Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:GithubActionsRunUrlPattern = "^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/[0-9]+(?:/attempts/[0-9]+)?$"
$script:RequiredNonClaims = @(
    "no final-state replay",
    "no R12 closeout",
    "no broad CI/product coverage",
    "no production evidence pipeline",
    "no R12 value-gate delivery yet"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Value | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $Path -Encoding UTF8
    return $Path
}

function Test-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
    }

    return $Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$Minimum = 0
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }
    $integer = [int]$Value
    if ($integer -lt $Minimum) {
        throw "$Context must be at least $Minimum."
    }
    return $integer
}

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }
    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }
    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }
    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }
    $items = @($Value)
    if ($items.Count -eq 0) {
        throw "$Context must not be empty."
    }
    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }
    $PSCmdlet.WriteObject($items, $false)
}

function Assert-RequiredObjectFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $Object -Context $Context | Out-Null
    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '^https?://') {
        return
    }
    if ($Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context path traversal is rejected."
    }
}

function Assert-ContainedFilePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context extraction path traversal is rejected."
    }
}

function Get-ExternalArtifactEvidenceContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner", "external_artifact_evidence_packet.contract.json")) -Label "External artifact evidence packet contract"
}

function Test-ExternalArtifactEvidencePacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "External artifact evidence packet"
    )

    $contract = Get-ExternalArtifactEvidenceContract
    Assert-RequiredObjectFields -Object $Packet -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Packet.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Packet.artifact_type -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }
    Assert-NonEmptyString -Value $Packet.evidence_packet_id -Context "$SourceLabel evidence_packet_id" | Out-Null
    if ($Packet.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Packet.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    foreach ($shaField in @("requested_head", "requested_tree", "observed_head", "observed_tree")) {
        $sha = Assert-NonEmptyString -Value $Packet.$shaField -Context "$SourceLabel $shaField"
        if ($sha -notmatch $script:GitObjectPattern) {
            throw "$SourceLabel $shaField must be a git object SHA."
        }
    }
    $sourceKind = Assert-NonEmptyString -Value $Packet.artifact_source_kind -Context "$SourceLabel artifact_source_kind"
    if ($contract.allowed_artifact_source_kinds -notcontains $sourceKind) {
        throw "$SourceLabel artifact_source_kind must be one of: $($contract.allowed_artifact_source_kinds -join ', ')."
    }
    $isExternalClaim = $sourceKind -in @("github_actions_artifact", "github_artifact_metadata")
    $runId = Assert-StringValue -Value $Packet.run_id -Context "$SourceLabel run_id"
    $runUrl = Assert-StringValue -Value $Packet.run_url -Context "$SourceLabel run_url"
    $artifactId = Assert-StringValue -Value $Packet.artifact_id -Context "$SourceLabel artifact_id"
    $artifactName = Assert-StringValue -Value $Packet.artifact_name -Context "$SourceLabel artifact_name"
    $digest = Assert-NonEmptyString -Value $Packet.artifact_digest_or_hash -Context "$SourceLabel artifact_digest_or_hash"
    if ($digest -match '^(?i)(missing|none|n/a|unavailable)$') {
        throw "$SourceLabel missing digest/hash must be explicitly recorded as unavailable with reason."
    }
    if ($isExternalClaim) {
        Assert-NonEmptyString -Value $runId -Context "$SourceLabel run_id" | Out-Null
        Assert-NonEmptyString -Value $runUrl -Context "$SourceLabel run_url" | Out-Null
        Assert-NonEmptyString -Value $artifactId -Context "$SourceLabel artifact_id" | Out-Null
        Assert-NonEmptyString -Value $artifactName -Context "$SourceLabel artifact_name" | Out-Null
        if ($runUrl -notmatch $script:GithubActionsRunUrlPattern -and $runUrl -notmatch '^https?://') {
            throw "$SourceLabel run_url must be concrete for external evidence."
        }
    }

    $importedAtUtc = Assert-NonEmptyString -Value $Packet.imported_at_utc -Context "$SourceLabel imported_at_utc"
    if ($importedAtUtc -notmatch $script:TimestampPattern) {
        throw "$SourceLabel imported_at_utc must be a UTC timestamp."
    }
    $sourcePath = Assert-NonEmptyString -Value $Packet.source_artifact_path_or_url -Context "$SourceLabel source_artifact_path_or_url"
    Assert-BoundedPathOrUrl -Value $sourcePath -Context "$SourceLabel source_artifact_path_or_url"
    $extractionRoot = Assert-NonEmptyString -Value $Packet.extraction_root -Context "$SourceLabel extraction_root"
    Assert-BoundedPathOrUrl -Value $extractionRoot -Context "$SourceLabel extraction_root"

    $containedFiles = Assert-ObjectArray -Value $Packet.contained_files -Context "$SourceLabel contained_files"
    foreach ($file in $containedFiles) {
        Assert-RequiredObjectFields -Object $file -FieldNames $contract.contained_file_required_fields -Context "$SourceLabel contained_file"
        $path = Assert-NonEmptyString -Value $file.path -Context "$SourceLabel contained_file.path"
        Assert-ContainedFilePath -Value $path -Context "$SourceLabel contained_file.path"
        Assert-IntegerValue -Value $file.size_bytes -Context "$SourceLabel contained_file.size_bytes" -Minimum 0 | Out-Null
        Assert-NonEmptyString -Value $file.digest_or_hash -Context "$SourceLabel contained_file.digest_or_hash" | Out-Null
    }

    Assert-StringValue -Value $Packet.replay_bundle_ref -Context "$SourceLabel replay_bundle_ref" | Out-Null
    Assert-StringValue -Value $Packet.external_runner_result_ref -Context "$SourceLabel external_runner_result_ref" | Out-Null
    if ($isExternalClaim) {
        Assert-NonEmptyString -Value $Packet.replay_bundle_ref -Context "$SourceLabel replay_bundle_ref" | Out-Null
        Assert-NonEmptyString -Value $Packet.external_runner_result_ref -Context "$SourceLabel external_runner_result_ref" | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$Packet.replay_bundle_ref)) {
        Assert-BoundedPathOrUrl -Value $Packet.replay_bundle_ref -Context "$SourceLabel replay_bundle_ref"
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$Packet.external_runner_result_ref)) {
        Assert-BoundedPathOrUrl -Value $Packet.external_runner_result_ref -Context "$SourceLabel external_runner_result_ref"
    }

    $summary = Get-RequiredProperty -Object $Packet -Name "command_results_summary" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $summary -FieldNames $contract.command_results_summary_required_fields -Context "$SourceLabel command_results_summary"
    $totalCount = Assert-IntegerValue -Value $summary.total_count -Context "$SourceLabel command_results_summary.total_count"
    $passedCount = Assert-IntegerValue -Value $summary.passed_count -Context "$SourceLabel command_results_summary.passed_count"
    $failedCount = Assert-IntegerValue -Value $summary.failed_count -Context "$SourceLabel command_results_summary.failed_count"
    $blockedCount = Assert-IntegerValue -Value $summary.blocked_count -Context "$SourceLabel command_results_summary.blocked_count"
    if (($passedCount + $failedCount + $blockedCount) -ne $totalCount) {
        throw "$SourceLabel command_results_summary counts must sum to total_count."
    }

    $aggregateVerdict = Assert-NonEmptyString -Value $Packet.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    if ($contract.allowed_aggregate_verdicts -notcontains $aggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be one of: $($contract.allowed_aggregate_verdicts -join ', ')."
    }
    $evidenceRefs = Assert-StringArray -Value $Packet.evidence_refs -Context "$SourceLabel evidence_refs"
    $refusalReasons = Assert-StringArray -Value $Packet.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$SourceLabel non_claims"
    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$SourceLabel non_claims must include '$requiredNonClaim'."
        }
    }
    if (-not $isExternalClaim -and $nonClaims -notcontains "local-only normalization is not external API evidence") {
        throw "$SourceLabel local artifact normalization must be labeled local-only, not external proof."
    }

    $headTreeMatch = ($Packet.requested_head -eq $Packet.observed_head -and $Packet.requested_tree -eq $Packet.observed_tree)
    if ($aggregateVerdict -eq "passed") {
        if (-not $headTreeMatch) {
            throw "$SourceLabel requested and observed head/tree must match for pass."
        }
        if ($failedCount -gt 0 -or $blockedCount -gt 0) {
            throw "$SourceLabel failed replay bundle cannot be imported as passed evidence."
        }
        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel passed aggregate verdict requires empty refusal_reasons."
        }
    }
    else {
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel failed or blocked aggregate verdict requires refusal_reasons."
        }
    }

    Write-Output -NoEnumerate ([pscustomobject]@{
            EvidencePacketId = $Packet.evidence_packet_id
            ArtifactSourceKind = $sourceKind
            ExternalEvidenceClaim = $isExternalClaim
            RunId = $runId
            ArtifactId = $artifactId
            AggregateVerdict = $aggregateVerdict
            ContainedFileCount = $containedFiles.Count
            EvidenceRefCount = $evidenceRefs.Count
        })
}

function Test-ExternalArtifactEvidencePacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $packet = Get-JsonDocument -Path $PacketPath -Label "External artifact evidence packet"
    return Test-ExternalArtifactEvidencePacketObject -Packet $packet -SourceLabel "External artifact evidence packet"
}

function New-ContainedFileSummary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath
    )

    $resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path
    $files = @()
    foreach ($file in Get-ChildItem -LiteralPath $resolvedRoot -File -Recurse) {
        $relativePath = [System.IO.Path]::GetRelativePath($resolvedRoot, $file.FullName).Replace("\", "/")
        $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256
        $files += [pscustomobject]@{
            path = $relativePath
            size_bytes = [int64]$file.Length
            digest_or_hash = "sha256:$($hash.Hash.ToLowerInvariant())"
        }
    }
    return $files
}

function Import-ExternalRunnerArtifactEvidence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("from_local_artifact_zip", "from_extracted_artifact_directory", "from_github_artifact_metadata", "validate_only")]
        [string]$Mode,
        [string]$PacketPath,
        [string]$SourcePath,
        [string]$ExtractionRoot,
        [string]$MetadataPath,
        [string]$OutputPath
    )

    if ($Mode -eq "validate_only") {
        if ([string]::IsNullOrWhiteSpace($PacketPath)) {
            throw "PacketPath is required for validate_only mode."
        }
        return Test-ExternalArtifactEvidencePacket -PacketPath $PacketPath
    }

    if ($Mode -eq "from_local_artifact_zip") {
        if ([string]::IsNullOrWhiteSpace($SourcePath) -or [string]::IsNullOrWhiteSpace($ExtractionRoot) -or [string]::IsNullOrWhiteSpace($OutputPath)) {
            throw "SourcePath, ExtractionRoot, and OutputPath are required for from_local_artifact_zip mode."
        }
        if ($SourcePath -match '(^|[\\/])\.\.([\\/]|$)' -or $ExtractionRoot -match '(^|[\\/])\.\.([\\/]|$)') {
            throw "from_local_artifact_zip path traversal is rejected."
        }
        New-Item -ItemType Directory -Path $ExtractionRoot -Force | Out-Null
        Expand-Archive -LiteralPath $SourcePath -DestinationPath $ExtractionRoot -Force
        $containedFiles = New-ContainedFileSummary -RootPath $ExtractionRoot
        $sourceHash = Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256
        $packet = [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_artifact_evidence_packet"
            evidence_packet_id = "local-artifact-" + [guid]::NewGuid().ToString("N")
            repository = "AIOffice_V2"
            branch = $script:R12Branch
            run_id = ""
            run_url = ""
            artifact_id = "local-artifact"
            artifact_name = [System.IO.Path]::GetFileName($SourcePath)
            artifact_digest_or_hash = "sha256:$($sourceHash.Hash.ToLowerInvariant())"
            artifact_source_kind = "local_artifact_zip"
            requested_head = "0000000000000000000000000000000000000000"
            requested_tree = "0000000000000000000000000000000000000000"
            observed_head = "0000000000000000000000000000000000000000"
            observed_tree = "0000000000000000000000000000000000000000"
            imported_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
            source_artifact_path_or_url = $SourcePath
            extraction_root = $ExtractionRoot
            contained_files = $containedFiles
            replay_bundle_ref = ""
            external_runner_result_ref = ""
            command_results_summary = [pscustomobject]@{ total_count = 0; passed_count = 0; failed_count = 0; blocked_count = 0 }
            aggregate_verdict = "passed"
            evidence_refs = @($SourcePath)
            refusal_reasons = @()
            non_claims = $script:RequiredNonClaims + @("local-only normalization is not external API evidence")
        }
        Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        return Test-ExternalArtifactEvidencePacketObject -Packet $packet -SourceLabel "External artifact evidence packet"
    }

    if ($Mode -eq "from_github_artifact_metadata") {
        if ([string]::IsNullOrWhiteSpace($MetadataPath) -or [string]::IsNullOrWhiteSpace($OutputPath)) {
            throw "MetadataPath and OutputPath are required for from_github_artifact_metadata mode."
        }
        $metadata = Get-JsonDocument -Path $MetadataPath -Label "GitHub artifact metadata"
        $packet = $metadata
        $packet.artifact_source_kind = "github_artifact_metadata"
        Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        return Test-ExternalArtifactEvidencePacketObject -Packet $packet -SourceLabel "External artifact evidence packet"
    }

    if ($Mode -eq "from_extracted_artifact_directory") {
        if ([string]::IsNullOrWhiteSpace($SourcePath) -or [string]::IsNullOrWhiteSpace($OutputPath)) {
            throw "SourcePath and OutputPath are required for from_extracted_artifact_directory mode."
        }
        $containedFiles = New-ContainedFileSummary -RootPath $SourcePath
        $packet = [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_artifact_evidence_packet"
            evidence_packet_id = "extracted-artifact-" + [guid]::NewGuid().ToString("N")
            repository = "AIOffice_V2"
            branch = $script:R12Branch
            run_id = ""
            run_url = ""
            artifact_id = "extracted-local-artifact"
            artifact_name = [System.IO.Path]::GetFileName($SourcePath)
            artifact_digest_or_hash = "unavailable: extracted directory source has no enclosing artifact digest"
            artifact_source_kind = "extracted_artifact_directory"
            requested_head = "0000000000000000000000000000000000000000"
            requested_tree = "0000000000000000000000000000000000000000"
            observed_head = "0000000000000000000000000000000000000000"
            observed_tree = "0000000000000000000000000000000000000000"
            imported_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
            source_artifact_path_or_url = $SourcePath
            extraction_root = $SourcePath
            contained_files = $containedFiles
            replay_bundle_ref = ""
            external_runner_result_ref = ""
            command_results_summary = [pscustomobject]@{ total_count = 0; passed_count = 0; failed_count = 0; blocked_count = 0 }
            aggregate_verdict = "passed"
            evidence_refs = @($SourcePath)
            refusal_reasons = @()
            non_claims = $script:RequiredNonClaims + @("local-only normalization is not external API evidence")
        }
        Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        return Test-ExternalArtifactEvidencePacketObject -Packet $packet -SourceLabel "External artifact evidence packet"
    }
}

Export-ModuleMember -Function Get-ExternalArtifactEvidenceContract, Test-ExternalArtifactEvidencePacketObject, Test-ExternalArtifactEvidencePacket, Import-ExternalRunnerArtifactEvidence
