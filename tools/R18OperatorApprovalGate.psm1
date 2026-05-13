$Script:R18ApprovalSourceTask = "R18-016"
$Script:R18ApprovalMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$Script:R18ApprovalRepository = "RodneyMuniz/AIOffice_V2"
$Script:R18ApprovalBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"

function Get-R18OperatorApprovalRepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Resolve-R18OperatorApprovalPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return (Join-Path $RepositoryRoot $PathValue)
}

function Read-R18OperatorApprovalJson {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $path = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue $PathValue
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required artifact missing: $PathValue"
    }

    return (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json)
}

function Write-R18OperatorApprovalJson {
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

function Write-R18OperatorApprovalText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $text = if ($Value -is [array]) {
        [string]::Join([Environment]::NewLine, @($Value))
    }
    else {
        [string]$Value
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($text.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Copy-R18OperatorApprovalObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18OperatorApprovalPaths {
    param([string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot))

    return [ordered]@{
        GateContract = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_operator_approval_gate.contract.json"
        DecisionContract = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_operator_decision_packet.contract.json"
        Profile = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_profile.json"
        Matrix = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_scope_matrix.json"
        RequestRoot = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_requests"
        DecisionRoot = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_decisions"
        Results = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_results.json"
        CheckReport = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_check_report.json"
        UiSnapshot = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_operator_approval_gate_snapshot.json"
        FixtureRoot = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_operator_approval_gate"
        ProofRoot = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate"
        EvidenceIndex = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/evidence_index.json"
        ProofReview = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/proof_review.md"
        ValidationManifest = Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/validation_manifest.md"
    }
}

function Get-R18OperatorApprovalRuntimeFlagNames {
    return @(
        "operator_approval_runtime_implemented",
        "operator_approval_executed",
        "approval_inferred_from_narration",
        "stage_commit_push_gate_implemented",
        "stage_commit_push_approved",
        "recovery_execution_approved",
        "api_enablement_approved",
        "wip_abandonment_approved",
        "remote_branch_resolution_approved",
        "milestone_closeout_approved",
        "retry_execution_performed",
        "retry_runtime_implemented",
        "escalation_runtime_implemented",
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
        "r18_017_completed",
        "main_merge_claimed"
    )
}

function New-R18OperatorApprovalRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($name in Get-R18OperatorApprovalRuntimeFlagNames) {
        $flags[$name] = $false
    }
    return $flags
}

function Get-R18OperatorApprovalScopes {
    return @(
        "stage_commit_push_gate",
        "recovery_execution",
        "api_enablement",
        "wip_abandonment",
        "remote_branch_conflict_resolution",
        "milestone_closeout"
    )
}

function Get-R18OperatorApprovalDecisionStatuses {
    return @(
        "requested_not_decided",
        "refused_policy_only",
        "blocked_until_future_runtime",
        "operator_decision_required"
    )
}

function Get-R18OperatorApprovalRequiredRequestFields {
    return @(
        "artifact_type",
        "contract_version",
        "request_id",
        "request_name",
        "source_task",
        "source_milestone",
        "request_status",
        "approval_scope",
        "requested_action",
        "requester_role",
        "operator_identity_policy",
        "approval_reason",
        "risk_summary",
        "required_evidence_refs",
        "authority_refs",
        "dependency_refs",
        "expiry_policy",
        "revocation_policy",
        "allowed_outcomes",
        "forbidden_outcomes",
        "runtime_flags",
        "non_claims",
        "rejected_claims"
    )
}

function Get-R18OperatorApprovalRequiredDecisionFields {
    return @(
        "artifact_type",
        "contract_version",
        "decision_id",
        "decision_name",
        "source_task",
        "source_milestone",
        "decision_status",
        "approval_scope",
        "source_request_ref",
        "decision_result",
        "operator_identity_policy",
        "explicit_operator_decision_recorded",
        "approval_inferred_from_narration",
        "approved",
        "refused",
        "blocked",
        "reason",
        "expiry_policy",
        "revocation_policy",
        "evidence_refs",
        "authority_refs",
        "runtime_flags",
        "non_claims",
        "rejected_claims"
    )
}

function Get-R18OperatorApprovalPositiveClaims {
    return @(
        "r18_operator_approval_gate_contract_created",
        "r18_operator_decision_packet_contract_created",
        "r18_operator_approval_gate_profile_created",
        "r18_operator_approval_scope_matrix_created",
        "r18_operator_approval_requests_created",
        "r18_operator_approval_decisions_created",
        "r18_operator_approval_gate_results_created",
        "r18_operator_approval_gate_validator_created",
        "r18_operator_approval_gate_fixtures_created",
        "r18_operator_approval_gate_proof_review_created"
    )
}

function Get-R18OperatorApprovalRejectedClaims {
    return @(
        "operator_approval_runtime",
        "operator_approval_execution",
        "approval_inferred_from_narration",
        "stage_commit_push_gate",
        "stage_commit_push_approval",
        "recovery_execution_approval",
        "api_enablement_approval",
        "wip_abandonment_approval",
        "remote_branch_resolution_approval",
        "milestone_closeout_approval",
        "retry_execution",
        "retry_runtime",
        "escalation_runtime",
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
        "r18_017_or_later_completion",
        "main_merge",
        "approval_without_finite_scope",
        "approval_without_expiry_or_revocation",
        "approval_without_evidence_or_authority"
    )
}

function Get-R18OperatorApprovalNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-016 only.",
        "R18-017 through R18-028 remain planned only.",
        "R18-016 created operator approval gate model foundation only.",
        "Approval request and decision/refusal packets were generated as deterministic governance artifacts only.",
        "Operator approval runtime was not implemented.",
        "No approval was inferred from narration.",
        "No risky action was approved by seed packets.",
        "Stage/commit/push gate is not implemented.",
        "Retry execution was not performed.",
        "Recovery action was not performed.",
        "Continuation packets were not executed.",
        "Prompt packets were not executed.",
        "Automatic new-thread creation was not performed.",
        "Codex thread creation was not performed.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18OperatorApprovalEvidenceRefs {
    return @(
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "contracts/governance/r18_operator_decision_packet.contract.json",
        "state/governance/r18_operator_approval_gate_profile.json",
        "state/governance/r18_operator_approval_scope_matrix.json",
        "state/governance/r18_operator_approval_requests/",
        "state/governance/r18_operator_approval_decisions/",
        "state/governance/r18_operator_approval_gate_results.json",
        "state/governance/r18_operator_approval_gate_check_report.json",
        "state/ui/r18_operator_surface/r18_operator_approval_gate_snapshot.json",
        "tools/R18OperatorApprovalGate.psm1",
        "tools/new_r18_operator_approval_gate.ps1",
        "tools/validate_r18_operator_approval_gate.ps1",
        "tests/test_r18_operator_approval_gate.ps1",
        "tests/fixtures/r18_operator_approval_gate/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/"
    )
}

function Get-R18OperatorApprovalAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "contracts/runtime/r18_retry_escalation_decision.contract.json",
        "state/runtime/r18_retry_escalation_decisions/",
        "state/runtime/r18_retry_escalation_policy_results.json",
        "contracts/runtime/r18_continuation_packet.contract.json",
        "state/runtime/r18_continuation_packets/",
        "contracts/runtime/r18_new_context_prompt_packet.contract.json",
        "state/runtime/r18_new_context_prompt_packet_manifest.json",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_current_verification.json",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function New-R18OperatorApprovalIdentityPolicy {
    return [ordered]@{
        explicit_operator_identity_required = $true
        narration_does_not_identify_operator = $true
        future_approval_requires_operator_identity_record = $true
        seed_packets_record_live_operator_identity = $false
        operator_approval_runtime_implemented = $false
    }
}

