$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17Cycle2DevExecution.psm1"
Import-Module $modulePath -Force

$result = Test-R17Cycle2DevExecution -RepositoryRoot $repoRoot

Write-Output "R17-024 Cycle 2 Developer/Codex execution package validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Cycle id: {0}" -f $result.CycleId)
Write-Output ("Card id: {0}" -f $result.CardId)
Write-Output ("A2A message candidates: {0}" -f $result.MessageCount)
Write-Output ("Handoff candidates: {0}" -f $result.HandoffCount)
Write-Output ("Dispatch refs: {0}" -f $result.DispatchRefCount)
Write-Output ("Tool-call refs: {0}" -f $result.ToolCallRefCount)
Write-Output ("Invocation refs: {0}" -f $result.InvocationRefCount)
Write-Output ("Control refs: {0}" -f $result.ControlRefCount)
Write-Output ("Board events: {0}" -f $result.BoardEventCount)
Write-Output ("Final lane: {0}" -f $result.FinalLane)
Write-Output ("Live cycle runtime implemented: {0}" -f $result.LiveCycleRuntimeImplemented)
Write-Output ("Live Orchestrator runtime invoked: {0}" -f $result.LiveOrchestratorRuntimeInvoked)
Write-Output ("Live Developer agent invoked: {0}" -f $result.LiveDeveloperAgentInvoked)
Write-Output ("Live Codex executor adapter invoked: {0}" -f $result.LiveCodexExecutorAdapterInvoked)
Write-Output ("Codex executor invoked by product runtime: {0}" -f $result.CodexExecutorInvokedByProductRuntime)
Write-Output ("Live A2A dispatch performed: {0}" -f $result.LiveA2aDispatchPerformed)
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("Adapter runtime invoked: {0}" -f $result.AdapterRuntimeInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Live board mutation performed: {0}" -f $result.LiveBoardMutationPerformed)
Write-Output ("Runtime card creation performed: {0}" -f $result.RuntimeCardCreationPerformed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("External audit acceptance claimed: {0}" -f $result.ExternalAuditAcceptanceClaimed)
Write-Output ("Autonomous agent executed: {0}" -f $result.AutonomousAgentExecuted)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
Write-Output ("No manual prompt transfer claimed: {0}" -f $result.NoManualPromptTransferClaimed)
