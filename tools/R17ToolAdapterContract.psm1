Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-015"
$script:AggregateVerdict = "generated_r17_tool_adapter_contract_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_015_tool_adapter_contract"
$script:FixtureRoot = "tests/fixtures/r17_tool_adapter_contract"
$script:MinimumInvalidFixtureCount = 50

$script:KnownAdapterTypes = @(
    "developer_codex_executor_adapter",
    "qa_test_agent_adapter",
    "evidence_auditor_api_adapter"
)

$script:SeedAdapterIds = @(
    "developer_codex_executor_adapter_future",
    "qa_test_agent_adapter_future",
    "evidence_auditor_api_adapter_future"
)

$script:KnownAgentIds = @(
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

$script:AllowedToolBoundaries = @(
    "adapter_contract_validation_only",
    "future_codex_executor_packet_contract_only",
    "future_qa_test_packet_contract_only",
    "future_evidence_auditor_api_packet_contract_only"
)

$script:RequiredProfileFields = @(
    "adapter_id",
    "adapter_type",
    "source_task",
    "card_id",
    "requested_by_agent_id",
    "target_agent_id",
    "invocation_ref",
    "input_packet_ref",
    "output_packet_ref",
    "tool_call_ref",
    "board_event_ref",
    "evidence_refs",
    "allowed_tool_boundary",
    "required_authority_refs",
    "secret_policy",
    "cost_policy",
    "timeout_policy",
    "retry_policy",
    "status",
    "error_ref",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReportFields = @(
    "contract_ref",
    "seed_profile_ref",
    "known_adapter_types",
    "future_adapter_sequence",
    "dependency_refs",
    "invocation_log_ref",
    "agent_registry_ref",
    "memory_loader_ref",
    "runtime_boundary_summary",
    "validation_summary",
    "aggregate_verdict",
    "non_claims",
    "rejected_claims"
)

$script:RuntimeFalseFields = @(
    "adapter_runtime_implemented",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "codex_executor_invoked",
    "qa_test_agent_invoked",
    "evidence_auditor_api_invoked",
    "a2a_message_sent",
    "agent_invocation_performed",
    "board_mutation_performed",
    "product_runtime_executed",
    "production_runtime_executed",
    "runtime_card_creation_performed",
    "live_orchestrator_runtime_invoked",
    "autonomous_agent_executed",
    "tool_call_ledger_runtime_implemented",
    "executable_handoff_performed",
    "executable_transition_performed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "external_integration_performed",
    "full_source_file_contents_embedded",
    "broad_repo_scan_output_included",
    "broad_repo_scan_used"
)

$script:ClaimStatusFields = @(
    "live_board_mutation_claimed",
    "runtime_card_creation_claimed",
    "live_orchestrator_runtime_claimed",
    "autonomous_agent_claimed",
    "executable_handoff_claimed",
    "executable_transition_claimed",
    "runtime_memory_engine_claimed",
    "vector_retrieval_claimed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r17_016_plus_implementation_claimed",
    "external_integration_claimed"
)

function Get-R17ToolAdapterContractRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17ToolAdapterContractPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17ToolAdapterContractJson {
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

function Write-R17ToolAdapterContractJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value ($Value | ConvertTo-Json -Depth 100) -Encoding UTF8
}

function Write-R17ToolAdapterContractText {
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

function Copy-R17ToolAdapterContractObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17ToolAdapterContractPaths {
    param([string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/tools/r17_tool_adapter.contract.json"
        SeedProfiles = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_tool_adapter_seed_profiles.json"
        CheckReport = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_tool_adapter_contract_check_report.json"
        UiSnapshot = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json"
        FixtureRoot = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        InvocationLog = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_agent_invocation_log.jsonl"
        AgentRegistry = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry.json"
        MemoryLoader = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r17_memory_artifact_loader_report.json"
        UiFiles = @(
            (Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md"),
            (Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/kanban.js")
        )
    }
}

function Get-R17ToolAdapterContractGitIdentity {
    param([string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17ToolAdapterContractNonClaims {
    return @(
        "R17-015 defines the common tool adapter contract foundation only",
        "R17-015 creates disabled seed adapter profiles only",
        "R17-015 does not implement the Developer/Codex executor adapter",
        "R17-015 does not implement the QA/Test Agent adapter",
        "R17-015 does not implement the Evidence Auditor API adapter",
        "R17-015 does not execute tool calls",
        "R17-015 does not invoke Codex",
        "R17-015 does not invoke QA/Test Agent",
        "R17-015 does not invoke Evidence Auditor API",
        "R17-015 does not call external APIs",
        "R17-015 does not implement adapter runtime",
        "R17-015 does not implement tool-call ledger runtime",
        "R17-015 does not implement A2A runtime",
        "R17-015 does not send A2A messages",
        "R17-015 does not invoke agents",
        "R17-015 does not implement live agent runtime",
        "R17-015 does not implement live Orchestrator runtime",
        "R17-015 does not mutate the board live",
        "R17-015 does not create runtime cards",
        "R17-015 does not implement autonomous agents",
        "R17-015 does not implement runtime memory engine",
        "R17-015 does not implement vector retrieval",
        "R17-015 does not implement executable handoffs",
        "R17-015 does not implement executable transitions",
        "R17-015 does not implement product runtime",
        "R17-015 does not implement production runtime",
        "R17-015 does not produce real Dev output",
        "R17-015 does not produce real QA result",
        "R17-015 does not produce real audit verdict",
        "R17-015 does not claim external audit acceptance",
        "R17-015 does not claim main merge",
        "R17-015 does not close R13",
        "R17-015 does not remove R14 caveats",
        "R17-015 does not remove R15 caveats",
        "R17-015 does not solve Codex compaction",
        "R17-015 does not solve Codex reliability"
    )
}

function Get-R17ToolAdapterContractRejectedClaims {
    return @(
        "live_board_mutation",
        "runtime_card_creation",
        "live_agent_runtime",
        "live_Orchestrator_runtime",
        "A2A_runtime",
        "A2A_messages_sent",
        "autonomous_agents",
        "adapter_runtime",
        "tool_call_runtime",
        "external_API_calls",
        "Codex_executor_invocation",
        "QA_Test_Agent_invocation",
        "Evidence_Auditor_API_invocation",
        "runtime_memory_engine",
        "vector_retrieval_runtime",
        "broad_repo_scan_output",
        "generated_artifact_embedding_full_source_file_contents",
        "executable_handoffs",
        "executable_transitions",
        "external_integrations",
        "external_audit_acceptance",
        "main_merge",
        "production_runtime",
        "product_runtime",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "R17_016_or_later_implementation"
    )
}

function Get-R17ToolAdapterContractFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return $flags
}

function Get-R17ToolAdapterContractClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return $status
}

function Get-R17ToolAdapterContractPreservedBoundaries {
    return [ordered]@{
        r13 = [ordered]@{ status = "failed/partial"; active_through = "R13-018"; closed = $false }
        r14 = [ordered]@{ status = "accepted_with_caveats"; through = "R14-006"; caveats_removed = $false }
        r15 = [ordered]@{ status = "accepted_with_caveats"; through = "R15-009"; caveats_removed = $false }
        r16 = [ordered]@{
            status = "complete_bounded_foundation_scope"
            through = "R16-026"
            external_audit_acceptance_claimed = $false
            main_merge_completed = $false
            product_runtime_implemented = $false
            production_runtime_implemented = $false
            runtime_memory_engine_implemented = $false
            vector_retrieval_implemented = $false
            a2a_runtime_implemented = $false
            autonomous_agents_implemented = $false
            executable_handoffs_implemented = $false
            executable_transitions_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
    }
}

function Assert-R17ToolAdapterContractSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [string]$Context = "ref",
        [switch]$AllowSeedPlaceholder,
        [switch]$AllowNone,
        [switch]$RequireExistingPath,
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot)
    )

    if ($AllowSeedPlaceholder -and $Path -eq "not_implemented_seed") { return }
    if ($AllowNone -and $Path -eq "none") { return }
    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context path must not be empty." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context path must be repo-relative." }
    if ($Path -match '(^|/)\.\.(/|$)' -or $Path -match '\\') { throw "$Context path must be normalized repo-relative path." }
    if ($Path -match '[\*\?\[\]]') { throw "$Context path must not contain wildcard characters." }
    if ($Path -match '^(?i:https?://|file://)') { throw "$Context path must not be a URL." }
    if ($Path -match '^\.local_backups/') { throw "$Context path must not point at .local_backups." }
    if ($Path -match '(?i)(chat_history|chat-transcript|raw_chat|transcript)') { throw "$Context path must not use raw chat history as canonical evidence." }

    if ($RequireExistingPath) {
        $pathOnly = ($Path -split '#', 2)[0]
        $resolved = Resolve-R17ToolAdapterContractPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Test-R17ToolAdapterContractHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Assert-R17ToolAdapterContractRequiredFields {
    param(
        [object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [string]$Context = "object"
    )

    if ($null -eq $Object) { throw "$Context is missing." }
    foreach ($field in $FieldNames) {
        if ($Object.PSObject.Properties.Name -notcontains $field) {
            throw "$Context is missing required field '$field'."
        }
    }
}

function Assert-R17ToolAdapterContractContains {
    param(
        [object[]]$Values,
        [string[]]$Required,
        [string]$Context
    )

    $strings = @($Values | ForEach-Object { [string]$_ })
    foreach ($requiredValue in $Required) {
        if ($strings -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-R17ToolAdapterContractFalseFlags {
    param(
        [object]$Object,
        [string[]]$FieldNames,
        [string]$Context = "object"
    )

    if ($null -eq $Object) { throw "$Context is missing false flag object." }
    foreach ($field in $FieldNames) {
        if ($Object.PSObject.Properties.Name -notcontains $field) { continue }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context $field must be false."
        }
    }
}

function Get-R17ToolAdapterContractFutureAdapterSequence {
    return @(
        [ordered]@{ order = 16; future_task = "R17-016"; adapter_id = "developer_codex_executor_adapter_future"; adapter_type = "developer_codex_executor_adapter"; target_agent_id = "developer"; runtime_implemented = $false },
        [ordered]@{ order = 17; future_task = "R17-017"; adapter_id = "qa_test_agent_adapter_future"; adapter_type = "qa_test_agent_adapter"; target_agent_id = "qa_test_agent"; runtime_implemented = $false },
        [ordered]@{ order = 18; future_task = "R17-018"; adapter_id = "evidence_auditor_api_adapter_future"; adapter_type = "evidence_auditor_api_adapter"; target_agent_id = "evidence_auditor"; runtime_implemented = $false }
    )
}

function Get-R17ToolAdapterContractSeedDefinitions {
    return @(
        [ordered]@{
            adapter_id = "developer_codex_executor_adapter_future"
            adapter_type = "developer_codex_executor_adapter"
            target_agent_id = "developer"
            target_role_name = "Developer"
            future_task = "R17-016"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_developer"
            target_identity_ref = "state/agents/r17_agent_identities/developer.identity.json"
            target_memory_packet_ref = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"
            allowed_tool_boundary = @("adapter_contract_validation_only", "future_codex_executor_packet_contract_only")
        },
        [ordered]@{
            adapter_id = "qa_test_agent_adapter_future"
            adapter_type = "qa_test_agent_adapter"
            target_agent_id = "qa_test_agent"
            target_role_name = "QA/Test Agent"
            future_task = "R17-017"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_qa_test_agent"
            target_identity_ref = "state/agents/r17_agent_identities/qa_test_agent.identity.json"
            target_memory_packet_ref = "state/agents/r17_agent_memory_packets/qa_test_agent.memory_packet.json"
            allowed_tool_boundary = @("adapter_contract_validation_only", "future_qa_test_packet_contract_only")
        },
        [ordered]@{
            adapter_id = "evidence_auditor_api_adapter_future"
            adapter_type = "evidence_auditor_api_adapter"
            target_agent_id = "evidence_auditor"
            target_role_name = "Evidence Auditor"
            future_task = "R17-018"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_evidence_auditor"
            target_identity_ref = "state/agents/r17_agent_identities/evidence_auditor.identity.json"
            target_memory_packet_ref = "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json"
            allowed_tool_boundary = @("adapter_contract_validation_only", "future_evidence_auditor_api_packet_contract_only")
        }
    )
}

function Get-R17ToolAdapterContractAuthorityRefs {
    param([Parameter(Mandatory = $true)][object]$Definition)

    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "contracts/tools/r17_tool_adapter.contract.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "state/agents/r17_agent_registry.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/agents/r17_agent_identity_packet.contract.json",
        [string]$Definition.target_identity_ref,
        [string]$Definition.target_memory_packet_ref,
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )
}

function Get-R17ToolAdapterContractDependencyRefs {
    return @(
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/agents/r17_agent_identity_packet.contract.json",
        "state/agents/r17_agent_registry.json",
        "contracts/context/r17_memory_artifact_loader.contract.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_state_machine.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )
}

function New-R17ToolAdapterContractContract {
    return [ordered]@{
        artifact_type = "r17_tool_adapter_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-015-tool-adapter-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "common_tool_adapter_contract_foundation_only_not_runtime"
        purpose = "Define the shared future adapter profile/request/result contract foundation without implementing adapter runtime, tool calls, Codex invocation, QA/Test invocation, Evidence Auditor API invocation, A2A dispatch, board mutation, or product runtime."
        required_adapter_profile_fields = $script:RequiredProfileFields
        required_adapter_request_fields = $script:RequiredProfileFields
        required_adapter_result_fields = $script:RequiredProfileFields
        required_report_fields = $script:RequiredReportFields
        known_adapter_types = $script:KnownAdapterTypes
        seed_adapter_profile_ids = $script:SeedAdapterIds
        allowed_statuses = @("not_implemented_seed", "queued", "running", "succeeded", "failed", "blocked", "cancelled", "skipped")
        allowed_tool_boundaries = $script:AllowedToolBoundaries
        required_runtime_false_fields = $script:RuntimeFalseFields
        required_claim_status_false_fields = $script:ClaimStatusFields
        future_adapter_sequence = Get-R17ToolAdapterContractFutureAdapterSequence
        seed_profile_policy = [ordered]@{
            disabled_seed_profiles_only = $true
            not_implemented_seed_allowed_for_input_packet_ref = $true
            not_implemented_seed_allowed_for_output_packet_ref = $true
            actual_adapter_runtime_allowed_in_r17_015 = $false
            actual_tool_call_allowed_in_r17_015 = $false
            external_api_call_allowed_in_r17_015 = $false
        }
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            urls_allowed = $false
            local_backups_refs_allowed = $false
            raw_chat_history_as_canonical_allowed = $false
            full_source_file_content_embedding_allowed = $false
            broad_repo_scan_output_allowed = $false
        }
        policy_requirements = [ordered]@{
            secret_policy_required = $true
            cost_policy_required = $true
            timeout_policy_required = $true
            retry_policy_required = $true
            required_authority_refs_required = $true
        }
        fixture_policy = [ordered]@{
            compact_invalid_fixtures_required = $true
            minimum_invalid_fixture_count = $script:MinimumInvalidFixtureCount
            fixture_payloads_must_not_duplicate_large_valid_state = $true
        }
        implementation_boundaries = Get-R17ToolAdapterContractFalseFlags
        claim_status = Get-R17ToolAdapterContractClaimStatus
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
        preserved_boundaries = Get-R17ToolAdapterContractPreservedBoundaries
    }
}

function New-R17ToolAdapterContractSeedProfile {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $runtimeFlags = Get-R17ToolAdapterContractFalseFlags
    return [ordered]@{
        adapter_id = [string]$Definition.adapter_id
        adapter_type = [string]$Definition.adapter_type
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        disabled_seed_profile_only = $true
        not_implemented_seed = $true
        future_task = [string]$Definition.future_task
        card_id = $script:SourceTask
        requested_by_agent_id = "orchestrator"
        target_agent_id = [string]$Definition.target_agent_id
        target_role_name = [string]$Definition.target_role_name
        invocation_ref = [string]$Definition.invocation_ref
        input_packet_ref = "not_implemented_seed"
        output_packet_ref = "not_implemented_seed"
        tool_call_ref = "not_implemented_seed"
        board_event_ref = "not_implemented_seed"
        evidence_refs = @(
            "contracts/tools/r17_tool_adapter.contract.json",
            "state/tools/r17_tool_adapter_seed_profiles.json",
            "state/tools/r17_tool_adapter_contract_check_report.json",
            "state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json",
            "state/runtime/r17_agent_invocation_log.jsonl",
            "state/agents/r17_agent_registry.json",
            "state/context/r17_memory_artifact_loader_report.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        allowed_tool_boundary = @($Definition.allowed_tool_boundary)
        required_authority_refs = Get-R17ToolAdapterContractAuthorityRefs -Definition $Definition
        secret_policy = [ordered]@{
            committed_secret_material_allowed = $false
            secrets_required_for_seed = $false
            external_api_keys_required = $false
            future_secret_gate_required_before_runtime = $true
            secret_scan_claimed = $false
        }
        cost_policy = [ordered]@{
            cost_incurred = $false
            estimated_cost_usd = 0
            external_billing_claimed = $false
            future_cost_budget_required_before_runtime = $true
            provider_cost_known = $false
        }
        timeout_policy = [ordered]@{
            timeout_runtime_implemented = $false
            max_seconds_seed = 0
            future_timeout_required_before_runtime = $true
            runaway_loop_control_implemented = $false
        }
        retry_policy = [ordered]@{
            retry_runtime_implemented = $false
            max_retries_seed = 0
            future_retry_policy_required_before_runtime = $true
            repeated_failure_requires_user_decision = $true
        }
        status = "not_implemented_seed"
        error_ref = "none"
        runtime_flags = $runtimeFlags
        claim_status = Get-R17ToolAdapterContractClaimStatus
        adapter_runtime_implemented = $false
        actual_tool_call_performed = $false
        external_api_call_performed = $false
        codex_executor_invoked = $false
        qa_test_agent_invoked = $false
        evidence_auditor_api_invoked = $false
        a2a_message_sent = $false
        agent_invocation_performed = $false
        board_mutation_performed = $false
        product_runtime_executed = $false
        production_runtime_executed = $false
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
        preserved_boundaries = Get-R17ToolAdapterContractPreservedBoundaries
    }
}

function New-R17ToolAdapterContractArtifactsObjectSet {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot))

    $gitIdentity = Get-R17ToolAdapterContractGitIdentity -RepositoryRoot $RepositoryRoot
    $contract = New-R17ToolAdapterContractContract
    $profiles = @(Get-R17ToolAdapterContractSeedDefinitions | ForEach-Object { New-R17ToolAdapterContractSeedProfile -Definition $_ -GitIdentity $gitIdentity })

    $seedProfiles = [ordered]@{
        artifact_type = "r17_tool_adapter_seed_profiles"
        contract_version = "v1"
        profile_set_id = "aioffice-r17-015-tool-adapter-seed-profiles-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $gitIdentity.Head
        generated_from_tree = $gitIdentity.Tree
        generated_state_artifact_only = $true
        contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        profile_count = @($profiles).Count
        known_adapter_types = $script:KnownAdapterTypes
        future_adapter_sequence = Get-R17ToolAdapterContractFutureAdapterSequence
        adapter_profiles = $profiles
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
    }

    $runtimeSummary = Get-R17ToolAdapterContractFalseFlags
    $report = [ordered]@{
        artifact_type = "r17_tool_adapter_contract_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-015-tool-adapter-contract-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $gitIdentity.Head
        generated_from_tree = $gitIdentity.Tree
        contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        seed_profile_ref = "state/tools/r17_tool_adapter_seed_profiles.json"
        known_adapter_types = $script:KnownAdapterTypes
        future_adapter_sequence = Get-R17ToolAdapterContractFutureAdapterSequence
        dependency_refs = Get-R17ToolAdapterContractDependencyRefs
        invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        memory_loader_ref = "state/context/r17_memory_artifact_loader_report.json"
        seed_profile_count = @($profiles).Count
        seed_adapter_profile_ids = $script:SeedAdapterIds
        runtime_boundary_summary = $runtimeSummary
        claim_status = Get-R17ToolAdapterContractClaimStatus
        validation_summary = [ordered]@{
            contract_fields_present = "passed"
            seed_adapter_profiles_present = "passed"
            duplicate_adapter_id_rejected = "passed"
            unknown_adapter_type_rejected = "passed"
            invocation_refs_present = "passed"
            seed_packet_placeholders_explicit = "passed"
            authority_refs_present = "passed"
            secret_policy_present = "passed"
            cost_policy_present = "passed"
            timeout_policy_present = "passed"
            retry_policy_present = "passed"
            runtime_false_flags_preserved = "passed"
            claim_status_false_flags_preserved = "passed"
            generated_artifact_content_guard = "passed"
            broad_repo_scan_output_guard = "passed"
            compact_invalid_fixture_coverage = "passed"
            external_ui_dependencies_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        generated_state_artifact_only = $true
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
        preserved_boundaries = Get-R17ToolAdapterContractPreservedBoundaries
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_tool_adapter_contract_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-015-tool-adapter-contract-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $gitIdentity.Head
        generated_from_tree = $gitIdentity.Tree
        contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        seed_profile_ref = "state/tools/r17_tool_adapter_seed_profiles.json"
        check_report_ref = "state/tools/r17_tool_adapter_contract_check_report.json"
        known_adapter_types = $script:KnownAdapterTypes
        total_seed_profiles = @($profiles).Count
        visible_profiles = @($profiles | ForEach-Object {
            [ordered]@{
                adapter_id = $_.adapter_id
                adapter_type = $_.adapter_type
                target_agent_id = $_.target_agent_id
                future_task = $_.future_task
                status = $_.status
                adapter_runtime_implemented = $false
                actual_tool_call_performed = $false
                external_api_call_performed = $false
            }
        })
        status_summary = [ordered]@{
            disabled_seed_profiles_only = $true
            adapter_runtime_implemented = $false
            actual_tool_call_performed = $false
            external_api_call_performed = $false
            codex_executor_invoked = $false
            qa_test_agent_invoked = $false
            evidence_auditor_api_invoked = $false
            a2a_message_sent = $false
            agent_invocation_performed = $false
            board_mutation_performed = $false
            product_runtime_executed = $false
        }
        runtime_boundaries = Get-R17ToolAdapterContractFalseFlags
        claim_status = Get-R17ToolAdapterContractClaimStatus
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        SeedProfiles = $seedProfiles
        CheckReport = $report
        Snapshot = $snapshot
    }
}

function New-R17ToolAdapterContractFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths
    )

    Write-R17ToolAdapterContractJson -Path (Join-Path $Paths.FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17ToolAdapterContractJson -Path (Join-Path $Paths.FixtureRoot "valid_seed_profiles.json") -Value $ObjectSet.SeedProfiles
    Write-R17ToolAdapterContractJson -Path (Join-Path $Paths.FixtureRoot "valid_check_report.json") -Value $ObjectSet.CheckReport
    Write-R17ToolAdapterContractJson -Path (Join-Path $Paths.FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $invalids = @(
        [ordered]@{ target = "contract"; remove_paths = @("required_adapter_profile_fields"); expected_failure_fragments = @("required_adapter_profile_fields") },
        [ordered]@{ target = "seed_profiles"; operation = "missing_seed_adapter_profiles"; expected_failure_fragments = @("missing seed adapter profiles") },
        [ordered]@{ target = "seed_profiles"; operation = "duplicate_adapter_id"; expected_failure_fragments = @("duplicate adapter_id") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ adapter_type = "unknown_adapter" }; expected_failure_fragments = @("unknown adapter_type") },
        [ordered]@{ target = "profile"; remove_paths = @("invocation_ref"); expected_failure_fragments = @("invocation_ref") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ input_packet_ref = "" }; expected_failure_fragments = @("input_packet_ref") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ output_packet_ref = "" }; expected_failure_fragments = @("output_packet_ref") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ required_authority_refs = @() }; expected_failure_fragments = @("required_authority_refs") },
        [ordered]@{ target = "profile"; remove_paths = @("secret_policy"); expected_failure_fragments = @("secret_policy") },
        [ordered]@{ target = "profile"; remove_paths = @("cost_policy"); expected_failure_fragments = @("cost_policy") },
        [ordered]@{ target = "profile"; remove_paths = @("timeout_policy"); expected_failure_fragments = @("timeout_policy") },
        [ordered]@{ target = "profile"; remove_paths = @("retry_policy"); expected_failure_fragments = @("retry_policy") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.adapter_runtime_implemented" = $true }; expected_failure_fragments = @("adapter_runtime_implemented") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.actual_tool_call_performed" = $true }; expected_failure_fragments = @("actual_tool_call_performed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.external_api_call_performed" = $true }; expected_failure_fragments = @("external_api_call_performed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.codex_executor_invoked" = $true }; expected_failure_fragments = @("codex_executor_invoked") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.qa_test_agent_invoked" = $true }; expected_failure_fragments = @("qa_test_agent_invoked") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.evidence_auditor_api_invoked" = $true }; expected_failure_fragments = @("evidence_auditor_api_invoked") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.a2a_message_sent" = $true }; expected_failure_fragments = @("a2a_message_sent") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.agent_invocation_performed" = $true }; expected_failure_fragments = @("agent_invocation_performed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.board_mutation_performed" = $true }; expected_failure_fragments = @("board_mutation_performed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "runtime_flags.product_runtime_executed" = $true }; expected_failure_fragments = @("product_runtime_executed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.live_board_mutation_claimed" = $true }; expected_failure_fragments = @("live_board_mutation_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.runtime_card_creation_claimed" = $true }; expected_failure_fragments = @("runtime_card_creation_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.live_orchestrator_runtime_claimed" = $true }; expected_failure_fragments = @("live_orchestrator_runtime_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.autonomous_agent_claimed" = $true }; expected_failure_fragments = @("autonomous_agent_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.executable_handoff_claimed" = $true }; expected_failure_fragments = @("executable_handoff_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.executable_transition_claimed" = $true }; expected_failure_fragments = @("executable_transition_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.runtime_memory_engine_claimed" = $true }; expected_failure_fragments = @("runtime_memory_engine_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.vector_retrieval_claimed" = $true }; expected_failure_fragments = @("vector_retrieval_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.dev_output_claimed" = $true }; expected_failure_fragments = @("dev_output_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.qa_result_claimed" = $true }; expected_failure_fragments = @("qa_result_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.audit_verdict_claimed" = $true }; expected_failure_fragments = @("audit_verdict_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.external_audit_acceptance_claimed" = $true }; expected_failure_fragments = @("external_audit_acceptance_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.main_merge_claimed" = $true }; expected_failure_fragments = @("main_merge_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.r13_closure_claimed" = $true }; expected_failure_fragments = @("r13_closure_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.r14_caveat_removal_claimed" = $true }; expected_failure_fragments = @("r14_caveat_removal_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.r15_caveat_removal_claimed" = $true }; expected_failure_fragments = @("r15_caveat_removal_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.solved_codex_compaction_claimed" = $true }; expected_failure_fragments = @("solved_codex_compaction_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.solved_codex_reliability_claimed" = $true }; expected_failure_fragments = @("solved_codex_reliability_claimed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ "claim_status.r17_016_plus_implementation_claimed" = $true }; expected_failure_fragments = @("r17_016_plus_implementation_claimed") },
        [ordered]@{ target = "report"; set_values = [ordered]@{ full_source_file_contents_embedded = $true }; expected_failure_fragments = @("full_source_file_contents_embedded") },
        [ordered]@{ target = "report"; set_values = [ordered]@{ broad_repo_scan_output_included = $true }; expected_failure_fragments = @("broad_repo_scan_output_included") },
        [ordered]@{ target = "fixture_coverage"; expected_failure_fragments = @("missing compact invalid fixture coverage") },
        [ordered]@{ target = "ui_text"; text = '<script src="https://cdn.example.test/tool.js"></script>'; expected_failure_fragments = @("forbidden external dependency") },
        [ordered]@{ target = "kanban_js"; expected_failure_fragments = @("kanban.js churn") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ allowed_tool_boundary = @("run_any_tool") }; expected_failure_fragments = @("unapproved allowed_tool_boundary") },
        [ordered]@{ target = "profile"; remove_paths = @("tool_call_ref"); expected_failure_fragments = @("tool_call_ref") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ production_runtime_executed = $true }; expected_failure_fragments = @("production_runtime_executed") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ full_source_file_contents_embedded = $true }; expected_failure_fragments = @("full_source_file_contents_embedded") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ broad_repo_scan_output_included = $true }; expected_failure_fragments = @("broad_repo_scan_output_included") },
        [ordered]@{ target = "profile"; set_values = [ordered]@{ requested_by_agent_id = "unknown_agent" }; expected_failure_fragments = @("requested_by_agent_id") }
    )

    $index = 0
    foreach ($invalid in $invalids) {
        $index += 1
        $target = [string]$invalid.target
        $name = if (Test-R17ToolAdapterContractHasProperty -Object $invalid -Name "operation") { [string]$invalid.operation } else { $target }
        $path = Join-Path $Paths.FixtureRoot ("invalid_{0:00}_{1}.json" -f $index, ($name -replace '[^a-zA-Z0-9_]', '_'))
        Write-R17ToolAdapterContractJson -Path $path -Value $invalid
    }
}

