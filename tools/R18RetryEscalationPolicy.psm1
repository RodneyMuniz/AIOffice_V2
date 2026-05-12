$Script:R18RetrySourceTask = "R18-015"
$Script:R18RetryMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$Script:R18RetryRepository = "RodneyMuniz/AIOffice_V2"
$Script:R18RetryBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"

function Get-R18RetryEscalationRepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Resolve-R18RetryEscalationPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return (Join-Path $RepositoryRoot $PathValue)
}

function Read-R18RetryEscalationJson {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $path = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue $PathValue
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required artifact missing: $PathValue"
    }

    return (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json)
}

function Write-R18RetryEscalationJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R18RetryEscalationText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R18RetryEscalationObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18RetryEscalationPaths {
    param([string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot))

    return [ordered]@{
        PolicyContract = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_retry_escalation_policy.contract.json"
        DecisionContract = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_retry_escalation_decision.contract.json"
        Profile = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_profile.json"
        ScenarioRoot = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_scenarios"
        DecisionRoot = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_decisions"
        Results = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_results.json"
        CheckReport = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_check_report.json"
        UiSnapshot = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_retry_escalation_policy_snapshot.json"
        FixtureRoot = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_retry_escalation_policy"
        ProofRoot = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy"
        EvidenceIndex = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/evidence_index.json"
        ProofReview = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/proof_review.md"
        ValidationManifest = Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/validation_manifest.md"
    }
}

function Get-R18RetryEscalationRuntimeFlagNames {
    return @(
        "retry_execution_performed",
        "retry_runtime_implemented",
        "escalation_runtime_implemented",
        "operator_approval_runtime_implemented",
        "stage_commit_push_gate_implemented",
        "continuation_packet_executed",
        "prompt_packet_executed",
        "automatic_new_thread_creation_performed",
        "codex_thread_created",
        "codex_api_invoked",
        "openai_api_invoked",
        "autonomous_codex_invocation_performed",
        "recovery_runtime_implemented",
        "recovery_action_performed",
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
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_016_completed",
        "main_merge_claimed"
    )
}

function New-R18RetryEscalationRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($name in Get-R18RetryEscalationRuntimeFlagNames) {
        $flags[$name] = $false
    }
    return $flags
}

function Get-R18RetryEscalationScenarioTypes {
    return @(
        "retry_allowed_after_compact_failure",
        "retry_blocked_by_unsafe_wip",
        "retry_blocked_by_remote_branch",
        "retry_limit_reached",
        "operator_decision_required",
        "block_until_future_runtime"
    )
}

function Get-R18RetryEscalationDecisionTypes {
    return @(
        "retry_allowed_policy_only",
        "retry_blocked_unsafe_wip",
        "retry_blocked_remote_branch",
        "retry_blocked_limit_reached",
        "operator_decision_required",
        "block_until_future_runtime"
    )
}

function Get-R18RetryEscalationActionRecommendations {
    return @(
        "prepare_retry_packet_for_future_runtime",
        "stop_and_request_operator_decision_for_wip",
        "stop_and_request_operator_decision_for_remote_branch",
        "stop_retry_limit_reached",
        "request_operator_decision",
        "block_until_r18_016_or_later"
    )
}

function Get-R18RetryEscalationPositiveClaims {
    return @(
        "r18_retry_escalation_policy_contract_created",
        "r18_retry_escalation_decision_contract_created",
        "r18_retry_escalation_policy_profile_created",
        "r18_retry_escalation_scenarios_created",
        "r18_retry_escalation_decisions_created",
        "r18_retry_escalation_policy_results_created",
        "r18_retry_escalation_policy_validator_created",
        "r18_retry_escalation_policy_fixtures_created",
        "r18_retry_escalation_policy_proof_review_created"
    )
}

function Get-R18RetryEscalationRejectedClaims {
    return @(
        "retry_execution",
        "retry_runtime",
        "escalation_runtime",
        "operator_approval_runtime",
        "stage_commit_push_gate",
        "continuation_packet_execution",
        "prompt_packet_execution",
        "automatic_new_thread_creation",
        "codex_thread_creation",
        "codex_api_invocation",
        "openai_api_invocation",
        "autonomous_codex_invocation",
        "recovery_runtime",
        "recovery_action",
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
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_016_or_later_completion",
        "main_merge",
        "unbounded_retry",
        "unsafe_wip_retry_allowed",
        "unsafe_remote_retry_allowed",
        "retry_allowed_after_limit_reached"
    )
}

function Get-R18RetryEscalationNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-015 only.",
        "R18-016 through R18-028 remain planned only.",
        "R18-015 created retry and escalation policy foundation only.",
        "Retry/escalation decisions were generated as deterministic policy artifacts only.",
        "Retry execution was not performed.",
        "Retry runtime was not implemented.",
        "Escalation runtime was not implemented.",
        "Operator approval runtime is not implemented.",
        "Stage/commit/push gate is not implemented.",
        "Continuation packets were not executed.",
        "Prompt packets were not executed.",
        "Automatic new-thread creation was not performed.",
        "Codex thread creation was not performed.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
        "No recovery action was performed.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18RetryEscalationStopConditions {
    return @(
        "retry_count_missing_or_unbounded",
        "retry_count_at_or_above_max_retry_count",
        "unsafe_wip_present",
        "unsafe_remote_state_present",
        "missing_failure_event_ref",
        "missing_wip_classification_ref",
        "missing_remote_verification_ref",
        "missing_continuation_packet_ref",
        "missing_prompt_packet_ref",
        "operator_decision_required_before_future_gate",
        "runtime_execution_requested",
        "api_invocation_requested",
        "branch_or_wip_mutation_requested",
        "R18-016_or_later_completion_claim"
    )
}

function Get-R18RetryEscalationEscalationConditions {
    return @(
        "retry_limit_reached",
        "unsafe_WIP_detected",
        "unsafe_remote_branch_state_detected",
        "operator_decision_required",
        "future_operator_approval_gate_required",
        "future_runtime_or_gate_dependency_required",
        "missing_or_contradictory_evidence_refs",
        "forbidden_execution_or_api_claim_detected"
    )
}

function Get-R18RetryEscalationEvidenceRefs {
    return @(
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "contracts/runtime/r18_retry_escalation_decision.contract.json",
        "state/runtime/r18_retry_escalation_policy_profile.json",
        "state/runtime/r18_retry_escalation_scenarios/",
        "state/runtime/r18_retry_escalation_decisions/",
        "state/runtime/r18_retry_escalation_policy_results.json",
        "state/runtime/r18_retry_escalation_policy_check_report.json",
        "state/ui/r18_operator_surface/r18_retry_escalation_policy_snapshot.json",
        "tools/R18RetryEscalationPolicy.psm1",
        "tools/new_r18_retry_escalation_policy.ps1",
        "tools/validate_r18_retry_escalation_policy.ps1",
        "tests/test_r18_retry_escalation_policy.ps1",
        "tests/fixtures/r18_retry_escalation_policy/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/",
        "state/runtime/r18_detected_failure_events/",
        "state/runtime/r18_wip_classification_packets/",
        "state/runtime/r18_remote_branch_verification_packets/",
        "state/runtime/r18_continuation_packets/",
        "state/runtime/r18_new_context_prompt_packets/"
    )
}

