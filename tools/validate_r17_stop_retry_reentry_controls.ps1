$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17StopRetryReentryControls.psm1"
Import-Module $modulePath -Force

$result = Test-R17StopRetryReentryControls -RepositoryRoot $repoRoot

Write-Output "R17-022 stop/retry/pause/block/re-entry controls foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Control packets: {0}" -f $result.ControlPacketCount)
Write-Output ("Re-entry packets: {0}" -f $result.ReentryPacketCount)
Write-Output ("Control runtime implemented: {0}" -f $result.ControlRuntimeImplemented)
Write-Output ("Live stop performed: {0}" -f $result.LiveStopPerformed)
Write-Output ("Live retry performed: {0}" -f $result.LiveRetryPerformed)
Write-Output ("Live pause performed: {0}" -f $result.LivePausePerformed)
Write-Output ("Live block performed: {0}" -f $result.LiveBlockPerformed)
Write-Output ("Live re-entry performed: {0}" -f $result.LiveReentryPerformed)
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("Live A2A dispatch performed: {0}" -f $result.LiveA2aDispatchPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("Live agent runtime invoked: {0}" -f $result.LiveAgentRuntimeInvoked)
Write-Output ("Live Orchestrator runtime invoked: {0}" -f $result.LiveOrchestratorRuntimeInvoked)
Write-Output ("Adapter runtime invoked: {0}" -f $result.AdapterRuntimeInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Board mutation performed: {0}" -f $result.BoardMutationPerformed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("External audit acceptance claimed: {0}" -f $result.ExternalAuditAcceptanceClaimed)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
