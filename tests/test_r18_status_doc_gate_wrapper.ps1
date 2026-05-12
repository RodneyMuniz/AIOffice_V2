$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StatusDocGateWrapper.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_status_doc_gate_wrapper.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_status_doc_gate_wrapper.ps1"
Import-Module $modulePath -Force

$paths = Get-R18StatusDocGateWrapperPaths -RepositoryRoot $repoRoot
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
    return Get-R18StatusDocGateWrapperSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18StatusDocGateWrapperSet `
        -WrapperContract $Set.WrapperContract `
        -AssessmentContract $Set.AssessmentContract `
        -Profile $Set.Profile `
        -Inputs $Set.Inputs `
        -Assessments $Set.Assessments `
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

    switch -Wildcard ($Target) {
        "input:*" {
            $scenario = $Target.Substring("input:".Length)
            return @($Set.Inputs | Where-Object { $_.gate_scenario -eq $scenario })[0]
        }
        "assessment:*" {
            $scenario = $Target.Substring("assessment:".Length)
            return @($Set.Assessments | Where-Object { $_.gate_scenario -eq $scenario })[0]
        }
        "wrapper_contract" { return $Set.WrapperContract }
        "assessment_contract" { return $Set.AssessmentContract }
        "profile" { return $Set.Profile }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.WrapperContract.runtime_flags,
        $Set.AssessmentContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Inputs | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Assessments | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.assessment_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18StatusDocGateWrapperRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-018 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-018 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all five inputs exist"; script = { if (@((Get-ValidSet).Inputs).Count -ne 5) { throw "Expected five inputs." } } },
        @{ label = "all five assessments exist"; script = { if (@((Get-ValidSet).Assessments).Count -ne 5) { throw "Expected five assessments." } } },
        @{ label = "current_status_surfaces passes policy-only"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "current_status_surfaces" })[0]; if ($assessment.gate_status -ne "status_gate_passed_policy_only" -or $assessment.action_recommendation -ne "allow_future_release_gate_after_revalidation" -or -not [bool]$assessment.safe_for_future_release_gate) { throw "current_status_surfaces did not pass policy-only." } } },
        @{ label = "missing_active_state blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "missing_active_state" })[0]; if ($assessment.gate_status -ne "status_gate_blocked_missing_surface" -or [bool]$assessment.safe_for_future_release_gate) { throw "missing_active_state did not block." } } },
        @{ label = "status_boundary_drift blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "status_boundary_drift" })[0]; if ($assessment.gate_status -ne "status_gate_blocked_boundary_drift" -or [bool]$assessment.safe_for_future_release_gate) { throw "status_boundary_drift did not block." } } },
        @{ label = "overclaim_runtime blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "overclaim_runtime" })[0]; if ($assessment.gate_status -ne "status_gate_blocked_runtime_overclaim" -or [bool]$assessment.safe_for_future_release_gate -or -not [bool]$assessment.runtime_overclaim_detected) { throw "overclaim_runtime did not block." } } },
        @{ label = "r18_019_premature_claim blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "r18_019_premature_claim" })[0]; if ($assessment.gate_status -ne "status_gate_blocked_premature_future_claim" -or [bool]$assessment.safe_for_future_release_gate -or -not [bool]$assessment.future_task_claim_detected) { throw "r18_019_premature_claim did not block." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no forbidden execution or overclaim exists"; script = { $flags = (Get-ValidSet).Report.runtime_flags; foreach ($flagName in @("release_gate_executed", "stage_performed_by_gate", "commit_performed_by_gate", "push_performed_by_gate", "ci_replay_performed", "github_actions_workflow_created", "github_actions_workflow_run_claimed", "main_merge_claimed", "milestone_closeout_claimed", "external_audit_acceptance_claimed", "recovery_action_performed", "codex_api_invoked", "openai_api_invoked", "automatic_new_thread_creation_performed", "work_order_execution_performed", "a2a_message_sent", "board_runtime_mutation_performed", "product_runtime_executed", "no_manual_prompt_transfer_success_claimed", "solved_codex_compaction_claimed", "solved_codex_reliability_claimed")) { if ([bool]$flags.$flagName) { throw "Forbidden claim '$flagName' was set." } } } },
        @{ label = "R18 is active through R18-018 only after status updates"; script = { Test-R18StatusDocGateWrapperStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-019 onward remain planned only"; script = { Test-R18StatusDocGateWrapperStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18StatusDocGateWrapperObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18StatusDocGateWrapperMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-018 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 status-doc gate wrapper tests failed."
}

Write-Output ("All R18 status-doc gate wrapper tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
