Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackModel.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerGenerator.psm1") -Force

$script:RequiredRoles = @(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:RequiredLayerTypes = @(
    "global_governance_memory",
    "product_governance_memory",
    "milestone_authority_memory",
    "role_identity_memory",
    "task_card_memory",
    "run_session_memory",
    "evidence_memory",
    "knowledge_index_memory",
    "historical_report_memory",
    "deprecated_cleanup_candidate_memory"
)

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "artifact_version",
    "role_memory_packs_artifact_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "model_ref",
    "memory_layers_ref",
    "generator",
    "generation_policy",
    "generation_mode",
    "current_posture",
    "role_aliases",
    "allowed_roles",
    "role_packs",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules",
    "generated_artifact_statement"
)

$script:RequiredPackFields = @(
    "role_id",
    "display_name",
    "role_kind",
    "purpose",
    "aliases",
    "memory_layer_policy",
    "memory_layer_dependencies",
    "load_priority",
    "ref_budget",
    "stale_ref_policy",
    "proof_treatment",
    "role_authority_boundaries",
    "may_decide",
    "must_not_decide",
    "forbidden_actions",
    "no_full_repo_scan",
    "non_claims",
    "artifact_statement"
)

$script:ModeFalseFields = @(
    "generated_role_memory_packs_are_runtime_memory",
    "generated_role_memory_packs_are_actual_agents",
    "generated_role_memory_packs_perform_workflow_execution",
    "role_memory_pack_generator_loads_runtime_memory",
    "artifact_maps_implemented",
    "audit_maps_implemented",
    "context_load_planner_implemented",
    "context_budget_estimator_implemented",
    "role_run_envelopes_implemented",
    "raci_transition_gates_implemented",
    "handoff_packets_implemented",
    "workflow_drills_run",
    "product_runtime_implemented",
    "productized_ui_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "persistent_memory_runtime_implemented",
    "runtime_memory_loading_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "external_integrations_implemented",
    "main_merge_completed",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r16_008_or_later_implementation_claimed",
    "r16_027_or_later_task_exists"
)

$script:RequiredNonClaims = @(
    "no product runtime",
    "no productized UI",
    "no actual autonomous agents",
    "no true multi-agent execution",
    "no persistent memory runtime",
    "no runtime memory loading",
    "no retrieval runtime",
    "no vector search runtime",
    "no external integrations",
    "no GitHub Projects integration",
    "no Linear integration",
    "no Symphony integration",
    "no custom board integration",
    "no external board sync",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "no main merge",
    "no R13 closure",
    "no R14 caveat removal",
    "no R15 caveat removal",
    "no R13 partial-gate conversion",
    "no R16-008 implementation",
    "no R16-027 or later task",
    "no artifact map",
    "no audit map",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "generated baseline memory layers remain committed state artifacts, not runtime memory",
    "generated baseline role memory packs are committed state artifacts, not runtime memory",
    "generated baseline role memory packs are not actual agents",
    "generated baseline role memory packs do not perform work or workflow execution"
)

$script:RequiredValidationCommands = @(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_packs.ps1 -PacksPath state\memory\r16_role_memory_packs.json -ModelPath state\memory\r16_role_memory_pack_model.json -MemoryLayersPath state\memory\r16_memory_layers.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_model.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_pack_model.ps1 -ModelPath state\memory\r16_role_memory_pack_model.json -ContractPath contracts\memory\r16_role_memory_pack_model.contract.json -MemoryLayersPath state\memory\r16_memory_layers.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layers.ps1 -MemoryLayersPath state\memory\r16_memory_layers.json -ContractPath contracts\memory\r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layer_contract.ps1 -ContractPath contracts\memory\r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_kpi_baseline_target_scorecard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state\governance\r16_kpi_baseline_target_scorecard.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1 -PacketPath state\governance\r16_planning_authority_reference.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1",
    "git diff --check",
    "git status --short",
    "git rev-parse HEAD",
    "git rev-parse ""HEAD^{tree}""",
    "git branch --show-current"
)

$script:RequiredInvalidRuleIds = @(
    "missing_role_pack_rejected",
    "unknown_role_rejected",
    "alias_to_unknown_role_rejected",
    "missing_model_dependency_rejected",
    "missing_memory_layer_dependency_rejected",
    "unknown_memory_layer_type_rejected",
    "missing_required_layer_for_role_rejected",
    "forbidden_layer_included_for_role_rejected",
    "missing_load_priority_rejected",
    "non_deterministic_load_order_rejected",
    "broad_repo_scan_requested_rejected",
    "wildcard_source_ref_requested_rejected",
    "stale_ref_accepted_without_caveat_rejected",
    "generated_report_as_machine_proof_rejected",
    "planning_report_as_implementation_proof_rejected",
    "runtime_memory_loading_claim_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "external_integration_claim_rejected",
    "artifact_map_claim_rejected",
    "audit_map_claim_rejected",
    "context_load_planner_claim_rejected",
    "role_run_envelope_claim_rejected",
    "raci_transition_gate_claim_rejected",
    "handoff_packet_claim_rejected",
    "workflow_drill_claim_rejected",
    "r16_008_implementation_claim_rejected",
    "r16_027_or_later_task_rejected",
    "r13_closure_claim_rejected",
    "r14_caveat_removal_rejected",
    "r15_caveat_removal_rejected"
)

