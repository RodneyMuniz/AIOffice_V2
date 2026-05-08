$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorLoopStateMachine.psm1"
Import-Module $modulePath -Force

$result = Invoke-R17OrchestratorLoopValidation -RepositoryRoot $repoRoot
Write-Output ("R17-010 Orchestrator loop state machine validation {0}. Aggregate verdict: {1}. Invalid fixtures rejected: {2}." -f $result.Status, $result.AggregateVerdict, $result.InvalidFixturesRejected)
