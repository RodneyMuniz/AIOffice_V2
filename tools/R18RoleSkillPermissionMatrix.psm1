Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:R18SourceTask = "R18-005"
$script:R18SourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18MatrixVerdict = "generated_r18_role_skill_permission_matrix_foundation_only"
$script:R18GeneratedFromHead = "7e736cd79c387491540635716b7fac20cc1ff3f2"
$script:R18GeneratedFromTree = "f0e906323e525eb153ded033816bc45f4b8dc19b"

$script:R18RequiredRoles = @(
    "Orchestrator",
    "Project Manager",
    "Solution Architect",
    "Developer/Codex",
    "QA/Test",
    "Evidence Auditor",
    "Release Manager"
)

$script:R18AgentIdByRole = [ordered]@{
    "Orchestrator" = "agent_orchestrator"
    "Project Manager" = "agent_project_manager"
    "Solution Architect" = "agent_solution_architect"
    "Developer/Codex" = "agent_developer_codex"
    "QA/Test" = "agent_qa_test"
    "Evidence Auditor" = "agent_evidence_auditor"
    "Release Manager" = "agent_release_manager"
}

$script:R18RequiredSkills = @(
    "inspect_repo_refs",
    "define_work_order",
    "define_schema",
    "generate_bounded_artifacts",
    "run_validator",
    "classify_failure",
    "classify_wip",
    "verify_remote_branch",
    "generate_continuation_packet",
    "generate_new_context_prompt",
    "update_status_docs",
    "generate_evidence_package",
    "stage_commit_push_gate",
    "request_operator_approval"
)

$script:R18PermissionStatuses = @("allowed", "denied", "approval_required")
$script:R18DecisionAuthorities = @(
    "role_can_execute_contract_only",
    "role_can_request_only",
    "role_can_validate_only",
    "role_can_audit_only",
    "operator_approval_required",
    "denied"
)

$script:R18RuntimeFlagFields = @(
    "permission_runtime_enforced",
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
    "r18_006_completed",
    "main_merge_claimed"
)

$script:R18ApprovalGateRefs = @(
    "operator_approval_required_for_main_merge",
    "operator_approval_required_for_milestone_closeout",
    "operator_approval_required_for_external_audit_acceptance_claim",
    "operator_approval_required_for_api_enablement",
    "operator_approval_required_for_wip_abandonment",
    "operator_approval_required_for_remote_branch_conflict_resolution",
    "operator_approval_required_for_stage_commit_push_when_risky"
)

$script:R18AllowedPositiveClaims = @(
    "r18_role_skill_permission_matrix_contract_created",
    "r18_role_skill_permission_matrix_created",
    "r18_role_skill_permission_matrix_validator_created",
    "r18_role_skill_permission_matrix_fixtures_created",
    "r18_role_skill_permission_matrix_proof_review_created"
)

$script:R18RejectedClaims = @(
    "wildcard_role_permission",
    "wildcard_skill_permission",
    "all_skills_permission",
    "unbounded_permission",
    "approval_gate_bypass",
    "historical_evidence_edit",
    "operator_local_backup_path_use",
    "broad_repo_write",
    "permission_runtime_enforcement",
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
    "r18_006_or_later_completion",
    "main_merge"
)

$script:R18ForbiddenWildcards = @("*", "all", "any", "unbounded", "all skills", "all_skills")

$script:R18ContractFields = @(
    "artifact_type",
    "contract_version",
    "contract_id",
    "source_task",
    "source_milestone",
    "repository",
    "branch",
    "scope",
    "purpose",
    "required_roles",
    "required_skills",
    "required_matrix_fields",
    "required_runtime_false_flags",
    "permission_policy",
    "approval_policy",
    "role_boundary_policy",
    "path_policy",
    "api_policy",
    "evidence_policy",
    "retry_failure_policy",
    "allowed_positive_claims",
    "rejected_claims",
    "non_claims",
    "evidence_refs",
    "authority_refs"
)

$script:R18MatrixFields = @(
    "artifact_type",
    "contract_version",
    "matrix_id",
    "source_task",
    "source_milestone",
    "matrix_status",
    "roles",
    "skills",
    "permissions",
    "denied_permissions",
    "approval_required_permissions",
    "permission_policy",
    "decision_authority_rules",
    "role_boundary_rules",
    "evidence_obligations",
    "failure_behavior",
    "path_policy",
    "api_policy",
    "runtime_flags",
    "non_claims",
    "rejected_claims",
    "evidence_refs",
    "authority_refs"
)

$script:R18PermissionRowFields = @(
    "role",
    "agent_id",
    "skill_id",
    "permission_status",
    "permission_reason",
    "decision_authority",
    "required_inputs",
    "required_outputs",
    "evidence_obligations",
    "approval_gate_ref",
    "failure_behavior",
    "runtime_flags",
    "path_policy",
    "api_policy"
)

function Get-R18MatrixRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R18MatrixPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R18MatrixJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R18MatrixJson {
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

function Write-R18MatrixText {
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

function Copy-R18MatrixObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R18MatrixPaths {
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $fixtureRoot = "tests/fixtures/r18_role_skill_permission_matrix"
    $proofRoot = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_005_role_skill_permission_matrix"

    return [pscustomobject]@{
        Contract = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/skills/r18_role_skill_permission_matrix.contract.json"
        Matrix = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_role_skill_permission_matrix.json"
        CheckReport = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_role_skill_permission_matrix_check_report.json"
        UiSnapshot = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_role_skill_permission_matrix_snapshot.json"
        Module = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "tools/R18RoleSkillPermissionMatrix.psm1"
        Generator = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "tools/new_r18_role_skill_permission_matrix.ps1"
        Validator = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "tools/validate_r18_role_skill_permission_matrix.ps1"
        Test = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "tests/test_r18_role_skill_permission_matrix.ps1"
        FixtureRoot = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue $fixtureRoot
        FixtureManifest = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $fixtureRoot "fixture_manifest.json")
        ProofRoot = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue $proofRoot
        EvidenceIndex = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "evidence_index.json")
        ProofReview = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "proof_review.md")
        ValidationManifest = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue (Join-Path $proofRoot "validation_manifest.md")
        AgentCardRoot = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "state/agents/r18_agent_cards"
        SkillRegistry = Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "state/skills/r18_skill_registry.json"
    }
}

function Get-R18MatrixEvidenceRefs {
    return @(
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "state/skills/r18_role_skill_permission_matrix_check_report.json",
        "state/ui/r18_operator_surface/r18_role_skill_permission_matrix_snapshot.json",
        "tools/R18RoleSkillPermissionMatrix.psm1",
        "tools/new_r18_role_skill_permission_matrix.ps1",
        "tools/validate_r18_role_skill_permission_matrix.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1",
        "tests/fixtures/r18_role_skill_permission_matrix/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_005_role_skill_permission_matrix/"
    )
}

function Get-R18MatrixAuthorityRefs {
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
        "contracts/a2a/r18_a2a_handoff_packet.contract.json",
        "state/a2a/r18_handoff_packets/",
        "state/a2a/r18_handoff_registry.json",
        "state/a2a/r18_a2a_handoff_check_report.json",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md"
    )
}

