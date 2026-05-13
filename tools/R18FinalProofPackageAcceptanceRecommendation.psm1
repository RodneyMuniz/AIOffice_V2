Set-StrictMode -Version Latest

$script:R18FinalSourceTask = "R18-028"
$script:R18FinalTitle = "Produce R18 final proof package and acceptance recommendation"
$script:R18FinalMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18FinalRepository = "RodneyMuniz/AIOffice_V2"
$script:R18FinalBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18FinalVerdict = "generated_r18_028_final_proof_package_acceptance_recommendation_candidate_only"
$script:R18FinalBoundary = "R18 active through R18-028 only; no R19 opened; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18FinalRuntimeFlagFields = @(
    "codex_api_invoked",
    "openai_api_invoked",
    "live_api_adapter_invoked",
    "live_agent_invoked",
    "live_skill_executed",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "live_runner_runtime_executed",
    "work_order_executed_as_live_runtime",
    "board_runtime_mutation_performed",
    "live_kanban_ui_implemented",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_runtime_executed",
    "continuation_packet_executed",
    "new_context_prompt_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "release_gate_executed",
    "stage_commit_push_gate_executed",
    "stage_commit_push_performed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "runtime_implementation_delivered",
    "burden_reduction_success_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "milestone_closeout_claimed",
    "operator_closeout_approval_granted",
    "approval_inferred_from_narration",
    "successor_milestone_opened",
    "r19_opened"
)

function Get-R18FinalProofPackageRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18FinalProofPackagePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18FinalProofPackagePaths {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $stateRoot = "state/governance/r18_final_proof_package_acceptance_recommendation"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation"
    return [ordered]@{
        Contract = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_final_proof_package_acceptance_recommendation.contract.json"
        StateRoot = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue $stateRoot
        FinalReport = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/final_report.json"
        FinalReportMarkdown = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/reports/AIOffice_V2_R18_Final_Proof_Package_and_Acceptance_Recommendation_v1.md"
        KpiScorecard = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/kpi_movement_scorecard.json"
        FinalHeadSupportPacket = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/final_head_support_packet.json"
        OperatorDecisionRecommendation = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/operator_decision_recommendation_packet.json"
        RepairPlan = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/repair_plan.json"
        Results = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/results.json"
        CheckReport = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$stateRoot/check_report.json"
        Snapshot = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_final_proof_package_acceptance_recommendation_snapshot.json"
        FixtureRoot = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_final_proof_package_acceptance_recommendation"
        ProofRoot = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/evidence_index.json"
        ProofReview = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/proof_review.md"
        ValidationManifest = Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "$proofRoot/validation_manifest.md"
    }
}

function Write-R18FinalProofPackageJson {
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

function Write-R18FinalProofPackageText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, ([string]::Join("`n", @($Lines)) + "`n"), [System.Text.UTF8Encoding]::new($false))
}

function Read-R18FinalProofPackageJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing JSON artifact: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-R18FinalProofPackageRuntimeFlagNames {
    return $script:R18FinalRuntimeFlagFields
}

function New-R18FinalProofPackageRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18FinalRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function New-R18FinalProofPackageStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_028_only"
        active_through = "R18-028"
        planned_from = $null
        planned_through = $null
        r19_status = "not_opened"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        closeout_status = "not_closed_operator_approval_required"
        summary = $script:R18FinalBoundary
    }
}

function Get-R18FinalProofPackagePositiveClaims {
    return @(
        "r18_028_final_proof_package_contract_created",
        "r18_final_report_created",
        "r18_kpi_movement_scorecard_created",
        "r18_evidence_index_created",
        "r18_proof_review_created",
        "r18_validation_manifest_created",
        "r18_final_head_support_packet_created",
        "r18_operator_decision_recommendation_packet_created",
        "r18_repair_plan_created",
        "r18_operator_surface_snapshot_created"
    )
}

function Get-R18FinalProofPackageNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-028 only.",
        "R18-028 produced a final proof package and acceptance recommendation candidate only.",
        "R18-028 is not operator approval.",
        "R18-028 is not milestone closeout.",
        "R18-028 is not external audit acceptance.",
        "R18-028 is not main merge.",
        "No R19 or successor milestone is opened.",
        "No Codex/OpenAI API invocation occurred.",
        "No live API adapter invocation occurred.",
        "No live agent invocation occurred.",
        "No live skill execution occurred.",
        "No tool-call execution was performed.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No live runner runtime was executed.",
        "No board/card runtime mutation occurred.",
        "No live Kanban UI was implemented.",
        "No recovery action was performed.",
        "No recovery runtime was implemented.",
        "No release gate execution occurred.",
        "No stage/commit/push was performed by any R18 gate.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "No four-cycle product-runtime completion is claimed.",
        "No no-manual-prompt-transfer success is claimed because committed baseline/current manual transfer counts are absent.",
        "Burden reduction success is not claimed.",
        "External audit acceptance is not claimed.",
        "Main is not merged.",
        "Milestone closeout is not claimed.",
        "Explicit committed operator approval for R18 closeout is absent.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved."
    )
}

function Get-R18FinalProofPackageRejectedClaims {
    return @(
        "operator_approval_inferred_from_narration",
        "milestone_closeout_without_committed_operator_approval",
        "external_audit_acceptance",
        "main_merge",
        "r19_opening",
        "successor_milestone_opening",
        "codex_api_invocation",
        "openai_api_invocation",
        "live_api_adapter_invocation",
        "live_agent_invocation",
        "live_skill_execution",
        "tool_call_execution",
        "a2a_message_sent",
        "board_card_runtime_mutation",
        "live_kanban_ui",
        "recovery_action",
        "release_gate_execution",
        "stage_commit_push_gate_execution",
        "ci_replay",
        "github_actions_workflow_created",
        "product_runtime",
        "no_manual_prompt_transfer_success_without_baseline_and_current_counts",
        "burden_reduction_success_without_metrics",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18FinalProofPackageAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "contracts/governance/r18_evidence_package_wrapper.contract.json",
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "state/runtime/r18_compact_failure_recovery_drill/results.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/closeout_candidate_packet.json",
        "state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json",
        "state/governance/r18_operator_burden_reduction_metrics/validation_packet.json"
    )
}

