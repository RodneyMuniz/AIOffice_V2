[CmdletBinding()]
param(
    [string]$Path = "state\artifacts\r16_artifact_audit_map_check_report.json",
    [string]$RepositoryRoot,
    [string]$ContractPath = "contracts\artifacts\r16_artifact_audit_map_check_report.contract.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ArtifactAuditMapCheck.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16ArtifactAuditMapCheckReport"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot -ContractPath $ContractPath
    Write-Output ("PASS: R16-013 artifact/audit map check report '{0}' is valid with findings={1}, warnings={2}, verdict={3}, active_through={4}, planned_range={5}..{6}." -f $Path, $result.FindingCount, $result.WarningCount, $result.AggregateVerdict, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("FAIL: R16-013 artifact/audit map check report '{0}' is invalid. {1}" -f $Path, $_.Exception.Message)
    exit 1
}
