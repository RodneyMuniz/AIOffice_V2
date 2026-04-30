Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:IdentifierPattern = "^[a-z0-9][a-z0-9._-]*$"
$script:GithubActionsRunUrlPattern = "^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/[0-9]+(?:/attempts/[0-9]+)?$"
$script:RequiredExternalRunnerNonClaims = @(
    "no full external orchestrator product",
    "no final-state replay",
    "no broad CI/product coverage",
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

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
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

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredExternalRunnerNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-R12RepositoryBranchHeadTree {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$HeadField = "requested_head",
        [string]$TreeField = "requested_tree"
    )

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "repository" -Context $Context) -Context "$Context repository"
    if ($repository -ne $script:R12RepositoryName) {
        throw "$Context repository must be '$script:R12RepositoryName'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "branch" -Context $Context) -Context "$Context branch"
    if ($branch -ne $script:R12Branch) {
        throw "$Context branch must be '$script:R12Branch'."
    }

    $head = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name $HeadField -Context $Context) -Context "$Context $HeadField"
    $tree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name $TreeField -Context $Context) -Context "$Context $TreeField"
    Assert-MatchesPattern -Value $head -Pattern $script:GitObjectPattern -Context "$Context $HeadField"
    Assert-MatchesPattern -Value $tree -Pattern $script:GitObjectPattern -Context "$Context $TreeField"

    return [pscustomobject]@{
        Repository = $repository
        Branch = $branch
        Head = $head
        Tree = $tree
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    Assert-MatchesPattern -Value $timestamp -Pattern $script:TimestampPattern -Context $Context
    return $timestamp
}

function Assert-ConcreteRunIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunId,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunUrl,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $RunId -Context "$Context run_id" | Out-Null
    Assert-NonEmptyString -Value $RunUrl -Context "$Context run_url" | Out-Null
    if ($RunId -match '(?i)^(mock|test|dummy|placeholder|local)') {
        throw "$Context run_id must be concrete and must not be mock, dummy, placeholder, or local-only."
    }
    if ($RunUrl -notmatch $script:GithubActionsRunUrlPattern -and $RunUrl -notmatch '^https?://') {
        throw "$Context run_url must be a concrete external URL."
    }
}

function Assert-NoLocalOnlyExternalProof {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        if ($value -match '(?i)local[-_ ]only|local[-_ ]artifact|local[-_ ]evidence') {
            throw "$Context local-only evidence cannot be used for an external runner claim."
        }
    }
}

function Get-ExternalRunnerRequestContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner", "external_runner_request.contract.json")) -Label "External runner request contract"
}

function Get-ExternalRunnerResultContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner", "external_runner_result.contract.json")) -Label "External runner result contract"
}

function Get-ExternalRunnerArtifactManifestContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner", "external_runner_artifact_manifest.contract.json")) -Label "External runner artifact manifest contract"
}

