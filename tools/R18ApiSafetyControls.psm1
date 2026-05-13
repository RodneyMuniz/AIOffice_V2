Set-StrictMode -Version Latest

$script:R18ApiSafetySourceTask = "R18-022"
$script:R18ApiSafetySourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18ApiSafetyRepository = "RodneyMuniz/AIOffice_V2"
$script:R18ApiSafetyBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ApiSafetyVerdict = "generated_r18_022_api_safety_controls_foundation_only"
$script:R18ApiSafetyBoundary = "R18 active through R18-022 only; R18-023 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18ApiSafetyRuntimeFlagFields = @(
    "api_enabled",
    "api_invocation_performed",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_runtime_implemented",
    "live_api_adapter_invoked",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "tool_call_runtime_implemented",
    "ledger_runtime_implemented",
    "adapter_runtime_invoked",
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
    "r18_023_completed"
)

function Get-R18ApiSafetyControlsRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18ApiSafetyControlsPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18ApiSafetyControlsPaths {
    param([string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/security/r18_api_safety_controls.contract.json"
        DisabledProfile = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_disabled_profile.json"
        SecretsPolicy = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_secrets_policy.json"
        BudgetTokenPolicy = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_budget_token_policy.json"
        TimeoutPolicy = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_timeout_policy.json"
        Results = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_safety_controls_results.json"
        CheckReport = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/security/r18_api_safety_controls_check_report.json"
        Snapshot = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_api_safety_controls_snapshot.json"
        FixtureRoot = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_api_safety_controls"
        ProofRoot = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls"
        EvidenceIndex = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls/evidence_index.json"
        ProofReview = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls/proof_review.md"
        ValidationManifest = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls/validation_manifest.md"
    }
}

function New-R18ApiSafetyControlsRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18ApiSafetyRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18ApiSafetyControlsRuntimeFlagNames {
    return $script:R18ApiSafetyRuntimeFlagFields
}

function Get-R18ApiSafetyControlsPositiveClaims {
    return @(
        "r18_api_safety_controls_contract_created",
        "r18_api_disabled_profile_created",
        "r18_api_secrets_policy_created",
        "r18_api_budget_token_policy_created",
        "r18_api_timeout_policy_created",
        "r18_api_safety_controls_validator_created",
        "r18_api_safety_controls_fixtures_created",
        "r18_api_safety_controls_proof_review_created"
    )
}

function Get-R18ApiSafetyControlsNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-022 only.",
        "R18-023 through R18-028 remain planned only.",
        "R18-022 created safety, secrets, budget, token, timeout, disabled API profile, logging redaction, and operator-approval control foundation only.",
        "Controls are deterministic policy and validation artifacts only.",
        "Controls are not API invocation.",
        "API-backed automation remains disabled by default.",
        "No live API adapter runtime was implemented.",
        "No live API adapter was invoked.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
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

function Get-R18ApiSafetyControlsRejectedClaims {
    return @(
        "api_invocation",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_runtime",
        "live_api_adapter_invocation",
        "api_enabled_by_default",
        "committed_secret_value",
        "raw_secret_logging",
        "missing_budget_policy",
        "missing_token_policy",
        "missing_timeout_policy",
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
        "r18_023_or_later_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18ApiSafetyControlsAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_registry.json",
        "state/skills/r18_skill_contracts/",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_scope_matrix.json",
        "state/governance/r18_operator_approval_requests/api_enablement.request.json",
        "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "contracts/tools/r18_agent_tool_call_evidence.contract.json",
        "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
    )
}

function Get-R18ApiSafetyControlsEvidenceRefs {
    return @(
        "contracts/security/r18_api_safety_controls.contract.json",
        "state/security/r18_api_disabled_profile.json",
        "state/security/r18_api_secrets_policy.json",
        "state/security/r18_api_budget_token_policy.json",
        "state/security/r18_api_timeout_policy.json",
        "state/security/r18_api_safety_controls_results.json",
        "state/security/r18_api_safety_controls_check_report.json",
        "state/ui/r18_operator_surface/r18_api_safety_controls_snapshot.json",
        "tools/R18ApiSafetyControls.psm1",
        "tools/new_r18_api_safety_controls.ps1",
        "tools/validate_r18_api_safety_controls.ps1",
        "tests/test_r18_api_safety_controls.ps1",
        "tests/fixtures/r18_api_safety_controls/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls/"
    )
}

function Get-R18ApiSafetyControlsValidationRefs {
    return @(
        "tools/new_r18_api_safety_controls.ps1",
        "tools/validate_r18_api_safety_controls.ps1",
        "tests/test_r18_api_safety_controls.ps1",
        "tools/validate_r18_agent_tool_call_evidence.ps1",
        "tests/test_r18_agent_tool_call_evidence.ps1",
        "tools/validate_r18_operator_approval_gate.ps1",
        "tests/test_r18_operator_approval_gate.ps1",
        "tools/validate_r18_skill_contract_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18ApiSafetyControlsValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_api_safety_controls.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_api_safety_controls.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_api_safety_controls.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18ApiSafetyControlsStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_022_only"
        planned_from = "R18-023"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18ApiSafetyBoundary
    }
}

function Write-R18ApiSafetyControlsJson {
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

function Write-R18ApiSafetyControlsText {
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

function Read-R18ApiSafetyControlsJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot)
    )

    $resolvedPath = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required JSON artifact missing: $Path"
    }
    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Copy-R18ApiSafetyControlsObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function New-R18ApiSafetyControlsContract {
    return [ordered]@{
        artifact_type = "r18_api_safety_controls_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-022-api-safety-controls-contract-v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        repository = $script:R18ApiSafetyRepository
        branch = $script:R18ApiSafetyBranch
        purpose = "Create deterministic controls required before any API-backed automation is enabled; controls do not invoke APIs."
        required_inputs = [ordered]@{
            skill_registry_ref = "state/skills/r18_skill_registry.json"
            approval_gate_ref = "contracts/governance/r18_operator_approval_gate.contract.json"
            api_enablement_refusal_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
            runner_shell_profile_ref = "state/runtime/r18_local_runner_cli_profile.json"
            operator_policy_ref = "state/governance/r18_operator_approval_scope_matrix.json"
            agent_tool_evidence_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        }
        required_outputs = [ordered]@{
            secrets_policy_ref = "state/security/r18_api_secrets_policy.json"
            budget_token_policy_ref = "state/security/r18_api_budget_token_policy.json"
            timeout_policy_ref = "state/security/r18_api_timeout_policy.json"
            disabled_api_profile_ref = "state/security/r18_api_disabled_profile.json"
            validator_ref = "tools/validate_r18_api_safety_controls.ps1"
            focused_test_ref = "tests/test_r18_api_safety_controls.ps1"
            invalid_fixture_root = "tests/fixtures/r18_api_safety_controls/"
        }
        acceptance_controls = [ordered]@{
            api_disabled_by_default_required = $true
            secrets_never_committed_required = $true
            per_request_budget_required = $true
            per_task_budget_required = $true
            token_budget_required = $true
            per_request_timeout_required = $true
            per_task_timeout_required = $true
            logs_redact_secrets_required = $true
            operator_approval_required = $true
            missing_controls_block_api_adapter_work = $true
            controls_are_not_api_invocation = $true
        }
        validation_policy = [ordered]@{
            reject_api_enabled_default = $true
            reject_committed_secret_values = $true
            reject_raw_secret_logging = $true
            reject_missing_budget = $true
            reject_missing_token_budget = $true
            reject_unbounded_budget_or_tokens = $true
            reject_missing_timeout = $true
            reject_unbounded_timeout = $true
            reject_missing_operator_approval_requirement = $true
            reject_runtime_claims = $true
            reject_operator_local_backup_paths = $true
            reject_historical_r13_r16_evidence_edits = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiDisabledProfile {
    return [ordered]@{
        artifact_type = "r18_api_disabled_profile"
        contract_version = "v1"
        profile_id = "r18_022_api_disabled_profile_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        repository = $script:R18ApiSafetyRepository
        branch = $script:R18ApiSafetyBranch
        profile_status = "disabled_profile_only_not_api_runtime"
        default_mode = "api_disabled_policy_only"
        api_enabled = $false
        codex_api_enabled = $false
        openai_api_enabled = $false
        live_api_invocation_allowed_by_r18_022 = $false
        optional_adapter_stub_allowed_before_controls = $false
        enablement_requirements = [ordered]@{
            operator_approval_required = $true
            explicit_operator_decision_required = $true
            approval_scope = "api_enablement"
            seed_decision_ref = "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
            seed_decision_approved = $false
            secrets_policy_ref = "state/security/r18_api_secrets_policy.json"
            budget_token_policy_ref = "state/security/r18_api_budget_token_policy.json"
            timeout_policy_ref = "state/security/r18_api_timeout_policy.json"
            evidence_ledger_shape_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
            live_call_evidence_required = $true
        }
        adapter_work_policy = [ordered]@{
            missing_controls_block_api_adapter_work = $true
            r18_023_optional_adapter_stub_must_default_disabled = $true
            runtime_execution_allowed_by_profile = $false
            api_credentials_loaded_by_profile = $false
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiSecretsPolicy {
    return [ordered]@{
        artifact_type = "r18_api_secrets_policy"
        contract_version = "v1"
        policy_id = "r18_022_api_secrets_policy_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        policy_status = "deterministic_secrets_policy_only_not_secret_runtime"
        committed_secret_values_present = $false
        secret_values_committed_allowed = $false
        raw_secret_values_in_logs_allowed = $false
        allowed_secret_ref_kinds = @(
            "environment_variable_name_only",
            "external_secret_reference_name_only",
            "operator_provided_runtime_secret_not_committed"
        )
        forbidden_secret_material_policy = [ordered]@{
            plaintext_provider_keys_allowed = $false
            tokens_or_credentials_in_repo_allowed = $false
            local_env_files_allowed_as_evidence = $false
            redacted_placeholders_only = $true
            secret_scanning_required_before_future_api_enablement = $true
        }
        logging_redaction_policy = [ordered]@{
            redact_secret_values = $true
            redact_authorization_headers = $true
            redact_environment_variable_values = $true
            redaction_marker = "[REDACTED_SECRET]"
            raw_secret_logging_allowed = $false
            logs_must_record_secret_ref_names_only = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiBudgetTokenPolicy {
    return [ordered]@{
        artifact_type = "r18_api_budget_token_policy"
        contract_version = "v1"
        policy_id = "r18_022_api_budget_token_policy_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        policy_status = "deterministic_budget_token_policy_only_not_api_runtime"
        api_disabled_budget_policy = [ordered]@{
            disabled_mode_budget_usd = 0
            disabled_mode_input_tokens = 0
            disabled_mode_output_tokens = 0
            disabled_mode_api_requests = 0
            any_nonzero_spend_requires_future_operator_approval = $true
        }
        per_request_budget_usd = [ordered]@{
            limit_defined = $true
            max_usd_when_disabled = 0
            future_limit_must_be_finite = $true
            unbounded_budget_allowed = $false
            missing_budget_fails_closed = $true
        }
        per_task_budget_usd = [ordered]@{
            limit_defined = $true
            max_usd_when_disabled = 0
            future_limit_must_be_finite = $true
            unbounded_budget_allowed = $false
            missing_budget_fails_closed = $true
        }
        token_budget = [ordered]@{
            per_request_input_token_limit_defined = $true
            per_request_output_token_limit_defined = $true
            per_task_total_token_limit_defined = $true
            max_input_tokens_when_disabled = 0
            max_output_tokens_when_disabled = 0
            max_total_tokens_when_disabled = 0
            future_limits_must_be_finite = $true
            unbounded_tokens_allowed = $false
            missing_token_limits_fail_closed = $true
        }
        stop_controls = [ordered]@{
            stop_on_budget_missing = $true
            stop_on_budget_exceeded = $true
            stop_on_token_limit_missing = $true
            stop_on_token_limit_exceeded = $true
            dependent_api_adapter_work_blocked_if_controls_missing = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiTimeoutPolicy {
    return [ordered]@{
        artifact_type = "r18_api_timeout_policy"
        contract_version = "v1"
        policy_id = "r18_022_api_timeout_policy_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        policy_status = "deterministic_timeout_policy_only_not_api_runtime"
        timeout_policy = [ordered]@{
            per_request_timeout_limit_defined = $true
            per_task_timeout_limit_defined = $true
            max_request_seconds_when_disabled = 0
            max_task_seconds_when_disabled = 0
            future_request_timeout_seconds_must_be_finite = $true
            future_task_timeout_seconds_must_be_finite = $true
            unbounded_timeout_allowed = $false
            missing_timeout_fails_closed = $true
        }
        stop_controls = [ordered]@{
            stop_on_timeout_missing = $true
            stop_on_timeout_exceeded = $true
            stop_on_stream_disconnect_before_completion = $true
            stop_on_operator_revocation = $true
        }
        retry_boundary = [ordered]@{
            retry_execution_allowed_by_r18_022 = $false
            retry_policy_ref = "contracts/runtime/r18_retry_escalation_policy.contract.json"
            retries_require_future_runtime_authority = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiSafetyControlsResults {
    return [ordered]@{
        artifact_type = "r18_api_safety_controls_results"
        contract_version = "v1"
        results_id = "r18_022_api_safety_controls_results_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        result_status = "deterministic_control_results_only_not_api_runtime"
        aggregate_verdict = $script:R18ApiSafetyVerdict
        control_results = [ordered]@{
            api_disabled_by_default = $true
            secrets_never_committed = $true
            per_request_budget_exists = $true
            per_task_budget_exists = $true
            token_budget_exists = $true
            per_request_timeout_exists = $true
            per_task_timeout_exists = $true
            logs_redact_secrets = $true
            operator_approval_required = $true
            missing_controls_block_api_adapter_work = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiSafetyControlsCheckReport {
    return [ordered]@{
        artifact_type = "r18_api_safety_controls_check_report"
        contract_version = "v1"
        report_id = "r18_022_api_safety_controls_check_report_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        report_status = "deterministic_control_check_report_only_not_api_runtime"
        aggregate_verdict = $script:R18ApiSafetyVerdict
        validation_summary = [ordered]@{
            unsafe_secret_policy_rejected = $true
            unsafe_budget_policy_rejected = $true
            unsafe_token_policy_rejected = $true
            unsafe_timeout_policy_rejected = $true
            unsafe_logging_policy_rejected = $true
            missing_operator_approval_rejected = $true
            api_enabled_default_rejected = $true
            runtime_overclaim_rejected = $true
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        validation_refs = Get-R18ApiSafetyControlsValidationRefs
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiSafetyControlsSnapshot {
    return [ordered]@{
        artifact_type = "r18_api_safety_controls_operator_surface_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_022_api_safety_controls_snapshot_v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        snapshot_status = "read_only_operator_surface_snapshot_not_runtime"
        r18_status = "active_through_r18_022_only"
        planned_from = "R18-023"
        planned_through = "R18-028"
        api_status = "disabled_by_default"
        summary = "R18-022 controls exist as deterministic policy/validation artifacts only; no API invocation or live adapter runtime occurred."
        control_summary = [ordered]@{
            secrets_policy = "present_no_committed_secret_values"
            budget_token_policy = "present_zero_spend_zero_token_disabled_profile"
            timeout_policy = "present_fail_closed_when_missing_or_unbounded"
            logging_policy = "present_redacts_secret_values"
            operator_approval = "required_seed_api_enablement_refusal_preserved"
        }
        status_boundary = New-R18ApiSafetyControlsStatusBoundary
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        positive_claims = Get-R18ApiSafetyControlsPositiveClaims
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
    }
}

function New-R18ApiSafetyControlsProofArtifacts {
    $evidenceIndex = [ordered]@{
        artifact_type = "r18_api_safety_controls_evidence_index"
        contract_version = "v1"
        source_task = $script:R18ApiSafetySourceTask
        source_milestone = $script:R18ApiSafetySourceMilestone
        evidence_status = "deterministic_controls_evidence_index_only_not_runtime"
        evidence_refs = Get-R18ApiSafetyControlsEvidenceRefs
        authority_refs = Get-R18ApiSafetyControlsAuthorityRefs
        validation_refs = Get-R18ApiSafetyControlsValidationRefs
        runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
        non_claims = Get-R18ApiSafetyControlsNonClaims
        rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
    }

    $proofReview = @(
        "# R18-022 Safety, Secrets, Budget, and Token Controls Proof Review",
        "",
        "Scope: deterministic controls required before any API-backed automation is enabled.",
        "",
        "Current status truth after this task: R18 is active through R18-022 only, R18-023 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Positive proof created: API safety controls contract, disabled API profile, secrets policy, budget/token policy, timeout policy, results, check report, read-only operator snapshot, validator, focused tests, invalid fixtures, and this proof-review package.",
        "",
        "R18-021 dependency posture: R18-021 defined live-approved ledger shape only. R18-022 supplies deterministic control/policy/validation refs only and does not perform live calls.",
        "",
        "Non-claims: controls are not API invocation; no Codex/OpenAI API invocation occurred; no live adapter runtime, agent invocation, skill execution, tool-call execution, A2A message, work-order execution, board/card runtime mutation, recovery action, release gate execution, CI replay, GitHub Actions workflow, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, main merge, audit acceptance, or R18 closeout is claimed."
    )

    $validationManifest = @(
        "# R18-022 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-022 only; R18-023 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_api_safety_controls.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_api_safety_controls.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_api_safety_controls.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_agent_tool_call_evidence.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_agent_tool_call_evidence.ps1",
        "- git diff --check",
        "",
        "Validation is deterministic controls validation only; it is not API invocation, CI replay, release gate execution, or live runtime execution."
    )

    return [pscustomobject]@{
        EvidenceIndex = $evidenceIndex
        ProofReview = $proofReview
        ValidationManifest = $validationManifest
    }
}

function New-R18ApiSafetyControlsFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [string[]]$ExpectedFailureFragments = @()
    )

    $fixture = [ordered]@{
        artifact_type = "r18_api_safety_controls_invalid_fixture"
        contract_version = "v1"
        source_task = $script:R18ApiSafetySourceTask
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

function New-R18ApiSafetyControlsFixtures {
    return @(
        (New-R18ApiSafetyControlsFixture -File "invalid_api_enabled_default.json" -Target "disabled_profile" -Operation "set" -Path "api_enabled" -Value $true -ExpectedFailureFragments @("API disabled profile must keep api_enabled false")),
        (New-R18ApiSafetyControlsFixture -File "invalid_codex_api_enabled.json" -Target "disabled_profile" -Operation "set" -Path "codex_api_enabled" -Value $true -ExpectedFailureFragments @("Codex API must remain disabled")),
        (New-R18ApiSafetyControlsFixture -File "invalid_committed_secret_value.json" -Target "secrets_policy" -Operation "set" -Path "committed_secret_values_present" -Value $true -ExpectedFailureFragments @("Secrets policy must record no committed secret values")),
        (New-R18ApiSafetyControlsFixture -File "invalid_raw_secret_logging.json" -Target "secrets_policy" -Operation "set" -Path "logging_redaction_policy.raw_secret_logging_allowed" -Value $true -ExpectedFailureFragments @("Raw secret logging must be disabled")),
        (New-R18ApiSafetyControlsFixture -File "invalid_missing_request_budget.json" -Target "budget_token_policy" -Operation "set" -Path "per_request_budget_usd.limit_defined" -Value $false -ExpectedFailureFragments @("Per-request budget limit must be defined")),
        (New-R18ApiSafetyControlsFixture -File "invalid_unbounded_tokens.json" -Target "budget_token_policy" -Operation "set" -Path "token_budget.unbounded_tokens_allowed" -Value $true -ExpectedFailureFragments @("Unbounded token budgets are not allowed")),
        (New-R18ApiSafetyControlsFixture -File "invalid_unbounded_timeout.json" -Target "timeout_policy" -Operation "set" -Path "timeout_policy.unbounded_timeout_allowed" -Value $true -ExpectedFailureFragments @("Unbounded timeouts are not allowed")),
        (New-R18ApiSafetyControlsFixture -File "invalid_operator_approval_not_required.json" -Target "disabled_profile" -Operation "set" -Path "enablement_requirements.operator_approval_required" -Value $false -ExpectedFailureFragments @("Operator approval is required before API enablement")),
        (New-R18ApiSafetyControlsFixture -File "invalid_runtime_api_invocation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -ExpectedFailureFragments @("runtime flag 'codex_api_invoked' must remain false"))
    )
}

function New-R18ApiSafetyControlsArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot))

    $paths = Get-R18ApiSafetyControlsPaths -RepositoryRoot $RepositoryRoot

    Write-R18ApiSafetyControlsJson -Path $paths.Contract -Value (New-R18ApiSafetyControlsContract)
    Write-R18ApiSafetyControlsJson -Path $paths.DisabledProfile -Value (New-R18ApiDisabledProfile)
    Write-R18ApiSafetyControlsJson -Path $paths.SecretsPolicy -Value (New-R18ApiSecretsPolicy)
    Write-R18ApiSafetyControlsJson -Path $paths.BudgetTokenPolicy -Value (New-R18ApiBudgetTokenPolicy)
    Write-R18ApiSafetyControlsJson -Path $paths.TimeoutPolicy -Value (New-R18ApiTimeoutPolicy)
    Write-R18ApiSafetyControlsJson -Path $paths.Results -Value (New-R18ApiSafetyControlsResults)
    Write-R18ApiSafetyControlsJson -Path $paths.CheckReport -Value (New-R18ApiSafetyControlsCheckReport)
    Write-R18ApiSafetyControlsJson -Path $paths.Snapshot -Value (New-R18ApiSafetyControlsSnapshot)

    $fixtures = New-R18ApiSafetyControlsFixtures
    foreach ($fixture in $fixtures) {
        Write-R18ApiSafetyControlsJson -Path (Join-Path $paths.FixtureRoot $fixture.file) -Value $fixture.fixture
    }
    Write-R18ApiSafetyControlsJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value ([ordered]@{
            artifact_type = "r18_api_safety_controls_fixture_manifest"
            contract_version = "v1"
            source_task = $script:R18ApiSafetySourceTask
            fixture_count = $fixtures.Count
            invalid_fixture_refs = @($fixtures | ForEach-Object { "tests/fixtures/r18_api_safety_controls/$($_.file)" })
            validation_purpose = "Prove fail-closed rejection of unsafe secret, budget, token, timeout, logging, approval, API-enable, and runtime-claim policies."
            runtime_flags = New-R18ApiSafetyControlsRuntimeFlags
            non_claims = Get-R18ApiSafetyControlsNonClaims
            rejected_claims = Get-R18ApiSafetyControlsRejectedClaims
        })

    $proof = New-R18ApiSafetyControlsProofArtifacts
    Write-R18ApiSafetyControlsJson -Path $paths.EvidenceIndex -Value $proof.EvidenceIndex
    Write-R18ApiSafetyControlsText -Path $paths.ProofReview -Value $proof.ProofReview
    Write-R18ApiSafetyControlsText -Path $paths.ValidationManifest -Value $proof.ValidationManifest

    $set = Get-R18ApiSafetyControlsSet -RepositoryRoot $RepositoryRoot
    $validation = Test-R18ApiSafetyControlsSet `
        -Contract $set.Contract `
        -DisabledProfile $set.DisabledProfile `
        -SecretsPolicy $set.SecretsPolicy `
        -BudgetTokenPolicy $set.BudgetTokenPolicy `
        -TimeoutPolicy $set.TimeoutPolicy `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $validation.AggregateVerdict
        InvalidFixtureCount = $fixtures.Count
        RuntimeFlags = $validation.RuntimeFlags
    }
}

function Assert-R18ApiSafetyControlsCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18ApiSafetyControlsFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18ApiSafetyControlsCondition -Condition ($null -ne $Object.PSObject.Properties[$field]) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18ApiSafetyControlsRuntimeFalse {
    param([Parameter(Mandatory = $true)][object]$RuntimeFlags)

    foreach ($flagName in $script:R18ApiSafetyRuntimeFlagFields) {
        Assert-R18ApiSafetyControlsCondition -Condition ($null -ne $RuntimeFlags.PSObject.Properties[$flagName]) -Message "runtime flag '$flagName' is missing."
        Assert-R18ApiSafetyControlsCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "runtime flag '$flagName' must remain false."
    }
}

function Test-R18ApiSafetyControlsSecretFreeObject {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $text = $Object | ConvertTo-Json -Depth 100 -Compress
    $secretPatterns = @(
        '(?i)\b(api[_-]?key|secret|token)\s*=\s*["'']?[A-Za-z0-9_\-]{12,}',
        '(?i)\bauthorization:\s*bearer\s+[A-Za-z0-9_\-\.]{12,}',
        '\bsk-(live|proj|test)-[A-Za-z0-9_\-]{8,}',
        '\bxox[baprs]-[A-Za-z0-9\-]{8,}'
    )
    foreach ($pattern in $secretPatterns) {
        if ($text -match $pattern) {
            throw "$Context contains apparent committed secret material."
        }
    }
}

function Assert-R18ApiSafetyControlsRefs {
    param(
        [Parameter(Mandatory = $true)][object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot),
        [switch]$SkipExistence
    )

    Assert-R18ApiSafetyControlsCondition -Condition (@($Refs).Count -gt 0) -Message "$Context must include at least one ref."
    foreach ($ref in @($Refs)) {
        $value = [string]$ref
        Assert-R18ApiSafetyControlsCondition -Condition (-not [string]::IsNullOrWhiteSpace($value)) -Message "$Context contains an empty ref."
        Assert-R18ApiSafetyControlsCondition -Condition (-not [System.IO.Path]::IsPathRooted($value)) -Message "$Context ref '$value' must be repo-relative."
        Assert-R18ApiSafetyControlsCondition -Condition ($value -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context ref '$value' uses an operator-local backup path."
        Assert-R18ApiSafetyControlsCondition -Condition ($value -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context ref '$value' targets historical R13/R14/R15/R16 evidence."
        if (-not $SkipExistence) {
            $resolved = Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue $value
            Assert-R18ApiSafetyControlsCondition -Condition (Test-Path -LiteralPath $resolved) -Message "$Context ref '$value' does not exist."
        }
    }
}

function Assert-R18ApiSafetyControlsCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R18ApiSafetyControlsFields -Object $Artifact -Fields @("artifact_type", "contract_version", "source_task", "source_milestone", "runtime_flags", "non_claims", "rejected_claims", "authority_refs", "evidence_refs") -Context $Context
    Assert-R18ApiSafetyControlsCondition -Condition ($Artifact.source_task -eq $script:R18ApiSafetySourceTask) -Message "$Context source_task must be R18-022."
    Assert-R18ApiSafetyControlsCondition -Condition ($Artifact.source_milestone -eq $script:R18ApiSafetySourceMilestone) -Message "$Context source_milestone is invalid."
    Assert-R18ApiSafetyControlsRuntimeFalse -RuntimeFlags $Artifact.runtime_flags
    Assert-R18ApiSafetyControlsRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    Test-R18ApiSafetyControlsSecretFreeObject -Object $Artifact -Context $Context
}

function Assert-R18ApiSafetyControlsContract {
    param([Parameter(Mandatory = $true)][object]$Contract, [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot), [switch]$SkipRefExistence)
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Contract -Context "contract" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCondition -Condition ($Contract.artifact_type -eq "r18_api_safety_controls_contract") -Message "contract artifact_type is invalid."
    foreach ($field in @("api_disabled_by_default_required", "secrets_never_committed_required", "per_request_budget_required", "per_task_budget_required", "token_budget_required", "per_request_timeout_required", "per_task_timeout_required", "logs_redact_secrets_required", "operator_approval_required", "missing_controls_block_api_adapter_work", "controls_are_not_api_invocation")) {
        Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Contract.acceptance_controls.$field -eq $true) -Message "contract acceptance control '$field' must be true."
    }
    foreach ($field in @("reject_api_enabled_default", "reject_committed_secret_values", "reject_raw_secret_logging", "reject_missing_budget", "reject_missing_token_budget", "reject_unbounded_budget_or_tokens", "reject_missing_timeout", "reject_unbounded_timeout", "reject_missing_operator_approval_requirement", "reject_runtime_claims")) {
        Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Contract.validation_policy.$field -eq $true) -Message "contract validation policy '$field' must be true."
    }
}

function Assert-R18ApiDisabledProfile {
    param([Parameter(Mandatory = $true)][object]$Profile, [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot), [switch]$SkipRefExistence)
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Profile -Context "disabled profile" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCondition -Condition ($Profile.artifact_type -eq "r18_api_disabled_profile") -Message "disabled profile artifact_type is invalid."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.api_enabled -eq $false) -Message "API disabled profile must keep api_enabled false."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.codex_api_enabled -eq $false) -Message "Codex API must remain disabled."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.openai_api_enabled -eq $false) -Message "OpenAI API must remain disabled."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.live_api_invocation_allowed_by_r18_022 -eq $false) -Message "R18-022 must not allow live API invocation."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.enablement_requirements.operator_approval_required -eq $true) -Message "Operator approval is required before API enablement."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.enablement_requirements.seed_decision_approved -eq $false) -Message "Seed API enablement decision must not approve runtime."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Profile.adapter_work_policy.missing_controls_block_api_adapter_work -eq $true) -Message "Missing controls must block API adapter work."
}

function Assert-R18ApiSecretsPolicy {
    param([Parameter(Mandatory = $true)][object]$Policy, [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot), [switch]$SkipRefExistence)
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Policy -Context "secrets policy" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCondition -Condition ($Policy.artifact_type -eq "r18_api_secrets_policy") -Message "secrets policy artifact_type is invalid."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.committed_secret_values_present -eq $false) -Message "Secrets policy must record no committed secret values."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.secret_values_committed_allowed -eq $false) -Message "Secret values must not be allowed in repo artifacts."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.raw_secret_values_in_logs_allowed -eq $false) -Message "Raw secret values must not be allowed in logs."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.logging_redaction_policy.redact_secret_values -eq $true) -Message "Logs must redact secret values."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.logging_redaction_policy.raw_secret_logging_allowed -eq $false) -Message "Raw secret logging must be disabled."
}

function Assert-R18ApiBudgetTokenPolicy {
    param([Parameter(Mandatory = $true)][object]$Policy, [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot), [switch]$SkipRefExistence)
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Policy -Context "budget/token policy" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCondition -Condition ($Policy.artifact_type -eq "r18_api_budget_token_policy") -Message "budget/token policy artifact_type is invalid."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.per_request_budget_usd.limit_defined -eq $true) -Message "Per-request budget limit must be defined."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.per_task_budget_usd.limit_defined -eq $true) -Message "Per-task budget limit must be defined."
    Assert-R18ApiSafetyControlsCondition -Condition ([decimal]$Policy.per_request_budget_usd.max_usd_when_disabled -eq 0) -Message "Disabled per-request budget must be zero."
    Assert-R18ApiSafetyControlsCondition -Condition ([decimal]$Policy.per_task_budget_usd.max_usd_when_disabled -eq 0) -Message "Disabled per-task budget must be zero."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.per_request_budget_usd.unbounded_budget_allowed -eq $false -and [bool]$Policy.per_task_budget_usd.unbounded_budget_allowed -eq $false) -Message "Unbounded budgets are not allowed."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.token_budget.per_request_input_token_limit_defined -eq $true -and [bool]$Policy.token_budget.per_request_output_token_limit_defined -eq $true -and [bool]$Policy.token_budget.per_task_total_token_limit_defined -eq $true) -Message "Token budget limits must be defined."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.token_budget.unbounded_tokens_allowed -eq $false) -Message "Unbounded token budgets are not allowed."
    Assert-R18ApiSafetyControlsCondition -Condition ([int]$Policy.token_budget.max_total_tokens_when_disabled -eq 0) -Message "Disabled token budget must be zero."
}

