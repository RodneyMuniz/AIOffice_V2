$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RoleSkillPermissionMatrix.psm1"
Import-Module $modulePath -Force

$result = Test-R18RoleSkillPermissionMatrix -RepositoryRoot $repoRoot

Write-Output "R18-005 role-to-skill permission matrix validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required role count: {0}" -f $result.RequiredRoleCount)
Write-Output ("Required skill count: {0}" -f $result.RequiredSkillCount)
Write-Output ("Permission rows: {0}" -f $result.PermissionCount)
Write-Output ("Allowed permission rows: {0}" -f $result.AllowedPermissionCount)
Write-Output ("Denied permission rows: {0}" -f $result.DeniedPermissionCount)
Write-Output ("Approval-required permission rows: {0}" -f $result.ApprovalRequiredPermissionCount)
Write-Output ("Permission runtime enforced: {0}" -f $result.RuntimeFlags.permission_runtime_enforced)
Write-Output ("Live agent runtime invoked: {0}" -f $result.RuntimeFlags.live_agent_runtime_invoked)
Write-Output ("Live skill execution performed: {0}" -f $result.RuntimeFlags.live_skill_execution_performed)
Write-Output ("A2A message sent: {0}" -f $result.RuntimeFlags.a2a_message_sent)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("R18-006 completed: {0}" -f $result.RuntimeFlags.r18_006_completed)
