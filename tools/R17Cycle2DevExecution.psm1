Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-024"
$script:InputSourceTask = "R17-023"
$script:CycleId = "r17_024_cycle_2_dev_execution"
$script:CycleNumber = 2
$script:CycleName = "Cycle 2 Developer/Codex Execution: Orchestrator to Developer/Codex to Board"
$script:CardId = "R17-023-CYCLE-1"
$script:AggregateVerdict = "generated_r17_cycle_2_dev_execution_package_candidate"
$script:CycleRoot = "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution"
$script:FixtureRoot = "tests/fixtures/r17_cycle_2_dev_execution"

$script:AllowedStatuses = @(
    "cycle_2_dev_execution_package_only",
    "dev_request_packet_created",
    "dev_result_packet_captured_repo_backed",
    "dev_diff_status_summary_captured",
    "ready_for_qa_packet_only",
    "blocked_missing_required_ref",
    "blocked_user_decision_required",
    "invalid"
)

$script:RequiredCyclePacketFields = @(
    "cycle_id",
    "source_task",
    "cycle_number",
    "cycle_name",
    "card_id",
    "input_task_packet_ref",
    "dev_request_packet_ref",
    "dev_result_packet_ref",
    "dev_diff_status_summary_ref",
    "memory_packet_refs",
    "artifact_refs",
    "a2a_message_refs",
    "handoff_refs",
    "dispatch_refs",
    "control_refs",
    "invocation_refs",
    "tool_call_ledger_refs",
    "board_event_refs",
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
    "live_cycle_runtime_implemented",
    "live_orchestrator_runtime_invoked",
    "live_developer_agent_invoked",
    "live_codex_executor_adapter_invoked",
    "codex_executor_adapter_runtime_implemented",
    "codex_executor_invoked_by_product_runtime",
    "live_agent_runtime_invoked",
    "live_a2a_dispatch_performed",
    "a2a_runtime_implemented",
    "a2a_message_sent",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "live_board_mutation_performed",
    "runtime_card_creation_performed",
    "qa_test_agent_invoked",
    "qa_result_claimed",
    "evidence_auditor_api_invoked",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "product_runtime_executed",
    "autonomous_agent_executed",
    "main_merge_claimed",
    "no_manual_prompt_transfer_claimed"
)

$script:AdditionalFalseFields = @(
    "dev_output_claimed",
    "tool_call_runtime_implemented",
    "ledger_runtime_implemented",
    "adapter_runtime_implemented",
    "a2a_dispatcher_runtime_implemented",
    "a2a_message_dispatched",
    "actual_agent_invoked",
    "agent_invocation_performed",
    "runtime_dispatch_performed",
    "board_mutation_performed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "executable_handoff_performed",
    "executable_transition_performed",
    "external_integration_performed",
    "production_runtime_executed",
    "runtime_memory_loading_performed",
    "broad_repo_scan_used",
    "broad_repo_scan_output_included",
    "full_source_file_contents_embedded",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "r17_025_plus_completion_claimed",
    "qa_pass_claimed",
    "audit_complete_claimed",
    "release_recommendation_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed"
)

$script:RuntimeFalseFields = @($script:ExplicitFalseFields + $script:AdditionalFalseFields | Select-Object -Unique)

$script:PositiveClaimFields = @(
    "repo_backed_cycle_2_dev_execution_package_created",
    "dev_request_packet_created",
    "dev_result_packet_captured_from_this_committed_task",
    "dev_diff_status_summary_created",
    "ready_for_qa_packet_only",
    "deterministic_board_event_evidence_created"
)

function Get-R17Cycle2DevExecutionRepositoryRoot {
    return $script:RepositoryRoot
}

function Resolve-R17Cycle2DevExecutionPath {
    param(
        [string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17Cycle2DevExecutionJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R17Cycle2DevExecutionJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $records += ($line | ConvertFrom-Json)
    }
    return $records
}

function Write-R17Cycle2DevExecutionJson {
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

function Write-R17Cycle2DevExecutionJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Values
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $lines = @()
    foreach ($value in @($Values)) {
        $lines += ($value | ConvertTo-Json -Depth 90 -Compress)
    }
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Write-R17Cycle2DevExecutionText {
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

function Copy-R17Cycle2DevExecutionObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 90 | ConvertFrom-Json)
}

function Test-R17Cycle2DevExecutionHasProperty {
    param([Parameter(Mandatory = $true)]$Object, [Parameter(Mandatory = $true)][string]$Name)

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17Cycle2DevExecutionProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17Cycle2DevExecutionHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Set-R17Cycle2DevExecutionObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17Cycle2DevExecutionProperty -Object $current -Name $parts[$index] -Context $Path
    }

    $leaf = $parts[-1]
    if (-not (Test-R17Cycle2DevExecutionHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R17Cycle2DevExecutionObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17Cycle2DevExecutionProperty -Object $current -Name $parts[$index] -Context $Path
    }

    $leaf = $parts[-1]
    if (Test-R17Cycle2DevExecutionHasProperty -Object $current -Name $leaf) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Get-R17Cycle2DevExecutionPaths {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/cycles/r17_cycle_2_dev_execution.contract.json"
        DevRequest = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/dev_request_packet.json"
        DevResult = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/dev_result_packet.json"
        DevDiffStatusSummary = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/dev_diff_status_summary.json"
        A2aMessages = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_2_messages.json"
        A2aHandoffs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_2_handoffs.json"
        A2aDispatchRefs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json"
        ToolCallLedgerRefs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_2_tool_call_ledger_refs.json"
        InvocationRefs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_2_invocation_refs.json"
        ControlRefs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_2_control_refs.json"
        BoardEventRefs = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_2_board_event_refs.json"
        CheckReport = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_2_check_report.json"
        BoardCard = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json"
        BoardEvents = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl"
        BoardSnapshot = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json"
        UiSnapshot = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json"
        FixtureRoot = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
        ProofRoot = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17Cycle2DevExecutionGitIdentity {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17Cycle2DevExecutionFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) {
        $flags[$field] = $false
    }
    return [pscustomobject]$flags
}

function Get-R17Cycle2DevExecutionExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }
    return [pscustomobject]$flags
}

function Get-R17Cycle2DevExecutionPositiveClaims {
    return [pscustomobject]@{
        repo_backed_cycle_2_dev_execution_package_created = $true
        dev_request_packet_created = $true
        dev_result_packet_captured_from_this_committed_task = $true
        dev_diff_status_summary_created = $true
        ready_for_qa_packet_only = $true
        deterministic_board_event_evidence_created = $true
    }
}

function Get-R17Cycle2DevExecutionCoreRefs {
    return [pscustomobject]@{
        input_task_packet_ref = "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/task_packet_ready_for_dev.json"
        dev_request_packet_ref = "$($script:CycleRoot)/dev_request_packet.json"
        dev_result_packet_ref = "$($script:CycleRoot)/dev_result_packet.json"
        dev_diff_status_summary_ref = "$($script:CycleRoot)/dev_diff_status_summary.json"
        a2a_message_refs = @(
            "$($script:CycleRoot)/a2a_cycle_2_messages.json#r17_024_cycle_2_message_orchestrator_to_developer_codex_request",
            "$($script:CycleRoot)/a2a_cycle_2_messages.json#r17_024_cycle_2_message_developer_codex_result_to_orchestrator",
            "$($script:CycleRoot)/a2a_cycle_2_messages.json#r17_024_cycle_2_message_orchestrator_ready_for_qa_packet"
        )
        handoff_refs = @(
            "$($script:CycleRoot)/a2a_cycle_2_handoffs.json#r17_024_cycle_2_handoff_orchestrator_to_developer_codex_packet_only",
            "$($script:CycleRoot)/a2a_cycle_2_handoffs.json#r17_024_cycle_2_handoff_developer_codex_to_orchestrator_result_packet_only",
            "$($script:CycleRoot)/a2a_cycle_2_handoffs.json#r17_024_cycle_2_handoff_orchestrator_to_board_ready_for_qa_packet_only"
        )
        dispatch_refs = @(
            "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json#r17_024_cycle_2_dispatch_ref_orchestrator_to_developer_codex_not_dispatched",
            "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json#r17_024_cycle_2_dispatch_ref_developer_codex_result_not_dispatched",
            "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json#r17_024_cycle_2_dispatch_ref_ready_for_qa_board_packet_only"
        )
        control_refs = @(
            "$($script:CycleRoot)/cycle_2_control_refs.json#r17_024_cycle_2_stop_ref",
            "$($script:CycleRoot)/cycle_2_control_refs.json#r17_024_cycle_2_retry_ref",
            "$($script:CycleRoot)/cycle_2_control_refs.json#r17_024_cycle_2_reentry_ref",
            "$($script:CycleRoot)/cycle_2_control_refs.json#r17_024_cycle_2_user_decision_ref"
        )
        invocation_refs = @(
            "$($script:CycleRoot)/cycle_2_invocation_refs.json#r17_024_cycle_2_invocation_ref_orchestrator_packet_only",
            "$($script:CycleRoot)/cycle_2_invocation_refs.json#r17_024_cycle_2_invocation_ref_developer_codex_packet_only"
        )
        tool_call_ledger_refs = @(
            "$($script:CycleRoot)/cycle_2_tool_call_ledger_refs.json#r17_024_cycle_2_tool_call_ref_codex_executor_packet_only"
        )
        board_event_refs = @(
            "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl#r17_024_cycle_2_event_001_ready_for_dev_to_in_dev",
            "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl#r17_024_cycle_2_event_002_dev_result_captured",
            "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl#r17_024_cycle_2_event_003_in_dev_to_ready_for_qa"
        )
    }
}

