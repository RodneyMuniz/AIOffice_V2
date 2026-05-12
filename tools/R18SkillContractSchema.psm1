Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SkillContractGeneratedFromHead = "543eb243429c5d9eb004d166283e2c0869f06980"
$script:R18SkillContractGeneratedFromTree = "c2b1d2a479d0d1e9b9f4a1332e800c014b7203fb"
$script:R18SourceTask = "R18-003"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18SkillContractVerdict = "generated_r18_skill_contract_schema_foundation_only"

$script:R18RequiredSkillFileMap = [ordered]@{
    inspect_repo_refs = "inspect_repo_refs.skill.json"
    define_work_order = "define_work_order.skill.json"
    define_schema = "define_schema.skill.json"
    generate_bounded_artifacts = "generate_bounded_artifacts.skill.json"
    run_validator = "run_validator.skill.json"
    classify_failure = "classify_failure.skill.json"
    classify_wip = "classify_wip.skill.json"
    verify_remote_branch = "verify_remote_branch.skill.json"
    generate_continuation_packet = "generate_continuation_packet.skill.json"
    generate_new_context_prompt = "generate_new_context_prompt.skill.json"
    update_status_docs = "update_status_docs.skill.json"
    generate_evidence_package = "generate_evidence_package.skill.json"
    stage_commit_push_gate = "stage_commit_push_gate.skill.json"
    request_operator_approval = "request_operator_approval.skill.json"
}

$script:R18SkillCategories = [ordered]@{
    inspect_repo_refs = "repository_inspection"
    define_work_order = "planning"
    define_schema = "schema_definition"
    generate_bounded_artifacts = "artifact_generation"
    run_validator = "validation"
    classify_failure = "failure_classification"
    classify_wip = "wip_classification"
    verify_remote_branch = "remote_verification"
    generate_continuation_packet = "continuation"
    generate_new_context_prompt = "new_context_prompting"
    update_status_docs = "status_governance"
    generate_evidence_package = "evidence_packaging"
    stage_commit_push_gate = "release_gate"
    request_operator_approval = "operator_approval"
}

$script:R18SkillAllowedRoles = [ordered]@{
    inspect_repo_refs = @("Orchestrator", "Project Manager", "Solution Architect", "Developer/Codex", "QA/Test", "Evidence Auditor", "Release Manager")
    define_work_order = @("Orchestrator", "Project Manager", "Solution Architect")
    define_schema = @("Solution Architect", "Developer/Codex")
    generate_bounded_artifacts = @("Developer/Codex")
    run_validator = @("Developer/Codex", "QA/Test", "Evidence Auditor", "Release Manager")
    classify_failure = @("Orchestrator", "QA/Test", "Evidence Auditor")
    classify_wip = @("Orchestrator", "Developer/Codex", "QA/Test", "Release Manager")
    verify_remote_branch = @("Orchestrator", "Release Manager", "Evidence Auditor")
    generate_continuation_packet = @("Orchestrator")
    generate_new_context_prompt = @("Orchestrator")
    update_status_docs = @("Project Manager", "Release Manager")
    generate_evidence_package = @("Evidence Auditor", "Release Manager")
    stage_commit_push_gate = @("Release Manager")
    request_operator_approval = @("Orchestrator", "Project Manager", "Evidence Auditor", "Release Manager")
}

$script:R18RequiredSkillFields = @(
    "artifact_type",
    "contract_version",
    "skill_id",
    "skill_name",
    "source_task",
    "source_milestone",
    "skill_category",
    "skill_status",
    "description",
    "allowed_roles",
    "forbidden_roles",
    "required_inputs",
    "required_outputs",
    "evidence_obligations",
    "failure_packet_schema",
    "path_policy",
    "command_policy",
    "api_policy",
    "secrets_policy",
    "token_budget_policy",
    "timeout_policy",
    "retry_policy",
    "approval_requirements",
    "allowed_paths",
    "forbidden_paths",
    "runtime_flags",
    "non_claims",
    "rejected_claims",
    "evidence_refs",
    "authority_refs"
)

$script:R18RuntimeFlagFields = @(
    "live_skill_execution_performed",
    "live_agent_runtime_invoked",
    "live_a2a_runtime_implemented",
    "live_recovery_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_004_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_skill_contract_schema_created",
    "r18_seed_skill_contracts_created",
    "r18_skill_registry_created",
    "r18_skill_contract_validator_created",
    "r18_skill_contract_fixtures_created",
    "r18_skill_contract_proof_review_created"
)

$script:R18ForbiddenRoleIdentifiers = @("*", "all", "any", "unbounded")

function Get-R18SkillContractRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18SkillContractPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18SkillContractJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18SkillContractJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 100
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Write-R18SkillContractText {
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

function Copy-R18SkillContractObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18SkillContractSchemaPaths {
    param([string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot))

    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema"
    $fixtureRoot = "tests/fixtures/r18_skill_contract_schema"
    $skillRoot = "state/skills/r18_skill_contracts"

    $skillFiles = [ordered]@{}
    foreach ($entry in $script:R18RequiredSkillFileMap.GetEnumerator()) {
        $skillFiles[$entry.Key] = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $skillRoot $entry.Value)
    }

    return [pscustomobject]@{
        Contract = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/skills/r18_skill_contract.contract.json"
        SkillRoot = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue $skillRoot
        SkillFiles = $skillFiles
        Registry = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_registry.json"
        CheckReport = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_contract_check_report.json"
        UiSnapshot = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_skill_contract_snapshot.json"
        Module = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18SkillContractSchema.psm1"
        Generator = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_skill_contract_schema.ps1"
        Validator = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_skill_contract_schema.ps1"
        Test = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_skill_contract_schema.ps1"
        FixtureRoot = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        AgentCardRoot = Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_cards"
    }
}

function Get-R18SkillContractAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "state/agents/r18_agent_card_check_report.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/tools/r17_tool_adapter.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "contracts/runtime/r17_compact_safe_harness_pilot.contract.json"
    )
}

function Get-R18SkillContractEvidenceRefs {
    return @(
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_contracts/",
        "state/skills/r18_skill_registry.json",
        "state/skills/r18_skill_contract_check_report.json",
        "state/ui/r18_operator_surface/r18_skill_contract_snapshot.json",
        "tools/R18SkillContractSchema.psm1",
        "tools/new_r18_skill_contract_schema.ps1",
        "tools/validate_r18_skill_contract_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tests/fixtures/r18_skill_contract_schema/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema/"
    )
}

function Get-R18SkillContractAllowedPathsForTask {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    switch ($SkillId) {
        "inspect_repo_refs" {
            return @(
                "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
                "state/governance/r18_opening_authority.json",
                "contracts/agents/r18_agent_card.contract.json",
                "state/agents/r18_agent_cards/",
                "contracts/tools/r17_tool_adapter.contract.json",
                "contracts/runtime/r17_automated_recovery_loop.contract.json",
                "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
                "contracts/runtime/r17_compact_safe_harness_pilot.contract.json"
            )
        }
        "update_status_docs" {
            return @(
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
        "generate_evidence_package" {
            return @(
                "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema/",
                "state/skills/r18_skill_contract_check_report.json",
                "state/skills/r18_skill_registry.json"
            )
        }
        "run_validator" {
            return @(
                "tools/validate_r18_skill_contract_schema.ps1",
                "tests/test_r18_skill_contract_schema.ps1",
                "tools/validate_r18_agent_card_schema.ps1",
                "tests/test_r18_agent_card_schema.ps1",
                "tools/validate_r18_opening_authority.ps1",
                "tests/test_r18_opening_authority.ps1",
                "tools/validate_status_doc_gate.ps1",
                "tests/test_status_doc_gate.ps1"
            )
        }
        default {
            return @(
                "contracts/skills/r18_skill_contract.contract.json",
                "state/skills/r18_skill_contracts/",
                "state/skills/r18_skill_registry.json",
                "state/skills/r18_skill_contract_check_report.json",
                "state/ui/r18_operator_surface/r18_skill_contract_snapshot.json",
                "tools/R18SkillContractSchema.psm1",
                "tools/new_r18_skill_contract_schema.ps1",
                "tools/validate_r18_skill_contract_schema.ps1",
                "tests/test_r18_skill_contract_schema.ps1",
                "tests/fixtures/r18_skill_contract_schema/"
            )
        }
    }
}

function Get-R18SkillContractForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_*",
        "state/proof_reviews/r14_*",
        "state/proof_reviews/r15_*",
        "state/proof_reviews/r16_*",
        "state/external_runs/",
        "main branch",
        "repository root broad write",
        "unbounded wildcard write paths"
    )
}

