Set-StrictMode -Version Latest

$script:R18DrillSourceTask = "R18-024"
$script:R18DrillTitle = "Exercise compact-failure recovery drill with local runner"
$script:R18DrillSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18DrillRepository = "RodneyMuniz/AIOffice_V2"
$script:R18DrillBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18DrillVerdict = "generated_r18_024_compact_failure_recovery_drill_foundation_only"
$script:R18DrillBoundary = "R18 active through R18-024 only; R18-025 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
$script:R18DrillPreflightHead = "a9115fcab9b02cf082665799bd21ce746f7a47e8"
$script:R18DrillPreflightTree = "cb0919561706361760de556c72a52f6c544afd1c"
$script:R18DrillPreflightRemoteHead = "a9115fcab9b02cf082665799bd21ce746f7a47e8"

$script:R18DrillRuntimeFlagFields = @(
    "compact_failure_recovery_drill_runtime_executed",
    "local_runner_runtime_executed",
    "live_runner_runtime_executed",
    "work_order_execution_performed",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_kanban_ui_implemented",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_execution_performed",
    "continuation_packet_executed",
    "new_context_prompt_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_invoked",
    "api_invocation_performed",
    "release_gate_executed",
    "stage_commit_push_performed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_025_completed"
)

function Get-R18CompactFailureRecoveryDrillRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18CompactFailureRecoveryDrillPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18CompactFailureRecoveryDrillPaths {
    param([string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot))

    $stateRoot = "state/runtime/r18_compact_failure_recovery_drill"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_024_compact_failure_recovery_drill"
    return [ordered]@{
        Contract = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_compact_failure_recovery_drill.contract.json"
        StateRoot = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue $stateRoot
        DrillPacket = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/drill_packet.json"
        FailureEvent = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/failure_event.json"
        WipClassification = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/wip_classification.json"
        RemoteVerification = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/remote_verification.json"
        ContinuationPacket = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/continuation_packet.json"
        NewContextPacket = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/new_context_packet.json"
        RunnerLog = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/runner_log.jsonl"
        Results = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/results.json"
        CheckReport = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/check_report.json"
        Snapshot = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_compact_failure_recovery_drill_snapshot.json"
        FixtureRoot = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_compact_failure_recovery_drill"
        ProofRoot = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/evidence_index.json"
        ProofReview = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/proof_review.md"
        ValidationManifest = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/validation_manifest.md"
    }
}

function New-R18CompactFailureRecoveryDrillRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18DrillRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18CompactFailureRecoveryDrillRuntimeFlagNames {
    return $script:R18DrillRuntimeFlagFields
}

function Get-R18CompactFailureRecoveryDrillPositiveClaims {
    return @(
        "r18_compact_failure_recovery_drill_contract_created",
        "r18_compact_failure_recovery_drill_packet_created",
        "r18_compact_failure_recovery_drill_failure_event_created",
        "r18_compact_failure_recovery_drill_wip_classification_created",
        "r18_compact_failure_recovery_drill_remote_verification_created",
        "r18_compact_failure_recovery_drill_continuation_packet_created",
        "r18_compact_failure_recovery_drill_new_context_packet_created",
        "r18_compact_failure_recovery_drill_runner_log_created",
        "r18_compact_failure_recovery_drill_results_created",
        "r18_compact_failure_recovery_drill_validator_created",
        "r18_compact_failure_recovery_drill_fixtures_created",
        "r18_compact_failure_recovery_drill_proof_review_created"
    )
}

function Get-R18CompactFailureRecoveryDrillRejectedClaims {
    return @(
        "packet_only_recovery_without_runner_evidence",
        "missing_runner_log",
        "missing_runner_evidence",
        "missing_last_completed_step",
        "missing_next_safe_step",
        "missing_retry_count",
        "missing_evidence_refs",
        "missing_operator_decision_points",
        "unbounded_retry",
        "recovery_runtime",
        "recovery_action",
        "retry_execution",
        "continuation_packet_execution",
        "new_context_prompt_execution",
        "automatic_new_thread_creation",
        "codex_thread_creation",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_invocation",
        "api_invocation",
        "work_order_execution",
        "tool_call_execution",
        "live_tool_call",
        "live_agent_invocation",
        "live_skill_execution",
        "a2a_message_sent",
        "live_a2a_runtime",
        "board_card_runtime_mutation",
        "live_kanban_ui",
        "release_gate_execution",
        "stage_commit_push",
        "ci_replay",
        "github_actions_workflow_created",
        "github_actions_workflow_run",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_025_or_later_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18CompactFailureRecoveryDrillNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-024 only.",
        "R18-025 through R18-028 remain planned only.",
        "R18-024 exercised compact-failure recovery drill foundation only.",
        "R18-024 drill evidence is deterministic bounded local runner drill evidence only.",
        "Runner evidence is a committed drill log and dry-run local runner refs, not live product runtime.",
        "Drill records last completed step, next safe step, retry count, evidence refs, runner log refs, continuation/new-context packet refs, and operator decision points.",
        "R18-024 drill does not solve compaction or prove full product runtime.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter invocation occurred.",
        "No live agent invocation occurred.",
        "No live skill execution occurred.",
        "No tool-call execution was performed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No live Kanban UI was implemented.",
        "No recovery action was performed.",
        "No recovery runtime was implemented.",
        "No retry execution was performed.",
        "No continuation packet was executed.",
        "No new-context prompt was executed.",
        "Automatic new-thread creation was not performed.",
        "Release gate was not executed.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18CompactFailureRecoveryDrillAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_execution_log.jsonl",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_compact_failure_detector.contract.json",
        "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json",
        "state/runtime/r18_detected_failure_events/stream_disconnected_before_completion.failure.json",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/no_wip.classification.json",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json",
        "contracts/runtime/r18_continuation_packet.contract.json",
        "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json",
        "contracts/runtime/r18_new_context_prompt_generator.contract.json",
        "state/runtime/r18_new_context_prompt_packets/continue_after_compact_failure.prompt.txt",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "state/runtime/r18_local_runner_cli_dry_run_results/status_command.result.json",
        "state/runtime/r18_local_runner_cli_dry_run_results/inspect_repo_command.result.json"
    )
}

