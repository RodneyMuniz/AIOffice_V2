[CmdletBinding()]
param(
    [string]$OutputPath = "state\workflow\r16_handoff_packet_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16HandoffPacketGenerator.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16HandoffPacketReport"]

try {
    $result = & $newReport -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 handoff packet report '{0}' wrote '{1}' with packets={2}, blocked={3}, executable={4}, active_through={5}, planned_range={6}..{7}, aggregate_verdict={8}, guard_verdict={9}, estimated_tokens_upper_bound={10}, max_estimated_tokens_upper_bound={11}. Candidate handoffs are state artifacts only and remain blocked by the R16-020 gate plus failed_closed_over_budget; no workflow drill, runtime handoff execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, or external integrations are claimed." -f $result.HandoffPacketReportId, $result.OutputPath, $result.HandoffPacketCount, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.BudgetGuardVerdict, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 handoff packet generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
