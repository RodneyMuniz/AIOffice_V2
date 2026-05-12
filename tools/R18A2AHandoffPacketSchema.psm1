Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18HandoffGeneratedFromHead = "0e891bf3566d0a744d9fe0bfa33aa36584d484e1"
$script:R18HandoffGeneratedFromTree = "f7abaebc9c8b051c8b0be84448c85772d92b8ca3"
$script:R18SourceTask = "R18-004"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18HandoffVerdict = "generated_r18_a2a_handoff_packet_schema_foundation_only"

$script:R18RequiredHandoffFileMap = [ordered]@{
    orchestrator_to_project_manager_define_work_order = "orchestrator_to_project_manager_define_work_order.handoff.json"
    project_manager_to_solution_architect_define_schema = "project_manager_to_solution_architect_define_schema.handoff.json"
    solution_architect_to_developer_codex_generate_bounded_artifacts = "solution_architect_to_developer_codex_generate_bounded_artifacts.handoff.json"
    developer_codex_to_qa_test_run_validator = "developer_codex_to_qa_test_run_validator.handoff.json"
    qa_test_to_developer_codex_repair_required = "qa_test_to_developer_codex_repair_required.handoff.json"
    qa_test_to_evidence_auditor_validation_passed = "qa_test_to_evidence_auditor_validation_passed.handoff.json"
    evidence_auditor_to_release_manager_generate_evidence_package = "evidence_auditor_to_release_manager_generate_evidence_package.handoff.json"
    release_manager_to_orchestrator_request_operator_approval = "release_manager_to_orchestrator_request_operator_approval.handoff.json"
}

$script:R18RequiredHandoffFields = @(
    "artifact_type",
    "contract_version",
    "handoff_id",
    "handoff_name",
    "source_task",
    "source_milestone",
    "handoff_status",
    "card_id",
    "work_order_id",
    "source_agent_id",
    "source_role",
    "target_agent_id",
    "target_role",
    "skill_ref",
    "required_input_refs",
    "expected_outputs",
    "memory_refs",
    "evidence_refs",
    "authority_refs",
    "current_state",
    "next_allowed_actions",
    "validation_expectations",
    "receiving_role_validation",
    "retry_failover_policy",
    "failure_routing",
    "approval_requirements",
    "allowed_paths",
    "forbidden_paths",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18CurrentStateFields = @(
    "card_status",
    "work_order_status",
    "source_completion_status",
    "target_acceptance_status"
)

$script:R18ReceivingValidationFields = @(
    "handoff_shape",
    "authority_refs",
    "source_role",
    "target_role",
    "skill_permission",
    "required_input_refs",
    "expected_outputs",
    "path_policy",
    "evidence_obligations",
    "retry_limit",
    "non_claims"
)

$script:R18RuntimeFlagFields = @(
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "live_agent_runtime_invoked",
    "live_skill_execution_performed",
    "live_recovery_runtime_implemented",
    "local_runner_runtime_implemented",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_005_completed",
    "main_merge_claimed"
)

$script:R18AllowedPositiveClaims = @(
    "r18_a2a_handoff_packet_schema_created",
    "r18_seed_handoff_packets_created",
    "r18_handoff_registry_created",
    "r18_a2a_handoff_validator_created",
    "r18_a2a_handoff_fixtures_created",
    "r18_a2a_handoff_proof_review_created"
)

$script:R18AllowedFailureRouting = @(
    "block_and_request_repair",
    "return_to_source_role",
    "request_operator_decision",
    "create_failure_packet",
    "stop_and_escalate"
)

$script:R18ForbiddenWildcards = @("*", "all", "any", "unbounded")

function Get-R18HandoffRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18HandoffPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18HandoffJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18HandoffJson {
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

function Write-R18HandoffText {
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

function Copy-R18HandoffObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18HandoffSchemaPaths {
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema"
    $fixtureRoot = "tests/fixtures/r18_a2a_handoff_packet_schema"
    $packetRoot = "state/a2a/r18_handoff_packets"

    $handoffFiles = [ordered]@{}
    foreach ($entry in $script:R18RequiredHandoffFileMap.GetEnumerator()) {
        $handoffFiles[$entry.Key] = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $packetRoot $entry.Value)
    }

    return [pscustomobject]@{
        Contract = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/a2a/r18_a2a_handoff_packet.contract.json"
        PacketRoot = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue $packetRoot
        HandoffFiles = $handoffFiles
        Registry = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r18_handoff_registry.json"
        CheckReport = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/a2a/r18_a2a_handoff_check_report.json"
        UiSnapshot = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json"
        Module = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18A2AHandoffPacketSchema.psm1"
        Generator = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_a2a_handoff_packet_schema.ps1"
        Validator = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_a2a_handoff_packet_schema.ps1"
        Test = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_a2a_handoff_packet_schema.ps1"
        FixtureRoot = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        AgentCardRoot = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_cards"
        SkillRegistry = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_registry.json"
    }
}

function Get-R18HandoffAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/governance/r18_opening_authority.json",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "state/agents/r18_agent_card_check_report.json",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_contracts/",
        "state/skills/r18_skill_registry.json",
        "state/skills/r18_skill_contract_check_report.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/a2a/r17_a2a_message.contract.json",
        "contracts/a2a/r17_a2a_handoff.contract.json",
        "contracts/a2a/r17_a2a_dispatcher.contract.json",
        "contracts/runtime/r17_automated_recovery_loop.contract.json"
    )
}

function Get-R18HandoffMemoryRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "state/governance/r18_opening_authority.json",
        "state/agents/r18_agent_cards/",
        "state/skills/r18_skill_registry.json",
        "state/skills/r18_skill_contracts/"
    )
}

function Get-R18HandoffEvidenceRefs {
    return @(
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_packets/",
        "state/a2a/r18_handoff_registry.json",
        "state/a2a/r18_a2a_handoff_check_report.json",
        "state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json",
        "tools/R18A2AHandoffPacketSchema.psm1",
        "tools/new_r18_a2a_handoff_packet_schema.ps1",
        "tools/validate_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tests/fixtures/r18_a2a_handoff_packet_schema/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema/"
    )
}

