[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MemoryLayersPath,
    [Parameter(Mandatory = $true)]
    [string]$ContractPath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerGenerator.psm1") -Force -PassThru
$testMemoryLayers = $module.ExportedCommands["Test-R16MemoryLayers"]

try {
    $result = & $testMemoryLayers -MemoryLayersPath $MemoryLayersPath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 memory layers '{0}' passed with {1} layer records, active_through={2}, planned_range={3}..{4}; generated baseline memory layers are state artifacts, not runtime memory." -f $result.ArtifactId, $result.LayerCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 memory layers failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