function Get-R17Cycle2DevExecutionMemoryRefs {
    return @(
        "state/agents/r17_agent_memory_packets/orchestrator.memory_packet.json",
        "state/agents/r17_agent_memory_packets/developer.memory_packet.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "state/context/r17_memory_loaded_refs_log.json"
    )
}

function Get-R17Cycle2DevExecutionArtifactRefs {
    return @(
        "contracts/cycles/r17_cycle_2_dev_execution.contract.json",
        "$($script:CycleRoot)/dev_request_packet.json",
        "$($script:CycleRoot)/dev_result_packet.json",
        "$($script:CycleRoot)/dev_diff_status_summary.json",
        "$($script:CycleRoot)/a2a_cycle_2_messages.json",
        "$($script:CycleRoot)/a2a_cycle_2_handoffs.json",
        "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json",
        "$($script:CycleRoot)/cycle_2_tool_call_ledger_refs.json",
        "$($script:CycleRoot)/cycle_2_invocation_refs.json",
        "$($script:CycleRoot)/cycle_2_control_refs.json",
        "$($script:CycleRoot)/cycle_2_board_event_refs.json",
        "$($script:CycleRoot)/cycle_2_check_report.json",
        "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json",
        "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl",
        "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json"
    )
}

function Get-R17Cycle2DevExecutionEvidenceRefs {
    return @(
        (Get-R17Cycle2DevExecutionArtifactRefs),
        "tools/R17Cycle2DevExecution.psm1",
        "tools/new_r17_cycle_2_dev_execution.ps1",
        "tools/validate_r17_cycle_2_dev_execution.ps1",
        "tests/test_r17_cycle_2_dev_execution.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/validation_manifest.md"
    ) | ForEach-Object { $_ }
}

function Get-R17Cycle2DevExecutionAuthorityRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "contracts/cycles/r17_cycle_1_definition.contract.json",
        "contracts/cycles/r17_cycle_2_dev_execution.contract.json",
        "contracts/tools/r17_codex_executor_adapter.contract.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "contracts/board/r17_card.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_memory_packets/developer.memory_packet.json",
        "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/task_packet_ready_for_dev.json",
        "state/tools/r17_codex_executor_adapter_request_packet.json",
        "state/tools/r17_codex_executor_adapter_result_packet.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_tool_call_ledger.jsonl",
        "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl",
        "state/runtime/r17_stop_retry_reentry_control_packets.json"
    )
}

function Get-R17Cycle2DevExecutionValidationRefs {
    return @(
        "contracts/cycles/r17_cycle_2_dev_execution.contract.json",
        "$($script:CycleRoot)/cycle_2_check_report.json",
        "tools/validate_r17_cycle_2_dev_execution.ps1",
        "tests/test_r17_cycle_2_dev_execution.ps1",
        "$($script:ProofRoot)/validation_manifest.md"
    )
}

function Get-R17Cycle2DevExecutionNonClaims {
    return @(
        "R17-024 creates a repo-backed Cycle 2 Developer/Codex execution package only",
        "R17-024 captures a Developer/Codex request/result packet from committed task evidence only",
        "R17-024 captures a dev diff/status summary for this repo-backed package without embedding source contents",
        "R17-024 records ready-for-QA packet only",
        "R17-024 records deterministic board event evidence only",
        "R17-024 does not implement live cycle runtime",
        "R17-024 does not invoke live Orchestrator runtime",
        "R17-024 does not invoke a live Developer/Codex adapter",
        "R17-024 does not prove autonomous Codex invocation by product runtime",
        "R17-024 does not implement live A2A runtime",
        "R17-024 does not send live A2A messages",
        "R17-024 does not invoke adapter runtime",
        "R17-024 does not perform actual tool calls",
        "R17-024 does not call external APIs",
        "R17-024 does not perform live board mutation",
        "R17-024 does not claim a QA result",
        "R17-024 does not claim a real audit verdict",
        "R17-024 does not claim external audit acceptance",
        "R17-024 does not execute autonomous agents",
        "R17-024 does not execute product runtime",
        "R17-024 does not claim main merge",
        "R17-024 does not claim prompt-transfer automation is solved",
        "R17-025 through R17-028 remain planned only",
        "R13 remains failed/partial and not closed",
        "R14 caveats remain preserved",
        "R15 caveats remain preserved",
        "R16 remains complete for bounded foundation scope through R16-026 only"
    )
}

function Get-R17Cycle2DevExecutionRejectedClaims {
    return @(
        "live_cycle_runtime",
        "live_Orchestrator_runtime",
        "live_Developer_agent_invocation",
        "live_Codex_executor_adapter_invocation",
        "autonomous_Codex_invocation_by_product_runtime",
        "live_agent_runtime",
        "live_A2A_runtime",
        "live_A2A_messages_sent",
        "live_A2A_dispatch",
        "adapter_runtime",
        "actual_tool_call",
        "external_API_call",
        "live_board_mutation",
        "runtime_card_creation",
        "QA_Test_Agent_invocation",
        "QA_result",
        "Evidence_Auditor_API_invocation",
        "real_audit_verdict",
        "external_audit_acceptance",
        "autonomous_agents",
        "product_runtime",
        "production_runtime",
        "main_merge",
        "no_manual_prompt_transfer_success",
        "future_R17_025_plus_completion",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "wildcard_evidence_refs",
        "local_backups_refs",
        "broad_repo_scan_output",
        "embedded_full_source_file_contents"
    )
}

function Get-R17Cycle2DevExecutionChangedFileSummary {
    return @(
        [pscustomobject]@{ path = "contracts/cycles/r17_cycle_2_dev_execution.contract.json"; change_type = "added"; category = "contract" },
        [pscustomobject]@{ path = "tools/R17Cycle2DevExecution.psm1"; change_type = "added"; category = "tooling" },
        [pscustomobject]@{ path = "tools/new_r17_cycle_2_dev_execution.ps1"; change_type = "added"; category = "tooling" },
        [pscustomobject]@{ path = "tools/validate_r17_cycle_2_dev_execution.ps1"; change_type = "added"; category = "tooling" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/dev_request_packet.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/dev_result_packet.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/dev_diff_status_summary.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/a2a_cycle_2_messages.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/a2a_cycle_2_handoffs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/a2a_cycle_2_dispatch_refs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/cycle_2_tool_call_ledger_refs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/cycle_2_invocation_refs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/cycle_2_control_refs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/cycle_2_board_event_refs.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:CycleRoot)/cycle_2_check_report.json"; change_type = "added"; category = "cycle_state" },
        [pscustomobject]@{ path = "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json"; change_type = "added"; category = "board_state" },
        [pscustomobject]@{ path = "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl"; change_type = "added"; category = "board_state" },
        [pscustomobject]@{ path = "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json"; change_type = "added"; category = "board_state" },
        [pscustomobject]@{ path = "state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json"; change_type = "added"; category = "ui_snapshot" },
        [pscustomobject]@{ path = "tests/test_r17_cycle_2_dev_execution.ps1"; change_type = "added"; category = "test" },
        [pscustomobject]@{ path = "$($script:FixtureRoot)/fixture_manifest.json"; change_type = "added"; category = "fixture" },
        [pscustomobject]@{ path = "$($script:ProofRoot)/proof_review.md"; change_type = "added"; category = "proof_review" },
        [pscustomobject]@{ path = "$($script:ProofRoot)/evidence_index.json"; change_type = "added"; category = "proof_review" },
        [pscustomobject]@{ path = "$($script:ProofRoot)/validation_manifest.md"; change_type = "added"; category = "proof_review" },
        [pscustomobject]@{ path = "README.md"; change_type = "updated"; category = "status_surface" },
        [pscustomobject]@{ path = "governance/ACTIVE_STATE.md"; change_type = "updated"; category = "status_surface" },
        [pscustomobject]@{ path = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"; change_type = "updated"; category = "status_surface" },
        [pscustomobject]@{ path = "execution/KANBAN.md"; change_type = "updated"; category = "status_surface" },
        [pscustomobject]@{ path = "governance/DECISION_LOG.md"; change_type = "updated"; category = "status_surface" },
        [pscustomobject]@{ path = "tools/StatusDocGate.psm1"; change_type = "updated"; category = "status_gate" },
        [pscustomobject]@{ path = "tests/test_status_doc_gate.ps1"; change_type = "updated"; category = "status_gate" }
    )
}

function New-R17Cycle2DevExecutionBasePacket {
    param(
        [Parameter(Mandatory = $true)][string]$ArtifactType,
        [Parameter(Mandatory = $true)][string]$PacketId,
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)]$GitIdentity
    )

    $refs = Get-R17Cycle2DevExecutionCoreRefs
    $packet = [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        packet_id = $PacketId
        cycle_id = $script:CycleId
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        input_source_task = $script:InputSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-025"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        cycle_number = $script:CycleNumber
        cycle_name = $script:CycleName
        card_id = $script:CardId
        input_task_packet_ref = $refs.input_task_packet_ref
        dev_request_packet_ref = $refs.dev_request_packet_ref
        dev_result_packet_ref = $refs.dev_result_packet_ref
        dev_diff_status_summary_ref = $refs.dev_diff_status_summary_ref
        memory_packet_refs = @(Get-R17Cycle2DevExecutionMemoryRefs)
        artifact_refs = @(Get-R17Cycle2DevExecutionArtifactRefs)
        a2a_message_refs = @($refs.a2a_message_refs)
        handoff_refs = @($refs.handoff_refs)
        dispatch_refs = @($refs.dispatch_refs)
        control_refs = @($refs.control_refs)
        invocation_refs = @($refs.invocation_refs)
        tool_call_ledger_refs = @($refs.tool_call_ledger_refs)
        board_event_refs = @($refs.board_event_refs)
        evidence_refs = @(Get-R17Cycle2DevExecutionEvidenceRefs)
        authority_refs = @(Get-R17Cycle2DevExecutionAuthorityRefs)
        validation_refs = @(Get-R17Cycle2DevExecutionValidationRefs)
        status = $Status
        execution_mode = "repo_backed_cycle_2_developer_codex_execution_package_not_product_runtime"
        runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
        rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        positive_claims = Get-R17Cycle2DevExecutionPositiveClaims
        repo_backed_cycle_2_dev_execution_package_created = $true
        dev_request_packet_created = $true
        dev_result_packet_captured_from_this_committed_task = $true
        dev_diff_status_summary_created = $true
        ready_for_qa_packet_only = $true
        deterministic_board_event_evidence_created = $true
    }

    foreach ($field in $script:RuntimeFalseFields) {
        $packet[$field] = $false
    }

    return [pscustomobject]$packet
}

