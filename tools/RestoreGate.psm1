Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneBaselineModule = Import-Module (Join-Path $PSScriptRoot "MilestoneBaseline.psm1") -Force -PassThru
$script:testMilestoneBaselineRecordContract = $milestoneBaselineModule.ExportedCommands["Test-MilestoneBaselineRecordContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-OptionalPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-OptionalPath -PathValue $PathValue
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

function Assert-NullableString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    return (Assert-NonEmptyString -Value $Value -Context $Context)
}

function Assert-RegexMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match the required pattern."
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    Write-Output -NoEnumerate $items
}

function Get-RestoreGateFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\foundation.contract.json") -Label "Restore gate foundation contract"
}

function Get-RestoreGateRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\request.contract.json") -Label "Restore gate request contract"
}

function Get-RestoreGateResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\result.contract.json") -Label "Restore gate result contract"
}

function Get-RestoreGateResultStorePath {
    param(
        [string]$StorePath
    )

    if ([string]::IsNullOrWhiteSpace($StorePath)) {
        return Join-Path (Get-RepositoryRoot) "state\restore_gate_results"
    }

    return (Resolve-OptionalPath -PathValue $StorePath)
}

function Assert-OperatorIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    $operatorId = Assert-NonEmptyString -Value $Value -Context $Context
    Assert-RegexMatch -Value $operatorId -Pattern $Foundation.operator_pattern -Context $Context
    return $operatorId
}

function Assert-GitCliAvailable {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        throw "Restore gate requires Git CLI to be installed and callable."
    }

    return $gitCommand
}

function Get-GitWorktreeRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    Assert-GitCliAvailable | Out-Null
    $resolvedRepositoryPath = Resolve-ExistingPath -PathValue $RepositoryPath -Label "Target repository root"
    $worktreeRoot = (& git -C $resolvedRepositoryPath rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($worktreeRoot)) {
        throw "Target repository root '$resolvedRepositoryPath' must resolve inside a Git worktree."
    }

    return (Resolve-Path -LiteralPath $worktreeRoot.Trim()).Path
}

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Assert-GitCliAvailable | Out-Null
    $value = & git -C $RepositoryRoot @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed for restore gate evaluation."
    }

    if ($null -eq $value) {
        return ""
    }

    return ([string]$value).Trim()
}

function New-BlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    return [pscustomobject]@{
        code    = $Code
        summary = $Summary
    }
}

function Add-UniqueBlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons,
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    $existing = @($Reasons | Where-Object { $_.code -eq $Code -and $_.summary -eq $Summary })
    if ($existing.Count -eq 0) {
        [void]$Reasons.Add((New-BlockReason -Code $Code -Summary $Summary))
    }
}

function Validate-AuthorityFields {
    param(
        [Parameter(Mandatory = $true)]
        $Authority,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.request_authority_required_fields) {
        Get-RequiredProperty -Object $Authority -Name $fieldName -Context "RestoreGateRequest.authority" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Authority -Name "status" -Context "RestoreGateRequest.authority") -Context "RestoreGateRequest.authority.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_authority_statuses) -Context "RestoreGateRequest.authority.status"

    Assert-OperatorIdentity -Value (Get-RequiredProperty -Object $Authority -Name "operator_id" -Context "RestoreGateRequest.authority") -Context "RestoreGateRequest.authority.operator_id" -Foundation $Foundation | Out-Null
    $approvedBy = Get-RequiredProperty -Object $Authority -Name "approved_by" -Context "RestoreGateRequest.authority"
    $approvedAt = Get-RequiredProperty -Object $Authority -Name "approved_at" -Context "RestoreGateRequest.authority"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Authority -Name "reason" -Context "RestoreGateRequest.authority") -Context "RestoreGateRequest.authority.reason" | Out-Null

    if ($status -eq "pending") {
        if ($null -ne $approvedBy -or $null -ne $approvedAt) {
            throw "RestoreGateRequest.authority.approved_by and RestoreGateRequest.authority.approved_at must be null while authority is pending."
        }
    }
    else {
        Assert-OperatorIdentity -Value $approvedBy -Context "RestoreGateRequest.authority.approved_by" -Foundation $Foundation | Out-Null
        $approvedAtValue = Assert-NonEmptyString -Value $approvedAt -Context "RestoreGateRequest.authority.approved_at"
        Assert-RegexMatch -Value $approvedAtValue -Pattern $Foundation.timestamp_pattern -Context "RestoreGateRequest.authority.approved_at"
    }
}