function Get-R18HandoffAllowedPaths {
    return @(
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_packets/",
        "state/a2a/r18_handoff_registry.json",
        "state/a2a/r18_a2a_handoff_check_report.json",
        "state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json",
        "tools/R18A2AHandoffPacketSchema.psm1",
        "tools/new_r18_a2a_handoff_packet_schema.ps1",
        "tools/validate_r18_a2a_handoff_packet_schema.ps1",
        "tests/test_r18_a2a_handoff_packet_schema.ps1",
        "tests/fixtures/r18_a2a_handoff_packet_schema/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema/",
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

function Get-R18HandoffForbiddenPaths {
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

function Get-R18HandoffRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18HandoffPositiveClaims {
    return @($script:R18AllowedPositiveClaims)
}

function Get-R18HandoffNonClaims {
    return @(
        "R18-004 created A2A handoff packet schema and seed handoff packets only.",
        "A2A handoff packets are schema/seed governance artifacts only; they are not live A2A runtime.",
        "R18-002 created agent card schema and seed cards only.",
        "Agent cards are not live agents.",
        "R18-003 created skill contract schema and seed skill contracts only.",
        "Skill contracts are not live skill execution.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "No live agents were invoked.",
        "No live skills were executed.",
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
        "R18-005 through R18-028 remain planned only.",
        "Main is not merged."
    )
}

function Get-R18HandoffRejectedClaims {
    return @(
        "a2a_message_sent",
        "live_a2a_runtime",
        "live_agent_runtime",
        "live_skill_execution",
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
        "r18_005_or_later_completion",
        "main_merge",
        "historical_evidence_edit",
        "operator_local_backup_path_use",
        "broad_repo_write",
        "wildcard_role",
        "wildcard_skill",
        "unbounded_next_action",
        "unbounded_retry"
    )
}

function New-R18HandoffCurrentState {
    param([Parameter(Mandatory = $true)][string]$TargetAcceptanceStatus)

    return [ordered]@{
        card_status = "bounded_card_context_available"
        work_order_status = "r18_004_schema_seed_governance_artifacts_only"
        source_completion_status = "source_packet_prepared_not_dispatched"
        target_acceptance_status = $TargetAcceptanceStatus
    }
}

function New-R18HandoffReceivingRoleValidation {
    $validation = [ordered]@{}
    foreach ($field in $script:R18ReceivingValidationFields) {
        $validation[$field] = $true
    }
    return $validation
}

function New-R18HandoffPathPolicy {
    return [ordered]@{
        allowed_paths_must_be_exact_or_task_scoped = $true
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
    }
}

function New-R18HandoffRetryFailoverPolicy {
    param(
        [int]$MaxRetryCount = 1,
        [string]$RetryCountSource = "handoff_packet_retry_count_field",
        [string[]]$EscalationConditions = @("missing_required_input_ref", "validator_failure", "unsafe_path_request"),
        [string]$FailureRoutingTarget = "source_role",
        [string[]]$OperatorDecisionRequiredWhen = @("retry_limit_reached", "authority_conflict_detected", "unsafe_wip_detected")
    )

    return [ordered]@{
        max_retry_count = $MaxRetryCount
        retry_count_source = $RetryCountSource
        retry_limit_enforced = $true
        unbounded_retry_allowed = $false
        escalation_conditions = $EscalationConditions
        failure_routing_target = $FailureRoutingTarget
        operator_decision_required_when = $OperatorDecisionRequiredWhen
    }
}

function New-R18HandoffFailureRouting {
    param(
        [Parameter(Mandatory = $true)][string]$Behavior,
        [Parameter(Mandatory = $true)][string]$FailureRoutingTarget,
        [string[]]$FailurePacketRequirements = @("failure_reason", "blocking_evidence_refs", "requested_repair_scope", "non_claims_preserved")
    )

    return [ordered]@{
        behavior = $Behavior
        failure_routing_target = $FailureRoutingTarget
        failure_packet_required = $true
        failure_packet_requirements = $FailurePacketRequirements
    }
}

function New-R18HandoffApprovalRequirements {
    param(
        [string[]]$OperatorApprovalRequiredFor = @("main_merge", "milestone_closeout", "external_audit_acceptance", "api_enablement", "automatic_new_thread_creation", "unsafe_wip_abandonment"),
        [bool]$DecisionPacketRequired = $false
    )

    return [ordered]@{
        operator_approval_required_for = $OperatorApprovalRequiredFor
        decision_packet_required = $DecisionPacketRequired
        developer_codex_decision_authority = $false
        qa_self_approval_allowed = $false
        audit_self_approval_allowed = $false
        release_manager_main_merge_without_operator_approval_allowed = $false
        missing_approval_blocks_action = $true
    }
}

function New-R18HandoffValidationExpectations {
    param(
        [string[]]$Checks,
        [string[]]$ValidationCommands = @("powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_a2a_handoff_packet_schema.ps1", "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_a2a_handoff_packet_schema.ps1"),
        [string[]]$ExpectedOutputs = @("validator_passed", "focused_tests_passed", "runtime_false_flags_preserved")
    )

    return [ordered]@{
        checks = $Checks
        validation_commands = $ValidationCommands
        expected_outputs = $ExpectedOutputs
        failure_packet_required_on_validation_failure = $true
    }
}

function New-R18HandoffPacket {
    param(
        [Parameter(Mandatory = $true)][string]$HandoffId,
        [Parameter(Mandatory = $true)][string]$HandoffName,
        [Parameter(Mandatory = $true)][string]$SourceAgentId,
        [Parameter(Mandatory = $true)][string]$SourceRole,
        [Parameter(Mandatory = $true)][string]$TargetAgentId,
        [Parameter(Mandatory = $true)][string]$TargetRole,
        [Parameter(Mandatory = $true)][string]$SkillRef,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [Parameter(Mandatory = $true)][string[]]$RequiredInputRefs,
        [Parameter(Mandatory = $true)][string[]]$ExpectedOutputs,
        [Parameter(Mandatory = $true)][string[]]$NextAllowedActions,
        [Parameter(Mandatory = $true)][string[]]$ValidationChecks,
        [Parameter(Mandatory = $true)][string]$FailureRoutingBehavior,
        [Parameter(Mandatory = $true)][string]$FailureRoutingTarget,
        [int]$MaxRetryCount = 1,
        [bool]$DecisionPacketRequired = $false,
        [string[]]$OperatorDecisionRequiredWhen = @("retry_limit_reached", "authority_conflict_detected", "unsafe_wip_detected"),
        [string[]]$AdditionalEvidenceRefs = @()
    )

    return [ordered]@{
        artifact_type = "r18_a2a_handoff_packet"
        contract_version = "v1"
        handoff_id = $HandoffId
        handoff_name = $HandoffName
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18HandoffGeneratedFromHead
        generated_from_tree = $script:R18HandoffGeneratedFromTree
        generated_state_artifact_only = $true
        handoff_status = "packet_only_not_dispatched"
        card_id = ("aioffice-r18-002-{0}-card-v1" -f $TargetAgentId)
        work_order_id = "r18-004-a2a-handoff-packet-schema-foundation"
        source_agent_id = $SourceAgentId
        source_role = $SourceRole
        target_agent_id = $TargetAgentId
        target_role = $TargetRole
        skill_ref = $SkillRef
        purpose = $Purpose
        required_input_refs = $RequiredInputRefs
        expected_outputs = $ExpectedOutputs
        memory_refs = (Get-R18HandoffMemoryRefs)
        evidence_refs = @((Get-R18HandoffEvidenceRefs) + $AdditionalEvidenceRefs | Select-Object -Unique)
        authority_refs = (Get-R18HandoffAuthorityRefs)
        current_state = (New-R18HandoffCurrentState -TargetAcceptanceStatus "target_must_validate_before_action")
        next_allowed_actions = $NextAllowedActions
        validation_expectations = (New-R18HandoffValidationExpectations -Checks $ValidationChecks)
        receiving_role_validation = (New-R18HandoffReceivingRoleValidation)
        retry_failover_policy = (New-R18HandoffRetryFailoverPolicy -MaxRetryCount $MaxRetryCount -FailureRoutingTarget $FailureRoutingTarget -OperatorDecisionRequiredWhen $OperatorDecisionRequiredWhen)
        failure_routing = (New-R18HandoffFailureRouting -Behavior $FailureRoutingBehavior -FailureRoutingTarget $FailureRoutingTarget)
        approval_requirements = (New-R18HandoffApprovalRequirements -DecisionPacketRequired:$DecisionPacketRequired)
        allowed_paths = (Get-R18HandoffAllowedPaths)
        forbidden_paths = (Get-R18HandoffForbiddenPaths)
        path_policy = (New-R18HandoffPathPolicy)
        runtime_flags = (Get-R18HandoffRuntimeFlags)
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
    }
}

function Get-R18HandoffPackets {
    return @(
        (New-R18HandoffPacket `
            -HandoffId "orchestrator_to_project_manager_define_work_order" `
            -HandoffName "Orchestrator to Project Manager Define Work Order" `
            -SourceAgentId "agent_orchestrator" `
            -SourceRole "Orchestrator" `
            -TargetAgentId "agent_project_manager" `
            -TargetRole "Project Manager" `
            -SkillRef "define_work_order" `
            -Purpose "Turn operator-approved R18 task objective into bounded work-order scope with operator/task authority refs and status-doc constraints." `
            -RequiredInputRefs @("operator_task_authority_ref", "r18_status_doc_constraints_ref", "active_milestone_scope_ref", "r17_caveat_non_claims_ref") `
            -ExpectedOutputs @("bounded_work_order_scope_packet", "acceptance_boundary_refs", "status_doc_constraint_refs", "evidence_expectation_refs") `
            -NextAllowedActions @("validate_operator_authority_refs", "draft_bounded_work_order_scope", "record_acceptance_boundary", "return_to_orchestrator_if_scope_ambiguous") `
            -ValidationChecks @("handoff_shape", "operator_task_authority_refs", "status_doc_constraints", "required_input_refs", "non_claims") `
            -FailureRoutingBehavior "return_to_source_role" `
            -FailureRoutingTarget "agent_orchestrator" `
            -MaxRetryCount 1)
        (New-R18HandoffPacket `
            -HandoffId "project_manager_to_solution_architect_define_schema" `
            -HandoffName "Project Manager to Solution Architect Define Schema" `
            -SourceAgentId "agent_project_manager" `
            -SourceRole "Project Manager" `
            -TargetAgentId "agent_solution_architect" `
            -TargetRole "Solution Architect" `
            -SkillRef "define_schema" `
            -Purpose "Convert work-order scope into schema/interface acceptance criteria with scope, known non-claims, and evidence expectations." `
            -RequiredInputRefs @("work_order_scope_packet_ref", "acceptance_criteria_ref", "known_non_claims_ref", "evidence_expectations_ref") `
            -ExpectedOutputs @("schema_acceptance_criteria_packet", "interface_boundary_refs", "required_field_list", "evidence_obligation_list") `
            -NextAllowedActions @("validate_work_order_scope", "define_required_schema_fields", "record_interface_acceptance_criteria", "return_scope_gap_to_project_manager") `
            -ValidationChecks @("scope_refs", "acceptance_criteria", "known_non_claims", "evidence_expectations", "skill_permission") `
            -FailureRoutingBehavior "return_to_source_role" `
            -FailureRoutingTarget "agent_project_manager" `
            -MaxRetryCount 1)
        (New-R18HandoffPacket `
            -HandoffId "solution_architect_to_developer_codex_generate_bounded_artifacts" `
            -HandoffName "Solution Architect to Developer/Codex Generate Bounded Artifacts" `
            -SourceAgentId "agent_solution_architect" `
            -SourceRole "Solution Architect" `
            -TargetAgentId "agent_developer_codex" `
            -TargetRole "Developer/Codex" `
            -SkillRef "generate_bounded_artifacts" `
            -Purpose "Implement bounded artifacts after schema, validators, allowed paths, forbidden paths, and explicit non-claims are defined." `
            -RequiredInputRefs @("schema_acceptance_criteria_packet_ref", "allowed_paths_ref", "forbidden_paths_ref", "validator_command_refs", "explicit_non_claims_ref") `
            -ExpectedOutputs @("bounded_artifact_refs", "diff_summary_ref", "validator_update_refs", "implementation_non_claims_packet") `
            -NextAllowedActions @("create_only_allowed_r18_004_artifacts", "update_only_allowed_status_surfaces", "run_declared_validators", "return_failure_packet_if_validator_fails") `
            -ValidationChecks @("schema_acceptance_criteria", "allowed_paths", "forbidden_paths", "validator_commands", "explicit_non_claims") `
            -FailureRoutingBehavior "create_failure_packet" `
            -FailureRoutingTarget "agent_solution_architect" `
            -MaxRetryCount 2)
        (New-R18HandoffPacket `
            -HandoffId "developer_codex_to_qa_test_run_validator" `
            -HandoffName "Developer/Codex to QA/Test Run Validator" `
            -SourceAgentId "agent_developer_codex" `
            -SourceRole "Developer/Codex" `
            -TargetAgentId "agent_qa_test" `
            -TargetRole "QA/Test" `
            -SkillRef "run_validator" `
            -Purpose "Ask QA/Test to validate generated artifacts with validation commands, expected outputs, evidence refs, and failure packet requirements." `
            -RequiredInputRefs @("generated_artifact_refs", "validation_command_refs", "expected_output_refs", "evidence_ref_list", "failure_packet_requirement_ref") `
            -ExpectedOutputs @("validator_result_refs", "qa_pass_or_fail_packet", "failure_packet_if_blocked", "non_claim_check_result") `
            -NextAllowedActions @("run_declared_validation_commands", "record_command_results", "create_failure_packet_on_failure", "handoff_to_evidence_auditor_on_pass") `
            -ValidationChecks @("validation_commands", "expected_outputs", "evidence_refs", "failure_packet_requirements", "runtime_false_flags") `
            -FailureRoutingBehavior "block_and_request_repair" `
            -FailureRoutingTarget "agent_developer_codex" `
            -MaxRetryCount 2)
        (New-R18HandoffPacket `
            -HandoffId "qa_test_to_developer_codex_repair_required" `
            -HandoffName "QA/Test to Developer/Codex Repair Required" `
            -SourceAgentId "agent_qa_test" `
            -SourceRole "QA/Test" `
            -TargetAgentId "agent_developer_codex" `
            -TargetRole "Developer/Codex" `
            -SkillRef "generate_bounded_artifacts" `
            -Purpose "Return bounded defect/repair request to Developer/Codex with defect evidence, allowed repair scope, retry count, and escalation policy." `
            -RequiredInputRefs @("qa_defect_evidence_ref", "allowed_repair_scope_ref", "retry_count_ref", "escalation_policy_ref", "failed_validator_output_ref") `
            -ExpectedOutputs @("bounded_repair_artifact_refs", "repair_diff_summary_ref", "rerun_validator_refs", "repair_non_claims_packet") `
            -NextAllowedActions @("repair_only_allowed_r18_004_scope", "rerun_declared_validators", "return_repair_result_to_qa", "escalate_if_retry_limit_reached") `
            -ValidationChecks @("defect_evidence", "allowed_repair_scope", "retry_count", "escalation_policy", "path_policy") `
            -FailureRoutingBehavior "stop_and_escalate" `
            -FailureRoutingTarget "agent_orchestrator" `
            -MaxRetryCount 2 `
            -OperatorDecisionRequiredWhen @("retry_limit_reached", "repair_scope_exceeds_allowed_paths", "authority_conflict_detected"))
        (New-R18HandoffPacket `
            -HandoffId "qa_test_to_evidence_auditor_validation_passed" `
            -HandoffName "QA/Test to Evidence Auditor Validation Passed" `
            -SourceAgentId "agent_qa_test" `
            -SourceRole "QA/Test" `
            -TargetAgentId "agent_evidence_auditor" `
            -TargetRole "Evidence Auditor" `
            -SkillRef "generate_evidence_package" `
            -Purpose "Request evidence audit after validation passes with validation evidence, non-claim checks, and artifact refs." `
            -RequiredInputRefs @("validation_pass_evidence_ref", "non_claim_check_ref", "generated_artifact_refs", "runtime_false_flag_refs", "status_truth_ref") `
            -ExpectedOutputs @("evidence_audit_packet", "accepted_claims_list", "rejected_claims_list", "release_blocker_list") `
            -NextAllowedActions @("audit_validation_evidence_refs", "check_non_claims", "package_evidence_refs", "handoff_release_gate_packet") `
            -ValidationChecks @("validation_evidence", "non_claim_checks", "artifact_refs", "runtime_false_flags", "status_truth") `
            -FailureRoutingBehavior "create_failure_packet" `
            -FailureRoutingTarget "agent_qa_test" `
            -MaxRetryCount 1)
        (New-R18HandoffPacket `
            -HandoffId "evidence_auditor_to_release_manager_generate_evidence_package" `
            -HandoffName "Evidence Auditor to Release Manager Generate Evidence Package" `
            -SourceAgentId "agent_evidence_auditor" `
            -SourceRole "Evidence Auditor" `
            -TargetAgentId "agent_release_manager" `
            -TargetRole "Release Manager" `
            -SkillRef "stage_commit_push_gate" `
            -Purpose "Transfer audit/evidence package for release gate assessment with proof-review refs, accepted/rejected claims, validation state, and release blockers." `
            -RequiredInputRefs @("proof_review_refs", "accepted_claims_ref", "rejected_claims_ref", "validation_state_ref", "release_blocker_ref") `
            -ExpectedOutputs @("release_gate_assessment_packet", "stage_commit_push_readiness_ref", "operator_approval_need_ref", "blocked_release_reason_ref") `
            -NextAllowedActions @("validate_proof_review_refs", "assess_release_blockers", "prepare_stage_commit_push_gate", "request_operator_decision_if_required") `
            -ValidationChecks @("proof_review_refs", "accepted_rejected_claims", "validation_state", "release_blockers", "approval_requirements") `
            -FailureRoutingBehavior "request_operator_decision" `
            -FailureRoutingTarget "agent_orchestrator" `
            -MaxRetryCount 1 `
            -DecisionPacketRequired:$true)
        (New-R18HandoffPacket `
            -HandoffId "release_manager_to_orchestrator_request_operator_approval" `
            -HandoffName "Release Manager to Orchestrator Request Operator Approval" `
            -SourceAgentId "agent_release_manager" `
            -SourceRole "Release Manager" `
            -TargetAgentId "agent_orchestrator" `
            -TargetRole "Orchestrator" `
            -SkillRef "request_operator_approval" `
            -Purpose "Request operator approval for risky release/closeout decision points with decision packet requirement and approval/refusal outcomes." `
            -RequiredInputRefs @("release_gate_assessment_packet_ref", "decision_packet_requirement_ref", "approval_outcome_schema_ref", "refusal_outcome_schema_ref", "non_claims_ref") `
            -ExpectedOutputs @("operator_decision_request_packet", "approval_outcome_ref", "refusal_outcome_ref", "blocked_until_operator_decision_state") `
            -NextAllowedActions @("prepare_operator_decision_request", "record_approval_or_refusal_outcome", "block_release_until_decision", "return_to_release_manager_after_decision") `
            -ValidationChecks @("decision_packet_requirement", "approval_outcome_schema", "refusal_outcome_schema", "release_manager_non_claims", "operator_authority_refs") `
            -FailureRoutingBehavior "request_operator_decision" `
            -FailureRoutingTarget "operator" `
            -MaxRetryCount 0 `
            -DecisionPacketRequired:$true `
            -OperatorDecisionRequiredWhen @("release_gate_decision_required", "stage_commit_push_requested", "milestone_closeout_requested", "main_merge_or_external_audit_acceptance_requested"))
    )
}

function New-R18HandoffContract {
    return [ordered]@{
        artifact_type = "r18_a2a_handoff_packet_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-004-a2a-handoff-packet-contract-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "a2a_handoff_packet_schema_and_seed_packets_only_not_live_a2a_runtime"
        purpose = "Define explicit, validated A2A handoff packets for bounded role-to-role transfer of card/work-order context without dispatching messages, invoking agents, executing skills, or implementing runtime."
        required_handoff_ids = @($script:R18RequiredHandoffFileMap.Keys)
        required_handoff_fields = $script:R18RequiredHandoffFields
        required_current_state_fields = $script:R18CurrentStateFields
        required_receiving_role_validation_fields = $script:R18ReceivingValidationFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        allowed_failure_routing = $script:R18AllowedFailureRouting
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        role_and_skill_validation_policy = [ordered]@{
            every_source_agent_id_must_exist_in_r18_agent_cards = $true
            every_target_agent_id_must_exist_in_r18_agent_cards = $true
            source_and_target_roles_must_match_agent_cards = $true
            every_skill_ref_must_exist_in_r18_skill_registry = $true
            target_role_must_be_allowed_for_skill = $true
            wildcard_roles_rejected = $true
            wildcard_skills_rejected = $true
            unbounded_next_actions_rejected = $true
            developer_codex_cannot_request_operator_approval_as_decision_authority = $true
            evidence_auditor_cannot_generate_implementation_artifacts = $true
            qa_test_cannot_self_approve_fixes = $true
            orchestrator_cannot_directly_implement_artifacts = $true
            release_manager_requires_operator_approval_packet_for_main_merge_closeout_or_external_audit_acceptance = $true
        }
        path_policy = (New-R18HandoffPathPolicy)
        retry_policy = [ordered]@{
            max_retry_count_required = $true
            retry_limit_enforced = $true
            unbounded_retry_allowed = $false
            maximum_allowed_retry_count_for_seed_packets = 3
        }
        evidence_refs = (Get-R18HandoffEvidenceRefs)
        authority_refs = (Get-R18HandoffAuthorityRefs)
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
    }
}

function New-R18HandoffRegistry {
    param([Parameter(Mandatory = $true)][object[]]$Handoffs)

    return [ordered]@{
        artifact_type = "r18_handoff_registry"
        contract_version = "v1"
        registry_id = "aioffice-r18-004-a2a-handoff-registry-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        active_through_task = "R18-004"
        handoff_status = "packet_only_not_dispatched"
        handoff_count = @($Handoffs).Count
        handoffs = @($Handoffs | ForEach-Object {
                [ordered]@{
                    handoff_id = $_.handoff_id
                    handoff_name = $_.handoff_name
                    source_agent_id = $_.source_agent_id
                    source_role = $_.source_role
                    target_agent_id = $_.target_agent_id
                    target_role = $_.target_role
                    skill_ref = $_.skill_ref
                    packet_ref = ("state/a2a/r18_handoff_packets/{0}" -f $script:R18RequiredHandoffFileMap[[string]$_.handoff_id])
                    handoff_status = $_.handoff_status
                    live_dispatch_allowed = $false
                    live_agent_invocation_allowed = $false
                    live_skill_execution_allowed = $false
                }
            })
        runtime_flags = (Get-R18HandoffRuntimeFlags)
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
        evidence_refs = (Get-R18HandoffEvidenceRefs)
        authority_refs = (Get-R18HandoffAuthorityRefs)
    }
}

function New-R18HandoffCheckReport {
    param([Parameter(Mandatory = $true)][object[]]$Handoffs)

    return [ordered]@{
        artifact_type = "r18_a2a_handoff_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-004-a2a-handoff-check-report-v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        required_handoff_count = @($script:R18RequiredHandoffFileMap.Keys).Count
        generated_handoff_count = @($Handoffs).Count
        handoff_ids = @($Handoffs | ForEach-Object { $_.handoff_id })
        checks = [ordered]@{
            required_seed_handoffs_present = [ordered]@{ status = "passed"; checked_count = @($Handoffs).Count }
            required_fields_present = [ordered]@{ status = "passed"; required_field_count = @($script:R18RequiredHandoffFields).Count }
            source_and_target_agents_map_to_r18_cards = [ordered]@{ status = "passed" }
            source_and_target_roles_match_cards = [ordered]@{ status = "passed" }
            skill_refs_map_to_r18_skill_registry = [ordered]@{ status = "passed" }
            target_roles_allowed_for_skills = [ordered]@{ status = "passed" }
            runtime_false_flags_preserved = [ordered]@{ status = "passed" }
            bounded_retries_enforced = [ordered]@{ status = "passed" }
            failure_routing_declared = [ordered]@{ status = "passed" }
            status_truth_active_through_r18_004_only = [ordered]@{ status = "passed" }
        }
        aggregate_verdict = $script:R18HandoffVerdict
        runtime_flags = (Get-R18HandoffRuntimeFlags)
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
        evidence_refs = (Get-R18HandoffEvidenceRefs)
        authority_refs = (Get-R18HandoffAuthorityRefs)
    }
}

function New-R18HandoffSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Handoffs)

    return [ordered]@{
        artifact_type = "r18_a2a_handoff_snapshot"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        active_through_task = "R18-004"
        ui_boundary_label = "A2A handoff packets are schema/seed governance artifacts only and are not dispatched."
        required_handoff_count = @($script:R18RequiredHandoffFileMap.Keys).Count
        generated_handoff_count = @($Handoffs).Count
        handoffs = @($Handoffs | ForEach-Object {
                [ordered]@{
                    handoff_id = $_.handoff_id
                    source_role = $_.source_role
                    target_role = $_.target_role
                    skill_ref = $_.skill_ref
                    handoff_status = $_.handoff_status
                    runtime_enabled = $false
                    a2a_message_sent = $false
                    live_agent_runtime_invoked = $false
                    live_skill_execution_performed = $false
                    max_retry_count = $_.retry_failover_policy.max_retry_count
                    failure_routing = $_.failure_routing.behavior
                }
            })
        runtime_summary = (Get-R18HandoffRuntimeFlags)
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
        evidence_refs = (Get-R18HandoffEvidenceRefs)
        authority_refs = (Get-R18HandoffAuthorityRefs)
    }
}

function New-R18HandoffEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_a2a_handoff_packet_schema_evidence_index"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        evidence_scope = "schema_seed_handoff_packets_registry_validator_fixtures_status_only"
        entries = @(
            [ordered]@{ path = "contracts/a2a/r18_a2a_handoff_packet.contract.json"; evidence_type = "contract" }
            [ordered]@{ path = "state/a2a/r18_handoff_packets/"; evidence_type = "seed_handoff_packets" }
            [ordered]@{ path = "state/a2a/r18_handoff_registry.json"; evidence_type = "handoff_registry" }
            [ordered]@{ path = "state/a2a/r18_a2a_handoff_check_report.json"; evidence_type = "check_report" }
            [ordered]@{ path = "state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json"; evidence_type = "operator_surface_snapshot_state_only" }
            [ordered]@{ path = "tools/R18A2AHandoffPacketSchema.psm1"; evidence_type = "validator_generator_module" }
            [ordered]@{ path = "tools/new_r18_a2a_handoff_packet_schema.ps1"; evidence_type = "generator_wrapper" }
            [ordered]@{ path = "tools/validate_r18_a2a_handoff_packet_schema.ps1"; evidence_type = "validator_wrapper" }
            [ordered]@{ path = "tests/test_r18_a2a_handoff_packet_schema.ps1"; evidence_type = "focused_tests" }
            [ordered]@{ path = "tests/fixtures/r18_a2a_handoff_packet_schema/"; evidence_type = "invalid_fixtures" }
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema/proof_review.md"; evidence_type = "proof_review" }
            [ordered]@{ path = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema/validation_manifest.md"; evidence_type = "validation_manifest" }
        )
        positive_claims = (Get-R18HandoffPositiveClaims)
        non_claims = (Get-R18HandoffNonClaims)
        rejected_claims = (Get-R18HandoffRejectedClaims)
        authority_refs = (Get-R18HandoffAuthorityRefs)
    }
}