function Get-R18CompactFailureRecoveryDrillEvidenceRefs {
    return @(
        "contracts/runtime/r18_compact_failure_recovery_drill.contract.json",
        "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/failure_event.json",
        "state/runtime/r18_compact_failure_recovery_drill/wip_classification.json",
        "state/runtime/r18_compact_failure_recovery_drill/remote_verification.json",
        "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl",
        "state/runtime/r18_compact_failure_recovery_drill/results.json",
        "state/runtime/r18_compact_failure_recovery_drill/check_report.json",
        "state/ui/r18_operator_surface/r18_compact_failure_recovery_drill_snapshot.json",
        "tools/R18CompactFailureRecoveryDrill.psm1",
        "tools/new_r18_compact_failure_recovery_drill.ps1",
        "tools/validate_r18_compact_failure_recovery_drill.ps1",
        "tests/test_r18_compact_failure_recovery_drill.ps1",
        "tests/fixtures/r18_compact_failure_recovery_drill/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_024_compact_failure_recovery_drill/"
    )
}

function Get-R18CompactFailureRecoveryDrillValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_compact_failure_recovery_drill.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18CompactFailureRecoveryDrillStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_024_only"
        planned_from = "R18-025"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18DrillBoundary
    }
}

function New-R18CompactFailureRecoveryDrillBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18DrillSourceTask
        source_milestone = $script:R18DrillSourceMilestone
        repository = $script:R18DrillRepository
        branch = $script:R18DrillBranch
        status_boundary = New-R18CompactFailureRecoveryDrillStatusBoundary
        runtime_flags = New-R18CompactFailureRecoveryDrillRuntimeFlags
        positive_claims = Get-R18CompactFailureRecoveryDrillPositiveClaims
        non_claims = Get-R18CompactFailureRecoveryDrillNonClaims
        rejected_claims = Get-R18CompactFailureRecoveryDrillRejectedClaims
        authority_refs = Get-R18CompactFailureRecoveryDrillAuthorityRefs
        evidence_refs = Get-R18CompactFailureRecoveryDrillEvidenceRefs
    }
}

function New-R18CompactFailureRecoveryDrillContract {
    $contract = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_contract"
    $contract.contract_id = "r18_024_compact_failure_recovery_drill_contract_v1"
    $contract.task_title = $script:R18DrillTitle
    $contract.purpose = "Prove the runner can handle a compact/stream failure drill through state preservation and continuation."
    $contract.inputs = @(
        "Runner state store",
        "failure detector",
        "WIP classifier",
        "remote verifier",
        "continuation generator",
        "retry policy"
    )
    $contract.outputs = @(
        "Drill packet",
        "failure event",
        "WIP classification",
        "remote verification",
        "continuation/new-context packets",
        "evidence"
    )
    $contract.acceptance_criteria = @(
        "Drill records last completed step.",
        "Drill records next safe step.",
        "Drill records retry count.",
        "Drill records evidence refs.",
        "Drill records operator decision points.",
        "Drill includes runner evidence and is not packet-only recovery.",
        "Drill does not claim solved compaction."
    )
    $contract.validation_expectation = "Drill validator rejects packet-only recovery without runner evidence."
    $contract.dependencies = @("R18-010", "R18-011", "R18-012", "R18-013", "R18-014", "R18-015", "R18-016")
    $contract.dependency_refs = [ordered]@{
        runner_state_store = "state/runtime/r18_runner_state.json"
        failure_detector = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        wip_classifier = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verifier = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        continuation_generator = "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json"
        new_context_prompt_generator = "state/runtime/r18_new_context_prompt_packets/continue_after_compact_failure.prompt.txt"
        retry_policy = "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json"
        operator_approval_gate = "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json"
        local_runner_cli = "state/runtime/r18_local_runner_cli_profile.json"
    }
    $contract.runner_evidence_policy = [ordered]@{
        runner_log_required = $true
        runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
        local_runner_dry_run_refs_required = $true
        packet_only_recovery_rejected = $true
        live_runner_runtime_required = $false
        live_runner_runtime_allowed = $false
    }
    $contract.failure_retry_behavior = [ordered]@{
        failed_drill_outcome = "escalate_with_exact_failure_evidence_no_runtime_success_claim"
        retry_count_recorded = $true
        retry_execution_performed = $false
        max_retry_count = 2
        recovery_action_performed = $false
    }
    return $contract
}

