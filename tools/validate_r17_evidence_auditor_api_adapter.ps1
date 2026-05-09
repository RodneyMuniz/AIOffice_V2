$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17EvidenceAuditorApiAdapter.psm1"
Import-Module $modulePath -Force

$result = Test-R17EvidenceAuditorApiAdapter -RepositoryRoot $repoRoot

Write-Output "R17-018 Evidence Auditor API adapter packet foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Adapter type: {0}" -f $result.AdapterType)
Write-Output ("Request status: {0}" -f $result.RequestStatus)
Write-Output ("Response status: {0}" -f $result.ResponseStatus)
Write-Output ("Verdict status: {0}" -f $result.VerdictStatus)
Write-Output ("Execution mode: {0}" -f $result.ExecutionMode)
Write-Output ("Adapter enabled: {0}" -f $result.AdapterEnabled)
Write-Output ("Evidence Auditor API invoked: {0}" -f $result.EvidenceAuditorApiInvoked)
Write-Output ("External API call performed: {0}" -f $result.ExternalApiCallPerformed)
Write-Output ("Audit verdict claimed: {0}" -f $result.AuditVerdictClaimed)
Write-Output ("Real audit verdict: {0}" -f $result.RealAuditVerdict)
Write-Output ("External audit acceptance claimed: {0}" -f $result.ExternalAuditAcceptanceClaimed)
Write-Output ("Runtime execution performed: {0}" -f $result.RuntimeExecutionPerformed)
