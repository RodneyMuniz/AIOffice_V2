$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18SkillContractSchema.psm1"
Import-Module $modulePath -Force

$result = Test-R18SkillContractSchema -RepositoryRoot $repoRoot

Write-Output "R18-003 skill contract schema validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required skill count: {0}" -f $result.RequiredSkillCount)
Write-Output ("Generated skill count: {0}" -f $result.GeneratedSkillCount)
Write-Output ("Skill IDs: {0}" -f (@($result.SkillIds) -join ", "))
Write-Output ("Live skill execution performed: {0}" -f $result.RuntimeFlags.live_skill_execution_performed)
Write-Output ("Live agent runtime invoked: {0}" -f $result.RuntimeFlags.live_agent_runtime_invoked)
Write-Output ("Live A2A runtime implemented: {0}" -f $result.RuntimeFlags.live_a2a_runtime_implemented)
Write-Output ("Live recovery runtime implemented: {0}" -f $result.RuntimeFlags.live_recovery_runtime_implemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-004 completed: {0}" -f $result.RuntimeFlags.r18_004_completed)
