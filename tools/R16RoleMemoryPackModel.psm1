Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "role_memory_pack_model_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "model_mode",
    "dependency_refs",
    "role_catalog",
    "role_aliases",
    "allowed_roles",
    "role_pack_schema",
    "role_memory_layer_policy",
    "load_priority_schema",
    "ref_budget_schema",
    "stale_ref_policy",
    "proof_treatment_policy",
    "role_authority_policy",
    "forbidden_action_policy",
    "pack_generation_status",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules"
)

$script:ExpectedRoles = @(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:ExpectedLayerTypes = @(
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

$script:ExpectedAllowedLayerTypesByRole = [ordered]@{
    operator = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "evidence_memory",
        "knowledge_index_memory"
    )
    project_manager = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "run_session_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "historical_report_memory"
    )
    architect = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "historical_report_memory"
    )
    developer = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "run_session_memory",
        "evidence_memory",
        "knowledge_index_memory"
    )
    qa = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "run_session_memory",
        "evidence_memory",
        "knowledge_index_memory"
    )
    evidence_auditor = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "run_session_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "historical_report_memory"
    )
    knowledge_curator = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "historical_report_memory",
        "deprecated_cleanup_candidate_memory"
    )
    release_closeout_agent = @(
        "global_governance_memory",
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "run_session_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "historical_report_memory"
    )
}

$script:ExpectedRequiredLayerTypesByRole = [ordered]@{
    operator = @(
        "global_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "evidence_memory"
    )
    project_manager = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "evidence_memory"
    )
    architect = @(
        "product_governance_memory",
        "milestone_authority_memory",
        "role_identity_memory",
        "knowledge_index_memory"
    )
    developer = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "evidence_memory"
    )
    qa = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "task_card_memory",
        "evidence_memory"
    )
    evidence_auditor = @(
        "global_governance_memory",
        "milestone_authority_memory",
        "evidence_memory",
        "historical_report_memory"
    )
    knowledge_curator = @(
        "role_identity_memory",
        "evidence_memory",
        "knowledge_index_memory",
        "deprecated_cleanup_candidate_memory"
    )
    release_closeout_agent = @(
        "milestone_authority_memory",
        "role_identity_memory",
        "evidence_memory",
        "historical_report_memory"
    )
}

$script:ExpectedBudgetCategories = @(
    "operator_control_small",
    "pm_task_coordination_small",
    "architecture_context_medium",
    "implementation_task_small",
    "qa_evidence_small",
    "audit_evidence_medium",
    "knowledge_curation_medium",
    "release_closeout_medium"
)

$script:RequiredValidationCommands = @(
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
    "missing_role_rejected",
    "unknown_role_rejected",
    "alias_to_unknown_role_rejected",
    "missing_memory_layer_dependency_rejected",
    "unknown_memory_layer_type_rejected",
    "missing_required_layer_for_role_rejected",
    "missing_forbidden_actions_rejected",
    "non_deterministic_load_order_rejected",
    "broad_repo_scan_requested_rejected",
    "wildcard_source_ref_requested_rejected",
    "generated_role_memory_packs_claim_rejected",
    "role_memory_pack_generator_claim_rejected",
    "runtime_memory_loading_claim_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "external_integration_claim_rejected",
    "artifact_map_claim_rejected",
    "context_load_planner_claim_rejected",
    "r16_007_implementation_claim_rejected",
    "r16_027_or_later_task_rejected",
    "r13_closure_claim_rejected",
    "r14_caveat_removal_rejected",
    "r15_caveat_removal_rejected"
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
    "no R16-007 implementation",
    "no R16-027 or later task",
    "no generated baseline role memory packs",
    "no role memory pack generator",
    "no artifact map",
    "no audit map",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no handoff packet",
    "no workflow drill",
    "role-specific memory pack model does not equal runtime agents or runtime memory",
    "generated baseline memory layers remain committed state artifacts, not runtime memory"
)