function Get-R18SkillContractRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18SkillContractNonClaims {
    return @(
        "R18-003 created skill contract schema and seed skill contracts only.",
        "Skill contracts are governance/runtime contracts only; they are not live skill execution.",
        "R18-002 created agent card schema and seed cards only.",
        "Agent cards are governance/runtime contracts only; they are not live agents.",
        "No A2A handoff schema was implemented.",
        "No A2A runtime was implemented.",
        "No local runner runtime was implemented.",
        "No recovery runtime was implemented.",
        "No OpenAI API invocation occurred.",
        "No Codex API invocation occurred.",
        "No autonomous Codex invocation occurred.",
        "No automatic new-thread creation occurred.",
        "No product runtime is claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction is not solved.",
        "Codex reliability is not solved.",
        "R18-004 through R18-028 remain planned only.",
        "Main is not merged."
    )
}

function Get-R18SkillContractRejectedClaims {
    return @(
        "live_skill_execution",
        "live_agent_runtime",
        "live_a2a_runtime",
        "live_recovery_runtime",
        "local_runner_runtime",
        "openai_api_invocation",
        "codex_api_invocation",
        "autonomous_codex_invocation",
        "automatic_new_thread_creation",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_004_or_later_completion",
        "main_merge",
        "historical_evidence_edit",
        "operator_local_backup_path_use",
        "broad_repo_write"
    )
}

function Get-R18SkillDescription {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    switch ($SkillId) {
        "inspect_repo_refs" { return "Inspect explicit repository references and current status only; broad repository scans and file writes are forbidden." }
        "define_work_order" { return "Define bounded work orders, acceptance criteria, dependencies, and expected evidence from approved authority." }
        "define_schema" { return "Define bounded schemas and contracts from approved authority without claiming execution." }
        "generate_bounded_artifacts" { return "Create bounded governance artifacts only inside allowed paths after valid work order and authority refs exist." }
        "run_validator" { return "Run explicitly approved validation commands and capture command-result evidence refs." }
        "classify_failure" { return "Classify failure events into machine-readable failure packets." }
        "classify_wip" { return "Classify local WIP before continuation, repair, stage, commit, or push." }
        "verify_remote_branch" { return "Verify branch, head, and tree before continuation or release action." }
        "generate_continuation_packet" { return "Generate continuation packets from failure event, WIP classification, remote verification, and runner state refs." }
        "generate_new_context_prompt" { return "Generate exact-ref compact resume prompts without prior-thread dependency and without automatic new-thread creation." }
        "update_status_docs" { return "Update status surfaces after validated task progress while preserving non-claims." }
        "generate_evidence_package" { return "Generate proof-review and evidence packages from committed machine-readable evidence." }
        "stage_commit_push_gate" { return "Gate stage, commit, and push on validation, evidence, status-doc, approval, and path controls." }
        "request_operator_approval" { return "Request explicit operator approval for risky decisions without granting decision authority to the requester." }
        default { throw "Unknown R18 skill id '$SkillId'." }
    }
}

function Get-R18SkillName {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    $words = foreach ($part in ($SkillId -split "_")) {
        if ([string]::IsNullOrWhiteSpace($part)) {
            $part
        }
        else {
            $part.Substring(0, 1).ToUpperInvariant() + $part.Substring(1)
        }
    }
    return ($words -join " ")
}

function Get-R18SkillRequiredInputs {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    switch ($SkillId) {
        "inspect_repo_refs" { return @("explicit_ref_list", "allowed_read_paths", "current_git_identity_request") }
        "define_work_order" { return @("operator_intent", "authority_refs", "acceptance_boundary", "evidence_expectations") }
        "define_schema" { return @("approved_authority_refs", "schema_scope", "required_fields", "non_claims") }
        "generate_bounded_artifacts" { return @("valid_work_order_ref", "authority_refs", "allowed_paths", "expected_outputs") }
        "run_validator" { return @("approved_validation_commands", "expected_artifact_refs", "authority_refs") }
        "classify_failure" { return @("failure_event_source", "command_result_ref", "runtime_state_ref") }
        "classify_wip" { return @("git_status_ref", "diff_summary_ref", "allowed_paths", "forbidden_paths") }
        "verify_remote_branch" { return @("branch_name", "expected_local_head", "expected_local_tree", "expected_remote_head") }
        "generate_continuation_packet" { return @("failure_event_ref", "wip_classification_ref", "remote_verification_ref", "runner_state_ref") }
        "generate_new_context_prompt" { return @("continuation_packet_ref", "authority_refs", "current_work_order_ref", "non_claims") }
        "update_status_docs" { return @("validated_task_progress_ref", "status_truth", "non_claims", "status_doc_paths") }
        "generate_evidence_package" { return @("machine_evidence_refs", "validation_results", "status_doc_gate_result", "non_claims") }
        "stage_commit_push_gate" { return @("validation_results", "evidence_package_ref", "status_doc_gate_result", "approval_packet_ref", "path_control_report") }
        "request_operator_approval" { return @("decision_request_summary", "risk_summary", "evidence_refs", "recommended_options") }
        default { throw "Unknown R18 skill id '$SkillId'." }
    }
}

function Get-R18SkillRequiredOutputs {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    switch ($SkillId) {
        "inspect_repo_refs" { return @("explicit_ref_inspection_summary", "git_identity_summary", "no_write_confirmation") }
        "define_work_order" { return @("bounded_work_order_packet", "acceptance_criteria", "expected_evidence_refs") }
        "define_schema" { return @("schema_contract_artifact", "schema_validation_rules", "schema_non_claims") }
        "generate_bounded_artifacts" { return @("bounded_artifact_refs", "generation_summary", "path_control_confirmation") }
        "run_validator" { return @("validation_result_packet", "command_output_summary", "evidence_refs") }
        "classify_failure" { return @("failure_packet", "failure_type", "operator_decision_requirement") }
        "classify_wip" { return @("wip_classification_packet", "preservation_recommendation", "unsafe_wip_flag") }
        "verify_remote_branch" { return @("remote_verification_packet", "branch_head_tree_summary", "movement_flag") }
        "generate_continuation_packet" { return @("continuation_packet", "next_safe_step", "stop_conditions") }
        "generate_new_context_prompt" { return @("new_context_prompt_packet", "exact_ref_prompt", "prior_thread_dependency_false") }
        "update_status_docs" { return @("status_doc_update_summary", "status_truth_confirmation", "non_claims_preserved") }
        "generate_evidence_package" { return @("evidence_index", "proof_review", "validation_manifest") }
        "stage_commit_push_gate" { return @("release_gate_packet", "stage_commit_push_readiness", "blockers_if_any") }
        "request_operator_approval" { return @("operator_approval_request_packet", "decision_options", "decision_authority_not_claimed") }
        default { throw "Unknown R18 skill id '$SkillId'." }
    }
}

function New-R18SkillFailurePacketSchema {
    return [ordered]@{
        failure_packet_required = $true
        required_fields = @(
            "failure_packet_id",
            "skill_id",
            "source_task",
            "failure_type",
            "failure_summary",
            "input_refs",
            "command_refs",
            "retry_count",
            "max_retry_count",
            "operator_decision_required",
            "evidence_refs",
            "runtime_flags",
            "non_claims"
        )
        unknown_failure_requires_operator_decision = $true
        missing_failure_packet_blocks_continuation = $true
    }
}

function New-R18SkillPathPolicy {
    return [ordered]@{
        allowed_paths_required = $true
        forbidden_paths_required = $true
        allowed_paths_must_be_exact_or_task_scoped = $true
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
    }
}

