Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18AgentCardGeneratedFromHead = "9bf0cd6da075ac398f9387e77072344e0671b73a"
$script:R18AgentCardGeneratedFromTree = "43f39e8f9ff6f09900f8b4f484356aceb10769fa"
$script:R18SourceTask = "R18-002"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18AgentCardVerdict = "generated_r18_agent_card_schema_foundation_only"
$script:R18RequiredCardFileMap = [ordered]@{
    agent_orchestrator = "agent_orchestrator.card.json"
    agent_project_manager = "agent_project_manager.card.json"
    agent_solution_architect = "agent_solution_architect.card.json"
    agent_developer_codex = "agent_developer_codex.card.json"
    agent_qa_test = "agent_qa_test.card.json"
    agent_evidence_auditor = "agent_evidence_auditor.card.json"
    agent_release_manager = "agent_release_manager.card.json"
}
$script:R18RequiredCardFields = @(
    "artifact_type",
    "contract_version",
    "card_id",
    "agent_id",
    "agent_name",
    "role",
    "role_type",
    "source_task",
    "source_milestone",
    "authority_scope",
    "allowed_skills",
    "forbidden_actions",
    "required_inputs",
    "required_outputs",
    "memory_refs",
    "evidence_obligations",
    "handoff_rules",
    "retry_failover_behavior",
    "approval_gates",
    "allowed_paths",
    "forbidden_paths",
    "runtime_flags",
    "non_claims",
    "rejected_claims",
    "evidence_refs",
    "authority_refs"
)
$script:R18RuntimeFlagFields = @(
    "live_agent_runtime_invoked",
    "live_a2a_runtime_implemented",
    "live_recovery_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_003_completed",
    "main_merge_claimed"
)
$script:R18AllowedPositiveClaims = @(
    "r18_agent_card_schema_created",
    "r18_seed_agent_cards_created",
    "r18_agent_card_validator_created",
    "r18_agent_card_fixtures_created",
    "r18_agent_card_proof_review_created"
)
$script:R18AllowedSkillIdentifiers = @(
    "inspect_repo_refs",
    "define_work_order",
    "define_schema",
    "generate_bounded_artifacts",
    "run_validator",
    "classify_failure",
    "classify_wip",
    "verify_remote_branch",
    "generate_continuation_packet",
    "generate_new_context_prompt",
    "update_status_docs",
    "generate_evidence_package",
    "stage_commit_push_gate",
    "request_operator_approval"
)
$script:R18ForbiddenSkillIdentifiers = @("*", "all", "any", "unbounded")

function Get-R18AgentCardRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18AgentCardPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$RepositoryRoot = (Get-R18AgentCardRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18AgentCardJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18AgentCardJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 100
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Write-R18AgentCardText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R18AgentCardObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18AgentCardSchemaPaths {
    param(
        [string]$RepositoryRoot = (Get-R18AgentCardRepositoryRoot)
    )

    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_002_agent_card_schema"
    $fixtureRoot = "tests/fixtures/r18_agent_card_schema"
    $cardRoot = "state/agents/r18_agent_cards"

    $cardFiles = [ordered]@{}
    foreach ($entry in $script:R18RequiredCardFileMap.GetEnumerator()) {
        $cardFiles[$entry.Key] = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $cardRoot $entry.Value)
    }

    return [pscustomobject]@{
        Contract = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/agents/r18_agent_card.contract.json"
        CardRoot = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue $cardRoot
        CardFiles = $cardFiles
        CheckReport = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_card_check_report.json"
        UiSnapshot = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_agent_card_snapshot.json"
        Module = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18AgentCardSchema.psm1"
        Generator = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_agent_card_schema.ps1"
        Validator = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_agent_card_schema.ps1"
        Test = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_agent_card_schema.ps1"
        FixtureRoot = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18AgentCardPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
    }
}

function Get-R18AgentCardAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/agents/r17_agent_identity_packet.contract.json"
    )
}

function Get-R18AgentCardMemoryRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "state/governance/r18_opening_authority.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/agents/r17_agent_identity_packet.contract.json"
    )
}

function Get-R18AgentCardEvidenceRefs {
    return @(
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "state/agents/r18_agent_card_check_report.json",
        "state/ui/r18_operator_surface/r18_agent_card_snapshot.json",
        "tools/R18AgentCardSchema.psm1",
        "tools/new_r18_agent_card_schema.ps1",
        "tools/validate_r18_agent_card_schema.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tests/fixtures/r18_agent_card_schema/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_002_agent_card_schema/"
    )
}

function Get-R18AgentCardAllowedPaths {
    return @(
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "state/agents/r18_agent_card_check_report.json",
        "state/ui/r18_operator_surface/r18_agent_card_snapshot.json",
        "tools/R18AgentCardSchema.psm1",
        "tools/new_r18_agent_card_schema.ps1",
        "tools/validate_r18_agent_card_schema.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tests/fixtures/r18_agent_card_schema/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_002_agent_card_schema/",
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
        "tests/test_r18_opening_authority.ps1"
    )
}

function Get-R18AgentCardForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_*",
        "state/proof_reviews/r14_*",
        "state/proof_reviews/r15_*",
        "state/proof_reviews/r16_*",
        "state/external_runs/",
        "main branch",
        "repository root broad write"
    )
}

function Get-R18AgentCardRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18AgentCardNonClaims {
    return @(
        "R18-002 creates agent card schema and seed cards only.",
        "Agent cards are governance/runtime contracts only; they are not live agents.",
        "No skills are implemented by R18-002.",
        "No live A2A runtime is implemented by R18-002.",
        "No live recovery runtime is implemented by R18-002.",
        "No OpenAI API invocation occurred.",
        "No Codex API invocation occurred.",
        "No autonomous Codex invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "R18-003 through R18-028 remain planned only.",
        "Main is not merged."
    )
}

function Get-R18AgentCardRejectedClaims {
    return @(
        "wildcard_skill_permission",
        "unbounded_skill_permission",
        "live_agent_runtime",
        "live_a2a_runtime",
        "live_recovery_runtime",
        "openai_api_invocation",
        "codex_api_invocation",
        "autonomous_codex_invocation",
        "automatic_new_thread_creation",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_003_completion",
        "main_merge",
        "historical_evidence_edit",
        "operator_local_backup_path_use",
        "broad_repo_write"
    )
}

function New-R18AgentCardAuthorityScope {
    param(
        [Parameter(Mandatory = $true)][string]$Summary,
        [Parameter(Mandatory = $true)][string[]]$Boundaries
    )

    return [ordered]@{
        summary = $Summary
        role_contract_only = $true
        live_runtime_authority = $false
        direct_api_authority = $false
        broad_repo_write_authority = $false
        historical_evidence_edit_authority = $false
        source_authority_refs = (Get-R18AgentCardAuthorityRefs)
        boundaries = $Boundaries
    }
}

