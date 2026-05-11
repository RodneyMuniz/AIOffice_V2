Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-008"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18Verdict = "generated_r18_work_order_state_machine_foundation_only"

$script:R18RequiredStates = @(
    "created",
    "intake_validated",
    "work_order_defined",
    "waiting_for_handoff_validation",
    "ready_for_handoff",
    "blocked_pending_future_execution_runtime",
    "validation_failed",
    "blocked_pending_operator_decision",
    "abandoned",
    "completed_foundation_only"
)

$script:R18StateSemantics = [ordered]@{
    created = "work order packet exists as a seed/foundation artifact only."
    intake_validated = "referenced intake packet has been shape-validated."
    work_order_defined = "scope, acceptance criteria, allowed paths, forbidden paths, and expected evidence are defined."
    waiting_for_handoff_validation = "role-to-role handoff evidence is required before future action."
    ready_for_handoff = "handoff shape is valid and future target role can inspect it."
    blocked_pending_future_execution_runtime = "execution is blocked because R18-009+ runtime/state store is not implemented."
    validation_failed = "state/transition validation failed."
    blocked_pending_operator_decision = "operator decision is required."
    abandoned = "work order is abandoned by explicit future operator decision only."
    completed_foundation_only = "foundation package completed, not work-order runtime completion."
}

$script:R18RequiredTransitionIds = @(
    "created_to_intake_validated",
    "intake_validated_to_work_order_defined",
    "work_order_defined_to_waiting_for_handoff_validation",
    "waiting_for_handoff_validation_to_ready_for_handoff",
    "ready_for_handoff_to_blocked_pending_future_execution_runtime",
    "any_state_to_validation_failed",
    "any_state_to_blocked_pending_operator_decision",
    "blocked_pending_operator_decision_to_abandoned",
    "foundation_package_to_completed_foundation_only"
)