function Get-R18MatrixAllowedPaths {
    return @(
        "contracts/skills/r18_role_skill_permission_matrix.contract.json",
        "state/skills/r18_role_skill_permission_matrix.json",
        "state/skills/r18_role_skill_permission_matrix_check_report.json",
        "state/ui/r18_operator_surface/r18_role_skill_permission_matrix_snapshot.json",
        "tools/R18RoleSkillPermissionMatrix.psm1",
        "tools/new_r18_role_skill_permission_matrix.ps1",
        "tools/validate_r18_role_skill_permission_matrix.ps1",
        "tests/test_r18_role_skill_permission_matrix.ps1",
        "tests/fixtures/r18_role_skill_permission_matrix/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_005_role_skill_permission_matrix/",
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

function Get-R18MatrixForbiddenPaths {
    return @(
        ".local_backups/",
        "operator-local backup paths",
        "state/proof_reviews/r13_*",
        "state/proof_reviews/r14_*",
        "state/proof_reviews/r15_*",
        "state/proof_reviews/r16_*",
        "state/external_runs/",
        "repository root broad write",
        "unbounded wildcard write paths"
    )
}

function Get-R18MatrixRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18RuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function New-R18MatrixPathPolicy {
    return [ordered]@{
        allowed_paths = Get-R18MatrixAllowedPaths
        forbidden_paths = Get-R18MatrixForbiddenPaths
        allowed_paths_must_be_exact_or_task_scoped = $true
        broad_repo_writes_allowed = $false
        operator_local_backup_paths_allowed = $false
        historical_r13_r16_evidence_edits_allowed = $false
    }
}

function New-R18MatrixApiPolicy {
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

function New-R18MatrixFailureBehavior {
    param([string]$Behavior = "fail_closed_and_block_permission")

    return [ordered]@{
        behavior = $Behavior
        fail_closed = $true
        failure_packet_required = $true
        retry_without_repair_allowed = $false
        bypass_allowed = $false
    }
}

function Get-R18MatrixNonClaims {
    return @(
        "R18-005 created role-to-skill permission matrix only.",
        "Permission matrix is a governance/control artifact only; it is not runtime enforcement.",
        "R18-002 created agent card schema and seed cards only.",
        "Agent cards are not live agents.",
        "R18-003 created skill contract schema and seed skill contracts only.",
        "Skill contracts are not live skill execution.",
        "R18-004 created A2A handoff packet schema and seed handoff packets only.",
        "A2A handoff packets are not live A2A runtime.",
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
        "R18-006 through R18-028 remain planned only.",
        "Main is not merged."
    )
}

function New-R18MatrixPermissionPolicy {
    return [ordered]@{
        finite_role_skill_grid_required = $true
        wildcard_role_permissions_allowed = $false
        wildcard_skill_permissions_allowed = $false
        all_skills_permission_allowed = $false
        unbounded_permission_allowed = $false
        approval_gate_bypass_allowed = $false
        permissions_are_contract_only = $true
        runtime_enforcement_implemented = $false
    }
}

function New-R18MatrixRoleBoundaryRules {
    return @(
        "Orchestrator coordinates and routes only; it cannot implement artifacts, bypass QA/audit/release/operator approval, or claim autonomous execution.",
        "Project Manager defines scope and acceptance only; it cannot implement, QA self-approve, audit self-approve, or release.",
        "Solution Architect defines design, schema, and constraints only; it cannot approve its own design as QA or audit.",
        "Developer/Codex implements bounded artifacts only after valid work order, authority refs, allowed paths, and validators exist; it cannot approve its own work as QA or audit.",
        "QA/Test validates, creates defect/failure packets, and routes repair; it cannot self-approve fixes or close audit.",
        "Evidence Auditor reviews committed evidence, validators, non-claims, and overclaims; it cannot create implementation evidence or fabricate runtime proof.",
        "Release Manager controls stage/commit/push gates and status synchronization; it cannot merge main, close out, or claim external audit acceptance without explicit operator approval and evidence."
    )
}

function Get-R18MatrixRoleBoundary {
    param([Parameter(Mandatory = $true)][string]$Role)

    switch ($Role) {
        "Orchestrator" { return "Orchestrator coordinates and routes only; it cannot implement artifacts, bypass QA/audit/release/operator approval, or claim autonomous execution." }
        "Project Manager" { return "Project Manager defines scope and acceptance only; it cannot implement, QA self-approve, audit self-approve, or release." }
        "Solution Architect" { return "Solution Architect defines design, schema, and constraints only; it cannot approve its own design as QA or audit." }
        "Developer/Codex" { return "Developer/Codex implements bounded artifacts only after valid work order, authority refs, allowed paths, and validators exist; it cannot approve its own work as QA or audit." }
        "QA/Test" { return "QA/Test validates, creates defect/failure packets, and routes repair; it cannot self-approve fixes or close audit." }
        "Evidence Auditor" { return "Evidence Auditor reviews committed evidence, validators, non-claims, and overclaims; it cannot create implementation evidence or fabricate runtime proof." }
        "Release Manager" { return "Release Manager controls stage/commit/push gates and status synchronization; it cannot merge main, close out, or claim external audit acceptance without explicit operator approval and evidence." }
        default { throw "Unknown role boundary '$Role'." }
    }
}

function New-R18MatrixRoleRules {
    return [ordered]@{
        "Orchestrator" = [ordered]@{
            allowed = @("inspect_repo_refs", "define_work_order", "classify_failure", "classify_wip", "verify_remote_branch", "generate_continuation_packet", "generate_new_context_prompt", "request_operator_approval")
            approval_required = @{}
        }
        "Project Manager" = [ordered]@{
            allowed = @("inspect_repo_refs", "define_work_order", "request_operator_approval")
            approval_required = @{ "update_status_docs" = "operator_approval_required_for_milestone_closeout" }
        }
        "Solution Architect" = [ordered]@{
            allowed = @("inspect_repo_refs", "define_work_order", "define_schema")
            approval_required = @{}
        }
        "Developer/Codex" = [ordered]@{
            allowed = @("inspect_repo_refs", "define_schema", "generate_bounded_artifacts", "run_validator", "classify_wip")
            approval_required = @{}
        }
        "QA/Test" = [ordered]@{
            allowed = @("inspect_repo_refs", "run_validator", "classify_failure", "classify_wip")
            approval_required = @{}
        }
        "Evidence Auditor" = [ordered]@{
            allowed = @("inspect_repo_refs", "run_validator", "classify_failure", "verify_remote_branch", "generate_evidence_package", "request_operator_approval")
            approval_required = @{}
        }
        "Release Manager" = [ordered]@{
            allowed = @("inspect_repo_refs", "run_validator", "classify_wip", "verify_remote_branch", "generate_evidence_package", "request_operator_approval")
            approval_required = @{
                "update_status_docs" = "operator_approval_required_for_milestone_closeout"
                "stage_commit_push_gate" = "operator_approval_required_for_stage_commit_push_when_risky"
            }
        }
    }
}

function Get-R18MatrixDecisionAuthority {
    param(
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$SkillId,
        [Parameter(Mandatory = $true)][string]$PermissionStatus
    )

    if ($PermissionStatus -eq "denied") {
        return "denied"
    }
    if ($PermissionStatus -eq "approval_required") {
        return "operator_approval_required"
    }
    if ($SkillId -eq "request_operator_approval") {
        return "role_can_request_only"
    }
    if ($SkillId -eq "run_validator") {
        if ($Role -eq "Evidence Auditor") {
            return "role_can_audit_only"
        }
        return "role_can_validate_only"
    }
    if ($SkillId -eq "generate_evidence_package" -and $Role -eq "Evidence Auditor") {
        return "role_can_audit_only"
    }
    if ($Role -eq "Orchestrator" -and $SkillId -in @("define_work_order", "generate_continuation_packet", "generate_new_context_prompt")) {
        return "role_can_request_only"
    }

    return "role_can_execute_contract_only"
}

function Get-R18MatrixPermissionReason {
    param(
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$SkillId,
        [Parameter(Mandatory = $true)][string]$PermissionStatus
    )

    if ($PermissionStatus -eq "allowed") {
        switch ($Role) {
            "Orchestrator" { return "Allowed for coordination, routing, classification, continuation packet preparation, and operator-approval request contracts only." }
            "Project Manager" { return "Allowed for scope, work-order, and approval-request governance contracts only." }
            "Solution Architect" { return "Allowed for schema, design, and work-order constraint contracts only." }
            "Developer/Codex" { return "Allowed for bounded implementation or implementation self-check contracts only; not QA, audit, release, or runtime authority." }
            "QA/Test" { return "Allowed for validation, defect classification, and WIP classification contracts only." }
            "Evidence Auditor" { return "Allowed for audit verification, evidence packaging, branch verification, and audit escalation contracts only." }
            "Release Manager" { return "Allowed for release-gate verification, evidence packaging, status synchronization, and approval request contracts only." }
        }
    }

    if ($PermissionStatus -eq "approval_required") {
        return "Approval required because this role/skill pairing can change milestone posture, closeout posture, push posture, or risky release state."
    }

    if ($SkillId -eq "generate_bounded_artifacts" -and $Role -in @("Orchestrator", "Project Manager", "QA/Test", "Evidence Auditor", "Release Manager")) {
        return "$Role cannot generate implementation artifacts under R18-005 matrix policy."
    }
    if ($Role -eq "Developer/Codex" -and $SkillId -eq "request_operator_approval") {
        return "Developer/Codex cannot request operator approval as decision authority."
    }
    if ($Role -eq "QA/Test" -and $SkillId -eq "generate_bounded_artifacts") {
        return "QA/Test cannot self-approve fixes or perform repair implementation in R18-005."
    }
    if ($Role -eq "Release Manager" -and $SkillId -in @("define_schema", "generate_bounded_artifacts", "generate_continuation_packet", "generate_new_context_prompt")) {
        return "Release Manager cannot own design, implementation, continuation, or new-context prompt generation."
    }

    return "$Role is denied $SkillId by explicit R18-005 role boundary policy."
}

function New-R18MatrixPermissionRow {
    param(
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$SkillId
    )

    $rules = New-R18MatrixRoleRules
    $roleRules = $rules[$Role]
    $permissionStatus = "denied"
    $approvalGateRef = "denied_no_approval_gate_bypass"
    if (@($roleRules.allowed) -contains $SkillId) {
        $permissionStatus = "allowed"
        $approvalGateRef = "not_required_contract_only"
    }
    if ($roleRules.approval_required.Contains($SkillId)) {
        $permissionStatus = "approval_required"
        $approvalGateRef = [string]$roleRules.approval_required[$SkillId]
    }

    $requiredInputs = @("authority_refs", "role_skill_permission_matrix_ref", "valid_work_order_or_validation_context_ref")
    if ($permissionStatus -eq "approval_required") {
        $requiredInputs += "operator_approval_packet_ref"
    }

    $requiredOutputs = if ($permissionStatus -eq "denied") {
        @("denial_record", "failure_packet_when_requested")
    }
    elseif ($permissionStatus -eq "approval_required") {
        @("approval_gate_record", "evidence_ref_update_after_operator_decision")
    }
    else {
        @("contract_only_output_ref", "evidence_ref")
    }

    $evidenceObligations = @(
        "permission_row_id_recorded",
        "authority_refs_recorded",
        "runtime_false_flags_recorded",
        "non_claims_preserved"
    )
    if ($permissionStatus -eq "approval_required") {
        $evidenceObligations += "operator_approval_ref_required_before_action"
    }
    if ($permissionStatus -eq "denied") {
        $evidenceObligations += "denial_reason_recorded"
    }

    $permissionId = ("{0}__{1}" -f ($Role.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim("_"), $SkillId)

    return [ordered]@{
        permission_id = $permissionId
        role = $Role
        agent_id = $script:R18AgentIdByRole[$Role]
        skill_id = $SkillId
        permission_status = $permissionStatus
        permission_reason = Get-R18MatrixPermissionReason -Role $Role -SkillId $SkillId -PermissionStatus $permissionStatus
        decision_authority = Get-R18MatrixDecisionAuthority -Role $Role -SkillId $SkillId -PermissionStatus $permissionStatus
        required_inputs = $requiredInputs
        required_outputs = $requiredOutputs
        evidence_obligations = $evidenceObligations
        approval_gate_ref = $approvalGateRef
        failure_behavior = New-R18MatrixFailureBehavior
        runtime_flags = Get-R18MatrixRuntimeFlags
        path_policy = New-R18MatrixPathPolicy
        api_policy = New-R18MatrixApiPolicy
    }
}

function New-R18MatrixPermissions {
    $permissions = @()
    foreach ($role in $script:R18RequiredRoles) {
        foreach ($skillId in $script:R18RequiredSkills) {
            $permissions += New-R18MatrixPermissionRow -Role $role -SkillId $skillId
        }
    }
    return @($permissions)
}

function New-R18MatrixContract {
    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-005-role-skill-permission-matrix-contract-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        scope = "role_to_skill_permission_matrix_governance_control_contract_only_not_runtime_enforcement"
        purpose = "Define a machine-checkable R18 role-to-skill permission matrix binding each role to approved skills, denied skills, approval requirements, evidence obligations, runtime false flags, and fail-closed constraints."
        required_roles = $script:R18RequiredRoles
        required_skills = $script:R18RequiredSkills
        required_matrix_fields = $script:R18MatrixFields
        required_permission_row_fields = $script:R18PermissionRowFields
        required_runtime_false_flags = $script:R18RuntimeFlagFields
        permission_policy = New-R18MatrixPermissionPolicy
        approval_policy = [ordered]@{
            approval_gates = $script:R18ApprovalGateRefs
            approval_gates_are_contract_refs_only = $true
            live_approval_runtime_implemented = $false
            missing_required_approval_fails_closed = $true
            approval_bypass_allowed = $false
        }
        role_boundary_policy = [ordered]@{
            rules = New-R18MatrixRoleBoundaryRules
            qa_self_approval_allowed = $false
            audit_self_approval_allowed = $false
            release_manager_main_merge_without_operator_approval_allowed = $false
            developer_codex_operator_approval_decision_authority_allowed = $false
        }
        path_policy = New-R18MatrixPathPolicy
        api_policy = New-R18MatrixApiPolicy
        evidence_policy = [ordered]@{
            evidence_obligations_required_on_every_permission = $true
            runtime_false_flags_required_on_every_permission = $true
            fabricated_runtime_proof_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
        }
        retry_failure_policy = [ordered]@{
            failure_behavior_required_on_every_permission = $true
            fail_closed_on_missing_matrix_entry = $true
            fail_closed_on_unknown_role_or_skill = $true
            unbounded_retry_allowed = $false
            maximum_retry_count_before_operator_decision = 3
        }
        allowed_positive_claims = $script:R18AllowedPositiveClaims
        rejected_claims = $script:R18RejectedClaims
        non_claims = Get-R18MatrixNonClaims
        evidence_refs = Get-R18MatrixEvidenceRefs
        authority_refs = Get-R18MatrixAuthorityRefs
    }
}

function New-R18MatrixArtifact {
    $permissions = New-R18MatrixPermissions
    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix"
        contract_version = "v1"
        matrix_id = "aioffice-r18-005-role-skill-permission-matrix-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_head = $script:R18GeneratedFromHead
        generated_from_tree = $script:R18GeneratedFromTree
        matrix_status = "matrix_only_not_runtime_enforced"
        roles = @($script:R18RequiredRoles | ForEach-Object {
                [ordered]@{
                    role = $_
                    agent_id = $script:R18AgentIdByRole[$_]
                    card_ref = ("state/agents/r18_agent_cards/{0}.card.json" -f $script:R18AgentIdByRole[$_])
                    boundary = Get-R18MatrixRoleBoundary -Role $_
                }
            })
        skills = @($script:R18RequiredSkills | ForEach-Object {
                [ordered]@{
                    skill_id = $_
                    registry_ref = "state/skills/r18_skill_registry.json"
                    contract_status = "contract_only_not_executed"
                }
            })
        permissions = $permissions
        denied_permissions = @($permissions | Where-Object { $_.permission_status -eq "denied" } | ForEach-Object { $_.permission_id })
        approval_required_permissions = @($permissions | Where-Object { $_.permission_status -eq "approval_required" } | ForEach-Object { $_.permission_id })
        permission_policy = New-R18MatrixPermissionPolicy
        approval_gate_refs = $script:R18ApprovalGateRefs
        decision_authority_rules = [ordered]@{
            allowed_values = $script:R18DecisionAuthorities
            developer_codex_operator_approval_decision_authority_allowed = $false
            qa_test_self_approve_fix_allowed = $false
            evidence_auditor_implementation_artifact_generation_allowed = $false
            release_manager_main_merge_without_operator_approval_allowed = $false
        }
        role_boundary_rules = New-R18MatrixRoleBoundaryRules
        evidence_obligations = [ordered]@{
            every_permission_requires_evidence_obligations = $true
            minimum_evidence_obligations = @("permission_row_id_recorded", "authority_refs_recorded", "runtime_false_flags_recorded", "non_claims_preserved")
            denied_permissions_require_denial_reason = $true
            approval_required_permissions_require_operator_approval_ref = $true
        }
        failure_behavior = New-R18MatrixFailureBehavior
        path_policy = New-R18MatrixPathPolicy
        api_policy = New-R18MatrixApiPolicy
        runtime_flags = Get-R18MatrixRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18MatrixNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18MatrixEvidenceRefs
        authority_refs = Get-R18MatrixAuthorityRefs
    }
}

function New-R18MatrixCheckReport {
    param([Parameter(Mandatory = $true)][object]$Matrix)

    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix_check_report"
        contract_version = "v1"
        report_id = "aioffice-r18-005-role-skill-permission-matrix-check-report-v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        required_role_count = @($script:R18RequiredRoles).Count
        required_skill_count = @($script:R18RequiredSkills).Count
        permission_count = @($Matrix.permissions).Count
        allowed_permission_count = @($Matrix.permissions | Where-Object { $_.permission_status -eq "allowed" }).Count
        denied_permission_count = @($Matrix.permissions | Where-Object { $_.permission_status -eq "denied" }).Count
        approval_required_permission_count = @($Matrix.permissions | Where-Object { $_.permission_status -eq "approval_required" }).Count
        checks = [ordered]@{
            required_roles_present = @{ status = "passed" }
            required_skills_present = @{ status = "passed" }
            role_agent_card_mapping = @{ status = "passed" }
            skill_registry_mapping = @{ status = "passed" }
            finite_permission_grid = @{ status = "passed" }
            denied_unsafe_combinations_present = @{ status = "passed" }
            approval_gates_present = @{ status = "passed" }
            evidence_obligations_present = @{ status = "passed" }
            failure_behavior_present = @{ status = "passed" }
            runtime_false_flags_preserved = @{ status = "passed" }
            api_flags_disabled = @{ status = "passed" }
            status_surface_active_through_r18_005_only = @{ status = "passed" }
        }
        aggregate_verdict = $script:R18MatrixVerdict
        runtime_flags = Get-R18MatrixRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18MatrixNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18MatrixEvidenceRefs
        authority_refs = Get-R18MatrixAuthorityRefs
    }
}

function New-R18MatrixSnapshot {
    param([Parameter(Mandatory = $true)][object]$Matrix)

    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix_snapshot"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        active_through_task = "R18-005"
        ui_boundary_label = "Role-to-skill permission matrix only; not runtime enforcement"
        matrix_status = $Matrix.matrix_status
        role_count = @($Matrix.roles).Count
        skill_count = @($Matrix.skills).Count
        permission_count = @($Matrix.permissions).Count
        permission_summary = @($script:R18RequiredRoles | ForEach-Object {
                $role = $_
                [ordered]@{
                    role = $role
                    agent_id = $script:R18AgentIdByRole[$role]
                    allowed = @($Matrix.permissions | Where-Object { $_.role -eq $role -and $_.permission_status -eq "allowed" } | ForEach-Object { $_.skill_id })
                    approval_required = @($Matrix.permissions | Where-Object { $_.role -eq $role -and $_.permission_status -eq "approval_required" } | ForEach-Object { $_.skill_id })
                    denied_count = @($Matrix.permissions | Where-Object { $_.role -eq $role -and $_.permission_status -eq "denied" }).Count
                }
            })
        approval_gate_refs = $script:R18ApprovalGateRefs
        runtime_summary = Get-R18MatrixRuntimeFlags
        positive_claims = $script:R18AllowedPositiveClaims
        non_claims = Get-R18MatrixNonClaims
        rejected_claims = $script:R18RejectedClaims
        evidence_refs = Get-R18MatrixEvidenceRefs
        authority_refs = Get-R18MatrixAuthorityRefs
    }
}

