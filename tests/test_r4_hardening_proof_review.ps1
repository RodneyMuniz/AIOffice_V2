$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofScriptPath = Join-Path $repoRoot "tools\new_r4_hardening_proof_review.ps1"
$failures = @()

$tempRoot = Join-Path $env:TEMP ("aioffice-r4-proof-review-test-" + [guid]::NewGuid().ToString("N"))
try {
    & powershell -ExecutionPolicy Bypass -File $proofScriptPath -OutputRoot $tempRoot -TestIds "r2-stage-artifact-contracts,r4-ci-foundation" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw ("R4 proof review script exited with code {0}." -f $LASTEXITCODE)
    }

    $summaryPath = Join-Path $tempRoot "bounded-proof-suite-summary.json"
    $replaySummaryPath = Join-Path $tempRoot "REPLAY_SUMMARY.md"
    $replayedCommandPath = Join-Path $tempRoot "meta\replayed_command.txt"

    foreach ($path in @($summaryPath, $replaySummaryPath, $replayedCommandPath)) {
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += ("FAIL R4 proof review output missing: {0}" -f $path)
        }
    }

    if (Test-Path -LiteralPath $summaryPath) {
        $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
        if ($summary.failed_count -ne 0) {
            $failures += "FAIL R4 proof review summary recorded failures unexpectedly."
        }
        if ($summary.passed_count -ne 2) {
            $failures += ("FAIL R4 proof review passed count was {0}, expected 2." -f $summary.passed_count)
        }
    }

    if (Test-Path -LiteralPath $replaySummaryPath) {
        $replaySummaryText = Get-Content -LiteralPath $replaySummaryPath -Raw
        if ($replaySummaryText -notmatch "r2-stage-artifact-contracts") {
            $failures += "FAIL R4 proof review summary did not preserve the selected stage-artifact proof case."
        }
        if ($replaySummaryText -notmatch "r4-ci-foundation") {
            $failures += "FAIL R4 proof review summary did not preserve the selected CI proof case."
        }
    }

    Write-Output ("PASS R4 proof review subset execution: {0}" -f $tempRoot)
}
catch {
    $failures += ("FAIL R4 proof review subset execution: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R4 hardening proof review tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All R4 hardening proof review tests passed."
