$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dispatchModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleDispatch.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$executionEvidenceModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleExecutionEvidence.psm1") -Force -PassThru
$qaModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleQA.psm1") -Force -PassThru
$summaryModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleSummary.psm1") -Force -PassThru
$closeoutModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleCloseout.psm1") -Force -PassThru
$invokeMilestoneAutocycleDispatchFlow = $dispatchModule.ExportedCommands["Invoke-MilestoneAutocycleDispatchFlow"]
$setMilestoneAutocycleRunLedgerStatus = $dispatchModule.ExportedCommands["Set-MilestoneAutocycleRunLedgerStatus"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]
$invokeMilestoneAutocycleExecutionEvidenceFlow = $executionEvidenceModule.ExportedCommands["Invoke-MilestoneAutocycleExecutionEvidenceFlow"]
$invokeMilestoneAutocycleQAObservationFlow = $qaModule.ExportedCommands["Invoke-MilestoneAutocycleQAObservationFlow"]
$invokeMilestoneAutocycleSummaryFlow = $summaryModule.ExportedCommands["Invoke-MilestoneAutocycleSummaryFlow"]
$invokeMilestoneAutocycleCloseoutFlow = $closeoutModule.ExportedCommands["Invoke-MilestoneAutocycleCloseoutFlow"]
$testMilestoneAutocycleReplayProofContract = $closeoutModule.ExportedCommands["Test-MilestoneAutocycleReplayProofContract"]
$testMilestoneAutocycleCloseoutPacketContract = $closeoutModule.ExportedCommands["Test-MilestoneAutocycleCloseoutPacketContract"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 25
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-TempGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    & git -C $Root init | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize temp Git repository."
    }

    & git -C $Root config core.autocrlf false | Out-Null
    & git -C $Root config core.safecrlf false | Out-Null
    & git -C $Root config user.email "codex@example.com" | Out-Null
    & git -C $Root config user.name "Codex" | Out-Null
    Add-Content -LiteralPath (Join-Path $Root ".git\info\exclude") -Value "state/autocycle/"
    Set-Content -LiteralPath (Join-Path $Root "README.md") -Value "# Temp repo" -Encoding UTF8
    & git -C $Root add README.md | Out-Null
    & git -C $Root commit -m "initial temp commit" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create initial temp Git commit."
    }
}

function Invoke-GitCommitAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    & git -C $Root add -A | Out-Null
    & git -C $Root commit -m $Message | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit '$Message' in temp Git repository."
    }
}

function Get-CurrentBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $branch = (& git -C $Root branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Failed to determine the current branch in temp Git repository."
    }

    return $branch
}

function Initialize-CloseoutHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-TempGitRepository -Root $Root
    $fixtureSource = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle"
    $fixtureDestinationParent = Join-Path $Root "state\fixtures\valid"
    New-Item -ItemType Directory -Path $fixtureDestinationParent -Force | Out-Null
    Copy-Item -LiteralPath $fixtureSource -Destination $fixtureDestinationParent -Recurse -Force
    Invoke-GitCommitAll -Root $Root -Message "add milestone autocycle fixtures"

    return [pscustomobject]@{
        Root = $Root
        ProposalPath = (Join-Path $Root "state\fixtures\valid\milestone_autocycle\proposal.expected.json")
        CycleOutputRoot = (Join-Path $Root "state\autocycle\cycle")
        BindingOutputRoot = (Join-Path $Root "state\autocycle\baseline_binding")
        DispatchOutputRoot = (Join-Path $Root "state\autocycle\dispatch")
        EvidenceOutputRoot = (Join-Path $Root "state\autocycle\evidence")
        QAOutputRoot = (Join-Path $Root "state\autocycle\qa")
        SummaryOutputRoot = (Join-Path $Root "state\autocycle\summary")
        CloseoutOutputRoot = (Join-Path $Root "state\autocycle\closeout")
        ExecutorEvidenceRoot = (Join-Path $Root "state\autocycle\executor_outputs")
        QAInputRoot = (Join-Path $Root "state\autocycle\qa_inputs")
        Branch = Get-CurrentBranch -Root $Root
    }
}

