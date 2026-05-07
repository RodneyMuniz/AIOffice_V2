$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17BoardStateStore.psm1") -Force -PassThru
$newStore = $module.ExportedCommands["New-R17BoardStateStore"]

$result = & $newStore -RepositoryRoot $repoRoot

Write-Output ("R17-005 board state store generated. Verdict: {0}. Board state: {1}. Replay report: {2}." -f $result.AggregateVerdict, $result.BoardStatePath, $result.ReplayReportPath)
