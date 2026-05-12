$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18NewContextPromptGenerator.psm1"
Import-Module $modulePath -Force

$result = Test-R18NewContextPromptGenerator -RepositoryRoot $repoRoot

Write-Output "R18-014 new-context prompt generator foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Prompt input count: {0}" -f $result.PromptInputCount)
Write-Output ("Prompt packet count: {0}" -f $result.PromptPacketCount)
Write-Output ("Prompt packet executed: {0}" -f $result.RuntimeFlags.prompt_packet_executed)
Write-Output ("Automatic new-thread creation performed: {0}" -f $result.RuntimeFlags.automatic_new_thread_creation_performed)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
