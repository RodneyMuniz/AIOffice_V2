$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RetryEscalationPolicy.psm1"
Import-Module $modulePath -Force

$result = Test-R18RetryEscalationPolicy -RepositoryRoot $repoRoot

Write-Output "R18-015 retry escalation policy foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Scenario count: {0}" -f $result.ScenarioCount)
Write-Output ("Decision count: {0}" -f $result.DecisionCount)
Write-Output ("Retry execution performed: {0}" -f $result.RuntimeFlags.retry_execution_performed)
Write-Output ("Retry runtime implemented: {0}" -f $result.RuntimeFlags.retry_runtime_implemented)
Write-Output ("Escalation runtime implemented: {0}" -f $result.RuntimeFlags.escalation_runtime_implemented)
Write-Output ("Operator approval runtime implemented: {0}" -f $result.RuntimeFlags.operator_approval_runtime_implemented)
