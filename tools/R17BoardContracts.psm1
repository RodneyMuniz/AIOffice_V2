Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"

$script:RequiredCardFields = @(
    "artifact_type",
    "contract_version",
    "card_id",
    "milestone",
    "task_id",
    "title",
    "description",
    "double_diamond_stage",
    "lane",
    "owner_role",
    "current_agent",
    "status",
    "acceptance_criteria",
    "qa_criteria",
    "evidence_refs",
    "memory_refs",
    "task_packet_ref",
    "blocker_refs",
    "user_decision_required",
    "user_approval_required_for_closure",
    "allowed_next_lanes",
    "forbidden_claims",
    "non_claims",
    "audit_log_refs",
    "created_by",
    "updated_by"
)

$script:RequiredBoardStateFields = @(
    "artifact_type",
    "contract_version",
    "board_id",
    "milestone",
    "branch",
    "active_through_task",
    "canonical_truth",
    "card_refs",
    "lane_order",
    "lane_policies",
    "role_permissions",
    "transition_policies",
    "unresolved_blockers",
    "user_decisions_required",
    "non_claims",
    "generated_from_head",
    "generated_from_tree"
)

$script:RequiredBoardEventFields = @(
    "artifact_type",
    "contract_version",
    "event_id",
    "card_id",
    "event_type",
    "actor_role",
    "agent_id",
    "from_lane",
    "to_lane",
    "timestamp_utc",
    "input_ref",
    "output_ref",
    "evidence_refs",
    "validation_refs",
    "transition_allowed",
    "user_approval_present",
    "non_claims",
    "rejected_claims"
)

$script:AllowedLanes = @(
    "intake",
    "define",
    "ready_for_dev",
    "in_dev",
    "ready_for_qa",
    "in_qa",
    "fix_required",
    "ready_for_audit",
    "in_audit",
    "ready_for_user_review",
    "resolved",
    "closed",
    "blocked"
)

$script:AllowedDoubleDiamondStages = @(
    "discover",
    "define",
    "develop",
    "deliver",
    "feedback_improve"
)

$script:AllowedOwnerRoles = @(
    "user",
    "operator",
    "orchestrator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout"
)

$script:AllowedEventTypes = @(
    "contract_validation",
    "card_created",
    "card_updated",
    "lane_transition_requested",
    "lane_transition_rejected",
    "blocker_added",
    "user_decision_requested",
    "closure_requested",
    "closure_rejected"
)

$script:RequiredPolicyRuleIds = @(
    "closed_requires_user_approval",
    "qa_must_not_implement",
    "developer_must_not_approve_evidence_sufficiency",
    "auditor_must_not_implement",
    "orchestrator_must_not_bypass_qa_or_audit",
    "contracts_are_design_only_not_runtime",
    "refs_do_not_implement_runtime_flows",
    "repo_truth_remains_canonical",
    "board_state_not_replacement_for_repo_truth",
    "fake_multi_agent_narration_not_proof",
    "a2a_runtime_not_implemented_in_r17_004"
)

$script:ForbiddenClaimFields = @(
    "unsupported_agent_runtime_claimed",
    "unsupported_a2a_runtime_claimed",
    "unsupported_product_runtime_claimed",
    "unsupported_autonomous_agent_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed"
)

$script:RequiredRejectedClaims = @(
    "external_audit_acceptance",
    "main_merge",
    "R13_closure",
    "R14_caveat_removal",
    "R15_caveat_removal",
    "solved_Codex_compaction",
    "solved_Codex_reliability",
    "product_runtime",
    "Kanban_runtime",
    "autonomous_agents",
    "A2A_runtime",
    "executable_handoffs",
    "executable_transitions"
)

$script:RequiredNonClaims = @(
    "R17-004 defines governed card, board-state, and board-event contracts only",
    "R17-004 does not implement board state store",
    "R17-004 does not implement Kanban UI",
    "R17-004 does not implement Orchestrator runtime",
    "R17-004 does not implement A2A runtime",
    "R17-004 does not implement Dev/Codex executor adapter",
    "R17-004 does not implement QA/Test Agent adapter",
    "R17-004 does not implement Evidence Auditor API adapter",
    "R17-004 does not claim product runtime",
    "R17-004 does not claim autonomous agents",
    "R17-004 does not claim executable handoffs",
    "R17-004 does not claim executable transitions",
    "R17-004 does not claim external audit acceptance",
    "R17-004 does not claim main merge",
    "R13 boundary preserved",
    "R14 caveats preserved",
    "R15 caveats preserved",
    "R16 boundary preserved",
    "R17-005 through R17-028 remain planned only",
    "R17-004 does not claim solved Codex compaction",
    "R17-004 does not claim solved Codex reliability"
)

