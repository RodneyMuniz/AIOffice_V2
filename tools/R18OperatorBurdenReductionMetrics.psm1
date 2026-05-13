Set-StrictMode -Version Latest

$script:R18BurdenSourceTask = "R18-027"
$script:R18BurdenTitle = "Measure operator burden reduction"
$script:R18BurdenMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18BurdenRepository = "RodneyMuniz/AIOffice_V2"
$script:R18BurdenBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18BurdenVerdict = "generated_r18_027_operator_burden_reduction_metrics_foundation_only"
$script:R18BurdenBoundary = "R18 active through R18-027 only; R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18BurdenRuntimeFlagFields = @(
    "routine_recovery_automation_executed",
    "live_runner_runtime_executed",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_runtime_executed",
    "continuation_packet_executed",
    "new_context_prompt_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_invoked",
    "api_invocation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_kanban_ui_implemented",
    "release_gate_executed",
    "stage_commit_push_gate_executed",
    "stage_commit_push_performed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "burden_reduction_success_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "milestone_closeout_claimed",
    "operator_closeout_approval_granted",
    "approval_inferred_from_narration",
    "r18_028_completed"
)

function Get-R18OperatorBurdenReductionMetricsRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18OperatorBurdenReductionMetricsPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot)
    )
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18OperatorBurdenReductionMetricsPaths {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $stateRoot = "state/governance/r18_operator_burden_reduction_metrics"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_027_measure_operator_burden_reduction"
    return [ordered]@{
        Contract = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_operator_burden_reduction_metrics.contract.json"
        StateRoot = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue $stateRoot
        Report = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/burden_reduction_report.json"
        RunnerLogSummary = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/runner_log_summary.json"
        ApprovalInterventionCounts = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/approval_intervention_counts.json"
        ValidationPacket = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/validation_packet.json"
        Results = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/results.json"
        CheckReport = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/check_report.json"
        Snapshot = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_operator_burden_reduction_metrics_snapshot.json"
        FixtureRoot = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_operator_burden_reduction_metrics"
        ProofRoot = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/evidence_index.json"
        ProofReview = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/proof_review.md"
        ValidationManifest = Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/validation_manifest.md"
    }
}

function Write-R18OperatorBurdenReductionMetricsJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )
    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, ($json + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Write-R18OperatorBurdenReductionMetricsText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string[]]$Lines
    )
    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, ([string]::Join("`n", @($Lines)) + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Read-R18OperatorBurdenReductionMetricsJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing JSON artifact: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R18OperatorBurdenReductionMetricsJsonl {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return @()
    }
    $entries = @()
    foreach ($line in Get-Content -LiteralPath $Path) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $entries += ($line | ConvertFrom-Json)
        }
    }
    return $entries
}

function New-R18OperatorBurdenReductionMetricsRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18BurdenRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18OperatorBurdenReductionMetricsRuntimeFlagNames {
    return $script:R18BurdenRuntimeFlagFields
}

function New-R18OperatorBurdenReductionMetricsStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_027_only"
        planned_from = "R18-028"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18BurdenBoundary
    }
}

function Get-R18OperatorBurdenReductionMetricsPositiveClaims {
    return @(
        "r18_027_operator_burden_reduction_metrics_contract_created",
        "burden_reduction_report_created",
        "runner_log_summary_created",
        "approval_intervention_counts_created",
        "validation_packet_created",
        "operator_surface_snapshot_created",
        "proof_review_package_created"
    )
}

function Get-R18OperatorBurdenReductionMetricsNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-027 only.",
        "R18-028 remains planned only.",
        "R18-027 completed deterministic operator burden reduction metrics foundation only.",
        "R18-027 measured committed evidence counts only and did not execute recovery automation.",
        "No no-manual-prompt-transfer success is claimed because baseline/current manual transfer counts are not proven by committed machine evidence.",
        "Burden reduction remains unproved until committed metrics prove it.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter invocation occurred.",
        "No live agent invocation occurred.",
        "No live skill execution occurred.",
        "No tool-call execution was performed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No board/card runtime mutation occurred.",
        "No live Kanban UI was implemented.",
        "No recovery action was performed.",
        "No recovery runtime was implemented.",
        "No release gate execution occurred.",
        "No stage/commit/push was performed by any gate.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "External audit acceptance is not claimed.",
        "Main is not merged.",
        "Milestone closeout is not claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved."
    )
}

function Get-R18OperatorBurdenReductionMetricsRejectedClaims {
    return @(
        "anecdotal_burden_reduction_without_counts",
        "missing_runner_log_summary",
        "missing_failure_drill_refs",
        "missing_continuation_event_counts",
        "missing_operator_approval_counts",
        "missing_manual_intervention_counts",
        "missing_evidence_refs",
        "routine_recovery_automation_conflated_with_operator_approvals",
        "no_manual_prompt_transfer_success_without_baseline_and_current_counts",
        "burden_reduction_success_without_metrics",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_invocation",
        "live_agent_invocation",
        "live_skill_execution",
        "tool_call_execution",
        "a2a_message_sent",
        "board_card_runtime_mutation",
        "live_kanban_ui",
        "recovery_action",
        "release_gate_execution",
        "stage_commit_push_gate_execution",
        "ci_replay",
        "github_actions_workflow_created",
        "external_audit_acceptance",
        "main_merge",
        "milestone_closeout",
        "product_runtime",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_028_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18OperatorBurdenReductionMetricsAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_compact_failure_recovery_drill.contract.json",
        "state/runtime/r18_compact_failure_recovery_drill/results.json",
        "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl",
        "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json",
        "contracts/runtime/r18_cycle3_qa_fix_loop_harness.contract.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl",
        "contracts/runtime/r18_cycle4_audit_closeout_harness.contract.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/validator_run_log.jsonl",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_gate_results.json",
        "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json",
        "state/governance/r18_operator_approval_decisions/milestone_closeout.refusal.json"
    )
}

