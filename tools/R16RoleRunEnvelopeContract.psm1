Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:BaselineHead = "9d7a9c1409b1d7cfa77f902d073ab1e5ba99581a"
$script:ContractId = "aioffice-r16-018-role-run-envelope-contract-v1"
$script:CurrentGuardVerdict = "failed_closed_over_budget"
$script:CurrentEstimatedUpperBound = 1323518
$script:MaxEstimatedUpperBound = 150000

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "role_run_envelope_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "dependency_refs",
    "role_catalog",
    "role_alias_policy",
    "required_envelope_fields",
    "allowed_action_model",
    "forbidden_action_model",
    "required_input_refs",
    "context_budget_guard_policy",
    "no_full_repo_scan_policy",
    "evidence_ref_policy",
    "handoff_boundary_policy",
    "current_posture",
    "preserved_boundaries",
    "non_claims",
    "invalid_state_policy"
)

$script:RequiredDependencyPaths = @(
    "state/memory/r16_role_memory_packs.json",
    "state/memory/r16_role_memory_pack_model.json",
    "state/context/r16_context_load_plan.json",
    "state/context/r16_context_budget_estimate.json",
    "state/context/r16_context_budget_guard_report.json",
    "contracts/context/r16_context_budget_guard.contract.json",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
)

$script:RequiredRoleIds = @(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:RequiredRoleFields = @(
    "role_id",
    "role_display_name",
    "authority_boundary",
    "allowed_action_categories",
    "forbidden_action_categories",
    "required_input_ref_types",
    "deterministic_order"
)

$script:MinimumEnvelopeFields = @(
    "envelope_id",
    "role_id",
    "role_display_name",
    "source_task",
    "target_task_or_card_ref",
    "allowed_actions",
    "forbidden_actions",
    "required_inputs",
    "memory_pack_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "budget_guard_status",
    "no_full_repo_scan_attestation",
    "evidence_refs",
    "output_expectations",
    "handoff_constraints",
    "non_claims"
)

$script:AdditionalEnvelopeFields = @(
    "envelope_execution_status",
    "executable",
    "blocked_reason",
    "deterministic_order"
)

$script:RequiredInputFields = @(
    "memory_pack_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "evidence_refs"
)

$script:RequiredActionFields = @(
    "action_id",
    "action_type",
    "action_summary",
    "allowed_scope",
    "dependency_ref_ids",
    "evidence_required",
    "deterministic_order"
)

$script:RequiredForbiddenActions = @(
    "broad_repo_scan",
    "full_repo_scan",
    "wildcard_context_load",
    "directory_only_context_ref",
    "scratch_or_temp_ref",
    "absolute_path_ref",
    "parent_traversal_ref",
    "url_or_remote_ref",
    "raw_chat_history_load",
    "report_as_machine_proof",
    "exact_provider_tokenization_claim",
    "exact_provider_billing_claim",
    "runtime_memory_load",
    "retrieval_runtime",
    "vector_search_runtime",
    "product_runtime",
    "autonomous_agent_execution",
    "external_integration_execution",
    "raci_transition_gate_execution",
    "handoff_packet_generation",
    "workflow_drill_execution",
    "r16_019_or_later_execution",
    "r16_027_or_later_task",
    "r13_closure",
    "r14_caveat_removal",
    "r15_caveat_removal"
)

$script:RequiredNonClaims = @(
    "R16-018 defines the role-run envelope contract only",
    "no generated role-run envelopes",
    "no role-run envelope generator",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R16-019 through R16-026 remain planned only",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved"
)

$script:ForbiddenTrueBooleanClaims = @{
    "broad_repo_scan_allowed" = "broad repo scan allowed"
    "broad_repo_root_refs_allowed" = "broad repo scan allowed"
    "full_repo_scan_allowed" = "full repo scan allowed"
    "wildcard_paths_allowed" = "wildcard path allowed"
    "wildcard_path_allowed" = "wildcard path allowed"
    "directory_only_refs_allowed" = "directory-only ref allowed"
    "directory_only_paths_allowed" = "directory-only ref allowed"
    "scratch_temp_paths_allowed" = "scratch/temp path allowed"
    "absolute_paths_allowed" = "absolute path allowed"
    "parent_traversal_allowed" = "parent traversal allowed"
    "url_or_remote_refs_allowed" = "URL or remote ref allowed"
    "raw_chat_history_loading_allowed" = "raw chat history loading allowed"
    "report_as_machine_proof_allowed" = "report-as-machine-proof misuse"
    "exact_provider_tokenization_claimed" = "exact provider tokenization claim"
    "exact_provider_tokenization_claims_allowed" = "exact provider tokenization claim"
    "exact_provider_token_count_claimed" = "exact provider tokenization claim"
    "exact_provider_billing_claimed" = "exact provider billing claim"
    "exact_provider_billing_claims_allowed" = "exact provider billing claim"
    "provider_billing_claimed" = "exact provider billing claim"
    "runtime_memory_claimed" = "runtime memory claim"
    "runtime_memory_implemented" = "runtime memory claim"
    "runtime_memory_loading_implemented" = "runtime memory claim"
    "retrieval_runtime_claimed" = "retrieval runtime claim"
    "retrieval_runtime_implemented" = "retrieval runtime claim"
    "vector_search_runtime_claimed" = "vector search runtime claim"
    "vector_search_runtime_implemented" = "vector search runtime claim"
    "product_runtime_claimed" = "product runtime claim"
    "product_runtime_implemented" = "product runtime claim"
    "autonomous_agent_claimed" = "autonomous agent claim"
    "autonomous_agents_implemented" = "autonomous agent claim"
    "actual_autonomous_agents_implemented" = "autonomous agent claim"
    "external_integration_claimed" = "external integration claim"
    "external_integrations_implemented" = "external integration claim"
    "raci_transition_gate_implemented" = "RACI transition gate implementation claim"
    "raci_transition_gate_claimed" = "RACI transition gate implementation claim"
    "handoff_packet_implemented" = "handoff packet implementation claim"
    "handoff_packet_claimed" = "handoff packet implementation claim"
    "workflow_drill_run" = "workflow drill claim"
    "workflow_drill_implemented" = "workflow drill claim"
    "r16_019_implementation_claimed" = "R16-019 implementation claim"
    "r16_019_or_later_implementation_claimed" = "R16-019 implementation claim"
    "r16_027_or_later_task_exists" = "R16-027 or later task claim"
    "r13_closed" = "R13 closure claim"
    "r13_closure_claimed" = "R13 closure claim"
    "r13_partial_gate_conversion_claimed" = "R13 partial-gate conversion claim"
    "partial_gates_converted_to_passed" = "R13 partial-gate conversion claim"
    "r14_caveat_removal_claimed" = "R14 caveat removal"
    "r14_caveats_removed" = "R14 caveat removal"
    "r15_caveat_removal_claimed" = "R15 caveat removal"
    "r15_caveats_removed" = "R15 caveat removal"
    "solved_codex_compaction" = "solved Codex compaction claim"
    "solved_codex_reliability" = "solved Codex reliability claim"
}

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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-RequiredStringsPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $Required) {
        if ($Actual -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $actualSorted = @($Actual | Sort-Object)
    $expectedSorted = @($Expected | Sort-Object)
    if ($actualSorted.Count -ne $expectedSorted.Count) {
        throw "$Context must contain exactly: $($expectedSorted -join ', ')."
    }

    for ($itemIndex = 0; $itemIndex -lt $expectedSorted.Count; $itemIndex += 1) {
        if ($actualSorted[$itemIndex] -ne $expectedSorted[$itemIndex]) {
            throw "$Context must contain exactly: $($expectedSorted -join ', ')."
        }
    }
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

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/")
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalizedPath = (ConvertTo-NormalizedRepoPath -Path $Path).ToLowerInvariant()
    return [string]::IsNullOrWhiteSpace($normalizedPath) -or $normalizedPath -in @(
        ".",
        "./",
        "/",
        "\",
        "repo",
        "repository",
        "full_repo",
        "entire_repo",
        "all",
        "all_files",
        "**",
        "**/*"
    )
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?\[\]]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalizedPath = (ConvertTo-NormalizedRepoPath -Path $Path).ToLowerInvariant()
    return $normalizedPath -match '^(\.tmp|\.temp|scratch|tmp|temp|state/temp|state/tmp|state/scratch)(/|$)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalizedPath = ConvertTo-NormalizedRepoPath -Path $Path
    return $normalizedPath -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
        $normalizedPath -match '^git@' -or
        $normalizedPath -match '^(origin|upstream|refs)/' -or
        $normalizedPath -match '^[A-Za-z0-9_.-]+:'
}

