[CmdletBinding()]
param(
    [string]$OutputPath = "state/control_room/r12_current/control_room_status.json",
    [string]$CompletedThroughTask = "R12-017",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ControlRoomStatus.psm1") -Force -PassThru
$newStatus = $module.ExportedCommands["New-ControlRoomStatus"]

& $newStatus `
    -OutputPath $OutputPath `
    -CompletedThroughTask $CompletedThroughTask `
    -Overwrite:$Overwrite
