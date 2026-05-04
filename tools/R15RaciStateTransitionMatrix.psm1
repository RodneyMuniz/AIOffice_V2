Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentIdentityPacket.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentMemoryScope.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "matrix_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "taxonomy_ref",
    "knowledge_index_ref",
    "agent_identity_packet_ref",
    "agent_memory_scope_ref",
    "scope_boundary",
    "required_state_ids",
    "required_state_fields",
    "required_transition_fields",
    "required_evidence_type_ids",
    "required_separation_of_duties_rule_ids",
    "state_model",
    "state_raci_records",
    "transition_matrix",
    "prohibited_transitions",
    "separation_of_duties_rules",
    "invalid_state_rules",
    "non_claims"
)

$script:RequiredStateIds = @(
    "intake",
    "refinement",
    "ready",
    "in_progress",
    "implementation_complete",
    "qa_review",
    "qa_failed",
    "qa_passed",
    "audit_review",
    "audit_blocked",
    "audit_accepted",
    "user_approval_required",
    "approved_for_closeout",
    "closed",
    "rejected_or_cancelled"
)

$script:TerminalStateIds = @("closed", "rejected_or_cancelled")

$script:RequiredStateFields = @(
    "state_id",
    "state_kind",
    "description",
    "terminal",
    "active_state",
    "allowed_entry_transition_ids",
    "allowed_exit_transition_ids",
    "non_claims"
)

$script:RequiredRaciFields = @(
    "state_id",
    "responsible_agent_ids",
    "accountable_agent_id",
    "consulted_agent_ids",
    "informed_agent_ids",
    "allowed_proposers",
    "allowed_executors",
    "allowed_verifiers",
    "required_approvers",
    "required_evidence_refs",
    "prohibited_agents",
    "prohibited_actions",
    "fail_closed_conditions",
    "non_claims"
)

$script:RequiredTransitionFields = @(
    "transition_id",
    "from_state_id",
    "to_state_id",
    "responsible_agent_ids",
    "accountable_agent_id",
    "consulted_agent_ids",
    "informed_agent_ids",
    "allowed_proposers",
    "allowed_executors",
    "allowed_verifiers",
    "required_approvers",
    "required_evidence_refs",
    "prohibited_agents",
    "prohibited_actions",
    "requires_user_approval",
    "requires_qa_evidence",
    "requires_audit_evidence",
    "requires_release_closeout_evidence",
    "fail_closed",
    "fail_closed_conditions",
    "no_self_approval",
    "separation_of_duties_rule_refs",
    "non_claims"
)

$script:RequiredEvidenceTypeIds = @(
    "bounded_card_ref",
    "task_packet_ref",
    "acceptance_criteria_ref",
    "implementation_evidence_ref",
    "qa_evidence_ref",
    "audit_evidence_ref",
    "audit_accepted_state_ref",
    "user_approval_ref",
    "release_closeout_evidence_ref",
    "rejection_or_cancellation_authority_ref",
    "state_change_record_ref"
)

$script:RequiredTransitionIds = @(
    "intake_to_refinement",
    "refinement_to_ready",
    "ready_to_in_progress",
    "in_progress_to_implementation_complete",
    "implementation_complete_to_qa_review",
    "qa_review_to_qa_failed",
    "qa_review_to_qa_passed",
    "qa_failed_to_in_progress",
    "qa_passed_to_audit_review",
    "audit_review_to_audit_blocked",
    "audit_review_to_audit_accepted",
    "audit_blocked_to_in_progress",
    "audit_blocked_to_refinement",
    "audit_accepted_to_user_approval_required",
    "user_approval_required_to_approved_for_closeout",
    "approved_for_closeout_to_closed",
    "intake_to_rejected_or_cancelled",
    "refinement_to_rejected_or_cancelled",
    "ready_to_rejected_or_cancelled",
    "in_progress_to_rejected_or_cancelled",
    "implementation_complete_to_rejected_or_cancelled",
    "qa_review_to_rejected_or_cancelled",
    "qa_failed_to_rejected_or_cancelled",
    "qa_passed_to_rejected_or_cancelled",
    "audit_review_to_rejected_or_cancelled",
    "audit_blocked_to_rejected_or_cancelled",
    "audit_accepted_to_rejected_or_cancelled",
    "user_approval_required_to_rejected_or_cancelled",
    "approved_for_closeout_to_rejected_or_cancelled"
)

$script:RequiredSeparationRules = @(
    "user_final_approval_required",
    "project_manager_no_implementation_or_final_qa",
    "developer_requires_bounded_task",
    "qa_no_self_final_qa",
    "auditor_no_implementation",
    "release_closeout_no_close_without_user_approval",
    "no_self_approval",
    "no_impersonation",
    "no_close_without_evidence_approval_chain"
)