function Test-ExternalRunnerRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [string]$SourceLabel = "External runner request"
    )

    $contract = Get-ExternalRunnerRequestContract
    Assert-RequiredObjectFields -Object $Request -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value $Request.contract_version -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Request.artifact_type -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }

    Assert-NonEmptyString -Value $Request.request_id -Context "$SourceLabel request_id" | Out-Null
    Assert-MatchesPattern -Value $Request.request_id -Pattern $script:IdentifierPattern -Context "$SourceLabel request_id"
    $identity = Assert-R12RepositoryBranchHeadTree -Artifact $Request -Context $SourceLabel
    Assert-NonEmptyString -Value $Request.workflow_ref -Context "$SourceLabel workflow_ref" | Out-Null
    Assert-NonEmptyString -Value $Request.workflow_name -Context "$SourceLabel workflow_name" | Out-Null
    $dispatchMode = Assert-NonEmptyString -Value $Request.dispatch_mode -Context "$SourceLabel dispatch_mode"
    Assert-AllowedValue -Value $dispatchMode -AllowedValues $contract.allowed_dispatch_modes -Context "$SourceLabel dispatch_mode"
    $runnerKind = Assert-NonEmptyString -Value $Request.runner_kind -Context "$SourceLabel runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $contract.allowed_runner_kinds -Context "$SourceLabel runner_kind"
    Assert-IntegerValue -Value $Request.timeout_seconds -Context "$SourceLabel timeout_seconds" -Minimum 1 | Out-Null
    Assert-NonEmptyString -Value $Request.caller_identity -Context "$SourceLabel caller_identity" | Out-Null
    Assert-NonEmptyString -Value $Request.residue_preflight_ref -Context "$SourceLabel residue_preflight_ref" | Out-Null
    Assert-NonEmptyString -Value $Request.remote_head_phase_detection_ref -Context "$SourceLabel remote_head_phase_detection_ref" | Out-Null
    Assert-TimestampString -Value $Request.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null

    $commands = Assert-ObjectArray -Value $Request.commands -Context "$SourceLabel commands"
    foreach ($command in $commands) {
        Assert-RequiredObjectFields -Object $command -FieldNames $contract.command_required_fields -Context "$SourceLabel command"
        Assert-NonEmptyString -Value $command.command_id -Context "$SourceLabel command.command_id" | Out-Null
        Assert-NonEmptyString -Value $command.command -Context "$SourceLabel command.command" | Out-Null
        Assert-NonEmptyString -Value $command.purpose -Context "$SourceLabel command.purpose" | Out-Null
    }

    $expectedArtifacts = Assert-ObjectArray -Value $Request.expected_artifacts -Context "$SourceLabel expected_artifacts"
    foreach ($artifact in $expectedArtifacts) {
        Assert-RequiredObjectFields -Object $artifact -FieldNames $contract.expected_artifact_required_fields -Context "$SourceLabel expected_artifact"
        Assert-NonEmptyString -Value $artifact.artifact_name -Context "$SourceLabel expected_artifact.artifact_name" | Out-Null
        Assert-BooleanValue -Value $artifact.required -Context "$SourceLabel expected_artifact.required" | Out-Null
        Assert-NonEmptyString -Value $artifact.description -Context "$SourceLabel expected_artifact.description" | Out-Null
    }

    $evidenceRefs = Assert-StringArray -Value $Request.evidence_refs -Context "$SourceLabel evidence_refs"
    $nonClaims = Assert-StringArray -Value $Request.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    Write-Output -NoEnumerate ([pscustomobject]@{
            RequestId = $Request.request_id
            Repository = $identity.Repository
            Branch = $identity.Branch
            RequestedHead = $identity.Head
            RequestedTree = $identity.Tree
            DispatchMode = $dispatchMode
            RunnerKind = $runnerKind
            CommandCount = $commands.Count
            ExpectedArtifactCount = $expectedArtifacts.Count
            EvidenceRefCount = $evidenceRefs.Count
        })
}

