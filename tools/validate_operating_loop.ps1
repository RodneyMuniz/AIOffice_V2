[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LoopPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "OperatingLoop.psm1") -Force -PassThru
$testOperatingLoop = $module.ExportedCommands["Test-OperatingLoopContract"]

$validation = & $testOperatingLoop -LoopPath $LoopPath
Write-Output ("VALID: R12 operating loop '{0}' is in state '{1}' with {2} transition(s) and {3} required evidence ref(s)." -f $validation.LoopId, $validation.State, $validation.TransitionCount, $validation.RequiredEvidenceRefCount)
