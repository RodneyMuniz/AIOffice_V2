$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17A2aContracts.psm1"
Import-Module $modulePath -Force

$result = Test-R17A2aContracts -RepositoryRoot $repoRoot

Write-Output "R17-020 A2A message and handoff contract foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Message seed packets: {0}" -f $result.MessageCount)
Write-Output ("Handoff seed packets: {0}" -f $result.HandoffCount)
Write-Output ("Message types: {0}" -f (@($result.MessageTypes) -join ", "))
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("A2A dispatcher implemented: {0}" -f $result.A2aDispatcherImplemented)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("A2A message dispatched: {0}" -f $result.A2aMessageDispatched)
Write-Output ("Agent invocation performed: {0}" -f $result.AgentInvocationPerformed)
Write-Output ("Adapter runtime invoked: {0}" -f $result.AdapterRuntimeInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Board mutation performed: {0}" -f $result.BoardMutationPerformed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
