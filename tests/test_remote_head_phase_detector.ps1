$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\RemoteHeadPhaseDetector.psm1") -Force -PassThru
$testDetection = $module.ExportedCommands["Test-RemoteHeadPhaseDetectionContract"]
$assertReady = $module.ExportedCommands["Assert-RemoteHeadPhaseReady"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\remote_head_phase"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\remote_head_phase"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

try {
    foreach ($case in @(
            @{ Label = "phase_match"; Path = "phase_match.valid.json"; Outcome = "phase_match" },
            @{ Label = "advanced_remote_head"; Path = "advanced_remote_head.valid.json"; Outcome = "advanced_remote_head" },
            @{ Label = "r11_009_like_stale_head"; Path = "r11_009_stale_expected_head.valid.json"; Outcome = "advanced_remote_head" }
        )) {
        $result = & $testDetection -DetectionPath (Join-Path $validRoot $case.Path)
        & $assertReady -DetectionResult $result -SourceLabel $case.Label | Out-Null
        if ($result.Outcome -ne $case.Outcome) {
            $failures += ("FAIL valid: {0} expected {1}, got {2}." -f $case.Label, $case.Outcome, $result.Outcome)
            continue
        }
        Write-Output ("PASS valid: {0} -> {1}" -f $case.Label, $result.Outcome)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-branch-mismatch" -RequiredFragments @("failed closed", "branch_mismatch") -Action {
        $result = & $testDetection -DetectionPath (Join-Path $invalidRoot "branch_mismatch.invalid.json")
        & $assertReady -DetectionResult $result -SourceLabel "branch_mismatch" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-dirty-worktree" -RequiredFragments @("failed closed", "dirty_worktree_blocked") -Action {
        $result = & $testDetection -DetectionPath (Join-Path $invalidRoot "dirty_worktree.invalid.json")
        & $assertReady -DetectionResult $result -SourceLabel "dirty_worktree" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-unknown-remote-head" -RequiredFragments @("failed closed", "unknown_remote_head") -Action {
        $result = & $testDetection -DetectionPath (Join-Path $invalidRoot "unknown_remote_head.invalid.json")
        & $assertReady -DetectionResult $result -SourceLabel "unknown_remote_head" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-evidence-refs" -RequiredFragments @("evidence_refs", "must not be empty") -Action {
        & $testDetection -DetectionPath (Join-Path $invalidRoot "missing_evidence_refs.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-remote-ref" -RequiredFragments @("remote_ref", "non-empty string") -Action {
        & $testDetection -DetectionPath (Join-Path $invalidRoot "missing_remote_ref.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL remote-head phase detector harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Remote-head phase detector tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All remote-head phase detector tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
