$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RoleSkillPermissionMatrix.psm1"
Import-Module $modulePath -Force

$result = New-R18RoleSkillPermissionMatrixArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-005 role-to-skill permission matrix artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Matrix: {0}" -f $result.Matrix)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required roles: {0}" -f $result.RequiredRoleCount)
Write-Output ("Required skills: {0}" -f $result.RequiredSkillCount)
Write-Output ("Permission rows: {0}" -f $result.PermissionCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