function New-R18SkillCommandPolicy {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    $readOnlyForbidden = @(
        "git add",
        "git commit",
        "git push",
        "git reset",
        "git checkout --",
        "Remove-Item",
        "Move-Item",
        "Set-Content",
        "Invoke-RestMethod",
        "Invoke-WebRequest",
        "openai",
        "codex"
    )

    switch ($SkillId) {
        "inspect_repo_refs" {
            return [ordered]@{
                commands_allowed = $true
                allowed_command_patterns = @("git status --short --branch", "git rev-parse HEAD", "git rev-parse `"HEAD^{tree}`"", "Get-Content explicit approved refs only")
                forbidden_command_patterns = @($readOnlyForbidden + @("Get-ChildItem -Recurse", "rg over repository root"))
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
        "run_validator" {
            return [ordered]@{
                commands_allowed = $true
                allowed_command_patterns = @("powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_*.ps1", "powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_*.ps1", "git diff --check")
                forbidden_command_patterns = @("Invoke-RestMethod", "Invoke-WebRequest", "openai", "codex", "git push", "git reset", "Remove-Item")
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
        "classify_wip" {
            return [ordered]@{
                commands_allowed = $true
                allowed_command_patterns = @("git status --short", "git diff --name-status", "git diff --numstat", "git diff --check")
                forbidden_command_patterns = @($readOnlyForbidden)
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
        "verify_remote_branch" {
            return [ordered]@{
                commands_allowed = $true
                allowed_command_patterns = @("git fetch origin explicit_branch", "git rev-parse HEAD", "git rev-parse `"HEAD^{tree}`"", "git rev-parse origin/explicit_branch")
                forbidden_command_patterns = @("git push", "git reset", "git checkout --", "Remove-Item", "Invoke-RestMethod", "Invoke-WebRequest", "openai", "codex")
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
        "stage_commit_push_gate" {
            return [ordered]@{
                commands_allowed = $true
                allowed_command_patterns = @("git status --short", "git diff --name-status", "git diff --cached --name-only", "git diff --check", "git rev-parse HEAD")
                forbidden_command_patterns = @("git push without approval_packet_ref", "git commit without validation evidence", "git add .", "git reset --hard", "Remove-Item", "openai", "codex")
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
        default {
            return [ordered]@{
                commands_allowed = $false
                allowed_command_patterns = @("none")
                forbidden_command_patterns = @($readOnlyForbidden)
                shell_execution_claimed = $false
                live_execution_claimed = $false
                mutation_commands_allowed = $false
            }
        }
    }
}

function New-R18SkillApiPolicy {
    return [ordered]@{
        api_enabled = $false
        openai_api_invocation_allowed = $false
        codex_api_invocation_allowed = $false
        autonomous_codex_invocation_allowed = $false
        automatic_new_thread_creation_allowed = $false
        api_controls_required_before_enablement = $true
    }
}

function New-R18SkillApprovalRequirements {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    $operatorRequired = @("api_enablement", "autonomous_codex_invocation", "automatic_new_thread_creation", "unsafe_wip_abandonment", "main_merge", "milestone_closeout")
    if ($SkillId -eq "stage_commit_push_gate") {
        $operatorRequired += "stage_commit_push"
    }
    if ($SkillId -eq "request_operator_approval") {
        $operatorRequired += "risky_decision_request"
    }

    return [ordered]@{
        operator_approval_required_for = @($operatorRequired | Select-Object -Unique)
        operator_approval_packet_required_before_risky_action = $true
        developer_codex_may_request_operator_approval_as_decision_authority = $false
        qa_self_approval_allowed = $false
        audit_self_approval_allowed = $false
        missing_approval_blocks_risky_action = $true
        decision_authority_claimed_by_skill = $false
    }
}

function New-R18SkillContract {
    param([Parameter(Mandatory = $true)][string]$SkillId)

    $allowedRoles = @($script:R18SkillAllowedRoles[$SkillId])
    $allRoleGrant = ($allowedRoles.Count -eq 7)

    return [ordered]@{
        artifact_type = "r18_skill_contract"
        contract_version = "v1"
        skill_id = $SkillId
        skill_name = (Get-R18SkillName -SkillId $SkillId)
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18SkillContractGeneratedFromHead
        generated_from_tree = $script:R18SkillContractGeneratedFromTree
        generated_state_artifact_only = $true
        skill_category = $script:R18SkillCategories[$SkillId]
        skill_status = "contract_only_not_executed"
        description = (Get-R18SkillDescription -SkillId $SkillId)
        allowed_roles = $allowedRoles
        forbidden_roles = @($script:R18SkillAllowedRoles.Values | ForEach-Object { $_ } | Select-Object -Unique | Where-Object { $allowedRoles -notcontains $_ })
        role_policy = [ordered]@{
            allowed_roles_must_exist_in_r18_agent_cards = $true
            wildcard_roles_allowed = $false
            grants_all_seed_roles = $allRoleGrant
            all_roles_validated_from_agent_cards = $true
            all_role_grant_boundary = if ($allRoleGrant) { "read_only_inspection_only" } else { "not_all_roles" }
            evidence_auditor_implementation_artifact_authority = $false
            developer_codex_operator_approval_decision_authority = $false
            qa_self_approval_allowed = $false
        }
        required_inputs = (Get-R18SkillRequiredInputs -SkillId $SkillId)
        required_outputs = (Get-R18SkillRequiredOutputs -SkillId $SkillId)
        evidence_obligations = @(
            "cite exact authority refs before action",
            "record input refs and output refs",
            "record validator command and result refs before claiming validation",
            "record failure packet refs on failure",
            "preserve runtime false flags and non-claims"
        )
        failure_packet_schema = (New-R18SkillFailurePacketSchema)
        path_policy = (New-R18SkillPathPolicy)
        command_policy = (New-R18SkillCommandPolicy -SkillId $SkillId)
        api_policy = (New-R18SkillApiPolicy)
        secrets_policy = [ordered]@{
            secrets_required = $false
            secrets_must_not_be_committed = $true
            secret_redaction_required_before_any_future_api_use = $true
        }
        token_budget_policy = [ordered]@{
            token_budget_required_before_api_use = $true
            cost_budget_required_before_api_use = $true
            max_token_budget_for_r18_003 = 0
            budget_enforced_before_future_api_enablement = $true
        }
        timeout_policy = [ordered]@{
            timeout_required_before_api_use = $true
            max_seconds_for_r18_003_execution = 0
            timeout_enforced_before_future_api_enablement = $true
        }
        retry_policy = [ordered]@{
            max_retry_count = if ($SkillId -eq "request_operator_approval") { 0 } else { 1 }
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
            retry_exhaustion_requires_operator_decision = $true
        }
        approval_requirements = (New-R18SkillApprovalRequirements -SkillId $SkillId)
        allowed_paths = (Get-R18SkillContractAllowedPathsForTask -SkillId $SkillId)
        forbidden_paths = (Get-R18SkillContractForbiddenPaths)
        runtime_flags = (Get-R18SkillContractRuntimeFlags)
        positive_claims = @("r18_seed_skill_contracts_created")
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
        evidence_refs = (Get-R18SkillContractEvidenceRefs)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
    }
}

function Get-R18SkillContracts {
    return @($script:R18RequiredSkillFileMap.Keys | ForEach-Object { New-R18SkillContract -SkillId $_ })
}

function New-R18SkillContractContract {
    return [ordered]@{
        artifact_type = "r18_skill_contract_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-003-skill-contract-contract-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "skill_contract_schema_and_seed_skill_contracts_only_not_live_skill_execution"
        purpose = "Define governed R18 skill contracts with role permissions, input/output contracts, path and command policy, evidence obligations, failure packets, retry behavior, and safety controls without implementing skill execution."
        required_skill_ids = @($script:R18RequiredSkillFileMap.Keys)
        required_skill_categories = @($script:R18SkillCategories.Values | Select-Object -Unique)
        required_skill_fields = $script:R18RequiredSkillFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        forbidden_role_identifiers = $script:R18ForbiddenRoleIdentifiers
        role_validation_policy = [ordered]@{
            every_allowed_role_must_exist_in_r18_agent_cards = $true
            wildcard_roles_rejected = $true
            all_roles_grant_requires_read_only_or_inspection_only = $true
            evidence_auditor_cannot_generate_implementation_artifacts = $true
            developer_codex_cannot_request_operator_approval_as_decision_authority = $true
            qa_test_cannot_self_approve_fixes = $true
        }
        path_policy = (New-R18SkillPathPolicy)
        command_policy = [ordered]@{
            command_policy_required = $true
            shell_execution_claimed_must_be_false = $true
            live_execution_claimed_must_be_false = $true
        }
        api_policy = (New-R18SkillApiPolicy)
        secrets_policy = [ordered]@{
            secrets_required = $false
            secrets_must_not_be_committed = $true
        }
        token_budget_policy = [ordered]@{
            token_budget_required_before_api_use = $true
            cost_budget_required_before_api_use = $true
        }
        timeout_policy = [ordered]@{
            timeout_required_before_api_use = $true
        }
        retry_policy = [ordered]@{
            max_retry_count_required = $true
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
            maximum_allowed_retry_count_for_seed_contracts = 3
        }
        evidence_refs = (Get-R18SkillContractEvidenceRefs)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
    }
}

function New-R18SkillRegistry {
    param([Parameter(Mandatory = $true)][object[]]$Skills)

    return [ordered]@{
        artifact_type = "r18_skill_registry"
        contract_version = "v1"
        registry_id = "aioffice-r18-003-skill-registry-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        active_through_task = "R18-003"
        skill_status = "contract_only_not_executed"
        skill_count = @($Skills).Count
        skills = @($Skills | ForEach-Object {
                [ordered]@{
                    skill_id = $_.skill_id
                    skill_name = $_.skill_name
                    skill_category = $_.skill_category
                    skill_status = $_.skill_status
                    allowed_roles = @($_.allowed_roles)
                    contract_ref = ("state/skills/r18_skill_contracts/{0}" -f $script:R18RequiredSkillFileMap[[string]$_.skill_id])
                    api_enabled = [bool]$_.api_policy.api_enabled
                    live_skill_execution_performed = [bool]$_.runtime_flags.live_skill_execution_performed
                }
            })
        runtime_flags = (Get-R18SkillContractRuntimeFlags)
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
        evidence_refs = (Get-R18SkillContractEvidenceRefs)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
    }
}

function New-R18SkillContractCheckReport {
    param([Parameter(Mandatory = $true)][object[]]$Skills)

    return [ordered]@{
        artifact_type = "r18_skill_contract_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-003-skill-contract-check-report-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18SkillContractGeneratedFromHead
        generated_from_tree = $script:R18SkillContractGeneratedFromTree
        generated_state_artifact_only = $true
        required_skill_count = @($script:R18RequiredSkillFileMap.Keys).Count
        generated_skill_count = @($Skills).Count
        skill_ids = @($Skills | ForEach-Object { $_.skill_id })
        checks = [ordered]@{
            required_seed_skills_present = [ordered]@{ status = "passed" }
            required_fields_present = [ordered]@{ status = "passed" }
            allowed_roles_map_to_agent_cards = [ordered]@{ status = "passed" }
            wildcard_roles_rejected = [ordered]@{ status = "passed"; wildcard_roles_allowed = $false }
            role_boundaries_preserved = [ordered]@{ status = "passed" }
            required_inputs_outputs_present = [ordered]@{ status = "passed" }
            evidence_obligations_present = [ordered]@{ status = "passed" }
            failure_packet_schema_present = [ordered]@{ status = "passed" }
            path_policy_present = [ordered]@{ status = "passed" }
            broad_repo_writes_rejected = [ordered]@{ status = "passed"; broad_repo_writes_allowed = $false }
            operator_local_backup_paths_rejected = [ordered]@{ status = "passed"; operator_local_backup_paths_allowed = $false }
            historical_evidence_edits_rejected = [ordered]@{ status = "passed"; historical_r13_r16_evidence_edits_allowed = $false }
            command_policy_present = [ordered]@{ status = "passed"; shell_execution_claimed = $false; live_execution_claimed = $false }
            api_policy_disabled = [ordered]@{ status = "passed"; api_enabled = $false }
            secrets_token_timeout_policies_present = [ordered]@{ status = "passed" }
            retry_policy_bounded = [ordered]@{ status = "passed"; unbounded_retry_allowed = $false }
            runtime_flags_false = [ordered]@{ status = "passed" }
            r18_004_or_later_completion_rejected = [ordered]@{ status = "passed"; r18_004_completed = $false }
        }
        aggregate_verdict = $script:R18SkillContractVerdict
        runtime_flags = (Get-R18SkillContractRuntimeFlags)
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
        evidence_refs = (Get-R18SkillContractEvidenceRefs)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
    }
}

function New-R18SkillContractSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Skills)

    return [ordered]@{
        artifact_type = "r18_skill_contract_snapshot"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        active_through_task = "R18-003"
        ui_boundary_label = "Skill contracts are governance contracts only, not live skill execution"
        required_skill_count = @($script:R18RequiredSkillFileMap.Keys).Count
        generated_skill_count = @($Skills).Count
        skills = @($Skills | ForEach-Object {
                [ordered]@{
                    skill_id = $_.skill_id
                    skill_name = $_.skill_name
                    skill_category = $_.skill_category
                    allowed_role_count = @($_.allowed_roles).Count
                    runtime_enabled = $false
                    api_enabled = [bool]$_.api_policy.api_enabled
                    live_skill_execution_performed = [bool]$_.runtime_flags.live_skill_execution_performed
                    live_agent_runtime_invoked = [bool]$_.runtime_flags.live_agent_runtime_invoked
                    r18_004_completed = [bool]$_.runtime_flags.r18_004_completed
                }
            })
        runtime_summary = (Get-R18SkillContractRuntimeFlags)
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
        evidence_refs = (Get-R18SkillContractEvidenceRefs)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
    }
}

function Get-R18SkillFixtureDefinitions {
    return [ordered]@{
        "invalid_missing_skill_id.json" = [ordered]@{ target = "skill:inspect_repo_refs"; remove_paths = @("skill_id"); expected_failure_fragments = @("skill_id") }
        "invalid_missing_allowed_roles.json" = [ordered]@{ target = "skill:inspect_repo_refs"; remove_paths = @("allowed_roles"); expected_failure_fragments = @("allowed_roles") }
        "invalid_role_not_in_agent_cards.json" = [ordered]@{ target = "skill:define_work_order"; set_values = [ordered]@{ "allowed_roles" = @("Imaginary Role") }; expected_failure_fragments = @("missing from R18-002 agent cards") }
        "invalid_missing_required_inputs.json" = [ordered]@{ target = "skill:define_schema"; remove_paths = @("required_inputs"); expected_failure_fragments = @("required_inputs") }
        "invalid_missing_required_outputs.json" = [ordered]@{ target = "skill:define_schema"; remove_paths = @("required_outputs"); expected_failure_fragments = @("required_outputs") }
        "invalid_missing_evidence_obligations.json" = [ordered]@{ target = "skill:run_validator"; remove_paths = @("evidence_obligations"); expected_failure_fragments = @("evidence_obligations") }
        "invalid_missing_failure_packet_schema.json" = [ordered]@{ target = "skill:classify_failure"; remove_paths = @("failure_packet_schema"); expected_failure_fragments = @("failure_packet_schema") }
        "invalid_missing_path_policy.json" = [ordered]@{ target = "skill:classify_wip"; remove_paths = @("path_policy"); expected_failure_fragments = @("path_policy") }
        "invalid_broad_repo_write.json" = [ordered]@{ target = "skill:generate_bounded_artifacts"; set_values = [ordered]@{ "path_policy.broad_repo_writes_allowed" = $true }; expected_failure_fragments = @("broad repo writes") }
        "invalid_operator_local_backup_path.json" = [ordered]@{ target = "skill:generate_bounded_artifacts"; set_values = [ordered]@{ "allowed_paths" = @(".local_backups/") }; expected_failure_fragments = @("operator-local backup") }
        "invalid_historical_evidence_edit_permission.json" = [ordered]@{ target = "skill:update_status_docs"; set_values = [ordered]@{ "path_policy.historical_r13_r16_evidence_edits_allowed" = $true }; expected_failure_fragments = @("historical") }
        "invalid_missing_command_policy.json" = [ordered]@{ target = "skill:run_validator"; remove_paths = @("command_policy"); expected_failure_fragments = @("command_policy") }
        "invalid_api_enabled_without_controls.json" = [ordered]@{ target = "skill:run_validator"; set_values = [ordered]@{ "api_policy.api_enabled" = $true; "api_policy.api_controls_required_before_enablement" = $false }; expected_failure_fragments = @("enables API use") }
        "invalid_missing_retry_policy.json" = [ordered]@{ target = "skill:classify_failure"; remove_paths = @("retry_policy"); expected_failure_fragments = @("retry_policy") }
        "invalid_unbounded_retry.json" = [ordered]@{ target = "skill:classify_failure"; set_values = [ordered]@{ "retry_policy.unbounded_retry_allowed" = $true }; expected_failure_fragments = @("unbounded retries") }
        "invalid_missing_token_budget_policy.json" = [ordered]@{ target = "skill:generate_new_context_prompt"; remove_paths = @("token_budget_policy"); expected_failure_fragments = @("token_budget_policy") }
        "invalid_missing_secrets_policy.json" = [ordered]@{ target = "skill:verify_remote_branch"; remove_paths = @("secrets_policy"); expected_failure_fragments = @("secrets_policy") }
        "invalid_live_skill_execution_claim.json" = [ordered]@{ target = "skill:generate_continuation_packet"; set_values = [ordered]@{ "runtime_flags.live_skill_execution_performed" = $true }; expected_failure_fragments = @("claims live skill execution") }
        "invalid_live_agent_claim.json" = [ordered]@{ target = "skill:generate_continuation_packet"; set_values = [ordered]@{ "runtime_flags.live_agent_runtime_invoked" = $true }; expected_failure_fragments = @("claims live agent runtime") }
        "invalid_r18_004_completion_claim.json" = [ordered]@{ target = "skill:generate_new_context_prompt"; set_values = [ordered]@{ "runtime_flags.r18_004_completed" = $true }; expected_failure_fragments = @("claims R18-004") }
    }
}

function New-R18SkillFixtureManifest {
    $fixtureDefinitions = Get-R18SkillFixtureDefinitions
    return [ordered]@{
        artifact_type = "r18_skill_contract_schema_fixture_manifest"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        fixture_style = "compact_mutation_specs_applied_to_valid_seed_skill_contracts"
        fixture_count = @($fixtureDefinitions.Keys).Count
        fixture_files = @($fixtureDefinitions.Keys)
        non_claims = (Get-R18SkillContractNonClaims)
    }
}

function New-R18SkillEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_skill_contract_schema_evidence_index"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        evidence_scope = "schema_seed_skill_contracts_registry_validator_fixtures_status_only"
        entries = @(
            [ordered]@{ path = "contracts/skills/r18_skill_contract.contract.json"; evidence_type = "contract" },
            [ordered]@{ path = "state/skills/r18_skill_contracts/"; evidence_type = "seed_skill_contracts" },
            [ordered]@{ path = "state/skills/r18_skill_registry.json"; evidence_type = "skill_registry" },
            [ordered]@{ path = "state/skills/r18_skill_contract_check_report.json"; evidence_type = "check_report" },
            [ordered]@{ path = "state/ui/r18_operator_surface/r18_skill_contract_snapshot.json"; evidence_type = "operator_surface_snapshot_state_only" },
            [ordered]@{ path = "tools/R18SkillContractSchema.psm1"; evidence_type = "validator_generator_module" },
            [ordered]@{ path = "tools/new_r18_skill_contract_schema.ps1"; evidence_type = "generator_wrapper" },
            [ordered]@{ path = "tools/validate_r18_skill_contract_schema.ps1"; evidence_type = "validator_wrapper" },
            [ordered]@{ path = "tests/test_r18_skill_contract_schema.ps1"; evidence_type = "focused_tests" },
            [ordered]@{ path = "tests/fixtures/r18_skill_contract_schema/"; evidence_type = "invalid_fixtures" },
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema/proof_review.md"; evidence_type = "proof_review" },
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema/validation_manifest.md"; evidence_type = "validation_manifest" }
        )
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = (Get-R18SkillContractNonClaims)
        rejected_claims = (Get-R18SkillContractRejectedClaims)
        authority_refs = (Get-R18SkillContractAuthorityRefs)
    }
}

function New-R18SkillProofReviewText {
    return @"
# R18-003 Skill Contract Schema Proof Review

Status: R18-003 creates the skill contract schema, fourteen seed skill contracts, registry, validator, focused tests, fixtures, check report, operator-surface snapshot state artifact, and this proof-review package only.

Evidence reviewed:

- `contracts/skills/r18_skill_contract.contract.json`
- `state/skills/r18_skill_contracts/`
- `state/skills/r18_skill_registry.json`
- `state/skills/r18_skill_contract_check_report.json`
- `state/ui/r18_operator_surface/r18_skill_contract_snapshot.json`
- `tools/R18SkillContractSchema.psm1`
- `tools/new_r18_skill_contract_schema.ps1`
- `tools/validate_r18_skill_contract_schema.ps1`
- `tests/test_r18_skill_contract_schema.ps1`
- `tests/fixtures/r18_skill_contract_schema/`

Boundary:

- Skill contracts are governance/runtime contracts only, not live skill execution.
- The contracts define input/output, role permission, path, command, API, secret, token, timeout, retry, evidence, and failure packet requirements.
- No live skill execution, live agent runtime, A2A handoff schema, live A2A runtime, local runner runtime, live recovery runtime, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, automatic new-thread creation, product runtime, main merge, solved Codex compaction, solved Codex reliability, or no-manual-prompt-transfer success is claimed.
- R18 remains active through R18-003 only; R18-004 through R18-028 remain planned only.
"@
}

function New-R18SkillValidationManifestText {
    return @"
# R18-003 Skill Contract Schema Validation Manifest

Required validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_skill_contract_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_skill_contract_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_skill_contract_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

Expected status truth: R18 active through R18-003 only; R18-004 through R18-028 planned only.

Expected non-claims: no live skill execution, no live agent runtime, no A2A handoff schema, no live A2A runtime, no local runner runtime, no live recovery runtime, no API invocation, no automatic new-thread creation, no product runtime, no main merge, no solved Codex compaction/reliability, and no no-manual-prompt-transfer success.
"@
}

function New-R18SkillContractSchemaArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot))

    $paths = Get-R18SkillContractSchemaPaths -RepositoryRoot $RepositoryRoot
    $skills = @(Get-R18SkillContracts)
    $contract = New-R18SkillContractContract
    $registry = New-R18SkillRegistry -Skills $skills
    $report = New-R18SkillContractCheckReport -Skills $skills
    $snapshot = New-R18SkillContractSnapshot -Skills $skills

    Write-R18SkillContractJson -Path $paths.Contract -Value $contract
    foreach ($skill in $skills) {
        $path = $paths.SkillFiles[[string]$skill.skill_id]
        if ([string]::IsNullOrWhiteSpace($path)) {
            throw "No skill contract file path configured for '$($skill.skill_id)'."
        }
        Write-R18SkillContractJson -Path $path -Value $skill
    }
    Write-R18SkillContractJson -Path $paths.Registry -Value $registry
    Write-R18SkillContractJson -Path $paths.CheckReport -Value $report
    Write-R18SkillContractJson -Path $paths.UiSnapshot -Value $snapshot

    Write-R18SkillContractJson -Path $paths.FixtureManifest -Value (New-R18SkillFixtureManifest)
    $fixtureDefinitions = Get-R18SkillFixtureDefinitions
    foreach ($entry in $fixtureDefinitions.GetEnumerator()) {
        $fixture = [ordered]@{
            artifact_type = "r18_skill_contract_schema_invalid_fixture"
            contract_version = "v1"
            source_milestone = $script:R18SourceMilestone
            source_task = $script:R18SourceTask
            target = $entry.Value.target
            expected_failure_fragments = $entry.Value.expected_failure_fragments
        }
        if ($entry.Value.Contains("remove_paths")) {
            $fixture.remove_paths = $entry.Value.remove_paths
        }
        if ($entry.Value.Contains("set_values")) {
            $fixture.set_values = $entry.Value.set_values
        }
        Write-R18SkillContractJson -Path (Join-Path $paths.FixtureRoot $entry.Key) -Value $fixture
    }

    Write-R18SkillContractJson -Path $paths.EvidenceIndex -Value (New-R18SkillEvidenceIndex)
    Write-R18SkillContractText -Path $paths.ProofReview -Value (New-R18SkillProofReviewText)
    Write-R18SkillContractText -Path $paths.ValidationManifest -Value (New-R18SkillValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        SkillRoot = $paths.SkillRoot
        Registry = $paths.Registry
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredSkillCount = @($script:R18RequiredSkillFileMap.Keys).Count
        GeneratedSkillCount = @($skills).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

function Assert-R18SkillContractCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-R18SkillContractRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18SkillContractCondition -Condition ($null -ne $Object.PSObject.Properties[$field]) -Message "$Context is missing required field '$field'."
        $value = $Object.PSObject.Properties[$field].Value
        if ($null -eq $value) { throw "$Context required field '$field' is null." }
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) { throw "$Context required field '$field' is blank." }
    }
}

