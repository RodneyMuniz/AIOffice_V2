Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-019"
$script:AggregateVerdict = "generated_r17_tool_call_ledger_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger"
$script:FixtureRoot = "tests/fixtures/r17_tool_call_ledger"
$script:MinimumInvalidFixtureCount = 24

$script:AllowedStatuses = @(
    "disabled_seed",
    "not_executed_disabled_foundation",
    "packet_only",
    "placeholder_only",
    "blocked",
    "invalid"
)

$script:SeedAdapterIds = @(
    "developer_codex_executor_adapter_future",
    "qa_test_agent_adapter_future",
    "evidence_auditor_api_adapter_future"
)

$script:RequiredRecordFields = @(
    "ledger_record_id",
    "source_task",
    "card_id",
    "requested_by_agent_id",
    "target_agent_id",
    "adapter_id",
    "adapter_type",
    "invocation_ref",
    "request_packet_ref",
    "response_or_result_packet_ref",
    "board_event_ref",
    "evidence_refs",
    "authority_refs",
    "memory_packet_ref",
    "secret_policy",
    "cost_policy",
    "timeout_policy",
    "retry_policy",
    "execution_mode",
    "status",
    "error_ref",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReportFields = @(
    "total_ledger_records",
    "ledger_record_ids",
    "adapter_ids",
    "contract_ref",
    "ledger_ref",
    "ui_snapshot_ref",
    "dependency_refs",
    "board_ref_summary",
    "runtime_boundary_summary",
    "validation_summary",
    "aggregate_verdict",
    "non_claims",
    "rejected_claims"
)

$script:ExplicitFalseFields = @(
    "ledger_runtime_implemented",
    "tool_call_runtime_implemented",
    "actual_tool_call_performed",
    "adapter_runtime_invoked",
    "codex_executor_invoked",
    "qa_test_agent_invoked",
    "evidence_auditor_api_invoked",
    "external_api_call_performed",
    "a2a_message_sent",
    "board_mutation_performed",
    "runtime_card_creation_performed",
    "product_runtime_executed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "main_merge_claimed"
)

$script:RuntimeFalseFields = @(
    "ledger_runtime_implemented",
    "tool_call_runtime_implemented",
    "adapter_runtime_implemented",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "codex_executor_invoked",
    "qa_test_agent_invoked",
    "evidence_auditor_api_invoked",
    "a2a_message_sent",
    "agent_invocation_performed",
    "board_mutation_performed",
    "runtime_card_creation_performed",
    "runtime_card_creation_claimed",
    "product_runtime_executed",
    "production_runtime_executed",
    "live_orchestrator_runtime_invoked",
    "autonomous_agent_executed",
    "executable_handoff_performed",
    "executable_transition_performed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict",
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
    "live_agent_runtime_claimed",
    "live_orchestrator_runtime_claimed",
    "a2a_runtime_claimed",
    "a2a_messages_claimed",
    "autonomous_agent_claimed",
    "adapter_runtime_claimed",
    "tool_call_runtime_claimed",
    "codex_executor_invocation_claimed",
    "qa_test_agent_invocation_claimed",
    "evidence_auditor_api_invocation_claimed",
    "external_api_call_claimed",
    "runtime_memory_engine_claimed",
    "vector_retrieval_claimed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r17_020_plus_implementation_claimed",
    "external_integration_claimed"
)

function Get-R17ToolCallLedgerRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17ToolCallLedgerPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    return Join-Path $RepositoryRoot $RelativePath
}

function Test-R17ToolCallLedgerHasProperty {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return ($Object.PSObject.Properties.Name -contains $Name)
}

function Get-R17ToolCallLedgerProperty {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17ToolCallLedgerHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Read-R17ToolCallLedgerJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R17ToolCallLedgerJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $records += ($line | ConvertFrom-Json)
    }

    return $records
}

function Write-R17ToolCallLedgerJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17ToolCallLedgerText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Write-R17ToolCallLedgerJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Records
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $lines = @($Records | ForEach-Object { $_ | ConvertTo-Json -Depth 20 -Compress })
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Copy-R17ToolCallLedgerObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 30 | ConvertFrom-Json)
}

function Get-R17ToolCallLedgerPaths {
    param([string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot))

    return [pscustomobject]@{
        RepositoryRoot = $RepositoryRoot
        Contract = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath "contracts/runtime/r17_tool_call_ledger.contract.json"
        Ledger = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath "state/runtime/r17_tool_call_ledger.jsonl"
        CheckReport = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath "state/runtime/r17_tool_call_ledger_check_report.json"
        UiSnapshot = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath "state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json"
        FixtureRoot = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath $script:FixtureRoot
        ProofRoot = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath $script:ProofRoot
        ProofReview = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath (Join-Path $script:ProofRoot "proof_review.md")
        EvidenceIndex = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath (Join-Path $script:ProofRoot "evidence_index.json")
        ValidationManifest = Resolve-R17ToolCallLedgerPath -RepositoryRoot $RepositoryRoot -RelativePath (Join-Path $script:ProofRoot "validation_manifest.md")
    }
}

