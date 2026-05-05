Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "context_load_plan_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "dependency_refs",
    "contract_mode",
    "context_load_plan_schema",
    "context_source_ref_schema",
    "load_group_schema",
    "context_budget_schema",
    "exact_ref_policy",
    "proof_treatment_policy",
    "overclaim_detection_policy",
    "current_posture",
    "preserved_boundaries",
    "validation_commands",
    "non_claims"
)

$script:RequiredContractModeFalseFields = @(
    "generated_context_load_plan",
    "context_load_planner",
    "context_budget_estimator",
    "over_budget_fail_closed_validator",
    "runtime_memory",
    "retrieval_runtime",
    "vector_search_runtime",
    "product_runtime",
    "autonomous_agents",
    "external_integrations",
    "role_run_envelope",
    "raci_transition_gate",
    "handoff_packet",
    "workflow_drill"
)

$script:RequiredClaimFlagFalseFields = @(
    "generated_context_load_plan",
    "context_load_planner",
    "context_budget_estimator",
    "over_budget_fail_closed_validator",
    "runtime_memory_loading",
    "persistent_memory_runtime",
    "retrieval_runtime",
    "vector_search_runtime",
    "product_runtime",
    "productized_ui",
    "actual_autonomous_agents",
    "true_multi_agent_execution",
    "role_run_envelope",
    "raci_transition_gate",
    "handoff_packet",
    "workflow_drill",
    "external_integrations",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "main_merge",
    "r13_closure",
    "r14_caveat_removal",
    "r15_caveat_removal",
    "r13_partial_gate_conversion",
    "r16_015_or_later_implementation",
    "r16_027_or_later_task"
)

$script:RequiredPlanFields = @(
    "context_load_plan_id",
    "source_milestone",
    "source_task",
    "target_role",
    "target_workflow_scope",
    "source_refs",
    "load_groups",
    "artifact_refs",
    "audit_refs",
    "exclusion_refs",
    "context_budget",
    "load_order",
    "exact_ref_policy",
    "validation_commands",
    "non_claims",
    "deterministic_order"
)

$script:RequiredSourceRefFields = @(
    "ref_id",
    "path",
    "ref_kind",
    "source_task",
    "authority_level",
    "proof_status",
    "load_required",
    "deterministic_order"
)

$script:RequiredLoadGroupFields = @(
    "group_id",
    "purpose",
    "required_refs",
    "optional_refs",
    "forbidden_refs",
    "max_items",
    "deterministic_order"
)

$script:RequiredBudgetFields = @(
    "budget_id",
    "budget_unit",
    "max_budget",
    "estimator_status",
    "over_budget_policy",
    "fail_closed_required",
    "deterministic_order"
)

$script:RequiredNonClaims = @(
    "no generated context-load plan",
    "no context-load planner",
    "no context budget estimator",
    "no over-budget fail-closed validator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability"
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
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context must contain only objects."
        }
    }

    $PSCmdlet.WriteObject($items, $false)
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

