Set-StrictMode -Version Latest

$script:R18OptionalApiAdapterSourceTask = "R18-023"
$script:R18OptionalApiAdapterSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18OptionalApiAdapterRepository = "RodneyMuniz/AIOffice_V2"
$script:R18OptionalApiAdapterBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18OptionalApiAdapterVerdict = "generated_r18_023_optional_api_adapter_stub_foundation_only"
$script:R18OptionalApiAdapterBoundary = "R18 active through R18-023 only; R18-024 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18OptionalApiAdapterRuntimeFlagFields = @(
    "api_invocation_performed",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_runtime_implemented",
    "live_api_adapter_invoked",
    "adapter_runtime_invoked",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "tool_call_runtime_implemented",
    "ledger_runtime_implemented",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "work_order_execution_performed",
    "board_runtime_mutation_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "automatic_new_thread_creation_performed",
    "recovery_action_performed",
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
    "r18_024_completed"
)

function Get-R18OptionalApiAdapterStubRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18OptionalApiAdapterStubPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18OptionalApiAdapterStubPaths {
    param([string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/tools/r18_optional_api_adapter_stub.contract.json"
        Profile = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_optional_api_adapter_stub_profile.json"
        DryRunEvidencePacketShape = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json"
        BlockedLiveRequest = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_optional_api_adapter_stub_blocked_live_request.json"
        Results = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_optional_api_adapter_stub_results.json"
        CheckReport = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_optional_api_adapter_stub_check_report.json"
        Snapshot = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_optional_api_adapter_stub_snapshot.json"
        FixtureRoot = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_optional_api_adapter_stub"
        ProofRoot = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub"
        EvidenceIndex = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub/evidence_index.json"
        ProofReview = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub/proof_review.md"
        ValidationManifest = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub/validation_manifest.md"
    }
}

function New-R18OptionalApiAdapterStubRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18OptionalApiAdapterRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18OptionalApiAdapterStubRuntimeFlagNames {
    return $script:R18OptionalApiAdapterRuntimeFlagFields
}

function Get-R18OptionalApiAdapterStubPositiveClaims {
    return @(
        "r18_optional_api_adapter_stub_contract_created",
        "r18_optional_api_adapter_stub_profile_created",
        "r18_optional_api_adapter_stub_dry_run_evidence_packet_shape_created",
        "r18_optional_api_adapter_stub_blocked_live_request_created",
        "r18_optional_api_adapter_stub_results_created",
        "r18_optional_api_adapter_stub_validator_created",
        "r18_optional_api_adapter_stub_fixtures_created",
        "r18_optional_api_adapter_stub_proof_review_created"
    )
}

function Get-R18OptionalApiAdapterStubNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-023 only.",
        "R18-024 through R18-028 remain planned only.",
        "R18-023 created optional API adapter stub foundation only.",
        "Optional API adapter stub artifacts are disabled/dry-run only.",
        "No API invocation is claimed by a stub.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter runtime was implemented or invoked.",
        "API-backed automation remains disabled by default.",
        "Missing approval or budget blocks adapter operation.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No tool-call execution was performed.",
        "No live tool call was performed.",
        "No tool-call runtime was implemented.",
        "No ledger runtime was implemented.",
        "No adapter runtime was invoked.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No recovery action was performed.",
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

function Get-R18OptionalApiAdapterStubRejectedClaims {
    return @(
        "api_invocation",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_runtime",
        "live_api_adapter_invocation",
        "api_enabled_by_default",
        "live_mode_enabled_without_controls",
        "live_mode_enabled_without_operator_approval",
        "live_mode_enabled_without_budget",
        "live_mode_enabled_without_evidence_packet",
        "committed_secret_value",
        "raw_secret_logging",
        "credentials_loaded",
        "network_access_allowed",
        "unbounded_budget",
        "unbounded_tokens",
        "unbounded_timeout",
        "operator_approval_not_required",
        "live_agent_invocation",
        "live_skill_execution",
        "tool_call_execution",
        "live_tool_call",
        "tool_call_runtime",
        "ledger_runtime",
        "adapter_runtime_invocation",
        "work_order_execution",
        "board_card_runtime_mutation",
        "a2a_message_sent",
        "live_a2a_runtime",
        "automatic_new_thread_creation",
        "recovery_action",
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
        "r18_024_or_later_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18OptionalApiAdapterStubAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "contracts/security/r18_api_safety_controls.contract.json",
        "state/security/r18_api_disabled_profile.json",
        "state/security/r18_api_secrets_policy.json",
        "state/security/r18_api_budget_token_policy.json",
        "state/security/r18_api_timeout_policy.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_scope_matrix.json",
        "state/governance/r18_operator_approval_requests/api_enablement.request.json",
        "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json",
        "state/skills/r18_skill_registry.json",
        "state/skills/r18_skill_contracts/",
        "contracts/tools/r18_agent_tool_call_evidence.contract.json",
        "state/tools/r18_agent_tool_call_evidence_ledger_shape.json",
        "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
    )
}

function Get-R18OptionalApiAdapterStubEvidenceRefs {
    return @(
        "contracts/tools/r18_optional_api_adapter_stub.contract.json",
        "state/tools/r18_optional_api_adapter_stub_profile.json",
        "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json",
        "state/tools/r18_optional_api_adapter_stub_blocked_live_request.json",
        "state/tools/r18_optional_api_adapter_stub_results.json",
        "state/tools/r18_optional_api_adapter_stub_check_report.json",
        "state/ui/r18_operator_surface/r18_optional_api_adapter_stub_snapshot.json",
        "tools/R18OptionalApiAdapterStub.psm1",
        "tools/new_r18_optional_api_adapter_stub.ps1",
        "tools/validate_r18_optional_api_adapter_stub.ps1",
        "tests/test_r18_optional_api_adapter_stub.ps1",
        "tests/fixtures/r18_optional_api_adapter_stub/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub/"
    )
}

function New-R18OptionalApiAdapterStubStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_023_only"
        planned_from = "R18-024"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18OptionalApiAdapterBoundary
    }
}

