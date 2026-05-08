Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-R17OrchestratorLoopRepositoryRoot {
    return $repoRoot
}

function Resolve-R17OrchestratorLoopPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Read-R17OrchestratorLoopJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $resolvedPath = Resolve-R17OrchestratorLoopPath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
    }
    catch {
        throw "Required JSON artifact '$Path' could not be parsed. $($_.Exception.Message)"
    }
}

function Write-R17OrchestratorLoopJson {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $resolvedPath = Resolve-R17OrchestratorLoopPath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = ($InputObject | ConvertTo-Json -Depth 80).TrimEnd()
    Set-Content -LiteralPath $resolvedPath -Value ($json + [Environment]::NewLine) -Encoding UTF8 -NoNewline
}

function Get-R17GitValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Argument,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $value = & git -C $RepositoryRoot rev-parse $Argument
    if ($LASTEXITCODE -ne 0) {
        throw "git rev-parse $Argument failed."
    }

    return ($value | Select-Object -First 1).Trim()
}

function Assert-R17Condition {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Get-R17PropertyValue {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        if (-not $InputObject.Contains($PropertyName)) {
            throw "$Context is missing required field '$PropertyName'."
        }

        return $InputObject[$PropertyName]
    }

    $property = $InputObject.PSObject.Properties[$PropertyName]
    if ($null -eq $property) {
        throw "$Context is missing required field '$PropertyName'."
    }

    return $property.Value
}

function Assert-R17FalseField {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $value = Get-R17PropertyValue -InputObject $InputObject -PropertyName $PropertyName -Context $Context
    if ($value -ne $false) {
        throw "$Context must set '$PropertyName' to false."
    }
}

function Assert-R17TrueField {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$PropertyName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $value = Get-R17PropertyValue -InputObject $InputObject -PropertyName $PropertyName -Context $Context
    if ($value -ne $true) {
        throw "$Context must set '$PropertyName' to true."
    }
}

function Get-R17Array {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [System.Array]) {
        return @($Value)
    }

    return @($Value)
}

function Copy-R17JsonObject {
    param([Parameter(Mandatory = $true)][object]$InputObject)
    return ($InputObject | ConvertTo-Json -Depth 80 | ConvertFrom-Json)
}

function Get-R17RequiredLoopStates {
    return @(
        "intake",
        "define",
        "ready_for_dev",
        "dev_running",
        "dev_done",
        "qa_running",
        "qa_failed",
        "qa_passed",
        "audit_running",
        "audit_failed",
        "audit_passed",
        "ready_for_user_review",
        "resolved",
        "closed",
        "blocked",
        "stopped",
        "retry_pending",
        "reentry_required"
    )
}

function Get-R17RequiredAllowedTransitionIds {
    return @(
        "intake_to_define",
        "define_to_ready_for_dev",
        "ready_for_dev_to_dev_running",
        "dev_running_to_dev_done",
        "dev_done_to_qa_running",
        "qa_running_to_qa_failed",
        "qa_failed_to_ready_for_dev",
        "qa_running_to_qa_passed",
        "qa_passed_to_audit_running",
        "audit_running_to_audit_failed",
        "audit_failed_to_ready_for_dev",
        "audit_running_to_audit_passed",
        "audit_passed_to_ready_for_user_review",
        "ready_for_user_review_to_resolved",
        "resolved_to_closed",
        "any_non_closed_to_blocked",
        "any_non_closed_to_stopped",
        "stopped_to_reentry_required",
        "reentry_required_to_retry_pending",
        "retry_pending_to_define"
    )
}

