Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentIdentityPacket.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentMemoryScope.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RaciStateTransitionMatrix.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "packet_model_id",
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
    "raci_state_transition_matrix_ref",
    "scope_boundary",
    "required_packet_fields",
    "required_load_plan_fields",
    "allowed_load_plan_ref_types",
    "allowed_context_budget_units",
    "packet_records",
    "invalid_state_rules",
    "non_claims"
)

$script:RequiredPacketFields = @(
    "packet_id",
    "source_card_id",
    "source_task_id",
    "source_milestone",
    "current_card_state",
    "intended_next_state",
    "target_agent_id",
    "target_role_type",
    "role_identity_ref",
    "memory_scope_refs",
    "raci_transition_refs",
    "allowed_canonical_paths",
    "allowed_evidence_refs",
    "optional_context_refs",
    "forbidden_paths",
    "forbidden_patterns",
    "load_plan",
    "context_budget",
    "allowed_actions",
    "forbidden_actions",
    "required_inputs",
    "required_outputs",
    "evidence_requirements",
    "approval_requirements",
    "escalation_targets",
    "fail_closed_conditions",
    "exit_conditions",
    "non_claims"
)

$script:RequiredLoadPlanFields = @(
    "load_plan_id",
    "allowed_ref_types",
    "exact_canonical_paths",
    "bounded_evidence_refs",
    "memory_scope_refs",
    "raci_transition_refs",
    "exact_canonical_paths_only",
    "bounded_evidence_refs_only",
    "memory_scope_refs_only",
    "raci_transition_refs_only",
    "no_full_repo_scan",
    "no_implicit_historical_memory",
    "no_dynamic_retrieval",
    "no_vector_search",
    "no_external_board_lookup",
    "no_runtime_agent_memory_loading"
)

$script:RequiredLoadPlanRefTypes = @(
    "exact_canonical_paths",
    "bounded_evidence_refs",
    "memory_scope_refs",
    "raci_transition_refs"
)

$script:RequiredScopeBoundary = [ordered]@{
    model_only = $true
    card_reentry_runtime_implemented = $false
    board_routing_runtime_implemented = $false
    actual_agents_implemented = $false
    pm_automation_implemented = $false
    workflow_execution_implemented = $false
    classification_reentry_dry_run_executed = $false
    product_runtime_implemented = $false
    integration_runtime_implemented = $false
    direct_agent_access_runtime_implemented = $false
    true_multi_agent_execution_implemented = $false
    persistent_memory_engine_implemented = $false
    runtime_memory_loading_implemented = $false
    retrieval_engine_implemented = $false
    vector_search_implemented = $false
    external_board_sync_implemented = $false
    r16_opened = $false
    future_runtime_requires_later_task = $true
}

$script:RequiredInvalidRuleIds = @(
    "missing_required_packet_fields",
    "duplicate_packet_ids",
    "unknown_target_agent_id",
    "unknown_memory_scope_ref",
    "unknown_raci_transition_ref",
    "target_role_not_allowed_by_memory_scope",
    "target_role_not_allowed_by_raci_transition",
    "unbounded_full_repo_scan_rejected",
    "wildcard_or_repo_root_allowed_paths_rejected",
    "implicit_memory_loading_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_vector_search_claim_rejected",
    "external_board_sync_claim_rejected",
    "board_routing_runtime_claim_rejected",
    "card_reentry_runtime_claim_rejected",
    "dry_run_executed_claim_rejected",
    "product_runtime_claim_rejected",
    "r16_opening_claim_rejected",
    "status_posture_r15_008_plus_complete_rejected",
    "packet_action_forbidden_by_identity_rejected",
    "packet_access_forbidden_by_memory_scope_rejected",
    "packet_raci_transition_violation_rejected",
    "developer_approve_qa_closeout_rejected",
    "qa_implement_code_rejected",
    "auditor_implement_rejected",
    "pm_implement_or_final_qa_rejected",
    "release_closeout_without_audit_user_approval_rejected"
)

$script:RequiredNonClaims = @(
    "no actual agents implemented by R15-007",
    "no direct agent access runtime implemented",
    "no true multi-agent execution implemented",
    "no persistent memory engine implemented",
    "no runtime memory loading implemented",
    "no retrieval engine implemented",
    "no vector search implemented",
    "no Obsidian integration by R15-007",
    "no external board sync",
    "no GitHub Projects integration",
    "no Linear integration",
    "no Symphony integration",
    "no custom board runtime",
    "no PM automation implemented",
    "no actual workflow execution",
    "no board routing runtime implemented",
    "no card re-entry runtime implemented",
    "no classification/re-entry dry run executed",
    "no final R15 proof package complete",
    "no product runtime",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "no R16 opening"
)

$script:OverclaimPatterns = @(
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
    "board routing runtime implemented",
    "board routing implemented",
    "card re-entry runtime",
    "card reentry runtime",
    "card re-entry packet runtime",
    "classification/re-entry dry run",
    "classification and re-entry dry run",
    "dry run executed",
    "final R15 proof package complete",
    "product runtime",
    "production runtime",
    "productized UI",
    "solved Codex reliability",
    "solved Codex compaction",
    "solved Codex context compaction",
    "R16 opening",
    "R16 opened",
    "R16 active",
    "full repo scan",
    "full-repo scan",
    "implicit memory loading",
    "dynamic retrieval",
    "external board lookup"
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

function Assert-PositiveInteger {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }
    if ([int64]$Value -lt 0) {
        throw "$Context must not be negative."
    }

    return [int64]$Value
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

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed|reject|rejected|fails validation|fail validation|claim fails|model-only|model only|future runtime requires later task|bounded|only)\b|any .{0,30}claim'
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

