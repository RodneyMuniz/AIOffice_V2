[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [string]$ExpectedResultRef = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
$newRequest = $module.ExportedCommands["New-R13ExternalReplayRequestObject"]
$writeJson = $module.ExportedCommands["Write-R13ExternalReplayJsonFile"]
$validate = $module.ExportedCommands["Test-R13ExternalReplayRequestObject"]

$request = & $newRequest -ExpectedResultRef $ExpectedResultRef
& $validate -Request $request -SourceLabel "generated R13 external replay request" | Out-Null
& $writeJson -Path $OutputPath -Value $request
Write-Output ("WROTE: R13 external replay request '{0}' for head '{1}' tree '{2}'." -f $OutputPath, $request.head, $request.tree)
