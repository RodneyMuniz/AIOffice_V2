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
        "governance\R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md",
        "governance\R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md",
        "governance\R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md",
        "governance\R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md",
        "governance\R14_PRODUCT_VISION_PIVOT_AND_GOVERNANCE_ENFORCEMENT.md",
        "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md",
        "governance\R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md",
        "governance\R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
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
        R11AuthorityPath = Join-Path $Root "governance\R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md"
        R12AuthorityPath = Join-Path $Root "governance\R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md"
        R13AuthorityPath = Join-Path $Root "governance\R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md"
        R14AuthorityPath = Join-Path $Root "governance\R14_PRODUCT_VISION_PIVOT_AND_GOVERNANCE_ENFORCEMENT.md"
        R15AuthorityPath = Join-Path $Root "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
        R16AuthorityPath = Join-Path $Root "governance\R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
        R17AuthorityPath = Join-Path $Root "governance\R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
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
    if ($liveValidation.DoneThrough -ne 9 -or $liveValidation.PlannedStart -ne $null -or $liveValidation.PlannedThrough -ne $null -or -not $liveValidation.R8Closed -or -not $liveValidation.R9Closed -or -not $liveValidation.R10Closed -or -not $liveValidation.R11Closed -or -not $liveValidation.R12Closed -or $liveValidation.R12Opened -or -not $liveValidation.R13Opened -or -not $liveValidation.R14Opened -or -not $liveValidation.R15Opened -or -not $liveValidation.R16Opened -or -not $liveValidation.R17Opened -or $liveValidation.ActiveMilestone -ne "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle" -or $liveValidation.MostRecentlyClosedMilestone -ne "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot" -or $liveValidation.R9DoneThrough -ne 7 -or $liveValidation.R9PlannedStart -ne $null -or $liveValidation.R9PlannedThrough -ne $null -or $liveValidation.R10DoneThrough -ne 8 -or $liveValidation.R10PlannedStart -ne $null -or $liveValidation.R10PlannedThrough -ne $null -or $liveValidation.R11DoneThrough -ne 9 -or $liveValidation.R11PlannedStart -ne $null -or $liveValidation.R11PlannedThrough -ne $null -or $liveValidation.R12DoneThrough -ne 21 -or $liveValidation.R12PlannedStart -ne $null -or $liveValidation.R12PlannedThrough -ne $null -or $liveValidation.R13DoneThrough -ne 18 -or $liveValidation.R13PlannedStart -ne $null -or $liveValidation.R13PlannedThrough -ne $null -or $liveValidation.R14DoneThrough -ne 6 -or $liveValidation.R14PlannedStart -ne $null -or $liveValidation.R14PlannedThrough -ne $null -or $liveValidation.R15DoneThrough -ne 9 -or $liveValidation.R15PlannedStart -ne $null -or $liveValidation.R15PlannedThrough -ne $null -or $liveValidation.R16DoneThrough -ne 26 -or $liveValidation.R16PlannedStart -ne $null -or $liveValidation.R16PlannedThrough -ne $null -or $liveValidation.R17DoneThrough -ne 3 -or $liveValidation.R17PlannedStart -ne 4 -or $liveValidation.R17PlannedThrough -ne 28) {
        $failures += "FAIL valid: live repo truth did not validate as R8/R9/R10/R11 closed, R12 closed narrowly through R12-021, R13 failed/partial through R13-018 only, R14 accepted with caveats through R14-006, R15 accepted with caveats through R15-009, R16 complete through R16-026, and R17 active through R17-003 with R17-004 through R17-028 planned only."
    }
    else {
        Write-Output ("PASS valid current R17 posture: R8 through R8-{0} complete, '{1}' most recently closed, R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, R13 failed/partial through R13-{5}, R14 accepted with caveats through R14-{6}, R15 accepted with caveats through R15-{7}, R16 complete through R16-{8}, and R17 active through R17-{9} with R17-{10} through R17-{11} planned only" -f $liveValidation.DoneThrough.ToString("000"), $liveValidation.MostRecentlyClosedMilestone, $liveValidation.R10DoneThrough.ToString("000"), $liveValidation.R11DoneThrough.ToString("000"), $liveValidation.R12DoneThrough.ToString("000"), $liveValidation.R13DoneThrough.ToString("000"), $liveValidation.R14DoneThrough.ToString("000"), $liveValidation.R15DoneThrough.ToString("000"), $liveValidation.R16DoneThrough.ToString("000"), $liveValidation.R17DoneThrough.ToString("000"), $liveValidation.R17PlannedStart.ToString("000"), $liveValidation.R17PlannedThrough.ToString("000"))
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

    Invoke-ExpectedRefusal -Label "r13-closed-claim-under-r14" -RequiredFragments @("R13 closure") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r13-closed-under-r14")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R13 is now closed in repo truth.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r17-opened-after-r16-opening" -RequiredFragments @("R16 closure") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r17-opened")
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + '`R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation` is now closed in repo truth and `R17 Product Runtime Milestone` is now active.') -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r13-partial-gate-converted-to-passed" -RequiredFragments @("R13 partial gates") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r13-partial-gate-passed")
        Add-Content -LiteralPath $scenario.KanbanPath -Value ($crlf + "R13 API/custom-runner bypass gate passed and is fully delivered as a hard gate.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r14-product-runtime-and-integration-overclaim" -RequiredFragments @("product/runtime/integration") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r14-runtime-integration-overclaim")
        Add-Content -LiteralPath $scenario.R14AuthorityPath -Value ($crlf + "R14 ships production runtime, Symphony integration, Linear integration, GitHub Projects integration, and custom board implementation.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-implementation-beyond-r15-009" -RequiredFragments @("R15 implementation beyond R15-009") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-implementation")
        Add-Content -LiteralPath $scenario.R15AuthorityPath -Value ($crlf + "R15-010 successor task is planned.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-productized-ui-and-qa-overclaim" -RequiredFragments @("product/runtime/integration overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-ui-qa-overclaim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R15 ships productized UI, production QA, and full product QA coverage.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-agent-execution-and-memory-overclaim" -RequiredFragments @("product/runtime/integration/agent-execution overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-agent-memory-overclaim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R15 implements true multi-agent execution and a persistent memory engine.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-solved-codex-overclaim" -RequiredFragments @("solved Codex reliability") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-solved-codex-overclaim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R15 proves solved Codex compaction and solved Codex reliability.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-external-audit-acceptance-overclaim" -RequiredFragments @("R15 external audit acceptance") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-external-audit-accepted")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R15 external audit accepted after review.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-main-merge-overclaim" -RequiredFragments @("R15 main merge") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-main-merge")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R15 merged to main after the proof package.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-027-task-overclaim" -RequiredFragments @("unexpected R16 task") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-027-task")
        Add-Content -LiteralPath $scenario.KanbanPath -Value ($crlf + "### `R16-027` Implement successor runtime" + $crlf + "- Status: planned") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-026-external-audit-acceptance-overclaim" -RequiredFragments @("final R16 audit acceptance") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-026-external-audit-acceptance")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16-026 final proof/review package candidate has final R16 audit acceptance completed.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-baseline-memory-runtime-overclaim" -RequiredFragments @("generated baseline memory layers treated as runtime memory") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-baseline-memory-runtime")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "Generated baseline memory layers are runtime memory for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-generated-role-memory-pack-runtime-overclaim" -RequiredFragments @("generated role memory packs treated as runtime memory") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-role-memory-pack-runtime")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "Generated role memory packs are runtime memory for PM and Developer.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-role-memory-pack-generator-overclaim" -RequiredFragments @("role memory pack generator") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-role-memory-pack-generator")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The role memory pack generator exists and performs runtime memory loading.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-role-memory-pack-model-agent-overclaim" -RequiredFragments @("role memory pack model treated as actual agents") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-role-memory-pack-model-agent")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The role-specific memory pack model provides actual autonomous agents and runtime agents.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "target-kpi-treated-as-achieved" -RequiredFragments @("target KPI scores treated as achieved implementation") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-target-kpi-achieved")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "KPI targets are achieved implementation evidence for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-artifact-map-runtime-overclaim" -RequiredFragments @("artifact map or audit map runtime overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-artifact-map-runtime")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The artifact map runtime exists for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-artifact-map-contract-treated-as-generated-map" -RequiredFragments @("artifact map contract treated as generated artifact map") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-contract-as-generated-map")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The artifact map contract is a generated artifact map.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-audit-map-overclaim" -RequiredFragments @("artifact map or audit map runtime overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-audit-map")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The audit map runtime exists for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-context-load-plan-runtime-overclaim" -RequiredFragments @("context-load plan runtime or budget overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-context-load-planner")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The context-load plan provides runtime memory loading for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-closed-overclaim" -RequiredFragments @("R16 closure") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-closed")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R16 is now closed in repo truth.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-product-runtime-overclaim" -RequiredFragments @("product runtime") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-product-runtime")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 ships product runtime and productized UI.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-agent-memory-retrieval-overclaim" -RequiredFragments @("true agent or multi-agent runtime") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-agent-memory-retrieval")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 implements actual autonomous agents, true multi-agent runtime, persistent memory engine, retrieval runtime, and vector search runtime.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-integration-overclaim" -RequiredFragments @("external integration") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-integration")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 implements GitHub Projects integration, Linear integration, Symphony integration, custom board integration, and external board sync.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-raci-transition-gate-overclaim" -RequiredFragments @("RACI transition gate runtime") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-raci-transition-gate")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 RACI transition gates execute role handoffs at runtime.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-executable-role-run-envelope-overclaim" -RequiredFragments @("executable or runtime role-run envelope implementation") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-executable-role-run-envelope")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "Generated role-run envelopes are executable for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-handoff-packet-runtime-overclaim" -RequiredFragments @("executable or runtime handoff packet implementation") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-handoff-packet")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "Handoff packet runtime exists for R16.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-workflow-drill-overclaim" -RequiredFragments @("workflow drill") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-workflow-drill")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 workflow drills ran for PM to Developer to QA.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-role-handoff-drill-runtime-overclaim" -RequiredFragments @("role-handoff drill runtime") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-role-handoff-drill-runtime")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The R16 role-handoff drill ran executable handoffs at runtime.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-audit-readiness-drill-runtime-overclaim" -RequiredFragments @("audit-readiness drill runtime or final-acceptance overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-audit-readiness-drill")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The R16 audit-readiness drill provides final R16 audit acceptance.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-friction-metrics-machine-proof-overclaim" -RequiredFragments @("friction metrics machine-proof or runtime overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-friction-metrics")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "The R16 friction metrics report is machine proof for closeout completion.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-solved-codex-overclaim" -RequiredFragments @("solved Codex compaction or reliability") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-solved-codex")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 proves solved Codex compaction and solved Codex reliability.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-main-merge-overclaim" -RequiredFragments @("main merge") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-main-merge")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R16 merged to main after opening.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-r14-caveats-removed" -RequiredFragments @("R14 caveat removal") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-r14-caveats-removed")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R14 is now accepted without caveats.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-r15-caveats-removed" -RequiredFragments @("R15 caveat removal") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r16-r15-caveats-removed")
        Add-Content -LiteralPath $scenario.R16AuthorityPath -Value ($crlf + "R15 is now accepted without caveats.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r17-004-implemented-overclaim" -RequiredFragments @("R17-004 or later implementation") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r17-004-implemented")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R17-004 is implemented by this pass.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r17-a2a-runtime-overclaim" -RequiredFragments @("A2A runtime or cycles working") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r17-a2a-runtime")
        Add-Content -LiteralPath $scenario.ActiveStatePath -Value ($crlf + "A2A runtime is working and four A2A cycles are exercised.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r17-adapter-runtime-overclaim" -RequiredFragments @("adapter runtime working") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r17-adapter-runtime")
        Add-Content -LiteralPath $scenario.R17AuthorityPath -Value ($crlf + "Dev/Codex executor adapter exists and QA/Test Agent adapter is working.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r17-kanban-ui-overclaim" -RequiredFragments @("Kanban UI working") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r17-kanban-ui")
        Add-Content -LiteralPath $scenario.KanbanPath -Value ($crlf + "Kanban UI is working for R17.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r10-closeout-without-phase-2-support-ref" -RequiredFragments @("Phase 2 final-head support packet") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r10-missing-phase-2-support")
        Replace-FileText -Path $scenario.ReadmePath -OldValue "state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json" -NewValue "state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/missing_packet.json"
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

    Invoke-ExpectedRefusal -Label "r11-open-without-r10-closeout-head" -RequiredFragments @("R10 closeout head") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-missing-r10-head")
        Replace-FileText -Path $scenario.R11AuthorityPath -OldValue "91035cfbb34f531684943d0bfd8c3ba660f48f08" -NewValue "91035cfbb34f531684943d0bfd8c3ba660f48f09"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-claims-broad-autonomy" -RequiredFragments @("broad autonomous milestone execution") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-broad-autonomy")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11 now proves broad autonomous milestone execution.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-claims-solved-compaction" -RequiredFragments @("solved Codex context compaction") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-solved-compaction")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11 proves solved Codex context compaction.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-claims-unattended-automatic-resume" -RequiredFragments @("unattended automatic resume") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-unattended-resume")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11 now provides unattended automatic resume.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-claims-ui-control-room" -RequiredFragments @("UI/control-room productization") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-ui-control-room")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11 now ships UI/control-room productization.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-claims-standard-multirepo-swarms" -RequiredFragments @("Standard runtime") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-standard-multirepo-swarms")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11 now ships Standard runtime, multi-repo orchestration, and swarms.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-missing-non-claim" -RequiredFragments @("R11 non-claim", "Codex context compaction") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-non-claim")
        Replace-RegexInFile -Path $scenario.R11AuthorityPath -Pattern '\- no solved Codex context compaction\r?\n' -Replacement ""
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r11-cycle-ledger-contract-ref" -RequiredFragments @("R11-002 ledger artifact", "cycle_ledger.contract.json") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-ledger-contract-ref")
        Replace-FileText -Path $scenario.R11AuthorityPath -OldValue "contracts/cycle_controller/cycle_ledger.contract.json" -NewValue "contracts/cycle_controller/cycle_ledger_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r11-local-residue-contract-ref" -RequiredFragments @("R11-005 local residue artifact", "local_residue_policy.contract.json") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-local-residue-contract-ref")
        Replace-FileText -Path $scenario.R11AuthorityPath -OldValue "contracts/cycle_controller/local_residue_policy.contract.json" -NewValue "contracts/cycle_controller/local_residue_policy_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r11-dev-dispatch-contract-ref" -RequiredFragments @("R11-006 bounded Dev adapter artifact", "dev_dispatch_packet.contract.json") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-dev-dispatch-contract-ref")
        Replace-FileText -Path $scenario.R11AuthorityPath -OldValue "contracts/cycle_controller/dev_dispatch_packet.contract.json" -NewValue "contracts/cycle_controller/dev_dispatch_packet_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-r11-qa-gate-contract-ref" -RequiredFragments @("R11 artifact", "cycle_qa_gate.contract.json") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-qa-gate-contract-ref")
        Replace-FileText -Path $scenario.R11AuthorityPath -OldValue "contracts/cycle_controller/cycle_qa_gate.contract.json" -NewValue "contracts/cycle_controller/cycle_qa_gate_missing.contract.json"
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-002-claims-controller-cli" -RequiredFragments @("R11-002 controller CLI implementation") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-controller-cli-claim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + "R11-002 now includes the controller CLI.") -Encoding UTF8
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "stale-r10-active-contradiction" -RequiredFragments @("stale R10 active contradiction") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-stale-r10-active")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ($crlf + '`R10` is currently open through `R10-008`.') -Encoding UTF8
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
        Replace-RegexInFile -Path $scenario.R10AuthorityPath -Pattern '###\s+`R10-008`\s+Close R10 only with real external final-head proof\r?\n-\s+Status:\s+done' -Replacement ('### `R10-008` Close R10 only with real external final-head proof' + $crlf + '- Status: planned')
        & $testStatusDocGate -RepositoryRoot $scenario.Root | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r11-task-status-mismatch" -RequiredFragments @("R11 authority does not match KANBAN") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r11-task-mismatch")
        Replace-RegexInFile -Path $scenario.R11AuthorityPath -Pattern '###\s+`R11-002`\s+Define cycle ledger/state machine\r?\n-\s+Status:\s+done' -Replacement ('### `R11-002` Define cycle ledger/state machine' + $crlf + '- Status: planned')
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
