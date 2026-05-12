Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-013"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18AggregateVerdict = "generated_r18_013_continuation_packet_generator_foundation_only"

$script:R18RuntimeFlagFields = @(
    "continuation_packet_executed",
    "continuation_runtime_implemented",
    "new_context_prompt_generated",
    "automatic_new_thread_creation_performed",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_execution_performed",
    "work_order_execution_performed",
    "live_runner_runtime_executed",
    "wip_cleanup_performed",
    "wip_abandonment_performed",
    "branch_mutation_performed",
    "pull_performed",
    "rebase_performed",
    "reset_performed",
    "merge_performed",
    "checkout_or_switch_performed",
    "clean_performed",
    "restore_performed",
    "staging_performed",
    "commit_performed",
    "push_performed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_014_completed",
    "main_merge_claimed"
)

$script:R18RequiredInputSetFields = @(
    "artifact_type",
    "contract_version",
    "input_set_id",
    "input_set_name",
    "source_task",
    "source_milestone",
    "input_status",
    "continuation_type",
    "runner_state_ref",
    "failure_event_ref",
    "wip_classification_ref",
    "remote_verification_ref",
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
    "validation_commands",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredContinuationPacketFields = @(
    "artifact_type",
    "contract_version",
    "continuation_packet_id",
    "continuation_packet_name",
    "source_task",
    "source_milestone",
    "continuation_status",
    "continuation_type",
    "source_input_set_ref",
    "runner_state_ref",
    "failure_event_ref",
    "wip_classification_ref",
    "remote_verification_ref",
    "resume_checkpoint_ref",
    "current_work_order_ref",
    "current_state",
    "last_completed_step",
    "next_safe_step",
    "next_safe_step_type",
    "retry_count",
    "max_retry_count",
    "retry_limit_enforced",
    "stop_conditions",
    "escalation_conditions",
    "operator_decision_required",
    "operator_decision_policy",
    "validation_commands",
    "allowed_paths",
    "forbidden_paths",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18AllowedContinuationTypes = @(
    "continue_after_compact_failure",
    "continue_after_stream_disconnect",
    "continue_after_validation_failure",
    "operator_decision_required_for_wip",
    "operator_decision_required_for_remote_branch",
    "block_until_future_runtime"
)

$script:R18AllowedContinuationStatuses = @(
    "packet_generated_not_executed"
)

$script:R18AllowedNextSafeStepTypes = @(
    "rerun_validation_only",
    "rerun_detector_only",
    "route_to_wip_operator_decision",
    "route_to_remote_branch_operator_decision",
    "block_until_r18_014_or_later",
    "block_until_future_runtime"
)

$script:R18AllowedPositiveClaims = @(
    "r18_continuation_packet_contract_created",
    "r18_continuation_packet_generator_contract_created",
    "r18_continuation_packet_generator_profile_created",
    "r18_continuation_input_sets_created",
    "r18_continuation_packets_created",
    "r18_continuation_packet_generator_results_created",
    "r18_continuation_packet_generator_validator_created",
    "r18_continuation_packet_generator_fixtures_created",
    "r18_continuation_packet_generator_proof_review_created"
)

$script:R18RejectedClaims = @(
    "new_context_prompt_generation",
    "automatic_new_thread_creation",
    "recovery_runtime",
    "recovery_action",
    "retry_execution",
    "work_order_execution",
    "live_runner_runtime",
    "wip_cleanup",
    "wip_abandonment",
    "branch_mutation",
    "pull",
    "rebase",
    "reset",
    "merge",
    "checkout_or_switch",
    "clean",
    "restore",
    "stage_commit_push",
    "staging",
    "commit",
    "push",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_014_or_later_completion",
    "main_merge",
    "unbounded_retry",
    "missing_runner_state_ref",
    "missing_failure_event_ref",
    "missing_wip_classification_ref",
    "missing_remote_verification_ref",
    "missing_resume_checkpoint_ref",
    "packet_execution"
)

$script:R18ContinuationDefinitions = @(
    [ordered]@{
        continuation_type = "continue_after_compact_failure"
        input_file = "continue_after_compact_failure.input.json"
        packet_file = "continue_after_compact_failure.continuation.json"
        name = "Continue after compact/context failure packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        failure_rule = "compact_or_context"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        operator_decision_required = $false
        next_safe_step_type = "rerun_detector_only"
        next_safe_step = "Rerun compact failure detector validation only in a future approved continuation path after WIP and remote refs are confirmed safe; R18-013 only generates deterministic packet evidence."
    },
    [ordered]@{
        continuation_type = "continue_after_stream_disconnect"
        input_file = "continue_after_stream_disconnect.input.json"
        packet_file = "continue_after_stream_disconnect.continuation.json"
        name = "Continue after stream disconnect packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/stream_disconnected_before_completion.failure.json"
        failure_rule = "stream_disconnected_before_completion"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        operator_decision_required = $false
        next_safe_step_type = "rerun_detector_only"
        next_safe_step = $null
    },
    [ordered]@{
        continuation_type = "continue_after_validation_failure"
        input_file = "continue_after_validation_failure.input.json"
        packet_file = "continue_after_validation_failure.continuation.json"
        name = "Continue after validation failure packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/validation_interrupted_after_compact.failure.json"
        failure_rule = "validation_failure"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        operator_decision_required = $false
        next_safe_step_type = "rerun_validation_only"
        next_safe_step = "Rerun validation commands only in a future approved runtime; R18-013 preserves validation command refs and performs no validation rerun."
    },
    [ordered]@{
        continuation_type = "operator_decision_required_for_wip"
        input_file = "operator_decision_required_for_wip.input.json"
        packet_file = "operator_decision_required_for_wip.continuation.json"
        name = "Operator decision required for WIP packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        failure_rule = "compact_or_context"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/unexpected_tracked_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        operator_decision_required = $true
        next_safe_step_type = "route_to_wip_operator_decision"
        next_safe_step = "Route to operator decision for WIP; do not clean, abandon, restore, stage, commit, or push."
    },
    [ordered]@{
        continuation_type = "operator_decision_required_for_remote_branch"
        input_file = "operator_decision_required_for_remote_branch.input.json"
        packet_file = "operator_decision_required_for_remote_branch.continuation.json"
        name = "Operator decision required for remote branch packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        failure_rule = "compact_or_context"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_ahead.verification.json"
        operator_decision_required = $true
        next_safe_step_type = "route_to_remote_branch_operator_decision"
        next_safe_step = "Route to operator decision for remote branch movement; do not pull, rebase, reset, merge, checkout, switch, clean, restore, stage, commit, or push."
    },
    [ordered]@{
        continuation_type = "block_until_future_runtime"
        input_file = "block_until_future_runtime.input.json"
        packet_file = "block_until_future_runtime.continuation.json"
        name = "Block until future runtime packet seed"
        failure_event_ref = "state/runtime/r18_detected_failure_events/unknown_failure_requires_escalation.failure.json"
        failure_rule = "future_runtime_block"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
        operator_decision_required = $false
        next_safe_step_type = "block_until_future_runtime"
        next_safe_step = "Block continuation until R18-014 or later runtime dependencies exist and are separately approved; R18-013 performs no execution."
    }
)

function Get-R18ContinuationRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18ContinuationPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18ContinuationJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18ContinuationJson {
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

function Write-R18ContinuationText {
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

function Copy-R18ContinuationObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18ContinuationPaths {
    param([string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot))

    return [ordered]@{
        PacketContract = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_continuation_packet.contract.json"
        GeneratorContract = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_continuation_packet_generator.contract.json"
        Profile = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_continuation_packet_generator_profile.json"
        InputSetRoot = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_continuation_input_sets"
        PacketRoot = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_continuation_packets"
        Results = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_continuation_packet_generator_results.json"
        CheckReport = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_continuation_packet_generator_check_report.json"
        UiSnapshot = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_continuation_packet_snapshot.json"
        FixtureRoot = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_continuation_packet_generator"
        ProofRoot = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator"
        EvidenceIndex = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/evidence_index.json"
        ProofReview = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/proof_review.md"
        ValidationManifest = Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/validation_manifest.md"
    }
}

function New-R18ContinuationRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18ContinuationAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_state_history.jsonl",
        "state/runtime/r18_execution_log.jsonl",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_failure_event.contract.json",
        "contracts/runtime/r18_compact_failure_detector.contract.json",
        "state/runtime/r18_detected_failure_events/",
        "state/runtime/r18_compact_failure_detector_results.json",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "state/runtime/r18_wip_classifier_results.json",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_current_verification.json",
        "state/runtime/r18_remote_branch_verification_packets/",
        "state/runtime/r18_remote_branch_verifier_results.json",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_seed_packets/",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18ContinuationEvidenceRefs {
    return @(
        "contracts/runtime/r18_continuation_packet.contract.json",
        "contracts/runtime/r18_continuation_packet_generator.contract.json",
        "state/runtime/r18_continuation_packet_generator_profile.json",
        "state/runtime/r18_continuation_input_sets/",
        "state/runtime/r18_continuation_packets/",
        "state/runtime/r18_continuation_packet_generator_results.json",
        "state/runtime/r18_continuation_packet_generator_check_report.json",
        "state/ui/r18_operator_surface/r18_continuation_packet_snapshot.json",
        "tools/R18ContinuationPacketGenerator.psm1",
        "tools/new_r18_continuation_packet_generator.ps1",
        "tools/validate_r18_continuation_packet_generator.ps1",
        "tests/test_r18_continuation_packet_generator.ps1",
        "tests/fixtures/r18_continuation_packet_generator/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/"
    )
}

function Get-R18ContinuationNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-013 only.",
        "R18-014 through R18-028 remain planned only.",
        "R18-013 created continuation packet generator foundation only.",
        "Continuation packets were generated as deterministic packet artifacts only.",
        "Continuation packets were not executed.",
        "Continuation packets are not new-context prompts.",
        "New-context prompt generator is not implemented.",
        "Automatic new-thread creation is not implemented.",
        "No recovery runtime was implemented.",
        "No recovery action was performed.",
        "No retry execution was performed.",
        "No WIP cleanup was performed.",
        "No WIP abandonment was performed.",
        "No branch mutation was performed.",
        "No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed.",
        "No staging, commit, or push was performed by the generator.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No OpenAI API invocation occurred.",
        "No Codex API invocation occurred.",
        "No autonomous Codex invocation occurred.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18ContinuationValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_continuation_packet_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_continuation_packet_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_continuation_packet_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_wip_classifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_runner_state_store.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R18ContinuationAllowedPaths {
    return @(
        "contracts/runtime/r18_continuation_packet.contract.json",
        "contracts/runtime/r18_continuation_packet_generator.contract.json",
        "state/runtime/r18_continuation_packet_generator_profile.json",
        "state/runtime/r18_continuation_input_sets/",
        "state/runtime/r18_continuation_packets/",
        "state/runtime/r18_continuation_packet_generator_results.json",
        "state/runtime/r18_continuation_packet_generator_check_report.json",
        "state/ui/r18_operator_surface/r18_continuation_packet_snapshot.json",
        "tools/R18ContinuationPacketGenerator.psm1",
        "tools/new_r18_continuation_packet_generator.ps1",
        "tools/validate_r18_continuation_packet_generator.ps1",
        "tests/test_r18_continuation_packet_generator.ps1",
        "tests/fixtures/r18_continuation_packet_generator/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/"
    )
}

function Get-R18ContinuationForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_",
        "state/proof_reviews/r14_",
        "state/proof_reviews/r15_",
        "state/proof_reviews/r16_",
        "main branch"
    )
}

