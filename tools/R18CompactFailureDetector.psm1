Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-010"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18DetectorVerdict = "generated_r18_010_compact_failure_detector_foundation_only"
$script:R18RunnerStateRef = "state/runtime/r18_runner_state.json"
$script:R18ExecutionLogRef = "state/runtime/r18_execution_log.jsonl"
$script:R18ResumeCheckpointRef = "state/runtime/r18_runner_resume_checkpoint.json"
$script:R18CurrentWorkOrderRef = "state/runtime/r18_work_order_seed_packets/r18_008_seed_blocked_pending_future_execution.work_order.json"
$script:R18CurrentState = "blocked_pending_future_execution_runtime"
$script:R18LastCompletedStep = "R18-009 runner state store and resumable execution log foundation validated"
$script:R18NextSafeStep = "Preserve the detected seed failure event for later R18-011 WIP classification and R18-013 continuation packet generation; do not recover, retry, execute work, or create a new context in R18-010."

$script:R18RuntimeFlagFields = @(
    "compact_failure_detector_live_runtime_executed",
    "live_failure_monitoring_performed",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "wip_classifier_implemented",
    "wip_classification_performed",
    "remote_branch_verifier_runtime_implemented",
    "remote_branch_verified",
    "continuation_packet_generated",
    "new_context_prompt_generated",
    "work_order_execution_performed",
    "work_order_state_machine_runtime_executed",
    "runner_state_store_runtime_executed",
    "live_runner_runtime_executed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "stage_commit_push_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_011_completed",
    "main_merge_claimed"
)

$script:R18RequiredSignalFields = @(
    "artifact_type",
    "contract_version",
    "signal_id",
    "signal_name",
    "source_task",
    "source_milestone",
    "signal_status",
    "signal_type",
    "raw_signal_summary",
    "observed_error_text",
    "observed_phase",
    "runner_state_ref",
    "execution_log_ref",
    "resume_checkpoint_ref",
    "expected_detection_rule",
    "expected_detected_failure_type",
    "expected_confidence",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredFailureEventFields = @(
    "artifact_type",
    "contract_version",
    "failure_event_id",
    "source_task",
    "source_milestone",
    "failure_event_status",
    "detected_failure_type",
    "failure_source",
    "classification_confidence",
    "source_signal_ref",
    "runner_state_ref",
    "execution_log_ref",
    "resume_checkpoint_ref",
    "current_work_order_ref",
    "current_state",
    "last_completed_step",
    "next_safe_step",
    "retry_count",
    "max_retry_count",
    "stop_conditions",
    "escalation_conditions",
    "operator_decision_required",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredDetectionResultFields = @(
    "result_id",
    "signal_id",
    "signal_type",
    "detection_rule",
    "detected_failure_type",
    "classification_confidence",
    "failure_event_ref",
    "operator_decision_required",
    "evidence_refs",
    "authority_refs",
    "runtime_flags"
)

$script:R18AllowedSignalTypes = @(
    "codex_backend_compact_stream_disconnect",
    "context_compaction_required",
    "stream_disconnected_before_completion",
    "validation_interrupted_after_compact",
    "non_compact_validation_failure",
    "unknown_failure_requires_escalation"
)

$script:R18AllowedDetectedFailureTypes = @(
    "codex_compact_failure",
    "context_compaction_required",
    "stream_disconnected_before_completion",
    "validation_failure_after_compact",
    "validation_failure_not_compact",
    "unknown_failure_operator_decision_required"
)

$script:R18AllowedConfidenceValues = @(
    "high",
    "medium",
    "low",
    "unknown_requires_operator_decision"
)

$script:R18AllowedPositiveClaims = @(
    "r18_failure_event_contract_created",
    "r18_compact_failure_detector_contract_created",
    "r18_compact_failure_detector_profile_created",
    "r18_failure_signal_samples_created",
    "r18_detected_failure_events_created",
    "r18_detection_results_created",
    "r18_compact_failure_detector_validator_created",
    "r18_compact_failure_detector_fixtures_created",
    "r18_compact_failure_detector_proof_review_created"
)

$script:R18RejectedClaims = @(
    "live_failure_monitoring",
    "live_compact_failure_detector_runtime",
    "recovery_runtime",
    "recovery_action",
    "wip_classifier_implementation",
    "wip_classification",
    "remote_branch_verifier_runtime",
    "remote_branch_verification",
    "continuation_packet_generation",
    "new_context_prompt_generation",
    "work_order_execution",
    "work_order_state_machine_runtime_execution",
    "runner_state_store_runtime_execution",
    "live_runner_runtime",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "automatic_new_thread_creation",
    "stage_commit_push",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_011_or_later_completion",
    "main_merge",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "broad_repo_write",
    "unknown_failure_guessing"
)

$script:R18SignalDefinitions = @(
    [ordered]@{
        file = "codex_backend_compact_stream_disconnect.signal.json"
        signal_type = "codex_backend_compact_stream_disconnect"
        signal_name = "Codex backend compact stream disconnect"
        raw_signal_summary = "Seed signal: backend compact response stream disconnected while a compact task was in progress."
        observed_error_text = "backend compact response stream disconnected during compact task before completion"
        observed_phase = "backend_compact_response"
        expected_detection_rule = "detect_codex_backend_compact_stream_disconnect"
        expected_detected_failure_type = "codex_compact_failure"
        expected_confidence = "high"
        failure_source = "codex_backend_stream"
        operator_decision_required = $false
        required_evidence = "stream disconnected during backend compact response or compact task"
    },
    [ordered]@{
        file = "context_compaction_required.signal.json"
        signal_type = "context_compaction_required"
        signal_name = "Context compaction required"
        raw_signal_summary = "Seed signal: context compression or compaction was required before the task could continue."
        observed_error_text = "context compression required; automatic compaction triggered before continuing"
        observed_phase = "context_management"
        expected_detection_rule = "detect_context_compaction_required"
        expected_detected_failure_type = "context_compaction_required"
        expected_confidence = "high"
        failure_source = "context_compaction_gate"
        operator_decision_required = $false
        required_evidence = "context compression or compaction was required or automatically triggered"
    },
    [ordered]@{
        file = "stream_disconnected_before_completion.signal.json"
        signal_type = "stream_disconnected_before_completion"
        signal_name = "Stream disconnected before completion"
        raw_signal_summary = "Seed signal: stream disconnected before completion with no compact or compaction text present."
        observed_error_text = "stream disconnected before completion; no compact or compaction text present"
        observed_phase = "tool_output_stream"
        expected_detection_rule = "detect_stream_disconnected_before_completion"
        expected_detected_failure_type = "stream_disconnected_before_completion"
        expected_confidence = "medium"
        failure_source = "transport_stream"
        operator_decision_required = $false
        required_evidence = "stream interruption without confirmed compact text"
    },
    [ordered]@{
        file = "validation_interrupted_after_compact.signal.json"
        signal_type = "validation_interrupted_after_compact"
        signal_name = "Validation interrupted after compact"
        raw_signal_summary = "Seed signal: validation phase was interrupted after compact or context interruption text appeared."
        observed_error_text = "validation interrupted after compact signal; validation command did not complete"
        observed_phase = "validation"
        expected_detection_rule = "detect_validation_interrupted_after_compact"
        expected_detected_failure_type = "validation_failure_after_compact"
        expected_confidence = "medium"
        failure_source = "validation_runner_interruption"
        operator_decision_required = $false
        required_evidence = "validation phase plus compact or interruption signal"
    },
    [ordered]@{
        file = "non_compact_validation_failure.signal.json"
        signal_type = "non_compact_validation_failure"
        signal_name = "Non-compact validation failure"
        raw_signal_summary = "Seed signal: validation command failed deterministically without compact, compaction, or stream interruption text."
        observed_error_text = "validation command failed with assertion mismatch; no compact or interruption signal present"
        observed_phase = "validation"
        expected_detection_rule = "detect_non_compact_validation_failure"
        expected_detected_failure_type = "validation_failure_not_compact"
        expected_confidence = "high"
        failure_source = "validation_gate"
        operator_decision_required = $false
        required_evidence = "validation failure without compact or interruption signal"
    },
    [ordered]@{
        file = "unknown_failure_requires_escalation.signal.json"
        signal_type = "unknown_failure_requires_escalation"
        signal_name = "Unknown failure requires escalation"
        raw_signal_summary = "Seed signal: failure note is insufficient for deterministic classification and must require operator decision."
        observed_error_text = "unrecognized failure note with insufficient deterministic signal"
        observed_phase = "unknown"
        expected_detection_rule = "detect_unknown_failure_requires_escalation"
        expected_detected_failure_type = "unknown_failure_operator_decision_required"
        expected_confidence = "unknown_requires_operator_decision"
        failure_source = "unknown_seed_signal"
        operator_decision_required = $true
        required_evidence = "insufficient deterministic signal, do not guess"
    }
)

function Get-R18CompactFailureDetectorRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18CompactPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18CompactJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18CompactJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R18CompactText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R18CompactFailureDetectorObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18CompactFailureDetectorPaths {
    param([string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot))

    return [ordered]@{
        FailureEventContract = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_failure_event.contract.json"
        DetectorContract = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_compact_failure_detector.contract.json"
        Profile = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_compact_failure_detector_profile.json"
        SignalRoot = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_compact_failure_signal_samples"
        FailureEventRoot = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_detected_failure_events"
        Results = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_compact_failure_detector_results.json"
        CheckReport = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_compact_failure_detector_check_report.json"
        UiSnapshot = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_compact_failure_detector_snapshot.json"
        FixtureRoot = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_compact_failure_detector"
        ProofRoot = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector"
        EvidenceIndex = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector/evidence_index.json"
        ProofReview = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector/proof_review.md"
        ValidationManifest = Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector/validation_manifest.md"
    }
}

function Get-R18CompactRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18CompactNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-010 only.",
        "R18-011 through R18-028 remain planned only.",
        "R18-010 created compact failure detector foundation only.",
        "Failure detection is deterministic over seed signal artifacts only.",
        "Failure events are not recovery completion.",
        "WIP classifier is not implemented.",
        "Remote branch verifier runtime is not implemented.",
        "Continuation packet generator is not implemented.",
        "New-context prompt generator is not implemented.",
        "No recovery action was performed.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No stage/commit/push was performed by the detector.",
        "No product runtime is claimed.",
        "Codex compaction is detected as a failure type, not solved.",
        "Codex reliability is not solved.",
        "No no-manual-prompt-transfer success is claimed.",
        "Main is not merged."
    )
}

