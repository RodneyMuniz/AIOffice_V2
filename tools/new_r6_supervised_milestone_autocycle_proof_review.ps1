[CmdletBinding()]
param(
    [string]$OutputRoot = "state/proof_reviews/r6_supervised_milestone_autocycle_pilot",
    [string]$ProposalIntakePath = "state/fixtures/valid/milestone_autocycle/proposal_intake.valid.json",
    [string]$ScenarioId = "r6-supervised-milestone-autocycle-pilot-proof-001",
    [string]$CycleId = "cycle-r6-supervised-milestone-autocycle-pilot-proof-001",
    [string]$OperatorId = "operator:rodney"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleProofReview.psm1"
$proofReviewModule = Import-Module $proofReviewModulePath -Force -PassThru
$invokeProofReviewFlow = $proofReviewModule.ExportedCommands["Invoke-MilestoneAutocycleProofReviewFlow"]

$result = & $invokeProofReviewFlow -OutputRoot $OutputRoot -ProposalIntakePath $ProposalIntakePath -ScenarioId $ScenarioId -CycleId $CycleId -OperatorId $OperatorId
Write-Output ("PASS: R6 supervised milestone autocycle proof review created at '{0}'." -f $result.PackageRoot)
Write-Output ("Replay command: {0}" -f $result.ReplayCommand)
