[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ContinuityLedgerPath,
    [Parameter(Mandatory = $true)]
    [string]$RollbackPlanPath,
    [Parameter(Mandatory = $true)]
    [string]$RollbackDrillResultPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuityReview.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-MilestoneContinuityAdvisoryReviewFlow -ContinuityLedgerPath $ContinuityLedgerPath -RollbackPlanPath $RollbackPlanPath -RollbackDrillResultPath $RollbackDrillResultPath -OutputRoot $OutputRoot
    Write-Output ("PREPARED: continuity review summary '{0}' and operator packet '{1}'." -f $result.ReviewSummaryId, $result.OperatorPacketId)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
