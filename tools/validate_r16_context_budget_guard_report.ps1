[CmdletBinding()]
param(
    [string]$Path = "state\context\r16_context_budget_guard_report.json",
    [string]$ContractPath = "contracts\context\r16_context_budget_guard.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextBudgetGuard.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16ContextBudgetGuardReport"]

try {
    $result = & $testReport -Path $Path -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 context budget guard report '{0}' is valid; active_through={1}, planned_range={2}..{3}, evaluated_load_items={4}, approximate_upper_bound={5}, threshold={6}, threshold_exceeded={7}, over_budget_findings={8}, policy_violations={9}, verdict={10}. The report is deterministic/local only, uses no provider tokenizer or provider pricing, and does not claim runtime memory, retrieval runtime, vector search runtime, product runtime, autonomous agents, external integrations, solved Codex compaction, or solved Codex reliability." -f $result.GuardId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.EvaluatedLoadItemCount, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound, $result.ThresholdExceeded, $result.OverBudgetCount, $result.PolicyViolationCount, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 context budget guard report is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
