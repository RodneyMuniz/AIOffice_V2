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

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
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

function Get-RepoRelativePathIfInsideRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedRepoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $fullPath = [System.IO.Path]::GetFullPath($Path)

    if (-not $fullPath.StartsWith($resolvedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    $baseUri = [System.Uri]("{0}{1}" -f $resolvedRepoRoot.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$fullPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Get-GitCommand {
    $command = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Repo enforcement requires Git CLI to be installed and callable."
    }

    return $command
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $branch = (& git -C $RepositoryRoot branch --show-current 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to resolve the current Git branch for repo enforcement."
    }

    return $branch
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $head = (& git -C $RepositoryRoot rev-parse HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) {
        throw "Unable to resolve the current Git HEAD commit for repo enforcement."
    }

    return $head
}

function Get-GitStatusLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $statusOutput = & git -C $RepositoryRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for repo enforcement."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-RepoEnforcementFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\repo_enforcement\foundation.contract.json") -Label "Repo enforcement foundation contract"
}

function Get-RepoEnforcementResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\repo_enforcement\result.contract.json") -Label "Repo enforcement result contract"
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

function Validate-ResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $Result
    )

    $foundation = Get-RepoEnforcementFoundationContract
    $resultContract = Get-RepoEnforcementResultContract

    foreach ($fieldName in $foundation.result_required_fields) {
        Get-RequiredProperty -Object $Result -Name $fieldName -Context "Repo enforcement result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "contract_version" -Context "Repo enforcement result") -Context "Repo enforcement result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Repo enforcement result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "record_type" -Context "Repo enforcement result") -Context "Repo enforcement result.record_type"
    if ($recordType -ne $foundation.result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "Repo enforcement result.record_type must equal '$($foundation.result_record_type)'."
    }

    $enforcementResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "enforcement_result_id" -Context "Repo enforcement result") -Context "Repo enforcement result.enforcement_result_id"
    Assert-RegexMatch -Value $enforcementResultId -Pattern $foundation.identifier_pattern -Context "Repo enforcement result.enforcement_result_id"

    $evaluatedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "evaluated_at" -Context "Repo enforcement result") -Context "Repo enforcement result.evaluated_at"
    Assert-RegexMatch -Value $evaluatedAt -Pattern $foundation.timestamp_pattern -Context "Repo enforcement result.evaluated_at"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "repository_root" -Context "Repo enforcement result") -Context "Repo enforcement result.repository_root" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "repo_branch" -Context "Repo enforcement result") -Context "Repo enforcement result.repo_branch" | Out-Null
    $repoHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "repo_head" -Context "Repo enforcement result") -Context "Repo enforcement result.repo_head"
    Assert-RegexMatch -Value $repoHead -Pattern $foundation.git_hash_pattern -Context "Repo enforcement result.repo_head"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "output_root" -Context "Repo enforcement result") -Context "Repo enforcement result.output_root" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "proof_summary_path" -Context "Repo enforcement result") -Context "Repo enforcement result.proof_summary_path" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "replay_summary_path" -Context "Repo enforcement result") -Context "Repo enforcement result.replay_summary_path" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "replayed_command_path" -Context "Repo enforcement result") -Context "Repo enforcement result.replayed_command_path" | Out-Null

    Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "required_selection_ids" -Context "Repo enforcement result") -Context "Repo enforcement result.required_selection_ids" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "actual_selection_ids" -Context "Repo enforcement result") -Context "Repo enforcement result.actual_selection_ids" | Out-Null

    $checks = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "checks" -Context "Repo enforcement result") -Context "Repo enforcement result.checks"
    foreach ($fieldName in $foundation.checks_required_fields) {
        $value = Get-RequiredProperty -Object $checks -Name $fieldName -Context "Repo enforcement result.checks"
        Assert-BooleanValue -Value $value -Context "Repo enforcement result.checks.$fieldName" | Out-Null
    }

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decision" -Context "Repo enforcement result") -Context "Repo enforcement result.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "Repo enforcement result.decision"

    $blockReasons = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Result -Name "block_reasons" -Context "Repo enforcement result") -Context "Repo enforcement result.block_reasons" -AllowEmpty
    foreach ($reason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $reason -Name $fieldName -Context "Repo enforcement result.block_reasons item" | Out-Null
        }

        $code = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "code" -Context "Repo enforcement result.block_reasons item") -Context "Repo enforcement result.block_reasons item.code"
        Assert-AllowedValue -Value $code -AllowedValues @($foundation.allowed_reason_codes) -Context "Repo enforcement result.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "summary" -Context "Repo enforcement result.block_reasons item") -Context "Repo enforcement result.block_reasons item.summary" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "notes" -Context "Repo enforcement result") -Context "Repo enforcement result.notes" | Out-Null

    $checkValues = @()
    foreach ($fieldName in $foundation.checks_required_fields) {
        $checkValues += [bool]$checks.$fieldName
    }
    $allChecksPassed = ($checkValues -notcontains $false)

    if ($decision -eq "allow") {
        if ($resultContract.decision_rules.allow_requires_no_block_reasons -and $blockReasons.Count -ne 0) {
            throw "Repo enforcement result with decision 'allow' must not contain block reasons."
        }
        if ($resultContract.checks_rules.all_true_required_for_allow -and -not $allChecksPassed) {
            throw "Repo enforcement result with decision 'allow' must satisfy all checks."
        }
    }
    else {
        if ($resultContract.decision_rules.blocked_requires_block_reasons -and $blockReasons.Count -eq 0) {
            throw "Repo enforcement result with decision 'blocked' must contain block reasons."
        }
        if ($resultContract.checks_rules.blocked_requires_failed_check -and $allChecksPassed) {
            throw "Repo enforcement result with decision 'blocked' must fail at least one check."
        }
    }

    return [pscustomobject]@{
        IsValid             = $true
        EnforcementResultId = $enforcementResultId
        Decision            = $decision
    }
}

