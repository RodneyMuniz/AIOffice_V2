$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17MemoryArtifactLoader.psm1"
Import-Module $modulePath -Force

$result = Test-R17MemoryArtifactLoader -RepositoryRoot $repoRoot

Write-Output "R17-013 memory/artifact loader validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Loaded ref count: {0}" -f $result.LoadedRefCount)
Write-Output ("Agent memory packet count: {0}" -f $result.AgentMemoryPacketCount)
Write-Output ("Broad repo scan used: {0}" -f $result.BroadRepoScanUsed)
Write-Output ("Runtime memory engine implemented: {0}" -f $result.RuntimeMemoryEngineImplemented)
Write-Output ("Vector retrieval implemented: {0}" -f $result.VectorRetrievalImplemented)
Write-Output ("Live agent invocation implemented: {0}" -f $result.LiveAgentInvocationImplemented)
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("External API calls implemented: {0}" -f $result.ExternalApiCallsImplemented)
