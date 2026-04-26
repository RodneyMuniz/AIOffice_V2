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
        "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md",
        "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md"
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
        R9AuthorityPath = Join-Path $Root "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md"
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

    Set-Content -LiteralPath $Path -Value ($text.Replace($OldValue, $NewValue)) -Encoding UTF8
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
    if ($liveValidation.DoneThrough -ne 9 -or $liveValidation.PlannedStart -ne $null -or $liveValidation.PlannedThrough -ne $null -or -not $liveValidation.R8Closed -or -not $liveValidation.R9Opened -or $liveValidation.ActiveMilestone -ne "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot" -or $liveValidation.R9DoneThrough -ne 5 -or $liveValidation.R9PlannedStart -ne 6 -or $liveValidation.R9PlannedThrough -ne 7) {
        $failures += "FAIL valid: live repo truth did not validate as R8 closed and R9 active through R9-005 only."
    }
    else {
        Write-Output ("PASS valid current R9 opening status: R8 through R8-{0} complete, '{1}' most recently closed, and R9 through R9-{2} active" -f $liveValidation.DoneThrough.ToString("000"), $liveValidation.MostRecentlyClosedMilestone, $liveValidation.R9DoneThrough.ToString("000"))
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "r8-closeout-without-qa-packet-ref" -RequiredFragments @("referenced QA packet") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-missing-qa")
        foreach ($path in @($scenario.ReadmePath, $scenario.ActiveStatePath, $scenario.KanbanPath, $scenario.DecisionLogPath, $scenario.R8AuthorityPath)) {
            Replace-FileText -Path $path -OldValue "qa_proof_packet.json" -NewValue "qa_packet_missing.json"
        }
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r8-closeout-without-remote-head-ref" -RequiredFragments @("remote-head verification artifact") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-missing-remote-head")
        foreach ($path in @($scenario.ReadmePath, $scenario.ActiveStatePath, $scenario.KanbanPath, $scenario.DecisionLogPath, $scenario.R8AuthorityPath)) {
            Replace-FileText -Path $path -OldValue "remote_head_verification_starting_head.json" -NewValue "remote_head_verification_starting_head.txt"
        }
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r8-closeout-without-post-push-limitation" -RequiredFragments @("post-push verification") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-missing-post-push-limitation")
        foreach ($path in @($scenario.ReadmePath, $scenario.ActiveStatePath, $scenario.KanbanPath, $scenario.DecisionLogPath, $scenario.R8AuthorityPath)) {
            $text = Get-Content -LiteralPath $path -Raw
            $text = [regex]::Replace($text, '(?i)no committed exact-final post-push verification artifact is claimed', 'post-push closeout note omitted')
            Set-Content -LiteralPath $path -Value $text -Encoding UTF8
        }
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "external-proof-claim-without-run-identity" -RequiredFragments @("concrete CI or external proof artifact") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-external-proof-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "A concrete CI external proof artifact exists for R8 closeout.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "post-push-artifact-claim-without-artifact-ref" -RequiredFragments @("post-push verification artifact") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-post-push-artifact-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "A post-push verification artifact exists for R8 closeout.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r9-active-status-mismatch" -RequiredFragments @("R9 as the active milestone") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-active-mismatch")
        Replace-FileText -Path $scenario.ActiveStatePath -OldValue '`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot` is now active in repo truth through `R9-005` only.' -NewValue '`R10 Next Milestone` is now active in repo truth.'
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r9-004-limitation" -RequiredFragments @("R9-004", "no-concrete-run-identity") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-004-limitation")
        Replace-FileText -Path $scenario.R9AuthorityPath -OldValue "No concrete CI or external runner artifact identity is claimed" -NewValue "External runner limitation wording omitted"
        Replace-FileText -Path $scenario.R9AuthorityPath -OldValue "no concrete CI or external runner artifact identity is claimed" -NewValue "external runner limitation wording omitted"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r9-005-segment-model-ref" -RequiredFragments @("R9-005", "execution segment") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-005-segment-ref")
        Replace-FileText -Path $scenario.R9AuthorityPath -OldValue "contracts/execution_segments/execution_segment_dispatch.contract.json" -NewValue "contracts/execution_segments/segment_dispatch_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "stale-most-recently-closed-after-r8-closeout" -RequiredFragments @("stale most recently closed milestone", "R7 Fault-Managed Continuity and Rollback Drill") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-stale-most-recent")
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + '`R7 Fault-Managed Continuity and Rollback Drill` remains the most recently closed milestone under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r8-non-claims" -RequiredFragments @("non-claim", "unattended automatic resume") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-non-claims")
        Replace-RegexInFile -Path $scenario.R8AuthorityPath -Pattern '\- unattended automatic resume\r?\n' -Replacement ""
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r9-non-claims" -RequiredFragments @("R9 non-claim", "Codex context compaction") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-non-claims")
        Replace-RegexInFile -Path $scenario.R9AuthorityPath -Pattern '\- no claim that Codex context compaction is solved\r?\n' -Replacement ""
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "task-status-mismatch" -RequiredFragments @("does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-task-mismatch")
        Replace-RegexInFile -Path $scenario.R8AuthorityPath -Pattern '###\s+`R8-009`\s+Pilot\s+and\s+close\s+R8\s+narrowly\r?\n-\s+Status:\s+done' -Replacement ('### `R8-009` Pilot and close R8 narrowly' + $crlf + '- Status: planned')
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r9-task-status-mismatch" -RequiredFragments @("R9 authority does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-task-mismatch")
        Replace-RegexInFile -Path $scenario.R9AuthorityPath -Pattern '###\s+`R9-006`\s+Pilot one tiny milestone through segmented execution\r?\n-\s+Status:\s+planned' -Replacement ('### `R9-006` Pilot one tiny milestone through segmented execution' + $crlf + '- Status: done')
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