function New-R18HandoffProofReviewText {
    return @"
# R18-004 A2A Handoff Packet Schema Proof Review

Status: R18-004 creates the A2A handoff packet schema, eight seed handoff packets, registry, validator, focused tests, fixtures, check report, operator-surface snapshot state artifact, and this proof-review package only.

Evidence reviewed:

- contracts/a2a/r18_a2a_handoff_packet.contract.json
- state/a2a/r18_handoff_packets/
- state/a2a/r18_handoff_registry.json
- state/a2a/r18_a2a_handoff_check_report.json
- state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json
- tools/R18A2AHandoffPacketSchema.psm1
- tools/new_r18_a2a_handoff_packet_schema.ps1
- tools/validate_r18_a2a_handoff_packet_schema.ps1
- tests/test_r18_a2a_handoff_packet_schema.ps1
- tests/fixtures/r18_a2a_handoff_packet_schema/

Boundary:

- A2A handoff packets are schema/seed governance artifacts only, not live A2A runtime.
- Handoff packets define source/target role validation, skill refs, required inputs, expected outputs, evidence refs, memory refs, authority refs, current state, finite next actions, validation expectations, bounded retry/failover policy, failure routing, approval requirements, path policy, runtime false flags, non-claims, and rejected claims.
- No A2A messages were sent, no live agents were invoked, no live skills were executed, no local runner runtime or recovery runtime was implemented, no API invocation occurred, no automatic new-thread creation occurred, no product runtime is claimed, no main merge occurred, and Codex compaction/reliability or no-manual-prompt-transfer success is not claimed.
- R18 remains active through R18-004 only; R18-005 through R18-028 remain planned only.
"@
}

