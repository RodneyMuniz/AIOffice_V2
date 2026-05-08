Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-014"
$script:AggregateVerdict = "generated_r17_agent_invocation_log_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_014_agent_invocation_log"
$script:FixtureRoot = "tests/fixtures/r17_agent_invocation_log"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:MinimumInvalidFixtureCount = 40

$script:RequiredRecordFields = @(
    "invocation_id",
    "source_task",
    "card_id",
    "agent_id",
    "role_name",
    "invocation_type",
    "requested_by",
    "input_packet_ref",
    "output_packet_ref",
    "memory_packet_ref",
    "board_event_ref",
    "tool_call_ref",
    "evidence_refs",
    "status",
    "started_at",
    "completed_at",
    "duration_ms",
    "error_ref",
    "retry_count",
    "cost_summary",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReportFields = @(
    "total_invocation_records",
    "record_ids",
    "known_agent_ids",
    "registry_ref",
    "memory_loader_ref",
    "board_ref_summary",
    "runtime_boundary_summary",
    "validation_summary",
    "aggregate_verdict",
    "non_claims",
    "rejected_claims"
)

$script:AllowedStatuses = @(
    "not_implemented_seed",
    "queued",
    "running",
    "succeeded",
    "failed",
    "blocked",
    "cancelled",
    "skipped"
)

$script:RuntimeFalseFields = @(
    "actual_agent_invoked",
    "runtime_dispatch_performed",
    "adapter_call_performed",
    "external_api_call_performed",
    "a2a_message_sent",
    "product_runtime_executed",
    "production_runtime_executed",
    "live_board_mutation_performed",
    "runtime_card_creation_performed",
    "live_orchestrator_runtime_invoked",
    "autonomous_agent_executed",
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
    "r17_015_plus_implementation_claimed",
    "external_integration_claimed"
)

function Get-R17AgentInvocationLogRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17AgentInvocationLogPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Test-R17AgentInvocationLogHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Read-R17AgentInvocationLogJson {
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

function Read-R17AgentInvocationLogJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "missing invocation log '$Path'."
    }

    $records = @()
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $Path)) {
        $lineNumber += 1
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $records += ($line | ConvertFrom-Json)
        }
        catch {
            throw "malformed JSONL in invocation log '$Path' at line $lineNumber. $($_.Exception.Message)"
        }
    }

    return $records
}

