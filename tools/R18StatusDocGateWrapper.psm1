Set-StrictMode -Version Latest

$script:R18StatusDocWrapperSourceTask = "R18-018"
$script:R18StatusDocWrapperSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18StatusDocWrapperRepository = "RodneyMuniz/AIOffice_V2"
$script:R18StatusDocWrapperBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18StatusDocWrapperVerdict = "generated_r18_018_status_doc_gate_wrapper_foundation_only"
$script:R18StatusDocWrapperBoundary = "R18 active through R18-019 only; R18-020 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18StatusDocWrapperRuntimeFlagFields = @(
    "status_doc_gate_wrapper_runtime_implemented",
    "live_status_doc_gate_runtime_executed",
    "release_gate_executed",
    "stage_commit_push_gate_runtime_implemented",
    "stage_performed_by_gate",
    "commit_performed_by_gate",
    "push_performed_by_gate",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "main_merge_claimed",
    "milestone_closeout_claimed",
    "external_audit_acceptance_claimed",
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

$script:R18StatusDocWrapperInputFields = @(
    "artifact_type",
    "contract_version",
    "input_id",
    "input_name",
    "source_task",
    "source_milestone",
    "input_status",
    "gate_scenario",
    "status_surface_refs",
    "expected_boundary",
    "actual_boundary",
    "r18_active_through",
    "planned_from",
    "planned_through",
    "non_claim_checks",
    "validation_refs",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18StatusDocWrapperAssessmentFields = @(
    "artifact_type",
    "contract_version",
    "assessment_id",
    "assessment_name",
    "source_task",
    "source_milestone",
    "assessment_status",
    "source_input_ref",
    "gate_scenario",
    "gate_status",
    "action_recommendation",
    "status_surfaces_present",
    "boundary_matches_expected",
    "runtime_overclaim_detected",
    "future_task_claim_detected",
    "non_claims_preserved",
    "validation_refs_present",
    "evidence_refs_present",
    "authority_refs_present",
    "safe_for_future_release_gate",
    "blocked_reasons",
    "next_safe_step",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18StatusDocWrapperScenarios = @(
    "current_status_surfaces",
    "missing_active_state",
    "status_boundary_drift",
    "overclaim_runtime",
    "r18_020_premature_claim"
)

$script:R18StatusDocWrapperStatuses = @(
    "status_gate_passed_policy_only",
    "status_gate_blocked_missing_surface",
    "status_gate_blocked_boundary_drift",
    "status_gate_blocked_runtime_overclaim",
    "status_gate_blocked_premature_future_claim"
)

$script:R18StatusDocWrapperActions = @(
    "allow_future_release_gate_after_revalidation",
    "stop_and_restore_missing_status_surface",
    "stop_and_fix_status_boundary",
    "stop_and_remove_runtime_overclaim",
    "stop_and_remove_future_task_claim"
)

function Get-R18StatusDocGateWrapperRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18StatusDocGateWrapperPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18StatusDocGateWrapperJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot)
    )

    $resolvedPath = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required artifact missing: $Path"
    }

    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Write-R18StatusDocGateWrapperJson {
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

function Write-R18StatusDocGateWrapperText {
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

function Copy-R18StatusDocGateWrapperObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18StatusDocGateWrapperPaths {
    param([string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot))

    return [ordered]@{
        WrapperContract = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_status_doc_gate_wrapper.contract.json"
        AssessmentContract = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r18_status_doc_gate_assessment.contract.json"
        Profile = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_status_doc_gate_wrapper_profile.json"
        InputRoot = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_status_doc_gate_inputs"
        AssessmentRoot = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_status_doc_gate_assessments"
        Results = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_status_doc_gate_wrapper_results.json"
        CheckReport = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r18_status_doc_gate_wrapper_check_report.json"
        UiSnapshot = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_status_doc_gate_wrapper_snapshot.json"
        FixtureRoot = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_status_doc_gate_wrapper"
        ProofRoot = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper"
        EvidenceIndex = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper/evidence_index.json"
        ProofReview = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper/proof_review.md"
        ValidationManifest = Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper/validation_manifest.md"
    }
}

function Get-R18StatusDocGateWrapperRuntimeFlagNames {
    return $script:R18StatusDocWrapperRuntimeFlagFields
}

function New-R18StatusDocGateWrapperRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18StatusDocWrapperRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18StatusDocGateWrapperPositiveClaims {
    return @(
        "r18_status_doc_gate_wrapper_contract_created",
        "r18_status_doc_gate_assessment_contract_created",
        "r18_status_doc_gate_wrapper_profile_created",
        "r18_status_doc_gate_inputs_created",
        "r18_status_doc_gate_assessments_created",
        "r18_status_doc_gate_wrapper_results_created",
        "r18_status_doc_gate_wrapper_validator_created",
        "r18_status_doc_gate_wrapper_fixtures_created",
        "r18_status_doc_gate_wrapper_proof_review_created"
    )
}

function Get-R18StatusDocGateWrapperRejectedClaims {
    return @(
        "live_status_doc_gate_runtime",
        "status_doc_gate_wrapper_runtime",
        "release_gate_execution",
        "stage_commit_push_gate_runtime",
        "stage_performed_by_gate",
        "commit_performed_by_gate",
        "push_performed_by_gate",
        "ci_replay_performed",
        "github_actions_workflow_created",
        "github_actions_workflow_run_claimed",
        "main_merge",
        "milestone_closeout",
        "external_audit_acceptance",
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
        "missing_status_surface_marked_safe",
        "status_boundary_drift_marked_safe",
        "runtime_overclaim_marked_safe",
        "future_task_claim_marked_safe"
    )
}

function Get-R18StatusDocGateWrapperNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-019 only.",
        "R18-020 through R18-028 remain planned only.",
        "R18-018 created status-doc gate automation wrapper foundation only.",
        "Status-doc gate wrapper artifacts are deterministic policy artifacts only.",
        "Wrapper runtime was not implemented.",
        "Live status-doc gate runtime was not executed.",
        "Release gate was not executed.",
        "Stage/commit/push gate runtime was not implemented by R18-018.",
        "No stage/commit/push was performed by the wrapper.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Main was not merged.",
        "Milestone closeout was not claimed.",
        "External audit acceptance was not claimed.",
        "Operator approval runtime was not implemented.",
        "Recovery runtime was not implemented.",
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
        "R18-020 is not complete."
    )
}

