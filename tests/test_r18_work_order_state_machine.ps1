$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WorkOrderStateMachine.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_work_order_state_machine.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_work_order_state_machine.ps1"
Import-Module $modulePath -Force

$paths = Get-R18WorkOrderPaths -RepositoryRoot $repoRoot
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

function Get-ValidSet {
    $seeds = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.SeedRoot -Filter "*.work_order.json" | Sort-Object Name) {
        $seeds += Read-TestJson -Path $file.FullName
    }

    $transitions = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.TransitionRoot -Filter "*.transition.json" | Sort-Object Name) {
        $transitions += Read-TestJson -Path $file.FullName
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        StateMachine = Read-TestJson -Path $paths.StateMachine
        Catalog = Read-TestJson -Path $paths.TransitionCatalog
        Seeds = $seeds
        Transitions = $transitions
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18WorkOrderStateMachineSet -Contract $Set.Contract -StateMachine $Set.StateMachine -Catalog $Set.Catalog -Seeds $Set.Seeds -Transitions $Set.Transitions -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "seed:*") {
        $state = $Target.Substring("seed:".Length)
        $seed = @($Set.Seeds | Where-Object { $_.current_state -eq $state }) | Select-Object -First 1
        if ($null -eq $seed) {
            throw "No seed work order found for mutation target '$Target'."
        }
        return $seed
    }
    if ($Target -like "transition:*") {
        $transitionId = $Target.Substring("transition:".Length)
        $transition = @($Set.Transitions | Where-Object { $_.transition_id -eq $transitionId }) | Select-Object -First 1
        if ($null -eq $transition) {
            throw "No transition evaluation found for mutation target '$Target'."
        }
        return $transition
    }
    if ($Target -eq "contract") {
        return $Set.Contract
    }
    if ($Target -eq "catalog") {
        return $Set.Catalog
    }
    if ($Target -eq "report") {
        return $Set.Report
    }
    throw "Unknown mutation target '$Target'."
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "work_order_execution_performed",
        "work_order_state_machine_runtime_executed",
        "runner_state_store_implemented",
        "resumable_execution_log_implemented",
        "local_runner_runtime_executed",
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
        "r18_009_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @($Set.Contract.runtime_flags, $Set.StateMachine.runtime_flags, $Set.Catalog.runtime_flags, $Set.Report.runtime_flags, $Set.Snapshot.runtime_summary)
    $runtimeObjects += @($Set.Seeds | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Transitions | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Assert-RequiredStatesAndTransitions {
    param([Parameter(Mandatory = $true)][object]$Set)

    $requiredStates = @(
        "created",
        "intake_validated",
        "work_order_defined",
        "waiting_for_handoff_validation",
        "ready_for_handoff",
        "blocked_pending_future_execution_runtime",
        "validation_failed",
        "blocked_pending_operator_decision",
        "abandoned",
        "completed_foundation_only"
    )
    $requiredTransitions = @(
        "created_to_intake_validated",
        "intake_validated_to_work_order_defined",
        "work_order_defined_to_waiting_for_handoff_validation",
        "waiting_for_handoff_validation_to_ready_for_handoff",
        "ready_for_handoff_to_blocked_pending_future_execution_runtime",
        "any_state_to_validation_failed",
        "any_state_to_blocked_pending_operator_decision",
        "blocked_pending_operator_decision_to_abandoned",
        "foundation_package_to_completed_foundation_only"
    )

    foreach ($state in $requiredStates) {
        if (@($Set.StateMachine.states | ForEach-Object { $_.state_id }) -notcontains $state) {
            throw "Missing required state '$state'."
        }
    }
    foreach ($transitionId in $requiredTransitions) {
        if (@($Set.Catalog.required_transition_ids) -notcontains $transitionId) {
            throw "Missing required transition '$transitionId'."
        }
    }
}

function Assert-ExecutionBlockTransition {
    param([Parameter(Mandatory = $true)][object]$Set)

    $blocking = @($Set.Transitions | Where-Object { $_.transition_id -eq "ready_for_handoff_to_blocked_pending_future_execution_runtime" -and $_.transition_status -eq "transition_refused" }) | Select-Object -First 1
    if ($null -eq $blocking) {
        throw "Missing refused execution-block transition evaluation."
    }
    if (@($blocking.refused_actions) -notcontains "execute_work_order_before_r18_009") {
        throw "Execution-block transition must refuse work-order execution before R18-009."
    }
    if ([bool]$blocking.execution_block_check.work_order_execution_allowed -ne $false -or [bool]$blocking.execution_block_check.runner_state_store_implemented -ne $false -or [bool]$blocking.execution_block_check.resumable_execution_log_implemented -ne $false) {
        throw "Execution-block transition must keep execution, runner state store, and resumable log disabled."
    }
}

function Assert-NoForbiddenPositiveClaims {
    param([Parameter(Mandatory = $true)][object]$Set)

    $positiveClaims = @($Set.StateMachine.positive_claims) + @($Set.Catalog.positive_claims) + @($Set.Report.positive_claims) + @($Set.Snapshot.positive_claims)
    foreach ($claim in $positiveClaims) {
        if ([string]$claim -match "(?i)runner_state_store|resumable_execution_log|r18_009|live|api|runtime_execution") {
            throw "Forbidden positive claim found: $claim"
        }
    }
}

function Assert-ApiFlagsDisabled {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ([bool]$Set.Contract.api_policy.api_enabled -or [bool]$Set.Contract.api_policy.openai_api_invocation_allowed -or [bool]$Set.Contract.api_policy.codex_api_invocation_allowed) {
        throw "Contract API flags must remain disabled."
    }
    foreach ($transition in @($Set.Transitions)) {
        if ([bool]$transition.runtime_flags.openai_api_invoked -or [bool]$transition.runtime_flags.codex_api_invoked) {
            throw "$($transition.transition_id) API flags must remain false."
        }
    }
}

function Assert-R18StatusBoundary {
    Test-R18WorkOrderStatusTruth -RepositoryRoot $repoRoot
}

try {
    Invoke-RequiredCommand -Label "R18-008 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-008 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-008 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all required states and transition IDs exist"; script = { Assert-RequiredStatesAndTransitions -Set (Get-ValidSet) } },
        @{ label = "execution block refuses work-order execution before R18-009"; script = { Assert-ExecutionBlockTransition -Set (Get-ValidSet) } },
        @{ label = "runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no runner state store or resumable log positive claim exists"; script = { Assert-NoForbiddenPositiveClaims -Set (Get-ValidSet) } },
        @{ label = "API flags remain disabled"; script = { Assert-ApiFlagsDisabled -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-013 only"; script = { Assert-R18StatusBoundary } }
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
    $mutatedSet = Copy-R18WorkOrderObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18WorkOrderMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
            Write-Output ("PASS invalid: {0} -> {1}" -f $fixtureFile.Name, $message)
            $invalidRejected += 1
        }
    }
}

$finalStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"
if ($finalStaged -ne $initialStaged) {
    $failures += "FAIL safety: R18-008 tests changed staged files."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18-008 work-order state machine tests failed."
}

Write-Output ("All R18-008 work-order state machine tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
