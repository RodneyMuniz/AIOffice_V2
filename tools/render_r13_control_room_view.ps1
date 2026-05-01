[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StatusPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
$exportView = $module.ExportedCommands["Export-R13ControlRoomView"]

$result = & $exportView -StatusPath $StatusPath -OutputPath $OutputPath
Write-Output ("Rendered R13 control-room view '{0}' from status '{1}' with {2} required sections." -f $result.ViewPath, $result.SourceStatusRef, $result.SectionCount)
