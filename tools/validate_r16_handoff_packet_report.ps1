[CmdletBinding()]
param(
    [string]$Path = "state\workflow\r16_handoff_packet_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16HandoffPacketGenerator.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16HandoffPacketReport"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 handoff packet report '{0}' is valid; active_through={1}, planned_range={2}..{3}, packets={4}, blocked={5}, executable={6}, aggregate_verdict={7}, guard_verdict={8}, estimated_tokens_upper_bound={9}, max_estimated_tokens_upper_bound={10}. This is bounded state-artifact validation only; no executable handoffs, workflow drill, runtime handoff execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, or external integrations are claimed." -f $result.HandoffPacketReportId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.HandoffPacketCount, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.AggregateVerdict, $result.BudgetGuardVerdict, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 handoff packet report is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
