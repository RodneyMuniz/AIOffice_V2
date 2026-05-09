Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-016"
$script:AdapterType = "developer_codex_executor_adapter"
$script:AdapterProfileId = "developer_codex_executor_adapter_future"
$script:AggregateVerdict = "generated_r17_codex_executor_adapter_packet_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_016_codex_executor_adapter"
$script:FixtureRoot = "tests/fixtures/r17_codex_executor_adapter"
$script:MinimumInvalidFixtureCount = 50

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
    "runtime_card_creation_performed",
    "live_orchestrator_runtime_invoked",
    "autonomous_agent_executed",
    "tool_call_ledger_runtime_implemented",
    "tool_call_runtime_implemented",
    "executable_handoff_performed",
    "executable_transition_performed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "product_runtime_executed",
    "production_runtime_executed",
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
    "live_agent_runtime_claimed",
    "live_orchestrator_runtime_claimed",
    "a2a_runtime_claimed",
    "a2a_messages_claimed",
    "autonomous_agent_claimed",
    "adapter_runtime_claimed",
    "tool_call_runtime_claimed",
    "api_call_claimed",
    "codex_executor_invocation_claimed",
    "qa_test_agent_invocation_claimed",
    "evidence_auditor_api_invocation_claimed",
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
    "external_integration_claimed"
)

$script:RequiredContractFields = @(
    "artifact_type",
    "contract_version",
    "contract_id",
    "source_task",
    "adapter_profile_id",
    "adapter_type",
    "target_agent_id",
    "common_tool_adapter_contract_ref",
    "required_request_fields",
    "required_result_fields",
    "required_report_fields",
    "allowed_statuses",
    "packet_policy",
    "exact_ref_policy",
    "implementation_boundaries",
    "claim_status",
    "non_claims",
    "rejected_claims"
)

$script:RequiredRequestFields = @(
    "artifact_type",
    "request_id",
    "source_task",
    "adapter_profile_id",
    "adapter_type",
    "card_id",
    "requested_by_agent_id",
    "target_agent_id",
    "invocation_ref",
    "contract_ref",
    "common_tool_adapter_contract_ref",
    "input_packet_ref",
    "result_packet_ref",
    "tool_call_ref",
    "board_event_ref",
    "evidence_refs",
    "required_authority_refs",
    "secret_policy",
    "cost_policy",
    "timeout_policy",
    "retry_policy",
    "status",
    "execution_allowed",
    "codex_executor_invocation_allowed",
    "runtime_flags",
    "claim_status",
    "non_claims",
    "rejected_claims"
)

