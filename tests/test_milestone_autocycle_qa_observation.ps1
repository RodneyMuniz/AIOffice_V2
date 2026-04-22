$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dispatchModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleDispatch.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$executionEvidenceModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleExecutionEvidence.psm1") -Force -PassThru
$qaModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleQA.psm1") -Force -PassThru
$invokeMilestoneAutocycleDispatchFlow = $dispatchModule.ExportedCommands["Invoke-MilestoneAutocycleDispatchFlow"]
$setMilestoneAutocycleRunLedgerStatus = $dispatchModule.ExportedCommands["Set-MilestoneAutocycleRunLedgerStatus"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]
$invokeMilestoneAutocycleExecutionEvidenceFlow = $executionEvidenceModule.ExportedCommands["Invoke-MilestoneAutocycleExecutionEvidenceFlow"]
$invokeMilestoneAutocycleQAObservationFlow = $qaModule.ExportedCommands["Invoke-MilestoneAutocycleQAObservationFlow"]
$testMilestoneAutocycleQAObservationContract = $qaModule.ExportedCommands["Test-MilestoneAutocycleQAObservationContract"]
$testMilestoneAutocycleQAAggregationContract = $qaModule.ExportedCommands["Test-MilestoneAutocycleQAAggregationContract"]

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

    $json = $Document | ConvertTo-Json -Depth 20
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

function Initialize-QAHarness {
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

    $proposalPath = Join-Path $Root "state\fixtures\valid\milestone_autocycle\proposal.expected.json"
    $freezeOutputRoot = Join-Path $Root "state\autocycle\cycle"
    New-Item -ItemType Directory -Path $freezeOutputRoot -Force | Out-Null
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-007-qa-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r6-007-approved-001" -FreezeId "freeze-r6-007-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T09:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before bounded QA observation."

    $bindingOutputRoot = Join-Path $Root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $Root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r6-007-valid-001" -BaselineId "baseline-r6-007-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T09:15:00Z").ToUniversalTime())

    $freeze = Get-JsonDocument -Path $approvalFlow.FreezePath
    $tasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $tasksById[$freezeTask.task_id] = $freezeTask
    }

    return [pscustomobject]@{
        Root                 = $Root
        BindingPath          = $bindingFlow.BindingPath
        DispatchOutputRoot   = (Join-Path $Root "state\autocycle\dispatch")
        EvidenceOutputRoot   = (Join-Path $Root "state\autocycle\evidence")
        QAOutputRoot         = (Join-Path $Root "state\autocycle\qa")
        ExecutorEvidenceRoot = (Join-Path $Root "state\autocycle\executor_outputs")
        QAInputRoot          = (Join-Path $Root "state\autocycle\qa_inputs")
        Branch               = Get-CurrentBranch -Root $Root
        TasksById            = $tasksById
    }
}

function New-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScopeSummary
    )

    return [pscustomobject]@{
        scope_kind    = "frozen_task_dispatch"
        scope_summary = $ScopeSummary
        allowed_paths = @(
            "tools/MilestoneAutocycleQA.psm1",
            "contracts/milestone_autocycle/*.json",
            "tests/test_milestone_autocycle_qa_observation.ps1"
        )
        blocked_paths = @(
            "state/proof_reviews/**"
        )
    }
}

function New-ExpectedOutputs {
    return @(
        [pscustomobject]@{
            kind  = "dispatch_record"
            path  = "state/autocycle/dispatch/dispatches/*.json"
            notes = "Durable governed dispatch record."
        },
        [pscustomobject]@{
            kind  = "run_ledger"
            path  = "state/autocycle/dispatch/run_ledgers/*.json"
            notes = "Durable run ledger for the dispatch."
        }
    )
}

function New-RefusalConditions {
    return @(
        [pscustomobject]@{
            code        = "binding_missing"
            description = "Refuse when the baseline binding is missing, malformed, or no longer valid."
        },
        [pscustomobject]@{
            code        = "qa_evidence_incomplete"
            description = "Refuse when completed execution evidence cannot support bounded QA observation."
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
                path        = "README.md"
                change_kind = "modified"
                notes       = "The completed dispatch changed tracked repository content."
            }
        )
        ProducedArtifacts = @(
            [pscustomobject]@{
                kind  = "executor_artifact"
                path  = $artifactPath
                notes = "Durable produced artifact from the completed executor run."
            }
        )
        TestOutputs = @(
            [pscustomobject]@{
                kind  = "powershell_log"
                ref   = $testOutputPath
                notes = "Durable test output captured from the completed executor run."
            }
        )
        EvidenceRefs = @(
            [pscustomobject]@{
                kind  = "executor_note"
                ref   = $evidenceRefPath
                notes = "Durable evidence reference captured for operator review."
            }
        )
    }
}

