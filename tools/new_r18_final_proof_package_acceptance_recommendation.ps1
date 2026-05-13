$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18FinalProofPackageAcceptanceRecommendation.psm1"
Import-Module $modulePath -Force

$result = New-R18FinalProofPackageArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-028 final proof package and acceptance recommendation generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Task entries indexed: {0}" -f $result.TaskEntryCount)
Write-Output ("Unresolved gaps: {0}" -f $result.UnresolvedGapCount)
Write-Output ("Operator approval granted: {0}" -f $result.OperatorApprovalGranted)
Write-Output ("Closeout blocked: {0}" -f $result.CloseoutBlocked)
Write-Output "Artifacts are a deterministic final package candidate only; no operator approval, external audit acceptance, main merge, milestone closeout, runtime/API/tool/agent/A2A execution, recovery action, release gate execution, CI replay, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or R19 opening is claimed."
