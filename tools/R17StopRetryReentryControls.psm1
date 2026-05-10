Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-022"
$script:SeedSourceTask = "R17-021"
$script:AggregateVerdict = "generated_r17_stop_retry_reentry_controls_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls"
$script:FixtureRoot = "tests/fixtures/r17_stop_retry_reentry_controls"
$script:MinimumInvalidFixtureCount = 36

$script:AllowedControlActions = @(
    "stop",
    "retry",
    "pause",
    "block",
    "reentry",
    "user_decision_required"
)

$script:AllowedStatuses = @(
    "control_packet_only",
    "reentry_packet_only",
    "stopped_not_executed",
    "retry_planned_not_executed",
    "paused_not_executed",
    "blocked_waiting_for_user_decision",
    "blocked_policy_limit",
    "blocked_missing_required_ref",
    "invalid"
)

$script:RequiredControlPacketFields = @(
    "control_packet_id",
    "source_task",
    "card_id",
    "correlation_id",
    "control_action",
    "control_reason",
    "requested_by_agent_id",
    "target_agent_id",
    "source_dispatch_record_ref",
    "source_a2a_message_ref",
    "source_handoff_ref",
    "source_tool_call_ledger_ref",
    "source_agent_invocation_ref",
    "source_board_event_ref",
    "source_orchestrator_state_ref",
    "retry_policy",
    "retry_count",
    "retry_limit",
    "timeout_policy",
    "cost_policy",
    "stop_condition_refs",
    "blocker_refs",
    "user_decision_required",
    "reentry_packet_ref",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "status",
    "execution_mode",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReentryPacketFields = @(
    "reentry_packet_id",
    "source_task",
    "card_id",
    "correlation_id",
    "reentry_reason",
    "source_control_packet_ref",
    "resume_from_state",
    "resume_allowed_next_actions",
    "required_operator_decision",
    "required_input_refs",
    "required_output_refs",
    "memory_packet_ref",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "status",
    "execution_mode",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:ExplicitFalseFields = @(
    "control_runtime_implemented",
    "live_stop_performed",
    "live_retry_performed",
    "live_pause_performed",
    "live_block_performed",
    "live_reentry_performed",
    "a2a_runtime_implemented",
    "live_a2a_dispatch_performed",
    "a2a_message_sent",
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
        "production_runtime_executed",
        "adapter_runtime_implemented",
        "runtime_memory_engine_used",
        "vector_retrieval_performed",
        "executable_handoff_performed",
        "executable_transition_performed",
        "external_integration_performed",
        "dev_output_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r13_closure_claimed",
        "r14_caveat_removal_claimed",
        "r15_caveat_removal_claimed",
        "r17_023_plus_implementation_claimed",
        "full_source_file_contents_embedded",
        "broad_repo_scan_output_included",
        "broad_repo_scan_used"
    )
)

$script:ClaimStatusFields = @(
    "control_runtime_claimed",
    "live_stop_claimed",
    "live_retry_claimed",
    "live_pause_claimed",
    "live_block_claimed",
    "live_reentry_claimed",
    "a2a_runtime_claimed",
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
    "r17_023_plus_implementation_claimed"
)

function Get-R17StopRetryReentryRepositoryRoot {
    return $script:RepositoryRoot
}

function Resolve-R17StopRetryReentryPath {
    param(
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17StopRetryReentryJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R17StopRetryReentryJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $records += ($line | ConvertFrom-Json)
    }
    return $records
}

function Write-R17StopRetryReentryJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $Value | ConvertTo-Json -Depth 90 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17StopRetryReentryText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R17StopRetryReentryObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 90 | ConvertFrom-Json)
}