function Test-DirectoryOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalizedPath = ConvertTo-NormalizedRepoPath -Path $Path
    if ($normalizedPath.EndsWith("/")) {
        return $true
    }
    if ([System.IO.Path]::IsPathRooted($normalizedPath) -or $normalizedPath -match '(^|/)\.\.(/|$)' -or (Test-RemoteOrUrlRef -Path $normalizedPath)) {
        return $false
    }

    return (Test-Path -LiteralPath (Join-Path $RepositoryRoot $normalizedPath) -PathType Container)
}

function Test-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalizedPath = ConvertTo-NormalizedRepoPath -Path $Path
    $null = & git -C $RepositoryRoot ls-files --error-unmatch -- $normalizedPath 2>$null
    return $LASTEXITCODE -eq 0
}

function Assert-SafeRepoRelativeTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $normalizedPath = ConvertTo-NormalizedRepoPath -Path $Path
    if (Test-BroadRepoRootPath -Path $normalizedPath) {
        throw "$Context rejects broad repo root ref '$Path'."
    }
    if (Test-WildcardPath -Path $normalizedPath) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
        throw "$Context rejects absolute path '$Path'."
    }
    if ($normalizedPath -match '(^|/)\.\.(/|$)') {
        throw "$Context rejects parent traversal path '$Path'."
    }
    if (Test-RemoteOrUrlRef -Path $normalizedPath) {
        throw "$Context rejects URL or remote ref '$Path'."
    }
    if (Test-ScratchTempPath -Path $normalizedPath) {
        throw "$Context rejects scratch/temp path '$Path'."
    }
    if (Test-DirectoryOnlyPath -Path $normalizedPath -RepositoryRoot $RepositoryRoot) {
        throw "$Context rejects directory-only ref '$Path'."
    }

    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalizedPath))
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context required path '$Path' does not exist as an exact file."
    }
    if (-not (Test-GitTrackedPath -Path $normalizedPath -RepositoryRoot $RepositoryRoot)) {
        throw "$Context required path '$Path' is not git-tracked."
    }
}

