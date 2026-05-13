$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorBurdenReductionMetrics.psm1"
Import-Module $modulePath -Force

$result = New-R18OperatorBurdenReductionMetricsArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-027 operator burden reduction metrics foundation generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Runner log entries: {0}" -f $result.RunnerLogEntryCount)
Write-Output ("Continuation events: {0}" -f $result.ContinuationEventCount)
Write-Output ("Operator approval decisions: {0}" -f $result.OperatorApprovalDecisionCount)
Write-Output ("Burden reduction proven: {0}" -f $result.BurdenReductionProven)
Write-Output ("No-manual-prompt-transfer success claimed: {0}" -f $result.NoManualPromptTransferSuccessClaimed)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic bounded metrics evidence only; no no-manual-prompt-transfer success, recovery action, runtime/API/tool/agent/A2A execution, release gate execution, CI replay, GitHub Actions workflow creation/run, external audit acceptance, main merge, milestone closeout, product runtime, or solved compaction/reliability is claimed."
