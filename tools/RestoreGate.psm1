Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneBaselineModule = Import-Module (Join-Path $PSScriptRoot "MilestoneBaseline.psm1") -Force -PassThru

$testMilestoneBaselineRecordContract = $milestoneBaselineModule.ExportedCommands["Test-MilestoneBaselineRecordContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return Join-Path (Get-Location) $PathValue
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue
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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
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

function Get-RestoreGateFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\foundation.contract.json") -Label "Restore gate foundation contract"
}

function Get-RestoreGateRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\request.contract.json") -Label "Restore gate request contract"
}

function Get-RestoreGateResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\restore_gate\result.contract.json") -Label "Restore gate result contract"
}

function Get-ResultStorePath {
    param(
        [string]$StorePath
    )

    $basePath = if ([string]::IsNullOrWhiteSpace($StorePath)) { Join-Path (Get-RepositoryRoot) "state\restore_gate" } else { Resolve-PathValue -PathValue $StorePath }
    return (Join-Path $basePath "results")
}

function Get-GitValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $value = (& git -C $RepositoryRoot @Arguments 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve $Label for the restore gate."
    }

    return $value
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $branch = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Label "Git branch").Trim()
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Restore gate requires a non-empty current Git branch."
    }

    return $branch
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $head = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Label "Git HEAD commit").Trim()
    if ([string]::IsNullOrWhiteSpace($head)) {
        throw "Restore gate requires a non-empty current Git HEAD commit."
    }

    return $head
}

function Get-GitStatusLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $statusOutput = & git -C $RepositoryRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for the restore gate."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-GitCommitExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Commit
    )

    & git -C $RepositoryRoot cat-file -e "$Commit^{commit}" 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Validate-Approval {
    param(
        [Parameter(Mandatory = $true)]
        $Approval,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.approval_required_fields) {
        Get-RequiredProperty -Object $Approval -Name $fieldName -Context "Restore gate approval" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "status" -Context "Restore gate approval") -Context "Restore gate approval.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_approval_statuses) -Context "Restore gate approval.status"
    $by = Get-RequiredProperty -Object $Approval -Name "by" -Context "Restore gate approval"
    $at = Get-RequiredProperty -Object $Approval -Name "at" -Context "Restore gate approval"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "notes" -Context "Restore gate approval") -Context "Restore gate approval.notes" | Out-Null

    if ($status -eq "pending") {
        if ($null -ne $by -or $null -ne $at) {
            throw "Restore gate approval.by and .at must be null when approval status is pending."
        }
    }
    else {
        $approvalBy = Assert-NonEmptyString -Value $by -Context "Restore gate approval.by"
        Assert-RegexMatch -Value $approvalBy -Pattern $Foundation.operator_pattern -Context "Restore gate approval.by"
        $approvalAt = Assert-NonEmptyString -Value $at -Context "Restore gate approval.at"
        Assert-RegexMatch -Value $approvalAt -Pattern $Foundation.timestamp_pattern -Context "Restore gate approval.at"
    }
}

function Validate-RequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $Request
    )

    $foundation = Get-RestoreGateFoundationContract
    $requestContract = Get-RestoreGateRequestContract

    foreach ($fieldName in $foundation.request_required_fields) {
        Get-RequiredProperty -Object $Request -Name $fieldName -Context "Restore gate request" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "contract_version" -Context "Restore gate request") -Context "Restore gate request.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Restore gate request.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "record_type" -Context "Restore gate request") -Context "Restore gate request.record_type"
    if ($recordType -ne $foundation.request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "Restore gate request.record_type must equal '$($foundation.request_record_type)'."
    }

    $requestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "restore_request_id" -Context "Restore gate request") -Context "Restore gate request.restore_request_id"
    Assert-RegexMatch -Value $requestId -Pattern $foundation.identifier_pattern -Context "Restore gate request.restore_request_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "baseline_ref" -Context "Restore gate request") -Context "Restore gate request.baseline_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "target_branch" -Context "Restore gate request") -Context "Restore gate request.target_branch" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "target_commit" -Context "Restore gate request") -Context "Restore gate request.target_commit" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "target_tree_id" -Context "Restore gate request") -Context "Restore gate request.target_tree_id" | Out-Null

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "requested_at" -Context "Restore gate request") -Context "Restore gate request.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "Restore gate request.requested_at"

    $requestedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "requested_by" -Context "Restore gate request") -Context "Restore gate request.requested_by"
    Assert-RegexMatch -Value $requestedBy -Pattern $foundation.operator_pattern -Context "Restore gate request.requested_by"

    $approval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Request -Name "approval" -Context "Restore gate request") -Context "Restore gate request.approval"
    Validate-Approval -Approval $approval -Foundation $foundation
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "notes" -Context "Restore gate request") -Context "Restore gate request.notes" | Out-Null

    return [pscustomobject]@{
        RestoreRequestId = $requestId
    }
}

