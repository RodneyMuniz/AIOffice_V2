Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentIdentityPacket.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15AgentMemoryScope.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15RaciStateTransitionMatrix.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15CardReentryPacket.psm1") -Force

$script:TargetSlicePaths = @(
    "state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/validation_manifest.md",
    "state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/r14_validation_summary.json",
    "governance/reports/AIOffice_V2_R14_Pivot_Closeout_and_R15_Planning_Brief_v1.md",
    "governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
)

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "dry_run_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "target_slice_id",
    "target_slice_paths",
    "dependency_refs",
    "scope_boundary",
    "classification_results",
    "knowledge_index_lookup_result",
    "agent_role_selection",
    "memory_scope_application",
    "raci_state_transition_application",
    "reentry_packet_result",
    "model_runtime_distinction",
    "dry_run_verdict",
    "invalid_state_rules",
    "claims",
    "non_claims"
)

$script:RequiredDependencyRefs = [ordered]@{
    artifact_classification_taxonomy = @{ IdField = "taxonomy_id"; ExpectedSourceTask = "R15-002" }
    repo_knowledge_index = @{ IdField = "index_id"; ExpectedSourceTask = "R15-003" }
    agent_identity_packet_model = @{ IdField = "packet_set_id"; ExpectedSourceTask = "R15-004" }
    agent_memory_scope_model = @{ IdField = "memory_scope_model_id"; ExpectedSourceTask = "R15-005" }
    raci_state_transition_matrix_model = @{ IdField = "matrix_id"; ExpectedSourceTask = "R15-006" }
    card_reentry_packet_model = @{ IdField = "packet_model_id"; ExpectedSourceTask = "R15-007" }
}

$script:RequiredScopeBoundary = [ordered]@{
    dry_run_only = $true
    full_repo_scan_executed = $false
    runtime_agents_implemented = $false
    actual_agents_implemented = $false
    direct_agent_access_runtime_implemented = $false
    true_multi_agent_execution_implemented = $false
    persistent_memory_engine_implemented = $false
    runtime_memory_loading_implemented = $false
    retrieval_engine_implemented = $false
    vector_search_implemented = $false
    card_reentry_runtime_implemented = $false
    board_routing_runtime_implemented = $false
    workflow_execution_implemented = $false
    final_r15_proof_package_complete = $false
    product_runtime_implemented = $false
    integration_runtime_implemented = $false
    external_board_sync_implemented = $false
    r16_opened = $false
    future_runtime_requires_later_task = $true
}

$script:RequiredInvalidRuleIds = @(
    "missing_required_target_slice_paths",
    "dry_run_claiming_full_repo_scan",
    "broad_repo_root_or_wildcard_paths",
    "unknown_artifact_classification",
    "unknown_knowledge_index_entry",
    "unknown_target_agent",
    "unknown_memory_scope",
    "unknown_raci_transition",
    "missing_card_reentry_packet_output",
    "runtime_agent_claim",
    "card_reentry_runtime_claim",
    "board_routing_runtime_claim",
    "workflow_execution_claim",
    "product_runtime_claim",
    "final_r15_proof_package_claim",
    "r16_opening_claim",
    "status_posture_r15_009_complete",
    "model_output_not_distinguished_from_runtime_execution"
)

$script:RequiredNonClaims = @(
    "no actual agents implemented by R15-008",
    "no direct agent access runtime implemented",
    "no true multi-agent execution implemented",
    "no persistent memory engine implemented",
    "no runtime memory loading implemented",
    "no retrieval engine implemented",
    "no vector search implemented",
    "no Obsidian integration by R15-008",
    "no external board sync",
    "no GitHub Projects integration",
    "no Linear integration",
    "no Symphony integration",
    "no custom board runtime",
    "no PM automation implemented",
    "no actual workflow execution",
    "no board routing runtime implemented",
    "no card re-entry runtime implemented",
    "no final R15 proof package complete",
    "no product runtime",
    "no integration runtime implemented",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "no R16 opening"
)

$script:OverclaimPatterns = @(
    "actual agents implemented",
    "agent runtime implemented",
    "direct agent access runtime",
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
    "card re-entry runtime",
    "card reentry runtime",
    "final R15 proof package complete",
    "product runtime",
    "production runtime",
    "integration runtime implemented",
    "R16 opening",
    "R16 opened",
    "R16 active",
    "full repo scan executed",
    "full-repo scan executed",
    "full repo scan was executed",
    "runtime execution completed",
    "runtime handoff executed"
)

