[CmdletBinding()]
param(
    [string]$Path = "contracts\audit\r16_audit_map.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16AuditMapContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16AuditMapContract"]

try {
    $result = & $testContract -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 audit map contract '{0}' is valid; active_through={1}, planned_range={2}..{3}, dependency_refs={4}; contract-only with no generated audit map, no audit map generator, no R15/R16 audit map, no runtime memory, and no product runtime." -f $result.ContractId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.DependencyRefCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 audit map contract is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
