[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LifecyclePath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaLifecycle.psm1") -Force -PassThru
$testLifecycle = $module.ExportedCommands["Test-R13QaLifecycle"]

$validation = & $testLifecycle -LifecyclePath $LifecyclePath
Write-Output ("VALID: R13 QA lifecycle '{0}' is in stage '{1}' with aggregate verdict '{2}' and {3} evidence ref(s)." -f $validation.LifecycleId, $validation.Stage, $validation.AggregateVerdict, $validation.EvidenceRefCount)