$script:ModeFalseFields = @(
    "generated_baseline_role_memory_packs_generated",
    "generated_role_memory_packs_claimed",
    "role_memory_pack_generator_implemented",
    "role_memory_pack_generator_claimed",
    "artifact_maps_implemented",
    "audit_maps_implemented",
    "context_load_planner_implemented",
    "context_budget_estimator_implemented",
    "role_run_envelopes_implemented",
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
    "r16_007_or_later_implementation_claimed",
    "r16_027_or_later_task_exists"
)

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($Object -is [System.Collections.IDictionary]) {
        return $Object.Contains($Name)
    }

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

    if ($Object -is [System.Collections.IDictionary]) {
        $PSCmdlet.WriteObject($Object[$Name], $false)
        return
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

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace($item)) {
            throw "$Context must contain only non-empty strings."
        }
    }

    $PSCmdlet.WriteObject([string[]]$items, $false)
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
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context must contain only objects."
        }
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
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

function Test-BroadRepoRootPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-WildcardPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return $Path -match '[\*\?]'
}

function Assert-SafeRepoRelativeFilePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Context
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

    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }

    return $resolved
}

function Assert-FalseFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$Fields,
        [Parameter(Mandatory = $true)]
        [string]$Context
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
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
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
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $r13.partial_gates -Context "$Context r13 partial_gates") -RequiredValues @("API/custom-runner bypass", "current operator control room", "skill invocation evidence", "operator demo") -Context "$Context r13 partial_gates"

    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r14" -Context $Context) -Context "$Context r14"
    if ($r14.status -ne "accepted_with_caveats" -or $r14.through -ne "R14-006") {
        throw "$Context r14 must stay accepted_with_caveats through R14-006."
    }
    if ((Assert-BooleanValue -Value $r14.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r14.r13_partial_gates_converted_to_passed -Context "$Context r14 r13_partial_gates_converted_to_passed") -ne $false) {
        throw "$Context r14 r13_partial_gates_converted_to_passed must be False."
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

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $posture = Assert-ObjectValue -Value $Value -Context $Context
    if ($posture.active_through_task -ne "R16-006") {
        throw "$Context active_through_task must be R16-006."
    }

    $completeTasks = Assert-StringArray -Value $posture.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $posture.planned_tasks -Context "$Context planned_tasks"
    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in @($completeTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 7) {
            throw "$Context claims R16-007 or later implementation with '$taskId'."
        }
    }

    Assert-ExactStringSet -Values $completeTasks -ExpectedValues @("R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006") -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues @(7..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") }) -Context "$Context planned_tasks"
}

function Get-ExpectedForbiddenLayerTypes {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleId
    )

    $allowed = [string[]]$script:ExpectedAllowedLayerTypesByRole[$RoleId]
    return [string[]]@($script:ExpectedLayerTypes | Where-Object { $allowed -notcontains $_ })
}

function Get-KnownMemoryLayerMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MemoryLayersPath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $memoryLayers = Read-SingleJsonObject -Path $MemoryLayersPath -Label "R16 memory layers"
    if ($memoryLayers.artifact_type -ne "r16_memory_layers") {
        throw "R16 memory layers artifact_type must be r16_memory_layers."
    }

    $records = Assert-ObjectArray -Value (Get-RequiredProperty -Object $memoryLayers -Name "layer_records" -Context "R16 memory layers") -Context "R16 memory layers layer_records"
    $map = @{}
    foreach ($record in $records) {
        $layerType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $record -Name "layer_type" -Context "R16 memory layers layer_record") -Context "R16 memory layers layer_type"
        $layerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $record -Name "layer_id" -Context "R16 memory layers layer_record") -Context "R16 memory layers layer_id"
        if ($map.ContainsKey($layerType)) {
            throw "R16 memory layers contains duplicate layer_type '$layerType'."
        }
        $map[$layerType] = $layerId
    }

    Assert-ExactStringSet -Values ([string[]]$map.Keys) -ExpectedValues $script:ExpectedLayerTypes -Context "R16 memory layer dependency types"
    return $map
}