function New-R18CompactFailureRecoveryDrillPacket {
    $packet = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_packet"
    $packet.drill_packet_id = "r18_024_compact_failure_recovery_drill_packet_v1"
    $packet.task_title = $script:R18DrillTitle
    $packet.drill_status = "deterministic_runner_drill_evidence_recorded_no_recovery_action"
    $packet.drill_mode = "bounded_deterministic_local_runner_drill"
    $packet.input_refs = [ordered]@{
        runner_state_store_ref = "state/runtime/r18_runner_state.json"
        runner_execution_log_ref = "state/runtime/r18_execution_log.jsonl"
        resume_checkpoint_ref = "state/runtime/r18_runner_resume_checkpoint.json"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json"
        new_context_prompt_ref = "state/runtime/r18_new_context_prompt_packets/continue_after_compact_failure.prompt.txt"
        retry_policy_decision_ref = "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json"
        recovery_operator_decision_ref = "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json"
    }
    $packet.preflight_identity = [ordered]@{
        branch = $script:R18DrillBranch
        local_head = $script:R18DrillPreflightHead
        local_tree = $script:R18DrillPreflightTree
        remote_head = $script:R18DrillPreflightRemoteHead
        identity_status = "preflight_verified_before_r18_024_generation"
        branch_mutation_performed = $false
    }
    $packet.last_completed_step = "R18-023 optional API adapter stub foundation validated and R18-024 preflight verified branch/head/tree."
    $packet.next_safe_step = "Review committed R18-024 drill evidence, keep recovery execution blocked without explicit future approval, and leave R18-025 through R18-028 planned only."
    $packet.retry_count = 1
    $packet.retry_count_meaning = "planned retry counter recorded by deterministic drill evidence; no retry execution occurred"
    $packet.max_retry_count = 2
    $packet.retry_limit_enforced = $true
    $packet.runner_evidence = [ordered]@{
        runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
        runner_log_entry_count = 7
        local_runner_cli_profile_ref = "state/runtime/r18_local_runner_cli_profile.json"
        local_runner_cli_dry_run_result_refs = @(
            "state/runtime/r18_local_runner_cli_dry_run_results/status_command.result.json",
            "state/runtime/r18_local_runner_cli_dry_run_results/inspect_repo_command.result.json"
        )
        packet_only_recovery = $false
        runner_evidence_present = $true
        live_runner_runtime_executed = $false
    }
    $packet.drill_artifact_refs = [ordered]@{
        drill_failure_event_ref = "state/runtime/r18_compact_failure_recovery_drill/failure_event.json"
        drill_wip_classification_ref = "state/runtime/r18_compact_failure_recovery_drill/wip_classification.json"
        drill_remote_verification_ref = "state/runtime/r18_compact_failure_recovery_drill/remote_verification.json"
        drill_continuation_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json"
        drill_new_context_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json"
    }
    $packet.operator_decision_points = @(
        [ordered]@{
            decision_point_id = "wip_safety_review"
            required_when = "WIP classification is unsafe, staged, historical, or operator-local."
            current_drill_status = "not_required_no_wip_seed_classification"
            operator_runtime_approval_granted = $false
        },
        [ordered]@{
            decision_point_id = "remote_branch_review"
            required_when = "Remote branch verification is missing, ahead, diverged, or wrong branch."
            current_drill_status = "not_required_remote_in_sync_preflight"
            operator_runtime_approval_granted = $false
        },
        [ordered]@{
            decision_point_id = "recovery_execution_approval"
            required_when = "Any recovery action, retry execution, automatic new context, or live runner path is requested."
            current_drill_status = "refused_by_seed_recovery_execution_decision"
            operator_runtime_approval_granted = $false
        },
        [ordered]@{
            decision_point_id = "retry_limit_escalation"
            required_when = "Retry count reaches max retry count or evidence is contradictory."
            current_drill_status = "not_reached_count_1_of_2"
            operator_runtime_approval_granted = $false
        }
    )
    $packet.stop_conditions = @(
        "runner evidence missing",
        "packet-only recovery attempt",
        "unsafe WIP",
        "remote branch not in sync",
        "retry limit reached",
        "recovery action requested",
        "automatic new-thread creation requested",
        "API invocation requested",
        "work-order execution requested",
        "board/card runtime mutation requested",
        "R18-025 or later completion claim"
    )
    $packet.validation_commands = Get-R18CompactFailureRecoveryDrillValidationCommands
    return $packet
}

function New-R18CompactFailureRecoveryDrillFailureEvent {
    $event = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_failure_event"
    $event.failure_event_id = "r18_024_drill_compact_stream_failure_event_v1"
    $event.failure_event_status = "drill_failure_event_recorded_no_recovery_action"
    $event.detected_failure_type = "compact_stream_disconnect_drill"
    $event.source_failure_event_refs = @(
        "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json",
        "state/runtime/r18_detected_failure_events/stream_disconnected_before_completion.failure.json"
    )
    $event.runner_state_ref = "state/runtime/r18_runner_state.json"
    $event.runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
    $event.last_completed_step = "R18-023 optional API adapter stub foundation validated and R18-024 preflight verified branch/head/tree."
    $event.next_safe_step = "Preserve drill evidence, review operator decision points, and do not execute recovery."
    $event.retry_count = 1
    $event.failure_retry_behavior = "failed drill escalates with exact failure evidence and no runtime success claim"
    return $event
}

function New-R18CompactFailureRecoveryDrillWipClassification {
    $classification = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_wip_classification"
    $classification.classification_id = "r18_024_drill_no_wip_classification_v1"
    $classification.classification_status = "drill_classification_from_committed_r18_011_packet"
    $classification.source_wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
    $classification.git_status_short_observed_in_preflight = @("?? .local_backups/", "?? governance/reports/AIOffice_V2_Revised_R17_Plan.md")
    $classification.allowed_untracked_refs_left_untracked = @(".local_backups/", "governance/reports/AIOffice_V2_Revised_R17_Plan.md")
    $classification.unexpected_tracked_wip_present = $false
    $classification.staged_files_present = $false
    $classification.wip_cleanup_performed = $false
    $classification.wip_abandonment_performed = $false
    $classification.operator_decision_required = $false
    return $classification
}

function New-R18CompactFailureRecoveryDrillRemoteVerification {
    $verification = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_remote_verification"
    $verification.verification_id = "r18_024_drill_remote_in_sync_preflight_v1"
    $verification.verification_status = "remote_in_sync_from_required_preflight_no_branch_mutation"
    $verification.source_remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
    $verification.expected_branch = $script:R18DrillBranch
    $verification.local_head = $script:R18DrillPreflightHead
    $verification.local_tree = $script:R18DrillPreflightTree
    $verification.remote_head = $script:R18DrillPreflightRemoteHead
    $verification.remote_marked_safe_for_drill = $true
    $verification.branch_mutation_performed = $false
    $verification.pull_rebase_reset_merge_performed = $false
    $verification.checkout_switch_clean_restore_performed = $false
    $verification.operator_decision_required = $false
    return $verification
}

function New-R18CompactFailureRecoveryDrillContinuationPacket {
    $packet = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_continuation_packet"
    $packet.continuation_packet_id = "r18_024_drill_continue_after_compact_failure_v1"
    $packet.continuation_status = "drill_continuation_packet_recorded_not_executed"
    $packet.source_continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json"
    $packet.new_context_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json"
    $packet.runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
    $packet.last_completed_step = "R18-023 optional API adapter stub foundation validated and R18-024 drill failure event recorded."
    $packet.next_safe_step = "Use committed continuation refs for future operator-reviewed R18-025 work only; do not execute continuation in R18-024."
    $packet.retry_count = 1
    $packet.max_retry_count = 2
    $packet.continuation_packet_executed = $false
    $packet.operator_decision_required_before_execution = $true
    return $packet
}

function New-R18CompactFailureRecoveryDrillNewContextPacket {
    $packet = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_new_context_packet"
    $packet.new_context_packet_id = "r18_024_drill_new_context_packet_v1"
    $packet.packet_status = "drill_new_context_packet_recorded_not_executed"
    $packet.source_prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/continue_after_compact_failure.prompt.txt"
    $packet.source_prompt_input_ref = "state/runtime/r18_new_context_prompt_inputs/continue_after_compact_failure.prompt_input.json"
    $packet.continuation_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json"
    $packet.runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
    $packet.prompt_packet_executed = $false
    $packet.automatic_new_thread_creation_performed = $false
    $packet.codex_thread_created = $false
    $packet.next_safe_step = "Treat this as committed prompt evidence only; any future new-context use requires future authority and operator decision."
    return $packet
}

