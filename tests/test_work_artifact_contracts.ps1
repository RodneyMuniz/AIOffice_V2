$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\WorkArtifactValidation.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot

$validCases = @(
    "state\fixtures\valid\work_artifact.request_brief.valid.json",
    "state\fixtures\valid\work_artifact.task_packet.valid.json",
    "state\fixtures\valid\work_artifact.execution_bundle.valid.json",
    "state\fixtures\valid\work_artifact.qa_report.valid.json",
    "state\fixtures\valid\work_artifact.external_audit_pack.valid.json",
    "state\fixtures\valid\work_artifact.baton.valid.json"
)

$invalidCases = @(
    "state\fixtures\invalid\work_artifact.request_brief.invalid-creator-role.json",
    "state\fixtures\invalid\work_artifact.task_packet.invalid-approved-without-accepted-plan.json",
    "state\fixtures\invalid\work_artifact.execution_bundle.invalid-lineage.json",
    "state\fixtures\invalid\work_artifact.qa_report.invalid-passed-remediation.json",
    "state\fixtures\invalid\work_artifact.external_audit_pack.invalid-missing-qa-evidence.json",
    "state\fixtures\invalid\work_artifact.baton.invalid-missing-next-artifacts.json"
)

$validPassed = 0
$invalidRejected = 0
$failures = @()

foreach ($relativePath in $validCases) {
    $artifactPath = Join-Path $repoRoot $relativePath
    try {
        $result = Test-WorkArtifactContract -ArtifactPath $artifactPath
        Write-Output ("PASS valid: {0} -> {1} {2}" -f $relativePath, $result.ArtifactType, $result.ArtifactId)
        $validPassed += 1
    }
    catch {
        $failures += ("FAIL valid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
    }
}

foreach ($relativePath in $invalidCases) {
    $artifactPath = Join-Path $repoRoot $relativePath
    try {
        Test-WorkArtifactContract -ArtifactPath $artifactPath | Out-Null
        $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $relativePath)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
        $invalidRejected += 1
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Work artifact contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All work artifact contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
