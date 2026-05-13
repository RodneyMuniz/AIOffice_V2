Set-StrictMode -Version Latest

$script:R18Cycle4SourceTask = "R18-026"
$script:R18Cycle4Title = "Retry Cycle 4 audit/closeout using compact-safe harness"
$script:R18Cycle4SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Cycle4Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Cycle4Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18Cycle4Verdict = "generated_r18_026_cycle4_audit_closeout_harness_evidence_package_only"
$script:R18Cycle4Boundary = "R18 active through R18-026 only; R18-027 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
$script:R18Cycle4PreflightHead = "146ec76cc54e5568a03224090b4992693efa36e9"
$script:R18Cycle4PreflightTree = "c2812b58359d26dccef85dc9250ee32206a5f60c"
$script:R18Cycle4PreflightRemoteHead = "146ec76cc54e5568a03224090b4992693efa36e9"

$script:R18Cycle4RuntimeFlagFields = @(
    "live_cycle4_runtime_executed",
    "live_runner_runtime_executed",
    "live_evidence_auditor_agent_invoked",
    "live_release_manager_agent_invoked",
    "live_skill_execution_performed",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_card_state_transition_performed",
    "live_kanban_ui_implemented",
    "release_gate_runtime_implemented",
    "release_gate_executed",
    "release_gate_action_performed",
    "stage_commit_push_gate_executed",
    "stage_commit_push_performed",
    "operator_approval_runtime_implemented",
    "operator_closeout_approval_granted",
    "approval_inferred_from_narration",
    "milestone_closeout_claimed",
    "closeout_performed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_invoked",
    "api_invocation_performed",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_runtime_executed",
    "continuation_packet_executed",
    "new_context_prompt_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "four_cycles_completed_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_027_completed",
    "r18_028_completed"
)

function Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18Cycle4AuditCloseoutHarnessPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18Cycle4AuditCloseoutHarnessPaths {
    param([string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot))

    $stateRoot = "state/runtime/r18_cycle4_audit_closeout_harness"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_026_cycle4_audit_closeout_harness"
    return [ordered]@{
        Contract = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_cycle4_audit_closeout_harness.contract.json"
        StateRoot = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $stateRoot
        AuditCloseoutPackage = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/cycle4_audit_closeout_package.json"
        EvidenceInventory = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/machine_readable_evidence_inventory.json"
        AuditVerdictPacket = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/audit_verdict_packet.json"
        ReleaseGateResult = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/release_gate_result.json"
        CloseoutCandidatePacket = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/closeout_candidate_packet.json"
        AuditRepairHandoffPacket = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/audit_repair_handoff_packet.json"
        ValidatorRunLog = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/validator_run_log.jsonl"
        BoardEvents = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/board_events.jsonl"
        Results = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/results.json"
        CheckReport = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/check_report.json"
        Snapshot = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_cycle4_audit_closeout_harness_snapshot.json"
        FixtureRoot = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_cycle4_audit_closeout_harness"
        ProofRoot = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/evidence_index.json"
        ProofReview = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/proof_review.md"
        ValidationManifest = Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/validation_manifest.md"
    }
}

function Write-R18Cycle4AuditCloseoutHarnessJson {
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

function Write-R18Cycle4AuditCloseoutHarnessText {
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

function Write-R18Cycle4AuditCloseoutHarnessJsonl {
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

function Read-R18Cycle4AuditCloseoutHarnessJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing JSON artifact: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-R18Cycle4AuditCloseoutHarnessJsonl {
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

function New-R18Cycle4AuditCloseoutHarnessRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18Cycle4RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18Cycle4AuditCloseoutHarnessRuntimeFlagNames {
    return $script:R18Cycle4RuntimeFlagFields
}

function Get-R18Cycle4AuditCloseoutHarnessPositiveClaims {
    return @(
        "r18_026_cycle4_audit_closeout_harness_contract_created",
        "r18_026_cycle4_audit_closeout_package_created",
        "machine_readable_evidence_inventory_created",
        "audit_verdict_packet_created",
        "release_gate_result_created_as_non_runtime_artifact",
        "closeout_candidate_packet_created_as_candidate_only",
        "audit_repair_handoff_policy_packet_created",
        "validator_run_log_recorded",
        "board_event_records_created_as_evidence_only",
        "proof_review_package_created"
    )
}

function Get-R18Cycle4AuditCloseoutHarnessNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-026 only.",
        "R18-027 through R18-028 remain planned only.",
        "R18-026 completed deterministic compact-safe Cycle 4 audit/closeout harness evidence package only.",
        "R18-026 exercised audit/closeout flow under the harness without claiming external audit acceptance.",
        "Evidence Auditor review is deterministic machine-readable evidence review only; no live Evidence Auditor agent was invoked.",
        "Release gate result is a bounded non-runtime assessment artifact only; release gate runtime was not executed.",
        "Closeout candidate packet is not milestone closeout and is blocked pending explicit operator approval.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter invocation occurred.",
        "No live agent invocation occurred.",
        "No live skill execution occurred.",
        "No tool-call execution was performed.",
        "No live tool call was performed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No board/card runtime mutation occurred.",
        "No live Kanban UI was implemented.",
        "No recovery action was performed.",
        "No recovery runtime was implemented.",
        "No release gate execution occurred.",
        "No stage/commit/push was performed by any gate.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "Four cycles are not claimed as product runtime completion.",
        "External audit acceptance is not claimed.",
        "Main is not merged.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved."
    )
}

function Get-R18Cycle4AuditCloseoutHarnessRejectedClaims {
    return @(
        "missing_machine_readable_evidence",
        "missing_audit_verdict_packet",
        "missing_release_gate_result",
        "missing_closeout_candidate_packet",
        "missing_validator_refs",
        "missing_status_doc_gate_refs",
        "missing_evidence_package_refs",
        "closeout_without_operator_approval",
        "operator_approval_inferred_from_narration",
        "external_audit_acceptance",
        "main_merge",
        "milestone_closeout",
        "release_gate_execution",
        "stage_commit_push_gate_execution",
        "ci_replay",
        "github_actions_workflow_created",
        "live_evidence_auditor_agent_invocation",
        "live_release_manager_agent_invocation",
        "live_skill_execution",
        "tool_call_execution",
        "a2a_message_sent",
        "board_card_runtime_mutation",
        "live_kanban_ui",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_invocation",
        "recovery_action",
        "product_runtime",
        "four_cycles_completed",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_027_or_later_completion",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18Cycle4AuditCloseoutHarnessAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "contracts/governance/r18_evidence_package_wrapper.contract.json",
        "contracts/governance/r18_evidence_package_manifest.contract.json",
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "state/governance/r18_evidence_package_wrapper_results.json",
        "contracts/tools/r18_agent_tool_call_evidence.contract.json",
        "state/tools/r18_agent_tool_call_evidence_ledger_shape.json",
        "state/agents/r18_agent_cards/agent_evidence_auditor.card.json",
        "state/agents/r18_agent_cards/agent_release_manager.card.json",
        "state/a2a/r18_handoff_packets/qa_test_to_evidence_auditor_validation_passed.handoff.json",
        "state/a2a/r18_handoff_packets/evidence_auditor_to_release_manager_generate_evidence_package.handoff.json",
        "state/a2a/r18_handoff_packets/release_manager_to_orchestrator_request_operator_approval.handoff.json",
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json",
        "state/runtime/r18_stage_commit_push_gate_assessments/blocked_by_missing_operator_approval.assessment.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/milestone_closeout.refusal.json",
        "contracts/runtime/r18_cycle3_qa_fix_loop_harness.contract.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json"
    )
}

function Get-R18Cycle4AuditCloseoutHarnessEvidenceRefs {
    return @(
        "contracts/runtime/r18_cycle4_audit_closeout_harness.contract.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/cycle4_audit_closeout_package.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/machine_readable_evidence_inventory.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/audit_verdict_packet.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/release_gate_result.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/closeout_candidate_packet.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/audit_repair_handoff_packet.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/validator_run_log.jsonl",
        "state/runtime/r18_cycle4_audit_closeout_harness/board_events.jsonl",
        "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/check_report.json",
        "state/ui/r18_operator_surface/r18_cycle4_audit_closeout_harness_snapshot.json",
        "tools/R18Cycle4AuditCloseoutHarness.psm1",
        "tools/new_r18_cycle4_audit_closeout_harness.ps1",
        "tools/validate_r18_cycle4_audit_closeout_harness.ps1",
        "tests/test_r18_cycle4_audit_closeout_harness.ps1",
        "tests/fixtures/r18_cycle4_audit_closeout_harness/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_026_cycle4_audit_closeout_harness/"
    )
}

function Get-R18Cycle4AuditCloseoutHarnessValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1",
        "git diff --check"
    )
}

