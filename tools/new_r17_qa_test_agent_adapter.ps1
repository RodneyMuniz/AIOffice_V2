$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17QaTestAgentAdapter.psm1"
Import-Module $modulePath -Force

$result = New-R17QaTestAgentAdapterArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-017 QA/Test Agent adapter packet foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Request packet: {0}" -f $result.RequestPacket)
Write-Output ("Result packet: {0}" -f $result.ResultPacket)
Write-Output ("Defect packet: {0}" -f $result.DefectPacket)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