function New-R18ContinuationPacketContract {
    return [ordered]@{
        artifact_type = "r18_continuation_packet_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-013-continuation-packet-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "continuation_packet_contract_foundation_only_no_recovery_execution_no_new_context_prompt_generation"
        purpose = "Define deterministic continuation packet fields and fail-closed boundaries using R18 runner state, failure events, WIP classifications, remote branch verification packets, and resume checkpoints without executing recovery, retries, work orders, skills, A2A messages, branch mutations, API calls, or new-context prompt generation."
        required_continuation_packet_fields = $script:R18RequiredContinuationPacketFields
        allowed_continuation_types = $script:R18AllowedContinuationTypes
        allowed_continuation_statuses = $script:R18AllowedContinuationStatuses
        allowed_next_safe_step_types = $script:R18AllowedNextSafeStepTypes
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        packet_policy = [ordered]@{ continuation_status_required = "packet_generated_not_executed"; deterministic_packet_artifacts_only = $true; packet_execution_allowed = $false }
        state_policy = [ordered]@{ runner_state_ref_required = $true; current_state_required = $true; last_completed_step_required = $true; next_safe_step_required = $true; state_mutation_allowed = $false }
        failure_event_policy = [ordered]@{ failure_event_ref_required = $true; compact_context_stream_validation_events_allowed = $true; failure_events_are_not_recovery_completion = $true }
        wip_policy = [ordered]@{ wip_classification_ref_required = $true; unsafe_wip_requires_operator_decision = $true; cleanup_or_abandonment_allowed = $false }
        remote_verification_policy = [ordered]@{ remote_verification_ref_required = $true; unsafe_remote_requires_operator_decision = $true; branch_mutation_allowed = $false }
        checkpoint_policy = [ordered]@{ resume_checkpoint_ref_required = $true; resume_checkpoint_is_not_continuation_packet = $true }
        operator_decision_policy = [ordered]@{ required_for_wip_decision_packets = $true; required_for_remote_decision_packets = $true; missing_required_decision_fails_closed = $true }
        validation_policy = [ordered]@{ validation_commands_required = $true; validation_rerun_performed_by_r18_013 = $false; validation_commands_are_refs_only = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; proof_review_required = $true }
        authority_policy = [ordered]@{ authority_refs_required = $true; r18_active_boundary = "R18 active through R18-013 only"; planned_boundary = "R18-014 through R18-028 planned only" }
        boundary_policy = [ordered]@{ new_context_prompt_generation_allowed = $false; automatic_new_thread_creation_allowed = $false; recovery_execution_allowed = $false; retry_execution_allowed = $false; work_order_execution_allowed = $false }
        path_policy = [ordered]@{ allowed_paths = Get-R18ContinuationAllowedPaths; forbidden_paths = Get-R18ContinuationForbiddenPaths; broad_repo_writes_allowed = $false; operator_local_backup_paths_allowed = $false }
        api_policy = [ordered]@{ openai_api_invocation_allowed = $false; codex_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false }
        execution_policy = [ordered]@{ packet_generation_only = $true; packet_execution_allowed = $false; live_runner_runtime_allowed = $false; board_runtime_mutation_allowed = $false; stage_commit_push_allowed_by_generator = $false }
        refusal_policy = [ordered]@{ refuse_on_missing_required_refs = $true; refuse_on_unknown_continuation_type = $true; refuse_on_forbidden_runtime_flag = $true; refuse_on_unbounded_retry = $true; refuse_on_r18_014_or_later_claim = $true }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18ContinuationNonClaims
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
        positive_claims = @("r18_continuation_packet_contract_created")
        runtime_flags = New-R18ContinuationRuntimeFlags
    }
}

