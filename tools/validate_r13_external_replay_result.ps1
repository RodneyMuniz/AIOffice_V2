[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ExternalReplayResult"]

$result = & $validate -ResultPath $ResultPath
Write-Output ("VALID: R13 external replay result '{0}', request '{1}', aggregate verdict '{2}', run '{3}', artifact '{4}', commands {5}, passed {6}, failed {7}, blocked {8}." -f $result.ResultId, $result.RequestId, $result.AggregateVerdict, $result.RunId, $result.ArtifactId, $result.CommandCount, $result.PassedCommandCount, $result.FailedCommandCount, $result.BlockedCommandCount)
