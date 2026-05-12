$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorApprovalGate.psm1"
Import-Module $modulePath -Force

$result = Test-R18OperatorApprovalGate -RepositoryRoot $repoRoot

Write-Output "R18-016 operator approval gate model foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Request count: {0}" -f $result.RequestCount)
Write-Output ("Decision count: {0}" -f $result.DecisionCount)
Write-Output ("Operator approval runtime implemented: {0}" -f $result.RuntimeFlags.operator_approval_runtime_implemented)
Write-Output ("Operator approval executed: {0}" -f $result.RuntimeFlags.operator_approval_executed)
Write-Output ("Approval inferred from narration: {0}" -f $result.RuntimeFlags.approval_inferred_from_narration)