function Assert-PresentFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        if (Test-HasProperty -Object $Object -Name $field) {
            $value = Get-RequiredProperty -Object $Object -Name $field -Context $Context
            if ((Assert-BooleanValue -Value $value -Context "$Context $field") -ne $false) {
                throw "$Context $field must be False."
            }
        }
    }
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/")
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-DirectoryOnlyPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (ConvertTo-NormalizedRepoPath -Path $Path).EndsWith("/")
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context path must be repo-relative, not absolute."
    }
    if (Test-BroadRepoRootPath -Path $normalized) {
        throw "$Context rejects broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $normalized) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if (Test-DirectoryOnlyPath -Path $normalized) {
        throw "$Context rejects directory-only ref '$Path'."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    $root = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if ($RequireLeaf -and -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context required path '$Path' does not exist."
    }

    return $resolved
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

function Assert-RequiredSchemaFields {
    param(
        [Parameter(Mandatory = $true)]$Schema,
        [Parameter(Mandatory = $true)][string[]]$RequiredFields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $schemaObject = Assert-ObjectValue -Value $Schema -Context $Context
    $fields = Assert-StringArray -Value (Get-RequiredProperty -Object $schemaObject -Name "required_fields" -Context $Context) -Context "$Context required_fields"
    Assert-RequiredValuesPresent -Values $fields -RequiredValues $RequiredFields -Context "$Context required_fields"
}

function Assert-ExactRefPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @(
        "repo_relative_exact_paths_only",
        "directory_only_refs_require_exact_files",
        "generated_plan_requires_dedicated_r16_015_planner"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }

    foreach ($falseField in @(
        "wildcard_path_claims_allowed",
        "broad_repo_root_claims_allowed",
        "full_repo_scan_allowed",
        "directory_only_ref_policy_allowed",
        "r16_014_generates_context_load_plan",
        "r16_014_implements_context_load_planner"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-ProofTreatmentPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name "contract_artifact_only" -Context $Context) -Context "$Context contract_artifact_only") -ne $true) {
        throw "$Context contract_artifact_only must be True."
    }

    foreach ($falseField in @(
        "generated_context_load_plan_as_machine_proof_allowed",
        "generated_reports_as_machine_proof_allowed",
        "operator_reports_as_machine_proof_allowed",
        "planning_artifacts_as_implementation_proof_allowed",
        "runtime_product_claims_allowed_without_later_evidence"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name "runtime_product_claims_rejected_unless_later_implemented_and_evidenced" -Context $Context) -Context "$Context runtime_product_claims_rejected_unless_later_implemented_and_evidenced") -ne $true) {
        throw "$Context runtime_product_claims_rejected_unless_later_implemented_and_evidenced must be True."
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-014") {
        throw "$Context active_through_task must be R16-014."
    }

    $completeTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "complete_tasks" -Context $Context) -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "planned_tasks" -Context $Context) -Context "$Context planned_tasks"
    Assert-ExactStringSet -Values $completeTasks -ExpectedValues @("R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006", "R16-007", "R16-008", "R16-009", "R16-010", "R16-011", "R16-012", "R16-013", "R16-014") -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues @("R16-015", "R16-016", "R16-017", "R16-018", "R16-019", "R16-020", "R16-021", "R16-022", "R16-023", "R16-024", "R16-025", "R16-026") -Context "$Context planned_tasks"

    foreach ($task in $completeTasks) {
        if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 15) {
            throw "$Context claims R16-015 or later implementation."
        }
    }
    foreach ($task in $plannedTasks) {
        if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task."
        }
    }

    foreach ($falseField in @("r16_015_or_later_implementation_claimed", "r16_027_or_later_task_exists")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaries = Assert-ObjectValue -Value $Value -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaries -Name "r13" -Context $Context) -Context "$Context r13"
    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaries -Name "r14" -Context $Context) -Context "$Context r14"
    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaries -Name "r15" -Context $Context) -Context "$Context r15"

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $r13 -Name "closed" -Context "$Context r13") -Context "$Context r13 closed") -ne $false) {
        throw "$Context r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $r13 -Name "partial_gates_converted_to_passed" -Context "$Context r13") -Context "$Context r13 partial_gates_converted_to_passed") -ne $false) {
        throw "$Context r13 partial_gates_converted_to_passed must be False."
    }
    if ($r13.status -ne "failed_partial_through_r13_018_only") {
        throw "$Context r13 status must preserve failed_partial_through_r13_018_only."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $r14 -Name "caveats_removed" -Context "$Context r14") -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }
    if ($r14.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $r15 -Name "caveats_removed" -Context "$Context r15") -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $r15 -Name "stale_generated_from_caveat_preserved" -Context "$Context r15") -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale_generated_from_caveat_preserved must be True."
    }
    if ($r15.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
}

