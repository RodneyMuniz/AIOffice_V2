Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }
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

    Write-Output -NoEnumerate ($Object.$Name)
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

    Write-Output -NoEnumerate $items
}

function Assert-ObjectArray {
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

    Write-Output -NoEnumerate $items
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

function Assert-MatchesPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match required pattern '$Pattern'."
    }
}

function Assert-AllowedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [object[]]$AllowedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AllowedValues -notcontains $Value) {
        throw "$Context must be one of: $($AllowedValues -join ', ')."
    }
}

function Get-IsolatedQaFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\isolated_qa\foundation.contract.json") -Label "Isolated QA foundation contract"
}

function Get-IsolatedQaSignoffPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\isolated_qa\qa_signoff_packet.contract.json") -Label "Isolated QA signoff packet contract"
}

function Assert-ReferenceIsPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [object[]]$SourceArtifacts,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedKinds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = @($SourceArtifacts | Where-Object { $_.artifact_ref -eq $Reference })
    if ($matches.Count -eq 0) {
        throw "$Context must be represented in source_artifacts."
    }

    $kindMatches = @($matches | Where-Object { $AllowedKinds -contains $_.artifact_kind })
    if ($kindMatches.Count -eq 0) {
        throw "$Context source_artifacts entry must use artifact_kind '$($AllowedKinds -join "' or '")'."
    }
}

