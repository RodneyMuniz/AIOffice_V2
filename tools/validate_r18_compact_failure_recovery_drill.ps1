$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureRecoveryDrill.psm1"
Import-Module $modulePath -Force

$result = Test-R18CompactFailureRecoveryDrill -RepositoryRoot $repoRoot

Write-Output "R18-024 compact-failure recovery drill validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Runner evidence present: {0}" -f $result.RunnerEvidencePresent)
Write-Output ("Runner log entries: {0}" -f $result.RunnerLogEntryCount)
Write-Output ("Retry count: {0}" -f $result.RetryCount)
Write-Output ("Recovery action performed: {0}" -f $result.RecoveryActionPerformed)
