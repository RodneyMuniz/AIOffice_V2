[CmdletBinding()]
param(
    [string]$Path = "state\artifacts\r16_artifact_map.json",
    [string]$RepositoryRoot,
    [string]$ContractPath = "contracts\artifacts\r16_artifact_map.contract.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapGenerator.psm1") -Force -PassThru
$testMap = $module.ExportedCommands["Test-R16ArtifactMap"]

try {
    $result = & $testMap -Path $Path -RepositoryRoot $RepositoryRoot -ContractPath $ContractPath
    Write-Output ("VALID: R16 artifact map '{0}' passed with records={1}, relationships={2}, required_paths={3}, active_through={4}, planned_range={5}..{6}; generated map is a committed state artifact only, not runtime memory, audit map, context-load planner, or workflow execution." -f $result.ArtifactMapId, $result.RecordCount, $result.RelationshipCount, $result.RequiredPathCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 artifact map failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
