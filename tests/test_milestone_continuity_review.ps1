$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$reviewModule = Import-Module (Join-Path $repoRoot "tools\MilestoneContinuityReview.psm1") -Force -PassThru

$invokeContinuityAdvisoryReviewFlow = $reviewModule.ExportedCommands["Invoke-MilestoneContinuityAdvisoryReviewFlow"]
$testMilestoneContinuityReviewSummaryContract = $reviewModule.ExportedCommands["Test-MilestoneContinuityReviewSummaryContract"]
$testMilestoneContinuityReviewSummaryObject = $reviewModule.ExportedCommands["Test-MilestoneContinuityReviewSummaryObject"]
$testMilestoneContinuityOperatorPacketContract = $reviewModule.ExportedCommands["Test-MilestoneContinuityOperatorPacketContract"]
$testMilestoneContinuityOperatorPacketObject = $reviewModule.ExportedCommands["Test-MilestoneContinuityOperatorPacketObject"]

$ledgerFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_ledger.valid.json"
$rollbackPlanFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\rollback_plan.valid.json"
$rollbackDrillFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\rollback_drill_result.valid.json"
$reviewSummaryFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\review_summaries\review-summary-r7-008-001.json"
$operatorPacketFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\operator_packets\operator-packet-r7-008-001.json"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return (ConvertFrom-Json ($Object | ConvertTo-Json -Depth 20))
}

function Get-PortableReviewSummary {
    $reviewSummary = Copy-JsonObject -Object (Get-JsonDocument -Path $reviewSummaryFixture)
    $reviewSummary.evidence_refs.continuity_ledger_ref.ledger_path = (Resolve-Path -LiteralPath $ledgerFixture).Path
    $reviewSummary.evidence_refs.rollback_plan_ref.rollback_plan_path = (Resolve-Path -LiteralPath $rollbackPlanFixture).Path
    $reviewSummary.evidence_refs.rollback_drill_result_ref.drill_result_path = (Resolve-Path -LiteralPath $rollbackDrillFixture).Path
    return $reviewSummary
}

