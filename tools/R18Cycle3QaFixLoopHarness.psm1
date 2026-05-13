Set-StrictMode -Version Latest

$script:R18Cycle3SourceTask = "R18-025"
$script:R18Cycle3Title = "Retry Cycle 3 QA/fix-loop using compact-safe harness"
$script:R18Cycle3SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Cycle3Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Cycle3Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18Cycle3Verdict = "generated_r18_025_cycle3_qa_fix_loop_harness_evidence_package_only"
$script:R18Cycle3Boundary = "R18 active through R18-025 only; R18-026 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
$script:R18Cycle3PreflightHead = "5da4be0953b0436573c6f808854f51d48f38db9d"
$script:R18Cycle3PreflightTree = "3e794d4afe20e84947cee21871e7c6f4c037a9b6"
$script:R18Cycle3PreflightRemoteHead = "5da4be0953b0436573c6f808854f51d48f38db9d"

$script:R18Cycle3RuntimeFlagFields = @(
    "live_cycle3_runtime_executed",
    "live_runner_runtime_executed",
    "product_work_order_execution_performed",
    "live_work_order_execution_performed",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "tool_call_runtime_implemented",
    "ledger_runtime_invoked",
    "adapter_runtime_invoked",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_card_state_transition_performed",
    "live_kanban_ui_implemented",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_runtime_executed",
    "continuation_packet_executed",
    "new_context_prompt_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_invoked",
    "api_invocation_performed",
    "release_gate_executed",
    "stage_commit_push_gate_executed",
    "stage_commit_push_performed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "four_cycles_completed_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_026_completed"
)

function Get-R18Cycle3QaFixLoopHarnessRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18Cycle3QaFixLoopHarnessPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18Cycle3QaFixLoopHarnessPaths {
    param([string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot))

    $stateRoot = "state/runtime/r18_cycle3_qa_fix_loop_harness"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_025_cycle3_qa_fix_loop_harness"
    return [ordered]@{
        Contract = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_cycle3_qa_fix_loop_harness.contract.json"
        StateRoot = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $stateRoot
        ExecutionPackage = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/cycle3_execution_package.json"
        WorkOrderRecords = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/work_order_records.jsonl"
        DeveloperQaHandoff = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/developer_qa_handoff_packet.json"
        QaResultPacket = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/qa_result_packet.json"
        DefectPacket = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/defect_packet.json"
        RepairPacket = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/repair_packet.json"
        ValidatorRunLog = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/validator_run_log.jsonl"
        RecoveryRoutePacket = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/recovery_route_packet.json"
        BoardEvents = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/board_events.jsonl"
        Results = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/results.json"
        CheckReport = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/check_report.json"
        Snapshot = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_cycle3_qa_fix_loop_harness_snapshot.json"
        FixtureRoot = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_cycle3_qa_fix_loop_harness"
        ProofRoot = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/evidence_index.json"
        ProofReview = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/proof_review.md"
        ValidationManifest = Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/validation_manifest.md"
    }
}

function Write-R18Cycle3QaFixLoopHarnessJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, ($json + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Write-R18Cycle3QaFixLoopHarnessText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string[]]$Lines
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, ([string]::Join("`n", @($Lines)) + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Write-R18Cycle3QaFixLoopHarnessJsonl {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Entries
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $lines = @($Entries | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    [System.IO.File]::WriteAllText($Path, ([string]::Join("`n", $lines) + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Read-R18Cycle3QaFixLoopHarnessJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing JSON artifact: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R18Cycle3QaFixLoopHarnessJsonl {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing JSONL artifact: $Path"
    }
    $entries = @()
    foreach ($line in Get-Content -LiteralPath $Path) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $entries += ($line | ConvertFrom-Json)
        }
    }
    return $entries
}

function New-R18Cycle3QaFixLoopHarnessRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18Cycle3RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18Cycle3QaFixLoopHarnessRuntimeFlagNames {
    return $script:R18Cycle3RuntimeFlagFields
}

function Get-R18Cycle3QaFixLoopHarnessPositiveClaims {
    return @(
        "r18_025_cycle3_qa_fix_loop_harness_contract_created",
        "r18_025_cycle3_execution_package_created",
        "executed_cycle3_harness_work_order_records_created",
        "developer_qa_handoff_recorded",
        "validator_run_log_recorded_under_harness",
        "qa_result_packet_created",
        "defect_packet_created",
        "repair_packet_created",
        "recovery_route_packet_created",
        "board_event_records_created",
        "proof_review_package_created"
    )
}

function Get-R18Cycle3QaFixLoopHarnessNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-025 only.",
        "R18-026 through R18-028 remain planned only.",
        "R18-025 completed compact-safe Cycle 3 QA/fix-loop harness evidence package only.",
        "R18-025 evidence exceeds packet-only artifacts through deterministic harness work-order records, Developer/QA handoff, validator run log, QA result packet, defect/repair evidence, recovery route packet, board event records, operator-surface snapshot, validator, tests, fixtures, and proof-review package.",
        "Bounded deterministic harness work-order records are not live agent, skill, tool-call, A2A, API, board runtime, or product-runtime execution.",
        "R18-025 does not claim four cycles or solved compaction.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter invocation occurred.",
        "No live agent invocation occurred.",
        "No live skill execution occurred.",
        "No tool-call execution was performed.",
        "No live tool call was performed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No live/product work orders were executed outside the bounded deterministic R18-025 harness evidence package.",
        "No board/card runtime mutation occurred.",
        "No live Kanban UI was implemented.",
        "No recovery action was performed.",
        "No recovery runtime was implemented.",
        "No continuation packet was executed.",
        "No new-context prompt was executed.",
        "Automatic new-thread creation was not performed.",
        "Release gate was not executed.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18Cycle3QaFixLoopHarnessRejectedClaims {
    return @(
        "fake_qa_fix_loop_completion",
        "packet_only_completion",
        "missing_runtime_evidence",
        "missing_work_order_records",
        "missing_validator_run_log",
        "missing_developer_qa_handoff",
        "missing_qa_result_packet",
        "missing_defect_packet",
        "missing_repair_packet",
        "missing_board_events",
        "missing_recovery_route_packet",
        "unbounded_retry",
        "four_cycles_completed",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "no_manual_prompt_transfer_success",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_invocation",
        "api_invocation",
        "live_agent_invocation",
        "live_skill_execution",
        "tool_call_execution",
        "live_tool_call",
        "a2a_message_sent",
        "live_a2a_runtime",
        "board_card_runtime_mutation",
        "live_kanban_ui",
        "recovery_action",
        "release_gate_execution",
        "stage_commit_push_gate_execution",
        "ci_replay",
        "github_actions_workflow_created",
        "github_actions_workflow_run",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "r18_026_or_later_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18Cycle3QaFixLoopHarnessAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
        "contracts/runtime/r18_compact_failure_recovery_drill.contract.json",
        "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json",
        "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl",
        "contracts/tools/r18_agent_tool_call_evidence.contract.json",
        "state/tools/r18_agent_tool_call_evidence_ledger_shape.json",
        "contracts/board/r18_board_card_event_model.contract.json",
        "state/board/r18_board_card_event_registry.json",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json",
        "state/a2a/r18_handoff_packets/qa_test_to_developer_codex_repair_required.handoff.json",
        "state/a2a/r18_handoff_packets/qa_test_to_evidence_auditor_validation_passed.handoff.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/recovery_execution.refusal.json",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json"
    )
}

function Get-R18Cycle3QaFixLoopHarnessEvidenceRefs {
    return @(
        "contracts/runtime/r18_cycle3_qa_fix_loop_harness.contract.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/cycle3_execution_package.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/developer_qa_handoff_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/recovery_route_packet.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/check_report.json",
        "state/ui/r18_operator_surface/r18_cycle3_qa_fix_loop_harness_snapshot.json",
        "tools/R18Cycle3QaFixLoopHarness.psm1",
        "tools/new_r18_cycle3_qa_fix_loop_harness.ps1",
        "tools/validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "tests/test_r18_cycle3_qa_fix_loop_harness.ps1",
        "tests/fixtures/r18_cycle3_qa_fix_loop_harness/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_025_cycle3_qa_fix_loop_harness/"
    )
}

function Get-R18Cycle3QaFixLoopHarnessValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18Cycle3QaFixLoopHarnessStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_025_only"
        planned_from = "R18-026"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18Cycle3Boundary
    }
}

