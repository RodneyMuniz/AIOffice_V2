$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolAdapterContract.psm1"
Import-Module $modulePath -Force

$result = Test-R17ToolAdapterContract -RepositoryRoot $repoRoot

Write-Output "R17-015 tool adapter contract validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Seed profiles: {0}" -f $result.SeedProfileCount)
Write-Output ("Known adapter types: {0}" -f (@($result.KnownAdapterTypes) -join ", "))
Write-Output ("Adapter runtime implemented: {0}" -f $result.AdapterRuntimeImplemented)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Codex executor invoked: {0}" -f $result.CodexExecutorInvoked)
Write-Output ("QA/Test Agent invoked: {0}" -f $result.QaTestAgentInvoked)
Write-Output ("Evidence Auditor API invoked: {0}" -f $result.EvidenceAuditorApiInvoked)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