function Assert-DependencyRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $refs = Assert-ObjectArray -Value $Value -Context $Context
    $paths = @()
    foreach ($ref in $refs) {
        foreach ($field in @("ref_id", "ref_type", "path", "source_task", "proof_treatment", "exact_ref_required", "broad_scan_allowed", "wildcard_allowed")) {
            Get-RequiredProperty -Object $ref -Name $field -Context $Context | Out-Null
        }
        $path = Assert-NonEmptyString -Value $ref.path -Context "$Context path"
        Assert-SafeRepoRelativeFilePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context path" | Out-Null
        if ((Assert-BooleanValue -Value $ref.exact_ref_required -Context "$Context exact_ref_required") -ne $true) {
            throw "$Context exact_ref_required must be True."
        }
        if ((Assert-BooleanValue -Value $ref.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
            throw "$Context broad repo scan requested through broad_scan_allowed."
        }
        if ((Assert-BooleanValue -Value $ref.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
            throw "$Context wildcard source ref requested through wildcard_allowed."
        }
        $paths += $path.Trim().Replace("\", "/")
    }

    if ($paths -notcontains "state/memory/r16_memory_layers.json") {
        throw "$Context is missing memory layer dependency 'state/memory/r16_memory_layers.json'."
    }
}

function Assert-RoleAliases {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $aliases = Assert-ObjectArray -Value $Value -Context $Context
    $seenAliases = @{}
    foreach ($alias in $aliases) {
        $aliasValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $alias -Name "alias" -Context $Context) -Context "$Context alias"
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $alias -Name "role_id" -Context $Context) -Context "$Context role_id"
        if ($script:ExpectedRoles -notcontains $roleId) {
            throw "$Context alias '$aliasValue' points to unknown role '$roleId'."
        }
        $aliasKey = $aliasValue.ToLowerInvariant()
        if ($seenAliases.ContainsKey($aliasKey)) {
            throw "$Context duplicate alias '$aliasValue'."
        }
        $seenAliases[$aliasKey] = $true
    }
}

function Assert-RoleCatalog {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $roles = Assert-ObjectArray -Value $Value -Context $Context
    $roleIds = @()
    foreach ($role in $roles) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $role -Name "role_id" -Context $Context) -Context "$Context role_id"
        if ($script:ExpectedRoles -notcontains $roleId) {
            throw "$Context defines unknown role '$roleId'."
        }
        foreach ($field in @("display_name", "purpose", "role_kind")) {
            Assert-NonEmptyString -Value (Get-RequiredProperty -Object $role -Name $field -Context "$Context $roleId") -Context "$Context $roleId $field" | Out-Null
        }
        $roleIds += $roleId
    }
    Assert-ExactStringSet -Values $roleIds -ExpectedValues $script:ExpectedRoles -Context $Context
}

function Assert-RefBudget {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $budget = Assert-ObjectValue -Value $Value -Context $Context
    $category = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $budget -Name "budget_category" -Context $Context) -Context "$Context budget_category"
    if ($script:ExpectedBudgetCategories -notcontains $category) {
        throw "$Context budget_category '$category' is not an allowed budget category."
    }
    $maxRefs = Assert-IntegerValue -Value (Get-RequiredProperty -Object $budget -Name "max_refs" -Context $Context) -Context "$Context max_refs"
    if ($maxRefs -lt 1 -or $maxRefs -gt 24) {
        throw "$Context max_refs must be a bounded positive integer not greater than 24."
    }
    foreach ($falseField in @("provider_billing_claim", "exact_provider_token_claim")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $budget -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context budgets are categories/limits only, not provider billing claims: $falseField must be False."
        }
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $budget -Name "limits_are_categories_only" -Context $Context) -Context "$Context limits_are_categories_only") -ne $true) {
        throw "$Context limits_are_categories_only must be True."
    }
}

function Assert-SourceRefTreatment {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $treatment = Assert-ObjectValue -Value $Value -Context $Context
    foreach ($trueField in @("exact_repo_relative_paths_required", "source_refs_must_resolve_to_dependency_refs", "stale_refs_fail_closed_without_caveat")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $treatment -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "wildcard_source_refs_allowed", "runtime_retrieval_allowed", "vector_search_runtime_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $treatment -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context broad repo scan, wildcard, retrieval, and vector runtime source-ref requests must be False: $falseField."
        }
    }
}