function Get-R18StatusDocGateWrapperNonClaimChecks {
    return @(
        "no product runtime",
        "no live recovery runtime",
        "no live A2A runtime",
        "no live agent runtime",
        "no live skill execution",
        "no work-order execution",
        "no board/card runtime mutation",
        "no automatic new-thread creation",
        "no Codex/OpenAI API invocation",
        "no no-manual-prompt-transfer success",
        "no solved Codex compaction",
        "no solved Codex reliability",
        "no main merge",
        "no milestone closeout",
        "no external audit acceptance",
        "no CI replay claim unless a real workflow run artifact exists"
    )
}

function Get-R18StatusDocGateWrapperStatusSurfaces {
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

function Get-R18StatusDocGateWrapperEvidenceRefs {
    return @(
        "contracts/governance/r18_status_doc_gate_wrapper.contract.json",
        "contracts/governance/r18_status_doc_gate_assessment.contract.json",
        "state/governance/r18_status_doc_gate_wrapper_profile.json",
        "state/governance/r18_status_doc_gate_inputs/",
        "state/governance/r18_status_doc_gate_assessments/",
        "state/governance/r18_status_doc_gate_wrapper_results.json",
        "state/governance/r18_status_doc_gate_wrapper_check_report.json",
        "state/ui/r18_operator_surface/r18_status_doc_gate_wrapper_snapshot.json",
        "tools/R18StatusDocGateWrapper.psm1",
        "tools/new_r18_status_doc_gate_wrapper.ps1",
        "tools/validate_r18_status_doc_gate_wrapper.ps1",
        "tests/test_r18_status_doc_gate_wrapper.ps1",
        "tests/fixtures/r18_status_doc_gate_wrapper/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper/"
    )
}

function Get-R18StatusDocGateWrapperAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "contracts/runtime/r18_stage_commit_push_gate.contract.json",
        "state/runtime/r18_stage_commit_push_gate_assessments/",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/",
        "contracts/runtime/r18_retry_escalation_policy.contract.json",
        "state/runtime/r18_retry_escalation_decisions/",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18StatusDocGateWrapperValidationRefs {
    return @(
        "tools/validate_r18_status_doc_gate_wrapper.ps1",
        "tests/test_r18_status_doc_gate_wrapper.ps1",
        "tools/validate_r18_stage_commit_push_gate.ps1",
        "tests/test_r18_stage_commit_push_gate.ps1",
        "tools/validate_r18_operator_approval_gate.ps1",
        "tests/test_r18_operator_approval_gate.ps1",
        "tools/validate_r18_retry_escalation_policy.ps1",
        "tests/test_r18_retry_escalation_policy.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18StatusDocGateWrapperExpectedBoundary {
    return [ordered]@{
        r17_status = "R17 closed with caveats through R17-028 only"
        r18_status = "R18 active through R18-019 only"
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        main_merged = $false
        summary = $script:R18StatusDocWrapperBoundary
    }
}

function Copy-R18StatusDocGateWrapperBoundary {
    return Copy-R18StatusDocGateWrapperObject -Value (New-R18StatusDocGateWrapperExpectedBoundary)
}

function Get-R18StatusDocGateWrapperRule {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    switch ($Scenario) {
        "current_status_surfaces" {
            return [pscustomobject]@{
                gate_status = "status_gate_passed_policy_only"
                action_recommendation = "allow_future_release_gate_after_revalidation"
                status_surfaces_present = $true
                boundary_matches_expected = $true
                runtime_overclaim_detected = $false
                future_task_claim_detected = $false
                safe_for_future_release_gate = $true
                next_safe_step = "Future release or stage/commit/push work may consume this package only after re-running the wrapper and status-doc gate against the then-current repository head."
                blocked_reasons = @()
            }
        }
        "missing_active_state" {
            return [pscustomobject]@{
                gate_status = "status_gate_blocked_missing_surface"
                action_recommendation = "stop_and_restore_missing_status_surface"
                status_surfaces_present = $false
                boundary_matches_expected = $true
                runtime_overclaim_detected = $false
                future_task_claim_detected = $false
                safe_for_future_release_gate = $false
                next_safe_step = "Restore governance/ACTIVE_STATE.md before any future release gate is evaluated."
                blocked_reasons = @("required_status_surface_missing:governance/ACTIVE_STATE.md")
            }
        }
        "status_boundary_drift" {
            return [pscustomobject]@{
                gate_status = "status_gate_blocked_boundary_drift"
                action_recommendation = "stop_and_fix_status_boundary"
                status_surfaces_present = $true
                boundary_matches_expected = $false
                runtime_overclaim_detected = $false
                future_task_claim_detected = $false
                safe_for_future_release_gate = $false
                next_safe_step = "Repair status surfaces so they agree that R18 is active through R18-019 only and R18-020 through R18-028 remain planned only."
                blocked_reasons = @("status_boundary_drift_detected")
            }
        }
        "overclaim_runtime" {
            return [pscustomobject]@{
                gate_status = "status_gate_blocked_runtime_overclaim"
                action_recommendation = "stop_and_remove_runtime_overclaim"
                status_surfaces_present = $true
                boundary_matches_expected = $true
                runtime_overclaim_detected = $true
                future_task_claim_detected = $false
                safe_for_future_release_gate = $false
                next_safe_step = "Remove runtime/execution claims and keep R18-018 to deterministic policy artifacts only."
                blocked_reasons = @("runtime_overclaim_detected")
            }
        }
        "r18_020_premature_claim" {
            return [pscustomobject]@{
                gate_status = "status_gate_blocked_premature_future_claim"
                action_recommendation = "stop_and_remove_future_task_claim"
                status_surfaces_present = $true
                boundary_matches_expected = $false
                runtime_overclaim_detected = $false
                future_task_claim_detected = $true
                safe_for_future_release_gate = $false
                next_safe_step = "Remove any R18-020 or later completion claim; R18-020 through R18-028 remain planned only."
                blocked_reasons = @("r18_020_or_later_completion_claim_detected")
            }
        }
        default {
            throw "Unknown R18 status-doc gate wrapper scenario '$Scenario'."
        }
    }
}

function New-R18StatusDocGateWrapperContract {
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_contract"
        contract_version = "v1"
        contract_id = "r18_018_status_doc_gate_wrapper_contract_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        repository = $script:R18StatusDocWrapperRepository
        branch = $script:R18StatusDocWrapperBranch
        scope = "deterministic_status_doc_gate_wrapper_policy_artifacts_only_not_runtime"
        purpose = "Consolidate status-doc gate inputs, deterministic assessments, evidence refs, and refusal rules into a replayable policy package before any future release action is allowed."
        required_input_fields = $script:R18StatusDocWrapperInputFields
        required_assessment_fields = $script:R18StatusDocWrapperAssessmentFields
        allowed_gate_scenarios = $script:R18StatusDocWrapperScenarios
        allowed_gate_statuses = $script:R18StatusDocWrapperStatuses
        allowed_action_recommendations = $script:R18StatusDocWrapperActions
        required_status_surfaces = Get-R18StatusDocGateWrapperStatusSurfaces
        required_non_claim_checks = Get-R18StatusDocGateWrapperNonClaimChecks
        required_runtime_false_flags = $script:R18StatusDocWrapperRuntimeFlagFields
        status_surface_policy = [ordered]@{
            all_required_surfaces_required_for_current_status_surfaces = $true
            missing_surface_blocks_gate = $true
            wrapper_does_not_repair_status_surfaces = $true
        }
        status_boundary_policy = [ordered]@{
            expected_boundary = New-R18StatusDocGateWrapperExpectedBoundary
            current_status_surfaces_must_match_expected = $true
            status_boundary_drift_blocks_gate = $true
            r18_020_or_later_completion_claims_fail_closed = $true
        }
        non_claim_policy = [ordered]@{
            non_claim_checks_required = $true
            runtime_overclaims_block_gate = $true
            future_task_claims_block_gate = $true
        }
        validation_policy = [ordered]@{
            validation_refs_required = $true
            status_doc_gate_validation_required = $true
            missing_validation_refs_fail_closed = $true
        }
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            missing_evidence_refs_fail_closed = $true
            wrapper_evidence_is_policy_only = $true
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            missing_authority_refs_fail_closed = $true
            authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        }
        ci_boundary_policy = [ordered]@{
            github_actions_workflow_created_allowed = $false
            ci_replay_claim_allowed_without_real_workflow_run_artifact = $false
            ci_replay_performed_by_wrapper = $false
        }
        execution_policy = [ordered]@{
            wrapper_runtime_allowed = $false
            live_status_doc_gate_runtime_allowed = $false
            release_gate_execution_allowed = $false
            stage_commit_push_allowed_by_wrapper = $false
            api_invocation_allowed = $false
            work_order_execution_allowed = $false
            board_runtime_mutation_allowed = $false
        }
        refusal_policy = [ordered]@{
            fail_closed_on_missing_required_field = $true
            blocked_scenarios_must_mark_safe_for_future_release_gate_false = $true
            wrapper_refusals_are_policy_only = $true
        }
        allowed_positive_claims = Get-R18StatusDocGateWrapperPositiveClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
    }
}

