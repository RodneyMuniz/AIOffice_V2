$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentCardSchema.psm1"
Import-Module $modulePath -Force

$result = New-R18AgentCardSchemaArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-002 agent card schema artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Card root: {0}" -f $result.CardRoot)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required cards: {0}" -f $result.RequiredCardCount)
Write-Output ("Generated cards: {0}" -f $result.GeneratedCardCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