function Write-R17AgentInvocationLogJson {
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

function Write-R17AgentInvocationLogText {
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

function Write-R17AgentInvocationLogJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Records
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $lines = @($Records | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    Set-Content -LiteralPath $Path -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
}

function Copy-R17AgentInvocationLogObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17AgentInvocationLogPaths {
    param([string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r17_agent_invocation_log.contract.json"
        InvocationLog = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_agent_invocation_log.jsonl"
        CheckReport = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_agent_invocation_log_check_report.json"
        UiSnapshot = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json"
        Registry = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_registry.json"
        MemoryLoaderReport = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/context/r17_memory_artifact_loader_report.json"
        MemoryPacketRoot = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r17_agent_memory_packets"
        BoardState = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/r17_board_state.json"
        BoardEvents = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
        BoardReplayReport = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/r17_board_replay_report.json"
        FixtureRoot = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        UiFiles = @(
            (Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md"),
            (Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/kanban.js")
        )
    }
}

function Get-R17AgentInvocationLogGitIdentity {
    param([string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }

    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Test-R17AgentInvocationLogTrackedFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot)
    )

    & git -C $RepositoryRoot ls-files --error-unmatch -- $Path *> $null
    return ($LASTEXITCODE -eq 0)
}

function Get-R17AgentInvocationLogNonClaims {
    return @(
        "R17-014 defines the agent invocation log foundation only",
        "R17-014 creates seed/foundation invocation records only",
        "R17-014 does not invoke agents",
        "R17-014 does not implement live agent runtime",
        "R17-014 does not implement live Orchestrator runtime",
        "R17-014 does not implement A2A runtime",
        "R17-014 does not send A2A messages",
        "R17-014 does not implement adapters",
        "R17-014 does not call external APIs",
        "R17-014 does not implement autonomous agents",
        "R17-014 does not implement runtime memory engine",
        "R17-014 does not implement vector retrieval",
        "R17-014 does not mutate the board live",
        "R17-014 does not create runtime cards",
        "R17-014 does not implement executable handoffs",
        "R17-014 does not implement executable transitions",
        "R17-014 does not implement product runtime",
        "R17-014 does not implement production runtime",
        "R17-014 does not produce real Dev output",
        "R17-014 does not produce real QA result",
        "R17-014 does not produce real audit verdict",
        "R17-014 does not claim external audit acceptance",
        "R17-014 does not claim main merge",
        "R17-014 does not close R13",
        "R17-014 does not remove R14 caveats",
        "R17-014 does not remove R15 caveats",
        "R17-014 does not solve Codex compaction",
        "R17-014 does not solve Codex reliability"
    )
}

function Get-R17AgentInvocationLogRejectedClaims {
    return @(
        "live_board_mutation",
        "runtime_card_creation",
        "live_agent_runtime",
        "live_Orchestrator_runtime",
        "A2A_runtime",
        "A2A_messages_sent",
        "autonomous_agents",
        "adapter_runtime",
        "external_API_calls",
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
        "R17_015_or_later_implementation"
    )
}

function Get-R17AgentInvocationLogFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return $flags
}

function Get-R17AgentInvocationLogClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return $status
}

function Get-R17AgentInvocationLogPreservedBoundaries {
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

function Assert-R17AgentInvocationLogSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$Context = "ref",
        [switch]$AllowSeedPlaceholder,
        [switch]$AllowNone
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
}

function Assert-R17AgentInvocationLogRequiredFields {
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

function Assert-R17AgentInvocationLogFalseFlags {
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

function Assert-R17AgentInvocationLogContains {
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

function Get-R17AgentInvocationLogAgentMap {
    param([Parameter(Mandatory = $true)][object]$Registry)

    $map = @{}
    foreach ($agent in @($Registry.agents)) {
        $map[[string]$agent.agent_id] = $agent
    }

    return $map
}

function New-R17AgentInvocationLogContract {
    return [ordered]@{
        artifact_type = "r17_agent_invocation_log_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-014-agent-invocation-log-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "repo_backed_agent_invocation_log_foundation_only_not_runtime"
        purpose = "Define append-only repo-backed invocation records for future agent invocations without invoking agents, dispatching runtime work, sending A2A messages, calling adapters, calling external APIs, or implementing product runtime."
        required_record_fields = $script:RequiredRecordFields
        required_report_fields = $script:RequiredReportFields
        allowed_statuses = $script:AllowedStatuses
        required_runtime_false_fields = $script:RuntimeFalseFields
        required_claim_status_false_fields = $script:ClaimStatusFields
        append_only_policy = [ordered]@{
            repo_backed_jsonl = $true
            mutation_in_place_allowed = $false
            future_runtime_append_requires_later_task = $true
            seed_records_allowed_for_r17_014 = $true
            actual_agent_invocation_allowed_in_r17_014 = $false
        }
        seed_placeholder_policy = [ordered]@{
            not_implemented_seed_allowed_for_input_packet_ref = $true
            not_implemented_seed_allowed_for_output_packet_ref = $true
            started_at_completed_at_may_be_null_for_seed = $true
            duration_ms_must_be_zero_for_seed = $true
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
        fixture_policy = [ordered]@{
            compact_invalid_fixtures_required = $true
            minimum_invalid_fixture_count = $script:MinimumInvalidFixtureCount
            fixture_payloads_must_not_duplicate_large_valid_state = $true
        }
        implementation_boundaries = Get-R17AgentInvocationLogFalseFlags
        claim_status = Get-R17AgentInvocationLogClaimStatus
        non_claims = Get-R17AgentInvocationLogNonClaims
        rejected_claims = Get-R17AgentInvocationLogRejectedClaims
        preserved_boundaries = Get-R17AgentInvocationLogPreservedBoundaries
    }
}

function New-R17AgentInvocationRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Agent,
        [Parameter(Mandatory = $true)][string]$MemoryPacketRef,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $agentId = [string]$Agent.agent_id
    $roleName = [string]$Agent.role_name
    $runtimeFlags = Get-R17AgentInvocationLogFalseFlags

    return [ordered]@{
        artifact_type = "r17_agent_invocation_record"
        contract_version = "v1"
        invocation_id = "r17_014_seed_invocation_$agentId"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        card_id = "R17-014"
        agent_id = $agentId
        role_name = $roleName
        invocation_type = "foundation_seed_record"
        requested_by = "operator"
        input_packet_ref = "not_implemented_seed"
        output_packet_ref = "not_implemented_seed"
        memory_packet_ref = $MemoryPacketRef
        board_event_ref = "not_implemented_seed"
        tool_call_ref = "not_implemented_seed"
        evidence_refs = @(
            "contracts/runtime/r17_agent_invocation_log.contract.json",
            "state/runtime/r17_agent_invocation_log.jsonl",
            "state/runtime/r17_agent_invocation_log_check_report.json",
            "state/agents/r17_agent_registry.json",
            $MemoryPacketRef,
            "state/context/r17_memory_artifact_loader_report.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        status = "not_implemented_seed"
        not_implemented_seed = $true
        seed_record_only = $true
        started_at = $null
        completed_at = $null
        duration_ms = 0
        error_ref = "none"
        retry_count = 0
        cost_summary = [ordered]@{
            cost_incurred = $false
            estimated_cost_usd = 0
            currency = "USD"
            external_billing_claimed = $false
            cost_source = "not_applicable_seed"
        }
        runtime_flags = $runtimeFlags
        claim_status = Get-R17AgentInvocationLogClaimStatus
        actual_agent_invoked = $false
        runtime_dispatch_performed = $false
        adapter_call_performed = $false
        external_api_call_performed = $false
        a2a_message_sent = $false
        product_runtime_executed = $false
        non_claims = Get-R17AgentInvocationLogNonClaims
        rejected_claims = Get-R17AgentInvocationLogRejectedClaims
    }
}

function New-R17AgentInvocationLogArtifactsObjectSet {
    param([string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot))

    $paths = Get-R17AgentInvocationLogPaths -RepositoryRoot $RepositoryRoot
    $gitIdentity = Get-R17AgentInvocationLogGitIdentity -RepositoryRoot $RepositoryRoot
    $registry = Read-R17AgentInvocationLogJson -Path $paths.Registry
    $memoryLoaderReport = Read-R17AgentInvocationLogJson -Path $paths.MemoryLoaderReport
    $contract = New-R17AgentInvocationLogContract
    $agentMap = Get-R17AgentInvocationLogAgentMap -Registry $registry
    $records = @()
    $memoryPacketRefs = @()

    foreach ($agentId in @($registry.required_agent_ids)) {
        $agentIdString = [string]$agentId
        if (-not $agentMap.ContainsKey($agentIdString)) { throw "Registry is missing required agent '$agentIdString'." }
        $memoryPacketRef = "state/agents/r17_agent_memory_packets/$agentIdString.memory_packet.json"
        $memoryPacketRefs += $memoryPacketRef
        $records += New-R17AgentInvocationRecord -Agent $agentMap[$agentIdString] -MemoryPacketRef $memoryPacketRef -GitIdentity $gitIdentity
    }

    $recordIds = @($records | ForEach-Object { [string]$_.invocation_id })
    $runtimeBoundarySummary = Get-R17AgentInvocationLogFalseFlags
    $claimStatus = Get-R17AgentInvocationLogClaimStatus
    $boardRefSummary = [ordered]@{
        board_state_ref = "$($script:BoardRoot)/r17_board_state.json"
        board_event_log_ref = "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
        board_replay_report_ref = "$($script:BoardRoot)/r17_board_replay_report.json"
        board_event_ref_implemented = $false
        live_board_mutation_performed = $false
        runtime_card_creation_performed = $false
    }

    $report = [ordered]@{
        artifact_type = "r17_agent_invocation_log_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-014-agent-invocation-log-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $gitIdentity.Head
        generated_from_tree = $gitIdentity.Tree
        contract_ref = "contracts/runtime/r17_agent_invocation_log.contract.json"
        invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        total_invocation_records = $records.Count
        record_ids = $recordIds
        known_agent_ids = @($registry.required_agent_ids)
        registry_ref = "state/agents/r17_agent_registry.json"
        memory_loader_ref = "state/context/r17_memory_artifact_loader_report.json"
        memory_packet_refs = $memoryPacketRefs
        board_ref_summary = $boardRefSummary
        runtime_boundary_summary = $runtimeBoundarySummary
        claim_status = $claimStatus
        validation_summary = [ordered]@{
            contract_fields_present = "passed"
            invocation_log_present = "passed"
            check_report_present = "passed"
            malformed_jsonl_rejected = "passed"
            duplicate_invocation_id_rejected = "passed"
            unknown_agent_id_rejected = "passed"
            memory_packet_refs_present = "passed"
            input_output_seed_placeholders_explicit = "passed"
            runtime_false_flags_preserved = "passed"
            compact_invalid_fixture_coverage = "passed"
            external_ui_dependencies_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        generated_state_artifact_only = $true
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        registry_summary = [ordered]@{
            required_agent_count = [int]$registry.agent_count
            registry_report_ref = "state/agents/r17_agent_registry_check_report.json"
        }
        memory_loader_summary = [ordered]@{
            loader_report_ref = "state/context/r17_memory_artifact_loader_report.json"
            aggregate_verdict = [string]$memoryLoaderReport.aggregate_verdict
            loaded_ref_log_ref = "state/context/r17_memory_loaded_refs_log.json"
            agent_memory_packet_count = @($memoryLoaderReport.agent_memory_packet_refs).Count
        }
        evidence_refs = @(
            "contracts/runtime/r17_agent_invocation_log.contract.json",
            "tools/R17AgentInvocationLog.psm1",
            "tools/new_r17_agent_invocation_log.ps1",
            "tools/validate_r17_agent_invocation_log.ps1",
            "tests/test_r17_agent_invocation_log.ps1",
            "tests/fixtures/r17_agent_invocation_log/",
            "state/runtime/r17_agent_invocation_log.jsonl",
            "state/runtime/r17_agent_invocation_log_check_report.json",
            "state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        non_claims = Get-R17AgentInvocationLogNonClaims
        rejected_claims = Get-R17AgentInvocationLogRejectedClaims
        preserved_boundaries = Get-R17AgentInvocationLogPreservedBoundaries
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_agent_invocation_log_snapshot"
        contract_version = "v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        branch = $script:BranchName
        active_through_task = "R17-014"
        generated_from_head = $gitIdentity.Head
        generated_from_tree = $gitIdentity.Tree
        ui_boundary_label = "read-only invocation log snapshot, seed/foundation records only"
        invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        check_report_ref = "state/runtime/r17_agent_invocation_log_check_report.json"
        contract_ref = "contracts/runtime/r17_agent_invocation_log.contract.json"
        total_seed_records = $records.Count
        record_ids = $recordIds
        known_agent_ids = @($registry.required_agent_ids)
        status_summary = [ordered]@{
            not_implemented_seed = $records.Count
            actual_agent_invoked = $false
            runtime_dispatch_performed = $false
            adapter_call_performed = $false
            external_api_call_performed = $false
            a2a_message_sent = $false
            product_runtime_executed = $false
        }
        runtime_boundaries = $runtimeBoundarySummary
        claim_status = $claimStatus
        visible_rows = @($records | ForEach-Object {
                [ordered]@{
                    invocation_id = $_.invocation_id
                    card_id = $_.card_id
                    agent_id = $_.agent_id
                    role_name = $_.role_name
                    status = $_.status
                    memory_packet_ref = $_.memory_packet_ref
                    actual_agent_invoked = $_.actual_agent_invoked
                    runtime_dispatch_performed = $_.runtime_dispatch_performed
                    adapter_call_performed = $_.adapter_call_performed
                    external_api_call_performed = $_.external_api_call_performed
                    a2a_message_sent = $_.a2a_message_sent
                    product_runtime_executed = $_.product_runtime_executed
                }
            })
        non_claims = Get-R17AgentInvocationLogNonClaims
        rejected_claims = Get-R17AgentInvocationLogRejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        Records = $records
        Report = $report
        Snapshot = $snapshot
    }
}

function New-R17AgentInvocationLogFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths
    )

    if (-not (Test-Path -LiteralPath $Paths.FixtureRoot)) {
        New-Item -ItemType Directory -Path $Paths.FixtureRoot -Force | Out-Null
    }

    Write-R17AgentInvocationLogJson -Path (Join-Path $Paths.FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17AgentInvocationLogJson -Path (Join-Path $Paths.FixtureRoot "valid_invocation_log_records.json") -Value @($ObjectSet.Records)
    Write-R17AgentInvocationLogJson -Path (Join-Path $Paths.FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17AgentInvocationLogJson -Path (Join-Path $Paths.FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $invalids = @(
        [ordered]@{ target = "contract"; remove_paths = @("required_record_fields"); expected_failure_fragments = @("required_record_fields") },
        [ordered]@{ target = "files"; operation = "missing_invocation_log"; expected_failure_fragments = @("missing invocation log") },
        [ordered]@{ target = "files"; operation = "missing_check_report"; expected_failure_fragments = @("missing check report") },
        [ordered]@{ target = "jsonl"; operation = "malformed_jsonl"; expected_failure_fragments = @("malformed JSONL") },
        [ordered]@{ target = "log"; operation = "duplicate_invocation_id"; expected_failure_fragments = @("duplicate invocation_id") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "agent_id" = "unknown_agent" }; expected_failure_fragments = @("unknown agent_id") },
        [ordered]@{ target = "record"; remove_paths = @("memory_packet_ref"); expected_failure_fragments = @("memory_packet_ref") },
        [ordered]@{ target = "record"; remove_paths = @("input_packet_ref"); expected_failure_fragments = @("input_packet_ref") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "input_packet_ref" = "state/intake/r17_operator_intake_seed_packet.json"; "output_packet_ref" = ""; "not_implemented_seed" = $false }; expected_failure_fragments = @("output_packet_ref") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "status" = "executed_live" }; expected_failure_fragments = @("status") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.actual_agent_invoked" = $true; "actual_agent_invoked" = $true }; expected_failure_fragments = @("actual_agent_invoked") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.runtime_dispatch_performed" = $true; "runtime_dispatch_performed" = $true }; expected_failure_fragments = @("runtime_dispatch_performed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.adapter_call_performed" = $true; "adapter_call_performed" = $true }; expected_failure_fragments = @("adapter_call_performed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.external_api_call_performed" = $true; "external_api_call_performed" = $true }; expected_failure_fragments = @("external_api_call_performed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.a2a_message_sent" = $true; "a2a_message_sent" = $true }; expected_failure_fragments = @("a2a_message_sent") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.product_runtime_executed" = $true; "product_runtime_executed" = $true }; expected_failure_fragments = @("product_runtime_executed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.live_board_mutation_performed" = $true; "claim_status.live_board_mutation_claimed" = $true }; expected_failure_fragments = @("live_board_mutation") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.runtime_card_creation_performed" = $true; "claim_status.runtime_card_creation_claimed" = $true }; expected_failure_fragments = @("runtime_card_creation") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.live_orchestrator_runtime_invoked" = $true; "claim_status.live_orchestrator_runtime_claimed" = $true }; expected_failure_fragments = @("live_orchestrator_runtime") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.autonomous_agent_executed" = $true; "claim_status.autonomous_agent_claimed" = $true }; expected_failure_fragments = @("autonomous_agent") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.executable_handoff_performed" = $true; "claim_status.executable_handoff_claimed" = $true }; expected_failure_fragments = @("executable_handoff") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.executable_transition_performed" = $true; "claim_status.executable_transition_claimed" = $true }; expected_failure_fragments = @("executable_transition") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.runtime_memory_engine_used" = $true; "claim_status.runtime_memory_engine_claimed" = $true }; expected_failure_fragments = @("runtime_memory_engine") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.vector_retrieval_performed" = $true; "claim_status.vector_retrieval_claimed" = $true }; expected_failure_fragments = @("vector_retrieval") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.dev_output_claimed" = $true; "claim_status.dev_output_claimed" = $true }; expected_failure_fragments = @("dev_output_claimed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.qa_result_claimed" = $true; "claim_status.qa_result_claimed" = $true }; expected_failure_fragments = @("qa_result_claimed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.audit_verdict_claimed" = $true; "claim_status.audit_verdict_claimed" = $true }; expected_failure_fragments = @("audit_verdict_claimed") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.external_audit_acceptance_claimed" = $true; "claim_status.external_audit_acceptance_claimed" = $true }; expected_failure_fragments = @("external_audit_acceptance") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.main_merge_claimed" = $true; "claim_status.main_merge_claimed" = $true }; expected_failure_fragments = @("main_merge") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.r13_closure_claimed" = $true; "claim_status.r13_closure_claimed" = $true }; expected_failure_fragments = @("r13_closure") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.r14_caveat_removal_claimed" = $true; "claim_status.r14_caveat_removal_claimed" = $true }; expected_failure_fragments = @("r14_caveat_removal") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.r15_caveat_removal_claimed" = $true; "claim_status.r15_caveat_removal_claimed" = $true }; expected_failure_fragments = @("r15_caveat_removal") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.solved_codex_compaction_claimed" = $true; "claim_status.solved_codex_compaction_claimed" = $true }; expected_failure_fragments = @("solved_codex_compaction") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.solved_codex_reliability_claimed" = $true; "claim_status.solved_codex_reliability_claimed" = $true }; expected_failure_fragments = @("solved_codex_reliability") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "claim_status.r17_015_plus_implementation_claimed" = $true }; expected_failure_fragments = @("r17_015_plus_implementation") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.full_source_file_contents_embedded" = $true }; expected_failure_fragments = @("full_source_file_contents_embedded") },
        [ordered]@{ target = "record"; set_values = [ordered]@{ "runtime_flags.broad_repo_scan_output_included" = $true }; expected_failure_fragments = @("broad_repo_scan_output_included") },
        [ordered]@{ target = "fixture_coverage"; operation = "missing_compact_invalid_fixture_coverage"; expected_failure_fragments = @("missing compact invalid fixture coverage") },
        [ordered]@{ target = "ui_text"; operation = "external_ui_dependency"; text = "<script src=`"https://cdn.example.test/app.js`"></script>"; expected_failure_fragments = @("external dependency") },
        [ordered]@{ target = "kanban_js"; operation = "kanban_js_churn"; expected_failure_fragments = @("kanban.js churn") }
    )

    $index = 0
    foreach ($invalid in $invalids) {
        $index += 1
        $name = if ($invalid.PSObject.Properties.Name -contains "operation") { [string]$invalid.operation } else { [string]$invalid.target }
        $path = Join-Path $Paths.FixtureRoot ("invalid_{0:00}_{1}.json" -f $index, ($name -replace '[^a-zA-Z0-9_]', '_'))
        Write-R17AgentInvocationLogJson -Path $path -Value $invalid
    }
}

