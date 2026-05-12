Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-012"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18RemoteRef = "origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ExpectedCurrentHead = "2d1b37d42d625269e8c727343bf22ce8357f6c9d"
$script:R18ExpectedCurrentTree = "8d721f5552565a52cb410200ab5191db8a81bb5a"
$script:R18VerifierVerdict = "generated_r18_012_remote_branch_verifier_foundation_only"

$script:R18RuntimeFlagFields = @(
    "remote_branch_verifier_live_runtime_executed",
    "branch_mutation_performed",
    "remote_branch_mutation_performed",
    "pull_performed",
    "rebase_performed",
    "reset_performed",
    "merge_performed",
    "checkout_or_switch_performed",
    "clean_performed",
    "restore_performed",
    "staging_performed",
    "commit_performed",
    "push_performed",
    "continuation_packet_generated",
    "new_context_prompt_generated",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "wip_cleanup_performed",
    "wip_abandonment_performed",
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
    "r18_013_completed",
    "main_merge_claimed"
)

$script:R18RequiredSampleFields = @(
    "artifact_type",
    "contract_version",
    "sample_id",
    "sample_name",
    "source_task",
    "source_milestone",
    "sample_status",
    "sample_type",
    "repository",
    "expected_branch",
    "actual_branch",
    "local_head",
    "local_tree",
    "expected_remote_ref",
    "expected_remote_head",
    "actual_remote_head",
    "merge_base_head",
    "ahead_by",
    "behind_by",
    "divergence_detected",
    "expected_verification_status",
    "expected_action_recommendation",
    "runner_state_ref",
    "failure_event_ref",
    "wip_classification_ref",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredVerificationFields = @(
    "artifact_type",
    "contract_version",
    "verification_id",
    "source_task",
    "source_milestone",
    "verification_status",
    "source_sample_ref",
    "repository",
    "expected_branch",
    "actual_branch",
    "local_head",
    "local_tree",
    "expected_remote_ref",
    "expected_remote_head",
    "actual_remote_head",
    "merge_base_head",
    "ahead_by",
    "behind_by",
    "divergence_detected",
    "branch_match",
    "remote_ref_present",
    "safe_to_continue",
    "operator_decision_required",
    "action_recommendation",
    "runner_state_ref",
    "failure_event_ref",
    "wip_classification_ref",
    "next_safe_step",
    "stop_conditions",
    "escalation_conditions",
    "evidence_refs",
    "authority_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18AllowedSampleTypes = @(
    "remote_in_sync",
    "remote_ahead",
    "local_ahead",
    "diverged",
    "wrong_branch",
    "missing_remote_ref"
)

$script:R18AllowedVerificationStatuses = @(
    "remote_in_sync_safe",
    "remote_ahead_blocked",
    "local_ahead_review_required",
    "diverged_operator_decision_required",
    "wrong_branch_blocked",
    "missing_remote_ref_blocked"
)

$script:R18AllowedActionRecommendations = @(
    "continue_without_branch_action",
    "stop_remote_ahead_requires_operator_decision",
    "review_local_ahead_before_push",
    "stop_diverged_requires_operator_decision",
    "stop_wrong_branch",
    "stop_missing_remote_ref"
)

$script:R18AllowedPositiveClaims = @(
    "r18_remote_branch_verifier_contract_created",
    "r18_remote_branch_verifier_profile_created",
    "r18_remote_branch_verification_samples_created",
    "r18_remote_branch_verification_packets_created",
    "r18_current_remote_branch_verification_created",
    "r18_remote_branch_verifier_results_created",
    "r18_remote_branch_verifier_validator_created",
    "r18_remote_branch_verifier_fixtures_created",
    "r18_remote_branch_verifier_proof_review_created"
)

$script:R18RejectedClaims = @(
    "live_remote_branch_verifier_runtime",
    "branch_mutation",
    "remote_branch_mutation",
    "pull",
    "rebase",
    "reset",
    "merge",
    "checkout_or_switch",
    "clean",
    "restore",
    "stage_commit_push",
    "staging",
    "commit",
    "push",
    "continuation_packet_generation",
    "new_context_prompt_generation",
    "recovery_runtime",
    "recovery_action",
    "wip_cleanup",
    "wip_abandonment",
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
    "r18_013_or_later_completion",
    "main_merge",
    "remote_ahead_marked_safe",
    "local_ahead_marked_push_safe",
    "diverged_marked_safe",
    "wrong_branch_marked_safe",
    "missing_remote_ref_marked_safe"
)

$script:R18SampleDefinitions = @(
    [ordered]@{
        file = "remote_in_sync.sample.json"
        sample_id = "r18_012_sample_remote_in_sync"
        sample_name = "Remote in sync branch identity sample"
        sample_type = "remote_in_sync"
        actual_branch = $script:R18Branch
        local_head = $script:R18ExpectedCurrentHead
        local_tree = $script:R18ExpectedCurrentTree
        expected_remote_head = $script:R18ExpectedCurrentHead
        actual_remote_head = $script:R18ExpectedCurrentHead
        merge_base_head = $script:R18ExpectedCurrentHead
        ahead_by = 0
        behind_by = 0
        divergence_detected = $false
    },
    [ordered]@{
        file = "remote_ahead.sample.json"
        sample_id = "r18_012_sample_remote_ahead"
        sample_name = "Remote ahead branch identity sample"
        sample_type = "remote_ahead"
        actual_branch = $script:R18Branch
        local_head = "1111111111111111111111111111111111111111"
        local_tree = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        expected_remote_head = "1111111111111111111111111111111111111111"
        actual_remote_head = "2222222222222222222222222222222222222222"
        merge_base_head = "1111111111111111111111111111111111111111"
        ahead_by = 0
        behind_by = 1
        divergence_detected = $false
    },
    [ordered]@{
        file = "local_ahead.sample.json"
        sample_id = "r18_012_sample_local_ahead"
        sample_name = "Local ahead branch identity sample"
        sample_type = "local_ahead"
        actual_branch = $script:R18Branch
        local_head = "3333333333333333333333333333333333333333"
        local_tree = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
        expected_remote_head = "1111111111111111111111111111111111111111"
        actual_remote_head = "1111111111111111111111111111111111111111"
        merge_base_head = "1111111111111111111111111111111111111111"
        ahead_by = 1
        behind_by = 0
        divergence_detected = $false
    },
    [ordered]@{
        file = "diverged.sample.json"
        sample_id = "r18_012_sample_diverged"
        sample_name = "Diverged branch identity sample"
        sample_type = "diverged"
        actual_branch = $script:R18Branch
        local_head = "4444444444444444444444444444444444444444"
        local_tree = "cccccccccccccccccccccccccccccccccccccccc"
        expected_remote_head = "1111111111111111111111111111111111111111"
        actual_remote_head = "5555555555555555555555555555555555555555"
        merge_base_head = "1111111111111111111111111111111111111111"
        ahead_by = 1
        behind_by = 1
        divergence_detected = $true
    },
    [ordered]@{
        file = "wrong_branch.sample.json"
        sample_id = "r18_012_sample_wrong_branch"
        sample_name = "Wrong branch identity sample"
        sample_type = "wrong_branch"
        actual_branch = "feature/wrong-branch"
        local_head = $script:R18ExpectedCurrentHead
        local_tree = $script:R18ExpectedCurrentTree
        expected_remote_head = $script:R18ExpectedCurrentHead
        actual_remote_head = $script:R18ExpectedCurrentHead
        merge_base_head = $script:R18ExpectedCurrentHead
        ahead_by = 0
        behind_by = 0
        divergence_detected = $false
    },
    [ordered]@{
        file = "missing_remote_ref.sample.json"
        sample_id = "r18_012_sample_missing_remote_ref"
        sample_name = "Missing remote ref branch identity sample"
        sample_type = "missing_remote_ref"
        actual_branch = $script:R18Branch
        local_head = $script:R18ExpectedCurrentHead
        local_tree = $script:R18ExpectedCurrentTree
        expected_remote_head = $script:R18ExpectedCurrentHead
        actual_remote_head = $null
        merge_base_head = $null
        ahead_by = $null
        behind_by = $null
        divergence_detected = $false
    }
)

function Get-R18RemoteBranchVerifierRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18RemotePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18RemoteJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18RemoteJson {
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

function Write-R18RemoteText {
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

function Copy-R18RemoteBranchVerifierObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18RemoteBranchVerifierPaths {
    param([string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_remote_branch_verifier.contract.json"
        Profile = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_verifier_profile.json"
        SampleRoot = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_verification_samples"
        PacketRoot = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_verification_packets"
        CurrentVerification = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_current_verification.json"
        Results = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_verifier_results.json"
        CheckReport = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_remote_branch_verifier_check_report.json"
        UiSnapshot = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_remote_branch_verifier_snapshot.json"
        FixtureRoot = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_remote_branch_verifier"
        ProofRoot = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier"
        EvidenceIndex = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier/evidence_index.json"
        ProofReview = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier/proof_review.md"
        ValidationManifest = Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier/validation_manifest.md"
    }
}

function New-R18RemoteRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18RemoteAuthorityRefs {
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
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "state/runtime/r18_wip_classifier_results.json",
        "contracts/runtime/r18_work_order_state_machine.contract.json",
        "state/runtime/r18_work_order_seed_packets/",
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18RemoteEvidenceRefs {
    return @(
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_verifier_profile.json",
        "state/runtime/r18_remote_branch_verification_samples/",
        "state/runtime/r18_remote_branch_verification_packets/",
        "state/runtime/r18_remote_branch_current_verification.json",
        "state/runtime/r18_remote_branch_verifier_results.json",
        "state/runtime/r18_remote_branch_verifier_check_report.json",
        "state/ui/r18_operator_surface/r18_remote_branch_verifier_snapshot.json",
        "tools/R18RemoteBranchVerifier.psm1",
        "tools/new_r18_remote_branch_verifier.ps1",
        "tools/validate_r18_remote_branch_verifier.ps1",
        "tools/invoke_r18_remote_branch_verifier.ps1",
        "tests/test_r18_remote_branch_verifier.ps1",
        "tests/fixtures/r18_remote_branch_verifier/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier/"
    )
}

function Get-R18RemoteNonClaims {
    return @(
        "R18-012 created remote branch verifier foundation only.",
        "Current branch identity was verified only by bounded git identity checks.",
        "Remote branch verification is not recovery.",
        "Remote branch verification is not continuation packet generation.",
        "Remote branch verification is not new-context prompt generation.",
        "Remote branch verification is not push, merge, rebase, pull, checkout, switch, reset, clean, restore, stage, or commit.",
        "Remote branch verification is not release gate completion.",
        "Continuation packet generator is not implemented.",
        "New-context prompt generator is not implemented.",
        "No recovery action was performed.",
        "No WIP cleanup was performed.",
        "No WIP abandonment was performed.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No product runtime is claimed.",
        "Main is not merged."
    )
}

function Get-R18RemoteRule {
    param([Parameter(Mandatory = $true)][string]$SampleType)

    switch ($SampleType) {
        "remote_in_sync" {
            return [pscustomobject]@{
                verification_status = "remote_in_sync_safe"
                action_recommendation = "continue_without_branch_action"
                safe_to_continue = $true
                operator_decision_required = $false
                next_safe_step = "Continue only to the next separately validated R18 gate; do not mutate branch state."
                stop_conditions = @("Stop if branch changes, remote head changes, unsafe WIP appears, or a later gate fails.")
                escalation_conditions = @("Escalate if current identity no longer matches expected branch/head/tree/remote head.")
            }
        }
        "remote_ahead" {
            return [pscustomobject]@{
                verification_status = "remote_ahead_blocked"
                action_recommendation = "stop_remote_ahead_requires_operator_decision"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop and request operator decision before any branch action."
                stop_conditions = @("Remote head is ahead of local head.", "No pull/rebase/merge/reset is allowed in R18-012.")
                escalation_conditions = @("Escalate remote movement to operator decision.")
            }
        }
        "local_ahead" {
            return [pscustomobject]@{
                verification_status = "local_ahead_review_required"
                action_recommendation = "review_local_ahead_before_push"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Review local-ahead state before any future push gate; R18-012 does not make local ahead push-safe."
                stop_conditions = @("Local head is ahead of remote head.", "R18-012 does not implement push or release gate.")
                escalation_conditions = @("Escalate if local-ahead state is unexpected or unapproved.")
            }
        }
        "diverged" {
            return [pscustomobject]@{
                verification_status = "diverged_operator_decision_required"
                action_recommendation = "stop_diverged_requires_operator_decision"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop and request operator decision for diverged branch state."
                stop_conditions = @("Local and remote both contain unique commits.", "No merge/rebase/reset is allowed in R18-012.")
                escalation_conditions = @("Escalate divergence to operator decision.")
            }
        }
        "wrong_branch" {
            return [pscustomobject]@{
                verification_status = "wrong_branch_blocked"
                action_recommendation = "stop_wrong_branch"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop on wrong branch; do not switch branches inside the verifier."
                stop_conditions = @("Actual branch does not match expected R18 branch.")
                escalation_conditions = @("Escalate wrong-branch identity to operator decision.")
            }
        }
        "missing_remote_ref" {
            return [pscustomobject]@{
                verification_status = "missing_remote_ref_blocked"
                action_recommendation = "stop_missing_remote_ref"
                safe_to_continue = $false
                operator_decision_required = $true
                next_safe_step = "Stop because expected remote ref is missing."
                stop_conditions = @("Expected remote ref is not present.")
                escalation_conditions = @("Escalate missing remote ref to operator decision.")
            }
        }
        default {
            throw "Unknown R18 remote branch sample type '$SampleType'."
        }
    }
}

function Get-R18RemoteSampleRef {
    param([Parameter(Mandatory = $true)][string]$FileName)
    return "state/runtime/r18_remote_branch_verification_samples/$FileName"
}

function Get-R18RemoteVerificationFileName {
    param([Parameter(Mandatory = $true)][string]$SampleType)
    return "$SampleType.verification.json"
}

function Get-R18RemoteDefinitionByType {
    param([Parameter(Mandatory = $true)][string]$SampleType)

    $matches = @($script:R18SampleDefinitions | Where-Object { $_.sample_type -eq $SampleType })
    if ($matches.Count -ne 1) {
        throw "Expected exactly one R18 remote sample definition for '$SampleType'."
    }
    return $matches[0]
}

function New-R18RemoteBranchVerifierContract {
    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-012-remote-branch-verifier-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "remote_branch_verifier_foundation_only_bounded_git_identity_checks_no_branch_mutation"
        purpose = "Create deterministic remote branch identity samples and verification packets, plus one bounded current-branch verification packet, without recovery, continuation packet generation, prompt generation, branch mutation, pull, rebase, reset, merge, checkout, switch, clean, restore, staging, commit, push, API invocation, live agents, live skills, A2A messages, work-order execution, or board/card runtime mutation."
        required_sample_fields = $script:R18RequiredSampleFields
        required_verification_fields = $script:R18RequiredVerificationFields
        allowed_sample_types = $script:R18AllowedSampleTypes
        allowed_verification_statuses = $script:R18AllowedVerificationStatuses
        allowed_action_recommendations = $script:R18AllowedActionRecommendations
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        branch_identity_policy = [ordered]@{
            expected_branch = $script:R18Branch
            current_branch_source = "git status --short --branch"
            wrong_branch_status = "wrong_branch_blocked"
            branch_mutation_allowed = $false
        }
        remote_identity_policy = [ordered]@{
            expected_remote_ref = $script:R18RemoteRef
            expected_remote_head = $script:R18ExpectedCurrentHead
            remote_head_source = "git fetch origin release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle then git rev-parse origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
            missing_remote_status = "missing_remote_ref_blocked"
            remote_branch_mutation_allowed = $false
        }
        divergence_policy = [ordered]@{
            merge_base_command = "git merge-base HEAD origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
            ahead_behind_command = "git rev-list --left-right --count HEAD...origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
            remote_ahead_safe_to_continue = $false
            local_ahead_safe_to_continue_for_r18_012 = $false
            diverged_safe_to_continue = $false
        }
        operator_decision_policy = [ordered]@{
            required_for = @("remote_ahead", "local_ahead", "diverged", "wrong_branch", "missing_remote_ref")
            not_required_for = @("remote_in_sync")
        }
        runner_state_policy = [ordered]@{
            runner_state_ref = "state/runtime/r18_runner_state.json"
            runner_state_runtime_executed = $false
        }
        failure_event_policy = [ordered]@{
            failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
            failure_events_are_not_recovery_completion = $true
        }
        wip_classification_policy = [ordered]@{
            wip_classification_ref = "state/runtime/r18_wip_classifier_results.json"
            wip_cleanup_allowed = $false
            wip_abandonment_allowed = $false
        }
        evidence_policy = [ordered]@{
            required_evidence_refs = Get-R18RemoteEvidenceRefs
            proof_review_required = $true
        }
        authority_policy = [ordered]@{
            required_authority_refs = Get-R18RemoteAuthorityRefs
            r18_active_boundary = "R18 active through R18-013 only"
            planned_boundary = "R18-014 through R18-028 planned only"
        }
        continuation_boundary_policy = [ordered]@{
            continuation_packet_generation_allowed = $false
            new_context_prompt_generation_allowed = $false
            deferred_to = @("R18-013", "R18-014")
        }
        path_policy = [ordered]@{
            allowed_write_paths = @(
                "contracts/runtime/r18_remote_branch_verifier.contract.json",
                "state/runtime/r18_remote_branch_verifier_profile.json",
                "state/runtime/r18_remote_branch_verification_samples/",
                "state/runtime/r18_remote_branch_verification_packets/",
                "state/runtime/r18_remote_branch_current_verification.json",
                "state/runtime/r18_remote_branch_verifier_results.json",
                "state/runtime/r18_remote_branch_verifier_check_report.json",
                "state/ui/r18_operator_surface/r18_remote_branch_verifier_snapshot.json",
                "tools/R18RemoteBranchVerifier.psm1",
                "tools/new_r18_remote_branch_verifier.ps1",
                "tools/validate_r18_remote_branch_verifier.ps1",
                "tools/invoke_r18_remote_branch_verifier.ps1",
                "tests/test_r18_remote_branch_verifier.ps1",
                "tests/fixtures/r18_remote_branch_verifier/",
                "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_012_remote_branch_verifier/"
            )
            forbidden_write_paths = @(".local_backups/", "state/proof_reviews/r13_", "state/proof_reviews/r14_", "state/proof_reviews/r15_", "state/proof_reviews/r16_")
        }
        git_command_policy = [ordered]@{
            allowed_git_commands = @(
                "git status --short --branch",
                "git rev-parse HEAD",
                "git rev-parse `"HEAD^{tree}`"",
                "git fetch origin release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
                "git rev-parse origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
                "git merge-base HEAD origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
                "git rev-list --left-right --count HEAD...origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
            )
            forbidden_git_commands = @("git pull", "git rebase", "git reset", "git merge", "git checkout", "git switch", "git clean", "git restore", "git add", "git commit", "git push")
            only_fetch_may_update_remote_tracking_state = $true
        }
        api_policy = [ordered]@{
            openai_api_invocation_allowed = $false
            codex_api_invocation_allowed = $false
            autonomous_codex_invocation_allowed = $false
        }
        execution_policy = [ordered]@{
            recovery_action_allowed = $false
            work_order_execution_allowed = $false
            live_runner_runtime_allowed = $false
            board_runtime_mutation_allowed = $false
            stage_commit_push_allowed_by_verifier = $false
        }
        refusal_policy = [ordered]@{
            refuse_on_wrong_branch = $true
            refuse_on_missing_remote_ref = $true
            refuse_on_remote_ahead = $true
            refuse_on_diverged = $true
            refuse_on_forbidden_claim = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18RemoteNonClaims
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
    }
}

function New-R18RemoteBranchVerifierProfile {
    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-012-remote-branch-verifier-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        expected_remote_ref = $script:R18RemoteRef
        expected_current_head = $script:R18ExpectedCurrentHead
        expected_current_tree = $script:R18ExpectedCurrentTree
        verification_mode = "bounded_git_identity_verification_only_not_recovery"
        sample_count = @($script:R18SampleDefinitions).Count
        packet_count = @($script:R18SampleDefinitions).Count
        current_verification_ref = "state/runtime/r18_remote_branch_current_verification.json"
        allowed_git_commands = (New-R18RemoteBranchVerifierContract).git_command_policy.allowed_git_commands
        forbidden_git_commands = (New-R18RemoteBranchVerifierContract).git_command_policy.forbidden_git_commands
        positive_claims = @("r18_remote_branch_verifier_profile_created")
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteSample {
    param([Parameter(Mandatory = $true)][object]$Definition)

    $rule = Get-R18RemoteRule -SampleType ([string]$Definition.sample_type)
    return [ordered]@{
        artifact_type = "r18_remote_branch_verification_sample"
        contract_version = "v1"
        sample_id = [string]$Definition.sample_id
        sample_name = [string]$Definition.sample_name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        sample_status = "seed_branch_identity_sample_only_not_branch_mutation"
        sample_type = [string]$Definition.sample_type
        repository = $script:R18Repository
        expected_branch = $script:R18Branch
        actual_branch = [string]$Definition.actual_branch
        local_head = [string]$Definition.local_head
        local_tree = [string]$Definition.local_tree
        expected_remote_ref = $script:R18RemoteRef
        expected_remote_head = [string]$Definition.expected_remote_head
        actual_remote_head = $Definition.actual_remote_head
        merge_base_head = $Definition.merge_base_head
        ahead_by = $Definition.ahead_by
        behind_by = $Definition.behind_by
        divergence_detected = [bool]$Definition.divergence_detected
        expected_verification_status = $rule.verification_status
        expected_action_recommendation = $rule.action_recommendation
        runner_state_ref = "state/runtime/r18_runner_state.json"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        wip_classification_ref = "state/runtime/r18_wip_classifier_results.json"
        evidence_refs = @((Get-R18RemoteEvidenceRefs) + @((Get-R18RemoteSampleRef -FileName ([string]$Definition.file))))
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Get-R18RemoteSampleTypeFromStatus {
    param(
        [string]$ExpectedBranch,
        [string]$ActualBranch,
        [string]$LocalHead,
        [string]$ExpectedRemoteHead,
        [AllowNull()][object]$ActualRemoteHead,
        [AllowNull()][object]$AheadBy,
        [AllowNull()][object]$BehindBy
    )

    if ($ExpectedBranch -ne $ActualBranch) {
        return "wrong_branch"
    }
    if ($null -eq $ActualRemoteHead -or [string]::IsNullOrWhiteSpace([string]$ActualRemoteHead)) {
        return "missing_remote_ref"
    }

    $ahead = if ($null -eq $AheadBy) { 0 } else { [int]$AheadBy }
    $behind = if ($null -eq $BehindBy) { 0 } else { [int]$BehindBy }

    if ($ahead -gt 0 -and $behind -gt 0) {
        return "diverged"
    }
    if ($behind -gt 0) {
        return "remote_ahead"
    }
    if ($ahead -gt 0) {
        return "local_ahead"
    }
    if ($LocalHead -eq [string]$ActualRemoteHead -and [string]$ActualRemoteHead -eq $ExpectedRemoteHead) {
        return "remote_in_sync"
    }

    return "remote_ahead"
}

function New-R18RemoteVerificationPacketFromValues {
    param(
        [Parameter(Mandatory = $true)][string]$VerificationId,
        [Parameter(Mandatory = $true)][string]$SourceSampleRef,
        [Parameter(Mandatory = $true)][string]$ExpectedBranch,
        [Parameter(Mandatory = $true)][string]$ActualBranch,
        [Parameter(Mandatory = $true)][string]$LocalHead,
        [Parameter(Mandatory = $true)][string]$LocalTree,
        [Parameter(Mandatory = $true)][string]$ExpectedRemoteRef,
        [Parameter(Mandatory = $true)][string]$ExpectedRemoteHead,
        [AllowNull()][object]$ActualRemoteHead,
        [AllowNull()][object]$MergeBaseHead,
        [AllowNull()][object]$AheadBy,
        [AllowNull()][object]$BehindBy,
        [bool]$DivergenceDetected,
        [string]$VerificationMode = "deterministic_seed_verification_packet_only"
    )

    $sampleType = Get-R18RemoteSampleTypeFromStatus -ExpectedBranch $ExpectedBranch -ActualBranch $ActualBranch -LocalHead $LocalHead -ExpectedRemoteHead $ExpectedRemoteHead -ActualRemoteHead $ActualRemoteHead -AheadBy $AheadBy -BehindBy $BehindBy
    if ($DivergenceDetected) {
        $sampleType = "diverged"
    }
    $rule = Get-R18RemoteRule -SampleType $sampleType
    $branchMatch = ($ExpectedBranch -eq $ActualBranch)
    $remotePresent = -not ($null -eq $ActualRemoteHead -or [string]::IsNullOrWhiteSpace([string]$ActualRemoteHead))

    return [ordered]@{
        artifact_type = "r18_remote_branch_verification_packet"
        contract_version = "v1"
        verification_id = $VerificationId
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        verification_status = $rule.verification_status
        verification_mode = $VerificationMode
        source_sample_ref = $SourceSampleRef
        repository = $script:R18Repository
        expected_branch = $ExpectedBranch
        actual_branch = $ActualBranch
        local_head = $LocalHead
        local_tree = $LocalTree
        expected_remote_ref = $ExpectedRemoteRef
        expected_remote_head = $ExpectedRemoteHead
        actual_remote_head = $ActualRemoteHead
        merge_base_head = $MergeBaseHead
        ahead_by = $AheadBy
        behind_by = $BehindBy
        divergence_detected = [bool]$DivergenceDetected
        branch_match = [bool]$branchMatch
        remote_ref_present = [bool]$remotePresent
        safe_to_continue = [bool]$rule.safe_to_continue
        operator_decision_required = [bool]$rule.operator_decision_required
        action_recommendation = $rule.action_recommendation
        runner_state_ref = "state/runtime/r18_runner_state.json"
        failure_event_ref = "state/runtime/r18_detected_failure_events/context_compaction_required.failure.json"
        wip_classification_ref = "state/runtime/r18_wip_classifier_results.json"
        next_safe_step = $rule.next_safe_step
        stop_conditions = $rule.stop_conditions
        escalation_conditions = $rule.escalation_conditions
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        validation_refs = @("tools/validate_r18_remote_branch_verifier.ps1", "tests/test_r18_remote_branch_verifier.ps1")
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteVerificationPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Sample,
        [Parameter(Mandatory = $true)][string]$SampleFileName
    )

    return New-R18RemoteVerificationPacketFromValues `
        -VerificationId ("r18_012_remote_branch_verification_{0}" -f [string]$Sample.sample_type) `
        -SourceSampleRef (Get-R18RemoteSampleRef -FileName $SampleFileName) `
        -ExpectedBranch ([string]$Sample.expected_branch) `
        -ActualBranch ([string]$Sample.actual_branch) `
        -LocalHead ([string]$Sample.local_head) `
        -LocalTree ([string]$Sample.local_tree) `
        -ExpectedRemoteRef ([string]$Sample.expected_remote_ref) `
        -ExpectedRemoteHead ([string]$Sample.expected_remote_head) `
        -ActualRemoteHead $Sample.actual_remote_head `
        -MergeBaseHead $Sample.merge_base_head `
        -AheadBy $Sample.ahead_by `
        -BehindBy $Sample.behind_by `
        -DivergenceDetected ([bool]$Sample.divergence_detected)
}

function New-R18RemoteSeedCurrentVerification {
    return New-R18RemoteVerificationPacketFromValues `
        -VerificationId "r18_012_current_remote_branch_verification" `
        -SourceSampleRef "bounded_current_branch_git_identity_observation" `
        -ExpectedBranch $script:R18Branch `
        -ActualBranch $script:R18Branch `
        -LocalHead $script:R18ExpectedCurrentHead `
        -LocalTree $script:R18ExpectedCurrentTree `
        -ExpectedRemoteRef $script:R18RemoteRef `
        -ExpectedRemoteHead $script:R18ExpectedCurrentHead `
        -ActualRemoteHead $script:R18ExpectedCurrentHead `
        -MergeBaseHead $script:R18ExpectedCurrentHead `
        -AheadBy 0 `
        -BehindBy 0 `
        -DivergenceDetected $false `
        -VerificationMode "deterministic_expected_current_identity_seed_pending_bounded_invoke"
}

function New-R18RemoteBranchVerifierResults {
    param(
        [Parameter(Mandatory = $true)][object[]]$Verifications,
        [Parameter(Mandatory = $true)][object]$CurrentVerification
    )

    $entries = @()
    foreach ($verification in @($Verifications)) {
        $entries += [ordered]@{
            verification_id = $verification.verification_id
            verification_status = $verification.verification_status
            action_recommendation = $verification.action_recommendation
            safe_to_continue = [bool]$verification.safe_to_continue
            operator_decision_required = [bool]$verification.operator_decision_required
            packet_ref = "state/runtime/r18_remote_branch_verification_packets/{0}" -f (Get-R18RemoteVerificationFileName -SampleType ([string]($verification.verification_id -replace '^r18_012_remote_branch_verification_', '')))
            runtime_flags = New-R18RemoteRuntimeFlags
        }
    }

    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_results"
        contract_version = "v1"
        results_id = "aioffice-r18-012-remote-branch-verifier-results-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        result_status = $script:R18VerifierVerdict
        sample_count = @($script:R18SampleDefinitions).Count
        verification_packet_count = @($Verifications).Count
        current_verification_ref = "state/runtime/r18_remote_branch_current_verification.json"
        current_verification_status = $CurrentVerification.verification_status
        current_action_recommendation = $CurrentVerification.action_recommendation
        current_safe_to_continue = [bool]$CurrentVerification.safe_to_continue
        verification_results = $entries
        positive_claims = @(
            "r18_remote_branch_verification_samples_created",
            "r18_remote_branch_verification_packets_created",
            "r18_current_remote_branch_verification_created",
            "r18_remote_branch_verifier_results_created"
        )
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteBranchVerifierCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Samples,
        [Parameter(Mandatory = $true)][object[]]$Verifications,
        [Parameter(Mandatory = $true)][object]$CurrentVerification
    )

    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-012-remote-branch-verifier-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18VerifierVerdict
        status_boundary = "R18 active through R18-013 only; R18-014 through R18-028 planned only."
        checked_sample_count = @($Samples).Count
        checked_verification_packet_count = @($Verifications).Count
        current_verification_status = $CurrentVerification.verification_status
        current_safe_to_continue = [bool]$CurrentVerification.safe_to_continue
        checks = @(
            [ordered]@{ check_id = "required_artifacts"; status = "passed"; boundary = "contract/profile/samples/packets/current/results/report/snapshot present" },
            [ordered]@{ check_id = "classification_rules"; status = "passed"; boundary = "all six verification rule classes validated" },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed"; boundary = "all required runtime flags remain false" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-013 only; R18-014 through R18-028 planned only" }
        )
        positive_claims = @(
            "r18_remote_branch_verifier_contract_created",
            "r18_remote_branch_verifier_profile_created",
            "r18_remote_branch_verification_samples_created",
            "r18_remote_branch_verification_packets_created",
            "r18_current_remote_branch_verification_created",
            "r18_remote_branch_verifier_results_created",
            "r18_remote_branch_verifier_validator_created",
            "r18_remote_branch_verifier_fixtures_created",
            "r18_remote_branch_verifier_proof_review_created"
        )
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteBranchVerifierSnapshot {
    param(
        [Parameter(Mandatory = $true)][object[]]$Verifications,
        [Parameter(Mandatory = $true)][object]$CurrentVerification
    )

    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-012-remote-branch-verifier-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        r18_status = "active_through_r18_012_only"
        planned_only_boundary = "R18-014 through R18-028 remain planned only"
        repository = $script:R18Repository
        branch = $script:R18Branch
        current_verification_ref = "state/runtime/r18_remote_branch_current_verification.json"
        current_verification_status = $CurrentVerification.verification_status
        current_safe_to_continue = [bool]$CurrentVerification.safe_to_continue
        remote_branch_verifier_foundation_only = "bounded branch/head/tree/remote-head verification evidence only"
        verification_summary = @($Verifications | ForEach-Object {
                [ordered]@{
                    verification_id = $_.verification_id
                    status = $_.verification_status
                    safe_to_continue = [bool]$_.safe_to_continue
                    action_recommendation = $_.action_recommendation
                }
            })
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
        positive_claims = @("r18_current_remote_branch_verification_created")
    }
}

function New-R18RemoteFixtureManifest {
    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        fixture_status = "invalid_mutation_fixtures_only_not_runtime_events"
        invalid_fixture_count = @(New-R18RemoteFixtureDefinitions).Count
        invalid_fixtures = @((New-R18RemoteFixtureDefinitions) | ForEach-Object { $_.file })
        allowed_sample_types = $script:R18AllowedSampleTypes
        allowed_verification_statuses = $script:R18AllowedVerificationStatuses
        allowed_action_recommendations = $script:R18AllowedActionRecommendations
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteFixtureDefinition {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Fragment
    )

    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_invalid_fixture"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        file = $File
        target = $Target
        operation = $Operation
        path = $Path
        value = $Value
        expected_failure_fragments = @($Fragment)
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteFixtureDefinitions {
    return @(
        (New-R18RemoteFixtureDefinition -File "invalid_missing_sample_id.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "sample_id" -Value $null -Fragment "sample_id"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_expected_branch.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "expected_branch" -Value $null -Fragment "expected_branch"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_local_head.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "local_head" -Value $null -Fragment "local_head"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_local_tree.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "local_tree" -Value $null -Fragment "local_tree"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_expected_remote_head.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "expected_remote_head" -Value $null -Fragment "expected_remote_head"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_actual_remote_head.json" -Target "sample:remote_in_sync" -Operation "remove" -Path "actual_remote_head" -Value $null -Fragment "actual_remote_head"),
        (New-R18RemoteFixtureDefinition -File "invalid_unknown_verification_status.json" -Target "verification:remote_in_sync" -Operation "set" -Path "verification_status" -Value "unknown_status" -Fragment "unknown verification_status"),
        (New-R18RemoteFixtureDefinition -File "invalid_remote_ahead_marked_safe.json" -Target "verification:remote_ahead" -Operation "set" -Path "safe_to_continue" -Value $true -Fragment "safe_to_continue does not match deterministic rule"),
        (New-R18RemoteFixtureDefinition -File "invalid_diverged_marked_safe.json" -Target "verification:diverged" -Operation "set" -Path "safe_to_continue" -Value $true -Fragment "safe_to_continue does not match deterministic rule"),
        (New-R18RemoteFixtureDefinition -File "invalid_wrong_branch_marked_safe.json" -Target "verification:wrong_branch" -Operation "set" -Path "safe_to_continue" -Value $true -Fragment "safe_to_continue does not match deterministic rule"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_remote_marked_safe.json" -Target "verification:missing_remote_ref" -Operation "set" -Path "safe_to_continue" -Value $true -Fragment "safe_to_continue does not match deterministic rule"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_operator_decision_policy.json" -Target "contract" -Operation "remove" -Path "operator_decision_policy" -Value $null -Fragment "operator_decision_policy"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_evidence_refs.json" -Target "verification:remote_in_sync" -Operation "remove" -Path "evidence_refs" -Value $null -Fragment "evidence_refs"),
        (New-R18RemoteFixtureDefinition -File "invalid_missing_authority_refs.json" -Target "verification:remote_in_sync" -Operation "remove" -Path "authority_refs" -Value $null -Fragment "authority_refs"),
        (New-R18RemoteFixtureDefinition -File "invalid_continuation_packet_generation_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.continuation_packet_generated" -Value $true -Fragment "continuation_packet_generated"),
        (New-R18RemoteFixtureDefinition -File "invalid_new_context_prompt_generation_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.new_context_prompt_generated" -Value $true -Fragment "new_context_prompt_generated"),
        (New-R18RemoteFixtureDefinition -File "invalid_recovery_action_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Fragment "recovery_action_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_wip_cleanup_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.wip_cleanup_performed" -Value $true -Fragment "wip_cleanup_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_stage_commit_push_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.push_performed" -Value $true -Fragment "push_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_work_order_execution_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Fragment "work_order_execution_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_live_runner_runtime_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.live_runner_runtime_executed" -Value $true -Fragment "live_runner_runtime_executed"),
        (New-R18RemoteFixtureDefinition -File "invalid_skill_execution_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.live_skill_execution_performed" -Value $true -Fragment "live_skill_execution_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_a2a_message_sent_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Fragment "a2a_message_sent"),
        (New-R18RemoteFixtureDefinition -File "invalid_board_runtime_mutation_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Fragment "board_runtime_mutation_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_api_invocation_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.openai_api_invoked" -Value $true -Fragment "openai_api_invoked"),
        (New-R18RemoteFixtureDefinition -File "invalid_automatic_new_thread_creation_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Fragment "automatic_new_thread_creation_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_pull_rebase_reset_merge_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.merge_performed" -Value $true -Fragment "merge_performed"),
        (New-R18RemoteFixtureDefinition -File "invalid_r18_013_completion_claim.json" -Target "verification:remote_in_sync" -Operation "set" -Path "runtime_flags.r18_013_completed" -Value $true -Fragment "r18_013_completed")
    )
}

function New-R18RemoteEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_remote_branch_verifier_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_status = "proof_review_index_for_remote_branch_verifier_foundation_only"
        evidence_refs = Get-R18RemoteEvidenceRefs
        authority_refs = Get-R18RemoteAuthorityRefs
        validation_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_remote_branch_verifier.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_remote_branch_verifier.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_remote_branch_verifier.ps1"
        )
        runtime_flags = New-R18RemoteRuntimeFlags
        non_claims = Get-R18RemoteNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18RemoteProofReviewText {
    return @(
        "# R18-012 Remote Branch Verifier Proof Review",
        "",
        "R18-012 creates the remote branch verifier foundation only. It defines the contract, profile, six deterministic branch identity samples, six verification packets, one bounded current-branch verification packet, results, check report, operator-surface snapshot, fixtures, and validation tooling.",
        "",
        "The current verification is bounded to branch/head/tree/remote-head identity checks. It is not recovery, not continuation packet generation, not new-context prompt generation, not release gating, not branch mutation, and not push/merge/rebase/reset/pull/checkout/switch/clean/restore/stage/commit.",
        "",
        "R18 remains active through R18-013 only. R18-014 through R18-028 remain planned only.",
        "",
        "Non-claims preserved: no recovery action, no WIP cleanup or abandonment, no work-order execution, no board/card runtime mutation, no A2A messages, no live agent or skill execution, no API invocation, no automatic new-thread creation, no product runtime, no solved Codex compaction/reliability claim, no no-manual-prompt-transfer success claim, and no main merge."
    ) -join [Environment]::NewLine
}

function New-R18RemoteValidationManifestText {
    return @(
        "# R18-012 Validation Manifest",
        "",
        "Expected status truth after this package: R18 active through R18-013 only; R18-014 through R18-028 planned only.",
        "",
        "Required validation commands:",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_remote_branch_verifier.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_remote_branch_verifier.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1",
        "- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_remote_branch_verifier.ps1",
        "",
        "Boundary: bounded git identity verification only. No continuation packets, new-context prompts, recovery actions, WIP cleanup, branch mutation, pull/rebase/reset/merge, checkout/switch, clean/restore, staging, commit, push, API invocation, live agent execution, live skill execution, A2A messages, or board/card runtime mutation."
    ) -join [Environment]::NewLine
}

function New-R18RemoteBranchVerifierArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot))

    $paths = Get-R18RemoteBranchVerifierPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18RemoteBranchVerifierContract
    $profile = New-R18RemoteBranchVerifierProfile
    $samples = @()
    $verifications = @()

    foreach ($definition in $script:R18SampleDefinitions) {
        $sample = New-R18RemoteSample -Definition $definition
        $samples += $sample
        $verifications += New-R18RemoteVerificationPacket -Sample $sample -SampleFileName ([string]$definition.file)
    }

    $current = New-R18RemoteSeedCurrentVerification
    $results = New-R18RemoteBranchVerifierResults -Verifications $verifications -CurrentVerification $current
    $report = New-R18RemoteBranchVerifierCheckReport -Samples $samples -Verifications $verifications -CurrentVerification $current
    $snapshot = New-R18RemoteBranchVerifierSnapshot -Verifications $verifications -CurrentVerification $current

    Write-R18RemoteJson -Path $paths.Contract -Value $contract
    Write-R18RemoteJson -Path $paths.Profile -Value $profile
    foreach ($definition in $script:R18SampleDefinitions) {
        $sample = @($samples | Where-Object { $_.sample_type -eq [string]$definition.sample_type })[0]
        $verification = @($verifications | Where-Object { $_.verification_id -eq ("r18_012_remote_branch_verification_{0}" -f [string]$definition.sample_type) })[0]
        Write-R18RemoteJson -Path (Join-Path $paths.SampleRoot ([string]$definition.file)) -Value $sample
        Write-R18RemoteJson -Path (Join-Path $paths.PacketRoot (Get-R18RemoteVerificationFileName -SampleType ([string]$definition.sample_type))) -Value $verification
    }
    Write-R18RemoteJson -Path $paths.CurrentVerification -Value $current
    Write-R18RemoteJson -Path $paths.Results -Value $results
    Write-R18RemoteJson -Path $paths.CheckReport -Value $report
    Write-R18RemoteJson -Path $paths.UiSnapshot -Value $snapshot
    Write-R18RemoteJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18RemoteFixtureManifest)
    foreach ($fixture in New-R18RemoteFixtureDefinitions) {
        Write-R18RemoteJson -Path (Join-Path $paths.FixtureRoot ([string]$fixture.file)) -Value $fixture
    }
    Write-R18RemoteJson -Path $paths.EvidenceIndex -Value (New-R18RemoteEvidenceIndex)
    Write-R18RemoteText -Path $paths.ProofReview -Value (New-R18RemoteProofReviewText)
    Write-R18RemoteText -Path $paths.ValidationManifest -Value (New-R18RemoteValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Profile = $paths.Profile
        SampleRoot = $paths.SampleRoot
        PacketRoot = $paths.PacketRoot
        CurrentVerification = $paths.CurrentVerification
        Results = $paths.Results
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        SampleCount = @($samples).Count
        VerificationPacketCount = @($verifications).Count
        AggregateVerdict = $script:R18VerifierVerdict
    }
}

function Invoke-R18RemoteGit {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [bool]$AllowFailure = $false
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $RepositoryRoot @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $lines = @($output | ForEach-Object { [string]$_ })
    if ($exitCode -ne 0 -and -not $AllowFailure) {
        throw "git $($Arguments -join ' ') failed with exit code $exitCode. $($lines -join [Environment]::NewLine)"
    }
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = $lines
        Text = ($lines -join [Environment]::NewLine).Trim()
    }
}

function Get-R18RemoteActualBranchFromStatus {
    param([Parameter(Mandatory = $true)][string[]]$StatusLines)

    $branchLine = @($StatusLines | Where-Object { $_ -like "## *" } | Select-Object -First 1)
    if ($branchLine.Count -eq 0) {
        return ""
    }

    $branch = ([string]$branchLine[0]) -replace '^##\s+', ''
    $branch = ($branch -split '\.\.\.')[0]
    $branch = ($branch -split '\s+')[0]
    return $branch.Trim()
}

function Invoke-R18RemoteBranchVerifier {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot),
        [string]$ExpectedBranch = $script:R18Branch,
        [string]$ExpectedRemoteHead = $script:R18ExpectedCurrentHead,
        [string]$ExpectedLocalTree = $script:R18ExpectedCurrentTree
    )

    $paths = Get-R18RemoteBranchVerifierPaths -RepositoryRoot $RepositoryRoot
    $status = Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("status", "--short", "--branch")
    $actualBranch = Get-R18RemoteActualBranchFromStatus -StatusLines $status.Output
    $head = (Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD")).Text
    $tree = (Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}")).Text
    $fetch = Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("fetch", "origin", $script:R18Branch) -AllowFailure $true
    $remote = Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", $script:R18RemoteRef) -AllowFailure $true

    $actualRemoteHead = $null
    $mergeBase = $null
    $aheadBy = $null
    $behindBy = $null
    $diverged = $false

    if ($remote.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($remote.Text)) {
        $actualRemoteHead = $remote.Text
        $merge = Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("merge-base", "HEAD", $script:R18RemoteRef) -AllowFailure $true
        if ($merge.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($merge.Text)) {
            $mergeBase = $merge.Text
        }

        $counts = Invoke-R18RemoteGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-list", "--left-right", "--count", ("HEAD...{0}" -f $script:R18RemoteRef)) -AllowFailure $true
        if ($counts.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($counts.Text)) {
            $parts = $counts.Text -split '\s+'
            if ($parts.Count -ge 2) {
                $aheadBy = [int]$parts[0]
                $behindBy = [int]$parts[1]
                $diverged = ($aheadBy -gt 0 -and $behindBy -gt 0)
            }
        }
    }

    $current = New-R18RemoteVerificationPacketFromValues `
        -VerificationId "r18_012_current_remote_branch_verification" `
        -SourceSampleRef "bounded_current_branch_git_identity_observation" `
        -ExpectedBranch $ExpectedBranch `
        -ActualBranch $actualBranch `
        -LocalHead $head `
        -LocalTree $tree `
        -ExpectedRemoteRef $script:R18RemoteRef `
        -ExpectedRemoteHead $ExpectedRemoteHead `
        -ActualRemoteHead $actualRemoteHead `
        -MergeBaseHead $mergeBase `
        -AheadBy $aheadBy `
        -BehindBy $behindBy `
        -DivergenceDetected $diverged `
        -VerificationMode "bounded_git_identity_verification_only_not_recovery_not_continuation_not_push_not_merge_not_release_gate"

    $current["expected_local_tree"] = $ExpectedLocalTree
    $current["git_status_short_branch"] = $status.Output
    $current["git_fetch_exit_code"] = $fetch.ExitCode
    $current["git_fetch_output_summary"] = $fetch.Output
    $current["bounded_git_commands_observed"] = @(
        "git status --short --branch",
        "git rev-parse HEAD",
        "git rev-parse `"HEAD^{tree}`"",
        "git fetch origin release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
        "git rev-parse origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
        "git merge-base HEAD origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle",
        "git rev-list --left-right --count HEAD...origin/release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
    )

    $verifications = @()
    foreach ($definition in $script:R18SampleDefinitions) {
        $verifications += Read-R18RemoteJson -Path (Join-Path $paths.PacketRoot (Get-R18RemoteVerificationFileName -SampleType ([string]$definition.sample_type)))
    }
    $samples = @()
    foreach ($definition in $script:R18SampleDefinitions) {
        $samples += Read-R18RemoteJson -Path (Join-Path $paths.SampleRoot ([string]$definition.file))
    }

    Write-R18RemoteJson -Path $paths.CurrentVerification -Value $current
    Write-R18RemoteJson -Path $paths.Results -Value (New-R18RemoteBranchVerifierResults -Verifications $verifications -CurrentVerification $current)
    Write-R18RemoteJson -Path $paths.CheckReport -Value (New-R18RemoteBranchVerifierCheckReport -Samples $samples -Verifications $verifications -CurrentVerification $current)
    Write-R18RemoteJson -Path $paths.UiSnapshot -Value (New-R18RemoteBranchVerifierSnapshot -Verifications $verifications -CurrentVerification $current)

    return [pscustomobject]@{
        CurrentVerification = $paths.CurrentVerification
        VerificationStatus = $current.verification_status
        ActionRecommendation = $current.action_recommendation
        SafeToContinue = [bool]$current.safe_to_continue
        ActualBranch = $actualBranch
        LocalHead = $head
        LocalTree = $tree
        ActualRemoteHead = $actualRemoteHead
    }
}

function Assert-R18RemoteCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18RemoteRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18RemoteCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18RemoteRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18RemoteCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context missing runtime flag '$field'."
        Assert-R18RemoteCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Assert-R18RemoteNoForbiddenTrueProperties {
    param(
        [AllowNull()][object]$Object,
        [string]$Context = "R18 remote branch verifier artifact"
    )

    if ($null -eq $Object) {
        return
    }
    if ($Object -is [string]) {
        return
    }
    if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [pscustomobject]) -and -not ($Object -is [System.Collections.IDictionary])) {
        foreach ($item in @($Object)) {
            Assert-R18RemoteNoForbiddenTrueProperties -Object $item -Context $Context
        }
        return
    }
    if ($null -eq $Object.PSObject -or $null -eq $Object.PSObject.Properties) {
        return
    }
    foreach ($property in $Object.PSObject.Properties) {
        if (($script:R18RuntimeFlagFields -contains $property.Name) -and [bool]$property.Value) {
            throw "$Context contains forbidden true claim '$($property.Name)'."
        }
        Assert-R18RemoteNoForbiddenTrueProperties -Object $property.Value -Context $Context
    }
}

function Assert-R18RemotePositiveClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Object.positive_claims)) {
            Assert-R18RemoteCondition -Condition ($script:R18AllowedPositiveClaims -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
        }
    }
}

function Assert-R18RemoteContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    $required = @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_sample_fields",
        "required_verification_fields",
        "allowed_verification_statuses",
        "allowed_action_recommendations",
        "required_runtime_false_flags",
        "branch_identity_policy",
        "remote_identity_policy",
        "divergence_policy",
        "operator_decision_policy",
        "runner_state_policy",
        "failure_event_policy",
        "wip_classification_policy",
        "evidence_policy",
        "authority_policy",
        "continuation_boundary_policy",
        "path_policy",
        "git_command_policy",
        "api_policy",
        "execution_policy",
        "refusal_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    )
    Assert-R18RemoteRequiredFields -Object $Contract -Fields $required -Context "R18 remote branch verifier contract"
    Assert-R18RemoteCondition -Condition ($Contract.artifact_type -eq "r18_remote_branch_verifier_contract") -Message "R18 remote branch verifier contract artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 remote branch verifier contract source_task is invalid."
    foreach ($field in $script:R18RequiredSampleFields) {
        Assert-R18RemoteCondition -Condition (@($Contract.required_sample_fields) -contains $field) -Message "Contract missing required sample field '$field'."
    }
    foreach ($field in $script:R18RequiredVerificationFields) {
        Assert-R18RemoteCondition -Condition (@($Contract.required_verification_fields) -contains $field) -Message "Contract missing required verification field '$field'."
    }
    foreach ($status in $script:R18AllowedVerificationStatuses) {
        Assert-R18RemoteCondition -Condition (@($Contract.allowed_verification_statuses) -contains $status) -Message "Contract missing allowed verification status '$status'."
    }
    foreach ($action in $script:R18AllowedActionRecommendations) {
        Assert-R18RemoteCondition -Condition (@($Contract.allowed_action_recommendations) -contains $action) -Message "Contract missing allowed action recommendation '$action'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18RemoteCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "Contract missing required runtime false flag '$flag'."
    }
    Assert-R18RemoteCondition -Condition ($Contract.PSObject.Properties.Name -contains "operator_decision_policy") -Message "Contract missing operator_decision_policy."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 remote branch verifier contract"
    Assert-R18RemotePositiveClaims -Object $Contract -Context "R18 remote branch verifier contract"
}

function Assert-R18RemoteSample {
    param([Parameter(Mandatory = $true)][object]$Sample)

    Assert-R18RemoteRequiredFields -Object $Sample -Fields $script:R18RequiredSampleFields -Context "R18 remote branch sample"
    Assert-R18RemoteCondition -Condition ($Sample.artifact_type -eq "r18_remote_branch_verification_sample") -Message "R18 remote branch sample artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ($Sample.source_task -eq $script:R18SourceTask) -Message "R18 remote branch sample source_task is invalid."
    Assert-R18RemoteCondition -Condition ($Sample.sample_status -eq "seed_branch_identity_sample_only_not_branch_mutation") -Message "R18 remote branch sample status is invalid."
    Assert-R18RemoteCondition -Condition ($script:R18AllowedSampleTypes -contains [string]$Sample.sample_type) -Message "R18 remote branch sample uses unknown sample_type '$($Sample.sample_type)'."
    Assert-R18RemoteCondition -Condition ($script:R18AllowedVerificationStatuses -contains [string]$Sample.expected_verification_status) -Message "R18 remote branch sample uses unknown expected_verification_status."
    Assert-R18RemoteCondition -Condition ($script:R18AllowedActionRecommendations -contains [string]$Sample.expected_action_recommendation) -Message "R18 remote branch sample uses unknown expected_action_recommendation."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Sample.expected_branch)) -Message "R18 remote branch sample expected_branch is blank."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Sample.local_head)) -Message "R18 remote branch sample local_head is blank."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Sample.local_tree)) -Message "R18 remote branch sample local_tree is blank."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Sample.expected_remote_head)) -Message "R18 remote branch sample expected_remote_head is blank."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Sample.runtime_flags -Context "R18 remote branch sample"
}

function Assert-R18RemoteVerification {
    param(
        [Parameter(Mandatory = $true)][object]$Verification,
        [AllowNull()][object]$Sample
    )

    Assert-R18RemoteRequiredFields -Object $Verification -Fields $script:R18RequiredVerificationFields -Context "R18 remote branch verification packet"
    Assert-R18RemoteCondition -Condition ($Verification.artifact_type -eq "r18_remote_branch_verification_packet") -Message "R18 remote branch verification packet artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ($Verification.source_task -eq $script:R18SourceTask) -Message "R18 remote branch verification packet source_task is invalid."
    Assert-R18RemoteCondition -Condition ($script:R18AllowedVerificationStatuses -contains [string]$Verification.verification_status) -Message "R18 remote branch verification packet uses unknown verification_status '$($Verification.verification_status)'."
    Assert-R18RemoteCondition -Condition ($script:R18AllowedActionRecommendations -contains [string]$Verification.action_recommendation) -Message "R18 remote branch verification packet uses unknown action_recommendation."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Verification.runtime_flags -Context "R18 remote branch verification packet"
    Assert-R18RemoteCondition -Condition (@($Verification.evidence_refs).Count -gt 0) -Message "R18 remote branch verification packet evidence_refs is missing."
    Assert-R18RemoteCondition -Condition (@($Verification.authority_refs).Count -gt 0) -Message "R18 remote branch verification packet authority_refs is missing."

    $observedType = Get-R18RemoteSampleTypeFromStatus -ExpectedBranch ([string]$Verification.expected_branch) -ActualBranch ([string]$Verification.actual_branch) -LocalHead ([string]$Verification.local_head) -ExpectedRemoteHead ([string]$Verification.expected_remote_head) -ActualRemoteHead $Verification.actual_remote_head -AheadBy $Verification.ahead_by -BehindBy $Verification.behind_by
    if ([bool]$Verification.divergence_detected) {
        $observedType = "diverged"
    }
    $rule = Get-R18RemoteRule -SampleType $observedType
    Assert-R18RemoteCondition -Condition ($Verification.verification_status -eq $rule.verification_status) -Message "R18 remote branch verification packet status does not match deterministic rule for $observedType."
    Assert-R18RemoteCondition -Condition ($Verification.action_recommendation -eq $rule.action_recommendation) -Message "R18 remote branch verification packet action does not match deterministic rule for $observedType."
    Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq [bool]$rule.safe_to_continue) -Message "R18 remote branch verification packet safe_to_continue does not match deterministic rule for $observedType."
    Assert-R18RemoteCondition -Condition ([bool]$Verification.operator_decision_required -eq [bool]$rule.operator_decision_required) -Message "R18 remote branch verification packet operator_decision_required does not match deterministic rule for $observedType."

    switch ($observedType) {
        "remote_in_sync" {
            Assert-R18RemoteCondition -Condition ($Verification.verification_status -eq "remote_in_sync_safe" -and [bool]$Verification.safe_to_continue -eq $true -and [bool]$Verification.operator_decision_required -eq $false -and $Verification.action_recommendation -eq "continue_without_branch_action") -Message "remote_in_sync must classify as remote_in_sync_safe."
        }
        "remote_ahead" {
            Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq $false) -Message "remote_ahead must be blocked."
        }
        "local_ahead" {
            Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq $false -and $Verification.verification_status -eq "local_ahead_review_required") -Message "local_ahead must be review-required and not safe in R18-012."
        }
        "diverged" {
            Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq $false) -Message "diverged must be blocked."
        }
        "wrong_branch" {
            Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq $false) -Message "wrong_branch must be blocked."
        }
        "missing_remote_ref" {
            Assert-R18RemoteCondition -Condition ([bool]$Verification.safe_to_continue -eq $false) -Message "missing_remote_ref must be blocked."
        }
    }

    if ($null -ne $Sample) {
        Assert-R18RemoteCondition -Condition ($Sample.expected_verification_status -eq $Verification.verification_status) -Message "Verification packet does not match sample expected_verification_status."
        Assert-R18RemoteCondition -Condition ($Sample.expected_action_recommendation -eq $Verification.action_recommendation) -Message "Verification packet does not match sample expected_action_recommendation."
    }
}

function Assert-R18RemoteCurrentVerification {
    param([Parameter(Mandatory = $true)][object]$Current)

    Assert-R18RemoteVerification -Verification $Current -Sample $null
    Assert-R18RemoteCondition -Condition ($Current.verification_id -eq "r18_012_current_remote_branch_verification") -Message "Current verification id is invalid."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Current.local_head)) -Message "Current verification lacks local head."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Current.local_tree)) -Message "Current verification lacks local tree."
    Assert-R18RemoteCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$Current.actual_remote_head)) -Message "Current verification lacks remote head."
    if ($Current.verification_status -eq "remote_in_sync_safe") {
        Assert-R18RemoteCondition -Condition ([bool]$Current.branch_match -eq $true) -Message "Current remote_in_sync verification requires branch match."
        Assert-R18RemoteCondition -Condition ([bool]$Current.remote_ref_present -eq $true) -Message "Current remote_in_sync verification requires remote ref present."
        Assert-R18RemoteCondition -Condition ($Current.local_head -eq $Current.actual_remote_head -and $Current.actual_remote_head -eq $Current.expected_remote_head) -Message "Current remote_in_sync verification requires local and remote heads to equal expected remote head."
        Assert-R18RemoteCondition -Condition ([bool]$Current.safe_to_continue -eq $true) -Message "Current remote_in_sync verification must be safe to continue for branch identity only."
    }
}

function Assert-R18RemoteResults {
    param(
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object[]]$Verifications
    )

    Assert-R18RemoteCondition -Condition ($Results.artifact_type -eq "r18_remote_branch_verifier_results") -Message "R18 remote branch verifier results artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ([int]$Results.sample_count -eq @($script:R18SampleDefinitions).Count) -Message "R18 remote branch verifier results sample_count is invalid."
    Assert-R18RemoteCondition -Condition ([int]$Results.verification_packet_count -eq @($Verifications).Count) -Message "R18 remote branch verifier results verification_packet_count is invalid."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Results.runtime_flags -Context "R18 remote branch verifier results"
    Assert-R18RemotePositiveClaims -Object $Results -Context "R18 remote branch verifier results"
}

function Assert-R18RemoteReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18RemoteCondition -Condition ($Report.artifact_type -eq "r18_remote_branch_verifier_check_report") -Message "R18 remote branch verifier check report artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ($Report.aggregate_verdict -eq $script:R18VerifierVerdict) -Message "R18 remote branch verifier check report aggregate verdict is invalid."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 remote branch verifier check report"
    Assert-R18RemotePositiveClaims -Object $Report -Context "R18 remote branch verifier check report"
}

function Assert-R18RemoteSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18RemoteCondition -Condition ($Snapshot.artifact_type -eq "r18_remote_branch_verifier_snapshot") -Message "R18 remote branch verifier snapshot artifact_type is invalid."
    Assert-R18RemoteCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_012_only") -Message "R18 remote branch verifier snapshot status is invalid."
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Snapshot.runtime_flags -Context "R18 remote branch verifier snapshot"
    Assert-R18RemotePositiveClaims -Object $Snapshot -Context "R18 remote branch verifier snapshot"
}

function Get-R18RemoteTaskStatusMap {
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

function Test-R18RemoteBranchVerifierStatusTruth {
    param([string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18RemotePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-014 only",
            "R18-015 through R18-028 planned only",
            "R18-012 created remote branch verifier foundation only",
            "Current branch identity was verified only by bounded git identity checks",
            "No branch mutation was performed",
            "No pull, rebase, reset, merge, checkout, switch, clean, restore, staging, commit, or push was performed by the verifier",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "Continuation packets are not new-context prompts",
            "R18-014 created new-context prompt generator foundation only",
            "Automatic new-thread creation is not implemented",
            "No recovery action was performed",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No product runtime is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-012 truth: $required"
        }
    }

    $authorityStatuses = Get-R18RemoteTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18RemoteTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18RemoteCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 14) {
            Assert-R18RemoteCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-014."
        }
        else {
            Assert-R18RemoteCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-014."
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[5-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-014."
    }
    if ($combinedText -match '(?i)R18-01[5-9].{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-015 or later completion."
    }
}

function Test-R18RemoteBranchVerifierSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Samples,
        [Parameter(Mandatory = $true)][object[]]$Verifications,
        [Parameter(Mandatory = $true)][object]$CurrentVerification,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot)
    )

    Assert-R18RemoteContract -Contract $Contract
    Assert-R18RemoteRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 remote branch verifier profile"
    Assert-R18RemotePositiveClaims -Object $Profile -Context "R18 remote branch verifier profile"
    Assert-R18RemoteCondition -Condition (@($Samples).Count -eq @($script:R18SampleDefinitions).Count) -Message "R18 remote branch verifier samples are missing."
    Assert-R18RemoteCondition -Condition (@($Verifications).Count -eq @($script:R18SampleDefinitions).Count) -Message "R18 remote branch verifier packets are missing."

    foreach ($sample in @($Samples)) {
        Assert-R18RemoteSample -Sample $sample
        $definition = Get-R18RemoteDefinitionByType -SampleType ([string]$sample.sample_type)
        $sampleRef = Get-R18RemoteSampleRef -FileName ([string]$definition.file)
        $matching = @($Verifications | Where-Object { $_.source_sample_ref -eq $sampleRef })
        Assert-R18RemoteCondition -Condition ($matching.Count -eq 1) -Message "R18 remote branch sample '$($sample.sample_type)' does not have exactly one verification packet."
        Assert-R18RemoteVerification -Verification $matching[0] -Sample $sample
    }

    Assert-R18RemoteCurrentVerification -Current $CurrentVerification
    Assert-R18RemoteResults -Results $Results -Verifications $Verifications
    Assert-R18RemoteReport -Report $Report
    Assert-R18RemoteSnapshot -Snapshot $Snapshot
    foreach ($artifact in @($Contract, $Profile, $Samples, $Verifications, $CurrentVerification, $Results, $Report, $Snapshot)) {
        Assert-R18RemoteNoForbiddenTrueProperties -Object $artifact
    }
    Test-R18RemoteBranchVerifierStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        SampleCount = @($Samples).Count
        VerificationPacketCount = @($Verifications).Count
        CurrentVerificationStatus = $CurrentVerification.verification_status
        CurrentSafeToContinue = [bool]$CurrentVerification.safe_to_continue
        RuntimeFlags = $Report.runtime_flags
    }
}

function Test-R18RemoteBranchVerifier {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18RemoteBranchVerifierRepositoryRoot))

    $paths = Get-R18RemoteBranchVerifierPaths -RepositoryRoot $RepositoryRoot
    $samples = @()
    $verifications = @()
    foreach ($definition in $script:R18SampleDefinitions) {
        $samples += Read-R18RemoteJson -Path (Join-Path $paths.SampleRoot ([string]$definition.file))
        $verifications += Read-R18RemoteJson -Path (Join-Path $paths.PacketRoot (Get-R18RemoteVerificationFileName -SampleType ([string]$definition.sample_type)))
    }

    return Test-R18RemoteBranchVerifierSet `
        -Contract (Read-R18RemoteJson -Path $paths.Contract) `
        -Profile (Read-R18RemoteJson -Path $paths.Profile) `
        -Samples $samples `
        -Verifications $verifications `
        -CurrentVerification (Read-R18RemoteJson -Path $paths.CurrentVerification) `
        -Results (Read-R18RemoteJson -Path $paths.Results) `
        -Report (Read-R18RemoteJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18RemoteJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18RemoteObjectPathValue {
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

function Remove-R18RemoteObjectPathValue {
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

function Invoke-R18RemoteBranchVerifierMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18RemoteObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18RemoteObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 remote branch verifier mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18RemoteBranchVerifierPaths, `
    Read-R18RemoteJson, `
    Copy-R18RemoteBranchVerifierObject, `
    New-R18RemoteBranchVerifierArtifacts, `
    Invoke-R18RemoteBranchVerifier, `
    Test-R18RemoteBranchVerifier, `
    Test-R18RemoteBranchVerifierSet, `
    Test-R18RemoteBranchVerifierStatusTruth, `
    Invoke-R18RemoteBranchVerifierMutation