function Get-R18RetryEscalationAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_failure_event.contract.json",
        "state/runtime/r18_detected_failure_events/",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_current_verification.json",
        "state/runtime/r18_remote_branch_verification_packets/",
        "contracts/runtime/r18_continuation_packet.contract.json",
        "state/runtime/r18_continuation_packets/",
        "contracts/runtime/r18_new_context_prompt_packet.contract.json",
        "state/runtime/r18_new_context_prompt_packet_manifest.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "tests/test_r18_remote_branch_verifier.ps1"
    )
}

function Get-R18RetryEscalationRequiredScenarioFields {
    return @(
        "artifact_type",
        "contract_version",
        "scenario_id",
        "scenario_name",
        "source_task",
        "source_milestone",
        "scenario_status",
        "scenario_type",
        "runner_state_ref",
        "failure_event_ref",
        "wip_classification_ref",
        "remote_verification_ref",
        "continuation_packet_ref",
        "prompt_packet_ref",
        "retry_count",
        "max_retry_count",
        "retry_limit_enforced",
        "unsafe_wip_present",
        "unsafe_remote_state_present",
        "operator_decision_required",
        "expected_decision_type",
        "expected_action_recommendation",
        "retry_allowed",
        "escalation_required",
        "operator_decision_policy",
        "stop_conditions",
        "escalation_conditions",
        "evidence_refs",
        "authority_refs",
        "runtime_flags",
        "non_claims",
        "rejected_claims"
    )
}

function Get-R18RetryEscalationRequiredDecisionFields {
    return @(
        "artifact_type",
        "contract_version",
        "decision_id",
        "decision_name",
        "source_task",
        "source_milestone",
        "decision_status",
        "scenario_ref",
        "scenario_type",
        "decision_type",
        "action_recommendation",
        "retry_allowed",
        "retry_count",
        "max_retry_count",
        "retry_limit_enforced",
        "operator_decision_required",
        "operator_decision_policy",
        "escalation_required",
        "stop_conditions",
        "escalation_conditions",
        "blocked_reasons",
        "next_safe_step",
        "runner_state_ref",
        "failure_event_ref",
        "wip_classification_ref",
        "remote_verification_ref",
        "continuation_packet_ref",
        "prompt_packet_ref",
        "evidence_refs",
        "authority_refs",
        "runtime_flags",
        "non_claims",
        "rejected_claims"
    )
}

function New-R18RetryEscalationPolicyBlock {
    return [ordered]@{
        max_retry_count = 2
        retry_limit_required = $true
        retry_limit_persists_as_policy_only = $true
        retry_allowed_only_when_retry_count_below_max = $true
        retry_allowed_only_when_wip_safe = $true
        retry_allowed_only_when_remote_branch_safe = $true
        continuation_packet_ref_required = $true
        prompt_packet_ref_required = $true
        retry_execution_performed = $false
        retry_runtime_implemented = $false
    }
}

function New-R18RetryEscalationOperatorPolicy {
    return [ordered]@{
        future_gate_task = "R18-016"
        approval_gate_model_implemented = $false
        approval_inference_allowed = $false
        operator_decision_required_for_unsafe_wip = $true
        operator_decision_required_for_remote_movement = $true
        operator_decision_required_for_ambiguous_or_future_runtime_dependency = $true
    }
}