function New-R18OperatorApprovalScopePolicy {
    return [ordered]@{
        finite_exact_scope_required = $true
        wildcard_scope_allowed = $false
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        future_approval_must_match_request_scope = $true
        seed_packets_approve_risky_actions = $false
    }
}

function New-R18OperatorApprovalExpiryPolicy {
    return [ordered]@{
        expiry_required_for_future_approval = $true
        seed_packet_expiry = "not_applicable_seed_refusal_no_approval_granted"
        finite_expiry_required_before_runtime_use = $true
    }
}

function New-R18OperatorApprovalRevocationPolicy {
    return [ordered]@{
        revocation_required_for_future_approval = $true
        revocation_effect = "future_runtime_must_stop_or_refuse_when_approval_is_revoked"
        seed_packet_revocation = "not_applicable_seed_refusal_no_approval_granted"
    }
}

function New-R18OperatorApprovalGateContract {
    return [ordered]@{
        artifact_type = "r18_operator_approval_gate_contract"
        contract_version = "v1"
        contract_id = "r18_016_operator_approval_gate_contract_v1"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        repository = $Script:R18ApprovalRepository
        branch = $Script:R18ApprovalBranch
        scope = "deterministic_operator_approval_gate_model_artifacts_only"
        purpose = "Define explicit, scoped, evidence-backed, revocable/refusable operator approval contracts for future runtime work without executing approvals."
        required_request_fields = Get-R18OperatorApprovalRequiredRequestFields
        required_decision_fields = Get-R18OperatorApprovalRequiredDecisionFields
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        allowed_decision_statuses = Get-R18OperatorApprovalDecisionStatuses
        required_runtime_false_flags = Get-R18OperatorApprovalRuntimeFlagNames
        operator_identity_policy = New-R18OperatorApprovalIdentityPolicy
        approval_scope_policy = New-R18OperatorApprovalScopePolicy
        evidence_policy = [ordered]@{ evidence_refs_required = $true; missing_evidence_refs_fail_closed = $true; evidence_must_precede_future_runtime_approval = $true }
        authority_policy = [ordered]@{ authority_refs_required = $true; missing_authority_refs_fail_closed = $true; r18_current_boundary = "R18 active through R18-016 only"; r18_future_boundary = "R18-017 through R18-028 planned only" }
        refusal_policy = [ordered]@{ seed_packets_refuse_or_block_all_risky_scopes = $true; refusal_is_policy_artifact_only = $true; refusal_does_not_execute_runtime = $true }
        expiry_revocation_policy = [ordered]@{ expiry_policy_required = $true; revocation_policy_required = $true; approval_without_expiry_or_revocation_fails_closed = $true }
        boundary_policy = [ordered]@{ model_only = $true; no_live_approval_runtime = $true; no_risky_action_approval = $true; no_R18_017_or_later_completion_claim = $true }
        path_policy = [ordered]@{ allowed_paths = @("contracts/governance/r18_operator_", "state/governance/r18_operator_approval_", "state/ui/r18_operator_surface/r18_operator_approval_gate_snapshot.json", "tools/R18OperatorApprovalGate.psm1", "tests/fixtures/r18_operator_approval_gate/", "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/"); forbidden_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_") }
        api_policy = [ordered]@{ codex_api_invocation_allowed = $false; openai_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false; api_enablement_approved = $false }
        execution_policy = [ordered]@{ approval_execution_allowed = $false; recovery_action_allowed = $false; retry_execution_allowed = $false; work_order_execution_allowed = $false; stage_commit_push_allowed = $false; live_agent_or_skill_execution_allowed = $false; a2a_message_allowed = $false }
        allowed_positive_claims = Get-R18OperatorApprovalPositiveClaims
        positive_claims = @("r18_operator_approval_gate_contract_created")
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        non_claims = Get-R18OperatorApprovalNonClaims
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
    }
}

function New-R18OperatorDecisionPacketContract {
    return [ordered]@{
        artifact_type = "r18_operator_decision_packet_contract"
        contract_version = "v1"
        contract_id = "r18_016_operator_decision_packet_contract_v1"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        required_decision_packet_fields = Get-R18OperatorApprovalRequiredDecisionFields
        required_runtime_false_flags = Get-R18OperatorApprovalRuntimeFlagNames
        decision_packet_policy = [ordered]@{ explicit_decision_packet_required_for_future_approval = $true; seed_decisions_must_be_refusal_or_blocked_policy_only = $true; approved_seed_packets_allowed = $false; allowed_decision_statuses = Get-R18OperatorApprovalDecisionStatuses }
        approval_inference_policy = [ordered]@{ approval_inference_allowed = $false; narration_is_never_approval = $true; approval_inferred_from_narration_must_be_false = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; authority_refs_required = $true; source_request_ref_required = $true; missing_refs_fail_closed = $true }
        positive_claims = @("r18_operator_decision_packet_contract_created")
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
    }
}

function Get-R18OperatorApprovalDefinitions {
    return @(
        [ordered]@{
            approval_scope = "stage_commit_push_gate"
            request_name = "Stage commit push gate approval request packet"
            requested_action = "Authorize future stage/commit/push gate runtime to stage, commit, or push only after its own R18-017 implementation exists."
            approval_reason = "Future release actions require an explicit operator approval gate and evidence-backed decision packet."
            risk_summary = "Staging, committing, or pushing can mutate repository history and remote state."
            dependency_refs = @("contracts/runtime/r18_remote_branch_verifier.contract.json", "state/runtime/r18_remote_branch_current_verification.json")
            refusal_reason = "R18-016 does not implement or approve a stage/commit/push gate; R18-017 remains planned only."
        },
        [ordered]@{
            approval_scope = "recovery_execution"
            request_name = "Recovery execution approval request packet"
            requested_action = "Authorize future recovery execution after runtime controls and evidence gates exist."
            approval_reason = "Recovery execution must be explicit, scoped, reversible where possible, and evidence-backed."
            risk_summary = "Recovery execution could mutate files, runner state, WIP, or branch state."
            dependency_refs = @("contracts/runtime/r18_retry_escalation_policy.contract.json", "state/runtime/r18_retry_escalation_policy_results.json")
            refusal_reason = "R18-016 defines approval artifacts only and does not approve or perform recovery execution."
        },
        [ordered]@{
            approval_scope = "api_enablement"
            request_name = "API enablement approval request packet"
            requested_action = "Authorize future Codex/OpenAI API enablement only after secrets, budget, timeout, retry, and stop controls exist."
            approval_reason = "API-backed automation must be separately approved before any invocation is possible."
            risk_summary = "API enablement can incur cost, expose secrets, and trigger autonomous invocation if not gated."
            dependency_refs = @("state/governance/r18_opening_authority.json", "contracts/runtime/r18_retry_escalation_policy.contract.json")
            refusal_reason = "R18-016 does not approve API enablement, Codex API invocation, or OpenAI API invocation."
        },
        [ordered]@{
            approval_scope = "wip_abandonment"
            request_name = "WIP abandonment approval request packet"
            requested_action = "Authorize future WIP abandonment only for an exact path and classification after operator approval."
            approval_reason = "Unsafe WIP cannot be cleaned, abandoned, restored, or deleted without explicit operator decision."
            risk_summary = "WIP abandonment can lose local changes or evidence."
            dependency_refs = @("contracts/runtime/r18_wip_classifier.contract.json", "state/runtime/r18_wip_classification_packets/")
            refusal_reason = "R18-016 does not approve WIP abandonment or cleanup."
        },
        [ordered]@{
            approval_scope = "remote_branch_conflict_resolution"
            request_name = "Remote branch conflict resolution approval request packet"
            requested_action = "Authorize future remote branch conflict resolution only after exact branch/head/tree evidence and operator decision."
            approval_reason = "Remote movement or divergence must be resolved by an explicit, scoped operator decision."
            risk_summary = "Remote branch resolution can imply pull, rebase, reset, merge, checkout, switch, push, or conflict handling."
            dependency_refs = @("contracts/runtime/r18_remote_branch_verifier.contract.json", "state/runtime/r18_remote_branch_current_verification.json")
            refusal_reason = "R18-016 does not approve remote branch conflict resolution or branch mutation."
        },
        [ordered]@{
            approval_scope = "milestone_closeout"
            request_name = "Milestone closeout approval request packet"
            requested_action = "Authorize future milestone closeout only after exact validation, evidence package, and status gate completion."
            approval_reason = "Milestone closeout must remain explicit, evidence-backed, and bounded to the current milestone status."
            risk_summary = "Closeout can overclaim runtime/product success or advance planned tasks incorrectly."
            dependency_refs = @("governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md", "governance/ACTIVE_STATE.md")
            refusal_reason = "R18-016 does not approve milestone closeout; R18-017 through R18-028 remain planned only."
        }
    )
}

function New-R18OperatorApprovalRequest {
    param([Parameter(Mandatory = $true)][object]$Definition)

    $scope = [string]$Definition.approval_scope
    return [ordered]@{
        artifact_type = "r18_operator_approval_request_packet"
        contract_version = "v1"
        request_id = "r18_016_$($scope)_request"
        request_name = $Definition.request_name
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        request_status = "request_packet_only_not_runtime_approval"
        approval_scope = $scope
        requested_action = $Definition.requested_action
        requester_role = "governance_model_seed"
        operator_identity_policy = New-R18OperatorApprovalIdentityPolicy
        approval_reason = $Definition.approval_reason
        risk_summary = $Definition.risk_summary
        required_evidence_refs = @((Get-R18OperatorApprovalEvidenceRefs) + @($Definition.dependency_refs))
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        dependency_refs = @($Definition.dependency_refs)
        expiry_policy = New-R18OperatorApprovalExpiryPolicy
        revocation_policy = New-R18OperatorApprovalRevocationPolicy
        allowed_outcomes = @("refused_policy_only", "blocked_until_future_runtime", "operator_decision_required")
        forbidden_outcomes = @("approval_inferred_from_narration", "approval_without_decision_packet", "approval_without_exact_scope", "approval_without_evidence_refs", "approval_without_authority_refs", "runtime_execution")
        evidence_refs = @((Get-R18OperatorApprovalEvidenceRefs) + @($Definition.dependency_refs))
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_requests_created")
    }
}

function New-R18OperatorApprovalDecision {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][string]$RequestRef
    )

    $scope = [string]$Definition.approval_scope
    return [ordered]@{
        artifact_type = "r18_operator_approval_decision_packet"
        contract_version = "v1"
        decision_id = "r18_016_$($scope)_refusal"
        decision_name = "$($Definition.request_name) refusal packet"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        decision_status = "refused_policy_only"
        approval_scope = $scope
        source_request_ref = $RequestRef
        decision_result = "refused_policy_only_no_approval_granted"
        operator_identity_policy = New-R18OperatorApprovalIdentityPolicy
        explicit_operator_decision_recorded = $false
        approval_inferred_from_narration = $false
        approved = $false
        refused = $true
        blocked = $true
        reason = $Definition.refusal_reason
        expiry_policy = New-R18OperatorApprovalExpiryPolicy
        revocation_policy = New-R18OperatorApprovalRevocationPolicy
        evidence_refs = @((Get-R18OperatorApprovalEvidenceRefs) + @($RequestRef) + @($Definition.dependency_refs))
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_decisions_created")
    }
}

