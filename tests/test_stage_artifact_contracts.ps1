$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\StageArtifactValidation.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot

$validCases = @(
    "artifacts\fixtures\valid\intake.valid.json",
    "artifacts\fixtures\valid\pm.valid.json",
    "artifacts\fixtures\valid\context_audit.valid.json",
    "artifacts\fixtures\valid\architect.valid.json"
)

$invalidCases = @(
    "artifacts\fixtures\invalid\intake.missing-output.json",
    "artifacts\fixtures\invalid\pm.invalid-approval.json",
    "artifacts\fixtures\invalid\context_audit.invalid-handoff.json",
    "artifacts\fixtures\invalid\architect.missing-acceptance-checks.json"
)

$validPassed = 0
$invalidRejected = 0
$failures = @()

foreach ($relativePath in $validCases) {
    $artifactPath = Join-Path $repoRoot $relativePath
    try {
        $result = Test-StageArtifactContract -ArtifactPath $artifactPath
        Write-Output ("PASS valid: {0} -> {1}" -f $relativePath, $result.Stage)
        $validPassed += 1
    }
    catch {
        $failures += ("FAIL valid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
    }
}

foreach ($relativePath in $invalidCases) {
    $artifactPath = Join-Path $repoRoot $relativePath
    try {
        Test-StageArtifactContract -ArtifactPath $artifactPath | Out-Null
        $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $relativePath)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
        $invalidRejected += 1
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Stage artifact contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All stage artifact contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
