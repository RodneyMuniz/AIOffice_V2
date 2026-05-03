Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "packet_set_id",
    "source_milestone",
    "source_task",
    "generated_from_head",
    "generated_from_tree",
    "taxonomy_ref",
    "knowledge_index_ref",
    "model_scope",
    "roles",
    "required_role_ids",
    "required_role_fields",
    "authority_scope_values",
    "allowed_tool_class_values",
    "forbidden_tool_class_values",
    "decision_right_values",
    "approval_requirement_values",
    "handoff_relationship_types",
    "invalid_state_rules",
    "non_claims"
)

$script:RequiredRoleIds = @(
    "user_rodney",
    "operator",
    "orchestrator",
    "project_manager",
    "architect",
    "developer",
    "qa_test_agent",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:RequiredRoleFields = @(
    "agent_id",
    "display_name",
    "role_type",
    "purpose",
    "primary_responsibilities",
    "authority_scope",
    "allowed_actions",
    "forbidden_actions",
    "memory_scope_refs",
    "allowed_tool_classes",
    "forbidden_tool_classes",
    "allowed_inputs",
    "required_outputs",
    "allowed_state_transitions",
    "handoff_targets",
    "escalation_targets",
    "decision_rights",
    "approval_requirements",
    "evidence_requirements",
    "non_claims"
)

$script:RequiredAuthorityScopeValues = @(
    "final_product_decision",
    "operator_intake",
    "routing_only",
    "planning_and_card_state",
    "architecture_advisory",
    "scoped_implementation",
    "qa_validation",
    "evidence_audit",
    "knowledge_classification_proposal",
    "release_closeout_evidence",
    "no_runtime_authority"
)

$script:RequiredAllowedToolClassValues = @(
    "read_governance_docs",
    "read_board_cards",
    "read_task_packets",
    "read_evidence_refs",
    "read_knowledge_index",
    "write_operator_artifact",
    "write_planning_artifact",
    "write_architecture_recommendation",
    "write_scoped_code",
    "run_validation_commands",
    "write_qa_report",
    "write_audit_report",
    "propose_knowledge_classification",
    "write_release_packet",
    "request_user_decision"
)

$script:RequiredForbiddenToolClassValues = @(
    "mutate_canonical_truth_without_pm",
    "implement_without_task_packet",
    "test_own_work_as_final_qa",
    "self_approve",
    "close_card_without_user_approval",
    "impersonate_other_agent",
    "narrate_other_agent_output",
    "run_outside_scope",
    "delete_or_deprecate_without_approval",
    "claim_runtime_not_evidenced",
    "open_successor_without_approval"
)

$script:RequiredDecisionRightValues = @(
    "final_user_decision",
    "intake_routing_decision",
    "card_state_decision",
    "architecture_recommendation_only",
    "implementation_execution_only",
    "qa_pass_fail_recommendation",
    "audit_block_or_accept_recommendation",
    "knowledge_cleanup_proposal_only",
    "release_readiness_recommendation",
    "no_decision_right"
)

$script:RequiredApprovalRequirementValues = @(
    "user_approval_required",
    "pm_approval_required",
    "auditor_verification_required",
    "qa_evidence_required",
    "release_evidence_required",
    "no_self_approval",
    "not_applicable"
)

$script:RequiredHandoffRelationshipTypes = @(
    "handoff_to",
    "escalates_to",
    "requests_decision_from",
    "routes_to",
    "blocks_for"
)

$script:RequiredModelScope = [ordered]@{
    model_only = $true
    runtime_agents_implemented = $false
    true_multi_agent_execution = $false
    direct_agent_access_runtime = $false
    persistent_memory_engine = $false
    raci_matrix_implemented = $false
    card_reentry_packet_implemented = $false
    future_runtime_requires_later_task = $true
}

$script:RequiredNonClaims = @(
    "no actual agents implemented by R15-004",
    "no direct agent access runtime implemented",
    "no true multi-agent execution implemented",
    "no persistent memory engine implemented",
    "no memory scopes implemented beyond identity packet refs by R15-004",
    "no RACI matrix implemented",
    "no card re-entry packet implemented",
    "no board routing implemented",
    "no PM automation implemented",
    "no Developer/QA/Auditor runtime separation implemented",
    "no final R15 proof package complete",
    "no product runtime",
    "no board runtime",
    "no external board sync",
    "no Linear implementation",
    "no Symphony implementation",
    "no GitHub Projects implementation",
    "no custom board implementation",
    "no R16 opening",
    "no solved Codex compaction",
    "no solved Codex reliability"
)

$script:AlwaysForbiddenToolClasses = @(
    "impersonate_other_agent",
    "narrate_other_agent_output",
    "claim_runtime_not_evidenced",
    "open_successor_without_approval"
)

$script:OverclaimPatterns = @(
    "actual agents implemented",
    "agent runtime implemented",
    "direct agent access implemented",
    "direct agent access runtime",
    "true multi-agent execution",
    "multi-agent runtime",
    "persistent memory engine",
    "memory scopes implemented",
    "RACI matrix implemented",
    "card re-entry packet implemented",
    "card reentry packet implemented",
    "board routing implemented",
    "PM automation implemented",
    "Developer/QA/Auditor runtime separation implemented",
    "product runtime",
    "production runtime",
    "productized UI",
    "board runtime",
    "external board sync",
    "Linear implementation",
    "Linear integration",
    "Symphony implementation",
    "Symphony integration",
    "GitHub Projects implementation",
    "GitHub Projects integration",
    "custom board implementation",
    "custom board runtime",
    "R16 opening",
    "R16 opened",
    "solved Codex reliability",
    "solved Codex compaction",
    "solved Codex context compaction"
)

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Resolve-PacketRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $resolvedPath = Resolve-PacketRelativePath -Path $Path
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Context path '$Path' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function New-ValueSet {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items,
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $map = @{}
    foreach ($item in $Items) {
        $id = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name $FieldName -Context $Context) -Context "$Context $FieldName"
        if ($map.ContainsKey($id)) {
            throw "$Context duplicate $FieldName '$id'."
        }

        $map[$id] = $item
    }

    return $map
}

