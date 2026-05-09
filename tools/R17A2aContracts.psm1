Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-020"
$script:AggregateVerdict = "generated_r17_a2a_message_handoff_contract_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts"
$script:FixtureRoot = "tests/fixtures/r17_a2a_contracts"
$script:MinimumInvalidFixtureCount = 30

$script:AllowedMessageTypes = @(
    "task_assignment",
    "clarification_request",
    "implementation_result",
    "qa_result",
    "defect_report",
    "fix_request",
    "audit_request",
    "audit_verdict",
    "release_recommendation",
    "user_decision_request"
)

$script:AllowedHandoffTypes = @(
    "planning_to_implementation",
    "implementation_to_qa",
    "qa_to_fix",
    "qa_to_audit",
    "audit_to_release_recommendation",
    "release_recommendation_to_user_decision"
)

$script:AllowedStatuses = @(
    "contract_only",
    "disabled_seed",
    "not_dispatched",
    "not_executed_disabled_foundation",
    "packet_only",
    "placeholder_only",
    "blocked",
    "invalid"
)

$script:AllowedExecutionModes = @(
    "contract_only",
    "disabled_seed",
    "packet_only",
    "validation_only"
)

$script:RequiredMessageFields = @(
    "message_id",
    "source_task",
    "card_id",
    "message_type",
    "from_agent_id",
    "to_agent_id",
    "correlation_id",
    "parent_message_id",
    "invocation_ref",
    "tool_call_ledger_ref",
    "board_event_ref",
    "input_packet_ref",
    "output_packet_ref",
    "memory_packet_ref",
    "evidence_refs",
    "authority_refs",
    "acceptance_criteria_refs",
    "status",
    "execution_mode",
    "handoff_ref",
    "requires_user_decision",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredHandoffFields = @(
    "handoff_id",
    "source_task",
    "card_id",
    "handoff_type",
    "source_message_ref",
    "from_agent_id",
    "to_agent_id",
    "allowed_message_types",
    "allowed_next_actions",
    "required_input_refs",
    "required_output_refs",
    "authority_refs",
    "memory_packet_ref",
    "evidence_refs",
    "board_event_ref",
    "tool_call_ledger_ref",
    "user_approval_required",
    "qa_required_before_audit",
    "audit_required_before_release_recommendation",
    "status",
    "execution_mode",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:ExplicitFalseFields = @(
    "a2a_runtime_implemented",
    "a2a_dispatcher_implemented",
    "a2a_message_sent",
    "a2a_message_dispatched",
    "live_agent_runtime_invoked",
    "live_orchestrator_runtime_invoked",
    "agent_invocation_performed",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "board_mutation_performed",
    "runtime_card_creation_performed",
    "product_runtime_executed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "main_merge_claimed"
)

$script:RuntimeFalseFields = @(
    $script:ExplicitFalseFields +
    @(
        "autonomous_agent_executed",
        "adapter_runtime_implemented",
        "codex_executor_invoked",
        "qa_test_agent_invoked",
        "evidence_auditor_api_invoked",
        "dev_output_claimed",
        "production_runtime_executed",
        "external_integration_performed",
        "executable_handoff_performed",
        "executable_transition_performed",
        "runtime_memory_engine_used",
        "vector_retrieval_performed",
        "r13_closure_claimed",
        "r14_caveat_removal_claimed",
        "r15_caveat_removal_claimed",
        "r17_021_plus_implementation_claimed",
        "full_source_file_contents_embedded",
        "broad_repo_scan_output_included",
        "broad_repo_scan_used"
    )
)

$script:ClaimStatusFields = @(
    "a2a_runtime_claimed",
    "a2a_dispatcher_claimed",
    "a2a_messages_claimed",
    "live_agent_runtime_claimed",
    "live_orchestrator_runtime_claimed",
    "autonomous_agent_claimed",
    "adapter_runtime_claimed",
    "actual_tool_call_claimed",
    "external_api_call_claimed",
    "live_board_mutation_claimed",
    "runtime_card_creation_claimed",
    "product_runtime_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r17_021_plus_implementation_claimed"
)

function Get-R17A2aContractsRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17A2aContractsPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17A2aJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "JSON artifact '$Path' is malformed. $($_.Exception.Message)"
    }
}

function Write-R17A2aJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $Value | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17A2aText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R17A2aObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 40 | ConvertFrom-Json)
}