function New-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScopeSummary
    )

    return [pscustomobject]@{
        scope_kind = "frozen_task_dispatch"
        scope_summary = $ScopeSummary
        allowed_paths = @(
            "tools/MilestoneAutocycleCloseout.psm1",
            "contracts/milestone_autocycle/*.json",
            "tests/test_milestone_autocycle_closeout.ps1"
        )
        blocked_paths = @(
            "state/proof_reviews/**"
        )
    }
}

function New-ExpectedOutputs {
    return @(
        [pscustomobject]@{
            kind = "dispatch_record"
            path = "state/autocycle/dispatch/dispatches/*.json"
            notes = "Durable governed dispatch record."
        },
        [pscustomobject]@{
            kind = "run_ledger"
            path = "state/autocycle/dispatch/run_ledgers/*.json"
            notes = "Durable run ledger for the dispatch."
        }
    )
}

function New-RefusalConditions {
    return @(
        [pscustomobject]@{
            code = "binding_missing"
            description = "Refuse when the baseline binding is missing, malformed, or no longer valid."
        },
        [pscustomobject]@{
            code = "closeout_inputs_incomplete"
            description = "Refuse when replay proof or closeout inputs are incomplete or malformed."
        }
    )
}

function New-ExecutionEvidenceInputs {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [Parameter(Mandatory = $true)]
        [string]$TaskId
    )

    $artifactDirectory = Join-Path $Harness.ExecutorEvidenceRoot "artifacts"
    $testOutputDirectory = Join-Path $Harness.ExecutorEvidenceRoot "test_outputs"
    $evidenceRefDirectory = Join-Path $Harness.ExecutorEvidenceRoot "evidence_refs"
    New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $testOutputDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $evidenceRefDirectory -Force | Out-Null

    $artifactPath = Join-Path $artifactDirectory ("{0}.txt" -f $TaskId)
    $testOutputPath = Join-Path $testOutputDirectory ("{0}.log" -f $TaskId)
    $evidenceRefPath = Join-Path $evidenceRefDirectory ("{0}.md" -f $TaskId)
    Set-Content -LiteralPath $artifactPath -Value ("artifact for {0}" -f $TaskId) -Encoding UTF8
    Set-Content -LiteralPath $testOutputPath -Value ("test output for {0}" -f $TaskId) -Encoding UTF8
    Set-Content -LiteralPath $evidenceRefPath -Value ("execution evidence ref for {0}" -f $TaskId) -Encoding UTF8

    return [pscustomobject]@{
        ChangedFiles = @(
            [pscustomobject]@{
                path = "README.md"
                change_kind = "modified"
                notes = "The completed dispatch changed tracked repository content."
            }
        )
        ProducedArtifacts = @(
            [pscustomobject]@{
                kind = "executor_artifact"
                path = $artifactPath
                notes = "Durable produced artifact from the completed executor run."
            }
        )
        TestOutputs = @(
            [pscustomobject]@{
                kind = "powershell_log"
                ref = $testOutputPath
                notes = "Durable test output captured from the completed executor run."
            }
        )
        EvidenceRefs = @(
            [pscustomobject]@{
                kind = "executor_note"
                ref = $evidenceRefPath
                notes = "Durable evidence reference captured for operator review."
            }
        )
    }
}

