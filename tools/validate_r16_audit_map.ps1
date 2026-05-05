[CmdletBinding()]
param(
    [string]$Path = "state\audit\r16_r15_r16_audit_map.json",
    [string]$RepositoryRoot,
    [string]$ContractPath = "contracts\audit\r16_audit_map.contract.json",
    [string]$ArtifactMapPath = "state\artifacts\r16_artifact_map.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16AuditMapGenerator.psm1") -Force -PassThru
$testMap = $module.ExportedCommands["Test-R16AuditMap"]

try {
    $result = & $testMap -Path $Path -RepositoryRoot $RepositoryRoot -ContractPath $ContractPath -ArtifactMapPath $ArtifactMapPath
    Write-Output ("VALID: R16 R15/R16 audit map '{0}' passed with entries={1}, caveats={2}, required_paths={3}, active_through={4}, planned_range={5}..{6}; generated audit map is a committed state artifact only, not runtime memory, product runtime, context-load planner, artifact-map diff/check tooling, or workflow execution." -f $result.AuditMapId, $result.EntryCount, $result.CaveatCount, $result.RequiredPathCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 R15/R16 audit map failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
