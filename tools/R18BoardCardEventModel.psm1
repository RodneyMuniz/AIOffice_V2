Set-StrictMode -Version Latest

$script:R18BoardCardSourceTask = "R18-020"
$script:R18BoardCardSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18BoardCardRepository = "RodneyMuniz/AIOffice_V2"
$script:R18BoardCardBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18BoardCardVerdict = "generated_r18_020_board_card_event_model_foundation_only"
$script:R18BoardCardBoundary = "R18 active through R18-020 only; R18-021 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18BoardCardRuntimeFlagFields = @(
    "board_card_runtime_implemented",
    "live_board_runtime_executed",
    "board_runtime_mutation_performed",
    "live_card_state_transition_performed",
    "live_kanban_ui_implemented",
    "work_order_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "tool_call_execution_performed",
    "api_invocation_performed",
    "codex_api_invoked",
    "openai_api_invoked",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_execution_performed",
    "continuation_packet_executed",
    "prompt_packet_executed",
    "automatic_new_thread_creation_performed",
    "stage_commit_push_gate_runtime_implemented",
    "stage_performed_by_gate",
    "commit_performed_by_gate",
    "push_performed_by_gate",
    "release_gate_executed",
    "audit_acceptance_claimed",
    "external_audit_acceptance_claimed",
    "milestone_closeout_claimed",
    "main_merge_claimed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_021_completed"
)

$script:R18BoardCardRequiredCardFields = @(
    "artifact_type",
    "contract_version",
    "card_id",
    "card_name",
    "card_type",
    "source_task",
    "source_milestone",
    "card_status",
    "current_state",
    "previous_state",
    "assigned_role",
    "allowed_next_states",
    "blocked_reasons",
    "linked_work_order_refs",
    "linked_intake_refs",
    "linked_handoff_refs",
    "linked_validation_refs",
    "linked_evidence_refs",
    "linked_operator_decision_refs",
    "linked_release_gate_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18BoardCardRequiredEventFields = @(
    "artifact_type",
    "contract_version",
    "event_id",
    "event_type",
    "event_name",
    "source_task",
    "source_milestone",
    "event_status",
    "card_id",
    "work_order_ref",
    "actor_role",
    "previous_state",
    "next_state",
    "event_payload",
    "linked_refs",
    "validation_refs",
    "evidence_refs",
    "authority_refs",
    "status_boundary",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18BoardCardRegistryFields = @(
    "artifact_type",
    "contract_version",
    "registry_id",
    "source_task",
    "source_milestone",
    "repository",
    "branch",
    "card_count",
    "event_count",
    "required_seed_card_refs",
    "required_seed_event_refs",
    "event_log_ref",
    "status_boundary",
    "runtime_flags",
    "non_claims",
    "rejected_claims",
    "evidence_refs",
    "authority_refs"
)

$script:R18BoardCardStatuses = @(
    "seed_card_created",
    "seed_card_ready_for_future_runtime",
    "seed_card_blocked",
    "seed_card_waiting_for_operator_decision",
    "seed_card_validation_recorded",
    "seed_card_evidence_linked",
    "seed_card_release_gate_assessed"
)

$script:R18BoardCardEventTypes = @(
    "card_created",
    "card_status_transitioned",
    "handoff_linked",
    "validation_recorded",
    "evidence_linked",
    "operator_decision_required",
    "release_gate_assessed",
    "card_blocked",
    "failure_recorded"
)

$script:R18BoardCardActorRoles = @(
    "Orchestrator",
    "Project Manager",
    "Solution Architect",
    "Developer/Codex",
    "QA/Test",
    "Evidence Auditor",
    "Release Manager",
    "System/Validator",
    "Operator"
)

$script:R18BoardCardSeedCards = @(
    @{ id = "r18_020_recovery_runtime_card"; file = "r18_020_recovery_runtime_card.card.json"; name = "R18-020 Recovery Runtime Boundary Card"; type = "recovery_runtime_boundary"; status = "seed_card_blocked"; current = "blocked_pending_future_recovery_runtime"; previous = "seed_card_created"; role = "Orchestrator"; next = @("seed_card_waiting_for_operator_decision", "seed_card_ready_for_future_runtime") },
    @{ id = "r18_020_stage_gate_card"; file = "r18_020_stage_gate_card.card.json"; name = "R18-020 Stage Gate Boundary Card"; type = "stage_commit_push_gate_boundary"; status = "seed_card_release_gate_assessed"; current = "release_gate_policy_assessed"; previous = "seed_card_ready_for_future_runtime"; role = "Release Manager"; next = @("seed_card_blocked", "seed_card_waiting_for_operator_decision") },
    @{ id = "r18_020_evidence_package_card"; file = "r18_020_evidence_package_card.card.json"; name = "R18-020 Evidence Package Boundary Card"; type = "evidence_package_boundary"; status = "seed_card_evidence_linked"; current = "evidence_linked_policy_only"; previous = "seed_card_validation_recorded"; role = "Evidence Auditor"; next = @("seed_card_release_gate_assessed", "seed_card_blocked") }
)

$script:R18BoardCardSeedEventFiles = [ordered]@{
    card_created = "card_created.event.json"
    card_status_transitioned = "card_status_transitioned.event.json"
    handoff_linked = "handoff_linked.event.json"
    validation_recorded = "validation_recorded.event.json"
    evidence_linked = "evidence_linked.event.json"
    operator_decision_required = "operator_decision_required.event.json"
    release_gate_assessed = "release_gate_assessed.event.json"
    card_blocked = "card_blocked.event.json"
    failure_recorded = "failure_recorded.event.json"
}

function Get-R18BoardCardEventModelRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18BoardCardEventModelPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18BoardCardEventModelPaths {
    param([string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot))

    return [ordered]@{
        EventContract = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/board/r18_board_card_event.contract.json"
        ModelContract = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/board/r18_board_card_event_model.contract.json"
        Profile = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_model_profile.json"
        CardRoot = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_seed_cards"
        EventRoot = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_seed_events"
        EventLog = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_log.jsonl"
        Registry = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_registry.json"
        Results = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_model_results.json"
        CheckReport = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_model_check_report.json"
        Snapshot = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_board_card_event_model_snapshot.json"
        FixtureRoot = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_board_card_event_model"
        ProofRoot = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model"
        EvidenceIndex = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/evidence_index.json"
        ProofReview = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/proof_review.md"
        ValidationManifest = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/validation_manifest.md"
    }
}

function Get-R18BoardCardEventModelRuntimeFlagNames {
    return $script:R18BoardCardRuntimeFlagFields
}

function New-R18BoardCardEventModelRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18BoardCardRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18BoardCardEventModelPositiveClaims {
    return @(
        "r18_board_card_event_contract_created",
        "r18_board_card_event_model_contract_created",
        "r18_board_card_event_model_profile_created",
        "r18_board_card_seed_cards_created",
        "r18_board_card_seed_events_created",
        "r18_board_card_event_log_created",
        "r18_board_card_event_registry_created",
        "r18_board_card_event_model_results_created",
        "r18_board_card_event_model_validator_created",
        "r18_board_card_event_model_fixtures_created",
        "r18_board_card_event_model_proof_review_created"
    )
}

function Get-R18BoardCardEventModelRejectedClaims {
    return @(
        "live_board_card_runtime",
        "live_board_runtime",
        "board_card_runtime_mutation",
        "live_card_state_transition",
        "live_kanban_ui",
        "work_order_execution",
        "a2a_message_sent",
        "live_a2a_runtime",
        "live_agent_runtime",
        "live_skill_execution",
        "tool_call_execution",
        "api_invocation",
        "codex_api_invocation",
        "openai_api_invocation",
        "recovery_runtime",
        "recovery_action",
        "retry_execution",
        "continuation_packet_execution",
        "prompt_packet_execution",
        "automatic_new_thread_creation",
        "stage_commit_push_gate_runtime",
        "stage_performed_by_gate",
        "commit_performed_by_gate",
        "push_performed_by_gate",
        "release_gate_execution",
        "audit_acceptance",
        "external_audit_acceptance",
        "milestone_closeout",
        "main_merge",
        "ci_replay_performed",
        "github_actions_workflow_created",
        "github_actions_workflow_run_claimed",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_021_or_later_completion",
        "missing_event_id",
        "missing_card_id",
        "unknown_event_type",
        "unknown_actor_role",
        "unknown_card_status",
        "missing_authority_refs",
        "missing_evidence_refs",
        "missing_status_boundary"
    )
}

function Get-R18BoardCardEventModelNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-020 only.",
        "R18-021 through R18-028 remain planned only.",
        "R18-020 created board/card runtime event model foundation only.",
        "Board/card event model artifacts are deterministic seed/policy artifacts only.",
        "Live board/card runtime was not implemented.",
        "Board/card runtime mutation was not performed.",
        "Live card state transition was not performed.",
        "Live Kanban UI was not implemented.",
        "No work orders were executed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No R18 runtime tool-call execution was performed.",
        "Codex/OpenAI API invocation did not occur.",
        "Recovery runtime was not implemented.",
        "Recovery action was not performed.",
        "Retry execution was not performed.",
        "Continuation packets were not executed.",
        "Prompt packets were not executed.",
        "Automatic new-thread creation was not performed.",
        "Stage/commit/push gate runtime was not implemented by R18-020.",
        "No stage/commit/push was performed by the gate.",
        "Release gate was not executed.",
        "Audit acceptance was not claimed.",
        "External audit acceptance was not claimed.",
        "Milestone closeout was not claimed.",
        "Main was not merged.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved.",
        "R18-021 is not complete."
    )
}

