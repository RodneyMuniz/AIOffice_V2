Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-021"
$script:SeedSourceTask = "R17-020"
$script:AggregateVerdict = "generated_r17_a2a_dispatcher_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_021_a2a_dispatcher"
$script:FixtureRoot = "tests/fixtures/r17_a2a_dispatcher"
$script:MinimumInvalidFixtureCount = 32

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

$script:AllowedRouteStatuses = @(
    "valid_seed_route_not_dispatched",
    "blocked_unauthorized_handoff",
    "blocked_missing_required_ref",
    "blocked_unknown_agent",
    "blocked_unsupported_message_type",
    "blocked_runtime_claim",
    "invalid"
)

$script:AllowedDispatchDecisions = @(
    "not_dispatched_foundation_validation_only",
    "blocked_foundation_validation_only"
)

$script:AllowedNextActions = @(
    "prepare_packet_only",
    "validate_contract_only",
    "wait_for_user_decision_packet_only",
    "record_future_dispatch_precondition",
    "block_until_future_dispatcher_task"
)

$script:RequiredDispatchRecordFields = @(
    "dispatch_record_id",
    "source_task",
    "seed_source_task",
    "card_id",
    "correlation_id",
    "message_ref",
    "handoff_ref",
    "from_agent_id",
    "to_agent_id",
    "message_type",
    "handoff_from_agent_id",
    "handoff_to_agent_id",
    "route_status",
    "dispatch_decision",
    "dispatch_reason",
    "input_packet_ref",
    "output_packet_ref",
    "memory_packet_ref",
    "handoff_memory_packet_ref",
    "invocation_ref",
    "tool_call_ledger_ref",
    "board_event_ref",
    "allowed_next_actions",
    "required_input_refs",
    "required_output_refs",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "execution_mode",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredRouteSetFields = @(
    "artifact_type",
    "contract_version",
    "route_set_id",
    "source_task",
    "active_through_task",
    "planned_only_from",
    "planned_only_through",
    "contract_ref",
    "message_seed_packet_ref",
    "handoff_seed_packet_ref",
    "dispatch_log_ref",
    "route_count",
    "valid_seed_route_count",
    "blocked_route_count",
    "allowed_route_statuses",
    "routes",
    "runtime_boundaries",
    "explicit_false_fields",
    "claim_status",
    "non_claims",
    "rejected_claims"
)

$script:ExplicitFalseFields = @(
    "a2a_runtime_implemented",
    "a2a_dispatcher_runtime_implemented",
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
        "live_a2a_dispatch_performed",
        "live_a2a_message_runtime_invoked",
        "adapter_runtime_implemented",
        "codex_executor_invoked",
        "qa_test_agent_invoked",
        "evidence_auditor_api_invoked",
        "actual_agent_invoked",
        "runtime_dispatch_performed",
        "runtime_memory_engine_used",
        "vector_retrieval_performed",
        "autonomous_agent_executed",
        "production_runtime_executed",
        "external_integration_performed",
        "executable_handoff_performed",
        "executable_transition_performed",
        "dev_output_claimed",
        "r13_closure_claimed",
        "r14_caveat_removal_claimed",
        "r15_caveat_removal_claimed",
        "r17_022_plus_implementation_claimed",
        "full_source_file_contents_embedded",
        "broad_repo_scan_output_included",
        "broad_repo_scan_used"
    )
)

$script:ClaimStatusFields = @(
    "a2a_runtime_claimed",
    "a2a_dispatcher_runtime_claimed",
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
    "r17_022_plus_implementation_claimed"
)

function Get-R17A2aDispatcherRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17A2aDispatcherPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17A2aDispatcherJson {
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

function Read-R17A2aDispatcherJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSONL artifact '$Path' does not exist."
    }

    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $records += ($line | ConvertFrom-Json)
        }
        catch {
            throw "JSONL artifact '$Path' contains malformed line. $($_.Exception.Message)"
        }
    }
    return $records
}

function Write-R17A2aDispatcherJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $Value | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17A2aDispatcherJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Values
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $lines = @($Values | ForEach-Object { $_ | ConvertTo-Json -Depth 40 -Compress })
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Write-R17A2aDispatcherText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R17A2aDispatcherObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 50 | ConvertFrom-Json)
}

