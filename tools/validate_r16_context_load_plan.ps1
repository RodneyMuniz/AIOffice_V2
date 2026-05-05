[CmdletBinding()]
param(
    [string]$Path = "state\context\r16_context_load_plan.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextLoadPlanner.psm1") -Force -PassThru
$testPlan = $module.ExportedCommands["Test-R16ContextLoadPlan"]

try {
    $result = & $testPlan -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 context-load plan '{0}' is valid; active_through={1}, planned_range={2}..{3}, load_groups={4}, load_items={5}, verdict={6}; no context budget estimator, no over-budget fail-closed validator, no role-run envelope, no RACI transition gate, no handoff packet, no workflow drill, no runtime memory, no retrieval runtime, no vector search runtime, and no product runtime are claimed." -f $result.PlanId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.LoadGroupCount, $result.LoadItemCount, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 context-load plan is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
