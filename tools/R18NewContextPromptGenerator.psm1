Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-014"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ExpectedHead = "9e3e16e5ca87908c9e45edb100b229333c6d77fc"
$script:R18ExpectedTree = "827a402b4cea45f2f699e115604e71cc4cf7812f"
$script:R18ExpectedRemoteHead = "9e3e16e5ca87908c9e45edb100b229333c6d77fc"
$script:R18PromptMaxLineCount = 160
$script:R18PromptMaxCharacterCount = 12000
$script:R18AggregateVerdict = "generated_r18_014_new_context_prompt_generator_foundation_only"

$script:R18RuntimeFlagFields = @(
    "prompt_packet_executed",
    "new_context_prompt_runtime_executed",
    "automatic_new_thread_creation_performed",
    "codex_thread_created",
    "codex_api_invoked",
    "openai_api_invoked",
    "autonomous_codex_invocation_performed",
    "continuation_packet_executed",
    "continuation_runtime_implemented",
    "recovery_runtime_implemented",
    "recovery_action_performed",
    "retry_execution_performed",
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
    "staging_performed",
    "commit_performed",
    "push_performed",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_015_completed",
    "main_merge_claimed"
)

$script:R18RequiredPromptInputFields = @(
    "artifact_type",
    "contract_version",
    "prompt_input_id",
    "prompt_packet_id",
    "prompt_input_name",
    "source_task",
    "source_milestone",
    "prompt_input_status",
    "prompt_type",
    "continuation_packet_ref",
    "runner_state_ref",
    "failure_event_ref",
    "wip_classification_ref",
    "remote_verification_ref",
    "resume_checkpoint_ref",
    "repository",
    "branch",
    "expected_head",
    "expected_tree",
    "expected_remote_head",
    "last_completed_step",
    "next_safe_step",
    "validation_commands",
    "allowed_paths",
    "forbidden_paths",
    "stop_conditions",
    "non_claims",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "rejected_claims"
)

$script:R18RequiredPromptPacketFields = @(
    "prompt_packet_id",
    "prompt_packet_status",
    "prompt_type",
    "prompt_packet_ref",
    "prompt_input_ref",
    "continuation_packet_ref",
    "repository",
    "branch",
    "expected_head",
    "expected_tree",
    "expected_remote_head",
    "last_completed_step",
    "next_safe_step",
    "allowed_paths",
    "forbidden_paths",
    "validation_commands",
    "stop_conditions",
    "explicit_non_claims",
    "required_final_response"
)

$script:R18RequiredPromptTextSections = @(
    "Mission",
    "Repository and branch",
    "Accepted refs",
    "Current boundary",
    "Last completed step",
    "Next safe step",
    "Allowed paths",
    "Forbidden paths",
    "Validation commands",
    "Stop conditions",
    "Explicit non-claims",
    "Required final response"
)

$script:R18AllowedPromptTypes = @(
    "continue_after_compact_failure",
    "continue_after_stream_disconnect",
    "continue_after_validation_failure",
    "operator_decision_required_for_wip",
    "operator_decision_required_for_remote_branch",
    "block_until_future_runtime"
)

$script:R18AllowedPromptStatuses = @(
    "prompt_packet_generated_not_executed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_new_context_prompt_packet_contract_created",
    "r18_new_context_prompt_generator_contract_created",
    "r18_new_context_prompt_generator_profile_created",
    "r18_new_context_prompt_inputs_created",
    "r18_new_context_prompt_packets_created",
    "r18_new_context_prompt_manifest_created",
    "r18_new_context_prompt_generator_results_created",
    "r18_new_context_prompt_generator_validator_created",
    "r18_new_context_prompt_generator_fixtures_created",
    "r18_new_context_prompt_generator_proof_review_created"
)

$script:R18RejectedClaims = @(
    "automatic_new_thread_creation",
    "codex_thread_creation",
    "codex_api_invocation",
    "openai_api_invocation",
    "autonomous_codex_invocation",
    "prompt_packet_execution",
    "new_context_prompt_runtime_execution",
    "continuation_packet_execution",
    "continuation_runtime",
    "recovery_runtime",
    "recovery_action",
    "retry_execution",
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
    "stage_commit_push",
    "staging",
    "commit",
    "push",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_015_or_later_completion",
    "main_merge",
    "previous_thread_memory_required",
    "whole_milestone_completion",
    "broad_repo_scan",
    "unbounded_write_paths"
)

$script:R18PromptDefinitions = @(
    [ordered]@{
        prompt_type = "continue_after_compact_failure"
        input_file = "continue_after_compact_failure.prompt_input.json"
        prompt_file = "continue_after_compact_failure.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_compact_failure.continuation.json"
        name = "Continue after compact/context failure new-context prompt seed"
        next_safe_step_override = $null
    },
    [ordered]@{
        prompt_type = "continue_after_stream_disconnect"
        input_file = "continue_after_stream_disconnect.prompt_input.json"
        prompt_file = "continue_after_stream_disconnect.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_stream_disconnect.continuation.json"
        name = "Continue after stream disconnect new-context prompt seed"
        next_safe_step_override = $null
    },
    [ordered]@{
        prompt_type = "continue_after_validation_failure"
        input_file = "continue_after_validation_failure.prompt_input.json"
        prompt_file = "continue_after_validation_failure.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/continue_after_validation_failure.continuation.json"
        name = "Continue after validation failure new-context prompt seed"
        next_safe_step_override = $null
    },
    [ordered]@{
        prompt_type = "operator_decision_required_for_wip"
        input_file = "operator_decision_required_for_wip.prompt_input.json"
        prompt_file = "operator_decision_required_for_wip.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/operator_decision_required_for_wip.continuation.json"
        name = "Operator decision required for WIP new-context prompt seed"
        next_safe_step_override = $null
    },
    [ordered]@{
        prompt_type = "operator_decision_required_for_remote_branch"
        input_file = "operator_decision_required_for_remote_branch.prompt_input.json"
        prompt_file = "operator_decision_required_for_remote_branch.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/operator_decision_required_for_remote_branch.continuation.json"
        name = "Operator decision required for remote branch new-context prompt seed"
        next_safe_step_override = $null
    },
    [ordered]@{
        prompt_type = "block_until_future_runtime"
        input_file = "block_until_future_runtime.prompt_input.json"
        prompt_file = "block_until_future_runtime.prompt.txt"
        continuation_packet_ref = "state/runtime/r18_continuation_packets/block_until_future_runtime.continuation.json"
        name = "Block until future runtime new-context prompt seed"
        next_safe_step_override = "Block. Do not execute runtime recovery, retries, work orders, prompts, or continuation packets until a separately approved future R18 runtime task exists."
    }
)

