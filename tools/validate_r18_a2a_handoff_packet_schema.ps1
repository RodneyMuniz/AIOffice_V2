$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18A2AHandoffPacketSchema.psm1"
Import-Module $modulePath -Force

$result = Test-R18HandoffPacketSchema -RepositoryRoot $repoRoot

Write-Output "R18-004 A2A handoff packet schema validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required handoff count: {0}" -f $result.RequiredHandoffCount)
Write-Output ("Generated handoff count: {0}" -f $result.GeneratedHandoffCount)
Write-Output ("Handoff IDs: {0}" -f (@($result.HandoffIds) -join ", "))
Write-Output ("A2A message sent: {0}" -f $result.RuntimeFlags.a2a_message_sent)
Write-Output ("Live A2A runtime implemented: {0}" -f $result.RuntimeFlags.live_a2a_runtime_implemented)
Write-Output ("Live agent runtime invoked: {0}" -f $result.RuntimeFlags.live_agent_runtime_invoked)
Write-Output ("Live skill execution performed: {0}" -f $result.RuntimeFlags.live_skill_execution_performed)
Write-Output ("Live recovery runtime implemented: {0}" -f $result.RuntimeFlags.live_recovery_runtime_implemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-005 completed: {0}" -f $result.RuntimeFlags.r18_005_completed)