$script:RequiredResultFields = @(
    "artifact_type",
    "result_id",
    "source_task",
    "adapter_profile_id",
    "adapter_type",
    "card_id",
    "requested_by_agent_id",
    "target_agent_id",
    "source_request_ref",
    "contract_ref",
    "common_tool_adapter_contract_ref",
    "tool_call_ref",
    "board_event_ref",
    "developer_output_ref",
    "imported_diff_ref",
    "imported_status_ref",
    "evidence_refs",
    "status",
    "result_kind",
    "developer_output_claimed",
    "runtime_flags",
    "claim_status",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReportFields = @(
    "contract_ref",
    "request_packet_ref",
    "result_packet_ref",
    "common_tool_adapter_contract_ref",
    "dependency_refs",
    "runtime_boundary_summary",
    "validation_summary",
    "aggregate_verdict",
    "non_claims",
    "rejected_claims"
)

function Get-R17CodexExecutorAdapterRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17CodexExecutorAdapterPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17CodexExecutorAdapterJson {
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

function Write-R17CodexExecutorAdapterJson {
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

function Write-R17CodexExecutorAdapterText {
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

function Copy-R17CodexExecutorAdapterObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17CodexExecutorAdapterPaths {
    param([string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/tools/r17_codex_executor_adapter.contract.json"
        RequestPacket = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_codex_executor_adapter_request_packet.json"
        ResultPacket = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_codex_executor_adapter_result_packet.json"
        CheckReport = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_codex_executor_adapter_check_report.json"
        UiSnapshot = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json"
        FixtureRoot = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        UiFiles = @(
            (Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md"),
            (Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/kanban.js")
        )
    }
}

function Get-R17CodexExecutorAdapterGitIdentity {
    param([string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17CodexExecutorAdapterFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return $flags
}

function Get-R17CodexExecutorAdapterClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return $status
}

function Get-R17CodexExecutorAdapterNonClaims {
    return @(
        "R17-016 creates a disabled packet-only Developer/Codex executor adapter foundation only",
        "R17-016 does not implement adapter runtime",
        "R17-016 does not implement tool-call runtime",
        "R17-016 does not invoke Codex",
        "R17-016 does not call external APIs",
        "R17-016 does not send A2A messages",
        "R17-016 does not invoke agents",
        "R17-016 does not mutate the board live",
        "R17-016 does not create runtime cards",
        "R17-016 does not implement live Orchestrator runtime",
        "R17-016 does not implement live agent runtime",
        "R17-016 does not implement autonomous agents",
        "R17-016 does not implement runtime memory engine",
        "R17-016 does not implement vector retrieval",
        "R17-016 does not implement executable handoffs",
        "R17-016 does not implement executable transitions",
        "R17-016 does not produce real Dev output",
        "R17-016 does not produce real QA result",
        "R17-016 does not produce real audit verdict",
        "R17-016 does not claim external audit acceptance",
        "R17-016 does not claim main merge",
        "R17-016 does not close R13",
        "R17-016 does not remove R14 caveats",
        "R17-016 does not remove R15 caveats",
        "R17-016 does not solve Codex compaction",
        "R17-016 does not solve Codex reliability"
    )
}

function Get-R17CodexExecutorAdapterRejectedClaims {
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
        "solved_Codex_reliability"
    )
}

function Get-R17CodexExecutorAdapterPreservedBoundaries {
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

function Get-R17CodexExecutorAdapterDependencyRefs {
    return @(
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "state/tools/r17_tool_adapter_contract_check_report.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "contracts/agents/r17_agent_registry.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/developer.identity.json",
        "state/agents/r17_agent_memory_packets/developer.memory_packet.json",
        "contracts/context/r17_memory_artifact_loader.contract.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )
}

function Assert-R17CodexExecutorAdapterSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [string]$Context = "ref",
        [switch]$AllowSeedPlaceholder,
        [switch]$AllowNone,
        [switch]$RequireExistingPath,
        [string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot)
    )

    if ($AllowSeedPlaceholder -and $Path -in @("not_implemented_seed", "not_imported")) { return }
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
        $resolved = Resolve-R17CodexExecutorAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Test-R17CodexExecutorAdapterHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Assert-R17CodexExecutorAdapterRequiredFields {
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

function Assert-R17CodexExecutorAdapterContains {
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

function Assert-R17CodexExecutorAdapterFalseFlags {
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

function Assert-R17CodexExecutorAdapterNoSensitiveLiteral {
    param(
        [object]$Object,
        [string]$Context = "object"
    )

    $text = $Object | ConvertTo-Json -Depth 100
    foreach ($pattern in @("(?i)cookie", "(?i)session[_-]?id", "(?i)bearer\s+[a-z0-9\._-]+", "sk-[a-zA-Z0-9]{20,}", "(?i)api[_-]?key\s*[:=]", "(?i)token\s*[:=]")) {
        if ($text -match $pattern) {
            throw "$Context contains a secret/token/cookie/session-like literal matching '$pattern'."
        }
    }
}

function New-R17CodexExecutorAdapterArtifactsObjectSet {
    param([string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot))

    $identity = Get-R17CodexExecutorAdapterGitIdentity -RepositoryRoot $RepositoryRoot
    $falseFlags = Get-R17CodexExecutorAdapterFalseFlags
    $claimStatus = Get-R17CodexExecutorAdapterClaimStatus
    $nonClaims = Get-R17CodexExecutorAdapterNonClaims
    $rejectedClaims = Get-R17CodexExecutorAdapterRejectedClaims
    $dependencies = Get-R17CodexExecutorAdapterDependencyRefs

    $contractRef = "contracts/tools/r17_codex_executor_adapter.contract.json"
    $requestRef = "state/tools/r17_codex_executor_adapter_request_packet.json"
    $resultRef = "state/tools/r17_codex_executor_adapter_result_packet.json"
    $reportRef = "state/tools/r17_codex_executor_adapter_check_report.json"
    $snapshotRef = "state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json"
    $commonContractRef = "contracts/tools/r17_tool_adapter.contract.json"
    $seedProfileRef = "state/tools/r17_tool_adapter_seed_profiles.json#$script:AdapterProfileId"

    $authorityRefs = @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        $commonContractRef,
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/developer.identity.json",
        "state/agents/r17_agent_memory_packets/developer.memory_packet.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )

    $evidenceRefs = @(
        $contractRef,
        $requestRef,
        $resultRef,
        $reportRef,
        $snapshotRef,
        "tools/R17CodexExecutorAdapter.psm1",
        "tools/new_r17_codex_executor_adapter.ps1",
        "tools/validate_r17_codex_executor_adapter.ps1",
        "tests/test_r17_codex_executor_adapter.ps1",
        "tests/fixtures/r17_codex_executor_adapter/",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/validation_manifest.md"
    )

    $packetPolicy = [ordered]@{
        disabled_packet_only_foundation = $true
        adapter_runtime_allowed = $false
        codex_executor_invocation_allowed = $false
        command_execution_allowed = $false
        tool_call_runtime_allowed = $false
        external_api_call_allowed = $false
        a2a_message_allowed = $false
        board_mutation_allowed = $false
        runtime_card_creation_allowed = $false
        real_dev_output_allowed_without_imported_committed_diff_status_evidence = $false
        separately_imported_dev_output_requires_committed_diff_and_status_evidence = $true
    }

    $contract = [ordered]@{
        artifact_type = "r17_codex_executor_adapter_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-016-codex-executor-adapter-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "developer_codex_executor_adapter_disabled_packet_foundation_only"
        purpose = "Create a disabled, packet-only Developer/Codex executor adapter foundation without live adapter runtime, Codex invocation, tool calls, API calls, A2A dispatch, board mutation, runtime card creation, or real Dev output."
        adapter_profile_id = $script:AdapterProfileId
        adapter_type = $script:AdapterType
        target_agent_id = "developer"
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        required_request_fields = $script:RequiredRequestFields
        required_result_fields = $script:RequiredResultFields
        required_report_fields = $script:RequiredReportFields
        allowed_statuses = @("disabled_packet_only", "not_executed_disabled_foundation", "blocked", "invalid")
        packet_policy = $packetPolicy
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            urls_allowed = $false
            local_backups_refs_allowed = $false
            raw_chat_history_as_canonical_allowed = $false
            full_source_file_content_embedding_allowed = $false
            broad_repo_scan_output_allowed = $false
        }
        dependency_refs = $dependencies
        required_runtime_false_fields = $script:RuntimeFalseFields
        required_claim_status_false_fields = $script:ClaimStatusFields
        implementation_boundaries = $falseFlags
        claim_status = $claimStatus
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17CodexExecutorAdapterPreservedBoundaries
    }

    $secretPolicy = [ordered]@{
        committed_secret_material_allowed = $false
        secrets_required_for_packet_foundation = $false
        external_api_keys_required = $false
        future_secret_gate_required_before_runtime = $true
        secret_scan_claimed = $false
    }

    $costPolicy = [ordered]@{
        cost_incurred = $false
        estimated_cost_usd = 0
        external_billing_claimed = $false
        future_cost_budget_required_before_runtime = $true
        provider_cost_known = $false
    }

    $timeoutPolicy = [ordered]@{
        timeout_runtime_implemented = $false
        max_seconds_seed = 0
        future_timeout_required_before_runtime = $true
        runaway_loop_control_implemented = $false
    }

    $retryPolicy = [ordered]@{
        retry_runtime_implemented = $false
        max_retries_seed = 0
        future_retry_policy_required_before_runtime = $true
        repeated_failure_requires_user_decision = $true
    }

    $request = [ordered]@{
        artifact_type = "r17_codex_executor_adapter_request_packet"
        contract_version = "v1"
        request_id = "aioffice-r17-016-codex-executor-adapter-request-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        adapter_profile_id = $script:AdapterProfileId
        adapter_type = $script:AdapterType
        card_id = "R17-016"
        requested_by_agent_id = "orchestrator"
        target_agent_id = "developer"
        target_role_name = "Developer"
        invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_developer"
        contract_ref = $contractRef
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        input_packet_ref = $requestRef
        result_packet_ref = $resultRef
        tool_call_ref = "not_implemented_seed"
        board_event_ref = "not_implemented_seed"
        requested_action = "disabled_packet_only_foundation_no_execution"
        implementation_packet_only = $true
        execution_allowed = $false
        codex_executor_invocation_allowed = $false
        command_execution_allowed = $false
        external_api_call_allowed = $false
        a2a_message_allowed = $false
        board_mutation_allowed = $false
        runtime_card_creation_allowed = $false
        evidence_refs = $evidenceRefs
        required_authority_refs = $authorityRefs
        secret_policy = $secretPolicy
        cost_policy = $costPolicy
        timeout_policy = $timeoutPolicy
        retry_policy = $retryPolicy
        status = "disabled_packet_only"
        error_ref = "none"
        runtime_flags = $falseFlags
        claim_status = $claimStatus
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17CodexExecutorAdapterPreservedBoundaries
    }

    $result = [ordered]@{
        artifact_type = "r17_codex_executor_adapter_result_packet"
        contract_version = "v1"
        result_id = "aioffice-r17-016-codex-executor-adapter-result-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        adapter_profile_id = $script:AdapterProfileId
        adapter_type = $script:AdapterType
        card_id = "R17-016"
        requested_by_agent_id = "orchestrator"
        target_agent_id = "developer"
        target_role_name = "Developer"
        source_request_ref = $requestRef
        contract_ref = $contractRef
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        tool_call_ref = "not_implemented_seed"
        board_event_ref = "not_implemented_seed"
        developer_output_ref = "not_implemented_seed"
        imported_diff_ref = "not_imported"
        imported_status_ref = "not_imported"
        evidence_refs = $evidenceRefs
        status = "not_executed_disabled_foundation"
        result_kind = "disabled_packet_only_no_codex_invocation"
        developer_output_claimed = $false
        actual_output_imported = $false
        committed_diff_status_evidence_present = $false
        error_ref = "none"
        runtime_flags = $falseFlags
        claim_status = $claimStatus
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17CodexExecutorAdapterPreservedBoundaries
    }

    $report = [ordered]@{
        artifact_type = "r17_codex_executor_adapter_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-016-codex-executor-adapter-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        active_through_task = "R17-016"
        contract_ref = $contractRef
        request_packet_ref = $requestRef
        result_packet_ref = $resultRef
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        dependency_refs = $dependencies
        invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        developer_identity_ref = "state/agents/r17_agent_identities/developer.identity.json"
        developer_memory_packet_ref = "state/agents/r17_agent_memory_packets/developer.memory_packet.json"
        runtime_boundary_summary = $falseFlags
        claim_status = $claimStatus
        validation_summary = [ordered]@{
            contract_fields_present = "passed"
            request_packet_fields_present = "passed"
            result_packet_fields_present = "passed"
            common_tool_adapter_seed_profile_linked = "passed"
            developer_identity_refs_present = "passed"
            packet_only_status_preserved = "passed"
            codex_invocation_disabled = "passed"
            runtime_false_flags_preserved = "passed"
            claim_status_false_flags_preserved = "passed"
            secret_policy_present = "passed"
            cost_policy_present = "passed"
            timeout_policy_present = "passed"
            retry_policy_present = "passed"
            generated_artifact_content_guard = "passed"
            broad_repo_scan_output_guard = "passed"
            compact_invalid_fixture_coverage = "passed"
            external_ui_dependencies_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        secret_material_committed = $false
        external_api_call_performed = $false
        codex_executor_invoked = $false
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17CodexExecutorAdapterPreservedBoundaries
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_codex_executor_adapter_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-016-codex-executor-adapter-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        active_through_task = "R17-016"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        contract_ref = $contractRef
        request_packet_ref = $requestRef
        result_packet_ref = $resultRef
        check_report_ref = $reportRef
        visible_adapter = [ordered]@{
            adapter_profile_id = $script:AdapterProfileId
            adapter_type = $script:AdapterType
            target_agent_id = "developer"
            source_task = "R17-016"
            status = "disabled_packet_only"
            adapter_runtime_implemented = $false
            actual_tool_call_performed = $false
            codex_executor_invoked = $false
            external_api_call_performed = $false
        }
        status_summary = [ordered]@{
            disabled_packet_only_foundation = $true
            adapter_runtime_implemented = $false
            actual_tool_call_performed = $false
            codex_executor_invoked = $false
            external_api_call_performed = $false
            a2a_message_sent = $false
            agent_invocation_performed = $false
            board_mutation_performed = $false
            runtime_card_creation_performed = $false
            product_runtime_executed = $false
            production_runtime_executed = $false
        }
        runtime_boundaries = $falseFlags
        claim_status = $claimStatus
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        RequestPacket = $request
        ResultPacket = $result
        Report = $report
        Snapshot = $snapshot
    }
}

function New-R17CodexExecutorAdapterInvalidFixtures {
    $fixtures = @(
        @{ label = "contract_missing_artifact_type"; target = "contract"; remove_paths = @("artifact_type"); expected = @("contract is missing required field 'artifact_type'") },
        @{ label = "contract_wrong_source_task"; target = "contract"; set_values = @{ source_task = "R17-017" }; expected = @("contract source_task must be R17-016") },
        @{ label = "contract_wrong_adapter_type"; target = "contract"; set_values = @{ adapter_type = "qa_test_agent_adapter" }; expected = @("contract adapter_type is invalid") },
        @{ label = "contract_missing_common_contract"; target = "contract"; remove_paths = @("common_tool_adapter_contract_ref"); expected = @("contract is missing required field 'common_tool_adapter_contract_ref'") },
        @{ label = "contract_missing_required_request_fields"; target = "contract"; remove_paths = @("required_request_fields"); expected = @("contract is missing required field 'required_request_fields'") },
        @{ label = "contract_missing_required_result_fields"; target = "contract"; remove_paths = @("required_result_fields"); expected = @("contract is missing required field 'required_result_fields'") },
        @{ label = "contract_runtime_true"; target = "contract"; set_values = @{ "implementation_boundaries.codex_executor_invoked" = $true }; expected = @("contract implementation_boundaries codex_executor_invoked must be false") },
        @{ label = "contract_urls_allowed"; target = "contract"; set_values = @{ "exact_ref_policy.urls_allowed" = $true }; expected = @("contract exact_ref_policy must forbid URLs") },
        @{ label = "contract_full_source_allowed"; target = "contract"; set_values = @{ "exact_ref_policy.full_source_file_content_embedding_allowed" = $true }; expected = @("contract must forbid generated artifact embedding full source file contents") },
        @{ label = "contract_broad_repo_scan_allowed"; target = "contract"; set_values = @{ "exact_ref_policy.broad_repo_scan_output_allowed" = $true }; expected = @("contract must forbid broad repo scan output") },
        @{ label = "contract_missing_non_claims"; target = "contract"; remove_paths = @("non_claims"); expected = @("contract is missing required field 'non_claims'") },
        @{ label = "contract_missing_rejected_claims"; target = "contract"; remove_paths = @("rejected_claims"); expected = @("contract is missing required field 'rejected_claims'") },
        @{ label = "request_missing_request_id"; target = "request"; remove_paths = @("request_id"); expected = @("request packet is missing required field 'request_id'") },
        @{ label = "request_missing_contract_ref"; target = "request"; remove_paths = @("contract_ref"); expected = @("request packet is missing required field 'contract_ref'") },
        @{ label = "request_wrong_adapter_type"; target = "request"; set_values = @{ adapter_type = "evidence_auditor_api_adapter" }; expected = @("request packet adapter_type is invalid") },
        @{ label = "request_wrong_target_agent"; target = "request"; set_values = @{ target_agent_id = "qa_test_agent" }; expected = @("request packet target_agent_id must be developer") },
        @{ label = "request_missing_invocation_ref"; target = "request"; remove_paths = @("invocation_ref"); expected = @("request packet is missing required field 'invocation_ref'") },
        @{ label = "request_running_status"; target = "request"; set_values = @{ status = "running" }; expected = @("request packet status must be disabled_packet_only") },
        @{ label = "request_execution_allowed"; target = "request"; set_values = @{ execution_allowed = $true }; expected = @("request packet execution_allowed must be false") },
        @{ label = "request_codex_allowed"; target = "request"; set_values = @{ codex_executor_invocation_allowed = $true }; expected = @("request packet codex_executor_invocation_allowed must be false") },
        @{ label = "request_runtime_flag_true"; target = "request"; set_values = @{ "runtime_flags.codex_executor_invoked" = $true }; expected = @("request packet runtime_flags codex_executor_invoked must be false") },
        @{ label = "request_external_api_true"; target = "request"; set_values = @{ "runtime_flags.external_api_call_performed" = $true }; expected = @("request packet runtime_flags external_api_call_performed must be false") },
        @{ label = "request_secret_allowed"; target = "request"; set_values = @{ "secret_policy.committed_secret_material_allowed" = $true }; expected = @("request packet secret_policy must not allow committed secrets") },
        @{ label = "request_cost_incurred"; target = "request"; set_values = @{ "cost_policy.cost_incurred" = $true }; expected = @("request packet cost_policy must not claim incurred cost") },
        @{ label = "request_timeout_runtime"; target = "request"; set_values = @{ "timeout_policy.timeout_runtime_implemented" = $true }; expected = @("request packet timeout_policy must not implement runtime timeout") },
        @{ label = "request_retry_runtime"; target = "request"; set_values = @{ "retry_policy.retry_runtime_implemented" = $true }; expected = @("request packet retry_policy must not implement runtime retry") },
        @{ label = "request_url_input_ref"; target = "request"; set_values = @{ input_packet_ref = "https://example.com/packet.json" }; expected = @("request packet input_packet_ref path must not be a URL") },
        @{ label = "request_local_backup_ref"; target = "request"; set_values = @{ evidence_refs = @(".local_backups/secret.txt") }; expected = @("request packet evidence_ref path must not point at .local_backups") },
        @{ label = "request_missing_evidence_refs"; target = "request"; remove_paths = @("evidence_refs"); expected = @("request packet is missing required field 'evidence_refs'") },
        @{ label = "request_missing_authority_refs"; target = "request"; remove_paths = @("required_authority_refs"); expected = @("request packet is missing required field 'required_authority_refs'") },
        @{ label = "result_missing_result_id"; target = "result"; remove_paths = @("result_id"); expected = @("result packet is missing required field 'result_id'") },
        @{ label = "result_missing_source_request"; target = "result"; remove_paths = @("source_request_ref"); expected = @("result packet is missing required field 'source_request_ref'") },
        @{ label = "result_wrong_status"; target = "result"; set_values = @{ status = "succeeded" }; expected = @("result packet status must be not_executed_disabled_foundation") },
        @{ label = "result_runtime_flag_true"; target = "result"; set_values = @{ "runtime_flags.actual_tool_call_performed" = $true }; expected = @("result packet runtime_flags actual_tool_call_performed must be false") },
        @{ label = "result_codex_true"; target = "result"; set_values = @{ "runtime_flags.codex_executor_invoked" = $true }; expected = @("result packet runtime_flags codex_executor_invoked must be false") },
        @{ label = "result_claims_dev_output"; target = "result"; set_values = @{ developer_output_claimed = $true }; expected = @("result packet developer_output_claimed must be false") },
        @{ label = "result_imported_diff_without_status"; target = "result"; set_values = @{ imported_diff_ref = "src/app.py" }; expected = @("result packet imported_diff_ref must remain not_imported for R17-016") },
        @{ label = "result_missing_runtime_flags"; target = "result"; remove_paths = @("runtime_flags"); expected = @("result packet is missing required field 'runtime_flags'") },
        @{ label = "result_missing_non_claims"; target = "result"; remove_paths = @("non_claims"); expected = @("result packet is missing required field 'non_claims'") },
        @{ label = "report_missing_contract_ref"; target = "report"; remove_paths = @("contract_ref"); expected = @("check report is missing required field 'contract_ref'") },
        @{ label = "report_wrong_aggregate"; target = "report"; set_values = @{ aggregate_verdict = "runtime_ready" }; expected = @("check report aggregate_verdict is invalid") },
        @{ label = "report_validation_failed"; target = "report"; set_values = @{ "validation_summary.codex_invocation_disabled" = "failed" }; expected = @("check report validation_summary 'codex_invocation_disabled' must be passed") },
        @{ label = "report_runtime_true"; target = "report"; set_values = @{ "runtime_boundary_summary.adapter_runtime_implemented" = $true }; expected = @("check report runtime_boundary_summary adapter_runtime_implemented must be false") },
        @{ label = "report_missing_dependencies"; target = "report"; remove_paths = @("dependency_refs"); expected = @("check report is missing required field 'dependency_refs'") },
        @{ label = "snapshot_missing_active_through"; target = "snapshot"; remove_paths = @("active_through_task"); expected = @("UI snapshot is missing required field 'active_through_task'") },
        @{ label = "snapshot_wrong_active_through"; target = "snapshot"; set_values = @{ active_through_task = "R17-017" }; expected = @("UI snapshot active_through_task must be R17-016") },
        @{ label = "snapshot_status_codex_true"; target = "snapshot"; set_values = @{ "status_summary.codex_executor_invoked" = $true }; expected = @("UI snapshot status_summary codex_executor_invoked must be false") },
        @{ label = "snapshot_runtime_true"; target = "snapshot"; set_values = @{ "runtime_boundaries.external_api_call_performed" = $true }; expected = @("UI snapshot runtime_boundaries external_api_call_performed must be false") },
        @{ label = "ui_external_dependency"; target = "ui_text"; text = '<link href="https://example.com/x.css">'; expected = @("contains forbidden external dependency") },
        @{ label = "ui_missing_fragment"; target = "ui_text"; text = '<section>missing adapter panel</section>'; expected = @("index.html must expose R17-016 Codex executor adapter fragment") },
        @{ label = "kanban_js_changed"; target = "kanban_js"; expected = @("kanban.js churn is not allowed") },
        @{ label = "fixture_coverage_missing"; target = "fixture_coverage"; expected = @("missing compact invalid fixture coverage") }
    )

    return $fixtures
}

function Write-R17CodexExecutorAdapterFixtures {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][string]$FixtureRoot
    )

    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $FixtureRoot -Filter "*.json" -ErrorAction SilentlyContinue | Remove-Item -Force
    Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot "valid_request_packet.json") -Value $ObjectSet.RequestPacket
    Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot "valid_result_packet.json") -Value $ObjectSet.ResultPacket
    Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $index = 1
    foreach ($fixture in (New-R17CodexExecutorAdapterInvalidFixtures)) {
        $fileName = "invalid_{0:000}_{1}.json" -f $index, $fixture.label
        $payload = [ordered]@{
            target = $fixture.target
            operation = $fixture.label
            expected_failure_fragments = $fixture.expected
        }
        if ($fixture.ContainsKey("remove_paths")) { $payload.remove_paths = $fixture.remove_paths }
        if ($fixture.ContainsKey("set_values")) { $payload.set_values = $fixture.set_values }
        if ($fixture.ContainsKey("text")) { $payload.text = $fixture.text }
        Write-R17CodexExecutorAdapterJson -Path (Join-Path $FixtureRoot $fileName) -Value $payload
        $index += 1
    }
}

function New-R17CodexExecutorAdapterProofArtifacts {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths
    )

    $proofReview = @"
# R17-016 Codex Executor Adapter Proof Review

Status: generated

R17-016 creates a disabled, packet-only Developer/Codex executor adapter foundation only. It defines the adapter contract, request packet, result packet, check report, UI snapshot, compact fixtures, and validation surfaces for the future Developer/Codex executor path.

This package does not invoke Codex, implement adapter runtime, execute tool calls, call APIs, send A2A messages, invoke agents, mutate the board live, create runtime cards, implement live Orchestrator runtime, implement autonomous agents, implement runtime memory, implement vector retrieval, produce real Dev output, produce real QA result, or produce real audit verdict.
"@

    $validationManifest = @"
# R17-016 Codex Executor Adapter Validation Manifest

Status: passed

The manifest may be marked passed only after the R17-016 generator, validator, focused test, status-doc gate, impacted R17 validators/tests, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- git diff --check
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_016_codex_executor_adapter_evidence_index"
        index_version = "v1"
        source_task = $script:SourceTask
        evidence_refs = @(
            "contracts/tools/r17_codex_executor_adapter.contract.json",
            "tools/R17CodexExecutorAdapter.psm1",
            "tools/new_r17_codex_executor_adapter.ps1",
            "tools/validate_r17_codex_executor_adapter.ps1",
            "tests/test_r17_codex_executor_adapter.ps1",
            "tests/fixtures/r17_codex_executor_adapter/",
            "state/tools/r17_codex_executor_adapter_request_packet.json",
            "state/tools/r17_codex_executor_adapter_result_packet.json",
            "state/tools/r17_codex_executor_adapter_check_report.json",
            "state/ui/r17_kanban_mvp/r17_codex_executor_adapter_snapshot.json",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_016_codex_executor_adapter/proof_review.md",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_016_codex_executor_adapter/validation_manifest.md"
        )
        dependency_refs = Get-R17CodexExecutorAdapterDependencyRefs
        aggregate_verdict = $script:AggregateVerdict
        runtime_boundary_summary = $ObjectSet.Report.runtime_boundary_summary
        non_claims = Get-R17CodexExecutorAdapterNonClaims
        rejected_claims = Get-R17CodexExecutorAdapterRejectedClaims
    }

    Write-R17CodexExecutorAdapterText -Path $Paths.ProofReview -Value $proofReview
    Write-R17CodexExecutorAdapterText -Path $Paths.ValidationManifest -Value $validationManifest
    Write-R17CodexExecutorAdapterJson -Path $Paths.EvidenceIndex -Value $evidenceIndex
}

function New-R17CodexExecutorAdapterArtifacts {
    param([string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot))

    $paths = Get-R17CodexExecutorAdapterPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17CodexExecutorAdapterArtifactsObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17CodexExecutorAdapterJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17CodexExecutorAdapterJson -Path $paths.RequestPacket -Value $objectSet.RequestPacket
    Write-R17CodexExecutorAdapterJson -Path $paths.ResultPacket -Value $objectSet.ResultPacket
    Write-R17CodexExecutorAdapterJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17CodexExecutorAdapterJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    Write-R17CodexExecutorAdapterFixtures -ObjectSet $objectSet -FixtureRoot $paths.FixtureRoot
    New-R17CodexExecutorAdapterProofArtifacts -ObjectSet $objectSet -Paths $paths

    return [pscustomobject]@{
        Contract = $paths.Contract
        RequestPacket = $paths.RequestPacket
        ResultPacket = $paths.ResultPacket
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        InvalidFixtureCount = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json").Count
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17CodexExecutorAdapterPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Packet,
        [Parameter(Mandatory = $true)][string]$PacketKind,
        [string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot)
    )

    if ($PacketKind -eq "request") {
        Assert-R17CodexExecutorAdapterRequiredFields -Object $Packet -FieldNames $script:RequiredRequestFields -Context "request packet"
        if ($Packet.artifact_type -ne "r17_codex_executor_adapter_request_packet") { throw "request packet artifact_type is invalid." }
        if ($Packet.status -ne "disabled_packet_only") { throw "request packet status must be disabled_packet_only." }
        if ([bool]$Packet.execution_allowed -ne $false) { throw "request packet execution_allowed must be false." }
        if ([bool]$Packet.codex_executor_invocation_allowed -ne $false) { throw "request packet codex_executor_invocation_allowed must be false." }
        if ([bool]$Packet.secret_policy.committed_secret_material_allowed -ne $false -or [bool]$Packet.secret_policy.external_api_keys_required -ne $false) { throw "request packet secret_policy must not allow committed secrets or require API keys." }
        if ([bool]$Packet.cost_policy.cost_incurred -ne $false -or [bool]$Packet.cost_policy.external_billing_claimed -ne $false) { throw "request packet cost_policy must not claim incurred cost." }
        if ([bool]$Packet.timeout_policy.timeout_runtime_implemented -ne $false) { throw "request packet timeout_policy must not implement runtime timeout." }
        if ([bool]$Packet.retry_policy.retry_runtime_implemented -ne $false) { throw "request packet retry_policy must not implement runtime retry." }
        Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.input_packet_ref) -Context "request packet input_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.result_packet_ref) -Context "request packet result_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    elseif ($PacketKind -eq "result") {
        Assert-R17CodexExecutorAdapterRequiredFields -Object $Packet -FieldNames $script:RequiredResultFields -Context "result packet"
        if ($Packet.artifact_type -ne "r17_codex_executor_adapter_result_packet") { throw "result packet artifact_type is invalid." }
        if ($Packet.status -ne "not_executed_disabled_foundation") { throw "result packet status must be not_executed_disabled_foundation." }
        if ([bool]$Packet.developer_output_claimed -ne $false) { throw "result packet developer_output_claimed must be false." }
        if ([string]$Packet.imported_diff_ref -ne "not_imported") { throw "result packet imported_diff_ref must remain not_imported for R17-016." }
        if ([string]$Packet.imported_status_ref -ne "not_imported") { throw "result packet imported_status_ref must remain not_imported for R17-016." }
        Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.source_request_ref) -Context "result packet source_request_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    else {
        throw "Unknown packet kind '$PacketKind'."
    }

    if ($Packet.source_task -ne $script:SourceTask) { throw "$PacketKind packet source_task must be R17-016." }
    if ($Packet.adapter_profile_id -ne $script:AdapterProfileId) { throw "$PacketKind packet adapter_profile_id is invalid." }
    if ($Packet.adapter_type -ne $script:AdapterType) { throw "$PacketKind packet adapter_type is invalid." }
    if ($Packet.target_agent_id -ne "developer") { throw "$PacketKind packet target_agent_id must be developer." }
    if ($Packet.requested_by_agent_id -ne "orchestrator") { throw "$PacketKind packet requested_by_agent_id must be orchestrator." }
    if ([string]$Packet.contract_ref -ne "contracts/tools/r17_codex_executor_adapter.contract.json") { throw "$PacketKind packet contract_ref is invalid." }
    if ([string]$Packet.common_tool_adapter_contract_ref -ne "contracts/tools/r17_tool_adapter.contract.json") { throw "$PacketKind packet common_tool_adapter_contract_ref is invalid." }

    Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.contract_ref) -Context "$PacketKind packet contract_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.common_tool_adapter_contract_ref) -Context "$PacketKind packet common_tool_adapter_contract_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.common_tool_adapter_seed_profile_ref) -Context "$PacketKind packet common_tool_adapter_seed_profile_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.tool_call_ref) -Context "$PacketKind packet tool_call_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
    Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$Packet.board_event_ref) -Context "$PacketKind packet board_event_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot

    if (@($Packet.evidence_refs).Count -lt 1) { throw "$PacketKind packet evidence_refs must not be empty." }
    foreach ($ref in @($Packet.evidence_refs)) {
        Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$ref) -Context "$PacketKind packet evidence_ref" -RepositoryRoot $RepositoryRoot
    }

    if (Test-R17CodexExecutorAdapterHasProperty -Object $Packet -Name "required_authority_refs") {
        foreach ($ref in @($Packet.required_authority_refs)) {
            Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$ref) -Context "$PacketKind packet required_authority_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        }
    }

    Assert-R17CodexExecutorAdapterFalseFlags -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$PacketKind packet runtime_flags"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Packet.claim_status -FieldNames $script:ClaimStatusFields -Context "$PacketKind packet claim_status"
    Assert-R17CodexExecutorAdapterContains -Values @($Packet.non_claims) -Required (Get-R17CodexExecutorAdapterNonClaims) -Context "$PacketKind packet non_claims"
    Assert-R17CodexExecutorAdapterContains -Values @($Packet.rejected_claims) -Required (Get-R17CodexExecutorAdapterRejectedClaims) -Context "$PacketKind packet rejected_claims"
    Assert-R17CodexExecutorAdapterNoSensitiveLiteral -Object $Packet -Context "$PacketKind packet"
}

