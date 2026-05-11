$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OrchestratorControlIntake.psm1"
Import-Module $modulePath -Force

$result = Test-R18OrchestratorControlIntake -RepositoryRoot $repoRoot

Write-Output "R18-006 Orchestrator control intake validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required intake packets: {0}" -f $result.RequiredIntakeCount)
Write-Output ("Generated intake packets: {0}" -f $result.GeneratedIntakeCount)
Write-Output ("Live chat UI implemented: {0}" -f $result.RuntimeFlags.live_chat_ui_implemented)
Write-Output ("Orchestrator runtime implemented: {0}" -f $result.RuntimeFlags.orchestrator_runtime_implemented)
Write-Output ("Intake routed by runtime: {0}" -f $result.RuntimeFlags.intake_routed_by_runtime)
Write-Output ("Board runtime mutation performed: {0}" -f $result.RuntimeFlags.board_runtime_mutation_performed)
Write-Output ("A2A message sent: {0}" -f $result.RuntimeFlags.a2a_message_sent)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-007 completed: {0}" -f $result.RuntimeFlags.r18_007_completed)