function Test-RestoreGateRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RestoreRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $RestoreRequestPath -Label "Restore gate request"
    $request = Get-JsonDocument -Path $resolvedPath -Label "Restore gate request"
    $result = Validate-RequestFields -Request $request

    return [pscustomobject]@{
        IsValid            = $true
        RestoreRequestId   = $result.RestoreRequestId
        RestoreRequestPath = $resolvedPath
    }
}

function Validate-ResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $Result
    )

    $foundation = Get-RestoreGateFoundationContract
    $resultContract = Get-RestoreGateResultContract

    foreach ($fieldName in $foundation.result_required_fields) {
        Get-RequiredProperty -Object $Result -Name $fieldName -Context "Restore gate result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "contract_version" -Context "Restore gate result") -Context "Restore gate result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Restore gate result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "record_type" -Context "Restore gate result") -Context "Restore gate result.record_type"
    if ($recordType -ne $foundation.result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "Restore gate result.record_type must equal '$($foundation.result_record_type)'."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "restore_result_id" -Context "Restore gate result") -Context "Restore gate result.restore_result_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "restore_request_id" -Context "Restore gate result") -Context "Restore gate result.restore_request_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "baseline_ref" -Context "Restore gate result") -Context "Restore gate result.baseline_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "baseline_id" -Context "Restore gate result") -Context "Restore gate result.baseline_id" | Out-Null

    $target = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "target" -Context "Restore gate result") -Context "Restore gate result.target"
    foreach ($fieldName in $foundation.target_required_fields) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $target -Name $fieldName -Context "Restore gate result.target") -Context "Restore gate result.target.$fieldName" | Out-Null
    }

    $requestedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "requested_by" -Context "Restore gate result") -Context "Restore gate result.requested_by"
    Assert-RegexMatch -Value $requestedBy -Pattern $foundation.operator_pattern -Context "Restore gate result.requested_by"
    $decidedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decided_at" -Context "Restore gate result") -Context "Restore gate result.decided_at"
    Assert-RegexMatch -Value $decidedAt -Pattern $foundation.timestamp_pattern -Context "Restore gate result.decided_at"

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decision" -Context "Restore gate result") -Context "Restore gate result.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "Restore gate result.decision"

    $preconditions = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "preconditions" -Context "Restore gate result") -Context "Restore gate result.preconditions"
    foreach ($fieldName in $foundation.precondition_required_fields) {
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $preconditions -Name $fieldName -Context "Restore gate result.preconditions") -Context "Restore gate result.preconditions.$fieldName" | Out-Null
    }

    $currentGitState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "current_git_state" -Context "Restore gate result") -Context "Restore gate result.current_git_state"
    foreach ($fieldName in $foundation.current_git_state_required_fields) {
        Get-RequiredProperty -Object $currentGitState -Name $fieldName -Context "Restore gate result.current_git_state" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "repository_root" -Context "Restore gate result.current_git_state") -Context "Restore gate result.current_git_state.repository_root" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "branch" -Context "Restore gate result.current_git_state") -Context "Restore gate result.current_git_state.branch" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "head_commit" -Context "Restore gate result.current_git_state") -Context "Restore gate result.current_git_state.head_commit" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $currentGitState -Name "working_tree_clean" -Context "Restore gate result.current_git_state") -Context "Restore gate result.current_git_state.working_tree_clean" | Out-Null
    [void](Assert-StringArray -Value (Get-RequiredProperty -Object $currentGitState -Name "status_lines" -Context "Restore gate result.current_git_state") -Context "Restore gate result.current_git_state.status_lines" -AllowEmpty)

    $blockReasons = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Result -Name "block_reasons" -Context "Restore gate result") -Context "Restore gate result.block_reasons" -AllowEmpty)
    foreach ($blockReason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $blockReason -Name $fieldName -Context "Restore gate result.block_reasons item" | Out-Null
        }

        $reasonCode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "code" -Context "Restore gate result.block_reasons item") -Context "Restore gate result.block_reasons item.code"
        Assert-AllowedValue -Value $reasonCode -AllowedValues @($foundation.allowed_reason_codes) -Context "Restore gate result.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "summary" -Context "Restore gate result.block_reasons item") -Context "Restore gate result.block_reasons item.summary" | Out-Null
    }

    if ($resultContract.decision_rules.allow_requires_no_block_reasons -and $decision -eq "allow" -and $blockReasons.Count -ne 0) {
        throw "Restore gate allow decisions must not include block reasons."
    }
    if ($resultContract.decision_rules.blocked_requires_block_reasons -and $decision -eq "blocked" -and $blockReasons.Count -eq 0) {
        throw "Restore gate blocked decisions must include at least one block reason."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "notes" -Context "Restore gate result") -Context "Restore gate result.notes" | Out-Null
}

