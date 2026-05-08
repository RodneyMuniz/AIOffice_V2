$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorLoopStateMachine.psm1"
Import-Module $modulePath -Force

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

try {
    Test-R17OrchestratorLoopStateMachineContract -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: contract"
    $validPassed += 1

    Test-R17OrchestratorLoopStateMachine -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: generated state machine"
    $validPassed += 1

    $seedResult = Test-R17OrchestratorLoopSeedEvaluation -RepositoryRoot $repoRoot
    if ($seedResult.CurrentLoopState -ne "ready_for_user_review" -or $seedResult.RecommendedNextLoopState -ne "ready_for_user_review" -or $seedResult.RecommendedNextAction -ne "request_user_review_or_closure_decision") {
        $failures += "FAIL valid: seed evaluation recommendation fields were not deterministic."
    }
    else {
        Write-Output "PASS valid: seed evaluation"
        $validPassed += 1
    }

    $reportResult = Test-R17OrchestratorLoopTransitionCheckReport -RepositoryRoot $repoRoot
    if ($reportResult.AggregateVerdict -ne "generated_r17_orchestrator_loop_state_machine_candidate") {
        $failures += "FAIL valid: transition check report aggregate verdict mismatch."
    }
    else {
        Write-Output "PASS valid: transition check report"
        $validPassed += 1
    }

    Test-R17OrchestratorLoopStateMachine -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_orchestrator_loop_state_machine.json" -RepositoryRoot $repoRoot | Out-Null
    Test-R17OrchestratorLoopSeedEvaluation -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_seed_evaluation.json" -RepositoryRoot $repoRoot | Out-Null
    Test-R17OrchestratorLoopTransitionCheckReport -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_transition_check_report.json" -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: fixture set"
    $validPassed += 1

    foreach ($fixtureDefinition in New-R17OrchestratorLoopInvalidFixtureDefinitions) {
        $fixturePath = "tests/fixtures/r17_orchestrator_loop_state_machine/$($fixtureDefinition.name).json"
        Invoke-ExpectedRefusal -Label $fixtureDefinition.name -Action {
            Test-R17OrchestratorLoopFixture -Path $fixturePath -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $validation = Invoke-R17OrchestratorLoopValidation -RepositoryRoot $repoRoot
    if ($validation.Status -ne "passed" -or $validation.AggregateVerdict -ne "generated_r17_orchestrator_loop_state_machine_candidate") {
        $failures += "FAIL valid: aggregate validation did not pass."
    }
    else {
        Write-Output ("PASS valid: aggregate validation rejected {0} invalid fixtures" -f $validation.InvalidFixturesRejected)
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17-010 Orchestrator loop state machine tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}." -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17-010 Orchestrator loop state machine tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