function Assert-LoadPriority {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedLayerTypes,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $items = Assert-ObjectArray -Value $Value -Context $Context
    $seenOrders = @{}
    $layerTypes = @()
    foreach ($item in $items) {
        $order = Assert-IntegerValue -Value (Get-RequiredProperty -Object $item -Name "order" -Context $Context) -Context "$Context order"
        $layerType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "layer_type" -Context $Context) -Context "$Context layer_type"
        if ($seenOrders.ContainsKey($order)) {
            throw "$Context non-deterministic load order: duplicate order '$order'."
        }
        $seenOrders[$order] = $true
        $layerTypes += $layerType
    }
    for ($order = 1; $order -le $items.Count; $order += 1) {
        if (-not $seenOrders.ContainsKey($order)) {
            throw "$Context non-deterministic load order: missing order '$order'."
        }
    }
    Assert-ExactStringSet -Values $layerTypes -ExpectedValues $ExpectedLayerTypes -Context "$Context layer_type"
}

function Assert-MemoryLayerDependencies {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedLayerTypes,
        [Parameter(Mandatory = $true)]
        [hashtable]$KnownMemoryLayerMap,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $dependencies = Assert-ObjectArray -Value $Value -Context $Context
    $layerTypes = @()
    foreach ($dependency in $dependencies) {
        foreach ($field in @("layer_type", "layer_id", "source_artifact", "exact_ref_required", "broad_scan_allowed", "wildcard_allowed")) {
            Get-RequiredProperty -Object $dependency -Name $field -Context $Context | Out-Null
        }
        $layerType = Assert-NonEmptyString -Value $dependency.layer_type -Context "$Context layer_type"
        if (-not $KnownMemoryLayerMap.ContainsKey($layerType)) {
            throw "$Context references unknown memory layer type '$layerType'."
        }
        if ($ExpectedLayerTypes -notcontains $layerType) {
            throw "$Context references memory layer type '$layerType' outside this role policy."
        }
        if ($dependency.layer_id -ne $KnownMemoryLayerMap[$layerType]) {
            throw "$Context layer_id for '$layerType' must match state/memory/r16_memory_layers.json."
        }
        if ($dependency.source_artifact -ne "state/memory/r16_memory_layers.json") {
            throw "$Context memory layer dependency must use exact source artifact state/memory/r16_memory_layers.json."
        }
        if ((Assert-BooleanValue -Value $dependency.exact_ref_required -Context "$Context exact_ref_required") -ne $true) {
            throw "$Context exact_ref_required must be True."
        }
        if ((Assert-BooleanValue -Value $dependency.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
            throw "$Context broad repo scan requested by memory layer dependency."
        }
        if ((Assert-BooleanValue -Value $dependency.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
            throw "$Context wildcard source ref requested by memory layer dependency."
        }
        $layerTypes += $layerType
    }
    Assert-ExactStringSet -Values $layerTypes -ExpectedValues $ExpectedLayerTypes -Context "$Context layer_type"
}

function Assert-RoleMemoryLayerPolicy {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [hashtable]$KnownMemoryLayerMap,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $policies = Assert-ObjectArray -Value $Value -Context $Context
    $policyRoleIds = @()
    foreach ($policy in $policies) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $policy -Name "role_id" -Context $Context) -Context "$Context role_id"
        if ($script:ExpectedRoles -notcontains $roleId) {
            throw "$Context defines unknown role '$roleId'."
        }
        $expectedAllowed = [string[]]$script:ExpectedAllowedLayerTypesByRole[$roleId]
        $expectedRequired = [string[]]$script:ExpectedRequiredLayerTypesByRole[$roleId]
        $expectedForbidden = Get-ExpectedForbiddenLayerTypes -RoleId $roleId

        $allowed = Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "allowed_memory_layer_types" -Context "$Context $roleId") -Context "$Context $roleId allowed_memory_layer_types"
        $required = Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "required_memory_layer_types" -Context "$Context $roleId") -Context "$Context $roleId required_memory_layer_types"
        $forbidden = Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "forbidden_memory_layer_types" -Context "$Context $roleId") -Context "$Context $roleId forbidden_memory_layer_types" -AllowEmpty

        Assert-ExactStringSet -Values $allowed -ExpectedValues $expectedAllowed -Context "$Context $roleId allowed_memory_layer_types"
        Assert-ExactStringSet -Values $required -ExpectedValues $expectedRequired -Context "$Context $roleId required_memory_layer_types"
        Assert-ExactStringSet -Values $forbidden -ExpectedValues $expectedForbidden -Context "$Context $roleId forbidden_memory_layer_types"

        foreach ($layerType in @($allowed + $required + $forbidden)) {
            if ($script:ExpectedLayerTypes -notcontains $layerType) {
                throw "$Context $roleId references unknown memory layer type '$layerType'."
            }
            if (-not $KnownMemoryLayerMap.ContainsKey($layerType)) {
                throw "$Context $roleId memory layer type '$layerType' is missing from state/memory/r16_memory_layers.json."
            }
        }
        foreach ($requiredLayer in $expectedRequired) {
            if ($required -notcontains $requiredLayer) {
                throw "$Context $roleId is missing required layer '$requiredLayer'."
            }
            if ($allowed -notcontains $requiredLayer) {
                throw "$Context $roleId required layer '$requiredLayer' must also be allowed."
            }
        }

        Assert-SourceRefTreatment -Value (Get-RequiredProperty -Object $policy -Name "source_ref_treatment" -Context "$Context $roleId") -Context "$Context $roleId source_ref_treatment"
        Assert-LoadPriority -Value (Get-RequiredProperty -Object $policy -Name "load_priority" -Context "$Context $roleId") -ExpectedLayerTypes $allowed -Context "$Context $roleId load_priority"
        Assert-RefBudget -Value (Get-RequiredProperty -Object $policy -Name "ref_budget" -Context "$Context $roleId") -Context "$Context $roleId ref_budget"
        Assert-MemoryLayerDependencies -Value (Get-RequiredProperty -Object $policy -Name "memory_layer_dependencies" -Context "$Context $roleId") -ExpectedLayerTypes $allowed -KnownMemoryLayerMap $KnownMemoryLayerMap -Context "$Context $roleId memory_layer_dependencies"

        $staleHandling = Assert-ObjectValue -Value (Get-RequiredProperty -Object $policy -Name "stale_ref_handling" -Context "$Context $roleId") -Context "$Context $roleId stale_ref_handling"
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $staleHandling -Name "stale_refs_fail_closed_without_caveat" -Context "$Context $roleId stale_ref_handling") -Context "$Context $roleId stale_ref_handling stale_refs_fail_closed_without_caveat") -ne $true) {
            throw "$Context $roleId stale refs must fail closed without caveat."
        }
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $staleHandling -Name "stale_refs_accepted_without_caveat" -Context "$Context $roleId stale_ref_handling") -Context "$Context $roleId stale_ref_handling stale_refs_accepted_without_caveat") -ne $false) {
            throw "$Context $roleId stale refs accepted without caveat must be False."
        }

        $proofTreatment = Assert-ObjectValue -Value (Get-RequiredProperty -Object $policy -Name "proof_treatment" -Context "$Context $roleId") -Context "$Context $roleId proof_treatment"
        foreach ($falseField in @("planning_reports_as_implementation_proof", "generated_reports_as_machine_proof", "role_pack_model_as_runtime_proof")) {
            if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $proofTreatment -Name $falseField -Context "$Context $roleId proof_treatment") -Context "$Context $roleId proof_treatment $falseField") -ne $false) {
                throw "$Context $roleId proof treatment $falseField must be False."
            }
        }

        $policyRoleIds += $roleId
    }
    Assert-ExactStringSet -Values $policyRoleIds -ExpectedValues $script:ExpectedRoles -Context $Context
}