function New-R18MatrixEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix_evidence_index"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        evidence_refs = Get-R18MatrixEvidenceRefs
        authority_refs = Get-R18MatrixAuthorityRefs
        validation_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_role_skill_permission_matrix.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_role_skill_permission_matrix.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_role_skill_permission_matrix.ps1"
        )
        runtime_flags = Get-R18MatrixRuntimeFlags
        non_claims = Get-R18MatrixNonClaims
        rejected_claims = $script:R18RejectedClaims
    }
}

function New-R18MatrixProofReviewText {
    return @"
# R18-005 Role-to-Skill Permission Matrix Proof Review

## Scope
R18-005 creates a governance/control permission matrix only. It binds each R18 role from R18-002 agent cards to each governed skill from the R18-003 skill registry with allowed, denied, or approval-required status.

## Positive Claims
- r18_role_skill_permission_matrix_contract_created
- r18_role_skill_permission_matrix_created
- r18_role_skill_permission_matrix_validator_created
- r18_role_skill_permission_matrix_fixtures_created
- r18_role_skill_permission_matrix_proof_review_created

## Non-Claims
- Permission matrix is not runtime enforcement.
- No A2A messages were sent.
- No live agents were invoked.
- No live skills were executed.
- No A2A runtime, local runner runtime, or recovery runtime was implemented.
- No OpenAI API or Codex API invocation occurred.
- No automatic new-thread creation occurred.
- R18-006 through R18-028 remain planned only.
- Main is not merged.

## Validation Expectation
The focused validator and tests fail closed on unknown roles, unknown skills, wildcard or all-skills permissions, missing approval gates, missing evidence obligations, missing failure behavior, unsafe role escalation, API enablement, runtime claims, and R18-006 or later completion claims.
"@
}