function Get-R18BoardCardEventModelAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "contracts/governance/r18_evidence_package_wrapper.contract.json",
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "contracts/governance/r18_status_doc_gate_wrapper.contract.json",
        "state/governance/r18_status_doc_gate_wrapper_results.json",
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "state/runtime/r18_stage_commit_push_gate_assessments/",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_state_machine.json",
        "state/runtime/r18_work_order_seed_packets/",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_registry.json",
        "state/a2a/r18_handoff_packets/",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18BoardCardEventModelEvidenceRefs {
    return @(
        "contracts/board/r18_board_card_event.contract.json",
        "contracts/board/r18_board_card_event_model.contract.json",
        "state/board/r18_board_card_event_model_profile.json",
        "state/board/r18_board_card_seed_cards/",
        "state/board/r18_board_card_seed_events/",
        "state/board/r18_board_card_event_log.jsonl",
        "state/board/r18_board_card_event_registry.json",
        "state/board/r18_board_card_event_model_results.json",
        "state/board/r18_board_card_event_model_check_report.json",
        "state/ui/r18_operator_surface/r18_board_card_event_model_snapshot.json",
        "tools/R18BoardCardEventModel.psm1",
        "tools/new_r18_board_card_event_model.ps1",
        "tools/validate_r18_board_card_event_model.ps1",
        "tests/test_r18_board_card_event_model.ps1",
        "tests/fixtures/r18_board_card_event_model/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/"
    )
}

function Get-R18BoardCardEventModelValidationRefs {
    return @(
        "tools/new_r18_board_card_event_model.ps1",
        "tools/validate_r18_board_card_event_model.ps1",
        "tests/test_r18_board_card_event_model.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18BoardCardEventModelValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_board_card_event_model.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_board_card_event_model.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_board_card_event_model.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18BoardCardEventModelStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_020_only"
        planned_from = "R18-021"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18BoardCardBoundary
    }
}

function Write-R18BoardCardEventModelJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 100
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($json.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Write-R18BoardCardEventModelText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $text = if ($Value -is [array]) { [string]::Join([Environment]::NewLine, @($Value)) } else { [string]$Value }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($text.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Read-R18BoardCardEventModelJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot)
    )

    $resolvedPath = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required artifact missing: $Path"
    }

    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Copy-R18BoardCardEventModelObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function New-R18BoardCardEventContract {
    return [ordered]@{
        artifact_type = "r18_board_card_event_contract"
        contract_version = "v1"
        contract_id = "r18_020_board_card_event_contract_v1"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        scope = "deterministic_board_card_event_contract_only_not_live_runtime"
        purpose = "Define deterministic board/card event contracts for future runtime representation without implementing live board/card runtime, mutation, UI, work-order execution, A2A dispatch, agent invocation, skill execution, tool execution, API invocation, recovery action, release-gate execution, or audit acceptance."
        required_card_fields = $script:R18BoardCardRequiredCardFields
        required_event_fields = $script:R18BoardCardRequiredEventFields
        allowed_card_statuses = $script:R18BoardCardStatuses
        allowed_event_types = $script:R18BoardCardEventTypes
        allowed_actor_roles = $script:R18BoardCardActorRoles
        required_runtime_false_flags = $script:R18BoardCardRuntimeFlagFields
        card_policy = [ordered]@{
            seed_cards_only = $true
            live_card_creation_allowed = $false
            card_statuses_must_be_known = $true
            linked_authority_and_evidence_refs_required = $true
            historical_board_rewrite_allowed = $false
        }
        event_policy = [ordered]@{
            seed_events_only = $true
            event_status_required = "seed_event_only_not_runtime_mutation"
            allowed_event_types = $script:R18BoardCardEventTypes
            append_only_shape_defined = $true
            live_event_dispatch_allowed = $false
        }
        state_transition_policy = [ordered]@{
            previous_state_required = $true
            next_state_required = $true
            runtime_transition_execution_allowed = $false
            transition_representation_only = $true
        }
        handoff_policy = [ordered]@{
            r18_a2a_handoff_packet_refs_required = $true
            a2a_message_send_allowed = $false
            live_a2a_runtime_allowed = $false
        }
        validation_policy = [ordered]@{
            validation_refs_required = $true
            validator_artifact_refs_required = $true
            validation_as_runtime_action_allowed = $false
            missing_validation_refs_fail_closed = $true
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            proof_review_refs_required = $true
            audit_acceptance_allowed = $false
            missing_evidence_refs_fail_closed = $true
        }
        operator_decision_policy = [ordered]@{
            r18_016_operator_approval_model_ref_required = $true
            approval_inference_allowed = $false
            approval_execution_allowed = $false
        }
        release_gate_policy = [ordered]@{
            r18_017_r18_018_r18_019_refs_required = $true
            release_gate_execution_allowed = $false
            stage_commit_push_by_gate_allowed = $false
        }
        boundary_policy = [ordered]@{
            expected_status_boundary = $script:R18BoardCardBoundary
            r18_021_or_later_completion_claims_fail_closed = $true
            milestone_closeout_allowed = $false
            main_merge_allowed = $false
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            missing_authority_refs_fail_closed = $true
            source_authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        }
        execution_policy = [ordered]@{
            board_card_runtime_allowed = $false
            board_mutation_allowed = $false
            work_order_execution_allowed = $false
            live_agent_invocation_allowed = $false
            live_skill_execution_allowed = $false
            tool_call_execution_allowed = $false
            api_invocation_allowed = $false
            recovery_action_allowed = $false
            release_gate_execution_allowed = $false
        }
        refusal_policy = [ordered]@{
            fail_closed_on_missing_required_field = $true
            fail_closed_on_unknown_event_type = $true
            fail_closed_on_unknown_actor_role = $true
            fail_closed_on_unknown_card_status = $true
            fail_closed_on_runtime_or_completion_overclaim = $true
        }
        allowed_positive_claims = Get-R18BoardCardEventModelPositiveClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        non_claims = Get-R18BoardCardEventModelNonClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
    }
}