function Validate-RestoreTargetRequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $RestoreTarget,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.request_restore_target_required_fields) {
        Get-RequiredProperty -Object $RestoreTarget -Name $fieldName -Context "RestoreGateRequest.restore_target" | Out-Null
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "baseline_id" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $Foundation.identifier_pattern -Context "RestoreGateRequest.restore_target.baseline_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "baseline_ref" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.baseline_ref" | Out-Null

    $milestoneObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "milestone_object_id" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.milestone_object_id"
    Assert-RegexMatch -Value $milestoneObjectId -Pattern $Foundation.identifier_pattern -Context "RestoreGateRequest.restore_target.milestone_object_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "branch" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.branch" | Out-Null

    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "head_commit" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_hash_pattern -Context "RestoreGateRequest.restore_target.head_commit"

    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "tree_id" -Context "RestoreGateRequest.restore_target") -Context "RestoreGateRequest.restore_target.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_hash_pattern -Context "RestoreGateRequest.restore_target.tree_id"
}

function Validate-RestoreGateRequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $RestoreGateRequest
    )

    $foundation = Get-RestoreGateFoundationContract
    $requestContract = Get-RestoreGateRequestContract

    foreach ($fieldName in $foundation.request_required_fields) {
        Get-RequiredProperty -Object $RestoreGateRequest -Name $fieldName -Context "RestoreGateRequest" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "contract_version" -Context "RestoreGateRequest") -Context "RestoreGateRequest.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "RestoreGateRequest.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "record_type" -Context "RestoreGateRequest") -Context "RestoreGateRequest.record_type"
    if ($recordType -ne $foundation.request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "RestoreGateRequest.record_type must equal '$($foundation.request_record_type)'."
    }

    $gateRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "gate_request_id" -Context "RestoreGateRequest") -Context "RestoreGateRequest.gate_request_id"
    Assert-RegexMatch -Value $gateRequestId -Pattern $foundation.identifier_pattern -Context "RestoreGateRequest.gate_request_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "target_repository_root" -Context "RestoreGateRequest") -Context "RestoreGateRequest.target_repository_root" | Out-Null

    $restoreTarget = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "restore_target" -Context "RestoreGateRequest") -Context "RestoreGateRequest.restore_target"
    Validate-RestoreTargetRequestFields -RestoreTarget $restoreTarget -Foundation $foundation

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "requested_at" -Context "RestoreGateRequest") -Context "RestoreGateRequest.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "RestoreGateRequest.requested_at"

    Assert-OperatorIdentity -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "requested_by" -Context "RestoreGateRequest") -Context "RestoreGateRequest.requested_by" -Foundation $foundation | Out-Null

    $authority = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "authority" -Context "RestoreGateRequest") -Context "RestoreGateRequest.authority"
    Validate-AuthorityFields -Authority $authority -Foundation $foundation

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateRequest -Name "notes" -Context "RestoreGateRequest") -Context "RestoreGateRequest.notes" | Out-Null

    return [pscustomobject]@{
        IsValid       = $true
        GateRequestId = $gateRequestId
    }
}

function Validate-ResultRestoreTargetFields {
    param(
        [Parameter(Mandatory = $true)]
        $RestoreTarget,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.result_restore_target_required_fields) {
        Get-RequiredProperty -Object $RestoreTarget -Name $fieldName -Context "RestoreGateResult.restore_target" | Out-Null
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "baseline_id" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $Foundation.identifier_pattern -Context "RestoreGateResult.restore_target.baseline_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "baseline_ref" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.baseline_ref" | Out-Null

    $milestoneObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "milestone_object_id" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.milestone_object_id"
    Assert-RegexMatch -Value $milestoneObjectId -Pattern $Foundation.identifier_pattern -Context "RestoreGateResult.restore_target.milestone_object_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "branch" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.branch" | Out-Null

    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "head_commit" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_hash_pattern -Context "RestoreGateResult.restore_target.head_commit"

    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "tree_id" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_hash_pattern -Context "RestoreGateResult.restore_target.tree_id"

    Assert-NullableString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "baseline_kind" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.baseline_kind" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "repository_root" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.repository_root" | Out-Null
    $capturedAt = Assert-NullableString -Value (Get-RequiredProperty -Object $RestoreTarget -Name "captured_at" -Context "RestoreGateResult.restore_target") -Context "RestoreGateResult.restore_target.captured_at"
    if ($null -ne $capturedAt) {
        Assert-RegexMatch -Value $capturedAt -Pattern $Foundation.timestamp_pattern -Context "RestoreGateResult.restore_target.captured_at"
    }
}

function Validate-CurrentRepositoryStateFields {
    param(
        [Parameter(Mandatory = $true)]
        $CurrentRepositoryState,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.current_repository_state_required_fields) {
        Get-RequiredProperty -Object $CurrentRepositoryState -Name $fieldName -Context "RestoreGateResult.current_repository_state" | Out-Null
    }

    Assert-NullableString -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "repository_root" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.repository_root" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "branch" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.branch" | Out-Null
    $headCommit = Assert-NullableString -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "head_commit" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.head_commit"
    if ($null -ne $headCommit) {
        Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_hash_pattern -Context "RestoreGateResult.current_repository_state.head_commit"
    }
    Assert-StringArray -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "status_lines" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.status_lines" -AllowEmpty | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "working_tree_clean" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.working_tree_clean" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $CurrentRepositoryState -Name "attached_head" -Context "RestoreGateResult.current_repository_state") -Context "RestoreGateResult.current_repository_state.attached_head" | Out-Null
}