function New-R18MatrixValidationManifestText {
    return @"
# R18-005 Validation Manifest

Expected validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_role_skill_permission_matrix.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_role_skill_permission_matrix.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_role_skill_permission_matrix.ps1

Expected status truth: R18 active through R18-006 only. R18-007 through R18-028 remain planned only.

The matrix is governance/control evidence only and is not runtime permission enforcement.
"@
}

function New-R18MatrixFixture {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureId,
        [Parameter(Mandatory = $true)][string]$Target,
        [hashtable]$SetValues = @{},
        [string[]]$RemovePaths = @(),
        [Parameter(Mandatory = $true)][string[]]$ExpectedFailureFragments
    )

    return [ordered]@{
        fixture_id = $FixtureId
        target = $Target
        set_values = $SetValues
        remove_paths = $RemovePaths
        expected_failure_fragments = $ExpectedFailureFragments
        fixture_status = "invalid_mutation_spec_only_not_runtime"
    }
}

function Get-R18MatrixFixtureDefinitions {
    return @(
        [ordered]@{ file = "invalid_missing_role.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_role" -Target "matrix" -SetValues @{ "roles" = @() } -ExpectedFailureFragments @("missing required role")) },
        [ordered]@{ file = "invalid_role_not_in_agent_cards.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_role_not_in_agent_cards" -Target "permission:Orchestrator:inspect_repo_refs" -SetValues @{ "role" = "Unknown Role" } -ExpectedFailureFragments @("unknown role")) },
        [ordered]@{ file = "invalid_missing_skill.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_skill" -Target "matrix" -SetValues @{ "skills" = @() } -ExpectedFailureFragments @("missing required skill")) },
        [ordered]@{ file = "invalid_skill_not_in_registry.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_skill_not_in_registry" -Target "permission:Orchestrator:inspect_repo_refs" -SetValues @{ "skill_id" = "unknown_skill" } -ExpectedFailureFragments @("unknown skill")) },
        [ordered]@{ file = "invalid_wildcard_role.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_wildcard_role" -Target "permission:Orchestrator:inspect_repo_refs" -SetValues @{ "role" = "*" } -ExpectedFailureFragments @("wildcard role")) },
        [ordered]@{ file = "invalid_wildcard_skill.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_wildcard_skill" -Target "permission:Orchestrator:inspect_repo_refs" -SetValues @{ "skill_id" = "*" } -ExpectedFailureFragments @("wildcard skill")) },
        [ordered]@{ file = "invalid_unbounded_permission.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_unbounded_permission" -Target "matrix" -SetValues @{ "permission_policy.unbounded_permission_allowed" = $true } -ExpectedFailureFragments @("unbounded permission")) },
        [ordered]@{ file = "invalid_missing_decision_authority.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_decision_authority" -Target "permission:Developer/Codex:generate_bounded_artifacts" -RemovePaths @("decision_authority") -ExpectedFailureFragments @("missing required field 'decision_authority'")) },
        [ordered]@{ file = "invalid_missing_approval_gate.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_approval_gate" -Target "permission:Release Manager:stage_commit_push_gate" -RemovePaths @("approval_gate_ref") -ExpectedFailureFragments @("missing required field 'approval_gate_ref'")) },
        [ordered]@{ file = "invalid_missing_evidence_obligations.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_evidence_obligations" -Target "permission:Developer/Codex:generate_bounded_artifacts" -RemovePaths @("evidence_obligations") -ExpectedFailureFragments @("missing required field 'evidence_obligations'")) },
        [ordered]@{ file = "invalid_missing_failure_behavior.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_missing_failure_behavior" -Target "permission:Developer/Codex:generate_bounded_artifacts" -RemovePaths @("failure_behavior") -ExpectedFailureFragments @("missing required field 'failure_behavior'")) },
        [ordered]@{ file = "invalid_orchestrator_implementation_skill.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_orchestrator_implementation_skill" -Target "permission:Orchestrator:generate_bounded_artifacts" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_execute_contract_only" } -ExpectedFailureFragments @("Orchestrator is allowed to implement artifacts")) },
        [ordered]@{ file = "invalid_project_manager_implementation_skill.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_project_manager_implementation_skill" -Target "permission:Project Manager:generate_bounded_artifacts" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_execute_contract_only" } -ExpectedFailureFragments @("Project Manager is allowed to implement artifacts")) },
        [ordered]@{ file = "invalid_evidence_auditor_implementation_skill.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_evidence_auditor_implementation_skill" -Target "permission:Evidence Auditor:generate_bounded_artifacts" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_execute_contract_only" } -ExpectedFailureFragments @("Evidence Auditor is allowed to generate implementation artifacts")) },
        [ordered]@{ file = "invalid_developer_codex_operator_approval_decision.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_developer_codex_operator_approval_decision" -Target "permission:Developer/Codex:request_operator_approval" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_request_only" } -ExpectedFailureFragments @("Developer/Codex is allowed to request operator approval")) },
        [ordered]@{ file = "invalid_qa_test_self_approve_fix.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_qa_test_self_approve_fix" -Target "permission:QA/Test:generate_bounded_artifacts" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_execute_contract_only" } -ExpectedFailureFragments @("QA/Test is allowed to self-approve fixes")) },
        [ordered]@{ file = "invalid_release_manager_main_merge_without_approval.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_release_manager_main_merge_without_approval" -Target "permission:Release Manager:stage_commit_push_gate" -SetValues @{ "permission_status" = "allowed"; "decision_authority" = "role_can_execute_contract_only"; "approval_gate_ref" = "not_required_contract_only" } -ExpectedFailureFragments @("Release Manager is allowed to claim main merge")) },
        [ordered]@{ file = "invalid_api_skill_enabled.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_api_skill_enabled" -Target "permission:Developer/Codex:generate_bounded_artifacts" -SetValues @{ "api_policy.api_enabled" = $true } -ExpectedFailureFragments @("enables API invocation")) },
        [ordered]@{ file = "invalid_live_permission_enforcement_claim.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_live_permission_enforcement_claim" -Target "matrix" -SetValues @{ "runtime_flags.permission_runtime_enforced" = $true } -ExpectedFailureFragments @("claims permission runtime enforcement")) },
        [ordered]@{ file = "invalid_live_agent_invocation_claim.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_live_agent_invocation_claim" -Target "permission:Developer/Codex:generate_bounded_artifacts" -SetValues @{ "runtime_flags.live_agent_runtime_invoked" = $true } -ExpectedFailureFragments @("claims live agent invocation")) },
        [ordered]@{ file = "invalid_skill_execution_claim.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_skill_execution_claim" -Target "permission:Developer/Codex:generate_bounded_artifacts" -SetValues @{ "runtime_flags.live_skill_execution_performed" = $true } -ExpectedFailureFragments @("claims live skill execution")) },
        [ordered]@{ file = "invalid_a2a_message_sent_claim.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_a2a_message_sent_claim" -Target "permission:Developer/Codex:generate_bounded_artifacts" -SetValues @{ "runtime_flags.a2a_message_sent" = $true } -ExpectedFailureFragments @("claims A2A message sent")) },
        [ordered]@{ file = "invalid_r18_006_completion_claim.json"; fixture = (New-R18MatrixFixture -FixtureId "invalid_r18_006_completion_claim" -Target "matrix" -SetValues @{ "runtime_flags.r18_006_completed" = $true } -ExpectedFailureFragments @("claims R18-006 or later completion")) }
    )
}

