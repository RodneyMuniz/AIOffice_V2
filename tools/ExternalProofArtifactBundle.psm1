Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

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

    $property = $Object.PSObject.Properties[$Name]
    $PSCmdlet.WriteObject($property.Value, $false)
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

    return $Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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

function Assert-RequiredReference {
    param(
        [AllowNull()]
        $Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $referenceValue = Assert-NonEmptyString -Value $Reference -Context $Label
    Resolve-ExistingPath -PathValue $referenceValue -Label $Label -AnchorPath $AnchorPath | Out-Null
    return $referenceValue
}

function Get-ExternalProofBundleFoundationContract {
    $contract = Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_proof_bundle", "foundation.contract.json")) -Label "External proof bundle foundation contract"
    return $contract
}

function Get-ExternalProofArtifactBundleContract {
    $contract = Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_proof_bundle", "external_proof_artifact_bundle.contract.json")) -Label "External proof artifact bundle contract"
    return $contract
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredNonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-NoForbiddenBundleClaimText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        $hasNegation = $value -match '(?i)\b(no|not|without|must not|does not|cannot|insufficient)\b'

        if ($value -match '(?i)\b(broad|production-grade|product(?:ion)?|product)\b.{0,80}\b(CI|coverage|product coverage)\b.{0,80}\b(claim|claimed|proves|proof|exists|available|complete|supported|covered)\b' -and -not $hasNegation) {
            throw "$Context must not claim broad CI/product coverage."
        }

        if ($value -match '(?i)\b(UI|control-room|control room|Standard runtime|multi-repo|swarms?|fleet execution|broad autonomous|unattended automatic resume|solved Codex context compaction|context compaction solved|hours-long unattended|destructive rollback|general Codex reliability)\b.{0,120}\b(claim|claimed|proves|proof|exists|available|complete|supported|solved)\b' -and -not $hasNegation) {
            throw "$Context must not claim UI, Standard runtime, multi-repo, swarms, broad autonomy, unattended resume, solved compaction, hours-long execution, destructive rollback, or general Codex reliability."
        }
    }
}

function Test-ExternalProofCleanStatus {
    param(
        [Parameter(Mandatory = $true)]
        $CleanStatus,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    Assert-RequiredObjectFields -Object $CleanStatus -FieldNames $Contract.clean_status_required_fields -Context $SourceLabel
    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CleanStatus -Name "status" -Context $SourceLabel) -Context "$SourceLabel status"
    Assert-AllowedValue -Value $status -AllowedValues $Foundation.allowed_clean_statuses -Context "$SourceLabel status"
    $evidenceRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $CleanStatus -Name "evidence_ref" -Context $SourceLabel) -Label "$SourceLabel evidence_ref" -AnchorPath $AnchorPath

    if ($status -ne "clean" -and (Test-HasProperty -Object $CleanStatus -Name "refusal_reason")) {
        Assert-NonEmptyString -Value $CleanStatus.refusal_reason -Context "$SourceLabel refusal_reason" | Out-Null
    }

    $result = [pscustomobject]@{
        Status = $status
        EvidenceRef = $evidenceRef
    }

    Write-Output -NoEnumerate $result
}

function Test-ExternalProofCommandResult {
    param(
        [Parameter(Mandatory = $true)]
        $CommandResult,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    Assert-RequiredObjectFields -Object $CommandResult -FieldNames $Contract.command_result_required_fields -Context $SourceLabel

    $commandId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CommandResult -Name "command_id" -Context $SourceLabel) -Context "$SourceLabel command_id"
    Assert-MatchesPattern -Value $commandId -Pattern $Foundation.identifier_pattern -Context "$SourceLabel command_id"
    $command = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CommandResult -Name "command" -Context $SourceLabel) -Context "$SourceLabel command"
    $stdoutRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $CommandResult -Name "stdout_ref" -Context $SourceLabel) -Label "$SourceLabel stdout_ref" -AnchorPath $AnchorPath
    $stderrRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $CommandResult -Name "stderr_ref" -Context $SourceLabel) -Label "$SourceLabel stderr_ref" -AnchorPath $AnchorPath
    $exitCodeRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $CommandResult -Name "exit_code_ref" -Context $SourceLabel) -Label "$SourceLabel exit_code_ref" -AnchorPath $AnchorPath
    $exitCode = Assert-IntegerValue -Value (Get-RequiredProperty -Object $CommandResult -Name "exit_code" -Context $SourceLabel) -Context "$SourceLabel exit_code"
    $verdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CommandResult -Name "verdict" -Context $SourceLabel) -Context "$SourceLabel verdict"
    Assert-AllowedValue -Value $verdict -AllowedValues $Foundation.allowed_command_verdicts -Context "$SourceLabel verdict"

    if ($verdict -eq "passed" -and $exitCode -ne 0) {
        throw "$SourceLabel verdict 'passed' requires exit_code 0."
    }

    $result = [pscustomobject]@{
        CommandId = $commandId
        Command = $command
        StdoutRef = $stdoutRef
        StderrRef = $stderrRef
        ExitCodeRef = $exitCodeRef
        ExitCode = $exitCode
        Verdict = $verdict
    }

    Write-Output -NoEnumerate $result
}

function Test-ExternalProofArtifactBundleObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Bundle,
        [string]$SourceLabel = "External proof artifact bundle",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-ExternalProofBundleFoundationContract
    $contract = Get-ExternalProofArtifactBundleContract

    Assert-RequiredObjectFields -Object $Bundle -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $bundleType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "bundle_type" -Context $SourceLabel) -Context "$SourceLabel bundle_type"
    if ($bundleType -ne $foundation.bundle_type -or $bundleType -ne $contract.bundle_type) {
        throw "$SourceLabel bundle_type must be '$($foundation.bundle_type)'."
    }

    $bundleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "bundle_id" -Context $SourceLabel) -Context "$SourceLabel bundle_id"
    Assert-MatchesPattern -Value $bundleId -Pattern $foundation.identifier_pattern -Context "$SourceLabel bundle_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    if ($branch -ne $foundation.required_branch) {
        throw "$SourceLabel branch must be '$($foundation.required_branch)'."
    }

    $triggeringRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "triggering_ref" -Context $SourceLabel) -Context "$SourceLabel triggering_ref"
    Assert-MatchesPattern -Value $triggeringRef -Pattern $foundation.branch_pattern -Context "$SourceLabel triggering_ref"

    $runnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "runner_kind" -Context $SourceLabel) -Context "$SourceLabel runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $foundation.allowed_runner_kinds -Context "$SourceLabel runner_kind"

    $runnerIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "runner_identity" -Context $SourceLabel) -Context "$SourceLabel runner_identity"
    $workflowName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "workflow_name" -Context $SourceLabel) -Context "$SourceLabel workflow_name"
    $workflowRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Bundle -Name "workflow_ref" -Context $SourceLabel) -Label "$SourceLabel workflow_ref" -AnchorPath (Get-ModuleRepositoryRootPath)
    $runId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "run_id" -Context $SourceLabel) -Context "$SourceLabel run_id"
    $runUrl = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "run_url" -Context $SourceLabel) -Context "$SourceLabel run_url"
    $artifactName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "artifact_name" -Context $SourceLabel) -Context "$SourceLabel artifact_name"
    $retrievalInstruction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "artifact_url_or_retrieval_instruction" -Context $SourceLabel) -Context "$SourceLabel artifact_url_or_retrieval_instruction"

    if ($retrievalInstruction -match '(?i)^(n/a|none|unavailable|limitation)$') {
        throw "$SourceLabel artifact_url_or_retrieval_instruction must be actionable."
    }

    if ($runnerKind -eq "github_actions") {
        Assert-MatchesPattern -Value $runUrl -Pattern $foundation.github_actions_run_url_pattern -Context "$SourceLabel run_url"
    }
    elseif ($runUrl -notmatch '^https?://') {
        throw "$SourceLabel run_url must be a concrete external runner URL."
    }

    $remoteHeadSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "remote_head_sha" -Context $SourceLabel) -Context "$SourceLabel remote_head_sha"
    $testedHeadSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "tested_head_sha" -Context $SourceLabel) -Context "$SourceLabel tested_head_sha"
    $testedTreeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "tested_tree_sha" -Context $SourceLabel) -Context "$SourceLabel tested_tree_sha"
    Assert-MatchesPattern -Value $remoteHeadSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel remote_head_sha"
    Assert-MatchesPattern -Value $testedHeadSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel tested_head_sha"
    Assert-MatchesPattern -Value $testedTreeSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel tested_tree_sha"

    $headMatch = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Bundle -Name "head_match" -Context $SourceLabel) -Context "$SourceLabel head_match"
    if ($headMatch -and $remoteHeadSha -ne $testedHeadSha) {
        throw "$SourceLabel head_match true requires remote_head_sha to equal tested_head_sha."
    }

    if (-not $headMatch -and $remoteHeadSha -eq $testedHeadSha) {
        throw "$SourceLabel head_match false requires remote_head_sha to differ from tested_head_sha."
    }

    $cleanStatusBefore = Test-ExternalProofCleanStatus -CleanStatus (Get-RequiredProperty -Object $Bundle -Name "clean_status_before" -Context $SourceLabel) -SourceLabel "$SourceLabel clean_status_before" -AnchorPath $AnchorPath -Foundation $foundation -Contract $contract
    $cleanStatusAfter = Test-ExternalProofCleanStatus -CleanStatus (Get-RequiredProperty -Object $Bundle -Name "clean_status_after" -Context $SourceLabel) -SourceLabel "$SourceLabel clean_status_after" -AnchorPath $AnchorPath -Foundation $foundation -Contract $contract
    $commandManifestRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Bundle -Name "command_manifest_ref" -Context $SourceLabel) -Label "$SourceLabel command_manifest_ref" -AnchorPath $AnchorPath
    $commandResults = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Bundle -Name "command_results" -Context $SourceLabel) -Context "$SourceLabel command_results"
    $validatedCommandResults = @()
    $commandIds = @{}

    foreach ($commandResult in $commandResults) {
        $validatedCommandResult = Test-ExternalProofCommandResult -CommandResult $commandResult -SourceLabel "$SourceLabel command_results item" -AnchorPath $AnchorPath -Foundation $foundation -Contract $contract
        if ($commandIds.ContainsKey($validatedCommandResult.CommandId)) {
            throw "$SourceLabel command_results contains duplicate command_id '$($validatedCommandResult.CommandId)'."
        }

        $commandIds[$validatedCommandResult.CommandId] = $true
        $validatedCommandResults += $validatedCommandResult
    }

    $aggregateVerdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "aggregate_verdict" -Context $SourceLabel) -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $foundation.allowed_aggregate_verdicts -Context "$SourceLabel aggregate_verdict"

    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $Bundle -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty

    if ($aggregateVerdict -eq "passed") {
        if (-not $headMatch) {
            throw "$SourceLabel head_match cannot be false when aggregate_verdict is 'passed'."
        }

        $nonPassedCommands = @($validatedCommandResults | Where-Object { $_.Verdict -ne "passed" })
        if ($nonPassedCommands.Count -gt 0) {
            throw "$SourceLabel aggregate_verdict 'passed' requires every command result verdict to be 'passed'."
        }

        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel aggregate_verdict 'passed' requires refusal_reasons to be empty."
        }
    }
    elseif ($refusalReasons.Count -eq 0) {
        throw "$SourceLabel aggregate_verdict '$aggregateVerdict' requires refusal_reasons to be non-empty."
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Bundle -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel created_at_utc"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $Bundle -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $foundation.required_non_claims -Context $SourceLabel

    $claimText = @(
        $bundleId,
        $repository,
        $branch,
        $triggeringRef,
        $runnerKind,
        $runnerIdentity,
        $workflowName,
        $workflowRef,
        $runId,
        $runUrl,
        $artifactName,
        $retrievalInstruction,
        $commandManifestRef
    )
    $claimText += $refusalReasons
    $claimText += $nonClaims
    foreach ($validatedCommandResult in $validatedCommandResults) {
        $claimText += $validatedCommandResult.CommandId
        $claimText += $validatedCommandResult.Command
        $claimText += $validatedCommandResult.StdoutRef
        $claimText += $validatedCommandResult.StderrRef
        $claimText += $validatedCommandResult.ExitCodeRef
    }
    Assert-NoForbiddenBundleClaimText -Values $claimText -Context $SourceLabel

    $result = [pscustomobject]@{
        BundleId = $bundleId
        Repository = $repository
        Branch = $branch
        RemoteHeadSha = $remoteHeadSha
        TestedHeadSha = $testedHeadSha
        TestedTreeSha = $testedTreeSha
        HeadMatch = $headMatch
        RunnerKind = $runnerKind
        RunId = $runId
        RunUrl = $runUrl
        ArtifactName = $artifactName
        CleanStatusBefore = $cleanStatusBefore.Status
        CleanStatusAfter = $cleanStatusAfter.Status
        CommandCount = $validatedCommandResults.Count
        AggregateVerdict = $aggregateVerdict
        IsPassingBundleShape = ($aggregateVerdict -eq "passed")
    }

    Write-Output -NoEnumerate $result
}

function Test-ExternalProofArtifactBundleContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BundlePath
    )

    $resolvedBundlePath = Resolve-ExistingPath -PathValue $BundlePath -Label "External proof artifact bundle"
    $bundle = Get-JsonDocument -Path $resolvedBundlePath -Label "External proof artifact bundle"
    $validation = Test-ExternalProofArtifactBundleObject -Bundle $bundle -SourceLabel "External proof artifact bundle" -AnchorPath (Split-Path -Parent $resolvedBundlePath)
    Write-Output -NoEnumerate $validation
}

Export-ModuleMember -Function Test-ExternalProofArtifactBundleContract, Test-ExternalProofArtifactBundleObject