function New-R17ToolAdapterContractProofFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths,
        [string]$ManifestStatus = "pending"
    )

    $proof = @"
# R17-015 Tool Adapter Contract Proof Review

Status: generated

R17-015 defines the common tool adapter contract foundation only. It creates disabled seed adapter profiles for future Developer/Codex executor, QA/Test Agent, and Evidence Auditor API adapters.

This package does not implement adapter runtime, tool-call runtime, API calls, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, A2A runtime, A2A messages, live agent runtime, live Orchestrator runtime, live board mutation, runtime card creation, autonomous agents, runtime memory engine, vector retrieval, executable handoffs, executable transitions, product runtime, production runtime, real Dev output, real QA result, or real audit verdict.
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_015_tool_adapter_contract_evidence_index"
        index_version = "v1"
        source_task = $script:SourceTask
        evidence_refs = @(
            "contracts/tools/r17_tool_adapter.contract.json",
            "tools/R17ToolAdapterContract.psm1",
            "tools/new_r17_tool_adapter_contract.ps1",
            "tools/validate_r17_tool_adapter_contract.ps1",
            "tests/test_r17_tool_adapter_contract.ps1",
            "tests/fixtures/r17_tool_adapter_contract/",
            "state/tools/r17_tool_adapter_seed_profiles.json",
            "state/tools/r17_tool_adapter_contract_check_report.json",
            "state/ui/r17_kanban_mvp/r17_tool_adapter_contract_snapshot.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        dependency_refs = Get-R17ToolAdapterContractDependencyRefs
        seed_adapter_profile_ids = $script:SeedAdapterIds
        aggregate_verdict = $script:AggregateVerdict
        non_claims = Get-R17ToolAdapterContractNonClaims
        rejected_claims = Get-R17ToolAdapterContractRejectedClaims
    }

    $manifest = @"
