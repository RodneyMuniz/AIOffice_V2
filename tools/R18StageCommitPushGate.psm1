Set-StrictMode -Version Latest

$script:R18StageSourceTask = "R18-017"
$script:R18StageSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18StageRepository = "RodneyMuniz/AIOffice_V2"
$script:R18StageBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18StageVerdict = "generated_r18_017_stage_commit_push_gate_foundation_only"
$script:R18StageBoundary = "R18 active through R18-017 only; R18-018 through R18-028 planned only"

$script:R18StageRuntimeFlagFields = @(
    "stage_commit_push_gate_runtime_implemented",
    "stage_performed_by_gate",
    "commit_performed_by_gate",
    "push_performed_by_gate",
    "stage_performed",
    "commit_performed",
    "push_performed",
    "main_merge_claimed",
    "milestone_closeout_claimed",
    "operator_approval_runtime_implemented",
    "operator_approval_executed",
    "approval_inferred_from_narration",
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
    "pull_performed",
    "rebase_performed",
    "reset_performed",
    "merge_performed",
    "checkout_or_switch_performed",
    "clean_performed",
    "restore_performed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_018_completed"
)

$script:R18StageGateInputFields = @(
    "artifact_type",
    "contract_version",
    "gate_input_id",
    "gate_input_name",
    "source_task",
    "source_milestone",
    "gate_input_status",
    "gate_scenario",
    "operator_approval_ref",
    "operator_approval_status",
    "wip_classification_ref",
    "wip_safe",
    "remote_verification_ref",
    "remote_safe",
    "validation_refs",
    "validation_passed",
    "status_boundary_ref",
    "status_boundary_expected",
    "status_boundary_actual",
    "status_boundary_safe",
    "allowed_paths",
    "forbidden_paths",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18StageAssessmentFields = @(
    "artifact_type",
    "contract_version",
    "assessment_id",
    "assessment_name",
    "source_task",
    "source_milestone",
    "assessment_status",
    "source_gate_input_ref",
    "gate_scenario",
    "gate_status",
    "action_recommendation",
    "safe_to_stage",
    "safe_to_commit",
    "safe_to_push",
    "operator_approval_check",
    "wip_check",
    "remote_branch_check",
    "validation_check",
    "status_boundary_check",
    "path_check",
    "evidence_check",
    "authority_check",
    "blocked_reasons",
    "next_safe_step",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18StageScenarios = @(
    "safe_release_candidate",
    "blocked_by_missing_operator_approval",
    "blocked_by_unsafe_wip",
    "blocked_by_remote_branch",
    "blocked_by_failed_validation",
    "blocked_by_status_boundary_drift"
)

$script:R18StageStatuses = @(
    "gate_passed_policy_only",
    "gate_blocked_missing_operator_approval",
    "gate_blocked_unsafe_wip",
    "gate_blocked_remote_branch",
    "gate_blocked_failed_validation",
    "gate_blocked_status_boundary_drift"
)

$script:R18StageActions = @(
    "allow_future_stage_commit_push_after_runtime_gate",
    "request_operator_approval",
    "stop_and_resolve_wip",
    "stop_and_resolve_remote_branch",
    "stop_and_fix_validation",
    "stop_and_fix_status_boundary"
)

function Get-R18StageCommitPushRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18StageCommitPushPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18StageCommitPushJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot)
    )

    $resolvedPath = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required artifact missing: $Path"
    }

    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Write-R18StageCommitPushJson {
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

function Write-R18StageCommitPushText {
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

function Copy-R18StageCommitPushObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18StageCommitPushPaths {
    param([string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot))

    return [ordered]@{
        GateContract = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_stage_commit_push_gate.contract.json"
        AssessmentContract = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json"
        Profile = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_stage_commit_push_gate_profile.json"
        InputRoot = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_stage_commit_push_gate_inputs"
        AssessmentRoot = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_stage_commit_push_gate_assessments"
        Results = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_stage_commit_push_gate_results.json"
        CheckReport = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_stage_commit_push_gate_check_report.json"
        UiSnapshot = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_stage_commit_push_gate_snapshot.json"
        FixtureRoot = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_stage_commit_push_gate"
        ProofRoot = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate"
        EvidenceIndex = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/evidence_index.json"
        ProofReview = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/proof_review.md"
        ValidationManifest = Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/validation_manifest.md"
    }
}

function Get-R18StageCommitPushRuntimeFlagNames {
    return $script:R18StageRuntimeFlagFields
}

function New-R18StageCommitPushRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18StageRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18StageCommitPushPositiveClaims {
    return @(
        "r18_stage_commit_push_gate_contract_created",
        "r18_stage_commit_push_gate_assessment_contract_created",
        "r18_stage_commit_push_gate_profile_created",
        "r18_stage_commit_push_gate_inputs_created",
        "r18_stage_commit_push_gate_assessments_created",
        "r18_stage_commit_push_gate_results_created",
        "r18_stage_commit_push_gate_validator_created",
        "r18_stage_commit_push_gate_fixtures_created",
        "r18_stage_commit_push_gate_proof_review_created"
    )
}

function Get-R18StageCommitPushRejectedClaims {
    return @(
        "live_stage_commit_push_gate_runtime",
        "stage_performed_by_gate",
        "commit_performed_by_gate",
        "push_performed_by_gate",
        "stage_performed",
        "commit_performed",
        "push_performed",
        "main_merge",
        "milestone_closeout",
        "operator_approval_runtime",
        "operator_approval_execution",
        "approval_inferred_from_narration",
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
        "pull",
        "rebase",
        "reset",
        "merge",
        "checkout_or_switch",
        "clean",
        "restore",
        "board_runtime_mutation",
        "live_agent_runtime",
        "live_skill_execution",
        "a2a_message_sent",
        "live_a2a_runtime",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_018_or_later_completion",
        "operator_approval_inferred",
        "unsafe_wip_marked_safe",
        "unsafe_remote_marked_safe",
        "failed_validation_marked_safe",
        "status_boundary_drift_marked_safe"
    )
}

function Get-R18StageCommitPushNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-017 only.",
        "R18-018 through R18-028 remain planned only.",
        "R18-017 created stage/commit/push gate foundation only.",
        "Stage/commit/push gate artifacts are deterministic policy artifacts only.",
        "Gate runtime was not implemented.",
        "The gate did not stage, commit, or push.",
        "Future policy eligibility is not execution.",
        "Normal Codex worker commit and push for R18-017 is not gate execution.",
        "Main was not merged.",
        "Milestone closeout was not claimed.",
        "Operator approval runtime was not implemented.",
        "No approval was inferred from narration.",
        "No risky action was approved by seed packets.",
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
        "No branch mutation was performed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved."
    )
}

function Get-R18StageCommitPushEvidenceRefs {
    return @(
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json",
        "state/runtime/r18_stage_commit_push_gate_profile.json",
        "state/runtime/r18_stage_commit_push_gate_inputs/",
        "state/runtime/r18_stage_commit_push_gate_assessments/",
        "state/runtime/r18_stage_commit_push_gate_results.json",
        "state/runtime/r18_stage_commit_push_gate_check_report.json",
        "state/ui/r18_operator_surface/r18_stage_commit_push_gate_snapshot.json",
        "tools/R18StageCommitPushGate.psm1",
        "tools/new_r18_stage_commit_push_gate.ps1",
        "tools/validate_r18_stage_commit_push_gate.ps1",
        "tests/test_r18_stage_commit_push_gate.ps1",
        "tests/fixtures/r18_stage_commit_push_gate/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/"
    )
}

