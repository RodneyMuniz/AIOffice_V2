[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13CustomRunner.psm1") -Force -PassThru
$testRequest = $module.ExportedCommands["Test-R13CustomRunnerRequest"]

$validation = & $testRequest -RequestPath $RequestPath
Write-Output ("VALID: R13 custom runner request '{0}' operation '{1}', command count {2}, input ref count {3}, output root '{4}', expected result '{5}'." -f $validation.RequestId, $validation.RequestedOperation, $validation.CommandCount, $validation.InputRefCount, $validation.OutputRoot, $validation.ExpectedResultRef)
