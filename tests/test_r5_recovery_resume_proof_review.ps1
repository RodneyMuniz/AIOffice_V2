$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofScriptPath = Join-Path $repoRoot "tools\new_r5_recovery_resume_proof_review.ps1"
$failures = @()

$tempRoot = Join-Path $env:TEMP ("aioffice-r5-proof-review-test-" + [guid]::NewGuid().ToString("N"))
try {
    & powershell -ExecutionPolicy Bypass -File $proofScriptPath -OutputRoot $tempRoot -TestIds "r5-milestone-baseline,r5-restore-gate,r5-resume-reentry,r5-repo-enforcement" -CloseoutPlanPath "governance/R5_PROOF_AND_CLOSEOUT_PLAN.md" -SkipRepoEnforcementWorktreeCheck | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw ("R5 proof review script exited with code {0}." -f $LASTEXITCODE)
    }

    $summaryPath = Join-Path $tempRoot "bounded-proof-suite-summary.json"
    $replaySummaryPath = Join-Path $tempRoot "REPLAY_SUMMARY.md"
    $replayedCommandPath = Join-Path $tempRoot "meta\replayed_command.txt"
    $repoEnforcementDirectory = Join-Path $tempRoot "repo_enforcement"

    foreach ($path in @($summaryPath, $replaySummaryPath, $replayedCommandPath, $repoEnforcementDirectory)) {
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += ("FAIL R5 proof review output missing: {0}" -f $path)
        }
    }

    if (Test-Path -LiteralPath $summaryPath) {
        $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
        if ($summary.failed_count -ne 0) {
            $failures += "FAIL R5 proof review summary recorded failures unexpectedly."
        }
        if ($summary.passed_count -ne 4) {
            $failures += ("FAIL R5 proof review passed count was {0}, expected 4." -f $summary.passed_count)
        }
    }

    if (Test-Path -LiteralPath $replaySummaryPath) {
        $replaySummaryText = Get-Content -LiteralPath $replaySummaryPath -Raw
        if ($replaySummaryText -notmatch "r5-milestone-baseline") {
            $failures += "FAIL R5 proof review summary did not preserve the selected milestone-baseline proof case."
        }
        if ($replaySummaryText -notmatch "r5-resume-reentry") {
            $failures += "FAIL R5 proof review summary did not preserve the selected resume-reentry proof case."
        }
        if ($replaySummaryText -notmatch "Repo enforcement") {
            $failures += "FAIL R5 proof review summary did not include the repo-enforcement section."
        }
    }

    Write-Output ("PASS R5 proof review subset execution: {0}" -f $tempRoot)
}
catch {
    $failures += ("FAIL R5 proof review subset execution: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R5 recovery, resume, and repo-enforcement proof review tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All R5 recovery, resume, and repo-enforcement proof review tests passed."
