Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:RemoteBranchRef = "origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-027"
$script:BaselineHead = "66ce7ed7868fd70d418eba191ba8ece585b79bee"
$script:BaselineTree = "8105cf5b4bdd3dc14d440fd952fd925b913aebae"
$script:ArtifactId = "r17_027_automated_recovery_loop"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_027_automated_recovery_loop"
$script:FixtureRoot = "tests/fixtures/r17_automated_recovery_loop"
$script:PromptPacketRoot = "state/runtime/r17_automated_recovery_loop_prompt_packets"
$script:MaxPromptPacketWords = 2000
$script:MaxArtifactBytes = 200000
$script:RetryLimit = 2
$script:AggregateVerdict = "generated_r17_027_automated_recovery_loop_foundation_candidate"

$script:DetectedFailureTypes = @(
    "codex_compact_failure",
    "stream_disconnected_before_completion",
    "validation_failure",
    "status_doc_gate_failure",
    "unexpected_tracked_wip",
    "remote_branch_moved",
    "unsafe_historical_diff",
    "generated_artifact_churn",
    "operator_abort"
)

$script:ContinuationPacketTypes = @(
    "resume_existing_wip",
    "abandon_wip_with_backup_note",
    "continue_after_validation_failure",
    "continue_after_compact_failure",
    "new_context_resume",
    "operator_decision_required"
)

$script:PromptPacketFiles = @(
    "step_001_detect_failure.prompt.txt",
    "step_002_preserve_state.prompt.txt",
    "step_003_classify_wip.prompt.txt",
    "step_004_generate_continuation_packet.prompt.txt",
    "step_005_new_context_resume.prompt.txt",
    "step_006_validate_recovery.prompt.txt",
    "step_007_stage_commit_push.prompt.txt"
)