function New-R18HandoffValidationManifestText {
    return @"
# R18-004 A2A Handoff Packet Schema Validation Manifest

Required validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_a2a_handoff_packet_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_a2a_handoff_packet_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_a2a_handoff_packet_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_skill_contract_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_skill_contract_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected status truth: R18 active through R18-004 only; R18-005 through R18-028 planned only.

Expected non-claims: no A2A messages sent, no live A2A runtime, no live agent runtime, no live skill execution, no local runner runtime, no live recovery runtime, no API invocation, no automatic new-thread creation, no product runtime, no main merge, no solved Codex compaction/reliability, and no no-manual-prompt-transfer success.
"@
}

function New-R18HandoffFixture {
    param(
        [Parameter(Mandatory = $true)][string]$Target,
        [string[]]$RemovePaths = @(),
        [hashtable]$SetValues = @{},
        [Parameter(Mandatory = $true)][string[]]$ExpectedFailureFragments
    )

    $orderedSetValues = [ordered]@{}
    foreach ($entry in $SetValues.GetEnumerator()) {
        $orderedSetValues[$entry.Key] = $entry.Value
    }

    return [ordered]@{
        target = $Target
        remove_paths = $RemovePaths
        set_values = $orderedSetValues
        expected_failure_fragments = $ExpectedFailureFragments
    }
}