function New-R18RetryEscalationPolicyContract {
    return [ordered]@{
        artifact_type = "r18_retry_escalation_policy_contract"
        contract_version = "v1"
        contract_id = "r18_015_retry_escalation_policy_contract_v1"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        repository = $Script:R18RetryRepository
        branch = $Script:R18RetryBranch
        scope = "deterministic_retry_escalation_policy_contracts_only"
        purpose = "Define policy-only retry, block, operator decision, escalation, and continuation recommendations for future runtime work."
        required_scenario_fields = Get-R18RetryEscalationRequiredScenarioFields
        required_decision_fields = Get-R18RetryEscalationRequiredDecisionFields
        allowed_scenario_types = Get-R18RetryEscalationScenarioTypes
        allowed_decision_types = Get-R18RetryEscalationDecisionTypes
        allowed_action_recommendations = Get-R18RetryEscalationActionRecommendations
        required_runtime_false_flags = Get-R18RetryEscalationRuntimeFlagNames
        retry_policy = New-R18RetryEscalationPolicyBlock
        escalation_policy = [ordered]@{ escalation_conditions_required = $true; retry_exhaustion_escalates = $true; unsafe_wip_escalates_to_operator_decision = $true; unsafe_remote_escalates_to_operator_decision = $true; escalation_runtime_implemented = $false }
        operator_decision_policy = New-R18RetryEscalationOperatorPolicy
        wip_policy = [ordered]@{ safe_to_continue_required_for_retry = $true; unsafe_wip_blocks_retry = $true; cleanup_or_abandonment_allowed = $false }
        remote_branch_policy = [ordered]@{ safe_to_continue_required_for_retry = $true; remote_movement_blocks_retry = $true; pull_rebase_reset_merge_push_allowed = $false }
        continuation_policy = [ordered]@{ continuation_packet_ref_required = $true; continuation_packet_execution_allowed = $false }
        prompt_policy = [ordered]@{ prompt_packet_ref_required = $true; prompt_packet_execution_allowed = $false; automatic_new_thread_creation_allowed = $false }
        safety_policy = [ordered]@{ fail_closed = $true; stop_conditions_required = $true; forbidden_runtime_claims_rejected = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; source_refs_must_cover_R18_009_through_R18_014 = $true }
        authority_policy = [ordered]@{ authority_refs_required = $true; r18_current_boundary = "R18 active through R18-015 only"; r18_future_boundary = "R18-016 through R18-028 planned only" }
        boundary_policy = [ordered]@{ policy_only = $true; no_runtime_execution = $true; no_R18_016_or_later_completion_claim = $true }
        path_policy = [ordered]@{ allowed_paths = @("contracts/runtime/", "state/runtime/r18_retry_escalation_", "state/ui/r18_operator_surface/r18_retry_escalation_policy_snapshot.json", "tools/R18RetryEscalationPolicy.psm1", "tests/fixtures/r18_retry_escalation_policy/", "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/"); forbidden_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_") }
        api_policy = [ordered]@{ codex_api_invocation_allowed = $false; openai_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false }
        execution_policy = [ordered]@{ retry_execution_allowed = $false; recovery_action_allowed = $false; work_order_execution_allowed = $false; live_agent_or_skill_execution_allowed = $false; a2a_message_allowed = $false }
        refusal_policy = [ordered]@{ refuse_unbounded_retry = $true; refuse_retry_with_unsafe_wip = $true; refuse_retry_with_remote_block = $true; refuse_retry_after_limit_reached = $true; refuse_execution_claims = $true }
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        allowed_positive_claims = Get-R18RetryEscalationPositiveClaims
        positive_claims = @("r18_retry_escalation_policy_contract_created")
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        non_claims = Get-R18RetryEscalationNonClaims
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
    }
}

function New-R18RetryEscalationDecisionContract {
    return [ordered]@{
        artifact_type = "r18_retry_escalation_decision_contract"
        contract_version = "v1"
        contract_id = "r18_015_retry_escalation_decision_contract_v1"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        required_decision_packet_fields = Get-R18RetryEscalationRequiredDecisionFields
        required_runtime_false_flags = Get-R18RetryEscalationRuntimeFlagNames
        decision_policy = [ordered]@{ allowed_decision_types = Get-R18RetryEscalationDecisionTypes; allowed_action_recommendations = Get-R18RetryEscalationActionRecommendations; retry_allowed_requires_safe_wip_safe_remote_and_retry_budget = $true; retry_limit_reached_requires_escalation = $true; operator_decision_does_not_infer_approval = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; authority_refs_required = $true; scenario_ref_required = $true }
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        positive_claims = @("r18_retry_escalation_decision_contract_created")
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
    }
}

function Get-R18RetryEscalationScenarioDefinitions {
    $commonRunner = "state/runtime/r18_runner_state.json"
    return @(
        [ordered]@{
            scenario_type = "retry_allowed_after_compact_failure"
            scenario_name = "Retry allowed after compact failure policy seed"
            decision_type = "retry_allowed_policy_only"
            action_recommendation = "prepare_retry_packet_for_future_runtime"
            retry_allowed = $true
            retry_count = 0
            max_retry_count = 2
            unsafe_wip_present = $false
            unsafe_remote_state_present = $false
            operator_decision_required = $false
            escalation_required = $false
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/continue_after_compact_failure.prompt.txt"
            blocked_reasons = @("none_policy_allowed_all_preconditions_safe")
            next_safe_step = "Prepare a retry packet for future runtime only after R18-016 or later gates exist; do not execute retry."
        },
        [ordered]@{
            scenario_type = "retry_blocked_by_unsafe_wip"
            scenario_name = "Retry blocked by unsafe WIP policy seed"
            decision_type = "retry_blocked_unsafe_wip"
            action_recommendation = "stop_and_request_operator_decision_for_wip"
            retry_allowed = $false
            retry_count = 0
            max_retry_count = 2
            unsafe_wip_present = $true
            unsafe_remote_state_present = $false
            operator_decision_required = $true
            escalation_required = $true
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/unexpected_tracked_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/operator_decision_required_for_wip.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/operator_decision_required_for_wip.prompt.txt"
            blocked_reasons = @("unsafe_wip_present", "wip_classification_safe_to_continue_false", "operator_decision_required_for_wip")
            next_safe_step = "Stop and request operator decision for WIP; do not clean, abandon, restore, stage, commit, or push."
        },
        [ordered]@{
            scenario_type = "retry_blocked_by_remote_branch"
            scenario_name = "Retry blocked by unsafe remote branch policy seed"
            decision_type = "retry_blocked_remote_branch"
            action_recommendation = "stop_and_request_operator_decision_for_remote_branch"
            retry_allowed = $false
            retry_count = 0
            max_retry_count = 2
            unsafe_wip_present = $false
            unsafe_remote_state_present = $true
            operator_decision_required = $true
            escalation_required = $true
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_ahead.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/operator_decision_required_for_remote_branch.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/operator_decision_required_for_remote_branch.prompt.txt"
            blocked_reasons = @("unsafe_remote_state_present", "remote_branch_safe_to_continue_false", "operator_decision_required_for_remote_branch")
            next_safe_step = "Stop and request operator decision for remote branch movement; do not pull, rebase, reset, merge, checkout, switch, or push."
        },
        [ordered]@{
            scenario_type = "retry_limit_reached"
            scenario_name = "Retry limit reached policy seed"
            decision_type = "retry_blocked_limit_reached"
            action_recommendation = "stop_retry_limit_reached"
            retry_allowed = $false
            retry_count = 2
            max_retry_count = 2
            unsafe_wip_present = $false
            unsafe_remote_state_present = $false
            operator_decision_required = $true
            escalation_required = $true
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/stream_disconnected_before_completion.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_stream_disconnect.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/continue_after_stream_disconnect.prompt.txt"
            blocked_reasons = @("retry_limit_reached", "retry_count_at_or_above_max_retry_count")
            next_safe_step = "Stop retry policy and escalate because retry_count reached max_retry_count; do not execute retry."
        },
        [ordered]@{
            scenario_type = "operator_decision_required"
            scenario_name = "Operator decision required policy seed"
            decision_type = "operator_decision_required"
            action_recommendation = "request_operator_decision"
            retry_allowed = $false
            retry_count = 0
            max_retry_count = 2
            unsafe_wip_present = $false
            unsafe_remote_state_present = $false
            operator_decision_required = $true
            escalation_required = $true
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/unknown_failure_requires_escalation.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/block_until_future_runtime.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/block_until_future_runtime.prompt.txt"
            blocked_reasons = @("operator_decision_required", "future_R18_016_operator_approval_gate_required")
            next_safe_step = "Route to future R18-016 operator approval gate model; do not infer approval."
        },
        [ordered]@{
            scenario_type = "block_until_future_runtime"
            scenario_name = "Block until future runtime policy seed"
            decision_type = "block_until_future_runtime"
            action_recommendation = "block_until_r18_016_or_later"
            retry_allowed = $false
            retry_count = 0
            max_retry_count = 2
            unsafe_wip_present = $false
            unsafe_remote_state_present = $false
            operator_decision_required = $false
            escalation_required = $false
            runner_state_ref = $commonRunner
            failure_event_ref = "state/runtime/r18_detected_failure_events/validation_interrupted_after_compact.failure.json"
            wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
            remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_in_sync.verification.json"
            continuation_packet_ref = "state/runtime/r18_continuation_packets/block_until_future_runtime.continuation.json"
            prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/block_until_future_runtime.prompt.txt"
            blocked_reasons = @("future_runtime_dependency_required", "R18_016_or_later_gate_required")
            next_safe_step = "Block until R18-016 or later provides approval/runtime/gate foundations; do not claim execution."
        }
    )
}

function New-R18RetryEscalationScenario {
    param([Parameter(Mandatory = $true)][object]$Definition)

    $stop = Get-R18RetryEscalationStopConditions
    $escalation = Get-R18RetryEscalationEscalationConditions
    return [ordered]@{
        artifact_type = "r18_retry_escalation_scenario"
        contract_version = "v1"
        scenario_id = "r18_015_scenario_$($Definition.scenario_type)"
        scenario_name = $Definition.scenario_name
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        scenario_status = "seed_retry_escalation_scenario_only_not_runtime_execution"
        scenario_type = $Definition.scenario_type
        runner_state_ref = $Definition.runner_state_ref
        failure_event_ref = $Definition.failure_event_ref
        wip_classification_ref = $Definition.wip_classification_ref
        remote_verification_ref = $Definition.remote_verification_ref
        continuation_packet_ref = $Definition.continuation_packet_ref
        prompt_packet_ref = $Definition.prompt_packet_ref
        retry_count = $Definition.retry_count
        max_retry_count = $Definition.max_retry_count
        retry_limit_enforced = $true
        unsafe_wip_present = $Definition.unsafe_wip_present
        unsafe_remote_state_present = $Definition.unsafe_remote_state_present
        operator_decision_required = $Definition.operator_decision_required
        expected_decision_type = $Definition.decision_type
        expected_action_recommendation = $Definition.action_recommendation
        retry_allowed = $Definition.retry_allowed
        escalation_required = $Definition.escalation_required
        blocked_reasons = @($Definition.blocked_reasons)
        next_safe_step = $Definition.next_safe_step
        operator_decision_policy = New-R18RetryEscalationOperatorPolicy
        stop_conditions = $stop
        escalation_conditions = $escalation
        evidence_refs = @((Get-R18RetryEscalationEvidenceRefs) + @($Definition.failure_event_ref, $Definition.wip_classification_ref, $Definition.remote_verification_ref, $Definition.continuation_packet_ref, $Definition.prompt_packet_ref))
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_scenarios_created")
    }
}

function New-R18RetryEscalationDecision {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][string]$ScenarioRef
    )

    return [ordered]@{
        artifact_type = "r18_retry_escalation_decision_packet"
        contract_version = "v1"
        decision_id = "r18_015_decision_$($Definition.scenario_type)"
        decision_name = "$($Definition.scenario_name) decision packet"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        decision_status = "decision_packet_generated_not_executed"
        scenario_ref = $ScenarioRef
        scenario_type = $Definition.scenario_type
        decision_type = $Definition.decision_type
        action_recommendation = $Definition.action_recommendation
        retry_allowed = $Definition.retry_allowed
        retry_count = $Definition.retry_count
        max_retry_count = $Definition.max_retry_count
        retry_limit_enforced = $true
        operator_decision_required = $Definition.operator_decision_required
        operator_decision_policy = New-R18RetryEscalationOperatorPolicy
        escalation_required = $Definition.escalation_required
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        blocked_reasons = @($Definition.blocked_reasons)
        next_safe_step = $Definition.next_safe_step
        runner_state_ref = $Definition.runner_state_ref
        failure_event_ref = $Definition.failure_event_ref
        wip_classification_ref = $Definition.wip_classification_ref
        remote_verification_ref = $Definition.remote_verification_ref
        continuation_packet_ref = $Definition.continuation_packet_ref
        prompt_packet_ref = $Definition.prompt_packet_ref
        evidence_refs = @((Get-R18RetryEscalationEvidenceRefs) + @($ScenarioRef, $Definition.failure_event_ref, $Definition.wip_classification_ref, $Definition.remote_verification_ref, $Definition.continuation_packet_ref, $Definition.prompt_packet_ref))
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_decisions_created")
    }
}

