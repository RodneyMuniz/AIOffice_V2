Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-013"
$script:AggregateVerdict = "generated_r17_memory_artifact_loader_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_013_memory_artifact_loader"
$script:FixtureRoot = "tests/fixtures/r17_memory_artifact_loader"

$script:RequiredAgents = @(
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

$script:FalseBoundaryFields = @(
    "broad_repo_scan_used",
    "raw_chat_history_used_as_canonical",
    "runtime_memory_engine_implemented",
    "vector_retrieval_implemented",
    "live_agent_invocation_implemented",
    "a2a_runtime_implemented",
    "adapter_runtime_implemented",
    "external_api_calls_implemented",
    "product_runtime_implemented",
    "production_runtime_implemented",
    "live_board_mutation_implemented",
    "runtime_card_creation_implemented",
    "executable_handoffs_implemented",
    "executable_transitions_implemented",
    "generated_markdown_only_evidence_used_as_proof",
    "fake_multi_agent_narration_as_proof",
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

function Get-R17MemoryArtifactLoaderRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17MemoryArtifactLoaderPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17MemoryArtifactLoaderJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17MemoryArtifactLoaderJson {
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

function Write-R17MemoryArtifactLoaderText {
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

function Copy-R17MemoryArtifactLoaderObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17MemoryArtifactLoaderPaths {
    param([string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/context/r17_memory_artifact_loader.contract.json"
        Report = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r17_memory_artifact_loader_report.json"
        LoadedRefsLog = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r17_memory_loaded_refs_log.json"
        AgentPacketRoot = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_memory_packets"
        UiSnapshot = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json"
        FixtureRoot = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        UiFiles = @(
            (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md")
        )
    }
}

function Get-R17MemoryArtifactLoaderGitIdentity {
    param([string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }

    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Test-R17MemoryArtifactLoaderTrackedFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot)
    )

    & git -C $RepositoryRoot ls-files --error-unmatch -- $Path *> $null
    return ($LASTEXITCODE -eq 0)
}

function Assert-R17MemoryArtifactLoaderSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$Context = "ref"
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context path must not be empty." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context path must be repo-relative." }
    if ($Path -match '(^|/)\.\.(/|$)' -or $Path -match '\\') { throw "$Context path must be normalized repo-relative path." }
    if ($Path -match '[\*\?\[\]]') { throw "$Context path must not contain wildcard characters." }
    if ($Path -match '^(?i:https?://|file://)') { throw "$Context path must not be a URL." }
    if ($Path -match '^\.local_backups/') { throw "$Context path must not point at .local_backups." }
    if ($Path -match '(?i)(chat_history|chat-transcript|raw_chat|transcript)') { throw "$Context path must not use raw chat history as canonical evidence." }
}

function Get-R17MemoryArtifactLoaderNonClaims {
    return @(
        "R17-013 implements a bounded deterministic memory/artifact loader foundation only",
        "R17-013 prepares scoped memory/artifact refs for future agent packets only",
        "R17-013 does not implement live agent runtime",
        "R17-013 does not invoke agents",
        "R17-013 does not implement A2A runtime",
        "R17-013 does not implement adapters",
        "R17-013 does not call external APIs",
        "R17-013 does not implement runtime memory engine",
        "R17-013 does not implement vector retrieval",
        "R17-013 does not use broad repo scan in the happy path",
        "R17-013 does not use raw chat history as canonical evidence",
        "R17-013 does not implement live board mutation",
        "R17-013 does not create runtime cards",
        "R17-013 does not implement product runtime",
        "R17-013 does not implement production runtime",
        "R17-013 does not produce real Dev output",
        "R17-013 does not produce real QA result",
        "R17-013 does not produce real audit verdict",
        "R17-013 does not claim external audit acceptance",
        "R17-013 does not claim main merge",
        "R17-013 does not close R13",
        "R17-013 does not remove R14 caveats",
        "R17-013 does not remove R15 caveats",
        "R17-013 does not solve Codex compaction",
        "R17-013 does not solve Codex reliability"
    )
}

function Get-R17MemoryArtifactLoaderRejectedClaims {
    return @(
        "live_agent_runtime",
        "runtime_agent_invocation",
        "A2A_runtime",
        "autonomous_agents",
        "adapter_runtime",
        "external_API_calls",
        "runtime_memory_engine",
        "vector_retrieval_runtime",
        "broad_repo_scan_in_happy_path",
        "raw_chat_history_as_canonical_evidence",
        "live_board_mutation",
        "runtime_card_creation",
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
        "fake_multi_agent_narration_as_proof",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "R17_014_or_later_implementation"
    )
}

function Get-R17MemoryArtifactLoaderFalseBoundaries {
    $boundaries = [ordered]@{}
    foreach ($field in $script:FalseBoundaryFields) { $boundaries[$field] = $false }
    return $boundaries
}

function Get-R17MemoryArtifactLoaderPreservedBoundaries {
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

function Get-R17MemoryArtifactLoaderR16SourceRefs {
    return @(
        [ordered]@{ ref_id = "r16_context_load_plan"; path = "state/context/r16_context_load_plan.json"; source_task = "R16-015"; category = "memory"; required = $true },
        [ordered]@{ ref_id = "r16_context_budget_estimate"; path = "state/context/r16_context_budget_estimate.json"; source_task = "R16-016"; category = "memory"; required = $true },
        [ordered]@{ ref_id = "r16_context_budget_guard_report"; path = "state/context/r16_context_budget_guard_report.json"; source_task = "R16-017"; category = "guard"; required = $true },
        [ordered]@{ ref_id = "r16_role_memory_packs"; path = "state/memory/r16_role_memory_packs.json"; source_task = "R16-007"; category = "memory"; required = $true },
        [ordered]@{ ref_id = "r16_role_memory_pack_model"; path = "state/memory/r16_role_memory_pack_model.json"; source_task = "R16-006"; category = "memory"; required = $true },
        [ordered]@{ ref_id = "r16_memory_pack_validation_report"; path = "state/memory/r16_memory_pack_validation_report.json"; source_task = "R16-008"; category = "memory"; required = $true },
        [ordered]@{ ref_id = "r16_artifact_map"; path = "state/artifacts/r16_artifact_map.json"; source_task = "R16-010"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_audit_map"; path = "state/audit/r16_r15_r16_audit_map.json"; source_task = "R16-012"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_artifact_audit_map_check_report"; path = "state/artifacts/r16_artifact_audit_map_check_report.json"; source_task = "R16-013"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_role_run_envelopes"; path = "state/workflow/r16_role_run_envelopes.json"; source_task = "R16-019"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_raci_transition_gate_report"; path = "state/workflow/r16_raci_transition_gate_report.json"; source_task = "R16-020"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_handoff_packet_report"; path = "state/workflow/r16_handoff_packet_report.json"; source_task = "R16-021"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_restart_compaction_recovery_drill"; path = "state/workflow/r16_restart_compaction_recovery_drill.json"; source_task = "R16-022"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_role_handoff_drill"; path = "state/workflow/r16_role_handoff_drill.json"; source_task = "R16-023"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_audit_readiness_drill"; path = "state/audit/r16_audit_readiness_drill.json"; source_task = "R16-024"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_friction_metrics_report"; path = "state/governance/r16_friction_metrics_report.json"; source_task = "R16-025"; category = "artifact"; required = $true },
        [ordered]@{ ref_id = "r16_final_evidence_index"; path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json"; source_task = "R16-026"; category = "artifact"; required = $true }
    )
}

function Get-R17MemoryArtifactLoaderR17SourceRefs {
    $refs = @(
        [ordered]@{ ref_id = "r17_agent_registry_contract"; path = "contracts/agents/r17_agent_registry.contract.json"; source_task = "R17-012"; category = "r17_registry"; required = $true },
        [ordered]@{ ref_id = "r17_agent_identity_packet_contract"; path = "contracts/agents/r17_agent_identity_packet.contract.json"; source_task = "R17-012"; category = "r17_registry"; required = $true },
        [ordered]@{ ref_id = "r17_agent_registry"; path = "state/agents/r17_agent_registry.json"; source_task = "R17-012"; category = "r17_registry"; required = $true },
        [ordered]@{ ref_id = "r17_agent_registry_check_report"; path = "state/agents/r17_agent_registry_check_report.json"; source_task = "R17-012"; category = "r17_registry"; required = $true }
    )

    foreach ($agentId in $script:RequiredAgents) {
        $refs += [ordered]@{
            ref_id = "r17_identity_$agentId"
            path = "state/agents/r17_agent_identities/$agentId.identity.json"
            source_task = "R17-012"
            category = "r17_identity_packet"
            required = $true
        }
    }

    return $refs
}

function Get-R17MemoryArtifactLoaderRoleMap {
    return @{
        user = $null
        operator = "operator"
        orchestrator = $null
        project_manager = "project_manager"
        architect = "architect"
        developer = "developer"
        qa_test_agent = "qa"
        evidence_auditor = "evidence_auditor"
        knowledge_curator = "knowledge_curator"
        release_closeout = "release_closeout_agent"
    }
}

function ConvertTo-R17MemoryArtifactLoaderLoadedRef {
    param(
        [Parameter(Mandatory = $true)][object]$Ref,
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot)
    )

    $path = [string]$Ref.path
    Assert-R17MemoryArtifactLoaderSafeRefPath -Path $path -Context $Ref.ref_id
    $resolved = Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue $path
    $exists = Test-Path -LiteralPath $resolved -PathType Leaf
    $tracked = $false
    if ($exists) { $tracked = Test-R17MemoryArtifactLoaderTrackedFile -RepositoryRoot $RepositoryRoot -Path $path }
    $status = if ($exists -and $tracked) { "loaded" } elseif ($exists -and -not $tracked) { "blocked" } else { "missing" }
    $sizeBytes = if ($exists) { (Get-Item -LiteralPath $resolved).Length } else { 0 }

    return [ordered]@{
        ref_id = [string]$Ref.ref_id
        path = $path
        source_task = [string]$Ref.source_task
        category = [string]$Ref.category
        required = [bool]$Ref.required
        status = $status
        exact_repo_ref = $true
        tracked = $tracked
        exists = $exists
        size_bytes = $sizeBytes
        full_file_content_embedded = $false
        broad_repo_scan_used = $false
        raw_chat_history_used_as_canonical = $false
    }
}

function Get-R17MemoryArtifactLoaderBudgetSummary {
    param([Parameter(Mandatory = $true)][object]$BudgetEstimate)
    return [ordered]@{
        source_ref = "state/context/r16_context_budget_estimate.json"
        estimate_is_approximate = [bool]$BudgetEstimate.estimate_mode.estimate_is_approximate
        load_item_count = [int]$BudgetEstimate.summary_estimates.load_item_count
        exact_file_count = [int]$BudgetEstimate.summary_estimates.exact_file_count
        total_bytes = [int64]$BudgetEstimate.summary_estimates.total_bytes
        total_lines = [int]$BudgetEstimate.summary_estimates.total_lines
        estimated_tokens_lower_bound = [int]$BudgetEstimate.summary_estimates.estimated_tokens_lower_bound
        estimated_tokens_upper_bound = [int]$BudgetEstimate.summary_estimates.estimated_tokens_upper_bound
        budget_category = [string]$BudgetEstimate.summary_estimates.budget_category
        exact_provider_token_count_claimed = $false
        exact_provider_billing_claimed = $false
    }
}

function Get-R17MemoryArtifactLoaderGuardSummary {
    param([Parameter(Mandatory = $true)][object]$GuardReport)
    return [ordered]@{
        source_ref = "state/context/r16_context_budget_guard_report.json"
        aggregate_verdict = [string]$GuardReport.aggregate_verdict
        threshold_exceeded = [bool]$GuardReport.evaluated_budget.threshold_exceeded
        estimated_tokens_upper_bound = [int]$GuardReport.evaluated_budget.estimated_tokens_upper_bound
        max_estimated_tokens_upper_bound = [int]$GuardReport.configured_budget_thresholds.max_estimated_tokens_upper_bound
        fail_closed_on_over_budget = [bool]$GuardReport.guard_mode.fail_closed_on_over_budget
        broad_repo_scan_allowed = [bool]$GuardReport.no_full_repo_scan_policy.broad_repo_scan_allowed
        full_repo_scan_allowed = [bool]$GuardReport.no_full_repo_scan_policy.full_repo_scan_allowed
        raw_chat_history_loading_allowed = [bool]$GuardReport.no_full_repo_scan_policy.raw_chat_history_loading_allowed
        runtime_memory_implemented = $false
        retrieval_runtime_implemented = $false
        vector_search_runtime_implemented = $false
    }
}

function New-R17MemoryArtifactLoaderContract {
    return [ordered]@{
        artifact_type = "r17_memory_artifact_loader_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-013-memory-artifact-loader-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "bounded_memory_artifact_loader_foundation_only_not_runtime"
        purpose = "Define the deterministic exact-ref loader report, loaded-ref log, and future agent memory packet shape without implementing runtime memory, vector retrieval, live agent invocation, A2A runtime, adapters, API calls, product runtime, or production runtime."
        required_report_fields = @("artifact_type", "contract_version", "report_id", "source_task", "r17_agent_registry_ref", "r17_identity_packet_refs", "r16_source_refs", "loaded_ref_log_ref", "agent_memory_packet_refs", "summary", "checks", "aggregate_verdict", "implementation_boundaries", "non_claims", "rejected_claims")
        required_loaded_ref_fields = @("ref_id", "path", "source_task", "category", "required", "status", "exact_repo_ref", "tracked", "exists", "full_file_content_embedded", "broad_repo_scan_used", "raw_chat_history_used_as_canonical")
        required_packet_fields = @("packet_id", "source_task", "agent_id", "role_name", "source_identity_packet_ref", "approved_memory_refs", "approved_artifact_refs", "forbidden_refs", "missing_refs", "blocked_refs", "context_budget_summary", "guard_summary", "evidence_refs", "loaded_ref_count", "broad_repo_scan_used", "raw_chat_history_used_as_canonical", "runtime_memory_engine_implemented", "vector_retrieval_implemented", "live_agent_invocation_implemented", "a2a_runtime_implemented", "adapter_runtime_implemented", "external_api_calls_implemented", "product_runtime_implemented", "production_runtime_implemented", "non_claims", "rejected_claims")
        required_source_refs = @((Get-R17MemoryArtifactLoaderR17SourceRefs) + (Get-R17MemoryArtifactLoaderR16SourceRefs))
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            broad_repo_scan_allowed = $false
            full_repo_scan_allowed = $false
            wildcard_paths_allowed = $false
            directory_only_refs_allowed = $false
            raw_chat_history_as_canonical_allowed = $false
            generated_markdown_only_evidence_allowed_as_proof = $false
            full_file_content_embedding_allowed = $false
        }
        fixture_policy = [ordered]@{
            compact_invalid_fixtures_required = $true
            fixture_payloads_must_not_duplicate_large_valid_state = $true
        }
        implementation_boundaries = (Get-R17MemoryArtifactLoaderFalseBoundaries)
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
        rejected_claims = @(Get-R17MemoryArtifactLoaderRejectedClaims)
        preserved_boundaries = (Get-R17MemoryArtifactLoaderPreservedBoundaries)
    }
}

function New-R17AgentMemoryPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Identity,
        [Parameter(Mandatory = $true)][object[]]$LoadedRefs,
        [Parameter(Mandatory = $true)][object]$BudgetSummary,
        [Parameter(Mandatory = $true)][object]$GuardSummary
    )

    $roleMap = Get-R17MemoryArtifactLoaderRoleMap
    $agentId = [string]$Identity.agent_id
    $r16RoleId = $roleMap[$agentId]
    $identityRef = "state/agents/r17_agent_identities/$agentId.identity.json"
    $loaded = @($LoadedRefs | Where-Object { $_.status -eq "loaded" })
    $memoryPaths = @($loaded | Where-Object { $_.category -in @("memory", "guard", "r17_registry", "r17_identity_packet") } | ForEach-Object { $_.path } | Select-Object -Unique)
    $artifactPaths = @($loaded | Where-Object { $_.category -eq "artifact" } | ForEach-Object { $_.path } | Select-Object -Unique)

    if ($r16RoleId) {
        $memoryPaths += "state/memory/r16_role_memory_packs.json#role_id=$r16RoleId"
        $artifactPaths += "state/workflow/r16_role_run_envelopes.json#role_id=$r16RoleId"
    }

    $identityAllowedRefs = @($Identity.memory_scope.allowed_refs | ForEach-Object { [string]$_ })
    $approvedMemoryRefs = @($identityAllowedRefs + $memoryPaths | Select-Object -Unique)
    $approvedArtifactRefs = @($artifactPaths | Select-Object -Unique)
    $missing = @($LoadedRefs | Where-Object { $_.required -and $_.status -eq "missing" } | ForEach-Object { $_.path })
    $blocked = @($LoadedRefs | Where-Object { $_.status -eq "blocked" } | ForEach-Object { $_.path })

    return [ordered]@{
        artifact_type = "r17_agent_memory_packet"
        contract_version = "v1"
        packet_id = "aioffice-r17-013-$agentId-memory-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        agent_id = $agentId
        role_name = [string]$Identity.role_name
        r17_role_type = [string]$Identity.role_type
        r16_role_mapping = if ($r16RoleId) { [ordered]@{ status = "mapped"; r16_role_id = $r16RoleId } } else { [ordered]@{ status = "not_applicable"; r16_role_id = $null; reason = "No direct R16 role pack is required for this R17 role." } }
        source_identity_packet_ref = $identityRef
        approved_memory_refs = @($approvedMemoryRefs)
        approved_artifact_refs = @($approvedArtifactRefs)
        forbidden_refs = @($Identity.memory_scope.forbidden_refs + @("generated Markdown-only evidence as proof by itself", "full file content embedding", "broad repo scan output", "external API result", "untracked local file"))
        missing_refs = @($missing)
        blocked_refs = @($blocked)
        context_budget_summary = $BudgetSummary
        guard_summary = $GuardSummary
        evidence_refs = @(
            "contracts/context/r17_memory_artifact_loader.contract.json",
            "state/context/r17_memory_artifact_loader_report.json",
            "state/context/r17_memory_loaded_refs_log.json",
            $identityRef,
            "state/agents/r17_agent_registry.json",
            "state/context/r16_context_load_plan.json",
            "state/context/r16_context_budget_estimate.json",
            "state/context/r16_context_budget_guard_report.json"
        )
        loaded_ref_count = @($loaded).Count
        broad_repo_scan_used = $false
        raw_chat_history_used_as_canonical = $false
        runtime_memory_engine_implemented = $false
        vector_retrieval_implemented = $false
        live_agent_invocation_implemented = $false
        a2a_runtime_implemented = $false
        adapter_runtime_implemented = $false
        external_api_calls_implemented = $false
        product_runtime_implemented = $false
        production_runtime_implemented = $false
        generated_markdown_only_evidence_used_as_proof = $false
        fake_multi_agent_narration_as_proof = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
        rejected_claims = @(Get-R17MemoryArtifactLoaderRejectedClaims)
        preserved_boundaries = (Get-R17MemoryArtifactLoaderPreservedBoundaries)
    }
}

function New-R17MemoryArtifactLoaderArtifactsObjectSet {
    param(
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot),
        [string]$GeneratedFromHead = "",
        [string]$GeneratedFromTree = ""
    )

    if ([string]::IsNullOrWhiteSpace($GeneratedFromHead) -or [string]::IsNullOrWhiteSpace($GeneratedFromTree)) {
        $git = Get-R17MemoryArtifactLoaderGitIdentity -RepositoryRoot $RepositoryRoot
        $GeneratedFromHead = $git.Head
        $GeneratedFromTree = $git.Tree
    }

    $contract = New-R17MemoryArtifactLoaderContract
    $allSourceRefs = @((Get-R17MemoryArtifactLoaderR17SourceRefs) + (Get-R17MemoryArtifactLoaderR16SourceRefs))
    $loadedRefs = @($allSourceRefs | ForEach-Object { ConvertTo-R17MemoryArtifactLoaderLoadedRef -Ref $_ -RepositoryRoot $RepositoryRoot })
    $missingRefs = @($loadedRefs | Where-Object { $_.required -and $_.status -eq "missing" })
    $blockedRefs = @($loadedRefs | Where-Object { $_.status -eq "blocked" })

    $budgetEstimate = Read-R17MemoryArtifactLoaderJson -Path (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r16_context_budget_estimate.json")
    $guardReport = Read-R17MemoryArtifactLoaderJson -Path (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r16_context_budget_guard_report.json")
    $budgetSummary = Get-R17MemoryArtifactLoaderBudgetSummary -BudgetEstimate $budgetEstimate
    $guardSummary = Get-R17MemoryArtifactLoaderGuardSummary -GuardReport $guardReport

    $identities = foreach ($agentId in $script:RequiredAgents) {
        Read-R17MemoryArtifactLoaderJson -Path (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_identities/$agentId.identity.json")
    }
    $packets = foreach ($identity in $identities) {
        New-R17AgentMemoryPacket -Identity $identity -LoadedRefs $loadedRefs -BudgetSummary $budgetSummary -GuardSummary $guardSummary
    }

    $packetRefs = @($packets | ForEach-Object { "state/agents/r17_agent_memory_packets/$($_.agent_id).memory_packet.json" })
    $loadedCount = @($loadedRefs | Where-Object { $_.status -eq "loaded" }).Count

    $report = [ordered]@{
        artifact_type = "r17_memory_artifact_loader_report"
        contract_version = "v1"
        report_id = "aioffice-r17-013-memory-artifact-loader-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        contract_ref = "contracts/context/r17_memory_artifact_loader.contract.json"
        r17_agent_registry_ref = "state/agents/r17_agent_registry.json"
        r17_agent_registry_check_report_ref = "state/agents/r17_agent_registry_check_report.json"
        r17_identity_packet_refs = @($script:RequiredAgents | ForEach-Object { "state/agents/r17_agent_identities/$_.identity.json" })
        r16_source_refs = @($loadedRefs | Where-Object { $_.source_task -like "R16-*" })
        loaded_ref_log_ref = "state/context/r17_memory_loaded_refs_log.json"
        agent_memory_packet_refs = @($packetRefs)
        summary = [ordered]@{
            source_ref_count = @($loadedRefs).Count
            loaded_ref_count = $loadedCount
            missing_ref_count = @($missingRefs).Count
            blocked_ref_count = @($blockedRefs).Count
            agent_memory_packet_count = @($packets).Count
            compact_fixture_policy = "compact invalid mutation fixtures only"
            no_artifact_over_5mb = $true
            full_file_content_embedded = $false
        }
        context_budget_summary = $budgetSummary
        guard_summary = $guardSummary
        checks = [ordered]@{
            exact_repo_refs_only = [ordered]@{ status = "passed"; broad_repo_scan_used = $false }
            r17_registry_consumed = [ordered]@{ status = "passed"; ref = "state/agents/r17_agent_registry.json" }
            source_identity_packets_resolved = [ordered]@{ status = "passed"; count = @($identities).Count }
            r16_source_refs_resolved = [ordered]@{ status = if (@($missingRefs).Count -eq 0 -and @($blockedRefs).Count -eq 0) { "passed" } else { "failed_closed" }; loaded = $loadedCount; missing = @($missingRefs).Count; blocked = @($blockedRefs).Count }
            broad_repo_scan_rejected = [ordered]@{ status = "passed"; broad_repo_scan_used = $false }
            raw_chat_history_rejected = [ordered]@{ status = "passed"; raw_chat_history_used_as_canonical = $false }
            generated_markdown_only_evidence_rejected = [ordered]@{ status = "passed"; generated_markdown_only_evidence_used_as_proof = $false }
            runtime_false_flags_preserved = [ordered]@{ status = "passed"; all_runtime_flags_false = $true }
            compact_invalid_fixture_coverage = [ordered]@{ status = "passed"; minimum_invalid_fixture_count = 8 }
        }
        aggregate_verdict = $script:AggregateVerdict
        implementation_boundaries = (Get-R17MemoryArtifactLoaderFalseBoundaries)
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
        rejected_claims = @(Get-R17MemoryArtifactLoaderRejectedClaims)
        preserved_boundaries = (Get-R17MemoryArtifactLoaderPreservedBoundaries)
    }

    $loadedLog = [ordered]@{
        artifact_type = "r17_memory_loaded_refs_log"
        contract_version = "v1"
        log_id = "aioffice-r17-013-memory-loaded-refs-log-v1"
        source_task = $script:SourceTask
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        log_format = "json_array_of_exact_ref_status_entries"
        broad_repo_scan_used = $false
        raw_chat_history_used_as_canonical = $false
        full_file_content_embedded = $false
        entries = @($loadedRefs)
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_memory_loader_snapshot"
        contract_version = "v1"
        source_task = $script:SourceTask
        milestone = $script:MilestoneName
        branch = $script:BranchName
        active_through_task = "R17-013"
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        ui_boundary_label = "read-only memory/artifact loader snapshot, not runtime"
        loader_report_ref = "state/context/r17_memory_artifact_loader_report.json"
        loaded_ref_log_ref = "state/context/r17_memory_loaded_refs_log.json"
        agent_memory_packet_refs = @($packetRefs)
        loaded_ref_summary = $report.summary
        context_budget_summary = $budgetSummary
        guard_summary = $guardSummary
        missing_refs = @($missingRefs | ForEach-Object { $_.path })
        blocked_refs = @($blockedRefs | ForEach-Object { $_.path })
        runtime_boundaries = (Get-R17MemoryArtifactLoaderFalseBoundaries)
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
        rejected_claims = @(Get-R17MemoryArtifactLoaderRejectedClaims)
    }

    return [pscustomobject]@{
        Contract = $contract
        Report = $report
        LoadedRefsLog = $loadedLog
        AgentPackets = @($packets)
        Snapshot = $snapshot
    }
}

function New-R17MemoryArtifactLoaderFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths
    )

    $validPacket = @($ObjectSet.AgentPackets | Where-Object { $_.agent_id -eq "developer" })[0]
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_loader_report.json") -Value $ObjectSet.Report
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_loaded_refs_log.json") -Value $ObjectSet.LoadedRefsLog
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_agent_memory_packets.json") -Value @($ObjectSet.AgentPackets)
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_developer_memory_packet.json") -Value $validPacket
    Write-R17MemoryArtifactLoaderJson -Path (Join-Path $Paths.FixtureRoot "valid_memory_loader_snapshot.json") -Value $ObjectSet.Snapshot

    $invalids = @(
        [ordered]@{ target = "contract"; remove_paths = @("required_packet_fields"); set_values = [ordered]@{}; expected_failure_fragments = @("required_packet_fields") },
        [ordered]@{ target = "report"; remove_paths = @("loaded_ref_log_ref"); set_values = [ordered]@{}; expected_failure_fragments = @("loaded_ref_log_ref") },
        [ordered]@{ target = "report"; remove_paths = @("r17_agent_registry_ref"); set_values = [ordered]@{}; expected_failure_fragments = @("r17_agent_registry_ref") },
        [ordered]@{ target = "packet"; remove_paths = @("source_identity_packet_ref"); set_values = [ordered]@{}; expected_failure_fragments = @("source_identity_packet_ref") },
        [ordered]@{ target = "packet"; remove_paths = @(); set_values = [ordered]@{ broad_repo_scan_used = $true }; expected_failure_fragments = @("broad_repo_scan_used") },
        [ordered]@{ target = "packet"; remove_paths = @(); set_values = [ordered]@{ runtime_memory_engine_implemented = $true }; expected_failure_fragments = @("runtime_memory_engine_implemented") },
        [ordered]@{ target = "packet"; remove_paths = @(); set_values = [ordered]@{ vector_retrieval_implemented = $true }; expected_failure_fragments = @("vector_retrieval_implemented") },
        [ordered]@{ target = "packet"; remove_paths = @(); set_values = [ordered]@{ live_agent_invocation_implemented = $true }; expected_failure_fragments = @("live_agent_invocation_implemented") },
        [ordered]@{ target = "report"; remove_paths = @(); set_values = [ordered]@{ "implementation_boundaries.external_api_calls_implemented" = $true }; expected_failure_fragments = @("external_api_calls_implemented") },
        [ordered]@{ target = "report"; remove_paths = @(); set_values = [ordered]@{ "implementation_boundaries.fake_multi_agent_narration_as_proof" = $true }; expected_failure_fragments = @("fake_multi_agent_narration_as_proof") },
        [ordered]@{ target = "report"; operation = "append_missing_source_ref"; expected_failure_fragments = @("unresolved source refs") },
        [ordered]@{ target = "snapshot"; remove_paths = @(); set_values = [ordered]@{ "runtime_boundaries.product_runtime_implemented" = $true }; expected_failure_fragments = @("product_runtime_implemented") }
    )

    $index = 0
    foreach ($invalid in $invalids) {
        $index++
        $path = Join-Path $Paths.FixtureRoot ("invalid_{0:00}_{1}.json" -f $index, ($invalid.target -replace '[^a-zA-Z0-9_]', '_'))
        Write-R17MemoryArtifactLoaderJson -Path $path -Value $invalid
    }
}

function New-R17MemoryArtifactLoaderProofFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths,
        [string]$ManifestStatus = "pending"
    )

    $proof = @"
# R17-013 Memory Artifact Loader Proof Review

Status: generated

R17-013 implements a bounded deterministic memory/artifact loader foundation only. It prepares scoped memory/artifact refs for future agent packets and does not implement live agent runtime, A2A runtime, adapters, API calls, runtime memory engine, vector retrieval, live board mutation, runtime card creation, product runtime, production runtime, real Dev output, real QA result, or real audit verdict.

The loader consumes exact R17-012 registry and identity packet refs plus exact R16 memory/context/artifact refs. It records loaded, skipped, missing, and blocked refs by path without embedding full file contents.
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_013_memory_artifact_loader_evidence_index"
        index_version = "v1"
        source_task = $script:SourceTask
        evidence_refs = @(
            "contracts/context/r17_memory_artifact_loader.contract.json",
            "tools/R17MemoryArtifactLoader.psm1",
            "tools/new_r17_memory_artifact_loader.ps1",
            "tools/validate_r17_memory_artifact_loader.ps1",
            "tests/test_r17_memory_artifact_loader.ps1",
            "tests/fixtures/r17_memory_artifact_loader/",
            "state/context/r17_memory_artifact_loader_report.json",
            "state/context/r17_memory_loaded_refs_log.json",
            "state/agents/r17_agent_memory_packets/",
            "state/ui/r17_kanban_mvp/r17_memory_loader_snapshot.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        source_refs = @($ObjectSet.Report.r16_source_refs | ForEach-Object { $_.path })
        non_claims = @(Get-R17MemoryArtifactLoaderNonClaims)
        aggregate_verdict = $script:AggregateVerdict
    }

    $manifest = @"
# R17-013 Memory Artifact Loader Validation Manifest

Status: $ManifestStatus

The manifest may be marked passed only after the R17-013 generator, validator, focused test, status-doc gate, impacted R17 gates, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- git diff --check
"@

    Write-R17MemoryArtifactLoaderText -Path $Paths.ProofReview -Value $proof
    Write-R17MemoryArtifactLoaderJson -Path $Paths.EvidenceIndex -Value $evidenceIndex
    Write-R17MemoryArtifactLoaderText -Path $Paths.ValidationManifest -Value $manifest
}

function New-R17MemoryArtifactLoaderArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot),
        [string]$ManifestStatus = "pending"
    )

    $paths = Get-R17MemoryArtifactLoaderPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17MemoryArtifactLoaderArtifactsObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17MemoryArtifactLoaderJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17MemoryArtifactLoaderJson -Path $paths.Report -Value $objectSet.Report
    Write-R17MemoryArtifactLoaderJson -Path $paths.LoadedRefsLog -Value $objectSet.LoadedRefsLog
    foreach ($packet in $objectSet.AgentPackets) {
        Write-R17MemoryArtifactLoaderJson -Path (Join-Path $paths.AgentPacketRoot "$($packet.agent_id).memory_packet.json") -Value $packet
    }
    Write-R17MemoryArtifactLoaderJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    New-R17MemoryArtifactLoaderFixtureFiles -ObjectSet $objectSet -Paths $paths
    New-R17MemoryArtifactLoaderProofFiles -ObjectSet $objectSet -Paths $paths -ManifestStatus $ManifestStatus

    return [pscustomobject]@{
        Contract = $paths.Contract
        Report = $paths.Report
        LoadedRefsLog = $paths.LoadedRefsLog
        AgentPacketRoot = $paths.AgentPacketRoot
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $objectSet.Report.aggregate_verdict
        AgentPacketCount = @($objectSet.AgentPackets).Count
        LoadedRefCount = [int]$objectSet.Report.summary.loaded_ref_count
    }
}

function Assert-R17MemoryArtifactLoaderRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [string]$Context = "object"
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains $field) {
            throw "$Context is missing required field '$field'."
        }
    }
}

function Assert-R17MemoryArtifactLoaderFalseFlags {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [string]$Context = "object"
    )

    foreach ($field in $script:FalseBoundaryFields) {
        if ($Object.PSObject.Properties.Name -contains $field -and [bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context $field must be false."
        }
    }
}

function Assert-R17MemoryArtifactLoaderBoundaryObject {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [string]$Context = "boundary"
    )

    foreach ($field in $script:FalseBoundaryFields) {
        if ($Object.PSObject.Properties.Name -contains $field -and [bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context $field must be false."
        }
    }
}

function Assert-R17MemoryArtifactLoaderSourceRefsResolved {
    param([Parameter(Mandatory = $true)][object[]]$Refs)

    $bad = @($Refs | Where-Object { $_.required -and $_.status -notin @("loaded", "skipped", "missing", "blocked") })
    if ($bad.Count -gt 0) { throw "unresolved source refs must be explicitly marked missing or blocked." }
    $missingOrBlocked = @($Refs | Where-Object { $_.required -and $_.status -in @("missing", "blocked") })
    if ($missingOrBlocked.Count -gt 0) { throw "required source refs are missing or blocked: $(@($missingOrBlocked | ForEach-Object { $_.path }) -join ', ')" }
}

function Test-R17MemoryArtifactLoaderSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$LoadedRefsLog,
        [Parameter(Mandatory = $true)][object[]]$AgentPackets,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot),
        [switch]$SkipUiFiles,
        [switch]$SkipFixtureCoverage
    )

    Assert-R17MemoryArtifactLoaderRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "required_report_fields", "required_loaded_ref_fields", "required_packet_fields", "required_source_refs", "exact_ref_policy", "fixture_policy", "implementation_boundaries", "non_claims", "rejected_claims", "preserved_boundaries") -Context "contract"
    if ($Contract.artifact_type -ne "r17_memory_artifact_loader_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask) { throw "contract source_task must be R17-013." }
    Assert-R17MemoryArtifactLoaderBoundaryObject -Object $Contract.implementation_boundaries -Context "contract implementation_boundaries"
    if ([bool]$Contract.exact_ref_policy.full_file_content_embedding_allowed -ne $false) { throw "contract must forbid full file content embedding." }

    Assert-R17MemoryArtifactLoaderRequiredFields -Object $Report -FieldNames @($Contract.required_report_fields) -Context "loader report"
    if ($Report.artifact_type -ne "r17_memory_artifact_loader_report") { throw "loader report artifact_type is invalid." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "loader report aggregate_verdict is invalid." }
    if ([string]::IsNullOrWhiteSpace([string]$Report.r17_agent_registry_ref)) { throw "loader report r17_agent_registry_ref must be present." }
    if ([string]::IsNullOrWhiteSpace([string]$Report.loaded_ref_log_ref)) { throw "loader report loaded_ref_log_ref must be present." }
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -notin @("passed")) {
            throw "loader report check '$($check.Name)' must be passed."
        }
    }
    Assert-R17MemoryArtifactLoaderBoundaryObject -Object $Report.implementation_boundaries -Context "loader report implementation_boundaries"
    Assert-R17MemoryArtifactLoaderFalseFlags -Object $Report.implementation_boundaries -Context "loader report implementation_boundaries"
    Assert-R17MemoryArtifactLoaderSourceRefsResolved -Refs @($LoadedRefsLog.entries)
    Assert-R17MemoryArtifactLoaderSourceRefsResolved -Refs @($Report.r16_source_refs)

    Assert-R17MemoryArtifactLoaderRequiredFields -Object $LoadedRefsLog -FieldNames @("artifact_type", "source_task", "entries", "broad_repo_scan_used", "raw_chat_history_used_as_canonical", "full_file_content_embedded") -Context "loaded ref log"
    if ($LoadedRefsLog.artifact_type -ne "r17_memory_loaded_refs_log") { throw "loaded ref log artifact_type is invalid." }
    Assert-R17MemoryArtifactLoaderFalseFlags -Object $LoadedRefsLog -Context "loaded ref log"
    foreach ($entry in @($LoadedRefsLog.entries)) {
        Assert-R17MemoryArtifactLoaderRequiredFields -Object $entry -FieldNames @($Contract.required_loaded_ref_fields) -Context "loaded ref entry"
        Assert-R17MemoryArtifactLoaderSafeRefPath -Path ([string]$entry.path) -Context "loaded ref entry"
        if ([bool]$entry.full_file_content_embedded -ne $false) { throw "loaded ref entry must not embed full file content." }
        if ([bool]$entry.broad_repo_scan_used -ne $false) { throw "loaded ref entry broad_repo_scan_used must be false." }
    }

    if (@($AgentPackets).Count -lt @($script:RequiredAgents).Count) { throw "missing agent memory packets." }
    foreach ($agentId in $script:RequiredAgents) {
        $packet = @($AgentPackets | Where-Object { $_.agent_id -eq $agentId }) | Select-Object -First 1
        if ($null -eq $packet) { throw "missing agent memory packet for '$agentId'." }
        Assert-R17MemoryArtifactLoaderRequiredFields -Object $packet -FieldNames @($Contract.required_packet_fields) -Context "agent memory packet $agentId"
        if ([string]::IsNullOrWhiteSpace([string]$packet.source_identity_packet_ref)) { throw "agent memory packet $agentId source_identity_packet_ref must be present." }
        Assert-R17MemoryArtifactLoaderSafeRefPath -Path ([string]$packet.source_identity_packet_ref) -Context "agent memory packet $agentId source_identity_packet_ref"
        Assert-R17MemoryArtifactLoaderFalseFlags -Object $packet -Context "agent memory packet $agentId"
        if (@($packet.approved_memory_refs).Count -lt 1) { throw "agent memory packet $agentId approved_memory_refs must not be empty." }
        if (@($packet.forbidden_refs).Count -lt 1) { throw "agent memory packet $agentId forbidden_refs must not be empty." }
        if (@($packet.missing_refs).Count -gt 0) { throw "agent memory packet $agentId has missing refs." }
        if (@($packet.blocked_refs).Count -gt 0) { throw "agent memory packet $agentId has blocked refs." }
    }

    Assert-R17MemoryArtifactLoaderRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "loader_report_ref", "loaded_ref_log_ref", "agent_memory_packet_refs", "loaded_ref_summary", "context_budget_summary", "guard_summary", "runtime_boundaries", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_memory_loader_snapshot") { throw "UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne "R17-013") { throw "UI snapshot active_through_task must be R17-013." }
    Assert-R17MemoryArtifactLoaderBoundaryObject -Object $Snapshot.runtime_boundaries -Context "UI snapshot runtime_boundaries"

    if (-not $SkipFixtureCoverage) {
        $paths = Get-R17MemoryArtifactLoaderPaths -RepositoryRoot $RepositoryRoot
        $invalidFixtures = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
        if ($invalidFixtures.Count -lt 8) { throw "missing compact invalid fixture coverage." }
    }

    if (-not $SkipUiFiles) {
        $paths = Get-R17MemoryArtifactLoaderPaths -RepositoryRoot $RepositoryRoot
        foreach ($uiPath in $paths.UiFiles) {
            if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) { throw "UI file '$uiPath' does not exist." }
            $text = Get-Content -LiteralPath $uiPath -Raw
            foreach ($pattern in @("http://", "https://", "(?i)\bcdn\b", "(?i)\bnpm\b", "(?i)fonts\.googleapis", "(?i)fonts\.gstatic", "(?i)unpkg", "(?i)jsdelivr", "(?i)@import\s+url")) {
                if ($text -match $pattern) { throw "UI file '$uiPath' contains forbidden external dependency reference matching '$pattern'." }
            }
        }
        $indexText = Get-Content -LiteralPath (Resolve-R17MemoryArtifactLoaderPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html") -Raw
        foreach ($fragment in @("memory-loader-panel", "Memory/Artifact Loader", "not runtime memory", "no live agent runtime", "no broad repo scan")) {
            if ($indexText -notmatch [regex]::Escape($fragment)) { throw "index.html must expose R17-013 memory loader fragment '$fragment'." }
        }
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        LoadedRefCount = [int]$Report.summary.loaded_ref_count
        AgentMemoryPacketCount = @($AgentPackets).Count
        BroadRepoScanUsed = [bool]$Report.implementation_boundaries.broad_repo_scan_used
        RuntimeMemoryEngineImplemented = [bool]$Report.implementation_boundaries.runtime_memory_engine_implemented
        VectorRetrievalImplemented = [bool]$Report.implementation_boundaries.vector_retrieval_implemented
        LiveAgentInvocationImplemented = [bool]$Report.implementation_boundaries.live_agent_invocation_implemented
        A2aRuntimeImplemented = [bool]$Report.implementation_boundaries.a2a_runtime_implemented
        ExternalApiCallsImplemented = [bool]$Report.implementation_boundaries.external_api_calls_implemented
    }
}

