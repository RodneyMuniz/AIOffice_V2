$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorLoopStateMachine.psm1"
Import-Module $modulePath -Force

$result = New-R17OrchestratorLoopArtifacts -RepositoryRoot $repoRoot
Write-Output ("Generated R17-010 Orchestrator loop state machine artifacts. Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("State machine: {0}" -f $result.StateMachinePath)
Write-Output ("Seed evaluation: {0}" -f $result.SeedEvaluationPath)
Write-Output ("Transition check report: {0}" -f $result.TransitionCheckReportPath)