function Test-R17A2aDispatcherHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17A2aDispatcherProperty {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17A2aDispatcherHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Get-R17A2aDispatcherPaths {
    param([string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot))

    return [pscustomobject]@{
        DispatcherContract = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_dispatcher.contract.json"
        Routes = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_dispatcher_routes.json"
        DispatchLog = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        CheckReport = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_dispatcher_check_report.json"
        UiSnapshot = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json"
        MessageContract = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_message.contract.json"
        HandoffContract = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_handoff.contract.json"
        MessagePackets = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_message_seed_packets.json"
        HandoffPackets = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_handoff_seed_packets.json"
        Registry = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry.json"
        FixtureRoot = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17A2aDispatcherGitIdentity {
    param([string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17A2aDispatcherFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17A2aDispatcherExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17A2aDispatcherClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return [pscustomobject]$status
}

function Get-R17A2aDispatcherPreservedBoundaries {
    return [pscustomobject]@{
        r13 = [pscustomobject]@{ status = "failed/partial"; active_through = "R13-018"; closed = $false }
        r14 = [pscustomobject]@{ status = "accepted_with_caveats"; active_through = "R14-006"; caveats_removed = $false }
        r15 = [pscustomobject]@{ status = "accepted_with_caveats_by_external_audit"; active_through = "R15-009"; caveats_removed = $false }
        r16 = [pscustomobject]@{ status = "complete_bounded_foundation_scope"; active_through = "R16-026"; overclaimed = $false }
        r17 = [pscustomobject]@{ status = "active"; active_through = "R17-021"; planned_only_from = "R17-022"; planned_only_through = "R17-028" }
    }
}

function Get-R17A2aDispatcherNonClaims {
    return @(
        "R17-021 creates a bounded A2A dispatcher foundation over committed R17-020 seed packets only",
        "R17-021 validates deterministic seed-packet route candidates only",
        "R17-021 writes not-executed dispatch-result and check artifacts only",
        "R17-021 does not implement live A2A runtime",
        "R17-021 does not send A2A messages",
        "R17-021 does not invoke live agents",
        "R17-021 does not invoke live Orchestrator runtime",
        "R17-021 does not invoke adapter runtime",
        "R17-021 does not perform actual tool calls",
        "R17-021 does not call external APIs",
        "R17-021 does not mutate the board",
        "R17-021 does not create runtime cards",
        "R17-021 does not implement autonomous agents",
        "R17-021 does not implement product runtime",
        "R17-021 does not produce real Dev output",
        "R17-021 does not produce real QA result",
        "R17-021 does not produce a real audit verdict",
        "R17-021 does not claim external audit acceptance",
        "R17-021 does not claim main merge",
        "R17-021 does not close R13",
        "R17-021 does not remove R14 caveats",
        "R17-021 does not remove R15 caveats",
        "R17-021 does not solve Codex compaction",
        "R17-021 does not solve Codex reliability",
        "R17-022 through R17-028 remain planned only"
    )
}

function Get-R17A2aDispatcherRejectedClaims {
    return @(
        "live_A2A_runtime",
        "live_A2A_dispatcher_runtime",
        "A2A_messages_sent",
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
        "future_R17_022_plus_completion",
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

function Get-R17A2aDispatcherDependencyRefs {
    return [pscustomobject]@{
        r17_authority_ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
        kanban_ref = "execution/KANBAN.md"
        message_contract_ref = "contracts/a2a/r17_a2a_message.contract.json"
        handoff_contract_ref = "contracts/a2a/r17_a2a_handoff.contract.json"
        message_seed_packet_ref = "state/a2a/r17_a2a_message_seed_packets.json"
        handoff_seed_packet_ref = "state/a2a/r17_a2a_handoff_seed_packets.json"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        memory_loader_report_ref = "state/context/r17_memory_artifact_loader_report.json"
        memory_loaded_refs_log_ref = "state/context/r17_memory_loaded_refs_log.json"
        agent_invocation_log_contract_ref = "contracts/runtime/r17_agent_invocation_log.contract.json"
        agent_invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        tool_adapter_contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        codex_executor_adapter_contract_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
        qa_test_agent_adapter_contract_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
        evidence_auditor_api_adapter_contract_ref = "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
        tool_call_ledger_contract_ref = "contracts/runtime/r17_tool_call_ledger.contract.json"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        board_event_contract_ref = "contracts/board/r17_board_event.contract.json"
        board_state_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"
        board_event_log_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl"
        orchestration_contract_ref = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"
        orchestration_transition_report_ref = "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    }
}

function Get-R17A2aDispatcherEvidenceRefs {
    return @(
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "state/a2a/r17_a2a_dispatcher_routes.json",
        "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl",
        "state/a2a/r17_a2a_dispatcher_check_report.json",
        "state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json",
        "tools/R17A2aDispatcher.psm1",
        "tools/new_r17_a2a_dispatcher.ps1",
        "tools/validate_r17_a2a_dispatcher.ps1",
        "tests/test_r17_a2a_dispatcher.ps1",
        "tests/fixtures/r17_a2a_dispatcher/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_021_a2a_dispatcher/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_021_a2a_dispatcher/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_021_a2a_dispatcher/validation_manifest.md"
    )
}

function Get-R17A2aDispatcherAuthorityRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "state/agents/r17_agent_registry.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "contracts/tools/r17_tool_adapter.contract.json",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/context/r17_memory_artifact_loader_report.json"
    )
}

function New-R17A2aDispatcherContract {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_a2a_dispatcher_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-021-a2a-dispatcher-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-022"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "bounded_a2a_dispatcher_foundation_only_seed_packet_validation_not_runtime"
        bounded_dispatcher_foundation_created = $true
        product_or_runtime_dispatcher = $false
        purpose = "Validate committed R17-020 A2A message and handoff seed packets into deterministic not-dispatched route records while preserving fail-closed runtime boundaries."
        required_dispatch_record_fields = $script:RequiredDispatchRecordFields
        allowed_route_statuses = $script:AllowedRouteStatuses
        allowed_dispatch_decisions = $script:AllowedDispatchDecisions
        allowed_message_types = $script:AllowedMessageTypes
        allowed_next_actions = $script:AllowedNextActions
        required_explicit_false_fields = $script:ExplicitFalseFields
        route_validation_policy = [pscustomobject][ordered]@{
            consume_committed_seed_packets_only = $true
            message_type_must_match_r17_020_contract = $true
            from_agent_id_must_exist_in_registry = $true
            to_agent_id_must_exist_in_registry = $true
            handoff_message_type_must_be_allowed = $true
            handoff_required_refs_must_be_exact_and_present = $true
            wildcard_refs_allowed = $false
            local_backups_refs_allowed = $false
            broad_repo_scan_output_allowed = $false
            full_source_file_content_embedding_allowed = $false
        }
        runtime_policy = [pscustomobject][ordered]@{
            live_a2a_runtime_allowed = $false
            live_message_sending_allowed = $false
            live_agent_invocation_allowed = $false
            live_orchestrator_runtime_allowed = $false
            adapter_runtime_allowed = $false
            actual_tool_calls_allowed = $false
            external_api_calls_allowed = $false
            board_mutation_allowed = $false
            runtime_card_creation_allowed = $false
            product_runtime_allowed = $false
        }
        dependency_refs = Get-R17A2aDispatcherDependencyRefs
        implementation_boundaries = Get-R17A2aDispatcherFalseFlags
        explicit_false_fields = Get-R17A2aDispatcherExplicitFalseMap
        claim_status = Get-R17A2aDispatcherClaimStatus
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
        preserved_boundaries = Get-R17A2aDispatcherPreservedBoundaries
    }
}

function Get-R17A2aDispatcherAgentIdMap {
    param([Parameter(Mandatory = $true)][object]$Registry)

    $map = @{}
    foreach ($agentId in @($Registry.required_agent_ids)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$agentId)) {
            $map[[string]$agentId] = $true
        }
    }
    foreach ($agent in @($Registry.agents)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$agent.agent_id)) {
            $map[[string]$agent.agent_id] = $true
        }
    }
    return $map
}

function Get-R17A2aDispatcherHandoffIdFromRef {
    param([Parameter(Mandatory = $true)][string]$Ref)

    if ([string]::IsNullOrWhiteSpace($Ref) -or $Ref -notmatch '#') {
        throw "handoff_ref must include a seed handoff fragment."
    }
    return ($Ref -split '#', 2)[1]
}

function Assert-R17A2aDispatcherRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17A2aDispatcherHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17A2aDispatcherContains {
    param(
        [Parameter(Mandatory = $true)][object[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $stringValues = @($Values | ForEach-Object { [string]$_ })
    foreach ($required in $Required) {
        if ($stringValues -notcontains $required) {
            throw "$Context must include '$required'."
        }
    }
}

function Assert-R17A2aDispatcherFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        $value = Get-R17A2aDispatcherProperty -Object $Object -Name $field -Context $Context
        if ($value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Assert-R17A2aDispatcherSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
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
        $resolved = Resolve-R17A2aDispatcherPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Assert-R17A2aDispatcherRefArray {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [switch]$SkipRefExistence,
        [switch]$AllowPlaceholder
    )

    if (@($Values).Count -lt 1) { throw "$Context must not be empty." }
    foreach ($ref in @($Values)) {
        Assert-R17A2aDispatcherSafeRefPath -Path ([string]$ref) -Context $Context -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder:$AllowPlaceholder
    }
}

function Assert-R17A2aDispatcherNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $json = ($Value | ConvertTo-Json -Depth 60 -Compress)
    if ($json -match '(?i)Get-ChildItem\s+-Recurse|git\s+ls-files|rg\s+--files|repo-wide file list|broad repo scan') {
        throw "$Context contains broad repo scan output."
    }
    if ($json -match '(?i)Set-StrictMode\s+-Version\s+Latest|function\s+[A-Za-z0-9_-]+\s*\{|full source file contents') {
        throw "$Context contains embedded full source file contents."
    }
    if ($json -match '(?i)\bR17-(0(?:2[2-8])|[3-9][0-9]|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exercised|working|available|ships|claimed)\b') {
        throw "$Context contains future R17-022+ completion claim."
    }
}

function Assert-R17A2aDispatcherSeedMessage {
    param(
        [Parameter(Mandatory = $true)][object]$Message,
        [Parameter(Mandatory = $true)][hashtable]$AgentMap,
        [Parameter(Mandatory = $true)][object]$MessageContract,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [switch]$SkipRefExistence
    )

    foreach ($field in @("message_id", "source_task", "card_id", "message_type", "from_agent_id", "to_agent_id", "correlation_id", "handoff_ref", "input_packet_ref", "output_packet_ref", "memory_packet_ref", "invocation_ref", "tool_call_ledger_ref", "board_event_ref", "evidence_refs", "authority_refs", "runtime_flags", "non_claims", "rejected_claims")) {
        if (-not (Test-R17A2aDispatcherHasProperty -Object $Message -Name $field)) {
            throw "message missing required field '$field'."
        }
    }
    if ([string]$Message.source_task -ne $script:SeedSourceTask) { throw "message $($Message.message_id) source_task must be R17-020." }
    if ([string]::IsNullOrWhiteSpace([string]$Message.card_id)) { throw "message $($Message.message_id) missing card_id." }
    if ([string]::IsNullOrWhiteSpace([string]$Message.correlation_id)) { throw "message $($Message.message_id) missing correlation_id." }
    if (@($MessageContract.allowed_message_types) -notcontains [string]$Message.message_type) { throw "message $($Message.message_id) unsupported message_type '$($Message.message_type)'." }
    if ($script:AllowedMessageTypes -notcontains [string]$Message.message_type) { throw "message $($Message.message_id) unsupported message_type '$($Message.message_type)'." }
    if (-not $AgentMap.ContainsKey([string]$Message.from_agent_id)) { throw "message $($Message.message_id) unknown from_agent_id '$($Message.from_agent_id)'." }
    if (-not $AgentMap.ContainsKey([string]$Message.to_agent_id)) { throw "message $($Message.message_id) unknown to_agent_id '$($Message.to_agent_id)'." }

    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.handoff_ref) -Context "message $($Message.message_id) handoff_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.input_packet_ref) -Context "message $($Message.message_id) input_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.output_packet_ref) -Context "message $($Message.message_id) output_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.memory_packet_ref) -Context "message $($Message.message_id) memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.invocation_ref) -Context "message $($Message.message_id) invocation_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.tool_call_ledger_ref) -Context "message $($Message.message_id) tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Message.board_event_ref) -Context "message $($Message.message_id) board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Message.evidence_refs) -Context "message $($Message.message_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherRefArray -Values @($Message.authority_refs) -Context "message $($Message.message_id) authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherFalseFields -Object $Message.runtime_flags -FieldNames @("a2a_runtime_implemented", "a2a_message_sent", "live_agent_runtime_invoked", "adapter_runtime_invoked", "actual_tool_call_performed", "external_api_call_performed", "board_mutation_performed", "product_runtime_executed", "real_audit_verdict", "main_merge_claimed") -Context "message $($Message.message_id) runtime_flags"
    Assert-R17A2aDispatcherNoForbiddenContent -Value $Message -Context "message $($Message.message_id)"
}