function Test-ExternalRunnerResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$SourceLabel = "External runner result"
    )

    $contract = Get-ExternalRunnerResultContract
    Assert-RequiredObjectFields -Object $Result -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Result.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Result.artifact_type -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }

    Assert-NonEmptyString -Value $Result.result_id -Context "$SourceLabel result_id" | Out-Null
    Assert-MatchesPattern -Value $Result.result_id -Pattern $script:IdentifierPattern -Context "$SourceLabel result_id"
    Assert-NonEmptyString -Value $Result.request_id -Context "$SourceLabel request_id" | Out-Null
    $identity = Assert-R12RepositoryBranchHeadTree -Artifact $Result -Context $SourceLabel
    $observedHead = Assert-NonEmptyString -Value $Result.observed_head -Context "$SourceLabel observed_head"
    $observedTree = Assert-NonEmptyString -Value $Result.observed_tree -Context "$SourceLabel observed_tree"
    Assert-MatchesPattern -Value $observedHead -Pattern $script:GitObjectPattern -Context "$SourceLabel observed_head"
    Assert-MatchesPattern -Value $observedTree -Pattern $script:GitObjectPattern -Context "$SourceLabel observed_tree"
    Assert-NonEmptyString -Value $Result.workflow_ref -Context "$SourceLabel workflow_ref" | Out-Null
    Assert-NonEmptyString -Value $Result.workflow_name -Context "$SourceLabel workflow_name" | Out-Null
    $runnerKind = Assert-NonEmptyString -Value $Result.runner_kind -Context "$SourceLabel runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $contract.allowed_runner_kinds -Context "$SourceLabel runner_kind"
    $runId = Assert-StringValue -Value $Result.run_id -Context "$SourceLabel run_id"
    $runUrl = Assert-StringValue -Value $Result.run_url -Context "$SourceLabel run_url"
    Assert-IntegerValue -Value $Result.run_attempt -Context "$SourceLabel run_attempt" -Minimum 0 | Out-Null
    $status = Assert-NonEmptyString -Value $Result.status -Context "$SourceLabel status"
    $conclusion = Assert-NonEmptyString -Value $Result.conclusion -Context "$SourceLabel conclusion"
    Assert-AllowedValue -Value $status -AllowedValues $contract.allowed_statuses -Context "$SourceLabel status"
    Assert-AllowedValue -Value $conclusion -AllowedValues $contract.allowed_conclusions -Context "$SourceLabel conclusion"
    Assert-TimestampString -Value $Result.started_at_utc -Context "$SourceLabel started_at_utc" | Out-Null
    Assert-TimestampString -Value $Result.completed_at_utc -Context "$SourceLabel completed_at_utc" | Out-Null
    $artifactManifestRef = Assert-StringValue -Value $Result.artifact_manifest_ref -Context "$SourceLabel artifact_manifest_ref"

    $commandResults = Assert-ObjectArray -Value $Result.command_results -Context "$SourceLabel command_results"
    $passedCommands = 0
    foreach ($commandResult in $commandResults) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames $contract.command_result_required_fields -Context "$SourceLabel command_result"
        Assert-NonEmptyString -Value $commandResult.command_id -Context "$SourceLabel command_result.command_id" | Out-Null
        Assert-NonEmptyString -Value $commandResult.command -Context "$SourceLabel command_result.command" | Out-Null
        $exitCode = Assert-IntegerValue -Value $commandResult.exit_code -Context "$SourceLabel command_result.exit_code" -Minimum 0
        $verdict = Assert-NonEmptyString -Value $commandResult.verdict -Context "$SourceLabel command_result.verdict"
        Assert-AllowedValue -Value $verdict -AllowedValues $contract.allowed_command_verdicts -Context "$SourceLabel command_result.verdict"
        Assert-NonEmptyString -Value $commandResult.stdout_ref -Context "$SourceLabel command_result.stdout_ref" | Out-Null
        Assert-NonEmptyString -Value $commandResult.stderr_ref -Context "$SourceLabel command_result.stderr_ref" | Out-Null
        if ($verdict -eq "passed" -and $exitCode -ne 0) {
            throw "$SourceLabel command_result verdict passed requires exit_code 0."
        }
        if ($verdict -eq "passed") {
            $passedCommands += 1
        }
    }

    $rawLogRefs = Assert-StringArray -Value $Result.raw_log_refs -Context "$SourceLabel raw_log_refs"
    $evidenceRefs = Assert-StringArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs"
    $refusalReasons = Assert-StringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    $nonClaims = Assert-StringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    $successful = ($status -eq "completed" -and $conclusion -eq "success")
    if ($successful) {
        Assert-ConcreteRunIdentity -RunId $runId -RunUrl $runUrl -Context $SourceLabel
        if ($Result.run_attempt -lt 1) {
            throw "$SourceLabel successful result requires run_attempt of at least 1."
        }
        if ($identity.Head -ne $observedHead -or $identity.Tree -ne $observedTree) {
            throw "$SourceLabel successful result requires matching requested/observed head and tree."
        }
        Assert-NonEmptyString -Value $artifactManifestRef -Context "$SourceLabel artifact_manifest_ref" | Out-Null
        Assert-NoLocalOnlyExternalProof -Values ($evidenceRefs + $rawLogRefs + @($artifactManifestRef)) -Context $SourceLabel
        $nonPassed = @($commandResults | Where-Object { $_.verdict -ne "passed" })
        if ($nonPassed.Count -gt 0) {
            throw "$SourceLabel successful result requires all command_results to pass."
        }
        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel successful result requires refusal_reasons to be empty."
        }
    }
    else {
        if ($conclusion -eq "success") {
            throw "$SourceLabel conclusion success requires status completed."
        }
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel failed or missing run cannot be accepted as passed evidence; refusal_reasons are required."
        }
        if ($passedCommands -eq $commandResults.Count) {
            throw "$SourceLabel failed or missing run cannot be presented as pass evidence."
        }
    }

    Write-Output -NoEnumerate ([pscustomobject]@{
            ResultId = $Result.result_id
            RequestId = $Result.request_id
            Repository = $identity.Repository
            Branch = $identity.Branch
            RequestedHead = $identity.Head
            RequestedTree = $identity.Tree
            ObservedHead = $observedHead
            ObservedTree = $observedTree
            RunnerKind = $runnerKind
            RunId = $runId
            Status = $status
            Conclusion = $conclusion
            SuccessfulExternalEvidenceShape = $successful
            CommandCount = $commandResults.Count
        })
}

function Test-ExternalRunnerArtifactManifestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Manifest,
        [string]$SourceLabel = "External runner artifact manifest"
    )

    $contract = Get-ExternalRunnerArtifactManifestContract
    Assert-RequiredObjectFields -Object $Manifest -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Manifest.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Manifest.artifact_type -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }

    Assert-NonEmptyString -Value $Manifest.manifest_id -Context "$SourceLabel manifest_id" | Out-Null
    Assert-MatchesPattern -Value $Manifest.manifest_id -Pattern $script:IdentifierPattern -Context "$SourceLabel manifest_id"
    $identity = Assert-R12RepositoryBranchHeadTree -Artifact $Manifest -Context $SourceLabel
    $observedHead = Assert-NonEmptyString -Value $Manifest.observed_head -Context "$SourceLabel observed_head"
    $observedTree = Assert-NonEmptyString -Value $Manifest.observed_tree -Context "$SourceLabel observed_tree"
    Assert-MatchesPattern -Value $observedHead -Pattern $script:GitObjectPattern -Context "$SourceLabel observed_head"
    Assert-MatchesPattern -Value $observedTree -Pattern $script:GitObjectPattern -Context "$SourceLabel observed_tree"
    if ($identity.Head -ne $observedHead -or $identity.Tree -ne $observedTree) {
        throw "$SourceLabel head/tree mismatch is rejected."
    }

    Assert-ConcreteRunIdentity -RunId (Assert-NonEmptyString -Value $Manifest.run_id -Context "$SourceLabel run_id") -RunUrl (Assert-NonEmptyString -Value $Manifest.run_url -Context "$SourceLabel run_url") -Context $SourceLabel
    Assert-NonEmptyString -Value $Manifest.artifact_id -Context "$SourceLabel artifact_id" | Out-Null
    Assert-NonEmptyString -Value $Manifest.artifact_name -Context "$SourceLabel artifact_name" | Out-Null
    Assert-NonEmptyString -Value $Manifest.artifact_url_or_path -Context "$SourceLabel artifact_url_or_path" | Out-Null
    $digest = Assert-NonEmptyString -Value $Manifest.artifact_digest_or_hash -Context "$SourceLabel artifact_digest_or_hash"
    if ($digest -match '^(?i)(n/a|none|missing|unavailable)$') {
        throw "$SourceLabel artifact_digest_or_hash must include a digest/hash or an explicit unavailable reason."
    }
    Assert-IntegerValue -Value $Manifest.artifact_size_bytes -Context "$SourceLabel artifact_size_bytes" -Minimum 0 | Out-Null
    Assert-TimestampString -Value $Manifest.downloaded_at_utc -Context "$SourceLabel downloaded_at_utc" | Out-Null
    Assert-NonEmptyString -Value $Manifest.extraction_root -Context "$SourceLabel extraction_root" | Out-Null

    $containedFiles = Assert-ObjectArray -Value $Manifest.contained_files -Context "$SourceLabel contained_files"
    foreach ($file in $containedFiles) {
        Assert-RequiredObjectFields -Object $file -FieldNames $contract.contained_file_required_fields -Context "$SourceLabel contained_file"
        Assert-NonEmptyString -Value $file.path -Context "$SourceLabel contained_file.path" | Out-Null
        Assert-IntegerValue -Value $file.size_bytes -Context "$SourceLabel contained_file.size_bytes" -Minimum 0 | Out-Null
        Assert-NonEmptyString -Value $file.digest_or_hash -Context "$SourceLabel contained_file.digest_or_hash" | Out-Null
    }

    $evidenceRefs = Assert-StringArray -Value $Manifest.evidence_refs -Context "$SourceLabel evidence_refs"
    $nonClaims = Assert-StringArray -Value $Manifest.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    Write-Output -NoEnumerate ([pscustomobject]@{
            ManifestId = $Manifest.manifest_id
            Repository = $identity.Repository
            Branch = $identity.Branch
            RunId = $Manifest.run_id
            ArtifactId = $Manifest.artifact_id
            ArtifactName = $Manifest.artifact_name
            ContainedFileCount = $containedFiles.Count
            EvidenceRefCount = $evidenceRefs.Count
            HeadTreeMatch = $true
        })
}

function Test-ExternalRunnerRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath
    )

    $request = Get-JsonDocument -Path $RequestPath -Label "External runner request"
    return Test-ExternalRunnerRequestObject -Request $request -SourceLabel "External runner request"
}

function Test-ExternalRunnerResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath
    )

    $result = Get-JsonDocument -Path $ResultPath -Label "External runner result"
    return Test-ExternalRunnerResultObject -Result $result -SourceLabel "External runner result"
}

function Test-ExternalRunnerArtifactManifestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath
    )

    $manifest = Get-JsonDocument -Path $ManifestPath -Label "External runner artifact manifest"
    return Test-ExternalRunnerArtifactManifestObject -Manifest $manifest -SourceLabel "External runner artifact manifest"
}

Export-ModuleMember -Function Get-ExternalRunnerRequestContract, Get-ExternalRunnerResultContract, Get-ExternalRunnerArtifactManifestContract, Test-ExternalRunnerRequestObject, Test-ExternalRunnerResultObject, Test-ExternalRunnerArtifactManifestObject, Test-ExternalRunnerRequestContract, Test-ExternalRunnerResultContract, Test-ExternalRunnerArtifactManifestContract
