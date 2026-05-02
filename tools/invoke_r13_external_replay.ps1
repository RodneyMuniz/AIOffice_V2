[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
$invoke = $module.ExportedCommands["Invoke-R13ExternalReplayDispatch"]

$result = & $invoke -RequestPath $RequestPath -OutputRoot $OutputRoot
Write-Output ("R13 external replay dispatch result: aggregate verdict '{0}'." -f $result.AggregateVerdict)
Write-Output ("Blocked result: {0}" -f $result.BlockedResultPath)
Write-Output ("Manual dispatch packet: {0}" -f $result.ManualDispatchPacketPath)
Write-Output ("Raw logs: {0}" -f $result.RawLogsPath)
