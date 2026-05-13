$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18BoardCardEventModel.psm1"
Import-Module $modulePath -Force

$result = New-R18BoardCardEventModelArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-020 board/card event model foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Seed card count: {0}" -f $result.CardCount)
Write-Output ("Seed event count: {0}" -f $result.EventCount)
Write-Output ("Event log entry count: {0}" -f $result.EventLogEntryCount)
Write-Output ("Invalid fixture count: {0}" -f $result.FixtureCount)
Write-Output "Artifacts are deterministic seed/policy artifacts only; no live board/card runtime, board mutation, work-order execution, A2A message, live agent/skill/tool/API execution, release gate execution, CI replay, product runtime, or recovery action occurred."
