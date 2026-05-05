[CmdletBinding()]
param(
    [string]$OutputPath = "state\artifacts\r16_artifact_map.json",
    [string]$RepositoryRoot,
    [string]$ContractPath = "contracts\artifacts\r16_artifact_map.contract.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapGenerator.psm1") -Force -PassThru
$newMap = $module.ExportedCommands["New-R16ArtifactMap"]

try {
    $result = & $newMap -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot -ContractPath $ContractPath
    Write-Output ("GENERATED: R16 artifact map '{0}' with records={1}, relationships={2}, required_paths={3}, active_through={4}, planned_range={5}..{6}, verdict={7}." -f $result.OutputPath, $result.RecordCount, $result.RelationshipCount, $result.RequiredPathCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 artifact map generation failed. {0}" -f $_.Exception.Message)
    exit 1
}
