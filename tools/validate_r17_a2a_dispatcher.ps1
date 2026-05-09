$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17A2aDispatcher.psm1"
Import-Module $modulePath -Force

$result = Test-R17A2aDispatcher -RepositoryRoot $repoRoot

Write-Output "R17-021 bounded A2A dispatcher foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Dispatch candidates: {0}" -f $result.RouteCount)
Write-Output ("Valid seed routes not dispatched: {0}" -f $result.ValidSeedRouteCount)
Write-Output ("Blocked routes: {0}" -f $result.BlockedRouteCount)
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("A2A dispatcher runtime implemented: {0}" -f $result.A2aDispatcherRuntimeImplemented)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("Live agent runtime invoked: {0}" -f $result.LiveAgentRuntimeInvoked)
Write-Output ("Live Orchestrator runtime invoked: {0}" -f $result.LiveOrchestratorRuntimeInvoked)
Write-Output ("Adapter runtime invoked: {0}" -f $result.AdapterRuntimeInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Board mutation performed: {0}" -f $result.BoardMutationPerformed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
