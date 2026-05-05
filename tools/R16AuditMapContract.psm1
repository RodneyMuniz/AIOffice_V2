Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "audit_map_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "dependency_refs",
    "contract_mode",
    "audit_map_entry_schema",
    "authority_level_taxonomy",
    "proof_status_values",
    "audit_readiness_status_values",
    "inspection_route_schema",
    "caveat_schema",
    "validation_command_schema",
    "exact_ref_policy",
    "audit_map_generation_policy",
    "proof_treatment_policy",
    "overclaim_detection_policy",
    "current_posture",
    "preserved_boundaries",
    "validation_commands",
    "non_claims"
)

$script:RequiredDependencyPaths = @(
    "contracts/artifacts/r16_artifact_map.contract.json",
    "state/artifacts/r16_artifact_map.json",
    "tools/R16ArtifactMapGenerator.psm1",
    "tools/validate_r16_artifact_map.ps1",
    "tests/test_r16_artifact_map_generator.ps1",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/validation_manifest.md"
)

$script:RequiredContractModeFalseFields = @(
    "generated_audit_map",
    "audit_map_generator",
    "r15_r16_audit_map_generated",
    "artifact_map_diff_tooling",
    "context_load_planner",
    "context_budget_estimator",
    "role_run_envelope",
    "raci_transition_gate",
    "handoff_packet",
    "workflow_drill",
    "runtime_memory",
    "product_runtime",
    "autonomous_agents",
    "external_integrations"
)

$script:RequiredAuditMapEntryFields = @(
    "audit_entry_id",
    "evidence_path",
    "artifact_id",
    "artifact_type",
    "source_milestone",
    "source_task",
    "authority_level",
    "authority_class",
    "evidence_kind",
    "proof_status",
    "proof_treatment",
    "inspection_route",
    "exact_ref_required",
    "broad_scan_allowed",
    "wildcard_allowed",
    "stale_ref_status",
    "caveat_id",
    "validation_commands",
    "required_for_closeout",
    "audit_readiness_status",
    "non_claims",
    "deterministic_order"
)

$script:RequiredAuthorityLevels = @(
    "constitutional_authority",
    "governance_authority",
    "milestone_authority",
    "contract_authority",
    "generated_state_artifact",
    "validation_report",
    "validation_manifest",
    "proof_review_package",
    "evidence_index",
    "operator_report",
    "planning_artifact",
    "narrative_context",
    "external_evidence",
    "local_only_rejected"
)

$script:RequiredProofStatuses = @(
    "machine_validated",
    "validator_backed_state_artifact",
    "generated_state_artifact_only",
    "contract_only",
    "proof_review_only",
    "validation_manifest_only",
    "operator_artifact_only",
    "planning_artifact_only",
    "narrative_context_only",
    "external_replay_evidence",
    "stale_with_explicit_caveat",
    "stale_without_caveat_rejected",
    "runtime_claim_rejected",
    "local_only_rejected"
)

$script:RequiredAuditReadinessStatuses = @(
    "ready_for_exact_inspection",
    "ready_with_caveat",
    "context_only",
    "not_implementation_proof",
    "rejected_overclaim",
    "missing_required_ref",
    "stale_without_caveat",
    "planned_only"
)

$script:RequiredInspectionRouteFields = @(
    "route_id",
    "route_kind",
    "evidence_path",
    "reader_role",
    "exact_command",
    "expected_content_type",
    "broad_scan_allowed",
    "wildcard_allowed",
    "fallback_allowed",
    "fallback_route",
    "audit_notes"
)

$script:RequiredCaveatFields = @(
    "caveat_id",
    "caveat_type",
    "applies_to_path",
    "applies_to_ref_id",
    "declared_boundary",
    "observed_boundary",
    "accepted_reason",
    "preserved_scope",
    "audit_impact",
    "deterministic_order"
)

$script:RequiredValidationCommandFields = @(
    "command_id",
    "command",
    "expected_result",
    "validates_path",
    "evidence_kind",
    "required_for_closeout",
    "deterministic_order"
)

$script:RequiredProofTreatmentCategories = @(
    "machine-validated evidence",
    "validator-backed committed state artifacts",
    "generated state artifacts only",
    "contract-only artifacts",
    "proof-review packages",
    "validation manifests",
    "operator reports",
    "planning artifacts",
    "narrative context",
    "external replay evidence",
    "local-only rejected evidence",
    "runtime/product claims rejected unless later implemented and evidenced"
)