function New-R18OperatorApprovalProfile {
    param(
        [Parameter(Mandatory = $true)][array]$RequestRefs,
        [Parameter(Mandatory = $true)][array]$DecisionRefs
    )

    return [ordered]@{
        artifact_type = "r18_operator_approval_gate_profile"
        contract_version = "v1"
        profile_id = "r18_016_operator_approval_gate_profile_v1"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        profile_status = "approval_gate_profile_generated_not_runtime_approval"
        repository = $Script:R18ApprovalRepository
        branch = $Script:R18ApprovalBranch
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        allowed_decision_statuses = Get-R18OperatorApprovalDecisionStatuses
        request_refs = $RequestRefs
        decision_refs = $DecisionRefs
        operator_identity_policy = New-R18OperatorApprovalIdentityPolicy
        approval_scope_policy = New-R18OperatorApprovalScopePolicy
        expiry_policy = New-R18OperatorApprovalExpiryPolicy
        revocation_policy = New-R18OperatorApprovalRevocationPolicy
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_profile_created")
    }
}

function New-R18OperatorApprovalScopeMatrix {
    param(
        [Parameter(Mandatory = $true)][array]$RequestRefs,
        [Parameter(Mandatory = $true)][array]$DecisionRefs
    )

    $rows = @()
    $definitions = Get-R18OperatorApprovalDefinitions
    foreach ($definition in $definitions) {
        $scope = [string]$definition.approval_scope
        $rows += [ordered]@{
            approval_scope = $scope
            request_ref = "state/governance/r18_operator_approval_requests/$scope.request.json"
            seed_decision_ref = "state/governance/r18_operator_approval_decisions/$scope.refusal.json"
            seed_decision_status = "refused_policy_only"
            future_approval_requires_explicit_operator_decision = $true
            future_approval_requires_evidence_refs = $true
            future_approval_requires_authority_refs = $true
            future_approval_requires_expiry_policy = $true
            future_approval_requires_revocation_policy = $true
            seed_packet_approved = $false
        }
    }

    return [ordered]@{
        artifact_type = "r18_operator_approval_scope_matrix"
        contract_version = "v1"
        matrix_id = "r18_016_operator_approval_scope_matrix_v1"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        matrix_status = "scope_matrix_generated_not_runtime_enforcement"
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        allowed_decision_statuses = Get-R18OperatorApprovalDecisionStatuses
        request_refs = $RequestRefs
        decision_refs = $DecisionRefs
        scope_rows = $rows
        approval_scope_policy = New-R18OperatorApprovalScopePolicy
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_scope_matrix_created")
    }
}