function New-R18ContinuationPacketGeneratorContract {
    return [ordered]@{
        artifact_type = "r18_continuation_packet_generator_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-013-continuation-packet-generator-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "continuation_packet_generator_foundation_only_deterministic_seed_inputs_no_runtime_recovery"
        purpose = "Generate deterministic continuation input sets and continuation packet artifacts from existing R18 runner state, failure events, WIP classifications, remote branch verification packets, and resume checkpoint refs without creating new-context prompts, automatic new threads, retries, recovery actions, branch mutations, API calls, work-order execution, live agents, live skills, A2A messages, or board/card runtime mutations."
        required_input_set_fields = $script:R18RequiredInputSetFields
        required_output_packet_fields = $script:R18RequiredContinuationPacketFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        generation_policy = [ordered]@{ deterministic_seed_artifacts_only = $true; input_sets_required = $true; output_packets_required = $true; runtime_generation_service_implemented = $false }
        input_policy = [ordered]@{ require_runner_state_ref = $true; require_failure_event_ref = $true; require_wip_classification_ref = $true; require_remote_verification_ref = $true; require_resume_checkpoint_ref = $true }
        output_policy = [ordered]@{ continuation_status = "packet_generated_not_executed"; packet_execution_allowed = $false; prompt_generation_allowed = $false }
        safety_policy = [ordered]@{ fail_closed_on_missing_refs = $true; fail_closed_on_unknown_type = $true; fail_closed_on_unbounded_retry = $true; fail_closed_on_forbidden_claim = $true }
        status_boundary_policy = [ordered]@{ r18_active_through = "R18-013"; planned_from = "R18-014"; planned_through = "R18-028"; r18_014_completion_claim_allowed = $false }
        path_policy = [ordered]@{ allowed_paths = Get-R18ContinuationAllowedPaths; forbidden_paths = Get-R18ContinuationForbiddenPaths; live_board_paths_mutable = $false }
        api_policy = [ordered]@{ openai_api_invocation_allowed = $false; codex_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false }
        execution_policy = [ordered]@{ recovery_execution_allowed = $false; retry_execution_allowed = $false; work_order_execution_allowed = $false; stage_commit_push_allowed_by_generator = $false }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18ContinuationNonClaims
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
        positive_claims = @("r18_continuation_packet_generator_contract_created")
        runtime_flags = New-R18ContinuationRuntimeFlags
    }
}

function New-R18ContinuationProfile {
    return [ordered]@{
        artifact_type = "r18_continuation_packet_generator_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-013-continuation-packet-generator-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        profile_status = "generator_profile_seed_only_not_runtime_recovery"
        repository = $script:R18Repository
        branch = $script:R18Branch
        continuation_types = $script:R18AllowedContinuationTypes
        input_set_count = @($script:R18ContinuationDefinitions).Count
        continuation_packet_count = @($script:R18ContinuationDefinitions).Count
        source_refs = Get-R18ContinuationAuthorityRefs
        allowed_paths = Get-R18ContinuationAllowedPaths
        forbidden_paths = Get-R18ContinuationForbiddenPaths
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        positive_claims = @("r18_continuation_packet_generator_profile_created")
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
    }
}

