$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $module.ExportedCommands["Test-StatusDocGate"]
$crlf = "`r`n"

function New-StatusDocHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $paths = @(
        "README.md",
        "governance\ACTIVE_STATE.md",
        "execution\KANBAN.md",
        "governance\DECISION_LOG.md",
        "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md"
    )

    foreach ($relativePath in $paths) {
        $sourcePath = Join-Path $repoRoot $relativePath
        $targetPath = Join-Path $Root $relativePath
        $targetDirectory = Split-Path -Parent $targetPath
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
        Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    }

    return [pscustomobject]@{
        Root = $Root
        ReadmePath = Join-Path $Root "README.md"
        ActiveStatePath = Join-Path $Root "governance\ACTIVE_STATE.md"
        KanbanPath = Join-Path $Root "execution\KANBAN.md"
        DecisionLogPath = Join-Path $Root "governance\DECISION_LOG.md"
        R8AuthorityPath = Join-Path $Root "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md"
    }
}

function Replace-FileText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$OldValue,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$NewValue
    )

    $text = Get-Content -LiteralPath $Path -Raw
    if ($text.IndexOf($OldValue, [System.StringComparison]::Ordinal) -lt 0) {
        throw "Expected text was not found in '$Path'."
    }

    $updatedText = $text.Replace($OldValue, $NewValue)
    Set-Content -LiteralPath $Path -Value $updatedText -Encoding UTF8
}

function Replace-RegexInFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Replacement
    )

    $text = Get-Content -LiteralPath $Path -Raw
    $updatedText = [regex]::Replace($text, $Pattern, $Replacement, 1)
    if ($updatedText -eq $text) {
        throw "Expected regex pattern was not found in '$Path'."
    }

    Set-Content -LiteralPath $Path -Value $updatedText -Encoding UTF8
}

function Remove-FileText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    Replace-FileText -Path $Path -OldValue $Value -NewValue ""
}