function New-R18MatrixFixtureManifest {
    param([Parameter(Mandatory = $true)][object[]]$FixtureDefinitions)

    return [ordered]@{
        artifact_type = "r18_role_skill_permission_matrix_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18SourceTask
        source_milestone = $script:R18SourceMilestone
        fixture_status = "invalid_mutation_specs_only_not_runtime"
        fixture_count = @($FixtureDefinitions).Count
        fixtures = @($FixtureDefinitions | ForEach-Object {
                [ordered]@{
                    file = $_.file
                    fixture_id = $_.fixture.fixture_id
                    expected_failure_fragments = $_.fixture.expected_failure_fragments
                }
            })
        non_claims = Get-R18MatrixNonClaims
    }
}

function Get-R18MatrixAgentCardIndex {
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $paths = Get-R18MatrixPaths -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $paths.AgentCardRoot -PathType Container)) {
        throw "R18-002 agent card root is missing."
    }

    $byRole = @{}
    foreach ($file in Get-ChildItem -LiteralPath $paths.AgentCardRoot -Filter "*.json") {
        $card = Read-R18MatrixJson -Path $file.FullName
        $byRole[[string]$card.role] = $card
    }
    return $byRole
}

function Get-R18MatrixSkillRegistryIndex {
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $paths = Get-R18MatrixPaths -RepositoryRoot $RepositoryRoot
    $registry = Read-R18MatrixJson -Path $paths.SkillRegistry
    $bySkill = @{}
    foreach ($skill in @($registry.skills)) {
        $bySkill[[string]$skill.skill_id] = $skill
    }
    return $bySkill
}

function Assert-R18MatrixCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R18MatrixRequiredFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if ($null -eq $Object.PSObject.Properties[$field] -or $null -eq $Object.PSObject.Properties[$field].Value) {
            throw "$Context missing required field '$field'."
        }
        $value = $Object.PSObject.Properties[$field].Value
        if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
            throw "$Context required field '$field' is blank."
        }
    }
}

function Assert-R18MatrixNonEmptyArray {
    param(
        [AllowNull()][object]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or @($Value).Count -eq 0) {
        throw "$Context must be a non-empty array."
    }
}

