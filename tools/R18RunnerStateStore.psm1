Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-009"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ExpectedHead = "13aab5c6725a1c440f6cab078c3bf4896234c7e3"
$script:R18ExpectedTree = "1acc0fd49c89ae7ac5c2a6e8e1023cf6a807d588"
$script:R18ExpectedRemoteHead = "13aab5c6725a1c440f6cab078c3bf4896234c7e3"
$script:R18RunnerStateVerdict = "generated_r18_runner_state_store_foundation_only"
$script:R18RunnerStateRef = "state/runtime/r18_runner_state.json"
$script:R18CheckpointRef = "state/runtime/r18_runner_resume_checkpoint.json"
$script:R18SeedWorkOrderRef = "state/runtime/r18_work_order_seed_packets/r18_008_seed_blocked_pending_future_execution.work_order.json"
$script:R18SeedWorkOrderId = "r18_008_seed_blocked_pending_future_execution_runtime"
$script:R18CurrentState = "blocked_pending_future_execution_runtime"
$script:R18PreviousState = "ready_for_handoff"
$script:R18LastCompletedStep = "R18-008 work-order state machine foundation validated"
$script:R18NextSafeStep = "R18-009 runner state store validation only; future execution remains blocked until later runtime tasks"

$script:R18KnownStates = @(
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

$script:R18RequiredStateFields = @(
    "artifact_type",
    "contract_version",
    "runner_state_id",
    "source_task",
    "source_milestone",
    "state_status",
    "current_work_order_ref",
    "current_work_order_id",
    "current_state",
    "previous_state",
    "last_completed_step",
    "next_safe_step",
    "next_allowed_states",
    "next_allowed_actions",
    "retry_count",
    "max_retry_count",
    "retry_limit_enforced",
    "git_identity",
    "branch_identity",
    "authority_refs",
    "intake_packet_ref",
    "handoff_packet_refs",
    "permission_matrix_ref",
    "state_machine_ref",
    "local_runner_cli_ref",
    "evidence_refs",
    "validation_refs",
    "stop_conditions",
    "escalation_conditions",
    "resume_checkpoint_ref",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredLogEntryFields = @(
    "artifact_type",
    "contract_version",
    "log_entry_id",
    "event_type",
    "source_task",
    "source_milestone",
    "event_status",
    "runner_state_ref",
    "work_order_ref",
    "work_order_state",
    "previous_state",
    "next_state",
    "last_completed_step",
    "next_safe_step",
    "retry_count",
    "git_identity_ref",
    "authority_refs",
    "evidence_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredCheckpointFields = @(
    "artifact_type",
    "contract_version",
    "checkpoint_id",
    "source_task",
    "checkpoint_status",
    "runner_state_ref",
    "current_work_order_ref",
    "last_completed_step",
    "next_safe_step",
    "retry_count",
    "max_retry_count",
    "evidence_refs",
    "validation_refs",
    "stop_conditions",
    "escalation_conditions",
    "continuation_packet_generated",
    "new_context_prompt_generated",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18AllowedEventTypes = @(
    "runner_state_store_initialized",
    "runner_state_loaded",
    "intake_ref_recorded",
    "work_order_ref_recorded",
    "transition_ref_recorded",
    "resume_checkpoint_created",
    "execution_block_recorded",
    "foundation_validation_recorded"
)

$script:R18RuntimeFlagFields = @(
    "work_order_execution_performed",
    "work_order_state_machine_runtime_executed",
    "runner_state_store_runtime_executed",
    "live_runner_runtime_executed",
    "compact_failure_detector_implemented",
    "wip_classifier_implemented",
    "remote_branch_verifier_runtime_implemented",
    "continuation_packet_generated",
    "new_context_prompt_generated",
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
    "r18_010_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_runner_state_store_contract_created",
    "r18_runner_state_store_profile_created",
    "r18_runner_state_created",
    "r18_runner_state_history_created",
    "r18_execution_log_created",
    "r18_resume_checkpoint_created",
    "r18_seed_events_created",
    "r18_runner_state_store_validator_created",
    "r18_runner_state_store_fixtures_created",
    "r18_runner_state_store_proof_review_created"
)

$script:R18RejectedClaims = @(
    "work_order_execution",
    "work_order_state_machine_runtime_execution",
    "runner_state_store_runtime_execution",
    "live_runner_runtime",
    "compact_failure_detector_implementation",
    "wip_classifier_implementation",
    "remote_branch_verifier_runtime",
    "continuation_packet_generation",
    "new_context_prompt_generation",
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
    "r18_010_or_later_completion",
    "main_merge",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "broad_repo_write",
    "unknown_state",
    "unknown_event_type",
    "unbounded_retry",
    "missing_resume_checkpoint"
)

$script:R18SeedEventDefinitions = @(
    [ordered]@{
        file = "seed_state_initialized.event.json"
        log_entry_id = "r18_009_seed_state_initialized_001"
        event_type = "runner_state_store_initialized"
        event_status = "state_store_seed_initialized_foundation_only"
    },
    [ordered]@{
        file = "seed_intake_validated.event.json"
        log_entry_id = "r18_009_seed_intake_validated_001"
        event_type = "intake_ref_recorded"
        event_status = "intake_ref_recorded_from_r18_008_seed_foundation_only"
    },
    [ordered]@{
        file = "seed_ready_for_handoff.event.json"
        log_entry_id = "r18_009_seed_ready_for_handoff_001"
        event_type = "transition_ref_recorded"
        event_status = "ready_for_handoff_ref_recorded_foundation_only"
    },
    [ordered]@{
        file = "seed_blocked_pending_future_execution.event.json"
        log_entry_id = "r18_009_seed_blocked_pending_future_execution_001"
        event_type = "execution_block_recorded"
        event_status = "future_execution_block_recorded_foundation_only"
    }
)

function Get-R18RunnerStateStoreRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18RunnerStateStorePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18RunnerJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R18RunnerJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSONL artifact '$Path' does not exist."
    }

    $entries = @()
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $Path) {
        $lineNumber += 1
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        try {
            $entries += ($line | ConvertFrom-Json)
        }
        catch {
            throw "Invalid JSONL entry at '$Path' line $lineNumber. $($_.Exception.Message)"
        }
    }
    if ($entries.Count -eq 0) {
        throw "JSONL artifact '$Path' does not contain any entries."
    }
    return $entries
}

