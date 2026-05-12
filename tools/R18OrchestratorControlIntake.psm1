Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-006"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18Repository = "RodneyMuniz/AIOffice_V2"
$script:R18Branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18IntakeVerdict = "generated_r18_orchestrator_control_intake_foundation_only"

$script:R18RequiredIntakeTypes = @(
    "create_work_order_request",
    "status_query_request",
    "recovery_resume_request",
    "retry_escalation_request",
    "evidence_query_request",
    "operator_approval_request",
    "operator_rejection_request",
    "stop_block_request"
)

$script:R18RequiredIntakeFileMap = [ordered]@{
    create_work_order_request = "create_work_order_request.intake.json"
    status_query_request = "status_query_request.intake.json"
    recovery_resume_request = "recovery_resume_request.intake.json"
    retry_escalation_request = "retry_escalation_request.intake.json"
    evidence_query_request = "evidence_query_request.intake.json"
    operator_approval_request = "operator_approval_request.intake.json"
    operator_rejection_request = "operator_rejection_request.intake.json"
    stop_block_request = "stop_block_request.intake.json"
}

$script:R18RequiredIntakeFields = @(
    "artifact_type",
    "contract_version",
    "intake_id",
    "intake_name",
    "intake_type",
    "source_task",
    "source_milestone",
    "intake_status",
    "operator_intent",
    "normalized_intent",
    "target_scope",
    "requested_action",
    "source_surface",
    "orchestrator_agent_ref",
    "authority_refs",
    "agent_card_refs",
    "skill_refs",
    "permission_matrix_ref",
    "a2a_handoff_refs",
    "required_input_refs",
    "expected_packet_outputs",
    "evidence_obligations",
    "validation_expectations",
    "operator_decision_policy",
    "failure_routing",
    "retry_failover_policy",
    "allowed_paths",
    "forbidden_paths",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18RequiredTargetScopeFields = @(
    "milestone_id",
    "task_id",
    "card_id",
    "work_order_id",
    "target_role",
    "target_skill",
    "allowed_paths",
    "forbidden_paths",
    "acceptance_criteria",
    "status_boundary",
    "planned_only_boundary"
)

$script:R18RequiredDecisionPolicyFields = @(
    "decision_packet_required",
    "approval_scope",
    "approval_already_granted",
    "operator_approval_required_for",
    "missing_decision_blocks_action",
    "decision_may_be_inferred"
)

$script:R18RuntimeFlagFields = @(
    "live_chat_ui_implemented",
    "orchestrator_runtime_implemented",
    "intake_routed_by_runtime",
    "board_runtime_mutation_performed",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "local_runner_runtime_implemented",
    "live_recovery_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_007_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_orchestrator_control_intake_contract_created",
    "r18_orchestrator_control_intake_seed_packets_created",
    "r18_orchestrator_control_intake_registry_created",
    "r18_orchestrator_control_intake_validator_created",
    "r18_orchestrator_control_intake_fixtures_created",
    "r18_orchestrator_control_intake_proof_review_created"
)

$script:R18RejectedClaims = @(
    "live_chat_ui",
    "orchestrator_runtime",
    "intake_routed_by_runtime",
    "board_runtime_mutation",
    "live_agent_runtime",
    "live_skill_execution",
    "a2a_message_sent",
    "live_a2a_runtime",
    "local_runner_runtime",
    "live_recovery_runtime",
    "openai_api_invocation",
    "codex_api_invocation",
    "autonomous_codex_invocation",
    "automatic_new_thread_creation",
    "product_runtime",
    "no_manual_prompt_transfer_success",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r18_007_or_later_completion",
    "main_merge",
    "raw_prompt_only_recovery",
    "unbounded_freeform_prompt",
    "permission_matrix_bypass",
    "a2a_handoff_validation_bypass",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "wildcard_role",
    "wildcard_skill",
    "wildcard_path",
    "unbounded_next_action"
)

$script:R18ForbiddenWildcards = @("*", "all", "any", "unbounded", "all roles", "all_roles", "all skills", "all_skills")

function Get-R18IntakeRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18IntakePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18IntakeJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18IntakeJson {
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

function Write-R18IntakeText {
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

function Copy-R18IntakeObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18IntakePaths {
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $packetRoot = "state/intake/r18_orchestrator_control_intake_packets"
    $fixtureRoot = "tests/fixtures/r18_orchestrator_control_intake"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_006_orchestrator_control_intake"

    return [pscustomobject]@{
        Contract = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/intake/r18_orchestrator_control_intake.contract.json"
        PacketRoot = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue $packetRoot
        Registry = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/intake/r18_orchestrator_control_intake_registry.json"
        CheckReport = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/intake/r18_orchestrator_control_intake_check_report.json"
        UiSnapshot = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_orchestrator_control_intake_snapshot.json"
        Module = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18OrchestratorControlIntake.psm1"
        Generator = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_orchestrator_control_intake.ps1"
        Validator = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_orchestrator_control_intake.ps1"
        Test = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_orchestrator_control_intake.ps1"
        FixtureRoot = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        AgentCardRoot = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_cards"
        SkillRegistry = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_registry.json"
        PermissionMatrix = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_role_skill_permission_matrix.json"
        HandoffRegistry = Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r18_handoff_registry.json"
    }
}

function Get-R18IntakePacketPath {
    param(
        [Parameter(Mandatory = $true)][string]$IntakeType,
        [string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot)
    )

    if (-not $script:R18RequiredIntakeFileMap.Contains($IntakeType)) {
        throw "Unknown R18 intake type '$IntakeType'."
    }

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    return Join-Path $paths.PacketRoot $script:R18RequiredIntakeFileMap[$IntakeType]
}

function Get-R18IntakeEvidenceRefs {
    return @(
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "state/intake/r18_orchestrator_control_intake_registry.json",
        "state/intake/r18_orchestrator_control_intake_check_report.json",
        "state/ui/r18_operator_surface/r18_orchestrator_control_intake_snapshot.json",
        "tools/R18OrchestratorControlIntake.psm1",
        "tools/new_r18_orchestrator_control_intake.ps1",
        "tools/validate_r18_orchestrator_control_intake.ps1",
        "tests/test_r18_orchestrator_control_intake.ps1",
        "tests/fixtures/r18_orchestrator_control_intake/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_006_orchestrator_control_intake/"
    )
}

function Get-R18IntakeAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "state/agents/r18_agent_card_check_report.json",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_contracts/",
        "state/skills/r18_skill_registry.json",
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_packets/",
        "state/a2a/r18_handoff_registry.json",
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "state/skills/r18_role_skill_permission_matrix_check_report.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/runtime/r17_automated_recovery_loop.contract.json",
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "contracts/runtime/r17_compact_safe_harness_pilot.contract.json"
    )
}

function Get-R18IntakeAllowedPaths {
    return @(
        "contracts/intake/r18_orchestrator_control_intake.contract.json",
        "state/intake/r18_orchestrator_control_intake_packets/",
        "state/intake/r18_orchestrator_control_intake_registry.json",
        "state/intake/r18_orchestrator_control_intake_check_report.json",
        "state/ui/r18_operator_surface/r18_orchestrator_control_intake_snapshot.json",
        "tools/R18OrchestratorControlIntake.psm1",
        "tools/new_r18_orchestrator_control_intake.ps1",
        "tools/validate_r18_orchestrator_control_intake.ps1",
        "tests/test_r18_orchestrator_control_intake.ps1",
        "tests/fixtures/r18_orchestrator_control_intake/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_006_orchestrator_control_intake/",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1",
        "tools/R18AgentCardSchema.psm1",
        "tools/R18SkillContractSchema.psm1",
        "tools/R18A2AHandoffPacketSchema.psm1",
        "tools/R18RoleSkillPermissionMatrix.psm1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1"
    )
}

function Get-R18IntakeForbiddenPaths {
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

function Get-R18IntakeRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18IntakeNonClaims {
    return @(
        "R18-006 created Orchestrator chat/control intake contract and seed intake packets only.",
        "Intake packets are contract and seed governance artifacts only.",
        "Intake packets are not a live chat UI.",
        "Intake packets are not Orchestrator runtime.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live agents were invoked.",
        "No live skills were executed.",
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
        "R18 is active through R18-006 only.",
        "R18-007 through R18-028 remain planned only.",
        "Main is not merged."
    )
}

function New-R18IntakePathPolicy {
    return [ordered]@{
        allowed_paths = Get-R18IntakeAllowedPaths
        forbidden_paths = Get-R18IntakeForbiddenPaths
        allowed_paths_must_be_exact_or_task_scoped = $true
        wildcard_paths_allowed = $false
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
    }
}

function New-R18IntakeApiPolicy {
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

function New-R18IntakeFailureRouting {
    param(
        [string]$Behavior = "fail_closed_and_block_intake",
        [string]$TargetRole = "Orchestrator",
        [string]$TargetAgent = "agent_orchestrator"
    )

    return [ordered]@{
        behavior = $Behavior
        failure_routing_target_role = $TargetRole
        failure_routing_target_agent_id = $TargetAgent
        failure_packet_required = $true
        block_on_denied_permission = $true
        stop_on_runtime_claim = $true
        retry_without_repair_allowed = $false
        bypass_allowed = $false
        failure_packet_requirements = @(
            "failure_reason",
            "blocking_evidence_refs",
            "requested_repair_scope",
            "non_claims_preserved"
        )
    }
}

function New-R18IntakeDecisionPolicy {
    param(
        [bool]$DecisionPacketRequired = $false,
        [string]$ApprovalScope = "not_requested",
        [string[]]$OperatorApprovalRequiredFor = @()
    )

    return [ordered]@{
        decision_packet_required = $DecisionPacketRequired
        approval_scope = $ApprovalScope
        approval_already_granted = $false
        operator_approval_required_for = $OperatorApprovalRequiredFor
        missing_decision_blocks_action = $DecisionPacketRequired
        decision_may_be_inferred = $false
        approval_bypass_allowed = $false
    }
}

function New-R18IntakeRetryPolicy {
    param(
        [int]$RetryCount = 0,
        [int]$MaxRetryCount = 1,
        [string]$FailurePacketRef = "not_applicable_for_seed_packet",
        [string]$EscalationReason = "not_applicable_for_seed_packet",
        [string]$OperatorDecisionCondition = "retry_limit_reached_or_unsafe_state"
    )

    return [ordered]@{
        retry_count = $RetryCount
        max_retry_count = $MaxRetryCount
        retry_count_required = $true
        retry_limit_enforced = $true
        unbounded_retry_allowed = $false
        failure_packet_ref = $FailurePacketRef
        escalation_reason = $EscalationReason
        operator_decision_condition = $OperatorDecisionCondition
        failover_allowed_without_packet = $false
    }
}

function New-R18IntakeRequestedAction {
    param(
        [Parameter(Mandatory = $true)][string]$ActionId,
        [Parameter(Mandatory = $true)][string]$Description,
        [bool]$ReadOnly = $false,
        [bool]$MutationAllowed = $false
    )

    return [ordered]@{
        action_id = $ActionId
        description = $Description
        read_only = $ReadOnly
        mutation_allowed = $MutationAllowed
        board_state_mutation_allowed = $false
        live_invocation_allowed = $false
        runtime_execution_allowed = $false
        bounded_packet_output_only = $true
    }
}

function New-R18IntakeTargetScope {
    param(
        [Parameter(Mandatory = $true)][string]$CardId,
        [Parameter(Mandatory = $true)][string]$WorkOrderId,
        [Parameter(Mandatory = $true)][string]$TargetRole,
        [Parameter(Mandatory = $true)][string]$TargetSkill,
        [string[]]$AcceptanceCriteria = @(),
        [string[]]$IntendedRolePath = @("Orchestrator")
    )

    return [ordered]@{
        milestone_id = "R18"
        task_id = $script:R18SourceTask
        card_id = $CardId
        work_order_id = $WorkOrderId
        target_role = $TargetRole
        target_skill = $TargetSkill
        intended_role_path = $IntendedRolePath
        allowed_paths = Get-R18IntakeAllowedPaths
        forbidden_paths = Get-R18IntakeForbiddenPaths
        acceptance_criteria = $AcceptanceCriteria
        status_boundary = "R18 active through R18-006 only"
        planned_only_boundary = "R18-007 through R18-028 planned only"
    }
}

function New-R18IntakePermissionRef {
    param(
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$SkillId,
        [string]$PermissionStatus = "allowed"
    )

    $permissionId = (($Role.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim("_")) + "__" + $SkillId
    return [ordered]@{
        matrix_ref = "state/skills/r18_role_skill_permission_matrix.json"
        contract_ref = "contracts/skills/r18_role_skill_permission_matrix.contract.json"
        permission_id = $permissionId
        role = $Role
        skill_id = $SkillId
        permission_status = $PermissionStatus
        approval_gate_ref = if ($PermissionStatus -eq "approval_required") { "operator_approval_required" } else { "not_required_contract_only" }
        denied_permissions_route_to_failure = $true
        bypass_allowed = $false
    }
}

function New-R18IntakeAgentRefs {
    param([Parameter(Mandatory = $true)][string[]]$Roles)

    $map = @{
        "Orchestrator" = "agent_orchestrator"
        "Project Manager" = "agent_project_manager"
        "Solution Architect" = "agent_solution_architect"
        "Developer/Codex" = "agent_developer_codex"
        "QA/Test" = "agent_qa_test"
        "Evidence Auditor" = "agent_evidence_auditor"
        "Release Manager" = "agent_release_manager"
    }

    $refs = @()
    foreach ($role in @($Roles | Select-Object -Unique)) {
        if (-not $map.ContainsKey($role)) {
            throw "Unknown agent role '$role'."
        }
        $agentId = $map[$role]
        $refs += [ordered]@{
            role = $role
            agent_id = $agentId
            card_ref = "state/agents/r18_agent_cards/$agentId.card.json"
        }
    }
    return $refs
}

function New-R18IntakeSkillRefs {
    param([Parameter(Mandatory = $true)][string[]]$SkillIds)

    $refs = @()
    foreach ($skillId in @($SkillIds | Select-Object -Unique)) {
        $refs += [ordered]@{
            skill_id = $skillId
            registry_ref = "state/skills/r18_skill_registry.json"
            contract_ref = "state/skills/r18_skill_contracts/$skillId.skill.json"
            contract_status = "contract_only_not_executed"
        }
    }
    return $refs
}

function New-R18IntakeA2ARefs {
    param(
        [bool]$RoutingImplied = $false,
        [string[]]$PacketRefs = @()
    )

    $refs = @("state/a2a/r18_handoff_registry.json")
    foreach ($packetRef in $PacketRefs) {
        $refs += $packetRef
    }

    return [ordered]@{
        routing_implied = $RoutingImplied
        validation_required_when_routing_implied = $true
        refs = @($refs | Select-Object -Unique)
        live_dispatch_allowed = $false
        live_a2a_runtime_allowed = $false
        a2a_message_send_allowed = $false
        bypass_allowed = $false
    }
}

function New-R18IntakeValidationExpectations {
    param([string[]]$ExtraChecks = @())

    return [ordered]@{
        checks = @(
            "intake_shape",
            "authority_refs",
            "agent_card_refs",
            "skill_refs",
            "permission_matrix_ref",
            "target_scope",
            "runtime_false_flags",
            "non_claims",
            "status_boundary"
        ) + $ExtraChecks
        validation_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1"
        )
        expected_outputs = @(
            "validator_passed",
            "focused_tests_passed",
            "runtime_false_flags_preserved"
        )
        fail_closed_on_missing_fields = $true
        unknown_intake_type_rejected = $true
        runtime_claims_rejected = $true
    }
}

function New-R18IntakeBasePacket {
    param(
        [Parameter(Mandatory = $true)][string]$IntakeType,
        [Parameter(Mandatory = $true)][string]$IntakeName,
        [Parameter(Mandatory = $true)][string]$OperatorIntent,
        [Parameter(Mandatory = $true)][string]$NormalizedIntent,
        [Parameter(Mandatory = $true)][object]$TargetScope,
        [Parameter(Mandatory = $true)][object]$RequestedAction,
        [Parameter(Mandatory = $true)][string[]]$AgentRoles,
        [Parameter(Mandatory = $true)][string[]]$SkillIds,
        [Parameter(Mandatory = $true)][object]$PermissionRef,
        [Parameter(Mandatory = $true)][object]$A2ARefs,
        [Parameter(Mandatory = $true)][string[]]$RequiredInputRefs,
        [Parameter(Mandatory = $true)][string[]]$ExpectedPacketOutputs,
        [Parameter(Mandatory = $true)][string[]]$EvidenceObligations,
        [Parameter(Mandatory = $true)][object]$OperatorDecisionPolicy,
        [Parameter(Mandatory = $true)][object]$FailureRouting,
        [Parameter(Mandatory = $true)][object]$RetryPolicy,
        [string[]]$NextAllowedActions = @("validate_intake_packet", "write_packet_artifact", "stop_on_validation_failure"),
        [object]$ValidationExpectations = $null
    )

    if ($null -eq $ValidationExpectations) {
        $ValidationExpectations = New-R18IntakeValidationExpectations
    }

    $intakeId = "r18_006_$IntakeType"
    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_packet"
        contract_version = "v1"
        intake_id = $intakeId
        intake_name = $IntakeName
        intake_type = $IntakeType
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        intake_status = "packet_only_not_routed"
        operator_intent = $OperatorIntent
        normalized_intent = $NormalizedIntent
        operator_intent_policy = [ordered]@{
            unbounded_freeform_prompt_allowed = $false
            raw_prompt_only_recovery_allowed = $false
            bounded_fields_required = $true
            clarification_required_when_ambiguous = $true
        }
        target_scope = $TargetScope
        requested_action = $RequestedAction
        source_surface = [ordered]@{
            surface_id = "future_orchestrator_control_surface"
            surface_status = "contract_only_no_live_chat_ui"
            live_chat_ui_implemented = $false
            runtime_controller_implemented = $false
        }
        orchestrator_agent_ref = [ordered]@{
            role = "Orchestrator"
            agent_id = "agent_orchestrator"
            card_ref = "state/agents/r18_agent_cards/agent_orchestrator.card.json"
            live_agent_invocation_allowed = $false
        }
        authority_refs = Get-R18IntakeAuthorityRefs
        agent_card_refs = New-R18IntakeAgentRefs -Roles $AgentRoles
        skill_refs = New-R18IntakeSkillRefs -SkillIds $SkillIds
        permission_matrix_ref = $PermissionRef
        a2a_handoff_refs = $A2ARefs
        required_input_refs = $RequiredInputRefs
        expected_packet_outputs = $ExpectedPacketOutputs
        evidence_obligations = $EvidenceObligations
        validation_expectations = $ValidationExpectations
        operator_decision_policy = $OperatorDecisionPolicy
        failure_routing = $FailureRouting
        retry_failover_policy = $RetryPolicy
        next_allowed_actions = $NextAllowedActions
        allowed_paths = Get-R18IntakeAllowedPaths
        forbidden_paths = Get-R18IntakeForbiddenPaths
        runtime_flags = Get-R18IntakeRuntimeFlags
        non_claims = Get-R18IntakeNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18IntakePackets {
    $packets = @()

    $packets += New-R18IntakeBasePacket `
        -IntakeType "create_work_order_request" `
        -IntakeName "Create Work Order Request" `
        -OperatorIntent "Convert an operator objective into a bounded future work-order request packet." `
        -NormalizedIntent "create_bounded_work_order_request_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_project_manager-card-v1" -WorkOrderId "future_r18_work_order_request_packet" -TargetRole "Project Manager" -TargetSkill "define_work_order" -IntendedRolePath @("Orchestrator", "Project Manager") -AcceptanceCriteria @("milestone_task_scope_declared", "allowed_paths_declared", "forbidden_paths_declared", "role_skill_permission_checked", "status_boundary_preserved")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "create_work_order_packet" -Description "Create a bounded work-order request packet for later R18 tasks." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator", "Project Manager") `
        -SkillIds @("define_work_order") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Project Manager" -SkillId "define_work_order") `
        -A2ARefs (New-R18IntakeA2ARefs -RoutingImplied:$true -PacketRefs @("state/a2a/r18_handoff_packets/orchestrator_to_project_manager_define_work_order.handoff.json")) `
        -RequiredInputRefs @("operator_objective_ref", "target_milestone_ref", "task_id_ref", "allowed_paths_ref", "forbidden_paths_ref", "acceptance_criteria_ref") `
        -ExpectedPacketOutputs @("bounded_work_order_request_packet", "target_scope_packet", "validation_expectation_packet") `
        -EvidenceObligations @("operator_intent_recorded", "permission_matrix_ref_recorded", "agent_card_refs_recorded", "skill_contract_refs_recorded", "a2a_handoff_validation_ref_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$false -ApprovalScope "not_requested") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy) `
        -NextAllowedActions @("validate_intake_contract", "create_packet_only_work_order_request", "request_operator_clarification_if_scope_ambiguous")

    $packets += New-R18IntakeBasePacket `
        -IntakeType "status_query_request" `
        -IntakeName "Status Query Request" `
        -OperatorIntent "Ask for current milestone, task, status, and evidence posture without mutating status docs or board state." `
        -NormalizedIntent "read_only_status_and_evidence_posture_query_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_status_query_packet" -TargetRole "Orchestrator" -TargetSkill "inspect_repo_refs" -AcceptanceCriteria @("read_only_query", "status_docs_not_mutated", "board_state_not_mutated", "non_claims_reported")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "status_query_packet" -Description "Read current R18 status and evidence refs only." -ReadOnly:$true -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("inspect_repo_refs") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "inspect_repo_refs") `
        -A2ARefs (New-R18IntakeA2ARefs) `
        -RequiredInputRefs @("status_doc_refs", "r18_authority_ref", "evidence_registry_refs") `
        -ExpectedPacketOutputs @("status_posture_packet", "evidence_ref_summary_packet", "non_claim_posture_packet") `
        -EvidenceObligations @("status_doc_refs_recorded", "read_only_boundary_recorded", "board_mutation_false_flag_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$false -ApprovalScope "not_requested") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy) `
        -NextAllowedActions @("validate_read_only_scope", "summarize_status_refs", "stop_before_status_doc_mutation")

    $packets += New-R18IntakeBasePacket `
        -IntakeType "recovery_resume_request" `
        -IntakeName "Recovery Resume Request" `
        -OperatorIntent "Request future recovery or continuation after compact failure, validation failure, branch movement, or interrupted session." `
        -NormalizedIntent "future_recovery_resume_request_packet_only_requires_failure_ref_or_operator_note" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_recovery_resume_packet" -TargetRole "Orchestrator" -TargetSkill "generate_continuation_packet" -AcceptanceCriteria @("failure_event_ref_or_operator_note_required", "raw_prompt_only_recovery_rejected", "automatic_new_thread_creation_not_claimed")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "recovery_resume_packet" -Description "Prepare a future continuation packet request without invoking recovery runtime." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("generate_continuation_packet") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "generate_continuation_packet") `
        -A2ARefs (New-R18IntakeA2ARefs) `
        -RequiredInputRefs @("failure_event_ref_or_operator_failure_note", "last_known_head_ref", "last_known_tree_ref", "validation_failure_ref_when_available") `
        -ExpectedPacketOutputs @("future_continuation_request_packet", "recovery_precondition_packet", "operator_decision_needed_packet_when_refs_missing") `
        -EvidenceObligations @("failure_ref_or_operator_note_requirement_recorded", "raw_prompt_only_recovery_rejected", "automatic_new_thread_creation_false_flag_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$true -ApprovalScope "operator_failure_note_or_resume_scope") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy -MaxRetryCount 1) `
        -NextAllowedActions @("validate_failure_ref_or_operator_note", "create_future_continuation_request_packet", "block_raw_prompt_only_recovery") `
        -ValidationExpectations (New-R18IntakeValidationExpectations -ExtraChecks @("raw_prompt_only_recovery_rejected", "automatic_new_thread_creation_false"))
    $packets[-1]["recovery_resume_constraints"] = [ordered]@{
        failure_event_refs_or_operator_failure_note_required = $true
        failure_event_refs = @("future_failure_event_ref_required_when_available")
        operator_failure_note_required_when_no_event_ref = $true
        raw_prompt_only_recovery_allowed = $false
        automatic_new_thread_creation_claim_allowed = $false
    }

    $packets += New-R18IntakeBasePacket `
        -IntakeType "retry_escalation_request" `
        -IntakeName "Retry Escalation Request" `
        -OperatorIntent "Request future retry or escalation routing after bounded retry failure." `
        -NormalizedIntent "future_retry_escalation_request_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_retry_escalation_packet" -TargetRole "Orchestrator" -TargetSkill "classify_failure" -AcceptanceCriteria @("retry_count_required", "failure_packet_ref_required", "escalation_reason_required", "operator_decision_condition_required")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "retry_escalation_packet" -Description "Create a bounded retry or escalation request packet without executing retry runtime." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("classify_failure") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "classify_failure") `
        -A2ARefs (New-R18IntakeA2ARefs) `
        -RequiredInputRefs @("retry_count_ref", "failure_packet_ref", "escalation_reason_ref", "operator_decision_condition_ref") `
        -ExpectedPacketOutputs @("retry_escalation_request_packet", "failure_routing_packet", "operator_decision_condition_packet") `
        -EvidenceObligations @("retry_count_recorded", "failure_packet_ref_recorded", "escalation_reason_recorded", "operator_decision_condition_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$true -ApprovalScope "retry_escalation_after_bounded_failure") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy -RetryCount 3 -MaxRetryCount 3 -FailurePacketRef "future_failure_packet_ref_required" -EscalationReason "retry_limit_reached_or_validator_failed" -OperatorDecisionCondition "retry_count_greater_than_or_equal_to_max_retry_count") `
        -NextAllowedActions @("validate_retry_count", "validate_failure_packet_ref", "create_escalation_packet_or_block")

    $packets += New-R18IntakeBasePacket `
        -IntakeType "evidence_query_request" `
        -IntakeName "Evidence Query Request" `
        -OperatorIntent "Request evidence refs, proof-review refs, validators, and non-claim posture." `
        -NormalizedIntent "read_only_evidence_query_future_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_evidence_auditor-card-v1" -WorkOrderId "future_evidence_query_packet" -TargetRole "Evidence Auditor" -TargetSkill "generate_evidence_package" -IntendedRolePath @("Orchestrator", "Evidence Auditor") -AcceptanceCriteria @("read_only_query", "proof_review_refs_reported", "validators_reported", "no_live_evidence_auditor_invocation")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "evidence_query_packet" -Description "Create a read-only evidence query packet for a future Evidence Auditor packet path." -ReadOnly:$true -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator", "Evidence Auditor") `
        -SkillIds @("generate_evidence_package") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Evidence Auditor" -SkillId "generate_evidence_package") `
        -A2ARefs (New-R18IntakeA2ARefs -RoutingImplied:$true -PacketRefs @("state/a2a/r18_handoff_packets/qa_test_to_evidence_auditor_validation_passed.handoff.json")) `
        -RequiredInputRefs @("evidence_ref_query_scope", "proof_review_ref_scope", "validator_ref_scope", "non_claim_scope") `
        -ExpectedPacketOutputs @("evidence_ref_summary_packet", "proof_review_ref_summary_packet", "validator_ref_summary_packet", "non_claim_posture_packet") `
        -EvidenceObligations @("read_only_boundary_recorded", "future_packet_route_only_recorded", "live_evidence_auditor_invocation_false_flag_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$false -ApprovalScope "not_requested") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy) `
        -NextAllowedActions @("validate_read_only_scope", "create_future_evidence_query_packet", "stop_before_live_invocation")

    $packets += New-R18IntakeBasePacket `
        -IntakeType "operator_approval_request" `
        -IntakeName "Operator Approval Request" `
        -OperatorIntent "Request explicit operator approval for future risky actions without treating approval as already granted." `
        -NormalizedIntent "operator_approval_request_packet_only_approval_not_granted" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_operator_approval_packet" -TargetRole "Orchestrator" -TargetSkill "request_operator_approval" -AcceptanceCriteria @("decision_packet_required", "approval_scope_declared", "approval_not_already_granted", "missing_approval_blocks_action")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "operator_approval_packet" -Description "Create an operator approval request packet for a future risky action." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("request_operator_approval") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "request_operator_approval") `
        -A2ARefs (New-R18IntakeA2ARefs -RoutingImplied:$true -PacketRefs @("state/a2a/r18_handoff_packets/release_manager_to_orchestrator_request_operator_approval.handoff.json")) `
        -RequiredInputRefs @("risky_action_ref", "approval_scope_ref", "blocking_evidence_refs", "operator_decision_packet_ref") `
        -ExpectedPacketOutputs @("operator_approval_request_packet", "approval_scope_packet", "blocked_until_operator_decision_packet") `
        -EvidenceObligations @("decision_packet_requirement_recorded", "approval_scope_recorded", "approval_already_granted_false_flag_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$true -ApprovalScope "future_risky_action_scope" -OperatorApprovalRequiredFor @("api_enablement", "stage_commit_push_when_risky", "main_merge", "milestone_closeout", "automatic_new_thread_creation", "unsafe_wip_abandonment")) `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy) `
        -NextAllowedActions @("validate_approval_scope", "create_operator_decision_packet_requirement", "block_until_explicit_operator_decision")

    $packets += New-R18IntakeBasePacket `
        -IntakeType "operator_rejection_request" `
        -IntakeName "Operator Rejection Request" `
        -OperatorIntent "Record or route an operator rejection or refusal pathway for a proposed future action." `
        -NormalizedIntent "operator_rejection_request_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_operator_rejection_packet" -TargetRole "Orchestrator" -TargetSkill "request_operator_approval" -AcceptanceCriteria @("blocked_action_declared", "rejection_reason_declared", "next_safe_action_declared", "evidence_refs_declared")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "operator_rejection_packet" -Description "Create an operator rejection/refusal packet without executing the blocked action." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("request_operator_approval") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "request_operator_approval") `
        -A2ARefs (New-R18IntakeA2ARefs) `
        -RequiredInputRefs @("blocked_action_ref", "operator_rejection_reason_ref", "next_safe_action_ref", "evidence_refs") `
        -ExpectedPacketOutputs @("operator_rejection_packet", "blocked_action_packet", "next_safe_action_packet") `
        -EvidenceObligations @("blocked_action_recorded", "rejection_reason_recorded", "next_safe_action_recorded", "evidence_refs_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$true -ApprovalScope "operator_rejection_scope") `
        -FailureRouting (New-R18IntakeFailureRouting) `
        -RetryPolicy (New-R18IntakeRetryPolicy) `
        -NextAllowedActions @("record_rejection_packet", "block_requested_action", "route_to_next_safe_action")
    $packets[-1]["operator_rejection_policy"] = [ordered]@{
        blocked_action = "future_action_blocked_by_operator"
        rejection_reason_required = $true
        next_safe_action = "stop_or_repair_scope_before_retry"
        evidence_refs_required = $true
    }

    $packets += New-R18IntakeBasePacket `
        -IntakeType "stop_block_request" `
        -IntakeName "Stop Block Request" `
        -OperatorIntent "Stop, block, or pause unsafe work before any runtime, board mutation, handoff, skill execution, or API action occurs." `
        -NormalizedIntent "stop_block_request_packet_only" `
        -TargetScope (New-R18IntakeTargetScope -CardId "aioffice-r18-002-agent_orchestrator-card-v1" -WorkOrderId "future_stop_block_packet" -TargetRole "Orchestrator" -TargetSkill "classify_failure" -AcceptanceCriteria @("stop_condition_declared", "blocked_action_declared", "responsible_role_declared", "required_recovery_path_declared")) `
        -RequestedAction (New-R18IntakeRequestedAction -ActionId "stop_block_packet" -Description "Create a stop/block packet for unsafe work without mutating board state." -ReadOnly:$false -MutationAllowed:$false) `
        -AgentRoles @("Orchestrator") `
        -SkillIds @("classify_failure") `
        -PermissionRef (New-R18IntakePermissionRef -Role "Orchestrator" -SkillId "classify_failure") `
        -A2ARefs (New-R18IntakeA2ARefs) `
        -RequiredInputRefs @("stop_condition_ref", "blocked_action_ref", "responsible_role_ref", "required_recovery_path_ref") `
        -ExpectedPacketOutputs @("stop_block_packet", "blocked_action_record", "required_recovery_path_packet") `
        -EvidenceObligations @("stop_condition_recorded", "blocked_action_recorded", "responsible_role_recorded", "required_recovery_path_recorded") `
        -OperatorDecisionPolicy (New-R18IntakeDecisionPolicy -DecisionPacketRequired:$true -ApprovalScope "unsafe_work_stop_or_block_scope") `
        -FailureRouting (New-R18IntakeFailureRouting -Behavior "stop_and_block_until_recovery_path_validated") `
        -RetryPolicy (New-R18IntakeRetryPolicy -MaxRetryCount 0) `
        -NextAllowedActions @("record_stop_condition", "block_unsafe_action", "require_recovery_path_before_resume")
    $packets[-1]["stop_block_policy"] = [ordered]@{
        stop_condition = "unsafe_or_out_of_scope_work_detected"
        blocked_action = "runtime_or_mutation_or_api_or_unbounded_action"
        responsible_role = "Orchestrator"
        required_recovery_path = "operator_decision_or_validated_repair_packet"
    }

    return $packets
}

function New-R18IntakeContract {
    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-006-orchestrator-control-intake-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = $script:R18Repository
        branch = $script:R18Branch
        scope = "orchestrator_chat_control_intake_contract_and_seed_packets_only_not_live_chat_ui_or_runtime"
        purpose = "Define an operator-facing intake contract that normalizes future Orchestrator control-surface requests into explicit, machine-checkable intake packets for work-order creation, status queries, recovery actions, retry/escalation handling, evidence queries, operator approvals, operator rejections, and stop/block decisions."
        required_intake_types = $script:R18RequiredIntakeTypes
        required_intake_fields = $script:R18RequiredIntakeFields
        required_target_scope_fields = $script:R18RequiredTargetScopeFields
        required_decision_policy_fields = $script:R18RequiredDecisionPolicyFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        intake_type_policy = [ordered]@{
            exact_required_type_set = $script:R18RequiredIntakeTypes
            unknown_intake_types_allowed = $false
            duplicate_intake_types_allowed = $false
            wildcard_intake_types_allowed = $false
            unbounded_freeform_prompt_allowed = $false
            raw_prompt_only_recovery_allowed = $false
        }
        authority_policy = [ordered]@{
            r18_authority_refs_required = $true
            current_status_refs_required = $true
            agent_card_evidence_required = $true
            skill_contract_evidence_required = $true
            a2a_handoff_evidence_required_when_routing_implied = $true
            permission_matrix_evidence_required = $true
        }
        permission_policy = [ordered]@{
            target_role_must_exist_in_agent_cards = $true
            target_skill_must_exist_in_skill_registry = $true
            role_skill_pairing_must_be_allowed_or_approval_required = $true
            denied_pairings_must_route_to_failure_or_block = $true
            permission_matrix_bypass_allowed = $false
            qa_audit_release_approval_bypass_allowed = $false
        }
        a2a_policy = [ordered]@{
            handoff_validation_required_when_routing_implied = $true
            a2a_message_send_allowed = $false
            live_a2a_runtime_allowed = $false
            live_dispatch_allowed = $false
            bypass_allowed = $false
        }
        recovery_policy = [ordered]@{
            failure_event_ref_or_operator_failure_note_required = $true
            raw_prompt_only_recovery_allowed = $false
            automatic_new_thread_creation_allowed = $false
            live_recovery_runtime_allowed = $false
        }
        operator_decision_policy = [ordered]@{
            approval_as_already_granted_allowed = $false
            decision_packet_required_for_risky_actions = $true
            rejection_packet_must_record_blocked_action_reason_next_safe_action = $true
            missing_decision_blocks_action = $true
        }
        path_policy = New-R18IntakePathPolicy
        api_policy = New-R18IntakeApiPolicy
        evidence_policy = [ordered]@{
            evidence_obligations_required_on_every_packet = $true
            proof_review_refs_required = $true
            runtime_false_flags_required = $true
            historical_r13_r16_evidence_edits_allowed = $false
            operator_local_backup_paths_allowed = $false
        }
        retry_failure_policy = [ordered]@{
            bounded_retry_count_required = $true
            unbounded_retry_allowed = $false
            failure_routing_required = $true
            operator_decision_required_on_retry_exhaustion = $true
            maximum_retry_count_before_operator_decision = 3
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18IntakeNonClaims
        evidence_refs = Get-R18IntakeEvidenceRefs
        authority_refs = Get-R18IntakeAuthorityRefs
    }
}

function New-R18IntakeRegistry {
    param([Parameter(Mandatory = $true)][object[]]$Packets)

    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_registry"
        contract_version = "v1"
        registry_id = "aioffice-r18-006-orchestrator-control-intake-registry-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = $script:R18SourceTask
        intake_status = "packet_only_not_routed"
        intake_count = @($Packets).Count
        required_intake_types = $script:R18RequiredIntakeTypes
        intakes = @($Packets | ForEach-Object {
                [ordered]@{
                    intake_id = $_.intake_id
                    intake_name = $_.intake_name
                    intake_type = $_.intake_type
                    target_role = $_.target_scope.target_role
                    target_skill = $_.target_scope.target_skill
                    packet_ref = "state/intake/r18_orchestrator_control_intake_packets/$($script:R18RequiredIntakeFileMap[$_.intake_type])"
                    intake_status = $_.intake_status
                    live_routing_allowed = $false
                    live_chat_ui_allowed = $false
                    runtime_execution_allowed = $false
                }
            })
        runtime_flags = Get-R18IntakeRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18IntakeNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18IntakeEvidenceRefs
        authority_refs = Get-R18IntakeAuthorityRefs
    }
}

function New-R18IntakeCheckReport {
    param([Parameter(Mandatory = $true)][object[]]$Packets)

    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-006-orchestrator-control-intake-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = $script:R18SourceTask
        required_intake_count = @($script:R18RequiredIntakeTypes).Count
        generated_intake_count = @($Packets).Count
        checks = [ordered]@{
            required_packets_present = @{ status = "passed" }
            required_fields_present = @{ status = "passed" }
            target_roles_map_to_agent_cards = @{ status = "passed" }
            target_skills_map_to_skill_registry = @{ status = "passed" }
            permission_matrix_refs_present = @{ status = "passed" }
            runtime_false_flags_preserved = @{ status = "passed" }
            api_flags_disabled = @{ status = "passed" }
            r18_boundary_preserved = @{ status = "passed" }
        }
        aggregate_verdict = $script:R18IntakeVerdict
        runtime_flags = Get-R18IntakeRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18IntakeNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18IntakeEvidenceRefs
        authority_refs = Get-R18IntakeAuthorityRefs
    }
}

function New-R18IntakeSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Packets)

    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_snapshot"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = $script:R18SourceTask
        ui_boundary_label = "orchestrator_control_intake_contract_snapshot_only_no_live_chat_ui"
        intake_status = "packet_only_not_routed"
        intake_count = @($Packets).Count
        intake_types = @($Packets | ForEach-Object { $_.intake_type })
        runtime_summary = Get-R18IntakeRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18IntakeNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18IntakeEvidenceRefs
        authority_refs = Get-R18IntakeAuthorityRefs
    }
}

function New-R18IntakeEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_status = "contract_seed_packet_proof_review_only"
        evidence_refs = Get-R18IntakeEvidenceRefs
        authority_refs = Get-R18IntakeAuthorityRefs
        validation_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_orchestrator_control_intake.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1"
        )
        runtime_flags = Get-R18IntakeRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18IntakeNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18IntakeProofReviewText {
    return @"
# R18-006 Orchestrator Control Intake Proof Review

R18-006 creates the Orchestrator chat/control intake contract, seed intake packets, registry, validator, fixtures, and proof-review package only.

The intake packets normalize future operator-facing requests into bounded packet shapes for work-order creation, status queries, recovery resume requests, retry/escalation handling, evidence queries, operator approval requests, operator rejection requests, and stop/block requests.

Non-claims preserved:
- No live chat UI is implemented.
- No Orchestrator runtime is implemented.
- No board/card runtime mutation occurred.
- No A2A messages were sent.
- No live agents were invoked.
- No live skills were executed.
- No A2A runtime, local runner runtime, or recovery runtime was implemented.
- No OpenAI API or Codex API invocation occurred.
- No automatic new-thread creation occurred.
- R18-007 through R18-028 remain planned only.
- Main is not merged.

Evidence refs are listed in `evidence_index.json`. The focused validator and test scripts are the authoritative checks for this packet-only foundation.
"@
}

function New-R18IntakeValidationManifestText {
    return @"
# R18-006 Validation Manifest

Required validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_orchestrator_control_intake.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_orchestrator_control_intake.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_orchestrator_control_intake.ps1`
- Prior R18 validators and status-doc gate remain required by the release worker prompt.

Expected posture:

- R18 active through R18-006 only.
- R18-007 through R18-028 planned only.
- Intake artifacts are contract and seed packets only.
- Runtime/API/live-routing flags remain false.
"@
}

function New-R18IntakeFixture {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureId,
        [Parameter(Mandatory = $true)][string]$Target,
        [string[]]$RemovePaths = @(),
        [hashtable]$SetValues = @{},
        [string[]]$ExpectedFailureFragments = @()
    )

    return [ordered]@{
        fixture_id = $FixtureId
        source_task = $script:R18SourceTask
        target = $Target
        remove_paths = $RemovePaths
        set_values = $SetValues
        expected_failure_fragments = $ExpectedFailureFragments
    }
}

function Get-R18IntakeFixtureDefinitions {
    return @(
        [ordered]@{ file = "invalid_missing_intake_id.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_intake_id" -Target "packet:create_work_order_request" -RemovePaths @("intake_id") -ExpectedFailureFragments @("missing required field 'intake_id'")) },
        [ordered]@{ file = "invalid_missing_operator_intent.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_operator_intent" -Target "packet:create_work_order_request" -RemovePaths @("operator_intent") -ExpectedFailureFragments @("missing required field 'operator_intent'")) },
        [ordered]@{ file = "invalid_unknown_intake_type.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_unknown_intake_type" -Target "packet:create_work_order_request" -SetValues @{ intake_type = "unknown_intake_type" } -ExpectedFailureFragments @("unknown intake_type")) },
        [ordered]@{ file = "invalid_missing_target_scope.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_target_scope" -Target "packet:create_work_order_request" -RemovePaths @("target_scope") -ExpectedFailureFragments @("missing required field 'target_scope'")) },
        [ordered]@{ file = "invalid_missing_authority_refs.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_authority_refs" -Target "packet:create_work_order_request" -RemovePaths @("authority_refs") -ExpectedFailureFragments @("missing required field 'authority_refs'")) },
        [ordered]@{ file = "invalid_missing_agent_card_refs.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_agent_card_refs" -Target "packet:create_work_order_request" -RemovePaths @("agent_card_refs") -ExpectedFailureFragments @("missing required field 'agent_card_refs'")) },
        [ordered]@{ file = "invalid_missing_skill_refs.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_skill_refs" -Target "packet:create_work_order_request" -RemovePaths @("skill_refs") -ExpectedFailureFragments @("missing required field 'skill_refs'")) },
        [ordered]@{ file = "invalid_missing_permission_matrix_ref.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_permission_matrix_ref" -Target "packet:create_work_order_request" -RemovePaths @("permission_matrix_ref") -ExpectedFailureFragments @("missing required field 'permission_matrix_ref'")) },
        [ordered]@{ file = "invalid_missing_expected_packet_outputs.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_expected_packet_outputs" -Target "packet:create_work_order_request" -RemovePaths @("expected_packet_outputs") -ExpectedFailureFragments @("missing required field 'expected_packet_outputs'")) },
        [ordered]@{ file = "invalid_missing_evidence_obligations.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_evidence_obligations" -Target "packet:create_work_order_request" -RemovePaths @("evidence_obligations") -ExpectedFailureFragments @("missing required field 'evidence_obligations'")) },
        [ordered]@{ file = "invalid_missing_validation_expectations.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_validation_expectations" -Target "packet:create_work_order_request" -RemovePaths @("validation_expectations") -ExpectedFailureFragments @("missing required field 'validation_expectations'")) },
        [ordered]@{ file = "invalid_missing_failure_routing.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_failure_routing" -Target "packet:create_work_order_request" -RemovePaths @("failure_routing") -ExpectedFailureFragments @("missing required field 'failure_routing'")) },
        [ordered]@{ file = "invalid_missing_operator_decision_policy.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_missing_operator_decision_policy" -Target "packet:create_work_order_request" -RemovePaths @("operator_decision_policy") -ExpectedFailureFragments @("missing required field 'operator_decision_policy'")) },
        [ordered]@{ file = "invalid_unbounded_freeform_prompt.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_unbounded_freeform_prompt" -Target "packet:create_work_order_request" -SetValues @{ "operator_intent_policy.unbounded_freeform_prompt_allowed" = $true } -ExpectedFailureFragments @("unbounded freeform prompt")) },
        [ordered]@{ file = "invalid_raw_prompt_only_recovery.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_raw_prompt_only_recovery" -Target "packet:recovery_resume_request" -SetValues @{ "recovery_resume_constraints.raw_prompt_only_recovery_allowed" = $true } -ExpectedFailureFragments @("raw prompt-only recovery")) },
        [ordered]@{ file = "invalid_bypass_permission_matrix.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_bypass_permission_matrix" -Target "packet:create_work_order_request" -SetValues @{ "permission_matrix_ref.bypass_allowed" = $true } -ExpectedFailureFragments @("permission matrix bypass")) },
        [ordered]@{ file = "invalid_bypass_a2a_handoff_validation.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_bypass_a2a_handoff_validation" -Target "packet:create_work_order_request" -SetValues @{ "a2a_handoff_refs.validation_required_when_routing_implied" = $false } -ExpectedFailureFragments @("bypasses A2A handoff validation")) },
        [ordered]@{ file = "invalid_runtime_orchestrator_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_runtime_orchestrator_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.orchestrator_runtime_implemented" = $true } -ExpectedFailureFragments @("claims Orchestrator runtime")) },
        [ordered]@{ file = "invalid_live_chat_ui_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_live_chat_ui_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.live_chat_ui_implemented" = $true } -ExpectedFailureFragments @("claims live chat UI")) },
        [ordered]@{ file = "invalid_board_runtime_mutation_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_board_runtime_mutation_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.board_runtime_mutation_performed" = $true } -ExpectedFailureFragments @("claims board runtime mutation")) },
        [ordered]@{ file = "invalid_a2a_message_sent_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_a2a_message_sent_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.a2a_message_sent" = $true } -ExpectedFailureFragments @("claims A2A message sent")) },
        [ordered]@{ file = "invalid_skill_execution_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_skill_execution_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.live_skill_execution_performed" = $true } -ExpectedFailureFragments @("claims live skill execution")) },
        [ordered]@{ file = "invalid_api_invocation_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_api_invocation_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.openai_api_invoked" = $true } -ExpectedFailureFragments @("claims OpenAI API invocation")) },
        [ordered]@{ file = "invalid_automatic_new_thread_creation_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_automatic_new_thread_creation_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.automatic_new_thread_creation_performed" = $true } -ExpectedFailureFragments @("claims automatic new-thread creation")) },
        [ordered]@{ file = "invalid_r18_007_completion_claim.json"; fixture = (New-R18IntakeFixture -FixtureId "invalid_r18_007_completion_claim" -Target "packet:create_work_order_request" -SetValues @{ "runtime_flags.r18_007_completed" = $true } -ExpectedFailureFragments @("claims R18-007 or later completion")) }
    )
}

