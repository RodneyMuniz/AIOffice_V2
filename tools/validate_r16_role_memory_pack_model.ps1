[CmdletBinding()]
param(
    [string]$ModelPath = "state\memory\r16_role_memory_pack_model.json",
    [string]$ContractPath = "contracts\memory\r16_role_memory_pack_model.contract.json",
    [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = Split-Path -Parent $RepositoryRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackModel.psm1") -Force -PassThru
$testModel = $module.ExportedCommands["Test-R16RoleMemoryPackModel"]

$validation = & $testModel -ModelPath $ModelPath -ContractPath $ContractPath -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot

Write-Output ("VALID: R16 role-specific memory pack model '{0}' defines {1} exact roles, references {2} known R16 memory layer types from '{3}', remains model-only through {4}, keeps R16-007 through R16-026 planned only, and claims no generated role memory packs, role memory pack generator, runtime memory loading, persistent memory runtime, retrieval/vector runtime, actual agents, true multi-agent execution, external integrations, artifact maps, context-load planner, R16-027+ task, or R13/R14/R15 boundary change." -f $ModelPath, $validation.RoleCount, $validation.KnownMemoryLayerTypes.Count, $MemoryLayersPath, $validation.ActiveThroughTask)
