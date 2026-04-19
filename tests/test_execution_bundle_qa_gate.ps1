$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$qaGateModule = Import-Module (Join-Path $repoRoot "tools\ExecutionBundleQaGate.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeExecutionBundleQaGate = $qaGateModule.ExportedCommands["Invoke-ExecutionBundleQaGate"]

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

$validCases = @(
    @{
        Name = "pass"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.pass.json"
        ExpectedOutcome = "pass"
        ExpectedQaStatus = "passed"
        ExpectedQaVerdict = "pass"
        ExpectedRemediationStatus = "none"
        ExpectedRemediationRequired = $false
    },
    @{
        Name = "fail"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.fail.json"
        ExpectedOutcome = "fail"
        ExpectedQaStatus = "failed"
        ExpectedQaVerdict = "fail"
        ExpectedRemediationStatus = "required"
        ExpectedRemediationRequired = $true
    },
    @{
        Name = "block"
        Fixture = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.block.json"
        ExpectedOutcome = "block"
        ExpectedQaStatus = "blocked"
        ExpectedQaVerdict = "blocked"
        ExpectedRemediationStatus = "blocked"
        ExpectedRemediationRequired = $true
    }
)

$invalidCases = @(
    (Join-Path $repoRoot "state\fixtures\invalid\qa_gate.execution_bundle.invalid-under-evidenced.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\qa_gate.execution_bundle.invalid-draft.json")
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
            if ($qaGateRecord.generated_artifacts.qa_report -eq $null -or $qaGateRecord.generated_artifacts.external_audit_pack -eq $null) {
                $failures += ("FAIL valid gate: {0} QA gate record did not persist generated artifact refs." -f $fixtureCheck.ArtifactId)
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