function Assert-R17A2aDispatcherSeedHandoff {
    param(
        [Parameter(Mandatory = $true)][object]$Handoff,
        [Parameter(Mandatory = $true)][hashtable]$AgentMap,
        [Parameter(Mandatory = $true)][object]$HandoffContract,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [switch]$SkipRefExistence
    )

    foreach ($field in @("handoff_id", "source_task", "card_id", "source_message_ref", "from_agent_id", "to_agent_id", "allowed_message_types", "allowed_next_actions", "required_input_refs", "required_output_refs", "authority_refs", "memory_packet_ref", "evidence_refs", "board_event_ref", "tool_call_ledger_ref", "runtime_flags", "non_claims", "rejected_claims")) {
        if (-not (Test-R17A2aDispatcherHasProperty -Object $Handoff -Name $field)) {
            throw "handoff missing required field '$field'."
        }
    }
    if ([string]$Handoff.source_task -ne $script:SeedSourceTask) { throw "handoff $($Handoff.handoff_id) source_task must be R17-020." }
    if ([string]::IsNullOrWhiteSpace([string]$Handoff.card_id)) { throw "handoff $($Handoff.handoff_id) missing card_id." }
    if (-not $AgentMap.ContainsKey([string]$Handoff.from_agent_id)) { throw "handoff $($Handoff.handoff_id) unknown from_agent_id '$($Handoff.from_agent_id)'." }
    if (-not $AgentMap.ContainsKey([string]$Handoff.to_agent_id)) { throw "handoff $($Handoff.handoff_id) unknown to_agent_id '$($Handoff.to_agent_id)'." }
    foreach ($messageType in @($Handoff.allowed_message_types)) {
        if (@($HandoffContract.allowed_message_types) -notcontains [string]$messageType) { throw "handoff $($Handoff.handoff_id) unsupported allowed_message_type '$messageType'." }
    }
    foreach ($nextAction in @($Handoff.allowed_next_actions)) {
        if ($script:AllowedNextActions -notcontains [string]$nextAction) { throw "handoff $($Handoff.handoff_id) unsupported allowed_next_action '$nextAction'." }
    }
    if (@($Handoff.allowed_message_types).Count -lt 1) { throw "handoff $($Handoff.handoff_id) allowed_message_types must not be empty." }
    if (@($Handoff.allowed_next_actions).Count -lt 1) { throw "handoff $($Handoff.handoff_id) allowed_next_actions must not be empty." }
    if (@($Handoff.required_input_refs).Count -lt 1) { throw "handoff $($Handoff.handoff_id) required_input_refs must not be empty." }
    if (@($Handoff.required_output_refs).Count -lt 1) { throw "handoff $($Handoff.handoff_id) required_output_refs must not be empty." }

    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Handoff.source_message_ref) -Context "handoff $($Handoff.handoff_id) source_message_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Handoff.memory_packet_ref) -Context "handoff $($Handoff.handoff_id) memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Handoff.board_event_ref) -Context "handoff $($Handoff.handoff_id) board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Handoff.tool_call_ledger_ref) -Context "handoff $($Handoff.handoff_id) tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherRefArray -Values @($Handoff.required_input_refs) -Context "handoff $($Handoff.handoff_id) required_input_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Handoff.required_output_refs) -Context "handoff $($Handoff.handoff_id) required_output_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Handoff.evidence_refs) -Context "handoff $($Handoff.handoff_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherRefArray -Values @($Handoff.authority_refs) -Context "handoff $($Handoff.handoff_id) authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherFalseFields -Object $Handoff.runtime_flags -FieldNames @("a2a_runtime_implemented", "a2a_message_sent", "live_agent_runtime_invoked", "adapter_runtime_invoked", "actual_tool_call_performed", "external_api_call_performed", "board_mutation_performed", "product_runtime_executed", "real_audit_verdict", "main_merge_claimed") -Context "handoff $($Handoff.handoff_id) runtime_flags"
    Assert-R17A2aDispatcherNoForbiddenContent -Value $Handoff -Context "handoff $($Handoff.handoff_id)"
}