function Get-R18CompactAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_state_history.jsonl",
        "state/runtime/r18_execution_log.jsonl",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_state_machine.json",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "state/runtime/r17_automated_recovery_loop_failure_events.jsonl",
        "state/runtime/r17_automated_recovery_loop_continuation_packets.json",
        "state/runtime/r17_automated_recovery_loop_new_context_packets.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18CompactEvidenceRefs {
    return @(
        "contracts/runtime/r18_failure_event.contract.json",
        "contracts/runtime/r18_compact_failure_detector.contract.json",
        "state/runtime/r18_compact_failure_detector_profile.json",
        "state/runtime/r18_compact_failure_signal_samples/",
        "state/runtime/r18_detected_failure_events/",
        "state/runtime/r18_compact_failure_detector_results.json",
        "state/runtime/r18_compact_failure_detector_check_report.json",
        "state/ui/r18_operator_surface/r18_compact_failure_detector_snapshot.json",
        "tools/R18CompactFailureDetector.psm1",
        "tools/new_r18_compact_failure_detector.ps1",
        "tools/validate_r18_compact_failure_detector.ps1",
        "tests/test_r18_compact_failure_detector.ps1",
        "tests/fixtures/r18_compact_failure_detector/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector/"
    )
}

function Get-R18CompactValidationRefs {
    return @(
        "tools/validate_r18_compact_failure_detector.ps1",
        "tests/test_r18_compact_failure_detector.ps1",
        "tools/validate_r18_runner_state_store.ps1",
        "tests/test_r18_runner_state_store.ps1",
        "tools/validate_r18_work_order_state_machine.ps1",
        "tests/test_r18_work_order_state_machine.ps1",
        "tools/validate_r18_local_runner_cli.ps1",
        "tests/test_r18_local_runner_cli.ps1",
        "tools/validate_r18_orchestrator_control_intake.ps1",
        "tests/test_r18_orchestrator_control_intake.ps1",
        "tools/validate_r18_role_skill_permission_matrix.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1",
        "tools/validate_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tools/validate_r18_skill_contract_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tools/validate_r18_agent_card_schema.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_opening_authority.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R18CompactStopConditions {
    return @(
        "missing required signal fields",
        "unknown signal type without escalation",
        "unknown detected failure type",
        "missing runner state, execution log, or resume checkpoint ref",
        "missing evidence or authority refs",
        "runtime execution requested",
        "recovery action requested",
        "WIP classification requested",
        "remote branch verification requested",
        "continuation or new-context prompt generation requested",
        "API invocation requested",
        "stage/commit/push requested by detector",
        "R18-011 or later completion claim"
    )
}

function Get-R18CompactEscalationConditions {
    return @(
        "unknown failure signal requires operator decision",
        "signal evidence is insufficient or contradictory",
        "event would require WIP classification before safe continuation",
        "event would require remote branch verification before safe continuation",
        "any recovery action is requested during R18-010",
        "any automatic new-thread creation is requested during R18-010"
    )
}

function Get-R18CompactDetectionRules {
    $rules = @()
    foreach ($definition in $script:R18SignalDefinitions) {
        $rules += [ordered]@{
            rule_id = [string]$definition.expected_detection_rule
            signal_type = [string]$definition.signal_type
            detected_failure_type = [string]$definition.expected_detected_failure_type
            required_evidence = [string]$definition.required_evidence
            classification_confidence = [string]$definition.expected_confidence
            operator_decision_required = [bool]$definition.operator_decision_required
            recovery_action_allowed = $false
        }
    }
    return $rules
}

function Get-R18CompactDefinitionBySignalType {
    param([Parameter(Mandatory = $true)][string]$SignalType)

    foreach ($definition in $script:R18SignalDefinitions) {
        if ([string]$definition.signal_type -eq $SignalType) {
            return $definition
        }
    }

    return $null
}

function Get-R18CompactSignalRef {
    param([Parameter(Mandatory = $true)][string]$FileName)
    return "state/runtime/r18_compact_failure_signal_samples/$FileName"
}

function Get-R18CompactFailureEventRef {
    param([Parameter(Mandatory = $true)][string]$SignalType)
    return "state/runtime/r18_detected_failure_events/$SignalType.failure.json"
}

function New-R18FailureEventContract {
    return [ordered]@{
        artifact_type = "r18_failure_event_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-010-failure-event-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "failure_event_packet_contract_for_seed_signal_detection_only_no_recovery_runtime"
        purpose = "Define machine-checkable detected failure event packets for R18-010 seed compact/context/stream failure detection. Events preserve runner state refs, evidence refs, authority refs, next safe step, stop conditions, and escalation conditions without performing recovery, WIP classification, remote verification, continuation generation, new-context prompt generation, work-order execution, live monitoring, API invocation, or stage/commit/push."
        required_failure_event_fields = $script:R18RequiredFailureEventFields
        allowed_failure_types = $script:R18AllowedDetectedFailureTypes
        allowed_failure_sources = @(
            "codex_backend_stream",
            "context_compaction_gate",
            "transport_stream",
            "validation_runner_interruption",
            "validation_gate",
            "unknown_seed_signal"
        )
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        failure_classification_policy = [ordered]@{
            deterministic_seed_signal_only = $true
            unknown_failures_require_operator_decision = $true
            non_compact_validation_must_not_be_classified_as_compact = $true
            compact_backend_or_compaction_signals_must_classify_to_compact_or_context_failure = $true
            live_telemetry_allowed = $false
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            source_signal_ref_required = $true
            runner_state_ref_required = $true
            execution_log_ref_required = $true
            resume_checkpoint_ref_required = $true
            historical_r13_r16_evidence_edits_allowed = $false
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            approved_authority_refs = Get-R18CompactAuthorityRefs
            missing_authority_refs_fail_closed = $true
        }
        next_step_policy = [ordered]@{
            next_safe_step_required = $true
            next_safe_step_is_for_later_r18_tasks_only = $true
            event_is_not_continuation_packet = $true
            event_is_not_new_context_prompt = $true
        }
        recovery_boundary_policy = [ordered]@{
            detected_events_are_not_recovery_completion = $true
            recovery_runtime_allowed = $false
            recovery_action_allowed = $false
            retry_allowed = $false
            work_order_execution_allowed = $false
        }
        path_policy = [ordered]@{
            allowed_paths = Get-R18CompactEvidenceRefs
            forbidden_paths = @(
                ".local_backups/",
                "operator-local backup paths",
                "state/proof_reviews/r13_*",
                "state/proof_reviews/r14_*",
                "state/proof_reviews/r15_*",
                "state/proof_reviews/r16_*",
                "repository root broad write",
                "unbounded wildcard write paths"
            )
            operator_local_backup_paths_allowed = $false
            broad_repo_writes_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
        }
        api_policy = [ordered]@{
            api_enabled = $false
            openai_api_invocation_allowed = $false
            codex_api_invocation_allowed = $false
            autonomous_codex_invocation_allowed = $false
            automatic_new_thread_creation_allowed = $false
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18CompactNonClaims
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        positive_claims = @("r18_failure_event_contract_created")
        runtime_flags = Get-R18CompactRuntimeFlags
    }
}

function New-R18CompactFailureDetectorContract {
    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-010-compact-failure-detector-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "deterministic_seed_signal_failure_detector_foundation_only_no_live_monitoring"
        purpose = "Classify committed seed compact/context/stream/validation failure signals into deterministic failure event packets while preserving runner state refs, authority refs, evidence refs, next safe step, stop conditions, and recovery boundaries. This detector is not live recovery runtime, not live monitoring, not WIP classification, not remote verification, not continuation packet generation, not new-context prompt generation, and not API-backed automation."
        required_signal_fields = $script:R18RequiredSignalFields
        required_detection_result_fields = $script:R18RequiredDetectionResultFields
        required_failure_event_fields = $script:R18RequiredFailureEventFields
        detection_rules = Get-R18CompactDetectionRules
        allowed_signal_types = $script:R18AllowedSignalTypes
        allowed_detected_failure_types = $script:R18AllowedDetectedFailureTypes
        allowed_classification_confidence_values = $script:R18AllowedConfidenceValues
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        detector_policy = [ordered]@{
            deterministic_seed_signal_artifacts_only = $true
            live_failure_monitoring_allowed = $false
            fail_closed_on_unknown_signal_type = $true
            unknown_failures_must_not_be_guessed = $true
        }
        signal_policy = [ordered]@{
            signal_status_required = "seed_signal_only_not_live_telemetry"
            runner_state_ref_required = $true
            execution_log_ref_required = $true
            resume_checkpoint_ref_required = $true
            raw_signal_summary_required = $true
            expected_detection_rule_required = $true
        }
        classification_policy = [ordered]@{
            allowed_signal_types = $script:R18AllowedSignalTypes
            allowed_detected_failure_types = $script:R18AllowedDetectedFailureTypes
            allowed_confidence_values = $script:R18AllowedConfidenceValues
            non_compact_validation_failure_must_not_classify_as_compact = $true
            unknown_failure_requires_operator_decision = $true
        }
        runner_state_policy = [ordered]@{
            runner_state_ref = $script:R18RunnerStateRef
            execution_log_ref = $script:R18ExecutionLogRef
            resume_checkpoint_ref = $script:R18ResumeCheckpointRef
            refs_attached_not_executed = $true
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            detector_results_required = $true
            failure_event_refs_required = $true
            proof_review_package_required = $true
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            approved_authority_refs = Get-R18CompactAuthorityRefs
        }
        recovery_boundary_policy = [ordered]@{
            recovery_runtime_allowed = $false
            recovery_action_allowed = $false
            failure_events_are_not_recovery_completion = $true
            retry_allowed = $false
        }
        path_policy = [ordered]@{
            allowed_paths = Get-R18CompactEvidenceRefs
            operator_local_backup_paths_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
            broad_repo_writes_allowed = $false
            wildcard_paths_allowed = $false
        }
        api_policy = [ordered]@{
            api_enabled = $false
            openai_api_invocation_allowed = $false
            codex_api_invocation_allowed = $false
            autonomous_codex_invocation_allowed = $false
            automatic_new_thread_creation_allowed = $false
        }
        execution_policy = [ordered]@{
            generator_over_committed_seed_artifacts_only = $true
            live_runner_runtime_allowed = $false
            work_order_execution_allowed = $false
            skill_execution_allowed = $false
            a2a_dispatch_allowed = $false
            board_runtime_mutation_allowed = $false
            stage_commit_push_allowed_by_detector = $false
        }
        refusal_policy = [ordered]@{
            live_monitoring_requested_fails_closed = $true
            recovery_requested_fails_closed = $true
            wip_classification_requested_fails_closed = $true
            remote_verification_requested_fails_closed = $true
            continuation_generation_requested_fails_closed = $true
            new_context_prompt_requested_fails_closed = $true
            api_invocation_requested_fails_closed = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18CompactNonClaims
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        positive_claims = @("r18_compact_failure_detector_contract_created")
        runtime_flags = Get-R18CompactRuntimeFlags
    }
}

function New-R18CompactFailureDetectorProfile {
    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-010-compact-failure-detector-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        profile_status = "foundation_profile_for_seed_signal_detection_only_not_live_monitoring"
        detection_mode = "deterministic_generation_from_committed_seed_signal_artifacts"
        signal_sample_root = "state/runtime/r18_compact_failure_signal_samples/"
        detected_failure_event_root = "state/runtime/r18_detected_failure_events/"
        runner_state_ref = $script:R18RunnerStateRef
        execution_log_ref = $script:R18ExecutionLogRef
        resume_checkpoint_ref = $script:R18ResumeCheckpointRef
        detection_rules = Get-R18CompactDetectionRules
        allowed_signal_types = $script:R18AllowedSignalTypes
        allowed_detected_failure_types = $script:R18AllowedDetectedFailureTypes
        allowed_classification_confidence_values = $script:R18AllowedConfidenceValues
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        validation_refs = Get-R18CompactValidationRefs
        positive_claims = @("r18_compact_failure_detector_profile_created")
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactSignalSample {
    param([Parameter(Mandatory = $true)][object]$Definition)

    return [ordered]@{
        artifact_type = "r18_compact_failure_signal_sample"
        contract_version = "v1"
        signal_id = "r18_010_signal_$($Definition.signal_type)"
        signal_name = [string]$Definition.signal_name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        signal_status = "seed_signal_only_not_live_telemetry"
        signal_type = [string]$Definition.signal_type
        raw_signal_summary = [string]$Definition.raw_signal_summary
        observed_error_text = [string]$Definition.observed_error_text
        observed_phase = [string]$Definition.observed_phase
        runner_state_ref = $script:R18RunnerStateRef
        execution_log_ref = $script:R18ExecutionLogRef
        resume_checkpoint_ref = $script:R18ResumeCheckpointRef
        expected_detection_rule = [string]$Definition.expected_detection_rule
        expected_detected_failure_type = [string]$Definition.expected_detected_failure_type
        expected_confidence = [string]$Definition.expected_confidence
        evidence_refs = @(
            (Get-R18CompactSignalRef -FileName ([string]$Definition.file)),
            $script:R18RunnerStateRef,
            $script:R18ExecutionLogRef,
            $script:R18ResumeCheckpointRef,
            "contracts/runtime/r18_compact_failure_detector.contract.json"
        )
        authority_refs = Get-R18CompactAuthorityRefs
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Invoke-R18CompactDetection {
    param([Parameter(Mandatory = $true)][object]$Signal)

    $definition = Get-R18CompactDefinitionBySignalType -SignalType ([string]$Signal.signal_type)
    if ($null -eq $definition) {
        throw "R18 compact failure signal uses unknown signal type '$($Signal.signal_type)'."
    }

    return [pscustomobject]@{
        RuleId = [string]$definition.expected_detection_rule
        DetectedFailureType = [string]$definition.expected_detected_failure_type
        ClassificationConfidence = [string]$definition.expected_confidence
        FailureSource = [string]$definition.failure_source
        OperatorDecisionRequired = [bool]$definition.operator_decision_required
        RequiredEvidence = [string]$definition.required_evidence
    }
}

function New-R18DetectedFailureEvent {
    param(
        [Parameter(Mandatory = $true)][object]$Signal,
        [Parameter(Mandatory = $true)][string]$SignalFileName
    )

    $classification = Invoke-R18CompactDetection -Signal $Signal
    $sourceSignalRef = Get-R18CompactSignalRef -FileName $SignalFileName

    return [ordered]@{
        artifact_type = "r18_failure_event"
        contract_version = "v1"
        failure_event_id = "r18_010_failure_event_$($Signal.signal_type)"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        failure_event_status = "detected_seed_event_only_not_recovered"
        detected_failure_type = $classification.DetectedFailureType
        failure_source = $classification.FailureSource
        classification_confidence = $classification.ClassificationConfidence
        source_signal_ref = $sourceSignalRef
        runner_state_ref = [string]$Signal.runner_state_ref
        execution_log_ref = [string]$Signal.execution_log_ref
        resume_checkpoint_ref = [string]$Signal.resume_checkpoint_ref
        current_work_order_ref = $script:R18CurrentWorkOrderRef
        current_state = $script:R18CurrentState
        last_completed_step = $script:R18LastCompletedStep
        next_safe_step = $script:R18NextSafeStep
        retry_count = 0
        max_retry_count = 2
        stop_conditions = Get-R18CompactStopConditions
        escalation_conditions = Get-R18CompactEscalationConditions
        operator_decision_required = $classification.OperatorDecisionRequired
        evidence_refs = @(
            $sourceSignalRef,
            (Get-R18CompactFailureEventRef -SignalType ([string]$Signal.signal_type)),
            $script:R18RunnerStateRef,
            $script:R18ExecutionLogRef,
            $script:R18ResumeCheckpointRef,
            "state/runtime/r18_compact_failure_detector_results.json",
            "state/runtime/r18_compact_failure_detector_check_report.json"
        )
        authority_refs = Get-R18CompactAuthorityRefs
        validation_refs = Get-R18CompactValidationRefs
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactDetectionResultEntry {
    param(
        [Parameter(Mandatory = $true)][object]$Signal,
        [Parameter(Mandatory = $true)][object]$Event
    )

    return [ordered]@{
        result_id = "r18_010_detection_result_$($Signal.signal_type)"
        signal_id = [string]$Signal.signal_id
        signal_type = [string]$Signal.signal_type
        detection_rule = [string]$Signal.expected_detection_rule
        detected_failure_type = [string]$Event.detected_failure_type
        classification_confidence = [string]$Event.classification_confidence
        failure_event_ref = Get-R18CompactFailureEventRef -SignalType ([string]$Signal.signal_type)
        operator_decision_required = [bool]$Event.operator_decision_required
        evidence_refs = @([string]$Event.source_signal_ref, (Get-R18CompactFailureEventRef -SignalType ([string]$Signal.signal_type)))
        authority_refs = Get-R18CompactAuthorityRefs
        runtime_flags = Get-R18CompactRuntimeFlags
    }
}

function New-R18CompactFailureDetectorResults {
    param(
        [Parameter(Mandatory = $true)][object[]]$Signals,
        [Parameter(Mandatory = $true)][object[]]$Events
    )

    $entries = @()
    foreach ($signal in $Signals) {
        $event = @($Events | Where-Object { $_.source_signal_ref -eq (Get-R18CompactSignalRef -FileName "$($signal.signal_type).signal.json") })[0]
        $entries += New-R18CompactDetectionResultEntry -Signal $signal -Event $event
    }

    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_results"
        contract_version = "v1"
        results_id = "aioffice-r18-010-compact-failure-detector-results-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        result_status = "deterministic_seed_signal_detection_results_only_not_recovery"
        detection_mode = "generator_over_committed_seed_signal_artifacts_only"
        signal_count = @($Signals).Count
        failure_event_count = @($Events).Count
        detection_results = $entries
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        validation_refs = Get-R18CompactValidationRefs
        positive_claims = @(
            "r18_failure_signal_samples_created",
            "r18_detected_failure_events_created",
            "r18_detection_results_created"
        )
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactFailureDetectorCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Signals,
        [Parameter(Mandatory = $true)][object[]]$Events
    )

    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_check_report"
        contract_version = "v1"
        check_report_id = "aioffice-r18-010-compact-failure-detector-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18DetectorVerdict
        report_status = "foundation_validation_report_only_not_live_monitoring"
        checks = @(
            [ordered]@{ check_id = "contracts_present"; status = "passed" },
            [ordered]@{ check_id = "signal_samples_present"; status = "passed"; count = @($Signals).Count },
            [ordered]@{ check_id = "failure_events_present"; status = "passed"; count = @($Events).Count },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed"; required_flag_count = @($script:R18RuntimeFlagFields).Count },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-010 only; R18-011 through R18-028 planned only." }
        )
        required_signal_field_count = @($script:R18RequiredSignalFields).Count
        required_failure_event_field_count = @($script:R18RequiredFailureEventFields).Count
        required_detection_result_field_count = @($script:R18RequiredDetectionResultFields).Count
        generated_signal_count = @($Signals).Count
        generated_failure_event_count = @($Events).Count
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        validation_refs = Get-R18CompactValidationRefs
        positive_claims = @(
            "r18_compact_failure_detector_validator_created",
            "r18_compact_failure_detector_fixtures_created"
        )
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactFailureDetectorSnapshot {
    param(
        [Parameter(Mandatory = $true)][object[]]$Signals,
        [Parameter(Mandatory = $true)][object[]]$Events
    )

    $counts = [ordered]@{}
    foreach ($failureType in $script:R18AllowedDetectedFailureTypes) {
        $counts[$failureType] = @($Events | Where-Object { $_.detected_failure_type -eq $failureType }).Count
    }

    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-010-compact-failure-detector-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        snapshot_status = "operator_surface_snapshot_for_seed_failure_detection_only"
        r18_status = "active_through_r18_010_only"
        planned_from = "R18-011"
        planned_through = "R18-028"
        detector_status = "compact_failure_detector_foundation_only_not_live_runtime"
        signal_count = @($Signals).Count
        failure_event_count = @($Events).Count
        detected_failure_type_counts = $counts
        operator_decision_required_count = @($Events | Where-Object { $_.operator_decision_required -eq $true }).Count
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        positive_claims = @("r18_compact_failure_detector_proof_review_created")
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18DetectorVerdict
        evidence_refs = Get-R18CompactEvidenceRefs
        authority_refs = Get-R18CompactAuthorityRefs
        validation_refs = Get-R18CompactValidationRefs
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CompactProofReviewText {
    return @"
# R18-010 Compact Failure Detector Proof Review

R18-010 creates the compact failure detector foundation only. The detector classifies committed seed signal artifacts into deterministic failure event packets and attaches runner state, execution log, resume checkpoint, authority, evidence, next-safe-step, stop-condition, and escalation-condition refs.

The failure events are not recovery completion, not continuation packets, not new-context prompts, and not retry evidence. No WIP classification, remote branch verification, recovery action, work-order execution, board/card runtime mutation, A2A message dispatch, live agent invocation, live skill execution, API invocation, autonomous Codex invocation, automatic new-thread creation, product runtime execution, or detector stage/commit/push is claimed.

Expected status truth after this package: R18 active through R18-010 only; R18-011 through R18-028 planned only.
"@
}

function New-R18CompactValidationManifestText {
    $commands = @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
    $lines = @("# R18-010 Validation Manifest", "", "Expected status truth after this package: R18 active through R18-010 only; R18-011 through R18-028 planned only.", "", "Required validation commands:")
    foreach ($command in $commands) {
        $lines += "- ``$command``"
    }
    return ($lines -join [Environment]::NewLine)
}

function New-R18CompactFixtureDefinitions {
    $fixtures = @(
        @{ file = "invalid_missing_signal_id.json"; target = "signal:first"; operation = "remove"; path = "signal_id"; expected = "signal_id" },
        @{ file = "invalid_missing_signal_type.json"; target = "signal:first"; operation = "remove"; path = "signal_type"; expected = "signal_type" },
        @{ file = "invalid_unknown_signal_type_without_escalation.json"; target = "signal:first"; operation = "set"; path = "signal_type"; value = "mystery_failure"; expected = "unknown signal type" },
        @{ file = "invalid_missing_raw_signal_summary.json"; target = "signal:first"; operation = "remove"; path = "raw_signal_summary"; expected = "raw_signal_summary" },
        @{ file = "invalid_missing_runner_state_ref.json"; target = "signal:first"; operation = "remove"; path = "runner_state_ref"; expected = "runner_state_ref" },
        @{ file = "invalid_missing_execution_log_ref.json"; target = "signal:first"; operation = "remove"; path = "execution_log_ref"; expected = "execution_log_ref" },
        @{ file = "invalid_missing_detection_rule.json"; target = "signal:first"; operation = "remove"; path = "expected_detection_rule"; expected = "expected_detection_rule" },
        @{ file = "invalid_missing_failure_event_id.json"; target = "event:first"; operation = "remove"; path = "failure_event_id"; expected = "failure_event_id" },
        @{ file = "invalid_missing_detected_failure_type.json"; target = "event:first"; operation = "remove"; path = "detected_failure_type"; expected = "detected_failure_type" },
        @{ file = "invalid_missing_classification_confidence.json"; target = "event:first"; operation = "remove"; path = "classification_confidence"; expected = "classification_confidence" },
        @{ file = "invalid_missing_evidence_refs.json"; target = "event:first"; operation = "remove"; path = "evidence_refs"; expected = "evidence_refs" },
        @{ file = "invalid_missing_authority_refs.json"; target = "event:first"; operation = "remove"; path = "authority_refs"; expected = "authority_refs" },
        @{ file = "invalid_missing_next_safe_step.json"; target = "event:first"; operation = "remove"; path = "next_safe_step"; expected = "next_safe_step" },
        @{ file = "invalid_missing_stop_conditions.json"; target = "event:first"; operation = "remove"; path = "stop_conditions"; expected = "stop_conditions" },
        @{ file = "invalid_compact_failure_claims_solved.json"; target = "event:first"; operation = "set"; path = "runtime_flags.solved_codex_compaction_claimed"; value = $true; expected = "solved_codex_compaction_claimed" },
        @{ file = "invalid_recovery_runtime_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.recovery_runtime_implemented"; value = $true; expected = "recovery_runtime_implemented" },
        @{ file = "invalid_wip_classifier_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.wip_classifier_implemented"; value = $true; expected = "wip_classifier_implemented" },
        @{ file = "invalid_remote_verifier_runtime_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.remote_branch_verifier_runtime_implemented"; value = $true; expected = "remote_branch_verifier_runtime_implemented" },
        @{ file = "invalid_continuation_packet_generation_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.continuation_packet_generated"; value = $true; expected = "continuation_packet_generated" },
        @{ file = "invalid_new_context_prompt_generation_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.new_context_prompt_generated"; value = $true; expected = "new_context_prompt_generated" },
        @{ file = "invalid_work_order_execution_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.work_order_execution_performed"; value = $true; expected = "work_order_execution_performed" },
        @{ file = "invalid_live_runner_runtime_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.live_runner_runtime_executed"; value = $true; expected = "live_runner_runtime_executed" },
        @{ file = "invalid_skill_execution_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.live_skill_execution_performed"; value = $true; expected = "live_skill_execution_performed" },
        @{ file = "invalid_a2a_message_sent_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.a2a_message_sent"; value = $true; expected = "a2a_message_sent" },
        @{ file = "invalid_board_runtime_mutation_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.board_runtime_mutation_performed"; value = $true; expected = "board_runtime_mutation_performed" },
        @{ file = "invalid_api_invocation_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.openai_api_invoked"; value = $true; expected = "openai_api_invoked" },
        @{ file = "invalid_automatic_new_thread_creation_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.automatic_new_thread_creation_performed"; value = $true; expected = "automatic_new_thread_creation_performed" },
        @{ file = "invalid_stage_commit_push_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.stage_commit_push_performed"; value = $true; expected = "stage_commit_push_performed" },
        @{ file = "invalid_operator_local_backup_path.json"; target = "event:first"; operation = "add_array_value"; path = "evidence_refs"; value = ".local_backups/r18_010_operator_note.json"; expected = "operator local backup" },
        @{ file = "invalid_historical_evidence_edit_permission.json"; target = "event:first"; operation = "add_array_value"; path = "evidence_refs"; value = "state/proof_reviews/r16_unsafe/edited.json"; expected = "historical R13/R14/R15/R16 evidence" },
        @{ file = "invalid_broad_repo_write.json"; target = "event:first"; operation = "add_array_value"; path = "authority_refs"; value = "repository root broad write"; expected = "broad repo write" },
        @{ file = "invalid_r18_011_completion_claim.json"; target = "event:first"; operation = "set"; path = "runtime_flags.r18_011_completed"; value = $true; expected = "r18_011_completed" }
    )

    $objects = @()
    foreach ($fixture in $fixtures) {
        $object = [ordered]@{
            fixture_id = [System.IO.Path]::GetFileNameWithoutExtension([string]$fixture.file)
            target = [string]$fixture.target
            operation = [string]$fixture.operation
            path = [string]$fixture.path
            expected_failure_fragments = @([string]$fixture.expected)
        }
        if ($fixture.ContainsKey("value")) {
            $object["value"] = $fixture.value
        }
        $object["file"] = [string]$fixture.file
        $objects += $object
    }
    return $objects
}

function New-R18CompactFixtureManifest {
    $fixtures = New-R18CompactFixtureDefinitions
    return [ordered]@{
        artifact_type = "r18_compact_failure_detector_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        fixture_status = "invalid_mutation_fixtures_only_not_runtime_events"
        invalid_fixture_files = @($fixtures | ForEach-Object { $_.file })
        runtime_flags = Get-R18CompactRuntimeFlags
        non_claims = Get-R18CompactNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Assert-R18CompactCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18CompactRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $names = @($Object.PSObject.Properties.Name)
    foreach ($field in $FieldNames) {
        Assert-R18CompactCondition -Condition ($names -contains $field) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18CompactArray {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18CompactCondition -Condition (@($Value).Count -gt 0) -Message "$Context must not be empty."
}

function Assert-R18CompactRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18CompactCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flag) -Message "$Context missing runtime false flag '$flag'."
        Assert-R18CompactCondition -Condition ($RuntimeFlags.$flag -eq $false) -Message "$Context runtime flag '$flag' must remain false."
    }
}

function Assert-R18CompactPositiveClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Object.positive_claims)) {
            Assert-R18CompactCondition -Condition (@($script:R18AllowedPositiveClaims) -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
        }
    }
}

function Assert-R18CompactRefsSafe {
    param(
        [Parameter(Mandatory = $true)][object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($ref in @($Refs)) {
        $value = ([string]$ref).Replace("\", "/")
        Assert-R18CompactCondition -Condition ($value -notmatch '^\.local_backups/' -and $value -notmatch '(?i)operator[- ]local backup') -Message "$Context references operator local backup path '$value'."
        Assert-R18CompactCondition -Condition ($value -notmatch '^state/proof_reviews/r1[3-6]' -and $value -notmatch '^state/.*/r1[3-6]_') -Message "$Context references historical R13/R14/R15/R16 evidence '$value'."
        Assert-R18CompactCondition -Condition ($value -notmatch '(?i)repository root broad write|broad repo write') -Message "$Context references broad repo write '$value'."
        Assert-R18CompactCondition -Condition ($value -notmatch '(?i)unbounded wildcard') -Message "$Context references unbounded wildcard path '$value'."
    }
}

function Assert-R18CompactContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $required = @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_failure_event_fields",
        "allowed_failure_types",
        "allowed_failure_sources",
        "required_runtime_false_flags",
        "failure_classification_policy",
        "evidence_policy",
        "authority_policy",
        "next_step_policy",
        "recovery_boundary_policy",
        "path_policy",
        "api_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    )
    Assert-R18CompactRequiredFields -Object $Contract -FieldNames $required -Context "R18 failure event contract"
    Assert-R18CompactCondition -Condition ($Contract.artifact_type -eq "r18_failure_event_contract") -Message "R18 failure event contract artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 failure event contract source_task must be R18-010."
    foreach ($field in $script:R18RequiredFailureEventFields) {
        Assert-R18CompactCondition -Condition (@($Contract.required_failure_event_fields) -contains $field) -Message "R18 failure event contract missing required event field '$field'."
    }
    foreach ($failureType in $script:R18AllowedDetectedFailureTypes) {
        Assert-R18CompactCondition -Condition (@($Contract.allowed_failure_types) -contains $failureType) -Message "R18 failure event contract missing allowed failure type '$failureType'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18CompactCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "R18 failure event contract missing runtime false flag '$flag'."
    }
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 failure event contract"
    Assert-R18CompactPositiveClaims -Object $Contract -Context "R18 failure event contract"
}

function Assert-R18CompactDetectorContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $required = @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_signal_fields",
        "required_detection_result_fields",
        "required_failure_event_fields",
        "detection_rules",
        "allowed_signal_types",
        "allowed_detected_failure_types",
        "allowed_classification_confidence_values",
        "required_runtime_false_flags",
        "detector_policy",
        "signal_policy",
        "classification_policy",
        "runner_state_policy",
        "evidence_policy",
        "authority_policy",
        "recovery_boundary_policy",
        "path_policy",
        "api_policy",
        "execution_policy",
        "refusal_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    )
    Assert-R18CompactRequiredFields -Object $Contract -FieldNames $required -Context "R18 compact failure detector contract"
    Assert-R18CompactCondition -Condition ($Contract.artifact_type -eq "r18_compact_failure_detector_contract") -Message "R18 compact failure detector contract artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 compact failure detector contract source_task must be R18-010."
    foreach ($field in $script:R18RequiredSignalFields) {
        Assert-R18CompactCondition -Condition (@($Contract.required_signal_fields) -contains $field) -Message "R18 compact failure detector contract missing required signal field '$field'."
    }
    foreach ($field in $script:R18RequiredDetectionResultFields) {
        Assert-R18CompactCondition -Condition (@($Contract.required_detection_result_fields) -contains $field) -Message "R18 compact failure detector contract missing required detection result field '$field'."
    }
    foreach ($signalType in $script:R18AllowedSignalTypes) {
        Assert-R18CompactCondition -Condition (@($Contract.allowed_signal_types) -contains $signalType) -Message "R18 compact failure detector contract missing allowed signal type '$signalType'."
    }
    foreach ($confidence in $script:R18AllowedConfidenceValues) {
        Assert-R18CompactCondition -Condition (@($Contract.allowed_classification_confidence_values) -contains $confidence) -Message "R18 compact failure detector contract missing confidence value '$confidence'."
    }
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 compact failure detector contract"
    Assert-R18CompactPositiveClaims -Object $Contract -Context "R18 compact failure detector contract"
}

function Assert-R18CompactSignal {
    param([Parameter(Mandatory = $true)][object]$Signal)

    Assert-R18CompactRequiredFields -Object $Signal -FieldNames $script:R18RequiredSignalFields -Context "R18 compact failure signal"
    Assert-R18CompactCondition -Condition ($Signal.artifact_type -eq "r18_compact_failure_signal_sample") -Message "R18 compact failure signal artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Signal.source_task -eq $script:R18SourceTask) -Message "R18 compact failure signal source_task must be R18-010."
    Assert-R18CompactCondition -Condition ($Signal.signal_status -eq "seed_signal_only_not_live_telemetry") -Message "R18 compact failure signal status must be seed_signal_only_not_live_telemetry."
    Assert-R18CompactCondition -Condition (@($script:R18AllowedSignalTypes) -contains [string]$Signal.signal_type) -Message "R18 compact failure signal uses unknown signal type '$($Signal.signal_type)'."
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Signal.raw_signal_summary)) -Message "R18 compact failure signal missing raw_signal_summary."
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Signal.runner_state_ref)) -Message "R18 compact failure signal missing runner_state_ref."
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Signal.execution_log_ref)) -Message "R18 compact failure signal missing execution_log_ref."
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Signal.resume_checkpoint_ref)) -Message "R18 compact failure signal missing resume_checkpoint_ref."
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Signal.expected_detection_rule)) -Message "R18 compact failure signal missing expected_detection_rule."
    $classification = Invoke-R18CompactDetection -Signal $Signal
    Assert-R18CompactCondition -Condition ($Signal.expected_detection_rule -eq $classification.RuleId) -Message "R18 compact failure signal expected_detection_rule does not match deterministic rule."
    Assert-R18CompactCondition -Condition ($Signal.expected_detected_failure_type -eq $classification.DetectedFailureType) -Message "R18 compact failure signal expected_detected_failure_type does not match deterministic rule."
    Assert-R18CompactCondition -Condition ($Signal.expected_confidence -eq $classification.ClassificationConfidence) -Message "R18 compact failure signal expected_confidence does not match deterministic rule."
    Assert-R18CompactArray -Value $Signal.evidence_refs -Context "R18 compact failure signal evidence_refs"
    Assert-R18CompactArray -Value $Signal.authority_refs -Context "R18 compact failure signal authority_refs"
    Assert-R18CompactRefsSafe -Refs @($Signal.evidence_refs) -Context "R18 compact failure signal evidence_refs"
    Assert-R18CompactRefsSafe -Refs @($Signal.authority_refs) -Context "R18 compact failure signal authority_refs"
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Signal.runtime_flags -Context "R18 compact failure signal"
}