function Assert-R18ApiTimeoutPolicy {
    param([Parameter(Mandatory = $true)][object]$Policy, [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot), [switch]$SkipRefExistence)
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Policy -Context "timeout policy" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCondition -Condition ($Policy.artifact_type -eq "r18_api_timeout_policy") -Message "timeout policy artifact_type is invalid."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.timeout_policy.per_request_timeout_limit_defined -eq $true) -Message "Per-request timeout limit must be defined."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.timeout_policy.per_task_timeout_limit_defined -eq $true) -Message "Per-task timeout limit must be defined."
    Assert-R18ApiSafetyControlsCondition -Condition ([int]$Policy.timeout_policy.max_request_seconds_when_disabled -eq 0) -Message "Disabled request timeout must be zero."
    Assert-R18ApiSafetyControlsCondition -Condition ([int]$Policy.timeout_policy.max_task_seconds_when_disabled -eq 0) -Message "Disabled task timeout must be zero."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.timeout_policy.unbounded_timeout_allowed -eq $false) -Message "Unbounded timeouts are not allowed."
    Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Policy.timeout_policy.missing_timeout_fails_closed -eq $true) -Message "Missing timeout must fail closed."
}

function Get-R18ApiSafetyControlsTaskStatusMap {
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

function Test-R18ApiSafetyControlsStatusTruth {
    param([string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18ApiSafetyControlsPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-023 only",
            "R18-024 through R18-028 planned only",
            "R18-023 created optional API adapter stub foundation only",
            "Optional API adapter stub artifacts are disabled/dry-run only",
            "No API invocation is claimed by a stub",
            "Missing approval or budget blocks adapter operation",
            "R18-022 created safety, secrets, budget, and token controls foundation only",
            "Controls are not API invocation",
            "API-backed automation remains disabled by default",
            "No live agents were invoked",
            "No live skills were executed",
            "No R18 runtime tool-call execution was performed",
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
        Assert-R18ApiSafetyControlsCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-022 truth: $required"
    }

    $authorityStatuses = Get-R18ApiSafetyControlsTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18ApiSafetyControlsTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18ApiSafetyControlsCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 23) {
            Assert-R18ApiSafetyControlsCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-023."
        }
        else {
            Assert-R18ApiSafetyControlsCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-023."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[4-8])') {
        throw "Status surface claims R18 beyond R18-023."
    }
    if ($combinedText -match '(?i)R18-(02[4-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-024 or later completion."
    }

    return [pscustomobject]@{
        R18DoneThrough = 23
        R18PlannedStart = 24
        R18PlannedThrough = 28
    }
}

function Test-R18ApiSafetyControlsSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$DisabledProfile,
        [Parameter(Mandatory = $true)][object]$SecretsPolicy,
        [Parameter(Mandatory = $true)][object]$BudgetTokenPolicy,
        [Parameter(Mandatory = $true)][object]$TimeoutPolicy,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [Parameter(Mandatory = $true)][object]$EvidenceIndex,
        [string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R18ApiSafetyControlsContract -Contract $Contract -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiDisabledProfile -Profile $DisabledProfile -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSecretsPolicy -Policy $SecretsPolicy -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiBudgetTokenPolicy -Policy $BudgetTokenPolicy -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiTimeoutPolicy -Policy $TimeoutPolicy -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Results -Context "results" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Report -Context "check report" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $Snapshot -Context "snapshot" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R18ApiSafetyControlsCommonArtifact -Artifact $EvidenceIndex -Context "evidence index" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence

    Assert-R18ApiSafetyControlsCondition -Condition ($Results.aggregate_verdict -eq $script:R18ApiSafetyVerdict) -Message "Results aggregate verdict is invalid."
    Assert-R18ApiSafetyControlsCondition -Condition ($Report.aggregate_verdict -eq $script:R18ApiSafetyVerdict) -Message "Check report aggregate verdict is invalid."
    foreach ($field in @("api_disabled_by_default", "secrets_never_committed", "per_request_budget_exists", "per_task_budget_exists", "token_budget_exists", "per_request_timeout_exists", "per_task_timeout_exists", "logs_redact_secrets", "operator_approval_required", "missing_controls_block_api_adapter_work")) {
        Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Results.control_results.$field -eq $true) -Message "results control '$field' must be true."
    }
    foreach ($field in @("unsafe_secret_policy_rejected", "unsafe_budget_policy_rejected", "unsafe_token_policy_rejected", "unsafe_timeout_policy_rejected", "unsafe_logging_policy_rejected", "missing_operator_approval_rejected", "api_enabled_default_rejected", "runtime_overclaim_rejected")) {
        Assert-R18ApiSafetyControlsCondition -Condition ([bool]$Report.validation_summary.$field -eq $true) -Message "report validation summary '$field' must be true."
    }
    Assert-R18ApiSafetyControlsCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_022_only") -Message "Snapshot must record active_through_r18_022_only."
    Assert-R18ApiSafetyControlsCondition -Condition ($Snapshot.api_status -eq "disabled_by_default") -Message "Snapshot must record API disabled by default."

    Test-R18ApiSafetyControlsStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RuntimeFlags = $Report.runtime_flags
        ApiEnabled = [bool]$DisabledProfile.api_enabled
        OperatorApprovalRequired = [bool]$DisabledProfile.enablement_requirements.operator_approval_required
    }
}