function Invoke-EarlyOverclaimChecks {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)][string]$SourceLabel
    )

    if (Test-HasProperty -Object $Contract -Name "contract_mode") {
        $mode = Assert-ObjectValue -Value $Contract.contract_mode -Context "$SourceLabel contract_mode"
        Assert-PresentFalseFields -Object $mode -Fields $script:RequiredContractModeFalseFields -Context "$SourceLabel contract_mode"
    }
    if (Test-HasProperty -Object $Contract -Name "overclaim_detection_policy") {
        $policy = Assert-ObjectValue -Value $Contract.overclaim_detection_policy -Context "$SourceLabel overclaim_detection_policy"
        if (Test-HasProperty -Object $policy -Name "claim_flags") {
            $flags = Assert-ObjectValue -Value $policy.claim_flags -Context "$SourceLabel overclaim_detection_policy claim_flags"
            Assert-PresentFalseFields -Object $flags -Fields $script:RequiredClaimFlagFalseFields -Context "$SourceLabel overclaim_detection_policy claim_flags"
        }
    }
    if (Test-HasProperty -Object $Contract -Name "exact_ref_policy") {
        $policy = Assert-ObjectValue -Value $Contract.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
        Assert-PresentFalseFields -Object $policy -Fields @(
            "wildcard_path_claims_allowed",
            "broad_repo_root_claims_allowed",
            "full_repo_scan_allowed",
            "directory_only_ref_policy_allowed",
            "r16_014_generates_context_load_plan",
            "r16_014_implements_context_load_planner"
        ) -Context "$SourceLabel exact_ref_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "proof_treatment_policy") {
        $policy = Assert-ObjectValue -Value $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"
        Assert-PresentFalseFields -Object $policy -Fields @(
            "generated_context_load_plan_as_machine_proof_allowed",
            "generated_reports_as_machine_proof_allowed",
            "operator_reports_as_machine_proof_allowed",
            "planning_artifacts_as_implementation_proof_allowed",
            "runtime_product_claims_allowed_without_later_evidence"
        ) -Context "$SourceLabel proof_treatment_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "current_posture") {
        $posture = Assert-ObjectValue -Value $Contract.current_posture -Context "$SourceLabel current_posture"
        if (Test-HasProperty -Object $posture -Name "complete_tasks") {
            $completeTasks = Assert-StringArray -Value $posture.complete_tasks -Context "$SourceLabel current_posture complete_tasks" -AllowEmpty
            foreach ($task in $completeTasks) {
                if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 15) {
                    throw "$SourceLabel current_posture claims R16-015 or later implementation."
                }
            }
        }
        if (Test-HasProperty -Object $posture -Name "planned_tasks") {
            $plannedTasks = Assert-StringArray -Value $posture.planned_tasks -Context "$SourceLabel current_posture planned_tasks" -AllowEmpty
            foreach ($task in $plannedTasks) {
                if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
                    throw "$SourceLabel current_posture introduces R16-027 or later task."
                }
            }
        }
        Assert-PresentFalseFields -Object $posture -Fields @("r16_015_or_later_implementation_claimed", "r16_027_or_later_task_exists") -Context "$SourceLabel current_posture"
    }
    if (Test-HasProperty -Object $Contract -Name "preserved_boundaries") {
        $boundaries = Assert-ObjectValue -Value $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
        if (Test-HasProperty -Object $boundaries -Name "r13") {
            $r13 = Assert-ObjectValue -Value $boundaries.r13 -Context "$SourceLabel preserved_boundaries r13"
            Assert-PresentFalseFields -Object $r13 -Fields @("closed", "partial_gates_converted_to_passed") -Context "$SourceLabel preserved_boundaries r13"
        }
        if (Test-HasProperty -Object $boundaries -Name "r14") {
            $r14 = Assert-ObjectValue -Value $boundaries.r14 -Context "$SourceLabel preserved_boundaries r14"
            Assert-PresentFalseFields -Object $r14 -Fields @("caveats_removed") -Context "$SourceLabel preserved_boundaries r14"
        }
        if (Test-HasProperty -Object $boundaries -Name "r15") {
            $r15 = Assert-ObjectValue -Value $boundaries.r15 -Context "$SourceLabel preserved_boundaries r15"
            Assert-PresentFalseFields -Object $r15 -Fields @("caveats_removed") -Context "$SourceLabel preserved_boundaries r15"
        }
    }
}