function Remove-RegexFromFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    Replace-RegexInFile -Path $Path -Pattern $Pattern -Replacement ""
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

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r8statusgate" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    $liveValidation = & $testStatusDocGate -RepositoryRoot $repoRoot
    if ($liveValidation.DoneThrough -ne 8 -or $liveValidation.PlannedStart -ne 9 -or $liveValidation.PlannedThrough -ne 9 -or -not $liveValidation.R8RemainsOpen) {
        $failures += "FAIL valid: live repo truth did not validate as R8-001 through R8-008 complete with R8-009 planned."
    }
    else {
        Write-Output ("PASS valid current R8 status: through R8-{0} complete with R8-{1} planned" -f $liveValidation.DoneThrough.ToString("000"), $liveValidation.PlannedStart.ToString("000"))
        $validPassed += 1
    }

    $harness = New-StatusDocHarness -Root $tempRoot

    Replace-RegexInFile -Path $harness.ReadmePath -Pattern '`R8-008`\s+is\s+complete[^;]+;\s+`R8-009`\s+is\s+planned\s+only\s+as\s+the\s+bounded\s+closeout\s+slice\.' -Replacement '`R8-008` through `R8-009` remain planned only.'
    Replace-FileText -Path $harness.ActiveStatePath -OldValue 'with `R8-001` through `R8-008` complete and `R8-009` planned.' -NewValue 'with `R8-001` through `R8-007` complete and `R8-008` through `R8-009` planned.'
    Replace-FileText -Path $harness.ActiveStatePath -OldValue '- `R8-008` is complete through the first status-doc gating validator at `tools/StatusDocGate.psm1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1`, which fails closed on stale closed-milestone contradictions, task-status drift, and premature closeout claims without evidence refs.' -NewValue '- `R8-008` through `R8-009` are planned only.'
    Replace-FileText -Path $harness.ActiveStatePath -OldValue '`R8-008` is complete through the first status-doc gating validator under `tools/StatusDocGate.psm1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1`, while `R8-009` remains planned only.' -NewValue '`R8-008` through `R8-009` remain planned only.'
    Replace-FileText -Path $harness.ActiveStatePath -OldValue '- `R8-009` Pilot and close R8 narrowly.' -NewValue '- `R8-008` Add status-doc gating.'
    Replace-FileText -Path $harness.ActiveStatePath -OldValue '- R8 remains intentionally fail-closed after `R8-008`: status-doc gating now exists, but no concrete external proof run artifact and no final closeout proof packet yet exist in repo truth.' -NewValue '- R8 remains intentionally fail-closed after `R8-007`: a workflow foundation now exists, but no concrete external proof run artifact, no status-doc gating layer, and no final closeout proof packet yet exist in repo truth.'
    Replace-RegexInFile -Path $harness.KanbanPath -Pattern '`R8-008`\s+is\s+complete\s+through\s+the\s+status-doc\s+gating\s+validator[\s\S]+?\.\s+`R8-009`\s+is\s+planned\s+only\.' -Replacement '`R8-008` through `R8-009` are planned only.'
    Replace-RegexInFile -Path $harness.KanbanPath -Pattern '###\s+`R8-008`\s+Add\s+status-doc\s+gating\r?\n-\s+Status:\s+done' -Replacement ('### `R8-008` Add status-doc gating' + $crlf + '- Status: planned')
    Replace-FileText -Path $harness.R8AuthorityPath -OldValue '`R8-001` through `R8-008` are complete in repo truth.' -NewValue '`R8-001` through `R8-007` are complete in repo truth.'
    Replace-FileText -Path $harness.R8AuthorityPath -OldValue '`R8-009` is planned only.' -NewValue '`R8-008` through `R8-009` are planned only.'
    Remove-RegexFromFile -Path $harness.R8AuthorityPath -Pattern '`R8-008`\s+now\s+adds\s+the\s+first\s+status-doc\s+gating\s+validator[\s\S]+?\.\r?\n\r?\n'
    Replace-RegexInFile -Path $harness.R8AuthorityPath -Pattern '###\s+`R8-008`\s+Add\s+status-doc\s+gating\r?\n-\s+Status:\s+done' -Replacement ('### `R8-008` Add status-doc gating' + $crlf + '- Status: planned')
    Remove-RegexFromFile -Path $harness.R8AuthorityPath -Pattern '\- `R8-008` adds the status-doc gating validator only\. It does not add a concrete CI or external proof artifact, it does not create the R8 closeout proof package, and it does not close R8\.\r?\n'
    Remove-RegexFromFile -Path $harness.DecisionLogPath -Pattern '## D-0052 R8-008 Added Status-Doc Gating[\s\S]*$'

    $plannedValidation = & $testStatusDocGate -RepositoryRoot $harness.Root
    if ($plannedValidation.DoneThrough -ne 7 -or $plannedValidation.PlannedStart -ne 8 -or $plannedValidation.PlannedThrough -ne 9 -or -not $plannedValidation.R8RemainsOpen) {
        $failures += "FAIL valid: pre-R8-008 planned state was not accepted."
    }
    else {
        Write-Output ("PASS valid prior R8 state: through R8-{0} complete with R8-{1} through R8-{2} planned" -f $plannedValidation.DoneThrough.ToString("000"), $plannedValidation.PlannedStart.ToString("000"), $plannedValidation.PlannedThrough.ToString("000"))
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "stale-most-recently-closed-contradiction" -RequiredFragments @("most recently closed milestone") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-readme-r6"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Replace-FileText -Path $scenario.ReadmePath -OldValue '`R7 Fault-Managed Continuity and Rollback Drill` is now the most recently closed milestone in repo truth.' -NewValue '`R6 Supervised Milestone Autocycle Pilot` is now the most recently closed milestone in repo truth.'
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r8-closed-before-r8-009" -RequiredFragments @("R8 is closed before R8-009 is complete") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-closed-before-009"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + '`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` is now closed in repo truth.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r8-009-done-without-proof-refs" -RequiredFragments @("referenced QA packet") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-r8-009-without-refs"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Replace-FileText -Path $scenario.ReadmePath -OldValue '`R8-009` is planned only as the bounded closeout slice.' -NewValue '`R8-009` is complete as the bounded closeout slice.'
        Replace-FileText -Path $scenario.ActiveStatePath -OldValue 'with `R8-001` through `R8-008` complete and `R8-009` planned.' -NewValue 'with `R8-001` through `R8-009` complete.'
        Replace-FileText -Path $scenario.ActiveStatePath -OldValue '`R8-008` is complete through the first status-doc gating validator under `tools/StatusDocGate.psm1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1`, while `R8-009` remains planned only.' -NewValue '`R8-008` is complete through the first status-doc gating validator under `tools/StatusDocGate.psm1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1`, and `R8-009` is complete as the bounded closeout slice.'
        Replace-RegexInFile -Path $scenario.KanbanPath -Pattern '###\s+`R8-009`\s+Pilot\s+and\s+close\s+R8\s+narrowly\r?\n-\s+Status:\s+planned' -Replacement ('### `R8-009` Pilot and close R8 narrowly' + $crlf + '- Status: done')
        Replace-FileText -Path $scenario.R8AuthorityPath -OldValue '`R8-009` is planned only.' -NewValue '`R8-009` is complete in repo truth.'
        Replace-RegexInFile -Path $scenario.R8AuthorityPath -Pattern '###\s+`R8-009`\s+Pilot\s+and\s+close\s+R8\s+narrowly\r?\n-\s+Status:\s+planned' -Replacement ('### `R8-009` Pilot and close R8 narrowly' + $crlf + '- Status: done')
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + '`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` is now closed in repo truth.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "external-proof-claim-without-run-identity" -RequiredFragments @("concrete CI or external proof artifact") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-external-proof-claim"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Add-Content -LiteralPath $scenario.ReadmePath -Value "`r`nA concrete CI or external proof artifact now exists for R8 closeout." -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "clean-checkout-qa-claim-without-packet-ref" -RequiredFragments @("clean-checkout QA packet") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-qa-packet-claim"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Add-Content -LiteralPath $scenario.ReadmePath -Value "`r`nA clean-checkout QA packet now exists for R8 closeout." -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "post-push-claim-without-artifact-ref" -RequiredFragments @("post-push verification artifact") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-post-push-claim"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Add-Content -LiteralPath $scenario.ReadmePath -Value "`r`nA post-push verification artifact now exists for R8 closeout." -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r8-non-claims" -RequiredFragments @("non-claim", "unattended automatic resume") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-non-claims"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Remove-RegexFromFile -Path $scenario.R8AuthorityPath -Pattern '\- unattended automatic resume\r?\n'
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "task-status-mismatch" -RequiredFragments @("does not match KANBAN") -Action {
        $scenarioRoot = Join-Path $tempRoot "invalid-task-mismatch"
        $scenario = New-StatusDocHarness -Root $scenarioRoot
        Replace-RegexInFile -Path $scenario.R8AuthorityPath -Pattern '###\s+`R8-008`\s+Add\s+status-doc\s+gating\r?\n-\s+Status:\s+done' -Replacement ('### `R8-008` Add status-doc gating' + $crlf + '- Status: planned')
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }
}
catch {
    $failures += ("FAIL status-doc gate harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Status-doc gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All status-doc gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