function New-R18StatusDocGateAssessmentContract {
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_assessment_contract"
        contract_version = "v1"
        contract_id = "r18_018_status_doc_gate_assessment_contract_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        required_assessment_packet_fields = $script:R18StatusDocWrapperAssessmentFields
        required_runtime_false_flags = $script:R18StatusDocWrapperRuntimeFlagFields
        decision_policy = [ordered]@{
            current_status_surfaces = "pass_policy_only_if_required_surfaces_exist_expected_boundary_matches_no_runtime_overclaim_no_future_claim_and_all_refs_exist"
            missing_active_state = "block_missing_surface"
            status_boundary_drift = "block_boundary_drift"
            overclaim_runtime = "block_runtime_overclaim"
            r18_020_premature_claim = "block_premature_future_claim"
            blocked_scenarios_are_not_safe_for_future_release_gate = $true
        }
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
    }
}

function New-R18StatusDocGateWrapperProfile {
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_profile"
        contract_version = "v1"
        profile_id = "r18_018_status_doc_gate_wrapper_profile_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        profile_status = "seed_profile_only_not_live_status_doc_gate_runtime"
        repository = $script:R18StatusDocWrapperRepository
        branch = $script:R18StatusDocWrapperBranch
        expected_boundary = New-R18StatusDocGateWrapperExpectedBoundary
        allowed_gate_scenarios = $script:R18StatusDocWrapperScenarios
        required_status_surfaces = Get-R18StatusDocGateWrapperStatusSurfaces
        required_non_claim_checks = Get-R18StatusDocGateWrapperNonClaimChecks
        validation_refs = Get-R18StatusDocGateWrapperValidationRefs
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
}

