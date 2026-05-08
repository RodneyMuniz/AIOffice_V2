Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-R17RepositoryRoot {
    return $repoRoot
}

function Resolve-R17Path {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$RepositoryRoot = (Get-R17RepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "$Label '$Path' is not valid JSON. $($_.Exception.Message)"
    }
}

function Write-R17JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = ($Value | ConvertTo-Json -Depth 100) + [Environment]::NewLine
    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $json, $encoding)
}

function Get-R17PropertyValue {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        throw "$Context missing required field '$Name'."
    }

    return $property.Value
}

function Assert-R17Equals {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Actual,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw $Message
    }
}

function Assert-R17True {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Actual,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Actual -ne $true) {
        throw $Message
    }
}

function Assert-R17False {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Actual,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Actual -ne $false) {
        throw $Message
    }
}

function Assert-R17ArrayContainsAll {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Actual,
        [Parameter(Mandatory = $true)]
        [string[]]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Actual) {
        throw "$Context is missing."
    }

    $actualValues = @($Actual)
    foreach ($expectedValue in $Expected) {
        if ($actualValues -notcontains $expectedValue) {
            throw "$Context missing required value '$expectedValue'."
        }
    }
}

function Get-R17RuleIds {
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$Rules,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Rules) {
        throw "$Context rules are missing."
    }

    return @($Rules | ForEach-Object {
            Get-R17PropertyValue -Object $_ -Name "rule_id" -Context $Context
        })
}

function Assert-R17FalseFields {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($fieldName in $FieldNames) {
        $value = Get-R17PropertyValue -Object $Object -Name $fieldName -Context $Context
        Assert-R17False -Actual $value -Message "$Context must set '$fieldName' to false."
    }
}

function Get-R17RequiredAllowedActions {
    return @(
        "read governed board state artifacts",
        "read governed card artifacts",
        "read memory refs when explicitly scoped",
        "read evidence refs",
        "propose card creation",
        "propose card routing",
        "propose next role",
        "propose user decision request",
        "propose stop/retry/re-entry requirement",
        "produce Orchestrator planning packets",
        "produce route recommendation packets",
        "produce non-executable handoff recommendations",
        "request user approval",
        "request QA gate",
        "request audit gate"
    )
}

function Get-R17RequiredForbiddenActions {
    return @(
        "implement code",
        "run tests",
        "approve evidence sufficiency",
        "bypass QA gate",
        "bypass audit gate",
        "close cards without user approval",
        "mutate live board state at runtime in R17-009",
        "invoke Developer/Codex runtime in R17-009",
        "invoke QA/Test Agent runtime in R17-009",
        "invoke Evidence Auditor API runtime in R17-009",
        "execute A2A runtime in R17-009",
        "call external APIs in R17-009",
        "claim autonomous-agent behavior",
        "claim product runtime",
        "claim executable handoffs",
        "claim executable transitions",
        "claim real Dev output",
        "claim real QA result",
        "claim real audit verdict",
        "claim solved Codex compaction",
        "claim solved Codex reliability",
        "claim external audit acceptance",
        "claim main merge",
        "claim R13 closure",
        "remove R14 caveats",
        "remove R15 caveats"
    )
}

function Get-R17RequiredRuntimeBoundaryFields {
    return @(
        "orchestrator_runtime_implemented",
        "live_board_mutation_implemented",
        "a2a_runtime_implemented",
        "dev_codex_adapter_runtime_implemented",
        "qa_test_agent_adapter_runtime_implemented",
        "evidence_auditor_api_runtime_implemented",
        "external_api_calls_implemented",
        "executable_handoffs_implemented",
        "executable_transitions_implemented",
        "autonomous_agents_implemented",
        "product_runtime_implemented",
        "production_runtime_implemented"
    )
}

function Get-R17RequiredNonClaims {
    return @(
        "R17-009 defines the Orchestrator identity and authority contract only",
        "R17-009 creates generated Orchestrator identity/authority state and non-executable route recommendation seed artifacts only",
        "R17-009 does not implement Orchestrator runtime",
        "R17-009 does not implement live board mutation",
        "R17-009 does not implement A2A runtime",
        "R17-009 does not implement Dev/Codex executor adapter",
        "R17-009 does not implement QA/Test Agent adapter",
        "R17-009 does not implement Evidence Auditor API adapter",
        "R17-009 does not call external APIs",
        "R17-009 does not call Codex as executor",
        "R17-009 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders",
        "R17-009 does not claim autonomous agents",
        "R17-009 does not claim product runtime",
        "R17-009 does not claim production runtime",
        "R17-009 does not claim executable handoffs or executable transitions",
        "R17-009 does not claim external audit acceptance",
        "R17-009 does not claim main merge",
        "R13 boundary preserved",
        "R14 caveats preserved",
        "R15 caveats preserved",
        "R16 boundary preserved",
        "R17-010 through R17-028 remain planned only",
        "R17-009 does not claim solved Codex compaction",
        "R17-009 does not claim solved Codex reliability"
    )
}

function Get-R17RequiredRejectedClaims {
    return @(
        "live_board_mutation",
        "Orchestrator_runtime",
        "A2A_runtime",
        "autonomous_agents",
        "Dev_Codex_executor_adapter_runtime",
        "QA_Test_Agent_adapter_runtime",
        "Evidence_Auditor_API_adapter_runtime",
        "external_API_calls",
        "executable_handoffs",
        "executable_transitions",
        "external_integrations",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "production_runtime",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability"
    )
}

function Test-R17OrchestratorIdentityObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Identity,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $Identity -Name "agent_id" -Context $Context) -Expected "orchestrator" -Message "$Context agent_id must be orchestrator."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $Identity -Name "role_name" -Context $Context) -Expected "Orchestrator" -Message "$Context role_name must be Orchestrator."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $Identity -Name "role_type" -Context $Context) -Expected "coordination_and_routing" -Message "$Context role_type must be coordination_and_routing."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $Identity -Name "accountable_to" -Context $Context) -Expected "user/operator" -Message "$Context accountable_to must be user/operator."

    Assert-R17FalseFields -Object $Identity -Context $Context -FieldNames @(
        "can_execute_code",
        "can_run_tests",
        "can_approve_evidence_sufficiency",
        "can_close_cards_without_user_approval",
        "can_call_external_apis_in_r17_009",
        "can_invoke_agents_in_r17_009",
        "can_mutate_live_board_in_r17_009",
        "can_delegate_runtime_work_in_r17_009"
    )
}