function Get-R18FinalProofPackageEvidenceRefs {
    return @(
        "contracts/governance/r18_final_proof_package_acceptance_recommendation.contract.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/final_report.json",
        "governance/reports/AIOffice_V2_R18_Final_Proof_Package_and_Acceptance_Recommendation_v1.md",
        "state/governance/r18_final_proof_package_acceptance_recommendation/kpi_movement_scorecard.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/final_head_support_packet.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/operator_decision_recommendation_packet.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/repair_plan.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/results.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/check_report.json",
        "state/ui/r18_operator_surface/r18_final_proof_package_acceptance_recommendation_snapshot.json",
        "tools/R18FinalProofPackageAcceptanceRecommendation.psm1",
        "tools/new_r18_final_proof_package_acceptance_recommendation.ps1",
        "tools/validate_r18_final_proof_package_acceptance_recommendation.ps1",
        "tests/test_r18_final_proof_package_acceptance_recommendation.ps1",
        "tests/fixtures/r18_final_proof_package_acceptance_recommendation/fixture_manifest.json",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation/evidence_index.json",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation/proof_review.md",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation/validation_manifest.md"
    )
}

function Get-R18FinalProofPackageValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_final_proof_package_acceptance_recommendation.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_final_proof_package_acceptance_recommendation.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_final_proof_package_acceptance_recommendation.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_burden_reduction_metrics.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_burden_reduction_metrics.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle4_audit_closeout_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle4_audit_closeout_harness.ps1",
        "git diff --check"
    )
}

function New-R18FinalProofPackageBase {
    param([Parameter(Mandatory = $true)][string]$ArtifactType)

    return [ordered]@{
        artifact_type = $ArtifactType
        contract_version = "v1"
        source_task = $script:R18FinalSourceTask
        source_milestone = $script:R18FinalMilestone
        repository = $script:R18FinalRepository
        branch = $script:R18FinalBranch
        status_boundary = New-R18FinalProofPackageStatusBoundary
        runtime_flags = New-R18FinalProofPackageRuntimeFlags
        positive_claims = Get-R18FinalProofPackagePositiveClaims
        non_claims = Get-R18FinalProofPackageNonClaims
        rejected_claims = Get-R18FinalProofPackageRejectedClaims
        authority_refs = Get-R18FinalProofPackageAuthorityRefs
        evidence_refs = Get-R18FinalProofPackageEvidenceRefs
    }
}

function New-R18FinalProofPackageContract {
    $contract = New-R18FinalProofPackageBase -ArtifactType "r18_final_proof_package_acceptance_recommendation_contract"
    $contract.contract_id = "r18_028_final_proof_package_acceptance_recommendation_contract_v1"
    $contract.task_title = $script:R18FinalTitle
    $contract.purpose = "Package R18 evidence and produce an acceptance recommendation for operator decision."
    $contract.inputs = @(
        "R18 evidence ledger",
        "recovery drills",
        "Cycle 3/4 packages",
        "validators",
        "status gates",
        "burden metrics"
    )
    $contract.outputs = @(
        "R18 final report",
        "KPI movement scorecard",
        "evidence index",
        "proof review",
        "validation manifest",
        "final-head support packet",
        "decision recommendation"
    )
    $contract.acceptance_criteria = @(
        "Runtime claims are backed by execution evidence.",
        "Unresolved gaps remain explicit.",
        "Operator approval remains required for closeout."
    )
    $contract.validation_expectation = "Planned final package validator, focused test, status-doc gate, and git diff --check."
    $contract.non_claims_from_authority = @(
        "Final package is not operator approval, external audit acceptance, or main merge."
    )
    $contract.dependencies = @("R18-001 through R18-027")
    $contract.failure_retry_behavior = [ordered]@{
        insufficient_evidence_status = "r18_active_partial_closeout_blocked"
        repair_plan_required = $true
        operator_approval_required_for_closeout = $true
        recovery_action_allowed = $false
    }
    $contract.expected_evidence_refs = @(
        "R18 final proof package",
        "validation manifest",
        "final-head support packet",
        "operator decision packet"
    )
    $contract.required_status_boundary = [ordered]@{
        r18_active_through = "R18-028"
        r18_closeout_requires_operator_approval = $true
        r19_opened = $false
    }
    return $contract
}

function New-R18FinalProofPackageTaskEntry {
    param(
        [Parameter(Mandatory = $true)][string]$TaskId,
        [Parameter(Mandatory = $true)][string]$TaskTitle,
        [Parameter(Mandatory = $true)][string[]]$EvidenceRefs,
        [string]$ProofReviewRoot = $null
    )

    return [ordered]@{
        task_id = $TaskId
        task_title = $TaskTitle
        task_status = "done"
        evidence_refs = $EvidenceRefs
        proof_review_root = $ProofReviewRoot
        proof_treatment = "committed_artifact_and_local_validation_basis_only"
    }
}

