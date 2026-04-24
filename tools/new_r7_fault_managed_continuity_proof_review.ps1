[CmdletBinding()]
param(
    [string]$OutputRoot = "state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill",
    [string]$ScenarioId = "r7-fault-managed-continuity-and-rollback-drill-proof-001"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuityProofReview.psm1") -Force -PassThru
$invokeProofReviewFlow = $proofReviewModule.ExportedCommands["Invoke-MilestoneContinuityProofReviewFlow"]

$result = & $invokeProofReviewFlow -RepositoryRoot $repoRoot -OutputRoot $OutputRoot -ScenarioId $ScenarioId
Write-Output ("PASS: R7 fault-managed continuity proof review created at '{0}'." -f $result.PackageRoot)
Write-Output ("Replay source head: {0}" -f $result.ReplaySourceHeadCommit)
Write-Output ("Replay source tree: {0}" -f $result.ReplaySourceTreeId)