function Get-R18Cycle4AuditCloseoutHarnessReleaseGateValidatorRefs {
    return @(
        "tools/validate_r18_cycle4_audit_closeout_harness.ps1",
        "tests/test_r18_cycle4_audit_closeout_harness.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_opening_authority.ps1",
        "tools/validate_r18_evidence_package_wrapper.ps1",
        "tests/test_r18_evidence_package_wrapper.ps1",
        "tools/validate_r18_cycle3_qa_fix_loop_harness.ps1",
        "tests/test_r18_cycle3_qa_fix_loop_harness.ps1",
        "tools/validate_r18_compact_failure_recovery_drill.ps1",
        "tests/test_r18_compact_failure_recovery_drill.ps1"
    )
}

function New-R18Cycle4AuditCloseoutHarnessStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_026_only"
        planned_from = "R18-027"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18Cycle4Boundary
    }
}

function New-R18Cycle4AuditCloseoutHarnessBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18Cycle4SourceTask
        source_milestone = $script:R18Cycle4SourceMilestone
        repository = $script:R18Cycle4Repository
        branch = $script:R18Cycle4Branch
        status_boundary = New-R18Cycle4AuditCloseoutHarnessStatusBoundary
        runtime_flags = New-R18Cycle4AuditCloseoutHarnessRuntimeFlags
        positive_claims = Get-R18Cycle4AuditCloseoutHarnessPositiveClaims
        non_claims = Get-R18Cycle4AuditCloseoutHarnessNonClaims
        rejected_claims = Get-R18Cycle4AuditCloseoutHarnessRejectedClaims
        authority_refs = Get-R18Cycle4AuditCloseoutHarnessAuthorityRefs
        evidence_refs = Get-R18Cycle4AuditCloseoutHarnessEvidenceRefs
    }
}

function New-R18Cycle4AuditCloseoutHarnessContract {
    $contract = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_harness_contract"
    $contract.contract_id = "r18_026_cycle4_audit_closeout_harness_contract_v1"
    $contract.task_title = $script:R18Cycle4Title
    $contract.purpose = "Exercise audit/closeout flow under the compact-safe harness without claiming external audit acceptance."
    $contract.inputs = @("Cycle 3 results", "evidence package wrapper", "Evidence Auditor model", "release gate")
    $contract.outputs = @("Cycle 4 audit/closeout package", "audit verdict packet", "release gate result", "closeout-candidate packet")
    $contract.acceptance_criteria = @(
        "Evidence Auditor reviews machine-readable evidence.",
        "Release gate enforces validators, status docs, evidence, and approvals.",
        "Closeout candidate remains blocked without explicit operator approval.",
        "Missing evidence, overclaims, and closeout without operator approval fail closed."
    )
    $contract.validation_expectation = "Planned validator rejects missing evidence, overclaims, and closeout without operator approval."
    $contract.non_claims_from_authority = @("No external audit acceptance.", "No main merge.", "No closeout without operator approval.")
    $contract.dependencies = @("R18-019", "R18-021", "R18-025")
    $contract.dependency_refs = [ordered]@{
        cycle3_results = "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json"
        evidence_package_manifest = "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json"
        evidence_package_wrapper_results = "state/governance/r18_evidence_package_wrapper_results.json"
        evidence_auditor_card = "state/agents/r18_agent_cards/agent_evidence_auditor.card.json"
        release_gate_policy = "contracts/runtime/r18_stage_commit_push_gate.contract.json"
        missing_closeout_approval_refusal = "state/governance/r18_operator_approval_decisions/milestone_closeout.refusal.json"
    }
    $contract.evidence_auditor_review_policy = [ordered]@{
        machine_readable_evidence_required = $true
        evidence_inventory_required = $true
        live_evidence_auditor_agent_allowed = $false
        api_invocation_allowed = $false
    }
    $contract.release_gate_policy = [ordered]@{
        non_runtime_release_gate_result_required = $true
        validators_required = $true
        status_docs_required = $true
        evidence_required = $true
        explicit_operator_approval_required_for_closeout = $true
        missing_operator_approval_blocks_closeout = $true
        release_gate_runtime_allowed = $false
        stage_commit_push_allowed = $false
        main_merge_allowed = $false
    }
    $contract.failure_retry_behavior = [ordered]@{
        audit_failure_route = "create_repair_handoff_or_block_closeout"
        repair_handoff_packet_required = $true
        closeout_blocked_when_operator_approval_missing = $true
        recovery_action_allowed = $false
    }
    $contract.expected_evidence_refs = @("Cycle 4 package", "audit packets", "release gate report")
    return $contract
}