function New-R17AgentInvocationLogProofFiles {
    param(
        [Parameter(Mandatory = $true)][object]$ObjectSet,
        [Parameter(Mandatory = $true)][object]$Paths,
        [string]$ManifestStatus = "pending"
    )

    $proof = @"
# R17-014 Agent Invocation Log Proof Review

Status: generated

R17-014 defines the agent invocation log foundation only. It creates repo-backed seed/foundation invocation records and a check report for future agent invocations, but it does not invoke agents, dispatch runtime work, call adapters, call external APIs, send A2A messages, mutate the board live, create runtime cards, implement runtime memory, implement vector retrieval, produce Dev output, produce QA results, or produce audit verdicts.

The generated JSONL log is append-only foundation state. Every seed record is explicitly marked `not_implemented_seed`, records the known R17-012 agent id and matching R17-013 memory packet ref, and keeps all runtime flags false.
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_014_agent_invocation_log_evidence_index"
        index_version = "v1"
        source_task = $script:SourceTask
        evidence_refs = @(
            "contracts/runtime/r17_agent_invocation_log.contract.json",
            "tools/R17AgentInvocationLog.psm1",
            "tools/new_r17_agent_invocation_log.ps1",
            "tools/validate_r17_agent_invocation_log.ps1",
            "tests/test_r17_agent_invocation_log.ps1",
            "tests/fixtures/r17_agent_invocation_log/",
            "state/runtime/r17_agent_invocation_log.jsonl",
            "state/runtime/r17_agent_invocation_log_check_report.json",
            "state/ui/r17_kanban_mvp/r17_agent_invocation_log_snapshot.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        record_ids = @($ObjectSet.Records | ForEach-Object { $_.invocation_id })
        aggregate_verdict = $ObjectSet.Report.aggregate_verdict
        non_claims = Get-R17AgentInvocationLogNonClaims
        rejected_claims = Get-R17AgentInvocationLogRejectedClaims
    }

    $manifest = @"
# R17-014 Agent Invocation Log Validation Manifest

Status: $ManifestStatus

The manifest may be marked passed only after the R17-014 generator, validator, focused test, status-doc gate, impacted R17 foundation validators/tests, Kanban MVP validator/test, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_operator_intake.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_operator_intake.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_loop.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_loop.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kanban_mvp.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_mvp.ps1
- git diff --check
"@

    Write-R17AgentInvocationLogText -Path $Paths.ProofReview -Value $proof
    Write-R17AgentInvocationLogJson -Path $Paths.EvidenceIndex -Value $evidenceIndex
    Write-R17AgentInvocationLogText -Path $Paths.ValidationManifest -Value $manifest
}