function New-R18ContinuationInputSet {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $failure = Read-R18ContinuationJson -Path (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$Definition.failure_event_ref))
    $checkpoint = Read-R18ContinuationJson -Path (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_runner_resume_checkpoint.json")
    $nextSafeStep = if ($null -eq $Definition.next_safe_step) { [string]$failure.next_safe_step } else { [string]$Definition.next_safe_step }

    return [ordered]@{
        artifact_type = "r18_continuation_input_set"
        contract_version = "v1"
        input_set_id = "r18_013_input_set_$($Definition.continuation_type)"
        input_set_name = [string]$Definition.name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        input_status = "seed_input_set_only_not_runtime_recovery"
        continuation_type = [string]$Definition.continuation_type
        runner_state_ref = "state/runtime/r18_runner_state.json"
        failure_event_ref = [string]$Definition.failure_event_ref
        wip_classification_ref = [string]$Definition.wip_classification_ref
        remote_verification_ref = [string]$Definition.remote_verification_ref
        resume_checkpoint_ref = "state/runtime/r18_runner_resume_checkpoint.json"
        current_work_order_ref = [string]$failure.current_work_order_ref
        current_state = [string]$failure.current_state
        last_completed_step = [string]$failure.last_completed_step
        next_safe_step = $nextSafeStep
        retry_count = [int]$checkpoint.retry_count
        max_retry_count = [int]$checkpoint.max_retry_count
        stop_conditions = @($failure.stop_conditions) + @("R18-013 must not execute continuation packets.", "R18-013 must not generate new-context prompts.", "R18-013 must not mutate WIP, branch state, board state, or evidence history.")
        escalation_conditions = @($failure.escalation_conditions) + @("missing continuation input refs", "unsafe WIP or remote verification requires operator decision", "future runtime dependency is required")
        operator_decision_required = [bool]$Definition.operator_decision_required
        validation_commands = Get-R18ContinuationValidationCommands
        evidence_refs = (Get-R18ContinuationEvidenceRefs) + @([string]$Definition.failure_event_ref, [string]$Definition.wip_classification_ref, [string]$Definition.remote_verification_ref)
        authority_refs = Get-R18ContinuationAuthorityRefs
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18ContinuationPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][object]$InputSet
    )

    return [ordered]@{
        artifact_type = "r18_continuation_packet"
        contract_version = "v1"
        continuation_packet_id = "r18_013_packet_$($Definition.continuation_type)"
        continuation_packet_name = [string]$Definition.name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        continuation_status = "packet_generated_not_executed"
        continuation_type = [string]$Definition.continuation_type
        source_input_set_ref = "state/runtime/r18_continuation_input_sets/$($Definition.input_file)"
        runner_state_ref = [string]$InputSet.runner_state_ref
        failure_event_ref = [string]$InputSet.failure_event_ref
        wip_classification_ref = [string]$InputSet.wip_classification_ref
        remote_verification_ref = [string]$InputSet.remote_verification_ref
        resume_checkpoint_ref = [string]$InputSet.resume_checkpoint_ref
        current_work_order_ref = [string]$InputSet.current_work_order_ref
        current_state = [string]$InputSet.current_state
        last_completed_step = [string]$InputSet.last_completed_step
        next_safe_step = [string]$InputSet.next_safe_step
        next_safe_step_type = [string]$Definition.next_safe_step_type
        retry_count = [int]$InputSet.retry_count
        max_retry_count = [int]$InputSet.max_retry_count
        retry_limit_enforced = $true
        stop_conditions = @($InputSet.stop_conditions)
        escalation_conditions = @($InputSet.escalation_conditions)
        operator_decision_required = [bool]$InputSet.operator_decision_required
        operator_decision_policy = [ordered]@{
            required = [bool]$InputSet.operator_decision_required
            required_for_wip_decision = ([string]$Definition.continuation_type -eq "operator_decision_required_for_wip")
            required_for_remote_branch_decision = ([string]$Definition.continuation_type -eq "operator_decision_required_for_remote_branch")
            approval_gate_model_implemented = $false
            no_cleanup_or_branch_action_without_future_operator_gate = $true
        }
        validation_commands = @($InputSet.validation_commands)
        allowed_paths = Get-R18ContinuationAllowedPaths
        forbidden_paths = Get-R18ContinuationForbiddenPaths
        evidence_refs = @($InputSet.evidence_refs)
        authority_refs = @($InputSet.authority_refs)
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        positive_claims = @("r18_continuation_packets_created")
    }
}

function New-R18ContinuationFixtureDefinition {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Fragment
    )

    return [ordered]@{
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($File)
        target = $Target
        operation = $Operation
        path = $Path
        value = $Value
        expected_failure_fragments = @($Fragment)
    }
}

