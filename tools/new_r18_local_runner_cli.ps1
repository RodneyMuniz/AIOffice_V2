$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18LocalRunnerCli.psm1"
Import-Module $modulePath -Force

$result = New-R18LocalRunnerCliArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-007 local runner CLI shell artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Profile: {0}" -f $result.Profile)
Write-Output ("Catalog: {0}" -f $result.Catalog)
Write-Output ("Input root: {0}" -f $result.InputRoot)
Write-Output ("Result root: {0}" -f $result.ResultRoot)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required command count: {0}" -f $result.RequiredCommandCount)
Write-Output ("Generated input count: {0}" -f $result.GeneratedInputCount)
Write-Output ("Generated result count: {0}" -f $result.GeneratedResultCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
