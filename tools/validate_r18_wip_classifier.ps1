$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WipClassifier.psm1"
Import-Module $modulePath -Force

$result = Test-R18WipClassifier -RepositoryRoot $repoRoot

Write-Output "R18-011 WIP classifier foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Inventory count: {0}" -f $result.InventoryCount)
Write-Output ("Classification packet count: {0}" -f $result.ClassificationPacketCount)
Write-Output ("Live git scan performed: {0}" -f $result.RuntimeFlags.live_git_scan_performed)
Write-Output ("WIP cleanup performed: {0}" -f $result.RuntimeFlags.wip_cleanup_performed)
Write-Output ("WIP abandonment performed: {0}" -f $result.RuntimeFlags.wip_abandonment_performed)
Write-Output ("Staging performed: {0}" -f $result.RuntimeFlags.staging_performed)
Write-Output ("Commit performed: {0}" -f $result.RuntimeFlags.commit_performed)
Write-Output ("Push performed: {0}" -f $result.RuntimeFlags.push_performed)
Write-Output ("Remote branch verified: {0}" -f $result.RuntimeFlags.remote_branch_verified)
Write-Output ("Continuation packet generated: {0}" -f $result.RuntimeFlags.continuation_packet_generated)
Write-Output ("New-context prompt generated: {0}" -f $result.RuntimeFlags.new_context_prompt_generated)
Write-Output ("Recovery action performed: {0}" -f $result.RuntimeFlags.recovery_action_performed)
Write-Output ("R18-012 completed: {0}" -f $result.RuntimeFlags.r18_012_completed)