function New-R18StatusDocGateWrapperInput {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    $rule = Get-R18StatusDocGateWrapperRule -Scenario $Scenario
    $statusSurfaces = @(Get-R18StatusDocGateWrapperStatusSurfaces)
    if ($Scenario -eq "missing_active_state") {
        $statusSurfaces = @($statusSurfaces | Where-Object { $_ -ne "governance/ACTIVE_STATE.md" })
    }

    $actualBoundary = Copy-R18StatusDocGateWrapperBoundary
    $claim_signals = @()
    if ($Scenario -eq "status_boundary_drift") {
        $actualBoundary.r18_status = "R18 active through R18-019"
        $actualBoundary.r18_active_through = "R18-019"
        $actualBoundary.planned_from = "R18-020"
        $actualBoundary.summary = "R18 active through R18-019; R18-020 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
        $claim_signals += "status_boundary_drift"
    }
    elseif ($Scenario -eq "overclaim_runtime") {
        $claim_signals += "status_doc_gate_wrapper_runtime_implemented_claim_seen"
        $claim_signals += "release_gate_execution_claim_seen"
    }
    elseif ($Scenario -eq "r18_020_premature_claim") {
        $actualBoundary.r18_status = "R18 active through R18-019"
        $actualBoundary.r18_active_through = "R18-019"
        $actualBoundary.planned_from = "R18-020"
        $actualBoundary.summary = "R18 active through R18-019; R18-020 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"
        $claim_signals += "r18_020_completed_claim_seen"
    }

    return [ordered]@{
        artifact_type = "r18_status_doc_gate_input"
        contract_version = "v1"
        input_id = "r18_018_status_doc_gate_input_$Scenario"
        input_name = $Scenario
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        input_status = "seed_status_gate_input_only_not_live_gate"
        gate_scenario = $Scenario
        status_surface_refs = $statusSurfaces
        expected_boundary = New-R18StatusDocGateWrapperExpectedBoundary
        actual_boundary = $actualBoundary
        r18_active_through = "R18-019"
        planned_from = "R18-020"
        planned_through = "R18-028"
        non_claim_checks = Get-R18StatusDocGateWrapperNonClaimChecks
        validation_refs = Get-R18StatusDocGateWrapperValidationRefs
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        claim_signals = $claim_signals
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
}

function New-R18StatusDocGateWrapperAssessment {
    param([Parameter(Mandatory = $true)][string]$Scenario)

    $rule = Get-R18StatusDocGateWrapperRule -Scenario $Scenario
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_assessment"
        contract_version = "v1"
        assessment_id = "r18_018_status_doc_gate_assessment_$Scenario"
        assessment_name = $Scenario
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        assessment_status = "deterministic_status_doc_gate_assessment_only_not_live_gate"
        source_input_ref = "state/governance/r18_status_doc_gate_inputs/$Scenario.input.json"
        gate_scenario = $Scenario
        gate_status = $rule.gate_status
        action_recommendation = $rule.action_recommendation
        status_surfaces_present = $rule.status_surfaces_present
        boundary_matches_expected = $rule.boundary_matches_expected
        runtime_overclaim_detected = $rule.runtime_overclaim_detected
        future_task_claim_detected = $rule.future_task_claim_detected
        non_claims_preserved = $true
        validation_refs_present = $true
        evidence_refs_present = $true
        authority_refs_present = $true
        safe_for_future_release_gate = $rule.safe_for_future_release_gate
        blocked_reasons = $rule.blocked_reasons
        next_safe_step = $rule.next_safe_step
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
}

function New-R18StatusDocGateWrapperResults {
    $assessmentResults = @()
    foreach ($scenario in $script:R18StatusDocWrapperScenarios) {
        $assessment = New-R18StatusDocGateWrapperAssessment -Scenario $scenario
        $assessmentResults += [ordered]@{
            gate_scenario = $scenario
            source_input_ref = $assessment.source_input_ref
            gate_status = $assessment.gate_status
            action_recommendation = $assessment.action_recommendation
            safe_for_future_release_gate = $assessment.safe_for_future_release_gate
            blocked_reasons = $assessment.blocked_reasons
            runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        }
    }

    return [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_results"
        contract_version = "v1"
        results_id = "r18_018_status_doc_gate_wrapper_results_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        result_status = "deterministic_policy_results_only_not_live_status_doc_gate_runtime"
        input_count = $script:R18StatusDocWrapperScenarios.Count
        assessment_count = $script:R18StatusDocWrapperScenarios.Count
        assessment_results = $assessmentResults
        positive_claims = @(
            "r18_status_doc_gate_inputs_created",
            "r18_status_doc_gate_assessments_created",
            "r18_status_doc_gate_wrapper_results_created"
        )
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
}

function New-R18StatusDocGateWrapperCheckReport {
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_check_report"
        contract_version = "v1"
        check_report_id = "r18_018_status_doc_gate_wrapper_check_report_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        aggregate_verdict = $script:R18StatusDocWrapperVerdict
        report_status = "validator_report_seed_only_not_live_status_doc_gate_runtime"
        input_count = $script:R18StatusDocWrapperScenarios.Count
        assessment_count = $script:R18StatusDocWrapperScenarios.Count
        status_boundary = $script:R18StatusDocWrapperBoundary
        checks = @(
            [ordered]@{ check_id = "contract_presence"; status = "passed" },
            [ordered]@{ check_id = "five_status_doc_gate_inputs"; status = "passed"; count = $script:R18StatusDocWrapperScenarios.Count },
            [ordered]@{ check_id = "five_status_doc_gate_assessments"; status = "passed"; count = $script:R18StatusDocWrapperScenarios.Count },
            [ordered]@{ check_id = "status_surface_refs"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = $script:R18StatusDocWrapperBoundary },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "non_claim_enforcement"; status = "passed" }
        )
        positive_claims = @(
            "r18_status_doc_gate_wrapper_validator_created",
            "r18_status_doc_gate_wrapper_fixtures_created"
        )
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
}

function New-R18StatusDocGateWrapperSnapshot {
    return [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_operator_surface_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_018_status_doc_gate_wrapper_snapshot_v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        snapshot_status = "read_only_operator_surface_snapshot_only_not_live_runtime"
        r18_status = "active_through_r18_019_only"
        planned_from = "R18-020"
        planned_through = "R18-028"
        gate_summary = [ordered]@{
            current_status_surfaces = "status_gate_passed_policy_only"
            missing_active_state = "status_gate_blocked_missing_surface"
            status_boundary_drift = "status_gate_blocked_boundary_drift"
            overclaim_runtime = "status_gate_blocked_runtime_overclaim"
            r18_020_premature_claim = "status_gate_blocked_premature_future_claim"
        }
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
    }
}

function New-R18StatusDocGateWrapperFixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string[]]$ExpectedFailureFragments
    )

    $fixture = [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_invalid_fixture"
        contract_version = "v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        target = $Target
        operation = $Operation
        path = $Path
        expected_failure_fragments = $ExpectedFailureFragments
    }

    if ($Operation -eq "set") {
        $fixture["value"] = $Value
    }

    return [ordered]@{
        file = $File
        fixture = $fixture
    }
}