function Get-R18StageCommitPushAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "contracts/governance/r18_operator_decision_packet.contract.json",
        "state/governance/r18_operator_approval_requests/",
        "state/governance/r18_operator_approval_decisions/",
        "state/governance/r18_operator_approval_scope_matrix.json",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_current_verification.json",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "state/runtime/r18_wip_classifier_results.json",
        "contracts/runtime/r18_new_context_prompt_packet.contract.json",
        "state/runtime/r18_new_context_prompt_packet_manifest.json",
        "contracts/runtime/r18_continuation_packet.contract.json",
        "state/runtime/r18_continuation_packets/",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18StageCommitPushValidationRefs {
    return @(
        "tools/validate_r18_stage_commit_push_gate.ps1",
        "tests/test_r18_stage_commit_push_gate.ps1",
        "tools/validate_r18_operator_approval_gate.ps1",
        "tests/test_r18_operator_approval_gate.ps1",
        "tools/validate_r18_retry_escalation_policy.ps1",
        "tests/test_r18_retry_escalation_policy.ps1",
        "tools/validate_r18_new_context_prompt_generator.ps1",
        "tests/test_r18_new_context_prompt_generator.ps1",
        "tools/validate_r18_continuation_packet_generator.ps1",
        "tests/test_r18_continuation_packet_generator.ps1",
        "tools/validate_r18_remote_branch_verifier.ps1",
        "tests/test_r18_remote_branch_verifier.ps1",
        "tools/validate_r18_wip_classifier.ps1",
        "tests/test_r18_wip_classifier.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_opening_authority.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R18StageCommitPushAllowedPaths {
    return @(
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json",
        "state/runtime/r18_stage_commit_push_gate_profile.json",
        "state/runtime/r18_stage_commit_push_gate_inputs/",
        "state/runtime/r18_stage_commit_push_gate_assessments/",
        "state/runtime/r18_stage_commit_push_gate_results.json",
        "state/runtime/r18_stage_commit_push_gate_check_report.json",
        "state/ui/r18_operator_surface/r18_stage_commit_push_gate_snapshot.json",
        "tools/R18StageCommitPushGate.psm1",
        "tools/new_r18_stage_commit_push_gate.ps1",
        "tools/validate_r18_stage_commit_push_gate.ps1",
        "tests/test_r18_stage_commit_push_gate.ps1",
        "tests/fixtures/r18_stage_commit_push_gate/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18StageCommitPushForbiddenPaths {
    return @(
        ".local_backups/",
        "governance/reports/AIOffice_V2_Revised_R17_Plan.md",
        "state/proof_reviews/r13_",
        "state/proof_reviews/r14_",
        "state/proof_reviews/r15_",
        "state/proof_reviews/r16_",
        ".git/",
        "secrets/",
        ".env",
        "state/runtime/live_gate_runtime/",
        "main"
    )
}

function Get-R18StageCommitPushRule {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    switch ($Scenario) {
        "safe_release_candidate" {
            return [pscustomobject]@{
                gate_status = "gate_passed_policy_only"
                action_recommendation = "allow_future_stage_commit_push_after_runtime_gate"
                safe_to_stage = $true
                safe_to_commit = $true
                safe_to_push = $true
                next_safe_step = "Future runtime may proceed only if it re-verifies the same approval, WIP, remote, validation, status-boundary, path, evidence, and authority checks immediately before any stage/commit/push action."
                blocked_reasons = @()
            }
        }
        "blocked_by_missing_operator_approval" {
            return [pscustomobject]@{
                gate_status = "gate_blocked_missing_operator_approval"
                action_recommendation = "request_operator_approval"
                safe_to_stage = $false
                safe_to_commit = $false
                safe_to_push = $false
                next_safe_step = "Request explicit finite-scope operator approval for stage_commit_push_gate; do not infer approval from narration."
                blocked_reasons = @("operator_approval_missing_or_not_valid_for_stage_commit_push_gate")
            }
        }
        "blocked_by_unsafe_wip" {
            return [pscustomobject]@{
                gate_status = "gate_blocked_unsafe_wip"
                action_recommendation = "stop_and_resolve_wip"
                safe_to_stage = $false
                safe_to_commit = $false
                safe_to_push = $false
                next_safe_step = "Stop and resolve WIP classification outside this gate; do not clean, abandon, restore, or stage WIP through R18-017."
                blocked_reasons = @("wip_classification_not_safe")
            }
        }
        "blocked_by_remote_branch" {
            return [pscustomobject]@{
                gate_status = "gate_blocked_remote_branch"
                action_recommendation = "stop_and_resolve_remote_branch"
                safe_to_stage = $false
                safe_to_commit = $false
                safe_to_push = $false
                next_safe_step = "Stop and resolve remote branch identity outside this gate; do not pull, rebase, reset, merge, checkout, switch, clean, restore, or push through R18-017."
                blocked_reasons = @("remote_branch_verification_not_safe")
            }
        }
        "blocked_by_failed_validation" {
            return [pscustomobject]@{
                gate_status = "gate_blocked_failed_validation"
                action_recommendation = "stop_and_fix_validation"
                safe_to_stage = $false
                safe_to_commit = $false
                safe_to_push = $false
                next_safe_step = "Stop and fix validation outside this gate; R18-017 records the refusal and does not run fixes."
                blocked_reasons = @("validation_evidence_failed")
            }
        }
        "blocked_by_status_boundary_drift" {
            return [pscustomobject]@{
                gate_status = "gate_blocked_status_boundary_drift"
                action_recommendation = "stop_and_fix_status_boundary"
                safe_to_stage = $false
                safe_to_commit = $false
                safe_to_push = $false
                next_safe_step = "Stop and fix status-boundary truth outside this gate; do not auto-edit status docs except scoped R18-017 status updates."
                blocked_reasons = @("status_boundary_drift_detected")
            }
        }
        default { throw "Unknown R18 stage/commit/push gate scenario '$Scenario'." }
    }
}

function New-R18StageCommitPushGateContract {
    return [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_contract"
        contract_version = "v1"
        contract_id = "r18_017_stage_commit_push_gate_contract_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        repository = $script:R18StageRepository
        branch = $script:R18StageBranch
        scope = "deterministic_stage_commit_push_gate_policy_artifacts_only_not_runtime"
        purpose = "Define fail-closed policy contracts for future stage/commit/push decisions without implementing or executing a live gate runtime."
        required_gate_input_fields = $script:R18StageGateInputFields
        required_assessment_fields = $script:R18StageAssessmentFields
        allowed_gate_scenarios = $script:R18StageScenarios
        allowed_gate_statuses = $script:R18StageStatuses
        allowed_action_recommendations = $script:R18StageActions
        required_runtime_false_flags = $script:R18StageRuntimeFlagFields
        operator_approval_policy = [ordered]@{
            explicit_operator_approval_required = $true
            approval_scope_required = "stage_commit_push_gate"
            valid_operator_approval_status = "valid_for_stage_commit_push_gate_future_policy_only"
            missing_or_inferred_approval_fails_closed = $true
            seed_packets_do_not_execute_approval = $true
        }
        wip_policy = [ordered]@{ clean_wip_classification_required = $true; unsafe_wip_blocks_gate = $true; wip_cleanup_or_abandonment_allowed = $false }
        remote_branch_policy = [ordered]@{ safe_remote_branch_verification_required = $true; remote_mismatch_blocks_gate = $true; pull_rebase_reset_merge_push_allowed = $false }
        validation_policy = [ordered]@{ validation_refs_required = $true; validation_passed_required = $true; failed_validation_blocks_gate = $true; validator_does_not_run_fixes = $true }
        status_boundary_policy = [ordered]@{ expected_boundary = $script:R18StageBoundary; boundary_truth_required = $true; r18_018_or_later_completion_claims_fail_closed = $true }
        path_policy = [ordered]@{ allowed_paths_required = $true; forbidden_paths_required = $true; allowed_paths = Get-R18StageCommitPushAllowedPaths; forbidden_paths = Get-R18StageCommitPushForbiddenPaths; operator_local_backup_paths_forbidden = $true; historical_r13_r16_evidence_edits_forbidden = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; missing_evidence_refs_fail_closed = $true; evidence_must_precede_future_runtime_gate = $true }
        authority_policy = [ordered]@{ authority_refs_required = $true; missing_authority_refs_fail_closed = $true; current_status_boundary = $script:R18StageBoundary; source_authority_refs = Get-R18StageCommitPushAuthorityRefs }
        execution_policy = [ordered]@{ live_gate_runtime_allowed = $false; stage_allowed_by_artifact = $false; commit_allowed_by_artifact = $false; push_allowed_by_artifact = $false; main_merge_allowed = $false; milestone_closeout_allowed = $false; future_runtime_must_revalidate_immediately = $true }
        refusal_policy = [ordered]@{ fail_closed_on_missing_required_field = $true; blocked_scenarios_must_mark_stage_commit_push_unsafe = $true; refusal_packets_are_policy_only = $true }
        allowed_positive_claims = Get-R18StageCommitPushPositiveClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
        non_claims = Get-R18StageCommitPushNonClaims
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
    }
}

function New-R18StageCommitPushAssessmentContract {
    return [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_assessment_contract"
        contract_version = "v1"
        contract_id = "r18_017_stage_commit_push_gate_assessment_contract_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        required_assessment_packet_fields = $script:R18StageAssessmentFields
        required_runtime_false_flags = $script:R18StageRuntimeFlagFields
        decision_policy = [ordered]@{
            safe_release_candidate = "May mark future policy eligibility safe only when operator approval, WIP, remote branch, validation, status boundary, path, evidence, and authority checks pass; it must not perform stage/commit/push."
            blocked_by_missing_operator_approval = "Must mark stage/commit/push unsafe and recommend request_operator_approval without inferring approval."
            blocked_by_unsafe_wip = "Must mark stage/commit/push unsafe and recommend stop_and_resolve_wip without cleanup or abandonment."
            blocked_by_remote_branch = "Must mark stage/commit/push unsafe and recommend stop_and_resolve_remote_branch without branch mutation."
            blocked_by_failed_validation = "Must mark stage/commit/push unsafe and recommend stop_and_fix_validation without running fixes."
            blocked_by_status_boundary_drift = "Must mark stage/commit/push unsafe and recommend stop_and_fix_status_boundary without broad status automation."
        }
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
        runtime_flags = New-R18StageCommitPushRuntimeFlags
    }
}

function New-R18StageCommitPushProfile {
    return [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_profile"
        contract_version = "v1"
        profile_id = "r18_017_stage_commit_push_gate_profile_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        profile_status = "profile_seed_only_not_live_gate_runtime"
        gate_boundary = $script:R18StageBoundary
        scenario_count = $script:R18StageScenarios.Count
        allowed_gate_scenarios = $script:R18StageScenarios
        allowed_gate_statuses = $script:R18StageStatuses
        allowed_action_recommendations = $script:R18StageActions
        positive_claims = @("r18_stage_commit_push_gate_profile_created")
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function Get-R18StageCommitPushDefinition {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    $common = [ordered]@{
        operator_approval_ref = "future_runtime_explicit_operator_approval_packet_required_for_stage_commit_push_gate"
        operator_approval_status = "valid_for_stage_commit_push_gate_future_policy_only"
        wip_classification_ref = "state/runtime/r18_wip_classification_packets/no_wip.classification.json"
        wip_safe = $true
        remote_verification_ref = "state/runtime/r18_remote_branch_current_verification.json"
        remote_safe = $true
        validation_refs = Get-R18StageCommitPushValidationRefs
        validation_passed = $true
        status_boundary_ref = "tools/validate_status_doc_gate.ps1"
        status_boundary_expected = $script:R18StageBoundary
        status_boundary_actual = $script:R18StageBoundary
        status_boundary_safe = $true
        allowed_paths = Get-R18StageCommitPushAllowedPaths
        forbidden_paths = Get-R18StageCommitPushForbiddenPaths
    }

    switch ($Scenario) {
        "safe_release_candidate" { return [pscustomobject]$common }
        "blocked_by_missing_operator_approval" {
            $copy = Copy-R18StageCommitPushObject -Value $common
            $copy.operator_approval_ref = "missing_explicit_operator_approval_for_stage_commit_push_gate"
            $copy.operator_approval_status = "missing"
            return $copy
        }
        "blocked_by_unsafe_wip" {
            $copy = Copy-R18StageCommitPushObject -Value $common
            $copy.wip_classification_ref = "state/runtime/r18_wip_classification_packets/unexpected_tracked_wip.classification.json"
            $copy.wip_safe = $false
            return $copy
        }
        "blocked_by_remote_branch" {
            $copy = Copy-R18StageCommitPushObject -Value $common
            $copy.remote_verification_ref = "state/runtime/r18_remote_branch_verification_packets/remote_ahead.verification.json"
            $copy.remote_safe = $false
            return $copy
        }
        "blocked_by_failed_validation" {
            $copy = Copy-R18StageCommitPushObject -Value $common
            $copy.validation_refs = @("tools/validate_status_doc_gate.ps1", "tests/test_status_doc_gate.ps1", "git diff --check")
            $copy.validation_passed = $false
            return $copy
        }
        "blocked_by_status_boundary_drift" {
            $copy = Copy-R18StageCommitPushObject -Value $common
            $copy.status_boundary_actual = "R18 active through R18-018 only; R18-019 through R18-028 planned only"
            $copy.status_boundary_safe = $false
            return $copy
        }
        default { throw "Unknown R18 stage/commit/push gate scenario '$Scenario'." }
    }
}

function New-R18StageCommitPushGateInput {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    $definition = Get-R18StageCommitPushDefinition -Scenario $Scenario
    return [pscustomobject][ordered]@{
        artifact_type = "r18_stage_commit_push_gate_input"
        contract_version = "v1"
        gate_input_id = "r18_017_gate_input_$Scenario"
        gate_input_name = ("R18-017 {0} gate input" -f ($Scenario -replace "_", " "))
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        gate_input_status = "seed_gate_input_only_not_live_gate"
        gate_scenario = $Scenario
        operator_approval_ref = $definition.operator_approval_ref
        operator_approval_status = $definition.operator_approval_status
        wip_classification_ref = $definition.wip_classification_ref
        wip_safe = [bool]$definition.wip_safe
        remote_verification_ref = $definition.remote_verification_ref
        remote_safe = [bool]$definition.remote_safe
        validation_refs = @($definition.validation_refs)
        validation_passed = [bool]$definition.validation_passed
        status_boundary_ref = $definition.status_boundary_ref
        status_boundary_expected = $definition.status_boundary_expected
        status_boundary_actual = $definition.status_boundary_actual
        status_boundary_safe = [bool]$definition.status_boundary_safe
        allowed_paths = @($definition.allowed_paths)
        forbidden_paths = @($definition.forbidden_paths)
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushGateAssessment {
    param([Parameter(Mandatory = $true)][Alias("Input")][object]$GateInput)

    if ($GateInput -is [System.Collections.IDictionary]) {
        $GateInput = [pscustomobject]$GateInput
    }

    $scenario = [string]$GateInput.gate_scenario
    $rule = Get-R18StageCommitPushRule -Scenario $scenario
    $checks = [ordered]@{
        operator_approval = ([string]$GateInput.operator_approval_status -eq "valid_for_stage_commit_push_gate_future_policy_only" -and -not [string]::IsNullOrWhiteSpace([string]$GateInput.operator_approval_ref))
        wip = [bool]$GateInput.wip_safe
        remote = [bool]$GateInput.remote_safe
        validation = [bool]$GateInput.validation_passed
        status_boundary = [bool]$GateInput.status_boundary_safe
        path = (@($GateInput.allowed_paths).Count -gt 0 -and @($GateInput.forbidden_paths).Count -gt 0)
        evidence = @($GateInput.evidence_refs).Count -gt 0
        authority = @($GateInput.authority_refs).Count -gt 0
    }

    return [pscustomobject][ordered]@{
        artifact_type = "r18_stage_commit_push_gate_assessment"
        contract_version = "v1"
        assessment_id = "r18_017_gate_assessment_$scenario"
        assessment_name = ("R18-017 {0} gate assessment" -f ($scenario -replace "_", " "))
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        assessment_status = "assessment_packet_only_not_live_gate"
        source_gate_input_ref = "state/runtime/r18_stage_commit_push_gate_inputs/$scenario.input.json"
        gate_scenario = $scenario
        gate_status = $rule.gate_status
        action_recommendation = $rule.action_recommendation
        safe_to_stage = [bool]$rule.safe_to_stage
        safe_to_commit = [bool]$rule.safe_to_commit
        safe_to_push = [bool]$rule.safe_to_push
        operator_approval_check = [ordered]@{ passed = [bool]$checks.operator_approval; required_scope = "stage_commit_push_gate"; operator_approval_ref = $GateInput.operator_approval_ref; operator_approval_status = $GateInput.operator_approval_status; approval_inferred_from_narration = $false }
        wip_check = [ordered]@{ passed = [bool]$checks.wip; wip_classification_ref = $GateInput.wip_classification_ref; wip_safe = [bool]$GateInput.wip_safe; wip_cleanup_performed = $false; wip_abandonment_performed = $false }
        remote_branch_check = [ordered]@{ passed = [bool]$checks.remote; remote_verification_ref = $GateInput.remote_verification_ref; remote_safe = [bool]$GateInput.remote_safe; branch_mutation_performed = $false }
        validation_check = [ordered]@{ passed = [bool]$checks.validation; validation_refs = @($GateInput.validation_refs); validation_passed = [bool]$GateInput.validation_passed; fixes_run = $false }
        status_boundary_check = [ordered]@{ passed = [bool]$checks.status_boundary; status_boundary_ref = $GateInput.status_boundary_ref; expected = $GateInput.status_boundary_expected; actual = $GateInput.status_boundary_actual; status_boundary_safe = [bool]$GateInput.status_boundary_safe }
        path_check = [ordered]@{ passed = [bool]$checks.path; allowed_paths = @($GateInput.allowed_paths); forbidden_paths = @($GateInput.forbidden_paths); forbidden_path_stageable = $false }
        evidence_check = [ordered]@{ passed = [bool]$checks.evidence; evidence_refs = @($GateInput.evidence_refs) }
        authority_check = [ordered]@{ passed = [bool]$checks.authority; authority_refs = @($GateInput.authority_refs) }
        blocked_reasons = @($rule.blocked_reasons)
        next_safe_step = $rule.next_safe_step
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushResults {
    param([Parameter(Mandatory = $true)][object[]]$Inputs, [Parameter(Mandatory = $true)][object[]]$Assessments)

    return [pscustomobject][ordered]@{
        artifact_type = "r18_stage_commit_push_gate_results"
        contract_version = "v1"
        results_id = "r18_017_stage_commit_push_gate_results_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        result_status = "deterministic_policy_results_only_not_live_gate_runtime"
        gate_input_count = @($Inputs).Count
        assessment_count = @($Assessments).Count
        assessment_results = @($Assessments | ForEach-Object {
                [ordered]@{
                    gate_scenario = $_.gate_scenario
                    source_gate_input_ref = $_.source_gate_input_ref
                    gate_status = $_.gate_status
                    action_recommendation = $_.action_recommendation
                    safe_to_stage = [bool]$_.safe_to_stage
                    safe_to_commit = [bool]$_.safe_to_commit
                    safe_to_push = [bool]$_.safe_to_push
                    blocked_reasons = @($_.blocked_reasons)
                    runtime_flags = New-R18StageCommitPushRuntimeFlags
                }
            })
        positive_claims = @("r18_stage_commit_push_gate_inputs_created", "r18_stage_commit_push_gate_assessments_created", "r18_stage_commit_push_gate_results_created")
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushCheckReport {
    param([Parameter(Mandatory = $true)][object[]]$Inputs, [Parameter(Mandatory = $true)][object[]]$Assessments)

    return [pscustomobject][ordered]@{
        artifact_type = "r18_stage_commit_push_gate_check_report"
        contract_version = "v1"
        check_report_id = "r18_017_stage_commit_push_gate_check_report_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        aggregate_verdict = $script:R18StageVerdict
        report_status = "validator_report_seed_only_not_gate_execution"
        gate_input_count = @($Inputs).Count
        assessment_count = @($Assessments).Count
        status_boundary = $script:R18StageBoundary
        checks = @(
            [ordered]@{ check_id = "contract_presence"; status = "passed" },
            [ordered]@{ check_id = "six_gate_inputs"; status = "passed"; count = @($Inputs).Count },
            [ordered]@{ check_id = "six_gate_assessments"; status = "passed"; count = @($Assessments).Count },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "non_claim_enforcement"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = $script:R18StageBoundary }
        )
        positive_claims = @("r18_stage_commit_push_gate_validator_created", "r18_stage_commit_push_gate_fixtures_created")
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Assessments)

    return [pscustomobject][ordered]@{
        artifact_type = "r18_stage_commit_push_gate_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_017_stage_commit_push_gate_snapshot_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        snapshot_status = "operator_surface_snapshot_seed_only_not_ui_runtime"
        r18_status = "active_through_r18_017_only"
        planned_boundary = "r18_018_through_r18_028_planned_only"
        safe_release_candidate_status = (@($Assessments | Where-Object { $_.gate_scenario -eq "safe_release_candidate" })[0]).gate_status
        blocked_assessment_count = @($Assessments | Where-Object { $_.gate_scenario -ne "safe_release_candidate" }).Count
        gate_runtime_implemented = $false
        stage_commit_push_performed_by_gate = $false
        positive_claims = @("r18_stage_commit_push_gate_profile_created")
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string[]]$Expected
    )

    $fixture = [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_invalid_fixture"
        contract_version = "v1"
        fixture_id = ($File -replace "\.json$", "")
        source_task = $script:R18StageSourceTask
        target = $Target
        operation = $Operation
        path = $Path
        expected_failure_fragments = $Expected
    }
    if ($Operation -eq "set") {
        $fixture["value"] = $Value
    }
    return [pscustomobject]$fixture
}

function New-R18StageCommitPushFixtureDefinitions {
    return @(
        (New-R18StageCommitPushFixture -File "invalid_missing_gate_input_id.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "gate_input_id" -Value $null -Expected @("gate_input_id")),
        (New-R18StageCommitPushFixture -File "invalid_missing_assessment_id.json" -Target "assessment:safe_release_candidate" -Operation "remove" -Path "assessment_id" -Value $null -Expected @("assessment_id")),
        (New-R18StageCommitPushFixture -File "invalid_missing_operator_approval_ref.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "operator_approval_ref" -Value $null -Expected @("operator_approval_ref")),
        (New-R18StageCommitPushFixture -File "invalid_missing_wip_classification_ref.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "wip_classification_ref" -Value $null -Expected @("wip_classification_ref")),
        (New-R18StageCommitPushFixture -File "invalid_missing_remote_verification_ref.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "remote_verification_ref" -Value $null -Expected @("remote_verification_ref")),
        (New-R18StageCommitPushFixture -File "invalid_missing_validation_refs.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "validation_refs" -Value $null -Expected @("validation_refs")),
        (New-R18StageCommitPushFixture -File "invalid_missing_status_boundary_ref.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "status_boundary_ref" -Value $null -Expected @("status_boundary_ref")),
        (New-R18StageCommitPushFixture -File "invalid_missing_allowed_paths.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "allowed_paths" -Value $null -Expected @("allowed_paths")),
        (New-R18StageCommitPushFixture -File "invalid_missing_forbidden_paths.json" -Target "input:safe_release_candidate" -Operation "remove" -Path "forbidden_paths" -Value $null -Expected @("forbidden_paths")),
        (New-R18StageCommitPushFixture -File "invalid_safe_when_operator_approval_missing.json" -Target "input:safe_release_candidate" -Operation "set" -Path "operator_approval_status" -Value "missing" -Expected @("operator approval")),
        (New-R18StageCommitPushFixture -File "invalid_safe_when_wip_unsafe.json" -Target "input:safe_release_candidate" -Operation "set" -Path "wip_safe" -Value $false -Expected @("WIP")),
        (New-R18StageCommitPushFixture -File "invalid_safe_when_remote_unsafe.json" -Target "input:safe_release_candidate" -Operation "set" -Path "remote_safe" -Value $false -Expected @("remote")),
        (New-R18StageCommitPushFixture -File "invalid_safe_when_validation_failed.json" -Target "input:safe_release_candidate" -Operation "set" -Path "validation_passed" -Value $false -Expected @("validation")),
        (New-R18StageCommitPushFixture -File "invalid_safe_when_status_boundary_drift.json" -Target "input:safe_release_candidate" -Operation "set" -Path "status_boundary_safe" -Value $false -Expected @("status boundary")),
        (New-R18StageCommitPushFixture -File "invalid_stage_performed_claim.json" -Target "assessment:safe_release_candidate" -Operation "set" -Path "runtime_flags.stage_performed_by_gate" -Value $true -Expected @("stage_performed_by_gate")),
        (New-R18StageCommitPushFixture -File "invalid_commit_performed_claim.json" -Target "assessment:safe_release_candidate" -Operation "set" -Path "runtime_flags.commit_performed_by_gate" -Value $true -Expected @("commit_performed_by_gate")),
        (New-R18StageCommitPushFixture -File "invalid_push_performed_claim.json" -Target "assessment:safe_release_candidate" -Operation "set" -Path "runtime_flags.push_performed_by_gate" -Value $true -Expected @("push_performed_by_gate")),
        (New-R18StageCommitPushFixture -File "invalid_main_merge_claim.json" -Target "results" -Operation "set" -Path "runtime_flags.main_merge_claimed" -Value $true -Expected @("main_merge_claimed")),
        (New-R18StageCommitPushFixture -File "invalid_milestone_closeout_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.milestone_closeout_claimed" -Value $true -Expected @("milestone_closeout_claimed")),
        (New-R18StageCommitPushFixture -File "invalid_live_gate_runtime_claim.json" -Target "gate_contract" -Operation "set" -Path "runtime_flags.stage_commit_push_gate_runtime_implemented" -Value $true -Expected @("stage_commit_push_gate_runtime_implemented")),
        (New-R18StageCommitPushFixture -File "invalid_operator_approval_runtime_claim.json" -Target "input:blocked_by_missing_operator_approval" -Operation "set" -Path "runtime_flags.operator_approval_runtime_implemented" -Value $true -Expected @("operator_approval_runtime_implemented")),
        (New-R18StageCommitPushFixture -File "invalid_recovery_action_claim.json" -Target "assessment:blocked_by_unsafe_wip" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Expected @("recovery_action_performed")),
        (New-R18StageCommitPushFixture -File "invalid_work_order_execution_claim.json" -Target "results" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Expected @("work_order_execution_performed")),
        (New-R18StageCommitPushFixture -File "invalid_api_invocation_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -Expected @("codex_api_invoked")),
        (New-R18StageCommitPushFixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "input:safe_release_candidate" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Expected @("automatic_new_thread_creation_performed")),
        (New-R18StageCommitPushFixture -File "invalid_a2a_message_sent_claim.json" -Target "assessment:blocked_by_remote_branch" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Expected @("a2a_message_sent")),
        (New-R18StageCommitPushFixture -File "invalid_board_runtime_mutation_claim.json" -Target "assessment:blocked_by_failed_validation" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Expected @("board_runtime_mutation_performed")),
        (New-R18StageCommitPushFixture -File "invalid_r18_018_completion_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.r18_018_completed" -Value $true -Expected @("r18_018_completed"))
    )
}

function New-R18StageCommitPushFixtureManifest {
    return [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18StageSourceTask
        fixture_count = (New-R18StageCommitPushFixtureDefinitions).Count
        invalid_fixture_files = @((New-R18StageCommitPushFixtureDefinitions) | ForEach-Object { "$($_.fixture_id).json" })
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_stage_commit_push_gate_evidence_index"
        contract_version = "v1"
        evidence_index_id = "r18_017_stage_commit_push_gate_evidence_index_v1"
        source_task = $script:R18StageSourceTask
        source_milestone = $script:R18StageSourceMilestone
        evidence_status = "policy_artifact_evidence_index_only"
        evidence_refs = Get-R18StageCommitPushEvidenceRefs
        authority_refs = Get-R18StageCommitPushAuthorityRefs
        validation_refs = Get-R18StageCommitPushValidationRefs
        runtime_flags = New-R18StageCommitPushRuntimeFlags
        non_claims = Get-R18StageCommitPushNonClaims
        rejected_claims = Get-R18StageCommitPushRejectedClaims
    }
}

function New-R18StageCommitPushProofReviewText {
    return @(
        "# R18-017 Stage/Commit/Push Gate Proof Review",
        "",
        "R18-017 creates deterministic stage/commit/push gate contracts, input packets, assessment packets, results, a check report, fixtures, validator tooling, and an operator-surface snapshot only.",
        "",
        "The safe-release candidate scenario records future policy eligibility only. It does not stage, commit, push, merge main, close a milestone, infer operator approval, execute recovery, run retries, execute work orders, invoke APIs, send A2A messages, mutate board/card runtime state, create Codex threads, invoke live agents, or execute live skills.",
        "",
        "Status truth after this task: R18 is active through R18-017 only, and R18-018 through R18-028 remain planned only.",
        "",
        "Normal Codex worker commit and push of the R18-017 repository changes is not the R18-017 gate executing."
    )
}

function New-R18StageCommitPushValidationManifestText {
    return @(
        "# R18-017 Stage/Commit/Push Gate Validation Manifest",
        "",
        "Expected validation commands:",
        "",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_stage_commit_push_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_stage_commit_push_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_stage_commit_push_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "- git diff --check",
        "",
        "The R18-017 gate validator is fail-closed on missing artifacts, missing required fields, unknown scenarios/statuses/actions, unsafe safe-release inputs, safe blocked assessments, runtime claims, API claims, work-order execution claims, board/A2A/agent/skill claims, stage/commit/push claims, main merge claims, milestone closeout claims, and R18-018 or later completion claims."
    )
}

function New-R18StageCommitPushArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot))

    $paths = Get-R18StageCommitPushPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18StageCommitPushGateContract
    $assessmentContract = New-R18StageCommitPushAssessmentContract
    $profile = New-R18StageCommitPushProfile
    $inputs = @()
    $assessments = @()

    foreach ($scenario in $script:R18StageScenarios) {
        $GateInput = New-R18StageCommitPushGateInput -Scenario $scenario
        if ($GateInput -is [System.Collections.IDictionary]) {
            $GateInput = [pscustomobject]$GateInput
        }
        $inputs += $GateInput
        $assessment = New-R18StageCommitPushGateAssessment -Input $GateInput
        if ($assessment -is [System.Collections.IDictionary]) {
            $assessment = [pscustomobject]$assessment
        }
        $assessments += $assessment
    }

    $results = New-R18StageCommitPushResults -Inputs $inputs -Assessments $assessments
    $report = New-R18StageCommitPushCheckReport -Inputs $inputs -Assessments $assessments
    $snapshot = New-R18StageCommitPushSnapshot -Assessments $assessments

    Write-R18StageCommitPushJson -Path $paths.GateContract -Value $contract
    Write-R18StageCommitPushJson -Path $paths.AssessmentContract -Value $assessmentContract
    Write-R18StageCommitPushJson -Path $paths.Profile -Value $profile
    foreach ($GateInput in $inputs) {
        Write-R18StageCommitPushJson -Path (Join-Path $paths.InputRoot "$($GateInput.gate_scenario).input.json") -Value $GateInput
    }
    foreach ($assessment in $assessments) {
        Write-R18StageCommitPushJson -Path (Join-Path $paths.AssessmentRoot "$($assessment.gate_scenario).assessment.json") -Value $assessment
    }
    Write-R18StageCommitPushJson -Path $paths.Results -Value $results
    Write-R18StageCommitPushJson -Path $paths.CheckReport -Value $report
    Write-R18StageCommitPushJson -Path $paths.UiSnapshot -Value $snapshot
    Write-R18StageCommitPushJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18StageCommitPushFixtureManifest)
    foreach ($fixture in New-R18StageCommitPushFixtureDefinitions) {
        Write-R18StageCommitPushJson -Path (Join-Path $paths.FixtureRoot "$($fixture.fixture_id).json") -Value $fixture
    }
    Write-R18StageCommitPushJson -Path $paths.EvidenceIndex -Value (New-R18StageCommitPushEvidenceIndex)
    Write-R18StageCommitPushText -Path $paths.ProofReview -Value (New-R18StageCommitPushProofReviewText)
    Write-R18StageCommitPushText -Path $paths.ValidationManifest -Value (New-R18StageCommitPushValidationManifestText)

    return [pscustomobject]@{
        AggregateVerdict = $script:R18StageVerdict
        GateInputCount = @($inputs).Count
        AssessmentCount = @($assessments).Count
        FixtureCount = (New-R18StageCommitPushFixtureDefinitions).Count
        RuntimeFlags = $report.runtime_flags
    }
}

function Assert-R18StageCommitPushCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18StageCommitPushRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18StageCommitPushCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18StageCommitPushRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in $script:R18StageRuntimeFlagFields) {
        Assert-R18StageCommitPushCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flag) -Message "$Context missing runtime flag '$flag'."
        Assert-R18StageCommitPushCondition -Condition ([bool]$RuntimeFlags.$flag -eq $false) -Message "$Context runtime flag '$flag' must remain false."
    }
}

function Assert-R18StageCommitPushNoForbiddenTrueProperties {
    param(
        [AllowNull()][object]$Object,
        [string]$Context = "artifact"
    )

    if ($null -eq $Object) {
        return
    }
    if ($Object -is [string] -or $Object -is [ValueType]) {
        return
    }
    if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [System.Management.Automation.PSCustomObject])) {
        foreach ($item in @($Object)) {
            Assert-R18StageCommitPushNoForbiddenTrueProperties -Object $item -Context $Context
        }
        return
    }

    foreach ($property in $Object.PSObject.Properties) {
        if ($script:R18StageRuntimeFlagFields -contains $property.Name) {
            Assert-R18StageCommitPushCondition -Condition ([bool]$property.Value -eq $false) -Message "$Context claims forbidden runtime flag '$($property.Name)'."
        }
        Assert-R18StageCommitPushNoForbiddenTrueProperties -Object $property.Value -Context $Context
    }
}

function Assert-R18StageCommitPushPositiveClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -notcontains "positive_claims") {
        return
    }

    foreach ($claim in @($Object.positive_claims)) {
        Assert-R18StageCommitPushCondition -Condition ((Get-R18StageCommitPushPositiveClaims) -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
    }
}

function Assert-R18StageCommitPushCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18StageCommitPushRequiredFields -Object $Artifact -Fields @("artifact_type", "contract_version", "source_task", "source_milestone", "runtime_flags", "non_claims", "rejected_claims") -Context $Context
    Assert-R18StageCommitPushCondition -Condition ($Artifact.source_task -eq $script:R18StageSourceTask) -Message "$Context source_task must be R18-017."
    Assert-R18StageCommitPushRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    Assert-R18StageCommitPushNoForbiddenTrueProperties -Object $Artifact -Context $Context
    Assert-R18StageCommitPushPositiveClaims -Object $Artifact -Context $Context
}

function Assert-R18StageCommitPushContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18StageCommitPushRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_gate_input_fields",
        "required_assessment_fields",
        "allowed_gate_scenarios",
        "allowed_gate_statuses",
        "allowed_action_recommendations",
        "required_runtime_false_flags",
        "operator_approval_policy",
        "wip_policy",
        "remote_branch_policy",
        "validation_policy",
        "status_boundary_policy",
        "path_policy",
        "evidence_policy",
        "authority_policy",
        "execution_policy",
        "refusal_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs",
        "runtime_flags"
    ) -Context "R18 stage/commit/push gate contract"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Contract -Context "R18 stage/commit/push gate contract"
    foreach ($scenario in $script:R18StageScenarios) {
        Assert-R18StageCommitPushCondition -Condition (@($Contract.allowed_gate_scenarios) -contains $scenario) -Message "Gate contract missing scenario '$scenario'."
    }
}

function Assert-R18StageCommitPushAssessmentContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18StageCommitPushRequiredFields -Object $Contract -Fields @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "required_assessment_packet_fields",
        "required_runtime_false_flags",
        "decision_policy",
        "non_claims",
        "rejected_claims",
        "runtime_flags"
    ) -Context "R18 stage/commit/push assessment contract"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Contract -Context "R18 stage/commit/push assessment contract"
}

function Assert-R18StageCommitPushInput {
    param([Parameter(Mandatory = $true)][Alias("Input")][object]$GateInput)

    Assert-R18StageCommitPushRequiredFields -Object $GateInput -Fields $script:R18StageGateInputFields -Context "R18 stage/commit/push gate input"
    Assert-R18StageCommitPushCommonArtifact -Artifact $GateInput -Context "R18 stage/commit/push gate input '$($GateInput.gate_scenario)'"
    Assert-R18StageCommitPushCondition -Condition ($GateInput.artifact_type -eq "r18_stage_commit_push_gate_input") -Message "R18 gate input artifact_type is invalid."
    Assert-R18StageCommitPushCondition -Condition ($GateInput.gate_input_status -eq "seed_gate_input_only_not_live_gate") -Message "R18 gate input status must be seed-only."
    Assert-R18StageCommitPushCondition -Condition ($script:R18StageScenarios -contains [string]$GateInput.gate_scenario) -Message "Unknown gate scenario '$($GateInput.gate_scenario)'."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$GateInput.gate_input_id)) -Message "R18 gate input gate_input_id is blank."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$GateInput.operator_approval_ref)) -Message "R18 gate input operator_approval_ref is blank."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$GateInput.wip_classification_ref)) -Message "R18 gate input wip_classification_ref is blank."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$GateInput.remote_verification_ref)) -Message "R18 gate input remote_verification_ref is blank."
    Assert-R18StageCommitPushCondition -Condition (@($GateInput.validation_refs).Count -gt 0) -Message "R18 gate input validation_refs is missing."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$GateInput.status_boundary_ref)) -Message "R18 gate input status_boundary_ref is blank."
    Assert-R18StageCommitPushCondition -Condition (@($GateInput.allowed_paths).Count -gt 0) -Message "R18 gate input allowed_paths is missing."
    Assert-R18StageCommitPushCondition -Condition (@($GateInput.forbidden_paths).Count -gt 0) -Message "R18 gate input forbidden_paths is missing."
    Assert-R18StageCommitPushCondition -Condition (@($GateInput.evidence_refs).Count -gt 0) -Message "R18 gate input evidence_refs is missing."
    Assert-R18StageCommitPushCondition -Condition (@($GateInput.authority_refs).Count -gt 0) -Message "R18 gate input authority_refs is missing."

    switch ([string]$GateInput.gate_scenario) {
        "safe_release_candidate" {
            Assert-R18StageCommitPushCondition -Condition ($GateInput.operator_approval_status -eq "valid_for_stage_commit_push_gate_future_policy_only") -Message "safe_release_candidate requires valid operator approval status for stage_commit_push_gate."
            Assert-R18StageCommitPushCondition -Condition ([bool]$GateInput.wip_safe) -Message "safe_release_candidate requires WIP safe."
            Assert-R18StageCommitPushCondition -Condition ([bool]$GateInput.remote_safe) -Message "safe_release_candidate requires remote safe."
            Assert-R18StageCommitPushCondition -Condition ([bool]$GateInput.validation_passed) -Message "safe_release_candidate requires validation passed."
            Assert-R18StageCommitPushCondition -Condition ([bool]$GateInput.status_boundary_safe) -Message "safe_release_candidate requires status boundary safe."
            Assert-R18StageCommitPushCondition -Condition (@($GateInput.evidence_refs).Count -gt 0) -Message "safe_release_candidate requires evidence refs."
            Assert-R18StageCommitPushCondition -Condition (@($GateInput.authority_refs).Count -gt 0) -Message "safe_release_candidate requires authority refs."
        }
        "blocked_by_missing_operator_approval" {
            Assert-R18StageCommitPushCondition -Condition ($GateInput.operator_approval_status -ne "valid_for_stage_commit_push_gate_future_policy_only") -Message "blocked_by_missing_operator_approval must not have valid operator approval."
        }
        "blocked_by_unsafe_wip" {
            Assert-R18StageCommitPushCondition -Condition (-not [bool]$GateInput.wip_safe) -Message "blocked_by_unsafe_wip must have unsafe WIP."
        }
        "blocked_by_remote_branch" {
            Assert-R18StageCommitPushCondition -Condition (-not [bool]$GateInput.remote_safe) -Message "blocked_by_remote_branch must have unsafe remote branch."
        }
        "blocked_by_failed_validation" {
            Assert-R18StageCommitPushCondition -Condition (-not [bool]$GateInput.validation_passed) -Message "blocked_by_failed_validation must have failed validation."
        }
        "blocked_by_status_boundary_drift" {
            Assert-R18StageCommitPushCondition -Condition (-not [bool]$GateInput.status_boundary_safe) -Message "blocked_by_status_boundary_drift must have status boundary drift."
        }
    }
}

