Set-StrictMode -Version Latest

$script:R18EvidencePackageSourceTask = "R18-019"
$script:R18EvidencePackageSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18EvidencePackageRepository = "RodneyMuniz/AIOffice_V2"
$script:R18EvidencePackageBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18EvidencePackageVerdict = "generated_r18_019_evidence_package_wrapper_foundation_only"
$script:R18EvidencePackageBoundary = "R18 active through R18-019 only; R18-020 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
$script:R18EvidencePackageCiGap = "CI replay remains absent; evidence relies on committed artifacts plus Codex-reported local validations."

$script:R18EvidencePackageRuntimeFlagFields = @(
    "evidence_package_wrapper_runtime_implemented",
    "live_evidence_package_runtime_executed",
    "audit_acceptance_claimed",
    "external_audit_acceptance_claimed",
    "milestone_closeout_claimed",
    "main_merge_claimed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "release_gate_executed",
    "stage_commit_push_gate_runtime_implemented",
    "stage_performed_by_gate",
    "commit_performed_by_gate",
    "push_performed_by_gate",
    "operator_approval_runtime_implemented",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_execution_performed",
    "continuation_packet_executed",
    "prompt_packet_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "codex_api_invoked",
    "openai_api_invoked",
    "autonomous_codex_invocation_performed",
    "work_order_execution_performed",
    "live_runner_runtime_executed",
    "wip_cleanup_performed",
    "wip_abandonment_performed",
    "branch_mutation_performed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_020_completed"
)

$script:R18EvidencePackageInputFields = @(
    "artifact_type",
    "contract_version",
    "input_id",
    "input_name",
    "source_task",
    "source_milestone",
    "input_status",
    "package_scenario",
    "task_coverage_scope",
    "evidence_ref_inventory",
    "proof_review_refs",
    "validation_manifest_refs",
    "validator_refs",
    "test_refs",
    "status_surface_refs",
    "validation_command_inventory",
    "non_claim_checks",
    "ci_replay_evidence",
    "ci_gap_disclosed",
    "expected_boundary",
    "actual_boundary",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18EvidencePackageManifestFields = @(
    "artifact_type",
    "contract_version",
    "manifest_id",
    "source_task",
    "source_milestone",
    "manifest_status",
    "repository",
    "branch",
    "r18_active_through",
    "planned_from",
    "planned_through",
    "task_entries",
    "status_surface_refs",
    "validation_command_inventory",
    "non_claim_checks",
    "known_gaps",
    "ci_replay_status",
    "ci_replay_evidence_refs",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18EvidencePackageAssessmentFields = @(
    "artifact_type",
    "contract_version",
    "assessment_id",
    "assessment_name",
    "source_task",
    "source_milestone",
    "assessment_status",
    "source_input_ref",
    "package_scenario",
    "action_recommendation",
    "task_coverage_present",
    "evidence_refs_present",
    "proof_review_refs_present",
    "validation_manifest_refs_present",
    "validator_refs_present",
    "test_refs_present",
    "status_surfaces_present",
    "validation_command_inventory_present",
    "non_claim_checks_present",
    "ci_gap_disclosed",
    "ci_replay_claimed",
    "runtime_overclaim_detected",
    "safe_for_future_audit",
    "blocked_reasons",
    "known_gaps",
    "next_safe_step",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18EvidencePackageTaskEntryFields = @(
    "task_id",
    "task_name",
    "task_status",
    "task_claim_type",
    "artifact_refs",
    "contract_refs",
    "state_refs",
    "validator_refs",
    "test_refs",
    "fixture_refs",
    "proof_review_ref",
    "validation_manifest_ref",
    "status_surface_refs",
    "non_claims",
    "known_gaps",
    "evidence_strength"
)

$script:R18EvidencePackageScenarios = @(
    "current_r18_evidence_package",
    "missing_proof_review",
    "missing_validation_manifest",
    "missing_status_surface",
    "runtime_overclaim",
    "ci_replay_gap_known"
)

$script:R18EvidencePackageStatuses = @(
    "evidence_package_passed_policy_only",
    "evidence_package_blocked_missing_proof_review",
    "evidence_package_blocked_missing_validation_manifest",
    "evidence_package_blocked_missing_status_surface",
    "evidence_package_blocked_runtime_overclaim",
    "evidence_package_attention_ci_replay_gap_known"
)

$script:R18EvidencePackageActions = @(
    "allow_future_audit_after_revalidation",
    "stop_and_restore_proof_review",
    "stop_and_restore_validation_manifest",
    "stop_and_restore_status_surface",
    "stop_and_remove_runtime_overclaim",
    "disclose_ci_replay_gap_before_final_audit"
)

$script:R18EvidencePackageEvidenceStrengthValues = @(
    "committed_artifact",
    "committed_validator",
    "committed_test",
    "committed_proof_review",
    "local_validation_reported_by_codex",
    "clean_ci_replay_missing",
    "clean_ci_replay_present"
)

function Get-R18EvidencePackageWrapperRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18EvidencePackageWrapperPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18EvidencePackageWrapperJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot)
    )

    $resolvedPath = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required artifact missing: $Path"
    }

    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Write-R18EvidencePackageWrapperJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 100
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($json.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Write-R18EvidencePackageWrapperText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $text = if ($Value -is [array]) { [string]::Join([Environment]::NewLine, @($Value)) } else { [string]$Value }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($text.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Copy-R18EvidencePackageWrapperObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18EvidencePackageWrapperPaths {
    param([string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot))

    return [ordered]@{
        WrapperContract = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_evidence_package_wrapper.contract.json"
        ManifestContract = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_evidence_package_manifest.contract.json"
        Profile = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_wrapper_profile.json"
        InputRoot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_inputs"
        ManifestRoot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_manifests"
        AssessmentRoot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_assessments"
        CurrentManifest = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json"
        Results = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_wrapper_results.json"
        CheckReport = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_evidence_package_wrapper_check_report.json"
        UiSnapshot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_evidence_package_wrapper_snapshot.json"
        FixtureRoot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_evidence_package_wrapper"
        ProofRoot = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper"
        EvidenceIndex = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/evidence_index.json"
        ProofReview = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/proof_review.md"
        ValidationManifest = Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/validation_manifest.md"
    }
}

function Get-R18EvidencePackageWrapperRuntimeFlagNames {
    return $script:R18EvidencePackageRuntimeFlagFields
}

function New-R18EvidencePackageWrapperRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18EvidencePackageRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18EvidencePackageWrapperPositiveClaims {
    return @(
        "r18_evidence_package_wrapper_contract_created",
        "r18_evidence_package_manifest_contract_created",
        "r18_evidence_package_wrapper_profile_created",
        "r18_evidence_package_inputs_created",
        "r18_evidence_package_manifest_created",
        "r18_evidence_package_assessments_created",
        "r18_evidence_package_wrapper_results_created",
        "r18_evidence_package_wrapper_validator_created",
        "r18_evidence_package_wrapper_fixtures_created",
        "r18_evidence_package_wrapper_proof_review_created"
    )
}

function Get-R18EvidencePackageWrapperRejectedClaims {
    return @(
        "evidence_package_wrapper_runtime",
        "live_evidence_package_runtime",
        "audit_acceptance",
        "external_audit_acceptance",
        "milestone_closeout",
        "main_merge",
        "ci_replay_performed",
        "github_actions_workflow_created",
        "github_actions_workflow_run_claimed",
        "release_gate_execution",
        "stage_commit_push_gate_runtime",
        "stage_performed_by_gate",
        "commit_performed_by_gate",
        "push_performed_by_gate",
        "operator_approval_runtime",
        "recovery_runtime",
        "recovery_action",
        "retry_execution",
        "continuation_packet_execution",
        "prompt_packet_execution",
        "automatic_new_thread_creation",
        "codex_thread_creation",
        "codex_api_invocation",
        "openai_api_invocation",
        "autonomous_codex_invocation",
        "work_order_execution",
        "live_runner_runtime",
        "wip_cleanup",
        "wip_abandonment",
        "branch_mutation",
        "board_runtime_mutation",
        "live_agent_runtime",
        "live_skill_execution",
        "a2a_message_sent",
        "live_a2a_runtime",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_020_or_later_completion",
        "missing_proof_review_marked_safe",
        "missing_validation_manifest_marked_safe",
        "missing_status_surface_marked_safe",
        "runtime_overclaim_marked_safe",
        "ci_replay_claim_without_workflow_artifact"
    )
}

function Get-R18EvidencePackageWrapperNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-019 only.",
        "R18-020 through R18-028 remain planned only.",
        "R18-019 created evidence package automation wrapper foundation only.",
        "Evidence package wrapper artifacts are deterministic policy/manifest artifacts only.",
        "Wrapper runtime was not implemented.",
        "Live evidence package runtime was not executed.",
        "Audit acceptance was not claimed.",
        "External audit acceptance was not claimed.",
        "Milestone closeout was not claimed.",
        "Main was not merged.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Release gate was not executed.",
        "No stage/commit/push was performed by the wrapper.",
        "Recovery action was not performed.",
        "Retry execution was not performed.",
        "Continuation packets were not executed.",
        "Prompt packets were not executed.",
        "Automatic new-thread creation was not performed.",
        "Codex thread creation was not performed.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
        "No work orders were executed.",
        "No WIP cleanup was performed.",
        "No WIP abandonment was performed.",
        "No branch mutation was performed by the wrapper.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "R18-020 is not complete.",
        $script:R18EvidencePackageCiGap
    )
}

function Get-R18EvidencePackageWrapperNonClaimChecks {
    return @(
        "no product runtime",
        "no live evidence package runtime",
        "no audit acceptance",
        "no external audit acceptance",
        "no milestone closeout",
        "no main merge",
        "no CI replay claim unless a real workflow run artifact exists",
        "no GitHub Actions workflow creation",
        "no release gate execution",
        "no stage/commit/push performed by wrapper",
        "no recovery action",
        "no Codex/OpenAI API invocation",
        "no automatic new-thread creation",
        "no work-order execution",
        "no board/card runtime mutation",
        "no A2A messages sent",
        "no live agent runtime",
        "no live skill execution",
        "no no-manual-prompt-transfer success",
        "no solved Codex compaction",
        "no solved Codex reliability",
        "no R18-020 or later completion"
    )
}

