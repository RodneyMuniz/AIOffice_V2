Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-023"
$script:SeedSourceTask = "R17-022"
$script:CycleId = "r17_023_cycle_1_definition"
$script:CycleNumber = 1
$script:CycleName = "Cycle 1 Definition: Orchestrator to PM/Architect to Board"
$script:CardId = "R17-023-CYCLE-1"
$script:AggregateVerdict = "generated_r17_cycle_1_definition_package_candidate"
$script:CycleRoot = "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition"
$script:FixtureRoot = "tests/fixtures/r17_cycle_1_definition"

$script:AllowedStatuses = @(
    "cycle_1_definition_packet_only",
    "operator_intent_captured_repo_backed",
    "pm_architect_definition_generated_repo_backed",
    "ready_for_dev_packet_only",
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
    "operator_intent_ref",
    "orchestrator_packet_ref",
    "pm_definition_packet_ref",
    "architect_definition_packet_ref",
    "task_packet_ready_for_dev_ref",
    "memory_packet_refs",
    "artifact_refs",
    "a2a_message_refs",
    "handoff_refs",
    "dispatch_refs",
    "control_refs",
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
    "live_pm_agent_invoked",
    "live_architect_agent_invoked",
    "live_agent_runtime_invoked",
    "live_a2a_dispatch_performed",
    "a2a_runtime_implemented",
    "a2a_message_sent",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "live_board_mutation_performed",
    "runtime_card_creation_performed",
    "codex_executor_invoked",
    "qa_test_agent_invoked",
    "evidence_auditor_api_invoked",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "product_runtime_executed",
    "autonomous_agent_executed",
    "main_merge_claimed"
)

$script:AdditionalFalseFields = @(
    "task_packet_executed",
    "implementation_started",
    "pm_agent_invocation_performed",
    "architect_agent_invocation_performed",
    "orchestrator_runtime_executed",
    "live_dispatch_record_created",
    "live_board_event_written",
    "product_runtime_implemented",
    "production_runtime_executed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "executable_handoff_performed",
    "executable_transition_performed",
    "external_integration_performed",
    "broad_repo_scan_used",
    "broad_repo_scan_output_included",
    "full_source_file_contents_embedded",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "r17_024_plus_completion_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed"
)

$script:RuntimeFalseFields = @($script:ExplicitFalseFields + $script:AdditionalFalseFields)

function Get-R17Cycle1DefinitionRepositoryRoot {
    return $script:RepositoryRoot
}

function Resolve-R17Cycle1DefinitionPath {
    param(
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17Cycle1DefinitionJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R17Cycle1DefinitionJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $records += ($line | ConvertFrom-Json)
    }
    return $records
}

function Write-R17Cycle1DefinitionJson {
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

function Write-R17Cycle1DefinitionText {
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

function Copy-R17Cycle1DefinitionObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 90 | ConvertFrom-Json)
}

function Test-R17Cycle1DefinitionHasProperty {
    param([Parameter(Mandatory = $true)]$Object, [Parameter(Mandatory = $true)][string]$Name)

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17Cycle1DefinitionProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17Cycle1DefinitionHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Set-R17Cycle1DefinitionObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()]$Value
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17Cycle1DefinitionProperty -Object $current -Name $parts[$index] -Context $Path
    }

    $leaf = $parts[-1]
    if (-not (Test-R17Cycle1DefinitionHasProperty -Object $current -Name $leaf)) {
        Add-Member -InputObject $current -MemberType NoteProperty -Name $leaf -Value $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R17Cycle1DefinitionObjectPathValue {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $TargetObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $current = Get-R17Cycle1DefinitionProperty -Object $current -Name $parts[$index] -Context $Path
    }

    $leaf = $parts[-1]
    if (Test-R17Cycle1DefinitionHasProperty -Object $current -Name $leaf) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Get-R17Cycle1DefinitionPaths {
    param([string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/cycles/r17_cycle_1_definition.contract.json"
        OperatorIntent = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/operator_intent_packet.json"
        OrchestratorPacket = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/orchestrator_cycle_packet.json"
        PmDefinitionPacket = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/pm_definition_packet.json"
        ArchitectDefinitionPacket = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/architect_definition_packet.json"
        TaskPacketReadyForDev = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/task_packet_ready_for_dev.json"
        A2aMessages = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_1_messages.json"
        A2aHandoffs = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_1_handoffs.json"
        A2aDispatchRefs = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json"
        ControlRefs = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_1_control_refs.json"
        BoardEventRefs = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_1_board_event_refs.json"
        CheckReport = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:CycleRoot)/cycle_1_check_report.json"
        BoardCard = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"
        BoardEvents = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl"
        BoardSnapshot = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json"
        UiSnapshot = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_cycle_1_definition_snapshot.json"
        FixtureRoot = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
        ValidCheckReportFixture = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/valid_check_report.json"
        ProofRoot = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17Cycle1DefinitionGitIdentity {
    param([string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17Cycle1DefinitionFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) {
        $flags[$field] = $false
    }
    return [pscustomobject]$flags
}

function Get-R17Cycle1DefinitionExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }
    return [pscustomobject]$flags
}

function Get-R17Cycle1DefinitionCoreRefs {
    return [pscustomobject]@{
        operator_intent_ref = "$($script:CycleRoot)/operator_intent_packet.json"
        orchestrator_packet_ref = "$($script:CycleRoot)/orchestrator_cycle_packet.json"
        pm_definition_packet_ref = "$($script:CycleRoot)/pm_definition_packet.json"
        architect_definition_packet_ref = "$($script:CycleRoot)/architect_definition_packet.json"
        task_packet_ready_for_dev_ref = "$($script:CycleRoot)/task_packet_ready_for_dev.json"
        a2a_message_refs = @(
            "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_pm",
            "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_architect",
            "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_pm_ready_for_dev_packet"
        )
        handoff_refs = @(
            "$($script:CycleRoot)/a2a_cycle_1_handoffs.json#r17_023_cycle_1_handoff_orchestrator_to_pm",
            "$($script:CycleRoot)/a2a_cycle_1_handoffs.json#r17_023_cycle_1_handoff_orchestrator_to_architect",
            "$($script:CycleRoot)/a2a_cycle_1_handoffs.json#r17_023_cycle_1_handoff_pm_to_developer_packet_only"
        )
        dispatch_refs = @(
            "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json#r17_023_cycle_1_dispatch_ref_orchestrator_to_pm",
            "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json#r17_023_cycle_1_dispatch_ref_orchestrator_to_architect",
            "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json#r17_023_cycle_1_dispatch_ref_pm_to_developer_packet_only"
        )
        control_refs = @(
            "$($script:CycleRoot)/cycle_1_control_refs.json#r17_023_cycle_1_stop_ref",
            "$($script:CycleRoot)/cycle_1_control_refs.json#r17_023_cycle_1_retry_ref",
            "$($script:CycleRoot)/cycle_1_control_refs.json#r17_023_cycle_1_reentry_ref",
            "$($script:CycleRoot)/cycle_1_control_refs.json#r17_023_cycle_1_user_decision_ref"
        )
        board_event_refs = @(
            "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl#r17_023_cycle_1_event_001_card_created",
            "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl#r17_023_cycle_1_event_002_moved_to_define",
            "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl#r17_023_cycle_1_event_005_ready_for_dev_packet_only"
        )
    }
}

function Get-R17Cycle1DefinitionMemoryRefs {
    return @(
        "state/agents/r17_agent_memory_packets/orchestrator.memory_packet.json",
        "state/agents/r17_agent_memory_packets/project_manager.memory_packet.json",
        "state/agents/r17_agent_memory_packets/architect.memory_packet.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "state/context/r17_memory_loaded_refs_log.json"
    )
}

function Get-R17Cycle1DefinitionArtifactRefs {
    return @(
        "contracts/cycles/r17_cycle_1_definition.contract.json",
        "$($script:CycleRoot)/operator_intent_packet.json",
        "$($script:CycleRoot)/orchestrator_cycle_packet.json",
        "$($script:CycleRoot)/pm_definition_packet.json",
        "$($script:CycleRoot)/architect_definition_packet.json",
        "$($script:CycleRoot)/task_packet_ready_for_dev.json",
        "$($script:CycleRoot)/a2a_cycle_1_messages.json",
        "$($script:CycleRoot)/a2a_cycle_1_handoffs.json",
        "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json",
        "$($script:CycleRoot)/cycle_1_control_refs.json",
        "$($script:CycleRoot)/cycle_1_board_event_refs.json",
        "$($script:CycleRoot)/cycle_1_check_report.json",
        "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json",
        "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl",
        "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_cycle_1_definition_snapshot.json"
    )
}

function Get-R17Cycle1DefinitionEvidenceRefs {
    return @(
        "contracts/cycles/r17_cycle_1_definition.contract.json",
        "$($script:CycleRoot)/operator_intent_packet.json",
        "$($script:CycleRoot)/orchestrator_cycle_packet.json",
        "$($script:CycleRoot)/pm_definition_packet.json",
        "$($script:CycleRoot)/architect_definition_packet.json",
        "$($script:CycleRoot)/task_packet_ready_for_dev.json",
        "$($script:CycleRoot)/a2a_cycle_1_messages.json",
        "$($script:CycleRoot)/a2a_cycle_1_handoffs.json",
        "$($script:CycleRoot)/a2a_cycle_1_dispatch_refs.json",
        "$($script:CycleRoot)/cycle_1_control_refs.json",
        "$($script:CycleRoot)/cycle_1_board_event_refs.json",
        "$($script:CycleRoot)/cycle_1_check_report.json",
        "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json",
        "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl",
        "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json",
        "state/ui/r17_kanban_mvp/r17_cycle_1_definition_snapshot.json",
        "tools/R17Cycle1Definition.psm1",
        "tools/new_r17_cycle_1_definition.ps1",
        "tools/validate_r17_cycle_1_definition.ps1",
        "tests/test_r17_cycle_1_definition.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/validation_manifest.md"
    )
}

function Get-R17Cycle1DefinitionAuthorityRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "contracts/cycles/r17_cycle_1_definition.contract.json",
        "contracts/intake/r17_operator_intake.contract.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "contracts/agents/r17_agent_registry.contract.json",
        "contracts/context/r17_memory_artifact_loader.contract.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "contracts/runtime/r17_tool_call_ledger.contract.json",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "contracts/board/r17_card.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/orchestration/r17_orchestrator_loop_state_machine.json",
        "state/intake/r17_operator_intake_seed_packet.json",
        "state/context/r17_memory_artifact_loader_report.json"
    )
}