function New-R18IntakeFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$FixtureDefinitions)

    return [ordered]@{
        artifact_type = "r18_orchestrator_control_intake_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        fixture_count = @($FixtureDefinitions).Count
        fixtures = @($FixtureDefinitions | ForEach-Object {
                [ordered]@{
                    file = $_.file
                    fixture_id = $_.fixture.fixture_id
                    target = $_.fixture.target
                    expected_failure_fragments = $_.fixture.expected_failure_fragments
                }
            })
    }
}

function Assert-R18IntakeCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18IntakeRequiredFields {
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

function Assert-R18IntakeNonEmptyArray {
    param(
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or @($Value).Count -eq 0) {
        throw "$Context must be a non-empty array."
    }
}

function Assert-R18IntakeRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($flag in $script:R18RuntimeFlagFields) {
        if ($null -eq $RuntimeFlags.PSObject.Properties[$flag]) {
            throw "$Context missing runtime flag '$flag'."
        }
        if ([bool]$RuntimeFlags.$flag -ne $false) {
            switch ($flag) {
                "live_chat_ui_implemented" { throw "$Context claims live chat UI." }
                "orchestrator_runtime_implemented" { throw "$Context claims Orchestrator runtime." }
                "intake_routed_by_runtime" { throw "$Context claims intake routed by runtime." }
                "board_runtime_mutation_performed" { throw "$Context claims board runtime mutation." }
                "live_agent_runtime_invoked" { throw "$Context claims live agent invocation." }
                "live_skill_execution_performed" { throw "$Context claims live skill execution." }
                "a2a_message_sent" { throw "$Context claims A2A message sent." }
                "live_a2a_runtime_implemented" { throw "$Context claims live A2A runtime." }
                "local_runner_runtime_implemented" { throw "$Context claims local runner runtime." }
                "live_recovery_runtime_implemented" { throw "$Context claims recovery runtime." }
                "openai_api_invoked" { throw "$Context claims OpenAI API invocation." }
                "codex_api_invoked" { throw "$Context claims Codex API invocation." }
                "autonomous_codex_invocation_performed" { throw "$Context claims autonomous Codex invocation." }
                "automatic_new_thread_creation_performed" { throw "$Context claims automatic new-thread creation." }
                "product_runtime_executed" { throw "$Context claims product runtime." }
                "no_manual_prompt_transfer_success_claimed" { throw "$Context claims no-manual-prompt-transfer success." }
                "solved_codex_compaction_claimed" { throw "$Context claims solved Codex compaction." }
                "solved_codex_reliability_claimed" { throw "$Context claims solved Codex reliability." }
                "r18_007_completed" { throw "$Context claims R18-007 or later completion." }
                "main_merge_claimed" { throw "$Context claims main merge." }
                default { throw "$Context runtime flag '$flag' must be false." }
            }
        }
    }
}