function Get-R18EvidencePackageWrapperStatusSurfaces {
    return @(
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18EvidencePackageWrapperEvidenceRefs {
    return @(
        "contracts/governance/r18_evidence_package_wrapper.contract.json",
        "contracts/governance/r18_evidence_package_manifest.contract.json",
        "state/governance/r18_evidence_package_wrapper_profile.json",
        "state/governance/r18_evidence_package_inputs/",
        "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json",
        "state/governance/r18_evidence_package_assessments/",
        "state/governance/r18_evidence_package_wrapper_results.json",
        "state/governance/r18_evidence_package_wrapper_check_report.json",
        "state/ui/r18_operator_surface/r18_evidence_package_wrapper_snapshot.json",
        "tools/R18EvidencePackageWrapper.psm1",
        "tools/new_r18_evidence_package_wrapper.ps1",
        "tools/validate_r18_evidence_package_wrapper.ps1",
        "tests/test_r18_evidence_package_wrapper.ps1",
        "tests/fixtures/r18_evidence_package_wrapper/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/"
    )
}

function Get-R18EvidencePackageWrapperAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "state/governance/r18_opening_authority.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "contracts/governance/r18_status_doc_gate_wrapper.contract.json",
        "state/governance/r18_status_doc_gate_wrapper_results.json",
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "state/runtime/r18_stage_commit_push_gate_assessments/",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18EvidencePackageWrapperValidationCommandInventory {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_status_doc_gate_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_status_doc_gate_wrapper.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_stage_commit_push_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_stage_commit_push_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_approval_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_approval_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_retry_escalation_policy.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_retry_escalation_policy.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_new_context_prompt_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_new_context_prompt_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_continuation_packet_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_continuation_packet_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_remote_branch_verifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_wip_classifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_wip_classifier.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_detector.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_runner_state_store.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_runner_state_store.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_work_order_state_machine.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_work_order_state_machine.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_local_runner_cli.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_local_runner_cli.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_role_skill_permission_matrix.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_role_skill_permission_matrix.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_a2a_handoff_packet_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_a2a_handoff_packet_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_skill_contract_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_skill_contract_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18EvidencePackageExpectedBoundary {
    return [ordered]@{
        r17_status = "R17 closed with caveats through R17-028 only"
        r18_status = "R18 active through R18-019 only"
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        main_merged = $false
        ci_replay_status = "not_performed_known_gap"
        summary = $script:R18EvidencePackageBoundary
    }
}

function Get-R18EvidencePackageRequiredCoverage {
    $coverage = @()
    foreach ($taskNumber in 1..19) {
        $coverage += "R18-{0}" -f $taskNumber.ToString("000")
    }
    $coverage += @(
        "r17_closeout_decision_package",
        "r18_authority_opening_package",
        "r18_status_doc_gate_wrapper_package",
        "r18_stage_commit_push_gate_foundation_package",
        "r18_operator_approval_gate_package",
        "r18_retry_escalation_policy_package",
        "r18_continuation_new_context_package",
        "r18_failure_wip_remote_verifier_package"
    )
    return $coverage
}

function New-R18EvidencePackageTaskEntry {
    param(
        [Parameter(Mandatory = $true)][string]$TaskId,
        [Parameter(Mandatory = $true)][string]$TaskName,
        [Parameter(Mandatory = $true)][string[]]$ArtifactRefs,
        [string[]]$ContractRefs = @(),
        [string[]]$StateRefs = @(),
        [string[]]$ValidatorRefs = @(),
        [string[]]$TestRefs = @(),
        [string[]]$FixtureRefs = @(),
        [Parameter(Mandatory = $true)][string]$ProofReviewRef,
        [Parameter(Mandatory = $true)][string]$ValidationManifestRef,
        [string[]]$KnownGaps = @()
    )

    return [ordered]@{
        task_id = $TaskId
        task_name = $TaskName
        task_status = "completed_foundation_or_decision_package"
        task_claim_type = "committed_bounded_foundation_evidence_only"
        artifact_refs = $ArtifactRefs
        contract_refs = $ContractRefs
        state_refs = $StateRefs
        validator_refs = $ValidatorRefs
        test_refs = $TestRefs
        fixture_refs = $FixtureRefs
        proof_review_ref = $ProofReviewRef
        validation_manifest_ref = $ValidationManifestRef
        status_surface_refs = Get-R18EvidencePackageWrapperStatusSurfaces
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        known_gaps = $KnownGaps
        evidence_strength = @(
            "committed_artifact",
            "committed_validator",
            "committed_test",
            "committed_proof_review",
            "local_validation_reported_by_codex",
            "clean_ci_replay_missing"
        )
    }
}

function Get-R18EvidencePackageTaskEntries {
    $entries = @()
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration"

    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-001" -TaskName "Open R18 in repo truth and install transition authority" -ArtifactRefs @("governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md", "state/governance/r18_opening_authority.json", "contracts/governance/r18_opening_authority.contract.json") -ContractRefs @("contracts/governance/r18_opening_authority.contract.json") -StateRefs @("state/governance/r18_opening_authority.json") -ValidatorRefs @("tools/validate_r18_opening_authority.ps1") -TestRefs @("tests/test_r18_opening_authority.ps1") -ProofReviewRef "state/governance/r18_opening_authority.json" -ValidationManifestRef "state/governance/r18_opening_authority.json" -KnownGaps @("R18-001 opening authority predates the dedicated R18 proof-review directory convention; evidence is the committed opening authority state plus validator/test refs.")
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-002" -TaskName "Define agent card schema and validator" -ArtifactRefs @("contracts/agents/r18_agent_card.contract.json", "state/agents/r18_agent_cards/", "state/agents/r18_agent_card_check_report.json") -ContractRefs @("contracts/agents/r18_agent_card.contract.json") -StateRefs @("state/agents/r18_agent_cards/", "state/agents/r18_agent_card_check_report.json") -ValidatorRefs @("tools/validate_r18_agent_card_schema.ps1") -TestRefs @("tests/test_r18_agent_card_schema.ps1") -FixtureRefs @("tests/fixtures/r18_agent_card_schema/") -ProofReviewRef "$proofRoot/r18_002_agent_card_schema/proof_review.md" -ValidationManifestRef "$proofRoot/r18_002_agent_card_schema/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-003" -TaskName "Define skill contract schema and validator" -ArtifactRefs @("contracts/skills/r18_skill_contract.contract.json", "state/skills/r18_skill_contracts/", "state/skills/r18_skill_registry.json") -ContractRefs @("contracts/skills/r18_skill_contract.contract.json") -StateRefs @("state/skills/r18_skill_contracts/", "state/skills/r18_skill_registry.json") -ValidatorRefs @("tools/validate_r18_skill_contract_schema.ps1") -TestRefs @("tests/test_r18_skill_contract_schema.ps1") -FixtureRefs @("tests/fixtures/r18_skill_contract_schema/") -ProofReviewRef "$proofRoot/r18_003_skill_contract_schema/proof_review.md" -ValidationManifestRef "$proofRoot/r18_003_skill_contract_schema/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-004" -TaskName "Define A2A handoff packet schema and validator" -ArtifactRefs @("contracts/a2a/r18_a2a_handoff_packet.contract.json", "state/a2a/r18_handoff_packets/", "state/a2a/r18_handoff_registry.json") -ContractRefs @("contracts/a2a/r18_a2a_handoff_packet.contract.json") -StateRefs @("state/a2a/r18_handoff_packets/", "state/a2a/r18_handoff_registry.json") -ValidatorRefs @("tools/validate_r18_a2a_handoff_packet_schema.ps1") -TestRefs @("tests/test_r18_a2a_handoff_packet_schema.ps1") -FixtureRefs @("tests/fixtures/r18_a2a_handoff_packet_schema/") -ProofReviewRef "$proofRoot/r18_004_a2a_handoff_packet_schema/proof_review.md" -ValidationManifestRef "$proofRoot/r18_004_a2a_handoff_packet_schema/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-005" -TaskName "Define explicit role-to-skill permission matrix" -ArtifactRefs @("contracts/skills/r18_role_skill_permission_matrix.contract.json", "state/skills/r18_role_skill_permission_matrix.json", "state/skills/r18_role_skill_permission_matrix_check_report.json") -ContractRefs @("contracts/skills/r18_role_skill_permission_matrix.contract.json") -StateRefs @("state/skills/r18_role_skill_permission_matrix.json") -ValidatorRefs @("tools/validate_r18_role_skill_permission_matrix.ps1") -TestRefs @("tests/test_r18_role_skill_permission_matrix.ps1") -FixtureRefs @("tests/fixtures/r18_role_skill_permission_matrix/") -ProofReviewRef "$proofRoot/r18_005_role_skill_permission_matrix/proof_review.md" -ValidationManifestRef "$proofRoot/r18_005_role_skill_permission_matrix/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-006" -TaskName "Build Orchestrator chat/control intake contract" -ArtifactRefs @("contracts/intake/r18_orchestrator_control_intake.contract.json", "state/intake/r18_orchestrator_control_intake_packets/", "state/intake/r18_orchestrator_control_intake_registry.json") -ContractRefs @("contracts/intake/r18_orchestrator_control_intake.contract.json") -StateRefs @("state/intake/r18_orchestrator_control_intake_packets/") -ValidatorRefs @("tools/validate_r18_orchestrator_control_intake.ps1") -TestRefs @("tests/test_r18_orchestrator_control_intake.ps1") -FixtureRefs @("tests/fixtures/r18_orchestrator_control_intake/") -ProofReviewRef "$proofRoot/r18_006_orchestrator_control_intake/proof_review.md" -ValidationManifestRef "$proofRoot/r18_006_orchestrator_control_intake/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-007" -TaskName "Build local runner/CLI shell foundation" -ArtifactRefs @("contracts/runtime/r18_local_runner_cli.contract.json", "state/runtime/r18_local_runner_cli_profile.json", "state/runtime/r18_local_runner_cli_command_catalog.json") -ContractRefs @("contracts/runtime/r18_local_runner_cli.contract.json") -StateRefs @("state/runtime/r18_local_runner_cli_profile.json") -ValidatorRefs @("tools/validate_r18_local_runner_cli.ps1") -TestRefs @("tests/test_r18_local_runner_cli.ps1") -FixtureRefs @("tests/fixtures/r18_local_runner_cli/") -ProofReviewRef "$proofRoot/r18_007_local_runner_cli_shell/proof_review.md" -ValidationManifestRef "$proofRoot/r18_007_local_runner_cli_shell/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-008" -TaskName "Implement work-order execution state machine foundation" -ArtifactRefs @("contracts/runtime/r18_work_order_state_machine.contract.json", "state/runtime/r18_work_order_state_machine.json", "state/runtime/r18_work_order_transition_catalog.json") -ContractRefs @("contracts/runtime/r18_work_order_state_machine.contract.json") -StateRefs @("state/runtime/r18_work_order_state_machine.json") -ValidatorRefs @("tools/validate_r18_work_order_state_machine.ps1") -TestRefs @("tests/test_r18_work_order_state_machine.ps1") -FixtureRefs @("tests/fixtures/r18_work_order_state_machine/") -ProofReviewRef "$proofRoot/r18_008_work_order_state_machine/proof_review.md" -ValidationManifestRef "$proofRoot/r18_008_work_order_state_machine/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-009" -TaskName "Implement runner state store and resumable execution log" -ArtifactRefs @("contracts/runtime/r18_runner_state_store.contract.json", "state/runtime/r18_runner_state_store_profile.json", "state/runtime/r18_execution_log.jsonl") -ContractRefs @("contracts/runtime/r18_runner_state_store.contract.json") -StateRefs @("state/runtime/r18_runner_state_store_profile.json", "state/runtime/r18_runner_state.json") -ValidatorRefs @("tools/validate_r18_runner_state_store.ps1") -TestRefs @("tests/test_r18_runner_state_store.ps1") -FixtureRefs @("tests/fixtures/r18_runner_state_store/") -ProofReviewRef "$proofRoot/r18_009_runner_state_store/proof_review.md" -ValidationManifestRef "$proofRoot/r18_009_runner_state_store/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-010" -TaskName "Implement compact failure detector" -ArtifactRefs @("contracts/runtime/r18_compact_failure_detector.contract.json", "contracts/runtime/r18_failure_event.contract.json", "state/runtime/r18_detected_failure_events/") -ContractRefs @("contracts/runtime/r18_compact_failure_detector.contract.json", "contracts/runtime/r18_failure_event.contract.json") -StateRefs @("state/runtime/r18_detected_failure_events/") -ValidatorRefs @("tools/validate_r18_compact_failure_detector.ps1") -TestRefs @("tests/test_r18_compact_failure_detector.ps1") -FixtureRefs @("tests/fixtures/r18_compact_failure_detector/") -ProofReviewRef "$proofRoot/r18_010_compact_failure_detector/proof_review.md" -ValidationManifestRef "$proofRoot/r18_010_compact_failure_detector/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-011" -TaskName "Implement WIP classifier" -ArtifactRefs @("contracts/runtime/r18_wip_classifier.contract.json", "state/runtime/r18_wip_inventory_samples/", "state/runtime/r18_wip_classification_packets/") -ContractRefs @("contracts/runtime/r18_wip_classifier.contract.json") -StateRefs @("state/runtime/r18_wip_classification_packets/") -ValidatorRefs @("tools/validate_r18_wip_classifier.ps1") -TestRefs @("tests/test_r18_wip_classifier.ps1") -FixtureRefs @("tests/fixtures/r18_wip_classifier/") -ProofReviewRef "$proofRoot/r18_011_wip_classifier/proof_review.md" -ValidationManifestRef "$proofRoot/r18_011_wip_classifier/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-012" -TaskName "Implement remote branch verifier" -ArtifactRefs @("contracts/runtime/r18_remote_branch_verifier.contract.json", "state/runtime/r18_remote_branch_current_verification.json", "state/runtime/r18_remote_branch_verifier_results.json") -ContractRefs @("contracts/runtime/r18_remote_branch_verifier.contract.json") -StateRefs @("state/runtime/r18_remote_branch_current_verification.json") -ValidatorRefs @("tools/validate_r18_remote_branch_verifier.ps1") -TestRefs @("tests/test_r18_remote_branch_verifier.ps1") -FixtureRefs @("tests/fixtures/r18_remote_branch_verifier/") -ProofReviewRef "$proofRoot/r18_012_remote_branch_verifier/proof_review.md" -ValidationManifestRef "$proofRoot/r18_012_remote_branch_verifier/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-013" -TaskName "Implement continuation packet generator" -ArtifactRefs @("contracts/runtime/r18_continuation_packet.contract.json", "contracts/runtime/r18_continuation_packet_generator.contract.json", "state/runtime/r18_continuation_packets/") -ContractRefs @("contracts/runtime/r18_continuation_packet.contract.json", "contracts/runtime/r18_continuation_packet_generator.contract.json") -StateRefs @("state/runtime/r18_continuation_packets/") -ValidatorRefs @("tools/validate_r18_continuation_packet_generator.ps1") -TestRefs @("tests/test_r18_continuation_packet_generator.ps1") -FixtureRefs @("tests/fixtures/r18_continuation_packet_generator/") -ProofReviewRef "$proofRoot/r18_013_continuation_packet_generator/proof_review.md" -ValidationManifestRef "$proofRoot/r18_013_continuation_packet_generator/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-014" -TaskName "Implement new-context/new-thread prompt generator" -ArtifactRefs @("contracts/runtime/r18_new_context_prompt_packet.contract.json", "contracts/runtime/r18_new_context_prompt_generator.contract.json", "state/runtime/r18_new_context_prompt_packets/") -ContractRefs @("contracts/runtime/r18_new_context_prompt_packet.contract.json", "contracts/runtime/r18_new_context_prompt_generator.contract.json") -StateRefs @("state/runtime/r18_new_context_prompt_packets/") -ValidatorRefs @("tools/validate_r18_new_context_prompt_generator.ps1") -TestRefs @("tests/test_r18_new_context_prompt_generator.ps1") -FixtureRefs @("tests/fixtures/r18_new_context_prompt_generator/") -ProofReviewRef "$proofRoot/r18_014_new_context_prompt_generator/proof_review.md" -ValidationManifestRef "$proofRoot/r18_014_new_context_prompt_generator/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-015" -TaskName "Implement retry and escalation policy" -ArtifactRefs @("contracts/runtime/r18_retry_escalation_policy.contract.json", "state/runtime/r18_retry_escalation_scenarios/", "state/runtime/r18_retry_escalation_decisions/") -ContractRefs @("contracts/runtime/r18_retry_escalation_policy.contract.json") -StateRefs @("state/runtime/r18_retry_escalation_decisions/") -ValidatorRefs @("tools/validate_r18_retry_escalation_policy.ps1") -TestRefs @("tests/test_r18_retry_escalation_policy.ps1") -FixtureRefs @("tests/fixtures/r18_retry_escalation_policy/") -ProofReviewRef "$proofRoot/r18_015_retry_escalation_policy/proof_review.md" -ValidationManifestRef "$proofRoot/r18_015_retry_escalation_policy/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-016" -TaskName "Implement operator approval gate model" -ArtifactRefs @("contracts/governance/r18_operator_approval_gate.contract.json", "state/governance/r18_operator_approval_requests/", "state/governance/r18_operator_approval_decisions/") -ContractRefs @("contracts/governance/r18_operator_approval_gate.contract.json") -StateRefs @("state/governance/r18_operator_approval_decisions/") -ValidatorRefs @("tools/validate_r18_operator_approval_gate.ps1") -TestRefs @("tests/test_r18_operator_approval_gate.ps1") -FixtureRefs @("tests/fixtures/r18_operator_approval_gate/") -ProofReviewRef "$proofRoot/r18_016_operator_approval_gate/proof_review.md" -ValidationManifestRef "$proofRoot/r18_016_operator_approval_gate/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-017" -TaskName "Implement stage/commit/push gate" -ArtifactRefs @("contracts/runtime/r18_stage_commit_push_gate.contract.json", "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json", "state/runtime/r18_stage_commit_push_gate_assessments/") -ContractRefs @("contracts/runtime/r18_stage_commit_push_gate.contract.json", "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json") -StateRefs @("state/runtime/r18_stage_commit_push_gate_assessments/") -ValidatorRefs @("tools/validate_r18_stage_commit_push_gate.ps1") -TestRefs @("tests/test_r18_stage_commit_push_gate.ps1") -FixtureRefs @("tests/fixtures/r18_stage_commit_push_gate/") -ProofReviewRef "$proofRoot/r18_017_stage_commit_push_gate/proof_review.md" -ValidationManifestRef "$proofRoot/r18_017_stage_commit_push_gate/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-018" -TaskName "Implement status-doc gate automation wrapper" -ArtifactRefs @("contracts/governance/r18_status_doc_gate_wrapper.contract.json", "state/governance/r18_status_doc_gate_inputs/", "state/governance/r18_status_doc_gate_assessments/") -ContractRefs @("contracts/governance/r18_status_doc_gate_wrapper.contract.json", "contracts/governance/r18_status_doc_gate_assessment.contract.json") -StateRefs @("state/governance/r18_status_doc_gate_wrapper_results.json") -ValidatorRefs @("tools/validate_r18_status_doc_gate_wrapper.ps1") -TestRefs @("tests/test_r18_status_doc_gate_wrapper.ps1") -FixtureRefs @("tests/fixtures/r18_status_doc_gate_wrapper/") -ProofReviewRef "$proofRoot/r18_018_status_doc_gate_wrapper/proof_review.md" -ValidationManifestRef "$proofRoot/r18_018_status_doc_gate_wrapper/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "R18-019" -TaskName "Implement evidence package automation wrapper" -ArtifactRefs (Get-R18EvidencePackageWrapperEvidenceRefs) -ContractRefs @("contracts/governance/r18_evidence_package_wrapper.contract.json", "contracts/governance/r18_evidence_package_manifest.contract.json") -StateRefs @("state/governance/r18_evidence_package_wrapper_profile.json", "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json") -ValidatorRefs @("tools/validate_r18_evidence_package_wrapper.ps1") -TestRefs @("tests/test_r18_evidence_package_wrapper.ps1") -FixtureRefs @("tests/fixtures/r18_evidence_package_wrapper/") -ProofReviewRef "$proofRoot/r18_019_evidence_package_wrapper/proof_review.md" -ValidationManifestRef "$proofRoot/r18_019_evidence_package_wrapper/validation_manifest.md"

    $entries += New-R18EvidencePackageTaskEntry -TaskId "r17_closeout_decision_package" -TaskName "R17 closeout decision package" -ArtifactRefs @("contracts/governance/r17_operator_closeout_decision.contract.json", "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json", "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/") -ContractRefs @("contracts/governance/r17_operator_closeout_decision.contract.json") -StateRefs @("state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json") -ValidatorRefs @("tools/validate_r17_operator_closeout_decision.ps1") -TestRefs @("tests/test_r17_operator_closeout_decision.ps1") -ProofReviewRef "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/proof_review.md" -ValidationManifestRef "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/validation_manifest.md" -KnownGaps @("R17 closeout remains a closed-with-caveats decision package; it is referenced here as authority evidence only and does not close R18.")
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_authority_opening_package" -TaskName "R18 authority/opening package" -ArtifactRefs @("governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md", "state/governance/r18_opening_authority.json", "contracts/governance/r18_opening_authority.contract.json") -ContractRefs @("contracts/governance/r18_opening_authority.contract.json") -StateRefs @("state/governance/r18_opening_authority.json") -ValidatorRefs @("tools/validate_r18_opening_authority.ps1") -TestRefs @("tests/test_r18_opening_authority.ps1") -ProofReviewRef "state/governance/r18_opening_authority.json" -ValidationManifestRef "state/governance/r18_opening_authority.json"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_status_doc_gate_wrapper_package" -TaskName "R18 status-doc gate wrapper package" -ArtifactRefs @("contracts/governance/r18_status_doc_gate_wrapper.contract.json", "state/governance/r18_status_doc_gate_wrapper_results.json", "$proofRoot/r18_018_status_doc_gate_wrapper/") -ContractRefs @("contracts/governance/r18_status_doc_gate_wrapper.contract.json") -StateRefs @("state/governance/r18_status_doc_gate_wrapper_results.json") -ValidatorRefs @("tools/validate_r18_status_doc_gate_wrapper.ps1") -TestRefs @("tests/test_r18_status_doc_gate_wrapper.ps1") -FixtureRefs @("tests/fixtures/r18_status_doc_gate_wrapper/") -ProofReviewRef "$proofRoot/r18_018_status_doc_gate_wrapper/proof_review.md" -ValidationManifestRef "$proofRoot/r18_018_status_doc_gate_wrapper/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_stage_commit_push_gate_foundation_package" -TaskName "R18 stage/commit/push gate foundation package" -ArtifactRefs @("contracts/runtime/r18_stage_commit_push_gate.contract.json", "state/runtime/r18_stage_commit_push_gate_assessments/", "$proofRoot/r18_017_stage_commit_push_gate/") -ContractRefs @("contracts/runtime/r18_stage_commit_push_gate.contract.json") -StateRefs @("state/runtime/r18_stage_commit_push_gate_assessments/") -ValidatorRefs @("tools/validate_r18_stage_commit_push_gate.ps1") -TestRefs @("tests/test_r18_stage_commit_push_gate.ps1") -FixtureRefs @("tests/fixtures/r18_stage_commit_push_gate/") -ProofReviewRef "$proofRoot/r18_017_stage_commit_push_gate/proof_review.md" -ValidationManifestRef "$proofRoot/r18_017_stage_commit_push_gate/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_operator_approval_gate_package" -TaskName "R18 operator approval gate package" -ArtifactRefs @("contracts/governance/r18_operator_approval_gate.contract.json", "state/governance/r18_operator_approval_decisions/", "$proofRoot/r18_016_operator_approval_gate/") -ContractRefs @("contracts/governance/r18_operator_approval_gate.contract.json") -StateRefs @("state/governance/r18_operator_approval_decisions/") -ValidatorRefs @("tools/validate_r18_operator_approval_gate.ps1") -TestRefs @("tests/test_r18_operator_approval_gate.ps1") -FixtureRefs @("tests/fixtures/r18_operator_approval_gate/") -ProofReviewRef "$proofRoot/r18_016_operator_approval_gate/proof_review.md" -ValidationManifestRef "$proofRoot/r18_016_operator_approval_gate/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_retry_escalation_policy_package" -TaskName "R18 retry/escalation policy package" -ArtifactRefs @("contracts/runtime/r18_retry_escalation_policy.contract.json", "state/runtime/r18_retry_escalation_decisions/", "$proofRoot/r18_015_retry_escalation_policy/") -ContractRefs @("contracts/runtime/r18_retry_escalation_policy.contract.json") -StateRefs @("state/runtime/r18_retry_escalation_decisions/") -ValidatorRefs @("tools/validate_r18_retry_escalation_policy.ps1") -TestRefs @("tests/test_r18_retry_escalation_policy.ps1") -FixtureRefs @("tests/fixtures/r18_retry_escalation_policy/") -ProofReviewRef "$proofRoot/r18_015_retry_escalation_policy/proof_review.md" -ValidationManifestRef "$proofRoot/r18_015_retry_escalation_policy/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_continuation_new_context_package" -TaskName "R18 continuation/new-context package" -ArtifactRefs @("contracts/runtime/r18_continuation_packet_generator.contract.json", "contracts/runtime/r18_new_context_prompt_generator.contract.json", "state/runtime/r18_continuation_packets/", "state/runtime/r18_new_context_prompt_packets/") -ContractRefs @("contracts/runtime/r18_continuation_packet_generator.contract.json", "contracts/runtime/r18_new_context_prompt_generator.contract.json") -StateRefs @("state/runtime/r18_continuation_packets/", "state/runtime/r18_new_context_prompt_packets/") -ValidatorRefs @("tools/validate_r18_continuation_packet_generator.ps1", "tools/validate_r18_new_context_prompt_generator.ps1") -TestRefs @("tests/test_r18_continuation_packet_generator.ps1", "tests/test_r18_new_context_prompt_generator.ps1") -FixtureRefs @("tests/fixtures/r18_continuation_packet_generator/", "tests/fixtures/r18_new_context_prompt_generator/") -ProofReviewRef "$proofRoot/r18_013_continuation_packet_generator/proof_review.md" -ValidationManifestRef "$proofRoot/r18_014_new_context_prompt_generator/validation_manifest.md"
    $entries += New-R18EvidencePackageTaskEntry -TaskId "r18_failure_wip_remote_verifier_package" -TaskName "R18 failure/WIP/remote verifier package" -ArtifactRefs @("contracts/runtime/r18_compact_failure_detector.contract.json", "contracts/runtime/r18_wip_classifier.contract.json", "contracts/runtime/r18_remote_branch_verifier.contract.json", "state/runtime/r18_remote_branch_current_verification.json") -ContractRefs @("contracts/runtime/r18_compact_failure_detector.contract.json", "contracts/runtime/r18_wip_classifier.contract.json", "contracts/runtime/r18_remote_branch_verifier.contract.json") -StateRefs @("state/runtime/r18_detected_failure_events/", "state/runtime/r18_wip_classification_packets/", "state/runtime/r18_remote_branch_current_verification.json") -ValidatorRefs @("tools/validate_r18_compact_failure_detector.ps1", "tools/validate_r18_wip_classifier.ps1", "tools/validate_r18_remote_branch_verifier.ps1") -TestRefs @("tests/test_r18_compact_failure_detector.ps1", "tests/test_r18_wip_classifier.ps1", "tests/test_r18_remote_branch_verifier.ps1") -FixtureRefs @("tests/fixtures/r18_compact_failure_detector/", "tests/fixtures/r18_wip_classifier/", "tests/fixtures/r18_remote_branch_verifier/") -ProofReviewRef "$proofRoot/r18_010_compact_failure_detector/proof_review.md" -ValidationManifestRef "$proofRoot/r18_012_remote_branch_verifier/validation_manifest.md"

    return $entries
}

function Get-R18EvidencePackageTaskEntryById {
    param([Parameter(Mandatory = $true)][string]$TaskId)
    return @((Get-R18EvidencePackageTaskEntries) | Where-Object { $_.task_id -eq $TaskId })[0]
}

function Get-R18EvidencePackageAllProofReviewRefs {
    return @((Get-R18EvidencePackageTaskEntries) | ForEach-Object { $_.proof_review_ref }) | Sort-Object -Unique
}

function Get-R18EvidencePackageAllValidationManifestRefs {
    return @((Get-R18EvidencePackageTaskEntries) | ForEach-Object { $_.validation_manifest_ref }) | Sort-Object -Unique
}

function Get-R18EvidencePackageAllValidatorRefs {
    return @((Get-R18EvidencePackageTaskEntries) | ForEach-Object { @($_.validator_refs) }) | Sort-Object -Unique
}

function Get-R18EvidencePackageAllTestRefs {
    return @((Get-R18EvidencePackageTaskEntries) | ForEach-Object { @($_.test_refs) }) | Sort-Object -Unique
}

function New-R18EvidencePackageWrapperContract {
    return [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_contract"
        contract_version = "v1"
        contract_id = "r18_019_evidence_package_wrapper_contract_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        repository = $script:R18EvidencePackageRepository
        branch = $script:R18EvidencePackageBranch
        scope = "deterministic_evidence_package_wrapper_policy_manifest_artifacts_only_not_runtime"
        purpose = "Assemble and validate R18-001 through R18-019 evidence references, status surfaces, validation command inventories, non-claim checks, CI gap disclosures, and proof-review coverage for future audit/release work."
        required_input_fields = $script:R18EvidencePackageInputFields
        required_manifest_fields = $script:R18EvidencePackageManifestFields
        required_assessment_fields = $script:R18EvidencePackageAssessmentFields
        required_task_coverage = Get-R18EvidencePackageRequiredCoverage
        required_status_surfaces = Get-R18EvidencePackageWrapperStatusSurfaces
        required_validation_refs = Get-R18EvidencePackageWrapperValidationCommandInventory
        required_non_claim_checks = Get-R18EvidencePackageWrapperNonClaimChecks
        allowed_package_scenarios = $script:R18EvidencePackageScenarios
        allowed_assessment_statuses = $script:R18EvidencePackageStatuses
        allowed_action_recommendations = $script:R18EvidencePackageActions
        required_runtime_false_flags = $script:R18EvidencePackageRuntimeFlagFields
        evidence_inventory_policy = [ordered]@{ evidence_ref_inventory_required = $true; missing_evidence_refs_fail_closed = $true; package_inventory_is_reference_only = $true }
        proof_review_policy = [ordered]@{ proof_review_refs_required_for_completed_tasks = $true; missing_proof_review_blocks = $true; missing_proof_review_must_not_be_marked_safe = $true }
        validation_manifest_policy = [ordered]@{ validation_manifest_refs_required_for_completed_tasks = $true; missing_validation_manifest_blocks = $true; missing_validation_manifest_must_not_be_marked_safe = $true }
        status_surface_policy = [ordered]@{ required_status_surfaces_required = $true; missing_status_surface_blocks = $true; status_surface_must_not_claim_r18_beyond_r18_019 = $true }
        non_claim_policy = [ordered]@{ non_claim_checks_required = $true; runtime_overclaims_block = $true; forbidden_positive_claims_fail_closed = $true }
        ci_gap_policy = [ordered]@{ ci_replay_absent_unless_real_workflow_run_artifact_exists = $true; ci_replay_must_not_be_claimed = $true; github_actions_workflow_creation_allowed = $false; known_gap = $script:R18EvidencePackageCiGap }
        authority_policy = [ordered]@{ authority_refs_required = $true; authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs }
        execution_policy = [ordered]@{ wrapper_runtime_allowed = $false; live_evidence_package_runtime_allowed = $false; release_gate_execution_allowed = $false; stage_commit_push_by_wrapper_allowed = $false; api_invocation_allowed = $false; work_order_execution_allowed = $false; board_runtime_mutation_allowed = $false; a2a_message_allowed = $false }
        refusal_policy = [ordered]@{ fail_closed_on_missing_required_field = $true; blocked_scenarios_must_mark_safe_for_future_audit_false = $true; policy_refusal_artifacts_only = $true }
        allowed_positive_claims = Get-R18EvidencePackageWrapperPositiveClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
    }
}

function New-R18EvidencePackageManifestContract {
    return [ordered]@{
        artifact_type = "r18_evidence_package_manifest_contract"
        contract_version = "v1"
        contract_id = "r18_019_evidence_package_manifest_contract_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        required_manifest_packet_fields = $script:R18EvidencePackageManifestFields
        required_task_entry_fields = $script:R18EvidencePackageTaskEntryFields
        required_runtime_false_flags = $script:R18EvidencePackageRuntimeFlagFields
        manifest_policy = [ordered]@{ manifest_is_not_audit_acceptance = $true; required_coverage = Get-R18EvidencePackageRequiredCoverage; r18_active_through = "R18-019"; planned_from = "R18-020"; planned_through = "R18-028" }
        evidence_policy = [ordered]@{ task_entries_require_evidence_contract_state_validator_test_proof_review_and_validation_manifest_refs = $true; missing_refs_fail_closed = $true; ci_gap_disclosure_required = $true }
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
    }
}

function New-R18EvidencePackageWrapperProfile {
    return [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_profile"
        contract_version = "v1"
        profile_id = "r18_019_evidence_package_wrapper_profile_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        profile_status = "seed_evidence_package_wrapper_profile_only_not_live_automation"
        repository = $script:R18EvidencePackageRepository
        branch = $script:R18EvidencePackageBranch
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        package_scenarios = $script:R18EvidencePackageScenarios
        required_task_coverage = Get-R18EvidencePackageRequiredCoverage
        status_surface_refs = Get-R18EvidencePackageWrapperStatusSurfaces
        validation_command_inventory = Get-R18EvidencePackageWrapperValidationCommandInventory
        ci_gap_policy = [ordered]@{ ci_replay_status = "not_performed_known_gap"; known_gap = $script:R18EvidencePackageCiGap }
        positive_claims = @("r18_evidence_package_wrapper_profile_created")
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageInput {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    if ($script:R18EvidencePackageScenarios -notcontains $Scenario) {
        throw "Unknown evidence package scenario '$Scenario'."
    }

    $proofRefs = @(Get-R18EvidencePackageAllProofReviewRefs)
    $validationManifestRefs = @(Get-R18EvidencePackageAllValidationManifestRefs)
    $statusSurfaces = @(Get-R18EvidencePackageWrapperStatusSurfaces)
    $claimSignals = @()

    if ($Scenario -eq "missing_proof_review") {
        $proofRefs = @($proofRefs | Where-Object { $_ -ne "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/proof_review.md" })
    }
    elseif ($Scenario -eq "missing_validation_manifest") {
        $validationManifestRefs = @($validationManifestRefs | Where-Object { $_ -ne "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/validation_manifest.md" })
    }
    elseif ($Scenario -eq "missing_status_surface") {
        $statusSurfaces = @($statusSurfaces | Where-Object { $_ -ne "governance/ACTIVE_STATE.md" })
    }
    elseif ($Scenario -eq "runtime_overclaim") {
        $claimSignals = @("live_evidence_package_runtime_claim_seen")
    }

    return [ordered]@{
        artifact_type = "r18_evidence_package_input"
        contract_version = "v1"
        input_id = "r18_019_$Scenario`_input_v1"
        input_name = $Scenario
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        input_status = "seed_evidence_package_input_only_not_live_automation"
        package_scenario = $Scenario
        task_coverage_scope = [ordered]@{
            r18_active_through = "R18-019"
            planned_from = "R18-020"
            planned_through = "R18-028"
            required_coverage = Get-R18EvidencePackageRequiredCoverage
        }
        evidence_ref_inventory = Get-R18EvidencePackageWrapperEvidenceRefs
        proof_review_refs = $proofRefs
        validation_manifest_refs = $validationManifestRefs
        validator_refs = Get-R18EvidencePackageAllValidatorRefs
        test_refs = Get-R18EvidencePackageAllTestRefs
        status_surface_refs = $statusSurfaces
        validation_command_inventory = Get-R18EvidencePackageWrapperValidationCommandInventory
        non_claim_checks = Get-R18EvidencePackageWrapperNonClaimChecks
        ci_replay_evidence = [ordered]@{
            ci_replay_status = "not_performed_known_gap"
            workflow_run_artifact_refs = @()
            github_actions_workflow_created = $false
            github_actions_workflow_run_claimed = $false
            known_gap = $script:R18EvidencePackageCiGap
        }
        ci_gap_disclosed = $true
        expected_boundary = New-R18EvidencePackageExpectedBoundary
        actual_boundary = [ordered]@{
            r17_status = "R17 closed with caveats through R17-028 only"
            r18_status = "R18 active through R18-019 only"
            planned_from = "R18-020"
            planned_through = "R18-028"
            claim_signals = $claimSignals
            summary = $script:R18EvidencePackageBoundary
        }
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageManifest {
    return [ordered]@{
        artifact_type = "r18_evidence_package_manifest"
        contract_version = "v1"
        manifest_id = "current_r18_evidence_package_manifest_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        manifest_status = "evidence_package_manifest_generated_not_audit_acceptance"
        repository = $script:R18EvidencePackageRepository
        branch = $script:R18EvidencePackageBranch
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        task_entries = Get-R18EvidencePackageTaskEntries
        status_surface_refs = Get-R18EvidencePackageWrapperStatusSurfaces
        validation_command_inventory = Get-R18EvidencePackageWrapperValidationCommandInventory
        non_claim_checks = Get-R18EvidencePackageWrapperNonClaimChecks
        known_gaps = @($script:R18EvidencePackageCiGap)
        ci_replay_status = "not_performed_known_gap"
        ci_replay_evidence_refs = @()
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function Get-R18EvidencePackageAssessmentRule {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    switch ($Scenario) {
        "current_r18_evidence_package" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_passed_policy_only"
                action_recommendation = "allow_future_audit_after_revalidation"
                safe_for_future_audit = $true
                blocked_reasons = @()
                next_safe_step = "Future audit or release work may consume this package only after re-running the wrapper and all listed validators against the then-current repository head."
            }
        }
        "missing_proof_review" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_blocked_missing_proof_review"
                action_recommendation = "stop_and_restore_proof_review"
                safe_for_future_audit = $false
                blocked_reasons = @("required_proof_review_ref_missing:r18_019_evidence_package_wrapper/proof_review.md")
                next_safe_step = "Restore the missing proof review ref before future audit packaging."
            }
        }
        "missing_validation_manifest" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_blocked_missing_validation_manifest"
                action_recommendation = "stop_and_restore_validation_manifest"
                safe_for_future_audit = $false
                blocked_reasons = @("required_validation_manifest_ref_missing:r18_019_evidence_package_wrapper/validation_manifest.md")
                next_safe_step = "Restore the missing validation manifest ref before future audit packaging."
            }
        }
        "missing_status_surface" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_blocked_missing_status_surface"
                action_recommendation = "stop_and_restore_status_surface"
                safe_for_future_audit = $false
                blocked_reasons = @("required_status_surface_missing:governance/ACTIVE_STATE.md")
                next_safe_step = "Restore the missing status surface and re-run the status-doc gate."
            }
        }
        "runtime_overclaim" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_blocked_runtime_overclaim"
                action_recommendation = "stop_and_remove_runtime_overclaim"
                safe_for_future_audit = $false
                blocked_reasons = @("runtime_overclaim_detected")
                next_safe_step = "Remove any evidence package runtime or execution claim before future audit packaging."
            }
        }
        "ci_replay_gap_known" {
            return [pscustomobject]@{
                assessment_status = "evidence_package_attention_ci_replay_gap_known"
                action_recommendation = "disclose_ci_replay_gap_before_final_audit"
                safe_for_future_audit = $false
                blocked_reasons = @()
                next_safe_step = "Disclose the known CI replay gap before final audit or replace it with a real workflow run artifact."
            }
        }
        default { throw "Unknown evidence package scenario '$Scenario'." }
    }
}

