$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentInvocationLog.psm1"
Import-Module $modulePath -Force

$result = Test-R17AgentInvocationLog -RepositoryRoot $repoRoot

Write-Output "R17-014 agent invocation log validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Total invocation records: {0}" -f $result.TotalInvocationRecords)
Write-Output ("Known agent count: {0}" -f @($result.KnownAgentIds).Count)
Write-Output ("Actual agent invoked: {0}" -f $result.ActualAgentInvoked)
Write-Output ("Runtime dispatch performed: {0}" -f $result.RuntimeDispatchPerformed)
Write-Output ("Adapter call performed: {0}" -f $result.AdapterCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
