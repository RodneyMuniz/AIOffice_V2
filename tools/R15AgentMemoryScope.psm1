Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentIdentityPacket.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "memory_scope_model_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "taxonomy_ref",
    "knowledge_index_ref",
    "agent_identity_packet_ref",
    "scope_boundary",
    "required_scope_ids",
    "required_scope_fields",
    "allowed_scope_types",
    "allowed_authority_levels",
    "allowed_load_modes",
    "allowed_context_strategies",
    "allowed_evidence_requirements",
    "allowed_memory_reference_kinds",
    "memory_scopes",
    "role_memory_access_matrix",
    "invalid_state_rules",
    "non_claims"
)

$script:RequiredScopeIds = @(
    "global_governance_memory",
    "product_governance_memory",
    "milestone_authority_memory",
    "role_identity_memory",
    "card_task_memory",
    "run_session_memory",
    "evidence_memory",
    "knowledge_index_memory",
    "historical_report_memory",
    "deprecated_cleanup_candidate_memory"
)

$script:RequiredScopeFields = @(
    "scope_id",
    "scope_type",
    "purpose",
    "authority_level",
    "allowed_agent_ids",
    "role_types",
    "canonical_paths",
    "optional_paths",
    "forbidden_paths",
    "forbidden_patterns",
    "load_mode",
    "max_context_strategy",
    "freshness_or_staleness_rule",
    "evidence_requirement",
    "compaction_rule",
    "mutation_allowed",
    "non_claims"
)

$script:RequiredRoleAccessFields = @(
    "agent_id",
    "role_type",
    "allowed_scope_ids",
    "default_load_scope_ids",
    "prohibited_scope_ids",
    "memory_reference_kinds",
    "evidence_reference_rule",
    "bounded_refs_required",
    "must_not_load_all_memory",
    "non_claims"
)

$script:RequiredScopeBoundary = [ordered]@{
    model_only = $true
    actual_agents_implemented = $false
    persistent_memory_engine_implemented = $false
    runtime_memory_loading_implemented = $false
    retrieval_engine_implemented = $false
    vector_search_implemented = $false
    direct_agent_access_runtime = $false
    true_multi_agent_execution = $false
    raci_matrix_implemented = $false
    card_reentry_packet_implemented = $false
    r16_opened = $false
    future_runtime_requires_later_task = $true
}

$script:RequiredInvalidRuleIds = @(
    "missing_required_memory_scopes_fail_closed",
    "scope_ids_unique",
    "missing_required_scope_fields_fail_closed",
    "full_repo_scan_rejected",
    "implicit_memory_loading_rejected",
    "load_all_memory_without_bounded_refs_rejected",
    "runtime_memory_engine_claim_rejected",
    "persistent_memory_claim_rejected",
    "retrieval_vector_search_claim_rejected",
    "direct_agent_runtime_claim_rejected",
    "raci_implementation_claim_rejected",
    "card_reentry_implementation_claim_rejected",
    "r16_opening_claim_rejected",
    "r15_006_plus_complete_status_rejected"
)

$script:RequiredNonClaims = @(
    "no actual agents implemented by R15-005",
    "no direct agent access runtime implemented",
    "no true multi-agent execution implemented",
    "no persistent memory engine implemented",
    "no runtime memory loading implemented",
    "no retrieval engine implemented",
    "no vector search implemented",
    "no Obsidian integration by R15-005",
    "no RACI matrix implemented",
    "no card re-entry packet implemented",
    "no classification or re-entry dry run executed",
    "no final R15 proof package complete",
    "no product runtime",
    "no board runtime",
    "no external board sync",
    "no GitHub Projects integration",
    "no Linear implementation",
    "no Symphony implementation",
    "no custom board implementation",
    "no R16 opening",
    "no solved Codex compaction",
    "no solved Codex reliability"
)

$script:ForbiddenLoadModes = @(
    "full_repo_scan",
    "implicit_default_load",
    "load_everything",
    "all_memory",
    "unbounded_scan"
)

