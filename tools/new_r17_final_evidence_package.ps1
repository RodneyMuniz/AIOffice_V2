$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17FinalEvidencePackage.psm1"
Import-Module $modulePath -Force

$result = New-R17FinalEvidencePackageArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-028 final evidence package artifacts."
Write-Output ("Final report: {0}" -f $result.FinalReport)
Write-Output ("KPI scorecard: {0}" -f $result.KpiScorecard)
Write-Output ("KPI contract: {0}" -f $result.KpiContract)
Write-Output ("Evidence index: {0}" -f $result.EvidenceIndex)
Write-Output ("Proof review: {0}" -f $result.ProofReview)
Write-Output ("Validation manifest: {0}" -f $result.ValidationManifest)
Write-Output ("Final-head support packet: {0}" -f $result.FinalHeadSupportPacket)
Write-Output ("R18 planning brief: {0}" -f $result.R18PlanningBrief)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