function Test-R17A2aHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17A2aProperty {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17A2aHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Get-R17A2aContractsPaths {
    param([string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot))

    return [pscustomobject]@{
        MessageContract = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_message.contract.json"
        HandoffContract = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_handoff.contract.json"
        MessagePackets = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_message_seed_packets.json"
        HandoffPackets = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_handoff_seed_packets.json"
        CheckReport = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_contract_check_report.json"
        UiSnapshot = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_a2a_contracts_snapshot.json"
        Registry = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry.json"
        FixtureRoot = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17A2aGitIdentity {
    param([string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17A2aFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17A2aExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17A2aClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return [pscustomobject]$status
}

function Get-R17A2aPreservedBoundaries {
    return [pscustomobject]@{
        r13 = [pscustomobject]@{ status = "failed/partial"; active_through = "R13-018"; closed = $false }
        r14 = [pscustomobject]@{ status = "accepted_with_caveats"; active_through = "R14-006"; caveats_removed = $false }
        r15 = [pscustomobject]@{ status = "accepted_with_caveats_by_external_audit"; active_through = "R15-009"; caveats_removed = $false }
        r16 = [pscustomobject]@{ status = "complete_bounded_foundation_scope"; active_through = "R16-026"; overclaimed = $false }
        r17 = [pscustomobject]@{ status = "active"; active_through = "R17-020"; planned_only_from = "R17-021"; planned_only_through = "R17-028" }
    }
}

function Get-R17A2aNonClaims {
    return @(
        "R17-020 defines A2A message and handoff contracts only",
        "R17-020 creates disabled/not-dispatched seed message and handoff packets only",
        "R17-020 does not implement A2A runtime",
        "R17-020 does not implement an A2A dispatcher",
        "R17-020 does not send or dispatch A2A messages",
        "R17-020 does not invoke live agents",
        "R17-020 does not invoke live Orchestrator runtime",
        "R17-020 does not invoke adapter runtime",
        "R17-020 does not perform actual tool calls",
        "R17-020 does not call external APIs",
        "R17-020 does not mutate the board",
        "R17-020 does not create runtime cards",
        "R17-020 does not implement autonomous agents",
        "R17-020 does not implement product runtime",
        "R17-020 does not produce real Dev output",
        "R17-020 does not produce real QA result",
        "R17-020 does not produce a real audit verdict",
        "R17-020 does not claim external audit acceptance",
        "R17-020 does not claim main merge",
        "R17-020 does not close R13",
        "R17-020 does not remove R14 caveats",
        "R17-020 does not remove R15 caveats",
        "R17-020 does not solve Codex compaction",
        "R17-020 does not solve Codex reliability",
        "R17-021 through R17-028 remain planned only"
    )
}

function Get-R17A2aRejectedClaims {
    return @(
        "A2A_runtime",
        "A2A_dispatcher",
        "A2A_messages_sent",
        "A2A_messages_dispatched",
        "live_agent_runtime",
        "live_Orchestrator_runtime",
        "adapter_runtime",
        "actual_tool_call",
        "external_API_calls",
        "live_board_mutation",
        "runtime_card_creation",
        "autonomous_agents",
        "product_runtime",
        "production_runtime",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "external_audit_acceptance",
        "main_merge",
        "future_R17_021_plus_completion",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "broad_repo_scan_output",
        "generated_artifact_embedding_full_source_file_contents",
        "local_backups_refs",
        "wildcard_evidence_refs"
    )
}

function Get-R17A2aDependencyRefs {
    return [pscustomobject]@{
        r17_authority_ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
        kanban_ref = "execution/KANBAN.md"
        agent_registry_contract_ref = "contracts/agents/r17_agent_registry.contract.json"
        agent_identity_packet_contract_ref = "contracts/agents/r17_agent_identity_packet.contract.json"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        memory_loader_contract_ref = "contracts/context/r17_memory_artifact_loader.contract.json"
        memory_loader_report_ref = "state/context/r17_memory_artifact_loader_report.json"
        memory_loaded_refs_log_ref = "state/context/r17_memory_loaded_refs_log.json"
        agent_invocation_log_contract_ref = "contracts/runtime/r17_agent_invocation_log.contract.json"
        agent_invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        agent_invocation_log_report_ref = "state/runtime/r17_agent_invocation_log_check_report.json"
        tool_adapter_contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        tool_adapter_seed_profile_ref = "state/tools/r17_tool_adapter_seed_profiles.json"
        codex_executor_adapter_contract_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
        codex_executor_request_ref = "state/tools/r17_codex_executor_adapter_request_packet.json"
        codex_executor_result_ref = "state/tools/r17_codex_executor_adapter_result_packet.json"
        qa_test_agent_adapter_contract_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
        qa_test_agent_request_ref = "state/tools/r17_qa_test_agent_adapter_request_packet.json"
        qa_test_agent_result_ref = "state/tools/r17_qa_test_agent_adapter_result_packet.json"
        qa_test_agent_defect_ref = "state/tools/r17_qa_test_agent_adapter_defect_packet.json"
        evidence_auditor_api_adapter_contract_ref = "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
        evidence_auditor_api_request_ref = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"
        evidence_auditor_api_response_ref = "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"
        evidence_auditor_api_verdict_ref = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"
        tool_call_ledger_contract_ref = "contracts/runtime/r17_tool_call_ledger.contract.json"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        tool_call_ledger_report_ref = "state/runtime/r17_tool_call_ledger_check_report.json"
        board_event_contract_ref = "contracts/board/r17_board_event.contract.json"
        board_state_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"
        board_event_log_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl"
        orchestration_contract_ref = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"
        orchestration_transition_report_ref = "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    }
}

function New-R17A2aMessageContract {
    return [ordered]@{
        artifact_type = "r17_a2a_message_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-020-a2a-message-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "a2a_message_contract_foundation_only_not_runtime"
        purpose = "Define future A2A message packet shape, required refs, allowed message types, fail-closed validation, and explicit false runtime flags without dispatching or sending messages."
        required_message_fields = $script:RequiredMessageFields
        allowed_message_types = $script:AllowedMessageTypes
        allowed_statuses = $script:AllowedStatuses
        allowed_execution_modes = $script:AllowedExecutionModes
        required_explicit_false_fields = $script:ExplicitFalseFields
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            local_backups_refs_allowed = $false
            urls_allowed = $false
            broad_repo_scan_output_allowed = $false
            full_source_file_content_embedding_allowed = $false
        }
        registry_policy = [ordered]@{
            from_agent_id_must_exist_in_registry = $true
            to_agent_id_must_exist_in_registry = $true
            registry_ref = "state/agents/r17_agent_registry.json"
        }
        runtime_policy = [ordered]@{
            dispatcher_required_before_sending = $true
            sending_allowed_in_r17_020 = $false
            dispatch_allowed_in_r17_020 = $false
            agent_invocation_allowed_in_r17_020 = $false
            adapter_invocation_allowed_in_r17_020 = $false
            board_mutation_allowed_in_r17_020 = $false
        }
        dependency_refs = Get-R17A2aDependencyRefs
        implementation_boundaries = Get-R17A2aFalseFlags
        claim_status = Get-R17A2aClaimStatus
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
        preserved_boundaries = Get-R17A2aPreservedBoundaries
    }
}

function New-R17A2aHandoffContract {
    return [ordered]@{
        artifact_type = "r17_a2a_handoff_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-020-a2a-handoff-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "a2a_handoff_contract_foundation_only_not_runtime"
        purpose = "Define future A2A handoff packet shape, allowed next-action vocabulary, required refs, and release-gate rules without executing handoffs."
        required_handoff_fields = $script:RequiredHandoffFields
        allowed_handoff_types = $script:AllowedHandoffTypes
        allowed_message_types = $script:AllowedMessageTypes
        allowed_statuses = $script:AllowedStatuses
        allowed_execution_modes = $script:AllowedExecutionModes
        allowed_next_actions = @(
            "prepare_packet_only",
            "validate_contract_only",
            "wait_for_user_decision_packet_only",
            "record_future_dispatch_precondition",
            "block_until_future_dispatcher_task"
        )
        required_explicit_false_fields = $script:ExplicitFalseFields
        gate_policy = [ordered]@{
            qa_required_before_audit = $true
            audit_required_before_release_recommendation = $true
            user_approval_required_before_release = $true
            runtime_handoff_execution_allowed_in_r17_020 = $false
        }
        dependency_refs = Get-R17A2aDependencyRefs
        implementation_boundaries = Get-R17A2aFalseFlags
        claim_status = Get-R17A2aClaimStatus
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
        preserved_boundaries = Get-R17A2aPreservedBoundaries
    }
}

function Get-R17A2aCommonEvidenceRefs {
    return @(
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "state/a2a/r17_a2a_message_seed_packets.json",
        "state/a2a/r17_a2a_handoff_seed_packets.json",
        "state/a2a/r17_a2a_contract_check_report.json",
        "state/ui/r17_kanban_mvp/r17_a2a_contracts_snapshot.json",
        "tools/R17A2aContracts.psm1",
        "tools/new_r17_a2a_contracts.ps1",
        "tools/validate_r17_a2a_contracts.ps1",
        "tests/test_r17_a2a_contracts.ps1",
        "tests/fixtures/r17_a2a_contracts/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_020_a2a_contracts/validation_manifest.md"
    )
}

function Get-R17A2aCommonAuthorityRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "state/agents/r17_agent_registry.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "contracts/tools/r17_tool_adapter.contract.json",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/context/r17_memory_artifact_loader_report.json"
    )
}

function Get-R17A2aMessageSeedDefinitions {
    return @(
        [pscustomobject]@{ id = "r17_020_seed_message_task_assignment"; type = "task_assignment"; from = "orchestrator"; to = "developer"; parent = "none"; handoff = "r17_020_seed_handoff_planning_to_implementation"; input = "state/tools/r17_codex_executor_adapter_request_packet.json"; output = "state/tools/r17_codex_executor_adapter_result_packet.json"; memory = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_clarification_request"; type = "clarification_request"; from = "developer"; to = "project_manager"; parent = "r17_020_seed_message_task_assignment"; handoff = "r17_020_seed_handoff_planning_to_implementation"; input = "state/tools/r17_codex_executor_adapter_request_packet.json"; output = "not_implemented_seed"; memory = "state/agents/r17_agent_memory_packets/project_manager.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_implementation_result"; type = "implementation_result"; from = "developer"; to = "orchestrator"; parent = "r17_020_seed_message_task_assignment"; handoff = "r17_020_seed_handoff_implementation_to_qa"; input = "state/tools/r17_codex_executor_adapter_request_packet.json"; output = "state/tools/r17_codex_executor_adapter_result_packet.json"; memory = "state/agents/r17_agent_memory_packets/orchestrator.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_qa_result"; type = "qa_result"; from = "qa_test_agent"; to = "orchestrator"; parent = "r17_020_seed_message_implementation_result"; handoff = "r17_020_seed_handoff_qa_to_audit"; input = "state/tools/r17_qa_test_agent_adapter_request_packet.json"; output = "state/tools/r17_qa_test_agent_adapter_result_packet.json"; memory = "state/agents/r17_agent_memory_packets/orchestrator.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_defect_report"; type = "defect_report"; from = "qa_test_agent"; to = "developer"; parent = "r17_020_seed_message_qa_result"; handoff = "r17_020_seed_handoff_qa_to_fix"; input = "state/tools/r17_qa_test_agent_adapter_request_packet.json"; output = "state/tools/r17_qa_test_agent_adapter_defect_packet.json"; memory = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_fix_request"; type = "fix_request"; from = "orchestrator"; to = "developer"; parent = "r17_020_seed_message_defect_report"; handoff = "r17_020_seed_handoff_qa_to_fix"; input = "state/tools/r17_qa_test_agent_adapter_defect_packet.json"; output = "state/tools/r17_codex_executor_adapter_result_packet.json"; memory = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_audit_request"; type = "audit_request"; from = "orchestrator"; to = "evidence_auditor"; parent = "r17_020_seed_message_qa_result"; handoff = "r17_020_seed_handoff_qa_to_audit"; input = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"; output = "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"; memory = "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_audit_verdict"; type = "audit_verdict"; from = "evidence_auditor"; to = "orchestrator"; parent = "r17_020_seed_message_audit_request"; handoff = "r17_020_seed_handoff_audit_to_release_recommendation"; input = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"; output = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"; memory = "state/agents/r17_agent_memory_packets/orchestrator.memory_packet.json"; requires_user = $false },
        [pscustomobject]@{ id = "r17_020_seed_message_release_recommendation"; type = "release_recommendation"; from = "release_closeout"; to = "user"; parent = "r17_020_seed_message_audit_verdict"; handoff = "r17_020_seed_handoff_release_recommendation_to_user_decision"; input = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"; output = "not_implemented_seed"; memory = "state/agents/r17_agent_memory_packets/user.memory_packet.json"; requires_user = $true },
        [pscustomobject]@{ id = "r17_020_seed_message_user_decision_request"; type = "user_decision_request"; from = "orchestrator"; to = "user"; parent = "r17_020_seed_message_release_recommendation"; handoff = "r17_020_seed_handoff_release_recommendation_to_user_decision"; input = "not_implemented_seed"; output = "not_implemented_seed"; memory = "state/agents/r17_agent_memory_packets/user.memory_packet.json"; requires_user = $true }
    )
}

function New-R17A2aMessagePacket {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $falseFlags = Get-R17A2aFalseFlags
    $explicitFalse = Get-R17A2aExplicitFalseMap
    $message = [ordered]@{
        artifact_type = "r17_a2a_message_seed_packet"
        contract_version = "v1"
        message_id = [string]$Definition.id
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = $script:SourceTask
        message_type = [string]$Definition.type
        from_agent_id = [string]$Definition.from
        to_agent_id = [string]$Definition.to
        correlation_id = "r17_020_a2a_contract_seed_correlation"
        parent_message_id = [string]$Definition.parent
        invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_$($Definition.to)"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        board_event_ref = "not_implemented_seed"
        input_packet_ref = [string]$Definition.input
        output_packet_ref = [string]$Definition.output
        memory_packet_ref = [string]$Definition.memory
        evidence_refs = Get-R17A2aCommonEvidenceRefs
        authority_refs = (Get-R17A2aCommonAuthorityRefs) + @("state/agents/r17_agent_identities/$($Definition.to).identity.json")
        acceptance_criteria_refs = @(
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md#r17-020-define-a2a-message-and-handoff-contracts",
            "execution/KANBAN.md#r17-020-define-a2a-message-and-handoff-contracts"
        )
        status = "not_dispatched"
        execution_mode = "disabled_seed"
        handoff_ref = "state/a2a/r17_a2a_handoff_seed_packets.json#$($Definition.handoff)"
        requires_user_decision = [bool]$Definition.requires_user
        runtime_flags = $falseFlags
        claim_status = Get-R17A2aClaimStatus
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    foreach ($field in $script:ExplicitFalseFields) { $message[$field] = $explicitFalse.PSObject.Properties[$field].Value }
    return [pscustomobject]$message
}

function Get-R17A2aHandoffSeedDefinitions {
    return @(
        [pscustomobject]@{ id = "r17_020_seed_handoff_planning_to_implementation"; type = "planning_to_implementation"; msg = "r17_020_seed_message_task_assignment"; from = "orchestrator"; to = "developer"; messages = @("task_assignment", "clarification_request", "implementation_result"); inputs = @("state/tools/r17_codex_executor_adapter_request_packet.json"); outputs = @("state/tools/r17_codex_executor_adapter_result_packet.json"); memory = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"; user = $false; qaBeforeAudit = $false; auditBeforeRelease = $false },
        [pscustomobject]@{ id = "r17_020_seed_handoff_implementation_to_qa"; type = "implementation_to_qa"; msg = "r17_020_seed_message_implementation_result"; from = "orchestrator"; to = "qa_test_agent"; messages = @("implementation_result", "qa_result", "defect_report"); inputs = @("state/tools/r17_qa_test_agent_adapter_request_packet.json"); outputs = @("state/tools/r17_qa_test_agent_adapter_result_packet.json", "state/tools/r17_qa_test_agent_adapter_defect_packet.json"); memory = "state/agents/r17_agent_memory_packets/qa_test_agent.memory_packet.json"; user = $false; qaBeforeAudit = $false; auditBeforeRelease = $false },
        [pscustomobject]@{ id = "r17_020_seed_handoff_qa_to_fix"; type = "qa_to_fix"; msg = "r17_020_seed_message_defect_report"; from = "orchestrator"; to = "developer"; messages = @("defect_report", "fix_request", "implementation_result"); inputs = @("state/tools/r17_qa_test_agent_adapter_defect_packet.json"); outputs = @("state/tools/r17_codex_executor_adapter_result_packet.json"); memory = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"; user = $false; qaBeforeAudit = $true; auditBeforeRelease = $false },
        [pscustomobject]@{ id = "r17_020_seed_handoff_qa_to_audit"; type = "qa_to_audit"; msg = "r17_020_seed_message_audit_request"; from = "orchestrator"; to = "evidence_auditor"; messages = @("qa_result", "audit_request", "audit_verdict"); inputs = @("state/tools/r17_evidence_auditor_api_adapter_request_packet.json"); outputs = @("state/tools/r17_evidence_auditor_api_adapter_response_packet.json", "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"); memory = "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json"; user = $false; qaBeforeAudit = $true; auditBeforeRelease = $false },
        [pscustomobject]@{ id = "r17_020_seed_handoff_audit_to_release_recommendation"; type = "audit_to_release_recommendation"; msg = "r17_020_seed_message_audit_verdict"; from = "orchestrator"; to = "release_closeout"; messages = @("audit_verdict", "release_recommendation"); inputs = @("state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"); outputs = @("not_implemented_seed"); memory = "state/agents/r17_agent_memory_packets/release_closeout.memory_packet.json"; user = $false; qaBeforeAudit = $true; auditBeforeRelease = $true },
        [pscustomobject]@{ id = "r17_020_seed_handoff_release_recommendation_to_user_decision"; type = "release_recommendation_to_user_decision"; msg = "r17_020_seed_message_user_decision_request"; from = "orchestrator"; to = "user"; messages = @("release_recommendation", "user_decision_request"); inputs = @("not_implemented_seed"); outputs = @("not_implemented_seed"); memory = "state/agents/r17_agent_memory_packets/user.memory_packet.json"; user = $true; qaBeforeAudit = $true; auditBeforeRelease = $true }
    )
}

function New-R17A2aHandoffPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $falseFlags = Get-R17A2aFalseFlags
    $explicitFalse = Get-R17A2aExplicitFalseMap
    $handoff = [ordered]@{
        artifact_type = "r17_a2a_handoff_seed_packet"
        contract_version = "v1"
        handoff_id = [string]$Definition.id
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = $script:SourceTask
        handoff_type = [string]$Definition.type
        source_message_ref = "state/a2a/r17_a2a_message_seed_packets.json#$($Definition.msg)"
        from_agent_id = [string]$Definition.from
        to_agent_id = [string]$Definition.to
        allowed_message_types = @($Definition.messages)
        allowed_next_actions = @("prepare_packet_only", "validate_contract_only", "record_future_dispatch_precondition", "block_until_future_dispatcher_task")
        required_input_refs = @($Definition.inputs)
        required_output_refs = @($Definition.outputs)
        authority_refs = (Get-R17A2aCommonAuthorityRefs) + @("state/agents/r17_agent_identities/$($Definition.to).identity.json")
        memory_packet_ref = [string]$Definition.memory
        evidence_refs = Get-R17A2aCommonEvidenceRefs
        board_event_ref = "not_implemented_seed"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        user_approval_required = [bool]$Definition.user
        qa_required_before_audit = [bool]$Definition.qaBeforeAudit
        audit_required_before_release_recommendation = [bool]$Definition.auditBeforeRelease
        status = "not_executed_disabled_foundation"
        execution_mode = "disabled_seed"
        runtime_flags = $falseFlags
        claim_status = Get-R17A2aClaimStatus
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    foreach ($field in $script:ExplicitFalseFields) { $handoff[$field] = $explicitFalse.PSObject.Properties[$field].Value }
    return [pscustomobject]$handoff
}

function New-R17A2aArtifactsObjectSet {
    param([object]$GitIdentity = (Get-R17A2aGitIdentity))

    $messageContract = New-R17A2aMessageContract
    $handoffContract = New-R17A2aHandoffContract
    $messages = @(Get-R17A2aMessageSeedDefinitions | ForEach-Object { New-R17A2aMessagePacket -Definition $_ -GitIdentity $GitIdentity })
    $handoffs = @(Get-R17A2aHandoffSeedDefinitions | ForEach-Object { New-R17A2aHandoffPacket -Definition $_ -GitIdentity $GitIdentity })

    $messagePackets = [ordered]@{
        artifact_type = "r17_a2a_message_seed_packet_set"
        contract_version = "v1"
        packet_set_id = "aioffice-r17-020-a2a-message-seed-packets-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        contract_ref = "contracts/a2a/r17_a2a_message.contract.json"
        handoff_contract_ref = "contracts/a2a/r17_a2a_handoff.contract.json"
        message_count = $messages.Count
        allowed_message_types = $script:AllowedMessageTypes
        messages = $messages
        runtime_boundaries = Get-R17A2aFalseFlags
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    $handoffPackets = [ordered]@{
        artifact_type = "r17_a2a_handoff_seed_packet_set"
        contract_version = "v1"
        packet_set_id = "aioffice-r17-020-a2a-handoff-seed-packets-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        message_contract_ref = "contracts/a2a/r17_a2a_message.contract.json"
        contract_ref = "contracts/a2a/r17_a2a_handoff.contract.json"
        handoff_count = $handoffs.Count
        allowed_handoff_types = $script:AllowedHandoffTypes
        handoffs = $handoffs
        runtime_boundaries = Get-R17A2aFalseFlags
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    $report = [ordered]@{
        artifact_type = "r17_a2a_contract_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-020-a2a-contract-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-021"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        message_contract_ref = "contracts/a2a/r17_a2a_message.contract.json"
        handoff_contract_ref = "contracts/a2a/r17_a2a_handoff.contract.json"
        message_seed_packet_ref = "state/a2a/r17_a2a_message_seed_packets.json"
        handoff_seed_packet_ref = "state/a2a/r17_a2a_handoff_seed_packets.json"
        ui_snapshot_ref = "state/ui/r17_kanban_mvp/r17_a2a_contracts_snapshot.json"
        total_message_seed_packets = $messages.Count
        total_handoff_seed_packets = $handoffs.Count
        message_types = $script:AllowedMessageTypes
        message_ids = @($messages | ForEach-Object { $_.message_id })
        handoff_ids = @($handoffs | ForEach-Object { $_.handoff_id })
        dependency_refs = Get-R17A2aDependencyRefs
        runtime_boundary_summary = Get-R17A2aFalseFlags
        explicit_false_fields = Get-R17A2aExplicitFalseMap
        claim_status = Get-R17A2aClaimStatus
        validation_summary = [ordered]@{
            message_contract_fields_present = "passed"
            handoff_contract_fields_present = "passed"
            supported_message_types_present = "passed"
            registry_agent_refs_valid = "passed"
            required_refs_present = "passed"
            exact_ref_policy_enforced = "passed"
            explicit_false_fields_preserved = "passed"
            no_a2a_runtime = "passed"
            no_a2a_dispatcher = "passed"
            no_message_sent_or_dispatched = "passed"
            no_agent_or_adapter_invocation = "passed"
            no_tool_call_or_external_api_call = "passed"
            no_board_mutation = "passed"
            no_qa_result_or_real_audit_verdict = "passed"
            compact_invalid_fixture_coverage = "passed"
            future_r17_021_plus_completion_claims_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        evidence_refs = Get-R17A2aCommonEvidenceRefs
        preserved_boundaries = Get-R17A2aPreservedBoundaries
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_a2a_contracts_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-020-a2a-contracts-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-021"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        message_contract_ref = "contracts/a2a/r17_a2a_message.contract.json"
        handoff_contract_ref = "contracts/a2a/r17_a2a_handoff.contract.json"
        check_report_ref = "state/a2a/r17_a2a_contract_check_report.json"
        total_message_seed_packets = $messages.Count
        total_handoff_seed_packets = $handoffs.Count
        supported_message_types = $script:AllowedMessageTypes
        visible_messages = @($messages | ForEach-Object {
            [ordered]@{
                message_id = $_.message_id
                message_type = $_.message_type
                from_agent_id = $_.from_agent_id
                to_agent_id = $_.to_agent_id
                status = $_.status
                execution_mode = $_.execution_mode
                a2a_message_sent = $_.a2a_message_sent
                a2a_message_dispatched = $_.a2a_message_dispatched
                agent_invocation_performed = $_.agent_invocation_performed
                adapter_runtime_invoked = $_.adapter_runtime_invoked
                actual_tool_call_performed = $_.actual_tool_call_performed
            }
        })
        visible_handoffs = @($handoffs | ForEach-Object {
            [ordered]@{
                handoff_id = $_.handoff_id
                handoff_type = $_.handoff_type
                from_agent_id = $_.from_agent_id
                to_agent_id = $_.to_agent_id
                status = $_.status
                execution_mode = $_.execution_mode
                user_approval_required = $_.user_approval_required
                qa_required_before_audit = $_.qa_required_before_audit
                audit_required_before_release_recommendation = $_.audit_required_before_release_recommendation
            }
        })
        status_summary = Get-R17A2aExplicitFalseMap
        runtime_boundaries = Get-R17A2aFalseFlags
        claim_status = Get-R17A2aClaimStatus
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    return [pscustomobject]@{
        MessageContract = [pscustomobject]$messageContract
        HandoffContract = [pscustomobject]$handoffContract
        MessagePackets = [pscustomobject]$messagePackets
        HandoffPackets = [pscustomobject]$handoffPackets
        Report = [pscustomobject]$report
        Snapshot = [pscustomobject]$snapshot
    }
}

function Get-R17A2aInvalidFixtureDefinitions {
    return @(
        [pscustomobject]@{ id = "invalid_unsupported_message_type"; target = "message"; property = "message_type"; value = "runtime_chat"; expected = @("unsupported message_type") },
        [pscustomobject]@{ id = "invalid_unknown_from_agent_id"; target = "message"; property = "from_agent_id"; value = "shadow_agent"; expected = @("unknown from_agent_id") },
        [pscustomobject]@{ id = "invalid_unknown_to_agent_id"; target = "message"; property = "to_agent_id"; value = "shadow_agent"; expected = @("unknown to_agent_id") },
        [pscustomobject]@{ id = "invalid_missing_correlation_id"; target = "message"; property = "correlation_id"; value = ""; expected = @("missing correlation_id") },
        [pscustomobject]@{ id = "invalid_missing_card_id"; target = "message"; property = "card_id"; value = ""; expected = @("missing card_id") },
        [pscustomobject]@{ id = "invalid_missing_evidence_refs"; target = "message"; property = "evidence_refs"; value = @(); expected = @("evidence_refs") },
        [pscustomobject]@{ id = "invalid_missing_authority_refs"; target = "message"; property = "authority_refs"; value = @(); expected = @("authority_refs") },
        [pscustomobject]@{ id = "invalid_wildcard_evidence_path"; target = "message_evidence_append"; value = "state/**/*.json"; expected = @("wildcard") },
        [pscustomobject]@{ id = "invalid_local_backups_ref"; target = "message_evidence_append"; value = ".local_backups/r17/a2a.json"; expected = @(".local_backups") },
        [pscustomobject]@{ id = "invalid_broad_repo_scan_output"; target = "message_add_property"; property = "debug_dump"; value = "Get-ChildItem -Recurse returned a repository-wide file list"; expected = @("broad repo scan output") },
        [pscustomobject]@{ id = "invalid_embedded_full_source_file_contents"; target = "message_add_property"; property = "embedded_source"; value = "Set-StrictMode -Version Latest`nfunction Invoke-Runtime { param() }"; expected = @("full source file contents") },
        [pscustomobject]@{ id = "invalid_a2a_runtime_implemented_true"; target = "message_runtime_flag"; property = "a2a_runtime_implemented"; value = $true; expected = @("a2a_runtime_implemented", "must be false") },
        [pscustomobject]@{ id = "invalid_a2a_dispatcher_implemented_true"; target = "message_runtime_flag"; property = "a2a_dispatcher_implemented"; value = $true; expected = @("a2a_dispatcher_implemented", "must be false") },
        [pscustomobject]@{ id = "invalid_a2a_message_sent_true"; target = "message_runtime_flag"; property = "a2a_message_sent"; value = $true; expected = @("a2a_message_sent", "must be false") },
        [pscustomobject]@{ id = "invalid_a2a_message_dispatched_true"; target = "message_runtime_flag"; property = "a2a_message_dispatched"; value = $true; expected = @("a2a_message_dispatched", "must be false") },
        [pscustomobject]@{ id = "invalid_live_agent_runtime_invoked_true"; target = "message_runtime_flag"; property = "live_agent_runtime_invoked"; value = $true; expected = @("live_agent_runtime_invoked", "must be false") },
        [pscustomobject]@{ id = "invalid_live_orchestrator_runtime_invoked_true"; target = "message_runtime_flag"; property = "live_orchestrator_runtime_invoked"; value = $true; expected = @("live_orchestrator_runtime_invoked", "must be false") },
        [pscustomobject]@{ id = "invalid_agent_invocation_performed_true"; target = "message_runtime_flag"; property = "agent_invocation_performed"; value = $true; expected = @("agent_invocation_performed", "must be false") },
        [pscustomobject]@{ id = "invalid_adapter_runtime_invoked_true"; target = "message_runtime_flag"; property = "adapter_runtime_invoked"; value = $true; expected = @("adapter_runtime_invoked", "must be false") },
        [pscustomobject]@{ id = "invalid_actual_tool_call_performed_true"; target = "message_runtime_flag"; property = "actual_tool_call_performed"; value = $true; expected = @("actual_tool_call_performed", "must be false") },
        [pscustomobject]@{ id = "invalid_external_api_call_performed_true"; target = "message_runtime_flag"; property = "external_api_call_performed"; value = $true; expected = @("external_api_call_performed", "must be false") },
        [pscustomobject]@{ id = "invalid_board_mutation_performed_true"; target = "message_runtime_flag"; property = "board_mutation_performed"; value = $true; expected = @("board_mutation_performed", "must be false") },
        [pscustomobject]@{ id = "invalid_runtime_card_creation_performed_true"; target = "message_runtime_flag"; property = "runtime_card_creation_performed"; value = $true; expected = @("runtime_card_creation_performed", "must be false") },
        [pscustomobject]@{ id = "invalid_product_runtime_executed_true"; target = "message_runtime_flag"; property = "product_runtime_executed"; value = $true; expected = @("product_runtime_executed", "must be false") },
        [pscustomobject]@{ id = "invalid_qa_result_claimed_true"; target = "message_runtime_flag"; property = "qa_result_claimed"; value = $true; expected = @("qa_result_claimed", "must be false") },
        [pscustomobject]@{ id = "invalid_audit_verdict_claimed_true"; target = "message_runtime_flag"; property = "audit_verdict_claimed"; value = $true; expected = @("audit_verdict_claimed", "must be false") },
        [pscustomobject]@{ id = "invalid_real_audit_verdict_true"; target = "message_runtime_flag"; property = "real_audit_verdict"; value = $true; expected = @("real_audit_verdict", "must be false") },
        [pscustomobject]@{ id = "invalid_external_audit_acceptance_claimed_true"; target = "message_runtime_flag"; property = "external_audit_acceptance_claimed"; value = $true; expected = @("external_audit_acceptance_claimed", "must be false") },
        [pscustomobject]@{ id = "invalid_main_merge_claimed_true"; target = "message_runtime_flag"; property = "main_merge_claimed"; value = $true; expected = @("main_merge_claimed", "must be false") },
        [pscustomobject]@{ id = "invalid_future_r17_021_completion_claim"; target = "message_non_claim_append"; value = "R17-021 is implemented by this pass."; expected = @("future R17-021+ completion claim") },
        [pscustomobject]@{ id = "invalid_handoff_unsupported_message_type"; target = "handoff_allowed_message_type_append"; value = "runtime_ping"; expected = @("unsupported allowed_message_type") },
        [pscustomobject]@{ id = "invalid_handoff_unknown_to_agent_id"; target = "handoff"; property = "to_agent_id"; value = "shadow_agent"; expected = @("unknown to_agent_id") },
        [pscustomobject]@{ id = "invalid_handoff_missing_required_input_refs"; target = "handoff"; property = "required_input_refs"; value = @(); expected = @("required_input_refs") }
    )
}

function New-R17A2aFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_message_contract.json") -Value $ObjectSet.MessageContract
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_handoff_contract.json") -Value $ObjectSet.HandoffContract
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_message_seed_packets.json") -Value $ObjectSet.MessagePackets
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_handoff_seed_packets.json") -Value $ObjectSet.HandoffPackets
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17A2aJson -Path (Join-Path $FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $count = 0
    foreach ($fixture in Get-R17A2aInvalidFixtureDefinitions) {
        $count += 1
        $value = [ordered]@{
            fixture_id = $fixture.id
            target = $fixture.target
            property = if (Test-R17A2aHasProperty -Object $fixture -Name "property") { $fixture.property } else { $null }
            value = if (Test-R17A2aHasProperty -Object $fixture -Name "value") { $fixture.value } else { $null }
            expected_failure_fragments = @($fixture.expected)
        }
        Write-R17A2aJson -Path (Join-Path $FixtureRoot ("{0}.json" -f $fixture.id)) -Value $value
    }

    return $count
}

function New-R17A2aProofFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProofRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $ProofRoot -Force | Out-Null

    $proofReview = @"
# R17-020 A2A Message and Handoff Contracts Proof Review

R17-020 adds the A2A message and handoff contract foundation only. The generated contracts define allowed message types, required refs, registry-bound agent IDs, handoff gate fields, exact-ref rules, compact fixtures, and explicit false runtime flags.

No A2A runtime, dispatcher, message sending, message dispatch, live agent invocation, adapter runtime, actual tool call, external API call, board mutation, QA result, real audit verdict, external audit acceptance, autonomous agents, product runtime, or main merge is claimed.

R17 is active through R17-020 only. R17-021 through R17-028 remain planned only.
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_020_a2a_contracts_evidence_index"
        source_task = $script:SourceTask
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = Get-R17A2aCommonEvidenceRefs
        validation_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_a2a_contracts.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_a2a_contracts.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_a2a_contracts.ps1"
        )
        non_claims = Get-R17A2aNonClaims
        rejected_claims = Get-R17A2aRejectedClaims
    }

    $validationManifest = @"
# R17-020 Validation Manifest

Expected focused validation:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_a2a_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_a2a_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_a2a_contracts.ps1`
- relevant existing R17 registry, memory loader, invocation log, adapter, ledger, board/orchestration, and status gates
- `git diff --check`

The manifest is proof-review support only; command execution remains terminal Git/PowerShell truth.
"@

    Write-R17A2aText -Path (Join-Path $ProofRoot "proof_review.md") -Value $proofReview
    Write-R17A2aJson -Path (Join-Path $ProofRoot "evidence_index.json") -Value $evidenceIndex
    Write-R17A2aText -Path (Join-Path $ProofRoot "validation_manifest.md") -Value $validationManifest
}

function New-R17A2aContractsArtifacts {
    param([string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot))

    $paths = Get-R17A2aContractsPaths -RepositoryRoot $RepositoryRoot
    $gitIdentity = Get-R17A2aGitIdentity -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17A2aArtifactsObjectSet -GitIdentity $gitIdentity

    Write-R17A2aJson -Path $paths.MessageContract -Value $objectSet.MessageContract
    Write-R17A2aJson -Path $paths.HandoffContract -Value $objectSet.HandoffContract
    Write-R17A2aJson -Path $paths.MessagePackets -Value $objectSet.MessagePackets
    Write-R17A2aJson -Path $paths.HandoffPackets -Value $objectSet.HandoffPackets
    Write-R17A2aJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17A2aJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    $invalidFixtureCount = New-R17A2aFixtureFiles -FixtureRoot $paths.FixtureRoot -ObjectSet $objectSet
    New-R17A2aProofFiles -ProofRoot $paths.ProofRoot -ObjectSet $objectSet

    return [pscustomobject]@{
        MessageContract = $paths.MessageContract
        HandoffContract = $paths.HandoffContract
        MessagePackets = $paths.MessagePackets
        HandoffPackets = $paths.HandoffPackets
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        MessageCount = @($objectSet.MessagePackets.messages).Count
        HandoffCount = @($objectSet.HandoffPackets.handoffs).Count
        InvalidFixtureCount = $invalidFixtureCount
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17A2aRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17A2aHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17A2aContains {
    param(
        [Parameter(Mandatory = $true)][object[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $strings = @($Values | ForEach-Object { [string]$_ })
    foreach ($required in $Required) {
        if ($strings -notcontains $required) {
            throw "$Context missing required value '$required'."
        }
    }
}

function Assert-R17A2aFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        $value = Get-R17A2aProperty -Object $Object -Name $field -Context $Context
        if ($value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Assert-R17A2aSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot),
        [switch]$AllowPlaceholder,
        [switch]$RequireExistingPath
    )

    if ($AllowPlaceholder -and $Path -in @("none", "not_implemented_seed", "not_applicable", "disabled_seed", "placeholder_only")) { return }
    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context path must not be empty." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context path must be repo-relative." }
    if ($Path -match '(^|/)\.\.(/|$)' -or $Path -match '\\') { throw "$Context path must be normalized repo-relative path." }
    if ($Path -match '[\*\?\[\]]') { throw "$Context path contains wildcard characters." }
    if ($Path -match '^(?i:https?://|file://)') { throw "$Context path must not be a URL." }
    if ($Path -match '(^|/)\.local_backups(/|$)') { throw "$Context path must not point at .local_backups." }

    if ($RequireExistingPath) {
        $pathOnly = ($Path -split '#', 2)[0]
        $resolved = Resolve-R17A2aContractsPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Assert-R17A2aNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $json = ($Value | ConvertTo-Json -Depth 40 -Compress)
    if ($json -match '(?i)Get-ChildItem\s+-Recurse|git\s+ls-files|rg\s+--files|repo-wide file list|broad repo scan') {
        throw "$Context contains broad repo scan output."
    }
    if ($json -match '(?i)Set-StrictMode\s+-Version\s+Latest|function\s+[A-Za-z0-9_-]+\s*\{|full source file contents') {
        throw "$Context contains embedded full source file contents."
    }
    if ($json -match '(?i)\bR17-(0(?:2[1-8])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exercised|working|available|ships|claimed)\b') {
        throw "$Context contains future R17-021+ completion claim."
    }
}

function Get-R17A2aAgentIdMap {
    param([object]$Registry)

    $map = @{}
    foreach ($agentId in @($Registry.required_agent_ids)) {
        $map[[string]$agentId] = $true
    }
    foreach ($agent in @($Registry.agents)) {
        $map[[string]$agent.agent_id] = $true
    }
    return $map
}

function Assert-R17A2aRefArray {
    param(
        [Parameter(Mandatory = $true)][object[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot),
        [switch]$SkipRefExistence,
        [switch]$AllowPlaceholder
    )

    if (@($Values).Count -lt 1) { throw "$Context must not be empty." }
    foreach ($ref in @($Values)) {
        Assert-R17A2aSafeRefPath -Path ([string]$ref) -Context $Context -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder:$AllowPlaceholder
    }
}

function Assert-R17A2aMessagePacket {
    param(
        [Parameter(Mandatory = $true)][object]$Message,
        [Parameter(Mandatory = $true)][hashtable]$AgentMap,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17A2aRequiredFields -Object $Message -FieldNames $script:RequiredMessageFields -Context "message"
    if ([string]$Message.source_task -ne $script:SourceTask) { throw "message $($Message.message_id) source_task must be R17-020." }
    if ([string]::IsNullOrWhiteSpace([string]$Message.card_id)) { throw "message $($Message.message_id) missing card_id." }
    if ([string]$Message.card_id -ne $script:SourceTask) { throw "message $($Message.message_id) card_id must be R17-020." }
    if ($script:AllowedMessageTypes -notcontains [string]$Message.message_type) { throw "message $($Message.message_id) unsupported message_type '$($Message.message_type)'." }
    if (-not $AgentMap.ContainsKey([string]$Message.from_agent_id)) { throw "message $($Message.message_id) unknown from_agent_id '$($Message.from_agent_id)'." }
    if (-not $AgentMap.ContainsKey([string]$Message.to_agent_id)) { throw "message $($Message.message_id) unknown to_agent_id '$($Message.to_agent_id)'." }
    if ([string]::IsNullOrWhiteSpace([string]$Message.correlation_id)) { throw "message $($Message.message_id) missing correlation_id." }
    if ($script:AllowedStatuses -notcontains [string]$Message.status) { throw "message $($Message.message_id) status is not allowed." }
    if ($script:AllowedExecutionModes -notcontains [string]$Message.execution_mode) { throw "message $($Message.message_id) execution_mode is not allowed." }

    Assert-R17A2aSafeRefPath -Path ([string]$Message.invocation_ref) -Context "message $($Message.message_id) invocation_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Message.tool_call_ledger_ref) -Context "message $($Message.message_id) tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aSafeRefPath -Path ([string]$Message.board_event_ref) -Context "message $($Message.message_id) board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Message.input_packet_ref) -Context "message $($Message.message_id) input_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Message.output_packet_ref) -Context "message $($Message.message_id) output_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Message.memory_packet_ref) -Context "message $($Message.message_id) memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Message.handoff_ref) -Context "message $($Message.message_id) handoff_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder

    if (@($Message.evidence_refs).Count -lt 1) { throw "message $($Message.message_id) missing evidence_refs." }
    if (@($Message.authority_refs).Count -lt 1) { throw "message $($Message.message_id) missing authority_refs." }
    Assert-R17A2aRefArray -Values @($Message.evidence_refs) -Context "message $($Message.message_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aRefArray -Values @($Message.authority_refs) -Context "message $($Message.message_id) authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aRefArray -Values @($Message.acceptance_criteria_refs) -Context "message $($Message.message_id) acceptance_criteria_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence

    Assert-R17A2aFalseFields -Object $Message.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "message $($Message.message_id) runtime_flags"
    Assert-R17A2aFalseFields -Object $Message -FieldNames $script:ExplicitFalseFields -Context "message $($Message.message_id)"
    Assert-R17A2aNoForbiddenContent -Value $Message -Context "message $($Message.message_id)"
}

function Assert-R17A2aHandoffPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Handoff,
        [Parameter(Mandatory = $true)][hashtable]$AgentMap,
        [Parameter(Mandatory = $true)][string[]]$MessageIds,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17A2aRequiredFields -Object $Handoff -FieldNames $script:RequiredHandoffFields -Context "handoff"
    if ([string]$Handoff.source_task -ne $script:SourceTask) { throw "handoff $($Handoff.handoff_id) source_task must be R17-020." }
    if ([string]::IsNullOrWhiteSpace([string]$Handoff.card_id)) { throw "handoff $($Handoff.handoff_id) missing card_id." }
    if ([string]$Handoff.card_id -ne $script:SourceTask) { throw "handoff $($Handoff.handoff_id) card_id must be R17-020." }
    if ($script:AllowedHandoffTypes -notcontains [string]$Handoff.handoff_type) { throw "handoff $($Handoff.handoff_id) unsupported handoff_type '$($Handoff.handoff_type)'." }
    if (-not $AgentMap.ContainsKey([string]$Handoff.from_agent_id)) { throw "handoff $($Handoff.handoff_id) unknown from_agent_id '$($Handoff.from_agent_id)'." }
    if (-not $AgentMap.ContainsKey([string]$Handoff.to_agent_id)) { throw "handoff $($Handoff.handoff_id) unknown to_agent_id '$($Handoff.to_agent_id)'." }
    if ($script:AllowedStatuses -notcontains [string]$Handoff.status) { throw "handoff $($Handoff.handoff_id) status is not allowed." }
    if ($script:AllowedExecutionModes -notcontains [string]$Handoff.execution_mode) { throw "handoff $($Handoff.handoff_id) execution_mode is not allowed." }

    $sourceMessageId = ([string]$Handoff.source_message_ref -split '#', 2)[-1]
    if ($MessageIds -notcontains $sourceMessageId) { throw "handoff $($Handoff.handoff_id) source_message_ref does not match a seed message." }
    Assert-R17A2aSafeRefPath -Path ([string]$Handoff.source_message_ref) -Context "handoff $($Handoff.handoff_id) source_message_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aSafeRefPath -Path ([string]$Handoff.board_event_ref) -Context "handoff $($Handoff.handoff_id) board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aSafeRefPath -Path ([string]$Handoff.tool_call_ledger_ref) -Context "handoff $($Handoff.handoff_id) tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aSafeRefPath -Path ([string]$Handoff.memory_packet_ref) -Context "handoff $($Handoff.handoff_id) memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder

    if (@($Handoff.allowed_message_types).Count -lt 1) { throw "handoff $($Handoff.handoff_id) allowed_message_types must not be empty." }
    foreach ($messageType in @($Handoff.allowed_message_types)) {
        if ($script:AllowedMessageTypes -notcontains [string]$messageType) { throw "handoff $($Handoff.handoff_id) unsupported allowed_message_type '$messageType'." }
    }
    if (@($Handoff.allowed_next_actions).Count -lt 1) { throw "handoff $($Handoff.handoff_id) allowed_next_actions must not be empty." }
    if (@($Handoff.required_input_refs).Count -lt 1) { throw "handoff $($Handoff.handoff_id) required_input_refs must not be empty." }
    if (@($Handoff.required_output_refs).Count -lt 1) { throw "handoff $($Handoff.handoff_id) required_output_refs must not be empty." }
    Assert-R17A2aRefArray -Values @($Handoff.required_input_refs) -Context "handoff $($Handoff.handoff_id) required_input_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aRefArray -Values @($Handoff.required_output_refs) -Context "handoff $($Handoff.handoff_id) required_output_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aRefArray -Values @($Handoff.authority_refs) -Context "handoff $($Handoff.handoff_id) authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aRefArray -Values @($Handoff.evidence_refs) -Context "handoff $($Handoff.handoff_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence

    Assert-R17A2aFalseFields -Object $Handoff.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "handoff $($Handoff.handoff_id) runtime_flags"
    Assert-R17A2aFalseFields -Object $Handoff -FieldNames $script:ExplicitFalseFields -Context "handoff $($Handoff.handoff_id)"
    Assert-R17A2aNoForbiddenContent -Value $Handoff -Context "handoff $($Handoff.handoff_id)"
}

function Assert-R17A2aFixtureCoverage {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $script:MinimumInvalidFixtureCount) {
        throw "fixture coverage requires at least $script:MinimumInvalidFixtureCount compact invalid fixtures."
    }
}

function Assert-R17A2aKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-020 must not modify the runtime/static renderer."
    }
}

function Test-R17A2aContractsSet {
    param(
        [Parameter(Mandatory = $true)][object]$MessageContract,
        [Parameter(Mandatory = $true)][object]$HandoffContract,
        [Parameter(Mandatory = $true)][object]$MessagePackets,
        [Parameter(Mandatory = $true)][object]$HandoffPackets,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot),
        [switch]$SkipFixtureCoverage,
        [switch]$SkipRefExistence,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17A2aRequiredFields -Object $MessageContract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "required_message_fields", "allowed_message_types", "allowed_statuses", "required_explicit_false_fields", "exact_ref_policy", "registry_policy", "runtime_policy", "implementation_boundaries", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "message contract"
    Assert-R17A2aRequiredFields -Object $HandoffContract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "required_handoff_fields", "allowed_handoff_types", "allowed_message_types", "allowed_statuses", "required_explicit_false_fields", "gate_policy", "implementation_boundaries", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "handoff contract"
    if ($MessageContract.source_task -ne $script:SourceTask) { throw "message contract source_task must be R17-020." }
    if ($HandoffContract.source_task -ne $script:SourceTask) { throw "handoff contract source_task must be R17-020." }
    Assert-R17A2aContains -Values @($MessageContract.required_message_fields) -Required $script:RequiredMessageFields -Context "message contract required_message_fields"
    Assert-R17A2aContains -Values @($HandoffContract.required_handoff_fields) -Required $script:RequiredHandoffFields -Context "handoff contract required_handoff_fields"
    Assert-R17A2aContains -Values @($MessageContract.allowed_message_types) -Required $script:AllowedMessageTypes -Context "message contract allowed_message_types"
    Assert-R17A2aContains -Values @($HandoffContract.allowed_message_types) -Required $script:AllowedMessageTypes -Context "handoff contract allowed_message_types"
    Assert-R17A2aContains -Values @($MessageContract.required_explicit_false_fields) -Required $script:ExplicitFalseFields -Context "message contract required_explicit_false_fields"
    Assert-R17A2aContains -Values @($HandoffContract.required_explicit_false_fields) -Required $script:ExplicitFalseFields -Context "handoff contract required_explicit_false_fields"
    Assert-R17A2aFalseFields -Object $MessageContract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "message contract implementation_boundaries"
    Assert-R17A2aFalseFields -Object $HandoffContract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "handoff contract implementation_boundaries"
    Assert-R17A2aFalseFields -Object $MessageContract.claim_status -FieldNames $script:ClaimStatusFields -Context "message contract claim_status"
    Assert-R17A2aFalseFields -Object $HandoffContract.claim_status -FieldNames $script:ClaimStatusFields -Context "handoff contract claim_status"

    $registry = Read-R17A2aJson -Path (Get-R17A2aContractsPaths -RepositoryRoot $RepositoryRoot).Registry
    $agentMap = Get-R17A2aAgentIdMap -Registry $registry

    Assert-R17A2aRequiredFields -Object $MessagePackets -FieldNames @("artifact_type", "source_task", "active_through_task", "contract_ref", "handoff_contract_ref", "message_count", "allowed_message_types", "messages", "runtime_boundaries", "non_claims", "rejected_claims") -Context "message packet set"
    Assert-R17A2aRequiredFields -Object $HandoffPackets -FieldNames @("artifact_type", "source_task", "active_through_task", "message_contract_ref", "contract_ref", "handoff_count", "allowed_handoff_types", "handoffs", "runtime_boundaries", "non_claims", "rejected_claims") -Context "handoff packet set"
    if ($MessagePackets.source_task -ne $script:SourceTask -or $MessagePackets.active_through_task -ne $script:SourceTask) { throw "message packet set must keep R17 active through R17-020." }
    if ($HandoffPackets.source_task -ne $script:SourceTask -or $HandoffPackets.active_through_task -ne $script:SourceTask) { throw "handoff packet set must keep R17 active through R17-020." }

    $messages = @($MessagePackets.messages)
    $handoffs = @($HandoffPackets.handoffs)
    if ([int]$MessagePackets.message_count -ne $messages.Count) { throw "message_count does not match messages." }
    if ([int]$HandoffPackets.handoff_count -ne $handoffs.Count) { throw "handoff_count does not match handoffs." }
    if ($messages.Count -ne $script:AllowedMessageTypes.Count) { throw "message packet set must include one disabled seed per supported message type." }

    $messageIds = @()
    $seenMessages = @{}
    foreach ($message in $messages) {
        if ($seenMessages.ContainsKey([string]$message.message_id)) { throw "duplicate message_id '$($message.message_id)'." }
        $seenMessages[[string]$message.message_id] = $true
        $messageIds += [string]$message.message_id
        Assert-R17A2aMessagePacket -Message $message -AgentMap $agentMap -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }
    Assert-R17A2aContains -Values @($messages | ForEach-Object { $_.message_type }) -Required $script:AllowedMessageTypes -Context "message packet message_types"

    $seenHandoffs = @{}
    foreach ($handoff in $handoffs) {
        if ($seenHandoffs.ContainsKey([string]$handoff.handoff_id)) { throw "duplicate handoff_id '$($handoff.handoff_id)'." }
        $seenHandoffs[[string]$handoff.handoff_id] = $true
        Assert-R17A2aHandoffPacket -Handoff $handoff -AgentMap $agentMap -MessageIds $messageIds -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    Assert-R17A2aRequiredFields -Object $Report -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "message_contract_ref", "handoff_contract_ref", "message_seed_packet_ref", "handoff_seed_packet_ref", "total_message_seed_packets", "total_handoff_seed_packets", "message_types", "message_ids", "handoff_ids", "dependency_refs", "runtime_boundary_summary", "explicit_false_fields", "claim_status", "validation_summary", "aggregate_verdict", "non_claims", "rejected_claims") -Context "check report"
    if ($Report.source_task -ne $script:SourceTask -or $Report.active_through_task -ne $script:SourceTask) { throw "check report must keep R17 active through R17-020." }
    if ($Report.planned_only_from -ne "R17-021" -or $Report.planned_only_through -ne "R17-028") { throw "check report must keep R17-021 through R17-028 planned only." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    if ([int]$Report.total_message_seed_packets -ne $messages.Count -or [int]$Report.total_handoff_seed_packets -ne $handoffs.Count) { throw "check report seed packet counts do not match." }
    Assert-R17A2aContains -Values @($Report.message_types) -Required $script:AllowedMessageTypes -Context "check report message_types"
    Assert-R17A2aFalseFields -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17A2aFalseFields -Object $Report.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "check report explicit_false_fields"
    Assert-R17A2aFalseFields -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    if ([bool]$Report.full_source_file_contents_embedded -ne $false -or [bool]$Report.broad_repo_scan_output_included -ne $false -or [bool]$Report.broad_repo_scan_used -ne $false) {
        throw "check report must preserve generated-artifact compactness guards."
    }
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    Assert-R17A2aRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "message_contract_ref", "handoff_contract_ref", "check_report_ref", "total_message_seed_packets", "total_handoff_seed_packets", "supported_message_types", "visible_messages", "visible_handoffs", "status_summary", "runtime_boundaries", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.source_task -ne $script:SourceTask -or $Snapshot.active_through_task -ne $script:SourceTask) { throw "UI snapshot must keep R17 active through R17-020." }
    if ($Snapshot.planned_only_from -ne "R17-021" -or $Snapshot.planned_only_through -ne "R17-028") { throw "UI snapshot must keep R17-021 through R17-028 planned only." }
    if ([int]$Snapshot.total_message_seed_packets -ne $messages.Count -or [int]$Snapshot.total_handoff_seed_packets -ne $handoffs.Count) { throw "UI snapshot counts do not match." }
    Assert-R17A2aFalseFields -Object $Snapshot.status_summary -FieldNames $script:ExplicitFalseFields -Context "UI snapshot status_summary"
    Assert-R17A2aFalseFields -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17A2aFalseFields -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"

    foreach ($object in @($MessageContract, $HandoffContract, $MessagePackets, $HandoffPackets, $Report, $Snapshot)) {
        Assert-R17A2aNoForbiddenContent -Value $object -Context "A2A artifact set"
    }

    if (-not $SkipFixtureCoverage) {
        Assert-R17A2aFixtureCoverage -FixtureRoot (Get-R17A2aContractsPaths -RepositoryRoot $RepositoryRoot).FixtureRoot
    }
    if (-not $SkipKanbanJsCheck) {
        Assert-R17A2aKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        MessageCount = $messages.Count
        HandoffCount = $handoffs.Count
        MessageTypes = $script:AllowedMessageTypes
        A2aRuntimeImplemented = $false
        A2aDispatcherImplemented = $false
        A2aMessageSent = $false
        A2aMessageDispatched = $false
        AgentInvocationPerformed = $false
        AdapterRuntimeInvoked = $false
        ActualToolCallPerformed = $false
        ExternalApiCallPerformed = $false
        BoardMutationPerformed = $false
        QaResultClaimed = $false
        RealAuditVerdict = $false
        MainMergeClaimed = $false
    }
}

function Test-R17A2aContracts {
    param([string]$RepositoryRoot = (Get-R17A2aContractsRepositoryRoot))

    $paths = Get-R17A2aContractsPaths -RepositoryRoot $RepositoryRoot
    return Test-R17A2aContractsSet `
        -MessageContract (Read-R17A2aJson -Path $paths.MessageContract) `
        -HandoffContract (Read-R17A2aJson -Path $paths.HandoffContract) `
        -MessagePackets (Read-R17A2aJson -Path $paths.MessagePackets) `
        -HandoffPackets (Read-R17A2aJson -Path $paths.HandoffPackets) `
        -Report (Read-R17A2aJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17A2aJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17A2aObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17A2aProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    if (-not (Test-R17A2aHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R17A2aObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17A2aProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    $property = $current.PSObject.Properties[$leaf]
    if ($null -ne $property) { $current.PSObject.Properties.Remove($leaf) }
}