$script:RequiredInvalidRuleIds = @(
    "missing_required_states",
    "duplicate_states",
    "missing_required_transitions",
    "duplicate_transition_ids",
    "closed_without_user_approval_rejected",
    "developer_accountable_for_qa_pass_rejected",
    "qa_as_implementer_for_final_qa_rejected",
    "auditor_as_implementer_rejected",
    "pm_as_code_implementer_rejected",
    "release_closeout_without_audit_accepted_rejected",
    "missing_accountable_agent_rejected",
    "missing_responsible_agent_rejected",
    "runtime_state_machine_claim_rejected",
    "board_routing_runtime_claim_rejected",
    "card_reentry_implementation_claim_rejected",
    "actual_agent_runtime_claim_rejected",
    "r16_opening_claim_rejected",
    "r15_007_plus_complete_status_rejected"
)

$script:RequiredScopeBoundary = [ordered]@{
    model_only = $true
    runtime_state_machine_implemented = $false
    board_routing_runtime_implemented = $false
    actual_agents_implemented = $false
    direct_agent_access_runtime_implemented = $false
    true_multi_agent_execution_implemented = $false
    persistent_memory_engine_implemented = $false
    runtime_memory_loading_implemented = $false
    retrieval_engine_implemented = $false
    vector_search_implemented = $false
    external_board_sync_implemented = $false
    pm_automation_implemented = $false
    actual_workflow_execution_implemented = $false
    card_reentry_packet_implemented = $false
    product_runtime_implemented = $false
    integration_runtime_implemented = $false
    r16_opened = $false
    future_runtime_requires_later_task = $true
}

$script:RequiredNonClaims = @(
    "no actual agents implemented by R15-006",
    "no direct agent access runtime implemented",
    "no true multi-agent execution implemented",
    "no persistent memory engine implemented",
    "no runtime memory loading implemented",
    "no retrieval engine implemented",
    "no vector search implemented",
    "no Obsidian integration by R15-006",
    "no external board sync",
    "no GitHub Projects integration",
    "no Linear implementation",
    "no Symphony implementation",
    "no custom board runtime",
    "no PM automation implemented",
    "no actual workflow execution",
    "no board routing runtime implemented",
    "no card re-entry packet implemented",
    "no classification or re-entry dry run executed",
    "no final R15 proof package complete",
    "no product runtime",
    "no R16 opening",
    "no solved Codex compaction",
    "no solved Codex reliability"
)

$script:OverclaimPatterns = @(
    "runtime state machine implemented",
    "state-machine runtime implemented",
    "board routing runtime implemented",
    "actual agents implemented",
    "agent runtime implemented",
    "direct agent access runtime",
    "direct agent access implemented",
    "true multi-agent execution",
    "multi-agent runtime",
    "persistent memory engine",
    "runtime memory loading",
    "retrieval engine",
    "vector search",
    "Obsidian integration",
    "external board sync",
    "GitHub Projects integration",
    "Linear integration",
    "Symphony integration",
    "custom board runtime",
    "custom board implementation",
    "PM automation implemented",
    "actual workflow execution",
    "workflow execution implemented",
    "board routing implemented",
    "card re-entry packet implemented",
    "card reentry packet implemented",
    "classification/re-entry dry run",
    "classification and re-entry dry run",
    "final R15 proof package complete",
    "product runtime",
    "production runtime",
    "productized UI",
    "solved Codex reliability",
    "solved Codex compaction",
    "solved Codex context compaction",
    "R16 opening",
    "R16 opened",
    "R16 active"
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

    if ($AllowEmpty -and $null -ne $Value -and $Value -isnot [string] -and $Value.PSObject -and @($Value.PSObject.Properties).Count -eq 0) {
        $PSCmdlet.WriteObject(@(), $false)
        return
    }

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

function Resolve-MatrixRelativePath {
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

    $resolvedPath = Resolve-MatrixRelativePath -Path $Path
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

function Assert-AgentRefsKnown {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$AgentIds,
        [Parameter(Mandatory = $true)]
        [hashtable]$KnownAgents,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if (-not $AllowEmpty -and $AgentIds.Count -eq 0) {
        throw "$Context must include at least one agent id."
    }

    foreach ($agentId in $AgentIds) {
        if (-not $KnownAgents.ContainsKey($agentId)) {
            throw "$Context references unknown agent_id '$agentId'."
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

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed|reject|rejected|fails validation|fail validation|claim fails|model-only|model only|future runtime requires later task)\b|any .{0,30}claim'
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

function Assert-NoForbiddenPositiveClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$ClaimLabel,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        if ($line -match $Pattern -and -not (Test-TextHasNegation -Text $line)) {
            throw "$Context contains forbidden positive claim: $ClaimLabel."
        }
    }
}

function Assert-RegexMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Get-R15TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R15-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R15 task status headings."
    }

    $statusMap = @{}
    foreach ($match in $matches) {
        $taskId = $match.Groups[1].Value
        if ($statusMap.ContainsKey($taskId)) {
            throw "$Context duplicates status heading '$taskId'."
        }
        $statusMap[$taskId] = $match.Groups[2].Value
    }

    return $statusMap
}

