$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17MemoryArtifactLoader.psm1"
Import-Module $modulePath -Force

$result = New-R17MemoryArtifactLoaderArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-013 memory/artifact loader artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Loader report: {0}" -f $result.Report)
Write-Output ("Loaded refs log: {0}" -f $result.LoadedRefsLog)
Write-Output ("Agent packet root: {0}" -f $result.AgentPacketRoot)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Loaded refs: {0}" -f $result.LoadedRefCount)
Write-Output ("Agent packets: {0}" -f $result.AgentPacketCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
