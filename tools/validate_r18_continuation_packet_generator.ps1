$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ContinuationPacketGenerator.psm1"
Import-Module $modulePath -Force

$result = Test-R18ContinuationPacketGenerator -RepositoryRoot $repoRoot

Write-Output "R18-013 continuation packet generator foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input set count: {0}" -f $result.InputSetCount)
Write-Output ("Continuation packet count: {0}" -f $result.ContinuationPacketCount)
Write-Output ("Continuation packet executed: {0}" -f $result.RuntimeFlags.continuation_packet_executed)
Write-Output ("New-context prompt generated: {0}" -f $result.RuntimeFlags.new_context_prompt_generated)
Write-Output ("Recovery action performed: {0}" -f $result.RuntimeFlags.recovery_action_performed)
Write-Output ("Retry execution performed: {0}" -f $result.RuntimeFlags.retry_execution_performed)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