function New-R18StatusDocGateWrapperFixtures {
    $fixtures = @(
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_status_surface_ref.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "status_surface_refs" -ExpectedFailureFragments @("status_surface_refs is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_expected_boundary.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "expected_boundary" -ExpectedFailureFragments @("expected_boundary is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_actual_boundary.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "actual_boundary" -ExpectedFailureFragments @("actual_boundary is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_non_claim_checks.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "non_claim_checks" -ExpectedFailureFragments @("non_claim_checks is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_validation_refs.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "validation_refs" -ExpectedFailureFragments @("validation_refs is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_evidence_refs.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "evidence_refs" -ExpectedFailureFragments @("evidence_refs is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_missing_authority_refs.json" -Target "input:current_status_surfaces" -Operation "remove" -Path "authority_refs" -ExpectedFailureFragments @("authority_refs is missing")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_status_boundary_drift_marked_safe.json" -Target "assessment:status_boundary_drift" -Operation "set" -Path "safe_for_future_release_gate" -Value $true -ExpectedFailureFragments @("status_boundary_drift must not be safe")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_runtime_overclaim_marked_safe.json" -Target "assessment:overclaim_runtime" -Operation "set" -Path "safe_for_future_release_gate" -Value $true -ExpectedFailureFragments @("overclaim_runtime must not be safe")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_r18_020_claim_marked_safe.json" -Target "assessment:r18_020_premature_claim" -Operation "set" -Path "safe_for_future_release_gate" -Value $true -ExpectedFailureFragments @("r18_020_premature_claim must not be safe")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_wrapper_executes_release_gate_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.release_gate_executed" -Value $true -ExpectedFailureFragments @("runtime flag 'release_gate_executed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_stage_commit_push_performed_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.stage_performed_by_gate" -Value $true -ExpectedFailureFragments @("runtime flag 'stage_performed_by_gate' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_ci_replay_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.ci_replay_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'ci_replay_performed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_main_merge_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.main_merge_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'main_merge_claimed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_milestone_closeout_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.milestone_closeout_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'milestone_closeout_claimed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_external_audit_acceptance_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.external_audit_acceptance_claimed" -Value $true -ExpectedFailureFragments @("runtime flag 'external_audit_acceptance_claimed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_recovery_action_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'recovery_action_performed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_api_invocation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -ExpectedFailureFragments @("runtime flag 'codex_api_invoked' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'automatic_new_thread_creation_performed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_work_order_execution_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'work_order_execution_performed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_a2a_message_sent_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -ExpectedFailureFragments @("runtime flag 'a2a_message_sent' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_board_runtime_mutation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -ExpectedFailureFragments @("runtime flag 'board_runtime_mutation_performed' must be false")),
        (New-R18StatusDocGateWrapperFixture -File "invalid_r18_020_completion_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.r18_020_completed" -Value $true -ExpectedFailureFragments @("runtime flag 'r18_020_completed' must be false"))
    )

    return $fixtures
}

function New-R18StatusDocGateWrapperProofArtifacts {
    $evidenceIndex = [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_evidence_index"
        contract_version = "v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        source_milestone = $script:R18StatusDocWrapperSourceMilestone
        evidence_status = "policy_artifact_evidence_index_only_not_runtime"
        evidence_refs = Get-R18StatusDocGateWrapperEvidenceRefs
        authority_refs = Get-R18StatusDocGateWrapperAuthorityRefs
        validation_refs = Get-R18StatusDocGateWrapperValidationRefs
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }

    $proofReview = @(
        "# R18-018 Status-Doc Gate Wrapper Proof Review",
        "",
        "R18-018 created a deterministic status-doc gate automation wrapper foundation only.",
        "",
        "The wrapper package consolidates current status-surface refs, expected milestone boundary, non-claim checks, validation refs, evidence refs, authority refs, five scenario inputs, and five deterministic assessments.",
        "",
        "Current status truth after this task: R18 is active through R18-019 only, R18-020 through R18-028 remain planned only, R17 remains closed with caveats through R17-028 only, and main is not merged.",
        "",
        "Non-claims preserved: no live wrapper runtime, no live status-doc gate runtime, no release gate execution, no stage/commit/push by the wrapper, no CI replay, no GitHub Actions workflow creation or run claim, no main merge, no milestone closeout, no external audit acceptance, no recovery action, no Codex/OpenAI API invocation, no automatic new-thread creation, no work-order execution, no board/card runtime mutation, no A2A messages, no live agents, no live skills, no product runtime, no no-manual-prompt-transfer success, and no solved Codex compaction or reliability.",
        "",
        "The current_status_surfaces scenario is policy-only passable. The missing_active_state, status_boundary_drift, overclaim_runtime, and r18_020_premature_claim scenarios are deterministic blocked assessments."
    )

    $validationManifest = @(
        "# R18-018 Validation Manifest",
        "",
        "Expected status truth: R18 active through R18-019 only; R18-020 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_status_doc_gate_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_status_doc_gate_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_status_doc_gate_wrapper.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1",
        "- git diff --check",
        "",
        "Validation is policy validation only; it is not release runtime execution."
    )

    return [pscustomobject]@{
        EvidenceIndex = $evidenceIndex
        ProofReview = $proofReview
        ValidationManifest = $validationManifest
    }
}

function New-R18StatusDocGateWrapperArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot))

    $paths = Get-R18StatusDocGateWrapperPaths -RepositoryRoot $RepositoryRoot
    Write-R18StatusDocGateWrapperJson -Path $paths.WrapperContract -Value (New-R18StatusDocGateWrapperContract)
    Write-R18StatusDocGateWrapperJson -Path $paths.AssessmentContract -Value (New-R18StatusDocGateAssessmentContract)
    Write-R18StatusDocGateWrapperJson -Path $paths.Profile -Value (New-R18StatusDocGateWrapperProfile)

    foreach ($scenario in $script:R18StatusDocWrapperScenarios) {
        Write-R18StatusDocGateWrapperJson -Path (Join-Path $paths.InputRoot "$scenario.input.json") -Value (New-R18StatusDocGateWrapperInput -Scenario $scenario)
        Write-R18StatusDocGateWrapperJson -Path (Join-Path $paths.AssessmentRoot "$scenario.assessment.json") -Value (New-R18StatusDocGateWrapperAssessment -Scenario $scenario)
    }

    Write-R18StatusDocGateWrapperJson -Path $paths.Results -Value (New-R18StatusDocGateWrapperResults)
    Write-R18StatusDocGateWrapperJson -Path $paths.CheckReport -Value (New-R18StatusDocGateWrapperCheckReport)
    Write-R18StatusDocGateWrapperJson -Path $paths.UiSnapshot -Value (New-R18StatusDocGateWrapperSnapshot)

    $fixtures = New-R18StatusDocGateWrapperFixtures
    $fixtureFiles = @()
    foreach ($entry in $fixtures) {
        $fixtureFiles += $entry.file
        Write-R18StatusDocGateWrapperJson -Path (Join-Path $paths.FixtureRoot $entry.file) -Value $entry.fixture
    }
    $manifest = [ordered]@{
        artifact_type = "r18_status_doc_gate_wrapper_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18StatusDocWrapperSourceTask
        fixture_count = $fixtureFiles.Count
        invalid_fixture_files = $fixtureFiles
        runtime_flags = New-R18StatusDocGateWrapperRuntimeFlags
        non_claims = Get-R18StatusDocGateWrapperNonClaims
        rejected_claims = Get-R18StatusDocGateWrapperRejectedClaims
    }
    Write-R18StatusDocGateWrapperJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $manifest

    $proof = New-R18StatusDocGateWrapperProofArtifacts
    Write-R18StatusDocGateWrapperJson -Path $paths.EvidenceIndex -Value $proof.EvidenceIndex
    Write-R18StatusDocGateWrapperText -Path $paths.ProofReview -Value $proof.ProofReview
    Write-R18StatusDocGateWrapperText -Path $paths.ValidationManifest -Value $proof.ValidationManifest

    return [pscustomobject]@{
        AggregateVerdict = $script:R18StatusDocWrapperVerdict
        InputCount = $script:R18StatusDocWrapperScenarios.Count
        AssessmentCount = $script:R18StatusDocWrapperScenarios.Count
        FixtureCount = $fixtureFiles.Count
    }
}

function Assert-R18StatusDocGateWrapperCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18StatusDocGateWrapperHasFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18StatusDocGateWrapperCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context $field is missing."
    }
}

function Assert-R18StatusDocGateWrapperRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flagName in $script:R18StatusDocWrapperRuntimeFlagFields) {
        Assert-R18StatusDocGateWrapperCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $flagName) -Message "$Context missing runtime flag '$flagName'."
        Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$RuntimeFlags.$flagName -eq $false) -Message "$Context runtime flag '$flagName' must be false."
    }
}

