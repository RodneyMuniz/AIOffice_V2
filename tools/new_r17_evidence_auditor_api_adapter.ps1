$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17EvidenceAuditorApiAdapter.psm1"
Import-Module $modulePath -Force

$result = New-R17EvidenceAuditorApiAdapterArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-018 Evidence Auditor API adapter packet foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Request packet: {0}" -f $result.RequestPacket)
Write-Output ("Response packet: {0}" -f $result.ResponsePacket)
Write-Output ("Verdict packet: {0}" -f $result.VerdictPacket)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