function Write-R18RunnerJson {
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

function Write-R18RunnerJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Entries
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $lines = @($Entries | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Write-R18RunnerText {
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

function Copy-R18RunnerStateStoreObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18RunnerStateStorePaths {
    param([string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_runner_state_store.contract.json"
        Profile = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_runner_state_store_profile.json"
        State = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue $script:R18RunnerStateRef
        HistoryLog = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_runner_state_history.jsonl"
        ExecutionLog = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_execution_log.jsonl"
        Checkpoint = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue $script:R18CheckpointRef
        SeedEventRoot = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_runner_state_store_seed_events"
        CheckReport = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_runner_state_store_check_report.json"
        UiSnapshot = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_runner_state_store_snapshot.json"
        FixtureRoot = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_runner_state_store"
        ProofRoot = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store"
        EvidenceIndex = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/evidence_index.json"
        ProofReview = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/proof_review.md"
        ValidationManifest = Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/validation_manifest.md"
    }
}

function Get-R18RunnerRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18RunnerAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "state/runtime/r18_local_runner_cli_command_catalog.json",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_state_machine.json",
        "state/runtime/r18_work_order_transition_catalog.json",
        "state/runtime/r18_work_order_seed_packets/",
        "state/runtime/r18_work_order_transition_evaluations/",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_registry.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json"
    )
}

function Get-R18RunnerEvidenceRefs {
    return @(
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state_store_profile.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_state_history.jsonl",
        "state/runtime/r18_execution_log.jsonl",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "state/runtime/r18_runner_state_store_seed_events/",
        "state/runtime/r18_runner_state_store_check_report.json",
        "state/ui/r18_operator_surface/r18_runner_state_store_snapshot.json",
        "tools/R18RunnerStateStore.psm1",
        "tools/new_r18_runner_state_store.ps1",
        "tools/validate_r18_runner_state_store.ps1",
        "tests/test_r18_runner_state_store.ps1",
        "tests/fixtures/r18_runner_state_store/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/"
    )
}

function Get-R18RunnerValidationRefs {
    return @(
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

function Get-R18RunnerStopConditions {
    return @(
        "unsafe WIP",
        "missing authority refs",
        "stale branch identity",
        "missing evidence refs",
        "runtime execution requested",
        "API invocation requested",
        "R18-010+ overclaim"
    )
}

function Get-R18RunnerEscalationConditions {
    return @(
        "retry limit reached",
        "unsafe WIP detected by preflight or future classifier",
        "authority refs missing or contradictory",
        "branch identity stale or moved",
        "execution requested before future runtime task",
        "API invocation requested before controls",
        "status surface claims R18-010 or later"
    )
}

function Get-R18RunnerNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-009 only.",
        "R18-010 through R18-028 remain planned only.",
        "R18-009 created runner state store and resumable execution log foundation only.",
        "Runner state store is not live runner runtime.",
        "Execution log is deterministic foundation evidence, not live execution evidence.",
        "Resume checkpoint is not a continuation packet.",
        "Compact failure detector is not implemented.",
        "WIP classifier is not implemented.",
        "Remote branch verifier runtime is not implemented.",
        "Continuation packet generator is not implemented.",
        "New-context prompt generator is not implemented.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No stage/commit/push was performed by the runner or state store.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18RunnerGitIdentity {
    return [ordered]@{
        repository = $script:R18Repository
        branch = $script:R18Branch
        expected_head = $script:R18ExpectedHead
        expected_tree = $script:R18ExpectedTree
        expected_remote_head = $script:R18ExpectedRemoteHead
        identity_mode = "recorded_not_live_verified"
        remote_verification_runtime_implemented = $false
    }
}

function Get-R18RunnerBranchIdentity {
    return [ordered]@{
        repository = $script:R18Repository
        branch = $script:R18Branch
        expected_head = $script:R18ExpectedHead
        expected_tree = $script:R18ExpectedTree
        expected_remote_head = $script:R18ExpectedRemoteHead
        branch_identity_status = "recorded_from_required_preflight_not_live_verified_by_runtime"
        remote_verification_runtime_implemented = $false
    }
}

function New-R18RunnerContract {
    return [ordered]@{
        artifact_type = "r18_runner_state_store_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-009-runner-state-store-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "runner_state_store_and_resumable_execution_log_foundation_only_no_runtime_execution"
        purpose = "Persist deterministic runner state, JSONL history, execution log, and resume checkpoint artifacts so future continuation can inspect repo-backed state without depending on chat memory. This contract does not execute work orders, implement live runner runtime, detect compact failures, classify WIP, verify remote branches at runtime, generate continuation packets, generate new-context prompts, invoke APIs, invoke live agents or skills, send A2A messages, mutate board/card runtime state, or create new threads."
        required_state_fields = $script:R18RequiredStateFields
        required_log_entry_fields = $script:R18RequiredLogEntryFields
        required_checkpoint_fields = $script:R18RequiredCheckpointFields
        allowed_event_types = $script:R18AllowedEventTypes
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        state_store_policy = [ordered]@{
            deterministic_seed_state_required = $true
            current_work_order_ref_required = $true
            current_state_required = $true
            last_completed_step_required = $true
            next_safe_step_required = $true
            retry_count_required = $true
            bounded_retry_required = $true
            state_store_runtime_execution_allowed = $false
            stale_state_blocks_future_continuation = $true
        }
        execution_log_policy = [ordered]@{
            jsonl_required = $true
            log_entries_are_foundation_evidence_only = $true
            allowed_event_types = $script:R18AllowedEventTypes
            work_order_execution_evidence_allowed = $false
            live_runtime_evidence_allowed = $false
            fail_closed_on_unknown_event_type = $true
        }
        checkpoint_policy = [ordered]@{
            checkpoint_required = $true
            checkpoint_is_not_continuation_packet = $true
            continuation_packet_generation_allowed = $false
            new_context_prompt_generation_allowed = $false
            fail_closed_on_missing_checkpoint = $true
        }
        git_identity_policy = [ordered]@{
            git_identity_required = $true
            repository = $script:R18Repository
            branch = $script:R18Branch
            expected_head = $script:R18ExpectedHead
            expected_tree = $script:R18ExpectedTree
            expected_remote_head = $script:R18ExpectedRemoteHead
            identity_mode = "recorded_not_live_verified"
            remote_verification_runtime_implemented = $false
            remote_branch_verifier_runtime_implemented = $false
            stale_branch_identity_blocks_future_continuation = $true
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            approved_authority_refs = Get-R18RunnerAuthorityRefs
            missing_authority_refs_fail_closed = $true
        }
        work_order_policy = [ordered]@{
            seed_work_order_ref = $script:R18SeedWorkOrderRef
            seed_work_order_id = $script:R18SeedWorkOrderId
            required_current_state = $script:R18CurrentState
            work_order_execution_allowed = $false
            live_runner_runtime_allowed = $false
        }
        validation_policy = [ordered]@{
            validation_commands = Get-R18RunnerValidationRefs
            fail_closed_on_missing_fields = $true
            unknown_states_rejected = $true
            unknown_event_types_rejected = $true
            runtime_claims_rejected = $true
            status_boundary_required = "R18 active through R18-009 only; R18-010 through R18-028 planned only."
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            evidence_refs = Get-R18RunnerEvidenceRefs
            deterministic_seed_events_required = $true
            proof_review_package_required = $true
            historical_r13_r16_evidence_edits_allowed = $false
            operator_local_backup_paths_allowed = $false
        }
        retry_failure_policy = [ordered]@{
            retry_count = 0
            max_retry_count = 2
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
            failure_event_detection_implemented = $false
            operator_decision_required_at_retry_limit = $true
        }
        path_policy = [ordered]@{
            allowed_paths = @(
                "contracts/runtime/r18_runner_state_store.contract.json",
                "state/runtime/r18_runner_state_store_profile.json",
                "state/runtime/r18_runner_state.json",
                "state/runtime/r18_runner_state_history.jsonl",
                "state/runtime/r18_execution_log.jsonl",
                "state/runtime/r18_runner_resume_checkpoint.json",
                "state/runtime/r18_runner_state_store_seed_events/",
                "state/runtime/r18_runner_state_store_check_report.json",
                "state/ui/r18_operator_surface/r18_runner_state_store_snapshot.json",
                "tools/R18RunnerStateStore.psm1",
                "tools/new_r18_runner_state_store.ps1",
                "tools/validate_r18_runner_state_store.ps1",
                "tests/test_r18_runner_state_store.ps1",
                "tests/fixtures/r18_runner_state_store/",
                "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/",
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
                "tools/R18WorkOrderStateMachine.psm1",
                "tests/test_r18_agent_card_schema.ps1",
                "tests/test_r18_local_runner_cli.ps1",
                "tests/test_r18_work_order_state_machine.ps1"
            )
            forbidden_paths = @(
                ".local_backups/",
                "operator-local backup paths",
                "state/proof_reviews/r13_*",
                "state/proof_reviews/r14_*",
                "state/proof_reviews/r15_*",
                "state/proof_reviews/r16_*",
                "state/external_runs/",
                "main branch",
                "repository root broad write",
                "unbounded wildcard write paths"
            )
            broad_repo_writes_allowed = $false
            operator_local_backup_paths_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
            wildcard_paths_allowed = $false
        }
        api_policy = [ordered]@{
            api_enabled = $false
            openai_api_invocation_allowed = $false
            codex_api_invocation_allowed = $false
            autonomous_codex_invocation_allowed = $false
            automatic_new_thread_creation_allowed = $false
            api_controls_required_before_enablement = $true
        }
        execution_policy = [ordered]@{
            foundation_artifact_generation_only = $true
            work_order_execution_allowed = $false
            live_runner_runtime_allowed = $false
            skill_execution_allowed = $false
            a2a_dispatch_allowed = $false
            board_runtime_mutation_allowed = $false
            recovery_runtime_allowed = $false
            product_runtime_execution_allowed = $false
            stage_commit_push_allowed_by_state_store = $false
        }
        refusal_policy = [ordered]@{
            runtime_execution_requested_fails_closed = $true
            api_invocation_requested_fails_closed = $true
            r18_010_or_later_claim_fails_closed = $true
            unsafe_wip_blocks_future_continuation = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18RunnerNonClaims
        evidence_refs = Get-R18RunnerEvidenceRefs
        authority_refs = Get-R18RunnerAuthorityRefs
        runtime_flags = Get-R18RunnerRuntimeFlags
    }
}

function New-R18RunnerProfile {
    return [ordered]@{
        artifact_type = "r18_runner_state_store_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-009-runner-state-store-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        profile_status = "profile_foundation_only_not_runtime_execution"
        state_ref = $script:R18RunnerStateRef
        history_log_ref = "state/runtime/r18_runner_state_history.jsonl"
        execution_log_ref = "state/runtime/r18_execution_log.jsonl"
        resume_checkpoint_ref = $script:R18CheckpointRef
        seed_event_root = "state/runtime/r18_runner_state_store_seed_events/"
        allowed_event_types = $script:R18AllowedEventTypes
        required_state_fields = $script:R18RequiredStateFields
        required_log_entry_fields = $script:R18RequiredLogEntryFields
        required_checkpoint_fields = $script:R18RequiredCheckpointFields
        retry_policy = [ordered]@{
            retry_count = 0
            max_retry_count = 2
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
        }
        git_identity = Get-R18RunnerGitIdentity
        authority_refs = Get-R18RunnerAuthorityRefs
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
        runtime_flags = Get-R18RunnerRuntimeFlags
        positive_claims = @(
            "r18_runner_state_store_profile_created"
        )
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RunnerState {
    return [ordered]@{
        artifact_type = "r18_runner_state"
        contract_version = "v1"
        runner_state_id = "aioffice-r18-009-seed-runner-state-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        state_status = "state_store_foundation_only_not_runtime_execution"
        current_work_order_ref = $script:R18SeedWorkOrderRef
        current_work_order_id = $script:R18SeedWorkOrderId
        current_state = $script:R18CurrentState
        previous_state = $script:R18PreviousState
        last_completed_step = $script:R18LastCompletedStep
        next_safe_step = $script:R18NextSafeStep
        next_allowed_states = @(
            "blocked_pending_operator_decision",
            "validation_failed"
        )
        next_allowed_actions = @(
            "validate_runner_state_store_artifacts",
            "record_deterministic_log_foundation",
            "stop_if_runtime_execution_requested"
        )
        retry_count = 0
        max_retry_count = 2
        retry_limit_enforced = $true
        git_identity = Get-R18RunnerGitIdentity
        branch_identity = Get-R18RunnerBranchIdentity
        authority_refs = Get-R18RunnerAuthorityRefs
        intake_packet_ref = "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json"
        handoff_packet_refs = @(
            "state/a2a/r18_handoff_registry.json",
            "state/a2a/r18_handoff_packets/orchestrator_to_project_manager_define_work_order.handoff.json"
        )
        permission_matrix_ref = "state/skills/r18_role_skill_permission_matrix.json"
        state_machine_ref = "state/runtime/r18_work_order_state_machine.json"
        local_runner_cli_ref = "state/runtime/r18_local_runner_cli_profile.json"
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
        stop_conditions = Get-R18RunnerStopConditions
        escalation_conditions = Get-R18RunnerEscalationConditions
        resume_checkpoint_ref = $script:R18CheckpointRef
        runtime_flags = Get-R18RunnerRuntimeFlags
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RunnerCheckpoint {
    return [ordered]@{
        artifact_type = "r18_runner_resume_checkpoint"
        contract_version = "v1"
        checkpoint_id = "aioffice-r18-009-seed-resume-checkpoint-v1"
        source_task = $script:R18SourceTask
        checkpoint_status = "checkpoint_foundation_only_not_continuation_packet"
        runner_state_ref = $script:R18RunnerStateRef
        current_work_order_ref = $script:R18SeedWorkOrderRef
        last_completed_step = $script:R18LastCompletedStep
        next_safe_step = $script:R18NextSafeStep
        retry_count = 0
        max_retry_count = 2
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
        stop_conditions = Get-R18RunnerStopConditions
        escalation_conditions = Get-R18RunnerEscalationConditions
        continuation_packet_generated = $false
        new_context_prompt_generated = $false
        runtime_flags = Get-R18RunnerRuntimeFlags
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RunnerLogEntry {
    param(
        [Parameter(Mandatory = $true)][string]$LogEntryId,
        [Parameter(Mandatory = $true)][string]$EventType,
        [Parameter(Mandatory = $true)][string]$EventStatus
    )

    return [ordered]@{
        artifact_type = "r18_runner_execution_log_entry"
        contract_version = "v1"
        log_entry_id = $LogEntryId
        event_type = $EventType
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        event_status = $EventStatus
        runner_state_ref = $script:R18RunnerStateRef
        work_order_ref = $script:R18SeedWorkOrderRef
        work_order_state = $script:R18CurrentState
        previous_state = $script:R18PreviousState
        next_state = $script:R18CurrentState
        last_completed_step = $script:R18LastCompletedStep
        next_safe_step = $script:R18NextSafeStep
        retry_count = 0
        git_identity_ref = "state/runtime/r18_runner_state.json#/git_identity"
        authority_refs = Get-R18RunnerAuthorityRefs
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
        runtime_flags = Get-R18RunnerRuntimeFlags
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RunnerExecutionLogEntries {
    $entries = @()
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_runner_state_store_initialized_001" -EventType "runner_state_store_initialized" -EventStatus "runner_state_store_foundation_initialized"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_runner_state_loaded_001" -EventType "runner_state_loaded" -EventStatus "runner_state_seed_loaded_foundation_only"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_intake_ref_recorded_001" -EventType "intake_ref_recorded" -EventStatus "intake_ref_recorded_from_seed_work_order"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_work_order_ref_recorded_001" -EventType "work_order_ref_recorded" -EventStatus "r18_008_seed_work_order_ref_recorded"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_transition_ref_recorded_001" -EventType "transition_ref_recorded" -EventStatus "r18_008_transition_refs_recorded"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_resume_checkpoint_created_001" -EventType "resume_checkpoint_created" -EventStatus "resume_checkpoint_created_not_continuation_packet"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_execution_block_recorded_001" -EventType "execution_block_recorded" -EventStatus "future_execution_block_recorded"
    $entries += New-R18RunnerLogEntry -LogEntryId "r18_009_foundation_validation_recorded_001" -EventType "foundation_validation_recorded" -EventStatus "foundation_validation_recorded"
    return $entries
}

function New-R18RunnerSeedEvent {
    param([Parameter(Mandatory = $true)][hashtable]$Definition)

    $entry = New-R18RunnerLogEntry -LogEntryId ([string]$Definition.log_entry_id) -EventType ([string]$Definition.event_type) -EventStatus ([string]$Definition.event_status)
    $entry.artifact_type = "r18_runner_state_store_seed_event"
    return $entry
}

function New-R18RunnerCheckReport {
    return [ordered]@{
        artifact_type = "r18_runner_state_store_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-009-runner-state-store-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        aggregate_verdict = $script:R18RunnerStateVerdict
        required_state_field_count = @($script:R18RequiredStateFields).Count
        required_log_entry_field_count = @($script:R18RequiredLogEntryFields).Count
        required_checkpoint_field_count = @($script:R18RequiredCheckpointFields).Count
        allowed_event_type_count = @($script:R18AllowedEventTypes).Count
        generated_seed_event_count = @($script:R18SeedEventDefinitions).Count
        generated_execution_log_entry_count = @(New-R18RunnerExecutionLogEntries).Count
        generated_history_log_entry_count = @(New-R18RunnerExecutionLogEntries).Count
        checks = [ordered]@{
            contract_created = @{ status = "passed"; ref = "contracts/runtime/r18_runner_state_store.contract.json" }
            profile_created = @{ status = "passed"; ref = "state/runtime/r18_runner_state_store_profile.json" }
            state_created = @{ status = "passed"; ref = $script:R18RunnerStateRef }
            execution_log_created = @{ status = "passed"; ref = "state/runtime/r18_execution_log.jsonl" }
            history_log_created = @{ status = "passed"; ref = "state/runtime/r18_runner_state_history.jsonl" }
            checkpoint_created = @{ status = "passed"; ref = $script:R18CheckpointRef }
            runtime_false_flags_preserved = @{ status = "passed"; count = @($script:R18RuntimeFlagFields).Count }
            status_boundary = @{ status = "passed"; boundary = "R18 active through R18-009 only; R18-010 through R18-028 planned only." }
        }
        runtime_flags = Get-R18RunnerRuntimeFlags
        positive_claims = @(
            "r18_runner_state_store_contract_created",
            "r18_runner_state_store_profile_created",
            "r18_runner_state_created",
            "r18_runner_state_history_created",
            "r18_execution_log_created",
            "r18_resume_checkpoint_created",
            "r18_seed_events_created",
            "r18_runner_state_store_validator_created",
            "r18_runner_state_store_fixtures_created",
            "r18_runner_state_store_proof_review_created"
        )
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18RunnerEvidenceRefs
        authority_refs = Get-R18RunnerAuthorityRefs
        validation_refs = Get-R18RunnerValidationRefs
    }
}

function New-R18RunnerSnapshot {
    return [ordered]@{
        artifact_type = "r18_runner_state_store_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-009-runner-state-store-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        snapshot_status = "operator_surface_snapshot_state_only_not_live_ui"
        current_work_order_ref = $script:R18SeedWorkOrderRef
        current_state = $script:R18CurrentState
        previous_state = $script:R18PreviousState
        last_completed_step = $script:R18LastCompletedStep
        next_safe_step = $script:R18NextSafeStep
        retry_count = 0
        max_retry_count = 2
        resume_checkpoint_ref = $script:R18CheckpointRef
        execution_log_ref = "state/runtime/r18_execution_log.jsonl"
        runtime_summary = Get-R18RunnerRuntimeFlags
        positive_claims = @(
            "r18_runner_state_created",
            "r18_execution_log_created",
            "r18_resume_checkpoint_created"
        )
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
    }
}

function New-R18RunnerEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_runner_state_store_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18RunnerStateVerdict
        evidence_refs = Get-R18RunnerEvidenceRefs
        validation_refs = Get-R18RunnerValidationRefs
        runtime_flags = Get-R18RunnerRuntimeFlags
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RunnerProofReviewText {
    return @"
# R18-009 Runner State Store Proof Review

R18-009 creates the runner state store and resumable execution log foundation only. The committed artifacts record the R18-008 blocked seed work order, current state, previous state, last completed step, next safe step, bounded retry count, git identity as recorded-not-live-verified data, authority refs, evidence refs, validation refs, stop conditions, escalation conditions, deterministic JSONL log entries, and a resume checkpoint.

The resume checkpoint is not a continuation packet. The execution log is deterministic foundation evidence, not live execution evidence. No work orders were executed, no live runner runtime was implemented or executed, no compact failure detector, WIP classifier, remote verifier runtime, continuation packet generator, or new-context prompt generator was implemented, no A2A message was sent, no live agent or skill was invoked, no API was called, and no board/card runtime state was mutated.

Validation is anchored by `tools/validate_r18_runner_state_store.ps1`, `tests/test_r18_runner_state_store.ps1`, the prior R18 foundation validators, and the status-doc gate.
"@
}

function New-R18RunnerValidationManifestText {
    return @"
# R18-009 Validation Manifest

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_runner_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_runner_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_runner_state_store.ps1`
- Prior R18 validators and focused tests listed in the R18-009 task prompt.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

Expected status truth after this package: R18 active through R18-009 only; R18-010 through R18-028 planned only.
"@
}

function New-R18RunnerFixtureDefinitions {
    $fixtures = @(
        @{ file = "invalid_missing_runner_state_id.json"; target = "state"; operation = "remove"; path = "runner_state_id"; expected = "runner_state_id" },
        @{ file = "invalid_missing_current_work_order_ref.json"; target = "state"; operation = "remove"; path = "current_work_order_ref"; expected = "current_work_order_ref" },
        @{ file = "invalid_missing_current_state.json"; target = "state"; operation = "remove"; path = "current_state"; expected = "current_state" },
        @{ file = "invalid_unknown_state.json"; target = "state"; operation = "set"; path = "current_state"; value = "executing_live_work"; expected = "unknown state" },
        @{ file = "invalid_missing_last_completed_step.json"; target = "state"; operation = "remove"; path = "last_completed_step"; expected = "last_completed_step" },
        @{ file = "invalid_missing_next_safe_step.json"; target = "state"; operation = "remove"; path = "next_safe_step"; expected = "next_safe_step" },
        @{ file = "invalid_missing_retry_count.json"; target = "state"; operation = "remove"; path = "retry_count"; expected = "retry_count" },
        @{ file = "invalid_unbounded_retry.json"; target = "state"; operation = "set"; path = "max_retry_count"; value = 99; expected = "bounded retry" },
        @{ file = "invalid_missing_git_identity.json"; target = "state"; operation = "remove"; path = "git_identity"; expected = "git_identity" },
        @{ file = "invalid_wrong_branch_identity.json"; target = "state"; operation = "set"; path = "git_identity.branch"; value = "main"; expected = "branch" },
        @{ file = "invalid_missing_authority_refs.json"; target = "state"; operation = "remove"; path = "authority_refs"; expected = "authority_refs" },
        @{ file = "invalid_missing_evidence_refs.json"; target = "state"; operation = "remove"; path = "evidence_refs"; expected = "evidence_refs" },
        @{ file = "invalid_missing_validation_refs.json"; target = "state"; operation = "remove"; path = "validation_refs"; expected = "validation_refs" },
        @{ file = "invalid_missing_stop_conditions.json"; target = "state"; operation = "remove"; path = "stop_conditions"; expected = "stop_conditions" },
        @{ file = "invalid_missing_resume_checkpoint.json"; target = "state"; operation = "remove"; path = "resume_checkpoint_ref"; expected = "resume_checkpoint" },
        @{ file = "invalid_missing_execution_log_entry_id.json"; target = "execution_log:first"; operation = "remove"; path = "log_entry_id"; expected = "log_entry_id" },
        @{ file = "invalid_log_entry_without_state_ref.json"; target = "execution_log:first"; operation = "remove"; path = "runner_state_ref"; expected = "runner_state_ref" },
        @{ file = "invalid_log_entry_without_event_type.json"; target = "execution_log:first"; operation = "remove"; path = "event_type"; expected = "event_type" },
        @{ file = "invalid_log_entry_claims_work_order_execution.json"; target = "execution_log:first"; operation = "set"; path = "runtime_flags.work_order_execution_performed"; value = $true; expected = "work_order_execution_performed" },
        @{ file = "invalid_log_entry_claims_live_runner_runtime.json"; target = "execution_log:first"; operation = "set"; path = "runtime_flags.live_runner_runtime_executed"; value = $true; expected = "live_runner_runtime_executed" },
        @{ file = "invalid_compact_failure_detector_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.compact_failure_detector_implemented"; value = $true; expected = "compact_failure_detector_implemented" },
        @{ file = "invalid_wip_classifier_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.wip_classifier_implemented"; value = $true; expected = "wip_classifier_implemented" },
        @{ file = "invalid_remote_verifier_runtime_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.remote_branch_verifier_runtime_implemented"; value = $true; expected = "remote_branch_verifier_runtime_implemented" },
        @{ file = "invalid_continuation_packet_generation_claim.json"; target = "checkpoint"; operation = "set"; path = "continuation_packet_generated"; value = $true; expected = "continuation_packet_generated" },
        @{ file = "invalid_new_context_prompt_generation_claim.json"; target = "checkpoint"; operation = "set"; path = "new_context_prompt_generated"; value = $true; expected = "new_context_prompt_generated" },
        @{ file = "invalid_skill_execution_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.live_skill_execution_performed"; value = $true; expected = "live_skill_execution_performed" },
        @{ file = "invalid_a2a_message_sent_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.a2a_message_sent"; value = $true; expected = "a2a_message_sent" },
        @{ file = "invalid_board_runtime_mutation_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.board_runtime_mutation_performed"; value = $true; expected = "board_runtime_mutation_performed" },
        @{ file = "invalid_api_invocation_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.openai_api_invoked"; value = $true; expected = "openai_api_invoked" },
        @{ file = "invalid_automatic_new_thread_creation_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.automatic_new_thread_creation_performed"; value = $true; expected = "automatic_new_thread_creation_performed" },
        @{ file = "invalid_stage_commit_push_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.stage_commit_push_performed"; value = $true; expected = "stage_commit_push_performed" },
        @{ file = "invalid_operator_local_backup_path.json"; target = "state"; operation = "add_array_value"; path = "evidence_refs"; value = ".local_backups/r18_runner_state_store.json"; expected = "operator local backup" },
        @{ file = "invalid_historical_evidence_edit_permission.json"; target = "contract"; operation = "set"; path = "path_policy.historical_r13_r16_evidence_edits_allowed"; value = $true; expected = "historical" },
        @{ file = "invalid_broad_repo_write.json"; target = "contract"; operation = "set"; path = "path_policy.broad_repo_writes_allowed"; value = $true; expected = "broad repo" },
        @{ file = "invalid_r18_010_completion_claim.json"; target = "state"; operation = "set"; path = "runtime_flags.r18_010_completed"; value = $true; expected = "r18_010_completed" }
    )

    return @($fixtures | ForEach-Object {
            $fixtureValue = $null
            if ($_.ContainsKey("value")) {
                $fixtureValue = $_.value
            }
            [ordered]@{
                fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($_.file)
                target = $_.target
                operation = $_.operation
                path = $_.path
                value = $fixtureValue
                expected_failure_fragments = @($_.expected)
            }
        })
}

function New-R18RunnerFixtureManifest {
    $definitions = New-R18RunnerFixtureDefinitions
    return [ordered]@{
        artifact_type = "r18_runner_state_store_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        fixture_count = @($definitions).Count
        fixtures = @($definitions | ForEach-Object { "$($_.fixture_id).json" })
        runtime_flags = Get-R18RunnerRuntimeFlags
        non_claims = Get-R18RunnerNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Assert-R18RunnerCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18RunnerRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18RunnerCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing required field '$field'."
        $value = $Object.$field
        if ($null -eq $value) {
            throw "$Context required field '$field' is null."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context required field '$field' is empty."
        }
    }
}

function Assert-R18RunnerRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18RunnerCondition -Condition ($null -ne $RuntimeFlags) -Message "$Context runtime_flags missing."
    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18RunnerCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context runtime flag '$field' missing."
        Assert-R18RunnerCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Assert-R18RunnerPositiveClaims {
    param(
        [object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains "positive_claims") {
        return
    }

    foreach ($claim in @($Object.positive_claims)) {
        Assert-R18RunnerCondition -Condition (@($script:R18AllowedPositiveClaims) -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
    }
}

function Assert-R18RunnerRefsSafe {
    param(
        [object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($ref in @($Refs)) {
        $value = [string]$ref
        Assert-R18RunnerCondition -Condition (-not [string]::IsNullOrWhiteSpace($value)) -Message "$Context contains an empty ref."
        Assert-R18RunnerCondition -Condition ($value -notmatch '(^|/)\.local_backups(/|$)|operator-local') -Message "$Context contains operator local backup path '$value'."
        Assert-R18RunnerCondition -Condition ($value -notmatch '^state/proof_reviews/r1[3-6]_|^state/proof_reviews/r1[3-6]/|^governance/R1[3-6]_') -Message "$Context contains historical evidence edit path '$value'."
        Assert-R18RunnerCondition -Condition ($value -notin @(".", "./", "*", "**", "repository root broad write")) -Message "$Context contains broad repo write path '$value'."
    }
}

function Assert-R18RunnerPathPolicy {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18RunnerCondition -Condition ([bool]$Contract.path_policy.broad_repo_writes_allowed -eq $false) -Message "R18 runner state store path policy cannot allow broad repo writes."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.path_policy.operator_local_backup_paths_allowed -eq $false) -Message "R18 runner state store path policy cannot allow operator local backup paths."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.path_policy.historical_r13_r16_evidence_edits_allowed -eq $false) -Message "R18 runner state store path policy cannot allow historical R13/R14/R15/R16 evidence edits."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.path_policy.wildcard_paths_allowed -eq $false) -Message "R18 runner state store path policy cannot allow wildcard paths."
    Assert-R18RunnerRefsSafe -Refs @($Contract.path_policy.allowed_paths) -Context "R18 runner state store allowed paths"
}

function Assert-R18RunnerGitIdentity {
    param(
        [Parameter(Mandatory = $true)][object]$GitIdentity,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in @("repository", "branch", "expected_head", "expected_tree", "expected_remote_head", "identity_mode", "remote_verification_runtime_implemented")) {
        Assert-R18RunnerCondition -Condition ($GitIdentity.PSObject.Properties.Name -contains $field) -Message "$Context missing git identity field '$field'."
    }
    Assert-R18RunnerCondition -Condition ($GitIdentity.repository -eq $script:R18Repository) -Message "$Context git identity repository is invalid."
    Assert-R18RunnerCondition -Condition ($GitIdentity.branch -eq $script:R18Branch) -Message "$Context git identity branch is invalid."
    Assert-R18RunnerCondition -Condition ($GitIdentity.expected_head -eq $script:R18ExpectedHead) -Message "$Context git identity expected_head is invalid."
    Assert-R18RunnerCondition -Condition ($GitIdentity.expected_tree -eq $script:R18ExpectedTree) -Message "$Context git identity expected_tree is invalid."
    Assert-R18RunnerCondition -Condition ($GitIdentity.expected_remote_head -eq $script:R18ExpectedRemoteHead) -Message "$Context git identity expected_remote_head is invalid."
    Assert-R18RunnerCondition -Condition ($GitIdentity.identity_mode -eq "recorded_not_live_verified") -Message "$Context git identity mode must be recorded_not_live_verified."
    Assert-R18RunnerCondition -Condition ([bool]$GitIdentity.remote_verification_runtime_implemented -eq $false) -Message "$Context must not claim live remote verification runtime."
}

function Assert-R18RunnerContract {
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
        "required_state_fields",
        "required_log_entry_fields",
        "required_checkpoint_fields",
        "allowed_event_types",
        "required_runtime_false_flags",
        "state_store_policy",
        "execution_log_policy",
        "checkpoint_policy",
        "git_identity_policy",
        "authority_policy",
        "work_order_policy",
        "validation_policy",
        "evidence_policy",
        "retry_failure_policy",
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
    Assert-R18RunnerRequiredFields -Object $Contract -FieldNames $required -Context "R18 runner state store contract"
    Assert-R18RunnerCondition -Condition ($Contract.artifact_type -eq "r18_runner_state_store_contract") -Message "R18 runner state store contract artifact_type is invalid."
    Assert-R18RunnerCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 runner state store contract source_task must be R18-009."
    Assert-R18RunnerCondition -Condition ((@($Contract.required_state_fields) | Sort-Object) -join "|" -eq ((@($script:R18RequiredStateFields) | Sort-Object) -join "|")) -Message "R18 runner state store contract required_state_fields are invalid."
    Assert-R18RunnerCondition -Condition ((@($Contract.required_log_entry_fields) | Sort-Object) -join "|" -eq ((@($script:R18RequiredLogEntryFields) | Sort-Object) -join "|")) -Message "R18 runner state store contract required_log_entry_fields are invalid."
    Assert-R18RunnerCondition -Condition ((@($Contract.required_checkpoint_fields) | Sort-Object) -join "|" -eq ((@($script:R18RequiredCheckpointFields) | Sort-Object) -join "|")) -Message "R18 runner state store contract required_checkpoint_fields are invalid."
    Assert-R18RunnerCondition -Condition ((@($Contract.allowed_event_types) | Sort-Object) -join "|" -eq ((@($script:R18AllowedEventTypes) | Sort-Object) -join "|")) -Message "R18 runner state store contract allowed_event_types are invalid."
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18RunnerCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "R18 runner state store contract missing runtime false flag '$flag'."
    }
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 runner state store contract"
    Assert-R18RunnerPositiveClaims -Object $Contract -Context "R18 runner state store contract"
    Assert-R18RunnerGitIdentity -GitIdentity $Contract.git_identity_policy -Context "R18 runner state store contract"
    Assert-R18RunnerCondition -Condition ([bool]$Contract.api_policy.api_enabled -eq $false) -Message "R18 runner state store contract must not enable APIs."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.api_policy.openai_api_invocation_allowed -eq $false) -Message "R18 runner state store contract must not allow OpenAI API invocation."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.api_policy.codex_api_invocation_allowed -eq $false) -Message "R18 runner state store contract must not allow Codex API invocation."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.execution_policy.work_order_execution_allowed -eq $false) -Message "R18 runner state store contract must not allow work-order execution."
    Assert-R18RunnerCondition -Condition ([bool]$Contract.execution_policy.live_runner_runtime_allowed -eq $false) -Message "R18 runner state store contract must not allow live runner runtime."
    Assert-R18RunnerPathPolicy -Contract $Contract
}

function Assert-R18RunnerState {
    param(
        [Parameter(Mandatory = $true)][object]$State,
        [string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot)
    )

    Assert-R18RunnerRequiredFields -Object $State -FieldNames $script:R18RequiredStateFields -Context "R18 runner state"
    Assert-R18RunnerCondition -Condition ($State.artifact_type -eq "r18_runner_state") -Message "R18 runner state artifact_type is invalid."
    Assert-R18RunnerCondition -Condition ($State.source_task -eq $script:R18SourceTask) -Message "R18 runner state source_task must be R18-009."
    Assert-R18RunnerCondition -Condition ($State.state_status -eq "state_store_foundation_only_not_runtime_execution") -Message "R18 runner state status is invalid."
    Assert-R18RunnerCondition -Condition ($State.current_work_order_ref -eq $script:R18SeedWorkOrderRef) -Message "R18 runner state current_work_order_ref must reference the R18-008 blocked seed work order."
    Assert-R18RunnerCondition -Condition (Test-Path -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue $State.current_work_order_ref) -PathType Leaf) -Message "R18 runner state references an unknown work order."
    Assert-R18RunnerCondition -Condition ($State.current_work_order_id -eq $script:R18SeedWorkOrderId) -Message "R18 runner state current_work_order_id is invalid."
    Assert-R18RunnerCondition -Condition (@($script:R18KnownStates) -contains [string]$State.current_state) -Message "R18 runner state uses unknown state '$($State.current_state)'."
    Assert-R18RunnerCondition -Condition (@($script:R18KnownStates) -contains [string]$State.previous_state) -Message "R18 runner state uses unknown previous state '$($State.previous_state)'."
    Assert-R18RunnerCondition -Condition ($State.current_state -eq $script:R18CurrentState) -Message "R18 runner state current_state must be blocked_pending_future_execution_runtime."
    Assert-R18RunnerCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$State.last_completed_step)) -Message "R18 runner state missing last_completed_step."
    Assert-R18RunnerCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$State.next_safe_step)) -Message "R18 runner state missing next_safe_step."
    Assert-R18RunnerCondition -Condition ($State.PSObject.Properties.Name -contains "retry_count") -Message "R18 runner state missing retry_count."
    Assert-R18RunnerCondition -Condition ($State.PSObject.Properties.Name -contains "max_retry_count") -Message "R18 runner state missing max_retry_count."
    Assert-R18RunnerCondition -Condition ([int]$State.retry_count -ge 0 -and [int]$State.max_retry_count -le 3 -and [int]$State.max_retry_count -gt 0 -and [bool]$State.retry_limit_enforced -eq $true) -Message "R18 runner state retry must remain bounded retry."
    Assert-R18RunnerGitIdentity -GitIdentity $State.git_identity -Context "R18 runner state"
    Assert-R18RunnerCondition -Condition ($State.branch_identity.branch -eq $script:R18Branch) -Message "R18 runner state branch_identity branch is invalid."
    foreach ($arrayField in @("authority_refs", "evidence_refs", "validation_refs", "stop_conditions", "escalation_conditions", "next_allowed_states", "next_allowed_actions")) {
        Assert-R18RunnerCondition -Condition (@($State.$arrayField).Count -gt 0) -Message "R18 runner state missing $arrayField."
    }
    Assert-R18RunnerRefsSafe -Refs @($State.authority_refs) -Context "R18 runner state authority_refs"
    Assert-R18RunnerRefsSafe -Refs @($State.evidence_refs) -Context "R18 runner state evidence_refs"
    Assert-R18RunnerRefsSafe -Refs @($State.validation_refs) -Context "R18 runner state validation_refs"
    Assert-R18RunnerCondition -Condition ($State.resume_checkpoint_ref -eq $script:R18CheckpointRef) -Message "R18 runner state missing resume_checkpoint_ref."
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $State.runtime_flags -Context "R18 runner state"
    Assert-R18RunnerPositiveClaims -Object $State -Context "R18 runner state"
}

function Assert-R18RunnerCheckpoint {
    param([Parameter(Mandatory = $true)][object]$Checkpoint)

    Assert-R18RunnerRequiredFields -Object $Checkpoint -FieldNames $script:R18RequiredCheckpointFields -Context "R18 runner resume checkpoint"
    Assert-R18RunnerCondition -Condition ($Checkpoint.artifact_type -eq "r18_runner_resume_checkpoint") -Message "R18 runner resume checkpoint artifact_type is invalid."
    Assert-R18RunnerCondition -Condition ($Checkpoint.source_task -eq $script:R18SourceTask) -Message "R18 runner resume checkpoint source_task must be R18-009."
    Assert-R18RunnerCondition -Condition ($Checkpoint.checkpoint_status -eq "checkpoint_foundation_only_not_continuation_packet") -Message "R18 runner resume checkpoint status is invalid."
    Assert-R18RunnerCondition -Condition ($Checkpoint.runner_state_ref -eq $script:R18RunnerStateRef) -Message "R18 runner resume checkpoint runner_state_ref is invalid."
    Assert-R18RunnerCondition -Condition ([int]$Checkpoint.retry_count -ge 0 -and [int]$Checkpoint.max_retry_count -le 3 -and [int]$Checkpoint.max_retry_count -gt 0) -Message "R18 runner resume checkpoint retry must be bounded."
    Assert-R18RunnerCondition -Condition ([bool]$Checkpoint.continuation_packet_generated -eq $false) -Message "R18 runner resume checkpoint must not claim continuation_packet_generated."
    Assert-R18RunnerCondition -Condition ([bool]$Checkpoint.new_context_prompt_generated -eq $false) -Message "R18 runner resume checkpoint must not claim new_context_prompt_generated."
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Checkpoint.runtime_flags -Context "R18 runner resume checkpoint"
}

function Assert-R18RunnerLogEntry {
    param([Parameter(Mandatory = $true)][object]$Entry)

    Assert-R18RunnerRequiredFields -Object $Entry -FieldNames $script:R18RequiredLogEntryFields -Context "R18 runner execution log entry"
    Assert-R18RunnerCondition -Condition (@($script:R18AllowedEventTypes) -contains [string]$Entry.event_type) -Message "R18 runner execution log entry uses unknown event type '$($Entry.event_type)'."
    Assert-R18RunnerCondition -Condition ($Entry.source_task -eq $script:R18SourceTask) -Message "R18 runner execution log entry source_task must be R18-009."
    Assert-R18RunnerCondition -Condition ($Entry.runner_state_ref -eq $script:R18RunnerStateRef) -Message "R18 runner execution log entry runner_state_ref is invalid."
    Assert-R18RunnerCondition -Condition ($Entry.work_order_ref -eq $script:R18SeedWorkOrderRef) -Message "R18 runner execution log entry work_order_ref is invalid."
    Assert-R18RunnerCondition -Condition (@($script:R18KnownStates) -contains [string]$Entry.work_order_state) -Message "R18 runner execution log entry work_order_state is unknown."
    Assert-R18RunnerCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Entry.last_completed_step)) -Message "R18 runner execution log entry missing last_completed_step."
    Assert-R18RunnerCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Entry.next_safe_step)) -Message "R18 runner execution log entry missing next_safe_step."
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Entry.runtime_flags -Context "R18 runner execution log entry"
}

function Assert-R18RunnerReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18RunnerCondition -Condition ($Report.artifact_type -eq "r18_runner_state_store_check_report") -Message "R18 runner state store check report artifact_type is invalid."
    Assert-R18RunnerCondition -Condition ($Report.aggregate_verdict -eq $script:R18RunnerStateVerdict) -Message "R18 runner state store check report verdict is invalid."
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 runner state store check report"
    Assert-R18RunnerPositiveClaims -Object $Report -Context "R18 runner state store check report"
}

function Assert-R18RunnerSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18RunnerCondition -Condition ($Snapshot.artifact_type -eq "r18_runner_state_store_snapshot") -Message "R18 runner state store snapshot artifact_type is invalid."
    Assert-R18RunnerCondition -Condition ($Snapshot.current_state -eq $script:R18CurrentState) -Message "R18 runner state store snapshot current_state is invalid."
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Snapshot.runtime_summary -Context "R18 runner state store snapshot"
    Assert-R18RunnerPositiveClaims -Object $Snapshot -Context "R18 runner state store snapshot"
}

function Get-R18RunnerTaskStatusMap {
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

function Test-R18RunnerStateStoreStatusTruth {
    param([string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RunnerStateStorePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-014 only",
            "R18-015 through R18-028 planned only",
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
            "R18-012 created remote branch verifier foundation only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "Continuation packets are not new-context prompts",
            "R18-014 created new-context prompt generator foundation only",
            "Automatic new-thread creation is not implemented",
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
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18RunnerTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18RunnerTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18RunnerCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 14) {
            Assert-R18RunnerCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-014."
        }
        else {
            Assert-R18RunnerCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-014."
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[5-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-014."
    }
    if ($combinedText -match '(?i)R18-01[5-9].{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-015 or later completion."
    }
}

function Test-R18RunnerStateStoreSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object]$State,
        [Parameter(Mandatory = $true)][object[]]$HistoryEntries,
        [Parameter(Mandatory = $true)][object[]]$ExecutionEntries,
        [Parameter(Mandatory = $true)][object]$Checkpoint,
        [Parameter(Mandatory = $true)][object[]]$SeedEvents,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot)
    )

    Assert-R18RunnerContract -Contract $Contract
    Assert-R18RunnerRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 runner state store profile"
    Assert-R18RunnerPositiveClaims -Object $Profile -Context "R18 runner state store profile"
    Assert-R18RunnerState -State $State -RepositoryRoot $RepositoryRoot
    Assert-R18RunnerCheckpoint -Checkpoint $Checkpoint
    Assert-R18RunnerCondition -Condition (@($HistoryEntries).Count -gt 0) -Message "R18 runner state history log is missing required entries."
    Assert-R18RunnerCondition -Condition (@($ExecutionEntries).Count -gt 0) -Message "R18 execution log is missing required entries."
    foreach ($entry in @($HistoryEntries)) {
        Assert-R18RunnerLogEntry -Entry $entry
    }
    foreach ($entry in @($ExecutionEntries)) {
        Assert-R18RunnerLogEntry -Entry $entry
    }
    Assert-R18RunnerCondition -Condition (@($SeedEvents).Count -eq @($script:R18SeedEventDefinitions).Count) -Message "R18 runner seed events are missing required event artifacts."
    foreach ($event in @($SeedEvents)) {
        Assert-R18RunnerLogEntry -Entry $event
    }
    Assert-R18RunnerReport -Report $Report
    Assert-R18RunnerSnapshot -Snapshot $Snapshot
    Test-R18RunnerStateStoreStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredStateFieldCount = [int]$Report.required_state_field_count
        RequiredLogEntryFieldCount = [int]$Report.required_log_entry_field_count
        RequiredCheckpointFieldCount = [int]$Report.required_checkpoint_field_count
        GeneratedSeedEventCount = [int]$Report.generated_seed_event_count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18RunnerStateStore {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot))

    $paths = Get-R18RunnerStateStorePaths -RepositoryRoot $RepositoryRoot
    $seedEvents = @()
    foreach ($definition in $script:R18SeedEventDefinitions) {
        $seedEvents += Read-R18RunnerJson -Path (Join-Path $paths.SeedEventRoot ([string]$definition.file))
    }

    return Test-R18RunnerStateStoreSet `
        -Contract (Read-R18RunnerJson -Path $paths.Contract) `
        -Profile (Read-R18RunnerJson -Path $paths.Profile) `
        -State (Read-R18RunnerJson -Path $paths.State) `
        -HistoryEntries (Read-R18RunnerJsonLines -Path $paths.HistoryLog) `
        -ExecutionEntries (Read-R18RunnerJsonLines -Path $paths.ExecutionLog) `
        -Checkpoint (Read-R18RunnerJson -Path $paths.Checkpoint) `
        -SeedEvents $seedEvents `
        -Report (Read-R18RunnerJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18RunnerJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18RunnerObjectPathValue {
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

function Remove-R18RunnerObjectPathValue {
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

function Add-R18RunnerArrayValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        $Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        $cursor = $cursor.$segment
    }
    $leaf = $segments[-1]
    $cursor.$leaf = @($cursor.$leaf) + $Value
}

function Invoke-R18RunnerStateStoreMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18RunnerObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18RunnerObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        "add_array_value" { Add-R18RunnerArrayValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 runner state store mutation operation '$($Mutation.operation)'." }
    }
}

function New-R18RunnerStateStoreArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RunnerStateStoreRepositoryRoot))

    $paths = Get-R18RunnerStateStorePaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18RunnerContract
    $profile = New-R18RunnerProfile
    $state = New-R18RunnerState
    $checkpoint = New-R18RunnerCheckpoint
    $entries = New-R18RunnerExecutionLogEntries
    $report = New-R18RunnerCheckReport
    $snapshot = New-R18RunnerSnapshot

    Write-R18RunnerJson -Path $paths.Contract -Value $contract
    Write-R18RunnerJson -Path $paths.Profile -Value $profile
    Write-R18RunnerJson -Path $paths.State -Value $state
    Write-R18RunnerJsonLines -Path $paths.HistoryLog -Entries $entries
    Write-R18RunnerJsonLines -Path $paths.ExecutionLog -Entries $entries
    Write-R18RunnerJson -Path $paths.Checkpoint -Value $checkpoint
    foreach ($definition in $script:R18SeedEventDefinitions) {
        Write-R18RunnerJson -Path (Join-Path $paths.SeedEventRoot ([string]$definition.file)) -Value (New-R18RunnerSeedEvent -Definition $definition)
    }
    Write-R18RunnerJson -Path $paths.CheckReport -Value $report
    Write-R18RunnerJson -Path $paths.UiSnapshot -Value $snapshot

    Write-R18RunnerJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18RunnerFixtureManifest)
    foreach ($fixture in New-R18RunnerFixtureDefinitions) {
        Write-R18RunnerJson -Path (Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id)) -Value $fixture
    }

    Write-R18RunnerJson -Path $paths.EvidenceIndex -Value (New-R18RunnerEvidenceIndex)
    Write-R18RunnerText -Path $paths.ProofReview -Value (New-R18RunnerProofReviewText)
    Write-R18RunnerText -Path $paths.ValidationManifest -Value (New-R18RunnerValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Profile = $paths.Profile
        State = $paths.State
        HistoryLog = $paths.HistoryLog
        ExecutionLog = $paths.ExecutionLog
        Checkpoint = $paths.Checkpoint
        SeedEventRoot = $paths.SeedEventRoot
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredStateFieldCount = @($script:R18RequiredStateFields).Count
        RequiredLogEntryFieldCount = @($script:R18RequiredLogEntryFields).Count
        RequiredCheckpointFieldCount = @($script:R18RequiredCheckpointFields).Count
        GeneratedSeedEventCount = @($script:R18SeedEventDefinitions).Count
        GeneratedExecutionLogEntryCount = @($entries).Count
        AggregateVerdict = $script:R18RunnerStateVerdict
    }
}

Export-ModuleMember -Function `
    Get-R18RunnerStateStorePaths, `
    Read-R18RunnerJson, `
    Read-R18RunnerJsonLines, `
    Copy-R18RunnerStateStoreObject, `
    Test-R18RunnerStateStore, `
    Test-R18RunnerStateStoreSet, `
    Test-R18RunnerStateStoreStatusTruth, `
    Invoke-R18RunnerStateStoreMutation, `
    New-R18RunnerStateStoreArtifacts
