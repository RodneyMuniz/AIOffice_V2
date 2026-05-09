$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolCallLedger.psm1"
Import-Module $modulePath -Force

$result = New-R17ToolCallLedgerArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-019 tool-call ledger foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Ledger: {0}" -f $result.Ledger)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Ledger records: {0}" -f $result.LedgerRecordCount)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