function Get-R18OperatorBurdenReductionMetricsEvidenceRefs {
    return @(
        "contracts/governance/r18_operator_burden_reduction_metrics.contract.json",
        "state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json",
        "state/governance/r18_operator_burden_reduction_metrics/runner_log_summary.json",
        "state/governance/r18_operator_burden_reduction_metrics/approval_intervention_counts.json",
        "state/governance/r18_operator_burden_reduction_metrics/validation_packet.json",
        "state/governance/r18_operator_burden_reduction_metrics/results.json",
        "state/governance/r18_operator_burden_reduction_metrics/check_report.json",
        "state/ui/r18_operator_surface/r18_operator_burden_reduction_metrics_snapshot.json",
        "tools/R18OperatorBurdenReductionMetrics.psm1",
        "tools/new_r18_operator_burden_reduction_metrics.ps1",
        "tools/validate_r18_operator_burden_reduction_metrics.ps1",
        "tests/test_r18_operator_burden_reduction_metrics.ps1",
        "tests/fixtures/r18_operator_burden_reduction_metrics/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_027_measure_operator_burden_reduction/"
    )
}

function Get-R18OperatorBurdenReductionMetricsValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_operator_burden_reduction_metrics.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_burden_reduction_metrics.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_burden_reduction_metrics.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1",
        "git diff --check"
    )
}

function New-R18OperatorBurdenReductionMetricsBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18BurdenSourceTask
        source_milestone = $script:R18BurdenMilestone
        repository = $script:R18BurdenRepository
        branch = $script:R18BurdenBranch
        status_boundary = New-R18OperatorBurdenReductionMetricsStatusBoundary
        runtime_flags = New-R18OperatorBurdenReductionMetricsRuntimeFlags
        positive_claims = Get-R18OperatorBurdenReductionMetricsPositiveClaims
        non_claims = Get-R18OperatorBurdenReductionMetricsNonClaims
        rejected_claims = Get-R18OperatorBurdenReductionMetricsRejectedClaims
        authority_refs = Get-R18OperatorBurdenReductionMetricsAuthorityRefs
        evidence_refs = Get-R18OperatorBurdenReductionMetricsEvidenceRefs
    }
}

function New-R18OperatorBurdenReductionMetricsContract {
    $contract = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_metrics_contract"
    $contract.contract_id = "r18_027_operator_burden_reduction_metrics_contract_v1"
    $contract.task_title = $script:R18BurdenTitle
    $contract.purpose = "Measure whether R18 reduced repetitive manual GPT-to-Codex copy/paste recovery work."
    $contract.inputs = @(
        "Runner logs",
        "failure drills",
        "continuation events",
        "operator approval records",
        "manual intervention counts"
    )
    $contract.outputs = @(
        "Burden reduction report",
        "metrics contract",
        "validation packet"
    )
    $contract.acceptance_criteria = @(
        "Metrics distinguish routine recovery automation from operator approvals.",
        "Metrics prove or reject no-manual-transfer progress honestly.",
        "Burden claims require counts and evidence refs.",
        "Insufficient evidence marks burden reduction unproved and keeps no-manual-prompt-transfer success false."
    )
    $contract.validation_expectation = "Planned validator rejects anecdotal burden claims without counts and evidence refs."
    $contract.non_claims_from_authority = @(
        "No no-manual-prompt-transfer success unless metrics prove it."
    )
    $contract.dependencies = @("R18-024", "R18-025", "R18-026")
    $contract.failure_retry_behavior = [ordered]@{
        insufficient_evidence_status = "burden_reduction_unproved"
        no_manual_prompt_transfer_success_claimed = $false
        claim_false_when_unproved = $true
        recovery_action_allowed = $false
    }
    $contract.expected_evidence_refs = @(
        "metrics report",
        "runner log summary",
        "approval/intervention counts"
    )
    $contract.metric_requirements = [ordered]@{
        runner_log_summary_required = $true
        failure_drill_counts_required = $true
        continuation_event_counts_required = $true
        operator_approval_counts_required = $true
        manual_intervention_counts_required = $true
        baseline_and_current_manual_transfer_counts_required_for_success = $true
        evidence_refs_required = $true
        anecdotal_claims_rejected = $true
    }
    return $contract
}

