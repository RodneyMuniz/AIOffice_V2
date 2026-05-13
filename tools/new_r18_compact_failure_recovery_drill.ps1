$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureRecoveryDrill.psm1"
Import-Module $modulePath -Force

$result = New-R18CompactFailureRecoveryDrillArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-024 compact-failure recovery drill foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Runner log entries: {0}" -f $result.RunnerLogEntryCount)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic local runner drill evidence only; no recovery action, live runner runtime, Codex/OpenAI API invocation, live agents, live skills, A2A messages, work-order execution, board/card runtime mutation, release gate execution, CI replay, product runtime, or solved compaction/reliability is claimed."