function Test-R17MemoryScopeRules {
    param(
        [Parameter(Mandatory = $true)]
        [object]$MemoryScopeRules,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-R17True -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "exact_ref_only" -Context $Context) -Message "$Context must require exact-ref-only memory scope."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "broad_repo_scan_allowed" -Context $Context) -Message "$Context must not allow broad repo scans."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "raw_chat_history_is_canonical" -Context $Context) -Message "$Context must not treat raw chat history as canonical."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "hidden_chat_memory_for_routing_allowed" -Context $Context) -Message "$Context must not rely on hidden chat memory for task routing."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "repo_truth_must_remain_canonical" -Context $Context) -Message "$Context must preserve repo truth as canonical."
    Assert-R17ArrayContainsAll -Actual (Get-R17PropertyValue -Object $MemoryScopeRules -Name "permitted_ref_classes" -Context $Context) -Expected @(
        "approved board state",
        "card state",
        "R17 authority",
        "KPI scorecard",
        "proof-review packages",
        "relevant memory/artifact refs"
    ) -Context "$Context permitted ref classes"
}

function Test-R17ToolPermissionRules {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ToolPermissionRules,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-R17True -Actual (Get-R17PropertyValue -Object $ToolPermissionRules -Name "r17_009_defines_permissions_only" -Context $Context) -Message "$Context must define permissions only."
    Assert-R17FalseFields -Object $ToolPermissionRules -Context $Context -FieldNames @(
        "tool_invocation_runtime_implemented",
        "api_calls_implemented",
        "codex_executor_invocation_implemented",
        "qa_test_agent_invocation_implemented",
        "evidence_auditor_api_invocation_implemented"
    )
    Assert-R17True -Actual (Get-R17PropertyValue -Object $ToolPermissionRules -Name "future_adapter_use_requires_later_task_gate" -Context $Context) -Message "$Context must gate future adapter use by later tasks."
}

function Test-R17EvidenceRequirements {
    param(
        [Parameter(Mandatory = $true)]
        [object]$EvidenceRequirements,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-R17True -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "every_recommendation_must_cite_refs" -Context $Context) -Message "$Context must require refs for every recommendation."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "generated_markdown_is_operator_readable_only_unless_backed_by_validation" -Context $Context) -Message "$Context must preserve generated Markdown proof limits."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "generated_markdown_is_machine_proof_without_validation" -Context $Context) -Message "$Context must not treat generated reports as machine proof without validation."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "route_recommendations_are_execution_proof" -Context $Context) -Message "$Context must not treat route recommendations as execution proof."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "handoff_recommendations_are_executable_handoffs" -Context $Context) -Message "$Context must not treat handoff recommendations as executable handoffs."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $EvidenceRequirements -Name "audit_requests_are_audit_verdicts" -Context $Context) -Message "$Context must not treat audit requests as audit verdicts."
}

function Test-R17BoardAndCardPermissions {
    param(
        [Parameter(Mandatory = $true)]
        [object]$BoardPermissions,
        [Parameter(Mandatory = $true)]
        [object]$CardPermissions,
        [Parameter(Mandatory = $true)]
        [object]$RoutingPermissions,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-R17True -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "can_propose_card_creation" -Context $Context) -Message "$Context must allow proposing card creation."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "card_creation_runtime_implemented_in_r17_009" -Context $Context) -Message "$Context must not implement card creation runtime."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "can_propose_lane_movement" -Context $Context) -Message "$Context must allow proposing lane movement."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "lane_movement_runtime_implemented_in_r17_009" -Context $Context) -Message "$Context must not implement lane movement runtime."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "can_move_cards_to_closed_without_user_approval" -Context $Context) -Message "$Context must not allow closing cards without user approval."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "can_bypass_qa_gate" -Context $Context) -Message "$Context must not allow QA gate bypass."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "can_bypass_audit_gate" -Context $Context) -Message "$Context must not allow audit gate bypass."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $BoardPermissions -Name "board_state_replaces_repo_truth" -Context $Context) -Message "$Context must not treat board as canonical over repo truth."

    Assert-R17False -Actual (Get-R17PropertyValue -Object $CardPermissions -Name "can_invoke_recommended_next_role_in_r17_009" -Context $Context) -Message "$Context must not invoke agents from card routing."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $CardPermissions -Name "can_close_cards_without_user_approval" -Context $Context) -Message "$Context must not close cards without user approval."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $CardPermissions -Name "closure_requires_user_approval" -Context $Context) -Message "$Context must require user approval for closure."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $CardPermissions -Name "qa_gate_required_before_audit_or_closure" -Context $Context) -Message "$Context must preserve QA gate requirement."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $CardPermissions -Name "audit_gate_required_before_release_or_closure" -Context $Context) -Message "$Context must preserve audit gate requirement."

    Assert-R17True -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "can_propose_card_routing" -Context $Context) -Message "$Context must allow routing proposals."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "can_invoke_agents_in_r17_009" -Context $Context) -Message "$Context must not invoke runtime agents."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "can_execute_handoffs_in_r17_009" -Context $Context) -Message "$Context must not execute handoffs."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "can_execute_transitions_in_r17_009" -Context $Context) -Message "$Context must not execute transitions."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "route_recommendations_are_execution_proof" -Context $Context) -Message "$Context must not treat routes as execution proof."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $RoutingPermissions -Name "handoff_recommendations_are_executable_handoffs" -Context $Context) -Message "$Context must not treat handoffs as executable."

    Assert-R17ArrayContainsAll -Actual (Get-R17RuleIds -Rules (Get-R17PropertyValue -Object $BoardPermissions -Name "rules" -Context $Context) -Context "$Context board permissions") -Expected @(
        "may_propose_card_creation_no_creation_runtime",
        "may_propose_lane_movement_no_movement_runtime",
        "may_request_user_decision_no_notification_runtime",
        "may_not_move_cards_to_closed_without_user_approval",
        "may_not_bypass_qa_or_audit_gates",
        "may_not_treat_board_as_canonical_over_repo_truth"
    ) -Context "$Context board permission rules"

    Assert-R17ArrayContainsAll -Actual (Get-R17RuleIds -Rules (Get-R17PropertyValue -Object $CardPermissions -Name "rules" -Context $Context) -Context "$Context card permissions") -Expected @(
        "may_propose_card_creation_no_creation_runtime",
        "may_assign_recommended_next_role_no_agent_invocation",
        "may_not_close_without_user_approval",
        "may_not_bypass_qa_or_audit_gates"
    ) -Context "$Context card permission rules"
}

