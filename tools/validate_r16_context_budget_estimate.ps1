[CmdletBinding()]
param(
    [string]$Path = "state\context\r16_context_budget_estimate.json",
    [string]$ContractPath = "contracts\context\r16_context_budget_estimate.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextBudgetEstimator.psm1") -Force -PassThru
$testEstimate = $module.ExportedCommands["Test-R16ContextBudgetEstimate"]

try {
    $result = & $testEstimate -Path $Path -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 context budget estimate '{0}' is valid; active_through={1}, planned_range={2}..{3}, load_items={4}, exact_files={5}, bytes={6}, lines={7}, approximate_tokens={8}..{9}, budget_category={10}, verdict={11}; no exact provider token count, no exact provider billing, no over-budget fail-closed validator, no role-run envelope, no RACI transition gate, no handoff packet, no workflow drill, no runtime memory, no retrieval runtime, no vector search runtime, no product runtime, no autonomous agents, and no external integrations are claimed." -f $result.EstimateId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.LoadItemCount, $result.ExactFileCount, $result.TotalBytes, $result.TotalLines, $result.EstimatedTokensLowerBound, $result.EstimatedTokensUpperBound, $result.BudgetCategory, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 context budget estimate is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
