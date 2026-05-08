$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OperatorIntakeSurface.psm1"
Import-Module $modulePath -Force

$result = Test-R17OperatorIntakeSurface -RepositoryRoot $repoRoot

Write-Output "R17-011 operator intake surface validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Intake ID: {0}" -f $result.IntakeId)
Write-Output ("Proposal ID: {0}" -f $result.ProposalId)
Write-Output ("Recommended card: {0}" -f $result.RecommendedCardId)
Write-Output ("Recommended lane: {0}" -f $result.RecommendedLane)
Write-Output ("Runtime Orchestrator invoked: {0}" -f $result.RuntimeOrchestratorInvoked)
Write-Output ("Board mutation performed: {0}" -f $result.BoardMutationPerformed)
Write-Output ("Card created: {0}" -f $result.CardCreated)
Write-Output ("Agent invocation performed: {0}" -f $result.AgentInvocationPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("API call performed: {0}" -f $result.ApiCallPerformed)
Write-Output ("Dev output claimed: {0}" -f $result.DevOutputClaimed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Audit verdict claimed: {0}" -f $result.AuditVerdictClaimed)