function Assert-RoleAuthorityPolicy {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $policies = Assert-ObjectArray -Value $Value -Context $Context
    $roleIds = @()
    foreach ($policy in $policies) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $policy -Name "role_id" -Context $Context) -Context "$Context role_id"
        if ($script:ExpectedRoles -notcontains $roleId) {
            throw "$Context defines unknown role '$roleId'."
        }
        Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "authority_boundaries" -Context "$Context $roleId") -Context "$Context $roleId authority_boundaries" | Out-Null
        Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "may_decide" -Context "$Context $roleId") -Context "$Context $roleId may_decide" -AllowEmpty | Out-Null
        Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "must_not_decide" -Context "$Context $roleId") -Context "$Context $roleId must_not_decide" | Out-Null
        $roleIds += $roleId
    }
    Assert-ExactStringSet -Values $roleIds -ExpectedValues $script:ExpectedRoles -Context $Context
}

function Assert-ForbiddenActionPolicy {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $container = Assert-ObjectValue -Value $Value -Context $Context
    Assert-StringArray -Value (Get-RequiredProperty -Object $container -Name "global_forbidden_actions" -Context $Context) -Context "$Context global_forbidden_actions" | Out-Null
    $perRole = Assert-ObjectArray -Value (Get-RequiredProperty -Object $container -Name "per_role" -Context $Context) -Context "$Context per_role"
    $roleIds = @()
    foreach ($policy in $perRole) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $policy -Name "role_id" -Context "$Context per_role") -Context "$Context per_role role_id"
        if ($script:ExpectedRoles -notcontains $roleId) {
            throw "$Context defines unknown role '$roleId'."
        }
        Assert-StringArray -Value (Get-RequiredProperty -Object $policy -Name "forbidden_actions" -Context "$Context $roleId") -Context "$Context $roleId forbidden_actions" | Out-Null
        $roleIds += $roleId
    }
    Assert-ExactStringSet -Values $roleIds -ExpectedValues $script:ExpectedRoles -Context "$Context per_role"
}