function Assert-DependencyRef {
    param(
        [Parameter(Mandatory = $true)]$Ref,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in @("ref_id", "path", "source_task", "proof_treatment", "deterministic_order")) {
        Get-RequiredProperty -Object $Ref -Name $field -Context $Context | Out-Null
    }

    Assert-NonEmptyString -Value $Ref.ref_id -Context "$Context ref_id" | Out-Null
    Assert-SafeRepoRelativePath -Path (Assert-NonEmptyString -Value $Ref.path -Context "$Context path") -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    Assert-NonEmptyString -Value $Ref.source_task -Context "$Context source_task" | Out-Null
    Assert-NonEmptyString -Value $Ref.proof_treatment -Context "$Context proof_treatment" | Out-Null
    $order = Assert-IntegerValue -Value $Ref.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
}

function Test-R16ContextLoadPlanContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [string]$SourceLabel = "R16 context-load plan contract",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Invoke-EarlyOverclaimChecks -Contract $Contract -SourceLabel $SourceLabel

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Contract -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_context_load_plan_contract") {
        throw "$SourceLabel artifact_type must be r16_context_load_plan_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.context_load_plan_contract_id -ne "aioffice-r16-014-context-load-plan-contract-v1") {
        throw "$SourceLabel context_load_plan_contract_id must be aioffice-r16-014-context-load-plan-contract-v1."
    }
    if ($Contract.source_milestone -ne $script:R16Milestone -or $Contract.repository -ne $script:Repository -or $Contract.branch -ne $script:Branch) {
        throw "$SourceLabel milestone, repository, or branch metadata is incorrect."
    }
    if ($Contract.source_task -ne "R16-014") {
        throw "$SourceLabel source_task must be R16-014."
    }
    if ((Assert-NonEmptyString -Value $Contract.generated_from_head -Context "$SourceLabel generated_from_head") -notmatch '^[0-9a-f]{40}$') {
        throw "$SourceLabel generated_from_head must be a 40-character SHA."
    }
    if ((Assert-NonEmptyString -Value $Contract.generated_from_tree -Context "$SourceLabel generated_from_tree") -notmatch '^[0-9a-f]{40}$') {
        throw "$SourceLabel generated_from_tree must be a 40-character tree SHA."
    }

    $mode = Assert-ObjectValue -Value $Contract.contract_mode -Context "$SourceLabel contract_mode"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "contract_only" -Context "$SourceLabel contract_mode") -Context "$SourceLabel contract_mode contract_only") -ne $true) {
        throw "$SourceLabel contract_mode contract_only must be True."
    }
    Assert-FalseFields -Object $mode -Fields $script:RequiredContractModeFalseFields -Context "$SourceLabel contract_mode"

    $dependencyRefs = Assert-ObjectArray -Value $Contract.dependency_refs -Context "$SourceLabel dependency_refs"
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-DependencyRef -Ref $dependencyRefs[$index] -Context "$SourceLabel dependency_refs[$index]" -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1)
    }

    Assert-RequiredSchemaFields -Schema $Contract.context_load_plan_schema -RequiredFields $script:RequiredPlanFields -Context "$SourceLabel context_load_plan_schema"
    Assert-RequiredSchemaFields -Schema $Contract.context_source_ref_schema -RequiredFields $script:RequiredSourceRefFields -Context "$SourceLabel context_source_ref_schema"
    Assert-RequiredSchemaFields -Schema $Contract.load_group_schema -RequiredFields $script:RequiredLoadGroupFields -Context "$SourceLabel load_group_schema"
    Assert-RequiredSchemaFields -Schema $Contract.context_budget_schema -RequiredFields $script:RequiredBudgetFields -Context "$SourceLabel context_budget_schema"
    Assert-ExactRefPolicy -Policy $Contract.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
    Assert-ProofTreatmentPolicy -Policy $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"

    $overclaimPolicy = Assert-ObjectValue -Value $Contract.overclaim_detection_policy -Context "$SourceLabel overclaim_detection_policy"
    $claimFlags = Assert-ObjectValue -Value (Get-RequiredProperty -Object $overclaimPolicy -Name "claim_flags" -Context "$SourceLabel overclaim_detection_policy") -Context "$SourceLabel overclaim_detection_policy claim_flags"
    Assert-FalseFields -Object $claimFlags -Fields $script:RequiredClaimFlagFalseFields -Context "$SourceLabel overclaim_detection_policy claim_flags"
    Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $commands = Assert-ObjectArray -Value $Contract.validation_commands -Context "$SourceLabel validation_commands"
    for ($index = 0; $index -lt $commands.Count; $index += 1) {
        $command = $commands[$index]
        foreach ($field in @("command_id", "command", "expected_result", "validates_path", "required_for_closeout", "deterministic_order")) {
            Get-RequiredProperty -Object $command -Name $field -Context "$SourceLabel validation_commands[$index]" | Out-Null
        }
        if ((Assert-IntegerValue -Value $command.deterministic_order -Context "$SourceLabel validation_commands[$index] deterministic_order") -ne ($index + 1)) {
            throw "$SourceLabel validation_commands[$index] deterministic_order must be $($index + 1)."
        }
    }

    $nonClaims = Assert-StringArray -Value $Contract.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ContractId = $Contract.context_load_plan_contract_id
        SourceTask = $Contract.source_task
        ActiveThroughTask = $Contract.current_posture.active_through_task
        PlannedTaskStart = $Contract.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Contract.current_posture.planned_tasks[-1]
        ContractOnly = [bool]$mode.contract_only
        GeneratedContextLoadPlan = [bool]$mode.generated_context_load_plan
        ContextLoadPlanner = [bool]$mode.context_load_planner
        ContextBudgetEstimator = [bool]$mode.context_budget_estimator
        OverBudgetFailClosedValidator = [bool]$mode.over_budget_fail_closed_validator
        RuntimeMemory = [bool]$mode.runtime_memory
        RetrievalRuntime = [bool]$mode.retrieval_runtime
        VectorSearchRuntime = [bool]$mode.vector_search_runtime
        ProductRuntime = [bool]$mode.product_runtime
        AutonomousAgents = [bool]$mode.autonomous_agents
        ExternalIntegrations = [bool]$mode.external_integrations
        RoleRunEnvelope = [bool]$mode.role_run_envelope
        RaciTransitionGate = [bool]$mode.raci_transition_gate
        HandoffPacket = [bool]$mode.handoff_packet
        WorkflowDrill = [bool]$mode.workflow_drill
        R16015OrLaterClaimed = [bool]$Contract.current_posture.r16_015_or_later_implementation_claimed
        R16027OrLaterTaskExists = [bool]$Contract.current_posture.r16_027_or_later_task_exists
        R13Closed = [bool]$Contract.preserved_boundaries.r13.closed
        R14CaveatsRemoved = [bool]$Contract.preserved_boundaries.r14.caveats_removed
        R15CaveatsRemoved = [bool]$Contract.preserved_boundaries.r15.caveats_removed
        DependencyRefCount = $dependencyRefs.Count
    }
}

function Test-R16ContextLoadPlanContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/context/r16_context_load_plan.contract.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        $Path
    }
    else {
        Join-Path $resolvedRepositoryRoot $Path
    }

    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context-load plan contract"
    return Test-R16ContextLoadPlanContractObject -Contract $contract -SourceLabel $Path -RepositoryRoot $resolvedRepositoryRoot
}

Export-ModuleMember -Function Test-R16ContextLoadPlanContract, Test-R16ContextLoadPlanContractObject
