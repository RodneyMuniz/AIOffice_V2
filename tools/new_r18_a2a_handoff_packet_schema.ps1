$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18A2AHandoffPacketSchema.psm1"
Import-Module $modulePath -Force

$result = New-R18HandoffSchemaArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-004 A2A handoff packet schema artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Packet root: {0}" -f $result.PacketRoot)
Write-Output ("Registry: {0}" -f $result.Registry)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required handoffs: {0}" -f $result.RequiredHandoffCount)
Write-Output ("Generated handoffs: {0}" -f $result.GeneratedHandoffCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
