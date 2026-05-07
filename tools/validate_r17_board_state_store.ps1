$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17BoardStateStore.psm1") -Force -PassThru
$testStore = $module.ExportedCommands["Test-R17BoardStateStore"]

$result = & $testStore -RepositoryRoot $repoRoot

if ($result.AggregateVerdict -ne "generated_r17_board_state_store_candidate") {
    throw "R17-005 board state store aggregate verdict was '$($result.AggregateVerdict)'."
}

Write-Output ("R17-005 board state store validation passed. Cards: {0}. Events: {1}. Replayed: {2}. Rejected: {3}. Final lane: {4}. User decisions required: {5}." -f $result.InputCardCount, $result.InputEventCount, $result.ReplayedEventCount, $result.RejectedEventCount, $result.FinalLane, $result.UserDecisionCount)