function New-R18OperatorApprovalFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [string]$Path,
        [object]$Value,
        [object[]]$Mutations,
        [string[]]$Expected
    )

    $fixture = [ordered]@{
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($File)
        artifact_type = "r18_operator_approval_gate_invalid_fixture"
        source_task = $Script:R18ApprovalSourceTask
        target = $Target
        operation = $Operation
        expected_failure_fragments = @($Expected)
    }

    if ($Path) { $fixture["path"] = $Path }
    if ($PSBoundParameters.ContainsKey("Value")) { $fixture["value"] = $Value }
    if ($Mutations) { $fixture["mutations"] = $Mutations }
    return $fixture
}

function Get-R18OperatorApprovalFixtureDefinitions {
    $approvedMutation = @(
        [ordered]@{ operation = "set"; path = "approved"; value = $true },
        [ordered]@{ operation = "set"; path = "explicit_operator_decision_recorded"; value = $true },
        [ordered]@{ operation = "set"; path = "refused"; value = $false },
        [ordered]@{ operation = "set"; path = "blocked"; value = $false }
    )

    return @(
        (New-R18OperatorApprovalFixture -File "invalid_missing_request_id.json" -Target "request:stage_commit_push_gate" -Operation "remove" -Path "request_id" -Expected @("request_id")),
        (New-R18OperatorApprovalFixture -File "invalid_missing_decision_id.json" -Target "decision:stage_commit_push_gate" -Operation "remove" -Path "decision_id" -Expected @("decision_id")),
        (New-R18OperatorApprovalFixture -File "invalid_missing_approval_scope.json" -Target "request:stage_commit_push_gate" -Operation "remove" -Path "approval_scope" -Expected @("approval_scope")),
        (New-R18OperatorApprovalFixture -File "invalid_unknown_approval_scope.json" -Target "request:stage_commit_push_gate" -Operation "set" -Path "approval_scope" -Value "unknown_scope" -Expected @("Unknown approval scope")),
        (New-R18OperatorApprovalFixture -File "invalid_missing_operator_identity_policy.json" -Target "request:stage_commit_push_gate" -Operation "remove" -Path "operator_identity_policy" -Expected @("operator_identity_policy")),
        (New-R18OperatorApprovalFixture -File "invalid_missing_evidence_refs.json" -Target "decision:stage_commit_push_gate" -Operation "remove" -Path "evidence_refs" -Expected @("evidence_refs")),
        (New-R18OperatorApprovalFixture -File "invalid_missing_authority_refs.json" -Target "decision:stage_commit_push_gate" -Operation "remove" -Path "authority_refs" -Expected @("authority_refs")),
        (New-R18OperatorApprovalFixture -File "invalid_approval_inferred_from_narration.json" -Target "decision:stage_commit_push_gate" -Operation "set" -Path "approval_inferred_from_narration" -Value $true -Expected @("approval_inferred_from_narration")),
        (New-R18OperatorApprovalFixture -File "invalid_approval_without_explicit_decision_packet.json" -Target "decision:stage_commit_push_gate" -Operation "set" -Path "approved" -Value $true -Expected @("explicit operator decision")),
        (New-R18OperatorApprovalFixture -File "invalid_approval_without_scope.json" -Target "decision:stage_commit_push_gate" -Operation "remove" -Path "approval_scope" -Expected @("approval_scope")),
        (New-R18OperatorApprovalFixture -File "invalid_approval_without_expiry_or_revocation_policy.json" -Target "decision:stage_commit_push_gate" -Operation "remove" -Path "expiry_policy" -Expected @("expiry_policy")),
        (New-R18OperatorApprovalFixture -File "invalid_stage_commit_push_approved.json" -Target "decision:stage_commit_push_gate" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_api_enablement_approved.json" -Target "decision:api_enablement" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_recovery_execution_approved.json" -Target "decision:recovery_execution" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_wip_abandonment_approved.json" -Target "decision:wip_abandonment" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_remote_branch_resolution_approved.json" -Target "decision:remote_branch_conflict_resolution" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_milestone_closeout_approved.json" -Target "decision:milestone_closeout" -Operation "set_many" -Mutations $approvedMutation -Expected @("must not approve")),
        (New-R18OperatorApprovalFixture -File "invalid_operator_approval_runtime_claim.json" -Target "gate_contract" -Operation "set" -Path "runtime_flags.operator_approval_runtime_implemented" -Value $true -Expected @("operator_approval_runtime_implemented")),
        (New-R18OperatorApprovalFixture -File "invalid_stage_commit_push_gate_claim.json" -Target "gate_contract" -Operation "set" -Path "runtime_flags.stage_commit_push_gate_implemented" -Value $true -Expected @("stage_commit_push_gate_implemented")),
        (New-R18OperatorApprovalFixture -File "invalid_retry_execution_claim.json" -Target "decision:stage_commit_push_gate" -Operation "set" -Path "runtime_flags.retry_execution_performed" -Value $true -Expected @("retry_execution_performed")),
        (New-R18OperatorApprovalFixture -File "invalid_recovery_action_claim.json" -Target "decision:recovery_execution" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Expected @("recovery_action_performed")),
        (New-R18OperatorApprovalFixture -File "invalid_api_invocation_claim.json" -Target "decision:api_enablement" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -Expected @("codex_api_invoked")),
        (New-R18OperatorApprovalFixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "decision:recovery_execution" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Expected @("automatic_new_thread_creation_performed")),
        (New-R18OperatorApprovalFixture -File "invalid_work_order_execution_claim.json" -Target "decision:recovery_execution" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Expected @("work_order_execution_performed")),
        (New-R18OperatorApprovalFixture -File "invalid_a2a_message_sent_claim.json" -Target "decision:recovery_execution" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Expected @("a2a_message_sent")),
        (New-R18OperatorApprovalFixture -File "invalid_board_runtime_mutation_claim.json" -Target "decision:milestone_closeout" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Expected @("board_runtime_mutation_performed")),
        (New-R18OperatorApprovalFixture -File "invalid_r18_017_completion_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.r18_017_completed" -Value $true -Expected @("r18_017_completed"))
    )
}

function New-R18OperatorApprovalGateArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot))

    $paths = Get-R18OperatorApprovalPaths -RepositoryRoot $RepositoryRoot
    $definitions = Get-R18OperatorApprovalDefinitions
    $requestRefs = @()
    $decisionRefs = @()

    Write-R18OperatorApprovalJson -Path $paths.GateContract -Value (New-R18OperatorApprovalGateContract)
    Write-R18OperatorApprovalJson -Path $paths.DecisionContract -Value (New-R18OperatorDecisionPacketContract)

    foreach ($definition in $definitions) {
        $scope = [string]$definition.approval_scope
        $requestRel = "state/governance/r18_operator_approval_requests/$scope.request.json"
        $decisionRel = "state/governance/r18_operator_approval_decisions/$scope.refusal.json"
        $requestRefs += $requestRel
        $decisionRefs += $decisionRel

        Write-R18OperatorApprovalJson -Path (Join-Path $paths.RequestRoot "$scope.request.json") -Value (New-R18OperatorApprovalRequest -Definition $definition)
        Write-R18OperatorApprovalJson -Path (Join-Path $paths.DecisionRoot "$scope.refusal.json") -Value (New-R18OperatorApprovalDecision -Definition $definition -RequestRef $requestRel)
    }

    Write-R18OperatorApprovalJson -Path $paths.Profile -Value (New-R18OperatorApprovalProfile -RequestRefs $requestRefs -DecisionRefs $decisionRefs)
    Write-R18OperatorApprovalJson -Path $paths.Matrix -Value (New-R18OperatorApprovalScopeMatrix -RequestRefs $requestRefs -DecisionRefs $decisionRefs)

    $results = [ordered]@{
        artifact_type = "r18_operator_approval_gate_results"
        contract_version = "v1"
        result_id = "r18_016_operator_approval_gate_results"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        result_status = "approval_gate_results_generated_not_runtime_approval"
        aggregate_verdict = "passed"
        request_count = $requestRefs.Count
        decision_count = $decisionRefs.Count
        approved_seed_decision_count = 0
        refused_or_blocked_seed_decision_count = $decisionRefs.Count
        request_refs = $requestRefs
        decision_refs = $decisionRefs
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        allowed_decision_statuses = Get-R18OperatorApprovalDecisionStatuses
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_results_created")
    }
    Write-R18OperatorApprovalJson -Path $paths.Results -Value $results

    $report = [ordered]@{
        artifact_type = "r18_operator_approval_gate_check_report"
        contract_version = "v1"
        report_id = "r18_016_operator_approval_gate_check_report"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        report_status = "check_report_generated_not_runtime_approval"
        aggregate_verdict = "passed"
        checks = @(
            [ordered]@{ check_id = "contracts_created"; status = "passed"; count = 2 },
            [ordered]@{ check_id = "six_approval_scopes_created"; status = "passed"; count = $requestRefs.Count },
            [ordered]@{ check_id = "six_request_packets_created"; status = "passed"; count = $requestRefs.Count },
            [ordered]@{ check_id = "six_decision_refusal_packets_created"; status = "passed"; count = $decisionRefs.Count },
            [ordered]@{ check_id = "no_seed_decision_approved_risky_action"; status = "passed"; approved_seed_decision_count = 0 },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-016 only; R18-017 through R18-028 planned only" }
        )
        request_refs = $requestRefs
        decision_refs = $decisionRefs
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_validator_created")
    }
    Write-R18OperatorApprovalJson -Path $paths.CheckReport -Value $report

    $snapshot = [ordered]@{
        artifact_type = "r18_operator_approval_gate_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_016_operator_approval_gate_snapshot"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        snapshot_status = "operator_surface_snapshot_model_only_not_runtime_approval"
        r18_status = "active_through_r18_016_only"
        r18_future_boundary = "R18-017 through R18-028 planned only"
        approval_gate_summary = "Operator approval gate contracts, request packets, decision/refusal packets, scope matrix, and validation artifacts exist as deterministic governance artifacts only."
        request_refs = $requestRefs
        decision_refs = $decisionRefs
        allowed_approval_scopes = Get-R18OperatorApprovalScopes
        approved_seed_decision_count = 0
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_results_created")
    }
    Write-R18OperatorApprovalJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18OperatorApprovalFixtureDefinitions
    foreach ($fixture in $fixtureDefinitions) {
        Write-R18OperatorApprovalJson -Path (Join-Path $paths.FixtureRoot ($fixture.fixture_id + ".json")) -Value $fixture
    }

    $fixtureManifest = [ordered]@{
        artifact_type = "r18_operator_approval_gate_fixture_manifest"
        contract_version = "v1"
        manifest_id = "r18_016_operator_approval_gate_fixture_manifest"
        source_task = $Script:R18ApprovalSourceTask
        fixture_count = $fixtureDefinitions.Count
        fixture_ids = @($fixtureDefinitions | ForEach-Object { $_.fixture_id })
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_fixtures_created")
    }
    Write-R18OperatorApprovalJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $fixtureManifest

    $evidenceIndex = [ordered]@{
        artifact_type = "r18_operator_approval_gate_evidence_index"
        contract_version = "v1"
        evidence_index_id = "r18_016_operator_approval_gate_evidence_index"
        source_task = $Script:R18ApprovalSourceTask
        source_milestone = $Script:R18ApprovalMilestone
        evidence_refs = Get-R18OperatorApprovalEvidenceRefs
        authority_refs = Get-R18OperatorApprovalAuthorityRefs
        request_refs = $requestRefs
        decision_refs = $decisionRefs
        validation_refs = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_operator_approval_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_approval_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_approval_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
            "git diff --check"
        )
        runtime_flags = New-R18OperatorApprovalRuntimeFlags
        non_claims = Get-R18OperatorApprovalNonClaims
        rejected_claims = Get-R18OperatorApprovalRejectedClaims
        positive_claims = @("r18_operator_approval_gate_proof_review_created")
    }
    Write-R18OperatorApprovalJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $proofReview = @(
        "# R18-016 Operator Approval Gate Proof Review",
        "",
        "R18-016 creates the operator approval gate model foundation only.",
        "",
        "Generated artifacts:",
        "- Operator approval gate and operator decision packet contracts.",
        "- Approval gate profile and approval scope matrix.",
        "- Six approval request packets.",
        "- Six refusal/block decision packets.",
        "- Results, check report, operator-surface snapshot, fail-closed validator, fixtures, and evidence index.",
        "",
        "Non-claims:",
        "- Operator approval runtime was not implemented.",
        "- No approval was executed or inferred from narration.",
        "- No seed packet approves stage/commit/push, recovery execution, API enablement, WIP abandonment, remote branch conflict resolution, or milestone closeout.",
        "- Stage/commit/push gate, recovery runtime/action, retry execution, continuation/prompt execution, API invocation, work-order execution, board/card runtime mutation, A2A messages, live agents, live skills, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, and main merge are not claimed.",
        "",
        "Status truth: R18 is active through R18-016 only. R18-017 through R18-028 remain planned only."
    ) -join [Environment]::NewLine
    Write-R18OperatorApprovalText -Path $paths.ProofReview -Value $proofReview

    $validationManifest = @(
        "# R18-016 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-016 only; R18-017 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_operator_approval_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_approval_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_approval_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "- git diff --check",
        "",
        "No operator approval runtime, inferred approval, risky seed approval, stage/commit/push gate, recovery action, retry execution, continuation execution, prompt execution, API invocation, work-order execution, board/card mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or main merge is claimed."
    ) -join [Environment]::NewLine
    Write-R18OperatorApprovalText -Path $paths.ValidationManifest -Value $validationManifest

    return [pscustomobject]@{
        AggregateVerdict = "passed"
        RequestCount = $requestRefs.Count
        DecisionCount = $decisionRefs.Count
        RuntimeFlags = $report.runtime_flags
    }
}

