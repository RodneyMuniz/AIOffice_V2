[CmdletBinding()]
param(
    [string]$Path = "state\workflow\r16_raci_transition_gate_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RaciTransitionGate.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16RaciTransitionGateReport"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 RACI transition gate report '{0}' is valid; active_through={1}, planned_range={2}..{3}, transitions={4}, blocked={5}, allowed={6}, aggregate_verdict={7}, guard_verdict={8}, estimated_tokens_upper_bound={9}, max_estimated_tokens_upper_bound={10}. This is bounded local gate validation/reporting only; no executable transition, handoff packet, workflow drill, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, or external integrations are claimed." -f $result.GateId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.TransitionCount, $result.BlockedTransitionCount, $result.AllowedTransitionCount, $result.AggregateVerdict, $result.BudgetGuardVerdict, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 RACI transition gate report is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
