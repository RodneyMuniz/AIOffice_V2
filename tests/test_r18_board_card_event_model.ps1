$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18BoardCardEventModel.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_board_card_event_model.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_board_card_event_model.ps1"
Import-Module $modulePath -Force

$paths = Get-R18BoardCardEventModelPaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0
$initialStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"

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

function Get-ValidSet {
    return Get-R18BoardCardEventModelSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18BoardCardEventModelSet `
        -EventContract $Set.EventContract `
        -ModelContract $Set.ModelContract `
        -Profile $Set.Profile `
        -Cards $Set.Cards `
        -Events $Set.Events `
        -EventLogEntries $Set.EventLogEntries `
        -Registry $Set.Registry `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -EvidenceIndex $Set.EvidenceIndex `
        -RepositoryRoot $repoRoot
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.EventContract.runtime_flags,
        $Set.ModelContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Registry.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    $runtimeObjects += @($Set.Cards | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Events | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.EventLogEntries | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18BoardCardEventModelRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-020 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-020 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all required seed cards exist"; script = { $set = Get-ValidSet; foreach ($cardId in @("r18_020_recovery_runtime_card", "r18_020_stage_gate_card", "r18_020_evidence_package_card")) { if (@($set.Cards | Where-Object { $_.card_id -eq $cardId }).Count -ne 1) { throw "Missing seed card $cardId." } } } },
        @{ label = "all required event types exist"; script = { $set = Get-ValidSet; foreach ($eventType in @("card_created", "card_status_transitioned", "handoff_linked", "validation_recorded", "evidence_linked", "operator_decision_required", "release_gate_assessed", "card_blocked", "failure_recorded")) { if (@($set.Events | Where-Object { $_.event_type -eq $eventType }).Count -ne 1) { throw "Missing event type $eventType." } } } },
        @{ label = "JSONL event log exists and contains only valid event types"; script = { if (-not (Test-Path -LiteralPath $paths.EventLog -PathType Leaf)) { throw "JSONL event log is missing." }; $validTypes = @("card_created", "card_status_transitioned", "handoff_linked", "validation_recorded", "evidence_linked", "operator_decision_required", "release_gate_assessed", "card_blocked", "failure_recorded"); foreach ($entry in @((Get-ValidSet).EventLogEntries)) { if ($validTypes -notcontains [string]$entry.event_type) { throw "Unknown JSONL event type $($entry.event_type)." } } } },
        @{ label = "handoff_linked references R18 A2A handoff artifacts without sending A2A messages"; script = { $event = @((Get-ValidSet).Events | Where-Object { $_.event_type -eq "handoff_linked" })[0]; if (((@($event.linked_refs.handoff_packet_refs) -join " ") -notlike "*state/a2a/r18_handoff_packets*") -or [bool]$event.runtime_flags.a2a_message_sent -or [bool]$event.event_payload.a2a_message_sent) { throw "handoff_linked boundary failed." } } },
        @{ label = "validation_recorded references validator/test artifacts without runtime validation execution"; script = { $event = @((Get-ValidSet).Events | Where-Object { $_.event_type -eq "validation_recorded" })[0]; if (((@($event.validation_refs) -join " ") -notlike "*validate_r18_board_card_event_model*") -or [bool]$event.event_payload.validation_executed_as_runtime_action) { throw "validation_recorded boundary failed." } } },
        @{ label = "evidence_linked references proof/evidence artifacts without audit acceptance"; script = { $event = @((Get-ValidSet).Events | Where-Object { $_.event_type -eq "evidence_linked" })[0]; if (((@($event.evidence_refs) -join " ") -notlike "*state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration*") -or [bool]$event.event_payload.audit_acceptance_claimed -or [bool]$event.runtime_flags.audit_acceptance_claimed) { throw "evidence_linked boundary failed." } } },
        @{ label = "operator_decision_required references R18-016 without approval execution"; script = { $event = @((Get-ValidSet).Events | Where-Object { $_.event_type -eq "operator_decision_required" })[0]; if (((@($event.linked_refs.operator_decision_refs) -join " ") -notlike "*r18_operator_approval_gate*") -or [bool]$event.event_payload.approval_executed -or [bool]$event.event_payload.approval_inferred_from_narration) { throw "operator_decision_required boundary failed." } } },
        @{ label = "release_gate_assessed references R18-017/R18-018/R18-019 without release gate execution"; script = { $event = @((Get-ValidSet).Events | Where-Object { $_.event_type -eq "release_gate_assessed" })[0]; $joined = @($event.linked_refs.release_gate_refs) -join " "; if ($joined -notlike "*r18_stage_commit_push_gate*" -or $joined -notlike "*r18_status_doc_gate_wrapper*" -or $joined -notlike "*r18_evidence_package_wrapper*" -or [bool]$event.event_payload.release_gate_executed -or [bool]$event.runtime_flags.release_gate_executed) { throw "release_gate_assessed boundary failed." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no forbidden runtime or overclaim exists"; script = { $flags = (Get-ValidSet).Report.runtime_flags; foreach ($flagName in @("board_card_runtime_implemented", "live_board_runtime_executed", "board_runtime_mutation_performed", "work_order_execution_performed", "a2a_message_sent", "live_agent_runtime_invoked", "live_skill_execution_performed", "tool_call_execution_performed", "api_invocation_performed", "codex_api_invoked", "openai_api_invoked", "recovery_action_performed", "release_gate_executed", "ci_replay_performed", "github_actions_workflow_created", "github_actions_workflow_run_claimed", "product_runtime_executed", "no_manual_prompt_transfer_success_claimed", "solved_codex_compaction_claimed", "solved_codex_reliability_claimed", "r18_021_completed")) { if ([bool]$flags.$flagName) { throw "Forbidden claim '$flagName' was set." } } } },
        @{ label = "R18 is active through R18-021 only after status updates"; script = { Test-R18BoardCardEventModelStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-022 onward remain planned only"; script = { Test-R18BoardCardEventModelStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $fixture = Get-Content -LiteralPath $fixtureFile.FullName -Raw | ConvertFrom-Json
    $mutatedSet = Copy-R18BoardCardEventModelObject -Value (Get-ValidSet)
    $targetObject = Get-R18BoardCardEventModelMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18BoardCardEventModelMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-020 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 board/card event model tests failed."
}

Write-Output ("All R18 board/card event model tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