function New-R18OptionalApiAdapterStubControlRefs {
    return [ordered]@{
        safety_controls_contract_ref = "contracts/security/r18_api_safety_controls.contract.json"
        disabled_api_profile_ref = "state/security/r18_api_disabled_profile.json"
        secrets_policy_ref = "state/security/r18_api_secrets_policy.json"
        budget_token_policy_ref = "state/security/r18_api_budget_token_policy.json"
        timeout_policy_ref = "state/security/r18_api_timeout_policy.json"
        operator_approval_scope_matrix_ref = "state/governance/r18_operator_approval_scope_matrix.json"
        api_enablement_request_ref = "state/governance/r18_operator_approval_requests/api_enablement.request.json"
        api_enablement_decision_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
        skill_registry_ref = "state/skills/r18_skill_registry.json"
        evidence_ledger_shape_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
    }
}

function New-R18OptionalApiAdapterStubBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18OptionalApiAdapterSourceTask
        source_milestone = $script:R18OptionalApiAdapterSourceMilestone
        repository = $script:R18OptionalApiAdapterRepository
        branch = $script:R18OptionalApiAdapterBranch
        status_boundary = New-R18OptionalApiAdapterStubStatusBoundary
        runtime_flags = New-R18OptionalApiAdapterStubRuntimeFlags
        positive_claims = Get-R18OptionalApiAdapterStubPositiveClaims
        non_claims = Get-R18OptionalApiAdapterStubNonClaims
        rejected_claims = Get-R18OptionalApiAdapterStubRejectedClaims
        authority_refs = Get-R18OptionalApiAdapterStubAuthorityRefs
        evidence_refs = Get-R18OptionalApiAdapterStubEvidenceRefs
    }
}

function New-R18OptionalApiAdapterStubContract {
    $contract = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_contract"
    $contract.contract_id = "r18_023_optional_api_adapter_stub_contract_v1"
    $contract.task_title = "Implement optional API adapter stub only after controls"
    $contract.purpose = "Add a disabled/dry-run API adapter stub only after safety controls exist."
    $contract.inputs = @(
        "R18-022 controls",
        "operator enablement model",
        "skill registry",
        "evidence ledger"
    )
    $contract.outputs = @(
        "Optional adapter stub",
        "dry-run evidence packet shape",
        "validator/tests"
    )
    $contract.dependency = [ordered]@{
        required_task = "R18-022"
        controls_must_exist_before_stub = $true
        live_runtime_dependency_satisfied = $false
    }
    $contract.control_refs = New-R18OptionalApiAdapterStubControlRefs
    $contract.adapter_stub_policy = [ordered]@{
        stub_defaults_disabled = $true
        default_mode = "disabled"
        allowed_modes = @("disabled", "dry_run")
        live_mode_supported_by_r18_023 = $false
        live_mode_enabled = $false
        dry_run_mode_allowed = $true
        api_credentials_loaded = $false
        network_access_allowed = $false
        live_mode_requires_explicit_controls_approval_budget_and_evidence = $true
        missing_approval_blocks_operation = $true
        missing_budget_blocks_operation = $true
        missing_evidence_packet_blocks_operation = $true
    }
    $contract.dry_run_evidence_packet_shape = [ordered]@{
        shape_ref = "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json"
        required_packet_fields = @(
            "packet_id",
            "adapter_profile_ref",
            "requested_mode",
            "effective_mode",
            "request_kind",
            "operator_approval_ref",
            "operator_approval_status",
            "budget_policy_ref",
            "budget_status",
            "token_policy_ref",
            "timeout_policy_ref",
            "secrets_policy_ref",
            "evidence_ledger_shape_ref",
            "control_refs",
            "evidence_refs",
            "runtime_flags",
            "non_claims"
        )
    }
    $contract.acceptance_criteria = @(
        "Stub defaults disabled.",
        "Live mode impossible without explicit controls, approval, budgets, and evidence packet requirements.",
        "Validator rejects live API mode without controls and approval.",
        "No API invocation is claimed by a stub."
    )
    $contract.failure_retry_behavior = [ordered]@{
        missing_approval = "blocks_adapter_operation"
        missing_budget = "blocks_adapter_operation"
        retry_execution_by_stub = "not_implemented"
        escalation_runtime_by_stub = "not_implemented"
    }
    return $contract
}

function New-R18OptionalApiAdapterStubProfile {
    $profile = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_profile"
    $profile.profile_id = "r18_023_optional_api_adapter_stub_profile_v1"
    $profile.profile_status = "disabled_dry_run_stub_only_not_api_runtime"
    $profile.control_refs = New-R18OptionalApiAdapterStubControlRefs
    $profile.adapter_stub = [ordered]@{
        adapter_id = "r18_023_optional_api_adapter_stub"
        default_mode = "disabled"
        allowed_modes = @("disabled", "dry_run")
        effective_mode = "disabled"
        live_mode_enabled = $false
        live_mode_supported_by_r18_023 = $false
        dry_run_supported = $true
        api_invocation_allowed = $false
        credentials_loaded = $false
        network_access_allowed = $false
        api_requests_allowed_when_disabled = 0
    }
    $profile.operator_enablement = [ordered]@{
        approval_scope = "api_enablement"
        approval_required = $true
        explicit_operator_decision_required = $true
        operator_decision_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
        approved = $false
        approval_inferred_from_narration = $false
        missing_approval_blocks_operation = $true
    }
    $profile.budget_gate = [ordered]@{
        budget_policy_ref = "state/security/r18_api_budget_token_policy.json"
        per_request_budget_required = $true
        per_task_budget_required = $true
        max_usd_when_disabled = 0
        nonzero_spend_allowed = $false
        missing_budget_blocks_operation = $true
        unbounded_budget_allowed = $false
    }
    $profile.evidence_gate = [ordered]@{
        evidence_ledger_shape_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        dry_run_evidence_packet_shape_ref = "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json"
        live_call_evidence_required_before_future_live_mode = $true
        missing_evidence_packet_blocks_operation = $true
        seeded_live_api_call_count = 0
    }
    $profile.failure_retry_behavior = [ordered]@{
        missing_approval = "blocked_no_api_invocation"
        missing_budget = "blocked_no_api_invocation"
        missing_evidence_packet = "blocked_no_api_invocation"
        retry_execution = "not_implemented"
    }
    return $profile
}

