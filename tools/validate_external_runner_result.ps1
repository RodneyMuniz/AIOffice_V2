[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerContract.psm1") -Force -PassThru
$testExternalRunnerResult = $module.ExportedCommands["Test-ExternalRunnerResultContract"]

$validation = & $testExternalRunnerResult -ResultPath $ResultPath
$posture = if ($validation.SuccessfulExternalEvidenceShape) { "successful external evidence shape" } else { "non-passing external runner result shape" }
Write-Output ("VALID: external runner result '{0}' for request '{1}' records run '{2}' with status '{3}', conclusion '{4}', {5} command(s), and {6}." -f $validation.ResultId, $validation.RequestId, $validation.RunId, $validation.Status, $validation.Conclusion, $validation.CommandCount, $posture)
