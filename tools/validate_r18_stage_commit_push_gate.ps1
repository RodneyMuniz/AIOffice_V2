$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StageCommitPushGate.psm1"
Import-Module $modulePath -Force

$result = Test-R18StageCommitPushGate -RepositoryRoot $repoRoot

Write-Output "R18-017 stage/commit/push gate validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Gate input count: {0}" -f $result.GateInputCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Gate runtime implemented: {0}" -f $result.RuntimeFlags.stage_commit_push_gate_runtime_implemented)
Write-Output ("Stage performed by gate: {0}" -f $result.RuntimeFlags.stage_performed_by_gate)
Write-Output ("Commit performed by gate: {0}" -f $result.RuntimeFlags.commit_performed_by_gate)
Write-Output ("Push performed by gate: {0}" -f $result.RuntimeFlags.push_performed_by_gate)