function Assert-R18StageCommitPushAssessment {
    param([Parameter(Mandatory = $true)][object]$Assessment)

    Assert-R18StageCommitPushRequiredFields -Object $Assessment -Fields $script:R18StageAssessmentFields -Context "R18 stage/commit/push assessment"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Assessment -Context "R18 stage/commit/push assessment '$($Assessment.gate_scenario)'"
    Assert-R18StageCommitPushCondition -Condition ($Assessment.artifact_type -eq "r18_stage_commit_push_gate_assessment") -Message "R18 gate assessment artifact_type is invalid."
    Assert-R18StageCommitPushCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Assessment.assessment_id)) -Message "R18 gate assessment assessment_id is blank."
    Assert-R18StageCommitPushCondition -Condition ($script:R18StageScenarios -contains [string]$Assessment.gate_scenario) -Message "Unknown assessment gate scenario '$($Assessment.gate_scenario)'."
    Assert-R18StageCommitPushCondition -Condition ($script:R18StageStatuses -contains [string]$Assessment.gate_status) -Message "Unknown gate status '$($Assessment.gate_status)'."
    Assert-R18StageCommitPushCondition -Condition ($script:R18StageActions -contains [string]$Assessment.action_recommendation) -Message "Unknown action recommendation '$($Assessment.action_recommendation)'."
    Assert-R18StageCommitPushCondition -Condition (@($Assessment.evidence_refs).Count -gt 0) -Message "R18 gate assessment evidence_refs is missing."
    Assert-R18StageCommitPushCondition -Condition (@($Assessment.authority_refs).Count -gt 0) -Message "R18 gate assessment authority_refs is missing."

    $rule = Get-R18StageCommitPushRule -Scenario ([string]$Assessment.gate_scenario)
    Assert-R18StageCommitPushCondition -Condition ($Assessment.gate_status -eq $rule.gate_status) -Message "Assessment gate_status does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StageCommitPushCondition -Condition ($Assessment.action_recommendation -eq $rule.action_recommendation) -Message "Assessment action_recommendation does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StageCommitPushCondition -Condition ([bool]$Assessment.safe_to_stage -eq [bool]$rule.safe_to_stage) -Message "Assessment safe_to_stage does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StageCommitPushCondition -Condition ([bool]$Assessment.safe_to_commit -eq [bool]$rule.safe_to_commit) -Message "Assessment safe_to_commit does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StageCommitPushCondition -Condition ([bool]$Assessment.safe_to_push -eq [bool]$rule.safe_to_push) -Message "Assessment safe_to_push does not match deterministic rule for $($Assessment.gate_scenario)."

    if ([string]$Assessment.gate_scenario -eq "safe_release_candidate") {
        Assert-R18StageCommitPushCondition -Condition ([bool]$Assessment.safe_to_stage -and [bool]$Assessment.safe_to_commit -and [bool]$Assessment.safe_to_push) -Message "safe_release_candidate must be policy-only safe for all three future actions."
        Assert-R18StageCommitPushCondition -Condition (@($Assessment.blocked_reasons).Count -eq 0) -Message "safe_release_candidate must not have blocked reasons."
    }
    else {
        Assert-R18StageCommitPushCondition -Condition (-not [bool]$Assessment.safe_to_stage -and -not [bool]$Assessment.safe_to_commit -and -not [bool]$Assessment.safe_to_push) -Message "Blocked scenario '$($Assessment.gate_scenario)' must not be safe to stage, commit, or push."
        Assert-R18StageCommitPushCondition -Condition (@($Assessment.blocked_reasons).Count -gt 0) -Message "Blocked scenario '$($Assessment.gate_scenario)' must record blocked reasons."
    }
}