# R17-015 Tool Adapter Contract Validation Manifest

Status: $ManifestStatus

The manifest may be marked passed only after the R17-015 generator, validator, focused test, status-doc gate, impacted R17 validators/tests, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- git diff --check
"@

    Write-R17ToolAdapterContractText -Path $Paths.ProofReview -Value $proof
    Write-R17ToolAdapterContractJson -Path $Paths.EvidenceIndex -Value $evidenceIndex
    Write-R17ToolAdapterContractText -Path $Paths.ValidationManifest -Value $manifest
}

function New-R17ToolAdapterContractArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot),
        [string]$ManifestStatus = "pending"
    )

    $paths = Get-R17ToolAdapterContractPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17ToolAdapterContractArtifactsObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17ToolAdapterContractJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17ToolAdapterContractJson -Path $paths.SeedProfiles -Value $objectSet.SeedProfiles
    Write-R17ToolAdapterContractJson -Path $paths.CheckReport -Value $objectSet.CheckReport
    Write-R17ToolAdapterContractJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    New-R17ToolAdapterContractFixtureFiles -ObjectSet $objectSet -Paths $paths
    New-R17ToolAdapterContractProofFiles -ObjectSet $objectSet -Paths $paths -ManifestStatus $ManifestStatus

    return [pscustomobject]@{
        Contract = $paths.Contract
        SeedProfiles = $paths.SeedProfiles
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $objectSet.CheckReport.aggregate_verdict
        SeedProfileCount = [int]$objectSet.SeedProfiles.profile_count
    }
}