function New-R17Cycle2DevExecutionArtifacts {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    $paths = Get-R17Cycle2DevExecutionPaths -RepositoryRoot $RepositoryRoot
    $git = Get-R17Cycle2DevExecutionGitIdentity -RepositoryRoot $RepositoryRoot
    $refs = Get-R17Cycle2DevExecutionCoreRefs
    $falseFlags = Get-R17Cycle2DevExecutionFalseFlags
    $explicitFalseMap = Get-R17Cycle2DevExecutionExplicitFalseMap

    $contract = [ordered]@{
        artifact_type = "r17_cycle_2_dev_execution_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-024-cycle-2-dev-execution-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        input_source_task = $script:InputSourceTask
        active_through_task = "R17-024"
        planned_only_from = "R17-025"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $git.Head
        generated_from_tree = $git.Tree
        required_cycle_packet_fields = $script:RequiredCyclePacketFields
        allowed_statuses = $script:AllowedStatuses
        required_explicit_false_fields = $script:ExplicitFalseFields
        required_positive_claim_fields = $script:PositiveClaimFields
        validation_policy = [ordered]@{
            reject_missing_required_refs = $true
            reject_wildcard_evidence_paths = $true
            reject_local_backups_refs = $true
            reject_broad_repo_scan_output = $true
            reject_embedded_full_source_file_contents = $true
            reject_product_runtime_claims = $true
            reject_live_adapter_invocation_claims = $true
            reject_no_manual_prompt_transfer_success_claims = $true
            reject_qa_result_claims = $true
            reject_audit_verdict_claims = $true
            reject_future_r17_025_plus_completion_claims = $true
        }
        runtime_boundaries = $falseFlags
        explicit_false_fields = $explicitFalseMap
        positive_claims_allowed_when_committed = Get-R17Cycle2DevExecutionPositiveClaims
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
        rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
    }
    Write-R17Cycle2DevExecutionJson -Path $paths.Contract -Value ([pscustomobject]$contract)

    $devRequest = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_dev_request_packet" -PacketId "r17_024_cycle_2_dev_request_packet" -Status "dev_request_packet_created" -GitIdentity $git
    $devRequest | Add-Member -MemberType NoteProperty -Name request_id -Value "r17_024_cycle_2_developer_codex_request"
    $devRequest | Add-Member -MemberType NoteProperty -Name requested_by_agent_id -Value "orchestrator"
    $devRequest | Add-Member -MemberType NoteProperty -Name target_agent_id -Value "developer"
    $devRequest | Add-Member -MemberType NoteProperty -Name source_ready_for_dev_packet_status -Value "ready_for_dev_packet_only"
    $devRequest | Add-Member -MemberType NoteProperty -Name scope -Value @(
        "Create deterministic R17-024 Cycle 2 Developer/Codex execution evidence package.",
        "Use the R17-023 ready-for-dev task packet as the input reference.",
        "Capture request, result, diff/status, A2A, dispatcher, control, invocation, tool-call, board, UI, and proof-review refs.",
        "Move the R17-023 Cycle 1 card to Ready for QA as deterministic repo-backed board evidence only."
    )
    $devRequest | Add-Member -MemberType NoteProperty -Name constraints -Value @(
        "Do not modify historical R13, R14, R15, or R16 evidence.",
        "Do not stage or commit local backup folders.",
        "Do not modify kanban.js.",
        "Do not claim live cycle runtime, live adapter runtime, live A2A runtime, actual tool calls, external API calls, live board mutation, QA result, audit verdict, product runtime, or main merge.",
        "Keep generated artifacts compact and avoid broad repo-scan output or embedded source contents."
    )
    $devRequest | Add-Member -MemberType NoteProperty -Name allowed_files -Value @(
        "contracts/cycles/r17_cycle_2_dev_execution.contract.json",
        "tools/R17Cycle2DevExecution.psm1",
        "tools/new_r17_cycle_2_dev_execution.ps1",
        "tools/validate_r17_cycle_2_dev_execution.ps1",
        "$($script:CycleRoot)/",
        "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json",
        "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl",
        "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_cycle_2_dev_execution_snapshot.json",
        "tests/test_r17_cycle_2_dev_execution.ps1",
        "$($script:FixtureRoot)/",
        "$($script:ProofRoot)/",
        "README.md",
        "governance/ACTIVE_STATE.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "governance/DECISION_LOG.md",
        "tools/StatusDocGate.psm1",
        "tests/test_status_doc_gate.ps1"
    )
    $devRequest | Add-Member -MemberType NoteProperty -Name acceptance_criteria -Value @(
        "R17-023 ready-for-dev task packet is referenced as input.",
        "Developer/Codex request and result packets exist and validate.",
        "Diff/status summary lists changed files without embedding file contents.",
        "A2A message/handoff/dispatch refs remain not-sent/not-dispatched packet candidates.",
        "Invocation and tool-call ledger refs remain packet-only and do not claim actual invocation or tool calls.",
        "Board evidence shows Ready for Dev to In Dev to Ready for QA without live board mutation.",
        "R17-025 through R17-028 remain planned only."
    )
    $devRequest | Add-Member -MemberType NoteProperty -Name validation_requirements -Value @(Get-R17Cycle2DevExecutionValidationRefs)
    $devRequest | Add-Member -MemberType NoteProperty -Name evidence_requirements -Value @(Get-R17Cycle2DevExecutionEvidenceRefs)
    $devRequest | Add-Member -MemberType NoteProperty -Name execution_requested_by_product_runtime -Value $false
    $devRequest | Add-Member -MemberType NoteProperty -Name manual_prompt_transfer_eliminated -Value $false
    Write-R17Cycle2DevExecutionJson -Path $paths.DevRequest -Value $devRequest

    $changedFileSummary = @(Get-R17Cycle2DevExecutionChangedFileSummary)
    $devResult = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_dev_result_packet" -PacketId "r17_024_cycle_2_dev_result_packet" -Status "dev_result_packet_captured_repo_backed" -GitIdentity $git
    $devResult | Add-Member -MemberType NoteProperty -Name result_id -Value "r17_024_cycle_2_developer_codex_result"
    $devResult | Add-Member -MemberType NoteProperty -Name request_packet_ref -Value $refs.dev_request_packet_ref
    $devResult | Add-Member -MemberType NoteProperty -Name committed_artifact_refs -Value @(Get-R17Cycle2DevExecutionArtifactRefs)
    $devResult | Add-Member -MemberType NoteProperty -Name changed_file_summary -Value $changedFileSummary
    $devResult | Add-Member -MemberType NoteProperty -Name result_summary -Value "Developer/Codex request/result packet captured from this committed task evidence as a repo-backed package only."
    $devResult | Add-Member -MemberType NoteProperty -Name result_captured_from_this_task -Value $true
    $devResult | Add-Member -MemberType NoteProperty -Name product_runtime_result -Value $false
    $devResult | Add-Member -MemberType NoteProperty -Name qa_result -Value "not_claimed_r17_024"
    $devResult | Add-Member -MemberType NoteProperty -Name audit_verdict -Value "not_claimed_r17_024"
    Write-R17Cycle2DevExecutionJson -Path $paths.DevResult -Value $devResult

    $devDiffStatus = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_dev_diff_status_summary" -PacketId "r17_024_cycle_2_dev_diff_status_summary" -Status "dev_diff_status_summary_captured" -GitIdentity $git
    $devDiffStatus | Add-Member -MemberType NoteProperty -Name summary_id -Value "r17_024_cycle_2_dev_diff_status_summary"
    $devDiffStatus | Add-Member -MemberType NoteProperty -Name changed_files -Value $changedFileSummary
    $devDiffStatus | Add-Member -MemberType NoteProperty -Name changed_file_count -Value $changedFileSummary.Count
    $devDiffStatus | Add-Member -MemberType NoteProperty -Name content_policy -Value ([pscustomobject]@{
        source_contents_embedded = $false
        broad_repo_scan_output_embedded = $false
        compact_refs_only = $true
    })
    $devDiffStatus | Add-Member -MemberType NoteProperty -Name summary -Value "Compact status summary for R17-024 cycle artifacts and narrow status/gate updates."
    Write-R17Cycle2DevExecutionJson -Path $paths.DevDiffStatusSummary -Value $devDiffStatus

    $messageDetails = @(
        [pscustomobject]@{ message_id = "r17_024_cycle_2_message_orchestrator_to_developer_codex_request"; from_agent_id = "orchestrator"; to_agent_id = "developer"; message_type = "developer_codex_request"; input_ref = $refs.input_task_packet_ref; output_ref = $refs.dev_request_packet_ref },
        [pscustomobject]@{ message_id = "r17_024_cycle_2_message_developer_codex_result_to_orchestrator"; from_agent_id = "developer"; to_agent_id = "orchestrator"; message_type = "developer_codex_result"; input_ref = $refs.dev_request_packet_ref; output_ref = $refs.dev_result_packet_ref },
        [pscustomobject]@{ message_id = "r17_024_cycle_2_message_orchestrator_ready_for_qa_packet"; from_agent_id = "orchestrator"; to_agent_id = "board"; message_type = "ready_for_qa_packet_only"; input_ref = $refs.dev_result_packet_ref; output_ref = "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json" }
    )
    $a2aMessages = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_a2a_messages" -PacketId "r17_024_cycle_2_a2a_messages" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $a2aMessages | Add-Member -MemberType NoteProperty -Name message_count -Value $messageDetails.Count
    $a2aMessages | Add-Member -MemberType NoteProperty -Name messages -Value @($messageDetails | ForEach-Object {
            [pscustomobject]@{
                message_id = $_.message_id
                from_agent_id = $_.from_agent_id
                to_agent_id = $_.to_agent_id
                message_type = $_.message_type
                input_ref = $_.input_ref
                output_ref = $_.output_ref
                status = "not_sent_packet_candidate"
                runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
                live_a2a_message_sent = $false
                a2a_message_sent = $false
                non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
                rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
            }
        })
    Write-R17Cycle2DevExecutionJson -Path $paths.A2aMessages -Value $a2aMessages

    $handoffDetails = @(
        [pscustomobject]@{ handoff_id = "r17_024_cycle_2_handoff_orchestrator_to_developer_codex_packet_only"; from_agent_id = "orchestrator"; to_agent_id = "developer"; input_ref = $refs.input_task_packet_ref; output_ref = $refs.dev_request_packet_ref },
        [pscustomobject]@{ handoff_id = "r17_024_cycle_2_handoff_developer_codex_to_orchestrator_result_packet_only"; from_agent_id = "developer"; to_agent_id = "orchestrator"; input_ref = $refs.dev_request_packet_ref; output_ref = $refs.dev_result_packet_ref },
        [pscustomobject]@{ handoff_id = "r17_024_cycle_2_handoff_orchestrator_to_board_ready_for_qa_packet_only"; from_agent_id = "orchestrator"; to_agent_id = "board"; input_ref = $refs.dev_result_packet_ref; output_ref = "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json" }
    )
    $a2aHandoffs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_a2a_handoffs" -PacketId "r17_024_cycle_2_a2a_handoffs" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $a2aHandoffs | Add-Member -MemberType NoteProperty -Name handoff_count -Value $handoffDetails.Count
    $a2aHandoffs | Add-Member -MemberType NoteProperty -Name handoffs -Value @($handoffDetails | ForEach-Object {
            [pscustomobject]@{
                handoff_id = $_.handoff_id
                from_agent_id = $_.from_agent_id
                to_agent_id = $_.to_agent_id
                input_ref = $_.input_ref
                output_ref = $_.output_ref
                status = "not_executed_packet_candidate"
                runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
                non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
                rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
            }
        })
    Write-R17Cycle2DevExecutionJson -Path $paths.A2aHandoffs -Value $a2aHandoffs

    $dispatchDetails = @(
        [pscustomobject]@{ dispatch_ref_id = "r17_024_cycle_2_dispatch_ref_orchestrator_to_developer_codex_not_dispatched"; source_dispatch_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#r17_021_dispatch_candidate_task_assignment"; input_ref = $refs.input_task_packet_ref; output_ref = $refs.dev_request_packet_ref },
        [pscustomobject]@{ dispatch_ref_id = "r17_024_cycle_2_dispatch_ref_developer_codex_result_not_dispatched"; source_dispatch_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#r17_021_dispatch_candidate_implementation_result"; input_ref = $refs.dev_request_packet_ref; output_ref = $refs.dev_result_packet_ref },
        [pscustomobject]@{ dispatch_ref_id = "r17_024_cycle_2_dispatch_ref_ready_for_qa_board_packet_only"; source_dispatch_ref = "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl#r17_021_dispatch_candidate_implementation_result"; input_ref = $refs.dev_result_packet_ref; output_ref = "$($script:CycleRoot)/cycle_2_board_event_refs.json" }
    )
    $a2aDispatchRefs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_a2a_dispatch_refs" -PacketId "r17_024_cycle_2_a2a_dispatch_refs" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $a2aDispatchRefs | Add-Member -MemberType NoteProperty -Name dispatch_ref_count -Value $dispatchDetails.Count
    $a2aDispatchRefs | Add-Member -MemberType NoteProperty -Name dispatch_refs_detail -Value @($dispatchDetails | ForEach-Object {
            [pscustomobject]@{
                dispatch_ref_id = $_.dispatch_ref_id
                source_dispatch_ref = $_.source_dispatch_ref
                input_ref = $_.input_ref
                output_ref = $_.output_ref
                dispatch_decision = "not_dispatched_packet_only"
                runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
            }
        })
    Write-R17Cycle2DevExecutionJson -Path $paths.A2aDispatchRefs -Value $a2aDispatchRefs

    $toolCallRefs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_tool_call_ledger_refs" -PacketId "r17_024_cycle_2_tool_call_ledger_refs" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $toolCallRefs | Add-Member -MemberType NoteProperty -Name tool_call_ref_count -Value 1
    $toolCallRefs | Add-Member -MemberType NoteProperty -Name tool_call_refs_detail -Value @(
        [pscustomobject]@{
            tool_call_ref_id = "r17_024_cycle_2_tool_call_ref_codex_executor_packet_only"
            source_tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl#r17_019_seed_tool_call_developer_codex_executor_adapter_future"
            request_packet_ref = $refs.dev_request_packet_ref
            result_packet_ref = $refs.dev_result_packet_ref
            status = "packet_only_no_actual_tool_call"
            actual_tool_call_performed = $false
            adapter_runtime_invoked = $false
            external_api_call_performed = $false
            runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
        }
    )
    Write-R17Cycle2DevExecutionJson -Path $paths.ToolCallLedgerRefs -Value $toolCallRefs

    $invocationRefs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_invocation_refs" -PacketId "r17_024_cycle_2_invocation_refs" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $invocationRefs | Add-Member -MemberType NoteProperty -Name invocation_ref_count -Value 2
    $invocationRefs | Add-Member -MemberType NoteProperty -Name invocation_refs_detail -Value @(
        [pscustomobject]@{
            invocation_ref_id = "r17_024_cycle_2_invocation_ref_orchestrator_packet_only"
            source_invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_orchestrator"
            status = "packet_only_no_live_invocation"
            actual_agent_invoked = $false
            runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
        },
        [pscustomobject]@{
            invocation_ref_id = "r17_024_cycle_2_invocation_ref_developer_codex_packet_only"
            source_invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_developer"
            status = "packet_only_no_live_invocation"
            actual_agent_invoked = $false
            live_developer_agent_invoked = $false
            live_codex_executor_adapter_invoked = $false
            runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
        }
    )
    Write-R17Cycle2DevExecutionJson -Path $paths.InvocationRefs -Value $invocationRefs

    $controlRefs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_control_refs" -PacketId "r17_024_cycle_2_control_refs" -Status "cycle_2_dev_execution_package_only" -GitIdentity $git
    $controlDetails = @(
        [pscustomobject]@{ control_ref_id = "r17_024_cycle_2_stop_ref"; control_action = "stop"; source_control_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#r17_022_control_stop" },
        [pscustomobject]@{ control_ref_id = "r17_024_cycle_2_retry_ref"; control_action = "retry"; source_control_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#r17_022_control_retry" },
        [pscustomobject]@{ control_ref_id = "r17_024_cycle_2_reentry_ref"; control_action = "reentry"; source_control_ref = "state/runtime/r17_stop_retry_reentry_reentry_packets.json#r17_022_reentry_developer_resume" },
        [pscustomobject]@{ control_ref_id = "r17_024_cycle_2_user_decision_ref"; control_action = "user_decision_required"; source_control_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#r17_022_control_user_decision_required" }
    )
    $controlRefs | Add-Member -MemberType NoteProperty -Name control_ref_count -Value $controlDetails.Count
    $controlRefs | Add-Member -MemberType NoteProperty -Name control_refs_detail -Value @($controlDetails | ForEach-Object {
            [pscustomobject]@{
                control_ref_id = $_.control_ref_id
                control_action = $_.control_action
                source_control_ref = $_.source_control_ref
                status = "control_ref_packet_only_not_executed"
                runtime_flags = Get-R17Cycle2DevExecutionFalseFlags
            }
        })
    Write-R17Cycle2DevExecutionJson -Path $paths.ControlRefs -Value $controlRefs

    $boardEventRefs = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_board_event_refs" -PacketId "r17_024_cycle_2_board_event_refs" -Status "ready_for_qa_packet_only" -GitIdentity $git
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name event_count -Value 4
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name initial_lane -Value "ready_for_dev"
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name intermediate_lane -Value "in_dev"
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name final_lane -Value "ready_for_qa"
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name live_board_mutation_performed -Value $false -Force
    $boardEventRefs | Add-Member -MemberType NoteProperty -Name runtime_card_creation_performed -Value $false -Force
    Write-R17Cycle2DevExecutionJson -Path $paths.BoardEventRefs -Value $boardEventRefs

    $checkReport = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_check_report" -PacketId "r17_024_cycle_2_check_report" -Status "ready_for_qa_packet_only" -GitIdentity $git
    $checkReport | Add-Member -MemberType NoteProperty -Name check_report_id -Value "r17_024_cycle_2_check_report"
    $checkReport | Add-Member -MemberType NoteProperty -Name aggregate_verdict -Value $script:AggregateVerdict
    $checkReport | Add-Member -MemberType NoteProperty -Name validation_summary -Value ([pscustomobject]@{
        contract_valid = "passed"
        input_task_packet_ref_valid = "passed"
        dev_request_packet_valid = "passed"
        dev_result_packet_valid = "passed"
        dev_diff_status_summary_valid = "passed"
        a2a_refs_packet_only = "passed"
        dispatch_refs_packet_only = "passed"
        control_refs_packet_only = "passed"
        invocation_refs_packet_only = "passed"
        tool_call_refs_packet_only = "passed"
        board_ready_for_dev_to_ready_for_qa_evidence = "passed"
        ui_snapshot_read_only = "passed"
        non_claims_preserved = "passed"
    })
    Write-R17Cycle2DevExecutionJson -Path $paths.CheckReport -Value $checkReport

    $boardCard = [ordered]@{
        artifact_type = "r17_board_card"
        contract_version = "v1"
        card_id = $script:CardId
        milestone = $script:MilestoneName
        task_id = "R17-023"
        cycle_source_task = "R17-024"
        title = "Cycle 1 card after Cycle 2 Developer/Codex packet capture"
        description = "R17-024 records a repo-backed Cycle 2 Developer/Codex execution package and deterministic board evidence moving the R17-023 Cycle 1 card to Ready for QA. It is not live board mutation, product runtime, QA, audit, or autonomous Codex invocation."
        double_diamond_stage = "deliver"
        lane = "ready_for_qa"
        owner_role = "developer"
        current_agent = "packet_only_no_live_agent"
        status = "active"
        acceptance_criteria = @(
            "R17-023 ready-for-dev packet is referenced as input.",
            "R17-024 dev request/result packets exist.",
            "R17-024 diff/status summary exists without embedded source contents.",
            "Board event evidence shows Ready for Dev to In Dev to Ready for QA."
        )
        qa_criteria = @(
            "R17-024 validator and focused test pass.",
            "Existing R17 foundation gates still pass.",
            "No QA result is claimed by R17-024.",
            "No audit verdict or release recommendation is claimed by R17-024."
        )
        evidence_refs = @(Get-R17Cycle2DevExecutionEvidenceRefs)
        memory_refs = @(Get-R17Cycle2DevExecutionMemoryRefs)
        task_packet_ref = $refs.input_task_packet_ref
        dev_request_packet_ref = $refs.dev_request_packet_ref
        dev_result_packet_ref = $refs.dev_result_packet_ref
        dev_diff_status_summary_ref = $refs.dev_diff_status_summary_ref
        blocker_refs = @()
        user_decision_required = $true
        user_approval_required_for_closure = $true
        allowed_next_lanes = @("ready_for_qa", "in_qa", "blocked")
        forbidden_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
        audit_log_refs = @("$($script:ProofRoot)/proof_review.md", "$($script:CycleRoot)/cycle_2_check_report.json")
        created_by = "r17_023_cycle_1_ready_for_dev_packet"
        updated_by = "deterministic_r17_024_generator"
        claims = $explicitFalseMap
        positive_claims = Get-R17Cycle2DevExecutionPositiveClaims
    }
    Write-R17Cycle2DevExecutionJson -Path $paths.BoardCard -Value ([pscustomobject]$boardCard)

    $eventEvidenceRefs = @(
        "contracts/board/r17_board_event.contract.json",
        "$($script:CycleRoot)/cycle_2_board_event_refs.json",
        "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json",
        "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl",
        "$($script:BoardRoot)/r17_024_cycle_2_dev_execution_board_snapshot.json"
    )
    $eventValidationRefs = @(Get-R17Cycle2DevExecutionValidationRefs)
    $boardEvents = @(
        [pscustomobject]@{
            artifact_type = "r17_board_event"; contract_version = "v1"; event_id = "r17_024_cycle_2_event_001_ready_for_dev_to_in_dev"; card_id = $script:CardId; event_type = "lane_transition_requested"; actor_role = "orchestrator"; agent_id = "r17_024_packet_only_orchestrator_ref"; from_lane = "ready_for_dev"; to_lane = "in_dev"; timestamp_utc = "2026-05-10T00:24:01Z"; input_ref = $refs.input_task_packet_ref; output_ref = $refs.dev_request_packet_ref; evidence_refs = $eventEvidenceRefs; validation_refs = $eventValidationRefs; transition_allowed = $true; user_approval_present = $false; non_claims = @(Get-R17Cycle2DevExecutionNonClaims); rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        },
        [pscustomobject]@{
            artifact_type = "r17_board_event"; contract_version = "v1"; event_id = "r17_024_cycle_2_event_002_dev_result_captured"; card_id = $script:CardId; event_type = "card_updated"; actor_role = "developer"; agent_id = "r17_024_packet_only_developer_codex_ref"; from_lane = "in_dev"; to_lane = "in_dev"; timestamp_utc = "2026-05-10T00:24:02Z"; input_ref = $refs.dev_request_packet_ref; output_ref = $refs.dev_result_packet_ref; evidence_refs = $eventEvidenceRefs; validation_refs = $eventValidationRefs; transition_allowed = $true; user_approval_present = $false; non_claims = @(Get-R17Cycle2DevExecutionNonClaims); rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        },
        [pscustomobject]@{
            artifact_type = "r17_board_event"; contract_version = "v1"; event_id = "r17_024_cycle_2_event_003_in_dev_to_ready_for_qa"; card_id = $script:CardId; event_type = "lane_transition_requested"; actor_role = "orchestrator"; agent_id = "r17_024_packet_only_orchestrator_ref"; from_lane = "in_dev"; to_lane = "ready_for_qa"; timestamp_utc = "2026-05-10T00:24:03Z"; input_ref = $refs.dev_result_packet_ref; output_ref = "$($script:CycleRoot)/cycle_2_board_event_refs.json"; evidence_refs = $eventEvidenceRefs; validation_refs = $eventValidationRefs; transition_allowed = $true; user_approval_present = $false; non_claims = @(Get-R17Cycle2DevExecutionNonClaims); rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        },
        [pscustomobject]@{
            artifact_type = "r17_board_event"; contract_version = "v1"; event_id = "r17_024_cycle_2_event_004_user_decision_required_before_qa"; card_id = $script:CardId; event_type = "user_decision_requested"; actor_role = "release_closeout"; agent_id = "r17_024_packet_only_release_ref"; from_lane = "ready_for_qa"; to_lane = "ready_for_qa"; timestamp_utc = "2026-05-10T00:24:04Z"; input_ref = "$($script:CycleRoot)/cycle_2_check_report.json"; output_ref = "$($script:CycleRoot)/cycle_2_check_report.json"; evidence_refs = $eventEvidenceRefs; validation_refs = $eventValidationRefs; transition_allowed = $false; user_approval_present = $false; non_claims = @(Get-R17Cycle2DevExecutionNonClaims); rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
        }
    )
    Write-R17Cycle2DevExecutionJsonLines -Path $paths.BoardEvents -Values $boardEvents

    $boardSnapshot = [ordered]@{
        artifact_type = "r17_cycle_2_dev_execution_board_snapshot"
        contract_version = "v1"
        source_task = "R17-024"
        input_source_task = "R17-023"
        cycle_id = $script:CycleId
        card_id = $script:CardId
        board_card_ref = "$($script:BoardRoot)/cards/r17_024_cycle_2_dev_execution_card.json"
        board_event_log_ref = "$($script:BoardRoot)/events/r17_024_cycle_2_dev_execution_events.jsonl"
        event_count = $boardEvents.Count
        initial_lane = "ready_for_dev"
        intermediate_lane = "in_dev"
        final_lane = "ready_for_qa"
        final_status = "ready_for_qa_packet_only"
        repo_backed_snapshot_only = $true
        live_board_mutation_performed = $false
        runtime_card_creation_performed = $false
        user_decision_required = $true
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
        rejected_claims = @(Get-R17Cycle2DevExecutionRejectedClaims)
    }
    Write-R17Cycle2DevExecutionJson -Path $paths.BoardSnapshot -Value ([pscustomobject]$boardSnapshot)

    $uiSnapshot = New-R17Cycle2DevExecutionBasePacket -ArtifactType "r17_cycle_2_dev_execution_ui_snapshot" -PacketId "r17_024_cycle_2_dev_execution_ui_snapshot" -Status "ready_for_qa_packet_only" -GitIdentity $git
    $uiSnapshot | Add-Member -MemberType NoteProperty -Name read_only_surface -Value $true
    $uiSnapshot | Add-Member -MemberType NoteProperty -Name visible_cycle_card -Value ([pscustomobject]@{
        card_id = $script:CardId
        source_task = "R17-023"
        cycle_source_task = "R17-024"
        lane = "ready_for_qa"
        status = "ready_for_qa_packet_only"
        user_decision_required = $true
    })
    $uiSnapshot | Add-Member -MemberType NoteProperty -Name visible_packet_refs -Value @($refs.input_task_packet_ref, $refs.dev_request_packet_ref, $refs.dev_result_packet_ref, $refs.dev_diff_status_summary_ref)
    Write-R17Cycle2DevExecutionJson -Path $paths.UiSnapshot -Value $uiSnapshot

    New-R17Cycle2DevExecutionFixtures -RepositoryRoot $RepositoryRoot | Out-Null
    New-R17Cycle2DevExecutionProofReview -RepositoryRoot $RepositoryRoot | Out-Null

    return [pscustomobject]@{
        Contract = $paths.Contract
        CycleRoot = (Split-Path -Parent $paths.DevRequest)
        BoardCard = $paths.BoardCard
        BoardEvents = $paths.BoardEvents
        BoardSnapshot = $paths.BoardSnapshot
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $script:AggregateVerdict
    }
}

function New-R17Cycle2DevExecutionFixtures {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    $paths = Get-R17Cycle2DevExecutionPaths -RepositoryRoot $RepositoryRoot
    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    $fixtures = @(
        [pscustomobject]@{ name = "invalid_missing_input_task_packet_ref"; target = "dev_request"; mutation = "remove"; property = "input_task_packet_ref"; expected_failure_fragments = @("input_task_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_dev_request_packet_ref"; target = "dev_result"; mutation = "remove"; property = "dev_request_packet_ref"; expected_failure_fragments = @("dev_request_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_dev_result_packet_ref"; target = "dev_request"; mutation = "remove"; property = "dev_result_packet_ref"; expected_failure_fragments = @("dev_result_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_dev_diff_status_summary_ref"; target = "dev_result"; mutation = "remove"; property = "dev_diff_status_summary_ref"; expected_failure_fragments = @("dev_diff_status_summary_ref") },
        [pscustomobject]@{ name = "invalid_missing_memory_refs"; target = "dev_request"; mutation = "set"; property = "memory_packet_refs"; value = @(); expected_failure_fragments = @("memory_packet_refs") },
        [pscustomobject]@{ name = "invalid_missing_artifact_refs"; target = "dev_request"; mutation = "set"; property = "artifact_refs"; value = @(); expected_failure_fragments = @("artifact_refs") },
        [pscustomobject]@{ name = "invalid_missing_a2a_refs"; target = "dev_request"; mutation = "set"; property = "a2a_message_refs"; value = @(); expected_failure_fragments = @("a2a_message_refs") },
        [pscustomobject]@{ name = "invalid_missing_handoff_refs"; target = "dev_request"; mutation = "set"; property = "handoff_refs"; value = @(); expected_failure_fragments = @("handoff_refs") },
        [pscustomobject]@{ name = "invalid_missing_dispatch_refs"; target = "dev_request"; mutation = "set"; property = "dispatch_refs"; value = @(); expected_failure_fragments = @("dispatch_refs") },
        [pscustomobject]@{ name = "invalid_missing_control_refs"; target = "dev_request"; mutation = "set"; property = "control_refs"; value = @(); expected_failure_fragments = @("control_refs") },
        [pscustomobject]@{ name = "invalid_missing_invocation_refs"; target = "dev_request"; mutation = "set"; property = "invocation_refs"; value = @(); expected_failure_fragments = @("invocation_refs") },
        [pscustomobject]@{ name = "invalid_missing_tool_call_refs"; target = "dev_request"; mutation = "set"; property = "tool_call_ledger_refs"; value = @(); expected_failure_fragments = @("tool_call_ledger_refs") },
        [pscustomobject]@{ name = "invalid_missing_board_event_refs"; target = "dev_request"; mutation = "set"; property = "board_event_refs"; value = @(); expected_failure_fragments = @("board_event_refs") },
        [pscustomobject]@{ name = "invalid_missing_evidence_refs"; target = "dev_request"; mutation = "set"; property = "evidence_refs"; value = @(); expected_failure_fragments = @("evidence_refs") },
        [pscustomobject]@{ name = "invalid_missing_authority_refs"; target = "dev_request"; mutation = "set"; property = "authority_refs"; value = @(); expected_failure_fragments = @("authority_refs") },
        [pscustomobject]@{ name = "invalid_missing_validation_refs"; target = "dev_request"; mutation = "set"; property = "validation_refs"; value = @(); expected_failure_fragments = @("validation_refs") },
        [pscustomobject]@{ name = "invalid_wildcard_evidence_ref"; target = "dev_request"; mutation = "append"; property = "evidence_refs"; value = "state/**/*.json"; expected_failure_fragments = @("wildcard") },
        [pscustomobject]@{ name = "invalid_local_backups_ref"; target = "dev_request"; mutation = "append"; property = "evidence_refs"; value = ".local_backups/r17.json"; expected_failure_fragments = @(".local_backups") },
        [pscustomobject]@{ name = "invalid_broad_repo_scan_output"; target = "dev_diff"; mutation = "set"; property = "summary"; value = "BROAD_REPO_SCAN_OUTPUT_BEGIN all repo files"; expected_failure_fragments = @("broad repo scan output") },
        [pscustomobject]@{ name = "invalid_embedded_source_contents"; target = "dev_diff"; mutation = "set"; property = "summary"; value = "EMBEDDED_FULL_SOURCE_FILE_CONTENTS_BEGIN function x"; expected_failure_fragments = @("full source file contents") },
        [pscustomobject]@{ name = "invalid_product_runtime_executed"; target = "dev_result"; mutation = "set"; property = "runtime_flags.product_runtime_executed"; value = $true; expected_failure_fragments = @("product_runtime_executed") },
        [pscustomobject]@{ name = "invalid_live_codex_adapter_invoked"; target = "dev_result"; mutation = "set"; property = "runtime_flags.live_codex_executor_adapter_invoked"; value = $true; expected_failure_fragments = @("live_codex_executor_adapter_invoked") },
        [pscustomobject]@{ name = "invalid_no_manual_prompt_transfer_claim"; target = "dev_result"; mutation = "set"; property = "runtime_flags.no_manual_prompt_transfer_claimed"; value = $true; expected_failure_fragments = @("no_manual_prompt_transfer_claimed") },
        [pscustomobject]@{ name = "invalid_qa_result_claim"; target = "dev_result"; mutation = "set"; property = "runtime_flags.qa_result_claimed"; value = $true; expected_failure_fragments = @("qa_result_claimed") },
        [pscustomobject]@{ name = "invalid_audit_verdict_claim"; target = "dev_result"; mutation = "set"; property = "runtime_flags.audit_verdict_claimed"; value = $true; expected_failure_fragments = @("audit_verdict_claimed") },
        [pscustomobject]@{ name = "invalid_future_r17_025_completion"; target = "dev_result"; mutation = "append"; property = "non_claims"; value = "R17-025 completed QA pass"; expected_failure_fragments = @("future R17-025+") }
    )

    foreach ($fixture in $fixtures) {
        Write-R17Cycle2DevExecutionJson -Path (Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.name)) -Value $fixture
    }

    $manifest = [pscustomobject]@{
        artifact_type = "r17_cycle_2_dev_execution_fixture_manifest"
        source_task = "R17-024"
        fixture_count = $fixtures.Count
        invalid_fixture_files = @($fixtures | ForEach-Object { "{0}.json" -f $_.name })
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
    }
    Write-R17Cycle2DevExecutionJson -Path $paths.FixtureManifest -Value $manifest
}

function New-R17Cycle2DevExecutionProofReview {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    $paths = Get-R17Cycle2DevExecutionPaths -RepositoryRoot $RepositoryRoot
    $evidenceRefs = @(Get-R17Cycle2DevExecutionEvidenceRefs)
    $proofText = @"
# R17-024 Cycle 2 Developer/Codex Execution Proof Review

R17-024 creates a repo-backed Cycle 2 Developer/Codex execution package only. It captures a Developer/Codex request packet, result packet, compact diff/status summary, packet-only A2A/dispatch/control/invocation/tool-call refs, deterministic board event evidence, and a read-only UI snapshot.

The board evidence moves the R17-023 Cycle 1 card from Ready for Dev to In Dev to Ready for QA as repo-backed evidence only. No live board mutation is claimed.

Non-claims preserved: no live cycle runtime, no live Orchestrator runtime, no live Developer/Codex adapter invocation, no autonomous Codex invocation by product runtime, no live A2A runtime, no live A2A messages sent, no adapter runtime, no actual tool call, no external API call, no live board mutation, no QA result, no real audit verdict, no external audit acceptance, no autonomous agents, no product runtime, no main merge, and no no-manual-prompt-transfer success claim.

R17 is active through R17-024 only. R17-025 through R17-028 remain planned only.
"@
    Write-R17Cycle2DevExecutionText -Path $paths.ProofReview -Value $proofText

    $evidenceIndex = [pscustomobject]@{
        artifact_type = "r17_cycle_2_dev_execution_evidence_index"
        source_task = "R17-024"
        cycle_id = $script:CycleId
        evidence_ref_count = $evidenceRefs.Count
        evidence_refs = $evidenceRefs
        non_claims = @(Get-R17Cycle2DevExecutionNonClaims)
    }
    Write-R17Cycle2DevExecutionJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $validationText = @"
# R17-024 Validation Manifest

- `tools/validate_r17_cycle_2_dev_execution.ps1`
- `tests/test_r17_cycle_2_dev_execution.ps1`
- Existing R17 foundation gates listed in the task request
- `git diff --check`
- `tests/test_status_doc_gate.ps1`

This manifest records validation routes only. It is not a QA result, audit verdict, external audit acceptance, product runtime, live adapter runtime, or main merge claim.
"@
    Write-R17Cycle2DevExecutionText -Path $paths.ValidationManifest -Value $validationText
}

function Assert-R17Cycle2DevExecutionRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in $FieldNames) {
        if (-not (Test-R17Cycle2DevExecutionHasProperty -Object $Object -Name $fieldName)) {
            throw "$Context missing required field '$fieldName'."
        }
    }
}

function Assert-R17Cycle2DevExecutionFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in $FieldNames) {
        if (-not (Test-R17Cycle2DevExecutionHasProperty -Object $Object -Name $fieldName)) {
            throw "$Context missing explicit false field '$fieldName'."
        }
        if ([bool]$Object.PSObject.Properties[$fieldName].Value -ne $false) {
            throw "$Context field '$fieldName' must be false."
        }
    }
}

function Assert-R17Cycle2DevExecutionNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)][AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) { return }

    if ($Value -is [string]) {
        if ($Value -match '(?i)\.local_backups') { throw "$Context references .local_backups." }
        if ($Value -match '(?i)BROAD_REPO_SCAN_OUTPUT_BEGIN|broad repo scan output:') { throw "$Context includes broad repo scan output." }
        if ($Value -match '(?i)EMBEDDED_FULL_SOURCE_FILE_CONTENTS_BEGIN|full source file contents begin') { throw "$Context embeds full source file contents." }
        if ($Value.Length -gt 4000) { throw "$Context contains an overlarge string; compact refs are required." }
        if ($Value -match '(?i)\bR17-0?2[5-8]\b.{0,120}\b(done|complete|completed|implemented|executed|passed|accepted|ready for audit|audit complete|release recommendation)\b') {
            throw "$Context contains future R17-025+ completion claim."
        }
        if ($Value -match '(?i)no[- ]manual[- ]prompt[- ]transfer.{0,80}(solved|success|implemented|complete|completed|achieved)') {
            throw "$Context claims no-manual-prompt-transfer success."
        }
        return
    }

    if ($Value -is [System.ValueType]) { return }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $Value[$key] -Context "$Context.$key"
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $index = 0
        foreach ($item in $Value) {
            Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $item -Context "$Context[$index]"
            $index += 1
        }
        return
    }

    foreach ($property in $Value.PSObject.Properties) {
        Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $property.Value -Context "$Context.$($property.Name)"
    }
}