function Resolve-R17Path {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Read-R17JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17Path -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "JSON file '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
    }
    catch {
        throw "JSON file '$Path' could not be parsed. $($_.Exception.Message)"
    }
}

function Test-R17HasProperty {
    param($Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17RequiredProperty {
    param($Object, [string]$Name, [string]$Context)

    if (-not (Test-R17HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Assert-R17NonEmptyString {
    param($Value, [string]$Context)

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }
}

function Assert-R17Boolean {
    param($Value, [string]$Context)

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }
}

function Assert-R17Array {
    param($Value, [string]$Context, [switch]$AllowNullAsEmpty)

    if ($null -eq $Value -and $AllowNullAsEmpty) {
        return @()
    }

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    return @($Value)
}

function Assert-R17AllowedValue {
    param($Value, [string[]]$AllowedValues, [string]$Context)

    if ($AllowedValues -notcontains [string]$Value) {
        throw "$Context value '$Value' is not allowed."
    }
}

function Assert-R17StringSetContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)

    foreach ($requiredValue in $Required) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-R17ExactStringSet {
    param([string[]]$Values, [string[]]$Expected, [string]$Context)

    $missing = @($Expected | Where-Object { $Values -notcontains $_ })
    $extra = @($Values | Where-Object { $Expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }
}

function Assert-R17PathExists {
    param([string]$Path, [string]$Context, [string]$RepositoryRoot = $repoRoot)

    Assert-R17NonEmptyString -Value $Path -Context $Context
    if ($Path -match '^\s*(\.|\.\\|\./|\*|\*\*|/|\\|repo|repository|full_repo|entire_repo)\s*$') {
        throw "$Context path '$Path' is unbounded."
    }

    $resolvedPath = Resolve-R17Path -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }
}

function Assert-R17Sha {
    param($Value, [string]$Context)

    Assert-R17NonEmptyString -Value $Value -Context $Context
    if ($Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character lowercase git SHA."
    }
}

function Assert-R17PolicyRules {
    param($Value, [string]$Context)

    $rules = Assert-R17Array -Value $Value -Context $Context
    $ruleIds = @($rules | ForEach-Object { [string]$_.rule_id })
    Assert-R17StringSetContains -Values $ruleIds -Required $script:RequiredPolicyRuleIds -Context $Context
}

function Test-R17BoardContractDefinitions {
    param([string]$RepositoryRoot = $repoRoot)

    $cardContract = Read-R17JsonFile -Path "contracts/board/r17_card.contract.json" -RepositoryRoot $RepositoryRoot
    $stateContract = Read-R17JsonFile -Path "contracts/board/r17_board_state.contract.json" -RepositoryRoot $RepositoryRoot
    $eventContract = Read-R17JsonFile -Path "contracts/board/r17_board_event.contract.json" -RepositoryRoot $RepositoryRoot

    if ($cardContract.artifact_type -ne "r17_board_card_contract") {
        throw "Card contract artifact_type must be r17_board_card_contract."
    }
    if ($stateContract.artifact_type -ne "r17_board_state_contract") {
        throw "Board state contract artifact_type must be r17_board_state_contract."
    }
    if ($eventContract.artifact_type -ne "r17_board_event_contract") {
        throw "Board event contract artifact_type must be r17_board_event_contract."
    }

    foreach ($contractEntry in @(
            @{ Contract = $cardContract; Context = "card contract" },
            @{ Contract = $stateContract; Context = "board state contract" },
            @{ Contract = $eventContract; Context = "board event contract" }
        )) {
        $contract = $contractEntry.Contract
        $context = $contractEntry.Context
        if ($contract.contract_version -ne "v1") {
            throw "$context contract_version must be v1."
        }
        if ($contract.source_milestone -ne $script:MilestoneName) {
            throw "$context source_milestone is incorrect."
        }
        if ($contract.source_task -ne "R17-004") {
            throw "$context source_task must be R17-004."
        }
        if ($contract.branch -ne $script:BranchName) {
            throw "$context branch is incorrect."
        }
        Assert-R17PolicyRules -Value $contract.required_policy_rules -Context "$context required_policy_rules"
        Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $contract.required_non_claims -Context "$context required_non_claims")) -Required $script:RequiredNonClaims -Context "$context required_non_claims"
    }

    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $cardContract.required_card_fields -Context "required_card_fields")) -Required $script:RequiredCardFields -Context "required_card_fields"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $cardContract.allowed_lanes -Context "card allowed_lanes")) -Required $script:AllowedLanes -Context "card allowed_lanes"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $cardContract.allowed_double_diamond_stages -Context "allowed_double_diamond_stages")) -Required $script:AllowedDoubleDiamondStages -Context "allowed_double_diamond_stages"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $cardContract.allowed_owner_roles -Context "allowed_owner_roles")) -Required $script:AllowedOwnerRoles -Context "allowed_owner_roles"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $cardContract.forbidden_claim_fields -Context "forbidden_claim_fields")) -Required $script:ForbiddenClaimFields -Context "forbidden_claim_fields"

    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $stateContract.required_board_state_fields -Context "required_board_state_fields")) -Required $script:RequiredBoardStateFields -Context "required_board_state_fields"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $stateContract.allowed_lanes -Context "board state allowed_lanes")) -Required $script:AllowedLanes -Context "board state allowed_lanes"

    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $eventContract.required_board_event_fields -Context "required_board_event_fields")) -Required $script:RequiredBoardEventFields -Context "required_board_event_fields"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $eventContract.allowed_lanes -Context "board event allowed_lanes")) -Required $script:AllowedLanes -Context "board event allowed_lanes"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $eventContract.allowed_actor_roles -Context "allowed_actor_roles")) -Required $script:AllowedOwnerRoles -Context "allowed_actor_roles"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $eventContract.allowed_event_types -Context "allowed_event_types")) -Required $script:AllowedEventTypes -Context "allowed_event_types"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $eventContract.required_rejected_claims -Context "required_rejected_claims")) -Required $script:RequiredRejectedClaims -Context "required_rejected_claims"

    foreach ($field in @(
            "board_state_store_implemented",
            "kanban_ui_implemented",
            "orchestrator_runtime_implemented",
            "a2a_runtime_implemented",
            "dev_codex_executor_adapter_implemented",
            "qa_test_agent_adapter_implemented",
            "evidence_auditor_api_adapter_implemented",
            "autonomous_agents_implemented",
            "product_runtime_implemented"
        )) {
        if ((Get-R17RequiredProperty -Object $cardContract.runtime_boundaries -Name $field -Context "card runtime_boundaries") -ne $false) {
            throw "Card contract runtime boundary '$field' must be false."
        }
    }

    foreach ($field in @(
            "event_replay_implemented",
            "transition_execution_implemented",
            "a2a_dispatch_implemented",
            "agent_invocation_implemented",
            "api_calls_implemented"
        )) {
        if ((Get-R17RequiredProperty -Object $eventContract.runtime_boundaries -Name $field -Context "event runtime_boundaries") -ne $false) {
            throw "Board event contract runtime boundary '$field' must be false."
        }
    }

    return [pscustomobject]@{
        ContractCount = 3
        RequiredCardFields = $script:RequiredCardFields.Count
        RequiredBoardStateFields = $script:RequiredBoardStateFields.Count
        RequiredBoardEventFields = $script:RequiredBoardEventFields.Count
        AllowedLaneCount = $script:AllowedLanes.Count
        AllowedOwnerRoleCount = $script:AllowedOwnerRoles.Count
    }
}