function Test-RepoEnforcementResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnforcementResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $EnforcementResultPath -Label "Repo enforcement result path"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Repo enforcement result"
    $result = Validate-ResultFields -Result $document

    return [pscustomobject]@{
        IsValid               = $result.IsValid
        EnforcementResultId   = $result.EnforcementResultId
        Decision              = $result.Decision
        EnforcementResultPath = $resolvedPath
    }
}

function Save-RepoEnforcementResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $EnforcementResult,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $resultPath = Join-Path $resolvedOutputRoot "repo-enforcement-result.json"
    Write-JsonDocument -Path $resultPath -Document $EnforcementResult
    Test-RepoEnforcementResultContract -EnforcementResultPath $resultPath | Out-Null
    return $resultPath
}

function Get-RepoEnforcementResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Repo enforcement result"
    Test-RepoEnforcementResultContract -EnforcementResultPath $resolvedPath | Out-Null
    return (Get-JsonDocument -Path $resolvedPath -Label "Repo enforcement result")
}

function Invoke-RepoEnforcementCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProofOutputRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredProofIds,
        [string[]]$PreReplayStatusLines,
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [datetime]$EvaluatedAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-RepoEnforcementFoundationContract
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repo enforcement repository root"
    $resolvedOutputRoot = Resolve-ExistingPath -PathValue $ProofOutputRoot -Label "Proof output root"
    $repoBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    $repoHead = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot

    [string[]]$statusBefore = @()
    if ($PSBoundParameters.ContainsKey("PreReplayStatusLines")) {
        if ($null -ne $PreReplayStatusLines) {
            $statusBefore = [string[]]@($PreReplayStatusLines | ForEach-Object { [string]$_ })
        }
    }
    else {
        $statusBefore = [string[]]@(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    }
    $requiredIds = @($RequiredProofIds | ForEach-Object { Assert-NonEmptyString -Value $_ -Context "Required proof id" })
    if ($requiredIds.Count -eq 0) {
        throw "Repo enforcement requires at least one required proof id."
    }

    $proofSummaryPath = Join-Path $resolvedOutputRoot "bounded-proof-suite-summary.json"
    $replaySummaryPath = Join-Path $resolvedOutputRoot "REPLAY_SUMMARY.md"
    $replayedCommandPath = Join-Path $resolvedOutputRoot "meta\replayed_command.txt"
    $reasons = [System.Collections.ArrayList]::new()

    $cleanWorktreeBeforeReplay = ($statusBefore.Count -eq 0)
    if (-not $cleanWorktreeBeforeReplay) {
        Add-UniqueBlockReason -Reasons $reasons -Code "workspace_dirty" -Summary "R5 proof review requires a clean Git worktree before replay."
    }

    $repoRelativeOutputRoot = Get-RepoRelativePathIfInsideRepo -Path $resolvedOutputRoot
    $governedOutputRoot = $true
    if ($null -ne $repoRelativeOutputRoot) {
        if (-not ($repoRelativeOutputRoot -eq "state/proof_reviews" -or $repoRelativeOutputRoot.StartsWith("state/proof_reviews/", [System.StringComparison]::OrdinalIgnoreCase))) {
            $governedOutputRoot = $false
            Add-UniqueBlockReason -Reasons $reasons -Code "governed_output_root_required" -Summary "Proof output written inside the repository must stay under 'state/proof_reviews/'."
        }
    }

    $summary = $null
    $proofSummaryValid = $false
    if (-not (Test-Path -LiteralPath $proofSummaryPath)) {
        Add-UniqueBlockReason -Reasons $reasons -Code "proof_summary_missing" -Summary "Bounded proof summary JSON is required for repo enforcement."
    }
    else {
        try {
            $summary = Get-JsonDocument -Path $proofSummaryPath -Label "Bounded proof summary"
            $proofSummaryValid = $true
        }
        catch {
            Add-UniqueBlockReason -Reasons $reasons -Code "proof_summary_invalid" -Summary $_.Exception.Message
        }
    }

    $replaySummaryPresent = Test-Path -LiteralPath $replaySummaryPath
    if (-not $replaySummaryPresent) {
        Add-UniqueBlockReason -Reasons $reasons -Code "replay_summary_missing" -Summary "Replay summary Markdown is required for closeout review."
    }

    $replayedCommandPresent = Test-Path -LiteralPath $replayedCommandPath
    if (-not $replayedCommandPresent) {
        Add-UniqueBlockReason -Reasons $reasons -Code "replayed_command_missing" -Summary "The replayed command record is required for closeout review."
    }

    $actualSelectionIds = @()
    $selectionScopeSatisfied = $false
    $proofPassed = $false
    $workspaceMutationSatisfied = $false
    $testLogsSatisfied = $false
    $replaySourceHeadSatisfied = $false

    if ($proofSummaryValid) {
        $actualSelectionIds = @($summary.selection_ids | ForEach-Object { [string]$_ })

        $missingIds = @($requiredIds | Where-Object { $actualSelectionIds -notcontains $_ })
        if ($missingIds.Count -gt 0) {
            Add-UniqueBlockReason -Reasons $reasons -Code "required_selection_missing" -Summary "Bounded proof summary is missing required proof ids: $($missingIds -join ', ')."
        }

        $extraIds = @($actualSelectionIds | Where-Object { $requiredIds -notcontains $_ })
        if ($missingIds.Count -eq 0 -and $extraIds.Count -eq 0 -and $actualSelectionIds.Count -eq $requiredIds.Count) {
            $selectionScopeSatisfied = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "selection_scope_mismatch" -Summary "Bounded proof summary selection ids must match the required proof id set exactly."
        }

        if ([int]$summary.failed_count -eq 0 -and [int]$summary.passed_count -eq $actualSelectionIds.Count) {
            $proofPassed = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "proof_failed" -Summary "Bounded proof summary recorded failures or an incomplete pass count."
        }

        if ($null -ne $summary.workspace_mutation_check -and [bool]$summary.workspace_mutation_check.passed) {
            $workspaceMutationSatisfied = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "workspace_mutation_detected" -Summary "Bounded proof summary recorded unexpected workspace mutation."
        }

        $missingLogs = [System.Collections.ArrayList]::new()
        foreach ($result in @($summary.results)) {
            $logPath = $result.log_path
            if ([string]::IsNullOrWhiteSpace($logPath) -or -not (Test-Path -LiteralPath $logPath)) {
                [void]$missingLogs.Add($result.id)
            }
        }
        if ($missingLogs.Count -eq 0) {
            $testLogsSatisfied = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "test_log_missing" -Summary "Bounded proof summary is missing raw test logs for: $($missingLogs -join ', ')."
        }

        if ($summary.repo_head -eq $repoHead) {
            $replaySourceHeadSatisfied = $true
        }
        else {
            Add-UniqueBlockReason -Reasons $reasons -Code "replay_source_head_mismatch" -Summary "Bounded proof summary repo_head does not match the current repository HEAD."
        }
    }

    $result = [pscustomobject]@{
        contract_version      = $foundation.contract_version
        record_type           = $foundation.result_record_type
        enforcement_result_id = ("repo-enforcement-{0}" -f (Get-UtcTimestamp -DateTime $EvaluatedAt).ToLower().Replace(":", "").Replace("-", ""))
        evaluated_at          = Get-UtcTimestamp -DateTime $EvaluatedAt
        repository_root       = $resolvedRepositoryRoot
        repo_branch           = $repoBranch
        repo_head             = $repoHead
        output_root           = $resolvedOutputRoot
        proof_summary_path    = $proofSummaryPath
        replay_summary_path   = $replaySummaryPath
        replayed_command_path = $replayedCommandPath
        required_selection_ids = @($requiredIds)
        actual_selection_ids  = @($actualSelectionIds)
        checks                = [pscustomobject]@{
            clean_worktree_before_replay = $cleanWorktreeBeforeReplay
            governed_output_root         = $governedOutputRoot
            proof_summary                = $proofSummaryValid
            replay_summary               = $replaySummaryPresent
            replay_command               = $replayedCommandPresent
            selection_scope              = $selectionScopeSatisfied
            proof_passed                 = $proofPassed
            workspace_mutation           = $workspaceMutationSatisfied
            test_logs                    = $testLogsSatisfied
            replay_source_head           = $replaySourceHeadSatisfied
        }
        decision              = if ($reasons.Count -eq 0) { "allow" } else { "blocked" }
        block_reasons         = @($reasons)
        notes                 = if ($reasons.Count -eq 0) { "Repo enforcement validates clean pre-replay state, governed evidence paths, exact proof scope, and proof replay integrity only. No full R5 closeout is claimed here." } else { "Repo enforcement blocked the candidate proof review fail-closed. No full R5 closeout is claimed here." }
    }

    Validate-ResultFields -Result $result | Out-Null
    return $result
}

Export-ModuleMember -Function Test-RepoEnforcementResultContract, Invoke-RepoEnforcementCheck, Save-RepoEnforcementResult, Get-RepoEnforcementResult
