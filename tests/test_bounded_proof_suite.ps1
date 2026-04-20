$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\BoundedProofSuite.psm1"
Import-Module $modulePath -Force

$failures = @()
$expectedIds = @(
    "r2-stage-artifact-contracts",
    "r2-packet-record-storage",
    "r2-apply-promotion-gate",
    "r2-apply-promotion-action",
    "r2-supervised-admin-flow",
    "r3-governed-work-object-contracts",
    "r3-planning-record-storage",
    "r3-work-artifact-contracts",
    "r3-request-brief-task-packet-flow",
    "r3-execution-bundle-qa-gate",
    "r3-baton-persistence",
    "r3-planning-replay",
    "r4-ci-foundation"
)

try {
    $definitions = @(Get-BoundedProofSuiteDefinition)
    $actualIds = @($definitions | ForEach-Object { $_.Id })
    foreach ($expectedId in $expectedIds) {
        if ($actualIds -notcontains $expectedId) {
            $failures += ("FAIL proof suite definition missing id: {0}" -f $expectedId)
        }
    }

    Write-Output ("PASS proof suite definition count: {0}" -f $definitions.Count)
}
catch {
    $failures += ("FAIL proof suite definition load: {0}" -f $_.Exception.Message)
}

$tempRoot = Join-Path $env:TEMP ("aioffice-proof-suite-test-" + [guid]::NewGuid().ToString("N"))
try {
    $result = Invoke-BoundedProofSuite -OutputRoot $tempRoot -TestIds @(
        "r2-stage-artifact-contracts",
        "r2-packet-record-storage",
        "r4-ci-foundation"
    )

    if ($result.PassedCount -ne 3) {
        $failures += ("FAIL proof suite subset pass count was {0}, expected 3." -f $result.PassedCount)
    }
    if ($result.FailedCount -ne 0) {
        $failures += ("FAIL proof suite subset fail count was {0}, expected 0." -f $result.FailedCount)
    }
    if (-not $result.WorkspaceMutationPassed) {
        $failures += "FAIL proof suite subset unexpectedly dirtied the repo workspace."
    }

    if (-not (Test-Path -LiteralPath $result.SummaryPath)) {
        $failures += "FAIL proof suite subset summary JSON was not created."
    }
    if (-not (Test-Path -LiteralPath $result.SummaryMarkdownPath)) {
        $failures += "FAIL proof suite subset summary Markdown was not created."
    }

    $summary = Get-Content -LiteralPath $result.SummaryPath -Raw | ConvertFrom-Json
    if ($summary.failed_count -ne 0) {
        $failures += "FAIL proof suite subset summary recorded failures unexpectedly."
    }
    if (-not $summary.workspace_mutation_check.passed) {
        $failures += "FAIL proof suite subset summary recorded unexpected workspace mutation."
    }

    foreach ($suiteResult in @($summary.results)) {
        $logPath = $suiteResult.log_path
        if (-not (Test-Path -LiteralPath $logPath)) {
            $failures += ("FAIL proof suite subset log missing: {0}" -f $suiteResult.log_path)
        }
    }

    Write-Output ("PASS proof suite subset execution: {0}" -f $result.SummaryPath)
}
catch {
    $failures += ("FAIL proof suite subset execution: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

try {
    $unknownSelectionFailed = $false
    try {
        Invoke-BoundedProofSuite -OutputRoot (Join-Path $env:TEMP ("aioffice-proof-suite-unknown-" + [guid]::NewGuid().ToString("N"))) -TestIds @("not-a-real-proof-case") | Out-Null
    }
    catch {
        $unknownSelectionFailed = $true
        Write-Output ("PASS proof suite unknown selection refusal: {0}" -f $_.Exception.Message)
    }

    if (-not $unknownSelectionFailed) {
        $failures += "FAIL proof suite accepted an unknown test id."
    }
}
catch {
    $failures += ("FAIL proof suite unknown-selection harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Bounded proof suite tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All bounded proof suite tests passed."