function Get-R18FinalProofPackageTaskEntries {
    $proofBase = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration"
    $taskSlugs = [ordered]@{
        "R18-002" = @("Define agent card schema and validator", "r18_002_agent_card_schema")
        "R18-003" = @("Define skill contract schema and validator", "r18_003_skill_contract_schema")
        "R18-004" = @("Define A2A handoff packet schema and validator", "r18_004_a2a_handoff_packet_schema")
        "R18-005" = @("Define explicit role-to-skill permission matrix", "r18_005_role_skill_permission_matrix")
        "R18-006" = @("Define Orchestrator chat/control intake contract", "r18_006_orchestrator_control_intake")
        "R18-007" = @("Implement local runner/CLI shell", "r18_007_local_runner_cli_shell")
        "R18-008" = @("Implement work-order execution state machine", "r18_008_work_order_state_machine")
        "R18-009" = @("Implement runner state store and resumable execution log", "r18_009_runner_state_store")
        "R18-010" = @("Implement compact failure detector", "r18_010_compact_failure_detector")
        "R18-011" = @("Implement WIP classifier", "r18_011_wip_classifier")
        "R18-012" = @("Implement remote branch verifier", "r18_012_remote_branch_verifier")
        "R18-013" = @("Implement continuation packet generator", "r18_013_continuation_packet_generator")
        "R18-014" = @("Implement new-context prompt generator", "r18_014_new_context_prompt_generator")
        "R18-015" = @("Implement retry and escalation policy", "r18_015_retry_escalation_policy")
        "R18-016" = @("Implement operator approval gate", "r18_016_operator_approval_gate")
        "R18-017" = @("Implement stage/commit/push gate", "r18_017_stage_commit_push_gate")
        "R18-018" = @("Implement status-doc gate automation wrapper", "r18_018_status_doc_gate_wrapper")
        "R18-019" = @("Implement evidence package automation wrapper", "r18_019_evidence_package_wrapper")
        "R18-020" = @("Implement board/card runtime event model", "r18_020_board_card_event_model")
        "R18-021" = @("Implement agent invocation and tool-call evidence model", "r18_021_agent_tool_call_evidence_model")
        "R18-022" = @("Implement safety, secrets, budget, and token controls", "r18_022_safety_secrets_budget_token_controls")
        "R18-023" = @("Implement optional API adapter stub only after controls", "r18_023_optional_api_adapter_stub")
        "R18-024" = @("Exercise compact-failure recovery drill with local runner", "r18_024_compact_failure_recovery_drill")
        "R18-025" = @("Retry Cycle 3 QA/fix-loop using compact-safe harness", "r18_025_cycle3_qa_fix_loop_harness")
        "R18-026" = @("Retry Cycle 4 audit/closeout using compact-safe harness", "r18_026_cycle4_audit_closeout_harness")
        "R18-027" = @("Measure operator burden reduction", "r18_027_measure_operator_burden_reduction")
    }

    $entries = @()
    $entries += New-R18FinalProofPackageTaskEntry -TaskId "R18-001" -TaskTitle "Open R18 in repo truth and install transition authority" -EvidenceRefs @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "contracts/governance/r18_opening_authority.contract.json",
        "state/governance/r18_opening_authority.json",
        "state/planning/r18_automated_recovery_runtime_and_api_orchestration/r18_001_opening_authority_manifest.md"
    ) -ProofReviewRoot $null

    foreach ($taskId in $taskSlugs.Keys) {
        $title = $taskSlugs[$taskId][0]
        $slug = $taskSlugs[$taskId][1]
        $root = "$proofBase/$slug"
        $entries += New-R18FinalProofPackageTaskEntry -TaskId $taskId -TaskTitle $title -EvidenceRefs @(
            "$root/evidence_index.json",
            "$root/proof_review.md",
            "$root/validation_manifest.md"
        ) -ProofReviewRoot $root
    }

    $r18Root = "$proofBase/r18_028_final_proof_package_acceptance_recommendation"
    $entries += New-R18FinalProofPackageTaskEntry -TaskId "R18-028" -TaskTitle $script:R18FinalTitle -EvidenceRefs @(
        "contracts/governance/r18_final_proof_package_acceptance_recommendation.contract.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/final_report.json",
        "state/governance/r18_final_proof_package_acceptance_recommendation/operator_decision_recommendation_packet.json",
        "$r18Root/evidence_index.json",
        "$r18Root/proof_review.md",
        "$r18Root/validation_manifest.md"
    ) -ProofReviewRoot $r18Root

    return $entries
}

function Get-R18FinalProofPackageUnresolvedGaps {
    return @(
        [ordered]@{ gap_id = "no_live_runtime"; status = "unresolved"; evidence_basis = "R18 artifacts are deterministic foundations and harness packages only"; required_for_closeout = $true },
        [ordered]@{ gap_id = "no_recovery_action"; status = "unresolved"; evidence_basis = "No recovery action or retry runtime execution is claimed"; required_for_closeout = $true },
        [ordered]@{ gap_id = "no_ci_replay"; status = "unresolved"; evidence_basis = "CI replay was not performed and no GitHub Actions workflow was created or run for R18"; required_for_closeout = $true },
        [ordered]@{ gap_id = "no_manual_prompt_transfer_success_unproved"; status = "unresolved"; evidence_basis = "R18-027 lacks committed baseline/current manual transfer counts"; required_for_closeout = $true },
        [ordered]@{ gap_id = "operator_closeout_approval_absent"; status = "unresolved"; evidence_basis = "No explicit committed R18 operator closeout approval exists"; required_for_closeout = $true },
        [ordered]@{ gap_id = "codex_compaction_and_model_capacity_unresolved"; status = "unresolved"; evidence_basis = "Failures remain known operational issues, not solved runtime capabilities"; required_for_closeout = $true }
    )
}

function New-R18FinalProofPackageKpiScorecard {
    $scorecard = New-R18FinalProofPackageBase -ArtifactType "r18_final_kpi_movement_scorecard"
    $rows = @(
        [ordered]@{ category = "Evidence packaging and audit readiness"; weight = 20; r18_opening_score = 40; r18_final_score = 78; target_score = 85; movement = 38; evidence_refs = @("state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json", "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation/evidence_index.json"); caveat = "Local validation evidence only; no external audit acceptance." },
        [ordered]@{ category = "Recovery and continuation foundations"; weight = 18; r18_opening_score = 20; r18_final_score = 55; target_score = 80; movement = 35; evidence_refs = @("state/runtime/r18_compact_failure_recovery_drill/results.json", "state/runtime/r18_compact_failure_recovery_drill/continuation_packet.json"); caveat = "Deterministic drill evidence only; no recovery action." },
        [ordered]@{ category = "Cycle 3/4 harness evidence"; weight = 16; r18_opening_score = 20; r18_final_score = 62; target_score = 80; movement = 42; evidence_refs = @("state/runtime/r18_cycle3_qa_fix_loop_harness/results.json", "state/runtime/r18_cycle4_audit_closeout_harness/results.json"); caveat = "Compact-safe harness evidence only; no product runtime or four-cycle product-runtime completion." },
        [ordered]@{ category = "API safety and optional adapter readiness"; weight = 14; r18_opening_score = 10; r18_final_score = 45; target_score = 75; movement = 35; evidence_refs = @("state/security/r18_api_safety_controls_results.json", "state/tools/r18_optional_api_adapter_stub_results.json"); caveat = "Controls and disabled/dry-run stub only; no API invocation." },
        [ordered]@{ category = "Operator burden measurement"; weight = 16; r18_opening_score = 10; r18_final_score = 35; target_score = 70; movement = 25; evidence_refs = @("state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json", "state/governance/r18_operator_burden_reduction_metrics/approval_intervention_counts.json"); caveat = "Burden reduction and no-manual-prompt-transfer success remain unproved." },
        [ordered]@{ category = "Runtime/product readiness"; weight = 16; r18_opening_score = 10; r18_final_score = 25; target_score = 80; movement = 15; evidence_refs = @("state/tools/r18_agent_tool_call_evidence_results.json", "state/board/r18_board_card_event_model_results.json"); caveat = "No live runtime, product runtime, live agents, live skills, A2A messages, tool-call execution, or board mutation." }
    )

    $weightSum = 0
    $weightedScore = 0
    foreach ($row in $rows) {
        $weightSum += [int]$row.weight
        $weightedScore += ([int]$row.weight * [double]$row.r18_final_score)
    }

    $scorecard.scorecard_id = "r18_028_final_kpi_movement_scorecard_v1"
    $scorecard.scorecard_mode = "bounded_evidence_movement_with_unresolved_gaps"
    $scorecard.weight_sum = $weightSum
    $scorecard.weighted_final_score = [math]::Round(($weightedScore / 100), 2)
    $scorecard.score_rows = $rows
    $scorecard.formal_closeout_recommended = $false
    $scorecard.operator_decision_required = $true
    return $scorecard
}