function Assert-R18MatrixRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18MatrixRequiredFields -Object $RuntimeFlags -FieldNames $script:R18RuntimeFlagFields -Context "$Context runtime_flags"
    foreach ($flag in $script:R18RuntimeFlagFields) {
        if ([bool]$RuntimeFlags.$flag -ne $false) {
            switch ($flag) {
                "permission_runtime_enforced" { throw "$Context claims permission runtime enforcement." }
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
                "r18_006_completed" { throw "$Context claims R18-006 or later completion." }
                "main_merge_claimed" { throw "$Context claims main merge." }
                default { throw "$Context runtime flag '$flag' must be false." }
            }
        }
    }
}

function Assert-R18MatrixPathPolicy {
    param(
        [Parameter(Mandatory = $true)][object]$PathPolicy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18MatrixRequiredFields -Object $PathPolicy -FieldNames @("allowed_paths_must_be_exact_or_task_scoped", "broad_repo_writes_allowed", "operator_local_backup_paths_allowed", "historical_r13_r16_evidence_edits_allowed") -Context "$Context path_policy"
    if ([bool]$PathPolicy.broad_repo_writes_allowed) { throw "$Context allows broad repo writes." }
    if ([bool]$PathPolicy.operator_local_backup_paths_allowed) { throw "$Context allows operator-local backup paths." }
    if ([bool]$PathPolicy.historical_r13_r16_evidence_edits_allowed) { throw "$Context allows historical R13/R14/R15/R16 evidence edits." }
    foreach ($path in @($PathPolicy.allowed_paths)) {
        $pathText = [string]$path
        if ($pathText -match '^\.local_backups' -or $pathText -match 'operator-local') {
            throw "$Context allows operator-local backup paths."
        }
        if ($pathText -match 'state/proof_reviews/r1[3-6]') {
            throw "$Context allows historical R13/R14/R15/R16 evidence edits."
        }
    }
}

function Assert-R18MatrixApiPolicy {
    param(
        [Parameter(Mandatory = $true)][object]$ApiPolicy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-R18MatrixRequiredFields -Object $ApiPolicy -FieldNames @("api_enabled", "openai_api_invocation_allowed", "codex_api_invocation_allowed", "autonomous_codex_invocation_allowed", "automatic_new_thread_creation_allowed") -Context "$Context api_policy"
    if ([bool]$ApiPolicy.api_enabled -or [bool]$ApiPolicy.openai_api_invocation_allowed -or [bool]$ApiPolicy.codex_api_invocation_allowed -or [bool]$ApiPolicy.autonomous_codex_invocation_allowed -or [bool]$ApiPolicy.automatic_new_thread_creation_allowed) {
        throw "$Context enables API invocation."
    }
}

function Assert-R18MatrixContract {
    param([Parameter(Mandatory = $true)][object]$Contract)

    Assert-R18MatrixRequiredFields -Object $Contract -FieldNames $script:R18ContractFields -Context "role-skill permission matrix contract"
    Assert-R18MatrixCondition -Condition ($Contract.artifact_type -eq "r18_role_skill_permission_matrix_contract") -Message "role-skill permission matrix contract artifact_type is invalid."
    Assert-R18MatrixCondition -Condition ($Contract.source_task -eq $script:R18SourceTask) -Message "role-skill permission matrix contract source_task must be R18-005."
    foreach ($role in $script:R18RequiredRoles) {
        Assert-R18MatrixCondition -Condition (@($Contract.required_roles) -contains $role) -Message "contract missing required role '$role'."
    }
    foreach ($skill in $script:R18RequiredSkills) {
        Assert-R18MatrixCondition -Condition (@($Contract.required_skills) -contains $skill) -Message "contract missing required skill '$skill'."
    }
    foreach ($field in $script:R18MatrixFields) {
        Assert-R18MatrixCondition -Condition (@($Contract.required_matrix_fields) -contains $field) -Message "contract missing required matrix field '$field'."
    }
    foreach ($flag in $script:R18RuntimeFlagFields) {
        Assert-R18MatrixCondition -Condition (@($Contract.required_runtime_false_flags) -contains $flag) -Message "contract missing required runtime flag '$flag'."
    }
    foreach ($gate in $script:R18ApprovalGateRefs) {
        Assert-R18MatrixCondition -Condition (@($Contract.approval_policy.approval_gates) -contains $gate) -Message "contract missing required approval gate '$gate'."
    }
    if ([bool]$Contract.permission_policy.wildcard_role_permissions_allowed) { throw "contract allows wildcard role permissions." }
    if ([bool]$Contract.permission_policy.wildcard_skill_permissions_allowed) { throw "contract allows wildcard skill permissions." }
    if ([bool]$Contract.permission_policy.all_skills_permission_allowed) { throw "contract allows all skills permission." }
    if ([bool]$Contract.permission_policy.unbounded_permission_allowed) { throw "contract allows unbounded permission." }
    if ([bool]$Contract.permission_policy.runtime_enforcement_implemented) { throw "contract claims permission runtime enforcement." }
    Assert-R18MatrixPathPolicy -PathPolicy $Contract.path_policy -Context "contract"
    Assert-R18MatrixApiPolicy -ApiPolicy $Contract.api_policy -Context "contract"
}

function Get-R18MatrixPermission {
    param(
        [Parameter(Mandatory = $true)][object]$Matrix,
        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$SkillId
    )

    return @($Matrix.permissions | Where-Object { [string]$_.role -eq $Role -and [string]$_.skill_id -eq $SkillId }) | Select-Object -First 1
}

function Assert-R18MatrixPermissionRow {
    param(
        [Parameter(Mandatory = $true)][object]$Permission,
        [Parameter(Mandatory = $true)][hashtable]$AgentCards,
        [Parameter(Mandatory = $true)][hashtable]$SkillRegistry
    )

    Assert-R18MatrixRequiredFields -Object $Permission -FieldNames $script:R18PermissionRowFields -Context "permission row"
    $role = [string]$Permission.role
    $skillId = [string]$Permission.skill_id
    if ($script:R18ForbiddenWildcards -contains $role.ToLowerInvariant()) { throw "permission row uses wildcard role." }
    if ($script:R18ForbiddenWildcards -contains $skillId.ToLowerInvariant()) { throw "permission row uses wildcard skill." }
    if (-not $AgentCards.ContainsKey($role)) { throw "permission row references unknown role '$role'." }
    if (-not $SkillRegistry.ContainsKey($skillId)) { throw "permission row references unknown skill '$skillId'." }
    if ([string]$Permission.agent_id -ne [string]$AgentCards[$role].agent_id) {
        throw "permission row for '$role' does not map to the R18-002 agent card."
    }
    if ($script:R18PermissionStatuses -notcontains [string]$Permission.permission_status) {
        throw "permission row '$role/$skillId' has invalid permission_status '$($Permission.permission_status)'."
    }
    if ($script:R18DecisionAuthorities -notcontains [string]$Permission.decision_authority) {
        throw "permission row '$role/$skillId' has invalid decision_authority '$($Permission.decision_authority)'."
    }
    if ([string]$Permission.permission_status -eq "denied" -and [string]$Permission.decision_authority -ne "denied") {
        throw "permission row '$role/$skillId' is denied but still carries decision authority."
    }
    Assert-R18MatrixNonEmptyArray -Value $Permission.required_inputs -Context "permission row '$role/$skillId' required_inputs"
    Assert-R18MatrixNonEmptyArray -Value $Permission.required_outputs -Context "permission row '$role/$skillId' required_outputs"
    Assert-R18MatrixNonEmptyArray -Value $Permission.evidence_obligations -Context "permission row '$role/$skillId' evidence_obligations"
    if ([string]::IsNullOrWhiteSpace([string]$Permission.approval_gate_ref)) {
        throw "permission row '$role/$skillId' missing approval gate."
    }
    if ([string]$Permission.permission_status -eq "approval_required" -and (@($script:R18ApprovalGateRefs) -notcontains [string]$Permission.approval_gate_ref)) {
        throw "permission row '$role/$skillId' references unknown approval gate '$($Permission.approval_gate_ref)'."
    }
    Assert-R18MatrixRequiredFields -Object $Permission.failure_behavior -FieldNames @("fail_closed", "failure_packet_required", "bypass_allowed") -Context "permission row '$role/$skillId' failure_behavior"
    if ([bool]$Permission.failure_behavior.fail_closed -ne $true -or [bool]$Permission.failure_behavior.failure_packet_required -ne $true -or [bool]$Permission.failure_behavior.bypass_allowed -ne $false) {
        throw "permission row '$role/$skillId' failure behavior is not fail-closed."
    }
    Assert-R18MatrixRuntimeFlags -RuntimeFlags $Permission.runtime_flags -Context "permission row '$role/$skillId'"
    Assert-R18MatrixPathPolicy -PathPolicy $Permission.path_policy -Context "permission row '$role/$skillId'"
    Assert-R18MatrixApiPolicy -ApiPolicy $Permission.api_policy -Context "permission row '$role/$skillId'"
}

function Assert-R18MatrixSpecificRoleRules {
    param([Parameter(Mandatory = $true)][object]$Matrix)

    if ((Get-R18MatrixPermission -Matrix $Matrix -Role "Orchestrator" -SkillId "generate_bounded_artifacts").permission_status -ne "denied") {
        throw "Orchestrator is allowed to implement artifacts."
    }
    if ((Get-R18MatrixPermission -Matrix $Matrix -Role "Project Manager" -SkillId "generate_bounded_artifacts").permission_status -ne "denied") {
        throw "Project Manager is allowed to implement artifacts."
    }
    if ((Get-R18MatrixPermission -Matrix $Matrix -Role "Evidence Auditor" -SkillId "generate_bounded_artifacts").permission_status -ne "denied") {
        throw "Evidence Auditor is allowed to generate implementation artifacts."
    }
    if ((Get-R18MatrixPermission -Matrix $Matrix -Role "Developer/Codex" -SkillId "request_operator_approval").permission_status -ne "denied") {
        throw "Developer/Codex is allowed to request operator approval as decision authority."
    }
    if ((Get-R18MatrixPermission -Matrix $Matrix -Role "QA/Test" -SkillId "generate_bounded_artifacts").permission_status -ne "denied") {
        throw "QA/Test is allowed to self-approve fixes."
    }
    $releaseGate = Get-R18MatrixPermission -Matrix $Matrix -Role "Release Manager" -SkillId "stage_commit_push_gate"
    if ($releaseGate.permission_status -ne "approval_required" -or $releaseGate.approval_gate_ref -ne "operator_approval_required_for_stage_commit_push_when_risky") {
        throw "Release Manager is allowed to claim main merge, closeout, or external audit acceptance without operator approval."
    }
    $releaseStatus = Get-R18MatrixPermission -Matrix $Matrix -Role "Release Manager" -SkillId "update_status_docs"
    if ($releaseStatus.permission_status -ne "approval_required") {
        throw "Release Manager status-doc closeout posture changes must require operator approval."
    }
    $pmStatus = Get-R18MatrixPermission -Matrix $Matrix -Role "Project Manager" -SkillId "update_status_docs"
    if ($pmStatus.permission_status -ne "approval_required") {
        throw "Project Manager status-doc acceptance or closeout posture changes must require operator approval."
    }
}

function Assert-R18MatrixArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Matrix,
        [Parameter(Mandatory = $true)][hashtable]$AgentCards,
        [Parameter(Mandatory = $true)][hashtable]$SkillRegistry
    )

    Assert-R18MatrixRequiredFields -Object $Matrix -FieldNames $script:R18MatrixFields -Context "role-skill permission matrix"
    Assert-R18MatrixCondition -Condition ($Matrix.artifact_type -eq "r18_role_skill_permission_matrix") -Message "role-skill permission matrix artifact_type is invalid."
    Assert-R18MatrixCondition -Condition ($Matrix.source_task -eq $script:R18SourceTask) -Message "role-skill permission matrix source_task must be R18-005."
    Assert-R18MatrixCondition -Condition ($Matrix.matrix_status -eq "matrix_only_not_runtime_enforced") -Message "role-skill permission matrix must remain matrix_only_not_runtime_enforced."

    foreach ($role in $script:R18RequiredRoles) {
        if (@($Matrix.roles | ForEach-Object { [string]$_.role }) -notcontains $role) {
            throw "matrix missing required role '$role'."
        }
    }
    foreach ($roleEntry in @($Matrix.roles)) {
        $role = [string]$roleEntry.role
        if ($script:R18ForbiddenWildcards -contains $role.ToLowerInvariant()) { throw "matrix uses wildcard role." }
        if (-not $AgentCards.ContainsKey($role)) { throw "matrix role '$role' does not map to R18-002 agent cards." }
        if ([string]$roleEntry.agent_id -ne [string]$AgentCards[$role].agent_id) { throw "matrix role '$role' agent_id does not match R18-002 agent card." }
    }

    foreach ($skill in $script:R18RequiredSkills) {
        if (@($Matrix.skills | ForEach-Object { [string]$_.skill_id }) -notcontains $skill) {
            throw "matrix missing required skill '$skill'."
        }
    }
    foreach ($skillEntry in @($Matrix.skills)) {
        $skillId = [string]$skillEntry.skill_id
        if ($script:R18ForbiddenWildcards -contains $skillId.ToLowerInvariant()) { throw "matrix uses wildcard skill." }
        if (-not $SkillRegistry.ContainsKey($skillId)) { throw "matrix skill '$skillId' does not map to R18-003 skill registry." }
    }

    if ([bool]$Matrix.permission_policy.unbounded_permission_allowed) { throw "matrix allows unbounded permission." }
    if ([bool]$Matrix.permission_policy.all_skills_permission_allowed) { throw "matrix allows all skills permission." }
    if ([bool]$Matrix.permission_policy.wildcard_role_permissions_allowed) { throw "matrix allows wildcard role permissions." }
    if ([bool]$Matrix.permission_policy.wildcard_skill_permissions_allowed) { throw "matrix allows wildcard skill permissions." }

    Assert-R18MatrixPathPolicy -PathPolicy $Matrix.path_policy -Context "matrix"
    Assert-R18MatrixApiPolicy -ApiPolicy $Matrix.api_policy -Context "matrix"
    Assert-R18MatrixRuntimeFlags -RuntimeFlags $Matrix.runtime_flags -Context "matrix"
    Assert-R18MatrixNonEmptyArray -Value $Matrix.denied_permissions -Context "matrix denied_permissions"
    Assert-R18MatrixNonEmptyArray -Value $Matrix.approval_required_permissions -Context "matrix approval_required_permissions"
    foreach ($gate in $script:R18ApprovalGateRefs) {
        Assert-R18MatrixCondition -Condition (@($Matrix.approval_gate_refs) -contains $gate) -Message "matrix missing required approval gate '$gate'."
    }

    foreach ($permission in @($Matrix.permissions)) {
        Assert-R18MatrixPermissionRow -Permission $permission -AgentCards $AgentCards -SkillRegistry $SkillRegistry
    }

    foreach ($role in $script:R18RequiredRoles) {
        foreach ($skill in $script:R18RequiredSkills) {
            $matches = @($Matrix.permissions | Where-Object { [string]$_.role -eq $role -and [string]$_.skill_id -eq $skill })
            if ($matches.Count -ne 1) {
                throw "matrix must contain exactly one permission row for '$role/$skill'."
            }
        }
    }

    Assert-R18MatrixSpecificRoleRules -Matrix $Matrix

    $nonClaimText = @($Matrix.non_claims) -join " "
    foreach ($required in @("R18-005 created role-to-skill permission matrix only", "not runtime enforcement", "No A2A messages were sent", "No live agents were invoked", "No live skills were executed", "No local runner runtime", "No recovery runtime", "No OpenAI API invocation", "No Codex API invocation", "R18-006 through R18-028 remain planned only", "Main is not merged")) {
        if ($nonClaimText -notmatch [regex]::Escape($required)) {
            throw "matrix non_claims must preserve '$required'."
        }
    }
}