function Assert-NoBroadPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Path -in @(".", ".\", "./", "*", "**", "**/*", "/", "\", "repo", "repository", "full_repo", "entire_repo")) {
        throw "$Context allows full repo scan by path '$Path'."
    }

    if ($Path -match '(^|[\\/])\*\*($|[\\/])' -or $Path -match '^\*\*' -or $Path -match '(?i)full[-_ ]?repo|entire[-_ ]?repo|whole[-_ ]?repository|repo[-_ ]?root') {
        throw "$Context allows full repo scan by path '$Path'."
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

function Assert-R15CardReentryPacketStatusPosture {
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
            throw "R15-007 status posture check could not find '$relativePath'."
        }
        $texts[$relativePath] = Get-Content -LiteralPath $path -Raw
    }

    $kanbanStatus = Get-R15TaskStatusMap -Text $texts["execution\KANBAN.md"] -Context "KANBAN"
    $authorityStatus = Get-R15TaskStatusMap -Text $texts["governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"] -Context "R15 authority"
    foreach ($taskId in @("R15-001", "R15-002", "R15-003", "R15-004", "R15-005", "R15-006", "R15-007", "R15-008")) {
        if ($kanbanStatus[$taskId] -ne "done" -or $authorityStatus[$taskId] -ne "done") {
            throw "R15 status posture must mark $taskId done for current R15 validation compatibility."
        }
    }
    if ($kanbanStatus["R15-009"] -ne "planned" -or $authorityStatus["R15-009"] -ne "planned") {
        throw "R15 status posture must keep R15-009 planned only."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R15 active through `?R15-008`? only|Active in repo truth through `R15-008` only|through `R15-008` only' -Message "Status docs must state R15 is active through R15-008 only."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)`?R15-009`?\s+planned only|R15-009 remains planned only|R15-009 planned only' -Message "Status docs must keep R15-009 planned only."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R13 remains failed/partial.*R13-018|R13 API-First QA Pipeline and Operator Control-Room Product Slice` remains failed/partial' -Message "Status docs must preserve R13 failed/partial through R13-018."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R14.*accepted.*R14-006|accepted with caveats.*R14-006' -Message "Status docs must preserve R14 accepted with caveats through R14-006."
    Assert-RegexMatch -Text $texts["governance\DECISION_LOG.md"] -Pattern 'R15-007 Defined Card Re-entry Packet Model' -Message "DECISION_LOG must record the R15-007 card re-entry packet model decision."

    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-007 status docs" -ClaimLabel "R16 or successor opening" -Pattern '(?i)\bR16\b.{0,120}\b(active|open|opened|marked active)\b|\bsuccessor milestone\b.{0,120}\b(is now active|is active|marked active|opens on branch|opened on branch)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-007 status docs" -ClaimLabel "R15-009 completion" -Pattern '(?i)\bR15-009\b.{0,160}\b(done|complete|completed|implemented|executed|ran)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-007 status docs" -ClaimLabel "runtime or integration overclaim" -Pattern '(?i)\b(actual agents implemented|agent runtime|direct agent access runtime|true multi-agent execution|multi-agent runtime|persistent memory engine|runtime memory loading|retrieval engine|vector search|Obsidian integration|card re-entry runtime|card reentry runtime|final R15 proof package complete|product runtime|production runtime|board runtime|external board sync|Linear integration|Symphony integration|GitHub Projects integration|custom board runtime|custom board implementation|PM automation|actual workflow execution|workflow execution implemented|board routing runtime|solved Codex reliability|solved Codex compaction)\b'
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

function Get-R15CardReentryPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    return Read-SingleJsonObject -Path $PacketPath -Label "R15 card re-entry packet model"
}

function Test-R15CardReentryPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketModel,
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [Parameter(Mandatory = $true)]
        $KnowledgeIndex,
        [Parameter(Mandatory = $true)]
        $AgentIdentityPacket,
        [Parameter(Mandatory = $true)]
        $AgentMemoryScope,
        [Parameter(Mandatory = $true)]
        $RaciStateTransitionMatrix,
        [string]$SourceLabel = "R15 card re-entry packet model"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $PacketModel -Name $field -Context $SourceLabel | Out-Null
    }

    if ($PacketModel.artifact_type -ne "r15_card_reentry_packet_model") {
        throw "$SourceLabel artifact_type must be 'r15_card_reentry_packet_model'."
    }
    Assert-NonEmptyString -Value $PacketModel.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $PacketModel.packet_model_id -Context "$SourceLabel packet_model_id" | Out-Null
    if ($PacketModel.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($PacketModel.source_task -ne "R15-007") {
        throw "$SourceLabel source_task must be R15-007."
    }
    Assert-NonEmptyString -Value $PacketModel.repository -Context "$SourceLabel repository" | Out-Null
    Assert-NonEmptyString -Value $PacketModel.branch -Context "$SourceLabel branch" | Out-Null
    Assert-NonEmptyString -Value $PacketModel.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $PacketModel.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-ObjectValue -Value $PacketModel.taxonomy_ref -Context "$SourceLabel taxonomy_ref" | Out-Null
    foreach ($field in @("taxonomy_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $PacketModel.taxonomy_ref -Name $field -Context "$SourceLabel taxonomy_ref" | Out-Null
    }
    Assert-PathExists -Path $PacketModel.taxonomy_ref.path -Context "$SourceLabel taxonomy_ref" | Out-Null
    Assert-PathExists -Path $PacketModel.taxonomy_ref.contract_path -Context "$SourceLabel taxonomy_ref" | Out-Null
    if ($PacketModel.taxonomy_ref.taxonomy_id -ne $Taxonomy.taxonomy_id -or $PacketModel.taxonomy_ref.source_task -ne "R15-002") {
        throw "$SourceLabel taxonomy_ref must point to the R15-002 taxonomy dependency."
    }
    Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency" | Out-Null

    Assert-ObjectValue -Value $PacketModel.knowledge_index_ref -Context "$SourceLabel knowledge_index_ref" | Out-Null
    foreach ($field in @("index_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $PacketModel.knowledge_index_ref -Name $field -Context "$SourceLabel knowledge_index_ref" | Out-Null
    }
    Assert-PathExists -Path $PacketModel.knowledge_index_ref.path -Context "$SourceLabel knowledge_index_ref" | Out-Null
    Assert-PathExists -Path $PacketModel.knowledge_index_ref.contract_path -Context "$SourceLabel knowledge_index_ref" | Out-Null
    if ($PacketModel.knowledge_index_ref.index_id -ne $KnowledgeIndex.index_id -or $PacketModel.knowledge_index_ref.source_task -ne "R15-003") {
        throw "$SourceLabel knowledge_index_ref must point to the R15-003 repo knowledge index dependency."
    }
    Test-R15RepoKnowledgeIndexObject -Index $KnowledgeIndex -Taxonomy $Taxonomy -SourceLabel "$SourceLabel knowledge index dependency" | Out-Null

    Assert-ObjectValue -Value $PacketModel.agent_identity_packet_ref -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    foreach ($field in @("packet_set_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $PacketModel.agent_identity_packet_ref -Name $field -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    }
    Assert-PathExists -Path $PacketModel.agent_identity_packet_ref.path -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    Assert-PathExists -Path $PacketModel.agent_identity_packet_ref.contract_path -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    if ($PacketModel.agent_identity_packet_ref.packet_set_id -ne $AgentIdentityPacket.packet_set_id -or $PacketModel.agent_identity_packet_ref.source_task -ne "R15-004") {
        throw "$SourceLabel agent_identity_packet_ref must point to the R15-004 identity packet dependency."
    }
    Test-R15AgentIdentityPacketObject -Packet $AgentIdentityPacket -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -SourceLabel "$SourceLabel agent identity dependency" | Out-Null

    Assert-ObjectValue -Value $PacketModel.agent_memory_scope_ref -Context "$SourceLabel agent_memory_scope_ref" | Out-Null
    foreach ($field in @("memory_scope_model_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $PacketModel.agent_memory_scope_ref -Name $field -Context "$SourceLabel agent_memory_scope_ref" | Out-Null
    }
    Assert-PathExists -Path $PacketModel.agent_memory_scope_ref.path -Context "$SourceLabel agent_memory_scope_ref" | Out-Null
    Assert-PathExists -Path $PacketModel.agent_memory_scope_ref.contract_path -Context "$SourceLabel agent_memory_scope_ref" | Out-Null
    if ($PacketModel.agent_memory_scope_ref.memory_scope_model_id -ne $AgentMemoryScope.memory_scope_model_id -or $PacketModel.agent_memory_scope_ref.source_task -ne "R15-005") {
        throw "$SourceLabel agent_memory_scope_ref must point to the R15-005 memory scope dependency."
    }
    Test-R15AgentMemoryScopeObject -ScopeModel $AgentMemoryScope -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -SourceLabel "$SourceLabel memory scope dependency" | Out-Null

    Assert-ObjectValue -Value $PacketModel.raci_state_transition_matrix_ref -Context "$SourceLabel raci_state_transition_matrix_ref" | Out-Null
    foreach ($field in @("matrix_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $PacketModel.raci_state_transition_matrix_ref -Name $field -Context "$SourceLabel raci_state_transition_matrix_ref" | Out-Null
    }
    Assert-PathExists -Path $PacketModel.raci_state_transition_matrix_ref.path -Context "$SourceLabel raci_state_transition_matrix_ref" | Out-Null
    Assert-PathExists -Path $PacketModel.raci_state_transition_matrix_ref.contract_path -Context "$SourceLabel raci_state_transition_matrix_ref" | Out-Null
    if ($PacketModel.raci_state_transition_matrix_ref.matrix_id -ne $RaciStateTransitionMatrix.matrix_id -or $PacketModel.raci_state_transition_matrix_ref.source_task -ne "R15-006") {
        throw "$SourceLabel raci_state_transition_matrix_ref must point to the R15-006 RACI dependency."
    }
    Test-R15RaciStateTransitionMatrixObject -Matrix $RaciStateTransitionMatrix -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -AgentMemoryScope $AgentMemoryScope -SourceLabel "$SourceLabel RACI dependency" | Out-Null

    Assert-ObjectValue -Value $PacketModel.scope_boundary -Context "$SourceLabel scope_boundary" | Out-Null
    foreach ($boundaryKey in $script:RequiredScopeBoundary.Keys) {
        Get-RequiredProperty -Object $PacketModel.scope_boundary -Name $boundaryKey -Context "$SourceLabel scope_boundary" | Out-Null
        $actual = Assert-BooleanValue -Value $PacketModel.scope_boundary.$boundaryKey -Context "$SourceLabel scope_boundary $boundaryKey"
        if ($actual -ne $script:RequiredScopeBoundary[$boundaryKey]) {
            throw "$SourceLabel scope_boundary $boundaryKey must be $($script:RequiredScopeBoundary[$boundaryKey])."
        }
    }

    $requiredPacketFields = Assert-StringArray -Value $PacketModel.required_packet_fields -Context "$SourceLabel required_packet_fields"
    Assert-RequiredValuesPresent -Values $requiredPacketFields -RequiredValues $script:RequiredPacketFields -Context "$SourceLabel required_packet_fields"
    $requiredLoadPlanFields = Assert-StringArray -Value $PacketModel.required_load_plan_fields -Context "$SourceLabel required_load_plan_fields"
    Assert-RequiredValuesPresent -Values $requiredLoadPlanFields -RequiredValues $script:RequiredLoadPlanFields -Context "$SourceLabel required_load_plan_fields"
    $allowedLoadPlanRefTypes = Assert-StringArray -Value $PacketModel.allowed_load_plan_ref_types -Context "$SourceLabel allowed_load_plan_ref_types"
    Assert-RequiredValuesPresent -Values $allowedLoadPlanRefTypes -RequiredValues $script:RequiredLoadPlanRefTypes -Context "$SourceLabel allowed_load_plan_ref_types"
    $allowedContextBudgetUnits = Assert-StringArray -Value $PacketModel.allowed_context_budget_units -Context "$SourceLabel allowed_context_budget_units"

    $invalidStateRules = Assert-ObjectArray -Value $PacketModel.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $invalidRuleMap = New-ValueSet -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules"
    foreach ($requiredRuleId in $script:RequiredInvalidRuleIds) {
        if (-not $invalidRuleMap.ContainsKey($requiredRuleId)) {
            throw "$SourceLabel missing required invalid-state rule '$requiredRuleId'."
        }
    }
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rule") -Context "$SourceLabel invalid_state_rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $PacketModel.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"
    if (Test-HasProperty -Object $PacketModel -Name "claims") {
        Assert-NoOverclaimText -Values (Assert-StringArray -Value $PacketModel.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    }

    $agentMap = @{}
    foreach ($role in @($AgentIdentityPacket.roles)) {
        $agentMap[[string]$role.agent_id] = $role
    }

    $scopeMap = @{}
    foreach ($scope in @($AgentMemoryScope.memory_scopes)) {
        $scopeMap[[string]$scope.scope_id] = $scope
    }

    $roleAccessMap = @{}
    foreach ($access in @($AgentMemoryScope.role_memory_access_matrix)) {
        $roleAccessMap[[string]$access.agent_id] = $access
    }

    $transitionMap = @{}
    foreach ($transition in @($RaciStateTransitionMatrix.transition_matrix)) {
        $transitionMap[[string]$transition.transition_id] = $transition
    }

    $dependencyPaths = @(
        [string]$PacketModel.taxonomy_ref.path,
        [string]$PacketModel.taxonomy_ref.contract_path,
        [string]$PacketModel.knowledge_index_ref.path,
        [string]$PacketModel.knowledge_index_ref.contract_path,
        [string]$PacketModel.agent_identity_packet_ref.path,
        [string]$PacketModel.agent_identity_packet_ref.contract_path,
        [string]$PacketModel.agent_memory_scope_ref.path,
        [string]$PacketModel.agent_memory_scope_ref.contract_path,
        [string]$PacketModel.raci_state_transition_matrix_ref.path,
        [string]$PacketModel.raci_state_transition_matrix_ref.contract_path
    )

    $packets = Assert-ObjectArray -Value $PacketModel.packet_records -Context "$SourceLabel packet_records"
    $packetMap = New-ValueSet -Items $packets -FieldName "packet_id" -Context "$SourceLabel packet_records"

    foreach ($packet in $packets) {
        $packetId = [string]$packet.packet_id
        foreach ($requiredField in $requiredPacketFields) {
            Get-RequiredProperty -Object $packet -Name $requiredField -Context "$SourceLabel packet '$packetId'" | Out-Null
        }

        Assert-NonEmptyString -Value $packet.source_card_id -Context "$SourceLabel packet '$packetId' source_card_id" | Out-Null
        Assert-NonEmptyString -Value $packet.source_task_id -Context "$SourceLabel packet '$packetId' source_task_id" | Out-Null
        Assert-NonEmptyString -Value $packet.source_milestone -Context "$SourceLabel packet '$packetId' source_milestone" | Out-Null
        $currentState = Assert-NonEmptyString -Value $packet.current_card_state -Context "$SourceLabel packet '$packetId' current_card_state"
        $intendedState = Assert-NonEmptyString -Value $packet.intended_next_state -Context "$SourceLabel packet '$packetId' intended_next_state"
        $targetAgentId = Assert-NonEmptyString -Value $packet.target_agent_id -Context "$SourceLabel packet '$packetId' target_agent_id"
        if (-not $agentMap.ContainsKey($targetAgentId)) {
            throw "$SourceLabel packet '$packetId' references unknown target_agent_id '$targetAgentId'."
        }
        $targetRole = $agentMap[$targetAgentId]
        $targetRoleType = Assert-NonEmptyString -Value $packet.target_role_type -Context "$SourceLabel packet '$packetId' target_role_type"
        if ($targetRoleType -ne [string]$targetRole.role_type) {
            throw "$SourceLabel packet '$packetId' target_role_type must match R15-004 identity role_type."
        }
        if ([string]$packet.role_identity_ref -ne $targetAgentId) {
            throw "$SourceLabel packet '$packetId' role_identity_ref must match target_agent_id."
        }

        if (-not $roleAccessMap.ContainsKey($targetAgentId)) {
            throw "$SourceLabel packet '$packetId' target_agent_id '$targetAgentId' has no R15-005 role memory access record."
        }
        $roleAccess = $roleAccessMap[$targetAgentId]

        $memoryScopeRefs = Assert-StringArray -Value $packet.memory_scope_refs -Context "$SourceLabel packet '$packetId' memory_scope_refs"
        $raciTransitionRefs = Assert-StringArray -Value $packet.raci_transition_refs -Context "$SourceLabel packet '$packetId' raci_transition_refs"
        $allowedCanonicalPaths = Assert-StringArray -Value $packet.allowed_canonical_paths -Context "$SourceLabel packet '$packetId' allowed_canonical_paths"
        $allowedEvidenceRefs = Assert-StringArray -Value $packet.allowed_evidence_refs -Context "$SourceLabel packet '$packetId' allowed_evidence_refs"
        $optionalContextRefs = Assert-StringArray -Value $packet.optional_context_refs -Context "$SourceLabel packet '$packetId' optional_context_refs" -AllowEmpty
        $forbiddenPaths = Assert-StringArray -Value $packet.forbidden_paths -Context "$SourceLabel packet '$packetId' forbidden_paths"
        $forbiddenPatterns = Assert-StringArray -Value $packet.forbidden_patterns -Context "$SourceLabel packet '$packetId' forbidden_patterns"
        $allowedActions = Assert-StringArray -Value $packet.allowed_actions -Context "$SourceLabel packet '$packetId' allowed_actions"
        $forbiddenActions = Assert-StringArray -Value $packet.forbidden_actions -Context "$SourceLabel packet '$packetId' forbidden_actions"
        Assert-StringArray -Value $packet.required_inputs -Context "$SourceLabel packet '$packetId' required_inputs" | Out-Null
        Assert-StringArray -Value $packet.required_outputs -Context "$SourceLabel packet '$packetId' required_outputs" | Out-Null
        $evidenceRequirements = Assert-StringArray -Value $packet.evidence_requirements -Context "$SourceLabel packet '$packetId' evidence_requirements"
        $escalationTargets = Assert-StringArray -Value $packet.escalation_targets -Context "$SourceLabel packet '$packetId' escalation_targets" -AllowEmpty
        Assert-StringArray -Value $packet.fail_closed_conditions -Context "$SourceLabel packet '$packetId' fail_closed_conditions" | Out-Null
        Assert-StringArray -Value $packet.exit_conditions -Context "$SourceLabel packet '$packetId' exit_conditions" | Out-Null
        $packetNonClaims = Assert-StringArray -Value $packet.non_claims -Context "$SourceLabel packet '$packetId' non_claims"
        $allowedActionText = [string]::Join(" | ", $allowedActions)
        $positiveAllowedActionText = [string]::Join(" | ", @($allowedActions | Where-Object { $_ -notmatch '(?i)\b(must not|do not|cannot|forbidden|prohibited|disallowed)\b' }))

        if ($targetAgentId -eq "developer" -and ($intendedState -in @("qa_passed", "audit_accepted", "approved_for_closeout", "closed") -or $positiveAllowedActionText -match '(?i)\b(QA pass|final QA|close|closeout|approve)\b')) {
            throw "$SourceLabel packet '$packetId' developer packet cannot approve QA or closeout."
        }

        foreach ($scopeId in $memoryScopeRefs) {
            if (-not $scopeMap.ContainsKey($scopeId)) {
                throw "$SourceLabel packet '$packetId' references unknown memory_scope_ref '$scopeId'."
            }
            if (@($roleAccess.allowed_scope_ids) -notcontains $scopeId) {
                throw "$SourceLabel packet '$packetId' target role '$targetAgentId' is not allowed memory scope '$scopeId'."
            }
            if (@($roleAccess.prohibited_scope_ids) -contains $scopeId) {
                throw "$SourceLabel packet '$packetId' target role '$targetAgentId' is prohibited from memory scope '$scopeId'."
            }
            $scope = $scopeMap[$scopeId]
            if (@($scope.allowed_agent_ids) -notcontains $targetAgentId -or @($scope.role_types) -notcontains $targetRoleType) {
                throw "$SourceLabel packet '$packetId' target role '$targetAgentId' is not allowed by memory scope '$scopeId'."
            }
        }

        $allowedPathUniverse = @($dependencyPaths)
        $scopeForbiddenPaths = @()
        foreach ($scopeId in $memoryScopeRefs) {
            $scope = $scopeMap[$scopeId]
            $allowedPathUniverse += @($scope.canonical_paths)
            $allowedPathUniverse += @($scope.optional_paths)
            $scopeForbiddenPaths += @($scope.forbidden_paths)
        }

        foreach ($path in @($allowedCanonicalPaths + $optionalContextRefs)) {
            Assert-NoBroadPath -Path $path -Context "$SourceLabel packet '$packetId'"
            if ($path -match '[*]') {
                throw "$SourceLabel packet '$packetId' allows wildcard path '$path'."
            }
            if ($allowedPathUniverse -notcontains $path) {
                throw "$SourceLabel packet '$packetId' allowed path '$path' is not authorized by memory scopes or dependency refs."
            }
            foreach ($forbiddenPath in @($forbiddenPaths + $scopeForbiddenPaths)) {
                if (-not [string]::IsNullOrWhiteSpace($forbiddenPath) -and ($path -eq $forbiddenPath -or $path.StartsWith($forbiddenPath))) {
                    throw "$SourceLabel packet '$packetId' allowed path '$path' is forbidden by memory scope or packet path '$forbiddenPath'."
                }
            }
            Assert-PathExists -Path $path -Context "$SourceLabel packet '$packetId' allowed_canonical_paths" | Out-Null
        }

        Assert-RequiredValuesPresent -Values $forbiddenPatterns -RequiredValues @("full_repo_scan", "implicit_memory_loading", "persistent_memory_runtime_claim", "runtime_agent_memory_loading", "dynamic_retrieval", "vector_search", "external_board_lookup", "board_routing_runtime_claim", "card_reentry_runtime_claim", "dry_run_executed_claim", "r16_opening_claim") -Context "$SourceLabel packet '$packetId' forbidden_patterns"

        foreach ($transitionId in $raciTransitionRefs) {
            if (-not $transitionMap.ContainsKey($transitionId)) {
                throw "$SourceLabel packet '$packetId' references unknown raci_transition_ref '$transitionId'."
            }
            $transition = $transitionMap[$transitionId]
            if ([string]$transition.from_state_id -ne $currentState -or [string]$transition.to_state_id -ne $intendedState) {
                throw "$SourceLabel packet '$packetId' violates R15-006 transition '$transitionId' state rule."
            }
            $transitionAgentRefs = @($transition.responsible_agent_ids) + @($transition.accountable_agent_id) + @($transition.allowed_proposers) + @($transition.allowed_executors) + @($transition.allowed_verifiers) + @($transition.required_approvers)
            if ($transitionAgentRefs -notcontains $targetAgentId) {
                throw "$SourceLabel packet '$packetId' target role '$targetAgentId' is not allowed by RACI transition '$transitionId'."
            }
            if (@($transition.prohibited_agents) -contains $targetAgentId) {
                throw "$SourceLabel packet '$packetId' target role '$targetAgentId' is prohibited by RACI transition '$transitionId'."
            }
            foreach ($requiredEvidenceRef in @($transition.required_evidence_refs)) {
                if ($allowedEvidenceRefs -notcontains $requiredEvidenceRef -and $evidenceRequirements -notcontains $requiredEvidenceRef) {
                    throw "$SourceLabel packet '$packetId' omits RACI-required evidence ref '$requiredEvidenceRef'."
                }
            }
        }

        foreach ($target in $escalationTargets) {
            if (-not $agentMap.ContainsKey($target)) {
                throw "$SourceLabel packet '$packetId' escalation target '$target' is not a known R15-004 agent_id."
            }
        }

        if ($targetAgentId -eq "qa_test_agent" -and $positiveAllowedActionText -match '(?i)\b(implement|write scoped code|fix code)\b') {
            throw "$SourceLabel packet '$packetId' QA packet cannot implement code as final QA scope."
        }
        if ($targetAgentId -eq "evidence_auditor" -and $positiveAllowedActionText -match '(?i)\b(implement|write scoped code|fix code)\b') {
            throw "$SourceLabel packet '$packetId' auditor packet cannot implement."
        }
        if ($targetAgentId -eq "project_manager" -and $positiveAllowedActionText -match '(?i)\b(implement code|write scoped code|execute final QA|final QA)\b') {
            throw "$SourceLabel packet '$packetId' PM packet cannot implement code or own final QA."
        }

        foreach ($allowedAction in $allowedActions) {
            if (@($targetRole.allowed_actions) -notcontains $allowedAction) {
                throw "$SourceLabel packet '$packetId' allowed action '$allowedAction' is not allowed by R15-004 identity '$targetAgentId'."
            }
            if (@($targetRole.forbidden_actions) -contains $allowedAction -or @($targetRole.forbidden_tool_classes) -contains $allowedAction) {
                throw "$SourceLabel packet '$packetId' allows forbidden action '$allowedAction' from R15-004 identity '$targetAgentId'."
            }
        }

        foreach ($identityForbiddenAction in @($targetRole.forbidden_actions)) {
            if ($forbiddenActions -notcontains $identityForbiddenAction) {
                throw "$SourceLabel packet '$packetId' forbidden_actions must include R15-004 forbidden action '$identityForbiddenAction'."
            }
        }

        Assert-ObjectValue -Value $packet.load_plan -Context "$SourceLabel packet '$packetId' load_plan" | Out-Null
        foreach ($loadPlanField in $requiredLoadPlanFields) {
            Get-RequiredProperty -Object $packet.load_plan -Name $loadPlanField -Context "$SourceLabel packet '$packetId' load_plan" | Out-Null
        }
        Assert-NonEmptyString -Value $packet.load_plan.load_plan_id -Context "$SourceLabel packet '$packetId' load_plan load_plan_id" | Out-Null
        $loadPlanRefTypes = Assert-StringArray -Value $packet.load_plan.allowed_ref_types -Context "$SourceLabel packet '$packetId' load_plan allowed_ref_types"
        Assert-RequiredValuesPresent -Values $loadPlanRefTypes -RequiredValues $script:RequiredLoadPlanRefTypes -Context "$SourceLabel packet '$packetId' load_plan allowed_ref_types"
        $loadPlanPaths = Assert-StringArray -Value $packet.load_plan.exact_canonical_paths -Context "$SourceLabel packet '$packetId' load_plan exact_canonical_paths"
        $loadPlanEvidenceRefs = Assert-StringArray -Value $packet.load_plan.bounded_evidence_refs -Context "$SourceLabel packet '$packetId' load_plan bounded_evidence_refs"
        $loadPlanScopeRefs = Assert-StringArray -Value $packet.load_plan.memory_scope_refs -Context "$SourceLabel packet '$packetId' load_plan memory_scope_refs"
        $loadPlanTransitionRefs = Assert-StringArray -Value $packet.load_plan.raci_transition_refs -Context "$SourceLabel packet '$packetId' load_plan raci_transition_refs"

        foreach ($path in $loadPlanPaths) {
            if ($allowedCanonicalPaths -notcontains $path) {
                throw "$SourceLabel packet '$packetId' load_plan path '$path' is not in allowed_canonical_paths."
            }
        }
        foreach ($evidenceRef in $loadPlanEvidenceRefs) {
            if ($allowedEvidenceRefs -notcontains $evidenceRef) {
                throw "$SourceLabel packet '$packetId' load_plan evidence ref '$evidenceRef' is not in allowed_evidence_refs."
            }
        }
        foreach ($scopeId in $loadPlanScopeRefs) {
            if ($memoryScopeRefs -notcontains $scopeId) {
                throw "$SourceLabel packet '$packetId' load_plan memory scope '$scopeId' is not in memory_scope_refs."
            }
        }
        foreach ($transitionId in $loadPlanTransitionRefs) {
            if ($raciTransitionRefs -notcontains $transitionId) {
                throw "$SourceLabel packet '$packetId' load_plan transition '$transitionId' is not in raci_transition_refs."
            }
        }
        foreach ($flag in @("exact_canonical_paths_only", "bounded_evidence_refs_only", "memory_scope_refs_only", "raci_transition_refs_only", "no_full_repo_scan", "no_implicit_historical_memory", "no_dynamic_retrieval", "no_vector_search", "no_external_board_lookup", "no_runtime_agent_memory_loading")) {
            if (-not (Assert-BooleanValue -Value $packet.load_plan.$flag -Context "$SourceLabel packet '$packetId' load_plan $flag")) {
                throw "$SourceLabel packet '$packetId' load_plan $flag must be true."
            }
        }

        Assert-ObjectValue -Value $packet.context_budget -Context "$SourceLabel packet '$packetId' context_budget" | Out-Null
        foreach ($field in @("max_files", "max_evidence_refs", "max_memory_scope_refs", "max_transition_refs", "max_notes_chars", "budget_unit")) {
            Get-RequiredProperty -Object $packet.context_budget -Name $field -Context "$SourceLabel packet '$packetId' context_budget" | Out-Null
        }
        if ($allowedContextBudgetUnits -notcontains [string]$packet.context_budget.budget_unit) {
            throw "$SourceLabel packet '$packetId' context_budget uses invalid budget_unit '$($packet.context_budget.budget_unit)'."
        }
        if ((Assert-PositiveInteger -Value $packet.context_budget.max_files -Context "$SourceLabel packet '$packetId' context_budget max_files") -lt $loadPlanPaths.Count) {
            throw "$SourceLabel packet '$packetId' context_budget max_files is smaller than load_plan exact paths."
        }
        if ((Assert-PositiveInteger -Value $packet.context_budget.max_evidence_refs -Context "$SourceLabel packet '$packetId' context_budget max_evidence_refs") -lt $loadPlanEvidenceRefs.Count) {
            throw "$SourceLabel packet '$packetId' context_budget max_evidence_refs is smaller than load_plan evidence refs."
        }
        if ((Assert-PositiveInteger -Value $packet.context_budget.max_memory_scope_refs -Context "$SourceLabel packet '$packetId' context_budget max_memory_scope_refs") -lt $loadPlanScopeRefs.Count) {
            throw "$SourceLabel packet '$packetId' context_budget max_memory_scope_refs is smaller than load_plan memory scope refs."
        }
        if ((Assert-PositiveInteger -Value $packet.context_budget.max_transition_refs -Context "$SourceLabel packet '$packetId' context_budget max_transition_refs") -lt $loadPlanTransitionRefs.Count) {
            throw "$SourceLabel packet '$packetId' context_budget max_transition_refs is smaller than load_plan transition refs."
        }
        Assert-PositiveInteger -Value $packet.context_budget.max_notes_chars -Context "$SourceLabel packet '$packetId' context_budget max_notes_chars" | Out-Null

        Assert-ObjectValue -Value $packet.approval_requirements -Context "$SourceLabel packet '$packetId' approval_requirements" | Out-Null
        foreach ($field in @("user_approval_required", "pm_approval_required", "qa_evidence_required", "audit_evidence_required", "release_evidence_required", "approval_refs")) {
            Get-RequiredProperty -Object $packet.approval_requirements -Name $field -Context "$SourceLabel packet '$packetId' approval_requirements" | Out-Null
        }
        foreach ($field in @("user_approval_required", "pm_approval_required", "qa_evidence_required", "audit_evidence_required", "release_evidence_required")) {
            Assert-BooleanValue -Value $packet.approval_requirements.$field -Context "$SourceLabel packet '$packetId' approval_requirements $field" | Out-Null
        }
        $approvalRefs = Assert-StringArray -Value $packet.approval_requirements.approval_refs -Context "$SourceLabel packet '$packetId' approval_requirements approval_refs" -AllowEmpty

        if ($targetAgentId -eq "release_closeout_agent" -and $intendedState -eq "closed") {
            if (-not [bool]$packet.approval_requirements.user_approval_required -or -not [bool]$packet.approval_requirements.audit_evidence_required -or -not [bool]$packet.approval_requirements.release_evidence_required -or $approvalRefs -notcontains "user_approval_ref" -or $allowedEvidenceRefs -notcontains "audit_accepted_state_ref" -or $allowedEvidenceRefs -notcontains "release_closeout_evidence_ref") {
                throw "$SourceLabel packet '$packetId' release_closeout_agent packet cannot close without audit and user approval requirements."
            }
        }

        foreach ($transitionId in $raciTransitionRefs) {
            $transition = $transitionMap[$transitionId]
            if ([bool]$transition.requires_user_approval -and (-not [bool]$packet.approval_requirements.user_approval_required -or $approvalRefs -notcontains "user_approval_ref")) {
                throw "$SourceLabel packet '$packetId' transition '$transitionId' requires user approval but packet approval_requirements do not include it."
            }
            if ([bool]$transition.requires_qa_evidence -and -not [bool]$packet.approval_requirements.qa_evidence_required) {
                throw "$SourceLabel packet '$packetId' transition '$transitionId' requires QA evidence but packet approval_requirements omit it."
            }
            if ([bool]$transition.requires_audit_evidence -and -not [bool]$packet.approval_requirements.audit_evidence_required) {
                throw "$SourceLabel packet '$packetId' transition '$transitionId' requires audit evidence but packet approval_requirements omit it."
            }
            if ([bool]$transition.requires_release_closeout_evidence -and -not [bool]$packet.approval_requirements.release_evidence_required) {
                throw "$SourceLabel packet '$packetId' transition '$transitionId' requires release closeout evidence but packet approval_requirements omit it."
            }
        }

        $allowedActionText = [string]::Join(" | ", $allowedActions)
        $positiveAllowedActionText = [string]::Join(" | ", @($allowedActions | Where-Object { $_ -notmatch '(?i)\b(must not|do not|cannot|forbidden|prohibited|disallowed)\b' }))
        if ($targetAgentId -eq "developer" -and ($intendedState -in @("qa_passed", "audit_accepted", "approved_for_closeout", "closed") -or $positiveAllowedActionText -match '(?i)\b(QA pass|final QA|close|closeout|approve)\b')) {
            throw "$SourceLabel packet '$packetId' developer packet cannot approve QA or closeout."
        }
        if ($targetAgentId -eq "qa_test_agent" -and $positiveAllowedActionText -match '(?i)\b(implement|write scoped code|fix code)\b') {
            throw "$SourceLabel packet '$packetId' QA packet cannot implement code as final QA scope."
        }
        if ($targetAgentId -eq "evidence_auditor" -and $positiveAllowedActionText -match '(?i)\b(implement|write scoped code|fix code)\b') {
            throw "$SourceLabel packet '$packetId' auditor packet cannot implement."
        }
        if ($targetAgentId -eq "project_manager" -and $positiveAllowedActionText -match '(?i)\b(implement code|write scoped code|execute final QA|final QA)\b') {
            throw "$SourceLabel packet '$packetId' PM packet cannot implement code or own final QA."
        }
        if ($targetAgentId -eq "release_closeout_agent" -and $intendedState -eq "closed") {
            if (-not [bool]$packet.approval_requirements.user_approval_required -or -not [bool]$packet.approval_requirements.audit_evidence_required -or -not [bool]$packet.approval_requirements.release_evidence_required -or $approvalRefs -notcontains "user_approval_ref" -or $allowedEvidenceRefs -notcontains "audit_accepted_state_ref" -or $allowedEvidenceRefs -notcontains "release_closeout_evidence_ref") {
                throw "$SourceLabel packet '$packetId' release_closeout_agent packet cannot close without audit and user approval requirements."
            }
        }

        $packetText = @(Get-StringValuesFromObject -Value $packet)
        Assert-NoOverclaimText -Values $packetText -Context "$SourceLabel packet '$packetId'"
        Assert-NoOverclaimText -Values $packetNonClaims -Context "$SourceLabel packet '$packetId' non_claims"
    }

    $allText = @(Get-StringValuesFromObject -Value $PacketModel)
    Assert-NoOverclaimText -Values $allText -Context $SourceLabel

    return [pscustomobject]@{
        ArtifactType = $PacketModel.artifact_type
        PacketModelId = $PacketModel.packet_model_id
        SourceTask = $PacketModel.source_task
        PacketCount = $packets.Count
        PacketIdCount = $packetMap.Count
        ModelOnly = [bool]$PacketModel.scope_boundary.model_only
        CardReentryRuntimeImplemented = [bool]$PacketModel.scope_boundary.card_reentry_runtime_implemented
        BoardRoutingRuntimeImplemented = [bool]$PacketModel.scope_boundary.board_routing_runtime_implemented
        ActualAgentsImplemented = [bool]$PacketModel.scope_boundary.actual_agents_implemented
        ClassificationReentryDryRunExecuted = [bool]$PacketModel.scope_boundary.classification_reentry_dry_run_executed
        ProductRuntimeImplemented = [bool]$PacketModel.scope_boundary.product_runtime_implemented
        IntegrationRuntimeImplemented = [bool]$PacketModel.scope_boundary.integration_runtime_implemented
        R16Opened = [bool]$PacketModel.scope_boundary.r16_opened
    }
}

function Test-R15CardReentryPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath,
        [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
        [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
        [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
        [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
        [string]$RaciStateTransitionMatrixPath = "state\agents\r15_raci_state_transition_matrix.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $packetModel = Get-R15CardReentryPacket -PacketPath $PacketPath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    $knowledgeIndex = Get-R15RepoKnowledgeIndex -IndexPath $KnowledgeIndexPath
    $agentIdentityPacket = Get-R15AgentIdentityPacket -PacketPath $AgentIdentityPacketPath
    $agentMemoryScope = Get-R15AgentMemoryScope -ScopePath $AgentMemoryScopePath
    $raciStateTransitionMatrix = Get-R15RaciStateTransitionMatrix -MatrixPath $RaciStateTransitionMatrixPath
    $result = Test-R15CardReentryPacketObject -PacketModel $packetModel -Taxonomy $taxonomy -KnowledgeIndex $knowledgeIndex -AgentIdentityPacket $agentIdentityPacket -AgentMemoryScope $agentMemoryScope -RaciStateTransitionMatrix $raciStateTransitionMatrix -SourceLabel $PacketPath
    Assert-R15CardReentryPacketStatusPosture -RepositoryRoot $RepositoryRoot
    return $result
}

Export-ModuleMember -Function Get-R15CardReentryPacket, Test-R15CardReentryPacketObject, Test-R15CardReentryPacket, Assert-R15CardReentryPacketStatusPosture