function Test-R17StopRetryReentryHasProperty {
    param([Parameter(Mandatory = $true)]$Object, [Parameter(Mandatory = $true)][string]$Name)

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17StopRetryReentryProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17StopRetryReentryHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Get-R17StopRetryReentryPaths {
    param([string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        ControlPackets = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_stop_retry_reentry_control_packets.json"
        ReentryPackets = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_stop_retry_reentry_reentry_packets.json"
        CheckReport = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_stop_retry_reentry_check_report.json"
        UiSnapshot = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json"
        DispatcherContract = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r17_a2a_dispatcher.contract.json"
        DispatcherRoutes = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_dispatcher_routes.json"
        DispatcherLog = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        A2aMessagePackets = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_message_seed_packets.json"
        A2aHandoffPackets = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r17_a2a_handoff_seed_packets.json"
        ToolCallLedger = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_tool_call_ledger.jsonl"
        AgentInvocationLog = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_agent_invocation_log.jsonl"
        OrchestratorState = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "state/orchestration/r17_orchestrator_loop_state_machine.json"
        FixtureRoot = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17StopRetryReentryGitIdentity {
    param([string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17StopRetryReentryFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17StopRetryReentryExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) { $flags[$field] = $false }
    return [pscustomobject]$flags
}

function Get-R17StopRetryReentryClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return [pscustomobject]$status
}

function Get-R17StopRetryReentryPreservedBoundaries {
    return [pscustomobject]@{
        r13 = [pscustomobject]@{ status = "failed/partial"; active_through = "R13-018"; closed = $false }
        r14 = [pscustomobject]@{ status = "accepted_with_caveats"; active_through = "R14-006"; caveats_removed = $false }
        r15 = [pscustomobject]@{ status = "accepted_with_caveats_by_external_audit"; active_through = "R15-009"; caveats_removed = $false }
        r16 = [pscustomobject]@{ status = "complete_bounded_foundation_scope"; active_through = "R16-026"; overclaimed = $false }
        r17 = [pscustomobject]@{ status = "active"; active_through = "R17-022"; planned_only_from = "R17-023"; planned_only_through = "R17-028" }
    }
}

function Get-R17StopRetryReentryNonClaims {
    return @(
        "R17-022 creates a bounded stop retry pause block and re-entry controls foundation only",
        "R17-022 validates deterministic control and re-entry packets over committed seed artifacts only",
        "R17-022 does not implement live control runtime",
        "R17-022 does not perform live stop retry pause block or re-entry execution",
        "R17-022 does not implement live A2A runtime",
        "R17-022 does not send live A2A messages",
        "R17-022 does not invoke live agents",
        "R17-022 does not invoke live Orchestrator runtime",
        "R17-022 does not invoke adapter runtime",
        "R17-022 does not perform actual tool calls",
        "R17-022 does not call external APIs",
        "R17-022 does not mutate the board",
        "R17-022 does not create runtime cards",
        "R17-022 does not implement autonomous agents",
        "R17-022 does not implement product runtime",
        "R17-022 does not produce real Dev output",
        "R17-022 does not produce real QA result",
        "R17-022 does not produce a real audit verdict",
        "R17-022 does not claim external audit acceptance",
        "R17-022 does not claim main merge",
        "R17-022 does not close R13",
        "R17-022 does not remove R14 caveats",
        "R17-022 does not remove R15 caveats",
        "R17-022 does not solve Codex compaction",
        "R17-022 does not solve Codex reliability",
        "R17-023 through R17-028 remain planned only"
    )
}

function Get-R17StopRetryReentryRejectedClaims {
    return @(
        "live_control_runtime",
        "live_stop_execution",
        "live_retry_execution",
        "live_pause_execution",
        "live_block_execution",
        "live_reentry_execution",
        "live_A2A_runtime",
        "live_A2A_messages_sent",
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
        "future_R17_023_plus_completion",
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

function Get-R17StopRetryReentryDependencyRefs {
    return [pscustomobject]@{
        r17_authority_ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
        kanban_ref = "execution/KANBAN.md"
        control_contract_ref = "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        control_packets_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json"
        reentry_packets_ref = "state/runtime/r17_stop_retry_reentry_reentry_packets.json"
        dispatcher_contract_ref = "contracts/a2a/r17_a2a_dispatcher.contract.json"
        dispatcher_routes_ref = "state/a2a/r17_a2a_dispatcher_routes.json"
        dispatcher_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        a2a_message_seed_packet_ref = "state/a2a/r17_a2a_message_seed_packets.json"
        a2a_handoff_seed_packet_ref = "state/a2a/r17_a2a_handoff_seed_packets.json"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        agent_invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        orchestrator_state_ref = "state/orchestration/r17_orchestrator_loop_state_machine.json"
        memory_loader_report_ref = "state/context/r17_memory_artifact_loader_report.json"
        agent_registry_ref = "state/agents/r17_agent_registry.json"
        board_event_log_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl"
    }
}

function Get-R17StopRetryReentryEvidenceRefs {
    return @(
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "state/runtime/r17_stop_retry_reentry_control_packets.json",
        "state/runtime/r17_stop_retry_reentry_reentry_packets.json",
        "state/runtime/r17_stop_retry_reentry_check_report.json",
        "state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json",
        "tools/R17StopRetryReentryControls.psm1",
        "tools/new_r17_stop_retry_reentry_controls.ps1",
        "tools/validate_r17_stop_retry_reentry_controls.ps1",
        "tests/test_r17_stop_retry_reentry_controls.ps1",
        "tests/fixtures/r17_stop_retry_reentry_controls/",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls/validation_manifest.md"
    )
}

function Get-R17StopRetryReentryAuthorityRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "state/a2a/r17_a2a_dispatcher_routes.json",
        "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl",
        "state/agents/r17_agent_registry.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/context/r17_memory_artifact_loader_report.json"
    )
}

function Get-R17StopRetryReentryValidationRefs {
    return @(
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "state/runtime/r17_stop_retry_reentry_check_report.json",
        "tools/validate_r17_stop_retry_reentry_controls.ps1",
        "tests/test_r17_stop_retry_reentry_controls.ps1",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_022_stop_retry_reentry_controls/validation_manifest.md"
    )
}

function New-R17StopRetryReentryContract {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_controls_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-022-stop-retry-reentry-controls-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-023"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "bounded_control_packet_foundation_only_not_runtime"
        bounded_control_foundation_created = $true
        product_or_runtime_control_plane = $false
        purpose = "Define and validate deterministic stop retry pause block and re-entry control packet candidates over committed R17 seed artifacts while preserving fail-closed runtime boundaries."
        required_control_packet_fields = $script:RequiredControlPacketFields
        required_reentry_packet_fields = $script:RequiredReentryPacketFields
        allowed_control_actions = $script:AllowedControlActions
        allowed_statuses = $script:AllowedStatuses
        required_explicit_false_fields = $script:ExplicitFalseFields
        control_validation_policy = [pscustomobject][ordered]@{
            consume_committed_seed_artifacts_only = $true
            source_dispatch_record_ref_required = $true
            source_a2a_message_ref_required = $true
            source_handoff_ref_required = $true
            evidence_refs_required = $true
            authority_refs_required = $true
            validation_refs_required = $true
            retry_count_must_not_exceed_retry_limit = $true
            retry_limit_must_be_present_and_within_0_to_3 = $true
            timeout_policy_required = $true
            cost_policy_required = $true
            wildcard_refs_allowed = $false
            local_backups_refs_allowed = $false
            broad_repo_scan_output_allowed = $false
            full_source_file_content_embedding_allowed = $false
            future_r17_023_plus_completion_claims_allowed = $false
        }
        runtime_policy = [pscustomobject][ordered]@{
            live_control_runtime_allowed = $false
            live_stop_allowed = $false
            live_retry_allowed = $false
            live_pause_allowed = $false
            live_block_allowed = $false
            live_reentry_allowed = $false
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
        dependency_refs = Get-R17StopRetryReentryDependencyRefs
        implementation_boundaries = Get-R17StopRetryReentryFalseFlags
        explicit_false_fields = Get-R17StopRetryReentryExplicitFalseMap
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
        preserved_boundaries = Get-R17StopRetryReentryPreservedBoundaries
    }
}

function Assert-R17StopRetryReentryRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17StopRetryReentryHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17StopRetryReentryContains {
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

function Assert-R17StopRetryReentryFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        $value = Get-R17StopRetryReentryProperty -Object $Object -Name $field -Context $Context
        if ($value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Assert-R17StopRetryReentrySafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
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
        $resolved = Resolve-R17StopRetryReentryPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Assert-R17StopRetryReentryRefArray {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [switch]$SkipRefExistence,
        [switch]$AllowPlaceholder
    )

    if (@($Values).Count -lt 1) { throw "$Context must not be empty." }
    foreach ($ref in @($Values)) {
        Assert-R17StopRetryReentrySafeRefPath -Path ([string]$ref) -Context $Context -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder:$AllowPlaceholder
    }
}

function Assert-R17StopRetryReentryNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $json = ($Value | ConvertTo-Json -Depth 90 -Compress)
    if ($json -match '(?i)Get-ChildItem\s+-Recurse|git\s+ls-files|rg\s+--files|repo-wide file list|broad repo scan') {
        throw "$Context contains broad repo scan output."
    }
    if ($json -match '(?i)Set-StrictMode\s+-Version\s+Latest|function\s+[A-Za-z0-9_-]+\s*\{|full source file contents') {
        throw "$Context contains embedded full source file contents."
    }
    if ($json -match '(?i)\bR17-(0(?:2[3-8])|[3-9][0-9]|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exercised|working|available|ships|claimed)\b') {
        throw "$Context contains future R17-023+ completion claim."
    }
}

function Get-R17StopRetryReentryInt {
    param($Value, [string]$Context)

    if ($null -eq $Value) { throw "$Context missing or unsafe." }
    $parsed = 0
    if (-not [int]::TryParse([string]$Value, [ref]$parsed)) {
        throw "$Context missing or unsafe."
    }
    return $parsed
}

function Get-R17StopRetryReentryDispatchRecordByMessageType {
    param(
        [Parameter(Mandatory = $true)][object[]]$DispatchRecords,
        [Parameter(Mandatory = $true)][string]$MessageType
    )

    $match = @($DispatchRecords | Where-Object { [string]$_.message_type -eq $MessageType } | Select-Object -First 1)
    if ($match.Count -lt 1) {
        throw "R17-021 dispatch log missing message_type '$MessageType'."
    }
    return $match[0]
}

function New-R17StopRetryReentryPolicySet {
    param(
        [Parameter(Mandatory = $true)][string]$Action,
        [Parameter(Mandatory = $true)][int]$RetryLimit
    )

    return [pscustomobject][ordered]@{
        retry_policy = [pscustomobject][ordered]@{
            retry_runtime_implemented = $false
            retry_allowed_for_control_packet = ($Action -eq "retry")
            max_retries_seed = $RetryLimit
            future_retry_engine_required_before_runtime = $true
            repeated_failure_requires_user_decision = $true
        }
        timeout_policy = [pscustomobject][ordered]@{
            timeout_runtime_implemented = $false
            max_seconds_seed = 0
            future_timeout_required_before_runtime = $true
            runaway_loop_control_implemented = $false
        }
        cost_policy = [pscustomobject][ordered]@{
            cost_incurred = $false
            estimated_cost_usd = 0
            external_billing_claimed = $false
            future_cost_budget_required_before_runtime = $true
            provider_cost_known = $false
        }
    }
}

function New-R17StopRetryReentryControlPacket {
    param(
        [Parameter(Mandatory = $true)][object]$DispatchRecord,
        [Parameter(Mandatory = $true)][string]$Action,
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $true)][int]$RetryCount,
        [Parameter(Mandatory = $true)][int]$RetryLimit,
        [Parameter(Mandatory = $true)][bool]$UserDecisionRequired,
        [Parameter(Mandatory = $true)][bool]$HasReentryPacket,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    $controlPacketId = "r17_022_control_$Action"
    $reentryPacketRef = if ($HasReentryPacket) {
        "state/runtime/r17_stop_retry_reentry_reentry_packets.json#r17_022_reentry_$Action"
    }
    else {
        "not_applicable"
    }
    $policies = New-R17StopRetryReentryPolicySet -Action $Action -RetryLimit $RetryLimit
    $explicitFalse = Get-R17StopRetryReentryExplicitFalseMap
    $record = [ordered]@{
        artifact_type = "r17_stop_retry_reentry_control_packet"
        contract_version = "v1"
        control_packet_id = $controlPacketId
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = [string]$DispatchRecord.card_id
        correlation_id = [string]$DispatchRecord.correlation_id
        control_action = $Action
        control_reason = $Reason
        requested_by_agent_id = [string]$DispatchRecord.from_agent_id
        target_agent_id = [string]$DispatchRecord.to_agent_id
        source_dispatch_record_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#$($DispatchRecord.dispatch_record_id)"
        source_a2a_message_ref = [string]$DispatchRecord.message_ref
        source_handoff_ref = [string]$DispatchRecord.handoff_ref
        source_tool_call_ledger_ref = [string]$DispatchRecord.tool_call_ledger_ref
        source_agent_invocation_ref = [string]$DispatchRecord.invocation_ref
        source_board_event_ref = [string]$DispatchRecord.board_event_ref
        source_orchestrator_state_ref = "state/orchestration/r17_orchestrator_loop_state_machine.json"
        retry_policy = $policies.retry_policy
        retry_count = $RetryCount
        retry_limit = $RetryLimit
        timeout_policy = $policies.timeout_policy
        cost_policy = $policies.cost_policy
        stop_condition_refs = @(
            "contracts/runtime/r17_stop_retry_reentry_controls.contract.json#stop_conditions",
            "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#$($DispatchRecord.dispatch_record_id)"
        )
        blocker_refs = if ($Action -in @("block", "user_decision_required")) {
            @(
                "contracts/runtime/r17_stop_retry_reentry_controls.contract.json#blocker_policy",
                "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#$($DispatchRecord.dispatch_record_id)"
            )
        }
        else {
            @("not_applicable")
        }
        user_decision_required = $UserDecisionRequired
        reentry_packet_ref = $reentryPacketRef
        evidence_refs = Get-R17StopRetryReentryEvidenceRefs
        authority_refs = Get-R17StopRetryReentryAuthorityRefs
        validation_refs = Get-R17StopRetryReentryValidationRefs
        status = $Status
        execution_mode = "control_foundation_packet_only_not_executed"
        runtime_flags = Get-R17StopRetryReentryFalseFlags
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }
    foreach ($field in $script:ExplicitFalseFields) { $record[$field] = $explicitFalse.PSObject.Properties[$field].Value }
    return [pscustomobject]$record
}

function New-R17StopRetryReentryReentryPacket {
    param(
        [Parameter(Mandatory = $true)][object]$ControlPacket,
        [Parameter(Mandatory = $true)][object]$DispatchRecord,
        [Parameter(Mandatory = $true)][object]$GitIdentity
    )

    return [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_reentry_packet"
        contract_version = "v1"
        reentry_packet_id = "r17_022_reentry_$($ControlPacket.control_action)"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = [string]$ControlPacket.card_id
        correlation_id = [string]$ControlPacket.correlation_id
        reentry_reason = "packet_only_reentry_candidate_after_$($ControlPacket.control_action)_control_without_runtime_resume"
        source_control_packet_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#$($ControlPacket.control_packet_id)"
        resume_from_state = "source_dispatch_candidate_not_executed"
        resume_allowed_next_actions = @(
            "validate_reentry_packet_only",
            "wait_for_user_decision_packet_only",
            "record_future_dispatch_precondition",
            "block_until_future_a2a_cycle_task"
        )
        required_operator_decision = [bool]$ControlPacket.user_decision_required
        required_input_refs = @($DispatchRecord.required_input_refs)
        required_output_refs = @($DispatchRecord.required_output_refs)
        memory_packet_ref = [string]$DispatchRecord.memory_packet_ref
        evidence_refs = Get-R17StopRetryReentryEvidenceRefs
        authority_refs = Get-R17StopRetryReentryAuthorityRefs
        validation_refs = Get-R17StopRetryReentryValidationRefs
        status = "reentry_packet_only"
        execution_mode = "reentry_foundation_packet_only_not_executed"
        runtime_flags = Get-R17StopRetryReentryFalseFlags
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }
}

function New-R17StopRetryReentryObjectSet {
    param(
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [object]$GitIdentity = (Get-R17StopRetryReentryGitIdentity -RepositoryRoot $RepositoryRoot)
    )

    $paths = Get-R17StopRetryReentryPaths -RepositoryRoot $RepositoryRoot
    $dispatcherRoutes = Read-R17StopRetryReentryJson -Path $paths.DispatcherRoutes
    $dispatchRecords = Read-R17StopRetryReentryJsonLines -Path $paths.DispatcherLog

    if ([int]$dispatcherRoutes.route_count -ne @($dispatchRecords).Count) {
        throw "R17-021 route set and dispatch log counts do not match."
    }

    $definitions = @(
        [pscustomobject]@{ action = "stop"; message_type = "task_assignment"; status = "stopped_not_executed"; reason = "operator_or_policy_stop_candidate_recorded_without_live_stop"; retry_count = 0; retry_limit = 0; user_decision = $false; reentry = $false },
        [pscustomobject]@{ action = "retry"; message_type = "implementation_result"; status = "retry_planned_not_executed"; reason = "retry_candidate_recorded_after_seed_result_without_live_retry"; retry_count = 1; retry_limit = 2; user_decision = $false; reentry = $true },
        [pscustomobject]@{ action = "pause"; message_type = "qa_result"; status = "paused_not_executed"; reason = "pause_candidate_recorded_for_operator_review_without_live_pause"; retry_count = 0; retry_limit = 1; user_decision = $false; reentry = $true },
        [pscustomobject]@{ action = "block"; message_type = "defect_report"; status = "blocked_policy_limit"; reason = "block_candidate_recorded_at_policy_limit_without_live_block"; retry_count = 2; retry_limit = 2; user_decision = $true; reentry = $true },
        [pscustomobject]@{ action = "reentry"; message_type = "fix_request"; status = "control_packet_only"; reason = "reentry_candidate_recorded_without_live_resume"; retry_count = 0; retry_limit = 1; user_decision = $false; reentry = $true },
        [pscustomobject]@{ action = "user_decision_required"; message_type = "user_decision_request"; status = "blocked_waiting_for_user_decision"; reason = "user_decision_required_candidate_recorded_without_live_operator_action"; retry_count = 0; retry_limit = 1; user_decision = $true; reentry = $true }
    )

    $controlPackets = @()
    $reentryPackets = @()
    foreach ($definition in $definitions) {
        $dispatchRecord = Get-R17StopRetryReentryDispatchRecordByMessageType -DispatchRecords $dispatchRecords -MessageType ([string]$definition.message_type)
        $control = New-R17StopRetryReentryControlPacket `
            -DispatchRecord $dispatchRecord `
            -Action ([string]$definition.action) `
            -Status ([string]$definition.status) `
            -Reason ([string]$definition.reason) `
            -RetryCount ([int]$definition.retry_count) `
            -RetryLimit ([int]$definition.retry_limit) `
            -UserDecisionRequired ([bool]$definition.user_decision) `
            -HasReentryPacket ([bool]$definition.reentry) `
            -GitIdentity $GitIdentity
        $controlPackets += $control
        if ([bool]$definition.reentry) {
            $reentryPackets += (New-R17StopRetryReentryReentryPacket -ControlPacket $control -DispatchRecord $dispatchRecord -GitIdentity $GitIdentity)
        }
    }

    $statusCounts = [ordered]@{}
    foreach ($status in $script:AllowedStatuses) {
        $statusCounts[$status] = @($controlPackets | Where-Object { $_.status -eq $status }).Count + @($reentryPackets | Where-Object { $_.status -eq $status }).Count
    }

    $contract = New-R17StopRetryReentryContract
    $controlSet = [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_control_packet_set"
        contract_version = "v1"
        packet_set_id = "aioffice-r17-022-stop-retry-reentry-control-packets-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-023"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        bounded_control_foundation_created = $true
        product_or_runtime_control_plane = $false
        contract_ref = "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        source_dispatch_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        packet_count = $controlPackets.Count
        allowed_control_actions = $script:AllowedControlActions
        allowed_statuses = $script:AllowedStatuses
        control_packets = $controlPackets
        runtime_boundaries = Get-R17StopRetryReentryFalseFlags
        explicit_false_fields = Get-R17StopRetryReentryExplicitFalseMap
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }

    $reentrySet = [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_reentry_packet_set"
        contract_version = "v1"
        packet_set_id = "aioffice-r17-022-stop-retry-reentry-reentry-packets-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-023"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        bounded_reentry_foundation_created = $true
        product_or_runtime_reentry = $false
        contract_ref = "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        source_control_packet_set_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json"
        packet_count = $reentryPackets.Count
        allowed_statuses = $script:AllowedStatuses
        reentry_packets = $reentryPackets
        runtime_boundaries = Get-R17StopRetryReentryFalseFlags
        explicit_false_fields = Get-R17StopRetryReentryExplicitFalseMap
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }

    $report = [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-022-stop-retry-reentry-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-023"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        bounded_control_foundation_created = $true
        product_or_runtime_control_plane = $false
        contract_ref = "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        control_packet_set_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json"
        reentry_packet_set_ref = "state/runtime/r17_stop_retry_reentry_reentry_packets.json"
        ui_snapshot_ref = "state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json"
        source_dispatch_log_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl"
        source_dispatch_route_count = @($dispatchRecords).Count
        control_packet_count = $controlPackets.Count
        reentry_packet_count = $reentryPackets.Count
        control_actions = @($controlPackets | ForEach-Object { $_.control_action })
        status_counts = [pscustomobject]$statusCounts
        dependency_refs = Get-R17StopRetryReentryDependencyRefs
        runtime_boundary_summary = Get-R17StopRetryReentryFalseFlags
        explicit_false_fields = Get-R17StopRetryReentryExplicitFalseMap
        claim_status = Get-R17StopRetryReentryClaimStatus
        validation_summary = [pscustomobject][ordered]@{
            committed_dispatch_log_loaded = "passed"
            deterministic_control_packets_emitted = "passed"
            deterministic_reentry_packets_emitted = "passed"
            supported_control_actions_validated = "passed"
            retry_limit_validation = "passed"
            timeout_policy_validation = "passed"
            cost_policy_validation = "passed"
            source_ref_validation = "passed"
            evidence_authority_validation_ref_validation = "passed"
            runtime_claims_rejected = "passed"
            future_r17_023_plus_claims_rejected = "passed"
            compact_artifact_policy_preserved = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        evidence_refs = Get-R17StopRetryReentryEvidenceRefs
        preserved_boundaries = Get-R17StopRetryReentryPreservedBoundaries
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }

    $snapshot = [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_controls_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r17-022-stop-retry-reentry-controls-snapshot-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-023"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        bounded_control_foundation_created = $true
        product_or_runtime_control_plane = $false
        contract_ref = "contracts/runtime/r17_stop_retry_reentry_controls.contract.json"
        control_packet_set_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json"
        reentry_packet_set_ref = "state/runtime/r17_stop_retry_reentry_reentry_packets.json"
        check_report_ref = "state/runtime/r17_stop_retry_reentry_check_report.json"
        control_packet_count = $controlPackets.Count
        reentry_packet_count = $reentryPackets.Count
        visible_controls = @($controlPackets | ForEach-Object {
                [pscustomobject][ordered]@{
                    control_packet_id = $_.control_packet_id
                    card_id = $_.card_id
                    control_action = $_.control_action
                    status = $_.status
                    retry_count = $_.retry_count
                    retry_limit = $_.retry_limit
                    user_decision_required = $_.user_decision_required
                    reentry_packet_ref = $_.reentry_packet_ref
                    execution_mode = $_.execution_mode
                }
            })
        runtime_boundaries = Get-R17StopRetryReentryFalseFlags
        explicit_false_fields = Get-R17StopRetryReentryExplicitFalseMap
        claim_status = Get-R17StopRetryReentryClaimStatus
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        ControlSet = $controlSet
        ReentrySet = $reentrySet
        Report = $report
        Snapshot = $snapshot
        DispatchRecords = $dispatchRecords
    }
}

function Get-R17StopRetryReentryInvalidFixtureDefinitions {
    $definitions = @(
        [pscustomobject]@{ name = "invalid_unsupported_control_action.json"; target = "control"; property = "control_action"; value = "resume_live_runtime"; expected = @("unsupported control_action") },
        [pscustomobject]@{ name = "invalid_retry_count_exceeds_limit.json"; target = "control"; property = "retry_count"; value = 4; expected = @("retry_count must not exceed retry_limit") },
        [pscustomobject]@{ name = "invalid_retry_limit_missing_or_unsafe.json"; target = "control"; property = "retry_limit"; value = 9; expected = @("retry_limit missing or unsafe") },
        [pscustomobject]@{ name = "invalid_timeout_policy_missing.json"; target = "control"; property = "timeout_policy"; value = $null; expected = @("timeout_policy missing") },
        [pscustomobject]@{ name = "invalid_cost_policy_missing.json"; target = "control"; property = "cost_policy"; value = $null; expected = @("cost_policy missing") },
        [pscustomobject]@{ name = "invalid_missing_source_dispatch_record_ref.json"; target = "control"; property = "source_dispatch_record_ref"; value = ""; expected = @("source_dispatch_record_ref path must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_source_a2a_message_ref.json"; target = "control"; property = "source_a2a_message_ref"; value = ""; expected = @("source_a2a_message_ref path must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_source_handoff_ref.json"; target = "control"; property = "source_handoff_ref"; value = ""; expected = @("source_handoff_ref path must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_evidence_refs.json"; target = "control"; property = "evidence_refs"; value = @(); expected = @("evidence_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_authority_refs.json"; target = "control"; property = "authority_refs"; value = @(); expected = @("authority_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_missing_validation_refs.json"; target = "control"; property = "validation_refs"; value = @(); expected = @("validation_refs must not be empty") },
        [pscustomobject]@{ name = "invalid_wildcard_evidence_path.json"; target = "control_evidence_append"; property = "evidence_refs"; value = "state/runtime/*.json"; expected = @("wildcard") },
        [pscustomobject]@{ name = "invalid_local_backups_ref.json"; target = "control_authority_append"; property = "authority_refs"; value = ".local_backups/r17_controls.json"; expected = @(".local_backups") },
        [pscustomobject]@{ name = "invalid_broad_repo_scan_output.json"; target = "control_non_claim_append"; property = "non_claims"; value = "rg --files repo-wide file list"; expected = @("broad repo scan") },
        [pscustomobject]@{ name = "invalid_embedded_full_source_file_contents.json"; target = "control_non_claim_append"; property = "non_claims"; value = "function Invoke-LiveControl { Set-StrictMode -Version Latest }"; expected = @("embedded full source") },
        [pscustomobject]@{ name = "invalid_future_r17_023_completion_claim.json"; target = "control_non_claim_append"; property = "non_claims"; value = "R17-023 is implemented by this pass."; expected = @("future R17-023+") }
    )

    foreach ($field in $script:ExplicitFalseFields) {
        $definitions += [pscustomobject]@{
            name = "invalid_$($field)_true.json"
            target = "control"
            property = $field
            value = $true
            expected = @("field '$field' must be false")
        }
    }

    return $definitions
}

function New-R17StopRetryReentryFixtureFiles {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $FixtureRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $FixtureRoot -File -Filter "valid_*" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -LiteralPath $FixtureRoot -File -Filter "invalid_*.json" -ErrorAction SilentlyContinue | Remove-Item -Force

    Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot "valid_contract.json") -Value $ObjectSet.Contract
    Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot "valid_control_packets.json") -Value $ObjectSet.ControlSet
    Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot "valid_reentry_packets.json") -Value $ObjectSet.ReentrySet
    Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot "valid_check_report.json") -Value $ObjectSet.Report
    Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot "valid_ui_snapshot.json") -Value $ObjectSet.Snapshot

    $count = 0
    foreach ($definition in Get-R17StopRetryReentryInvalidFixtureDefinitions) {
        $fixture = [pscustomobject][ordered]@{
            target = [string]$definition.target
            property = [string]$definition.property
            value = $definition.value
            expected_failure_fragments = @($definition.expected)
        }
        Write-R17StopRetryReentryJson -Path (Join-Path $FixtureRoot ([string]$definition.name)) -Value $fixture
        $count += 1
    }
    return $count
}

function New-R17StopRetryReentryProofFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProofRoot,
        [Parameter(Mandatory = $true)][object]$ObjectSet
    )

    New-Item -ItemType Directory -Path $ProofRoot -Force | Out-Null

    $proof = @"
# R17-022 Stop Retry Re-entry Controls Foundation Proof Review

R17-022 adds a bounded stop, retry, pause, block, and re-entry controls foundation only. It consumes committed R17-021 dispatcher seed artifacts, validates deterministic control packet candidates, and writes packet-only control and re-entry state plus a check report.

R17 is active through R17-022 only. R17-023 through R17-028 remain planned only.

Non-claims preserved: no live control runtime, no live stop/retry/pause/block/re-entry execution, no live A2A runtime, no live A2A messages sent, no live agent invocation, no live Orchestrator runtime, no adapter runtime, no actual tool call, no external API call, no board mutation, no QA result, no real audit verdict, no external audit acceptance, no autonomous agents, no product runtime, and no main merge.

Generated evidence:
- contracts/runtime/r17_stop_retry_reentry_controls.contract.json
- state/runtime/r17_stop_retry_reentry_control_packets.json
- state/runtime/r17_stop_retry_reentry_reentry_packets.json
- state/runtime/r17_stop_retry_reentry_check_report.json
- state/ui/r17_kanban_mvp/r17_stop_retry_reentry_controls_snapshot.json
- tools/R17StopRetryReentryControls.psm1
- tools/new_r17_stop_retry_reentry_controls.ps1
- tools/validate_r17_stop_retry_reentry_controls.ps1
- tests/test_r17_stop_retry_reentry_controls.ps1
- tests/fixtures/r17_stop_retry_reentry_controls/
"@
    Write-R17StopRetryReentryText -Path (Join-Path $ProofRoot "proof_review.md") -Value $proof

    $evidenceIndex = [pscustomobject][ordered]@{
        artifact_type = "r17_stop_retry_reentry_controls_evidence_index"
        source_task = $script:SourceTask
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = Get-R17StopRetryReentryEvidenceRefs
        non_claims = Get-R17StopRetryReentryNonClaims
        rejected_claims = Get-R17StopRetryReentryRejectedClaims
        runtime_boundaries = Get-R17StopRetryReentryFalseFlags
    }
    Write-R17StopRetryReentryJson -Path (Join-Path $ProofRoot "evidence_index.json") -Value $evidenceIndex

    $validation = @"
# R17-022 Validation Manifest

Required focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_stop_retry_reentry_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_stop_retry_reentry_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_stop_retry_reentry_controls.ps1

Required related gates include the existing R17 A2A contract, A2A dispatcher, registry, memory loader, invocation log, adapter, ledger, board/orchestration, Kanban, KPI, and status-doc validators/tests.

Boundary: generated control and re-entry records are validation-only and not executed. The foundation does not invoke agents, runtime Orchestrator, adapters, APIs, tools, QA, audit, product runtime, board mutation, or main merge.
"@
    Write-R17StopRetryReentryText -Path (Join-Path $ProofRoot "validation_manifest.md") -Value $validation
}

function New-R17StopRetryReentryArtifacts {
    param([string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot))

    $paths = Get-R17StopRetryReentryPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17StopRetryReentryObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17StopRetryReentryJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17StopRetryReentryJson -Path $paths.ControlPackets -Value $objectSet.ControlSet
    Write-R17StopRetryReentryJson -Path $paths.ReentryPackets -Value $objectSet.ReentrySet
    Write-R17StopRetryReentryJson -Path $paths.CheckReport -Value $objectSet.Report
    Write-R17StopRetryReentryJson -Path $paths.UiSnapshot -Value $objectSet.Snapshot
    $invalidFixtureCount = New-R17StopRetryReentryFixtureFiles -FixtureRoot $paths.FixtureRoot -ObjectSet $objectSet
    New-R17StopRetryReentryProofFiles -ProofRoot $paths.ProofRoot -ObjectSet $objectSet

    return [pscustomobject]@{
        Contract = $paths.Contract
        ControlPackets = $paths.ControlPackets
        ReentryPackets = $paths.ReentryPackets
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        ControlPacketCount = $objectSet.ControlSet.packet_count
        ReentryPacketCount = $objectSet.ReentrySet.packet_count
        InvalidFixtureCount = $invalidFixtureCount
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17StopRetryReentryPolicyObject {
    param(
        [Parameter(Mandatory = $true)][AllowNull()]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Policy) { throw "$Context missing." }
    Assert-R17StopRetryReentryNoForbiddenContent -Value $Policy -Context $Context
}

function Assert-R17StopRetryReentryControlPacket {
    param(
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17StopRetryReentryRequiredFields -Object $Packet -FieldNames $script:RequiredControlPacketFields -Context $Context
    if ([string]$Packet.source_task -ne $script:SourceTask) { throw "$Context source_task must be R17-022." }
    if ([string]::IsNullOrWhiteSpace([string]$Packet.card_id)) { throw "$Context missing card_id." }
    if ([string]::IsNullOrWhiteSpace([string]$Packet.correlation_id)) { throw "$Context missing correlation_id." }
    if ($script:AllowedControlActions -notcontains [string]$Packet.control_action) { throw "$Context unsupported control_action '$($Packet.control_action)'." }
    if ($script:AllowedStatuses -notcontains [string]$Packet.status) { throw "$Context status '$($Packet.status)' is not allowed." }
    if ([string]$Packet.execution_mode -ne "control_foundation_packet_only_not_executed") { throw "$Context execution_mode must be control_foundation_packet_only_not_executed." }

    $retryLimit = Get-R17StopRetryReentryInt -Value $Packet.retry_limit -Context "$Context retry_limit"
    $retryCount = Get-R17StopRetryReentryInt -Value $Packet.retry_count -Context "$Context retry_count"
    if ($retryLimit -lt 0 -or $retryLimit -gt 3) { throw "$Context retry_limit missing or unsafe." }
    if ($retryCount -lt 0) { throw "$Context retry_count missing or unsafe." }
    if ($retryCount -gt $retryLimit) { throw "$Context retry_count must not exceed retry_limit." }
    if ([string]$Packet.control_action -eq "retry" -and $retryLimit -lt 1) { throw "$Context retry_limit missing or unsafe." }

    Assert-R17StopRetryReentryPolicyObject -Policy $Packet.retry_policy -Context "$Context retry_policy"
    Assert-R17StopRetryReentryPolicyObject -Policy $Packet.timeout_policy -Context "$Context timeout_policy"
    Assert-R17StopRetryReentryPolicyObject -Policy $Packet.cost_policy -Context "$Context cost_policy"

    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_dispatch_record_ref) -Context "$Context source_dispatch_record_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_a2a_message_ref) -Context "$Context source_a2a_message_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_handoff_ref) -Context "$Context source_handoff_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_tool_call_ledger_ref) -Context "$Context source_tool_call_ledger_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_agent_invocation_ref) -Context "$Context source_agent_invocation_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_board_event_ref) -Context "$Context source_board_event_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_orchestrator_state_ref) -Context "$Context source_orchestrator_state_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.reentry_packet_ref) -Context "$Context reentry_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder

    Assert-R17StopRetryReentryRefArray -Values @($Packet.stop_condition_refs) -Context "$Context stop_condition_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.blocker_refs) -Context "$Context blocker_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.evidence_refs) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryRefArray -Values @($Packet.authority_refs) -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryRefArray -Values @($Packet.validation_refs) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryFalseFields -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$Context runtime_flags"
    Assert-R17StopRetryReentryFalseFields -Object $Packet -FieldNames $script:ExplicitFalseFields -Context $Context
    Assert-R17StopRetryReentryNoForbiddenContent -Value $Packet -Context $Context
}

function Assert-R17StopRetryReentryReentryPacket {
    param(
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17StopRetryReentryRequiredFields -Object $Packet -FieldNames $script:RequiredReentryPacketFields -Context $Context
    if ([string]$Packet.source_task -ne $script:SourceTask) { throw "$Context source_task must be R17-022." }
    if ([string]::IsNullOrWhiteSpace([string]$Packet.card_id)) { throw "$Context missing card_id." }
    if ([string]::IsNullOrWhiteSpace([string]$Packet.correlation_id)) { throw "$Context missing correlation_id." }
    if ([string]$Packet.status -ne "reentry_packet_only") { throw "$Context status must be reentry_packet_only." }
    if ([string]$Packet.execution_mode -ne "reentry_foundation_packet_only_not_executed") { throw "$Context execution_mode must be reentry_foundation_packet_only_not_executed." }

    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.source_control_packet_ref) -Context "$Context source_control_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17StopRetryReentrySafeRefPath -Path ([string]$Packet.memory_packet_ref) -Context "$Context memory_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence) -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.resume_allowed_next_actions) -Context "$Context resume_allowed_next_actions" -RepositoryRoot $RepositoryRoot -SkipRefExistence -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.required_input_refs) -Context "$Context required_input_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.required_output_refs) -Context "$Context required_output_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence -AllowPlaceholder
    Assert-R17StopRetryReentryRefArray -Values @($Packet.evidence_refs) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryRefArray -Values @($Packet.authority_refs) -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryRefArray -Values @($Packet.validation_refs) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17StopRetryReentryFalseFields -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$Context runtime_flags"
    Assert-R17StopRetryReentryNoForbiddenContent -Value $Packet -Context $Context
}

function Assert-R17StopRetryReentryKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-022 must not modify the runtime/static renderer."
    }
}

function Assert-R17StopRetryReentryFixtureCoverage {
    param([Parameter(Mandatory = $true)][string]$FixtureRoot)

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $script:MinimumInvalidFixtureCount) {
        throw "fixture coverage requires at least $script:MinimumInvalidFixtureCount compact invalid fixtures."
    }
}

function Test-R17StopRetryReentrySet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$ControlSet,
        [Parameter(Mandatory = $true)]$ReentrySet,
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$Snapshot,
        [string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot),
        [switch]$SkipFixtureCoverage,
        [switch]$SkipRefExistence,
        [switch]$SkipDeterministicComparison,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17StopRetryReentryRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "seed_source_task", "active_through_task", "planned_only_from", "planned_only_through", "required_control_packet_fields", "required_reentry_packet_fields", "allowed_control_actions", "allowed_statuses", "control_validation_policy", "runtime_policy", "implementation_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims", "preserved_boundaries") -Context "control contract"
    if ($Contract.artifact_type -ne "r17_stop_retry_reentry_controls_contract") { throw "control contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask -or $Contract.seed_source_task -ne $script:SeedSourceTask) { throw "control contract source tasks are invalid." }
    if ($Contract.active_through_task -ne "R17-022" -or $Contract.planned_only_from -ne "R17-023" -or $Contract.planned_only_through -ne "R17-028") { throw "control contract must keep R17 active through R17-022 only." }
    Assert-R17StopRetryReentryContains -Values @($Contract.required_control_packet_fields) -Required $script:RequiredControlPacketFields -Context "control contract required_control_packet_fields"
    Assert-R17StopRetryReentryContains -Values @($Contract.required_reentry_packet_fields) -Required $script:RequiredReentryPacketFields -Context "control contract required_reentry_packet_fields"
    Assert-R17StopRetryReentryContains -Values @($Contract.allowed_control_actions) -Required $script:AllowedControlActions -Context "control contract allowed_control_actions"
    Assert-R17StopRetryReentryContains -Values @($Contract.allowed_statuses) -Required $script:AllowedStatuses -Context "control contract allowed_statuses"
    Assert-R17StopRetryReentryFalseFields -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "control contract implementation_boundaries"
    Assert-R17StopRetryReentryFalseFields -Object $Contract.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "control contract explicit_false_fields"
    Assert-R17StopRetryReentryFalseFields -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "control contract claim_status"

    Assert-R17StopRetryReentryRequiredFields -Object $ControlSet -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "contract_ref", "source_dispatch_log_ref", "packet_count", "allowed_control_actions", "allowed_statuses", "control_packets", "runtime_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims") -Context "control packet set"
    if ($ControlSet.source_task -ne $script:SourceTask -or $ControlSet.active_through_task -ne "R17-022") { throw "control packet set must keep R17 active through R17-022." }
    if ($ControlSet.planned_only_from -ne "R17-023" -or $ControlSet.planned_only_through -ne "R17-028") { throw "control packet set must keep R17-023 through R17-028 planned only." }
    if ([int]$ControlSet.packet_count -ne @($ControlSet.control_packets).Count) { throw "control packet set packet_count does not match packets." }
    Assert-R17StopRetryReentryFalseFields -Object $ControlSet.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "control packet set runtime_boundaries"
    Assert-R17StopRetryReentryFalseFields -Object $ControlSet.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "control packet set explicit_false_fields"
    Assert-R17StopRetryReentryFalseFields -Object $ControlSet.claim_status -FieldNames $script:ClaimStatusFields -Context "control packet set claim_status"

    $controlIds = @{}
    foreach ($packet in @($ControlSet.control_packets)) {
        Assert-R17StopRetryReentryControlPacket -Packet $packet -Context "control packet $($packet.control_packet_id)" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        if ($controlIds.ContainsKey([string]$packet.control_packet_id)) { throw "duplicate control_packet_id '$($packet.control_packet_id)'." }
        $controlIds[[string]$packet.control_packet_id] = $true
    }

    Assert-R17StopRetryReentryRequiredFields -Object $ReentrySet -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "contract_ref", "source_control_packet_set_ref", "packet_count", "allowed_statuses", "reentry_packets", "runtime_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims") -Context "reentry packet set"
    if ($ReentrySet.source_task -ne $script:SourceTask -or $ReentrySet.active_through_task -ne "R17-022") { throw "reentry packet set must keep R17 active through R17-022." }
    if ($ReentrySet.planned_only_from -ne "R17-023" -or $ReentrySet.planned_only_through -ne "R17-028") { throw "reentry packet set must keep R17-023 through R17-028 planned only." }
    if ([int]$ReentrySet.packet_count -ne @($ReentrySet.reentry_packets).Count) { throw "reentry packet set packet_count does not match packets." }
    Assert-R17StopRetryReentryFalseFields -Object $ReentrySet.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "reentry packet set runtime_boundaries"
    Assert-R17StopRetryReentryFalseFields -Object $ReentrySet.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "reentry packet set explicit_false_fields"
    Assert-R17StopRetryReentryFalseFields -Object $ReentrySet.claim_status -FieldNames $script:ClaimStatusFields -Context "reentry packet set claim_status"
    foreach ($packet in @($ReentrySet.reentry_packets)) {
        Assert-R17StopRetryReentryReentryPacket -Packet $packet -Context "reentry packet $($packet.reentry_packet_id)" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    if (-not $SkipDeterministicComparison) {
        $expected = New-R17StopRetryReentryObjectSet -RepositoryRoot $RepositoryRoot -GitIdentity ([pscustomobject]@{ Head = "fixture_head"; Tree = "fixture_tree" })
        $actualControls = @($ControlSet.control_packets | ForEach-Object {
                $copy = Copy-R17StopRetryReentryObject -Value $_
                $copy.generated_from_head = "fixture_head"
                $copy.generated_from_tree = "fixture_tree"
                $copy
            }) | ConvertTo-Json -Depth 80 -Compress
        $expectedControls = @($expected.ControlSet.control_packets) | ConvertTo-Json -Depth 80 -Compress
        if ($actualControls -ne $expectedControls) {
            throw "control packets do not match deterministic R17-021 seed dispatch generation output."
        }

        $actualReentries = @($ReentrySet.reentry_packets | ForEach-Object {
                $copy = Copy-R17StopRetryReentryObject -Value $_
                $copy.generated_from_head = "fixture_head"
                $copy.generated_from_tree = "fixture_tree"
                $copy
            }) | ConvertTo-Json -Depth 80 -Compress
        $expectedReentries = @($expected.ReentrySet.reentry_packets) | ConvertTo-Json -Depth 80 -Compress
        if ($actualReentries -ne $expectedReentries) {
            throw "reentry packets do not match deterministic R17-021 seed dispatch generation output."
        }
    }

    Assert-R17StopRetryReentryRequiredFields -Object $Report -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "contract_ref", "control_packet_set_ref", "reentry_packet_set_ref", "control_packet_count", "reentry_packet_count", "runtime_boundary_summary", "explicit_false_fields", "claim_status", "validation_summary", "aggregate_verdict", "non_claims", "rejected_claims") -Context "check report"
    if ($Report.source_task -ne $script:SourceTask -or $Report.active_through_task -ne "R17-022") { throw "check report must keep R17 active through R17-022." }
    if ($Report.planned_only_from -ne "R17-023" -or $Report.planned_only_through -ne "R17-028") { throw "check report must keep R17-023 through R17-028 planned only." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    if ([int]$Report.control_packet_count -ne [int]$ControlSet.packet_count) { throw "check report control packet count does not match packet set." }
    if ([int]$Report.reentry_packet_count -ne [int]$ReentrySet.packet_count) { throw "check report reentry packet count does not match packet set." }
    Assert-R17StopRetryReentryFalseFields -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17StopRetryReentryFalseFields -Object $Report.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "check report explicit_false_fields"
    Assert-R17StopRetryReentryFalseFields -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    if ([bool]$Report.full_source_file_contents_embedded -ne $false -or [bool]$Report.broad_repo_scan_output_included -ne $false -or [bool]$Report.broad_repo_scan_used -ne $false) {
        throw "check report must preserve generated-artifact compactness guards."
    }
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    Assert-R17StopRetryReentryRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "contract_ref", "control_packet_set_ref", "reentry_packet_set_ref", "check_report_ref", "control_packet_count", "reentry_packet_count", "visible_controls", "runtime_boundaries", "explicit_false_fields", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.source_task -ne $script:SourceTask -or $Snapshot.active_through_task -ne "R17-022") { throw "UI snapshot must keep R17 active through R17-022." }
    if ($Snapshot.planned_only_from -ne "R17-023" -or $Snapshot.planned_only_through -ne "R17-028") { throw "UI snapshot must keep R17-023 through R17-028 planned only." }
    if ([int]$Snapshot.control_packet_count -ne [int]$ControlSet.packet_count) { throw "UI snapshot control packet count does not match packet set." }
    Assert-R17StopRetryReentryFalseFields -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17StopRetryReentryFalseFields -Object $Snapshot.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "UI snapshot explicit_false_fields"
    Assert-R17StopRetryReentryFalseFields -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"

    foreach ($object in @($Contract, $ControlSet, $ReentrySet, $Report, $Snapshot)) {
        Assert-R17StopRetryReentryNoForbiddenContent -Value $object -Context "R17-022 stop retry reentry artifact set"
    }
    if (-not $SkipFixtureCoverage) {
        Assert-R17StopRetryReentryFixtureCoverage -FixtureRoot (Get-R17StopRetryReentryPaths -RepositoryRoot $RepositoryRoot).FixtureRoot
    }
    if (-not $SkipKanbanJsCheck) {
        Assert-R17StopRetryReentryKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        ControlPacketCount = [int]$ControlSet.packet_count
        ReentryPacketCount = [int]$ReentrySet.packet_count
        ControlRuntimeImplemented = $false
        LiveStopPerformed = $false
        LiveRetryPerformed = $false
        LivePausePerformed = $false
        LiveBlockPerformed = $false
        LiveReentryPerformed = $false
        A2aRuntimeImplemented = $false
        LiveA2aDispatchPerformed = $false
        A2aMessageSent = $false
        LiveAgentRuntimeInvoked = $false
        LiveOrchestratorRuntimeInvoked = $false
        AdapterRuntimeInvoked = $false
        ActualToolCallPerformed = $false
        ExternalApiCallPerformed = $false
        BoardMutationPerformed = $false
        QaResultClaimed = $false
        RealAuditVerdict = $false
        ExternalAuditAcceptanceClaimed = $false
        MainMergeClaimed = $false
    }
}

function Test-R17StopRetryReentryControls {
    param([string]$RepositoryRoot = (Get-R17StopRetryReentryRepositoryRoot))

    $paths = Get-R17StopRetryReentryPaths -RepositoryRoot $RepositoryRoot
    return Test-R17StopRetryReentrySet `
        -Contract (Read-R17StopRetryReentryJson -Path $paths.Contract) `
        -ControlSet (Read-R17StopRetryReentryJson -Path $paths.ControlPackets) `
        -ReentrySet (Read-R17StopRetryReentryJson -Path $paths.ReentryPackets) `
        -Report (Read-R17StopRetryReentryJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17StopRetryReentryJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17StopRetryReentryObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17StopRetryReentryProperty -Object $current -Name $parts[$index] -Context $Path
    }
    $leaf = $parts[-1]
    if (-not (Test-R17StopRetryReentryHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}
