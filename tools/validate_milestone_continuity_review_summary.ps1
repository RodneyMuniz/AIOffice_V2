[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ReviewSummaryPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuityReview.psm1"
Import-Module $modulePath -Force

try {
    $validation = Test-MilestoneContinuityReviewSummaryContract -ReviewSummaryPath $ReviewSummaryPath
    Write-Output ("VALID: continuity review summary '{0}' remains advisory for cycle '{1}'." -f $validation.ReviewSummaryId, $validation.CycleId)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