function Assert-R17Cycle2DevExecutionSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot),
        [switch]$RequireExistingPath
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context missing ref path." }
    if ($Path -match '[\*\?]') { throw "$Context contains wildcard path '$Path'." }
    if ($Path -match '(?i)\.local_backups') { throw "$Context references .local_backups path '$Path'." }
    if ($Path -match '(?i)BROAD_REPO_SCAN_OUTPUT_BEGIN|broad repo scan output') { throw "$Context references forbidden broad repo scan output '$Path'." }
    if ($Path -match '(?i)EMBEDDED_FULL_SOURCE_FILE_CONTENTS_BEGIN') { throw "$Context references embedded full source file contents '$Path'." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context must be repo-relative, got '$Path'." }
    if ($Path -match '^\.\.' -or $Path -match '(^|/)\.\.(/|$)') { throw "$Context must not traverse parent paths, got '$Path'." }
    if ($Path -match '^[a-zA-Z][a-zA-Z0-9+.-]*://') { throw "$Context must not use external URI '$Path'." }

    if ($RequireExistingPath) {
        $pathWithoutAnchor = ($Path -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathWithoutAnchor)) { throw "$Context has empty path before anchor." }
        $resolved = Resolve-R17Cycle2DevExecutionPath -RepositoryRoot $RepositoryRoot -PathValue $pathWithoutAnchor
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context references missing path '$Path'."
        }
    }
}