function New-R18EvidencePackageAssessment {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    $inputPacket = New-R18EvidencePackageInput -Scenario $Scenario
    $rule = Get-R18EvidencePackageAssessmentRule -Scenario $Scenario
    $requiredCoverage = @(Get-R18EvidencePackageRequiredCoverage)
    $coveragePresent = $true
    foreach ($coverageId in $requiredCoverage) {
        if (@($inputPacket.task_coverage_scope.required_coverage) -notcontains $coverageId) {
            $coveragePresent = $false
        }
    }

    $runtimeOverclaimDetected = (@($inputPacket.actual_boundary.claim_signals) -contains "live_evidence_package_runtime_claim_seen")
    $ciReplayClaimed = (Test-R18EvidencePackageCiReplayClaimed -Status $inputPacket.ci_replay_evidence.ci_replay_status) -or [bool]$inputPacket.runtime_flags.ci_replay_performed
    $knownGaps = @()
    if ($Scenario -eq "ci_replay_gap_known" -or [bool]$inputPacket.ci_gap_disclosed) {
        $knownGaps += $script:R18EvidencePackageCiGap
    }

    return [ordered]@{
        artifact_type = "r18_evidence_package_assessment"
        contract_version = "v1"
        assessment_id = "r18_019_$Scenario`_assessment_v1"
        assessment_name = $Scenario
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        assessment_status = $rule.assessment_status
        source_input_ref = "state/governance/r18_evidence_package_inputs/$Scenario.input.json"
        package_scenario = $Scenario
        action_recommendation = $rule.action_recommendation
        task_coverage_present = $coveragePresent
        evidence_refs_present = (@($inputPacket.evidence_ref_inventory).Count -gt 0)
        proof_review_refs_present = (@($inputPacket.proof_review_refs).Count -ge ((Get-R18EvidencePackageAllProofReviewRefs).Count))
        validation_manifest_refs_present = (@($inputPacket.validation_manifest_refs).Count -ge ((Get-R18EvidencePackageAllValidationManifestRefs).Count))
        validator_refs_present = (@($inputPacket.validator_refs).Count -gt 0)
        test_refs_present = (@($inputPacket.test_refs).Count -gt 0)
        status_surfaces_present = (@($inputPacket.status_surface_refs).Count -eq ((Get-R18EvidencePackageWrapperStatusSurfaces).Count))
        validation_command_inventory_present = (@($inputPacket.validation_command_inventory).Count -gt 0)
        non_claim_checks_present = (@($inputPacket.non_claim_checks).Count -gt 0)
        ci_gap_disclosed = [bool]$inputPacket.ci_gap_disclosed
        ci_replay_claimed = $ciReplayClaimed
        runtime_overclaim_detected = $runtimeOverclaimDetected
        safe_for_future_audit = [bool]$rule.safe_for_future_audit
        blocked_reasons = $rule.blocked_reasons
        known_gaps = $knownGaps
        next_safe_step = $rule.next_safe_step
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageWrapperResults {
    $assessmentResults = @()
    foreach ($scenario in $script:R18EvidencePackageScenarios) {
        $assessment = New-R18EvidencePackageAssessment -Scenario $scenario
        $assessmentResults += [ordered]@{
            package_scenario = $scenario
            source_input_ref = $assessment.source_input_ref
            assessment_status = $assessment.assessment_status
            action_recommendation = $assessment.action_recommendation
            safe_for_future_audit = $assessment.safe_for_future_audit
            blocked_reasons = $assessment.blocked_reasons
            known_gaps = $assessment.known_gaps
            runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        }
    }

    return [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_results"
        contract_version = "v1"
        results_id = "r18_019_evidence_package_wrapper_results_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        result_status = "deterministic_policy_manifest_results_only_not_live_evidence_package_runtime"
        input_count = $script:R18EvidencePackageScenarios.Count
        manifest_count = 1
        assessment_count = $script:R18EvidencePackageScenarios.Count
        aggregate_verdict = $script:R18EvidencePackageVerdict
        assessment_results = $assessmentResults
        positive_claims = @(
            "r18_evidence_package_inputs_created",
            "r18_evidence_package_manifest_created",
            "r18_evidence_package_assessments_created",
            "r18_evidence_package_wrapper_results_created"
        )
        known_gaps = @($script:R18EvidencePackageCiGap)
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageWrapperCheckReport {
    return [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_check_report"
        contract_version = "v1"
        report_id = "r18_019_evidence_package_wrapper_check_report_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        report_status = "deterministic_policy_check_report_only_not_audit_acceptance"
        aggregate_verdict = $script:R18EvidencePackageVerdict
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        package_scenarios = $script:R18EvidencePackageScenarios
        required_task_coverage = Get-R18EvidencePackageRequiredCoverage
        validation_command_inventory = Get-R18EvidencePackageWrapperValidationCommandInventory
        non_claim_checks = Get-R18EvidencePackageWrapperNonClaimChecks
        ci_replay_status = "not_performed_known_gap"
        known_gaps = @($script:R18EvidencePackageCiGap)
        positive_claims = @("r18_evidence_package_wrapper_validator_created")
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageWrapperSnapshot {
    return [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_operator_surface_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_019_evidence_package_wrapper_snapshot_v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        snapshot_status = "read_only_operator_surface_snapshot_not_runtime"
        r18_status = "active_through_r18_019_only"
        planned_from = "R18-020"
        planned_through = "R18-028"
        summary = "Evidence package wrapper foundation exists as deterministic policy/manifest artifacts only; CI replay gap remains disclosed."
        package_scenarios = $script:R18EvidencePackageScenarios
        known_gaps = @($script:R18EvidencePackageCiGap)
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
}

function New-R18EvidencePackageWrapperProofArtifacts {
    $evidenceIndex = [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_evidence_index"
        contract_version = "v1"
        source_task = $script:R18EvidencePackageSourceTask
        source_milestone = $script:R18EvidencePackageSourceMilestone
        evidence_status = "policy_manifest_evidence_index_only_not_runtime"
        evidence_refs = Get-R18EvidencePackageWrapperEvidenceRefs
        authority_refs = Get-R18EvidencePackageWrapperAuthorityRefs
        validation_refs = Get-R18EvidencePackageWrapperValidationCommandInventory
        known_gaps = @($script:R18EvidencePackageCiGap)
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }

    $proofReview = @(
        "# R18-019 Evidence Package Wrapper Proof Review",
        "",
        "Scope: deterministic evidence package wrapper foundation only.",
        "",
        "Current status truth after this task: R18 is active through R18-019 only, R18-020 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Positive proof created: wrapper contract, manifest contract, wrapper profile, six input packets, current manifest, six assessments, results, check report, read-only operator snapshot, validator, focused tests, fixtures, and this proof-review package.",
        "",
        "Known gap: $script:R18EvidencePackageCiGap",
        "",
        "Non-claims: no live evidence package runtime, no audit acceptance, no external audit acceptance, no milestone closeout, no main merge, no CI replay, no GitHub Actions workflow created or run, no release gate execution, no stage/commit/push by wrapper, no recovery action, no Codex/OpenAI API invocation, no automatic new-thread creation, no work-order execution, no board/card runtime mutation, no A2A messages, no live agents, no live skills, no product runtime, no no-manual-prompt-transfer success, and no solved Codex compaction or reliability."
    )

    $validationManifest = @(
        "# R18-019 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-019 only; R18-020 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_evidence_package_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_evidence_package_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_evidence_package_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_status_doc_gate_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_status_doc_gate_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1",
        "- git diff --check",
        "",
        "Validation is policy/manifest validation only; it is not CI replay, audit acceptance, release gate execution, or live runtime execution."
    )

    return [pscustomobject]@{
        EvidenceIndex = $evidenceIndex
        ProofReview = $proofReview
        ValidationManifest = $validationManifest
    }
}

function New-R18EvidencePackageWrapperFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [string[]]$ExpectedFailureFragments = @()
    )

    $fixture = [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_invalid_fixture"
        contract_version = "v1"
        source_task = $script:R18EvidencePackageSourceTask
        target = $Target
        operation = $Operation
        path = $Path
        expected_failure_fragments = $ExpectedFailureFragments
    }
    if ($Operation -eq "set") {
        $fixture["value"] = $Value
    }

    return [pscustomobject]@{ file = $File; fixture = $fixture }
}

function New-R18EvidencePackageWrapperFixtures {
    return @(
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_task_id.json" -Target "manifest_task:R18-019" -Operation "remove" -Path "task_id" -ExpectedFailureFragments @("task_id is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_evidence_ref.json" -Target "input:current_r18_evidence_package" -Operation "remove" -Path "evidence_ref_inventory" -ExpectedFailureFragments @("evidence_ref_inventory is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_proof_review_ref.json" -Target "manifest_task:R18-019" -Operation "remove" -Path "proof_review_ref" -ExpectedFailureFragments @("proof_review_ref is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_validation_manifest_ref.json" -Target "manifest_task:R18-019" -Operation "remove" -Path "validation_manifest_ref" -ExpectedFailureFragments @("validation_manifest_ref is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_status_surface_ref.json" -Target "input:current_r18_evidence_package" -Operation "remove" -Path "status_surface_refs" -ExpectedFailureFragments @("status_surface_refs is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_validator_ref.json" -Target "manifest_task:R18-019" -Operation "remove" -Path "validator_refs" -ExpectedFailureFragments @("validator_refs is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_test_ref.json" -Target "manifest_task:R18-019" -Operation "remove" -Path "test_refs" -ExpectedFailureFragments @("test_refs is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_non_claim_checks.json" -Target "input:current_r18_evidence_package" -Operation "remove" -Path "non_claim_checks" -ExpectedFailureFragments @("non_claim_checks is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_validation_command_inventory.json" -Target "manifest" -Operation "remove" -Path "validation_command_inventory" -ExpectedFailureFragments @("validation_command_inventory is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_ci_gap_disclosure.json" -Target "input:current_r18_evidence_package" -Operation "set" -Path "ci_gap_disclosed" -Value $false -ExpectedFailureFragments @("CI gap disclosure is missing")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_runtime_overclaim_marked_safe.json" -Target "assessment:runtime_overclaim" -Operation "set" -Path "safe_for_future_audit" -Value $true -ExpectedFailureFragments @("runtime_overclaim must not be marked safe")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_proof_review_marked_safe.json" -Target "assessment:missing_proof_review" -Operation "set" -Path "safe_for_future_audit" -Value $true -ExpectedFailureFragments @("missing_proof_review must not be marked safe")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_missing_validation_manifest_marked_safe.json" -Target "assessment:missing_validation_manifest" -Operation "set" -Path "safe_for_future_audit" -Value $true -ExpectedFailureFragments @("missing_validation_manifest must not be marked safe")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_ci_replay_claim_without_workflow_artifact.json" -Target "manifest" -Operation "set" -Path "ci_replay_status" -Value "claimed_performed" -ExpectedFailureFragments @("CI replay is claimed without a real workflow run artifact")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_external_audit_acceptance_claim.json" -Target "results" -Operation "set" -Path "runtime_flags.external_audit_acceptance_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'external_audit_acceptance_claimed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_milestone_closeout_claim.json" -Target "results" -Operation "set" -Path "runtime_flags.milestone_closeout_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'milestone_closeout_claimed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_main_merge_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.main_merge_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'main_merge_claimed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_release_gate_execution_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.release_gate_executed" -Value $true -ExpectedFailureFragments @("runtime flag 'release_gate_executed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_stage_commit_push_performed_claim.json" -Target "results" -Operation "set" -Path "runtime_flags.stage_performed_by_gate" -Value $true -ExpectedFailureFragments @("runtime flag 'stage_performed_by_gate' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_recovery_action_claim.json" -Target "assessment:current_r18_evidence_package" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'recovery_action_performed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_api_invocation_claim.json" -Target "input:current_r18_evidence_package" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -ExpectedFailureFragments @("runtime flag 'codex_api_invoked' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "input:current_r18_evidence_package" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'automatic_new_thread_creation_performed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_work_order_execution_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'work_order_execution_performed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_a2a_message_sent_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -ExpectedFailureFragments @("runtime flag 'a2a_message_sent' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_board_runtime_mutation_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'board_runtime_mutation_performed' must remain false")),
        (New-R18EvidencePackageWrapperFixture -File "invalid_r18_020_completion_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.r18_020_completed" -Value $true -ExpectedFailureFragments @("runtime flag 'r18_020_completed' must remain false"))
    )
}

function New-R18EvidencePackageWrapperArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot))

    $paths = Get-R18EvidencePackageWrapperPaths -RepositoryRoot $RepositoryRoot

    Write-R18EvidencePackageWrapperJson -Path $paths.WrapperContract -Value (New-R18EvidencePackageWrapperContract)
    Write-R18EvidencePackageWrapperJson -Path $paths.ManifestContract -Value (New-R18EvidencePackageManifestContract)
    Write-R18EvidencePackageWrapperJson -Path $paths.Profile -Value (New-R18EvidencePackageWrapperProfile)

    foreach ($scenario in $script:R18EvidencePackageScenarios) {
        Write-R18EvidencePackageWrapperJson -Path (Join-Path $paths.InputRoot "$scenario.input.json") -Value (New-R18EvidencePackageInput -Scenario $scenario)
        Write-R18EvidencePackageWrapperJson -Path (Join-Path $paths.AssessmentRoot "$scenario.assessment.json") -Value (New-R18EvidencePackageAssessment -Scenario $scenario)
    }

    Write-R18EvidencePackageWrapperJson -Path $paths.CurrentManifest -Value (New-R18EvidencePackageManifest)
    Write-R18EvidencePackageWrapperJson -Path $paths.Results -Value (New-R18EvidencePackageWrapperResults)
    Write-R18EvidencePackageWrapperJson -Path $paths.CheckReport -Value (New-R18EvidencePackageWrapperCheckReport)
    Write-R18EvidencePackageWrapperJson -Path $paths.UiSnapshot -Value (New-R18EvidencePackageWrapperSnapshot)

    $fixtures = New-R18EvidencePackageWrapperFixtures
    $fixtureFiles = @()
    foreach ($entry in $fixtures) {
        $fixtureFiles += $entry.file
        Write-R18EvidencePackageWrapperJson -Path (Join-Path $paths.FixtureRoot $entry.file) -Value $entry.fixture
    }
    $fixtureManifest = [ordered]@{
        artifact_type = "r18_evidence_package_wrapper_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18EvidencePackageSourceTask
        fixture_count = $fixtureFiles.Count
        invalid_fixture_files = $fixtureFiles
        runtime_flags = New-R18EvidencePackageWrapperRuntimeFlags
        non_claims = Get-R18EvidencePackageWrapperNonClaims
        rejected_claims = Get-R18EvidencePackageWrapperRejectedClaims
    }
    Write-R18EvidencePackageWrapperJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $fixtureManifest

    $proof = New-R18EvidencePackageWrapperProofArtifacts
    Write-R18EvidencePackageWrapperJson -Path $paths.EvidenceIndex -Value $proof.EvidenceIndex
    Write-R18EvidencePackageWrapperText -Path $paths.ProofReview -Value $proof.ProofReview
    Write-R18EvidencePackageWrapperText -Path $paths.ValidationManifest -Value $proof.ValidationManifest

    return [pscustomobject]@{
        AggregateVerdict = $script:R18EvidencePackageVerdict
        InputCount = $script:R18EvidencePackageScenarios.Count
        ManifestCount = 1
        AssessmentCount = $script:R18EvidencePackageScenarios.Count
        FixtureCount = $fixtureFiles.Count
    }
}

function Assert-R18EvidencePackageCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Test-R18EvidencePackageCiReplayClaimed {
    param([object]$Status)

    $statusText = [string]$Status
    return ($statusText -match "^(claimed|performed|workflow_run_claimed|github_actions_workflow_run_claimed|ci_replay_performed)")
}

function Assert-R18EvidencePackageFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18EvidencePackageCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$field is missing."
        $value = $Object.$field
        if ($null -eq $value) {
            throw "$field is missing."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$field is missing."
        }
        if ($value -is [array] -and $value.Count -eq 0 -and $field -notin @("fixture_refs", "known_gaps", "ci_replay_evidence_refs", "blocked_reasons")) {
            throw "$field is missing."
        }
    }
}

function Assert-R18EvidencePackageRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in Get-R18EvidencePackageWrapperRuntimeFlagNames) {
        Assert-R18EvidencePackageCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flag) -Message "$Context runtime_flags missing '$flag'."
        Assert-R18EvidencePackageCondition -Condition ([bool]$RuntimeFlags.$flag -eq $false) -Message "$Context runtime flag '$flag' must remain false."
    }
}