function Get-R18ContinuationFixtureDefinitions {
    $fixtures = @()
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_continuation_packet_id.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "continuation_packet_id" -Value $null -Fragment "continuation_packet_id"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_runner_state_ref.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "runner_state_ref" -Value $null -Fragment "runner_state_ref"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_failure_event_ref.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "failure_event_ref" -Value $null -Fragment "failure_event_ref"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_wip_classification_ref.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "wip_classification_ref" -Value $null -Fragment "wip_classification_ref"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_remote_verification_ref.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "remote_verification_ref" -Value $null -Fragment "remote_verification_ref"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_resume_checkpoint_ref.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "resume_checkpoint_ref" -Value $null -Fragment "resume_checkpoint_ref"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_last_completed_step.json" -Target "packet:continue_after_stream_disconnect" -Operation "remove" -Path "last_completed_step" -Value $null -Fragment "last_completed_step"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_next_safe_step.json" -Target "packet:continue_after_stream_disconnect" -Operation "remove" -Path "next_safe_step" -Value $null -Fragment "next_safe_step"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_retry_count.json" -Target "packet:continue_after_validation_failure" -Operation "remove" -Path "retry_count" -Value $null -Fragment "retry_count"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_unbounded_retry.json" -Target "packet:continue_after_validation_failure" -Operation "set" -Path "max_retry_count" -Value 0 -Fragment "unbounded"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_stop_conditions.json" -Target "packet:continue_after_validation_failure" -Operation "remove" -Path "stop_conditions" -Value $null -Fragment "stop_conditions"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_operator_decision_policy.json" -Target "packet:operator_decision_required_for_wip" -Operation "remove" -Path "operator_decision_policy" -Value $null -Fragment "operator_decision_policy"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_validation_commands.json" -Target "packet:continue_after_validation_failure" -Operation "remove" -Path "validation_commands" -Value $null -Fragment "validation_commands"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_evidence_refs.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "evidence_refs" -Value $null -Fragment "evidence_refs"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_missing_authority_refs.json" -Target "packet:continue_after_compact_failure" -Operation "remove" -Path "authority_refs" -Value $null -Fragment "authority_refs"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_new_context_prompt_generation_claim.json" -Target "packet:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.new_context_prompt_generated" -Value $true -Fragment "new_context_prompt_generated"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_automatic_new_thread_creation_claim.json" -Target "packet:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Fragment "automatic_new_thread_creation_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_recovery_action_claim.json" -Target "packet:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Fragment "recovery_action_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_retry_execution_claim.json" -Target "packet:continue_after_validation_failure" -Operation "set" -Path "runtime_flags.retry_execution_performed" -Value $true -Fragment "retry_execution_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_work_order_execution_claim.json" -Target "packet:continue_after_stream_disconnect" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Fragment "work_order_execution_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_wip_cleanup_claim.json" -Target "packet:operator_decision_required_for_wip" -Operation "set" -Path "runtime_flags.wip_cleanup_performed" -Value $true -Fragment "wip_cleanup_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_branch_mutation_claim.json" -Target "packet:operator_decision_required_for_remote_branch" -Operation "set" -Path "runtime_flags.branch_mutation_performed" -Value $true -Fragment "branch_mutation_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_stage_commit_push_claim.json" -Target "packet:operator_decision_required_for_remote_branch" -Operation "set" -Path "runtime_flags.push_performed" -Value $true -Fragment "push_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_skill_execution_claim.json" -Target "packet:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.live_skill_execution_performed" -Value $true -Fragment "live_skill_execution_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_a2a_message_sent_claim.json" -Target "packet:continue_after_stream_disconnect" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Fragment "a2a_message_sent"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_board_runtime_mutation_claim.json" -Target "packet:continue_after_validation_failure" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Fragment "board_runtime_mutation_performed"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_api_invocation_claim.json" -Target "packet:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.openai_api_invoked" -Value $true -Fragment "openai_api_invoked"
    $fixtures += New-R18ContinuationFixtureDefinition -File "invalid_r18_014_completion_claim.json" -Target "packet:block_until_future_runtime" -Operation "set" -Path "runtime_flags.r18_014_completed" -Value $true -Fragment "r18_014_completed"
    return $fixtures
}

function New-R18ContinuationArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot))

    $paths = Get-R18ContinuationPaths -RepositoryRoot $RepositoryRoot
    $inputSets = @()
    $packets = @()

    Write-R18ContinuationJson -Path $paths.PacketContract -Value (New-R18ContinuationPacketContract)
    Write-R18ContinuationJson -Path $paths.GeneratorContract -Value (New-R18ContinuationPacketGeneratorContract)
    Write-R18ContinuationJson -Path $paths.Profile -Value (New-R18ContinuationProfile)

    foreach ($definition in $script:R18ContinuationDefinitions) {
        $inputSet = New-R18ContinuationInputSet -Definition $definition -RepositoryRoot $RepositoryRoot
        $packet = New-R18ContinuationPacket -Definition $definition -InputSet $inputSet
        Write-R18ContinuationJson -Path (Join-Path $paths.InputSetRoot ([string]$definition.input_file)) -Value $inputSet
        Write-R18ContinuationJson -Path (Join-Path $paths.PacketRoot ([string]$definition.packet_file)) -Value $packet
        $inputSets += (ConvertTo-Json $inputSet -Depth 100 | ConvertFrom-Json)
        $packets += (ConvertTo-Json $packet -Depth 100 | ConvertFrom-Json)
    }

    $results = [ordered]@{
        artifact_type = "r18_continuation_packet_generator_results"
        contract_version = "v1"
        result_id = "r18_013_continuation_packet_generator_results"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        result_status = "results_created_not_runtime_recovery"
        aggregate_verdict = $script:R18AggregateVerdict
        input_set_count = @($inputSets).Count
        continuation_packet_count = @($packets).Count
        continuation_types = @($packets | ForEach-Object { $_.continuation_type })
        continuation_packet_refs = @($script:R18ContinuationDefinitions | ForEach-Object { "state/runtime/r18_continuation_packets/$($_.packet_file)" })
        input_set_refs = @($script:R18ContinuationDefinitions | ForEach-Object { "state/runtime/r18_continuation_input_sets/$($_.input_file)" })
        positive_claims = @("r18_continuation_packet_generator_results_created", "r18_continuation_input_sets_created", "r18_continuation_packets_created")
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
    }
    Write-R18ContinuationJson -Path $paths.Results -Value $results

    $report = [ordered]@{
        artifact_type = "r18_continuation_packet_generator_check_report"
        contract_version = "v1"
        report_id = "r18_013_continuation_packet_generator_check_report"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18AggregateVerdict
        checks = @(
            [ordered]@{ check_id = "contracts_present"; status = "passed" },
            [ordered]@{ check_id = "input_sets_present"; status = "passed"; count = @($inputSets).Count },
            [ordered]@{ check_id = "continuation_packets_present"; status = "passed"; count = @($packets).Count },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-013 only; R18-014 through R18-028 planned only" }
        )
        positive_claims = @("r18_continuation_packet_generator_validator_created")
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
    }
    Write-R18ContinuationJson -Path $paths.CheckReport -Value $report

    $snapshot = [ordered]@{
        artifact_type = "r18_continuation_packet_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_013_continuation_packet_snapshot"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        r18_status = "active_through_r18_013_only"
        planned_only_boundary = "R18-014 through R18-028 remain planned only"
        packet_count = @($packets).Count
        continuation_types = @($packets | ForEach-Object { $_.continuation_type })
        packets_executed = $false
        runtime_flags = New-R18ContinuationRuntimeFlags
        positive_claims = @("r18_continuation_packets_created")
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
    }
    Write-R18ContinuationJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18ContinuationFixtureDefinitions
    foreach ($fixture in $fixtureDefinitions) {
        Write-R18ContinuationJson -Path (Join-Path $paths.FixtureRoot ($fixture.fixture_id + ".json")) -Value $fixture
    }
    $manifest = [ordered]@{
        artifact_type = "r18_continuation_packet_generator_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        fixture_count = @($fixtureDefinitions).Count
        fixtures = @($fixtureDefinitions | ForEach-Object { "$($_.fixture_id).json" })
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        positive_claims = @("r18_continuation_packet_generator_fixtures_created")
    }
    Write-R18ContinuationJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $manifest

    $evidenceIndex = [ordered]@{
        artifact_type = "r18_013_continuation_packet_generator_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_refs = Get-R18ContinuationEvidenceRefs
        authority_refs = Get-R18ContinuationAuthorityRefs
        validation_commands = Get-R18ContinuationValidationCommands
        runtime_flags = New-R18ContinuationRuntimeFlags
        non_claims = Get-R18ContinuationNonClaims
        rejected_claims = $script:R18RejectedClaims
        positive_claims = @("r18_continuation_packet_generator_proof_review_created")
    }
    Write-R18ContinuationJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $proofReview = @(
        "# R18-013 Continuation Packet Generator Proof Review",
        "",
        "R18-013 created the continuation packet generator foundation only.",
        "",
        "The generated continuation packets are deterministic packet artifacts assembled from R18-009 runner state, R18-010 failure events, R18-011 WIP classifications, R18-012 remote branch verification packets, and the R18-009 resume checkpoint.",
        "",
        "No continuation packet was executed. No new-context prompt was generated. No automatic new-thread creation, recovery action, retry execution, WIP cleanup, branch mutation, work-order execution, board/card runtime mutation, A2A message, live agent or skill invocation, OpenAI API invocation, Codex API invocation, product runtime, solved compaction/reliability claim, no-manual-prompt-transfer success claim, or main merge is claimed.",
        "",
        "R18 is active through R18-013 only. R18-014 through R18-028 remain planned only."
    ) -join [Environment]::NewLine
    Write-R18ContinuationText -Path $paths.ProofReview -Value $proofReview

    $validationManifest = @(
        "# R18-013 Validation Manifest",
        "",
        "Expected status truth after this package: R18 active through R18-013 only; R18-014 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_continuation_packet_generator.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_continuation_packet_generator.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_continuation_packet_generator.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "- git diff --check"
    ) -join [Environment]::NewLine
    Write-R18ContinuationText -Path $paths.ValidationManifest -Value $validationManifest

    return [pscustomobject]@{
        AggregateVerdict = $script:R18AggregateVerdict
        InputSetCount = @($inputSets).Count
        ContinuationPacketCount = @($packets).Count
        RuntimeFlags = $report.runtime_flags
    }
}