function Get-R17RequiredBlockedTransitionIds {
    return @(
        "intake_to_dev_running",
        "define_to_qa_running",
        "ready_for_dev_to_qa_running",
        "dev_running_to_audit_running",
        "dev_done_to_audit_running",
        "qa_failed_to_audit_running",
        "qa_failed_to_closed",
        "audit_failed_to_closed",
        "ready_for_user_review_to_closed_without_user_approval",
        "resolved_to_closed_without_user_approval",
        "closed_to_any_state",
        "any_state_to_closed_without_user_approval",
        "any_state_to_main_merge",
        "any_state_to_external_audit_acceptance"
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

function Get-R17RequiredClaimStatusFields {
    return @(
        "external_audit_acceptance_claimed",
        "main_merge_claimed",
        "r13_closure_claimed",
        "r14_caveat_removal_claimed",
        "r15_caveat_removal_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed"
    )
}

function Get-R17RequiredNonClaims {
    return @(
        "R17-010 defines and validates a bounded Orchestrator loop state machine only",
        "R17-010 creates generated state-machine, seed evaluation, and transition check artifacts only",
        "R17-010 performs deterministic non-executable transition evaluation only",
        "R17-010 does not implement Orchestrator runtime",
        "R17-010 does not implement live board mutation",
        "R17-010 does not implement A2A runtime",
        "R17-010 does not implement Dev/Codex executor adapter",
        "R17-010 does not implement QA/Test Agent adapter",
        "R17-010 does not implement Evidence Auditor API adapter",
        "R17-010 does not call external APIs",
        "R17-010 does not call Codex as executor",
        "R17-010 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders",
        "R17-010 does not claim autonomous agents",
        "R17-010 does not claim product runtime",
        "R17-010 does not claim production runtime",
        "R17-010 does not claim executable handoffs or executable transitions",
        "R17-010 does not claim external audit acceptance",
        "R17-010 does not claim main merge",
        "R13 boundary preserved",
        "R14 caveats preserved",
        "R15 caveats preserved",
        "R16 boundary preserved",
        "R17-011 through R17-028 remain planned only",
        "R17-010 does not claim solved Codex compaction",
        "R17-010 does not claim solved Codex reliability"
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

function Assert-R17CommonLoopDefinition {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Artifact,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($field in @(
            "source_milestone",
            "source_task",
            "repository",
            "branch",
            "scope",
            "purpose",
            "orchestrator_loop_states",
            "allowed_transitions",
            "blocked_transitions",
            "transition_requirements",
            "role_gate_requirements",
            "evidence_requirements",
            "user_approval_requirements",
            "stop_retry_reentry_states",
            "seed_evaluation_requirements",
            "non_claims",
            "rejected_claims",
            "runtime_boundaries",
            "preserved_boundaries"
        )) {
        Get-R17PropertyValue -InputObject $Artifact -PropertyName $field -Context $Context | Out-Null
    }

    if ($Artifact.source_task -ne "R17-010") {
        throw "$Context must be sourced from R17-010."
    }

    $stateIds = @(Get-R17Array -Value $Artifact.orchestrator_loop_states | ForEach-Object { $_.state_id })
    foreach ($requiredState in Get-R17RequiredLoopStates) {
        if ($stateIds -notcontains $requiredState) {
            throw "$Context is missing required state '$requiredState'."
        }
    }

    $allowedTransitionIds = @(Get-R17Array -Value $Artifact.allowed_transitions | ForEach-Object { $_.transition_id })
    foreach ($requiredTransitionId in Get-R17RequiredAllowedTransitionIds) {
        if ($allowedTransitionIds -notcontains $requiredTransitionId) {
            throw "$Context is missing required allowed transition '$requiredTransitionId'."
        }
    }

    foreach ($transition in Get-R17Array -Value $Artifact.allowed_transitions) {
        Assert-R17FalseField -InputObject $transition -PropertyName "executable_in_r17_010" -Context "$Context allowed transition '$($transition.transition_id)'"
    }

    $blockedTransitionIds = @(Get-R17Array -Value $Artifact.blocked_transitions | ForEach-Object { $_.transition_id })
    foreach ($requiredTransitionId in Get-R17RequiredBlockedTransitionIds) {
        if ($blockedTransitionIds -notcontains $requiredTransitionId) {
            throw "$Context is missing required blocked transition '$requiredTransitionId'."
        }
    }

    foreach ($field in @(
            "developer_execution_required_before_qa",
            "qa_pass_required_before_audit",
            "audit_pass_required_before_ready_for_user_review",
            "user_approval_required_before_closed",
            "orchestrator_may_recommend_transitions_but_r17_010_does_not_execute_transitions",
            "transition_evaluation_is_deterministic_and_non_executable",
            "route_recommendation_is_not_execution_proof",
            "handoff_recommendation_is_not_executable_handoff",
            "audit_request_is_not_audit_verdict",
            "board_state_remains_repo_backed_generated_state_not_live_mutation",
            "repo_truth_remains_canonical"
        )) {
        Assert-R17TrueField -InputObject $Artifact.transition_requirements -PropertyName $field -Context "$Context transition requirements"
    }

    Assert-R17TrueField -InputObject $Artifact.role_gate_requirements.developer_gate -PropertyName "developer_execution_required" -Context "$Context developer gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.developer_gate -PropertyName "dev_output_claim_allowed_in_r17_010" -Context "$Context developer gate"
    Assert-R17TrueField -InputObject $Artifact.role_gate_requirements.qa_gate -PropertyName "qa_pass_required" -Context "$Context QA gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.qa_gate -PropertyName "qa_result_claim_allowed_in_r17_010" -Context "$Context QA gate"
    Assert-R17TrueField -InputObject $Artifact.role_gate_requirements.audit_gate -PropertyName "audit_pass_required" -Context "$Context audit gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.audit_gate -PropertyName "audit_verdict_claim_allowed_in_r17_010" -Context "$Context audit gate"
    Assert-R17TrueField -InputObject $Artifact.role_gate_requirements.user_gate -PropertyName "explicit_user_approval_required" -Context "$Context user gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.orchestrator_gate -PropertyName "may_execute_transitions" -Context "$Context Orchestrator gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.orchestrator_gate -PropertyName "may_invoke_agents" -Context "$Context Orchestrator gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.orchestrator_gate -PropertyName "may_mutate_board" -Context "$Context Orchestrator gate"
    Assert-R17FalseField -InputObject $Artifact.role_gate_requirements.orchestrator_gate -PropertyName "may_call_external_apis" -Context "$Context Orchestrator gate"

    foreach ($field in @(
            "every_transition_evaluation_requires_state_machine_ref",
            "every_transition_evaluation_requires_card_or_route_ref",
            "ready_for_qa_requires_developer_execution_evidence",
            "audit_requires_qa_pass_evidence",
            "ready_for_user_review_requires_audit_pass_evidence",
            "closed_requires_user_approval_evidence"
        )) {
        Assert-R17TrueField -InputObject $Artifact.evidence_requirements -PropertyName $field -Context "$Context evidence requirements"
    }

    foreach ($field in @(
            "route_recommendations_are_execution_proof",
            "handoff_recommendations_are_executable_handoffs",
            "audit_requests_are_audit_verdicts",
            "generated_markdown_is_machine_proof_without_validation"
        )) {
        Assert-R17FalseField -InputObject $Artifact.evidence_requirements -PropertyName $field -Context "$Context evidence requirements"
    }

    foreach ($field in @(
            "closure_requires_user_approval",
            "resolved_is_not_closed",
            "ready_for_user_review_waits_for_user_decision",
            "main_merge_requires_user_approval_and_separate_evidence",
            "external_audit_acceptance_requires_external_evidence_and_user_acceptance",
            "orchestrator_may_request_user_approval",
            "orchestrator_may_not_substitute_for_user_approval"
        )) {
        Assert-R17TrueField -InputObject $Artifact.user_approval_requirements -PropertyName $field -Context "$Context user approval requirements"
    }

    Assert-R17TrueField -InputObject $Artifact.stop_retry_reentry_states.blocked -PropertyName "entry_from_any_non_closed_state_allowed" -Context "$Context blocked state"
    Assert-R17FalseField -InputObject $Artifact.stop_retry_reentry_states.blocked -PropertyName "runtime_unblock_implemented_in_r17_010" -Context "$Context blocked state"
    Assert-R17TrueField -InputObject $Artifact.stop_retry_reentry_states.stopped -PropertyName "entry_from_any_non_closed_state_allowed" -Context "$Context stopped state"
    Assert-R17FalseField -InputObject $Artifact.stop_retry_reentry_states.stopped -PropertyName "runtime_stop_control_implemented_in_r17_010" -Context "$Context stopped state"
    Assert-R17TrueField -InputObject $Artifact.stop_retry_reentry_states.reentry_required -PropertyName "requires_exact_repo_backed_packet_refs" -Context "$Context reentry state"
    Assert-R17TrueField -InputObject $Artifact.stop_retry_reentry_states.retry_pending -PropertyName "repeated_failure_requires_user_decision" -Context "$Context retry state"

    foreach ($field in Get-R17RequiredRuntimeBoundaryFields) {
        Assert-R17FalseField -InputObject $Artifact.runtime_boundaries -PropertyName $field -Context "$Context runtime boundaries"
    }

    $extended = Get-R17PropertyValue -InputObject $Artifact -PropertyName "runtime_boundaries_extended" -Context $Context
    foreach ($field in @(
            "board_state_replaces_repo_truth",
            "route_recommendation_is_execution_proof",
            "handoff_recommendation_is_executable_handoff",
            "audit_request_is_audit_verdict"
        )) {
        Assert-R17FalseField -InputObject $extended -PropertyName $field -Context "$Context extended runtime boundaries"
    }

    $claimStatus = Get-R17PropertyValue -InputObject $Artifact -PropertyName "claim_status" -Context $Context
    foreach ($field in Get-R17RequiredClaimStatusFields) {
        Assert-R17FalseField -InputObject $claimStatus -PropertyName $field -Context "$Context claim status"
    }

    $nonClaims = @(Get-R17Array -Value $Artifact.non_claims)
    foreach ($nonClaim in Get-R17RequiredNonClaims) {
        if ($nonClaims -notcontains $nonClaim) {
            throw "$Context is missing required non-claim '$nonClaim'."
        }
    }

    $rejectedClaims = @(Get-R17Array -Value $Artifact.rejected_claims)
    foreach ($rejectedClaim in Get-R17RequiredRejectedClaims) {
        if ($rejectedClaims -notcontains $rejectedClaim) {
            throw "$Context is missing required rejected claim '$rejectedClaim'."
        }
    }

    if ($Artifact.preserved_boundaries.r13.closed -ne $false) {
        throw "$Context must preserve R13 as not closed."
    }
    if ($Artifact.preserved_boundaries.r14.caveats_removed -ne $false) {
        throw "$Context must preserve R14 caveats."
    }
    if ($Artifact.preserved_boundaries.r15.caveats_removed -ne $false) {
        throw "$Context must preserve R15 caveats."
    }

    foreach ($field in @(
            "external_audit_acceptance_claimed",
            "main_merge_completed",
            "product_runtime_implemented",
            "a2a_runtime_implemented",
            "autonomous_agents_implemented",
            "solved_codex_compaction",
            "solved_codex_reliability"
        )) {
        Assert-R17FalseField -InputObject $Artifact.preserved_boundaries.r16 -PropertyName $field -Context "$Context R16 preserved boundary"
    }
}

function Test-R17OrchestratorLoopStateMachineContract {
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [string]$Path = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $contract = if ($PSBoundParameters.ContainsKey("InputObject")) { $InputObject } else { Read-R17OrchestratorLoopJson -Path $Path -RepositoryRoot $RepositoryRoot }
    if ($contract.artifact_type -ne "r17_orchestrator_loop_state_machine_contract") {
        throw "Contract artifact_type must be r17_orchestrator_loop_state_machine_contract."
    }
    if ($contract.contract_id -ne "aioffice-r17-010-orchestrator-loop-state-machine-contract-v1") {
        throw "Contract id is not the R17-010 Orchestrator loop state-machine contract id."
    }

    Assert-R17CommonLoopDefinition -Artifact $contract -Context "R17-010 contract"
    return [pscustomobject]@{
        Status = "passed"
        Artifact = "contract"
    }
}

function New-R17OrchestratorLoopStateMachine {
    [CmdletBinding()]
    param(
        [object]$Contract,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    if ($null -eq $Contract) {
        $Contract = Read-R17OrchestratorLoopJson -Path "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json" -RepositoryRoot $RepositoryRoot
    }

    Test-R17OrchestratorLoopStateMachineContract -InputObject $Contract | Out-Null
    $head = Get-R17GitValue -Argument "HEAD" -RepositoryRoot $RepositoryRoot
    $tree = Get-R17GitValue -Argument "HEAD^{tree}" -RepositoryRoot $RepositoryRoot

    return [ordered]@{
        artifact_type = "r17_orchestrator_loop_state_machine"
        contract_version = $Contract.contract_version
        state_id = "aioffice-r17-010-orchestrator-loop-state-machine-state-v1"
        source_milestone = $Contract.source_milestone
        source_task = $Contract.source_task
        repository = $Contract.repository
        branch = $Contract.branch
        generated_from_head = $head
        generated_from_tree = $tree
        generated_from_contract = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"
        generated_state_artifact_only = $true
        scope = $Contract.scope
        purpose = $Contract.purpose
        orchestrator_loop_states = @(Get-R17Array -Value $Contract.orchestrator_loop_states)
        allowed_transitions = @(Get-R17Array -Value $Contract.allowed_transitions)
        blocked_transitions = @(Get-R17Array -Value $Contract.blocked_transitions)
        transition_requirements = $Contract.transition_requirements
        role_gate_requirements = $Contract.role_gate_requirements
        evidence_requirements = $Contract.evidence_requirements
        user_approval_requirements = $Contract.user_approval_requirements
        stop_retry_reentry_states = $Contract.stop_retry_reentry_states
        seed_evaluation_requirements = $Contract.seed_evaluation_requirements
        non_claims = @(Get-R17Array -Value $Contract.non_claims)
        rejected_claims = @(Get-R17Array -Value $Contract.rejected_claims)
        runtime_boundaries = $Contract.runtime_boundaries
        claim_status = $Contract.claim_status
        runtime_boundaries_extended = $Contract.runtime_boundaries_extended
        preserved_boundaries = $Contract.preserved_boundaries
    }
}

function Test-R17OrchestratorLoopStateMachine {
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [string]$Path = "state/orchestration/r17_orchestrator_loop_state_machine.json",
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $stateMachine = if ($PSBoundParameters.ContainsKey("InputObject")) { $InputObject } else { Read-R17OrchestratorLoopJson -Path $Path -RepositoryRoot $RepositoryRoot }
    if ($stateMachine.artifact_type -ne "r17_orchestrator_loop_state_machine") {
        throw "State-machine artifact_type must be r17_orchestrator_loop_state_machine."
    }
    Assert-R17TrueField -InputObject $stateMachine -PropertyName "generated_state_artifact_only" -Context "R17-010 state-machine artifact"
    Assert-R17CommonLoopDefinition -Artifact $stateMachine -Context "R17-010 state-machine artifact"
    return [pscustomobject]@{
        Status = "passed"
        Artifact = "state_machine"
    }
}

function Test-R17TransitionAllowedMatch {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Transition,
        [Parameter(Mandatory = $true)]
        [string]$FromState,
        [Parameter(Mandatory = $true)]
        [string]$ToState
    )

    $selector = $Transition.PSObject.Properties["from_state_selector"]
    if ($null -ne $selector -and $selector.Value -eq "any_non_closed_state") {
        return ($FromState -ne "closed" -and $Transition.to_state -eq $ToState)
    }

    return ($Transition.from_state -eq $FromState -and $Transition.to_state -eq $ToState)
}

function Test-R17BlockedTransitionMatch {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Transition,
        [Parameter(Mandatory = $true)]
        [string]$FromState,
        [Parameter(Mandatory = $true)]
        [string]$ToState,
        [bool]$UserApprovalPresent
    )

    $condition = $Transition.PSObject.Properties["condition"]
    if ($null -ne $condition -and $condition.Value -eq "without_user_approval" -and $UserApprovalPresent) {
        return $false
    }

    $fromMatches = $false
    $fromSelector = $Transition.PSObject.Properties["from_state_selector"]
    if ($null -ne $fromSelector -and $fromSelector.Value -eq "any_state") {
        $fromMatches = $true
    }
    else {
        $fromMatches = ($Transition.from_state -eq $FromState)
    }

    $toMatches = $false
    $toSelector = $Transition.PSObject.Properties["to_state_selector"]
    if ($null -ne $toSelector -and $toSelector.Value -eq "any_state") {
        $toMatches = $true
    }
    else {
        $toMatches = ($Transition.to_state -eq $ToState)
    }

    return ($fromMatches -and $toMatches)
}

function Get-R17CandidateEvidenceValue {
    param(
        [object]$Candidate,
        [string]$PropertyName
    )

    $evidenceProperty = $Candidate.PSObject.Properties["evidence"]
    if ($null -eq $evidenceProperty -or $null -eq $evidenceProperty.Value) {
        return $false
    }

    $valueProperty = $evidenceProperty.Value.PSObject.Properties[$PropertyName]
    if ($null -eq $valueProperty) {
        return $false
    }

    return $valueProperty.Value
}

function Test-R17OrchestratorLoopTransitionCandidate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$StateMachine,
        [Parameter(Mandatory = $true)]
        [object]$Candidate
    )

    Test-R17OrchestratorLoopStateMachine -InputObject $StateMachine | Out-Null

    $fromState = Get-R17PropertyValue -InputObject $Candidate -PropertyName "from_state" -Context "transition candidate"
    $toState = Get-R17PropertyValue -InputObject $Candidate -PropertyName "to_state" -Context "transition candidate"
    $approvalProperty = $Candidate.PSObject.Properties["user_approval_present"]
    $userApprovalPresent = ($null -ne $approvalProperty -and $approvalProperty.Value -eq $true)

    $transitionExecutedProperty = $Candidate.PSObject.Properties["transition_executed"]
    if ($null -ne $transitionExecutedProperty -and $transitionExecutedProperty.Value -eq $true) {
        throw "Transition candidate claims transition execution; R17-010 evaluation is non-executable."
    }

    $stateIds = @(Get-R17Array -Value $StateMachine.orchestrator_loop_states | ForEach-Object { $_.state_id })
    if ($stateIds -notcontains $fromState) {
        throw "Transition candidate uses unknown from_state '$fromState'."
    }

    if ($toState -eq "main_merge") {
        throw "Transition to main_merge is forbidden by the Orchestrator loop state machine."
    }
    if ($toState -eq "external_audit_acceptance") {
        throw "Transition to external_audit_acceptance is forbidden by the Orchestrator loop state machine."
    }
    if ($stateIds -notcontains $toState) {
        throw "Transition candidate uses unknown to_state '$toState'."
    }

    if ($fromState -eq "closed") {
        throw "Closed is terminal; closed-to-active transitions are forbidden."
    }
    if ($toState -eq "closed" -and -not $userApprovalPresent) {
        throw "User approval is required before closed."
    }
    if ($toState -eq "qa_running" -and (Get-R17CandidateEvidenceValue -Candidate $Candidate -PropertyName "developer_execution_completed") -ne $true) {
        throw "Developer execution is required before QA."
    }
    if ($toState -eq "audit_running" -and (Get-R17CandidateEvidenceValue -Candidate $Candidate -PropertyName "qa_passed") -ne $true) {
        throw "QA pass is required before audit."
    }
    if ($toState -eq "ready_for_user_review" -and (Get-R17CandidateEvidenceValue -Candidate $Candidate -PropertyName "audit_passed") -ne $true) {
        throw "Audit pass is required before ready_for_user_review."
    }

    foreach ($blockedTransition in Get-R17Array -Value $StateMachine.blocked_transitions) {
        if (Test-R17BlockedTransitionMatch -Transition $blockedTransition -FromState $fromState -ToState $toState -UserApprovalPresent:$userApprovalPresent) {
            throw "Blocked transition '$($blockedTransition.transition_id)' failed closed: $($blockedTransition.reason)"
        }
    }

    $allowed = $false
    foreach ($allowedTransition in Get-R17Array -Value $StateMachine.allowed_transitions) {
        if (Test-R17TransitionAllowedMatch -Transition $allowedTransition -FromState $fromState -ToState $toState) {
            $allowed = $true
            break
        }
    }

    if (-not $allowed) {
        throw "Transition '$fromState -> $toState' is not an allowed Orchestrator loop transition."
    }

    return [pscustomobject]@{
        Status = "passed"
        FromState = $fromState
        ToState = $toState
        TransitionExecuted = $false
    }
}

function New-R17OrchestratorLoopSeedEvaluation {
    [CmdletBinding()]
    param(
        [object]$StateMachine,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    if ($null -eq $StateMachine) {
        $StateMachine = Read-R17OrchestratorLoopJson -Path "state/orchestration/r17_orchestrator_loop_state_machine.json" -RepositoryRoot $RepositoryRoot
    }

    Test-R17OrchestratorLoopStateMachine -InputObject $StateMachine | Out-Null

    $seedCard = Read-R17OrchestratorLoopJson -Path "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json" -RepositoryRoot $RepositoryRoot
    $routeSeed = Read-R17OrchestratorLoopJson -Path "state/agents/r17_orchestrator_route_recommendation_seed.json" -RepositoryRoot $RepositoryRoot
    $authorityReport = Read-R17OrchestratorLoopJson -Path "state/agents/r17_orchestrator_authority_check_report.json" -RepositoryRoot $RepositoryRoot
    $boardState = Read-R17OrchestratorLoopJson -Path "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json" -RepositoryRoot $RepositoryRoot
    $replayReport = Read-R17OrchestratorLoopJson -Path "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json" -RepositoryRoot $RepositoryRoot

    $currentLane = $routeSeed.current_lane
    return [ordered]@{
        artifact_type = "r17_orchestrator_loop_seed_evaluation"
        contract_version = "v1"
        evaluation_id = "aioffice-r17-010-orchestrator-loop-seed-evaluation-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-010"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_contract = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"
        generated_from_state_machine = "state/orchestration/r17_orchestrator_loop_state_machine.json"
        source_card_id = $routeSeed.source_card_id
        source_card_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json"
        source_route_recommendation_ref = "state/agents/r17_orchestrator_route_recommendation_seed.json"
        source_authority_check_report_ref = "state/agents/r17_orchestrator_authority_check_report.json"
        current_card_lane = $currentLane
        current_loop_state = "ready_for_user_review"
        recommended_next_loop_state = "ready_for_user_review"
        recommended_next_action = $routeSeed.recommended_next_action
        recommended_next_role = $routeSeed.recommended_next_role
        user_decision_required = $true
        closure_requires_user_approval = $true
        transition_executed = $false
        board_mutation_performed = $false
        runtime_orchestrator_invoked = $false
        agent_invocation_performed = $false
        a2a_message_sent = $false
        api_call_performed = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
        non_executable_evaluation = $true
        deterministic_evaluation_only = $true
        route_recommendation_is_execution_proof = $false
        handoff_recommendation_is_executable_handoff = $false
        audit_request_is_audit_verdict = $false
        board_state_compatibility = [ordered]@{
            source_card_lane_from_board_state = @($boardState.card_refs | Where-Object { $_.card_id -eq "R17-005" } | Select-Object -First 1).lane
            source_card_final_lane_from_replay = $replayReport.final_lane_by_card."R17-005"
            source_card_initial_lane = $seedCard.lane
            current_lane_matches_route_seed = ($currentLane -eq "ready_for_user_review")
            repo_backed_generated_state_only = $true
        }
        orchestrator_authority_compatibility = [ordered]@{
            authority_report = "state/agents/r17_orchestrator_authority_check_report.json"
            authority_report_verdict = $authorityReport.aggregate_verdict
            route_seed_non_executable = $routeSeed.non_executable_recommendation
            authority_runtime_invocation_performed = $false
            compatible = $true
        }
        evidence_refs = @(
            "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
            "state/orchestration/r17_orchestrator_loop_state_machine.json",
            "state/agents/r17_orchestrator_route_recommendation_seed.json",
            "state/agents/r17_orchestrator_authority_check_report.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json"
        )
        non_claims = @(Get-R17RequiredNonClaims)
        rejected_claims = @(Get-R17RequiredRejectedClaims)
    }
}

function Test-R17OrchestratorLoopSeedEvaluation {
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [string]$Path = "state/orchestration/r17_orchestrator_loop_seed_evaluation.json",
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $evaluation = if ($PSBoundParameters.ContainsKey("InputObject")) { $InputObject } else { Read-R17OrchestratorLoopJson -Path $Path -RepositoryRoot $RepositoryRoot }
    if ($evaluation.artifact_type -ne "r17_orchestrator_loop_seed_evaluation") {
        throw "Seed evaluation artifact_type must be r17_orchestrator_loop_seed_evaluation."
    }
    if ($evaluation.source_task -ne "R17-010") {
        throw "Seed evaluation must be sourced from R17-010."
    }
    if ($evaluation.source_card_id -ne "R17-005") {
        throw "Seed evaluation must evaluate source card R17-005."
    }
    if ($evaluation.current_card_lane -ne "ready_for_user_review") {
        throw "Seed evaluation must keep current_card_lane ready_for_user_review."
    }
    if ($evaluation.current_loop_state -ne "ready_for_user_review") {
        throw "Seed evaluation must keep current_loop_state ready_for_user_review."
    }
    if ($evaluation.recommended_next_loop_state -ne "ready_for_user_review") {
        throw "Seed evaluation must recommend ready_for_user_review pending user decision."
    }
    if ($evaluation.recommended_next_action -ne "request_user_review_or_closure_decision") {
        throw "Seed evaluation must recommend request_user_review_or_closure_decision."
    }
    if ($evaluation.recommended_next_role -ne "user") {
        throw "Seed evaluation must recommend user as next role."
    }

    foreach ($field in @("user_decision_required", "closure_requires_user_approval", "non_executable_evaluation", "deterministic_evaluation_only")) {
        Assert-R17TrueField -InputObject $evaluation -PropertyName $field -Context "R17-010 seed evaluation"
    }

    foreach ($field in @(
            "transition_executed",
            "board_mutation_performed",
            "runtime_orchestrator_invoked",
            "agent_invocation_performed",
            "a2a_message_sent",
            "api_call_performed",
            "dev_output_claimed",
            "qa_result_claimed",
            "audit_verdict_claimed",
            "route_recommendation_is_execution_proof",
            "handoff_recommendation_is_executable_handoff",
            "audit_request_is_audit_verdict"
        )) {
        Assert-R17FalseField -InputObject $evaluation -PropertyName $field -Context "R17-010 seed evaluation"
    }

    if ($evaluation.orchestrator_authority_compatibility.compatible -ne $true) {
        throw "Seed evaluation must be compatible with the R17-009 Orchestrator authority check report."
    }
    if ($evaluation.board_state_compatibility.repo_backed_generated_state_only -ne $true) {
        throw "Seed evaluation must preserve repo-backed generated board state only."
    }

    $nonClaims = @(Get-R17Array -Value $evaluation.non_claims)
    foreach ($nonClaim in Get-R17RequiredNonClaims) {
        if ($nonClaims -notcontains $nonClaim) {
            throw "Seed evaluation is missing required non-claim '$nonClaim'."
        }
    }

    $rejectedClaims = @(Get-R17Array -Value $evaluation.rejected_claims)
    foreach ($rejectedClaim in Get-R17RequiredRejectedClaims) {
        if ($rejectedClaims -notcontains $rejectedClaim) {
            throw "Seed evaluation is missing required rejected claim '$rejectedClaim'."
        }
    }

    return [pscustomobject]@{
        Status = "passed"
        Artifact = "seed_evaluation"
        CurrentLoopState = $evaluation.current_loop_state
        RecommendedNextLoopState = $evaluation.recommended_next_loop_state
        RecommendedNextAction = $evaluation.recommended_next_action
    }
}

function New-R17OrchestratorLoopTransitionCheckReport {
    [CmdletBinding()]
    param(
        [object]$StateMachine,
        [object]$SeedEvaluation,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    if ($null -eq $StateMachine) {
        $StateMachine = Read-R17OrchestratorLoopJson -Path "state/orchestration/r17_orchestrator_loop_state_machine.json" -RepositoryRoot $RepositoryRoot
    }
    if ($null -eq $SeedEvaluation) {
        $SeedEvaluation = Read-R17OrchestratorLoopJson -Path "state/orchestration/r17_orchestrator_loop_seed_evaluation.json" -RepositoryRoot $RepositoryRoot
    }

    Test-R17OrchestratorLoopStateMachine -InputObject $StateMachine | Out-Null
    Test-R17OrchestratorLoopSeedEvaluation -InputObject $SeedEvaluation | Out-Null

    return [ordered]@{
        artifact_type = "r17_orchestrator_loop_transition_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-010-orchestrator-loop-transition-check-report-v1"
        source_milestone = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
        source_task = "R17-010"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
        generated_from_contract = "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json"
        checked_artifacts = @(
            "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
            "state/orchestration/r17_orchestrator_loop_state_machine.json",
            "state/orchestration/r17_orchestrator_loop_seed_evaluation.json",
            "state/agents/r17_orchestrator_identity_authority.json",
            "state/agents/r17_orchestrator_route_recommendation_seed.json",
            "state/agents/r17_orchestrator_authority_check_report.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json"
        )
        checks = [ordered]@{
            loop_states = [ordered]@{ status = "passed" }
            allowed_transitions = [ordered]@{ status = "passed" }
            blocked_transitions = [ordered]@{ status = "passed" }
            transition_requirements = [ordered]@{ status = "passed" }
            user_approval_before_closed = [ordered]@{ status = "passed" }
            qa_pass_before_audit = [ordered]@{ status = "passed" }
            audit_pass_before_ready_for_user_review = [ordered]@{ status = "passed" }
            seed_evaluation = [ordered]@{ status = "passed" }
            orchestrator_authority_compatibility = [ordered]@{ status = "passed" }
            board_card_compatibility = [ordered]@{ status = "passed" }
            non_claims = [ordered]@{ status = "passed" }
            rejected_claims = [ordered]@{ status = "passed" }
            r13_r14_r15_r16_boundary_preservation = [ordered]@{ status = "passed" }
            runtime_boundaries = [ordered]@{ status = "passed" }
        }
        aggregate_verdict = "generated_r17_orchestrator_loop_state_machine_candidate"
        current_loop_state = $SeedEvaluation.current_loop_state
        recommended_next_loop_state = $SeedEvaluation.recommended_next_loop_state
        recommended_next_action = $SeedEvaluation.recommended_next_action
        user_decision_required = $SeedEvaluation.user_decision_required
        non_claims = @(Get-R17RequiredNonClaims)
        rejected_claims = @(Get-R17RequiredRejectedClaims)
        runtime_boundaries = $StateMachine.runtime_boundaries
        preserved_boundaries = $StateMachine.preserved_boundaries
    }
}

function Test-R17OrchestratorLoopTransitionCheckReport {
    [CmdletBinding()]
    param(
        [object]$InputObject,
        [string]$Path = "state/orchestration/r17_orchestrator_loop_transition_check_report.json",
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $report = if ($PSBoundParameters.ContainsKey("InputObject")) { $InputObject } else { Read-R17OrchestratorLoopJson -Path $Path -RepositoryRoot $RepositoryRoot }
    if ($report.artifact_type -ne "r17_orchestrator_loop_transition_check_report") {
        throw "Transition check report artifact_type must be r17_orchestrator_loop_transition_check_report."
    }
    if ($report.aggregate_verdict -ne "generated_r17_orchestrator_loop_state_machine_candidate") {
        throw "Transition check report aggregate verdict must be generated_r17_orchestrator_loop_state_machine_candidate."
    }

    foreach ($checkName in @(
            "loop_states",
            "allowed_transitions",
            "blocked_transitions",
            "transition_requirements",
            "user_approval_before_closed",
            "qa_pass_before_audit",
            "audit_pass_before_ready_for_user_review",
            "seed_evaluation",
            "orchestrator_authority_compatibility",
            "board_card_compatibility",
            "non_claims",
            "rejected_claims",
            "r13_r14_r15_r16_boundary_preservation",
            "runtime_boundaries"
        )) {
        $check = Get-R17PropertyValue -InputObject $report.checks -PropertyName $checkName -Context "transition check report checks"
        if ($check.status -ne "passed") {
            throw "Transition check report check '$checkName' must be passed."
        }
    }

    if ($report.current_loop_state -ne "ready_for_user_review") {
        throw "Transition check report must record current loop state ready_for_user_review."
    }
    if ($report.recommended_next_loop_state -ne "ready_for_user_review") {
        throw "Transition check report must record recommended next loop state ready_for_user_review."
    }
    if ($report.recommended_next_action -ne "request_user_review_or_closure_decision") {
        throw "Transition check report must record request_user_review_or_closure_decision."
    }
    if ($report.user_decision_required -ne $true) {
        throw "Transition check report must record user_decision_required true."
    }

    return [pscustomobject]@{
        Status = "passed"
        Artifact = "transition_check_report"
        AggregateVerdict = $report.aggregate_verdict
    }
}

function New-R17OrchestratorLoopInvalidFixtureDefinitions {
    $transition = "transition"
    $machine = "state_machine"
    $seed = "seed_evaluation"

    return @(
        @{ name = "invalid_missing_state"; target = $machine; mutation = @{ kind = "remove_state"; state_id = "qa_passed" } },
        @{ name = "invalid_missing_allowed_transition"; target = $machine; mutation = @{ kind = "remove_allowed_transition"; transition_id = "qa_passed_to_audit_running" } },
        @{ name = "invalid_missing_blocked_transition"; target = $machine; mutation = @{ kind = "remove_blocked_transition"; transition_id = "intake_to_dev_running" } },
        @{ name = "invalid_close_without_user_approval"; target = $transition; candidate = @{ from_state = "resolved"; to_state = "closed"; user_approval_present = $false; evidence = @{ explicit_user_closure_approval_ref = $false } } },
        @{ name = "invalid_qa_before_dev"; target = $transition; candidate = @{ from_state = "define"; to_state = "qa_running"; user_approval_present = $false; evidence = @{ developer_execution_completed = $false } } },
        @{ name = "invalid_audit_before_qa_pass"; target = $transition; candidate = @{ from_state = "dev_done"; to_state = "audit_running"; user_approval_present = $false; evidence = @{ qa_passed = $false } } },
        @{ name = "invalid_ready_for_user_review_without_audit_pass"; target = $transition; candidate = @{ from_state = "audit_running"; to_state = "ready_for_user_review"; user_approval_present = $false; evidence = @{ audit_passed = $false } } },
        @{ name = "invalid_closed_to_active_transition"; target = $transition; candidate = @{ from_state = "closed"; to_state = "define"; user_approval_present = $true; evidence = @{} } },
        @{ name = "invalid_main_merge_transition"; target = $transition; candidate = @{ from_state = "ready_for_user_review"; to_state = "main_merge"; user_approval_present = $true; evidence = @{} } },
        @{ name = "invalid_external_audit_acceptance_transition"; target = $transition; candidate = @{ from_state = "audit_passed"; to_state = "external_audit_acceptance"; user_approval_present = $true; evidence = @{} } },
        @{ name = "invalid_transition_executed_claim"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "transition_executed"; value = $true } },
        @{ name = "invalid_board_mutation_performed"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "board_mutation_performed"; value = $true } },
        @{ name = "invalid_orchestrator_runtime_invoked"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "runtime_orchestrator_invoked"; value = $true } },
        @{ name = "invalid_agent_invocation_performed"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "agent_invocation_performed"; value = $true } },
        @{ name = "invalid_a2a_message_sent"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "a2a_message_sent"; value = $true } },
        @{ name = "invalid_api_call_performed"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "api_call_performed"; value = $true } },
        @{ name = "invalid_dev_output_claim"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "dev_output_claimed"; value = $true } },
        @{ name = "invalid_qa_result_claim"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "qa_result_claimed"; value = $true } },
        @{ name = "invalid_audit_verdict_claim"; target = $seed; mutation = @{ kind = "set_seed_flag"; field = "audit_verdict_claimed"; value = $true } },
        @{ name = "invalid_live_board_mutation_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "live_board_mutation_implemented"; value = $true } },
        @{ name = "invalid_orchestrator_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "orchestrator_runtime_implemented"; value = $true } },
        @{ name = "invalid_a2a_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "a2a_runtime_implemented"; value = $true } },
        @{ name = "invalid_autonomous_agent_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "autonomous_agents_implemented"; value = $true } },
        @{ name = "invalid_dev_codex_adapter_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "dev_codex_adapter_runtime_implemented"; value = $true } },
        @{ name = "invalid_qa_adapter_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "qa_test_agent_adapter_runtime_implemented"; value = $true } },
        @{ name = "invalid_evidence_auditor_api_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "evidence_auditor_api_runtime_implemented"; value = $true } },
        @{ name = "invalid_executable_handoff_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "executable_handoffs_implemented"; value = $true } },
        @{ name = "invalid_executable_transition_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "executable_transitions_implemented"; value = $true } },
        @{ name = "invalid_product_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "product_runtime_implemented"; value = $true } },
        @{ name = "invalid_production_runtime_claim"; target = $machine; mutation = @{ kind = "set_runtime_boundary"; field = "production_runtime_implemented"; value = $true } },
        @{ name = "invalid_external_audit_acceptance_claim"; target = $machine; mutation = @{ kind = "set_claim_status"; field = "external_audit_acceptance_claimed"; value = $true } },
        @{ name = "invalid_main_merge_claim"; target = $machine; mutation = @{ kind = "set_claim_status"; field = "main_merge_claimed"; value = $true } },
        @{ name = "invalid_r13_closure_claim"; target = $machine; mutation = @{ kind = "set_preserved_boundary"; boundary = "r13"; field = "closed"; value = $true } },
        @{ name = "invalid_r14_caveat_removal_claim"; target = $machine; mutation = @{ kind = "set_preserved_boundary"; boundary = "r14"; field = "caveats_removed"; value = $true } },
        @{ name = "invalid_r15_caveat_removal_claim"; target = $machine; mutation = @{ kind = "set_preserved_boundary"; boundary = "r15"; field = "caveats_removed"; value = $true } },
        @{ name = "invalid_solved_codex_compaction_claim"; target = $machine; mutation = @{ kind = "set_claim_status"; field = "solved_codex_compaction_claimed"; value = $true } },
        @{ name = "invalid_solved_codex_reliability_claim"; target = $machine; mutation = @{ kind = "set_claim_status"; field = "solved_codex_reliability_claimed"; value = $true } }
    )
}

function New-R17OrchestratorLoopFixtureSet {
    [CmdletBinding()]
    param(
        [object]$StateMachine,
        [object]$SeedEvaluation,
        [object]$TransitionCheckReport,
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $fixtureRoot = "tests/fixtures/r17_orchestrator_loop_state_machine"
    Write-R17OrchestratorLoopJson -InputObject $StateMachine -Path (Join-Path $fixtureRoot "valid_orchestrator_loop_state_machine.json") -RepositoryRoot $RepositoryRoot
    Write-R17OrchestratorLoopJson -InputObject $SeedEvaluation -Path (Join-Path $fixtureRoot "valid_seed_evaluation.json") -RepositoryRoot $RepositoryRoot
    Write-R17OrchestratorLoopJson -InputObject $TransitionCheckReport -Path (Join-Path $fixtureRoot "valid_transition_check_report.json") -RepositoryRoot $RepositoryRoot

    foreach ($definition in New-R17OrchestratorLoopInvalidFixtureDefinitions) {
        $fixture = [ordered]@{
            artifact_type = "r17_orchestrator_loop_state_machine_invalid_fixture"
            fixture_id = $definition.name
            source_task = "R17-010"
            target = $definition.target
            compact_fixture = $true
            expected_result = "rejected"
        }
        if ($definition.ContainsKey("mutation")) {
            $fixture["mutation"] = $definition.mutation
        }
        if ($definition.ContainsKey("candidate")) {
            $fixture["candidate"] = $definition.candidate
        }

        Write-R17OrchestratorLoopJson -InputObject $fixture -Path (Join-Path $fixtureRoot ($definition.name + ".json")) -RepositoryRoot $RepositoryRoot
    }
}

function Apply-R17InvalidFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Artifact,
        [Parameter(Mandatory = $true)]
        [object]$Mutation
    )

    switch ($Mutation.kind) {
        "remove_state" {
            $Artifact.orchestrator_loop_states = @(Get-R17Array -Value $Artifact.orchestrator_loop_states | Where-Object { $_.state_id -ne $Mutation.state_id })
        }
        "remove_allowed_transition" {
            $Artifact.allowed_transitions = @(Get-R17Array -Value $Artifact.allowed_transitions | Where-Object { $_.transition_id -ne $Mutation.transition_id })
        }
        "remove_blocked_transition" {
            $Artifact.blocked_transitions = @(Get-R17Array -Value $Artifact.blocked_transitions | Where-Object { $_.transition_id -ne $Mutation.transition_id })
        }
        "set_runtime_boundary" {
            $Artifact.runtime_boundaries.($Mutation.field) = $Mutation.value
        }
        "set_claim_status" {
            $Artifact.claim_status.($Mutation.field) = $Mutation.value
        }
        "set_preserved_boundary" {
            $Artifact.preserved_boundaries.($Mutation.boundary).($Mutation.field) = $Mutation.value
        }
        "set_seed_flag" {
            $Artifact.($Mutation.field) = $Mutation.value
        }
        default {
            throw "Unsupported invalid fixture mutation kind '$($Mutation.kind)'."
        }
    }

    return $Artifact
}

function Test-R17OrchestratorLoopFixture {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$FixtureRoot = "tests/fixtures/r17_orchestrator_loop_state_machine",
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $fixture = Read-R17OrchestratorLoopJson -Path $Path -RepositoryRoot $RepositoryRoot
    if ($fixture.artifact_type -ne "r17_orchestrator_loop_state_machine_invalid_fixture") {
        throw "Fixture '$Path' must be a compact invalid R17-010 fixture."
    }

    switch ($fixture.target) {
        "state_machine" {
            $valid = Read-R17OrchestratorLoopJson -Path (Join-Path $FixtureRoot "valid_orchestrator_loop_state_machine.json") -RepositoryRoot $RepositoryRoot
            $candidate = Apply-R17InvalidFixtureMutation -Artifact (Copy-R17JsonObject -InputObject $valid) -Mutation $fixture.mutation
            Test-R17OrchestratorLoopStateMachine -InputObject $candidate | Out-Null
        }
        "seed_evaluation" {
            $valid = Read-R17OrchestratorLoopJson -Path (Join-Path $FixtureRoot "valid_seed_evaluation.json") -RepositoryRoot $RepositoryRoot
            $candidate = Apply-R17InvalidFixtureMutation -Artifact (Copy-R17JsonObject -InputObject $valid) -Mutation $fixture.mutation
            Test-R17OrchestratorLoopSeedEvaluation -InputObject $candidate | Out-Null
        }
        "transition" {
            $valid = Read-R17OrchestratorLoopJson -Path (Join-Path $FixtureRoot "valid_orchestrator_loop_state_machine.json") -RepositoryRoot $RepositoryRoot
            Test-R17OrchestratorLoopTransitionCandidate -StateMachine $valid -Candidate $fixture.candidate | Out-Null
        }
        default {
            throw "Unsupported invalid fixture target '$($fixture.target)'."
        }
    }
}

function New-R17OrchestratorLoopProofReviewPackage {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot),
        [string]$ValidationStatus = "pending/generated",
        [string[]]$ValidationCommands = @()
    )

    $proofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_010_orchestrator_loop_state_machine"
    $proofReview = @"
# R17-010 Orchestrator Loop State Machine Proof Review

Status: $ValidationStatus

R17-010 defines and validates a bounded Orchestrator loop state machine only. It creates generated state-machine, seed evaluation, and transition check artifacts only.

This is deterministic non-executable transition evaluation for the existing R17-005 seed card and R17-009 Orchestrator route recommendation/authority artifacts. It does not implement Orchestrator runtime, live board mutation, A2A runtime, Dev/Codex executor adapter, QA/Test Agent adapter, Evidence Auditor API adapter, external API calls, Codex executor calls, autonomous agents, product runtime, production runtime, executable handoffs, executable transitions, external audit acceptance, main merge, or real Dev/QA/Audit outputs.

R13, R14, R15, and R16 boundaries are preserved. R17 is active through R17-010 only, and R17-011 through R17-028 remain planned only.

## Evidence

- contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json
- state/orchestration/r17_orchestrator_loop_state_machine.json
- state/orchestration/r17_orchestrator_loop_seed_evaluation.json
- state/orchestration/r17_orchestrator_loop_transition_check_report.json
- tools/R17OrchestratorLoopStateMachine.psm1
- tools/new_r17_orchestrator_loop_state_machine.ps1
- tools/validate_r17_orchestrator_loop_state_machine.ps1
- tests/test_r17_orchestrator_loop_state_machine.ps1
- tests/fixtures/r17_orchestrator_loop_state_machine/

## Non-Claims

- R17-010 does not implement Orchestrator runtime.
- R17-010 does not implement live board mutation.
- R17-010 does not implement A2A runtime.
- R17-010 does not implement Dev/Codex executor adapter.
- R17-010 does not implement QA/Test Agent adapter.
- R17-010 does not implement Evidence Auditor API adapter.
- R17-010 does not call external APIs.
- R17-010 does not call Codex as executor.
- R17-010 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders.
- R17-010 does not claim autonomous agents.
- R17-010 does not implement external integrations.
- R17-010 does not claim product runtime.
- R17-010 does not claim production runtime.
- R17-010 does not claim executable handoffs or executable transitions.
- R17-010 does not claim external audit acceptance.
- R17-010 does not claim main merge.
- R13, R14, R15, and R16 boundaries are preserved.
"@

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_010_proof_review_evidence_index"
        source_task = "R17-010"
        status = $ValidationStatus
        evidence_refs = @(
            "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
            "state/orchestration/r17_orchestrator_loop_state_machine.json",
            "state/orchestration/r17_orchestrator_loop_seed_evaluation.json",
            "state/orchestration/r17_orchestrator_loop_transition_check_report.json",
            "tools/R17OrchestratorLoopStateMachine.psm1",
            "tools/new_r17_orchestrator_loop_state_machine.ps1",
            "tools/validate_r17_orchestrator_loop_state_machine.ps1",
            "tests/test_r17_orchestrator_loop_state_machine.ps1",
            "tests/fixtures/r17_orchestrator_loop_state_machine/"
        )
        aggregate_verdict = "generated_r17_orchestrator_loop_state_machine_candidate"
        current_loop_state = "ready_for_user_review"
        recommended_next_loop_state = "ready_for_user_review"
        recommended_next_action = "request_user_review_or_closure_decision"
        transition_executed = $false
        board_mutation_performed = $false
        runtime_orchestrator_invoked = $false
        agent_invocation_performed = $false
        a2a_message_sent = $false
        api_call_performed = $false
        dev_output_claimed = $false
        qa_result_claimed = $false
        audit_verdict_claimed = $false
        non_claims = @(Get-R17RequiredNonClaims)
        rejected_claims = @(Get-R17RequiredRejectedClaims)
    }

    $manifestCommands = if ($ValidationCommands.Count -eq 0) {
        "- Pending validation commands will be recorded after validation passes."
    }
    else {
        ($ValidationCommands | ForEach-Object { "- ``$_``: passed" }) -join [Environment]::NewLine
    }

    $validationManifest = @"
# R17-010 Validation Manifest

Status: $ValidationStatus

## Commands

$manifestCommands

## Boundary

R17-010 defines and validates a bounded Orchestrator loop state machine only. R17-010 creates generated state-machine, seed evaluation, and transition check artifacts only.

R17-010 does not implement Orchestrator runtime, live board mutation, A2A runtime, Dev/Codex executor adapter, QA/Test Agent adapter, Evidence Auditor API adapter, external APIs, Codex executor calls, autonomous agents, executable handoffs, executable transitions, external integrations, product runtime, production runtime, or real Dev/QA/Audit outputs.

R17-010 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders. R17-010 does not claim external audit acceptance, main merge, autonomous agents, product runtime, production runtime, executable handoffs, or executable transitions. R13, R14, R15, and R16 boundaries are preserved.
"@

    $proofReviewPath = Resolve-R17OrchestratorLoopPath -Path (Join-Path $proofRoot "proof_review.md") -RepositoryRoot $RepositoryRoot
    $proofReviewDirectory = Split-Path -Parent $proofReviewPath
    if (-not (Test-Path -LiteralPath $proofReviewDirectory)) {
        New-Item -ItemType Directory -Path $proofReviewDirectory -Force | Out-Null
    }
    Set-Content -LiteralPath $proofReviewPath -Value ($proofReview.TrimEnd() + [Environment]::NewLine) -Encoding UTF8 -NoNewline
    Write-R17OrchestratorLoopJson -InputObject $evidenceIndex -Path (Join-Path $proofRoot "evidence_index.json") -RepositoryRoot $RepositoryRoot
    Set-Content -LiteralPath (Resolve-R17OrchestratorLoopPath -Path (Join-Path $proofRoot "validation_manifest.md") -RepositoryRoot $RepositoryRoot) -Value ($validationManifest.TrimEnd() + [Environment]::NewLine) -Encoding UTF8 -NoNewline
}

function New-R17OrchestratorLoopArtifacts {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    $contract = Read-R17OrchestratorLoopJson -Path "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json" -RepositoryRoot $RepositoryRoot
    Test-R17OrchestratorLoopStateMachineContract -InputObject $contract | Out-Null

    $stateMachine = New-R17OrchestratorLoopStateMachine -Contract $contract -RepositoryRoot $RepositoryRoot
    Write-R17OrchestratorLoopJson -InputObject $stateMachine -Path "state/orchestration/r17_orchestrator_loop_state_machine.json" -RepositoryRoot $RepositoryRoot

    $seedEvaluation = New-R17OrchestratorLoopSeedEvaluation -StateMachine $stateMachine -RepositoryRoot $RepositoryRoot
    Write-R17OrchestratorLoopJson -InputObject $seedEvaluation -Path "state/orchestration/r17_orchestrator_loop_seed_evaluation.json" -RepositoryRoot $RepositoryRoot

    $transitionReport = New-R17OrchestratorLoopTransitionCheckReport -StateMachine $stateMachine -SeedEvaluation $seedEvaluation -RepositoryRoot $RepositoryRoot
    Write-R17OrchestratorLoopJson -InputObject $transitionReport -Path "state/orchestration/r17_orchestrator_loop_transition_check_report.json" -RepositoryRoot $RepositoryRoot

    New-R17OrchestratorLoopFixtureSet -StateMachine $stateMachine -SeedEvaluation $seedEvaluation -TransitionCheckReport $transitionReport -RepositoryRoot $RepositoryRoot
    New-R17OrchestratorLoopProofReviewPackage -RepositoryRoot $RepositoryRoot -ValidationStatus "pending/generated"

    return [pscustomobject]@{
        Status = "generated"
        StateMachinePath = "state/orchestration/r17_orchestrator_loop_state_machine.json"
        SeedEvaluationPath = "state/orchestration/r17_orchestrator_loop_seed_evaluation.json"
        TransitionCheckReportPath = "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
        AggregateVerdict = "generated_r17_orchestrator_loop_state_machine_candidate"
    }
}

function Invoke-R17OrchestratorLoopValidation {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-R17OrchestratorLoopRepositoryRoot)
    )

    Test-R17OrchestratorLoopStateMachineContract -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R17OrchestratorLoopStateMachine -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R17OrchestratorLoopSeedEvaluation -RepositoryRoot $RepositoryRoot | Out-Null
    $reportResult = Test-R17OrchestratorLoopTransitionCheckReport -RepositoryRoot $RepositoryRoot

    Test-R17OrchestratorLoopStateMachine -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_orchestrator_loop_state_machine.json" -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R17OrchestratorLoopSeedEvaluation -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_seed_evaluation.json" -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R17OrchestratorLoopTransitionCheckReport -Path "tests/fixtures/r17_orchestrator_loop_state_machine/valid_transition_check_report.json" -RepositoryRoot $RepositoryRoot | Out-Null

    $invalidRejected = 0
    foreach ($fixtureDefinition in New-R17OrchestratorLoopInvalidFixtureDefinitions) {
        $fixturePath = "tests/fixtures/r17_orchestrator_loop_state_machine/$($fixtureDefinition.name).json"
        try {
            Test-R17OrchestratorLoopFixture -Path $fixturePath -RepositoryRoot $RepositoryRoot | Out-Null
            throw "Invalid fixture '$($fixtureDefinition.name)' was accepted unexpectedly."
        }
        catch {
            if ($_.Exception.Message -like "Invalid fixture '$($fixtureDefinition.name)' was accepted unexpectedly.") {
                throw
            }
            $invalidRejected += 1
        }
    }

    return [pscustomobject]@{
        Status = "passed"
        AggregateVerdict = $reportResult.AggregateVerdict
        InvalidFixturesRejected = $invalidRejected
    }
}

Export-ModuleMember -Function `
    Get-R17OrchestratorLoopRepositoryRoot, `
    Read-R17OrchestratorLoopJson, `
    Write-R17OrchestratorLoopJson, `
    Test-R17OrchestratorLoopStateMachineContract, `
    New-R17OrchestratorLoopStateMachine, `
    Test-R17OrchestratorLoopStateMachine, `
    Test-R17OrchestratorLoopTransitionCandidate, `
    New-R17OrchestratorLoopSeedEvaluation, `
    Test-R17OrchestratorLoopSeedEvaluation, `
    New-R17OrchestratorLoopTransitionCheckReport, `
    Test-R17OrchestratorLoopTransitionCheckReport, `
    New-R17OrchestratorLoopInvalidFixtureDefinitions, `
    New-R17OrchestratorLoopFixtureSet, `
    Test-R17OrchestratorLoopFixture, `
    New-R17OrchestratorLoopProofReviewPackage, `
    New-R17OrchestratorLoopArtifacts, `
    Invoke-R17OrchestratorLoopValidation