function Assert-RequiredValuesPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Test-TextHasNegation {
    param(
        [AllowNull()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed)\b'
}

function Assert-NoOverclaimText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        foreach ($pattern in $script:OverclaimPatterns) {
            if ($value -match [regex]::Escape($pattern) -and -not (Test-TextHasNegation -Text $value)) {
                throw "$Context contains overclaim text '$pattern'."
            }
        }
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-StringValuesFromObject {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Get-StringValuesFromObject -Value $Value[$key]
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringValuesFromObject -Value $item
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            Get-StringValuesFromObject -Value $property.Value
        }
    }
}

function Assert-TargetIdsExist {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Targets,
        [Parameter(Mandatory = $true)]
        [hashtable]$RoleMap,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($target in $Targets) {
        if (-not $RoleMap.ContainsKey($target)) {
            throw "$Context target '$target' does not point to a known agent_id."
        }
    }
}

function Assert-AllowedValues {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        if ($AllowedValues -notcontains $value) {
            throw "$Context uses invalid value '$value'."
        }
    }
}

function Test-AnyTextMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    foreach ($value in $Values) {
        if ($value -match $Pattern -and -not (Test-TextHasNegation -Text $value)) {
            return $true
        }
    }

    return $false
}

function Assert-FakeNarrationRejected {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $patterns = @(
        '(?i)\bimpersonate(_|\s)+other(_|\s)+agent\b',
        '(?i)\bnarrate(_|\s)+other(_|\s)+agent(_|\s)+output\b',
        '(?i)\bnarrate\s+as\s+another\s+agent\b',
        '(?i)\bpretend\s+to\s+be\s+(the\s+)?(operator|orchestrator|project manager|architect|developer|qa|auditor|knowledge curator|release)',
        '(?i)\bspeaking\s+as\s+(the\s+)?(operator|orchestrator|project manager|architect|developer|qa|auditor|knowledge curator|release)'
    )

    foreach ($value in $Values) {
        foreach ($pattern in $patterns) {
            if ($value -match $pattern -and -not (Test-TextHasNegation -Text $value)) {
                throw "$Context allows fake multi-agent narration or impersonation."
            }
        }
    }
}