function Assert-FalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequirePresent
    )

    foreach ($fieldName in $Fields) {
        if (-not (Test-HasProperty -Object $Object -Name $fieldName)) {
            if ($RequirePresent) {
                throw "$Context is missing required field '$fieldName'."
            }
            continue
        }

        $fieldValue = Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context
        if ((Assert-BooleanValue -Value $fieldValue -Context "$Context $fieldName") -ne $false) {
            throw "$Context $fieldName must be False."
        }
    }
}

function Assert-TrueFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequirePresent
    )

    foreach ($fieldName in $Fields) {
        if (-not (Test-HasProperty -Object $Object -Name $fieldName)) {
            if ($RequirePresent) {
                throw "$Context is missing required field '$fieldName'."
            }
            continue
        }

        $fieldValue = Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context
        if ((Assert-BooleanValue -Value $fieldValue -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }
}

function Assert-NoForbiddenTrueClaims {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string]) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($key) -and $Value[$key] -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$key]) via '$key'."
            }
            Assert-NoForbiddenTrueClaims -Value $Value[$key] -Context "$Context.$key"
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $arrayIndex = 0
        foreach ($item in $Value) {
            Assert-NoForbiddenTrueClaims -Value $item -Context "$Context[$arrayIndex]"
            $arrayIndex += 1
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($property.Name) -and $property.Value -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$property.Name]) via '$($property.Name)'."
            }
            Assert-NoForbiddenTrueClaims -Value $property.Value -Context "$Context.$($property.Name)"
        }
    }
}

