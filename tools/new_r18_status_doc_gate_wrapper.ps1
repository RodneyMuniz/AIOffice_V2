$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StatusDocGateWrapper.psm1"
Import-Module $modulePath -Force

$result = New-R18StatusDocGateWrapperArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-018 status-doc gate wrapper foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input count: {0}" -f $result.InputCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Invalid fixture count: {0}" -f $result.FixtureCount)
Write-Output "Artifacts are deterministic policy artifacts only; no live wrapper runtime or release gate execution occurred."