function New-R18AgentCardHandoffRules {
    param(
        [Parameter(Mandatory = $true)][string[]]$AllowedTargets
    )

    return [ordered]@{
        can_prepare_handoff_contract = $true
        allowed_target_agents = $AllowedTargets
        executable_handoff_allowed = $false
        live_dispatch_allowed = $false
        target_must_validate_card = $true
        missing_target_authority_blocks_handoff = $true
        later_task_required_for_execution = $true
    }
}

function New-R18AgentCardRetryFailoverBehavior {
    return [ordered]@{
        behavior_status = "planned_contract_only_not_runtime"
        automatic_retry_allowed = $false
        automatic_failover_allowed = $false
        retry_limit_before_operator_review = 0
        failure_packet_required = $true
        unsafe_wip_blocks_retry = $true
        remote_branch_movement_blocks_retry = $true
        unknown_failure_requires_operator_decision = $true
    }
}

function New-R18AgentCardApprovalGates {
    param(
        [string[]]$AdditionalRequiredGates = @()
    )

    return [ordered]@{
        operator_approval_required_for = @(
            "api_enablement",
            "autonomous_codex_invocation",
            "automatic_new_thread_creation",
            "unsafe_wip_abandonment",
            "stage_commit_push",
            "main_merge",
            "milestone_closeout",
            "external_audit_acceptance",
            "historical_evidence_edit_attempt"
        ) + $AdditionalRequiredGates | Select-Object -Unique
        qa_self_approval_allowed = $false
        audit_self_approval_allowed = $false
        bypass_gate_allowed = $false
        missing_approval_blocks_action = $true
    }
}

function New-R18AgentCard {
    param(
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$AgentName,
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$RoleType,
        [Parameter(Mandatory = $true)][string]$AuthoritySummary,
        [Parameter(Mandatory = $true)][string[]]$AuthorityBoundaries,
        [Parameter(Mandatory = $true)][string[]]$AllowedSkills,
        [Parameter(Mandatory = $true)][string[]]$ForbiddenActions,
        [Parameter(Mandatory = $true)][string[]]$RequiredInputs,
        [Parameter(Mandatory = $true)][string[]]$RequiredOutputs,
        [Parameter(Mandatory = $true)][string[]]$HandoffTargets,
        [string[]]$AdditionalApprovalGates = @()
    )

    return [ordered]@{
        artifact_type = "r18_agent_card"
        contract_version = "v1"
        card_id = ("aioffice-r18-002-{0}-card-v1" -f $AgentId)
        agent_id = $AgentId
        agent_name = $AgentName
        role = $Role
        role_type = $RoleType
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18AgentCardGeneratedFromHead
        generated_from_tree = $script:R18AgentCardGeneratedFromTree
        generated_state_artifact_only = $true
        authority_scope = (New-R18AgentCardAuthorityScope -Summary $AuthoritySummary -Boundaries $AuthorityBoundaries)
        allowed_skills = $AllowedSkills
        allowed_skill_status = "planned_identifiers_only_not_implemented"
        forbidden_actions = $ForbiddenActions
        required_inputs = $RequiredInputs
        required_outputs = $RequiredOutputs
        memory_refs = (Get-R18AgentCardMemoryRefs)
        evidence_obligations = @(
            "cite exact authority refs before action",
            "record validator command and result refs for claimed validation",
            "record non-claims with every proof packet",
            "preserve rejected claims when packaging evidence",
            "treat generated markdown as insufficient proof unless backed by machine-readable artifacts"
        )
        handoff_rules = (New-R18AgentCardHandoffRules -AllowedTargets $HandoffTargets)
        retry_failover_behavior = (New-R18AgentCardRetryFailoverBehavior)
        approval_gates = (New-R18AgentCardApprovalGates -AdditionalRequiredGates $AdditionalApprovalGates)
        allowed_paths = (Get-R18AgentCardAllowedPaths)
        forbidden_paths = (Get-R18AgentCardForbiddenPaths)
        runtime_flags = (Get-R18AgentCardRuntimeFlags)
        positive_claims = (Get-R18AllowedPositiveClaimsForCards)
        non_claims = (Get-R18AgentCardNonClaims)
        rejected_claims = (Get-R18AgentCardRejectedClaims)
        evidence_refs = (Get-R18AgentCardEvidenceRefs)
        authority_refs = (Get-R18AgentCardAuthorityRefs)
    }
}

function Get-R18AllowedPositiveClaimsForCards {
    return @($script:R18AllowedPositiveClaims)
}

