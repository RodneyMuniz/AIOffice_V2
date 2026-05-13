$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentToolCallEvidence.psm1"
Import-Module $modulePath -Force

$result = Test-R18AgentToolCallEvidence -RepositoryRoot $repoRoot

Write-Output "R18-021 agent invocation and tool-call evidence model validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Ledger record count: {0}" -f $result.RecordCount)
Write-Output ("Planned records: {0}" -f $result.CallModeCounts.planned)
Write-Output ("Dry-run records: {0}" -f $result.CallModeCounts.dry_run)
Write-Output ("Failed records: {0}" -f $result.CallModeCounts.failed)
Write-Output ("Live-approved seeded records: {0}" -f $result.CallModeCounts.live_approved)
Write-Output ("Tool-call execution performed: {0}" -f $result.RuntimeFlags.tool_call_execution_performed)
Write-Output ("Live agent runtime invoked: {0}" -f $result.RuntimeFlags.live_agent_runtime_invoked)
