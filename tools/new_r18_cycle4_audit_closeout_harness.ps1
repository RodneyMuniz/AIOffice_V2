$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle4AuditCloseoutHarness.psm1"
Import-Module $modulePath -Force

$result = New-R18Cycle4AuditCloseoutHarnessArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-026 Cycle 4 audit/closeout compact-safe harness evidence package generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Machine-readable evidence inventory entries: {0}" -f $result.EvidenceInventoryCount)
Write-Output ("Validator run log entries: {0}" -f $result.ValidatorRunLogEntryCount)
Write-Output ("Board event records: {0}" -f $result.BoardEventCount)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic bounded harness evidence only; no external audit acceptance, main merge, milestone closeout, closeout without operator approval, release gate execution, CI replay, GitHub Actions workflow creation/run, Codex/OpenAI API invocation, live agent, live skill, tool-call execution, A2A message dispatch, board/card runtime mutation, product runtime, solved compaction/reliability, or no-manual-prompt-transfer success is claimed."