function Assert-R17Cycle2DevExecutionRefArray {
    param(
        [Parameter(Mandatory = $true)]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot),
        [switch]$SkipRefExistence
    )

    $items = @($Values | ForEach-Object { [string]$_ })
    if ($items.Count -eq 0) { throw "$Context must contain at least one ref." }
    foreach ($item in $items) {
        Assert-R17Cycle2DevExecutionSafeRefPath -Path $item -Context $Context -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    }
}

function Assert-R17Cycle2DevExecutionCyclePacket {
    param(
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17Cycle2DevExecutionRequiredFields -Object $Packet -FieldNames $script:RequiredCyclePacketFields -Context $Context
    if ([string]$Packet.cycle_id -ne $script:CycleId) { throw "$Context cycle_id must be $script:CycleId." }
    if ([string]$Packet.source_task -ne $script:SourceTask) { throw "$Context source_task must be R17-024." }
    if ([int]$Packet.cycle_number -ne 2) { throw "$Context cycle_number must be 2." }
    if ([string]$Packet.card_id -ne $script:CardId) { throw "$Context card_id must be $script:CardId." }
    if ($script:AllowedStatuses -notcontains [string]$Packet.status) { throw "$Context status '$($Packet.status)' is not allowed." }
    if ([string]$Packet.status -eq "invalid") { throw "$Context must not use invalid status." }
    if ([string]$Packet.execution_mode -notmatch 'repo_backed_cycle_2.*not_product_runtime') { throw "$Context execution_mode must be repo-backed and not product runtime." }

    foreach ($singleRefField in @("input_task_packet_ref", "dev_request_packet_ref", "dev_result_packet_ref", "dev_diff_status_summary_ref")) {
        Assert-R17Cycle2DevExecutionSafeRefPath -Path ([string]$Packet.PSObject.Properties[$singleRefField].Value) -Context "$Context $singleRefField" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    }
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.memory_packet_refs) -Context "$Context memory_packet_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.artifact_refs) -Context "$Context artifact_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.a2a_message_refs) -Context "$Context a2a_message_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.handoff_refs) -Context "$Context handoff_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.dispatch_refs) -Context "$Context dispatch_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.control_refs) -Context "$Context control_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.invocation_refs) -Context "$Context invocation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.tool_call_ledger_refs) -Context "$Context tool_call_ledger_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.board_event_refs) -Context "$Context board_event_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.evidence_refs) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.authority_refs) -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($Packet.validation_refs) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionFalseFields -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$Context runtime_flags"
    Assert-R17Cycle2DevExecutionFalseFields -Object $Packet -FieldNames $script:ExplicitFalseFields -Context $Context
    Assert-R17Cycle2DevExecutionRequiredFields -Object $Packet.positive_claims -FieldNames $script:PositiveClaimFields -Context "$Context positive_claims"
    foreach ($field in $script:PositiveClaimFields) {
        if ([bool]$Packet.positive_claims.PSObject.Properties[$field].Value -ne $true) {
            throw "$Context positive_claims field '$field' must be true."
        }
    }
    Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $Packet -Context $Context
}