function New-CompletedSummaryArtifacts {
    param(
        [Parameter(Mandatory = $true)]
        $Harness
    )

    New-Item -ItemType Directory -Path $Harness.CycleOutputRoot -Force | Out-Null
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $Harness.ProposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-009-closeout-001" -OutputRoot $Harness.CycleOutputRoot -DecisionId "decision-r6-009-approved-001" -FreezeId "freeze-r6-009-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T12:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before bounded replay proof and closeout assembly."
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $Harness.Root -OutputRoot $Harness.BindingOutputRoot -BindingId "baseline-binding-r6-009-valid-001" -BaselineId "baseline-r6-009-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T12:05:00Z").ToUniversalTime())

    $freeze = Get-JsonDocument -Path $approvalFlow.FreezePath
    $task = @($freeze.frozen_task_set)[0]

    $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $bindingFlow.BindingPath -TaskId $task.task_id -AllowedScope (New-AllowedScope -ScopeSummary $task.scope_summary) -TargetBranch $Harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $Harness.DispatchOutputRoot -DispatchId "dispatch-r6-009-pass-001" -LedgerId "run-ledger-r6-009-pass-001" -Notes "Create one governed Codex dispatch before bounded closeout generation." -LedgerNotes "Initialize the governed run ledger before bounded closeout generation."
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary "Dispatch has started under explicit operator control." -Notes "Executor start recorded before bounded closeout generation." -OccurredAt ([datetime]::Parse("2026-04-22T12:10:00Z").ToUniversalTime()) | Out-Null
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary "Dispatch completed with bounded executor outputs ready for governed QA and closeout." -Notes "Dispatch and ledger statuses were updated durably." -OccurredAt ([datetime]::Parse("2026-04-22T12:15:00Z").ToUniversalTime()) | Out-Null

    $evidenceInputs = New-ExecutionEvidenceInputs -Harness $Harness -TaskId $task.task_id
    $evidenceFlow = & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $dispatchFlow.DispatchPath -LedgerPath $dispatchFlow.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $Harness.EvidenceOutputRoot -EvidenceBundleId "execution-evidence-r6-009-pass-001" -Notes "Assemble one governed execution evidence bundle before bounded closeout generation."

    New-Item -ItemType Directory -Path $Harness.QAInputRoot -Force | Out-Null
    $qaRefPath = Join-Path $Harness.QAInputRoot "task-r6-pilot-004-passed.md"
    Set-Content -LiteralPath $qaRefPath -Value "qa evidence ref for closeout slice" -Encoding UTF8
    $qaFlow = & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $evidenceFlow.EvidenceBundlePath -Status "passed" -Findings @([pscustomobject]@{
            finding_id = "finding-task-r6-pilot-004-passed"
            summary = "QA checks passed for the governed task evidence bundle."
            notes = "Bounded QA finding recorded for the closeout slice."
        }) -EvidenceRefs @([pscustomobject]@{
            kind = "qa_note"
            ref = $qaRefPath
            notes = "Durable QA evidence reference captured for the closeout slice."
        }) -OutputRoot $Harness.QAOutputRoot -QAObservationId "qa-observation-r6-009-pass-001" -AggregationId "qa-aggregation-r6-009-main-001" -Notes "Create one bounded QA observation from one governed execution-evidence bundle only." -AggregationNotes "Update one bounded milestone-visible QA aggregation from bounded QA observations only."

    $summaryFlow = & $invokeMilestoneAutocycleSummaryFlow -QAAggregationPath $qaFlow.QAAggregationPath -OutputRoot $Harness.SummaryOutputRoot -SummaryId "summary-r6-009-main-001" -DecisionPacketId "decision-packet-r6-009-main-001" -Notes "Create one bounded PRO-style summary from authoritative milestone QA state only." -DecisionPacketNotes "Expose bounded operator options without mutating milestone QA state."

    return [pscustomobject]@{
        ProposalPath = $Harness.ProposalPath
        ApprovalPath = $approvalFlow.ApprovalPath
        FreezePath = $approvalFlow.FreezePath
        BindingPath = $bindingFlow.BindingPath
        DispatchPath = $dispatchFlow.DispatchPath
        RunLedgerPath = $dispatchFlow.RunLedgerPath
        EvidenceBundlePath = $evidenceFlow.EvidenceBundlePath
        QAObservationPath = $qaFlow.QAObservationPath
        QAAggregationPath = $qaFlow.QAAggregationPath
        SummaryPath = $summaryFlow.SummaryPath
        DecisionPacketPath = $summaryFlow.DecisionPacketPath
    }
}