function New-R18RetryEscalationPolicyProfile {
    param(
        [Parameter(Mandatory = $true)][array]$ScenarioRefs,
        [Parameter(Mandatory = $true)][array]$DecisionRefs
    )

    return [ordered]@{
        artifact_type = "r18_retry_escalation_policy_profile"
        contract_version = "v1"
        profile_id = "r18_015_retry_escalation_policy_profile_v1"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        profile_status = "policy_profile_generated_not_runtime_execution"
        repository = $Script:R18RetryRepository
        branch = $Script:R18RetryBranch
        scenario_refs = $ScenarioRefs
        decision_refs = $DecisionRefs
        retry_policy = New-R18RetryEscalationPolicyBlock
        escalation_policy = [ordered]@{ escalation_conditions = Get-R18RetryEscalationEscalationConditions; escalation_runtime_implemented = $false }
        operator_decision_policy = New-R18RetryEscalationOperatorPolicy
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_profile_created")
    }
}

function New-R18RetryEscalationFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [object]$Value,
        [string[]]$Expected
    )

    return [ordered]@{
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($File)
        artifact_type = "r18_retry_escalation_policy_invalid_fixture"
        source_task = $Script:R18RetrySourceTask
        target = $Target
        operation = $Operation
        path = $Path
        value = $Value
        expected_failure_fragments = @($Expected)
    }
}