function Test-R17BoundaryPreservation {
    param(
        [Parameter(Mandatory = $true)]
        [object]$PreservedBoundaries,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $r13 = Get-R17PropertyValue -Object $PreservedBoundaries -Name "r13" -Context $Context
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $r13 -Name "active_through" -Context "$Context r13") -Expected "R13-018" -Message "$Context must preserve R13 active through R13-018."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $r13 -Name "closed" -Context "$Context r13") -Message "$Context must not claim R13 closure."

    $r14 = Get-R17PropertyValue -Object $PreservedBoundaries -Name "r14" -Context $Context
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $r14 -Name "through" -Context "$Context r14") -Expected "R14-006" -Message "$Context must preserve R14 through R14-006."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $r14 -Name "caveats_removed" -Context "$Context r14") -Message "$Context must not remove R14 caveats."

    $r15 = Get-R17PropertyValue -Object $PreservedBoundaries -Name "r15" -Context $Context
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $r15 -Name "through" -Context "$Context r15") -Expected "R15-009" -Message "$Context must preserve R15 through R15-009."
    Assert-R17False -Actual (Get-R17PropertyValue -Object $r15 -Name "caveats_removed" -Context "$Context r15") -Message "$Context must not remove R15 caveats."

    $r16 = Get-R17PropertyValue -Object $PreservedBoundaries -Name "r16" -Context $Context
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $r16 -Name "through" -Context "$Context r16") -Expected "R16-026" -Message "$Context must preserve R16 through R16-026."
    Assert-R17FalseFields -Object $r16 -Context "$Context r16" -FieldNames @(
        "external_audit_acceptance_claimed",
        "main_merge_completed",
        "product_runtime_implemented",
        "a2a_runtime_implemented",
        "autonomous_agents_implemented",
        "solved_codex_compaction",
        "solved_codex_reliability"
    )
}

function Test-R17OrchestratorContractObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract
    )

    foreach ($fieldName in @(
            "artifact_type",
            "contract_version",
            "contract_id",
            "source_milestone",
            "source_task",
            "repository",
            "branch",
            "scope",
            "purpose",
            "orchestrator_identity",
            "authority_model",
            "allowed_actions",
            "forbidden_actions",
            "board_permissions",
            "card_permissions",
            "routing_permissions",
            "user_approval_requirements",
            "role_boundary_rules",
            "memory_scope_rules",
            "tool_permission_rules",
            "evidence_requirements",
            "stop_retry_reentry_requirements",
            "audit_requirements",
            "non_claims",
            "rejected_claims",
            "runtime_boundaries"
        )) {
        Get-R17PropertyValue -Object $Contract -Name $fieldName -Context "contract" | Out-Null
    }

    Assert-R17Equals -Actual $Contract.artifact_type -Expected "r17_orchestrator_identity_authority_contract" -Message "contract artifact_type must be r17_orchestrator_identity_authority_contract."
    Assert-R17Equals -Actual $Contract.source_task -Expected "R17-009" -Message "contract source_task must be R17-009."

    Test-R17OrchestratorIdentityObject -Identity $Contract.orchestrator_identity -Context "contract orchestrator_identity"
    Assert-R17ArrayContainsAll -Actual $Contract.allowed_actions -Expected (Get-R17RequiredAllowedActions) -Context "contract allowed_actions"
    Assert-R17ArrayContainsAll -Actual $Contract.forbidden_actions -Expected (Get-R17RequiredForbiddenActions) -Context "contract forbidden_actions"
    Test-R17BoardAndCardPermissions -BoardPermissions $Contract.board_permissions -CardPermissions $Contract.card_permissions -RoutingPermissions $Contract.routing_permissions -Context "contract permissions"
    Test-R17MemoryScopeRules -MemoryScopeRules $Contract.memory_scope_rules -Context "contract memory_scope_rules"
    Test-R17ToolPermissionRules -ToolPermissionRules $Contract.tool_permission_rules -Context "contract tool_permission_rules"
    Test-R17EvidenceRequirements -EvidenceRequirements $Contract.evidence_requirements -Context "contract evidence_requirements"
    Assert-R17FalseFields -Object $Contract.runtime_boundaries -FieldNames (Get-R17RequiredRuntimeBoundaryFields) -Context "contract runtime_boundaries"
    Assert-R17ArrayContainsAll -Actual $Contract.non_claims -Expected (Get-R17RequiredNonClaims) -Context "contract non_claims"
    Assert-R17ArrayContainsAll -Actual $Contract.rejected_claims -Expected (Get-R17RequiredRejectedClaims) -Context "contract rejected_claims"
    Test-R17BoundaryPreservation -PreservedBoundaries $Contract.preserved_boundaries -Context "contract preserved_boundaries"
}

function Get-R17GitIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read git HEAD."
    }

    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read git tree."
    }

    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function New-R17OrchestratorIdentityAuthorityStateObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$GitIdentity
    )

    return [ordered]@{
        artifact_type = "r17_orchestrator_identity_authority"
        contract_version = $Contract.contract_version
        state_id = "aioffice-r17-009-orchestrator-identity-authority-state-v1"
        source_milestone = $Contract.source_milestone
        source_task = $Contract.source_task
        repository = $Contract.repository
        branch = $Contract.branch
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_state_artifact_only = $true
        contract_ref = "contracts/agents/r17_orchestrator_identity_authority.contract.json"
        scope = $Contract.scope
        purpose = $Contract.purpose
        orchestrator_identity = $Contract.orchestrator_identity
        authority_model = $Contract.authority_model
        allowed_actions = $Contract.allowed_actions
        forbidden_actions = $Contract.forbidden_actions
        board_permissions = $Contract.board_permissions
        card_permissions = $Contract.card_permissions
        routing_permissions = $Contract.routing_permissions
        approval_limits = $Contract.approval_limits
        user_approval_requirements = $Contract.user_approval_requirements
        role_boundary_rules = $Contract.role_boundary_rules
        memory_scope_rules = $Contract.memory_scope_rules
        tool_permission_rules = $Contract.tool_permission_rules
        evidence_requirements = $Contract.evidence_requirements
        stop_retry_reentry_requirements = $Contract.stop_retry_reentry_requirements
        audit_requirements = $Contract.audit_requirements
        claim_status = [ordered]@{
            external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
            r13_closure_claimed = $false
            r14_caveat_removal_claimed = $false
            r15_caveat_removal_claimed = $false
            solved_codex_compaction_claimed = $false
            solved_codex_reliability_claimed = $false
        }
        output_placeholders = [ordered]@{
            dev_output = [ordered]@{
                status = "not_implemented_in_r17_009"
                claimed = $false
            }
            qa_result = [ordered]@{
                status = "not_implemented_in_r17_009"
                claimed = $false
            }
            audit_verdict = [ordered]@{
                status = "not_implemented_in_r17_009"
                claimed = $false
            }
        }
        non_claims = $Contract.non_claims
        rejected_claims = $Contract.rejected_claims
        runtime_boundaries = $Contract.runtime_boundaries
        preserved_boundaries = $Contract.preserved_boundaries
        evidence_refs = @(
            "contracts/agents/r17_orchestrator_identity_authority.contract.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
            "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json",
            "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json",
            "state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_009_orchestrator_identity_authority/proof_review.md",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_009_orchestrator_identity_authority/evidence_index.json"
        )
    }
}

function New-R17OrchestratorRouteRecommendationSeedObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$GitIdentity
    )

    return [ordered]@{
        artifact_type = "r17_orchestrator_route_recommendation_seed"
        contract_version = $Contract.contract_version
        seed_id = "aioffice-r17-009-orchestrator-route-recommendation-seed-v1"
        source_milestone = $Contract.source_milestone
        source_task = $Contract.source_task
        repository = $Contract.repository
        branch = $Contract.branch
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_from_contract = "contracts/agents/r17_orchestrator_identity_authority.contract.json"
        generated_state_artifact_only = $true
        source_card_id = "R17-005"
        current_lane = "ready_for_user_review"
        recommended_next_action = "request_user_review_or_closure_decision"
        recommended_next_role = "user"
        user_decision_required = $true
        closure_requires_user_approval = $true
        evidence_refs = @(
            "contracts/agents/r17_orchestrator_identity_authority.contract.json",
            "state/agents/r17_orchestrator_identity_authority.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json",
            "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json",
            "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json",
            "state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/",
            "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_009_orchestrator_identity_authority/"
        )
        memory_refs = @(
            [ordered]@{
                ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md"
                boundary = "exact repo ref only, not hidden chat memory"
            },
            [ordered]@{
                ref = "state/governance/r17_kpi_baseline_target_scorecard.json"
                boundary = "exact repo ref only, target scores are not achieved implementation evidence"
            },
            [ordered]@{
                ref = "contracts/board/r17_card.contract.json"
                boundary = "exact repo ref only, card contract model"
            },
            [ordered]@{
                ref = "contracts/board/r17_board_state.contract.json"
                boundary = "exact repo ref only, board state contract model"
            },
            [ordered]@{
                ref = "contracts/board/r17_board_event.contract.json"
                boundary = "exact repo ref only, board event contract model"
            }
        )
        non_executable_recommendation = $true
        runtime_invocation_performed = $false
        agent_invocation_performed = $false
        board_mutation_performed = $false
        a2a_message_sent = $false
        api_call_performed = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
        recommendation_boundary = "This is a generated non-executable route recommendation seed only. It requests user review or closure decision for the R17-005 seed card and performs no runtime invocation, board mutation, A2A message, API call, Dev output claim, QA result claim, or audit verdict claim."
        non_claims = $Contract.non_claims
        rejected_claims = $Contract.rejected_claims
    }
}

function New-R17OrchestratorAuthorityCheckReportObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Contract,
        [Parameter(Mandatory = $true)]
        [object]$GitIdentity
    )

    return [ordered]@{
        artifact_type = "r17_orchestrator_authority_check_report"
        contract_version = $Contract.contract_version
        report_id = "aioffice-r17-009-orchestrator-authority-check-report-v1"
        source_milestone = $Contract.source_milestone
        source_task = $Contract.source_task
        repository = $Contract.repository
        branch = $Contract.branch
        generated_from_head = $GitIdentity.Head
        generated_from_tree = $GitIdentity.Tree
        generated_from_contract = "contracts/agents/r17_orchestrator_identity_authority.contract.json"
        generated_state_artifact_only = $true
        checked_artifacts = @(
            "contracts/agents/r17_orchestrator_identity_authority.contract.json",
            "state/agents/r17_orchestrator_identity_authority.json",
            "state/agents/r17_orchestrator_route_recommendation_seed.json"
        )
        checks = [ordered]@{
            orchestrator_identity_fields = [ordered]@{ status = "passed" }
            allowed_actions = [ordered]@{ status = "passed" }
            forbidden_actions = [ordered]@{ status = "passed" }
            board_card_permission_rules = [ordered]@{ status = "passed" }
            memory_scope_rules = [ordered]@{ status = "passed" }
            tool_permission_rules = [ordered]@{ status = "passed" }
            route_recommendation_seed_artifact = [ordered]@{ status = "passed" }
            non_claims = [ordered]@{ status = "passed" }
            rejected_claims = [ordered]@{ status = "passed" }
            r13_r14_r15_r16_boundary_preservation = [ordered]@{ status = "passed" }
            runtime_boundaries = [ordered]@{ status = "passed" }
        }
        aggregate_verdict = "generated_r17_orchestrator_identity_authority_candidate"
        non_claims = $Contract.non_claims
        rejected_claims = $Contract.rejected_claims
        runtime_boundaries = $Contract.runtime_boundaries
    }
}

function Test-R17OrchestratorIdentityAuthorityStateObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$IdentityState
    )

    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $IdentityState -Name "artifact_type" -Context "identity state") -Expected "r17_orchestrator_identity_authority" -Message "identity state artifact_type must be r17_orchestrator_identity_authority."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $IdentityState -Name "source_task" -Context "identity state") -Expected "R17-009" -Message "identity state source_task must be R17-009."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $IdentityState -Name "generated_state_artifact_only" -Context "identity state") -Message "identity state must be a generated state artifact only."

    Test-R17OrchestratorIdentityObject -Identity (Get-R17PropertyValue -Object $IdentityState -Name "orchestrator_identity" -Context "identity state") -Context "identity state orchestrator_identity"
    Assert-R17ArrayContainsAll -Actual (Get-R17PropertyValue -Object $IdentityState -Name "allowed_actions" -Context "identity state") -Expected (Get-R17RequiredAllowedActions) -Context "identity state allowed_actions"
    Assert-R17ArrayContainsAll -Actual (Get-R17PropertyValue -Object $IdentityState -Name "forbidden_actions" -Context "identity state") -Expected (Get-R17RequiredForbiddenActions) -Context "identity state forbidden_actions"
    Test-R17BoardAndCardPermissions -BoardPermissions $IdentityState.board_permissions -CardPermissions $IdentityState.card_permissions -RoutingPermissions $IdentityState.routing_permissions -Context "identity state permissions"
    Test-R17MemoryScopeRules -MemoryScopeRules $IdentityState.memory_scope_rules -Context "identity state memory_scope_rules"
    Test-R17ToolPermissionRules -ToolPermissionRules $IdentityState.tool_permission_rules -Context "identity state tool_permission_rules"
    Test-R17EvidenceRequirements -EvidenceRequirements $IdentityState.evidence_requirements -Context "identity state evidence_requirements"
    Assert-R17FalseFields -Object $IdentityState.runtime_boundaries -FieldNames (Get-R17RequiredRuntimeBoundaryFields) -Context "identity state runtime_boundaries"
    Assert-R17FalseFields -Object $IdentityState.claim_status -FieldNames @(
        "external_audit_acceptance_claimed",
        "main_merge_claimed",
        "r13_closure_claimed",
        "r14_caveat_removal_claimed",
        "r15_caveat_removal_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed"
    ) -Context "identity state claim_status"

    Assert-R17False -Actual $IdentityState.output_placeholders.dev_output.claimed -Message "identity state must not claim Dev output."
    Assert-R17False -Actual $IdentityState.output_placeholders.qa_result.claimed -Message "identity state must not claim QA result."
    Assert-R17False -Actual $IdentityState.output_placeholders.audit_verdict.claimed -Message "identity state must not claim audit verdict."
    Assert-R17ArrayContainsAll -Actual $IdentityState.non_claims -Expected (Get-R17RequiredNonClaims) -Context "identity state non_claims"
    Assert-R17ArrayContainsAll -Actual $IdentityState.rejected_claims -Expected (Get-R17RequiredRejectedClaims) -Context "identity state rejected_claims"
    Test-R17BoundaryPreservation -PreservedBoundaries $IdentityState.preserved_boundaries -Context "identity state preserved_boundaries"
}

function Test-R17OrchestratorRouteRecommendationSeedObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$RouteSeed
    )

    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "artifact_type" -Context "route seed") -Expected "r17_orchestrator_route_recommendation_seed" -Message "route seed artifact_type must be r17_orchestrator_route_recommendation_seed."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "source_card_id" -Context "route seed") -Expected "R17-005" -Message "route seed must use R17-005 as source_card_id."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "current_lane" -Context "route seed") -Expected "ready_for_user_review" -Message "route seed current_lane must be ready_for_user_review."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "recommended_next_action" -Context "route seed") -Expected "request_user_review_or_closure_decision" -Message "route seed recommended_next_action must request user review or closure decision."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "recommended_next_role" -Context "route seed") -Expected "user" -Message "route seed recommended_next_role must be user."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "user_decision_required" -Context "route seed") -Message "route seed must require user decision."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "closure_requires_user_approval" -Context "route seed") -Message "route seed must require user approval for closure."
    Assert-R17True -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "non_executable_recommendation" -Context "route seed") -Message "route seed must be non-executable."

    Assert-R17FalseFields -Object $RouteSeed -FieldNames @(
        "runtime_invocation_performed",
        "agent_invocation_performed",
        "board_mutation_performed",
        "a2a_message_sent",
        "api_call_performed",
        "dev_output_claimed",
        "qa_result_claimed",
        "audit_verdict_claimed"
    ) -Context "route seed"

    Assert-R17ArrayContainsAll -Actual (Get-R17PropertyValue -Object $RouteSeed -Name "evidence_refs" -Context "route seed") -Expected @(
        "contracts/agents/r17_orchestrator_identity_authority.contract.json",
        "state/agents/r17_orchestrator_identity_authority.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json"
    ) -Context "route seed evidence_refs"
    if (@($RouteSeed.memory_refs).Count -lt 1) {
        throw "route seed memory_refs must not be empty."
    }
}

function Test-R17OrchestratorAuthorityCheckReportObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$CheckReport
    )

    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $CheckReport -Name "artifact_type" -Context "authority check report") -Expected "r17_orchestrator_authority_check_report" -Message "authority check report artifact_type must be r17_orchestrator_authority_check_report."
    Assert-R17Equals -Actual (Get-R17PropertyValue -Object $CheckReport -Name "aggregate_verdict" -Context "authority check report") -Expected "generated_r17_orchestrator_identity_authority_candidate" -Message "authority check report aggregate verdict must be generated_r17_orchestrator_identity_authority_candidate."
    $checks = Get-R17PropertyValue -Object $CheckReport -Name "checks" -Context "authority check report"
    foreach ($checkName in @(
            "orchestrator_identity_fields",
            "allowed_actions",
            "forbidden_actions",
            "board_card_permission_rules",
            "memory_scope_rules",
            "tool_permission_rules",
            "route_recommendation_seed_artifact",
            "non_claims",
            "rejected_claims",
            "r13_r14_r15_r16_boundary_preservation",
            "runtime_boundaries"
        )) {
        $check = Get-R17PropertyValue -Object $checks -Name $checkName -Context "authority check report checks"
        Assert-R17Equals -Actual (Get-R17PropertyValue -Object $check -Name "status" -Context "authority check report $checkName") -Expected "passed" -Message "authority check report '$checkName' must be passed."
    }
    Assert-R17FalseFields -Object $CheckReport.runtime_boundaries -FieldNames (Get-R17RequiredRuntimeBoundaryFields) -Context "authority check report runtime_boundaries"
}

function Test-R17OrchestratorIdentityAuthorityArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17RepositoryRoot),
        [string]$ContractPath = "contracts/agents/r17_orchestrator_identity_authority.contract.json",
        [string]$IdentityStatePath = "state/agents/r17_orchestrator_identity_authority.json",
        [string]$RouteSeedPath = "state/agents/r17_orchestrator_route_recommendation_seed.json",
        [string]$CheckReportPath = "state/agents/r17_orchestrator_authority_check_report.json"
    )

    $contract = Read-R17JsonFile -Path (Resolve-R17Path -PathValue $ContractPath -RepositoryRoot $RepositoryRoot) -Label "Orchestrator identity/authority contract"
    $identityState = Read-R17JsonFile -Path (Resolve-R17Path -PathValue $IdentityStatePath -RepositoryRoot $RepositoryRoot) -Label "Orchestrator identity/authority state artifact"
    $routeSeed = Read-R17JsonFile -Path (Resolve-R17Path -PathValue $RouteSeedPath -RepositoryRoot $RepositoryRoot) -Label "Orchestrator route recommendation seed"
    $checkReport = Read-R17JsonFile -Path (Resolve-R17Path -PathValue $CheckReportPath -RepositoryRoot $RepositoryRoot) -Label "Orchestrator authority check report"

    Test-R17OrchestratorContractObject -Contract $contract
    Test-R17OrchestratorIdentityAuthorityStateObject -IdentityState $identityState
    Test-R17OrchestratorRouteRecommendationSeedObject -RouteSeed $routeSeed
    Test-R17OrchestratorAuthorityCheckReportObject -CheckReport $checkReport

    return [pscustomobject]@{
        aggregate_verdict = $checkReport.aggregate_verdict
        source_card_id = $routeSeed.source_card_id
        recommended_next_action = $routeSeed.recommended_next_action
        recommended_next_role = $routeSeed.recommended_next_role
        user_decision_required = $routeSeed.user_decision_required
        board_mutation_performed = $routeSeed.board_mutation_performed
        agent_invocation_performed = $routeSeed.agent_invocation_performed
        a2a_message_sent = $routeSeed.a2a_message_sent
        api_call_performed = $routeSeed.api_call_performed
        dev_output_claimed = $routeSeed.dev_output_claimed
        qa_result_claimed = $routeSeed.qa_result_claimed
        audit_verdict_claimed = $routeSeed.audit_verdict_claimed
    }
}

function Get-R17InvalidFixtureSpecs {
    return @(
        [ordered]@{ mutation_id = "invalid_missing_agent_id"; target = "identity_state"; operation = "remove"; path = "orchestrator_identity.agent_id"; expected_failure_fragment = "agent_id" },
        [ordered]@{ mutation_id = "invalid_can_execute_code"; target = "identity_state"; operation = "set"; path = "orchestrator_identity.can_execute_code"; value = $true; expected_failure_fragment = "can_execute_code" },
        [ordered]@{ mutation_id = "invalid_can_run_tests"; target = "identity_state"; operation = "set"; path = "orchestrator_identity.can_run_tests"; value = $true; expected_failure_fragment = "can_run_tests" },
        [ordered]@{ mutation_id = "invalid_can_approve_evidence_sufficiency"; target = "identity_state"; operation = "set"; path = "orchestrator_identity.can_approve_evidence_sufficiency"; value = $true; expected_failure_fragment = "can_approve_evidence_sufficiency" },
        [ordered]@{ mutation_id = "invalid_can_close_without_user_approval"; target = "identity_state"; operation = "set"; path = "orchestrator_identity.can_close_cards_without_user_approval"; value = $true; expected_failure_fragment = "can_close_cards_without_user_approval" },
        [ordered]@{ mutation_id = "invalid_bypass_qa_gate"; target = "identity_state"; operation = "set"; path = "board_permissions.can_bypass_qa_gate"; value = $true; expected_failure_fragment = "QA gate bypass" },
        [ordered]@{ mutation_id = "invalid_bypass_audit_gate"; target = "identity_state"; operation = "set"; path = "board_permissions.can_bypass_audit_gate"; value = $true; expected_failure_fragment = "audit gate bypass" },
        [ordered]@{ mutation_id = "invalid_live_board_mutation_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.live_board_mutation_implemented"; value = $true; expected_failure_fragment = "live_board_mutation_implemented" },
        [ordered]@{ mutation_id = "invalid_orchestrator_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.orchestrator_runtime_implemented"; value = $true; expected_failure_fragment = "orchestrator_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_a2a_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.a2a_runtime_implemented"; value = $true; expected_failure_fragment = "a2a_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_autonomous_agent_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.autonomous_agents_implemented"; value = $true; expected_failure_fragment = "autonomous_agents_implemented" },
        [ordered]@{ mutation_id = "invalid_dev_codex_adapter_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.dev_codex_adapter_runtime_implemented"; value = $true; expected_failure_fragment = "dev_codex_adapter_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_qa_adapter_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.qa_test_agent_adapter_runtime_implemented"; value = $true; expected_failure_fragment = "qa_test_agent_adapter_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_evidence_auditor_api_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.evidence_auditor_api_runtime_implemented"; value = $true; expected_failure_fragment = "evidence_auditor_api_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_external_api_call_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.external_api_calls_implemented"; value = $true; expected_failure_fragment = "external_api_calls_implemented" },
        [ordered]@{ mutation_id = "invalid_executable_handoff_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.executable_handoffs_implemented"; value = $true; expected_failure_fragment = "executable_handoffs_implemented" },
        [ordered]@{ mutation_id = "invalid_executable_transition_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.executable_transitions_implemented"; value = $true; expected_failure_fragment = "executable_transitions_implemented" },
        [ordered]@{ mutation_id = "invalid_product_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.product_runtime_implemented"; value = $true; expected_failure_fragment = "product_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_production_runtime_claim"; target = "identity_state"; operation = "set"; path = "runtime_boundaries.production_runtime_implemented"; value = $true; expected_failure_fragment = "production_runtime_implemented" },
        [ordered]@{ mutation_id = "invalid_dev_output_claim"; target = "route_seed"; operation = "set"; path = "dev_output_claimed"; value = $true; expected_failure_fragment = "dev_output_claimed" },
        [ordered]@{ mutation_id = "invalid_qa_result_claim"; target = "route_seed"; operation = "set"; path = "qa_result_claimed"; value = $true; expected_failure_fragment = "qa_result_claimed" },
        [ordered]@{ mutation_id = "invalid_audit_verdict_claim"; target = "route_seed"; operation = "set"; path = "audit_verdict_claimed"; value = $true; expected_failure_fragment = "audit_verdict_claimed" },
        [ordered]@{ mutation_id = "invalid_external_audit_acceptance_claim"; target = "identity_state"; operation = "set"; path = "claim_status.external_audit_acceptance_claimed"; value = $true; expected_failure_fragment = "external_audit_acceptance_claimed" },
        [ordered]@{ mutation_id = "invalid_main_merge_claim"; target = "identity_state"; operation = "set"; path = "claim_status.main_merge_claimed"; value = $true; expected_failure_fragment = "main_merge_claimed" },
        [ordered]@{ mutation_id = "invalid_r13_closure_claim"; target = "identity_state"; operation = "set"; path = "claim_status.r13_closure_claimed"; value = $true; expected_failure_fragment = "r13_closure_claimed" },
        [ordered]@{ mutation_id = "invalid_r14_caveat_removal_claim"; target = "identity_state"; operation = "set"; path = "claim_status.r14_caveat_removal_claimed"; value = $true; expected_failure_fragment = "r14_caveat_removal_claimed" },
        [ordered]@{ mutation_id = "invalid_r15_caveat_removal_claim"; target = "identity_state"; operation = "set"; path = "claim_status.r15_caveat_removal_claimed"; value = $true; expected_failure_fragment = "r15_caveat_removal_claimed" },
        [ordered]@{ mutation_id = "invalid_solved_codex_compaction_claim"; target = "identity_state"; operation = "set"; path = "claim_status.solved_codex_compaction_claimed"; value = $true; expected_failure_fragment = "solved_codex_compaction_claimed" },
        [ordered]@{ mutation_id = "invalid_solved_codex_reliability_claim"; target = "identity_state"; operation = "set"; path = "claim_status.solved_codex_reliability_claimed"; value = $true; expected_failure_fragment = "solved_codex_reliability_claimed" },
        [ordered]@{ mutation_id = "invalid_broad_repo_scan_memory_scope"; target = "identity_state"; operation = "set"; path = "memory_scope_rules.broad_repo_scan_allowed"; value = $true; expected_failure_fragment = "broad repo scans" },
        [ordered]@{ mutation_id = "invalid_raw_chat_history_as_canonical"; target = "identity_state"; operation = "set"; path = "memory_scope_rules.raw_chat_history_is_canonical"; value = $true; expected_failure_fragment = "raw chat history" },
        [ordered]@{ mutation_id = "invalid_generated_report_as_machine_proof"; target = "identity_state"; operation = "set"; path = "evidence_requirements.generated_markdown_is_machine_proof_without_validation"; value = $true; expected_failure_fragment = "generated reports" },
        [ordered]@{ mutation_id = "invalid_route_recommendation_executable"; target = "route_seed"; operation = "set"; path = "non_executable_recommendation"; value = $false; expected_failure_fragment = "non-executable" },
        [ordered]@{ mutation_id = "invalid_agent_invocation_performed"; target = "route_seed"; operation = "set"; path = "agent_invocation_performed"; value = $true; expected_failure_fragment = "agent_invocation_performed" },
        [ordered]@{ mutation_id = "invalid_board_mutation_performed"; target = "route_seed"; operation = "set"; path = "board_mutation_performed"; value = $true; expected_failure_fragment = "board_mutation_performed" },
        [ordered]@{ mutation_id = "invalid_a2a_message_sent"; target = "route_seed"; operation = "set"; path = "a2a_message_sent"; value = $true; expected_failure_fragment = "a2a_message_sent" },
        [ordered]@{ mutation_id = "invalid_api_call_performed"; target = "route_seed"; operation = "set"; path = "api_call_performed"; value = $true; expected_failure_fragment = "api_call_performed" }
    )
}

function New-R17OrchestratorIdentityAuthorityArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17RepositoryRoot)
    )

    $contractPath = Resolve-R17Path -PathValue "contracts/agents/r17_orchestrator_identity_authority.contract.json" -RepositoryRoot $RepositoryRoot
    $contract = Read-R17JsonFile -Path $contractPath -Label "Orchestrator identity/authority contract"
    Test-R17OrchestratorContractObject -Contract $contract

    $gitIdentity = Get-R17GitIdentity -RepositoryRoot $RepositoryRoot
    $identityState = New-R17OrchestratorIdentityAuthorityStateObject -Contract $contract -GitIdentity $gitIdentity
    $routeSeed = New-R17OrchestratorRouteRecommendationSeedObject -Contract $contract -GitIdentity $gitIdentity
    $checkReport = New-R17OrchestratorAuthorityCheckReportObject -Contract $contract -GitIdentity $gitIdentity

    $identityPath = Resolve-R17Path -PathValue "state/agents/r17_orchestrator_identity_authority.json" -RepositoryRoot $RepositoryRoot
    $routeSeedPath = Resolve-R17Path -PathValue "state/agents/r17_orchestrator_route_recommendation_seed.json" -RepositoryRoot $RepositoryRoot
    $checkReportPath = Resolve-R17Path -PathValue "state/agents/r17_orchestrator_authority_check_report.json" -RepositoryRoot $RepositoryRoot

    Write-R17JsonFile -Path $identityPath -Value $identityState
    Write-R17JsonFile -Path $routeSeedPath -Value $routeSeed
    Write-R17JsonFile -Path $checkReportPath -Value $checkReport

    $fixtureRoot = Resolve-R17Path -PathValue "tests/fixtures/r17_orchestrator_identity_authority" -RepositoryRoot $RepositoryRoot
    Write-R17JsonFile -Path (Join-Path $fixtureRoot "valid_orchestrator_identity_authority.json") -Value $identityState
    Write-R17JsonFile -Path (Join-Path $fixtureRoot "valid_route_recommendation_seed.json") -Value $routeSeed
    Write-R17JsonFile -Path (Join-Path $fixtureRoot "valid_authority_check_report.json") -Value $checkReport

    foreach ($spec in Get-R17InvalidFixtureSpecs) {
        $fixturePath = Join-Path $fixtureRoot ("{0}.json" -f $spec.mutation_id)
        $fixture = [ordered]@{
            fixture_type = "r17_orchestrator_identity_authority_invalid_mutation"
            mutation_id = $spec.mutation_id
            target = $spec.target
            operation = $spec.operation
            path = $spec.path
            expected_failure_fragment = $spec.expected_failure_fragment
        }
        if ($spec.Contains("value")) {
            $fixture["value"] = $spec.value
        }
        Write-R17JsonFile -Path $fixturePath -Value $fixture
    }

    $validation = Test-R17OrchestratorIdentityAuthorityArtifacts -RepositoryRoot $RepositoryRoot
    return [pscustomobject]@{
        generated = $true
        contract_path = "contracts/agents/r17_orchestrator_identity_authority.contract.json"
        identity_state_path = "state/agents/r17_orchestrator_identity_authority.json"
        route_recommendation_seed_path = "state/agents/r17_orchestrator_route_recommendation_seed.json"
        authority_check_report_path = "state/agents/r17_orchestrator_authority_check_report.json"
        fixture_root = "tests/fixtures/r17_orchestrator_identity_authority/"
        aggregate_verdict = $validation.aggregate_verdict
    }
}

