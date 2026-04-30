$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ActionableQaFixQueue.psm1") -Force -PassThru
$testQueue = $module.ExportedCommands["Test-ActionableQaFixQueue"]
$newQueue = $module.ExportedCommands["New-ActionableQaFixQueue"]
$testMarkdown = $module.ExportedCommands["Test-ActionableQaFixQueueMarkdown"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa_fix_queue"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa_fix_queue"
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

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12_fix_queue_" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    $warningQueue = & $testQueue -QueuePath (Join-Path $validRoot "actionable_qa_fix_queue.warning.valid.json")
    if ($warningQueue.IssueCount -ne 1 -or $warningQueue.BlockingIssueCount -ne 0 -or $warningQueue.FixItemCount -ne 1) {
        $failures += "FAIL valid: warning fix queue fixture did not expose one non-blocking fix item."
    }
    else {
        Write-Output ("PASS valid warning fix queue fixture: {0}" -f $warningQueue.QueueId)
        $validPassed += 1
    }

    $blockingQueue = & $testQueue -QueuePath (Join-Path $validRoot "actionable_qa_fix_queue.blocking.valid.json")
    if ($blockingQueue.IssueCount -ne 1 -or $blockingQueue.BlockingIssueCount -ne 1 -or $blockingQueue.FixItemCount -ne 1) {
        $failures += "FAIL valid: blocking fix queue fixture did not expose one blocking fix item."
    }
    else {
        Write-Output ("PASS valid blocking fix queue fixture: {0}" -f $blockingQueue.QueueId)
        $validPassed += 1
    }

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $tempQueuePath = Join-Path $tempRoot "generated_fix_queue.json"
    $tempMarkdownPath = Join-Path $tempRoot "generated_fix_queue.md"
    & $newQueue `
        -ActionableQaReportPath "state/fixtures/valid/actionable_qa/actionable_qa_report.warning.valid.json" `
        -OutputPath $tempQueuePath `
        -MarkdownOutputPath $tempMarkdownPath `
        -Overwrite | Out-Null
    $markdownValidation = & $testMarkdown -QueuePath $tempQueuePath -MarkdownPath $tempMarkdownPath
    if ($markdownValidation.IssueCount -ne 1 -or $markdownValidation.BlockingIssueCount -ne 0) {
        $failures += "FAIL valid: generated Markdown summary did not validate expected issue/blocking counts."
    }
    else {
        Write-Output ("PASS valid generated Markdown fix queue summary: {0}" -f $tempMarkdownPath)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-source-issue-mapping" -RequiredFragments @("source_issue_id", "does not map") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.missing-source-issue-mapping.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-blocking-without-fix-item" -RequiredFragments @("every blocking issue", "missing") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.blocking-without-fix-item.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-fix-item-without-reproduction-command" -RequiredFragments @("reproduction_command", "non-empty string") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.fix-item-without-reproduction-command.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-fix-item-without-recommended-fix" -RequiredFragments @("recommended_fix", "non-empty string") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.fix-item-without-recommended-fix.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-hidden-blocking-issue" -RequiredFragments @("cannot hide blocking issues", "blocking_issue_count") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.hidden-blocking-issue.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "actionable_qa_fix_queue.missing-non-claims.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL actionable QA fix queue harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Actionable QA fix queue tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All actionable QA fix queue tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
