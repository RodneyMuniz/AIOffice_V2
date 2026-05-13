Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-011"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ClassifierVerdict = "generated_r18_011_wip_classifier_foundation_only"
$script:R18RunnerStateRef = "state/runtime/r18_runner_state.json"
$script:R18FailureEventRef = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"

$script:R18RuntimeFlagFields = @(
    "wip_classifier_live_runtime_executed",
    "live_git_scan_performed",
    "wip_cleanup_performed",
    "wip_abandonment_performed",
    "file_restore_performed",
    "file_delete_performed",
    "staging_performed",
    "commit_performed",
    "push_performed",
    "remote_branch_verifier_runtime_implemented",
    "remote_branch_verified",
    "continuation_packet_generated",
    "new_context_prompt_generated",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "work_order_execution_performed",
    "live_runner_runtime_executed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_012_completed",
    "main_merge_claimed"
)

$script:R18RequiredInventoryFields = @(
    "artifact_type",
    "contract_version",
    "inventory_id",
    "inventory_name",
    "source_task",
    "source_milestone",
    "inventory_status",
    "inventory_type",
    "git_status_short",
    "git_diff_name_status",
    "git_diff_numstat",
    "staged_paths",
    "tracked_wip_paths",
    "untracked_paths",
    "allowed_wip_paths",
    "forbidden_wip_paths",
    "churn_threshold_policy",
    "expected_classification_type",
    "expected_action_recommendation",
    "runner_state_ref",
    "failure_event_ref",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredClassificationFields = @(
    "artifact_type",
    "contract_version",
    "classification_id",
    "source_task",
    "source_milestone",
    "classification_status",
    "source_inventory_ref",
    "classification_type",
    "action_recommendation",
    "safety_level",
    "tracked_wip_present",
    "untracked_paths_present",
    "staged_paths_present",
    "historical_evidence_edit_detected",
    "operator_local_backup_path_detected",
    "generated_artifact_churn_detected",
    "allowed_wip_paths",
    "forbidden_wip_paths",
    "safe_to_continue",
    "operator_decision_required",
    "stop_conditions",
    "escalation_conditions",
    "next_safe_step",
    "runner_state_ref",
    "failure_event_ref",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18AllowedInventoryTypes = @(
    "no_wip",
    "scoped_tracked_wip",
    "unexpected_tracked_wip",
    "historical_evidence_edit",
    "operator_local_backup_path",
    "untracked_local_notes",
    "generated_artifact_churn",
    "staged_files_present"
)

$script:R18AllowedClassificationTypes = @(
    "no_wip_safe",
    "scoped_tracked_wip_safe_to_preserve",
    "unexpected_tracked_wip_operator_decision_required",
    "historical_evidence_edit_blocked",
    "operator_local_backup_path_blocked",
    "untracked_local_notes_do_not_stage",
    "generated_artifact_churn_review_required",
    "staged_files_present_blocked"
)

$script:R18AllowedActionRecommendations = @(
    "continue_without_wip_action",
    "preserve_scoped_wip_for_future_task",
    "stop_and_request_operator_decision",
    "block_historical_evidence_edit",
    "leave_untracked_local_notes_unstaged",
    "review_generated_artifact_churn",
    "unstage_before_continue",
    "stop_and_escalate"
)

$script:R18AllowedPositiveClaims = @(
    "r18_wip_classifier_contract_created",
    "r18_wip_classifier_profile_created",
    "r18_wip_inventory_samples_created",
    "r18_wip_classification_packets_created",
    "r18_wip_classifier_results_created",
    "r18_wip_classifier_validator_created",
    "r18_wip_classifier_fixtures_created",
    "r18_wip_classifier_proof_review_created"
)

$script:R18RejectedClaims = @(
    "live_wip_classifier_runtime",
    "live_git_scan",
    "wip_cleanup",
    "wip_abandonment",
    "file_restore",
    "file_delete",
    "stage_commit_push",
    "staging",
    "commit",
    "push",
    "remote_branch_verifier_runtime",
    "remote_branch_verification",
    "continuation_packet_generation",
    "new_context_prompt_generation",
    "recovery_runtime",
    "recovery_action",
    "work_order_execution",
    "live_runner_runtime",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "automatic_new_thread_creation",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_012_or_later_completion",
    "main_merge",
    "historical_evidence_edit_marked_safe",
    "operator_local_backup_path_stageable",
    "unexpected_tracked_wip_marked_safe",
    "staged_files_marked_safe",
    "untracked_local_notes_marked_for_staging",
    "generated_churn_without_threshold"
)

$script:R18InventoryDefinitions = @(
    [ordered]@{
        file = "no_wip.inventory.json"
        inventory_id = "r18_011_inventory_no_wip"
        inventory_name = "No WIP seed inventory"
        inventory_type = "no_wip"
        git_status_short = @()
        git_diff_name_status = @()
        git_diff_numstat = @()
        staged_paths = @()
        tracked_wip_paths = @()
        untracked_paths = @()
        allowed_wip_paths = @("state/runtime/r18_wip_inventory_samples/")
        forbidden_wip_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "no_wip_safe"
        expected_action_recommendation = "continue_without_wip_action"
        threshold_observed_files = 0
        threshold_observed_delta = 0
        threshold_within = $true
    },
    [ordered]@{
        file = "scoped_tracked_wip.inventory.json"
        inventory_id = "r18_011_inventory_scoped_tracked_wip"
        inventory_name = "Scoped tracked WIP seed inventory"
        inventory_type = "scoped_tracked_wip"
        git_status_short = @(" M state/runtime/r18_future_scoped_wip/scoped_runner_note.md")
        git_diff_name_status = @([ordered]@{ status = "M"; path = "state/runtime/r18_future_scoped_wip/scoped_runner_note.md" })
        git_diff_numstat = @([ordered]@{ additions = 8; deletions = 1; path = "state/runtime/r18_future_scoped_wip/scoped_runner_note.md" })
        staged_paths = @()
        tracked_wip_paths = @("state/runtime/r18_future_scoped_wip/scoped_runner_note.md")
        untracked_paths = @()
        allowed_wip_paths = @("state/runtime/r18_future_scoped_wip/")
        forbidden_wip_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "scoped_tracked_wip_safe_to_preserve"
        expected_action_recommendation = "preserve_scoped_wip_for_future_task"
        threshold_observed_files = 1
        threshold_observed_delta = 9
        threshold_within = $true
    },
    [ordered]@{
        file = "unexpected_tracked_wip.inventory.json"
        inventory_id = "r18_011_inventory_unexpected_tracked_wip"
        inventory_name = "Unexpected tracked WIP seed inventory"
        inventory_type = "unexpected_tracked_wip"
        git_status_short = @(" M tools/experimental_recovery_runtime.ps1")
        git_diff_name_status = @([ordered]@{ status = "M"; path = "tools/experimental_recovery_runtime.ps1" })
        git_diff_numstat = @([ordered]@{ additions = 22; deletions = 2; path = "tools/experimental_recovery_runtime.ps1" })
        staged_paths = @()
        tracked_wip_paths = @("tools/experimental_recovery_runtime.ps1")
        untracked_paths = @()
        allowed_wip_paths = @("state/runtime/r18_future_scoped_wip/")
        forbidden_wip_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "unexpected_tracked_wip_operator_decision_required"
        expected_action_recommendation = "stop_and_request_operator_decision"
        threshold_observed_files = 1
        threshold_observed_delta = 24
        threshold_within = $true
    },
    [ordered]@{
        file = "historical_evidence_edit.inventory.json"
        inventory_id = "r18_011_inventory_historical_evidence_edit"
        inventory_name = "Historical R13-R16 evidence edit seed inventory"
        inventory_type = "historical_evidence_edit"
        git_status_short = @(" M state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json")
        git_diff_name_status = @([ordered]@{ status = "M"; path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json" })
        git_diff_numstat = @([ordered]@{ additions = 3; deletions = 3; path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json" })
        staged_paths = @()
        tracked_wip_paths = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package/evidence_index.json")
        untracked_paths = @()
        allowed_wip_paths = @("state/runtime/r18_wip_inventory_samples/")
        forbidden_wip_paths = @("state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_", ".local_backups/")
        expected_classification_type = "historical_evidence_edit_blocked"
        expected_action_recommendation = "block_historical_evidence_edit"
        threshold_observed_files = 1
        threshold_observed_delta = 6
        threshold_within = $true
    },
    [ordered]@{
        file = "operator_local_backup_path.inventory.json"
        inventory_id = "r18_011_inventory_operator_local_backup_path"
        inventory_name = "Operator-local backup path seed inventory"
        inventory_type = "operator_local_backup_path"
        git_status_short = @("?? .local_backups/r18_operator_saved_context.md")
        git_diff_name_status = @()
        git_diff_numstat = @()
        staged_paths = @()
        tracked_wip_paths = @()
        untracked_paths = @(".local_backups/r18_operator_saved_context.md")
        allowed_wip_paths = @("state/runtime/r18_wip_inventory_samples/")
        forbidden_wip_paths = @(".local_backups/", "operator-local backup paths", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "operator_local_backup_path_blocked"
        expected_action_recommendation = "stop_and_request_operator_decision"
        threshold_observed_files = 0
        threshold_observed_delta = 0
        threshold_within = $true
    },
    [ordered]@{
        file = "untracked_local_notes.inventory.json"
        inventory_id = "r18_011_inventory_untracked_local_notes"
        inventory_name = "Untracked local notes seed inventory"
        inventory_type = "untracked_local_notes"
        git_status_short = @("?? local_notes/r18_operator_note.md")
        git_diff_name_status = @()
        git_diff_numstat = @()
        staged_paths = @()
        tracked_wip_paths = @()
        untracked_paths = @("local_notes/r18_operator_note.md")
        allowed_wip_paths = @("local_notes/")
        forbidden_wip_paths = @("contracts/", "governance/", "state/proof_reviews/", ".local_backups/")
        expected_classification_type = "untracked_local_notes_do_not_stage"
        expected_action_recommendation = "leave_untracked_local_notes_unstaged"
        threshold_observed_files = 0
        threshold_observed_delta = 0
        threshold_within = $true
    },
    [ordered]@{
        file = "generated_artifact_churn.inventory.json"
        inventory_id = "r18_011_inventory_generated_artifact_churn"
        inventory_name = "Generated artifact churn seed inventory"
        inventory_type = "generated_artifact_churn"
        git_status_short = @(" M state/ui/r18_operator_surface/generated_snapshot_a.json", " M state/runtime/generated_large_report.json", " M state/runtime/generated_large_report_index.json")
        git_diff_name_status = @(
            [ordered]@{ status = "M"; path = "state/ui/r18_operator_surface/generated_snapshot_a.json" },
            [ordered]@{ status = "M"; path = "state/runtime/generated_large_report.json" },
            [ordered]@{ status = "M"; path = "state/runtime/generated_large_report_index.json" }
        )
        git_diff_numstat = @(
            [ordered]@{ additions = 220; deletions = 120; path = "state/ui/r18_operator_surface/generated_snapshot_a.json" },
            [ordered]@{ additions = 360; deletions = 80; path = "state/runtime/generated_large_report.json" },
            [ordered]@{ additions = 100; deletions = 40; path = "state/runtime/generated_large_report_index.json" }
        )
        staged_paths = @()
        tracked_wip_paths = @("state/ui/r18_operator_surface/generated_snapshot_a.json", "state/runtime/generated_large_report.json", "state/runtime/generated_large_report_index.json")
        untracked_paths = @()
        allowed_wip_paths = @("state/ui/r18_operator_surface/", "state/runtime/")
        forbidden_wip_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "generated_artifact_churn_review_required"
        expected_action_recommendation = "review_generated_artifact_churn"
        threshold_observed_files = 3
        threshold_observed_delta = 920
        threshold_within = $false
    },
    [ordered]@{
        file = "staged_files_present.inventory.json"
        inventory_id = "r18_011_inventory_staged_files_present"
        inventory_name = "Staged files present seed inventory"
        inventory_type = "staged_files_present"
        git_status_short = @("M  governance/ACTIVE_STATE.md")
        git_diff_name_status = @([ordered]@{ status = "M"; path = "governance/ACTIVE_STATE.md" })
        git_diff_numstat = @([ordered]@{ additions = 5; deletions = 1; path = "governance/ACTIVE_STATE.md" })
        staged_paths = @("governance/ACTIVE_STATE.md")
        tracked_wip_paths = @("governance/ACTIVE_STATE.md")
        untracked_paths = @()
        allowed_wip_paths = @("governance/ACTIVE_STATE.md")
        forbidden_wip_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        expected_classification_type = "staged_files_present_blocked"
        expected_action_recommendation = "unstage_before_continue"
        threshold_observed_files = 1
        threshold_observed_delta = 6
        threshold_within = $true
    }
)

function Get-R18WipClassifierRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18WipPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18WipJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18WipJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R18WipText {
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

function Copy-R18WipClassifierObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18WipClassifierPaths {
    param([string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_wip_classifier.contract.json"
        Profile = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_wip_classifier_profile.json"
        InventoryRoot = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_wip_inventory_samples"
        ClassificationRoot = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_wip_classification_packets"
        Results = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_wip_classifier_results.json"
        CheckReport = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_wip_classifier_check_report.json"
        UiSnapshot = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_wip_classifier_snapshot.json"
        FixtureRoot = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_wip_classifier"
        ProofRoot = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier"
        EvidenceIndex = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier/evidence_index.json"
        ProofReview = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier/proof_review.md"
        ValidationManifest = Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier/validation_manifest.md"
    }
}

function Get-R18WipRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18WipNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-011 only.",
        "R18-012 through R18-028 remain planned only.",
        "R18-011 created WIP classifier foundation only.",
        "WIP classification is deterministic over seed git inventory artifacts only.",
        "No live git scan was performed.",
        "No WIP cleanup was performed.",
        "No WIP abandonment was performed.",
        "No files were restored or deleted.",
        "No staging, commit, or push was performed by the classifier.",
        "Remote branch verifier runtime is not implemented.",
        "Continuation packet generator is not implemented.",
        "New-context prompt generator is not implemented.",
        "No recovery action was performed.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No product runtime is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "No no-manual-prompt-transfer success is claimed.",
        "Main is not merged."
    )
}

function Get-R18WipAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_state_history.jsonl",
        "state/runtime/r18_execution_log.jsonl",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_failure_event.contract.json",
        "contracts/runtime/r18_compact_failure_detector.contract.json",
        "state/runtime/r18_detected_failure_events/",
        "state/runtime/r18_compact_failure_detector_results.json",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_seed_packets/",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18WipEvidenceRefs {
    return @(
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classifier_profile.json",
        "state/runtime/r18_wip_inventory_samples/",
        "state/runtime/r18_wip_classification_packets/",
        "state/runtime/r18_wip_classifier_results.json",
        "state/runtime/r18_wip_classifier_check_report.json",
        "state/ui/r18_operator_surface/r18_wip_classifier_snapshot.json",
        "tools/R18WipClassifier.psm1",
        "tools/new_r18_wip_classifier.ps1",
        "tools/validate_r18_wip_classifier.ps1",
        "tests/test_r18_wip_classifier.ps1",
        "tests/fixtures/r18_wip_classifier/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier/"
    )
}

function Get-R18WipValidationRefs {
    return @(
        "tools/validate_r18_wip_classifier.ps1",
        "tests/test_r18_wip_classifier.ps1",
        "tools/validate_r18_compact_failure_detector.ps1",
        "tests/test_r18_compact_failure_detector.ps1",
        "tools/validate_r18_runner_state_store.ps1",
        "tests/test_r18_runner_state_store.ps1",
        "tools/validate_r18_work_order_state_machine.ps1",
        "tests/test_r18_work_order_state_machine.ps1",
        "tools/validate_r18_local_runner_cli.ps1",
        "tests/test_r18_local_runner_cli.ps1",
        "tools/validate_r18_orchestrator_control_intake.ps1",
        "tests/test_r18_orchestrator_control_intake.ps1",
        "tools/validate_r18_role_skill_permission_matrix.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1",
        "tools/validate_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tools/validate_r18_skill_contract_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tools/validate_r18_agent_card_schema.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_opening_authority.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18WipChurnThresholdPolicy {
    param([Parameter(Mandatory = $true)][object]$Definition)

    return [ordered]@{
        policy_id = "r18_011_deterministic_generated_artifact_threshold"
        threshold_required = $true
        max_changed_files_without_review = 2
        max_total_line_delta_without_review = 500
        observed_changed_files = [int]$Definition.threshold_observed_files
        observed_total_line_delta = [int]$Definition.threshold_observed_delta
        within_threshold = [bool]$Definition.threshold_within
        threshold_basis = "seed_git_diff_name_status_and_seed_git_diff_numstat_only_not_live_git_scan"
    }
}

function Test-R18WipPathInsideAny {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Prefixes
    )

    $normalizedPath = $Path -replace '\\', '/'
    foreach ($prefix in @($Prefixes)) {
        $normalizedPrefix = ([string]$prefix) -replace '\\', '/'
        if ($normalizedPath.StartsWith($normalizedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
        if ($normalizedPath -eq $normalizedPrefix) {
            return $true
        }
    }
    return $false
}

function Get-R18WipInventoryRef {
    param([Parameter(Mandatory = $true)][string]$FileName)
    return "state/runtime/r18_wip_inventory_samples/$FileName"
}

function Get-R18WipClassificationFileName {
    param([Parameter(Mandatory = $true)][string]$InventoryType)
    return "$InventoryType.classification.json"
}

function Get-R18WipClassificationRef {
    param([Parameter(Mandatory = $true)][string]$InventoryType)
    return "state/runtime/r18_wip_classification_packets/$(Get-R18WipClassificationFileName -InventoryType $InventoryType)"
}

function Get-R18WipDefinitionByType {
    param([Parameter(Mandatory = $true)][string]$InventoryType)
    $definition = @($script:R18InventoryDefinitions | Where-Object { $_.inventory_type -eq $InventoryType })
    if ($definition.Count -ne 1) {
        throw "Unknown R18 WIP inventory type '$InventoryType'."
    }
    return $definition[0]
}

function New-R18WipClassifierContract {
    return [ordered]@{
        artifact_type = "r18_wip_classifier_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-011-wip-classifier-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "deterministic_seed_git_inventory_wip_classifier_foundation_only_no_live_git_scan_no_cleanup"
        purpose = "Classify committed seed git inventory samples into deterministic WIP classification packets while preserving safety boundaries. This foundation does not scan live git state, clean WIP, abandon WIP, restore files, delete files, stage, commit, push, verify remote branches, generate continuation packets, generate new-context prompts, execute work orders, invoke APIs, invoke live agents or skills, mutate board/card runtime state, or perform recovery actions."
        required_inventory_fields = $script:R18RequiredInventoryFields
        required_classification_fields = $script:R18RequiredClassificationFields
        allowed_inventory_types = $script:R18AllowedInventoryTypes
        allowed_classification_types = $script:R18AllowedClassificationTypes
        allowed_action_recommendations = $script:R18AllowedActionRecommendations
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        inventory_policy = [ordered]@{
            inventory_status_required = "seed_inventory_only_not_live_git_scan"
            deterministic_committed_seed_samples_only = $true
            live_git_scan_allowed = $false
            git_status_short_required = $true
            git_diff_name_status_required = $true
            git_diff_numstat_required = $true
            staged_paths_required = $true
            allowed_and_forbidden_paths_required = $true
            unknown_inventory_types_fail_closed = $true
        }
        classification_policy = [ordered]@{
            classification_status_required = "classification_seed_packet_only_not_cleanup"
            deterministic_seed_packet_generation_only = $true
            unknown_classification_types_fail_closed = $true
            unknown_action_recommendations_fail_closed = $true
            no_wip_classifies_as = "no_wip_safe"
            scoped_tracked_wip_classifies_as = "scoped_tracked_wip_safe_to_preserve"
            unexpected_tracked_wip_classifies_as = "unexpected_tracked_wip_operator_decision_required"
            historical_evidence_edit_classifies_as = "historical_evidence_edit_blocked"
            operator_local_backup_path_classifies_as = "operator_local_backup_path_blocked"
            untracked_local_notes_classifies_as = "untracked_local_notes_do_not_stage"
            generated_artifact_churn_classifies_as = "generated_artifact_churn_review_required"
            staged_files_present_classifies_as = "staged_files_present_blocked"
        }
        safety_policy = [ordered]@{
            historical_r13_r16_evidence_edits_always_blocked = $true
            operator_local_backup_paths_always_blocked_from_staging_commit = $true
            staged_files_blocked_until_explicitly_reviewed = $true
            unexpected_tracked_wip_requires_operator_decision = $true
            untracked_local_notes_may_remain_untracked_but_must_not_be_staged = $true
            generated_artifact_churn_requires_threshold_based_review = $true
            cleanup_restore_delete_stage_commit_push_allowed = $false
        }
        operator_decision_policy = [ordered]@{
            operator_decision_required_for_unexpected_tracked_wip = $true
            operator_decision_required_for_historical_evidence_edit = $true
            operator_decision_required_for_operator_local_backup_path = $true
            operator_decision_required_for_staged_files = $true
            operator_decision_required_for_generated_churn_above_threshold = $true
            missing_operator_decision_policy_fails_closed = $true
        }
        runner_state_policy = [ordered]@{
            runner_state_ref_required = $true
            runner_state_ref = $script:R18RunnerStateRef
            runner_state_is_attached_not_executed = $true
        }
        failure_event_policy = [ordered]@{
            failure_event_ref_required = $true
            failure_event_ref = $script:R18FailureEventRef
            failure_event_is_attached_seed_evidence_not_recovery_completion = $true
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            inventory_samples_required = $true
            classification_packets_required = $true
            results_required = $true
            proof_review_package_required = $true
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            approved_authority_refs = Get-R18WipAuthorityRefs
        }
        remote_verification_boundary_policy = [ordered]@{
            remote_branch_verifier_runtime_allowed = $false
            remote_branch_verified_allowed = $false
            remote_verification_deferred_to = "R18-012"
        }
        continuation_boundary_policy = [ordered]@{
            continuation_packet_generation_allowed = $false
            new_context_prompt_generation_allowed = $false
            continuation_packet_generation_deferred_to = "R18-013"
            new_context_prompt_generation_deferred_to = "R18-014"
        }
        path_policy = [ordered]@{
            allowed_paths = Get-R18WipEvidenceRefs
            forbidden_paths = @(".local_backups/", "operator-local backup paths", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_", "repository root broad write", "main branch")
            operator_local_backup_paths_allowed_for_staging = $false
            historical_r13_r16_evidence_edits_allowed = $false
            broad_repo_writes_allowed = $false
            wildcard_paths_allowed = $false
        }
        api_policy = [ordered]@{
            api_enabled = $false
            openai_api_invocation_allowed = $false
            codex_api_invocation_allowed = $false
            autonomous_codex_invocation_allowed = $false
            automatic_new_thread_creation_allowed = $false
        }
        execution_policy = [ordered]@{
            classifier_live_runtime_allowed = $false
            live_git_scan_allowed = $false
            recovery_runtime_allowed = $false
            recovery_action_allowed = $false
            work_order_execution_allowed = $false
            live_runner_runtime_allowed = $false
            skill_execution_allowed = $false
            a2a_dispatch_allowed = $false
            board_runtime_mutation_allowed = $false
            cleanup_restore_delete_stage_commit_push_allowed = $false
        }
        refusal_policy = [ordered]@{
            live_git_scan_requested_fails_closed = $true
            cleanup_requested_fails_closed = $true
            abandonment_requested_fails_closed = $true
            restore_or_delete_requested_fails_closed = $true
            stage_commit_push_requested_fails_closed = $true
            remote_verification_requested_fails_closed = $true
            continuation_generation_requested_fails_closed = $true
            new_context_prompt_generation_requested_fails_closed = $true
            recovery_action_requested_fails_closed = $true
            api_invocation_requested_fails_closed = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18WipNonClaims
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        positive_claims = @("r18_wip_classifier_contract_created")
        runtime_flags = Get-R18WipRuntimeFlags
    }
}

function New-R18WipClassifierProfile {
    return [ordered]@{
        artifact_type = "r18_wip_classifier_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-011-wip-classifier-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        profile_status = "seed_classifier_profile_only_not_live_runtime"
        classification_mode = "deterministic_committed_seed_git_inventory_only"
        inventory_sample_count = @($script:R18InventoryDefinitions).Count
        classification_packet_count = @($script:R18InventoryDefinitions).Count
        runner_state_ref = $script:R18RunnerStateRef
        failure_event_ref = $script:R18FailureEventRef
        allowed_classification_types = $script:R18AllowedClassificationTypes
        allowed_action_recommendations = $script:R18AllowedActionRecommendations
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        positive_claims = @("r18_wip_classifier_profile_created")
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipInventorySample {
    param([Parameter(Mandatory = $true)][object]$Definition)

    $inventoryRef = Get-R18WipInventoryRef -FileName ([string]$Definition.file)
    return [ordered]@{
        artifact_type = "r18_wip_inventory_sample"
        contract_version = "v1"
        inventory_id = $Definition.inventory_id
        inventory_name = $Definition.inventory_name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        inventory_status = "seed_inventory_only_not_live_git_scan"
        inventory_type = $Definition.inventory_type
        git_status_short = $Definition.git_status_short
        git_diff_name_status = $Definition.git_diff_name_status
        git_diff_numstat = $Definition.git_diff_numstat
        staged_paths = $Definition.staged_paths
        tracked_wip_paths = $Definition.tracked_wip_paths
        untracked_paths = $Definition.untracked_paths
        allowed_wip_paths = $Definition.allowed_wip_paths
        forbidden_wip_paths = $Definition.forbidden_wip_paths
        churn_threshold_policy = New-R18WipChurnThresholdPolicy -Definition $Definition
        expected_classification_type = $Definition.expected_classification_type
        expected_action_recommendation = $Definition.expected_action_recommendation
        runner_state_ref = $script:R18RunnerStateRef
        failure_event_ref = $script:R18FailureEventRef
        evidence_refs = @($inventoryRef, "contracts/runtime/r18_wip_classifier.contract.json")
        authority_refs = Get-R18WipAuthorityRefs
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Get-R18WipClassificationShape {
    param([Parameter(Mandatory = $true)][object]$Inventory)

    $allTrackedAllowed = $true
    foreach ($path in @($Inventory.tracked_wip_paths)) {
        if (-not (Test-R18WipPathInsideAny -Path ([string]$path) -Prefixes @($Inventory.allowed_wip_paths))) {
            $allTrackedAllowed = $false
        }
    }

    $untrackedOverlapsForbidden = $false
    foreach ($path in @($Inventory.untracked_paths)) {
        if (Test-R18WipPathInsideAny -Path ([string]$path) -Prefixes @($Inventory.forbidden_wip_paths)) {
            $untrackedOverlapsForbidden = $true
        }
    }

    $withinThreshold = [bool]$Inventory.churn_threshold_policy.within_threshold

    switch ([string]$Inventory.inventory_type) {
        "no_wip" {
            return [ordered]@{
                classification_type = "no_wip_safe"
                action_recommendation = "continue_without_wip_action"
                safety_level = "safe"
                safe_to_continue = $true
                operator_decision_required = $false
                next_safe_step = "Continue without WIP action; preserve R18-011 non-runtime boundary."
            }
        }
        "scoped_tracked_wip" {
            return [ordered]@{
                classification_type = "scoped_tracked_wip_safe_to_preserve"
                action_recommendation = "preserve_scoped_wip_for_future_task"
                safety_level = "safe_to_preserve"
                safe_to_continue = ($allTrackedAllowed -and @($Inventory.staged_paths).Count -eq 0)
                operator_decision_required = $false
                next_safe_step = "Preserve scoped tracked WIP for the future task; do not stage, commit, push, clean, or abandon it in R18-011."
            }
        }
        "unexpected_tracked_wip" {
            return [ordered]@{
                classification_type = "unexpected_tracked_wip_operator_decision_required"
                action_recommendation = "stop_and_request_operator_decision"
                safety_level = "operator_decision_required"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop and request operator decision for unexpected tracked WIP."
            }
        }
        "historical_evidence_edit" {
            return [ordered]@{
                classification_type = "historical_evidence_edit_blocked"
                action_recommendation = "block_historical_evidence_edit"
                safety_level = "blocked"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Block historical R13/R14/R15/R16 evidence edit and request operator decision."
            }
        }
        "operator_local_backup_path" {
            return [ordered]@{
                classification_type = "operator_local_backup_path_blocked"
                action_recommendation = "stop_and_request_operator_decision"
                safety_level = "blocked"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Leave operator-local backup paths untracked and unstaged; request operator decision before any future action."
            }
        }
        "untracked_local_notes" {
            return [ordered]@{
                classification_type = "untracked_local_notes_do_not_stage"
                action_recommendation = "leave_untracked_local_notes_unstaged"
                safety_level = "safe_untracked_do_not_stage"
                safe_to_continue = (-not $untrackedOverlapsForbidden)
                operator_decision_required = $untrackedOverlapsForbidden
                next_safe_step = "Leave untracked local notes unstaged because they are outside committed evidence scope."
            }
        }
        "generated_artifact_churn" {
            return [ordered]@{
                classification_type = "generated_artifact_churn_review_required"
                action_recommendation = "review_generated_artifact_churn"
                safety_level = "review_required"
                safe_to_continue = $withinThreshold
                operator_decision_required = (-not $withinThreshold)
                next_safe_step = "Review generated artifact churn against the deterministic threshold policy before continuation."
            }
        }
        "staged_files_present" {
            return [ordered]@{
                classification_type = "staged_files_present_blocked"
                action_recommendation = "unstage_before_continue"
                safety_level = "blocked"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop because staged files are present; R18-011 records the block but does not unstage files."
            }
        }
        default {
            throw "Unknown R18 WIP inventory type '$($Inventory.inventory_type)'."
        }
    }
}

function New-R18WipClassificationPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Inventory,
        [Parameter(Mandatory = $true)][string]$InventoryFileName
    )

    $shape = Get-R18WipClassificationShape -Inventory $Inventory
    $inventoryType = [string]$Inventory.inventory_type
    $classificationRef = Get-R18WipClassificationRef -InventoryType $inventoryType
    $inventoryRef = Get-R18WipInventoryRef -FileName $InventoryFileName

    $stopConditions = @()
    if (-not [bool]$shape.safe_to_continue) {
        $stopConditions += "safe_to_continue_false"
    }
    if ([bool]$shape.operator_decision_required) {
        $stopConditions += "operator_decision_required"
    }
    if (@($Inventory.staged_paths).Count -gt 0) {
        $stopConditions += "staged_paths_present"
    }
    if ($inventoryType -eq "operator_local_backup_path") {
        $stopConditions += "operator_local_backup_path_detected"
    }
    if ($inventoryType -eq "historical_evidence_edit") {
        $stopConditions += "historical_evidence_edit_detected"
    }
    if ($stopConditions.Count -eq 0) {
        $stopConditions += "none"
    }

    return [ordered]@{
        artifact_type = "r18_wip_classification_packet"
        contract_version = "v1"
        classification_id = "r18_011_classification_$inventoryType"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        classification_status = "classification_seed_packet_only_not_cleanup"
        source_inventory_ref = $inventoryRef
        classification_type = $shape.classification_type
        action_recommendation = $shape.action_recommendation
        safety_level = $shape.safety_level
        tracked_wip_present = (@($Inventory.tracked_wip_paths).Count -gt 0)
        untracked_paths_present = (@($Inventory.untracked_paths).Count -gt 0)
        staged_paths_present = (@($Inventory.staged_paths).Count -gt 0)
        historical_evidence_edit_detected = ($inventoryType -eq "historical_evidence_edit")
        operator_local_backup_path_detected = ($inventoryType -eq "operator_local_backup_path")
        generated_artifact_churn_detected = ($inventoryType -eq "generated_artifact_churn")
        allowed_wip_paths = @($Inventory.allowed_wip_paths)
        forbidden_wip_paths = @($Inventory.forbidden_wip_paths)
        safe_to_continue = [bool]$shape.safe_to_continue
        operator_decision_required = [bool]$shape.operator_decision_required
        stop_conditions = $stopConditions
        escalation_conditions = @("operator_decision_required", "forbidden_path_overlap", "generated_churn_above_threshold", "staged_files_present")
        next_safe_step = $shape.next_safe_step
        runner_state_ref = $Inventory.runner_state_ref
        failure_event_ref = $Inventory.failure_event_ref
        evidence_refs = @($inventoryRef, $classificationRef, "contracts/runtime/r18_wip_classifier.contract.json")
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        operator_local_backup_paths_stageable = $false
        recommended_stage_paths = @()
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipClassifierResults {
    param(
        [Parameter(Mandatory = $true)][object[]]$Inventories,
        [Parameter(Mandatory = $true)][object[]]$Classifications
    )

    $entries = @()
    foreach ($inventory in @($Inventories)) {
        $classification = @($Classifications | Where-Object { $_.source_inventory_ref -eq (Get-R18WipInventoryRef -FileName ([string](Get-R18WipDefinitionByType -InventoryType ([string]$inventory.inventory_type)).file)) })[0]
        $entries += [ordered]@{
            result_id = "r18_011_result_$($inventory.inventory_type)"
            inventory_id = $inventory.inventory_id
            inventory_type = $inventory.inventory_type
            classification_packet_ref = Get-R18WipClassificationRef -InventoryType ([string]$inventory.inventory_type)
            classification_type = $classification.classification_type
            action_recommendation = $classification.action_recommendation
            safe_to_continue = $classification.safe_to_continue
            operator_decision_required = $classification.operator_decision_required
            evidence_refs = @($classification.evidence_refs)
            authority_refs = @($classification.authority_refs)
            runtime_flags = Get-R18WipRuntimeFlags
        }
    }

    return [ordered]@{
        artifact_type = "r18_wip_classifier_results"
        contract_version = "v1"
        results_id = "aioffice-r18-011-wip-classifier-results-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        result_status = "deterministic_seed_inventory_classification_results_only_not_cleanup"
        classification_mode = "generator_over_committed_seed_inventory_artifacts_only"
        inventory_count = @($Inventories).Count
        classification_packet_count = @($Classifications).Count
        classification_results = $entries
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        positive_claims = @("r18_wip_inventory_samples_created", "r18_wip_classification_packets_created", "r18_wip_classifier_results_created")
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipClassifierCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Inventories,
        [Parameter(Mandatory = $true)][object[]]$Classifications
    )

    return [ordered]@{
        artifact_type = "r18_wip_classifier_check_report"
        contract_version = "v1"
        check_report_id = "aioffice-r18-011-wip-classifier-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18ClassifierVerdict
        inventory_count = @($Inventories).Count
        classification_packet_count = @($Classifications).Count
        required_inventory_field_count = @($script:R18RequiredInventoryFields).Count
        required_classification_field_count = @($script:R18RequiredClassificationFields).Count
        status_boundary = "R18 active through R18-011 only; R18-012 through R18-028 planned only."
        checks = @(
            [ordered]@{ check_id = "required_artifacts"; status = "passed" },
            [ordered]@{ check_id = "inventory_samples"; status = "passed" },
            [ordered]@{ check_id = "classification_packets"; status = "passed" },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-011 only; R18-012 through R18-028 planned only." }
        )
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        positive_claims = @("r18_wip_classifier_validator_created", "r18_wip_classifier_fixtures_created")
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipClassifierSnapshot {
    param(
        [Parameter(Mandatory = $true)][object[]]$Classifications
    )

    return [ordered]@{
        artifact_type = "r18_wip_classifier_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-011-wip-classifier-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        r18_status = "active_through_r18_011_only"
        planned_only_boundary = "R18-012 through R18-028 remain planned only"
        snapshot_status = "operator_surface_seed_snapshot_only_not_runtime_ui"
        classification_summary = @($Classifications | ForEach-Object {
                [ordered]@{
                    classification_id = $_.classification_id
                    classification_type = $_.classification_type
                    action_recommendation = $_.action_recommendation
                    safe_to_continue = $_.safe_to_continue
                    operator_decision_required = $_.operator_decision_required
                }
            })
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        positive_claims = @("r18_wip_classifier_proof_review_created")
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_wip_classifier_evidence_index"
        contract_version = "v1"
        evidence_index_id = "aioffice-r18-011-wip-classifier-evidence-index-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18ClassifierVerdict
        evidence_refs = Get-R18WipEvidenceRefs
        authority_refs = Get-R18WipAuthorityRefs
        validation_refs = Get-R18WipValidationRefs
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipProofReviewText {
    return @"
# R18-011 WIP Classifier Proof Review

Verdict: $script:R18ClassifierVerdict.

R18-011 creates a deterministic WIP classifier foundation over committed seed git inventory artifacts only. It creates a classifier contract, profile, eight seed inventory samples, eight classification packets, result/check artifacts, fixtures, and this proof-review package.

Non-claims preserved: no live git scan, no WIP cleanup, no WIP abandonment, no file restore/delete, no staging, no commit, no push, no remote branch verifier runtime, no continuation packet generation, no new-context prompt generation, no recovery runtime/action, no work-order execution, no board/card runtime mutation, no A2A messages, no live agent or skill execution, no API invocation, no automatic new-thread creation, no product runtime, no solved Codex compaction/reliability, and no main merge.
"@
}

function New-R18WipValidationManifestText {
    $commands = Get-R18WipValidationRefs
    $lines = @("# R18-011 Validation Manifest", "", "Expected status truth after this package: R18 active through R18-011 only; R18-012 through R18-028 planned only.", "", "Required validation commands:")
    foreach ($command in $commands) {
        $lines += ("- ``{0}``" -f $command)
    }
    $lines += ""
    $lines += "The WIP classifier is deterministic over seed inventory artifacts only and performs no cleanup, abandonment, restore/delete, staging, commit, push, remote verification, continuation generation, new-context prompt generation, recovery action, work-order execution, live agent/skill/A2A runtime, API invocation, or automatic new-thread creation."
    return ($lines -join [Environment]::NewLine)
}

function New-R18WipFixtureManifest {
    $files = @(
        "invalid_missing_inventory_id.json",
        "invalid_missing_git_status_short.json",
        "invalid_missing_diff_name_status.json",
        "invalid_missing_classification_id.json",
        "invalid_unknown_classification_type.json",
        "invalid_missing_action_recommendation.json",
        "invalid_missing_operator_decision_policy.json",
        "invalid_missing_allowed_wip_paths.json",
        "invalid_missing_forbidden_wip_paths.json",
        "invalid_historical_evidence_edit_marked_safe.json",
        "invalid_operator_local_backup_marked_safe.json",
        "invalid_unexpected_tracked_wip_marked_safe.json",
        "invalid_staged_files_marked_safe.json",
        "invalid_generated_churn_without_threshold.json",
        "invalid_missing_runner_state_ref.json",
        "invalid_missing_failure_event_ref.json",
        "invalid_missing_evidence_refs.json",
        "invalid_missing_authority_refs.json",
        "invalid_remote_branch_verifier_runtime_claim.json",
        "invalid_remote_branch_verified_claim.json",
        "invalid_continuation_packet_generation_claim.json",
        "invalid_new_context_prompt_generation_claim.json",
        "invalid_recovery_action_claim.json",
        "invalid_wip_cleanup_claim.json",
        "invalid_wip_abandonment_claim.json",
        "invalid_stage_commit_push_claim.json",
        "invalid_work_order_execution_claim.json",
        "invalid_live_runner_runtime_claim.json",
        "invalid_skill_execution_claim.json",
        "invalid_a2a_message_sent_claim.json",
        "invalid_board_runtime_mutation_claim.json",
        "invalid_api_invocation_claim.json",
        "invalid_automatic_new_thread_creation_claim.json",
        "invalid_r18_012_completion_claim.json"
    )

    return [ordered]@{
        artifact_type = "r18_wip_classifier_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        fixture_count = $files.Count
        fixtures = $files
        runtime_flags = Get-R18WipRuntimeFlags
        non_claims = Get-R18WipNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18WipFixtureDefinitions {
    $fixtures = @(
        @{ file = "invalid_missing_inventory_id.json"; target = "inventory:no_wip"; operation = "remove"; path = "inventory_id"; fragment = "inventory_id" },
        @{ file = "invalid_missing_git_status_short.json"; target = "inventory:no_wip"; operation = "remove"; path = "git_status_short"; fragment = "git_status_short" },
        @{ file = "invalid_missing_diff_name_status.json"; target = "inventory:no_wip"; operation = "remove"; path = "git_diff_name_status"; fragment = "git_diff_name_status" },
        @{ file = "invalid_missing_classification_id.json"; target = "classification:no_wip"; operation = "remove"; path = "classification_id"; fragment = "classification_id" },
        @{ file = "invalid_unknown_classification_type.json"; target = "classification:no_wip"; operation = "set"; path = "classification_type"; value = "unknown_classification_type"; fragment = "unknown classification type" },
        @{ file = "invalid_missing_action_recommendation.json"; target = "classification:no_wip"; operation = "remove"; path = "action_recommendation"; fragment = "action_recommendation" },
        @{ file = "invalid_missing_operator_decision_policy.json"; target = "contract"; operation = "remove"; path = "operator_decision_policy"; fragment = "operator_decision_policy" },
        @{ file = "invalid_missing_allowed_wip_paths.json"; target = "inventory:scoped_tracked_wip"; operation = "remove"; path = "allowed_wip_paths"; fragment = "allowed_wip_paths" },
        @{ file = "invalid_missing_forbidden_wip_paths.json"; target = "inventory:no_wip"; operation = "remove"; path = "forbidden_wip_paths"; fragment = "forbidden_wip_paths" },
        @{ file = "invalid_historical_evidence_edit_marked_safe.json"; target = "classification:historical_evidence_edit"; operation = "set"; path = "safe_to_continue"; value = $true; fragment = "safe_to_continue does not match deterministic rule" },
        @{ file = "invalid_operator_local_backup_marked_safe.json"; target = "classification:operator_local_backup_path"; operation = "set"; path = "safe_to_continue"; value = $true; fragment = "safe_to_continue does not match deterministic rule" },
        @{ file = "invalid_unexpected_tracked_wip_marked_safe.json"; target = "classification:unexpected_tracked_wip"; operation = "set"; path = "safe_to_continue"; value = $true; fragment = "safe_to_continue does not match deterministic rule" },
        @{ file = "invalid_staged_files_marked_safe.json"; target = "classification:staged_files_present"; operation = "set"; path = "safe_to_continue"; value = $true; fragment = "safe_to_continue does not match deterministic rule" },
        @{ file = "invalid_generated_churn_without_threshold.json"; target = "inventory:generated_artifact_churn"; operation = "remove"; path = "churn_threshold_policy"; fragment = "churn_threshold_policy" },
        @{ file = "invalid_missing_runner_state_ref.json"; target = "classification:no_wip"; operation = "remove"; path = "runner_state_ref"; fragment = "runner_state_ref" },
        @{ file = "invalid_missing_failure_event_ref.json"; target = "classification:no_wip"; operation = "remove"; path = "failure_event_ref"; fragment = "failure_event_ref" },
        @{ file = "invalid_missing_evidence_refs.json"; target = "classification:no_wip"; operation = "remove"; path = "evidence_refs"; fragment = "evidence_refs" },
        @{ file = "invalid_missing_authority_refs.json"; target = "classification:no_wip"; operation = "remove"; path = "authority_refs"; fragment = "authority_refs" },
        @{ file = "invalid_remote_branch_verifier_runtime_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.remote_branch_verifier_runtime_implemented"; value = $true; fragment = "remote_branch_verifier_runtime_implemented" },
        @{ file = "invalid_remote_branch_verified_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.remote_branch_verified"; value = $true; fragment = "remote_branch_verified" },
        @{ file = "invalid_continuation_packet_generation_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.continuation_packet_generated"; value = $true; fragment = "continuation_packet_generated" },
        @{ file = "invalid_new_context_prompt_generation_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.new_context_prompt_generated"; value = $true; fragment = "new_context_prompt_generated" },
        @{ file = "invalid_recovery_action_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.recovery_action_performed"; value = $true; fragment = "recovery_action_performed" },
        @{ file = "invalid_wip_cleanup_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.wip_cleanup_performed"; value = $true; fragment = "wip_cleanup_performed" },
        @{ file = "invalid_wip_abandonment_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.wip_abandonment_performed"; value = $true; fragment = "wip_abandonment_performed" },
        @{ file = "invalid_stage_commit_push_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.staging_performed"; value = $true; fragment = "staging_performed" },
        @{ file = "invalid_work_order_execution_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.work_order_execution_performed"; value = $true; fragment = "work_order_execution_performed" },
        @{ file = "invalid_live_runner_runtime_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.live_runner_runtime_executed"; value = $true; fragment = "live_runner_runtime_executed" },
        @{ file = "invalid_skill_execution_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.live_skill_execution_performed"; value = $true; fragment = "live_skill_execution_performed" },
        @{ file = "invalid_a2a_message_sent_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.a2a_message_sent"; value = $true; fragment = "a2a_message_sent" },
        @{ file = "invalid_board_runtime_mutation_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.board_runtime_mutation_performed"; value = $true; fragment = "board_runtime_mutation_performed" },
        @{ file = "invalid_api_invocation_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.openai_api_invoked"; value = $true; fragment = "openai_api_invoked" },
        @{ file = "invalid_automatic_new_thread_creation_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.automatic_new_thread_creation_performed"; value = $true; fragment = "automatic_new_thread_creation_performed" },
        @{ file = "invalid_r18_012_completion_claim.json"; target = "classification:no_wip"; operation = "set"; path = "runtime_flags.r18_012_completed"; value = $true; fragment = "r18_012_completed" }
    )

    return @($fixtures | ForEach-Object {
            [ordered]@{
                artifact_type = "r18_wip_classifier_invalid_fixture"
                contract_version = "v1"
                fixture_id = ([System.IO.Path]::GetFileNameWithoutExtension([string]$_.file))
                source_task = $script:R18SourceTask
                target = $_.target
                operation = $_.operation
                path = $_.path
                value = if ($_.ContainsKey("value")) { $_.value } else { $null }
                expected_failure_fragments = @($_.fragment)
                runtime_flags = Get-R18WipRuntimeFlags
                non_claims = Get-R18WipNonClaims
                rejected_claims = $script:R18RejectedClaims
                file = $_.file
            }
        })
}

function Assert-R18WipCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18WipRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18WipCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18WipArray {
    param($Value, [Parameter(Mandatory = $true)][string]$Context)
    Assert-R18WipCondition -Condition ($null -ne $Value) -Message "$Context must be present."
    Assert-R18WipCondition -Condition ($Value -is [array] -or $Value -is [System.Collections.IEnumerable]) -Message "$Context must be array-like."
}

function Assert-R18WipRuntimeFlags {
    param($RuntimeFlags, [Parameter(Mandatory = $true)][string]$Context)

    Assert-R18WipCondition -Condition ($null -ne $RuntimeFlags) -Message "$Context missing runtime_flags."
    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18WipCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context missing runtime flag '$field'."
        Assert-R18WipCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Assert-R18WipPositiveClaims {
    param([Parameter(Mandatory = $true)][object]$Object, [Parameter(Mandatory = $true)][string]$Context)

    if ($Object.PSObject.Properties.Name -notcontains "positive_claims") {
        return
    }

    foreach ($claim in @($Object.positive_claims)) {
        Assert-R18WipCondition -Condition (@($script:R18AllowedPositiveClaims) -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
    }
}

function Assert-R18WipRefs {
    param($Refs, [Parameter(Mandatory = $true)][string]$Context)
    Assert-R18WipCondition -Condition (@($Refs).Count -gt 0) -Message "$Context missing refs."
    foreach ($ref in @($Refs)) {
        $refText = [string]$ref
        Assert-R18WipCondition -Condition (-not [string]::IsNullOrWhiteSpace($refText)) -Message "$Context contains blank ref."
        Assert-R18WipCondition -Condition ($refText -notmatch '^\.local_backups/') -Message "$Context must not reference operator-local backup path '$refText'."
        Assert-R18WipCondition -Condition ($refText -notmatch '^state/proof_reviews/r1[3-6]') -Message "$Context must not edit historical R13/R14/R15/R16 evidence '$refText'."
    }
}

function Assert-R18WipContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    foreach ($field in @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_inventory_fields", "required_classification_fields", "allowed_classification_types", "allowed_action_recommendations", "required_runtime_false_flags", "inventory_policy", "classification_policy", "safety_policy", "operator_decision_policy", "runner_state_policy", "failure_event_policy", "evidence_policy", "authority_policy", "remote_verification_boundary_policy", "continuation_boundary_policy", "path_policy", "api_policy", "execution_policy", "refusal_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs")) {
        Assert-R18WipCondition -Condition ($Contract.PSObject.Properties.Name -contains $field) -Message "R18 WIP classifier contract missing required field '$field'."
    }
    Assert-R18WipCondition -Condition ($Contract.artifact_type -eq "r18_wip_classifier_contract") -Message "R18 WIP classifier contract artifact_type is invalid."
    Assert-R18WipCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 WIP classifier contract source_task must be R18-011."
    foreach ($field in $script:R18RequiredInventoryFields) {
        Assert-R18WipCondition -Condition (@($Contract.required_inventory_fields) -contains $field) -Message "R18 WIP classifier contract required_inventory_fields missing '$field'."
    }
    foreach ($field in $script:R18RequiredClassificationFields) {
        Assert-R18WipCondition -Condition (@($Contract.required_classification_fields) -contains $field) -Message "R18 WIP classifier contract required_classification_fields missing '$field'."
    }
    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18WipCondition -Condition (@($Contract.required_runtime_false_flags) -contains $field) -Message "R18 WIP classifier contract required_runtime_false_flags missing '$field'."
    }
    Assert-R18WipCondition -Condition ([bool]$Contract.execution_policy.classifier_live_runtime_allowed -eq $false) -Message "R18 WIP classifier contract must not allow live runtime."
    Assert-R18WipCondition -Condition ([bool]$Contract.inventory_policy.live_git_scan_allowed -eq $false) -Message "R18 WIP classifier contract must not allow live git scan."
    Assert-R18WipRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 WIP classifier contract"
    Assert-R18WipPositiveClaims -Object $Contract -Context "R18 WIP classifier contract"
}

function Assert-R18WipInventory {
    param([Parameter(Mandatory = $true)][object]$Inventory)

    Assert-R18WipRequiredFields -Object $Inventory -FieldNames $script:R18RequiredInventoryFields -Context "R18 WIP inventory sample"
    Assert-R18WipCondition -Condition ($Inventory.artifact_type -eq "r18_wip_inventory_sample") -Message "R18 WIP inventory sample artifact_type is invalid."
    Assert-R18WipCondition -Condition ($Inventory.source_task -eq $script:R18SourceTask) -Message "R18 WIP inventory sample source_task must be R18-011."
    Assert-R18WipCondition -Condition ($Inventory.inventory_status -eq "seed_inventory_only_not_live_git_scan") -Message "R18 WIP inventory sample status must be seed_inventory_only_not_live_git_scan."
    Assert-R18WipCondition -Condition (@($script:R18AllowedInventoryTypes) -contains [string]$Inventory.inventory_type) -Message "R18 WIP inventory sample uses unknown inventory type '$($Inventory.inventory_type)'."
    Assert-R18WipCondition -Condition (@($script:R18AllowedClassificationTypes) -contains [string]$Inventory.expected_classification_type) -Message "R18 WIP inventory sample expected classification type is unknown."
    Assert-R18WipCondition -Condition (@($script:R18AllowedActionRecommendations) -contains [string]$Inventory.expected_action_recommendation) -Message "R18 WIP inventory sample expected action recommendation is unknown."
    foreach ($arrayField in @("git_status_short", "git_diff_name_status", "git_diff_numstat", "staged_paths", "tracked_wip_paths", "untracked_paths", "allowed_wip_paths", "forbidden_wip_paths", "evidence_refs", "authority_refs")) {
        Assert-R18WipArray -Value $Inventory.$arrayField -Context "R18 WIP inventory sample $arrayField"
    }
    Assert-R18WipCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Inventory.runner_state_ref)) -Message "R18 WIP inventory sample missing runner_state_ref."
    Assert-R18WipCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Inventory.failure_event_ref)) -Message "R18 WIP inventory sample missing failure_event_ref."
    Assert-R18WipCondition -Condition ($Inventory.PSObject.Properties.Name -contains "churn_threshold_policy" -and $null -ne $Inventory.churn_threshold_policy) -Message "R18 WIP inventory sample missing churn_threshold_policy."
    Assert-R18WipCondition -Condition ([bool]$Inventory.churn_threshold_policy.threshold_required -eq $true) -Message "R18 WIP inventory sample churn_threshold_policy must be required."
    if ($Inventory.inventory_type -eq "generated_artifact_churn") {
        Assert-R18WipCondition -Condition ($Inventory.churn_threshold_policy.PSObject.Properties.Name -contains "max_total_line_delta_without_review") -Message "generated_artifact_churn inventory missing churn_threshold_policy max_total_line_delta_without_review."
    }
    if ($Inventory.inventory_type -eq "historical_evidence_edit") {
        Assert-R18WipCondition -Condition ((@($Inventory.tracked_wip_paths) -join "`n") -match 'state/proof_reviews/r1[3-6]') -Message "historical_evidence_edit inventory must include historical R13/R14/R15/R16 evidence path."
    }
    if ($Inventory.inventory_type -eq "operator_local_backup_path") {
        Assert-R18WipCondition -Condition ((@($Inventory.untracked_paths) -join "`n") -match '^\.local_backups/') -Message "operator_local_backup_path inventory must include .local_backups/ path."
    }
    Assert-R18WipRefs -Refs @($Inventory.evidence_refs) -Context "R18 WIP inventory sample evidence_refs"
    Assert-R18WipRefs -Refs @($Inventory.authority_refs) -Context "R18 WIP inventory sample authority_refs"
    Assert-R18WipRuntimeFlags -RuntimeFlags $Inventory.runtime_flags -Context "R18 WIP inventory sample"
}

function Assert-R18WipClassification {
    param(
        [Parameter(Mandatory = $true)][object]$Classification,
        [Parameter(Mandatory = $true)][object]$Inventory
    )

    Assert-R18WipRequiredFields -Object $Classification -FieldNames $script:R18RequiredClassificationFields -Context "R18 WIP classification packet"
    Assert-R18WipCondition -Condition ($Classification.artifact_type -eq "r18_wip_classification_packet") -Message "R18 WIP classification packet artifact_type is invalid."
    Assert-R18WipCondition -Condition ($Classification.source_task -eq $script:R18SourceTask) -Message "R18 WIP classification packet source_task must be R18-011."
    Assert-R18WipCondition -Condition ($Classification.classification_status -eq "classification_seed_packet_only_not_cleanup") -Message "R18 WIP classification packet status must be classification_seed_packet_only_not_cleanup."
    Assert-R18WipCondition -Condition (@($script:R18AllowedClassificationTypes) -contains [string]$Classification.classification_type) -Message "R18 WIP classification packet uses unknown classification type '$($Classification.classification_type)'."
    Assert-R18WipCondition -Condition (@($script:R18AllowedActionRecommendations) -contains [string]$Classification.action_recommendation) -Message "R18 WIP classification packet uses unknown action recommendation '$($Classification.action_recommendation)'."
    Assert-R18WipCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Classification.runner_state_ref)) -Message "R18 WIP classification packet missing runner_state_ref."
    Assert-R18WipCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Classification.failure_event_ref)) -Message "R18 WIP classification packet missing failure_event_ref."
    foreach ($arrayField in @("allowed_wip_paths", "forbidden_wip_paths", "stop_conditions", "escalation_conditions", "evidence_refs", "authority_refs", "validation_refs")) {
        Assert-R18WipArray -Value $Classification.$arrayField -Context "R18 WIP classification packet $arrayField"
    }
    Assert-R18WipRefs -Refs @($Classification.evidence_refs) -Context "R18 WIP classification packet evidence_refs"
    Assert-R18WipRefs -Refs @($Classification.authority_refs) -Context "R18 WIP classification packet authority_refs"
    Assert-R18WipRuntimeFlags -RuntimeFlags $Classification.runtime_flags -Context "R18 WIP classification packet"

    $expected = Get-R18WipClassificationShape -Inventory $Inventory
    Assert-R18WipCondition -Condition ($Classification.classification_type -eq $expected.classification_type) -Message "R18 WIP classification packet classification_type does not match deterministic rule for $($Inventory.inventory_type)."
    Assert-R18WipCondition -Condition ($Classification.action_recommendation -eq $expected.action_recommendation) -Message "R18 WIP classification packet action_recommendation does not match deterministic rule for $($Inventory.inventory_type)."
    Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq [bool]$expected.safe_to_continue) -Message "R18 WIP classification packet safe_to_continue does not match deterministic rule for $($Inventory.inventory_type)."
    Assert-R18WipCondition -Condition ([bool]$Classification.operator_decision_required -eq [bool]$expected.operator_decision_required) -Message "R18 WIP classification packet operator_decision_required does not match deterministic rule for $($Inventory.inventory_type)."
    Assert-R18WipCondition -Condition ($Inventory.expected_classification_type -eq $Classification.classification_type) -Message "R18 WIP classification packet does not match inventory expected_classification_type."
    Assert-R18WipCondition -Condition ($Inventory.expected_action_recommendation -eq $Classification.action_recommendation) -Message "R18 WIP classification packet does not match inventory expected_action_recommendation."

    switch ([string]$Inventory.inventory_type) {
        "no_wip" {
            Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq $true -and [bool]$Classification.operator_decision_required -eq $false) -Message "no_wip must classify as safe without operator decision."
        }
        "scoped_tracked_wip" {
            Assert-R18WipCondition -Condition ($Classification.classification_type -eq "scoped_tracked_wip_safe_to_preserve" -and [bool]$Classification.safe_to_continue -eq $true) -Message "Scoped tracked WIP with only allowed paths must be safe to preserve."
        }
        "unexpected_tracked_wip" {
            Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq $false -and [bool]$Classification.operator_decision_required -eq $true) -Message "Unexpected tracked WIP must require operator decision and must not be safe."
        }
        "historical_evidence_edit" {
            Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq $false -and [bool]$Classification.historical_evidence_edit_detected -eq $true) -Message "Historical evidence edit must be blocked."
        }
        "operator_local_backup_path" {
            Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq $false -and [bool]$Classification.operator_local_backup_path_detected -eq $true -and [bool]$Classification.operator_local_backup_paths_stageable -eq $false) -Message "Operator-local backup path must be blocked and not stageable."
        }
        "untracked_local_notes" {
            Assert-R18WipCondition -Condition ($Classification.action_recommendation -eq "leave_untracked_local_notes_unstaged") -Message "Untracked local notes must not be staged."
            Assert-R18WipCondition -Condition (@($Classification.recommended_stage_paths).Count -eq 0) -Message "Untracked local notes are marked for staging."
        }
        "generated_artifact_churn" {
            Assert-R18WipCondition -Condition ($Inventory.PSObject.Properties.Name -contains "churn_threshold_policy" -and $null -ne $Inventory.churn_threshold_policy) -Message "Generated artifact churn lacks threshold policy."
            Assert-R18WipCondition -Condition ($Classification.action_recommendation -eq "review_generated_artifact_churn") -Message "Generated artifact churn must require review."
        }
        "staged_files_present" {
            Assert-R18WipCondition -Condition ([bool]$Classification.safe_to_continue -eq $false -and [bool]$Classification.staged_paths_present -eq $true) -Message "Staged files must be blocked."
        }
    }
}

function Assert-R18WipResults {
    param(
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object[]]$Inventories,
        [Parameter(Mandatory = $true)][object[]]$Classifications
    )

    Assert-R18WipCondition -Condition ($Results.artifact_type -eq "r18_wip_classifier_results") -Message "R18 WIP classifier results artifact_type is invalid."
    Assert-R18WipCondition -Condition ([int]$Results.inventory_count -eq @($Inventories).Count) -Message "R18 WIP classifier results inventory_count is invalid."
    Assert-R18WipCondition -Condition ([int]$Results.classification_packet_count -eq @($Classifications).Count) -Message "R18 WIP classifier results classification_packet_count is invalid."
    foreach ($entry in @($Results.classification_results)) {
        Assert-R18WipCondition -Condition (@($script:R18AllowedClassificationTypes) -contains [string]$entry.classification_type) -Message "R18 WIP classifier result entry uses unknown classification type."
        Assert-R18WipCondition -Condition (@($script:R18AllowedActionRecommendations) -contains [string]$entry.action_recommendation) -Message "R18 WIP classifier result entry uses unknown action recommendation."
        Assert-R18WipRuntimeFlags -RuntimeFlags $entry.runtime_flags -Context "R18 WIP classifier result entry"
    }
    Assert-R18WipRuntimeFlags -RuntimeFlags $Results.runtime_flags -Context "R18 WIP classifier results"
    Assert-R18WipPositiveClaims -Object $Results -Context "R18 WIP classifier results"
}

function Assert-R18WipReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18WipCondition -Condition ($Report.artifact_type -eq "r18_wip_classifier_check_report") -Message "R18 WIP classifier check report artifact_type is invalid."
    Assert-R18WipCondition -Condition ($Report.aggregate_verdict -eq $script:R18ClassifierVerdict) -Message "R18 WIP classifier check report aggregate verdict is invalid."
    Assert-R18WipRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 WIP classifier check report"
    Assert-R18WipPositiveClaims -Object $Report -Context "R18 WIP classifier check report"
}

function Assert-R18WipSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18WipCondition -Condition ($Snapshot.artifact_type -eq "r18_wip_classifier_snapshot") -Message "R18 WIP classifier snapshot artifact_type is invalid."
    Assert-R18WipCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_011_only") -Message "R18 WIP classifier snapshot status is invalid."
    Assert-R18WipRuntimeFlags -RuntimeFlags $Snapshot.runtime_flags -Context "R18 WIP classifier snapshot"
    Assert-R18WipPositiveClaims -Object $Snapshot -Context "R18 WIP classifier snapshot"
}

function Get-R18WipTaskStatusMap {
    param([Parameter(Mandatory = $true)][string]$Text, [Parameter(Mandatory = $true)][string]$Context)

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

function Test-R18WipClassifierStatusTruth {
    param([string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18WipPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-020 only",
            "R18-021 through R18-028 planned only",
            "R18-010 created compact failure detector foundation only",
            "Failure detection is deterministic over seed signal artifacts only",
            "Failure events are not recovery completion",
            "R18-011 created WIP classifier foundation only",
            "WIP classification is deterministic over seed git inventory artifacts only",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No files were restored or deleted",
            "No staging, commit, or push was performed by the classifier",
            "R18-012 created remote branch verifier foundation only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "Continuation packets are not new-context prompts",
            "R18-014 created new-context prompt generator foundation only",
            "Automatic new-thread creation is not implemented",
            "No recovery action was performed",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No live A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No product runtime is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18WipTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18WipTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18WipCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 20) {
            Assert-R18WipCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-020."
        }
        else {
            Assert-R18WipCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-020."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[1-8])') {
        throw "Status surface claims R18 beyond R18-020."
    }
    if ($combinedText -match '(?i)R18-(02[1-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-021 or later completion."
    }
}

function Test-R18WipClassifierSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Inventories,
        [Parameter(Mandatory = $true)][object[]]$Classifications,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot)
    )

    Assert-R18WipContract -Contract $Contract
    Assert-R18WipRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 WIP classifier profile"
    Assert-R18WipPositiveClaims -Object $Profile -Context "R18 WIP classifier profile"
    Assert-R18WipCondition -Condition (@($Inventories).Count -eq @($script:R18InventoryDefinitions).Count) -Message "R18 WIP inventory samples are missing."
    Assert-R18WipCondition -Condition (@($Classifications).Count -eq @($script:R18InventoryDefinitions).Count) -Message "R18 WIP classification packets are missing."

    foreach ($inventory in @($Inventories)) {
        Assert-R18WipInventory -Inventory $inventory
        $definition = Get-R18WipDefinitionByType -InventoryType ([string]$inventory.inventory_type)
        $inventoryRef = Get-R18WipInventoryRef -FileName ([string]$definition.file)
        $matchingClassifications = @($Classifications | Where-Object { $_.source_inventory_ref -eq $inventoryRef })
        Assert-R18WipCondition -Condition ($matchingClassifications.Count -eq 1) -Message "R18 WIP inventory '$($inventory.inventory_type)' does not have exactly one classification packet."
        Assert-R18WipClassification -Classification $matchingClassifications[0] -Inventory $inventory
    }

    Assert-R18WipResults -Results $Results -Inventories $Inventories -Classifications $Classifications
    Assert-R18WipReport -Report $Report
    Assert-R18WipSnapshot -Snapshot $Snapshot
    Test-R18WipClassifierStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        InventoryCount = @($Inventories).Count
        ClassificationPacketCount = @($Classifications).Count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18WipClassifier {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot))

    $paths = Get-R18WipClassifierPaths -RepositoryRoot $RepositoryRoot
    $inventories = @()
    $classifications = @()
    foreach ($definition in $script:R18InventoryDefinitions) {
        $inventories += Read-R18WipJson -Path (Join-Path $paths.InventoryRoot ([string]$definition.file))
        $classifications += Read-R18WipJson -Path (Join-Path $paths.ClassificationRoot (Get-R18WipClassificationFileName -InventoryType ([string]$definition.inventory_type)))
    }

    return Test-R18WipClassifierSet `
        -Contract (Read-R18WipJson -Path $paths.Contract) `
        -Profile (Read-R18WipJson -Path $paths.Profile) `
        -Inventories $inventories `
        -Classifications $classifications `
        -Results (Read-R18WipJson -Path $paths.Results) `
        -Report (Read-R18WipJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18WipJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18WipObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        $Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($cursor.PSObject.Properties.Name -notcontains $segment) {
            $cursor | Add-Member -NotePropertyName $segment -NotePropertyValue ([pscustomobject]@{})
        }
        $cursor = $cursor.$segment
    }
    $leaf = $segments[-1]
    if ($cursor.PSObject.Properties.Name -contains $leaf) {
        $cursor.$leaf = $Value
    }
    else {
        $cursor | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
}

function Remove-R18WipObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($cursor.PSObject.Properties.Name -notcontains $segment) {
            return
        }
        $cursor = $cursor.$segment
    }
    $leaf = $segments[-1]
    if ($cursor.PSObject.Properties.Name -contains $leaf) {
        $cursor.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18WipClassifierMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18WipObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18WipObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 WIP classifier mutation operation '$($Mutation.operation)'." }
    }
}

function New-R18WipClassifierArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18WipClassifierRepositoryRoot))

    $paths = Get-R18WipClassifierPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18WipClassifierContract
    $profile = New-R18WipClassifierProfile
    $inventories = @()
    $classifications = @()

    foreach ($definition in $script:R18InventoryDefinitions) {
        $inventory = New-R18WipInventorySample -Definition $definition
        $inventories += $inventory
        $classifications += New-R18WipClassificationPacket -Inventory $inventory -InventoryFileName ([string]$definition.file)
    }

    $results = New-R18WipClassifierResults -Inventories $inventories -Classifications $classifications
    $report = New-R18WipClassifierCheckReport -Inventories $inventories -Classifications $classifications
    $snapshot = New-R18WipClassifierSnapshot -Classifications $classifications

    Write-R18WipJson -Path $paths.Contract -Value $contract
    Write-R18WipJson -Path $paths.Profile -Value $profile
    foreach ($definition in $script:R18InventoryDefinitions) {
        $inventory = @($inventories | Where-Object { $_.inventory_type -eq [string]$definition.inventory_type })[0]
        $classification = @($classifications | Where-Object { $_.source_inventory_ref -eq (Get-R18WipInventoryRef -FileName ([string]$definition.file)) })[0]
        Write-R18WipJson -Path (Join-Path $paths.InventoryRoot ([string]$definition.file)) -Value $inventory
        Write-R18WipJson -Path (Join-Path $paths.ClassificationRoot (Get-R18WipClassificationFileName -InventoryType ([string]$definition.inventory_type))) -Value $classification
    }
    Write-R18WipJson -Path $paths.Results -Value $results
    Write-R18WipJson -Path $paths.CheckReport -Value $report
    Write-R18WipJson -Path $paths.UiSnapshot -Value $snapshot
    Write-R18WipJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18WipFixtureManifest)
    foreach ($fixture in New-R18WipFixtureDefinitions) {
        Write-R18WipJson -Path (Join-Path $paths.FixtureRoot ([string]$fixture.file)) -Value $fixture
    }
    Write-R18WipJson -Path $paths.EvidenceIndex -Value (New-R18WipEvidenceIndex)
    Write-R18WipText -Path $paths.ProofReview -Value (New-R18WipProofReviewText)
    Write-R18WipText -Path $paths.ValidationManifest -Value (New-R18WipValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Profile = $paths.Profile
        InventoryRoot = $paths.InventoryRoot
        ClassificationRoot = $paths.ClassificationRoot
        Results = $paths.Results
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        InventoryCount = @($inventories).Count
        ClassificationPacketCount = @($classifications).Count
        AggregateVerdict = $script:R18ClassifierVerdict
    }
}

Export-ModuleMember -Function `
    Get-R18WipClassifierPaths, `
    Read-R18WipJson, `
    Copy-R18WipClassifierObject, `
    Test-R18WipClassifier, `
    Test-R18WipClassifierSet, `
    Test-R18WipClassifierStatusTruth, `
    Invoke-R18WipClassifierMutation, `
    New-R18WipClassifierArtifacts