function Assert-R18EvidencePackageCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18EvidencePackageFields -Object $Artifact -Fields @("source_task", "source_milestone", "runtime_flags", "non_claims", "rejected_claims") -Context $Context
    Assert-R18EvidencePackageCondition -Condition ($Artifact.source_task -eq $script:R18EvidencePackageSourceTask) -Message "$Context source_task must be R18-019."
    Assert-R18EvidencePackageCondition -Condition ($Artifact.source_milestone -eq $script:R18EvidencePackageSourceMilestone) -Message "$Context source_milestone is invalid."
    Assert-R18EvidencePackageRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    if ($Artifact.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Artifact.positive_claims)) {
            Assert-R18EvidencePackageCondition -Condition ((Get-R18EvidencePackageWrapperPositiveClaims) -contains [string]$claim) -Message "$Context positive claim '$claim' is not allowed."
        }
    }
}

function Assert-R18EvidencePackageWrapperContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18EvidencePackageFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_input_fields",
        "required_manifest_fields",
        "required_assessment_fields",
        "required_task_coverage",
        "required_status_surfaces",
        "required_validation_refs",
        "required_non_claim_checks",
        "allowed_package_scenarios",
        "allowed_assessment_statuses",
        "allowed_action_recommendations",
        "required_runtime_false_flags",
        "evidence_inventory_policy",
        "proof_review_policy",
        "validation_manifest_policy",
        "status_surface_policy",
        "non_claim_policy",
        "ci_gap_policy",
        "authority_policy",
        "execution_policy",
        "refusal_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs",
        "runtime_flags"
    ) -Context "R18 evidence package wrapper contract"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Contract -Context "R18 evidence package wrapper contract"
}