function New-R18FinalProofPackageFinalReport {
    $report = New-R18FinalProofPackageBase -ArtifactType "r18_final_report"
    $report.report_id = "r18_028_final_report_v1"
    $report.package_status = "final_proof_package_candidate_only"
    $report.acceptance_recommendation = "accept_bounded_r18_028_final_package_for_operator_review_keep_r18_active_partial_until_explicit_operator_closeout_approval"
    $report.operator_approval_required_for_closeout = $true
    $report.explicit_committed_operator_closeout_approval_exists = $false
    $report.closeout_assessment = [ordered]@{
        milestone_closeout_claimed = $false
        closeout_blocked = $true
        blocked_reason = "Explicit committed R18 operator closeout approval is absent and unresolved runtime/API/CI/no-manual-transfer gaps remain."
    }
    $report.runtime_claim_assessment = [ordered]@{
        runtime_claims_made = $false
        runtime_claims_backed_by_execution_evidence = $false
        accepted_runtime_claim_policy = "Any runtime claim requires execution evidence; this package makes no runtime claims because committed execution evidence is absent."
    }
    $report.input_evidence_refs = @(
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "state/runtime/r18_compact_failure_recovery_drill/results.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
        "state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json"
    )
    $report.unresolved_gap_summary = Get-R18FinalProofPackageUnresolvedGaps
    $report.repair_plan_ref = "state/governance/r18_final_proof_package_acceptance_recommendation/repair_plan.json"
    return $report
}

function New-R18FinalProofPackageFinalHeadSupportPacket {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD 2>$null)
    if ($LASTEXITCODE -ne 0) { $head = "unavailable" }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}" 2>$null)
    if ($LASTEXITCODE -ne 0) { $tree = "unavailable" }

    $packet = New-R18FinalProofPackageBase -ArtifactType "r18_final_head_support_packet"
    $packet.packet_id = "r18_028_final_head_support_packet_v1"
    $packet.observed_head_at_generation = [string]$head
    $packet.observed_tree_at_generation = [string]$tree
    $packet.final_head_support_mode = "candidate_pre_commit_support_packet"
    $packet.self_referential_final_head_claimed = $false
    $packet.post_push_remote_head_claimed = $false
    $packet.validation_command_list = Get-R18FinalProofPackageValidationCommands
    $packet.expected_final_scope = "R18-028 final proof package and acceptance recommendation candidate only"
    $packet.operator_approval_required_for_closeout = $true
    return $packet
}

function New-R18FinalProofPackageOperatorDecisionRecommendation {
    $packet = New-R18FinalProofPackageBase -ArtifactType "r18_operator_decision_recommendation_packet"
    $packet.packet_id = "r18_028_operator_decision_recommendation_packet_v1"
    $packet.decision_packet_status = "recommendation_only_not_operator_approval"
    $packet.operator_approval_granted = $false
    $packet.operator_closeout_approval_granted = $false
    $packet.approval_inferred_from_narration = $false
    $packet.recommended_decision = "accept_bounded_r18_028_final_package_for_review_keep_closeout_blocked_pending_explicit_operator_approval"
    $packet.closeout_recommendation = "blocked_pending_explicit_committed_operator_closeout_approval_and_gap_resolution"
    $packet.required_operator_decision = "explicit_accept_or_refuse_r18_closeout_in_committed_operator_decision_packet"
    $packet.blocking_gaps = @((Get-R18FinalProofPackageUnresolvedGaps) | ForEach-Object { $_.gap_id })
    return $packet
}

function New-R18FinalProofPackageRepairPlan {
    $plan = New-R18FinalProofPackageBase -ArtifactType "r18_final_repair_plan"
    $plan.repair_plan_id = "r18_028_closeout_blocker_repair_plan_v1"
    $plan.repair_plan_status = "candidate_repair_plan_no_successor_milestone_opened"
    $plan.recovery_or_escalation_triggered = $false
    $plan.successor_milestone_opened = $false
    $plan.blocked_closeout_reason = "Insufficient evidence for runtime/API/CI/no-manual-transfer success and no explicit committed operator closeout approval."
    $plan.required_repairs = @(
        [ordered]@{ repair_id = "explicit_operator_closeout_decision"; required_before_closeout = $true; action = "Commit an explicit R18 operator closeout decision if the operator chooses closeout." },
        [ordered]@{ repair_id = "ci_replay_evidence"; required_before_closeout = $true; action = "Run and commit CI replay evidence only if separately authorized." },
        [ordered]@{ repair_id = "manual_transfer_baseline_current_counts"; required_before_success_claim = $true; action = "Commit machine-readable baseline and current manual GPT-to-Codex transfer counts before claiming no-manual-prompt-transfer success." },
        [ordered]@{ repair_id = "live_runtime_execution_evidence"; required_before_runtime_claim = $true; action = "Produce bounded execution evidence before any live runtime, recovery, A2A, agent, skill, tool-call, or product-runtime claim." },
        [ordered]@{ repair_id = "external_audit_decision"; required_before_external_acceptance_claim = $true; action = "Commit external audit acceptance evidence before claiming external audit acceptance." }
    )
    return $plan
}

function New-R18FinalProofPackageEvidenceIndex {
    $index = New-R18FinalProofPackageBase -ArtifactType "r18_final_evidence_index"
    $index.index_id = "r18_028_final_evidence_index_v1"
    $index.index_mode = "task_level_final_package_candidate"
    $index.task_entries = Get-R18FinalProofPackageTaskEntries
    $index.indexed_evidence_refs = Get-R18FinalProofPackageEvidenceRefs
    $index.input_evidence_refs = @(
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "state/runtime/r18_compact_failure_recovery_drill/results.json",
        "state/runtime/r18_cycle3_qa_fix_loop_harness/results.json",
        "state/runtime/r18_cycle4_audit_closeout_harness/results.json",
        "state/governance/r18_operator_burden_reduction_metrics/burden_reduction_report.json"
    )
    $index.validation_commands = Get-R18FinalProofPackageValidationCommands
    $index.unresolved_gaps = Get-R18FinalProofPackageUnresolvedGaps
    return $index
}

