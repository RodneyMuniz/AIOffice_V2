$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RunnerStateStore.psm1"
Import-Module $modulePath -Force

$result = New-R18RunnerStateStoreArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-009 runner state store and resumable execution log foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Profile: {0}" -f $result.Profile)
Write-Output ("Runner state: {0}" -f $result.State)
Write-Output ("State history log: {0}" -f $result.HistoryLog)
Write-Output ("Execution log: {0}" -f $result.ExecutionLog)
Write-Output ("Resume checkpoint: {0}" -f $result.Checkpoint)
Write-Output ("Seed event root: {0}" -f $result.SeedEventRoot)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required state field count: {0}" -f $result.RequiredStateFieldCount)
Write-Output ("Required log entry field count: {0}" -f $result.RequiredLogEntryFieldCount)
Write-Output ("Required checkpoint field count: {0}" -f $result.RequiredCheckpointFieldCount)
Write-Output ("Generated seed event count: {0}" -f $result.GeneratedSeedEventCount)
Write-Output ("Generated execution log entry count: {0}" -f $result.GeneratedExecutionLogEntryCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