function New-R17A2aDispatcherRouteRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Message,
        [Parameter(Mandatory = $true)][hashtable]$HandoffMap,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $handoffId = Get-R17A2aDispatcherHandoffIdFromRef -Ref ([string]$Message.handoff_ref)
    if (-not $HandoffMap.ContainsKey($handoffId)) {
        throw "message $($Message.message_id) references unauthorized handoff '$handoffId'."
    }
    $handoff = $HandoffMap[$handoffId]
    if (@($handoff.allowed_message_types) -notcontains [string]$Message.message_type) {
        throw "message $($Message.message_id) message_type '$($Message.message_type)' is not allowed by handoff $handoffId."
    }

    $falseFlags = Get-R17A2aDispatcherFalseFlags
    $explicitFalse = Get-R17A2aDispatcherExplicitFalseMap
    $messageRef = "state/a2a/r17_a2a_message_seed_packets.json#$($Message.message_id)"
    $record = [ordered]@{
        artifact_type = "r17_a2a_dispatch_record"
        contract_version = "v1"
        dispatch_record_id = ([string]$Message.message_id).Replace("r17_020_seed_message_", "r17_021_dispatch_candidate_")
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = [string]$Message.card_id
        correlation_id = [string]$Message.correlation_id
        message_ref = $messageRef
        handoff_ref = [string]$Message.handoff_ref
        from_agent_id = [string]$Message.from_agent_id
        to_agent_id = [string]$Message.to_agent_id
        message_type = [string]$Message.message_type
        handoff_from_agent_id = [string]$handoff.from_agent_id
        handoff_to_agent_id = [string]$handoff.to_agent_id
        route_status = "valid_seed_route_not_dispatched"
        dispatch_decision = "not_dispatched_foundation_validation_only"
        dispatch_reason = "validated_committed_r17_020_seed_packet_route_candidate_without_sending_or_executing"
        input_packet_ref = [string]$Message.input_packet_ref
        output_packet_ref = [string]$Message.output_packet_ref
        memory_packet_ref = [string]$Message.memory_packet_ref
        handoff_memory_packet_ref = [string]$handoff.memory_packet_ref
        invocation_ref = [string]$Message.invocation_ref
        tool_call_ledger_ref = [string]$Message.tool_call_ledger_ref
        board_event_ref = [string]$Message.board_event_ref
        allowed_next_actions = @($handoff.allowed_next_actions)
        required_input_refs = @($handoff.required_input_refs)
        required_output_refs = @($handoff.required_output_refs)
        evidence_refs = Get-R17A2aDispatcherEvidenceRefs
        authority_refs = Get-R17A2aDispatcherAuthorityRefs
        validation_refs = @(
            "contracts/a2a/r17_a2a_dispatcher.contract.json",
            "contracts/a2a/r17_a2a_message.contract.json",
            "contracts/a2a/r17_a2a_handoff.contract.json",
            "state/agents/r17_agent_registry.json",
            "state/a2a/r17_a2a_dispatcher_check_report.json"
        )
        execution_mode = "validation_only_not_dispatched"
        runtime_flags = $falseFlags
        claim_status = Get-R17A2aDispatcherClaimStatus
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
    }
    foreach ($field in $script:ExplicitFalseFields) { $record[$field] = $explicitFalse.PSObject.Properties[$field].Value }
    return [pscustomobject]$record
}