function New-R18OptionalApiAdapterStubDryRunEvidencePacketShape {
    $packet = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_dry_run_evidence_packet_shape"
    $packet.packet_shape_id = "r18_023_optional_api_adapter_stub_dry_run_evidence_packet_shape_v1"
    $packet.packet_status = "dry_run_shape_only_no_api_invocation"
    $packet.requested_mode = "dry_run"
    $packet.effective_mode = "disabled"
    $packet.control_refs = New-R18OptionalApiAdapterStubControlRefs
    $packet.required_packet_fields = @(
        "packet_id",
        "adapter_profile_ref",
        "requested_mode",
        "effective_mode",
        "request_kind",
        "operator_approval_ref",
        "operator_approval_status",
        "budget_policy_ref",
        "budget_status",
        "token_policy_ref",
        "timeout_policy_ref",
        "secrets_policy_ref",
        "evidence_ledger_shape_ref",
        "control_refs",
        "evidence_refs",
        "runtime_flags",
        "non_claims"
    )
    $packet.required_for_future_live_mode = [ordered]@{
        explicit_operator_approval = $true
        safety_controls = $true
        secrets_policy = $true
        finite_budget = $true
        finite_token_limit = $true
        finite_timeout = $true
        evidence_packet = $true
        live_call_ledger_record = $true
        all_required_before_live_mode = $true
    }
    $packet.sample_dry_run_packet = [ordered]@{
        packet_id = "r18_023_optional_api_adapter_stub_dry_run_sample"
        adapter_profile_ref = "state/tools/r18_optional_api_adapter_stub_profile.json"
        requested_mode = "dry_run"
        effective_mode = "disabled"
        request_kind = "deterministic_stub_shape_only"
        operator_approval_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
        operator_approval_status = "refused_policy_only_no_approval_granted"
        budget_policy_ref = "state/security/r18_api_budget_token_policy.json"
        budget_status = "disabled_zero_budget"
        token_policy_ref = "state/security/r18_api_budget_token_policy.json"
        timeout_policy_ref = "state/security/r18_api_timeout_policy.json"
        secrets_policy_ref = "state/security/r18_api_secrets_policy.json"
        evidence_ledger_shape_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        evidence_refs = @("state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json")
    }
    return $packet
}

function New-R18OptionalApiAdapterStubBlockedLiveRequest {
    $request = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_blocked_live_request"
    $request.blocked_request_id = "r18_023_optional_api_adapter_stub_live_mode_blocked_v1"
    $request.request_status = "blocked_policy_only_no_api_invocation"
    $request.requested_mode = "live"
    $request.effective_mode = "blocked"
    $request.request_outcome = "blocked_by_stub_policy_missing_approval_or_budget"
    $request.api_invocation_attempted = $false
    $request.api_invocation_performed = $false
    $request.control_refs = New-R18OptionalApiAdapterStubControlRefs
    $request.operator_approval = [ordered]@{
        approval_required = $true
        approval_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
        approved = $false
        refused = $true
        block_reason = "R18-016 seed decision refuses API enablement; R18-023 does not override it."
    }
    $request.budget_gate = [ordered]@{
        budget_policy_ref = "state/security/r18_api_budget_token_policy.json"
        max_usd_when_disabled = 0
        blocked = $true
        block_reason = "Disabled API profile and zero budget block live adapter operation."
    }
    $request.evidence_gate = [ordered]@{
        evidence_packet_shape_ref = "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json"
        evidence_ledger_shape_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        live_evidence_packet_present = $false
        blocked = $true
    }
    $request.failure_retry_behavior = [ordered]@{
        missing_approval_or_budget = "block_adapter_operation"
        retry_performed = $false
        escalation_performed = $false
    }
    return $request
}

function New-R18OptionalApiAdapterStubResults {
    $results = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_results"
    $results.results_id = "r18_023_optional_api_adapter_stub_results_v1"
    $results.aggregate_verdict = $script:R18OptionalApiAdapterVerdict
    $results.control_results = [ordered]@{
        r18_022_controls_refs_present = $true
        stub_defaults_disabled = $true
        dry_run_shape_created = $true
        live_mode_enabled = $false
        live_mode_supported_by_r18_023 = $false
        live_request_blocked_without_approval = $true
        missing_budget_blocks_operation = $true
        api_invocation_performed = $false
    }
    $results.generated_artifact_refs = Get-R18OptionalApiAdapterStubEvidenceRefs
    return $results
}

function New-R18OptionalApiAdapterStubCheckReport {
    $report = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_check_report"
    $report.check_report_id = "r18_023_optional_api_adapter_stub_check_report_v1"
    $report.aggregate_verdict = $script:R18OptionalApiAdapterVerdict
    $report.validation_summary = [ordered]@{
        contract_valid = $true
        profile_valid = $true
        dry_run_evidence_packet_shape_valid = $true
        blocked_live_request_valid = $true
        status_boundary_valid = $true
        runtime_flags_false = $true
        invalid_fixtures_reject_live_mode_without_controls_or_approval = $true
    }
    $report.validation_expectation = "Validator rejects live API mode without controls and approval."
    return $report
}