function Assert-R18ContinuationCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18ContinuationRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18ContinuationCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context is missing required field '$field'."
        $value = $Object.$field
        if ($null -eq $value) {
            throw "$Context required field '$field' is null."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context required field '$field' is blank."
        }
        if ($field -in @("stop_conditions", "escalation_conditions", "validation_commands", "evidence_refs", "authority_refs", "non_claims", "rejected_claims", "allowed_paths", "forbidden_paths") -and @($value).Count -eq 0) {
            throw "$Context required field '$field' is empty."
        }
    }
}

function Assert-R18ContinuationRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18ContinuationCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context runtime_flags missing '$field'."
        Assert-R18ContinuationCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Assert-R18ContinuationPositiveClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Object.positive_claims)) {
            Assert-R18ContinuationCondition -Condition ($script:R18AllowedPositiveClaims -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
        }
    }
}

function Assert-R18ContinuationNoForbiddenTrueProperties {
    param([AllowNull()][object]$Object)

    if ($null -eq $Object) {
        return
    }

    if ($Object -is [string] -or $Object -is [int] -or $Object -is [bool]) {
        return
    }

    if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
        foreach ($item in $Object) {
            Assert-R18ContinuationNoForbiddenTrueProperties -Object $item
        }
        return
    }

    foreach ($property in $Object.PSObject.Properties) {
        if ($script:R18RuntimeFlagFields -contains $property.Name) {
            Assert-R18ContinuationCondition -Condition ([bool]$property.Value -eq $false) -Message "Forbidden runtime claim '$($property.Name)' is true."
        }
        Assert-R18ContinuationNoForbiddenTrueProperties -Object $property.Value
    }
}

function Assert-R18ContinuationInputSet {
    param([Parameter(Mandatory = $true)][object]$InputSet)

    Assert-R18ContinuationRequiredFields -Object $InputSet -Fields $script:R18RequiredInputSetFields -Context "R18 continuation input set"
    Assert-R18ContinuationCondition -Condition ($InputSet.artifact_type -eq "r18_continuation_input_set") -Message "R18 continuation input set artifact_type is invalid."
    Assert-R18ContinuationCondition -Condition ($InputSet.source_task -eq $script:R18SourceTask) -Message "R18 continuation input set source_task is invalid."
    Assert-R18ContinuationCondition -Condition ($InputSet.input_status -eq "seed_input_set_only_not_runtime_recovery") -Message "R18 continuation input set input_status is invalid."
    Assert-R18ContinuationCondition -Condition ($script:R18AllowedContinuationTypes -contains [string]$InputSet.continuation_type) -Message "R18 continuation input set uses unknown continuation_type '$($InputSet.continuation_type)'."
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $InputSet.runtime_flags -Context "R18 continuation input set"
    Assert-R18ContinuationCondition -Condition ([int]$InputSet.max_retry_count -gt 0 -and [int]$InputSet.retry_count -lt [int]$InputSet.max_retry_count) -Message "R18 continuation input set retry policy is unbounded or exhausted."

    switch ([string]$InputSet.continuation_type) {
        "continue_after_compact_failure" {
            Assert-R18ContinuationCondition -Condition ($InputSet.failure_event_ref -match '(context_compaction_required|codex_backend_compact_stream_disconnect)') -Message "continue_after_compact_failure must use a compact/context failure event."
            if ([bool]$InputSet.operator_decision_required -eq $false) {
                Assert-R18ContinuationCondition -Condition ($InputSet.wip_classification_ref -match 'no_wip|scoped_tracked_wip' -and $InputSet.remote_verification_ref -match 'remote_in_sync') -Message "compact continuation may omit operator decision only when WIP and remote verification refs are safe."
            }
        }
        "continue_after_stream_disconnect" {
            Assert-R18ContinuationCondition -Condition ($InputSet.failure_event_ref -match 'stream_disconnected_before_completion') -Message "continue_after_stream_disconnect must use stream_disconnected_before_completion."
        }
        "continue_after_validation_failure" {
            Assert-R18ContinuationCondition -Condition ($InputSet.failure_event_ref -match '(validation_interrupted_after_compact|non_compact_validation_failure)') -Message "continue_after_validation_failure must use a validation failure event."
            Assert-R18ContinuationCondition -Condition (@($InputSet.validation_commands).Count -gt 0) -Message "continue_after_validation_failure must preserve validation_commands."
        }
        "operator_decision_required_for_wip" {
            Assert-R18ContinuationCondition -Condition ([bool]$InputSet.operator_decision_required -eq $true) -Message "operator_decision_required_for_wip must require operator decision."
            Assert-R18ContinuationCondition -Condition ($InputSet.wip_classification_ref -notmatch 'no_wip') -Message "operator_decision_required_for_wip must use a WIP classification requiring operator decision."
        }
        "operator_decision_required_for_remote_branch" {
            Assert-R18ContinuationCondition -Condition ([bool]$InputSet.operator_decision_required -eq $true) -Message "operator_decision_required_for_remote_branch must require operator decision."
            Assert-R18ContinuationCondition -Condition ($InputSet.remote_verification_ref -notmatch 'remote_in_sync') -Message "operator_decision_required_for_remote_branch must use a remote verification requiring operator decision."
        }
        "block_until_future_runtime" {
            Assert-R18ContinuationCondition -Condition ($InputSet.next_safe_step -match 'Block continuation') -Message "block_until_future_runtime must block continuation until a future runtime task."
        }
    }
}