function New-R18CompactFailureRecoveryDrillRunnerLogEntries {
    $common = [ordered]@{
        artifact_type = "r18_compact_failure_recovery_drill_runner_log_entry"
        contract_version = "v1"
        source_task = $script:R18DrillSourceTask
        source_milestone = $script:R18DrillSourceMilestone
        runner_state_ref = "state/runtime/r18_runner_state.json"
        drill_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json"
        runtime_flags = New-R18CompactFailureRecoveryDrillRuntimeFlags
        non_claims = Get-R18CompactFailureRecoveryDrillNonClaims
    }

    $definitions = @(
        @{ id = "r18_024_runner_log_preflight_verified"; type = "preflight_verified"; status = "branch_head_tree_remote_checked"; step = "R18-024 preflight verified branch/head/tree and no staged work."; next = "Load runner state refs for deterministic drill."; refs = @("git status --short --branch", "git rev-parse HEAD", "git rev-parse HEAD^{tree}", "git fetch origin release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle") },
        @{ id = "r18_024_runner_log_state_loaded"; type = "runner_state_loaded"; status = "state_preservation_refs_loaded"; step = "Runner state store, execution log, and resume checkpoint refs loaded."; next = "Record compact/stream failure event."; refs = @("state/runtime/r18_runner_state.json", "state/runtime/r18_execution_log.jsonl", "state/runtime/r18_runner_resume_checkpoint.json") },
        @{ id = "r18_024_runner_log_failure_recorded"; type = "failure_event_recorded"; status = "compact_stream_failure_drill_recorded"; step = "Compact/stream failure drill event recorded from R18-010 detector refs."; next = "Link WIP classification."; refs = @("state/runtime/r18_detected_failure_events/context_compaction_required.failure.json", "state/runtime/r18_compact_failure_recovery_drill/failure_event.json") },
        @{ id = "r18_024_runner_log_wip_linked"; type = "wip_classification_linked"; status = "wip_classification_ref_confirmed"; step = "WIP classification linked; expected untracked operator-local paths remain unstaged."; next = "Link remote branch verification."; refs = @("state/runtime/r18_wip_classification_packets/no_wip.classification.json", "state/runtime/r18_compact_failure_recovery_drill/wip_classification.json") },
        @{ id = "r18_024_runner_log_remote_linked"; type = "remote_verification_linked"; status = "remote_branch_preflight_in_sync"; step = "Remote branch verification linked from required preflight."; next = "Record continuation and new-context packets."; refs = @("state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json", "state/runtime/r18_compact_failure_recovery_drill/remote_verification.json") },
        @{ id = "r18_024_runner_log_continuation_recorded"; type = "continuation_packets_recorded"; status = "continuation_and_new_context_refs_recorded_not_executed"; step = "Continuation and new-context packet refs recorded."; next = "Record operator decision points and stop conditions."; refs = @("state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json", "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json") },
        @{ id = "r18_024_runner_log_operator_points_recorded"; type = "operator_decision_points_recorded"; status = "operator_decision_points_recorded_recovery_blocked"; step = "Operator decision points and retry count recorded; recovery execution remains blocked."; next = "Validate R18-024 evidence package."; refs = @("state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json", "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json") }
    )

    $entries = @()
    foreach ($definition in $definitions) {
        $entry = [ordered]@{}
        foreach ($property in $common.GetEnumerator()) {
            $entry[$property.Key] = $property.Value
        }
        $entry.log_entry_id = $definition.id
        $entry.event_type = $definition.type
        $entry.event_status = $definition.status
        $entry.last_completed_step = $definition.step
        $entry.next_safe_step = $definition.next
        $entry.retry_count = 1
        $entry.evidence_refs = $definition.refs
        $entries += $entry
    }
    return $entries
}

function New-R18CompactFailureRecoveryDrillResults {
    $results = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_results"
    $results.results_id = "r18_024_compact_failure_recovery_drill_results_v1"
    $results.aggregate_verdict = $script:R18DrillVerdict
    $results.drill_results = [ordered]@{
        drill_packet_present = $true
        runner_evidence_present = $true
        runner_log_present = $true
        runner_log_entry_count = 7
        packet_only_recovery = $false
        last_completed_step_recorded = $true
        next_safe_step_recorded = $true
        retry_count_recorded = $true
        operator_decision_points_recorded = $true
        continuation_packet_recorded = $true
        new_context_packet_recorded = $true
        compaction_solved = $false
        full_product_runtime_proven = $false
        recovery_action_performed = $false
    }
    $results.generated_artifact_refs = Get-R18CompactFailureRecoveryDrillEvidenceRefs
    $results.validation_commands = Get-R18CompactFailureRecoveryDrillValidationCommands
    return $results
}

function New-R18CompactFailureRecoveryDrillCheckReport {
    $report = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_check_report"
    $report.check_report_id = "r18_024_compact_failure_recovery_drill_check_report_v1"
    $report.aggregate_verdict = $script:R18DrillVerdict
    $report.validation_summary = [ordered]@{
        contract_valid = $true
        drill_packet_valid = $true
        runner_log_valid = $true
        packet_only_recovery_rejected = $true
        last_completed_step_recorded = $true
        next_safe_step_recorded = $true
        retry_count_recorded = $true
        evidence_refs_recorded = $true
        operator_decision_points_recorded = $true
        continuation_and_new_context_packet_refs_recorded = $true
        runtime_flags_false = $true
        status_boundary_valid = $true
    }
    $report.validation_expectation = "Drill validator rejects packet-only recovery without runner evidence."
    return $report
}

function New-R18CompactFailureRecoveryDrillSnapshot {
    $snapshot = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_operator_surface_snapshot"
    $snapshot.snapshot_id = "r18_024_compact_failure_recovery_drill_snapshot_v1"
    $snapshot.r18_status = "active_through_r18_024_only"
    $snapshot.operator_summary = [ordered]@{
        title = "R18-024 Exercise compact-failure recovery drill with local runner"
        completed_scope = "Deterministic compact/stream failure recovery drill foundation only."
        runner_evidence = "runner log and dry-run local runner refs recorded"
        last_completed_step = "R18-023 optional API adapter stub foundation validated and R18-024 preflight verified branch/head/tree."
        next_safe_step = "Review R18-024 evidence; R18-025 through R18-028 remain planned only."
        retry_count = 1
        recovery_action = "not_performed"
        compaction_solution = "not_claimed"
    }
    $snapshot.visible_controls = @(
        "runner evidence required",
        "packet-only recovery rejected",
        "operator decision points recorded",
        "recovery execution blocked",
        "compaction remains unresolved"
    )
    return $snapshot
}