function Assert-R18OperatorApprovalCondition {
    param(
        [bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18OperatorApprovalRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18OperatorApprovalCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing '$field'."
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

function Assert-R18OperatorApprovalRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in Get-R18OperatorApprovalRuntimeFlagNames) {
        Assert-R18OperatorApprovalCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flag) -Message "$Context runtime_flags missing '$flag'."
        Assert-R18OperatorApprovalCondition -Condition ([bool]$RuntimeFlags.$flag -eq $false) -Message "$Context runtime flag '$flag' must remain false."
    }
}

function Assert-R18OperatorApprovalCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18OperatorApprovalRequiredFields -Object $Artifact -Fields @("evidence_refs", "authority_refs", "runtime_flags", "non_claims", "rejected_claims") -Context $Context
    Assert-R18OperatorApprovalRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context

    if ($Artifact.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Artifact.positive_claims)) {
            Assert-R18OperatorApprovalCondition -Condition ((Get-R18OperatorApprovalPositiveClaims) -contains [string]$claim) -Message "$Context positive claim '$claim' is not allowed."
        }
    }
}

function Assert-R18OperatorApprovalGateContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18OperatorApprovalRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_request_fields",
        "required_decision_fields",
        "allowed_approval_scopes",
        "allowed_decision_statuses",
        "required_runtime_false_flags",
        "operator_identity_policy",
        "approval_scope_policy",
        "evidence_policy",
        "authority_policy",
        "refusal_policy",
        "expiry_revocation_policy",
        "boundary_policy",
        "path_policy",
        "api_policy",
        "execution_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    ) -Context "R18 operator approval gate contract"

    Assert-R18OperatorApprovalCondition -Condition ($Contract.source_task -eq $Script:R18ApprovalSourceTask) -Message "R18 operator approval gate contract source_task must be R18-016."
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Contract -Context "R18 operator approval gate contract"
    foreach ($scope in Get-R18OperatorApprovalScopes) {
        Assert-R18OperatorApprovalCondition -Condition (@($Contract.allowed_approval_scopes) -contains $scope) -Message "Gate contract missing approval scope '$scope'."
    }
}