function Get-R18ApiSafetyControlsSet {
    param([string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot))

    return [pscustomobject]@{
        Contract = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "contracts/security/r18_api_safety_controls.contract.json"
        DisabledProfile = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_disabled_profile.json"
        SecretsPolicy = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_secrets_policy.json"
        BudgetTokenPolicy = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_budget_token_policy.json"
        TimeoutPolicy = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_timeout_policy.json"
        Results = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_safety_controls_results.json"
        Report = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/security/r18_api_safety_controls_check_report.json"
        Snapshot = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_api_safety_controls_snapshot.json"
        EvidenceIndex = Read-R18ApiSafetyControlsJson -RepositoryRoot $RepositoryRoot -Path "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_022_safety_secrets_budget_token_controls/evidence_index.json"
        Paths = Get-R18ApiSafetyControlsPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18ApiSafetyControls {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18ApiSafetyControlsRepositoryRoot))

    $set = Get-R18ApiSafetyControlsSet -RepositoryRoot $RepositoryRoot
    return Test-R18ApiSafetyControlsSet `
        -Contract $set.Contract `
        -DisabledProfile $set.DisabledProfile `
        -SecretsPolicy $set.SecretsPolicy `
        -BudgetTokenPolicy $set.BudgetTokenPolicy `
        -TimeoutPolicy $set.TimeoutPolicy `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RepositoryRoot $RepositoryRoot
}

