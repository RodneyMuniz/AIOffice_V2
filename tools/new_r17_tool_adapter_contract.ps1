$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolAdapterContract.psm1"
Import-Module $modulePath -Force

$result = New-R17ToolAdapterContractArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-015 tool adapter contract artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Seed profiles: {0}" -f $result.SeedProfiles)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Seed profiles: {0}" -f $result.SeedProfileCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