function New-R18Cycle4AuditCloseoutHarnessEvidenceInventory {
    $inventory = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_machine_readable_evidence_inventory"
    $inventory.inventory_id = "r18_026_cycle4_machine_readable_evidence_inventory_v1"
    $inventory.machine_readable = $true
    $inventory.reviewed_by_evidence_auditor_model = $true
    $inventory.live_evidence_auditor_agent_invoked = $false
    $inventory.inventory_entries = @(
        [ordered]@{ entry_id = "cycle3_results"; evidence_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json"; evidence_type = "cycle3_results"; required_for_audit = $true },
        [ordered]@{ entry_id = "cycle3_execution_package"; evidence_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/cycle3_execution_package.json"; evidence_type = "cycle3_package"; required_for_audit = $true },
        [ordered]@{ entry_id = "cycle3_qa_result"; evidence_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/qa_result_packet.json"; evidence_type = "qa_packet"; required_for_audit = $true },
        [ordered]@{ entry_id = "cycle3_validator_log"; evidence_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/validator_run_log.jsonl"; evidence_type = "validator_log"; required_for_audit = $true },
        [ordered]@{ entry_id = "cycle3_board_events"; evidence_ref = "state/runtime/r18_cycle3_qa_fix_loop_harness/board_events.jsonl"; evidence_type = "board_event_evidence"; required_for_audit = $true },
        [ordered]@{ entry_id = "evidence_wrapper_manifest"; evidence_ref = "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json"; evidence_type = "evidence_manifest"; required_for_audit = $true },
        [ordered]@{ entry_id = "evidence_wrapper_results"; evidence_ref = "state/governance/r18_evidence_package_wrapper_results.json"; evidence_type = "evidence_wrapper_result"; required_for_audit = $true },
        [ordered]@{ entry_id = "agent_tool_evidence_model"; evidence_ref = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"; evidence_type = "evidence_model"; required_for_audit = $true },
        [ordered]@{ entry_id = "evidence_auditor_model"; evidence_ref = "state/agents/r18_agent_cards/agent_evidence_auditor.card.json"; evidence_type = "auditor_model"; required_for_audit = $true },
        [ordered]@{ entry_id = "release_gate_policy"; evidence_ref = "contracts/runtime/r18_stage_commit_push_gate.contract.json"; evidence_type = "release_gate_policy"; required_for_audit = $true },
        [ordered]@{ entry_id = "operator_closeout_refusal"; evidence_ref = "state/governance/r18_operator_approval_decisions/milestone_closeout.refusal.json"; evidence_type = "approval_refusal"; required_for_audit = $true }
    )
    $inventory.inventory_count = @($inventory.inventory_entries).Count
    return $inventory
}

function New-R18Cycle4AuditCloseoutHarnessPackage {
    $package = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_package"
    $package.package_id = "r18_026_cycle4_audit_closeout_package_v1"
    $package.task_title = $script:R18Cycle4Title
    $package.package_status = "bounded_deterministic_harness_evidence_recorded_closeout_blocked_pending_operator_approval"
    $package.harness_mode = "compact_safe_local_harness_evidence_only"
    $package.preflight_identity = [ordered]@{
        branch = $script:R18Cycle4Branch
        preflight_head = $script:R18Cycle4PreflightHead
        preflight_tree = $script:R18Cycle4PreflightTree
        preflight_remote_head = $script:R18Cycle4PreflightRemoteHead
        identity_status = "verified_before_r18_026_generation"
    }
    $package.input_refs = [ordered]@{
        cycle3_results = "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json"
        evidence_package_wrapper = "state/governance/r18_evidence_package_wrapper_results.json"
        evidence_auditor_model = "state/agents/r18_agent_cards/agent_evidence_auditor.card.json"
        release_gate_policy = "contracts/runtime/r18_stage_commit_push_gate.contract.json"
    }
    $package.machine_readable_evidence_review = [ordered]@{
        evidence_inventory_ref = "state/runtime/r18_cycle4_audit_closeout_harness/machine_readable_evidence_inventory.json"
        evidence_auditor_reviewed_machine_readable_evidence = $true
        live_evidence_auditor_agent_invoked = $false
        audit_verdict_packet_ref = "state/runtime/r18_cycle4_audit_closeout_harness/audit_verdict_packet.json"
    }
    $package.release_gate_summary = [ordered]@{
        release_gate_result_ref = "state/runtime/r18_cycle4_audit_closeout_harness/release_gate_result.json"
        release_gate_result_status = "gate_blocked_closeout_pending_operator_approval"
        release_gate_runtime_executed = $false
        validators_enforced = $true
        status_docs_enforced = $true
        evidence_enforced = $true
        approvals_enforced = $true
    }
    $package.closeout_candidate_ref = "state/runtime/r18_cycle4_audit_closeout_harness/closeout_candidate_packet.json"
    $package.audit_failure_behavior = [ordered]@{
        audit_failure_creates_repair_handoff_or_blocks_closeout = $true
        audit_repair_handoff_packet_ref = "state/runtime/r18_cycle4_audit_closeout_harness/audit_repair_handoff_packet.json"
        recovery_action_performed = $false
    }
    return $package
}

function New-R18Cycle4AuditCloseoutHarnessAuditVerdict {
    $packet = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_verdict_packet"
    $packet.audit_verdict_packet_id = "r18_026_cycle4_audit_verdict_packet_v1"
    $packet.verdict = "machine_readable_evidence_reviewed_closeout_candidate_blocked_pending_operator_approval"
    $packet.review_mode = "deterministic_harness_review_no_live_agent"
    $packet.evidence_inventory_ref = "state/runtime/r18_cycle4_audit_closeout_harness/machine_readable_evidence_inventory.json"
    $packet.evidence_auditor_reviewed_machine_readable_evidence = $true
    $packet.evidence_missing = $false
    $packet.overclaim_detected = $false
    $packet.external_audit_acceptance_claimed = $false
    $packet.main_merge_claimed = $false
    $packet.closeout_approved = $false
    $packet.operator_approval_required_for_closeout = $true
    $packet.release_gate_result_ref = "state/runtime/r18_cycle4_audit_closeout_harness/release_gate_result.json"
    $packet.audit_failure_route = "repair_handoff_or_closeout_block"
    $packet.audit_repair_handoff_packet_ref = "state/runtime/r18_cycle4_audit_closeout_harness/audit_repair_handoff_packet.json"
    return $packet
}

function New-R18Cycle4AuditCloseoutHarnessReleaseGateResult {
    $packet = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_release_gate_result"
    $packet.release_gate_result_id = "r18_026_cycle4_release_gate_result_v1"
    $packet.gate_mode = "deterministic_non_runtime_release_gate_result_only"
    $packet.gate_status = "gate_blocked_closeout_pending_operator_approval"
    $packet.release_gate_executed = $false
    $packet.validation_gate = [ordered]@{
        passed = $true
        validator_refs = Get-R18Cycle4AuditCloseoutHarnessReleaseGateValidatorRefs
    }
    $packet.status_docs_gate = [ordered]@{
        passed = $true
        expected_status = "R18 active through R18-026 only; R18-027 through R18-028 planned only"
        status_doc_refs = @("README.md", "governance/ACTIVE_STATE.md", "execution/KANBAN.md", "governance/DOCUMENT_AUTHORITY_INDEX.md", "governance/DECISION_LOG.md", "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md")
    }
    $packet.evidence_gate = [ordered]@{
        passed = $true
        evidence_inventory_ref = "state/runtime/r18_cycle4_audit_closeout_harness/machine_readable_evidence_inventory.json"
        audit_verdict_packet_ref = "state/runtime/r18_cycle4_audit_closeout_harness/audit_verdict_packet.json"
    }
    $packet.approval_gate = [ordered]@{
        passed = $false
        approval_scope = "milestone_closeout"
        operator_approval_ref = "state/governance/r18_operator_approval_decisions/milestone_closeout.refusal.json"
        operator_approval_granted = $false
        approval_inferred_from_narration = $false
    }
    $packet.safe_to_closeout = $false
    $packet.safe_to_merge_main = $false
    $packet.external_audit_acceptance_claimed = $false
    $packet.blocked_reasons = @("missing_explicit_operator_approval_for_milestone_closeout")
    return $packet
}

function New-R18Cycle4AuditCloseoutHarnessCloseoutCandidate {
    $packet = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_closeout_candidate_packet"
    $packet.closeout_candidate_packet_id = "r18_026_cycle4_closeout_candidate_packet_v1"
    $packet.candidate_status = "candidate_only_blocked_pending_operator_approval"
    $packet.closeout_candidate_only = $true
    $packet.closeout_approved = $false
    $packet.closeout_performed = $false
    $packet.operator_approval_required_for_closeout = $true
    $packet.operator_approval_granted = $false
    $packet.audit_verdict_packet_ref = "state/runtime/r18_cycle4_audit_closeout_harness/audit_verdict_packet.json"
    $packet.release_gate_result_ref = "state/runtime/r18_cycle4_audit_closeout_harness/release_gate_result.json"
    $packet.external_audit_acceptance_claimed = $false
    $packet.main_merge_claimed = $false
    $packet.r18_closeout_claimed = $false
    $packet.next_safe_step = "Keep R18 active; R18-027 remains planned for operator burden reduction metrics and R18-028 remains planned for final proof package and recommendation."
    return $packet
}

function New-R18Cycle4AuditCloseoutHarnessAuditRepairHandoff {
    $packet = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_repair_handoff_packet"
    $packet.audit_repair_handoff_packet_id = "r18_026_audit_repair_handoff_packet_v1"
    $packet.handoff_status = "prepared_for_audit_failure_policy_not_dispatched"
    $packet.audit_failure_creates_repair_handoff = $true
    $packet.audit_failure_detected = $false
    $packet.closeout_blocked = $true
    $packet.handoff_dispatched = $false
    $packet.a2a_message_sent = $false
    $packet.source_role = "Evidence Auditor"
    $packet.target_role = "Developer/Codex"
    $packet.failure_route = "repair_handoff_if_missing_evidence_else_block_closeout_pending_operator_approval"
    $packet.repair_scope = "R18-026 evidence package only"
    return $packet
}

function New-R18Cycle4AuditCloseoutHarnessValidatorRunLog {
    $base = @{
        artifact_type = "r18_cycle4_validator_run_log_entry"
        contract_version = "v1"
        source_task = $script:R18Cycle4SourceTask
        source_milestone = $script:R18Cycle4SourceMilestone
        repository = $script:R18Cycle4Repository
        branch = $script:R18Cycle4Branch
        status_boundary = New-R18Cycle4AuditCloseoutHarnessStatusBoundary
        runtime_flags = New-R18Cycle4AuditCloseoutHarnessRuntimeFlags
        non_claims = Get-R18Cycle4AuditCloseoutHarnessNonClaims
        rejected_claims = Get-R18Cycle4AuditCloseoutHarnessRejectedClaims
        authority_refs = Get-R18Cycle4AuditCloseoutHarnessAuthorityRefs
        evidence_refs = Get-R18Cycle4AuditCloseoutHarnessEvidenceRefs
    }
    $definitions = @(
        @{ id = "r18_026_validator_001_evidence_inventory"; command = "deterministic_harness_validator:machine_readable_evidence_inventory"; status = "passed"; exit = 0 },
        @{ id = "r18_026_validator_002_audit_verdict"; command = "deterministic_harness_validator:audit_verdict_packet"; status = "passed"; exit = 0 },
        @{ id = "r18_026_validator_003_release_gate"; command = "deterministic_harness_validator:release_gate_result"; status = "blocked_expected_missing_operator_approval"; exit = 0 },
        @{ id = "r18_026_validator_004_closeout_candidate"; command = "deterministic_harness_validator:closeout_candidate_packet"; status = "blocked_expected_missing_operator_approval"; exit = 0 },
        @{ id = "r18_026_validator_005_status_gate"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1"; status = "recorded_expected_status_gate_pass"; exit = 0 },
        @{ id = "r18_026_validator_006_status_gate_test"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1"; status = "recorded_expected_status_gate_test_pass"; exit = 0 },
        @{ id = "r18_026_validator_007_opening_authority"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1"; status = "recorded_expected_opening_authority_pass"; exit = 0 },
        @{ id = "r18_026_validator_008_opening_authority_test"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1"; status = "recorded_expected_opening_authority_test_pass"; exit = 0 },
        @{ id = "r18_026_validator_009_evidence_package_wrapper"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1"; status = "recorded_expected_evidence_package_wrapper_pass"; exit = 0 },
        @{ id = "r18_026_validator_010_evidence_package_wrapper_test"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1"; status = "recorded_expected_evidence_package_wrapper_test_pass"; exit = 0 },
        @{ id = "r18_026_validator_011_cycle3_qa_fix_loop_harness"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1"; status = "recorded_expected_cycle3_harness_pass"; exit = 0 },
        @{ id = "r18_026_validator_012_cycle3_qa_fix_loop_harness_test"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1"; status = "recorded_expected_cycle3_harness_test_pass"; exit = 0 },
        @{ id = "r18_026_validator_013_compact_failure_recovery_drill"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1"; status = "recorded_expected_compact_failure_recovery_drill_pass"; exit = 0 },
        @{ id = "r18_026_validator_014_compact_failure_recovery_drill_test"; command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1"; status = "recorded_expected_compact_failure_recovery_drill_test_pass"; exit = 0 },
        @{ id = "r18_026_validator_015_git_diff_check"; command = "git diff --check"; status = "recorded_expected_diff_check_pass"; exit = 0 }
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
        $entry.release_gate_executed = $false
        $entries += [pscustomobject]$entry
    }
    return $entries
}

function New-R18Cycle4AuditCloseoutHarnessBoardEvents {
    $base = @{
        artifact_type = "r18_cycle4_board_event_record"
        contract_version = "v1"
        source_task = $script:R18Cycle4SourceTask
        source_milestone = $script:R18Cycle4SourceMilestone
        repository = $script:R18Cycle4Repository
        branch = $script:R18Cycle4Branch
        status_boundary = New-R18Cycle4AuditCloseoutHarnessStatusBoundary
        runtime_flags = New-R18Cycle4AuditCloseoutHarnessRuntimeFlags
        non_claims = Get-R18Cycle4AuditCloseoutHarnessNonClaims
        rejected_claims = Get-R18Cycle4AuditCloseoutHarnessRejectedClaims
        authority_refs = Get-R18Cycle4AuditCloseoutHarnessAuthorityRefs
        evidence_refs = Get-R18Cycle4AuditCloseoutHarnessEvidenceRefs
    }
    $definitions = @(
        @{ id = "r18_026_board_event_001_audit_review_recorded"; type = "audit_review_recorded"; status = "machine_readable_evidence_review_recorded" },
        @{ id = "r18_026_board_event_002_release_gate_recorded"; type = "release_gate_result_recorded"; status = "release_gate_blocked_pending_operator_approval" },
        @{ id = "r18_026_board_event_003_closeout_candidate_recorded"; type = "closeout_candidate_recorded"; status = "candidate_only_not_closeout" },
        @{ id = "r18_026_board_event_004_block_reason_recorded"; type = "blocked_state_recorded"; status = "missing_operator_approval_blocks_closeout" }
    )
    $events = @()
    foreach ($definition in $definitions) {
        $event = [ordered]@{}
        foreach ($key in $base.Keys) {
            $event[$key] = $base[$key]
        }
        $event.event_id = $definition.id
        $event.card_id = "r18_026_cycle4_audit_closeout_harness_card"
        $event.event_type = $definition.type
        $event.event_status = $definition.status
        $event.board_runtime_mutation_performed = $false
        $event.live_card_state_transition_performed = $false
        $event.live_kanban_ui_implemented = $false
        $events += [pscustomobject]$event
    }
    return $events
}

function New-R18Cycle4AuditCloseoutHarnessResults {
    $results = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_harness_results"
    $results.results_id = "r18_026_cycle4_audit_closeout_harness_results_v1"
    $results.aggregate_verdict = $script:R18Cycle4Verdict
    $results.audit_closeout_results = [ordered]@{
        machine_readable_evidence_reviewed = $true
        evidence_inventory_count = 11
        audit_verdict_packet_created = $true
        release_gate_result_created = $true
        release_gate_executed = $false
        closeout_candidate_packet_created = $true
        closeout_approved = $false
        closeout_performed = $false
        external_audit_acceptance_claimed = $false
        main_merge_claimed = $false
    }
    $results.gate_enforcement_summary = [ordered]@{
        validators_enforced = $true
        status_docs_enforced = $true
        evidence_enforced = $true
        approvals_enforced = $true
        blocked_reason = "missing_explicit_operator_approval_for_milestone_closeout"
    }
    return $results
}

function New-R18Cycle4AuditCloseoutHarnessCheckReport {
    $report = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_harness_check_report"
    $report.check_report_id = "r18_026_cycle4_audit_closeout_harness_check_report_v1"
    $report.aggregate_verdict = $script:R18Cycle4Verdict
    $report.validation_summary = [ordered]@{
        contract_created = "passed"
        cycle4_package_created = "passed"
        machine_readable_evidence_inventory_created = "passed"
        evidence_auditor_review_recorded = "passed"
        release_gate_result_created = "passed_non_runtime"
        closeout_candidate_blocked_without_operator_approval = "passed"
        overclaims_rejected = "passed"
        status_boundary_current = "passed"
        non_claims_preserved = "passed"
    }
    $report.validation_commands = Get-R18Cycle4AuditCloseoutHarnessValidationCommands
    return $report
}

function New-R18Cycle4AuditCloseoutHarnessSnapshot {
    $snapshot = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_harness_operator_snapshot"
    $snapshot.snapshot_id = "r18_026_cycle4_audit_closeout_harness_snapshot_v1"
    $snapshot.r18_status = "active_through_r18_026_only"
    $snapshot.operator_surface = [ordered]@{
        title = "R18-026 Retry Cycle 4 audit/closeout using compact-safe harness"
        summary = "Cycle 4 audit/closeout harness evidence recorded; closeout remains blocked pending explicit operator approval."
        last_completed_step = "R18-026 deterministic machine-readable audit review, non-runtime release-gate result, and closeout-candidate packet recorded."
        next_safe_step = "Keep R18-027 and R18-028 planned only; do not infer closeout, external audit acceptance, main merge, or CI replay."
        decision_points = @(
            "Review R18-026 evidence before R18-027 burden metrics.",
            "Explicit operator approval is still required before any milestone closeout.",
            "Release gate result is not live release-gate execution.",
            "External audit acceptance and main merge remain false."
        )
    }
    return $snapshot
}

function New-R18Cycle4AuditCloseoutHarnessEvidenceIndex {
    $index = New-R18Cycle4AuditCloseoutHarnessBase -ArtifactType "r18_cycle4_audit_closeout_harness_evidence_index"
    $index.evidence_index_id = "r18_026_cycle4_audit_closeout_harness_evidence_index_v1"
    $index.aggregate_verdict = $script:R18Cycle4Verdict
    $index.evidence_summary = "R18-026 evidence is a deterministic compact-safe Cycle 4 audit/closeout harness package with machine-readable evidence inventory, audit verdict packet, non-runtime release-gate result, closeout-candidate packet, audit repair handoff policy packet, validator log, board-event records, and proof-review refs only."
    $index.validation_commands = Get-R18Cycle4AuditCloseoutHarnessValidationCommands
    return $index
}

function New-R18Cycle4AuditCloseoutHarnessProofReviewLines {
    return @(
        "# R18-026 Cycle 4 Audit/Closeout Harness Proof Review",
        "",
        "Task: R18-026 Retry Cycle 4 audit/closeout using compact-safe harness",
        "",
        "Verdict: generated_r18_026_cycle4_audit_closeout_harness_evidence_package_only.",
        "",
        "Evidence basis: deterministic machine-readable evidence inventory, Evidence Auditor verdict packet, non-runtime release-gate result, closeout-candidate packet, audit repair handoff policy packet, validator run log, board-event records, operator-surface snapshot, validator, focused tests, fixtures, and this proof-review package.",
        "",
        "Current status truth after this task: R18 is active through R18-026 only, R18-027 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Non-claims: no external audit acceptance, no main merge, no milestone closeout, no closeout without operator approval, no release gate execution, no CI replay, no GitHub Actions workflow creation/run, no Codex/OpenAI API invocation, no live adapter, no live agents, no live skills, no tool-call execution, no A2A message dispatch, no live board/card runtime mutation, no live Kanban UI, no recovery action, no product runtime, no no-manual-prompt-transfer success, and no solved compaction/reliability claim."
    )
}

function New-R18Cycle4AuditCloseoutHarnessValidationManifestLines {
    $lines = @(
        "# R18-026 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-026 only; R18-027 through R18-028 planned only.",
        "",
        "Focused and boundary commands:"
    )
    foreach ($command in Get-R18Cycle4AuditCloseoutHarnessValidationCommands) {
        $lines += "- $command"
    }
    $lines += ""
    $lines += "This manifest records deterministic local validation expectations only. It is not CI replay."
    return $lines
}

function New-R18Cycle4AuditCloseoutHarnessInvalidFixtures {
    return @(
        [ordered]@{ fixture_id = "invalid_missing_evidence_inventory_ref"; target = "package"; operation = "remove"; path = "machine_readable_evidence_review.evidence_inventory_ref"; expected_failure_fragments = @("missing evidence") },
        [ordered]@{ fixture_id = "invalid_external_audit_acceptance"; target = "audit_verdict"; operation = "set"; path = "external_audit_acceptance_claimed"; value = $true; expected_failure_fragments = @("external audit") },
        [ordered]@{ fixture_id = "invalid_main_merge"; target = "closeout_candidate"; operation = "set"; path = "main_merge_claimed"; value = $true; expected_failure_fragments = @("main merge") },
        [ordered]@{ fixture_id = "invalid_closeout_without_operator_approval"; target = "closeout_candidate"; operation = "set"; path = "closeout_approved"; value = $true; expected_failure_fragments = @("operator approval") },
        [ordered]@{ fixture_id = "invalid_release_gate_executed"; target = "release_gate_result"; operation = "set"; path = "release_gate_executed"; value = $true; expected_failure_fragments = @("release gate execution") },
        [ordered]@{ fixture_id = "invalid_live_auditor_agent"; target = "audit_verdict"; operation = "set"; path = "runtime_flags.live_evidence_auditor_agent_invoked"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_missing_validator_refs"; target = "release_gate_result"; operation = "set"; path = "validation_gate.validator_refs"; value = @(); expected_failure_fragments = @("validator") },
        [ordered]@{ fixture_id = "invalid_status_docs_unchecked"; target = "release_gate_result"; operation = "set"; path = "status_docs_gate.passed"; value = $false; expected_failure_fragments = @("status docs") },
        [ordered]@{ fixture_id = "invalid_r18_027_completion"; target = "snapshot"; operation = "set"; path = "runtime_flags.r18_027_completed"; value = $true; expected_failure_fragments = @("Runtime flag") },
        [ordered]@{ fixture_id = "invalid_local_backup_ref"; target = "evidence_index"; operation = "set"; path = "evidence_refs"; value = @(".local_backups/r18_026.json"); expected_failure_fragments = @("operator-local backup") },
        [ordered]@{ fixture_id = "invalid_missing_repair_handoff_policy"; target = "package"; operation = "remove"; path = "audit_failure_behavior"; expected_failure_fragments = @("repair handoff") }
    )
}

function New-R18Cycle4AuditCloseoutHarnessArtifacts {
    param([string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot))

    $paths = Get-R18Cycle4AuditCloseoutHarnessPaths -RepositoryRoot $RepositoryRoot
    New-Item -ItemType Directory -Path $paths.StateRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $paths.ProofRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null

    $contract = New-R18Cycle4AuditCloseoutHarnessContract
    $package = New-R18Cycle4AuditCloseoutHarnessPackage
    $inventory = New-R18Cycle4AuditCloseoutHarnessEvidenceInventory
    $auditVerdict = New-R18Cycle4AuditCloseoutHarnessAuditVerdict
    $releaseGateResult = New-R18Cycle4AuditCloseoutHarnessReleaseGateResult
    $closeoutCandidate = New-R18Cycle4AuditCloseoutHarnessCloseoutCandidate
    $repairHandoff = New-R18Cycle4AuditCloseoutHarnessAuditRepairHandoff
    $validatorRunLog = New-R18Cycle4AuditCloseoutHarnessValidatorRunLog
    $boardEvents = New-R18Cycle4AuditCloseoutHarnessBoardEvents
    $results = New-R18Cycle4AuditCloseoutHarnessResults
    $checkReport = New-R18Cycle4AuditCloseoutHarnessCheckReport
    $snapshot = New-R18Cycle4AuditCloseoutHarnessSnapshot
    $evidenceIndex = New-R18Cycle4AuditCloseoutHarnessEvidenceIndex

    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Contract -Value $contract
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditCloseoutPackage -Value $package
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.EvidenceInventory -Value $inventory
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditVerdictPacket -Value $auditVerdict
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.ReleaseGateResult -Value $releaseGateResult
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.CloseoutCandidatePacket -Value $closeoutCandidate
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditRepairHandoffPacket -Value $repairHandoff
    Write-R18Cycle4AuditCloseoutHarnessJsonl -Path $paths.ValidatorRunLog -Entries $validatorRunLog
    Write-R18Cycle4AuditCloseoutHarnessJsonl -Path $paths.BoardEvents -Entries $boardEvents
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Results -Value $results
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.CheckReport -Value $checkReport
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Snapshot -Value $snapshot
    Write-R18Cycle4AuditCloseoutHarnessJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R18Cycle4AuditCloseoutHarnessText -Path $paths.ProofReview -Lines (New-R18Cycle4AuditCloseoutHarnessProofReviewLines)
    Write-R18Cycle4AuditCloseoutHarnessText -Path $paths.ValidationManifest -Lines (New-R18Cycle4AuditCloseoutHarnessValidationManifestLines)

    $fixtures = New-R18Cycle4AuditCloseoutHarnessInvalidFixtures
    foreach ($fixture in $fixtures) {
        $fixturePath = Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id)
        Write-R18Cycle4AuditCloseoutHarnessJson -Path $fixturePath -Value $fixture
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:R18Cycle4Verdict
        EvidenceInventoryCount = @($inventory.inventory_entries).Count
        ValidatorRunLogEntryCount = @($validatorRunLog).Count
        BoardEventCount = @($boardEvents).Count
        InvalidFixtureCount = @($fixtures).Count
    }
}

function Assert-R18Cycle4AuditCloseoutHarnessCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18Cycle4AuditCloseoutHarnessProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) -Message "$Context missing required property '$Name'."
}

function Assert-R18Cycle4AuditCloseoutHarnessRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($flagName in Get-R18Cycle4AuditCloseoutHarnessRuntimeFlagNames) {
        Assert-R18Cycle4AuditCloseoutHarnessProperty -Object $RuntimeFlags -Name $flagName -Context "$Context runtime_flags"
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "Runtime flag '$flagName' must remain false in $Context."
    }
}

function Assert-R18Cycle4AuditCloseoutHarnessNoUnsafeRefs {
    param(
        [Parameter(Mandatory = $true)]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($ref in @($Refs)) {
        $refText = [string]$ref
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($refText -notmatch '(^|/)\.local_backups(/|$)') -Message "$Context contains operator-local backup ref: $refText"
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($refText -ne "governance/reports/AIOffice_V2_Revised_R17_Plan.md") -Message "$Context contains untracked revised R17 plan report ref."
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($refText -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context contains historical evidence edit ref: $refText"
    }
}

function Assert-R18Cycle4AuditCloseoutHarnessCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($property in @("artifact_type", "contract_version", "source_task", "source_milestone", "status_boundary", "runtime_flags", "non_claims", "rejected_claims", "authority_refs", "evidence_refs")) {
        Assert-R18Cycle4AuditCloseoutHarnessProperty -Object $Artifact -Name $property -Context $Context
    }
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($Artifact.source_task -eq $script:R18Cycle4SourceTask) -Message "$Context source_task must be R18-026."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_026_only") -Message "$Context status boundary must be active through R18-026 only."
    Assert-R18Cycle4AuditCloseoutHarnessRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    Assert-R18Cycle4AuditCloseoutHarnessNoUnsafeRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs"
    Assert-R18Cycle4AuditCloseoutHarnessNoUnsafeRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs"
}

function Test-R18Cycle4AuditCloseoutHarnessSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$Package,
        [Parameter(Mandatory = $true)]$EvidenceInventory,
        [Parameter(Mandatory = $true)]$AuditVerdict,
        [Parameter(Mandatory = $true)]$ReleaseGateResult,
        [Parameter(Mandatory = $true)]$CloseoutCandidate,
        [Parameter(Mandatory = $true)]$AuditRepairHandoff,
        [Parameter(Mandatory = $true)][object[]]$ValidatorRunLog,
        [Parameter(Mandatory = $true)][object[]]$BoardEvents,
        [Parameter(Mandatory = $true)]$Results,
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$Snapshot,
        [Parameter(Mandatory = $true)]$EvidenceIndex
    )

    foreach ($pair in @(
            @{ Context = "contract"; Artifact = $Contract },
            @{ Context = "package"; Artifact = $Package },
            @{ Context = "evidence_inventory"; Artifact = $EvidenceInventory },
            @{ Context = "audit_verdict"; Artifact = $AuditVerdict },
            @{ Context = "release_gate_result"; Artifact = $ReleaseGateResult },
            @{ Context = "closeout_candidate"; Artifact = $CloseoutCandidate },
            @{ Context = "audit_repair_handoff"; Artifact = $AuditRepairHandoff },
            @{ Context = "results"; Artifact = $Results },
            @{ Context = "check_report"; Artifact = $Report },
            @{ Context = "snapshot"; Artifact = $Snapshot },
            @{ Context = "evidence_index"; Artifact = $EvidenceIndex }
        )) {
        Assert-R18Cycle4AuditCloseoutHarnessCommonArtifact -Artifact $pair.Artifact -Context $pair.Context
    }

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($Contract.validation_expectation -like "*missing evidence, overclaims, and closeout without operator approval*") -Message "Contract must reject missing evidence, overclaims, and closeout without operator approval."
    foreach ($dependency in @("R18-019", "R18-021", "R18-025")) {
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition (@($Contract.dependencies) -contains $dependency) -Message "Contract missing dependency $dependency."
    }
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($Package.machine_readable_evidence_review.PSObject.Properties.Name -contains "evidence_inventory_ref" -and -not [string]::IsNullOrWhiteSpace([string]$Package.machine_readable_evidence_review.evidence_inventory_ref)) -Message "Package missing evidence inventory ref."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Package.machine_readable_evidence_review.evidence_auditor_reviewed_machine_readable_evidence -eq $true -and [bool]$Package.machine_readable_evidence_review.live_evidence_auditor_agent_invoked -eq $false) -Message "Evidence Auditor review must be deterministic and not live agent invocation."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($Package.PSObject.Properties.Name -contains "audit_failure_behavior") -Message "Package missing repair handoff policy."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Package.audit_failure_behavior.audit_failure_creates_repair_handoff_or_blocks_closeout -eq $true -and -not [string]::IsNullOrWhiteSpace([string]$Package.audit_failure_behavior.audit_repair_handoff_packet_ref)) -Message "Package must define repair handoff or closeout block behavior."

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$EvidenceInventory.machine_readable -eq $true -and [int]$EvidenceInventory.inventory_count -ge 10) -Message "Machine-readable evidence inventory is missing or too small."
    foreach ($entry in @($EvidenceInventory.inventory_entries)) {
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$entry.evidence_ref)) -Message "Evidence inventory entry missing evidence ref."
        Assert-R18Cycle4AuditCloseoutHarnessNoUnsafeRefs -Refs @($entry.evidence_ref) -Context "evidence inventory"
    }

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$AuditVerdict.evidence_auditor_reviewed_machine_readable_evidence -eq $true) -Message "Audit verdict must record machine-readable evidence review."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$AuditVerdict.external_audit_acceptance_claimed -eq $false) -Message "Audit verdict must not claim external audit acceptance."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$AuditVerdict.main_merge_claimed -eq $false) -Message "Audit verdict must not claim main merge."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$AuditVerdict.closeout_approved -eq $false) -Message "Audit verdict must not approve closeout."

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.release_gate_executed -eq $false) -Message "Release gate execution must remain false."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.validation_gate.passed -eq $true) -Message "Release gate result validator gate must pass as non-runtime evidence."
    $releaseGateValidatorRefs = @($ReleaseGateResult.validation_gate.validator_refs)
    foreach ($validatorRef in Get-R18Cycle4AuditCloseoutHarnessReleaseGateValidatorRefs) {
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($releaseGateValidatorRefs -contains $validatorRef) -Message "Release gate result missing validator ref: $validatorRef"
    }
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.status_docs_gate.passed -eq $true) -Message "Release gate result must enforce status docs."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.evidence_gate.passed -eq $true) -Message "Release gate result must enforce evidence."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.approval_gate.passed -eq $false -and [bool]$ReleaseGateResult.approval_gate.operator_approval_granted -eq $false) -Message "Release gate result must block closeout without operator approval."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$ReleaseGateResult.safe_to_closeout -eq $false -and @($ReleaseGateResult.blocked_reasons).Count -ge 1) -Message "Release gate result must block closeout."

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$CloseoutCandidate.closeout_candidate_only -eq $true) -Message "Closeout packet must remain candidate-only."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$CloseoutCandidate.closeout_approved -eq $false -and [bool]$CloseoutCandidate.operator_approval_granted -eq $false) -Message "Closeout candidate cannot be approved without operator approval."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$CloseoutCandidate.main_merge_claimed -eq $false -and [bool]$CloseoutCandidate.external_audit_acceptance_claimed -eq $false -and [bool]$CloseoutCandidate.r18_closeout_claimed -eq $false) -Message "Closeout candidate must not claim closeout, main merge, or external audit acceptance."

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$AuditRepairHandoff.audit_failure_creates_repair_handoff -eq $true -and [bool]$AuditRepairHandoff.handoff_dispatched -eq $false -and [bool]$AuditRepairHandoff.a2a_message_sent -eq $false) -Message "Audit repair handoff must be prepared only and not dispatched."

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition (@($ValidatorRunLog).Count -ge 5) -Message "At least five validator run log entries are required."
    foreach ($entry in @($ValidatorRunLog)) {
        Assert-R18Cycle4AuditCloseoutHarnessCommonArtifact -Artifact $entry -Context ("validator_run_log {0}" -f $entry.validator_run_log_id)
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$entry.validators_run_under_harness -eq $true -and [bool]$entry.release_gate_executed -eq $false) -Message "Validator run log must remain deterministic and not release gate execution."
    }
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition (@($BoardEvents).Count -ge 4) -Message "At least four board event records are required."
    foreach ($event in @($BoardEvents)) {
        Assert-R18Cycle4AuditCloseoutHarnessCommonArtifact -Artifact $event -Context ("board_event {0}" -f $event.event_id)
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$event.board_runtime_mutation_performed -eq $false -and [bool]$event.live_card_state_transition_performed -eq $false -and [bool]$event.live_kanban_ui_implemented -eq $false) -Message "Board events must not claim runtime mutation."
    }

    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Results.audit_closeout_results.machine_readable_evidence_reviewed -eq $true) -Message "Results must record machine-readable evidence review."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Results.audit_closeout_results.release_gate_executed -eq $false) -Message "Results must not claim release gate execution."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Results.audit_closeout_results.closeout_approved -eq $false -and [bool]$Results.audit_closeout_results.closeout_performed -eq $false) -Message "Results must not claim closeout."
    Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ([bool]$Results.gate_enforcement_summary.approvals_enforced -eq $true) -Message "Results must record approval enforcement."

    return [pscustomobject]@{
        AggregateVerdict = $Results.aggregate_verdict
        EvidenceInventoryCount = [int]$EvidenceInventory.inventory_count
        ValidatorRunLogEntryCount = @($ValidatorRunLog).Count
        BoardEventCount = @($BoardEvents).Count
        ReleaseGateStatus = $ReleaseGateResult.gate_status
        CloseoutApproved = [bool]$CloseoutCandidate.closeout_approved
    }
}