function Test-IsolatedQaSignoffObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $QaSignoffPacket,
        [string]$SourceLabel = "Isolated QA signoff packet",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-IsolatedQaFoundationContract
    $contract = Get-IsolatedQaSignoffPacketContract

    Assert-RequiredObjectFields -Object $QaSignoffPacket -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $packetType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "packet_type" -Context $SourceLabel) -Context "$SourceLabel packet_type"
    if ($packetType -ne $contract.packet_type -or $packetType -ne $foundation.qa_signoff_packet_type) {
        throw "$SourceLabel packet_type must be '$($contract.packet_type)'."
    }

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "packet_id" -Context $SourceLabel) -Context "$SourceLabel packet_id"
    Assert-MatchesPattern -Value $packetId -Pattern $foundation.identifier_pattern -Context "$SourceLabel packet_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    Assert-MatchesPattern -Value $repository -Pattern $foundation.repository_name_pattern -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    Assert-MatchesPattern -Value $branch -Pattern $foundation.branch_pattern -Context "$SourceLabel branch"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_milestone" -Context $SourceLabel) -Context "$SourceLabel source_milestone" | Out-Null
    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel source_task"
    Assert-MatchesPattern -Value $sourceTask -Pattern $foundation.source_task_pattern -Context "$SourceLabel source_task"

    $executorEvidenceRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "executor_evidence_refs" -Context $SourceLabel) -Context "$SourceLabel executor_evidence_refs"
    foreach ($executorEvidenceRef in $executorEvidenceRefs) {
        Resolve-ExistingPath -PathValue $executorEvidenceRef -Label "$SourceLabel executor_evidence_refs item" -AnchorPath $AnchorPath | Out-Null
    }

    $remoteHeadEvidenceRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "remote_head_evidence_ref" -Context $SourceLabel) -Context "$SourceLabel remote_head_evidence_ref"
    Resolve-ExistingPath -PathValue $remoteHeadEvidenceRef -Label "$SourceLabel remote_head_evidence_ref" -AnchorPath $AnchorPath | Out-Null

    $cleanCheckoutOrExternalQaRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "clean_checkout_or_external_qa_ref" -Context $SourceLabel) -Context "$SourceLabel clean_checkout_or_external_qa_ref"
    Resolve-ExistingPath -PathValue $cleanCheckoutOrExternalQaRef -Label "$SourceLabel clean_checkout_or_external_qa_ref" -AnchorPath $AnchorPath | Out-Null

    $qaRoleIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_role_identity" -Context $SourceLabel) -Context "$SourceLabel qa_role_identity"

    $qaRunnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_runner_kind" -Context $SourceLabel) -Context "$SourceLabel qa_runner_kind"
    Assert-AllowedValue -Value $qaRunnerKind -AllowedValues $foundation.allowed_qa_runner_kinds -Context "$SourceLabel qa_runner_kind"

    $qaAuthorityType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_authority_type" -Context $SourceLabel) -Context "$SourceLabel qa_authority_type"
    if ($qaAuthorityType -match $foundation.forbidden_self_certification_pattern) {
        throw "$SourceLabel qa_authority_type must not imply executor self-certification."
    }

    Assert-AllowedValue -Value $qaAuthorityType -AllowedValues $foundation.allowed_qa_authority_types -Context "$SourceLabel qa_authority_type"

    $sourceArtifacts = Assert-ObjectArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_artifacts" -Context $SourceLabel) -Context "$SourceLabel source_artifacts"
    $sourceArtifactRefs = @{}
    foreach ($sourceArtifact in $sourceArtifacts) {
        Assert-RequiredObjectFields -Object $sourceArtifact -FieldNames $contract.source_artifact_required_fields -Context "$SourceLabel source_artifacts item"

        $artifactRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "artifact_ref" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.artifact_ref"
        Resolve-ExistingPath -PathValue $artifactRef -Label "$SourceLabel source_artifacts item.artifact_ref" -AnchorPath $AnchorPath | Out-Null

        $artifactKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "artifact_kind" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.artifact_kind"
        Assert-AllowedValue -Value $artifactKind -AllowedValues $foundation.allowed_source_artifact_kinds -Context "$SourceLabel source_artifacts item.artifact_kind"

        $authorityRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "authority_role" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.authority_role"
        if ($artifactKind -eq "executor_evidence" -and $authorityRole -ne "source_evidence") {
            throw "$SourceLabel executor evidence refs must not be presented as QA verdict authority."
        }

        Assert-AllowedValue -Value $authorityRole -AllowedValues $foundation.allowed_artifact_authority_roles -Context "$SourceLabel source_artifacts item.authority_role"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "produced_by" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.produced_by" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "notes" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.notes" | Out-Null

        $sourceArtifactRefs[$artifactRef] = $sourceArtifact
    }

    foreach ($executorEvidenceRef in $executorEvidenceRefs) {
        Assert-ReferenceIsPresent -Reference $executorEvidenceRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("executor_evidence") -Context "$SourceLabel executor_evidence_refs item" | Out-Null
    }

    $hasRemoteArtifact = $false
    $hasCleanOrExternalArtifact = $false
    foreach ($sourceArtifact in $sourceArtifacts) {
        if ($sourceArtifact.artifact_kind -eq "remote_head_evidence") {
            $hasRemoteArtifact = $true
        }

        if ($sourceArtifact.artifact_kind -eq "local_qa_evidence" -or $sourceArtifact.artifact_kind -eq "clean_checkout_qa_evidence" -or $sourceArtifact.artifact_kind -eq "external_qa_evidence") {
            $hasCleanOrExternalArtifact = $true
        }
    }

    if (-not $hasRemoteArtifact -or -not $hasCleanOrExternalArtifact) {
        throw "$SourceLabel source_artifacts must include remote-head evidence and clean-checkout or external QA evidence; executor evidence alone is not QA signoff authority."
    }

    Assert-ReferenceIsPresent -Reference $remoteHeadEvidenceRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("remote_head_evidence") -Context "$SourceLabel remote_head_evidence_ref" | Out-Null
    Assert-ReferenceIsPresent -Reference $cleanCheckoutOrExternalQaRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("local_qa_evidence", "clean_checkout_qa_evidence", "external_qa_evidence") -Context "$SourceLabel clean_checkout_or_external_qa_ref" | Out-Null

    $verdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "verdict" -Context $SourceLabel) -Context "$SourceLabel verdict"
    Assert-AllowedValue -Value $verdict -AllowedValues $foundation.allowed_verdicts -Context "$SourceLabel verdict"

    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($verdict -eq "passed" -and $refusalReasons.Count -ne 0) {
        throw "$SourceLabel refusal_reasons must be empty when verdict is 'passed'."
    }

    if ($verdict -ne "passed" -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel refusal_reasons must not be empty when verdict is '$verdict'."
    }

    $independenceBoundary = Get-RequiredProperty -Object $QaSignoffPacket -Name "independence_boundary" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $independenceBoundary -FieldNames $contract.independence_boundary_required_fields -Context "$SourceLabel independence_boundary"

    $boundaryType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "boundary_type" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.boundary_type"
    Assert-AllowedValue -Value $boundaryType -AllowedValues $foundation.allowed_independence_boundary_types -Context "$SourceLabel independence_boundary.boundary_type"

    $executorIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "executor_identity" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.executor_identity"
    $qaIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "qa_identity" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.qa_identity"
    if ($qaIdentity -ne $qaRoleIdentity) {
        throw "$SourceLabel independence_boundary.qa_identity must match qa_role_identity."
    }

    if ($executorIdentity -eq $qaIdentity) {
        throw "$SourceLabel independence_boundary must not say the same executor produced and approved the signoff."
    }

    $executorArtifactsRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "executor_artifacts_role" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.executor_artifacts_role"
    if ($executorArtifactsRole -ne $foundation.required_executor_artifacts_role) {
        throw "$SourceLabel independence_boundary must preserve executor artifacts as source evidence only."
    }

    $statement = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "statement" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.statement"
    if ($statement -match '(?i)same executor.*(approved|signoff)|produced and approved') {
        throw "$SourceLabel independence_boundary must not say the same executor produced and approved the signoff."
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel created_at_utc"

    return [pscustomobject]@{
        PacketId = $packetId
        Repository = $repository
        Branch = $branch
        SourceTask = $sourceTask
        QaRoleIdentity = $qaRoleIdentity
        QaRunnerKind = $qaRunnerKind
        QaAuthorityType = $qaAuthorityType
        Verdict = $verdict
    }
}

function Test-IsolatedQaSignoffContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "Isolated QA signoff packet"
    $qaSignoffPacket = Get-JsonDocument -Path $resolvedPacketPath -Label "Isolated QA signoff packet"
    return Test-IsolatedQaSignoffObject -QaSignoffPacket $qaSignoffPacket -SourceLabel "Isolated QA signoff packet" -AnchorPath (Split-Path -Parent $resolvedPacketPath)
}

Export-ModuleMember -Function Test-IsolatedQaSignoffContract, Test-IsolatedQaSignoffObject