function Assert-R18StatusDocGateWrapperCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18StatusDocGateWrapperCondition -Condition ($Artifact.contract_version -eq "v1") -Message "$Context contract_version must be v1."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Artifact.source_task -eq $script:R18StatusDocWrapperSourceTask) -Message "$Context source_task must be R18-018."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Artifact.source_milestone -eq $script:R18StatusDocWrapperSourceMilestone) -Message "$Context source_milestone is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Artifact.PSObject.Properties.Name -contains "runtime_flags") -Message "$Context runtime_flags is missing."
    Assert-R18StatusDocGateWrapperRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    if ($Artifact.PSObject.Properties.Name -contains "non_claims") {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Artifact.non_claims).Count -gt 0) -Message "$Context non_claims is missing."
    }
    if ($Artifact.PSObject.Properties.Name -contains "rejected_claims") {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Artifact.rejected_claims).Count -gt 0) -Message "$Context rejected_claims is missing."
    }
}

function Test-R18StatusDocGateWrapperBoundaryMatch {
    param(
        [Parameter(Mandatory = $true)][object]$Expected,
        [Parameter(Mandatory = $true)][object]$Actual
    )

    foreach ($field in @("r17_status", "r18_status", "r18_active_through", "planned_from", "planned_through", "main_merged", "summary")) {
        if ($Expected.PSObject.Properties.Name -notcontains $field -or $Actual.PSObject.Properties.Name -notcontains $field) {
            return $false
        }
        if ([string]$Expected.$field -ne [string]$Actual.$field) {
            return $false
        }
    }

    return $true
}

function Assert-R18StatusDocGateWrapperContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $fields = @(
        "artifact_type", "contract_version", "contract_id", "source_task", "source_milestone",
        "repository", "branch", "scope", "purpose", "required_input_fields",
        "required_assessment_fields", "allowed_gate_scenarios", "allowed_gate_statuses",
        "allowed_action_recommendations", "required_status_surfaces", "required_non_claim_checks",
        "required_runtime_false_flags", "status_surface_policy", "status_boundary_policy",
        "non_claim_policy", "validation_policy", "evidence_policy", "authority_policy",
        "ci_boundary_policy", "execution_policy", "refusal_policy", "allowed_positive_claims",
        "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags"
    )
    Assert-R18StatusDocGateWrapperHasFields -Object $Contract -Fields $fields -Context "R18 status-doc wrapper contract"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Contract -Context "R18 status-doc wrapper contract"
    Assert-R18StatusDocGateWrapperCondition -Condition ($Contract.artifact_type -eq "r18_status_doc_gate_wrapper_contract") -Message "Wrapper contract artifact_type is invalid."
    foreach ($field in $script:R18StatusDocWrapperInputFields) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Contract.required_input_fields) -contains $field) -Message "Wrapper contract missing required input field '$field'."
    }
    foreach ($field in $script:R18StatusDocWrapperAssessmentFields) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Contract.required_assessment_fields) -contains $field) -Message "Wrapper contract missing required assessment field '$field'."
    }
    foreach ($surface in Get-R18StatusDocGateWrapperStatusSurfaces) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Contract.required_status_surfaces) -contains $surface) -Message "Wrapper contract missing required status surface '$surface'."
    }
    foreach ($claimCheck in Get-R18StatusDocGateWrapperNonClaimChecks) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Contract.required_non_claim_checks) -contains $claimCheck) -Message "Wrapper contract missing non-claim check '$claimCheck'."
    }
}

function Assert-R18StatusDocGateAssessmentContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $fields = @(
        "artifact_type", "contract_version", "contract_id", "source_task", "source_milestone",
        "required_assessment_packet_fields", "required_runtime_false_flags", "decision_policy",
        "non_claims", "rejected_claims", "runtime_flags"
    )
    Assert-R18StatusDocGateWrapperHasFields -Object $Contract -Fields $fields -Context "R18 status-doc assessment contract"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Contract -Context "R18 status-doc assessment contract"
    Assert-R18StatusDocGateWrapperCondition -Condition ($Contract.artifact_type -eq "r18_status_doc_gate_assessment_contract") -Message "Assessment contract artifact_type is invalid."
    foreach ($field in $script:R18StatusDocWrapperAssessmentFields) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Contract.required_assessment_packet_fields) -contains $field) -Message "Assessment contract missing packet field '$field'."
    }
}

function Assert-R18StatusDocGateInput {
    param([Parameter(Mandatory = $true)][object]$GateInput)

    Assert-R18StatusDocGateWrapperHasFields -Object $GateInput -Fields $script:R18StatusDocWrapperInputFields -Context "R18 status-doc gate input"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $GateInput -Context "R18 status-doc gate input '$($GateInput.gate_scenario)'"
    Assert-R18StatusDocGateWrapperCondition -Condition ($GateInput.artifact_type -eq "r18_status_doc_gate_input") -Message "Input artifact_type is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($GateInput.input_status -eq "seed_status_gate_input_only_not_live_gate") -Message "Input status is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($script:R18StatusDocWrapperScenarios -contains [string]$GateInput.gate_scenario) -Message "Unknown gate scenario '$($GateInput.gate_scenario)'."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.status_surface_refs).Count -gt 0) -Message "status_surface_refs is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition ($GateInput.PSObject.Properties.Name -contains "expected_boundary") -Message "expected_boundary is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition ($GateInput.PSObject.Properties.Name -contains "actual_boundary") -Message "actual_boundary is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition ([string]$GateInput.r18_active_through -eq "R18-019") -Message "R18 active through is beyond R18-019."
    Assert-R18StatusDocGateWrapperCondition -Condition ([string]$GateInput.planned_from -eq "R18-020" -and [string]$GateInput.planned_through -eq "R18-028") -Message "R18-020 through R18-028 must remain planned only."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.non_claim_checks).Count -gt 0) -Message "non_claim_checks is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.validation_refs).Count -gt 0) -Message "validation_refs is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.evidence_refs).Count -gt 0) -Message "evidence_refs is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.authority_refs).Count -gt 0) -Message "authority_refs is missing."
    foreach ($claimCheck in Get-R18StatusDocGateWrapperNonClaimChecks) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($GateInput.non_claim_checks) -contains $claimCheck) -Message "Missing non-claim check '$claimCheck'."
    }

    $requiredSurfaces = @(Get-R18StatusDocGateWrapperStatusSurfaces)
    $allSurfacesPresent = $true
    foreach ($surface in $requiredSurfaces) {
        if (@($GateInput.status_surface_refs) -notcontains $surface) {
            $allSurfacesPresent = $false
        }
    }
    $boundaryMatches = Test-R18StatusDocGateWrapperBoundaryMatch -Expected $GateInput.expected_boundary -Actual $GateInput.actual_boundary
    $signals = if ($GateInput.PSObject.Properties.Name -contains "claim_signals") { @($GateInput.claim_signals) } else { @() }

    switch ([string]$GateInput.gate_scenario) {
        "current_status_surfaces" {
            Assert-R18StatusDocGateWrapperCondition -Condition $allSurfacesPresent -Message "current_status_surfaces is missing a required status surface."
            Assert-R18StatusDocGateWrapperCondition -Condition $boundaryMatches -Message "current_status_surfaces actual boundary does not match expected boundary."
            Assert-R18StatusDocGateWrapperCondition -Condition (@($signals).Count -eq 0) -Message "current_status_surfaces must not contain overclaim signals."
        }
        "missing_active_state" {
            Assert-R18StatusDocGateWrapperCondition -Condition (-not $allSurfacesPresent -and @($GateInput.status_surface_refs) -notcontains "governance/ACTIVE_STATE.md") -Message "missing_active_state must omit governance/ACTIVE_STATE.md."
        }
        "status_boundary_drift" {
            Assert-R18StatusDocGateWrapperCondition -Condition (-not $boundaryMatches) -Message "status_boundary_drift must include a mismatched actual boundary."
        }
        "overclaim_runtime" {
            Assert-R18StatusDocGateWrapperCondition -Condition ($signals -contains "status_doc_gate_wrapper_runtime_implemented_claim_seen") -Message "overclaim_runtime must include a runtime overclaim signal."
        }
        "r18_020_premature_claim" {
            Assert-R18StatusDocGateWrapperCondition -Condition ($signals -contains "r18_020_completed_claim_seen") -Message "r18_020_premature_claim must include an R18-020 claim signal."
        }
    }
}