function Get-R17ToolCallLedgerGitIdentity {
    param([string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function Get-R17ToolCallLedgerNonClaims {
    return @(
        "R17-019 creates the tool-call ledger foundation only",
        "R17-019 records disabled/not-executed seed tool-call records only",
        "R17-019 does not implement a tool-call runtime",
        "R17-019 does not implement ledger runtime",
        "R17-019 does not perform actual tool calls",
        "R17-019 does not invoke adapter runtime",
        "R17-019 does not invoke Codex executor",
        "R17-019 does not invoke QA/Test Agent",
        "R17-019 does not invoke Evidence Auditor API",
        "R17-019 does not call external APIs",
        "R17-019 does not send A2A messages",
        "R17-019 does not mutate the board live",
        "R17-019 does not create runtime cards",
        "R17-019 does not implement autonomous agents",
        "R17-019 does not implement runtime memory engine",
        "R17-019 does not implement vector retrieval",
        "R17-019 does not implement executable handoffs",
        "R17-019 does not implement executable transitions",
        "R17-019 does not implement product runtime",
        "R17-019 does not implement production runtime",
        "R17-019 does not produce real Dev output",
        "R17-019 does not produce real QA result",
        "R17-019 does not produce a real audit verdict",
        "R17-019 does not claim external audit acceptance",
        "R17-019 does not claim main merge",
        "R17-019 does not close R13",
        "R17-019 does not remove R14 caveats",
        "R17-019 does not remove R15 caveats",
        "R17-019 does not solve Codex compaction",
        "R17-019 does not solve Codex reliability",
        "R17-020 through R17-028 remain planned only"
    )
}

function Get-R17ToolCallLedgerRejectedClaims {
    return @(
        "live_board_mutation",
        "runtime_card_creation",
        "live_agent_runtime",
        "live_Orchestrator_runtime",
        "A2A_runtime",
        "A2A_messages_sent",
        "autonomous_agents",
        "adapter_runtime",
        "adapter_runtime_invocation",
        "tool_call_runtime",
        "ledger_runtime",
        "actual_tool_call",
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
        "R17_020_or_later_implementation"
    )
}

function Get-R17ToolCallLedgerFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) {
        $flags[$field] = $false
    }

    return [pscustomobject]$flags
}

function Get-R17ToolCallLedgerExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }

    return [pscustomobject]$flags
}

function Get-R17ToolCallLedgerClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) {
        $status[$field] = $false
    }

    return [pscustomobject]$status
}

function Get-R17ToolCallLedgerPreservedBoundaries {
    return [pscustomobject]@{
        r13 = [pscustomobject]@{
            status = "failed/partial"
            active_through = "R13-018"
            closed = $false
        }
        r14 = [pscustomobject]@{
            status = "accepted_with_caveats"
            active_through = "R14-006"
            caveats_removed = $false
        }
        r15 = [pscustomobject]@{
            status = "accepted_with_caveats_by_external_audit"
            active_through = "R15-009"
            caveats_removed = $false
        }
        r16 = [pscustomobject]@{
            status = "complete_bounded_foundation_scope"
            active_through = "R16-026"
            overclaimed = $false
        }
        r17 = [pscustomobject]@{
            status = "active"
            active_through = "R17-019"
            planned_only_from = "R17-020"
            planned_only_through = "R17-028"
        }
    }
}

function Get-R17ToolCallLedgerDependencyRefs {
    return [pscustomobject]@{
        agent_invocation_log_contract_ref = "contracts/runtime/r17_agent_invocation_log.contract.json"
        agent_invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        tool_adapter_contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        tool_adapter_seed_profile_ref = "state/tools/r17_tool_adapter_seed_profiles.json"
        codex_executor_adapter_contract_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
        codex_executor_request_ref = "state/tools/r17_codex_executor_adapter_request_packet.json"
        codex_executor_result_ref = "state/tools/r17_codex_executor_adapter_result_packet.json"
        qa_test_agent_adapter_contract_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
        qa_test_agent_request_ref = "state/tools/r17_qa_test_agent_adapter_request_packet.json"
        qa_test_agent_result_ref = "state/tools/r17_qa_test_agent_adapter_result_packet.json"
        evidence_auditor_api_adapter_contract_ref = "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
        evidence_auditor_api_request_ref = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"
        evidence_auditor_api_response_ref = "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"
        evidence_auditor_api_verdict_ref = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        memory_loader_ref = "state/context/r17_memory_artifact_loader_report.json"
        board_state_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"
        board_event_contract_ref = "contracts/board/r17_board_event.contract.json"
        orchestration_transition_report_ref = "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    }
}

function Get-R17ToolCallLedgerSeedDefinitions {
    return @(
        [pscustomobject]@{
            ledger_record_id = "r17_019_seed_tool_call_developer_codex_executor_adapter_future"
            adapter_id = "developer_codex_executor_adapter_future"
            adapter_type = "developer_codex_executor_adapter"
            adapter_source_task = "R17-016"
            target_agent_id = "developer"
            target_role_name = "Developer"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_developer"
            request_packet_ref = "state/tools/r17_codex_executor_adapter_request_packet.json"
            response_or_result_packet_ref = "state/tools/r17_codex_executor_adapter_result_packet.json"
            memory_packet_ref = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"
            adapter_contract_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
            adapter_check_report_ref = "state/tools/r17_codex_executor_adapter_check_report.json"
            adapter_snapshot_ref = "state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json"
        },
        [pscustomobject]@{
            ledger_record_id = "r17_019_seed_tool_call_qa_test_agent_adapter_future"
            adapter_id = "qa_test_agent_adapter_future"
            adapter_type = "qa_test_agent_adapter"
            adapter_source_task = "R17-017"
            target_agent_id = "qa_test_agent"
            target_role_name = "QA/Test Agent"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_qa_test_agent"
            request_packet_ref = "state/tools/r17_qa_test_agent_adapter_request_packet.json"
            response_or_result_packet_ref = "state/tools/r17_qa_test_agent_adapter_result_packet.json"
            memory_packet_ref = "state/agents/r17_agent_memory_packets/qa_test_agent.memory_packet.json"
            adapter_contract_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
            adapter_check_report_ref = "state/tools/r17_qa_test_agent_adapter_check_report.json"
            adapter_snapshot_ref = "state/ui/r17_kanban_mvp/r17_qa_test_agent_adapter_snapshot.json"
        },
        [pscustomobject]@{
            ledger_record_id = "r17_019_seed_tool_call_evidence_auditor_api_adapter_future"
            adapter_id = "evidence_auditor_api_adapter_future"
            adapter_type = "evidence_auditor_api_adapter"
            adapter_source_task = "R17-018"
            target_agent_id = "evidence_auditor"
            target_role_name = "Evidence Auditor"
            invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_evidence_auditor"
            request_packet_ref = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"
            response_or_result_packet_ref = "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"
            secondary_result_packet_ref = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"
            memory_packet_ref = "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json"
            adapter_contract_ref = "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
            adapter_check_report_ref = "state/tools/r17_evidence_auditor_api_adapter_check_report.json"
            adapter_snapshot_ref = "state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json"
        }
    )
}

function New-R17ToolCallLedgerContract {
    $falseMap = Get-R17ToolCallLedgerExplicitFalseMap
    $runtimeFlags = Get-R17ToolCallLedgerFalseFlags

    return [pscustomobject]@{
        artifact_type = "r17_tool_call_ledger_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-019-tool-call-ledger-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "repo_backed_tool_call_ledger_foundation_only_not_runtime"
        purpose = "Define compact disabled/not-executed seed tool-call ledger records for the R17 adapter chain without executing a tool call, invoking adapters, sending A2A messages, calling external APIs, mutating the board, or claiming runtime."
        required_ledger_record_fields = $script:RequiredRecordFields
        required_report_fields = $script:RequiredReportFields
        seed_adapter_ids = $script:SeedAdapterIds
        allowed_statuses = $script:AllowedStatuses
        allowed_execution_modes = $script:AllowedStatuses
        required_explicit_false_fields = $script:ExplicitFalseFields
        required_runtime_false_fields = $script:RuntimeFalseFields
        required_claim_status_false_fields = $script:ClaimStatusFields
        ledger_policy = [pscustomobject]@{
            repo_backed_jsonl = $true
            seed_records_allowed_for_r17_019 = $true
            actual_tool_call_allowed_in_r17_019 = $false
            adapter_runtime_invocation_allowed_in_r17_019 = $false
            runtime_append_requires_later_task = $true
            ledger_runtime_implemented = $false
            tool_call_runtime_implemented = $false
        }
        exact_ref_policy = [pscustomobject]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            urls_allowed = $false
            local_backups_refs_allowed = $false
            raw_chat_history_as_canonical_allowed = $false
            full_source_file_content_embedding_allowed = $false
            broad_repo_scan_output_allowed = $false
        }
        implementation_boundaries = $runtimeFlags
        explicit_false_fields = $falseMap
        claim_status = Get-R17ToolCallLedgerClaimStatus
        dependency_refs = Get-R17ToolCallLedgerDependencyRefs
        preserved_boundaries = Get-R17ToolCallLedgerPreservedBoundaries
        non_claims = Get-R17ToolCallLedgerNonClaims
        rejected_claims = Get-R17ToolCallLedgerRejectedClaims
    }
}