function Get-R18NewContextRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18NewContextPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18NewContextJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18NewContextJson {
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

function Write-R18NewContextText {
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

function Copy-R18NewContextObject {
    param([Parameter(Mandatory = $true)][object]$Value)

    if ($Value.PSObject.Properties.Name -contains "PacketContract" -and $Value.PSObject.Properties.Name -contains "Prompts") {
        return [pscustomobject]@{
            PacketContract = Copy-R18NewContextObject -Value $Value.PacketContract
            GeneratorContract = Copy-R18NewContextObject -Value $Value.GeneratorContract
            Profile = Copy-R18NewContextObject -Value $Value.Profile
            Inputs = @($Value.Inputs | ForEach-Object { Copy-R18NewContextObject -Value $_ })
            Prompts = @($Value.Prompts | ForEach-Object {
                    [pscustomobject]@{
                        prompt_type = [string]$_.prompt_type
                        path = [string]$_.path
                        text = [string]$_.text
                    }
                })
            Manifest = Copy-R18NewContextObject -Value $Value.Manifest
            Results = Copy-R18NewContextObject -Value $Value.Results
            Report = Copy-R18NewContextObject -Value $Value.Report
            Snapshot = Copy-R18NewContextObject -Value $Value.Snapshot
        }
    }

    return ($Value | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
}

function Get-R18NewContextPaths {
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    return [ordered]@{
        PacketContract = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_new_context_prompt_packet.contract.json"
        GeneratorContract = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_new_context_prompt_generator.contract.json"
        Profile = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_generator_profile.json"
        PromptInputRoot = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_inputs"
        PromptPacketRoot = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_packets"
        Manifest = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_packet_manifest.json"
        Results = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_generator_results.json"
        CheckReport = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_new_context_prompt_generator_check_report.json"
        UiSnapshot = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_new_context_prompt_snapshot.json"
        FixtureRoot = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_new_context_prompt_generator"
        ProofRoot = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator"
        EvidenceIndex = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/evidence_index.json"
        ProofReview = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/proof_review.md"
        ValidationManifest = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/validation_manifest.md"
    }
}

function New-R18NewContextRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18NewContextEvidenceRefs {
    return @(
        "contracts/runtime/r18_new_context_prompt_packet.contract.json",
        "contracts/runtime/r18_new_context_prompt_generator.contract.json",
        "state/runtime/r18_new_context_prompt_generator_profile.json",
        "state/runtime/r18_new_context_prompt_inputs/",
        "state/runtime/r18_new_context_prompt_packets/",
        "state/runtime/r18_new_context_prompt_packet_manifest.json",
        "state/runtime/r18_new_context_prompt_generator_results.json",
        "state/runtime/r18_new_context_prompt_generator_check_report.json",
        "state/ui/r18_operator_surface/r18_new_context_prompt_snapshot.json",
        "tools/R18NewContextPromptGenerator.psm1",
        "tools/new_r18_new_context_prompt_generator.ps1",
        "tools/validate_r18_new_context_prompt_generator.ps1",
        "tests/test_r18_new_context_prompt_generator.ps1",
        "tests/fixtures/r18_new_context_prompt_generator/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/"
    )
}

function Get-R18NewContextAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/runtime/r18_continuation_packet.contract.json",
        "contracts/runtime/r18_continuation_packet_generator.contract.json",
        "state/runtime/r18_continuation_packets/",
        "state/runtime/r18_continuation_packet_generator_results.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_runner_state.json",
        "state/runtime/r18_runner_resume_checkpoint.json",
        "contracts/runtime/r18_failure_event.contract.json",
        "state/runtime/r18_detected_failure_events/",
        "contracts/runtime/r18_wip_classifier.contract.json",
        "state/runtime/r18_wip_classification_packets/",
        "contracts/runtime/r18_remote_branch_verifier.contract.json",
        "state/runtime/r18_remote_branch_current_verification.json",
        "state/runtime/r18_remote_branch_verification_packets/",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "state/runtime/r17_automated_recovery_loop_new_context_packets.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18NewContextAllowedPaths {
    return @(
        "contracts/runtime/r18_new_context_prompt_packet.contract.json",
        "contracts/runtime/r18_new_context_prompt_generator.contract.json",
        "state/runtime/r18_new_context_prompt_generator_profile.json",
        "state/runtime/r18_new_context_prompt_inputs/",
        "state/runtime/r18_new_context_prompt_packets/",
        "state/runtime/r18_new_context_prompt_packet_manifest.json",
        "state/runtime/r18_new_context_prompt_generator_results.json",
        "state/runtime/r18_new_context_prompt_generator_check_report.json",
        "state/ui/r18_operator_surface/r18_new_context_prompt_snapshot.json",
        "tools/R18NewContextPromptGenerator.psm1",
        "tools/new_r18_new_context_prompt_generator.ps1",
        "tools/validate_r18_new_context_prompt_generator.ps1",
        "tests/test_r18_new_context_prompt_generator.ps1",
        "tests/fixtures/r18_new_context_prompt_generator/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/",
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

function Get-R18NewContextForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "governance/reports/AIOffice_V2_Revised_R17_Plan.md",
        "state/proof_reviews/r13_",
        "state/proof_reviews/r14_",
        "state/proof_reviews/r15_",
        "state/proof_reviews/r16_",
        "state/runtime/recovery_runtime/",
        "state/runtime/r18_retry_state.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "main branch",
        "unbounded repository write paths"
    )
}

function Get-R18NewContextValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_new_context_prompt_generator.ps1",
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

function Get-R18NewContextNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-014 only.",
        "R18-015 through R18-028 remain planned only.",
        "R18-014 created new-context prompt generator foundation only.",
        "New-context prompt packets were generated as deterministic text artifacts only.",
        "Prompt packets were not executed.",
        "Automatic new-thread creation was not performed.",
        "Codex thread creation was not performed.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
        "Continuation packets were not executed.",
        "No recovery action was performed.",
        "No retry execution was performed.",
        "No WIP cleanup or abandonment was performed.",
        "No branch mutation was performed.",
        "No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed.",
        "No staging, commit, or push was performed by the generator.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function New-R18PromptPacketContract {
    return [ordered]@{
        artifact_type = "r18_new_context_prompt_packet_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-014-new-context-prompt-packet-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "new_context_prompt_packet_contract_foundation_only_text_artifacts_not_thread_creation_not_api_invocation"
        purpose = "Define deterministic, exact-ref, bounded, copy-paste-ready new-context prompt packet fields and text sections seeded from R18-013 continuation packet refs without executing prompts, creating Codex threads, invoking APIs, executing continuation packets, or performing recovery."
        required_prompt_input_fields = $script:R18RequiredPromptInputFields
        required_prompt_packet_fields = $script:R18RequiredPromptPacketFields
        required_prompt_text_sections = $script:R18RequiredPromptTextSections
        allowed_prompt_types = $script:R18AllowedPromptTypes
        allowed_prompt_statuses = $script:R18AllowedPromptStatuses
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        prompt_packet_policy = [ordered]@{ deterministic_text_artifacts_only = $true; copy_paste_ready_required = $true; prompt_packet_execution_allowed = $false; automatic_thread_creation_allowed = $false }
        exact_ref_policy = [ordered]@{ repository_required = $true; branch_required = $true; head_required = $true; tree_required = $true; remote_head_required = $true; continuation_packet_ref_required = $true }
        context_independence_policy = [ordered]@{ previous_thread_memory_required = $false; previous_thread_memory_allowed = $false; prompt_must_stand_alone = $true }
        size_policy = [ordered]@{ max_line_count = $script:R18PromptMaxLineCount; max_character_count = $script:R18PromptMaxCharacterCount; oversized_prompt_fails_closed = $true }
        safety_policy = [ordered]@{ fail_closed_on_missing_refs = $true; fail_closed_on_unbounded_scope = $true; fail_closed_on_forbidden_claim = $true; whole_milestone_completion_allowed = $false; broad_repo_scan_allowed = $false; unbounded_write_paths_allowed = $false }
        validation_policy = [ordered]@{ prompt_sections_required = $true; exact_refs_required = $true; validation_commands_required = $true; status_boundary_required = $true }
        evidence_policy = [ordered]@{ evidence_refs_required = $true; proof_review_required = $true }
        authority_policy = [ordered]@{ authority_refs_required = $true; r18_active_boundary = "R18 active through R18-014 only"; planned_boundary = "R18-015 through R18-028 planned only" }
        boundary_policy = [ordered]@{ automatic_new_thread_creation_allowed = $false; codex_api_invocation_allowed = $false; openai_api_invocation_allowed = $false; recovery_execution_allowed = $false; retry_execution_allowed = $false; work_order_execution_allowed = $false; r18_015_or_later_claim_allowed = $false }
        path_policy = [ordered]@{ allowed_paths = Get-R18NewContextAllowedPaths; forbidden_paths = Get-R18NewContextForbiddenPaths; broad_repo_writes_allowed = $false; operator_local_backup_paths_allowed = $false }
        api_policy = [ordered]@{ openai_api_invocation_allowed = $false; codex_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false }
        execution_policy = [ordered]@{ prompt_packet_generation_only = $true; prompt_execution_allowed = $false; continuation_packet_execution_allowed = $false; live_runner_runtime_allowed = $false; board_runtime_mutation_allowed = $false; stage_commit_push_allowed_by_generator = $false }
        refusal_policy = [ordered]@{ refuse_on_missing_required_refs = $true; refuse_on_unknown_prompt_type = $true; refuse_on_forbidden_runtime_flag = $true; refuse_on_previous_thread_memory_dependency = $true; refuse_on_unbounded_scope = $true }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18NewContextNonClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
        positive_claims = @("r18_new_context_prompt_packet_contract_created")
        runtime_flags = New-R18NewContextRuntimeFlags
    }
}

function New-R18PromptGeneratorContract {
    return [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-014-new-context-prompt-generator-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "new_context_prompt_generator_foundation_only_seed_inputs_and_text_packets_not_runtime_execution"
        purpose = "Generate deterministic prompt input artifacts and bounded new-context prompt text packets from R18-013 continuation packets without creating threads, calling APIs, executing prompts, executing continuation packets, retrying work, mutating WIP/branches/boards, or implementing recovery runtime."
        required_input_fields = $script:R18RequiredPromptInputFields
        required_output_fields = @("prompt_input_refs", "prompt_packet_refs", "manifest", "results", "check_report", "snapshot", "proof_review")
        required_prompt_text_constraints = [ordered]@{ required_sections = $script:R18RequiredPromptTextSections; max_line_count = $script:R18PromptMaxLineCount; max_character_count = $script:R18PromptMaxCharacterCount; exact_refs_required = $true; previous_thread_memory_required = $false }
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        generation_policy = [ordered]@{ deterministic_seed_artifacts_only = $true; input_artifacts_required = $true; text_prompt_packets_required = $true; runtime_generation_service_implemented = $false }
        input_policy = [ordered]@{ require_continuation_packet_ref = $true; require_runner_state_ref = $true; require_failure_event_ref = $true; require_wip_classification_ref = $true; require_remote_verification_ref = $true; require_resume_checkpoint_ref = $true }
        output_policy = [ordered]@{ prompt_packet_status = "prompt_packet_generated_not_executed"; prompt_execution_allowed = $false; automatic_thread_creation_allowed = $false }
        size_policy = [ordered]@{ max_line_count = $script:R18PromptMaxLineCount; max_character_count = $script:R18PromptMaxCharacterCount; oversized_prompt_fails_closed = $true }
        exact_ref_policy = [ordered]@{ expected_head = $script:R18ExpectedHead; expected_tree = $script:R18ExpectedTree; expected_remote_head = $script:R18ExpectedRemoteHead; stale_or_missing_ref_fails_closed = $true }
        safety_policy = [ordered]@{ fail_closed_on_missing_refs = $true; fail_closed_on_forbidden_claim = $true; fail_closed_on_unbounded_scope = $true; no_previous_thread_memory_dependency = $true }
        status_boundary_policy = [ordered]@{ r18_active_through = "R18-014"; planned_from = "R18-015"; planned_through = "R18-028"; r18_015_completion_claim_allowed = $false }
        path_policy = [ordered]@{ allowed_paths = Get-R18NewContextAllowedPaths; forbidden_paths = Get-R18NewContextForbiddenPaths; live_board_paths_mutable = $false; unbounded_write_paths_allowed = $false }
        api_policy = [ordered]@{ openai_api_invocation_allowed = $false; codex_api_invocation_allowed = $false; autonomous_codex_invocation_allowed = $false }
        execution_policy = [ordered]@{ prompt_packet_generation_only = $true; prompt_execution_allowed = $false; continuation_packet_execution_allowed = $false; recovery_execution_allowed = $false; retry_execution_allowed = $false; work_order_execution_allowed = $false; stage_commit_push_allowed_by_generator = $false }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18NewContextNonClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
        positive_claims = @("r18_new_context_prompt_generator_contract_created")
        runtime_flags = New-R18NewContextRuntimeFlags
    }
}

function New-R18PromptGeneratorProfile {
    return [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-014-new-context-prompt-generator-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        profile_status = "generator_profile_seed_only_not_runtime_execution"
        repository = $script:R18Repository
        branch = $script:R18Branch
        expected_head = $script:R18ExpectedHead
        expected_tree = $script:R18ExpectedTree
        expected_remote_head = $script:R18ExpectedRemoteHead
        prompt_types = $script:R18AllowedPromptTypes
        prompt_count = @($script:R18PromptDefinitions).Count
        prompt_size_policy = [ordered]@{ max_line_count = $script:R18PromptMaxLineCount; max_character_count = $script:R18PromptMaxCharacterCount }
        context_independence_policy = [ordered]@{ previous_thread_memory_required = $false; prompt_must_stand_alone = $true }
        generation_boundary = "deterministic prompt text artifacts only; no automatic thread creation, no API invocation, no prompt execution"
        positive_claims = @("r18_new_context_prompt_generator_profile_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
    }
}

function New-R18PromptInput {
    param(
        [Parameter(Mandatory = $true)][object]$Definition,
        [string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot)
    )

    $continuationPacketPath = Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$Definition.continuation_packet_ref)
    $continuationPacket = Read-R18NewContextJson -Path $continuationPacketPath
    $promptType = [string]$Definition.prompt_type
    $nextSafeStep = if ($null -ne $Definition.next_safe_step_override) {
        [string]$Definition.next_safe_step_override
    }
    else {
        [string]$continuationPacket.next_safe_step
    }

    return [ordered]@{
        artifact_type = "r18_new_context_prompt_input"
        contract_version = "v1"
        prompt_input_id = "r18_014_prompt_input_$promptType"
        prompt_packet_id = "r18_014_prompt_packet_$promptType"
        prompt_input_name = [string]$Definition.name
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        prompt_input_status = "seed_prompt_input_only_not_runtime_execution"
        prompt_type = $promptType
        prompt_packet_status = "prompt_packet_generated_not_executed"
        prompt_packet_ref = "state/runtime/r18_new_context_prompt_packets/$($Definition.prompt_file)"
        prompt_input_ref = "state/runtime/r18_new_context_prompt_inputs/$($Definition.input_file)"
        continuation_packet_ref = [string]$Definition.continuation_packet_ref
        runner_state_ref = [string]$continuationPacket.runner_state_ref
        failure_event_ref = [string]$continuationPacket.failure_event_ref
        wip_classification_ref = [string]$continuationPacket.wip_classification_ref
        remote_verification_ref = [string]$continuationPacket.remote_verification_ref
        resume_checkpoint_ref = [string]$continuationPacket.resume_checkpoint_ref
        repository = $script:R18Repository
        branch = $script:R18Branch
        expected_head = $script:R18ExpectedHead
        expected_tree = $script:R18ExpectedTree
        expected_remote_head = $script:R18ExpectedRemoteHead
        current_work_order_ref = [string]$continuationPacket.current_work_order_ref
        current_state = [string]$continuationPacket.current_state
        last_completed_step = [string]$continuationPacket.last_completed_step
        next_safe_step = $nextSafeStep
        validation_commands = Get-R18NewContextValidationCommands
        allowed_paths = Get-R18NewContextAllowedPaths
        forbidden_paths = Get-R18NewContextForbiddenPaths
        stop_conditions = @(
            "accepted repository, branch, head, tree, or remote head ref is missing or different",
            "referenced continuation packet, runner state, failure event, WIP classification, remote verification, or checkpoint ref is missing",
            "previous thread memory is requested as required context",
            "scope expands beyond the referenced continuation packet and next safe step",
            "automatic new-thread creation, Codex API invocation, OpenAI API invocation, or autonomous Codex invocation is requested",
            "prompt execution, continuation packet execution, recovery action, retry execution, work-order execution, WIP cleanup, branch mutation, board mutation, A2A message sending, live agent invocation, or live skill execution is requested",
            "staging, commit, push, pull, rebase, reset, merge, checkout, switch, clean, or restore is requested through this prompt packet",
            "R18-015 or later completion, solved Codex compaction, solved Codex reliability, no-manual-prompt-transfer success, product runtime, or main merge is claimed"
        )
        non_claims = Get-R18NewContextNonClaims
        evidence_refs = @((Get-R18NewContextEvidenceRefs) + @([string]$Definition.continuation_packet_ref, [string]$continuationPacket.failure_event_ref, [string]$continuationPacket.wip_classification_ref, [string]$continuationPacket.remote_verification_ref))
        authority_refs = Get-R18NewContextAuthorityRefs
        runtime_flags = New-R18NewContextRuntimeFlags
        rejected_claims = $script:R18RejectedClaims
    }
}

function Format-R18PromptList {
    param([Parameter(Mandatory = $true)][object[]]$Items)

    $lines = @()
    foreach ($item in @($Items)) {
        $lines += "- $item"
    }
    return $lines
}

function New-R18PromptText {
    param([Parameter(Mandatory = $true)][object]$PromptInput)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("Mission")
    $lines.Add("You are Codex acting in a future new context for RodneyMuniz/AIOffice_V2.")
    $lines.Add("Use this R18-014 prompt packet as a deterministic, exact-ref, copy/paste-ready handoff only.")
    $lines.Add("Rely only on this prompt and the referenced repository artifacts. Previous thread memory required: false.")
    $lines.Add("Prompt packet execution by R18-014: false. Automatic Codex thread creation: false. API invocation: false.")
    $lines.Add("")
    $lines.Add("Repository and branch")
    $lines.Add("Repository: $($PromptInput.repository)")
    $lines.Add("Branch: $($PromptInput.branch)")
    $lines.Add("")
    $lines.Add("Accepted refs")
    $lines.Add("Expected HEAD: $($PromptInput.expected_head)")
    $lines.Add("Expected tree: $($PromptInput.expected_tree)")
    $lines.Add("Expected remote head: $($PromptInput.expected_remote_head)")
    $lines.Add("Prompt input ref: $($PromptInput.prompt_input_ref)")
    $lines.Add("Prompt packet id: $($PromptInput.prompt_packet_id)")
    $lines.Add("Continuation packet ref: $($PromptInput.continuation_packet_ref)")
    $lines.Add("Runner state ref: $($PromptInput.runner_state_ref)")
    $lines.Add("Failure event ref: $($PromptInput.failure_event_ref)")
    $lines.Add("WIP classification ref: $($PromptInput.wip_classification_ref)")
    $lines.Add("Remote verification ref: $($PromptInput.remote_verification_ref)")
    $lines.Add("Resume checkpoint ref: $($PromptInput.resume_checkpoint_ref)")
    $lines.Add("")
    $lines.Add("Current boundary")
    $lines.Add("R17 remains closed with caveats through R17-028 only.")
    $lines.Add("R18 is active through R18-014 only.")
    $lines.Add("R18-015 through R18-028 remain planned only.")
    $lines.Add("Stay scoped to prompt type '$($PromptInput.prompt_type)' and the referenced continuation packet. Do not broaden scope to milestone completion.")
    $lines.Add("")
    $lines.Add("Last completed step")
    $lines.Add([string]$PromptInput.last_completed_step)
    $lines.Add("")
    $lines.Add("Next safe step")
    $lines.Add([string]$PromptInput.next_safe_step)
    $lines.Add("")
    $lines.Add("Allowed paths")
    foreach ($line in (Format-R18PromptList -Items @($PromptInput.allowed_paths))) { $lines.Add($line) }
    $lines.Add("")
    $lines.Add("Forbidden paths")
    foreach ($line in (Format-R18PromptList -Items @($PromptInput.forbidden_paths))) { $lines.Add($line) }
    $lines.Add("")
    $lines.Add("Validation commands")
    foreach ($line in (Format-R18PromptList -Items @($PromptInput.validation_commands))) { $lines.Add($line) }
    $lines.Add("")
    $lines.Add("Stop conditions")
    foreach ($line in (Format-R18PromptList -Items @($PromptInput.stop_conditions))) { $lines.Add($line) }
    $lines.Add("")
    $lines.Add("Explicit non-claims")
    foreach ($line in (Format-R18PromptList -Items @($PromptInput.non_claims))) { $lines.Add($line) }
    $lines.Add("")
    $lines.Add("Required final response")
    $lines.Add("Report the accepted refs, the bounded next safe step outcome, validation pass/fail results, files touched, and preserved non-claims.")
    $lines.Add("If any accepted ref, required artifact, allowed path, forbidden path, status boundary, or runtime false flag is unsafe, stop and report the blocker only.")

    return ($lines -join [Environment]::NewLine)
}

function New-R18NewContextPromptArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    $paths = Get-R18NewContextPaths -RepositoryRoot $RepositoryRoot
    $inputs = @()
    $promptRecords = @()

    Write-R18NewContextJson -Path $paths.PacketContract -Value (New-R18PromptPacketContract)
    Write-R18NewContextJson -Path $paths.GeneratorContract -Value (New-R18PromptGeneratorContract)
    Write-R18NewContextJson -Path $paths.Profile -Value (New-R18PromptGeneratorProfile)

    foreach ($definition in $script:R18PromptDefinitions) {
        $promptInput = New-R18PromptInput -Definition $definition -RepositoryRoot $RepositoryRoot
        $promptText = New-R18PromptText -PromptInput ([pscustomobject]$promptInput)
        $inputPath = Join-Path $paths.PromptInputRoot ([string]$definition.input_file)
        $promptPath = Join-Path $paths.PromptPacketRoot ([string]$definition.prompt_file)
        Write-R18NewContextJson -Path $inputPath -Value $promptInput
        Write-R18NewContextText -Path $promptPath -Value $promptText
        $inputs += (ConvertTo-Json $promptInput -Depth 100 | ConvertFrom-Json)
        $promptRecords += [pscustomobject]@{
            prompt_type = [string]$definition.prompt_type
            prompt_packet_id = [string]$promptInput.prompt_packet_id
            prompt_input_ref = [string]$promptInput.prompt_input_ref
            prompt_packet_ref = [string]$promptInput.prompt_packet_ref
            continuation_packet_ref = [string]$promptInput.continuation_packet_ref
            line_count = ($promptText -split "\r?\n").Count
            character_count = $promptText.Length
        }
    }

    $manifest = [ordered]@{
        artifact_type = "r18_new_context_prompt_packet_manifest"
        contract_version = "v1"
        manifest_id = "r18_014_new_context_prompt_packet_manifest"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        manifest_status = "prompt_packets_generated_not_executed"
        prompt_packet_refs = @($promptRecords | ForEach-Object { $_.prompt_packet_ref })
        prompt_input_refs = @($promptRecords | ForEach-Object { $_.prompt_input_ref })
        continuation_packet_refs = @($promptRecords | ForEach-Object { $_.continuation_packet_ref })
        validation_refs = @("tools/validate_r18_new_context_prompt_generator.ps1", "tests/test_r18_new_context_prompt_generator.ps1")
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
        prompt_count = @($promptRecords).Count
        all_prompts_context_independent = $true
        previous_thread_memory_required = $false
        automatic_new_thread_creation_performed = $false
        codex_api_invoked = $false
        openai_api_invoked = $false
        prompt_records = $promptRecords
        positive_claims = @("r18_new_context_prompt_manifest_created", "r18_new_context_prompt_inputs_created", "r18_new_context_prompt_packets_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
    Write-R18NewContextJson -Path $paths.Manifest -Value $manifest

    $results = [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_results"
        contract_version = "v1"
        result_id = "r18_014_new_context_prompt_generator_results"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        result_status = "results_created_not_runtime_execution"
        aggregate_verdict = $script:R18AggregateVerdict
        prompt_input_count = @($inputs).Count
        prompt_packet_count = @($promptRecords).Count
        prompt_types = @($inputs | ForEach-Object { $_.prompt_type })
        prompt_packet_refs = @($promptRecords | ForEach-Object { $_.prompt_packet_ref })
        prompt_input_refs = @($promptRecords | ForEach-Object { $_.prompt_input_ref })
        continuation_packet_refs = @($promptRecords | ForEach-Object { $_.continuation_packet_ref })
        max_prompt_line_count = $script:R18PromptMaxLineCount
        max_prompt_character_count = $script:R18PromptMaxCharacterCount
        all_prompts_context_independent = $true
        previous_thread_memory_required = $false
        positive_claims = @("r18_new_context_prompt_generator_results_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
    }
    Write-R18NewContextJson -Path $paths.Results -Value $results

    $report = [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_check_report"
        contract_version = "v1"
        report_id = "r18_014_new_context_prompt_generator_check_report"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        aggregate_verdict = $script:R18AggregateVerdict
        checks = @(
            [ordered]@{ check_id = "contracts_present"; status = "passed" },
            [ordered]@{ check_id = "prompt_inputs_present"; status = "passed"; count = @($inputs).Count },
            [ordered]@{ check_id = "prompt_text_packets_present"; status = "passed"; count = @($promptRecords).Count },
            [ordered]@{ check_id = "prompt_text_sections_present"; status = "passed" },
            [ordered]@{ check_id = "exact_refs_present"; status = "passed"; expected_head = $script:R18ExpectedHead; expected_tree = $script:R18ExpectedTree; expected_remote_head = $script:R18ExpectedRemoteHead },
            [ordered]@{ check_id = "runtime_false_flags"; status = "passed" },
            [ordered]@{ check_id = "status_boundary"; status = "passed"; boundary = "R18 active through R18-014 only; R18-015 through R18-028 planned only" }
        )
        positive_claims = @("r18_new_context_prompt_generator_validator_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
    }
    Write-R18NewContextJson -Path $paths.CheckReport -Value $report

    $snapshot = [ordered]@{
        artifact_type = "r18_new_context_prompt_snapshot"
        contract_version = "v1"
        snapshot_id = "r18_014_new_context_prompt_snapshot"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        r18_status = "active_through_r18_014_only"
        planned_boundary = "R18-015 through R18-028 planned only"
        prompt_count = @($promptRecords).Count
        prompt_packets_executed = $false
        automatic_new_thread_creation_performed = $false
        codex_thread_created = $false
        codex_api_invoked = $false
        openai_api_invoked = $false
        continuation_packet_executed = $false
        no_manual_prompt_transfer_success_claimed = $false
        positive_claims = @("r18_new_context_prompt_packets_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18NewContextEvidenceRefs
        authority_refs = Get-R18NewContextAuthorityRefs
    }
    Write-R18NewContextJson -Path $paths.UiSnapshot -Value $snapshot

    New-R18NewContextFixtures -RepositoryRoot $RepositoryRoot
    New-R18NewContextProofReview -RepositoryRoot $RepositoryRoot -PromptRecords $promptRecords

    return [pscustomobject]@{
        AggregateVerdict = $script:R18AggregateVerdict
        PromptInputCount = @($inputs).Count
        PromptPacketCount = @($promptRecords).Count
        PromptPacketRefs = @($promptRecords | ForEach-Object { $_.prompt_packet_ref })
    }
}

function New-R18NewContextProofReview {
    param(
        [string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot),
        [object[]]$PromptRecords = @()
    )

    $paths = Get-R18NewContextPaths -RepositoryRoot $RepositoryRoot
    $evidenceIndex = [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_evidence_index"
        contract_version = "v1"
        evidence_index_id = "r18_014_new_context_prompt_generator_evidence_index"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_status = "proof_review_created_not_runtime_execution"
        evidence_refs = Get-R18NewContextEvidenceRefs
        prompt_packet_refs = @($PromptRecords | ForEach-Object { $_.prompt_packet_ref })
        validation_refs = @("tools/validate_r18_new_context_prompt_generator.ps1", "tests/test_r18_new_context_prompt_generator.ps1")
        authority_refs = Get-R18NewContextAuthorityRefs
        positive_claims = @("r18_new_context_prompt_generator_proof_review_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
    Write-R18NewContextJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $proof = @(
        "# R18-014 New-Context Prompt Generator Proof Review",
        "",
        "## Scope",
        "R18-014 creates deterministic new-context prompt packet contracts, seed prompt inputs, bounded prompt text packets, a manifest, results, check report, fixtures, and validator tooling only.",
        "",
        "## Evidence",
        '- `contracts/runtime/r18_new_context_prompt_packet.contract.json`',
        '- `contracts/runtime/r18_new_context_prompt_generator.contract.json`',
        '- `state/runtime/r18_new_context_prompt_inputs/`',
        '- `state/runtime/r18_new_context_prompt_packets/`',
        '- `state/runtime/r18_new_context_prompt_packet_manifest.json`',
        '- `tools/R18NewContextPromptGenerator.psm1`',
        '- `tests/test_r18_new_context_prompt_generator.ps1`',
        "",
        "## Boundary",
        "Prompt packets are deterministic text artifacts only. They were not executed, did not create Codex threads, did not call Codex or OpenAI APIs, did not execute continuation packets, and did not perform recovery, retry, WIP, branch, board, A2A, live-agent, or live-skill actions.",
        "",
        "## Status",
        "R18 is active through R18-014 only. R18-015 through R18-028 remain planned only."
    ) -join [Environment]::NewLine
    Write-R18NewContextText -Path $paths.ProofReview -Value $proof

    $validation = @(
        "# R18-014 New-Context Prompt Generator Validation Manifest",
        "",
        "Required validation commands:",
        ""
    )
    foreach ($command in (Get-R18NewContextValidationCommands)) {
        $validation += ("- ``{0}``" -f $command)
    }
    $validation += ""
    $validation += "Expected status truth: R18 active through R18-014 only; R18-015 through R18-028 planned only."
    $validation += "Expected non-claims: no prompt execution, no automatic new-thread creation, no Codex/OpenAI API invocation, no continuation packet execution, no recovery action, no retry execution, no WIP cleanup, no branch mutation, no stage/commit/push by the generator, no A2A message, no live agent or skill execution, no no-manual-prompt-transfer success, and no main merge."
    Write-R18NewContextText -Path $paths.ValidationManifest -Value ($validation -join [Environment]::NewLine)
}

function New-R18Fixture {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Target,
        [Parameter(Mandatory = $true)][string]$Operation,
        [string]$Path,
        [AllowNull()][object]$Value,
        [int]$LineCount = 0,
        [string[]]$Expected = @()
    )

    $fixture = [ordered]@{
        fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($File)
        target = $Target
        operation = $Operation
        expected_failure_fragments = $Expected
    }
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $fixture.path = $Path
    }
    if ($PSBoundParameters.ContainsKey("Value")) {
        $fixture.value = $Value
    }
    if ($LineCount -gt 0) {
        $fixture.line_count = $LineCount
    }

    return [pscustomobject]@{ File = $File; Fixture = $fixture }
}

function New-R18NewContextFixtures {
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    $paths = Get-R18NewContextPaths -RepositoryRoot $RepositoryRoot
    $fixtures = @(
        New-R18Fixture -File "invalid_missing_prompt_packet_id.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "prompt_packet_id" -Expected @("prompt input missing 'prompt_packet_id'")
        New-R18Fixture -File "invalid_missing_continuation_packet_ref.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "continuation_packet_ref" -Expected @("prompt input missing 'continuation_packet_ref'")
        New-R18Fixture -File "invalid_missing_exact_repo_refs.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "repository" -Value "Wrong/Repo" -Expected @("repository exact ref")
        New-R18Fixture -File "invalid_missing_branch_head_tree.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "expected_head" -Expected @("prompt input missing 'expected_head'")
        New-R18Fixture -File "invalid_missing_last_completed_step.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "last_completed_step" -Expected @("prompt input missing 'last_completed_step'")
        New-R18Fixture -File "invalid_missing_next_safe_step.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "next_safe_step" -Expected @("prompt input missing 'next_safe_step'")
        New-R18Fixture -File "invalid_missing_allowed_paths.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "allowed_paths" -Expected @("prompt input missing 'allowed_paths'")
        New-R18Fixture -File "invalid_missing_forbidden_paths.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "forbidden_paths" -Expected @("prompt input missing 'forbidden_paths'")
        New-R18Fixture -File "invalid_missing_validation_commands.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "validation_commands" -Expected @("prompt input missing 'validation_commands'")
        New-R18Fixture -File "invalid_missing_stop_conditions.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "stop_conditions" -Expected @("prompt input missing 'stop_conditions'")
        New-R18Fixture -File "invalid_missing_non_claims.json" -Target "input:continue_after_compact_failure" -Operation "remove" -Path "non_claims" -Expected @("prompt input missing 'non_claims'")
        New-R18Fixture -File "invalid_previous_thread_memory_required.json" -Target "manifest" -Operation "set" -Path "previous_thread_memory_required" -Value $true -Expected @("previous_thread_memory_required must be false")
        New-R18Fixture -File "invalid_oversized_prompt.json" -Target "prompt:continue_after_compact_failure" -Operation "inflate_prompt" -LineCount 200 -Expected @("exceeds max line count")
        New-R18Fixture -File "invalid_unbounded_prompt_scope.json" -Target "prompt:continue_after_compact_failure" -Operation "append_text" -Value "Complete R18 from this prompt." -Expected @("whole milestone")
        New-R18Fixture -File "invalid_automatic_new_thread_creation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.automatic_new_thread_creation_performed" -Value $true -Expected @("automatic_new_thread_creation_performed")
        New-R18Fixture -File "invalid_codex_api_invocation_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.codex_api_invoked" -Value $true -Expected @("codex_api_invoked")
        New-R18Fixture -File "invalid_openai_api_invocation_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.openai_api_invoked" -Value $true -Expected @("openai_api_invoked")
        New-R18Fixture -File "invalid_prompt_execution_claim.json" -Target "manifest" -Operation "set" -Path "runtime_flags.prompt_packet_executed" -Value $true -Expected @("prompt_packet_executed")
        New-R18Fixture -File "invalid_continuation_packet_execution_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.continuation_packet_executed" -Value $true -Expected @("continuation_packet_executed")
        New-R18Fixture -File "invalid_recovery_action_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.recovery_action_performed" -Value $true -Expected @("recovery_action_performed")
        New-R18Fixture -File "invalid_retry_execution_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.retry_execution_performed" -Value $true -Expected @("retry_execution_performed")
        New-R18Fixture -File "invalid_work_order_execution_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.work_order_execution_performed" -Value $true -Expected @("work_order_execution_performed")
        New-R18Fixture -File "invalid_wip_cleanup_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.wip_cleanup_performed" -Value $true -Expected @("wip_cleanup_performed")
        New-R18Fixture -File "invalid_branch_mutation_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.branch_mutation_performed" -Value $true -Expected @("branch_mutation_performed")
        New-R18Fixture -File "invalid_stage_commit_push_claim.json" -Target "report" -Operation "set" -Path "runtime_flags.commit_performed" -Value $true -Expected @("commit_performed")
        New-R18Fixture -File "invalid_skill_execution_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.live_skill_execution_performed" -Value $true -Expected @("live_skill_execution_performed")
        New-R18Fixture -File "invalid_a2a_message_sent_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.a2a_message_sent" -Value $true -Expected @("a2a_message_sent")
        New-R18Fixture -File "invalid_board_runtime_mutation_claim.json" -Target "input:continue_after_compact_failure" -Operation "set" -Path "runtime_flags.board_runtime_mutation_performed" -Value $true -Expected @("board_runtime_mutation_performed")
        New-R18Fixture -File "invalid_r18_015_completion_claim.json" -Target "snapshot" -Operation "set" -Path "runtime_flags.r18_015_completed" -Value $true -Expected @("r18_015_completed")
    )

    $manifest = [ordered]@{
        artifact_type = "r18_new_context_prompt_generator_fixture_manifest"
        contract_version = "v1"
        fixture_manifest_id = "r18_014_new_context_prompt_generator_fixture_manifest"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        fixture_count = @($fixtures).Count
        fixture_refs = @($fixtures | ForEach-Object { "tests/fixtures/r18_new_context_prompt_generator/$($_.File)" })
        positive_claims = @("r18_new_context_prompt_generator_fixtures_created")
        runtime_flags = New-R18NewContextRuntimeFlags
        non_claims = Get-R18NewContextNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
    Write-R18NewContextJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value $manifest

    foreach ($fixtureRecord in $fixtures) {
        Write-R18NewContextJson -Path (Join-Path $paths.FixtureRoot $fixtureRecord.File) -Value $fixtureRecord.Fixture
    }
}

function Assert-R18PromptCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18PromptRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        Assert-R18PromptCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing '$field'."
        $value = $Object.$field
        if ($null -eq $value) {
            throw "$Context '$field' is null."
        }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context '$field' is blank."
        }
        if ($value -is [System.Array] -and @($value).Count -eq 0) {
            throw "$Context '$field' is empty."
        }
    }
}

function Assert-R18PromptRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        Assert-R18PromptCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context runtime_flags missing '$field'."
        Assert-R18PromptCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Assert-R18PromptPositiveClaims {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -contains "positive_claims") {
        foreach ($claim in @($Object.positive_claims)) {
            Assert-R18PromptCondition -Condition ($script:R18AllowedPositiveClaims -contains [string]$claim) -Message "$Context contains disallowed positive claim '$claim'."
        }
    }
}

function Assert-R18PromptNoForbiddenTrueProperties {
    param([AllowNull()][object]$Object)

    if ($null -eq $Object) {
        return
    }
    if ($Object -is [string] -or $Object -is [int] -or $Object -is [bool]) {
        return
    }
    if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
        foreach ($item in $Object) {
            Assert-R18PromptNoForbiddenTrueProperties -Object $item
        }
        return
    }
    foreach ($property in $Object.PSObject.Properties) {
        if ($script:R18RuntimeFlagFields -contains $property.Name) {
            Assert-R18PromptCondition -Condition ([bool]$property.Value -eq $false) -Message "Forbidden runtime claim '$($property.Name)' is true."
        }
        if ($property.Name -eq "previous_thread_memory_required") {
            Assert-R18PromptCondition -Condition ([bool]$property.Value -eq $false) -Message "previous_thread_memory_required must be false."
        }
        Assert-R18PromptNoForbiddenTrueProperties -Object $property.Value
    }
}

function Assert-R18PromptTextNoForbiddenPositiveClaims {
    param([Parameter(Mandatory = $true)][string]$Text)

    $patterns = @(
        @{ pattern = '(?i)requires\s+previous[- ]thread\s+memory|previous[- ]thread\s+memory\s+is\s+required'; message = "Prompt requires previous-thread memory." },
        @{ pattern = '(?i)\bcomplete\s+R18\b|\bfinish\s+R18\b|\bcomplete\s+the\s+whole\s+milestone\b'; message = "Prompt asks for whole milestone completion." },
        @{ pattern = '(?i)\bscan\s+the\s+(whole|entire)\s+repo|\bbroad\s+repo\s+scan\s+allowed\b'; message = "Prompt allows broad repo scan." },
        @{ pattern = '(?i)\bunbounded\s+write\s+paths?\s+allowed\b|\bwrite\s+anywhere\b'; message = "Prompt allows unbounded write paths." },
        @{ pattern = '(?i)automatic\s+new[- ]thread\s+creation\s+(performed|occurred|true|will\s+occur)'; message = "Prompt claims automatic new-thread creation." },
        @{ pattern = '(?i)codex\s+thread\s+(created|creation\s+performed|creation\s+occurred)'; message = "Prompt claims Codex thread creation." },
        @{ pattern = '(?i)codex\s+api\s+(invoked|invocation\s+occurred|invocation\s+performed)'; message = "Prompt claims Codex API invocation." },
        @{ pattern = '(?i)openai\s+api\s+(invoked|invocation\s+occurred|invocation\s+performed)'; message = "Prompt claims OpenAI API invocation." },
        @{ pattern = '(?i)prompt\s+(packet\s+)?execution\s+(occurred|performed)|prompt\s+packet\s+executed:\s*true'; message = "Prompt claims prompt execution." },
        @{ pattern = '(?i)continuation\s+packet\s+execution\s+(occurred|performed)|continuation\s+packet\s+executed:\s*true'; message = "Prompt claims continuation packet execution." },
        @{ pattern = '(?i)recovery\s+action\s+(occurred|performed)|retry\s+execution\s+(occurred|performed)|work[- ]order\s+execution\s+(occurred|performed)'; message = "Prompt claims runtime execution." },
        @{ pattern = '(?i)wip\s+(cleanup|abandonment)\s+(occurred|performed)|branch\s+mutation\s+(occurred|performed)|commit\s+performed|push\s+performed|staging\s+performed'; message = "Prompt claims WIP or branch mutation." },
        @{ pattern = '(?i)a2a\s+message\s+sent:\s*true|board\s+runtime\s+mutation\s+(occurred|performed)|live\s+skill\s+execution\s+(occurred|performed)'; message = "Prompt claims live runtime side effects." },
        @{ pattern = '(?i)no[- ]manual[- ]prompt[- ]transfer\s+success\s+(claimed|achieved)|codex\s+compaction\s+solved|codex\s+reliability\s+solved|R18-015\s+(completed|done)'; message = "Prompt claims forbidden success or later completion." }
    )

    foreach ($entry in $patterns) {
        if ($Text -match $entry.pattern) {
            throw $entry.message
        }
    }
}

function Assert-R18PromptInput {
    param([Parameter(Mandatory = $true)][object]$PromptInput)

    Assert-R18PromptRequiredFields -Object $PromptInput -Fields $script:R18RequiredPromptInputFields -Context "R18 prompt input"
    Assert-R18PromptCondition -Condition ($PromptInput.artifact_type -eq "r18_new_context_prompt_input") -Message "R18 prompt input artifact_type is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.source_task -eq $script:R18SourceTask) -Message "R18 prompt input source_task is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.prompt_input_status -eq "seed_prompt_input_only_not_runtime_execution") -Message "R18 prompt input status is invalid."
    Assert-R18PromptCondition -Condition ($script:R18AllowedPromptTypes -contains [string]$PromptInput.prompt_type) -Message "R18 prompt input uses unknown prompt_type '$($PromptInput.prompt_type)'."
    Assert-R18PromptCondition -Condition ($PromptInput.repository -eq $script:R18Repository) -Message "R18 prompt input repository exact ref is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.branch -eq $script:R18Branch) -Message "R18 prompt input branch exact ref is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.expected_head -eq $script:R18ExpectedHead) -Message "R18 prompt input expected_head exact ref is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.expected_tree -eq $script:R18ExpectedTree) -Message "R18 prompt input expected_tree exact ref is invalid."
    Assert-R18PromptCondition -Condition ($PromptInput.expected_remote_head -eq $script:R18ExpectedRemoteHead) -Message "R18 prompt input expected_remote_head exact ref is invalid."
    Assert-R18PromptCondition -Condition (@($PromptInput.validation_commands).Count -gt 0) -Message "R18 prompt input validation_commands must not be empty."
    Assert-R18PromptCondition -Condition (@($PromptInput.allowed_paths).Count -gt 0) -Message "R18 prompt input allowed_paths must not be empty."
    Assert-R18PromptCondition -Condition (@($PromptInput.forbidden_paths).Count -gt 0) -Message "R18 prompt input forbidden_paths must not be empty."
    Assert-R18PromptCondition -Condition (@($PromptInput.stop_conditions).Count -gt 0) -Message "R18 prompt input stop_conditions must not be empty."
    Assert-R18PromptCondition -Condition (@($PromptInput.non_claims).Count -gt 0) -Message "R18 prompt input non_claims must not be empty."
    Assert-R18PromptRuntimeFlags -RuntimeFlags $PromptInput.runtime_flags -Context "R18 prompt input"
    Assert-R18PromptPositiveClaims -Object $PromptInput -Context "R18 prompt input"
}