function Get-R18AgentCards {
    $commonForbidden = @(
        "modify_historical_evidence",
        "use_operator_local_backup_path",
        "permit_broad_repo_write",
        "claim_live_runtime",
        "claim_r18_003_or_later_completion",
        "invoke_openai_api",
        "invoke_codex_api"
    )

    return @(
        (New-R18AgentCard `
            -AgentId "agent_orchestrator" `
            -AgentName "Agent Orchestrator" `
            -Role "Orchestrator" `
            -RoleType "coordination_and_routing_contract" `
            -AuthoritySummary "Coordinates intake, routing, board/work-order state, handoffs, recovery, and operator decision gates as a contract only." `
            -AuthorityBoundaries @("no direct implementation", "no direct API invocation", "no QA bypass", "no audit bypass", "no approval bypass", "no autonomous execution claim") `
            -AllowedSkills @("inspect_repo_refs", "define_work_order", "classify_wip", "verify_remote_branch", "generate_continuation_packet", "generate_new_context_prompt", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("direct_implementation", "direct_api_invocation", "bypass_qa", "bypass_audit", "bypass_approvals", "claim_autonomous_execution")) `
            -RequiredInputs @("operator_intent", "active_work_order_ref", "authority_refs", "board_or_work_order_state_ref", "validation_expectations") `
            -RequiredOutputs @("routing_recommendation_packet", "handoff_contract_candidate", "approval_gate_packet", "recovery_or_escalation_recommendation") `
            -HandoffTargets @("agent_project_manager", "agent_solution_architect", "agent_developer_codex", "agent_qa_test", "agent_evidence_auditor", "agent_release_manager"))
        (New-R18AgentCard `
            -AgentId "agent_project_manager" `
            -AgentName "Agent Project Manager" `
            -Role "Project Manager" `
            -RoleType "planning_scope_and_acceptance_contract" `
            -AuthoritySummary "Defines work order scope, acceptance criteria, dependencies, status, operator decision points, and release readiness as a contract only." `
            -AuthorityBoundaries @("no code implementation", "no direct runtime execution", "no QA self-approval", "no audit self-approval") `
            -AllowedSkills @("inspect_repo_refs", "define_work_order", "classify_wip", "update_status_docs", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("code_implementation", "direct_runtime_execution", "qa_self_approval", "audit_self_approval")) `
            -RequiredInputs @("operator_scope_ref", "authority_refs", "dependency_refs", "acceptance_boundary", "validation_expectations") `
            -RequiredOutputs @("work_order_scope_packet", "acceptance_criteria_packet", "dependency_status_packet", "operator_decision_point_packet") `
            -HandoffTargets @("agent_orchestrator", "agent_solution_architect", "agent_developer_codex", "agent_qa_test", "agent_evidence_auditor", "agent_release_manager"))
        (New-R18AgentCard `
            -AgentId "agent_solution_architect" `
            -AgentName "Agent Solution Architect" `
            -Role "Solution Architect" `
            -RoleType "schema_interface_and_boundary_contract" `
            -AuthoritySummary "Defines design constraints, schemas, interfaces, role boundaries, authority, and technical acceptance criteria as a contract only." `
            -AuthorityBoundaries @("no implementation without Developer handoff", "no QA approval of own design", "no audit approval of own design") `
            -AllowedSkills @("inspect_repo_refs", "define_schema", "define_work_order", "classify_failure", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("implement_without_developer_handoff", "approve_own_design_as_qa", "approve_own_design_as_audit")) `
            -RequiredInputs @("work_order_scope_packet", "authority_refs", "existing_contract_refs", "technical_boundary_refs", "validation_expectations") `
            -RequiredOutputs @("schema_or_interface_design_packet", "technical_acceptance_criteria_packet", "role_boundary_update_candidate", "developer_handoff_packet") `
            -HandoffTargets @("agent_orchestrator", "agent_project_manager", "agent_developer_codex", "agent_qa_test", "agent_evidence_auditor"))
        (New-R18AgentCard `
            -AgentId "agent_developer_codex" `
            -AgentName "Agent Developer/Codex" `
            -Role "Developer/Codex" `
            -RoleType "bounded_implementation_contract" `
            -AuthoritySummary "Performs bounded implementation only after valid work order, authority refs, allowed paths, and validation expectations exist." `
            -AuthorityBoundaries @("no broad repo rewrites", "no historical evidence edits", "no unsafe backup paths", "no unapproved API invocation", "no validation bypass", "no live runtime claim without evidence") `
            -AllowedSkills @("inspect_repo_refs", "generate_bounded_artifacts", "run_validator", "classify_failure", "classify_wip", "update_status_docs") `
            -ForbiddenActions @($commonForbidden + @("broad_repo_rewrite", "historical_evidence_edit", "unsafe_backup_path_use", "unapproved_api_invocation", "bypass_validation", "claim_live_runtime_without_evidence")) `
            -RequiredInputs @("valid_work_order_ref", "authority_refs", "allowed_paths", "forbidden_paths", "validation_expectations") `
            -RequiredOutputs @("bounded_diff_summary", "generated_artifact_refs", "validator_result_refs", "implementation_non_claims_packet") `
            -HandoffTargets @("agent_orchestrator", "agent_project_manager", "agent_qa_test", "agent_evidence_auditor", "agent_release_manager"))
        (New-R18AgentCard `
            -AgentId "agent_qa_test" `
            -AgentName "Agent QA/Test" `
            -Role "QA/Test" `
            -RoleType "validation_and_defect_contract" `
            -AuthoritySummary "Runs validation, checks fixtures, defects, regression scope, and failure packets as a contract only." `
            -AuthorityBoundaries @("no implementation fixes unless explicitly handed off", "no audit self-approval", "no release acceptance claim") `
            -AllowedSkills @("inspect_repo_refs", "run_validator", "classify_failure", "generate_evidence_package", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("implement_fixes_without_explicit_handoff", "audit_self_approval", "release_acceptance_claim")) `
            -RequiredInputs @("validator_command_refs", "fixture_manifest_ref", "work_order_scope_packet", "expected_runtime_flags", "acceptance_criteria_packet") `
            -RequiredOutputs @("validation_result_packet", "fixture_coverage_packet", "defect_packet", "regression_scope_packet", "failure_packet_if_needed") `
            -HandoffTargets @("agent_orchestrator", "agent_project_manager", "agent_developer_codex", "agent_evidence_auditor", "agent_release_manager"))
        (New-R18AgentCard `
            -AgentId "agent_evidence_auditor" `
            -AgentName "Agent Evidence Auditor" `
            -Role "Evidence Auditor" `
            -RoleType "evidence_boundary_and_overclaim_contract" `
            -AuthoritySummary "Reviews committed evidence, validators, non-claims, acceptance boundaries, overclaims, and proof packages as a contract only." `
            -AuthorityBoundaries @("no implementation evidence creation", "no fabricated runtime proof", "no milestone closeout without operator decision") `
            -AllowedSkills @("inspect_repo_refs", "classify_failure", "generate_evidence_package", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("create_implementation_evidence", "fabricate_runtime_proof", "close_milestone_without_operator_decision")) `
            -RequiredInputs @("committed_evidence_refs", "validator_result_refs", "non_claims_packet", "rejected_claims_packet", "acceptance_boundary_refs") `
            -RequiredOutputs @("evidence_sufficiency_review", "overclaim_report", "proof_package_review", "residual_risk_packet") `
            -HandoffTargets @("agent_orchestrator", "agent_project_manager", "agent_developer_codex", "agent_qa_test", "agent_release_manager"))
        (New-R18AgentCard `
            -AgentId "agent_release_manager" `
            -AgentName "Agent Release Manager" `
            -Role "Release Manager" `
            -RoleType "stage_commit_push_gate_contract" `
            -AuthoritySummary "Controls stage/commit/push gates, release evidence, final-head support, and status-doc synchronization as a contract only." `
            -AuthorityBoundaries @("no main merge", "no closeout without operator approval", "no external audit acceptance claim without explicit operator approval and evidence") `
            -AllowedSkills @("inspect_repo_refs", "verify_remote_branch", "run_validator", "update_status_docs", "generate_evidence_package", "stage_commit_push_gate", "request_operator_approval") `
            -ForbiddenActions @($commonForbidden + @("merge_main", "closeout_without_operator_approval", "external_audit_acceptance_without_evidence", "external_audit_acceptance_without_operator_approval")) `
            -RequiredInputs @("passed_validator_refs", "git_status_ref", "diff_check_ref", "status_doc_gate_ref", "operator_approval_ref_if_required") `
            -RequiredOutputs @("stage_gate_report", "commit_readiness_packet", "push_readiness_packet", "final_head_support_candidate", "release_non_claims_packet") `
            -HandoffTargets @("agent_orchestrator", "agent_project_manager", "agent_qa_test", "agent_evidence_auditor") `
            -AdditionalApprovalGates @("release_push"))
    )
}

function New-R18AgentCardContract {
    return [ordered]@{
        artifact_type = "r18_agent_card_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-002-agent-card-contract-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "agent_card_schema_and_seed_card_contracts_only_not_live_agents"
        purpose = "Define enforceable R18 agent cards for role identity, authority, planned skills, evidence duties, handoff rules, retry/failover behavior, approval gates, and hard runtime non-claims."
        required_card_ids = @($script:R18RequiredCardFileMap.Keys)
        required_card_fields = $script:R18RequiredCardFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        allowed_skill_identifiers = $script:R18AllowedSkillIdentifiers
        forbidden_skill_identifiers = $script:R18ForbiddenSkillIdentifiers
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        required_non_claims = (Get-R18AgentCardNonClaims)
        rejected_claims = (Get-R18AgentCardRejectedClaims)
        path_policy = [ordered]@{
            allowed_paths_must_be_exact_or_task_scoped = $true
            broad_repo_writes_allowed = $false
            operator_local_backup_paths_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
        }
        role_boundary_rules = @(
            "Orchestrator coordinates but cannot implement, invoke APIs, bypass QA/audit/approval, alter historical evidence, or claim autonomous execution.",
            "Project Manager defines scope and readiness but cannot implement, execute runtime, or self-approve QA/audit.",
            "Solution Architect defines schemas and boundaries but cannot implement without Developer handoff or approve own design as QA/audit.",
            "Developer/Codex implements only bounded artifacts after valid work order, authority refs, allowed paths, and validation expectations exist.",
            "QA/Test validates and reports defects but cannot implement fixes unless explicitly handed off or self-approve audit.",
            "Evidence Auditor reviews evidence and overclaims but cannot create implementation evidence, fabricate runtime proof, or close milestones without operator decision.",
            "Release Manager controls stage/commit/push gates but cannot merge main, close out, or claim external audit acceptance without explicit operator approval and evidence."
        )
        evidence_refs = (Get-R18AgentCardEvidenceRefs)
        authority_refs = (Get-R18AgentCardAuthorityRefs)
        non_claims = (Get-R18AgentCardNonClaims)
    }
}

function New-R18AgentCardCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Cards
    )

    return [ordered]@{
        artifact_type = "r18_agent_card_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-002-agent-card-check-report-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18AgentCardGeneratedFromHead
        generated_from_tree = $script:R18AgentCardGeneratedFromTree
        generated_state_artifact_only = $true
        required_card_count = @($script:R18RequiredCardFileMap.Keys).Count
        generated_card_count = @($Cards).Count
        card_ids = @($Cards | ForEach-Object { $_.agent_id })
        checks = [ordered]@{
            required_cards_present = [ordered]@{ status = "passed" }
            required_fields_present = [ordered]@{ status = "passed" }
            wildcard_skills_rejected = [ordered]@{ status = "passed"; wildcard_skills_allowed = $false }
            authority_scope_present = [ordered]@{ status = "passed" }
            forbidden_actions_present = [ordered]@{ status = "passed" }
            required_inputs_outputs_present = [ordered]@{ status = "passed" }
            memory_refs_present = [ordered]@{ status = "passed" }
            evidence_obligations_present = [ordered]@{ status = "passed" }
            handoff_rules_present = [ordered]@{ status = "passed" }
            retry_failover_behavior_present = [ordered]@{ status = "passed" }
            approval_gates_present = [ordered]@{ status = "passed" }
            runtime_flags_false = [ordered]@{ status = "passed" }
            broad_repo_writes_rejected = [ordered]@{ status = "passed"; broad_repo_writes_allowed = $false }
            historical_evidence_edits_rejected = [ordered]@{ status = "passed"; historical_evidence_edits_allowed = $false }
            operator_local_backup_paths_rejected = [ordered]@{ status = "passed"; operator_local_backup_paths_allowed = $false }
            r18_003_or_later_completion_rejected = [ordered]@{ status = "passed"; r18_003_completed = $false }
        }
        aggregate_verdict = $script:R18AgentCardVerdict
        runtime_flags = (Get-R18AgentCardRuntimeFlags)
        positive_claims = (Get-R18AllowedPositiveClaimsForCards)
        non_claims = (Get-R18AgentCardNonClaims)
        rejected_claims = (Get-R18AgentCardRejectedClaims)
        evidence_refs = (Get-R18AgentCardEvidenceRefs)
        authority_refs = (Get-R18AgentCardAuthorityRefs)
    }
}

function New-R18AgentCardSnapshot {
    param(
        [Parameter(Mandatory = $true)][object[]]$Cards
    )

    return [ordered]@{
        artifact_type = "r18_agent_card_snapshot"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        active_through_task = "R18-002"
        ui_boundary_label = "Agent cards are governance contracts only, not live agents"
        required_card_count = @($script:R18RequiredCardFileMap.Keys).Count
        generated_card_count = @($Cards).Count
        cards = @($Cards | ForEach-Object {
                [ordered]@{
                    agent_id = $_.agent_id
                    agent_name = $_.agent_name
                    role = $_.role
                    role_type = $_.role_type
                    planned_skill_count = @($_.allowed_skills).Count
                    runtime_enabled = $false
                    live_agent_runtime_invoked = [bool]$_.runtime_flags.live_agent_runtime_invoked
                    openai_api_invoked = [bool]$_.runtime_flags.openai_api_invoked
                    codex_api_invoked = [bool]$_.runtime_flags.codex_api_invoked
                    r18_003_completed = [bool]$_.runtime_flags.r18_003_completed
                }
            })
        runtime_summary = (Get-R18AgentCardRuntimeFlags)
        positive_claims = (Get-R18AllowedPositiveClaimsForCards)
        non_claims = (Get-R18AgentCardNonClaims)
        rejected_claims = (Get-R18AgentCardRejectedClaims)
        evidence_refs = (Get-R18AgentCardEvidenceRefs)
        authority_refs = (Get-R18AgentCardAuthorityRefs)
    }
}

function Get-R18AgentCardFixtureDefinitions {
    return [ordered]@{
        "invalid_missing_authority.json" = [ordered]@{
            target = "card:agent_orchestrator"
            remove_paths = @("authority_scope")
            expected_failure_fragments = @("authority_scope")
        }
        "invalid_wildcard_skill_permission.json" = [ordered]@{
            target = "card:agent_developer_codex"
            set_values = [ordered]@{ allowed_skills = @("*") }
            expected_failure_fragments = @("wildcard or unbounded skill")
        }
        "invalid_missing_forbidden_actions.json" = [ordered]@{
            target = "card:agent_project_manager"
            remove_paths = @("forbidden_actions")
            expected_failure_fragments = @("forbidden_actions")
        }
        "invalid_missing_required_inputs.json" = [ordered]@{
            target = "card:agent_solution_architect"
            remove_paths = @("required_inputs")
            expected_failure_fragments = @("required_inputs")
        }
        "invalid_missing_required_outputs.json" = [ordered]@{
            target = "card:agent_developer_codex"
            remove_paths = @("required_outputs")
            expected_failure_fragments = @("required_outputs")
        }
        "invalid_missing_memory_refs.json" = [ordered]@{
            target = "card:agent_qa_test"
            remove_paths = @("memory_refs")
            expected_failure_fragments = @("memory_refs")
        }
        "invalid_missing_evidence_obligations.json" = [ordered]@{
            target = "card:agent_evidence_auditor"
            remove_paths = @("evidence_obligations")
            expected_failure_fragments = @("evidence_obligations")
        }
        "invalid_missing_handoff_rules.json" = [ordered]@{
            target = "card:agent_release_manager"
            remove_paths = @("handoff_rules")
            expected_failure_fragments = @("handoff_rules")
        }
        "invalid_missing_retry_failover_behavior.json" = [ordered]@{
            target = "card:agent_orchestrator"
            remove_paths = @("retry_failover_behavior")
            expected_failure_fragments = @("retry_failover_behavior")
        }
        "invalid_missing_approval_gates.json" = [ordered]@{
            target = "card:agent_project_manager"
            remove_paths = @("approval_gates")
            expected_failure_fragments = @("approval_gates")
        }
        "invalid_live_agent_claim.json" = [ordered]@{
            target = "card:agent_orchestrator"
            set_values = [ordered]@{ "runtime_flags.live_agent_runtime_invoked" = $true }
            expected_failure_fragments = @("live_agent_runtime_invoked")
        }
        "invalid_api_invocation_claim.json" = [ordered]@{
            target = "card:agent_developer_codex"
            set_values = [ordered]@{ "runtime_flags.openai_api_invoked" = $true }
            expected_failure_fragments = @("openai_api_invoked")
        }
        "invalid_r18_003_completion_claim.json" = [ordered]@{
            target = "card:agent_release_manager"
            set_values = [ordered]@{ "runtime_flags.r18_003_completed" = $true }
            expected_failure_fragments = @("r18_003_completed")
        }
    }
}

function New-R18AgentCardFixtureManifest {
    $fixtureDefinitions = Get-R18AgentCardFixtureDefinitions
    return [ordered]@{
        artifact_type = "r18_agent_card_schema_fixture_manifest"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        fixture_style = "compact_mutation_specs_applied_to_valid_seed_cards"
        fixture_count = @($fixtureDefinitions.Keys).Count
        fixture_files = @($fixtureDefinitions.Keys)
        non_claims = (Get-R18AgentCardNonClaims)
    }
}

function New-R18AgentCardEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_agent_card_schema_evidence_index"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        evidence_scope = "schema_seed_cards_validator_fixtures_status_only"
        entries = @(
            [ordered]@{ path = "contracts/agents/r18_agent_card.contract.json"; evidence_type = "contract" },
            [ordered]@{ path = "state/agents/r18_agent_cards/"; evidence_type = "seed_agent_cards" },
            [ordered]@{ path = "state/agents/r18_agent_card_check_report.json"; evidence_type = "check_report" },
            [ordered]@{ path = "state/ui/r18_operator_surface/r18_agent_card_snapshot.json"; evidence_type = "operator_surface_snapshot_state_only" },
            [ordered]@{ path = "tools/R18AgentCardSchema.psm1"; evidence_type = "validator_generator_module" },
            [ordered]@{ path = "tools/new_r18_agent_card_schema.ps1"; evidence_type = "generator_wrapper" },
            [ordered]@{ path = "tools/validate_r18_agent_card_schema.ps1"; evidence_type = "validator_wrapper" },
            [ordered]@{ path = "tests/test_r18_agent_card_schema.ps1"; evidence_type = "focused_tests" },
            [ordered]@{ path = "tests/fixtures/r18_agent_card_schema/"; evidence_type = "invalid_fixtures" },
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_002_agent_card_schema/proof_review.md"; evidence_type = "proof_review" },
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_002_agent_card_schema/validation_manifest.md"; evidence_type = "validation_manifest" }
        )
        positive_claims = (Get-R18AllowedPositiveClaimsForCards)
        non_claims = (Get-R18AgentCardNonClaims)
        rejected_claims = (Get-R18AgentCardRejectedClaims)
        authority_refs = (Get-R18AgentCardAuthorityRefs)
    }
}

function New-R18AgentCardProofReviewText {
    return @"
# R18-002 Agent Card Schema Proof Review

Status: R18-002 creates the agent card contract, seven seed cards, validator, invalid fixtures, check report, operator-surface snapshot state artifact, and this proof-review package only.

Evidence reviewed:

- `contracts/agents/r18_agent_card.contract.json`
- `state/agents/r18_agent_cards/`
- `state/agents/r18_agent_card_check_report.json`
- `state/ui/r18_operator_surface/r18_agent_card_snapshot.json`
- `tools/R18AgentCardSchema.psm1`
- `tools/new_r18_agent_card_schema.ps1`
- `tools/validate_r18_agent_card_schema.ps1`
- `tests/test_r18_agent_card_schema.ps1`
- `tests/fixtures/r18_agent_card_schema/`

Boundary:

- Agent cards are governance/runtime contracts only, not live agents.
- Allowed skills are planned identifiers only; no skill contracts or executable skills are implemented.
- No live A2A runtime, live recovery runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, automatic new-thread creation, product runtime, main merge, solved Codex compaction, solved Codex reliability, or no-manual-prompt-transfer success is claimed.
- R18 remains active through R18-002 only; R18-003 through R18-028 remain planned only.
"@
}

function New-R18AgentCardValidationManifestText {
    return @"
# R18-002 Agent Card Schema Validation Manifest

Required validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

Expected result: all commands pass before R18-002 is committed and pushed.

Non-claims: this manifest is not runtime proof, not skill implementation proof, not A2A runtime proof, not recovery runtime proof, not API invocation proof, and not main-merge proof.
"@
}

function New-R18AgentCardSchemaArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R18AgentCardRepositoryRoot)
    )

    $paths = Get-R18AgentCardSchemaPaths -RepositoryRoot $RepositoryRoot
    $cards = @(Get-R18AgentCards)
    $contract = New-R18AgentCardContract
    $report = New-R18AgentCardCheckReport -Cards $cards
    $snapshot = New-R18AgentCardSnapshot -Cards $cards

    Write-R18AgentCardJson -Path $paths.Contract -Value $contract
    foreach ($card in $cards) {
        $path = $paths.CardFiles[[string]$card.agent_id]
        if ([string]::IsNullOrWhiteSpace($path)) {
            throw "No card file path configured for '$($card.agent_id)'."
        }
        Write-R18AgentCardJson -Path $path -Value $card
    }
    Write-R18AgentCardJson -Path $paths.CheckReport -Value $report
    Write-R18AgentCardJson -Path $paths.UiSnapshot -Value $snapshot

    Write-R18AgentCardJson -Path $paths.FixtureManifest -Value (New-R18AgentCardFixtureManifest)
    $fixtureDefinitions = Get-R18AgentCardFixtureDefinitions
    foreach ($entry in $fixtureDefinitions.GetEnumerator()) {
        Write-R18AgentCardJson -Path (Join-Path $paths.FixtureRoot $entry.Key) -Value $entry.Value
    }

    Write-R18AgentCardJson -Path $paths.EvidenceIndex -Value (New-R18AgentCardEvidenceIndex)
    Write-R18AgentCardText -Path $paths.ProofReview -Value (New-R18AgentCardProofReviewText)
    Write-R18AgentCardText -Path $paths.ValidationManifest -Value (New-R18AgentCardValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        CardRoot = $paths.CardRoot
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredCardCount = @($script:R18RequiredCardFileMap.Keys).Count
        GeneratedCardCount = @($cards).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

function Assert-R18AgentCardCondition {
    param(
        [bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18AgentCardRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18AgentCardCondition -Condition ($null -ne $Object.PSObject.Properties[$field]) -Message "$Context is missing required field '$field'."
        $value = $Object.PSObject.Properties[$field].Value
        if ($null -eq $value) {
            throw "$Context required field '$field' is null."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context required field '$field' is blank."
        }
    }
}

function Assert-R18AgentCardNonEmptyArray {
    param(
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        throw "$Context is missing."
    }
    if (@($Value).Count -eq 0) {
        throw "$Context must not be empty."
    }
    foreach ($item in @($Value)) {
        if ([string]::IsNullOrWhiteSpace([string]$item)) {
            throw "$Context contains a blank value."
        }
    }
}

function Assert-R18AgentCardNonEmptyObject {
    param(
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        throw "$Context is missing."
    }
    if (@($Value.PSObject.Properties).Count -eq 0) {
        throw "$Context must not be empty."
    }
}

function Assert-R18AgentCardFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18AgentCardCondition -Condition ($null -ne $Object.PSObject.Properties[$field]) -Message "$Context is missing required false field '$field'."
        Assert-R18AgentCardCondition -Condition ([bool]$Object.PSObject.Properties[$field].Value -eq $false) -Message "$Context claims $field."
    }
}

function Assert-R18AgentCardAllowedPaths {
    param(
        [Parameter(Mandatory = $true)][object]$Card
    )

    Assert-R18AgentCardNonEmptyArray -Value $Card.allowed_paths -Context "$($Card.agent_id) allowed_paths"
    foreach ($path in @($Card.allowed_paths)) {
        $normalized = ([string]$path).Replace("\", "/").Trim()
        if ([string]::IsNullOrWhiteSpace($normalized)) {
            throw "$($Card.agent_id) allowed_paths contains a blank path."
        }
        if (@(".", "./", "/", "*", "**", "repo", "repo_root", "repository_root", "root") -contains $normalized.ToLowerInvariant()) {
            throw "$($Card.agent_id) permits broad repo writes through allowed path '$normalized'."
        }
        if ($normalized -match '^(contracts|governance|state|tools|tests|execution)/?$') {
            throw "$($Card.agent_id) permits broad repo writes through allowed path '$normalized'."
        }
        if ($normalized -match '^\*' -or $normalized -match '\*\*$') {
            throw "$($Card.agent_id) permits broad repo writes through wildcard path '$normalized'."
        }
        if ($normalized -match '^\.local_backups/' -or $normalized -match '(?i)operator[-_ ]local') {
            throw "$($Card.agent_id) permits operator-local backup path '$normalized'."
        }
        if ($normalized -match '^state/proof_reviews/r1[3-6]' -or $normalized -match '^state/.*/r1[3-6]_' -or $normalized -match '^governance/R1[3-6]_') {
            throw "$($Card.agent_id) permits historical evidence edits through '$normalized'."
        }
    }

    Assert-R18AgentCardNonEmptyArray -Value $Card.forbidden_paths -Context "$($Card.agent_id) forbidden_paths"
    $forbiddenText = (@($Card.forbidden_paths) -join " ").ToLowerInvariant()
    foreach ($requiredFragment in @(".local_backups", "operator-local", "r13", "r14", "r15", "r16")) {
        if ($forbiddenText -notmatch [regex]::Escape($requiredFragment)) {
            throw "$($Card.agent_id) forbidden_paths must preserve '$requiredFragment'."
        }
    }
}

function Assert-R18AgentCardSkills {
    param(
        [Parameter(Mandatory = $true)][object]$Card
    )

    Assert-R18AgentCardNonEmptyArray -Value $Card.allowed_skills -Context "$($Card.agent_id) allowed_skills"
    foreach ($skill in @($Card.allowed_skills)) {
        $skillValue = ([string]$skill).Trim()
        $lowerSkill = $skillValue.ToLowerInvariant()
        if ($script:R18ForbiddenSkillIdentifiers -contains $lowerSkill -or $skillValue -match '\*') {
            throw "$($Card.agent_id) contains wildcard or unbounded skill permission '$skillValue'."
        }
        if ($script:R18AllowedSkillIdentifiers -notcontains $skillValue) {
            throw "$($Card.agent_id) contains unrecognized planned skill identifier '$skillValue'."
        }
    }
}

function Assert-R18AgentCardClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Card
    )

    Assert-R18AgentCardFalseFields -Object $Card.runtime_flags -FieldNames $script:R18RuntimeFlagFields -Context "$($Card.agent_id) runtime_flags"
    if ([bool]$Card.runtime_flags.live_agent_runtime_invoked) { throw "$($Card.agent_id) claims live agent runtime." }
    if ([bool]$Card.runtime_flags.live_a2a_runtime_implemented) { throw "$($Card.agent_id) claims live A2A runtime." }
    if ([bool]$Card.runtime_flags.live_recovery_runtime_implemented) { throw "$($Card.agent_id) claims live recovery runtime." }
    if ([bool]$Card.runtime_flags.openai_api_invoked) { throw "$($Card.agent_id) claims OpenAI API invocation." }
    if ([bool]$Card.runtime_flags.codex_api_invoked) { throw "$($Card.agent_id) claims Codex API invocation." }
    if ([bool]$Card.runtime_flags.autonomous_codex_invocation_performed) { throw "$($Card.agent_id) claims autonomous Codex invocation." }
    if ([bool]$Card.runtime_flags.automatic_new_thread_creation_performed) { throw "$($Card.agent_id) claims automatic new-thread creation." }
    if ([bool]$Card.runtime_flags.product_runtime_executed) { throw "$($Card.agent_id) claims product runtime." }
    if ([bool]$Card.runtime_flags.no_manual_prompt_transfer_success_claimed) { throw "$($Card.agent_id) claims no-manual-prompt-transfer success." }
    if ([bool]$Card.runtime_flags.solved_codex_compaction_claimed) { throw "$($Card.agent_id) claims solved Codex compaction." }
    if ([bool]$Card.runtime_flags.solved_codex_reliability_claimed) { throw "$($Card.agent_id) claims solved Codex reliability." }
    if ([bool]$Card.runtime_flags.r18_003_completed) { throw "$($Card.agent_id) claims R18-003 or later completion." }
    if ([bool]$Card.runtime_flags.main_merge_claimed) { throw "$($Card.agent_id) claims main merge." }

    if ($null -ne $Card.PSObject.Properties["positive_claims"]) {
        foreach ($claim in @($Card.positive_claims)) {
            if ($script:R18AllowedPositiveClaims -notcontains [string]$claim) {
                throw "$($Card.agent_id) contains unsupported positive claim '$claim'."
            }
        }
    }

    Assert-R18AgentCardNonEmptyArray -Value $Card.non_claims -Context "$($Card.agent_id) non_claims"
    $nonClaimText = @($Card.non_claims) -join " "
    foreach ($required in @("not live agents", "No skills are implemented", "No live A2A runtime", "No live recovery runtime", "No OpenAI API invocation", "No Codex API invocation", "R18-003 through R18-028 remain planned only", "Main is not merged")) {
        if ($nonClaimText -notmatch [regex]::Escape($required)) {
            throw "$($Card.agent_id) non_claims must preserve '$required'."
        }
    }

    Assert-R18AgentCardNonEmptyArray -Value $Card.rejected_claims -Context "$($Card.agent_id) rejected_claims"
    $rejectedText = @($Card.rejected_claims) -join " "
    foreach ($required in @("live_agent_runtime", "openai_api_invocation", "codex_api_invocation", "r18_003_completion", "broad_repo_write")) {
        if ($rejectedText -notmatch [regex]::Escape($required)) {
            throw "$($Card.agent_id) rejected_claims must preserve '$required'."
        }
    }
}

function Assert-R18AgentCardRoleBoundary {
    param(
        [Parameter(Mandatory = $true)][object]$Card
    )

    $forbidden = @($Card.forbidden_actions) -join " "
    switch ([string]$Card.agent_id) {
        "agent_orchestrator" {
            foreach ($required in @("direct_implementation", "direct_api_invocation", "bypass_qa", "bypass_audit", "bypass_approvals", "claim_autonomous_execution")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Orchestrator forbidden_actions must preserve '$required'." }
            }
        }
        "agent_project_manager" {
            foreach ($required in @("code_implementation", "direct_runtime_execution", "qa_self_approval", "audit_self_approval")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Project Manager forbidden_actions must preserve '$required'." }
            }
        }
        "agent_solution_architect" {
            foreach ($required in @("implement_without_developer_handoff", "approve_own_design_as_qa", "approve_own_design_as_audit")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Solution Architect forbidden_actions must preserve '$required'." }
            }
        }
        "agent_developer_codex" {
            foreach ($required in @("broad_repo_rewrite", "historical_evidence_edit", "unsafe_backup_path_use", "unapproved_api_invocation", "bypass_validation", "claim_live_runtime_without_evidence")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Developer/Codex forbidden_actions must preserve '$required'." }
            }
        }
        "agent_qa_test" {
            foreach ($required in @("implement_fixes_without_explicit_handoff", "audit_self_approval")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "QA/Test forbidden_actions must preserve '$required'." }
            }
        }
        "agent_evidence_auditor" {
            foreach ($required in @("create_implementation_evidence", "fabricate_runtime_proof", "close_milestone_without_operator_decision")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Evidence Auditor forbidden_actions must preserve '$required'." }
            }
        }
        "agent_release_manager" {
            foreach ($required in @("merge_main", "closeout_without_operator_approval", "external_audit_acceptance_without_evidence", "external_audit_acceptance_without_operator_approval")) {
                if ($forbidden -notmatch [regex]::Escape($required)) { throw "Release Manager forbidden_actions must preserve '$required'." }
            }
        }
        default {
            throw "Unknown required R18 card agent_id '$($Card.agent_id)'."
        }
    }
}

function Assert-R18AgentCard {
    param(
        [Parameter(Mandatory = $true)][object]$Card
    )

    Assert-R18AgentCardRequiredFields -Object $Card -FieldNames $script:R18RequiredCardFields -Context "agent card"
    Assert-R18AgentCardCondition -Condition ($Card.artifact_type -eq "r18_agent_card") -Message "$($Card.agent_id) artifact_type is invalid."
    Assert-R18AgentCardCondition -Condition ($Card.contract_version -eq "v1") -Message "$($Card.agent_id) contract_version is invalid."
    Assert-R18AgentCardCondition -Condition ($Card.source_task -eq $script:R18SourceTask) -Message "$($Card.agent_id) source_task must be R18-002."
    Assert-R18AgentCardCondition -Condition ($Card.source_milestone -eq $script:R18SourceMilestone) -Message "$($Card.agent_id) source_milestone is invalid."
    Assert-R18AgentCardCondition -Condition ($script:R18RequiredCardFileMap.Contains([string]$Card.agent_id)) -Message "Unexpected R18 card agent_id '$($Card.agent_id)'."

    Assert-R18AgentCardNonEmptyObject -Value $Card.authority_scope -Context "$($Card.agent_id) authority_scope"
    Assert-R18AgentCardNonEmptyArray -Value $Card.forbidden_actions -Context "$($Card.agent_id) forbidden_actions"
    foreach ($requiredForbidden in @("modify_historical_evidence", "use_operator_local_backup_path", "permit_broad_repo_write", "claim_live_runtime", "claim_r18_003_or_later_completion")) {
        if ((@($Card.forbidden_actions) -join " ") -notmatch [regex]::Escape($requiredForbidden)) {
            throw "$($Card.agent_id) forbidden_actions must preserve '$requiredForbidden'."
        }
    }
    Assert-R18AgentCardNonEmptyArray -Value $Card.required_inputs -Context "$($Card.agent_id) required_inputs"
    Assert-R18AgentCardNonEmptyArray -Value $Card.required_outputs -Context "$($Card.agent_id) required_outputs"
    Assert-R18AgentCardNonEmptyArray -Value $Card.memory_refs -Context "$($Card.agent_id) memory_refs"
    Assert-R18AgentCardNonEmptyArray -Value $Card.evidence_obligations -Context "$($Card.agent_id) evidence_obligations"
    Assert-R18AgentCardNonEmptyObject -Value $Card.handoff_rules -Context "$($Card.agent_id) handoff_rules"
    Assert-R18AgentCardNonEmptyObject -Value $Card.retry_failover_behavior -Context "$($Card.agent_id) retry_failover_behavior"
    Assert-R18AgentCardNonEmptyObject -Value $Card.approval_gates -Context "$($Card.agent_id) approval_gates"
    Assert-R18AgentCardCondition -Condition ([bool]$Card.handoff_rules.executable_handoff_allowed -eq $false) -Message "$($Card.agent_id) permits executable handoff."
    Assert-R18AgentCardCondition -Condition ([bool]$Card.handoff_rules.live_dispatch_allowed -eq $false) -Message "$($Card.agent_id) permits live dispatch."
    Assert-R18AgentCardCondition -Condition ([bool]$Card.retry_failover_behavior.automatic_retry_allowed -eq $false) -Message "$($Card.agent_id) permits automatic retry runtime."
    Assert-R18AgentCardCondition -Condition ([bool]$Card.retry_failover_behavior.automatic_failover_allowed -eq $false) -Message "$($Card.agent_id) permits automatic failover runtime."
    Assert-R18AgentCardCondition -Condition ([bool]$Card.approval_gates.bypass_gate_allowed -eq $false) -Message "$($Card.agent_id) permits approval bypass."
    Assert-R18AgentCardNonEmptyArray -Value $Card.evidence_refs -Context "$($Card.agent_id) evidence_refs"
    Assert-R18AgentCardNonEmptyArray -Value $Card.authority_refs -Context "$($Card.agent_id) authority_refs"

    Assert-R18AgentCardSkills -Card $Card
    Assert-R18AgentCardAllowedPaths -Card $Card
    Assert-R18AgentCardClaims -Card $Card
    Assert-R18AgentCardRoleBoundary -Card $Card
}

function Assert-R18AgentCardContract {
    param(
        [Parameter(Mandatory = $true)][object]$Contract
    )

    Assert-R18AgentCardRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "scope", "purpose", "required_card_ids", "required_card_fields", "required_runtime_false_flags", "allowed_skill_identifiers", "forbidden_skill_identifiers", "allowed_positive_claims", "path_policy", "role_boundary_rules", "evidence_refs", "authority_refs", "non_claims") -Context "agent card contract"
    Assert-R18AgentCardCondition -Condition ($Contract.artifact_type -eq "r18_agent_card_contract") -Message "agent card contract artifact_type is invalid."
    foreach ($agentId in @($script:R18RequiredCardFileMap.Keys)) {
        Assert-R18AgentCardCondition -Condition (@($Contract.required_card_ids) -contains $agentId) -Message "agent card contract missing required card '$agentId'."
    }
    foreach ($field in $script:R18RequiredCardFields) {
        Assert-R18AgentCardCondition -Condition (@($Contract.required_card_fields) -contains $field) -Message "agent card contract missing required field '$field'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18AgentCardCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "agent card contract missing required runtime flag '$flag'."
    }
}

function Assert-R18AgentCardCheckReport {
    param(
        [Parameter(Mandatory = $true)][object]$Report
    )

    Assert-R18AgentCardRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_milestone", "source_task", "required_card_count", "generated_card_count", "card_ids", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "agent card check report"
    Assert-R18AgentCardCondition -Condition ($Report.artifact_type -eq "r18_agent_card_check_report") -Message "agent card check report artifact_type is invalid."
    Assert-R18AgentCardCondition -Condition ($Report.aggregate_verdict -eq $script:R18AgentCardVerdict) -Message "agent card check report aggregate verdict is invalid."
    Assert-R18AgentCardCondition -Condition ([int]$Report.required_card_count -eq @($script:R18RequiredCardFileMap.Keys).Count) -Message "agent card check report required_card_count is invalid."
    Assert-R18AgentCardCondition -Condition ([int]$Report.generated_card_count -eq @($script:R18RequiredCardFileMap.Keys).Count) -Message "agent card check report generated_card_count is invalid."
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "agent card check '$($check.Name)' must have status passed."
        }
    }
    Assert-R18AgentCardFalseFields -Object $Report.runtime_flags -FieldNames $script:R18RuntimeFlagFields -Context "agent card check report runtime_flags"
}

function Assert-R18AgentCardSnapshot {
    param(
        [Parameter(Mandatory = $true)][object]$Snapshot
    )

    Assert-R18AgentCardRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_milestone", "source_task", "active_through_task", "ui_boundary_label", "required_card_count", "generated_card_count", "cards", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "agent card snapshot"
    Assert-R18AgentCardCondition -Condition ($Snapshot.artifact_type -eq "r18_agent_card_snapshot") -Message "agent card snapshot artifact_type is invalid."
    Assert-R18AgentCardCondition -Condition ($Snapshot.active_through_task -eq "R18-002") -Message "agent card snapshot active_through_task must be R18-002."
    Assert-R18AgentCardCondition -Condition ([int]$Snapshot.required_card_count -eq @($script:R18RequiredCardFileMap.Keys).Count) -Message "agent card snapshot required_card_count is invalid."
    Assert-R18AgentCardCondition -Condition ([int]$Snapshot.generated_card_count -eq @($script:R18RequiredCardFileMap.Keys).Count) -Message "agent card snapshot generated_card_count is invalid."
    foreach ($card in @($Snapshot.cards)) {
        Assert-R18AgentCardCondition -Condition ([bool]$card.runtime_enabled -eq $false) -Message "agent card snapshot '$($card.agent_id)' runtime_enabled must be false."
        Assert-R18AgentCardCondition -Condition ([bool]$card.live_agent_runtime_invoked -eq $false) -Message "agent card snapshot '$($card.agent_id)' claims live agent runtime."
        Assert-R18AgentCardCondition -Condition ([bool]$card.openai_api_invoked -eq $false) -Message "agent card snapshot '$($card.agent_id)' claims OpenAI API invocation."
        Assert-R18AgentCardCondition -Condition ([bool]$card.codex_api_invoked -eq $false) -Message "agent card snapshot '$($card.agent_id)' claims Codex API invocation."
        Assert-R18AgentCardCondition -Condition ([bool]$card.r18_003_completed -eq $false) -Message "agent card snapshot '$($card.agent_id)' claims R18-003 completion."
    }
    Assert-R18AgentCardFalseFields -Object $Snapshot.runtime_summary -FieldNames $script:R18RuntimeFlagFields -Context "agent card snapshot runtime_summary"
}

function Test-R18AgentCardSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object[]]$Cards,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot
    )

    Assert-R18AgentCardContract -Contract $Contract
    Assert-R18AgentCardCondition -Condition (@($Cards).Count -eq @($script:R18RequiredCardFileMap.Keys).Count) -Message "R18 agent card set is missing required cards."
    foreach ($agentId in @($script:R18RequiredCardFileMap.Keys)) {
        Assert-R18AgentCardCondition -Condition (@($Cards | Where-Object { $_.agent_id -eq $agentId }).Count -eq 1) -Message "R18 agent card set is missing required card '$agentId'."
    }
    foreach ($card in @($Cards)) {
        Assert-R18AgentCard -Card $card
    }
    Assert-R18AgentCardCheckReport -Report $Report
    Assert-R18AgentCardSnapshot -Snapshot $Snapshot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredCardCount = [int]$Report.required_card_count
        GeneratedCardCount = [int]$Report.generated_card_count
        AgentIds = @($Cards | ForEach-Object { $_.agent_id })
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18AgentCardSchema {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R18AgentCardRepositoryRoot)
    )

    $paths = Get-R18AgentCardSchemaPaths -RepositoryRoot $RepositoryRoot
    $cards = foreach ($agentId in @($script:R18RequiredCardFileMap.Keys)) {
        Read-R18AgentCardJson -Path $paths.CardFiles[$agentId]
    }

    return Test-R18AgentCardSet `
        -Contract (Read-R18AgentCardJson -Path $paths.Contract) `
        -Cards @($cards) `
        -Report (Read-R18AgentCardJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18AgentCardJson -Path $paths.UiSnapshot)
}

function Set-R18AgentCardObjectPathValue {
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

function Remove-R18AgentCardObjectPathValue {
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

function Invoke-R18AgentCardMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18AgentCardObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18AgentCardObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R18AgentCardSchemaPaths, `
    New-R18AgentCardSchemaArtifacts, `
    Test-R18AgentCardSchema, `
    Test-R18AgentCardSet, `
    Invoke-R18AgentCardMutation, `
    Copy-R18AgentCardObject