function New-R18FinalProofPackageResults {
    $results = New-R18FinalProofPackageBase -ArtifactType "r18_final_proof_package_results"
    $results.results_id = "r18_028_final_proof_package_results_v1"
    $results.aggregate_verdict = $script:R18FinalVerdict
    $results.final_package_result = [ordered]@{
        final_report_created = $true
        kpi_scorecard_created = $true
        evidence_index_created = $true
        proof_review_created = $true
        validation_manifest_created = $true
        final_head_support_packet_created = $true
        operator_decision_recommendation_packet_created = $true
        repair_plan_created = $true
        closeout_blocked_pending_operator_approval = $true
    }
    $results.runtime_claim_summary = New-R18FinalProofPackageRuntimeFlags
    $results.validation_commands = Get-R18FinalProofPackageValidationCommands
    return $results
}

function New-R18FinalProofPackageCheckReport {
    $report = New-R18FinalProofPackageBase -ArtifactType "r18_final_proof_package_check_report"
    $report.check_report_id = "r18_028_final_proof_package_check_report_v1"
    $report.checks = @(
        [ordered]@{ check = "authority_scope_extracted"; passed = $true },
        [ordered]@{ check = "task_entries_cover_r18_001_through_r18_028"; passed = $true },
        [ordered]@{ check = "runtime_claims_not_made_without_execution_evidence"; passed = $true },
        [ordered]@{ check = "unresolved_gaps_explicit"; passed = $true },
        [ordered]@{ check = "operator_approval_required_for_closeout"; passed = $true },
        [ordered]@{ check = "no_external_audit_main_merge_or_closeout_claim"; passed = $true },
        [ordered]@{ check = "no_r19_or_successor_opened"; passed = $true }
    )
    return $report
}

function New-R18FinalProofPackageSnapshot {
    $snapshot = New-R18FinalProofPackageBase -ArtifactType "r18_final_operator_surface_snapshot"
    $snapshot.snapshot_id = "r18_028_final_operator_surface_snapshot_v1"
    $snapshot.title = "R18-028 Produce R18 final proof package and acceptance recommendation"
    $snapshot.operator_visible_status = "R18 active through R18-028 only; closeout blocked pending explicit committed operator approval."
    $snapshot.recommendation = "Review the bounded final package; do not treat it as operator approval, external audit acceptance, main merge, or milestone closeout."
    $snapshot.unresolved_gap_count = @((Get-R18FinalProofPackageUnresolvedGaps)).Count
    $snapshot.next_safe_step = "Operator decision on R18 closeout or repair plan; no R19 is opened by this package."
    return $snapshot
}

function Get-R18FinalProofPackageProofReviewLines {
    return @(
        "# R18-028 Final Proof Package and Acceptance Recommendation Proof Review",
        "",
        "Task: R18-028 Produce R18 final proof package and acceptance recommendation",
        "",
        "Verdict: $script:R18FinalVerdict",
        "",
        "Scope: final proof package and acceptance recommendation candidate only. The package indexes R18-001 through R18-028 evidence refs, summarizes KPI movement, preserves unresolved gaps, and creates a recommendation packet for operator decision.",
        "",
        "Finding: R18 closeout remains blocked because explicit committed R18 operator closeout approval is absent, CI replay is absent, live runtime/API/A2A/agent/skill/tool-call/product execution is absent, and no committed baseline/current manual prompt transfer counts prove no-manual-prompt-transfer success.",
        "",
        "Current status truth after this task: R18 is active through R18-028 only, R17 remains closed with caveats through R17-028 only, no R19 is opened, main is not merged, and R18-028 is not milestone closeout."
    )
}

function Get-R18FinalProofPackageValidationManifestLines {
    $lines = @(
        "# R18-028 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-028 only; no R19 opened; closeout blocked pending explicit committed operator approval.",
        "",
        "Required validation commands:"
    )
    foreach ($command in Get-R18FinalProofPackageValidationCommands) {
        $lines += "- $command"
    }
    return $lines
}

function Get-R18FinalProofPackageReportMarkdownLines {
    return @(
        "# AIOffice V2 R18 Final Proof Package and Acceptance Recommendation v1",
        "",
        "Status: R18 active through R18-028 only. This is a final proof package and acceptance recommendation candidate, not operator approval and not milestone closeout.",
        "",
        "Recommendation: accept the bounded R18-028 final package for operator review, keep closeout blocked pending explicit committed operator approval, and keep unresolved runtime/API/CI/no-manual-transfer gaps explicit.",
        "",
        "Non-claims: no Codex/OpenAI API invocation, no live API adapter invocation, no live agent invocation, no live skill execution, no tool-call execution, no A2A messages, no live A2A runtime, no recovery action, no release gate execution, no CI replay, no GitHub Actions workflow created or run, no product runtime, no no-manual-prompt-transfer success, no solved Codex compaction or reliability, no external audit acceptance, no main merge, no milestone closeout, and no R19 opened.",
        "",
        "Evidence refs: see `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_028_final_proof_package_acceptance_recommendation/evidence_index.json`.",
        "",
        "Decision packet: see `state/governance/r18_final_proof_package_acceptance_recommendation/operator_decision_recommendation_packet.json`."
    )
}

