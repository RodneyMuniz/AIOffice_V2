$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17Cycle2DevExecution.psm1"
Import-Module $modulePath -Force

$result = New-R17Cycle2DevExecutionArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-024 Cycle 2 Developer/Codex execution package artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Cycle root: {0}" -f $result.CycleRoot)
Write-Output ("Board card: {0}" -f $result.BoardCard)
Write-Output ("Board events: {0}" -f $result.BoardEvents)
Write-Output ("Board snapshot: {0}" -f $result.BoardSnapshot)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