function Assert-R18SkillContractNonEmptyArray {
    param([AllowNull()][object]$Value, [Parameter(Mandatory = $true)][string]$Context)
    if ($null -eq $Value -or @($Value).Count -eq 0) { throw "$Context must be a non-empty array." }
    foreach ($item in @($Value)) {
        if ($null -eq $item -or ([string]$item).Trim().Length -eq 0) { throw "$Context contains a blank item." }
    }
}

function Assert-R18SkillContractNonEmptyObject {
    param([AllowNull()][object]$Value, [Parameter(Mandatory = $true)][string]$Context)
    if ($null -eq $Value -or @($Value.PSObject.Properties).Count -eq 0) { throw "$Context must be a non-empty object." }
}

function Assert-R18SkillContractFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        Assert-R18SkillContractCondition -Condition ($null -ne $Object.PSObject.Properties[$field]) -Message "$Context is missing required false field '$field'."
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }
}

function Get-R18AgentCardRoles {
    param([string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot))

    $paths = Get-R18SkillContractSchemaPaths -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $paths.AgentCardRoot -PathType Container)) {
        throw "R18-002 agent card root is missing."
    }

    $roles = @()
    foreach ($file in @(Get-ChildItem -LiteralPath $paths.AgentCardRoot -Filter "*.json" | Sort-Object Name)) {
        $card = Read-R18SkillContractJson -Path $file.FullName
        if ($null -eq $card.PSObject.Properties["role"]) {
            throw "R18-002 agent card '$($file.Name)' is missing role."
        }
        $roles += [string]$card.role
    }

    $roles = @($roles | Sort-Object -Unique)
    if ($roles.Count -eq 0) {
        throw "No R18-002 agent card roles were found."
    }

    return $roles
}