function Get-R18StageTaskStatusMap {
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

function Test-R18StageCommitPushStatusTruth {
    param([string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18StageCommitPushPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-018 only",
            "R18-019 through R18-028 planned only",
            "R18-017 created stage/commit/push gate foundation only",
            "Stage/commit/push gate artifacts are deterministic policy artifacts only",
            "Gate runtime was not implemented",
            "The gate did not stage, commit, or push",
            "Normal Codex worker commit/push of this R18-017 task is not the gate executing",
            "Main was not merged",
            "Milestone closeout was not claimed",
            "Operator approval runtime was not implemented",
            "Recovery action was not performed",
            "Retry execution was not performed",
            "Continuation packets were not executed",
            "Prompt packets were not executed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed"
        )) {
        Assert-R18StageCommitPushCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-017 truth: $required"
    }

    $authorityStatuses = Get-R18StageTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18StageTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18StageCommitPushCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 18) {
            Assert-R18StageCommitPushCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-018."
        }
        else {
            Assert-R18StageCommitPushCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-018."
        }
    }

    if ($combinedText -match 'R18 active through R18-(019|02[0-8])') {
        throw "Status surface claims R18 beyond R18-018."
    }
    if ($combinedText -match '(?i)R18-(019|02[0-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-019 or later completion."
    }
}

