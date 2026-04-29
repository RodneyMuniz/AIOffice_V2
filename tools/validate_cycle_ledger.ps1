[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LedgerPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "CycleLedger.psm1") -Force -PassThru
$testCycleLedgerContract = $module.ExportedCommands["Test-CycleLedgerContract"]

$validation = & $testCycleLedgerContract -LedgerPath $LedgerPath
Write-Output ("VALID: cycle ledger '{0}' is in state '{1}' with {2} transition(s), head {3}, tree {4}." -f $validation.CycleId, $validation.State, $validation.TransitionCount, $validation.HeadSha, $validation.TreeSha)