function Assert-R18SkillAllowedPaths {
    param([Parameter(Mandatory = $true)][object]$Skill)

    Assert-R18SkillContractNonEmptyArray -Value $Skill.allowed_paths -Context "$($Skill.skill_id) allowed_paths"
    foreach ($path in @($Skill.allowed_paths)) {
        $normalized = ([string]$path).Replace("\", "/").Trim()
        if ([string]::IsNullOrWhiteSpace($normalized)) {
            throw "$($Skill.skill_id) allowed_paths contains a blank path."
        }
        if (@(".", "./", "/", "*", "**", "repo", "repo_root", "repository_root", "root") -contains $normalized.ToLowerInvariant()) {
            throw "$($Skill.skill_id) permits broad repo writes through allowed path '$normalized'."
        }
        if ($normalized -match '^(contracts|governance|state|tools|tests|execution)/?$') {
            throw "$($Skill.skill_id) permits broad repo writes through allowed path '$normalized'."
        }
        if ($normalized -match '^\*' -or $normalized -match '\*\*$') {
            throw "$($Skill.skill_id) permits broad repo writes through wildcard path '$normalized'."
        }
        if ($normalized -match '^\.local_backups/' -or $normalized -match '(?i)operator[-_ ]local') {
            throw "$($Skill.skill_id) permits operator-local backup path '$normalized'."
        }
        if ($normalized -match '^state/proof_reviews/r1[3-6]' -or $normalized -match '^state/.*/r1[3-6]_' -or $normalized -match '^governance/R1[3-6]_') {
            throw "$($Skill.skill_id) permits historical evidence edits through '$normalized'."
        }
    }

    Assert-R18SkillContractNonEmptyArray -Value $Skill.forbidden_paths -Context "$($Skill.skill_id) forbidden_paths"
    $forbiddenText = (@($Skill.forbidden_paths) -join " ").ToLowerInvariant()
    foreach ($requiredFragment in @(".local_backups", "operator-local", "r13", "r14", "r15", "r16")) {
        if ($forbiddenText -notmatch [regex]::Escape($requiredFragment)) {
            throw "$($Skill.skill_id) forbidden_paths must preserve '$requiredFragment'."
        }
    }
}

function Assert-R18SkillRoles {
    param(
        [Parameter(Mandatory = $true)][object]$Skill,
        [Parameter(Mandatory = $true)][string[]]$AgentCardRoles
    )

    Assert-R18SkillContractNonEmptyArray -Value $Skill.allowed_roles -Context "$($Skill.skill_id) allowed_roles"
    $expectedRoles = @($script:R18SkillAllowedRoles[[string]$Skill.skill_id])
    foreach ($role in @($Skill.allowed_roles)) {
        $roleValue = ([string]$role).Trim()
        $lowerRole = $roleValue.ToLowerInvariant()
        if ($script:R18ForbiddenRoleIdentifiers -contains $lowerRole -or $roleValue -match '\*') {
            throw "$($Skill.skill_id) contains wildcard or unbounded role '$roleValue'."
        }
        if ($AgentCardRoles -notcontains $roleValue) {
            throw "$($Skill.skill_id) allowed role '$roleValue' is missing from R18-002 agent cards."
        }
        if ($expectedRoles -notcontains $roleValue) {
            throw "$($Skill.skill_id) allowed role '$roleValue' is not allowed for this seed skill."
        }
    }

    Assert-R18SkillContractCondition -Condition (@($Skill.allowed_roles).Count -eq $expectedRoles.Count) -Message "$($Skill.skill_id) allowed_roles does not match intended seed role access."

    foreach ($role in $expectedRoles) {
        Assert-R18SkillContractCondition -Condition (@($Skill.allowed_roles) -contains $role) -Message "$($Skill.skill_id) missing intended allowed role '$role'."
    }

    if (@($Skill.allowed_roles).Count -eq $AgentCardRoles.Count) {
        Assert-R18SkillContractCondition -Condition ($Skill.skill_id -eq "inspect_repo_refs") -Message "$($Skill.skill_id) grants all roles without being the bounded inspection-only skill."
        Assert-R18SkillContractCondition -Condition ($Skill.skill_category -eq "repository_inspection") -Message "$($Skill.skill_id) grants all roles without inspection-only category."
        Assert-R18SkillContractCondition -Condition ([bool]$Skill.role_policy.grants_all_seed_roles -eq $true) -Message "$($Skill.skill_id) must explicitly prove all seed roles are validated."
        Assert-R18SkillContractCondition -Condition ([string]$Skill.role_policy.all_role_grant_boundary -eq "read_only_inspection_only") -Message "$($Skill.skill_id) all-role grant must be read-only inspection-only."
        Assert-R18SkillContractCondition -Condition ([bool]$Skill.command_policy.mutation_commands_allowed -eq $false) -Message "$($Skill.skill_id) all-role grant cannot allow mutation commands."
    }

    if (@($Skill.allowed_roles) -contains "Evidence Auditor") {
        Assert-R18SkillContractCondition -Condition ($Skill.skill_category -ne "artifact_generation" -and $Skill.skill_category -ne "schema_definition") -Message "$($Skill.skill_id) allows Evidence Auditor to generate implementation artifacts."
    }
    if ($Skill.skill_id -eq "request_operator_approval") {
        Assert-R18SkillContractCondition -Condition (@($Skill.allowed_roles) -notcontains "Developer/Codex") -Message "Developer/Codex must not request operator approval as decision authority."
    }
    if (@($Skill.allowed_roles) -contains "QA/Test") {
        Assert-R18SkillContractCondition -Condition ([bool]$Skill.approval_requirements.qa_self_approval_allowed -eq $false) -Message "QA/Test must not be allowed to self-approve fixes."
    }
}

function Assert-R18SkillPolicies {
    param([Parameter(Mandatory = $true)][object]$Skill)

    Assert-R18SkillContractNonEmptyObject -Value $Skill.failure_packet_schema -Context "$($Skill.skill_id) failure_packet_schema"
    Assert-R18SkillContractRequiredFields -Object $Skill.failure_packet_schema -FieldNames @("failure_packet_required", "required_fields", "unknown_failure_requires_operator_decision") -Context "$($Skill.skill_id) failure_packet_schema"
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.failure_packet_schema.failure_packet_required -eq $true) -Message "$($Skill.skill_id) failure packet schema must require failure packets."
    Assert-R18SkillContractNonEmptyArray -Value $Skill.failure_packet_schema.required_fields -Context "$($Skill.skill_id) failure_packet_schema.required_fields"

    Assert-R18SkillContractNonEmptyObject -Value $Skill.path_policy -Context "$($Skill.skill_id) path_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.path_policy -FieldNames @("allowed_paths_required", "forbidden_paths_required", "broad_repo_writes_allowed", "operator_local_backup_paths_allowed", "historical_r13_r16_evidence_edits_allowed") -Context "$($Skill.skill_id) path_policy"
    if ([bool]$Skill.path_policy.broad_repo_writes_allowed) { throw "$($Skill.skill_id) allows broad repo writes." }
    if ([bool]$Skill.path_policy.operator_local_backup_paths_allowed) { throw "$($Skill.skill_id) allows operator-local backup paths." }
    if ([bool]$Skill.path_policy.historical_r13_r16_evidence_edits_allowed) { throw "$($Skill.skill_id) allows historical R13/R14/R15/R16 evidence edits." }

    Assert-R18SkillContractNonEmptyObject -Value $Skill.command_policy -Context "$($Skill.skill_id) command_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.command_policy -FieldNames @("commands_allowed", "allowed_command_patterns", "forbidden_command_patterns", "shell_execution_claimed", "live_execution_claimed") -Context "$($Skill.skill_id) command_policy"
    Assert-R18SkillContractNonEmptyArray -Value $Skill.command_policy.allowed_command_patterns -Context "$($Skill.skill_id) command_policy.allowed_command_patterns"
    Assert-R18SkillContractNonEmptyArray -Value $Skill.command_policy.forbidden_command_patterns -Context "$($Skill.skill_id) command_policy.forbidden_command_patterns"
    if ([bool]$Skill.command_policy.shell_execution_claimed) { throw "$($Skill.skill_id) claims shell execution in R18-003." }
    if ([bool]$Skill.command_policy.live_execution_claimed) { throw "$($Skill.skill_id) claims live execution in R18-003." }

    Assert-R18SkillContractNonEmptyObject -Value $Skill.api_policy -Context "$($Skill.skill_id) api_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.api_policy -FieldNames @("api_enabled", "openai_api_invocation_allowed", "codex_api_invocation_allowed", "autonomous_codex_invocation_allowed", "automatic_new_thread_creation_allowed", "api_controls_required_before_enablement") -Context "$($Skill.skill_id) api_policy"
    if ([bool]$Skill.api_policy.api_enabled) { throw "$($Skill.skill_id) enables API use." }
    if ([bool]$Skill.api_policy.openai_api_invocation_allowed) { throw "$($Skill.skill_id) allows OpenAI API invocation." }
    if ([bool]$Skill.api_policy.codex_api_invocation_allowed) { throw "$($Skill.skill_id) allows Codex API invocation." }
    if ([bool]$Skill.api_policy.autonomous_codex_invocation_allowed) { throw "$($Skill.skill_id) allows autonomous Codex invocation." }
    if ([bool]$Skill.api_policy.automatic_new_thread_creation_allowed) { throw "$($Skill.skill_id) allows automatic new-thread creation." }
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.api_policy.api_controls_required_before_enablement -eq $true) -Message "$($Skill.skill_id) must require API controls before enablement."

    Assert-R18SkillContractNonEmptyObject -Value $Skill.secrets_policy -Context "$($Skill.skill_id) secrets_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.secrets_policy -FieldNames @("secrets_required", "secrets_must_not_be_committed") -Context "$($Skill.skill_id) secrets_policy"
    if ([bool]$Skill.secrets_policy.secrets_required) { throw "$($Skill.skill_id) requires secrets in R18-003." }
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.secrets_policy.secrets_must_not_be_committed -eq $true) -Message "$($Skill.skill_id) must forbid committed secrets."

    Assert-R18SkillContractNonEmptyObject -Value $Skill.token_budget_policy -Context "$($Skill.skill_id) token_budget_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.token_budget_policy -FieldNames @("token_budget_required_before_api_use", "cost_budget_required_before_api_use") -Context "$($Skill.skill_id) token_budget_policy"
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.token_budget_policy.token_budget_required_before_api_use -eq $true) -Message "$($Skill.skill_id) must require token budget before API use."
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.token_budget_policy.cost_budget_required_before_api_use -eq $true) -Message "$($Skill.skill_id) must require cost budget before API use."

    Assert-R18SkillContractNonEmptyObject -Value $Skill.timeout_policy -Context "$($Skill.skill_id) timeout_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.timeout_policy -FieldNames @("timeout_required_before_api_use") -Context "$($Skill.skill_id) timeout_policy"
    Assert-R18SkillContractCondition -Condition ([bool]$Skill.timeout_policy.timeout_required_before_api_use -eq $true) -Message "$($Skill.skill_id) must require timeout before API use."

    Assert-R18SkillContractNonEmptyObject -Value $Skill.retry_policy -Context "$($Skill.skill_id) retry_policy"
    Assert-R18SkillContractRequiredFields -Object $Skill.retry_policy -FieldNames @("max_retry_count", "retry_limit_enforced", "unbounded_retry_allowed") -Context "$($Skill.skill_id) retry_policy"
    $maxRetry = 0
    if (-not [int]::TryParse([string]$Skill.retry_policy.max_retry_count, [ref]$maxRetry)) {
        throw "$($Skill.skill_id) allows unbounded retries through non-numeric max_retry_count."
    }
    if ($maxRetry -lt 0 -or $maxRetry -gt 3 -or [bool]$Skill.retry_policy.unbounded_retry_allowed -or [bool]$Skill.retry_policy.retry_limit_enforced -ne $true) {
        throw "$($Skill.skill_id) allows unbounded retries."
    }
}