function New-R18OptionalApiAdapterStubSnapshot {
    $snapshot = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_operator_surface_snapshot"
    $snapshot.snapshot_id = "r18_023_optional_api_adapter_stub_snapshot_v1"
    $snapshot.r18_status = "active_through_r18_023_only"
    $snapshot.adapter_status = "disabled_dry_run_stub_only"
    $snapshot.api_status = "disabled_by_default"
    $snapshot.operator_summary = [ordered]@{
        title = "R18-023 Implement optional API adapter stub only after controls"
        completed_scope = "Disabled/dry-run optional API adapter stub foundation only."
        live_api_invocation = "not_performed"
        live_adapter_runtime = "not_implemented_or_invoked"
        blocked_reason = "Missing approval or budget blocks adapter operation."
    }
    $snapshot.visible_controls = @(
        "API disabled by default",
        "dry-run evidence packet shape exists",
        "live mode blocked without approval",
        "live mode blocked without budget",
        "no API invocation claimed"
    )
    return $snapshot
}

function New-R18OptionalApiAdapterStubEvidenceIndex {
    $index = New-R18OptionalApiAdapterStubBase -ArtifactType "r18_optional_api_adapter_stub_evidence_index"
    $index.evidence_index_id = "r18_023_optional_api_adapter_stub_evidence_index_v1"
    $index.aggregate_verdict = $script:R18OptionalApiAdapterVerdict
    $index.evidence_summary = "R18-023 evidence is a deterministic disabled/dry-run adapter stub package only."
    $index.validation_commands = @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_optional_api_adapter_stub.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_optional_api_adapter_stub.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_optional_api_adapter_stub.ps1"
    )
    $index.ci_gap_disclosure = "No CI replay was performed; evidence remains committed artifacts plus Codex-reported local validations."
    return $index
}

function Get-R18OptionalApiAdapterStubProofReviewLines {
    return @(
        "# R18-023 Optional API Adapter Stub Proof Review",
        "",
        "Task: R18-023 Implement optional API adapter stub only after controls",
        "",
        "Scope: disabled/dry-run optional API adapter stub foundation only.",
        "",
        "Current status truth after this task: R18 is active through R18-023 only, R18-024 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Evidence refs:",
        "- contracts/tools/r18_optional_api_adapter_stub.contract.json",
        "- state/tools/r18_optional_api_adapter_stub_profile.json",
        "- state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json",
        "- state/tools/r18_optional_api_adapter_stub_blocked_live_request.json",
        "- state/tools/r18_optional_api_adapter_stub_results.json",
        "- state/tools/r18_optional_api_adapter_stub_check_report.json",
        "- state/ui/r18_operator_surface/r18_optional_api_adapter_stub_snapshot.json",
        "- tools/R18OptionalApiAdapterStub.psm1",
        "- tools/new_r18_optional_api_adapter_stub.ps1",
        "- tools/validate_r18_optional_api_adapter_stub.ps1",
        "- tests/test_r18_optional_api_adapter_stub.ps1",
        "- tests/fixtures/r18_optional_api_adapter_stub/",
        "",
        "Non-claims: no API invocation, no Codex/OpenAI API invocation, no live API adapter runtime, no live agents, no live skills, no tool-call execution, no A2A messages, no work-order execution, no board/card runtime mutation, no recovery action, no release gate execution, no CI replay, no GitHub Actions workflow created or run, no product runtime, no no-manual-prompt-transfer success, and no solved Codex compaction or reliability."
    )
}

function Get-R18OptionalApiAdapterStubValidationManifestLines {
    return @(
        "# R18-023 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-023 only; R18-024 through R18-028 planned only.",
        "",
        "Focused commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_optional_api_adapter_stub.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_optional_api_adapter_stub.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_optional_api_adapter_stub.ps1",
        "",
        "This manifest records deterministic local validation expectations only. It is not CI replay."
    )
}