function Validate-RestoreGateResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $RestoreGateResult
    )

    $foundation = Get-RestoreGateFoundationContract
    $resultContract = Get-RestoreGateResultContract

    foreach ($fieldName in $foundation.result_required_fields) {
        Get-RequiredProperty -Object $RestoreGateResult -Name $fieldName -Context "RestoreGateResult" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "contract_version" -Context "RestoreGateResult") -Context "RestoreGateResult.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "RestoreGateResult.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "record_type" -Context "RestoreGateResult") -Context "RestoreGateResult.record_type"
    if ($recordType -ne $foundation.result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "RestoreGateResult.record_type must equal '$($foundation.result_record_type)'."
    }

    $gateResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "gate_result_id" -Context "RestoreGateResult") -Context "RestoreGateResult.gate_result_id"
    Assert-RegexMatch -Value $gateResultId -Pattern $foundation.identifier_pattern -Context "RestoreGateResult.gate_result_id"

    $gateRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "gate_request_id" -Context "RestoreGateResult") -Context "RestoreGateResult.gate_request_id"
    Assert-RegexMatch -Value $gateRequestId -Pattern $foundation.identifier_pattern -Context "RestoreGateResult.gate_request_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "target_repository_root" -Context "RestoreGateResult") -Context "RestoreGateResult.target_repository_root" | Out-Null

    $decidedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "decided_at" -Context "RestoreGateResult") -Context "RestoreGateResult.decided_at"
    Assert-RegexMatch -Value $decidedAt -Pattern $foundation.timestamp_pattern -Context "RestoreGateResult.decided_at"

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "decision" -Context "RestoreGateResult") -Context "RestoreGateResult.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "RestoreGateResult.decision"

    $restoreTarget = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "restore_target" -Context "RestoreGateResult") -Context "RestoreGateResult.restore_target"
    Validate-ResultRestoreTargetFields -RestoreTarget $restoreTarget -Foundation $foundation

    $preconditions = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "preconditions" -Context "RestoreGateResult") -Context "RestoreGateResult.preconditions"
    foreach ($fieldName in $foundation.result_precondition_required_fields) {
        $fieldValue = Get-RequiredProperty -Object $preconditions -Name $fieldName -Context "RestoreGateResult.preconditions"
        if ($fieldValue -isnot [bool]) {
            throw "RestoreGateResult.preconditions.$fieldName must be a boolean."
        }
    }

    $currentRepositoryState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "current_repository_state" -Context "RestoreGateResult") -Context "RestoreGateResult.current_repository_state"
    Validate-CurrentRepositoryStateFields -CurrentRepositoryState $currentRepositoryState -Foundation $foundation

    $blockReasons = Assert-ObjectArray -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "block_reasons" -Context "RestoreGateResult") -Context "RestoreGateResult.block_reasons" -AllowEmpty
    foreach ($reason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $reason -Name $fieldName -Context "RestoreGateResult.block_reasons item" | Out-Null
        }

        $code = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "code" -Context "RestoreGateResult.block_reasons item") -Context "RestoreGateResult.block_reasons item.code"
        Assert-AllowedValue -Value $code -AllowedValues @($foundation.allowed_reason_codes) -Context "RestoreGateResult.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "summary" -Context "RestoreGateResult.block_reasons item") -Context "RestoreGateResult.block_reasons item.summary" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RestoreGateResult -Name "notes" -Context "RestoreGateResult") -Context "RestoreGateResult.notes" | Out-Null

    $allPreconditionsSatisfied = ($RestoreGateResult.preconditions.authority -and $RestoreGateResult.preconditions.restore_target -and $RestoreGateResult.preconditions.repository_binding -and $RestoreGateResult.preconditions.workspace_safety)
    if ($decision -eq "allow") {
        if ($resultContract.decision_rules.allow_requires_no_block_reasons -and $blockReasons.Count -ne 0) {
            throw "RestoreGateResult with decision 'allow' must not contain block reasons."
        }
        if ($resultContract.precondition_rules.all_true_required_for_allow -and -not $allPreconditionsSatisfied) {
            throw "RestoreGateResult with decision 'allow' must satisfy all preconditions."
        }
    }
    else {
        if ($resultContract.decision_rules.blocked_requires_block_reasons -and $blockReasons.Count -eq 0) {
            throw "RestoreGateResult with decision 'blocked' must contain at least one block reason."
        }
        if ($resultContract.precondition_rules.blocked_when_any_precondition_false -and $allPreconditionsSatisfied) {
            throw "RestoreGateResult with decision 'blocked' must fail at least one precondition."
        }
    }

    return [pscustomobject]@{
        IsValid      = $true
        GateResultId = $gateResultId
        Decision     = $decision
    }
}