function Assert-R18OperatorDecisionPacketContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18OperatorApprovalRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "required_decision_packet_fields",
        "required_runtime_false_flags",
        "decision_packet_policy",
        "approval_inference_policy",
        "evidence_policy",
        "non_claims",
        "rejected_claims"
    ) -Context "R18 operator decision packet contract"

    Assert-R18OperatorApprovalCondition -Condition ($Contract.source_task -eq $Script:R18ApprovalSourceTask) -Message "R18 operator decision packet contract source_task must be R18-016."
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Contract -Context "R18 operator decision packet contract"
}

function Assert-R18OperatorApprovalFiniteScope {
    param(
        [Parameter(Mandatory = $true)][string]$Scope,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18OperatorApprovalCondition -Condition ((Get-R18OperatorApprovalScopes) -contains $Scope) -Message "Unknown approval scope '$Scope' in $Context."
    Assert-R18OperatorApprovalCondition -Condition ($Scope -notmatch '[\*\?]' -and $Scope -ne "all" -and $Scope -ne "any") -Message "$Context approval scope must be finite and exact."
}

function Assert-R18OperatorApprovalRequest {
    param([Parameter(Mandatory = $true)][object]$Request)

    Assert-R18OperatorApprovalRequiredFields -Object $Request -Fields (Get-R18OperatorApprovalRequiredRequestFields) -Context "R18 operator approval request"
    Assert-R18OperatorApprovalCondition -Condition ($Request.source_task -eq $Script:R18ApprovalSourceTask) -Message "R18 operator approval request source_task must be R18-016."
    Assert-R18OperatorApprovalCondition -Condition ($Request.request_status -eq "request_packet_only_not_runtime_approval") -Message "R18 operator approval request has invalid request_status."
    Assert-R18OperatorApprovalFiniteScope -Scope ([string]$Request.approval_scope) -Context "R18 operator approval request"
    Assert-R18OperatorApprovalRequiredFields -Object $Request -Fields @("evidence_refs") -Context "R18 operator approval request"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Request -Context "R18 operator approval request '$($Request.approval_scope)'"
    Assert-R18OperatorApprovalRequiredFields -Object $Request -Fields @("expiry_policy", "revocation_policy", "operator_identity_policy") -Context "R18 operator approval request '$($Request.approval_scope)'"
}

function Assert-R18OperatorApprovalDecision {
    param([Parameter(Mandatory = $true)][object]$Decision)

    Assert-R18OperatorApprovalRequiredFields -Object $Decision -Fields (Get-R18OperatorApprovalRequiredDecisionFields) -Context "R18 operator approval decision"
    Assert-R18OperatorApprovalCondition -Condition ($Decision.source_task -eq $Script:R18ApprovalSourceTask) -Message "R18 operator approval decision source_task must be R18-016."
    Assert-R18OperatorApprovalCondition -Condition ((Get-R18OperatorApprovalDecisionStatuses) -contains [string]$Decision.decision_status) -Message "Unknown decision status '$($Decision.decision_status)'."
    Assert-R18OperatorApprovalFiniteScope -Scope ([string]$Decision.approval_scope) -Context "R18 operator approval decision"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Decision -Context "R18 operator approval decision '$($Decision.approval_scope)'"

    Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approval_inferred_from_narration -eq $false) -Message "approval_inferred_from_narration must remain false."
    Assert-R18OperatorApprovalCondition -Condition ($null -ne $Decision.expiry_policy) -Message "R18 operator approval decision missing expiry_policy."
    Assert-R18OperatorApprovalCondition -Condition ($null -ne $Decision.revocation_policy) -Message "R18 operator approval decision missing revocation_policy."

    if ([bool]$Decision.approved) {
        Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.explicit_operator_decision_recorded -eq $true) -Message "Approved decision requires explicit operator decision packet."
        Assert-R18OperatorApprovalCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Decision.source_request_ref)) -Message "Approved decision requires source_request_ref."
        throw "Seed decision packet for '$($Decision.approval_scope)' must not approve risky actions."
    }

    Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.refused -eq $true -or [bool]$Decision.blocked -eq $true) -Message "Seed decision packet must be refused or blocked policy-only."

    switch ([string]$Decision.approval_scope) {
        "stage_commit_push_gate" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve stage/commit/push." }
        "recovery_execution" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve recovery execution." }
        "api_enablement" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve API enablement." }
        "wip_abandonment" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve WIP abandonment." }
        "remote_branch_conflict_resolution" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve remote branch conflict resolution." }
        "milestone_closeout" { Assert-R18OperatorApprovalCondition -Condition ([bool]$Decision.approved -eq $false) -Message "No seed packet may approve milestone closeout." }
    }
}

