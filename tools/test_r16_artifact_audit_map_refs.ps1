[CmdletBinding()]
param(
    [string]$ArtifactMapPath = "state\artifacts\r16_artifact_map.json",
    [string]$AuditMapPath = "state\audit\r16_r15_r16_audit_map.json",
    [string]$ContractPath = "contracts\artifacts\r16_artifact_audit_map_check_report.contract.json",
    [string]$OutputPath = "state\artifacts\r16_artifact_audit_map_check_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ArtifactAuditMapCheck.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16ArtifactAuditMapCheckReport"]

try {
    $result = & $newReport -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -ContractPath $ContractPath -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16-013 artifact/audit map check report '{0}' generated with findings={1}, warnings={2}, verdict={3}, active_through={4}, planned_range={5}..{6}." -f $result.OutputPath, $result.FindingCount, $result.WarningCount, $result.AggregateVerdict, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("FAIL: R16-013 artifact/audit map check failed. {0}" -f $_.Exception.Message)
    exit 1
}