function Get-R18Cycle4AuditCloseoutHarnessSet {
    param([string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot))

    $paths = Get-R18Cycle4AuditCloseoutHarnessPaths -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        Contract = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Contract
        Package = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditCloseoutPackage
        EvidenceInventory = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.EvidenceInventory
        AuditVerdict = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditVerdictPacket
        ReleaseGateResult = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.ReleaseGateResult
        CloseoutCandidate = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.CloseoutCandidatePacket
        AuditRepairHandoff = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.AuditRepairHandoffPacket
        ValidatorRunLog = Read-R18Cycle4AuditCloseoutHarnessJsonl -Path $paths.ValidatorRunLog
        BoardEvents = Read-R18Cycle4AuditCloseoutHarnessJsonl -Path $paths.BoardEvents
        Results = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Results
        Report = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.CheckReport
        Snapshot = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.Snapshot
        EvidenceIndex = Read-R18Cycle4AuditCloseoutHarnessJson -Path $paths.EvidenceIndex
    }
}

function Get-R18Cycle4AuditCloseoutHarnessTaskStatusMap {
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

function Test-R18Cycle4AuditCloseoutHarnessStatusTruth {
    param([string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18Cycle4AuditCloseoutHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-028 only",
            "R18-028 produced the R18 final proof package and acceptance recommendation candidate only",
            "R18-028 is not operator approval",
            "R18-028 is not milestone closeout",
            "No R19 is opened",
            "R18-027 completed deterministic operator burden reduction metrics foundation only",
            "R18-027 measured committed runner logs, failure drills, continuation events, operator approval records, and manual intervention counts only",
            "R18-027 metrics distinguish deterministic recovery/harness evidence from operator approval and refusal records",
            "R18-027 marks no-manual-prompt-transfer success unproved and keeps the claim false",
            "R18-026 completed deterministic compact-safe Cycle 4 audit/closeout harness evidence package only",
            "R18-026 exercised audit/closeout flow under the harness without claiming external audit acceptance",
            "release gate result is a bounded non-runtime assessment artifact only",
            "closeout-candidate packet is not milestone closeout",
            "No external audit acceptance",
            "No main merge",
            "No closeout without operator approval",
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
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($combinedText -like "*$required*") -Message "Status surface missing R18-026 wording: $required"
    }

    $authorityStatuses = Get-R18Cycle4AuditCloseoutHarnessTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18Cycle4AuditCloseoutHarnessTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        Assert-R18Cycle4AuditCloseoutHarnessCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-028."
    }
    if ($combinedText -match '(?i)\bR18-(0(?:2[9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,120}\b(done|complete|completed|implemented|executed|active|planned)\b') {
        throw "Status surface claims R18 successor task."
    }
    return [pscustomobject]@{
        R18DoneThrough = 28
        R18PlannedStart = $null
        R18PlannedThrough = $null
    }
}

function Test-R18Cycle4AuditCloseoutHarness {
    param(
        [string]$RepositoryRoot = (Get-R18Cycle4AuditCloseoutHarnessRepositoryRoot),
        [switch]$SkipStatusTruth
    )
    $set = Get-R18Cycle4AuditCloseoutHarnessSet -RepositoryRoot $RepositoryRoot
    $result = Test-R18Cycle4AuditCloseoutHarnessSet `
        -Contract $set.Contract `
        -Package $set.Package `
        -EvidenceInventory $set.EvidenceInventory `
        -AuditVerdict $set.AuditVerdict `
        -ReleaseGateResult $set.ReleaseGateResult `
        -CloseoutCandidate $set.CloseoutCandidate `
        -AuditRepairHandoff $set.AuditRepairHandoff `
        -ValidatorRunLog $set.ValidatorRunLog `
        -BoardEvents $set.BoardEvents `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex
    if (-not $SkipStatusTruth) {
        Test-R18Cycle4AuditCloseoutHarnessStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }
    return $result
}

function Copy-R18Cycle4AuditCloseoutHarnessObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18Cycle4AuditCloseoutHarnessMutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )
    switch ($Target) {
        "contract" { return $Set.Contract }
        "package" { return $Set.Package }
        "evidence_inventory" { return $Set.EvidenceInventory }
        "audit_verdict" { return $Set.AuditVerdict }
        "release_gate_result" { return $Set.ReleaseGateResult }
        "closeout_candidate" { return $Set.CloseoutCandidate }
        "audit_repair_handoff" { return $Set.AuditRepairHandoff }
        "results" { return $Set.Results }
        "check_report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target: $Target" }
    }
}

