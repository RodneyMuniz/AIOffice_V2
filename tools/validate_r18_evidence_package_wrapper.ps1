$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18EvidencePackageWrapper.psm1"
Import-Module $modulePath -Force

$result = Test-R18EvidencePackageWrapper -RepositoryRoot $repoRoot

Write-Output "R18-019 evidence package wrapper validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input count: {0}" -f $result.InputCount)
Write-Output ("Manifest count: {0}" -f $result.ManifestCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Wrapper runtime implemented: {0}" -f $result.RuntimeFlags.evidence_package_wrapper_runtime_implemented)
Write-Output ("Live evidence package runtime executed: {0}" -f $result.RuntimeFlags.live_evidence_package_runtime_executed)
Write-Output ("Audit acceptance claimed: {0}" -f $result.RuntimeFlags.audit_acceptance_claimed)
Write-Output ("CI replay performed: {0}" -f $result.RuntimeFlags.ci_replay_performed)