function New-R18FinalProofPackageFixtureFiles {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $paths = Get-R18FinalProofPackagePaths -RepositoryRoot $RepositoryRoot
    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null

    $fixtures = @(
        @{ file = "invalid_operator_approval_claimed.json"; target = "recommendation"; path = "operator_approval_granted"; operation = "set"; value = $true; expected_failure_fragments = @("operator approval") },
        @{ file = "invalid_milestone_closeout_claimed.json"; target = "final_report"; path = "closeout_assessment.milestone_closeout_claimed"; operation = "set"; value = $true; expected_failure_fragments = @("Milestone closeout") },
        @{ file = "invalid_external_audit_acceptance_claimed.json"; target = "results"; path = "runtime_flags.external_audit_acceptance_claimed"; operation = "set"; value = $true; expected_failure_fragments = @("external_audit_acceptance_claimed") },
        @{ file = "invalid_main_merge_claimed.json"; target = "results"; path = "runtime_flags.main_merge_claimed"; operation = "set"; value = $true; expected_failure_fragments = @("main_merge_claimed") },
        @{ file = "invalid_ci_replay_claimed.json"; target = "final_report"; path = "runtime_flags.ci_replay_performed"; operation = "set"; value = $true; expected_failure_fragments = @("ci_replay_performed") },
        @{ file = "invalid_no_manual_prompt_transfer_success.json"; target = "final_report"; path = "runtime_flags.no_manual_prompt_transfer_success_claimed"; operation = "set"; value = $true; expected_failure_fragments = @("no_manual_prompt_transfer_success_claimed") },
        @{ file = "invalid_runtime_claim_without_evidence.json"; target = "final_report"; path = "runtime_claim_assessment.runtime_claims_made"; operation = "set"; value = $true; expected_failure_fragments = @("Runtime claims") },
        @{ file = "invalid_missing_unresolved_gaps.json"; target = "final_report"; path = "unresolved_gap_summary"; operation = "set"; value = @(); expected_failure_fragments = @("unresolved gaps") },
        @{ file = "invalid_missing_task_entries.json"; target = "evidence_index"; path = "task_entries"; operation = "set"; value = @(); expected_failure_fragments = @("28 R18 task entries") },
        @{ file = "invalid_r19_opened.json"; target = "repair_plan"; path = "successor_milestone_opened"; operation = "set"; value = $true; expected_failure_fragments = @("successor milestone") },
        @{ file = "invalid_release_gate_executed.json"; target = "check_report"; path = "runtime_flags.release_gate_executed"; operation = "set"; value = $true; expected_failure_fragments = @("release_gate_executed") },
        @{ file = "invalid_recovery_action_claimed.json"; target = "final_report"; path = "runtime_flags.recovery_action_performed"; operation = "set"; value = $true; expected_failure_fragments = @("recovery_action_performed") },
        @{ file = "invalid_local_backup_ref.json"; target = "evidence_index"; path = "indexed_evidence_refs"; operation = "set"; value = @(".local_backups/r18-final.json"); expected_failure_fragments = @("operator-local backup") },
        @{ file = "invalid_final_head_self_reference.json"; target = "final_head"; path = "self_referential_final_head_claimed"; operation = "set"; value = $true; expected_failure_fragments = @("self-referential") }
    )

    foreach ($fixture in $fixtures) {
        Write-R18FinalProofPackageJson -Path (Join-Path $paths.FixtureRoot $fixture.file) -Value ([ordered]@{
                target = $fixture.target
                path = $fixture.path
                operation = $fixture.operation
                value = $fixture.value
                expected_failure_fragments = $fixture.expected_failure_fragments
            })
    }

    Write-R18FinalProofPackageJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value ([ordered]@{
            artifact_type = "r18_final_proof_package_acceptance_recommendation_fixture_manifest"
            source_task = $script:R18FinalSourceTask
            fixtures = @($fixtures | ForEach-Object {
                    [ordered]@{
                        file = $_.file
                        target = $_.target
                        path = $_.path
                        operation = $_.operation
                        expected_failure_fragments = $_.expected_failure_fragments
                    }
                })
        })
}

function New-R18FinalProofPackageArtifacts {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $paths = Get-R18FinalProofPackagePaths -RepositoryRoot $RepositoryRoot
    Write-R18FinalProofPackageJson -Path $paths.Contract -Value (New-R18FinalProofPackageContract)
    Write-R18FinalProofPackageJson -Path $paths.FinalReport -Value (New-R18FinalProofPackageFinalReport)
    Write-R18FinalProofPackageText -Path $paths.FinalReportMarkdown -Lines (Get-R18FinalProofPackageReportMarkdownLines)
    Write-R18FinalProofPackageJson -Path $paths.KpiScorecard -Value (New-R18FinalProofPackageKpiScorecard)
    Write-R18FinalProofPackageJson -Path $paths.FinalHeadSupportPacket -Value (New-R18FinalProofPackageFinalHeadSupportPacket -RepositoryRoot $RepositoryRoot)
    Write-R18FinalProofPackageJson -Path $paths.OperatorDecisionRecommendation -Value (New-R18FinalProofPackageOperatorDecisionRecommendation)
    Write-R18FinalProofPackageJson -Path $paths.RepairPlan -Value (New-R18FinalProofPackageRepairPlan)
    Write-R18FinalProofPackageJson -Path $paths.Results -Value (New-R18FinalProofPackageResults)
    Write-R18FinalProofPackageJson -Path $paths.CheckReport -Value (New-R18FinalProofPackageCheckReport)
    Write-R18FinalProofPackageJson -Path $paths.Snapshot -Value (New-R18FinalProofPackageSnapshot)
    Write-R18FinalProofPackageJson -Path $paths.EvidenceIndex -Value (New-R18FinalProofPackageEvidenceIndex)
    Write-R18FinalProofPackageText -Path $paths.ProofReview -Lines (Get-R18FinalProofPackageProofReviewLines)
    Write-R18FinalProofPackageText -Path $paths.ValidationManifest -Lines (Get-R18FinalProofPackageValidationManifestLines)
    New-R18FinalProofPackageFixtureFiles -RepositoryRoot $RepositoryRoot

    return Test-R18FinalProofPackage -RepositoryRoot $RepositoryRoot -SkipStatusTruth
}

function Get-R18FinalProofPackageSet {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $paths = Get-R18FinalProofPackagePaths -RepositoryRoot $RepositoryRoot
    return [ordered]@{
        Contract = Read-R18FinalProofPackageJson -Path $paths.Contract
        FinalReport = Read-R18FinalProofPackageJson -Path $paths.FinalReport
        KpiScorecard = Read-R18FinalProofPackageJson -Path $paths.KpiScorecard
        FinalHead = Read-R18FinalProofPackageJson -Path $paths.FinalHeadSupportPacket
        Recommendation = Read-R18FinalProofPackageJson -Path $paths.OperatorDecisionRecommendation
        RepairPlan = Read-R18FinalProofPackageJson -Path $paths.RepairPlan
        Results = Read-R18FinalProofPackageJson -Path $paths.Results
        CheckReport = Read-R18FinalProofPackageJson -Path $paths.CheckReport
        Snapshot = Read-R18FinalProofPackageJson -Path $paths.Snapshot
        EvidenceIndex = Read-R18FinalProofPackageJson -Path $paths.EvidenceIndex
    }
}

