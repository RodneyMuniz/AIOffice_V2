$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RunnerStateStore.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_runner_state_store.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_runner_state_store.ps1"
Import-Module $modulePath -Force

$paths = Get-R18RunnerStateStorePaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0
$initialStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Invoke-RequiredCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$ScriptPath
    )

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed: $($output -join [Environment]::NewLine)"
    }
    Write-Output "PASS command: $Label"
    return $output
}

function Get-SeedEvents {
    $events = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.SeedEventRoot -Filter "*.event.json" | Sort-Object Name) {
        $events += Read-TestJson -Path $file.FullName
    }
    return $events
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Profile = Read-TestJson -Path $paths.Profile
        State = Read-TestJson -Path $paths.State
        HistoryEntries = @(Read-R18RunnerJsonLines -Path $paths.HistoryLog)
        ExecutionEntries = @(Read-R18RunnerJsonLines -Path $paths.ExecutionLog)
        Checkpoint = Read-TestJson -Path $paths.Checkpoint
        SeedEvents = @(Get-SeedEvents)
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18RunnerStateStoreSet `
        -Contract $Set.Contract `
        -Profile $Set.Profile `
        -State $Set.State `
        -HistoryEntries $Set.HistoryEntries `
        -ExecutionEntries $Set.ExecutionEntries `
        -Checkpoint $Set.Checkpoint `
        -SeedEvents $Set.SeedEvents `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch -Wildcard ($Target) {
        "contract" { return $Set.Contract }
        "profile" { return $Set.Profile }
        "state" { return $Set.State }
        "checkpoint" { return $Set.Checkpoint }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "execution_log:first" { return @($Set.ExecutionEntries)[0] }
        "history_log:first" { return @($Set.HistoryEntries)[0] }
        "seed_event:first" { return @($Set.SeedEvents)[0] }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "work_order_execution_performed",
        "work_order_state_machine_runtime_executed",
        "runner_state_store_runtime_executed",
        "live_runner_runtime_executed",
        "compact_failure_detector_implemented",
        "wip_classifier_implemented",
        "remote_branch_verifier_runtime_implemented",
        "continuation_packet_generated",
        "new_context_prompt_generated",
        "live_chat_ui_implemented",
        "orchestrator_runtime_implemented",
        "board_runtime_mutation_performed",
        "live_agent_runtime_invoked",
        "live_skill_execution_performed",
        "a2a_message_sent",
        "live_a2a_runtime_implemented",
        "live_recovery_runtime_implemented",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_performed",
        "automatic_new_thread_creation_performed",
        "stage_commit_push_performed",
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_010_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.State.runtime_flags,
        $Set.Checkpoint.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_summary
    )
    $runtimeObjects += @($Set.HistoryEntries | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.ExecutionEntries | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.SeedEvents | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Assert-SeedStateSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ($Set.State.current_work_order_ref -ne "state/runtime/r18_work_order_seed_packets/r18_008_seed_blocked_pending_future_execution.work_order.json") {
        throw "Runner state must reference the R18-008 blocked seed work order."
    }
    if ($Set.State.current_state -ne "blocked_pending_future_execution_runtime") {
        throw "Runner state current_state must be blocked_pending_future_execution_runtime."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Set.State.last_completed_step)) {
        throw "Runner state last_completed_step is required."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Set.State.next_safe_step)) {
        throw "Runner state next_safe_step is required."
    }
    if ([int]$Set.State.max_retry_count -gt 3 -or [bool]$Set.State.retry_limit_enforced -ne $true) {
        throw "Runner state retry count must be bounded and enforced."
    }
}

function Assert-CheckpointSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ($Set.Checkpoint.checkpoint_status -ne "checkpoint_foundation_only_not_continuation_packet") {
        throw "Resume checkpoint must be a checkpoint foundation only."
    }
    if ([bool]$Set.Checkpoint.continuation_packet_generated -ne $false) {
        throw "Resume checkpoint must not claim continuation packet generation."
    }
    if ([bool]$Set.Checkpoint.new_context_prompt_generated -ne $false) {
        throw "Resume checkpoint must not claim new-context prompt generation."
    }
}

function Assert-ExecutionLogSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    $allowedEventTypes = @(
        "runner_state_store_initialized",
        "runner_state_loaded",
        "intake_ref_recorded",
        "work_order_ref_recorded",
        "transition_ref_recorded",
        "resume_checkpoint_created",
        "execution_block_recorded",
        "foundation_validation_recorded"
    )
    if (@($Set.ExecutionEntries).Count -eq 0) {
        throw "Execution log JSONL must contain entries."
    }
    foreach ($entry in @($Set.ExecutionEntries)) {
        if (@($allowedEventTypes) -notcontains [string]$entry.event_type) {
            throw "Execution log contains unknown event type '$($entry.event_type)'."
        }
    }
}

function Assert-NoFutureRuntimeClaims {
    param([Parameter(Mandatory = $true)][object]$Set)

    Assert-AllRuntimeFalseFlags -Set $Set
    if ([bool]$Set.Contract.api_policy.api_enabled -or [bool]$Set.Contract.api_policy.openai_api_invocation_allowed -or [bool]$Set.Contract.api_policy.codex_api_invocation_allowed) {
        throw "API policy must remain disabled."
    }
    if ([bool]$Set.Contract.execution_policy.work_order_execution_allowed -or [bool]$Set.Contract.execution_policy.live_runner_runtime_allowed) {
        throw "Execution policy must not allow work-order execution or live runner runtime."
    }
}

function Assert-R18StatusBoundary {
    Test-R18RunnerStateStoreStatusTruth -RepositoryRoot $repoRoot
}

try {
    Invoke-RequiredCommand -Label "R18-009 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-009 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-009 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "runner state references R18-008 blocked seed work order"; script = { Assert-SeedStateSemantics -Set (Get-ValidSet) } },
        @{ label = "resume checkpoint exists but is not a continuation packet"; script = { Assert-CheckpointSemantics -Set (Get-ValidSet) } },
        @{ label = "execution log JSONL has allowed event types only"; script = { Assert-ExecutionLogSemantics -Set (Get-ValidSet) } },
        @{ label = "no compact/WIP/remote/continuation/new-context/runtime/API claims exist"; script = { Assert-NoFutureRuntimeClaims -Set (Get-ValidSet) } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-009 only"; script = { Assert-R18StatusBoundary } }
    )) {
    try {
        & $assertion.script
        Write-Output "PASS valid: $($assertion.label)."
        $validPassed += 1
    }
    catch {
        $failures += "FAIL $($assertion.label): $($_.Exception.Message)"
    }
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R18RunnerStateStoreObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18RunnerStateStoreMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

    try {
        Invoke-SetValidation -Set $mutatedSet | Out-Null
        $failures += "FAIL invalid: $($fixtureFile.Name) was accepted."
    }
    catch {
        $message = $_.Exception.Message
        $matched = $false
        foreach ($fragment in @($fixture.expected_failure_fragments)) {
            if ($message -match [regex]::Escape([string]$fragment)) {
                $matched = $true
            }
        }

        if (-not $matched -and @($fixture.expected_failure_fragments).Count -gt 0) {
            $failures += "FAIL invalid: $($fixtureFile.Name) rejected with unexpected message: $message"
        }
        else {
            Write-Output "PASS invalid: $($fixtureFile.Name)"
            $invalidRejected += 1
        }
    }
}

$finalStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"
if ($initialStaged -ne $finalStaged) {
    $failures += "FAIL safety: R18-009 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 runner state store tests failed."
}

Write-Output ("All R18 runner state store tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
