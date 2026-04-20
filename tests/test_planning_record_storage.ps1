$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\PlanningRecordStorage.psm1"
Import-Module $modulePath -Force

$validFixture = Join-Path $repoRoot "state\fixtures\valid\planning_record.task.valid.json"
$invalidFixtures = @(
    (Join-Path $repoRoot "state\fixtures\invalid\planning_record.accepted-ref-mismatch.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\planning_record.invalid-working-status.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\planning_record.invalid-standard-runtime-claim.json")
)

$governedFixtures = @(
    (Join-Path $repoRoot "state\fixtures\valid\governed_work_object.project.valid.json"),
    (Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"),
    (Join-Path $repoRoot "state\fixtures\valid\governed_work_object.task.valid.json"),
    (Join-Path $repoRoot "state\fixtures\valid\governed_work_object.bug.valid.json")
)

$failures = @()

try {
    $fixtureResult = Test-PlanningRecordContract -PlanningRecordPath $validFixture
    Write-Output ("PASS valid fixture: {0} -> {1} {2}" -f $fixtureResult.PlanningRecordId, $fixtureResult.ObjectType, $fixtureResult.ObjectId)
}
catch {
    $failures += ("FAIL valid fixture: {0}" -f $_.Exception.Message)
}

foreach ($invalidFixture in $invalidFixtures) {
    try {
        Test-PlanningRecordContract -PlanningRecordPath $invalidFixture | Out-Null
        $failures += ("FAIL invalid fixture accepted: {0}" -f $invalidFixture)
    }
    catch {
        Write-Output ("PASS invalid fixture: {0} -> {1}" -f (Split-Path -Leaf $invalidFixture), $_.Exception.Message)
    }
}

$tempStore = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r3-003-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempStore -Force | Out-Null

try {
    foreach ($fixturePath in $governedFixtures) {
        $workObject = Get-Content -LiteralPath $fixturePath -Raw | ConvertFrom-Json
        $planningRecordId = "planning-{0}" -f $workObject.object_id
        $createdAt = [datetime]"2026-04-19T15:00:00Z"
        $acceptedAt = [datetime]"2026-04-19T15:05:00Z"
        $comparedAt = [datetime]"2026-04-19T15:10:00Z"

        $planningRecord = New-PlanningRecord -PlanningRecordId $planningRecordId -WorkingRecord $workObject -CreatedAt $createdAt -InitialWorkingStatus "draft"
        $planningRecord = Set-PlanningRecordWorkingState -PlanningRecord $planningRecord -Status "ready_for_review" -WorkObjectRecord $workObject -UpdatedAt $createdAt -Notes "Working surface saved for round-trip validation."
        $planningRecord = Set-PlanningRecordAcceptedState -PlanningRecord $planningRecord -Status "accepted" -WorkObjectRecord $workObject -AcceptedAt $acceptedAt -AcceptedBy "operator:admin" -Notes "Accepted surface saved separately."
        $planningRecord = Set-PlanningRecordReconciliationState -PlanningRecord $planningRecord -Status "matched" -ComparedAt $comparedAt -WorkingMatchesAccepted $true -Notes "Working and accepted surfaces match for round-trip validation."

        $savedPath = Save-PlanningRecord -PlanningRecord $planningRecord -StorePath $tempStore
        $reloaded = Get-PlanningRecord -PlanningRecordId $planningRecordId -StorePath $tempStore

        if ($reloaded.planning_record_id -ne $planningRecordId) {
            $failures += ("FAIL round-trip: {0} planning_record_id did not persist." -f $workObject.object_type)
        }
        if ($reloaded.object_type -ne $workObject.object_type) {
            $failures += ("FAIL round-trip: {0} object_type did not persist." -f $workObject.object_type)
        }
        if ($reloaded.object_id -ne $workObject.object_id) {
            $failures += ("FAIL round-trip: {0} object_id did not persist." -f $workObject.object_type)
        }
        if ($reloaded.working_state.status -ne "ready_for_review") {
            $failures += ("FAIL round-trip: {0} working_state.status did not persist as ready_for_review." -f $workObject.object_type)
        }
        if ($reloaded.accepted_state.status -ne "accepted") {
            $failures += ("FAIL round-trip: {0} accepted_state.status did not persist as accepted." -f $workObject.object_type)
        }
        if ($reloaded.reconciliation_state.status -ne "matched") {
            $failures += ("FAIL round-trip: {0} reconciliation_state.status did not persist as matched." -f $workObject.object_type)
        }
        if ($reloaded.pipeline.mode -ne "admin_only_bounded") {
            $failures += ("FAIL round-trip: {0} pipeline.mode did not persist as admin_only_bounded." -f $workObject.object_type)
        }
        if ([bool]$reloaded.pipeline.standard_runtime_claimed -ne $false) {
            $failures += ("FAIL round-trip: {0} pipeline.standard_runtime_claimed did not remain false." -f $workObject.object_type)
        }
        if (@($reloaded.scope.protected_surfaces) -notcontains "planning_records") {
            $failures += ("FAIL round-trip: {0} scope.protected_surfaces did not preserve the planning_records boundary." -f $workObject.object_type)
        }
        if (@($reloaded.scope.prohibited_surfaces) -notcontains "standard_runtime") {
            $failures += ("FAIL round-trip: {0} scope.prohibited_surfaces did not preserve the Standard runtime exclusion." -f $workObject.object_type)
        }
        if ($reloaded.working_state.record_ref -eq $reloaded.accepted_state.record_ref) {
            $failures += ("FAIL round-trip: {0} working and accepted record refs should remain distinct." -f $workObject.object_type)
        }
        if ($reloaded.working_state.record.object_id -ne $reloaded.accepted_state.record.object_id) {
            $failures += ("FAIL round-trip: {0} accepted record identity changed unexpectedly." -f $workObject.object_type)
        }
        if ($reloaded.working_state.object_status -ne $reloaded.working_state.record.status) {
            $failures += ("FAIL round-trip: {0} working surface status metadata does not match the reloaded work object." -f $workObject.object_type)
        }
        if ($reloaded.accepted_state.object_status -ne $reloaded.accepted_state.record.status) {
            $failures += ("FAIL round-trip: {0} accepted surface status metadata does not match the reloaded work object." -f $workObject.object_type)
        }

        Write-Output ("PASS round-trip: {0} -> {1}" -f $workObject.object_type, $savedPath)
    }
}
catch {
    $failures += ("FAIL round-trip harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempStore) {
        Remove-Item -LiteralPath $tempStore -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Planning record storage tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All planning record storage tests passed."
