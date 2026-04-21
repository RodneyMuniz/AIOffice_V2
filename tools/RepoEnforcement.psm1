Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

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

function Get-RepoEnforcementFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\repo_enforcement\foundation.contract.json") -Label "Repo enforcement foundation contract"
}

function Get-RepoEnforcementResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\repo_enforcement\result.contract.json") -Label "Repo enforcement result contract"
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
        throw "Unable to resolve $Label for repo enforcement."
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
        throw "Repo enforcement requires a non-empty Git branch."
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
        throw "Repo enforcement requires a non-empty Git HEAD commit."
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
        throw "Unable to resolve Git status for repo enforcement."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Validate-ResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $Result
    )

    $foundation = Get-RepoEnforcementFoundationContract
    $resultContract = Get-RepoEnforcementResultContract

    foreach ($fieldName in $foundation.required_fields) {
        Get-RequiredProperty -Object $Result -Name $fieldName -Context "Repo enforcement result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "contract_version" -Context "Repo enforcement result") -Context "Repo enforcement result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Repo enforcement result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "record_type" -Context "Repo enforcement result") -Context "Repo enforcement result.record_type"
    if ($recordType -ne $foundation.record_type -or $recordType -ne $resultContract.record_type) {
        throw "Repo enforcement result.record_type must equal '$($foundation.record_type)'."
    }

    $enforcementResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "enforcement_result_id" -Context "Repo enforcement result") -Context "Repo enforcement result.enforcement_result_id"
    Assert-RegexMatch -Value $enforcementResultId -Pattern $foundation.identifier_pattern -Context "Repo enforcement result.enforcement_result_id"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "milestone_id" -Context "Repo enforcement result") -Context "Repo enforcement result.milestone_id" | Out-Null
    $requestedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "requested_by" -Context "Repo enforcement result") -Context "Repo enforcement result.requested_by"
    Assert-RegexMatch -Value $requestedBy -Pattern $foundation.actor_pattern -Context "Repo enforcement result.requested_by"
    $reviewedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "reviewed_at" -Context "Repo enforcement result") -Context "Repo enforcement result.reviewed_at"
    Assert-RegexMatch -Value $reviewedAt -Pattern $foundation.timestamp_pattern -Context "Repo enforcement result.reviewed_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "repository_root" -Context "Repo enforcement result") -Context "Repo enforcement result.repository_root" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "proof_summary_ref" -Context "Repo enforcement result") -Context "Repo enforcement result.proof_summary_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "replay_summary_ref" -Context "Repo enforcement result") -Context "Repo enforcement result.replay_summary_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "closeout_plan_ref" -Context "Repo enforcement result") -Context "Repo enforcement result.closeout_plan_ref" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "expected_test_ids" -Context "Repo enforcement result") -Context "Repo enforcement result.expected_test_ids" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $Result -Name "worktree_clean_required" -Context "Repo enforcement result") -Context "Repo enforcement result.worktree_clean_required" | Out-Null

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decision" -Context "Repo enforcement result") -Context "Repo enforcement result.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "Repo enforcement result.decision"

    $currentGitState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "current_git_state" -Context "Repo enforcement result") -Context "Repo enforcement result.current_git_state"
    foreach ($fieldName in $foundation.current_git_state_required_fields) {
        Get-RequiredProperty -Object $currentGitState -Name $fieldName -Context "Repo enforcement result.current_git_state" | Out-Null
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "branch" -Context "Repo enforcement result.current_git_state") -Context "Repo enforcement result.current_git_state.branch" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "head_commit" -Context "Repo enforcement result.current_git_state") -Context "Repo enforcement result.current_git_state.head_commit" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $currentGitState -Name "working_tree_clean" -Context "Repo enforcement result.current_git_state") -Context "Repo enforcement result.current_git_state.working_tree_clean" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $currentGitState -Name "status_lines" -Context "Repo enforcement result.current_git_state") -Context "Repo enforcement result.current_git_state.status_lines" -AllowEmpty | Out-Null

    $blockReasons = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Result -Name "block_reasons" -Context "Repo enforcement result") -Context "Repo enforcement result.block_reasons" -AllowEmpty)
    foreach ($blockReason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $blockReason -Name $fieldName -Context "Repo enforcement result.block_reasons item" | Out-Null
        }

        $reasonCode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "code" -Context "Repo enforcement result.block_reasons item") -Context "Repo enforcement result.block_reasons item.code"
        Assert-AllowedValue -Value $reasonCode -AllowedValues @($foundation.allowed_reason_codes) -Context "Repo enforcement result.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "summary" -Context "Repo enforcement result.block_reasons item") -Context "Repo enforcement result.block_reasons item.summary" | Out-Null
    }

    if ($resultContract.decision_rules.allow_requires_no_block_reasons -and $decision -eq "allow" -and $blockReasons.Count -ne 0) {
        throw "Repo enforcement allow decisions must not include block reasons."
    }
    if ($resultContract.decision_rules.blocked_requires_block_reasons -and $decision -eq "blocked" -and $blockReasons.Count -eq 0) {
        throw "Repo enforcement blocked decisions must include at least one block reason."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "notes" -Context "Repo enforcement result") -Context "Repo enforcement result.notes" | Out-Null
}

function Test-RepoEnforcementResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ResultPath -Label "Repo enforcement result"
    $result = Get-JsonDocument -Path $resolvedPath -Label "Repo enforcement result"
    Validate-ResultFields -Result $result

    return [pscustomobject]@{
        IsValid    = $true
        ResultPath = $resolvedPath
    }
}