$script:R18RequiredWorkOrderFields = @(
    "artifact_type",
    "contract_version",
    "work_order_id",
    "work_order_name",
    "source_task",
    "source_milestone",
    "work_order_status",
    "current_state",
    "previous_state",
    "next_allowed_states",
    "intake_packet_ref",
    "handoff_packet_refs",
    "target_role",
    "target_skill",
    "authority_refs",
    "permission_matrix_ref",
    "allowed_paths",
    "forbidden_paths",
    "acceptance_criteria",
    "validation_expectations",
    "evidence_obligations",
    "retry_failover_policy",
    "failure_routing",
    "operator_decision_policy",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredTransitionFields = @(
    "artifact_type",
    "contract_version",
    "transition_id",
    "transition_name",
    "source_task",
    "source_milestone",
    "transition_status",
    "from_state",
    "to_state",
    "work_order_ref",
    "transition_preconditions",
    "authority_check",
    "intake_check",
    "handoff_check",
    "permission_check",
    "validation_check",
    "evidence_check",
    "retry_check",
    "path_check",
    "execution_block_check",
    "next_allowed_actions",
    "refused_actions",
    "evidence_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RuntimeFlagFields = @(
    "work_order_execution_performed",
    "work_order_state_machine_runtime_executed",
    "runner_state_store_implemented",
    "resumable_execution_log_implemented",
    "local_runner_runtime_executed",
    "live_chat_ui_implemented",
    "orchestrator_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "live_recovery_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "stage_commit_push_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_009_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_work_order_state_machine_contract_created",
    "r18_work_order_state_machine_created",
    "r18_work_order_transition_catalog_created",
    "r18_seed_work_order_packets_created",
    "r18_transition_evaluation_artifacts_created",
    "r18_work_order_state_machine_validator_created",
    "r18_work_order_state_machine_fixtures_created",
    "r18_work_order_state_machine_proof_review_created"
)

$script:R18RejectedClaims = @(
    "work_order_execution",
    "runner_state_store_implementation",
    "resumable_execution_log_implementation",
    "live_runner_runtime",
    "live_chat_ui",
    "orchestrator_runtime",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "live_recovery_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "automatic_new_thread_creation",
    "stage_commit_push",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_009_or_later_completion",
    "main_merge",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "broad_repo_write",
    "unknown_state",
    "unknown_transition",
    "unbounded_next_state",
    "unbounded_retry"
)

$script:R18SeedFileMap = [ordered]@{
    created = "r18_008_seed_created.work_order.json"
    intake_validated = "r18_008_seed_intake_validated.work_order.json"
    ready_for_handoff = "r18_008_seed_ready_for_handoff.work_order.json"
    blocked_pending_future_execution_runtime = "r18_008_seed_blocked_pending_future_execution.work_order.json"
}

$script:R18TransitionFileDefinitions = @(
    [ordered]@{
        file = "created_to_intake_validated.transition.json"
        transition_id = "created_to_intake_validated"
        transition_name = "Created To Intake Validated"
        from_state = "created"
        to_state = "intake_validated"
        work_order_ref = "state/runtime/r18_work_order_seed_packets/r18_008_seed_created.work_order.json"
        transition_status = "transition_shape_validated"
    },
    [ordered]@{
        file = "intake_validated_to_ready_for_handoff.transition.json"
        transition_id = "intake_validated_to_work_order_defined"
        transition_name = "Intake Validated To Work Order Defined"
        from_state = "intake_validated"
        to_state = "work_order_defined"
        work_order_ref = "state/runtime/r18_work_order_seed_packets/r18_008_seed_intake_validated.work_order.json"
        transition_status = "transition_shape_validated"
    },
    [ordered]@{
        file = "ready_for_handoff_to_blocked_pending_future_execution.transition.json"
        transition_id = "ready_for_handoff_to_blocked_pending_future_execution_runtime"
        transition_name = "Ready For Handoff To Blocked Pending Future Execution Runtime"
        from_state = "ready_for_handoff"
        to_state = "blocked_pending_future_execution_runtime"
        work_order_ref = "state/runtime/r18_work_order_seed_packets/r18_008_seed_ready_for_handoff.work_order.json"
        transition_status = "transition_shape_validated"
    },
    [ordered]@{
        file = "invalid_execute_before_r18_009.transition.json"
        transition_id = "ready_for_handoff_to_blocked_pending_future_execution_runtime"
        transition_name = "Invalid Execute Before R18-009"
        from_state = "ready_for_handoff"
        to_state = "blocked_pending_future_execution_runtime"
        work_order_ref = "state/runtime/r18_work_order_seed_packets/r18_008_seed_ready_for_handoff.work_order.json"
        transition_status = "transition_refused"
    }
)

function Get-R18WorkOrderRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18WorkOrderPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18WorkOrderJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18WorkOrderJson {
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

function Write-R18WorkOrderText {
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

function Copy-R18WorkOrderObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18WorkOrderPaths {
    param([string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot))

    $seedRoot = "state/runtime/r18_work_order_seed_packets"
    $transitionRoot = "state/runtime/r18_work_order_transition_evaluations"
    $fixtureRoot = "tests/fixtures/r18_work_order_state_machine"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_008_work_order_state_machine"

    return [pscustomobject]@{
        Contract = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_work_order_state_machine.contract.json"
        StateMachine = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_work_order_state_machine.json"
        TransitionCatalog = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_work_order_transition_catalog.json"
        SeedRoot = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue $seedRoot
        TransitionRoot = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue $transitionRoot
        CheckReport = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_work_order_state_machine_check_report.json"
        UiSnapshot = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_work_order_state_machine_snapshot.json"
        Module = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18WorkOrderStateMachine.psm1"
        Generator = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_work_order_state_machine.ps1"
        Validator = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_work_order_state_machine.ps1"
        Test = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_work_order_state_machine.ps1"
        FixtureRoot = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
    }
}

function Get-R18WorkOrderSeedPath {
    param(
        [Parameter(Mandatory = $true)][string]$State,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    if (-not $script:R18SeedFileMap.Contains($State)) {
        throw "No R18-008 seed file is registered for state '$State'."
    }

    $paths = Get-R18WorkOrderPaths -RepositoryRoot $RepositoryRoot
    return Join-Path $paths.SeedRoot $script:R18SeedFileMap[$State]
}

function Get-R18WorkOrderTransitionPath {
    param(
        [Parameter(Mandatory = $true)][string]$FileName,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    $paths = Get-R18WorkOrderPaths -RepositoryRoot $RepositoryRoot
    return Join-Path $paths.TransitionRoot $FileName
}

function Get-R18WorkOrderAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_registry.json",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_registry.json",
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "state/intake/r18_orchestrator_control_intake_registry.json",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "state/runtime/r18_local_runner_cli_command_catalog.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json"
    )
}

function Get-R18WorkOrderEvidenceRefs {
    return @(
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_state_machine.json",
        "state/runtime/r18_work_order_transition_catalog.json",
        "state/runtime/r18_work_order_seed_packets/",
        "state/runtime/r18_work_order_transition_evaluations/",
        "state/runtime/r18_work_order_state_machine_check_report.json",
        "state/ui/r18_operator_surface/r18_work_order_state_machine_snapshot.json",
        "tools/R18WorkOrderStateMachine.psm1",
        "tools/new_r18_work_order_state_machine.ps1",
        "tools/validate_r18_work_order_state_machine.ps1",
        "tests/test_r18_work_order_state_machine.ps1",
        "tests/fixtures/r18_work_order_state_machine/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_008_work_order_state_machine/"
    )
}

function Get-R18WorkOrderAllowedPaths {
    return @(
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_state_machine.json",
        "state/runtime/r18_work_order_transition_catalog.json",
        "state/runtime/r18_work_order_seed_packets/",
        "state/runtime/r18_work_order_transition_evaluations/",
        "state/runtime/r18_work_order_state_machine_check_report.json",
        "state/ui/r18_operator_surface/r18_work_order_state_machine_snapshot.json",
        "tools/R18WorkOrderStateMachine.psm1",
        "tools/new_r18_work_order_state_machine.ps1",
        "tools/validate_r18_work_order_state_machine.ps1",
        "tests/test_r18_work_order_state_machine.ps1",
        "tests/fixtures/r18_work_order_state_machine/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_008_work_order_state_machine/",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_opening_authority.ps1",
        "tools/R18AgentCardSchema.psm1",
        "tools/R18SkillContractSchema.psm1",
        "tools/R18A2AHandoffPacketSchema.psm1",
        "tools/R18RoleSkillPermissionMatrix.psm1",
        "tools/R18OrchestratorControlIntake.psm1",
        "tools/R18LocalRunnerCli.psm1",
        "tests/test_r18_agent_card_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1",
        "tests/test_r18_orchestrator_control_intake.ps1",
        "tests/test_r18_local_runner_cli.ps1"
    )
}

function Get-R18WorkOrderForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_*",
        "state/proof_reviews/r14_*",
        "state/proof_reviews/r15_*",
        "state/proof_reviews/r16_*",
        "state/external_runs/",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_execution_log.jsonl",
        "main branch",
        "repository root broad write",
        "unbounded wildcard write paths"
    )
}

function Get-R18WorkOrderValidationRefs {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_work_order_state_machine.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_work_order_state_machine.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_work_order_state_machine.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R18WorkOrderRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18WorkOrderNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-008 only.",
        "R18-009 through R18-028 remain planned only.",
        "R18-008 created work-order execution state machine foundation only.",
        "Work-order state machine is not runtime execution.",
        "Runner state store is not implemented.",
        "Resumable execution log is not implemented.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No stage/commit/push was performed by the runner or state machine.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function New-R18WorkOrderPathPolicy {
    return [ordered]@{
        allowed_paths = Get-R18WorkOrderAllowedPaths
        forbidden_paths = Get-R18WorkOrderForbiddenPaths
        allowed_paths_must_be_exact_or_task_scoped = $true
        wildcard_paths_allowed = $false
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
        runner_state_store_paths_allowed = $false
        resumable_execution_log_paths_allowed = $false
        state_machine_write_paths_limited_to_r18_008_foundation_artifacts = $true
    }
}

function New-R18WorkOrderApiPolicy {
    return [ordered]@{
        api_enabled = $false
        openai_api_invocation_allowed = $false
        codex_api_invocation_allowed = $false
        autonomous_codex_invocation_allowed = $false
        automatic_new_thread_creation_allowed = $false
        api_controls_required_before_enablement = $true
        operator_approval_required_for_api_enablement = $true
    }
}

function New-R18WorkOrderExecutionPolicy {
    return [ordered]@{
        transition_evaluation_only = $true
        work_order_execution_allowed = $false
        work_order_state_machine_runtime_allowed = $false
        runner_state_store_allowed = $false
        resumable_execution_log_allowed = $false
        local_runner_runtime_allowed = $false
        skill_execution_allowed = $false
        a2a_dispatch_allowed = $false
        api_invocation_allowed = $false
        stage_commit_push_allowed_by_state_machine = $false
        board_runtime_mutation_allowed = $false
        live_agent_invocation_allowed = $false
        live_recovery_runtime_allowed = $false
        product_runtime_execution_allowed = $false
    }
}

function New-R18WorkOrderValidationExpectations {
    return [ordered]@{
        checks = @(
            "required_fields",
            "required_states",
            "required_transition_ids",
            "known_state_values",
            "known_transition_values",
            "authority_refs",
            "intake_packet_ref",
            "handoff_refs",
            "permission_matrix_ref",
            "validation_expectations",
            "evidence_obligations",
            "bounded_next_states",
            "bounded_retry",
            "path_policy",
            "runtime_false_flags",
            "status_boundary"
        )
        validation_commands = Get-R18WorkOrderValidationRefs
        fail_closed_on_missing_fields = $true
        unknown_states_rejected = $true
        unknown_transitions_rejected = $true
        runtime_claims_rejected = $true
    }
}

function New-R18WorkOrderEvidenceObligations {
    return @(
        "state_machine_contract_ref_recorded",
        "work_order_seed_packet_ref_recorded",
        "transition_catalog_ref_recorded",
        "transition_evaluation_ref_recorded",
        "authority_refs_recorded",
        "intake_packet_ref_recorded",
        "handoff_packet_ref_recorded",
        "permission_matrix_ref_recorded",
        "runtime_false_flags_recorded",
        "non_claims_preserved"
    )
}

function New-R18WorkOrderRetryFailoverPolicy {
    return [ordered]@{
        retry_runtime_implemented = $false
        retry_execution_allowed = $false
        retry_count = 0
        max_retry_count = 1
        retry_count_required = $true
        retry_limit_enforced = $true
        unbounded_retry_allowed = $false
        failure_packet_required_for_retry = $true
        operator_decision_required_at_retry_limit = $true
        failover_without_packet_allowed = $false
        fail_closed_on_unbounded_retry = $true
    }
}

function New-R18WorkOrderPermissionMatrixRef {
    return [ordered]@{
        matrix_ref = "state/skills/r18_role_skill_permission_matrix.json"
        contract_ref = "contracts/skills/r18_role_skill_permission_matrix.contract.json"
        permission_id = "project_manager__define_work_order"
        role = "Project Manager"
        skill_id = "define_work_order"
        permission_status = "allowed"
        permission_runtime_enforced = $false
        bypass_allowed = $false
    }
}

function Get-R18WorkOrderHandoffRefs {
    return @(
        "state/a2a/r18_handoff_registry.json",
        "state/a2a/r18_handoff_packets/orchestrator_to_project_manager_define_work_order.handoff.json"
    )
}

function New-R18WorkOrderTransitionRows {
    $common = @{
        authority_refs_required = $true
        intake_packet_ref_required = $true
        permission_matrix_ref_required = $true
        validation_expectations_required = $true
        evidence_obligations_required = $true
        retry_bounded = $true
        transition_evaluation_only = $true
        work_order_execution_allowed = $false
    }

    return @(
        [ordered]@{
            transition_id = "created_to_intake_validated"
            transition_name = "Created To Intake Validated"
            from_states = @("created")
            to_state = "intake_validated"
            blocked = $false
            requirements = $common
        },
        [ordered]@{
            transition_id = "intake_validated_to_work_order_defined"
            transition_name = "Intake Validated To Work Order Defined"
            from_states = @("intake_validated")
            to_state = "work_order_defined"
            blocked = $false
            requirements = $common
        },
        [ordered]@{
            transition_id = "work_order_defined_to_waiting_for_handoff_validation"
            transition_name = "Work Order Defined To Waiting For Handoff Validation"
            from_states = @("work_order_defined")
            to_state = "waiting_for_handoff_validation"
            blocked = $false
            requirements = $common + @{ handoff_refs_required = $true }
        },
        [ordered]@{
            transition_id = "waiting_for_handoff_validation_to_ready_for_handoff"
            transition_name = "Waiting For Handoff Validation To Ready For Handoff"
            from_states = @("waiting_for_handoff_validation")
            to_state = "ready_for_handoff"
            blocked = $false
            requirements = $common + @{ handoff_refs_required = $true }
        },
        [ordered]@{
            transition_id = "ready_for_handoff_to_blocked_pending_future_execution_runtime"
            transition_name = "Ready For Handoff To Blocked Pending Future Execution Runtime"
            from_states = @("ready_for_handoff")
            to_state = "blocked_pending_future_execution_runtime"
            blocked = $true
            block_reason = "R18-009 runner state store and resumable execution log are not implemented; work-order execution remains fail-closed."
            requirements = $common + @{ handoff_refs_required = $true; execution_block_required = $true }
        },
        [ordered]@{
            transition_id = "any_state_to_validation_failed"
            transition_name = "Any State To Validation Failed"
            from_states = @("any_required_state")
            to_state = "validation_failed"
            blocked = $true
            requirements = $common + @{ validation_failure_required = $true }
        },
        [ordered]@{
            transition_id = "any_state_to_blocked_pending_operator_decision"
            transition_name = "Any State To Blocked Pending Operator Decision"
            from_states = @("any_required_state")
            to_state = "blocked_pending_operator_decision"
            blocked = $true
            requirements = $common + @{ operator_decision_required = $true }
        },
        [ordered]@{
            transition_id = "blocked_pending_operator_decision_to_abandoned"
            transition_name = "Blocked Pending Operator Decision To Abandoned"
            from_states = @("blocked_pending_operator_decision")
            to_state = "abandoned"
            blocked = $true
            requirements = $common + @{ explicit_future_operator_decision_required = $true }
        },
        [ordered]@{
            transition_id = "foundation_package_to_completed_foundation_only"
            transition_name = "Foundation Package To Completed Foundation Only"
            from_states = @("created", "intake_validated", "work_order_defined", "waiting_for_handoff_validation", "ready_for_handoff", "blocked_pending_future_execution_runtime")
            to_state = "completed_foundation_only"
            blocked = $false
            requirements = $common + @{ closes_r18_008_foundation_only = $true; future_work_order_execution_completion_allowed = $false }
        }
    )
}

function New-R18WorkOrderContract {
    return [ordered]@{
        artifact_type = "r18_work_order_state_machine_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-008-work-order-state-machine-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "work_order_execution_state_machine_foundation_only_no_runtime_execution"
        purpose = "Define the governed work-order state machine that future R18-009+ runner/runtime work can consume without executing work orders, persisting runner state, creating resumable execution logs, invoking live agents or skills, dispatching A2A, calling APIs, or mutating board/card runtime state."
        required_states = $script:R18RequiredStates
        required_transition_ids = $script:R18RequiredTransitionIds
        required_work_order_fields = $script:R18RequiredWorkOrderFields
        required_transition_fields = $script:R18RequiredTransitionFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        state_policy = [ordered]@{
            finite_state_set_required = $true
            exact_required_states_only = $true
            unknown_states_allowed = $false
            unbounded_next_states_allowed = $false
            completed_foundation_only_is_not_runtime_completion = $true
        }
        transition_policy = [ordered]@{
            finite_transition_set_required = $true
            exact_required_transition_ids_only = $true
            unknown_transitions_allowed = $false
            transitions_are_validation_evaluation_artifacts_only = $true
            transitions_must_not_execute_work_orders = $true
            transitions_must_not_persist_runner_state = $true
            transitions_must_not_create_resumable_execution_log = $true
            transitions_must_not_mutate_board_card_runtime_state = $true
            transitions_must_not_dispatch_a2a = $true
            transitions_must_not_execute_skills = $true
            transitions_must_not_call_apis = $true
            execution_block_transition_id = "ready_for_handoff_to_blocked_pending_future_execution_runtime"
            foundation_close_transition_id = "foundation_package_to_completed_foundation_only"
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            all_required_authority_refs_must_exist = $true
            missing_authority_refs_fail_closed = $true
            approved_authority_refs = Get-R18WorkOrderAuthorityRefs
        }
        intake_policy = [ordered]@{
            intake_packet_ref_required = $true
            intake_packet_ref_must_exist = $true
            approved_intake_packet_ref = "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json"
            intake_validation_is_shape_only = $true
            runtime_routing_allowed = $false
        }
        handoff_policy = [ordered]@{
            handoff_refs_required_when_routing_implied = $true
            handoff_shape_validation_only = $true
            live_a2a_dispatch_allowed = $false
            handoff_refs = Get-R18WorkOrderHandoffRefs
            missing_handoff_refs_fail_closed = $true
        }
        permission_policy = [ordered]@{
            permission_matrix_ref_required = $true
            role_skill_permission_matrix_ref = "state/skills/r18_role_skill_permission_matrix.json"
            permission_runtime_enforcement_implemented = $false
            permission_bypass_allowed = $false
        }
        validation_policy = New-R18WorkOrderValidationExpectations
        evidence_policy = [ordered]@{
            evidence_obligations_required = $true
            evidence_obligations = New-R18WorkOrderEvidenceObligations
            deterministic_seed_packets_required = $true
            deterministic_transition_evaluations_required = $true
            proof_review_package_required = $true
            historical_r13_r16_evidence_edits_allowed = $false
            operator_local_backup_paths_allowed = $false
        }
        retry_failure_policy = New-R18WorkOrderRetryFailoverPolicy
        path_policy = New-R18WorkOrderPathPolicy
        api_policy = New-R18WorkOrderApiPolicy
        execution_policy = New-R18WorkOrderExecutionPolicy
        refusal_policy = [ordered]@{
            ready_for_handoff_to_blocked_pending_future_execution_runtime_must_block_execution_until = "R18-009_or_later"
            execute_work_order_before_r18_009_must_be_refused = $true
            unsafe_transition_requests_fail_closed = $true
            refusal_results_must_include_non_claims = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18WorkOrderNonClaims
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        authority_refs = Get-R18WorkOrderAuthorityRefs
        runtime_flags = Get-R18WorkOrderRuntimeFlags
    }
}

function New-R18WorkOrderStateMachine {
    $states = @()
    foreach ($state in $script:R18RequiredStates) {
        $states += [ordered]@{
            state_id = $state
            semantics = $script:R18StateSemantics[$state]
            state_is_runtime_execution = $false
            terminal_for_future_runtime = ($state -in @("abandoned"))
            foundation_terminal_only = ($state -eq "completed_foundation_only")
        }
    }

    return [ordered]@{
        artifact_type = "r18_work_order_state_machine"
        contract_version = "v1"
        state_machine_id = "aioffice-r18-008-work-order-state-machine-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        active_through_task = $script:R18SourceTask
        state_machine_status = "foundation_only_not_runtime_executed"
        states = $states
        transitions = New-R18WorkOrderTransitionRows
        state_policy = [ordered]@{
            exact_required_states_only = $true
            unknown_states_allowed = $false
            unbounded_next_states_allowed = $false
            fail_closed_on_invalid_state = $true
        }
        transition_policy = [ordered]@{
            exact_required_transition_ids_only = $true
            unknown_transitions_allowed = $false
            transition_evaluation_only = $true
            fail_closed_on_invalid_transition = $true
            execution_block_transition_required = $true
        }
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        positive_claims = @(
            "r18_work_order_state_machine_created",
            "r18_work_order_transition_catalog_created"
        )
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        authority_refs = Get-R18WorkOrderAuthorityRefs
    }
}

function New-R18WorkOrderTransitionCatalog {
    return [ordered]@{
        artifact_type = "r18_work_order_transition_catalog"
        contract_version = "v1"
        catalog_id = "aioffice-r18-008-work-order-transition-catalog-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        active_through_task = $script:R18SourceTask
        transition_count = @($script:R18RequiredTransitionIds).Count
        required_transition_ids = $script:R18RequiredTransitionIds
        transitions = New-R18WorkOrderTransitionRows
        unknown_transitions_fail_closed = $true
        execution_block_transition = "ready_for_handoff_to_blocked_pending_future_execution_runtime"
        foundation_close_transition = "foundation_package_to_completed_foundation_only"
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        positive_claims = @("r18_work_order_transition_catalog_created")
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        authority_refs = Get-R18WorkOrderAuthorityRefs
    }
}

function New-R18WorkOrderSeed {
    param(
        [Parameter(Mandatory = $true)][string]$CurrentState,
        [AllowNull()][string]$PreviousState,
        [Parameter(Mandatory = $true)][string[]]$NextAllowedStates,
        [Parameter(Mandatory = $true)][string]$WorkOrderStatus
    )

    return [ordered]@{
        artifact_type = "r18_work_order_seed_packet"
        contract_version = "v1"
        work_order_id = ("r18_008_seed_{0}" -f $CurrentState)
        work_order_name = ("R18-008 Seed {0}" -f ($CurrentState -replace "_", " "))
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        work_order_status = $WorkOrderStatus
        current_state = $CurrentState
        previous_state = $PreviousState
        next_allowed_states = $NextAllowedStates
        intake_packet_ref = "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json"
        handoff_packet_refs = Get-R18WorkOrderHandoffRefs
        target_role = "Project Manager"
        target_skill = "define_work_order"
        authority_refs = Get-R18WorkOrderAuthorityRefs
        permission_matrix_ref = New-R18WorkOrderPermissionMatrixRef
        allowed_paths = Get-R18WorkOrderAllowedPaths
        forbidden_paths = Get-R18WorkOrderForbiddenPaths
        acceptance_criteria = @(
            "state_machine_contract_shape_validated",
            "required_states_declared",
            "required_transitions_declared",
            "authority_intake_handoff_permission_refs_declared",
            "execution_block_before_r18_009_declared",
            "runtime_false_flags_preserved",
            "status_boundary_preserved_through_r18_008_only"
        )
        validation_expectations = New-R18WorkOrderValidationExpectations
        evidence_obligations = New-R18WorkOrderEvidenceObligations
        retry_failover_policy = New-R18WorkOrderRetryFailoverPolicy
        failure_routing = [ordered]@{
            behavior = "fail_closed_and_block_transition"
            failure_routing_target_role = "Orchestrator"
            failure_packet_required = $true
            block_on_denied_permission = $true
            stop_on_runtime_claim = $true
            retry_without_repair_allowed = $false
            bypass_allowed = $false
        }
        operator_decision_policy = [ordered]@{
            operator_decision_required_for_abandonment = $true
            operator_decision_required_for_retry_limit = $true
            operator_decision_required_for_unsafe_state = $true
            decision_may_be_inferred = $false
            approval_bypass_allowed = $false
        }
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WorkOrderSeedPackets {
    $seeds = @()
    $seeds += New-R18WorkOrderSeed -CurrentState "created" -PreviousState $null -NextAllowedStates @("intake_validated", "validation_failed", "blocked_pending_operator_decision") -WorkOrderStatus "seed_created_packet_only"
    $seeds += New-R18WorkOrderSeed -CurrentState "intake_validated" -PreviousState "created" -NextAllowedStates @("work_order_defined", "validation_failed", "blocked_pending_operator_decision") -WorkOrderStatus "seed_intake_validated_packet_only"
    $seeds += New-R18WorkOrderSeed -CurrentState "ready_for_handoff" -PreviousState "waiting_for_handoff_validation" -NextAllowedStates @("blocked_pending_future_execution_runtime", "validation_failed", "blocked_pending_operator_decision") -WorkOrderStatus "seed_ready_for_handoff_packet_only"
    $seeds += New-R18WorkOrderSeed -CurrentState "blocked_pending_future_execution_runtime" -PreviousState "ready_for_handoff" -NextAllowedStates @("blocked_pending_operator_decision", "validation_failed") -WorkOrderStatus "seed_blocked_pending_future_execution_packet_only"
    return $seeds
}

function New-R18WorkOrderTransitionEvaluation {
    param([Parameter(Mandatory = $true)][object]$Definition)

    $transitionId = [string]$Definition.transition_id
    $status = [string]$Definition.transition_status
    $refusedActions = @(
        "work_order_execution",
        "runner_state_store_creation",
        "resumable_execution_log_creation",
        "live_runner_runtime",
        "skill_execution",
        "a2a_dispatch",
        "api_invocation",
        "board_runtime_mutation",
        "stage_commit_push_by_state_machine"
    )
    if ($status -eq "transition_refused") {
        $refusedActions += "execute_work_order_before_r18_009"
    }

    return [ordered]@{
        artifact_type = "r18_work_order_transition_evaluation"
        contract_version = "v1"
        transition_id = $transitionId
        transition_name = [string]$Definition.transition_name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        transition_status = $status
        from_state = [string]$Definition.from_state
        to_state = [string]$Definition.to_state
        work_order_ref = [string]$Definition.work_order_ref
        transition_preconditions = [ordered]@{
            authority_refs = Get-R18WorkOrderAuthorityRefs
            intake_packet_ref = "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json"
            handoff_packet_refs = Get-R18WorkOrderHandoffRefs
            permission_matrix_ref = New-R18WorkOrderPermissionMatrixRef
            validation_expectations = New-R18WorkOrderValidationExpectations
            evidence_obligations = New-R18WorkOrderEvidenceObligations
            retry_failover_policy = New-R18WorkOrderRetryFailoverPolicy
            preconditions_are_shape_only = $true
        }
        authority_check = [ordered]@{
            check_status = "passed"
            authority_refs = Get-R18WorkOrderAuthorityRefs
            authority_ref_count = @(Get-R18WorkOrderAuthorityRefs).Count
            live_authority_mutation_performed = $false
        }
        intake_check = [ordered]@{
            check_status = "passed"
            intake_packet_ref = "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json"
            intake_shape_validated = $true
            runtime_routing_performed = $false
            work_order_executed = $false
        }
        handoff_check = [ordered]@{
            check_status = "passed"
            handoff_packet_refs = Get-R18WorkOrderHandoffRefs
            handoff_shape_validated = $true
            live_a2a_dispatch_performed = $false
            a2a_message_sent = $false
        }
        permission_check = [ordered]@{
            check_status = "passed"
            permission_matrix_ref = New-R18WorkOrderPermissionMatrixRef
            role_skill_permission_shape_validated = $true
            runtime_permission_enforcement_implemented = $false
            permission_bypass_allowed = $false
        }
        validation_check = [ordered]@{
            check_status = if ($status -eq "transition_failed") { "failed" } else { "passed" }
            validation_expectations = New-R18WorkOrderValidationExpectations
            transition_shape_validated = ($status -ne "transition_failed")
            status_boundary_validated = $true
        }
        evidence_check = [ordered]@{
            check_status = "passed"
            evidence_obligations = New-R18WorkOrderEvidenceObligations
            evidence_refs_recorded = $true
            historical_evidence_edit_performed = $false
        }
        retry_check = [ordered]@{
            check_status = "passed"
            retry_count = 0
            max_retry_count = 1
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
            retry_runtime_implemented = $false
        }
        path_check = [ordered]@{
            check_status = "passed"
            allowed_paths = Get-R18WorkOrderAllowedPaths
            forbidden_paths = Get-R18WorkOrderForbiddenPaths
            operator_local_backup_paths_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
            broad_repo_writes_allowed = $false
            runner_state_store_path_allowed = $false
            resumable_execution_log_path_allowed = $false
        }
        execution_block_check = [ordered]@{
            check_status = "passed"
            work_order_execution_performed = $false
            work_order_execution_allowed = $false
            work_order_execution_blocked_until = "R18-009_or_later_state_store_and_runtime"
            runner_state_store_implemented = $false
            resumable_execution_log_implemented = $false
            local_runner_runtime_executed = $false
            skill_execution_performed = $false
            a2a_message_sent = $false
            api_invocation_performed = $false
            stage_commit_push_performed_by_state_machine = $false
            board_runtime_mutation_performed = $false
            product_runtime_executed = $false
        }
        next_allowed_actions = @(
            "validate_r18_008_foundation_artifacts",
            "keep_execution_blocked_until_r18_009",
            "preserve_r18_009_through_r18_028_planned_only"
        )
        refused_actions = $refusedActions
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        validation_refs = Get-R18WorkOrderValidationRefs
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WorkOrderTransitionEvaluations {
    $evaluations = @()
    foreach ($definition in $script:R18TransitionFileDefinitions) {
        $evaluations += (New-R18WorkOrderTransitionEvaluation -Definition $definition)
    }
    return $evaluations
}

function New-R18WorkOrderCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Seeds,
        [Parameter(Mandatory = $true)][object[]]$Transitions
    )

    return [ordered]@{
        artifact_type = "r18_work_order_state_machine_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-008-work-order-state-machine-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        active_through_task = $script:R18SourceTask
        required_state_count = @($script:R18RequiredStates).Count
        required_transition_count = @($script:R18RequiredTransitionIds).Count
        generated_seed_count = @($Seeds).Count
        generated_transition_evaluation_count = @($Transitions).Count
        checks = [ordered]@{
            contract_created = @{ status = "passed"; ref = "contracts/runtime/r18_work_order_state_machine.contract.json" }
            state_machine_created = @{ status = "passed"; ref = "state/runtime/r18_work_order_state_machine.json" }
            transition_catalog_created = @{ status = "passed"; ref = "state/runtime/r18_work_order_transition_catalog.json" }
            seed_packets_created = @{ status = "passed"; count = @($Seeds).Count }
            transition_evaluations_created = @{ status = "passed"; count = @($Transitions).Count }
            required_states_declared = @{ status = "passed"; count = @($script:R18RequiredStates).Count }
            required_transitions_declared = @{ status = "passed"; count = @($script:R18RequiredTransitionIds).Count }
            execution_block_before_r18_009 = @{ status = "passed"; enforced = $true; transition_id = "ready_for_handoff_to_blocked_pending_future_execution_runtime" }
            runner_state_store_not_implemented = @{ status = "passed"; implemented = $false; forbidden_path = "state/runtime/r18_runner_state.json" }
            resumable_execution_log_not_implemented = @{ status = "passed"; implemented = $false; forbidden_path = "state/runtime/r18_execution_log.jsonl" }
            runtime_false_flags = @{ status = "passed"; all_required_false = $true }
            status_boundary = @{ status = "passed"; active_through_task = "R18-008"; planned_from = "R18-009" }
        }
        aggregate_verdict = $script:R18Verdict
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        authority_refs = Get-R18WorkOrderAuthorityRefs
    }
}

function New-R18WorkOrderSnapshot {
    param(
        [Parameter(Mandatory = $true)][object[]]$Seeds,
        [Parameter(Mandatory = $true)][object[]]$Transitions
    )

    return [ordered]@{
        artifact_type = "r18_work_order_state_machine_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-008-work-order-state-machine-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = $script:R18SourceTask
        ui_boundary_label = "R18-008 work-order state machine foundation only; execution blocked until R18-009+"
        state_machine_status = "foundation_only_not_runtime_execution"
        required_states = $script:R18RequiredStates
        required_transition_ids = $script:R18RequiredTransitionIds
        seed_work_order_ids = @($Seeds | ForEach-Object { [string]$_.work_order_id })
        transition_evaluation_ids = @($Transitions | ForEach-Object { [string]$_.transition_id })
        execution_block_summary = [ordered]@{
            ready_for_handoff_to_blocked_pending_future_execution_runtime_blocks_execution = $true
            work_order_execution_allowed = $false
            runner_state_store_implemented = $false
            resumable_execution_log_implemented = $false
        }
        runtime_summary = Get-R18WorkOrderRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        authority_refs = Get-R18WorkOrderAuthorityRefs
    }
}

function New-R18WorkOrderEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_work_order_state_machine_evidence_index"
        contract_version = "v1"
        evidence_index_id = "aioffice-r18-008-work-order-state-machine-evidence-index-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_refs = Get-R18WorkOrderEvidenceRefs
        validation_refs = Get-R18WorkOrderValidationRefs
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        positive_claims = @("r18_work_order_state_machine_proof_review_created")
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WorkOrderProofReviewText {
    return @"
# R18-008 Work-Order State Machine Proof Review

R18-008 created a work-order execution state machine foundation only. The package defines required states, transition identifiers, seed work-order packets, transition-evaluation artifacts, fail-closed validation, runtime false flags, and an operator-surface snapshot.

This proof review does not claim work-order execution, runner state storage, resumable execution logging, live runner runtime, live agent invocation, live skill execution, A2A dispatch, recovery runtime, API invocation, automatic new-thread creation, product runtime, Codex reliability, Codex compaction resolution, no-manual-prompt-transfer success, stage/commit/push by the runner/state machine, or main merge.

The execution-block transition `ready_for_handoff_to_blocked_pending_future_execution_runtime` explicitly blocks work-order execution until R18-009 or later.
"@
}

function New-R18WorkOrderValidationManifestText {
    return @"
# R18-008 Validation Manifest

Required validation:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_work_order_state_machine.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_work_order_state_machine.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_work_order_state_machine.ps1`
- Prior R18 validators and status-doc gate validators must continue to pass with R18 active through R18-008 only and R18-009 through R18-028 planned only.

The validator fails closed on missing artifacts, unknown states, unknown transitions, missing refs, missing validation/evidence obligations, unbounded next states, unbounded retry, forbidden path permissions, runtime/API/agent/skill/A2A/recovery/product claims, R18-009+ completion claims, and status surfaces beyond R18-008.
"@
}

function New-R18WorkOrderFixtureDefinitions {
    $defs = @(
        @{ file = "invalid_missing_work_order_id.json"; target = "seed:created"; remove_paths = @("work_order_id"); expected = @("missing required field 'work_order_id'") },
        @{ file = "invalid_missing_current_state.json"; target = "seed:created"; remove_paths = @("current_state"); expected = @("missing required field 'current_state'") },
        @{ file = "invalid_unknown_state.json"; target = "seed:created"; set_values = [ordered]@{ current_state = "unknown_state" }; expected = @("unknown state") },
        @{ file = "invalid_missing_transition_id.json"; target = "transition:created_to_intake_validated"; remove_paths = @("transition_id"); expected = @("missing required field 'transition_id'") },
        @{ file = "invalid_unknown_transition.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ transition_id = "unknown_transition" }; expected = @("unknown transition") },
        @{ file = "invalid_transition_without_authority_refs.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "authority_check.authority_refs" = @() }; expected = @("authority refs") },
        @{ file = "invalid_transition_without_intake_ref.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "intake_check.intake_packet_ref" = "" }; expected = @("intake packet ref") },
        @{ file = "invalid_transition_without_handoff_ref.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "handoff_check.handoff_packet_refs" = @() }; expected = @("handoff refs") },
        @{ file = "invalid_transition_without_permission_matrix_ref.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "permission_check.permission_matrix_ref.matrix_ref" = "" }; expected = @("permission matrix ref") },
        @{ file = "invalid_transition_without_validation_expectations.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "validation_check.validation_expectations.checks" = @() }; expected = @("validation expectations") },
        @{ file = "invalid_transition_without_evidence_obligations.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "evidence_check.evidence_obligations" = @() }; expected = @("evidence obligations") },
        @{ file = "invalid_unbounded_next_state.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ next_allowed_actions = @("*") }; expected = @("unbounded next") },
        @{ file = "invalid_unbounded_retry.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "retry_check.unbounded_retry_allowed" = $true }; expected = @("unbounded retry") },
        @{ file = "invalid_execute_work_order_claim.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "runtime_flags.work_order_execution_performed" = $true }; expected = @("runtime flag 'work_order_execution_performed' must be false") },
        @{ file = "invalid_runner_state_store_claim.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "runtime_flags.runner_state_store_implemented" = $true }; expected = @("runtime flag 'runner_state_store_implemented' must be false") },
        @{ file = "invalid_resumable_execution_log_claim.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "runtime_flags.resumable_execution_log_implemented" = $true }; expected = @("runtime flag 'resumable_execution_log_implemented' must be false") },
        @{ file = "invalid_live_runner_runtime_claim.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "runtime_flags.local_runner_runtime_executed" = $true }; expected = @("runtime flag 'local_runner_runtime_executed' must be false") },
        @{ file = "invalid_skill_execution_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.live_skill_execution_performed" = $true }; expected = @("runtime flag 'live_skill_execution_performed' must be false") },
        @{ file = "invalid_a2a_message_sent_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.a2a_message_sent" = $true }; expected = @("runtime flag 'a2a_message_sent' must be false") },
        @{ file = "invalid_board_runtime_mutation_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.board_runtime_mutation_performed" = $true }; expected = @("runtime flag 'board_runtime_mutation_performed' must be false") },
        @{ file = "invalid_api_invocation_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.openai_api_invoked" = $true }; expected = @("runtime flag 'openai_api_invoked' must be false") },
        @{ file = "invalid_automatic_new_thread_creation_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.automatic_new_thread_creation_performed" = $true }; expected = @("runtime flag 'automatic_new_thread_creation_performed' must be false") },
        @{ file = "invalid_stage_commit_push_claim.json"; target = "transition:created_to_intake_validated"; set_values = [ordered]@{ "runtime_flags.stage_commit_push_performed" = $true }; expected = @("runtime flag 'stage_commit_push_performed' must be false") },
        @{ file = "invalid_operator_local_backup_path.json"; target = "seed:created"; set_values = [ordered]@{ allowed_paths = @(".local_backups/") }; expected = @("operator-local backup path") },
        @{ file = "invalid_historical_evidence_edit_permission.json"; target = "seed:created"; set_values = [ordered]@{ allowed_paths = @("state/proof_reviews/r15_historical_evidence/") }; expected = @("historical R13/R14/R15/R16 evidence") },
        @{ file = "invalid_broad_repo_write.json"; target = "seed:created"; set_values = [ordered]@{ allowed_paths = @(".") }; expected = @("broad repo write") },
        @{ file = "invalid_r18_009_completion_claim.json"; target = "transition:ready_for_handoff_to_blocked_pending_future_execution_runtime"; set_values = [ordered]@{ "runtime_flags.r18_009_completed" = $true }; expected = @("runtime flag 'r18_009_completed' must be false") }
    )

    $fixtures = @()
    foreach ($definition in $defs) {
        $fixture = [ordered]@{
            artifact_type = "r18_work_order_state_machine_invalid_fixture"
            contract_version = "v1"
            fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($definition.file)
            source_task = $script:R18SourceTask
            target = $definition.target
            expected_failure_fragments = $definition.expected
        }
        if ($definition.ContainsKey("remove_paths")) {
            $fixture["remove_paths"] = $definition.remove_paths
        }
        if ($definition.ContainsKey("set_values")) {
            $fixture["set_values"] = $definition.set_values
        }
        $fixtures += [pscustomobject]@{ file = $definition.file; fixture = $fixture }
    }

    return $fixtures
}

function New-R18WorkOrderFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$FixtureDefinitions)

    return [ordered]@{
        artifact_type = "r18_work_order_state_machine_fixture_manifest"
        contract_version = "v1"
        fixture_manifest_id = "aioffice-r18-008-work-order-state-machine-fixture-manifest-v1"
        source_task = $script:R18SourceTask
        fixture_count = @($FixtureDefinitions).Count
        fixtures = @($FixtureDefinitions | ForEach-Object { $_.file })
        runtime_flags = Get-R18WorkOrderRuntimeFlags
        non_claims = Get-R18WorkOrderNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Assert-R18WorkOrderCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18WorkOrderRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R18WorkOrderRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        if ($null -eq $RuntimeFlags.PSObject.Properties[$field]) {
            throw "$Context missing runtime flag '$field'."
        }
        if ([bool]$RuntimeFlags.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context runtime flag '$field' must be false."
        }
    }
}

function Assert-R18WorkOrderAllowedPaths {
    param(
        [Parameter(Mandatory = $true)][object[]]$AllowedPaths,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18WorkOrderCondition -Condition (@($AllowedPaths).Count -gt 0) -Message "$Context allowed_paths must not be empty."
    foreach ($path in @($AllowedPaths)) {
        $value = [string]$path
        if ([string]::IsNullOrWhiteSpace($value) -or $value -in @(".", ".\", "./", "*", "/*", "\*")) {
            throw "$Context allows broad repo write '$value'."
        }
        if ($value -match '(?i)\.local_backups|operator-local') {
            throw "$Context allows operator-local backup path '$value'."
        }
        if ($value -match '(?i)state[\\/]+proof_reviews[\\/]+r1[3-6]') {
            throw "$Context allows historical R13/R14/R15/R16 evidence edit path '$value'."
        }
        if ($value -match '\*') {
            throw "$Context allows wildcard path '$value'."
        }
    }
}

function Assert-R18WorkOrderForbiddenPaths {
    param(
        [Parameter(Mandatory = $true)][object[]]$ForbiddenPaths,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $joined = @($ForbiddenPaths) -join " "
    foreach ($required in @(".local_backups", "operator-local", "r13", "r14", "r15", "r16", "broad write", "r18_runner_state", "r18_execution_log")) {
        if ($joined -notmatch [regex]::Escape($required)) {
            throw "$Context forbidden_paths missing '$required'."
        }
    }
}

function Assert-R18WorkOrderAuthorityRefs {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$AuthorityRefs,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    Assert-R18WorkOrderCondition -Condition (@($AuthorityRefs).Count -gt 0) -Message "$Context authority refs must not be empty."
    foreach ($authorityRef in Get-R18WorkOrderAuthorityRefs) {
        if (@($AuthorityRefs) -notcontains $authorityRef) {
            throw "$Context missing required authority ref '$authorityRef'."
        }
        $resolved = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue $authorityRef
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context authority ref '$authorityRef' does not exist."
        }
    }
}

function Assert-R18WorkOrderKnownState {
    param(
        [AllowNull()][string]$State,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowNull
    )

    if ([string]::IsNullOrWhiteSpace($State)) {
        if ($AllowNull) {
            return
        }
        throw "$Context missing state."
    }
    if (@($script:R18RequiredStates) -notcontains $State) {
        throw "$Context unknown state '$State'."
    }
}

function Assert-R18WorkOrderKnownTransition {
    param(
        [Parameter(Mandatory = $true)][string]$TransitionId,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (@($script:R18RequiredTransitionIds) -notcontains $TransitionId) {
        throw "$Context unknown transition '$TransitionId'."
    }
}

function Assert-R18WorkOrderPositiveClaims {
    param(
        [AllowNull()][object[]]$PositiveClaims,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($claim in @($PositiveClaims)) {
        $value = [string]$claim
        if (@($script:R18AllowedPositiveClaims) -notcontains $value) {
            throw "$Context has disallowed positive claim '$value'."
        }
        if ($value -match '(?i)runner_state_store|resumable_execution_log|r18_009|execution_runtime|api|live') {
            throw "$Context has forbidden positive claim '$value'."
        }
    }
}

function Assert-R18WorkOrderContract {
    param([Parameter(Mandatory = $true)][object]$Contract, [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot))

    Assert-R18WorkOrderRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_states", "required_transition_ids", "required_work_order_fields", "required_transition_fields", "required_runtime_false_flags", "state_policy", "transition_policy", "authority_policy", "intake_policy", "handoff_policy", "permission_policy", "validation_policy", "evidence_policy", "retry_failure_policy", "path_policy", "api_policy", "execution_policy", "refusal_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags") -Context "R18 work-order state machine contract"
    Assert-R18WorkOrderCondition -Condition ([string]$Contract.source_task -eq $script:R18SourceTask) -Message "R18 work-order state machine contract source_task must be R18-008."
    foreach ($state in $script:R18RequiredStates) {
        Assert-R18WorkOrderCondition -Condition (@($Contract.required_states) -contains $state) -Message "R18 work-order state machine contract missing required state '$state'."
    }
    foreach ($transitionId in $script:R18RequiredTransitionIds) {
        Assert-R18WorkOrderCondition -Condition (@($Contract.required_transition_ids) -contains $transitionId) -Message "R18 work-order state machine contract missing required transition '$transitionId'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18WorkOrderCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "R18 work-order state machine contract missing runtime false flag '$flag'."
    }
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 work-order state machine contract"
    Assert-R18WorkOrderAuthorityRefs -AuthorityRefs $Contract.authority_refs -Context "R18 work-order state machine contract" -RepositoryRoot $RepositoryRoot
    Assert-R18WorkOrderAllowedPaths -AllowedPaths $Contract.path_policy.allowed_paths -Context "R18 work-order state machine contract path_policy"
    Assert-R18WorkOrderForbiddenPaths -ForbiddenPaths $Contract.path_policy.forbidden_paths -Context "R18 work-order state machine contract path_policy"
    Assert-R18WorkOrderCondition -Condition ([bool]$Contract.api_policy.api_enabled -eq $false) -Message "R18 work-order state machine contract API policy must remain disabled."
    Assert-R18WorkOrderCondition -Condition ([bool]$Contract.execution_policy.work_order_execution_allowed -eq $false) -Message "R18 work-order state machine contract must disallow work-order execution."
}

function Assert-R18WorkOrderStateMachine {
    param([Parameter(Mandatory = $true)][object]$StateMachine)

    Assert-R18WorkOrderRequiredFields -Object $StateMachine -FieldNames @("artifact_type", "contract_version", "state_machine_id", "source_task", "source_milestone", "repository", "branch", "active_through_task", "state_machine_status", "states", "transitions", "state_policy", "transition_policy", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 work-order state machine"
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $StateMachine.runtime_flags -Context "R18 work-order state machine"
    Assert-R18WorkOrderPositiveClaims -PositiveClaims $StateMachine.positive_claims -Context "R18 work-order state machine"
    $stateIds = @($StateMachine.states | ForEach-Object { [string]$_.state_id } | Sort-Object)
    $expectedStates = @($script:R18RequiredStates | Sort-Object)
    Assert-R18WorkOrderCondition -Condition (($stateIds -join "|") -eq ($expectedStates -join "|")) -Message "R18 work-order state machine must contain exactly the required states."
    $transitionIds = @($StateMachine.transitions | ForEach-Object { [string]$_.transition_id } | Sort-Object)
    $expectedTransitions = @($script:R18RequiredTransitionIds | Sort-Object)
    Assert-R18WorkOrderCondition -Condition (($transitionIds -join "|") -eq ($expectedTransitions -join "|")) -Message "R18 work-order state machine must contain exactly the required transition IDs."
}

function Assert-R18WorkOrderTransitionCatalog {
    param([Parameter(Mandatory = $true)][object]$Catalog)

    Assert-R18WorkOrderRequiredFields -Object $Catalog -FieldNames @("artifact_type", "contract_version", "catalog_id", "source_task", "source_milestone", "repository", "branch", "active_through_task", "transition_count", "required_transition_ids", "transitions", "unknown_transitions_fail_closed", "execution_block_transition", "foundation_close_transition", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 work-order transition catalog"
    Assert-R18WorkOrderCondition -Condition ([int]$Catalog.transition_count -eq @($script:R18RequiredTransitionIds).Count) -Message "R18 work-order transition catalog transition_count is invalid."
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Catalog.runtime_flags -Context "R18 work-order transition catalog"
    Assert-R18WorkOrderPositiveClaims -PositiveClaims $Catalog.positive_claims -Context "R18 work-order transition catalog"
}

function Assert-R18WorkOrderSeed {
    param(
        [Parameter(Mandatory = $true)][object]$Seed,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    Assert-R18WorkOrderRequiredFields -Object $Seed -FieldNames $script:R18RequiredWorkOrderFields -Context "R18 work-order seed packet"
    Assert-R18WorkOrderCondition -Condition ([string]$Seed.source_task -eq $script:R18SourceTask) -Message "$($Seed.work_order_id) source_task must be R18-008."
    Assert-R18WorkOrderKnownState -State ([string]$Seed.current_state) -Context "$($Seed.work_order_id) current_state"
    Assert-R18WorkOrderKnownState -State ([string]$Seed.previous_state) -Context "$($Seed.work_order_id) previous_state" -AllowNull
    foreach ($state in @($Seed.next_allowed_states)) {
        Assert-R18WorkOrderKnownState -State ([string]$state) -Context "$($Seed.work_order_id) next_allowed_states"
    }
    if ([string]::IsNullOrWhiteSpace([string]$Seed.intake_packet_ref)) {
        throw "$($Seed.work_order_id) missing intake packet ref."
    }
    $intakePath = Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$Seed.intake_packet_ref)
    if (-not (Test-Path -LiteralPath $intakePath -PathType Leaf)) {
        throw "$($Seed.work_order_id) intake packet ref '$($Seed.intake_packet_ref)' does not exist."
    }
    Assert-R18WorkOrderCondition -Condition (@($Seed.handoff_packet_refs).Count -gt 0) -Message "$($Seed.work_order_id) handoff refs must not be empty."
    Assert-R18WorkOrderAuthorityRefs -AuthorityRefs $Seed.authority_refs -Context "$($Seed.work_order_id)" -RepositoryRoot $RepositoryRoot
    if ($null -eq $Seed.permission_matrix_ref.PSObject.Properties["matrix_ref"] -or [string]::IsNullOrWhiteSpace([string]$Seed.permission_matrix_ref.matrix_ref)) {
        throw "$($Seed.work_order_id) missing permission matrix ref."
    }
    Assert-R18WorkOrderAllowedPaths -AllowedPaths $Seed.allowed_paths -Context "$($Seed.work_order_id)"
    Assert-R18WorkOrderForbiddenPaths -ForbiddenPaths $Seed.forbidden_paths -Context "$($Seed.work_order_id)"
    Assert-R18WorkOrderCondition -Condition (@($Seed.validation_expectations.checks).Count -gt 0) -Message "$($Seed.work_order_id) missing validation expectations."
    Assert-R18WorkOrderCondition -Condition (@($Seed.evidence_obligations).Count -gt 0) -Message "$($Seed.work_order_id) missing evidence obligations."
    Assert-R18WorkOrderCondition -Condition ([bool]$Seed.retry_failover_policy.unbounded_retry_allowed -eq $false -and [int]$Seed.retry_failover_policy.max_retry_count -ge 0 -and [int]$Seed.retry_failover_policy.max_retry_count -le 3) -Message "$($Seed.work_order_id) has unbounded retry."
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Seed.runtime_flags -Context "$($Seed.work_order_id)"
}

function Assert-R18WorkOrderTransitionEvaluation {
    param(
        [Parameter(Mandatory = $true)][object]$Transition,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    Assert-R18WorkOrderRequiredFields -Object $Transition -FieldNames $script:R18RequiredTransitionFields -Context "R18 work-order transition evaluation"
    Assert-R18WorkOrderKnownTransition -TransitionId ([string]$Transition.transition_id) -Context "$($Transition.transition_name)"
    Assert-R18WorkOrderCondition -Condition (@("transition_shape_validated", "transition_refused", "transition_failed") -contains [string]$Transition.transition_status) -Message "$($Transition.transition_id) transition_status is invalid."
    Assert-R18WorkOrderKnownState -State ([string]$Transition.from_state) -Context "$($Transition.transition_id) from_state"
    Assert-R18WorkOrderKnownState -State ([string]$Transition.to_state) -Context "$($Transition.transition_id) to_state"
    if ([string]::IsNullOrWhiteSpace([string]$Transition.work_order_ref)) {
        throw "$($Transition.transition_id) missing work_order_ref."
    }
    Assert-R18WorkOrderAuthorityRefs -AuthorityRefs $Transition.authority_check.authority_refs -Context "$($Transition.transition_id) authority refs" -RepositoryRoot $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace([string]$Transition.intake_check.intake_packet_ref)) {
        throw "$($Transition.transition_id) missing intake packet ref."
    }
    Assert-R18WorkOrderCondition -Condition (@($Transition.handoff_check.handoff_packet_refs).Count -gt 0) -Message "$($Transition.transition_id) missing handoff refs."
    if ($null -eq $Transition.permission_check.permission_matrix_ref.PSObject.Properties["matrix_ref"] -or [string]::IsNullOrWhiteSpace([string]$Transition.permission_check.permission_matrix_ref.matrix_ref)) {
        throw "$($Transition.transition_id) missing permission matrix ref."
    }
    Assert-R18WorkOrderCondition -Condition (@($Transition.validation_check.validation_expectations.checks).Count -gt 0) -Message "$($Transition.transition_id) missing validation expectations."
    Assert-R18WorkOrderCondition -Condition (@($Transition.evidence_check.evidence_obligations).Count -gt 0) -Message "$($Transition.transition_id) missing evidence obligations."
    foreach ($action in @($Transition.next_allowed_actions)) {
        $value = [string]$action
        if ([string]::IsNullOrWhiteSpace($value) -or $value -in @("*", "any", "unbounded") -or $value -match '(?i)unbounded') {
            throw "$($Transition.transition_id) has unbounded next action/state."
        }
    }
    Assert-R18WorkOrderCondition -Condition ([bool]$Transition.retry_check.unbounded_retry_allowed -eq $false -and [int]$Transition.retry_check.max_retry_count -ge 0 -and [int]$Transition.retry_check.max_retry_count -le 3) -Message "$($Transition.transition_id) has unbounded retry."
    Assert-R18WorkOrderAllowedPaths -AllowedPaths $Transition.path_check.allowed_paths -Context "$($Transition.transition_id)"
    Assert-R18WorkOrderForbiddenPaths -ForbiddenPaths $Transition.path_check.forbidden_paths -Context "$($Transition.transition_id)"
    foreach ($falseField in @("work_order_execution_performed", "runner_state_store_implemented", "resumable_execution_log_implemented", "local_runner_runtime_executed", "skill_execution_performed", "a2a_message_sent", "api_invocation_performed", "stage_commit_push_performed_by_state_machine", "board_runtime_mutation_performed", "product_runtime_executed")) {
        if ($null -ne $Transition.execution_block_check.PSObject.Properties[$falseField] -and [bool]$Transition.execution_block_check.PSObject.Properties[$falseField].Value -ne $false) {
            throw "$($Transition.transition_id) execution block check '$falseField' must be false."
        }
    }
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Transition.runtime_flags -Context "$($Transition.transition_id)"
}

function Assert-R18WorkOrderReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18WorkOrderRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_task", "source_milestone", "repository", "branch", "active_through_task", "required_state_count", "required_transition_count", "generated_seed_count", "generated_transition_evaluation_count", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 work-order state machine check report"
    Assert-R18WorkOrderCondition -Condition ([string]$Report.active_through_task -eq $script:R18SourceTask) -Message "R18 work-order state machine check report active_through_task must be R18-008."
    Assert-R18WorkOrderCondition -Condition ([string]$Report.aggregate_verdict -eq $script:R18Verdict) -Message "R18 work-order state machine check report aggregate verdict is invalid."
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 work-order state machine check report"
    Assert-R18WorkOrderPositiveClaims -PositiveClaims $Report.positive_claims -Context "R18 work-order state machine check report"
}

function Assert-R18WorkOrderSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18WorkOrderRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "snapshot_id", "source_task", "source_milestone", "active_through_task", "ui_boundary_label", "state_machine_status", "required_states", "required_transition_ids", "seed_work_order_ids", "transition_evaluation_ids", "execution_block_summary", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 work-order state machine snapshot"
    Assert-R18WorkOrderCondition -Condition ([string]$Snapshot.active_through_task -eq $script:R18SourceTask) -Message "R18 work-order state machine snapshot active_through_task must be R18-008."
    Assert-R18WorkOrderCondition -Condition ([string]$Snapshot.ui_boundary_label -match "foundation") -Message "R18 work-order state machine snapshot must preserve foundation-only boundary."
    Assert-R18WorkOrderRuntimeFlags -RuntimeFlags $Snapshot.runtime_summary -Context "R18 work-order state machine snapshot"
    Assert-R18WorkOrderPositiveClaims -PositiveClaims $Snapshot.positive_claims -Context "R18 work-order state machine snapshot"
}

function Get-R18WorkOrderTaskStatusMap {
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

function Test-R18WorkOrderStatusTruth {
    param([string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18WorkOrderPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-011 only",
            "R18-012 through R18-028 planned only",
            "R18-007 created local runner/CLI shell foundation only",
            "CLI shell is dry-run only",
            "CLI shell is not full work-order execution runtime",
            "R18-008 created work-order execution state machine foundation only",
            "Work-order state machine is not runtime execution",
            "R18-009 created runner state store and resumable execution log foundation only",
            "Runner state store is not live runner runtime",
            "Execution log is deterministic foundation evidence, not live execution evidence",
            "Resume checkpoint is not a continuation packet",
            "R18-010 created compact failure detector foundation only",
            "Failure detection is deterministic over seed signal artifacts only",
            "Failure events are not recovery completion",
            "R18-011 created WIP classifier foundation only",
            "WIP classification is deterministic over seed git inventory artifacts only",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No files were restored or deleted",
            "No staging, commit, or push was performed by the classifier",
            "Remote branch verifier runtime is not implemented",
            "Continuation packet generator is not implemented",
            "New-context prompt generator is not implemented",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No stage/commit/push was performed by the runner or state store",
            "No product runtime is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing current R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18WorkOrderTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18WorkOrderTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 11) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-011."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-011."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[2-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-011."
    }
    if ($combinedText -match '(?i)R18-01[2-9].{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-012 or later completion."
    }
}

function Test-R18WorkOrderStateMachineSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$StateMachine,
        [Parameter(Mandatory = $true)][object]$Catalog,
        [Parameter(Mandatory = $true)][object[]]$Seeds,
        [Parameter(Mandatory = $true)][object[]]$Transitions,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot)
    )

    Assert-R18WorkOrderContract -Contract $Contract -RepositoryRoot $RepositoryRoot
    Assert-R18WorkOrderStateMachine -StateMachine $StateMachine
    Assert-R18WorkOrderTransitionCatalog -Catalog $Catalog
    Assert-R18WorkOrderCondition -Condition (@($Seeds).Count -eq @($script:R18SeedFileMap.Keys).Count) -Message "R18 work-order state machine set is missing required seed work orders."
    foreach ($seed in @($Seeds)) {
        Assert-R18WorkOrderSeed -Seed $seed -RepositoryRoot $RepositoryRoot
    }
    foreach ($seedState in @($script:R18SeedFileMap.Keys)) {
        Assert-R18WorkOrderCondition -Condition (@($Seeds | Where-Object { $_.current_state -eq $seedState }).Count -eq 1) -Message "R18 work-order state machine set missing seed state '$seedState'."
    }
    Assert-R18WorkOrderCondition -Condition (@($Transitions).Count -eq @($script:R18TransitionFileDefinitions).Count) -Message "R18 work-order state machine set is missing transition evaluations."
    foreach ($transition in @($Transitions)) {
        Assert-R18WorkOrderTransitionEvaluation -Transition $transition -RepositoryRoot $RepositoryRoot
    }
    Assert-R18WorkOrderReport -Report $Report
    Assert-R18WorkOrderSnapshot -Snapshot $Snapshot
    Test-R18WorkOrderStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredStateCount = [int]$Report.required_state_count
        RequiredTransitionCount = [int]$Report.required_transition_count
        GeneratedSeedCount = [int]$Report.generated_seed_count
        GeneratedTransitionEvaluationCount = [int]$Report.generated_transition_evaluation_count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18WorkOrderStateMachine {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot))

    $paths = Get-R18WorkOrderPaths -RepositoryRoot $RepositoryRoot
    $seeds = @()
    foreach ($state in @($script:R18SeedFileMap.Keys)) {
        $seeds += Read-R18WorkOrderJson -Path (Get-R18WorkOrderSeedPath -RepositoryRoot $RepositoryRoot -State $state)
    }
    $transitions = @()
    foreach ($definition in $script:R18TransitionFileDefinitions) {
        $transitions += Read-R18WorkOrderJson -Path (Get-R18WorkOrderTransitionPath -RepositoryRoot $RepositoryRoot -FileName ([string]$definition.file))
    }

    return Test-R18WorkOrderStateMachineSet `
        -Contract (Read-R18WorkOrderJson -Path $paths.Contract) `
        -StateMachine (Read-R18WorkOrderJson -Path $paths.StateMachine) `
        -Catalog (Read-R18WorkOrderJson -Path $paths.TransitionCatalog) `
        -Seeds $seeds `
        -Transitions $transitions `
        -Report (Read-R18WorkOrderJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18WorkOrderJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18WorkOrderObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) {
            $current | Add-Member -NotePropertyName $part -NotePropertyValue ([pscustomobject]@{})
        }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -eq $current.PSObject.Properties[$leaf]) {
        $current | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R18WorkOrderObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) {
            return
        }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -ne $current.PSObject.Properties[$leaf]) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18WorkOrderMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18WorkOrderObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18WorkOrderObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

function New-R18WorkOrderStateMachineArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18WorkOrderRepositoryRoot))

    $paths = Get-R18WorkOrderPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18WorkOrderContract
    $stateMachine = New-R18WorkOrderStateMachine
    $catalog = New-R18WorkOrderTransitionCatalog
    $seeds = New-R18WorkOrderSeedPackets
    $transitions = New-R18WorkOrderTransitionEvaluations
    $report = New-R18WorkOrderCheckReport -Seeds $seeds -Transitions $transitions
    $snapshot = New-R18WorkOrderSnapshot -Seeds $seeds -Transitions $transitions

    Write-R18WorkOrderJson -Path $paths.Contract -Value $contract
    Write-R18WorkOrderJson -Path $paths.StateMachine -Value $stateMachine
    Write-R18WorkOrderJson -Path $paths.TransitionCatalog -Value $catalog
    foreach ($seed in @($seeds)) {
        Write-R18WorkOrderJson -Path (Get-R18WorkOrderSeedPath -RepositoryRoot $RepositoryRoot -State ([string]$seed.current_state)) -Value $seed
    }
    for ($index = 0; $index -lt @($script:R18TransitionFileDefinitions).Count; $index++) {
        $definition = $script:R18TransitionFileDefinitions[$index]
        Write-R18WorkOrderJson -Path (Get-R18WorkOrderTransitionPath -RepositoryRoot $RepositoryRoot -FileName ([string]$definition.file)) -Value $transitions[$index]
    }
    Write-R18WorkOrderJson -Path $paths.CheckReport -Value $report
    Write-R18WorkOrderJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = New-R18WorkOrderFixtureDefinitions
    Write-R18WorkOrderJson -Path $paths.FixtureManifest -Value (New-R18WorkOrderFixtureManifest -FixtureDefinitions $fixtureDefinitions)
    foreach ($definition in @($fixtureDefinitions)) {
        Write-R18WorkOrderJson -Path (Join-Path $paths.FixtureRoot $definition.file) -Value $definition.fixture
    }

    Write-R18WorkOrderJson -Path $paths.EvidenceIndex -Value (New-R18WorkOrderEvidenceIndex)
    Write-R18WorkOrderText -Path $paths.ProofReview -Value (New-R18WorkOrderProofReviewText)
    Write-R18WorkOrderText -Path $paths.ValidationManifest -Value (New-R18WorkOrderValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        StateMachine = $paths.StateMachine
        TransitionCatalog = $paths.TransitionCatalog
        SeedRoot = $paths.SeedRoot
        TransitionRoot = $paths.TransitionRoot
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredStateCount = @($script:R18RequiredStates).Count
        RequiredTransitionCount = @($script:R18RequiredTransitionIds).Count
        GeneratedSeedCount = @($seeds).Count
        GeneratedTransitionEvaluationCount = @($transitions).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

Export-ModuleMember -Function `
    Get-R18WorkOrderPaths, `
    New-R18WorkOrderStateMachineArtifacts, `
    Test-R18WorkOrderStateMachine, `
    Test-R18WorkOrderStateMachineSet, `
    Test-R18WorkOrderStatusTruth, `
    Invoke-R18WorkOrderMutation, `
    Copy-R18WorkOrderObject