function Assert-R18EvidencePackageManifestContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18EvidencePackageFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "required_manifest_packet_fields",
        "required_task_entry_fields",
        "required_runtime_false_flags",
        "manifest_policy",
        "evidence_policy",
        "non_claims",
        "rejected_claims",
        "runtime_flags"
    ) -Context "R18 evidence package manifest contract"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Contract -Context "R18 evidence package manifest contract"
}

function Assert-R18EvidencePackageInput {
    param([Parameter(Mandatory = $true)][object]$InputPacket)

    Assert-R18EvidencePackageFields -Object $InputPacket -Fields $script:R18EvidencePackageInputFields -Context "R18 evidence package input"
    Assert-R18EvidencePackageCommonArtifact -Artifact $InputPacket -Context "R18 evidence package input '$($InputPacket.package_scenario)'"
    Assert-R18EvidencePackageCondition -Condition ($InputPacket.artifact_type -eq "r18_evidence_package_input") -Message "Input artifact_type is invalid."
    Assert-R18EvidencePackageCondition -Condition ($script:R18EvidencePackageScenarios -contains [string]$InputPacket.package_scenario) -Message "Unknown package scenario '$($InputPacket.package_scenario)'."
    Assert-R18EvidencePackageCondition -Condition ($InputPacket.input_status -eq "seed_evidence_package_input_only_not_live_automation") -Message "Input status is invalid."
    Assert-R18EvidencePackageCondition -Condition (@($InputPacket.evidence_ref_inventory).Count -gt 0) -Message "evidence_ref_inventory is missing."
    Assert-R18EvidencePackageCondition -Condition (@($InputPacket.validation_command_inventory).Count -gt 0) -Message "validation_command_inventory is missing."
    Assert-R18EvidencePackageCondition -Condition (@($InputPacket.non_claim_checks).Count -gt 0) -Message "non_claim_checks is missing."

    foreach ($check in Get-R18EvidencePackageWrapperNonClaimChecks) {
        Assert-R18EvidencePackageCondition -Condition (@($InputPacket.non_claim_checks) -contains $check) -Message "Required non-claim check missing: $check"
    }

    if ([string]$InputPacket.package_scenario -eq "current_r18_evidence_package") {
        Assert-R18EvidencePackageCondition -Condition ([bool]$InputPacket.ci_gap_disclosed) -Message "CI gap disclosure is missing."
        foreach ($surface in Get-R18EvidencePackageWrapperStatusSurfaces) {
            Assert-R18EvidencePackageCondition -Condition (@($InputPacket.status_surface_refs) -contains $surface) -Message "Required status surface missing: $surface"
        }
    }
}