function Get-R18OptionalApiAdapterStubInvalidFixtures {
    return @(
        [ordered]@{ fixture_id = "invalid_live_mode_enabled"; target = "profile"; operation = "set"; path = "adapter_stub.live_mode_enabled"; value = $true; expected_failure_fragments = @("live mode") },
        [ordered]@{ fixture_id = "invalid_default_mode_live"; target = "profile"; operation = "set"; path = "adapter_stub.default_mode"; value = "live"; expected_failure_fragments = @("default mode") },
        [ordered]@{ fixture_id = "invalid_credentials_loaded"; target = "profile"; operation = "set"; path = "adapter_stub.credentials_loaded"; value = $true; expected_failure_fragments = @("Credentials") },
        [ordered]@{ fixture_id = "invalid_network_access_allowed"; target = "profile"; operation = "set"; path = "adapter_stub.network_access_allowed"; value = $true; expected_failure_fragments = @("Network") },
        [ordered]@{ fixture_id = "invalid_budget_nonzero_when_disabled"; target = "profile"; operation = "set"; path = "budget_gate.max_usd_when_disabled"; value = 1; expected_failure_fragments = @("Disabled budget") },
        [ordered]@{ fixture_id = "invalid_operator_approval_granted"; target = "profile"; operation = "set"; path = "operator_enablement.approved"; value = $true; expected_failure_fragments = @("Operator approval") },
        [ordered]@{ fixture_id = "invalid_missing_budget_policy_ref"; target = "profile"; operation = "remove"; path = "control_refs.budget_token_policy_ref"; expected_failure_fragments = @("budget_token_policy_ref") },
        [ordered]@{ fixture_id = "invalid_missing_dry_run_packet_fields"; target = "dry_run_evidence_packet_shape"; operation = "set"; path = "required_packet_fields"; value = @(); expected_failure_fragments = @("required_packet_fields") },
        [ordered]@{ fixture_id = "invalid_blocked_request_outcome_allows_live"; target = "blocked_live_request"; operation = "set"; path = "request_outcome"; value = "live_api_invocation_allowed"; expected_failure_fragments = @("blocked live") },
        [ordered]@{ fixture_id = "invalid_runtime_api_invocation_claim"; target = "blocked_live_request"; operation = "set"; path = "runtime_flags.openai_api_invoked"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_r18_024_completion_claim"; target = "contract"; operation = "set"; path = "runtime_flags.r18_024_completed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_operator_local_backup_ref"; target = "evidence_index"; operation = "set"; path = "evidence_refs"; value = @(".local_backups/r18-023.json"); expected_failure_fragments = @("operator-local backup") }
    )
}

function Write-R18OptionalApiAdapterStubJson {
    param(
        [Parameter(Mandatory = $true)][object]$Value,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R18OptionalApiAdapterStubText {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Lines -Encoding UTF8
}

function New-R18OptionalApiAdapterStubArtifacts {
    param([string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot))

    $paths = Get-R18OptionalApiAdapterStubPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18OptionalApiAdapterStubContract
    $profile = New-R18OptionalApiAdapterStubProfile
    $dryRunShape = New-R18OptionalApiAdapterStubDryRunEvidencePacketShape
    $blockedLiveRequest = New-R18OptionalApiAdapterStubBlockedLiveRequest
    $results = New-R18OptionalApiAdapterStubResults
    $report = New-R18OptionalApiAdapterStubCheckReport
    $snapshot = New-R18OptionalApiAdapterStubSnapshot
    $evidenceIndex = New-R18OptionalApiAdapterStubEvidenceIndex

    Write-R18OptionalApiAdapterStubJson -Value $contract -Path $paths.Contract
    Write-R18OptionalApiAdapterStubJson -Value $profile -Path $paths.Profile
    Write-R18OptionalApiAdapterStubJson -Value $dryRunShape -Path $paths.DryRunEvidencePacketShape
    Write-R18OptionalApiAdapterStubJson -Value $blockedLiveRequest -Path $paths.BlockedLiveRequest
    Write-R18OptionalApiAdapterStubJson -Value $results -Path $paths.Results
    Write-R18OptionalApiAdapterStubJson -Value $report -Path $paths.CheckReport
    Write-R18OptionalApiAdapterStubJson -Value $snapshot -Path $paths.Snapshot
    Write-R18OptionalApiAdapterStubJson -Value $evidenceIndex -Path $paths.EvidenceIndex
    Write-R18OptionalApiAdapterStubText -Lines (Get-R18OptionalApiAdapterStubProofReviewLines) -Path $paths.ProofReview
    Write-R18OptionalApiAdapterStubText -Lines (Get-R18OptionalApiAdapterStubValidationManifestLines) -Path $paths.ValidationManifest

    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    Write-R18OptionalApiAdapterStubJson -Value $dryRunShape -Path (Join-Path $paths.FixtureRoot "valid_dry_run_evidence_packet_shape.json")
    $fixtures = Get-R18OptionalApiAdapterStubInvalidFixtures
    foreach ($fixture in $fixtures) {
        Write-R18OptionalApiAdapterStubJson -Value $fixture -Path (Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id))
    }
    $manifest = [ordered]@{
        artifact_type = "r18_optional_api_adapter_stub_fixture_manifest"
        source_task = $script:R18OptionalApiAdapterSourceTask
        valid_fixture_refs = @("tests/fixtures/r18_optional_api_adapter_stub/valid_dry_run_evidence_packet_shape.json")
        invalid_fixture_refs = @($fixtures | ForEach-Object { "tests/fixtures/r18_optional_api_adapter_stub/{0}.json" -f $_.fixture_id })
        runtime_flags = New-R18OptionalApiAdapterStubRuntimeFlags
        non_claims = Get-R18OptionalApiAdapterStubNonClaims
    }
    Write-R18OptionalApiAdapterStubJson -Value $manifest -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json")

    return [pscustomobject]@{
        AggregateVerdict = $script:R18OptionalApiAdapterVerdict
        InvalidFixtureCount = @($fixtures).Count
        Paths = $paths
    }
}

function Read-R18OptionalApiAdapterStubJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot)
    )

    $resolvedPath = Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Assert-R18OptionalApiAdapterStubCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18OptionalApiAdapterStubProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18OptionalApiAdapterStubCondition -Condition ($Object.PSObject.Properties.Name -contains $Name) -Message "$Context missing required property '$Name'."
}

