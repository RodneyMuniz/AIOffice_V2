$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ControlRoomRefresh.psm1") -Force -PassThru
$testRefresh = $module.ExportedCommands["Test-ControlRoomRefreshResult"]
$invokeRefresh = $module.ExportedCommands["Invoke-ControlRoomRefresh"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\control_room_refresh"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\control_room_refresh"
$currentRefreshPath = Join-Path $repoRoot "state\control_room\r12_current\control_room_refresh_result.json"
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

try {
    $validFixture = & $testRefresh -RefreshResultPath (Join-Path $validRoot "control_room_refresh.valid.json")
    if ($validFixture.RefreshVerdict -ne "blocked" -or $validFixture.GeneratedStatusRef -ne "state/control_room/r12_current/control_room_status.json") {
        $failures += "FAIL valid: refresh fixture did not preserve blocked verdict and generated status ref."
    }
    else {
        Write-Output ("PASS valid control-room refresh fixture: {0}" -f $validFixture.RefreshId)
        $validPassed += 1
    }

    $currentResult = & $testRefresh -RefreshResultPath $currentRefreshPath
    if ($currentResult.RefreshVerdict -ne "blocked") {
        $failures += "FAIL valid: current refresh result should validate with blocked verdict while external evidence is missing."
    }
    else {
        Write-Output ("PASS valid current control-room refresh result: {0}" -f $currentResult.RefreshId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-stale-head-tree" -RequiredFragments @("stale branch/head/tree", "head") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.stale-head-tree.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-generated-view" -RequiredFragments @("generated_view_ref") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.missing-generated-view.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-decision-queue" -RequiredFragments @("generated_decision_queue_ref") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.missing-decision-queue.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-hidden-external-evidence-blocker" -RequiredFragments @("missing blocker", "external evidence") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.hidden-external-evidence-blocker.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-productized-control-room-claim" -RequiredFragments @("forbidden positive view claim", "productized control-room") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.productized-control-room-claim.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-r12-closeout-claim" -RequiredFragments @("forbidden positive claim", "R12 closeout") -Action {
        & $testRefresh -RefreshResultPath (Join-Path $invalidRoot "control_room_refresh.r12-closeout-claim.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "command-stale-head-refusal" -RequiredFragments @("refused stale branch/head/tree") -Action {
        & $invokeRefresh `
            -Repository "AIOffice_V2" `
            -Branch "release/r12-external-api-runner-actionable-qa-control-room-pilot" `
            -Head "0000000000000000000000000000000000000000" `
            -Tree "1111111111111111111111111111111111111111" `
            -StatusOutputPath "state/control_room/r12_current/_stale_probe_status.json" `
            -ViewOutputPath "state/control_room/r12_current/_stale_probe_control_room.md" `
            -DecisionQueueOutputPath "state/control_room/r12_current/_stale_probe_queue.json" `
            -DecisionQueueViewOutputPath "state/control_room/r12_current/_stale_probe_queue.md" `
            -RefreshResultOutputPath "state/control_room/r12_current/_stale_probe_refresh.json" `
            -Overwrite | Out-Null
    }
}
catch {
    $failures += ("FAIL control-room refresh harness: {0}" -f $_.Exception.Message)
}

foreach ($probePath in @(
        "state/control_room/r12_current/_stale_probe_status.json",
        "state/control_room/r12_current/_stale_probe_control_room.md",
        "state/control_room/r12_current/_stale_probe_queue.json",
        "state/control_room/r12_current/_stale_probe_queue.md",
        "state/control_room/r12_current/_stale_probe_refresh.json"
    )) {
    $resolvedProbePath = Join-Path $repoRoot $probePath
    if (Test-Path -LiteralPath $resolvedProbePath) {
        Remove-Item -LiteralPath $resolvedProbePath -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Control-room refresh tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All control-room refresh tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
