$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ControlRoomStatus.psm1") -Force -PassThru
$testStatus = $module.ExportedCommands["Test-ControlRoomStatus"]
$newStatus = $module.ExportedCommands["New-ControlRoomStatus"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\control_room"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\control_room"
$currentStatusPath = Join-Path $repoRoot "state\control_room\r12_current\control_room_status.json"
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
    $fixtureStatus = & $testStatus -StatusPath (Join-Path $validRoot "control_room_status.foundation.valid.json")
    if ($fixtureStatus.OperatorControlRoomGate -ne "foundation_present" -or $fixtureStatus.RealBuildChangeGate -ne "not_started") {
        $failures += "FAIL valid: control-room status fixture did not expose expected operator-control foundation and real-build not-started posture."
    }
    else {
        Write-Output ("PASS valid control-room status fixture: {0}" -f $fixtureStatus.StatusId)
        $validPassed += 1
    }

    $draft = & $newStatus -CompletedThroughTask "R12-014"
    if ($draft.active_scope.input_completed_through -ne "R12-013" -or $draft.active_scope.current_completed_through -ne "R12-014") {
        $failures += "FAIL valid: generated R12-014 status draft did not preserve input/current task boundary."
    }
    else {
        Write-Output ("PASS valid generated R12-014 control-room status draft: {0}" -f $draft.status_id)
        $validPassed += 1
    }

    $currentStatus = & $testStatus -StatusPath $currentStatusPath
    if ($currentStatus.CurrentCompletedThrough -ne "R12-017" -or $currentStatus.OperatorControlRoomGate -ne "foundation_present" -or $currentStatus.RealBuildChangeGate -ne "partially_evidenced") {
        $failures += "FAIL valid: current generated status did not validate as R12 active through R12-017 with bounded refresh evidence present."
    }
    else {
        Write-Output ("PASS valid current generated control-room status: {0}" -f $currentStatus.StatusId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-branch-head-tree" -RequiredFragments @("branch") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.missing-identity.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-value-gate" -RequiredFragments @("value_gate_status", "real_build_change") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.missing-value-gate.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-external-evidence-overclaim" -RequiredFragments @("external runner evidence", "real external") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.external-evidence-overclaim.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-qa-pass-without-external" -RequiredFragments @("QA gate pass", "real external evidence") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.qa-pass-without-external.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-blocker-for-blocked-gate" -RequiredFragments @("missing blockers", "blocked") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.missing-blocker.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-closeout-claim" -RequiredFragments @("forbidden positive claim", "R12 closeout") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.closeout-claim.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims") -Action {
        & $testStatus -StatusPath (Join-Path $invalidRoot "control_room_status.missing-non-claims.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL control-room status harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Control-room status tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All control-room status tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