function Assert-R17ToolAdapterContractPacketRef {
    param(
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][string]$FieldName,
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot)
    )

    if ($Profile.PSObject.Properties.Name -notcontains $FieldName) {
        throw "adapter profile $($Profile.adapter_id) is missing required field '$FieldName'."
    }

    $value = [string]$Profile.PSObject.Properties[$FieldName].Value
    if ([bool]$Profile.not_implemented_seed -and [string]$Profile.status -eq "not_implemented_seed") {
        Assert-R17ToolAdapterContractSafeRefPath -Path $value -Context "adapter profile $($Profile.adapter_id) $FieldName" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
        return
    }

    if ([string]::IsNullOrWhiteSpace($value) -or $value -eq "not_implemented_seed") {
        throw "adapter profile $($Profile.adapter_id) $FieldName must be present unless explicitly marked not_implemented_seed."
    }
    Assert-R17ToolAdapterContractSafeRefPath -Path $value -Context "adapter profile $($Profile.adapter_id) $FieldName" -RequireExistingPath -RepositoryRoot $RepositoryRoot
}

function Assert-R17ToolAdapterContractPolicy {
    param(
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][string]$FieldName,
        [Parameter(Mandatory = $true)][string[]]$RequiredFields
    )

    Assert-R17ToolAdapterContractRequiredFields -Object $Profile -FieldNames @($FieldName) -Context "adapter profile $($Profile.adapter_id)"
    $policy = $Profile.PSObject.Properties[$FieldName].Value
    Assert-R17ToolAdapterContractRequiredFields -Object $policy -FieldNames $RequiredFields -Context "adapter profile $($Profile.adapter_id) $FieldName"
}

