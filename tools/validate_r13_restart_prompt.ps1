[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PromptPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13CompactionMitigation.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13RestartPrompt"]

$result = & $validate -PromptPath $PromptPath
Write-Output ("VALID: R13 restart prompt '{0}' at '{1}' with {2} required checks." -f $result.PromptId, $result.PromptPath, $result.RequiredCheckCount)
