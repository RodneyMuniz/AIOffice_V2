[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerContract.psm1") -Force -PassThru
$testExternalRunnerRequest = $module.ExportedCommands["Test-ExternalRunnerRequestContract"]

$validation = & $testExternalRunnerRequest -RequestPath $RequestPath
Write-Output ("VALID: external runner request '{0}' targets branch '{1}' at head '{2}' tree '{3}' with {4} command(s), dispatch mode '{5}', and runner kind '{6}'." -f $validation.RequestId, $validation.Branch, $validation.RequestedHead, $validation.RequestedTree, $validation.CommandCount, $validation.DispatchMode, $validation.RunnerKind)