function Assert-R18MatrixCheckReport {
    param([Parameter(Mandatory = $true)][object]$Report)

    Assert-R18MatrixRequiredFields -Object $Report -FieldNames @("artifact_type", "contract_version", "report_id", "source_task", "source_milestone", "required_role_count", "required_skill_count", "permission_count", "checks", "aggregate_verdict", "runtime_flags", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "role-skill permission matrix check report"
    Assert-R18MatrixCondition -Condition ($Report.artifact_type -eq "r18_role_skill_permission_matrix_check_report") -Message "check report artifact_type is invalid."
    Assert-R18MatrixCondition -Condition ($Report.aggregate_verdict -eq $script:R18MatrixVerdict) -Message "check report aggregate verdict is invalid."
    Assert-R18MatrixCondition -Condition ([int]$Report.required_role_count -eq @($script:R18RequiredRoles).Count) -Message "check report required_role_count is invalid."
    Assert-R18MatrixCondition -Condition ([int]$Report.required_skill_count -eq @($script:R18RequiredSkills).Count) -Message "check report required_skill_count is invalid."
    Assert-R18MatrixCondition -Condition ([int]$Report.permission_count -eq (@($script:R18RequiredRoles).Count * @($script:R18RequiredSkills).Count)) -Message "check report permission_count is invalid."
    foreach ($check in @($Report.checks.PSObject.Properties)) {
        if ($null -ne $check.Value.PSObject.Properties["status"] -and [string]$check.Value.status -ne "passed") {
            throw "check report '$($check.Name)' must have status passed."
        }
    }
    Assert-R18MatrixRuntimeFlags -RuntimeFlags $Report.runtime_flags -Context "check report"
}

function Assert-R18MatrixSnapshot {
    param([Parameter(Mandatory = $true)][object]$Snapshot)

    Assert-R18MatrixRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "contract_version", "source_task", "source_milestone", "active_through_task", "ui_boundary_label", "matrix_status", "role_count", "skill_count", "permission_count", "permission_summary", "approval_gate_refs", "runtime_summary", "positive_claims", "non_claims", "rejected_claims", "evidence_refs", "authority_refs") -Context "role-skill permission matrix snapshot"
    Assert-R18MatrixCondition -Condition ($Snapshot.artifact_type -eq "r18_role_skill_permission_matrix_snapshot") -Message "snapshot artifact_type is invalid."
    Assert-R18MatrixCondition -Condition ($Snapshot.active_through_task -eq "R18-005") -Message "snapshot active_through_task must be R18-005."
    Assert-R18MatrixCondition -Condition ($Snapshot.matrix_status -eq "matrix_only_not_runtime_enforced") -Message "snapshot matrix status is invalid."
    Assert-R18MatrixRuntimeFlags -RuntimeFlags $Snapshot.runtime_summary -Context "snapshot"
}

