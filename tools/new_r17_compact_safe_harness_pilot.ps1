$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CompactSafeHarnessPilot.psm1"
Import-Module $modulePath -Force

$result = New-R17CompactSafeHarnessPilotArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-026 compact-safe harness pilot artifacts."
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
