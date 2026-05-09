$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolCallLedger.psm1"
Import-Module $modulePath -Force

$result = Test-R17ToolCallLedger -RepositoryRoot $repoRoot

Write-Output "R17-019 tool-call ledger foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Ledger records: {0}" -f $result.LedgerRecordCount)
Write-Output ("Adapter ids: {0}" -f (@($result.AdapterIds) -join ", "))
Write-Output ("Ledger runtime implemented: {0}" -f $result.LedgerRuntimeImplemented)
Write-Output ("Tool-call runtime implemented: {0}" -f $result.ToolCallRuntimeImplemented)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("Adapter runtime invoked: {0}" -f $result.AdapterRuntimeInvoked)
Write-Output ("Codex executor invoked: {0}" -f $result.CodexExecutorInvoked)
Write-Output ("QA/Test Agent invoked: {0}" -f $result.QaTestAgentInvoked)
Write-Output ("Evidence Auditor API invoked: {0}" -f $result.EvidenceAuditorApiInvoked)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("Board mutation performed: {0}" -f $result.BoardMutationPerformed)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