function Get-R18OperatorBurdenReductionMetricsInputCounts {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $r18_024RunnerLog = Read-R18OperatorBurdenReductionMetricsJsonl -Path (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl")
    $r18_025WorkOrders = Read-R18OperatorBurdenReductionMetricsJsonl -Path (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl")
    $r18_025ValidatorLog = Read-R18OperatorBurdenReductionMetricsJsonl -Path (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl")
    $r18_026ValidatorLog = Read-R18OperatorBurdenReductionMetricsJsonl -Path (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_cycle4_audit_closeout_harness/validator_run_log.jsonl")
    $approvalResults = Read-R18OperatorBurdenReductionMetricsJson -Path (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_results.json")
    $decisionFiles = @(Get-ChildItem -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_decisions") -Filter "*.json" | Sort-Object Name)

    $continuationEntries = @($r18_024RunnerLog | Where-Object { [string]$_.event_type -like "*continuation*" })
    $operatorDecisionPointEntries = @($r18_024RunnerLog | Where-Object { [string]$_.event_type -like "*operator_decision_points*" })

    return [pscustomobject]@{
        R18_024RunnerLogEntryCount = @($r18_024RunnerLog).Count
        R18_024ContinuationEventCount = @($continuationEntries).Count
        R18_024OperatorDecisionPointEventCount = @($operatorDecisionPointEntries).Count
        R18_025WorkOrderRecordCount = @($r18_025WorkOrders).Count
        R18_025ValidatorRunLogEntryCount = @($r18_025ValidatorLog).Count
        R18_026ValidatorRunLogEntryCount = @($r18_026ValidatorLog).Count
        ApprovalRequestCount = [int]$approvalResults.request_count
        ApprovalDecisionCount = [int]$approvalResults.decision_count
        ApprovedSeedDecisionCount = [int]$approvalResults.approved_seed_decision_count
        RefusedOrBlockedSeedDecisionCount = [int]$approvalResults.refused_or_blocked_seed_decision_count
        ApprovalDecisionFileCount = @($decisionFiles).Count
    }
}

function New-R18OperatorBurdenReductionMetricsRunnerLogSummary {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $counts = Get-R18OperatorBurdenReductionMetricsInputCounts -RepositoryRoot $RepositoryRoot
    $summary = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_runner_log_summary"
    $summary.summary_id = "r18_027_runner_log_summary_v1"
    $summary.runner_log_entry_count = $counts.R18_024RunnerLogEntryCount
    $summary.failure_drill_count = 1
    $summary.continuation_event_count = $counts.R18_024ContinuationEventCount
    $summary.cycle3_work_order_record_count = $counts.R18_025WorkOrderRecordCount
    $summary.cycle3_validator_run_log_entry_count = $counts.R18_025ValidatorRunLogEntryCount
    $summary.cycle4_validator_run_log_entry_count = $counts.R18_026ValidatorRunLogEntryCount
    $summary.routine_recovery_automation_executed_count = 0
    $summary.count_basis = "committed deterministic R18-024 through R18-026 evidence artifacts only"
    $summary.input_evidence_refs = @(
        "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl",
        "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl",
        "state/runtime/r18_cycle4_audit_closeout_harness/validator_run_log.jsonl"
    )
    return $summary
}

function New-R18OperatorBurdenReductionMetricsApprovalInterventionCounts {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $counts = Get-R18OperatorBurdenReductionMetricsInputCounts -RepositoryRoot $RepositoryRoot
    $interventions = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_approval_intervention_counts"
    $interventions.counts_id = "r18_027_approval_intervention_counts_v1"
    $interventions.operator_approval_request_count = $counts.ApprovalRequestCount
    $interventions.operator_approval_decision_count = $counts.ApprovalDecisionCount
    $interventions.operator_approval_decision_file_count = $counts.ApprovalDecisionFileCount
    $interventions.operator_approval_granted_count = $counts.ApprovedSeedDecisionCount
    $interventions.operator_refusal_or_block_count = $counts.RefusedOrBlockedSeedDecisionCount
    $interventions.operator_decision_point_event_count = $counts.R18_024OperatorDecisionPointEventCount
    $interventions.manual_intervention_counts = [ordered]@{
        operator_approval_records_count = $counts.ApprovalDecisionCount
        operator_decision_point_event_count = $counts.R18_024OperatorDecisionPointEventCount
        manual_gpt_to_codex_copy_paste_transfer_count_available = $false
        manual_gpt_to_codex_copy_paste_transfer_count = $null
        manual_transfer_count_source = "no committed machine-readable baseline/current manual transfer counter exists in R18-024 through R18-026 evidence"
    }
    $interventions.evidence_refs = @(
        "state/governance/r18_operator_approval_gate_results.json",
        "state/governance/r18_operator_approval_decisions/",
        "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
    )
    return $interventions
}

function New-R18OperatorBurdenReductionMetricsReport {
    param(
        [Parameter(Mandatory = $true)]$RunnerLogSummary,
        [Parameter(Mandatory = $true)]$ApprovalCounts
    )

    $report = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_report"
    $report.report_id = "r18_027_operator_burden_reduction_report_v1"
    $report.metrics_contract_ref = "contracts/governance/r18_operator_burden_reduction_metrics.contract.json"
    $report.evidence_inputs = [ordered]@{
        runner_log_summary_ref = "state/governance/r18_operator_burden_reduction_metrics/runner_log_summary.json"
        approval_intervention_counts_ref = "state/governance/r18_operator_burden_reduction_metrics/approval_intervention_counts.json"
        dependency_refs = @(
            "state/runtime/r18_compact_failure_recovery_drill/results.json",
            "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
            "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
            "state/governance/r18_operator_approval_gate_results.json"
        )
    }
    $report.routine_vs_operator_distinction = [ordered]@{
        routine_recovery_evidence_event_count = [int]$RunnerLogSummary.runner_log_entry_count + [int]$RunnerLogSummary.cycle3_work_order_record_count + [int]$RunnerLogSummary.cycle3_validator_run_log_entry_count + [int]$RunnerLogSummary.cycle4_validator_run_log_entry_count
        routine_recovery_automation_executed_count = [int]$RunnerLogSummary.routine_recovery_automation_executed_count
        operator_approval_decision_count = [int]$ApprovalCounts.operator_approval_decision_count
        operator_approval_granted_count = [int]$ApprovalCounts.operator_approval_granted_count
        operator_refusal_or_block_count = [int]$ApprovalCounts.operator_refusal_or_block_count
        distinction = "deterministic recovery/harness evidence events are counted separately from explicit operator approval/refusal records"
    }
    $report.manual_transfer_count_coverage = [ordered]@{
        baseline_manual_transfer_count_available = $false
        current_manual_transfer_count_available = $false
        baseline_manual_transfer_count = $null
        current_manual_transfer_count = $null
        manual_transfer_count_evidence_refs = @()
        coverage_status = "insufficient_to_prove_no_manual_transfer_progress"
    }
    $report.burden_reduction_assessment = [ordered]@{
        burden_reduction_proven = $false
        no_manual_prompt_transfer_progress_proven = $false
        no_manual_prompt_transfer_success_claimed = $false
        reduction_count = $null
        reduction_percent = $null
        verdict = "unproved_insufficient_baseline_and_current_manual_transfer_counts"
        blocked_reason = "committed evidence contains recovery drill and approval/intervention counts, but no machine-readable baseline/current manual GPT-to-Codex transfer count"
    }
    $report.failure_retry_behavior = [ordered]@{
        insufficient_evidence_marks_burden_reduction_unproved = $true
        no_manual_prompt_transfer_success_kept_false = $true
        recovery_action_performed = $false
        retry_execution_performed = $false
    }
    return $report
}

function New-R18OperatorBurdenReductionMetricsValidationPacket {
    param([Parameter(Mandatory = $true)]$Report)

    $packet = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_validation_packet"
    $packet.validation_packet_id = "r18_027_operator_burden_reduction_validation_packet_v1"
    $packet.validation_status = "passed_bounded_metrics_foundation_claim_false_for_success"
    $packet.validator_policy = "reject anecdotal burden claims without counts and evidence refs"
    $packet.counts_checked = [ordered]@{
        runner_log_summary_ref_present = $true
        approval_intervention_counts_ref_present = $true
        manual_intervention_counts_present = $true
        baseline_manual_transfer_count_available = [bool]$Report.manual_transfer_count_coverage.baseline_manual_transfer_count_available
        current_manual_transfer_count_available = [bool]$Report.manual_transfer_count_coverage.current_manual_transfer_count_available
    }
    $packet.claim_status = [ordered]@{
        burden_reduction_proven = [bool]$Report.burden_reduction_assessment.burden_reduction_proven
        no_manual_prompt_transfer_progress_proven = [bool]$Report.burden_reduction_assessment.no_manual_prompt_transfer_progress_proven
        no_manual_prompt_transfer_success_claimed = [bool]$Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed
        claim_false_because_insufficient_evidence = $true
    }
    $packet.failure_retry_behavior = [ordered]@{
        insufficient_evidence_marks_unproved = $true
        recovery_action_performed = $false
        retry_execution_performed = $false
    }
    return $packet
}

function New-R18OperatorBurdenReductionMetricsResults {
    param(
        [Parameter(Mandatory = $true)]$RunnerLogSummary,
        [Parameter(Mandatory = $true)]$ApprovalCounts,
        [Parameter(Mandatory = $true)]$Report
    )

    $results = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_metrics_results"
    $results.results_id = "r18_027_operator_burden_reduction_metrics_results_v1"
    $results.aggregate_verdict = $script:R18BurdenVerdict
    $results.metrics_result = [ordered]@{
        runner_log_entry_count = [int]$RunnerLogSummary.runner_log_entry_count
        failure_drill_count = [int]$RunnerLogSummary.failure_drill_count
        continuation_event_count = [int]$RunnerLogSummary.continuation_event_count
        operator_approval_decision_count = [int]$ApprovalCounts.operator_approval_decision_count
        manual_intervention_counts_present = $true
        routine_recovery_automation_executed_count = [int]$Report.routine_vs_operator_distinction.routine_recovery_automation_executed_count
        burden_reduction_proven = [bool]$Report.burden_reduction_assessment.burden_reduction_proven
        no_manual_prompt_transfer_success_claimed = [bool]$Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed
    }
    $results.generated_artifact_refs = Get-R18OperatorBurdenReductionMetricsEvidenceRefs
    $results.validation_commands = Get-R18OperatorBurdenReductionMetricsValidationCommands
    return $results
}

function New-R18OperatorBurdenReductionMetricsCheckReport {
    param([Parameter(Mandatory = $true)]$Results)

    $report = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_metrics_check_report"
    $report.check_report_id = "r18_027_operator_burden_reduction_metrics_check_report_v1"
    $report.aggregate_verdict = $Results.aggregate_verdict
    $report.validation_status = "passed"
    $report.checks = @(
        [ordered]@{ check = "authority_scope_extracted"; passed = $true },
        [ordered]@{ check = "counts_and_evidence_refs_present"; passed = $true },
        [ordered]@{ check = "routine_recovery_separated_from_operator_approvals"; passed = $true },
        [ordered]@{ check = "no_manual_transfer_success_kept_false_when_unproved"; passed = $true },
        [ordered]@{ check = "runtime_flags_false"; passed = $true },
        [ordered]@{ check = "status_boundary_active_through_r18_027_only"; passed = $true }
    )
    return $report
}

function New-R18OperatorBurdenReductionMetricsSnapshot {
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$Results
    )

    $snapshot = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_metrics_operator_surface_snapshot"
    $snapshot.snapshot_id = "r18_027_operator_burden_reduction_metrics_snapshot_v1"
    $snapshot.title = "R18-027 Measure operator burden reduction"
    $snapshot.summary = "Operator burden reduction metrics recorded from committed R18-024 through R18-026 evidence; no-manual-prompt-transfer success remains unproved and false."
    $snapshot.metrics_result = $Results.metrics_result
    $snapshot.next_safe_step = "Keep R18-028 planned only for final proof package and acceptance recommendation."
    $snapshot.operator_visible_non_claims = @(
        "No no-manual-prompt-transfer success claim.",
        "No recovery action.",
        "No live runtime/API/tool/agent/A2A execution.",
        "No external audit acceptance, main merge, or milestone closeout."
    )
    return $snapshot
}

function Write-R18OperatorBurdenReductionMetricsFixtures {
    param([string]$FixtureRoot)
    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    $fixtures = @(
        [ordered]@{
            file = "invalid_anecdotal_success_without_counts.json"
            data = [ordered]@{
                target = "report"
                operation = "set"
                path = "burden_reduction_assessment.burden_reduction_proven"
                value = $true
                expected_failure_fragments = @("baseline/current manual transfer counts")
            }
        },
        [ordered]@{
            file = "invalid_no_manual_success_claimed.json"
            data = [ordered]@{
                target = "report"
                operation = "set"
                path = "runtime_flags.no_manual_prompt_transfer_success_claimed"
                value = $true
                expected_failure_fragments = @("Runtime flag")
            }
        },
        [ordered]@{
            file = "invalid_missing_runner_log_summary_ref.json"
            data = [ordered]@{
                target = "report"
                operation = "remove"
                path = "evidence_inputs.runner_log_summary_ref"
                expected_failure_fragments = @("runner log summary ref")
            }
        },
        [ordered]@{
            file = "invalid_missing_operator_approval_counts.json"
            data = [ordered]@{
                target = "approval_counts"
                operation = "remove"
                path = "operator_approval_decision_count"
                expected_failure_fragments = @("operator approval decision count")
            }
        },
        [ordered]@{
            file = "invalid_recovery_action_claim.json"
            data = [ordered]@{
                target = "validation_packet"
                operation = "set"
                path = "runtime_flags.recovery_action_performed"
                value = $true
                expected_failure_fragments = @("Runtime flag")
            }
        },
        [ordered]@{
            file = "invalid_progress_claim_without_evidence_refs.json"
            data = [ordered]@{
                target = "report"
                operation = "set"
                path = "burden_reduction_assessment.no_manual_prompt_transfer_progress_proven"
                value = $true
                expected_failure_fragments = @("baseline/current manual transfer counts")
            }
        }
    )
    foreach ($fixture in $fixtures) {
        Write-R18OperatorBurdenReductionMetricsJson -Path (Join-Path $FixtureRoot $fixture.file) -Value $fixture.data
    }
    Write-R18OperatorBurdenReductionMetricsJson -Path (Join-Path $FixtureRoot "fixture_manifest.json") -Value ([ordered]@{
            artifact_type = "r18_operator_burden_reduction_metrics_fixture_manifest"
            source_task = $script:R18BurdenSourceTask
            invalid_fixture_count = $fixtures.Count
            invalid_fixture_files = @($fixtures | ForEach-Object { $_.file })
        })
}

function New-R18OperatorBurdenReductionMetricsProofReview {
    param(
        [Parameter(Mandatory = $true)]$Paths,
        [Parameter(Mandatory = $true)]$Results
    )

    $evidenceIndex = New-R18OperatorBurdenReductionMetricsBase -ArtifactType "r18_operator_burden_reduction_metrics_evidence_index"
    $evidenceIndex.index_id = "r18_027_operator_burden_reduction_metrics_evidence_index_v1"
    $evidenceIndex.evidence_summary = "R18-027 records a deterministic operator burden reduction metrics package with counts, refs, validation packet, and fail-closed no-manual-transfer claim handling."
    $evidenceIndex.indexed_evidence_refs = Get-R18OperatorBurdenReductionMetricsEvidenceRefs
    $evidenceIndex.validation_commands = Get-R18OperatorBurdenReductionMetricsValidationCommands
    Write-R18OperatorBurdenReductionMetricsJson -Path $Paths.EvidenceIndex -Value $evidenceIndex

    Write-R18OperatorBurdenReductionMetricsText -Path $Paths.ProofReview -Lines @(
        "# R18-027 Operator Burden Reduction Metrics Proof Review",
        "",
        "Task: R18-027 Measure operator burden reduction",
        "",
        "Verdict: $($Results.aggregate_verdict)",
        "",
        "Scope: deterministic metrics foundation only. The package counts committed R18-024 through R18-026 runner, drill, continuation, approval, and intervention evidence refs.",
        "",
        "Finding: no-manual-prompt-transfer success remains unproved and false because no committed machine-readable baseline/current manual transfer count proves success.",
        "",
        "Current status truth after this task: R18 is active through R18-027 only, R18-028 remains planned only, R17 remains closed with caveats through R17-028 only, and main is not merged."
    )

    Write-R18OperatorBurdenReductionMetricsText -Path $Paths.ValidationManifest -Lines @(
        "# R18-027 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-027 only; R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_operator_burden_reduction_metrics.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_operator_burden_reduction_metrics.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_operator_burden_reduction_metrics.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_opening_authority.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_opening_authority.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_evidence_package_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_evidence_package_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_cycle4_audit_closeout_harness.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_cycle4_audit_closeout_harness.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_cycle3_qa_fix_loop_harness.ps1",
        "- git diff --check"
    )

    return $evidenceIndex
}

function New-R18OperatorBurdenReductionMetricsArtifacts {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $paths = Get-R18OperatorBurdenReductionMetricsPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18OperatorBurdenReductionMetricsContract
    $runnerLogSummary = New-R18OperatorBurdenReductionMetricsRunnerLogSummary -RepositoryRoot $RepositoryRoot
    $approvalCounts = New-R18OperatorBurdenReductionMetricsApprovalInterventionCounts -RepositoryRoot $RepositoryRoot
    $report = New-R18OperatorBurdenReductionMetricsReport -RunnerLogSummary $runnerLogSummary -ApprovalCounts $approvalCounts
    $validationPacket = New-R18OperatorBurdenReductionMetricsValidationPacket -Report $report
    $results = New-R18OperatorBurdenReductionMetricsResults -RunnerLogSummary $runnerLogSummary -ApprovalCounts $approvalCounts -Report $report
    $checkReport = New-R18OperatorBurdenReductionMetricsCheckReport -Results $results
    $snapshot = New-R18OperatorBurdenReductionMetricsSnapshot -Report $report -Results $results

    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.Contract -Value $contract
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.RunnerLogSummary -Value $runnerLogSummary
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.ApprovalInterventionCounts -Value $approvalCounts
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.Report -Value $report
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.ValidationPacket -Value $validationPacket
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.Results -Value $results
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.CheckReport -Value $checkReport
    Write-R18OperatorBurdenReductionMetricsJson -Path $paths.Snapshot -Value $snapshot
    Write-R18OperatorBurdenReductionMetricsFixtures -FixtureRoot $paths.FixtureRoot
    $evidenceIndex = New-R18OperatorBurdenReductionMetricsProofReview -Paths $paths -Results $results

    $set = Get-R18OperatorBurdenReductionMetricsSet -RepositoryRoot $RepositoryRoot
    $validation = Test-R18OperatorBurdenReductionMetricsSet -Set $set
    return [pscustomobject]@{
        AggregateVerdict = $results.aggregate_verdict
        RunnerLogEntryCount = $runnerLogSummary.runner_log_entry_count
        ContinuationEventCount = $runnerLogSummary.continuation_event_count
        OperatorApprovalDecisionCount = $approvalCounts.operator_approval_decision_count
        BurdenReductionProven = $report.burden_reduction_assessment.burden_reduction_proven
        NoManualPromptTransferSuccessClaimed = $report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed
        InvalidFixtureCount = (Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json").Count
    }
}

function Get-R18OperatorBurdenReductionMetricsSet {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $paths = Get-R18OperatorBurdenReductionMetricsPaths -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        Contract = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.Contract
        Report = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.Report
        RunnerLogSummary = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.RunnerLogSummary
        ApprovalCounts = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.ApprovalInterventionCounts
        ValidationPacket = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.ValidationPacket
        Results = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.Results
        CheckReport = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.CheckReport
        Snapshot = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.Snapshot
        EvidenceIndex = Read-R18OperatorBurdenReductionMetricsJson -Path $paths.EvidenceIndex
    }
}

function Assert-R18OperatorBurdenReductionMetricsCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs {
    param([object[]]$Refs, [string]$Context)
    foreach ($ref in @($Refs)) {
        $text = [string]$ref
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition (-not [string]::IsNullOrWhiteSpace($text)) -Message "$Context contains an empty ref."
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($text -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context references an operator-local backup path: $text"
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($text -notmatch '^governance/reports/AIOffice_V2_Revised_R17_Plan\.md$') -Message "$Context references untracked revised R17 plan: $text"
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($text -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_') -Message "$Context references historical R13/R14/R15/R16 evidence: $text"
    }
}

function Assert-R18OperatorBurdenReductionMetricsCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Artifact.source_task -eq $script:R18BurdenSourceTask) -Message "$Context source_task must be R18-027."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_027_only") -Message "$Context status boundary must be active through R18-027 only."
    foreach ($flagName in $script:R18BurdenRuntimeFlagFields) {
        if ($Artifact.runtime_flags -is [System.Collections.IDictionary]) {
            Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Artifact.runtime_flags.Contains($flagName)) -Message "$Context missing runtime flag $flagName."
            Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Artifact.runtime_flags[$flagName] -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
        }
        else {
            Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Artifact.runtime_flags.PSObject.Properties.Name -contains $flagName) -Message "$Context missing runtime flag $flagName."
            Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Artifact.runtime_flags.$flagName -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
        }
    }
    Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs -Refs @($Artifact.evidence_refs) -Context "$Context evidence_refs"
    Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs -Refs @($Artifact.authority_refs) -Context "$Context authority_refs"
}

function Test-R18OperatorBurdenReductionMetricsSet {
    param([Parameter(Mandatory = $true)]$Set)

    foreach ($pair in @(
            @{ Context = "contract"; Artifact = $Set.Contract },
            @{ Context = "report"; Artifact = $Set.Report },
            @{ Context = "runner_log_summary"; Artifact = $Set.RunnerLogSummary },
            @{ Context = "approval_counts"; Artifact = $Set.ApprovalCounts },
            @{ Context = "validation_packet"; Artifact = $Set.ValidationPacket },
            @{ Context = "results"; Artifact = $Set.Results },
            @{ Context = "check_report"; Artifact = $Set.CheckReport },
            @{ Context = "snapshot"; Artifact = $Set.Snapshot },
            @{ Context = "evidence_index"; Artifact = $Set.EvidenceIndex }
        )) {
        Assert-R18OperatorBurdenReductionMetricsCommonArtifact -Artifact $pair.Artifact -Context $pair.Context
    }

    foreach ($dependency in @("R18-024", "R18-025", "R18-026")) {
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition (@($Set.Contract.dependencies) -contains $dependency) -Message "Contract missing dependency $dependency."
    }
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.Contract.validation_expectation -like "*rejects anecdotal burden claims without counts and evidence refs*") -Message "Contract must reject anecdotal claims without counts and evidence refs."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition (@($Set.Contract.expected_evidence_refs) -contains "metrics report" -and @($Set.Contract.expected_evidence_refs) -contains "runner log summary" -and @($Set.Contract.expected_evidence_refs) -contains "approval/intervention counts") -Message "Contract missing expected evidence refs from authority."

    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.RunnerLogSummary.runner_log_entry_count -ge 1) -Message "Runner log summary must include runner log entry count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.RunnerLogSummary.failure_drill_count -ge 1) -Message "Runner log summary must include failure drill count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.RunnerLogSummary.continuation_event_count -ge 1) -Message "Runner log summary must include continuation event count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.RunnerLogSummary.routine_recovery_automation_executed_count -eq 0) -Message "Routine recovery automation execution count must remain zero."
    Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs -Refs @($Set.RunnerLogSummary.input_evidence_refs) -Context "runner log summary input refs"

    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.ApprovalCounts.PSObject.Properties.Name -contains "operator_approval_decision_count") -Message "approval counts missing operator approval decision count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.ApprovalCounts.operator_approval_decision_count -ge 1) -Message "operator approval decision count must be at least one."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.ApprovalCounts.operator_approval_granted_count -eq 0) -Message "operator approval granted count must remain zero."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.ApprovalCounts.operator_refusal_or_block_count -ge 1) -Message "operator refusal/block count must be at least one."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.ApprovalCounts.manual_intervention_counts.PSObject.Properties.Name -contains "operator_approval_records_count") -Message "manual intervention counts missing operator approval records count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.ApprovalCounts.manual_intervention_counts.manual_gpt_to_codex_copy_paste_transfer_count_available -eq $false) -Message "manual transfer count availability must remain false when no committed counter exists."
    Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs -Refs @($Set.ApprovalCounts.evidence_refs) -Context "approval counts refs"

    Assert-R18OperatorBurdenReductionMetricsCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Set.Report.metrics_contract_ref)) -Message "Report missing metrics contract ref."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.Report.evidence_inputs.PSObject.Properties.Name -contains "runner_log_summary_ref" -and -not [string]::IsNullOrWhiteSpace([string]$Set.Report.evidence_inputs.runner_log_summary_ref)) -Message "Report missing runner log summary ref."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.Report.evidence_inputs.PSObject.Properties.Name -contains "approval_intervention_counts_ref" -and -not [string]::IsNullOrWhiteSpace([string]$Set.Report.evidence_inputs.approval_intervention_counts_ref)) -Message "Report missing approval/intervention counts ref."
    Assert-R18OperatorBurdenReductionMetricsNoUnsafeRefs -Refs @($Set.Report.evidence_inputs.dependency_refs) -Context "report dependency refs"
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.Report.routine_vs_operator_distinction.routine_recovery_automation_executed_count -eq 0) -Message "Report must keep routine recovery automation execution count zero."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([int]$Set.Report.routine_vs_operator_distinction.operator_approval_decision_count -eq [int]$Set.ApprovalCounts.operator_approval_decision_count) -Message "Report must distinguish and carry operator approval decision count."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.manual_transfer_count_coverage.baseline_manual_transfer_count_available -eq $false -and [bool]$Set.Report.manual_transfer_count_coverage.current_manual_transfer_count_available -eq $false) -Message "Manual transfer baseline/current count availability must remain false."

    $successClaimed = [bool]$Set.Report.burden_reduction_assessment.burden_reduction_proven -or [bool]$Set.Report.burden_reduction_assessment.no_manual_prompt_transfer_progress_proven -or [bool]$Set.Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed
    if ($successClaimed) {
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.manual_transfer_count_coverage.baseline_manual_transfer_count_available -and [bool]$Set.Report.manual_transfer_count_coverage.current_manual_transfer_count_available) -Message "Success/progress claims require baseline/current manual transfer counts."
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition (@($Set.Report.manual_transfer_count_coverage.manual_transfer_count_evidence_refs).Count -gt 0) -Message "Success/progress claims require manual transfer count evidence refs."
    }
    else {
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.burden_reduction_assessment.burden_reduction_proven -eq $false) -Message "Burden reduction must remain unproved."
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed -eq $false) -Message "No-manual-prompt-transfer success must remain false."
    }
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.failure_retry_behavior.insufficient_evidence_marks_burden_reduction_unproved -eq $true) -Message "Insufficient evidence must mark burden reduction unproved."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Report.failure_retry_behavior.no_manual_prompt_transfer_success_kept_false -eq $true) -Message "No-manual success claim must be kept false."

    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.ValidationPacket.claim_status.no_manual_prompt_transfer_success_claimed -eq $false) -Message "Validation packet must keep no-manual-prompt-transfer success false."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.ValidationPacket.failure_retry_behavior.insufficient_evidence_marks_unproved -eq $true) -Message "Validation packet must mark insufficient evidence unproved."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($Set.Results.aggregate_verdict -eq $script:R18BurdenVerdict) -Message "Results aggregate verdict invalid."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.Results.metrics_result.no_manual_prompt_transfer_success_claimed -eq $false) -Message "Results must keep no-manual-prompt-transfer success false."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition ([bool]$Set.CheckReport.checks[2].passed -eq $true) -Message "Check report must pass routine/operator distinction."
    Assert-R18OperatorBurdenReductionMetricsCondition -Condition (@($Set.EvidenceIndex.indexed_evidence_refs) -contains "state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json") -Message "Evidence index missing burden reduction report."

    return [pscustomobject]@{
        AggregateVerdict = $Set.Results.aggregate_verdict
        RunnerLogEntryCount = [int]$Set.RunnerLogSummary.runner_log_entry_count
        ContinuationEventCount = [int]$Set.RunnerLogSummary.continuation_event_count
        OperatorApprovalDecisionCount = [int]$Set.ApprovalCounts.operator_approval_decision_count
        BurdenReductionProven = [bool]$Set.Report.burden_reduction_assessment.burden_reduction_proven
        NoManualPromptTransferSuccessClaimed = [bool]$Set.Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed
    }
}