function Assert-ModeAndGenerationStatus {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $mode = Assert-ObjectValue -Value $Document.model_mode -Context "$Context model_mode"
    if ($mode.mode -ne "role_specific_memory_pack_model_only_not_generated_packs") {
        throw "$Context model_mode mode must be role_specific_memory_pack_model_only_not_generated_packs."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "role_specific_memory_pack_model_defined" -Context "$Context model_mode") -Context "$Context model_mode role_specific_memory_pack_model_defined") -ne $true) {
        throw "$Context model_mode role_specific_memory_pack_model_defined must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "model_only" -Context "$Context model_mode") -Context "$Context model_mode model_only") -ne $true) {
        throw "$Context model_mode model_only must be True."
    }
    Assert-FalseFields -Object $mode -Fields $script:ModeFalseFields -Context "$Context model_mode"

    $status = Assert-ObjectValue -Value $Document.pack_generation_status -Context "$Context pack_generation_status"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $status -Name "role_specific_memory_pack_model_defined" -Context "$Context pack_generation_status") -Context "$Context pack_generation_status role_specific_memory_pack_model_defined") -ne $true) {
        throw "$Context pack_generation_status role_specific_memory_pack_model_defined must be True."
    }
    Assert-FalseFields -Object $status -Fields @(
        "generated_baseline_role_memory_packs_exist",
        "generated_role_memory_packs_claimed",
        "role_memory_pack_generator_exists",
        "role_memory_pack_generator_claimed",
        "runtime_memory_loading_claimed",
        "persistent_memory_runtime_claimed",
        "retrieval_runtime_claimed",
        "vector_search_runtime_claimed",
        "actual_autonomous_agents_claimed",
        "true_multi_agent_execution_claimed",
        "external_integrations_claimed",
        "artifact_maps_claimed",
        "context_load_planner_claimed",
        "r16_007_or_later_implementation_claimed",
        "r16_027_or_later_task_exists"
    ) -Context "$Context pack_generation_status"
    Assert-CurrentPosture -Value (Get-RequiredProperty -Object $status -Name "current_posture" -Context "$Context pack_generation_status") -Context "$Context pack_generation_status current_posture"
}