function Assert-DependencyRefs {
    param(
        [Parameter(Mandatory = $true)]$DependencyRefs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $refs = Assert-ObjectArray -Value $DependencyRefs -Context $Context
    $paths = New-Object System.Collections.Generic.List[string]
    for ($refIndex = 0; $refIndex -lt $refs.Count; $refIndex += 1) {
        $ref = Assert-ObjectValue -Value $refs[$refIndex] -Context "$Context[$refIndex]"
        foreach ($fieldName in @("ref_id", "path", "source_task", "proof_treatment", "deterministic_order")) {
            Get-RequiredProperty -Object $ref -Name $fieldName -Context "$Context[$refIndex]" | Out-Null
        }
        Assert-NonEmptyString -Value $ref.ref_id -Context "$Context[$refIndex] ref_id" | Out-Null
        $pathValue = Assert-NonEmptyString -Value $ref.path -Context "$Context[$refIndex] path"
        Assert-SafeRepoRelativeTrackedPath -Path $pathValue -RepositoryRoot $RepositoryRoot -Context "$Context[$refIndex]"
        $null = $paths.Add((ConvertTo-NormalizedRepoPath -Path $pathValue))
        Assert-NonEmptyString -Value $ref.source_task -Context "$Context[$refIndex] source_task" | Out-Null
        Assert-NonEmptyString -Value $ref.proof_treatment -Context "$Context[$refIndex] proof_treatment" | Out-Null
        $orderValue = Assert-IntegerValue -Value $ref.deterministic_order -Context "$Context[$refIndex] deterministic_order"
        if ($orderValue -ne ($refIndex + 1)) {
            throw "$Context[$refIndex] deterministic_order must be $($refIndex + 1)."
        }
    }

    Assert-RequiredStringsPresent -Actual ([string[]]$paths) -Required $script:RequiredDependencyPaths -Context "$Context path set"
    return $refs.Count
}

function Assert-RoleCatalog {
    param(
        [Parameter(Mandatory = $true)]$RoleCatalog,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $roles = Assert-ObjectArray -Value $RoleCatalog -Context $Context
    $roleIds = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    for ($roleIndex = 0; $roleIndex -lt $roles.Count; $roleIndex += 1) {
        $role = Assert-ObjectValue -Value $roles[$roleIndex] -Context "$Context[$roleIndex]"
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $role -Name "role_id" -Context "$Context[$roleIndex]") -Context "$Context[$roleIndex] role_id"
        if ($script:RequiredRoleIds -notcontains $roleId) {
            throw "$Context contains invalid role id '$roleId'."
        }
        if ($seen.ContainsKey($roleId)) {
            throw "$Context contains duplicate role id '$roleId'."
        }
        $seen[$roleId] = $true
        $null = $roleIds.Add($roleId)

        if ($RequireComplete) {
            foreach ($fieldName in $script:RequiredRoleFields) {
                Get-RequiredProperty -Object $role -Name $fieldName -Context "$Context[$roleIndex]" | Out-Null
            }
            Assert-NonEmptyString -Value $role.role_display_name -Context "$Context[$roleIndex] role_display_name" | Out-Null
            Assert-NonEmptyString -Value $role.authority_boundary -Context "$Context[$roleIndex] authority_boundary" | Out-Null
            Assert-StringArray -Value $role.allowed_action_categories -Context "$Context[$roleIndex] allowed_action_categories" | Out-Null
            Assert-StringArray -Value $role.forbidden_action_categories -Context "$Context[$roleIndex] forbidden_action_categories" | Out-Null
            Assert-StringArray -Value $role.required_input_ref_types -Context "$Context[$roleIndex] required_input_ref_types" | Out-Null
            $orderValue = Assert-IntegerValue -Value $role.deterministic_order -Context "$Context[$roleIndex] deterministic_order"
            if ($orderValue -ne ($roleIndex + 1)) {
                throw "$Context[$roleIndex] deterministic_order must be $($roleIndex + 1)."
            }
        }
    }

    Assert-RequiredStringsPresent -Actual ([string[]]$roleIds) -Required $script:RequiredRoleIds -Context $Context
    return $roleIds.Count
}

function Assert-RoleAliasPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-TrueFields -Object $policyObject -Fields @("canonical_role_ids_required", "role_id_must_match_catalog", "role_display_name_must_match_catalog") -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $policyObject -Fields @("aliases_allowed", "freeform_role_ids_allowed") -Context $Context -RequirePresent:$RequireComplete
}