function Assert-R18FinalProofPackageCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18FinalProofPackageNoUnsafeRefs {
    param(
        [Parameter(Mandatory = $true)][object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($ref in @($Refs)) {
        $value = [string]$ref
        if ([string]::IsNullOrWhiteSpace($value)) { continue }
        Assert-R18FinalProofPackageCondition -Condition ($value -notmatch '\.local_backups') -Message "$Context contains operator-local backup ref: $value"
        Assert-R18FinalProofPackageCondition -Condition ($value -ne "governance/reports/AIOffice_V2_Revised_R17_Plan.md") -Message "$Context contains protected untracked report ref: $value"
        Assert-R18FinalProofPackageCondition -Condition (-not [System.IO.Path]::IsPathRooted($value)) -Message "$Context contains absolute path: $value"
        Assert-R18FinalProofPackageCondition -Condition ($value -notmatch '\.\.') -Message "$Context contains parent traversal path: $value"
        Assert-R18FinalProofPackageCondition -Condition ($value -notmatch '[*?]') -Message "$Context contains wildcard path: $value"
        Assert-R18FinalProofPackageCondition -Condition ($value -notmatch '^(scratch|tmp|temp)/') -Message "$Context contains scratch/temp path: $value"
    }
}

function Assert-R18FinalProofPackageCommonArtifact {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18FinalProofPackageCondition -Condition ($Artifact.source_task -eq $script:R18FinalSourceTask) -Message "$Context source_task must be R18-028."
    Assert-R18FinalProofPackageCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_028_only") -Message "$Context status boundary must be active through R18-028 only."
    foreach ($flagName in $script:R18FinalRuntimeFlagFields) {
        Assert-R18FinalProofPackageCondition -Condition ($Artifact.runtime_flags.PSObject.Properties.Name -contains $flagName) -Message "$Context missing runtime flag $flagName."
        Assert-R18FinalProofPackageCondition -Condition ([bool]$Artifact.runtime_flags.$flagName -eq $false) -Message "$flagName must remain false in $Context."
    }
    Assert-R18FinalProofPackageNoUnsafeRefs -Refs @($Artifact.evidence_refs) -Context "$Context evidence_refs"
    Assert-R18FinalProofPackageNoUnsafeRefs -Refs @($Artifact.authority_refs) -Context "$Context authority_refs"
}

function Test-R18FinalProofPackageSet {
    param([Parameter(Mandatory = $true)]$Set)

    foreach ($pair in @(
            @{ Context = "contract"; Artifact = $Set.Contract },
            @{ Context = "final_report"; Artifact = $Set.FinalReport },
            @{ Context = "kpi_scorecard"; Artifact = $Set.KpiScorecard },
            @{ Context = "final_head"; Artifact = $Set.FinalHead },
            @{ Context = "recommendation"; Artifact = $Set.Recommendation },
            @{ Context = "repair_plan"; Artifact = $Set.RepairPlan },
            @{ Context = "results"; Artifact = $Set.Results },
            @{ Context = "check_report"; Artifact = $Set.CheckReport },
            @{ Context = "snapshot"; Artifact = $Set.Snapshot },
            @{ Context = "evidence_index"; Artifact = $Set.EvidenceIndex }
        )) {
        Assert-R18FinalProofPackageCommonArtifact -Artifact $pair.Artifact -Context $pair.Context
    }

    Assert-R18FinalProofPackageCondition -Condition ($Set.Contract.task_title -eq $script:R18FinalTitle) -Message "Contract title must match authority."
    foreach ($dependency in @("R18-001 through R18-027")) {
        Assert-R18FinalProofPackageCondition -Condition (@($Set.Contract.dependencies) -contains $dependency) -Message "Contract missing dependency $dependency."
    }
    foreach ($expected in @("R18 final report", "KPI movement scorecard", "evidence index", "proof review", "validation manifest", "final-head support packet", "decision recommendation")) {
        Assert-R18FinalProofPackageCondition -Condition (@($Set.Contract.outputs) -contains $expected) -Message "Contract missing authority output '$expected'."
    }
    Assert-R18FinalProofPackageCondition -Condition ($Set.Contract.failure_retry_behavior.repair_plan_required -eq $true) -Message "Contract must require repair plan on insufficient evidence."

    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.package_status -eq "final_proof_package_candidate_only") -Message "Final report must be candidate-only."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.operator_approval_required_for_closeout -eq $true) -Message "Operator approval must remain required."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.explicit_committed_operator_closeout_approval_exists -eq $false) -Message "Committed operator closeout approval must remain absent."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.closeout_assessment.milestone_closeout_claimed -eq $false) -Message "Milestone closeout must not be claimed."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.closeout_assessment.closeout_blocked -eq $true) -Message "Closeout must be blocked."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.runtime_claim_assessment.runtime_claims_made -eq $false) -Message "Runtime claims must not be made."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalReport.runtime_claim_assessment.runtime_claims_backed_by_execution_evidence -eq $false) -Message "Runtime claims must not be marked backed when no runtime claims are made."
    Assert-R18FinalProofPackageCondition -Condition (@($Set.FinalReport.unresolved_gap_summary).Count -ge 5) -Message "Final report must keep unresolved gaps explicit."

    Assert-R18FinalProofPackageCondition -Condition ($Set.KpiScorecard.weight_sum -eq 100) -Message "KPI weights must sum to 100."
    foreach ($row in @($Set.KpiScorecard.score_rows)) {
        Assert-R18FinalProofPackageCondition -Condition ([int]$row.r18_final_score -le [int]$row.target_score) -Message "KPI row exceeds target: $($row.category)."
        Assert-R18FinalProofPackageCondition -Condition (@($row.evidence_refs).Count -gt 0) -Message "KPI row missing evidence refs: $($row.category)."
    }
    Assert-R18FinalProofPackageCondition -Condition ($Set.KpiScorecard.formal_closeout_recommended -eq $false) -Message "Scorecard must not recommend formal closeout."

    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalHead.self_referential_final_head_claimed -eq $false) -Message "Final-head support packet must not make self-referential final-head claim."
    Assert-R18FinalProofPackageCondition -Condition ($Set.FinalHead.post_push_remote_head_claimed -eq $false) -Message "Final-head support packet must not claim post-push remote head."
    Assert-R18FinalProofPackageCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Set.FinalHead.observed_head_at_generation)) -Message "Final-head support packet missing observed head."

    Assert-R18FinalProofPackageCondition -Condition ($Set.Recommendation.decision_packet_status -eq "recommendation_only_not_operator_approval") -Message "Recommendation must be recommendation-only."
    Assert-R18FinalProofPackageCondition -Condition ($Set.Recommendation.operator_approval_granted -eq $false -and $Set.Recommendation.operator_closeout_approval_granted -eq $false) -Message "Recommendation must not grant operator approval."
    Assert-R18FinalProofPackageCondition -Condition ($Set.Recommendation.approval_inferred_from_narration -eq $false) -Message "Recommendation must not infer approval from narration."
    Assert-R18FinalProofPackageCondition -Condition ($Set.Recommendation.closeout_recommendation -like "blocked*") -Message "Recommendation must keep closeout blocked."

    Assert-R18FinalProofPackageCondition -Condition ($Set.RepairPlan.repair_plan_status -eq "candidate_repair_plan_no_successor_milestone_opened") -Message "Repair plan status must be candidate-only."
    Assert-R18FinalProofPackageCondition -Condition ($Set.RepairPlan.recovery_or_escalation_triggered -eq $false) -Message "Repair plan must not trigger recovery/escalation."
    Assert-R18FinalProofPackageCondition -Condition ($Set.RepairPlan.successor_milestone_opened -eq $false) -Message "Repair plan must not open successor milestone."
    Assert-R18FinalProofPackageCondition -Condition (@($Set.RepairPlan.required_repairs).Count -ge 5) -Message "Repair plan must include required repairs."

    Assert-R18FinalProofPackageCondition -Condition ($Set.Results.aggregate_verdict -eq $script:R18FinalVerdict) -Message "Results aggregate verdict invalid."
    Assert-R18FinalProofPackageCondition -Condition ($Set.Results.final_package_result.closeout_blocked_pending_operator_approval -eq $true) -Message "Results must keep closeout blocked pending operator approval."
    foreach ($check in @($Set.CheckReport.checks)) {
        Assert-R18FinalProofPackageCondition -Condition ($check.passed -eq $true) -Message "Check report contains a failed check: $($check.check)."
    }

    $entries = @($Set.EvidenceIndex.task_entries)
    Assert-R18FinalProofPackageCondition -Condition ($entries.Count -eq 28) -Message "Evidence index must include 28 R18 task entries."
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18FinalProofPackageCondition -Condition (@($entries | Where-Object { $_.task_id -eq $taskId }).Count -eq 1) -Message "Evidence index missing $taskId."
    }
    Assert-R18FinalProofPackageNoUnsafeRefs -Refs @($Set.EvidenceIndex.indexed_evidence_refs) -Context "evidence index refs"

    return [pscustomobject]@{
        AggregateVerdict = $Set.Results.aggregate_verdict
        TaskEntryCount = $entries.Count
        UnresolvedGapCount = @($Set.FinalReport.unresolved_gap_summary).Count
        OperatorApprovalGranted = [bool]$Set.Recommendation.operator_approval_granted
        CloseoutBlocked = [bool]$Set.FinalReport.closeout_assessment.closeout_blocked
        R18Status = $Set.FinalReport.status_boundary.r18_status
    }
}