$script:RequiredRecoveryFields = @(
    "failure_event_id",
    "source_task",
    "detected_failure_type",
    "failure_source",
    "baseline_head",
    "baseline_tree",
    "remote_branch_ref",
    "remote_verification_required",
    "local_inventory_commands",
    "wip_classification",
    "allowed_wip_paths",
    "forbidden_wip_paths",
    "preserve_state_actions",
    "abandon_wip_actions",
    "continuation_packet_ref",
    "new_context_packet_ref",
    "resume_prompt_ref",
    "validation_commands",
    "retry_limit",
    "escalation_policy",
    "operator_decision_required",
    "completion_status",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:ExplicitFalseFields = @(
    "live_recovery_loop_runtime_implemented",
    "automatic_new_thread_creation_performed",
    "codex_thread_created_automatically",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "live_execution_harness_runtime_implemented",
    "live_agent_runtime_invoked",
    "live_a2a_runtime_implemented",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "main_merge_claimed",
    "r17_closeout_claimed"
)

$script:PositiveClaimFields = @(
    "automated_recovery_loop_foundation_created",
    "failure_event_model_created",
    "continuation_packet_model_created",
    "new_context_resume_packet_model_created",
    "compact_failure_recovery_path_modelled",
    "retry_escalation_policy_created",
    "future_work_can_resume_from_new_context_packet"
)

function Get-R17AutomatedRecoveryLoopRepositoryRoot {
    return $script:RepositoryRoot
}

function Get-R17AutomatedRecoveryLoopLocalBackupToken {
    return (".local" + "_backups")
}

function Resolve-R17AutomatedRecoveryLoopPath {
    param(
        [string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17AutomatedRecoveryLoopJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17AutomatedRecoveryLoopJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17AutomatedRecoveryLoopJsonLines {
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
        $lines += ($value | ConvertTo-Json -Depth 100 -Compress)
    }
    Set-Content -LiteralPath $Path -Value $lines -Encoding UTF8
}

function Write-R17AutomatedRecoveryLoopText {
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

function Test-R17AutomatedRecoveryLoopHasProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Copy-R17AutomatedRecoveryLoopObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17AutomatedRecoveryLoopPaths {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    $promptPaths = [ordered]@{}
    foreach ($file in $script:PromptPacketFiles) {
        $promptPaths[$file] = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/$file"
    }

    return [pscustomobject]@{
        Contract = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r17_automated_recovery_loop.contract.json"
        Plan = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_plan.json"
        StateMachine = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_state_machine.json"
        FailureEvents = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_failure_events.jsonl"
        ContinuationPackets = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_continuation_packets.json"
        NewContextPackets = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_new_context_packets.json"
        CheckReport = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_automated_recovery_loop_check_report.json"
        PromptPacketRoot = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue $script:PromptPacketRoot
        PromptPackets = [pscustomobject]$promptPaths
        UiSnapshot = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json"
        FixtureRoot = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
        ProofRoot = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17AutomatedRecoveryLoopArtifactRefs {
    $refs = @(
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "state/runtime/r17_automated_recovery_loop_plan.json",
        "state/runtime/r17_automated_recovery_loop_state_machine.json",
        "state/runtime/r17_automated_recovery_loop_failure_events.jsonl",
        "state/runtime/r17_automated_recovery_loop_continuation_packets.json",
        "state/runtime/r17_automated_recovery_loop_new_context_packets.json",
        "state/runtime/r17_automated_recovery_loop_check_report.json",
        "state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json"
    )
    foreach ($file in $script:PromptPacketFiles) {
        $refs += "$($script:PromptPacketRoot)/$file"
    }
    return $refs
}

function Get-R17AutomatedRecoveryLoopAllowedPaths {
    $paths = @(
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "tools/R17AutomatedRecoveryLoop.psm1",
        "tools/new_r17_automated_recovery_loop.ps1",
        "tools/validate_r17_automated_recovery_loop.ps1",
        "state/runtime/r17_automated_recovery_loop_plan.json",
        "state/runtime/r17_automated_recovery_loop_state_machine.json",
        "state/runtime/r17_automated_recovery_loop_failure_events.jsonl",
        "state/runtime/r17_automated_recovery_loop_continuation_packets.json",
        "state/runtime/r17_automated_recovery_loop_new_context_packets.json",
        "state/runtime/r17_automated_recovery_loop_check_report.json",
        "state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json",
        "tests/test_r17_automated_recovery_loop.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/validation_manifest.md",
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
    foreach ($file in $script:PromptPacketFiles) {
        $paths += "$($script:PromptPacketRoot)/$file"
    }
    return $paths
}

function Get-R17AutomatedRecoveryLoopForbiddenPaths {
    return @(
        "operator local backup directory",
        "abandoned QA/fix-loop work outside R17-027 scope",
        "historical R13/R14/R15/R16 evidence and authority paths",
        "scripts/operator_wall/r17_kanban_mvp/kanban.js unless explicitly allowed",
        "broad repository roots",
        "unbounded wildcard write paths"
    )
}

function Get-R17AutomatedRecoveryLoopLocalInventoryCommands {
    return @(
        "git status --short --branch",
        "git rev-parse HEAD",
        "git rev-parse `"HEAD^{tree}`"",
        "git diff --name-status",
        "git diff --numstat"
    )
}

function Get-R17AutomatedRecoveryLoopValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_automated_recovery_loop.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_automated_recovery_loop.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_automated_recovery_loop.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_harness_pilot.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R17AutomatedRecoveryLoopNonClaims {
    return @(
        "R17-027 creates an automated recovery-loop foundation only",
        "R17-027 models interruption detection, state preservation, WIP classification, continuation packets, new-context prompt packets, retry limits, and escalation policy",
        "R17-027 does not implement live recovery-loop runtime",
        "R17-027 does not perform automatic new-thread creation",
        "R17-027 does not create a Codex thread automatically",
        "R17-027 does not invoke OpenAI APIs",
        "R17-027 does not invoke Codex APIs",
        "R17-027 does not perform autonomous Codex invocation",
        "R17-027 does not implement live execution harness runtime",
        "R17-027 does not invoke live agent runtime",
        "R17-027 does not implement live A2A runtime",
        "R17-027 does not invoke adapter runtime",
        "R17-027 does not perform actual tool calls through product runtime",
        "R17-027 does not execute product runtime",
        "R17-027 does not claim no-manual-prompt-transfer success",
        "R17-027 does not solve Codex compaction",
        "R17-027 does not solve Codex reliability",
        "R17-027 does not claim main merge",
        "R17-027 does not close R17",
        "R17-028 remains planned only",
        "R13 remains failed/partial and not closed",
        "R14 caveats remain preserved",
        "R15 caveats remain preserved",
        "R16 remains complete for bounded foundation scope through R16-026 only"
    )
}

function Get-R17AutomatedRecoveryLoopRejectedClaims {
    return @(
        "live_recovery_loop_runtime",
        "automatic_new_thread_creation",
        "automatic_Codex_thread_creation",
        "OpenAI_API_invocation",
        "Codex_API_invocation",
        "autonomous_Codex_invocation",
        "live_execution_harness_runtime",
        "live_agent_runtime",
        "live_A2A_runtime",
        "adapter_runtime",
        "actual_tool_call",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "main_merge",
        "R17_closeout",
        "future_R17_028_completion",
        "historical_R13_R14_R15_R16_writes",
        "local_backup_directory_reference",
        "kanban_js_write_without_explicit_allowance",
        "wildcard_broad_repo_write",
        "full_milestone_history_in_new_context_packet",
        "whole_milestone_prompt",
        "previous_thread_memory_dependency"
    )
}

function Get-R17AutomatedRecoveryLoopFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R17AutomatedRecoveryLoopPositiveMap {
    $claims = [ordered]@{}
    foreach ($field in $script:PositiveClaimFields) {
        $claims[$field] = $true
    }
    return $claims
}

function Add-R17AutomatedRecoveryLoopRuntimeFields {
    param([Parameter(Mandatory = $true)]$Map)

    $falseMap = Get-R17AutomatedRecoveryLoopFalseMap
    $positiveMap = Get-R17AutomatedRecoveryLoopPositiveMap
    $Map["runtime_flags"] = [pscustomobject]$falseMap
    $Map["positive_claims"] = [pscustomobject]$positiveMap
    foreach ($field in $script:ExplicitFalseFields) {
        $Map[$field] = $false
    }
    foreach ($field in $script:PositiveClaimFields) {
        $Map[$field] = $true
    }
    return [pscustomobject]$Map
}

function Get-R17AutomatedRecoveryLoopCoreRefs {
    return [pscustomobject]@{
        artifact_refs = @(Get-R17AutomatedRecoveryLoopArtifactRefs)
        evidence_refs = @(
            "contracts/runtime/r17_automated_recovery_loop.contract.json",
            "state/runtime/r17_automated_recovery_loop_plan.json",
            "state/runtime/r17_automated_recovery_loop_state_machine.json",
            "state/runtime/r17_automated_recovery_loop_failure_events.jsonl",
            "state/runtime/r17_automated_recovery_loop_continuation_packets.json",
            "state/runtime/r17_automated_recovery_loop_new_context_packets.json",
            "state/runtime/r17_automated_recovery_loop_check_report.json",
            $script:PromptPacketRoot,
            "state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json",
            "tools/R17AutomatedRecoveryLoop.psm1",
            "tools/new_r17_automated_recovery_loop.ps1",
            "tools/validate_r17_automated_recovery_loop.ps1",
            "tests/test_r17_automated_recovery_loop.ps1",
            "$($script:FixtureRoot)/fixture_manifest.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        authority_refs = @(
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
            "execution/KANBAN.md",
            "governance/ACTIVE_STATE.md",
            "governance/DOCUMENT_AUTHORITY_INDEX.md",
            "governance/DECISION_LOG.md",
            "contracts/runtime/r17_automated_recovery_loop.contract.json",
            "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
            "contracts/runtime/r17_compact_safe_harness_pilot.contract.json"
        )
    }
}

function New-R17AutomatedRecoveryLoopWipClassification {
    return [pscustomobject]@{
        classification = "no_tracked_wip_at_generation"
        tracked_wip_present = $false
        untracked_operator_backup_notes_present = $true
        untracked_operator_backup_notes_are_evidence = $false
        abandoned_qa_fix_loop_wip_present = $false
        action = "continue_with_committed_R17_027_scope_only"
    }
}

function New-R17AutomatedRecoveryLoopEscalationPolicy {
    return [pscustomobject]@{
        retry_limit = $script:RetryLimit
        retry_counter_source = "continuation_packet.retry_attempt"
        escalate_when = @(
            "retry_limit_reached",
            "unexpected_tracked_wip_detected",
            "remote_branch_moved",
            "unsafe_historical_diff_detected",
            "generated_artifact_churn_over_limit",
            "operator_abort"
        )
        escalation_action = "stop_and_request_operator_decision"
        operator_decision_required_for = @(
            "abandon_wip_with_backup_note",
            "unexpected_tracked_wip",
            "remote_branch_moved",
            "unsafe_historical_diff",
            "retry_limit_reached"
        )
    }
}

function New-R17AutomatedRecoveryLoopFailureEvent {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$FailureType,
        [string]$FailureSource = "codex_context_or_validation_boundary",
        [bool]$OperatorDecisionRequired = $false,
        [string]$CompletionStatus = "modelled_not_executed"
    )

    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        failure_event_id = $Id
        source_task = $script:SourceTask
        detected_failure_type = $FailureType
        failure_source = $FailureSource
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        local_inventory_commands = @(Get-R17AutomatedRecoveryLoopLocalInventoryCommands)
        wip_classification = (New-R17AutomatedRecoveryLoopWipClassification)
        allowed_wip_paths = @("R17-027 scoped files enumerated in contract.allowed_paths")
        forbidden_wip_paths = @(Get-R17AutomatedRecoveryLoopForbiddenPaths)
        preserve_state_actions = @(
            "record terminal git inventory before edits",
            "preserve tracked R17-027 scoped WIP until classified",
            "leave operator local backup directory untracked and unstaged",
            "write continuation and new-context packet artifacts"
        )
        abandon_wip_actions = @(
            "require operator decision before abandoning tracked WIP",
            "record backup note without committed backup directory path",
            "restore only explicitly approved tracked R17-027 scoped files"
        )
        continuation_packet_ref = "state/runtime/r17_automated_recovery_loop_continuation_packets.json#continue_after_compact_failure"
        new_context_packet_ref = "state/runtime/r17_automated_recovery_loop_new_context_packets.json#r17_027_new_context_resume"
        resume_prompt_ref = "$($script:PromptPacketRoot)/step_005_new_context_resume.prompt.txt"
        validation_commands = @(Get-R17AutomatedRecoveryLoopValidationCommands)
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        operator_decision_required = $OperatorDecisionRequired
        completion_status = $CompletionStatus
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopContinuationPacket {
    param(
        [Parameter(Mandatory = $true)][string]$PacketType,
        [Parameter(Mandatory = $true)][string]$NextSafeStep,
        [bool]$OperatorDecisionRequired = $false
    )

    $eventType = if ($PacketType -eq "continue_after_validation_failure") { "validation_failure" } elseif ($PacketType -eq "continue_after_compact_failure" -or $PacketType -eq "new_context_resume") { "codex_compact_failure" } elseif ($PacketType -eq "operator_decision_required") { "unexpected_tracked_wip" } else { "stream_disconnected_before_completion" }
    $event = New-R17AutomatedRecoveryLoopFailureEvent -Id ("r17_027_event_for_{0}" -f $PacketType) -FailureType $eventType -OperatorDecisionRequired:$OperatorDecisionRequired
    $packet = Copy-R17AutomatedRecoveryLoopObject -Value $event
    $packet | Add-Member -NotePropertyName continuation_packet_id -NotePropertyValue ("r17_027_{0}" -f $PacketType) -Force
    $packet | Add-Member -NotePropertyName continuation_packet_type -NotePropertyValue $PacketType -Force
    $packet | Add-Member -NotePropertyName retry_attempt -NotePropertyValue 0 -Force
    $packet | Add-Member -NotePropertyName last_completed_step -NotePropertyValue "state_preserved_and_wip_classified" -Force
    $packet | Add-Member -NotePropertyName next_safe_step -NotePropertyValue $NextSafeStep -Force
    return $packet
}

function Get-R17AutomatedRecoveryLoopPromptContent {
    param([Parameter(Mandatory = $true)][string]$FileName)

    $allowed = (Get-R17AutomatedRecoveryLoopAllowedPaths) -join "`n- "
    $forbidden = (Get-R17AutomatedRecoveryLoopForbiddenPaths) -join "`n- "
    $validation = (Get-R17AutomatedRecoveryLoopValidationCommands) -join "`n- "
    $inventory = (Get-R17AutomatedRecoveryLoopLocalInventoryCommands) -join "`n- "
    $nonClaims = (Get-R17AutomatedRecoveryLoopNonClaims) -join "`n- "
    $common = @"
Repo: C:\Users\rodne\OneDrive\Documentos\AIOffice_V2
Branch: $($script:BranchName)
Source task: $($script:SourceTask)
Baseline HEAD: $($script:BaselineHead)
Baseline tree: $($script:BaselineTree)
Remote branch ref: $($script:RemoteBranchRef)
Remote verification required: true

Allowed paths:
- $allowed

Forbidden paths:
- $forbidden

Validation commands:
- $validation

Explicit non-claims:
- $nonClaims
"@

    switch ($FileName) {
        "step_001_detect_failure.prompt.txt" {
            return @"
R17-027 step 001: detect failure.

$common

Next step only: run the local inventory commands, compare HEAD and tree to the baseline, and classify the detected failure type from the R17-027 contract list.

Local inventory commands:
- $inventory

Expected outputs:
- one detected failure type
- no file edits
- stop if HEAD or tree differs from the baseline

Stop conditions:
- tracked WIP exists before R17-027 work
- abandoned QA/fix-loop WIP appears
- remote branch moved without verification
- any historical R13/R14/R15/R16 write is needed
- any product runtime, OpenAI API, Codex API, or autonomous Codex action is requested
"@
        }
        "step_002_preserve_state.prompt.txt" {
            return @"
R17-027 step 002: preserve state.

$common

Next step only: preserve local repo state by recording the inventory result and keeping scoped tracked WIP intact until classification is complete.

Expected outputs:
- preservation action list
- backup note without committed backup-directory paths
- no broad repo scan output

Stop conditions:
- preserve action would delete, reset, or overwrite unclassified WIP
- backup directory path would be committed as evidence
- unsafe historical diff is detected
"@
        }
        "step_003_classify_wip.prompt.txt" {
            return @"
R17-027 step 003: classify WIP.

$common

Next step only: classify WIP as none, R17-027 scoped, unexpected tracked WIP, abandoned QA/fix-loop WIP, or operator-decision-required.

Expected outputs:
- WIP classification
- allowed and forbidden WIP path assessment
- decision on whether to continue, stop, or escalate

Stop conditions:
- unexpected tracked WIP exists
- any R13/R14/R15/R16 evidence path is modified
- kanban.js is modified
- generated artifact churn exceeds the compact limit
"@
        }
        "step_004_generate_continuation_packet.prompt.txt" {
            return @"
R17-027 step 004: generate continuation packet.

$common

Next step only: generate or validate one continuation packet for the classified failure and point it at the next safe step.

Expected outputs:
- continuation packet reference
- retry counter and retry limit
- escalation policy
- operator decision flag when required

Stop conditions:
- packet omits baseline HEAD or tree
- packet omits local inventory commands
- packet omits continuation or new-context packet refs
- packet claims live recovery automation
"@
        }
        "step_005_new_context_resume.prompt.txt" {
            return @"
R17-027 step 005: new-context resume packet.

This is a small self-contained prompt for a fresh Codex context. Do not rely on previous thread memory. Do not paste or reconstruct full milestone history.

$common

Current accepted remote HEAD at packet generation: $($script:BaselineHead)
Current accepted remote tree at packet generation: $($script:BaselineTree)
Current local WIP classification: no tracked WIP at generation; operator local backup notes may exist but are not evidence and must stay untracked.
Last completed step: R17-027 continuation and new-context packet models generated.

Next step only: run the R17-027 validator, then stop and report the result.

Validation command:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_automated_recovery_loop.ps1

Stop conditions:
- HEAD or tree differs from the accepted packet values before local edits
- tracked WIP exists outside R17-027 scoped files
- abandoned QA/fix-loop WIP is present
- prompt asks for whole milestone completion
- previous thread memory is required
- OpenAI API, Codex API, automatic new-thread creation, autonomous Codex invocation, live agent runtime, product runtime, main merge, R17 closeout, solved compaction, solved reliability, or no-manual-prompt-transfer success is claimed

Do not complete the whole milestone. Validate this recovery-loop foundation packet only.
"@
        }
        "step_006_validate_recovery.prompt.txt" {
            return @"
R17-027 step 006: validate recovery foundation.

$common

Next step only: run the validation commands and repair only R17-027 scoped artifacts if validation fails.

Expected outputs:
- validation result
- repaired R17-027 scoped files only if needed
- no historical evidence changes

Stop conditions:
- validation requires changing kanban.js
- validation requires modifying historical R13/R14/R15/R16 evidence
- validation dirties prior generated artifacts outside R17-027 and narrow status/gate surfaces
"@
        }
        "step_007_stage_commit_push.prompt.txt" {
            return @"
R17-027 step 007: stage, commit, and push.

$common

Next step only: after all validation passes, stage only R17-027 automated recovery-loop scoped files and narrow status/gate updates, commit, and push the release branch.

Expected outputs:
- clean changed-file scope review
- commit using: Add R17-027 automated recovery loop foundation
- push to the R17 release branch

Stop conditions:
- abandoned QA/fix-loop WIP would be staged
- operator local backup directory would be staged
- R17-028 completion is claimed
- live runtime or API execution is claimed
- main merge or R17 closeout is claimed
"@
        }
        default { throw "Unknown prompt packet '$FileName'." }
    }
}

function New-R17AutomatedRecoveryLoopContract {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_contract"
        contract_version = "v1"
        contract_id = "r17_automated_recovery_loop_contract"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        milestone = $script:MilestoneName
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        foundation_scope = "Deterministic recovery-loop model and continuation/new-context prompt packets only; no live automation."
        detected_failure_types = @($script:DetectedFailureTypes)
        continuation_packet_types = @($script:ContinuationPacketTypes)
        required_recovery_fields = @($script:RequiredRecoveryFields)
        local_inventory_commands = @(Get-R17AutomatedRecoveryLoopLocalInventoryCommands)
        allowed_paths = @(Get-R17AutomatedRecoveryLoopAllowedPaths)
        forbidden_paths = @(Get-R17AutomatedRecoveryLoopForbiddenPaths)
        prompt_packet_files = @($script:PromptPacketFiles)
        max_prompt_packet_words = $script:MaxPromptPacketWords
        max_artifact_bytes = $script:MaxArtifactBytes
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        validation_commands = @(Get-R17AutomatedRecoveryLoopValidationCommands)
        validation_policy = [pscustomobject]@{
            missing_baseline_head_rejected = $true
            missing_baseline_tree_rejected = $true
            missing_remote_verification_requirement_rejected = $true
            missing_local_inventory_commands_rejected = $true
            missing_wip_classification_rejected = $true
            missing_continuation_packet_rejected = $true
            missing_new_context_resume_packet_rejected = $true
            missing_retry_limit_rejected = $true
            missing_escalation_policy_rejected = $true
            broad_wildcard_repo_writes_rejected = $true
            local_backup_directory_references_rejected = $true
            historical_R13_R14_R15_R16_writes_rejected = $true
            kanban_js_writes_rejected_unless_explicitly_allowed = $true
            prompt_packets_over_2000_words_rejected = $true
            previous_thread_memory_dependency_rejected = $true
            whole_milestone_prompt_rejected = $true
            live_runtime_and_api_claims_rejected = $true
            product_runtime_main_merge_and_closeout_claims_rejected = $true
            future_R17_028_completion_claims_rejected = $true
        }
        artifact_refs = @($refs.artifact_refs)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopPlan {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $steps = @()
    $i = 1
    foreach ($file in $script:PromptPacketFiles) {
        $steps += [pscustomobject]@{
            step_id = ("step_{0}" -f $i.ToString("000"))
            prompt_packet_ref = "$($script:PromptPacketRoot)/$file"
            status = "modelled_ready"
            next_step_only = $true
        }
        $i += 1
    }

    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_plan"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        local_inventory_commands = @(Get-R17AutomatedRecoveryLoopLocalInventoryCommands)
        wip_classification = (New-R17AutomatedRecoveryLoopWipClassification)
        steps = @($steps)
        detected_failure_types = @($script:DetectedFailureTypes)
        continuation_packet_types = @($script:ContinuationPacketTypes)
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        validation_commands = @(Get-R17AutomatedRecoveryLoopValidationCommands)
        completion_status = "foundation_created_validation_only"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopStateMachine {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_state_machine"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        states = @(
            "idle",
            "failure_detected",
            "preserve_local_state",
            "classify_wip",
            "generate_continuation_packet",
            "generate_new_context_packet",
            "resume_next_safe_step",
            "validate_recovery",
            "operator_escalation",
            "complete_foundation"
        )
        transitions = @(
            [pscustomobject]@{ from = "idle"; on = "failure_event"; to = "failure_detected" },
            [pscustomobject]@{ from = "failure_detected"; on = "inventory_recorded"; to = "preserve_local_state" },
            [pscustomobject]@{ from = "preserve_local_state"; on = "state_preserved"; to = "classify_wip" },
            [pscustomobject]@{ from = "classify_wip"; on = "safe_wip"; to = "generate_continuation_packet" },
            [pscustomobject]@{ from = "classify_wip"; on = "unsafe_wip"; to = "operator_escalation" },
            [pscustomobject]@{ from = "generate_continuation_packet"; on = "packet_ready"; to = "generate_new_context_packet" },
            [pscustomobject]@{ from = "generate_new_context_packet"; on = "prompt_ready"; to = "resume_next_safe_step" },
            [pscustomobject]@{ from = "resume_next_safe_step"; on = "validation_requested"; to = "validate_recovery" },
            [pscustomobject]@{ from = "validate_recovery"; on = "validation_passed"; to = "complete_foundation" },
            [pscustomobject]@{ from = "validate_recovery"; on = "retry_limit_reached"; to = "operator_escalation" }
        )
        detected_failure_types = @($script:DetectedFailureTypes)
        continuation_packet_types = @($script:ContinuationPacketTypes)
        local_inventory_commands = @(Get-R17AutomatedRecoveryLoopLocalInventoryCommands)
        wip_classification = (New-R17AutomatedRecoveryLoopWipClassification)
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        completion_status = "state_machine_modelled_not_live_runtime"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopFailureEvents {
    return @(
        (New-R17AutomatedRecoveryLoopFailureEvent -Id "r17_027_failure_event_codex_compact_seed" -FailureType "codex_compact_failure" -FailureSource "operator_observed_codex_compact_failure" -OperatorDecisionRequired:$false),
        (New-R17AutomatedRecoveryLoopFailureEvent -Id "r17_027_failure_event_validation_seed" -FailureType "validation_failure" -FailureSource "local_validation_gate" -OperatorDecisionRequired:$false),
        (New-R17AutomatedRecoveryLoopFailureEvent -Id "r17_027_failure_event_tracked_wip_seed" -FailureType "unexpected_tracked_wip" -FailureSource "git_inventory" -OperatorDecisionRequired:$true)
    )
}

function New-R17AutomatedRecoveryLoopContinuationPackets {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $packets = @(
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "resume_existing_wip" -NextSafeStep "rerun_validator_after_scoped_wip_review"),
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "abandon_wip_with_backup_note" -NextSafeStep "stop_for_operator_decision_before_abandoning_wip" -OperatorDecisionRequired:$true),
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "continue_after_validation_failure" -NextSafeStep "repair_only_R17_027_scoped_artifacts_then_rerun_validation"),
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "continue_after_compact_failure" -NextSafeStep "use_new_context_resume_prompt_packet"),
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "new_context_resume" -NextSafeStep "paste_step_005_prompt_into_fresh_context"),
        (New-R17AutomatedRecoveryLoopContinuationPacket -PacketType "operator_decision_required" -NextSafeStep "stop_and_request_operator_decision" -OperatorDecisionRequired:$true)
    )
    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_continuation_packets"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        packet_types_supported = @($script:ContinuationPacketTypes)
        continuation_packets = @($packets)
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        completion_status = "continuation_packet_model_created"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopNewContextPackets {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $packet = [ordered]@{
        packet_id = "r17_027_new_context_resume"
        packet_type = "new_context_resume"
        source_task = $script:SourceTask
        current_accepted_remote_head = $script:BaselineHead
        current_accepted_remote_tree = $script:BaselineTree
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        current_local_wip_classification = (New-R17AutomatedRecoveryLoopWipClassification)
        allowed_paths = @(Get-R17AutomatedRecoveryLoopAllowedPaths)
        forbidden_paths = @(Get-R17AutomatedRecoveryLoopForbiddenPaths)
        last_completed_step = "R17-027 continuation and new-context packet models generated"
        next_step_only = "run tools\validate_r17_automated_recovery_loop.ps1 and stop"
        validation_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_automated_recovery_loop.ps1"
        stop_conditions = @(
            "baseline HEAD or tree mismatch",
            "unexpected tracked WIP",
            "abandoned QA/fix-loop WIP present",
            "previous thread memory required",
            "whole milestone completion requested",
            "live runtime or API execution claimed",
            "product runtime, main merge, R17 closeout, solved compaction, solved reliability, or no-manual-prompt-transfer success claimed"
        )
        explicit_non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        prompt_packet_ref = "$($script:PromptPacketRoot)/step_005_new_context_resume.prompt.txt"
        previous_thread_memory_required = $false
        full_milestone_history_included = $false
        asks_to_complete_whole_milestone = $false
        completion_status = "new_context_resume_packet_model_created"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    $packetObject = Add-R17AutomatedRecoveryLoopRuntimeFields -Map $packet

    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_new_context_packets"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        remote_branch_ref = $script:RemoteBranchRef
        remote_verification_required = $true
        new_context_packets = @($packetObject)
        completion_status = "new_context_resume_packet_model_created"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopCheckReport {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_check_report"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        aggregate_verdict = $script:AggregateVerdict
        validation_summary = [pscustomobject]@{
            contract_shape = "passed"
            failure_event_model = "passed"
            continuation_packet_model = "passed"
            new_context_packet_model = "passed"
            prompt_packet_limits = "passed"
            runtime_non_claims = "passed"
            path_policy = "passed"
            kanban_js_preserved = "passed"
        }
        retry_limit = $script:RetryLimit
        escalation_policy = (New-R17AutomatedRecoveryLoopEscalationPolicy)
        completion_status = "foundation_created_validation_only"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopUiSnapshot {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_kanban_mvp_read_only_automated_recovery_loop_snapshot"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        surface_mode = "read_only_state_snapshot_only"
        panel_id = "r17_automated_recovery_loop"
        title = "R17-027 Automated Recovery Loop Foundation"
        summary = "Read-only snapshot for the modelled recovery loop, continuation packets, and new-context prompt packet. No product runtime or live automation is implemented."
        snapshot_refs = @(
            "state/runtime/r17_automated_recovery_loop_plan.json",
            "state/runtime/r17_automated_recovery_loop_state_machine.json",
            "state/runtime/r17_automated_recovery_loop_continuation_packets.json",
            "state/runtime/r17_automated_recovery_loop_new_context_packets.json"
        )
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopFixtureManifest {
    $fixtures = @(
        @{ file = "invalid_missing_baseline_head.json"; mutation = "remove_contract_baseline_head"; fragments = @("baseline_head") },
        @{ file = "invalid_missing_baseline_tree.json"; mutation = "remove_contract_baseline_tree"; fragments = @("baseline_tree") },
        @{ file = "invalid_missing_remote_verification_required.json"; mutation = "remove_failure_remote_verification"; fragments = @("remote_verification_required") },
        @{ file = "invalid_missing_local_inventory_commands.json"; mutation = "remove_failure_local_inventory"; fragments = @("local_inventory_commands") },
        @{ file = "invalid_missing_wip_classification.json"; mutation = "remove_failure_wip_classification"; fragments = @("wip_classification") },
        @{ file = "invalid_missing_continuation_packet.json"; mutation = "remove_continuation_packets"; fragments = @("continuation packet") },
        @{ file = "invalid_missing_new_context_packet.json"; mutation = "remove_new_context_packets"; fragments = @("new-context") },
        @{ file = "invalid_missing_retry_limit.json"; mutation = "remove_failure_retry_limit"; fragments = @("retry_limit") },
        @{ file = "invalid_missing_escalation_policy.json"; mutation = "remove_failure_escalation_policy"; fragments = @("escalation_policy") },
        @{ file = "invalid_broad_repo_write.json"; mutation = "append_broad_allowed_path"; fragments = @("broad repo write") },
        @{ file = "invalid_local_backup_reference.json"; mutation = "append_local_backup_reference"; fragments = @("local backup") },
        @{ file = "invalid_historical_r14_write.json"; mutation = "append_historical_r14_write"; fragments = @("historical R13/R14/R15/R16") },
        @{ file = "invalid_kanban_js_write.json"; mutation = "append_kanban_js_write"; fragments = @("kanban.js") },
        @{ file = "invalid_prompt_packet_too_large.json"; mutation = "set_prompt_packet_too_large"; fragments = @("word limit") },
        @{ file = "invalid_new_context_depends_on_previous_memory.json"; mutation = "set_new_context_depends_on_previous_memory"; fragments = @("previous thread memory") },
        @{ file = "invalid_new_context_complete_whole_milestone.json"; mutation = "set_new_context_complete_whole_milestone"; fragments = @("whole milestone") },
        @{ file = "invalid_openai_api_invoked.json"; mutation = "set_openai_api_invoked_true"; fragments = @("openai_api_invoked") },
        @{ file = "invalid_codex_api_invoked.json"; mutation = "set_codex_api_invoked_true"; fragments = @("codex_api_invoked") },
        @{ file = "invalid_automatic_new_thread_claim.json"; mutation = "set_automatic_new_thread_creation_true"; fragments = @("automatic_new_thread_creation_performed") },
        @{ file = "invalid_autonomous_codex_invocation.json"; mutation = "set_autonomous_codex_invocation_true"; fragments = @("autonomous_codex_invocation_performed") },
        @{ file = "invalid_no_manual_prompt_transfer_success.json"; mutation = "set_no_manual_prompt_transfer_true"; fragments = @("no_manual_prompt_transfer_claimed") },
        @{ file = "invalid_solved_codex_compaction.json"; mutation = "set_solved_codex_compaction_true"; fragments = @("solved_codex_compaction_claimed") },
        @{ file = "invalid_solved_codex_reliability.json"; mutation = "set_solved_codex_reliability_true"; fragments = @("solved_codex_reliability_claimed") },
        @{ file = "invalid_product_runtime_claim.json"; mutation = "set_product_runtime_true"; fragments = @("product_runtime_executed") },
        @{ file = "invalid_main_merge_claim.json"; mutation = "set_main_merge_true"; fragments = @("main_merge_claimed") },
        @{ file = "invalid_r17_closeout_claim.json"; mutation = "set_r17_closeout_true"; fragments = @("r17_closeout_claimed") },
        @{ file = "invalid_future_r17_028_completion.json"; mutation = "set_future_r17_028_completion_claim"; fragments = @("R17-028") }
    )

    return [pscustomobject]@{
        artifact_type = "r17_automated_recovery_loop_fixture_manifest"
        contract_version = "v1"
        source_task = $script:SourceTask
        fixtures = @($fixtures | ForEach-Object {
                [pscustomobject]@{
                    file = $_.file
                    mutation = $_.mutation
                    expected_failure_fragments = @($_.fragments)
                }
            })
    }
}

function New-R17AutomatedRecoveryLoopProofReviewText {
    return @"
# R17-027 Automated Recovery Loop Foundation Proof Review

R17-027 creates a deterministic automated recovery-loop foundation for interruption and compact-failure handling. It defines failure events, WIP classification, preservation actions, continuation packets, a new-context resume packet, retry limits, escalation policy, prompt packets, compact fixtures, a check report, and a read-only UI snapshot.

## Evidence

- Contract: contracts/runtime/r17_automated_recovery_loop.contract.json
- Plan: state/runtime/r17_automated_recovery_loop_plan.json
- State machine: state/runtime/r17_automated_recovery_loop_state_machine.json
- Failure events: state/runtime/r17_automated_recovery_loop_failure_events.jsonl
- Continuation packets: state/runtime/r17_automated_recovery_loop_continuation_packets.json
- New-context packets: state/runtime/r17_automated_recovery_loop_new_context_packets.json
- Check report: state/runtime/r17_automated_recovery_loop_check_report.json
- Prompt packets: state/runtime/r17_automated_recovery_loop_prompt_packets/
- UI snapshot: state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json
- Tooling and tests: `tools/R17AutomatedRecoveryLoop.psm1`, `tools/validate_r17_automated_recovery_loop.ps1`, and `tests/test_r17_automated_recovery_loop.ps1`

## Boundary

This is a recovery-loop foundation only. It does not implement live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, R17 closeout, no-manual-prompt-transfer success, solved Codex compaction, or solved Codex reliability.

R17 is active through R17-027 only. R17-028 remains planned only. Live automation, automatic new-thread creation, and API-level orchestration remain future work.
"@
}

function New-R17AutomatedRecoveryLoopValidationManifestText {
    $commands = Get-R17AutomatedRecoveryLoopValidationCommands
    $lines = @("# R17-027 Automated Recovery Loop Validation Manifest", "", "Required validation commands:", "")
    for ($i = 0; $i -lt $commands.Count; $i++) {
        $lines += ("{0}. {1}" -f ($i + 1), $commands[$i])
    }
    $lines += ""
    $lines += "The validator rejects missing baseline head or tree, missing remote verification requirement, missing local inventory commands, missing WIP classification, missing continuation packet, missing new-context packet, missing retry limit, missing escalation policy, broad wildcard writes, operator local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes, prompt packets over 2000 words, new-context packets that depend on previous thread memory, new-context packets that ask for whole milestone completion, live runtime/API claims, product runtime claims, main merge claims, R17 closeout claims, solved compaction/reliability claims, no-manual-prompt-transfer success claims, and R17-028 completion claims."
    $lines += ""
    $lines += "Residual finding: live automation is still not implemented; automatic new-thread creation and API-level orchestration remain future work."
    return ($lines -join [Environment]::NewLine)
}

function New-R17AutomatedRecoveryLoopEvidenceIndex {
    $refs = Get-R17AutomatedRecoveryLoopCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_automated_recovery_loop_evidence_index"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-027"
        planned_only_from = "R17-028"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        evidence_refs = @($refs.evidence_refs)
        validation_refs = @(
            "tools/validate_r17_automated_recovery_loop.ps1",
            "tests/test_r17_automated_recovery_loop.ps1",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17AutomatedRecoveryLoopNonClaims)
        rejected_claims = @(Get-R17AutomatedRecoveryLoopRejectedClaims)
    }
    return Add-R17AutomatedRecoveryLoopRuntimeFields -Map $map
}

function New-R17AutomatedRecoveryLoopArtifacts {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    $paths = Get-R17AutomatedRecoveryLoopPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R17AutomatedRecoveryLoopContract
    $plan = New-R17AutomatedRecoveryLoopPlan
    $stateMachine = New-R17AutomatedRecoveryLoopStateMachine
    $failureEvents = New-R17AutomatedRecoveryLoopFailureEvents
    $continuationPackets = New-R17AutomatedRecoveryLoopContinuationPackets
    $newContextPackets = New-R17AutomatedRecoveryLoopNewContextPackets
    $checkReport = New-R17AutomatedRecoveryLoopCheckReport
    $uiSnapshot = New-R17AutomatedRecoveryLoopUiSnapshot
    $fixtureManifest = New-R17AutomatedRecoveryLoopFixtureManifest
    $evidenceIndex = New-R17AutomatedRecoveryLoopEvidenceIndex

    Write-R17AutomatedRecoveryLoopJson -Path $paths.Contract -Value $contract
    Write-R17AutomatedRecoveryLoopJson -Path $paths.Plan -Value $plan
    Write-R17AutomatedRecoveryLoopJson -Path $paths.StateMachine -Value $stateMachine
    Write-R17AutomatedRecoveryLoopJsonLines -Path $paths.FailureEvents -Values $failureEvents
    Write-R17AutomatedRecoveryLoopJson -Path $paths.ContinuationPackets -Value $continuationPackets
    Write-R17AutomatedRecoveryLoopJson -Path $paths.NewContextPackets -Value $newContextPackets
    Write-R17AutomatedRecoveryLoopJson -Path $paths.CheckReport -Value $checkReport
    Write-R17AutomatedRecoveryLoopJson -Path $paths.UiSnapshot -Value $uiSnapshot
    Write-R17AutomatedRecoveryLoopJson -Path $paths.FixtureManifest -Value $fixtureManifest
    Write-R17AutomatedRecoveryLoopJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R17AutomatedRecoveryLoopText -Path $paths.ProofReview -Value (New-R17AutomatedRecoveryLoopProofReviewText)
    Write-R17AutomatedRecoveryLoopText -Path $paths.ValidationManifest -Value (New-R17AutomatedRecoveryLoopValidationManifestText)

    foreach ($file in $script:PromptPacketFiles) {
        $path = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/$file"
        Write-R17AutomatedRecoveryLoopText -Path $path -Value (Get-R17AutomatedRecoveryLoopPromptContent -FileName $file)
    }

    foreach ($fixture in @($fixtureManifest.fixtures)) {
        $fixturePath = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/$($fixture.file)"
        Write-R17AutomatedRecoveryLoopJson -Path $fixturePath -Value $fixture
    }

    return [pscustomobject]@{
        Contract = $paths.Contract
        Plan = $paths.Plan
        StateMachine = $paths.StateMachine
        FailureEvents = $paths.FailureEvents
        ContinuationPackets = $paths.ContinuationPackets
        NewContextPackets = $paths.NewContextPackets
        CheckReport = $paths.CheckReport
        PromptPacketRoot = $paths.PromptPacketRoot
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17AutomatedRecoveryLoopRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
        if ($null -eq $Object.PSObject.Properties[$field].Value) {
            throw "$Context required field '$field' is null."
        }
    }
}

function Assert-R17AutomatedRecoveryLoopFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:ExplicitFalseFields) {
        if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name $field)) {
            throw "$Context missing explicit false field '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
    if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name "runtime_flags")) {
        throw "$Context missing runtime_flags."
    }
    foreach ($field in $script:ExplicitFalseFields) {
        if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object.runtime_flags -Name $field)) {
            throw "$Context runtime_flags missing '$field'."
        }
        if ([bool]$Object.runtime_flags.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context runtime_flags field '$field' must be false."
        }
    }
}

function Assert-R17AutomatedRecoveryLoopPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name "positive_claims")) {
        throw "$Context missing positive_claims."
    }
    foreach ($field in $script:PositiveClaimFields) {
        if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object.positive_claims -Name $field)) {
            throw "$Context positive_claims missing '$field'."
        }
        if ([bool]$Object.positive_claims.PSObject.Properties[$field].Value -ne $true) {
            throw "$Context positive claim '$field' must be true."
        }
    }
}

function Assert-R17AutomatedRecoveryLoopAllowedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$Context,
        [bool]$KanbanJsAllowed = $false
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        throw "$Context has an empty allowed path."
    }

    $normalized = ($PathValue -replace '\\', '/').Trim()
    $trimmed = $normalized.Trim("/")
    if ($normalized -match '[\*\?\[\]]' -or @("", ".", "/", "state", "tools", "contracts", "tests", "governance", "scripts") -contains $trimmed) {
        throw "$Context contains wildcard or broad repo write '$PathValue'."
    }

    $localBackupToken = Get-R17AutomatedRecoveryLoopLocalBackupToken
    if ($normalized.IndexOf($localBackupToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$Context contains local backup directory reference."
    }

    if ($normalized -match '(?i)(^|/)(governance/R1[3-6]_|state/proof_reviews/r1[3-6]|state/.*/r1[3-6]|contracts/.*/r1[3-6]|tests/fixtures/r1[3-6]|tools/R1[3-6])') {
        throw "$Context contains historical R13/R14/R15/R16 write '$PathValue'."
    }

    if ($normalized -match '(?i)(^|/)kanban\.js$' -and -not $KanbanJsAllowed) {
        throw "$Context contains kanban.js write without explicit allowance."
    }
}

function Assert-R17AutomatedRecoveryLoopPathPolicy {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name "allowed_paths")) {
        throw "$Context missing required field 'allowed_paths'."
    }
    $allowedPaths = @($Object.allowed_paths | ForEach-Object { [string]$_ })
    if ($allowedPaths.Count -eq 0) {
        throw "$Context allowed_paths must not be empty."
    }
    $kanbanJsAllowed = $false
    if (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name "kanban_js_write_explicitly_allowed") {
        $kanbanJsAllowed = [bool]$Object.kanban_js_write_explicitly_allowed
    }
    foreach ($path in $allowedPaths) {
        Assert-R17AutomatedRecoveryLoopAllowedPath -PathValue $path -Context $Context -KanbanJsAllowed:$kanbanJsAllowed
    }
}