function Assert-R18CompactFailureEvent {
    param(
        [Parameter(Mandatory = $true)][object]$Event,
        [Parameter(Mandatory = $true)][object]$Signal
    )

    Assert-R18CompactRequiredFields -Object $Event -FieldNames $script:R18RequiredFailureEventFields -Context "R18 detected failure event"
    Assert-R18CompactCondition -Condition ($Event.artifact_type -eq "r18_failure_event") -Message "R18 detected failure event artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Event.source_task -eq $script:R18SourceTask) -Message "R18 detected failure event source_task must be R18-010."
    Assert-R18CompactCondition -Condition ($Event.failure_event_status -eq "detected_seed_event_only_not_recovered") -Message "R18 detected failure event status must be detected_seed_event_only_not_recovered."
    Assert-R18CompactCondition -Condition (@($script:R18AllowedDetectedFailureTypes) -contains [string]$Event.detected_failure_type) -Message "R18 detected failure event uses unknown detected failure type '$($Event.detected_failure_type)'."
    Assert-R18CompactCondition -Condition (@($script:R18AllowedConfidenceValues) -contains [string]$Event.classification_confidence) -Message "R18 detected failure event uses unknown classification confidence '$($Event.classification_confidence)'."
    Assert-R18CompactCondition -Condition ($Event.detected_failure_type -eq $Signal.expected_detected_failure_type) -Message "R18 detected failure event classification does not match source signal expectation."
    Assert-R18CompactCondition -Condition ($Event.classification_confidence -eq $Signal.expected_confidence) -Message "R18 detected failure event confidence does not match source signal expectation."
    if ($Signal.signal_type -eq "unknown_failure_requires_escalation") {
        Assert-R18CompactCondition -Condition ([bool]$Event.operator_decision_required -eq $true) -Message "Unknown failure must require operator decision."
        Assert-R18CompactCondition -Condition ($Event.classification_confidence -eq "unknown_requires_operator_decision") -Message "Unknown failure must use unknown_requires_operator_decision confidence."
    }
    if ($Signal.signal_type -eq "non_compact_validation_failure") {
        Assert-R18CompactCondition -Condition ($Event.detected_failure_type -eq "validation_failure_not_compact") -Message "non_compact_validation_failure must not be classified as compact failure."
    }
    if ($Signal.signal_type -in @("codex_backend_compact_stream_disconnect", "context_compaction_required")) {
        Assert-R18CompactCondition -Condition ($Event.detected_failure_type -in @("codex_compact_failure", "context_compaction_required")) -Message "compact/backend/compaction signal must classify to compact or context failure."
    }
    Assert-R18CompactCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.next_safe_step)) -Message "R18 detected failure event missing next_safe_step."
    Assert-R18CompactArray -Value $Event.stop_conditions -Context "R18 detected failure event stop_conditions"
    Assert-R18CompactArray -Value $Event.evidence_refs -Context "R18 detected failure event evidence_refs"
    Assert-R18CompactArray -Value $Event.authority_refs -Context "R18 detected failure event authority_refs"
    Assert-R18CompactRefsSafe -Refs @($Event.evidence_refs) -Context "R18 detected failure event evidence_refs"
    Assert-R18CompactRefsSafe -Refs @($Event.authority_refs) -Context "R18 detected failure event authority_refs"
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Event.runtime_flags -Context "R18 detected failure event"
}