function Assert-R18EvidencePackageTaskEntry {
    param([Parameter(Mandatory = $true)][object]$Entry)

    Assert-R18EvidencePackageFields -Object $Entry -Fields $script:R18EvidencePackageTaskEntryFields -Context "R18 evidence package task entry"
    Assert-R18EvidencePackageCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Entry.task_id)) -Message "task_id is missing."
    Assert-R18EvidencePackageCondition -Condition (@($Entry.artifact_refs).Count -gt 0) -Message "artifact_refs is missing for task '$($Entry.task_id)'."
    Assert-R18EvidencePackageCondition -Condition (@($Entry.validator_refs).Count -gt 0) -Message "validator_refs is missing for task '$($Entry.task_id)'."
    Assert-R18EvidencePackageCondition -Condition (@($Entry.test_refs).Count -gt 0) -Message "test_refs is missing for task '$($Entry.task_id)'."
    Assert-R18EvidencePackageCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Entry.proof_review_ref)) -Message "proof_review_ref is missing for task '$($Entry.task_id)'."
    Assert-R18EvidencePackageCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Entry.validation_manifest_ref)) -Message "validation_manifest_ref is missing for task '$($Entry.task_id)'."
    foreach ($strength in @($Entry.evidence_strength)) {
        Assert-R18EvidencePackageCondition -Condition ($script:R18EvidencePackageEvidenceStrengthValues -contains [string]$strength) -Message "Unknown evidence strength '$strength' for task '$($Entry.task_id)'."
    }
}

