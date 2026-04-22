$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dispatchModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleDispatch.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$executionEvidenceModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleExecutionEvidence.psm1") -Force -PassThru
$invokeMilestoneAutocycleDispatchFlow = $dispatchModule.ExportedCommands["Invoke-MilestoneAutocycleDispatchFlow"]
$setMilestoneAutocycleRunLedgerStatus = $dispatchModule.ExportedCommands["Set-MilestoneAutocycleRunLedgerStatus"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]
$invokeMilestoneAutocycleExecutionEvidenceFlow = $executionEvidenceModule.ExportedCommands["Invoke-MilestoneAutocycleExecutionEvidenceFlow"]
$testMilestoneAutocycleExecutionEvidenceContract = $executionEvidenceModule.ExportedCommands["Test-MilestoneAutocycleExecutionEvidenceContract"]

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

function Initialize-ExecutionEvidenceHarness {
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
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-006-evidence-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r6-006-approved-001" -FreezeId "freeze-r6-006-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T08:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before governed evidence assembly."

    $bindingOutputRoot = Join-Path $Root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $Root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r6-006-valid-001" -BaselineId "baseline-r6-006-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T08:15:00Z").ToUniversalTime())

    $freeze = Get-JsonDocument -Path $approvalFlow.FreezePath
    $tasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $tasksById[$freezeTask.task_id] = $freezeTask
    }

    return [pscustomobject]@{
        Root                = $Root
        ProposalPath        = $proposalPath
        FreezePath          = $approvalFlow.FreezePath
        BindingPath         = $bindingFlow.BindingPath
        DispatchOutputRoot  = (Join-Path $Root "state\autocycle\dispatch")
        EvidenceOutputRoot  = (Join-Path $Root "state\autocycle\evidence")
        ExecutorEvidenceRoot = (Join-Path $Root "state\autocycle\executor_outputs")
        Branch              = Get-CurrentBranch -Root $Root
        TasksById           = $tasksById
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
            "tools/MilestoneAutocycleExecutionEvidence.psm1",
            "contracts/milestone_autocycle/*.json",
            "tests/test_milestone_autocycle_execution_evidence.ps1"
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
            code        = "executor_evidence_incomplete"
            description = "Refuse when the completed dispatch does not produce complete governed execution evidence."
        }
    )
}

