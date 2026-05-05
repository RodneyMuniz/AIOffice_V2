[CmdletBinding()]
param(
    [string]$OutputPath = "state\memory\r16_memory_pack_validation_report.json",
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
$newReport = $module.ExportedCommands["New-R16MemoryPackValidationReport"]

try {
    $result = & $newReport -OutputPath $OutputPath -MemoryLayersPath $MemoryLayersPath -RoleModelPath $RoleModelPath -RolePacksPath $RolePacksPath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 memory pack validation report emitted to '{0}' with aggregate_verdict={1}, roles={2}, memory_layer_types={3}, exact_refs={4}, accepted_stale_caveats={5}; report is a committed state artifact only, not runtime memory, not an artifact map, not an audit map, and not workflow execution." -f $result.OutputPath, $result.AggregateVerdict, $result.RolePackCount, $result.MemoryLayerTypeCount, $result.ExactInspectedRefCount, $result.AcceptedStaleCaveatCount)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 memory pack validation report generation failed. {0}" -f $_.Exception.Message)
    exit 1
}
