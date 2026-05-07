$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17BoardContracts.psm1") -Force -PassThru
$testContracts = $module.ExportedCommands["Test-R17BoardContracts"]
$testContractDefinitions = $module.ExportedCommands["Test-R17BoardContractDefinitions"]
$testCard = $module.ExportedCommands["Test-R17CardFixture"]
$testBoardState = $module.ExportedCommands["Test-R17BoardStateFixture"]
$testBoardEvent = $module.ExportedCommands["Test-R17BoardEventFixture"]
$testInvalidFixture = $module.ExportedCommands["Test-R17InvalidFixture"]
$readJson = $module.ExportedCommands["Read-R17JsonFile"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixturesRoot = "tests/fixtures/r17_board_contracts"

function Invoke-ExpectedFailure {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedFragment,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        if ($message -notlike ("*{0}*" -f $ExpectedFragment)) {
            $script:failures += "FAIL invalid: $Label refusal missed '$ExpectedFragment'. Actual: $message"
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $ExpectedFragment)
        $script:invalidRejected += 1
    }
}

try {
    $definitionResult = & $testContractDefinitions -RepositoryRoot $repoRoot
    if ($definitionResult.ContractCount -ne 3 -or $definitionResult.AllowedLaneCount -lt 13 -or $definitionResult.AllowedOwnerRoleCount -lt 10) {
        $failures += "FAIL valid contract definitions: expected three contracts with required lanes and roles."
    }
    else {
        Write-Output "PASS valid contract definitions: card, board-state, and board-event contracts are present."
        $validPassed += 1
    }

    $result = & $testContracts -RepositoryRoot $repoRoot -FixturesRoot $fixturesRoot
    if ($result.ContractCount -ne 3 -or $result.ValidFixtureCount -ne 3 -or $result.InvalidRejectedCount -ne 17 -or $result.Scope -ne "contract_shape_and_fixture_behavior_only_not_runtime") {
        $failures += "FAIL valid full validation: unexpected aggregate counts or scope."
    }
    else {
        Write-Output "PASS valid full validation: fixtures accepted/rejected as expected."
        $validPassed += 1
    }

    $validCard = & $readJson -Path (Join-Path $fixturesRoot "valid_card.json") -RepositoryRoot $repoRoot
    $validBoardState = & $readJson -Path (Join-Path $fixturesRoot "valid_board_state.json") -RepositoryRoot $repoRoot
    $validBoardEvent = & $readJson -Path (Join-Path $fixturesRoot "valid_board_event.json") -RepositoryRoot $repoRoot

    & $testCard -Card $validCard -Context "valid_card" -RepositoryRoot $repoRoot | Out-Null
    & $testBoardState -BoardState $validBoardState -Context "valid_board_state" -RepositoryRoot $repoRoot | Out-Null
    & $testBoardEvent -BoardEvent $validBoardEvent -Context "valid_board_event" -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid fixtures: card, board-state, and board-event examples validate."
    $validPassed += 1

    if ($validBoardState.transition_policies.runtime_transitions_implemented_in_r17_004 -ne $false -or $validBoardState.transition_policies.a2a_runtime_implemented_in_r17_004 -ne $false -or $validBoardState.canonical_truth.board_state_replaces_repo_truth -ne $false) {
        $failures += "FAIL non-claim posture: valid board state fixture made a runtime or repo-truth replacement claim."
    }
    else {
        Write-Output "PASS non-claim posture: board fixture is contract-only and repo truth remains canonical."
        $validPassed += 1
    }

    foreach ($invalidFixture in @(Get-ChildItem -LiteralPath (Join-Path $repoRoot $fixturesRoot) -Filter "invalid_*.json" -File | Sort-Object Name)) {
        $relativePath = Join-Path $fixturesRoot $invalidFixture.Name
        & $testInvalidFixture -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
        Write-Output ("PASS invalid fixture file: {0}" -f $invalidFixture.Name)
        $invalidRejected += 1
    }

    Invoke-ExpectedFailure -Label "event-closed-without-user-approval" -ExpectedFragment "closed events require user approval" -Action {
        $candidate = ($validBoardEvent | ConvertTo-Json -Depth 80 | ConvertFrom-Json)
        $candidate.to_lane = "closed"
        $candidate.transition_allowed = $true
        $candidate.user_approval_present = $false
        & $testBoardEvent -BoardEvent $candidate -Context "mutated event" -RepositoryRoot $repoRoot | Out-Null
    }
}
catch {
    $failures += ("FAIL R17 board contract harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 board contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17 board contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
