$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OrchestratorControlIntake.psm1"
Import-Module $modulePath -Force

$result = New-R18OrchestratorControlIntakeArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-006 Orchestrator control intake artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Packet root: {0}" -f $result.PacketRoot)
Write-Output ("Registry: {0}" -f $result.Registry)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required intake packets: {0}" -f $result.RequiredIntakeCount)
Write-Output ("Generated intake packets: {0}" -f $result.GeneratedIntakeCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