function Test-R17CardFixture {
    param(
        [Parameter(Mandatory = $true)]
        $Card,
        [string]$Context = "R17 board card",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredCardFields) {
        Get-R17RequiredProperty -Object $Card -Name $field -Context $Context | Out-Null
    }

    if ($Card.artifact_type -ne "r17_board_card") {
        throw "$Context artifact_type must be r17_board_card."
    }
    if ($Card.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }
    if ($Card.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($Card.task_id -ne "R17-004") {
        throw "$Context task_id must be R17-004."
    }

    foreach ($field in @("card_id", "title", "description", "current_agent", "status", "created_by", "updated_by")) {
        Assert-R17NonEmptyString -Value (Get-R17RequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field"
    }

    Assert-R17AllowedValue -Value $Card.double_diamond_stage -AllowedValues $script:AllowedDoubleDiamondStages -Context "double_diamond_stage"
    Assert-R17AllowedValue -Value $Card.lane -AllowedValues $script:AllowedLanes -Context "lane"
    Assert-R17AllowedValue -Value $Card.owner_role -AllowedValues $script:AllowedOwnerRoles -Context "owner_role"

    foreach ($field in @("user_decision_required", "user_approval_required_for_closure")) {
        Assert-R17Boolean -Value (Get-R17RequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field"
    }

    foreach ($field in @("acceptance_criteria", "qa_criteria", "evidence_refs")) {
        $values = @(Assert-R17Array -Value (Get-R17RequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field")
        if ($values.Count -eq 0) {
            throw "$Context $field must not be empty."
        }
    }

    foreach ($field in @("memory_refs", "blocker_refs", "audit_log_refs")) {
        Assert-R17Array -Value (Get-R17RequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field" -AllowNullAsEmpty | Out-Null
    }

    foreach ($field in @("allowed_next_lanes", "forbidden_claims", "non_claims")) {
        Assert-R17Array -Value (Get-R17RequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field" | Out-Null
    }

    foreach ($lane in (Assert-R17Array -Value $Card.allowed_next_lanes -Context "$Context allowed_next_lanes")) {
        Assert-R17AllowedValue -Value $lane -AllowedValues $script:AllowedLanes -Context "allowed_next_lanes"
    }

    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $Card.forbidden_claims -Context "$Context forbidden_claims")) -Required $script:ForbiddenClaimFields -Context "$Context forbidden_claims"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $Card.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"

    foreach ($evidenceRef in (Assert-R17Array -Value $Card.evidence_refs -Context "$Context evidence_refs")) {
        Assert-R17PathExists -Path ([string]$evidenceRef) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot
    }

    if (($Card.lane -eq "closed" -or $Card.status -eq "closed") -and $Card.user_approval_required_for_closure -ne $true) {
        throw "$Context closed cards require user approval."
    }

    if (Test-R17HasProperty -Object $Card -Name "claims") {
        foreach ($claimField in $script:ForbiddenClaimFields) {
            $claimValue = Get-R17RequiredProperty -Object $Card.claims -Name $claimField -Context "$Context claims"
            Assert-R17Boolean -Value $claimValue -Context "$Context claims $claimField"
            if ($claimValue -ne $false) {
                throw "$Context forbidden claim $claimField must be false."
            }
        }
    }

    return [pscustomobject]@{
        CardId = $Card.card_id
        Lane = $Card.lane
        OwnerRole = $Card.owner_role
        EvidenceRefCount = @(Assert-R17Array -Value $Card.evidence_refs -Context "$Context evidence_refs").Count
    }
}

function Test-R17BoardStateFixture {
    param(
        [Parameter(Mandatory = $true)]
        $BoardState,
        [string]$Context = "R17 board state",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredBoardStateFields) {
        Get-R17RequiredProperty -Object $BoardState -Name $field -Context $Context | Out-Null
    }

    if ($BoardState.artifact_type -ne "r17_board_state") {
        throw "$Context artifact_type must be r17_board_state."
    }
    if ($BoardState.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }
    if ($BoardState.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($BoardState.branch -ne $script:BranchName) {
        throw "$Context branch is incorrect."
    }
    if ($BoardState.active_through_task -ne "R17-004") {
        throw "$Context active_through_task must be R17-004."
    }

    if ($BoardState.canonical_truth.repo_truth_is_canonical -ne $true) {
        throw "$Context canonical_truth repo_truth_is_canonical must be true."
    }
    if ($BoardState.canonical_truth.board_state_replaces_repo_truth -ne $false) {
        throw "$Context canonical_truth board_state_replaces_repo_truth must be false."
    }
    if ($BoardState.canonical_truth.fixture_only_not_runtime_state -ne $true) {
        throw "$Context canonical_truth fixture_only_not_runtime_state must be true."
    }

    Assert-R17ExactStringSet -Values ([string[]](Assert-R17Array -Value $BoardState.lane_order -Context "$Context lane_order")) -Expected $script:AllowedLanes -Context "$Context lane_order"
    foreach ($lane in $script:AllowedLanes) {
        if (-not (Test-R17HasProperty -Object $BoardState.lane_policies -Name $lane)) {
            throw "$Context lane_policies must define lane '$lane'."
        }
    }

    $cardRefs = @(Assert-R17Array -Value $BoardState.card_refs -Context "$Context card_refs")
    if ($cardRefs.Count -eq 0) {
        throw "$Context card_refs must not be empty."
    }
    foreach ($cardRef in $cardRefs) {
        Assert-R17NonEmptyString -Value $cardRef.card_id -Context "$Context card_refs card_id"
        Assert-R17PathExists -Path ([string]$cardRef.path) -Context "$Context card_refs path" -RepositoryRoot $RepositoryRoot
    }

    if ($BoardState.role_permissions.qa.can_implement -ne $false) {
        throw "$Context role_permissions qa can_implement must be false."
    }
    if ($BoardState.role_permissions.developer.can_approve_evidence_sufficiency -ne $false) {
        throw "$Context role_permissions developer can_approve_evidence_sufficiency must be false."
    }
    if ($BoardState.role_permissions.evidence_auditor.can_implement -ne $false) {
        throw "$Context role_permissions evidence_auditor can_implement must be false."
    }
    if ($BoardState.role_permissions.orchestrator.can_bypass_qa_gate -ne $false -or $BoardState.role_permissions.orchestrator.can_bypass_audit_gate -ne $false) {
        throw "$Context role_permissions orchestrator bypass flags must be false."
    }

    if ($BoardState.transition_policies.closed_requires_user_approval -ne $true) {
        throw "$Context transition_policies closed_requires_user_approval must be true."
    }
    foreach ($field in @("board_state_replaces_repo_truth", "runtime_transitions_implemented_in_r17_004", "a2a_runtime_implemented_in_r17_004")) {
        if ((Get-R17RequiredProperty -Object $BoardState.transition_policies -Name $field -Context "$Context transition_policies") -ne $false) {
            throw "$Context transition_policies $field must be false."
        }
    }

    Assert-R17Array -Value $BoardState.unresolved_blockers -Context "$Context unresolved_blockers" -AllowNullAsEmpty | Out-Null
    Assert-R17Array -Value $BoardState.user_decisions_required -Context "$Context user_decisions_required" -AllowNullAsEmpty | Out-Null
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $BoardState.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"
    Assert-R17Sha -Value $BoardState.generated_from_head -Context "$Context generated_from_head"
    Assert-R17Sha -Value $BoardState.generated_from_tree -Context "$Context generated_from_tree"

    return [pscustomobject]@{
        BoardId = $BoardState.board_id
        LaneCount = @(Assert-R17Array -Value $BoardState.lane_order -Context "$Context lane_order").Count
        CardRefCount = $cardRefs.Count
    }
}

function Test-R17BoardEventFixture {
    param(
        [Parameter(Mandatory = $true)]
        $BoardEvent,
        [string]$Context = "R17 board event",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredBoardEventFields) {
        Get-R17RequiredProperty -Object $BoardEvent -Name $field -Context $Context | Out-Null
    }

    if ($BoardEvent.artifact_type -ne "r17_board_event") {
        throw "$Context artifact_type must be r17_board_event."
    }
    if ($BoardEvent.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }

    foreach ($field in @("event_id", "card_id", "agent_id", "input_ref", "output_ref")) {
        Assert-R17NonEmptyString -Value (Get-R17RequiredProperty -Object $BoardEvent -Name $field -Context $Context) -Context "$Context $field"
    }

    Assert-R17AllowedValue -Value $BoardEvent.event_type -AllowedValues $script:AllowedEventTypes -Context "event_type"
    Assert-R17AllowedValue -Value $BoardEvent.actor_role -AllowedValues $script:AllowedOwnerRoles -Context "actor_role"
    Assert-R17AllowedValue -Value $BoardEvent.from_lane -AllowedValues $script:AllowedLanes -Context "from_lane"
    Assert-R17AllowedValue -Value $BoardEvent.to_lane -AllowedValues $script:AllowedLanes -Context "to_lane"
    Assert-R17Boolean -Value $BoardEvent.transition_allowed -Context "$Context transition_allowed"
    Assert-R17Boolean -Value $BoardEvent.user_approval_present -Context "$Context user_approval_present"

    if ($BoardEvent.timestamp_utc -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
        throw "$Context timestamp_utc must be an ISO UTC timestamp ending in Z."
    }
    [datetime]::ParseExact($BoardEvent.timestamp_utc, "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal) | Out-Null

    Assert-R17PathExists -Path $BoardEvent.input_ref -Context "$Context input_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17PathExists -Path $BoardEvent.output_ref -Context "$Context output_ref" -RepositoryRoot $RepositoryRoot
    foreach ($ref in (Assert-R17Array -Value $BoardEvent.evidence_refs -Context "$Context evidence_refs")) {
        Assert-R17PathExists -Path ([string]$ref) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot
    }
    foreach ($ref in (Assert-R17Array -Value $BoardEvent.validation_refs -Context "$Context validation_refs")) {
        Assert-R17PathExists -Path ([string]$ref) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot
    }

    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $BoardEvent.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"
    Assert-R17StringSetContains -Values ([string[]](Assert-R17Array -Value $BoardEvent.rejected_claims -Context "$Context rejected_claims")) -Required $script:RequiredRejectedClaims -Context "$Context rejected_claims"

    if ($BoardEvent.to_lane -eq "closed" -and $BoardEvent.transition_allowed -eq $true -and $BoardEvent.user_approval_present -ne $true) {
        throw "$Context closed events require user approval."
    }

    return [pscustomobject]@{
        EventId = $BoardEvent.event_id
        EventType = $BoardEvent.event_type
        TransitionAllowed = $BoardEvent.transition_allowed
    }
}

function Copy-R17JsonObject {
    param($Object)
    return ($Object | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Set-R17JsonPathProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        $Value
    )

    $parts = @($Path -split '\.')
    $target = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if (-not (Test-R17HasProperty -Object $target -Name $part) -or $null -eq $target.PSObject.Properties[$part].Value) {
            $target | Add-Member -MemberType NoteProperty -Name $part -Value ([pscustomobject]@{}) -Force
        }
        $target = $target.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if (Test-R17HasProperty -Object $target -Name $leaf) {
        $target.PSObject.Properties[$leaf].Value = $Value
    }
    else {
        $target | Add-Member -MemberType NoteProperty -Name $leaf -Value $Value -Force
    }
}

function Remove-R17JsonPathProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $parts = @($Path -split '\.')
    $target = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if (-not (Test-R17HasProperty -Object $target -Name $part)) {
            return
        }
        $target = $target.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if (Test-R17HasProperty -Object $target -Name $leaf) {
        $target.PSObject.Properties.Remove($leaf)
    }
}

function New-R17InvalidFixtureCandidate {
    param(
        [Parameter(Mandatory = $true)]
        $InvalidFixture,
        [string]$RepositoryRoot = $repoRoot
    )

    if ($InvalidFixture.artifact_type -ne "r17_board_contract_invalid_fixture") {
        throw "Invalid fixture '$($InvalidFixture.case_id)' must have artifact_type r17_board_contract_invalid_fixture."
    }
    Assert-R17NonEmptyString -Value $InvalidFixture.base_fixture -Context "invalid fixture base_fixture"
    Assert-R17NonEmptyString -Value $InvalidFixture.expected_refusal -Context "invalid fixture expected_refusal"

    $candidate = Copy-R17JsonObject -Object (Read-R17JsonFile -Path $InvalidFixture.base_fixture -RepositoryRoot $RepositoryRoot)

    if (Test-R17HasProperty -Object $InvalidFixture -Name "remove_fields") {
        foreach ($fieldPath in (Assert-R17Array -Value $InvalidFixture.remove_fields -Context "invalid fixture remove_fields")) {
            Remove-R17JsonPathProperty -Object $candidate -Path ([string]$fieldPath)
        }
    }

    if (Test-R17HasProperty -Object $InvalidFixture -Name "set_fields") {
        foreach ($property in $InvalidFixture.set_fields.PSObject.Properties) {
            Set-R17JsonPathProperty -Object $candidate -Path $property.Name -Value $property.Value
        }
    }

    return [pscustomobject]@{
        CaseId = $InvalidFixture.case_id
        ExpectedRefusal = $InvalidFixture.expected_refusal
        Candidate = $candidate
    }
}

function Test-R17InvalidFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $invalidFixture = Read-R17JsonFile -Path $Path -RepositoryRoot $RepositoryRoot
    $candidateRecord = New-R17InvalidFixtureCandidate -InvalidFixture $invalidFixture -RepositoryRoot $RepositoryRoot

    try {
        Test-R17CardFixture -Card $candidateRecord.Candidate -Context "invalid fixture $($candidateRecord.CaseId)" -RepositoryRoot $RepositoryRoot | Out-Null
        throw "invalid fixture '$($candidateRecord.CaseId)' was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        if ($message -notlike ("*{0}*" -f $candidateRecord.ExpectedRefusal)) {
            throw "invalid fixture '$($candidateRecord.CaseId)' refusal missed expected fragment '$($candidateRecord.ExpectedRefusal)'. Actual: $message"
        }
    }

    return [pscustomobject]@{
        CaseId = $candidateRecord.CaseId
        ExpectedRefusal = $candidateRecord.ExpectedRefusal
        Rejected = $true
    }
}

function Test-R17BoardContracts {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$FixturesRoot = "tests/fixtures/r17_board_contracts"
    )

    $contracts = Test-R17BoardContractDefinitions -RepositoryRoot $RepositoryRoot
    $validCard = Test-R17CardFixture -Card (Read-R17JsonFile -Path (Join-Path $FixturesRoot "valid_card.json") -RepositoryRoot $RepositoryRoot) -Context "valid_card" -RepositoryRoot $RepositoryRoot
    $validBoardState = Test-R17BoardStateFixture -BoardState (Read-R17JsonFile -Path (Join-Path $FixturesRoot "valid_board_state.json") -RepositoryRoot $RepositoryRoot) -Context "valid_board_state" -RepositoryRoot $RepositoryRoot
    $validBoardEvent = Test-R17BoardEventFixture -BoardEvent (Read-R17JsonFile -Path (Join-Path $FixturesRoot "valid_board_event.json") -RepositoryRoot $RepositoryRoot) -Context "valid_board_event" -RepositoryRoot $RepositoryRoot

    $resolvedFixturesRoot = Resolve-R17Path -Path $FixturesRoot -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedFixturesRoot -PathType Container)) {
        throw "Fixtures root '$FixturesRoot' does not exist."
    }

    $invalidResults = @()
    foreach ($invalidFixture in @(Get-ChildItem -LiteralPath $resolvedFixturesRoot -Filter "invalid_*.json" -File | Sort-Object Name)) {
        $relativePath = Join-Path $FixturesRoot $invalidFixture.Name
        $invalidResults += Test-R17InvalidFixture -Path $relativePath -RepositoryRoot $RepositoryRoot
    }

    if ($invalidResults.Count -ne 17) {
        throw "R17 board contract invalid fixture count must be 17."
    }

    return [pscustomobject]@{
        ContractCount = $contracts.ContractCount
        ValidFixtureCount = 3
        InvalidRejectedCount = $invalidResults.Count
        CardId = $validCard.CardId
        LaneCount = $validBoardState.LaneCount
        EventId = $validBoardEvent.EventId
        Scope = "contract_shape_and_fixture_behavior_only_not_runtime"
    }
}

Export-ModuleMember -Function @(
    "Read-R17JsonFile",
    "Test-R17BoardContractDefinitions",
    "Test-R17CardFixture",
    "Test-R17BoardStateFixture",
    "Test-R17BoardEventFixture",
    "New-R17InvalidFixtureCandidate",
    "Test-R17InvalidFixture",
    "Test-R17BoardContracts"
)