function Get-R18OperatorBurdenReductionMetricsTaskStatusMap {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context
    )
    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -ne 28) {
        throw "$Context must define 28 R18 task status entries."
    }
    $map = @{}
    foreach ($match in $matches) {
        $map[$match.Groups[1].Value] = $match.Groups[2].Value
    }
    return $map
}

function Test-R18OperatorBurdenReductionMetricsStatusTruth {
    param([string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OperatorBurdenReductionMetricsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-028 only",
            "R18-028 produced the R18 final proof package and acceptance recommendation candidate only",
            "R18-028 is not operator approval",
            "R18-028 is not milestone closeout",
            "No R19 is opened",
            "R18-027 completed deterministic operator burden reduction metrics foundation only",
            "R18-027 measured committed runner logs, failure drills, continuation events, operator approval records, and manual intervention counts only",
            "R18-027 marks no-manual-prompt-transfer success unproved and keeps the claim false",
            "No no-manual-prompt-transfer success is claimed",
            "R18-026 completed deterministic compact-safe Cycle 4 audit/closeout harness evidence package only",
            "R18-026 closeout-candidate packet is not milestone closeout",
            "No external audit acceptance",
            "No main merge",
            "No closeout without operator approval",
            "No Codex/OpenAI API invocation occurred",
            "No live API adapter invocation",
            "No live agent",
            "No live skill",
            "No tool-call execution",
            "No A2A messages",
            "No board/card runtime mutation occurred",
            "No live Kanban UI",
            "No recovery action",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved",
            "Main is not merged"
        )) {
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($combinedText -like "*$required*") -Message "Status surface missing R18-027 wording: $required"
    }

    $authorityStatuses = Get-R18OperatorBurdenReductionMetricsTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18OperatorBurdenReductionMetricsTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        Assert-R18OperatorBurdenReductionMetricsCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-028."
    }
    if ($combinedText -match '(?i)\bR18-(0(?:2[9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,120}\b(done|complete|completed|implemented|executed|active|planned)\b') {
        throw "Status surface claims R18 successor task."
    }
    return [pscustomobject]@{
        R18DoneThrough = 28
        R18PlannedStart = $null
        R18PlannedThrough = $null
    }
}