function Assert-R18StatusDocGateAssessment {
    param([Parameter(Mandatory = $true)][object]$Assessment)

    Assert-R18StatusDocGateWrapperHasFields -Object $Assessment -Fields $script:R18StatusDocWrapperAssessmentFields -Context "R18 status-doc gate assessment"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Assessment -Context "R18 status-doc gate assessment '$($Assessment.gate_scenario)'"
    Assert-R18StatusDocGateWrapperCondition -Condition ($Assessment.artifact_type -eq "r18_status_doc_gate_assessment") -Message "Assessment artifact_type is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($script:R18StatusDocWrapperScenarios -contains [string]$Assessment.gate_scenario) -Message "Unknown assessment gate scenario '$($Assessment.gate_scenario)'."
    Assert-R18StatusDocGateWrapperCondition -Condition ($script:R18StatusDocWrapperStatuses -contains [string]$Assessment.gate_status) -Message "Unknown gate status '$($Assessment.gate_status)'."
    Assert-R18StatusDocGateWrapperCondition -Condition ($script:R18StatusDocWrapperActions -contains [string]$Assessment.action_recommendation) -Message "Unknown action recommendation '$($Assessment.action_recommendation)'."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($Assessment.evidence_refs).Count -gt 0) -Message "assessment evidence_refs is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($Assessment.authority_refs).Count -gt 0) -Message "assessment authority_refs is missing."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.non_claims_preserved) -Message "assessment non_claims_preserved must be true."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.validation_refs_present) -Message "assessment validation_refs_present must be true."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.evidence_refs_present) -Message "assessment evidence_refs_present must be true."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.authority_refs_present) -Message "assessment authority_refs_present must be true."

    $rule = Get-R18StatusDocGateWrapperRule -Scenario ([string]$Assessment.gate_scenario)
    Assert-R18StatusDocGateWrapperCondition -Condition ($Assessment.gate_status -eq $rule.gate_status) -Message "Assessment gate_status does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Assessment.action_recommendation -eq $rule.action_recommendation) -Message "Assessment action_recommendation does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.status_surfaces_present -eq [bool]$rule.status_surfaces_present) -Message "Assessment status_surfaces_present does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.boundary_matches_expected -eq [bool]$rule.boundary_matches_expected) -Message "Assessment boundary_matches_expected does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.runtime_overclaim_detected -eq [bool]$rule.runtime_overclaim_detected) -Message "Assessment runtime_overclaim_detected does not match deterministic rule for $($Assessment.gate_scenario)."
    Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.future_task_claim_detected -eq [bool]$rule.future_task_claim_detected) -Message "Assessment future_task_claim_detected does not match deterministic rule for $($Assessment.gate_scenario)."
    if ([bool]$Assessment.safe_for_future_release_gate -ne [bool]$rule.safe_for_future_release_gate) {
        if ([bool]$rule.safe_for_future_release_gate) {
            throw "$($Assessment.gate_scenario) must be safe for a future release gate after revalidation."
        }
        throw "$($Assessment.gate_scenario) must not be safe for a future release gate."
    }

    if ([string]$Assessment.gate_scenario -eq "current_status_surfaces") {
        Assert-R18StatusDocGateWrapperCondition -Condition ([bool]$Assessment.safe_for_future_release_gate) -Message "current_status_surfaces must be policy-only safe after revalidation."
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Assessment.blocked_reasons).Count -eq 0) -Message "current_status_surfaces must not have blocked reasons."
    }
    else {
        Assert-R18StatusDocGateWrapperCondition -Condition (-not [bool]$Assessment.safe_for_future_release_gate) -Message "$($Assessment.gate_scenario) must not be safe for a future release gate."
        Assert-R18StatusDocGateWrapperCondition -Condition (@($Assessment.blocked_reasons).Count -gt 0) -Message "$($Assessment.gate_scenario) must record blocked reasons."
    }
}

function Get-R18StatusDocGateWrapperTaskStatusMap {
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

function Test-R18StatusDocGateWrapperStatusTruth {
    param([string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18StatusDocGateWrapperPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-019 only",
            "R18-020 through R18-028 planned only",
            "R18-018 created status-doc gate automation wrapper foundation only",
            "Status-doc gate wrapper artifacts are deterministic policy artifacts only",
            "R18-019 created evidence package automation wrapper foundation only",
            "Evidence package wrapper artifacts are deterministic policy/manifest artifacts only",
            "Wrapper runtime was not implemented",
            "Live status-doc gate runtime was not executed",
            "Release gate was not executed",
            "No stage/commit/push was performed by the wrapper",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Main was not merged",
            "Milestone closeout was not claimed",
            "External audit acceptance was not claimed",
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
            "No no-manual-prompt-transfer success is claimed"
        )) {
        Assert-R18StatusDocGateWrapperCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-018 truth: $required"
    }

    $authorityStatuses = Get-R18StatusDocGateWrapperTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18StatusDocGateWrapperTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18StatusDocGateWrapperCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 19) {
            Assert-R18StatusDocGateWrapperCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-019."
        }
        else {
            Assert-R18StatusDocGateWrapperCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-019."
        }
    }

    if ($combinedText -match 'R18 active through R18-02[0-8]') {
        throw "Status surface claims R18 beyond R18-019."
    }
    if ($combinedText -match '(?i)R18-02[0-8].{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-020 or later completion."
    }
}