$script:OverclaimPatterns = @(
    "actual agents implemented",
    "agent runtime implemented",
    "direct agent access runtime",
    "direct agent access implemented",
    "true multi-agent execution",
    "multi-agent runtime",
    "persistent memory engine",
    "persistent memory implemented",
    "runtime memory loading",
    "memory loading runtime",
    "retrieval engine",
    "vector search",
    "Obsidian integration",
    "external board sync",
    "GitHub Projects integration",
    "Linear integration",
    "Symphony integration",
    "custom board runtime",
    "custom board implementation",
    "RACI matrix implemented",
    "RACI implementation",
    "card re-entry packet implemented",
    "card reentry packet implemented",
    "card re-entry implementation",
    "classification/re-entry dry run",
    "classification and re-entry dry run",
    "final R15 proof package complete",
    "product runtime",
    "production runtime",
    "productized UI",
    "board runtime",
    "solved Codex reliability",
    "solved Codex compaction",
    "solved Codex context compaction",
    "R16 opening",
    "R16 opened",
    "R16 active",
    "full repo scan",
    "full-repo scan",
    "load all memory",
    "implicit memory loading"
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

function Resolve-ScopeRelativePath {
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

    $resolvedPath = Resolve-ScopeRelativePath -Path $Path
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

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed|reject|rejected|fails validation|fail validation|claim fails|claim of|any claim|bounded|only|requires later task|future runtime requires later task)\b'
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

    if ($Path -match '(^|[\\/])\*\*($|[\\/])' -or $Path -match '^\*\*' -or $Path -match '(?i)full[-_ ]?repo|entire[-_ ]?repo|all[-_ ]?memory|whole[-_ ]?repository') {
        throw "$Context allows full repo scan by path '$Path'."
    }
}

