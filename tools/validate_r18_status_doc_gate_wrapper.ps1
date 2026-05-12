$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StatusDocGateWrapper.psm1"
Import-Module $modulePath -Force

$result = Test-R18StatusDocGateWrapper -RepositoryRoot $repoRoot

Write-Output "R18-018 status-doc gate wrapper validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input count: {0}" -f $result.InputCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Wrapper runtime implemented: {0}" -f $result.RuntimeFlags.status_doc_gate_wrapper_runtime_implemented)
Write-Output ("Live status-doc gate runtime executed: {0}" -f $result.RuntimeFlags.live_status_doc_gate_runtime_executed)
Write-Output ("Release gate executed: {0}" -f $result.RuntimeFlags.release_gate_executed)
Write-Output ("CI replay performed: {0}" -f $result.RuntimeFlags.ci_replay_performed)