function Test-HasProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Object -is [System.Collections.IDictionary]) {
        return $Object.Contains($Name)
    }

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

    if ($Object -is [System.Collections.IDictionary]) {
        $PSCmdlet.WriteObject($Object[$Name], $false)
        return
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

function Assert-IntegerValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace($item)) {
            throw "$Context must contain only non-empty strings."
        }
    }

    $PSCmdlet.WriteObject([string[]]$items, $false)
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
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context must contain only objects."
        }
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$ExpectedValues,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $actual = @($Values | Sort-Object)
    $expected = @($ExpectedValues | Sort-Object)
    if ($actual.Count -ne $expected.Count) {
        throw "$Context must contain exactly: $($expected -join ', ')."
    }

    for ($index = 0; $index -lt $expected.Count; $index += 1) {
        if ($actual[$index] -ne $expected[$index]) {
            throw "$Context must contain exactly: $($expected -join ', ')."
        }
    }
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

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-GeneratedReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/") -like "governance/reports/*"
}

function Test-PlanningReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized -in @(
        "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
        "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"
    )
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        throw "$Context must be a repo-relative exact path, not an absolute path."
    }
    if (Test-BroadRepoRootPath -Path $Path) {
        throw "$Context rejects broad repo scan or broad repo root source ref '$Path'."
    }
    if (Test-WildcardPath -Path $Path) {
        throw "$Context rejects wildcard source ref '$Path'."
    }
    if ($Path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }

    if ($RequireLeaf -and -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }

    return $resolved
}

function Invoke-GitScalar {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $output = & git -C $RepositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return [string]($output | Select-Object -First 1)
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)
    $json = ($Object | ConvertTo-Json -Depth 100)
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $json = ConvertTo-StableJson -Object $Object
    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $json + "`n", $encoding)
}

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-RepositoryRoot {
    param([AllowNull()][string]$RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $RepositoryRoot = $repoRoot
    }

    if (Test-Path -LiteralPath $RepositoryRoot) {
        return (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Get-RoleMemoryPackInputBundle {
    param(
        [Parameter(Mandatory = $true)][string]$ModelPath,
        [Parameter(Mandatory = $true)][string]$MemoryLayersPath,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ModelContractPath = "contracts\memory\r16_role_memory_pack_model.contract.json",
        [string]$MemoryLayerContractPath = "contracts\memory\r16_memory_layer.contract.json"
    )

    Test-R16RoleMemoryPackModel -ModelPath $ModelPath -ContractPath $ModelContractPath -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16MemoryLayers -MemoryLayersPath $MemoryLayersPath -ContractPath $MemoryLayerContractPath -RepositoryRoot $RepositoryRoot | Out-Null

    $model = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $ModelPath) -Label "R16 role memory pack model"
    $memoryLayers = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $MemoryLayersPath) -Label "R16 memory layers"

    $layerMap = @{}
    foreach ($layer in @($memoryLayers.layer_records)) {
        $layerType = [string]$layer.layer_type
        if ($layerMap.ContainsKey($layerType)) {
            throw "R16 memory layers contain duplicate layer_type '$layerType'."
        }
        $layerMap[$layerType] = $layer
    }

    foreach ($requiredLayerType in $script:RequiredLayerTypes) {
        if (-not $layerMap.ContainsKey($requiredLayerType)) {
            throw "R16 memory layers are missing required layer type '$requiredLayerType'."
        }
    }

    return [pscustomobject]@{
        Model = $model
        MemoryLayers = $memoryLayers
        LayerMap = $layerMap
    }
}

function New-ContentIdentity {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$IdentityBasis
    )

    $resolved = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $RepositoryRoot -Context "content identity $Path" -RequireLeaf
    return [ordered]@{
        hash_algorithm = "SHA256"
        sha256 = Get-FileSha256 -Path $resolved
        identity_basis = $IdentityBasis
    }
}

function Convert-SourceRefForPack {
    param(
        [Parameter(Mandatory = $true)]$SourceRef,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $path = Assert-NonEmptyString -Value $SourceRef.path -Context "source ref path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "source ref '$($SourceRef.ref_id)'" -RequireLeaf | Out-Null

    return [ordered]@{
        ref_id = [string]$SourceRef.ref_id
        ref_type = [string]$SourceRef.ref_type
        path = $path
        authority_class = [string]$SourceRef.authority_class
        proof_treatment = [string]$SourceRef.proof_treatment
        exact_load_only = [bool]$SourceRef.exact_load_only
        broad_scan_allowed = [bool]$SourceRef.broad_scan_allowed
        wildcard_allowed = [bool]$SourceRef.wildcard_allowed
        stale_state = [string]$SourceRef.stale_state
        stale_caveat = [string]$SourceRef.stale_caveat
        machine_proof = [bool]$SourceRef.machine_proof
        implementation_proof = [bool]$SourceRef.implementation_proof
        content_identity = New-ContentIdentity -Path $path -RepositoryRoot $RepositoryRoot -IdentityBasis "Exact repo-relative source ref preserved in R16-007 generated baseline role memory pack."
    }
}

function Convert-LayerDependencyForPack {
    param(
        [Parameter(Mandatory = $true)]$Layer,
        [Parameter(Mandatory = $true)][int]$LoadOrder,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    return [ordered]@{
        load_order = $LoadOrder
        layer_id = [string]$Layer.layer_id
        layer_type = [string]$Layer.layer_type
        authority_class = [string]$Layer.authority_class
        memory_scope_kind = [string]$Layer.memory_scope_kind
        source_artifact = "state/memory/r16_memory_layers.json"
        exact_ref_required = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        source_refs = @($Layer.source_refs | ForEach-Object { Convert-SourceRefForPack -SourceRef $_ -RepositoryRoot $RepositoryRoot })
        freshness = Copy-JsonObject -Value $Layer.freshness
        role_eligibility = Copy-JsonObject -Value $Layer.role_eligibility
        load_rules = Copy-JsonObject -Value $Layer.load_rules
        exclusion_rules = Copy-JsonObject -Value $Layer.exclusion_rules
        context_budget = Copy-JsonObject -Value $Layer.context_budget
        proof_treatment = [string]$Layer.proof_treatment
        evidence_requirements = Copy-JsonObject -Value $Layer.evidence_requirements
        allowed_content = [string[]]$Layer.allowed_content
        forbidden_content = [string[]]$Layer.forbidden_content
        non_claims = [string[]]$Layer.non_claims
    }
}

function New-RolePack {
    param(
        [Parameter(Mandatory = $true)][string]$RoleId,
        [Parameter(Mandatory = $true)]$Model,
        [Parameter(Mandatory = $true)][hashtable]$LayerMap,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $catalog = @($Model.role_catalog | Where-Object { $_.role_id -eq $RoleId })
    if ($catalog.Count -ne 1) {
        throw "R16 role catalog must define role '$RoleId' exactly once."
    }

    $policy = @($Model.role_memory_layer_policy | Where-Object { $_.role_id -eq $RoleId })
    if ($policy.Count -ne 1) {
        throw "R16 role memory layer policy must define role '$RoleId' exactly once."
    }

    $authority = @($Model.role_authority_policy | Where-Object { $_.role_id -eq $RoleId })
    if ($authority.Count -ne 1) {
        throw "R16 role authority policy must define role '$RoleId' exactly once."
    }

    $perRoleForbidden = @($Model.forbidden_action_policy.per_role | Where-Object { $_.role_id -eq $RoleId })
    if ($perRoleForbidden.Count -ne 1) {
        throw "R16 forbidden action policy must define role '$RoleId' exactly once."
    }

    $loadPriority = @($policy[0].load_priority | Sort-Object -Property @{ Expression = { [int]$_.order } })
    $dependencies = @()
    foreach ($loadItem in $loadPriority) {
        $layerType = [string]$loadItem.layer_type
        if (-not $LayerMap.ContainsKey($layerType)) {
            throw "Role '$RoleId' references missing memory layer dependency '$layerType'."
        }
        $dependencies += Convert-LayerDependencyForPack -Layer $LayerMap[$layerType] -LoadOrder ([int]$loadItem.order) -RepositoryRoot $RepositoryRoot
    }

    $aliases = @($Model.role_aliases | Where-Object { $_.role_id -eq $RoleId } | ForEach-Object { [string]$_.alias } | Sort-Object)

    return [ordered]@{
        role_id = $RoleId
        display_name = [string]$catalog[0].display_name
        role_kind = [string]$catalog[0].role_kind
        purpose = [string]$catalog[0].purpose
        aliases = [string[]]$aliases
        memory_layer_policy = [ordered]@{
            allowed_memory_layer_types = [string[]]$policy[0].allowed_memory_layer_types
            required_memory_layer_types = [string[]]$policy[0].required_memory_layer_types
            forbidden_memory_layer_types = [string[]]$policy[0].forbidden_memory_layer_types
            source_ref_treatment = Copy-JsonObject -Value $policy[0].source_ref_treatment
            model_memory_layer_dependencies = Copy-JsonObject -Value $policy[0].memory_layer_dependencies
        }
        memory_layer_dependencies = $dependencies
        load_priority = Copy-JsonObject -Value $policy[0].load_priority
        ref_budget = Copy-JsonObject -Value $policy[0].ref_budget
        stale_ref_policy = Copy-JsonObject -Value $policy[0].stale_ref_handling
        proof_treatment = Copy-JsonObject -Value $policy[0].proof_treatment
        role_authority_boundaries = [string[]]$authority[0].authority_boundaries
        may_decide = [string[]]$authority[0].may_decide
        must_not_decide = [string[]]$authority[0].must_not_decide
        forbidden_actions = [ordered]@{
            global_forbidden_actions_preserved_from_model = [string[]]$Model.forbidden_action_policy.global_forbidden_actions
            role_forbidden_actions_preserved_from_model = [string[]]$perRoleForbidden[0].forbidden_actions
            r16_007_authorized_generation_scope = "R16-007 generates committed baseline role memory pack state artifacts only; this does not authorize runtime memory loading, actual agents, true multi-agent execution, artifact maps, audit maps, context-load planners, role-run envelopes, handoff packets, or workflow drills."
        }
        no_full_repo_scan = [ordered]@{
            exact_load_only = $true
            path_level_source_refs_required = $true
            broad_repo_scan_allowed = $false
            broad_repo_scan_requested = $false
            full_repo_scan_allowed = $false
            full_repo_scan_requested = $false
            wildcard_source_refs_allowed = $false
            wildcard_source_refs_requested = $false
        }
        non_claims = [string[]]$script:RequiredNonClaims
        artifact_statement = "This generated role memory pack is a committed state artifact only; it is not runtime memory, not an actual agent, and does not perform work or workflow execution."
    }
}

function New-R16RoleMemoryPackObject {
    [CmdletBinding()]
    param(
        [string]$ModelPath = "state\memory\r16_role_memory_pack_model.json",
        [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
        [string]$RepositoryRoot,
        [string]$ModelContractPath = "contracts\memory\r16_role_memory_pack_model.contract.json",
        [string]$MemoryLayerContractPath = "contracts\memory\r16_memory_layer.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-SafeRepoRelativePath -Path $ModelPath -RepositoryRoot $resolvedRepositoryRoot -Context "ModelPath" -RequireLeaf | Out-Null
    Assert-SafeRepoRelativePath -Path $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Context "MemoryLayersPath" -RequireLeaf | Out-Null

    $inputs = Get-RoleMemoryPackInputBundle -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -ModelContractPath $ModelContractPath -MemoryLayerContractPath $MemoryLayerContractPath -RepositoryRoot $resolvedRepositoryRoot
    $model = $inputs.Model
    $memoryLayers = $inputs.MemoryLayers
    $layerMap = $inputs.LayerMap

    $head = Invoke-GitScalar -Arguments @("rev-parse", "HEAD") -RepositoryRoot $resolvedRepositoryRoot
    $tree = Invoke-GitScalar -Arguments @("rev-parse", "HEAD^{tree}") -RepositoryRoot $resolvedRepositoryRoot

    $rolePacks = @()
    foreach ($roleId in $script:RequiredRoles) {
        $rolePacks += New-RolePack -RoleId $roleId -Model $model -LayerMap $layerMap -RepositoryRoot $resolvedRepositoryRoot
    }

    return [ordered]@{
        artifact_type = "r16_role_memory_packs"
        artifact_version = "v1"
        role_memory_packs_artifact_id = "aioffice-r16-007-baseline-role-memory-packs-v1"
        source_milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
        source_task = "R16-007"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
        generated_from_head = $head
        generated_from_tree = $tree
        model_ref = [ordered]@{
            path = "state/memory/r16_role_memory_pack_model.json"
            artifact_type = [string]$model.artifact_type
            contract_id = [string]$model.role_memory_pack_model_contract_id
            source_task = [string]$model.source_task
            exact_load_only = $true
            broad_scan_allowed = $false
            wildcard_allowed = $false
            content_identity = New-ContentIdentity -Path $ModelPath -RepositoryRoot $resolvedRepositoryRoot -IdentityBasis "Exact R16-006 role memory pack model read by R16-007 deterministic role memory pack generator."
        }
        memory_layers_ref = [ordered]@{
            path = "state/memory/r16_memory_layers.json"
            artifact_type = [string]$memoryLayers.artifact_type
            artifact_id = [string]$memoryLayers.memory_layer_artifact_id
            source_task = [string]$memoryLayers.source_task
            exact_load_only = $true
            broad_scan_allowed = $false
            wildcard_allowed = $false
            layer_types = [string[]]$script:RequiredLayerTypes
            content_identity = New-ContentIdentity -Path $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -IdentityBasis "Exact R16-005 baseline memory layers read by R16-007 deterministic role memory pack generator."
        }
        generator = [ordered]@{
            module_path = "tools/R16RoleMemoryPackGenerator.psm1"
            cli_path = "tools/new_r16_role_memory_packs.ps1"
            validator_path = "tools/validate_r16_role_memory_packs.ps1"
            deterministic_output_ordering = $true
            reads_model_ref = "state/memory/r16_role_memory_pack_model.json"
            reads_memory_layers_ref = "state/memory/r16_memory_layers.json"
            reads_bounded_exact_refs_only = $true
            broad_repo_scan_performed = $false
            wildcard_paths_loaded = $false
        }
        generation_policy = [ordered]@{
            source_refs_are_exact_repo_relative_paths = $true
            broad_repo_scan_allowed = $false
            broad_repo_scan_requested = $false
            full_repo_scan_allowed = $false
            full_repo_scan_requested = $false
            wildcard_source_refs_allowed = $false
            wildcard_source_refs_requested = $false
            stale_refs_fail_closed_without_caveat = $true
            stale_refs_accepted_without_caveat = $false
            generated_reports_as_machine_proof = $false
            planning_reports_as_implementation_proof = $false
        }
        generation_mode = [ordered]@{
            deterministic_role_memory_pack_generator_implemented = $true
            generated_baseline_role_memory_packs_exist = $true
            generated_baseline_role_memory_packs_are_state_artifacts = $true
            generated_role_memory_packs_are_runtime_memory = $false
            generated_role_memory_packs_are_actual_agents = $false
            generated_role_memory_packs_perform_workflow_execution = $false
            role_memory_pack_generator_implemented = $true
            role_memory_pack_generator_loads_runtime_memory = $false
            artifact_maps_implemented = $false
            audit_maps_implemented = $false
            context_load_planner_implemented = $false
            context_budget_estimator_implemented = $false
            role_run_envelopes_implemented = $false
            raci_transition_gates_implemented = $false
            handoff_packets_implemented = $false
            workflow_drills_run = $false
            product_runtime_implemented = $false
            productized_ui_implemented = $false
            actual_autonomous_agents_implemented = $false
            true_multi_agent_execution_implemented = $false
            persistent_memory_runtime_implemented = $false
            runtime_memory_loading_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            external_integrations_implemented = $false
            main_merge_completed = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            r16_008_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        current_posture = [ordered]@{
            active_through_task = "R16-007"
            complete_tasks = [string[]](1..7 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            planned_tasks = [string[]](8..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            posture_statement = "R16 active through R16-007 only; R16-008 through R16-026 remain planned only."
            r16_008_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        role_aliases = Copy-JsonObject -Value $model.role_aliases
        allowed_roles = [string[]]$script:RequiredRoles
        role_packs = $rolePacks
        non_claims = [string[]]$script:RequiredNonClaims
        preserved_boundaries = Copy-JsonObject -Value $model.preserved_boundaries
        validation_commands = @($script:RequiredValidationCommands | ForEach-Object { [ordered]@{ command = $_; required = $true } })
        invalid_state_rules = @($script:RequiredInvalidRuleIds | ForEach-Object {
                [ordered]@{
                    rule_id = $_
                    description = "Fail closed when $($_.Replace('_', ' ')) occurs."
                }
            })
        generated_artifact_statement = "Generated baseline role memory packs are committed state artifacts, not runtime memory, not actual agents, and not workflow execution. R16 is active through R16-007 only; R16-008 through R16-026 remain planned only."
    }
}

function Assert-FalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        $value = Get-RequiredProperty -Object $Object -Name $field -Context $Context
        if ((Assert-BooleanValue -Value $value -Context "$Context $field") -ne $false) {
            throw "$Context $field must be False."
        }
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundary = Assert-ObjectValue -Value $Value -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r13" -Context $Context) -Context "$Context r13"
    if ($r13.status -ne "failed/partial" -or $r13.active_through -ne "R13-018") {
        throw "$Context r13 must stay failed/partial through R13-018."
    }
    if ((Assert-BooleanValue -Value $r13.closed -Context "$Context r13 closed") -ne $false) {
        throw "$Context r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $r13.partial_gates_remain_partial -Context "$Context r13 partial_gates_remain_partial") -ne $true) {
        throw "$Context r13 partial_gates_remain_partial must be True."
    }

    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r14" -Context $Context) -Context "$Context r14"
    if ($r14.status -ne "accepted_with_caveats" -or $r14.through -ne "R14-006") {
        throw "$Context r14 must stay accepted_with_caveats through R14-006."
    }
    if ((Assert-BooleanValue -Value $r14.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }

    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r15" -Context $Context) -Context "$Context r15"
    if ($r15.status -ne "accepted_with_caveats" -or $r15.through -ne "R15-009") {
        throw "$Context r15 must stay accepted_with_caveats through R15-009."
    }
    if ($r15.audited_head -ne "d9685030a0556a528684d28367db83f4c72f7fc9" -or $r15.audited_tree -ne "7529230df0c1f5bec3625ba654b035a2af824e9b") {
        throw "$Context r15 audited head/tree must remain unchanged."
    }
    if ($r15.post_audit_support_commit -ne "3058bd6ed5067c97f744c92b9b9235004f0568b0") {
        throw "$Context r15 post_audit_support_commit must remain unchanged."
    }
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r15.stale_generated_from_caveat_preserved -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale_generated_from_caveat_preserved must be True."
    }
}

function Assert-SourceRefForPack {
    param(
        [Parameter(Mandatory = $true)]$SourceRef,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    foreach ($field in @("ref_id", "ref_type", "path", "authority_class", "proof_treatment", "exact_load_only", "broad_scan_allowed", "wildcard_allowed", "stale_state", "stale_caveat", "machine_proof", "implementation_proof")) {
        Get-RequiredProperty -Object $SourceRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $SourceRef.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null

    if ((Assert-BooleanValue -Value $SourceRef.exact_load_only -Context "$Context exact_load_only") -ne $true) {
        throw "$Context exact_load_only must be True."
    }
    if ((Assert-BooleanValue -Value $SourceRef.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $SourceRef.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }

    if ($SourceRef.stale_state -eq "stale" -and [string]::IsNullOrWhiteSpace([string]$SourceRef.stale_caveat)) {
        throw "$Context stale ref accepted without caveat."
    }
    if (Test-GeneratedReportPath -Path $path) {
        if ((Assert-BooleanValue -Value $SourceRef.machine_proof -Context "$Context machine_proof") -ne $false) {
            throw "$Context generated report treated as machine proof."
        }
    }
    if (Test-PlanningReportPath -Path $path) {
        if ((Assert-BooleanValue -Value $SourceRef.implementation_proof -Context "$Context implementation_proof") -ne $false) {
            throw "$Context planning report treated as implementation proof."
        }
    }
}

function Assert-LoadPriority {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string[]]$ExpectedLayerTypes,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = Assert-ObjectArray -Value $Value -Context $Context
    if ($items.Count -ne $ExpectedLayerTypes.Count) {
        throw "$Context must include one deterministic load priority entry per allowed layer type."
    }

    $orders = @()
    $layerTypes = @()
    for ($index = 0; $index -lt $items.Count; $index += 1) {
        $order = Assert-IntegerValue -Value (Get-RequiredProperty -Object $items[$index] -Name "order" -Context "$Context[$index]") -Context "$Context[$index] order"
        $layerType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $items[$index] -Name "layer_type" -Context "$Context[$index]") -Context "$Context[$index] layer_type"
        $orders += $order
        $layerTypes += $layerType
        if ($order -ne ($index + 1)) {
            throw "$Context has non-deterministic load order; order values must be contiguous from 1."
        }
    }

    if (@($orders | Sort-Object -Unique).Count -ne $orders.Count) {
        throw "$Context has non-deterministic load order; order values must be unique."
    }
    Assert-ExactStringSet -Values $layerTypes -ExpectedValues $ExpectedLayerTypes -Context "$Context layer types"
}

function Assert-RolePack {
    param(
        [Parameter(Mandatory = $true)]$Pack,
        [Parameter(Mandatory = $true)]$Model,
        [Parameter(Mandatory = $true)][hashtable]$LayerMap,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:RequiredPackFields) {
        Get-RequiredProperty -Object $Pack -Name $field -Context $Context | Out-Null
    }

    $roleId = Assert-NonEmptyString -Value $Pack.role_id -Context "$Context role_id"
    if ($script:RequiredRoles -notcontains $roleId) {
        throw "$Context defines unknown role '$roleId'."
    }

    $policy = @($Model.role_memory_layer_policy | Where-Object { $_.role_id -eq $roleId })
    if ($policy.Count -ne 1) {
        throw "$Context cannot resolve model policy for role '$roleId'."
    }

    $packPolicy = Assert-ObjectValue -Value $Pack.memory_layer_policy -Context "$Context memory_layer_policy"
    $allowed = Assert-StringArray -Value (Get-RequiredProperty -Object $packPolicy -Name "allowed_memory_layer_types" -Context "$Context memory_layer_policy") -Context "$Context allowed_memory_layer_types"
    $required = Assert-StringArray -Value (Get-RequiredProperty -Object $packPolicy -Name "required_memory_layer_types" -Context "$Context memory_layer_policy") -Context "$Context required_memory_layer_types"
    $forbidden = Assert-StringArray -Value (Get-RequiredProperty -Object $packPolicy -Name "forbidden_memory_layer_types" -Context "$Context memory_layer_policy") -Context "$Context forbidden_memory_layer_types" -AllowEmpty

    Assert-ExactStringSet -Values $allowed -ExpectedValues ([string[]]$policy[0].allowed_memory_layer_types) -Context "$Context allowed_memory_layer_types"
    Assert-ExactStringSet -Values $required -ExpectedValues ([string[]]$policy[0].required_memory_layer_types) -Context "$Context required_memory_layer_types"
    Assert-ExactStringSet -Values $forbidden -ExpectedValues ([string[]]$policy[0].forbidden_memory_layer_types) -Context "$Context forbidden_memory_layer_types"

    foreach ($layerType in @($allowed + $required + $forbidden)) {
        if ($script:RequiredLayerTypes -notcontains $layerType) {
            throw "$Context references unknown memory layer type '$layerType'."
        }
    }

    Assert-LoadPriority -Value $Pack.load_priority -ExpectedLayerTypes $allowed -Context "$Context load_priority"

    $dependencies = Assert-ObjectArray -Value $Pack.memory_layer_dependencies -Context "$Context memory_layer_dependencies"
    $dependencyTypes = @()
    for ($index = 0; $index -lt $dependencies.Count; $index += 1) {
        $dependency = $dependencies[$index]
        $layerType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $dependency -Name "layer_type" -Context "$Context memory_layer_dependencies[$index]") -Context "$Context memory_layer_dependencies[$index] layer_type"
        $dependencyTypes += $layerType
        if ($script:RequiredLayerTypes -notcontains $layerType) {
            throw "$Context memory_layer_dependencies[$index] references unknown memory layer type '$layerType'."
        }
        if (-not $LayerMap.ContainsKey($layerType)) {
            throw "$Context memory_layer_dependencies[$index] memory layer dependency '$layerType' is missing from state/memory/r16_memory_layers.json."
        }
        if ($forbidden -contains $layerType) {
            throw "$Context forbidden layer included for role '$roleId': '$layerType'."
        }
        $loadOrder = Assert-IntegerValue -Value (Get-RequiredProperty -Object $dependency -Name "load_order" -Context "$Context memory_layer_dependencies[$index]") -Context "$Context memory_layer_dependencies[$index] load_order"
        if ($loadOrder -ne ($index + 1)) {
            throw "$Context memory_layer_dependencies have non-deterministic load order."
        }

        $sourceRefs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $dependency -Name "source_refs" -Context "$Context memory_layer_dependencies[$index]") -Context "$Context memory_layer_dependencies[$index] source_refs"
        for ($sourceIndex = 0; $sourceIndex -lt $sourceRefs.Count; $sourceIndex += 1) {
            Assert-SourceRefForPack -SourceRef $sourceRefs[$sourceIndex] -Context "$Context memory_layer_dependencies[$index] source_refs[$sourceIndex]" -RepositoryRoot $RepositoryRoot
        }
    }

    foreach ($requiredLayer in $required) {
        if ($dependencyTypes -notcontains $requiredLayer) {
            throw "$Context is missing required layer for role '$roleId': '$requiredLayer'."
        }
    }
    Assert-ExactStringSet -Values $dependencyTypes -ExpectedValues $allowed -Context "$Context memory_layer_dependencies layer_type"

    $noScan = Assert-ObjectValue -Value $Pack.no_full_repo_scan -Context "$Context no_full_repo_scan"
    foreach ($trueField in @("exact_load_only", "path_level_source_refs_required")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $noScan -Name $trueField -Context "$Context no_full_repo_scan") -Context "$Context no_full_repo_scan $trueField") -ne $true) {
            throw "$Context no_full_repo_scan $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_requested", "full_repo_scan_allowed", "full_repo_scan_requested", "wildcard_source_refs_allowed", "wildcard_source_refs_requested")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $noScan -Name $falseField -Context "$Context no_full_repo_scan") -Context "$Context no_full_repo_scan $falseField") -ne $false) {
            throw "$Context no_full_repo_scan $falseField must be False."
        }
    }

    $stale = Assert-ObjectValue -Value $Pack.stale_ref_policy -Context "$Context stale_ref_policy"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $stale -Name "stale_refs_fail_closed_without_caveat" -Context "$Context stale_ref_policy") -Context "$Context stale_ref_policy stale_refs_fail_closed_without_caveat") -ne $true) {
        throw "$Context stale refs must fail closed without caveat."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $stale -Name "stale_refs_accepted_without_caveat" -Context "$Context stale_ref_policy") -Context "$Context stale_ref_policy stale_refs_accepted_without_caveat") -ne $false) {
        throw "$Context stale refs accepted without caveat must be False."
    }

    $proof = Assert-ObjectValue -Value $Pack.proof_treatment -Context "$Context proof_treatment"
    foreach ($falseField in @("planning_reports_as_implementation_proof", "generated_reports_as_machine_proof", "role_pack_model_as_runtime_proof")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $proof -Name $falseField -Context "$Context proof_treatment") -Context "$Context proof_treatment $falseField") -ne $false) {
            throw "$Context proof_treatment $falseField must be False."
        }
    }

    Assert-StringArray -Value $Pack.aliases -Context "$Context aliases" | Out-Null
    Assert-StringArray -Value $Pack.role_authority_boundaries -Context "$Context role_authority_boundaries" | Out-Null
    Assert-StringArray -Value $Pack.may_decide -Context "$Context may_decide" -AllowEmpty | Out-Null
    Assert-StringArray -Value $Pack.must_not_decide -Context "$Context must_not_decide" | Out-Null
    Assert-ObjectValue -Value $Pack.forbidden_actions -Context "$Context forbidden_actions" | Out-Null

    $artifactStatement = Assert-NonEmptyString -Value $Pack.artifact_statement -Context "$Context artifact_statement"
    if ($artifactStatement -notmatch 'committed state artifact' -or $artifactStatement -notmatch 'not runtime memory' -or $artifactStatement -notmatch 'not an actual agent' -or $artifactStatement -notmatch 'does not perform work or workflow execution') {
        throw "$Context artifact_statement must state state-artifact-only, not runtime memory, not actual agent, and no workflow execution."
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-007") {
        throw "$Context active_through_task must be R16-007."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    Assert-ExactStringSet -Values $completeTasks -ExpectedValues ([string[]](1..7 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues ([string[]](8..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"

    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in @($completeTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 8) {
            throw "$Context claims R16-008 implementation with '$taskId'."
        }
    }

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_008_or_later_implementation_claimed" -Context $Context) -Context "$Context r16_008_or_later_implementation_claimed") -ne $false) {
        throw "$Context r16_008_or_later_implementation_claimed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_027_or_later_task_exists" -Context $Context) -Context "$Context r16_027_or_later_task_exists") -ne $false) {
        throw "$Context r16_027_or_later_task_exists must be False."
    }
}

function Test-R16RoleMemoryPacksObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Packs,
        [Parameter(Mandatory = $true)]$Model,
        [Parameter(Mandatory = $true)]$MemoryLayers,
        [Parameter(Mandatory = $true)][hashtable]$LayerMap,
        [string]$RepositoryRoot = $repoRoot,
        [string]$SourceLabel = "R16 role memory packs"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Packs -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Packs.artifact_type -ne "r16_role_memory_packs") {
        throw "$SourceLabel artifact_type must be r16_role_memory_packs."
    }
    if ($Packs.artifact_version -ne "v1") {
        throw "$SourceLabel artifact_version must be v1."
    }
    if ($Packs.source_task -ne "R16-007") {
        throw "$SourceLabel source_task must be R16-007."
    }
    if ($Packs.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Packs.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }

    $modelRef = Assert-ObjectValue -Value $Packs.model_ref -Context "$SourceLabel model_ref"
    if ($modelRef.path -ne "state/memory/r16_role_memory_pack_model.json") {
        throw "$SourceLabel missing model dependency: model_ref.path must be state/memory/r16_role_memory_pack_model.json."
    }
    Assert-SafeRepoRelativePath -Path $modelRef.path -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel model_ref" -RequireLeaf | Out-Null
    if ((Assert-BooleanValue -Value $modelRef.exact_load_only -Context "$SourceLabel model_ref exact_load_only") -ne $true -or (Assert-BooleanValue -Value $modelRef.broad_scan_allowed -Context "$SourceLabel model_ref broad_scan_allowed") -ne $false -or (Assert-BooleanValue -Value $modelRef.wildcard_allowed -Context "$SourceLabel model_ref wildcard_allowed") -ne $false) {
        throw "$SourceLabel model_ref must be exact-load only with no broad scan or wildcard refs."
    }

    $memoryLayersRef = Assert-ObjectValue -Value $Packs.memory_layers_ref -Context "$SourceLabel memory_layers_ref"
    if ($memoryLayersRef.path -ne "state/memory/r16_memory_layers.json") {
        throw "$SourceLabel missing memory layer dependency: memory_layers_ref.path must be state/memory/r16_memory_layers.json."
    }
    Assert-SafeRepoRelativePath -Path $memoryLayersRef.path -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel memory_layers_ref" -RequireLeaf | Out-Null
    if ((Assert-BooleanValue -Value $memoryLayersRef.exact_load_only -Context "$SourceLabel memory_layers_ref exact_load_only") -ne $true -or (Assert-BooleanValue -Value $memoryLayersRef.broad_scan_allowed -Context "$SourceLabel memory_layers_ref broad_scan_allowed") -ne $false -or (Assert-BooleanValue -Value $memoryLayersRef.wildcard_allowed -Context "$SourceLabel memory_layers_ref wildcard_allowed") -ne $false) {
        throw "$SourceLabel memory_layers_ref must be exact-load only with no broad scan or wildcard refs."
    }

    $generator = Assert-ObjectValue -Value $Packs.generator -Context "$SourceLabel generator"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $generator -Name "deterministic_output_ordering" -Context "$SourceLabel generator") -Context "$SourceLabel generator deterministic_output_ordering") -ne $true) {
        throw "$SourceLabel generator deterministic_output_ordering must be True."
    }
    foreach ($falseField in @("broad_repo_scan_performed", "wildcard_paths_loaded")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $generator -Name $falseField -Context "$SourceLabel generator") -Context "$SourceLabel generator $falseField") -ne $false) {
            throw "$SourceLabel generator $falseField must be False."
        }
    }

    $policy = Assert-ObjectValue -Value $Packs.generation_policy -Context "$SourceLabel generation_policy"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policy -Name "source_refs_are_exact_repo_relative_paths" -Context "$SourceLabel generation_policy") -Context "$SourceLabel generation_policy source_refs_are_exact_repo_relative_paths") -ne $true) {
        throw "$SourceLabel generation_policy source_refs_are_exact_repo_relative_paths must be True."
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_requested", "full_repo_scan_allowed", "full_repo_scan_requested", "wildcard_source_refs_allowed", "wildcard_source_refs_requested", "stale_refs_accepted_without_caveat", "generated_reports_as_machine_proof", "planning_reports_as_implementation_proof")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policy -Name $falseField -Context "$SourceLabel generation_policy") -Context "$SourceLabel generation_policy $falseField") -ne $false) {
            throw "$SourceLabel generation_policy $falseField must be False."
        }
    }

    $mode = Assert-ObjectValue -Value $Packs.generation_mode -Context "$SourceLabel generation_mode"
    foreach ($trueField in @("deterministic_role_memory_pack_generator_implemented", "generated_baseline_role_memory_packs_exist", "generated_baseline_role_memory_packs_are_state_artifacts", "role_memory_pack_generator_implemented")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name $trueField -Context "$SourceLabel generation_mode") -Context "$SourceLabel generation_mode $trueField") -ne $true) {
            throw "$SourceLabel generation_mode $trueField must be True."
        }
    }
    Assert-FalseFields -Object $mode -Fields $script:ModeFalseFields -Context "$SourceLabel generation_mode"
    Assert-CurrentPosture -Posture $Packs.current_posture -Context "$SourceLabel current_posture"

    Assert-ExactStringSet -Values (Assert-StringArray -Value $Packs.allowed_roles -Context "$SourceLabel allowed_roles") -ExpectedValues $script:RequiredRoles -Context "$SourceLabel allowed_roles"

    $aliases = Assert-ObjectArray -Value $Packs.role_aliases -Context "$SourceLabel role_aliases"
    foreach ($alias in $aliases) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $alias -Name "role_id" -Context "$SourceLabel role_aliases") -Context "$SourceLabel role_aliases role_id"
        if ($script:RequiredRoles -notcontains $roleId) {
            throw "$SourceLabel role alias points to unknown role '$roleId'."
        }
    }

    $rolePacks = Assert-ObjectArray -Value $Packs.role_packs -Context "$SourceLabel role_packs"
    $roleIds = @($rolePacks | ForEach-Object { [string]$_.role_id })
    foreach ($roleId in $roleIds) {
        if ($script:RequiredRoles -notcontains $roleId) {
            throw "$SourceLabel role_packs defines unknown role '$roleId'."
        }
    }
    Assert-ExactStringSet -Values $roleIds -ExpectedValues $script:RequiredRoles -Context "$SourceLabel role_packs role_id"
    for ($index = 0; $index -lt $rolePacks.Count; $index += 1) {
        Assert-RolePack -Pack $rolePacks[$index] -Model $Model -LayerMap $LayerMap -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel role_packs[$index]"
    }

    $nonClaims = Assert-StringArray -Value $Packs.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    Assert-PreservedBoundaries -Value $Packs.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $validationCommands = Assert-ObjectArray -Value $Packs.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidRules = Assert-ObjectArray -Value $Packs.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $statement = Assert-NonEmptyString -Value $Packs.generated_artifact_statement -Context "$SourceLabel generated_artifact_statement"
    if ($statement -notmatch 'committed state artifacts' -or $statement -notmatch 'not runtime memory' -or $statement -notmatch 'not actual agents' -or $statement -notmatch 'not workflow execution') {
        throw "$SourceLabel generated_artifact_statement must state state-artifact-only, not runtime memory, not actual agents, and not workflow execution."
    }

    return [pscustomobject]@{
        ArtifactId = $Packs.role_memory_packs_artifact_id
        SourceTask = $Packs.source_task
        RoleCount = $rolePacks.Count
        Roles = [string[]]$roleIds
        MemoryLayerTypes = [string[]]$script:RequiredLayerTypes
        ActiveThroughTask = $Packs.current_posture.active_through_task
        PlannedTaskStart = $Packs.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Packs.current_posture.planned_tasks[-1]
        GeneratedFromHead = $Packs.generated_from_head
        GeneratedFromTree = $Packs.generated_from_tree
        StateArtifactsOnly = [bool]$Packs.generation_mode.generated_baseline_role_memory_packs_are_state_artifacts
        RuntimeMemoryLoadingImplemented = [bool]$Packs.generation_mode.runtime_memory_loading_implemented
        ActualAutonomousAgentsImplemented = [bool]$Packs.generation_mode.actual_autonomous_agents_implemented
        WorkflowDrillsRun = [bool]$Packs.generation_mode.workflow_drills_run
    }
}

function Test-R16RoleMemoryPacks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$PacksPath,
        [Parameter(Mandatory = $true)][string]$ModelPath,
        [Parameter(Mandatory = $true)][string]$MemoryLayersPath,
        [string]$RepositoryRoot,
        [string]$ModelContractPath = "contracts\memory\r16_role_memory_pack_model.contract.json",
        [string]$MemoryLayerContractPath = "contracts\memory\r16_memory_layer.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $inputs = Get-RoleMemoryPackInputBundle -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -ModelContractPath $ModelContractPath -MemoryLayerContractPath $MemoryLayerContractPath -RepositoryRoot $resolvedRepositoryRoot
    $resolvedPacksPath = Assert-SafeRepoRelativePath -Path $PacksPath -RepositoryRoot $resolvedRepositoryRoot -Context "PacksPath" -RequireLeaf
    $packs = Read-SingleJsonObject -Path $resolvedPacksPath -Label "R16 role memory packs"

    return Test-R16RoleMemoryPacksObject -Packs $packs -Model $inputs.Model -MemoryLayers $inputs.MemoryLayers -LayerMap $inputs.LayerMap -RepositoryRoot $resolvedRepositoryRoot -SourceLabel $PacksPath
}

function New-R16RoleMemoryPacks {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state\memory\r16_role_memory_packs.json",
        [string]$ModelPath = "state\memory\r16_role_memory_pack_model.json",
        [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
        [string]$RepositoryRoot,
        [string]$ModelContractPath = "contracts\memory\r16_role_memory_pack_model.contract.json",
        [string]$MemoryLayerContractPath = "contracts\memory\r16_memory_layer.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutputPath = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -Context "OutputPath"
    $packs = New-R16RoleMemoryPackObject -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -ModelContractPath $ModelContractPath -MemoryLayerContractPath $MemoryLayerContractPath -RepositoryRoot $resolvedRepositoryRoot
    Write-StableJsonFile -Object $packs -Path $resolvedOutputPath
    $validation = Test-R16RoleMemoryPacks -PacksPath $OutputPath -ModelPath $ModelPath -MemoryLayersPath $MemoryLayersPath -ModelContractPath $ModelContractPath -MemoryLayerContractPath $MemoryLayerContractPath -RepositoryRoot $resolvedRepositoryRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        RoleCount = $validation.RoleCount
        Roles = $validation.Roles
        GeneratedFromHead = $validation.GeneratedFromHead
        GeneratedFromTree = $validation.GeneratedFromTree
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
    }
}

Export-ModuleMember -Function New-R16RoleMemoryPackObject, New-R16RoleMemoryPacks, Test-R16RoleMemoryPacks, Test-R16RoleMemoryPacksObject