$script:RequiredRejectedClaimFlags = @(
    "generated_audit_map",
    "audit_map_generator",
    "r15_r16_audit_map_generated",
    "artifact_map_diff_tooling",
    "context_load_planner",
    "context_budget_estimator",
    "role_run_envelope",
    "raci_transition_gate",
    "handoff_packet",
    "workflow_drill",
    "product_runtime",
    "productized_ui",
    "actual_autonomous_agents",
    "true_multi_agent_execution",
    "persistent_memory_runtime",
    "runtime_memory_loading",
    "retrieval_runtime",
    "vector_search_runtime",
    "external_integrations",
    "github_projects_integration",
    "linear_integration",
    "symphony_integration",
    "custom_board_integration",
    "external_board_sync",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "main_merge",
    "r13_closure",
    "r14_caveat_removal",
    "r15_caveat_removal",
    "r13_partial_gate_conversion",
    "r16_012_or_later_implementation",
    "r16_027_or_later_task"
)

$script:RequiredNonClaims = @(
    "no generated audit map",
    "no audit map generator",
    "no R15/R16 audit map",
    "no artifact-map diff/check tooling",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no runtime memory",
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

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-DirectoryOnlyPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/").EndsWith("/")
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        throw "$Context path must be a repo-relative exact path, not an absolute path."
    }
    if (Test-BroadRepoRootPath -Path $Path) {
        throw "$Context rejects broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $Path) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if (Test-DirectoryOnlyPath -Path $Path) {
        throw "$Context rejects directory-only path '$Path'."
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

function Assert-DependencyRef {
    param(
        [Parameter(Mandatory = $true)]$Ref,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in @("ref_id", "path", "authority_level", "proof_status", "deterministic_order")) {
        Get-RequiredProperty -Object $Ref -Name $field -Context $Context | Out-Null
    }

    Assert-NonEmptyString -Value $Ref.ref_id -Context "$Context ref_id" | Out-Null
    $path = Assert-NonEmptyString -Value $Ref.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    if ($Ref.authority_level -notin $script:RequiredAuthorityLevels) {
        throw "$Context authority_level '$($Ref.authority_level)' is not allowed."
    }
    if ($Ref.proof_status -notin $script:RequiredProofStatuses) {
        throw "$Context proof_status '$($Ref.proof_status)' is not allowed."
    }
    $order = Assert-IntegerValue -Value $Ref.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
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
        "exact_ref_required",
        "directory_only_proof_claims_require_exact_files",
        "stale_generated_from_refs_detected_and_caveated"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @(
        "wildcard_path_claims_allowed",
        "broad_repo_root_claims_allowed",
        "full_repo_scan_claims_allowed",
        "directory_only_proof_claims_allowed_without_exact_files",
        "stale_generated_from_refs_hidden"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-AuditMapGenerationPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @("deterministic_ordering_required", "future_generated_audit_map_requires_dedicated_r16_012_generator")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @(
        "r16_011_generates_audit_map",
        "r16_011_implements_generator_logic",
        "audit_map_generator_exists",
        "r15_r16_audit_map_generated",
        "generated_audit_maps_are_runtime_memory",
        "generated_audit_maps_are_product_runtime",
        "generated_audit_maps_close_r13",
        "generated_audit_maps_remove_r14_caveats",
        "generated_audit_maps_remove_r15_caveats"
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
    $categories = Assert-StringArray -Value (Get-RequiredProperty -Object $policyObject -Name "treatment_categories" -Context $Context) -Context "$Context treatment_categories"
    Assert-RequiredValuesPresent -Values $categories -RequiredValues $script:RequiredProofTreatmentCategories -Context "$Context treatment_categories"

    foreach ($falseField in @(
        "generated_reports_as_machine_proof_allowed",
        "operator_reports_as_machine_proof_allowed",
        "planning_artifacts_as_implementation_proof_allowed",
        "local_only_evidence_allowed_for_closeout",
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

function Assert-OverclaimDetectionPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    $claimFlags = Assert-ObjectValue -Value (Get-RequiredProperty -Object $policyObject -Name "claim_flags" -Context $Context) -Context "$Context claim_flags"
    Assert-FalseFields -Object $claimFlags -Fields $script:RequiredRejectedClaimFlags -Context "$Context claim_flags"
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-011") {
        throw "$Context active_through_task must be R16-011."
    }

    $completeTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "complete_tasks" -Context $Context) -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "planned_tasks" -Context $Context) -Context "$Context planned_tasks"
    Assert-ExactStringSet -Values $completeTasks -ExpectedValues @("R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006", "R16-007", "R16-008", "R16-009", "R16-010", "R16-011") -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues @("R16-012", "R16-013", "R16-014", "R16-015", "R16-016", "R16-017", "R16-018", "R16-019", "R16-020", "R16-021", "R16-022", "R16-023", "R16-024", "R16-025", "R16-026") -Context "$Context planned_tasks"

    foreach ($task in $completeTasks) {
        if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 12) {
            throw "$Context claims R16-012 or later implementation."
        }
    }
    foreach ($task in $plannedTasks) {
        if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task."
        }
    }

    foreach ($falseField in @("r16_012_or_later_implementation_claimed", "r16_027_or_later_task_exists")) {
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
            Assert-PresentFalseFields -Object $flags -Fields $script:RequiredRejectedClaimFlags -Context "$SourceLabel overclaim_detection_policy claim_flags"
        }
    }
    if (Test-HasProperty -Object $Contract -Name "exact_ref_policy") {
        $policy = Assert-ObjectValue -Value $Contract.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
        Assert-PresentFalseFields -Object $policy -Fields @(
            "wildcard_path_claims_allowed",
            "broad_repo_root_claims_allowed",
            "full_repo_scan_claims_allowed",
            "directory_only_proof_claims_allowed_without_exact_files",
            "stale_generated_from_refs_hidden"
        ) -Context "$SourceLabel exact_ref_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "audit_map_generation_policy") {
        $policy = Assert-ObjectValue -Value $Contract.audit_map_generation_policy -Context "$SourceLabel audit_map_generation_policy"
        Assert-PresentFalseFields -Object $policy -Fields @(
            "r16_011_generates_audit_map",
            "r16_011_implements_generator_logic",
            "audit_map_generator_exists",
            "r15_r16_audit_map_generated",
            "generated_audit_maps_are_runtime_memory",
            "generated_audit_maps_are_product_runtime",
            "generated_audit_maps_close_r13",
            "generated_audit_maps_remove_r14_caveats",
            "generated_audit_maps_remove_r15_caveats"
        ) -Context "$SourceLabel audit_map_generation_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "proof_treatment_policy") {
        $policy = Assert-ObjectValue -Value $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"
        Assert-PresentFalseFields -Object $policy -Fields @(
            "generated_reports_as_machine_proof_allowed",
            "operator_reports_as_machine_proof_allowed",
            "planning_artifacts_as_implementation_proof_allowed",
            "local_only_evidence_allowed_for_closeout",
            "runtime_product_claims_allowed_without_later_evidence"
        ) -Context "$SourceLabel proof_treatment_policy"
    }
    if (Test-HasProperty -Object $Contract -Name "current_posture") {
        $posture = Assert-ObjectValue -Value $Contract.current_posture -Context "$SourceLabel current_posture"
        if (Test-HasProperty -Object $posture -Name "complete_tasks") {
            $completeTasks = Assert-StringArray -Value $posture.complete_tasks -Context "$SourceLabel current_posture complete_tasks" -AllowEmpty
            foreach ($task in $completeTasks) {
                if ($task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 12) {
                    throw "$SourceLabel current_posture claims R16-012 or later implementation."
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
        Assert-PresentFalseFields -Object $posture -Fields @("r16_012_or_later_implementation_claimed", "r16_027_or_later_task_exists") -Context "$SourceLabel current_posture"
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

function Test-R16AuditMapContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [string]$SourceLabel = "R16 audit map contract",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Invoke-EarlyOverclaimChecks -Contract $Contract -SourceLabel $SourceLabel

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Contract -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_audit_map_contract") {
        throw "$SourceLabel artifact_type must be r16_audit_map_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.audit_map_contract_id -ne "aioffice-r16-011-audit-map-contract-v1") {
        throw "$SourceLabel audit_map_contract_id must be aioffice-r16-011-audit-map-contract-v1."
    }
    if ($Contract.source_milestone -ne $script:R16Milestone) {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Contract.source_task -ne "R16-011") {
        throw "$SourceLabel source_task must be R16-011."
    }
    if ($Contract.repository -ne $script:Repository) {
        throw "$SourceLabel repository must be $script:Repository."
    }
    if ($Contract.branch -ne $script:Branch) {
        throw "$SourceLabel branch must be $script:Branch."
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
    $dependencyPaths = @()
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-DependencyRef -Ref $dependencyRefs[$index] -Context "$SourceLabel dependency_refs[$index]" -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1)
        $dependencyPaths += [string]$dependencyRefs[$index].path
    }
    Assert-RequiredValuesPresent -Values $dependencyPaths -RequiredValues $script:RequiredDependencyPaths -Context "$SourceLabel dependency_refs paths"

    Assert-RequiredSchemaFields -Schema $Contract.audit_map_entry_schema -RequiredFields $script:RequiredAuditMapEntryFields -Context "$SourceLabel audit_map_entry_schema"
    $authorityLevels = @($Contract.authority_level_taxonomy | ForEach-Object { [string]$_.authority_level })
    Assert-RequiredValuesPresent -Values $authorityLevels -RequiredValues $script:RequiredAuthorityLevels -Context "$SourceLabel authority_level_taxonomy"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $Contract.proof_status_values -Context "$SourceLabel proof_status_values") -RequiredValues $script:RequiredProofStatuses -Context "$SourceLabel proof_status_values"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $Contract.audit_readiness_status_values -Context "$SourceLabel audit_readiness_status_values") -RequiredValues $script:RequiredAuditReadinessStatuses -Context "$SourceLabel audit_readiness_status_values"
    Assert-RequiredSchemaFields -Schema $Contract.inspection_route_schema -RequiredFields $script:RequiredInspectionRouteFields -Context "$SourceLabel inspection_route_schema"
    Assert-RequiredSchemaFields -Schema $Contract.caveat_schema -RequiredFields $script:RequiredCaveatFields -Context "$SourceLabel caveat_schema"
    Assert-RequiredSchemaFields -Schema $Contract.validation_command_schema -RequiredFields $script:RequiredValidationCommandFields -Context "$SourceLabel validation_command_schema"
    Assert-ExactRefPolicy -Policy $Contract.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
    Assert-AuditMapGenerationPolicy -Policy $Contract.audit_map_generation_policy -Context "$SourceLabel audit_map_generation_policy"
    Assert-ProofTreatmentPolicy -Policy $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"
    Assert-OverclaimDetectionPolicy -Policy $Contract.overclaim_detection_policy -Context "$SourceLabel overclaim_detection_policy"
    Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $commands = Assert-ObjectArray -Value $Contract.validation_commands -Context "$SourceLabel validation_commands"
    for ($index = 0; $index -lt $commands.Count; $index += 1) {
        $command = $commands[$index]
        foreach ($field in $script:RequiredValidationCommandFields) {
            Get-RequiredProperty -Object $command -Name $field -Context "$SourceLabel validation_commands[$index]" | Out-Null
        }
        $order = Assert-IntegerValue -Value $command.deterministic_order -Context "$SourceLabel validation_commands[$index] deterministic_order"
        if ($order -ne ($index + 1)) {
            throw "$SourceLabel validation_commands[$index] deterministic_order must be $($index + 1)."
        }
    }

    $nonClaims = Assert-StringArray -Value $Contract.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ContractId = $Contract.audit_map_contract_id
        SourceTask = $Contract.source_task
        ActiveThroughTask = $Contract.current_posture.active_through_task
        PlannedTaskStart = $Contract.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Contract.current_posture.planned_tasks[-1]
        ContractOnly = [bool]$mode.contract_only
        GeneratedAuditMap = [bool]$mode.generated_audit_map
        AuditMapGenerator = [bool]$mode.audit_map_generator
        R15R16AuditMapGenerated = [bool]$mode.r15_r16_audit_map_generated
        ArtifactMapDiffTooling = [bool]$mode.artifact_map_diff_tooling
        ContextLoadPlanner = [bool]$mode.context_load_planner
        RoleRunEnvelope = [bool]$mode.role_run_envelope
        HandoffPacket = [bool]$mode.handoff_packet
        WorkflowDrill = [bool]$mode.workflow_drill
        RuntimeMemory = [bool]$mode.runtime_memory
        ProductRuntime = [bool]$mode.product_runtime
        AutonomousAgents = [bool]$mode.autonomous_agents
        ExternalIntegrations = [bool]$mode.external_integrations
        R16012OrLaterClaimed = [bool]$Contract.current_posture.r16_012_or_later_implementation_claimed
        R16027OrLaterTaskExists = [bool]$Contract.current_posture.r16_027_or_later_task_exists
        R13Closed = [bool]$Contract.preserved_boundaries.r13.closed
        R14CaveatsRemoved = [bool]$Contract.preserved_boundaries.r14.caveats_removed
        R15CaveatsRemoved = [bool]$Contract.preserved_boundaries.r15.caveats_removed
        DependencyRefCount = $dependencyRefs.Count
        AuthorityLevelCount = $authorityLevels.Count
        ProofStatusCount = @($Contract.proof_status_values).Count
        AuditReadinessStatusCount = @($Contract.audit_readiness_status_values).Count
    }
}

function Test-R16AuditMapContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/audit/r16_audit_map.contract.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        $Path
    }
    else {
        Join-Path $resolvedRepositoryRoot $Path
    }

    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 audit map contract"
    return Test-R16AuditMapContractObject -Contract $contract -SourceLabel $Path -RepositoryRoot $resolvedRepositoryRoot
}

Export-ModuleMember -Function Test-R16AuditMapContract, Test-R16AuditMapContractObject
