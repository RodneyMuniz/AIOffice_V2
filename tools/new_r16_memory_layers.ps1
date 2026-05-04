[CmdletBinding()]
param(
    [string]$OutputPath = "state\memory\r16_memory_layers.json",
    [string]$ContractPath = "contracts\memory\r16_memory_layer.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerGenerator.psm1") -Force -PassThru
$newMemoryLayers = $module.ExportedCommands["New-R16MemoryLayers"]

try {
    $result = & $newMemoryLayers -OutputPath $OutputPath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 baseline memory layers wrote '{0}' with {1} layer records from head {2} tree {3}. Generated baseline memory layers are committed state artifacts, not runtime memory." -f $result.OutputPath, $result.LayerCount, $result.GeneratedFromHead, $result.GeneratedFromTree)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 memory layer generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
