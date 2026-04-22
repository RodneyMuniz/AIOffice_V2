$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dispatchModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleDispatch.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$executionEvidenceModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleExecutionEvidence.psm1") -Force -PassThru
$qaModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleQA.psm1") -Force -PassThru
$summaryModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleSummary.psm1") -Force -PassThru
$invokeMilestoneAutocycleDispatchFlow = $dispatchModule.ExportedCommands["Invoke-MilestoneAutocycleDispatchFlow"]
$setMilestoneAutocycleRunLedgerStatus = $dispatchModule.ExportedCommands["Set-MilestoneAutocycleRunLedgerStatus"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]
$invokeMilestoneAutocycleExecutionEvidenceFlow = $executionEvidenceModule.ExportedCommands["Invoke-MilestoneAutocycleExecutionEvidenceFlow"]
$invokeMilestoneAutocycleQAObservationFlow = $qaModule.ExportedCommands["Invoke-MilestoneAutocycleQAObservationFlow"]
$invokeMilestoneAutocycleSummaryFlow = $summaryModule.ExportedCommands["Invoke-MilestoneAutocycleSummaryFlow"]
$testMilestoneAutocycleSummaryContract = $summaryModule.ExportedCommands["Test-MilestoneAutocycleSummaryContract"]
$testMilestoneAutocycleDecisionPacketContract = $summaryModule.ExportedCommands["Test-MilestoneAutocycleDecisionPacketContract"]

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

