[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$modulePath = Join-Path $RepositoryRoot "tools\R18FinalProofPackageAcceptanceRecommendation.psm1"
Import-Module $modulePath -Force

$result = Test-R18FinalProofPackage -RepositoryRoot $RepositoryRoot

Write-Output "R18-028 final proof package and acceptance recommendation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Task entries indexed: {0}" -f $result.TaskEntryCount)
Write-Output ("Unresolved gaps: {0}" -f $result.UnresolvedGapCount)
Write-Output ("R18 status: {0}" -f $result.R18Status)
Write-Output "R18 remains active through R18-028 only; closeout remains blocked pending explicit committed operator approval."