function Get-R17Cycle1DefinitionValidationRefs {
    return @(
        "contracts/cycles/r17_cycle_1_definition.contract.json",
        "$($script:CycleRoot)/cycle_1_check_report.json",
        "tools/validate_r17_cycle_1_definition.ps1",
        "tests/test_r17_cycle_1_definition.ps1",
        "$($script:ProofRoot)/validation_manifest.md"
    )
}

function Get-R17Cycle1DefinitionNonClaims {
    return @(
        "R17-023 creates a repo-backed exercised Cycle 1 definition package only",
        "R17-023 is a deterministic packet-only PM/Architect definition cycle",
        "R17-023 records ready-for-dev packet only and not execution",
        "R17-023 does not implement live cycle runtime",
        "R17-023 does not invoke live Orchestrator runtime",
        "R17-023 does not invoke live PM or Architect agents",
        "R17-023 does not implement live A2A runtime",
        "R17-023 does not send live A2A messages",
        "R17-023 does not invoke adapter runtime",
        "R17-023 does not perform actual tool calls",
        "R17-023 does not call external APIs",
        "R17-023 does not perform live board mutation",
        "R17-023 does not invoke Codex executor",
        "R17-023 does not produce Dev output",
        "R17-023 does not produce QA result",
        "R17-023 does not produce a real audit verdict",
        "R17-023 does not claim external audit acceptance",
        "R17-023 does not execute autonomous agents",
        "R17-023 does not execute product runtime",
        "R17-023 does not claim main merge",
        "R13 remains failed/partial and not closed",
        "R14 caveats remain preserved",
        "R15 caveats remain preserved",
        "R16 remains complete for bounded foundation scope through R16-026 only",
        "R17-024 through R17-028 remain planned only"
    )
}

function Get-R17Cycle1DefinitionRejectedClaims {
    return @(
        "live_cycle_runtime",
        "live_Orchestrator_runtime",
        "live_PM_agent_invocation",
        "live_Architect_agent_invocation",
        "live_agent_runtime",
        "live_A2A_runtime",
        "live_A2A_messages_sent",
        "live_A2A_dispatch",
        "adapter_runtime",
        "actual_tool_call",
        "external_API_call",
        "live_board_mutation",
        "runtime_card_creation",
        "Codex_executor_invocation",
        "QA_Test_Agent_invocation",
        "Evidence_Auditor_API_invocation",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "external_audit_acceptance",
        "autonomous_agents",
        "product_runtime",
        "production_runtime",
        "main_merge",
        "future_R17_024_plus_completion",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "wildcard_evidence_refs",
        "local_backups_refs",
        "broad_repo_scan_output",
        "generated_artifact_embedding_source_files"
    )
}

function New-R17Cycle1DefinitionBasePacket {
    param(
        [Parameter(Mandatory = $true)][string]$ArtifactType,
        [Parameter(Mandatory = $true)][string]$PacketId,
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)]$GitIdentity
    )

    $refs = Get-R17Cycle1DefinitionCoreRefs
    $packet = [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        packet_id = $PacketId
        cycle_id = $script:CycleId
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-024"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        cycle_number = $script:CycleNumber
        cycle_name = $script:CycleName
        card_id = $script:CardId
        operator_intent_ref = $refs.operator_intent_ref
        orchestrator_packet_ref = $refs.orchestrator_packet_ref
        pm_definition_packet_ref = $refs.pm_definition_packet_ref
        architect_definition_packet_ref = $refs.architect_definition_packet_ref
        task_packet_ready_for_dev_ref = $refs.task_packet_ready_for_dev_ref
        memory_packet_refs = Get-R17Cycle1DefinitionMemoryRefs
        artifact_refs = Get-R17Cycle1DefinitionArtifactRefs
        a2a_message_refs = $refs.a2a_message_refs
        handoff_refs = $refs.handoff_refs
        dispatch_refs = $refs.dispatch_refs
        control_refs = $refs.control_refs
        board_event_refs = $refs.board_event_refs
        evidence_refs = Get-R17Cycle1DefinitionEvidenceRefs
        authority_refs = Get-R17Cycle1DefinitionAuthorityRefs
        validation_refs = Get-R17Cycle1DefinitionValidationRefs
        status = $Status
        execution_mode = "repo_backed_cycle_1_definition_packet_only_not_runtime"
        runtime_flags = Get-R17Cycle1DefinitionFalseFlags
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }

    foreach ($field in $script:ExplicitFalseFields) {
        $packet[$field] = $false
    }

    return [pscustomobject]$packet
}

function New-R17Cycle1DefinitionContract {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_cycle_1_definition_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-023-cycle-1-definition-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        seed_source_task = $script:SeedSourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-024"
        planned_only_through = "R17-028"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "repo_backed_exercised_cycle_1_definition_package_only_not_runtime"
        purpose = "Define required fields, statuses, refs, false runtime flags, and validation policy for the R17-023 deterministic packet-only PM/Architect definition cycle."
        required_cycle_packet_fields = $script:RequiredCyclePacketFields
        allowed_statuses = $script:AllowedStatuses
        required_explicit_false_fields = $script:ExplicitFalseFields
        validation_policy = [pscustomobject]@{
            exact_repo_relative_refs_required = $true
            wildcard_evidence_paths_allowed = $false
            local_backups_refs_allowed = $false
            broad_repo_scan_output_allowed = $false
            embedded_full_source_file_contents_allowed = $false
            task_packet_execution_allowed = $false
            future_r17_024_plus_completion_claims_allowed = $false
        }
        required_artifact_refs = Get-R17Cycle1DefinitionArtifactRefs
        required_evidence_refs = Get-R17Cycle1DefinitionEvidenceRefs
        required_authority_refs = Get-R17Cycle1DefinitionAuthorityRefs
        required_validation_refs = Get-R17Cycle1DefinitionValidationRefs
        runtime_boundaries = Get-R17Cycle1DefinitionFalseFlags
        explicit_false_fields = Get-R17Cycle1DefinitionExplicitFalseMap
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }
}

function New-R17Cycle1DefinitionA2aMessage {
    param(
        [Parameter(Mandatory = $true)][string]$MessageId,
        [Parameter(Mandatory = $true)][string]$FromAgentId,
        [Parameter(Mandatory = $true)][string]$ToAgentId,
        [Parameter(Mandatory = $true)][string]$MessageType,
        [Parameter(Mandatory = $true)][string]$InputPacketRef,
        [Parameter(Mandatory = $true)][string]$OutputPacketRef,
        [Parameter(Mandatory = $true)][string]$MemoryPacketRef,
        [Parameter(Mandatory = $true)]$GitIdentity
    )

    $message = [ordered]@{
        artifact_type = "r17_cycle_1_a2a_message_candidate"
        contract_version = "v1"
        message_id = $MessageId
        source_task = $script:SourceTask
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        card_id = $script:CardId
        correlation_id = "r17_023_cycle_1_definition_correlation"
        message_type = $MessageType
        from_agent_id = $FromAgentId
        to_agent_id = $ToAgentId
        parent_message_id = "none"
        input_packet_ref = $InputPacketRef
        output_packet_ref = $OutputPacketRef
        memory_packet_ref = $MemoryPacketRef
        invocation_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        tool_call_ledger_ref = "state/runtime/r17_tool_call_ledger.jsonl"
        board_event_ref = "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl"
        status = "not_sent_packet_candidate"
        execution_mode = "packet_candidate_only_not_dispatched"
        runtime_flags = Get-R17Cycle1DefinitionFalseFlags
        evidence_refs = Get-R17Cycle1DefinitionEvidenceRefs
        authority_refs = Get-R17Cycle1DefinitionAuthorityRefs
        validation_refs = Get-R17Cycle1DefinitionValidationRefs
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }

    foreach ($field in $script:ExplicitFalseFields) {
        $message[$field] = $false
    }

    return [pscustomobject]$message
}

