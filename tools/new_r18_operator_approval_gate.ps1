$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorApprovalGate.psm1"
Import-Module $modulePath -Force

$result = New-R18OperatorApprovalGateArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-016 operator approval gate model foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Request count: {0}" -f $result.RequestCount)
Write-Output ("Decision count: {0}" -f $result.DecisionCount)
Write-Output "Approval requests and refusal packets are deterministic governance artifacts only and were not executed."