function New-R18BoardCardEventModelContract {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_contract"
        contract_version = "v1"
        contract_id = "r18_020_board_card_event_model_contract_v1"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        scope = "deterministic_board_card_event_model_artifacts_only_not_runtime"
        purpose = "Define the seed card, seed event, event log, registry, result, check-report, snapshot, fixture, and proof-review model for future board/card runtime representation without implementing or executing live board/card runtime."
        required_seed_cards = @($script:R18BoardCardSeedCards | ForEach-Object { "state/board/r18_board_card_seed_cards/$($_.file)" })
        required_seed_events = @($script:R18BoardCardEventTypes | ForEach-Object { "state/board/r18_board_card_seed_events/$($script:R18BoardCardSeedEventFiles[$_])" })
        required_event_log_fields = $script:R18BoardCardRequiredEventFields
        required_registry_fields = $script:R18BoardCardRegistryFields
        required_runtime_false_flags = $script:R18BoardCardRuntimeFlagFields
        model_policy = [ordered]@{
            deterministic_seed_artifacts_only = $true
            live_runtime_implementation_allowed = $false
            live_board_mutation_allowed = $false
            future_runtime_must_revalidate_before_use = $true
        }
        event_log_policy = [ordered]@{
            jsonl_required = $true
            one_entry_per_required_seed_event = $true
            log_entries_are_seed_samples_not_runtime_history = $true
            event_log_must_not_claim_runtime_mutation = $true
        }
        status_boundary_policy = [ordered]@{
            expected_boundary = $script:R18BoardCardBoundary
            r18_active_through = "R18-020"
            planned_from = "R18-021"
            planned_through = "R18-028"
            future_completion_claims_fail_closed = $true
        }
        evidence_policy = [ordered]@{
            seed_events_require_evidence_refs = $true
            evidence_package_refs_required = $true
            audit_acceptance_allowed = $false
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            required_authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        }
        execution_policy = [ordered]@{
            live_board_card_runtime_allowed = $false
            board_runtime_mutation_allowed = $false
            work_order_execution_allowed = $false
            a2a_message_allowed = $false
            live_agent_or_skill_execution_allowed = $false
            tool_call_execution_allowed = $false
            api_invocation_allowed = $false
            release_gate_execution_allowed = $false
            recovery_action_allowed = $false
        }
        allowed_positive_claims = Get-R18BoardCardEventModelPositiveClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        non_claims = Get-R18BoardCardEventModelNonClaims
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
    }
}

function New-R18BoardCardModelProfile {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_profile"
        contract_version = "v1"
        profile_id = "r18_020_board_card_event_model_profile"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        profile_status = "profile_created_seed_policy_only_not_runtime"
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        required_seed_cards = @($script:R18BoardCardSeedCards | ForEach-Object { "state/board/r18_board_card_seed_cards/$($_.file)" })
        required_seed_events = @($script:R18BoardCardEventTypes | ForEach-Object { "state/board/r18_board_card_seed_events/$($script:R18BoardCardSeedEventFiles[$_])" })
        required_event_types = $script:R18BoardCardEventTypes
        allowed_card_statuses = $script:R18BoardCardStatuses
        allowed_actor_roles = $script:R18BoardCardActorRoles
        validation_commands = Get-R18BoardCardEventModelValidationCommands
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        positive_claims = @("r18_board_card_event_model_profile_created")
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
    }
}

function New-R18BoardCardSeedCard {
    param([Parameter(Mandatory = $true)][hashtable]$Definition)

    $blockedReasons = if ($Definition.status -eq "seed_card_blocked") {
        @("future live recovery runtime is not implemented", "event model cannot perform recovery action")
    }
    else {
        @()
    }

    return [ordered]@{
        artifact_type = "r18_board_card_seed_card"
        contract_version = "v1"
        card_id = $Definition.id
        card_name = $Definition.name
        card_type = $Definition.type
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        card_status = $Definition.status
        current_state = $Definition.current
        previous_state = $Definition.previous
        assigned_role = $Definition.role
        allowed_next_states = $Definition.next
        blocked_reasons = $blockedReasons
        linked_work_order_refs = @(
            "state/runtime/r18_work_order_seed_packets/r18_008_seed_created.work_order.json",
            "state/runtime/r18_work_order_seed_packets/r18_008_seed_ready_for_handoff.work_order.json"
        )
        linked_intake_refs = @("state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json")
        linked_handoff_refs = @(
            "state/a2a/r18_handoff_packets/orchestrator_to_project_manager_define_work_order.handoff.json",
            "state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json",
            "state/a2a/r18_handoff_packets/evidence_auditor_to_release_manager_generate_evidence_package.handoff.json"
        )
        linked_validation_refs = Get-R18BoardCardEventModelValidationRefs
        linked_evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        linked_operator_decision_refs = @(
            "contracts/governance/r18_operator_approval_gate.contract.json",
            "state/governance/r18_operator_approval_decisions/stage_commit_push_gate.refusal.json",
            "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json"
        )
        linked_release_gate_refs = @(
            "contracts/runtime/r18_stage_commit_push_gate.contract.json",
            "contracts/governance/r18_status_doc_gate_wrapper.contract.json",
            "contracts/governance/r18_evidence_package_wrapper.contract.json"
        )
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
    }
}

function New-R18BoardCardEventPayload {
    param([Parameter(Mandatory = $true)][string]$EventType)

    switch ($EventType) {
        "card_created" {
            return [ordered]@{
                creates_deterministic_seed_evidence = $true
                claims_live_board_mutation = $false
                live_card_creation_performed = $false
                note = "Seed card existence is represented as deterministic evidence only."
            }
        }
        "card_status_transitioned" {
            return [ordered]@{
                previous_and_next_state_referenced = $true
                runtime_transition_execution_claimed = $false
                live_card_state_transition_performed = $false
                note = "Transition is represented for future runtime semantics only."
            }
        }
        "handoff_linked" {
            return [ordered]@{
                handoff_packet_refs_required = $true
                a2a_message_sent = $false
                live_a2a_runtime_implemented = $false
                note = "Handoff refs point to R18 packet artifacts and do not send messages."
            }
        }
        "validation_recorded" {
            return [ordered]@{
                validation_refs_required = $true
                validation_executed_as_runtime_action = $false
                runtime_validator_execution_claimed = $false
                note = "Validation refs identify committed validators/tests, not runtime execution."
            }
        }
        "evidence_linked" {
            return [ordered]@{
                proof_review_refs_required = $true
                evidence_package_refs_required = $true
                audit_acceptance_claimed = $false
                external_audit_acceptance_claimed = $false
                note = "Evidence links are proof-review/package refs only."
            }
        }
        "operator_decision_required" {
            return [ordered]@{
                operator_approval_model_ref_required = $true
                approval_inferred_from_narration = $false
                approval_executed = $false
                operator_decision_required = $true
                note = "Decision requirement references R18-016 and does not approve action."
            }
        }
        "release_gate_assessed" {
            return [ordered]@{
                stage_gate_ref_required = $true
                status_doc_gate_wrapper_ref_required = $true
                evidence_package_wrapper_ref_required = $true
                release_gate_executed = $false
                stage_commit_push_performed_by_gate = $false
                note = "Assessment references R18-017/R18-018/R18-019 wrapper artifacts only."
            }
        }
        "card_blocked" {
            return [ordered]@{
                blocked_reasons = @("future runtime unavailable", "operator decision or future implementation required")
                next_safe_step = "Keep card blocked until a future approved runtime task revalidates this seed event model."
                recovery_action_performed = $false
                note = "Blocked state does not perform recovery."
            }
        }
        "failure_recorded" {
            return [ordered]@{
                failure_event_refs_required = $true
                recovery_completed_claimed = $false
                recovery_action_performed = $false
                note = "Failure refs point to R18-010 seed failure artifacts only."
            }
        }
        default {
            throw "Unknown event type '$EventType'."
        }
    }
}

