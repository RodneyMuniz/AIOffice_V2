$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ContinuationPacketGenerator.psm1"
Import-Module $modulePath -Force

$result = New-R18ContinuationArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-013 continuation packet generator foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input set count: {0}" -f $result.InputSetCount)
Write-Output ("Continuation packet count: {0}" -f $result.ContinuationPacketCount)
