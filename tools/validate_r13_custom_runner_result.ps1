[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13CustomRunner.psm1") -Force -PassThru
$testResult = $module.ExportedCommands["Test-R13CustomRunnerResult"]

$validation = & $testResult -ResultPath $ResultPath
Write-Output ("VALID: R13 custom runner result '{0}' for request '{1}' operation '{2}', command count {3}, passed {4}, failed {5}, blocked {6}, aggregate verdict '{7}'." -f $validation.ResultId, $validation.RequestId, $validation.RequestedOperation, $validation.CommandCount, $validation.PassedCommandCount, $validation.FailedCommandCount, $validation.BlockedCommandCount, $validation.AggregateVerdict)
