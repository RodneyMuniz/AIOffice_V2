[CmdletBinding()]
param(
    [string]$OutputPath = "state\memory\r16_role_memory_packs.json",
    [string]$ModelPath = "state\memory\r16_role_memory_pack_model.json",
    [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackGenerator.psm1") -Force -PassThru
$newRoleMemoryPacks = $module.ExportedCommands["New-R16RoleMemoryPacks"]

try {
    $result = & $newRoleMemoryPacks -OutputPath $OutputPath -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 baseline role memory packs wrote '{0}' with {1} role packs from head {2} tree {3}. Generated baseline role memory packs are committed state artifacts, not runtime memory, not actual agents, and not workflow execution." -f $result.OutputPath, $result.RoleCount, $result.GeneratedFromHead, $result.GeneratedFromTree)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 role memory pack generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
