$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17StopRetryReentryControls.psm1"
Import-Module $modulePath -Force

$result = New-R17StopRetryReentryArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-022 stop/retry/pause/block/re-entry controls foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Control packets: {0}" -f $result.ControlPackets)
Write-Output ("Re-entry packets: {0}" -f $result.ReentryPackets)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Control packets: {0}" -f $result.ControlPacketCount)
Write-Output ("Re-entry packets: {0}" -f $result.ReentryPacketCount)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