function Assert-SchemasAndPolicies {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $rolePackSchema = Assert-ObjectValue -Value $Document.role_pack_schema -Context "$Context role_pack_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value (Get-RequiredProperty -Object $rolePackSchema -Name "required_top_level_fields" -Context "$Context role_pack_schema") -Context "$Context role_pack_schema required_top_level_fields") -RequiredValues $script:RequiredTopLevelFields -Context "$Context role_pack_schema required_top_level_fields"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $rolePackSchema -Name "model_only_not_generated_pack" -Context "$Context role_pack_schema") -Context "$Context role_pack_schema model_only_not_generated_pack") -ne $true) {
        throw "$Context role_pack_schema model_only_not_generated_pack must be True."
    }

    $loadSchema = Assert-ObjectValue -Value $Document.load_priority_schema -Context "$Context load_priority_schema"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $loadSchema -Name "deterministic_order_required" -Context "$Context load_priority_schema") -Context "$Context load_priority_schema deterministic_order_required") -ne $true) {
        throw "$Context load_priority_schema deterministic_order_required must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $loadSchema -Name "ties_allowed" -Context "$Context load_priority_schema") -Context "$Context load_priority_schema ties_allowed") -ne $false) {
        throw "$Context load_priority_schema ties_allowed must be False."
    }

    $budgetSchema = Assert-ObjectValue -Value $Document.ref_budget_schema -Context "$Context ref_budget_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value (Get-RequiredProperty -Object $budgetSchema -Name "allowed_budget_categories" -Context "$Context ref_budget_schema") -Context "$Context ref_budget_schema allowed_budget_categories") -RequiredValues $script:ExpectedBudgetCategories -Context "$Context ref_budget_schema allowed_budget_categories"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $budgetSchema -Name "budget_values_are_categories_not_provider_billing" -Context "$Context ref_budget_schema") -Context "$Context ref_budget_schema budget_values_are_categories_not_provider_billing") -ne $true) {
        throw "$Context ref_budget_schema must state that budget values are categories, not provider billing claims."
    }

    $stalePolicy = Assert-ObjectValue -Value $Document.stale_ref_policy -Context "$Context stale_ref_policy"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $stalePolicy -Name "stale_ref_requires_caveat" -Context "$Context stale_ref_policy") -Context "$Context stale_ref_policy stale_ref_requires_caveat") -ne $true) {
        throw "$Context stale_ref_policy stale_ref_requires_caveat must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $stalePolicy -Name "stale_ref_accepted_without_caveat" -Context "$Context stale_ref_policy") -Context "$Context stale_ref_policy stale_ref_accepted_without_caveat") -ne $false) {
        throw "$Context stale_ref_policy stale_ref_accepted_without_caveat must be False."
    }

    $proofPolicy = Assert-ObjectValue -Value $Document.proof_treatment_policy -Context "$Context proof_treatment_policy"
    foreach ($falseField in @("role_memory_pack_model_is_runtime_proof", "planning_reports_are_implementation_proof", "generated_reports_are_machine_proof")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $proofPolicy -Name $falseField -Context "$Context proof_treatment_policy") -Context "$Context proof_treatment_policy $falseField") -ne $false) {
            throw "$Context proof_treatment_policy $falseField must be False."
        }
    }
}

