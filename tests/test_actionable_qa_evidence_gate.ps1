$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ActionableQaEvidenceGate.psm1") -Force -PassThru
$testGate = $module.ExportedCommands["Test-ActionableQaEvidenceGate"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa_evidence_gate"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa_evidence_gate"
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
    $passedGate = & $testGate -GatePath (Join-Path $validRoot "cycle_qa_evidence_gate.passed.valid.json")
    if ($passedGate.GateVerdict -ne "passed" -or $passedGate.BlockingIssueCount -ne 0) {
        $failures += "FAIL valid: passed fixture did not validate as passed with no blocking issues."
    }
    else {
        Write-Output ("PASS valid mocked external evidence gate fixture: {0}" -f $passedGate.GateId)
        $validPassed += 1
    }

    $blockedGate = & $testGate -GatePath (Join-Path $validRoot "cycle_qa_evidence_gate.missing-external.blocked.valid.json")
    if ($blockedGate.GateVerdict -ne "blocked" -or $blockedGate.RefusalReasonCount -lt 1) {
        $failures += "FAIL valid: missing external evidence fixture did not validate as blocked/refused posture."
    }
    else {
        Write-Output ("PASS valid missing external evidence gate fixture: {0}" -f $blockedGate.GateId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-local-only-as-external-proof" -RequiredFragments @("local-only", "external proof") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.local-only-as-external.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-actionable-report" -RequiredFragments @("cannot pass", "actionable_qa_report_ref") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.missing-actionable-report.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-fix-queue" -RequiredFragments @("cannot pass", "actionable_qa_fix_queue_ref") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.missing-fix-queue.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-blocking-issues-ignored" -RequiredFragments @("unresolved blocking QA issues") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.blocking-issues-ignored.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-external-runner-result" -RequiredFragments @("cannot pass", "external_runner_result_ref") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.missing-external-runner-result.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-external-artifact-evidence" -RequiredFragments @("cannot pass", "external_artifact_evidence_ref") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.missing-external-artifact-evidence.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-head-tree-mismatch" -RequiredFragments @("head/tree mismatch") -Action {
        & $testGate -GatePath (Join-Path $invalidRoot "cycle_qa_evidence_gate.head-tree-mismatch.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL actionable QA evidence gate harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Actionable QA evidence gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All actionable QA evidence gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
