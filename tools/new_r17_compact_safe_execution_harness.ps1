$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CompactSafeExecutionHarness.psm1"
Import-Module $modulePath -Force

$result = New-R17CompactSafeExecutionHarnessArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-025 compact-safe local execution harness foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Plan: {0}" -f $result.Plan)
Write-Output ("Work orders: {0}" -f $result.WorkOrders)
Write-Output ("Resume state: {0}" -f $result.ResumeState)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("Prompt packet root: {0}" -f $result.PromptPacketRoot)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