function Assert-RequiredEnvelopeFields {
    param(
        [Parameter(Mandatory = $true)]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $fieldValues = Assert-StringArray -Value $Fields -Context $Context
    Assert-RequiredStringsPresent -Actual $fieldValues -Required $script:MinimumEnvelopeFields -Context $Context
    Assert-RequiredStringsPresent -Actual $fieldValues -Required $script:AdditionalEnvelopeFields -Context $Context
}

function Assert-AllowedActionModel {
    param(
        [Parameter(Mandatory = $true)]$Model,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $modelObject = Assert-ObjectValue -Value $Model -Context $Context
    if ($RequireComplete) {
        foreach ($fieldName in @("allowed_action_categories", "action_schema", "execution_boundary")) {
            Get-RequiredProperty -Object $modelObject -Name $fieldName -Context $Context | Out-Null
        }
        Assert-StringArray -Value $modelObject.allowed_action_categories -Context "$Context allowed_action_categories" | Out-Null
        $schema = Assert-ObjectValue -Value $modelObject.action_schema -Context "$Context action_schema"
        $requiredFields = Assert-StringArray -Value (Get-RequiredProperty -Object $schema -Name "required_fields" -Context "$Context action_schema") -Context "$Context action_schema required_fields"
        Assert-RequiredStringsPresent -Actual $requiredFields -Required $script:RequiredActionFields -Context "$Context action_schema required_fields"
        $boundary = Assert-ObjectValue -Value $modelObject.execution_boundary -Context "$Context execution_boundary"
        Assert-TrueFields -Object $boundary -Fields @("future_envelope_actions_must_be_declared", "disallow_execution_when_guard_failed_closed_over_budget") -Context "$Context execution_boundary" -RequirePresent
        Assert-FalseFields -Object $boundary -Fields @("runtime_executor_implemented", "role_run_envelope_generator_implemented", "generated_envelopes_created") -Context "$Context execution_boundary" -RequirePresent
    }
}

function Assert-ForbiddenActionModel {
    param(
        [Parameter(Mandatory = $true)]$Model,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $modelObject = Assert-ObjectValue -Value $Model -Context $Context
    if (Test-HasProperty -Object $modelObject -Name "required_forbidden_actions") {
        $actions = Assert-StringArray -Value $modelObject.required_forbidden_actions -Context "$Context required_forbidden_actions"
        Assert-RequiredStringsPresent -Actual $actions -Required $script:RequiredForbiddenActions -Context "$Context required_forbidden_actions"
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'required_forbidden_actions'."
    }
    if (Test-HasProperty -Object $modelObject -Name "claim_flags") {
        $claimFlags = Assert-ObjectValue -Value $modelObject.claim_flags -Context "$Context claim_flags"
        Assert-NoForbiddenTrueClaims -Value $claimFlags -Context "$Context claim_flags"
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'claim_flags'."
    }
}

function Assert-RequiredInputRefs {
    param(
        [Parameter(Mandatory = $true)]$RequiredInputRefs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $inputObject = Assert-ObjectValue -Value $RequiredInputRefs -Context $Context
    if (Test-HasProperty -Object $inputObject -Name "future_envelope_required_input_fields") {
        $inputFields = Assert-StringArray -Value $inputObject.future_envelope_required_input_fields -Context "$Context future_envelope_required_input_fields"
        Assert-RequiredStringsPresent -Actual $inputFields -Required $script:RequiredInputFields -Context "$Context future_envelope_required_input_fields"
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'future_envelope_required_input_fields'."
    }

    if (Test-HasProperty -Object $inputObject -Name "canonical_refs") {
        $canonicalRefs = Assert-ObjectArray -Value $inputObject.canonical_refs -Context "$Context canonical_refs"
        foreach ($ref in $canonicalRefs) {
            if (Test-HasProperty -Object $ref -Name "path") {
                Assert-SafeRepoRelativeTrackedPath -Path $ref.path -RepositoryRoot $RepositoryRoot -Context "$Context canonical_refs"
            }
        }
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'canonical_refs'."
    }
}

function Assert-ContextBudgetGuardPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-TrueFields -Object $policyObject -Fields @(
        "must_not_bypass_r16_017_guard",
        "failed_closed_over_budget_blocks_execution",
        "preserve_guard_report_as_current_repo_truth"
    ) -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $policyObject -Fields @(
        "r16_018_creates_mitigation",
        "r16_018_weakens_r16_017"
    ) -Context $Context -RequirePresent:$RequireComplete

    if ((Test-HasProperty -Object $policyObject -Name "current_guard_verdict") -and $policyObject.current_guard_verdict -ne $script:CurrentGuardVerdict) {
        throw "$Context current_guard_verdict must be $script:CurrentGuardVerdict."
    }
    if ((Test-HasProperty -Object $policyObject -Name "estimated_tokens_upper_bound") -and [int64]$policyObject.estimated_tokens_upper_bound -ne $script:CurrentEstimatedUpperBound) {
        throw "$Context estimated_tokens_upper_bound must preserve $script:CurrentEstimatedUpperBound."
    }
    if ((Test-HasProperty -Object $policyObject -Name "max_estimated_tokens_upper_bound") -and [int64]$policyObject.max_estimated_tokens_upper_bound -ne $script:MaxEstimatedUpperBound) {
        throw "$Context max_estimated_tokens_upper_bound must preserve $script:MaxEstimatedUpperBound."
    }
}

function Assert-NoFullRepoScanPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-TrueFields -Object $policyObject -Fields @("repo_relative_exact_tracked_paths_only", "tracked_files_only") -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $policyObject -Fields @(
        "broad_repo_root_refs_allowed",
        "broad_repo_scan_allowed",
        "full_repo_scan_allowed",
        "wildcard_paths_allowed",
        "directory_only_refs_allowed",
        "scratch_temp_paths_allowed",
        "absolute_paths_allowed",
        "parent_traversal_allowed",
        "url_or_remote_refs_allowed",
        "raw_chat_history_loading_allowed",
        "report_as_machine_proof_allowed"
    ) -Context $Context -RequirePresent:$RequireComplete
}

function Assert-EvidenceRefPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-TrueFields -Object $policyObject -Fields @("exact_repo_relative_tracked_paths_only", "machine_proof_requires_validator") -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $policyObject -Fields @("report_as_machine_proof_allowed", "raw_chat_history_as_evidence_allowed", "operator_report_as_machine_proof_allowed") -Context $Context -RequirePresent:$RequireComplete
}

function Assert-HandoffBoundaryPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-TrueFields -Object $policyObject -Fields @("handoff_constraints_required") -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $policyObject -Fields @("handoff_packet_implemented", "raci_transition_gate_implemented", "workflow_drill_run") -Context $Context -RequirePresent:$RequireComplete
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ((Test-HasProperty -Object $postureObject -Name "active_through_task") -and $postureObject.active_through_task -ne "R16-018") {
        throw "$Context active_through_task must be R16-018."
    }
    elseif ($RequireComplete -and -not (Test-HasProperty -Object $postureObject -Name "active_through_task")) {
        throw "$Context is missing required field 'active_through_task'."
    }

    if (Test-HasProperty -Object $postureObject -Name "complete_tasks") {
        $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
        foreach ($taskId in $completeTasks) {
            if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 19) {
                throw "$Context claims R16-019 or later implementation."
            }
        }
        if ($RequireComplete) {
            Assert-ExactStringSet -Actual $completeTasks -Expected ([string[]](1..18 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
        }
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'complete_tasks'."
    }

    if (Test-HasProperty -Object $postureObject -Name "planned_tasks") {
        $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
        foreach ($taskId in $plannedTasks) {
            if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
                throw "$Context introduces R16-027 or later task."
            }
        }
        if ($RequireComplete) {
            Assert-ExactStringSet -Actual $plannedTasks -Expected ([string[]](19..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"
        }
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'planned_tasks'."
    }

    Assert-TrueFields -Object $postureObject -Fields @("role_run_envelope_contract_defined") -Context $Context -RequirePresent:$RequireComplete
    Assert-FalseFields -Object $postureObject -Fields @(
        "generated_role_run_envelopes_exist",
        "role_run_envelope_generator_exists",
        "raci_transition_gate_exists",
        "handoff_packet_exists",
        "workflow_drill_exists",
        "r16_019_or_later_implementation_claimed",
        "r16_027_or_later_task_exists"
    ) -Context $Context -RequirePresent:$RequireComplete
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    if ($RequireComplete) {
        foreach ($boundaryName in @("r13", "r14", "r15")) {
            Get-RequiredProperty -Object $boundaryObject -Name $boundaryName -Context $Context | Out-Null
        }
    }
    if (Test-HasProperty -Object $boundaryObject -Name "r13") {
        $r13 = Assert-ObjectValue -Value $boundaryObject.r13 -Context "$Context r13"
        Assert-FalseFields -Object $r13 -Fields @("closed", "partial_gates_converted_to_passed") -Context "$Context r13" -RequirePresent:$RequireComplete
        if ((Test-HasProperty -Object $r13 -Name "status") -and $r13.status -ne "failed_partial_through_r13_018_only") {
            throw "$Context r13 status must preserve failed_partial_through_r13_018_only."
        }
    }
    if (Test-HasProperty -Object $boundaryObject -Name "r14") {
        $r14 = Assert-ObjectValue -Value $boundaryObject.r14 -Context "$Context r14"
        Assert-FalseFields -Object $r14 -Fields @("caveats_removed") -Context "$Context r14" -RequirePresent:$RequireComplete
        if ((Test-HasProperty -Object $r14 -Name "status") -and $r14.status -ne "accepted_with_caveats_through_r14_006_only") {
            throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
        }
    }
    if (Test-HasProperty -Object $boundaryObject -Name "r15") {
        $r15 = Assert-ObjectValue -Value $boundaryObject.r15 -Context "$Context r15"
        Assert-FalseFields -Object $r15 -Fields @("caveats_removed") -Context "$Context r15" -RequirePresent:$RequireComplete
        Assert-TrueFields -Object $r15 -Fields @("stale_generated_from_caveat_preserved") -Context "$Context r15" -RequirePresent:$RequireComplete
        if ((Test-HasProperty -Object $r15 -Name "status") -and $r15.status -ne "accepted_with_caveats_through_r15_009_only") {
            throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
        }
    }
}

function Assert-InvalidStatePolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireComplete
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    if (Test-HasProperty -Object $policyObject -Name "claim_flags") {
        $claimFlags = Assert-ObjectValue -Value $policyObject.claim_flags -Context "$Context claim_flags"
        Assert-NoForbiddenTrueClaims -Value $claimFlags -Context "$Context claim_flags"
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'claim_flags'."
    }
    if (Test-HasProperty -Object $policyObject -Name "rejected_states") {
        $rejectedStates = Assert-StringArray -Value $policyObject.rejected_states -Context "$Context rejected_states"
        Assert-RequiredStringsPresent -Actual $rejectedStates -Required $script:RequiredForbiddenActions -Context "$Context rejected_states"
    }
    elseif ($RequireComplete) {
        throw "$Context is missing required field 'rejected_states'."
    }
}

function Assert-FutureEnvelopeCandidateFixture {
    param(
        [Parameter(Mandatory = $true)]$Candidate,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $candidateObject = Assert-ObjectValue -Value $Candidate -Context $Context
    if (Test-HasProperty -Object $candidateObject -Name "role_id") {
        $roleId = Assert-NonEmptyString -Value $candidateObject.role_id -Context "$Context role_id"
        if ($script:RequiredRoleIds -notcontains $roleId) {
            throw "$Context contains invalid role id '$roleId'."
        }
    }
    if ((Test-HasProperty -Object $candidateObject -Name "budget_guard_status") -and $candidateObject.budget_guard_status -eq $script:CurrentGuardVerdict) {
        $executableValue = if (Test-HasProperty -Object $candidateObject -Name "executable") { [bool]$candidateObject.executable } else { $false }
        $statusValue = if (Test-HasProperty -Object $candidateObject -Name "envelope_execution_status") { [string]$candidateObject.envelope_execution_status } else { "blocked" }
        if ($executableValue -or $statusValue -notin @("blocked", "not_executable")) {
            throw "$Context failed_closed_over_budget guard must block execution unless a later explicit machine-checkable mitigation exists."
        }
    }
}

function Invoke-EarlyContractChecks {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)][string]$SourceLabel,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    Assert-NoForbiddenTrueClaims -Value $Contract -Context $SourceLabel
    if (Test-HasProperty -Object $Contract -Name "role_catalog") {
        Assert-RoleCatalog -RoleCatalog $Contract.role_catalog -Context "$SourceLabel role_catalog" | Out-Null
    }
    if (Test-HasProperty -Object $Contract -Name "role_alias_policy") {
        Assert-RoleAliasPolicy -Policy $Contract.role_alias_policy -Context "$SourceLabel role_alias_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "required_envelope_fields") {
        Assert-RequiredEnvelopeFields -Fields $Contract.required_envelope_fields -Context "$SourceLabel required_envelope_fields"
    }
    if (Test-HasProperty -Object $Contract -Name "required_input_refs") {
        Assert-RequiredInputRefs -RequiredInputRefs $Contract.required_input_refs -RepositoryRoot $RepositoryRoot -Context "$SourceLabel required_input_refs"
    }
    if (Test-HasProperty -Object $Contract -Name "context_budget_guard_policy") {
        Assert-ContextBudgetGuardPolicy -Policy $Contract.context_budget_guard_policy -Context "$SourceLabel context_budget_guard_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "no_full_repo_scan_policy") {
        Assert-NoFullRepoScanPolicy -Policy $Contract.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "evidence_ref_policy") {
        Assert-EvidenceRefPolicy -Policy $Contract.evidence_ref_policy -Context "$SourceLabel evidence_ref_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "handoff_boundary_policy") {
        Assert-HandoffBoundaryPolicy -Policy $Contract.handoff_boundary_policy -Context "$SourceLabel handoff_boundary_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "forbidden_action_model") {
        Assert-ForbiddenActionModel -Model $Contract.forbidden_action_model -Context "$SourceLabel forbidden_action_model"
    }
    if (Test-HasProperty -Object $Contract -Name "current_posture") {
        Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture"
    }
    if (Test-HasProperty -Object $Contract -Name "preserved_boundaries") {
        Assert-PreservedBoundaries -Boundaries $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    }
    if (Test-HasProperty -Object $Contract -Name "invalid_state_policy") {
        Assert-InvalidStatePolicy -Policy $Contract.invalid_state_policy -Context "$SourceLabel invalid_state_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "future_envelope_candidate_fixture") {
        Assert-FutureEnvelopeCandidateFixture -Candidate $Contract.future_envelope_candidate_fixture -Context "$SourceLabel future_envelope_candidate_fixture"
    }
}

