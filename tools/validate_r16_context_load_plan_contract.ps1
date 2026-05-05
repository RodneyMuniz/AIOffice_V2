[CmdletBinding()]
param(
    [string]$Path = "contracts\context\r16_context_load_plan.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextLoadPlanContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16ContextLoadPlanContract"]

try {
    $result = & $testContract -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 context-load plan contract '{0}' is valid; active_through={1}, planned_range={2}..{3}, dependency_refs={4}; contract-only with no generated context-load plan, no context-load planner, no context budget estimator, no over-budget fail-closed validator, no runtime memory, and no product runtime." -f $result.ContractId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.DependencyRefCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 context-load plan contract is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