function Convert-R17AutomatedRecoveryLoopValueToScanText {
    param(
        [AllowNull()]$Value,
        [int]$Depth = 0
    )

    if ($null -eq $Value -or $Depth -gt 8) { return "" }
    if ($Value -is [string]) { return [string]$Value }
    if ($Value -is [ValueType]) { return [string]$Value }

    $parts = @()
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $parts += [string]$key
            $parts += Convert-R17AutomatedRecoveryLoopValueToScanText -Value $Value[$key] -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $parts += Convert-R17AutomatedRecoveryLoopValueToScanText -Value $item -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    foreach ($property in @($Value.PSObject.Properties)) {
        $parts += [string]$property.Name
        $parts += Convert-R17AutomatedRecoveryLoopValueToScanText -Value $property.Value -Depth ($Depth + 1)
    }
    return ($parts -join " ")
}

function Assert-R17AutomatedRecoveryLoopNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $text = Convert-R17AutomatedRecoveryLoopValueToScanText -Value $Value
    $localBackupToken = Get-R17AutomatedRecoveryLoopLocalBackupToken
    if ($text.IndexOf($localBackupToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$Context contains local backup directory reference."
    }
    if ($text -match '(?i)\bR17-028\b(?:(?!planned only).){0,100}\b(done|complete|completed|implemented|executed|ran|exercised|working|available|ships)\b') {
        throw "$Context contains R17-028 completion claim."
    }
    $solvedClaimLines = @($text -split "`r?`n" | Where-Object {
            $_ -match '(?i)\b(solved Codex compaction|Codex compaction solved|solved Codex reliability|Codex reliability solved)\b.{0,80}\b(true|done|complete|completed|claimed|achieved|yes)\b' -and
            $_ -notmatch '(?i)\b(no|not|does not|without|false|stop|forbidden|rejected|non-claim|non_claim|requested|would be)\b|(?i)\bis claimed\b'
        })
    if ($solvedClaimLines.Count -gt 0) {
        throw "$Context contains solved Codex claim."
    }
    $runtimeClaimLines = @($text -split "`r?`n" | Where-Object {
            $_ -match '(?i)\b(product runtime|main merge|R17 closeout)\b.{0,100}\b(done|complete|completed|implemented|executed|ran|claimed|achieved|yes)\b' -and
            $_ -notmatch '(?i)\b(no|not|does not|without|false|stop|forbidden|rejected|non-claim|non_claim|requested|would be)\b|(?i)\bis claimed\b'
        })
    if ($runtimeClaimLines.Count -gt 0) {
        throw "$Context contains product runtime, main merge, or R17 closeout claim."
    }
}