function Assert-R18IntakeNoWildcardValue {
    param(
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($item in @($Value)) {
        $text = ([string]$item).Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
            continue
        }
        $lower = $text.ToLowerInvariant()
        if ($script:R18ForbiddenWildcards -contains $lower -or $text -match '\*') {
            throw "$Context uses wildcard or unbounded value '$text'."
        }
    }
}

function Assert-R18IntakePathSet {
    param(
        [Parameter(Mandatory = $true)][object]$Paths,
        [Parameter(Mandatory = $true)][string]$Context,
        [bool]$AllowedPathSet = $true
    )

    Assert-R18IntakeNonEmptyArray -Value $Paths -Context $Context
    foreach ($path in @($Paths)) {
        $pathText = [string]$path
        if ($pathText -match '\*') {
            if ($AllowedPathSet) {
                throw "$Context uses wildcard path '$pathText'."
            }
            continue
        }
        if ($AllowedPathSet -and ($pathText -match '(^|/)state/proof_reviews/r1[3-6]_|(^|/)state/.*/r1[3-6]_|(^|/)governance/R1[3-6]_' -or $pathText -match '^state/proof_reviews/r1[3-6]')) {
            throw "$Context allows historical R13/R14/R15/R16 evidence edits."
        }
        if ($AllowedPathSet -and ($pathText -match '^\.local_backups/' -or $pathText -match 'operator-local backup')) {
            throw "$Context allows operator-local backup paths."
        }
    }
}