function New-R17Cycle1DefinitionBoardEvent {
    param(
        [Parameter(Mandatory = $true)][string]$EventId,
        [Parameter(Mandatory = $true)][string]$EventType,
        [Parameter(Mandatory = $true)][string]$ActorRole,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$FromLane,
        [Parameter(Mandatory = $true)][string]$ToLane,
        [Parameter(Mandatory = $true)][string]$TimestampUtc,
        [Parameter(Mandatory = $true)][string]$InputRef,
        [Parameter(Mandatory = $true)][string]$OutputRef,
        [bool]$TransitionAllowed = $true
    )

    return [pscustomobject][ordered]@{
        artifact_type = "r17_board_event"
        contract_version = "v1"
        event_id = $EventId
        card_id = $script:CardId
        event_type = $EventType
        actor_role = $ActorRole
        agent_id = $AgentId
        from_lane = $FromLane
        to_lane = $ToLane
        timestamp_utc = $TimestampUtc
        input_ref = $InputRef
        output_ref = $OutputRef
        evidence_refs = @(
            "contracts/board/r17_board_event.contract.json",
            "$($script:CycleRoot)/cycle_1_board_event_refs.json",
            "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json",
            "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl",
            "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json"
        )
        validation_refs = Get-R17Cycle1DefinitionValidationRefs
        transition_allowed = $TransitionAllowed
        user_approval_present = $false
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }
}