function Assert-R18EvidencePackageManifest {
    param([Parameter(Mandatory = $true)][object]$Manifest)

    Assert-R18EvidencePackageFields -Object $Manifest -Fields $script:R18EvidencePackageManifestFields -Context "R18 evidence package manifest"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Manifest -Context "R18 evidence package manifest"
    Assert-R18EvidencePackageCondition -Condition ($Manifest.artifact_type -eq "r18_evidence_package_manifest") -Message "Manifest artifact_type is invalid."
    Assert-R18EvidencePackageCondition -Condition ($Manifest.manifest_status -eq "evidence_package_manifest_generated_not_audit_acceptance") -Message "Manifest status is invalid."
    Assert-R18EvidencePackageCondition -Condition ($Manifest.r18_active_through -eq "R18-019" -and $Manifest.planned_from -eq "R18-020" -and $Manifest.planned_through -eq "R18-028") -Message "Manifest must record R18 active through R18-019 only and R18-020 through R18-028 planned only."
    Assert-R18EvidencePackageCondition -Condition (@($Manifest.validation_command_inventory).Count -gt 0) -Message "validation_command_inventory is missing."
    Assert-R18EvidencePackageCondition -Condition (@($Manifest.non_claim_checks).Count -gt 0) -Message "non_claim_checks is missing."
    Assert-R18EvidencePackageCondition -Condition (@($Manifest.known_gaps) -contains $script:R18EvidencePackageCiGap) -Message "CI replay gap disclosure is missing."

    if (Test-R18EvidencePackageCiReplayClaimed -Status $Manifest.ci_replay_status) {
        Assert-R18EvidencePackageCondition -Condition (@($Manifest.ci_replay_evidence_refs).Count -gt 0) -Message "CI replay is claimed without a real workflow run artifact."
    }

    foreach ($surface in Get-R18EvidencePackageWrapperStatusSurfaces) {
        Assert-R18EvidencePackageCondition -Condition (@($Manifest.status_surface_refs) -contains $surface) -Message "Required status surface missing: $surface"
    }

    foreach ($entry in @($Manifest.task_entries)) {
        Assert-R18EvidencePackageTaskEntry -Entry $entry
    }

    foreach ($coverageId in Get-R18EvidencePackageRequiredCoverage) {
        Assert-R18EvidencePackageCondition -Condition (@($Manifest.task_entries | Where-Object { $_.task_id -eq $coverageId }).Count -eq 1) -Message "Required task coverage missing: $coverageId"
    }
}

