$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dispatchModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleDispatch.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$invokeMilestoneAutocycleDispatchFlow = $dispatchModule.ExportedCommands["Invoke-MilestoneAutocycleDispatchFlow"]
$setMilestoneAutocycleRunLedgerStatus = $dispatchModule.ExportedCommands["Set-MilestoneAutocycleRunLedgerStatus"]
$testMilestoneAutocycleDispatchContract = $dispatchModule.ExportedCommands["Test-MilestoneAutocycleDispatchContract"]
$testMilestoneAutocycleRunLedgerContract = $dispatchModule.ExportedCommands["Test-MilestoneAutocycleRunLedgerContract"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-TempGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    & git -C $Root init | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize temp Git repository."
    }

    & git -C $Root config core.autocrlf false | Out-Null
    & git -C $Root config core.safecrlf false | Out-Null
    & git -C $Root config user.email "codex@example.com" | Out-Null
    & git -C $Root config user.name "Codex" | Out-Null
    Set-Content -LiteralPath (Join-Path $Root "README.md") -Value "# Temp repo" -Encoding UTF8
    & git -C $Root add README.md | Out-Null
    & git -C $Root commit -m "initial temp commit" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create initial temp Git commit."
    }
}

function Invoke-GitCommitAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    & git -C $Root add -A | Out-Null
    & git -C $Root commit -m $Message | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit '$Message' in temp Git repository."
    }
}

function Get-CurrentBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $branch = (& git -C $Root branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Failed to determine the current branch in temp Git repository."
    }

    return $branch
}

function Initialize-DispatchHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-TempGitRepository -Root $Root
    $fixtureSource = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle"
    $fixtureDestinationParent = Join-Path $Root "state\fixtures\valid"
    New-Item -ItemType Directory -Path $fixtureDestinationParent -Force | Out-Null
    Copy-Item -LiteralPath $fixtureSource -Destination $fixtureDestinationParent -Recurse -Force
    Invoke-GitCommitAll -Root $Root -Message "add milestone autocycle fixtures"

    $proposalPath = Join-Path $Root "state\fixtures\valid\milestone_autocycle\proposal.expected.json"
    $freezeOutputRoot = Join-Path $Root "state\autocycle\cycle"
    New-Item -ItemType Directory -Path $freezeOutputRoot -Force | Out-Null
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-005-dispatch-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r6-005-approved-001" -FreezeId "freeze-r6-005-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T06:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before governed dispatch creation."
    Invoke-GitCommitAll -Root $Root -Message "commit approved freeze artifacts"

    $bindingOutputRoot = Join-Path $Root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $Root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r6-005-valid-001" -BaselineId "baseline-r6-005-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T06:15:00Z").ToUniversalTime())
    Invoke-GitCommitAll -Root $Root -Message "commit baseline binding artifacts"

    $freeze = Get-JsonDocument -Path $approvalFlow.FreezePath
    $tasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $tasksById[$freezeTask.task_id] = $freezeTask
    }

    return [pscustomobject]@{
        Root              = $Root
        ProposalPath      = $proposalPath
        FreezePath        = $approvalFlow.FreezePath
        BindingPath       = $bindingFlow.BindingPath
        BindingOutputRoot = $bindingOutputRoot
        DispatchOutputRoot = (Join-Path $Root "state\autocycle\dispatch")
        Branch            = Get-CurrentBranch -Root $Root
        TasksById         = $tasksById
    }
}

function New-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScopeSummary
    )

    return [pscustomobject]@{
        scope_kind    = "frozen_task_dispatch"
        scope_summary = $ScopeSummary
        allowed_paths = @(
            "tools/MilestoneAutocycleDispatch.psm1",
            "contracts/milestone_autocycle/*.json",
            "tests/test_milestone_autocycle_dispatch.ps1"
        )
        blocked_paths = @(
            "state/proof_reviews/**"
        )
    }
}