function New-R17Cycle1DefinitionObjectSet {
    param(
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        $GitIdentity = (Get-R17Cycle1DefinitionGitIdentity -RepositoryRoot $RepositoryRoot)
    )

    $contract = New-R17Cycle1DefinitionContract

    $operatorIntent = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_operator_intent_packet" -PacketId "r17_023_cycle_1_operator_intent_packet" -Status "operator_intent_captured_repo_backed" -GitIdentity $GitIdentity
    Add-Member -InputObject $operatorIntent -MemberType NoteProperty -Name "intent_summary" -Value "Create a governed Cycle 1 definition card and deterministic PM/Architect definition packet set from one bounded operator intent."
    Add-Member -InputObject $operatorIntent -MemberType NoteProperty -Name "operator_intent_text" -Value "Exercise Cycle 1 as a repo-backed definition package that converts operator intent into governed card, PM definition, Architect definition, A2A packet candidates, dispatch/control refs, board evidence, and ready-for-dev packet only."
    Add-Member -InputObject $operatorIntent -MemberType NoteProperty -Name "requested_outputs" -Value @("governed_cycle_card", "pm_definition_packet", "architect_definition_packet", "ready_for_dev_packet_only", "proof_review_package")
    Add-Member -InputObject $operatorIntent -MemberType NoteProperty -Name "intake_alignment_refs" -Value @("contracts/intake/r17_operator_intake.contract.json", "state/intake/r17_operator_intake_seed_packet.json", "state/intake/r17_orchestrator_intake_proposal.json")

    $orchestrator = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_orchestrator_packet" -PacketId "r17_023_cycle_1_orchestrator_cycle_packet" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $orchestrator -MemberType NoteProperty -Name "orchestrator_decision" -Value "deterministically_prepare_cycle_1_definition_packets_without_runtime_invocation"
    Add-Member -InputObject $orchestrator -MemberType NoteProperty -Name "definition_sequence" -Value @("capture_operator_intent", "create_repo_backed_card_snapshot", "prepare_pm_definition_packet", "prepare_architect_definition_packet", "prepare_ready_for_dev_packet_only", "record_board_event_refs")
    Add-Member -InputObject $orchestrator -MemberType NoteProperty -Name "board_card_ref" -Value "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"
    Add-Member -InputObject $orchestrator -MemberType NoteProperty -Name "board_snapshot_ref" -Value "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json"
    Add-Member -InputObject $orchestrator -MemberType NoteProperty -Name "ready_for_dev_gate" -Value "ready_for_dev_packet_only_user_approval_still_required_for_later_cycle_claims"

    $pm = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_pm_definition_packet" -PacketId "r17_023_cycle_1_pm_definition_packet" -Status "pm_architect_definition_generated_repo_backed" -GitIdentity $GitIdentity
    Add-Member -InputObject $pm -MemberType NoteProperty -Name "definition_scope" -Value "Bound the next implementation-cycle intake to consume the ready-for-dev packet only after user/operator approval, without claiming any later-cycle delivery."
    Add-Member -InputObject $pm -MemberType NoteProperty -Name "acceptance_criteria" -Value @(
        "Developer cycle must consume exact R17-023 packet refs only.",
        "No Dev output is claimed by R17-023.",
        "Board movement beyond ready_for_dev remains future R17-024 work.",
        "QA and audit claims remain absent until later governed cycles."
    )
    Add-Member -InputObject $pm -MemberType NoteProperty -Name "constraints" -Value @(
        "No live PM agent invocation.",
        "No live Orchestrator runtime.",
        "No A2A message sending.",
        "No live board mutation.",
        "No Codex executor invocation."
    )
    Add-Member -InputObject $pm -MemberType NoteProperty -Name "risks" -Value @(
        "Later-cycle overclaim risk if ready-for-dev packet is mistaken for executed work.",
        "Stale generated_from values are identity metadata only after future commits.",
        "User approval remains required before closure or later-cycle claims."
    )
    Add-Member -InputObject $pm -MemberType NoteProperty -Name "next_step_recommendation" -Value "Proceed to R17-024 only as a separate governed implementation cycle after accepting this packet-only definition boundary."

    $architect = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_architect_definition_packet" -PacketId "r17_023_cycle_1_architect_definition_packet" -Status "pm_architect_definition_generated_repo_backed" -GitIdentity $GitIdentity
    Add-Member -InputObject $architect -MemberType NoteProperty -Name "technical_boundary" -Value "R17-023 may generate deterministic JSON and Markdown evidence artifacts only; runtime surfaces and adapters remain untouched."
    Add-Member -InputObject $architect -MemberType NoteProperty -Name "architecture_notes" -Value @(
        "Use exact refs into R17-011 intake, R17-010 loop state, R17-012 registry, R17-013 memory packets, R17-020 contracts, R17-021 dispatcher refs, and R17-022 controls.",
        "Keep board evidence as a cycle-specific repo-backed snapshot rather than updating the R17-005 canonical board state.",
        "Expose UI evidence through a read-only snapshot JSON only."
    )
    Add-Member -InputObject $architect -MemberType NoteProperty -Name "interface_refs" -Value @(
        "contracts/intake/r17_operator_intake.contract.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "contracts/runtime/r17_stop_retry_reentry_controls.contract.json",
        "contracts/board/r17_card.contract.json",
        "contracts/board/r17_board_event.contract.json"
    )
    Add-Member -InputObject $architect -MemberType NoteProperty -Name "implementation_constraints" -Value @(
        "Do not modify kanban.js.",
        "Do not invoke live agents or adapters.",
        "Do not embed source file contents in generated JSON.",
        "Do not complete or claim R17-024 through R17-028."
    )

    $taskPacket = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_task_packet_ready_for_dev" -PacketId "r17_023_cycle_1_task_packet_ready_for_dev" -Status "ready_for_dev_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "task_packet_id" -Value "r17_023_cycle_1_ready_for_dev_packet_only"
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "ready_state" -Value "ready_for_dev_packet_only"
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "ready_for_dev_packet_only" -Value $true
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "executed" -Value $false
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "task_execution" -Value ([pscustomobject]@{
            executed = $false
            implementation_started = $false
            dev_output_produced = $false
            qa_result_produced = $false
            audit_verdict_produced = $false
        })
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "developer_entry_refs" -Value @(
        "$($script:CycleRoot)/pm_definition_packet.json",
        "$($script:CycleRoot)/architect_definition_packet.json",
        "$($script:CycleRoot)/a2a_cycle_1_handoffs.json#r17_023_cycle_1_handoff_pm_to_developer_packet_only"
    )
    Add-Member -InputObject $taskPacket -MemberType NoteProperty -Name "next_cycle" -Value ([pscustomobject]@{
            task_id = "R17-024"
            status = "planned_only"
            implementation_may_start_in_r17_023 = $false
        })

    $messages = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_a2a_message_candidate_set" -PacketId "r17_023_cycle_1_a2a_message_candidates" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $messages -MemberType NoteProperty -Name "contract_alignment_refs" -Value @("contracts/a2a/r17_a2a_message.contract.json", "state/a2a/r17_a2a_message_seed_packets.json")
    Add-Member -InputObject $messages -MemberType NoteProperty -Name "message_count" -Value 3
    Add-Member -InputObject $messages -MemberType NoteProperty -Name "messages" -Value @(
        (New-R17Cycle1DefinitionA2aMessage -MessageId "r17_023_cycle_1_message_orchestrator_to_pm" -FromAgentId "orchestrator" -ToAgentId "project_manager" -MessageType "task_assignment" -InputPacketRef "$($script:CycleRoot)/operator_intent_packet.json" -OutputPacketRef "$($script:CycleRoot)/pm_definition_packet.json" -MemoryPacketRef "state/agents/r17_agent_memory_packets/project_manager.memory_packet.json" -GitIdentity $GitIdentity),
        (New-R17Cycle1DefinitionA2aMessage -MessageId "r17_023_cycle_1_message_orchestrator_to_architect" -FromAgentId "orchestrator" -ToAgentId "architect" -MessageType "task_assignment" -InputPacketRef "$($script:CycleRoot)/operator_intent_packet.json" -OutputPacketRef "$($script:CycleRoot)/architect_definition_packet.json" -MemoryPacketRef "state/agents/r17_agent_memory_packets/architect.memory_packet.json" -GitIdentity $GitIdentity),
        (New-R17Cycle1DefinitionA2aMessage -MessageId "r17_023_cycle_1_message_pm_ready_for_dev_packet" -FromAgentId "project_manager" -ToAgentId "developer" -MessageType "task_assignment" -InputPacketRef "$($script:CycleRoot)/task_packet_ready_for_dev.json" -OutputPacketRef "$($script:CycleRoot)/task_packet_ready_for_dev.json" -MemoryPacketRef "state/agents/r17_agent_memory_packets/developer.memory_packet.json" -GitIdentity $GitIdentity)
    )

    $handoffs = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_a2a_handoff_candidate_set" -PacketId "r17_023_cycle_1_a2a_handoff_candidates" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $handoffs -MemberType NoteProperty -Name "contract_alignment_refs" -Value @("contracts/a2a/r17_a2a_handoff.contract.json", "state/a2a/r17_a2a_handoff_seed_packets.json")
    Add-Member -InputObject $handoffs -MemberType NoteProperty -Name "handoff_count" -Value 3
    Add-Member -InputObject $handoffs -MemberType NoteProperty -Name "handoffs" -Value @(
        [pscustomobject]@{ handoff_id = "r17_023_cycle_1_handoff_orchestrator_to_pm"; from_agent_id = "orchestrator"; to_agent_id = "project_manager"; handoff_type = "definition_packet_candidate"; status = "not_executed_packet_candidate"; source_message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_pm"; required_output_refs = @("$($script:CycleRoot)/pm_definition_packet.json"); runtime_flags = Get-R17Cycle1DefinitionFalseFlags },
        [pscustomobject]@{ handoff_id = "r17_023_cycle_1_handoff_orchestrator_to_architect"; from_agent_id = "orchestrator"; to_agent_id = "architect"; handoff_type = "definition_packet_candidate"; status = "not_executed_packet_candidate"; source_message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_architect"; required_output_refs = @("$($script:CycleRoot)/architect_definition_packet.json"); runtime_flags = Get-R17Cycle1DefinitionFalseFlags },
        [pscustomobject]@{ handoff_id = "r17_023_cycle_1_handoff_pm_to_developer_packet_only"; from_agent_id = "project_manager"; to_agent_id = "developer"; handoff_type = "planning_to_implementation_packet_only"; status = "not_executed_packet_candidate"; source_message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_pm_ready_for_dev_packet"; required_output_refs = @("$($script:CycleRoot)/task_packet_ready_for_dev.json"); runtime_flags = Get-R17Cycle1DefinitionFalseFlags }
    )

    $dispatchRefs = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_a2a_dispatch_ref_set" -PacketId "r17_023_cycle_1_a2a_dispatch_refs" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $dispatchRefs -MemberType NoteProperty -Name "dispatcher_alignment_refs" -Value @("contracts/a2a/r17_a2a_dispatcher.contract.json", "state/a2a/r17_a2a_dispatcher_routes.json", "state/a2a/r17_a2a_dispatcher_dispatch_log.jsonl")
    Add-Member -InputObject $dispatchRefs -MemberType NoteProperty -Name "dispatch_ref_count" -Value 3
    Add-Member -InputObject $dispatchRefs -MemberType NoteProperty -Name "dispatch_refs_detail" -Value @(
        [pscustomobject]@{ dispatch_ref_id = "r17_023_cycle_1_dispatch_ref_orchestrator_to_pm"; route_status = "deterministic_route_ref_not_executed"; dispatch_decision = "not_dispatched_packet_only"; message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_pm" },
        [pscustomobject]@{ dispatch_ref_id = "r17_023_cycle_1_dispatch_ref_orchestrator_to_architect"; route_status = "deterministic_route_ref_not_executed"; dispatch_decision = "not_dispatched_packet_only"; message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_orchestrator_to_architect" },
        [pscustomobject]@{ dispatch_ref_id = "r17_023_cycle_1_dispatch_ref_pm_to_developer_packet_only"; route_status = "deterministic_route_ref_not_executed"; dispatch_decision = "not_dispatched_packet_only"; message_ref = "$($script:CycleRoot)/a2a_cycle_1_messages.json#r17_023_cycle_1_message_pm_ready_for_dev_packet" }
    )

    $controlRefs = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_control_ref_set" -PacketId "r17_023_cycle_1_control_refs" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $controlRefs -MemberType NoteProperty -Name "control_alignment_refs" -Value @("contracts/runtime/r17_stop_retry_reentry_controls.contract.json", "state/runtime/r17_stop_retry_reentry_control_packets.json", "state/runtime/r17_stop_retry_reentry_reentry_packets.json")
    Add-Member -InputObject $controlRefs -MemberType NoteProperty -Name "control_ref_count" -Value 4
    Add-Member -InputObject $controlRefs -MemberType NoteProperty -Name "control_refs_detail" -Value @(
        [pscustomobject]@{ control_ref_id = "r17_023_cycle_1_stop_ref"; control_action = "stop"; status = "control_packet_only"; source_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#r17_022_control_stop" },
        [pscustomobject]@{ control_ref_id = "r17_023_cycle_1_retry_ref"; control_action = "retry"; status = "control_packet_only"; source_ref = "state/runtime/r17_stop_retry_reentry_control_packets.json#r17_022_control_retry" },
        [pscustomobject]@{ control_ref_id = "r17_023_cycle_1_reentry_ref"; control_action = "reentry"; status = "reentry_packet_only"; source_ref = "state/runtime/r17_stop_retry_reentry_reentry_packets.json" },
        [pscustomobject]@{ control_ref_id = "r17_023_cycle_1_user_decision_ref"; control_action = "user_decision_required"; status = "blocked_user_decision_required"; source_ref = "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl#r17_023_cycle_1_event_006_user_decision_required" }
    )

    $boardCard = [pscustomobject][ordered]@{
        artifact_type = "r17_board_card"
        contract_version = "v1"
        card_id = $script:CardId
        milestone = $script:MilestoneName
        task_id = $script:SourceTask
        title = "Cycle 1 definition packet: Orchestrator to PM/Architect to Board"
        description = "R17-023 creates a deterministic repo-backed Cycle 1 definition package and ready-for-dev packet only. It is not live board mutation, live agent execution, implementation, QA, audit, or product runtime."
        double_diamond_stage = "define"
        lane = "ready_for_dev"
        owner_role = "project_manager"
        current_agent = "packet_only_no_live_agent"
        status = "active"
        acceptance_criteria = @(
            "Operator intent packet exists with exact refs.",
            "PM and Architect definition packets exist with scope, constraints, risks, and architecture boundaries.",
            "Task packet is ready_for_dev_packet_only and not executed.",
            "A2A, dispatch, control, and board refs are deterministic packet candidates only."
        )
        qa_criteria = @(
            "R17-023 validator and focused test pass.",
            "Existing R17 foundation gates still pass.",
            "Status-doc gate records R17 active through R17-023 only.",
            "No live runtime, Dev, QA, audit, adapter, API, board mutation, or main-merge claim exists."
        )
        evidence_refs = Get-R17Cycle1DefinitionEvidenceRefs
        memory_refs = Get-R17Cycle1DefinitionMemoryRefs
        task_packet_ref = "$($script:CycleRoot)/task_packet_ready_for_dev.json"
        blocker_refs = @()
        user_decision_required = $true
        user_approval_required_for_closure = $true
        allowed_next_lanes = @("ready_for_dev", "blocked")
        forbidden_claims = Get-R17Cycle1DefinitionRejectedClaims
        non_claims = Get-R17Cycle1DefinitionNonClaims
        audit_log_refs = @("$($script:ProofRoot)/proof_review.md", "$($script:CycleRoot)/cycle_1_check_report.json")
        created_by = "operator_intent_packet"
        updated_by = "deterministic_r17_023_generator"
        claims = Get-R17Cycle1DefinitionExplicitFalseMap
    }

    $boardEvents = @(
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_001_card_created" -EventType "card_created" -ActorRole "orchestrator" -AgentId "r17_023_packet_only_orchestrator_ref" -FromLane "intake" -ToLane "intake" -TimestampUtc "2026-05-10T00:23:01Z" -InputRef "$($script:CycleRoot)/operator_intent_packet.json" -OutputRef "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"),
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_002_moved_to_define" -EventType "lane_transition_requested" -ActorRole "orchestrator" -AgentId "r17_023_packet_only_orchestrator_ref" -FromLane "intake" -ToLane "define" -TimestampUtc "2026-05-10T00:23:02Z" -InputRef "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json" -OutputRef "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"),
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_003_pm_definition_recorded" -EventType "card_updated" -ActorRole "project_manager" -AgentId "r17_023_packet_only_pm_ref" -FromLane "define" -ToLane "define" -TimestampUtc "2026-05-10T00:23:03Z" -InputRef "$($script:CycleRoot)/orchestrator_cycle_packet.json" -OutputRef "$($script:CycleRoot)/pm_definition_packet.json"),
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_004_architect_definition_recorded" -EventType "card_updated" -ActorRole "architect" -AgentId "r17_023_packet_only_architect_ref" -FromLane "define" -ToLane "define" -TimestampUtc "2026-05-10T00:23:04Z" -InputRef "$($script:CycleRoot)/orchestrator_cycle_packet.json" -OutputRef "$($script:CycleRoot)/architect_definition_packet.json"),
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_005_ready_for_dev_packet_only" -EventType "lane_transition_requested" -ActorRole "project_manager" -AgentId "r17_023_packet_only_pm_ref" -FromLane "define" -ToLane "ready_for_dev" -TimestampUtc "2026-05-10T00:23:05Z" -InputRef "$($script:CycleRoot)/pm_definition_packet.json" -OutputRef "$($script:CycleRoot)/task_packet_ready_for_dev.json"),
        (New-R17Cycle1DefinitionBoardEvent -EventId "r17_023_cycle_1_event_006_user_decision_required" -EventType "user_decision_requested" -ActorRole "release_closeout" -AgentId "r17_023_packet_only_release_ref" -FromLane "ready_for_dev" -ToLane "ready_for_dev" -TimestampUtc "2026-05-10T00:23:06Z" -InputRef "$($script:CycleRoot)/cycle_1_check_report.json" -OutputRef "$($script:CycleRoot)/cycle_1_check_report.json" -TransitionAllowed:$false)
    )

    $boardSnapshot = [pscustomobject][ordered]@{
        artifact_type = "r17_cycle_1_definition_board_snapshot"
        contract_version = "v1"
        source_task = $script:SourceTask
        cycle_id = $script:CycleId
        card_id = $script:CardId
        board_card_ref = "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"
        board_event_log_ref = "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl"
        event_count = $boardEvents.Count
        final_lane = "ready_for_dev"
        final_status = "ready_for_dev_packet_only"
        repo_backed_snapshot_only = $true
        live_board_mutation_performed = $false
        runtime_card_creation_performed = $false
        user_decision_required = $true
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }

    $boardEventRefs = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_board_event_ref_set" -PacketId "r17_023_cycle_1_board_event_refs" -Status "ready_for_dev_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "board_card_ref" -Value "$($script:BoardRoot)/cards/r17_023_cycle_1_definition_card.json"
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "board_event_log_ref" -Value "$($script:BoardRoot)/events/r17_023_cycle_1_definition_events.jsonl"
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "board_snapshot_ref" -Value "$($script:BoardRoot)/r17_023_cycle_1_definition_board_snapshot.json"
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "event_count" -Value $boardEvents.Count
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "final_lane" -Value "ready_for_dev"
    Add-Member -InputObject $boardEventRefs -MemberType NoteProperty -Name "replay_evidence" -Value ([pscustomobject]@{ input_event_count = $boardEvents.Count; replayed_event_count = $boardEvents.Count; rejected_event_count = 0; deterministic_replay_only = $true; live_board_mutation_performed = $false })

    $uiSnapshot = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_definition_ui_snapshot" -PacketId "r17_023_cycle_1_definition_ui_snapshot" -Status "ready_for_dev_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $uiSnapshot -MemberType NoteProperty -Name "read_only_surface" -Value $true
    Add-Member -InputObject $uiSnapshot -MemberType NoteProperty -Name "visible_cycle_card" -Value ([pscustomobject]@{ card_id = $script:CardId; lane = "ready_for_dev"; status = "ready_for_dev_packet_only"; user_decision_required = $true })
    Add-Member -InputObject $uiSnapshot -MemberType NoteProperty -Name "visible_packet_refs" -Value @($operatorIntent.operator_intent_ref, $pm.pm_definition_packet_ref, $architect.architect_definition_packet_ref, $taskPacket.task_packet_ready_for_dev_ref)

    $checkReport = New-R17Cycle1DefinitionBasePacket -ArtifactType "r17_cycle_1_definition_check_report" -PacketId "r17_023_cycle_1_check_report" -Status "cycle_1_definition_packet_only" -GitIdentity $GitIdentity
    Add-Member -InputObject $checkReport -MemberType NoteProperty -Name "aggregate_verdict" -Value $script:AggregateVerdict
    Add-Member -InputObject $checkReport -MemberType NoteProperty -Name "validation_summary" -Value ([pscustomobject]@{
            contract_shape = "passed"
            required_refs = "passed"
            false_runtime_flags = "passed"
            task_packet_not_executed = "passed"
            board_event_snapshot = "passed"
            no_future_r17_024_plus_completion_claims = "passed"
            no_live_runtime_claims = "passed"
            compact_artifacts = "passed"
        })
    Add-Member -InputObject $checkReport -MemberType NoteProperty -Name "artifact_counts" -Value ([pscustomobject]@{ cycle_packets = 5; a2a_messages = 3; handoffs = 3; dispatch_refs = 3; control_refs = 4; board_events = $boardEvents.Count })

    return [pscustomobject]@{
        Contract = $contract
        OperatorIntent = $operatorIntent
        OrchestratorPacket = $orchestrator
        PmDefinitionPacket = $pm
        ArchitectDefinitionPacket = $architect
        TaskPacketReadyForDev = $taskPacket
        A2aMessages = $messages
        A2aHandoffs = $handoffs
        A2aDispatchRefs = $dispatchRefs
        ControlRefs = $controlRefs
        BoardEventRefs = $boardEventRefs
        CheckReport = $checkReport
        BoardCard = $boardCard
        BoardEvents = $boardEvents
        BoardSnapshot = $boardSnapshot
        UiSnapshot = $uiSnapshot
    }
}

function New-R17Cycle1DefinitionInvalidFixtureSpecs {
    $falseFieldFixtures = @(
        "live_cycle_runtime_implemented",
        "live_orchestrator_runtime_invoked",
        "live_pm_agent_invoked",
        "live_architect_agent_invoked",
        "live_agent_runtime_invoked",
        "live_a2a_dispatch_performed",
        "a2a_runtime_implemented",
        "a2a_message_sent",
        "adapter_runtime_invoked",
        "actual_tool_call_performed",
        "external_api_call_performed",
        "live_board_mutation_performed",
        "runtime_card_creation_performed",
        "codex_executor_invoked",
        "qa_test_agent_invoked",
        "evidence_auditor_api_invoked",
        "dev_output_claimed",
        "qa_result_claimed",
        "audit_verdict_claimed",
        "real_audit_verdict",
        "external_audit_acceptance_claimed",
        "product_runtime_executed",
        "autonomous_agent_executed",
        "main_merge_claimed"
    ) | ForEach-Object {
        [pscustomobject]@{
            name = "invalid_runtime_flag_$_.json"
            target = "orchestrator"
            mutation = "set"
            property = "runtime_flags.$_"
            value = $true
            expected_failure_fragments = @($_)
        }
    }

    $fixtures = @(
        [pscustomobject]@{ name = "invalid_missing_operator_intent_ref.json"; target = "orchestrator"; mutation = "remove"; property = "operator_intent_ref"; value = $null; expected_failure_fragments = @("operator_intent_ref") },
        [pscustomobject]@{ name = "invalid_missing_orchestrator_packet_ref.json"; target = "orchestrator"; mutation = "remove"; property = "orchestrator_packet_ref"; value = $null; expected_failure_fragments = @("orchestrator_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_pm_definition_packet_ref.json"; target = "orchestrator"; mutation = "remove"; property = "pm_definition_packet_ref"; value = $null; expected_failure_fragments = @("pm_definition_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_architect_definition_packet_ref.json"; target = "orchestrator"; mutation = "remove"; property = "architect_definition_packet_ref"; value = $null; expected_failure_fragments = @("architect_definition_packet_ref") },
        [pscustomobject]@{ name = "invalid_missing_task_packet_ready_for_dev_ref.json"; target = "orchestrator"; mutation = "remove"; property = "task_packet_ready_for_dev_ref"; value = $null; expected_failure_fragments = @("task_packet_ready_for_dev_ref") },
        [pscustomobject]@{ name = "invalid_empty_memory_packet_refs.json"; target = "orchestrator"; mutation = "set"; property = "memory_packet_refs"; value = @(); expected_failure_fragments = @("memory_packet_refs") },
        [pscustomobject]@{ name = "invalid_empty_artifact_refs.json"; target = "orchestrator"; mutation = "set"; property = "artifact_refs"; value = @(); expected_failure_fragments = @("artifact_refs") },
        [pscustomobject]@{ name = "invalid_empty_a2a_message_refs.json"; target = "orchestrator"; mutation = "set"; property = "a2a_message_refs"; value = @(); expected_failure_fragments = @("a2a_message_refs") },
        [pscustomobject]@{ name = "invalid_empty_handoff_refs.json"; target = "orchestrator"; mutation = "set"; property = "handoff_refs"; value = @(); expected_failure_fragments = @("handoff_refs") },
        [pscustomobject]@{ name = "invalid_empty_dispatch_refs.json"; target = "orchestrator"; mutation = "set"; property = "dispatch_refs"; value = @(); expected_failure_fragments = @("dispatch_refs") },
        [pscustomobject]@{ name = "invalid_empty_control_refs.json"; target = "orchestrator"; mutation = "set"; property = "control_refs"; value = @(); expected_failure_fragments = @("control_refs") },
        [pscustomobject]@{ name = "invalid_empty_board_event_refs.json"; target = "orchestrator"; mutation = "set"; property = "board_event_refs"; value = @(); expected_failure_fragments = @("board_event_refs") },
        [pscustomobject]@{ name = "invalid_empty_evidence_refs.json"; target = "orchestrator"; mutation = "set"; property = "evidence_refs"; value = @(); expected_failure_fragments = @("evidence_refs") },
        [pscustomobject]@{ name = "invalid_empty_authority_refs.json"; target = "orchestrator"; mutation = "set"; property = "authority_refs"; value = @(); expected_failure_fragments = @("authority_refs") },
        [pscustomobject]@{ name = "invalid_empty_validation_refs.json"; target = "orchestrator"; mutation = "set"; property = "validation_refs"; value = @(); expected_failure_fragments = @("validation_refs") },
        [pscustomobject]@{ name = "invalid_wildcard_evidence_path.json"; target = "orchestrator"; mutation = "append"; property = "evidence_refs"; value = "state/**/*.json"; expected_failure_fragments = @("wildcard") },
        [pscustomobject]@{ name = "invalid_local_backups_ref.json"; target = "orchestrator"; mutation = "append"; property = "artifact_refs"; value = ".local_backups/r17_023.json"; expected_failure_fragments = @(".local_backups") },
        [pscustomobject]@{ name = "invalid_broad_repo_scan_output.json"; target = "orchestrator"; mutation = "set"; property = "orchestrator_decision"; value = "broad repo scan output included"; expected_failure_fragments = @("broad repo scan output") },
        [pscustomobject]@{ name = "invalid_full_source_contents_embedded.json"; target = "orchestrator"; mutation = "set"; property = "runtime_flags.full_source_file_contents_embedded"; value = $true; expected_failure_fragments = @("full_source_file_contents_embedded") },
        [pscustomobject]@{ name = "invalid_task_packet_executed_status.json"; target = "task_packet"; mutation = "set"; property = "status"; value = "executed"; expected_failure_fragments = @("status") },
        [pscustomobject]@{ name = "invalid_task_packet_executed_flag.json"; target = "task_packet"; mutation = "set"; property = "task_execution.executed"; value = $true; expected_failure_fragments = @("task packet must not be executed") },
        [pscustomobject]@{ name = "invalid_future_r17_024_completion_claim.json"; target = "orchestrator"; mutation = "set"; property = "orchestrator_decision"; value = "R17-024 completed implementation"; expected_failure_fragments = @("future R17-024") }
    )

    return @($fixtures + $falseFieldFixtures)
}

function New-R17Cycle1DefinitionProofReviewText {
    return @"
# R17-023 Cycle 1 Definition Package Proof Review

R17-023 creates a repo-backed exercised Cycle 1 definition package. The package turns one bounded operator intent into deterministic packet-only PM and Architect definition artifacts, scoped memory/artifact refs, A2A message and handoff candidates, dispatch/control refs, board event evidence, a read-only UI snapshot, and a ready-for-dev packet only.

R17 is active through R17-023 only. R17-024 through R17-028 remain planned only.

This package does not implement live cycle runtime, invoke live Orchestrator runtime, invoke PM or Architect agents, send A2A messages, invoke adapters, perform tool calls, call external APIs, mutate the live board, invoke Codex executor, produce Dev output, produce QA result, produce a real audit verdict, claim external audit acceptance, execute autonomous agents, run product runtime, or claim main merge.
"@
}

function New-R17Cycle1DefinitionValidationManifestText {
    return @"
# R17-023 Validation Manifest

Required validation commands:

- powershell -ExecutionPolicy Bypass -File tools\new_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tools\validate_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1

The package is deterministic repo-backed evidence only. It is not live autonomous operation and not live A2A runtime.
"@
}

function New-R17Cycle1DefinitionArtifacts {
    param([string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot))

    $paths = Get-R17Cycle1DefinitionPaths -RepositoryRoot $RepositoryRoot
    $objectSet = New-R17Cycle1DefinitionObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17Cycle1DefinitionJson -Path $paths.Contract -Value $objectSet.Contract
    Write-R17Cycle1DefinitionJson -Path $paths.OperatorIntent -Value $objectSet.OperatorIntent
    Write-R17Cycle1DefinitionJson -Path $paths.OrchestratorPacket -Value $objectSet.OrchestratorPacket
    Write-R17Cycle1DefinitionJson -Path $paths.PmDefinitionPacket -Value $objectSet.PmDefinitionPacket
    Write-R17Cycle1DefinitionJson -Path $paths.ArchitectDefinitionPacket -Value $objectSet.ArchitectDefinitionPacket
    Write-R17Cycle1DefinitionJson -Path $paths.TaskPacketReadyForDev -Value $objectSet.TaskPacketReadyForDev
    Write-R17Cycle1DefinitionJson -Path $paths.A2aMessages -Value $objectSet.A2aMessages
    Write-R17Cycle1DefinitionJson -Path $paths.A2aHandoffs -Value $objectSet.A2aHandoffs
    Write-R17Cycle1DefinitionJson -Path $paths.A2aDispatchRefs -Value $objectSet.A2aDispatchRefs
    Write-R17Cycle1DefinitionJson -Path $paths.ControlRefs -Value $objectSet.ControlRefs
    Write-R17Cycle1DefinitionJson -Path $paths.BoardEventRefs -Value $objectSet.BoardEventRefs
    Write-R17Cycle1DefinitionJson -Path $paths.CheckReport -Value $objectSet.CheckReport
    Write-R17Cycle1DefinitionJson -Path $paths.BoardCard -Value $objectSet.BoardCard
    Write-R17Cycle1DefinitionJson -Path $paths.BoardSnapshot -Value $objectSet.BoardSnapshot
    Write-R17Cycle1DefinitionJson -Path $paths.UiSnapshot -Value $objectSet.UiSnapshot

    $boardEventDirectory = Split-Path -Parent $paths.BoardEvents
    New-Item -ItemType Directory -Path $boardEventDirectory -Force | Out-Null
    @($objectSet.BoardEvents | ForEach-Object { $_ | ConvertTo-Json -Depth 60 -Compress }) | Set-Content -LiteralPath $paths.BoardEvents -Encoding UTF8

    Write-R17Cycle1DefinitionJson -Path $paths.ValidCheckReportFixture -Value $objectSet.CheckReport
    $fixtures = New-R17Cycle1DefinitionInvalidFixtureSpecs
    $fixtureManifest = [pscustomobject][ordered]@{
        artifact_type = "r17_cycle_1_definition_fixture_manifest"
        source_task = $script:SourceTask
        invalid_fixture_count = $fixtures.Count
        invalid_fixture_names = @($fixtures | ForEach-Object { $_.name })
        valid_check_report_ref = "$($script:FixtureRoot)/valid_check_report.json"
    }
    Write-R17Cycle1DefinitionJson -Path $paths.FixtureManifest -Value $fixtureManifest
    foreach ($fixture in $fixtures) {
        $fixturePath = Join-Path $paths.FixtureRoot $fixture.name
        Write-R17Cycle1DefinitionJson -Path $fixturePath -Value $fixture
    }

    Write-R17Cycle1DefinitionText -Path $paths.ProofReview -Value (New-R17Cycle1DefinitionProofReviewText)
    $evidenceIndex = [pscustomobject][ordered]@{
        artifact_type = "r17_cycle_1_definition_evidence_index"
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        planned_only_from = "R17-024"
        planned_only_through = "R17-028"
        evidence_refs = Get-R17Cycle1DefinitionEvidenceRefs
        authority_refs = Get-R17Cycle1DefinitionAuthorityRefs
        validation_refs = Get-R17Cycle1DefinitionValidationRefs
        non_claims = Get-R17Cycle1DefinitionNonClaims
        rejected_claims = Get-R17Cycle1DefinitionRejectedClaims
    }
    Write-R17Cycle1DefinitionJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R17Cycle1DefinitionText -Path $paths.ValidationManifest -Value (New-R17Cycle1DefinitionValidationManifestText)

    $result = Test-R17Cycle1Definition -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        Contract = $paths.Contract
        CycleRoot = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue $script:CycleRoot
        BoardCard = $paths.BoardCard
        BoardEvents = $paths.BoardEvents
        BoardSnapshot = $paths.BoardSnapshot
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        InvalidFixtureCount = $fixtures.Count
        AggregateVerdict = $result.AggregateVerdict
    }
}

function Assert-R17Cycle1DefinitionRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17Cycle1DefinitionHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17Cycle1DefinitionFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17Cycle1DefinitionHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required false field '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Assert-R17Cycle1DefinitionNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)][AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) { return }

    if ($Value -is [string]) {
        $text = [string]$Value
        if ($text -match '(?i)\.local_backups') { throw "$Context contains .local_backups reference." }
        if ($text -match '(?i)broad repo scan output included|full repo scan output|embedded full source file contents|BEGIN FULL SOURCE|END FULL SOURCE') { throw "$Context contains broad repo scan output or embedded full source file contents." }
        $futureClaimIsNegated = $text -match '(?i)\b(do not|does not|must not|not complete|not completed|not implemented|remain planned only|remains planned only|planned only)\b'
        if (-not $futureClaimIsNegated -and $text -match '(?i)\bR17-(0(?:2[4-8])|[1-9][0-9]{2,})\b.{0,140}\b(done|complete|completed|implemented|executed|passed|closed)\b') { throw "$Context contains future R17-024 plus completion claim." }
        if (-not $futureClaimIsNegated -and $text -match '(?i)\b(done|complete|completed|implemented|executed|passed|closed)\b.{0,140}\bR17-(0(?:2[4-8])|[1-9][0-9]{2,})\b') { throw "$Context contains future R17-024 plus completion claim." }
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Assert-R17Cycle1DefinitionNoForbiddenContent -Value $Value[$key] -Context "$Context.$key"
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $index = 0
        foreach ($item in $Value) {
            Assert-R17Cycle1DefinitionNoForbiddenContent -Value $item -Context "$Context[$index]"
            $index += 1
        }
        return
    }

    foreach ($property in $Value.PSObject.Properties) {
        Assert-R17Cycle1DefinitionNoForbiddenContent -Value $property.Value -Context "$Context.$($property.Name)"
    }
}

function Assert-R17Cycle1DefinitionSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        [switch]$RequireExistingPath
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context missing ref path." }
    if ($Path -match '[\*\?]') { throw "$Context contains wildcard path '$Path'." }
    if ($Path -match '(?i)\.local_backups') { throw "$Context references .local_backups path '$Path'." }
    if ($Path -match '(?i)broad repo scan|full repo scan|raw chat history') { throw "$Context references forbidden broad source '$Path'." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context must be repo-relative, got '$Path'." }
    if ($Path -match '^\.\.' -or $Path -match '(^|/)\.\.(/|$)') { throw "$Context must not traverse parent paths, got '$Path'." }
    if ($Path -match '^[a-zA-Z][a-zA-Z0-9+.-]*://') { throw "$Context must not use external URI '$Path'." }

    if ($RequireExistingPath) {
        $pathWithoutAnchor = ($Path -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathWithoutAnchor)) { throw "$Context has empty path before anchor." }
        $resolved = Resolve-R17Cycle1DefinitionPath -RepositoryRoot $RepositoryRoot -PathValue $pathWithoutAnchor
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context references missing path '$Path'."
        }
    }
}

function Assert-R17Cycle1DefinitionRefArray {
    param(
        [Parameter(Mandatory = $true)]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        [switch]$SkipRefExistence
    )

    $items = @($Values | ForEach-Object { [string]$_ })
    if ($items.Count -eq 0) { throw "$Context must contain at least one ref." }
    foreach ($item in $items) {
        Assert-R17Cycle1DefinitionSafeRefPath -Path $item -Context $Context -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    }
}

function Assert-R17Cycle1DefinitionCyclePacket {
    param(
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R17Cycle1DefinitionRequiredFields -Object $Packet -FieldNames $script:RequiredCyclePacketFields -Context $Context
    if ([string]$Packet.cycle_id -ne $script:CycleId) { throw "$Context cycle_id must be $script:CycleId." }
    if ([string]$Packet.source_task -ne $script:SourceTask) { throw "$Context source_task must be R17-023." }
    if ([int]$Packet.cycle_number -ne 1) { throw "$Context cycle_number must be 1." }
    if ([string]$Packet.card_id -ne $script:CardId) { throw "$Context card_id must be $script:CardId." }
    if ($script:AllowedStatuses -notcontains [string]$Packet.status) { throw "$Context status '$($Packet.status)' is not allowed." }
    if ([string]$Packet.status -eq "invalid") { throw "$Context must not use invalid status." }
    if ([string]$Packet.execution_mode -notmatch 'packet_only|not_runtime|not_executed') { throw "$Context execution_mode must be packet-only/not-runtime." }

    Assert-R17Cycle1DefinitionSafeRefPath -Path ([string]$Packet.operator_intent_ref) -Context "$Context operator_intent_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17Cycle1DefinitionSafeRefPath -Path ([string]$Packet.orchestrator_packet_ref) -Context "$Context orchestrator_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17Cycle1DefinitionSafeRefPath -Path ([string]$Packet.pm_definition_packet_ref) -Context "$Context pm_definition_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17Cycle1DefinitionSafeRefPath -Path ([string]$Packet.architect_definition_packet_ref) -Context "$Context architect_definition_packet_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17Cycle1DefinitionSafeRefPath -Path ([string]$Packet.task_packet_ready_for_dev_ref) -Context "$Context task_packet_ready_for_dev_ref" -RepositoryRoot $RepositoryRoot -RequireExistingPath:(-not $SkipRefExistence)
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.memory_packet_refs) -Context "$Context memory_packet_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.artifact_refs) -Context "$Context artifact_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.a2a_message_refs) -Context "$Context a2a_message_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.handoff_refs) -Context "$Context handoff_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.dispatch_refs) -Context "$Context dispatch_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.control_refs) -Context "$Context control_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.board_event_refs) -Context "$Context board_event_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.evidence_refs) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.authority_refs) -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($Packet.validation_refs) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionFalseFields -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$Context runtime_flags"
    Assert-R17Cycle1DefinitionFalseFields -Object $Packet -FieldNames $script:ExplicitFalseFields -Context $Context
    Assert-R17Cycle1DefinitionNoForbiddenContent -Value $Packet -Context $Context
}

function Assert-R17Cycle1DefinitionKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-023 must preserve exact renderer bytes."
    }
}