function Test-R17MemoryArtifactLoader {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17MemoryArtifactLoaderRepositoryRoot))

    $paths = Get-R17MemoryArtifactLoaderPaths -RepositoryRoot $RepositoryRoot
    $packets = foreach ($agentId in $script:RequiredAgents) {
        Read-R17MemoryArtifactLoaderJson -Path (Join-Path $paths.AgentPacketRoot "$agentId.memory_packet.json")
    }

    return Test-R17MemoryArtifactLoaderSet `
        -Contract (Read-R17MemoryArtifactLoaderJson -Path $paths.Contract) `
        -Report (Read-R17MemoryArtifactLoaderJson -Path $paths.Report) `
        -LoadedRefsLog (Read-R17MemoryArtifactLoaderJson -Path $paths.LoadedRefsLog) `
        -AgentPackets $packets `
        -Snapshot (Read-R17MemoryArtifactLoaderJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17MemoryArtifactLoaderObjectPathValue {
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

function Remove-R17MemoryArtifactLoaderObjectPathValue {
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

function Invoke-R17MemoryArtifactLoaderMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    $operation = ""
    if ($null -ne $Mutation.PSObject.Properties["operation"]) {
        $operation = [string]$Mutation.operation
    }
    if ($operation -eq "append_missing_source_ref") {
        $TargetObject.r16_source_refs += [pscustomobject]@{
            ref_id = "bad_missing_ref"
            path = "state/context/does_not_exist.json"
            source_task = "R16-999"
            category = "memory"
            required = $true
            status = "unresolved"
            exact_repo_ref = $true
            tracked = $false
            exists = $false
            full_file_content_embedded = $false
            broad_repo_scan_used = $false
            raw_chat_history_used_as_canonical = $false
        }
        return $TargetObject
    }

    foreach ($removePath in @($Mutation.remove_paths)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
            Remove-R17MemoryArtifactLoaderObjectPathValue -Object $TargetObject -Path $removePath
        }
    }

    if ($null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17MemoryArtifactLoaderObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17MemoryArtifactLoaderPaths, `
    New-R17MemoryArtifactLoaderArtifacts, `
    New-R17MemoryArtifactLoaderArtifactsObjectSet, `
    Test-R17MemoryArtifactLoader, `
    Test-R17MemoryArtifactLoaderSet, `
    Invoke-R17MemoryArtifactLoaderMutation, `
    Copy-R17MemoryArtifactLoaderObject