function New-R18CompactFailureRecoveryDrillEvidenceIndex {
    $index = New-R18CompactFailureRecoveryDrillBase -ArtifactType "r18_compact_failure_recovery_drill_evidence_index"
    $index.evidence_index_id = "r18_024_compact_failure_recovery_drill_evidence_index_v1"
    $index.aggregate_verdict = $script:R18DrillVerdict
    $index.evidence_summary = "R18-024 evidence is a deterministic compact/stream failure recovery drill package with runner log evidence and continuation/new-context refs only."
    $index.validation_commands = Get-R18CompactFailureRecoveryDrillValidationCommands
    $index.ci_gap_disclosure = "No CI replay was performed; evidence remains committed artifacts plus Codex-reported local validations."
    return $index
}

function Get-R18CompactFailureRecoveryDrillProofReviewLines {
    return @(
        "# R18-024 Compact-Failure Recovery Drill Proof Review",
        "",
        "Task: R18-024 Exercise compact-failure recovery drill with local runner",
        "",
        "Scope: deterministic compact/stream failure recovery drill foundation only.",
        "",
        "Current status truth after this task: R18 is active through R18-024 only, R18-025 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Evidence refs:",
        "- contracts/runtime/r18_compact_failure_recovery_drill.contract.json",
        "- state/runtime/r18_compact_failure_recovery_drill/drill_packet.json",
        "- state/runtime/r18_compact_failure_recovery_drill/failure_event.json",
        "- state/runtime/r18_compact_failure_recovery_drill/wip_classification.json",
        "- state/runtime/r18_compact_failure_recovery_drill/remote_verification.json",
        "- state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json",
        "- state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json",
        "- state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl",
        "- state/runtime/r18_compact_failure_recovery_drill/results.json",
        "- state/runtime/r18_compact_failure_recovery_drill/check_report.json",
        "- state/ui/r18_operator_surface/r18_compact_failure_recovery_drill_snapshot.json",
        "- tools/R18CompactFailureRecoveryDrill.psm1",
        "- tools/new_r18_compact_failure_recovery_drill.ps1",
        "- tools/validate_r18_compact_failure_recovery_drill.ps1",
        "- tests/test_r18_compact_failure_recovery_drill.ps1",
        "- tests/fixtures/r18_compact_failure_recovery_drill/",
        "",
        "Non-claims: the drill does not solve compaction or prove full product runtime. No Codex/OpenAI API invocation, live API adapter invocation, live agent invocation, live skill execution, tool-call execution, A2A message, work-order execution, board/card runtime mutation, live Kanban UI, recovery action, release gate execution, CI replay, GitHub Actions workflow creation/run, product runtime, no-manual-prompt-transfer success, or solved Codex reliability is claimed."
    )
}

function Get-R18CompactFailureRecoveryDrillValidationManifestLines {
    return @(
        "# R18-024 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-024 only; R18-025 through R18-028 planned only.",
        "",
        "Focused commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_compact_failure_recovery_drill.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1",
        "",
        "This manifest records deterministic local validation expectations only. It is not CI replay."
    )
}

function Get-R18CompactFailureRecoveryDrillInvalidFixtures {
    return @(
        [ordered]@{ fixture_id = "invalid_missing_runner_log_ref"; target = "drill_packet"; operation = "remove"; path = "runner_evidence.runner_log_ref"; expected_failure_fragments = @("runner log") },
        [ordered]@{ fixture_id = "invalid_packet_only_recovery"; target = "drill_packet"; operation = "set"; path = "runner_evidence.packet_only_recovery"; value = $true; expected_failure_fragments = @("packet-only recovery") },
        [ordered]@{ fixture_id = "invalid_missing_last_completed_step"; target = "drill_packet"; operation = "remove"; path = "last_completed_step"; expected_failure_fragments = @("last_completed_step") },
        [ordered]@{ fixture_id = "invalid_missing_next_safe_step"; target = "drill_packet"; operation = "remove"; path = "next_safe_step"; expected_failure_fragments = @("next_safe_step") },
        [ordered]@{ fixture_id = "invalid_missing_retry_count"; target = "drill_packet"; operation = "remove"; path = "retry_count"; expected_failure_fragments = @("retry_count") },
        [ordered]@{ fixture_id = "invalid_unbounded_retry"; target = "drill_packet"; operation = "set"; path = "max_retry_count"; value = 999; expected_failure_fragments = @("retry") },
        [ordered]@{ fixture_id = "invalid_missing_operator_decision_points"; target = "drill_packet"; operation = "set"; path = "operator_decision_points"; value = @(); expected_failure_fragments = @("operator decision") },
        [ordered]@{ fixture_id = "invalid_missing_continuation_ref"; target = "continuation_packet"; operation = "remove"; path = "source_continuation_packet_ref"; expected_failure_fragments = @("source_continuation_packet_ref") },
        [ordered]@{ fixture_id = "invalid_recovery_action_claim"; target = "results"; operation = "set"; path = "runtime_flags.recovery_action_performed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_solved_compaction_claim"; target = "results"; operation = "set"; path = "runtime_flags.solved_codex_compaction_claimed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_product_runtime_claim"; target = "check_report"; operation = "set"; path = "runtime_flags.product_runtime_executed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_r18_025_completion_claim"; target = "contract"; operation = "set"; path = "runtime_flags.r18_025_completed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_operator_local_backup_ref"; target = "drill_packet"; operation = "set"; path = "evidence_refs"; value = @(".local_backups/r18-024.json"); expected_failure_fragments = @("operator-local backup") }
    )
}