function New-R17A2aDispatcherObjectSet {
    param(
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [object]$GitIdentity = (Get-R17A2aDispatcherGitIdentity -RepositoryRoot $RepositoryRoot)
    )

    $paths = Get-R17A2aDispatcherPaths -RepositoryRoot $RepositoryRoot
    $messageContract = Read-R17A2aDispatcherJson -Path $paths.MessageContract
    $handoffContract = Read-R17A2aDispatcherJson -Path $paths.HandoffContract
    $messagePackets = Read-R17A2aDispatcherJson -Path $paths.MessagePackets
    $handoffPackets = Read-R17A2aDispatcherJson -Path $paths.HandoffPackets
    $registry = Read-R17A2aDispatcherJson -Path $paths.Registry
    $agentMap = Get-R17A2aDispatcherAgentIdMap -Registry $registry

    $handoffMap = @{}
    foreach ($handoff in @($handoffPackets.handoffs)) {
        Assert-R17A2aDispatcherSeedHandoff -Handoff $handoff -AgentMap $agentMap -HandoffContract $handoffContract -RepositoryRoot $RepositoryRoot
        $handoffMap[[string]$handoff.handoff_id] = $handoff
    }

    $routes = @()
    foreach ($message in @($messagePackets.messages)) {
        Assert-R17A2aDispatcherSeedMessage -Message $message -AgentMap $agentMap -MessageContract $messageContract -RepositoryRoot $RepositoryRoot
        $routes += (New-R17A2aDispatcherRouteRecord -Message $message -HandoffMap $handoffMap -GitIdentity $GitIdentity)
    }

    $contract = New-R17A2aDispatcherContract
    $routeStatusCounts = [ordered]@{}
    foreach ($status in $script:AllowedRouteStatuses) {
        $routeStatusCounts[$status] = @($routes | Where-Object { $_.route_status -eq $status }).Count
    }

    $routeSet = [pscustomobject][ordered]@{
        artifact_type = "r17_a2a_dispatcher_route_set"
        contract_version = "v1"
        route_set_id = "aioffice-r17-021-a2a-dispatcher-routes-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-022"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        bounded_dispatcher_foundation_created = $true
        product_or_runtime_dispatcher = $false
        contract_ref = "contracts/a2a/r17_a2a_dispatcher.contract.json"
        message_seed_packet_ref = "state/a2a/r17_a2a_message_seed_packets.json"
        handoff_seed_packet_ref = "state/a2a/r17_a2a_handoff_seed_packets.json"
        dispatch_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        route_count = $routes.Count
        valid_seed_route_count = @($routes | Where-Object { $_.route_status -eq "valid_seed_route_not_dispatched" }).Count
        blocked_route_count = @($routes | Where-Object { $_.route_status -ne "valid_seed_route_not_dispatched" }).Count
        route_status_counts = [pscustomobject]$routeStatusCounts
        allowed_route_statuses = $script:AllowedRouteStatuses
        routes = $routes
        runtime_boundaries = Get-R17A2aDispatcherFalseFlags
        explicit_false_fields = Get-R17A2aDispatcherExplicitFalseMap
        claim_status = Get-R17A2aDispatcherClaimStatus
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
    }

    $report = [pscustomobject][ordered]@{
        artifact_type = "r17_a2a_dispatcher_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-021-a2a-dispatcher-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-022"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        bounded_dispatcher_foundation_created = $true
        product_or_runtime_dispatcher = $false
        dispatcher_contract_ref = "contracts/a2a/r17_a2a_dispatcher.contract.json"
        route_set_ref = "state/a2a/r17_a2a_dispatcher_routes.json"
        dispatch_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        message_seed_packet_ref = "state/a2a/r17_a2a_message_seed_packets.json"
        handoff_seed_packet_ref = "state/a2a/r17_a2a_handoff_seed_packets.json"
        ui_snapshot_ref = "state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json"
        total_message_seed_packets = @($messagePackets.messages).Count
        total_handoff_seed_packets = @($handoffPackets.handoffs).Count
        total_dispatch_candidates = $routes.Count
        valid_seed_route_count = $routeSet.valid_seed_route_count
        blocked_route_count = $routeSet.blocked_route_count
        route_status_counts = [pscustomobject]$routeStatusCounts
        dispatch_record_ids = @($routes | ForEach-Object { $_.dispatch_record_id })
        message_types = $script:AllowedMessageTypes
        dependency_refs = Get-R17A2aDispatcherDependencyRefs
        runtime_boundary_summary = Get-R17A2aDispatcherFalseFlags
        explicit_false_fields = Get-R17A2aDispatcherExplicitFalseMap
        claim_status = Get-R17A2aDispatcherClaimStatus
        validation_summary = [pscustomobject][ordered]@{
            message_seed_packets_loaded = "passed"
            handoff_seed_packets_loaded = "passed"
            message_type_contract_validation = "passed"
            registry_agent_validation = "passed"
            handoff_permission_validation = "passed"
            allowed_next_actions_validation = "passed"
            required_ref_validation = "passed"
            evidence_authority_ref_validation = "passed"
            memory_packet_ref_validation = "passed"
            deterministic_dispatch_candidates_emitted = "passed"
            not_executed_dispatch_log_emitted = "passed"
            unsupported_message_type_rejected = "passed"
            unauthorized_handoff_rejected = "passed"
            runtime_claims_rejected = "passed"
            future_r17_022_plus_claims_rejected = "passed"
            compact_artifact_policy_preserved = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        evidence_refs = Get-R17A2aDispatcherEvidenceRefs
        preserved_boundaries = Get-R17A2aDispatcherPreservedBoundaries
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
    }

    $snapshot = [pscustomobject][ordered]@{
        artifact_type = "r17_a2a_dispatcher_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-021-a2a-dispatcher-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-022"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        bounded_dispatcher_foundation_created = $true
        product_or_runtime_dispatcher = $false
        dispatcher_contract_ref = "contracts/a2a/r17_a2a_dispatcher.contract.json"
        route_set_ref = "state/a2a/r17_a2a_dispatcher_routes.json"
        dispatch_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        check_report_ref = "state/a2a/r17_a2a_dispatcher_check_report.json"
        total_dispatch_candidates = $routes.Count
        valid_seed_route_count = $routeSet.valid_seed_route_count
        blocked_route_count = $routeSet.blocked_route_count
        visible_routes = @($routes | ForEach-Object {
                [pscustomobject][ordered]@{
                    dispatch_record_id = $_.dispatch_record_id
                    card_id = $_.card_id
                    message_type = $_.message_type
                    from_agent_id = $_.from_agent_id
                    to_agent_id = $_.to_agent_id
                    handoff_ref = $_.handoff_ref
                    route_status = $_.route_status
                    dispatch_decision = $_.dispatch_decision
                    execution_mode = $_.execution_mode
                }
            })
        runtime_boundaries = Get-R17A2aDispatcherFalseFlags
        explicit_false_fields = Get-R17A2aDispatcherExplicitFalseMap
        claim_status = Get-R17A2aDispatcherClaimStatus
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        RouteSet = $routeSet
        DispatchRecords = $routes
        Report = $report
        Snapshot = $snapshot
        MessagePackets = $messagePackets
        HandoffPackets = $handoffPackets
    }
}

function Get-R17A2aDispatcherInvalidFixtureDefinitions {
    $definitions = @(
        [pscustomobject]@{ name = "invalid_unsupported_message_type.json"; target = "message"; property = "message_type"; value = "unsupported_status_ping"; expected = @("unsupported message_type") },
        [pscustomobject]@{ name = "invalid_unknown_from_agent_id.json"; target = "message"; property = "from_agent_id"; value = "ghost_agent"; expected = @("unknown from_agent_id") },
        [pscustomobject]@{ name = "invalid_unknown_to_agent_id.json"; target = "message"; property = "to_agent_id"; value = "ghost_agent"; expected = @("unknown to_agent_id") },
        [pscustomobject]@{ name = "invalid_handoff_message_type_not_allowed.json"; target = "handoff_allowed_message_types"; property = "allowed_message_types"; value = @("clarification_request"); expected = @("not allowed by handoff") },
        [pscustomobject]@{ name = "invalid_missing_correlation_id.json"; target = "message"; property = "correlation_id"; value = ""; expected = @("missing correlation_id") },
        [pscustomobject]@{ name = "invalid_missing_card_id.json"; target = "message"; property = "card_id"; value = ""; expected = @("missing card_id") },
        [pscustomobject]@{ name = "invalid_missing_evidence_refs.json"; target = "message"; property = "evidence_refs"; value = @(); expected = @("evidence_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_authority_refs.json"; target = "message"; property = "authority_refs"; value = @(); expected = @("authority_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_required_input_refs.json"; target = "handoff"; property = "required_input_refs"; value = @(); expected = @("required_input_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_required_output_refs.json"; target = "handoff"; property = "required_output_refs"; value = @(); expected = @("required_output_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_wildcard_evidence_path.json"; target = "message_evidence_append"; property = "evidence_refs"; value = "state/a2a/*.json"; expected = @("wildcard") },
        [pscustomobject]@{ name = "invalid_local_backups_ref.json"; target = "message_authority_append"; property = "authority_refs"; value = ".local_backups/r17_a2a_dispatcher.json"; expected = @(".local_backups") },
        [pscustomobject]@{ name = "invalid_broad_repo_scan_output.json"; target = "route_non_claim_append"; property = "non_claims"; value = "rg --files repo-wide file list"; expected = @("broad repo scan") },
        [pscustomobject]@{ name = "invalid_embedded_full_source_contents.json"; target = "route_non_claim_append"; property = "non_claims"; value = "function Invoke-LiveAgent { Set-StrictMode -Version Latest }"; expected = @("embedded full source") },
        [pscustomobject]@{ name = "invalid_future_r17_022_completion_claim.json"; target = "route_non_claim_append"; property = "non_claims"; value = "R17-022 is implemented by this pass."; expected = @("future R17-022+") }
    )

    foreach ($field in $script:ExplicitFalseFields) {
        $definitions += [pscustomobject]@{
            name = "invalid_$($field)_true.json"
            target = "route"
            property = $field
            value = $true
            expected = @("field '$field' must be false")
        }
    }

    return $definitions
}

function New-R17A2aDispatcherFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $FixtureRoot -File -Filter "valid_*" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -LiteralPath $FixtureRoot -File -Filter "invalid_*.json" -ErrorAction SilentlyContinue | Remove-Item -Force

    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_dispatcher_contract.json") -Value $ObjectSet.Contract
    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_routes.json") -Value $ObjectSet.RouteSet
    Write-R17A2aDispatcherJsonLines -Path (Join-Path $FixtureRoot "valid_dispatch_log.jsonl") -Values $ObjectSet.DispatchRecords
    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot
    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_message_seed_packets.json") -Value $ObjectSet.MessagePackets
    Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot "valid_handoff_seed_packets.json") -Value $ObjectSet.HandoffPackets

    $count = 0
    foreach ($definition in Get-R17A2aDispatcherInvalidFixtureDefinitions) {
        $fixture = [pscustomobject][ordered]@{
            target = [string]$definition.target
            property = [string]$definition.property
            value = $definition.value
            expected_failure_fragments = @($definition.expected)
        }
        Write-R17A2aDispatcherJson -Path (Join-Path $FixtureRoot ([string]$definition.name)) -Value $fixture
        $count += 1
    }
    return $count
}

function New-R17A2aDispatcherProofFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProofRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $ProofRoot -Force | Out-Null

    $proof = @"
# R17-021 A2A Dispatcher Foundation Proof Review

R17-021 adds a bounded A2A dispatcher foundation only. It consumes the committed R17-020 A2A message and handoff seed packets, validates route authority deterministically, and writes not-executed dispatch candidate records plus a check report.

R17 is active through R17-021 only. R17-022 through R17-028 remain planned only.

Non-claims preserved: no live A2A runtime, no live A2A messages sent, no live agent invocation, no live Orchestrator runtime, no adapter runtime, no actual tool call, no external API call, no board mutation, no QA result, no real audit verdict, no external audit acceptance, no autonomous agents, no product runtime, and no main merge.

Generated evidence:
- contracts/a2a/r17_a2a_dispatcher.contract.json
- state/a2a/r17_a2a_dispatcher_routes.json
- state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl
- state/a2a/r17_a2a_dispatcher_check_report.json
- state/ui/r17_kanban_mvp/r17_a2a_dispatcher_snapshot.json
- tools/R17A2aDispatcher.psm1
- tools/new_r17_a2a_dispatcher.ps1
- tools/validate_r17_a2a_dispatcher.ps1
- tests/test_r17_a2a_dispatcher.ps1
- tests/fixtures/r17_a2a_dispatcher/
"@
    Write-R17A2aDispatcherText -Path (Join-Path $ProofRoot "proof_review.md") -Value $proof

    $evidenceIndex = [pscustomobject][ordered]@{
        artifact_type = "r17_a2a_dispatcher_evidence_index"
        source_task = $script:SourceTask
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = Get-R17A2aDispatcherEvidenceRefs
        non_claims = Get-R17A2aDispatcherNonClaims
        rejected_claims = Get-R17A2aDispatcherRejectedClaims
        runtime_boundaries = Get-R17A2aDispatcherFalseFlags
    }
    Write-R17A2aDispatcherJson -Path (Join-Path $ProofRoot "evidence_index.json") -Value $evidenceIndex

    $validation = @"
# R17-021 Validation Manifest

Required focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_a2a_dispatcher.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_a2a_dispatcher.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_dispatcher.ps1

Required related gates include the existing R17 A2A contract, registry, memory loader, invocation log, adapter, ledger, board/orchestration, Kanban, KPI, and status-doc validators/tests.

Boundary: generated dispatch records are validation-only and not dispatched. The foundation does not invoke agents, runtime Orchestrator, adapters, APIs, tools, QA, audit, product runtime, board mutation, or main merge.
"@
    Write-R17A2aDispatcherText -Path (Join-Path $ProofRoot "validation_manifest.md") -Value $validation
}

function New-R17A2aDispatcherArtifacts {
    param([string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot))

    $paths = Get-R17A2aDispatcherPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17A2aDispatcherObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17A2aDispatcherJson -Path $paths.DispatcherContract -Value $objectSet.Contract
    Write-R17A2aDispatcherJson -Path $paths.Routes -Value $objectSet.RouteSet
    Write-R17A2aDispatcherJsonLines -Path $paths.DispatchLog -Values $objectSet.DispatchRecords
    Write-R17A2aDispatcherJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17A2aDispatcherJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    $invalidFixtureCount = New-R17A2aDispatcherFixtureFiles -FixtureRoot $paths.FixtureRoot -ObjectSet $objectSet
    New-R17A2aDispatcherProofFiles -ProofRoot $paths.ProofRoot -ObjectSet $objectSet

    return [pscustomobject]@{
        Contract = $paths.DispatcherContract
        Routes = $paths.Routes
        DispatchLog = $paths.DispatchLog
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RouteCount = $objectSet.RouteSet.route_count
        ValidSeedRouteCount = $objectSet.RouteSet.valid_seed_route_count
        InvalidFixtureCount = $invalidFixtureCount
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17A2aDispatcherRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17A2aDispatcherRequiredFields -Object $Record -FieldNames $script:RequiredDispatchRecordFields -Context $Context
    if ([string]$Record.source_task -ne $script:SourceTask) { throw "$Context source_task must be R17-021." }
    if ([string]$Record.seed_source_task -ne $script:SeedSourceTask) { throw "$Context seed_source_task must be R17-020." }
    if ([string]::IsNullOrWhiteSpace([string]$Record.card_id)) { throw "$Context missing card_id." }
    if ([string]::IsNullOrWhiteSpace([string]$Record.correlation_id)) { throw "$Context missing correlation_id." }
    if ($script:AllowedMessageTypes -notcontains [string]$Record.message_type) { throw "$Context unsupported message_type '$($Record.message_type)'." }
    if ($script:AllowedRouteStatuses -notcontains [string]$Record.route_status) { throw "$Context route_status '$($Record.route_status)' is not allowed." }
    if ($script:AllowedDispatchDecisions -notcontains [string]$Record.dispatch_decision) { throw "$Context dispatch_decision '$($Record.dispatch_decision)' is not allowed." }
    if ([string]$Record.execution_mode -ne "validation_only_not_dispatched") { throw "$Context execution_mode must be validation_only_not_dispatched." }

    foreach ($nextAction in @($Record.allowed_next_actions)) {
        if ($script:AllowedNextActions -notcontains [string]$nextAction) { throw "$Context unsupported allowed_next_action '$nextAction'." }
    }
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.message_ref) -Context "$Context message_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.handoff_ref) -Context "$Context handoff_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.input_packet_ref) -Context "$Context input_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.output_packet_ref) -Context "$Context output_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.memory_packet_ref) -Context "$Context memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.handoff_memory_packet_ref) -Context "$Context handoff_memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.invocation_ref) -Context "$Context invocation_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.tool_call_ledger_ref) -Context "$Context tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17A2aDispatcherSafeRefPath -Path ([string]$Record.board_event_ref) -Context "$Context board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Record.required_input_refs) -Context "$Context required_input_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Record.required_output_refs) -Context "$Context required_output_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17A2aDispatcherRefArray -Values @($Record.evidence_refs) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherRefArray -Values @($Record.authority_refs) -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherRefArray -Values @($Record.validation_refs) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17A2aDispatcherFalseFields -Object $Record.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$Context runtime_flags"
    Assert-R17A2aDispatcherFalseFields -Object $Record -FieldNames $script:ExplicitFalseFields -Context $Context
    Assert-R17A2aDispatcherNoForbiddenContent -Value $Record -Context $Context
}

