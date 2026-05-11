$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17FinalEvidencePackage.psm1"
Import-Module $modulePath -Force

$result = Test-R17FinalEvidencePackage -RepositoryRoot $repoRoot

Write-Output "R17-028 final evidence package validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Source task: {0}" -f $result.SourceTask)
Write-Output ("Active through: {0}" -f $result.ActiveThroughTask)
Write-Output ("KPI domain count: {0}" -f $result.DomainCount)
Write-Output ("Weighted actual score: {0}" -f $result.WeightedActualScore)
Write-Output ("R17 closed: {0}" -f $result.R17Closed)
Write-Output ("R18 opened: {0}" -f $result.R18Opened)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("Operator decision required: {0}" -f $result.OperatorDecisionRequired)
