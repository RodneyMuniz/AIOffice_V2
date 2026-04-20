$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$qaGateModule = Import-Module (Join-Path $repoRoot "tools\ExecutionBundleQaGate.psm1") -Force -PassThru
$batonPersistenceModule = Import-Module (Join-Path $repoRoot "tools\BatonPersistence.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeExecutionBundleQaGate = $qaGateModule.ExportedCommands["Invoke-ExecutionBundleQaGate"]
$newBatonFromQaOutcome = $batonPersistenceModule.ExportedCommands["New-BatonFromQaOutcome"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
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

function New-RetryEntryExecutionBundle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseFixturePath,
        [Parameter(Mandatory = $true)]
        [int]$AttemptCount,
        [Parameter(Mandatory = $true)]
        [string]$PriorQaReportPath,
        [Parameter(Mandatory = $true)]
        [string]$PriorBatonPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputDirectory
    )

    $bundle = Get-JsonDocument -Path $BaseFixturePath
    $bundle.artifact_id = "execution-bundle-r4-004-retry-attempt-{0:00}" -f $AttemptCount
    $bundle.title = "R4-004 retry entry attempt $AttemptCount"
    $bundle.summary = "Replay the bounded QA loop at attempt $AttemptCount."
    $bundle.qa_attempt_count = $AttemptCount
    $bundle.qa_retry_ceiling = 4
    $bundle.qa_entry_state = "retry_entry"
    $bundle.prior_qa_report_ref = $PriorQaReportPath
    $bundle.prior_baton_ref = $PriorBatonPath
    $bundle.lineage.source_refs = @($bundle.lineage.source_refs | ForEach-Object {
            Resolve-ArtifactReferencePath -ArtifactPath $BaseFixturePath -Reference $_
        })
    $bundle.work_object_refs = @($bundle.work_object_refs | ForEach-Object {
            $_.ref = Resolve-ArtifactReferencePath -ArtifactPath $BaseFixturePath -Reference $_.ref
            $_
        })
    $bundle.planning_record_refs = @($bundle.planning_record_refs | ForEach-Object {
            $_.ref = Resolve-ArtifactReferencePath -ArtifactPath $BaseFixturePath -Reference $_.ref
            $_
        })
    $bundle.evidence[0].ref = Resolve-ArtifactReferencePath -ArtifactPath $BaseFixturePath -Reference $bundle.evidence[0].ref

    $observationPath = Resolve-ArtifactReferencePath -ArtifactPath $BaseFixturePath -Reference $bundle.evidence[1].ref
    $observation = Get-JsonDocument -Path $observationPath
    $observation.execution_bundle_id = $bundle.artifact_id
    $retryObservationPath = Join-Path $OutputDirectory ("qa_gate.observation.retry-attempt-{0:00}.json" -f $AttemptCount)
    Write-JsonDocument -Path $retryObservationPath -Document $observation
    $bundle.evidence[1].ref = $retryObservationPath

    $bundlePath = Join-Path $OutputDirectory ("{0}.json" -f $bundle.artifact_id)
    Write-JsonDocument -Path $bundlePath -Document $bundle

    return [pscustomobject]@{
        BundlePath = $bundlePath
        Bundle     = $bundle
    }
}

$validCases = @(
    @{
        Name = "pass"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.pass.json"
        ExpectedOutcome = "pass"
        ExpectedQaStatus = "passed"
        ExpectedQaVerdict = "pass"
        ExpectedRemediationStatus = "none"
        ExpectedRemediationRequired = $false
        ExpectedLoopState = "closed"
        ExpectedNextHandoff = "none"
    },
    @{
        Name = "fail"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.fail.json"
        ExpectedOutcome = "fail"
        ExpectedQaStatus = "failed"
        ExpectedQaVerdict = "fail"
        ExpectedRemediationStatus = "required"
        ExpectedRemediationRequired = $true
        ExpectedLoopState = "retry_required"
        ExpectedNextHandoff = "baton_follow_up"
    },
    @{
        Name = "block"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.block.json"
        ExpectedOutcome = "block"
        ExpectedQaStatus = "blocked"
        ExpectedQaVerdict = "blocked"
        ExpectedRemediationStatus = "blocked"
        ExpectedRemediationRequired = $true
        ExpectedLoopState = "blocked"
        ExpectedNextHandoff = "baton_follow_up"
    }
)

