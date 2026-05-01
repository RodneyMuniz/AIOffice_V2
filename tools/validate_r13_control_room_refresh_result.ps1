[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RefreshResultPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ControlRoomRefreshResult"]

$result = & $validate -RefreshResultPath $RefreshResultPath
Write-Output ("VALID: R13 control-room refresh result '{0}', verdict {1}, blockers {2}, next actions {3}." -f $result.RefreshId, $result.RefreshVerdict, $result.BlockerCount, $result.NextActionCount)
