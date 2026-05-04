[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16PlanningAuthorityReference.psm1") -Force -PassThru
$testReference = $module.ExportedCommands["Test-R16PlanningAuthorityReference"]

try {
    $result = & $testReference -PacketPath $PacketPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 planning authority reference packet '{0}' passed with {1} operator-approved planning artifacts, active_through={2}, planned_range={3}..{4}, planning_reports_implementation_proof={5}." -f $result.ReferencePacketId, $result.PlanningArtifactCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.PlanningReportsImplementationProof)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 planning authority reference packet failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
