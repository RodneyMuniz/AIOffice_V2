$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$qaGateModule = Import-Module (Join-Path $repoRoot "tools\ExecutionBundleQaGate.psm1") -Force -PassThru
$batonPersistenceModule = Import-Module (Join-Path $repoRoot "tools\BatonPersistence.psm1") -Force -PassThru

$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeExecutionBundleQaGate = $qaGateModule.ExportedCommands["Invoke-ExecutionBundleQaGate"]
$testBatonRecordContract = $batonPersistenceModule.ExportedCommands["Test-BatonRecordContract"]
$newBatonFromQaOutcome = $batonPersistenceModule.ExportedCommands["New-BatonFromQaOutcome"]
$saveBatonRecord = $batonPersistenceModule.ExportedCommands["Save-BatonRecord"]
$getBatonRecord = $batonPersistenceModule.ExportedCommands["Get-BatonRecord"]

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

$validExecutionBundle = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.fail.json"
$passExecutionBundle = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.pass.json"
$invalidBatonFixture = Join-Path $repoRoot "state\fixtures\invalid\work_artifact.baton.invalid-missing-next-artifacts.json"

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $fixtureCheck = & $testWorkArtifactContract -ArtifactPath $validExecutionBundle
    Write-Output ("PASS valid fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validExecutionBundle), $fixtureCheck.ArtifactType, $fixtureCheck.ArtifactId)

    $tempRoot = Join-Path $env:TEMP ("aioffice-r3-007-valid-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $qaOutputRoot = Join-Path $tempRoot "qa-output"
        $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot $qaOutputRoot -CreatedAt ([datetime]::Parse("2026-04-20T03:00:00Z").ToUniversalTime())
        $batonEmission = & $newBatonFromQaOutcome -QaReportPath $gateResult.QaReportPath -ExternalAuditPackPath $gateResult.ExternalAuditPackPath -RemediationRecordPath $gateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-20T03:10:00Z").ToUniversalTime())
        $batonStorePath = Join-Path $tempRoot "baton-store"
        $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath $batonStorePath
        $savedBatonCheck = & $testBatonRecordContract -BatonPath $savedBatonPath
        $loadedBaton = & $getBatonRecord -BatonId $batonEmission.Baton.artifact_id -StorePath $batonStorePath
        $qaReport = Get-JsonDocument -Path $gateResult.QaReportPath

        Write-Output ("PASS valid baton persistence: {0} -> baton {1}" -f $qaReport.artifact_id, $loadedBaton.Baton.artifact_id)

        if ($savedBatonCheck.ArtifactType -ne "baton") {
            $failures += "FAIL valid baton persistence: saved baton did not validate as artifact type 'baton'."
        }
        if ($loadedBaton.Baton.status -ne "ready_for_handoff") {
            $failures += ("FAIL valid baton persistence: expected status 'ready_for_handoff' but found '{0}'." -f $loadedBaton.Baton.status)
        }
        if ($loadedBaton.Baton.lineage.source_kind -ne "qa_report") {
            $failures += ("FAIL valid baton persistence: expected lineage source kind 'qa_report' but found '{0}'." -f $loadedBaton.Baton.lineage.source_kind)
        }
        if ($loadedBaton.Baton.artifact_id -ne $batonEmission.Baton.artifact_id) {
            $failures += ("FAIL valid baton persistence: loaded artifact id '{0}' did not match emitted artifact id '{1}'." -f $loadedBaton.Baton.artifact_id, $batonEmission.Baton.artifact_id)
        }
        if (@($loadedBaton.Baton.blocked_by).Count -eq 0) {
            $failures += "FAIL valid baton persistence: blocked_by must remain non-empty after reload."
        }
        if (@($loadedBaton.Baton.handoff_notes | Where-Object { $_ -eq "Do not auto-resume; this baton is persistence-only foundation state." }).Count -eq 0) {
            $failures += "FAIL valid baton persistence: handoff notes did not preserve the persistence-only foundation warning."
        }

        $resolvedNextArtifacts = @($loadedBaton.Baton.next_required_artifacts | ForEach-Object {
                Resolve-ArtifactReferencePath -ArtifactPath $savedBatonPath -Reference $_
            })
        if ($resolvedNextArtifacts.Count -ne 3) {
            $failures += ("FAIL valid baton persistence: expected 3 next required artifacts but found {0}." -f $resolvedNextArtifacts.Count)
        }
        if ($resolvedNextArtifacts -notcontains $gateResult.QaReportPath) {
            $failures += "FAIL valid baton persistence: next required artifacts did not preserve the QA report path."
        }
        if ($resolvedNextArtifacts -notcontains $gateResult.ExternalAuditPackPath) {
            $failures += "FAIL valid baton persistence: next required artifacts did not preserve the External Audit Pack path."
        }
        if ($resolvedNextArtifacts -notcontains $gateResult.RemediationRecordPath) {
            $failures += "FAIL valid baton persistence: next required artifacts did not preserve the remediation record path."
        }

        $resolvedEvidencePaths = @($loadedBaton.Baton.evidence | ForEach-Object {
                Resolve-ArtifactReferencePath -ArtifactPath $savedBatonPath -Reference $_.ref
            })
        if ($resolvedEvidencePaths -notcontains $gateResult.QaReportPath) {
            $failures += "FAIL valid baton persistence: evidence did not preserve the QA report path."
        }
        if ($resolvedEvidencePaths -notcontains $gateResult.ExternalAuditPackPath) {
            $failures += "FAIL valid baton persistence: evidence did not preserve the External Audit Pack path."
        }
        if ($resolvedEvidencePaths -notcontains $gateResult.RemediationRecordPath) {
            $failures += "FAIL valid baton persistence: evidence did not preserve the remediation record path."
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
    $failures += ("FAIL valid baton persistence harness: {0}" -f $_.Exception.Message)
}

try {
    & $testBatonRecordContract -BatonPath $invalidBatonFixture | Out-Null
    $failures += ("FAIL invalid baton: {0} was accepted unexpectedly." -f (Split-Path -Leaf $invalidBatonFixture))
}
catch {
    Write-Output ("PASS invalid baton: {0} -> {1}" -f (Split-Path -Leaf $invalidBatonFixture), $_.Exception.Message)
    $invalidRejected += 1
}

try {
    $passFixtureCheck = & $testWorkArtifactContract -ArtifactPath $passExecutionBundle
    Write-Output ("PASS valid pass-source fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $passExecutionBundle), $passFixtureCheck.ArtifactType, $passFixtureCheck.ArtifactId)

    $passTempRoot = Join-Path $env:TEMP ("aioffice-r3-007-pass-source-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $passTempRoot -Force | Out-Null

    try {
        $passGateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $passExecutionBundle -OutputRoot (Join-Path $passTempRoot "qa-output") -CreatedAt ([datetime]::Parse("2026-04-20T03:20:00Z").ToUniversalTime())
        & $newBatonFromQaOutcome -QaReportPath $passGateResult.QaReportPath -ExternalAuditPackPath $passGateResult.ExternalAuditPackPath -RemediationRecordPath $passGateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-20T03:25:00Z").ToUniversalTime()) | Out-Null
        $failures += "FAIL invalid baton emission: QA pass outcome was accepted unexpectedly."
    }
    catch {
        Write-Output ("PASS invalid baton emission: {0} -> {1}" -f $passFixtureCheck.ArtifactId, $_.Exception.Message)
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $passTempRoot) {
            Remove-Item -LiteralPath $passTempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL invalid baton emission harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Baton persistence tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All baton persistence tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
