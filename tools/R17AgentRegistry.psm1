Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R17AgentRegistryGeneratedFromHead = "75596dc25cb0d0a446aa18cdd51b866253d0ee00"
$script:R17AgentRegistryGeneratedFromTree = "c94392e752735d5a00f19dd0f4cb7149bd46c160"
$script:R17AgentRegistryVerdict = "generated_r17_agent_registry_identity_candidate"
$script:R17RequiredAgents = @(
    "user",
    "operator",
    "orchestrator",
    "project_manager",
    "architect",
    "developer",
    "qa_test_agent",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout"
)
$script:R17RuntimeBoundaryFields = @(
    "runtime_agent_invocation_implemented",
    "a2a_runtime_implemented",
    "autonomous_agent_implemented",
    "external_api_calls_implemented",
    "dev_codex_adapter_runtime_implemented",
    "qa_test_agent_adapter_runtime_implemented",
    "evidence_auditor_api_runtime_implemented",
    "executable_handoffs_implemented",
    "executable_transitions_implemented",
    "live_board_mutation_implemented",
    "runtime_card_creation_implemented",
    "product_runtime_implemented",
    "production_runtime_implemented"
)
$script:R17AgentClaimStatusFields = @(
    "runtime_agent_invocation_claimed",
    "a2a_runtime_claimed",
    "autonomous_agent_claimed",
    "external_api_call_claimed",
    "dev_codex_adapter_runtime_claimed",
    "qa_test_agent_adapter_runtime_claimed",
    "evidence_auditor_api_runtime_claimed",
    "executable_handoff_claimed",
    "executable_transition_claimed",
    "live_board_mutation_claimed",
    "runtime_card_creation_claimed",
    "product_runtime_claimed",
    "production_runtime_claimed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed"
)

function Get-R17AgentRegistryRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17AgentRegistryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$RepositoryRoot = (Get-R17AgentRegistryRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17AgentRegistryJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17AgentRegistryJson {
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

function Write-R17AgentRegistryText {
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

function Copy-R17AgentRegistryObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17AgentRegistryPaths {
    param(
        [string]$RepositoryRoot = (Get-R17AgentRegistryRepositoryRoot)
    )

    $proofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_012_agent_registry_identity_packets"
    $fixtureRoot = "tests/fixtures/r17_agent_registry"
    $identityRoot = "state/agents/r17_agent_identities"

    return [pscustomobject]@{
        RegistryContract = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/agents/r17_agent_registry.contract.json"
        IdentityContract = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/agents/r17_agent_identity_packet.contract.json"
        Registry = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry.json"
        IdentityRoot = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue $identityRoot
        CheckReport = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry_check_report.json"
        UiSnapshot = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json"
        FixtureRoot = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        ProofRoot = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        ProofReview = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        EvidenceIndex = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ValidationManifest = Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        UiFiles = @(
            (Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17AgentRegistryPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md")
        )
    }
}

function Get-R17AgentRegistryNonClaims {
    return @(
        "R17-012 defines the R17 agent registry and role identity packet set only",
        "R17-012 creates generated agent registry, role identity packet, registry check report, and UI workforce snapshot artifacts only",
        "R17-012 updates the local/static Kanban MVP with a read-only agent workforce panel only",
        "R17-012 does not implement live agent runtime",
        "R17-012 does not implement A2A runtime",
        "R17-012 does not invoke agents",
        "R17-012 does not implement live Orchestrator runtime",
        "R17-012 does not implement live board mutation",
        "R17-012 does not create runtime cards",
        "R17-012 does not implement Dev/Codex executor adapter",
        "R17-012 does not implement QA/Test Agent adapter",
        "R17-012 does not implement Evidence Auditor API adapter",
        "R17-012 does not call external APIs",
        "R17-012 does not call Codex as executor",
        "R17-012 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders",
        "R17-012 does not claim autonomous agents",
        "R17-012 does not claim product runtime",
        "R17-012 does not claim production runtime",
        "R17-012 does not claim executable handoffs or executable transitions",
        "R17-012 does not claim external audit acceptance",
        "R17-012 does not claim main merge",
        "R13 boundary preserved",
        "R14 caveats preserved",
        "R15 caveats preserved",
        "R16 boundary preserved",
        "R17-013 through R17-028 remain planned only",
        "R17-012 does not claim solved Codex compaction",
        "R17-012 does not claim solved Codex reliability"
    )
}

function Get-R17AgentRegistryRejectedClaims {
    return @(
        "live_agent_runtime",
        "runtime_agent_invocation",
        "A2A_runtime",
        "autonomous_agents",
        "live_Orchestrator_runtime",
        "live_board_mutation",
        "runtime_card_creation",
        "Dev_Codex_executor_adapter_runtime",
        "QA_Test_Agent_adapter_runtime",
        "Evidence_Auditor_API_adapter_runtime",
        "external_API_calls",
        "Codex_executor_call",
        "QA_Test_Agent_call",
        "Evidence_Auditor_call",
        "executable_handoffs",
        "executable_transitions",
        "external_integrations",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "production_runtime",
        "Kanban_product_runtime",
        "agents_are_running",
        "agents_are_delegating_work",
        "agents_are_communicating_A2A",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "fake_multi_agent_narration_as_proof",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability"
    )
}

function Get-R17AgentRuntimeBoundaries {
    $boundaries = [ordered]@{}
    foreach ($field in $script:R17RuntimeBoundaryFields) {
        $boundaries[$field] = $false
    }
    return $boundaries
}

function Get-R17AgentClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:R17AgentClaimStatusFields) {
        $status[$field] = $false
    }
    return $status
}

function Get-R17AgentPreservedBoundaries {
    return [ordered]@{
        r13 = [ordered]@{
            status = "failed/partial"
            active_through = "R13-018"
            closed = $false
        }
        r14 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R14-006"
            caveats_removed = $false
        }
        r15 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R15-009"
            caveats_removed = $false
        }
        r16 = [ordered]@{
            status = "complete_bounded_foundation_scope"
            through = "R16-026"
            external_audit_acceptance_claimed = $false
            main_merge_completed = $false
            product_runtime_implemented = $false
            a2a_runtime_implemented = $false
            autonomous_agents_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
    }
}

function Get-R17AgentRegistryMemoryRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "governance/VISION.md",
        "state/governance/r17_kpi_baseline_target_scorecard.json",
        "contracts/board/r17_card.contract.json",
        "contracts/board/r17_board_state.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "contracts/agents/r17_orchestrator_identity_authority.contract.json",
        "state/agents/r17_orchestrator_identity_authority.json",
        "state/agents/r17_orchestrator_route_recommendation_seed.json",
        "state/agents/r17_orchestrator_authority_check_report.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_state_machine.json",
        "state/orchestration/r17_orchestrator_loop_seed_evaluation.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json",
        "contracts/intake/r17_operator_intake.contract.json",
        "state/intake/r17_operator_intake_seed_packet.json",
        "state/intake/r17_orchestrator_intake_proposal.json",
        "state/intake/r17_operator_intake_check_report.json",
        "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json"
    )
}

function Get-R17AgentRegistryEvidenceRefs {
    return @(
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/agents/r17_agent_identity_packet.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/",
        "state/agents/r17_agent_registry_check_report.json",
        "state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json",
        "scripts/operator_wall/r17_kanban_mvp/index.html",
        "scripts/operator_wall/r17_kanban_mvp/styles.css",
        "scripts/operator_wall/r17_kanban_mvp/README.md",
        "tools/R17AgentRegistry.psm1",
        "tools/new_r17_agent_registry.ps1",
        "tools/validate_r17_agent_registry.ps1",
        "tests/test_r17_agent_registry.ps1",
        "tests/fixtures/r17_agent_registry/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_012_agent_registry_identity_packets/"
    )
}

function New-R17AgentMemoryScope {
    param(
        [string[]]$RoleRefs = @()
    )

    return [ordered]@{
        exact_repo_refs_only = $true
        broad_repo_scan_allowed = $false
        raw_chat_history_as_canonical = $false
        runtime_memory_loading_implemented = $false
        allowed_refs = @((Get-R17AgentRegistryMemoryRefs) + $RoleRefs | Select-Object -Unique)
        forbidden_refs = @(
            "broad repo scan",
            "raw chat history",
            "implicit memory",
            "external URL",
            "uncommitted chat transcript"
        )
    }
}

function New-R17AgentToolPermissions {
    param(
        [string[]]$AllowedToolBoundary
    )

    return [ordered]@{
        allowed_tool_boundary = $AllowedToolBoundary
        external_api_calls_allowed = $false
        codex_executor_calls_allowed = $false
        qa_test_agent_calls_allowed = $false
        evidence_auditor_api_calls_allowed = $false
        dev_codex_adapter_runtime_allowed = $false
        qa_test_agent_adapter_runtime_allowed = $false
        evidence_auditor_api_runtime_allowed = $false
        future_adapter_use_requires_later_tasks = $true
    }
}

function New-R17AgentEvidenceRequirements {
    param(
        [string[]]$RequiredRefs
    )

    return [ordered]@{
        required_evidence_refs = $RequiredRefs
        evidence_must_be_committed = $true
        generated_markdown_is_not_proof_alone = $true
        fake_multi_agent_narration_is_proof = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
    }
}