function Get-R18IntakeAgentCardIndex {
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    $index = @{}
    foreach ($file in Get-ChildItem -LiteralPath $paths.AgentCardRoot -Filter "*.json") {
        $card = Read-R18IntakeJson -Path $file.FullName
        $index[[string]$card.role] = $card
    }
    return $index
}

function Get-R18IntakeSkillRegistryIndex {
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    $registry = Read-R18IntakeJson -Path $paths.SkillRegistry
    $index = @{}
    foreach ($skill in @($registry.skills)) {
        $index[[string]$skill.skill_id] = $skill
    }
    return $index
}

function Get-R18IntakePermissionIndex {
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    $matrix = Read-R18IntakeJson -Path $paths.PermissionMatrix
    $index = @{}
    foreach ($permission in @($matrix.permissions)) {
        $key = "{0}|{1}" -f [string]$permission.role, [string]$permission.skill_id
        $index[$key] = $permission
    }
    return $index
}

function Assert-R18IntakeContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18IntakeRequiredFields -Object $Contract -FieldNames @(
        "artifact_type",
        "contract_version",
        "contract_id",
        "source_task",
        "source_milestone",
        "repository",
        "branch",
        "scope",
        "purpose",
        "required_intake_types",
        "required_intake_fields",
        "required_target_scope_fields",
        "required_decision_policy_fields",
        "required_runtime_false_flags",
        "intake_type_policy",
        "authority_policy",
        "permission_policy",
        "a2a_policy",
        "recovery_policy",
        "operator_decision_policy",
        "path_policy",
        "api_policy",
        "evidence_policy",
        "retry_failure_policy",
        "allowed_positive_claims",
        "rejected_claims",
        "non_claims",
        "evidence_refs",
        "authority_refs"
    ) -Context "R18 intake contract"
    Assert-R18IntakeCondition -Condition ($Contract.artifact_type -eq "r18_orchestrator_control_intake_contract") -Message "R18 intake contract artifact_type is invalid."
    Assert-R18IntakeCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "R18 intake contract source_task must be R18-006."
    Assert-R18IntakeCondition -Condition (@($Contract.required_intake_types).Count -eq @($script:R18RequiredIntakeTypes).Count) -Message "R18 intake contract must declare exactly the required intake types."
    foreach ($type in $script:R18RequiredIntakeTypes) {
        Assert-R18IntakeCondition -Condition (@($Contract.required_intake_types) -contains $type) -Message "R18 intake contract missing required intake type '$type'."
    }
    foreach ($field in $script:R18RequiredIntakeFields) {
        Assert-R18IntakeCondition -Condition (@($Contract.required_intake_fields) -contains $field) -Message "R18 intake contract missing required intake field '$field'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18IntakeCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "R18 intake contract missing required runtime false flag '$flag'."
    }
    Assert-R18IntakeCondition -Condition ([bool]$Contract.intake_type_policy.unknown_intake_types_allowed -eq $false) -Message "R18 intake contract allows unknown intake types."
    Assert-R18IntakeCondition -Condition ([bool]$Contract.intake_type_policy.unbounded_freeform_prompt_allowed -eq $false) -Message "R18 intake contract allows unbounded freeform prompts."
    Assert-R18IntakeCondition -Condition ([bool]$Contract.permission_policy.permission_matrix_bypass_allowed -eq $false) -Message "R18 intake contract allows permission matrix bypass."
    Assert-R18IntakeCondition -Condition ([bool]$Contract.a2a_policy.a2a_message_send_allowed -eq $false) -Message "R18 intake contract allows A2A message sending."
    Assert-R18IntakeCondition -Condition ([bool]$Contract.api_policy.openai_api_invocation_allowed -eq $false -and [bool]$Contract.api_policy.codex_api_invocation_allowed -eq $false) -Message "R18 intake contract allows API invocation."
}