function Assert-R17A2aDispatcherKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-021 must not modify the runtime/static renderer."
    }
}

function Assert-R17A2aDispatcherFixtureCoverage {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $script:MinimumInvalidFixtureCount) {
        throw "fixture coverage requires at least $script:MinimumInvalidFixtureCount compact invalid fixtures."
    }
}

function Test-R17A2aDispatcherSet {
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$MessagePackets,
        [Parameter(Mandatory = $true)][object]$HandoffPackets,
        [Parameter(Mandatory = $true)][object]$RouteSet,
        [Parameter(Mandatory = $true)][object[]]$DispatchRecords,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot),
        [switch]$SkipFixtureCoverage,
        [switch]$SkipRefExistence,
        [switch]$SkipDeterministicComparison,
        [switch]$SkipKanbanJsCheck
    )

    $paths = Get-R17A2aDispatcherPaths -RepositoryRoot $RepositoryRoot
    $messageContract = Read-R17A2aDispatcherJson -Path $paths.MessageContract
    $handoffContract = Read-R17A2aDispatcherJson -Path $paths.HandoffContract
    $registry = Read-R17A2aDispatcherJson -Path $paths.Registry
    $agentMap = Get-R17A2aDispatcherAgentIdMap -Registry $registry

    Assert-R17A2aDispatcherRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "seed_source_task", "active_through_task", "planned_only_from", "planned_only_through", "required_dispatch_record_fields", "allowed_route_statuses", "allowed_message_types", "route_validation_policy", "runtime_policy", "implementation_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "dispatcher contract"
    if ($Contract.artifact_type -ne "r17_a2a_dispatcher_contract") { throw "dispatcher contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask -or $Contract.seed_source_task -ne $script:SeedSourceTask) { throw "dispatcher contract source tasks are invalid." }
    if ($Contract.active_through_task -ne "R17-021" -or $Contract.planned_only_from -ne "R17-022" -or $Contract.planned_only_through -ne "R17-028") { throw "dispatcher contract must keep R17 active through R17-021 only." }
    Assert-R17A2aDispatcherContains -Values @($Contract.required_dispatch_record_fields) -Required $script:RequiredDispatchRecordFields -Context "dispatcher contract required_dispatch_record_fields"
    Assert-R17A2aDispatcherContains -Values @($Contract.allowed_route_statuses) -Required $script:AllowedRouteStatuses -Context "dispatcher contract allowed_route_statuses"
    Assert-R17A2aDispatcherContains -Values @($Contract.allowed_message_types) -Required $script:AllowedMessageTypes -Context "dispatcher contract allowed_message_types"
    Assert-R17A2aDispatcherFalseFields -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "dispatcher contract implementation_boundaries"
    Assert-R17A2aDispatcherFalseFields -Object $Contract.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "dispatcher contract explicit_false_fields"
    Assert-R17A2aDispatcherFalseFields -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "dispatcher contract claim_status"

    $handoffMap = @{}
    foreach ($handoff in @($HandoffPackets.handoffs)) {
        Assert-R17A2aDispatcherSeedHandoff -Handoff $handoff -AgentMap $agentMap -HandoffContract $handoffContract -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        $handoffMap[[string]$handoff.handoff_id] = $handoff
    }
    $expectedRecords = @()
    foreach ($message in @($MessagePackets.messages)) {
        Assert-R17A2aDispatcherSeedMessage -Message $message -AgentMap $agentMap -MessageContract $messageContract -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        $expectedRecords += (New-R17A2aDispatcherRouteRecord -Message $message -HandoffMap $handoffMap -GitIdentity ([pscustomobject]@{ Head = "fixture_head"; Tree = "fixture_tree" }))
    }

    Assert-R17A2aDispatcherRequiredFields -Object $RouteSet -FieldNames $script:RequiredRouteSetFields -Context "route set"
    if ($RouteSet.source_task -ne $script:SourceTask -or $RouteSet.active_through_task -ne "R17-021") { throw "route set must keep R17 active through R17-021." }
    if ($RouteSet.planned_only_from -ne "R17-022" -or $RouteSet.planned_only_through -ne "R17-028") { throw "route set must keep R17-022 through R17-028 planned only." }
    if ([int]$RouteSet.route_count -ne @($RouteSet.routes).Count) { throw "route set route_count does not match routes." }
    if ([int]$RouteSet.route_count -ne @($DispatchRecords).Count) { throw "dispatch log record count does not match route set." }
    if ([int]$RouteSet.route_count -ne @($MessagePackets.messages).Count) { throw "route set must include one candidate per R17-020 seed message." }
    if ([int]$RouteSet.valid_seed_route_count -ne @($RouteSet.routes | Where-Object { $_.route_status -eq "valid_seed_route_not_dispatched" }).Count) { throw "route set valid_seed_route_count is invalid." }
    if ([int]$RouteSet.blocked_route_count -ne @($RouteSet.routes | Where-Object { $_.route_status -ne "valid_seed_route_not_dispatched" }).Count) { throw "route set blocked_route_count is invalid." }
    Assert-R17A2aDispatcherFalseFields -Object $RouteSet.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "route set runtime_boundaries"
    Assert-R17A2aDispatcherFalseFields -Object $RouteSet.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "route set explicit_false_fields"
    Assert-R17A2aDispatcherFalseFields -Object $RouteSet.claim_status -FieldNames $script:ClaimStatusFields -Context "route set claim_status"

    $routeIds = @{}
    foreach ($route in @($RouteSet.routes)) {
        Assert-R17A2aDispatcherRecord -Record $route -Context "route $($route.dispatch_record_id)" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        if ($routeIds.ContainsKey([string]$route.dispatch_record_id)) { throw "duplicate dispatch_record_id '$($route.dispatch_record_id)'." }
        $routeIds[[string]$route.dispatch_record_id] = $true
    }
    foreach ($record in @($DispatchRecords)) {
        Assert-R17A2aDispatcherRecord -Record $record -Context "dispatch log $($record.dispatch_record_id)" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        if (-not $routeIds.ContainsKey([string]$record.dispatch_record_id)) { throw "dispatch log contains a record not present in route set." }
    }

    if (-not $SkipDeterministicComparison) {
        $routeComparable = @($RouteSet.routes | ForEach-Object {
                $copy = Copy-R17A2aDispatcherObject -Value $_
                $copy.generated_from_head = "fixture_head"
                $copy.generated_from_tree = "fixture_tree"
                $copy
            }) | ConvertTo-Json -Depth 50 -Compress
        $expectedComparable = @($expectedRecords) | ConvertTo-Json -Depth 50 -Compress
        if ($routeComparable -ne $expectedComparable) {
            throw "route set does not match deterministic seed packet generation output."
        }
    }

    Assert-R17A2aDispatcherRequiredFields -Object $Report -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "dispatcher_contract_ref", "route_set_ref", "dispatch_log_ref", "total_message_seed_packets", "total_handoff_seed_packets", "total_dispatch_candidates", "valid_seed_route_count", "blocked_route_count", "runtime_boundary_summary", "explicit_false_fields", "claim_status", "validation_summary", "aggregate_verdict", "non_claims", "rejected_claims") -Context "check report"
    if ($Report.source_task -ne $script:SourceTask -or $Report.active_through_task -ne "R17-021") { throw "check report must keep R17 active through R17-021." }
    if ($Report.planned_only_from -ne "R17-022" -or $Report.planned_only_through -ne "R17-028") { throw "check report must keep R17-022 through R17-028 planned only." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    if ([int]$Report.total_dispatch_candidates -ne [int]$RouteSet.route_count) { throw "check report dispatch candidate count does not match route set." }
    Assert-R17A2aDispatcherFalseFields -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17A2aDispatcherFalseFields -Object $Report.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "check report explicit_false_fields"
    Assert-R17A2aDispatcherFalseFields -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    if ([bool]$Report.full_source_file_contents_embedded -ne $false -or [bool]$Report.broad_repo_scan_output_included -ne $false -or [bool]$Report.broad_repo_scan_used -ne $false) {
        throw "check report must preserve generated-artifact compactness guards."
    }
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    Assert-R17A2aDispatcherRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "dispatcher_contract_ref", "route_set_ref", "dispatch_log_ref", "check_report_ref", "total_dispatch_candidates", "valid_seed_route_count", "blocked_route_count", "visible_routes", "runtime_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.source_task -ne $script:SourceTask -or $Snapshot.active_through_task -ne "R17-021") { throw "UI snapshot must keep R17 active through R17-021." }
    if ($Snapshot.planned_only_from -ne "R17-022" -or $Snapshot.planned_only_through -ne "R17-028") { throw "UI snapshot must keep R17-022 through R17-028 planned only." }
    if ([int]$Snapshot.total_dispatch_candidates -ne [int]$RouteSet.route_count) { throw "UI snapshot dispatch candidate count does not match route set." }
    Assert-R17A2aDispatcherFalseFields -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17A2aDispatcherFalseFields -Object $Snapshot.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "UI snapshot explicit_false_fields"
    Assert-R17A2aDispatcherFalseFields -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"

    foreach ($object in @($Contract, $RouteSet, $Report, $Snapshot)) {
        Assert-R17A2aDispatcherNoForbiddenContent -Value $object -Context "R17-021 dispatcher artifact set"
    }
    if (-not $SkipFixtureCoverage) {
        Assert-R17A2aDispatcherFixtureCoverage -FixtureRoot (Get-R17A2aDispatcherPaths -RepositoryRoot $RepositoryRoot).FixtureRoot
    }
    if (-not $SkipKanbanJsCheck) {
        Assert-R17A2aDispatcherKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        RouteCount = [int]$RouteSet.route_count
        ValidSeedRouteCount = [int]$RouteSet.valid_seed_route_count
        BlockedRouteCount = [int]$RouteSet.blocked_route_count
        A2aRuntimeImplemented = $false
        A2aDispatcherRuntimeImplemented = $false
        A2aMessageSent = $false
        LiveAgentRuntimeInvoked = $false
        LiveOrchestratorRuntimeInvoked = $false
        AdapterRuntimeInvoked = $false
        ActualToolCallPerformed = $false
        ExternalApiCallPerformed = $false
        BoardMutationPerformed = $false
        QaResultClaimed = $false
        RealAuditVerdict = $false
        MainMergeClaimed = $false
    }
}

function Test-R17A2aDispatcher {
    param([string]$RepositoryRoot = (Get-R17A2aDispatcherRepositoryRoot))

    $paths = Get-R17A2aDispatcherPaths -RepositoryRoot $RepositoryRoot
    return Test-R17A2aDispatcherSet `
        -Contract (Read-R17A2aDispatcherJson -Path $paths.DispatcherContract) `
        -MessagePackets (Read-R17A2aDispatcherJson -Path $paths.MessagePackets) `
        -HandoffPackets (Read-R17A2aDispatcherJson -Path $paths.HandoffPackets) `
        -RouteSet (Read-R17A2aDispatcherJson -Path $paths.Routes) `
        -DispatchRecords (Read-R17A2aDispatcherJsonLines -Path $paths.DispatchLog) `
        -Report (Read-R17A2aDispatcherJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17A2aDispatcherJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17A2aDispatcherObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17A2aDispatcherProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    if (-not (Test-R17A2aDispatcherHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}