function Test-RestoreGateResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RestoreResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $RestoreResultPath -Label "Restore gate result"
    $result = Get-JsonDocument -Path $resolvedPath -Label "Restore gate result"
    Validate-ResultFields -Result $result

    return [pscustomobject]@{
        IsValid           = $true
        RestoreResultPath = $resolvedPath
    }
}

function Invoke-RestoreGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RestoreRequestPath,
        [string]$RepositoryRoot
    )

    $requestCheck = Test-RestoreGateRequestContract -RestoreRequestPath $RestoreRequestPath
    $request = Get-JsonDocument -Path $requestCheck.RestoreRequestPath -Label "Restore gate request"
    $baselinePath = Resolve-ExistingPath -PathValue $request.baseline_ref -Label "Milestone baseline"
    $baselineValidation = & $testMilestoneBaselineRecordContract -BaselinePath $baselinePath
    $baseline = Get-JsonDocument -Path $baselineValidation.BaselinePath -Label "Milestone baseline"

    $resolvedRepositoryRoot = if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) { Resolve-ExistingPath -PathValue $baseline.git.repository_root -Label "Restore gate repository root" } else { Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Restore gate repository root" }

    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    $currentHeadCommit = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
    $statusLines = @(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    $workingTreeClean = ($statusLines.Count -eq 0)

    $reasons = [System.Collections.ArrayList]::new()

    $approvalSatisfied = $true
    if ($request.approval.status -eq "rejected") {
        Add-UniqueBlockReason -Reasons $reasons -Code "approval_rejected" -Summary "Restore gate approval is rejected."
        $approvalSatisfied = $false
    }
    elseif ($request.approval.status -ne "approved") {
        Add-UniqueBlockReason -Reasons $reasons -Code "approval_missing" -Summary "Restore gate approval is not explicitly approved."
        $approvalSatisfied = $false
    }

    $baselineSatisfied = $true
    if ($request.target_branch -ne $baseline.git.branch -or $request.target_commit -ne $baseline.git.head_commit -or $request.target_tree_id -ne $baseline.git.tree_id) {
        Add-UniqueBlockReason -Reasons $reasons -Code "target_mismatch" -Summary "Restore target fields must match the captured milestone baseline Git identity."
        $baselineSatisfied = $false
    }

    $repositoryMatchSatisfied = $true
    if ((Resolve-Path -LiteralPath $resolvedRepositoryRoot).Path -ne (Resolve-Path -LiteralPath $baseline.git.repository_root).Path) {
        Add-UniqueBlockReason -Reasons $reasons -Code "baseline_repository_mismatch" -Summary "Restore gate repository root does not match the captured milestone baseline repository root."
        $repositoryMatchSatisfied = $false
    }

    $branchSatisfied = $true
    if ($currentBranch -ne $request.target_branch) {
        Add-UniqueBlockReason -Reasons $reasons -Code "branch_mismatch" -Summary "Current branch '$currentBranch' does not match requested restore branch '$($request.target_branch)'."
        $branchSatisfied = $false
    }

    $cleanWorktreeSatisfied = $true
    if (-not $workingTreeClean) {
        Add-UniqueBlockReason -Reasons $reasons -Code "worktree_dirty" -Summary "Restore gate requires a clean current worktree before a restore can be authorized."
        $cleanWorktreeSatisfied = $false
    }

    $targetCommitSatisfied = $true
    if (-not (Test-GitCommitExists -RepositoryRoot $resolvedRepositoryRoot -Commit $request.target_commit)) {
        Add-UniqueBlockReason -Reasons $reasons -Code "target_commit_missing" -Summary "Requested restore target commit '$($request.target_commit)' does not exist in the local repository."
        $targetCommitSatisfied = $false
    }

    $restoreRequiredSatisfied = $true
    if ($currentHeadCommit -eq $request.target_commit) {
        Add-UniqueBlockReason -Reasons $reasons -Code "restore_not_required" -Summary "Current Git HEAD already matches the requested restore target commit."
        $restoreRequiredSatisfied = $false
    }

    $decision = if ($reasons.Count -eq 0) { "allow" } else { "blocked" }
    $decidedAt = Get-UtcTimestamp

    $result = [pscustomobject]@{
        contract_version  = (Get-RestoreGateFoundationContract).contract_version
        record_type       = (Get-RestoreGateFoundationContract).result_record_type
        restore_result_id = ("{0}.result" -f $request.restore_request_id)
        restore_request_id = $request.restore_request_id
        baseline_ref      = $baselineValidation.BaselinePath
        baseline_id       = $baseline.baseline_id
        target            = [pscustomobject]@{
            branch  = $request.target_branch
            commit  = $request.target_commit
            tree_id = $request.target_tree_id
        }
        requested_by      = $request.requested_by
        decided_at        = $decidedAt
        decision          = $decision
        preconditions     = [pscustomobject]@{
            approval         = $approvalSatisfied
            baseline         = $baselineSatisfied
            repository_match = $repositoryMatchSatisfied
            branch           = $branchSatisfied
            clean_worktree   = $cleanWorktreeSatisfied
            target_commit    = $targetCommitSatisfied
            restore_required = $restoreRequiredSatisfied
        }
        current_git_state = [pscustomobject]@{
            repository_root   = $resolvedRepositoryRoot
            branch            = $currentBranch
            head_commit       = $currentHeadCommit
            working_tree_clean = $workingTreeClean
            status_lines      = @($statusLines)
        }
        block_reasons      = @($reasons)
        notes              = if ($decision -eq "allow") { "Restore gate authorized the baseline target only. No restore action was executed." } else { "Restore gate blocked fail-closed. No restore action was executed." }
    }

    Validate-ResultFields -Result $result
    return $result
}

function Save-RestoreGateResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RestoreGateResult,
        [string]$StorePath
    )

    Validate-ResultFields -Result $RestoreGateResult

    $resultStorePath = Get-ResultStorePath -StorePath $StorePath
    if (-not (Test-Path -LiteralPath $resultStorePath)) {
        New-Item -ItemType Directory -Path $resultStorePath -Force | Out-Null
    }

    $resultPath = Join-Path $resultStorePath ("{0}.json" -f $RestoreGateResult.restore_result_id)
    $RestoreGateResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $resultPath -Encoding UTF8
    Test-RestoreGateResultContract -RestoreResultPath $resultPath | Out-Null

    return [pscustomobject]@{
        RestoreGateResult = $RestoreGateResult
        RestoreResultPath = $resultPath
    }
}

function Get-RestoreGateResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Restore gate result"
    Test-RestoreGateResultContract -RestoreResultPath $resolvedPath | Out-Null
    return (Get-JsonDocument -Path $resolvedPath -Label "Restore gate result")
}

Export-ModuleMember -Function Test-RestoreGateRequestContract, Test-RestoreGateResultContract, Invoke-RestoreGate, Save-RestoreGateResult, Get-RestoreGateResult
