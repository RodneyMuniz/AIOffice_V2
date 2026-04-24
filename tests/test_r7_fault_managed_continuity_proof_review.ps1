$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModule = Import-Module (Join-Path $repoRoot "tools\MilestoneContinuityProofReview.psm1") -Force -PassThru
$testProofReviewPackage = $proofReviewModule.ExportedCommands["Test-MilestoneContinuityProofReviewPackage"]

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

    $Document | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Add-SupportManifestCoverage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageRoot
    )

    $manifestPath = Join-Path $PackageRoot "proof_review_manifest.json"
    $manifest = Get-JsonDocument -Path $manifestPath
    $supportRoot = Join-Path $PackageRoot "support\proof_hardening"
    $supportLogsRoot = Join-Path $supportRoot "logs"
    New-Item -ItemType Directory -Path $supportLogsRoot -Force | Out-Null

    $validatorStdoutRef = "support/proof_hardening/logs/validate_proof_review.stdout.log"
    $validatorStderrRef = "support/proof_hardening/logs/validate_proof_review.stderr.log"
    $proofTestStdoutRef = "support/proof_hardening/logs/test_r7_fault_managed_continuity_proof_review.stdout.log"
    $proofTestStderrRef = "support/proof_hardening/logs/test_r7_fault_managed_continuity_proof_review.stderr.log"

    Write-Utf8File -Path (Join-Path $PackageRoot $validatorStdoutRef) -Value "VALID: support validator log"
    Write-Utf8File -Path (Join-Path $PackageRoot $validatorStderrRef) -Value ""
    Write-Utf8File -Path (Join-Path $PackageRoot $proofTestStdoutRef) -Value "PASS: support proof-review test log"
    Write-Utf8File -Path (Join-Path $PackageRoot $proofTestStderrRef) -Value ""

    $supportManifest = [ordered]@{
        support_kind = "r7_proof_hardening_support"
        correction_purpose = "Bounded R7 proof-hardening support-log linkage for claimed replay commands."
        original_replay_source = [ordered]@{
            head_commit = "fce96fb35c3d1ff8d2676d470ccfe81ae3cb6905"
            tree_id = "3b55d697b6206a62967800cd78bc4f3b39b99858"
        }
        accepted_r7_closeout_head_before_correction = "7549b0200eaaa790940450159c6503ad57d1f6e3"
        correction_commit_head = $null
        branch = "feature/r5-closeout-remaining-foundations"
        local_head = "7549b0200eaaa790940450159c6503ad57d1f6e3"
        remote_head = "7549b0200eaaa790940450159c6503ad57d1f6e3"
        tree_hash = "6e48cd27c3fe971588fd213a4e8f77d80bac8d75"
        command_list = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_continuity_proof_review.ps1 -PackageRoot state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
        )
        command_records = @(
            [ordered]@{
                command_id = "validate-proof-review"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_continuity_proof_review.ps1 -PackageRoot state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill"
                stdout_log_ref = $validatorStdoutRef
                stderr_log_ref = $validatorStderrRef
                exit_code = 0
                classification = "support_hardening_logs"
            },
            [ordered]@{
                command_id = "test-r7-proof-review"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
                stdout_log_ref = $proofTestStdoutRef
                stderr_log_ref = $proofTestStderrRef
                exit_code = 0
                classification = "support_hardening_logs"
            }
        )
        raw_log_refs = @(
            $validatorStdoutRef,
            $validatorStderrRef,
            $proofTestStdoutRef,
            $proofTestStderrRef
        )
        exit_codes = [ordered]@{
            "validate-proof-review" = 0
            "test-r7-proof-review" = 0
        }
        timestamp_utc = "2026-04-25T00:00:00Z"
        result = "passed"
        note = "These are support-hardening logs only and not replacement original replay logs."
        claimed_command_log_coverage = @(
            [ordered]@{
                command = "powershell -ExecutionPolicy Bypass -File tools\new_r7_fault_managed_continuity_proof_review.ps1 -OutputRoot state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill"
                log_refs = @(
                    "raw_logs/replay_steps.log",
                    "raw_logs/replay_events.jsonl"
                )
                classification = "original_replay_logs"
                note = "Original replay package logs preserved as original replay evidence only."
            },
            [ordered]@{
                command = "powershell -ExecutionPolicy Bypass -File tools\validate_milestone_continuity_proof_review.ps1 -PackageRoot state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill"
                log_refs = @(
                    $validatorStdoutRef,
                    $validatorStderrRef
                )
                classification = "support_hardening_logs"
                note = "Support-hardening validator rerun only; not replacement original replay log."
            },
            [ordered]@{
                command = "powershell -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
                log_refs = @(
                    $proofTestStdoutRef,
                    $proofTestStderrRef
                )
                classification = "support_hardening_logs"
                note = "Support-hardening proof-review rerun only; not replacement original replay log."
            }
        )
    }

    $supportManifestPath = Join-Path $supportRoot "support_manifest.json"
    Write-JsonDocument -Path $supportManifestPath -Document $supportManifest
    $manifest | Add-Member -NotePropertyName support_manifest_ref -NotePropertyValue "support/proof_hardening/support_manifest.json" -Force
    Write-JsonDocument -Path $manifestPath -Document $manifest
}

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

