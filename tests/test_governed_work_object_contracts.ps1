$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\GovernedWorkObjectValidation.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot

$validCases = @(
    "state\fixtures\valid\governed_work_object.project.valid.json",
    "state\fixtures\valid\governed_work_object.milestone.valid.json",
    "state\fixtures\valid\governed_work_object.task.valid.json",
    "state\fixtures\valid\governed_work_object.bug.valid.json"
)

$invalidCases = @(
    "state\fixtures\invalid\governed_work_object.project.invalid-parent.json",
    "state\fixtures\invalid\governed_work_object.milestone.invalid-parent.json",
    "state\fixtures\invalid\governed_work_object.task.invalid-done-without-summary.json",
    "state\fixtures\invalid\governed_work_object.bug.invalid-open-resolution.json"
)

$validPassed = 0
$invalidRejected = 0
$failures = @()

foreach ($relativePath in $validCases) {
    $workObjectPath = Join-Path $repoRoot $relativePath
    try {
        $result = Test-GovernedWorkObjectContract -WorkObjectPath $workObjectPath
        Write-Output ("PASS valid: {0} -> {1} {2}" -f $relativePath, $result.ObjectType, $result.ObjectId)
        $validPassed += 1
    }
    catch {
        $failures += ("FAIL valid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
    }
}

foreach ($relativePath in $invalidCases) {
    $workObjectPath = Join-Path $repoRoot $relativePath
    try {
        Test-GovernedWorkObjectContract -WorkObjectPath $workObjectPath | Out-Null
        $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $relativePath)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $relativePath, $_.Exception.Message)
        $invalidRejected += 1
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Governed work object contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All governed work object contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