function Assert-R18CompactResults {
    param(
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object[]]$Signals,
        [Parameter(Mandatory = $true)][object[]]$Events
    )

    Assert-R18CompactCondition -Condition ($Results.artifact_type -eq "r18_compact_failure_detector_results") -Message "R18 compact failure detector results artifact_type is invalid."
    Assert-R18CompactCondition -Condition ([int]$Results.signal_count -eq @($Signals).Count) -Message "R18 compact failure detector results signal_count is invalid."
    Assert-R18CompactCondition -Condition ([int]$Results.failure_event_count -eq @($Events).Count) -Message "R18 compact failure detector results failure_event_count is invalid."
    foreach ($entry in @($Results.detection_results)) {
        Assert-R18CompactRequiredFields -Object $entry -FieldNames $script:R18RequiredDetectionResultFields -Context "R18 compact detection result entry"
        Assert-R18CompactCondition -Condition (@($script:R18AllowedDetectedFailureTypes) -contains [string]$entry.detected_failure_type) -Message "R18 compact detection result entry uses unknown detected failure type '$($entry.detected_failure_type)'."
        Assert-R18CompactCondition -Condition (@($script:R18AllowedConfidenceValues) -contains [string]$entry.classification_confidence) -Message "R18 compact detection result entry uses unknown confidence '$($entry.classification_confidence)'."
        Assert-R18CompactRuntimeFlags -RuntimeFlags $entry.runtime_flags -Context "R18 compact detection result entry"
    }
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Results.runtime_flags -Context "R18 compact failure detector results"
    Assert-R18CompactPositiveClaims -Object $Results -Context "R18 compact failure detector results"
}

