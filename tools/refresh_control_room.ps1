[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    [Parameter(Mandatory = $true)]
    [string]$Branch,
    [Parameter(Mandatory = $true)]
    [string]$Head,
    [Parameter(Mandatory = $true)]
    [string]$Tree,
    [string]$StatusOutputPath = "state/control_room/r12_current/control_room_status.json",
    [string]$ViewOutputPath = "state/control_room/r12_current/control_room.md",
    [string]$DecisionQueueOutputPath = "state/control_room/r12_current/operator_decision_queue.json",
    [string]$DecisionQueueViewOutputPath = "state/control_room/r12_current/operator_decision_queue.md",
    [string]$RefreshResultOutputPath = "state/control_room/r12_current/control_room_refresh_result.json",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ControlRoomRefresh.psm1") -Force -PassThru
$refresh = $module.ExportedCommands["Invoke-ControlRoomRefresh"]

& $refresh `
    -Repository $Repository `
    -Branch $Branch `
    -Head $Head `
    -Tree $Tree `
    -StatusOutputPath $StatusOutputPath `
    -ViewOutputPath $ViewOutputPath `
    -DecisionQueueOutputPath $DecisionQueueOutputPath `
    -DecisionQueueViewOutputPath $DecisionQueueViewOutputPath `
    -RefreshResultOutputPath $RefreshResultOutputPath `
    -Overwrite:$Overwrite