function Get-R18OperatorApprovalTaskStatusMap {
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

function Test-R18OperatorApprovalStatusTruth {
    param([string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18OperatorApprovalPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-021 only",
            "R18-022 through R18-028 planned only",
            "R18-016 created operator approval gate model foundation only",
            "Approval request and decision/refusal packets were generated as deterministic governance artifacts only",
            "Operator approval runtime was not implemented",
            "No approval was inferred from narration",
            "No risky action was approved by seed packets",
            "R18-017 created stage/commit/push gate foundation only",
            "Stage/commit/push gate artifacts are deterministic policy artifacts only",
            "Gate runtime was not implemented",
            "The gate did not stage, commit, or push",
            "Retry execution was not performed",
            "Recovery action was not performed",
            "Continuation packets were not executed",
            "Prompt packets were not executed",
            "Automatic new-thread creation was not performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Main is not merged"
        )) {
        Assert-R18OperatorApprovalCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-016 truth: $required"
    }

    $authorityStatuses = Get-R18OperatorApprovalTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18OperatorApprovalTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18OperatorApprovalCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 21) {
            Assert-R18OperatorApprovalCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-021."
        }
        else {
            Assert-R18OperatorApprovalCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-021."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[2-8])') {
        throw "Status surface claims R18 beyond R18-021."
    }
    if ($combinedText -match '(?i)R18-(02[2-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-022 or later completion."
    }
}