function Get-R18HandoffFixtureDefinitions {
    $target = "handoff:orchestrator_to_project_manager_define_work_order"
    return @(
        [ordered]@{ file = "invalid_missing_handoff_id.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("handoff_id") -ExpectedFailureFragments @("missing required field 'handoff_id'")) }
        [ordered]@{ file = "invalid_missing_card_id.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("card_id") -ExpectedFailureFragments @("missing required field 'card_id'")) }
        [ordered]@{ file = "invalid_missing_source_role.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("source_role") -ExpectedFailureFragments @("missing required field 'source_role'")) }
        [ordered]@{ file = "invalid_missing_target_role.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("target_role") -ExpectedFailureFragments @("missing required field 'target_role'")) }
        [ordered]@{ file = "invalid_source_role_not_in_agent_cards.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ source_role = "Unregistered Role" } -ExpectedFailureFragments @("source_role")) }
        [ordered]@{ file = "invalid_target_role_not_in_agent_cards.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ target_role = "Unregistered Role" } -ExpectedFailureFragments @("target_role")) }
        [ordered]@{ file = "invalid_missing_skill_ref.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("skill_ref") -ExpectedFailureFragments @("missing required field 'skill_ref'")) }
        [ordered]@{ file = "invalid_skill_not_in_registry.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ skill_ref = "unknown_skill" } -ExpectedFailureFragments @("unknown skill_ref")) }
        [ordered]@{ file = "invalid_skill_not_allowed_for_target_role.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ skill_ref = "generate_bounded_artifacts" } -ExpectedFailureFragments @("target role", "not allowed")) }
        [ordered]@{ file = "invalid_missing_required_input_refs.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("required_input_refs") -ExpectedFailureFragments @("required_input_refs")) }
        [ordered]@{ file = "invalid_missing_expected_outputs.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("expected_outputs") -ExpectedFailureFragments @("expected_outputs")) }
        [ordered]@{ file = "invalid_missing_memory_refs.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("memory_refs") -ExpectedFailureFragments @("memory_refs")) }
        [ordered]@{ file = "invalid_missing_evidence_refs.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("evidence_refs") -ExpectedFailureFragments @("evidence_refs")) }
        [ordered]@{ file = "invalid_missing_authority_refs.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("authority_refs") -ExpectedFailureFragments @("authority_refs")) }
        [ordered]@{ file = "invalid_missing_current_state.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("current_state") -ExpectedFailureFragments @("current_state")) }
        [ordered]@{ file = "invalid_missing_next_allowed_actions.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("next_allowed_actions") -ExpectedFailureFragments @("next_allowed_actions")) }
        [ordered]@{ file = "invalid_missing_validation_expectations.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("validation_expectations") -ExpectedFailureFragments @("validation_expectations")) }
        [ordered]@{ file = "invalid_missing_retry_failover_policy.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("retry_failover_policy") -ExpectedFailureFragments @("retry_failover_policy")) }
        [ordered]@{ file = "invalid_missing_failure_routing.json"; fixture = (New-R18HandoffFixture -Target $target -RemovePaths @("failure_routing") -ExpectedFailureFragments @("failure_routing")) }
        [ordered]@{ file = "invalid_unbounded_retry.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "retry_failover_policy.unbounded_retry_allowed" = $true } -ExpectedFailureFragments @("unbounded retry")) }
        [ordered]@{ file = "invalid_live_a2a_message_sent_claim.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "runtime_flags.a2a_message_sent" = $true } -ExpectedFailureFragments @("A2A message sent")) }
        [ordered]@{ file = "invalid_live_agent_invocation_claim.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "runtime_flags.live_agent_runtime_invoked" = $true } -ExpectedFailureFragments @("live agent runtime")) }
        [ordered]@{ file = "invalid_skill_execution_claim.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "runtime_flags.live_skill_execution_performed" = $true } -ExpectedFailureFragments @("live skill execution")) }
        [ordered]@{ file = "invalid_api_invocation_claim.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "runtime_flags.openai_api_invoked" = $true } -ExpectedFailureFragments @("OpenAI API invocation")) }
        [ordered]@{ file = "invalid_r18_005_completion_claim.json"; fixture = (New-R18HandoffFixture -Target $target -SetValues @{ "runtime_flags.r18_005_completed" = $true } -ExpectedFailureFragments @("R18-005 or later completion")) }
    )
}

function New-R18HandoffFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$FixtureDefinitions)

    return [ordered]@{
        artifact_type = "r18_a2a_handoff_packet_schema_fixture_manifest"
        contract_version = "v1"
        source_milestone = $script:R18SourceMilestone
        source_task = $script:R18SourceTask
        valid_seed_handoff_count = @($script:R18RequiredHandoffFileMap.Keys).Count
        invalid_fixture_count = @($FixtureDefinitions).Count
        invalid_fixtures = @($FixtureDefinitions | ForEach-Object { $_.file })
        non_claims = (Get-R18HandoffNonClaims)
    }
}

function Get-R18HandoffAgentCardIndex {
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $root = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_cards"
    if (-not (Test-Path -LiteralPath $root -PathType Container)) {
        throw "R18 agent card root '$root' does not exist."
    }

    $index = @{}
    foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.card.json") {
        $card = Read-R18HandoffJson -Path $file.FullName
        if ([string]::IsNullOrWhiteSpace([string]$card.agent_id)) {
            throw "Agent card '$($file.FullName)' is missing agent_id."
        }
        $index[[string]$card.agent_id] = $card
    }
    return $index
}

function Get-R18HandoffSkillRegistryIndex {
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $registryPath = Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_registry.json"
    $registry = Read-R18HandoffJson -Path $registryPath
    $index = @{}
    foreach ($skill in @($registry.skills)) {
        $index[[string]$skill.skill_id] = $skill
    }
    return $index
}

function Assert-R18HandoffCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18HandoffRequiredFields {
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

function Assert-R18HandoffNonEmptyArray {
    param(
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or @($Value).Count -eq 0) {
        throw "$Context must be a non-empty array."
    }
}

function Assert-R18HandoffNonEmptyObject {
    param(
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or @($Value.PSObject.Properties).Count -eq 0) {
        throw "$Context must be a non-empty object."
    }
}

function Assert-R18HandoffFalseFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field]) {
            throw "$Context missing runtime flag '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context runtime flag '$field' must be false."
        }
    }
}

function Assert-R18HandoffNoWildcardValue {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $lower = $Value.ToLowerInvariant()
    if ($script:R18ForbiddenWildcards -contains $lower -or $Value -match '\*') {
        throw "$Context contains wildcard or unbounded value '$Value'."
    }
}

function Assert-R18HandoffRuntimeClaims {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:R18RuntimeFlagFields) {
        if ($null -eq $RuntimeFlags.PSObject.Properties[$field]) {
            throw "$Context runtime_flags missing runtime flag '$field'."
        }
    }
    if ([bool]$RuntimeFlags.a2a_message_sent) { throw "$Context claims A2A message sent." }
    if ([bool]$RuntimeFlags.live_a2a_runtime_implemented) { throw "$Context claims live A2A runtime." }
    if ([bool]$RuntimeFlags.live_agent_runtime_invoked) { throw "$Context claims live agent runtime." }
    if ([bool]$RuntimeFlags.live_skill_execution_performed) { throw "$Context claims live skill execution." }
    if ([bool]$RuntimeFlags.live_recovery_runtime_implemented) { throw "$Context claims live recovery runtime." }
    if ([bool]$RuntimeFlags.local_runner_runtime_implemented) { throw "$Context claims local runner runtime." }
    if ([bool]$RuntimeFlags.openai_api_invoked) { throw "$Context claims OpenAI API invocation." }
    if ([bool]$RuntimeFlags.codex_api_invoked) { throw "$Context claims Codex API invocation." }
    if ([bool]$RuntimeFlags.autonomous_codex_invocation_performed) { throw "$Context claims autonomous Codex invocation." }
    if ([bool]$RuntimeFlags.automatic_new_thread_creation_performed) { throw "$Context claims automatic new-thread creation." }
    if ([bool]$RuntimeFlags.product_runtime_executed) { throw "$Context claims product runtime." }
    if ([bool]$RuntimeFlags.no_manual_prompt_transfer_success_claimed) { throw "$Context claims no-manual-prompt-transfer success." }
    if ([bool]$RuntimeFlags.solved_codex_compaction_claimed) { throw "$Context claims solved Codex compaction." }
    if ([bool]$RuntimeFlags.solved_codex_reliability_claimed) { throw "$Context claims solved Codex reliability." }
    if ([bool]$RuntimeFlags.r18_005_completed) { throw "$Context claims R18-005 or later completion." }
    if ([bool]$RuntimeFlags.main_merge_claimed) { throw "$Context claims main merge." }
}

function Assert-R18HandoffPacket {
    param(
        [Parameter(Mandatory = $true)][object]$Handoff,
        [Parameter(Mandatory = $true)][hashtable]$AgentCards,
        [Parameter(Mandatory = $true)][hashtable]$SkillRegistry
    )

    $context = if ($null -ne $Handoff.PSObject.Properties["handoff_id"]) { [string]$Handoff.handoff_id } else { "handoff packet" }
    Assert-R18HandoffRequiredFields -Object $Handoff -FieldNames $script:R18RequiredHandoffFields -Context $context
    Assert-R18HandoffCondition -Condition ($Handoff.artifact_type -eq "r18_a2a_handoff_packet") -Message "$($Handoff.handoff_id) artifact_type is invalid."
    Assert-R18HandoffCondition -Condition ($Handoff.contract_version -eq "v1") -Message "$($Handoff.handoff_id) contract_version is invalid."
    Assert-R18HandoffCondition -Condition ($Handoff.source_task -eq $script:R18SourceTask) -Message "$($Handoff.handoff_id) source_task must be R18-004."
    Assert-R18HandoffCondition -Condition ($Handoff.source_milestone -eq $script:R18SourceMilestone) -Message "$($Handoff.handoff_id) source_milestone is invalid."
    Assert-R18HandoffCondition -Condition ($Handoff.handoff_status -eq "packet_only_not_dispatched") -Message "$($Handoff.handoff_id) must be packet_only_not_dispatched."
    Assert-R18HandoffCondition -Condition ($script:R18RequiredHandoffFileMap.Contains([string]$Handoff.handoff_id)) -Message "Unexpected R18 handoff_id '$($Handoff.handoff_id)'."

    foreach ($valueContext in @("source_role", "target_role", "skill_ref")) {
        Assert-R18HandoffNoWildcardValue -Value ([string]$Handoff.$valueContext) -Context "$($Handoff.handoff_id) $valueContext"
    }

    Assert-R18HandoffCondition -Condition ($AgentCards.ContainsKey([string]$Handoff.source_agent_id)) -Message "$($Handoff.handoff_id) uses unknown source agent '$($Handoff.source_agent_id)'."
    Assert-R18HandoffCondition -Condition ($AgentCards.ContainsKey([string]$Handoff.target_agent_id)) -Message "$($Handoff.handoff_id) uses unknown target agent '$($Handoff.target_agent_id)'."
    $sourceCard = $AgentCards[[string]$Handoff.source_agent_id]
    $targetCard = $AgentCards[[string]$Handoff.target_agent_id]
    Assert-R18HandoffCondition -Condition ($Handoff.source_role -eq $sourceCard.role) -Message "$($Handoff.handoff_id) source_role does not match source agent card role."
    Assert-R18HandoffCondition -Condition ($Handoff.target_role -eq $targetCard.role) -Message "$($Handoff.handoff_id) target_role does not match target agent card role."
    Assert-R18HandoffCondition -Condition ($Handoff.card_id -eq $targetCard.card_id) -Message "$($Handoff.handoff_id) card_id must reference the target agent card."

    Assert-R18HandoffCondition -Condition ($SkillRegistry.ContainsKey([string]$Handoff.skill_ref)) -Message "$($Handoff.handoff_id) uses unknown skill_ref '$($Handoff.skill_ref)'."
    $skill = $SkillRegistry[[string]$Handoff.skill_ref]
    Assert-R18HandoffCondition -Condition (@($skill.allowed_roles) -contains [string]$Handoff.target_role) -Message "$($Handoff.handoff_id) target role '$($Handoff.target_role)' is not allowed for skill '$($Handoff.skill_ref)'."

    Assert-R18HandoffNonEmptyArray -Value $Handoff.required_input_refs -Context "$($Handoff.handoff_id) required_input_refs"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.expected_outputs -Context "$($Handoff.handoff_id) expected_outputs"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.memory_refs -Context "$($Handoff.handoff_id) memory_refs"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.evidence_refs -Context "$($Handoff.handoff_id) evidence_refs"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.authority_refs -Context "$($Handoff.handoff_id) authority_refs"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.next_allowed_actions -Context "$($Handoff.handoff_id) next_allowed_actions"
    foreach ($action in @($Handoff.next_allowed_actions)) {
        $actionText = [string]$action
        Assert-R18HandoffNoWildcardValue -Value $actionText -Context "$($Handoff.handoff_id) next_allowed_actions"
        if ($actionText -match '(?i)\bunbounded\b|\ball_actions\b|\bany_action\b') {
            throw "$($Handoff.handoff_id) contains unbounded next action '$actionText'."
        }
    }

    Assert-R18HandoffNonEmptyObject -Value $Handoff.current_state -Context "$($Handoff.handoff_id) current_state"
    Assert-R18HandoffRequiredFields -Object $Handoff.current_state -FieldNames $script:R18CurrentStateFields -Context "$($Handoff.handoff_id) current_state"
    Assert-R18HandoffNonEmptyObject -Value $Handoff.validation_expectations -Context "$($Handoff.handoff_id) validation_expectations"
    Assert-R18HandoffNonEmptyObject -Value $Handoff.receiving_role_validation -Context "$($Handoff.handoff_id) receiving_role_validation"
    Assert-R18HandoffRequiredFields -Object $Handoff.receiving_role_validation -FieldNames $script:R18ReceivingValidationFields -Context "$($Handoff.handoff_id) receiving_role_validation"
    foreach ($field in $script:R18ReceivingValidationFields) {
        if ([bool]$Handoff.receiving_role_validation.$field -ne $true) {
            throw "$($Handoff.handoff_id) receiving_role_validation.$field must be true."
        }
    }

    Assert-R18HandoffNonEmptyObject -Value $Handoff.retry_failover_policy -Context "$($Handoff.handoff_id) retry_failover_policy"
    Assert-R18HandoffRequiredFields -Object $Handoff.retry_failover_policy -FieldNames @("max_retry_count", "retry_count_source", "retry_limit_enforced", "unbounded_retry_allowed", "escalation_conditions", "failure_routing_target", "operator_decision_required_when") -Context "$($Handoff.handoff_id) retry_failover_policy"
    $maxRetry = [int]$Handoff.retry_failover_policy.max_retry_count
    if ($maxRetry -lt 0 -or $maxRetry -gt 3) {
        throw "$($Handoff.handoff_id) retry max is not bounded."
    }
    if ([bool]$Handoff.retry_failover_policy.retry_limit_enforced -ne $true) {
        throw "$($Handoff.handoff_id) retry limit must be enforced."
    }
    if ([bool]$Handoff.retry_failover_policy.unbounded_retry_allowed -ne $false) {
        throw "$($Handoff.handoff_id) permits unbounded retry."
    }
    Assert-R18HandoffNonEmptyArray -Value $Handoff.retry_failover_policy.escalation_conditions -Context "$($Handoff.handoff_id) escalation_conditions"

    Assert-R18HandoffNonEmptyObject -Value $Handoff.failure_routing -Context "$($Handoff.handoff_id) failure_routing"
    Assert-R18HandoffRequiredFields -Object $Handoff.failure_routing -FieldNames @("behavior", "failure_routing_target", "failure_packet_required", "failure_packet_requirements") -Context "$($Handoff.handoff_id) failure_routing"
    Assert-R18HandoffCondition -Condition ($script:R18AllowedFailureRouting -contains [string]$Handoff.failure_routing.behavior) -Message "$($Handoff.handoff_id) failure_routing behavior is invalid."
    Assert-R18HandoffCondition -Condition ([bool]$Handoff.failure_routing.failure_packet_required -eq $true) -Message "$($Handoff.handoff_id) failure packet must be required."

    Assert-R18HandoffNonEmptyObject -Value $Handoff.approval_requirements -Context "$($Handoff.handoff_id) approval_requirements"
    Assert-R18HandoffCondition -Condition ([bool]$Handoff.approval_requirements.qa_self_approval_allowed -eq $false) -Message "$($Handoff.handoff_id) permits QA/Test self-approval."
    Assert-R18HandoffCondition -Condition ([bool]$Handoff.approval_requirements.developer_codex_decision_authority -eq $false) -Message "$($Handoff.handoff_id) grants Developer/Codex decision authority."
    Assert-R18HandoffCondition -Condition ([bool]$Handoff.approval_requirements.release_manager_main_merge_without_operator_approval_allowed -eq $false) -Message "$($Handoff.handoff_id) permits release manager main merge without operator approval."

    Assert-R18HandoffNonEmptyArray -Value $Handoff.allowed_paths -Context "$($Handoff.handoff_id) allowed_paths"
    Assert-R18HandoffNonEmptyArray -Value $Handoff.forbidden_paths -Context "$($Handoff.handoff_id) forbidden_paths"
    Assert-R18HandoffNonEmptyObject -Value $Handoff.path_policy -Context "$($Handoff.handoff_id) path_policy"
    Assert-R18HandoffRequiredFields -Object $Handoff.path_policy -FieldNames @("broad_repo_writes_allowed", "operator_local_backup_paths_allowed", "historical_r13_r16_evidence_edits_allowed") -Context "$($Handoff.handoff_id) path_policy"
    if ([bool]$Handoff.path_policy.broad_repo_writes_allowed) { throw "$($Handoff.handoff_id) allows broad repo writes." }
    if ([bool]$Handoff.path_policy.operator_local_backup_paths_allowed) { throw "$($Handoff.handoff_id) allows operator-local backup paths." }
    if ([bool]$Handoff.path_policy.historical_r13_r16_evidence_edits_allowed) { throw "$($Handoff.handoff_id) allows historical R13/R14/R15/R16 evidence edits." }

    Assert-R18HandoffRuntimeClaims -RuntimeFlags $Handoff.runtime_flags -Context $Handoff.handoff_id

    if ($null -ne $Handoff.PSObject.Properties["positive_claims"]) {
        foreach ($claim in @($Handoff.positive_claims)) {
            if ($script:R18AllowedPositiveClaims -notcontains [string]$claim) {
                throw "$($Handoff.handoff_id) contains unsupported positive claim '$claim'."
            }
        }
    }

    Assert-R18HandoffNonEmptyArray -Value $Handoff.non_claims -Context "$($Handoff.handoff_id) non_claims"
    $nonClaimText = @($Handoff.non_claims) -join " "
    foreach ($required in @("R18-004 created A2A handoff packet schema", "not live A2A runtime", "No A2A messages were sent", "No live agents were invoked", "No live skills were executed", "No local runner runtime", "No recovery runtime", "No OpenAI API invocation", "No Codex API invocation", "R18-005 through R18-028 remain planned only", "Main is not merged")) {
        if ($nonClaimText -notmatch [regex]::Escape($required)) {
            throw "$($Handoff.handoff_id) non_claims must preserve '$required'."
        }
    }
    Assert-R18HandoffNonEmptyArray -Value $Handoff.rejected_claims -Context "$($Handoff.handoff_id) rejected_claims"

    if (($Handoff.source_role -eq "Developer/Codex" -or $Handoff.target_role -eq "Developer/Codex") -and $Handoff.skill_ref -eq "request_operator_approval") {
        throw "$($Handoff.handoff_id) lets Developer/Codex request operator approval as decision authority."
    }
    if (($Handoff.source_role -eq "Evidence Auditor" -or $Handoff.target_role -eq "Evidence Auditor") -and $Handoff.skill_ref -eq "generate_bounded_artifacts") {
        throw "$($Handoff.handoff_id) lets Evidence Auditor generate implementation artifacts."
    }
    if (($Handoff.source_role -eq "Orchestrator" -or $Handoff.target_role -eq "Orchestrator") -and $Handoff.skill_ref -eq "generate_bounded_artifacts") {
        throw "$($Handoff.handoff_id) lets Orchestrator directly implement artifacts."
    }
}

function Assert-R18HandoffContractArtifact {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18HandoffRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "scope", "purpose", "required_handoff_ids", "required_handoff_fields", "required_runtime_false_flags", "allowed_failure_routing", "allowed_positive_claims", "role_and_skill_validation_policy", "path_policy", "retry_policy", "evidence_refs", "authority_refs", "non_claims") -Context "handoff packet contract"
    Assert-R18HandoffCondition -Condition ($Contract.artifact_type -eq "r18_a2a_handoff_packet_contract") -Message "handoff packet contract artifact_type is invalid."
    foreach ($handoffId in @($script:R18RequiredHandoffFileMap.Keys)) {
        Assert-R18HandoffCondition -Condition (@($Contract.required_handoff_ids) -contains $handoffId) -Message "handoff packet contract missing required handoff '$handoffId'."
    }
    foreach ($field in $script:R18RequiredHandoffFields) {
        Assert-R18HandoffCondition -Condition (@($Contract.required_handoff_fields) -contains $field) -Message "handoff packet contract missing required field '$field'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18HandoffCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "handoff packet contract missing required runtime flag '$flag'."
    }
}

function Assert-R18HandoffRegistry {
    param([Parameter(Mandatory = $true)][object]$Registry)

    Assert-R18HandoffRequiredFields -Object $Registry -FieldNames @("artifact_type", "contract_version", "registry_id", "source_milestone", "source_task", "active_through_task", "handoff_status", "handoff_count", "handoffs", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "handoff registry"
    Assert-R18HandoffCondition -Condition ($Registry.artifact_type -eq "r18_handoff_registry") -Message "handoff registry artifact_type is invalid."
    Assert-R18HandoffCondition -Condition ($Registry.active_through_task -eq "R18-004") -Message "handoff registry active_through_task must be R18-004."
    Assert-R18HandoffCondition -Condition ([int]$Registry.handoff_count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "handoff registry handoff_count is invalid."
    foreach ($handoffId in @($script:R18RequiredHandoffFileMap.Keys)) {
        Assert-R18HandoffCondition -Condition (@($Registry.handoffs | Where-Object { $_.handoff_id -eq $handoffId }).Count -eq 1) -Message "handoff registry missing '$handoffId'."
    }
    Assert-R18HandoffRuntimeClaims -RuntimeFlags $Registry.runtime_flags -Context "handoff registry"
}

function Assert-R18HandoffCheckReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18HandoffRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_milestone", "source_task", "required_handoff_count", "generated_handoff_count", "handoff_ids", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "handoff check report"
    Assert-R18HandoffCondition -Condition ($Report.artifact_type -eq "r18_a2a_handoff_check_report") -Message "handoff check report artifact_type is invalid."
    Assert-R18HandoffCondition -Condition ($Report.aggregate_verdict -eq $script:R18HandoffVerdict) -Message "handoff check report aggregate verdict is invalid."
    Assert-R18HandoffCondition -Condition ([int]$Report.required_handoff_count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "handoff check report required_handoff_count is invalid."
    Assert-R18HandoffCondition -Condition ([int]$Report.generated_handoff_count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "handoff check report generated_handoff_count is invalid."
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "handoff check '$($check.Name)' must have status passed."
        }
    }
    Assert-R18HandoffRuntimeClaims -RuntimeFlags $Report.runtime_flags -Context "handoff check report"
}

function Assert-R18HandoffSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18HandoffRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_milestone", "source_task", "active_through_task", "ui_boundary_label", "required_handoff_count", "generated_handoff_count", "handoffs", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "handoff snapshot"
    Assert-R18HandoffCondition -Condition ($Snapshot.artifact_type -eq "r18_a2a_handoff_snapshot") -Message "handoff snapshot artifact_type is invalid."
    Assert-R18HandoffCondition -Condition ($Snapshot.active_through_task -eq "R18-004") -Message "handoff snapshot active_through_task must be R18-004."
    Assert-R18HandoffCondition -Condition ([int]$Snapshot.required_handoff_count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "handoff snapshot required_handoff_count is invalid."
    Assert-R18HandoffCondition -Condition ([int]$Snapshot.generated_handoff_count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "handoff snapshot generated_handoff_count is invalid."
    foreach ($handoff in @($Snapshot.handoffs)) {
        Assert-R18HandoffCondition -Condition ([bool]$handoff.runtime_enabled -eq $false) -Message "handoff snapshot '$($handoff.handoff_id)' runtime_enabled must be false."
        Assert-R18HandoffCondition -Condition ([bool]$handoff.a2a_message_sent -eq $false) -Message "handoff snapshot '$($handoff.handoff_id)' claims A2A message sent."
        Assert-R18HandoffCondition -Condition ([bool]$handoff.live_agent_runtime_invoked -eq $false) -Message "handoff snapshot '$($handoff.handoff_id)' claims live agent runtime."
        Assert-R18HandoffCondition -Condition ([bool]$handoff.live_skill_execution_performed -eq $false) -Message "handoff snapshot '$($handoff.handoff_id)' claims live skill execution."
    }
    Assert-R18HandoffRuntimeClaims -RuntimeFlags $Snapshot.runtime_summary -Context "handoff snapshot"
}

function Get-R18HandoffTaskStatusMap {
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

function Test-R18HandoffStatusTruth {
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18HandoffPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-015 only",
            "R18-016 through R18-028 planned only",
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
            "Main is not merged"
        )) {
        if ($combinedText -notlike "*$required*") {
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18HandoffTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18HandoffTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 15) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-015."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-015."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(01[6-9]|02[0-8])') {
        throw "Status surface claims R18 beyond R18-015."
    }
}

function Test-R18HandoffPacketSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object[]]$Handoffs,
        [Parameter(Mandatory = $true)][object]$Registry,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot)
    )

    $agentCards = Get-R18HandoffAgentCardIndex -RepositoryRoot $RepositoryRoot
    $skillRegistry = Get-R18HandoffSkillRegistryIndex -RepositoryRoot $RepositoryRoot
    Assert-R18HandoffContractArtifact -Contract $Contract
    Assert-R18HandoffCondition -Condition (@($Handoffs).Count -eq @($script:R18RequiredHandoffFileMap.Keys).Count) -Message "R18 handoff packet set is missing required seed handoffs."
    foreach ($handoff in @($Handoffs)) {
        Assert-R18HandoffPacket -Handoff $handoff -AgentCards $agentCards -SkillRegistry $skillRegistry
    }
    foreach ($handoffId in @($script:R18RequiredHandoffFileMap.Keys)) {
        Assert-R18HandoffCondition -Condition (@($Handoffs | Where-Object { $_.handoff_id -eq $handoffId }).Count -eq 1) -Message "R18 handoff packet set is missing required handoff '$handoffId'."
    }
    Assert-R18HandoffRegistry -Registry $Registry
    Assert-R18HandoffCheckReport -Report $Report
    Assert-R18HandoffSnapshot -Snapshot $Snapshot
    Test-R18HandoffStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredHandoffCount = [int]$Report.required_handoff_count
        GeneratedHandoffCount = [int]$Report.generated_handoff_count
        HandoffIds = @($Handoffs | ForEach-Object { $_.handoff_id })
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18HandoffPacketSchema {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $paths = Get-R18HandoffSchemaPaths -RepositoryRoot $RepositoryRoot
    $handoffs = foreach ($handoffId in @($script:R18RequiredHandoffFileMap.Keys)) {
        Read-R18HandoffJson -Path $paths.HandoffFiles[$handoffId]
    }

    return Test-R18HandoffPacketSet `
        -Contract (Read-R18HandoffJson -Path $paths.Contract) `
        -Handoffs @($handoffs) `
        -Registry (Read-R18HandoffJson -Path $paths.Registry) `
        -Report (Read-R18HandoffJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18HandoffJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18HandoffObjectPathValue {
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

function Remove-R18HandoffObjectPathValue {
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

function Invoke-R18HandoffMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18HandoffObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18HandoffObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

function New-R18HandoffSchemaArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18HandoffRepositoryRoot))

    $paths = Get-R18HandoffSchemaPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18HandoffContract
    $handoffs = Get-R18HandoffPackets
    $registry = New-R18HandoffRegistry -Handoffs $handoffs
    $report = New-R18HandoffCheckReport -Handoffs $handoffs
    $snapshot = New-R18HandoffSnapshot -Handoffs $handoffs

    Write-R18HandoffJson -Path $paths.Contract -Value $contract
    foreach ($handoff in @($handoffs)) {
        Write-R18HandoffJson -Path $paths.HandoffFiles[[string]$handoff.handoff_id] -Value $handoff
    }
    Write-R18HandoffJson -Path $paths.Registry -Value $registry
    Write-R18HandoffJson -Path $paths.CheckReport -Value $report
    Write-R18HandoffJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18HandoffFixtureDefinitions
    Write-R18HandoffJson -Path $paths.FixtureManifest -Value (New-R18HandoffFixtureManifest -FixtureDefinitions $fixtureDefinitions)
    foreach ($definition in @($fixtureDefinitions)) {
        Write-R18HandoffJson -Path (Join-Path $paths.FixtureRoot $definition.file) -Value $definition.fixture
    }

    Write-R18HandoffJson -Path $paths.EvidenceIndex -Value (New-R18HandoffEvidenceIndex)
    Write-R18HandoffText -Path $paths.ProofReview -Value (New-R18HandoffProofReviewText)
    Write-R18HandoffText -Path $paths.ValidationManifest -Value (New-R18HandoffValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        PacketRoot = $paths.PacketRoot
        Registry = $paths.Registry
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredHandoffCount = @($script:R18RequiredHandoffFileMap.Keys).Count
        GeneratedHandoffCount = @($handoffs).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

Export-ModuleMember -Function `
    Get-R18HandoffSchemaPaths, `
    New-R18HandoffSchemaArtifacts, `
    Test-R18HandoffPacketSchema, `
    Test-R18HandoffPacketSet, `
    Test-R18HandoffStatusTruth, `
    Invoke-R18HandoffMutation, `
    Copy-R18HandoffObject, `
    Get-R18HandoffAgentCardIndex, `
    Get-R18HandoffSkillRegistryIndex