function New-R17ToolCallLedgerRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $evidenceRefs = @(
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "state/runtime/r17_tool_call_ledger.jsonl",
        "state/runtime/r17_tool_call_ledger_check_report.json",
        "state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json",
        "tools/R17ToolCallLedger.psm1",
        "tools/new_r17_tool_call_ledger.ps1",
        "tools/validate_r17_tool_call_ledger.ps1",
        "tests/test_r17_tool_call_ledger.ps1",
        "tests/fixtures/r17_tool_call_ledger/",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        $Definition.adapter_contract_ref,
        $Definition.request_packet_ref,
        $Definition.response_or_result_packet_ref,
        $Definition.adapter_check_report_ref,
        $Definition.adapter_snapshot_ref,
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/validation_manifest.md"
    )

    if (Test-R17ToolCallLedgerHasProperty -Object $Definition -Name "secondary_result_packet_ref") {
        $evidenceRefs += $Definition.secondary_result_packet_ref
    }

    $authorityRefs = @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        $Definition.adapter_contract_ref,
        "state/agents/r17_agent_registry.json",
        ("state/agents/r17_agent_identities/{0}.identity.json" -f $Definition.target_agent_id),
        $Definition.memory_packet_ref,
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )

    $explicitFalse = Get-R17ToolCallLedgerExplicitFalseMap
    $record = [ordered]@{
        artifact_type = "r17_tool_call_ledger_record"
        contract_version = "v1"
        ledger_record_id = $Definition.ledger_record_id
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = $script:SourceTask
        adapter_source_task = $Definition.adapter_source_task
        requested_by_agent_id = "orchestrator"
        target_agent_id = $Definition.target_agent_id
        target_role_name = $Definition.target_role_name
        adapter_id = $Definition.adapter_id
        adapter_type = $Definition.adapter_type
        invocation_ref = $Definition.invocation_ref
        request_packet_ref = $Definition.request_packet_ref
        response_or_result_packet_ref = $Definition.response_or_result_packet_ref
        secondary_result_packet_ref = if (Test-R17ToolCallLedgerHasProperty -Object $Definition -Name "secondary_result_packet_ref") { $Definition.secondary_result_packet_ref } else { "not_applicable" }
        board_event_ref = "not_implemented_seed"
        evidence_refs = $evidenceRefs
        authority_refs = $authorityRefs
        memory_packet_ref = $Definition.memory_packet_ref
        common_tool_adapter_contract_ref = "contracts/tools/r17_tool_adapter.contract.json"
        common_tool_adapter_seed_profile_ref = ("state/tools/r17_tool_adapter_seed_profiles.json#{0}" -f $Definition.adapter_id)
        agent_invocation_log_ref = $Definition.invocation_ref
        secret_policy = [pscustomobject]@{
            committed_secret_material_allowed = $false
            secrets_required_for_seed_foundation = $false
            external_api_keys_required = $false
            future_secret_gate_required_before_runtime = $true
            secret_scan_claimed = $false
        }
        cost_policy = [pscustomobject]@{
            cost_incurred = $false
            estimated_cost_usd = 0
            external_billing_claimed = $false
            future_cost_budget_required_before_runtime = $true
            provider_cost_known = $false
        }
        timeout_policy = [pscustomobject]@{
            timeout_runtime_implemented = $false
            max_seconds_seed = 0
            future_timeout_required_before_runtime = $true
            runaway_loop_control_implemented = $false
        }
        retry_policy = [pscustomobject]@{
            retry_runtime_implemented = $false
            max_retries_seed = 0
            future_retry_policy_required_before_runtime = $true
            repeated_failure_requires_user_decision = $true
        }
        execution_mode = "disabled_seed"
        status = "not_executed_disabled_foundation"
        error_ref = "none"
        runtime_flags = Get-R17ToolCallLedgerFalseFlags
        claim_status = Get-R17ToolCallLedgerClaimStatus
        non_claims = Get-R17ToolCallLedgerNonClaims
        rejected_claims = Get-R17ToolCallLedgerRejectedClaims
    }

    foreach ($field in $script:ExplicitFalseFields) {
        $record[$field] = $explicitFalse.PSObject.Properties[$field].Value
    }

    return [pscustomobject]$record
}