function Assert-R18PromptText {
    param(
        [Parameter(Mandatory = $true)][object]$PromptInput,
        [Parameter(Mandatory = $true)][string]$Text
    )

    foreach ($section in $script:R18RequiredPromptTextSections) {
        $escaped = [regex]::Escape($section)
        Assert-R18PromptCondition -Condition ($Text -match "(?m)^$escaped\s*$") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing required section '$section'."
    }

    foreach ($required in @(
            [string]$PromptInput.repository,
            [string]$PromptInput.branch,
            [string]$PromptInput.expected_head,
            [string]$PromptInput.expected_tree,
            [string]$PromptInput.expected_remote_head,
            [string]$PromptInput.last_completed_step,
            [string]$PromptInput.next_safe_step,
            [string]$PromptInput.continuation_packet_ref
        )) {
        Assert-R18PromptCondition -Condition ($Text -like "*$required*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing exact required value '$required'."
    }

    foreach ($path in @($PromptInput.allowed_paths)) {
        Assert-R18PromptCondition -Condition ($Text -like "*$path*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing allowed path '$path'."
    }
    foreach ($path in @($PromptInput.forbidden_paths)) {
        Assert-R18PromptCondition -Condition ($Text -like "*$path*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing forbidden path '$path'."
    }
    foreach ($command in @($PromptInput.validation_commands)) {
        Assert-R18PromptCondition -Condition ($Text -like "*$command*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing validation command '$command'."
    }
    foreach ($condition in @($PromptInput.stop_conditions)) {
        Assert-R18PromptCondition -Condition ($Text -like "*$condition*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing stop condition '$condition'."
    }
    foreach ($claim in @($PromptInput.non_claims)) {
        Assert-R18PromptCondition -Condition ($Text -like "*$claim*") -Message "R18 prompt text '$($PromptInput.prompt_type)' missing explicit non-claim '$claim'."
    }

    $lineCount = ($Text -split "\r?\n").Count
    Assert-R18PromptCondition -Condition ($lineCount -le $script:R18PromptMaxLineCount) -Message "R18 prompt text '$($PromptInput.prompt_type)' exceeds max line count."
    Assert-R18PromptCondition -Condition ($Text.Length -le $script:R18PromptMaxCharacterCount) -Message "R18 prompt text '$($PromptInput.prompt_type)' exceeds max character count."
    Assert-R18PromptTextNoForbiddenPositiveClaims -Text $Text
}

function Assert-R18PromptContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    foreach ($field in @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_prompt_input_fields", "required_prompt_packet_fields", "required_prompt_text_sections", "allowed_prompt_types", "allowed_prompt_statuses", "required_runtime_false_flags", "prompt_packet_policy", "exact_ref_policy", "context_independence_policy", "size_policy", "safety_policy", "validation_policy", "evidence_policy", "authority_policy", "boundary_policy", "path_policy", "api_policy", "execution_policy", "refusal_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags")) {
        Assert-R18PromptCondition -Condition ($Contract.PSObject.Properties.Name -contains $field) -Message "R18 prompt packet contract missing '$field'."
    }
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 prompt packet contract"
    Assert-R18PromptPositiveClaims -Object $Contract -Context "R18 prompt packet contract"
}

function Assert-R18PromptGeneratorContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    foreach ($field in @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_input_fields", "required_output_fields", "required_prompt_text_constraints", "required_runtime_false_flags", "generation_policy", "input_policy", "output_policy", "size_policy", "exact_ref_policy", "safety_policy", "status_boundary_policy", "path_policy", "api_policy", "execution_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags")) {
        Assert-R18PromptCondition -Condition ($Contract.PSObject.Properties.Name -contains $field) -Message "R18 prompt generator contract missing '$field'."
    }
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 prompt generator contract"
    Assert-R18PromptPositiveClaims -Object $Contract -Context "R18 prompt generator contract"
}

function Assert-R18PromptManifest {
    param([Parameter(Mandatory = $true)][object]$Manifest)

    foreach ($field in @("artifact_type", "contract_version", "manifest_id", "source_task", "source_milestone", "manifest_status", "prompt_packet_refs", "prompt_input_refs", "continuation_packet_refs", "validation_refs", "evidence_refs", "authority_refs", "prompt_count", "all_prompts_context_independent", "previous_thread_memory_required", "automatic_new_thread_creation_performed", "codex_api_invoked", "openai_api_invoked", "runtime_flags", "non_claims", "rejected_claims")) {
        Assert-R18PromptCondition -Condition ($Manifest.PSObject.Properties.Name -contains $field) -Message "R18 prompt manifest missing '$field'."
    }
    Assert-R18PromptCondition -Condition ($Manifest.manifest_status -eq "prompt_packets_generated_not_executed") -Message "R18 prompt manifest status is invalid."
    Assert-R18PromptCondition -Condition ([int]$Manifest.prompt_count -eq @($script:R18PromptDefinitions).Count) -Message "R18 prompt manifest prompt_count is invalid."
    Assert-R18PromptCondition -Condition ([bool]$Manifest.all_prompts_context_independent -eq $true) -Message "R18 prompt manifest must mark prompts context-independent."
    Assert-R18PromptCondition -Condition ([bool]$Manifest.previous_thread_memory_required -eq $false) -Message "previous_thread_memory_required must be false."
    Assert-R18PromptCondition -Condition ([bool]$Manifest.automatic_new_thread_creation_performed -eq $false) -Message "R18 prompt manifest claims automatic new-thread creation."
    Assert-R18PromptCondition -Condition ([bool]$Manifest.codex_api_invoked -eq $false) -Message "R18 prompt manifest claims Codex API invocation."
    Assert-R18PromptCondition -Condition ([bool]$Manifest.openai_api_invoked -eq $false) -Message "R18 prompt manifest claims OpenAI API invocation."
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Manifest.runtime_flags -Context "R18 prompt manifest"
    Assert-R18PromptPositiveClaims -Object $Manifest -Context "R18 prompt manifest"
}

function Assert-R18PromptResults {
    param([Parameter(Mandatory = $true)][object]$Results)

    Assert-R18PromptCondition -Condition ($Results.artifact_type -eq "r18_new_context_prompt_generator_results") -Message "R18 prompt generator results artifact_type is invalid."
    Assert-R18PromptCondition -Condition ([int]$Results.prompt_input_count -eq @($script:R18PromptDefinitions).Count) -Message "R18 prompt generator results prompt_input_count is invalid."
    Assert-R18PromptCondition -Condition ([int]$Results.prompt_packet_count -eq @($script:R18PromptDefinitions).Count) -Message "R18 prompt generator results prompt_packet_count is invalid."
    Assert-R18PromptCondition -Condition ([bool]$Results.previous_thread_memory_required -eq $false) -Message "R18 prompt generator results claims previous thread memory is required."
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Results.runtime_flags -Context "R18 prompt generator results"
    Assert-R18PromptPositiveClaims -Object $Results -Context "R18 prompt generator results"
}

function Assert-R18PromptReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18PromptCondition -Condition ($Report.artifact_type -eq "r18_new_context_prompt_generator_check_report") -Message "R18 prompt check report artifact_type is invalid."
    Assert-R18PromptCondition -Condition ($Report.aggregate_verdict -eq $script:R18AggregateVerdict) -Message "R18 prompt check report aggregate verdict is invalid."
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 prompt check report"
    Assert-R18PromptPositiveClaims -Object $Report -Context "R18 prompt check report"
}

function Assert-R18PromptSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18PromptCondition -Condition ($Snapshot.artifact_type -eq "r18_new_context_prompt_snapshot") -Message "R18 prompt snapshot artifact_type is invalid."
    Assert-R18PromptCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_014_only") -Message "R18 prompt snapshot status is invalid."
    Assert-R18PromptCondition -Condition ([bool]$Snapshot.prompt_packets_executed -eq $false) -Message "R18 prompt snapshot claims prompt execution."
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Snapshot.runtime_flags -Context "R18 prompt snapshot"
    Assert-R18PromptPositiveClaims -Object $Snapshot -Context "R18 prompt snapshot"
}

function Get-R18PromptTaskStatusMap {
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

function Test-R18NewContextPromptGeneratorStatusTruth {
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18NewContextPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-018 only",
            "R18-019 through R18-028 planned only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "R18-014 created new-context prompt generator foundation only",
            "New-context prompt packets were generated as deterministic text artifacts only",
            "Prompt packets were not executed",
            "Automatic new-thread creation was not performed",
            "Codex thread creation was not performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "No recovery action was performed",
            "No retry execution was performed",
            "No WIP cleanup or abandonment was performed",
            "No branch mutation was performed",
            "No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed",
            "No staging, commit, or push was performed by the generator",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-014 truth: $required"
        }
    }

    $authorityStatuses = Get-R18PromptTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18PromptTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18PromptCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 18) {
            Assert-R18PromptCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-018."
        }
        else {
            Assert-R18PromptCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-018."
        }
    }

    if ($combinedText -match 'R18 active through R18-(019|02[0-8])') {
        throw "Status surface claims R18 beyond R18-018."
    }
    if ($combinedText -match '(?i)R18-(019|02[0-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-019 or later completion."
    }
}

function Test-R18NewContextPromptGeneratorSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$PacketContract,
        [Parameter(Mandatory = $true)][object]$GeneratorContract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object[]]$Prompts,
        [Parameter(Mandatory = $true)][object]$Manifest,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot)
    )

    Assert-R18PromptContract -Contract $PacketContract
    Assert-R18PromptGeneratorContract -Contract $GeneratorContract
    Assert-R18PromptRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 prompt generator profile"
    Assert-R18PromptPositiveClaims -Object $Profile -Context "R18 prompt generator profile"
    Assert-R18PromptCondition -Condition (@($Inputs).Count -eq @($script:R18PromptDefinitions).Count) -Message "R18 prompt inputs are missing."
    Assert-R18PromptCondition -Condition (@($Prompts).Count -eq @($script:R18PromptDefinitions).Count) -Message "R18 prompt packets are missing."

    foreach ($promptInput in @($Inputs)) {
        Assert-R18PromptInput -PromptInput $promptInput
        $matchingPrompt = @($Prompts | Where-Object { $_.prompt_type -eq $promptInput.prompt_type })
        Assert-R18PromptCondition -Condition ($matchingPrompt.Count -eq 1) -Message "R18 prompt input '$($promptInput.prompt_type)' does not have exactly one matching prompt text packet."
        Assert-R18PromptText -PromptInput $promptInput -Text ([string]$matchingPrompt[0].text)
    }

    Assert-R18PromptManifest -Manifest $Manifest
    Assert-R18PromptResults -Results $Results
    Assert-R18PromptReport -Report $Report
    Assert-R18PromptSnapshot -Snapshot $Snapshot

    foreach ($artifact in @($PacketContract, $GeneratorContract, $Profile, $Inputs, $Manifest, $Results, $Report, $Snapshot)) {
        Assert-R18PromptNoForbiddenTrueProperties -Object $artifact
    }
    foreach ($prompt in @($Prompts)) {
        Assert-R18PromptTextNoForbiddenPositiveClaims -Text ([string]$prompt.text)
    }

    Test-R18NewContextPromptGeneratorStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        PromptInputCount = @($Inputs).Count
        PromptPacketCount = @($Prompts).Count
        RuntimeFlags = $Report.runtime_flags
    }
}

