Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot

function Get-R17OperatorIntakeRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17OperatorIntakePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$RepositoryRoot = (Get-R17OperatorIntakeRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17Json {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17Json {
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

function Write-R17Text {
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

function Copy-R17Object {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17OperatorIntakePaths {
    param(
        [string]$RepositoryRoot = (Get-R17OperatorIntakeRepositoryRoot)
    )

    $proofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface"
    $fixtureRoot = "tests/fixtures/r17_operator_intake_surface"

    return [pscustomobject]@{
        Contract = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/intake/r17_operator_intake.contract.json"
        SeedPacket = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/intake/r17_operator_intake_seed_packet.json"
        Proposal = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/intake/r17_orchestrator_intake_proposal.json"
        CheckReport = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/intake/r17_operator_intake_check_report.json"
        UiSnapshot = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json"
        FixtureRoot = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        ProofRoot = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        ProofReview = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        EvidenceIndex = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ValidationManifest = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        UiFiles = @(
            (Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/kanban.js"),
            (Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md")
        )
    }
}

function Get-R17OperatorIntakeNonClaims {
    return @(
        "R17-011 implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only",
        "R17-011 creates generated operator intake seed packet, non-executable Orchestrator intake proposal, check report, and UI snapshot only",
        "R17-011 updates the local/static Kanban MVP with an intake preview panel only",
        "R17-011 does not implement live Orchestrator runtime",
        "R17-011 does not implement live board mutation",
        "R17-011 does not create runtime cards",
        "R17-011 does not implement A2A runtime",
        "R17-011 does not implement Dev/Codex executor adapter",
        "R17-011 does not implement QA/Test Agent adapter",
        "R17-011 does not implement Evidence Auditor API adapter",
        "R17-011 does not call external APIs",
        "R17-011 does not call Codex as executor",
        "R17-011 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders",
        "R17-011 does not claim autonomous agents",
        "R17-011 does not claim product runtime",
        "R17-011 does not claim production runtime",
        "R17-011 does not claim executable handoffs or executable transitions",
        "R17-011 does not claim external audit acceptance",
        "R17-011 does not claim main merge",
        "R13 boundary preserved",
        "R14 caveats preserved",
        "R15 caveats preserved",
        "R16 boundary preserved",
        "R17-012 through R17-028 remain planned only",
        "R17-011 does not claim solved Codex compaction",
        "R17-011 does not claim solved Codex reliability"
    )
}

function Get-R17OperatorIntakeRejectedClaims {
    return @(
        "live_board_mutation",
        "Orchestrator_runtime",
        "A2A_runtime",
        "autonomous_agents",
        "Dev_Codex_executor_adapter_runtime",
        "QA_Test_Agent_adapter_runtime",
        "Evidence_Auditor_API_adapter_runtime",
        "external_API_calls",
        "executable_handoffs",
        "executable_transitions",
        "external_integrations",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "production_runtime",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability"
    )
}

function Get-R17OperatorIntakeRuntimeBoundaries {
    return [ordered]@{
        operator_intake_runtime_server_implemented = $false
        live_orchestrator_runtime_implemented = $false
        live_board_mutation_implemented = $false
        card_creation_runtime_implemented = $false
        a2a_runtime_implemented = $false
        dev_codex_adapter_runtime_implemented = $false
        qa_test_agent_adapter_runtime_implemented = $false
        evidence_auditor_api_runtime_implemented = $false
        external_api_calls_implemented = $false
        executable_handoffs_implemented = $false
        executable_transitions_implemented = $false
        autonomous_agents_implemented = $false
        product_runtime_implemented = $false
        production_runtime_implemented = $false
    }
}

function Get-R17OperatorIntakeClaimStatus {
    return [ordered]@{
        external_audit_acceptance_claimed = $false
        main_merge_claimed = $false
        r13_closure_claimed = $false
        r14_caveat_removal_claimed = $false
        r15_caveat_removal_claimed = $false
        solved_codex_compaction_claimed = $false
        solved_codex_reliability_claimed = $false
    }
}

function Get-R17OperatorIntakePreservedBoundaries {
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

function Get-R17OperatorIntakeMemoryRefs {
    return @(
        [ordered]@{ ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"; boundary = "exact repo ref only, not hidden chat memory" },
        [ordered]@{ ref = "execution/KANBAN.md"; boundary = "exact repo ref only, status surface not runtime board mutation" },
        [ordered]@{ ref = "governance/ACTIVE_STATE.md"; boundary = "exact repo ref only, status surface" },
        [ordered]@{ ref = "governance/DOCUMENT_AUTHORITY_INDEX.md"; boundary = "exact repo ref only, authority classification" },
        [ordered]@{ ref = "governance/DECISION_LOG.md"; boundary = "exact repo ref only, decision authority" },
        [ordered]@{ ref = "governance/VISION.md"; boundary = "exact repo ref only, product doctrine" },
        [ordered]@{ ref = "state/governance/r17_kpi_baseline_target_scorecard.json"; boundary = "exact repo ref only, target scores are not achieved implementation evidence" },
        [ordered]@{ ref = "contracts/board/r17_card.contract.json"; boundary = "exact repo ref only, card contract model" },
        [ordered]@{ ref = "contracts/board/r17_board_state.contract.json"; boundary = "exact repo ref only, board state contract model" },
        [ordered]@{ ref = "contracts/board/r17_board_event.contract.json"; boundary = "exact repo ref only, board event contract model" },
        [ordered]@{ ref = "contracts/agents/r17_orchestrator_identity_authority.contract.json"; boundary = "exact repo ref only, Orchestrator authority model" },
        [ordered]@{ ref = "state/agents/r17_orchestrator_identity_authority.json"; boundary = "exact repo ref only, generated state artifact only" },
        [ordered]@{ ref = "state/agents/r17_orchestrator_route_recommendation_seed.json"; boundary = "exact repo ref only, non-executable route recommendation seed" },
        [ordered]@{ ref = "state/agents/r17_orchestrator_authority_check_report.json"; boundary = "exact repo ref only, authority compatibility report" },
        [ordered]@{ ref = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"; boundary = "exact repo ref only, loop state-machine contract" },
        [ordered]@{ ref = "state/orchestration/r17_orchestrator_loop_state_machine.json"; boundary = "exact repo ref only, generated non-runtime state-machine artifact" },
        [ordered]@{ ref = "state/orchestration/r17_orchestrator_loop_seed_evaluation.json"; boundary = "exact repo ref only, deterministic non-executable seed evaluation" },
        [ordered]@{ ref = "state/orchestration/r17_orchestrator_loop_transition_check_report.json"; boundary = "exact repo ref only, transition check report" },
        [ordered]@{ ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"; boundary = "exact repo ref only, generated board state artifact" },
        [ordered]@{ ref = "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json"; boundary = "exact repo ref only, read-only static UI snapshot" },
        [ordered]@{ ref = "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json"; boundary = "exact repo ref only, read-only card detail snapshot" },
        [ordered]@{ ref = "state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json"; boundary = "exact repo ref only, read-only event/evidence snapshot" }
    )
}

function Get-R17OperatorIntakeEvidenceRefs {
    return @(
        "contracts/intake/r17_operator_intake.contract.json",
        "state/intake/r17_operator_intake_seed_packet.json",
        "state/intake/r17_orchestrator_intake_proposal.json",
        "state/intake/r17_operator_intake_check_report.json",
        "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json",
        "contracts/agents/r17_orchestrator_identity_authority.contract.json",
        "state/agents/r17_orchestrator_identity_authority.json",
        "state/agents/r17_orchestrator_authority_check_report.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_state_machine.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json",
        "scripts/operator_wall/r17_kanban_mvp/index.html",
        "scripts/operator_wall/r17_kanban_mvp/styles.css",
        "scripts/operator_wall/r17_kanban_mvp/kanban.js",
        "scripts/operator_wall/r17_kanban_mvp/README.md",
        "tools/R17OperatorIntakeSurface.psm1",
        "tools/new_r17_operator_intake_surface.ps1",
        "tools/validate_r17_operator_intake_surface.ps1",
        "tests/test_r17_operator_intake_surface.ps1",
        "tests/fixtures/r17_operator_intake_surface/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface/"
    )
}

function New-R17OperatorIntakeContractObject {
    return [ordered]@{
        artifact_type = "r17_operator_intake_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-011-operator-intake-contract-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-011"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "bounded_operator_intake_contract_and_static_preview_only"
        purpose = "Define the governed operator intake packet and non-executable Orchestrator intake proposal boundary without implementing live Orchestrator runtime, live board mutation, runtime card creation, A2A runtime, adapters, external APIs, autonomous agents, executable handoffs, executable transitions, product runtime, or production runtime."
        required_intake_fields = @(
            "intake_id",
            "source_task",
            "submitted_by",
            "submitted_at_utc",
            "raw_operator_request",
            "normalized_request",
            "intent_type",
            "requested_outcome",
            "target_milestone",
            "target_branch",
            "urgency",
            "acceptance_notes",
            "constraints",
            "explicit_non_goals",
            "user_decision_required",
            "evidence_refs",
            "memory_refs",
            "non_claims",
            "rejected_claims"
        )
        allowed_intent_types = @(
            "create_work_card",
            "request_status",
            "request_user_decision",
            "request_release_step",
            "request_audit",
            "request_qa",
            "request_research",
            "request_clarification"
        )
        bounded_seed_intent_type = "create_work_card"
        required_classification_fields = @(
            "classification_id",
            "source_intake_id",
            "intent_type",
            "requested_outcome",
            "target_milestone",
            "target_branch",
            "recommended_loop_state",
            "recommended_lane",
            "recommended_owner_role",
            "recommended_next_role",
            "user_decision_required",
            "evidence_refs",
            "memory_refs",
            "non_claims",
            "rejected_claims"
        )
        required_orchestrator_proposal_fields = @(
            "proposal_id",
            "source_intake_id",
            "orchestrator_agent_id",
            "recommended_action",
            "recommended_loop_state",
            "recommended_card_id",
            "recommended_lane",
            "recommended_owner_role",
            "recommended_next_role",
            "user_decision_required",
            "closure_requires_user_approval",
            "non_executable_proposal",
            "runtime_orchestrator_invoked",
            "board_mutation_performed",
            "card_created",
            "agent_invocation_performed",
            "a2a_message_sent",
            "api_call_performed",
            "dev_output_claimed",
            "qa_result_claimed",
            "audit_verdict_claimed",
            "evidence_refs",
            "memory_refs",
            "non_claims",
            "rejected_claims"
        )
        required_card_proposal_fields = @(
            "card_proposal_id",
            "source_intake_id",
            "proposed_card_id",
            "proposed_task_id",
            "title",
            "description",
            "double_diamond_stage",
            "proposed_lane",
            "proposed_owner_role",
            "proposed_next_role",
            "acceptance_criteria",
            "qa_criteria",
            "evidence_requirements",
            "memory_refs",
            "non_executable_card_proposal",
            "runtime_card_created",
            "live_board_mutation_performed",
            "user_decision_required",
            "closure_requires_user_approval",
            "non_claims",
            "rejected_claims"
        )
        required_user_decision_fields = @(
            "user_decision_required",
            "decision_type",
            "next_expected_role",
            "next_expected_future_task",
            "copy_save_manual_until_future_runtime",
            "closure_requires_user_approval"
        )
        evidence_requirements = [ordered]@{
            seed_packet_must_reference_contract = $true
            proposal_must_reference_seed_packet = $true
            proposal_must_reference_orchestrator_authority = $true
            proposal_must_reference_loop_state_machine = $true
            check_report_must_reference_packet_and_proposal = $true
            generated_markdown_is_operator_readable_only_unless_backed_by_validation = $true
        }
        memory_scope_rules = [ordered]@{
            exact_ref_only = $true
            broad_repo_scan_allowed = $false
            raw_chat_history_is_canonical = $false
            hidden_chat_memory_for_routing_allowed = $false
            repo_truth_must_remain_canonical = $true
            allowed_exact_refs = @(Get-R17OperatorIntakeMemoryRefs)
        }
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        runtime_boundaries = Get-R17OperatorIntakeRuntimeBoundaries
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function New-R17OperatorIntakeSeedPacketObject {
    $rawRequest = "Create a governed R17 work card to continue from the current read-only Kanban and Orchestrator state-machine foundation into an operator interaction surface."
    return [ordered]@{
        artifact_type = "r17_operator_intake_packet"
        contract_version = "v1"
        intake_id = "aioffice-r17-011-operator-intake-seed-packet-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-011"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = "cdbbdc76ddb16bc1fafcb8acd3add7c2eedda193"
        generated_from_tree = "1545a8d05a7051b7e9c461a10ebb2b7bd7f3f703"
        generated_state_artifact_only = $true
        seed_demo_intake_only = $true
        seed_demo_intake_not_runtime_user_intake = $true
        submitted_by = "operator"
        submitted_at_utc = "2026-05-08T00:00:00Z"
        raw_operator_request = $rawRequest
        normalized_request = "Create a governed R17-011 work-card proposal for a bounded operator interaction/intake surface that compiles a seed operator request into governed intake and non-executable Orchestrator proposal artifacts."
        intent_type = "create_work_card"
        requested_outcome = "bounded operator interaction/intake surface plus deterministic intake packet and non-executable Orchestrator proposal generation"
        target_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        target_branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        urgency = "normal"
        acceptance_notes = @(
            "Show where the operator submits intent.",
            "Show how intent becomes a governed intake packet.",
            "Show how Orchestrator would classify and routably propose work.",
            "Show the future card proposal shape without creating a runtime card.",
            "Show next required user or future-role step.",
            "Preserve all R17-011 non-claims and R13/R14/R15/R16 boundaries."
        )
        constraints = @(
            "local/static preview only",
            "copy/save generated JSON manually until future runtime task",
            "no file writes from browser UI",
            "no external API calls",
            "no Orchestrator runtime invocation",
            "no live board mutation",
            "no runtime card creation",
            "no A2A dispatcher",
            "no adapter runtime"
        )
        explicit_non_goals = @(
            "live Orchestrator runtime",
            "live board mutation",
            "runtime card creation",
            "A2A runtime",
            "Dev/Codex executor adapter",
            "QA/Test Agent adapter",
            "Evidence Auditor API adapter",
            "executable handoffs",
            "executable transitions",
            "external integrations",
            "product runtime",
            "production runtime"
        )
        user_decision_required = $false
        evidence_refs = @(Get-R17OperatorIntakeEvidenceRefs)
        memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        claim_status = Get-R17OperatorIntakeClaimStatus
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function New-R17OrchestratorIntakeProposalObject {
    $seed = New-R17OperatorIntakeSeedPacketObject
    $cardProposal = [ordered]@{
        card_proposal_id = "aioffice-r17-011-card-proposal-v1"
        source_intake_id = $seed.intake_id
        proposed_card_id = "R17-011"
        proposed_task_id = "R17-011"
        title = "Add operator interaction endpoint/surface"
        description = "Non-executable future card proposal for the R17-011 bounded operator interaction/intake surface and deterministic intake compilation layer."
        double_diamond_stage = "discover"
        proposed_lane = "intake"
        proposed_owner_role = "project_manager"
        proposed_next_role = "project_manager"
        acceptance_criteria = @(
            "Governed seed operator intake packet is generated and validated.",
            "Non-executable Orchestrator intake proposal is generated and validated.",
            "Static Kanban MVP exposes a local/static intake preview panel.",
            "No live Orchestrator runtime, board mutation, runtime card creation, A2A runtime, adapters, external APIs, executable handoffs, executable transitions, product runtime, or production runtime is implemented or claimed."
        )
        qa_criteria = @(
            "R17-011 generator, validator, and focused tests pass.",
            "Invalid compact fixtures fail closed for runtime and boundary overclaims.",
            "Static UI files contain no external dependency refs."
        )
        evidence_requirements = @(
            "contracts/intake/r17_operator_intake.contract.json",
            "state/intake/r17_operator_intake_seed_packet.json",
            "state/intake/r17_orchestrator_intake_proposal.json",
            "state/intake/r17_operator_intake_check_report.json",
            "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface/"
        )
        memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
        non_executable_card_proposal = $true
        runtime_card_created = $false
        live_board_mutation_performed = $false
        user_decision_required = $false
        closure_requires_user_approval = $true
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
    }

    return [ordered]@{
        artifact_type = "r17_orchestrator_intake_proposal"
        contract_version = "v1"
        proposal_id = "aioffice-r17-011-orchestrator-intake-proposal-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-011"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = "cdbbdc76ddb16bc1fafcb8acd3add7c2eedda193"
        generated_from_tree = "1545a8d05a7051b7e9c461a10ebb2b7bd7f3f703"
        generated_state_artifact_only = $true
        source_intake_id = $seed.intake_id
        source_intake_ref = "state/intake/r17_operator_intake_seed_packet.json"
        orchestrator_agent_id = "orchestrator"
        classification = [ordered]@{
            classification_id = "aioffice-r17-011-intake-classification-v1"
            source_intake_id = $seed.intake_id
            intent_type = "create_work_card"
            requested_outcome = $seed.requested_outcome
            target_milestone = $seed.target_milestone
            target_branch = $seed.target_branch
            recommended_loop_state = "intake"
            recommended_lane = "intake"
            recommended_owner_role = "project_manager"
            recommended_next_role = "project_manager"
            user_decision_required = $false
            evidence_refs = @(Get-R17OperatorIntakeEvidenceRefs)
            memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
            non_claims = @(Get-R17OperatorIntakeNonClaims)
            rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        }
        recommended_action = "create_governed_card_proposal"
        recommended_loop_state = "intake"
        recommended_card_id = "R17-011"
        recommended_lane = "intake"
        recommended_owner_role = "project_manager"
        recommended_next_role = "project_manager"
        user_decision_required = $false
        closure_requires_user_approval = $true
        non_executable_proposal = $true
        runtime_orchestrator_invoked = $false
        board_mutation_performed = $false
        card_created = $false
        agent_invocation_performed = $false
        a2a_message_sent = $false
        api_call_performed = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
        card_proposal = $cardProposal
        user_decision = [ordered]@{
            user_decision_required = $false
            decision_type = "none_for_seed_demo_generation"
            next_expected_role = "project_manager"
            next_expected_future_task = "R17-012 planned only; do not implement in R17-011"
            copy_save_manual_until_future_runtime = $true
            closure_requires_user_approval = $true
        }
        runtime_boundaries = Get-R17OperatorIntakeRuntimeBoundaries
        evidence_refs = @(Get-R17OperatorIntakeEvidenceRefs)
        memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        claim_status = Get-R17OperatorIntakeClaimStatus
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function New-R17OperatorIntakeCheckReportObject {
    $seed = New-R17OperatorIntakeSeedPacketObject
    $proposal = New-R17OrchestratorIntakeProposalObject

    return [ordered]@{
        artifact_type = "r17_operator_intake_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-011-operator-intake-check-report-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-011"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_contract = "contracts/intake/r17_operator_intake.contract.json"
        generated_state_artifact_only = $true
        checked_artifacts = @(
            "contracts/intake/r17_operator_intake.contract.json",
            "state/intake/r17_operator_intake_seed_packet.json",
            "state/intake/r17_orchestrator_intake_proposal.json",
            "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json",
            "state/agents/r17_orchestrator_identity_authority.json",
            "state/agents/r17_orchestrator_authority_check_report.json",
            "state/orchestration/r17_orchestrator_loop_state_machine.json",
            "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
        )
        checks = [ordered]@{
            operator_intake_packet = [ordered]@{ status = "passed"; intake_id = $seed.intake_id }
            orchestrator_proposal = [ordered]@{ status = "passed"; proposal_id = $proposal.proposal_id }
            memory_refs = [ordered]@{ status = "passed"; exact_refs_only = $true }
            evidence_refs = [ordered]@{ status = "passed"; evidence_refs_present = $true }
            orchestrator_authority_compatibility = [ordered]@{ status = "passed"; compatible = $true; authority_ref = "state/agents/r17_orchestrator_authority_check_report.json" }
            orchestrator_loop_state_machine_compatibility = [ordered]@{ status = "passed"; compatible = $true; recommended_loop_state = $proposal.recommended_loop_state }
            non_executable_proposal = [ordered]@{ status = "passed"; non_executable_proposal = $true }
            runtime_orchestrator_invocation = [ordered]@{ status = "passed"; runtime_orchestrator_invoked = $false }
            board_mutation = [ordered]@{ status = "passed"; board_mutation_performed = $false }
            card_creation_runtime = [ordered]@{ status = "passed"; card_created = $false }
            agent_invocation = [ordered]@{ status = "passed"; agent_invocation_performed = $false }
            a2a_message = [ordered]@{ status = "passed"; a2a_message_sent = $false }
            api_call = [ordered]@{ status = "passed"; api_call_performed = $false }
            dev_qa_audit_outputs = [ordered]@{ status = "passed"; dev_output_claimed = $false; qa_result_claimed = $false; audit_verdict_claimed = $false }
            non_claims = [ordered]@{ status = "passed" }
            rejected_claims = [ordered]@{ status = "passed" }
            r13_r14_r15_r16_boundary_preservation = [ordered]@{ status = "passed" }
            static_ui_external_dependency_refs = [ordered]@{ status = "passed"; http_refs = 0; https_refs = 0; cdn_refs = 0; npm_refs = 0; remote_font_refs = 0 }
        }
        aggregate_verdict = "generated_r17_operator_interaction_surface_candidate"
        seed_intake_id = $seed.intake_id
        proposal_id = $proposal.proposal_id
        recommended_card_id = $proposal.recommended_card_id
        recommended_lane = $proposal.recommended_lane
        recommended_owner_role = $proposal.recommended_owner_role
        recommended_next_role = $proposal.recommended_next_role
        runtime_boundaries = Get-R17OperatorIntakeRuntimeBoundaries
        claim_status = Get-R17OperatorIntakeClaimStatus
        evidence_refs = @(Get-R17OperatorIntakeEvidenceRefs)
        memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function New-R17OperatorIntakeSnapshotObject {
    $seed = New-R17OperatorIntakeSeedPacketObject
    $proposal = New-R17OrchestratorIntakeProposalObject

    return [ordered]@{
        artifact_type = "r17_operator_intake_snapshot"
        contract_version = "v1"
        source_task = "R17-011"
        milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        active_through_task = "R17-011"
        generated_from_head = "cdbbdc76ddb16bc1fafcb8acd3add7c2eedda193"
        generated_from_tree = "1545a8d05a7051b7e9c461a10ebb2b7bd7f3f703"
        ui_boundary_label = "local/static preview only"
        local_open_path = "scripts/operator_wall/r17_kanban_mvp/index.html"
        seed_intake_packet_summary = [ordered]@{
            intake_id = $seed.intake_id
            seed_demo_intake_only = $seed.seed_demo_intake_only
            raw_operator_request = $seed.raw_operator_request
            intent_type = $seed.intent_type
            requested_outcome = $seed.requested_outcome
            target_branch = $seed.target_branch
            user_decision_required = $seed.user_decision_required
            evidence_ref_count = $seed.evidence_refs.Count
            memory_ref_count = $seed.memory_refs.Count
        }
        orchestrator_intake_proposal_summary = [ordered]@{
            proposal_id = $proposal.proposal_id
            source_intake_id = $proposal.source_intake_id
            orchestrator_agent_id = $proposal.orchestrator_agent_id
            recommended_action = $proposal.recommended_action
            recommended_loop_state = $proposal.recommended_loop_state
            recommended_card_id = $proposal.recommended_card_id
            recommended_lane = $proposal.recommended_lane
            recommended_owner_role = $proposal.recommended_owner_role
            recommended_next_role = $proposal.recommended_next_role
            user_decision_required = $proposal.user_decision_required
            closure_requires_user_approval = $proposal.closure_requires_user_approval
            non_executable_proposal = $proposal.non_executable_proposal
        }
        user_decision_state = $proposal.user_decision
        recommended_card_proposal = $proposal.card_proposal
        evidence_refs = @(Get-R17OperatorIntakeEvidenceRefs)
        memory_refs = @(Get-R17OperatorIntakeMemoryRefs)
        runtime_boundary_flags = Get-R17OperatorIntakeRuntimeBoundaries
        proposal_execution_flags = [ordered]@{
            runtime_orchestrator_invoked = $proposal.runtime_orchestrator_invoked
            board_mutation_performed = $proposal.board_mutation_performed
            card_created = $proposal.card_created
            agent_invocation_performed = $proposal.agent_invocation_performed
            a2a_message_sent = $proposal.a2a_message_sent
            api_call_performed = $proposal.api_call_performed
            dev_output_claimed = $proposal.dev_output_claimed
            qa_result_claimed = $proposal.qa_result_claimed
            audit_verdict_claimed = $proposal.audit_verdict_claimed
        }
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        claim_status = Get-R17OperatorIntakeClaimStatus
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function New-R17OperatorIntakeEvidenceIndexObject {
    return [ordered]@{
        artifact_type = "r17_operator_intake_surface_evidence_index"
        contract_version = "v1"
        source_task = "R17-011"
        evidence_package = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_011_operator_interaction_surface/"
        generated_state_artifact_only = $true
        artifacts = @(
            [ordered]@{ path = "contracts/intake/r17_operator_intake.contract.json"; role = "operator intake contract" },
            [ordered]@{ path = "state/intake/r17_operator_intake_seed_packet.json"; role = "generated seed operator intake packet" },
            [ordered]@{ path = "state/intake/r17_orchestrator_intake_proposal.json"; role = "non-executable Orchestrator intake proposal" },
            [ordered]@{ path = "state/intake/r17_operator_intake_check_report.json"; role = "intake check report" },
            [ordered]@{ path = "state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json"; role = "operator intake UI snapshot" },
            [ordered]@{ path = "scripts/operator_wall/r17_kanban_mvp/"; role = "local/static Kanban MVP with intake preview panel" },
            [ordered]@{ path = "tools/R17OperatorIntakeSurface.psm1"; role = "generator and validator module" },
            [ordered]@{ path = "tools/new_r17_operator_intake_surface.ps1"; role = "generator wrapper" },
            [ordered]@{ path = "tools/validate_r17_operator_intake_surface.ps1"; role = "validator wrapper" },
            [ordered]@{ path = "tests/test_r17_operator_intake_surface.ps1"; role = "focused tests" },
            [ordered]@{ path = "tests/fixtures/r17_operator_intake_surface/"; role = "valid and compact invalid fixtures" }
        )
        non_claims = @(Get-R17OperatorIntakeNonClaims)
        rejected_claims = @(Get-R17OperatorIntakeRejectedClaims)
        preserved_boundaries = Get-R17OperatorIntakePreservedBoundaries
    }
}

function Get-R17OperatorIntakeProofReviewText {
    return @"
# R17-011 Operator Interaction Surface Proof Review

Status: generated pending validation

R17-011 implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only.

R17-011 creates generated operator intake seed packet, non-executable Orchestrator intake proposal, check report, and UI snapshot only.

R17-011 updates the local/static Kanban MVP with an intake preview panel only.

## Evidence

- contracts/intake/r17_operator_intake.contract.json
- state/intake/r17_operator_intake_seed_packet.json
- state/intake/r17_orchestrator_intake_proposal.json
- state/intake/r17_operator_intake_check_report.json
- state/ui/r17_kanban_mvp/r17_operator_intake_snapshot.json
- scripts/operator_wall/r17_kanban_mvp/index.html
- scripts/operator_wall/r17_kanban_mvp/styles.css
- scripts/operator_wall/r17_kanban_mvp/kanban.js
- scripts/operator_wall/r17_kanban_mvp/README.md
- tools/R17OperatorIntakeSurface.psm1
- tools/new_r17_operator_intake_surface.ps1
- tools/validate_r17_operator_intake_surface.ps1
- tests/test_r17_operator_intake_surface.ps1
- tests/fixtures/r17_operator_intake_surface/

## Non-Claims

- R17-011 does not implement live Orchestrator runtime.
- R17-011 does not implement live board mutation.
- R17-011 does not create runtime cards.
- R17-011 does not implement A2A runtime.
- R17-011 does not implement Dev/Codex executor adapter.
- R17-011 does not implement QA/Test Agent adapter.
- R17-011 does not implement Evidence Auditor API adapter.
- R17-011 does not call external APIs.
- R17-011 does not call Codex as executor.
- R17-011 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders.
- R17-011 does not claim autonomous agents.
- R17-011 does not claim product runtime.
- R17-011 does not claim production runtime.
- R17-011 does not claim executable handoffs or executable transitions.
- R17-011 does not claim external integrations.
- R17-011 does not claim external audit acceptance.
- R17-011 does not claim main merge.
- R13, R14, R15, and R16 boundaries are preserved.
"@
}

function Get-R17OperatorIntakeValidationManifestText {
    return @"
# R17-011 Operator Interaction Surface Validation Manifest

Status: pending/generated

The validation manifest starts pending/generated. Update this file to passed only after the requested validation commands pass.

## Pending Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_operator_intake_surface.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_operator_intake_surface.ps1
- git diff --check
"@
}

function New-R17OperatorIntakeMutationFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [hashtable]$Set = @{},
        [string[]]$Remove = @(),
        [string]$RemoveArtifact = "",
        [string]$UiFile = "",
        [string]$AppendText = ""
    )

    return [ordered]@{
        fixture_type = "r17_operator_intake_surface_invalid_mutation"
        file_name = $FileName
        target = $Target
        remove_paths = @($Remove)
        set_values = $Set
        remove_artifact = $RemoveArtifact
        ui_file = $UiFile
        append_text = $AppendText
    }
}

function Get-R17OperatorIntakeInvalidFixtures {
    return @(
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_missing_intake_id.json" -Target "operator_intake_packet" -Remove @("intake_id")),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_missing_raw_request.json" -Target "operator_intake_packet" -Remove @("raw_operator_request")),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_invalid_intent_type.json" -Target "operator_intake_packet" -Set @{ intent_type = "unsupported_intent" }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_missing_orchestrator_proposal.json" -Target "artifact_set" -RemoveArtifact "proposal"),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_executable_proposal.json" -Target "orchestrator_intake_proposal" -Set @{ non_executable_proposal = $false }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_runtime_orchestrator_invoked.json" -Target "orchestrator_intake_proposal" -Set @{ runtime_orchestrator_invoked = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_board_mutation_performed.json" -Target "orchestrator_intake_proposal" -Set @{ board_mutation_performed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_card_created_runtime_claim.json" -Target "orchestrator_intake_proposal" -Set @{ card_created = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_agent_invocation_performed.json" -Target "orchestrator_intake_proposal" -Set @{ agent_invocation_performed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_a2a_message_sent.json" -Target "orchestrator_intake_proposal" -Set @{ a2a_message_sent = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_api_call_performed.json" -Target "orchestrator_intake_proposal" -Set @{ api_call_performed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_dev_output_claim.json" -Target "orchestrator_intake_proposal" -Set @{ dev_output_claimed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_qa_result_claim.json" -Target "orchestrator_intake_proposal" -Set @{ qa_result_claimed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_audit_verdict_claim.json" -Target "orchestrator_intake_proposal" -Set @{ audit_verdict_claimed = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_live_board_mutation_claim.json" -Target "contract" -Set @{ "runtime_boundaries.live_board_mutation_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_orchestrator_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.live_orchestrator_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_a2a_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.a2a_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_autonomous_agent_claim.json" -Target "contract" -Set @{ "runtime_boundaries.autonomous_agents_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_dev_codex_adapter_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.dev_codex_adapter_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_qa_adapter_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.qa_test_agent_adapter_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_evidence_auditor_api_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.evidence_auditor_api_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_executable_handoff_claim.json" -Target "contract" -Set @{ "runtime_boundaries.executable_handoffs_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_executable_transition_claim.json" -Target "contract" -Set @{ "runtime_boundaries.executable_transitions_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_product_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.product_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_production_runtime_claim.json" -Target "contract" -Set @{ "runtime_boundaries.production_runtime_implemented" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_external_dependency_ref.json" -Target "ui_external_dependency" -UiFile "index.html" -AppendText "<script src='https://example.invalid/runtime.js'></script>"),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_external_audit_acceptance_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.external_audit_acceptance_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_main_merge_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.main_merge_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_r13_closure_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.r13_closure_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_r14_caveat_removal_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.r14_caveat_removal_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_r15_caveat_removal_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.r15_caveat_removal_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_solved_codex_compaction_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.solved_codex_compaction_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_solved_codex_reliability_claim.json" -Target "operator_intake_check_report" -Set @{ "claim_status.solved_codex_reliability_claimed" = $true }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_broad_repo_scan_memory_ref.json" -Target "operator_intake_packet" -Set @{ memory_refs = @("broad repo scan") }),
        (New-R17OperatorIntakeMutationFixture -FileName "invalid_raw_chat_history_as_canonical.json" -Target "operator_intake_packet" -Set @{ memory_refs = @("raw chat history") })
    )
}

function New-R17OperatorIntakeSurfaceArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17OperatorIntakeRepositoryRoot)
    )

    $paths = Get-R17OperatorIntakePaths -RepositoryRoot $RepositoryRoot
    $contract = New-R17OperatorIntakeContractObject
    $seed = New-R17OperatorIntakeSeedPacketObject
    $proposal = New-R17OrchestratorIntakeProposalObject
    $report = New-R17OperatorIntakeCheckReportObject
    $snapshot = New-R17OperatorIntakeSnapshotObject

    Write-R17Json -Path $paths.Contract -Value $contract
    Write-R17Json -Path $paths.SeedPacket -Value $seed
    Write-R17Json -Path $paths.Proposal -Value $proposal
    Write-R17Json -Path $paths.CheckReport -Value $report
    Write-R17Json -Path $paths.UiSnapshot -Value $snapshot

    if (-not (Test-Path -LiteralPath $paths.FixtureRoot)) {
        New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    }

    Write-R17Json -Path (Join-Path $paths.FixtureRoot "valid_operator_intake_seed_packet.json") -Value $seed
    Write-R17Json -Path (Join-Path $paths.FixtureRoot "valid_orchestrator_intake_proposal.json") -Value $proposal
    Write-R17Json -Path (Join-Path $paths.FixtureRoot "valid_operator_intake_check_report.json") -Value $report
    Write-R17Json -Path (Join-Path $paths.FixtureRoot "valid_operator_intake_snapshot.json") -Value $snapshot

    foreach ($fixture in Get-R17OperatorIntakeInvalidFixtures) {
        Write-R17Json -Path (Join-Path $paths.FixtureRoot $fixture.file_name) -Value $fixture
    }

    Write-R17Text -Path $paths.ProofReview -Value (Get-R17OperatorIntakeProofReviewText)
    Write-R17Json -Path $paths.EvidenceIndex -Value (New-R17OperatorIntakeEvidenceIndexObject)
    Write-R17Text -Path $paths.ValidationManifest -Value (Get-R17OperatorIntakeValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        SeedPacket = $paths.SeedPacket
        Proposal = $paths.Proposal
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $report.aggregate_verdict
    }
}

function Assert-R17RequiredProperties {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string[]]$Properties,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($null -eq $Object) {
        throw "$Label is missing."
    }

    foreach ($property in $Properties) {
        if ($null -eq $Object.PSObject.Properties[$property]) {
            throw "$Label is missing required field '$property'."
        }
    }
}

function Assert-R17ArrayNotEmpty {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($null -eq $Value -or @($Value).Count -eq 0) {
        throw "$Label must be present and non-empty."
    }
}

function Get-R17MemoryRefText {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    if ($Value -is [string]) {
        return $Value
    }

    if ($null -ne $Value.PSObject.Properties["ref"]) {
        return [string]$Value.ref
    }

    throw "Memory ref must be a string or an object with a ref field."
}

function Assert-R17MemoryRefsExact {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Refs,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Assert-R17ArrayNotEmpty -Value $Refs -Label $Label

    foreach ($item in @($Refs)) {
        $ref = (Get-R17MemoryRefText -Value $item).Trim()
        if ([string]::IsNullOrWhiteSpace($ref)) {
            throw "$Label contains an empty memory ref."
        }

        if ($ref -match '[\*\?]' -or $ref -eq "." -or $ref -eq "./" -or $ref -eq ".\" -or $ref.EndsWith("/") -or $ref.EndsWith("\")) {
            throw "$Label contains non-exact memory ref '$ref'."
        }

        if ($ref -match '(?i)broad repo scan|full repo scan|repo root|raw chat|chat history|hidden chat') {
            throw "$Label contains forbidden non-canonical memory ref '$ref'."
        }
    }
}

function Get-R17FalseFlagNames {
    return @(
        "operator_intake_runtime_server_implemented",
        "live_orchestrator_runtime_implemented",
        "orchestrator_runtime_implemented",
        "live_board_mutation_implemented",
        "card_creation_runtime_implemented",
        "a2a_runtime_implemented",
        "dev_codex_adapter_runtime_implemented",
        "qa_test_agent_adapter_runtime_implemented",
        "evidence_auditor_api_runtime_implemented",
        "external_api_calls_implemented",
        "executable_handoffs_implemented",
        "executable_transitions_implemented",
        "autonomous_agents_implemented",
        "external_integrations_implemented",
        "product_runtime_implemented",
        "production_runtime_implemented",
        "runtime_orchestrator_invoked",
        "board_mutation_performed",
        "card_created",
        "runtime_card_created",
        "live_board_mutation_performed",
        "agent_invocation_performed",
        "a2a_message_sent",
        "api_call_performed",
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
}

function Assert-R17FalseFlags {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $falseFlags = @(Get-R17FalseFlagNames)

    function Visit-Node {
        param(
            [object]$Node,
            [string]$Path
        )

        if ($null -eq $Node) {
            return
        }

        if ($Node -is [string] -or $Node -is [ValueType]) {
            return
        }

        foreach ($property in @($Node.PSObject.Properties)) {
            $name = $property.Name
            $value = $property.Value
            $propertyPath = if ($Path) { "$Path.$name" } else { $name }

            if ($falseFlags -contains $name -and $value -eq $true) {
                throw "$Label contains forbidden true runtime/claim flag '$propertyPath'."
            }

            if ($value -is [System.Array]) {
                $index = 0
                foreach ($item in $value) {
                    Visit-Node -Node $item -Path ("$propertyPath[$index]")
                    $index++
                }
            }
            elseif ($null -ne $value -and -not ($value -is [string]) -and -not ($value -is [ValueType])) {
                Visit-Node -Node $value -Path $propertyPath
            }
        }
    }

    Visit-Node -Node $Object -Path ""
}

function Assert-R17NonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Assert-R17ArrayNotEmpty -Value $Object.non_claims -Label "$Label non_claims"

    foreach ($required in @(
            "R17-011 implements a bounded operator interaction/intake surface and deterministic intake packet/proposal generation only",
            "R17-011 does not implement live Orchestrator runtime",
            "R17-011 does not implement live board mutation",
            "R17-011 does not implement A2A runtime",
            "R17-012 through R17-028 remain planned only",
            "R13 boundary preserved",
            "R14 caveats preserved",
            "R15 caveats preserved",
            "R16 boundary preserved"
        )) {
        if (@($Object.non_claims) -notcontains $required) {
            throw "$Label non_claims must include '$required'."
        }
    }
}

function Assert-R17RejectedClaims {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Assert-R17ArrayNotEmpty -Value $Object.rejected_claims -Label "$Label rejected_claims"
    foreach ($required in @(
            "live_board_mutation",
            "Orchestrator_runtime",
            "A2A_runtime",
            "external_audit_acceptance",
            "main_merge",
            "product_runtime",
            "production_runtime",
            "R13_closure",
            "R14_caveat_removal",
            "R15_caveat_removal",
            "solved_Codex_compaction",
            "solved_Codex_reliability"
        )) {
        if (@($Object.rejected_claims) -notcontains $required) {
            throw "$Label rejected_claims must include '$required'."
        }
    }
}

function Assert-R17PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($null -eq $Object.preserved_boundaries) {
        throw "$Label must include preserved_boundaries."
    }

    if ($Object.preserved_boundaries.r13.closed -ne $false) {
        throw "$Label must preserve R13 as not closed."
    }

    if ($Object.preserved_boundaries.r14.caveats_removed -ne $false) {
        throw "$Label must preserve R14 caveats."
    }

    if ($Object.preserved_boundaries.r15.caveats_removed -ne $false) {
        throw "$Label must preserve R15 caveats."
    }

    if ($Object.preserved_boundaries.r16.product_runtime_implemented -ne $false -or $Object.preserved_boundaries.r16.a2a_runtime_implemented -ne $false -or $Object.preserved_boundaries.r16.autonomous_agents_implemented -ne $false) {
        throw "$Label must preserve R16 runtime non-claims."
    }
}

function Assert-R17Contract {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract
    )

    Assert-R17RequiredProperties -Object $Contract -Properties @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_milestone",
        "source_task",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_intake_fields",
        "allowed_intent_types",
        "required_classification_fields",
        "required_orchestrator_proposal_fields",
        "required_card_proposal_fields",
        "required_user_decision_fields",
        "evidence_requirements",
        "memory_scope_rules",
        "non_claims",
        "rejected_claims",
        "runtime_boundaries",
        "preserved_boundaries"
    ) -Label "contract"

    if ($Contract.artifact_type -ne "r17_operator_intake_contract") {
        throw "Contract artifact_type is invalid."
    }

    if ($Contract.source_task -ne "R17-011") {
        throw "Contract source_task must be R17-011."
    }

    foreach ($intent in @("create_work_card", "request_status", "request_user_decision", "request_release_step", "request_audit", "request_qa", "request_research", "request_clarification")) {
        if (@($Contract.allowed_intent_types) -notcontains $intent) {
            throw "Contract allowed_intent_types must include '$intent'."
        }
    }

    foreach ($property in (Get-R17OperatorIntakeRuntimeBoundaries).Keys) {
        if ($null -eq $Contract.runtime_boundaries.PSObject.Properties[$property]) {
            throw "Contract runtime_boundaries is missing '$property'."
        }

        if ($Contract.runtime_boundaries.$property -ne $false) {
            throw "Contract runtime boundary '$property' must be false."
        }
    }

    Assert-R17MemoryRefsExact -Refs $Contract.memory_scope_rules.allowed_exact_refs -Label "contract memory_scope_rules.allowed_exact_refs"
    Assert-R17NonClaims -Object $Contract -Label "contract"
    Assert-R17RejectedClaims -Object $Contract -Label "contract"
    Assert-R17PreservedBoundaries -Object $Contract -Label "contract"
    Assert-R17FalseFlags -Object $Contract -Label "contract"
}

function Assert-R17SeedPacket {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$Packet
    )

    Assert-R17RequiredProperties -Object $Packet -Properties @($Contract.required_intake_fields) -Label "operator intake packet"

    if ($Packet.artifact_type -ne "r17_operator_intake_packet") {
        throw "Operator intake packet artifact_type is invalid."
    }

    if ($Packet.source_task -ne "R17-011") {
        throw "Operator intake packet source_task must be R17-011."
    }

    if ($Packet.raw_operator_request -ne "Create a governed R17 work card to continue from the current read-only Kanban and Orchestrator state-machine foundation into an operator interaction surface.") {
        throw "Operator intake packet raw_operator_request does not match the required seed request."
    }

    if ($Packet.intent_type -ne "create_work_card") {
        throw "Operator intake packet intent_type must be create_work_card."
    }

    if (@($Contract.allowed_intent_types) -notcontains $Packet.intent_type) {
        throw "Operator intake packet intent_type is not allowed by contract."
    }

    if ($Packet.seed_demo_intake_not_runtime_user_intake -ne $true) {
        throw "Operator intake packet must mark seed as demo/test intake only."
    }

    Assert-R17ArrayNotEmpty -Value $Packet.evidence_refs -Label "operator intake packet evidence_refs"
    Assert-R17MemoryRefsExact -Refs $Packet.memory_refs -Label "operator intake packet memory_refs"
    Assert-R17NonClaims -Object $Packet -Label "operator intake packet"
    Assert-R17RejectedClaims -Object $Packet -Label "operator intake packet"
    Assert-R17PreservedBoundaries -Object $Packet -Label "operator intake packet"
    Assert-R17FalseFlags -Object $Packet -Label "operator intake packet"
}

function Assert-R17Proposal {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$Packet,
        [Parameter(Mandatory = $true)]
        [object]$Proposal,
        [object]$AuthorityState = $null,
        [object]$LoopStateMachine = $null
    )

    Assert-R17RequiredProperties -Object $Proposal -Properties @($Contract.required_orchestrator_proposal_fields) -Label "Orchestrator proposal"

    if ($Proposal.artifact_type -ne "r17_orchestrator_intake_proposal") {
        throw "Orchestrator proposal artifact_type is invalid."
    }

    if ($Proposal.source_intake_id -ne $Packet.intake_id) {
        throw "Orchestrator proposal source_intake_id must match seed intake packet."
    }

    if ($Proposal.orchestrator_agent_id -ne "orchestrator") {
        throw "Orchestrator proposal orchestrator_agent_id must be orchestrator."
    }

    if ($null -ne $AuthorityState -and $AuthorityState.orchestrator_identity.agent_id -ne $Proposal.orchestrator_agent_id) {
        throw "Orchestrator proposal is incompatible with Orchestrator identity state."
    }

    if ($Proposal.recommended_action -ne "create_governed_card_proposal") {
        throw "Orchestrator proposal recommended_action must be create_governed_card_proposal."
    }

    if (@("intake", "define") -notcontains $Proposal.recommended_loop_state) {
        throw "Orchestrator proposal recommended_loop_state must be intake or define for R17-011."
    }

    if ($null -ne $LoopStateMachine) {
        $states = @($LoopStateMachine.orchestrator_loop_states | ForEach-Object { $_.state_id })
        if ($states -notcontains $Proposal.recommended_loop_state) {
            throw "Orchestrator proposal recommended_loop_state is not present in the loop state machine."
        }
    }

    if ($Proposal.recommended_card_id -ne "R17-011") {
        throw "Orchestrator proposal recommended_card_id must be R17-011."
    }

    if (@("intake", "define") -notcontains $Proposal.recommended_lane) {
        throw "Orchestrator proposal recommended_lane must be intake or define for R17-011."
    }

    if (@("orchestrator", "project_manager") -notcontains $Proposal.recommended_owner_role) {
        throw "Orchestrator proposal recommended_owner_role must be orchestrator or project_manager."
    }

    if ($Proposal.recommended_next_role -ne "project_manager") {
        throw "Orchestrator proposal recommended_next_role must be project_manager."
    }

    if ($Proposal.closure_requires_user_approval -ne $true) {
        throw "Orchestrator proposal must require user approval for closure."
    }

    if ($Proposal.non_executable_proposal -ne $true) {
        throw "Orchestrator proposal must be non-executable."
    }

    Assert-R17RequiredProperties -Object $Proposal.card_proposal -Properties @($Contract.required_card_proposal_fields) -Label "card proposal"
    if ($Proposal.card_proposal.proposed_card_id -ne "R17-011") {
        throw "Card proposal proposed_card_id must be R17-011."
    }

    if ($Proposal.card_proposal.non_executable_card_proposal -ne $true) {
        throw "Card proposal must be non-executable."
    }

    Assert-R17ArrayNotEmpty -Value $Proposal.evidence_refs -Label "Orchestrator proposal evidence_refs"
    Assert-R17MemoryRefsExact -Refs $Proposal.memory_refs -Label "Orchestrator proposal memory_refs"
    Assert-R17MemoryRefsExact -Refs $Proposal.classification.memory_refs -Label "Orchestrator classification memory_refs"
    Assert-R17MemoryRefsExact -Refs $Proposal.card_proposal.memory_refs -Label "card proposal memory_refs"
    Assert-R17NonClaims -Object $Proposal -Label "Orchestrator proposal"
    Assert-R17RejectedClaims -Object $Proposal -Label "Orchestrator proposal"
    Assert-R17PreservedBoundaries -Object $Proposal -Label "Orchestrator proposal"
    Assert-R17FalseFlags -Object $Proposal -Label "Orchestrator proposal"
}

function Assert-R17CheckReport {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Report
    )

    Assert-R17RequiredProperties -Object $Report -Properties @(
        "artifact_type",
        "contract_version",
        "report_id",
        "source_task",
        "checked_artifacts",
        "checks",
        "aggregate_verdict",
        "evidence_refs",
        "memory_refs",
        "non_claims",
        "rejected_claims",
        "preserved_boundaries"
    ) -Label "check report"

    if ($Report.artifact_type -ne "r17_operator_intake_check_report") {
        throw "Check report artifact_type is invalid."
    }

    if ($Report.aggregate_verdict -ne "generated_r17_operator_interaction_surface_candidate") {
        throw "Check report aggregate verdict is invalid."
    }

    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and $check.Value.status -ne "passed") {
            throw "Check report check '$($check.Name)' must be passed."
        }
    }

    Assert-R17ArrayNotEmpty -Value $Report.checked_artifacts -Label "check report checked_artifacts"
    Assert-R17ArrayNotEmpty -Value $Report.evidence_refs -Label "check report evidence_refs"
    Assert-R17MemoryRefsExact -Refs $Report.memory_refs -Label "check report memory_refs"
    Assert-R17NonClaims -Object $Report -Label "check report"
    Assert-R17RejectedClaims -Object $Report -Label "check report"
    Assert-R17PreservedBoundaries -Object $Report -Label "check report"
    Assert-R17FalseFlags -Object $Report -Label "check report"
}

function Assert-R17Snapshot {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Snapshot
    )

    Assert-R17RequiredProperties -Object $Snapshot -Properties @(
        "artifact_type",
        "contract_version",
        "source_task",
        "seed_intake_packet_summary",
        "orchestrator_intake_proposal_summary",
        "user_decision_state",
        "recommended_card_proposal",
        "evidence_refs",
        "memory_refs",
        "runtime_boundary_flags",
        "non_claims",
        "rejected_claims"
    ) -Label "UI snapshot"

    if ($Snapshot.artifact_type -ne "r17_operator_intake_snapshot") {
        throw "UI snapshot artifact_type is invalid."
    }

    if ($Snapshot.source_task -ne "R17-011") {
        throw "UI snapshot source_task must be R17-011."
    }

    if ($Snapshot.seed_intake_packet_summary.intent_type -ne "create_work_card") {
        throw "UI snapshot seed intent type must be create_work_card."
    }

    if ($Snapshot.orchestrator_intake_proposal_summary.recommended_card_id -ne "R17-011") {
        throw "UI snapshot proposal summary must recommend R17-011."
    }

    if ($Snapshot.user_decision_state.copy_save_manual_until_future_runtime -ne $true) {
        throw "UI snapshot must expose manual copy/save state until future runtime task."
    }

    Assert-R17ArrayNotEmpty -Value $Snapshot.evidence_refs -Label "UI snapshot evidence_refs"
    Assert-R17MemoryRefsExact -Refs $Snapshot.memory_refs -Label "UI snapshot memory_refs"
    Assert-R17NonClaims -Object $Snapshot -Label "UI snapshot"
    Assert-R17RejectedClaims -Object $Snapshot -Label "UI snapshot"
    Assert-R17PreservedBoundaries -Object $Snapshot -Label "UI snapshot"
    Assert-R17FalseFlags -Object $Snapshot -Label "UI snapshot"
}

function Assert-R17UiFilesHaveNoExternalDependencyRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$UiFilePaths
    )

    foreach ($path in $UiFilePaths) {
        if (-not (Test-Path -LiteralPath $path)) {
            throw "UI file '$path' does not exist."
        }

        $text = Get-Content -LiteralPath $path -Raw
        foreach ($pattern in @(
                "http://",
                "https://",
                "(?i)\bcdn\b",
                "(?i)\bnpm\b",
                "(?i)fonts\.googleapis",
                "(?i)fonts\.gstatic",
                "(?i)unpkg",
                "(?i)jsdelivr",
                "(?i)@import\s+url"
            )) {
            if ($text -match $pattern) {
                throw "UI file '$path' contains forbidden external dependency reference matching '$pattern'."
            }
        }
    }
}

function Test-R17OperatorIntakeSurfaceSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$Packet,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Proposal,
        [Parameter(Mandatory = $true)]
        [object]$Report,
        [Parameter(Mandatory = $true)]
        [object]$Snapshot,
        [object]$AuthorityState = $null,
        [object]$LoopStateMachine = $null,
        [string[]]$UiFilePaths = @()
    )

    Assert-R17Contract -Contract $Contract
    Assert-R17SeedPacket -Contract $Contract -Packet $Packet
    Assert-R17Proposal -Contract $Contract -Packet $Packet -Proposal $Proposal -AuthorityState $AuthorityState -LoopStateMachine $LoopStateMachine
    Assert-R17CheckReport -Report $Report
    Assert-R17Snapshot -Snapshot $Snapshot
    if ($UiFilePaths.Count -gt 0) {
        Assert-R17UiFilesHaveNoExternalDependencyRefs -UiFilePaths $UiFilePaths
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        IntakeId = $Packet.intake_id
        ProposalId = $Proposal.proposal_id
        RecommendedCardId = $Proposal.recommended_card_id
        RecommendedLane = $Proposal.recommended_lane
        RuntimeOrchestratorInvoked = $Proposal.runtime_orchestrator_invoked
        BoardMutationPerformed = $Proposal.board_mutation_performed
        CardCreated = $Proposal.card_created
        AgentInvocationPerformed = $Proposal.agent_invocation_performed
        A2aMessageSent = $Proposal.a2a_message_sent
        ApiCallPerformed = $Proposal.api_call_performed
        DevOutputClaimed = $Proposal.dev_output_claimed
        QaResultClaimed = $Proposal.qa_result_claimed
        AuditVerdictClaimed = $Proposal.audit_verdict_claimed
    }
}

function Test-R17OperatorIntakeSurface {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17OperatorIntakeRepositoryRoot)
    )

    $paths = Get-R17OperatorIntakePaths -RepositoryRoot $RepositoryRoot
    $authorityStatePath = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_orchestrator_identity_authority.json"
    $loopStateMachinePath = Resolve-R17OperatorIntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/orchestration/r17_orchestrator_loop_state_machine.json"

    return Test-R17OperatorIntakeSurfaceSet `
        -Contract (Read-R17Json -Path $paths.Contract) `
        -Packet (Read-R17Json -Path $paths.SeedPacket) `
        -Proposal (Read-R17Json -Path $paths.Proposal) `
        -Report (Read-R17Json -Path $paths.CheckReport) `
        -Snapshot (Read-R17Json -Path $paths.UiSnapshot) `
        -AuthorityState (Read-R17Json -Path $authorityStatePath) `
        -LoopStateMachine (Read-R17Json -Path $loopStateMachinePath) `
        -UiFilePaths $paths.UiFiles
}

function Set-R17ObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Value
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

function Remove-R17ObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
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

function Invoke-R17OperatorIntakeMutation {
    param(
        [Parameter(Mandatory = $true)]
        [object]$TargetObject,
        [Parameter(Mandatory = $true)]
        [object]$Mutation
    )

    foreach ($removePath in @($Mutation.remove_paths)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
            Remove-R17ObjectPathValue -Object $TargetObject -Path $removePath
        }
    }

    if ($null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17ObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17OperatorIntakePaths, `
    New-R17OperatorIntakeSurfaceArtifacts, `
    Test-R17OperatorIntakeSurface, `
    Test-R17OperatorIntakeSurfaceSet, `
    Invoke-R17OperatorIntakeMutation, `
    Copy-R17Object