function Save-RepoEnforcementResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RepoEnforcementResult,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    Validate-ResultFields -Result $RepoEnforcementResult

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $resultDirectory = Join-Path $resolvedOutputRoot "repo_enforcement"
    if (-not (Test-Path -LiteralPath $resultDirectory)) {
        New-Item -ItemType Directory -Path $resultDirectory -Force | Out-Null
    }

    $resultPath = Join-Path $resultDirectory ("{0}.json" -f $RepoEnforcementResult.enforcement_result_id)
    $RepoEnforcementResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $resultPath -Encoding UTF8
    Test-RepoEnforcementResultContract -ResultPath $resultPath | Out-Null

    return $resultPath
}

function Get-RepoEnforcementResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Repo enforcement result"
    Test-RepoEnforcementResultContract -ResultPath $resolvedPath | Out-Null
    return (Get-JsonDocument -Path $resolvedPath -Label "Repo enforcement result")
}

function Invoke-RepoEnforcementCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MilestoneId,
        [Parameter(Mandatory = $true)]
        [string]$ProofSummaryPath,
        [Parameter(Mandatory = $true)]
        [string]$ReplaySummaryPath,
        [Parameter(Mandatory = $true)]
        [string]$CloseoutPlanPath,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedTestIds,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [string]$RequestedBy = "control-kernel:repo-enforcement",
        [switch]$WorktreeCleanRequired
    )

    $foundation = Get-RepoEnforcementFoundationContract
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repo enforcement repository root"
    $proofSummaryCandidate = Resolve-PathValue -PathValue $ProofSummaryPath
    $replaySummaryCandidate = Resolve-PathValue -PathValue $ReplaySummaryPath
    $closeoutPlanCandidate = Resolve-PathValue -PathValue $CloseoutPlanPath
    $requestedByValue = Assert-NonEmptyString -Value $RequestedBy -Context "RequestedBy"
    Assert-RegexMatch -Value $requestedByValue -Pattern $foundation.actor_pattern -Context "RequestedBy"

    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    $currentHeadCommit = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
    $statusLines = @(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    $workingTreeClean = ($statusLines.Count -eq 0)
    $reasons = [System.Collections.ArrayList]::new()

    if ($WorktreeCleanRequired.IsPresent -and -not $workingTreeClean) {
        Add-UniqueBlockReason -Reasons $reasons -Code "worktree_dirty" -Summary "Repo enforcement requires a clean Git worktree."
    }

    $summary = $null
    if (-not (Test-Path -LiteralPath $proofSummaryCandidate)) {
        Add-UniqueBlockReason -Reasons $reasons -Code "proof_summary_missing" -Summary "Bounded proof summary is missing."
    }
    else {
        $summary = Get-JsonDocument -Path $proofSummaryCandidate -Label "Bounded proof summary"
        if ([int]$summary.failed_count -ne 0) {
            Add-UniqueBlockReason -Reasons $reasons -Code "proof_failures_present" -Summary "Bounded proof summary records one or more failed tests."
        }

        $summaryResultIds = @($summary.results | ForEach-Object { $_.id })
        foreach ($expectedTestId in @($ExpectedTestIds)) {
            if ($summaryResultIds -notcontains $expectedTestId) {
                Add-UniqueBlockReason -Reasons $reasons -Code "proof_test_missing" -Summary "Bounded proof summary does not include expected test id '$expectedTestId'."
            }
        }
    }

    if (-not (Test-Path -LiteralPath $replaySummaryCandidate)) {
        Add-UniqueBlockReason -Reasons $reasons -Code "replay_summary_missing" -Summary "Replay summary is missing."
    }

    if (-not (Test-Path -LiteralPath $closeoutPlanCandidate)) {
        Add-UniqueBlockReason -Reasons $reasons -Code "closeout_plan_missing" -Summary "R5 proof and closeout plan is missing."
    }

    $result = [pscustomobject]@{
        contract_version       = $foundation.contract_version
        record_type            = $foundation.record_type
        enforcement_result_id  = ("repo-enforcement-{0}" -f $MilestoneId)
        milestone_id           = $MilestoneId
        requested_by           = $requestedByValue
        reviewed_at            = Get-UtcTimestamp
        repository_root        = $resolvedRepositoryRoot
        proof_summary_ref      = $proofSummaryCandidate
        replay_summary_ref     = $replaySummaryCandidate
        closeout_plan_ref      = $closeoutPlanCandidate
        expected_test_ids      = @($ExpectedTestIds)
        worktree_clean_required = $WorktreeCleanRequired.IsPresent
        decision               = if ($reasons.Count -eq 0) { "allow" } else { "blocked" }
        current_git_state      = [pscustomobject]@{
            branch            = $currentBranch
            head_commit       = $currentHeadCommit
            working_tree_clean = $workingTreeClean
            status_lines      = @($statusLines)
        }
        block_reasons          = @($reasons)
        notes                  = if ($reasons.Count -eq 0) { "Repo enforcement confirmed bounded proof coverage, replay summary presence, and closeout-plan presence only. No milestone closure was executed." } else { "Repo enforcement blocked fail-closed because one or more bounded proof or cleanliness expectations were not met." }
    }

    $resultPath = Save-RepoEnforcementResult -RepoEnforcementResult $result -OutputRoot $OutputRoot

    return [pscustomobject]@{
        RepoEnforcementResult = $result
        ResultPath            = $resultPath
    }
}

Export-ModuleMember -Function Test-RepoEnforcementResultContract, Invoke-RepoEnforcementCheck, Save-RepoEnforcementResult, Get-RepoEnforcementResult