function Assert-R18OptionalApiAdapterStubNoUnsafeRefs {
    param(
        [Parameter(Mandatory = $true)][object]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($ref in @($Refs)) {
        $refText = [string]$ref
        Assert-R18OptionalApiAdapterStubCondition -Condition ($refText -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context contains operator-local backup ref: $refText"
        Assert-R18OptionalApiAdapterStubCondition -Condition ($refText -ne "governance/reports/AIOffice_V2_Revised_R17_Plan.md") -Message "$Context contains untracked revised R17 plan report ref."
        Assert-R18OptionalApiAdapterStubCondition -Condition ($refText -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context contains historical evidence edit ref: $refText"
    }
}

function Assert-R18OptionalApiAdapterStubRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flagName in Get-R18OptionalApiAdapterStubRuntimeFlagNames) {
        Assert-R18OptionalApiAdapterStubProperty -Object $RuntimeFlags -Name $flagName -Context "$Context runtime_flags"
        Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
    }
}

function Assert-R18OptionalApiAdapterStubCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($property in @("artifact_type", "contract_version", "source_task", "source_milestone", "status_boundary", "runtime_flags", "non_claims", "rejected_claims", "authority_refs", "evidence_refs")) {
        Assert-R18OptionalApiAdapterStubProperty -Object $Artifact -Name $property -Context $Context
    }
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Artifact.source_task -eq "R18-023") -Message "$Context source_task must be R18-023."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Artifact.source_milestone -eq $script:R18OptionalApiAdapterSourceMilestone) -Message "$Context source_milestone is invalid."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_023_only") -Message "$Context status_boundary must record active_through_r18_023_only."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Artifact.status_boundary.planned_from -eq "R18-024") -Message "$Context status_boundary planned_from must be R18-024."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Artifact.status_boundary.planned_through -eq "R18-028") -Message "$Context status_boundary planned_through must be R18-028."
    Assert-R18OptionalApiAdapterStubRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    Assert-R18OptionalApiAdapterStubNoUnsafeRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs"
    Assert-R18OptionalApiAdapterStubNoUnsafeRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs"

    foreach ($required in @(
            "R18 is active through R18-023 only.",
            "R18-024 through R18-028 remain planned only.",
            "R18-023 created optional API adapter stub foundation only.",
            "No API invocation is claimed by a stub.",
            "No Codex/OpenAI API invocation occurred.",
            "No live API adapter runtime was implemented or invoked.",
            "No no-manual-prompt-transfer success is claimed."
        )) {
        Assert-R18OptionalApiAdapterStubCondition -Condition (@($Artifact.non_claims) -contains $required) -Message "$Context missing non-claim: $required"
    }
}

function Assert-R18OptionalApiAdapterStubControlRefs {
    param(
        [Parameter(Mandatory = $true)]$ControlRefs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($property in @(
            "safety_controls_contract_ref",
            "disabled_api_profile_ref",
            "secrets_policy_ref",
            "budget_token_policy_ref",
            "timeout_policy_ref",
            "operator_approval_scope_matrix_ref",
            "api_enablement_decision_ref",
            "skill_registry_ref",
            "evidence_ledger_shape_ref"
        )) {
        Assert-R18OptionalApiAdapterStubProperty -Object $ControlRefs -Name $property -Context "$Context control_refs"
    }
    Assert-R18OptionalApiAdapterStubCondition -Condition ($ControlRefs.budget_token_policy_ref -eq "state/security/r18_api_budget_token_policy.json") -Message "$Context budget_token_policy_ref is invalid."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($ControlRefs.api_enablement_decision_ref -eq "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json") -Message "$Context API approval decision ref is invalid."
}

function Assert-R18OptionalApiAdapterStubContract {
    param([Parameter(Mandatory = $true)]$Contract)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Contract -Context "contract"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Contract.artifact_type -eq "r18_optional_api_adapter_stub_contract") -Message "Contract artifact_type is invalid."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Contract.task_title -eq "Implement optional API adapter stub only after controls") -Message "Contract task_title is invalid."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Contract.dependency.required_task -eq "R18-022") -Message "Contract dependency must be R18-022."
    Assert-R18OptionalApiAdapterStubControlRefs -ControlRefs $Contract.control_refs -Context "contract"
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Contract.adapter_stub_policy.stub_defaults_disabled -eq $true) -Message "Contract must require disabled default."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Contract.adapter_stub_policy.default_mode -eq "disabled") -Message "Contract default mode must be disabled."
    Assert-R18OptionalApiAdapterStubCondition -Condition (@($Contract.adapter_stub_policy.allowed_modes) -contains "dry_run" -and @($Contract.adapter_stub_policy.allowed_modes) -notcontains "live") -Message "Contract allowed modes must exclude live mode."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Contract.adapter_stub_policy.live_mode_supported_by_r18_023 -eq $false) -Message "Contract live mode must not be supported by R18-023."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Contract.adapter_stub_policy.missing_approval_blocks_operation -eq $true) -Message "Contract must block missing approval."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Contract.adapter_stub_policy.missing_budget_blocks_operation -eq $true) -Message "Contract must block missing budget."
}

function Assert-R18OptionalApiAdapterStubProfile {
    param([Parameter(Mandatory = $true)]$Profile)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Profile -Context "profile"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Profile.artifact_type -eq "r18_optional_api_adapter_stub_profile") -Message "Profile artifact_type is invalid."
    Assert-R18OptionalApiAdapterStubControlRefs -ControlRefs $Profile.control_refs -Context "profile"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Profile.adapter_stub.default_mode -eq "disabled") -Message "Profile default mode must be disabled."
    Assert-R18OptionalApiAdapterStubCondition -Condition (@($Profile.adapter_stub.allowed_modes) -notcontains "live") -Message "Profile live mode must not be an allowed mode."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.adapter_stub.live_mode_enabled -eq $false) -Message "Profile live mode must be disabled."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.adapter_stub.live_mode_supported_by_r18_023 -eq $false) -Message "Profile live mode must not be supported by R18-023."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.adapter_stub.credentials_loaded -eq $false) -Message "Credentials must not be loaded by the stub."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.adapter_stub.network_access_allowed -eq $false) -Message "Network access must not be allowed by the stub."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([int]$Profile.adapter_stub.api_requests_allowed_when_disabled -eq 0) -Message "Disabled stub must allow zero API requests."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.operator_enablement.approval_required -eq $true) -Message "Operator approval must be required."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.operator_enablement.approved -eq $false) -Message "Operator approval must not be granted by seed artifacts."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([decimal]$Profile.budget_gate.max_usd_when_disabled -eq 0) -Message "Disabled budget must remain zero."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Profile.budget_gate.missing_budget_blocks_operation -eq $true) -Message "Missing budget must block operation."
}

