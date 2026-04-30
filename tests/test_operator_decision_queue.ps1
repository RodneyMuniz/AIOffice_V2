$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\OperatorDecisionQueue.psm1") -Force -PassThru
$testQueue = $module.ExportedCommands["Test-OperatorDecisionQueue"]
$newQueue = $module.ExportedCommands["New-OperatorDecisionQueue"]
$testMarkdown = $module.ExportedCommands["Test-OperatorDecisionQueueMarkdown"]

$validStatusPath = Join-Path $repoRoot "state\fixtures\valid\control_room\control_room_status.foundation.valid.json"
$validRoot = Join-Path $repoRoot "state\fixtures\valid\operator_decision_queue"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\operator_decision_queue"
$currentQueuePath = Join-Path $repoRoot "state\control_room\r12_current\operator_decision_queue.json"
$currentQueueMarkdownPath = Join-Path $repoRoot "state\control_room\r12_current\operator_decision_queue.md"
$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12_decision_queue_" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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
    $fixtureQueue = & $testQueue -QueuePath (Join-Path $validRoot "operator_decision_queue.valid.json")
    if ($fixtureQueue.DecisionCount -lt 4 -or $fixtureQueue.BlockingDecisionCount -lt 2) {
        $failures += "FAIL valid: operator decision queue fixture did not expose expected current decisions."
    }
    else {
        Write-Output ("PASS valid operator decision queue fixture: {0}" -f $fixtureQueue.QueueId)
        $validPassed += 1
    }

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $tempQueuePath = Join-Path $tempRoot "generated_decision_queue.json"
    $tempMarkdownPath = Join-Path $tempRoot "generated_decision_queue.md"
    & $newQueue -ControlRoomStatusPath $validStatusPath -OutputPath $tempQueuePath -MarkdownOutputPath $tempMarkdownPath -Overwrite | Out-Null
    $generatedQueue = & $testQueue -QueuePath $tempQueuePath
    $generatedMarkdown = & $testMarkdown -QueuePath $tempQueuePath -MarkdownPath $tempMarkdownPath
    if ($generatedQueue.DecisionCount -ne $generatedMarkdown.DecisionCount) {
        $failures += "FAIL valid: generated queue Markdown did not preserve decision count."
    }
    else {
        Write-Output ("PASS valid generated operator decision queue and Markdown: {0}" -f $tempQueuePath)
        $validPassed += 1
    }

    $currentQueue = & $testQueue -QueuePath $currentQueuePath
    $currentMarkdown = & $testMarkdown -QueuePath $currentQueuePath -MarkdownPath $currentQueueMarkdownPath
    if ($currentQueue.DecisionCount -ne $currentMarkdown.DecisionCount -or $currentQueue.BlockingDecisionCount -lt 2) {
        $failures += "FAIL valid: current generated decision queue or Markdown did not preserve blocking decisions."
    }
    else {
        Write-Output ("PASS valid current generated operator decision queue: {0}" -f $currentQueue.QueueId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-consequence" -RequiredFragments @("consequence") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.missing-consequence.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-evidence-refs" -RequiredFragments @("evidence_refs") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.missing-evidence-refs.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-implicit-successor-authorization" -RequiredFragments @("successor milestone authorization", "implicit") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.implicit-successor.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-premature-final-acceptance" -RequiredFragments @("final acceptance", "prerequisites") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.premature-final-acceptance.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-hidden-blocking-decision" -RequiredFragments @("hidden blocking decisions") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.hidden-blocking.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "operator_decision_queue.missing-non-claims.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL operator decision queue harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Operator decision queue tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All operator decision queue tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
