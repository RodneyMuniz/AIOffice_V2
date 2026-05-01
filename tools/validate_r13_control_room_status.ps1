[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StatusPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ControlRoomStatus"]

$result = & $validate -StatusPath $StatusPath
Write-Output ("VALID: R13 control-room status '{0}', completed tasks {1}, planned tasks {2}, blockers {3}, next legal action {4}." -f $result.StatusId, $result.CompletedTaskCount, $result.PlannedTaskCount, $result.BlockerCount, $result.NextLegalAction)