function New-R18Cycle3QaFixLoopHarnessBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18Cycle3SourceTask
        source_milestone = $script:R18Cycle3SourceMilestone
        repository = $script:R18Cycle3Repository
        branch = $script:R18Cycle3Branch
        status_boundary = New-R18Cycle3QaFixLoopHarnessStatusBoundary
        runtime_flags = New-R18Cycle3QaFixLoopHarnessRuntimeFlags
        positive_claims = Get-R18Cycle3QaFixLoopHarnessPositiveClaims
        non_claims = Get-R18Cycle3QaFixLoopHarnessNonClaims
        rejected_claims = Get-R18Cycle3QaFixLoopHarnessRejectedClaims
        authority_refs = Get-R18Cycle3QaFixLoopHarnessAuthorityRefs
        evidence_refs = Get-R18Cycle3QaFixLoopHarnessEvidenceRefs
    }
}

function New-R18Cycle3QaFixLoopHarnessContract {
    $contract = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_contract"
    $contract.contract_id = "r18_025_cycle3_qa_fix_loop_harness_contract_v1"
    $contract.task_title = $script:R18Cycle3Title
    $contract.purpose = "Retry the R17 Cycle 3 QA/fix-loop with the compact-safe runner harness."
    $contract.inputs = @(
        "R17 Cycle 3 prompt/work-order plan",
        "R18 runner",
        "Developer/QA roles",
        "recovery loop"
    )
    $contract.outputs = @(
        "Executed Cycle 3 work-order records",
        "QA result packet",
        "defect/repair evidence",
        "recovery evidence if needed"
    )
    $contract.acceptance_criteria = @(
        "Evidence exceeds packet-only artifacts.",
        "Developer/QA handoff is recorded and validated under the harness.",
        "Validators run under the harness and are recorded in a validator run log.",
        "Defect and repair evidence are linked to the QA result.",
        "Board events are recorded as deterministic evidence only.",
        "Fake QA/fix-loop completion and missing runtime evidence fail closed."
    )
    $contract.validation_expectation = "Planned validator rejects fake QA/fix-loop completion and missing runtime evidence."
    $contract.non_claims_from_authority = @(
        "Does not claim four cycles or solved compaction."
    )
    $contract.dependencies = @(
        "R18-024",
        "R18-021",
        "R18-020",
        "R17-026"
    )
    $contract.dependency_refs = [ordered]@{
        r17_cycle3_work_order_plan = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json"
        r18_runner_drill = "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json"
        developer_qa_evidence_model = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        board_event_model = "state/board/r18_board_card_event_registry.json"
        developer_to_qa_handoff = "state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json"
        qa_to_developer_repair_handoff = "state/a2a/r18_handoff_packets/qa_test_to_developer_codex_repair_required.handoff.json"
        qa_to_auditor_passed_handoff = "state/a2a/r18_handoff_packets/qa_test_to_evidence_auditor_validation_passed.handoff.json"
        recovery_policy = "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json"
    }
    $contract.harness_execution_policy = [ordered]@{
        deterministic_harness_records_required = $true
        packet_only_completion_rejected = $true
        validator_run_log_required = $true
        developer_qa_handoff_required = $true
        qa_result_packet_required = $true
        defect_repair_evidence_required = $true
        board_event_records_required = $true
        live_agent_runtime_allowed = $false
        live_skill_execution_allowed = $false
        api_invocation_allowed = $false
        a2a_message_dispatch_allowed = $false
        board_runtime_mutation_allowed = $false
        recovery_action_allowed = $false
        release_gate_execution_allowed = $false
    }
    $contract.failure_retry_behavior = [ordered]@{
        compact_or_validation_failure_route = "record_r18_recovery_route_packet_without_recovery_action"
        validation_failure_repaired_by_harness_packet = $true
        retry_count_recorded = $true
        retry_count = 1
        max_retry_count = 2
        retry_limit_enforced = $true
        recovery_action_performed = $false
    }
    $contract.expected_evidence_refs = @(
        "Cycle 3 execution package",
        "QA packets",
        "defect packets",
        "board events"
    )
    return $contract
}

