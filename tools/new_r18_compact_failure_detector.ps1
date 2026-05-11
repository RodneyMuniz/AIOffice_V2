$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureDetector.psm1"
Import-Module $modulePath -Force

$result = New-R18CompactFailureDetectorArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-010 compact failure detector foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Signal count: {0}" -f $result.SignalCount)
Write-Output ("Failure event count: {0}" -f $result.FailureEventCount)