function Get-ValidatedRestoreTarget {
    param(
        [Parameter(Mandatory = $true)]
        $RestoreTargetRequest,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $resultTarget = [pscustomobject]@{
        baseline_id        = $RestoreTargetRequest.baseline_id
        baseline_ref       = $RestoreTargetRequest.baseline_ref
        milestone_object_id = $RestoreTargetRequest.milestone_object_id
        branch             = $RestoreTargetRequest.branch
        head_commit        = $RestoreTargetRequest.head_commit
        tree_id            = $RestoreTargetRequest.tree_id
        baseline_kind      = $null
        repository_root    = $null
        captured_at        = $null
    }

    try {
        $baselinePath = Resolve-ExistingPath -PathValue $RestoreTargetRequest.baseline_ref -Label "Restore target baseline"
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "restore_target_missing" -Summary $_.Exception.Message
        return [pscustomobject]@{
            IsValid      = $false
            BaselinePath = $null
            Baseline     = $null
            ResultTarget = $resultTarget
        }
    }

    try {
        $validation = & $script:testMilestoneBaselineRecordContract -BaselinePath $baselinePath
        $baseline = Get-JsonDocument -Path $validation.BaselinePath -Label "Restore target baseline"
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "restore_target_invalid" -Summary "Restore target baseline '$baselinePath' failed milestone baseline validation. $($_.Exception.Message)"
        return [pscustomobject]@{
            IsValid      = $false
            BaselinePath = $baselinePath
            Baseline     = $null
            ResultTarget = $resultTarget
        }
    }

    $resultTarget.baseline_id = $baseline.baseline_id
    $resultTarget.baseline_ref = $validation.BaselinePath
    $resultTarget.milestone_object_id = $baseline.milestone.object_id
    $resultTarget.branch = $baseline.git.branch
    $resultTarget.head_commit = $baseline.git.head_commit
    $resultTarget.tree_id = $baseline.git.tree_id
    $resultTarget.baseline_kind = $baseline.baseline_kind
    $resultTarget.repository_root = $baseline.git.repository_root
    $resultTarget.captured_at = $baseline.captured_at

    $identityValid = $true
    foreach ($comparison in @(
            @{ Name = "baseline_id"; Expected = $RestoreTargetRequest.baseline_id; Actual = $baseline.baseline_id },
            @{ Name = "milestone_object_id"; Expected = $RestoreTargetRequest.milestone_object_id; Actual = $baseline.milestone.object_id },
            @{ Name = "branch"; Expected = $RestoreTargetRequest.branch; Actual = $baseline.git.branch },
            @{ Name = "head_commit"; Expected = $RestoreTargetRequest.head_commit; Actual = $baseline.git.head_commit },
            @{ Name = "tree_id"; Expected = $RestoreTargetRequest.tree_id; Actual = $baseline.git.tree_id }
        )) {
        if ($comparison.Expected -ne $comparison.Actual) {
            Add-UniqueBlockReason -Reasons $Reasons -Code "restore_target_identity_mismatch" -Summary ("Restore target {0} '{1}' did not match the milestone baseline value '{2}'." -f $comparison.Name, $comparison.Expected, $comparison.Actual)
            $identityValid = $false
        }
    }

    return [pscustomobject]@{
        IsValid      = $identityValid
        BaselinePath = $validation.BaselinePath
        Baseline     = $baseline
        ResultTarget = $resultTarget
    }
}

function Get-CurrentRepositoryState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetRepositoryRoot,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $state = [pscustomobject]@{
        repository_root   = $null
        branch            = $null
        head_commit       = $null
        status_lines      = @()
        working_tree_clean = $false
        attached_head     = $false
    }

    $resolvedTargetRepositoryRoot = $null
    $worktreeRoot = $null

    try {
        $resolvedTargetRepositoryRoot = Resolve-ExistingPath -PathValue $TargetRepositoryRoot -Label "Target repository root"
        $worktreeRoot = Get-GitWorktreeRoot -RepositoryPath $resolvedTargetRepositoryRoot
        $state.repository_root = $worktreeRoot
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "repository_binding_mismatch" -Summary $_.Exception.Message
        return [pscustomobject]@{
            IsValid     = $false
            State       = $state
            WorktreeRoot = $null
        }
    }

    try {
        $state.head_commit = Get-GitTrimmedValue -RepositoryRoot $worktreeRoot -Arguments @("rev-parse", "HEAD")
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "repository_binding_mismatch" -Summary "Unable to resolve current Git HEAD commit for target repository '$worktreeRoot'."
        return [pscustomobject]@{
            IsValid     = $false
            State       = $state
            WorktreeRoot = $worktreeRoot
        }
    }

    try {
        $branch = Get-GitTrimmedValue -RepositoryRoot $worktreeRoot -Arguments @("branch", "--show-current")
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $state.attached_head = $false
            Add-UniqueBlockReason -Reasons $Reasons -Code "detached_head" -Summary "Target repository must remain on an attached branch for restore-gate allow decisions."
        }
        else {
            $state.branch = $branch
            $state.attached_head = $true
        }
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "detached_head" -Summary "Unable to resolve the current Git branch for target repository '$worktreeRoot'."
    }

    try {
        $statusOutput = & git -C $worktreeRoot status --short --untracked-files=all 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to resolve Git status."
        }

        $state.status_lines = @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $state.working_tree_clean = ($state.status_lines.Count -eq 0)
        if (-not $state.working_tree_clean) {
            Add-UniqueBlockReason -Reasons $Reasons -Code "workspace_dirty" -Summary "Target repository must have a clean Git worktree before restore-gate allow decisions."
        }
    }
    catch {
        Add-UniqueBlockReason -Reasons $Reasons -Code "workspace_dirty" -Summary "Unable to resolve Git status for target repository '$worktreeRoot'."
    }

    return [pscustomobject]@{
        IsValid      = $true
        State        = $state
        WorktreeRoot = $worktreeRoot
    }
}