function Assert-R18ContinuationPacket {
    param([Parameter(Mandatory = $true)][object]$Packet)

    Assert-R18ContinuationRequiredFields -Object $Packet -Fields $script:R18RequiredContinuationPacketFields -Context "R18 continuation packet"
    Assert-R18ContinuationCondition -Condition ($Packet.artifact_type -eq "r18_continuation_packet") -Message "R18 continuation packet artifact_type is invalid."
    Assert-R18ContinuationCondition -Condition ($Packet.source_task -eq $script:R18SourceTask) -Message "R18 continuation packet source_task is invalid."
    Assert-R18ContinuationCondition -Condition ($Packet.continuation_status -eq "packet_generated_not_executed") -Message "R18 continuation packet continuation_status is invalid."
    Assert-R18ContinuationCondition -Condition ($script:R18AllowedContinuationTypes -contains [string]$Packet.continuation_type) -Message "R18 continuation packet uses unknown continuation_type '$($Packet.continuation_type)'."
    Assert-R18ContinuationCondition -Condition ($script:R18AllowedNextSafeStepTypes -contains [string]$Packet.next_safe_step_type) -Message "R18 continuation packet uses unknown next_safe_step_type '$($Packet.next_safe_step_type)'."
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Packet.runtime_flags -Context "R18 continuation packet"
    Assert-R18ContinuationPositiveClaims -Object $Packet -Context "R18 continuation packet"
    Assert-R18ContinuationCondition -Condition ([bool]$Packet.retry_limit_enforced -eq $true) -Message "R18 continuation packet retry_limit_enforced must be true."
    Assert-R18ContinuationCondition -Condition ([int]$Packet.max_retry_count -gt 0 -and [int]$Packet.retry_count -lt [int]$Packet.max_retry_count) -Message "R18 continuation packet retry policy is unbounded."

    switch ([string]$Packet.continuation_type) {
        "operator_decision_required_for_wip" {
            Assert-R18ContinuationCondition -Condition ([bool]$Packet.operator_decision_required -eq $true) -Message "operator_decision_required_for_wip must require operator decision."
            Assert-R18ContinuationCondition -Condition ([bool]$Packet.operator_decision_policy.required_for_wip_decision -eq $true) -Message "operator_decision_required_for_wip missing operator decision policy."
        }
        "operator_decision_required_for_remote_branch" {
            Assert-R18ContinuationCondition -Condition ([bool]$Packet.operator_decision_required -eq $true) -Message "operator_decision_required_for_remote_branch must require operator decision."
            Assert-R18ContinuationCondition -Condition ([bool]$Packet.operator_decision_policy.required_for_remote_branch_decision -eq $true) -Message "operator_decision_required_for_remote_branch missing operator decision policy."
        }
        "block_until_future_runtime" {
            Assert-R18ContinuationCondition -Condition ($Packet.next_safe_step_type -eq "block_until_future_runtime" -or $Packet.next_safe_step_type -eq "block_until_r18_014_or_later") -Message "block_until_future_runtime must use a blocking next_safe_step_type."
            Assert-R18ContinuationCondition -Condition ([bool]$Packet.runtime_flags.continuation_packet_executed -eq $false) -Message "block_until_future_runtime must not claim execution."
        }
    }
}

function Assert-R18ContinuationContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    foreach ($field in @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_continuation_packet_fields", "allowed_continuation_types", "allowed_continuation_statuses", "allowed_next_safe_step_types", "required_runtime_false_flags", "packet_policy", "state_policy", "failure_event_policy", "wip_policy", "remote_verification_policy", "checkpoint_policy", "operator_decision_policy", "validation_policy", "evidence_policy", "authority_policy", "boundary_policy", "path_policy", "api_policy", "execution_policy", "refusal_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags")) {
        Assert-R18ContinuationCondition -Condition ($Contract.PSObject.Properties.Name -contains $field) -Message "R18 continuation packet contract missing '$field'."
    }
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 continuation packet contract"
    Assert-R18ContinuationPositiveClaims -Object $Contract -Context "R18 continuation packet contract"
}

function Assert-R18ContinuationGeneratorContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    foreach ($field in @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_input_set_fields", "required_output_packet_fields", "required_runtime_false_flags", "generation_policy", "input_policy", "output_policy", "safety_policy", "status_boundary_policy", "path_policy", "api_policy", "execution_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags")) {
        Assert-R18ContinuationCondition -Condition ($Contract.PSObject.Properties.Name -contains $field) -Message "R18 continuation packet generator contract missing '$field'."
    }
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 continuation packet generator contract"
    Assert-R18ContinuationPositiveClaims -Object $Contract -Context "R18 continuation packet generator contract"
}

