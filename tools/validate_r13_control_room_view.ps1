[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ViewPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ControlRoomView"]

$result = & $validate -ViewPath $ViewPath
Write-Output ("VALID: R13 control-room view '{0}' from status '{1}', sections {2}." -f $result.ViewPath, $result.SourceStatusRef, $result.SectionCount)