$failures = @()
$validPassed = 0
$invalidRejected = 0

$shortBase = "C:\t"
if (-not (Test-Path -LiteralPath $shortBase)) {
    New-Item -ItemType Directory -Path $shortBase -Force | Out-Null
}

$tempRoot = Join-Path $shortBase ("r7prf" + [guid]::NewGuid().ToString("N").Substring(0, 8))
try {
    $packageRoot = Join-Path $tempRoot "state\proof_reviews\r7_fault_managed_continuity_and_rollback_drill"
    New-Item -ItemType Directory -Path (Split-Path -Parent $packageRoot) -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "state\fixtures") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "governance") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot "execution") -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot "state\proof_reviews\r7_fault_managed_continuity_and_rollback_drill") -Destination $packageRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "state\fixtures\valid") -Destination (Join-Path $tempRoot "state\fixtures\valid") -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "README.md") -Destination (Join-Path $tempRoot "README.md") -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "governance\ACTIVE_STATE.md") -Destination (Join-Path $tempRoot "governance\ACTIVE_STATE.md") -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "governance\DECISION_LOG.md") -Destination (Join-Path $tempRoot "governance\DECISION_LOG.md") -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "governance\R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md") -Destination (Join-Path $tempRoot "governance\R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md") -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "execution\KANBAN.md") -Destination (Join-Path $tempRoot "execution\KANBAN.md") -Force
    Add-SupportManifestCoverage -PackageRoot $packageRoot
    $validation = & $testProofReviewPackage -PackageRoot $packageRoot

    foreach ($requiredPath in @(
            (Join-Path $packageRoot "proof_review_manifest.json"),
            (Join-Path $packageRoot "REPLAY_SUMMARY.md"),
            (Join-Path $packageRoot "CLOSEOUT_REVIEW.md"),
            (Join-Path $packageRoot "support\proof_hardening\support_manifest.json"),
            (Join-Path $packageRoot "meta\proof_selection_scope.json"),
            (Join-Path $packageRoot "meta\replay_source.json"),
            (Join-Path $packageRoot "meta\authoritative_artifact_refs.json"),
            (Join-Path $packageRoot "meta\replayed_commands.txt"),
            (Join-Path $packageRoot "raw_logs\replay_steps.log"),
            (Join-Path $packageRoot "raw_logs\replay_events.jsonl"),
            (Join-Path $packageRoot "artifacts\summary\summaries\summary-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"),
            (Join-Path $packageRoot "artifacts\closeout\closeout_packets\closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001.json")
        )) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            $failures += ("FAIL valid: required proof-review path missing '{0}'." -f $requiredPath)
        }
    }

    if ($validation.ReplaySourceHeadCommit -ne "fce96fb35c3d1ff8d2676d470ccfe81ae3cb6905") {
        $failures += "FAIL valid: proof-review validation did not preserve the original R7 replay-source head."
    }
    else {
        Write-Output ("PASS valid proof-review package: {0}" -f $validation.PackageRoot)
        $validPassed += 1
    }

    $stepLogPath = Join-Path $packageRoot "raw_logs\replay_steps.log"
    $stepLogBackup = Get-Content -LiteralPath $stepLogPath -Raw
    try {
        Remove-Item -LiteralPath $stepLogPath -Force
        Invoke-ExpectedRefusal -Label "missing-raw-log" -RequiredFragments @("does not exist", "raw_logs/replay_steps.log") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $stepLogPath -Value $stepLogBackup
    }

    $replaySourcePath = Join-Path $packageRoot "meta\replay_source.json"
    $replaySourceBackup = Get-Content -LiteralPath $replaySourcePath -Raw
    try {
        Remove-Item -LiteralPath $replaySourcePath -Force
        Invoke-ExpectedRefusal -Label "missing-replay-source" -RequiredFragments @("Replay source metadata") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $replaySourcePath -Value $replaySourceBackup
    }

    $artifactRefsPath = Join-Path $packageRoot "meta\authoritative_artifact_refs.json"
    $artifactRefsBackup = Get-Content -LiteralPath $artifactRefsPath -Raw
    try {
        $artifactRefs = Get-JsonDocument -Path $artifactRefsPath
        $artifactRefs.rollback_proof_refs.PSObject.Properties.Remove("operator_packet_ref")
        Write-JsonDocument -Path $artifactRefsPath -Document $artifactRefs
        Invoke-ExpectedRefusal -Label "missing-operator-packet-ref" -RequiredFragments @("operator_packet_ref") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $artifactRefsPath -Value $artifactRefsBackup
    }

    $nonClaimsPath = Join-Path $packageRoot "meta\non_claims.json"
    $nonClaimsBackup = Get-Content -LiteralPath $nonClaimsPath -Raw
    try {
        Write-JsonDocument -Path $nonClaimsPath -Document @("no_ui")
        Invoke-ExpectedRefusal -Label "missing-explicit-non-claims" -RequiredFragments @("must be an array") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $nonClaimsPath -Value $nonClaimsBackup
    }

    $closeoutPacketPath = Join-Path $packageRoot "artifacts\closeout\closeout_packets\closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
    $closeoutPacketBackup = Get-Content -LiteralPath $closeoutPacketPath -Raw
    try {
        $closeoutPacket = Get-JsonDocument -Path $closeoutPacketPath
        $closeoutPacket.automatic_execution_implied = $true
        Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket
        Invoke-ExpectedRefusal -Label "automatic-execution-implication" -RequiredFragments @("automatic execution") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $closeoutPacketPath -Value $closeoutPacketBackup
    }

    try {
        $closeoutPacket = Get-JsonDocument -Path $closeoutPacketPath
        $closeoutPacket.destructive_primary_worktree_rollback_implied = $true
        Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket
        Invoke-ExpectedRefusal -Label "destructive-rollback-implication" -RequiredFragments @("destructive primary-worktree rollback") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $closeoutPacketPath -Value $closeoutPacketBackup
    }

    $summaryPath = Join-Path $packageRoot "artifacts\summary\summaries\summary-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
    $summaryBackup = Get-Content -LiteralPath $summaryPath -Raw
    try {
        $summary = Get-JsonDocument -Path $summaryPath
        $summary.command_results[0].status = "failed"
        Write-JsonDocument -Path $summaryPath -Document $summary
        Invoke-ExpectedRefusal -Label "malformed-summary-command-state" -RequiredFragments @("must be one of: passed") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $summaryPath -Value $summaryBackup
    }

    $supportManifestPath = Join-Path $packageRoot "support\proof_hardening\support_manifest.json"
    $supportManifestBackup = Get-Content -LiteralPath $supportManifestPath -Raw
    try {
        $supportManifest = Get-JsonDocument -Path $supportManifestPath
        $supportManifest.claimed_command_log_coverage = @($supportManifest.claimed_command_log_coverage | Where-Object {
                $_.command -ne "powershell -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
            })
        Write-JsonDocument -Path $supportManifestPath -Document $supportManifest
        Invoke-ExpectedRefusal -Label "missing-claimed-command-log-coverage" -RequiredFragments @("Claimed replay command", "test_r7_fault_managed_continuity_proof_review.ps1") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $supportManifestPath -Value $supportManifestBackup
    }
}
catch {
    $failures += ("FAIL proof-review flow: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R7 fault-managed continuity proof-review tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R7 fault-managed continuity proof-review tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