function Test-R18StageCommitPushGateSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$GateContract,
        [Parameter(Mandatory = $true)][object]$AssessmentContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object[]]$Assessments,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot)
    )

    Assert-R18StageCommitPushContract -Contract $GateContract
    Assert-R18StageCommitPushAssessmentContract -Contract $AssessmentContract
    Assert-R18StageCommitPushCommonArtifact -Artifact $Profile -Context "R18 stage/commit/push gate profile"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Results -Context "R18 stage/commit/push gate results"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Report -Context "R18 stage/commit/push gate check report"
    Assert-R18StageCommitPushCommonArtifact -Artifact $Snapshot -Context "R18 stage/commit/push gate snapshot"
    Assert-R18StageCommitPushCondition -Condition (@($Inputs).Count -eq 6) -Message "R18 stage/commit/push gate must have six gate inputs."
    Assert-R18StageCommitPushCondition -Condition (@($Assessments).Count -eq 6) -Message "R18 stage/commit/push gate must have six assessments."

    foreach ($GateInput in @($Inputs)) {
        Assert-R18StageCommitPushInput -Input $GateInput
    }
    foreach ($assessment in @($Assessments)) {
        Assert-R18StageCommitPushAssessment -Assessment $assessment
    }

    foreach ($scenario in $script:R18StageScenarios) {
        Assert-R18StageCommitPushCondition -Condition (@($Inputs | Where-Object { $_.gate_scenario -eq $scenario }).Count -eq 1) -Message "Missing gate input scenario '$scenario'."
        Assert-R18StageCommitPushCondition -Condition (@($Assessments | Where-Object { $_.gate_scenario -eq $scenario }).Count -eq 1) -Message "Missing assessment scenario '$scenario'."
        $assessment = @($Assessments | Where-Object { $_.gate_scenario -eq $scenario })[0]
        Assert-R18StageCommitPushCondition -Condition ($assessment.source_gate_input_ref -eq "state/runtime/r18_stage_commit_push_gate_inputs/$scenario.input.json") -Message "Assessment source ref does not match scenario '$scenario'."
    }

    Assert-R18StageCommitPushCondition -Condition ($Results.artifact_type -eq "r18_stage_commit_push_gate_results") -Message "Results artifact_type is invalid."
    Assert-R18StageCommitPushCondition -Condition ([int]$Results.gate_input_count -eq 6 -and [int]$Results.assessment_count -eq 6) -Message "Results counts are invalid."
    Assert-R18StageCommitPushCondition -Condition ($Report.artifact_type -eq "r18_stage_commit_push_gate_check_report") -Message "Check report artifact_type is invalid."
    Assert-R18StageCommitPushCondition -Condition ($Report.aggregate_verdict -eq $script:R18StageVerdict) -Message "Check report aggregate verdict is invalid."
    Assert-R18StageCommitPushCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_017_only") -Message "Snapshot must record active_through_r18_017_only."

    Test-R18StageCommitPushStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        GateInputCount = @($Inputs).Count
        AssessmentCount = @($Assessments).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18StageCommitPushGateSet {
    param([string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot))

    $inputs = @()
    $assessments = @()
    foreach ($scenario in $script:R18StageScenarios) {
        $inputs += Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/runtime/r18_stage_commit_push_gate_inputs/$scenario.input.json"
        $assessments += Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/runtime/r18_stage_commit_push_gate_assessments/$scenario.assessment.json"
    }

    return [pscustomobject]@{
        GateContract = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "contracts/runtime/r18_stage_commit_push_gate.contract.json"
        AssessmentContract = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json"
        Profile = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/runtime/r18_stage_commit_push_gate_profile.json"
        Inputs = $inputs
        Assessments = $assessments
        Results = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/runtime/r18_stage_commit_push_gate_results.json"
        Report = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/runtime/r18_stage_commit_push_gate_check_report.json"
        Snapshot = Read-R18StageCommitPushJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_stage_commit_push_gate_snapshot.json"
        Paths = Get-R18StageCommitPushPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18StageCommitPushGate {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18StageCommitPushRepositoryRoot))

    $set = Get-R18StageCommitPushGateSet -RepositoryRoot $RepositoryRoot
    return Test-R18StageCommitPushGateSet `
        -GateContract $set.GateContract `
        -AssessmentContract $set.AssessmentContract `
        -Profile $set.Profile `
        -Inputs $set.Inputs `
        -Assessments $set.Assessments `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18StageCommitPushObjectPathValue {
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

function Remove-R18StageCommitPushObjectPathValue {
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

function Invoke-R18StageCommitPushMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18StageCommitPushObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18StageCommitPushObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 stage/commit/push gate mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18StageCommitPushPaths, `
    Get-R18StageCommitPushRuntimeFlagNames, `
    New-R18StageCommitPushArtifacts, `
    Test-R18StageCommitPushGate, `
    Test-R18StageCommitPushGateSet, `
    Test-R18StageCommitPushStatusTruth, `
    Get-R18StageCommitPushGateSet, `
    Copy-R18StageCommitPushObject, `
    Invoke-R18StageCommitPushMutation
