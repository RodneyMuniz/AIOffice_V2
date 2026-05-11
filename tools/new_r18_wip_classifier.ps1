$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WipClassifier.psm1"
Import-Module $modulePath -Force

$result = New-R18WipClassifierArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-011 WIP classifier foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Inventory count: {0}" -f $result.InventoryCount)
Write-Output ("Classification packet count: {0}" -f $result.ClassificationPacketCount)