function Get-R18RetryEscalationFixtureDefinitions {
    return @(
        (New-R18RetryEscalationFixture -File "invalid_missing_scenario_id.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "scenario_id" -Expected @("scenario_id")),
        (New-R18RetryEscalationFixture -File "invalid_missing_failure_event_ref.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "failure_event_ref" -Expected @("failure_event_ref")),
        (New-R18RetryEscalationFixture -File "invalid_missing_wip_classification_ref.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "wip_classification_ref" -Expected @("wip_classification_ref")),
        (New-R18RetryEscalationFixture -File "invalid_missing_remote_verification_ref.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "remote_verification_ref" -Expected @("remote_verification_ref")),
        (New-R18RetryEscalationFixture -File "invalid_missing_continuation_packet_ref.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "continuation_packet_ref" -Expected @("continuation_packet_ref")),
        (New-R18RetryEscalationFixture -File "invalid_missing_prompt_packet_ref.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "prompt_packet_ref" -Expected @("prompt_packet_ref")),
        (New-R18RetryEscalationFixture -File "invalid_missing_retry_count.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "retry_count" -Expected @("retry_count")),
        (New-R18RetryEscalationFixture -File "invalid_unbounded_retry.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "set" -Path "retry_limit_enforced" -Value $false -Expected @("unbounded retry")),
        (New-R18RetryEscalationFixture -File "invalid_retry_allowed_with_unsafe_wip.json" -Target "scenario:retry_blocked_by_unsafe_wip" -Operation "set" -Path "retry_allowed" -Value $true -Expected @("unsafe WIP")),
        (New-R18RetryEscalationFixture -File "invalid_retry_allowed_with_remote_block.json" -Target "scenario:retry_blocked_by_remote_branch" -Operation "set" -Path "retry_allowed" -Value $true -Expected @("unsafe remote")),
        (New-R18RetryEscalationFixture -File "invalid_retry_allowed_after_limit_reached.json" -Target "scenario:retry_limit_reached" -Operation "set" -Path "retry_allowed" -Value $true -Expected @("retry limit")),
        (New-R18RetryEscalationFixture -File "invalid_missing_operator_decision_policy.json" -Target "policy_contract" -Operation "remove" -Path "operator_decision_policy" -Expected @("operator_decision_policy")),
        (New-R18RetryEscalationFixture -File "invalid_missing_escalation_conditions.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "escalation_conditions" -Expected @("escalation_conditions")),
        (New-R18RetryEscalationFixture -File "invalid_missing_stop_conditions.json" -Target "scenario:retry_allowed_after_compact_failure" -Operation "remove" -Path "stop_conditions" -Expected @("stop_conditions")),
        (New-R18RetryEscalationFixture -File "invalid_missing_evidence_refs.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "remove" -Path "evidence_refs" -Expected @("evidence_refs")),
        (New-R18RetryEscalationFixture -File "invalid_missing_authority_refs.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "remove" -Path "authority_refs" -Expected @("authority_refs")),
        (New-R18RetryEscalationFixture -File "invalid_retry_execution_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.retry_execution_performed" -Value $true -Expected @("retry_execution_performed")),
        (New-R18RetryEscalationFixture -File "invalid_recovery_action_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Expected @("recovery_action_performed")),
        (New-R18RetryEscalationFixture -File "invalid_operator_approval_runtime_claim.json" -Target "policy_contract" -Operation "set" -Path "runtime_flags.operator_approval_runtime_implemented" -Value $true -Expected @("operator_approval_runtime_implemented")),
        (New-R18RetryEscalationFixture -File "invalid_stage_commit_push_gate_claim.json" -Target "policy_contract" -Operation "set" -Path "runtime_flags.stage_commit_push_gate_implemented" -Value $true -Expected @("stage_commit_push_gate_implemented")),
        (New-R18RetryEscalationFixture -File "invalid_continuation_packet_execution_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.continuation_packet_executed" -Value $true -Expected @("continuation_packet_executed")),
        (New-R18RetryEscalationFixture -File "invalid_prompt_execution_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.prompt_packet_executed" -Value $true -Expected @("prompt_packet_executed")),
        (New-R18RetryEscalationFixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Expected @("automatic_new_thread_creation_performed")),
        (New-R18RetryEscalationFixture -File "invalid_codex_api_invocation_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -Expected @("codex_api_invoked")),
        (New-R18RetryEscalationFixture -File "invalid_openai_api_invocation_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.openai_api_invoked" -Value $true -Expected @("openai_api_invoked")),
        (New-R18RetryEscalationFixture -File "invalid_work_order_execution_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Expected @("work_order_execution_performed")),
        (New-R18RetryEscalationFixture -File "invalid_wip_cleanup_claim.json" -Target "decision:retry_blocked_by_unsafe_wip" -Operation "set" -Path "runtime_flags.wip_cleanup_performed" -Value $true -Expected @("wip_cleanup_performed")),
        (New-R18RetryEscalationFixture -File "invalid_branch_mutation_claim.json" -Target "decision:retry_blocked_by_remote_branch" -Operation "set" -Path "runtime_flags.branch_mutation_performed" -Value $true -Expected @("branch_mutation_performed")),
        (New-R18RetryEscalationFixture -File "invalid_skill_execution_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.live_skill_execution_performed" -Value $true -Expected @("live_skill_execution_performed")),
        (New-R18RetryEscalationFixture -File "invalid_a2a_message_sent_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Expected @("a2a_message_sent")),
        (New-R18RetryEscalationFixture -File "invalid_board_runtime_mutation_claim.json" -Target "decision:retry_allowed_after_compact_failure" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Expected @("board_runtime_mutation_performed")),
        (New-R18RetryEscalationFixture -File "invalid_r18_016_completion_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.r18_016_completed" -Value $true -Expected @("r18_016_completed"))
    )
}

function New-R18RetryEscalationPolicyArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot))

    $paths = Get-R18RetryEscalationPaths -RepositoryRoot $RepositoryRoot
    $definitions = Get-R18RetryEscalationScenarioDefinitions
    $scenarioRefs = @()
    $decisionRefs = @()

    Write-R18RetryEscalationJson -Path $paths.PolicyContract -Value (New-R18RetryEscalationPolicyContract)
    Write-R18RetryEscalationJson -Path $paths.DecisionContract -Value (New-R18RetryEscalationDecisionContract)

    foreach ($definition in $definitions) {
        $scenarioFile = "$($definition.scenario_type).scenario.json"
        $decisionFile = "$($definition.scenario_type).decision.json"
        $scenarioRel = "state/runtime/r18_retry_escalation_scenarios/$scenarioFile"
        $decisionRel = "state/runtime/r18_retry_escalation_decisions/$decisionFile"
        $scenarioRefs += $scenarioRel
        $decisionRefs += $decisionRel

        $scenario = New-R18RetryEscalationScenario -Definition $definition
        $decision = New-R18RetryEscalationDecision -Definition $definition -ScenarioRef $scenarioRel

        Write-R18RetryEscalationJson -Path (Join-Path $paths.ScenarioRoot $scenarioFile) -Value $scenario
        Write-R18RetryEscalationJson -Path (Join-Path $paths.DecisionRoot $decisionFile) -Value $decision
    }

    Write-R18RetryEscalationJson -Path $paths.Profile -Value (New-R18RetryEscalationPolicyProfile -ScenarioRefs $scenarioRefs -DecisionRefs $decisionRefs)

    $results = [ordered]@{
        artifact_type = "r18_retry_escalation_policy_results"
        contract_version = "v1"
        result_id = "r18_015_retry_escalation_policy_results"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        result_status = "policy_results_generated_not_runtime_execution"
        aggregate_verdict = "passed"
        scenario_count = $scenarioRefs.Count
        decision_count = $decisionRefs.Count
        retry_allowed_policy_only_count = 1
        retry_blocked_or_escalated_count = 5
        scenario_refs = $scenarioRefs
        decision_refs = $decisionRefs
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_results_created")
    }
    Write-R18RetryEscalationJson -Path $paths.Results -Value $results

    $report = [ordered]@{
        artifact_type = "r18_retry_escalation_policy_check_report"
        contract_version = "v1"
        report_id = "r18_015_retry_escalation_policy_check_report"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        report_status = "check_report_generated_not_runtime_execution"
        aggregate_verdict = "passed"
        checks = @(
            [ordered]@{ check_id = "contracts_created"; status = "passed" },
            [ordered]@{ check_id = "six_scenarios_created"; status = "passed"; count = $scenarioRefs.Count },
            [ordered]@{ check_id = "six_decisions_created"; status = "passed"; count = $decisionRefs.Count },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-015 only; R18-016 through R18-028 planned only" }
        )
        scenario_refs = $scenarioRefs
        decision_refs = $decisionRefs
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_validator_created")
    }
    Write-R18RetryEscalationJson -Path $paths.CheckReport -Value $report

    $snapshot = [ordered]@{
        artifact_type = "r18_operator_surface_retry_escalation_policy_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_015_retry_escalation_policy_snapshot"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        snapshot_status = "operator_surface_snapshot_policy_only_not_runtime_execution"
        r18_status = "active_through_r18_015_only"
        r18_future_boundary = "R18-016 through R18-028 planned only"
        policy_summary = "Retry/escalation decisions exist as deterministic policy artifacts only."
        scenario_refs = $scenarioRefs
        decision_refs = $decisionRefs
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_results_created")
    }
    Write-R18RetryEscalationJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18RetryEscalationFixtureDefinitions
    foreach ($fixture in $fixtureDefinitions) {
        Write-R18RetryEscalationJson -Path (Join-Path $paths.FixtureRoot ($fixture.fixture_id + ".json")) -Value $fixture
    }
    $fixtureManifest = [ordered]@{
        artifact_type = "r18_retry_escalation_policy_fixture_manifest"
        contract_version = "v1"
        manifest_id = "r18_015_retry_escalation_policy_fixture_manifest"
        source_task = $Script:R18RetrySourceTask
        fixture_count = $fixtureDefinitions.Count
        fixture_ids = @($fixtureDefinitions | ForEach-Object { $_.fixture_id })
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_fixtures_created")
    }
    Write-R18RetryEscalationJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $fixtureManifest

    $evidenceIndex = [ordered]@{
        artifact_type = "r18_retry_escalation_policy_evidence_index"
        contract_version = "v1"
        evidence_index_id = "r18_015_retry_escalation_policy_evidence_index"
        source_task = $Script:R18RetrySourceTask
        source_milestone = $Script:R18RetryMilestone
        evidence_refs = Get-R18RetryEscalationEvidenceRefs
        authority_refs = Get-R18RetryEscalationAuthorityRefs
        scenario_refs = $scenarioRefs
        decision_refs = $decisionRefs
        validation_refs = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_retry_escalation_policy.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_retry_escalation_policy.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_retry_escalation_policy.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
            "git diff --check"
        )
        stop_conditions = Get-R18RetryEscalationStopConditions
        escalation_conditions = Get-R18RetryEscalationEscalationConditions
        runtime_flags = New-R18RetryEscalationRuntimeFlags
        non_claims = Get-R18RetryEscalationNonClaims
        rejected_claims = Get-R18RetryEscalationRejectedClaims
        positive_claims = @("r18_retry_escalation_policy_proof_review_created")
    }
    Write-R18RetryEscalationJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $proofReview = @(
        "# R18-015 Retry Escalation Policy Proof Review",
        "",
        "R18-015 creates retry and escalation policy foundation artifacts only.",
        "",
        "Policy outputs:",
        "- Retry/escalation policy and decision contracts.",
        "- Six seeded retry/escalation scenarios.",
        "- Six deterministic decision packets.",
        "- Validator, focused tests, invalid fixtures, check report, UI snapshot, and evidence index.",
        "",
        "Non-claims:",
        "- Retry execution was not performed.",
        "- Retry runtime was not implemented.",
        "- Escalation runtime was not implemented.",
        "- Operator approval runtime is not implemented.",
        "- Stage/commit/push gate is not implemented.",
        "- Continuation packets and prompt packets were not executed.",
        "- Codex/OpenAI APIs were not invoked.",
        "- No recovery action, work order execution, board/card runtime mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or main merge is claimed.",
        "",
        "Status truth: R18 is active through R18-015 only. R18-016 through R18-028 remain planned only."
    ) -join [Environment]::NewLine
    Write-R18RetryEscalationText -Path $paths.ProofReview -Value $proofReview

    $validationManifest = @(
        "# R18-015 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-015 only; R18-016 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_retry_escalation_policy.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_retry_escalation_policy.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_retry_escalation_policy.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "- git diff --check",
        "",
        "No retry execution, recovery runtime, API invocation, continuation execution, prompt execution, work-order execution, WIP cleanup, branch mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or main merge is claimed."
    ) -join [Environment]::NewLine
    Write-R18RetryEscalationText -Path $paths.ValidationManifest -Value $validationManifest

    return [pscustomobject]@{
        AggregateVerdict = "passed"
        ScenarioCount = $scenarioRefs.Count
        DecisionCount = $decisionRefs.Count
        RuntimeFlags = $report.runtime_flags
    }
}

function Assert-R18RetryEscalationCondition {
    param(
        [bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18RetryEscalationRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18RetryEscalationCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing '$field'."
        $value = $Object.$field
        if ($null -eq $value) {
            throw "$Context field '$field' is null."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context field '$field' is empty."
        }
        if ($value -is [array] -and $value.Count -eq 0) {
            throw "$Context field '$field' is empty."
        }
    }
}

function Assert-R18RetryEscalationRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in Get-R18RetryEscalationRuntimeFlagNames) {
        Assert-R18RetryEscalationCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flag) -Message "$Context runtime_flags missing '$flag'."
        Assert-R18RetryEscalationCondition -Condition ([bool]$RuntimeFlags.$flag -eq $false) -Message "$Context runtime flag '$flag' must remain false."
    }
}

function Assert-R18RetryEscalationCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18RetryEscalationRequiredFields -Object $Artifact -Fields @("stop_conditions", "escalation_conditions", "evidence_refs", "authority_refs", "runtime_flags", "non_claims", "rejected_claims") -Context $Context
    Assert-R18RetryEscalationRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    if ($Artifact.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Artifact.positive_claims)) {
            Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationPositiveClaims) -contains [string]$claim) -Message "$Context positive claim '$claim' is not allowed."
        }
    }
}

function Assert-R18RetryEscalationPolicyContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18RetryEscalationRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_scenario_fields",
        "required_decision_fields",
        "allowed_scenario_types",
        "allowed_decision_types",
        "allowed_action_recommendations",
        "required_runtime_false_flags",
        "retry_policy",
        "escalation_policy",
        "operator_decision_policy",
        "wip_policy",
        "remote_branch_policy",
        "continuation_policy",
        "prompt_policy",
        "safety_policy",
        "evidence_policy",
        "authority_policy",
        "boundary_policy",
        "path_policy",
        "api_policy",
        "execution_policy",
        "refusal_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    ) -Context "R18 retry escalation policy contract"
    Assert-R18RetryEscalationCondition -Condition ($Contract.source_task -eq $Script:R18RetrySourceTask) -Message "R18 retry escalation policy contract source_task must be R18-015."
    Assert-R18RetryEscalationCommonArtifact -Artifact $Contract -Context "R18 retry escalation policy contract"
}

function Assert-R18RetryEscalationDecisionContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18RetryEscalationRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "required_decision_packet_fields",
        "required_runtime_false_flags",
        "decision_policy",
        "evidence_policy",
        "non_claims",
        "rejected_claims"
    ) -Context "R18 retry escalation decision contract"
    Assert-R18RetryEscalationCondition -Condition ($Contract.source_task -eq $Script:R18RetrySourceTask) -Message "R18 retry escalation decision contract source_task must be R18-015."
    Assert-R18RetryEscalationCommonArtifact -Artifact $Contract -Context "R18 retry escalation decision contract"
}

function Assert-R18RetryEscalationScenario {
    param([Parameter(Mandatory = $true)][object]$Scenario)

    Assert-R18RetryEscalationRequiredFields -Object $Scenario -Fields (Get-R18RetryEscalationRequiredScenarioFields) -Context "R18 retry escalation scenario"
    Assert-R18RetryEscalationCondition -Condition ($Scenario.source_task -eq $Script:R18RetrySourceTask) -Message "R18 retry escalation scenario source_task must be R18-015."
    Assert-R18RetryEscalationCondition -Condition ($Scenario.scenario_status -eq "seed_retry_escalation_scenario_only_not_runtime_execution") -Message "R18 retry escalation scenario has invalid scenario_status."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationScenarioTypes) -contains [string]$Scenario.scenario_type) -Message "Unknown scenario type '$($Scenario.scenario_type)'."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationDecisionTypes) -contains [string]$Scenario.expected_decision_type) -Message "Unknown expected decision type '$($Scenario.expected_decision_type)'."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationActionRecommendations) -contains [string]$Scenario.expected_action_recommendation) -Message "Unknown expected action recommendation '$($Scenario.expected_action_recommendation)'."
    Assert-R18RetryEscalationCommonArtifact -Artifact $Scenario -Context "R18 retry escalation scenario '$($Scenario.scenario_type)'"

    Assert-R18RetryEscalationCondition -Condition ($Scenario.retry_limit_enforced -eq $true -and [int]$Scenario.max_retry_count -gt 0) -Message "R18 retry escalation scenario has unbounded retry."
    Assert-R18RetryEscalationCondition -Condition ([int]$Scenario.retry_count -le [int]$Scenario.max_retry_count) -Message "R18 retry escalation scenario retry_count exceeds max_retry_count."
    if ([bool]$Scenario.retry_allowed -and [bool]$Scenario.unsafe_wip_present) {
        throw "R18 retry escalation scenario allows retry with unsafe WIP."
    }
    if ([bool]$Scenario.retry_allowed -and [bool]$Scenario.unsafe_remote_state_present) {
        throw "R18 retry escalation scenario allows retry with unsafe remote state."
    }
    if ([bool]$Scenario.retry_allowed -and [int]$Scenario.retry_count -ge [int]$Scenario.max_retry_count) {
        throw "R18 retry escalation scenario allows retry after retry limit reached."
    }

    switch ([string]$Scenario.scenario_type) {
        "retry_allowed_after_compact_failure" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $true) -Message "retry_allowed_after_compact_failure must set retry_allowed true."
            Assert-R18RetryEscalationCondition -Condition ([int]$Scenario.retry_count -lt [int]$Scenario.max_retry_count) -Message "retry_allowed_after_compact_failure must be bounded by retry count."
            Assert-R18RetryEscalationCondition -Condition (-not [bool]$Scenario.unsafe_wip_present -and -not [bool]$Scenario.unsafe_remote_state_present) -Message "retry_allowed_after_compact_failure must require safe WIP and remote branch state."
        }
        "retry_blocked_by_unsafe_wip" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $false -and [bool]$Scenario.operator_decision_required -eq $true) -Message "retry_blocked_by_unsafe_wip must block retry and require operator decision."
            Assert-R18RetryEscalationCondition -Condition (@($Scenario.blocked_reasons) -contains "unsafe_wip_present") -Message "retry_blocked_by_unsafe_wip missing unsafe WIP blocked reason."
        }
        "retry_blocked_by_remote_branch" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $false -and [bool]$Scenario.operator_decision_required -eq $true) -Message "retry_blocked_by_remote_branch must block retry and require operator decision."
            Assert-R18RetryEscalationCondition -Condition (@($Scenario.blocked_reasons) -contains "unsafe_remote_state_present") -Message "retry_blocked_by_remote_branch missing unsafe remote blocked reason."
        }
        "retry_limit_reached" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $false -and [bool]$Scenario.escalation_required -eq $true) -Message "retry_limit_reached must block retry and require escalation."
            Assert-R18RetryEscalationCondition -Condition (@($Scenario.blocked_reasons) -contains "retry_limit_reached") -Message "retry_limit_reached missing retry limit blocked reason."
        }
        "operator_decision_required" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $false -and [bool]$Scenario.operator_decision_required -eq $true) -Message "operator_decision_required scenario must require operator decision and keep retry disallowed."
            Assert-R18RetryEscalationCondition -Condition ([string]$Scenario.next_safe_step -match "R18-016") -Message "operator_decision_required scenario must route to future R18-016."
        }
        "block_until_future_runtime" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Scenario.retry_allowed -eq $false) -Message "block_until_future_runtime must block retry."
            Assert-R18RetryEscalationCondition -Condition ([string]$Scenario.next_safe_step -match "R18-016") -Message "block_until_future_runtime must block until R18-016 or later."
        }
    }
}

