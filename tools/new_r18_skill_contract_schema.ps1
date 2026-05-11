$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18SkillContractSchema.psm1"
Import-Module $modulePath -Force

$result = New-R18SkillContractSchemaArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-003 skill contract schema artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Skill root: {0}" -f $result.SkillRoot)
Write-Output ("Registry: {0}" -f $result.Registry)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required skills: {0}" -f $result.RequiredSkillCount)
Write-Output ("Generated skills: {0}" -f $result.GeneratedSkillCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
