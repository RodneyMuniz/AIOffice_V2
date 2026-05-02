[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ExternalReplayRequest"]

$result = & $validate -RequestPath $RequestPath
Write-Output ("VALID: R13 external replay request '{0}', branch '{1}', head '{2}', tree '{3}', inputs {4}, commands {5}, scope '{6}'." -f $result.RequestId, $result.Branch, $result.Head, $result.Tree, $result.InputRefCount, $result.CommandCount, $result.ReplayScope)