$invalidCases = @(
    (Join-Path $repoRoot "state\fixtures\invalid\qa_gate.execution_bundle.invalid-under-evidenced.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\qa_gate.execution_bundle.invalid-draft.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\qa_gate.execution_bundle.invalid-working-planning-view.json")
)

$failures = @()
$validPassed = 0
$invalidRejected = 0

foreach ($validCase in $validCases) {
    try {
        $fixtureCheck = & $testWorkArtifactContract -ArtifactPath $validCase.Fixture
        Write-Output ("PASS valid fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validCase.Fixture), $fixtureCheck.ArtifactType, $fixtureCheck.ArtifactId)

        $tempRoot = Join-Path $env:TEMP ("aioffice-r3-006-{0}-{1}" -f $validCase.Name, ([guid]::NewGuid().ToString("N")))
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

        try {
            $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validCase.Fixture -OutputRoot $tempRoot -CreatedAt ([datetime]::Parse("2026-04-20T02:00:00Z").ToUniversalTime())
            $qaReportCheck = & $testWorkArtifactContract -ArtifactPath $gateResult.QaReportPath
            $externalAuditPackCheck = & $testWorkArtifactContract -ArtifactPath $gateResult.ExternalAuditPackPath
            Write-Output ("PASS valid gate: {0} -> outcome {1}" -f $fixtureCheck.ArtifactId, $gateResult.Outcome)

            $qaReport = Get-JsonDocument -Path $gateResult.QaReportPath
            $remediationRecord = Get-JsonDocument -Path $gateResult.RemediationRecordPath
            $qaGateRecord = Get-JsonDocument -Path $gateResult.QaGateResultPath
            $externalAuditPack = Get-JsonDocument -Path $gateResult.ExternalAuditPackPath

            if ($gateResult.Outcome -ne $validCase.ExpectedOutcome) {
                $failures += ("FAIL valid gate: {0} outcome expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedOutcome, $gateResult.Outcome)
            }
            if ($qaReport.status -ne $validCase.ExpectedQaStatus) {
                $failures += ("FAIL valid gate: {0} QA report status expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedQaStatus, $qaReport.status)
            }
            if ($qaReport.verdict -ne $validCase.ExpectedQaVerdict) {
                $failures += ("FAIL valid gate: {0} QA report verdict expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedQaVerdict, $qaReport.verdict)
            }
            if ($remediationRecord.status -ne $validCase.ExpectedRemediationStatus) {
                $failures += ("FAIL valid gate: {0} remediation status expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedRemediationStatus, $remediationRecord.status)
            }
            if ([bool]$remediationRecord.remediation_required -ne [bool]$validCase.ExpectedRemediationRequired) {
                $failures += ("FAIL valid gate: {0} remediation_required expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedRemediationRequired, $remediationRecord.remediation_required)
            }
            if ([int]$qaReport.qa_attempt_count -ne 1 -or [int]$qaReport.qa_retry_ceiling -ne 4) {
                $failures += ("FAIL valid gate: {0} QA report did not preserve bounded retry metadata." -f $fixtureCheck.ArtifactId)
            }
            if ($qaReport.qa_loop_state -ne $validCase.ExpectedLoopState) {
                $failures += ("FAIL valid gate: {0} QA report loop state expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedLoopState, $qaReport.qa_loop_state)
            }
            if ($qaReport.next_handoff -ne $validCase.ExpectedNextHandoff) {
                $failures += ("FAIL valid gate: {0} QA report next_handoff expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedNextHandoff, $qaReport.next_handoff)
            }
            if ([int]$remediationRecord.qa_attempt_count -ne 1 -or [int]$remediationRecord.qa_retry_ceiling -ne 4) {
                $failures += ("FAIL valid gate: {0} remediation record did not preserve bounded retry metadata." -f $fixtureCheck.ArtifactId)
            }
            if ($remediationRecord.next_handoff -ne $validCase.ExpectedNextHandoff) {
                $failures += ("FAIL valid gate: {0} remediation record next_handoff expected '{1}' but found '{2}'." -f $fixtureCheck.ArtifactId, $validCase.ExpectedNextHandoff, $remediationRecord.next_handoff)
            }
            if ($qaGateRecord.generated_artifacts.qa_report -eq $null -or $qaGateRecord.generated_artifacts.external_audit_pack -eq $null) {
                $failures += ("FAIL valid gate: {0} QA gate record did not persist generated artifact refs." -f $fixtureCheck.ArtifactId)
            }
            if ($qaGateRecord.qa_loop_state -ne $validCase.ExpectedLoopState -or $qaGateRecord.next_handoff -ne $validCase.ExpectedNextHandoff) {
                $failures += ("FAIL valid gate: {0} QA gate record did not preserve the bounded loop metadata." -f $fixtureCheck.ArtifactId)
            }

            $qaReportEvidencePath = Resolve-ArtifactReferencePath -ArtifactPath $gateResult.QaReportPath -Reference $qaReport.evidence[0].ref
            if ($qaReportEvidencePath -ne $gateResult.QaGateResultPath) {
                $failures += ("FAIL valid gate: {0} QA report test_output evidence did not resolve to the gate result record." -f $fixtureCheck.ArtifactId)
            }

            if (@($externalAuditPack.planning_record_refs | Where-Object { $_.view -ne "accepted" }).Count -ne 0) {
                $failures += ("FAIL valid gate: {0} external audit pack did not preserve accepted planning views only." -f $fixtureCheck.ArtifactId)
            }

            $includedArtifactPaths = @($externalAuditPack.included_artifacts | ForEach-Object {
                    Resolve-ArtifactReferencePath -ArtifactPath $gateResult.ExternalAuditPackPath -Reference $_
                })
            if ($includedArtifactPaths -notcontains $gateResult.QaReportPath) {
                $failures += ("FAIL valid gate: {0} external audit pack did not include the QA report artifact path." -f $fixtureCheck.ArtifactId)
            }
            if ($includedArtifactPaths -notcontains $gateResult.RemediationRecordPath) {
                $failures += ("FAIL valid gate: {0} external audit pack did not include the remediation record path." -f $fixtureCheck.ArtifactId)
            }

            if ($qaReportCheck.ArtifactType -ne "qa_report") {
                $failures += ("FAIL valid gate: {0} generated QA report did not validate as artifact type 'qa_report'." -f $fixtureCheck.ArtifactId)
            }
            if ($externalAuditPackCheck.ArtifactType -ne "external_audit_pack") {
                $failures += ("FAIL valid gate: {0} generated External Audit Pack did not validate as artifact type 'external_audit_pack'." -f $fixtureCheck.ArtifactId)
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
        $failures += ("FAIL valid gate harness ({0}): {1}" -f $validCase.Name, $_.Exception.Message)
    }
}

try {
    $retrySourceFixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.fail.json"
    $retrySourceCheck = & $testWorkArtifactContract -ArtifactPath $retrySourceFixture
    Write-Output ("PASS retry-source fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $retrySourceFixture), $retrySourceCheck.ArtifactType, $retrySourceCheck.ArtifactId)

    $retryTempRoot = Join-Path $env:TEMP ("aioffice-r4-004-retry-exhausted-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $retryTempRoot -Force | Out-Null

    try {
        $attemptDirectory = Join-Path $retryTempRoot "attempts"
        New-Item -ItemType Directory -Path $attemptDirectory -Force | Out-Null

        $currentGateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $retrySourceFixture -OutputRoot (Join-Path $attemptDirectory "attempt-01-gate") -CreatedAt ([datetime]::Parse("2026-04-20T05:00:00Z").ToUniversalTime())
        $currentBatonEmission = & $newBatonFromQaOutcome -QaReportPath $currentGateResult.QaReportPath -ExternalAuditPackPath $currentGateResult.ExternalAuditPackPath -RemediationRecordPath $currentGateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-20T05:05:00Z").ToUniversalTime())
        $currentBatonPath = Join-Path $attemptDirectory "attempt-01-baton.json"
        Write-JsonDocument -Path $currentBatonPath -Document $currentBatonEmission.Baton

        foreach ($attempt in 2..4) {
            $retryEntry = New-RetryEntryExecutionBundle -BaseFixturePath $retrySourceFixture -AttemptCount $attempt -PriorQaReportPath $currentGateResult.QaReportPath -PriorBatonPath $currentBatonPath -OutputDirectory $attemptDirectory
            $retryEntryCheck = & $testWorkArtifactContract -ArtifactPath $retryEntry.BundlePath
            if ($retryEntryCheck.ArtifactType -ne "execution_bundle") {
                $failures += ("FAIL retry-exhausted gate: attempt {0} bundle did not validate as execution_bundle." -f $attempt)
            }

            $currentGateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $retryEntry.BundlePath -OutputRoot (Join-Path $attemptDirectory ("attempt-{0:00}-gate" -f $attempt)) -CreatedAt ([datetime]::Parse("2026-04-20T05:10:00Z").AddMinutes($attempt).ToUniversalTime())

            if ($attempt -lt 4) {
                $currentBatonEmission = & $newBatonFromQaOutcome -QaReportPath $currentGateResult.QaReportPath -ExternalAuditPackPath $currentGateResult.ExternalAuditPackPath -RemediationRecordPath $currentGateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-20T05:20:00Z").AddMinutes($attempt).ToUniversalTime())
                $currentBatonPath = Join-Path $attemptDirectory ("attempt-{0:00}-baton.json" -f $attempt)
                Write-JsonDocument -Path $currentBatonPath -Document $currentBatonEmission.Baton
            }
        }

        $retryQaReport = Get-JsonDocument -Path $currentGateResult.QaReportPath
        $retryRemediationRecord = Get-JsonDocument -Path $currentGateResult.RemediationRecordPath
        $retryQaGateRecord = Get-JsonDocument -Path $currentGateResult.QaGateResultPath
        Write-Output ("PASS retry-exhausted gate: {0} -> QA status {1}" -f $retryQaReport.artifact_id, $retryQaReport.status)

        if ($retryQaReport.status -ne "retry_exhausted") {
            $failures += ("FAIL retry-exhausted gate: expected QA report status 'retry_exhausted' but found '{0}'." -f $retryQaReport.status)
        }
        if ($retryQaReport.qa_loop_state -ne "retry_exhausted" -or $retryQaReport.next_handoff -ne "manual_review") {
            $failures += "FAIL retry-exhausted gate: QA report did not preserve manual-review stop metadata."
        }
        if ($retryRemediationRecord.status -ne "retry_exhausted" -or $retryRemediationRecord.next_handoff -ne "manual_review") {
            $failures += "FAIL retry-exhausted gate: remediation record did not preserve retry-exhausted stop metadata."
        }
        if ($retryQaGateRecord.qa_loop_state -ne "retry_exhausted" -or $retryQaGateRecord.next_handoff -ne "manual_review") {
            $failures += "FAIL retry-exhausted gate: QA gate record did not preserve retry-exhausted stop metadata."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $retryTempRoot) {
            Remove-Item -LiteralPath $retryTempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL retry-exhausted gate harness: {0}" -f $_.Exception.Message)
}

foreach ($invalidCase in $invalidCases) {
    try {
        $fixtureCheck = & $testWorkArtifactContract -ArtifactPath $invalidCase
        Write-Output ("PASS contract-valid malformed input: {0} -> {1} {2}" -f (Resolve-Path -Relative $invalidCase), $fixtureCheck.ArtifactType, $fixtureCheck.ArtifactId)

        $invalidOutputRoot = Join-Path $env:TEMP ("aioffice-r3-006-invalid-{0}" -f ([guid]::NewGuid().ToString("N")))
        New-Item -ItemType Directory -Path $invalidOutputRoot -Force | Out-Null

        try {
            & $invokeExecutionBundleQaGate -ExecutionBundlePath $invalidCase -OutputRoot $invalidOutputRoot -CreatedAt ([datetime]::Parse("2026-04-20T02:00:00Z").ToUniversalTime()) | Out-Null
            $failures += ("FAIL invalid gate: {0} was accepted unexpectedly." -f (Split-Path -Leaf $invalidCase))
        }
        catch {
            Write-Output ("PASS invalid gate: {0} -> {1}" -f (Split-Path -Leaf $invalidCase), $_.Exception.Message)
            $invalidRejected += 1
        }
        finally {
            if (Test-Path -LiteralPath $invalidOutputRoot) {
                Remove-Item -LiteralPath $invalidOutputRoot -Recurse -Force
            }
        }
    }
    catch {
        $failures += ("FAIL invalid fixture harness ({0}): {1}" -f (Split-Path -Leaf $invalidCase), $_.Exception.Message)
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Execution Bundle QA gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All Execution Bundle QA gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
