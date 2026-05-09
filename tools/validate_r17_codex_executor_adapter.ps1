$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CodexExecutorAdapter.psm1"
Import-Module $modulePath -Force

$result = Test-R17CodexExecutorAdapter -RepositoryRoot $repoRoot

Write-Output "R17-016 Codex executor adapter packet foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Adapter type: {0}" -f $result.AdapterType)
Write-Output ("Request status: {0}" -f $result.RequestStatus)
Write-Output ("Result status: {0}" -f $result.ResultStatus)
Write-Output ("Adapter runtime implemented: {0}" -f $result.AdapterRuntimeImplemented)
Write-Output ("Codex executor invoked: {0}" -f $result.CodexExecutorInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