function Assert-BoundedPathList {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Paths,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$MustExist
    )

    foreach ($path in $Paths) {
        Assert-NoBroadPath -Path $path -Context $Context
        if ($MustExist) {
            Assert-PathExists -Path $path -Context $Context | Out-Null
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

function Assert-R15MemoryScopeStatusPosture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $statusPaths = @(
        "README.md",
        "governance\ACTIVE_STATE.md",
        "execution\KANBAN.md",
        "governance\DECISION_LOG.md",
        "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    )

    $texts = @{}
    foreach ($relativePath in $statusPaths) {
        $path = Join-Path $RepositoryRoot $relativePath
        if (-not (Test-Path -LiteralPath $path)) {
            throw "R15-005 status posture check could not find '$relativePath'."
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
    if ($kanbanStatus["R15-009"] -notin @("planned", "done") -or $authorityStatus["R15-009"] -notin @("planned", "done")) {
        throw "R15 status posture must keep R15-009 planned at the R15-005 boundary or done at the R15-009 boundary."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R15 active through `?R15-005`? only|R15 active through `?R15-008`? only|Active in repo truth through `R15-008` only|through `R15-008` only|R15.*complete through `?R15-009`?.*pending external audit/review|R15 active through R15-009 only|Active in repo truth through `R15-009` only' -Message "Status docs must state either the R15-005/R15-008 boundary posture or the current R15-009 pending external review posture."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R13 remains failed/partial.*R13-018|R13 API-First QA Pipeline and Operator Control-Room Product Slice` remains failed/partial' -Message "Status docs must preserve R13 failed/partial through R13-018."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R14.*accepted.*R14-006|accepted with caveats.*R14-006' -Message "Status docs must preserve R14 accepted with caveats through R14-006."
    Assert-RegexMatch -Text $texts["governance\DECISION_LOG.md"] -Pattern 'R15-005 Defined Agent Memory Scope Model' -Message "DECISION_LOG must record the R15-005 agent memory scope decision."

    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-005 status docs" -ClaimLabel "R16 or successor opening" -Pattern '(?i)\bR16\b.{0,120}\b(active|open|opened|marked active)\b|\bsuccessor milestone\b.{0,120}\b(is now active|is active|marked active|opens on branch|opened on branch)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-005 status docs" -ClaimLabel "R15 implementation beyond R15-009" -Pattern '(?i)\b(R15-010|R15 successor task)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-005 status docs" -ClaimLabel "R15 external audit acceptance" -Pattern '(?i)\bR15\b.{0,160}\b(externally accepted|external audit accepted|external acceptance)\b|\bexternal audit accepted\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-005 status docs" -ClaimLabel "R15 main merge" -Pattern '(?i)\bR15\b.{0,160}\b(merged to main|main merge exists|main merged)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-005 status docs" -ClaimLabel "runtime or integration overclaim" -Pattern '(?i)\b(actual agents implemented|agent runtime|direct agent access runtime|true multi-agent execution|multi-agent runtime|persistent memory engine|runtime memory loading|retrieval engine|vector search|Obsidian integration|RACI matrix implemented|card re-entry packet implemented|card reentry packet implemented|final R15 proof package complete|product runtime|production runtime|board runtime|external board sync|Linear integration|Symphony integration|GitHub Projects integration|custom board runtime|custom board implementation|solved Codex reliability|solved Codex compaction)\b'
}

function Get-R15AgentMemoryScope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScopePath
    )

    return Read-SingleJsonObject -Path $ScopePath -Label "R15 agent memory scope model"
}

function Test-R15AgentMemoryScopeObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ScopeModel,
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [Parameter(Mandatory = $true)]
        $KnowledgeIndex,
        [Parameter(Mandatory = $true)]
        $AgentIdentityPacket,
        [string]$SourceLabel = "R15 agent memory scope model"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $ScopeModel -Name $field -Context $SourceLabel | Out-Null
    }

    if ($ScopeModel.artifact_type -ne "r15_agent_memory_scope_model") {
        throw "$SourceLabel artifact_type must be 'r15_agent_memory_scope_model'."
    }
    Assert-NonEmptyString -Value $ScopeModel.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $ScopeModel.memory_scope_model_id -Context "$SourceLabel memory_scope_model_id" | Out-Null
    if ($ScopeModel.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($ScopeModel.source_task -ne "R15-005") {
        throw "$SourceLabel source_task must be R15-005."
    }
    if ($ScopeModel.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($ScopeModel.branch -ne "release/r15-knowledge-base-agent-identity-memory-raci-foundations") {
        throw "$SourceLabel branch must be the R15 release branch."
    }
    Assert-NonEmptyString -Value $ScopeModel.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $ScopeModel.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-ObjectValue -Value $ScopeModel.taxonomy_ref -Context "$SourceLabel taxonomy_ref" | Out-Null
    foreach ($field in @("taxonomy_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $ScopeModel.taxonomy_ref -Name $field -Context "$SourceLabel taxonomy_ref" | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.taxonomy_ref.path -Context "$SourceLabel taxonomy_ref path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.taxonomy_ref.contract_path -Context "$SourceLabel taxonomy_ref contract_path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    if ($ScopeModel.taxonomy_ref.taxonomy_id -ne $Taxonomy.taxonomy_id -or $ScopeModel.taxonomy_ref.source_task -ne "R15-002") {
        throw "$SourceLabel taxonomy_ref must point to the R15-002 taxonomy dependency."
    }
    Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency" | Out-Null

    Assert-ObjectValue -Value $ScopeModel.knowledge_index_ref -Context "$SourceLabel knowledge_index_ref" | Out-Null
    foreach ($field in @("index_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $ScopeModel.knowledge_index_ref -Name $field -Context "$SourceLabel knowledge_index_ref" | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.knowledge_index_ref.path -Context "$SourceLabel knowledge_index_ref path") -Context "$SourceLabel knowledge_index_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.knowledge_index_ref.contract_path -Context "$SourceLabel knowledge_index_ref contract_path") -Context "$SourceLabel knowledge_index_ref" | Out-Null
    if ($ScopeModel.knowledge_index_ref.index_id -ne $KnowledgeIndex.index_id -or $ScopeModel.knowledge_index_ref.source_task -ne "R15-003") {
        throw "$SourceLabel knowledge_index_ref must point to the R15-003 repo knowledge index dependency."
    }
    Test-R15RepoKnowledgeIndexObject -Index $KnowledgeIndex -Taxonomy $Taxonomy -SourceLabel "$SourceLabel knowledge index dependency" | Out-Null

    Assert-ObjectValue -Value $ScopeModel.agent_identity_packet_ref -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    foreach ($field in @("packet_set_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $ScopeModel.agent_identity_packet_ref -Name $field -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    }
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.agent_identity_packet_ref.path -Context "$SourceLabel agent_identity_packet_ref path") -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $ScopeModel.agent_identity_packet_ref.contract_path -Context "$SourceLabel agent_identity_packet_ref contract_path") -Context "$SourceLabel agent_identity_packet_ref" | Out-Null
    if ($ScopeModel.agent_identity_packet_ref.packet_set_id -ne $AgentIdentityPacket.packet_set_id -or $ScopeModel.agent_identity_packet_ref.source_task -ne "R15-004") {
        throw "$SourceLabel agent_identity_packet_ref must point to the R15-004 agent identity packet dependency."
    }
    Test-R15AgentIdentityPacketObject -Packet $AgentIdentityPacket -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -SourceLabel "$SourceLabel agent identity dependency" | Out-Null

    Assert-ObjectValue -Value $ScopeModel.scope_boundary -Context "$SourceLabel scope_boundary" | Out-Null
    foreach ($boundaryKey in $script:RequiredScopeBoundary.Keys) {
        Get-RequiredProperty -Object $ScopeModel.scope_boundary -Name $boundaryKey -Context "$SourceLabel scope_boundary" | Out-Null
        $actual = Assert-BooleanValue -Value $ScopeModel.scope_boundary.$boundaryKey -Context "$SourceLabel scope_boundary $boundaryKey"
        if ($actual -ne $script:RequiredScopeBoundary[$boundaryKey]) {
            throw "$SourceLabel scope_boundary $boundaryKey must be $($script:RequiredScopeBoundary[$boundaryKey])."
        }
    }

    $requiredScopeIds = Assert-StringArray -Value $ScopeModel.required_scope_ids -Context "$SourceLabel required_scope_ids"
    Assert-RequiredValuesPresent -Values $requiredScopeIds -RequiredValues $script:RequiredScopeIds -Context "$SourceLabel required_scope_ids"
    $requiredScopeFields = Assert-StringArray -Value $ScopeModel.required_scope_fields -Context "$SourceLabel required_scope_fields"
    Assert-RequiredValuesPresent -Values $requiredScopeFields -RequiredValues $script:RequiredScopeFields -Context "$SourceLabel required_scope_fields"
    $allowedScopeTypes = Assert-StringArray -Value $ScopeModel.allowed_scope_types -Context "$SourceLabel allowed_scope_types"
    Assert-RequiredValuesPresent -Values $allowedScopeTypes -RequiredValues $script:RequiredScopeIds -Context "$SourceLabel allowed_scope_types"
    $allowedAuthorityLevels = Assert-StringArray -Value $ScopeModel.allowed_authority_levels -Context "$SourceLabel allowed_authority_levels"
    $allowedLoadModes = Assert-StringArray -Value $ScopeModel.allowed_load_modes -Context "$SourceLabel allowed_load_modes"
    $allowedContextStrategies = Assert-StringArray -Value $ScopeModel.allowed_context_strategies -Context "$SourceLabel allowed_context_strategies"
    $allowedEvidenceRequirements = Assert-StringArray -Value $ScopeModel.allowed_evidence_requirements -Context "$SourceLabel allowed_evidence_requirements"
    $allowedMemoryReferenceKinds = Assert-StringArray -Value $ScopeModel.allowed_memory_reference_kinds -Context "$SourceLabel allowed_memory_reference_kinds"

    foreach ($forbiddenLoadMode in $script:ForbiddenLoadModes) {
        if ($allowedLoadModes -contains $forbiddenLoadMode) {
            throw "$SourceLabel allowed_load_modes must not include '$forbiddenLoadMode'."
        }
    }

    $invalidStateRules = Assert-ObjectArray -Value $ScopeModel.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    New-ValueSet -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules" | Out-Null
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rule") -Context "$SourceLabel invalid_state_rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $ScopeModel.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"
    if (Test-HasProperty -Object $ScopeModel -Name "claims") {
        Assert-NoOverclaimText -Values (Assert-StringArray -Value $ScopeModel.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    }

    $memoryScopes = Assert-ObjectArray -Value $ScopeModel.memory_scopes -Context "$SourceLabel memory_scopes"
    $scopeMap = @{}
    foreach ($scope in $memoryScopes) {
        $scopeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "scope_id" -Context "$SourceLabel memory_scope") -Context "$SourceLabel memory_scope scope_id"
        if ($scopeMap.ContainsKey($scopeId)) {
            throw "$SourceLabel memory_scopes duplicate scope_id '$scopeId'."
        }
        $scopeMap[$scopeId] = $scope
    }
    foreach ($requiredScopeId in $script:RequiredScopeIds) {
        if (-not $scopeMap.ContainsKey($requiredScopeId)) {
            throw "$SourceLabel is missing required memory scope '$requiredScopeId'."
        }
    }

    foreach ($scope in $memoryScopes) {
        $scopeId = [string]$scope.scope_id
        foreach ($requiredField in $requiredScopeFields) {
            Get-RequiredProperty -Object $scope -Name $requiredField -Context "$SourceLabel memory scope '$scopeId'" | Out-Null
        }
        $scopeType = Assert-NonEmptyString -Value $scope.scope_type -Context "$SourceLabel memory scope '$scopeId' scope_type"
        if ($allowedScopeTypes -notcontains $scopeType) {
            throw "$SourceLabel memory scope '$scopeId' uses invalid scope_type '$scopeType'."
        }
        Assert-NonEmptyString -Value $scope.purpose -Context "$SourceLabel memory scope '$scopeId' purpose" | Out-Null
        $authorityLevel = Assert-NonEmptyString -Value $scope.authority_level -Context "$SourceLabel memory scope '$scopeId' authority_level"
        if ($allowedAuthorityLevels -notcontains $authorityLevel) {
            throw "$SourceLabel memory scope '$scopeId' uses invalid authority_level '$authorityLevel'."
        }
        $allowedAgentIds = Assert-StringArray -Value $scope.allowed_agent_ids -Context "$SourceLabel memory scope '$scopeId' allowed_agent_ids" -AllowEmpty
        Assert-StringArray -Value $scope.role_types -Context "$SourceLabel memory scope '$scopeId' role_types" -AllowEmpty | Out-Null
        $canonicalPaths = Assert-StringArray -Value $scope.canonical_paths -Context "$SourceLabel memory scope '$scopeId' canonical_paths"
        $optionalPaths = Assert-StringArray -Value $scope.optional_paths -Context "$SourceLabel memory scope '$scopeId' optional_paths" -AllowEmpty
        Assert-StringArray -Value $scope.forbidden_paths -Context "$SourceLabel memory scope '$scopeId' forbidden_paths" -AllowEmpty | Out-Null
        $forbiddenPatterns = Assert-StringArray -Value $scope.forbidden_patterns -Context "$SourceLabel memory scope '$scopeId' forbidden_patterns"
        $loadMode = Assert-NonEmptyString -Value $scope.load_mode -Context "$SourceLabel memory scope '$scopeId' load_mode"
        if ($script:ForbiddenLoadModes -contains $loadMode) {
            throw "$SourceLabel memory scope '$scopeId' allows full repo scan by load_mode '$loadMode'."
        }
        if ($allowedLoadModes -notcontains $loadMode) {
            throw "$SourceLabel memory scope '$scopeId' uses invalid load_mode '$loadMode'."
        }
        $contextStrategy = Assert-NonEmptyString -Value $scope.max_context_strategy -Context "$SourceLabel memory scope '$scopeId' max_context_strategy"
        if ($allowedContextStrategies -notcontains $contextStrategy) {
            throw "$SourceLabel memory scope '$scopeId' uses invalid max_context_strategy '$contextStrategy'."
        }
        Assert-NonEmptyString -Value $scope.freshness_or_staleness_rule -Context "$SourceLabel memory scope '$scopeId' freshness_or_staleness_rule" | Out-Null
        $evidenceRequirement = Assert-NonEmptyString -Value $scope.evidence_requirement -Context "$SourceLabel memory scope '$scopeId' evidence_requirement"
        if ($allowedEvidenceRequirements -notcontains $evidenceRequirement) {
            throw "$SourceLabel memory scope '$scopeId' uses invalid evidence_requirement '$evidenceRequirement'."
        }
        Assert-NonEmptyString -Value $scope.compaction_rule -Context "$SourceLabel memory scope '$scopeId' compaction_rule" | Out-Null
        $mutationAllowed = Assert-BooleanValue -Value $scope.mutation_allowed -Context "$SourceLabel memory scope '$scopeId' mutation_allowed"
        if ($mutationAllowed -and (-not (Test-HasProperty -Object $scope -Name "mutation_justification") -or [string]::IsNullOrWhiteSpace([string]$scope.mutation_justification))) {
            throw "$SourceLabel memory scope '$scopeId' mutation_allowed requires mutation_justification."
        }
        $scopeNonClaims = Assert-StringArray -Value $scope.non_claims -Context "$SourceLabel memory scope '$scopeId' non_claims" -AllowEmpty

        foreach ($agentId in $allowedAgentIds) {
            if (@($AgentIdentityPacket.roles.agent_id) -notcontains $agentId) {
                throw "$SourceLabel memory scope '$scopeId' allowed_agent_ids contains unknown R15-004 agent_id '$agentId'."
            }
        }
        Assert-BoundedPathList -Paths $canonicalPaths -Context "$SourceLabel memory scope '$scopeId' canonical_paths" -MustExist
        Assert-BoundedPathList -Paths $optionalPaths -Context "$SourceLabel memory scope '$scopeId' optional_paths"
        Assert-RequiredValuesPresent -Values $forbiddenPatterns -RequiredValues @("full_repo_scan", "implicit_memory_loading", "persistent_memory_runtime_claim") -Context "$SourceLabel memory scope '$scopeId' forbidden_patterns"

        $scopeText = @(Get-StringValuesFromObject -Value $scope)
        Assert-NoOverclaimText -Values $scopeText -Context "$SourceLabel memory scope '$scopeId'"
        Assert-NoOverclaimText -Values $scopeNonClaims -Context "$SourceLabel memory scope '$scopeId' non_claims"
    }

    $roleAccessItems = Assert-ObjectArray -Value $ScopeModel.role_memory_access_matrix -Context "$SourceLabel role_memory_access_matrix"
    $roleAccessMap = @{}
    foreach ($accessItem in $roleAccessItems) {
        $agentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $accessItem -Name "agent_id" -Context "$SourceLabel role_memory_access_matrix") -Context "$SourceLabel role_memory_access_matrix agent_id"
        if ($roleAccessMap.ContainsKey($agentId)) {
            throw "$SourceLabel role_memory_access_matrix duplicate agent_id '$agentId'."
        }
        $roleAccessMap[$agentId] = $accessItem
    }

    $identityRoleMap = @{}
    foreach ($role in @($AgentIdentityPacket.roles)) {
        $identityRoleMap[[string]$role.agent_id] = $role
    }
    foreach ($agentId in @($AgentIdentityPacket.required_role_ids)) {
        if (-not $roleAccessMap.ContainsKey($agentId)) {
            throw "$SourceLabel role_memory_access_matrix is missing R15-004 role '$agentId'."
        }
    }

    foreach ($accessItem in $roleAccessItems) {
        $agentId = [string]$accessItem.agent_id
        foreach ($requiredField in $script:RequiredRoleAccessFields) {
            Get-RequiredProperty -Object $accessItem -Name $requiredField -Context "$SourceLabel role memory access '$agentId'" | Out-Null
        }
        if (-not $identityRoleMap.ContainsKey($agentId)) {
            throw "$SourceLabel role memory access '$agentId' does not tie to an R15-004 agent identity."
        }
        $roleType = Assert-NonEmptyString -Value $accessItem.role_type -Context "$SourceLabel role memory access '$agentId' role_type"
        if ($roleType -ne [string]$identityRoleMap[$agentId].role_type) {
            throw "$SourceLabel role memory access '$agentId' role_type must match the R15-004 identity packet."
        }
        $allowedScopeIds = Assert-StringArray -Value $accessItem.allowed_scope_ids -Context "$SourceLabel role memory access '$agentId' allowed_scope_ids"
        $defaultScopeIds = Assert-StringArray -Value $accessItem.default_load_scope_ids -Context "$SourceLabel role memory access '$agentId' default_load_scope_ids" -AllowEmpty
        $prohibitedScopeIds = Assert-StringArray -Value $accessItem.prohibited_scope_ids -Context "$SourceLabel role memory access '$agentId' prohibited_scope_ids" -AllowEmpty
        $referenceKinds = Assert-StringArray -Value $accessItem.memory_reference_kinds -Context "$SourceLabel role memory access '$agentId' memory_reference_kinds"
        Assert-NonEmptyString -Value $accessItem.evidence_reference_rule -Context "$SourceLabel role memory access '$agentId' evidence_reference_rule" | Out-Null
        $boundedRefsRequired = Assert-BooleanValue -Value $accessItem.bounded_refs_required -Context "$SourceLabel role memory access '$agentId' bounded_refs_required"
        $mustNotLoadAllMemory = Assert-BooleanValue -Value $accessItem.must_not_load_all_memory -Context "$SourceLabel role memory access '$agentId' must_not_load_all_memory"
        $accessNonClaims = Assert-StringArray -Value $accessItem.non_claims -Context "$SourceLabel role memory access '$agentId' non_claims" -AllowEmpty

        foreach ($scopeId in @($allowedScopeIds + $defaultScopeIds + $prohibitedScopeIds)) {
            if (-not $scopeMap.ContainsKey($scopeId)) {
                throw "$SourceLabel role memory access '$agentId' references unknown scope_id '$scopeId'."
            }
        }
        foreach ($scopeId in $defaultScopeIds) {
            if ($allowedScopeIds -notcontains $scopeId) {
                throw "$SourceLabel role memory access '$agentId' default_load_scope_ids contains scope '$scopeId' not listed in allowed_scope_ids."
            }
        }
        Assert-AllowedValues -Values $referenceKinds -AllowedValues $allowedMemoryReferenceKinds -Context "$SourceLabel role memory access '$agentId' memory_reference_kinds"
        if ($allowedScopeIds -contains "*" -or $allowedScopeIds -contains "all" -or $defaultScopeIds -contains "*" -or $defaultScopeIds -contains "all") {
            throw "$SourceLabel role memory access '$agentId' can load all memory without bounded refs."
        }
        if ($allowedScopeIds.Count -ge $memoryScopes.Count -and -not $boundedRefsRequired) {
            throw "$SourceLabel role memory access '$agentId' can load all memory without bounded refs."
        }
        if ($defaultScopeIds.Count -ge $memoryScopes.Count) {
            throw "$SourceLabel role memory access '$agentId' default load can load all memory."
        }
        if (-not $mustNotLoadAllMemory) {
            throw "$SourceLabel role memory access '$agentId' must_not_load_all_memory must be true."
        }
        if (-not $boundedRefsRequired) {
            throw "$SourceLabel role memory access '$agentId' bounded_refs_required must be true."
        }

        $accessText = @(Get-StringValuesFromObject -Value $accessItem)
        Assert-NoOverclaimText -Values $accessText -Context "$SourceLabel role memory access '$agentId'"
        Assert-NoOverclaimText -Values $accessNonClaims -Context "$SourceLabel role memory access '$agentId' non_claims"
    }

    $modelText = @(Get-StringValuesFromObject -Value $ScopeModel)
    Assert-NoOverclaimText -Values $modelText -Context $SourceLabel

    return [pscustomobject]@{
        ArtifactType = $ScopeModel.artifact_type
        MemoryScopeModelId = $ScopeModel.memory_scope_model_id
        SourceTask = $ScopeModel.source_task
        ScopeCount = $memoryScopes.Count
        RoleAccessCount = $roleAccessItems.Count
        ModelOnly = [bool]$ScopeModel.scope_boundary.model_only
        PersistentMemoryEngineImplemented = [bool]$ScopeModel.scope_boundary.persistent_memory_engine_implemented
        RuntimeMemoryLoadingImplemented = [bool]$ScopeModel.scope_boundary.runtime_memory_loading_implemented
        RetrievalEngineImplemented = [bool]$ScopeModel.scope_boundary.retrieval_engine_implemented
        VectorSearchImplemented = [bool]$ScopeModel.scope_boundary.vector_search_implemented
        DirectAgentAccessRuntime = [bool]$ScopeModel.scope_boundary.direct_agent_access_runtime
        TrueMultiAgentExecution = [bool]$ScopeModel.scope_boundary.true_multi_agent_execution
        RaciMatrixImplemented = [bool]$ScopeModel.scope_boundary.raci_matrix_implemented
        CardReentryPacketImplemented = [bool]$ScopeModel.scope_boundary.card_reentry_packet_implemented
        R16Opened = [bool]$ScopeModel.scope_boundary.r16_opened
    }
}

function Test-R15AgentMemoryScope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScopePath,
        [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
        [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
        [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $scopeModel = Get-R15AgentMemoryScope -ScopePath $ScopePath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    $knowledgeIndex = Get-R15RepoKnowledgeIndex -IndexPath $KnowledgeIndexPath
    $agentIdentityPacket = Get-R15AgentIdentityPacket -PacketPath $AgentIdentityPacketPath
    $result = Test-R15AgentMemoryScopeObject -ScopeModel $scopeModel -Taxonomy $taxonomy -KnowledgeIndex $knowledgeIndex -AgentIdentityPacket $agentIdentityPacket -SourceLabel $ScopePath
    Assert-R15MemoryScopeStatusPosture -RepositoryRoot $RepositoryRoot
    return $result
}

Export-ModuleMember -Function Get-R15AgentMemoryScope, Test-R15AgentMemoryScopeObject, Test-R15AgentMemoryScope, Assert-R15MemoryScopeStatusPosture