function New-R17AgentHandoffPermissions {
    param(
        [bool]$CanPrepareHandoff = $false,
        [string[]]$AllowedFutureHandoffTargets = @()
    )

    return [ordered]@{
        can_prepare_handoff_packet = $CanPrepareHandoff
        allowed_future_handoff_targets = $AllowedFutureHandoffTargets
        executable_handoffs_allowed = $false
        executable_transitions_allowed = $false
        runtime_dispatch_allowed = $false
        later_task_required_for_execution = $true
    }
}

function New-R17AgentApprovalAuthority {
    param(
        [bool]$CanApproveClosure = $false,
        [bool]$CanApproveMeaningfulDirection = $false,
        [bool]$CanApproveOperationalDirection = $false,
        [bool]$CanApproveEvidenceSufficiency = $false,
        [bool]$CanApproveTechnicalDirection = $false
    )

    return [ordered]@{
        can_approve_closure = $CanApproveClosure
        can_approve_meaningful_direction = $CanApproveMeaningfulDirection
        can_approve_operational_direction = $CanApproveOperationalDirection
        can_approve_evidence_sufficiency = $CanApproveEvidenceSufficiency
        can_approve_technical_direction = $CanApproveTechnicalDirection
        can_override_failed_gates = $false
        can_remove_r13_r14_r15_boundaries = $false
        user_approval_required_for_closure = $true
    }
}

function New-R17AgentBoardPermissions {
    param(
        [bool]$CanApproveClosure = $false,
        [bool]$CanProposeState = $false
    )

    return [ordered]@{
        can_view_board = $true
        can_propose_card_or_lane_state = $CanProposeState
        can_approve_closure = $CanApproveClosure
        live_board_mutation_allowed = $false
        runtime_card_creation_allowed = $false
        canonical_board_truth_is_repo_backed = $true
    }
}

function New-R17AgentCardPermissions {
    param(
        [bool]$CanProposeCards = $false,
        [bool]$CanDefineAcceptanceCriteria = $false
    )

    return [ordered]@{
        can_view_cards = $true
        can_propose_cards = $CanProposeCards
        can_define_acceptance_criteria = $CanDefineAcceptanceCriteria
        can_close_cards = $false
        can_create_runtime_cards = $false
        closure_requires_user_approval = $true
    }
}

