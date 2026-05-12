$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RemoteBranchVerifier.psm1"
Import-Module $modulePath -Force

$result = Invoke-R18RemoteBranchVerifier -RepositoryRoot $repoRoot

Write-Output "R18-012 bounded current remote branch verification packet generated."
Write-Output ("Verification status: {0}" -f $result.VerificationStatus)
Write-Output ("Action recommendation: {0}" -f $result.ActionRecommendation)
Write-Output ("Safe to continue: {0}" -f $result.SafeToContinue)
Write-Output ("Actual branch: {0}" -f $result.ActualBranch)
Write-Output ("Local head: {0}" -f $result.LocalHead)
Write-Output ("Local tree: {0}" -f $result.LocalTree)
Write-Output ("Actual remote head: {0}" -f $result.ActualRemoteHead)
