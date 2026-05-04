[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacksPath,
    [Parameter(Mandatory = $true)]
    [string]$ModelPath,
    [Parameter(Mandatory = $true)]
    [string]$MemoryLayersPath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackGenerator.psm1") -Force -PassThru
$testRoleMemoryPacks = $module.ExportedCommands["Test-R16RoleMemoryPacks"]

try {
    $result = & $testRoleMemoryPacks -PacksPath $PacksPath -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 role memory packs '{0}' passed with {1} role packs, active_through={2}, planned_range={3}..{4}; generated baseline role memory packs are committed state artifacts only, not runtime memory, not actual agents, and not workflow execution." -f $result.ArtifactId, $result.RoleCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 role memory packs failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