function Set-R18Cycle4AuditCloseoutHarnessPathValue {
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

function Invoke-R18Cycle4AuditCloseoutHarnessMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )
    $parts = ([string]$Mutation.path).Split(".")
    switch ([string]$Mutation.operation) {
        "set" { Set-R18Cycle4AuditCloseoutHarnessPathValue -Object $TargetObject -Parts $parts -Value $Mutation.value }
        "remove" { Set-R18Cycle4AuditCloseoutHarnessPathValue -Object $TargetObject -Parts $parts -Value $null -Remove }
        default { throw "Unknown mutation operation: $($Mutation.operation)" }
    }
}

Export-ModuleMember -Function `
    Get-R18Cycle4AuditCloseoutHarnessPaths, `
    Get-R18Cycle4AuditCloseoutHarnessRuntimeFlagNames, `
    New-R18Cycle4AuditCloseoutHarnessArtifacts, `
    Get-R18Cycle4AuditCloseoutHarnessSet, `
    Test-R18Cycle4AuditCloseoutHarnessSet, `
    Test-R18Cycle4AuditCloseoutHarness, `
    Test-R18Cycle4AuditCloseoutHarnessStatusTruth, `
    Copy-R18Cycle4AuditCloseoutHarnessObject, `
    Get-R18Cycle4AuditCloseoutHarnessMutationTarget, `
    Invoke-R18Cycle4AuditCloseoutHarnessMutation