function Test-R18StatusDocGateWrapperSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$WrapperContract,
        [Parameter(Mandatory = $true)][object]$AssessmentContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object[]]$Assessments,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot)
    )

    $InputPackets = @()
    foreach ($packet in $Inputs) {
        if ($packet -is [System.Array]) {
            foreach ($nestedPacket in $packet) {
                $InputPackets += $nestedPacket
            }
        }
        else {
            $InputPackets += $packet
        }
    }
    $AssessmentPackets = @()
    foreach ($packet in $Assessments) {
        if ($packet -is [System.Array]) {
            foreach ($nestedPacket in $packet) {
                $AssessmentPackets += $nestedPacket
            }
        }
        else {
            $AssessmentPackets += $packet
        }
    }

    Assert-R18StatusDocGateWrapperContract -Contract $WrapperContract
    Assert-R18StatusDocGateAssessmentContract -Contract $AssessmentContract
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Profile -Context "R18 status-doc gate wrapper profile"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Results -Context "R18 status-doc gate wrapper results"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Report -Context "R18 status-doc gate wrapper check report"
    Assert-R18StatusDocGateWrapperCommonArtifact -Artifact $Snapshot -Context "R18 status-doc gate wrapper snapshot"
    Assert-R18StatusDocGateWrapperCondition -Condition (@($InputPackets).Count -eq 5) -Message "R18 status-doc gate wrapper must have five inputs."
    Assert-R18StatusDocGateWrapperCondition -Condition (@($AssessmentPackets).Count -eq 5) -Message "R18 status-doc gate wrapper must have five assessments."

    foreach ($gateInput in @($InputPackets)) {
        Assert-R18StatusDocGateInput -GateInput $gateInput
    }
    foreach ($assessment in @($AssessmentPackets)) {
        Assert-R18StatusDocGateAssessment -Assessment $assessment
    }

    foreach ($scenario in $script:R18StatusDocWrapperScenarios) {
        Assert-R18StatusDocGateWrapperCondition -Condition (@($InputPackets | Where-Object { $_.gate_scenario -eq $scenario }).Count -eq 1) -Message "Missing input scenario '$scenario'."
        Assert-R18StatusDocGateWrapperCondition -Condition (@($AssessmentPackets | Where-Object { $_.gate_scenario -eq $scenario }).Count -eq 1) -Message "Missing assessment scenario '$scenario'."
        $assessment = @($AssessmentPackets | Where-Object { $_.gate_scenario -eq $scenario })[0]
        Assert-R18StatusDocGateWrapperCondition -Condition ($assessment.source_input_ref -eq "state/governance/r18_status_doc_gate_inputs/$scenario.input.json") -Message "Assessment source ref does not match scenario '$scenario'."
    }

    Assert-R18StatusDocGateWrapperCondition -Condition ($Results.artifact_type -eq "r18_status_doc_gate_wrapper_results") -Message "Results artifact_type is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ([int]$Results.input_count -eq 5 -and [int]$Results.assessment_count -eq 5) -Message "Results counts are invalid."
    foreach ($resultEntry in @($Results.assessment_results)) {
        Assert-R18StatusDocGateWrapperRuntimeFlags -RuntimeFlags $resultEntry.runtime_flags -Context "R18 status-doc gate wrapper result entry '$($resultEntry.gate_scenario)'"
    }
    Assert-R18StatusDocGateWrapperCondition -Condition ($Report.artifact_type -eq "r18_status_doc_gate_wrapper_check_report") -Message "Check report artifact_type is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Report.aggregate_verdict -eq $script:R18StatusDocWrapperVerdict) -Message "Check report aggregate verdict is invalid."
    Assert-R18StatusDocGateWrapperCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_019_only") -Message "Snapshot must record active_through_r18_019_only."

    Test-R18StatusDocGateWrapperStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        InputCount = @($InputPackets).Count
        AssessmentCount = @($AssessmentPackets).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18StatusDocGateWrapperSet {
    param([string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot))

    $inputs = @()
    $assessments = @()
    foreach ($scenario in $script:R18StatusDocWrapperScenarios) {
        $inputs += Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_status_doc_gate_inputs/$scenario.input.json"
        $assessments += Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_status_doc_gate_assessments/$scenario.assessment.json"
    }

    return [pscustomobject]@{
        WrapperContract = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "contracts/governance/r18_status_doc_gate_wrapper.contract.json"
        AssessmentContract = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "contracts/governance/r18_status_doc_gate_assessment.contract.json"
        Profile = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_status_doc_gate_wrapper_profile.json"
        Inputs = $inputs
        Assessments = $assessments
        Results = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_status_doc_gate_wrapper_results.json"
        Report = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/governance/r18_status_doc_gate_wrapper_check_report.json"
        Snapshot = Read-R18StatusDocGateWrapperJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_status_doc_gate_wrapper_snapshot.json"
        Paths = Get-R18StatusDocGateWrapperPaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18StatusDocGateWrapper {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18StatusDocGateWrapperRepositoryRoot))

    $set = Get-R18StatusDocGateWrapperSet -RepositoryRoot $RepositoryRoot
    return Test-R18StatusDocGateWrapperSet `
        -WrapperContract $set.WrapperContract `
        -AssessmentContract $set.AssessmentContract `
        -Profile $set.Profile `
        -Inputs $set.Inputs `
        -Assessments $set.Assessments `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18StatusDocGateWrapperObjectPathValue {
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

function Remove-R18StatusDocGateWrapperObjectPathValue {
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

function Invoke-R18StatusDocGateWrapperMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18StatusDocGateWrapperObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18StatusDocGateWrapperObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 status-doc gate wrapper mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18StatusDocGateWrapperPaths, `
    Get-R18StatusDocGateWrapperRuntimeFlagNames, `
    New-R18StatusDocGateWrapperRuntimeFlags, `
    New-R18StatusDocGateWrapperArtifacts, `
    Test-R18StatusDocGateWrapper, `
    Test-R18StatusDocGateWrapperSet, `
    Test-R18StatusDocGateWrapperStatusTruth, `
    Get-R18StatusDocGateWrapperSet, `
    Copy-R18StatusDocGateWrapperObject, `
    Invoke-R18StatusDocGateWrapperMutation
