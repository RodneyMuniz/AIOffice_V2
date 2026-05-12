$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RemoteBranchVerifier.psm1"
Import-Module $modulePath -Force

$result = New-R18RemoteBranchVerifierArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-012 remote branch verifier foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Sample count: {0}" -f $result.SampleCount)
Write-Output ("Verification packet count: {0}" -f $result.VerificationPacketCount)