function Assert-R18IntakePacket {
    param(
        [Parameter(Mandatory = $true)][object]$Packet,
        [Parameter(Mandatory = $true)][hashtable]$AgentCards,
        [Parameter(Mandatory = $true)][hashtable]$SkillRegistry,
        [Parameter(Mandatory = $true)][hashtable]$PermissionIndex
    )

    $packetId = if ($null -ne $Packet.PSObject.Properties["intake_id"]) { [string]$Packet.intake_id } else { "<missing_intake_id>" }
    $context = "intake packet '$packetId'"
    Assert-R18IntakeRequiredFields -Object $Packet -FieldNames $script:R18RequiredIntakeFields -Context $context
    Assert-R18IntakeCondition -Condition ($Packet.artifact_type -eq "r18_orchestrator_control_intake_packet") -Message "$context artifact_type is invalid."
    Assert-R18IntakeCondition -Condition ($Packet.source_task -eq $script:R18SourceTask) -Message "$context source_task must be R18-006."
    Assert-R18IntakeCondition -Condition ($Packet.intake_status -eq "packet_only_not_routed") -Message "$context must remain packet_only_not_routed."
    if ($script:R18RequiredIntakeTypes -notcontains [string]$Packet.intake_type) {
        throw "$context uses unknown intake_type '$($Packet.intake_type)'."
    }

    foreach ($field in @("operator_intent", "normalized_intent")) {
        if ([string]::IsNullOrWhiteSpace([string]$Packet.$field)) {
            throw "$context lacks $field."
        }
    }

    if ($null -ne $Packet.PSObject.Properties["operator_intent_policy"]) {
        if ([bool]$Packet.operator_intent_policy.unbounded_freeform_prompt_allowed) {
            throw "$context allows unbounded freeform prompt."
        }
        if ([bool]$Packet.operator_intent_policy.raw_prompt_only_recovery_allowed) {
            throw "$context allows raw prompt-only recovery."
        }
    }

    Assert-R18IntakeRequiredFields -Object $Packet.target_scope -FieldNames $script:R18RequiredTargetScopeFields -Context "$context target_scope"
    $targetRole = [string]$Packet.target_scope.target_role
    $targetSkill = [string]$Packet.target_scope.target_skill
    Assert-R18IntakeNoWildcardValue -Value $targetRole -Context "$context target_role"
    Assert-R18IntakeNoWildcardValue -Value $targetSkill -Context "$context target_skill"
    if (-not $AgentCards.ContainsKey($targetRole)) {
        throw "$context references unknown target role '$targetRole'."
    }
    if (-not $SkillRegistry.ContainsKey($targetSkill)) {
        throw "$context references unknown target skill '$targetSkill'."
    }
    Assert-R18IntakePathSet -Paths $Packet.target_scope.allowed_paths -Context "$context target_scope.allowed_paths" -AllowedPathSet:$true
    Assert-R18IntakePathSet -Paths $Packet.allowed_paths -Context "$context allowed_paths" -AllowedPathSet:$true
    Assert-R18IntakePathSet -Paths $Packet.forbidden_paths -Context "$context forbidden_paths" -AllowedPathSet:$false

    Assert-R18IntakeNonEmptyArray -Value $Packet.authority_refs -Context "$context authority_refs"
    foreach ($requiredRef in @("governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md", "state/governance/r18_opening_authority.json", "contracts/agents/r18_agent_card.contract.json", "contracts/skills/r18_skill_contract.contract.json", "contracts/a2a/r18_a2a_handoff_packet.contract.json", "state/skills/r18_role_skill_permission_matrix.json")) {
        if (@($Packet.authority_refs) -notcontains $requiredRef) {
            throw "$context authority_refs missing '$requiredRef'."
        }
    }

    Assert-R18IntakeNonEmptyArray -Value $Packet.agent_card_refs -Context "$context agent_card_refs"
    $agentRoles = @($Packet.agent_card_refs | ForEach-Object { [string]$_.role })
    if ($agentRoles -notcontains "Orchestrator") {
        throw "$context agent_card_refs must reference Orchestrator."
    }
    if ($agentRoles -notcontains $targetRole) {
        throw "$context agent_card_refs must reference target role '$targetRole'."
    }

    Assert-R18IntakeNonEmptyArray -Value $Packet.skill_refs -Context "$context skill_refs"
    $skillIds = @($Packet.skill_refs | ForEach-Object { [string]$_.skill_id })
    if ($skillIds -notcontains $targetSkill) {
        throw "$context skill_refs must reference target skill '$targetSkill'."
    }

    if ($null -eq $Packet.permission_matrix_ref.PSObject.Properties["matrix_ref"] -or [string]::IsNullOrWhiteSpace([string]$Packet.permission_matrix_ref.matrix_ref)) {
        throw "$context missing permission matrix ref."
    }
    if ([bool]$Packet.permission_matrix_ref.bypass_allowed) {
        throw "$context attempts permission matrix bypass."
    }
    $permissionKey = "{0}|{1}" -f $targetRole, $targetSkill
    if (-not $PermissionIndex.ContainsKey($permissionKey)) {
        throw "$context has no permission matrix row for '$targetRole/$targetSkill'."
    }
    $permission = $PermissionIndex[$permissionKey]
    $permissionStatus = [string]$permission.permission_status
    if ($permissionStatus -eq "denied") {
        if ($null -eq $Packet.failure_routing.PSObject.Properties["block_on_denied_permission"] -or [bool]$Packet.failure_routing.block_on_denied_permission -ne $true -or [string]$Packet.failure_routing.behavior -notmatch "block|fail_closed|stop") {
            throw "$context references a denied role-skill pairing without failure/block routing."
        }
    }
    elseif ($permissionStatus -notin @("allowed", "approval_required")) {
        throw "$context has unknown permission status '$permissionStatus'."
    }

    Assert-R18IntakeRequiredFields -Object $Packet.operator_decision_policy -FieldNames $script:R18RequiredDecisionPolicyFields -Context "$context operator_decision_policy"
    if ([bool]$Packet.operator_decision_policy.approval_already_granted) {
        throw "$context treats operator approval as already granted."
    }
    if ([bool]$Packet.operator_decision_policy.decision_may_be_inferred) {
        throw "$context allows inferred operator decision."
    }

    Assert-R18IntakeRequiredFields -Object $Packet.failure_routing -FieldNames @("behavior", "failure_packet_required", "block_on_denied_permission", "bypass_allowed") -Context "$context failure_routing"
    if ([bool]$Packet.failure_routing.bypass_allowed) {
        throw "$context allows failure routing bypass."
    }
    if ([bool]$Packet.failure_routing.failure_packet_required -ne $true) {
        throw "$context failure_routing must require a failure packet."
    }

    Assert-R18IntakeNonEmptyArray -Value $Packet.required_input_refs -Context "$context required_input_refs"
    Assert-R18IntakeNonEmptyArray -Value $Packet.expected_packet_outputs -Context "$context expected_packet_outputs"
    Assert-R18IntakeNonEmptyArray -Value $Packet.evidence_obligations -Context "$context evidence_obligations"
    Assert-R18IntakeRequiredFields -Object $Packet.validation_expectations -FieldNames @("checks", "validation_commands", "expected_outputs", "fail_closed_on_missing_fields", "unknown_intake_type_rejected", "runtime_claims_rejected") -Context "$context validation_expectations"
    Assert-R18IntakeNonEmptyArray -Value $Packet.validation_expectations.checks -Context "$context validation_expectations.checks"

    if ($null -eq $Packet.a2a_handoff_refs.PSObject.Properties["refs"]) {
        throw "$context missing a2a_handoff_refs refs."
    }
    Assert-R18IntakeNonEmptyArray -Value $Packet.a2a_handoff_refs.refs -Context "$context a2a_handoff_refs.refs"
    if ([bool]$Packet.a2a_handoff_refs.routing_implied -and [bool]$Packet.a2a_handoff_refs.validation_required_when_routing_implied -ne $true) {
        throw "$context bypasses A2A handoff validation when routing is implied."
    }
    if ([bool]$Packet.a2a_handoff_refs.a2a_message_send_allowed -or [bool]$Packet.a2a_handoff_refs.live_dispatch_allowed -or [bool]$Packet.a2a_handoff_refs.live_a2a_runtime_allowed) {
        throw "$context claims live A2A routing or message send."
    }

    if ($Packet.intake_type -eq "status_query_request" -or $Packet.intake_type -eq "evidence_query_request") {
        if ([bool]$Packet.requested_action.read_only -ne $true -or [bool]$Packet.requested_action.mutation_allowed -ne $false -or [bool]$Packet.requested_action.board_state_mutation_allowed -ne $false) {
            throw "$context must be read-only and must not mutate status docs or board state."
        }
    }

    if ($Packet.intake_type -eq "recovery_resume_request") {
        if ($null -eq $Packet.PSObject.Properties["recovery_resume_constraints"]) {
            throw "$context missing recovery resume constraints."
        }
        if ([bool]$Packet.recovery_resume_constraints.raw_prompt_only_recovery_allowed) {
            throw "$context allows raw prompt-only recovery."
        }
        if ([bool]$Packet.recovery_resume_constraints.failure_event_refs_or_operator_failure_note_required -ne $true) {
            throw "$context must require failure event refs or explicit operator-provided failure note."
        }
    }

    if ($Packet.intake_type -eq "retry_escalation_request") {
        foreach ($requiredField in @("retry_count", "failure_packet_ref", "escalation_reason", "operator_decision_condition")) {
            if ($null -eq $Packet.retry_failover_policy.PSObject.Properties[$requiredField] -or [string]::IsNullOrWhiteSpace([string]$Packet.retry_failover_policy.$requiredField)) {
                throw "$context retry escalation missing '$requiredField'."
            }
        }
    }

    if ($Packet.intake_type -eq "operator_approval_request") {
        if ([bool]$Packet.operator_decision_policy.decision_packet_required -ne $true -or [string]$Packet.operator_decision_policy.approval_scope -eq "not_requested") {
            throw "$context must include decision packet requirement and approval scope."
        }
        if ([bool]$Packet.operator_decision_policy.approval_already_granted) {
            throw "$context treats approval as already granted."
        }
    }

    if ($Packet.intake_type -eq "operator_rejection_request") {
        if ($null -eq $Packet.PSObject.Properties["operator_rejection_policy"]) {
            throw "$context missing operator rejection policy."
        }
        foreach ($requiredField in @("blocked_action", "next_safe_action")) {
            if ([string]::IsNullOrWhiteSpace([string]$Packet.operator_rejection_policy.$requiredField)) {
                throw "$context operator rejection policy missing '$requiredField'."
            }
        }
        if ([bool]$Packet.operator_rejection_policy.rejection_reason_required -ne $true -or [bool]$Packet.operator_rejection_policy.evidence_refs_required -ne $true) {
            throw "$context operator rejection must require reason and evidence refs."
        }
    }

    if ($Packet.intake_type -eq "stop_block_request") {
        if ($null -eq $Packet.PSObject.Properties["stop_block_policy"]) {
            throw "$context missing stop/block policy."
        }
        foreach ($requiredField in @("stop_condition", "blocked_action", "responsible_role", "required_recovery_path")) {
            if ([string]::IsNullOrWhiteSpace([string]$Packet.stop_block_policy.$requiredField)) {
                throw "$context stop/block policy missing '$requiredField'."
            }
        }
    }

    Assert-R18IntakeNoWildcardValue -Value $Packet.next_allowed_actions -Context "$context next_allowed_actions"
    foreach ($action in @($Packet.next_allowed_actions)) {
        if ([string]$action -match '(?i)unbounded|do_anything|whatever') {
            throw "$context uses unbounded next action."
        }
    }

    Assert-R18IntakeRuntimeFlags -RuntimeFlags $Packet.runtime_flags -Context $context

    $nonClaimText = @($Packet.non_claims) -join " "
    foreach ($required in @("not a live chat UI", "not Orchestrator runtime", "No board/card runtime mutation", "No A2A messages were sent", "No live agents were invoked", "No live skills were executed", "No local runner runtime", "No recovery runtime", "No OpenAI API invocation", "No Codex API invocation", "No automatic new-thread creation", "R18-007 through R18-028 remain planned only", "Main is not merged")) {
        if ($nonClaimText -notmatch [regex]::Escape($required)) {
            throw "$context non_claims must preserve '$required'."
        }
    }
}