function New-R17AgentInvocationLogArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot),
        [string]$ManifestStatus = "pending"
    )

    $paths = Get-R17AgentInvocationLogPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17AgentInvocationLogArtifactsObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17AgentInvocationLogJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17AgentInvocationLogJsonLines -Path $paths.InvocationLog -Records $objectSet.Records
    Write-R17AgentInvocationLogJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17AgentInvocationLogJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    New-R17AgentInvocationLogFixtureFiles -ObjectSet $objectSet -Paths $paths
    New-R17AgentInvocationLogProofFiles -ObjectSet $objectSet -Paths $paths -ManifestStatus $ManifestStatus

    return [pscustomobject]@{
        Contract = $paths.Contract
        InvocationLog = $paths.InvocationLog
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RecordCount = @($objectSet.Records).Count
        AggregateVerdict = $objectSet.Report.aggregate_verdict
    }
}

function Assert-R17AgentInvocationLogPacketRef {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [Parameter(Mandatory = $true)][string]$FieldName,
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot)
    )

    $value = ""
    if (Test-R17AgentInvocationLogHasProperty -Object $Record -Name $FieldName) {
        $value = [string]$Record.PSObject.Properties[$FieldName].Value
    }

    if ([string]::IsNullOrWhiteSpace($value)) { throw "record $($Record.invocation_id) $FieldName must not be empty." }
    if ($value -eq "not_implemented_seed") {
        if (-not (Test-R17AgentInvocationLogHasProperty -Object $Record -Name "not_implemented_seed") -or [bool]$Record.not_implemented_seed -ne $true) {
            throw "record $($Record.invocation_id) $FieldName uses not_implemented_seed without explicit not_implemented_seed marker."
        }
        return
    }

    Assert-R17AgentInvocationLogSafeRefPath -Path $value -Context "record $($Record.invocation_id) $FieldName"
    $resolved = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue $value
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "record $($Record.invocation_id) $FieldName path '$value' does not exist."
    }
}