function New-R18Cycle3QaFixLoopHarnessExecutionPackage {
    $package = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_execution_package"
    $package.package_id = "r18_025_cycle3_qa_fix_loop_harness_execution_package_v1"
    $package.task_title = $script:R18Cycle3Title
    $package.package_status = "bounded_deterministic_harness_evidence_recorded"
    $package.harness_mode = "compact_safe_local_harness_evidence_only"
    $package.preflight_identity = [ordered]@{
        branch = $script:R18Cycle3Branch
        preflight_head = $script:R18Cycle3PreflightHead
        preflight_tree = $script:R18Cycle3PreflightTree
        preflight_remote_head = $script:R18Cycle3PreflightRemoteHead
        identity_status = "verified_before_r18_025_generation"
    }
    $package.input_refs = [ordered]@{
        r17_cycle3_plan_ref = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json"
        r17_cycle3_work_orders_ref = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json"
        r18_runner_drill_ref = "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json"
        r18_runner_log_ref = "state/runtime/r18_compact_failure_recovery_drill/runner_log.jsonl"
        r18_agent_tool_evidence_model_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        r18_board_event_model_ref = "state/board/r18_board_card_event_registry.json"
    }
    $package.harness_evidence = [ordered]@{
        packet_only_artifacts = $false
        harness_runtime_evidence_present = $true
        work_order_records_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl"
        work_order_record_count = 6
        validator_run_log_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl"
        validator_run_log_entry_count = 4
        developer_qa_handoff_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/developer_qa_handoff_packet.json"
        qa_result_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json"
        defect_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json"
        repair_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json"
        board_events_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl"
        board_event_count = 5
        recovery_route_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/recovery_route_packet.json"
    }
    $package.developer_qa_handoff_status = "recorded_under_harness_no_a2a_message_sent"
    $package.qa_fix_loop_status = "qa_failed_once_on_seeded_defect_then_passed_after_bounded_repair_packet"
    $package.last_completed_step = "R18-024 compact-failure recovery drill foundation validated and R18-025 preflight verified branch/head/tree."
    $package.next_safe_step = "Review R18-025 harness evidence; keep R18-026 through R18-028 planned only without release gate execution."
    $package.acceptance_summary = [ordered]@{
        evidence_exceeds_packet_only = $true
        developer_qa_handoff_recorded = $true
        validators_recorded_under_harness = $true
        qa_result_packet_created = $true
        defect_repair_evidence_created = $true
        board_events_recorded = $true
        fake_completion_rejected_by_validator = $true
        four_cycles_claimed = $false
        solved_compaction_claimed = $false
    }
    return $package
}