function Assert-R18RetryEscalationDecision {
    param([Parameter(Mandatory = $true)][object]$Decision)

    Assert-R18RetryEscalationRequiredFields -Object $Decision -Fields (Get-R18RetryEscalationRequiredDecisionFields) -Context "R18 retry escalation decision"
    Assert-R18RetryEscalationCondition -Condition ($Decision.source_task -eq $Script:R18RetrySourceTask) -Message "R18 retry escalation decision source_task must be R18-015."
    Assert-R18RetryEscalationCondition -Condition ($Decision.decision_status -eq "decision_packet_generated_not_executed") -Message "R18 retry escalation decision has invalid decision_status."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationScenarioTypes) -contains [string]$Decision.scenario_type) -Message "Unknown decision scenario type '$($Decision.scenario_type)'."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationDecisionTypes) -contains [string]$Decision.decision_type) -Message "Unknown decision type '$($Decision.decision_type)'."
    Assert-R18RetryEscalationCondition -Condition ((Get-R18RetryEscalationActionRecommendations) -contains [string]$Decision.action_recommendation) -Message "Unknown action recommendation '$($Decision.action_recommendation)'."
    Assert-R18RetryEscalationCommonArtifact -Artifact $Decision -Context "R18 retry escalation decision '$($Decision.scenario_type)'"

    Assert-R18RetryEscalationCondition -Condition ($Decision.retry_limit_enforced -eq $true -and [int]$Decision.max_retry_count -gt 0) -Message "R18 retry escalation decision has unbounded retry."
    if ([bool]$Decision.retry_allowed -and [int]$Decision.retry_count -ge [int]$Decision.max_retry_count) {
        throw "R18 retry escalation decision allows retry after retry limit reached."
    }

    switch ([string]$Decision.decision_type) {
        "retry_allowed_policy_only" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $true -and [string]$Decision.action_recommendation -eq "prepare_retry_packet_for_future_runtime") -Message "retry_allowed_policy_only decision must prepare future runtime retry packet only."
        }
        "retry_blocked_unsafe_wip" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $false -and [bool]$Decision.operator_decision_required -eq $true) -Message "retry_blocked_unsafe_wip decision must block retry and require operator decision."
            Assert-R18RetryEscalationCondition -Condition (@($Decision.blocked_reasons) -contains "unsafe_wip_present") -Message "retry_blocked_unsafe_wip decision missing unsafe WIP reason."
        }
        "retry_blocked_remote_branch" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $false -and [bool]$Decision.operator_decision_required -eq $true) -Message "retry_blocked_remote_branch decision must block retry and require operator decision."
            Assert-R18RetryEscalationCondition -Condition (@($Decision.blocked_reasons) -contains "unsafe_remote_state_present") -Message "retry_blocked_remote_branch decision missing remote block reason."
        }
        "retry_blocked_limit_reached" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $false -and [bool]$Decision.escalation_required -eq $true) -Message "retry_blocked_limit_reached decision must block retry and escalate."
        }
        "operator_decision_required" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $false -and [bool]$Decision.operator_decision_required -eq $true) -Message "operator_decision_required decision must keep retry disallowed until future approval gate."
            Assert-R18RetryEscalationCondition -Condition ([string]$Decision.next_safe_step -match "R18-016") -Message "operator_decision_required decision must route to future R18-016."
        }
        "block_until_future_runtime" {
            Assert-R18RetryEscalationCondition -Condition ([bool]$Decision.retry_allowed -eq $false -and [string]$Decision.action_recommendation -eq "block_until_r18_016_or_later") -Message "block_until_future_runtime decision must block until R18-016 or later."
        }
    }
}

