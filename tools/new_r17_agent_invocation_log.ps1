$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentInvocationLog.psm1"
Import-Module $modulePath -Force

$result = New-R17AgentInvocationLogArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-014 agent invocation log artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Invocation log: {0}" -f $result.InvocationLog)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Invocation records: {0}" -f $result.RecordCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