function Assert-R18IntakeRegistry {
    param([Parameter(Mandatory = $true)][object]$Registry)

    Assert-R18IntakeRequiredFields -Object $Registry -FieldNames @("artifact_type", "contract_version", "registry_id", "source_task", "source_milestone", "active_through_task", "intake_status", "intake_count", "required_intake_types", "intakes", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 intake registry"
    Assert-R18IntakeCondition -Condition ($Registry.artifact_type -eq "r18_orchestrator_control_intake_registry") -Message "R18 intake registry artifact_type is invalid."
    Assert-R18IntakeCondition -Condition ($Registry.active_through_task -eq $script:R18SourceTask) -Message "R18 intake registry active_through_task must be R18-006."
    Assert-R18IntakeCondition -Condition ([int]$Registry.intake_count -eq @($script:R18RequiredIntakeTypes).Count) -Message "R18 intake registry count is invalid."
    Assert-R18IntakeRuntimeFlags -RuntimeFlags $Registry.runtime_flags -Context "R18 intake registry"
}

function Assert-R18IntakeCheckReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18IntakeRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_task", "source_milestone", "active_through_task", "required_intake_count", "generated_intake_count", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 intake check report"
    Assert-R18IntakeCondition -Condition ($Report.artifact_type -eq "r18_orchestrator_control_intake_check_report") -Message "R18 intake check report artifact_type is invalid."
    Assert-R18IntakeCondition -Condition ($Report.aggregate_verdict -eq $script:R18IntakeVerdict) -Message "R18 intake check report aggregate verdict is invalid."
    Assert-R18IntakeCondition -Condition ([int]$Report.required_intake_count -eq @($script:R18RequiredIntakeTypes).Count) -Message "R18 intake check report required count is invalid."
    Assert-R18IntakeCondition -Condition ([int]$Report.generated_intake_count -eq @($script:R18RequiredIntakeTypes).Count) -Message "R18 intake check report generated count is invalid."
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "R18 intake check report '$($check.Name)' must have status passed."
        }
    }
    Assert-R18IntakeRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "R18 intake check report"
}