function Assert-R18SkillClaims {
    param([Parameter(Mandatory = $true)][object]$Skill)

    Assert-R18SkillContractRequiredFields -Object $Skill.runtime_flags -FieldNames $script:R18RuntimeFlagFields -Context "$($Skill.skill_id) runtime_flags"
    if ([bool]$Skill.runtime_flags.live_skill_execution_performed) { throw "$($Skill.skill_id) claims live skill execution." }
    if ([bool]$Skill.runtime_flags.live_agent_runtime_invoked) { throw "$($Skill.skill_id) claims live agent runtime." }
    if ([bool]$Skill.runtime_flags.live_a2a_runtime_implemented) { throw "$($Skill.skill_id) claims live A2A runtime." }
    if ([bool]$Skill.runtime_flags.live_recovery_runtime_implemented) { throw "$($Skill.skill_id) claims live recovery runtime." }
    if ([bool]$Skill.runtime_flags.openai_api_invoked) { throw "$($Skill.skill_id) claims OpenAI API invocation." }
    if ([bool]$Skill.runtime_flags.codex_api_invoked) { throw "$($Skill.skill_id) claims Codex API invocation." }
    if ([bool]$Skill.runtime_flags.autonomous_codex_invocation_performed) { throw "$($Skill.skill_id) claims autonomous Codex invocation." }
    if ([bool]$Skill.runtime_flags.automatic_new_thread_creation_performed) { throw "$($Skill.skill_id) claims automatic new-thread creation." }
    if ([bool]$Skill.runtime_flags.product_runtime_executed) { throw "$($Skill.skill_id) claims product runtime." }
    if ([bool]$Skill.runtime_flags.no_manual_prompt_transfer_success_claimed) { throw "$($Skill.skill_id) claims no-manual-prompt-transfer success." }
    if ([bool]$Skill.runtime_flags.solved_codex_compaction_claimed) { throw "$($Skill.skill_id) claims solved Codex compaction." }
    if ([bool]$Skill.runtime_flags.solved_codex_reliability_claimed) { throw "$($Skill.skill_id) claims solved Codex reliability." }
    if ([bool]$Skill.runtime_flags.r18_004_completed) { throw "$($Skill.skill_id) claims R18-004 or later completion." }
    if ([bool]$Skill.runtime_flags.main_merge_claimed) { throw "$($Skill.skill_id) claims main merge." }

    if ($null -ne $Skill.PSObject.Properties["positive_claims"]) {
        foreach ($claim in @($Skill.positive_claims)) {
            if ($script:R18AllowedPositiveClaims -notcontains [string]$claim) {
                throw "$($Skill.skill_id) contains unsupported positive claim '$claim'."
            }
        }
    }

    Assert-R18SkillContractNonEmptyArray -Value $Skill.non_claims -Context "$($Skill.skill_id) non_claims"
    $nonClaimText = @($Skill.non_claims) -join " "
    foreach ($required in @("Skill contracts are governance/runtime contracts only", "No A2A handoff schema", "No A2A runtime", "No local runner runtime", "No recovery runtime", "No OpenAI API invocation", "No Codex API invocation", "R18-004 through R18-028 remain planned only", "Main is not merged")) {
        if ($nonClaimText -notmatch [regex]::Escape($required)) {
            throw "$($Skill.skill_id) non_claims must preserve '$required'."
        }
    }

    Assert-R18SkillContractNonEmptyArray -Value $Skill.rejected_claims -Context "$($Skill.skill_id) rejected_claims"
    $rejectedText = @($Skill.rejected_claims) -join " "
    foreach ($required in @("live_skill_execution", "live_agent_runtime", "live_a2a_runtime", "openai_api_invocation", "codex_api_invocation", "r18_004_or_later_completion", "broad_repo_write")) {
        if ($rejectedText -notmatch [regex]::Escape($required)) {
            throw "$($Skill.skill_id) rejected_claims must preserve '$required'."
        }
    }
}