function Assert-R17Cycle2DevExecutionKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-024 must preserve exact renderer bytes."
    }
}

function Test-R17Cycle2DevExecutionSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$DevRequest,
        [Parameter(Mandatory = $true)]$DevResult,
        [Parameter(Mandatory = $true)]$DevDiffStatusSummary,
        [Parameter(Mandatory = $true)]$A2aMessages,
        [Parameter(Mandatory = $true)]$A2aHandoffs,
        [Parameter(Mandatory = $true)]$A2aDispatchRefs,
        [Parameter(Mandatory = $true)]$ToolCallLedgerRefs,
        [Parameter(Mandatory = $true)]$InvocationRefs,
        [Parameter(Mandatory = $true)]$ControlRefs,
        [Parameter(Mandatory = $true)]$BoardEventRefs,
        [Parameter(Mandatory = $true)]$CheckReport,
        [Parameter(Mandatory = $true)]$BoardCard,
        [Parameter(Mandatory = $true)]$BoardEvents,
        [Parameter(Mandatory = $true)]$BoardSnapshot,
        [Parameter(Mandatory = $true)]$UiSnapshot,
        [string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot),
        [switch]$SkipRefExistence,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17Cycle2DevExecutionRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "required_cycle_packet_fields", "allowed_statuses", "required_explicit_false_fields", "validation_policy", "runtime_boundaries", "explicit_false_fields", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.artifact_type -ne "r17_cycle_2_dev_execution_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne "R17-024" -or $Contract.active_through_task -ne "R17-024") { throw "contract must keep R17 active through R17-024." }
    if ($Contract.planned_only_from -ne "R17-025" -or $Contract.planned_only_through -ne "R17-028") { throw "contract must keep R17-025 through R17-028 planned only." }
    Assert-R17Cycle2DevExecutionFalseFields -Object $Contract.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract runtime_boundaries"
    Assert-R17Cycle2DevExecutionFalseFields -Object $Contract.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "contract explicit_false_fields"

    foreach ($packetInfo in @(
            [pscustomobject]@{ Name = "dev request"; Packet = $DevRequest },
            [pscustomobject]@{ Name = "dev result"; Packet = $DevResult },
            [pscustomobject]@{ Name = "dev diff/status summary"; Packet = $DevDiffStatusSummary },
            [pscustomobject]@{ Name = "A2A messages"; Packet = $A2aMessages },
            [pscustomobject]@{ Name = "A2A handoffs"; Packet = $A2aHandoffs },
            [pscustomobject]@{ Name = "dispatch refs"; Packet = $A2aDispatchRefs },
            [pscustomobject]@{ Name = "tool-call refs"; Packet = $ToolCallLedgerRefs },
            [pscustomobject]@{ Name = "invocation refs"; Packet = $InvocationRefs },
            [pscustomobject]@{ Name = "control refs"; Packet = $ControlRefs },
            [pscustomobject]@{ Name = "board event refs"; Packet = $BoardEventRefs },
            [pscustomobject]@{ Name = "check report"; Packet = $CheckReport },
            [pscustomobject]@{ Name = "UI snapshot"; Packet = $UiSnapshot }
        )) {
        Assert-R17Cycle2DevExecutionCyclePacket -Packet $packetInfo.Packet -Context $packetInfo.Name -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    if ([string]$DevRequest.status -ne "dev_request_packet_created") { throw "dev request status must be dev_request_packet_created." }
    foreach ($field in @("scope", "constraints", "allowed_files", "acceptance_criteria", "validation_requirements", "evidence_requirements")) {
        if (@($DevRequest.PSObject.Properties[$field].Value).Count -eq 0) { throw "dev request $field must be populated." }
    }
    if ([bool]$DevRequest.execution_requested_by_product_runtime -ne $false -or [bool]$DevRequest.manual_prompt_transfer_eliminated -ne $false) {
        throw "dev request must not claim product runtime execution or manual prompt transfer elimination."
    }

    if ([string]$DevResult.status -ne "dev_result_packet_captured_repo_backed") { throw "dev result status must be dev_result_packet_captured_repo_backed." }
    if (@($DevResult.committed_artifact_refs).Count -eq 0 -or @($DevResult.changed_file_summary).Count -eq 0) { throw "dev result must include artifact refs and changed file summary." }
    if ([bool]$DevResult.product_runtime_result -ne $false) { throw "dev result must not be a product runtime result." }
    if ([string]$DevResult.qa_result -ne "not_claimed_r17_024" -or [string]$DevResult.audit_verdict -ne "not_claimed_r17_024") { throw "dev result must not claim QA result or audit verdict." }

    if ([bool]$DevDiffStatusSummary.content_policy.source_contents_embedded -ne $false -or [bool]$DevDiffStatusSummary.content_policy.broad_repo_scan_output_embedded -ne $false) {
        throw "dev diff/status summary must not embed source contents or broad repo scan output."
    }

    if ([int]$A2aMessages.message_count -ne @($A2aMessages.messages).Count) { throw "A2A message count does not match messages." }
    foreach ($message in @($A2aMessages.messages)) {
        if ([string]$message.status -ne "not_sent_packet_candidate") { throw "A2A message '$($message.message_id)' must be not_sent_packet_candidate." }
        Assert-R17Cycle2DevExecutionFalseFields -Object $message.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "A2A message $($message.message_id) runtime_flags"
    }

    if ([int]$A2aHandoffs.handoff_count -ne @($A2aHandoffs.handoffs).Count) { throw "handoff count does not match handoffs." }
    foreach ($handoff in @($A2aHandoffs.handoffs)) {
        if ([string]$handoff.status -ne "not_executed_packet_candidate") { throw "handoff '$($handoff.handoff_id)' must be not_executed_packet_candidate." }
        Assert-R17Cycle2DevExecutionFalseFields -Object $handoff.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "handoff $($handoff.handoff_id) runtime_flags"
    }

    if ([int]$A2aDispatchRefs.dispatch_ref_count -ne @($A2aDispatchRefs.dispatch_refs_detail).Count) { throw "dispatch ref count does not match dispatch refs." }
    foreach ($dispatchRef in @($A2aDispatchRefs.dispatch_refs_detail)) {
        if ([string]$dispatchRef.dispatch_decision -ne "not_dispatched_packet_only") { throw "dispatch ref '$($dispatchRef.dispatch_ref_id)' must be not_dispatched_packet_only." }
    }

    if ([int]$ToolCallLedgerRefs.tool_call_ref_count -ne @($ToolCallLedgerRefs.tool_call_refs_detail).Count) { throw "tool-call ref count does not match detail." }
    foreach ($toolCallRef in @($ToolCallLedgerRefs.tool_call_refs_detail)) {
        if ([bool]$toolCallRef.actual_tool_call_performed -ne $false -or [bool]$toolCallRef.adapter_runtime_invoked -ne $false) {
            throw "tool-call ref '$($toolCallRef.tool_call_ref_id)' must stay packet-only."
        }
    }

    if ([int]$InvocationRefs.invocation_ref_count -ne @($InvocationRefs.invocation_refs_detail).Count) { throw "invocation ref count does not match detail." }
    foreach ($invocationRef in @($InvocationRefs.invocation_refs_detail)) {
        if ([bool]$invocationRef.actual_agent_invoked -ne $false) { throw "invocation ref '$($invocationRef.invocation_ref_id)' must not claim actual agent invocation." }
    }

    if ([int]$ControlRefs.control_ref_count -ne @($ControlRefs.control_refs_detail).Count) { throw "control ref count does not match control refs." }
    if ([int]$BoardEventRefs.event_count -ne @($BoardEvents).Count) { throw "board event ref count does not match event log." }
    if ([string]$BoardEventRefs.initial_lane -ne "ready_for_dev" -or [string]$BoardEventRefs.intermediate_lane -ne "in_dev" -or [string]$BoardEventRefs.final_lane -ne "ready_for_qa") {
        throw "board event refs must show Ready for Dev to In Dev to Ready for QA."
    }

    Assert-R17Cycle2DevExecutionRequiredFields -Object $BoardCard -FieldNames @("artifact_type", "card_id", "task_id", "cycle_source_task", "lane", "status", "evidence_refs", "memory_refs", "task_packet_ref", "non_claims", "claims") -Context "board card"
    if ($BoardCard.card_id -ne $script:CardId -or $BoardCard.task_id -ne "R17-023" -or $BoardCard.cycle_source_task -ne "R17-024") { throw "board card identity is invalid." }
    if ($BoardCard.lane -ne "ready_for_qa") { throw "board card lane must be ready_for_qa." }
    Assert-R17Cycle2DevExecutionFalseFields -Object $BoardCard.claims -FieldNames $script:ExplicitFalseFields -Context "board card claims"
    Assert-R17Cycle2DevExecutionRefArray -Values @($BoardCard.evidence_refs) -Context "board card evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle2DevExecutionRefArray -Values @($BoardCard.memory_refs) -Context "board card memory_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence

    if ([string]$BoardSnapshot.final_lane -ne "ready_for_qa" -or [bool]$BoardSnapshot.live_board_mutation_performed -ne $false -or [bool]$BoardSnapshot.runtime_card_creation_performed -ne $false) {
        throw "board snapshot must be ready_for_qa with no live board mutation or runtime card creation."
    }
    if ([int]$BoardSnapshot.event_count -ne @($BoardEvents).Count) { throw "board snapshot event_count does not match event log." }
    foreach ($event in @($BoardEvents)) {
        Assert-R17Cycle2DevExecutionRequiredFields -Object $event -FieldNames @("artifact_type", "event_id", "card_id", "event_type", "actor_role", "from_lane", "to_lane", "input_ref", "output_ref", "evidence_refs", "validation_refs", "transition_allowed", "user_approval_present", "non_claims", "rejected_claims") -Context "board event"
        if ($event.card_id -ne $script:CardId) { throw "board event '$($event.event_id)' card_id is invalid." }
        Assert-R17Cycle2DevExecutionRefArray -Values @($event.evidence_refs) -Context "board event $($event.event_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        Assert-R17Cycle2DevExecutionRefArray -Values @($event.validation_refs) -Context "board event $($event.event_id) validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    if ($CheckReport.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($check in @($CheckReport.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    foreach ($object in @($Contract, $DevRequest, $DevResult, $DevDiffStatusSummary, $A2aMessages, $A2aHandoffs, $A2aDispatchRefs, $ToolCallLedgerRefs, $InvocationRefs, $ControlRefs, $BoardEventRefs, $CheckReport, $BoardCard, $BoardSnapshot, $UiSnapshot)) {
        Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $object -Context "R17-024 cycle dev execution artifact set"
    }
    foreach ($event in @($BoardEvents)) {
        Assert-R17Cycle2DevExecutionNoForbiddenContent -Value $event -Context "R17-024 board event"
    }

    if (-not $SkipKanbanJsCheck) {
        Assert-R17Cycle2DevExecutionKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        CycleId = $script:CycleId
        CardId = $script:CardId
        MessageCount = [int]$A2aMessages.message_count
        HandoffCount = [int]$A2aHandoffs.handoff_count
        DispatchRefCount = [int]$A2aDispatchRefs.dispatch_ref_count
        ToolCallRefCount = [int]$ToolCallLedgerRefs.tool_call_ref_count
        InvocationRefCount = [int]$InvocationRefs.invocation_ref_count
        ControlRefCount = [int]$ControlRefs.control_ref_count
        BoardEventCount = [int]$BoardEventRefs.event_count
        FinalLane = [string]$BoardEventRefs.final_lane
        LiveCycleRuntimeImplemented = $false
        LiveOrchestratorRuntimeInvoked = $false
        LiveDeveloperAgentInvoked = $false
        LiveCodexExecutorAdapterInvoked = $false
        CodexExecutorInvokedByProductRuntime = $false
        LiveA2aDispatchPerformed = $false
        A2aRuntimeImplemented = $false
        A2aMessageSent = $false
        AdapterRuntimeInvoked = $false
        ActualToolCallPerformed = $false
        ExternalApiCallPerformed = $false
        LiveBoardMutationPerformed = $false
        RuntimeCardCreationPerformed = $false
        QaResultClaimed = $false
        RealAuditVerdict = $false
        ExternalAuditAcceptanceClaimed = $false
        AutonomousAgentExecuted = $false
        ProductRuntimeExecuted = $false
        MainMergeClaimed = $false
        NoManualPromptTransferClaimed = $false
    }
}

function Test-R17Cycle2DevExecution {
    param([string]$RepositoryRoot = (Get-R17Cycle2DevExecutionRepositoryRoot))

    $paths = Get-R17Cycle2DevExecutionPaths -RepositoryRoot $RepositoryRoot
    return Test-R17Cycle2DevExecutionSet `
        -Contract (Read-R17Cycle2DevExecutionJson -Path $paths.Contract) `
        -DevRequest (Read-R17Cycle2DevExecutionJson -Path $paths.DevRequest) `
        -DevResult (Read-R17Cycle2DevExecutionJson -Path $paths.DevResult) `
        -DevDiffStatusSummary (Read-R17Cycle2DevExecutionJson -Path $paths.DevDiffStatusSummary) `
        -A2aMessages (Read-R17Cycle2DevExecutionJson -Path $paths.A2aMessages) `
        -A2aHandoffs (Read-R17Cycle2DevExecutionJson -Path $paths.A2aHandoffs) `
        -A2aDispatchRefs (Read-R17Cycle2DevExecutionJson -Path $paths.A2aDispatchRefs) `
        -ToolCallLedgerRefs (Read-R17Cycle2DevExecutionJson -Path $paths.ToolCallLedgerRefs) `
        -InvocationRefs (Read-R17Cycle2DevExecutionJson -Path $paths.InvocationRefs) `
        -ControlRefs (Read-R17Cycle2DevExecutionJson -Path $paths.ControlRefs) `
        -BoardEventRefs (Read-R17Cycle2DevExecutionJson -Path $paths.BoardEventRefs) `
        -CheckReport (Read-R17Cycle2DevExecutionJson -Path $paths.CheckReport) `
        -BoardCard (Read-R17Cycle2DevExecutionJson -Path $paths.BoardCard) `
        -BoardEvents (Read-R17Cycle2DevExecutionJsonLines -Path $paths.BoardEvents) `
        -BoardSnapshot (Read-R17Cycle2DevExecutionJson -Path $paths.BoardSnapshot) `
        -UiSnapshot (Read-R17Cycle2DevExecutionJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}
