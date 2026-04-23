$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\MilestoneContinuityLedger.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot
$faultEventFixture = Join-Path $repoRoot "state\fixtures\valid\fault_management\fault_event.valid.json"
$checkpointFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_checkpoint.valid.json"
$handoffFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_handoff_packet.valid.json"
$resumeRequestFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\resume_from_fault_request.valid.json"
$resumeResultFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\resume_from_fault_result.valid.json"
$ledgerFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_ledger.valid.json"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r7-005-" + [System.Guid]::NewGuid().ToString("N"))

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

try {
    $fixtureValidation = Test-MilestoneContinuityLedgerContract -LedgerPath $ledgerFixture
    Write-Output ("PASS valid continuity ledger fixture: {0} -> {1}" -f (Resolve-Path -Relative $ledgerFixture), $fixtureValidation.LedgerId)
    $validPassed += 1

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $emittedLedgerPath = Join-Path $tempRoot "continuity_ledger.emitted.json"
    $emittedLedger = Invoke-MilestoneContinuityLedgerStitch `
        -FaultEventPath $faultEventFixture `
        -CheckpointPath $checkpointFixture `
        -HandoffPacketPath $handoffFixture `
        -ResumeRequestPath $resumeRequestFixture `
        -ResumeResultPath $resumeResultFixture `
        -SuccessorSegmentId "segment-r7-005-002" `
        -LedgerPath $emittedLedgerPath `
        -LedgerId "continuity-ledger-r7-005-002"
    $emittedValidation = Test-MilestoneContinuityLedgerContract -LedgerPath $emittedLedger.LedgerPath
    $emittedDocument = Get-JsonDocument -Path $emittedLedger.LedgerPath

    Write-Output ("PASS stitched continuity ledger: {0} -> {1}" -f $emittedValidation.InterruptedSegmentId, $emittedValidation.SuccessorSegmentId)
    if ($emittedDocument.ledger_continuity_state -ne "stitched_interrupted_to_supervised_resume") {
        $failures += "FAIL valid stitched continuity ledger: ledger_continuity_state drifted."
    }
    if ($emittedDocument.non_claims -notcontains "stitching_only_no_rollback_plan_no_rollback_drill_no_unattended_recovery") {
        $failures += "FAIL valid stitched continuity ledger: required bounded non-claim was lost."
    }
    $validPassed += 1

    $validLedger = Get-JsonDocument -Path $ledgerFixture
    $invalidCases = @(
        @{
            Name = "missing-prior-link"
            Mutate = {
                param($Document)
                $Document.ordered_segments[1].PSObject.Properties.Remove("prior_segment_id")
                return $Document
            }
        },
        @{
            Name = "contradictory-segment-ordering"
            Mutate = {
                param($Document)
                $Document.ordered_segments[0].ordinal = 2
                return $Document
            }
        },
        @{
            Name = "repository-mismatch"
            Mutate = {
                param($Document)
                $Document.repository.repository_name = "OtherRepo"
                return $Document
            }
        },
        @{
            Name = "git-context-mismatch"
            Mutate = {
                param($Document)
                $Document.ordered_segments[1].git_context.tree_id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                return $Document
            }
        },
        @{
            Name = "milestone-cycle-mismatch"
            Mutate = {
                param($Document)
                $Document.cycle_context.milestone_id = "milestone-r7-other"
                return $Document
            }
        },
        @{
            Name = "identity-drift-across-stitched-segments"
            Mutate = {
                param($Document)
                $Document.ordered_segments[1].task_id = "task-r7-005-other-001"
                return $Document
            }
        },
        @{
            Name = "malformed-ledger-state"
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("ordered_segments")
                return $Document
            }
        }
    )

    foreach ($invalidCase in @($invalidCases)) {
        $invalidLedger = Copy-JsonObject -Object $validLedger
        $invalidLedger = & $invalidCase.Mutate $invalidLedger

        try {
            Test-MilestoneContinuityLedgerObject -Ledger $invalidLedger -SourceLabel $invalidCase.Name | Out-Null
            $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $invalidCase.Name)
        }
        catch {
            Write-Output ("PASS invalid: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
            $invalidRejected += 1
        }
    }
}
catch {
    $failures += ("FAIL milestone continuity ledger harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Force -Recurse
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone continuity ledger tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone continuity ledger tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
