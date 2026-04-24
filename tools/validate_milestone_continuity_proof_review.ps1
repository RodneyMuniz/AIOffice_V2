[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackageRoot
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuityProofReview.psm1") -Force -PassThru
$testProofReviewPackage = $proofReviewModule.ExportedCommands["Test-MilestoneContinuityProofReviewPackage"]

$validation = & $testProofReviewPackage -PackageRoot $PackageRoot
Write-Output ("VALID: R7 proof-review package '{0}' replays source head '{1}' tree '{2}'." -f $validation.PackageRoot, $validation.ReplaySourceHeadCommit, $validation.ReplaySourceTreeId)
