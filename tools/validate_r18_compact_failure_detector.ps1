$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureDetector.psm1"
Import-Module $modulePath -Force

$result = Test-R18CompactFailureDetector -RepositoryRoot $repoRoot

Write-Output "R18-010 compact failure detector foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Signal count: {0}" -f $result.SignalCount)
Write-Output ("Failure event count: {0}" -f $result.FailureEventCount)
Write-Output ("Recovery runtime implemented: {0}" -f $result.RuntimeFlags.recovery_runtime_implemented)
Write-Output ("Recovery action performed: {0}" -f $result.RuntimeFlags.recovery_action_performed)
Write-Output ("WIP classifier implemented: {0}" -f $result.RuntimeFlags.wip_classifier_implemented)
Write-Output ("Remote branch verified: {0}" -f $result.RuntimeFlags.remote_branch_verified)
Write-Output ("Continuation packet generated: {0}" -f $result.RuntimeFlags.continuation_packet_generated)
Write-Output ("New-context prompt generated: {0}" -f $result.RuntimeFlags.new_context_prompt_generated)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-011 completed: {0}" -f $result.RuntimeFlags.r18_011_completed)