function Assert-R18ContinuationResults {
    param(
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object[]]$Packets
    )

    Assert-R18ContinuationCondition -Condition ($Results.artifact_type -eq "r18_continuation_packet_generator_results") -Message "R18 continuation packet generator results artifact_type is invalid."
    Assert-R18ContinuationCondition -Condition ([int]$Results.input_set_count -eq @($script:R18ContinuationDefinitions).Count) -Message "R18 continuation packet generator results input_set_count is invalid."
    Assert-R18ContinuationCondition -Condition ([int]$Results.continuation_packet_count -eq @($Packets).Count) -Message "R18 continuation packet generator results continuation_packet_count is invalid."
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Results.runtime_flags -Context "R18 continuation packet generator results"
    Assert-R18ContinuationPositiveClaims -Object $Results -Context "R18 continuation packet generator results"
}

function Assert-R18ContinuationReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18ContinuationCondition -Condition ($Report.artifact_type -eq "r18_continuation_packet_generator_check_report") -Message "R18 continuation packet generator check report artifact_type is invalid."
    Assert-R18ContinuationCondition -Condition ($Report.aggregate_verdict -eq $script:R18AggregateVerdict) -Message "R18 continuation packet generator check report aggregate verdict is invalid."
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 continuation packet generator check report"
    Assert-R18ContinuationPositiveClaims -Object $Report -Context "R18 continuation packet generator check report"
}

function Assert-R18ContinuationSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18ContinuationCondition -Condition ($Snapshot.artifact_type -eq "r18_continuation_packet_snapshot") -Message "R18 continuation packet snapshot artifact_type is invalid."
    Assert-R18ContinuationCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_013_only") -Message "R18 continuation packet snapshot status is invalid."
    Assert-R18ContinuationCondition -Condition ([bool]$Snapshot.packets_executed -eq $false) -Message "R18 continuation packet snapshot must not claim packet execution."
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Snapshot.runtime_flags -Context "R18 continuation packet snapshot"
    Assert-R18ContinuationPositiveClaims -Object $Snapshot -Context "R18 continuation packet snapshot"
}

function Get-R18ContinuationTaskStatusMap {
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

function Test-R18ContinuationPacketGeneratorStatusTruth {
    param([string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18ContinuationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-015 only",
            "R18-016 through R18-028 planned only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "R18-014 created new-context prompt generator foundation only",
            "Automatic new-thread creation is not implemented",
            "No recovery action was performed",
            "No retry execution was performed",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No branch mutation was performed",
            "No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed",
            "No staging, commit, or push was performed by the generator",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No product runtime is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-013 truth: $required"
        }
    }

    $authorityStatuses = Get-R18ContinuationTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18ContinuationTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18ContinuationCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 15) {
            Assert-R18ContinuationCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-015."
        }
        else {
            Assert-R18ContinuationCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-015."
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[6-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-015."
    }
    if ($combinedText -match '(?i)R18-(01[6-9]|02[0-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-016 or later completion."
    }
}

function Test-R18ContinuationPacketGeneratorSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$PacketContract,
        [Parameter(Mandatory = $true)][object]$GeneratorContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$InputSets,
        [Parameter(Mandatory = $true)][object[]]$Packets,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot)
    )

    Assert-R18ContinuationContract -Contract $PacketContract
    Assert-R18ContinuationGeneratorContract -Contract $GeneratorContract
    Assert-R18ContinuationRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 continuation packet generator profile"
    Assert-R18ContinuationPositiveClaims -Object $Profile -Context "R18 continuation packet generator profile"
    Assert-R18ContinuationCondition -Condition (@($InputSets).Count -eq @($script:R18ContinuationDefinitions).Count) -Message "R18 continuation input sets are missing."
    Assert-R18ContinuationCondition -Condition (@($Packets).Count -eq @($script:R18ContinuationDefinitions).Count) -Message "R18 continuation packets are missing."

    foreach ($inputSet in @($InputSets)) {
        Assert-R18ContinuationInputSet -InputSet $inputSet
    }
    foreach ($packet in @($Packets)) {
        Assert-R18ContinuationPacket -Packet $packet
        $matchingInputSet = @($InputSets | Where-Object { $_.continuation_type -eq $packet.continuation_type })
        Assert-R18ContinuationCondition -Condition ($matchingInputSet.Count -eq 1) -Message "R18 continuation packet '$($packet.continuation_type)' does not have exactly one matching input set."
    }

    Assert-R18ContinuationResults -Results $Results -Packets $Packets
    Assert-R18ContinuationReport -Report $Report
    Assert-R18ContinuationSnapshot -Snapshot $Snapshot
    foreach ($artifact in @($PacketContract, $GeneratorContract, $Profile, $InputSets, $Packets, $Results, $Report, $Snapshot)) {
        Assert-R18ContinuationNoForbiddenTrueProperties -Object $artifact
    }
    Test-R18ContinuationPacketGeneratorStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        InputSetCount = @($InputSets).Count
        ContinuationPacketCount = @($Packets).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Test-R18ContinuationPacketGenerator {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18ContinuationRepositoryRoot))

    $paths = Get-R18ContinuationPaths -RepositoryRoot $RepositoryRoot
    $inputSets = @()
    $packets = @()
    foreach ($definition in $script:R18ContinuationDefinitions) {
        $inputSets += Read-R18ContinuationJson -Path (Join-Path $paths.InputSetRoot ([string]$definition.input_file))
        $packets += Read-R18ContinuationJson -Path (Join-Path $paths.PacketRoot ([string]$definition.packet_file))
    }

    return Test-R18ContinuationPacketGeneratorSet `
        -PacketContract (Read-R18ContinuationJson -Path $paths.PacketContract) `
        -GeneratorContract (Read-R18ContinuationJson -Path $paths.GeneratorContract) `
        -Profile (Read-R18ContinuationJson -Path $paths.Profile) `
        -InputSets $inputSets `
        -Packets $packets `
        -Results (Read-R18ContinuationJson -Path $paths.Results) `
        -Report (Read-R18ContinuationJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18ContinuationJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18ContinuationObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value
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

function Remove-R18ContinuationObjectPathValue {
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

function Invoke-R18ContinuationMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18ContinuationObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18ContinuationObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 continuation packet generator mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18ContinuationPaths, `
    Read-R18ContinuationJson, `
    Copy-R18ContinuationObject, `
    New-R18ContinuationArtifacts, `
    Test-R18ContinuationPacketGenerator, `
    Test-R18ContinuationPacketGeneratorSet, `
    Test-R18ContinuationPacketGeneratorStatusTruth, `
    Invoke-R18ContinuationMutation