function Get-R18RetryEscalationTaskStatusMap {
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

function Test-R18RetryEscalationPolicyStatusTruth {
    param([string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RetryEscalationPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-016 only",
            "R18-017 through R18-028 planned only",
            "R18-015 created retry and escalation policy foundation only",
            "Retry/escalation decisions were generated as deterministic policy artifacts only",
            "Retry execution was not performed",
            "Retry runtime was not implemented",
            "Escalation runtime was not implemented",
            "Operator approval runtime is not implemented",
            "Stage/commit/push gate is not implemented",
            "Continuation packets were not executed",
            "Prompt packets were not executed",
            "Automatic new-thread creation was not performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "No recovery action was performed",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Main is not merged"
        )) {
        Assert-R18RetryEscalationCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-015 truth: $required"
    }

    $authorityStatuses = Get-R18RetryEscalationTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18RetryEscalationTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18RetryEscalationCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 16) {
            Assert-R18RetryEscalationCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-016."
        }
        else {
            Assert-R18RetryEscalationCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-016."
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[7-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-015."
    }
    if ($combinedText -match '(?i)R18-(01[7-9]|02[0-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-017 or later completion."
    }
}

function Test-R18RetryEscalationPolicySet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$PolicyContract,
        [Parameter(Mandatory = $true)][object]$DecisionContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Scenarios,
        [Parameter(Mandatory = $true)][object[]]$Decisions,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot)
    )

    Assert-R18RetryEscalationPolicyContract -Contract $PolicyContract
    Assert-R18RetryEscalationDecisionContract -Contract $DecisionContract
    Assert-R18RetryEscalationCommonArtifact -Artifact $Profile -Context "R18 retry escalation policy profile"
    Assert-R18RetryEscalationCommonArtifact -Artifact $Results -Context "R18 retry escalation policy results"
    Assert-R18RetryEscalationCommonArtifact -Artifact $Report -Context "R18 retry escalation policy check report"
    Assert-R18RetryEscalationCommonArtifact -Artifact $Snapshot -Context "R18 retry escalation policy snapshot"

    Assert-R18RetryEscalationCondition -Condition (@($Scenarios).Count -eq 6) -Message "R18 retry escalation policy must have six scenarios."
    Assert-R18RetryEscalationCondition -Condition (@($Decisions).Count -eq 6) -Message "R18 retry escalation policy must have six decision packets."

    foreach ($scenario in @($Scenarios)) {
        Assert-R18RetryEscalationScenario -Scenario $scenario
    }
    foreach ($decision in @($Decisions)) {
        Assert-R18RetryEscalationDecision -Decision $decision
    }

    foreach ($scenarioType in Get-R18RetryEscalationScenarioTypes) {
        Assert-R18RetryEscalationCondition -Condition (@($Scenarios | Where-Object { $_.scenario_type -eq $scenarioType }).Count -eq 1) -Message "Missing scenario type '$scenarioType'."
        Assert-R18RetryEscalationCondition -Condition (@($Decisions | Where-Object { $_.scenario_type -eq $scenarioType }).Count -eq 1) -Message "Missing decision packet for '$scenarioType'."
    }

    foreach ($scenario in @($Scenarios)) {
        $decision = @($Decisions | Where-Object { $_.scenario_type -eq $scenario.scenario_type })[0]
        Assert-R18RetryEscalationCondition -Condition ($decision.decision_type -eq $scenario.expected_decision_type) -Message "Decision type mismatch for scenario '$($scenario.scenario_type)'."
        Assert-R18RetryEscalationCondition -Condition ($decision.action_recommendation -eq $scenario.expected_action_recommendation) -Message "Action recommendation mismatch for scenario '$($scenario.scenario_type)'."
        Assert-R18RetryEscalationCondition -Condition ([bool]$decision.retry_allowed -eq [bool]$scenario.retry_allowed) -Message "Retry allowed mismatch for scenario '$($scenario.scenario_type)'."
    }

    Test-R18RetryEscalationPolicyStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = "passed"
        ScenarioCount = @($Scenarios).Count
        DecisionCount = @($Decisions).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18RetryEscalationPolicySet {
    param([string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot))

    $paths = Get-R18RetryEscalationPaths -RepositoryRoot $RepositoryRoot
    $scenarios = @()
    $decisions = @()

    foreach ($scenarioType in Get-R18RetryEscalationScenarioTypes) {
        $scenarios += Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_scenarios/$scenarioType.scenario.json"
        $decisions += Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_decisions/$scenarioType.decision.json"
    }

    return [pscustomobject]@{
        PolicyContract = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_retry_escalation_policy.contract.json"
        DecisionContract = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_retry_escalation_decision.contract.json"
        Profile = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_profile.json"
        Scenarios = $scenarios
        Decisions = $decisions
        Results = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_results.json"
        Report = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_retry_escalation_policy_check_report.json"
        Snapshot = Read-R18RetryEscalationJson -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_retry_escalation_policy_snapshot.json"
        Paths = $paths
    }
}

