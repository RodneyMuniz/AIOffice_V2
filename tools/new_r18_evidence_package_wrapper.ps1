$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18EvidencePackageWrapper.psm1"
Import-Module $modulePath -Force

$result = New-R18EvidencePackageWrapperArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-019 evidence package wrapper foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Input count: {0}" -f $result.InputCount)
Write-Output ("Manifest count: {0}" -f $result.ManifestCount)
Write-Output ("Assessment count: {0}" -f $result.AssessmentCount)
Write-Output ("Invalid fixture count: {0}" -f $result.FixtureCount)
Write-Output "Artifacts are deterministic policy/manifest artifacts only; no live evidence package runtime, audit acceptance, release gate execution, CI replay, or GitHub Actions workflow occurred."