function Get-R18ApiSafetyControlsMutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "contract" { return $Set.Contract }
        "disabled_profile" { return $Set.DisabledProfile }
        "secrets_policy" { return $Set.SecretsPolicy }
        "budget_token_policy" { return $Set.BudgetTokenPolicy }
        "timeout_policy" { return $Set.TimeoutPolicy }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Set-R18ApiSafetyControlsObjectPathValue {
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

function Remove-R18ApiSafetyControlsObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($null -eq $cursor.PSObject.Properties[$segment]) { return }
        $cursor = $cursor.PSObject.Properties[$segment].Value
    }
    $leaf = $segments[-1]
    if ($null -ne $cursor.PSObject.Properties[$leaf]) {
        $cursor.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18ApiSafetyControlsMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18ApiSafetyControlsObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18ApiSafetyControlsObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 API safety controls mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18ApiSafetyControlsPaths, `
    Get-R18ApiSafetyControlsRuntimeFlagNames, `
    New-R18ApiSafetyControlsRuntimeFlags, `
    New-R18ApiSafetyControlsArtifacts, `
    Test-R18ApiSafetyControls, `
    Test-R18ApiSafetyControlsSet, `
    Test-R18ApiSafetyControlsStatusTruth, `
    Get-R18ApiSafetyControlsSet, `
    Get-R18ApiSafetyControlsMutationTarget, `
    Copy-R18ApiSafetyControlsObject, `
    Invoke-R18ApiSafetyControlsMutation