function Copy-R17JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object
    )

    return ($Object | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17MutationParent {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $segments = $Path -split "\."
    if ($segments.Count -lt 1) {
        throw "Mutation path '$Path' is invalid."
    }

    $current = $Object
    for ($index = 0; $index -lt ($segments.Count - 1); $index++) {
        $segment = $segments[$index]
        $property = $current.PSObject.Properties[$segment]
        if ($null -eq $property) {
            throw "Mutation path '$Path' missing segment '$segment'."
        }
        $current = $property.Value
    }

    return [pscustomobject]@{
        Parent = $current
        Leaf = $segments[-1]
    }
}

function Apply-R17FixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,
        [Parameter(Mandatory = $true)]
        [object]$Mutation
    )

    $target = Get-R17MutationParent -Object $Object -Path $Mutation.path
    if ($Mutation.operation -eq "remove") {
        $target.Parent.PSObject.Properties.Remove($target.Leaf)
        if ($null -ne $target.Parent.PSObject.Properties[$target.Leaf]) {
            throw "Mutation could not remove '$($Mutation.path)'."
        }
        return
    }

    if ($Mutation.operation -ne "set") {
        throw "Unsupported mutation operation '$($Mutation.operation)'."
    }

    $property = $target.Parent.PSObject.Properties[$target.Leaf]
    if ($null -eq $property) {
        throw "Mutation path '$($Mutation.path)' missing leaf '$($target.Leaf)'."
    }

    $property.Value = $Mutation.value
}

function Test-R17OrchestratorIdentityAuthorityFixtures {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17RepositoryRoot),
        [string]$FixtureDirectory = "tests/fixtures/r17_orchestrator_identity_authority"
    )

    $fixtureRoot = Resolve-R17Path -PathValue $FixtureDirectory -RepositoryRoot $RepositoryRoot
    $contractPath = Resolve-R17Path -PathValue "contracts/agents/r17_orchestrator_identity_authority.contract.json" -RepositoryRoot $RepositoryRoot
    $validIdentityPath = Join-Path $fixtureRoot "valid_orchestrator_identity_authority.json"
    $validRoutePath = Join-Path $fixtureRoot "valid_route_recommendation_seed.json"
    $validReportPath = Join-Path $fixtureRoot "valid_authority_check_report.json"

    $validIdentity = Read-R17JsonFile -Path $validIdentityPath -Label "valid identity fixture"
    $validRoute = Read-R17JsonFile -Path $validRoutePath -Label "valid route fixture"
    $validReport = Read-R17JsonFile -Path $validReportPath -Label "valid report fixture"

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17_orchestrator_fixture_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $invalidRejected = 0
    $failures = @()

    try {
        $validTempIdentity = Join-Path $tempRoot "valid_identity.json"
        $validTempRoute = Join-Path $tempRoot "valid_route.json"
        $validTempReport = Join-Path $tempRoot "valid_report.json"
        Write-R17JsonFile -Path $validTempIdentity -Value $validIdentity
        Write-R17JsonFile -Path $validTempRoute -Value $validRoute
        Write-R17JsonFile -Path $validTempReport -Value $validReport
        Test-R17OrchestratorIdentityAuthorityArtifacts -RepositoryRoot $RepositoryRoot -ContractPath $contractPath -IdentityStatePath $validTempIdentity -RouteSeedPath $validTempRoute -CheckReportPath $validTempReport | Out-Null

        $invalidFixtures = @(Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | Sort-Object Name)
        if ($invalidFixtures.Count -lt 1) {
            throw "No invalid R17 Orchestrator fixtures were found."
        }

        foreach ($invalidFixture in $invalidFixtures) {
            $mutation = Read-R17JsonFile -Path $invalidFixture.FullName -Label $invalidFixture.Name
            $identity = Copy-R17JsonObject -Object $validIdentity
            $route = Copy-R17JsonObject -Object $validRoute
            $report = Copy-R17JsonObject -Object $validReport

            if ($mutation.target -eq "identity_state") {
                Apply-R17FixtureMutation -Object $identity -Mutation $mutation
            }
            elseif ($mutation.target -eq "route_seed") {
                Apply-R17FixtureMutation -Object $route -Mutation $mutation
            }
            elseif ($mutation.target -eq "authority_check_report") {
                Apply-R17FixtureMutation -Object $report -Mutation $mutation
            }
            else {
                throw "Invalid fixture '$($invalidFixture.Name)' uses unsupported target '$($mutation.target)'."
            }

            $identityPath = Join-Path $tempRoot ("{0}_identity.json" -f $mutation.mutation_id)
            $routePath = Join-Path $tempRoot ("{0}_route.json" -f $mutation.mutation_id)
            $reportPath = Join-Path $tempRoot ("{0}_report.json" -f $mutation.mutation_id)
            Write-R17JsonFile -Path $identityPath -Value $identity
            Write-R17JsonFile -Path $routePath -Value $route
            Write-R17JsonFile -Path $reportPath -Value $report

            try {
                Test-R17OrchestratorIdentityAuthorityArtifacts -RepositoryRoot $RepositoryRoot -ContractPath $contractPath -IdentityStatePath $identityPath -RouteSeedPath $routePath -CheckReportPath $reportPath | Out-Null
                $failures += "Invalid fixture '$($invalidFixture.Name)' was accepted unexpectedly."
            }
            catch {
                $message = $_.Exception.Message
                if ($message -notlike ("*{0}*" -f $mutation.expected_failure_fragment)) {
                    $failures += "Invalid fixture '$($invalidFixture.Name)' failed with unexpected message '$message'. Expected fragment '$($mutation.expected_failure_fragment)'."
                }
                else {
                    $invalidRejected += 1
                }
            }
        }
    }
    finally {
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $resolvedSystemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if ($resolvedTempRoot.StartsWith($resolvedSystemTemp, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedTempRoot)) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }

    if ($failures.Count -gt 0) {
        throw ("R17 Orchestrator fixture validation failed: {0}" -f ($failures -join " | "))
    }

    return [pscustomobject]@{
        valid_fixtures_passed = 3
        invalid_fixtures_rejected = $invalidRejected
    }
}

Export-ModuleMember -Function New-R17OrchestratorIdentityAuthorityArtifacts, Test-R17OrchestratorIdentityAuthorityArtifacts, Test-R17OrchestratorIdentityAuthorityFixtures
