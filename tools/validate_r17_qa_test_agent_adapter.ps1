$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17QaTestAgentAdapter.psm1"
Import-Module $modulePath -Force

$result = Test-R17QaTestAgentAdapter -RepositoryRoot $repoRoot

Write-Output "R17-017 QA/Test Agent adapter packet foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Adapter type: {0}" -f $result.AdapterType)
Write-Output ("Request status: {0}" -f $result.RequestStatus)
Write-Output ("Result status: {0}" -f $result.ResultStatus)
Write-Output ("Defect status: {0}" -f $result.DefectStatus)
Write-Output ("Execution mode: {0}" -f $result.ExecutionMode)
Write-Output ("Adapter runtime implemented: {0}" -f $result.AdapterRuntimeImplemented)
Write-Output ("QA/Test Agent invoked: {0}" -f $result.QaTestAgentInvoked)
Write-Output ("Actual tool call performed: {0}" -f $result.ActualToolCallPerformed)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("A2A message sent: {0}" -f $result.A2aMessageSent)