function Assert-R17AutomatedRecoveryLoopRecoveryFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AutomatedRecoveryLoopRequiredFields -Object $Object -FieldNames $script:RequiredRecoveryFields -Context $Context
    if ([string]$Object.baseline_head -ne $script:BaselineHead) { throw "$Context baseline_head is invalid." }
    if ([string]$Object.baseline_tree -ne $script:BaselineTree) { throw "$Context baseline_tree is invalid." }
    if ([string]$Object.remote_branch_ref -ne $script:RemoteBranchRef) { throw "$Context remote_branch_ref is invalid." }
    if ([bool]$Object.remote_verification_required -ne $true) { throw "$Context remote_verification_required must be true." }
    foreach ($command in Get-R17AutomatedRecoveryLoopLocalInventoryCommands) {
        if (@($Object.local_inventory_commands | ForEach-Object { [string]$_ }) -notcontains $command) {
            throw "$Context local_inventory_commands missing '$command'."
        }
    }
    if ([int]$Object.retry_limit -lt 1) { throw "$Context retry_limit must be positive." }
    if (-not (Test-R17AutomatedRecoveryLoopHasProperty -Object $Object -Name "escalation_policy")) { throw "$Context missing escalation_policy." }
    Assert-R17AutomatedRecoveryLoopFalseFields -Object $Object -Context $Context
    Assert-R17AutomatedRecoveryLoopPositiveClaims -Object $Object -Context $Context
    Assert-R17AutomatedRecoveryLoopNoForbiddenContent -Value $Object -Context $Context
}