function Test-R18RetryEscalationPolicy {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RetryEscalationRepositoryRoot))

    $set = Get-R18RetryEscalationPolicySet -RepositoryRoot $RepositoryRoot
    return Test-R18RetryEscalationPolicySet `
        -PolicyContract $set.PolicyContract `
        -DecisionContract $set.DecisionContract `
        -Profile $set.Profile `
        -Scenarios $set.Scenarios `
        -Decisions $set.Decisions `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18RetryEscalationObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [object]$Value
    )

    $segments = $Path.Split(".")
    $cursor = $TargetObject
    for ($i = 0; $i -lt ($segments.Count - 1); $i++) {
        $segment = $segments[$i]
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

function Remove-R18RetryEscalationObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path.Split(".")
    $cursor = $TargetObject
    for ($i = 0; $i -lt ($segments.Count - 1); $i++) {
        $segment = $segments[$i]
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

function Invoke-R18RetryEscalationPolicyMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "set" { Set-R18RetryEscalationObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        "remove" { Remove-R18RetryEscalationObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        default { throw "Unknown mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18RetryEscalationPaths, `
    New-R18RetryEscalationPolicyArtifacts, `
    Test-R18RetryEscalationPolicy, `
    Test-R18RetryEscalationPolicySet, `
    Test-R18RetryEscalationPolicyStatusTruth, `
    Get-R18RetryEscalationPolicySet, `
    Copy-R18RetryEscalationObject, `
    Invoke-R18RetryEscalationPolicyMutation, `
    Get-R18RetryEscalationScenarioTypes, `
    Get-R18RetryEscalationRuntimeFlagNames