function New-CompletedDispatch {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$DispatchId,
        [Parameter(Mandatory = $true)]
        [string]$LedgerId
    )

    $dispatchFlow = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $Harness.BindingPath -TaskId $TaskId -AllowedScope (New-AllowedScope -ScopeSummary $Harness.TasksById[$TaskId].scope_summary) -TargetBranch $Harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $Harness.DispatchOutputRoot -DispatchId $DispatchId -LedgerId $LedgerId -Notes "Create one governed Codex dispatch before bounded evidence assembly." -LedgerNotes "Initialize the governed run ledger before recording execution evidence."
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary "Dispatch has started under explicit operator control." -Notes "Executor start recorded before evidence assembly." -OccurredAt ([datetime]::Parse("2026-04-22T08:20:00Z").ToUniversalTime()) | Out-Null
    & $setMilestoneAutocycleRunLedgerStatus -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary "Dispatch completed with bounded executor outputs ready for governed evidence assembly." -Notes "Dispatch and ledger statuses were updated durably." -OccurredAt ([datetime]::Parse("2026-04-22T08:25:00Z").ToUniversalTime()) | Out-Null

    return $dispatchFlow
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
    Set-Content -LiteralPath $evidenceRefPath -Value ("evidence ref for {0}" -f $TaskId) -Encoding UTF8

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
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-006-evidence-main-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-ExecutionEvidenceHarness -Root $tempRoot
        $completedDispatch = New-CompletedDispatch -Harness $harness -TaskId "task-r6-pilot-004" -DispatchId "dispatch-r6-006-valid-001" -LedgerId "run-ledger-r6-006-valid-001"
        $evidenceInputs = New-ExecutionEvidenceInputs -Harness $harness -TaskId "task-r6-pilot-004"
        $evidenceFlow = & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot -EvidenceBundleId "execution-evidence-r6-006-valid-001" -Notes "Assemble one governed execution evidence bundle from one completed dispatch and one completed run ledger only."
        $bundleCheck = & $testMilestoneAutocycleExecutionEvidenceContract -EvidenceBundlePath $evidenceFlow.EvidenceBundlePath
        $bundle = Get-JsonDocument -Path $evidenceFlow.EvidenceBundlePath

        if ($bundleCheck.DispatchId -ne "dispatch-r6-006-valid-001") {
            $failures += "FAIL valid execution evidence flow: validator did not return the expected dispatch id."
        }
        if ($bundle.run_ledger_id -ne "run-ledger-r6-006-valid-001") {
            $failures += "FAIL valid execution evidence flow: run_ledger_id did not persist."
        }
        if ($bundle.task_id -ne "task-r6-pilot-004") {
            $failures += "FAIL valid execution evidence flow: task id did not persist."
        }
        if ($bundle.baseline_id -ne "baseline-r6-006-valid-001") {
            $failures += "FAIL valid execution evidence flow: baseline id did not persist."
        }
        if (@($bundle.changed_files).Count -ne 1 -or @($bundle.produced_artifacts).Count -ne 1 -or @($bundle.test_outputs).Count -ne 1 -or @($bundle.evidence_refs).Count -ne 1) {
            $failures += "FAIL valid execution evidence flow: evidence categories did not persist one durable item each."
        }

        Write-Output ("PASS valid governed execution evidence flow: {0}" -f $bundleCheck.EvidenceBundleId)
        $validPassed += 1

        Invoke-ExpectedRefusal -Label "missing dispatch refusal" -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath (Join-Path $harness.Root "state\autocycle\dispatch\dispatches\missing-dispatch.json") -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing ledger refusal" -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath (Join-Path $harness.Root "state\autocycle\dispatch\run_ledgers\missing-ledger.json") -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        $secondCompletedDispatch = New-CompletedDispatch -Harness $harness -TaskId "task-r6-pilot-005" -DispatchId "dispatch-r6-006-mismatch-002" -LedgerId "run-ledger-r6-006-mismatch-002"
        Invoke-ExpectedRefusalWithMessage -Label "dispatch or ledger mismatch refusal" -RequiredFragments @(
            "dispatch and run ledger"
        ) -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $secondCompletedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        $ledger = Get-JsonDocument -Path $secondCompletedDispatch.RunLedgerPath
        $ledger.status = "failed"
        $ledger.result_summary = "Executor failed after completion was previously recorded."
        $ledger.notes = "Tampered ledger state to prove evidence assembly refuses non-completed ledgers."
        Write-JsonDocument -Path $secondCompletedDispatch.RunLedgerPath -Document $ledger
        $ledgerEvidenceInputs = New-ExecutionEvidenceInputs -Harness $harness -TaskId "task-r6-pilot-005"

        Invoke-ExpectedRefusalWithMessage -Label "non-completed ledger refusal" -RequiredFragments @(
            "run ledger status",
            "'completed'"
        ) -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $secondCompletedDispatch.DispatchPath -LedgerPath $secondCompletedDispatch.RunLedgerPath -ChangedFiles $ledgerEvidenceInputs.ChangedFiles -ProducedArtifacts $ledgerEvidenceInputs.ProducedArtifacts -TestOutputs $ledgerEvidenceInputs.TestOutputs -EvidenceRefs $ledgerEvidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing changed-files evidence refusal" -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles @() -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing produced-artifacts evidence refusal" -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts @() -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        Invoke-ExpectedRefusal -Label "missing test-output evidence refusal" -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs @() -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }

        $malformedBundleFlow = & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $completedDispatch.DispatchPath -LedgerPath $completedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot -EvidenceBundleId "execution-evidence-r6-006-malformed-contract-001" -Notes "Assemble one governed execution evidence bundle from one completed dispatch and one completed run ledger only."
        $bundle = Get-JsonDocument -Path $malformedBundleFlow.EvidenceBundlePath
        $bundle.evidence_refs = "not-an-array"
        Write-JsonDocument -Path $malformedBundleFlow.EvidenceBundlePath -Document $bundle

        Invoke-ExpectedRefusal -Label "malformed bundle contract refusal" -Action {
            & $testMilestoneAutocycleExecutionEvidenceContract -EvidenceBundlePath $malformedBundleFlow.EvidenceBundlePath | Out-Null
        }

        $taskId = "task-r6-pilot-004"
        $notStartedDispatch = & $invokeMilestoneAutocycleDispatchFlow -BindingPath $harness.BindingPath -TaskId $taskId -AllowedScope (New-AllowedScope -ScopeSummary $harness.TasksById[$taskId].scope_summary) -TargetBranch $harness.Branch -ExpectedOutputs (New-ExpectedOutputs) -RefusalConditions (New-RefusalConditions) -OutputRoot $harness.DispatchOutputRoot -DispatchId "dispatch-r6-006-dispatch-state-001" -LedgerId "run-ledger-r6-006-dispatch-state-001" -Notes "Create one governed Codex dispatch before bounded evidence assembly." -LedgerNotes "Initialize the governed run ledger before recording execution evidence."

        Invoke-ExpectedRefusalWithMessage -Label "non-completed dispatch refusal" -RequiredFragments @(
            "dispatch status",
            "'completed'"
        ) -Action {
            & $invokeMilestoneAutocycleExecutionEvidenceFlow -DispatchPath $notStartedDispatch.DispatchPath -LedgerPath $notStartedDispatch.RunLedgerPath -ChangedFiles $evidenceInputs.ChangedFiles -ProducedArtifacts $evidenceInputs.ProducedArtifacts -TestOutputs $evidenceInputs.TestOutputs -EvidenceRefs $evidenceInputs.EvidenceRefs -OutputRoot $harness.EvidenceOutputRoot | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL main execution evidence harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle execution evidence tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle execution evidence tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