function Assert-R15RaciStateTransitionStatusPosture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $statusPaths = @(
        "README.md",
        "governance\ACTIVE_STATE.md",
        "execution\KANBAN.md",
        "governance\DECISION_LOG.md",
        "governance\DOCUMENT_AUTHORITY_INDEX.md",
        "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    )

    $texts = @{}
    foreach ($relativePath in $statusPaths) {
        $path = Join-Path $RepositoryRoot $relativePath
        if (-not (Test-Path -LiteralPath $path)) {
            throw "R15-006 status posture check could not find '$relativePath'."
        }
        $texts[$relativePath] = Get-Content -LiteralPath $path -Raw
    }

    $kanbanStatus = Get-R15TaskStatusMap -Text $texts["execution\KANBAN.md"] -Context "KANBAN"
    $authorityStatus = Get-R15TaskStatusMap -Text $texts["governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"] -Context "R15 authority"
    foreach ($taskId in @("R15-001", "R15-002", "R15-003", "R15-004", "R15-005", "R15-006")) {
        if ($kanbanStatus[$taskId] -ne "done" -or $authorityStatus[$taskId] -ne "done") {
            throw "R15 status posture must mark $taskId done for R15-006."
        }
    }
    foreach ($taskId in @("R15-007", "R15-008", "R15-009")) {
        if ($kanbanStatus[$taskId] -ne "planned" -or $authorityStatus[$taskId] -ne "planned") {
            throw "R15 status posture must keep $taskId planned only."
        }
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R15 active through `?R15-006`? only|Active in repo truth through `R15-006` only|through `R15-006` only' -Message "Status docs must state R15 is active through R15-006 only."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)`?R15-007`?\s+through\s+`?R15-009`?\s+are planned only|R15-007 through R15-009 are planned only' -Message "Status docs must keep R15-007 through R15-009 planned only."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R13 remains failed/partial.*R13-018|R13 API-First QA Pipeline and Operator Control-Room Product Slice` remains failed/partial' -Message "Status docs must preserve R13 failed/partial through R13-018."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R14.*accepted.*R14-006|accepted with caveats.*R14-006' -Message "Status docs must preserve R14 accepted with caveats through R14-006."
    Assert-RegexMatch -Text $texts["governance\DECISION_LOG.md"] -Pattern 'R15-006 Defined RACI State-Transition Matrix Model' -Message "DECISION_LOG must record the R15-006 RACI state-transition decision."

    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-006 status docs" -ClaimLabel "R16 or successor opening" -Pattern '(?i)\bR16\b.{0,120}\b(active|open|opened|marked active)\b|\bsuccessor milestone\b.{0,120}\b(is now active|is active|marked active|opens on branch|opened on branch)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-006 status docs" -ClaimLabel "R15-007 or later completion" -Pattern '(?i)\bR15-00[7-9]\b.{0,140}\b(done|complete|completed|implemented|executed|ran)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-006 status docs" -ClaimLabel "runtime or integration overclaim" -Pattern '(?i)\b(actual agents implemented|agent runtime|direct agent access runtime|true multi-agent execution|multi-agent runtime|persistent memory engine|runtime memory loading|retrieval engine|vector search|Obsidian integration|card re-entry packet implemented|card reentry packet implemented|card re-entry implementation|final R15 proof package complete|product runtime|production runtime|board runtime|external board sync|Linear integration|Symphony integration|GitHub Projects integration|custom board runtime|custom board implementation|PM automation|actual workflow execution|workflow execution implemented|board routing runtime|solved Codex reliability|solved Codex compaction)\b'
}

function Get-R15RaciStateTransitionMatrix {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MatrixPath
    )

    return Read-SingleJsonObject -Path $MatrixPath -Label "R15 RACI state-transition matrix"
}

function Assert-DependencyRef {
    param(
        [Parameter(Mandatory = $true)]
        $Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedSourceTask,
        [Parameter(Mandatory = $true)]
        [string]$IdField,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedId
    )

    Assert-ObjectValue -Value $Ref -Context $Context | Out-Null
    foreach ($field in @($IdField, "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $Ref -Name $field -Context $Context | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Ref.path -Context "$Context path") -Context $Context | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Ref.contract_path -Context "$Context contract_path") -Context $Context | Out-Null
    if ($Ref.$IdField -ne $ExpectedId -or $Ref.source_task -ne $ExpectedSourceTask) {
        throw "$Context must point to the $ExpectedSourceTask dependency."
    }
}

function Test-R15RaciStateTransitionMatrixObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Matrix,
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [Parameter(Mandatory = $true)]
        $KnowledgeIndex,
        [Parameter(Mandatory = $true)]
        $AgentIdentityPacket,
        [Parameter(Mandatory = $true)]
        $AgentMemoryScope,
        [string]$SourceLabel = "R15 RACI state-transition matrix"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Matrix -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Matrix.artifact_type -ne "r15_raci_state_transition_matrix_model") {
        throw "$SourceLabel artifact_type must be 'r15_raci_state_transition_matrix_model'."
    }
    if ($Matrix.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($Matrix.source_task -ne "R15-006") {
        throw "$SourceLabel source_task must be R15-006."
    }
    Assert-NonEmptyString -Value $Matrix.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $Matrix.matrix_id -Context "$SourceLabel matrix_id" | Out-Null
    Assert-NonEmptyString -Value $Matrix.repository -Context "$SourceLabel repository" | Out-Null
    Assert-NonEmptyString -Value $Matrix.branch -Context "$SourceLabel branch" | Out-Null
    Assert-NonEmptyString -Value $Matrix.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Matrix.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-DependencyRef -Ref $Matrix.taxonomy_ref -Context "$SourceLabel taxonomy_ref" -ExpectedSourceTask "R15-002" -IdField "taxonomy_id" -ExpectedId $Taxonomy.taxonomy_id
    Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency" | Out-Null
    Assert-DependencyRef -Ref $Matrix.knowledge_index_ref -Context "$SourceLabel knowledge_index_ref" -ExpectedSourceTask "R15-003" -IdField "index_id" -ExpectedId $KnowledgeIndex.index_id
    Test-R15RepoKnowledgeIndexObject -Index $KnowledgeIndex -Taxonomy $Taxonomy -SourceLabel "$SourceLabel knowledge index dependency" | Out-Null
    Assert-DependencyRef -Ref $Matrix.agent_identity_packet_ref -Context "$SourceLabel agent_identity_packet_ref" -ExpectedSourceTask "R15-004" -IdField "packet_set_id" -ExpectedId $AgentIdentityPacket.packet_set_id
    Test-R15AgentIdentityPacketObject -Packet $AgentIdentityPacket -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -SourceLabel "$SourceLabel agent identity dependency" | Out-Null
    Assert-DependencyRef -Ref $Matrix.agent_memory_scope_ref -Context "$SourceLabel agent_memory_scope_ref" -ExpectedSourceTask "R15-005" -IdField "memory_scope_model_id" -ExpectedId $AgentMemoryScope.memory_scope_model_id
    Test-R15AgentMemoryScopeObject -ScopeModel $AgentMemoryScope -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -SourceLabel "$SourceLabel agent memory scope dependency" | Out-Null

    Assert-ObjectValue -Value $Matrix.scope_boundary -Context "$SourceLabel scope_boundary" | Out-Null
    foreach ($boundaryKey in $script:RequiredScopeBoundary.Keys) {
        Get-RequiredProperty -Object $Matrix.scope_boundary -Name $boundaryKey -Context "$SourceLabel scope_boundary" | Out-Null
        $actual = Assert-BooleanValue -Value $Matrix.scope_boundary.$boundaryKey -Context "$SourceLabel scope_boundary $boundaryKey"
        if ($actual -ne $script:RequiredScopeBoundary[$boundaryKey]) {
            throw "$SourceLabel scope_boundary $boundaryKey must be $($script:RequiredScopeBoundary[$boundaryKey])."
        }
    }

    $agentMap = @{}
    foreach ($role in @($AgentIdentityPacket.roles)) {
        $agentMap[[string]$role.agent_id] = $role
    }

    $requiredStateIds = Assert-StringArray -Value $Matrix.required_state_ids -Context "$SourceLabel required_state_ids"
    Assert-RequiredValuesPresent -Values $requiredStateIds -RequiredValues $script:RequiredStateIds -Context "$SourceLabel required_state_ids"
    $requiredStateFields = Assert-StringArray -Value $Matrix.required_state_fields -Context "$SourceLabel required_state_fields"
    Assert-RequiredValuesPresent -Values $requiredStateFields -RequiredValues $script:RequiredStateFields -Context "$SourceLabel required_state_fields"
    $requiredTransitionFields = Assert-StringArray -Value $Matrix.required_transition_fields -Context "$SourceLabel required_transition_fields"
    Assert-RequiredValuesPresent -Values $requiredTransitionFields -RequiredValues $script:RequiredTransitionFields -Context "$SourceLabel required_transition_fields"
    $requiredEvidenceTypeIds = Assert-StringArray -Value $Matrix.required_evidence_type_ids -Context "$SourceLabel required_evidence_type_ids"
    Assert-RequiredValuesPresent -Values $requiredEvidenceTypeIds -RequiredValues $script:RequiredEvidenceTypeIds -Context "$SourceLabel required_evidence_type_ids"
    $requiredSeparationRuleIds = Assert-StringArray -Value $Matrix.required_separation_of_duties_rule_ids -Context "$SourceLabel required_separation_of_duties_rule_ids"
    Assert-RequiredValuesPresent -Values $requiredSeparationRuleIds -RequiredValues $script:RequiredSeparationRules -Context "$SourceLabel required_separation_of_duties_rule_ids"

    $states = Assert-ObjectArray -Value $Matrix.state_model -Context "$SourceLabel state_model"
    $stateMap = New-ValueSet -Items $states -FieldName "state_id" -Context "$SourceLabel state_model"
    foreach ($requiredStateId in $script:RequiredStateIds) {
        if (-not $stateMap.ContainsKey($requiredStateId)) {
            throw "$SourceLabel missing required state '$requiredStateId'."
        }
    }

    $raciRecords = Assert-ObjectArray -Value $Matrix.state_raci_records -Context "$SourceLabel state_raci_records"
    $raciMap = New-ValueSet -Items $raciRecords -FieldName "state_id" -Context "$SourceLabel state_raci_records"

    foreach ($state in $states) {
        $stateId = [string]$state.state_id
        foreach ($requiredField in $requiredStateFields) {
            Get-RequiredProperty -Object $state -Name $requiredField -Context "$SourceLabel state '$stateId'" | Out-Null
        }
        Assert-NonEmptyString -Value $state.state_kind -Context "$SourceLabel state '$stateId' state_kind" | Out-Null
        Assert-NonEmptyString -Value $state.description -Context "$SourceLabel state '$stateId' description" | Out-Null
        $terminal = Assert-BooleanValue -Value $state.terminal -Context "$SourceLabel state '$stateId' terminal"
        $active = Assert-BooleanValue -Value $state.active_state -Context "$SourceLabel state '$stateId' active_state"
        Assert-StringArray -Value $state.allowed_entry_transition_ids -Context "$SourceLabel state '$stateId' allowed_entry_transition_ids" -AllowEmpty | Out-Null
        Assert-StringArray -Value $state.allowed_exit_transition_ids -Context "$SourceLabel state '$stateId' allowed_exit_transition_ids" -AllowEmpty | Out-Null
        Assert-StringArray -Value $state.non_claims -Context "$SourceLabel state '$stateId' non_claims" -AllowEmpty | Out-Null
        if (($script:TerminalStateIds -contains $stateId) -and (-not $terminal -or $active)) {
            throw "$SourceLabel terminal state '$stateId' must be terminal and not active."
        }
        if (($script:TerminalStateIds -notcontains $stateId) -and ($terminal -or -not $active)) {
            throw "$SourceLabel active state '$stateId' must not be terminal."
        }
        if (-not $raciMap.ContainsKey($stateId)) {
            throw "$SourceLabel missing RACI record for state '$stateId'."
        }
    }

    foreach ($record in $raciRecords) {
        $stateId = [string]$record.state_id
        foreach ($requiredField in $script:RequiredRaciFields) {
            Get-RequiredProperty -Object $record -Name $requiredField -Context "$SourceLabel RACI record '$stateId'" | Out-Null
        }
        if (-not $stateMap.ContainsKey($stateId)) {
            throw "$SourceLabel RACI record references unknown state '$stateId'."
        }
        $responsible = Assert-StringArray -Value $record.responsible_agent_ids -Context "$SourceLabel RACI record '$stateId' responsible_agent_ids"
        $accountable = Assert-NonEmptyString -Value $record.accountable_agent_id -Context "$SourceLabel RACI record '$stateId' accountable_agent_id"
        Assert-AgentRefsKnown -AgentIds $responsible -KnownAgents $agentMap -Context "$SourceLabel RACI record '$stateId' responsible_agent_ids"
        Assert-AgentRefsKnown -AgentIds @($accountable) -KnownAgents $agentMap -Context "$SourceLabel RACI record '$stateId' accountable_agent_id"
        foreach ($field in @("consulted_agent_ids", "informed_agent_ids", "allowed_proposers", "allowed_executors", "allowed_verifiers", "required_approvers", "prohibited_agents")) {
            $agentIds = Assert-StringArray -Value $record.$field -Context "$SourceLabel RACI record '$stateId' $field" -AllowEmpty
            Assert-AgentRefsKnown -AgentIds $agentIds -KnownAgents $agentMap -Context "$SourceLabel RACI record '$stateId' $field" -AllowEmpty
        }
        Assert-StringArray -Value $record.required_evidence_refs -Context "$SourceLabel RACI record '$stateId' required_evidence_refs" -AllowEmpty | Out-Null
        Assert-StringArray -Value $record.prohibited_actions -Context "$SourceLabel RACI record '$stateId' prohibited_actions" -AllowEmpty | Out-Null
        Assert-StringArray -Value $record.fail_closed_conditions -Context "$SourceLabel RACI record '$stateId' fail_closed_conditions" | Out-Null
        Assert-StringArray -Value $record.non_claims -Context "$SourceLabel RACI record '$stateId' non_claims" -AllowEmpty | Out-Null
    }

    $transitions = Assert-ObjectArray -Value $Matrix.transition_matrix -Context "$SourceLabel transition_matrix"
    $transitionMap = New-ValueSet -Items $transitions -FieldName "transition_id" -Context "$SourceLabel transition_matrix"
    foreach ($requiredTransitionId in $script:RequiredTransitionIds) {
        if (-not $transitionMap.ContainsKey($requiredTransitionId)) {
            throw "$SourceLabel missing required transition '$requiredTransitionId'."
        }
    }

    foreach ($transition in $transitions) {
        $transitionId = [string]$transition.transition_id
        foreach ($requiredField in $requiredTransitionFields) {
            Get-RequiredProperty -Object $transition -Name $requiredField -Context "$SourceLabel transition '$transitionId'" | Out-Null
        }

        $fromState = Assert-NonEmptyString -Value $transition.from_state_id -Context "$SourceLabel transition '$transitionId' from_state_id"
        $toState = Assert-NonEmptyString -Value $transition.to_state_id -Context "$SourceLabel transition '$transitionId' to_state_id"
        if (-not $stateMap.ContainsKey($fromState)) {
            throw "$SourceLabel transition '$transitionId' from_state_id '$fromState' is unknown."
        }
        if (-not $stateMap.ContainsKey($toState)) {
            throw "$SourceLabel transition '$transitionId' to_state_id '$toState' is unknown."
        }

        $responsible = Assert-StringArray -Value $transition.responsible_agent_ids -Context "$SourceLabel transition '$transitionId' responsible_agent_ids"
        $accountable = Assert-NonEmptyString -Value $transition.accountable_agent_id -Context "$SourceLabel transition '$transitionId' accountable_agent_id"
        $proposers = Assert-StringArray -Value $transition.allowed_proposers -Context "$SourceLabel transition '$transitionId' allowed_proposers" -AllowEmpty
        $executors = Assert-StringArray -Value $transition.allowed_executors -Context "$SourceLabel transition '$transitionId' allowed_executors"
        $verifiers = Assert-StringArray -Value $transition.allowed_verifiers -Context "$SourceLabel transition '$transitionId' allowed_verifiers" -AllowEmpty
        $approvers = Assert-StringArray -Value $transition.required_approvers -Context "$SourceLabel transition '$transitionId' required_approvers" -AllowEmpty
        $prohibitedAgents = Assert-StringArray -Value $transition.prohibited_agents -Context "$SourceLabel transition '$transitionId' prohibited_agents" -AllowEmpty
        foreach ($fieldValue in @(
                @{ Name = "responsible_agent_ids"; Values = $responsible },
                @{ Name = "accountable_agent_id"; Values = @($accountable) },
                @{ Name = "allowed_proposers"; Values = $proposers },
                @{ Name = "allowed_executors"; Values = $executors },
                @{ Name = "allowed_verifiers"; Values = $verifiers },
                @{ Name = "required_approvers"; Values = $approvers },
                @{ Name = "prohibited_agents"; Values = $prohibitedAgents }
            )) {
            $fieldName = [string]$fieldValue["Name"]
            $fieldValues = [string[]]@($fieldValue["Values"])
            Assert-AgentRefsKnown -AgentIds $fieldValues -KnownAgents $agentMap -Context "$SourceLabel transition '$transitionId' $fieldName" -AllowEmpty
        }
        foreach ($field in @("consulted_agent_ids", "informed_agent_ids")) {
            $agentIds = Assert-StringArray -Value $transition.$field -Context "$SourceLabel transition '$transitionId' $field" -AllowEmpty
            Assert-AgentRefsKnown -AgentIds $agentIds -KnownAgents $agentMap -Context "$SourceLabel transition '$transitionId' $field" -AllowEmpty
        }

        $evidenceRefs = Assert-StringArray -Value $transition.required_evidence_refs -Context "$SourceLabel transition '$transitionId' required_evidence_refs" -AllowEmpty
        foreach ($evidenceRef in $evidenceRefs) {
            if ($requiredEvidenceTypeIds -notcontains $evidenceRef) {
                throw "$SourceLabel transition '$transitionId' references unknown evidence '$evidenceRef'."
            }
        }
        Assert-StringArray -Value $transition.prohibited_actions -Context "$SourceLabel transition '$transitionId' prohibited_actions" -AllowEmpty | Out-Null
        $requiresUserApproval = Assert-BooleanValue -Value $transition.requires_user_approval -Context "$SourceLabel transition '$transitionId' requires_user_approval"
        $requiresQaEvidence = Assert-BooleanValue -Value $transition.requires_qa_evidence -Context "$SourceLabel transition '$transitionId' requires_qa_evidence"
        $requiresAuditEvidence = Assert-BooleanValue -Value $transition.requires_audit_evidence -Context "$SourceLabel transition '$transitionId' requires_audit_evidence"
        $requiresReleaseEvidence = Assert-BooleanValue -Value $transition.requires_release_closeout_evidence -Context "$SourceLabel transition '$transitionId' requires_release_closeout_evidence"
        $failClosed = Assert-BooleanValue -Value $transition.fail_closed -Context "$SourceLabel transition '$transitionId' fail_closed"
        $noSelfApproval = Assert-BooleanValue -Value $transition.no_self_approval -Context "$SourceLabel transition '$transitionId' no_self_approval"
        Assert-StringArray -Value $transition.fail_closed_conditions -Context "$SourceLabel transition '$transitionId' fail_closed_conditions" | Out-Null
        $separationRefs = Assert-StringArray -Value $transition.separation_of_duties_rule_refs -Context "$SourceLabel transition '$transitionId' separation_of_duties_rule_refs" -AllowEmpty
        foreach ($ruleRef in $separationRefs) {
            if ($requiredSeparationRuleIds -notcontains $ruleRef) {
                throw "$SourceLabel transition '$transitionId' references unknown separation-of-duties rule '$ruleRef'."
            }
        }
        Assert-StringArray -Value $transition.non_claims -Context "$SourceLabel transition '$transitionId' non_claims" -AllowEmpty | Out-Null

        if (-not $failClosed) {
            throw "$SourceLabel transition '$transitionId' must fail closed."
        }
        if ($noSelfApproval) {
            $overlap = @($executors | Where-Object { $approvers -contains $_ })
            if ($overlap.Count -gt 0) {
                throw "$SourceLabel transition '$transitionId' violates no_self_approval for '$($overlap -join ', ')'."
            }
        }
        if ($requiresUserApproval -and $approvers -notcontains "user_rodney") {
            throw "$SourceLabel transition '$transitionId' requires user approval but does not require user_rodney."
        }
        if ($requiresQaEvidence -and $evidenceRefs -notcontains "qa_evidence_ref") {
            throw "$SourceLabel transition '$transitionId' requires QA evidence but omits qa_evidence_ref."
        }
        if ($requiresAuditEvidence -and $evidenceRefs -notcontains "audit_evidence_ref") {
            throw "$SourceLabel transition '$transitionId' requires audit evidence but omits audit_evidence_ref."
        }
        if ($requiresReleaseEvidence -and $evidenceRefs -notcontains "release_closeout_evidence_ref") {
            throw "$SourceLabel transition '$transitionId' requires release closeout evidence but omits release_closeout_evidence_ref."
        }
        if ($toState -eq "closed") {
            if ($fromState -ne "approved_for_closeout" -or -not $requiresUserApproval -or $approvers -notcontains "user_rodney" -or -not $requiresAuditEvidence -or -not $requiresReleaseEvidence -or $evidenceRefs -notcontains "audit_accepted_state_ref") {
                throw "$SourceLabel transition '$transitionId' cannot transition to closed without approved_for_closeout, user approval, audit accepted state, audit evidence, and release closeout evidence."
            }
        }
    }

    if ($transitionMap["qa_review_to_qa_passed"].accountable_agent_id -eq "developer") {
        throw "$SourceLabel developer cannot be accountable for QA pass."
    }
    if (@($transitionMap["qa_review_to_qa_passed"].allowed_executors) -contains "developer") {
        throw "$SourceLabel developer cannot execute final QA pass transition."
    }
    if (@($transitionMap["qa_review_to_qa_passed"].allowed_executors) -contains "qa_test_agent" -and @($transitionMap["qa_review_to_qa_passed"].prohibited_actions) -notcontains "test_own_implementation_as_final_qa") {
        throw "$SourceLabel QA final pass must prohibit testing own implementation as final QA."
    }
    foreach ($implementationTransitionId in @("ready_to_in_progress", "in_progress_to_implementation_complete")) {
        $transition = $transitionMap[$implementationTransitionId]
        foreach ($blockedImplementer in @("project_manager", "evidence_auditor", "qa_test_agent")) {
            if (@($transition.allowed_executors) -contains $blockedImplementer) {
                throw "$SourceLabel $blockedImplementer cannot be an implementation executor for '$implementationTransitionId'."
            }
        }
        foreach ($requiredEvidence in @("bounded_card_ref", "task_packet_ref")) {
            if (@($transition.required_evidence_refs) -notcontains $requiredEvidence) {
                throw "$SourceLabel developer implementation transition '$implementationTransitionId' must require '$requiredEvidence'."
            }
        }
    }
    if (@($transitionMap["approved_for_closeout_to_closed"].required_evidence_refs) -notcontains "audit_accepted_state_ref") {
        throw "$SourceLabel release closeout without audit accepted state is rejected."
    }
    if ($transitionMap["audit_accepted_to_user_approval_required"].from_state_id -ne "audit_accepted") {
        throw "$SourceLabel user approval cannot be requested without audit_accepted state."
    }

    $prohibitedTransitions = Assert-ObjectArray -Value $Matrix.prohibited_transitions -Context "$SourceLabel prohibited_transitions"
    foreach ($prohibited in $prohibitedTransitions) {
        foreach ($field in @("transition_id", "from_state_id", "to_state_id", "reason", "fail_closed", "non_claims")) {
            Get-RequiredProperty -Object $prohibited -Name $field -Context "$SourceLabel prohibited transition" | Out-Null
        }
        Assert-NonEmptyString -Value $prohibited.transition_id -Context "$SourceLabel prohibited transition transition_id" | Out-Null
        $fromState = Assert-NonEmptyString -Value $prohibited.from_state_id -Context "$SourceLabel prohibited transition from_state_id"
        $toState = Assert-NonEmptyString -Value $prohibited.to_state_id -Context "$SourceLabel prohibited transition to_state_id"
        if ($fromState -ne "any_valid_active_state" -and -not $stateMap.ContainsKey($fromState)) {
            throw "$SourceLabel prohibited transition from_state_id '$fromState' is unknown."
        }
        if ($toState -ne "any_valid_active_state" -and -not $stateMap.ContainsKey($toState)) {
            throw "$SourceLabel prohibited transition to_state_id '$toState' is unknown."
        }
        Assert-NonEmptyString -Value $prohibited.reason -Context "$SourceLabel prohibited transition reason" | Out-Null
        if (-not (Assert-BooleanValue -Value $prohibited.fail_closed -Context "$SourceLabel prohibited transition fail_closed")) {
            throw "$SourceLabel prohibited transitions must fail closed."
        }
        Assert-StringArray -Value $prohibited.non_claims -Context "$SourceLabel prohibited transition non_claims" -AllowEmpty | Out-Null
    }

    $separationRules = Assert-ObjectArray -Value $Matrix.separation_of_duties_rules -Context "$SourceLabel separation_of_duties_rules"
    $separationRuleMap = New-ValueSet -Items $separationRules -FieldName "rule_id" -Context "$SourceLabel separation_of_duties_rules"
    foreach ($requiredRuleId in $script:RequiredSeparationRules) {
        if (-not $separationRuleMap.ContainsKey($requiredRuleId)) {
            throw "$SourceLabel missing required separation-of-duties rule '$requiredRuleId'."
        }
    }
    foreach ($rule in $separationRules) {
        foreach ($field in @("rule_id", "description", "must_fail_closed", "non_claims")) {
            Get-RequiredProperty -Object $rule -Name $field -Context "$SourceLabel separation-of-duties rule" | Out-Null
        }
        Assert-NonEmptyString -Value $rule.description -Context "$SourceLabel separation-of-duties rule description" | Out-Null
        if (-not (Assert-BooleanValue -Value $rule.must_fail_closed -Context "$SourceLabel separation-of-duties rule must_fail_closed")) {
            throw "$SourceLabel separation-of-duties rule '$($rule.rule_id)' must fail closed."
        }
        Assert-StringArray -Value $rule.non_claims -Context "$SourceLabel separation-of-duties rule non_claims" -AllowEmpty | Out-Null
    }

    $invalidStateRules = Assert-ObjectArray -Value $Matrix.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $invalidRuleMap = New-ValueSet -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules"
    foreach ($requiredRuleId in $script:RequiredInvalidRuleIds) {
        if (-not $invalidRuleMap.ContainsKey($requiredRuleId)) {
            throw "$SourceLabel missing required invalid-state rule '$requiredRuleId'."
        }
    }
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rule") -Context "$SourceLabel invalid_state_rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $Matrix.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"
    if (Test-HasProperty -Object $Matrix -Name "claims") {
        Assert-NoOverclaimText -Values (Assert-StringArray -Value $Matrix.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    }
    $allText = @(Get-StringValuesFromObject -Value $Matrix)
    Assert-NoOverclaimText -Values $allText -Context $SourceLabel

    return [pscustomobject]@{
        ArtifactType = $Matrix.artifact_type
        MatrixId = $Matrix.matrix_id
        SourceTask = $Matrix.source_task
        StateCount = $states.Count
        TransitionCount = $transitions.Count
        ProhibitedTransitionCount = $prohibitedTransitions.Count
        SeparationRuleCount = $separationRules.Count
        ModelOnly = [bool]$Matrix.scope_boundary.model_only
        RuntimeStateMachineImplemented = [bool]$Matrix.scope_boundary.runtime_state_machine_implemented
        BoardRoutingRuntimeImplemented = [bool]$Matrix.scope_boundary.board_routing_runtime_implemented
        ActualAgentsImplemented = [bool]$Matrix.scope_boundary.actual_agents_implemented
        CardReentryPacketImplemented = [bool]$Matrix.scope_boundary.card_reentry_packet_implemented
        ProductRuntimeImplemented = [bool]$Matrix.scope_boundary.product_runtime_implemented
        IntegrationRuntimeImplemented = [bool]$Matrix.scope_boundary.integration_runtime_implemented
        R16Opened = [bool]$Matrix.scope_boundary.r16_opened
    }
}

function Test-R15RaciStateTransitionMatrix {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MatrixPath,
        [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
        [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
        [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
        [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $matrix = Get-R15RaciStateTransitionMatrix -MatrixPath $MatrixPath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    $knowledgeIndex = Get-R15RepoKnowledgeIndex -IndexPath $KnowledgeIndexPath
    $agentIdentityPacket = Get-R15AgentIdentityPacket -PacketPath $AgentIdentityPacketPath
    $agentMemoryScope = Get-R15AgentMemoryScope -ScopePath $AgentMemoryScopePath
    $result = Test-R15RaciStateTransitionMatrixObject -Matrix $matrix -Taxonomy $taxonomy -KnowledgeIndex $knowledgeIndex -AgentIdentityPacket $agentIdentityPacket -AgentMemoryScope $agentMemoryScope -SourceLabel $MatrixPath
    Assert-R15RaciStateTransitionStatusPosture -RepositoryRoot $RepositoryRoot
    return $result
}

Export-ModuleMember -Function Get-R15RaciStateTransitionMatrix, Test-R15RaciStateTransitionMatrixObject, Test-R15RaciStateTransitionMatrix, Assert-R15RaciStateTransitionStatusPosture
