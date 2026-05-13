$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle3QaFixLoopHarness.psm1"
Import-Module $modulePath -Force

$result = Test-R18Cycle3QaFixLoopHarness -RepositoryRoot $repoRoot

Write-Output "R18-025 Cycle 3 QA/fix-loop harness validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Work-order records: {0}" -f $result.WorkOrderRecordCount)
Write-Output ("Validator run log entries: {0}" -f $result.ValidatorRunLogEntryCount)
Write-Output ("Board event records: {0}" -f $result.BoardEventCount)
Write-Output ("QA verdict: {0}" -f $result.QaVerdict)
Write-Output ("Recovery action performed: {0}" -f $result.RecoveryActionPerformed)