function New-ProofRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Artifacts
    )

    return [pscustomobject]@{
        proposal_ref = $Artifacts.ProposalPath
        approval_ref = $Artifacts.ApprovalPath
        freeze_ref = $Artifacts.FreezePath
        baseline_binding_ref = $Artifacts.BindingPath
        dispatch_refs = @($Artifacts.DispatchPath)
        run_ledger_refs = @($Artifacts.RunLedgerPath)
        execution_evidence_refs = @($Artifacts.EvidenceBundlePath)
        qa_observation_refs = @($Artifacts.QAObservationPath)
        qa_aggregation_ref = $Artifacts.QAAggregationPath
    }
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
        $script:failures += ("FAIL {0}: operation succeeded unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS {0}: {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

function Invoke-ExpectedRefusalWithMessage {
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
        $script:failures += ("FAIL {0}: operation succeeded unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL {0}: refusal message did not include expected fragments: {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS {0}: {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-009-closeout-main-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-CloseoutHarness -Root $tempRoot
        $artifacts = New-CompletedSummaryArtifacts -Harness $harness
        $proofRefs = New-ProofRefs -Artifacts $artifacts

        $closeoutFlow = & $invokeMilestoneAutocycleCloseoutFlow -SummaryPath $artifacts.SummaryPath -DecisionPacketPath $artifacts.DecisionPacketPath -ProofRefs $proofRefs -OutputRoot $harness.CloseoutOutputRoot -ReplayProofId "replay-proof-r6-009-main-001" -CloseoutPacketId "closeout-packet-r6-009-main-001" -Notes "Create one bounded replay proof from authoritative summary, decision packet, and governed artifact refs only." -CloseoutNotes "Create one bounded closeout packet from the authoritative replay proof only."
        $replayProofCheck = & $testMilestoneAutocycleReplayProofContract -ReplayProofPath $closeoutFlow.ReplayProofPath
        $closeoutPacketCheck = & $testMilestoneAutocycleCloseoutPacketContract -CloseoutPacketPath $closeoutFlow.CloseoutPacketPath

        if ($replayProofCheck.CycleId -ne "cycle-r6-009-closeout-001" -or $replayProofCheck.OperatorDecisionState -ne "advisory_only_not_executed") {
            $failures += "FAIL happy-path replay proof: preserved identity or operator decision state did not match the bounded advisory closeout flow."
        }
        else {
            Write-Output ("PASS happy-path replay proof creation: {0}" -f $replayProofCheck.ReplayProofId)
            $validPassed += 1
        }

        if ($closeoutPacketCheck.CloseoutPacketId -ne "closeout-packet-r6-009-main-001" -or $closeoutPacketCheck.OperatorDecisionState -ne "advisory_only_not_executed") {
            $failures += "FAIL happy-path closeout packet: preserved identity or operator decision state did not match the referenced replay proof."
        }
        else {
            Write-Output ("PASS happy-path closeout packet creation: {0}" -f $closeoutPacketCheck.CloseoutPacketId)
            $validPassed += 1
        }

        Invoke-ExpectedRefusal -Label "missing summary artifact refusal" -Action {
            & $invokeMilestoneAutocycleCloseoutFlow -SummaryPath (Join-Path $harness.Root "state\\autocycle\\summary\\summaries\\missing-summary.json") -DecisionPacketPath $artifacts.DecisionPacketPath -ProofRefs $proofRefs -OutputRoot $harness.CloseoutOutputRoot | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing decision packet artifact refusal" -Action {
            & $invokeMilestoneAutocycleCloseoutFlow -SummaryPath $artifacts.SummaryPath -DecisionPacketPath (Join-Path $harness.Root "state\\autocycle\\summary\\decision_packets\\missing-decision-packet.json") -ProofRefs $proofRefs -OutputRoot $harness.CloseoutOutputRoot | Out-Null
        }

        $cycleMismatchDecisionPacketPath = Join-Path (Split-Path -Parent $artifacts.DecisionPacketPath) "decision-packet-r6-009-cycle-mismatch.json"
        Copy-Item -LiteralPath $artifacts.DecisionPacketPath -Destination $cycleMismatchDecisionPacketPath -Force
        $cycleMismatchDecisionPacket = Get-JsonDocument -Path $cycleMismatchDecisionPacketPath
        $cycleMismatchDecisionPacket.cycle_id = "cycle-r6-009-other"
        Write-JsonDocument -Path $cycleMismatchDecisionPacketPath -Document $cycleMismatchDecisionPacket
        Invoke-ExpectedRefusalWithMessage -Label "summary or decision-packet cycle mismatch refusal" -RequiredFragments @(
            "cycle_id",
            "referenced summary"
        ) -Action {
            & $invokeMilestoneAutocycleCloseoutFlow -SummaryPath $artifacts.SummaryPath -DecisionPacketPath $cycleMismatchDecisionPacketPath -ProofRefs $proofRefs -OutputRoot $harness.CloseoutOutputRoot | Out-Null
        }

        $missingProofRefs = [pscustomobject]@{
            proposal_ref = $artifacts.ProposalPath
            freeze_ref = $artifacts.FreezePath
            baseline_binding_ref = $artifacts.BindingPath
            dispatch_refs = @($artifacts.DispatchPath)
            run_ledger_refs = @($artifacts.RunLedgerPath)
            execution_evidence_refs = @($artifacts.EvidenceBundlePath)
            qa_observation_refs = @($artifacts.QAObservationPath)
            qa_aggregation_ref = $artifacts.QAAggregationPath
        }
        Invoke-ExpectedRefusalWithMessage -Label "missing required proof refs refusal" -RequiredFragments @(
            "proof_refs",
            "approval_ref"
        ) -Action {
            & $invokeMilestoneAutocycleCloseoutFlow -SummaryPath $artifacts.SummaryPath -DecisionPacketPath $artifacts.DecisionPacketPath -ProofRefs $missingProofRefs -OutputRoot $harness.CloseoutOutputRoot | Out-Null
        }

        $tamperedReplayProofPath = Join-Path (Split-Path -Parent $closeoutFlow.ReplayProofPath) "replay-proof-r6-009-tampered.json"
        Copy-Item -LiteralPath $closeoutFlow.ReplayProofPath -Destination $tamperedReplayProofPath -Force
        $tamperedReplayProof = Get-JsonDocument -Path $tamperedReplayProofPath
        $tamperedReplayProof.proof_refs.dispatch_refs = "not-an-array"
        Write-JsonDocument -Path $tamperedReplayProofPath -Document $tamperedReplayProof
        Invoke-ExpectedRefusal -Label "malformed replay proof contract refusal" -Action {
            & $testMilestoneAutocycleReplayProofContract -ReplayProofPath $tamperedReplayProofPath | Out-Null
        }

        $tamperedCloseoutPacketPath = Join-Path (Split-Path -Parent $closeoutFlow.CloseoutPacketPath) "closeout-packet-r6-009-tampered.json"
        Copy-Item -LiteralPath $closeoutFlow.CloseoutPacketPath -Destination $tamperedCloseoutPacketPath -Force
        $tamperedCloseoutPacket = Get-JsonDocument -Path $tamperedCloseoutPacketPath
        $tamperedCloseoutPacket.replay_proof_id = "not-the-real-replay-proof-id"
        Write-JsonDocument -Path $tamperedCloseoutPacketPath -Document $tamperedCloseoutPacket
        Invoke-ExpectedRefusal -Label "malformed closeout packet contract refusal" -Action {
            & $testMilestoneAutocycleCloseoutPacketContract -CloseoutPacketPath $tamperedCloseoutPacketPath | Out-Null
        }

        $claimingCloseoutPacketPath = Join-Path (Split-Path -Parent $closeoutFlow.CloseoutPacketPath) "closeout-packet-r6-009-claiming.json"
        Copy-Item -LiteralPath $closeoutFlow.CloseoutPacketPath -Destination $claimingCloseoutPacketPath -Force
        $claimingCloseoutPacket = Get-JsonDocument -Path $claimingCloseoutPacketPath
        $claimingCloseoutPacket.proved_scope = "This proves broader autonomy and proves rollback execution."
        Write-JsonDocument -Path $claimingCloseoutPacketPath -Document $claimingCloseoutPacket
        Invoke-ExpectedRefusalWithMessage -Label "overclaiming closeout language refusal" -RequiredFragments @(
            "must not claim",
            "proves broader autonomy"
        ) -Action {
            & $testMilestoneAutocycleCloseoutPacketContract -CloseoutPacketPath $claimingCloseoutPacketPath | Out-Null
        }

        $misrepresentedCloseoutPacketPath = Join-Path (Split-Path -Parent $closeoutFlow.CloseoutPacketPath) "closeout-packet-r6-009-misrepresented.json"
        Copy-Item -LiteralPath $closeoutFlow.CloseoutPacketPath -Destination $misrepresentedCloseoutPacketPath -Force
        $misrepresentedCloseoutPacket = Get-JsonDocument -Path $misrepresentedCloseoutPacketPath
        $misrepresentedCloseoutPacket.operator_decision_state = "accepted"
        Write-JsonDocument -Path $misrepresentedCloseoutPacketPath -Document $misrepresentedCloseoutPacket
        Invoke-ExpectedRefusalWithMessage -Label "advisory-only recommendation misrepresented as executed operator decision refusal" -RequiredFragments @(
            "operator_decision_state",
            "advisory_only_not_executed"
        ) -Action {
            & $testMilestoneAutocycleCloseoutPacketContract -CloseoutPacketPath $misrepresentedCloseoutPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL closeout harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle closeout tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle closeout tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