function Write-R18CompactFailureRecoveryDrillJson {
    param(
        [Parameter(Mandatory = $true)][object]$Value,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R18CompactFailureRecoveryDrillText {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    Set-Content -LiteralPath $Path -Value $Lines -Encoding UTF8
}

function Write-R18CompactFailureRecoveryDrillJsonl {
    param(
        [Parameter(Mandatory = $true)][object[]]$Entries,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $lines = @($Entries | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function New-R18CompactFailureRecoveryDrillArtifacts {
    param([string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot))

    $paths = Get-R18CompactFailureRecoveryDrillPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18CompactFailureRecoveryDrillContract
    $drillPacket = New-R18CompactFailureRecoveryDrillPacket
    $failureEvent = New-R18CompactFailureRecoveryDrillFailureEvent
    $wipClassification = New-R18CompactFailureRecoveryDrillWipClassification
    $remoteVerification = New-R18CompactFailureRecoveryDrillRemoteVerification
    $continuationPacket = New-R18CompactFailureRecoveryDrillContinuationPacket
    $newContextPacket = New-R18CompactFailureRecoveryDrillNewContextPacket
    $runnerLogEntries = New-R18CompactFailureRecoveryDrillRunnerLogEntries
    $results = New-R18CompactFailureRecoveryDrillResults
    $checkReport = New-R18CompactFailureRecoveryDrillCheckReport
    $snapshot = New-R18CompactFailureRecoveryDrillSnapshot
    $evidenceIndex = New-R18CompactFailureRecoveryDrillEvidenceIndex

    Write-R18CompactFailureRecoveryDrillJson -Value $contract -Path $paths.Contract
    Write-R18CompactFailureRecoveryDrillJson -Value $drillPacket -Path $paths.DrillPacket
    Write-R18CompactFailureRecoveryDrillJson -Value $failureEvent -Path $paths.FailureEvent
    Write-R18CompactFailureRecoveryDrillJson -Value $wipClassification -Path $paths.WipClassification
    Write-R18CompactFailureRecoveryDrillJson -Value $remoteVerification -Path $paths.RemoteVerification
    Write-R18CompactFailureRecoveryDrillJson -Value $continuationPacket -Path $paths.ContinuationPacket
    Write-R18CompactFailureRecoveryDrillJson -Value $newContextPacket -Path $paths.NewContextPacket
    Write-R18CompactFailureRecoveryDrillJsonl -Entries $runnerLogEntries -Path $paths.RunnerLog
    Write-R18CompactFailureRecoveryDrillJson -Value $results -Path $paths.Results
    Write-R18CompactFailureRecoveryDrillJson -Value $checkReport -Path $paths.CheckReport
    Write-R18CompactFailureRecoveryDrillJson -Value $snapshot -Path $paths.Snapshot
    Write-R18CompactFailureRecoveryDrillJson -Value $evidenceIndex -Path $paths.EvidenceIndex
    Write-R18CompactFailureRecoveryDrillText -Lines (Get-R18CompactFailureRecoveryDrillProofReviewLines) -Path $paths.ProofReview
    Write-R18CompactFailureRecoveryDrillText -Lines (Get-R18CompactFailureRecoveryDrillValidationManifestLines) -Path $paths.ValidationManifest

    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    Write-R18CompactFailureRecoveryDrillJson -Value $drillPacket -Path (Join-Path $paths.FixtureRoot "valid_drill_packet.json")
    $fixtures = Get-R18CompactFailureRecoveryDrillInvalidFixtures
    foreach ($fixture in $fixtures) {
        Write-R18CompactFailureRecoveryDrillJson -Value $fixture -Path (Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id))
    }
    $manifest = [ordered]@{
        artifact_type = "r18_compact_failure_recovery_drill_fixture_manifest"
        source_task = $script:R18DrillSourceTask
        valid_fixture_refs = @("tests/fixtures/r18_compact_failure_recovery_drill/valid_drill_packet.json")
        invalid_fixture_refs = @($fixtures | ForEach-Object { "tests/fixtures/r18_compact_failure_recovery_drill/{0}.json" -f $_.fixture_id })
        runtime_flags = New-R18CompactFailureRecoveryDrillRuntimeFlags
        non_claims = Get-R18CompactFailureRecoveryDrillNonClaims
    }
    Write-R18CompactFailureRecoveryDrillJson -Value $manifest -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json")

    return [pscustomobject]@{
        AggregateVerdict = $script:R18DrillVerdict
        RunnerLogEntryCount = @($runnerLogEntries).Count
        InvalidFixtureCount = @($fixtures).Count
        Paths = $paths
    }
}

function Read-R18CompactFailureRecoveryDrillJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot)
    )

    $resolvedPath = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Read-R18CompactFailureRecoveryDrillJsonl {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required runner log is missing: $Path"
    }
    return @(Get-Content -LiteralPath $Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_ | ConvertFrom-Json })
}

function Assert-R18CompactFailureRecoveryDrillCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18CompactFailureRecoveryDrillProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($Object.PSObject.Properties.Name -contains $Name) -Message "$Context missing required property '$Name'."
}

function Assert-R18CompactFailureRecoveryDrillNoUnsafeRefs {
    param(
        [Parameter(Mandatory = $true)][object]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($ref in @($Refs)) {
        $refText = [string]$ref
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($refText -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context contains operator-local backup ref: $refText"
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($refText -ne "governance/reports/AIOffice_V2_Revised_R17_Plan.md") -Message "$Context contains untracked revised R17 plan report ref."
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($refText -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context contains historical evidence edit ref: $refText"
    }
}

function Assert-R18CompactFailureRecoveryDrillRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flagName in Get-R18CompactFailureRecoveryDrillRuntimeFlagNames) {
        Assert-R18CompactFailureRecoveryDrillProperty -Object $RuntimeFlags -Name $flagName -Context "$Context runtime_flags"
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
    }
}

function Assert-R18CompactFailureRecoveryDrillCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($property in @("artifact_type", "contract_version", "source_task", "source_milestone", "status_boundary", "runtime_flags", "non_claims", "rejected_claims", "authority_refs", "evidence_refs")) {
        Assert-R18CompactFailureRecoveryDrillProperty -Object $Artifact -Name $property -Context $Context
    }
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($Artifact.source_task -eq $script:R18DrillSourceTask) -Message "$Context source_task must be R18-024."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_024_only") -Message "$Context status boundary must be active through R18-024 only."
    Assert-R18CompactFailureRecoveryDrillRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    Assert-R18CompactFailureRecoveryDrillNoUnsafeRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs"
    Assert-R18CompactFailureRecoveryDrillNoUnsafeRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs"
}

function Test-R18CompactFailureRecoveryDrillSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$DrillPacket,
        [Parameter(Mandatory = $true)]$FailureEvent,
        [Parameter(Mandatory = $true)]$WipClassification,
        [Parameter(Mandatory = $true)]$RemoteVerification,
        [Parameter(Mandatory = $true)]$ContinuationPacket,
        [Parameter(Mandatory = $true)]$NewContextPacket,
        [Parameter(Mandatory = $true)]$Results,
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$Snapshot,
        [Parameter(Mandatory = $true)]$EvidenceIndex,
        [Parameter(Mandatory = $true)][object[]]$RunnerLogEntries
    )

    foreach ($pair in @(
            @{ Context = "contract"; Artifact = $Contract },
            @{ Context = "drill_packet"; Artifact = $DrillPacket },
            @{ Context = "failure_event"; Artifact = $FailureEvent },
            @{ Context = "wip_classification"; Artifact = $WipClassification },
            @{ Context = "remote_verification"; Artifact = $RemoteVerification },
            @{ Context = "continuation_packet"; Artifact = $ContinuationPacket },
            @{ Context = "new_context_packet"; Artifact = $NewContextPacket },
            @{ Context = "results"; Artifact = $Results },
            @{ Context = "check_report"; Artifact = $Report },
            @{ Context = "snapshot"; Artifact = $Snapshot },
            @{ Context = "evidence_index"; Artifact = $EvidenceIndex }
        )) {
        Assert-R18CompactFailureRecoveryDrillCommonArtifact -Artifact $pair.Artifact -Context $pair.Context
    }

    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($Contract.validation_expectation -like "*rejects packet-only recovery without runner evidence*") -Message "Contract must reject packet-only recovery without runner evidence."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($DrillPacket.PSObject.Properties.Name -contains "last_completed_step" -and -not [string]::IsNullOrWhiteSpace($DrillPacket.last_completed_step)) -Message "drill_packet missing last_completed_step."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($DrillPacket.PSObject.Properties.Name -contains "next_safe_step" -and -not [string]::IsNullOrWhiteSpace($DrillPacket.next_safe_step)) -Message "drill_packet missing next_safe_step."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($DrillPacket.PSObject.Properties.Name -contains "retry_count") -Message "drill_packet missing retry_count."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([int]$DrillPacket.retry_count -le [int]$DrillPacket.max_retry_count -and [int]$DrillPacket.max_retry_count -le 2 -and [bool]$DrillPacket.retry_limit_enforced) -Message "Drill retry count must be bounded and enforced."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($DrillPacket.PSObject.Properties.Name -contains "runner_evidence") -Message "drill_packet missing runner evidence."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($DrillPacket.runner_evidence.PSObject.Properties.Name -contains "runner_log_ref" -and -not [string]::IsNullOrWhiteSpace($DrillPacket.runner_evidence.runner_log_ref)) -Message "drill_packet missing runner log ref."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$DrillPacket.runner_evidence.runner_evidence_present -eq $true) -Message "Runner evidence must be present."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$DrillPacket.runner_evidence.packet_only_recovery -eq $false) -Message "Drill cannot be packet-only recovery."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition (@($DrillPacket.runner_evidence.local_runner_cli_dry_run_result_refs).Count -ge 2) -Message "Drill must include local runner dry-run refs."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition (@($DrillPacket.operator_decision_points).Count -ge 3) -Message "Drill must include operator decision points."

    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($FailureEvent.failure_event_status -like "*no_recovery_action*") -Message "Failure event must not claim recovery action."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$WipClassification.wip_cleanup_performed -eq $false -and [bool]$WipClassification.wip_abandonment_performed -eq $false) -Message "WIP classification must not perform cleanup or abandonment."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($RemoteVerification.verification_status -like "*no_branch_mutation*" -and [bool]$RemoteVerification.branch_mutation_performed -eq $false) -Message "Remote verification must not mutate branches."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($ContinuationPacket.PSObject.Properties.Name -contains "source_continuation_packet_ref" -and -not [string]::IsNullOrWhiteSpace($ContinuationPacket.source_continuation_packet_ref)) -Message "continuation_packet missing source_continuation_packet_ref."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$ContinuationPacket.continuation_packet_executed -eq $false) -Message "Continuation packet must not be executed."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$NewContextPacket.prompt_packet_executed -eq $false -and [bool]$NewContextPacket.automatic_new_thread_creation_performed -eq $false) -Message "New-context packet must not be executed or create a thread."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$Results.drill_results.runner_evidence_present -eq $true -and [bool]$Results.drill_results.packet_only_recovery -eq $false) -Message "Results must prove runner evidence and reject packet-only recovery."
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ([bool]$Results.drill_results.compaction_solved -eq $false -and [bool]$Results.drill_results.full_product_runtime_proven -eq $false) -Message "Results must not solve compaction or prove product runtime."

    Assert-R18CompactFailureRecoveryDrillCondition -Condition (@($RunnerLogEntries).Count -eq [int]$DrillPacket.runner_evidence.runner_log_entry_count) -Message "Runner log entry count must match drill packet."
    $eventTypes = @($RunnerLogEntries | ForEach-Object { $_.event_type })
    foreach ($requiredType in @("preflight_verified", "runner_state_loaded", "failure_event_recorded", "wip_classification_linked", "remote_verification_linked", "continuation_packets_recorded", "operator_decision_points_recorded")) {
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($eventTypes -contains $requiredType) -Message "Runner log missing event type: $requiredType"
    }
    foreach ($entry in $RunnerLogEntries) {
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($entry.source_task -eq $script:R18DrillSourceTask) -Message "Runner log entry must source R18-024."
        Assert-R18CompactFailureRecoveryDrillRuntimeFlags -RuntimeFlags $entry.runtime_flags -Context ("runner_log {0}" -f $entry.log_entry_id)
        Assert-R18CompactFailureRecoveryDrillNoUnsafeRefs -Refs $entry.evidence_refs -Context ("runner_log {0} evidence_refs" -f $entry.log_entry_id)
    }

    return [pscustomobject]@{
        AggregateVerdict = $Results.aggregate_verdict
        RunnerEvidencePresent = [bool]$DrillPacket.runner_evidence.runner_evidence_present
        RunnerLogEntryCount = @($RunnerLogEntries).Count
        RetryCount = [int]$DrillPacket.retry_count
        RecoveryActionPerformed = [bool]$Results.drill_results.recovery_action_performed
    }
}