function New-CompletedEvidenceBundle {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$DispatchId,
        [Parameter(Mandatory = $true)]
        [string]$LedgerId,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceBundleId
    )

    $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $Harness.BindingPath -TaskId $TaskId -AllowedScope (New-AllowedScope -ScopeSummary $Harness.TasksById[$TaskId].scope_summary) -TargetBranch $Harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $Harness.DispatchOutputRoot -DispatchId $DispatchId -LedgerId $LedgerId -Notes "Create one governed Codex dispatch before bounded QA observation." -LedgerNotes "Initialize the governed run ledger before bounded QA observation."
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary "Dispatch has started under explicit operator control." -Notes "Executor start recorded before bounded QA observation." -OccurredAt ([datetime]::Parse("2026-04-22T09:20:00Z").ToUniversalTime()) | Out-Null
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary "Dispatch completed with bounded executor outputs ready for governed QA observation." -Notes "Dispatch and ledger statuses were updated durably." -OccurredAt ([datetime]::Parse("2026-04-22T09:25:00Z").ToUniversalTime()) | Out-Null

    $evidenceInputs = New-ExecutionEvidenceInputs -Harness $Harness -TaskId $TaskId
    $evidenceFlow = & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $dispatchFlow.DispatchPath -LedgerPath $dispatchFlow.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $Harness.EvidenceOutputRoot -EvidenceBundleId $EvidenceBundleId -Notes "Assemble one governed execution evidence bundle before bounded QA observation."

    return [pscustomobject]@{
        DispatchPath      = $dispatchFlow.DispatchPath
        RunLedgerPath     = $dispatchFlow.RunLedgerPath
        EvidenceBundlePath = $evidenceFlow.EvidenceBundlePath
        EvidenceInputs    = $evidenceInputs
    }
}

function New-QAFindings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$Status
    )

    $summary = switch ($Status) {
        "passed" { "QA checks passed for the governed task evidence bundle." }
        "blocked" { "QA could not clear the task because bounded evidence remains incomplete or blocked." }
        "failed" { "QA found a bounded failure in the governed task evidence bundle." }
        default { "QA observation recorded for the governed task evidence bundle." }
    }

    Write-Output -NoEnumerate @(
        [pscustomobject]@{
            finding_id = ("finding-{0}-{1}" -f $TaskId, $Status)
            summary    = $summary
            notes      = ("Bounded QA finding recorded for {0} with status {1}." -f $TaskId, $Status)
        }
    )
}

