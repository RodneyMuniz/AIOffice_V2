$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$r3ReplayModule = Import-Module (Join-Path $repoRoot "tools\R3PlanningReplayProof.psm1") -Force -PassThru

$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeR3PlanningReplayProof = $r3ReplayModule.ExportedCommands["Invoke-R3PlanningReplayProof"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Resolve-ArtifactReferencePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    $baseDirectory = Split-Path -Parent $ArtifactPath
    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Resolve-Path -LiteralPath $Reference).Path
    }

    return (Resolve-Path -LiteralPath (Join-Path $baseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar))).Path
}

$validRequestBrief = Join-Path $repoRoot "state\fixtures\valid\request_brief_task_packet_flow.request_brief.valid.json"
$validQaObservation = Join-Path $repoRoot "state\fixtures\valid\qa_gate.observation.fail.json"
$invalidRequestBrief = Join-Path $repoRoot "state\fixtures\invalid\request_brief_task_packet_flow.request_brief.invalid-missing-planning-record.json"
$missingObservation = Join-Path $repoRoot "state\fixtures\invalid\qa_gate.observation.missing.json"

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $requestBriefCheck = & $testWorkArtifactContract -ArtifactPath $validRequestBrief
    Write-Output ("PASS valid replay request fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validRequestBrief), $requestBriefCheck.ArtifactType, $requestBriefCheck.ArtifactId)

    $tempRoot = Join-Path $env:TEMP ("aioffice-r3-008-valid-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $replayResult = & $invokeR3PlanningReplayProof -RequestBriefPath $validRequestBrief -QaObservationPath $validQaObservation -OutputRoot $tempRoot -TaskPacketId "task-packet-r3-005-flow-001" -ExecutionBundleId "execution-bundle-r3-006-fail-001" -CreatedAt ([datetime]::Parse("2026-04-20T04:00:00Z").ToUniversalTime())

        $taskPacketCheck = & $testWorkArtifactContract -ArtifactPath $replayResult.TaskPacketPath
        $executionBundleCheck = & $testWorkArtifactContract -ArtifactPath $replayResult.ExecutionBundlePath
        $qaReportCheck = & $testWorkArtifactContract -ArtifactPath $replayResult.QaReportPath
        $externalAuditPackCheck = & $testWorkArtifactContract -ArtifactPath $replayResult.ExternalAuditPackPath
        $batonCheck = & $testWorkArtifactContract -ArtifactPath $replayResult.BatonPath

        Write-Output ("PASS valid replay proof: {0} -> {1} -> {2} -> {3}" -f $requestBriefCheck.ArtifactId, $taskPacketCheck.ArtifactId, $qaReportCheck.ArtifactId, $batonCheck.ArtifactId)

        $executionBundle = Get-JsonDocument -Path $replayResult.ExecutionBundlePath
        $qaReport = Get-JsonDocument -Path $replayResult.QaReportPath
        $externalAuditPack = Get-JsonDocument -Path $replayResult.ExternalAuditPackPath
        $baton = Get-JsonDocument -Path $replayResult.BatonPath
        $summary = Get-JsonDocument -Path $replayResult.ReplaySummaryPath

        if ($taskPacketCheck.ArtifactType -ne "task_packet") {
            $failures += "FAIL valid replay proof: generated Task Packet did not validate as artifact type 'task_packet'."
        }
        if ($executionBundleCheck.ArtifactType -ne "execution_bundle") {
            $failures += "FAIL valid replay proof: generated Execution Bundle did not validate as artifact type 'execution_bundle'."
        }
        if ($qaReportCheck.ArtifactType -ne "qa_report") {
            $failures += "FAIL valid replay proof: generated QA Report did not validate as artifact type 'qa_report'."
        }
        if ($externalAuditPackCheck.ArtifactType -ne "external_audit_pack") {
            $failures += "FAIL valid replay proof: generated External Audit Pack did not validate as artifact type 'external_audit_pack'."
        }
        if ($batonCheck.ArtifactType -ne "baton") {
            $failures += "FAIL valid replay proof: generated Baton did not validate as artifact type 'baton'."
        }

        $executionBundleLineagePath = Resolve-ArtifactReferencePath -ArtifactPath $replayResult.ExecutionBundlePath -Reference $executionBundle.lineage.source_refs[0]
        if ($executionBundleLineagePath -ne $replayResult.TaskPacketPath) {
            $failures += "FAIL valid replay proof: Execution Bundle lineage did not resolve to the generated Task Packet."
        }

        $qaReportLineagePath = Resolve-ArtifactReferencePath -ArtifactPath $replayResult.QaReportPath -Reference $qaReport.lineage.source_refs[0]
        if ($qaReportLineagePath -ne $replayResult.ExecutionBundlePath) {
            $failures += "FAIL valid replay proof: QA Report lineage did not resolve to the generated Execution Bundle."
        }

        $externalAuditPackLineagePath = Resolve-ArtifactReferencePath -ArtifactPath $replayResult.ExternalAuditPackPath -Reference $externalAuditPack.lineage.source_refs[0]
        if ($externalAuditPackLineagePath -ne $replayResult.QaReportPath) {
            $failures += "FAIL valid replay proof: External Audit Pack lineage did not resolve to the generated QA Report."
        }

        $batonLineagePath = Resolve-ArtifactReferencePath -ArtifactPath $replayResult.BatonPath -Reference $baton.lineage.source_refs[0]
        if ($batonLineagePath -ne $replayResult.QaReportPath) {
            $failures += "FAIL valid replay proof: Baton lineage did not resolve to the generated QA Report."
        }

        $includedArtifactPaths = @($externalAuditPack.included_artifacts | ForEach-Object {
                Resolve-ArtifactReferencePath -ArtifactPath $replayResult.ExternalAuditPackPath -Reference $_
            })
        if ($includedArtifactPaths -notcontains $replayResult.TaskPacketPath) {
            $failures += "FAIL valid replay proof: External Audit Pack did not include the generated Task Packet."
        }
        if ($includedArtifactPaths -notcontains $replayResult.ExecutionBundlePath) {
            $failures += "FAIL valid replay proof: External Audit Pack did not include the generated Execution Bundle."
        }
        if ($includedArtifactPaths -notcontains $replayResult.QaReportPath) {
            $failures += "FAIL valid replay proof: External Audit Pack did not include the generated QA Report."
        }
        if ($includedArtifactPaths -notcontains $replayResult.RemediationRecordPath) {
            $failures += "FAIL valid replay proof: External Audit Pack did not include the remediation record."
        }

        $nextArtifactPaths = @($baton.next_required_artifacts | ForEach-Object {
                Resolve-ArtifactReferencePath -ArtifactPath $replayResult.BatonPath -Reference $_
            })
        if ($nextArtifactPaths -notcontains $replayResult.QaReportPath) {
            $failures += "FAIL valid replay proof: Baton next_required_artifacts did not preserve the QA Report path."
        }
        if ($nextArtifactPaths -notcontains $replayResult.ExternalAuditPackPath) {
            $failures += "FAIL valid replay proof: Baton next_required_artifacts did not preserve the External Audit Pack path."
        }
        if ($nextArtifactPaths -notcontains $replayResult.RemediationRecordPath) {
            $failures += "FAIL valid replay proof: Baton next_required_artifacts did not preserve the remediation record path."
        }

        if ($summary.record_type -ne "r3_planning_replay_summary") {
            $failures += "FAIL valid replay proof: replay summary record_type was not 'r3_planning_replay_summary'."
        }
        if ($summary.replay_command -ne "powershell -ExecutionPolicy Bypass -File tests\\test_r3_planning_replay.ps1") {
            $failures += "FAIL valid replay proof: replay summary did not preserve the committed replay command."
        }
        if ([bool]$summary.automatic_resume_added -ne $false) {
            $failures += "FAIL valid replay proof: replay summary incorrectly claimed automatic resume behavior."
        }
        if ([bool]$summary.broad_orchestration_added -ne $false) {
            $failures += "FAIL valid replay proof: replay summary incorrectly claimed broad orchestration behavior."
        }

        $summaryBatonPath = Resolve-ArtifactReferencePath -ArtifactPath $replayResult.ReplaySummaryPath -Reference $summary.generated_artifacts.baton
        if ($summaryBatonPath -ne $replayResult.BatonPath) {
            $failures += "FAIL valid replay proof: replay summary did not preserve the Baton output path."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid replay proof harness: {0}" -f $_.Exception.Message)
}

try {
    $invalidRequestBriefCheck = & $testWorkArtifactContract -ArtifactPath $invalidRequestBrief
    Write-Output ("PASS contract-valid malformed replay request: {0} -> {1} {2}" -f (Resolve-Path -Relative $invalidRequestBrief), $invalidRequestBriefCheck.ArtifactType, $invalidRequestBriefCheck.ArtifactId)

    $invalidRequestRoot = Join-Path $env:TEMP ("aioffice-r3-008-invalid-request-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $invalidRequestRoot -Force | Out-Null

    try {
        & $invokeR3PlanningReplayProof -RequestBriefPath $invalidRequestBrief -QaObservationPath $validQaObservation -OutputRoot $invalidRequestRoot -TaskPacketId "task-packet-invalid" -ExecutionBundleId "execution-bundle-invalid" -CreatedAt ([datetime]::Parse("2026-04-20T04:00:00Z").ToUniversalTime()) | Out-Null
        $failures += "FAIL invalid replay proof: malformed Request Brief was accepted unexpectedly."
    }
    catch {
        Write-Output ("PASS invalid replay proof: {0} -> {1}" -f (Split-Path -Leaf $invalidRequestBrief), $_.Exception.Message)
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $invalidRequestRoot) {
            Remove-Item -LiteralPath $invalidRequestRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL invalid replay request harness: {0}" -f $_.Exception.Message)
}

try {
    $missingObservationRoot = Join-Path $env:TEMP ("aioffice-r3-008-missing-observation-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $missingObservationRoot -Force | Out-Null

    try {
        & $invokeR3PlanningReplayProof -RequestBriefPath $validRequestBrief -QaObservationPath $missingObservation -OutputRoot $missingObservationRoot -TaskPacketId "task-packet-r3-005-flow-001" -ExecutionBundleId "execution-bundle-r3-006-fail-001" -CreatedAt ([datetime]::Parse("2026-04-20T04:00:00Z").ToUniversalTime()) | Out-Null
        $failures += "FAIL invalid replay proof: missing QA observation was accepted unexpectedly."
    }
    catch {
        Write-Output ("PASS invalid replay proof: {0} -> {1}" -f (Split-Path -Leaf $missingObservation), $_.Exception.Message)
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $missingObservationRoot) {
            Remove-Item -LiteralPath $missingObservationRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL missing observation harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R3 planning replay proof tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R3 planning replay proof tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