function Get-R18CompactFailureRecoveryDrillSet {
    param([string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot))

    $paths = Get-R18CompactFailureRecoveryDrillPaths -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        Contract = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.Contract
        DrillPacket = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.DrillPacket
        FailureEvent = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.FailureEvent
        WipClassification = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.WipClassification
        RemoteVerification = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.RemoteVerification
        ContinuationPacket = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.ContinuationPacket
        NewContextPacket = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.NewContextPacket
        RunnerLogEntries = Read-R18CompactFailureRecoveryDrillJsonl -Path $paths.RunnerLog
        Results = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.Results
        Report = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.CheckReport
        Snapshot = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.Snapshot
        EvidenceIndex = Read-R18CompactFailureRecoveryDrillJson -RepositoryRoot $RepositoryRoot -Path $paths.EvidenceIndex
    }
}

function Test-R18CompactFailureRecoveryDrillStatusTruth {
    param([string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot))

    $statusFiles = @(
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md"
    )
    $texts = @{}
    foreach ($file in $statusFiles) {
        $path = Resolve-R18CompactFailureRecoveryDrillPath -RepositoryRoot $RepositoryRoot -PathValue $file
        Assert-R18CompactFailureRecoveryDrillCondition -Condition (Test-Path -LiteralPath $path -PathType Leaf) -Message "Status surface missing: $file"
        $texts[$file] = Get-Content -LiteralPath $path -Raw
    }
    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-025 only",
            "R18-026 through R18-028 planned only",
            "R18-025 completed compact-safe Cycle 3 QA/fix-loop harness evidence package only",
            "R18-025 evidence exceeds packet-only artifacts through deterministic harness work-order records",
            "R18-025 does not claim four cycles",
            "R18-024 exercised compact-failure recovery drill foundation only",
            "R18-024 drill evidence is deterministic bounded local runner drill evidence only",
            "R18-024 drill does not solve compaction or prove full product runtime",
            "R18-023 created optional API adapter stub foundation only",
            "No Codex/OpenAI API invocation occurred",
            "No live API adapter invocation",
            "No live agent",
            "No live skill",
            "No tool-call execution",
            "No A2A messages",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No recovery action was performed",
            "No retry execution was performed",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved",
            "Main is not merged"
        )) {
        Assert-R18CompactFailureRecoveryDrillCondition -Condition ($combinedText -like "*$required*") -Message "Status surface missing R18-024 wording: $required"
    }

    $taskMatches = [regex]::Matches($texts["governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md"], '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    Assert-R18CompactFailureRecoveryDrillCondition -Condition ($taskMatches.Count -eq 28) -Message "R18 authority must define 28 task statuses."
    foreach ($match in $taskMatches) {
        $taskId = $match.Groups[1].Value
        $status = $match.Groups[2].Value
        $taskNumber = [int]$taskId.Substring(4)
        if ($taskNumber -le 25) {
            Assert-R18CompactFailureRecoveryDrillCondition -Condition ($status -eq "done") -Message "$taskId must be done after R18-025."
        }
        else {
            Assert-R18CompactFailureRecoveryDrillCondition -Condition ($status -eq "planned") -Message "$taskId must remain planned only after R18-025."
        }
    }
    if ($combinedText -match 'R18 active through R18-(02[6-8])') {
        throw "Status surface claims R18 beyond R18-025."
    }
    if ($combinedText -match 'R18-02[6-8][^\.\r\n]{0,80}(done|complete|completed|implemented|executed)') {
        throw "Status surface claims R18-026 or later completion."
    }

    return [pscustomobject]@{
        R18DoneThrough = 25
        R18PlannedStart = 26
        R18PlannedThrough = 28
    }
}

function Copy-R18CompactFailureRecoveryDrillObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18CompactFailureRecoveryDrillMutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "contract" { return $Set.Contract }
        "drill_packet" { return $Set.DrillPacket }
        "failure_event" { return $Set.FailureEvent }
        "wip_classification" { return $Set.WipClassification }
        "remote_verification" { return $Set.RemoteVerification }
        "continuation_packet" { return $Set.ContinuationPacket }
        "new_context_packet" { return $Set.NewContextPacket }
        "results" { return $Set.Results }
        "check_report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target: $Target" }
    }
}

function Set-R18CompactFailureRecoveryDrillPathValue {
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

function Invoke-R18CompactFailureRecoveryDrillMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )

    $parts = ([string]$Mutation.path).Split(".")
    switch ([string]$Mutation.operation) {
        "set" { Set-R18CompactFailureRecoveryDrillPathValue -Object $TargetObject -Parts $parts -Value $Mutation.value }
        "remove" { Set-R18CompactFailureRecoveryDrillPathValue -Object $TargetObject -Parts $parts -Value $null -Remove }
        default { throw "Unknown mutation operation: $($Mutation.operation)" }
    }
}

function Test-R18CompactFailureRecoveryDrill {
    param(
        [string]$RepositoryRoot = (Get-R18CompactFailureRecoveryDrillRepositoryRoot),
        [switch]$SkipStatusTruth
    )

    $set = Get-R18CompactFailureRecoveryDrillSet -RepositoryRoot $RepositoryRoot
    $result = Test-R18CompactFailureRecoveryDrillSet `
        -Contract $set.Contract `
        -DrillPacket $set.DrillPacket `
        -FailureEvent $set.FailureEvent `
        -WipClassification $set.WipClassification `
        -RemoteVerification $set.RemoteVerification `
        -ContinuationPacket $set.ContinuationPacket `
        -NewContextPacket $set.NewContextPacket `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RunnerLogEntries $set.RunnerLogEntries
    if (-not $SkipStatusTruth) {
        Test-R18CompactFailureRecoveryDrillStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }
    return $result
}

Export-ModuleMember -Function `
    Get-R18CompactFailureRecoveryDrillPaths, `
    Get-R18CompactFailureRecoveryDrillRuntimeFlagNames, `
    New-R18CompactFailureRecoveryDrillArtifacts, `
    Get-R18CompactFailureRecoveryDrillSet, `
    Test-R18CompactFailureRecoveryDrillSet, `
    Test-R18CompactFailureRecoveryDrill, `
    Test-R18CompactFailureRecoveryDrillStatusTruth, `
    Copy-R18CompactFailureRecoveryDrillObject, `
    Get-R18CompactFailureRecoveryDrillMutationTarget, `
    Invoke-R18CompactFailureRecoveryDrillMutation