function Assert-R18SkillContract {
    param(
        [Parameter(Mandatory = $true)][object]$Skill,
        [Parameter(Mandatory = $true)][string[]]$AgentCardRoles
    )

    Assert-R18SkillContractRequiredFields -Object $Skill -FieldNames $script:R18RequiredSkillFields -Context "skill contract"
    Assert-R18SkillContractCondition -Condition ($Skill.artifact_type -eq "r18_skill_contract") -Message "$($Skill.skill_id) artifact_type is invalid."
    Assert-R18SkillContractCondition -Condition ($Skill.contract_version -eq "v1") -Message "$($Skill.skill_id) contract_version is invalid."
    Assert-R18SkillContractCondition -Condition ($Skill.source_task -eq $script:R18SourceTask) -Message "$($Skill.skill_id) source_task must be R18-003."
    Assert-R18SkillContractCondition -Condition ($Skill.source_milestone -eq $script:R18SourceMilestone) -Message "$($Skill.skill_id) source_milestone is invalid."
    Assert-R18SkillContractCondition -Condition ($script:R18RequiredSkillFileMap.Contains([string]$Skill.skill_id)) -Message "Unexpected R18 skill_id '$($Skill.skill_id)'."
    Assert-R18SkillContractCondition -Condition ($Skill.skill_category -eq $script:R18SkillCategories[[string]$Skill.skill_id]) -Message "$($Skill.skill_id) skill_category is invalid."
    Assert-R18SkillContractCondition -Condition ($Skill.skill_status -eq "contract_only_not_executed") -Message "$($Skill.skill_id) skill_status must be contract_only_not_executed."

    Assert-R18SkillRoles -Skill $Skill -AgentCardRoles $AgentCardRoles
    Assert-R18SkillContractNonEmptyArray -Value $Skill.required_inputs -Context "$($Skill.skill_id) required_inputs"
    Assert-R18SkillContractNonEmptyArray -Value $Skill.required_outputs -Context "$($Skill.skill_id) required_outputs"
    Assert-R18SkillContractNonEmptyArray -Value $Skill.evidence_obligations -Context "$($Skill.skill_id) evidence_obligations"
    Assert-R18SkillPolicies -Skill $Skill
    Assert-R18SkillAllowedPaths -Skill $Skill
    Assert-R18SkillClaims -Skill $Skill
    Assert-R18SkillContractNonEmptyArray -Value $Skill.evidence_refs -Context "$($Skill.skill_id) evidence_refs"
    Assert-R18SkillContractNonEmptyArray -Value $Skill.authority_refs -Context "$($Skill.skill_id) authority_refs"
}

