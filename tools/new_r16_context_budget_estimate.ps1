[CmdletBinding()]
param(
    [string]$OutputPath = "state\context\r16_context_budget_estimate.json",
    [string]$ContextLoadPlanPath = "state\context\r16_context_load_plan.json",
    [string]$ContractPath = "contracts\context\r16_context_budget_estimate.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextBudgetEstimator.psm1") -Force -PassThru
$newEstimate = $module.ExportedCommands["New-R16ContextBudgetEstimate"]

try {
    $result = & $newEstimate -OutputPath $OutputPath -ContextLoadPlanPath $ContextLoadPlanPath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 context budget estimate '{0}' wrote '{1}' with {2} exact files, {3} approximate token range {4}..{5}, budget_category={6}, active_through={7}, planned_range={8}..{9}, verdict={10}. Token and cost proxy values are approximations only, not exact provider tokenization and not exact provider billing; no over-budget fail-closed validator, role-run envelope, RACI transition gate, handoff packet, or workflow drill is claimed." -f $result.EstimateId, $result.OutputPath, $result.ExactFileCount, $result.LoadItemCount, $result.EstimatedTokensLowerBound, $result.EstimatedTokensUpperBound, $result.BudgetCategory, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 context budget estimate generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