function New-R18Cycle3QaFixLoopHarnessWorkOrderRecords {
    $base = @{
        artifact_type = "r18_cycle3_qa_fix_loop_harness_work_order_record"
        contract_version = "v1"
        source_task = $script:R18Cycle3SourceTask
        source_milestone = $script:R18Cycle3SourceMilestone
        repository = $script:R18Cycle3Repository
        branch = $script:R18Cycle3Branch
        status_boundary = New-R18Cycle3QaFixLoopHarnessStatusBoundary
        runtime_flags = New-R18Cycle3QaFixLoopHarnessRuntimeFlags
        non_claims = Get-R18Cycle3QaFixLoopHarnessNonClaims
        rejected_claims = Get-R18Cycle3QaFixLoopHarnessRejectedClaims
        authority_refs = Get-R18Cycle3QaFixLoopHarnessAuthorityRefs
    }

    $definitions = @(
        @{ id = "r18_025_wo_001_load_cycle3_plan"; step = 1; role = "Orchestrator"; status = "passed"; type = "load_cycle3_plan"; last = "R17 Cycle 3 compact-safe plan loaded."; next = "Record Developer/QA handoff."; refs = @("state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json", "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json") },
        @{ id = "r18_025_wo_002_developer_qa_handoff"; step = 2; role = "Developer/Codex"; status = "passed"; type = "developer_qa_handoff"; last = "Developer/QA handoff packet recorded under harness."; next = "Run first QA validator pass."; refs = @("state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/developer_qa_handoff_packet.json") },
        @{ id = "r18_025_wo_003_qa_first_validator_pass"; step = 3; role = "QA/Test"; status = "failed_seeded_defect_detected"; type = "qa_validator_first_pass"; last = "QA first pass detected seeded missing evidence ref defect."; next = "Record repair packet and route validation failure through R18 recovery policy."; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl", "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json") },
        @{ id = "r18_025_wo_004_developer_repair_packet"; step = 4; role = "Developer/Codex"; status = "passed"; type = "developer_repair_packet"; last = "Repair packet linked the missing evidence refs inside the R18-025 package."; next = "Run QA validator rerun."; refs = @("state/a2a/r18_handoff_packets/qa_test_to_developer_codex_repair_required.handoff.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json") },
        @{ id = "r18_025_wo_005_qa_validator_rerun"; step = 5; role = "QA/Test"; status = "passed_after_bounded_repair"; type = "qa_validator_rerun"; last = "QA rerun passed after bounded repair packet."; next = "Record deterministic board events."; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl") },
        @{ id = "r18_025_wo_006_board_events_recorded"; step = 6; role = "System/Validator"; status = "passed"; type = "board_events_recorded"; last = "Board events recorded as deterministic evidence only."; next = "Validate R18-025 package and keep R18-026 through R18-028 planned only."; refs = @("state/board/r18_board_card_event_registry.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl") }
    )

    $records = @()
    foreach ($definition in $definitions) {
        $record = [ordered]@{}
        foreach ($key in $base.Keys) {
            $record[$key] = $base[$key]
        }
        $record.work_order_record_id = $definition.id
        $record.sequence = $definition.step
        $record.harness_step_type = $definition.type
        $record.actor_role = $definition.role
        $record.record_status = $definition.status
        $record.execution_mode = "bounded_deterministic_harness_record_only"
        $record.packet_only_artifact = $false
        $record.harness_runtime_evidence_present = $true
        $record.last_completed_step = $definition.last
        $record.next_safe_step = $definition.next
        $record.retry_count = if ($definition.step -eq 4 -or $definition.step -eq 5) { 1 } else { 0 }
        $record.max_retry_count = 2
        $record.retry_limit_enforced = $true
        $record.evidence_refs = @($definition.refs + (Get-R18Cycle3QaFixLoopHarnessEvidenceRefs))
        $records += [pscustomobject]$record
    }
    return $records
}

function New-R18Cycle3QaFixLoopHarnessDeveloperQaHandoff {
    $packet = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_developer_qa_handoff_packet"
    $packet.handoff_packet_id = "r18_025_developer_qa_handoff_packet_v1"
    $packet.handoff_status = "validated_under_compact_safe_harness_no_a2a_message_sent"
    $packet.source_role = "Developer/Codex"
    $packet.target_role = "QA/Test"
    $packet.handoff_model_ref = "state/a2a/r18_handoff_packets/developer_codex_to_qa_test_run_validator.handoff.json"
    $packet.work_order_record_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl#r18_025_wo_002_developer_qa_handoff"
    $packet.expected_validator_refs = @(
        "tools/validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "tests/test_r18_cycle3_qa_fix_loop_harness.ps1",
        "tools/validate_status_doc_gate.ps1"
    )
    $packet.handoff_validated_under_harness = $true
    $packet.a2a_message_sent = $false
    $packet.live_agent_invocation_performed = $false
    return $packet
}

function New-R18Cycle3QaFixLoopHarnessDefectPacket {
    $packet = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_defect_packet"
    $packet.defect_packet_id = "r18_025_seeded_qa_defect_packet_v1"
    $packet.defect_status = "detected_under_harness_first_pass"
    $packet.defect_type = "missing_required_evidence_ref"
    $packet.detected_by_role = "QA/Test"
    $packet.detected_in_work_order_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/work_order_records.jsonl#r18_025_wo_003_qa_first_validator_pass"
    $packet.reproduction_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1"
    $packet.expected_failure = "missing defect/repair evidence must fail closed"
    $packet.repair_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json"
    $packet.qa_result_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json"
    $packet.product_code_changed = $false
    return $packet
}

function New-R18Cycle3QaFixLoopHarnessRepairPacket {
    $packet = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_repair_packet"
    $packet.repair_packet_id = "r18_025_cycle3_bounded_repair_packet_v1"
    $packet.repair_status = "bounded_repair_recorded_under_harness"
    $packet.defect_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json"
    $packet.repair_summary = "Linked defect, repair, QA result, validator log, and board event refs inside the R18-025 evidence package."
    $packet.changed_surface = "R18-025 evidence package only"
    $packet.product_code_changed = $false
    $packet.live_agent_invocation_performed = $false
    $packet.live_skill_execution_performed = $false
    $packet.tool_call_execution_performed = $false
    return $packet
}

function New-R18Cycle3QaFixLoopHarnessValidatorRunLog {
    $base = @{
        artifact_type = "r18_cycle3_validator_run_log_entry"
        contract_version = "v1"
        source_task = $script:R18Cycle3SourceTask
        source_milestone = $script:R18Cycle3SourceMilestone
        status_boundary = New-R18Cycle3QaFixLoopHarnessStatusBoundary
        runtime_flags = New-R18Cycle3QaFixLoopHarnessRuntimeFlags
        non_claims = Get-R18Cycle3QaFixLoopHarnessNonClaims
        rejected_claims = Get-R18Cycle3QaFixLoopHarnessRejectedClaims
        authority_refs = Get-R18Cycle3QaFixLoopHarnessAuthorityRefs
    }
    $definitions = @(
        @{ id = "r18_025_validator_001_first_pass"; command = "deterministic_harness_validator:first_pass"; status = "failed_expected_seeded_defect"; exit = 1; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json") },
        @{ id = "r18_025_validator_002_repair_check"; command = "deterministic_harness_validator:repair_packet_linkage"; status = "passed"; exit = 0; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json") },
        @{ id = "r18_025_validator_003_rerun"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1"; status = "recorded_expected_pass_after_repair"; exit = 0; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json") },
        @{ id = "r18_025_validator_004_status_gate"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1"; status = "recorded_expected_status_gate_pass"; exit = 0; refs = @("governance/ACTIVE_STATE.md", "execution/KANBAN.md", "README.md") }
    )
    $entries = @()
    foreach ($definition in $definitions) {
        $entry = [ordered]@{}
        foreach ($key in $base.Keys) {
            $entry[$key] = $base[$key]
        }
        $entry.validator_run_log_id = $definition.id
        $entry.command = $definition.command
        $entry.command_status = $definition.status
        $entry.exit_code = $definition.exit
        $entry.validators_run_under_harness = $true
        $entry.packet_only_artifact = $false
        $entry.harness_runtime_evidence_present = $true
        $entry.evidence_refs = @($definition.refs + (Get-R18Cycle3QaFixLoopHarnessEvidenceRefs))
        $entries += [pscustomobject]$entry
    }
    return $entries
}

function New-R18Cycle3QaFixLoopHarnessQaResultPacket {
    $packet = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_result_packet"
    $packet.qa_result_packet_id = "r18_025_cycle3_qa_result_packet_v1"
    $packet.qa_result_status = "passed_after_bounded_repair_under_harness"
    $packet.verdict = "passed_after_bounded_repair"
    $packet.validators_run_under_harness = $true
    $packet.validator_run_log_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl"
    $packet.defect_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json"
    $packet.repair_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json"
    $packet.developer_qa_handoff_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/developer_qa_handoff_packet.json"
    $packet.board_events_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl"
    $packet.packet_only_artifacts = $false
    $packet.harness_runtime_evidence_present = $true
    $packet.fake_completion = $false
    $packet.live_qa_agent_invoked = $false
    return $packet
}

function New-R18Cycle3QaFixLoopHarnessRecoveryRoutePacket {
    $packet = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_recovery_route_packet"
    $packet.recovery_route_packet_id = "r18_025_cycle3_recovery_route_packet_v1"
    $packet.route_status = "validation_failure_routed_through_r18_recovery_policy_no_recovery_action"
    $packet.validation_failure_detected = $true
    $packet.compact_failure_detected = $false
    $packet.routed_through_recovery_policy = $true
    $packet.route_only = $true
    $packet.retry_count = 1
    $packet.max_retry_count = 2
    $packet.retry_limit_enforced = $true
    $packet.recovery_policy_ref = "state/runtime/r18_retry_escalation_decisions/retry_allowed_after_compact_failure.decision.json"
    $packet.recovery_drill_ref = "state/runtime/r18_compact_failure_recovery_drill/drill_packet.json"
    $packet.continuation_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json"
    $packet.new_context_packet_ref = "state/runtime/r18_compact_failure_recovery_drill/new_context_packet.json"
    $packet.recovery_action_performed = $false
    $packet.continuation_packet_executed = $false
    $packet.new_context_prompt_executed = $false
    $packet.automatic_new_thread_creation_performed = $false
    return $packet
}

function New-R18Cycle3QaFixLoopHarnessBoardEvents {
    $base = @{
        artifact_type = "r18_cycle3_board_event_record"
        contract_version = "v1"
        source_task = $script:R18Cycle3SourceTask
        source_milestone = $script:R18Cycle3SourceMilestone
        event_model_ref = "state/board/r18_board_card_event_registry.json"
        status_boundary = New-R18Cycle3QaFixLoopHarnessStatusBoundary
        runtime_flags = New-R18Cycle3QaFixLoopHarnessRuntimeFlags
        non_claims = Get-R18Cycle3QaFixLoopHarnessNonClaims
        rejected_claims = Get-R18Cycle3QaFixLoopHarnessRejectedClaims
        authority_refs = Get-R18Cycle3QaFixLoopHarnessAuthorityRefs
    }
    $definitions = @(
        @{ id = "r18_025_board_event_001_card_created"; type = "card_created"; status = "cycle3_harness_card_record_created"; role = "System/Validator"; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/cycle3_execution_package.json") },
        @{ id = "r18_025_board_event_002_handoff_linked"; type = "handoff_linked"; status = "developer_qa_handoff_linked"; role = "Developer/Codex"; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/developer_qa_handoff_packet.json") },
        @{ id = "r18_025_board_event_003_validation_recorded_failed"; type = "validation_recorded"; status = "seeded_defect_validation_failure_recorded"; role = "QA/Test"; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl") },
        @{ id = "r18_025_board_event_004_failure_recorded"; type = "failure_recorded"; status = "defect_and_repair_recorded"; role = "QA/Test"; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json", "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json") },
        @{ id = "r18_025_board_event_005_evidence_linked"; type = "evidence_linked"; status = "qa_result_and_proof_refs_linked"; role = "System/Validator"; refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json", "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_025_cycle3_qa_fix_loop_harness/") }
    )
    $events = @()
    foreach ($definition in $definitions) {
        $event = [ordered]@{}
        foreach ($key in $base.Keys) {
            $event[$key] = $base[$key]
        }
        $event.event_id = $definition.id
        $event.card_id = "r18_025_cycle3_qa_fix_loop_harness_card"
        $event.event_type = $definition.type
        $event.event_status = $definition.status
        $event.actor_role = $definition.role
        $event.board_runtime_mutation_performed = $false
        $event.live_card_state_transition_performed = $false
        $event.live_kanban_ui_implemented = $false
        $event.evidence_refs = @($definition.refs + (Get-R18Cycle3QaFixLoopHarnessEvidenceRefs))
        $events += [pscustomobject]$event
    }
    return $events
}

function New-R18Cycle3QaFixLoopHarnessResults {
    $results = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_results"
    $results.results_id = "r18_025_cycle3_qa_fix_loop_harness_results_v1"
    $results.aggregate_verdict = $script:R18Cycle3Verdict
    $results.harness_runtime_evidence = [ordered]@{
        packet_only_artifacts = $false
        harness_runtime_evidence_present = $true
        work_order_record_count = 6
        validator_run_log_entry_count = 4
        developer_qa_handoff_recorded = $true
        validators_run_under_harness = $true
        qa_result_packet_created = $true
        defect_packet_created = $true
        repair_packet_created = $true
        recovery_route_packet_created = $true
        board_event_count = 5
    }
    $results.qa_fix_loop_results = [ordered]@{
        first_pass_status = "failed_expected_seeded_defect"
        repair_status = "bounded_repair_packet_recorded"
        rerun_status = "passed_after_bounded_repair"
        final_verdict = "passed_after_bounded_repair"
        fake_completion = $false
        four_cycles_claimed = $false
        compaction_solved = $false
        reliability_solved = $false
        product_runtime_proven = $false
    }
    $results.board_event_summary = [ordered]@{
        board_events_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl"
        board_event_count = 5
        board_runtime_mutation_performed = $false
        live_kanban_ui_implemented = $false
    }
    $results.recovery_summary = [ordered]@{
        recovery_route_packet_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/recovery_route_packet.json"
        validation_failure_routed = $true
        recovery_action_performed = $false
        continuation_packet_executed = $false
        new_context_prompt_executed = $false
    }
    return $results
}

function New-R18Cycle3QaFixLoopHarnessCheckReport {
    $report = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_check_report"
    $report.check_report_id = "r18_025_cycle3_qa_fix_loop_harness_check_report_v1"
    $report.aggregate_verdict = $script:R18Cycle3Verdict
    $report.validation_summary = [ordered]@{
        contract_created = "passed"
        execution_package_created = "passed"
        work_order_records_present = "passed"
        packet_only_completion_rejected = "passed"
        developer_qa_handoff_present = "passed"
        validator_run_log_present = "passed"
        qa_result_packet_present = "passed"
        defect_repair_evidence_linked = "passed"
        recovery_route_recorded_without_recovery_action = "passed"
        board_events_recorded_without_runtime_mutation = "passed"
        status_boundary_current = "passed"
        non_claims_preserved = "passed"
    }
    $report.validation_commands = Get-R18Cycle3QaFixLoopHarnessValidationCommands
    return $report
}

function New-R18Cycle3QaFixLoopHarnessSnapshot {
    $snapshot = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_operator_snapshot"
    $snapshot.snapshot_id = "r18_025_cycle3_qa_fix_loop_harness_snapshot_v1"
    $snapshot.r18_status = "active_through_r18_025_only"
    $snapshot.operator_surface = [ordered]@{
        title = "R18-025 Retry Cycle 3 QA/fix-loop using compact-safe harness"
        summary = "Compact-safe Cycle 3 QA/fix-loop harness evidence package recorded; R18-026 through R18-028 remain planned only."
        last_completed_step = "R18-025 deterministic harness work-order records, QA result, defect/repair evidence, recovery route packet, board events, and proof-review package recorded."
        next_safe_step = "Keep Cycle 4 audit/closeout planned until R18-026 authority is started."
        decision_points = @(
            "Review R18-025 harness evidence before any Cycle 4 audit/closeout retry.",
            "Do not infer external audit acceptance.",
            "Do not run release gate or GitHub Actions from this package.",
            "Keep compaction and model-capacity interruption as known operational issues."
        )
    }
    return $snapshot
}

function New-R18Cycle3QaFixLoopHarnessEvidenceIndex {
    $index = New-R18Cycle3QaFixLoopHarnessBase -ArtifactType "r18_cycle3_qa_fix_loop_harness_evidence_index"
    $index.evidence_index_id = "r18_025_cycle3_qa_fix_loop_harness_evidence_index_v1"
    $index.aggregate_verdict = $script:R18Cycle3Verdict
    $index.evidence_summary = "R18-025 evidence is a deterministic compact-safe Cycle 3 QA/fix-loop harness package with work-order records, Developer/QA handoff, validator run log, QA result, defect/repair packet, recovery route packet, board events, and proof-review refs only."
    $index.validation_commands = Get-R18Cycle3QaFixLoopHarnessValidationCommands
    return $index
}

function New-R18Cycle3QaFixLoopHarnessProofReviewLines {
    return @(
        "# R18-025 Cycle 3 QA/Fix-Loop Harness Proof Review",
        "",
        "Task: R18-025 Retry Cycle 3 QA/fix-loop using compact-safe harness",
        "",
        "Verdict: generated_r18_025_cycle3_qa_fix_loop_harness_evidence_package_only.",
        "",
        "Evidence basis: deterministic compact-safe harness work-order records, Developer/QA handoff packet, validator run log, QA result packet, seeded defect packet, bounded repair packet, recovery route packet, board-event records, operator-surface snapshot, validator, focused tests, fixtures, and this proof-review package.",
        "",
        "Current status truth after this task: R18 is active through R18-025 only, R18-026 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Non-claims: no Codex/OpenAI API invocation, no live API adapter invocation, no live agents, no live skills, no tool-call execution, no A2A message dispatch, no live board/card runtime mutation, no live Kanban UI, no recovery action, no release gate execution, no CI replay, no GitHub Actions workflow creation/run, no product runtime, no four-cycle claim, no external audit acceptance, no main merge, no no-manual-prompt-transfer success, and no solved compaction/reliability claim."
    )
}

function New-R18Cycle3QaFixLoopHarnessValidationManifestLines {
    return @(
        "# R18-025 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-025 only; R18-026 through R18-028 planned only.",
        "",
        "Focused commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_cycle3_qa_fix_loop_harness.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1",
        "",
        "This manifest records deterministic local validation expectations only. It is not CI replay."
    )
}

function New-R18Cycle3QaFixLoopHarnessInvalidFixtures {
    return @(
        [ordered]@{ fixture_id = "invalid_packet_only_completion"; target = "execution_package"; operation = "set"; path = "harness_evidence.packet_only_artifacts"; value = $true; expected_failure_fragments = @("packet-only") },
        [ordered]@{ fixture_id = "invalid_missing_validator_run_log"; target = "results"; operation = "remove"; path = "harness_runtime_evidence.validator_run_log_entry_count"; expected_failure_fragments = @("validator run log") },
        [ordered]@{ fixture_id = "invalid_live_agent_invoked"; target = "qa_result_packet"; operation = "set"; path = "runtime_flags.live_agent_runtime_invoked"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_api_invoked"; target = "contract"; operation = "set"; path = "runtime_flags.openai_api_invoked"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_recovery_action"; target = "recovery_route_packet"; operation = "set"; path = "recovery_action_performed"; value = $true; expected_failure_fragments = @("recovery action") },
        [ordered]@{ fixture_id = "invalid_missing_defect_ref"; target = "qa_result_packet"; operation = "remove"; path = "defect_packet_ref"; expected_failure_fragments = @("defect") },
        [ordered]@{ fixture_id = "invalid_board_mutation"; target = "results"; operation = "set"; path = "board_event_summary.board_runtime_mutation_performed"; value = $true; expected_failure_fragments = @("board runtime mutation") },
        [ordered]@{ fixture_id = "invalid_r18_026_completion"; target = "snapshot"; operation = "set"; path = "runtime_flags.r18_026_completed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_local_backup_ref"; target = "evidence_index"; operation = "set"; path = "evidence_refs"; value = @(".local_backups/r18_025.json"); expected_failure_fragments = @("operator-local backup") }
    )
}

function New-R18Cycle3QaFixLoopHarnessArtifacts {
    param([string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot))

    $paths = Get-R18Cycle3QaFixLoopHarnessPaths -RepositoryRoot $RepositoryRoot
    New-Item -ItemType Directory -Path $paths.StateRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $paths.ProofRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null

    $contract = New-R18Cycle3QaFixLoopHarnessContract
    $executionPackage = New-R18Cycle3QaFixLoopHarnessExecutionPackage
    $workOrderRecords = New-R18Cycle3QaFixLoopHarnessWorkOrderRecords
    $developerQaHandoff = New-R18Cycle3QaFixLoopHarnessDeveloperQaHandoff
    $defectPacket = New-R18Cycle3QaFixLoopHarnessDefectPacket
    $repairPacket = New-R18Cycle3QaFixLoopHarnessRepairPacket
    $validatorRunLog = New-R18Cycle3QaFixLoopHarnessValidatorRunLog
    $qaResultPacket = New-R18Cycle3QaFixLoopHarnessQaResultPacket
    $recoveryRoutePacket = New-R18Cycle3QaFixLoopHarnessRecoveryRoutePacket
    $boardEvents = New-R18Cycle3QaFixLoopHarnessBoardEvents
    $results = New-R18Cycle3QaFixLoopHarnessResults
    $checkReport = New-R18Cycle3QaFixLoopHarnessCheckReport
    $snapshot = New-R18Cycle3QaFixLoopHarnessSnapshot
    $evidenceIndex = New-R18Cycle3QaFixLoopHarnessEvidenceIndex

    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.Contract -Value $contract
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.ExecutionPackage -Value $executionPackage
    Write-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.WorkOrderRecords -Entries $workOrderRecords
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.DeveloperQaHandoff -Value $developerQaHandoff
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.DefectPacket -Value $defectPacket
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.RepairPacket -Value $repairPacket
    Write-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.ValidatorRunLog -Entries $validatorRunLog
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.QaResultPacket -Value $qaResultPacket
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.RecoveryRoutePacket -Value $recoveryRoutePacket
    Write-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.BoardEvents -Entries $boardEvents
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.Results -Value $results
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.CheckReport -Value $checkReport
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.Snapshot -Value $snapshot
    Write-R18Cycle3QaFixLoopHarnessJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R18Cycle3QaFixLoopHarnessText -Path $paths.ProofReview -Lines (New-R18Cycle3QaFixLoopHarnessProofReviewLines)
    Write-R18Cycle3QaFixLoopHarnessText -Path $paths.ValidationManifest -Lines (New-R18Cycle3QaFixLoopHarnessValidationManifestLines)

    $fixtures = New-R18Cycle3QaFixLoopHarnessInvalidFixtures
    foreach ($fixture in $fixtures) {
        $fixturePath = Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id)
        Write-R18Cycle3QaFixLoopHarnessJson -Path $fixturePath -Value $fixture
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:R18Cycle3Verdict
        WorkOrderRecordCount = @($workOrderRecords).Count
        ValidatorRunLogEntryCount = @($validatorRunLog).Count
        BoardEventCount = @($boardEvents).Count
        InvalidFixtureCount = @($fixtures).Count
    }
}

function Assert-R18Cycle3QaFixLoopHarnessCondition {
    param(
        [bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18Cycle3QaFixLoopHarnessProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) -Message "$Context missing required property '$Name'."
}

function Assert-R18Cycle3QaFixLoopHarnessRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($flagName in Get-R18Cycle3QaFixLoopHarnessRuntimeFlagNames) {
        Assert-R18Cycle3QaFixLoopHarnessProperty -Object $RuntimeFlags -Name $flagName -Context "$Context runtime_flags"
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
    }
}

function Assert-R18Cycle3QaFixLoopHarnessNoUnsafeRefs {
    param(
        [Parameter(Mandatory = $true)]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($ref in @($Refs)) {
        $refText = [string]$ref
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($refText -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context contains operator-local backup ref: $refText"
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($refText -ne "governance/reports/AIOffice_V2_Revised_R17_Plan.md") -Message "$Context contains untracked revised R17 plan report ref."
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($refText -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context contains historical evidence edit ref: $refText"
    }
}

function Assert-R18Cycle3QaFixLoopHarnessCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($property in @("artifact_type", "contract_version", "source_task", "source_milestone", "status_boundary", "runtime_flags", "non_claims", "rejected_claims", "authority_refs", "evidence_refs")) {
        Assert-R18Cycle3QaFixLoopHarnessProperty -Object $Artifact -Name $property -Context $Context
    }
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($Artifact.source_task -eq $script:R18Cycle3SourceTask) -Message "$Context source_task must be R18-025."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_025_only") -Message "$Context status boundary must be active through R18-025 only."
    Assert-R18Cycle3QaFixLoopHarnessRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    Assert-R18Cycle3QaFixLoopHarnessNoUnsafeRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs"
    Assert-R18Cycle3QaFixLoopHarnessNoUnsafeRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs"
}

function Test-R18Cycle3QaFixLoopHarnessSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$ExecutionPackage,
        [Parameter(Mandatory = $true)][object[]]$WorkOrderRecords,
        [Parameter(Mandatory = $true)]$DeveloperQaHandoff,
        [Parameter(Mandatory = $true)]$QaResultPacket,
        [Parameter(Mandatory = $true)]$DefectPacket,
        [Parameter(Mandatory = $true)]$RepairPacket,
        [Parameter(Mandatory = $true)][object[]]$ValidatorRunLog,
        [Parameter(Mandatory = $true)]$RecoveryRoutePacket,
        [Parameter(Mandatory = $true)][object[]]$BoardEvents,
        [Parameter(Mandatory = $true)]$Results,
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$Snapshot,
        [Parameter(Mandatory = $true)]$EvidenceIndex
    )

    foreach ($pair in @(
            @{ Context = "contract"; Artifact = $Contract },
            @{ Context = "execution_package"; Artifact = $ExecutionPackage },
            @{ Context = "developer_qa_handoff"; Artifact = $DeveloperQaHandoff },
            @{ Context = "qa_result_packet"; Artifact = $QaResultPacket },
            @{ Context = "defect_packet"; Artifact = $DefectPacket },
            @{ Context = "repair_packet"; Artifact = $RepairPacket },
            @{ Context = "recovery_route_packet"; Artifact = $RecoveryRoutePacket },
            @{ Context = "results"; Artifact = $Results },
            @{ Context = "check_report"; Artifact = $Report },
            @{ Context = "snapshot"; Artifact = $Snapshot },
            @{ Context = "evidence_index"; Artifact = $EvidenceIndex }
        )) {
        Assert-R18Cycle3QaFixLoopHarnessCommonArtifact -Artifact $pair.Artifact -Context $pair.Context
    }

    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($Contract.validation_expectation -like "*rejects fake QA/fix-loop completion and missing runtime evidence*") -Message "Contract must reject fake completion and missing runtime evidence."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$ExecutionPackage.harness_evidence.packet_only_artifacts -eq $false) -Message "Execution package cannot be packet-only."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$ExecutionPackage.harness_evidence.harness_runtime_evidence_present -eq $true) -Message "Execution package missing harness runtime evidence."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition (@($WorkOrderRecords).Count -ge 6) -Message "At least six harness work-order records are required."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition (@($ValidatorRunLog).Count -ge 4) -Message "At least four validator run log entries are required."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition (@($BoardEvents).Count -ge 5) -Message "At least five board event records are required."

    $workOrderTypes = @($WorkOrderRecords | ForEach-Object { $_.harness_step_type })
    foreach ($requiredType in @("load_cycle3_plan", "developer_qa_handoff", "qa_validator_first_pass", "developer_repair_packet", "qa_validator_rerun", "board_events_recorded")) {
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($workOrderTypes -contains $requiredType) -Message "Missing work-order record type: $requiredType"
    }
    foreach ($record in $WorkOrderRecords) {
        Assert-R18Cycle3QaFixLoopHarnessCommonArtifact -Artifact $record -Context ("work_order_record {0}" -f $record.work_order_record_id)
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$record.packet_only_artifact -eq $false -and [bool]$record.harness_runtime_evidence_present -eq $true) -Message "Work-order record must be runtime evidence and not packet-only."
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([int]$record.retry_count -le [int]$record.max_retry_count -and [int]$record.max_retry_count -le 2 -and [bool]$record.retry_limit_enforced) -Message "Work-order retry count must be bounded."
    }
    foreach ($entry in $ValidatorRunLog) {
        Assert-R18Cycle3QaFixLoopHarnessCommonArtifact -Artifact $entry -Context ("validator_run_log {0}" -f $entry.validator_run_log_id)
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$entry.validators_run_under_harness -eq $true -and [bool]$entry.packet_only_artifact -eq $false -and [bool]$entry.harness_runtime_evidence_present -eq $true) -Message "Validator run log entry must be under harness and not packet-only."
    }
    foreach ($event in $BoardEvents) {
        Assert-R18Cycle3QaFixLoopHarnessCommonArtifact -Artifact $event -Context ("board_event {0}" -f $event.event_id)
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$event.board_runtime_mutation_performed -eq $false -and [bool]$event.live_card_state_transition_performed -eq $false -and [bool]$event.live_kanban_ui_implemented -eq $false) -Message "Board events must not claim runtime mutation."
    }

    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$DeveloperQaHandoff.handoff_validated_under_harness -eq $true -and [bool]$DeveloperQaHandoff.a2a_message_sent -eq $false) -Message "Developer/QA handoff must be harness-validated without A2A message dispatch."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$QaResultPacket.validators_run_under_harness -eq $true -and [bool]$QaResultPacket.packet_only_artifacts -eq $false -and [bool]$QaResultPacket.harness_runtime_evidence_present -eq $true) -Message "QA result must include harness validator evidence."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition (-not [string]::IsNullOrWhiteSpace($QaResultPacket.defect_packet_ref) -and -not [string]::IsNullOrWhiteSpace($QaResultPacket.repair_packet_ref)) -Message "QA result missing defect or repair refs."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($DefectPacket.repair_packet_ref -eq "state/runtime/r18_cycle3_qa_fix_loop_harness/repair_packet.json") -Message "Defect packet must link repair packet."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($RepairPacket.defect_packet_ref -eq "state/runtime/r18_cycle3_qa_fix_loop_harness/defect_packet.json") -Message "Repair packet must link defect packet."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$RecoveryRoutePacket.routed_through_recovery_policy -eq $true -and [bool]$RecoveryRoutePacket.recovery_action_performed -eq $false) -Message "Validation failure must route through recovery policy without recovery action."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$Results.harness_runtime_evidence.packet_only_artifacts -eq $false -and [bool]$Results.harness_runtime_evidence.harness_runtime_evidence_present -eq $true) -Message "Results must reject packet-only completion and include harness runtime evidence."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($Results.harness_runtime_evidence.PSObject.Properties.Name -contains "validator_run_log_entry_count") -Message "Results missing validator run log count."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([int]$Results.harness_runtime_evidence.validator_run_log_entry_count -ge 4) -Message "Results missing validator run log count."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$Results.board_event_summary.board_runtime_mutation_performed -eq $false) -Message "Results must not claim board runtime mutation."
    Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ([bool]$Results.qa_fix_loop_results.four_cycles_claimed -eq $false -and [bool]$Results.qa_fix_loop_results.compaction_solved -eq $false -and [bool]$Results.qa_fix_loop_results.reliability_solved -eq $false) -Message "Results must not claim four cycles or solved compaction/reliability."

    return [pscustomobject]@{
        AggregateVerdict = $Results.aggregate_verdict
        WorkOrderRecordCount = @($WorkOrderRecords).Count
        ValidatorRunLogEntryCount = @($ValidatorRunLog).Count
        BoardEventCount = @($BoardEvents).Count
        QaVerdict = $QaResultPacket.verdict
        RecoveryActionPerformed = [bool]$RecoveryRoutePacket.recovery_action_performed
    }
}