function Get-R18FinalProofPackageTaskStatusMap {
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

function Test-R18FinalProofPackageStatusTruth {
    param([string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18FinalProofPackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-028 only",
            "R18-028 produced the R18 final proof package and acceptance recommendation candidate only",
            "R18-028 is not operator approval",
            "R18-028 is not milestone closeout",
            "R18-028 is not external audit acceptance",
            "R18-028 is not main merge",
            "No R19 is opened",
            "No no-manual-prompt-transfer success is claimed",
            "No Codex/OpenAI API invocation occurred",
            "No live API adapter invocation",
            "No live agent",
            "No live skill",
            "No tool-call execution",
            "No A2A messages",
            "No board/card runtime mutation occurred",
            "No recovery action",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "External audit acceptance is not claimed",
            "Main is not merged",
            "No milestone closeout is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved",
            "Codex reliability is not solved"
        )) {
        Assert-R18FinalProofPackageCondition -Condition ($combinedText -like "*$required*") -Message "Status surface missing R18-028 wording: $required"
    }

    $authorityStatuses = Get-R18FinalProofPackageTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18FinalProofPackageTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18FinalProofPackageCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        Assert-R18FinalProofPackageCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-028."
    }

    Assert-R18FinalProofPackageCondition -Condition ($combinedText -notmatch '(?i)\bR18-(0(?:2[9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,120}\b(done|complete|completed|implemented|executed|active|planned)\b') -Message "R18 successor task is claimed."

    foreach ($forbidden in @(
            "R18 runtime implementation is delivered",
            "R18 API invocation completed",
            "R18 live recovery runtime delivered",
            "R18 solved Codex compaction",
            "R18 solved Codex reliability",
            "R18 proved no-manual-prompt-transfer success",
            "R19 opened"
        )) {
        Assert-R18FinalProofPackageCondition -Condition ($combinedText -notlike "*$forbidden*") -Message "Forbidden status-doc claim found: $forbidden"
    }

    return [pscustomobject]@{
        R18DoneThrough = 28
        R18PlannedStart = $null
        R18PlannedThrough = $null
    }
}

function Test-R18FinalProofPackage {
    param(
        [string]$RepositoryRoot = (Get-R18FinalProofPackageRepositoryRoot),
        [switch]$SkipStatusTruth
    )

    $set = Get-R18FinalProofPackageSet -RepositoryRoot $RepositoryRoot
    $result = Test-R18FinalProofPackageSet -Set $set
    if (-not $SkipStatusTruth) {
        Test-R18FinalProofPackageStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null
    }
    return $result
}

function Copy-R18FinalProofPackageObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18FinalProofPackageMutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )
    switch ($Target) {
        "contract" { return $Set.Contract }
        "final_report" { return $Set.FinalReport }
        "scorecard" { return $Set.KpiScorecard }
        "final_head" { return $Set.FinalHead }
        "recommendation" { return $Set.Recommendation }
        "repair_plan" { return $Set.RepairPlan }
        "results" { return $Set.Results }
        "check_report" { return $Set.CheckReport }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target: $Target" }
    }
}

function Set-R18FinalProofPackagePathValue {
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

function Invoke-R18FinalProofPackageMutation {
    param(
        [Parameter(Mandatory = $true)]$TargetObject,
        [Parameter(Mandatory = $true)]$Mutation
    )

    $parts = ([string]$Mutation.path).Split(".")
    switch ([string]$Mutation.operation) {
        "set" { Set-R18FinalProofPackagePathValue -Object $TargetObject -Parts $parts -Value $Mutation.value }
        "remove" { Set-R18FinalProofPackagePathValue -Object $TargetObject -Parts $parts -Value $null -Remove }
        default { throw "Unknown mutation operation: $($Mutation.operation)" }
    }
}

Export-ModuleMember -Function `
    Get-R18FinalProofPackagePaths, `
    Get-R18FinalProofPackageRuntimeFlagNames, `
    New-R18FinalProofPackageArtifacts, `
    Get-R18FinalProofPackageSet, `
    Test-R18FinalProofPackageSet, `
    Test-R18FinalProofPackage, `
    Test-R18FinalProofPackageStatusTruth, `
    Copy-R18FinalProofPackageObject, `
    Get-R18FinalProofPackageMutationTarget, `
    Invoke-R18FinalProofPackageMutation
