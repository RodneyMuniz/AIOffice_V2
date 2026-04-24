$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModule = Import-Module (Join-Path $repoRoot "tools\MilestoneContinuityProofReview.psm1") -Force -PassThru
$invokeProofReviewFlow = $proofReviewModule.ExportedCommands["Invoke-MilestoneContinuityProofReviewFlow"]
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
    $packageRoot = Join-Path $tempRoot "proof-review"
    $proofFlow = & $invokeProofReviewFlow -RepositoryRoot $repoRoot -OutputRoot $packageRoot
    $validation = & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot

    foreach ($requiredPath in @(
            (Join-Path $proofFlow.PackageRoot "proof_review_manifest.json"),
            (Join-Path $proofFlow.PackageRoot "REPLAY_SUMMARY.md"),
            (Join-Path $proofFlow.PackageRoot "CLOSEOUT_REVIEW.md"),
            (Join-Path $proofFlow.PackageRoot "meta\proof_selection_scope.json"),
            (Join-Path $proofFlow.PackageRoot "meta\replay_source.json"),
            (Join-Path $proofFlow.PackageRoot "meta\authoritative_artifact_refs.json"),
            (Join-Path $proofFlow.PackageRoot "meta\replayed_commands.txt"),
            (Join-Path $proofFlow.PackageRoot "raw_logs\replay_steps.log"),
            (Join-Path $proofFlow.PackageRoot "raw_logs\replay_events.jsonl"),
            (Join-Path $proofFlow.PackageRoot "artifacts\summary\summaries\summary-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"),
            (Join-Path $proofFlow.PackageRoot "artifacts\closeout\closeout_packets\closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001.json")
        )) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            $failures += ("FAIL valid: required proof-review path missing '{0}'." -f $requiredPath)
        }
    }

    if ($validation.ReplaySourceHeadCommit -ne (git -C $repoRoot rev-parse HEAD).Trim()) {
        $failures += "FAIL valid: proof-review validation did not preserve current replay-source head."
    }
    else {
        Write-Output ("PASS valid proof-review package: {0}" -f $validation.PackageRoot)
        $validPassed += 1
    }

    $stepLogPath = Join-Path $proofFlow.PackageRoot "raw_logs\replay_steps.log"
    $stepLogBackup = Get-Content -LiteralPath $stepLogPath -Raw
    try {
        Remove-Item -LiteralPath $stepLogPath -Force
        Invoke-ExpectedRefusal -Label "missing-raw-log" -RequiredFragments @("Raw log") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $stepLogPath -Value $stepLogBackup
    }

    $replaySourcePath = Join-Path $proofFlow.PackageRoot "meta\replay_source.json"
    $replaySourceBackup = Get-Content -LiteralPath $replaySourcePath -Raw
    try {
        Remove-Item -LiteralPath $replaySourcePath -Force
        Invoke-ExpectedRefusal -Label "missing-replay-source" -RequiredFragments @("Replay source metadata") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $replaySourcePath -Value $replaySourceBackup
    }

    $artifactRefsPath = Join-Path $proofFlow.PackageRoot "meta\authoritative_artifact_refs.json"
    $artifactRefsBackup = Get-Content -LiteralPath $artifactRefsPath -Raw
    try {
        $artifactRefs = Get-JsonDocument -Path $artifactRefsPath
        $artifactRefs.rollback_proof_refs.PSObject.Properties.Remove("operator_packet_ref")
        Write-JsonDocument -Path $artifactRefsPath -Document $artifactRefs
        Invoke-ExpectedRefusal -Label "missing-operator-packet-ref" -RequiredFragments @("operator_packet_ref") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $artifactRefsPath -Value $artifactRefsBackup
    }

    $nonClaimsPath = Join-Path $proofFlow.PackageRoot "meta\non_claims.json"
    $nonClaimsBackup = Get-Content -LiteralPath $nonClaimsPath -Raw
    try {
        Write-JsonDocument -Path $nonClaimsPath -Document @("no_ui")
        Invoke-ExpectedRefusal -Label "missing-explicit-non-claims" -RequiredFragments @("must be an array") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $nonClaimsPath -Value $nonClaimsBackup
    }

    $closeoutPacketPath = Join-Path $proofFlow.PackageRoot "artifacts\closeout\closeout_packets\closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
    $closeoutPacketBackup = Get-Content -LiteralPath $closeoutPacketPath -Raw
    try {
        $closeoutPacket = Get-JsonDocument -Path $closeoutPacketPath
        $closeoutPacket.automatic_execution_implied = $true
        Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket
        Invoke-ExpectedRefusal -Label "automatic-execution-implication" -RequiredFragments @("automatic execution") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
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
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $closeoutPacketPath -Value $closeoutPacketBackup
    }

    $summaryPath = Join-Path $proofFlow.PackageRoot "artifacts\summary\summaries\summary-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
    $summaryBackup = Get-Content -LiteralPath $summaryPath -Raw
    try {
        $summary = Get-JsonDocument -Path $summaryPath
        $summary.command_results[0].status = "failed"
        Write-JsonDocument -Path $summaryPath -Document $summary
        Invoke-ExpectedRefusal -Label "malformed-summary-command-state" -RequiredFragments @("must be one of: passed") -Action {
            & $testProofReviewPackage -PackageRoot $proofFlow.PackageRoot | Out-Null
        }
    }
    finally {
        Write-Utf8File -Path $summaryPath -Value $summaryBackup
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
