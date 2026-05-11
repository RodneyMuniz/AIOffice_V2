$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureDetector.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_compact_failure_detector.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_compact_failure_detector.ps1"
Import-Module $modulePath -Force

$paths = Get-R18CompactFailureDetectorPaths -RepositoryRoot $repoRoot
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

function Get-Signals {
    return @(Get-ChildItem -LiteralPath $paths.SignalRoot -Filter "*.signal.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-Events {
    return @(Get-ChildItem -LiteralPath $paths.FailureEventRoot -Filter "*.failure.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-ValidSet {
    return [pscustomobject]@{
        FailureEventContract = Read-TestJson -Path $paths.FailureEventContract
        DetectorContract = Read-TestJson -Path $paths.DetectorContract
        Profile = Read-TestJson -Path $paths.Profile
        Signals = @(Get-Signals)
        FailureEvents = @(Get-Events)
        Results = Read-TestJson -Path $paths.Results
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18CompactFailureDetectorSet `
        -FailureEventContract $Set.FailureEventContract `
        -DetectorContract $Set.DetectorContract `
        -Profile $Set.Profile `
        -Signals $Set.Signals `
        -FailureEvents $Set.FailureEvents `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "failure_event_contract" { return $Set.FailureEventContract }
        "detector_contract" { return $Set.DetectorContract }
        "profile" { return $Set.Profile }
        "signal:first" { return @($Set.Signals)[0] }
        "signal:non_compact" { return @($Set.Signals | Where-Object { $_.signal_type -eq "non_compact_validation_failure" })[0] }
        "signal:unknown" { return @($Set.Signals | Where-Object { $_.signal_type -eq "unknown_failure_requires_escalation" })[0] }
        "event:first" { return @($Set.FailureEvents)[0] }
        "event:non_compact" { return @($Set.FailureEvents | Where-Object { $_.detected_failure_type -eq "validation_failure_not_compact" })[0] }
        "event:unknown" { return @($Set.FailureEvents | Where-Object { $_.detected_failure_type -eq "unknown_failure_operator_decision_required" })[0] }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "compact_failure_detector_live_runtime_executed",
        "live_failure_monitoring_performed",
        "recovery_runtime_implemented",
        "recovery_action_performed",
        "wip_classifier_implemented",
        "wip_classification_performed",
        "remote_branch_verifier_runtime_implemented",
        "remote_branch_verified",
        "continuation_packet_generated",
        "new_context_prompt_generated",
        "work_order_execution_performed",
        "work_order_state_machine_runtime_executed",
        "runner_state_store_runtime_executed",
        "live_runner_runtime_executed",
        "board_runtime_mutation_performed",
        "live_agent_runtime_invoked",
        "live_skill_execution_performed",
        "a2a_message_sent",
        "live_a2a_runtime_implemented",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_performed",
        "automatic_new_thread_creation_performed",
        "stage_commit_push_performed",
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_011_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.FailureEventContract.runtime_flags,
        $Set.DetectorContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Signals | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.FailureEvents | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.detection_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Assert-ClassificationSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    $expected = @{
        codex_backend_compact_stream_disconnect = "codex_compact_failure"
        context_compaction_required = "context_compaction_required"
        stream_disconnected_before_completion = "stream_disconnected_before_completion"
        validation_interrupted_after_compact = "validation_failure_after_compact"
        non_compact_validation_failure = "validation_failure_not_compact"
        unknown_failure_requires_escalation = "unknown_failure_operator_decision_required"
    }

    foreach ($signalType in $expected.Keys) {
        $eventRef = "state/runtime/r18_compact_failure_signal_samples/$signalType.signal.json"
        $event = @($Set.FailureEvents | Where-Object { $_.source_signal_ref -eq $eventRef })[0]
        if ($event.detected_failure_type -ne $expected[$signalType]) {
            throw "$signalType classified as $($event.detected_failure_type), expected $($expected[$signalType])."
        }
    }

    $nonCompact = @($Set.FailureEvents | Where-Object { $_.source_signal_ref -eq "state/runtime/r18_compact_failure_signal_samples/non_compact_validation_failure.signal.json" })[0]
    if ($nonCompact.detected_failure_type -in @("codex_compact_failure", "context_compaction_required")) {
        throw "non_compact_validation_failure was falsely classified as compact failure."
    }

    $unknown = @($Set.FailureEvents | Where-Object { $_.source_signal_ref -eq "state/runtime/r18_compact_failure_signal_samples/unknown_failure_requires_escalation.signal.json" })[0]
    if ([bool]$unknown.operator_decision_required -ne $true) {
        throw "unknown failure must require operator decision."
    }
}

function Assert-NoFutureRuntimeClaims {
    param([Parameter(Mandatory = $true)][object]$Set)

    Assert-AllRuntimeFalseFlags -Set $Set
    if ([bool]$Set.FailureEventContract.recovery_boundary_policy.recovery_runtime_allowed -or [bool]$Set.DetectorContract.api_policy.api_enabled) {
        throw "R18-010 must not allow recovery runtime or API enablement."
    }
}

try {
    Invoke-RequiredCommand -Label "R18-010 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-010 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-010 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all valid signal samples pass"; script = { if (@((Get-ValidSet).Signals).Count -ne 6) { throw "Expected six signal samples." } } },
        @{ label = "all detected failure events are generated"; script = { if (@((Get-ValidSet).FailureEvents).Count -ne 6) { throw "Expected six failure events." } } },
        @{ label = "compact/backend/compaction signals classify correctly"; script = { Assert-ClassificationSemantics -Set (Get-ValidSet) } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no recovery/WIP/remote/continuation/new-context/runtime/API claims exist"; script = { Assert-NoFutureRuntimeClaims -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-010 only"; script = { Test-R18CompactFailureDetectorStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18CompactFailureDetectorObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18CompactFailureDetectorMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-010 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 compact failure detector tests failed."
}

Write-Output ("All R18 compact failure detector tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
