$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RemoteBranchVerifier.psm1"
Import-Module $modulePath -Force

$result = Test-R18RemoteBranchVerifier -RepositoryRoot $repoRoot

Write-Output "R18-012 remote branch verifier foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Sample count: {0}" -f $result.SampleCount)
Write-Output ("Verification packet count: {0}" -f $result.VerificationPacketCount)
Write-Output ("Current verification status: {0}" -f $result.CurrentVerificationStatus)
Write-Output ("Current safe to continue: {0}" -f $result.CurrentSafeToContinue)
Write-Output ("Branch mutation performed: {0}" -f $result.RuntimeFlags.branch_mutation_performed)
Write-Output ("Push performed: {0}" -f $result.RuntimeFlags.push_performed)
Write-Output ("Continuation packet generated: {0}" -f $result.RuntimeFlags.continuation_packet_generated)
Write-Output ("Recovery action performed: {0}" -f $result.RuntimeFlags.recovery_action_performed)