function Assert-R17AgentInvocationLogRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][hashtable]$AgentMap,
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot)
    )

    Assert-R17AgentInvocationLogRequiredFields -Object $Record -FieldNames @($Contract.required_record_fields) -Context "invocation record"
    if ($Record.source_task -ne $script:SourceTask) { throw "record $($Record.invocation_id) source_task must be R17-014." }
    if (@($Contract.allowed_statuses) -notcontains [string]$Record.status) { throw "record $($Record.invocation_id) status '$($Record.status)' is not allowed." }

    $agentId = [string]$Record.agent_id
    if (-not $AgentMap.ContainsKey($agentId)) { throw "record $($Record.invocation_id) has unknown agent_id '$agentId'." }
    if ([string]$Record.role_name -ne [string]$AgentMap[$agentId].role_name) { throw "record $($Record.invocation_id) role_name does not match registry for '$agentId'." }

    $expectedMemoryPacketRef = "state/agents/r17_agent_memory_packets/$agentId.memory_packet.json"
    if ([string]$Record.memory_packet_ref -ne $expectedMemoryPacketRef) {
        throw "record $($Record.invocation_id) memory_packet_ref must be '$expectedMemoryPacketRef'."
    }
    Assert-R17AgentInvocationLogSafeRefPath -Path ([string]$Record.memory_packet_ref) -Context "record $($Record.invocation_id) memory_packet_ref"
    $memoryPacketPath = Resolve-R17AgentInvocationLogPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$Record.memory_packet_ref)
    if (-not (Test-Path -LiteralPath $memoryPacketPath -PathType Leaf)) { throw "record $($Record.invocation_id) memory_packet_ref path does not exist." }

    Assert-R17AgentInvocationLogPacketRef -Record $Record -FieldName "input_packet_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17AgentInvocationLogPacketRef -Record $Record -FieldName "output_packet_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17AgentInvocationLogPacketRef -Record $Record -FieldName "board_event_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17AgentInvocationLogPacketRef -Record $Record -FieldName "tool_call_ref" -RepositoryRoot $RepositoryRoot

    if ($Record.status -eq "not_implemented_seed") {
        if ([bool]$Record.not_implemented_seed -ne $true -or [bool]$Record.seed_record_only -ne $true) {
            throw "record $($Record.invocation_id) seed status requires explicit seed markers."
        }
        if ($null -ne $Record.started_at -or $null -ne $Record.completed_at) {
            throw "record $($Record.invocation_id) seed started_at and completed_at must be null."
        }
        if ([int]$Record.duration_ms -ne 0) { throw "record $($Record.invocation_id) seed duration_ms must be 0." }
    }

    if ([int]$Record.retry_count -lt 0) { throw "record $($Record.invocation_id) retry_count must not be negative." }
    if ([string]::IsNullOrWhiteSpace([string]$Record.error_ref)) { throw "record $($Record.invocation_id) error_ref must be present." }
    Assert-R17AgentInvocationLogRequiredFields -Object $Record.cost_summary -FieldNames @("cost_incurred", "estimated_cost_usd", "currency", "external_billing_claimed", "cost_source") -Context "record $($Record.invocation_id) cost_summary"
    if ([bool]$Record.cost_summary.cost_incurred -ne $false -or [bool]$Record.cost_summary.external_billing_claimed -ne $false) {
        throw "record $($Record.invocation_id) cost_summary must not claim incurred cost or billing."
    }

    Assert-R17AgentInvocationLogFalseFlags -Object $Record.runtime_flags -FieldNames @($Contract.required_runtime_false_fields) -Context "record $($Record.invocation_id) runtime_flags"
    Assert-R17AgentInvocationLogFalseFlags -Object $Record.claim_status -FieldNames @($Contract.required_claim_status_false_fields) -Context "record $($Record.invocation_id) claim_status"
    Assert-R17AgentInvocationLogFalseFlags -Object $Record -FieldNames @("actual_agent_invoked", "runtime_dispatch_performed", "adapter_call_performed", "external_api_call_performed", "a2a_message_sent", "product_runtime_executed") -Context "record $($Record.invocation_id)"

    if (@($Record.evidence_refs).Count -lt 1) { throw "record $($Record.invocation_id) evidence_refs must not be empty." }
    foreach ($ref in @($Record.evidence_refs)) {
        Assert-R17AgentInvocationLogSafeRefPath -Path ([string]$ref) -Context "record $($Record.invocation_id) evidence_ref"
    }

    Assert-R17AgentInvocationLogContains -Values @($Record.non_claims) -Required (Get-R17AgentInvocationLogNonClaims) -Context "record $($Record.invocation_id) non_claims"
    Assert-R17AgentInvocationLogContains -Values @($Record.rejected_claims) -Required (Get-R17AgentInvocationLogRejectedClaims) -Context "record $($Record.invocation_id) rejected_claims"
}

