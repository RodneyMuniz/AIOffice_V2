[CmdletBinding()]
param(
    [string]$ReportPath = "state\memory\r16_memory_pack_validation_report.json",
    [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
    [string]$RoleModelPath = "state\memory\r16_role_memory_pack_model.json",
    [string]$RolePacksPath = "state\memory\r16_role_memory_packs.json",
    [string]$ContractPath = "contracts\memory\r16_memory_pack_validation_report.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16MemoryPackValidation.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16MemoryPackValidationReport"]

try {
    $result = & $testReport -ReportPath $ReportPath -MemoryLayersPath $MemoryLayersPath -RoleModelPath $RoleModelPath -RolePacksPath $RolePacksPath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 memory pack validation report passed with aggregate_verdict={0}, roles={1}, memory_layer_types={2}, exact_refs={3}, accepted_stale_caveats={4}, active_through={5}, planned_range={6}..{7}." -f $result.AggregateVerdict, $result.RolePackCount, $result.MemoryLayerTypeCount, $result.ExactInspectedRefCount, $result.AcceptedStaleCaveatCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 memory pack validation report failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
