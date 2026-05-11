$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18LocalRunnerCli.psm1"
Import-Module $modulePath -Force

$result = Test-R18LocalRunnerCli -RepositoryRoot $repoRoot

Write-Output "R18-007 local runner CLI shell validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required command count: {0}" -f $result.RequiredCommandCount)
Write-Output ("Generated input count: {0}" -f $result.GeneratedInputCount)
Write-Output ("Generated result count: {0}" -f $result.GeneratedResultCount)
Write-Output ("Local runner runtime executed: {0}" -f $result.RuntimeFlags.local_runner_runtime_executed)
Write-Output ("Work-order execution performed: {0}" -f $result.RuntimeFlags.work_order_execution_performed)
Write-Output ("Work-order state machine implemented: {0}" -f $result.RuntimeFlags.work_order_state_machine_implemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("Stage/commit/push performed by runner: {0}" -f $result.RuntimeFlags.stage_commit_push_performed)
Write-Output ("R18-008 completed: {0}" -f $result.RuntimeFlags.r18_008_completed)
