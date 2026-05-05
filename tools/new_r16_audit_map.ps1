[CmdletBinding()]
param(
    [string]$OutputPath = "state\audit\r16_r15_r16_audit_map.json",
    [string]$RepositoryRoot,
    [string]$ContractPath = "contracts\audit\r16_audit_map.contract.json",
    [string]$ArtifactMapPath = "state\artifacts\r16_artifact_map.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16AuditMapGenerator.psm1") -Force -PassThru
$newMap = $module.ExportedCommands["New-R16AuditMap"]

try {
    $result = & $newMap -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot -ContractPath $ContractPath -ArtifactMapPath $ArtifactMapPath
    Write-Output ("GENERATED: R16 R15/R16 audit map '{0}' with entries={1}, caveats={2}, required_paths={3}, active_through={4}, planned_range={5}..{6}, verdict={7}." -f $result.OutputPath, $result.EntryCount, $result.CaveatCount, $result.RequiredPathCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 R15/R16 audit map generation failed. {0}" -f $_.Exception.Message)
    exit 1
}