function Assert-R18EvidencePackageAssessment {
    param([Parameter(Mandatory = $true)][object]$Assessment)

    Assert-R18EvidencePackageFields -Object $Assessment -Fields $script:R18EvidencePackageAssessmentFields -Context "R18 evidence package assessment"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Assessment -Context "R18 evidence package assessment '$($Assessment.package_scenario)'"
    Assert-R18EvidencePackageCondition -Condition ($Assessment.artifact_type -eq "r18_evidence_package_assessment") -Message "Assessment artifact_type is invalid."
    Assert-R18EvidencePackageCondition -Condition ($script:R18EvidencePackageScenarios -contains [string]$Assessment.package_scenario) -Message "Unknown package scenario '$($Assessment.package_scenario)'."
    Assert-R18EvidencePackageCondition -Condition ($script:R18EvidencePackageStatuses -contains [string]$Assessment.assessment_status) -Message "Unknown assessment status '$($Assessment.assessment_status)'."
    Assert-R18EvidencePackageCondition -Condition ($script:R18EvidencePackageActions -contains [string]$Assessment.action_recommendation) -Message "Unknown action recommendation '$($Assessment.action_recommendation)'."

    $rule = Get-R18EvidencePackageAssessmentRule -Scenario ([string]$Assessment.package_scenario)
    Assert-R18EvidencePackageCondition -Condition ($Assessment.assessment_status -eq $rule.assessment_status) -Message "Assessment status does not match deterministic rule for $($Assessment.package_scenario)."
    Assert-R18EvidencePackageCondition -Condition ($Assessment.action_recommendation -eq $rule.action_recommendation) -Message "Assessment action does not match deterministic rule for $($Assessment.package_scenario)."

    if ([bool]$Assessment.safe_for_future_audit -ne [bool]$rule.safe_for_future_audit) {
        if (-not [bool]$rule.safe_for_future_audit) {
            throw "$($Assessment.package_scenario) must not be marked safe."
        }
        throw "$($Assessment.package_scenario) must be marked safe after revalidation."
    }

    switch ([string]$Assessment.package_scenario) {
        "missing_proof_review" {
            Assert-R18EvidencePackageCondition -Condition (-not [bool]$Assessment.safe_for_future_audit) -Message "missing_proof_review must not be marked safe."
        }
        "missing_validation_manifest" {
            Assert-R18EvidencePackageCondition -Condition (-not [bool]$Assessment.safe_for_future_audit) -Message "missing_validation_manifest must not be marked safe."
        }
        "missing_status_surface" {
            Assert-R18EvidencePackageCondition -Condition (-not [bool]$Assessment.safe_for_future_audit) -Message "missing_status_surface must not be marked safe."
        }
        "runtime_overclaim" {
            Assert-R18EvidencePackageCondition -Condition (-not [bool]$Assessment.safe_for_future_audit) -Message "runtime_overclaim must not be marked safe."
            Assert-R18EvidencePackageCondition -Condition ([bool]$Assessment.runtime_overclaim_detected) -Message "runtime_overclaim must detect runtime overclaim."
        }
        "ci_replay_gap_known" {
            Assert-R18EvidencePackageCondition -Condition ([bool]$Assessment.ci_gap_disclosed) -Message "CI gap disclosure is missing."
            Assert-R18EvidencePackageCondition -Condition (-not [bool]$Assessment.ci_replay_claimed) -Message "CI replay must not be claimed."
        }
    }
}

function Get-R18EvidencePackageTaskStatusMap {
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

function Test-R18EvidencePackageWrapperStatusTruth {
    param([string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18EvidencePackageWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-020 only",
            "R18-021 through R18-028 planned only",
            "R18-019 created evidence package automation wrapper foundation only",
            "Evidence package wrapper artifacts are deterministic policy/manifest artifacts only",
            "Wrapper runtime was not implemented",
            "Audit acceptance was not claimed",
            "External audit acceptance was not claimed",
            "Milestone closeout was not claimed",
            "Main was not merged",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Release gate was not executed",
            "No stage/commit/push was performed by the wrapper",
            "Recovery action was not performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "Automatic new-thread creation was not performed",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed",
            $script:R18EvidencePackageCiGap
        )) {
        Assert-R18EvidencePackageCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-019 truth: $required"
    }

    $authorityStatuses = Get-R18EvidencePackageTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18EvidencePackageTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18EvidencePackageCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 20) {
            Assert-R18EvidencePackageCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-020."
        }
        else {
            Assert-R18EvidencePackageCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-020."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[1-8])') {
        throw "Status surface claims R18 beyond R18-020."
    }
    if ($combinedText -match '(?i)R18-02[1-8].{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-021 or later completion."
    }

    return [pscustomobject]@{
        R18DoneThrough = 20
        R18PlannedStart = 21
        R18PlannedThrough = 28
    }
}

function Test-R18EvidencePackageWrapperSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$WrapperContract,
        [Parameter(Mandatory = $true)][object]$ManifestContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object]$Manifest,
        [Parameter(Mandatory = $true)][object[]]$Assessments,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot)
    )

    $inputPackets = @($Inputs)
    $assessmentPackets = @($Assessments)

    Assert-R18EvidencePackageWrapperContract -Contract $WrapperContract
    Assert-R18EvidencePackageManifestContract -Contract $ManifestContract
    Assert-R18EvidencePackageCommonArtifact -Artifact $Profile -Context "R18 evidence package wrapper profile"
    Assert-R18EvidencePackageManifest -Manifest $Manifest
    Assert-R18EvidencePackageCommonArtifact -Artifact $Results -Context "R18 evidence package wrapper results"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Report -Context "R18 evidence package wrapper check report"
    Assert-R18EvidencePackageCommonArtifact -Artifact $Snapshot -Context "R18 evidence package wrapper snapshot"

    Assert-R18EvidencePackageCondition -Condition (@($inputPackets).Count -eq 6) -Message "R18 evidence package wrapper must have six inputs."
    Assert-R18EvidencePackageCondition -Condition (@($assessmentPackets).Count -eq 6) -Message "R18 evidence package wrapper must have six assessments."

    foreach ($inputPacket in $inputPackets) {
        Assert-R18EvidencePackageInput -InputPacket $inputPacket
    }
    foreach ($assessment in $assessmentPackets) {
        Assert-R18EvidencePackageAssessment -Assessment $assessment
    }

    foreach ($scenario in $script:R18EvidencePackageScenarios) {
        Assert-R18EvidencePackageCondition -Condition (@($inputPackets | Where-Object { $_.package_scenario -eq $scenario }).Count -eq 1) -Message "Missing input scenario '$scenario'."
        Assert-R18EvidencePackageCondition -Condition (@($assessmentPackets | Where-Object { $_.package_scenario -eq $scenario }).Count -eq 1) -Message "Missing assessment scenario '$scenario'."
        $assessment = @($assessmentPackets | Where-Object { $_.package_scenario -eq $scenario })[0]
        Assert-R18EvidencePackageCondition -Condition ($assessment.source_input_ref -eq "state/governance/r18_evidence_package_inputs/$scenario.input.json") -Message "Assessment source ref does not match scenario '$scenario'."
    }

    Assert-R18EvidencePackageCondition -Condition ($Results.artifact_type -eq "r18_evidence_package_wrapper_results") -Message "Results artifact_type is invalid."
    Assert-R18EvidencePackageCondition -Condition ([int]$Results.input_count -eq 6 -and [int]$Results.assessment_count -eq 6) -Message "Results counts are invalid."
    Assert-R18EvidencePackageCondition -Condition ($Report.aggregate_verdict -eq $script:R18EvidencePackageVerdict) -Message "Check report aggregate verdict is invalid."
    Assert-R18EvidencePackageCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_019_only") -Message "Snapshot must record active_through_r18_019_only."

    Test-R18EvidencePackageWrapperStatusTruth -RepositoryRoot $RepositoryRoot | Out-Null

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        InputCount = @($inputPackets).Count
        ManifestCount = 1
        AssessmentCount = @($assessmentPackets).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18EvidencePackageWrapperSet {
    param([string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot))

    $inputs = @()
    $assessments = @()
    foreach ($scenario in $script:R18EvidencePackageScenarios) {
        $inputs += Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_inputs/$scenario.input.json"
        $assessments += Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_assessments/$scenario.assessment.json"
    }

    return [pscustomobject]@{
        WrapperContract = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "contracts/governance/r18_evidence_package_wrapper.contract.json"
        ManifestContract = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "contracts/governance/r18_evidence_package_manifest.contract.json"
        Profile = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_wrapper_profile.json"
        Inputs = $inputs
        Manifest = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json"
        Assessments = $assessments
        Results = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_wrapper_results.json"
        Report = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_evidence_package_wrapper_check_report.json"
        Snapshot = Read-R18EvidencePackageWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_evidence_package_wrapper_snapshot.json"
        Paths = Get-R18EvidencePackageWrapperPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18EvidencePackageWrapper {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18EvidencePackageWrapperRepositoryRoot))

    $set = Get-R18EvidencePackageWrapperSet -RepositoryRoot $RepositoryRoot
    return Test-R18EvidencePackageWrapperSet `
        -WrapperContract $set.WrapperContract `
        -ManifestContract $set.ManifestContract `
        -Profile $set.Profile `
        -Inputs $set.Inputs `
        -Manifest $set.Manifest `
        -Assessments $set.Assessments `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18EvidencePackageWrapperObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value
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

function Remove-R18EvidencePackageWrapperObjectPathValue {
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

function Invoke-R18EvidencePackageWrapperMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18EvidencePackageWrapperObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18EvidencePackageWrapperObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 evidence package wrapper mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18EvidencePackageWrapperPaths, `
    Get-R18EvidencePackageWrapperRuntimeFlagNames, `
    New-R18EvidencePackageWrapperRuntimeFlags, `
    New-R18EvidencePackageWrapperArtifacts, `
    Test-R18EvidencePackageWrapper, `
    Test-R18EvidencePackageWrapperSet, `
    Test-R18EvidencePackageWrapperStatusTruth, `
    Get-R18EvidencePackageWrapperSet, `
    Copy-R18EvidencePackageWrapperObject, `
    Invoke-R18EvidencePackageWrapperMutation