function Assert-R17ToolAdapterContractProfile {
    param(
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object]$Contract,
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot)
    )

    Assert-R17ToolAdapterContractRequiredFields -Object $Profile -FieldNames @($Contract.required_adapter_profile_fields) -Context "adapter profile"

    if ([string]$Profile.source_task -ne $script:SourceTask) { throw "adapter profile $($Profile.adapter_id) source_task must be R17-015." }
    if ([string]$Profile.card_id -ne $script:SourceTask) { throw "adapter profile $($Profile.adapter_id) card_id must be R17-015." }
    if (@($Contract.known_adapter_types) -notcontains [string]$Profile.adapter_type) { throw "adapter profile $($Profile.adapter_id) has unknown adapter_type '$($Profile.adapter_type)'." }
    if ($script:KnownAgentIds -notcontains [string]$Profile.requested_by_agent_id) { throw "adapter profile $($Profile.adapter_id) requested_by_agent_id is unknown." }
    if ($script:KnownAgentIds -notcontains [string]$Profile.target_agent_id) { throw "adapter profile $($Profile.adapter_id) target_agent_id is unknown." }
    if (@($Contract.allowed_statuses) -notcontains [string]$Profile.status) { throw "adapter profile $($Profile.adapter_id) status is not allowed." }
    if ([string]$Profile.status -ne "not_implemented_seed" -or [bool]$Profile.not_implemented_seed -ne $true) {
        throw "adapter profile $($Profile.adapter_id) must remain an explicit not_implemented_seed in R17-015."
    }

    Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$Profile.invocation_ref) -Context "adapter profile $($Profile.adapter_id) invocation_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractPacketRef -Profile $Profile -FieldName "input_packet_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractPacketRef -Profile $Profile -FieldName "output_packet_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractPacketRef -Profile $Profile -FieldName "tool_call_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractPacketRef -Profile $Profile -FieldName "board_event_ref" -RepositoryRoot $RepositoryRoot

    if (@($Profile.allowed_tool_boundary).Count -lt 1) { throw "adapter profile $($Profile.adapter_id) allowed_tool_boundary must not be empty." }
    foreach ($boundary in @($Profile.allowed_tool_boundary)) {
        if (@($Contract.allowed_tool_boundaries) -notcontains [string]$boundary) {
            throw "adapter profile $($Profile.adapter_id) contains unapproved allowed_tool_boundary '$boundary'."
        }
    }

    if (@($Profile.required_authority_refs).Count -lt 1) { throw "adapter profile $($Profile.adapter_id) required_authority_refs must not be empty." }
    foreach ($ref in @($Profile.required_authority_refs)) {
        Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$ref) -Context "adapter profile $($Profile.adapter_id) required_authority_refs" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }

    Assert-R17ToolAdapterContractPolicy -Profile $Profile -FieldName "secret_policy" -RequiredFields @("committed_secret_material_allowed", "secrets_required_for_seed", "external_api_keys_required", "future_secret_gate_required_before_runtime", "secret_scan_claimed")
    Assert-R17ToolAdapterContractPolicy -Profile $Profile -FieldName "cost_policy" -RequiredFields @("cost_incurred", "estimated_cost_usd", "external_billing_claimed", "future_cost_budget_required_before_runtime", "provider_cost_known")
    Assert-R17ToolAdapterContractPolicy -Profile $Profile -FieldName "timeout_policy" -RequiredFields @("timeout_runtime_implemented", "max_seconds_seed", "future_timeout_required_before_runtime", "runaway_loop_control_implemented")
    Assert-R17ToolAdapterContractPolicy -Profile $Profile -FieldName "retry_policy" -RequiredFields @("retry_runtime_implemented", "max_retries_seed", "future_retry_policy_required_before_runtime", "repeated_failure_requires_user_decision")
    if ([bool]$Profile.secret_policy.committed_secret_material_allowed -ne $false -or [bool]$Profile.secret_policy.external_api_keys_required -ne $false) { throw "adapter profile $($Profile.adapter_id) secret_policy must not require or commit secrets." }
    if ([bool]$Profile.cost_policy.cost_incurred -ne $false -or [bool]$Profile.cost_policy.external_billing_claimed -ne $false) { throw "adapter profile $($Profile.adapter_id) cost_policy must not claim incurred cost." }
    if ([bool]$Profile.timeout_policy.timeout_runtime_implemented -ne $false) { throw "adapter profile $($Profile.adapter_id) timeout_policy must not implement runtime timeout." }
    if ([bool]$Profile.retry_policy.retry_runtime_implemented -ne $false) { throw "adapter profile $($Profile.adapter_id) retry_policy must not implement runtime retry." }

    Assert-R17ToolAdapterContractFalseFlags -Object $Profile.runtime_flags -FieldNames @($Contract.required_runtime_false_fields) -Context "adapter profile $($Profile.adapter_id) runtime_flags"
    Assert-R17ToolAdapterContractFalseFlags -Object $Profile.claim_status -FieldNames @($Contract.required_claim_status_false_fields) -Context "adapter profile $($Profile.adapter_id) claim_status"
    Assert-R17ToolAdapterContractFalseFlags -Object $Profile -FieldNames @("adapter_runtime_implemented", "actual_tool_call_performed", "external_api_call_performed", "codex_executor_invoked", "qa_test_agent_invoked", "evidence_auditor_api_invoked", "a2a_message_sent", "agent_invocation_performed", "board_mutation_performed", "product_runtime_executed", "production_runtime_executed", "full_source_file_contents_embedded", "broad_repo_scan_output_included", "broad_repo_scan_used") -Context "adapter profile $($Profile.adapter_id)"

    if ([string]::IsNullOrWhiteSpace([string]$Profile.error_ref)) { throw "adapter profile $($Profile.adapter_id) error_ref must be present." }
    Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$Profile.error_ref) -Context "adapter profile $($Profile.adapter_id) error_ref" -AllowNone -RepositoryRoot $RepositoryRoot

    if (@($Profile.evidence_refs).Count -lt 1) { throw "adapter profile $($Profile.adapter_id) evidence_refs must not be empty." }
    foreach ($ref in @($Profile.evidence_refs)) {
        Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$ref) -Context "adapter profile $($Profile.adapter_id) evidence_ref" -RepositoryRoot $RepositoryRoot
    }
    Assert-R17ToolAdapterContractContains -Values @($Profile.non_claims) -Required (Get-R17ToolAdapterContractNonClaims) -Context "adapter profile $($Profile.adapter_id) non_claims"
    Assert-R17ToolAdapterContractContains -Values @($Profile.rejected_claims) -Required (Get-R17ToolAdapterContractRejectedClaims) -Context "adapter profile $($Profile.adapter_id) rejected_claims"
}