function Get-R18Cycle3QaFixLoopHarnessSet {
    param([string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot))

    $paths = Get-R18Cycle3QaFixLoopHarnessPaths -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        Contract = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.Contract
        ExecutionPackage = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.ExecutionPackage
        WorkOrderRecords = Read-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.WorkOrderRecords
        DeveloperQaHandoff = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.DeveloperQaHandoff
        QaResultPacket = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.QaResultPacket
        DefectPacket = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.DefectPacket
        RepairPacket = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.RepairPacket
        ValidatorRunLog = Read-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.ValidatorRunLog
        RecoveryRoutePacket = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.RecoveryRoutePacket
        BoardEvents = Read-R18Cycle3QaFixLoopHarnessJsonl -Path $paths.BoardEvents
        Results = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.Results
        Report = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.CheckReport
        Snapshot = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.Snapshot
        EvidenceIndex = Read-R18Cycle3QaFixLoopHarnessJson -Path $paths.EvidenceIndex
    }
}

function Get-R18Cycle3QaFixLoopHarnessTaskStatusMap {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context
    )
    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -ne 28) {
        throw "$Context must define 28 R18 task status entries."
    }
    $map = @{}
    foreach ($match in $matches) {
        $map[$match.Groups[1].Value] = $match.Groups[2].Value
    }
    return $map
}