function Assert-RoleInvariants {
    param(
        [Parameter(Mandatory = $true)]
        $Role,
        [Parameter(Mandatory = $true)]
        [string[]]$RoleText
    )

    $agentId = [string]$Role.agent_id
    $authorityScope = @($Role.authority_scope)
    $allowedToolClasses = @($Role.allowed_tool_classes)
    $decisionRights = @($Role.decision_rights)
    $approvalRequirements = @($Role.approval_requirements)
    $forbiddenToolClasses = @($Role.forbidden_tool_classes)
    $invariantText = @(
        @($Role.allowed_actions) +
        @($Role.allowed_tool_classes) +
        @($Role.authority_scope) +
        @($Role.decision_rights) +
        @($Role.approval_requirements) +
        @($Role.purpose) +
        @($Role.primary_responsibilities)
    )

    foreach ($requiredForbidden in $script:AlwaysForbiddenToolClasses) {
        if ($forbiddenToolClasses -notcontains $requiredForbidden) {
            throw "role '$agentId' forbidden_tool_classes must include '$requiredForbidden'."
        }
    }

    $allowedNarrationText = @(
        @($Role.allowed_actions) +
        @($Role.allowed_tool_classes) +
        @($Role.purpose) +
        @($Role.primary_responsibilities)
    )
    Assert-FakeNarrationRejected -Values $allowedNarrationText -Context "role '$agentId'"

    if ($agentId -eq "project_manager") {
        if ($authorityScope -contains "scoped_implementation" -or $allowedToolClasses -contains "write_scoped_code" -or $allowedToolClasses -contains "run_validation_commands" -or $decisionRights -contains "implementation_execution_only" -or (Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(implement|implementation execution|write scoped code|run validation|execute tests|run tests|test execution)\b')) {
            throw "Project Manager cannot have implementation or test execution authority."
        }
    }

    if ($agentId -eq "architect") {
        if ($authorityScope -contains "final_product_decision" -or $decisionRights -contains "final_user_decision" -or (Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(final architecture decision|decide final architecture|final product decision)\b')) {
            throw "Architect cannot hold final architecture decision authority."
        }
    }

    if ($agentId -eq "developer") {
        if ($decisionRights -contains "qa_pass_fail_recommendation" -or $decisionRights -contains "card_state_decision" -or $decisionRights -contains "final_user_decision" -or (Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(QA signoff|QA pass|final QA|close card|card closure|mark resolved|mark closed)\b')) {
            throw "Developer cannot hold QA signoff or card closure authority."
        }
    }

    if ($agentId -eq "qa_test_agent") {
        if ($allowedToolClasses -contains "write_scoped_code" -or (Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(test_own_work_as_final_qa|own implementation as final QA|final QA over own implementation)\b')) {
            throw "QA cannot test its own implementation as final QA."
        }
    }

    if ($agentId -eq "evidence_auditor") {
        if ($authorityScope -contains "scoped_implementation" -or $allowedToolClasses -contains "write_scoped_code" -or $decisionRights -contains "implementation_execution_only" -or (Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(implement|implementation execution|write scoped code)\b')) {
            throw "Evidence Auditor cannot have implementation authority."
        }
    }

    if ($agentId -eq "knowledge_curator") {
        if ((Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(delete|deprecate|remove)\b.{0,80}\b(artifact|document|file|knowledge)\b') -and -not ($approvalRequirements -contains "auditor_verification_required" -and $approvalRequirements -contains "user_approval_required")) {
            throw "Knowledge Curator cannot delete or deprecate without audit and user approval."
        }
    }

    if ($agentId -eq "release_closeout_agent") {
        if ((Test-AnyTextMatch -Values $invariantText -Pattern '(?i)\b(merge|promote|promotion|release to production)\b') -and -not ($approvalRequirements -contains "release_evidence_required" -and $approvalRequirements -contains "user_approval_required")) {
            throw "Release Agent cannot merge or promote without release evidence and user approval."
        }
    }
}

function Get-R15AgentIdentityPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    return Read-SingleJsonObject -Path $PacketPath -Label "R15 agent identity packet set"
}

function Test-R15AgentIdentityPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [Parameter(Mandatory = $true)]
        $KnowledgeIndex,
        [string]$SourceLabel = "R15 agent identity packet set"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Packet -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Packet.artifact_type -ne "r15_agent_identity_packet_set") {
        throw "$SourceLabel artifact_type must be 'r15_agent_identity_packet_set'."
    }
    Assert-NonEmptyString -Value $Packet.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $Packet.packet_set_id -Context "$SourceLabel packet_set_id" | Out-Null
    if ($Packet.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($Packet.source_task -ne "R15-004") {
        throw "$SourceLabel source_task must be R15-004."
    }
    Assert-NonEmptyString -Value $Packet.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Packet.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-ObjectValue -Value $Packet.taxonomy_ref -Context "$SourceLabel taxonomy_ref" | Out-Null
    foreach ($field in @("taxonomy_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $Packet.taxonomy_ref -Name $field -Context "$SourceLabel taxonomy_ref" | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Packet.taxonomy_ref.path -Context "$SourceLabel taxonomy_ref path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Packet.taxonomy_ref.contract_path -Context "$SourceLabel taxonomy_ref contract_path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    if ($Packet.taxonomy_ref.taxonomy_id -ne $Taxonomy.taxonomy_id) {
        throw "$SourceLabel taxonomy_ref taxonomy_id must match the loaded R15-002 taxonomy."
    }
    if ($Packet.taxonomy_ref.source_task -ne "R15-002") {
        throw "$SourceLabel taxonomy_ref source_task must be R15-002."
    }
    Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency" | Out-Null

    Assert-ObjectValue -Value $Packet.knowledge_index_ref -Context "$SourceLabel knowledge_index_ref" | Out-Null
    foreach ($field in @("index_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $Packet.knowledge_index_ref -Name $field -Context "$SourceLabel knowledge_index_ref" | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Packet.knowledge_index_ref.path -Context "$SourceLabel knowledge_index_ref path") -Context "$SourceLabel knowledge_index_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Packet.knowledge_index_ref.contract_path -Context "$SourceLabel knowledge_index_ref contract_path") -Context "$SourceLabel knowledge_index_ref" | Out-Null
    if ($Packet.knowledge_index_ref.index_id -ne $KnowledgeIndex.index_id) {
        throw "$SourceLabel knowledge_index_ref index_id must match the loaded R15-003 repo knowledge index."
    }
    if ($Packet.knowledge_index_ref.source_task -ne "R15-003") {
        throw "$SourceLabel knowledge_index_ref source_task must be R15-003."
    }
    Test-R15RepoKnowledgeIndexObject -Index $KnowledgeIndex -Taxonomy $Taxonomy -SourceLabel "$SourceLabel knowledge index dependency" | Out-Null

    Assert-ObjectValue -Value $Packet.model_scope -Context "$SourceLabel model_scope" | Out-Null
    foreach ($scopeKey in $script:RequiredModelScope.Keys) {
        Get-RequiredProperty -Object $Packet.model_scope -Name $scopeKey -Context "$SourceLabel model_scope" | Out-Null
        $actual = Assert-BooleanValue -Value $Packet.model_scope.$scopeKey -Context "$SourceLabel model_scope $scopeKey"
        if ($actual -ne $script:RequiredModelScope[$scopeKey]) {
            throw "$SourceLabel model_scope $scopeKey must be $($script:RequiredModelScope[$scopeKey])."
        }
    }

    $requiredRoleIds = Assert-StringArray -Value $Packet.required_role_ids -Context "$SourceLabel required_role_ids"
    Assert-RequiredValuesPresent -Values $requiredRoleIds -RequiredValues $script:RequiredRoleIds -Context "$SourceLabel required_role_ids"
    $requiredRoleFields = Assert-StringArray -Value $Packet.required_role_fields -Context "$SourceLabel required_role_fields"
    Assert-RequiredValuesPresent -Values $requiredRoleFields -RequiredValues $script:RequiredRoleFields -Context "$SourceLabel required_role_fields"

    $authorityScopeValues = Assert-StringArray -Value $Packet.authority_scope_values -Context "$SourceLabel authority_scope_values"
    $allowedToolClassValues = Assert-StringArray -Value $Packet.allowed_tool_class_values -Context "$SourceLabel allowed_tool_class_values"
    $forbiddenToolClassValues = Assert-StringArray -Value $Packet.forbidden_tool_class_values -Context "$SourceLabel forbidden_tool_class_values"
    $decisionRightValues = Assert-StringArray -Value $Packet.decision_right_values -Context "$SourceLabel decision_right_values"
    $approvalRequirementValues = Assert-StringArray -Value $Packet.approval_requirement_values -Context "$SourceLabel approval_requirement_values"
    $handoffRelationshipTypes = Assert-StringArray -Value $Packet.handoff_relationship_types -Context "$SourceLabel handoff_relationship_types"

    Assert-RequiredValuesPresent -Values $authorityScopeValues -RequiredValues $script:RequiredAuthorityScopeValues -Context "$SourceLabel authority_scope_values"
    Assert-RequiredValuesPresent -Values $allowedToolClassValues -RequiredValues $script:RequiredAllowedToolClassValues -Context "$SourceLabel allowed_tool_class_values"
    Assert-RequiredValuesPresent -Values $forbiddenToolClassValues -RequiredValues $script:RequiredForbiddenToolClassValues -Context "$SourceLabel forbidden_tool_class_values"
    Assert-RequiredValuesPresent -Values $decisionRightValues -RequiredValues $script:RequiredDecisionRightValues -Context "$SourceLabel decision_right_values"
    Assert-RequiredValuesPresent -Values $approvalRequirementValues -RequiredValues $script:RequiredApprovalRequirementValues -Context "$SourceLabel approval_requirement_values"
    Assert-RequiredValuesPresent -Values $handoffRelationshipTypes -RequiredValues $script:RequiredHandoffRelationshipTypes -Context "$SourceLabel handoff_relationship_types"

    $invalidStateRules = Assert-ObjectArray -Value $Packet.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    New-ValueSet -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules" | Out-Null
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rule") -Context "$SourceLabel invalid_state_rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"
    if (Test-HasProperty -Object $Packet -Name "claims") {
        Assert-NoOverclaimText -Values (Assert-StringArray -Value $Packet.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    }

    $roles = Assert-ObjectArray -Value $Packet.roles -Context "$SourceLabel roles"
    $roleMap = @{}
    foreach ($role in $roles) {
        $agentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $role -Name "agent_id" -Context "$SourceLabel role") -Context "$SourceLabel role agent_id"
        if ($roleMap.ContainsKey($agentId)) {
            throw "$SourceLabel roles duplicate agent_id '$agentId'."
        }
        $roleMap[$agentId] = $role
    }

    foreach ($requiredRoleId in $script:RequiredRoleIds) {
        if (-not $roleMap.ContainsKey($requiredRoleId)) {
            throw "$SourceLabel is missing required role '$requiredRoleId'."
        }
    }

    foreach ($role in $roles) {
        $agentId = [string]$role.agent_id
        foreach ($requiredField in $requiredRoleFields) {
            Get-RequiredProperty -Object $role -Name $requiredField -Context "$SourceLabel role '$agentId'" | Out-Null
        }

        Assert-NonEmptyString -Value $role.display_name -Context "$SourceLabel role '$agentId' display_name" | Out-Null
        Assert-NonEmptyString -Value $role.role_type -Context "$SourceLabel role '$agentId' role_type" | Out-Null
        Assert-NonEmptyString -Value $role.purpose -Context "$SourceLabel role '$agentId' purpose" | Out-Null
        Assert-StringArray -Value $role.primary_responsibilities -Context "$SourceLabel role '$agentId' primary_responsibilities" | Out-Null
        $authorityScope = Assert-StringArray -Value $role.authority_scope -Context "$SourceLabel role '$agentId' authority_scope"
        $allowedActions = Assert-StringArray -Value $role.allowed_actions -Context "$SourceLabel role '$agentId' allowed_actions"
        Assert-StringArray -Value $role.forbidden_actions -Context "$SourceLabel role '$agentId' forbidden_actions" | Out-Null
        Assert-StringArray -Value $role.memory_scope_refs -Context "$SourceLabel role '$agentId' memory_scope_refs" | Out-Null
        $allowedToolClasses = Assert-StringArray -Value $role.allowed_tool_classes -Context "$SourceLabel role '$agentId' allowed_tool_classes"
        $forbiddenToolClasses = Assert-StringArray -Value $role.forbidden_tool_classes -Context "$SourceLabel role '$agentId' forbidden_tool_classes"
        Assert-StringArray -Value $role.allowed_inputs -Context "$SourceLabel role '$agentId' allowed_inputs" | Out-Null
        Assert-StringArray -Value $role.required_outputs -Context "$SourceLabel role '$agentId' required_outputs" | Out-Null
        Assert-StringArray -Value $role.allowed_state_transitions -Context "$SourceLabel role '$agentId' allowed_state_transitions" -AllowEmpty | Out-Null
        $handoffTargets = Assert-StringArray -Value $role.handoff_targets -Context "$SourceLabel role '$agentId' handoff_targets" -AllowEmpty
        $escalationTargets = Assert-StringArray -Value $role.escalation_targets -Context "$SourceLabel role '$agentId' escalation_targets" -AllowEmpty
        $decisionRights = Assert-StringArray -Value $role.decision_rights -Context "$SourceLabel role '$agentId' decision_rights"
        $approvalRequirements = Assert-StringArray -Value $role.approval_requirements -Context "$SourceLabel role '$agentId' approval_requirements"
        Assert-StringArray -Value $role.evidence_requirements -Context "$SourceLabel role '$agentId' evidence_requirements" | Out-Null
        $roleNonClaims = Assert-StringArray -Value $role.non_claims -Context "$SourceLabel role '$agentId' non_claims" -AllowEmpty

        Assert-AllowedValues -Values $authorityScope -AllowedValues $authorityScopeValues -Context "$SourceLabel role '$agentId' authority_scope"
        Assert-AllowedValues -Values $allowedToolClasses -AllowedValues $allowedToolClassValues -Context "$SourceLabel role '$agentId' allowed_tool_classes"
        Assert-AllowedValues -Values $forbiddenToolClasses -AllowedValues $forbiddenToolClassValues -Context "$SourceLabel role '$agentId' forbidden_tool_classes"
        Assert-AllowedValues -Values $decisionRights -AllowedValues $decisionRightValues -Context "$SourceLabel role '$agentId' decision_rights"
        Assert-AllowedValues -Values $approvalRequirements -AllowedValues $approvalRequirementValues -Context "$SourceLabel role '$agentId' approval_requirements"
        Assert-TargetIdsExist -Targets $handoffTargets -RoleMap $roleMap -Context "$SourceLabel role '$agentId' handoff_targets"
        Assert-TargetIdsExist -Targets $escalationTargets -RoleMap $roleMap -Context "$SourceLabel role '$agentId' escalation_targets"

        Assert-NoOverclaimText -Values $roleNonClaims -Context "$SourceLabel role '$agentId' non_claims"
        $roleText = @(Get-StringValuesFromObject -Value $role | Where-Object { $roleNonClaims -notcontains $_ })
        Assert-NoOverclaimText -Values $roleText -Context "$SourceLabel role '$agentId'"
        Assert-RoleInvariants -Role $role -RoleText $roleText
        Assert-FakeNarrationRejected -Values $allowedActions -Context "$SourceLabel role '$agentId' allowed_actions"
    }

    return [pscustomobject]@{
        ArtifactType = $Packet.artifact_type
        PacketSetId = $Packet.packet_set_id
        SourceTask = $Packet.source_task
        RoleCount = $roles.Count
        ModelOnly = [bool]$Packet.model_scope.model_only
        RuntimeAgentsImplemented = [bool]$Packet.model_scope.runtime_agents_implemented
        TrueMultiAgentExecution = [bool]$Packet.model_scope.true_multi_agent_execution
        DirectAgentAccessRuntime = [bool]$Packet.model_scope.direct_agent_access_runtime
        PersistentMemoryEngine = [bool]$Packet.model_scope.persistent_memory_engine
        RaciMatrixImplemented = [bool]$Packet.model_scope.raci_matrix_implemented
        CardReentryPacketImplemented = [bool]$Packet.model_scope.card_reentry_packet_implemented
        TaxonomyId = $Packet.taxonomy_ref.taxonomy_id
        KnowledgeIndexId = $Packet.knowledge_index_ref.index_id
    }
}

function Test-R15AgentIdentityPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath,
        [Parameter(Mandatory = $true)]
        [string]$TaxonomyPath,
        [Parameter(Mandatory = $true)]
        [string]$KnowledgeIndexPath
    )

    $packet = Get-R15AgentIdentityPacket -PacketPath $PacketPath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    $knowledgeIndex = Get-R15RepoKnowledgeIndex -IndexPath $KnowledgeIndexPath
    return Test-R15AgentIdentityPacketObject -Packet $packet -Taxonomy $taxonomy -KnowledgeIndex $knowledgeIndex -SourceLabel $PacketPath
}

Export-ModuleMember -Function Get-R15AgentIdentityPacket, Test-R15AgentIdentityPacketObject, Test-R15AgentIdentityPacket