function Test-R16RoleMemoryPackModelObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [hashtable]$KnownMemoryLayerMap,
        [string]$SourceLabel = "R16 role memory pack model",
        [string]$RepositoryRoot = $repoRoot,
        [string[]]$AllowedArtifactTypes = @("r16_role_memory_pack_model", "r16_role_memory_pack_model_contract")
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Document -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Document.artifact_type -notin $AllowedArtifactTypes) {
        throw "$SourceLabel artifact_type '$($Document.artifact_type)' is not allowed."
    }
    if ($Document.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Document.source_milestone -ne "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation") {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Document.source_task -ne "R16-006") {
        throw "$SourceLabel source_task must be R16-006."
    }
    if ($Document.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Document.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be release/r16-operational-memory-artifact-map-role-workflow-foundation."
    }
    Assert-NonEmptyString -Value $Document.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Document.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-ModeAndGenerationStatus -Document $Document -Context $SourceLabel
    Assert-DependencyRefs -Value $Document.dependency_refs -Context "$SourceLabel dependency_refs" -RepositoryRoot $RepositoryRoot
    Assert-RoleCatalog -Value $Document.role_catalog -Context "$SourceLabel role_catalog"
    Assert-RoleAliases -Value $Document.role_aliases -Context "$SourceLabel role_aliases"
    Assert-ExactStringSet -Values (Assert-StringArray -Value $Document.allowed_roles -Context "$SourceLabel allowed_roles") -ExpectedValues $script:ExpectedRoles -Context "$SourceLabel allowed_roles"
    Assert-SchemasAndPolicies -Document $Document -Context $SourceLabel
    Assert-RoleMemoryLayerPolicy -Value $Document.role_memory_layer_policy -KnownMemoryLayerMap $KnownMemoryLayerMap -Context "$SourceLabel role_memory_layer_policy"
    Assert-RoleAuthorityPolicy -Value $Document.role_authority_policy -Context "$SourceLabel role_authority_policy"
    Assert-ForbiddenActionPolicy -Value $Document.forbidden_action_policy -Context "$SourceLabel forbidden_action_policy"

    $nonClaims = Assert-StringArray -Value $Document.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    Assert-PreservedBoundaries -Value $Document.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $validationCommands = Assert-ObjectArray -Value $Document.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidStateRules = Assert-ObjectArray -Value $Document.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    return [pscustomobject]@{
        ArtifactType = $Document.artifact_type
        ContractId = $Document.role_memory_pack_model_contract_id
        SourceTask = $Document.source_task
        RoleCount = $script:ExpectedRoles.Count
        Roles = [string[]]$script:ExpectedRoles
        KnownMemoryLayerTypes = [string[]]$KnownMemoryLayerMap.Keys
        ActiveThroughTask = $Document.pack_generation_status.current_posture.active_through_task
        PlannedTaskStart = $Document.pack_generation_status.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Document.pack_generation_status.current_posture.planned_tasks[-1]
        RolePackModelDefined = [bool]$Document.model_mode.role_specific_memory_pack_model_defined
        GeneratedBaselineRoleMemoryPacksExist = [bool]$Document.pack_generation_status.generated_baseline_role_memory_packs_exist
        RoleMemoryPackGeneratorExists = [bool]$Document.pack_generation_status.role_memory_pack_generator_exists
        RuntimeMemoryLoadingClaimed = [bool]$Document.pack_generation_status.runtime_memory_loading_claimed
    }
}

function Test-R16RoleMemoryPackModelContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [Parameter(Mandatory = $true)]
        [string]$MemoryLayersPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $knownMemoryLayerMap = Get-KnownMemoryLayerMap -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot
    $contract = Read-SingleJsonObject -Path $ContractPath -Label "R16 role memory pack model contract"
    return Test-R16RoleMemoryPackModelObject -Document $contract -KnownMemoryLayerMap $knownMemoryLayerMap -SourceLabel $ContractPath -RepositoryRoot $RepositoryRoot -AllowedArtifactTypes @("r16_role_memory_pack_model_contract")
}

function Test-R16RoleMemoryPackModel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModelPath,
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [Parameter(Mandatory = $true)]
        [string]$MemoryLayersPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $knownMemoryLayerMap = Get-KnownMemoryLayerMap -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $RepositoryRoot
    $contract = Read-SingleJsonObject -Path $ContractPath -Label "R16 role memory pack model contract"
    Test-R16RoleMemoryPackModelObject -Document $contract -KnownMemoryLayerMap $knownMemoryLayerMap -SourceLabel $ContractPath -RepositoryRoot $RepositoryRoot -AllowedArtifactTypes @("r16_role_memory_pack_model_contract") | Out-Null

    $model = Read-SingleJsonObject -Path $ModelPath -Label "R16 role memory pack model"
    $result = Test-R16RoleMemoryPackModelObject -Document $model -KnownMemoryLayerMap $knownMemoryLayerMap -SourceLabel $ModelPath -RepositoryRoot $RepositoryRoot -AllowedArtifactTypes @("r16_role_memory_pack_model")
    if ($model.role_memory_pack_model_contract_id -ne $contract.role_memory_pack_model_contract_id) {
        throw "$ModelPath role_memory_pack_model_contract_id must match $ContractPath."
    }

    return $result
}

Export-ModuleMember -Function Test-R16RoleMemoryPackModel, Test-R16RoleMemoryPackModelContract, Test-R16RoleMemoryPackModelObject
