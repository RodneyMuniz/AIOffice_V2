[CmdletBinding()]
param(
    [string]$ControlRoomStatusPath = "state/control_room/r12_current/control_room_status.json",
    [string]$OutputPath = "state/control_room/r12_current/operator_decision_queue.json",
    [string]$MarkdownOutputPath = "state/control_room/r12_current/operator_decision_queue.md",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "OperatorDecisionQueue.psm1") -Force -PassThru
$newQueue = $module.ExportedCommands["New-OperatorDecisionQueue"]

& $newQueue `
    -ControlRoomStatusPath $ControlRoomStatusPath `
    -OutputPath $OutputPath `
    -MarkdownOutputPath $MarkdownOutputPath `
    -Overwrite:$Overwrite
