[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LedgerPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuityLedger.psm1"
Import-Module $modulePath -Force

try {
    $validation = Test-MilestoneContinuityLedgerContract -LedgerPath $LedgerPath
    Write-Output ("VALID: continuity ledger '{0}' stitches cycle '{1}' from segment '{2}' to '{3}'." -f $validation.LedgerId, $validation.CycleId, $validation.InterruptedSegmentId, $validation.SuccessorSegmentId)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