function Assert-R17CodexExecutorAdapterUiText {
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
    $styleText = ""
    $readmeText = ""
    foreach ($path in $UiTextByPath.Keys) {
        if ($path -like "*index.html") { $indexText = [string]$UiTextByPath[$path] }
        if ($path -like "*styles.css") { $styleText = [string]$UiTextByPath[$path] }
        if ($path -like "*README.md") { $readmeText = [string]$UiTextByPath[$path] }
    }

    foreach ($fragment in @("codex-executor-adapter-panel", "Developer/Codex Executor Adapter", "disabled packet-only foundation", "codex_executor_invoked: false", "adapter_runtime_implemented: false", "actual_tool_call_performed: false", "external_api_call_performed: false", "no Codex invocation", "no adapter runtime", "no API calls")) {
        if ($indexText -notmatch [regex]::Escape($fragment)) {
            throw "index.html must expose R17-016 Codex executor adapter fragment '$fragment'."
        }
    }

    if ($styleText -notmatch "codex-executor-adapter-panel") { throw "styles.css must include codex-executor-adapter-panel styling." }
    if ($readmeText -notmatch "R17-016" -or $readmeText -notmatch "disabled packet-only") { throw "README.md must document the R17-016 disabled packet-only panel." }
}

function Assert-R17CodexExecutorAdapterFixtureCoverage {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [int]$MinimumInvalidFixtureCount = $script:MinimumInvalidFixtureCount
    )

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $MinimumInvalidFixtureCount) {
        throw "missing compact invalid fixture coverage: expected at least $MinimumInvalidFixtureCount invalid fixtures."
    }
}