function Get-R18MatrixTaskStatusMap {
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

function Test-R18MatrixStatusTruth {
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18MatrixPath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-006 only",
            "R18-007 through R18-028 planned only",
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
            "No board/card runtime mutation occurred",
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
            throw "Status docs missing R18-005 truth: $required"
        }
    }

    $authorityStatuses = Get-R18MatrixTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18MatrixTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 6) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-006."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-006."
            }
        }
    }

    if ($combinedText -match 'R18 active through R18-(00[7-9]|0[1-2][0-9])') {
        throw "Status surface claims R18 beyond R18-006."
    }
}

function Test-R18RoleSkillPermissionMatrixSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$Matrix,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot)
    )

    $agentCards = Get-R18MatrixAgentCardIndex -RepositoryRoot $RepositoryRoot
    $skillRegistry = Get-R18MatrixSkillRegistryIndex -RepositoryRoot $RepositoryRoot
    Assert-R18MatrixContract -Contract $Contract
    Assert-R18MatrixArtifact -Matrix $Matrix -AgentCards $agentCards -SkillRegistry $skillRegistry
    Assert-R18MatrixCheckReport -Report $Report
    Assert-R18MatrixSnapshot -Snapshot $Snapshot
    Test-R18MatrixStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RequiredRoleCount = [int]$Report.required_role_count
        RequiredSkillCount = [int]$Report.required_skill_count
        PermissionCount = [int]$Report.permission_count
        AllowedPermissionCount = [int]$Report.allowed_permission_count
        DeniedPermissionCount = [int]$Report.denied_permission_count
        ApprovalRequiredPermissionCount = [int]$Report.approval_required_permission_count
        RuntimeFlags = $Report.runtime_flags
        PositiveClaims = @($Report.positive_claims)
    }
}

function Test-R18RoleSkillPermissionMatrix {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $paths = Get-R18MatrixPaths -RepositoryRoot $RepositoryRoot
    return Test-R18RoleSkillPermissionMatrixSet `
        -Contract (Read-R18MatrixJson -Path $paths.Contract) `
        -Matrix (Read-R18MatrixJson -Path $paths.Matrix) `
        -Report (Read-R18MatrixJson -Path $paths.CheckReport) `
        -Snapshot (Read-R18MatrixJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R18MatrixObjectPathValue {
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

function Remove-R18MatrixObjectPathValue {
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

function Invoke-R18MatrixMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if ($null -ne $Mutation.PSObject.Properties["remove_paths"] -and $null -ne $Mutation.remove_paths) {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R18MatrixObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ($null -ne $Mutation.PSObject.Properties["set_values"] -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R18MatrixObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

function New-R18RoleSkillPermissionMatrixArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18MatrixRepositoryRoot))

    $paths = Get-R18MatrixPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18MatrixContract
    $matrix = New-R18MatrixArtifact
    $report = New-R18MatrixCheckReport -Matrix $matrix
    $snapshot = New-R18MatrixSnapshot -Matrix $matrix

    Write-R18MatrixJson -Path $paths.Contract -Value $contract
    Write-R18MatrixJson -Path $paths.Matrix -Value $matrix
    Write-R18MatrixJson -Path $paths.CheckReport -Value $report
    Write-R18MatrixJson -Path $paths.UiSnapshot -Value $snapshot

    $fixtureDefinitions = Get-R18MatrixFixtureDefinitions
    Write-R18MatrixJson -Path $paths.FixtureManifest -Value (New-R18MatrixFixtureManifest -FixtureDefinitions $fixtureDefinitions)
    foreach ($definition in @($fixtureDefinitions)) {
        Write-R18MatrixJson -Path (Join-Path $paths.FixtureRoot $definition.file) -Value $definition.fixture
    }

    Write-R18MatrixJson -Path $paths.EvidenceIndex -Value (New-R18MatrixEvidenceIndex)
    Write-R18MatrixText -Path $paths.ProofReview -Value (New-R18MatrixProofReviewText)
    Write-R18MatrixText -Path $paths.ValidationManifest -Value (New-R18MatrixValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Matrix = $paths.Matrix
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RequiredRoleCount = @($script:R18RequiredRoles).Count
        RequiredSkillCount = @($script:R18RequiredSkills).Count
        PermissionCount = @($matrix.permissions).Count
        AggregateVerdict = $report.aggregate_verdict
    }
}

Export-ModuleMember -Function `
    Get-R18MatrixPaths, `
    New-R18RoleSkillPermissionMatrixArtifacts, `
    Test-R18RoleSkillPermissionMatrix, `
    Test-R18RoleSkillPermissionMatrixSet, `
    Test-R18MatrixStatusTruth, `
    Invoke-R18MatrixMutation, `
    Copy-R18MatrixObject, `
    Get-R18MatrixAgentCardIndex, `
    Get-R18MatrixSkillRegistryIndex