function Test-R18OperatorApprovalGateSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$GateContract,
        [Parameter(Mandatory = $true)][object]$DecisionContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object]$Matrix,
        [Parameter(Mandatory = $true)][object[]]$Requests,
        [Parameter(Mandatory = $true)][object[]]$Decisions,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot)
    )

    Assert-R18OperatorApprovalGateContract -Contract $GateContract
    Assert-R18OperatorDecisionPacketContract -Contract $DecisionContract
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Profile -Context "R18 operator approval gate profile"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Matrix -Context "R18 operator approval scope matrix"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Results -Context "R18 operator approval gate results"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Report -Context "R18 operator approval gate check report"
    Assert-R18OperatorApprovalCommonArtifact -Artifact $Snapshot -Context "R18 operator approval gate snapshot"

    Assert-R18OperatorApprovalCondition -Condition (@($Requests).Count -eq 6) -Message "R18 operator approval gate must have six request packets."
    Assert-R18OperatorApprovalCondition -Condition (@($Decisions).Count -eq 6) -Message "R18 operator approval gate must have six decision/refusal packets."

    foreach ($request in @($Requests)) {
        Assert-R18OperatorApprovalRequest -Request $request
    }
    foreach ($decision in @($Decisions)) {
        Assert-R18OperatorApprovalDecision -Decision $decision
    }

    foreach ($scope in Get-R18OperatorApprovalScopes) {
        Assert-R18OperatorApprovalCondition -Condition (@($Requests | Where-Object { $_.approval_scope -eq $scope }).Count -eq 1) -Message "Missing request packet for '$scope'."
        Assert-R18OperatorApprovalCondition -Condition (@($Decisions | Where-Object { $_.approval_scope -eq $scope }).Count -eq 1) -Message "Missing decision/refusal packet for '$scope'."
    }

    foreach ($decision in @($Decisions)) {
        $matchingRequest = @($Requests | Where-Object { $_.approval_scope -eq $decision.approval_scope })[0]
        Assert-R18OperatorApprovalCondition -Condition ([string]$decision.source_request_ref -like "*$($matchingRequest.approval_scope).request.json") -Message "Decision packet source_request_ref does not match request for '$($decision.approval_scope)'."
    }

    Test-R18OperatorApprovalStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = "passed"
        RequestCount = @($Requests).Count
        DecisionCount = @($Decisions).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18OperatorApprovalGateSet {
    param([string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot))

    $requests = @()
    $decisions = @()
    foreach ($scope in Get-R18OperatorApprovalScopes) {
        $requests += Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_requests/$scope.request.json"
        $decisions += Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_decisions/$scope.refusal.json"
    }

    return [pscustomobject]@{
        GateContract = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_operator_approval_gate.contract.json"
        DecisionContract = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_operator_decision_packet.contract.json"
        Profile = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_profile.json"
        Matrix = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_scope_matrix.json"
        Requests = $requests
        Decisions = $decisions
        Results = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_results.json"
        Report = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_operator_approval_gate_check_report.json"
        Snapshot = Read-R18OperatorApprovalJson -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_operator_approval_gate_snapshot.json"
        Paths = Get-R18OperatorApprovalPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18OperatorApprovalGate {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18OperatorApprovalRepositoryRoot))

    $set = Get-R18OperatorApprovalGateSet -RepositoryRoot $RepositoryRoot
    return Test-R18OperatorApprovalGateSet `
        -GateContract $set.GateContract `
        -DecisionContract $set.DecisionContract `
        -Profile $set.Profile `
        -Matrix $set.Matrix `
        -Requests $set.Requests `
        -Decisions $set.Decisions `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18OperatorApprovalObjectPathValue {
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

function Remove-R18OperatorApprovalObjectPathValue {
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

function Invoke-R18OperatorApprovalMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "set" { Set-R18OperatorApprovalObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        "remove" { Remove-R18OperatorApprovalObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set_many" {
            foreach ($childMutation in @($Mutation.mutations)) {
                Invoke-R18OperatorApprovalMutation -TargetObject $TargetObject -Mutation $childMutation
            }
        }
        default { throw "Unknown mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18OperatorApprovalPaths, `
    New-R18OperatorApprovalGateArtifacts, `
    Test-R18OperatorApprovalGate, `
    Test-R18OperatorApprovalGateSet, `
    Test-R18OperatorApprovalStatusTruth, `
    Get-R18OperatorApprovalGateSet, `
    Copy-R18OperatorApprovalObject, `
    Invoke-R18OperatorApprovalMutation, `
    Get-R18OperatorApprovalScopes, `
    Get-R18OperatorApprovalRuntimeFlagNames