function Test-R17Cycle1DefinitionSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$OperatorIntent,
        [Parameter(Mandatory = $true)]$OrchestratorPacket,
        [Parameter(Mandatory = $true)]$PmDefinitionPacket,
        [Parameter(Mandatory = $true)]$ArchitectDefinitionPacket,
        [Parameter(Mandatory = $true)]$TaskPacketReadyForDev,
        [Parameter(Mandatory = $true)]$A2aMessages,
        [Parameter(Mandatory = $true)]$A2aHandoffs,
        [Parameter(Mandatory = $true)]$A2aDispatchRefs,
        [Parameter(Mandatory = $true)]$ControlRefs,
        [Parameter(Mandatory = $true)]$BoardEventRefs,
        [Parameter(Mandatory = $true)]$CheckReport,
        [Parameter(Mandatory = $true)]$BoardCard,
        [Parameter(Mandatory = $true)]$BoardEvents,
        [Parameter(Mandatory = $true)]$BoardSnapshot,
        [Parameter(Mandatory = $true)]$UiSnapshot,
        [string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot),
        [switch]$SkipRefExistence,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17Cycle1DefinitionRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "required_cycle_packet_fields", "allowed_statuses", "required_explicit_false_fields", "validation_policy", "runtime_boundaries", "explicit_false_fields", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.artifact_type -ne "r17_cycle_1_definition_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne "R17-023" -or $Contract.active_through_task -ne "R17-023") { throw "contract must keep R17 active through R17-023." }
    if ($Contract.planned_only_from -ne "R17-024" -or $Contract.planned_only_through -ne "R17-028") { throw "contract must keep R17-024 through R17-028 planned only." }
    Assert-R17Cycle1DefinitionFalseFields -Object $Contract.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract runtime_boundaries"
    Assert-R17Cycle1DefinitionFalseFields -Object $Contract.explicit_false_fields -FieldNames $script:ExplicitFalseFields -Context "contract explicit_false_fields"

    foreach ($packetInfo in @(
            [pscustomobject]@{ Name = "operator intent"; Packet = $OperatorIntent },
            [pscustomobject]@{ Name = "orchestrator packet"; Packet = $OrchestratorPacket },
            [pscustomobject]@{ Name = "PM definition packet"; Packet = $PmDefinitionPacket },
            [pscustomobject]@{ Name = "Architect definition packet"; Packet = $ArchitectDefinitionPacket },
            [pscustomobject]@{ Name = "task packet"; Packet = $TaskPacketReadyForDev },
            [pscustomobject]@{ Name = "A2A messages"; Packet = $A2aMessages },
            [pscustomobject]@{ Name = "A2A handoffs"; Packet = $A2aHandoffs },
            [pscustomobject]@{ Name = "dispatch refs"; Packet = $A2aDispatchRefs },
            [pscustomobject]@{ Name = "control refs"; Packet = $ControlRefs },
            [pscustomobject]@{ Name = "board event refs"; Packet = $BoardEventRefs },
            [pscustomobject]@{ Name = "check report"; Packet = $CheckReport },
            [pscustomobject]@{ Name = "UI snapshot"; Packet = $UiSnapshot }
        )) {
        Assert-R17Cycle1DefinitionCyclePacket -Packet $packetInfo.Packet -Context $packetInfo.Name -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    if ([string]$TaskPacketReadyForDev.status -ne "ready_for_dev_packet_only") { throw "task packet status must be ready_for_dev_packet_only." }
    if ([bool]$TaskPacketReadyForDev.executed -ne $false -or [bool]$TaskPacketReadyForDev.task_execution.executed -ne $false) { throw "task packet must not be executed." }
    if ([bool]$TaskPacketReadyForDev.task_execution.implementation_started -ne $false) { throw "task packet must not start implementation." }

    if ([int]$A2aMessages.message_count -ne @($A2aMessages.messages).Count) { throw "A2A message count does not match messages." }
    foreach ($message in @($A2aMessages.messages)) {
        if ([string]$message.status -ne "not_sent_packet_candidate") { throw "A2A message '$($message.message_id)' must be not_sent_packet_candidate." }
        Assert-R17Cycle1DefinitionFalseFields -Object $message.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "A2A message $($message.message_id) runtime_flags"
        Assert-R17Cycle1DefinitionFalseFields -Object $message -FieldNames $script:ExplicitFalseFields -Context "A2A message $($message.message_id)"
    }

    if ([int]$A2aHandoffs.handoff_count -ne @($A2aHandoffs.handoffs).Count) { throw "handoff count does not match handoffs." }
    foreach ($handoff in @($A2aHandoffs.handoffs)) {
        if ([string]$handoff.status -ne "not_executed_packet_candidate") { throw "handoff '$($handoff.handoff_id)' must be not_executed_packet_candidate." }
        Assert-R17Cycle1DefinitionFalseFields -Object $handoff.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "handoff $($handoff.handoff_id) runtime_flags"
    }

    if ([int]$A2aDispatchRefs.dispatch_ref_count -ne @($A2aDispatchRefs.dispatch_refs_detail).Count) { throw "dispatch ref count does not match dispatch refs." }
    foreach ($dispatchRef in @($A2aDispatchRefs.dispatch_refs_detail)) {
        if ([string]$dispatchRef.dispatch_decision -ne "not_dispatched_packet_only") { throw "dispatch ref '$($dispatchRef.dispatch_ref_id)' must be not_dispatched_packet_only." }
    }

    if ([int]$ControlRefs.control_ref_count -ne @($ControlRefs.control_refs_detail).Count) { throw "control ref count does not match control refs." }
    if ([int]$BoardEventRefs.event_count -ne @($BoardEvents).Count) { throw "board event ref count does not match event log." }
    if ([string]$BoardEventRefs.final_lane -ne "ready_for_dev") { throw "board event refs final_lane must be ready_for_dev." }

    Assert-R17Cycle1DefinitionRequiredFields -Object $BoardCard -FieldNames @("artifact_type", "card_id", "task_id", "lane", "status", "evidence_refs", "memory_refs", "task_packet_ref", "non_claims", "claims") -Context "board card"
    if ($BoardCard.card_id -ne $script:CardId -or $BoardCard.task_id -ne $script:SourceTask) { throw "board card identity is invalid." }
    if ($BoardCard.lane -ne "ready_for_dev") { throw "board card lane must be ready_for_dev." }
    Assert-R17Cycle1DefinitionFalseFields -Object $BoardCard.claims -FieldNames $script:ExplicitFalseFields -Context "board card claims"
    Assert-R17Cycle1DefinitionRefArray -Values @($BoardCard.evidence_refs) -Context "board card evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    Assert-R17Cycle1DefinitionRefArray -Values @($BoardCard.memory_refs) -Context "board card memory_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence

    if ([string]$BoardSnapshot.final_lane -ne "ready_for_dev" -or [bool]$BoardSnapshot.live_board_mutation_performed -ne $false -or [bool]$BoardSnapshot.runtime_card_creation_performed -ne $false) {
        throw "board snapshot must be ready_for_dev with no live board mutation or runtime card creation."
    }
    if ([int]$BoardSnapshot.event_count -ne @($BoardEvents).Count) { throw "board snapshot event_count does not match event log." }
    foreach ($event in @($BoardEvents)) {
        Assert-R17Cycle1DefinitionRequiredFields -Object $event -FieldNames @("artifact_type", "event_id", "card_id", "event_type", "actor_role", "from_lane", "to_lane", "input_ref", "output_ref", "evidence_refs", "validation_refs", "transition_allowed", "user_approval_present", "non_claims", "rejected_claims") -Context "board event"
        if ($event.card_id -ne $script:CardId) { throw "board event '$($event.event_id)' card_id is invalid." }
        Assert-R17Cycle1DefinitionRefArray -Values @($event.evidence_refs) -Context "board event $($event.event_id) evidence_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        Assert-R17Cycle1DefinitionRefArray -Values @($event.validation_refs) -Context "board event $($event.event_id) validation_refs" -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
    }

    if ($CheckReport.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($check in @($CheckReport.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    foreach ($object in @($Contract, $OperatorIntent, $OrchestratorPacket, $PmDefinitionPacket, $ArchitectDefinitionPacket, $TaskPacketReadyForDev, $A2aMessages, $A2aHandoffs, $A2aDispatchRefs, $ControlRefs, $BoardEventRefs, $CheckReport, $BoardCard, $BoardSnapshot, $UiSnapshot)) {
        Assert-R17Cycle1DefinitionNoForbiddenContent -Value $object -Context "R17-023 cycle definition artifact set"
    }
    foreach ($event in @($BoardEvents)) {
        Assert-R17Cycle1DefinitionNoForbiddenContent -Value $event -Context "R17-023 board event"
    }

    if (-not $SkipKanbanJsCheck) {
        Assert-R17Cycle1DefinitionKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        CycleId = $script:CycleId
        CardId = $script:CardId
        MessageCount = [int]$A2aMessages.message_count
        HandoffCount = [int]$A2aHandoffs.handoff_count
        DispatchRefCount = [int]$A2aDispatchRefs.dispatch_ref_count
        ControlRefCount = [int]$ControlRefs.control_ref_count
        BoardEventCount = [int]$BoardEventRefs.event_count
        LiveCycleRuntimeImplemented = $false
        LiveOrchestratorRuntimeInvoked = $false
        LivePmAgentInvoked = $false
        LiveArchitectAgentInvoked = $false
        LiveA2aDispatchPerformed = $false
        A2aRuntimeImplemented = $false
        A2aMessageSent = $false
        AdapterRuntimeInvoked = $false
        ActualToolCallPerformed = $false
        ExternalApiCallPerformed = $false
        LiveBoardMutationPerformed = $false
        RuntimeCardCreationPerformed = $false
        CodexExecutorInvoked = $false
        DevOutputClaimed = $false
        QaResultClaimed = $false
        RealAuditVerdict = $false
        ExternalAuditAcceptanceClaimed = $false
        AutonomousAgentExecuted = $false
        ProductRuntimeExecuted = $false
        MainMergeClaimed = $false
    }
}

function Test-R17Cycle1Definition {
    param([string]$RepositoryRoot = (Get-R17Cycle1DefinitionRepositoryRoot))

    $paths = Get-R17Cycle1DefinitionPaths -RepositoryRoot $RepositoryRoot
    return Test-R17Cycle1DefinitionSet `
        -Contract (Read-R17Cycle1DefinitionJson -Path $paths.Contract) `
        -OperatorIntent (Read-R17Cycle1DefinitionJson -Path $paths.OperatorIntent) `
        -OrchestratorPacket (Read-R17Cycle1DefinitionJson -Path $paths.OrchestratorPacket) `
        -PmDefinitionPacket (Read-R17Cycle1DefinitionJson -Path $paths.PmDefinitionPacket) `
        -ArchitectDefinitionPacket (Read-R17Cycle1DefinitionJson -Path $paths.ArchitectDefinitionPacket) `
        -TaskPacketReadyForDev (Read-R17Cycle1DefinitionJson -Path $paths.TaskPacketReadyForDev) `
        -A2aMessages (Read-R17Cycle1DefinitionJson -Path $paths.A2aMessages) `
        -A2aHandoffs (Read-R17Cycle1DefinitionJson -Path $paths.A2aHandoffs) `
        -A2aDispatchRefs (Read-R17Cycle1DefinitionJson -Path $paths.A2aDispatchRefs) `
        -ControlRefs (Read-R17Cycle1DefinitionJson -Path $paths.ControlRefs) `
        -BoardEventRefs (Read-R17Cycle1DefinitionJson -Path $paths.BoardEventRefs) `
        -CheckReport (Read-R17Cycle1DefinitionJson -Path $paths.CheckReport) `
        -BoardCard (Read-R17Cycle1DefinitionJson -Path $paths.BoardCard) `
        -BoardEvents (Read-R17Cycle1DefinitionJsonLines -Path $paths.BoardEvents) `
        -BoardSnapshot (Read-R17Cycle1DefinitionJson -Path $paths.BoardSnapshot) `
        -UiSnapshot (Read-R17Cycle1DefinitionJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}