function Evaluate-AuthorityPreconditions {
    param(
        [Parameter(Mandatory = $true)]
        $Authority,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    if ($Authority.status -eq "approved") {
        return $true
    }

    if ($Authority.status -eq "rejected") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "authority_rejected" -Summary "Restore authority is explicitly rejected."
        return $false
    }

    Add-UniqueBlockReason -Reasons $Reasons -Code "authority_missing" -Summary "Restore authority is not explicitly approved."
    return $false
}

function Test-RestoreGateRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $GateRequestPath -Label "Restore gate request path"
    $request = Get-JsonDocument -Path $resolvedPath -Label "Restore gate request"
    $result = Validate-RestoreGateRequestFields -RestoreGateRequest $request

    return [pscustomobject]@{
        IsValid         = $result.IsValid
        GateRequestId   = $result.GateRequestId
        GateRequestPath = $resolvedPath
    }
}

function Test-RestoreGateResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $GateResultPath -Label "Restore gate result path"
    $resultDocument = Get-JsonDocument -Path $resolvedPath -Label "Restore gate result"
    $result = Validate-RestoreGateResultFields -RestoreGateResult $resultDocument

    return [pscustomobject]@{
        IsValid        = $result.IsValid
        GateResultId   = $result.GateResultId
        Decision       = $result.Decision
        GateResultPath = $resolvedPath
    }
}

