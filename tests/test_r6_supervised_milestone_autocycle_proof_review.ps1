$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofReviewModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleProofReview.psm1") -Force -PassThru
$invokeProofReviewFlow = $proofReviewModule.ExportedCommands["Invoke-MilestoneAutocycleProofReviewFlow"]
$testProofReviewPackage = $proofReviewModule.ExportedCommands["Test-MilestoneAutocycleProofReviewPackage"]

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

    $json = $Document | ConvertTo-Json -Depth 30
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-TempGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    & git -C $Root init | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize temp Git repository."
    }

    & git -C $Root config core.autocrlf false | Out-Null
    & git -C $Root config core.safecrlf false | Out-Null
    & git -C $Root config user.email "codex@example.com" | Out-Null
    & git -C $Root config user.name "Codex" | Out-Null

    Set-Content -LiteralPath (Join-Path $Root "README.md") -Value "# Temp repo" -Encoding UTF8
    New-Item -ItemType Directory -Path (Join-Path $Root "state\fixtures\valid") -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle") -Destination (Join-Path $Root "state\fixtures\valid") -Recurse -Force

    & git -C $Root add README.md state/fixtures/valid/milestone_autocycle | Out-Null
    & git -C $Root commit -m "seed proof review fixtures" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create initial temp Git commit."
    }
}

