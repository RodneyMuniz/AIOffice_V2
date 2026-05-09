$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17A2aContracts.psm1"
Import-Module $modulePath -Force

$result = New-R17A2aContractsArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-020 A2A message and handoff contract foundation artifacts."
Write-Output ("Message contract: {0}" -f $result.MessageContract)
Write-Output ("Handoff contract: {0}" -f $result.HandoffContract)
Write-Output ("Message seed packets: {0}" -f $result.MessagePackets)
Write-Output ("Handoff seed packets: {0}" -f $result.HandoffPackets)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Message seed packets: {0}" -f $result.MessageCount)
Write-Output ("Handoff seed packets: {0}" -f $result.HandoffCount)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