function Invoke-RestoreGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateRequestPath
    )

    Assert-GitCliAvailable | Out-Null

    $requestCheck = Test-RestoreGateRequestContract -GateRequestPath $GateRequestPath
    $request = Get-JsonDocument -Path $requestCheck.GateRequestPath -Label "Restore gate request"
    $reasons = [System.Collections.ArrayList]::new()

    $authoritySatisfied = Evaluate-AuthorityPreconditions -Authority $request.authority -Reasons $reasons
    $restoreTargetValidation = Get-ValidatedRestoreTarget -RestoreTargetRequest $request.restore_target -Reasons $reasons
    $currentRepositoryEvaluation = Get-CurrentRepositoryState -TargetRepositoryRoot $request.target_repository_root -Reasons $reasons

    $repositoryBindingSatisfied = $false
    if ($restoreTargetValidation.IsValid -and $currentRepositoryEvaluation.IsValid) {
        if ($request.target_repository_root -and $restoreTargetValidation.ResultTarget.repository_root -and $currentRepositoryEvaluation.WorktreeRoot -eq $restoreTargetValidation.ResultTarget.repository_root) {
            $repositoryBindingSatisfied = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "repository_binding_mismatch" -Summary "Restore target baseline repository_root must match the requested target repository worktree root exactly."
        }
    }

    $workspaceSafetySatisfied = ($currentRepositoryEvaluation.IsValid -and $currentRepositoryEvaluation.State.attached_head -and $currentRepositoryEvaluation.State.working_tree_clean)
    $decision = if ($authoritySatisfied -and $restoreTargetValidation.IsValid -and $repositoryBindingSatisfied -and $workspaceSafetySatisfied) { "allow" } else { "blocked" }
    $timestamp = Get-Date
    $timestampText = $timestamp.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $result = [pscustomobject]@{
        contract_version     = (Get-RestoreGateFoundationContract).contract_version
        record_type          = (Get-RestoreGateFoundationContract).result_record_type
        gate_result_id       = "{0}.result" -f $request.gate_request_id
        gate_request_id      = $request.gate_request_id
        target_repository_root = if ($currentRepositoryEvaluation.State.repository_root) { $currentRepositoryEvaluation.State.repository_root } else { $request.target_repository_root }
        decided_at           = $timestampText
        decision             = $decision
        restore_target       = $restoreTargetValidation.ResultTarget
        preconditions        = [pscustomobject]@{
            authority          = $authoritySatisfied
            restore_target     = $restoreTargetValidation.IsValid
            repository_binding = $repositoryBindingSatisfied
            workspace_safety   = $workspaceSafetySatisfied
        }
        current_repository_state = $currentRepositoryEvaluation.State
        block_reasons        = @($reasons)
        notes                = if ($decision -eq "allow") { "Restore target and rollback-gate authority are validated. This remains gate foundation only and does not execute rollback." } else { "Restore gate blocked fail-closed. No rollback execution is performed by this foundation slice." }
    }

    Validate-RestoreGateResultFields -RestoreGateResult $result | Out-Null
    return $result
}

function Save-RestoreGateResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $GateResult,
        [string]$StorePath
    )

    Validate-RestoreGateResultFields -RestoreGateResult $GateResult | Out-Null

    $resultStorePath = Get-RestoreGateResultStorePath -StorePath $StorePath
    if (-not (Test-Path -LiteralPath $resultStorePath)) {
        New-Item -ItemType Directory -Path $resultStorePath -Force | Out-Null
    }

    $resultPath = Join-Path $resultStorePath ("{0}.json" -f $GateResult.gate_result_id)
    $GateResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $resultPath -Encoding UTF8
    Test-RestoreGateResultContract -GateResultPath $resultPath | Out-Null

    return $resultPath
}

function Get-RestoreGateResult {
    [CmdletBinding(DefaultParameterSetName = "ByGateResultId")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ByGateResultId")]
        [string]$GateResultId,
        [Parameter(ParameterSetName = "ByGateResultId")]
        [string]$StorePath,
        [Parameter(Mandatory = $true, ParameterSetName = "ByPath")]
        [string]$Path
    )

    if ($PSCmdlet.ParameterSetName -eq "ByPath") {
        $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Restore gate result path"
    }
    else {
        $resolvedPath = Resolve-ExistingPath -PathValue (Join-Path (Get-RestoreGateResultStorePath -StorePath $StorePath) ("{0}.json" -f $GateResultId)) -Label "Restore gate result path"
    }

    $resultDocument = Get-JsonDocument -Path $resolvedPath -Label "Restore gate result"
    Validate-RestoreGateResultFields -RestoreGateResult $resultDocument | Out-Null
    return $resultDocument
}

Export-ModuleMember -Function Test-RestoreGateRequestContract, Test-RestoreGateResultContract, Invoke-RestoreGate, Save-RestoreGateResult, Get-RestoreGateResult
