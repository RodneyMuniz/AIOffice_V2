$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentCardSchema.psm1"
Import-Module $modulePath -Force

$result = Test-R18AgentCardSchema -RepositoryRoot $repoRoot

Write-Output "R18-002 agent card schema validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required card count: {0}" -f $result.RequiredCardCount)
Write-Output ("Generated card count: {0}" -f $result.GeneratedCardCount)
Write-Output ("Agent IDs: {0}" -f (@($result.AgentIds) -join ", "))
Write-Output ("Live agent runtime invoked: {0}" -f $result.RuntimeFlags.live_agent_runtime_invoked)
Write-Output ("Live A2A runtime implemented: {0}" -f $result.RuntimeFlags.live_a2a_runtime_implemented)
Write-Output ("Live recovery runtime implemented: {0}" -f $result.RuntimeFlags.live_recovery_runtime_implemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-003 completed: {0}" -f $result.RuntimeFlags.r18_003_completed)