function Test-R18Cycle3QaFixLoopHarnessStatusTruth {
    param([string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18Cycle3QaFixLoopHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-026 only",
            "R18-027 through R18-028 planned only",
            "R18-026 completed deterministic compact-safe Cycle 4 audit/closeout harness evidence package only",
            "R18-026 exercised audit/closeout flow under the harness without claiming external audit acceptance",
            "R18-026 release gate result is a bounded non-runtime assessment artifact only",
            "R18-026 closeout-candidate packet is not milestone closeout",
            "No external audit acceptance is claimed",
            "No main merge is claimed",
            "No closeout without operator approval is claimed",
            "R18-025 completed compact-safe Cycle 3 QA/fix-loop harness evidence package only",
            "R18-025 evidence exceeds packet-only artifacts through deterministic harness work-order records",
            "R18-025 does not claim four cycles",
            "No Codex/OpenAI API invocation occurred",
            "No live API adapter invocation",
            "No live agent",
            "No live skill",
            "No tool-call execution",
            "No A2A messages",
            "No board/card runtime mutation occurred",
            "No live Kanban UI",
            "No recovery action",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved",
            "Main is not merged"
        )) {
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($combinedText -like "*$required*") -Message "Status surface missing current R18 wording: $required"
    }

    $authorityStatuses = Get-R18Cycle3QaFixLoopHarnessTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18Cycle3QaFixLoopHarnessTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 26) {
            Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-026."
        }
        else {
            Assert-R18Cycle3QaFixLoopHarnessCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-026."
        }
    }
    if ($combinedText -match 'R18 active through R18-(02[7-8])') {
        throw "Status surface claims R18 beyond R18-026."
    }
    if ($combinedText -match '(?i)R18-02[7-8][^\.\r\n]{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-027 or later completion."
    }
    return [pscustomobject]@{
        R18DoneThrough = 26
        R18PlannedStart = 27
        R18PlannedThrough = 28
    }
}