function Test-HasProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-PositiveInteger {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
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
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
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
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
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

function Resolve-DryRunRelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $resolvedPath = Resolve-DryRunRelativePath -Path $Path
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Context path '$Path' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Assert-NoBroadPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Path -in @(".", ".\", "./", "*", "**", "**/*", "/", "\", "repo", "repository", "full_repo", "entire_repo")) {
        throw "$Context includes broad repo-root or wildcard path '$Path'."
    }

    if ($Path -match '[*]' -or $Path -match '(^|[\\/])\*\*($|[\\/])' -or $Path -match '(?i)full[-_ ]?repo|entire[-_ ]?repo|whole[-_ ]?repository|repo[-_ ]?root') {
        throw "$Context includes broad repo-root or wildcard path '$Path'."
    }
}

function Test-TextHasNegation {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed|reject|rejected|fails validation|fail validation|model-only|model only|dry-run-only|future runtime requires later task|bounded|only|avoided|distinguished from runtime)\b|any .{0,30}claim'
}

function Assert-NoOverclaimText {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context
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
    param([AllowNull()]$Value)

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

function Assert-RegexMatch {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$ClaimLabel,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        if ($line -match $Pattern -and -not (Test-TextHasNegation -Text $line)) {
            throw "$Context contains forbidden positive claim: $ClaimLabel."
        }
    }
}

function New-ValueSet {
    param(
        [Parameter(Mandatory = $true)][object[]]$Items,
        [Parameter(Mandatory = $true)][string]$FieldName,
        [Parameter(Mandatory = $true)][string]$Context
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
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$RequiredValues,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)][string[]]$NonClaims,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-R15TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context
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

function Assert-R15ClassificationReentryDryRunStatusPosture {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

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
            throw "R15-008 status posture check could not find '$relativePath'."
        }
        $texts[$relativePath] = Get-Content -LiteralPath $path -Raw
    }

    $kanbanStatus = Get-R15TaskStatusMap -Text $texts["execution\KANBAN.md"] -Context "KANBAN"
    $authorityStatus = Get-R15TaskStatusMap -Text $texts["governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"] -Context "R15 authority"
    foreach ($taskId in @("R15-001", "R15-002", "R15-003", "R15-004", "R15-005", "R15-006", "R15-007", "R15-008")) {
        if ($kanbanStatus[$taskId] -ne "done" -or $authorityStatus[$taskId] -ne "done") {
            throw "R15 status posture must mark $taskId done for R15-008."
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
    Assert-RegexMatch -Text $texts["governance\DECISION_LOG.md"] -Pattern 'R15-008 Ran Classification And Re-entry Dry Run' -Message "DECISION_LOG must record the R15-008 classification/re-entry dry-run decision."

    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-008 status docs" -ClaimLabel "R16 or successor opening" -Pattern '(?i)\bR16\b.{0,120}\b(active|open|opened|marked active)\b|\bsuccessor milestone\b.{0,120}\b(is now active|is active|marked active|opens on branch|opened on branch)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-008 status docs" -ClaimLabel "R15-009 completion" -Pattern '(?i)\bR15-009\b.{0,160}\b(done|complete|completed|implemented|executed|ran)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-008 status docs" -ClaimLabel "final R15 proof package completion" -Pattern '(?i)\b(final R15 proof package|R15 proof package)\b.{0,160}\b(done|complete|completed|executed|exists|created)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "R15-008 status docs" -ClaimLabel "runtime or integration overclaim" -Pattern '(?i)\b(actual agents implemented|agent runtime|direct agent access runtime|true multi-agent execution|multi-agent runtime|persistent memory engine|runtime memory loading|retrieval engine|vector search|Obsidian integration|external board sync|Linear integration|Symphony integration|GitHub Projects integration|custom board runtime|custom board implementation|PM automation|actual workflow execution|workflow execution implemented|board routing runtime|card re-entry runtime|card reentry runtime|product runtime|production runtime|integration runtime|solved Codex reliability|solved Codex compaction)\b'
}

function Get-R15ClassificationReentryDryRun {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$DryRunPath)

    return Read-SingleJsonObject -Path $DryRunPath -Label "R15 classification re-entry dry run"
}

function Test-R15ClassificationReentryDryRunObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$DryRun,
        [Parameter(Mandatory = $true)]$Taxonomy,
        [Parameter(Mandatory = $true)]$KnowledgeIndex,
        [Parameter(Mandatory = $true)]$AgentIdentityPacket,
        [Parameter(Mandatory = $true)]$AgentMemoryScope,
        [Parameter(Mandatory = $true)]$RaciStateTransitionMatrix,
        [Parameter(Mandatory = $true)]$CardReentryPacket,
        [string]$SourceLabel = "R15 classification re-entry dry run"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $DryRun -Name $field -Context $SourceLabel | Out-Null
    }

    if ($DryRun.artifact_type -ne "r15_classification_reentry_dry_run") {
        throw "$SourceLabel artifact_type must be 'r15_classification_reentry_dry_run'."
    }
    if ($DryRun.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations."
    }
    if ($DryRun.source_task -ne "R15-008") {
        throw "$SourceLabel source_task must be R15-008."
    }
    if ($DryRun.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($DryRun.branch -ne "release/r15-knowledge-base-agent-identity-memory-raci-foundations") {
        throw "$SourceLabel branch must be the R15 release branch."
    }

    Assert-NonEmptyString -Value $DryRun.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $DryRun.dry_run_id -Context "$SourceLabel dry_run_id" | Out-Null
    Assert-NonEmptyString -Value $DryRun.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $DryRun.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null
    if ($DryRun.target_slice_id -ne "r15_008_default_r14_evidence_slice") {
        throw "$SourceLabel target_slice_id must be r15_008_default_r14_evidence_slice."
    }

    $targetSlicePaths = Assert-StringArray -Value $DryRun.target_slice_paths -Context "$SourceLabel target_slice_paths"
    foreach ($requiredPath in $script:TargetSlicePaths) {
        if ($targetSlicePaths -notcontains $requiredPath) {
            throw "$SourceLabel is missing required target slice path '$requiredPath'."
        }
    }
    if ($targetSlicePaths.Count -ne $script:TargetSlicePaths.Count) {
        throw "$SourceLabel target_slice_paths must contain only the bounded R15-008 target slice paths."
    }
    foreach ($path in $targetSlicePaths) {
        Assert-NoBroadPath -Path $path -Context "$SourceLabel target_slice_paths"
        Assert-PathExists -Path $path -Context "$SourceLabel target_slice_paths" | Out-Null
    }

    Assert-ObjectValue -Value $DryRun.dependency_refs -Context "$SourceLabel dependency_refs" | Out-Null
    foreach ($dependencyName in $script:RequiredDependencyRefs.Keys) {
        $dependency = Get-RequiredProperty -Object $DryRun.dependency_refs -Name $dependencyName -Context "$SourceLabel dependency_refs"
        Assert-ObjectValue -Value $dependency -Context "$SourceLabel dependency_refs $dependencyName" | Out-Null
        foreach ($field in @($script:RequiredDependencyRefs[$dependencyName].IdField, "path", "contract_path", "source_task")) {
            Get-RequiredProperty -Object $dependency -Name $field -Context "$SourceLabel dependency_refs $dependencyName" | Out-Null
        }
        Assert-PathExists -Path (Assert-NonEmptyString -Value $dependency.path -Context "$SourceLabel dependency_refs $dependencyName path") -Context "$SourceLabel dependency_refs $dependencyName" | Out-Null
        Assert-PathExists -Path (Assert-NonEmptyString -Value $dependency.contract_path -Context "$SourceLabel dependency_refs $dependencyName contract_path") -Context "$SourceLabel dependency_refs $dependencyName" | Out-Null
        if ($dependency.source_task -ne $script:RequiredDependencyRefs[$dependencyName].ExpectedSourceTask) {
            throw "$SourceLabel dependency_refs $dependencyName source_task must be $($script:RequiredDependencyRefs[$dependencyName].ExpectedSourceTask)."
        }
    }
    if ($DryRun.dependency_refs.artifact_classification_taxonomy.taxonomy_id -ne $Taxonomy.taxonomy_id) {
        throw "$SourceLabel taxonomy dependency id does not match loaded taxonomy."
    }
    if ($DryRun.dependency_refs.repo_knowledge_index.index_id -ne $KnowledgeIndex.index_id) {
        throw "$SourceLabel knowledge index dependency id does not match loaded index."
    }
    if ($DryRun.dependency_refs.agent_identity_packet_model.packet_set_id -ne $AgentIdentityPacket.packet_set_id) {
        throw "$SourceLabel identity packet dependency id does not match loaded packet."
    }
    if ($DryRun.dependency_refs.agent_memory_scope_model.memory_scope_model_id -ne $AgentMemoryScope.memory_scope_model_id) {
        throw "$SourceLabel memory scope dependency id does not match loaded scope model."
    }
    if ($DryRun.dependency_refs.raci_state_transition_matrix_model.matrix_id -ne $RaciStateTransitionMatrix.matrix_id) {
        throw "$SourceLabel RACI dependency id does not match loaded matrix."
    }
    if ($DryRun.dependency_refs.card_reentry_packet_model.packet_model_id -ne $CardReentryPacket.packet_model_id) {
        throw "$SourceLabel card re-entry dependency id does not match loaded packet model."
    }

    Assert-ObjectValue -Value $DryRun.scope_boundary -Context "$SourceLabel scope_boundary" | Out-Null
    foreach ($scopeKey in $script:RequiredScopeBoundary.Keys) {
        Get-RequiredProperty -Object $DryRun.scope_boundary -Name $scopeKey -Context "$SourceLabel scope_boundary" | Out-Null
        $actual = Assert-BooleanValue -Value $DryRun.scope_boundary.$scopeKey -Context "$SourceLabel scope_boundary $scopeKey"
        if ($actual -ne $script:RequiredScopeBoundary[$scopeKey]) {
            throw "$SourceLabel scope_boundary $scopeKey must be $($script:RequiredScopeBoundary[$scopeKey])."
        }
    }

    Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency" | Out-Null
    Test-R15RepoKnowledgeIndexObject -Index $KnowledgeIndex -Taxonomy $Taxonomy -SourceLabel "$SourceLabel knowledge index dependency" | Out-Null
    Test-R15AgentIdentityPacketObject -Packet $AgentIdentityPacket -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -SourceLabel "$SourceLabel identity dependency" | Out-Null
    Test-R15AgentMemoryScopeObject -ScopeModel $AgentMemoryScope -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -SourceLabel "$SourceLabel memory dependency" | Out-Null
    Test-R15RaciStateTransitionMatrixObject -Matrix $RaciStateTransitionMatrix -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -AgentMemoryScope $AgentMemoryScope -SourceLabel "$SourceLabel RACI dependency" | Out-Null
    Test-R15CardReentryPacketObject -PacketModel $CardReentryPacket -Taxonomy $Taxonomy -KnowledgeIndex $KnowledgeIndex -AgentIdentityPacket $AgentIdentityPacket -AgentMemoryScope $AgentMemoryScope -RaciStateTransitionMatrix $RaciStateTransitionMatrix -SourceLabel "$SourceLabel card re-entry dependency" | Out-Null

    $classificationClassMap = New-ValueSet -Items @($Taxonomy.classification_classes) -FieldName "class_id" -Context "$SourceLabel taxonomy classification_classes"
    $evidenceKindMap = New-ValueSet -Items @($Taxonomy.evidence_kinds) -FieldName "evidence_kind" -Context "$SourceLabel taxonomy evidence_kinds"
    $authorityKindMap = New-ValueSet -Items @($Taxonomy.authority_kinds) -FieldName "authority_kind" -Context "$SourceLabel taxonomy authority_kinds"
    $lifecycleStateMap = New-ValueSet -Items @($Taxonomy.lifecycle_states) -FieldName "lifecycle_state" -Context "$SourceLabel taxonomy lifecycle_states"
    $proofStatusMap = New-ValueSet -Items @($Taxonomy.proof_status_values) -FieldName "proof_status" -Context "$SourceLabel taxonomy proof_status_values"
    $indexMap = New-ValueSet -Items @($KnowledgeIndex.index_entries) -FieldName "entry_id" -Context "$SourceLabel knowledge index entries"
    $agentMap = New-ValueSet -Items @($AgentIdentityPacket.roles) -FieldName "agent_id" -Context "$SourceLabel agent identities"
    $scopeMap = New-ValueSet -Items @($AgentMemoryScope.memory_scopes) -FieldName "scope_id" -Context "$SourceLabel memory scopes"
    $roleAccessMap = New-ValueSet -Items @($AgentMemoryScope.role_memory_access_matrix) -FieldName "agent_id" -Context "$SourceLabel role memory access matrix"
    $transitionMap = New-ValueSet -Items @($RaciStateTransitionMatrix.transition_matrix) -FieldName "transition_id" -Context "$SourceLabel RACI transitions"

    $classificationResults = Assert-ObjectArray -Value $DryRun.classification_results -Context "$SourceLabel classification_results"
    $classifiedPaths = @()
    foreach ($classification in $classificationResults) {
        foreach ($field in @("path", "artifact_class", "evidence_kind", "authority_kind", "lifecycle_state", "proof_status", "classification_reason", "bounded_context_reason", "treatment_flags")) {
            Get-RequiredProperty -Object $classification -Name $field -Context "$SourceLabel classification_result" | Out-Null
        }
        $path = Assert-NonEmptyString -Value $classification.path -Context "$SourceLabel classification_result path"
        if ($targetSlicePaths -notcontains $path) {
            throw "$SourceLabel classification_result path '$path' is outside the bounded target slice."
        }
        $classifiedPaths += $path
        Assert-NoBroadPath -Path $path -Context "$SourceLabel classification_result"
        $artifactClass = Assert-NonEmptyString -Value $classification.artifact_class -Context "$SourceLabel classification_result artifact_class"
        if ($artifactClass -eq "unknown" -or -not $classificationClassMap.ContainsKey($artifactClass)) {
            throw "$SourceLabel classification_result path '$path' uses unknown artifact classification '$artifactClass'."
        }
        $evidenceKind = Assert-NonEmptyString -Value $classification.evidence_kind -Context "$SourceLabel classification_result evidence_kind"
        if (-not $evidenceKindMap.ContainsKey($evidenceKind)) {
            throw "$SourceLabel classification_result path '$path' uses unknown evidence_kind '$evidenceKind'."
        }
        $authorityKind = Assert-NonEmptyString -Value $classification.authority_kind -Context "$SourceLabel classification_result authority_kind"
        if (-not $authorityKindMap.ContainsKey($authorityKind)) {
            throw "$SourceLabel classification_result path '$path' uses unknown authority_kind '$authorityKind'."
        }
        $lifecycleState = Assert-NonEmptyString -Value $classification.lifecycle_state -Context "$SourceLabel classification_result lifecycle_state"
        if (-not $lifecycleStateMap.ContainsKey($lifecycleState)) {
            throw "$SourceLabel classification_result path '$path' uses unknown lifecycle_state '$lifecycleState'."
        }
        $proofStatus = Assert-NonEmptyString -Value $classification.proof_status -Context "$SourceLabel classification_result proof_status"
        if (-not $proofStatusMap.ContainsKey($proofStatus)) {
            throw "$SourceLabel classification_result path '$path' uses unknown proof_status '$proofStatus'."
        }
        Assert-NonEmptyString -Value $classification.classification_reason -Context "$SourceLabel classification_result classification_reason" | Out-Null
        Assert-NonEmptyString -Value $classification.bounded_context_reason -Context "$SourceLabel classification_result bounded_context_reason" | Out-Null
        Assert-ObjectValue -Value $classification.treatment_flags -Context "$SourceLabel classification_result treatment_flags" | Out-Null
        $treatmentTrueCount = 0
        foreach ($flag in @("canonical_authority", "bounded_evidence", "operator_artifact", "generated_report", "non_authoritative_context")) {
            Get-RequiredProperty -Object $classification.treatment_flags -Name $flag -Context "$SourceLabel classification_result treatment_flags" | Out-Null
            if (Assert-BooleanValue -Value $classification.treatment_flags.$flag -Context "$SourceLabel classification_result treatment_flags $flag") {
                $treatmentTrueCount += 1
            }
        }
        if ($treatmentTrueCount -lt 1) {
            throw "$SourceLabel classification_result path '$path' must mark at least one treatment flag true."
        }
    }
    foreach ($requiredPath in $targetSlicePaths) {
        if ($classifiedPaths -notcontains $requiredPath) {
            throw "$SourceLabel classification_results must include target slice path '$requiredPath'."
        }
    }

    $lookupResults = Assert-ObjectArray -Value $DryRun.knowledge_index_lookup_result -Context "$SourceLabel knowledge_index_lookup_result"
    $lookupPaths = @()
    foreach ($lookup in $lookupResults) {
        foreach ($field in @("index_entry_id", "path", "why_loaded", "authority_level", "load_mode", "exact_file_inspection_allowed", "full_repo_scan_avoided")) {
            Get-RequiredProperty -Object $lookup -Name $field -Context "$SourceLabel knowledge_index_lookup_result" | Out-Null
        }
        $entryId = Assert-NonEmptyString -Value $lookup.index_entry_id -Context "$SourceLabel knowledge_index_lookup_result index_entry_id"
        if (-not $indexMap.ContainsKey($entryId)) {
            throw "$SourceLabel knowledge_index_lookup_result references unknown knowledge index entry '$entryId'."
        }
        $path = Assert-NonEmptyString -Value $lookup.path -Context "$SourceLabel knowledge_index_lookup_result path"
        Assert-NoBroadPath -Path $path -Context "$SourceLabel knowledge_index_lookup_result"
        if ($indexMap[$entryId].path -ne $path) {
            throw "$SourceLabel knowledge_index_lookup_result entry '$entryId' path does not match the repo knowledge index."
        }
        $lookupPaths += $path
        Assert-NonEmptyString -Value $lookup.why_loaded -Context "$SourceLabel knowledge_index_lookup_result why_loaded" | Out-Null
        Assert-NonEmptyString -Value $lookup.authority_level -Context "$SourceLabel knowledge_index_lookup_result authority_level" | Out-Null
        $loadMode = Assert-NonEmptyString -Value $lookup.load_mode -Context "$SourceLabel knowledge_index_lookup_result load_mode"
        if ($loadMode -notin @("exact_file_only", "folder_limited", "evidence_refs_only", "knowledge_index_lookup_only", "no_scan")) {
            throw "$SourceLabel knowledge_index_lookup_result entry '$entryId' has invalid load_mode '$loadMode'."
        }
        if (-not (Assert-BooleanValue -Value $lookup.full_repo_scan_avoided -Context "$SourceLabel knowledge_index_lookup_result full_repo_scan_avoided")) {
            throw "$SourceLabel knowledge_index_lookup_result entry '$entryId' must avoid full repo scan."
        }
        Assert-BooleanValue -Value $lookup.exact_file_inspection_allowed -Context "$SourceLabel knowledge_index_lookup_result exact_file_inspection_allowed" | Out-Null
    }
    foreach ($requiredPath in $targetSlicePaths) {
        if ($lookupPaths -notcontains $requiredPath) {
            throw "$SourceLabel knowledge_index_lookup_result must include target slice path '$requiredPath'."
        }
    }

    Assert-ObjectValue -Value $DryRun.agent_role_selection -Context "$SourceLabel agent_role_selection" | Out-Null
    foreach ($field in @("target_agent_id", "target_role_type", "role_identity_ref", "selection_rationale")) {
        Get-RequiredProperty -Object $DryRun.agent_role_selection -Name $field -Context "$SourceLabel agent_role_selection" | Out-Null
    }
    if ($DryRun.agent_role_selection.target_agent_id -ne "evidence_auditor") {
        throw "$SourceLabel agent_role_selection target_agent_id must be evidence_auditor."
    }
    if (-not $agentMap.ContainsKey("evidence_auditor")) {
        throw "$SourceLabel references unknown target agent 'evidence_auditor'."
    }
    if ($DryRun.agent_role_selection.target_role_type -ne $agentMap["evidence_auditor"].role_type) {
        throw "$SourceLabel agent_role_selection target_role_type must match R15-004 evidence_auditor."
    }
    if ($DryRun.agent_role_selection.role_identity_ref -ne "evidence_auditor") {
        throw "$SourceLabel agent_role_selection role_identity_ref must be evidence_auditor."
    }
    Assert-NonEmptyString -Value $DryRun.agent_role_selection.selection_rationale -Context "$SourceLabel agent_role_selection selection_rationale" | Out-Null

    Assert-ObjectValue -Value $DryRun.memory_scope_application -Context "$SourceLabel memory_scope_application" | Out-Null
    foreach ($field in @("allowed_memory_scope_refs", "forbidden_memory_scope_refs", "forbidden_paths", "exact_load_budget", "compaction_rule", "context_budget", "no_implicit_memory_loading")) {
        Get-RequiredProperty -Object $DryRun.memory_scope_application -Name $field -Context "$SourceLabel memory_scope_application" | Out-Null
    }
    $allowedScopes = Assert-StringArray -Value $DryRun.memory_scope_application.allowed_memory_scope_refs -Context "$SourceLabel memory_scope_application allowed_memory_scope_refs"
    $forbiddenScopes = Assert-StringArray -Value $DryRun.memory_scope_application.forbidden_memory_scope_refs -Context "$SourceLabel memory_scope_application forbidden_memory_scope_refs" -AllowEmpty
    $roleAccess = $roleAccessMap["evidence_auditor"]
    foreach ($scopeId in $allowedScopes) {
        if (-not $scopeMap.ContainsKey($scopeId)) {
            throw "$SourceLabel memory_scope_application references unknown memory scope '$scopeId'."
        }
        if (@($roleAccess.allowed_scope_ids) -notcontains $scopeId) {
            throw "$SourceLabel memory_scope_application scope '$scopeId' is not allowed for evidence_auditor."
        }
    }
    foreach ($scopeId in $forbiddenScopes) {
        if (-not $scopeMap.ContainsKey($scopeId)) {
            throw "$SourceLabel memory_scope_application references unknown forbidden memory scope '$scopeId'."
        }
        if ($allowedScopes -contains $scopeId) {
            throw "$SourceLabel memory_scope_application scope '$scopeId' cannot be both allowed and forbidden."
        }
    }
    foreach ($path in (Assert-StringArray -Value $DryRun.memory_scope_application.forbidden_paths -Context "$SourceLabel memory_scope_application forbidden_paths" -AllowEmpty)) {
        Assert-NoBroadPath -Path $path -Context "$SourceLabel memory_scope_application forbidden_paths"
    }
    if (-not (Assert-BooleanValue -Value $DryRun.memory_scope_application.no_implicit_memory_loading -Context "$SourceLabel memory_scope_application no_implicit_memory_loading")) {
        throw "$SourceLabel memory_scope_application no_implicit_memory_loading must be true."
    }
    Assert-ObjectValue -Value $DryRun.memory_scope_application.exact_load_budget -Context "$SourceLabel memory_scope_application exact_load_budget" | Out-Null
    foreach ($field in @("max_files", "max_evidence_refs", "max_memory_scope_refs", "max_context_chars")) {
        Get-RequiredProperty -Object $DryRun.memory_scope_application.exact_load_budget -Name $field -Context "$SourceLabel memory_scope_application exact_load_budget" | Out-Null
        Assert-PositiveInteger -Value $DryRun.memory_scope_application.exact_load_budget.$field -Context "$SourceLabel memory_scope_application exact_load_budget $field" | Out-Null
    }
    Assert-ObjectValue -Value $DryRun.memory_scope_application.context_budget -Context "$SourceLabel memory_scope_application context_budget" | Out-Null
    foreach ($field in @("exact_allowed_paths", "max_files", "no_full_repo_scan")) {
        Get-RequiredProperty -Object $DryRun.memory_scope_application.context_budget -Name $field -Context "$SourceLabel memory_scope_application context_budget" | Out-Null
    }
    $memoryAllowedPaths = Assert-StringArray -Value $DryRun.memory_scope_application.context_budget.exact_allowed_paths -Context "$SourceLabel memory_scope_application context_budget exact_allowed_paths"
    foreach ($path in $memoryAllowedPaths) {
        Assert-NoBroadPath -Path $path -Context "$SourceLabel memory_scope_application context_budget exact_allowed_paths"
        Assert-PathExists -Path $path -Context "$SourceLabel memory_scope_application context_budget exact_allowed_paths" | Out-Null
    }
    if (-not (Assert-BooleanValue -Value $DryRun.memory_scope_application.context_budget.no_full_repo_scan -Context "$SourceLabel memory_scope_application context_budget no_full_repo_scan")) {
        throw "$SourceLabel memory_scope_application context_budget no_full_repo_scan must be true."
    }

    Assert-ObjectValue -Value $DryRun.raci_state_transition_application -Context "$SourceLabel raci_state_transition_application" | Out-Null
    foreach ($field in @("transition_id", "from_state", "to_state", "responsible_roles", "accountable_role", "consulted_roles", "informed_roles", "required_evidence", "required_approvals", "fail_closed_conditions")) {
        Get-RequiredProperty -Object $DryRun.raci_state_transition_application -Name $field -Context "$SourceLabel raci_state_transition_application" | Out-Null
    }
    $transitionId = Assert-NonEmptyString -Value $DryRun.raci_state_transition_application.transition_id -Context "$SourceLabel raci_state_transition_application transition_id"
    if (-not $transitionMap.ContainsKey($transitionId)) {
        throw "$SourceLabel raci_state_transition_application references unknown RACI transition '$transitionId'."
    }
    $transition = $transitionMap[$transitionId]
    if ($transition.transition_id -ne "audit_review_to_audit_accepted") {
        throw "$SourceLabel raci_state_transition_application transition_id must be audit_review_to_audit_accepted."
    }
    if ($DryRun.raci_state_transition_application.from_state -ne $transition.from_state_id -or $DryRun.raci_state_transition_application.to_state -ne $transition.to_state_id) {
        throw "$SourceLabel raci_state_transition_application state values must match R15-006 transition '$transitionId'."
    }
    if ($DryRun.raci_state_transition_application.accountable_role -ne $transition.accountable_agent_id) {
        throw "$SourceLabel raci_state_transition_application accountable_role must match R15-006 transition '$transitionId'."
    }
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $DryRun.raci_state_transition_application.responsible_roles -Context "$SourceLabel raci_state_transition_application responsible_roles") -RequiredValues @($transition.responsible_agent_ids) -Context "$SourceLabel raci_state_transition_application responsible_roles"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $DryRun.raci_state_transition_application.required_evidence -Context "$SourceLabel raci_state_transition_application required_evidence") -RequiredValues @($transition.required_evidence_refs) -Context "$SourceLabel raci_state_transition_application required_evidence"
    Assert-StringArray -Value $DryRun.raci_state_transition_application.required_approvals -Context "$SourceLabel raci_state_transition_application required_approvals" -AllowEmpty | Out-Null
    Assert-StringArray -Value $DryRun.raci_state_transition_application.consulted_roles -Context "$SourceLabel raci_state_transition_application consulted_roles" -AllowEmpty | Out-Null
    Assert-StringArray -Value $DryRun.raci_state_transition_application.informed_roles -Context "$SourceLabel raci_state_transition_application informed_roles" -AllowEmpty | Out-Null
    Assert-StringArray -Value $DryRun.raci_state_transition_application.fail_closed_conditions -Context "$SourceLabel raci_state_transition_application fail_closed_conditions" | Out-Null

    Assert-ObjectValue -Value $DryRun.reentry_packet_result -Context "$SourceLabel reentry_packet_result" | Out-Null
    foreach ($field in @("uses_card_reentry_packet_model", "card_reentry_packet_model_ref", "packet_output")) {
        Get-RequiredProperty -Object $DryRun.reentry_packet_result -Name $field -Context "$SourceLabel reentry_packet_result" | Out-Null
    }
    if (-not (Assert-BooleanValue -Value $DryRun.reentry_packet_result.uses_card_reentry_packet_model -Context "$SourceLabel reentry_packet_result uses_card_reentry_packet_model")) {
        throw "$SourceLabel reentry_packet_result must use the R15-007 card re-entry packet model."
    }
    if ($DryRun.reentry_packet_result.card_reentry_packet_model_ref -ne $CardReentryPacket.packet_model_id) {
        throw "$SourceLabel reentry_packet_result card_reentry_packet_model_ref must match the R15-007 packet model id."
    }
    Assert-ObjectValue -Value $DryRun.reentry_packet_result.packet_output -Context "$SourceLabel reentry_packet_result packet_output" | Out-Null
    $packet = $DryRun.reentry_packet_result.packet_output
    foreach ($field in @("packet_id", "source_card_id", "source_task_id", "source_milestone", "current_card_state", "intended_next_state", "target_agent_id", "target_role_type", "role_identity_ref", "memory_scope_refs", "raci_transition_refs", "allowed_canonical_paths", "allowed_evidence_refs", "optional_context_refs", "forbidden_paths", "forbidden_patterns", "load_plan", "context_budget", "allowed_actions", "forbidden_actions", "required_inputs", "required_outputs", "evidence_requirements", "approval_requirements", "escalation_targets", "fail_closed_conditions", "exit_conditions", "non_claims")) {
        Get-RequiredProperty -Object $packet -Name $field -Context "$SourceLabel reentry_packet_result packet_output" | Out-Null
    }
    if ($packet.source_task_id -ne "R15-008") {
        throw "$SourceLabel reentry_packet_result packet_output source_task_id must be R15-008."
    }
    if ($packet.target_agent_id -ne "evidence_auditor" -or $packet.target_role_type -ne "evidence_audit" -or $packet.role_identity_ref -ne "evidence_auditor") {
        throw "$SourceLabel reentry_packet_result packet_output must target evidence_auditor/evidence_audit."
    }
    if ($packet.current_card_state -ne "audit_review" -or $packet.intended_next_state -ne "audit_accepted") {
        throw "$SourceLabel reentry_packet_result packet_output must use audit_review to audit_accepted state bounds."
    }
    $packetMemoryScopes = Assert-StringArray -Value $packet.memory_scope_refs -Context "$SourceLabel reentry_packet_result packet_output memory_scope_refs"
    foreach ($scopeId in $packetMemoryScopes) {
        if ($allowedScopes -notcontains $scopeId) {
            throw "$SourceLabel reentry_packet_result packet_output memory scope '$scopeId' must be included in memory_scope_application allowed refs."
        }
    }
    $packetTransitions = Assert-StringArray -Value $packet.raci_transition_refs -Context "$SourceLabel reentry_packet_result packet_output raci_transition_refs"
    Assert-RequiredValuesPresent -Values $packetTransitions -RequiredValues @($transitionId) -Context "$SourceLabel reentry_packet_result packet_output raci_transition_refs"
    $packetAllowedPaths = Assert-StringArray -Value $packet.allowed_canonical_paths -Context "$SourceLabel reentry_packet_result packet_output allowed_canonical_paths"
    foreach ($path in $packetAllowedPaths) {
        Assert-NoBroadPath -Path $path -Context "$SourceLabel reentry_packet_result packet_output allowed_canonical_paths"
        Assert-PathExists -Path $path -Context "$SourceLabel reentry_packet_result packet_output allowed_canonical_paths" | Out-Null
    }
    foreach ($requiredPath in $targetSlicePaths) {
        if ($packetAllowedPaths -notcontains $requiredPath) {
            throw "$SourceLabel reentry_packet_result packet_output allowed_canonical_paths must include target slice path '$requiredPath'."
        }
    }
    $packetForbiddenPatterns = Assert-StringArray -Value $packet.forbidden_patterns -Context "$SourceLabel reentry_packet_result packet_output forbidden_patterns"
    Assert-RequiredValuesPresent -Values $packetForbiddenPatterns -RequiredValues @("full_repo_scan", "implicit_memory_loading", "dynamic_retrieval", "vector_search", "external_board_lookup", "runtime_execution_claim", "board_routing_runtime_claim", "card_reentry_runtime_claim", "r16_opening_claim") -Context "$SourceLabel reentry_packet_result packet_output forbidden_patterns"
    Assert-ObjectValue -Value $packet.load_plan -Context "$SourceLabel reentry_packet_result packet_output load_plan" | Out-Null
    foreach ($flag in @("exact_canonical_paths_only", "bounded_evidence_refs_only", "memory_scope_refs_only", "raci_transition_refs_only", "no_full_repo_scan", "no_implicit_historical_memory", "no_dynamic_retrieval", "no_vector_search", "no_external_board_lookup", "no_runtime_agent_memory_loading", "no_runtime_execution_claims")) {
        Get-RequiredProperty -Object $packet.load_plan -Name $flag -Context "$SourceLabel reentry_packet_result packet_output load_plan" | Out-Null
        if (-not (Assert-BooleanValue -Value $packet.load_plan.$flag -Context "$SourceLabel reentry_packet_result packet_output load_plan $flag")) {
            throw "$SourceLabel reentry_packet_result packet_output load_plan $flag must be true."
        }
    }
    Assert-ObjectValue -Value $packet.context_budget -Context "$SourceLabel reentry_packet_result packet_output context_budget" | Out-Null
    foreach ($field in @("max_files", "max_evidence_refs", "max_memory_scope_refs", "max_transition_refs", "max_notes_chars", "budget_unit")) {
        Get-RequiredProperty -Object $packet.context_budget -Name $field -Context "$SourceLabel reentry_packet_result packet_output context_budget" | Out-Null
    }
    if ((Assert-PositiveInteger -Value $packet.context_budget.max_files -Context "$SourceLabel reentry_packet_result packet_output context_budget max_files") -lt $packetAllowedPaths.Count) {
        throw "$SourceLabel reentry_packet_result packet_output context_budget max_files is smaller than allowed paths."
    }
    $packetEvidenceRefs = Assert-StringArray -Value $packet.allowed_evidence_refs -Context "$SourceLabel reentry_packet_result packet_output allowed_evidence_refs"
    Assert-RequiredValuesPresent -Values $packetEvidenceRefs -RequiredValues @($transition.required_evidence_refs) -Context "$SourceLabel reentry_packet_result packet_output allowed_evidence_refs"
    Assert-StringArray -Value $packet.required_outputs -Context "$SourceLabel reentry_packet_result packet_output required_outputs" | Out-Null
    Assert-StringArray -Value $packet.exit_conditions -Context "$SourceLabel reentry_packet_result packet_output exit_conditions" | Out-Null
    Assert-StringArray -Value $packet.escalation_targets -Context "$SourceLabel reentry_packet_result packet_output escalation_targets" | Out-Null
    foreach ($action in (Assert-StringArray -Value $packet.allowed_actions -Context "$SourceLabel reentry_packet_result packet_output allowed_actions")) {
        if (@($agentMap["evidence_auditor"].allowed_actions) -notcontains $action) {
            throw "$SourceLabel reentry_packet_result packet_output allowed action '$action' is not allowed by R15-004 evidence_auditor."
        }
    }
    Assert-RequiredNonClaims -NonClaims (Assert-StringArray -Value $packet.non_claims -Context "$SourceLabel reentry_packet_result packet_output non_claims") -Context "$SourceLabel reentry_packet_result packet_output"

    Assert-ObjectValue -Value $DryRun.model_runtime_distinction -Context "$SourceLabel model_runtime_distinction" | Out-Null
    foreach ($field in @("model_output_only", "runtime_execution_performed", "runtime_claims_prohibited", "distinction_statement")) {
        Get-RequiredProperty -Object $DryRun.model_runtime_distinction -Name $field -Context "$SourceLabel model_runtime_distinction" | Out-Null
    }
    if (-not (Assert-BooleanValue -Value $DryRun.model_runtime_distinction.model_output_only -Context "$SourceLabel model_runtime_distinction model_output_only")) {
        throw "$SourceLabel model_runtime_distinction model_output_only must be true."
    }
    if (Assert-BooleanValue -Value $DryRun.model_runtime_distinction.runtime_execution_performed -Context "$SourceLabel model_runtime_distinction runtime_execution_performed") {
        throw "$SourceLabel model_runtime_distinction must not claim runtime execution."
    }
    if (-not (Assert-BooleanValue -Value $DryRun.model_runtime_distinction.runtime_claims_prohibited -Context "$SourceLabel model_runtime_distinction runtime_claims_prohibited")) {
        throw "$SourceLabel model_runtime_distinction runtime_claims_prohibited must be true."
    }
    Assert-NonEmptyString -Value $DryRun.model_runtime_distinction.distinction_statement -Context "$SourceLabel model_runtime_distinction distinction_statement" | Out-Null

    Assert-ObjectValue -Value $DryRun.dry_run_verdict -Context "$SourceLabel dry_run_verdict" | Out-Null
    foreach ($field in @("aggregate_verdict", "bounded_reentry_context_achieved", "full_repo_scan_avoided", "non_claims_preserved", "model_conflicts_found", "r15_009_remains_planned_only", "model_output_distinguished_from_runtime_execution")) {
        Get-RequiredProperty -Object $DryRun.dry_run_verdict -Name $field -Context "$SourceLabel dry_run_verdict" | Out-Null
    }
    if ($DryRun.dry_run_verdict.aggregate_verdict -ne "passed") {
        throw "$SourceLabel dry_run_verdict aggregate_verdict must be passed."
    }
    foreach ($flag in @("bounded_reentry_context_achieved", "full_repo_scan_avoided", "non_claims_preserved", "r15_009_remains_planned_only", "model_output_distinguished_from_runtime_execution")) {
        if (-not (Assert-BooleanValue -Value $DryRun.dry_run_verdict.$flag -Context "$SourceLabel dry_run_verdict $flag")) {
            throw "$SourceLabel dry_run_verdict $flag must be true."
        }
    }
    if (Assert-BooleanValue -Value $DryRun.dry_run_verdict.model_conflicts_found -Context "$SourceLabel dry_run_verdict model_conflicts_found") {
        throw "$SourceLabel dry_run_verdict model_conflicts_found must be false."
    }

    $invalidRules = Assert-ObjectArray -Value $DryRun.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $invalidRuleIds = @()
    foreach ($rule in $invalidRules) {
        $ruleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "rule_id" -Context "$SourceLabel invalid_state_rules") -Context "$SourceLabel invalid_state_rules rule_id"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rules") -Context "$SourceLabel invalid_state_rules description" | Out-Null
        $invalidRuleIds += $ruleId
    }
    Assert-RequiredValuesPresent -Values $invalidRuleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $nonClaims = Assert-StringArray -Value $DryRun.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"
    Assert-NoOverclaimText -Values (Assert-StringArray -Value $DryRun.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    $allText = @(Get-StringValuesFromObject -Value $DryRun)
    Assert-NoOverclaimText -Values $allText -Context $SourceLabel

    return [pscustomobject]@{
        ArtifactType = $DryRun.artifact_type
        DryRunId = $DryRun.dry_run_id
        SourceTask = $DryRun.source_task
        TargetSlicePathCount = $targetSlicePaths.Count
        ClassificationCount = $classificationResults.Count
        LookupCount = $lookupResults.Count
        TargetAgentId = $DryRun.agent_role_selection.target_agent_id
        TransitionId = $DryRun.raci_state_transition_application.transition_id
        AggregateVerdict = $DryRun.dry_run_verdict.aggregate_verdict
        FullRepoScanExecuted = [bool]$DryRun.scope_boundary.full_repo_scan_executed
        RuntimeAgentsImplemented = [bool]$DryRun.scope_boundary.runtime_agents_implemented
        CardReentryRuntimeImplemented = [bool]$DryRun.scope_boundary.card_reentry_runtime_implemented
        FinalR15ProofPackageComplete = [bool]$DryRun.scope_boundary.final_r15_proof_package_complete
        R16Opened = [bool]$DryRun.scope_boundary.r16_opened
    }
}

function Test-R15ClassificationReentryDryRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$DryRunPath,
        [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
        [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
        [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
        [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
        [string]$RaciStateTransitionMatrixPath = "state\agents\r15_raci_state_transition_matrix.json",
        [string]$CardReentryPacketPath = "state\agents\r15_card_reentry_packet.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $dryRun = Get-R15ClassificationReentryDryRun -DryRunPath $DryRunPath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    $knowledgeIndex = Get-R15RepoKnowledgeIndex -IndexPath $KnowledgeIndexPath
    $agentIdentityPacket = Get-R15AgentIdentityPacket -PacketPath $AgentIdentityPacketPath
    $agentMemoryScope = Get-R15AgentMemoryScope -ScopePath $AgentMemoryScopePath
    $raciStateTransitionMatrix = Get-R15RaciStateTransitionMatrix -MatrixPath $RaciStateTransitionMatrixPath
    $cardReentryPacket = Get-R15CardReentryPacket -PacketPath $CardReentryPacketPath
    $result = Test-R15ClassificationReentryDryRunObject -DryRun $dryRun -Taxonomy $taxonomy -KnowledgeIndex $knowledgeIndex -AgentIdentityPacket $agentIdentityPacket -AgentMemoryScope $agentMemoryScope -RaciStateTransitionMatrix $raciStateTransitionMatrix -CardReentryPacket $cardReentryPacket -SourceLabel $DryRunPath
    Assert-R15ClassificationReentryDryRunStatusPosture -RepositoryRoot $RepositoryRoot
    return $result
}

Export-ModuleMember -Function Get-R15ClassificationReentryDryRun, Test-R15ClassificationReentryDryRunObject, Test-R15ClassificationReentryDryRun, Assert-R15ClassificationReentryDryRunStatusPosture
