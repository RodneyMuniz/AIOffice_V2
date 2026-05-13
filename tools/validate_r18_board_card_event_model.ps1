$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18BoardCardEventModel.psm1"
Import-Module $modulePath -Force

$result = Test-R18BoardCardEventModel -RepositoryRoot $repoRoot

Write-Output "R18-020 board/card event model validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Seed card count: {0}" -f $result.CardCount)
Write-Output ("Seed event count: {0}" -f $result.EventCount)
Write-Output ("Event log entry count: {0}" -f $result.EventLogEntryCount)
Write-Output ("Board/card runtime implemented: {0}" -f $result.RuntimeFlags.board_card_runtime_implemented)
Write-Output ("Live board runtime executed: {0}" -f $result.RuntimeFlags.live_board_runtime_executed)
Write-Output ("Board runtime mutation performed: {0}" -f $result.RuntimeFlags.board_runtime_mutation_performed)
Write-Output ("R18-021 completed: {0}" -f $result.RuntimeFlags.r18_021_completed)