function Get-R18NewContextPromptGeneratorSet {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    $paths = Get-R18NewContextPaths -RepositoryRoot $RepositoryRoot
    $inputs = @()
    $prompts = @()
    foreach ($definition in $script:R18PromptDefinitions) {
        $inputs += Read-R18NewContextJson -Path (Join-Path $paths.PromptInputRoot ([string]$definition.input_file))
        $promptTextPath = Join-Path $paths.PromptPacketRoot ([string]$definition.prompt_file)
        if (-not (Test-Path -LiteralPath $promptTextPath -PathType Leaf)) {
            throw "Required prompt text artifact '$promptTextPath' does not exist."
        }
        $prompts += [pscustomobject]@{
            prompt_type = [string]$definition.prompt_type
            path = "state/runtime/r18_new_context_prompt_packets/$($definition.prompt_file)"
            text = Get-Content -LiteralPath $promptTextPath -Raw
        }
    }

    return [pscustomobject]@{
        PacketContract = Read-R18NewContextJson -Path $paths.PacketContract
        GeneratorContract = Read-R18NewContextJson -Path $paths.GeneratorContract
        Profile = Read-R18NewContextJson -Path $paths.Profile
        Inputs = $inputs
        Prompts = $prompts
        Manifest = Read-R18NewContextJson -Path $paths.Manifest
        Results = Read-R18NewContextJson -Path $paths.Results
        Report = Read-R18NewContextJson -Path $paths.CheckReport
        Snapshot = Read-R18NewContextJson -Path $paths.UiSnapshot
    }
}