function Assert-R18IntakeSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18IntakeRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_task", "source_milestone", "active_through_task", "ui_boundary_label", "intake_status", "intake_count", "intake_types", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "R18 intake snapshot"
    Assert-R18IntakeCondition -Condition ($Snapshot.artifact_type -eq "r18_orchestrator_control_intake_snapshot") -Message "R18 intake snapshot artifact_type is invalid."
    Assert-R18IntakeCondition -Condition ($Snapshot.active_through_task -eq $script:R18SourceTask) -Message "R18 intake snapshot active_through_task must be R18-006."
    Assert-R18IntakeCondition -Condition ($Snapshot.ui_boundary_label -match "no_live_chat_ui") -Message "R18 intake snapshot must preserve no-live-chat-UI boundary."
    Assert-R18IntakeRuntimeFlags -RuntimeFlags $Snapshot.runtime_summary -Context "R18 intake snapshot"
}

function Get-R18IntakeTaskStatusMap {
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

function Test-R18IntakeStatusTruth {
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18IntakePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-017 only",
            "R18-018 through R18-028 planned only",
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
            "R18 runtime implementation is not yet delivered",
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18IntakeTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18IntakeTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 17) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-017."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-017."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[8-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-015."
    }
}

function Test-R18OrchestratorControlIntakeSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object[]]$Packets,
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot)
    )

    $agentCards = Get-R18IntakeAgentCardIndex -RepositoryRoot $RepositoryRoot
    $skillRegistry = Get-R18IntakeSkillRegistryIndex -RepositoryRoot $RepositoryRoot
    $permissionIndex = Get-R18IntakePermissionIndex -RepositoryRoot $RepositoryRoot
    Assert-R18IntakeContract -Contract $Contract
    Assert-R18IntakeCondition -Condition (@($Packets).Count -eq @($script:R18RequiredIntakeTypes).Count) -Message "R18 intake set is missing required seed packets."
    foreach ($packet in @($Packets)) {
        Assert-R18IntakePacket -Packet $packet -AgentCards $agentCards -SkillRegistry $skillRegistry -PermissionIndex $permissionIndex
    }
    foreach ($intakeType in $script:R18RequiredIntakeTypes) {
        Assert-R18IntakeCondition -Condition (@($Packets | Where-Object { $_.intake_type -eq $intakeType }).Count -eq 1) -Message "R18 intake set missing required intake type '$intakeType'."
    }
    Assert-R18IntakeRegistry -Registry $Registry
    Assert-R18IntakeCheckReport -Report $Report
    Assert-R18IntakeSnapshot -Snapshot $Snapshot
    Test-R18IntakeStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredIntakeCount = [int]$Report.required_intake_count
        GeneratedIntakeCount = [int]$Report.generated_intake_count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18OrchestratorControlIntake {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    $packets = @()
    foreach ($intakeType in $script:R18RequiredIntakeTypes) {
        $packets += Read-R18IntakeJson -Path (Get-R18IntakePacketPath -RepositoryRoot $RepositoryRoot -IntakeType $intakeType)
    }

    return Test-R18OrchestratorControlIntakeSet `
        -Contract (Read-R18IntakeJson -Path $paths.Contract) `
        -Packets $packets `
        -Registry (Read-R18IntakeJson -Path $paths.Registry) `
        -Report (Read-R18IntakeJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18IntakeJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18IntakeObjectPathValue {
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

function Remove-R18IntakeObjectPathValue {
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

function Invoke-R18IntakeMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18IntakeObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18IntakeObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

function New-R18OrchestratorControlIntakeArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18IntakeRepositoryRoot))

    $paths = Get-R18IntakePaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18IntakeContract
    $packets = New-R18IntakePackets
    $registry = New-R18IntakeRegistry -Packets $packets
    $report = New-R18IntakeCheckReport -Packets $packets
    $snapshot = New-R18IntakeSnapshot -Packets $packets

    Write-R18IntakeJson -Path $paths.Contract -Value $contract
    foreach ($packet in @($packets)) {
        Write-R18IntakeJson -Path (Get-R18IntakePacketPath -RepositoryRoot $RepositoryRoot -IntakeType ([string]$packet.intake_type)) -Value $packet
    }
    Write-R18IntakeJson -Path $paths.Registry -Value $registry
    Write-R18IntakeJson -Path $paths.CheckReport -Value $report
    Write-R18IntakeJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18IntakeFixtureDefinitions
    Write-R18IntakeJson -Path $paths.FixtureManifest -Value (New-R18IntakeFixtureManifest -FixtureDefinitions $fixtureDefinitions)
    foreach ($definition in @($fixtureDefinitions)) {
        Write-R18IntakeJson -Path (Join-Path $paths.FixtureRoot $definition.file) -Value $definition.fixture
    }

    Write-R18IntakeJson -Path $paths.EvidenceIndex -Value (New-R18IntakeEvidenceIndex)
    Write-R18IntakeText -Path $paths.ProofReview -Value (New-R18IntakeProofReviewText)
    Write-R18IntakeText -Path $paths.ValidationManifest -Value (New-R18IntakeValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        PacketRoot = $paths.PacketRoot
        Registry = $paths.Registry
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredIntakeCount = @($script:R18RequiredIntakeTypes).Count
        GeneratedIntakeCount = @($packets).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

Export-ModuleMember -Function `
    Get-R18IntakePaths, `
    New-R18OrchestratorControlIntakeArtifacts, `
    Test-R18OrchestratorControlIntake, `
    Test-R18OrchestratorControlIntakeSet, `
    Test-R18IntakeStatusTruth, `
    Invoke-R18IntakeMutation, `
    Copy-R18IntakeObject, `
    Get-R18IntakeAgentCardIndex, `
    Get-R18IntakeSkillRegistryIndex, `
    Get-R18IntakePermissionIndex