function Assert-R18OptionalApiAdapterStubDryRunEvidencePacketShape {
    param([Parameter(Mandatory = $true)]$Packet)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Packet -Context "dry-run evidence packet shape"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Packet.artifact_type -eq "r18_optional_api_adapter_stub_dry_run_evidence_packet_shape") -Message "Dry-run evidence packet artifact_type is invalid."
    Assert-R18OptionalApiAdapterStubControlRefs -ControlRefs $Packet.control_refs -Context "dry-run evidence packet shape"
    foreach ($required in @("operator_approval_ref", "budget_policy_ref", "token_policy_ref", "timeout_policy_ref", "secrets_policy_ref", "evidence_ledger_shape_ref", "runtime_flags", "non_claims")) {
        Assert-R18OptionalApiAdapterStubCondition -Condition (@($Packet.required_packet_fields) -contains $required) -Message "Dry-run required_packet_fields missing $required."
    }
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Packet.required_for_future_live_mode.all_required_before_live_mode -eq $true) -Message "Future live mode must require all controls."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Packet.sample_dry_run_packet.effective_mode -eq "disabled") -Message "Sample dry-run packet effective mode must be disabled."
}

function Assert-R18OptionalApiAdapterStubBlockedLiveRequest {
    param([Parameter(Mandatory = $true)]$Request)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Request -Context "blocked live request"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Request.artifact_type -eq "r18_optional_api_adapter_stub_blocked_live_request") -Message "Blocked live request artifact_type is invalid."
    Assert-R18OptionalApiAdapterStubControlRefs -ControlRefs $Request.control_refs -Context "blocked live request"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Request.requested_mode -eq "live") -Message "Blocked live request must model requested live mode."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Request.effective_mode -eq "blocked") -Message "Blocked live request effective mode must be blocked."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Request.request_outcome -eq "blocked_by_stub_policy_missing_approval_or_budget") -Message "Blocked live request outcome must remain blocked live."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Request.api_invocation_attempted -eq $false -and [bool]$Request.api_invocation_performed -eq $false) -Message "Blocked live request must not attempt or perform API invocation."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Request.operator_approval.approved -eq $false -and [bool]$Request.operator_approval.refused -eq $true) -Message "Blocked live request operator approval must be refused."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Request.budget_gate.blocked -eq $true -and [decimal]$Request.budget_gate.max_usd_when_disabled -eq 0) -Message "Blocked live request budget gate must block with zero budget."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Request.evidence_gate.live_evidence_packet_present -eq $false -and [bool]$Request.evidence_gate.blocked -eq $true) -Message "Blocked live request evidence gate must block."
}

function Assert-R18OptionalApiAdapterStubResults {
    param([Parameter(Mandatory = $true)]$Results)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Results -Context "results"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Results.aggregate_verdict -eq $script:R18OptionalApiAdapterVerdict) -Message "Results aggregate verdict is invalid."
    foreach ($field in @("r18_022_controls_refs_present", "stub_defaults_disabled", "dry_run_shape_created", "live_request_blocked_without_approval", "missing_budget_blocks_operation")) {
        Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Results.control_results.$field -eq $true) -Message "Results control '$field' must be true."
    }
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Results.control_results.live_mode_enabled -eq $false) -Message "Results must keep live mode disabled."
    Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Results.control_results.api_invocation_performed -eq $false) -Message "Results must not claim API invocation."
}

function Assert-R18OptionalApiAdapterStubCheckReport {
    param([Parameter(Mandatory = $true)]$Report)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Report -Context "check report"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Report.aggregate_verdict -eq $script:R18OptionalApiAdapterVerdict) -Message "Check report aggregate verdict is invalid."
    foreach ($field in @("contract_valid", "profile_valid", "dry_run_evidence_packet_shape_valid", "blocked_live_request_valid", "status_boundary_valid", "runtime_flags_false", "invalid_fixtures_reject_live_mode_without_controls_or_approval")) {
        Assert-R18OptionalApiAdapterStubCondition -Condition ([bool]$Report.validation_summary.$field -eq $true) -Message "Check report validation '$field' must be true."
    }
}

function Assert-R18OptionalApiAdapterStubSnapshot {
    param([Parameter(Mandatory = $true)]$Snapshot)

    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $Snapshot -Context "snapshot"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_023_only") -Message "Snapshot must record active_through_r18_023_only."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Snapshot.adapter_status -eq "disabled_dry_run_stub_only") -Message "Snapshot adapter status is invalid."
    Assert-R18OptionalApiAdapterStubCondition -Condition ($Snapshot.api_status -eq "disabled_by_default") -Message "Snapshot must record disabled API status."
}

function Get-R18OptionalApiAdapterStubTaskStatusMap {
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

function Test-R18OptionalApiAdapterStubStatusTruth {
    param([string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OptionalApiAdapterStubPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

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
            "Optional API adapter stub artifacts are disabled/dry-run only",
            "No API invocation is claimed by a stub",
            "No Codex/OpenAI API invocation occurred",
            "No live API adapter runtime was implemented or invoked",
            "API-backed automation remains disabled by default",
            "Missing approval or budget blocks adapter operation",
            "R18-022 created safety, secrets, budget, and token controls foundation only",
            "Controls are not API invocation",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "Recovery action was not performed",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved",
            "Main is not merged"
        )) {
        Assert-R18OptionalApiAdapterStubCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-023 truth: $required"
    }

    $authorityStatuses = Get-R18OptionalApiAdapterStubTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18OptionalApiAdapterStubTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18OptionalApiAdapterStubCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 25) {
            Assert-R18OptionalApiAdapterStubCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-025."
        }
        else {
            Assert-R18OptionalApiAdapterStubCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-025."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[6-8])') {
        throw "Status surface claims R18 beyond R18-025."
    }
    if ($combinedText -match '(?i)R18-(02[6-8])[^\.\r\n]{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-026 or later completion."
    }

    return [pscustomobject]@{
        R18DoneThrough = 25
        R18PlannedStart = 26
        R18PlannedThrough = 28
    }
}

function Test-R18OptionalApiAdapterStubSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object]$DryRunEvidencePacketShape,
        [Parameter(Mandatory = $true)][object]$BlockedLiveRequest,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [Parameter(Mandatory = $true)][object]$EvidenceIndex,
        [string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot),
        [switch]$SkipStatusTruth
    )

    Assert-R18OptionalApiAdapterStubContract -Contract $Contract
    Assert-R18OptionalApiAdapterStubProfile -Profile $Profile
    Assert-R18OptionalApiAdapterStubDryRunEvidencePacketShape -Packet $DryRunEvidencePacketShape
    Assert-R18OptionalApiAdapterStubBlockedLiveRequest -Request $BlockedLiveRequest
    Assert-R18OptionalApiAdapterStubResults -Results $Results
    Assert-R18OptionalApiAdapterStubCheckReport -Report $Report
    Assert-R18OptionalApiAdapterStubSnapshot -Snapshot $Snapshot
    Assert-R18OptionalApiAdapterStubCommonArtifact -Artifact $EvidenceIndex -Context "evidence index"
    Assert-R18OptionalApiAdapterStubCondition -Condition ($EvidenceIndex.aggregate_verdict -eq $script:R18OptionalApiAdapterVerdict) -Message "Evidence index aggregate verdict is invalid."
    Assert-R18OptionalApiAdapterStubNoUnsafeRefs -Refs $EvidenceIndex.validation_commands -Context "evidence index validation_commands"

    if (-not $SkipStatusTruth) {
        Test-R18OptionalApiAdapterStubStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:R18OptionalApiAdapterVerdict
        AdapterDefaultMode = $Profile.adapter_stub.default_mode
        LiveModeEnabled = [bool]$Profile.adapter_stub.live_mode_enabled
        RequestedLiveOutcome = $BlockedLiveRequest.request_outcome
        RuntimeFlags = $Profile.runtime_flags
    }
}

function Get-R18OptionalApiAdapterStubSet {
    param([string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot))

    return [pscustomobject]@{
        Contract = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "contracts/tools/r18_optional_api_adapter_stub.contract.json"
        Profile = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_optional_api_adapter_stub_profile.json"
        DryRunEvidencePacketShape = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_optional_api_adapter_stub_dry_run_evidence_packet_shape.json"
        BlockedLiveRequest = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_optional_api_adapter_stub_blocked_live_request.json"
        Results = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_optional_api_adapter_stub_results.json"
        Report = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_optional_api_adapter_stub_check_report.json"
        Snapshot = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_optional_api_adapter_stub_snapshot.json"
        EvidenceIndex = Read-R18OptionalApiAdapterStubJson -RepositoryRoot $RepositoryRoot -Path "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_023_optional_api_adapter_stub/evidence_index.json"
        Paths = Get-R18OptionalApiAdapterStubPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18OptionalApiAdapterStub {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18OptionalApiAdapterStubRepositoryRoot))

    $set = Get-R18OptionalApiAdapterStubSet -RepositoryRoot $RepositoryRoot
    return Test-R18OptionalApiAdapterStubSet `
        -Contract $set.Contract `
        -Profile $set.Profile `
        -DryRunEvidencePacketShape $set.DryRunEvidencePacketShape `
        -BlockedLiveRequest $set.BlockedLiveRequest `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RepositoryRoot $RepositoryRoot
}

function Copy-R18OptionalApiAdapterStubObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18OptionalApiAdapterStubMutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "contract" { return $Set.Contract }
        "profile" { return $Set.Profile }
        "dry_run_evidence_packet_shape" { return $Set.DryRunEvidencePacketShape }
        "blocked_live_request" { return $Set.BlockedLiveRequest }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Set-R18OptionalApiAdapterStubObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        $Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($current.PSObject.Properties.Name -notcontains $part) {
            $current | Add-Member -MemberType NoteProperty -Name $part -Value ([pscustomobject]@{})
        }
        $current = $current.$part
    }
    $leaf = $parts[-1]
    if ($current.PSObject.Properties.Name -contains $leaf) {
        $current.$leaf = $Value
    }
    else {
        $current | Add-Member -MemberType NoteProperty -Name $leaf -Value $Value
    }
}

function Remove-R18OptionalApiAdapterStubObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($current.PSObject.Properties.Name -notcontains $part) {
            return
        }
        $current = $current.$part
    }
    $leaf = $parts[-1]
    if ($current.PSObject.Properties.Name -contains $leaf) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18OptionalApiAdapterStubMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18OptionalApiAdapterStubObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18OptionalApiAdapterStubObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18OptionalApiAdapterStubPaths, `
    Get-R18OptionalApiAdapterStubRuntimeFlagNames, `
    New-R18OptionalApiAdapterStubRuntimeFlags, `
    New-R18OptionalApiAdapterStubArtifacts, `
    Test-R18OptionalApiAdapterStub, `
    Test-R18OptionalApiAdapterStubSet, `
    Test-R18OptionalApiAdapterStubStatusTruth, `
    Get-R18OptionalApiAdapterStubSet, `
    Get-R18OptionalApiAdapterStubMutationTarget, `
    Copy-R18OptionalApiAdapterStubObject, `
    Invoke-R18OptionalApiAdapterStubMutation