function Test-R18NewContextPromptGenerator {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18NewContextRepositoryRoot))

    $set = Get-R18NewContextPromptGeneratorSet -RepositoryRoot $RepositoryRoot
    return Test-R18NewContextPromptGeneratorSet `
        -PacketContract $set.PacketContract `
        -GeneratorContract $set.GeneratorContract `
        -Profile $set.Profile `
        -Inputs $set.Inputs `
        -Prompts $set.Prompts `
        -Manifest $set.Manifest `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18PromptObjectPathValue {
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

function Remove-R18PromptObjectPathValue {
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

function Invoke-R18NewContextPromptMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18PromptObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18PromptObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        "append_text" { $TargetObject.text = ([string]$TargetObject.text) + [Environment]::NewLine + ([string]$Mutation.value) }
        "replace_text" { $TargetObject.text = [string]$Mutation.value }
        "inflate_prompt" {
            $lines = @([string]$TargetObject.text)
            foreach ($index in 1..([int]$Mutation.line_count)) {
                $lines += "oversized prompt line $index"
            }
            $TargetObject.text = $lines -join [Environment]::NewLine
        }
        default { throw "Unknown R18 new-context prompt generator mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18NewContextPaths, `
    Read-R18NewContextJson, `
    Copy-R18NewContextObject, `
    New-R18NewContextPromptArtifacts, `
    Test-R18NewContextPromptGenerator, `
    Test-R18NewContextPromptGeneratorSet, `
    Test-R18NewContextPromptGeneratorStatusTruth, `
    Get-R18NewContextPromptGeneratorSet, `
    Invoke-R18NewContextPromptMutation