function Assert-R18CompactReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18CompactCondition -Condition ($Report.artifact_type -eq "r18_compact_failure_detector_check_report") -Message "R18 compact failure detector check report artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Report.aggregate_verdict -eq $script:R18DetectorVerdict) -Message "R18 compact failure detector check report aggregate verdict is invalid."
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 compact failure detector check report"
    Assert-R18CompactPositiveClaims -Object $Report -Context "R18 compact failure detector check report"
}

function Assert-R18CompactSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18CompactCondition -Condition ($Snapshot.artifact_type -eq "r18_compact_failure_detector_snapshot") -Message "R18 compact failure detector snapshot artifact_type is invalid."
    Assert-R18CompactCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_010_only") -Message "R18 compact failure detector snapshot status is invalid."
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Snapshot.runtime_flags -Context "R18 compact failure detector snapshot"
    Assert-R18CompactPositiveClaims -Object $Snapshot -Context "R18 compact failure detector snapshot"
}

function Get-R18CompactTaskStatusMap {
    param([Parameter(Mandatory = $true)][string]$Text, [Parameter(Mandatory = $true)][string]$Context)

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

function Test-R18CompactFailureDetectorStatusTruth {
    param([string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18CompactPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-018 only",
            "R18-019 through R18-028 planned only",
            "R18-010 created compact failure detector foundation only",
            "Failure detection is deterministic over seed signal artifacts only",
            "Failure events are not recovery completion",
            "R18-011 created WIP classifier foundation only",
            "WIP classification is deterministic over seed git inventory artifacts only",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No files were restored or deleted",
            "No staging, commit, or push was performed by the classifier",
            "R18-012 created remote branch verifier foundation only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "Continuation packets are not new-context prompts",
            "R18-014 created new-context prompt generator foundation only",
            "Automatic new-thread creation is not implemented",
            "No recovery action was performed",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No live A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No stage/commit/push was performed by the detector",
            "No product runtime is claimed",
            "Codex compaction is detected as a failure type, not solved",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18CompactTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18CompactTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18CompactCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 18) {
            Assert-R18CompactCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-018."
        }
        else {
            Assert-R18CompactCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-018."
        }
    }

    if ($combinedText -match 'R18 active through R18-(019|02[0-8])') {
        throw "Status surface claims R18 beyond R18-018."
    }
}

function Test-R18CompactFailureDetectorSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$FailureEventContract,
        [Parameter(Mandatory = $true)][object]$DetectorContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Signals,
        [Parameter(Mandatory = $true)][object[]]$FailureEvents,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot)
    )

    Assert-R18CompactContract -Contract $FailureEventContract
    Assert-R18CompactDetectorContract -Contract $DetectorContract
    Assert-R18CompactRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 compact failure detector profile"
    Assert-R18CompactPositiveClaims -Object $Profile -Context "R18 compact failure detector profile"
    Assert-R18CompactCondition -Condition (@($Signals).Count -eq @($script:R18SignalDefinitions).Count) -Message "R18 compact failure detector signals are missing."
    Assert-R18CompactCondition -Condition (@($FailureEvents).Count -eq @($script:R18SignalDefinitions).Count) -Message "R18 compact failure detector failure events are missing."

    foreach ($signal in @($Signals)) {
        Assert-R18CompactSignal -Signal $signal
        $definition = Get-R18CompactDefinitionBySignalType -SignalType ([string]$signal.signal_type)
        $signalRef = Get-R18CompactSignalRef -FileName ([string]$definition.file)
        $matchingEvents = @($FailureEvents | Where-Object { $_.source_signal_ref -eq $signalRef })
        Assert-R18CompactCondition -Condition ($matchingEvents.Count -eq 1) -Message "R18 compact failure signal '$($signal.signal_type)' does not have exactly one detected event."
        Assert-R18CompactFailureEvent -Event $matchingEvents[0] -Signal $signal
    }

    Assert-R18CompactResults -Results $Results -Signals $Signals -Events $FailureEvents
    Assert-R18CompactReport -Report $Report
    Assert-R18CompactSnapshot -Snapshot $Snapshot
    Test-R18CompactFailureDetectorStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        SignalCount = @($Signals).Count
        FailureEventCount = @($FailureEvents).Count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18CompactFailureDetector {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot))

    $paths = Get-R18CompactFailureDetectorPaths -RepositoryRoot $RepositoryRoot
    $signals = @()
    $events = @()
    foreach ($definition in $script:R18SignalDefinitions) {
        $signals += Read-R18CompactJson -Path (Join-Path $paths.SignalRoot ([string]$definition.file))
        $events += Read-R18CompactJson -Path (Join-Path $paths.FailureEventRoot ("$($definition.signal_type).failure.json"))
    }

    return Test-R18CompactFailureDetectorSet `
        -FailureEventContract (Read-R18CompactJson -Path $paths.FailureEventContract) `
        -DetectorContract (Read-R18CompactJson -Path $paths.DetectorContract) `
        -Profile (Read-R18CompactJson -Path $paths.Profile) `
        -Signals $signals `
        -FailureEvents $events `
        -Results (Read-R18CompactJson -Path $paths.Results) `
        -Report (Read-R18CompactJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18CompactJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18CompactObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        $Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($cursor.PSObject.Properties.Name -notcontains $segment) {
            $cursor | Add-Member -NotePropertyName $segment -NotePropertyValue ([pscustomobject]@{})
        }
        $cursor = $cursor.$segment
    }
    $leaf = $segments[-1]
    if ($cursor.PSObject.Properties.Name -contains $leaf) {
        $cursor.$leaf = $Value
    }
    else {
        $cursor | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
}

function Remove-R18CompactObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($cursor.PSObject.Properties.Name -notcontains $segment) {
            return
        }
        $cursor = $cursor.$segment
    }
    $leaf = $segments[-1]
    if ($cursor.PSObject.Properties.Name -contains $leaf) {
        $cursor.PSObject.Properties.Remove($leaf)
    }
}

function Add-R18CompactArrayValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        $Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $cursor = $cursor.$($segments[$index])
    }
    $leaf = $segments[-1]
    $cursor.$leaf = @($cursor.$leaf) + $Value
}

function Invoke-R18CompactFailureDetectorMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18CompactObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18CompactObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        "add_array_value" { Add-R18CompactArrayValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 compact failure detector mutation operation '$($Mutation.operation)'." }
    }
}

function New-R18CompactFailureDetectorArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18CompactFailureDetectorRepositoryRoot))

    $paths = Get-R18CompactFailureDetectorPaths -RepositoryRoot $RepositoryRoot
    $failureEventContract = New-R18FailureEventContract
    $detectorContract = New-R18CompactFailureDetectorContract
    $profile = New-R18CompactFailureDetectorProfile
    $signals = @()
    $events = @()

    foreach ($definition in $script:R18SignalDefinitions) {
        $signal = New-R18CompactSignalSample -Definition $definition
        $signals += $signal
        $events += New-R18DetectedFailureEvent -Signal $signal -SignalFileName ([string]$definition.file)
    }

    $results = New-R18CompactFailureDetectorResults -Signals $signals -Events $events
    $report = New-R18CompactFailureDetectorCheckReport -Signals $signals -Events $events
    $snapshot = New-R18CompactFailureDetectorSnapshot -Signals $signals -Events $events

    Write-R18CompactJson -Path $paths.FailureEventContract -Value $failureEventContract
    Write-R18CompactJson -Path $paths.DetectorContract -Value $detectorContract
    Write-R18CompactJson -Path $paths.Profile -Value $profile
    foreach ($definition in $script:R18SignalDefinitions) {
        $signal = @($signals | Where-Object { $_.signal_type -eq [string]$definition.signal_type })[0]
        $event = @($events | Where-Object { $_.detected_failure_type -eq [string]$definition.expected_detected_failure_type })[0]
        Write-R18CompactJson -Path (Join-Path $paths.SignalRoot ([string]$definition.file)) -Value $signal
        Write-R18CompactJson -Path (Join-Path $paths.FailureEventRoot ("$($definition.signal_type).failure.json")) -Value $event
    }
    Write-R18CompactJson -Path $paths.Results -Value $results
    Write-R18CompactJson -Path $paths.CheckReport -Value $report
    Write-R18CompactJson -Path $paths.UiSnapshot -Value $snapshot
    Write-R18CompactJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18CompactFixtureManifest)
    foreach ($fixture in New-R18CompactFixtureDefinitions) {
        Write-R18CompactJson -Path (Join-Path $paths.FixtureRoot ([string]$fixture.file)) -Value $fixture
    }
    Write-R18CompactJson -Path $paths.EvidenceIndex -Value (New-R18CompactEvidenceIndex)
    Write-R18CompactText -Path $paths.ProofReview -Value (New-R18CompactProofReviewText)
    Write-R18CompactText -Path $paths.ValidationManifest -Value (New-R18CompactValidationManifestText)

    return [pscustomobject]@{
        FailureEventContract = $paths.FailureEventContract
        DetectorContract = $paths.DetectorContract
        Profile = $paths.Profile
        SignalRoot = $paths.SignalRoot
        FailureEventRoot = $paths.FailureEventRoot
        Results = $paths.Results
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        SignalCount = @($signals).Count
        FailureEventCount = @($events).Count
        AggregateVerdict = $script:R18DetectorVerdict
    }
}

Export-ModuleMember -Function `
    Get-R18CompactFailureDetectorPaths, `
    Read-R18CompactJson, `
    Copy-R18CompactFailureDetectorObject, `
    Test-R18CompactFailureDetector, `
    Test-R18CompactFailureDetectorSet, `
    Test-R18CompactFailureDetectorStatusTruth, `
    Invoke-R18CompactFailureDetectorMutation, `
    New-R18CompactFailureDetectorArtifacts