function Assert-R17ToolAdapterContractUiText {
    param([Parameter(Mandatory = $true)][hashtable]$UiTextByPath)

    foreach ($path in $UiTextByPath.Keys) {
        $text = [string]$UiTextByPath[$path]
        foreach ($pattern in @("http://", "https://", "(?i)\bcdn\b", "(?i)\bnpm\b", "(?i)fonts\.googleapis", "(?i)fonts\.gstatic", "(?i)unpkg", "(?i)jsdelivr", "(?i)@import\s+url")) {
            if ($text -match $pattern) {
                throw "UI file '$path' contains forbidden external dependency reference matching '$pattern'."
            }
        }
    }

    $indexText = ""
    foreach ($path in $UiTextByPath.Keys) {
        if ($path -like "*index.html") { $indexText = [string]$UiTextByPath[$path]; break }
    }

    foreach ($fragment in @("tool-adapter-contract-panel", "Tool Adapter Contract", "disabled seed adapter profiles only", "adapter_runtime_implemented: false", "actual_tool_call_performed: false", "external_api_call_performed: false", "no adapter runtime", "no tool calls", "no API calls")) {
        if ($indexText -notmatch [regex]::Escape($fragment)) {
            throw "index.html must expose R17-015 tool adapter contract fragment '$fragment'."
        }
    }
}