function New-ExpectedOutputs {
    return @(
        [pscustomobject]@{
            kind  = "dispatch_record"
            path  = "state/autocycle/dispatch/dispatches/*.json"
            notes = "Durable governed dispatch record."
        },
        [pscustomobject]@{
            kind  = "run_ledger"
            path  = "state/autocycle/dispatch/run_ledgers/*.json"
            notes = "Durable run ledger for the dispatch."
        }
    )
}

function New-RefusalConditions {
    return @(
        [pscustomobject]@{
            code        = "binding_missing"
            description = "Refuse when the baseline binding is missing, malformed, or no longer valid."
        },
        [pscustomobject]@{
            code        = "active_dispatch_exists"
            description = "Refuse when another dispatch in the same cycle remains active."
        }
    )
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL {0}: operation succeeded unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS {0}: {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-valid-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $taskId = "task-r6-pilot-004"
        $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId $taskId -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById[$taskId].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -DispatchId "dispatch-r6-005-valid-001" -LedgerId "run-ledger-r6-005-valid-001" -Notes "Create one governed Codex dispatch from the frozen task and pinned baseline binding only." -LedgerNotes "Initialize the governed run ledger before any execution begins."
        $dispatchCheck = & $testMilestoneAutocycleDispatchContract -DispatchPath $dispatchFlow.DispatchPath
        $ledgerCheck = & $testMilestoneAutocycleRunLedgerContract -LedgerPath $dispatchFlow.RunLedgerPath
        $dispatch = Get-JsonDocument -Path $dispatchFlow.DispatchPath
        $ledger = Get-JsonDocument -Path $dispatchFlow.RunLedgerPath

        if ($dispatchCheck.BaselineId -ne "baseline-r6-005-valid-001") {
            $failures += "FAIL valid dispatch flow: validator did not return the expected baseline id."
        }
        if ($dispatch.target_branch -ne $harness.Branch) {
            $failures += "FAIL valid dispatch flow: target branch did not persist."
        }
        if ($dispatch.task_id -ne $taskId) {
            $failures += "FAIL valid dispatch flow: task id did not persist."
        }
        if ($ledgerCheck.Status -ne "not_started" -or $ledger.status -ne "not_started") {
            $failures += "FAIL valid dispatch flow: run ledger should start in 'not_started'."
        }
        if ($ledger.dispatch_id -ne $dispatch.dispatch_id) {
            $failures += "FAIL valid dispatch flow: run ledger did not retain the dispatch id."
        }

        $runStart = & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary "Dispatch has started under explicit operator control." -Notes "Executor start recorded without any evidence bundling yet." -OccurredAt ([datetime]::Parse("2026-04-22T06:20:00Z").ToUniversalTime())
        $runFinish = & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary "Dispatch ledger marked completed for bounded pre-execution-grade testing only." -Notes "Dispatch and ledger statuses were updated durably." -OccurredAt ([datetime]::Parse("2026-04-22T06:25:00Z").ToUniversalTime())
        $completedLedger = Get-JsonDocument -Path $dispatchFlow.RunLedgerPath

        if ($runStart.Status -ne "in_progress") {
            $failures += "FAIL run ledger happy path: ledger did not enter 'in_progress'."
        }
        if ($runFinish.Status -ne "completed") {
            $failures += "FAIL run ledger happy path: ledger did not enter 'completed'."
        }
        if ([string]::IsNullOrWhiteSpace($completedLedger.started_at) -or [string]::IsNullOrWhiteSpace($completedLedger.completed_at)) {
            $failures += "FAIL run ledger happy path: started_at and completed_at were not persisted."
        }

        Write-Output ("PASS valid governed dispatch flow: {0} -> {1}" -f $dispatchCheck.DispatchId, $ledgerCheck.LedgerId)
        Write-Output ("PASS run ledger happy path: {0}" -f $runFinish.Status)
        $validPassed += 2
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid dispatch harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-active-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $firstTaskId = "task-r6-pilot-004"
        & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId $firstTaskId -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById[$firstTaskId].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -DispatchId "dispatch-r6-005-active-001" -LedgerId "run-ledger-r6-005-active-001" | Out-Null
        Invoke-GitCommitAll -Root $harness.Root -Message "commit active dispatch artifacts"

        Invoke-ExpectedRefusal -Label "active-dispatch exclusivity refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-005" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-005"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -DispatchId "dispatch-r6-005-active-002" -LedgerId "run-ledger-r6-005-active-002" | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL active-dispatch exclusivity harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-missing-binding-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        Invoke-ExpectedRefusal -Label "missing binding refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath (Join-Path $harness.Root "state\autocycle\baseline_binding\baseline_bindings\missing-binding.json") -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL missing binding refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-malformed-binding-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $tamperedBindingPath = Join-Path (Split-Path -Parent $harness.BindingPath) "tampered-binding.json"
        $tamperedBinding = Get-JsonDocument -Path $harness.BindingPath
        $tamperedBinding.baseline.baseline_ref = "baseline_store/milestone_baselines/missing-baseline.json"
        Write-JsonDocument -Path $tamperedBindingPath -Document $tamperedBinding

        Invoke-ExpectedRefusal -Label "malformed baseline-binding refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $tamperedBindingPath -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL malformed baseline-binding refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-task-mismatch-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        Invoke-ExpectedRefusal -Label "frozen-task mismatch refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-mismatch-001" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL frozen-task mismatch refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-executor-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        Invoke-ExpectedRefusal -Label "invalid executor-type refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -ExecutorType "architect" | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL invalid executor-type refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-scope-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $badScope = [pscustomobject]@{
            scope_kind    = "frozen_task_dispatch"
            scope_summary = $harness.TasksById["task-r6-pilot-004"].scope_summary
            allowed_paths = "tools/MilestoneAutocycleDispatch.psm1"
        }

        Invoke-ExpectedRefusal -Label "malformed allowed-scope refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-004" -AllowedScope $badScope -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL malformed allowed-scope refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-branch-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        Invoke-ExpectedRefusal -Label "malformed target-branch refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch "invalid branch" -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL malformed target-branch refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-outputs-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $badExpectedOutputs = @(
            [pscustomobject]@{
                kind  = "dispatch_record"
                notes = "Missing path field."
            }
        )

        Invoke-ExpectedRefusal -Label "malformed expected-outputs refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs $badExpectedOutputs -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL malformed expected-outputs refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-refusals-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $badRefusalConditions = @(
            [pscustomobject]@{
                description = "Missing refusal-condition code."
            }
        )

        Invoke-ExpectedRefusal -Label "malformed refusal-conditions refusal" -Action {
            & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId "task-r6-pilot-004" -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById["task-r6-pilot-004"].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions $badRefusalConditions -OutputRoot $harness.DispatchOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL malformed refusal-conditions refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-005-dispatch-ledger-transition-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-DispatchHarness -Root $tempRoot
        $taskId = "task-r6-pilot-004"
        $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId $taskId -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById[$taskId].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -DispatchId "dispatch-r6-005-ledger-001" -LedgerId "run-ledger-r6-005-ledger-001" | Out-Null

        Invoke-ExpectedRefusal -Label "invalid ledger-state refusal" -Action {
            & $setMilestoneAutocycleRunLedgerStatus -LedgerPath (Join-Path $harness.DispatchOutputRoot "run_ledgers\run-ledger-r6-005-ledger-001.json") -Status "completed" -ResultSummary "Invalid direct completion." -Notes "Direct completion from not_started must fail." -OccurredAt ([datetime]::Parse("2026-04-22T06:30:00Z").ToUniversalTime()) | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL invalid ledger-state refusal harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle dispatch tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle dispatch tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
