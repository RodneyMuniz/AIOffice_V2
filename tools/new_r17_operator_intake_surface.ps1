$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OperatorIntakeSurface.psm1"
Import-Module $modulePath -Force

$result = New-R17OperatorIntakeSurfaceArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-011 operator intake surface artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Seed packet: {0}" -f $result.SeedPacket)
Write-Output ("Orchestrator proposal: {0}" -f $result.Proposal)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof-review root: {0}" -f $result.ProofRoot)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
