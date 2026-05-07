[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [string]$FixturesRoot = "tests/fixtures/r17_board_contracts"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

try {
    $modulePath = Join-Path $RepositoryRoot "tools\R17BoardContracts.psm1"
    $module = Import-Module $modulePath -Force -PassThru
    $testContracts = $module.ExportedCommands["Test-R17BoardContracts"]
    $result = & $testContracts -RepositoryRoot $RepositoryRoot -FixturesRoot $FixturesRoot

    Write-Output ("VALID: R17-004 board contracts passed. contracts={0}; valid_fixtures={1}; invalid_rejected={2}; lanes={3}; scope={4}." -f $result.ContractCount, $result.ValidFixtureCount, $result.InvalidRejectedCount, $result.LaneCount, $result.Scope)
    Write-Output "R17-004 validation is contract shape and fixture behavior only; it creates no runtime board state, moves no cards, calls no agents, and calls no APIs."
    exit 0
}
catch {
    Write-Output ("INVALID: R17-004 board contracts failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