function Assert-R17ToolAdapterContractFixtureCoverage {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [int]$MinimumInvalidFixtureCount = $script:MinimumInvalidFixtureCount
    )

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $MinimumInvalidFixtureCount) {
        throw "missing compact invalid fixture coverage: expected at least $MinimumInvalidFixtureCount invalid fixtures."
    }
}

function Assert-R17ToolAdapterContractKanbanJsUnchanged {
    param(
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot),
        [string[]]$ChangedPaths
    )

    if ($null -eq $ChangedPaths) {
        $ChangedPaths = @()
        $ChangedPaths += @((& git -C $RepositoryRoot diff --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $ChangedPaths += @((& git -C $RepositoryRoot diff --cached --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    if (@($ChangedPaths | Where-Object { $_ -eq "scripts/operator_wall/r17_kanban_mvp/kanban.js" }).Count -gt 0) {
        throw "kanban.js churn is not allowed for R17-015 unless explicitly justified."
    }
}

function Test-R17ToolAdapterContractSet {
    [CmdletBinding()]
    param(
        [object]$Contract,
        [object]$SeedProfiles,
        [object]$Report,
        [object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot),
        [switch]$SkipUiFiles,
        [switch]$SkipFixtureCoverage
    )

    Assert-R17ToolAdapterContractRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "required_adapter_profile_fields", "required_report_fields", "known_adapter_types", "seed_adapter_profile_ids", "allowed_tool_boundaries", "required_runtime_false_fields", "required_claim_status_false_fields", "seed_profile_policy", "exact_ref_policy", "policy_requirements", "fixture_policy", "implementation_boundaries", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "contract"
    if ($Contract.artifact_type -ne "r17_tool_adapter_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask) { throw "contract source_task must be R17-015." }
    Assert-R17ToolAdapterContractContains -Values @($Contract.required_adapter_profile_fields) -Required $script:RequiredProfileFields -Context "contract required_adapter_profile_fields"
    Assert-R17ToolAdapterContractContains -Values @($Contract.required_report_fields) -Required $script:RequiredReportFields -Context "contract required_report_fields"
    Assert-R17ToolAdapterContractContains -Values @($Contract.known_adapter_types) -Required $script:KnownAdapterTypes -Context "contract known_adapter_types"
    Assert-R17ToolAdapterContractContains -Values @($Contract.seed_adapter_profile_ids) -Required $script:SeedAdapterIds -Context "contract seed_adapter_profile_ids"
    Assert-R17ToolAdapterContractFalseFlags -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract implementation_boundaries"
    Assert-R17ToolAdapterContractFalseFlags -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "contract claim_status"
    if ([bool]$Contract.exact_ref_policy.full_source_file_content_embedding_allowed -ne $false) { throw "contract must forbid generated artifact embedding full source file contents." }
    if ([bool]$Contract.exact_ref_policy.broad_repo_scan_output_allowed -ne $false) { throw "contract must forbid broad repo scan output." }
    Assert-R17ToolAdapterContractContains -Values @($Contract.non_claims) -Required (Get-R17ToolAdapterContractNonClaims) -Context "contract non_claims"
    Assert-R17ToolAdapterContractContains -Values @($Contract.rejected_claims) -Required (Get-R17ToolAdapterContractRejectedClaims) -Context "contract rejected_claims"

    Assert-R17ToolAdapterContractRequiredFields -Object $SeedProfiles -FieldNames @("artifact_type", "source_task", "contract_ref", "profile_count", "known_adapter_types", "future_adapter_sequence", "adapter_profiles", "non_claims", "rejected_claims") -Context "seed profiles"
    if ($SeedProfiles.artifact_type -ne "r17_tool_adapter_seed_profiles") { throw "seed profiles artifact_type is invalid." }
    if ($SeedProfiles.source_task -ne $script:SourceTask) { throw "seed profiles source_task must be R17-015." }
    $profiles = @($SeedProfiles.adapter_profiles)
    if ($profiles.Count -lt $script:SeedAdapterIds.Count) { throw "missing seed adapter profiles." }
    if ([int]$SeedProfiles.profile_count -ne $profiles.Count) { throw "seed profiles profile_count does not match adapter_profiles." }
    Assert-R17ToolAdapterContractContains -Values @($SeedProfiles.known_adapter_types) -Required $script:KnownAdapterTypes -Context "seed profiles known_adapter_types"

    $seen = @{}
    foreach ($profile in $profiles) {
        $adapterId = [string]$profile.adapter_id
        if ([string]::IsNullOrWhiteSpace($adapterId)) { throw "adapter_id must not be empty." }
        if ($seen.ContainsKey($adapterId)) { throw "duplicate adapter_id '$adapterId'." }
        $seen[$adapterId] = $true
        Assert-R17ToolAdapterContractProfile -Profile $profile -Contract $Contract -RepositoryRoot $RepositoryRoot
    }
    Assert-R17ToolAdapterContractContains -Values @($seen.Keys) -Required $script:SeedAdapterIds -Context "seed profiles adapter_ids"

    Assert-R17ToolAdapterContractRequiredFields -Object $Report -FieldNames @($Contract.required_report_fields) -Context "check report"
    if ($Report.artifact_type -ne "r17_tool_adapter_contract_check_report") { throw "check report artifact_type is invalid." }
    if ($Report.source_task -ne $script:SourceTask) { throw "check report source_task must be R17-015." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    if ([string]$Report.contract_ref -ne "contracts/tools/r17_tool_adapter.contract.json") { throw "check report contract_ref is invalid." }
    if ([string]$Report.seed_profile_ref -ne "state/tools/r17_tool_adapter_seed_profiles.json") { throw "check report seed_profile_ref is invalid." }
    Assert-R17ToolAdapterContractContains -Values @($Report.known_adapter_types) -Required $script:KnownAdapterTypes -Context "check report known_adapter_types"
    Assert-R17ToolAdapterContractContains -Values @($Report.seed_adapter_profile_ids) -Required $script:SeedAdapterIds -Context "check report seed_adapter_profile_ids"
    foreach ($ref in @($Report.dependency_refs)) {
        Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$ref) -Context "check report dependency_refs" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$Report.invocation_log_ref) -Context "check report invocation_log_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$Report.agent_registry_ref) -Context "check report agent_registry_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractSafeRefPath -Path ([string]$Report.memory_loader_ref) -Context "check report memory_loader_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17ToolAdapterContractFalseFlags -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17ToolAdapterContractFalseFlags -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    if ([bool]$Report.full_source_file_contents_embedded -ne $false) { throw "check report full_source_file_contents_embedded must be false." }
    if ([bool]$Report.broad_repo_scan_output_included -ne $false) { throw "check report broad_repo_scan_output_included must be false." }
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }
    Assert-R17ToolAdapterContractContains -Values @($Report.non_claims) -Required (Get-R17ToolAdapterContractNonClaims) -Context "check report non_claims"
    Assert-R17ToolAdapterContractContains -Values @($Report.rejected_claims) -Required (Get-R17ToolAdapterContractRejectedClaims) -Context "check report rejected_claims"

    Assert-R17ToolAdapterContractRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "contract_ref", "seed_profile_ref", "check_report_ref", "known_adapter_types", "total_seed_profiles", "visible_profiles", "status_summary", "runtime_boundaries", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_tool_adapter_contract_snapshot") { throw "UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne "R17-015") { throw "UI snapshot active_through_task must be R17-015." }
    if ([int]$Snapshot.total_seed_profiles -ne $profiles.Count) { throw "UI snapshot total_seed_profiles does not match profiles." }
    Assert-R17ToolAdapterContractFalseFlags -Object $Snapshot.status_summary -FieldNames @("adapter_runtime_implemented", "actual_tool_call_performed", "external_api_call_performed", "codex_executor_invoked", "qa_test_agent_invoked", "evidence_auditor_api_invoked", "a2a_message_sent", "agent_invocation_performed", "board_mutation_performed", "product_runtime_executed") -Context "UI snapshot status_summary"
    Assert-R17ToolAdapterContractFalseFlags -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17ToolAdapterContractFalseFlags -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"
    Assert-R17ToolAdapterContractContains -Values @($Snapshot.non_claims) -Required (Get-R17ToolAdapterContractNonClaims) -Context "UI snapshot non_claims"
    Assert-R17ToolAdapterContractContains -Values @($Snapshot.rejected_claims) -Required (Get-R17ToolAdapterContractRejectedClaims) -Context "UI snapshot rejected_claims"

    if (-not $SkipFixtureCoverage) {
        $paths = Get-R17ToolAdapterContractPaths -RepositoryRoot $RepositoryRoot
        Assert-R17ToolAdapterContractFixtureCoverage -FixtureRoot $paths.FixtureRoot -MinimumInvalidFixtureCount ([int]$Contract.fixture_policy.minimum_invalid_fixture_count)
    }

    if (-not $SkipUiFiles) {
        $paths = Get-R17ToolAdapterContractPaths -RepositoryRoot $RepositoryRoot
        $uiText = @{}
        foreach ($uiPath in $paths.UiFiles) {
            if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) { throw "UI file '$uiPath' does not exist." }
            $uiText[$uiPath] = Get-Content -LiteralPath $uiPath -Raw
        }
        Assert-R17ToolAdapterContractUiText -UiTextByPath $uiText
        Assert-R17ToolAdapterContractKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        SeedProfileCount = [int]$SeedProfiles.profile_count
        KnownAdapterTypes = @($Report.known_adapter_types)
        AdapterRuntimeImplemented = [bool]$Report.runtime_boundary_summary.adapter_runtime_implemented
        ActualToolCallPerformed = [bool]$Report.runtime_boundary_summary.actual_tool_call_performed
        ExternalApiCallPerformed = [bool]$Report.runtime_boundary_summary.external_api_call_performed
        CodexExecutorInvoked = [bool]$Report.runtime_boundary_summary.codex_executor_invoked
        QaTestAgentInvoked = [bool]$Report.runtime_boundary_summary.qa_test_agent_invoked
        EvidenceAuditorApiInvoked = [bool]$Report.runtime_boundary_summary.evidence_auditor_api_invoked
        A2aMessageSent = [bool]$Report.runtime_boundary_summary.a2a_message_sent
    }
}

function Test-R17ToolAdapterContract {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17ToolAdapterContractRepositoryRoot))

    $paths = Get-R17ToolAdapterContractPaths -RepositoryRoot $RepositoryRoot
    return Test-R17ToolAdapterContractSet `
        -Contract (Read-R17ToolAdapterContractJson -Path $paths.Contract) `
        -SeedProfiles (Read-R17ToolAdapterContractJson -Path $paths.SeedProfiles) `
        -Report (Read-R17ToolAdapterContractJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17ToolAdapterContractJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17ToolAdapterContractObjectPathValue {
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

function Remove-R17ToolAdapterContractObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) { return }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -ne $current.PSObject.Properties[$leaf]) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R17ToolAdapterContractMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if (Test-R17ToolAdapterContractHasProperty -Object $Mutation -Name "remove_paths") {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R17ToolAdapterContractObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ((Test-R17ToolAdapterContractHasProperty -Object $Mutation -Name "set_values") -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17ToolAdapterContractObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17ToolAdapterContractPaths, `
    Get-R17ToolAdapterContractNonClaims, `
    Get-R17ToolAdapterContractRejectedClaims, `
    New-R17ToolAdapterContractArtifacts, `
    New-R17ToolAdapterContractArtifactsObjectSet, `
    Test-R17ToolAdapterContract, `
    Test-R17ToolAdapterContractSet, `
    Assert-R17ToolAdapterContractUiText, `
    Assert-R17ToolAdapterContractFixtureCoverage, `
    Assert-R17ToolAdapterContractKanbanJsUnchanged, `
    Invoke-R17ToolAdapterContractMutation, `
    Copy-R17ToolAdapterContractObject
