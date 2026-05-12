$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StageCommitPushGate.psm1"
Import-Module $modulePath -Force

$result = New-R18StageCommitPushArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-017 stage/commit/push gate foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Gate input count: {0}" -f $result.GateInputCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Invalid fixture count: {0}" -f $result.FixtureCount)
Write-Output "Artifacts are deterministic policy artifacts only; the gate did not stage, commit, or push."
