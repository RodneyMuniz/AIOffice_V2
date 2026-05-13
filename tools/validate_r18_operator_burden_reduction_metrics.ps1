$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorBurdenReductionMetrics.psm1"
Import-Module $modulePath -Force

$result = Test-R18OperatorBurdenReductionMetrics -RepositoryRoot $repoRoot

Write-Output "R18-027 operator burden reduction metrics validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Runner log entries: {0}" -f $result.RunnerLogEntryCount)
Write-Output ("Continuation events: {0}" -f $result.ContinuationEventCount)
Write-Output ("Operator approval decisions: {0}" -f $result.OperatorApprovalDecisionCount)
Write-Output ("Burden reduction proven: {0}" -f $result.BurdenReductionProven)
Write-Output ("No-manual-prompt-transfer success claimed: {0}" -f $result.NoManualPromptTransferSuccessClaimed)