function Get-PortableOperatorPacket {
    $operatorPacket = Copy-JsonObject -Object (Get-JsonDocument -Path $operatorPacketFixture)
    $operatorPacket.review_summary_ref.review_summary_path = (Resolve-Path -LiteralPath $reviewSummaryFixture).Path
    return $operatorPacket
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r7-008-" + [guid]::NewGuid().ToString("N"))
    try {
        $generatedOutputRoot = Join-Path $tempRoot "generated-review"
        $generatedFlow = & $invokeContinuityAdvisoryReviewFlow -ContinuityLedgerPath $ledgerFixture -RollbackPlanPath $rollbackPlanFixture -RollbackDrillResultPath $rollbackDrillFixture -OutputRoot $generatedOutputRoot -ReviewSummaryId "review-summary-r7-008-test-001" -OperatorPacketId "operator-packet-r7-008-test-001" -ReviewedAt ([datetime]::Parse("2026-04-24T06:05:00Z").ToUniversalTime())
        $generatedSummaryCheck = & $testMilestoneContinuityReviewSummaryContract -ReviewSummaryPath $generatedFlow.ReviewSummaryPath
        $generatedPacketCheck = & $testMilestoneContinuityOperatorPacketContract -OperatorPacketPath $generatedFlow.OperatorPacketPath

        if ($generatedSummaryCheck.Recommendation -ne "advance_to_r7_009" -or -not $generatedSummaryCheck.RecommendationIsAdvisory) {
            $failures += "FAIL valid generated review summary: advisory recommendation drifted."
        }
        else {
            Write-Output ("PASS valid generated review summary: {0}" -f $generatedSummaryCheck.ReviewSummaryId)
            $validPassed += 1
        }

        if ($generatedPacketCheck.Recommendation -ne "advance_to_r7_009" -or -not $generatedPacketCheck.ManualOperatorDecisionRequired) {
            $failures += "FAIL valid generated operator packet: bounded operator decision state drifted."
        }
        else {
            Write-Output ("PASS valid generated operator packet: {0}" -f $generatedPacketCheck.OperatorPacketId)
            $validPassed += 1
        }

        $fixtureSummaryCheck = & $testMilestoneContinuityReviewSummaryContract -ReviewSummaryPath $reviewSummaryFixture
        $fixturePacketCheck = & $testMilestoneContinuityOperatorPacketContract -OperatorPacketPath $operatorPacketFixture

        if ($fixtureSummaryCheck.ReviewSummaryId -ne "review-summary-r7-008-001" -or $fixturePacketCheck.OperatorPacketId -ne "operator-packet-r7-008-001") {
            $failures += "FAIL valid committed review fixtures: committed advisory fixture identity drifted."
        }
        else {
            Write-Output "PASS valid committed review fixtures."
            $validPassed += 1
        }

        Invoke-ExpectedRefusal -Label "missing-rollback-drill-result" -Action {
            & $invokeContinuityAdvisoryReviewFlow -ContinuityLedgerPath $ledgerFixture -RollbackPlanPath $rollbackPlanFixture -RollbackDrillResultPath (Join-Path $tempRoot "missing\rollback_drill_result.valid.json") -OutputRoot (Join-Path $tempRoot "missing-drill-review") | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing-rollback-plan" -Action {
            & $invokeContinuityAdvisoryReviewFlow -ContinuityLedgerPath $ledgerFixture -RollbackPlanPath (Join-Path $tempRoot "missing\rollback_plan.valid.json") -RollbackDrillResultPath $rollbackDrillFixture -OutputRoot (Join-Path $tempRoot "missing-plan-review") | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing-continuity-ledger" -Action {
            & $invokeContinuityAdvisoryReviewFlow -ContinuityLedgerPath (Join-Path $tempRoot "missing\continuity_ledger.valid.json") -RollbackPlanPath $rollbackPlanFixture -RollbackDrillResultPath $rollbackDrillFixture -OutputRoot (Join-Path $tempRoot "missing-ledger-review") | Out-Null
        }

        $portableReviewSummary = Get-PortableReviewSummary
        $portableOperatorPacket = Get-PortableOperatorPacket

        $invalidRepositorySummary = Copy-JsonObject -Object $portableReviewSummary
        $invalidRepositorySummary.repository.repository_name = "OtherRepo"
        Invoke-ExpectedRefusal -Label "repository-mismatch" -Action {
            & $testMilestoneContinuityReviewSummaryObject -ReviewSummary $invalidRepositorySummary -SourceLabel "repository-mismatch" | Out-Null
        }

        $invalidCycleSummary = Copy-JsonObject -Object $portableReviewSummary
        $invalidCycleSummary.cycle_context.cycle_id = "cycle-r7-invalid-001"
        Invoke-ExpectedRefusal -Label "cycle-mismatch" -Action {
            & $testMilestoneContinuityReviewSummaryObject -ReviewSummary $invalidCycleSummary -SourceLabel "cycle-mismatch" | Out-Null
        }

        $invalidAutomaticExecutionPacket = Copy-JsonObject -Object $portableOperatorPacket
        $invalidAutomaticExecutionPacket.automatic_execution_implied = $true
        Invoke-ExpectedRefusal -Label "packet-implies-automatic-execution" -Action {
            & $testMilestoneContinuityOperatorPacketObject -OperatorPacket $invalidAutomaticExecutionPacket -SourceLabel "packet-implies-automatic-execution" | Out-Null
        }

        $invalidDestructivePacket = Copy-JsonObject -Object $portableOperatorPacket
        $invalidDestructivePacket.destructive_primary_worktree_rollback_implied = $true
        Invoke-ExpectedRefusal -Label "packet-implies-destructive-rollback" -Action {
            & $testMilestoneContinuityOperatorPacketObject -OperatorPacket $invalidDestructivePacket -SourceLabel "packet-implies-destructive-rollback" | Out-Null
        }

        $invalidNonClaimsSummary = Copy-JsonObject -Object $portableReviewSummary
        $invalidNonClaimsSummary.non_claims = @("no_ui")
        Invoke-ExpectedRefusal -Label "missing-explicit-non-claims" -Action {
            & $testMilestoneContinuityReviewSummaryObject -ReviewSummary $invalidNonClaimsSummary -SourceLabel "missing-explicit-non-claims" | Out-Null
        }

        $malformedReviewSummary = Copy-JsonObject -Object $portableReviewSummary
        $malformedReviewSummary.evidence_snapshot = "bad-state"
        Invoke-ExpectedRefusal -Label "malformed-advisory-review-state" -Action {
            & $testMilestoneContinuityReviewSummaryObject -ReviewSummary $malformedReviewSummary -SourceLabel "malformed-advisory-review-state" | Out-Null
        }

        $malformedOperatorPacket = Copy-JsonObject -Object $portableOperatorPacket
        $malformedOperatorPacket.operator_options = @("advance_to_r7_009")
        Invoke-ExpectedRefusal -Label "malformed-operator-packet-state" -Action {
            & $testMilestoneContinuityOperatorPacketObject -OperatorPacket $malformedOperatorPacket -SourceLabel "malformed-operator-packet-state" | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL continuity review harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone continuity review tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone continuity review tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
