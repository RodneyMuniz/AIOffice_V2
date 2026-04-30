$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ActionableQa.psm1") -Force -PassThru
$testIssue = $module.ExportedCommands["Test-ActionableQaIssue"]
$testReport = $module.ExportedCommands["Test-ActionableQaReport"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa"
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
    $issue = & $testIssue -IssuePath (Join-Path $validRoot "actionable_qa_issue.warning.valid.json")
    if ($issue.Severity -ne "warning" -or $issue.BlockingStatus -ne "advisory") {
        $failures += "FAIL valid: actionable QA issue fixture did not validate with expected warning/advisory shape."
    }
    else {
        Write-Output ("PASS valid actionable QA issue fixture: {0}" -f $issue.IssueId)
        $validPassed += 1
    }

    $warningReport = & $testReport -ReportPath (Join-Path $validRoot "actionable_qa_report.warning.valid.json")
    if ($warningReport.AggregateVerdict -ne "warning" -or $warningReport.IssueCount -ne 1 -or $warningReport.BlockingIssueCount -ne 0) {
        $failures += "FAIL valid: warning report fixture did not expose expected actionable warning shape."
    }
    else {
        Write-Output ("PASS valid actionable QA warning report fixture: {0}" -f $warningReport.ReportId)
        $validPassed += 1
    }

    $psaUnavailable = & $testReport -ReportPath (Join-Path $validRoot "actionable_qa_report.psscriptanalyzer-unavailable.valid.json")
    if ($psaUnavailable.PSScriptAnalyzerAvailable -or $psaUnavailable.AggregateVerdict -ne "passed") {
        $failures += "FAIL valid: PSScriptAnalyzer-unavailable report fixture did not pass non-strict validation."
    }
    else {
        Write-Output ("PASS valid PSScriptAnalyzer unavailable non-strict fixture: {0}" -f $psaUnavailable.ReportId)
        $validPassed += 1
    }

    $blockingReport = & $testReport -ReportPath (Join-Path $validRoot "actionable_qa_report.blocking.valid.json")
    if ($blockingReport.AggregateVerdict -ne "failed" -or $blockingReport.BlockingIssueCount -ne 1) {
        $failures += "FAIL valid: blocking report fixture did not validate as failed with one blocking issue."
    }
    else {
        Write-Output ("PASS valid actionable QA blocking report fixture: {0}" -f $blockingReport.ReportId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-branch-head-tree" -RequiredFragments @("branch") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.missing-identity.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-dependency-status" -RequiredFragments @("dependency_status") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.missing-dependency-status.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-issue-without-file-path" -RequiredFragments @("file path", "not_applicable") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.issue-without-file-path.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-blocking-passed-aggregate" -RequiredFragments @("blocking issues", "passed") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.blocking-with-passed-aggregate.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-reproduction-command" -RequiredFragments @("reproduction_command", "non-empty string") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.missing-issue-reproduction-command.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.missing-non-claims.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-evidence-ref" -RequiredFragments @("evidence ref", "does not exist") -Action {
        & $testReport -ReportPath (Join-Path $invalidRoot "actionable_qa_report.missing-evidence-ref.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL actionable QA harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Actionable QA tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All actionable QA tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