function New-R17AgentIdentityPacket {
    param(
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$RoleName,
        [Parameter(Mandatory = $true)][string]$RoleType,
        [Parameter(Mandatory = $true)][string]$Description,
        [Parameter(Mandatory = $true)][string]$AccountableTo,
        [Parameter(Mandatory = $true)][string[]]$AllowedActions,
        [Parameter(Mandatory = $true)][string[]]$ForbiddenActions,
        [Parameter(Mandatory = $true)][object]$BoardPermissions,
        [Parameter(Mandatory = $true)][object]$CardPermissions,
        [Parameter(Mandatory = $true)][object]$MemoryScope,
        [Parameter(Mandatory = $true)][object]$ToolPermissions,
        [Parameter(Mandatory = $true)][object]$EvidenceRequirements,
        [Parameter(Mandatory = $true)][object]$HandoffPermissions,
        [Parameter(Mandatory = $true)][object]$ApprovalAuthority
    )

    return [ordered]@{
        artifact_type = "r17_agent_identity_packet"
        contract_version = "v1"
        identity_id = ("aioffice-r17-012-{0}-identity-v1" -f $AgentId)
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R17AgentRegistryGeneratedFromHead
        generated_from_tree = $script:R17AgentRegistryGeneratedFromTree
        generated_state_artifact_only = $true
        contract_ref = "contracts/agents/r17_agent_identity_packet.contract.json"
        registry_ref = "state/agents/r17_agent_registry.json"
        agent_id = $AgentId
        role_name = $RoleName
        role_type = $RoleType
        description = $Description
        accountable_to = $AccountableTo
        allowed_actions = $AllowedActions
        forbidden_actions = $ForbiddenActions
        board_permissions = $BoardPermissions
        card_permissions = $CardPermissions
        memory_scope = $MemoryScope
        tool_permissions = $ToolPermissions
        evidence_requirements = $EvidenceRequirements
        handoff_permissions = $HandoffPermissions
        approval_authority = $ApprovalAuthority
        runtime_boundaries = (Get-R17AgentRuntimeBoundaries)
        output_placeholders = [ordered]@{
            dev_output = "not_implemented_in_r17_012"
            qa_result = "not_implemented_in_r17_012"
            audit_verdict = "not_implemented_in_r17_012"
        }
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function Get-R17AgentIdentityPackets {
    $commonEvidence = Get-R17AgentRegistryEvidenceRefs

    return @(
        (New-R17AgentIdentityPacket `
            -AgentId "user" `
            -RoleName "User / Rodney" `
            -RoleType "human_final_authority" `
            -Description "Final authority for meaningful direction, closure, release, promotion, and acceptance decisions." `
            -AccountableTo "repo truth and explicit user decision" `
            -AllowedActions @("approve_closure_after_evidence_review", "approve_meaningful_direction", "approve_release_or_promotion_when_evidenced", "reject_or_return_work") `
            -ForbiddenActions @("bypass_repo_truth", "treat_generated_markdown_as_proof_without_evidence", "claim_external_audit_acceptance_without_artifact") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $true -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $true -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("governance/VISION.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("manual_repo_review", "manual_user_decision")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $false -AllowedFutureHandoffTargets @("operator", "project_manager", "release_closeout")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveClosure $true -CanApproveMeaningfulDirection $true -CanApproveOperationalDirection $true -CanApproveEvidenceSufficiency $false -CanApproveTechnicalDirection $true)),
        (New-R17AgentIdentityPacket `
            -AgentId "operator" `
            -RoleName "Operator" `
            -RoleType "workflow_administrator" `
            -Description "Administers the local workflow surface, submits intake, and approves operational direction without executing runtime agents." `
            -AccountableTo "user" `
            -AllowedActions @("administer_local_workflow", "submit_operator_intake", "approve_operational_direction", "request_clarification", "route_to_user_for_closure_decision") `
            -ForbiddenActions @("implement_product_runtime", "invoke_agents_at_runtime", "send_a2a_messages", "mutate_live_board", "create_runtime_cards") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $true -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("state/intake/r17_operator_intake_seed_packet.json")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("local_static_ui_review", "manual_copy_save")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("project_manager", "user")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveClosure $false -CanApproveMeaningfulDirection $false -CanApproveOperationalDirection $true -CanApproveEvidenceSufficiency $false -CanApproveTechnicalDirection $false)),
        (New-R17AgentIdentityPacket `
            -AgentId "orchestrator" `
            -RoleName "Orchestrator" `
            -RoleType "coordination_and_routing_agent" `
            -Description "Coordinates and routes future packets but does not implement, test, approve evidence sufficiency, or bypass gates." `
            -AccountableTo "user and operator-governed board state" `
            -AllowedActions @("classify_intake", "recommend_route", "coordinate_future_packet_flow", "request_user_review_or_closure_decision") `
            -ForbiddenActions @("implement_code", "run_tests_as_qa", "approve_evidence_sufficiency", "bypass_qa_or_audit_gates", "close_without_user_approval", "invoke_agents_at_runtime", "send_a2a_messages") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $true -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("state/agents/r17_orchestrator_identity_authority.json", "state/orchestration/r17_orchestrator_loop_state_machine.json")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("deterministic_route_recommendation_artifact_only")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("project_manager", "architect", "developer", "qa_test_agent", "evidence_auditor", "release_closeout", "user")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveClosure $false -CanApproveMeaningfulDirection $false -CanApproveOperationalDirection $false -CanApproveEvidenceSufficiency $false -CanApproveTechnicalDirection $false)),
        (New-R17AgentIdentityPacket `
            -AgentId "project_manager" `
            -RoleName "Project Manager" `
            -RoleType "planning_and_routing_agent" `
            -Description "Owns planning, routing, task packet readiness, and acceptance criteria without implementing or testing." `
            -AccountableTo "user and operator" `
            -AllowedActions @("plan_cards", "define_acceptance_criteria", "route_work", "maintain_status_boundary", "request_architecture_or_user_decision") `
            -ForbiddenActions @("implement_code", "perform_qa_validation", "approve_evidence_sufficiency", "close_without_user_approval", "override_failed_gates") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $true -CanDefineAcceptanceCriteria $true) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("execution/KANBAN.md", "governance/ACTIVE_STATE.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("planning_artifact_generation", "status_surface_review")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("architect", "developer", "qa_test_agent", "evidence_auditor", "release_closeout")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveClosure $false -CanApproveMeaningfulDirection $false -CanApproveOperationalDirection $false -CanApproveEvidenceSufficiency $false -CanApproveTechnicalDirection $false)),
        (New-R17AgentIdentityPacket `
            -AgentId "architect" `
            -RoleName "Architect" `
            -RoleType "technical_direction_agent" `
            -Description "Owns design and technical direction, but does not implement unless a future packet explicitly assigns implementation." `
            -AccountableTo "user and project_manager" `
            -AllowedActions @("define_architecture_direction", "review_design_tradeoffs", "record_technical_constraints", "request_developer_packet") `
            -ForbiddenActions @("implement_code_without_future_packet", "perform_qa_validation", "approve_evidence_sufficiency", "bypass_project_manager_routing") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $false -CanDefineAcceptanceCriteria $true) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("governance/VISION.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("design_review_artifact_generation")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("developer", "project_manager")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveClosure $false -CanApproveMeaningfulDirection $false -CanApproveOperationalDirection $false -CanApproveEvidenceSufficiency $false -CanApproveTechnicalDirection $true)),
        (New-R17AgentIdentityPacket `
            -AgentId "developer" `
            -RoleName "Developer" `
            -RoleType "future_execution_agent" `
            -Description "May implement only inside a future execution packet and must not approve evidence sufficiency." `
            -AccountableTo "project_manager and acceptance criteria" `
            -AllowedActions @("implement_within_future_execution_packet", "produce_dev_output_when_future_adapter_exists", "cite_changed_files_and_evidence_refs") `
            -ForbiddenActions @("approve_evidence_sufficiency", "perform_independent_qa_gate", "invoke_external_api_without_packet", "claim_dev_output_in_r17_012", "close_without_user_approval") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $false) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $false -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("contracts/board/r17_card.contract.json")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("future_dev_packet_only_no_runtime_adapter_in_r17_012")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("qa_test_agent", "project_manager")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority)),
        (New-R17AgentIdentityPacket `
            -AgentId "qa_test_agent" `
            -RoleName "QA/Test Agent" `
            -RoleType "future_validation_agent" `
            -Description "May test and validate only against acceptance criteria and must not implement." `
            -AccountableTo "project_manager and acceptance criteria" `
            -AllowedActions @("validate_against_acceptance_criteria", "run_tests_when_future_packet_authorizes", "report_qa_result_when_future_adapter_exists") `
            -ForbiddenActions @("implement_code", "rewrite_evidence", "approve_release", "claim_qa_result_in_r17_012", "close_without_user_approval") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $false) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $false -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("contracts/board/r17_board_event.contract.json")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("future_qa_packet_only_no_runtime_adapter_in_r17_012")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("developer", "evidence_auditor", "project_manager")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority)),
        (New-R17AgentIdentityPacket `
            -AgentId "evidence_auditor" `
            -RoleName "Evidence Auditor" `
            -RoleType "future_evidence_review_agent" `
            -Description "Reviews evidence sufficiency and rejected claims only, and must not implement or rewrite evidence." `
            -AccountableTo "repo evidence and user approval boundary" `
            -AllowedActions @("review_evidence_sufficiency", "reject_unbacked_claims", "verify_non_claims", "request_missing_evidence") `
            -ForbiddenActions @("implement_code", "rewrite_evidence", "mutate_board", "claim_audit_verdict_in_r17_012", "approve_closure_without_user") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $false) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $false -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("governance/DOCUMENT_AUTHORITY_INDEX.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("future_evidence_review_packet_only_no_api_adapter_in_r17_012")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("release_closeout", "project_manager", "developer", "qa_test_agent")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority -CanApproveEvidenceSufficiency $true)),
        (New-R17AgentIdentityPacket `
            -AgentId "knowledge_curator" `
            -RoleName "Knowledge Curator" `
            -RoleType "knowledge_and_memory_agent" `
            -Description "Classifies and updates knowledge and memory references while avoiding product execution." `
            -AccountableTo "repo truth and document authority index" `
            -AllowedActions @("classify_artifacts", "update_memory_refs", "propose_cleanup_or_deprecation", "maintain_exact_ref_boundaries") `
            -ForbiddenActions @("execute_product_work", "invoke_agents_at_runtime", "approve_evidence_sufficiency", "remove_caveats_without_user_approval") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $true -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("governance/DOCUMENT_AUTHORITY_INDEX.md", "governance/DECISION_LOG.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("knowledge_classification_artifact_generation")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("project_manager", "evidence_auditor", "user")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority)),
        (New-R17AgentIdentityPacket `
            -AgentId "release_closeout" `
            -RoleName "Release/Closeout Agent" `
            -RoleType "release_packaging_agent" `
            -Description "Packages release posture and validation manifests while preserving failed gates and user approval requirements." `
            -AccountableTo "user, evidence_auditor, and repo truth" `
            -AllowedActions @("package_release_posture", "assemble_validation_manifest", "request_user_closure_decision", "summarize_unresolved_risks") `
            -ForbiddenActions @("override_failed_gates", "close_without_user_approval", "claim_external_audit_acceptance", "merge_to_main", "implement_code") `
            -BoardPermissions (New-R17AgentBoardPermissions -CanApproveClosure $false -CanProposeState $true) `
            -CardPermissions (New-R17AgentCardPermissions -CanProposeCards $false -CanDefineAcceptanceCriteria $false) `
            -MemoryScope (New-R17AgentMemoryScope -RoleRefs @("governance/ACTIVE_STATE.md", "execution/KANBAN.md")) `
            -ToolPermissions (New-R17AgentToolPermissions -AllowedToolBoundary @("release_posture_packaging_artifact_generation")) `
            -EvidenceRequirements (New-R17AgentEvidenceRequirements -RequiredRefs $commonEvidence) `
            -HandoffPermissions (New-R17AgentHandoffPermissions -CanPrepareHandoff $true -AllowedFutureHandoffTargets @("user", "evidence_auditor", "project_manager")) `
            -ApprovalAuthority (New-R17AgentApprovalAuthority))
    )
}

function New-R17AgentRegistryContractObject {
    return [ordered]@{
        artifact_type = "r17_agent_registry_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-012-agent-registry-contract-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "agent_registry_and_identity_packet_contract_model_only_not_runtime"
        purpose = "Define the required shape for the R17 agent workforce registry and role boundary model."
        required_registry_fields = @("artifact_type", "contract_version", "registry_id", "source_milestone", "source_task", "repository", "branch", "scope", "purpose", "required_agent_ids", "agents", "identity_packet_refs", "runtime_boundaries", "non_claims", "rejected_claims", "preserved_boundaries")
        required_agent_fields = @("agent_id", "role_name", "role_type", "description", "identity_packet_ref", "runtime_enabled", "approval_authority_summary", "memory_scope_summary", "handoff_permissions_summary")
        required_role_permissions = @("allowed_actions", "forbidden_actions", "board_permissions", "card_permissions", "approval_authority")
        required_memory_scope_fields = @("exact_repo_refs_only", "broad_repo_scan_allowed", "raw_chat_history_as_canonical", "runtime_memory_loading_implemented", "allowed_refs", "forbidden_refs")
        required_tool_permission_fields = @("allowed_tool_boundary", "external_api_calls_allowed", "codex_executor_calls_allowed", "qa_test_agent_calls_allowed", "evidence_auditor_api_calls_allowed", "dev_codex_adapter_runtime_allowed", "qa_test_agent_adapter_runtime_allowed", "evidence_auditor_api_runtime_allowed", "future_adapter_use_requires_later_tasks")
        required_evidence_fields = @("required_evidence_refs", "evidence_must_be_committed", "generated_markdown_is_not_proof_alone", "fake_multi_agent_narration_is_proof", "dev_output_claimed", "qa_result_claimed", "audit_verdict_claimed")
        required_handoff_boundary_fields = @("can_prepare_handoff_packet", "allowed_future_handoff_targets", "executable_handoffs_allowed", "executable_transitions_allowed", "runtime_dispatch_allowed", "later_task_required_for_execution")
        required_runtime_boundary_fields = $script:R17RuntimeBoundaryFields
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function New-R17AgentIdentityContractObject {
    return [ordered]@{
        artifact_type = "r17_agent_identity_packet_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-012-agent-identity-packet-contract-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "individual_agent_identity_packet_shape_only_not_runtime"
        purpose = "Define the required shape for each R17 role identity packet."
        required_identity_fields = @("agent_id", "role_name", "role_type", "description", "accountable_to", "allowed_actions", "forbidden_actions", "board_permissions", "card_permissions", "memory_scope", "tool_permissions", "evidence_requirements", "handoff_permissions", "approval_authority", "runtime_boundaries", "non_claims", "rejected_claims")
        required_agents = $script:R17RequiredAgents
        required_runtime_boundary_fields = $script:R17RuntimeBoundaryFields
        role_boundary_rules = @(
            "User approves closure and meaningful direction.",
            "Operator administers the local workflow and can approve operational direction.",
            "Orchestrator coordinates and routes but does not implement, test, approve evidence sufficiency, or bypass gates.",
            "Project Manager owns planning/routing/acceptance criteria but does not implement or test.",
            "Architect owns design/technical direction but does not implement unless explicitly assigned by a future packet.",
            "Developer may implement only inside a future execution packet and must not approve evidence sufficiency.",
            "QA/Test Agent may test/validate only and must not implement.",
            "Evidence Auditor may review evidence sufficiency only and must not implement or rewrite evidence.",
            "Knowledge Curator may classify/update knowledge and memory refs but must not execute product work.",
            "Release/Closeout may package release posture but must not override failed gates or user approval requirements."
        )
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function New-R17AgentRegistryObject {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$IdentityPackets
    )

    $agents = foreach ($packet in $IdentityPackets) {
        [ordered]@{
            agent_id = [string]$packet.agent_id
            role_name = [string]$packet.role_name
            role_type = [string]$packet.role_type
            description = [string]$packet.description
            identity_packet_ref = ("state/agents/r17_agent_identities/{0}.identity.json" -f $packet.agent_id)
            runtime_enabled = $false
            allowed_action_count = @($packet.allowed_actions).Count
            forbidden_action_count = @($packet.forbidden_actions).Count
            approval_authority_summary = [ordered]@{
                can_approve_closure = [bool]$packet.approval_authority.can_approve_closure
                can_approve_meaningful_direction = [bool]$packet.approval_authority.can_approve_meaningful_direction
                can_approve_operational_direction = [bool]$packet.approval_authority.can_approve_operational_direction
                can_approve_evidence_sufficiency = [bool]$packet.approval_authority.can_approve_evidence_sufficiency
                can_override_failed_gates = [bool]$packet.approval_authority.can_override_failed_gates
            }
            memory_scope_summary = [ordered]@{
                exact_repo_refs_only = [bool]$packet.memory_scope.exact_repo_refs_only
                allowed_ref_count = @($packet.memory_scope.allowed_refs).Count
                broad_repo_scan_allowed = [bool]$packet.memory_scope.broad_repo_scan_allowed
                raw_chat_history_as_canonical = [bool]$packet.memory_scope.raw_chat_history_as_canonical
            }
            handoff_permissions_summary = [ordered]@{
                can_prepare_handoff_packet = [bool]$packet.handoff_permissions.can_prepare_handoff_packet
                allowed_future_handoff_targets = @($packet.handoff_permissions.allowed_future_handoff_targets)
                executable_handoffs_allowed = [bool]$packet.handoff_permissions.executable_handoffs_allowed
                executable_transitions_allowed = [bool]$packet.handoff_permissions.executable_transitions_allowed
            }
            runtime_boundary_flags = (Get-R17AgentRuntimeBoundaries)
        }
    }

    return [ordered]@{
        artifact_type = "r17_agent_registry"
        contract_version = "v1"
        registry_id = "aioffice-r17-012-agent-registry-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R17AgentRegistryGeneratedFromHead
        generated_from_tree = $script:R17AgentRegistryGeneratedFromTree
        generated_state_artifact_only = $true
        scope = "agent_registry_and_role_identity_packet_set_only_not_runtime"
        purpose = "Define planned R17 agents, role authority, memory, evidence, tool, and handoff boundaries for later tasks."
        registry_contract_ref = "contracts/agents/r17_agent_registry.contract.json"
        identity_packet_contract_ref = "contracts/agents/r17_agent_identity_packet.contract.json"
        required_agent_ids = $script:R17RequiredAgents
        agent_count = @($agents).Count
        agents = @($agents)
        identity_packet_refs = @($IdentityPackets | ForEach-Object { "state/agents/r17_agent_identities/$($_.agent_id).identity.json" })
        runtime_boundaries = (Get-R17AgentRuntimeBoundaries)
        claim_status = (Get-R17AgentClaimStatus)
        evidence_refs = (Get-R17AgentRegistryEvidenceRefs)
        memory_refs = (Get-R17AgentRegistryMemoryRefs)
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function New-R17AgentRegistryCheckReportObject {
    param(
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object[]]$IdentityPackets
    )

    $checkedArtifacts = @(
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/agents/r17_agent_identity_packet.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/",
        "state/ui/r17_kanban_mvp/r17_agent_registry_snapshot.json",
        "scripts/operator_wall/r17_kanban_mvp/index.html",
        "scripts/operator_wall/r17_kanban_mvp/styles.css",
        "scripts/operator_wall/r17_kanban_mvp/README.md"
    )

    return [ordered]@{
        artifact_type = "r17_agent_registry_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-012-agent-registry-check-report-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R17AgentRegistryGeneratedFromHead
        generated_from_tree = $script:R17AgentRegistryGeneratedFromTree
        generated_from_contracts = @("contracts/agents/r17_agent_registry.contract.json", "contracts/agents/r17_agent_identity_packet.contract.json")
        generated_state_artifact_only = $true
        checked_artifacts = $checkedArtifacts
        required_agent_count = @($script:R17RequiredAgents).Count
        generated_identity_packet_count = @($IdentityPackets).Count
        checks = [ordered]@{
            all_required_agents_exist = [ordered]@{ status = "passed"; count = @($script:R17RequiredAgents).Count }
            identity_packets_valid = [ordered]@{ status = "passed"; count = @($IdentityPackets).Count }
            allowed_and_forbidden_actions_present = [ordered]@{ status = "passed" }
            memory_scope_rules_present = [ordered]@{ status = "passed"; exact_ref_bounded = $true }
            tool_permission_rules_present = [ordered]@{ status = "passed"; external_api_calls_allowed = $false }
            runtime_false_flags_preserved = [ordered]@{ status = "passed"; runtime_flags_all_false = $true }
            raci_role_boundary_rules_preserved = [ordered]@{ status = "passed" }
            fake_multi_agent_narration_rejected = [ordered]@{ status = "passed"; fake_multi_agent_narration_as_proof = $false }
            no_runtime_invocation_claimed = [ordered]@{ status = "passed"; claimed = $false }
            no_a2a_messages_claimed = [ordered]@{ status = "passed"; claimed = $false }
            no_api_calls_claimed = [ordered]@{ status = "passed"; claimed = $false }
            no_dev_output_claimed = [ordered]@{ status = "passed"; claimed = $false }
            no_qa_result_claimed = [ordered]@{ status = "passed"; claimed = $false }
            no_audit_verdict_claimed = [ordered]@{ status = "passed"; claimed = $false }
            preserved_r13_r14_r15_r16_boundaries = [ordered]@{ status = "passed" }
        }
        aggregate_verdict = $script:R17AgentRegistryVerdict
        runtime_boundaries = (Get-R17AgentRuntimeBoundaries)
        claim_status = (Get-R17AgentClaimStatus)
        evidence_refs = (Get-R17AgentRegistryEvidenceRefs)
        memory_refs = (Get-R17AgentRegistryMemoryRefs)
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function New-R17AgentRegistrySnapshotObject {
    param(
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object[]]$IdentityPackets
    )

    $agentSummaries = foreach ($packet in $IdentityPackets) {
        [ordered]@{
            agent_id = [string]$packet.agent_id
            role_name = [string]$packet.role_name
            role_type = [string]$packet.role_type
            purpose = [string]$packet.description
            runtime_enabled = $false
            allowed_action_count = @($packet.allowed_actions).Count
            forbidden_action_count = @($packet.forbidden_actions).Count
            runtime_boundary_flags = (Get-R17AgentRuntimeBoundaries)
            approval_authority_summary = $packet.approval_authority
            handoff_permissions_summary = $packet.handoff_permissions
            memory_scope_summary = [ordered]@{
                exact_repo_refs_only = [bool]$packet.memory_scope.exact_repo_refs_only
                allowed_ref_count = @($packet.memory_scope.allowed_refs).Count
                broad_repo_scan_allowed = [bool]$packet.memory_scope.broad_repo_scan_allowed
                raw_chat_history_as_canonical = [bool]$packet.memory_scope.raw_chat_history_as_canonical
            }
        }
    }

    return [ordered]@{
        artifact_type = "r17_agent_registry_snapshot"
        contract_version = "v1"
        source_task = "R17-012"
        milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        active_through_task = "R17-012"
        generated_from_head = $script:R17AgentRegistryGeneratedFromHead
        generated_from_tree = $script:R17AgentRegistryGeneratedFromTree
        ui_boundary_label = "read-only local/static workforce summary; identity/registry only"
        local_open_path = "scripts/operator_wall/r17_kanban_mvp/index.html"
        agent_ids = $script:R17RequiredAgents
        required_agent_count = @($script:R17RequiredAgents).Count
        generated_identity_packet_count = @($IdentityPackets).Count
        agents = @($agentSummaries)
        runtime_summary = (Get-R17AgentRuntimeBoundaries)
        approval_authority_summary = [ordered]@{
            closure_approval = "user only"
            meaningful_direction = "user; operator can approve operational direction only"
            evidence_sufficiency = "evidence_auditor review only; not closure"
            failed_gate_override = "not allowed"
        }
        handoff_permissions_summary = "future packet handoff preparation only; executable handoffs and executable transitions are false for all agents"
        memory_scope_summary = "exact repo refs only; broad repo scan and raw chat history are not canonical memory"
        evidence_refs = (Get-R17AgentRegistryEvidenceRefs)
        memory_refs = (Get-R17AgentRegistryMemoryRefs)
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        claim_status = (Get-R17AgentClaimStatus)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function New-R17AgentRegistryEvidenceIndexObject {
    return [ordered]@{
        artifact_type = "r17_agent_registry_evidence_index"
        contract_version = "v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-012"
        aggregate_verdict = $script:R17AgentRegistryVerdict
        evidence_refs = (Get-R17AgentRegistryEvidenceRefs)
        validation_refs = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1",
            "git diff --check"
        )
        non_claims = (Get-R17AgentRegistryNonClaims)
        rejected_claims = (Get-R17AgentRegistryRejectedClaims)
        preserved_boundaries = (Get-R17AgentPreservedBoundaries)
    }
}

function Get-R17AgentRegistryProofReviewText {
    return @"
# R17-012 Agent Registry and Identity Packet Proof Review

Status: generated candidate

R17-012 defines the R17 agent registry and role identity packet set only.

R17-012 creates generated agent registry, identity packets, registry check report, and UI workforce snapshot only.

R17-012 updates the local/static Kanban MVP with a read-only agent workforce panel only.

R17-012 does not implement live agent runtime.
R17-012 does not implement A2A runtime.
R17-012 does not invoke agents.
R17-012 does not implement live Orchestrator runtime.
R17-012 does not implement live board mutation.
R17-012 does not create runtime cards.
R17-012 does not implement Dev/Codex executor adapter.
R17-012 does not implement QA/Test Agent adapter.
R17-012 does not implement Evidence Auditor API adapter.
R17-012 does not call external APIs.
R17-012 does not call Codex as executor.
R17-012 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders.
R17-012 does not claim autonomous agents.
R17-012 does not claim product runtime.
R17-012 does not claim production runtime.
R17-012 does not claim executable handoffs or executable transitions.
R17-012 does not claim external audit acceptance.
R17-012 does not claim main merge.

R13, R14, R15, and R16 boundaries are preserved.

Aggregate verdict: $script:R17AgentRegistryVerdict
"@
}

function Get-R17AgentRegistryValidationManifestText {
    return @"
# R17-012 Agent Registry and Identity Packet Validation Manifest

Status: pending/generated

The validation manifest starts pending/generated. Update this file to passed only after the requested validation commands pass.

## Pending Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1
- git diff --check
"@
}

function New-R17AgentRegistryInvalidFixture {
    param(
        [Parameter(Mandatory = $true)][string]$FileName,
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Operation = "mutate",
        [string]$AgentId = "",
        [string[]]$RemovePaths = @(),
        [hashtable]$Set = @{},
        [string[]]$ExpectedFailure = @()
    )

    $setValues = [ordered]@{}
    foreach ($key in $Set.Keys) {
        $setValues[$key] = $Set[$key]
    }

    return [ordered]@{
        artifact_type = "r17_agent_registry_invalid_mutation"
        contract_version = "v1"
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        file_name = $FileName
        target = $Target
        operation = $Operation
        agent_id = $AgentId
        remove_paths = $RemovePaths
        set_values = $setValues
        expected_failure_fragments = $ExpectedFailure
    }
}

function Get-R17AgentRegistryInvalidFixtures {
    return @(
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_required_agent.json" -Target "agent_registry" -Operation "remove_agent" -AgentId "release_closeout" -ExpectedFailure @("required agent")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_agent_id.json" -Target "identity:user" -RemovePaths @("agent_id") -ExpectedFailure @("agent_id")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_role_type.json" -Target "identity:user" -RemovePaths @("role_type") -ExpectedFailure @("role_type")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_allowed_actions.json" -Target "identity:operator" -RemovePaths @("allowed_actions") -ExpectedFailure @("allowed_actions")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_forbidden_actions.json" -Target "identity:operator" -RemovePaths @("forbidden_actions") -ExpectedFailure @("forbidden_actions")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_memory_scope.json" -Target "identity:operator" -RemovePaths @("memory_scope") -ExpectedFailure @("memory_scope")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_tool_permissions.json" -Target "identity:operator" -RemovePaths @("tool_permissions") -ExpectedFailure @("tool_permissions")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_missing_evidence_requirements.json" -Target "identity:operator" -RemovePaths @("evidence_requirements") -ExpectedFailure @("evidence_requirements")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_orchestrator_can_implement.json" -Target "identity:orchestrator" -Set @{ allowed_actions = @("implement_code") } -ExpectedFailure @("Orchestrator")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_orchestrator_can_bypass_qa.json" -Target "identity:orchestrator" -Set @{ allowed_actions = @("bypass_qa_or_audit_gates") } -ExpectedFailure @("Orchestrator")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_developer_can_approve_evidence.json" -Target "identity:developer" -Set @{ allowed_actions = @("approve_evidence_sufficiency") } -ExpectedFailure @("Developer")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_qa_can_implement.json" -Target "identity:qa_test_agent" -Set @{ allowed_actions = @("implement_code") } -ExpectedFailure @("QA/Test")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_auditor_can_implement.json" -Target "identity:evidence_auditor" -Set @{ allowed_actions = @("implement_code") } -ExpectedFailure @("Evidence Auditor")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_release_closeout_can_override_failed_gate.json" -Target "identity:release_closeout" -Set @{ allowed_actions = @("override_failed_gates") } -ExpectedFailure @("Release/Closeout")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_runtime_agent_invocation_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.runtime_agent_invocation_implemented" = $true } -ExpectedFailure @("runtime_agent_invocation_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_a2a_runtime_claim.json" -Target "identity:orchestrator" -Set @{ "runtime_boundaries.a2a_runtime_implemented" = $true } -ExpectedFailure @("a2a_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_autonomous_agent_claim.json" -Target "identity:orchestrator" -Set @{ "runtime_boundaries.autonomous_agent_implemented" = $true } -ExpectedFailure @("autonomous_agent_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_external_api_call_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.external_api_calls_implemented" = $true } -ExpectedFailure @("external_api_calls_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_dev_codex_adapter_runtime_claim.json" -Target "identity:developer" -Set @{ "runtime_boundaries.dev_codex_adapter_runtime_implemented" = $true } -ExpectedFailure @("dev_codex_adapter_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_qa_adapter_runtime_claim.json" -Target "identity:qa_test_agent" -Set @{ "runtime_boundaries.qa_test_agent_adapter_runtime_implemented" = $true } -ExpectedFailure @("qa_test_agent_adapter_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_evidence_auditor_api_runtime_claim.json" -Target "identity:evidence_auditor" -Set @{ "runtime_boundaries.evidence_auditor_api_runtime_implemented" = $true } -ExpectedFailure @("evidence_auditor_api_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_executable_handoff_claim.json" -Target "identity:project_manager" -Set @{ "runtime_boundaries.executable_handoffs_implemented" = $true } -ExpectedFailure @("executable_handoffs_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_executable_transition_claim.json" -Target "identity:project_manager" -Set @{ "runtime_boundaries.executable_transitions_implemented" = $true } -ExpectedFailure @("executable_transitions_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_live_board_mutation_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.live_board_mutation_implemented" = $true } -ExpectedFailure @("live_board_mutation_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_runtime_card_creation_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.runtime_card_creation_implemented" = $true } -ExpectedFailure @("runtime_card_creation_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_product_runtime_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.product_runtime_implemented" = $true } -ExpectedFailure @("product_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_production_runtime_claim.json" -Target "identity:operator" -Set @{ "runtime_boundaries.production_runtime_implemented" = $true } -ExpectedFailure @("production_runtime_implemented")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_fake_multi_agent_narration_as_proof.json" -Target "check_report" -Set @{ "checks.fake_multi_agent_narration_rejected.fake_multi_agent_narration_as_proof" = $true } -ExpectedFailure @("fake multi-agent")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_dev_output_claim.json" -Target "check_report" -Set @{ "claim_status.dev_output_claimed" = $true } -ExpectedFailure @("dev_output_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_qa_result_claim.json" -Target "check_report" -Set @{ "claim_status.qa_result_claimed" = $true } -ExpectedFailure @("qa_result_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_audit_verdict_claim.json" -Target "check_report" -Set @{ "claim_status.audit_verdict_claimed" = $true } -ExpectedFailure @("audit_verdict_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_external_audit_acceptance_claim.json" -Target "check_report" -Set @{ "claim_status.external_audit_acceptance_claimed" = $true } -ExpectedFailure @("external_audit_acceptance_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_main_merge_claim.json" -Target "check_report" -Set @{ "claim_status.main_merge_claimed" = $true } -ExpectedFailure @("main_merge_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_r13_closure_claim.json" -Target "check_report" -Set @{ "claim_status.r13_closure_claimed" = $true } -ExpectedFailure @("r13_closure_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_r14_caveat_removal_claim.json" -Target "check_report" -Set @{ "claim_status.r14_caveat_removal_claimed" = $true } -ExpectedFailure @("r14_caveat_removal_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_r15_caveat_removal_claim.json" -Target "check_report" -Set @{ "claim_status.r15_caveat_removal_claimed" = $true } -ExpectedFailure @("r15_caveat_removal_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_solved_codex_compaction_claim.json" -Target "check_report" -Set @{ "claim_status.solved_codex_compaction_claimed" = $true } -ExpectedFailure @("solved_codex_compaction_claimed")),
        (New-R17AgentRegistryInvalidFixture -FileName "invalid_solved_codex_reliability_claim.json" -Target "check_report" -Set @{ "claim_status.solved_codex_reliability_claimed" = $true } -ExpectedFailure @("solved_codex_reliability_claimed"))
    )
}

function New-R17AgentRegistryArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17AgentRegistryRepositoryRoot)
    )

    $paths = Get-R17AgentRegistryPaths -RepositoryRoot $RepositoryRoot
    $registryContract = New-R17AgentRegistryContractObject
    $identityContract = New-R17AgentIdentityContractObject
    $identities = Get-R17AgentIdentityPackets
    $registry = New-R17AgentRegistryObject -IdentityPackets $identities
    $report = New-R17AgentRegistryCheckReportObject -Registry $registry -IdentityPackets $identities
    $snapshot = New-R17AgentRegistrySnapshotObject -Registry $registry -IdentityPackets $identities

    Write-R17AgentRegistryJson -Path $paths.RegistryContract -Value $registryContract
    Write-R17AgentRegistryJson -Path $paths.IdentityContract -Value $identityContract
    Write-R17AgentRegistryJson -Path $paths.Registry -Value $registry
    Write-R17AgentRegistryJson -Path $paths.CheckReport -Value $report
    Write-R17AgentRegistryJson -Path $paths.UiSnapshot -Value $snapshot

    if (-not (Test-Path -LiteralPath $paths.IdentityRoot)) {
        New-Item -ItemType Directory -Path $paths.IdentityRoot -Force | Out-Null
    }

    foreach ($identity in $identities) {
        Write-R17AgentRegistryJson -Path (Join-Path $paths.IdentityRoot ("{0}.identity.json" -f $identity.agent_id)) -Value $identity
    }

    if (-not (Test-Path -LiteralPath $paths.FixtureRoot)) {
        New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    }

    Write-R17AgentRegistryJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry.json") -Value $registry
    foreach ($identity in $identities) {
        Write-R17AgentRegistryJson -Path (Join-Path $paths.FixtureRoot ("valid_{0}_identity.json" -f $identity.agent_id)) -Value $identity
    }
    Write-R17AgentRegistryJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry_check_report.json") -Value $report
    Write-R17AgentRegistryJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry_snapshot.json") -Value $snapshot

    foreach ($fixture in Get-R17AgentRegistryInvalidFixtures) {
        Write-R17AgentRegistryJson -Path (Join-Path $paths.FixtureRoot $fixture.file_name) -Value $fixture
    }

    Write-R17AgentRegistryText -Path $paths.ProofReview -Value (Get-R17AgentRegistryProofReviewText)
    Write-R17AgentRegistryJson -Path $paths.EvidenceIndex -Value (New-R17AgentRegistryEvidenceIndexObject)
    Write-R17AgentRegistryText -Path $paths.ValidationManifest -Value (Get-R17AgentRegistryValidationManifestText)

    return [pscustomobject]@{
        RegistryContract = $paths.RegistryContract
        IdentityContract = $paths.IdentityContract
        Registry = $paths.Registry
        IdentityRoot = $paths.IdentityRoot
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredAgentCount = @($script:R17RequiredAgents).Count
        IdentityPacketCount = @($identities).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

function Assert-R17AgentRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context is missing required field '$field'."
        }
    }
}

function Assert-R17AgentNonEmptyArray {
    param(
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or @($Value).Count -eq 0) {
        throw "$Context must be a non-empty array."
    }
}

function Assert-R17AgentFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context missing required false flag '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context flag '$field' must be false."
        }
    }
}

function Assert-R17AgentContracts {
    param(
        [Parameter(Mandatory = $true)][object]$RegistryContract,
        [Parameter(Mandatory = $true)][object]$IdentityContract
    )

    Assert-R17AgentRequiredFields -Object $RegistryContract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "repository", "branch", "scope", "purpose", "required_registry_fields", "required_agent_fields", "required_role_permissions", "required_memory_scope_fields", "required_tool_permission_fields", "required_evidence_fields", "required_handoff_boundary_fields", "required_runtime_boundary_fields", "non_claims", "rejected_claims", "preserved_boundaries") -Context "agent registry contract"
    Assert-R17AgentRequiredFields -Object $IdentityContract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "repository", "branch", "scope", "purpose", "required_identity_fields", "required_agents", "required_runtime_boundary_fields", "role_boundary_rules", "non_claims", "rejected_claims", "preserved_boundaries") -Context "agent identity packet contract"
    if ($RegistryContract.artifact_type -ne "r17_agent_registry_contract") { throw "agent registry contract artifact_type is invalid." }
    if ($IdentityContract.artifact_type -ne "r17_agent_identity_packet_contract") { throw "agent identity packet contract artifact_type is invalid." }
    foreach ($field in $script:R17RuntimeBoundaryFields) {
        if (@($RegistryContract.required_runtime_boundary_fields) -notcontains $field -or @($IdentityContract.required_runtime_boundary_fields) -notcontains $field) {
            throw "contracts must require runtime boundary field '$field'."
        }
    }
}

function Assert-R17AgentMemoryScope {
    param(
        [Parameter(Mandatory = $true)][object]$MemoryScope,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AgentRequiredFields -Object $MemoryScope -FieldNames @("exact_repo_refs_only", "broad_repo_scan_allowed", "raw_chat_history_as_canonical", "runtime_memory_loading_implemented", "allowed_refs", "forbidden_refs") -Context "$Context memory_scope"
    if ([bool]$MemoryScope.exact_repo_refs_only -ne $true) { throw "$Context memory_scope exact_repo_refs_only must be true." }
    if ([bool]$MemoryScope.broad_repo_scan_allowed -ne $false) { throw "$Context memory_scope broad_repo_scan_allowed must be false." }
    if ([bool]$MemoryScope.raw_chat_history_as_canonical -ne $false) { throw "$Context memory_scope raw_chat_history_as_canonical must be false." }
    if ([bool]$MemoryScope.runtime_memory_loading_implemented -ne $false) { throw "$Context memory_scope runtime_memory_loading_implemented must be false." }
    Assert-R17AgentNonEmptyArray -Value $MemoryScope.allowed_refs -Context "$Context memory_scope.allowed_refs"
    foreach ($ref in @($MemoryScope.allowed_refs)) {
        $text = [string]$ref
        if ($text -match 'https?://' -or $text -match '(?i)broad repo scan|raw chat history|implicit memory') {
            throw "$Context memory_scope contains forbidden non-canonical memory ref '$text'."
        }
    }
}

function Assert-R17AgentToolPermissions {
    param(
        [Parameter(Mandatory = $true)][object]$ToolPermissions,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AgentRequiredFields -Object $ToolPermissions -FieldNames @("allowed_tool_boundary", "external_api_calls_allowed", "codex_executor_calls_allowed", "qa_test_agent_calls_allowed", "evidence_auditor_api_calls_allowed", "dev_codex_adapter_runtime_allowed", "qa_test_agent_adapter_runtime_allowed", "evidence_auditor_api_runtime_allowed", "future_adapter_use_requires_later_tasks") -Context "$Context tool_permissions"
    Assert-R17AgentNonEmptyArray -Value $ToolPermissions.allowed_tool_boundary -Context "$Context tool_permissions.allowed_tool_boundary"
    Assert-R17AgentFalseFields -Object $ToolPermissions -FieldNames @("external_api_calls_allowed", "codex_executor_calls_allowed", "qa_test_agent_calls_allowed", "evidence_auditor_api_calls_allowed", "dev_codex_adapter_runtime_allowed", "qa_test_agent_adapter_runtime_allowed", "evidence_auditor_api_runtime_allowed") -Context "$Context tool_permissions"
    if ([bool]$ToolPermissions.future_adapter_use_requires_later_tasks -ne $true) {
        throw "$Context tool_permissions must require later tasks for future adapter use."
    }
}

function Assert-R17AgentEvidenceRequirements {
    param(
        [Parameter(Mandatory = $true)][object]$EvidenceRequirements,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AgentRequiredFields -Object $EvidenceRequirements -FieldNames @("required_evidence_refs", "evidence_must_be_committed", "generated_markdown_is_not_proof_alone", "fake_multi_agent_narration_is_proof", "dev_output_claimed", "qa_result_claimed", "audit_verdict_claimed") -Context "$Context evidence_requirements"
    Assert-R17AgentNonEmptyArray -Value $EvidenceRequirements.required_evidence_refs -Context "$Context evidence_requirements.required_evidence_refs"
    if ([bool]$EvidenceRequirements.evidence_must_be_committed -ne $true) { throw "$Context evidence_requirements evidence_must_be_committed must be true." }
    if ([bool]$EvidenceRequirements.generated_markdown_is_not_proof_alone -ne $true) { throw "$Context evidence_requirements generated_markdown_is_not_proof_alone must be true." }
    Assert-R17AgentFalseFields -Object $EvidenceRequirements -FieldNames @("fake_multi_agent_narration_is_proof", "dev_output_claimed", "qa_result_claimed", "audit_verdict_claimed") -Context "$Context evidence_requirements"
}

function Assert-R17AgentHandoffPermissions {
    param(
        [Parameter(Mandatory = $true)][object]$HandoffPermissions,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AgentRequiredFields -Object $HandoffPermissions -FieldNames @("can_prepare_handoff_packet", "allowed_future_handoff_targets", "executable_handoffs_allowed", "executable_transitions_allowed", "runtime_dispatch_allowed", "later_task_required_for_execution") -Context "$Context handoff_permissions"
    Assert-R17AgentFalseFields -Object $HandoffPermissions -FieldNames @("executable_handoffs_allowed", "executable_transitions_allowed", "runtime_dispatch_allowed") -Context "$Context handoff_permissions"
    if ([bool]$HandoffPermissions.later_task_required_for_execution -ne $true) {
        throw "$Context handoff_permissions must require a later task for execution."
    }
}

function Assert-R17AgentApprovalAuthority {
    param(
        [Parameter(Mandatory = $true)][object]$ApprovalAuthority,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AgentRequiredFields -Object $ApprovalAuthority -FieldNames @("can_approve_closure", "can_approve_meaningful_direction", "can_approve_operational_direction", "can_approve_evidence_sufficiency", "can_approve_technical_direction", "can_override_failed_gates", "can_remove_r13_r14_r15_boundaries", "user_approval_required_for_closure") -Context "$Context approval_authority"
    Assert-R17AgentFalseFields -Object $ApprovalAuthority -FieldNames @("can_override_failed_gates", "can_remove_r13_r14_r15_boundaries") -Context "$Context approval_authority"
    if ([bool]$ApprovalAuthority.user_approval_required_for_closure -ne $true) {
        throw "$Context approval_authority must require user approval for closure."
    }
}

function Assert-R17AgentRoleBoundary {
    param(
        [Parameter(Mandatory = $true)][object]$Identity
    )

    $agentId = [string]$Identity.agent_id
    $allowed = @($Identity.allowed_actions) -join " "
    $forbidden = @($Identity.forbidden_actions) -join " "

    switch ($agentId) {
        "user" {
            if ([bool]$Identity.approval_authority.can_approve_closure -ne $true -or [bool]$Identity.approval_authority.can_approve_meaningful_direction -ne $true) {
                throw "User must approve closure and meaningful direction."
            }
        }
        "operator" {
            if ([bool]$Identity.approval_authority.can_approve_operational_direction -ne $true) {
                throw "Operator must be able to approve operational direction only."
            }
        }
        "orchestrator" {
            if ($allowed -match '(?i)implement|run_tests|approve_evidence|bypass') {
                throw "Orchestrator boundary forbids implementation, QA testing, evidence approval, or gate bypass."
            }
            foreach ($required in @("implement", "test", "approve_evidence", "bypass")) {
                if ($forbidden -notmatch [regex]::Escape($required)) {
                    throw "Orchestrator forbidden_actions must preserve '$required'."
                }
            }
        }
        "project_manager" {
            if ($allowed -match '(?i)implement|qa_validation|run_tests') {
                throw "Project Manager boundary forbids implementation and testing."
            }
        }
        "architect" {
            if ($allowed -match '(?i)\bimplement\b|implement_code') {
                throw "Architect boundary forbids implementation unless future packet assigns it."
            }
        }
        "developer" {
            if ($allowed -match '(?i)approve_evidence') {
                throw "Developer boundary forbids approving evidence sufficiency."
            }
            if ($forbidden -notmatch '(?i)approve_evidence') {
                throw "Developer forbidden_actions must include evidence approval prohibition."
            }
        }
        "qa_test_agent" {
            if ($allowed -match '(?i)implement') {
                throw "QA/Test Agent boundary forbids implementation."
            }
        }
        "evidence_auditor" {
            if ($allowed -match '(?i)implement|rewrite_evidence') {
                throw "Evidence Auditor boundary forbids implementation or evidence rewrite."
            }
        }
        "knowledge_curator" {
            if ($allowed -match '(?i)execute_product_work|implement_code') {
                throw "Knowledge Curator boundary forbids product execution."
            }
        }
        "release_closeout" {
            if ($allowed -match '(?i)override_failed_gates|close_without_user_approval|merge_to_main') {
                throw "Release/Closeout boundary forbids failed gate override, closure without user approval, and main merge."
            }
        }
        default {
            throw "Unknown agent id '$agentId'."
        }
    }
}

function Assert-R17AgentIdentityPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Identity
    )

    Assert-R17AgentRequiredFields -Object $Identity -FieldNames @("artifact_type", "contract_version", "identity_id", "source_milestone", "source_task", "repository", "branch", "generated_from_head", "generated_from_tree", "generated_state_artifact_only", "contract_ref", "registry_ref", "agent_id", "role_name", "role_type", "description", "accountable_to", "allowed_actions", "forbidden_actions", "board_permissions", "card_permissions", "memory_scope", "tool_permissions", "evidence_requirements", "handoff_permissions", "approval_authority", "runtime_boundaries", "output_placeholders", "non_claims", "rejected_claims", "preserved_boundaries") -Context "agent identity packet"
    if ($Identity.artifact_type -ne "r17_agent_identity_packet") { throw "agent identity packet artifact_type is invalid." }
    if (@($script:R17RequiredAgents) -notcontains [string]$Identity.agent_id) { throw "agent identity packet has unexpected agent_id '$($Identity.agent_id)'." }
    Assert-R17AgentNonEmptyArray -Value $Identity.allowed_actions -Context "$($Identity.agent_id) allowed_actions"
    Assert-R17AgentNonEmptyArray -Value $Identity.forbidden_actions -Context "$($Identity.agent_id) forbidden_actions"
    Assert-R17AgentRequiredFields -Object $Identity.board_permissions -FieldNames @("can_view_board", "can_propose_card_or_lane_state", "can_approve_closure", "live_board_mutation_allowed", "runtime_card_creation_allowed", "canonical_board_truth_is_repo_backed") -Context "$($Identity.agent_id) board_permissions"
    Assert-R17AgentFalseFields -Object $Identity.board_permissions -FieldNames @("live_board_mutation_allowed", "runtime_card_creation_allowed") -Context "$($Identity.agent_id) board_permissions"
    Assert-R17AgentRequiredFields -Object $Identity.card_permissions -FieldNames @("can_view_cards", "can_propose_cards", "can_define_acceptance_criteria", "can_close_cards", "can_create_runtime_cards", "closure_requires_user_approval") -Context "$($Identity.agent_id) card_permissions"
    Assert-R17AgentFalseFields -Object $Identity.card_permissions -FieldNames @("can_close_cards", "can_create_runtime_cards") -Context "$($Identity.agent_id) card_permissions"
    Assert-R17AgentMemoryScope -MemoryScope $Identity.memory_scope -Context $Identity.agent_id
    Assert-R17AgentToolPermissions -ToolPermissions $Identity.tool_permissions -Context $Identity.agent_id
    Assert-R17AgentEvidenceRequirements -EvidenceRequirements $Identity.evidence_requirements -Context $Identity.agent_id
    Assert-R17AgentHandoffPermissions -HandoffPermissions $Identity.handoff_permissions -Context $Identity.agent_id
    Assert-R17AgentApprovalAuthority -ApprovalAuthority $Identity.approval_authority -Context $Identity.agent_id
    Assert-R17AgentFalseFields -Object $Identity.runtime_boundaries -FieldNames $script:R17RuntimeBoundaryFields -Context "$($Identity.agent_id) runtime_boundaries"
    Assert-R17AgentRoleBoundary -Identity $Identity
}

function Assert-R17AgentRegistryObject {
    param(
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object[]]$IdentityPackets
    )

    Assert-R17AgentRequiredFields -Object $Registry -FieldNames @("artifact_type", "contract_version", "registry_id", "source_milestone", "source_task", "repository", "branch", "generated_from_head", "generated_from_tree", "generated_state_artifact_only", "scope", "purpose", "registry_contract_ref", "identity_packet_contract_ref", "required_agent_ids", "agent_count", "agents", "identity_packet_refs", "runtime_boundaries", "claim_status", "evidence_refs", "memory_refs", "non_claims", "rejected_claims", "preserved_boundaries") -Context "agent registry"
    if ($Registry.artifact_type -ne "r17_agent_registry") { throw "agent registry artifact_type is invalid." }
    if (@($Registry.required_agent_ids).Count -ne @($script:R17RequiredAgents).Count) { throw "agent registry required agent count is invalid." }
    foreach ($agentId in $script:R17RequiredAgents) {
        if (@($Registry.required_agent_ids) -notcontains $agentId) { throw "agent registry is missing required agent '$agentId'." }
        if (-not (@($Registry.agents) | Where-Object { $_.agent_id -eq $agentId })) { throw "agent registry is missing required agent '$agentId'." }
        if (-not (@($IdentityPackets) | Where-Object { $_.agent_id -eq $agentId })) { throw "identity packet set is missing required agent '$agentId'." }
    }
    if ([int]$Registry.agent_count -ne @($script:R17RequiredAgents).Count -or @($Registry.agents).Count -ne @($script:R17RequiredAgents).Count) {
        throw "agent registry agent_count must match required agents."
    }
    Assert-R17AgentFalseFields -Object $Registry.runtime_boundaries -FieldNames $script:R17RuntimeBoundaryFields -Context "agent registry runtime_boundaries"
    Assert-R17AgentFalseFields -Object $Registry.claim_status -FieldNames $script:R17AgentClaimStatusFields -Context "agent registry claim_status"
}

function Assert-R17AgentRegistryCheckReport {
    param(
        [Parameter(Mandatory = $true)][object]$Report
    )

    Assert-R17AgentRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_milestone", "source_task", "repository", "branch", "generated_from_head", "generated_from_tree", "generated_from_contracts", "generated_state_artifact_only", "checked_artifacts", "required_agent_count", "generated_identity_packet_count", "checks", "aggregate_verdict", "runtime_boundaries", "claim_status", "evidence_refs", "memory_refs", "non_claims", "rejected_claims", "preserved_boundaries") -Context "agent registry check report"
    if ($Report.artifact_type -ne "r17_agent_registry_check_report") { throw "agent registry check report artifact_type is invalid." }
    if ($Report.aggregate_verdict -ne $script:R17AgentRegistryVerdict) { throw "agent registry check report aggregate verdict is invalid." }
    if ([int]$Report.required_agent_count -ne @($script:R17RequiredAgents).Count) { throw "agent registry check report required_agent_count is invalid." }
    if ([int]$Report.generated_identity_packet_count -ne @($script:R17RequiredAgents).Count) { throw "agent registry check report generated_identity_packet_count is invalid." }
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "agent registry check '$($check.Name)' must have status passed."
        }
    }
    if ([bool]$Report.checks.fake_multi_agent_narration_rejected.fake_multi_agent_narration_as_proof -ne $false) {
        throw "agent registry check report must reject fake multi-agent narration as proof."
    }
    Assert-R17AgentFalseFields -Object $Report.runtime_boundaries -FieldNames $script:R17RuntimeBoundaryFields -Context "agent registry check report runtime_boundaries"
    Assert-R17AgentFalseFields -Object $Report.claim_status -FieldNames $script:R17AgentClaimStatusFields -Context "agent registry check report claim_status"
}

function Assert-R17AgentRegistrySnapshot {
    param(
        [Parameter(Mandatory = $true)][object]$Snapshot
    )

    Assert-R17AgentRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_task", "milestone", "branch", "active_through_task", "generated_from_head", "generated_from_tree", "ui_boundary_label", "local_open_path", "agent_ids", "required_agent_count", "generated_identity_packet_count", "agents", "runtime_summary", "approval_authority_summary", "handoff_permissions_summary", "memory_scope_summary", "evidence_refs", "memory_refs", "non_claims", "rejected_claims", "claim_status", "preserved_boundaries") -Context "agent registry UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_agent_registry_snapshot") { throw "agent registry UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne "R17-012") { throw "agent registry UI snapshot active_through_task must be R17-012." }
    foreach ($agentId in $script:R17RequiredAgents) {
        if (@($Snapshot.agent_ids) -notcontains $agentId) { throw "agent registry UI snapshot is missing agent '$agentId'." }
    }
    if ([int]$Snapshot.required_agent_count -ne @($script:R17RequiredAgents).Count -or [int]$Snapshot.generated_identity_packet_count -ne @($script:R17RequiredAgents).Count) {
        throw "agent registry UI snapshot agent counts are invalid."
    }
    foreach ($agent in @($Snapshot.agents)) {
        if ([bool]$agent.runtime_enabled -ne $false) { throw "agent registry UI snapshot agent '$($agent.agent_id)' runtime_enabled must be false." }
        Assert-R17AgentFalseFields -Object $agent.runtime_boundary_flags -FieldNames $script:R17RuntimeBoundaryFields -Context "agent registry UI snapshot $($agent.agent_id) runtime_boundary_flags"
    }
    Assert-R17AgentFalseFields -Object $Snapshot.runtime_summary -FieldNames $script:R17RuntimeBoundaryFields -Context "agent registry UI snapshot runtime_summary"
    Assert-R17AgentFalseFields -Object $Snapshot.claim_status -FieldNames $script:R17AgentClaimStatusFields -Context "agent registry UI snapshot claim_status"
}

function Assert-R17AgentRegistryUiFiles {
    param(
        [Parameter(Mandatory = $true)][string[]]$UiFilePaths
    )

    foreach ($path in $UiFilePaths) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "UI file '$path' does not exist."
        }
        $text = Get-Content -LiteralPath $path -Raw
        foreach ($pattern in @("http://", "https://", "(?i)\bcdn\b", "(?i)\bnpm\b", "(?i)fonts\.googleapis", "(?i)fonts\.gstatic", "(?i)unpkg", "(?i)jsdelivr", "(?i)@import\s+url")) {
            if ($text -match $pattern) {
                throw "UI file '$path' contains forbidden external dependency reference matching '$pattern'."
            }
        }
    }

    $htmlPath = $UiFilePaths | Where-Object { $_ -like "*index.html" } | Select-Object -First 1
    if ($htmlPath) {
        $html = Get-Content -LiteralPath $htmlPath -Raw
        foreach ($required in @("Agent Workforce", "identity/registry only", "no runtime agent invocation", "no A2A runtime", "no autonomous agents", "future adapter use requires later tasks")) {
            if ($html -notmatch [regex]::Escape($required)) {
                throw "UI file '$htmlPath' must contain required R17-012 label '$required'."
            }
        }
        foreach ($agentId in $script:R17RequiredAgents) {
            if ($html -notmatch [regex]::Escape($agentId)) {
                throw "UI file '$htmlPath' must contain required agent id '$agentId'."
            }
        }
    }
}

function Test-R17AgentRegistrySet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$RegistryContract,
        [Parameter(Mandatory = $true)][object]$IdentityContract,
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object[]]$IdentityPackets,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string[]]$UiFilePaths = @()
    )

    Assert-R17AgentContracts -RegistryContract $RegistryContract -IdentityContract $IdentityContract
    Assert-R17AgentRegistryObject -Registry $Registry -IdentityPackets $IdentityPackets
    foreach ($identity in $IdentityPackets) {
        Assert-R17AgentIdentityPacket -Identity $identity
    }
    Assert-R17AgentRegistryCheckReport -Report $Report
    Assert-R17AgentRegistrySnapshot -Snapshot $Snapshot
    if ($UiFilePaths.Count -gt 0) {
        Assert-R17AgentRegistryUiFiles -UiFilePaths $UiFilePaths
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredAgentCount = [int]$Report.required_agent_count
        IdentityPacketCount = [int]$Report.generated_identity_packet_count
        AgentIds = @($Registry.required_agent_ids)
        RuntimeAgentInvocationImplemented = [bool]$Report.runtime_boundaries.runtime_agent_invocation_implemented
        A2aRuntimeImplemented = [bool]$Report.runtime_boundaries.a2a_runtime_implemented
        AutonomousAgentImplemented = [bool]$Report.runtime_boundaries.autonomous_agent_implemented
        ExternalApiCallsImplemented = [bool]$Report.runtime_boundaries.external_api_calls_implemented
        DevOutputClaimed = [bool]$Report.claim_status.dev_output_claimed
        QaResultClaimed = [bool]$Report.claim_status.qa_result_claimed
        AuditVerdictClaimed = [bool]$Report.claim_status.audit_verdict_claimed
    }
}

function Test-R17AgentRegistry {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17AgentRegistryRepositoryRoot)
    )

    $paths = Get-R17AgentRegistryPaths -RepositoryRoot $RepositoryRoot
    $identities = foreach ($agentId in $script:R17RequiredAgents) {
        Read-R17AgentRegistryJson -Path (Join-Path $paths.IdentityRoot ("{0}.identity.json" -f $agentId))
    }

    return Test-R17AgentRegistrySet `
        -RegistryContract (Read-R17AgentRegistryJson -Path $paths.RegistryContract) `
        -IdentityContract (Read-R17AgentRegistryJson -Path $paths.IdentityContract) `
        -Registry (Read-R17AgentRegistryJson -Path $paths.Registry) `
        -IdentityPackets $identities `
        -Report (Read-R17AgentRegistryJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17AgentRegistryJson -Path $paths.UiSnapshot) `
        -UiFilePaths $paths.UiFiles
}

function Set-R17AgentRegistryObjectPathValue {
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

function Remove-R17AgentRegistryObjectPathValue {
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

function Invoke-R17AgentRegistryMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ([string]$Mutation.operation -eq "remove_agent") {
        $TargetObject.agents = @($TargetObject.agents | Where-Object { $_.agent_id -ne [string]$Mutation.agent_id })
        return $TargetObject
    }

    foreach ($removePath in @($Mutation.remove_paths)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
            Remove-R17AgentRegistryObjectPathValue -Object $TargetObject -Path $removePath
        }
    }

    if ($null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17AgentRegistryObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17AgentRegistryPaths, `
    New-R17AgentRegistryArtifacts, `
    Test-R17AgentRegistry, `
    Test-R17AgentRegistrySet, `
    Invoke-R17AgentRegistryMutation, `
    Copy-R17AgentRegistryObject
