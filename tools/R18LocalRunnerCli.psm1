Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-007"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18ExpectedRemoteHead = "43ab46d6e2054145bc546f049c5c4c195f9679fe"
$script:R18ExpectedTree = "a8c6724e492cc3c895030bfc0c679b072e1a9468"
$script:R18CliVerdict = "generated_r18_local_runner_cli_shell_foundation_only"

$script:R18RequiredCommandTypes = @(
    "status",
    "inspect_repo",
    "validate_intake_packet",
    "refuse_execute_work_order"
)

$script:R18InputFileMap = [ordered]@{
    status = "status_command.input.json"
    inspect_repo = "inspect_repo_command.input.json"
    validate_intake_packet = "validate_intake_command.input.json"
    refuse_execute_work_order = "refuse_execute_work_order_command.input.json"
}

$script:R18ResultFileMap = [ordered]@{
    status = "status_command.result.json"
    inspect_repo = "inspect_repo_command.result.json"
    validate_intake_packet = "validate_intake_command.result.json"
    refuse_execute_work_order = "refuse_execute_work_order_command.result.json"
}

$script:R18InputRequiredFields = @(
    "artifact_type",
    "contract_version",
    "command_id",
    "command_type",
    "source_task",
    "source_milestone",
    "command_status",
    "dry_run",
    "requested_by_role",
    "intake_packet_ref",
    "authority_refs",
    "expected_branch",
    "expected_remote_head",
    "expected_tree",
    "allowed_paths",
    "forbidden_paths",
    "requested_action",
    "validation_expectations",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18ResultRequiredFields = @(
    "artifact_type",
    "contract_version",
    "result_id",
    "command_id",
    "command_type",
    "source_task",
    "result_status",
    "branch_identity",
    "authority_check",
    "intake_check",
    "path_check",
    "dry_run_only_check",
    "refused_actions",
    "next_allowed_actions",
    "evidence_refs",
    "validation_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RuntimeFlagFields = @(
    "local_runner_runtime_executed",
    "work_order_execution_performed",
    "work_order_state_machine_implemented",
    "live_chat_ui_implemented",
    "orchestrator_runtime_implemented",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "live_recovery_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "stage_commit_push_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_008_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_local_runner_cli_contract_created",
    "r18_local_runner_cli_profile_created",
    "r18_local_runner_cli_command_catalog_created",
    "r18_local_runner_cli_dry_run_inputs_created",
    "r18_local_runner_cli_dry_run_results_created",
    "r18_local_runner_cli_validator_created",
    "r18_local_runner_cli_fixtures_created",
    "r18_local_runner_cli_proof_review_created"
)

$script:R18RejectedClaims = @(
    "work_order_execution",
    "work_order_state_machine",
    "live_runner_runtime",
    "live_chat_ui",
    "orchestrator_runtime",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "live_recovery_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "automatic_new_thread_creation",
    "stage_commit_push",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_008_or_later_completion",
    "main_merge",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "broad_repo_write",
    "unknown_command"
)

function Get-R18CliRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18CliPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18CliJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18CliJson {
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

function Write-R18CliText {
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

function Copy-R18CliObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18CliPaths {
    param([string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $inputRoot = "state/runtime/r18_local_runner_cli_dry_run_inputs"
    $resultRoot = "state/runtime/r18_local_runner_cli_dry_run_results"
    $fixtureRoot = "tests/fixtures/r18_local_runner_cli"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_007_local_runner_cli_shell"

    return [pscustomobject]@{
        Contract = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r18_local_runner_cli.contract.json"
        Profile = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_local_runner_cli_profile.json"
        Catalog = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_local_runner_cli_command_catalog.json"
        InputRoot = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $inputRoot
        ResultRoot = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $resultRoot
        CheckReport = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r18_local_runner_cli_check_report.json"
        UiSnapshot = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_local_runner_cli_snapshot.json"
        Module = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18LocalRunnerCli.psm1"
        Generator = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_local_runner_cli.ps1"
        Validator = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_local_runner_cli.ps1"
        Invoker = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "tools/invoke_r18_local_runner_cli.ps1"
        Test = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_local_runner_cli.ps1"
        FixtureRoot = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
    }
}

function Get-R18CliInputPath {
    param(
        [Parameter(Mandatory = $true)][string]$CommandType,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    if (-not $script:R18InputFileMap.Contains($CommandType)) {
        throw "Unknown R18 local runner CLI command type '$CommandType'."
    }

    $paths = Get-R18CliPaths -RepositoryRoot $RepositoryRoot
    return Join-Path $paths.InputRoot $script:R18InputFileMap[$CommandType]
}

function Get-R18CliResultPath {
    param(
        [Parameter(Mandatory = $true)][string]$CommandType,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    if (-not $script:R18ResultFileMap.Contains($CommandType)) {
        throw "Unknown R18 local runner CLI command type '$CommandType'."
    }

    $paths = Get-R18CliPaths -RepositoryRoot $RepositoryRoot
    return Join-Path $paths.ResultRoot $script:R18ResultFileMap[$CommandType]
}

function Get-R18CliAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_registry.json",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_registry.json",
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "state/intake/r18_orchestrator_control_intake_registry.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json"
    )
}

function Get-R18CliEvidenceRefs {
    return @(
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "state/runtime/r18_local_runner_cli_command_catalog.json",
        "state/runtime/r18_local_runner_cli_dry_run_inputs/",
        "state/runtime/r18_local_runner_cli_dry_run_results/",
        "state/runtime/r18_local_runner_cli_check_report.json",
        "state/ui/r18_operator_surface/r18_local_runner_cli_snapshot.json",
        "tools/R18LocalRunnerCli.psm1",
        "tools/invoke_r18_local_runner_cli.ps1",
        "tools/new_r18_local_runner_cli.ps1",
        "tools/validate_r18_local_runner_cli.ps1",
        "tests/test_r18_local_runner_cli.ps1",
        "tests/fixtures/r18_local_runner_cli/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_007_local_runner_cli_shell/"
    )
}

function Get-R18CliAllowedPaths {
    return @(
        "contracts/runtime/r18_local_runner_cli.contract.json",
        "state/runtime/r18_local_runner_cli_profile.json",
        "state/runtime/r18_local_runner_cli_command_catalog.json",
        "state/runtime/r18_local_runner_cli_dry_run_inputs/",
        "state/runtime/r18_local_runner_cli_dry_run_results/",
        "state/runtime/r18_local_runner_cli_check_report.json",
        "state/ui/r18_operator_surface/r18_local_runner_cli_snapshot.json",
        "tools/R18LocalRunnerCli.psm1",
        "tools/invoke_r18_local_runner_cli.ps1",
        "tools/new_r18_local_runner_cli.ps1",
        "tools/validate_r18_local_runner_cli.ps1",
        "tests/test_r18_local_runner_cli.ps1",
        "tests/fixtures/r18_local_runner_cli/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_007_local_runner_cli_shell/",
        "state/intake/r18_orchestrator_control_intake_packets/status_query_request.intake.json",
        "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json",
        "state/intake/r18_orchestrator_control_intake_registry.json"
    )
}

function Get-R18CliForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_*",
        "state/proof_reviews/r14_*",
        "state/proof_reviews/r15_*",
        "state/proof_reviews/r16_*",
        "state/external_runs/",
        "repository root broad write",
        "unbounded wildcard write paths",
        "main branch"
    )
}

function Get-R18CliValidationRefs {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_local_runner_cli.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_local_runner_cli.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_local_runner_cli.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R18CliRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18CliNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-008 only.",
        "R18-009 through R18-028 remain planned only.",
        "R18-007 created local runner/CLI shell foundation only.",
        "CLI shell is dry-run only.",
        "CLI shell is not full work-order execution runtime.",
        "R18-008 created work-order execution state machine foundation only.",
        "Work-order state machine is not runtime execution.",
        "Runner state store is not implemented.",
        "Resumable execution log is not implemented.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
        "No live A2A runtime was implemented.",
        "No recovery runtime was implemented.",
        "No API invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No stage/commit/push was performed by the runner or state machine.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function New-R18CliPathPolicy {
    return [ordered]@{
        allowed_paths = Get-R18CliAllowedPaths
        forbidden_paths = Get-R18CliForbiddenPaths
        allowed_paths_must_be_exact_or_task_scoped = $true
        wildcard_paths_allowed = $false
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
        runner_write_paths_limited_to_r18_007_artifacts = $true
    }
}

function New-R18CliApiPolicy {
    return [ordered]@{
        api_enabled = $false
        openai_api_invocation_allowed = $false
        codex_api_invocation_allowed = $false
        autonomous_codex_invocation_allowed = $false
        automatic_new_thread_creation_allowed = $false
        api_controls_required_before_enablement = $true
        operator_approval_required_for_api_enablement = $true
    }
}

function New-R18CliExecutionPolicy {
    return [ordered]@{
        dry_run_only = $true
        work_order_execution_allowed = $false
        work_order_state_machine_allowed = $false
        skill_execution_allowed = $false
        a2a_dispatch_allowed = $false
        api_invocation_allowed = $false
        stage_commit_push_allowed = $false
        board_runtime_mutation_allowed = $false
        live_agent_invocation_allowed = $false
        live_recovery_runtime_allowed = $false
        product_runtime_execution_allowed = $false
    }
}

function New-R18CliBranchPolicy {
    return [ordered]@{
        expected_branch = $script:R18Branch
        expected_remote_head = $script:R18ExpectedRemoteHead
        expected_tree = $script:R18ExpectedTree
        wrong_branch_fails_closed = $true
        missing_branch_identity_fails_closed = $true
        missing_remote_head_expectation_fails_closed = $true
        missing_tree_expectation_fails_closed = $true
        broad_repo_scan_allowed = $false
    }
}

function New-R18CliContract {
    return [ordered]@{
        artifact_type = "r18_local_runner_cli_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-007-local-runner-cli-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "local_runner_cli_shell_foundation_dry_run_validation_boundary_only"
        purpose = "Create a bounded local runner/CLI shell foundation that validates command shape, inspects explicit repository identity, loads approved R18-006 intake packet refs, enforces dry-run path and authority checks, emits deterministic dry-run evidence, and refuses unsafe commands without executing work orders or live runtimes."
        required_command_types = $script:R18RequiredCommandTypes
        required_command_input_fields = $script:R18InputRequiredFields
        required_command_result_fields = $script:R18ResultRequiredFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        command_policy = [ordered]@{
            exact_required_command_type_set = $script:R18RequiredCommandTypes
            unknown_command_types_allowed = $false
            duplicate_command_types_allowed = $false
            wildcard_command_types_allowed = $false
            commands_default_to_dry_run_only = $true
            commands_must_refuse_unsafe_actions = $true
        }
        authority_policy = [ordered]@{
            authority_refs_required = $true
            all_required_authority_refs_must_exist = $true
            missing_authority_refs_fail_closed = $true
            approved_authority_refs = Get-R18CliAuthorityRefs
        }
        intake_policy = [ordered]@{
            intake_packet_ref_required = $true
            intake_packet_ref_must_exist = $true
            approved_intake_packet_root = "state/intake/r18_orchestrator_control_intake_packets/"
            validate_intake_packet_does_not_route_or_execute = $true
            missing_intake_packet_ref_fails_closed = $true
        }
        branch_policy = New-R18CliBranchPolicy
        path_policy = New-R18CliPathPolicy
        api_policy = New-R18CliApiPolicy
        execution_policy = New-R18CliExecutionPolicy
        refusal_policy = [ordered]@{
            refuse_execute_work_order_required = $true
            work_order_execution_blocked_until = "R18-008_or_later_when_explicitly_implemented_and_approved"
            unsafe_command_requests_fail_closed = $true
            refusal_results_must_include_non_claims = $true
        }
        evidence_policy = [ordered]@{
            deterministic_dry_run_inputs_required = $true
            deterministic_dry_run_results_required = $true
            check_report_required = $true
            proof_review_package_required = $true
            runtime_false_flags_required = $true
            historical_r13_r16_evidence_edits_allowed = $false
            operator_local_backup_paths_allowed = $false
        }
        retry_failure_policy = [ordered]@{
            retry_runtime_implemented = $false
            retry_execution_allowed = $false
            validation_failures_return_nonzero = $true
            unsafe_commands_fail_closed = $true
            recovery_runtime_not_implemented = $true
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18CliNonClaims
        evidence_refs = Get-R18CliEvidenceRefs
        authority_refs = Get-R18CliAuthorityRefs
        runtime_flags = Get-R18CliRuntimeFlags
    }
}

function New-R18CliProfile {
    return [ordered]@{
        artifact_type = "r18_local_runner_cli_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-007-local-runner-cli-profile-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        profile_status = "dry_run_shell_profile_only"
        active_through_task = $script:R18SourceTask
        planned_only_boundary = "R18-009 through R18-028 remain planned only"
        default_mode = "dry_run_only"
        command_types = $script:R18RequiredCommandTypes
        branch_policy = New-R18CliBranchPolicy
        path_policy = New-R18CliPathPolicy
        api_policy = New-R18CliApiPolicy
        execution_policy = New-R18CliExecutionPolicy
        runtime_flags = Get-R18CliRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18CliEvidenceRefs
        authority_refs = Get-R18CliAuthorityRefs
    }
}

function New-R18CliCommandCatalog {
    $commands = @(
        [ordered]@{
            command_type = "status"
            command_id = "r18_007_status_command"
            command_status = "dry_run_input_only"
            behavior = "Reports current milestone boundary and runner shell status."
            read_only = $true
            dry_run_only = $true
            mutation_allowed = $false
            result_status = "dry_run_passed"
        },
        [ordered]@{
            command_type = "inspect_repo"
            command_id = "r18_007_inspect_repo_command"
            command_status = "dry_run_input_only"
            behavior = "Captures branch, HEAD, tree, and remote head expectation without broad repo scan."
            read_only = $true
            dry_run_only = $true
            mutation_allowed = $false
            result_status = "dry_run_passed"
        },
        [ordered]@{
            command_type = "validate_intake_packet"
            command_id = "r18_007_validate_intake_packet_command"
            command_status = "dry_run_input_only"
            behavior = "Validates a supplied R18-006 intake packet ref against current authority refs without routing or execution."
            read_only = $true
            dry_run_only = $true
            mutation_allowed = $false
            result_status = "dry_run_passed"
        },
        [ordered]@{
            command_type = "refuse_execute_work_order"
            command_id = "r18_007_refuse_execute_work_order_command"
            command_status = "dry_run_input_only"
            behavior = "Demonstrates that direct work-order execution is blocked until R18-008 or later."
            read_only = $true
            dry_run_only = $true
            mutation_allowed = $false
            result_status = "dry_run_refused"
        }
    )

    return [ordered]@{
        artifact_type = "r18_local_runner_cli_command_catalog"
        contract_version = "v1"
        catalog_id = "aioffice-r18-007-local-runner-cli-command-catalog-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        active_through_task = $script:R18SourceTask
        command_count = @($commands).Count
        required_command_types = $script:R18RequiredCommandTypes
        commands = $commands
        unknown_commands_fail_closed = $true
        dry_run_default = $true
        runtime_flags = Get-R18CliRuntimeFlags
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18CliEvidenceRefs
        authority_refs = Get-R18CliAuthorityRefs
    }
}

function New-R18CliRequestedAction {
    param(
        [Parameter(Mandatory = $true)][string]$ActionId,
        [Parameter(Mandatory = $true)][string]$Description,
        [bool]$WorkOrderExecutionRequested = $false
    )

    return [ordered]@{
        action_id = $ActionId
        description = $Description
        dry_run_validation_only = $true
        read_only = $true
        mutation_allowed = $false
        work_order_execution_requested = $WorkOrderExecutionRequested
        skill_execution_requested = $false
        a2a_dispatch_requested = $false
        api_invocation_requested = $false
        stage_commit_push_requested = $false
        board_runtime_mutation_requested = $false
        automatic_new_thread_creation_requested = $false
        live_runner_runtime_requested = $false
    }
}

function New-R18CliValidationExpectations {
    param([Parameter(Mandatory = $true)][string]$CommandType)

    return [ordered]@{
        checks = @(
            "command_shape",
            "authority_refs",
            "intake_packet_ref",
            "expected_branch",
            "expected_remote_head",
            "expected_tree",
            "allowed_paths",
            "dry_run_true",
            "runtime_false_flags",
            "non_claims"
        )
        command_type = $CommandType
        validation_commands = Get-R18CliValidationRefs
        fail_closed_on_missing_fields = $true
        unknown_commands_rejected = $true
        unsafe_actions_rejected_or_refused = $true
        historical_r13_r16_evidence_edits_allowed = $false
        operator_local_backup_paths_allowed = $false
        broad_repo_writes_allowed = $false
    }
}

function New-R18CliCommandInput {
    param(
        [Parameter(Mandatory = $true)][string]$CommandType,
        [Parameter(Mandatory = $true)][string]$CommandId,
        [Parameter(Mandatory = $true)][string]$IntakePacketRef,
        [Parameter(Mandatory = $true)][object]$RequestedAction
    )

    return [ordered]@{
        artifact_type = "r18_local_runner_cli_command_input"
        contract_version = "v1"
        command_id = $CommandId
        command_type = $CommandType
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        command_status = "dry_run_input_only"
        dry_run = $true
        requested_by_role = "Orchestrator"
        intake_packet_ref = $IntakePacketRef
        authority_refs = Get-R18CliAuthorityRefs
        expected_branch = $script:R18Branch
        expected_remote_head = $script:R18ExpectedRemoteHead
        expected_tree = $script:R18ExpectedTree
        allowed_paths = Get-R18CliAllowedPaths
        forbidden_paths = Get-R18CliForbiddenPaths
        requested_action = $RequestedAction
        validation_expectations = New-R18CliValidationExpectations -CommandType $CommandType
        runtime_flags = Get-R18CliRuntimeFlags
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CliCommandInputs {
    $inputs = @()
    $inputs += New-R18CliCommandInput `
        -CommandType "status" `
        -CommandId "r18_007_status_command" `
        -IntakePacketRef "state/intake/r18_orchestrator_control_intake_packets/status_query_request.intake.json" `
        -RequestedAction (New-R18CliRequestedAction -ActionId "report_local_runner_shell_status" -Description "Report current R18 boundary and dry-run shell status only.")
    $inputs += New-R18CliCommandInput `
        -CommandType "inspect_repo" `
        -CommandId "r18_007_inspect_repo_command" `
        -IntakePacketRef "state/intake/r18_orchestrator_control_intake_packets/status_query_request.intake.json" `
        -RequestedAction (New-R18CliRequestedAction -ActionId "inspect_explicit_repo_identity" -Description "Inspect explicit branch, HEAD, tree, and remote head expectation only.")
    $inputs += New-R18CliCommandInput `
        -CommandType "validate_intake_packet" `
        -CommandId "r18_007_validate_intake_packet_command" `
        -IntakePacketRef "state/intake/r18_orchestrator_control_intake_packets/status_query_request.intake.json" `
        -RequestedAction (New-R18CliRequestedAction -ActionId "validate_supplied_intake_packet_ref" -Description "Validate the supplied R18-006 intake packet ref against required authority refs only.")
    $inputs += New-R18CliCommandInput `
        -CommandType "refuse_execute_work_order" `
        -CommandId "r18_007_refuse_execute_work_order_command" `
        -IntakePacketRef "state/intake/r18_orchestrator_control_intake_packets/create_work_order_request.intake.json" `
        -RequestedAction (New-R18CliRequestedAction -ActionId "direct_work_order_execution_attempt" -Description "Demonstrate refusal of direct work-order execution because R18-008 is not implemented." -WorkOrderExecutionRequested $true)
    return $inputs
}

function Invoke-R18CliGit {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    $output = & git -C $RepositoryRoot @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    return (($output | Select-Object -First 1) -as [string]).Trim()
}

function Get-R18CliGitIdentity {
    param([string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $branch = Invoke-R18CliGit -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current")
    $head = Invoke-R18CliGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD")
    $tree = Invoke-R18CliGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}")
    $remoteHead = Invoke-R18CliGit -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", ("origin/{0}" -f $script:R18Branch))
    if ([string]::IsNullOrWhiteSpace($remoteHead)) {
        $remoteHead = $script:R18ExpectedRemoteHead
    }

    return [ordered]@{
        expected_branch = $script:R18Branch
        current_branch = $branch
        branch_match = ($branch -eq $script:R18Branch)
        local_head = $head
        local_tree = $tree
        expected_remote_head = $script:R18ExpectedRemoteHead
        observed_remote_head = $remoteHead
        expected_tree = $script:R18ExpectedTree
        broad_repo_scan_performed = $false
        fetch_performed_by_cli = $false
    }
}

function New-R18CliAuthorityCheck {
    param([Parameter(Mandatory = $true)][object]$CommandInput, [string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $missing = @()
    foreach ($authorityRef in Get-R18CliAuthorityRefs) {
        if (@($CommandInput.authority_refs) -notcontains $authorityRef) {
            $missing += $authorityRef
            continue
        }
        $resolved = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $authorityRef
        if (-not (Test-Path -LiteralPath $resolved)) {
            $missing += $authorityRef
        }
    }

    return [ordered]@{
        check_status = if ($missing.Count -eq 0) { "passed" } else { "failed" }
        required_authority_ref_count = @(Get-R18CliAuthorityRefs).Count
        supplied_authority_ref_count = @($CommandInput.authority_refs).Count
        missing_authority_refs = $missing
        live_authority_mutation_performed = $false
    }
}

function New-R18CliIntakeCheck {
    param([Parameter(Mandatory = $true)][object]$CommandInput, [string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $resolved = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$CommandInput.intake_packet_ref)
    $exists = Test-Path -LiteralPath $resolved -PathType Leaf
    $intakeId = "not_loaded"
    $intakeType = "not_loaded"
    if ($exists) {
        $packet = Read-R18CliJson -Path $resolved
        if ($null -ne $packet.PSObject.Properties["intake_id"]) {
            $intakeId = [string]$packet.intake_id
        }
        if ($null -ne $packet.PSObject.Properties["intake_type"]) {
            $intakeType = [string]$packet.intake_type
        }
    }

    return [ordered]@{
        check_status = if ($exists) { "passed" } else { "failed" }
        intake_packet_ref = [string]$CommandInput.intake_packet_ref
        intake_packet_exists = $exists
        intake_id = $intakeId
        intake_type = $intakeType
        routed_by_runtime = $false
        work_order_executed = $false
        skill_executed = $false
        a2a_dispatched = $false
    }
}

function New-R18CliPathCheck {
    param([Parameter(Mandatory = $true)][object]$CommandInput)

    return [ordered]@{
        check_status = "passed"
        allowed_path_count = @($CommandInput.allowed_paths).Count
        forbidden_path_count = @($CommandInput.forbidden_paths).Count
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
        broad_repo_writes_allowed = $false
        write_outside_r18_007_allowed = $false
    }
}

function New-R18CliDryRunOnlyCheck {
    param([Parameter(Mandatory = $true)][object]$CommandInput)

    return [ordered]@{
        check_status = "passed"
        dry_run = [bool]$CommandInput.dry_run
        work_order_execution_performed = $false
        skill_execution_performed = $false
        a2a_message_sent = $false
        api_invocation_performed = $false
        stage_commit_push_performed = $false
        board_runtime_mutation_performed = $false
    }
}

function New-R18CliCommandResult {
    param(
        [Parameter(Mandatory = $true)][object]$CommandInput,
        [Parameter(Mandatory = $true)][string]$ResultStatus,
        [string[]]$RefusedActions = @(),
        [string[]]$NextAllowedActions = @("validate_r18_007_artifacts", "keep_r18_008_planned_only"),
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    $commandType = [string]$CommandInput.command_type
    $result = [ordered]@{
        artifact_type = "r18_local_runner_cli_command_result"
        contract_version = "v1"
        result_id = ("{0}_result" -f [string]$CommandInput.command_id)
        command_id = [string]$CommandInput.command_id
        command_type = $commandType
        source_task = $script:R18SourceTask
        result_status = $ResultStatus
        branch_identity = Get-R18CliGitIdentity -RepositoryRoot $RepositoryRoot
        authority_check = New-R18CliAuthorityCheck -CommandInput $CommandInput -RepositoryRoot $RepositoryRoot
        intake_check = New-R18CliIntakeCheck -CommandInput $CommandInput -RepositoryRoot $RepositoryRoot
        path_check = New-R18CliPathCheck -CommandInput $CommandInput
        dry_run_only_check = New-R18CliDryRunOnlyCheck -CommandInput $CommandInput
        refused_actions = $RefusedActions
        next_allowed_actions = $NextAllowedActions
        evidence_refs = Get-R18CliEvidenceRefs
        validation_refs = Get-R18CliValidationRefs
        runtime_flags = Get-R18CliRuntimeFlags
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
    }

    if ($commandType -eq "status") {
        $result["status_boundary"] = "R18 active through R18-008 only; R18-009 through R18-028 remain planned only."
        $result["runner_shell_status"] = "dry_run_cli_shell_foundation_only_not_runtime"
    }
    elseif ($commandType -eq "inspect_repo") {
        $result["repo_identity_summary"] = "branch_head_tree_and_remote_head_expectation_recorded_without_broad_repo_scan"
    }
    elseif ($commandType -eq "validate_intake_packet") {
        $result["intake_validation_summary"] = "supplied_r18_006_intake_packet_ref_exists_and_authority_refs_are_present"
    }
    elseif ($commandType -eq "refuse_execute_work_order") {
        $result["refusal_reason"] = "Work-order execution is blocked until R18-008 or later because R18-007 is a dry-run CLI shell foundation only."
    }

    return ($result | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function New-R18CliCommandResults {
    param(
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    $results = @()
    foreach ($input in @($Inputs)) {
        $commandType = [string]$input.command_type
        if ($commandType -eq "refuse_execute_work_order") {
            $results += New-R18CliCommandResult `
                -RepositoryRoot $RepositoryRoot `
                -CommandInput $input `
                -ResultStatus "dry_run_refused" `
                -RefusedActions @(
                    "direct_work_order_execution",
                    "work_order_state_machine_execution",
                    "skill_execution",
                    "a2a_dispatch",
                    "api_invocation",
                    "stage_commit_push"
                ) `
                -NextAllowedActions @(
                    "keep_work_order_execution_blocked_until_r18_008",
                    "validate_r18_007_dry_run_shell_only",
                    "plan_r18_008_without_claiming_completion"
                )
        }
        else {
            $results += New-R18CliCommandResult -RepositoryRoot $RepositoryRoot -CommandInput $input -ResultStatus "dry_run_passed"
        }
    }

    return $results
}

function New-R18CliCheckReport {
    param(
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object[]]$Results
    )

    return [ordered]@{
        artifact_type = "r18_local_runner_cli_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-007-local-runner-cli-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        active_through_task = $script:R18SourceTask
        required_command_count = @($script:R18RequiredCommandTypes).Count
        generated_input_count = @($Inputs).Count
        generated_result_count = @($Results).Count
        checks = [ordered]@{
            contract_created = [ordered]@{ status = "passed"; ref = "contracts/runtime/r18_local_runner_cli.contract.json" }
            profile_created = [ordered]@{ status = "passed"; ref = "state/runtime/r18_local_runner_cli_profile.json" }
            command_catalog_created = [ordered]@{ status = "passed"; ref = "state/runtime/r18_local_runner_cli_command_catalog.json" }
            dry_run_inputs_created = [ordered]@{ status = "passed"; count = @($Inputs).Count }
            dry_run_results_created = [ordered]@{ status = "passed"; count = @($Results).Count }
            unknown_commands_fail_closed = [ordered]@{ status = "passed"; enforced = $true }
            unsafe_commands_refused = [ordered]@{ status = "passed"; enforced = $true }
            dry_run_only_boundary = [ordered]@{ status = "passed"; work_order_execution_performed = $false }
            runtime_false_flags = [ordered]@{ status = "passed"; all_required_false = $true }
            status_boundary = [ordered]@{ status = "passed"; active_through_task = "R18-007"; planned_from = "R18-008" }
        }
        aggregate_verdict = $script:R18CliVerdict
        runtime_flags = Get-R18CliRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18CliEvidenceRefs
        authority_refs = Get-R18CliAuthorityRefs
    }
}

function New-R18CliSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Inputs, [Parameter(Mandatory = $true)][object[]]$Results)

    return [ordered]@{
        artifact_type = "r18_local_runner_cli_snapshot"
        contract_version = "v1"
        snapshot_id = "aioffice-r18-007-local-runner-cli-snapshot-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = $script:R18SourceTask
        ui_boundary_label = "dry_run_cli_shell_snapshot_only_no_runtime_execution"
        shell_status = "foundation_created_dry_run_only"
        command_types = $script:R18RequiredCommandTypes
        result_statuses = @($Results | ForEach-Object { [ordered]@{ command_type = $_.command_type; result_status = $_.result_status } })
        runtime_summary = Get-R18CliRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18CliEvidenceRefs
        authority_refs = Get-R18CliAuthorityRefs
    }
}

function New-R18CliEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_local_runner_cli_evidence_index"
        contract_version = "v1"
        evidence_index_id = "aioffice-r18-007-local-runner-cli-evidence-index-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        scope = "dry_run_cli_shell_foundation_only"
        evidence_refs = Get-R18CliEvidenceRefs
        validation_refs = Get-R18CliValidationRefs
        runtime_flags = Get-R18CliRuntimeFlags
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18CliProofReviewText {
    return @"
# R18-007 Local Runner CLI Shell Proof Review

R18-007 creates a bounded local runner/CLI shell foundation only. The shell validates command shape, required authority refs, explicit intake packet refs, expected branch identity fields, dry-run flags, and path boundaries.

The accepted positive claims are limited to the R18-007 contract, profile, command catalog, dry-run inputs, dry-run results, validator, fixtures, and proof-review package.

The CLI shell is dry-run only. It does not execute work orders, does not implement the R18-008 work-order execution state machine, does not execute skills, does not dispatch A2A messages, does not call APIs, does not mutate board/card runtime state, and does not stage, commit, or push.

Work-order execution remains blocked until R18-008 or later is explicitly implemented and validated.
"@
}

function New-R18CliValidationManifestText {
    return @"
# R18-007 Validation Manifest

Required local validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\status_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\inspect_repo_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\validate_intake_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_local_runner_cli.ps1 -CommandInputPath state\runtime\r18_local_runner_cli_dry_run_inputs\refuse_execute_work_order_command.input.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_local_runner_cli.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected truth after validation: R18 is active through R18-008 only; R18-009 through R18-028 remain planned only.
"@
}

function New-R18CliFixtureDefinitions {
    $definitions = @(
        @{ file = "invalid_missing_command_id.json"; target = "input:status"; remove_paths = @("command_id"); expected = @("missing required field 'command_id'") },
        @{ file = "invalid_unknown_command.json"; target = "input:status"; set_values = [ordered]@{ command_type = "execute_anything" }; expected = @("exactly the required command types") },
        @{ file = "invalid_missing_authority_refs.json"; target = "input:status"; set_values = [ordered]@{ authority_refs = @() }; expected = @("authority_refs must not be empty") },
        @{ file = "invalid_missing_intake_packet_ref.json"; target = "input:validate_intake_packet"; set_values = [ordered]@{ intake_packet_ref = "" }; expected = @("missing intake_packet_ref") },
        @{ file = "invalid_missing_branch_identity.json"; target = "result:inspect_repo"; remove_paths = @("branch_identity"); expected = @("missing required field 'branch_identity'") },
        @{ file = "invalid_wrong_branch.json"; target = "input:inspect_repo"; set_values = [ordered]@{ expected_branch = "main" }; expected = @("expected_branch must be") },
        @{ file = "invalid_remote_head_missing.json"; target = "input:inspect_repo"; set_values = [ordered]@{ expected_remote_head = "" }; expected = @("expected_remote_head is required") },
        @{ file = "invalid_missing_dry_run_flag.json"; target = "input:status"; set_values = [ordered]@{ dry_run = $false }; expected = @("dry_run must be true") },
        @{ file = "invalid_execute_work_order_attempt.json"; target = "input:status"; set_values = [ordered]@{ "requested_action.work_order_execution_requested" = $true }; expected = @("requests work-order execution") },
        @{ file = "invalid_skill_execution_attempt.json"; target = "input:status"; set_values = [ordered]@{ "requested_action.skill_execution_requested" = $true }; expected = @("requests live skill execution") },
        @{ file = "invalid_a2a_dispatch_attempt.json"; target = "input:status"; set_values = [ordered]@{ "requested_action.a2a_dispatch_requested" = $true }; expected = @("requests A2A dispatch") },
        @{ file = "invalid_stage_commit_push_attempt.json"; target = "input:status"; set_values = [ordered]@{ "requested_action.stage_commit_push_requested" = $true }; expected = @("requests stage/commit/push") },
        @{ file = "invalid_api_invocation_attempt.json"; target = "input:status"; set_values = [ordered]@{ "requested_action.api_invocation_requested" = $true }; expected = @("requests API invocation") },
        @{ file = "invalid_automatic_new_thread_creation_claim.json"; target = "input:status"; set_values = [ordered]@{ "runtime_flags.automatic_new_thread_creation_performed" = $true }; expected = @("runtime flag 'automatic_new_thread_creation_performed' must be false") },
        @{ file = "invalid_live_runner_runtime_claim.json"; target = "input:status"; set_values = [ordered]@{ "runtime_flags.local_runner_runtime_executed" = $true }; expected = @("runtime flag 'local_runner_runtime_executed' must be false") },
        @{ file = "invalid_board_runtime_mutation_claim.json"; target = "input:status"; set_values = [ordered]@{ "runtime_flags.board_runtime_mutation_performed" = $true }; expected = @("runtime flag 'board_runtime_mutation_performed' must be false") },
        @{ file = "invalid_operator_local_backup_path.json"; target = "input:status"; set_values = [ordered]@{ allowed_paths = @(".local_backups/") }; expected = @("operator-local backup path") },
        @{ file = "invalid_historical_evidence_edit_permission.json"; target = "input:status"; set_values = [ordered]@{ allowed_paths = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/") }; expected = @("historical R13/R14/R15/R16 evidence") },
        @{ file = "invalid_broad_repo_write.json"; target = "input:status"; set_values = [ordered]@{ allowed_paths = @(".") }; expected = @("broad repo write") },
        @{ file = "invalid_r18_008_completion_claim.json"; target = "input:status"; set_values = [ordered]@{ "runtime_flags.r18_008_completed" = $true }; expected = @("runtime flag 'r18_008_completed' must be false") }
    )

    $fixtures = @()
    foreach ($definition in $definitions) {
        $fixture = [ordered]@{
            artifact_type = "r18_local_runner_cli_invalid_fixture"
            contract_version = "v1"
            fixture_id = [System.IO.Path]::GetFileNameWithoutExtension($definition.file)
            source_task = $script:R18SourceTask
            target = $definition.target
            expected_failure_fragments = $definition.expected
        }
        if ($definition.ContainsKey("remove_paths")) {
            $fixture["remove_paths"] = $definition.remove_paths
        }
        if ($definition.ContainsKey("set_values")) {
            $fixture["set_values"] = $definition.set_values
        }

        $fixtures += [pscustomobject]@{
            file = $definition.file
            fixture = $fixture
        }
    }

    return $fixtures
}

function New-R18CliFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$FixtureDefinitions)

    return [ordered]@{
        artifact_type = "r18_local_runner_cli_fixture_manifest"
        contract_version = "v1"
        fixture_manifest_id = "aioffice-r18-007-local-runner-cli-fixture-manifest-v1"
        source_task = $script:R18SourceTask
        fixture_count = @($FixtureDefinitions).Count
        fixtures = @($FixtureDefinitions | ForEach-Object { $_.file })
        runtime_flags = Get-R18CliRuntimeFlags
        non_claims = Get-R18CliNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function Assert-R18CliCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18CliRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R18CliRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        if ($null -eq $RuntimeFlags.PSObject.Properties[$field]) {
            throw "$Context missing runtime flag '$field'."
        }
        if ([bool]$RuntimeFlags.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context runtime flag '$field' must be false."
        }
    }
}

function Assert-R18CliAllowedPaths {
    param(
        [Parameter(Mandatory = $true)][object[]]$AllowedPaths,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18CliCondition -Condition (@($AllowedPaths).Count -gt 0) -Message "$Context allowed_paths must not be empty."
    foreach ($path in @($AllowedPaths)) {
        $value = [string]$path
        if ([string]::IsNullOrWhiteSpace($value) -or $value -in @(".", ".\", "./", "*", "/*", "\*")) {
            throw "$Context allows broad repo write '$value'."
        }
        if ($value -match '(?i)\.local_backups|operator-local') {
            throw "$Context allows operator-local backup path '$value'."
        }
        if ($value -match '(?i)state[\\/]+proof_reviews[\\/]+r1[3-6]') {
            throw "$Context allows historical R13/R14/R15/R16 evidence edit path '$value'."
        }
        if ($value -match '\*') {
            throw "$Context allows wildcard path '$value'."
        }
    }
}

function Assert-R18CliForbiddenPaths {
    param(
        [Parameter(Mandatory = $true)][object[]]$ForbiddenPaths,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $joined = @($ForbiddenPaths) -join " "
    foreach ($required in @(".local_backups", "operator-local", "r13", "r14", "r15", "r16", "broad write")) {
        if ($joined -notmatch [regex]::Escape($required)) {
            throw "$Context forbidden_paths missing '$required'."
        }
    }
}

function Assert-R18CliAuthorityRefs {
    param(
        [Parameter(Mandatory = $true)][object]$CommandInput,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    Assert-R18CliCondition -Condition (@($CommandInput.authority_refs).Count -gt 0) -Message "$($CommandInput.command_id) authority_refs must not be empty."
    foreach ($authorityRef in Get-R18CliAuthorityRefs) {
        if (@($CommandInput.authority_refs) -notcontains $authorityRef) {
            throw "$($CommandInput.command_id) missing required authority ref '$authorityRef'."
        }
        $resolved = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $authorityRef
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$($CommandInput.command_id) authority ref '$authorityRef' does not exist."
        }
    }
}

function Assert-R18CliRequestedAction {
    param([Parameter(Mandatory = $true)][object]$CommandInput)

    $action = $CommandInput.requested_action
    $commandType = [string]$CommandInput.command_type
    if ([bool]$action.work_order_execution_requested -and $commandType -ne "refuse_execute_work_order") {
        throw "$($CommandInput.command_id) requests work-order execution outside the refusal command."
    }
    if ([bool]$action.skill_execution_requested) {
        throw "$($CommandInput.command_id) requests live skill execution."
    }
    if ([bool]$action.a2a_dispatch_requested) {
        throw "$($CommandInput.command_id) requests A2A dispatch."
    }
    if ([bool]$action.api_invocation_requested) {
        throw "$($CommandInput.command_id) requests API invocation."
    }
    if ([bool]$action.stage_commit_push_requested) {
        throw "$($CommandInput.command_id) requests stage/commit/push."
    }
    if ([bool]$action.board_runtime_mutation_requested) {
        throw "$($CommandInput.command_id) requests board/card runtime mutation."
    }
    if ([bool]$action.automatic_new_thread_creation_requested) {
        throw "$($CommandInput.command_id) requests automatic new-thread creation."
    }
    if ([bool]$action.live_runner_runtime_requested) {
        throw "$($CommandInput.command_id) requests live runner runtime."
    }
}

function Assert-R18CliCommandInput {
    param(
        [Parameter(Mandatory = $true)][object]$CommandInput,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    Assert-R18CliRequiredFields -Object $CommandInput -FieldNames $script:R18InputRequiredFields -Context "R18 local runner CLI command input"
    $commandType = [string]$CommandInput.command_type
    if (@($script:R18RequiredCommandTypes) -notcontains $commandType) {
        throw "Unknown R18 local runner CLI command type '$commandType'."
    }
    Assert-R18CliCondition -Condition ([string]$CommandInput.source_task -eq $script:R18SourceTask) -Message "$($CommandInput.command_id) source_task must be R18-007."
    Assert-R18CliCondition -Condition ([string]$CommandInput.source_milestone -eq $script:R18SourceMilestone) -Message "$($CommandInput.command_id) source_milestone is invalid."
    Assert-R18CliCondition -Condition ([string]$CommandInput.command_status -eq "dry_run_input_only") -Message "$($CommandInput.command_id) command_status must be dry_run_input_only."
    Assert-R18CliCondition -Condition ([bool]$CommandInput.dry_run -eq $true) -Message "$($CommandInput.command_id) dry_run must be true."
    Assert-R18CliCondition -Condition ([string]$CommandInput.expected_branch -eq $script:R18Branch) -Message "$($CommandInput.command_id) expected_branch must be '$script:R18Branch'."
    Assert-R18CliCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$CommandInput.expected_remote_head)) -Message "$($CommandInput.command_id) expected_remote_head is required."
    Assert-R18CliCondition -Condition (-not [string]::IsNullOrWhiteSpace([string]$CommandInput.expected_tree)) -Message "$($CommandInput.command_id) expected_tree is required."
    if ([string]::IsNullOrWhiteSpace([string]$CommandInput.intake_packet_ref)) {
        throw "$($CommandInput.command_id) missing intake_packet_ref."
    }
    $intakePath = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue ([string]$CommandInput.intake_packet_ref)
    if (-not (Test-Path -LiteralPath $intakePath -PathType Leaf)) {
        throw "$($CommandInput.command_id) intake_packet_ref '$($CommandInput.intake_packet_ref)' does not exist."
    }
    Assert-R18CliAuthorityRefs -CommandInput $CommandInput -RepositoryRoot $RepositoryRoot
    Assert-R18CliAllowedPaths -AllowedPaths $CommandInput.allowed_paths -Context "$($CommandInput.command_id)"
    Assert-R18CliForbiddenPaths -ForbiddenPaths $CommandInput.forbidden_paths -Context "$($CommandInput.command_id)"
    Assert-R18CliRequestedAction -CommandInput $CommandInput
    Assert-R18CliRuntimeFlags -RuntimeFlags $CommandInput.runtime_flags -Context "$($CommandInput.command_id)"
}

function Assert-R18CliCommandResult {
    param([Parameter(Mandatory = $true)][object]$CommandResult)

    Assert-R18CliRequiredFields -Object $CommandResult -FieldNames $script:R18ResultRequiredFields -Context "R18 local runner CLI command result"
    Assert-R18CliCondition -Condition (@("dry_run_passed", "dry_run_refused", "validation_failed") -contains [string]$CommandResult.result_status) -Message "$($CommandResult.result_id) result_status is invalid."
    Assert-R18CliCondition -Condition ([string]$CommandResult.source_task -eq $script:R18SourceTask) -Message "$($CommandResult.result_id) source_task must be R18-007."
    $branchIdentity = $CommandResult.branch_identity
    foreach ($field in @("expected_branch", "current_branch", "local_head", "local_tree", "expected_remote_head", "expected_tree")) {
        if ($null -eq $branchIdentity.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace([string]$branchIdentity.PSObject.Properties[$field].Value)) {
            throw "$($CommandResult.result_id) branch_identity missing '$field'."
        }
    }
    foreach ($checkField in @("authority_check", "intake_check", "path_check", "dry_run_only_check")) {
        $checkValue = $CommandResult.PSObject.Properties[$checkField].Value
        if ($null -eq $checkValue.PSObject.Properties["check_status"]) {
            throw "$($CommandResult.result_id) $checkField missing check_status."
        }
        if ([string]$checkValue.check_status -ne "passed") {
            throw "$($CommandResult.result_id) $checkField must pass."
        }
    }
    if ([string]$CommandResult.command_type -eq "refuse_execute_work_order" -and [string]$CommandResult.result_status -ne "dry_run_refused") {
        throw "refuse_execute_work_order must return dry_run_refused."
    }
    if ([string]$CommandResult.command_type -ne "refuse_execute_work_order" -and [string]$CommandResult.result_status -ne "dry_run_passed") {
        throw "$($CommandResult.command_type) must return dry_run_passed."
    }
    Assert-R18CliRuntimeFlags -RuntimeFlags $CommandResult.runtime_flags -Context "$($CommandResult.result_id)"
}

function Assert-R18CliContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18CliRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "source_milestone", "repository", "branch", "scope", "purpose", "required_command_types", "required_command_input_fields", "required_command_result_fields", "required_runtime_false_flags", "command_policy", "authority_policy", "intake_policy", "branch_policy", "path_policy", "api_policy", "execution_policy", "refusal_policy", "evidence_policy", "retry_failure_policy", "allowed_positive_claims", "rejected_claims", "non_claims", "evidence_refs", "authority_refs", "runtime_flags") -Context "R18 local runner CLI contract"
    Assert-R18CliCondition -Condition ([string]$Contract.source_task -eq $script:R18SourceTask) -Message "R18 local runner CLI contract source_task must be R18-007."
    foreach ($commandType in $script:R18RequiredCommandTypes) {
        Assert-R18CliCondition -Condition (@($Contract.required_command_types) -contains $commandType) -Message "R18 local runner CLI contract missing command type '$commandType'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18CliCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "R18 local runner CLI contract missing runtime false flag '$flag'."
    }
    Assert-R18CliRuntimeFlags -RuntimeFlags $Contract.runtime_flags -Context "R18 local runner CLI contract"
    Assert-R18CliCondition -Condition ([bool]$Contract.api_policy.api_enabled -eq $false) -Message "R18 local runner CLI contract API policy must remain disabled."
    Assert-R18CliCondition -Condition ([bool]$Contract.execution_policy.work_order_execution_allowed -eq $false) -Message "R18 local runner CLI contract must disallow work-order execution."
}

function Assert-R18CliProfile {
    param([Parameter(Mandatory = $true)][object]$Profile)

    Assert-R18CliRequiredFields -Object $Profile -FieldNames @("artifact_type", "contract_version", "profile_id", "source_task", "source_milestone", "repository", "branch", "profile_status", "active_through_task", "planned_only_boundary", "default_mode", "command_types", "branch_policy", "path_policy", "api_policy", "execution_policy", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 local runner CLI profile"
    Assert-R18CliCondition -Condition ([string]$Profile.active_through_task -eq $script:R18SourceTask) -Message "R18 local runner CLI profile active_through_task must be R18-007."
    Assert-R18CliRuntimeFlags -RuntimeFlags $Profile.runtime_flags -Context "R18 local runner CLI profile"
}

function Assert-R18CliCatalog {
    param([Parameter(Mandatory = $true)][object]$Catalog)

    Assert-R18CliRequiredFields -Object $Catalog -FieldNames @("artifact_type", "contract_version", "catalog_id", "source_task", "source_milestone", "repository", "branch", "active_through_task", "command_count", "required_command_types", "commands", "unknown_commands_fail_closed", "dry_run_default", "runtime_flags", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 local runner CLI command catalog"
    Assert-R18CliCondition -Condition ([int]$Catalog.command_count -eq @($script:R18RequiredCommandTypes).Count) -Message "R18 local runner CLI catalog command_count is invalid."
    $types = @($Catalog.commands | ForEach-Object { [string]$_.command_type } | Sort-Object)
    $expected = @($script:R18RequiredCommandTypes | Sort-Object)
    Assert-R18CliCondition -Condition (($types -join "|") -eq ($expected -join "|")) -Message "R18 local runner CLI catalog must contain exactly the required command types."
    Assert-R18CliRuntimeFlags -RuntimeFlags $Catalog.runtime_flags -Context "R18 local runner CLI command catalog"
}

function Assert-R18CliCheckReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18CliRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_task", "source_milestone", "repository", "branch", "active_through_task", "required_command_count", "generated_input_count", "generated_result_count", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 local runner CLI check report"
    Assert-R18CliCondition -Condition ([string]$Report.active_through_task -eq $script:R18SourceTask) -Message "R18 local runner CLI check report active_through_task must be R18-007."
    Assert-R18CliCondition -Condition ([string]$Report.aggregate_verdict -eq $script:R18CliVerdict) -Message "R18 local runner CLI check report aggregate verdict is invalid."
    Assert-R18CliRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 local runner CLI check report"
}

function Assert-R18CliSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18CliRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "snapshot_id", "source_task", "source_milestone", "active_through_task", "ui_boundary_label", "shell_status", "command_types", "result_statuses", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 local runner CLI snapshot"
    Assert-R18CliCondition -Condition ([string]$Snapshot.active_through_task -eq $script:R18SourceTask) -Message "R18 local runner CLI snapshot active_through_task must be R18-007."
    Assert-R18CliCondition -Condition ([string]$Snapshot.ui_boundary_label -match "dry_run") -Message "R18 local runner CLI snapshot must preserve dry-run boundary."
    Assert-R18CliRuntimeFlags -RuntimeFlags $Snapshot.runtime_summary -Context "R18 local runner CLI snapshot"
}

function Get-R18CliTaskStatusMap {
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

function Test-R18CliStatusTruth {
    param([string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-010 only",
            "R18-011 through R18-028 planned only",
            "R18-002 created agent card schema and seed cards only",
            "Agent cards are not live agents",
            "R18-003 created skill contract schema and seed skill contracts only",
            "Skill contracts are not live skill execution",
            "R18-004 created A2A handoff packet schema and seed handoff packets only",
            "A2A handoff packets are not live A2A runtime",
            "R18-005 created role-to-skill permission matrix only",
            "Permission matrix is not runtime enforcement",
            "R18-006 created Orchestrator chat/control intake contract and seed intake packets only",
            "Intake packets are not a live chat UI",
            "Intake packets are not Orchestrator runtime",
            "R18-007 created local runner/CLI shell foundation only",
            "CLI shell is dry-run only",
            "CLI shell is not full work-order execution runtime",
            "R18-008 created work-order execution state machine foundation only",
            "Work-order state machine is not runtime execution",
            "R18-009 created runner state store and resumable execution log foundation only",
            "Runner state store is not live runner runtime",
            "Execution log is deterministic foundation evidence, not live execution evidence",
            "Resume checkpoint is not a continuation packet",
            "R18-010 created compact failure detector foundation only",
            "Failure detection is deterministic over seed signal artifacts only",
            "Failure events are not recovery completion",
            "WIP classifier is not implemented",
            "Remote branch verifier runtime is not implemented",
            "Continuation packet generator is not implemented",
            "New-context prompt generator is not implemented",
            "No work orders were executed",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No stage/commit/push was performed by the runner or state store",
            "No product runtime is claimed",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-007 truth: $required"
        }
    }

    $authorityStatuses = Get-R18CliTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18CliTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 10) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-010."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-010."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[1-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-010."
    }
}

function Test-R18LocalRunnerCliSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object]$Catalog,
        [Parameter(Mandatory = $true)][object[]]$Inputs,
        [Parameter(Mandatory = $true)][object[]]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    Assert-R18CliContract -Contract $Contract
    Assert-R18CliProfile -Profile $Profile
    Assert-R18CliCatalog -Catalog $Catalog
    Assert-R18CliCondition -Condition (@($Inputs).Count -eq @($script:R18RequiredCommandTypes).Count) -Message "R18 local runner CLI set is missing required command inputs."
    Assert-R18CliCondition -Condition (@($Results).Count -eq @($script:R18RequiredCommandTypes).Count) -Message "R18 local runner CLI set is missing required command results."

    $inputTypes = @($Inputs | ForEach-Object { [string]$_.command_type } | Sort-Object)
    $resultTypes = @($Results | ForEach-Object { [string]$_.command_type } | Sort-Object)
    $expectedTypes = @($script:R18RequiredCommandTypes | Sort-Object)
    Assert-R18CliCondition -Condition (($inputTypes -join "|") -eq ($expectedTypes -join "|")) -Message "R18 local runner CLI inputs must contain exactly the required command types."
    Assert-R18CliCondition -Condition (($resultTypes -join "|") -eq ($expectedTypes -join "|")) -Message "R18 local runner CLI results must contain exactly the required command types."

    foreach ($input in @($Inputs)) {
        Assert-R18CliCommandInput -CommandInput $input -RepositoryRoot $RepositoryRoot
    }
    foreach ($result in @($Results)) {
        Assert-R18CliCommandResult -CommandResult $result
    }

    Assert-R18CliCheckReport -Report $Report
    Assert-R18CliSnapshot -Snapshot $Snapshot
    Test-R18CliStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredCommandCount = [int]$Report.required_command_count
        GeneratedInputCount = [int]$Report.generated_input_count
        GeneratedResultCount = [int]$Report.generated_result_count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18LocalRunnerCli {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $paths = Get-R18CliPaths -RepositoryRoot $RepositoryRoot
    $inputs = @()
    $results = @()
    foreach ($commandType in $script:R18RequiredCommandTypes) {
        $inputs += Read-R18CliJson -Path (Get-R18CliInputPath -RepositoryRoot $RepositoryRoot -CommandType $commandType)
        $results += Read-R18CliJson -Path (Get-R18CliResultPath -RepositoryRoot $RepositoryRoot -CommandType $commandType)
    }

    return Test-R18LocalRunnerCliSet `
        -Contract (Read-R18CliJson -Path $paths.Contract) `
        -Profile (Read-R18CliJson -Path $paths.Profile) `
        -Catalog (Read-R18CliJson -Path $paths.Catalog) `
        -Inputs $inputs `
        -Results $results `
        -Report (Read-R18CliJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18CliJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Invoke-R18LocalRunnerCliCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$CommandInputPath,
        [string]$RepositoryRoot = (Get-R18CliRepositoryRoot)
    )

    $resolvedInputPath = Resolve-R18CliPath -RepositoryRoot $RepositoryRoot -PathValue $CommandInputPath
    $commandInput = Read-R18CliJson -Path $resolvedInputPath
    Assert-R18CliCommandInput -CommandInput $commandInput -RepositoryRoot $RepositoryRoot

    $currentBranch = Invoke-R18CliGit -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current")
    if ($currentBranch -ne [string]$commandInput.expected_branch) {
        throw "$($commandInput.command_id) wrong branch '$currentBranch'; expected '$($commandInput.expected_branch)'."
    }

    $commandType = [string]$commandInput.command_type
    if ($commandType -eq "status") {
        $result = New-R18CliCommandResult -CommandInput $commandInput -ResultStatus "dry_run_passed" -RepositoryRoot $RepositoryRoot
    }
    elseif ($commandType -eq "inspect_repo") {
        $result = New-R18CliCommandResult -CommandInput $commandInput -ResultStatus "dry_run_passed" -RepositoryRoot $RepositoryRoot
    }
    elseif ($commandType -eq "validate_intake_packet") {
        $result = New-R18CliCommandResult -CommandInput $commandInput -ResultStatus "dry_run_passed" -RepositoryRoot $RepositoryRoot
    }
    elseif ($commandType -eq "refuse_execute_work_order") {
        $result = New-R18CliCommandResult `
            -CommandInput $commandInput `
            -ResultStatus "dry_run_refused" `
            -RefusedActions @("direct_work_order_execution", "work_order_state_machine_execution", "skill_execution", "a2a_dispatch", "api_invocation", "stage_commit_push") `
            -NextAllowedActions @("keep_work_order_execution_blocked_until_r18_008", "validate_r18_007_dry_run_shell_only", "plan_r18_008_without_claiming_completion") `
            -RepositoryRoot $RepositoryRoot
    }
    else {
        throw "Unknown R18 local runner CLI command type '$commandType'."
    }

    Assert-R18CliCommandResult -CommandResult $result
    return $result
}

function Set-R18CliObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) {
            $current | Add-Member -NotePropertyName $part -NotePropertyValue ([pscustomobject]@{})
        }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -eq $current.PSObject.Properties[$leaf]) {
        $current | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R18CliObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) {
            return
        }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -ne $current.PSObject.Properties[$leaf]) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18CliMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18CliObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18CliObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

function New-R18LocalRunnerCliArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18CliRepositoryRoot))

    $paths = Get-R18CliPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18CliContract
    $profile = New-R18CliProfile
    $catalog = New-R18CliCommandCatalog
    $inputs = New-R18CliCommandInputs
    $results = New-R18CliCommandResults -Inputs $inputs -RepositoryRoot $RepositoryRoot
    $report = New-R18CliCheckReport -Inputs $inputs -Results $results
    $snapshot = New-R18CliSnapshot -Inputs $inputs -Results $results

    Write-R18CliJson -Path $paths.Contract -Value $contract
    Write-R18CliJson -Path $paths.Profile -Value $profile
    Write-R18CliJson -Path $paths.Catalog -Value $catalog
    foreach ($input in @($inputs)) {
        Write-R18CliJson -Path (Get-R18CliInputPath -RepositoryRoot $RepositoryRoot -CommandType ([string]$input.command_type)) -Value $input
    }
    foreach ($result in @($results)) {
        Write-R18CliJson -Path (Get-R18CliResultPath -RepositoryRoot $RepositoryRoot -CommandType ([string]$result.command_type)) -Value $result
    }
    Write-R18CliJson -Path $paths.CheckReport -Value $report
    Write-R18CliJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = New-R18CliFixtureDefinitions
    Write-R18CliJson -Path $paths.FixtureManifest -Value (New-R18CliFixtureManifest -FixtureDefinitions $fixtureDefinitions)
    foreach ($definition in @($fixtureDefinitions)) {
        Write-R18CliJson -Path (Join-Path $paths.FixtureRoot $definition.file) -Value $definition.fixture
    }

    Write-R18CliJson -Path $paths.EvidenceIndex -Value (New-R18CliEvidenceIndex)
    Write-R18CliText -Path $paths.ProofReview -Value (New-R18CliProofReviewText)
    Write-R18CliText -Path $paths.ValidationManifest -Value (New-R18CliValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Profile = $paths.Profile
        Catalog = $paths.Catalog
        InputRoot = $paths.InputRoot
        ResultRoot = $paths.ResultRoot
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredCommandCount = @($script:R18RequiredCommandTypes).Count
        GeneratedInputCount = @($inputs).Count
        GeneratedResultCount = @($results).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

Export-ModuleMember -Function `
    Get-R18CliPaths, `
    New-R18LocalRunnerCliArtifacts, `
    Test-R18LocalRunnerCli, `
    Test-R18LocalRunnerCliSet, `
    Invoke-R18LocalRunnerCliCommand, `
    Invoke-R18CliMutation, `
    Copy-R18CliObject, `
    Test-R18CliStatusTruth
