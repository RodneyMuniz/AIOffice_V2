$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\PacketRecordStorage.psm1"
Import-Module $modulePath -Force

$validFixture = Join-Path $repoRoot "state\fixtures\valid\packet_record.valid.json"
$invalidFixtures = @(
    (Join-Path $repoRoot "state\fixtures\invalid\packet_record.missing-packet-id.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\packet_record.invalid-current-stage.json")
)

$failures = @()

try {
    $fixtureResult = Test-PacketRecordContract -PacketRecordPath $validFixture
    Write-Output ("PASS valid fixture: {0} -> {1}" -f $fixtureResult.PacketId, $fixtureResult.Stage)
}
catch {
    $failures += ("FAIL valid fixture: {0}" -f $_.Exception.Message)
}

foreach ($invalidFixture in $invalidFixtures) {
    try {
        Test-PacketRecordContract -PacketRecordPath $invalidFixture | Out-Null
        $failures += ("FAIL invalid fixture accepted: {0}" -f $invalidFixture)
    }
    catch {
        Write-Output ("PASS invalid fixture: {0} -> {1}" -f (Split-Path -Leaf $invalidFixture), $_.Exception.Message)
    }
}

$tempStore = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-rst010-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempStore -Force | Out-Null

try {
    $packet = New-PacketRecord -PacketId "packet-rst010-test-001" -InitialStage "intake" -CreatedAt ([datetime]"2026-04-19T12:00:00Z")
    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "intake" -Ref "artifacts/fixtures/valid/intake.valid.json" -Kind "stage_artifact" -View "working" -AddedAt ([datetime]"2026-04-19T12:01:00Z") -Notes "Working intake artifact."
    $packet = Set-PacketRecordCurrentStage -PacketRecord $packet -Stage "pm" -Status "active" -ArtifactRef "artifacts/fixtures/valid/pm.valid.json" -ChangedAt ([datetime]"2026-04-19T12:05:00Z") -Notes "Planning stage recorded."
    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "pm" -Ref "artifacts/fixtures/valid/pm.valid.json" -Kind "stage_artifact" -View "working" -AddedAt ([datetime]"2026-04-19T12:05:00Z") -Notes "Working planning artifact."
    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "architect" -Ref "artifacts/fixtures/valid/architect.valid.json" -Kind "stage_artifact" -View "accepted" -AddedAt ([datetime]"2026-04-19T12:15:00Z") -Notes "Accepted architect artifact."
    $packet = Set-PacketRecordApprovalState -PacketRecord $packet -Mode "required" -Status "approved" -By "operator:admin" -At ([datetime]"2026-04-19T12:06:00Z") -Notes "Packet approved for continued work."
    $packet = Set-PacketRecordGitRefs -PacketRecord $packet -Branch "main" -HeadCommit "c03e2c3fd83b8bdd353ebb221477a9eb0f605260" -AcceptedCommit "b9b3edca10992cc497349d6d35b61da90583f66e" -ObservedAt ([datetime]"2026-04-19T12:10:00Z")
    $packet = Set-PacketRecordWorkingState -PacketRecord $packet -Status "ready_for_review" -ArtifactRefs @("artifacts/fixtures/valid/intake.valid.json", "artifacts/fixtures/valid/pm.valid.json") -UpdatedAt ([datetime]"2026-04-19T12:12:00Z") -Notes "Working state is ahead of accepted state."
    $packet = Set-PacketRecordAcceptedState -PacketRecord $packet -Status "accepted" -AcceptedStage "architect" -ArtifactRefs @("artifacts/fixtures/valid/architect.valid.json") -AcceptedAt ([datetime]"2026-04-19T12:15:00Z") -AcceptedBy "operator:admin" -Notes "Architect artifact accepted."
    $packet = Set-PacketRecordReconciliationState -PacketRecord $packet -Status "drift" -ComparedAt ([datetime]"2026-04-19T12:20:00Z") -WorkingMatchesAccepted:$false -GitHeadMatchesAccepted:$false -Notes "Working and Git state are ahead of accepted state."

    $savedPath = Save-PacketRecord -PacketRecord $packet -StorePath $tempStore
    $reloaded = Get-PacketRecord -PacketId "packet-rst010-test-001" -StorePath $tempStore

    if ($reloaded.packet_id -ne "packet-rst010-test-001") {
        $failures += "FAIL persisted packet_id did not round-trip."
    }
    if ($reloaded.current_stage -ne "pm") {
        $failures += "FAIL current_stage did not persist as pm."
    }
    if (@($reloaded.stage_progression).Count -ne 2) {
        $failures += "FAIL stage_progression did not persist two entries."
    }
    if ($reloaded.approval_state.status -ne "approved") {
        $failures += "FAIL approval_state.status did not persist as approved."
    }
    if (@($reloaded.artifact_refs).Count -ne 3) {
        $failures += "FAIL artifact_refs count did not persist as 3."
    }
    if ($reloaded.git_refs.head_commit -ne "c03e2c3fd83b8bdd353ebb221477a9eb0f605260") {
        $failures += "FAIL git_refs.head_commit did not persist."
    }
    if ($reloaded.working_state.status -ne "ready_for_review") {
        $failures += "FAIL working_state.status did not persist as ready_for_review."
    }
    if ($reloaded.accepted_state.status -ne "accepted") {
        $failures += "FAIL accepted_state.status did not persist as accepted."
    }
    if ($reloaded.reconciliation_state.status -ne "drift") {
        $failures += "FAIL reconciliation_state.status did not persist as drift."
    }
    if ($reloaded.reconciliation_state.status -eq $reloaded.accepted_state.status) {
        $failures += "FAIL reconciliation_state.status should remain distinct from accepted_state.status."
    }
    if ($reloaded.working_state.artifact_refs.Count -eq $reloaded.accepted_state.artifact_refs.Count -and ($reloaded.working_state.artifact_refs -join '|') -eq ($reloaded.accepted_state.artifact_refs -join '|')) {
        $failures += "FAIL working_state.artifact_refs should remain distinct from accepted_state.artifact_refs."
    }

    Write-Output ("PASS persist reload: {0}" -f $savedPath)
}
catch {
    $failures += ("FAIL persist reload: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempStore) {
        Remove-Item -LiteralPath $tempStore -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Packet record storage tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All packet record storage tests passed."
