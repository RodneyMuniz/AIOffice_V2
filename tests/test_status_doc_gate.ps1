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
        "governance\BRANCHING_CONVENTION.md",
        "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md",
        "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md",
        "governance\R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md"
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
        BranchingConventionPath = Join-Path $Root "governance\BRANCHING_CONVENTION.md"
        R8AuthorityPath = Join-Path $Root "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md"
        R9AuthorityPath = Join-Path $Root "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md"
        R10AuthorityPath = Join-Path $Root "governance\R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md"
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
    if ($liveValidation.DoneThrough -ne 9 -or $liveValidation.PlannedStart -ne $null -or $liveValidation.PlannedThrough -ne $null -or -not $liveValidation.R8Closed -or -not $liveValidation.R9Closed -or -not $liveValidation.R10Opened -or $liveValidation.ActiveMilestone -ne "R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation" -or $liveValidation.MostRecentlyClosedMilestone -ne "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot" -or $liveValidation.R9DoneThrough -ne 7 -or $liveValidation.R9PlannedStart -ne $null -or $liveValidation.R9PlannedThrough -ne $null -or $liveValidation.R10DoneThrough -ne 7 -or $liveValidation.R10PlannedStart -ne 8 -or $liveValidation.R10PlannedThrough -ne 8) {
        $failures += "FAIL valid: live repo truth did not validate as R8 closed, R9 narrowly closed, and R10 active through R10-007 only."
    }
    else {
        Write-Output ("PASS valid current R10 external identity status: R8 through R8-{0} complete, '{1}' most recently closed, and R10 through R10-{2} active with R10-{3} through R10-{4} planned" -f $liveValidation.DoneThrough.ToString("000"), $liveValidation.MostRecentlyClosedMilestone, $liveValidation.R10DoneThrough.ToString("000"), $liveValidation.R10PlannedStart.ToString("000"), $liveValidation.R10PlannedThrough.ToString("000"))
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

    Invoke-ExpectedRefusal -Label "r10-external-proof-claim-without-run-identity" -RequiredFragments @("concrete CI or external proof artifact") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-external-proof-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "A concrete CI external proof artifact exists for R10 closeout.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "post-push-artifact-claim-without-artifact-ref" -RequiredFragments @("post-push verification artifact") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-post-push-artifact-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "A post-push verification artifact exists for R8 closeout.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "successor-opened-after-r10-opening" -RequiredFragments @("successor", "R10 opening") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-successor-opened")
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + '`R11 Next Milestone` is now active in repo truth.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r10-closeout-claimed-before-final-head-replay" -RequiredFragments @("R10 closeout", "R10-007") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-closeout-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + '`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` is now closed in repo truth.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-closeout-identity-contract-ref" -RequiredFragments @("R10-002", "closeout identity contract") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-closeout-contract-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "contracts/external_runner_artifact/external_runner_closeout_identity.contract.json" -NewValue "contracts/external_runner_artifact/external_runner_closeout_identity_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-validator-only-fixture-nonproof" -RequiredFragments @("R10-002 fixture", "real external proof") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-validator-fixture-nonproof")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "That fixture is not a real external runner capture and is not R10 proof." -NewValue "That fixture records a real external runner capture for R10 proof."
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-proof-bundle-contract-ref" -RequiredFragments @("R10-003", "external proof artifact bundle contract") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-bundle-contract-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "contracts/external_proof_bundle/external_proof_artifact_bundle.contract.json" -NewValue "contracts/external_proof_bundle/external_proof_artifact_bundle_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-proof-bundle-fixture-nonproof" -RequiredFragments @("R10-003 fixture", "real external proof") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-bundle-fixture-nonproof")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "Its validator-only fixture is not a real external runner capture, not CI proof, not external QA proof, and not R10 closeout proof." -NewValue "Its validator-only fixture records real external runner proof, CI proof, external QA proof, and R10 closeout proof."
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-proof-workflow-ref" -RequiredFragments @("R10-004", "workflow") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-workflow-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue ".github/workflows/r10-external-proof-bundle.yml" -NewValue ".github/workflows/r10-external-proof-bundle-missing.yml"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-runner-consuming-qa-contract-ref" -RequiredFragments @("R10-006", "QA signoff contract") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-qa-contract-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "contracts/isolated_qa/external_runner_consuming_qa_signoff.contract.json" -NewValue "contracts/isolated_qa/external_runner_consuming_qa_signoff_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-runner-consuming-qa-packet-ref" -RequiredFragments @("R10-006", "QA signoff packet") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-qa-packet-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff.json" -NewValue "state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff_missing.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-two-phase-procedure-ref" -RequiredFragments @("R10-007", "procedure document") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-two-phase-procedure-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE.md" -NewValue "governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE_MISSING.md"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-two-phase-contract-ref" -RequiredFragments @("R10-007", "procedure contract") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-two-phase-contract-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "contracts/post_push_support/r10_two_phase_final_head_closeout_procedure.contract.json" -NewValue "contracts/post_push_support/r10_two_phase_final_head_closeout_procedure_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-two-phase-validator-ref" -RequiredFragments @("R10-007", "validator module") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-two-phase-validator-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "tools/R10TwoPhaseFinalHeadSupport.psm1" -NewValue "tools/R10TwoPhaseFinalHeadSupportMissing.psm1"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-two-phase-fixture-ref" -RequiredFragments @("R10-007", "valid fixture") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-two-phase-fixture-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure.valid.json" -NewValue "state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure_missing.valid.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-external-proof-runner-script-ref" -RequiredFragments @("R10-004", "runner script") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-runner-script-ref")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "tools/invoke_r10_external_proof_bundle.ps1" -NewValue "tools/invoke_r10_external_proof_bundle_missing.ps1"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-workflow-existence-nonproof" -RequiredFragments @("Workflow existence", "successful external proof") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-workflow-existence-nonproof")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "Workflow existence is not proof of a successful run" -NewValue "Workflow existence is accepted as proof of a successful run"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r10-failed-run-treated-as-successful-proof" -RequiredFragments @("failed identity capture", "successful external proof") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-failed-run-success-claim")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue 'Run `25033063285` completed with conclusion `failure`; it is a real external runner identity capture, but successful external proof was not established by that run.' -NewValue 'Run `25033063285` completed with conclusion `success`; it is accepted as the R10-005G successful external proof run.'
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-limitation-only-closeout-block" -RequiredFragments @("limitation-only", "external-runner") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-limitation-only-block")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue "Limitation-only external-runner evidence is insufficient for R10 closeout" -NewValue "External-runner limitation wording omitted for R10 closeout"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r10-branch-convention" -RequiredFragments @("R10 branch") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-branch-convention")
        Replace-FileText -Path $scenario.BranchingConventionPath -OldValue 'R10 branch: `release/r10-real-external-runner-proof-foundation`' -NewValue 'R10 branch: `feature/r5-closeout-remaining-foundations`'
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "stale-r10-authority-branch" -RequiredFragments @("active R10 release branch") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-authority-branch")
        Replace-FileText -Path $scenario.R10AuthorityPath -OldValue 'one active branch: `release/r10-real-external-runner-proof-foundation`' -NewValue 'one active branch: `feature/r5-closeout-remaining-foundations`'
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

    Invoke-ExpectedRefusal -Label "missing-r9-006-pilot-ref" -RequiredFragments @("R9-006", "pilot request") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-006-pilot-ref")
        Replace-FileText -Path $scenario.R9AuthorityPath -OldValue "state/pilots/r9_tiny_segmented_milestone_pilot/pilot_request.json" -NewValue "state/pilots/r9_tiny_segmented_milestone_pilot/pilot_request_missing.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r9-proof-package-ref" -RequiredFragments @("R9 proof-review package") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-proof-package-ref")
        Replace-FileText -Path $scenario.R9AuthorityPath -OldValue "state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/" -NewValue "state/proof_reviews/r9_missing/"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "stale-r8-most-recent-after-r9-closeout" -RequiredFragments @("stale most recently closed milestone", "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-stale-r8-most-recent")
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + '`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains the most recently closed milestone under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`.') -Encoding UTF8
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

    Invoke-ExpectedRefusal -Label "missing-r10-non-claims" -RequiredFragments @("R10 non-claim", "Codex context compaction") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-non-claims")
        Replace-RegexInFile -Path $scenario.R10AuthorityPath -Pattern '\- no solved Codex context compaction\r?\n' -Replacement ""
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "task-status-mismatch" -RequiredFragments @("does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-task-mismatch")
        Replace-RegexInFile -Path $scenario.R8AuthorityPath -Pattern '###\s+`R8-009`\s+Pilot\s+and\s+close\s+R8\s+narrowly\r?\n-\s+Status:\s+done' -Replacement ('### `R8-009` Pilot and close R8 narrowly' + $crlf + '- Status: planned')
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r9-task-status-mismatch" -RequiredFragments @("R9 authority does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r9-task-mismatch")
        Replace-RegexInFile -Path $scenario.R9AuthorityPath -Pattern '###\s+`R9-007`\s+Close R9 narrowly\r?\n-\s+Status:\s+done' -Replacement ('### `R9-007` Close R9 narrowly' + $crlf + '- Status: planned')
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r10-task-status-mismatch" -RequiredFragments @("R10 authority does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-task-mismatch")
        Replace-RegexInFile -Path $scenario.R10AuthorityPath -Pattern '###\s+`R10-008`\s+Close R10 only with real external final-head proof\r?\n-\s+Status:\s+planned' -Replacement ('### `R10-008` Close R10 only with real external final-head proof' + $crlf + '- Status: done')
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
