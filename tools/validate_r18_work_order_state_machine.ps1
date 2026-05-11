$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WorkOrderStateMachine.psm1"
Import-Module $modulePath -Force

$result = Test-R18WorkOrderStateMachine -RepositoryRoot $repoRoot

Write-Output "R18-008 work-order state machine foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required state count: {0}" -f $result.RequiredStateCount)
Write-Output ("Required transition count: {0}" -f $result.RequiredTransitionCount)
Write-Output ("Generated seed count: {0}" -f $result.GeneratedSeedCount)
Write-Output ("Generated transition evaluation count: {0}" -f $result.GeneratedTransitionEvaluationCount)
Write-Output ("Work-order execution performed: {0}" -f $result.RuntimeFlags.work_order_execution_performed)
Write-Output ("State-machine runtime executed: {0}" -f $result.RuntimeFlags.work_order_state_machine_runtime_executed)
Write-Output ("Runner state store implemented: {0}" -f $result.RuntimeFlags.runner_state_store_implemented)
Write-Output ("Resumable execution log implemented: {0}" -f $result.RuntimeFlags.resumable_execution_log_implemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-009 completed: {0}" -f $result.RuntimeFlags.r18_009_completed)