function New-QAEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$Status
    )

    New-Item -ItemType Directory -Path $Harness.QAInputRoot -Force | Out-Null
    $qaRefPath = Join-Path $Harness.QAInputRoot ("{0}-{1}.md" -f $TaskId, $Status)
    Set-Content -LiteralPath $qaRefPath -Value ("qa evidence ref for {0} with status {1}" -f $TaskId, $Status) -Encoding UTF8

    Write-Output -NoEnumerate @(
        [pscustomobject]@{
            kind  = "qa_note"
            ref   = $qaRefPath
            notes = "Durable QA evidence reference captured for the observation."
        }
    )
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
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-007-qa-main-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-QAHarness -Root $tempRoot

        $passBundle = New-CompletedEvidenceBundle -Harness $harness -TaskId "task-r6-pilot-004" -DispatchId "dispatch-r6-007-pass-001" -LedgerId "run-ledger-r6-007-pass-001" -EvidenceBundleId "execution-evidence-r6-007-pass-001"
        $passFlow = & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $passBundle.EvidenceBundlePath -Status "passed" -Findings (New-QAFindings -TaskId "task-r6-pilot-004" -Status "passed") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-004" -Status "passed") -OutputRoot $harness.QAOutputRoot -QAObservationId "qa-observation-r6-007-pass-001" -AggregationId "qa-aggregation-r6-007-main-001" -Notes "Create one bounded QA observation from one governed execution-evidence bundle only." -AggregationNotes "Update one bounded milestone-visible QA aggregation from bounded QA observations only."
        $passObservationCheck = & $testMilestoneAutocycleQAObservationContract -QAObservationPath $passFlow.QAObservationPath
        $passAggregationCheck = & $testMilestoneAutocycleQAAggregationContract -QAAggregationPath $passFlow.QAAggregationPath

        if ($passObservationCheck.TaskId -ne "task-r6-pilot-004" -or $passObservationCheck.DispatchId -ne "dispatch-r6-007-pass-001") {
            $failures += "FAIL happy-path QA observation: preserved identity did not match the source execution evidence bundle."
        }
        if ($passAggregationCheck.MilestoneStatus -ne "passed" -or $passAggregationCheck.ProgressionState -ne "continue") {
            $failures += "FAIL happy-path milestone aggregation: expected passed/continue roll-up."
        }

        Write-Output ("PASS happy-path QA observation creation: {0}" -f $passObservationCheck.QAObservationId)
        Write-Output ("PASS happy-path milestone aggregation update: {0}" -f $passAggregationCheck.AggregationId)
        $validPassed += 2

        Invoke-ExpectedRefusal -Label "missing execution-evidence bundle refusal" -Action {
            & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath (Join-Path $harness.Root "state\autocycle\evidence\execution_evidence\missing-bundle.json") -Status "passed" -Findings (New-QAFindings -TaskId "task-r6-pilot-004" -Status "passed") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-004" -Status "missing-bundle") -OutputRoot $harness.QAOutputRoot | Out-Null
        }

        $malformedBundlePath = Join-Path (Split-Path -Parent $passBundle.EvidenceBundlePath) "execution-evidence-r6-007-malformed-bundle.json"
        Copy-Item -LiteralPath $passBundle.EvidenceBundlePath -Destination $malformedBundlePath -Force
        $malformedBundle = Get-JsonDocument -Path $malformedBundlePath
        $malformedBundle.record_type = "not-execution-evidence"
        Write-JsonDocument -Path $malformedBundlePath -Document $malformedBundle
        Invoke-ExpectedRefusal -Label "malformed execution-evidence bundle refusal" -Action {
            & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $malformedBundlePath -Status "passed" -Findings (New-QAFindings -TaskId "task-r6-pilot-004" -Status "passed") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-004" -Status "malformed-bundle") -OutputRoot $harness.QAOutputRoot | Out-Null
        }

        $missingBundleRefsPath = Join-Path (Split-Path -Parent $passBundle.EvidenceBundlePath) "execution-evidence-r6-007-missing-refs.json"
        Copy-Item -LiteralPath $passBundle.EvidenceBundlePath -Destination $missingBundleRefsPath -Force
        $missingBundleRefs = Get-JsonDocument -Path $missingBundleRefsPath
        $missingBundleRefs.evidence_refs = @()
        Write-JsonDocument -Path $missingBundleRefsPath -Document $missingBundleRefs
        Invoke-ExpectedRefusalWithMessage -Label "missing evidence refs required for QA refusal" -RequiredFragments @(
            "evidence_refs",
            "must not be empty"
        ) -Action {
            & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $missingBundleRefsPath -Status "passed" -Findings (New-QAFindings -TaskId "task-r6-pilot-004" -Status "passed") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-004" -Status "missing-refs") -OutputRoot $harness.QAOutputRoot | Out-Null
        }

        $badFindings = @(
            [pscustomobject]@{
                finding_id = "finding-malformed-r6-007"
                summary    = "Missing notes should fail closed."
            }
        )
        Invoke-ExpectedRefusal -Label "malformed findings refusal" -Action {
            & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $passBundle.EvidenceBundlePath -Status "passed" -Findings $badFindings -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-004" -Status "bad-findings") -OutputRoot $harness.QAOutputRoot | Out-Null
        }

        $blockedBundle = New-CompletedEvidenceBundle -Harness $harness -TaskId "task-r6-pilot-005" -DispatchId "dispatch-r6-007-blocked-001" -LedgerId "run-ledger-r6-007-blocked-001" -EvidenceBundleId "execution-evidence-r6-007-blocked-001"
        $blockedFlow = & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $blockedBundle.EvidenceBundlePath -Status "blocked" -Findings (New-QAFindings -TaskId "task-r6-pilot-005" -Status "blocked") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-005" -Status "blocked") -OutputRoot $harness.QAOutputRoot -QAObservationId "qa-observation-r6-007-blocked-001" -AggregationId "qa-aggregation-r6-007-main-001" -Notes "Create one bounded blocked QA observation from one governed execution-evidence bundle only." -AggregationNotes "Update one bounded milestone-visible QA aggregation from bounded QA observations only."
        $blockedAggregation = & $testMilestoneAutocycleQAAggregationContract -QAAggregationPath $blockedFlow.QAAggregationPath
        if ($blockedAggregation.MilestoneStatus -ne "blocked" -or $blockedAggregation.ProgressionState -ne "stop" -or $blockedAggregation.StopReasonCode -ne "qa_evidence_incomplete") {
            $failures += "FAIL blocked QA roll-up: expected blocked/stop with qa_evidence_incomplete."
        }
        else {
            Write-Output ("PASS blocked QA rolls milestone aggregation into blocked or stop state: {0}" -f $blockedAggregation.AggregationId)
            $validPassed += 1
        }

        $failedBundle = New-CompletedEvidenceBundle -Harness $harness -TaskId "task-r6-pilot-006" -DispatchId "dispatch-r6-007-failed-001" -LedgerId "run-ledger-r6-007-failed-001" -EvidenceBundleId "execution-evidence-r6-007-failed-001"
        $failedFlow = & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $failedBundle.EvidenceBundlePath -Status "failed" -Findings (New-QAFindings -TaskId "task-r6-pilot-006" -Status "failed") -EvidenceRefs (New-QAEvidenceRefs -Harness $harness -TaskId "task-r6-pilot-006" -Status "failed") -OutputRoot $harness.QAOutputRoot -QAObservationId "qa-observation-r6-007-failed-001" -AggregationId "qa-aggregation-r6-007-main-001" -Notes "Create one bounded failed QA observation from one governed execution-evidence bundle only." -AggregationNotes "Update one bounded milestone-visible QA aggregation from bounded QA observations only."
        $failedAggregation = & $testMilestoneAutocycleQAAggregationContract -QAAggregationPath $failedFlow.QAAggregationPath
        if ($failedAggregation.MilestoneStatus -ne "failed" -or $failedAggregation.ProgressionState -ne "stop" -or $failedAggregation.StopReasonCode -ne "qa_failed") {
            $failures += "FAIL failed QA roll-up: expected failed/stop with qa_failed."
        }
        else {
            Write-Output ("PASS failed QA rolls milestone aggregation into failed or stop state: {0}" -f $failedAggregation.AggregationId)
            $validPassed += 1
        }

        $tamperedObservationPath = Join-Path (Split-Path -Parent $passFlow.QAObservationPath) "qa-observation-r6-007-tampered.json"
        Copy-Item -LiteralPath $passFlow.QAObservationPath -Destination $tamperedObservationPath -Force
        $tamperedObservation = Get-JsonDocument -Path $tamperedObservationPath
        $tamperedObservation.findings = "not-an-array"
        Write-JsonDocument -Path $tamperedObservationPath -Document $tamperedObservation
        Invoke-ExpectedRefusal -Label "malformed QA observation contract refusal" -Action {
            & $testMilestoneAutocycleQAObservationContract -QAObservationPath $tamperedObservationPath | Out-Null
        }

        $tamperedAggregationPath = Join-Path (Split-Path -Parent $failedFlow.QAAggregationPath) "qa-aggregation-r6-007-tampered.json"
        Copy-Item -LiteralPath $failedFlow.QAAggregationPath -Destination $tamperedAggregationPath -Force
        $tamperedAggregation = Get-JsonDocument -Path $tamperedAggregationPath
        $tamperedAggregation.progression_state = "continue"
        Write-JsonDocument -Path $tamperedAggregationPath -Document $tamperedAggregation
        Invoke-ExpectedRefusalWithMessage -Label "malformed milestone aggregation contract refusal" -RequiredFragments @(
            "progression_state",
            "rolled-up task QA state"
        ) -Action {
            & $testMilestoneAutocycleQAAggregationContract -QAAggregationPath $tamperedAggregationPath | Out-Null
        }

        $unexpectedLaterArtifacts = @(Get-ChildItem -LiteralPath $harness.QAOutputRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -like "*summary*" -or $_.Name -like "*decision*"
            })
        if ($unexpectedLaterArtifacts.Count -gt 0) {
            $failures += "FAIL no summary or decision-packet artifacts: later-stage artifacts were created unexpectedly."
        }
        else {
            Write-Output "PASS no summary or decision-packet artifacts are introduced by this slice."
            $validPassed += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL QA observation harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle QA observation tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle QA observation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