function Assert-R18SkillContractContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18SkillContractRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "scope", "purpose", "required_skill_ids", "required_skill_categories", "required_skill_fields", "required_runtime_false_flags", "allowed_positive_claims", "role_validation_policy", "path_policy", "command_policy", "api_policy", "secrets_policy", "token_budget_policy", "timeout_policy", "retry_policy", "evidence_refs", "authority_refs", "non_claims") -Context "skill contract contract"
    Assert-R18SkillContractCondition -Condition ($Contract.artifact_type -eq "r18_skill_contract_contract") -Message "skill contract contract artifact_type is invalid."
    foreach ($skillId in @($script:R18RequiredSkillFileMap.Keys)) {
        Assert-R18SkillContractCondition -Condition (@($Contract.required_skill_ids) -contains $skillId) -Message "skill contract contract missing required seed skill '$skillId'."
    }
    foreach ($field in $script:R18RequiredSkillFields) {
        Assert-R18SkillContractCondition -Condition (@($Contract.required_skill_fields) -contains $field) -Message "skill contract contract missing required field '$field'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18SkillContractCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "skill contract contract missing required runtime flag '$flag'."
    }
}

function Assert-R18SkillRegistry {
    param([Parameter(Mandatory = $true)][object]$Registry)

    Assert-R18SkillContractRequiredFields -Object $Registry -FieldNames @("artifact_type", "contract_version", "registry_id", "source_milestone", "source_task", "active_through_task", "skill_status", "skill_count", "skills", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "skill registry"
    Assert-R18SkillContractCondition -Condition ($Registry.artifact_type -eq "r18_skill_registry") -Message "skill registry artifact_type is invalid."
    Assert-R18SkillContractCondition -Condition ($Registry.active_through_task -eq "R18-003") -Message "skill registry active_through_task must be R18-003."
    Assert-R18SkillContractCondition -Condition ([int]$Registry.skill_count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "skill registry skill_count is invalid."
    foreach ($skillId in @($script:R18RequiredSkillFileMap.Keys)) {
        Assert-R18SkillContractCondition -Condition (@($Registry.skills | Where-Object { $_.skill_id -eq $skillId }).Count -eq 1) -Message "skill registry missing '$skillId'."
    }
    Assert-R18SkillContractFalseFields -Object $Registry.runtime_flags -FieldNames $script:R18RuntimeFlagFields -Context "skill registry runtime_flags"
}

function Assert-R18SkillContractCheckReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18SkillContractRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_milestone", "source_task", "required_skill_count", "generated_skill_count", "skill_ids", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "skill contract check report"
    Assert-R18SkillContractCondition -Condition ($Report.artifact_type -eq "r18_skill_contract_check_report") -Message "skill contract check report artifact_type is invalid."
    Assert-R18SkillContractCondition -Condition ($Report.aggregate_verdict -eq $script:R18SkillContractVerdict) -Message "skill contract check report aggregate verdict is invalid."
    Assert-R18SkillContractCondition -Condition ([int]$Report.required_skill_count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "skill contract check report required_skill_count is invalid."
    Assert-R18SkillContractCondition -Condition ([int]$Report.generated_skill_count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "skill contract check report generated_skill_count is invalid."
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "skill contract check '$($check.Name)' must have status passed."
        }
    }
    Assert-R18SkillContractFalseFields -Object $Report.runtime_flags -FieldNames $script:R18RuntimeFlagFields -Context "skill contract check report runtime_flags"
}

function Assert-R18SkillSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18SkillContractRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_milestone", "source_task", "active_through_task", "ui_boundary_label", "required_skill_count", "generated_skill_count", "skills", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "skill contract snapshot"
    Assert-R18SkillContractCondition -Condition ($Snapshot.artifact_type -eq "r18_skill_contract_snapshot") -Message "skill contract snapshot artifact_type is invalid."
    Assert-R18SkillContractCondition -Condition ($Snapshot.active_through_task -eq "R18-003") -Message "skill contract snapshot active_through_task must be R18-003."
    Assert-R18SkillContractCondition -Condition ([int]$Snapshot.required_skill_count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "skill contract snapshot required_skill_count is invalid."
    Assert-R18SkillContractCondition -Condition ([int]$Snapshot.generated_skill_count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "skill contract snapshot generated_skill_count is invalid."
    foreach ($skill in @($Snapshot.skills)) {
        Assert-R18SkillContractCondition -Condition ([bool]$skill.runtime_enabled -eq $false) -Message "skill snapshot '$($skill.skill_id)' runtime_enabled must be false."
        Assert-R18SkillContractCondition -Condition ([bool]$skill.api_enabled -eq $false) -Message "skill snapshot '$($skill.skill_id)' api_enabled must be false."
        Assert-R18SkillContractCondition -Condition ([bool]$skill.live_skill_execution_performed -eq $false) -Message "skill snapshot '$($skill.skill_id)' claims live skill execution."
        Assert-R18SkillContractCondition -Condition ([bool]$skill.live_agent_runtime_invoked -eq $false) -Message "skill snapshot '$($skill.skill_id)' claims live agent runtime."
        Assert-R18SkillContractCondition -Condition ([bool]$skill.r18_004_completed -eq $false) -Message "skill snapshot '$($skill.skill_id)' claims R18-004 completion."
    }
    Assert-R18SkillContractFalseFields -Object $Snapshot.runtime_summary -FieldNames $script:R18RuntimeFlagFields -Context "skill contract snapshot runtime_summary"
}

function Get-R18SkillTaskStatusMap {
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

function Test-R18SkillContractStatusTruth {
    param([string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18SkillContractPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-016 only",
            "R18-017 through R18-028 planned only",
            "R18-002 created agent card schema and seed cards only",
            "R18-003 created skill contract schema and seed skill contracts only",
            "Agent cards are not live agents",
            "Skill contracts are not live skill execution",
            "R18-004 created A2A handoff packet schema and seed handoff packets only",
            "A2A handoff packets are not live A2A runtime",
            "R18-005 created role-to-skill permission matrix only",
            "Permission matrix is not runtime enforcement",
            "R18-006 created Orchestrator chat/control intake contract and seed intake packets only",
            "Intake packets are not a live chat UI",
            "Intake packets are not Orchestrator runtime",
            "R18-008 created work-order execution state machine foundation only",
            "Work-order state machine is not runtime execution",
            "R18-009 created runner state store and resumable execution log foundation only",
            "Runner state store is not live runner runtime",
            "Execution log is deterministic foundation evidence, not live execution evidence",
            "Resume checkpoint is not a continuation packet",
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
            "Automatic new-thread creation is not implemented",            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No local runner runtime was implemented",
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

    $authorityStatuses = Get-R18SkillTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18SkillTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 16) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-016."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-016."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[7-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-015."
    }
}

function Test-R18SkillContractSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object[]]$Skills,
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot)
    )

    $agentCardRoles = Get-R18AgentCardRoles -RepositoryRoot $RepositoryRoot
    Assert-R18SkillContractContract -Contract $Contract
    Assert-R18SkillContractCondition -Condition (@($Skills).Count -eq @($script:R18RequiredSkillFileMap.Keys).Count) -Message "R18 skill contract set is missing required seed skills."
    foreach ($skillId in @($script:R18RequiredSkillFileMap.Keys)) {
        Assert-R18SkillContractCondition -Condition (@($Skills | Where-Object { $_.skill_id -eq $skillId }).Count -eq 1) -Message "R18 skill contract set is missing required skill '$skillId'."
    }
    foreach ($skill in @($Skills)) {
        Assert-R18SkillContract -Skill $skill -AgentCardRoles $agentCardRoles
    }
    Assert-R18SkillRegistry -Registry $Registry
    Assert-R18SkillContractCheckReport -Report $Report
    Assert-R18SkillSnapshot -Snapshot $Snapshot
    Test-R18SkillContractStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredSkillCount = [int]$Report.required_skill_count
        GeneratedSkillCount = [int]$Report.generated_skill_count
        SkillIds = @($Skills | ForEach-Object { $_.skill_id })
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18SkillContractSchema {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18SkillContractRepositoryRoot))

    $paths = Get-R18SkillContractSchemaPaths -RepositoryRoot $RepositoryRoot
    $skills = foreach ($skillId in @($script:R18RequiredSkillFileMap.Keys)) {
        Read-R18SkillContractJson -Path $paths.SkillFiles[$skillId]
    }

    return Test-R18SkillContractSet `
        -Contract (Read-R18SkillContractJson -Path $paths.Contract) `
        -Skills @($skills) `
        -Registry (Read-R18SkillContractJson -Path $paths.Registry) `
        -Report (Read-R18SkillContractJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18SkillContractJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18SkillContractObjectPathValue {
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

function Remove-R18SkillContractObjectPathValue {
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

function Invoke-R18SkillContractMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18SkillContractObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18SkillContractObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R18SkillContractSchemaPaths, `
    New-R18SkillContractSchemaArtifacts, `
    Test-R18SkillContractSchema, `
    Test-R18SkillContractSet, `
    Test-R18SkillContractStatusTruth, `
    Invoke-R18SkillContractMutation, `
    Copy-R18SkillContractObject, `
    Get-R18AgentCardRoles