function New-R18BoardCardLinkedRefs {
    param([Parameter(Mandatory = $true)][string]$EventType)

    $base = [ordered]@{
        work_order_refs = @("state/runtime/r18_work_order_seed_packets/r18_008_seed_ready_for_handoff.work_order.json")
        intake_refs = @("state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json")
        handoff_packet_refs = @()
        operator_decision_refs = @()
        release_gate_refs = @()
        failure_event_refs = @()
    }

    if ($EventType -eq "handoff_linked") {
        $base.handoff_packet_refs = @(
            "state/a2a/r18_handoff_packets/orchestrator_to_project_manager_define_work_order.handoff.json",
            "state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json"
        )
    }
    if ($EventType -eq "operator_decision_required") {
        $base.operator_decision_refs = @(
            "contracts/governance/r18_operator_approval_gate.contract.json",
            "state/governance/r18_operator_approval_decisions/stage_commit_push_gate.refusal.json"
        )
    }
    if ($EventType -eq "release_gate_assessed") {
        $base.release_gate_refs = @(
            "contracts/runtime/r18_stage_commit_push_gate.contract.json",
            "contracts/governance/r18_status_doc_gate_wrapper.contract.json",
            "contracts/governance/r18_evidence_package_wrapper.contract.json",
            "state/runtime/r18_stage_commit_push_gate_assessments/safe_release_candidate.assessment.json"
        )
    }
    if ($EventType -eq "failure_recorded") {
        $base.failure_event_refs = @(
            "contracts/runtime/r18_failure_event.contract.json",
            "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        )
    }

    return $base
}

function New-R18BoardCardSeedEvent {
    param(
        [Parameter(Mandatory = $true)][string]$EventType,
        [Parameter(Mandatory = $true)][int]$Index
    )

    $cardByType = @{
        card_created = "r18_020_recovery_runtime_card"
        card_status_transitioned = "r18_020_recovery_runtime_card"
        handoff_linked = "r18_020_recovery_runtime_card"
        validation_recorded = "r18_020_evidence_package_card"
        evidence_linked = "r18_020_evidence_package_card"
        operator_decision_required = "r18_020_stage_gate_card"
        release_gate_assessed = "r18_020_stage_gate_card"
        card_blocked = "r18_020_recovery_runtime_card"
        failure_recorded = "r18_020_recovery_runtime_card"
    }
    $roleByType = @{
        card_created = "Orchestrator"
        card_status_transitioned = "Project Manager"
        handoff_linked = "Solution Architect"
        validation_recorded = "System/Validator"
        evidence_linked = "Evidence Auditor"
        operator_decision_required = "Operator"
        release_gate_assessed = "Release Manager"
        card_blocked = "Orchestrator"
        failure_recorded = "QA/Test"
    }
    $previousByType = @{
        card_created = "not_present_before_seed"
        card_status_transitioned = "seed_card_created"
        handoff_linked = "seed_card_ready_for_future_runtime"
        validation_recorded = "seed_card_ready_for_future_runtime"
        evidence_linked = "seed_card_validation_recorded"
        operator_decision_required = "seed_card_ready_for_future_runtime"
        release_gate_assessed = "seed_card_evidence_linked"
        card_blocked = "seed_card_waiting_for_operator_decision"
        failure_recorded = "seed_card_blocked"
    }
    $nextByType = @{
        card_created = "seed_card_created"
        card_status_transitioned = "seed_card_ready_for_future_runtime"
        handoff_linked = "seed_card_ready_for_future_runtime"
        validation_recorded = "seed_card_validation_recorded"
        evidence_linked = "seed_card_evidence_linked"
        operator_decision_required = "seed_card_waiting_for_operator_decision"
        release_gate_assessed = "seed_card_release_gate_assessed"
        card_blocked = "seed_card_blocked"
        failure_recorded = "seed_card_blocked"
    }

    $validationRefs = if ($EventType -eq "validation_recorded") {
        Get-R18BoardCardEventModelValidationRefs
    }
    else {
        @("tools/validate_r18_board_card_event_model.ps1", "tests/test_r18_board_card_event_model.ps1")
    }

    $evidenceRefs = Get-R18BoardCardEventModelEvidenceRefs
    if ($EventType -eq "evidence_linked") {
        $evidenceRefs += @(
            "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/evidence_index.json",
            "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json"
        )
    }

    return [ordered]@{
        artifact_type = "r18_board_card_seed_event"
        contract_version = "v1"
        event_id = ("r18_020_event_{0}_{1}" -f $Index.ToString("000"), $EventType)
        event_type = $EventType
        event_name = ("R18-020 {0}" -f (($EventType -replace "_", " ").Trim()))
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        event_status = "seed_event_only_not_runtime_mutation"
        card_id = $cardByType[$EventType]
        work_order_ref = "state/runtime/r18_work_order_seed_packets/r18_008_seed_ready_for_handoff.work_order.json"
        actor_role = $roleByType[$EventType]
        previous_state = $previousByType[$EventType]
        next_state = $nextByType[$EventType]
        event_payload = New-R18BoardCardEventPayload -EventType $EventType
        linked_refs = New-R18BoardCardLinkedRefs -EventType $EventType
        validation_refs = $validationRefs
        evidence_refs = $evidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
    }
}

function New-R18BoardCardAllEvents {
    $events = @()
    $index = 1
    foreach ($eventType in $script:R18BoardCardEventTypes) {
        $events += New-R18BoardCardSeedEvent -EventType $eventType -Index $index
        $index += 1
    }
    return $events
}

function New-R18BoardCardEventRegistry {
    return [ordered]@{
        artifact_type = "r18_board_card_event_registry"
        contract_version = "v1"
        registry_id = "r18_020_board_card_event_registry"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        card_count = @($script:R18BoardCardSeedCards).Count
        event_count = @($script:R18BoardCardEventTypes).Count
        required_seed_card_refs = @($script:R18BoardCardSeedCards | ForEach-Object { "state/board/r18_board_card_seed_cards/$($_.file)" })
        required_seed_event_refs = @($script:R18BoardCardEventTypes | ForEach-Object { "state/board/r18_board_card_seed_events/$($script:R18BoardCardSeedEventFiles[$_])" })
        event_log_ref = "state/board/r18_board_card_event_log.jsonl"
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
    }
}

function New-R18BoardCardEventModelResults {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_results"
        contract_version = "v1"
        results_id = "r18_020_board_card_event_model_results"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        aggregate_verdict = $script:R18BoardCardVerdict
        card_count = @($script:R18BoardCardSeedCards).Count
        event_count = @($script:R18BoardCardEventTypes).Count
        event_log_entry_count = @($script:R18BoardCardEventTypes).Count
        allowed_event_types = $script:R18BoardCardEventTypes
        allowed_card_statuses = $script:R18BoardCardStatuses
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        positive_claims = Get-R18BoardCardEventModelPositiveClaims
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
    }
}

function New-R18BoardCardEventModelCheckReport {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_check_report"
        contract_version = "v1"
        report_id = "r18_020_board_card_event_model_check_report"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        aggregate_verdict = $script:R18BoardCardVerdict
        checks = @(
            "required_contracts_present",
            "required_seed_cards_present",
            "required_seed_events_present",
            "event_log_jsonl_present",
            "registry_present",
            "required_card_fields_present",
            "required_event_fields_present",
            "known_event_types_only",
            "known_actor_roles_only",
            "known_card_statuses_only",
            "authority_refs_present",
            "evidence_refs_present",
            "status_boundary_present",
            "runtime_false_flags_preserved",
            "r18_status_active_through_r18_020_only"
        )
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        validation_commands = Get-R18BoardCardEventModelValidationCommands
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        positive_claims = Get-R18BoardCardEventModelPositiveClaims
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
    }
}

function New-R18BoardCardEventModelSnapshot {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_020_board_card_event_model_snapshot"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        repository = $script:R18BoardCardRepository
        branch = $script:R18BoardCardBranch
        snapshot_status = "read_only_operator_surface_snapshot_not_live_kanban_ui"
        r18_status = "active_through_r18_020_only"
        card_count = @($script:R18BoardCardSeedCards).Count
        event_count = @($script:R18BoardCardEventTypes).Count
        displayed_seed_cards = @($script:R18BoardCardSeedCards | ForEach-Object { $_.id })
        displayed_event_types = $script:R18BoardCardEventTypes
        status_boundary = New-R18BoardCardEventModelStatusBoundary
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
    }
}