function New-R17ToolCallLedgerArtifactsObjectSet {
    param([Parameter(Mandatory = $true)][object]$GitIdentity)

    $contract = New-R17ToolCallLedgerContract
    $records = @(Get-R17ToolCallLedgerSeedDefinitions | ForEach-Object {
        New-R17ToolCallLedgerRecord -Definition $_ -GitIdentity $GitIdentity
    })

    $recordIds = @($records | ForEach-Object { $_.ledger_record_id })
    $adapterIds = @($records | ForEach-Object { $_.adapter_id })
    $runtimeFlags = Get-R17ToolCallLedgerFalseFlags
    $evidenceRefs = @(
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "state/runtime/r17_tool_call_ledger.jsonl",
        "state/runtime/r17_tool_call_ledger_check_report.json",
        "state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json",
        "tools/R17ToolCallLedger.psm1",
        "tools/new_r17_tool_call_ledger.ps1",
        "tools/validate_r17_tool_call_ledger.ps1",
        "tests/test_r17_tool_call_ledger.ps1",
        "tests/fixtures/r17_tool_call_ledger/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_019_tool_call_ledger/validation_manifest.md"
    )

    $report = [pscustomobject]@{
        artifact_type = "r17_tool_call_ledger_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-019-tool-call-ledger-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        contract_ref = "contracts/runtime/r17_tool_call_ledger.contract.json"
        ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        ui_snapshot_ref = "state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json"
        total_ledger_records = $records.Count
        ledger_record_ids = $recordIds
        adapter_ids = $adapterIds
        dependency_refs = Get-R17ToolCallLedgerDependencyRefs
        board_ref_summary = [pscustomobject]@{
            board_state_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"
            board_event_contract_ref = "contracts/board/r17_board_event.contract.json"
            board_event_ref_implemented = $false
            board_mutation_performed = $false
            runtime_card_creation_performed = $false
        }
        runtime_boundary_summary = $runtimeFlags
        explicit_false_fields = Get-R17ToolCallLedgerExplicitFalseMap
        claim_status = Get-R17ToolCallLedgerClaimStatus
        validation_summary = [pscustomobject]@{
            contract_fields_present = "passed"
            ledger_jsonl_present = "passed"
            seed_adapter_chain_present = "passed"
            disabled_statuses_only = "passed"
            explicit_false_fields_preserved = "passed"
            no_actual_tool_call = "passed"
            no_adapter_runtime_invocation = "passed"
            no_external_api_call = "passed"
            no_a2a_message = "passed"
            no_board_mutation = "passed"
            compact_invalid_fixture_coverage = "passed"
            wildcard_evidence_refs_rejected = "passed"
            local_backups_refs_rejected = "passed"
            broad_repo_scan_output_rejected = "passed"
            full_source_content_embedding_rejected = "passed"
            future_r17_020_plus_completion_claims_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = $evidenceRefs
        preserved_boundaries = Get-R17ToolCallLedgerPreservedBoundaries
        non_claims = Get-R17ToolCallLedgerNonClaims
        rejected_claims = Get-R17ToolCallLedgerRejectedClaims
    }

    $snapshot = [pscustomobject]@{
        artifact_type = "r17_tool_call_ledger_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-019-tool-call-ledger-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        check_report_ref = "state/runtime/r17_tool_call_ledger_check_report.json"
        total_ledger_records = $records.Count
        visible_records = @($records | ForEach-Object {
            [pscustomobject]@{
                ledger_record_id = $_.ledger_record_id
                adapter_id = $_.adapter_id
                adapter_type = $_.adapter_type
                target_agent_id = $_.target_agent_id
                request_packet_ref = $_.request_packet_ref
                response_or_result_packet_ref = $_.response_or_result_packet_ref
                execution_mode = $_.execution_mode
                status = $_.status
                ledger_runtime_implemented = $_.ledger_runtime_implemented
                tool_call_runtime_implemented = $_.tool_call_runtime_implemented
                actual_tool_call_performed = $_.actual_tool_call_performed
                adapter_runtime_invoked = $_.adapter_runtime_invoked
                external_api_call_performed = $_.external_api_call_performed
            }
        })
        status_summary = [pscustomobject]@{
            disabled_seed_records_only = $true
            ledger_runtime_implemented = $false
            tool_call_runtime_implemented = $false
            actual_tool_call_performed = $false
            adapter_runtime_invoked = $false
            codex_executor_invoked = $false
            qa_test_agent_invoked = $false
            evidence_auditor_api_invoked = $false
            external_api_call_performed = $false
            a2a_message_sent = $false
            board_mutation_performed = $false
            runtime_card_creation_performed = $false
            product_runtime_executed = $false
            audit_verdict_claimed = $false
            real_audit_verdict = $false
            external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
        }
        runtime_boundaries = $runtimeFlags
        claim_status = Get-R17ToolCallLedgerClaimStatus
        non_claims = Get-R17ToolCallLedgerNonClaims
        rejected_claims = Get-R17ToolCallLedgerRejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        Records = $records
        Report = $report
        Snapshot = $snapshot
    }
}

function New-R17ToolCallLedgerFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    Write-R17ToolCallLedgerJson -Path (Join-Path $FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17ToolCallLedgerJson -Path (Join-Path $FixtureRoot "valid_ledger_records.json") -Value $ObjectSet.Records
    Write-R17ToolCallLedgerJson -Path (Join-Path $FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17ToolCallLedgerJson -Path (Join-Path $FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $fixtures = @(
        @{ name = "invalid_actual_tool_call_true.json"; target = "record"; property = "actual_tool_call_performed"; value = $true; expected = @("actual_tool_call_performed") },
        @{ name = "invalid_tool_call_runtime_true.json"; target = "record"; property = "tool_call_runtime_implemented"; value = $true; expected = @("tool_call_runtime_implemented") },
        @{ name = "invalid_ledger_runtime_true.json"; target = "record"; property = "ledger_runtime_implemented"; value = $true; expected = @("ledger_runtime_implemented") },
        @{ name = "invalid_adapter_runtime_invoked_true.json"; target = "record"; property = "adapter_runtime_invoked"; value = $true; expected = @("adapter_runtime_invoked") },
        @{ name = "invalid_codex_executor_invoked_true.json"; target = "record"; property = "codex_executor_invoked"; value = $true; expected = @("codex_executor_invoked") },
        @{ name = "invalid_qa_test_agent_invoked_true.json"; target = "record"; property = "qa_test_agent_invoked"; value = $true; expected = @("qa_test_agent_invoked") },
        @{ name = "invalid_evidence_auditor_api_invoked_true.json"; target = "record"; property = "evidence_auditor_api_invoked"; value = $true; expected = @("evidence_auditor_api_invoked") },
        @{ name = "invalid_external_api_call_true.json"; target = "record"; property = "external_api_call_performed"; value = $true; expected = @("external_api_call_performed") },
        @{ name = "invalid_a2a_message_sent_true.json"; target = "record"; property = "a2a_message_sent"; value = $true; expected = @("a2a_message_sent") },
        @{ name = "invalid_board_mutation_true.json"; target = "record"; property = "board_mutation_performed"; value = $true; expected = @("board_mutation_performed") },
        @{ name = "invalid_runtime_card_creation_true.json"; target = "record"; property = "runtime_card_creation_performed"; value = $true; expected = @("runtime_card_creation_performed") },
        @{ name = "invalid_product_runtime_true.json"; target = "record"; property = "product_runtime_executed"; value = $true; expected = @("product_runtime_executed") },
        @{ name = "invalid_audit_verdict_claimed_true.json"; target = "record"; property = "audit_verdict_claimed"; value = $true; expected = @("audit_verdict_claimed") },
        @{ name = "invalid_real_audit_verdict_true.json"; target = "record"; property = "real_audit_verdict"; value = $true; expected = @("real_audit_verdict") },
        @{ name = "invalid_external_audit_acceptance_true.json"; target = "record"; property = "external_audit_acceptance_claimed"; value = $true; expected = @("external_audit_acceptance_claimed") },
        @{ name = "invalid_main_merge_true.json"; target = "record"; property = "main_merge_claimed"; value = $true; expected = @("main_merge_claimed") },
        @{ name = "invalid_runtime_flag_actual_tool_call_true.json"; target = "runtime_flag"; property = "actual_tool_call_performed"; value = $true; expected = @("actual_tool_call_performed") },
        @{ name = "invalid_status_succeeded.json"; target = "record"; property = "status"; value = "succeeded"; expected = @("status") },
        @{ name = "invalid_execution_mode_runtime.json"; target = "record"; property = "execution_mode"; value = "runtime_enabled"; expected = @("execution_mode") },
        @{ name = "invalid_wildcard_evidence_ref.json"; target = "evidence_append"; value = "state/**/*.json"; expected = @("wildcard") },
        @{ name = "invalid_local_backups_ref.json"; target = "evidence_append"; value = ".local_backups/r17_tool_call_ledger.json"; expected = @(".local_backups") },
        @{ name = "invalid_future_completion_claim.json"; target = "non_claim_append"; value = "R17-020 is done and implemented."; expected = @("future R17-020") },
        @{ name = "invalid_broad_repo_scan_output_flag.json"; target = "runtime_flag"; property = "broad_repo_scan_output_included"; value = $true; expected = @("broad_repo_scan_output_included") },
        @{ name = "invalid_full_source_contents_flag.json"; target = "runtime_flag"; property = "full_source_file_contents_embedded"; value = $true; expected = @("full_source_file_contents_embedded") },
        @{ name = "invalid_duplicate_record_id.json"; target = "duplicate_record"; expected = @("Duplicate ledger_record_id") },
        @{ name = "invalid_missing_required_field.json"; target = "remove_property"; property = "request_packet_ref"; expected = @("request_packet_ref") },
        @{ name = "invalid_unknown_adapter_id.json"; target = "record"; property = "adapter_id"; value = "unknown_adapter_future"; expected = @("unknown adapter_id") },
        @{ name = "invalid_fixture_coverage.json"; target = "fixture_coverage"; expected = @("compact invalid fixture") }
    )

    foreach ($fixture in $fixtures) {
        $value = [ordered]@{
            target = $fixture.target
            expected_failure_fragments = $fixture.expected
        }
        if ($fixture.ContainsKey("property")) {
            $value["property"] = $fixture.property
        }
        if ($fixture.ContainsKey("value")) {
            $value["value"] = $fixture.value
        }
        Write-R17ToolCallLedgerJson -Path (Join-Path $FixtureRoot $fixture.name) -Value ([pscustomobject]$value)
    }

    return $fixtures.Count
}

function New-R17ToolCallLedgerProofFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProofRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $ProofRoot -Force | Out-Null

    $proofReview = @"
# R17-019 Tool-Call Ledger Foundation Proof Review

## Scope
R17-019 creates a bounded tool-call ledger foundation only. The contract and generated JSONL ledger records define disabled/not-executed seed records for the Developer/Codex executor adapter, QA/Test Agent adapter, and Evidence Auditor API adapter chain without executing a tool call, invoking adapters, calling external APIs, sending A2A messages, mutating the board, or claiming product runtime.

## Artifacts
- contracts/runtime/r17_tool_call_ledger.contract.json
- state/runtime/r17_tool_call_ledger.jsonl
- state/runtime/r17_tool_call_ledger_check_report.json
- state/ui/r17_kanban_mvp/r17_tool_call_ledger_snapshot.json
- tools/R17ToolCallLedger.psm1
- tools/new_r17_tool_call_ledger.ps1
- tools/validate_r17_tool_call_ledger.ps1
- tests/test_r17_tool_call_ledger.ps1
- tests/fixtures/r17_tool_call_ledger/

## Verdict
Generated foundation candidate only: $script:AggregateVerdict.

## Non-Claims
No tool-call runtime, actual tool call, adapter runtime, Codex executor invocation, QA/Test Agent invocation, Evidence Auditor API invocation, external API call, real audit verdict, external audit acceptance, board mutation, A2A runtime, autonomous agents, product runtime, production runtime, main merge, R13 closure, R14 caveat removal, R15 caveat removal, solved Codex compaction, or solved Codex reliability is claimed.
"@

    $validationManifest = @"
# R17-019 Validation Manifest

Required focused validation:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1

Boundary:
- Generated ledger contract/check/UI/proof artifacts only.
- All ledger seed records remain disabled/not executed.
- No tool-call runtime or ledger runtime.
- No actual tool call.
- No adapter runtime invocation.
- No Codex executor, QA/Test Agent, or Evidence Auditor API invocation.
- No external API call.
- No real audit verdict or external audit acceptance.
- No board mutation, A2A runtime, autonomous agents, product runtime, main merge, or R17-020+ completion claim.
"@

    $validationRefs = @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_tool_call_ledger.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_call_ledger.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_call_ledger.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1"
    )

    $evidenceIndex = [pscustomobject]@{
        artifact_type = "r17_019_tool_call_ledger_evidence_index"
        source_task = $script:SourceTask
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = $ObjectSet.Report.evidence_refs
        validation_refs = $validationRefs
        non_claims = Get-R17ToolCallLedgerNonClaims
    }

    Write-R17ToolCallLedgerText -Path (Join-Path $ProofRoot "proof_review.md") -Value $proofReview
    Write-R17ToolCallLedgerText -Path (Join-Path $ProofRoot "validation_manifest.md") -Value $validationManifest
    Write-R17ToolCallLedgerJson -Path (Join-Path $ProofRoot "evidence_index.json") -Value $evidenceIndex
}

function New-R17ToolCallLedgerArtifacts {
    param([string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot))

    $paths = Get-R17ToolCallLedgerPaths -RepositoryRoot $RepositoryRoot
    $gitIdentity = Get-R17ToolCallLedgerGitIdentity -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17ToolCallLedgerArtifactsObjectSet -GitIdentity $gitIdentity

    Write-R17ToolCallLedgerJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17ToolCallLedgerJsonLines -Path $paths.Ledger -Records $objectSet.Records
    Write-R17ToolCallLedgerJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17ToolCallLedgerJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    $invalidFixtureCount = New-R17ToolCallLedgerFixtureFiles -FixtureRoot $paths.FixtureRoot -ObjectSet $objectSet
    New-R17ToolCallLedgerProofFiles -ProofRoot $paths.ProofRoot -ObjectSet $objectSet

    return [pscustomobject]@{
        Contract = $paths.Contract
        Ledger = $paths.Ledger
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        InvalidFixtureCount = $invalidFixtureCount
        LedgerRecordCount = $objectSet.Records.Count
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17ToolCallLedgerRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        if (-not (Test-R17ToolCallLedgerHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17ToolCallLedgerContains {
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

function Assert-R17ToolCallLedgerFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        $value = Get-R17ToolCallLedgerProperty -Object $Object -Name $field -Context $Context
        if ($value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Assert-R17ToolCallLedgerSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot),
        [switch]$SkipExistence
    )

    if ($Value -in @("none", "not_implemented_seed", "not_applicable", "disabled_seed", "placeholder_only")) {
        return
    }
    if ($Value -match '\*') {
        throw "$Context contains wildcard ref '$Value'."
    }
    if ($Value -match '(^|/|\\)\.local_backups(/|\\)') {
        throw "$Context contains .local_backups ref '$Value'."
    }
    if ($Value -match '^(https?|file)://') {
        throw "$Context contains non repo-relative URL ref '$Value'."
    }
    if ([System.IO.Path]::IsPathRooted($Value)) {
        throw "$Context contains absolute path '$Value'."
    }

    $pathPart = ($Value -split '#')[0]
    if ([string]::IsNullOrWhiteSpace($pathPart)) {
        throw "$Context contains empty ref path."
    }

    if (-not $SkipExistence) {
        $fullPath = Join-Path $RepositoryRoot $pathPart
        if (-not (Test-Path -LiteralPath $fullPath)) {
            throw "$Context ref does not exist: '$Value'."
        }
    }
}

function Assert-R17ToolCallLedgerNoForbiddenStrings {
    param(
        [Parameter(Mandatory = $true)][object]$Value,
        [string]$Context = "artifact"
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [string]) {
        if ($Value -match '(?i)\bR17-0?2[0-8]\b.{0,120}\b(done|complete|completed|implemented|executed|ran|exercised|working|ships)\b') {
            throw "$Context contains future R17-020+ completion claim."
        }
        if ($Value -match 'Set-StrictMode\s+-Version|function\s+[A-Za-z0-9_-]+\s*\{') {
            throw "$Context appears to embed full source file contents."
        }
        if ($Value.Length -gt 20000) {
            throw "$Context contains an oversized string that may embed source or scan output."
        }
        if ($Value -match '(?m)^Mode\s+LastWriteTime\s+Length\s+Name$|^Directory:\s+') {
            throw "$Context appears to embed broad repo scan output."
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        foreach ($item in $Value) {
            Assert-R17ToolCallLedgerNoForbiddenStrings -Value $item -Context $Context
        }
        return
    }

    foreach ($property in $Value.PSObject.Properties) {
        Assert-R17ToolCallLedgerNoForbiddenStrings -Value $property.Value -Context ("$Context.$($property.Name)")
    }
}

function Assert-R17ToolCallLedgerPolicy {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Record.secret_policy.committed_secret_material_allowed -ne $false -or $Record.secret_policy.external_api_keys_required -ne $false) {
        throw "$Context secret_policy must not allow committed secrets or require external API keys."
    }
    if ($Record.cost_policy.cost_incurred -ne $false -or [double]$Record.cost_policy.estimated_cost_usd -ne 0 -or $Record.cost_policy.external_billing_claimed -ne $false) {
        throw "$Context cost_policy must preserve zero cost and no billing claim."
    }
    if ($Record.timeout_policy.timeout_runtime_implemented -ne $false -or [int]$Record.timeout_policy.max_seconds_seed -ne 0) {
        throw "$Context timeout_policy must remain seed-only with no runtime timeout."
    }
    if ($Record.retry_policy.retry_runtime_implemented -ne $false -or [int]$Record.retry_policy.max_retries_seed -ne 0) {
        throw "$Context retry_policy must remain seed-only with no retry runtime."
    }
}

function Assert-R17ToolCallLedgerRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17ToolCallLedgerRequiredFields -Object $Record -Fields $script:RequiredRecordFields -Context "ledger record"
    Assert-R17ToolCallLedgerFalseFields -Object $Record -Fields $script:ExplicitFalseFields -Context ("ledger record '{0}'" -f $Record.ledger_record_id)
    Assert-R17ToolCallLedgerFalseFields -Object $Record.runtime_flags -Fields $script:RuntimeFalseFields -Context ("ledger record runtime_flags '{0}'" -f $Record.ledger_record_id)
    Assert-R17ToolCallLedgerFalseFields -Object $Record.claim_status -Fields $script:ClaimStatusFields -Context ("ledger record claim_status '{0}'" -f $Record.ledger_record_id)

    if ($Record.source_task -ne $script:SourceTask -or $Record.card_id -ne $script:SourceTask) {
        throw "ledger record '$($Record.ledger_record_id)' must be scoped to R17-019."
    }
    if ($script:SeedAdapterIds -notcontains [string]$Record.adapter_id) {
        throw "ledger record '$($Record.ledger_record_id)' has unknown adapter_id '$($Record.adapter_id)'."
    }
    if ($script:AllowedStatuses -notcontains [string]$Record.status) {
        throw "ledger record '$($Record.ledger_record_id)' has unsupported status '$($Record.status)'."
    }
    if ($script:AllowedStatuses -notcontains [string]$Record.execution_mode) {
        throw "ledger record '$($Record.ledger_record_id)' has unsupported execution_mode '$($Record.execution_mode)'."
    }

    Assert-R17ToolCallLedgerPolicy -Record $Record -Context ("ledger record '$($Record.ledger_record_id)'")

    foreach ($pathValue in @($Record.invocation_ref, $Record.request_packet_ref, $Record.response_or_result_packet_ref, $Record.secondary_result_packet_ref, $Record.board_event_ref, $Record.memory_packet_ref, $Record.common_tool_adapter_contract_ref, $Record.common_tool_adapter_seed_profile_ref, $Record.agent_invocation_log_ref)) {
        Assert-R17ToolCallLedgerSafeRefPath -Value ([string]$pathValue) -Context ("ledger record '$($Record.ledger_record_id)' ref") -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    }
    foreach ($pathValue in @($Record.evidence_refs)) {
        Assert-R17ToolCallLedgerSafeRefPath -Value ([string]$pathValue) -Context ("ledger record '$($Record.ledger_record_id)' evidence_refs") -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    }
    foreach ($pathValue in @($Record.authority_refs)) {
        Assert-R17ToolCallLedgerSafeRefPath -Value ([string]$pathValue) -Context ("ledger record '$($Record.ledger_record_id)' authority_refs") -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    }

    Assert-R17ToolCallLedgerContains -Values @($Record.non_claims) -Required @(
        "R17-019 does not implement a tool-call runtime",
        "R17-019 does not perform actual tool calls",
        "R17-019 does not invoke adapter runtime",
        "R17-019 does not invoke Codex executor",
        "R17-019 does not invoke QA/Test Agent",
        "R17-019 does not invoke Evidence Auditor API",
        "R17-019 does not call external APIs",
        "R17-019 does not send A2A messages",
        "R17-019 does not mutate the board live",
        "R17-020 through R17-028 remain planned only"
    ) -Context ("ledger record '$($Record.ledger_record_id)' non_claims")
    Assert-R17ToolCallLedgerContains -Values @($Record.rejected_claims) -Required @(
        "tool_call_runtime",
        "ledger_runtime",
        "actual_tool_call",
        "adapter_runtime_invocation",
        "Codex_executor_invocation",
        "QA_Test_Agent_invocation",
        "Evidence_Auditor_API_invocation",
        "external_API_calls",
        "A2A_runtime",
        "main_merge",
        "R17_020_or_later_implementation"
    ) -Context ("ledger record '$($Record.ledger_record_id)' rejected_claims")

    Assert-R17ToolCallLedgerNoForbiddenStrings -Value $Record -Context ("ledger record '$($Record.ledger_record_id)'")
}

function Assert-R17ToolCallLedgerFixtureCoverage {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [int]$MinimumInvalidFixtureCount = $script:MinimumInvalidFixtureCount
    )

    if (-not (Test-Path -LiteralPath $FixtureRoot)) {
        throw "Fixture root '$FixtureRoot' does not exist."
    }
    $fixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json")
    if ($fixtures.Count -lt $MinimumInvalidFixtureCount) {
        throw "Expected at least $MinimumInvalidFixtureCount compact invalid fixture files."
    }
}

function Assert-R17ToolCallLedgerKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot))

    $changedPaths = @(& git -C $RepositoryRoot diff --name-only)
    if ($changedPaths -contains "scripts/operator_wall/r17_kanban_mvp/kanban.js") {
        throw "R17-019 must not modify scripts/operator_wall/r17_kanban_mvp/kanban.js."
    }
}