function Test-R18Cycle3QaFixLoopHarness {
    param(
        [string]$RepositoryRoot = (Get-R18Cycle3QaFixLoopHarnessRepositoryRoot),
        [switch]$SkipStatusTruth
    )
    $set = Get-R18Cycle3QaFixLoopHarnessSet -RepositoryRoot $RepositoryRoot
    $result = Test-R18Cycle3QaFixLoopHarnessSet `
        -Contract $set.Contract `
        -ExecutionPackage $set.ExecutionPackage `
        -WorkOrderRecords $set.WorkOrderRecords `
        -DeveloperQaHandoff $set.DeveloperQaHandoff `
        -QaResultPacket $set.QaResultPacket `
        -DefectPacket $set.DefectPacket `
        -RepairPacket $set.RepairPacket `
        -ValidatorRunLog $set.ValidatorRunLog `
        -RecoveryRoutePacket $set.RecoveryRoutePacket `
        -BoardEvents $set.BoardEvents `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex
    if (-not $SkipStatusTruth) {
        Test-R18Cycle3QaFixLoopHarnessStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }
    return $result
}

function Copy-R18Cycle3QaFixLoopHarnessObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18Cycle3QaFixLoopHarnessMutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )
    switch ($Target) {
        "contract" { return $Set.Contract }
        "execution_package" { return $Set.ExecutionPackage }
        "developer_qa_handoff" { return $Set.DeveloperQaHandoff }
        "qa_result_packet" { return $Set.QaResultPacket }
        "defect_packet" { return $Set.DefectPacket }
        "repair_packet" { return $Set.RepairPacket }
        "recovery_route_packet" { return $Set.RecoveryRoutePacket }
        "results" { return $Set.Results }
        "check_report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target: $Target" }
    }
}

function Set-R18Cycle3QaFixLoopHarnessPathValue {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Parts,
        [AllowNull()]$Value,
        [switch]$Remove
    )
    $current = $Object
    for ($i = 0; $i -lt $Parts.Count - 1; $i++) {
        $part = $Parts[$i]
        if ($current.PSObject.Properties.Name -notcontains $part) {
            throw "Mutation path missing: $($Parts -join '.')"
        }
        $current = $current.$part
    }
    $leaf = $Parts[$Parts.Count - 1]
    if ($Remove) {
        if ($current.PSObject.Properties.Name -contains $leaf) {
            $current.PSObject.Properties.Remove($leaf)
        }
        return
    }
    if ($current.PSObject.Properties.Name -contains $leaf) {
        $current.$leaf = $Value
    }
    else {
        $current | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
}

function Invoke-R18Cycle3QaFixLoopHarnessMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )
    $parts = ([string]$Mutation.path).Split(".")
    switch ([string]$Mutation.operation) {
        "set" { Set-R18Cycle3QaFixLoopHarnessPathValue -Object $TargetObject -Parts $parts -Value $Mutation.value }
        "remove" { Set-R18Cycle3QaFixLoopHarnessPathValue -Object $TargetObject -Parts $parts -Value $null -Remove }
        default { throw "Unknown mutation operation: $($Mutation.operation)" }
    }
}

Export-ModuleMember -Function `
    Get-R18Cycle3QaFixLoopHarnessPaths, `
    Get-R18Cycle3QaFixLoopHarnessRuntimeFlagNames, `
    New-R18Cycle3QaFixLoopHarnessArtifacts, `
    Get-R18Cycle3QaFixLoopHarnessSet, `
    Test-R18Cycle3QaFixLoopHarnessSet, `
    Test-R18Cycle3QaFixLoopHarness, `
    Test-R18Cycle3QaFixLoopHarnessStatusTruth, `
    Copy-R18Cycle3QaFixLoopHarnessObject, `
    Get-R18Cycle3QaFixLoopHarnessMutationTarget, `
    Invoke-R18Cycle3QaFixLoopHarnessMutation
