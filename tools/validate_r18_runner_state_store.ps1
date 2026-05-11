$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RunnerStateStore.psm1"
Import-Module $modulePath -Force

$result = Test-R18RunnerStateStore -RepositoryRoot $repoRoot

Write-Output "R18-009 runner state store foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required state field count: {0}" -f $result.RequiredStateFieldCount)
Write-Output ("Required log entry field count: {0}" -f $result.RequiredLogEntryFieldCount)
Write-Output ("Required checkpoint field count: {0}" -f $result.RequiredCheckpointFieldCount)
Write-Output ("Generated seed event count: {0}" -f $result.GeneratedSeedEventCount)
Write-Output ("Work-order execution performed: {0}" -f $result.RuntimeFlags.work_order_execution_performed)
Write-Output ("Live runner runtime executed: {0}" -f $result.RuntimeFlags.live_runner_runtime_executed)
Write-Output ("Compact failure detector implemented: {0}" -f $result.RuntimeFlags.compact_failure_detector_implemented)
Write-Output ("WIP classifier implemented: {0}" -f $result.RuntimeFlags.wip_classifier_implemented)
Write-Output ("Remote branch verifier runtime implemented: {0}" -f $result.RuntimeFlags.remote_branch_verifier_runtime_implemented)
Write-Output ("Continuation packet generated: {0}" -f $result.RuntimeFlags.continuation_packet_generated)
Write-Output ("New-context prompt generated: {0}" -f $result.RuntimeFlags.new_context_prompt_generated)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-010 completed: {0}" -f $result.RuntimeFlags.r18_010_completed)
