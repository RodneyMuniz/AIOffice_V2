$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle4AuditCloseoutHarness.psm1"
Import-Module $modulePath -Force

$result = Test-R18Cycle4AuditCloseoutHarness -RepositoryRoot $repoRoot

Write-Output "R18-026 Cycle 4 audit/closeout harness validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Machine-readable evidence inventory entries: {0}" -f $result.EvidenceInventoryCount)
Write-Output ("Validator run log entries: {0}" -f $result.ValidatorRunLogEntryCount)
Write-Output ("Board event records: {0}" -f $result.BoardEventCount)
Write-Output ("Release gate status: {0}" -f $result.ReleaseGateStatus)
Write-Output ("Closeout approved: {0}" -f $result.CloseoutApproved)