function Invoke-ExpectedRefusalWithMessage {
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
        $script:failures += ("FAIL {0}: operation succeeded unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL {0}: refusal message did not include expected fragments: {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS {0}: {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        $script:failures += ("FAIL {0}: missing '{1}'." -f $Label, $Path)
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

$shortBase = "C:\t"
if (-not (Test-Path -LiteralPath $shortBase)) {
    New-Item -ItemType Directory -Path $shortBase -Force | Out-Null
}

$tempRoot = Join-Path $shortBase ("r6prt" + [guid]::NewGuid().ToString("N").Substring(0, 8))
try {
    New-TempGitRepository -Root $tempRoot

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $proofFlow = & $invokeProofReviewFlow -RepositoryRoot $tempRoot -ProposalIntakePath "state/fixtures/valid/milestone_autocycle/proposal_intake.valid.json" -OutputRoot "state/proof_reviews/r6_supervised_milestone_autocycle_pilot"
    $sw.Stop()

    $packageRoot = $proofFlow.PackageRoot
    $manifestPath = Join-Path $packageRoot "proof_review_manifest.json"
    $selectionScopePath = Join-Path $packageRoot "meta\proof_selection_scope.json"
    $replaySourcePath = Join-Path $packageRoot "meta\replay_source.json"
    $artifactRefsPath = Join-Path $packageRoot "meta\authoritative_artifact_refs.json"
    $replaySummaryPath = Join-Path $packageRoot "REPLAY_SUMMARY.md"
    $closeoutReviewPath = Join-Path $packageRoot "CLOSEOUT_REVIEW.md"
    $stepLogPath = Join-Path $packageRoot "raw_logs\replay_steps.log"
    $eventLogPath = Join-Path $packageRoot "raw_logs\replay_events.jsonl"

    foreach ($requiredPath in @(
            @{ Path = $manifestPath; Label = "proof review manifest" },
            @{ Path = $selectionScopePath; Label = "proof selection scope" },
            @{ Path = $replaySourcePath; Label = "replay source metadata" },
            @{ Path = $artifactRefsPath; Label = "authoritative artifact refs" },
            @{ Path = $replaySummaryPath; Label = "replay summary" },
            @{ Path = $closeoutReviewPath; Label = "closeout review" },
            @{ Path = $stepLogPath; Label = "raw step log" },
            @{ Path = $eventLogPath; Label = "raw event log" }
        )) {
        Assert-PathExists -Path $requiredPath.Path -Label $requiredPath.Label
    }

    $replaySummaryText = Get-Content -LiteralPath $replaySummaryPath -Raw
    $closeoutReviewText = Get-Content -LiteralPath $closeoutReviewPath -Raw
    if ($replaySummaryText -notmatch "Exact replay scope") {
        $failures += "FAIL happy-path proof review: replay summary did not preserve the exact replay scope section."
    }
    if ($closeoutReviewText -notmatch "Exact closeout scope") {
        $failures += "FAIL happy-path proof review: closeout review did not preserve the exact closeout scope section."
    }

    if ($failures.Count -eq 0) {
        Write-Output ("PASS happy-path proof review package creation: {0} seconds" -f [math]::Round($sw.Elapsed.TotalSeconds, 2))
        $validPassed += 1
    }

    $stepLogBackup = Get-Content -LiteralPath $stepLogPath -Raw
    try {
        Remove-Item -LiteralPath $stepLogPath -Force
        Invoke-ExpectedRefusalWithMessage -Label "missing raw log refusal" -RequiredFragments @("raw log", "does not exist") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $stepLogPath -Value $stepLogBackup -Encoding UTF8
    }

    $replaySourceBackup = Get-Content -LiteralPath $replaySourcePath -Raw
    try {
        Remove-Item -LiteralPath $replaySourcePath -Force
        Invoke-ExpectedRefusalWithMessage -Label "missing replay-source metadata refusal" -RequiredFragments @("replay source metadata", "does not exist") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $replaySourcePath -Value $replaySourceBackup -Encoding UTF8
    }

    $selectionScopeBackup = Get-Content -LiteralPath $selectionScopePath -Raw
    try {
        Remove-Item -LiteralPath $selectionScopePath -Force
        Invoke-ExpectedRefusalWithMessage -Label "missing proof selection scope refusal" -RequiredFragments @("selection scope", "does not exist") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $selectionScopePath -Value $selectionScopeBackup -Encoding UTF8
    }

    $closeoutPacketPath = Join-Path $packageRoot "artifacts\closeout\closeout_packets\closeout-packet-r6-supervised-milestone-autocycle-pilot-proof-001.json"
    $closeoutPacketBackup = Get-Content -LiteralPath $closeoutPacketPath -Raw
    try {
        $mismatchedCloseoutPacket = Get-JsonDocument -Path $closeoutPacketPath
        $mismatchedCloseoutPacket.closeout_scope = "Exact closeout scope: mismatched scope for invalid replay validation."
        Write-JsonDocument -Path $closeoutPacketPath -Document $mismatchedCloseoutPacket
        Invoke-ExpectedRefusalWithMessage -Label "mismatched replay scope versus closeout wording refusal" -RequiredFragments @("exact replay scope", "closeout wording") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $closeoutPacketPath -Value $closeoutPacketBackup -Encoding UTF8
    }

    $replaySummaryBackup = Get-Content -LiteralPath $replaySummaryPath -Raw
    try {
        $summaryLinePattern = [regex]::Escape("state/proof_reviews/r6_supervised_milestone_autocycle_pilot/artifacts/summary/summaries/summary-r6-supervised-milestone-autocycle-pilot-proof-001.json")
        $missingSummaryReplaySummaryText = [regex]::Replace($replaySummaryBackup, $summaryLinePattern, "summary-lineage-redacted")
        Set-Content -LiteralPath $replaySummaryPath -Value $missingSummaryReplaySummaryText -Encoding UTF8
        Invoke-ExpectedRefusalWithMessage -Label "missing summary lineage refusal" -RequiredFragments @("summary lineage") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $replaySummaryPath -Value $replaySummaryBackup -Encoding UTF8
    }

    $closeoutReviewBackup = Get-Content -LiteralPath $closeoutReviewPath -Raw
    try {
        Set-Content -LiteralPath $closeoutReviewPath -Value ($closeoutReviewBackup + [Environment]::NewLine + "The operator chose accept.") -Encoding UTF8
        Invoke-ExpectedRefusalWithMessage -Label "executed operator decision misrepresentation refusal" -RequiredFragments @("advisory operator choice as executed") -Action {
            & $testProofReviewPackage -PackageRoot $packageRoot | Out-Null
        }
    }
    finally {
        Set-Content -LiteralPath $closeoutReviewPath -Value $closeoutReviewBackup -Encoding UTF8
    }
}
catch {
    $failures += ("FAIL proof review package flow: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R6 supervised milestone autocycle proof review tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output ("All R6 supervised milestone autocycle proof review tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