function Test-R16RoleRunEnvelopeContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [string]$SourceLabel = "R16 role-run envelope contract",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Invoke-EarlyContractChecks -Contract $Contract -SourceLabel $SourceLabel -RepositoryRoot $resolvedRoot

    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Contract -Name $fieldName -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_role_run_envelope_contract") {
        throw "$SourceLabel artifact_type must be r16_role_run_envelope_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.role_run_envelope_contract_id -ne $script:ContractId) {
        throw "$SourceLabel role_run_envelope_contract_id must be $script:ContractId."
    }
    if ($Contract.source_milestone -ne $script:R16Milestone -or $Contract.repository -ne $script:Repository -or $Contract.branch -ne $script:Branch) {
        throw "$SourceLabel milestone, repository, or branch metadata is incorrect."
    }
    if ($Contract.source_task -ne "R16-018") {
        throw "$SourceLabel source_task must be R16-018."
    }
    if ($Contract.generated_from_head -ne $script:BaselineHead) {
        throw "$SourceLabel generated_from_head must be $script:BaselineHead."
    }

    $dependencyRefCount = Assert-DependencyRefs -DependencyRefs $Contract.dependency_refs -RepositoryRoot $resolvedRoot -Context "$SourceLabel dependency_refs"
    $roleCount = Assert-RoleCatalog -RoleCatalog $Contract.role_catalog -Context "$SourceLabel role_catalog" -RequireComplete
    Assert-RoleAliasPolicy -Policy $Contract.role_alias_policy -Context "$SourceLabel role_alias_policy" -RequireComplete
    Assert-RequiredEnvelopeFields -Fields $Contract.required_envelope_fields -Context "$SourceLabel required_envelope_fields"
    Assert-AllowedActionModel -Model $Contract.allowed_action_model -Context "$SourceLabel allowed_action_model" -RequireComplete
    Assert-ForbiddenActionModel -Model $Contract.forbidden_action_model -Context "$SourceLabel forbidden_action_model" -RequireComplete
    Assert-RequiredInputRefs -RequiredInputRefs $Contract.required_input_refs -RepositoryRoot $resolvedRoot -Context "$SourceLabel required_input_refs" -RequireComplete
    Assert-ContextBudgetGuardPolicy -Policy $Contract.context_budget_guard_policy -Context "$SourceLabel context_budget_guard_policy" -RequireComplete
    Assert-NoFullRepoScanPolicy -Policy $Contract.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy" -RequireComplete
    Assert-EvidenceRefPolicy -Policy $Contract.evidence_ref_policy -Context "$SourceLabel evidence_ref_policy" -RequireComplete
    Assert-HandoffBoundaryPolicy -Policy $Contract.handoff_boundary_policy -Context "$SourceLabel handoff_boundary_policy" -RequireComplete
    Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture" -RequireComplete
    Assert-PreservedBoundaries -Boundaries $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries" -RequireComplete
    Assert-InvalidStatePolicy -Policy $Contract.invalid_state_policy -Context "$SourceLabel invalid_state_policy" -RequireComplete

    $nonClaims = Assert-StringArray -Value $Contract.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ContractId = $Contract.role_run_envelope_contract_id
        SourceTask = $Contract.source_task
        ActiveThroughTask = $Contract.current_posture.active_through_task
        PlannedTaskStart = $Contract.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Contract.current_posture.planned_tasks[-1]
        DependencyRefCount = $dependencyRefCount
        RoleCount = $roleCount
        RequiredEnvelopeFieldCount = @($Contract.required_envelope_fields).Count
        RequiredInputRefCount = @($Contract.required_input_refs.future_envelope_required_input_fields).Count
        GuardVerdict = $Contract.context_budget_guard_policy.current_guard_verdict
        GuardBlocksExecution = [bool]$Contract.context_budget_guard_policy.failed_closed_over_budget_blocks_execution
        GeneratedRoleRunEnvelopesExist = [bool]$Contract.current_posture.generated_role_run_envelopes_exist
        RoleRunEnvelopeGeneratorExists = [bool]$Contract.current_posture.role_run_envelope_generator_exists
        RaciTransitionGateExists = [bool]$Contract.current_posture.raci_transition_gate_exists
        HandoffPacketExists = [bool]$Contract.current_posture.handoff_packet_exists
        WorkflowDrillExists = [bool]$Contract.current_posture.workflow_drill_exists
        R13Closed = [bool]$Contract.preserved_boundaries.r13.closed
        R14CaveatsRemoved = [bool]$Contract.preserved_boundaries.r14.caveats_removed
        R15CaveatsRemoved = [bool]$Contract.preserved_boundaries.r15.caveats_removed
    }
}

function Test-R16RoleRunEnvelopeContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/workflow/r16_role_run_envelope.contract.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        $Path
    }
    else {
        Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $Path)
    }

    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 role-run envelope contract"
    return Test-R16RoleRunEnvelopeContractObject -Contract $contract -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

Export-ModuleMember -Function Test-R16RoleRunEnvelopeContract, Test-R16RoleRunEnvelopeContractObject