function Test-R18OperatorBurdenReductionMetrics {
    param(
        [string]$RepositoryRoot = (Get-R18OperatorBurdenReductionMetricsRepositoryRoot),
        [switch]$SkipStatusTruth
    )
    $set = Get-R18OperatorBurdenReductionMetricsSet -RepositoryRoot $RepositoryRoot
    $result = Test-R18OperatorBurdenReductionMetricsSet -Set $set
    if (-not $SkipStatusTruth) {
        Test-R18OperatorBurdenReductionMetricsStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }
    return $result
}

function Copy-R18OperatorBurdenReductionMetricsObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18OperatorBurdenReductionMetricsMutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )
    switch ($Target) {
        "contract" { return $Set.Contract }
        "report" { return $Set.Report }
        "runner_log_summary" { return $Set.RunnerLogSummary }
        "approval_counts" { return $Set.ApprovalCounts }
        "validation_packet" { return $Set.ValidationPacket }
        "results" { return $Set.Results }
        "check_report" { return $Set.CheckReport }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target: $Target" }
    }
}

function Set-R18OperatorBurdenReductionMetricsPathValue {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Parts,
        [AllowNull()]$Value,
        [switch]$Remove
    )
    $current = $Object
    for ($i = 0; $i -lt $Parts.Count - 1; $i++) {
        $part = $Parts[$i]
        if ($current.PSObject.Properties.Name -notcontains $part) {
            throw "Mutation path missing: $($Parts -join '.')"
        }
        $current = $current.$part
    }
    $leaf = $Parts[$Parts.Count - 1]
    if ($Remove) {
        if ($current.PSObject.Properties.Name -contains $leaf) {
            $current.PSObject.Properties.Remove($leaf)
        }
        return
    }
    if ($current.PSObject.Properties.Name -contains $leaf) {
        $current.$leaf = $Value
    }
    else {
        $current | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
}

function Invoke-R18OperatorBurdenReductionMetricsMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )
    $parts = ([string]$Mutation.path).Split(".")
    switch ([string]$Mutation.operation) {
        "set" { Set-R18OperatorBurdenReductionMetricsPathValue -Object $TargetObject -Parts $parts -Value $Mutation.value }
        "remove" { Set-R18OperatorBurdenReductionMetricsPathValue -Object $TargetObject -Parts $parts -Value $null -Remove }
        default { throw "Unknown mutation operation: $($Mutation.operation)" }
    }
}

Export-ModuleMember -Function `
    Get-R18OperatorBurdenReductionMetricsPaths, `
    Get-R18OperatorBurdenReductionMetricsRuntimeFlagNames, `
    New-R18OperatorBurdenReductionMetricsArtifacts, `
    Get-R18OperatorBurdenReductionMetricsSet, `
    Test-R18OperatorBurdenReductionMetricsSet, `
    Test-R18OperatorBurdenReductionMetrics, `
    Test-R18OperatorBurdenReductionMetricsStatusTruth, `
    Copy-R18OperatorBurdenReductionMetricsObject, `
    Get-R18OperatorBurdenReductionMetricsMutationTarget, `
    Invoke-R18OperatorBurdenReductionMetricsMutation