function New-R18BoardCardEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_board_card_event_model_evidence_index"
        contract_version = "v1"
        evidence_index_id = "r18_020_board_card_event_model_evidence_index"
        source_task = $script:R18BoardCardSourceTask
        source_milestone = $script:R18BoardCardSourceMilestone
        evidence_refs = Get-R18BoardCardEventModelEvidenceRefs
        validation_refs = Get-R18BoardCardEventModelValidationRefs
        authority_refs = Get-R18BoardCardEventModelAuthorityRefs
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
    }
}

function New-R18BoardCardProofReviewText {
    return @"
# R18-020 Board/Card Event Model Proof Review

R18-020 created a deterministic board/card runtime event model foundation only. The package defines event contracts, a model contract, three seed cards, nine seed events, a JSONL event log sample, registry/results/check-report artifacts, an operator-surface snapshot, validator, fixtures, and this proof-review evidence.

The artifacts are seed and policy evidence only. They do not implement live board/card runtime, mutate board state, perform live card transitions, create a live Kanban UI, execute work orders, send A2A messages, invoke live agents or skills, execute tool calls, invoke Codex/OpenAI APIs, perform recovery, execute release gates, run CI replay, create or run GitHub Actions workflows, claim product runtime, claim no-manual-prompt-transfer success, or solve Codex compaction/reliability.

R18 status after this task is active through R18-020 only. R18-021 through R18-028 remain planned only.
"@
}