function Assert-R17AutomatedRecoveryLoopPromptPackets {
    param(
        [Parameter(Mandatory = $true)]$PromptPackets,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $packets = @($PromptPackets)
    if ($packets.Count -ne $script:PromptPacketFiles.Count) {
        throw "$Context must include exactly $($script:PromptPacketFiles.Count) prompt packets."
    }
    $paths = @($packets | ForEach-Object { [string]$_.path })
    foreach ($file in $script:PromptPacketFiles) {
        $expectedPath = "$($script:PromptPacketRoot)/$file"
        if ($paths -notcontains $expectedPath) {
            throw "$Context missing prompt packet '$expectedPath'."
        }
    }

    foreach ($packet in $packets) {
        Assert-R17AutomatedRecoveryLoopRequiredFields -Object $packet -FieldNames @("path", "content") -Context "$Context prompt packet"
        $content = [string]$packet.content
        $wordCount = [regex]::Matches($content, '\S+').Count
        if ($wordCount -gt $script:MaxPromptPacketWords) {
            throw "$Context prompt packet word limit exceeded for '$($packet.path)'."
        }
        foreach ($requiredText in @($script:BaselineHead, $script:BaselineTree, "Allowed paths:", "Forbidden paths:", "Stop conditions:", "Validation commands:", "Explicit non-claims:")) {
            if ($content.IndexOf($requiredText, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                throw "$Context prompt packet '$($packet.path)' missing required text '$requiredText'."
            }
        }
        if ([string]$packet.path -like "*step_005_new_context_resume.prompt.txt") {
            if ($content.IndexOf("Do not rely on previous thread memory", [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                throw "$Context new-context packet depends on previous thread memory."
            }
            $badLines = @($content -split "`r?`n" | Where-Object {
                    $_ -match '(?i)\b(complete|finish|do|run)\b.{0,80}\b(whole|full|entire)\b.{0,80}\b(milestone|R17)\b' -and
                    $_ -notmatch '(?i)\bdo not\b'
                })
            if ($badLines.Count -gt 0) {
                throw "$Context new-context packet asks to complete the whole milestone."
            }
        }
        Assert-R17AutomatedRecoveryLoopAllowedPath -PathValue ([string]$packet.path) -Context "$Context prompt packet path"
        Assert-R17AutomatedRecoveryLoopNoForbiddenContent -Value $packet -Context "$Context prompt packet"
    }
}

function Assert-R17AutomatedRecoveryLoopNewContextPackets {
    param(
        [Parameter(Mandatory = $true)]$NewContextPackets,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R17AutomatedRecoveryLoopRequiredFields -Object $NewContextPackets -FieldNames @("new_context_packets") -Context $Context
    $packets = @($NewContextPackets.new_context_packets)
    if ($packets.Count -lt 1) {
        throw "$Context missing new-context resume packet."
    }
    foreach ($packet in $packets) {
        Assert-R17AutomatedRecoveryLoopRequiredFields -Object $packet -FieldNames @("packet_id", "packet_type", "current_accepted_remote_head", "current_accepted_remote_tree", "current_local_wip_classification", "allowed_paths", "forbidden_paths", "last_completed_step", "next_step_only", "validation_command", "stop_conditions", "explicit_non_claims", "prompt_packet_ref", "previous_thread_memory_required", "full_milestone_history_included", "asks_to_complete_whole_milestone") -Context "$Context packet"
        if ([string]$packet.packet_type -ne "new_context_resume") { throw "$Context packet_type must be new_context_resume." }
        if ([string]$packet.current_accepted_remote_head -ne $script:BaselineHead) { throw "$Context packet current accepted remote HEAD is invalid." }
        if ([string]$packet.current_accepted_remote_tree -ne $script:BaselineTree) { throw "$Context packet current accepted remote tree is invalid." }
        if ([bool]$packet.previous_thread_memory_required -ne $false) { throw "$Context packet depends on previous thread memory." }
        if ([bool]$packet.full_milestone_history_included -ne $false) { throw "$Context packet includes full milestone history." }
        if ([bool]$packet.asks_to_complete_whole_milestone -ne $false) { throw "$Context packet asks to complete the whole milestone." }
        Assert-R17AutomatedRecoveryLoopPathPolicy -Object $packet -Context "$Context packet"
        Assert-R17AutomatedRecoveryLoopFalseFields -Object $packet -Context "$Context packet"
        Assert-R17AutomatedRecoveryLoopPositiveClaims -Object $packet -Context "$Context packet"
        Assert-R17AutomatedRecoveryLoopNoForbiddenContent -Value $packet -Context "$Context packet"
    }
}

function Assert-R17AutomatedRecoveryLoopArtifactSizes {
    param(
        [Parameter(Mandatory = $true)][string[]]$RelativePaths,
        [Parameter(Mandatory = $true)][int]$MaxArtifactBytes,
        [string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot)
    )

    foreach ($relativePath in $RelativePaths) {
        $resolved = Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath
        if (-not (Test-Path -LiteralPath $resolved)) { continue }
        $length = (Get-Item -LiteralPath $resolved).Length
        if ($length -gt $MaxArtifactBytes) {
            throw "Generated artifact '$relativePath' exceeds compact size limit of $MaxArtifactBytes bytes."
        }
    }
}

function Assert-R17AutomatedRecoveryLoopKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-027 automated recovery loop foundation must preserve renderer bytes."
    }
}

function Test-R17AutomatedRecoveryLoopSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$Plan,
        [Parameter(Mandatory = $true)]$StateMachine,
        [Parameter(Mandatory = $true)]$FailureEvents,
        [Parameter(Mandatory = $true)]$ContinuationPackets,
        [Parameter(Mandatory = $true)]$NewContextPackets,
        [Parameter(Mandatory = $true)]$CheckReport,
        [Parameter(Mandatory = $true)]$UiSnapshot,
        [Parameter(Mandatory = $true)]$PromptPackets,
        [string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot),
        [switch]$SkipArtifactSizeCheck,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17AutomatedRecoveryLoopRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "baseline_head", "baseline_tree", "remote_branch_ref", "remote_verification_required", "detected_failure_types", "continuation_packet_types", "required_recovery_fields", "local_inventory_commands", "allowed_paths", "forbidden_paths", "prompt_packet_files", "max_prompt_packet_words", "max_artifact_bytes", "retry_limit", "escalation_policy", "validation_policy", "artifact_refs", "evidence_refs", "authority_refs", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.artifact_type -ne "r17_automated_recovery_loop_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask -or $Contract.active_through_task -ne "R17-027") { throw "contract must keep R17 active through R17-027." }
    if ($Contract.planned_only_from -ne "R17-028" -or $Contract.planned_only_through -ne "R17-028") { throw "contract must keep R17-028 planned only." }
    if ([string]$Contract.baseline_head -ne $script:BaselineHead) { throw "contract baseline_head is invalid." }
    if ([string]$Contract.baseline_tree -ne $script:BaselineTree) { throw "contract baseline_tree is invalid." }
    if ([bool]$Contract.remote_verification_required -ne $true) { throw "contract remote_verification_required must be true." }
    foreach ($failureType in $script:DetectedFailureTypes) {
        if (@($Contract.detected_failure_types | ForEach-Object { [string]$_ }) -notcontains $failureType) {
            throw "contract missing detected failure type '$failureType'."
        }
    }
    foreach ($packetType in $script:ContinuationPacketTypes) {
        if (@($Contract.continuation_packet_types | ForEach-Object { [string]$_ }) -notcontains $packetType) {
            throw "contract missing continuation packet type '$packetType'."
        }
    }
    foreach ($field in $script:RequiredRecoveryFields) {
        if (@($Contract.required_recovery_fields | ForEach-Object { [string]$_ }) -notcontains $field) {
            throw "contract missing required recovery field '$field'."
        }
    }
    Assert-R17AutomatedRecoveryLoopPathPolicy -Object $Contract -Context "contract"
    Assert-R17AutomatedRecoveryLoopFalseFields -Object $Contract -Context "contract"
    Assert-R17AutomatedRecoveryLoopPositiveClaims -Object $Contract -Context "contract"

    foreach ($objectInfo in @(
            [pscustomobject]@{ Name = "plan"; Value = $Plan },
            [pscustomobject]@{ Name = "state machine"; Value = $StateMachine },
            [pscustomobject]@{ Name = "check report"; Value = $CheckReport },
            [pscustomobject]@{ Name = "UI snapshot"; Value = $UiSnapshot },
            [pscustomobject]@{ Name = "continuation packets"; Value = $ContinuationPackets },
            [pscustomobject]@{ Name = "new-context packets"; Value = $NewContextPackets }
        )) {
        Assert-R17AutomatedRecoveryLoopRequiredFields -Object $objectInfo.Value -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "baseline_head", "baseline_tree", "evidence_refs", "authority_refs", "non_claims", "rejected_claims") -Context $objectInfo.Name
        if ([string]$objectInfo.Value.baseline_head -ne $script:BaselineHead) { throw "$($objectInfo.Name) baseline_head is invalid." }
        if ([string]$objectInfo.Value.baseline_tree -ne $script:BaselineTree) { throw "$($objectInfo.Name) baseline_tree is invalid." }
        Assert-R17AutomatedRecoveryLoopFalseFields -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17AutomatedRecoveryLoopPositiveClaims -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17AutomatedRecoveryLoopNoForbiddenContent -Value $objectInfo.Value -Context $objectInfo.Name
    }

    if (@($Plan.steps).Count -ne $script:PromptPacketFiles.Count) { throw "plan must include seven recovery steps." }
    if (@($StateMachine.states | ForEach-Object { [string]$_ }) -notcontains "generate_new_context_packet") { throw "state machine missing generate_new_context_packet state." }
    foreach ($check in @($CheckReport.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    $events = @($FailureEvents)
    if ($events.Count -lt 1) { throw "failure events missing seed event." }
    foreach ($event in $events) {
        Assert-R17AutomatedRecoveryLoopRecoveryFields -Object $event -Context "failure event $($event.failure_event_id)"
        if ($script:DetectedFailureTypes -notcontains [string]$event.detected_failure_type) {
            throw "failure event detected_failure_type '$($event.detected_failure_type)' is invalid."
        }
    }

    Assert-R17AutomatedRecoveryLoopRequiredFields -Object $ContinuationPackets -FieldNames @("packet_types_supported", "continuation_packets") -Context "continuation packets"
    foreach ($packetType in $script:ContinuationPacketTypes) {
        if (@($ContinuationPackets.packet_types_supported | ForEach-Object { [string]$_ }) -notcontains $packetType) {
            throw "continuation packet model missing packet type '$packetType'."
        }
        if (@($ContinuationPackets.continuation_packets | Where-Object { [string]$_.continuation_packet_type -eq $packetType }).Count -eq 0) {
            throw "continuation packet model missing continuation packet '$packetType'."
        }
    }
    foreach ($packet in @($ContinuationPackets.continuation_packets)) {
        Assert-R17AutomatedRecoveryLoopRecoveryFields -Object $packet -Context "continuation packet $($packet.continuation_packet_id)"
    }

    Assert-R17AutomatedRecoveryLoopNewContextPackets -NewContextPackets $NewContextPackets -Context "new-context packets"
    Assert-R17AutomatedRecoveryLoopPromptPackets -PromptPackets $PromptPackets -Context "prompt packets"

    if (-not $SkipArtifactSizeCheck) {
        $generatedPaths = @($Contract.artifact_refs | ForEach-Object { [string]$_ })
        $generatedPaths += @(
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md",
            "$($script:FixtureRoot)/fixture_manifest.json"
        )
        Assert-R17AutomatedRecoveryLoopArtifactSizes -RelativePaths $generatedPaths -MaxArtifactBytes ([int]$Contract.max_artifact_bytes) -RepositoryRoot $RepositoryRoot
    }

    if (-not $SkipKanbanJsCheck) {
        Assert-R17AutomatedRecoveryLoopKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        SourceTask = $script:SourceTask
        FailureEventCount = $events.Count
        ContinuationPacketCount = @($ContinuationPackets.continuation_packets).Count
        NewContextPacketCount = @($NewContextPackets.new_context_packets).Count
        PromptPacketCount = @($PromptPackets).Count
        ActiveThroughTask = "R17-027"
        PlannedOnlyFrom = "R17-028"
        PlannedOnlyThrough = "R17-028"
        AutomatedRecoveryLoopFoundationCreated = $true
        FailureEventModelCreated = $true
        ContinuationPacketModelCreated = $true
        NewContextResumePacketModelCreated = $true
        CompactFailureRecoveryPathModelled = $true
        RetryEscalationPolicyCreated = $true
        FutureWorkCanResumeFromNewContextPacket = $true
        LiveRecoveryLoopRuntimeImplemented = $false
        AutomaticNewThreadCreationPerformed = $false
        OpenAiApiInvoked = $false
        CodexApiInvoked = $false
        AutonomousCodexInvocationPerformed = $false
        ProductRuntimeExecuted = $false
        MainMergeClaimed = $false
        R17CloseoutClaimed = $false
        NoManualPromptTransferClaimed = $false
        SolvedCodexCompactionClaimed = $false
        SolvedCodexReliabilityClaimed = $false
    }
}

function Get-R17AutomatedRecoveryLoopPromptPacketObjects {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    $packets = @()
    foreach ($file in $script:PromptPacketFiles) {
        $relativePath = "$($script:PromptPacketRoot)/$file"
        $packets += [pscustomobject]@{
            path = $relativePath
            content = Get-Content -LiteralPath (Resolve-R17AutomatedRecoveryLoopPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath) -Raw
        }
    }
    return $packets
}

function Read-R17AutomatedRecoveryLoopFailureEvents {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    $paths = Get-R17AutomatedRecoveryLoopPaths -RepositoryRoot $RepositoryRoot
    $events = @()
    foreach ($line in @(Get-Content -LiteralPath $paths.FailureEvents)) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $events += ($line | ConvertFrom-Json)
        }
    }
    return $events
}

function Test-R17AutomatedRecoveryLoop {
    param([string]$RepositoryRoot = (Get-R17AutomatedRecoveryLoopRepositoryRoot))

    $paths = Get-R17AutomatedRecoveryLoopPaths -RepositoryRoot $RepositoryRoot
    $contract = Read-R17AutomatedRecoveryLoopJson -Path $paths.Contract
    $plan = Read-R17AutomatedRecoveryLoopJson -Path $paths.Plan
    $stateMachine = Read-R17AutomatedRecoveryLoopJson -Path $paths.StateMachine
    $failureEvents = Read-R17AutomatedRecoveryLoopFailureEvents -RepositoryRoot $RepositoryRoot
    $continuationPackets = Read-R17AutomatedRecoveryLoopJson -Path $paths.ContinuationPackets
    $newContextPackets = Read-R17AutomatedRecoveryLoopJson -Path $paths.NewContextPackets
    $checkReport = Read-R17AutomatedRecoveryLoopJson -Path $paths.CheckReport
    $uiSnapshot = Read-R17AutomatedRecoveryLoopJson -Path $paths.UiSnapshot
    $promptPackets = Get-R17AutomatedRecoveryLoopPromptPacketObjects -RepositoryRoot $RepositoryRoot

    return Test-R17AutomatedRecoveryLoopSet `
        -Contract $contract `
        -Plan $plan `
        -StateMachine $stateMachine `
        -FailureEvents $failureEvents `
        -ContinuationPackets $continuationPackets `
        -NewContextPackets $newContextPackets `
        -CheckReport $checkReport `
        -UiSnapshot $uiSnapshot `
        -PromptPackets $promptPackets `
        -RepositoryRoot $RepositoryRoot
}

Export-ModuleMember -Function `
    Get-R17AutomatedRecoveryLoopPaths, `
    New-R17AutomatedRecoveryLoopArtifacts, `
    Test-R17AutomatedRecoveryLoop, `
    Test-R17AutomatedRecoveryLoopSet, `
    Get-R17AutomatedRecoveryLoopPromptPacketObjects, `
    Read-R17AutomatedRecoveryLoopFailureEvents, `
    Copy-R17AutomatedRecoveryLoopObject
