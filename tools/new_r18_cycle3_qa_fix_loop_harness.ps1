$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle3QaFixLoopHarness.psm1"
Import-Module $modulePath -Force

$result = New-R18Cycle3QaFixLoopHarnessArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-025 Cycle 3 QA/fix-loop compact-safe harness evidence package generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Work-order records: {0}" -f $result.WorkOrderRecordCount)
Write-Output ("Validator run log entries: {0}" -f $result.ValidatorRunLogEntryCount)
Write-Output ("Board event records: {0}" -f $result.BoardEventCount)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic bounded harness evidence only; no Codex/OpenAI API invocation, live agent, live skill, tool-call execution, A2A message dispatch, live board/card runtime mutation, live Kanban UI, recovery action, release gate execution, CI replay, product runtime, four-cycle claim, solved compaction/reliability, or no-manual-prompt-transfer success is claimed."