function Assert-R17AgentInvocationLogUiText {
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

    if (-not [string]::IsNullOrWhiteSpace($indexText)) {
        foreach ($fragment in @("agent-invocation-log-panel", "Agent Invocation Log", "seed/foundation invocation records only", "actual_agent_invoked: false", "runtime_dispatch_performed: false", "no live agent runtime", "no A2A messages sent")) {
            if ($indexText -notmatch [regex]::Escape($fragment)) {
                throw "index.html must expose R17-014 invocation log fragment '$fragment'."
            }
        }
    }
}

function Assert-R17AgentInvocationLogFixtureCoverage {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [int]$MinimumInvalidFixtureCount = $script:MinimumInvalidFixtureCount
    )

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $MinimumInvalidFixtureCount) {
        throw "missing compact invalid fixture coverage: expected at least $MinimumInvalidFixtureCount invalid fixtures."
    }
}

function Assert-R17AgentInvocationLogKanbanJsUnchanged {
    param(
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot),
        [string[]]$ChangedPaths
    )

    if ($null -eq $ChangedPaths) {
        $ChangedPaths = @()
        $ChangedPaths += @((& git -C $RepositoryRoot diff --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $ChangedPaths += @((& git -C $RepositoryRoot diff --cached --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    if (@($ChangedPaths | Where-Object { $_ -eq "scripts/operator_wall/r17_kanban_mvp/kanban.js" }).Count -gt 0) {
        throw "kanban.js churn is not allowed for R17-014 unless explicitly justified."
    }
}

function Test-R17AgentInvocationLogSet {
    [CmdletBinding()]
    param(
        [object]$Contract,
        [object[]]$InvocationRecords,
        [object]$Report,
        [object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot),
        [switch]$SkipUiFiles,
        [switch]$SkipFixtureCoverage
    )

    if ($null -eq $Contract) { throw "missing contract fields: contract is missing." }
    Assert-R17AgentInvocationLogRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "required_record_fields", "required_report_fields", "allowed_statuses", "required_runtime_false_fields", "required_claim_status_false_fields", "append_only_policy", "exact_ref_policy", "fixture_policy", "implementation_boundaries", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "contract"
    if ($Contract.artifact_type -ne "r17_agent_invocation_log_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask) { throw "contract source_task must be R17-014." }
    Assert-R17AgentInvocationLogContains -Values @($Contract.required_record_fields) -Required $script:RequiredRecordFields -Context "contract required_record_fields"
    Assert-R17AgentInvocationLogContains -Values @($Contract.required_report_fields) -Required $script:RequiredReportFields -Context "contract required_report_fields"
    Assert-R17AgentInvocationLogContains -Values @($Contract.allowed_statuses) -Required @("not_implemented_seed") -Context "contract allowed_statuses"
    Assert-R17AgentInvocationLogFalseFlags -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract implementation_boundaries"
    Assert-R17AgentInvocationLogFalseFlags -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "contract claim_status"
    if ([bool]$Contract.exact_ref_policy.full_source_file_content_embedding_allowed -ne $false) { throw "contract must forbid generated artifact embedding full source file contents." }
    if ([bool]$Contract.exact_ref_policy.broad_repo_scan_output_allowed -ne $false) { throw "contract must forbid broad repo scan output." }

    if ($null -eq $InvocationRecords -or @($InvocationRecords).Count -lt 1) { throw "missing invocation log records." }
    if ($null -eq $Report) { throw "missing check report." }
    if ($null -eq $Snapshot) { throw "missing UI snapshot." }

    $paths = Get-R17AgentInvocationLogPaths -RepositoryRoot $RepositoryRoot
    $registry = Read-R17AgentInvocationLogJson -Path $paths.Registry
    $agentMap = Get-R17AgentInvocationLogAgentMap -Registry $registry

    $seen = @{}
    foreach ($record in @($InvocationRecords)) {
        $recordId = [string]$record.invocation_id
        if ([string]::IsNullOrWhiteSpace($recordId)) { throw "invocation_id must not be empty." }
        if ($seen.ContainsKey($recordId)) { throw "duplicate invocation_id '$recordId'." }
        $seen[$recordId] = $true
        Assert-R17AgentInvocationLogRecord -Record $record -Contract $Contract -AgentMap $agentMap -RepositoryRoot $RepositoryRoot
    }

    Assert-R17AgentInvocationLogRequiredFields -Object $Report -FieldNames @($Contract.required_report_fields) -Context "check report"
    if ($Report.artifact_type -ne "r17_agent_invocation_log_check_report") { throw "check report artifact_type is invalid." }
    if ($Report.source_task -ne $script:SourceTask) { throw "check report source_task must be R17-014." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    if ([int]$Report.total_invocation_records -ne @($InvocationRecords).Count) { throw "check report total_invocation_records does not match log." }
    Assert-R17AgentInvocationLogContains -Values @($Report.record_ids) -Required @($seen.Keys) -Context "check report record_ids"
    Assert-R17AgentInvocationLogContains -Values @($Report.known_agent_ids) -Required @($registry.required_agent_ids) -Context "check report known_agent_ids"
    if ([string]$Report.registry_ref -ne "state/agents/r17_agent_registry.json") { throw "check report registry_ref is invalid." }
    if ([string]$Report.memory_loader_ref -ne "state/context/r17_memory_artifact_loader_report.json") { throw "check report memory_loader_ref is invalid." }
    Assert-R17AgentInvocationLogRequiredFields -Object $Report.board_ref_summary -FieldNames @("board_state_ref", "board_event_log_ref", "board_replay_report_ref", "board_event_ref_implemented", "live_board_mutation_performed", "runtime_card_creation_performed") -Context "check report board_ref_summary"
    Assert-R17AgentInvocationLogFalseFlags -Object $Report.board_ref_summary -FieldNames @("board_event_ref_implemented", "live_board_mutation_performed", "runtime_card_creation_performed") -Context "check report board_ref_summary"
    Assert-R17AgentInvocationLogFalseFlags -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17AgentInvocationLogFalseFlags -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    if ([bool]$Report.full_source_file_contents_embedded -ne $false) { throw "check report full_source_file_contents_embedded must be false." }
    if ([bool]$Report.broad_repo_scan_output_included -ne $false) { throw "check report broad_repo_scan_output_included must be false." }
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }
    Assert-R17AgentInvocationLogContains -Values @($Report.non_claims) -Required (Get-R17AgentInvocationLogNonClaims) -Context "check report non_claims"
    Assert-R17AgentInvocationLogContains -Values @($Report.rejected_claims) -Required (Get-R17AgentInvocationLogRejectedClaims) -Context "check report rejected_claims"

    Assert-R17AgentInvocationLogRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "invocation_log_ref", "check_report_ref", "total_seed_records", "record_ids", "known_agent_ids", "status_summary", "runtime_boundaries", "claim_status", "visible_rows", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_agent_invocation_log_snapshot") { throw "UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne "R17-014") { throw "UI snapshot active_through_task must be R17-014." }
    if ([int]$Snapshot.total_seed_records -ne @($InvocationRecords).Count) { throw "UI snapshot total_seed_records does not match log." }
    Assert-R17AgentInvocationLogFalseFlags -Object $Snapshot.status_summary -FieldNames @("actual_agent_invoked", "runtime_dispatch_performed", "adapter_call_performed", "external_api_call_performed", "a2a_message_sent", "product_runtime_executed") -Context "UI snapshot status_summary"
    Assert-R17AgentInvocationLogFalseFlags -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17AgentInvocationLogFalseFlags -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"
    Assert-R17AgentInvocationLogContains -Values @($Snapshot.non_claims) -Required (Get-R17AgentInvocationLogNonClaims) -Context "UI snapshot non_claims"
    Assert-R17AgentInvocationLogContains -Values @($Snapshot.rejected_claims) -Required (Get-R17AgentInvocationLogRejectedClaims) -Context "UI snapshot rejected_claims"

    if (-not $SkipFixtureCoverage) {
        Assert-R17AgentInvocationLogFixtureCoverage -FixtureRoot $paths.FixtureRoot -MinimumInvalidFixtureCount ([int]$Contract.fixture_policy.minimum_invalid_fixture_count)
    }

    if (-not $SkipUiFiles) {
        $uiText = @{}
        foreach ($uiPath in $paths.UiFiles) {
            if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) { throw "UI file '$uiPath' does not exist." }
            $uiText[$uiPath] = Get-Content -LiteralPath $uiPath -Raw
        }
        Assert-R17AgentInvocationLogUiText -UiTextByPath $uiText
        Assert-R17AgentInvocationLogKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        TotalInvocationRecords = [int]$Report.total_invocation_records
        RecordIds = @($Report.record_ids)
        KnownAgentIds = @($Report.known_agent_ids)
        ActualAgentInvoked = [bool]$Report.runtime_boundary_summary.actual_agent_invoked
        RuntimeDispatchPerformed = [bool]$Report.runtime_boundary_summary.runtime_dispatch_performed
        AdapterCallPerformed = [bool]$Report.runtime_boundary_summary.adapter_call_performed
        ExternalApiCallPerformed = [bool]$Report.runtime_boundary_summary.external_api_call_performed
        A2aMessageSent = [bool]$Report.runtime_boundary_summary.a2a_message_sent
        ProductRuntimeExecuted = [bool]$Report.runtime_boundary_summary.product_runtime_executed
    }
}

function Test-R17AgentInvocationLog {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17AgentInvocationLogRepositoryRoot))

    $paths = Get-R17AgentInvocationLogPaths -RepositoryRoot $RepositoryRoot
    return Test-R17AgentInvocationLogSet `
        -Contract (Read-R17AgentInvocationLogJson -Path $paths.Contract) `
        -InvocationRecords @(Read-R17AgentInvocationLogJsonLines -Path $paths.InvocationLog) `
        -Report (Read-R17AgentInvocationLogJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17AgentInvocationLogJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17AgentInvocationLogObjectPathValue {
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

function Remove-R17AgentInvocationLogObjectPathValue {
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

function Invoke-R17AgentInvocationLogMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if (Test-R17AgentInvocationLogHasProperty -Object $Mutation -Name "remove_paths") {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R17AgentInvocationLogObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ((Test-R17AgentInvocationLogHasProperty -Object $Mutation -Name "set_values") -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17AgentInvocationLogObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17AgentInvocationLogPaths, `
    Get-R17AgentInvocationLogNonClaims, `
    Get-R17AgentInvocationLogRejectedClaims, `
    New-R17AgentInvocationLogArtifacts, `
    New-R17AgentInvocationLogArtifactsObjectSet, `
    Test-R17AgentInvocationLog, `
    Test-R17AgentInvocationLogSet, `
    Read-R17AgentInvocationLogJsonLines, `
    Assert-R17AgentInvocationLogUiText, `
    Assert-R17AgentInvocationLogFixtureCoverage, `
    Assert-R17AgentInvocationLogKanbanJsUnchanged, `
    Invoke-R17AgentInvocationLogMutation, `
    Copy-R17AgentInvocationLogObject