function Initialize-SummaryHarness {
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
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-008-summary-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r6-008-approved-001" -FreezeId "freeze-r6-008-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T11:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before bounded summary generation."

    $bindingOutputRoot = Join-Path $Root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $Root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r6-008-valid-001" -BaselineId "baseline-r6-008-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T11:05:00Z").ToUniversalTime())

    $freeze = Get-JsonDocument -Path $approvalFlow.FreezePath
    $tasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $tasksById[$freezeTask.task_id] = $freezeTask
    }

    return [pscustomobject]@{
        Root = $Root
        BindingPath = $bindingFlow.BindingPath
        DispatchOutputRoot = (Join-Path $Root "state\autocycle\dispatch")
        EvidenceOutputRoot = (Join-Path $Root "state\autocycle\evidence")
        QAOutputRoot = (Join-Path $Root "state\autocycle\qa")
        SummaryOutputRoot = (Join-Path $Root "state\autocycle\summary")
        ExecutorEvidenceRoot = (Join-Path $Root "state\autocycle\executor_outputs")
        QAInputRoot = (Join-Path $Root "state\autocycle\qa_inputs")
        Branch = Get-CurrentBranch -Root $Root
        TasksById = $tasksById
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
            "tools/MilestoneAutocycleSummary.psm1",
            "contracts/milestone_autocycle/*.json",
            "tests/test_milestone_autocycle_summary.ps1"
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
            code = "summary_inputs_incomplete"
            description = "Refuse when bounded summary inputs are incomplete or malformed."
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

function New-CompletedQAAggregation {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [Parameter(Mandatory = $true)]
        [string]$TaskId
    )

    $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $Harness.BindingPath -TaskId $TaskId -AllowedScope (New-AllowedScope -ScopeSummary $Harness.TasksById[$TaskId].scope_summary) -TargetBranch $Harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $Harness.DispatchOutputRoot -DispatchId "dispatch-r6-008-pass-001" -LedgerId "run-ledger-r6-008-pass-001" -Notes "Create one governed Codex dispatch before bounded summary generation." -LedgerNotes "Initialize the governed run ledger before bounded summary generation."
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary "Dispatch has started under explicit operator control." -Notes "Executor start recorded before bounded summary generation." -OccurredAt ([datetime]::Parse("2026-04-22T11:10:00Z").ToUniversalTime()) | Out-Null
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary "Dispatch completed with bounded executor outputs ready for governed QA observation." -Notes "Dispatch and ledger statuses were updated durably." -OccurredAt ([datetime]::Parse("2026-04-22T11:15:00Z").ToUniversalTime()) | Out-Null

    $evidenceInputs = New-ExecutionEvidenceInputs -Harness $Harness -TaskId $TaskId
    $evidenceFlow = & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $dispatchFlow.DispatchPath -LedgerPath $dispatchFlow.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $Harness.EvidenceOutputRoot -EvidenceBundleId "execution-evidence-r6-008-pass-001" -Notes "Assemble one governed execution evidence bundle before bounded summary generation."

    $qaRefPath = Join-Path $Harness.QAInputRoot "task-r6-pilot-004-passed.md"
    New-Item -ItemType Directory -Path $Harness.QAInputRoot -Force | Out-Null
    Set-Content -LiteralPath $qaRefPath -Value "qa evidence ref for summary slice" -Encoding UTF8
    $qaFlow = & $invokeMilestoneAutocycleQAObservationFlow -EvidenceBundlePath $evidenceFlow.EvidenceBundlePath -Status "passed" -Findings @([pscustomobject]@{
            finding_id = "finding-task-r6-pilot-004-passed"
            summary = "QA checks passed for the governed task evidence bundle."
            notes = "Bounded QA finding recorded for the summary slice."
        }) -EvidenceRefs @([pscustomobject]@{
            kind = "qa_note"
            ref = $qaRefPath
            notes = "Durable QA evidence reference captured for the summary slice."
        }) -OutputRoot $Harness.QAOutputRoot -QAObservationId "qa-observation-r6-008-pass-001" -AggregationId "qa-aggregation-r6-008-main-001" -Notes "Create one bounded QA observation from one governed execution-evidence bundle only." -AggregationNotes "Update one bounded milestone-visible QA aggregation from bounded QA observations only."

    return [pscustomobject]@{
        DispatchPath = $dispatchFlow.DispatchPath
        RunLedgerPath = $dispatchFlow.RunLedgerPath
        EvidenceBundlePath = $evidenceFlow.EvidenceBundlePath
        QAAggregationPath = $qaFlow.QAAggregationPath
        QAObservationPath = $qaFlow.QAObservationPath
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
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-008-summary-main-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-SummaryHarness -Root $tempRoot
        $qaArtifacts = New-CompletedQAAggregation -Harness $harness -TaskId "task-r6-pilot-004"
        $aggregationBeforeSummary = Get-JsonDocument -Path $qaArtifacts.QAAggregationPath | ConvertTo-Json -Depth 20

        $summaryFlow = & $invokeMilestoneAutocycleSummaryFlow -QAAggregationPath $qaArtifacts.QAAggregationPath -OutputRoot $harness.SummaryOutputRoot -SummaryId "summary-r6-008-main-001" -DecisionPacketId "decision-packet-r6-008-main-001" -Notes "Create one bounded PRO-style summary from authoritative milestone QA state only." -DecisionPacketNotes "Expose bounded operator options without mutating milestone QA state."
        $summaryCheck = & $testMilestoneAutocycleSummaryContract -SummaryPath $summaryFlow.SummaryPath
        $decisionPacketCheck = & $testMilestoneAutocycleDecisionPacketContract -DecisionPacketPath $summaryFlow.DecisionPacketPath
        $aggregationAfterSummary = Get-JsonDocument -Path $qaArtifacts.QAAggregationPath | ConvertTo-Json -Depth 20

        if ($summaryCheck.CycleId -ne "cycle-r6-008-summary-001" -or $summaryCheck.Recommendation -ne "accept") {
            $failures += "FAIL happy-path summary: preserved identity or recommendation did not match the authoritative QA aggregation."
        }
        else {
            Write-Output ("PASS happy-path summary creation: {0}" -f $summaryCheck.SummaryId)
            $validPassed += 1
        }

        if ($decisionPacketCheck.DecisionPacketId -ne "decision-packet-r6-008-main-001" -or $decisionPacketCheck.Recommendation -ne "accept") {
            $failures += "FAIL happy-path decision packet: preserved identity or recommendation did not match the referenced summary."
        }
        else {
            Write-Output ("PASS happy-path decision packet creation: {0}" -f $decisionPacketCheck.DecisionPacketId)
            $validPassed += 1
        }

        if (-not $decisionPacketCheck.RecommendationIsAdvisory -or $aggregationBeforeSummary -ne $aggregationAfterSummary) {
            $failures += "FAIL recommendation advisory rule: summary flow changed authoritative QA aggregation state or failed to preserve advisory-only recommendation."
        }
        else {
            Write-Output "PASS recommendation remains advisory only."
            $validPassed += 1
        }

        Invoke-ExpectedRefusal -Label "missing QA aggregation artifact refusal" -Action {
            & $invokeMilestoneAutocycleSummaryFlow -QAAggregationPath (Join-Path $harness.Root "state\\autocycle\\qa\\qa_aggregations\\missing.json") -OutputRoot $harness.SummaryOutputRoot | Out-Null
        }

        $malformedAggregationPath = Join-Path (Split-Path -Parent $qaArtifacts.QAAggregationPath) "qa-aggregation-r6-008-malformed.json"
        Copy-Item -LiteralPath $qaArtifacts.QAAggregationPath -Destination $malformedAggregationPath -Force
        $malformedAggregation = Get-JsonDocument -Path $malformedAggregationPath
        $malformedAggregation.task_results = @()
        Write-JsonDocument -Path $malformedAggregationPath -Document $malformedAggregation
        Invoke-ExpectedRefusalWithMessage -Label "malformed QA aggregation artifact refusal" -RequiredFragments @(
            "task_results",
            "must not be empty"
        ) -Action {
            & $invokeMilestoneAutocycleSummaryFlow -QAAggregationPath $malformedAggregationPath -OutputRoot $harness.SummaryOutputRoot | Out-Null
        }

        $tamperedSummaryPath = Join-Path (Split-Path -Parent $summaryFlow.SummaryPath) "summary-r6-008-tampered.json"
        Copy-Item -LiteralPath $summaryFlow.SummaryPath -Destination $tamperedSummaryPath -Force
        $tamperedSummary = Get-JsonDocument -Path $tamperedSummaryPath
        $tamperedSummary.task_coverage = "not-an-array"
        Write-JsonDocument -Path $tamperedSummaryPath -Document $tamperedSummary
        Invoke-ExpectedRefusal -Label "malformed summary contract refusal" -Action {
            & $testMilestoneAutocycleSummaryContract -SummaryPath $tamperedSummaryPath | Out-Null
        }

        $tamperedDecisionPacketPath = Join-Path (Split-Path -Parent $summaryFlow.DecisionPacketPath) "decision-packet-r6-008-tampered.json"
        Copy-Item -LiteralPath $summaryFlow.DecisionPacketPath -Destination $tamperedDecisionPacketPath -Force
        $tamperedDecisionPacket = Get-JsonDocument -Path $tamperedDecisionPacketPath
        $tamperedDecisionPacket.summary_id = "not-the-real-summary-id"
        Write-JsonDocument -Path $tamperedDecisionPacketPath -Document $tamperedDecisionPacket
        Invoke-ExpectedRefusal -Label "malformed decision packet contract refusal" -Action {
            & $testMilestoneAutocycleDecisionPacketContract -DecisionPacketPath $tamperedDecisionPacketPath | Out-Null
        }

        $missingNonClaimsPath = Join-Path (Split-Path -Parent $summaryFlow.SummaryPath) "summary-r6-008-missing-non-claims.json"
        Copy-Item -LiteralPath $summaryFlow.SummaryPath -Destination $missingNonClaimsPath -Force
        $missingNonClaims = Get-JsonDocument -Path $missingNonClaimsPath
        $missingNonClaims.non_claims = @()
        Write-JsonDocument -Path $missingNonClaimsPath -Document $missingNonClaims
        Invoke-ExpectedRefusalWithMessage -Label "missing non-claims refusal" -RequiredFragments @(
            "non_claims",
            "must not be empty"
        ) -Action {
            & $testMilestoneAutocycleSummaryContract -SummaryPath $missingNonClaimsPath | Out-Null
        }

        $invalidRecommendationPath = Join-Path (Split-Path -Parent $summaryFlow.SummaryPath) "summary-r6-008-invalid-recommendation.json"
        Copy-Item -LiteralPath $summaryFlow.SummaryPath -Destination $invalidRecommendationPath -Force
        $invalidRecommendation = Get-JsonDocument -Path $invalidRecommendationPath
        $invalidRecommendation.recommendation = "approve"
        Write-JsonDocument -Path $invalidRecommendationPath -Document $invalidRecommendation
        Invoke-ExpectedRefusalWithMessage -Label "recommendation outside allowed values refusal" -RequiredFragments @(
            "recommendation",
            "accept, rework, stop"
        ) -Action {
            & $testMilestoneAutocycleSummaryContract -SummaryPath $invalidRecommendationPath | Out-Null
        }

        $invalidOptionsPath = Join-Path (Split-Path -Parent $summaryFlow.DecisionPacketPath) "decision-packet-r6-008-invalid-options.json"
        Copy-Item -LiteralPath $summaryFlow.DecisionPacketPath -Destination $invalidOptionsPath -Force
        $invalidOptions = Get-JsonDocument -Path $invalidOptionsPath
        $invalidOptions.options = @("accept", "expand", "stop")
        Write-JsonDocument -Path $invalidOptionsPath -Document $invalidOptions
        Invoke-ExpectedRefusalWithMessage -Label "decision options outside bounded set refusal" -RequiredFragments @(
            "options",
            "accept, rework, stop"
        ) -Action {
            & $testMilestoneAutocycleDecisionPacketContract -DecisionPacketPath $invalidOptionsPath | Out-Null
        }

        $claimingSummaryPath = Join-Path (Split-Path -Parent $summaryFlow.SummaryPath) "summary-r6-008-claiming.json"
        Copy-Item -LiteralPath $summaryFlow.SummaryPath -Destination $claimingSummaryPath -Force
        $claimingSummary = Get-JsonDocument -Path $claimingSummaryPath
        $claimingSummary.evidence_quality_summary = "This is final closeout evidence and replay proof complete for broader autonomy."
        Write-JsonDocument -Path $claimingSummaryPath -Document $claimingSummary
        Invoke-ExpectedRefusalWithMessage -Label "forbidden summary claim refusal" -RequiredFragments @(
            "must not claim",
            "replay proof complete"
        ) -Action {
            & $testMilestoneAutocycleSummaryContract -SummaryPath $claimingSummaryPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL summary harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle summary tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle summary tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