function Test-R17ToolCallLedgerSet {
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object[]]$Records,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot),
        [switch]$SkipFixtureCoverage,
        [switch]$SkipRefExistence,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17ToolCallLedgerRequiredFields -Object $Contract -Fields @("artifact_type", "contract_version", "contract_id", "source_task", "required_ledger_record_fields", "allowed_statuses", "required_explicit_false_fields", "implementation_boundaries", "claim_status", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.source_task -ne $script:SourceTask) {
        throw "contract source_task must be R17-019."
    }
    Assert-R17ToolCallLedgerContains -Values @($Contract.required_ledger_record_fields) -Required $script:RequiredRecordFields -Context "contract required_ledger_record_fields"
    Assert-R17ToolCallLedgerContains -Values @($Contract.allowed_statuses) -Required $script:AllowedStatuses -Context "contract allowed_statuses"
    Assert-R17ToolCallLedgerContains -Values @($Contract.required_explicit_false_fields) -Required $script:ExplicitFalseFields -Context "contract required_explicit_false_fields"
    Assert-R17ToolCallLedgerFalseFields -Object $Contract.implementation_boundaries -Fields $script:RuntimeFalseFields -Context "contract implementation_boundaries"
    Assert-R17ToolCallLedgerFalseFields -Object $Contract.claim_status -Fields $script:ClaimStatusFields -Context "contract claim_status"

    if ($Records.Count -ne 3) {
        throw "tool-call ledger must contain exactly 3 disabled seed records."
    }

    $seen = @{}
    foreach ($record in $Records) {
        Assert-R17ToolCallLedgerRecord -Record $record -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        if ($seen.ContainsKey([string]$record.ledger_record_id)) {
            throw "Duplicate ledger_record_id '$($record.ledger_record_id)'."
        }
        $seen[[string]$record.ledger_record_id] = $true
    }

    $recordAdapterIds = @($Records | ForEach-Object { [string]$_.adapter_id })
    foreach ($adapterId in $script:SeedAdapterIds) {
        if ($recordAdapterIds -notcontains $adapterId) {
            throw "tool-call ledger missing seed adapter '$adapterId'."
        }
    }

    Assert-R17ToolCallLedgerRequiredFields -Object $Report -Fields $script:RequiredReportFields -Context "check report"
    if ($Report.source_task -ne $script:SourceTask -or $Report.active_through_task -ne $script:SourceTask) {
        throw "check report must keep R17 active through R17-019."
    }
    if ([int]$Report.total_ledger_records -ne 3) {
        throw "check report total_ledger_records must be 3."
    }
    Assert-R17ToolCallLedgerContains -Values @($Report.ledger_record_ids) -Required @($Records | ForEach-Object { $_.ledger_record_id }) -Context "check report ledger_record_ids"
    Assert-R17ToolCallLedgerContains -Values @($Report.adapter_ids) -Required $script:SeedAdapterIds -Context "check report adapter_ids"
    Assert-R17ToolCallLedgerFalseFields -Object $Report.runtime_boundary_summary -Fields $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17ToolCallLedgerFalseFields -Object $Report.explicit_false_fields -Fields $script:ExplicitFalseFields -Context "check report explicit_false_fields"
    Assert-R17ToolCallLedgerFalseFields -Object $Report.claim_status -Fields $script:ClaimStatusFields -Context "check report claim_status"
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "check report aggregate_verdict is incorrect."
    }

    Assert-R17ToolCallLedgerRequiredFields -Object $Snapshot -Fields @("artifact_type", "source_task", "active_through_task", "ledger_ref", "check_report_ref", "total_ledger_records", "visible_records", "status_summary", "runtime_boundaries", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.source_task -ne $script:SourceTask -or $Snapshot.active_through_task -ne $script:SourceTask) {
        throw "UI snapshot must keep R17 active through R17-019."
    }
    if ([int]$Snapshot.total_ledger_records -ne 3 -or @($Snapshot.visible_records).Count -ne 3) {
        throw "UI snapshot must expose exactly 3 read-only ledger records."
    }
    Assert-R17ToolCallLedgerFalseFields -Object $Snapshot.status_summary -Fields $script:ExplicitFalseFields -Context "UI snapshot status_summary"
    Assert-R17ToolCallLedgerFalseFields -Object $Snapshot.runtime_boundaries -Fields $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"

    Assert-R17ToolCallLedgerNoForbiddenStrings -Value $Contract -Context "contract"
    Assert-R17ToolCallLedgerNoForbiddenStrings -Value $Report -Context "check report"
    Assert-R17ToolCallLedgerNoForbiddenStrings -Value $Snapshot -Context "UI snapshot"

    if (-not $SkipFixtureCoverage) {
        $paths = Get-R17ToolCallLedgerPaths -RepositoryRoot $RepositoryRoot
        Assert-R17ToolCallLedgerFixtureCoverage -FixtureRoot $paths.FixtureRoot
    }
    if (-not $SkipKanbanJsCheck) {
        Assert-R17ToolCallLedgerKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        LedgerRecordCount = $Records.Count
        AdapterIds = $recordAdapterIds
        LedgerRuntimeImplemented = $false
        ToolCallRuntimeImplemented = $false
        ActualToolCallPerformed = $false
        AdapterRuntimeInvoked = $false
        CodexExecutorInvoked = $false
        QaTestAgentInvoked = $false
        EvidenceAuditorApiInvoked = $false
        ExternalApiCallPerformed = $false
        A2aMessageSent = $false
        BoardMutationPerformed = $false
        ProductRuntimeExecuted = $false
        RealAuditVerdict = $false
        MainMergeClaimed = $false
    }
}

function Test-R17ToolCallLedger {
    param([string]$RepositoryRoot = (Get-R17ToolCallLedgerRepositoryRoot))

    $paths = Get-R17ToolCallLedgerPaths -RepositoryRoot $RepositoryRoot
    $contract = Read-R17ToolCallLedgerJson -Path $paths.Contract
    $records = @(Read-R17ToolCallLedgerJsonLines -Path $paths.Ledger)
    $report = Read-R17ToolCallLedgerJson -Path $paths.CheckReport
    $snapshot = Read-R17ToolCallLedgerJson -Path $paths.UiSnapshot

    return Test-R17ToolCallLedgerSet -Contract $contract -Records $records -Report $report -Snapshot $snapshot -RepositoryRoot $RepositoryRoot
}

function Set-R17ToolCallLedgerObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17ToolCallLedgerProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    if (-not (Test-R17ToolCallLedgerHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R17ToolCallLedgerObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17ToolCallLedgerProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    $property = $current.PSObject.Properties[$leaf]
    if ($null -ne $property) {
        $current.PSObject.Properties.Remove($leaf)
    }
}