function New-R18BoardCardValidationManifestText {
    return @"
# R18-020 Validation Manifest

Required validation:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_board_card_event_model.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_board_card_event_model.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_board_card_event_model.ps1`
- Prior R18 validators and status-doc gate validators must continue to pass with R18 active through R18-020 only and R18-021 through R18-028 planned only.
- `git diff --check`

The validator fails closed on missing artifacts, missing card/event fields, unknown event types, unknown actor roles, unknown card statuses, missing card IDs, missing previous/next states where required, missing authority/evidence/status-boundary refs, R18-021+ completion claims, and runtime claims for live board runtime, mutation, work-order execution, A2A messages, live agent/skill/tool/API execution, recovery, retry, continuation/prompt execution, automatic thread creation, stage/commit/push by gate, release gate execution, audit acceptance, milestone closeout, main merge, CI replay, GitHub Actions workflow creation/run claims, product runtime, no-manual-prompt-transfer success, or solved Codex compaction/reliability.
"@
}

function New-R18BoardCardFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string[]]$ExpectedFailureFragments
    )

    $fixture = [ordered]@{
        artifact_type = "r18_board_card_event_model_invalid_fixture"
        contract_version = "v1"
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($File)
        source_task = $script:R18BoardCardSourceTask
        target = $Target
        operation = $Operation
        path = $Path
        expected_failure_fragments = $ExpectedFailureFragments
    }
    if ($Operation -eq "set") {
        $fixture["value"] = $Value
    }
    return [pscustomobject]@{ file = $File; fixture = $fixture }
}

function New-R18BoardCardFixtureDefinitions {
    return @(
        (New-R18BoardCardFixture -File "invalid_missing_event_id.json" -Target "event:card_created" -Operation "remove" -Path "event_id" -ExpectedFailureFragments @("missing required field 'event_id'")),
        (New-R18BoardCardFixture -File "invalid_missing_card_id.json" -Target "event:card_created" -Operation "remove" -Path "card_id" -ExpectedFailureFragments @("missing required field 'card_id'")),
        (New-R18BoardCardFixture -File "invalid_missing_event_type.json" -Target "event:card_created" -Operation "remove" -Path "event_type" -ExpectedFailureFragments @("missing required field 'event_type'")),
        (New-R18BoardCardFixture -File "invalid_unknown_event_type.json" -Target "event:card_created" -Operation "set" -Path "event_type" -Value "unknown_event_type" -ExpectedFailureFragments @("Unknown event type")),
        (New-R18BoardCardFixture -File "invalid_missing_source_task.json" -Target "event:card_created" -Operation "remove" -Path "source_task" -ExpectedFailureFragments @("missing required field 'source_task'")),
        (New-R18BoardCardFixture -File "invalid_missing_actor_role.json" -Target "event:card_created" -Operation "remove" -Path "actor_role" -ExpectedFailureFragments @("missing required field 'actor_role'")),
        (New-R18BoardCardFixture -File "invalid_missing_previous_state.json" -Target "event:card_status_transitioned" -Operation "remove" -Path "previous_state" -ExpectedFailureFragments @("missing required field 'previous_state'")),
        (New-R18BoardCardFixture -File "invalid_missing_next_state.json" -Target "event:card_status_transitioned" -Operation "remove" -Path "next_state" -ExpectedFailureFragments @("missing required field 'next_state'")),
        (New-R18BoardCardFixture -File "invalid_missing_authority_refs.json" -Target "event:card_created" -Operation "remove" -Path "authority_refs" -ExpectedFailureFragments @("missing required field 'authority_refs'")),
        (New-R18BoardCardFixture -File "invalid_missing_evidence_refs.json" -Target "event:card_created" -Operation "remove" -Path "evidence_refs" -ExpectedFailureFragments @("missing required field 'evidence_refs'")),
        (New-R18BoardCardFixture -File "invalid_missing_status_boundary.json" -Target "event:card_created" -Operation "remove" -Path "status_boundary" -ExpectedFailureFragments @("missing required field 'status_boundary'")),
        (New-R18BoardCardFixture -File "invalid_live_board_runtime_claim.json" -Target "event:card_created" -Operation "set" -Path "runtime_flags.live_board_runtime_executed" -Value $true -ExpectedFailureFragments @("runtime flag 'live_board_runtime_executed' must be false")),
        (New-R18BoardCardFixture -File "invalid_board_runtime_mutation_claim.json" -Target "event:card_created" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'board_runtime_mutation_performed' must be false")),
        (New-R18BoardCardFixture -File "invalid_work_order_execution_claim.json" -Target "event:card_created" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'work_order_execution_performed' must be false")),
        (New-R18BoardCardFixture -File "invalid_a2a_message_sent_claim.json" -Target "event:handoff_linked" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -ExpectedFailureFragments @("runtime flag 'a2a_message_sent' must be false")),
        (New-R18BoardCardFixture -File "invalid_live_agent_invocation_claim.json" -Target "event:handoff_linked" -Operation "set" -Path "runtime_flags.live_agent_runtime_invoked" -Value $true -ExpectedFailureFragments @("runtime flag 'live_agent_runtime_invoked' must be false")),
        (New-R18BoardCardFixture -File "invalid_live_skill_execution_claim.json" -Target "event:handoff_linked" -Operation "set" -Path "runtime_flags.live_skill_execution_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'live_skill_execution_performed' must be false")),
        (New-R18BoardCardFixture -File "invalid_api_invocation_claim.json" -Target "event:validation_recorded" -Operation "set" -Path "runtime_flags.api_invocation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'api_invocation_performed' must be false")),
        (New-R18BoardCardFixture -File "invalid_stage_commit_push_claim.json" -Target "event:release_gate_assessed" -Operation "set" -Path "runtime_flags.stage_performed_by_gate" -Value $true -ExpectedFailureFragments @("runtime flag 'stage_performed_by_gate' must be false")),
        (New-R18BoardCardFixture -File "invalid_recovery_action_claim.json" -Target "event:card_blocked" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'recovery_action_performed' must be false")),
        (New-R18BoardCardFixture -File "invalid_product_runtime_claim.json" -Target "event:evidence_linked" -Operation "set" -Path "runtime_flags.product_runtime_executed" -Value $true -ExpectedFailureFragments @("runtime flag 'product_runtime_executed' must be false")),
        (New-R18BoardCardFixture -File "invalid_r18_021_completion_claim.json" -Target "event:evidence_linked" -Operation "set" -Path "runtime_flags.r18_021_completed" -Value $true -ExpectedFailureFragments @("runtime flag 'r18_021_completed' must be false"))
    )
}

function New-R18BoardCardFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$Fixtures)

    return [ordered]@{
        artifact_type = "r18_board_card_event_model_fixture_manifest"
        contract_version = "v1"
        fixture_manifest_id = "r18_020_board_card_event_model_fixture_manifest"
        source_task = $script:R18BoardCardSourceTask
        invalid_fixture_files = @($Fixtures | ForEach-Object { $_.file })
        invalid_fixture_count = @($Fixtures).Count
        runtime_flags = New-R18BoardCardEventModelRuntimeFlags
        non_claims = Get-R18BoardCardEventModelNonClaims
        rejected_claims = Get-R18BoardCardEventModelRejectedClaims
    }
}

function New-R18BoardCardEventModelArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot))

    $paths = Get-R18BoardCardEventModelPaths -RepositoryRoot $RepositoryRoot

    $cards = @()
    foreach ($definition in $script:R18BoardCardSeedCards) {
        $cards += New-R18BoardCardSeedCard -Definition $definition
    }
    $events = New-R18BoardCardAllEvents

    Write-R18BoardCardEventModelJson -Path $paths.EventContract -Value (New-R18BoardCardEventContract)
    Write-R18BoardCardEventModelJson -Path $paths.ModelContract -Value (New-R18BoardCardEventModelContract)
    Write-R18BoardCardEventModelJson -Path $paths.Profile -Value (New-R18BoardCardModelProfile)

    foreach ($definition in $script:R18BoardCardSeedCards) {
        $card = @($cards | Where-Object { $_.card_id -eq $definition.id })[0]
        Write-R18BoardCardEventModelJson -Path (Join-Path $paths.CardRoot $definition.file) -Value $card
    }
    foreach ($event in $events) {
        Write-R18BoardCardEventModelJson -Path (Join-Path $paths.EventRoot $script:R18BoardCardSeedEventFiles[[string]$event.event_type]) -Value $event
    }

    $eventLogLines = @()
    foreach ($event in $events) {
        $eventLogLines += ($event | ConvertTo-Json -Depth 100 -Compress)
    }
    Write-R18BoardCardEventModelText -Path $paths.EventLog -Value $eventLogLines

    Write-R18BoardCardEventModelJson -Path $paths.Registry -Value (New-R18BoardCardEventRegistry)
    Write-R18BoardCardEventModelJson -Path $paths.Results -Value (New-R18BoardCardEventModelResults)
    Write-R18BoardCardEventModelJson -Path $paths.CheckReport -Value (New-R18BoardCardEventModelCheckReport)
    Write-R18BoardCardEventModelJson -Path $paths.Snapshot -Value (New-R18BoardCardEventModelSnapshot)
    Write-R18BoardCardEventModelJson -Path $paths.EvidenceIndex -Value (New-R18BoardCardEvidenceIndex)
    Write-R18BoardCardEventModelText -Path $paths.ProofReview -Value (New-R18BoardCardProofReviewText)
    Write-R18BoardCardEventModelText -Path $paths.ValidationManifest -Value (New-R18BoardCardValidationManifestText)

    $fixtures = New-R18BoardCardFixtureDefinitions
    foreach ($fixture in $fixtures) {
        Write-R18BoardCardEventModelJson -Path (Join-Path $paths.FixtureRoot $fixture.file) -Value $fixture.fixture
    }
    Write-R18BoardCardEventModelJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18BoardCardFixtureManifest -Fixtures $fixtures)

    return [pscustomobject]@{
        AggregateVerdict = $script:R18BoardCardVerdict
        CardCount = @($cards).Count
        EventCount = @($events).Count
        EventLogEntryCount = @($eventLogLines).Count
        FixtureCount = @($fixtures).Count
    }
}

function Assert-R18BoardCardCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18BoardCardFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R18BoardCardRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18BoardCardRuntimeFlagFields) {
        if ($null -eq $RuntimeFlags.PSObject.Properties[$field]) {
            throw "$Context missing runtime flag '$field'."
        }
        if ([bool]$RuntimeFlags.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context runtime flag '$field' must be false."
        }
    }
}

function Assert-R18BoardCardCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18BoardCardCondition -Condition ($Artifact.source_task -eq $script:R18BoardCardSourceTask) -Message "$Context source_task must be R18-020."
    Assert-R18BoardCardCondition -Condition ($Artifact.source_milestone -eq $script:R18BoardCardSourceMilestone) -Message "$Context source_milestone is invalid."
    Assert-R18BoardCardRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
}

function Assert-R18BoardCardRefs {
    param(
        [AllowNull()][object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Assert-R18BoardCardCondition -Condition ($null -ne $Refs -and @($Refs).Count -gt 0) -Message "$Context $Label must not be empty."
    foreach ($ref in @($Refs)) {
        Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$ref)) -Message "$Context $Label contains an empty ref."
    }
}

function Assert-R18BoardCardEventContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $fields = @(
        "artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_card_fields", "required_event_fields", "allowed_card_statuses", "allowed_event_types", "allowed_actor_roles", "required_runtime_false_flags", "card_policy", "event_policy", "state_transition_policy", "handoff_policy", "validation_policy", "evidence_policy", "operator_decision_policy", "release_gate_policy", "boundary_policy", "authority_policy", "execution_policy", "refusal_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs"
    )
    Assert-R18BoardCardFields -Object $Contract -Fields $fields -Context "event contract"
    Assert-R18BoardCardCommonArtifact -Artifact $Contract -Context "event contract"
    Assert-R18BoardCardCondition -Condition ($Contract.artifact_type -eq "r18_board_card_event_contract") -Message "Event contract artifact_type is invalid."
    foreach ($field in $script:R18BoardCardRequiredCardFields) {
        Assert-R18BoardCardCondition -Condition (@($Contract.required_card_fields) -contains $field) -Message "Event contract required_card_fields missing '$field'."
    }
    foreach ($field in $script:R18BoardCardRequiredEventFields) {
        Assert-R18BoardCardCondition -Condition (@($Contract.required_event_fields) -contains $field) -Message "Event contract required_event_fields missing '$field'."
    }
    foreach ($flag in $script:R18BoardCardRuntimeFlagFields) {
        Assert-R18BoardCardCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "Event contract required_runtime_false_flags missing '$flag'."
    }
}

function Assert-R18BoardCardEventModelContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $fields = @(
        "artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_seed_cards", "required_seed_events", "required_event_log_fields", "required_registry_fields", "required_runtime_false_flags", "model_policy", "event_log_policy", "status_boundary_policy", "evidence_policy", "authority_policy", "execution_policy", "allowed_positive_claims", "rejected_claims", "non_claims"
    )
    Assert-R18BoardCardFields -Object $Contract -Fields $fields -Context "event model contract"
    Assert-R18BoardCardCommonArtifact -Artifact $Contract -Context "event model contract"
    Assert-R18BoardCardCondition -Condition ($Contract.artifact_type -eq "r18_board_card_event_model_contract") -Message "Event model contract artifact_type is invalid."
    Assert-R18BoardCardCondition -Condition (@($Contract.required_seed_cards).Count -eq 3) -Message "Event model contract must require three seed cards."
    Assert-R18BoardCardCondition -Condition (@($Contract.required_seed_events).Count -eq 9) -Message "Event model contract must require nine seed events."
}

function Assert-R18BoardCardSeedCard {
    param([Parameter(Mandatory = $true)][object]$Card)

    Assert-R18BoardCardFields -Object $Card -Fields $script:R18BoardCardRequiredCardFields -Context "seed card '$($Card.card_id)'"
    Assert-R18BoardCardCommonArtifact -Artifact $Card -Context "seed card '$($Card.card_id)'"
    Assert-R18BoardCardCondition -Condition ($Card.artifact_type -eq "r18_board_card_seed_card") -Message "Seed card '$($Card.card_id)' artifact_type is invalid."
    Assert-R18BoardCardCondition -Condition ($script:R18BoardCardStatuses -contains [string]$Card.card_status) -Message "Unknown card status '$($Card.card_status)'."
    Assert-R18BoardCardCondition -Condition ($script:R18BoardCardActorRoles -contains [string]$Card.assigned_role) -Message "Unknown assigned role '$($Card.assigned_role)'."
    Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Card.card_id)) -Message "Seed card card_id must not be empty."
    Assert-R18BoardCardRefs -Refs $Card.allowed_next_states -Context "seed card '$($Card.card_id)'" -Label "allowed_next_states"
    Assert-R18BoardCardRefs -Refs $Card.linked_evidence_refs -Context "seed card '$($Card.card_id)'" -Label "linked_evidence_refs"
    Assert-R18BoardCardRefs -Refs $Card.authority_refs -Context "seed card '$($Card.card_id)'" -Label "authority_refs"
}

function Assert-R18BoardCardEventRule {
    param([Parameter(Mandatory = $true)][object]$Event)

    switch ([string]$Event.event_type) {
        "card_created" {
            Assert-R18BoardCardCondition -Condition ([bool]$Event.event_payload.creates_deterministic_seed_evidence) -Message "card_created must create only deterministic seed evidence."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.claims_live_board_mutation) -Message "card_created must not claim live board mutation."
        }
        "card_status_transitioned" {
            Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.previous_state) -and -not [string]::IsNullOrWhiteSpace([string]$Event.next_state)) -Message "card_status_transitioned must reference previous and next state."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.runtime_transition_execution_claimed) -Message "card_status_transitioned must not claim runtime transition execution."
        }
        "handoff_linked" {
            Assert-R18BoardCardRefs -Refs $Event.linked_refs.handoff_packet_refs -Context "handoff_linked" -Label "handoff_packet_refs"
            Assert-R18BoardCardCondition -Condition ((@($Event.linked_refs.handoff_packet_refs) -join " ") -like "*state/a2a/r18_handoff_packets*") -Message "handoff_linked must reference R18 A2A handoff packets."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.a2a_message_sent) -Message "handoff_linked must not send A2A messages."
        }
        "validation_recorded" {
            Assert-R18BoardCardRefs -Refs $Event.validation_refs -Context "validation_recorded" -Label "validation_refs"
            Assert-R18BoardCardCondition -Condition ((@($Event.validation_refs) -join " ") -like "*validate_r18_board_card_event_model*") -Message "validation_recorded must reference validator artifacts."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.validation_executed_as_runtime_action) -Message "validation_recorded must not execute validations as runtime action."
        }
        "evidence_linked" {
            Assert-R18BoardCardRefs -Refs $Event.evidence_refs -Context "evidence_linked" -Label "evidence_refs"
            Assert-R18BoardCardCondition -Condition ((@($Event.evidence_refs) -join " ") -like "*state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration*") -Message "evidence_linked must reference proof-review/evidence artifacts."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.audit_acceptance_claimed) -Message "evidence_linked must not claim audit acceptance."
        }
        "operator_decision_required" {
            Assert-R18BoardCardCondition -Condition ((@($Event.linked_refs.operator_decision_refs) -join " ") -like "*r18_operator_approval_gate*") -Message "operator_decision_required must reference R18-016 operator approval model."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.approval_executed -and -not [bool]$Event.event_payload.approval_inferred_from_narration) -Message "operator_decision_required must not infer or execute approval."
        }
        "release_gate_assessed" {
            $joined = @($Event.linked_refs.release_gate_refs) -join " "
            Assert-R18BoardCardCondition -Condition ($joined -like "*r18_stage_commit_push_gate*" -and $joined -like "*r18_status_doc_gate_wrapper*" -and $joined -like "*r18_evidence_package_wrapper*") -Message "release_gate_assessed must reference R18-017/R18-018/R18-019 gate/evidence wrappers."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.release_gate_executed) -Message "release_gate_assessed must not execute release gate."
        }
        "card_blocked" {
            Assert-R18BoardCardRefs -Refs $Event.event_payload.blocked_reasons -Context "card_blocked" -Label "blocked_reasons"
            Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.event_payload.next_safe_step)) -Message "card_blocked must include next safe step."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.recovery_action_performed) -Message "card_blocked must not perform recovery."
        }
        "failure_recorded" {
            Assert-R18BoardCardRefs -Refs $Event.linked_refs.failure_event_refs -Context "failure_recorded" -Label "failure_event_refs"
            Assert-R18BoardCardCondition -Condition ((@($Event.linked_refs.failure_event_refs) -join " ") -like "*r18_detected_failure_events*") -Message "failure_recorded must reference R18-010 failure events."
            Assert-R18BoardCardCondition -Condition (-not [bool]$Event.event_payload.recovery_completed_claimed) -Message "failure_recorded must not claim recovery completed."
        }
    }
}

function Assert-R18BoardCardSeedEvent {
    param([Parameter(Mandatory = $true)][object]$Event)

    $eventLabel = if ($null -eq $Event.PSObject.Properties["event_id"]) { "<missing event_id>" } else { [string]$Event.event_id }
    Assert-R18BoardCardFields -Object $Event -Fields $script:R18BoardCardRequiredEventFields -Context "event '$eventLabel'"
    Assert-R18BoardCardCommonArtifact -Artifact $Event -Context "event '$eventLabel'"
    Assert-R18BoardCardCondition -Condition ($Event.artifact_type -eq "r18_board_card_seed_event") -Message "Event '$eventLabel' artifact_type is invalid."
    Assert-R18BoardCardCondition -Condition ($Event.event_status -eq "seed_event_only_not_runtime_mutation") -Message "Event '$eventLabel' status must be seed_event_only_not_runtime_mutation."
    Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.event_id)) -Message "Event event_id must not be empty."
    Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.card_id)) -Message "Event '$eventLabel' card_id must not be empty."
    Assert-R18BoardCardCondition -Condition ($script:R18BoardCardEventTypes -contains [string]$Event.event_type) -Message "Unknown event type '$($Event.event_type)'."
    Assert-R18BoardCardCondition -Condition ($script:R18BoardCardActorRoles -contains [string]$Event.actor_role) -Message "Unknown actor role '$($Event.actor_role)'."
    Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.previous_state)) -Message "Event '$eventLabel' previous_state must not be empty."
    Assert-R18BoardCardCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Event.next_state)) -Message "Event '$eventLabel' next_state must not be empty."
    Assert-R18BoardCardRefs -Refs $Event.authority_refs -Context "event '$eventLabel'" -Label "authority_refs"
    Assert-R18BoardCardRefs -Refs $Event.evidence_refs -Context "event '$eventLabel'" -Label "evidence_refs"
    Assert-R18BoardCardCondition -Condition ($null -ne $Event.status_boundary -and -not [string]::IsNullOrWhiteSpace([string]$Event.status_boundary.summary)) -Message "Event '$eventLabel' status boundary must not be empty."
    Assert-R18BoardCardEventRule -Event $Event
}

function Assert-R18BoardCardRegistry {
    param([Parameter(Mandatory = $true)][object]$Registry)

    Assert-R18BoardCardFields -Object $Registry -Fields $script:R18BoardCardRegistryFields -Context "registry"
    Assert-R18BoardCardCommonArtifact -Artifact $Registry -Context "registry"
    Assert-R18BoardCardCondition -Condition ([int]$Registry.card_count -eq 3) -Message "Registry card_count must be 3."
    Assert-R18BoardCardCondition -Condition ([int]$Registry.event_count -eq 9) -Message "Registry event_count must be 9."
    Assert-R18BoardCardCondition -Condition (@($Registry.required_seed_card_refs).Count -eq 3) -Message "Registry must list three seed card refs."
    Assert-R18BoardCardCondition -Condition (@($Registry.required_seed_event_refs).Count -eq 9) -Message "Registry must list nine seed event refs."
}

function Get-R18BoardCardTaskStatusMap {
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

function Test-R18BoardCardEventModelStatusTruth {
    param([string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-021 only",
            "R18-022 through R18-028 planned only",
            "R18-020 created board/card runtime event model foundation only",
            "Board/card event model artifacts are deterministic seed/policy artifacts only",
            "Live board/card runtime was not implemented",
            "Board/card runtime mutation was not performed",
            "Live Kanban UI was not implemented",
            "R18-021 created agent invocation and tool-call evidence model foundation only",
            "Evidence model is not agent invocation by itself",
            "No work orders were executed",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "Recovery action was not performed",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved"
        )) {
        Assert-R18BoardCardCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-020 truth: $required"
    }

    $authorityStatuses = Get-R18BoardCardTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18BoardCardTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18BoardCardCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 21) {
            Assert-R18BoardCardCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-021."
        }
        else {
            Assert-R18BoardCardCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-021."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[2-8])') {
        throw "Status surface claims R18 beyond R18-021."
    }
    if ($combinedText -match '(?i)R18-(02[2-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-022 or later completion."
    }

    return [pscustomobject]@{
        R18DoneThrough = 21
        R18PlannedStart = 22
        R18PlannedThrough = 28
    }
}

function Test-R18BoardCardEventModelSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$EventContract,
        [Parameter(Mandatory = $true)][object]$ModelContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Cards,
        [Parameter(Mandatory = $true)][object[]]$Events,
        [Parameter(Mandatory = $true)][object[]]$EventLogEntries,
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [Parameter(Mandatory = $true)][object]$EvidenceIndex,
        [string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot)
    )

    Assert-R18BoardCardEventContract -Contract $EventContract
    Assert-R18BoardCardEventModelContract -Contract $ModelContract
    Assert-R18BoardCardCommonArtifact -Artifact $Profile -Context "profile"
    Assert-R18BoardCardRegistry -Registry $Registry
    Assert-R18BoardCardCommonArtifact -Artifact $Results -Context "results"
    Assert-R18BoardCardCommonArtifact -Artifact $Report -Context "check report"
    Assert-R18BoardCardCommonArtifact -Artifact $Snapshot -Context "snapshot"
    Assert-R18BoardCardCommonArtifact -Artifact $EvidenceIndex -Context "evidence index"

    Assert-R18BoardCardCondition -Condition (@($Cards).Count -eq 3) -Message "Expected three seed cards."
    Assert-R18BoardCardCondition -Condition (@($Events).Count -eq 9) -Message "Expected nine seed events."
    Assert-R18BoardCardCondition -Condition (@($EventLogEntries).Count -eq 9) -Message "Expected nine JSONL log entries."

    foreach ($card in @($Cards)) {
        Assert-R18BoardCardSeedCard -Card $card
    }
    foreach ($event in @($Events)) {
        Assert-R18BoardCardSeedEvent -Event $event
    }
    foreach ($entry in @($EventLogEntries)) {
        Assert-R18BoardCardSeedEvent -Event $entry
    }

    foreach ($eventType in $script:R18BoardCardEventTypes) {
        Assert-R18BoardCardCondition -Condition (@($Events | Where-Object { $_.event_type -eq $eventType }).Count -eq 1) -Message "Missing seed event type '$eventType'."
        Assert-R18BoardCardCondition -Condition (@($EventLogEntries | Where-Object { $_.event_type -eq $eventType }).Count -eq 1) -Message "Missing JSONL event type '$eventType'."
    }

    $eventIds = @($Events | ForEach-Object { $_.event_id } | Sort-Object)
    $logIds = @($EventLogEntries | ForEach-Object { $_.event_id } | Sort-Object)
    Assert-R18BoardCardCondition -Condition (@(Compare-Object -ReferenceObject $eventIds -DifferenceObject $logIds).Count -eq 0) -Message "JSONL event log entries must match seed event ids."
    Assert-R18BoardCardCondition -Condition ($Results.aggregate_verdict -eq $script:R18BoardCardVerdict) -Message "Results aggregate verdict is invalid."
    Assert-R18BoardCardCondition -Condition ($Report.aggregate_verdict -eq $script:R18BoardCardVerdict) -Message "Check report aggregate verdict is invalid."
    Assert-R18BoardCardCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_020_only") -Message "Snapshot must record active_through_r18_020_only."

    Test-R18BoardCardEventModelStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        CardCount = @($Cards).Count
        EventCount = @($Events).Count
        EventLogEntryCount = @($EventLogEntries).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18BoardCardEventModelSet {
    param([string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot))

    $cards = @()
    foreach ($definition in $script:R18BoardCardSeedCards) {
        $cards += Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_seed_cards/$($definition.file)"
    }
    $events = @()
    foreach ($eventType in $script:R18BoardCardEventTypes) {
        $events += Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_seed_events/$($script:R18BoardCardSeedEventFiles[$eventType])"
    }

    $eventLogPath = Resolve-R18BoardCardEventModelPath -RepositoryRoot $RepositoryRoot -PathValue "state/board/r18_board_card_event_log.jsonl"
    if (-not (Test-Path -LiteralPath $eventLogPath -PathType Leaf)) {
        throw "Required artifact missing: state/board/r18_board_card_event_log.jsonl"
    }
    $eventLogEntries = @()
    foreach ($line in @(Get-Content -LiteralPath $eventLogPath)) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $eventLogEntries += ($line | ConvertFrom-Json)
        }
    }

    return [pscustomobject]@{
        EventContract = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "contracts/board/r18_board_card_event.contract.json"
        ModelContract = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "contracts/board/r18_board_card_event_model.contract.json"
        Profile = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_event_model_profile.json"
        Cards = $cards
        Events = $events
        EventLogEntries = $eventLogEntries
        Registry = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_event_registry.json"
        Results = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_event_model_results.json"
        Report = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/board/r18_board_card_event_model_check_report.json"
        Snapshot = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_board_card_event_model_snapshot.json"
        EvidenceIndex = Read-R18BoardCardEventModelJson -RepositoryRoot $RepositoryRoot -Path "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/evidence_index.json"
        Paths = Get-R18BoardCardEventModelPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18BoardCardEventModel {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18BoardCardEventModelRepositoryRoot))

    $set = Get-R18BoardCardEventModelSet -RepositoryRoot $RepositoryRoot
    return Test-R18BoardCardEventModelSet `
        -EventContract $set.EventContract `
        -ModelContract $set.ModelContract `
        -Profile $set.Profile `
        -Cards $set.Cards `
        -Events $set.Events `
        -EventLogEntries $set.EventLogEntries `
        -Registry $set.Registry `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RepositoryRoot $RepositoryRoot
}

function Get-R18BoardCardEventModelMutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch -Wildcard ($Target) {
        "event:*" {
            $eventType = $Target.Substring("event:".Length)
            return @($Set.Events | Where-Object { $_.event_type -eq $eventType })[0]
        }
        "card:*" {
            $cardId = $Target.Substring("card:".Length)
            return @($Set.Cards | Where-Object { $_.card_id -eq $cardId })[0]
        }
        "event_contract" { return $Set.EventContract }
        "model_contract" { return $Set.ModelContract }
        "profile" { return $Set.Profile }
        "registry" { return $Set.Registry }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Set-R18BoardCardEventModelObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($null -eq $cursor.PSObject.Properties[$segment]) {
            $cursor | Add-Member -NotePropertyName $segment -NotePropertyValue ([pscustomobject]@{})
        }
        $cursor = $cursor.PSObject.Properties[$segment].Value
    }
    $leaf = $segments[-1]
    if ($null -eq $cursor.PSObject.Properties[$leaf]) {
        $cursor | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
    else {
        $cursor.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R18BoardCardEventModelObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($null -eq $cursor.PSObject.Properties[$segment]) {
            return
        }
        $cursor = $cursor.PSObject.Properties[$segment].Value
    }
    $leaf = $segments[-1]
    if ($null -ne $cursor.PSObject.Properties[$leaf]) {
        $cursor.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18BoardCardEventModelMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18BoardCardEventModelObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18BoardCardEventModelObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 board/card event model mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18BoardCardEventModelPaths, `
    Get-R18BoardCardEventModelRuntimeFlagNames, `
    New-R18BoardCardEventModelRuntimeFlags, `
    New-R18BoardCardEventModelArtifacts, `
    Test-R18BoardCardEventModel, `
    Test-R18BoardCardEventModelSet, `
    Test-R18BoardCardEventModelStatusTruth, `
    Get-R18BoardCardEventModelSet, `
    Get-R18BoardCardEventModelMutationTarget, `
    Copy-R18BoardCardEventModelObject, `
    Invoke-R18BoardCardEventModelMutation