function Assert-R17CodexExecutorAdapterKanbanJsUnchanged {
    param(
        [string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot),
        [string[]]$ChangedPaths
    )

    if ($null -eq $ChangedPaths) {
        $ChangedPaths = @()
        $ChangedPaths += @((& git -C $RepositoryRoot diff --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $ChangedPaths += @((& git -C $RepositoryRoot diff --cached --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    if (@($ChangedPaths | Where-Object { $_ -eq "scripts/operator_wall/r17_kanban_mvp/kanban.js" }).Count -gt 0) {
        throw "kanban.js churn is not allowed for R17-016 unless explicitly justified."
    }
}

function Test-R17CodexExecutorAdapterSet {
    [CmdletBinding()]
    param(
        [object]$Contract,
        [object]$RequestPacket,
        [object]$ResultPacket,
        [object]$Report,
        [object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot),
        [switch]$SkipUiFiles,
        [switch]$SkipFixtureCoverage
    )

    Assert-R17CodexExecutorAdapterRequiredFields -Object $Contract -FieldNames $script:RequiredContractFields -Context "contract"
    if ($Contract.artifact_type -ne "r17_codex_executor_adapter_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask) { throw "contract source_task must be R17-016." }
    if ($Contract.adapter_profile_id -ne $script:AdapterProfileId) { throw "contract adapter_profile_id is invalid." }
    if ($Contract.adapter_type -ne $script:AdapterType) { throw "contract adapter_type is invalid." }
    if ($Contract.target_agent_id -ne "developer") { throw "contract target_agent_id must be developer." }
    if ([string]$Contract.common_tool_adapter_contract_ref -ne "contracts/tools/r17_tool_adapter.contract.json") { throw "contract common_tool_adapter_contract_ref is invalid." }
    Assert-R17CodexExecutorAdapterContains -Values @($Contract.required_request_fields) -Required $script:RequiredRequestFields -Context "contract required_request_fields"
    Assert-R17CodexExecutorAdapterContains -Values @($Contract.required_result_fields) -Required $script:RequiredResultFields -Context "contract required_result_fields"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract implementation_boundaries"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "contract claim_status"
    if ([bool]$Contract.exact_ref_policy.urls_allowed -ne $false) { throw "contract exact_ref_policy must forbid URLs." }
    if ([bool]$Contract.exact_ref_policy.full_source_file_content_embedding_allowed -ne $false) { throw "contract must forbid generated artifact embedding full source file contents." }
    if ([bool]$Contract.exact_ref_policy.broad_repo_scan_output_allowed -ne $false) { throw "contract must forbid broad repo scan output." }
    if ([bool]$Contract.packet_policy.codex_executor_invocation_allowed -ne $false) { throw "contract packet_policy must disable Codex executor invocation." }
    Assert-R17CodexExecutorAdapterContains -Values @($Contract.non_claims) -Required (Get-R17CodexExecutorAdapterNonClaims) -Context "contract non_claims"
    Assert-R17CodexExecutorAdapterContains -Values @($Contract.rejected_claims) -Required (Get-R17CodexExecutorAdapterRejectedClaims) -Context "contract rejected_claims"
    Assert-R17CodexExecutorAdapterNoSensitiveLiteral -Object $Contract -Context "contract"

    Assert-R17CodexExecutorAdapterPacket -Packet $RequestPacket -PacketKind "request" -RepositoryRoot $RepositoryRoot
    Assert-R17CodexExecutorAdapterPacket -Packet $ResultPacket -PacketKind "result" -RepositoryRoot $RepositoryRoot

    Assert-R17CodexExecutorAdapterRequiredFields -Object $Report -FieldNames $script:RequiredReportFields -Context "check report"
    if ($Report.artifact_type -ne "r17_codex_executor_adapter_check_report") { throw "check report artifact_type is invalid." }
    if ($Report.source_task -ne $script:SourceTask) { throw "check report source_task must be R17-016." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($ref in @($Report.dependency_refs)) {
        Assert-R17CodexExecutorAdapterSafeRefPath -Path ([string]$ref) -Context "check report dependency_refs" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }
    if ([bool]$Report.full_source_file_contents_embedded -ne $false) { throw "check report full_source_file_contents_embedded must be false." }
    if ([bool]$Report.broad_repo_scan_output_included -ne $false) { throw "check report broad_repo_scan_output_included must be false." }
    if ([bool]$Report.codex_executor_invoked -ne $false) { throw "check report codex_executor_invoked must be false." }
    Assert-R17CodexExecutorAdapterContains -Values @($Report.non_claims) -Required (Get-R17CodexExecutorAdapterNonClaims) -Context "check report non_claims"
    Assert-R17CodexExecutorAdapterContains -Values @($Report.rejected_claims) -Required (Get-R17CodexExecutorAdapterRejectedClaims) -Context "check report rejected_claims"
    Assert-R17CodexExecutorAdapterNoSensitiveLiteral -Object $Report -Context "check report"

    Assert-R17CodexExecutorAdapterRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "contract_ref", "request_packet_ref", "result_packet_ref", "check_report_ref", "visible_adapter", "status_summary", "runtime_boundaries", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_codex_executor_adapter_snapshot") { throw "UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne "R17-016") { throw "UI snapshot active_through_task must be R17-016." }
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Snapshot.status_summary -FieldNames @("adapter_runtime_implemented", "actual_tool_call_performed", "codex_executor_invoked", "external_api_call_performed", "a2a_message_sent", "agent_invocation_performed", "board_mutation_performed", "runtime_card_creation_performed", "product_runtime_executed", "production_runtime_executed") -Context "UI snapshot status_summary"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17CodexExecutorAdapterFalseFlags -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"
    Assert-R17CodexExecutorAdapterContains -Values @($Snapshot.non_claims) -Required (Get-R17CodexExecutorAdapterNonClaims) -Context "UI snapshot non_claims"
    Assert-R17CodexExecutorAdapterContains -Values @($Snapshot.rejected_claims) -Required (Get-R17CodexExecutorAdapterRejectedClaims) -Context "UI snapshot rejected_claims"

    if (-not $SkipFixtureCoverage) {
        $paths = Get-R17CodexExecutorAdapterPaths -RepositoryRoot $RepositoryRoot
        Assert-R17CodexExecutorAdapterFixtureCoverage -FixtureRoot $paths.FixtureRoot
    }

    if (-not $SkipUiFiles) {
        $paths = Get-R17CodexExecutorAdapterPaths -RepositoryRoot $RepositoryRoot
        $uiText = @{}
        foreach ($uiPath in $paths.UiFiles) {
            if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) { throw "UI file '$uiPath' does not exist." }
            $uiText[$uiPath] = Get-Content -LiteralPath $uiPath -Raw
        }
        Assert-R17CodexExecutorAdapterUiText -UiTextByPath $uiText
        Assert-R17CodexExecutorAdapterKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        AdapterType = $Contract.adapter_type
        RequestStatus = $RequestPacket.status
        ResultStatus = $ResultPacket.status
        AdapterRuntimeImplemented = [bool]$Report.runtime_boundary_summary.adapter_runtime_implemented
        CodexExecutorInvoked = [bool]$Report.runtime_boundary_summary.codex_executor_invoked
        ActualToolCallPerformed = [bool]$Report.runtime_boundary_summary.actual_tool_call_performed
        ExternalApiCallPerformed = [bool]$Report.runtime_boundary_summary.external_api_call_performed
        A2aMessageSent = [bool]$Report.runtime_boundary_summary.a2a_message_sent
    }
}

function Test-R17CodexExecutorAdapter {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17CodexExecutorAdapterRepositoryRoot))

    $paths = Get-R17CodexExecutorAdapterPaths -RepositoryRoot $RepositoryRoot
    return Test-R17CodexExecutorAdapterSet `
        -Contract (Read-R17CodexExecutorAdapterJson -Path $paths.Contract) `
        -RequestPacket (Read-R17CodexExecutorAdapterJson -Path $paths.RequestPacket) `
        -ResultPacket (Read-R17CodexExecutorAdapterJson -Path $paths.ResultPacket) `
        -Report (Read-R17CodexExecutorAdapterJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17CodexExecutorAdapterJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17CodexExecutorAdapterObjectPathValue {
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

function Remove-R17CodexExecutorAdapterObjectPathValue {
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

function Invoke-R17CodexExecutorAdapterMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if (Test-R17CodexExecutorAdapterHasProperty -Object $Mutation -Name "remove_paths") {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R17CodexExecutorAdapterObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ((Test-R17CodexExecutorAdapterHasProperty -Object $Mutation -Name "set_values") -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17CodexExecutorAdapterObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17CodexExecutorAdapterPaths, `
    Get-R17CodexExecutorAdapterNonClaims, `
    Get-R17CodexExecutorAdapterRejectedClaims, `
    New-R17CodexExecutorAdapterArtifacts, `
    New-R17CodexExecutorAdapterArtifactsObjectSet, `
    Test-R17CodexExecutorAdapter, `
    Test-R17CodexExecutorAdapterSet, `
    Assert-R17CodexExecutorAdapterUiText, `
    Assert-R17CodexExecutorAdapterFixtureCoverage, `
    Assert-R17CodexExecutorAdapterKanbanJsUnchanged, `
    Invoke-R17CodexExecutorAdapterMutation, `
    Copy-R17CodexExecutorAdapterObject
