Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "artifact_map_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "contract_mode",
    "dependency_refs",
    "allowed_artifact_classes",
    "allowed_artifact_roles",
    "allowed_authority_classes",
    "allowed_evidence_kinds",
    "allowed_lifecycle_states",
    "allowed_proof_statuses",
    "artifact_record_schema",
    "source_ref_schema",
    "relationship_schema",
    "inspection_route_schema",
    "caveat_schema",
    "exact_path_policy",
    "deterministic_ordering_policy",
    "stale_ref_policy",
    "proof_treatment_policy",
    "overclaim_rejection_policy",
    "current_posture",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules",
    "contract_model_records",
    "contract_model_relationships"
)

$script:ExpectedArtifactClasses = @(
    "governance_document",
    "authority_document",
    "contract",
    "tool",
    "cli_wrapper",
    "test",
    "fixture",
    "state_artifact",
    "proof_review_package",
    "validation_manifest",
    "report",
    "operator_artifact",
    "generated_artifact",
    "external_evidence",
    "deprecated_context",
    "cleanup_candidate",
    "unknown"
)

$script:ExpectedArtifactRoles = @(
    "constitutional_authority",
    "governance_authority",
    "milestone_authority",
    "planning_authority",
    "contract_authority",
    "validation_tool",
    "generation_tool",
    "focused_test",
    "valid_fixture",
    "invalid_fixture",
    "committed_state",
    "proof_manifest",
    "proof_review",
    "operator_report",
    "evidence_context",
    "non_claim_record",
    "stale_ref_caveat",
    "dependency_ref",
    "source_ref",
    "inspection_target"
)

$script:ExpectedAuthorityClasses = @(
    "constitutional_authority",
    "governance_authority",
    "milestone_authority",
    "contract_authority",
    "state_authority",
    "proof_authority",
    "report_context",
    "operator_context",
    "external_evidence_context",
    "deprecated_context",
    "unknown_authority"
)

$script:ExpectedEvidenceKinds = @(
    "committed_machine_evidence",
    "contract_schema",
    "validator_module",
    "cli_wrapper",
    "focused_test",
    "valid_fixture",
    "invalid_fixture",
    "generated_state_artifact",
    "validation_manifest",
    "proof_review_package",
    "operator_report",
    "external_replay",
    "narrative_context",
    "stale_ref_caveat",
    "non_claim",
    "rejected_claim"
)

$script:ExpectedLifecycleStates = @(
    "active",
    "current",
    "planned",
    "superseded",
    "deprecated",
    "cleanup_candidate",
    "historical",
    "unknown"
)

$script:ExpectedProofStatuses = @(
    "proof_by_itself_true",
    "proof_by_itself_false",
    "proof_if_validator_backed",
    "proof_if_external_replay_backed",
    "context_only",
    "rejected_as_overclaim",
    "stale_with_caveat",
    "stale_without_caveat_rejected",
    "unknown"
)

$script:RequiredArtifactRecordFields = @(
    "artifact_id",
    "path",
    "artifact_class",
    "artifact_role",
    "authority_class",
    "evidence_kind",
    "lifecycle_state",
    "proof_status",
    "source_task",
    "source_milestone",
    "owner_role",
    "source_refs",
    "dependency_refs",
    "generated_from_head",
    "generated_from_tree",
    "exact_path_only",
    "broad_scan_allowed",
    "wildcard_allowed",
    "inspection_route",
    "caveats",
    "non_claims",
    "deterministic_order"
)

$script:RequiredSourceRefFields = @(
    "ref_id",
    "path",
    "source_task",
    "source_milestone",
    "artifact_class",
    "authority_class",
    "evidence_kind",
    "proof_status",
    "exact_path_only",
    "broad_scan_allowed",
    "wildcard_allowed",
    "stale_state",
    "caveat_id",
    "generated_from_head",
    "generated_from_tree",
    "machine_proof",
    "implementation_proof"
)

$script:RequiredRelationshipFields = @(
    "relationship_id",
    "relationship_type",
    "from_artifact_id",
    "to_artifact_id",
    "dependency_kind",
    "required",
    "evidence_kind",
    "proof_status",
    "deterministic_order"
)

$script:RequiredInspectionRouteFields = @(
    "route_id",
    "route_kind",
    "path",
    "expected_reader_role",
    "exact_command",
    "broad_scan_allowed",
    "wildcard_allowed",
    "fallback_route",
    "inspection_notes"
)

$script:RequiredCaveatFields = @(
    "caveat_id",
    "caveat_type",
    "applies_to_ref_id",
    "applies_to_path",
    "declared_boundary",
    "observed_boundary",
    "accepted_reason",
    "preserved_scope",
    "deterministic_order"
)

$script:RequiredContractModeFalseFields = @(
    "artifact_map_generation_claimed",
    "artifact_map_generator_claimed",
    "generated_artifact_map_exists",
    "operational_artifact_map_generated",
    "artifact_map_generator_implemented",
    "audit_map_implemented",
    "context_load_planner_implemented",
    "context_budget_estimator_implemented",
    "role_run_envelope_implemented",
    "raci_transition_gate_implemented",
    "handoff_packet_implemented",
    "workflow_drill_run",
    "runtime_memory_implemented",
    "runtime_memory_loading_implemented",
    "persistent_memory_runtime_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "product_runtime_implemented",
    "productized_ui_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "external_integrations_implemented"
)

$script:RequiredPostureFalseFields = @(
    "r16_010_or_later_implementation_claimed",
    "r16_027_or_later_task_exists",
    "artifact_map_generation_claimed",
    "artifact_map_generator_claimed",
    "generated_artifact_map_exists",
    "artifact_map_contract_treated_as_generated_artifact_map",
    "artifact_map_generator_implemented",
    "audit_map_implemented",
    "context_load_planner_implemented",
    "context_budget_estimator_implemented",
    "role_run_envelope_implemented",
    "raci_transition_gate_implemented",
    "handoff_packet_implemented",
    "workflow_drill_run",
    "product_runtime_implemented",
    "productized_ui_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "persistent_memory_runtime_implemented",
    "runtime_memory_implemented",
    "runtime_memory_loading_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "external_integrations_implemented",
    "main_merge_completed",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "r13_closure_claimed",
    "r14_caveat_removed",
    "r15_caveat_removed",
    "r13_partial_gate_conversion_claimed"
)

$script:RequiredOverclaimFalseFields = @(
    "artifact_map_generation_claimed",
    "artifact_map_generator_claimed",
    "generated_artifact_map_claimed",
    "artifact_map_contract_treated_as_generated_artifact_map",
    "audit_map_claimed",
    "context_load_planner_claimed",
    "context_budget_estimator_claimed",
    "role_run_envelope_claimed",
    "raci_transition_gate_claimed",
    "handoff_packet_claimed",
    "workflow_drill_claimed",
    "runtime_memory_claimed",
    "runtime_memory_loading_claimed",
    "persistent_memory_runtime_claimed",
    "retrieval_runtime_claimed",
    "vector_search_runtime_claimed",
    "actual_autonomous_agents_claimed",
    "true_multi_agent_execution_claimed",
    "product_runtime_claimed",
    "productized_ui_claimed",
    "external_integration_claimed",
    "main_merge_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r16_010_implementation_claimed",
    "r16_027_or_later_task_exists",
    "r13_closure_claimed",
    "r14_caveat_removed",
    "r15_caveat_removed",
    "r13_partial_gate_conversion_claimed"
)

$script:RequiredValidationCommands = @(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_artifact_map_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_artifact_map_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_pack_validation.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_pack_validation_report.ps1 -ReportPath state\memory\r16_memory_pack_validation_report.json -MemoryLayersPath state\memory\r16_memory_layers.json -RoleModelPath state\memory\r16_role_memory_pack_model.json -RolePacksPath state\memory\r16_role_memory_packs.json -ContractPath contracts\memory\r16_memory_pack_validation_report.contract.json",
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
    "missing_path_rejected",
    "unknown_artifact_class_rejected",
    "unknown_artifact_role_rejected",
    "unknown_authority_class_rejected",
    "unknown_evidence_kind_rejected",
    "unknown_lifecycle_state_rejected",
    "unknown_proof_status_rejected",
    "broad_repo_root_path_rejected",
    "wildcard_path_rejected",
    "generated_report_as_machine_proof_rejected",
    "planning_report_as_implementation_proof_rejected",
    "stale_ref_without_caveat_rejected",
    "missing_inspection_route_rejected",
    "duplicate_artifact_id_rejected",
    "non_deterministic_ordering_rejected",
    "artifact_map_generation_claim_rejected",
    "artifact_map_generator_claim_rejected",
    "audit_map_claim_rejected",
    "context_load_planner_claim_rejected",
    "runtime_memory_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "product_runtime_claim_rejected",
    "external_integration_claim_rejected",
    "r16_010_implementation_claim_rejected",
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
    "no R16-010 implementation",
    "no R16-027 or later task",
    "no generated artifact map",
    "no artifact map generator",
    "no audit map",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "artifact map contract is model/contract proof only",
    "artifact map contract is not a generated artifact map",
    "artifact map contract is not runtime memory",
    "artifact map contract is not retrieval or vector runtime",
    "artifact map contract is not audit execution",
    "artifact map contract is not workflow execution"
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

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return $Path -match '[\*\?]'
}

function Test-PlanningReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized -in @(
        "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
        "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"
    )
}

function Test-GeneratedReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return $Path.Trim().Replace("\", "/") -like "governance/reports/*"
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireExists
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        throw "$Context path must be a repo-relative exact path, not an absolute path."
    }
    if (Test-BroadRepoRootPath -Path $Path) {
        throw "$Context path rejects broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $Path) {
        throw "$Context path rejects wildcard path '$Path'."
    }
    if ($Path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context path must not traverse outside the repository."
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path must remain inside the repository."
    }

    if ($RequireExists -and -not (Test-Path -LiteralPath $resolved)) {
        throw "$Context path '$Path' does not exist."
    }

    return $resolved
}

function Assert-PathPolicyFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $Object -Name "exact_path_only" -Context $Context) -Context "$Context exact_path_only") -ne $true) {
        throw "$Context exact_path_only must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $Object -Name "broad_scan_allowed" -Context $Context) -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $Object -Name "wildcard_allowed" -Context $Context) -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
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
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-009") {
        throw "$Context active_through_task must be R16-009."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    $allTasks = @($completeTasks) + @($plannedTasks)
    foreach ($taskId in $allTasks) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in @($completeTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 10) {
            throw "$Context claims R16-010 implementation with '$taskId'."
        }
    }

    $expectedCompleteTasks = @(1..9 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
    $expectedPlannedTasks = @(10..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
    Assert-ExactStringSet -Values $completeTasks -ExpectedValues $expectedCompleteTasks -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues $expectedPlannedTasks -Context "$Context planned_tasks"
    Assert-FalseFields -Object $postureObject -Fields $script:RequiredPostureFalseFields -Context $Context
}

function Assert-ProofTreatmentForPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ArtifactClass,
        [Parameter(Mandatory = $true)][string]$EvidenceKind,
        [Parameter(Mandatory = $true)][string]$ProofStatus,
        [Parameter(Mandatory = $true)][bool]$MachineProof,
        [Parameter(Mandatory = $true)][bool]$ImplementationProof,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ((Test-PlanningReportPath -Path $Path) -and ($ImplementationProof -or $ProofStatus -eq "proof_by_itself_true")) {
        throw "$Context planning report treated as implementation proof is rejected."
    }
    if ((Test-GeneratedReportPath -Path $Path) -and ($MachineProof -or $EvidenceKind -eq "committed_machine_evidence" -or $ProofStatus -eq "proof_by_itself_true")) {
        throw "$Context generated report treated as machine proof is rejected."
    }
    if ($ArtifactClass -eq "report" -and ($MachineProof -or $ProofStatus -eq "proof_by_itself_true")) {
        throw "$Context generated report treated as machine proof is rejected."
    }
}

function Assert-SourceRef {
    param(
        [Parameter(Mandatory = $true)]$SourceRef,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [AllowEmptyCollection()][string[]]$CaveatIds
    )

    foreach ($field in $script:RequiredSourceRefFields) {
        Get-RequiredProperty -Object $SourceRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $SourceRef.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireExists | Out-Null
    Assert-PathPolicyFields -Object $SourceRef -Context $Context

    if ($SourceRef.artifact_class -notin $script:ExpectedArtifactClasses) {
        throw "$Context artifact_class '$($SourceRef.artifact_class)' is not allowed."
    }
    if ($SourceRef.authority_class -notin $script:ExpectedAuthorityClasses) {
        throw "$Context authority_class '$($SourceRef.authority_class)' is not allowed."
    }
    if ($SourceRef.evidence_kind -notin $script:ExpectedEvidenceKinds) {
        throw "$Context evidence_kind '$($SourceRef.evidence_kind)' is not allowed."
    }
    if ($SourceRef.proof_status -notin $script:ExpectedProofStatuses) {
        throw "$Context proof_status '$($SourceRef.proof_status)' is not allowed."
    }

    $machineProof = Assert-BooleanValue -Value $SourceRef.machine_proof -Context "$Context machine_proof"
    $implementationProof = Assert-BooleanValue -Value $SourceRef.implementation_proof -Context "$Context implementation_proof"
    Assert-ProofTreatmentForPath -Path $path -ArtifactClass $SourceRef.artifact_class -EvidenceKind $SourceRef.evidence_kind -ProofStatus $SourceRef.proof_status -MachineProof $machineProof -ImplementationProof $implementationProof -Context $Context

    $staleState = Assert-NonEmptyString -Value $SourceRef.stale_state -Context "$Context stale_state"
    if ($staleState -notin @("fresh", "stale_with_caveat", "stale_without_caveat_rejected")) {
        throw "$Context stale_state '$staleState' is not allowed."
    }
    if ($staleState -eq "stale_without_caveat_rejected") {
        throw "$Context stale ref without caveat is rejected."
    }
    if ($staleState -eq "stale_with_caveat") {
        $caveatId = Assert-NonEmptyString -Value $SourceRef.caveat_id -Context "$Context caveat_id"
        if ($CaveatIds -notcontains $caveatId) {
            throw "$Context stale ref without caveat is rejected."
        }
    }
}

function Assert-DependencyRef {
    param(
        [Parameter(Mandatory = $true)]$DependencyRef,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    foreach ($field in @("ref_id", "path", "artifact_class", "artifact_role", "authority_class", "evidence_kind", "source_task", "source_milestone", "proof_status", "exact_path_only", "broad_scan_allowed", "wildcard_allowed", "stale_state", "caveat_id", "generated_from_head", "generated_from_tree")) {
        Get-RequiredProperty -Object $DependencyRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $DependencyRef.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireExists | Out-Null
    Assert-PathPolicyFields -Object $DependencyRef -Context $Context
    if ($DependencyRef.artifact_class -notin $script:ExpectedArtifactClasses) {
        throw "$Context artifact_class '$($DependencyRef.artifact_class)' is not allowed."
    }
    if ($DependencyRef.artifact_role -notin $script:ExpectedArtifactRoles) {
        throw "$Context artifact_role '$($DependencyRef.artifact_role)' is not allowed."
    }
    if ($DependencyRef.authority_class -notin $script:ExpectedAuthorityClasses) {
        throw "$Context authority_class '$($DependencyRef.authority_class)' is not allowed."
    }
    if ($DependencyRef.evidence_kind -notin $script:ExpectedEvidenceKinds) {
        throw "$Context evidence_kind '$($DependencyRef.evidence_kind)' is not allowed."
    }
    if ($DependencyRef.proof_status -notin $script:ExpectedProofStatuses) {
        throw "$Context proof_status '$($DependencyRef.proof_status)' is not allowed."
    }
    if ($DependencyRef.stale_state -eq "stale_without_caveat_rejected") {
        throw "$Context stale ref without caveat is rejected."
    }
}

function Assert-InspectionRoute {
    param(
        [Parameter(Mandatory = $true)]$Route,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    foreach ($field in $script:RequiredInspectionRouteFields) {
        Get-RequiredProperty -Object $Route -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $Route.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireExists | Out-Null
    if ((Assert-BooleanValue -Value $Route.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $Route.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }
}

function Assert-Caveat {
    param(
        [Parameter(Mandatory = $true)]$Caveat,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredCaveatFields) {
        Get-RequiredProperty -Object $Caveat -Name $field -Context $Context | Out-Null
    }
    Assert-SafeRepoRelativePath -Path (Assert-NonEmptyString -Value $Caveat.applies_to_path -Context "$Context applies_to_path") -RepositoryRoot $RepositoryRoot -Context $Context -RequireExists | Out-Null
    $order = Assert-IntegerValue -Value $Caveat.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic ordering."
    }
}

function Assert-ArtifactRecord {
    param(
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredArtifactRecordFields) {
        Get-RequiredProperty -Object $Record -Name $field -Context $Context | Out-Null
    }

    $artifactId = Assert-NonEmptyString -Value $Record.artifact_id -Context "$Context artifact_id"
    $path = Assert-NonEmptyString -Value $Record.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireExists | Out-Null
    Assert-PathPolicyFields -Object $Record -Context $Context

    if ($Record.artifact_class -notin $script:ExpectedArtifactClasses) {
        throw "$Context artifact_class '$($Record.artifact_class)' is not allowed."
    }
    if ($Record.artifact_role -notin $script:ExpectedArtifactRoles) {
        throw "$Context artifact_role '$($Record.artifact_role)' is not allowed."
    }
    if ($Record.authority_class -notin $script:ExpectedAuthorityClasses) {
        throw "$Context authority_class '$($Record.authority_class)' is not allowed."
    }
    if ($Record.evidence_kind -notin $script:ExpectedEvidenceKinds) {
        throw "$Context evidence_kind '$($Record.evidence_kind)' is not allowed."
    }
    if ($Record.lifecycle_state -notin $script:ExpectedLifecycleStates) {
        throw "$Context lifecycle_state '$($Record.lifecycle_state)' is not allowed."
    }
    if ($Record.proof_status -notin $script:ExpectedProofStatuses) {
        throw "$Context proof_status '$($Record.proof_status)' is not allowed."
    }

    $order = Assert-IntegerValue -Value $Record.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic ordering."
    }

    Assert-ProofTreatmentForPath -Path $path -ArtifactClass $Record.artifact_class -EvidenceKind $Record.evidence_kind -ProofStatus $Record.proof_status -MachineProof:($Record.proof_status -eq "proof_by_itself_true") -ImplementationProof:($Record.proof_status -eq "proof_by_itself_true") -Context $Context

    $caveats = Assert-ObjectArray -Value $Record.caveats -Context "$Context caveats" -AllowEmpty
    $caveatIds = @()
    for ($index = 0; $index -lt $caveats.Count; $index += 1) {
        Assert-Caveat -Caveat $caveats[$index] -Context "$Context caveats[$index]" -RepositoryRoot $RepositoryRoot -ExpectedOrder ($index + 1)
        $caveatIds += [string]$caveats[$index].caveat_id
    }
    if ($Record.proof_status -eq "stale_without_caveat_rejected") {
        throw "$Context stale ref without caveat is rejected."
    }
    if ($Record.proof_status -eq "stale_with_caveat" -and $caveatIds.Count -eq 0) {
        throw "$Context stale ref without caveat is rejected."
    }

    $inspectionRoute = Assert-ObjectValue -Value $Record.inspection_route -Context "$Context inspection_route"
    Assert-InspectionRoute -Route $inspectionRoute -Context "$Context inspection_route" -RepositoryRoot $RepositoryRoot

    $sourceRefs = Assert-ObjectArray -Value $Record.source_refs -Context "$Context source_refs"
    for ($index = 0; $index -lt $sourceRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $sourceRefs[$index] -Context "$Context source_refs[$index]" -RepositoryRoot $RepositoryRoot -CaveatIds $caveatIds
    }

    $dependencyRefs = Assert-ObjectArray -Value $Record.dependency_refs -Context "$Context dependency_refs" -AllowEmpty
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-DependencyRef -DependencyRef $dependencyRefs[$index] -Context "$Context dependency_refs[$index]" -RepositoryRoot $RepositoryRoot
    }

    Assert-StringArray -Value $Record.non_claims -Context "$Context non_claims" | Out-Null
    return $artifactId
}

function Assert-Relationship {
    param(
        [Parameter(Mandatory = $true)]$Relationship,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string[]]$ArtifactIds,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredRelationshipFields) {
        Get-RequiredProperty -Object $Relationship -Name $field -Context $Context | Out-Null
    }

    if ($ArtifactIds -notcontains [string]$Relationship.from_artifact_id -or $ArtifactIds -notcontains [string]$Relationship.to_artifact_id) {
        throw "$Context relationship endpoints must reference known artifact ids."
    }
    if ($Relationship.evidence_kind -notin $script:ExpectedEvidenceKinds) {
        throw "$Context evidence_kind '$($Relationship.evidence_kind)' is not allowed."
    }
    if ($Relationship.proof_status -notin $script:ExpectedProofStatuses) {
        throw "$Context proof_status '$($Relationship.proof_status)' is not allowed."
    }
    if ((Assert-BooleanValue -Value $Relationship.required -Context "$Context required") -ne $true) {
        throw "$Context required must be True."
    }
    $order = Assert-IntegerValue -Value $Relationship.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic ordering."
    }
}

function Test-R16ArtifactMapContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [string]$SourceLabel = "R16 artifact map contract",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Contract -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_artifact_map_contract") {
        throw "$SourceLabel artifact_type must be r16_artifact_map_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.source_milestone -ne "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation") {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Contract.source_task -ne "R16-009") {
        throw "$SourceLabel source_task must be R16-009."
    }
    if ($Contract.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Contract.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }
    Assert-NonEmptyString -Value $Contract.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Contract.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    $mode = Assert-ObjectValue -Value $Contract.contract_mode -Context "$SourceLabel contract_mode"
    if ($mode.mode -ne "artifact_map_contract_only_not_generated_map") {
        throw "$SourceLabel contract_mode mode must be artifact_map_contract_only_not_generated_map."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "contract_only" -Context "$SourceLabel contract_mode") -Context "$SourceLabel contract_mode contract_only") -ne $true) {
        throw "$SourceLabel contract_mode contract_only must be True."
    }
    Assert-FalseFields -Object $mode -Fields $script:RequiredContractModeFalseFields -Context "$SourceLabel contract_mode"

    $allowedArtifactClasses = Assert-StringArray -Value $Contract.allowed_artifact_classes -Context "$SourceLabel allowed_artifact_classes"
    Assert-ExactStringSet -Values $allowedArtifactClasses -ExpectedValues $script:ExpectedArtifactClasses -Context "$SourceLabel allowed_artifact_classes"
    $allowedArtifactRoles = Assert-StringArray -Value $Contract.allowed_artifact_roles -Context "$SourceLabel allowed_artifact_roles"
    Assert-ExactStringSet -Values $allowedArtifactRoles -ExpectedValues $script:ExpectedArtifactRoles -Context "$SourceLabel allowed_artifact_roles"
    $allowedAuthorityClasses = Assert-StringArray -Value $Contract.allowed_authority_classes -Context "$SourceLabel allowed_authority_classes"
    Assert-ExactStringSet -Values $allowedAuthorityClasses -ExpectedValues $script:ExpectedAuthorityClasses -Context "$SourceLabel allowed_authority_classes"
    $allowedEvidenceKinds = Assert-StringArray -Value $Contract.allowed_evidence_kinds -Context "$SourceLabel allowed_evidence_kinds"
    Assert-ExactStringSet -Values $allowedEvidenceKinds -ExpectedValues $script:ExpectedEvidenceKinds -Context "$SourceLabel allowed_evidence_kinds"
    $allowedLifecycleStates = Assert-StringArray -Value $Contract.allowed_lifecycle_states -Context "$SourceLabel allowed_lifecycle_states"
    Assert-ExactStringSet -Values $allowedLifecycleStates -ExpectedValues $script:ExpectedLifecycleStates -Context "$SourceLabel allowed_lifecycle_states"
    $allowedProofStatuses = Assert-StringArray -Value $Contract.allowed_proof_statuses -Context "$SourceLabel allowed_proof_statuses"
    Assert-ExactStringSet -Values $allowedProofStatuses -ExpectedValues $script:ExpectedProofStatuses -Context "$SourceLabel allowed_proof_statuses"

    $artifactSchema = Assert-ObjectValue -Value $Contract.artifact_record_schema -Context "$SourceLabel artifact_record_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $artifactSchema.required_fields -Context "$SourceLabel artifact_record_schema required_fields") -RequiredValues $script:RequiredArtifactRecordFields -Context "$SourceLabel artifact_record_schema required_fields"
    $sourceRefSchema = Assert-ObjectValue -Value $Contract.source_ref_schema -Context "$SourceLabel source_ref_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $sourceRefSchema.required_fields -Context "$SourceLabel source_ref_schema required_fields") -RequiredValues $script:RequiredSourceRefFields -Context "$SourceLabel source_ref_schema required_fields"
    $relationshipSchema = Assert-ObjectValue -Value $Contract.relationship_schema -Context "$SourceLabel relationship_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $relationshipSchema.required_fields -Context "$SourceLabel relationship_schema required_fields") -RequiredValues $script:RequiredRelationshipFields -Context "$SourceLabel relationship_schema required_fields"
    $inspectionRouteSchema = Assert-ObjectValue -Value $Contract.inspection_route_schema -Context "$SourceLabel inspection_route_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $inspectionRouteSchema.required_fields -Context "$SourceLabel inspection_route_schema required_fields") -RequiredValues $script:RequiredInspectionRouteFields -Context "$SourceLabel inspection_route_schema required_fields"
    $caveatSchema = Assert-ObjectValue -Value $Contract.caveat_schema -Context "$SourceLabel caveat_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $caveatSchema.required_fields -Context "$SourceLabel caveat_schema required_fields") -RequiredValues $script:RequiredCaveatFields -Context "$SourceLabel caveat_schema required_fields"

    $exactPathPolicy = Assert-ObjectValue -Value $Contract.exact_path_policy -Context "$SourceLabel exact_path_policy"
    foreach ($trueField in @("repo_relative_exact_paths_required", "missing_path_rejected", "broad_repo_root_path_rejected", "wildcard_path_rejected")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $exactPathPolicy -Name $trueField -Context "$SourceLabel exact_path_policy") -Context "$SourceLabel exact_path_policy $trueField") -ne $true) {
            throw "$SourceLabel exact_path_policy $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_scan_allowed", "wildcard_allowed", "full_repo_scan_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $exactPathPolicy -Name $falseField -Context "$SourceLabel exact_path_policy") -Context "$SourceLabel exact_path_policy $falseField") -ne $false) {
            throw "$SourceLabel exact_path_policy $falseField must be False."
        }
    }

    $deterministicPolicy = Assert-ObjectValue -Value $Contract.deterministic_ordering_policy -Context "$SourceLabel deterministic_ordering_policy"
    foreach ($trueField in @("deterministic_output_required", "records_sorted_by_deterministic_order", "relationships_sorted_by_deterministic_order", "duplicate_artifact_ids_rejected", "non_deterministic_ordering_rejected")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $deterministicPolicy -Name $trueField -Context "$SourceLabel deterministic_ordering_policy") -Context "$SourceLabel deterministic_ordering_policy $trueField") -ne $true) {
            throw "$SourceLabel deterministic_ordering_policy $trueField must be True."
        }
    }

    $stalePolicy = Assert-ObjectValue -Value $Contract.stale_ref_policy -Context "$SourceLabel stale_ref_policy"
    if ($stalePolicy.policy_id -ne "fail_closed_unless_explicit_caveat") {
        throw "$SourceLabel stale_ref_policy policy_id must be fail_closed_unless_explicit_caveat."
    }
    if ((Assert-BooleanValue -Value $stalePolicy.stale_ref_requires_caveat -Context "$SourceLabel stale_ref_policy stale_ref_requires_caveat") -ne $true) {
        throw "$SourceLabel stale_ref_policy stale_ref_requires_caveat must be True."
    }
    if ((Assert-BooleanValue -Value $stalePolicy.stale_ref_accepted_without_caveat -Context "$SourceLabel stale_ref_policy stale_ref_accepted_without_caveat") -ne $false) {
        throw "$SourceLabel stale_ref_policy stale_ref_accepted_without_caveat must be False."
    }

    $proofPolicy = Assert-ObjectValue -Value $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"
    foreach ($falseField in @("generated_reports_as_machine_proof_allowed", "planning_reports_as_implementation_proof_allowed", "artifact_map_contract_is_generated_artifact_map", "artifact_map_contract_is_runtime_memory", "artifact_map_contract_is_retrieval_runtime", "artifact_map_contract_is_vector_runtime", "artifact_map_contract_is_workflow_execution")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $proofPolicy -Name $falseField -Context "$SourceLabel proof_treatment_policy") -Context "$SourceLabel proof_treatment_policy $falseField") -ne $false) {
            throw "$SourceLabel proof_treatment_policy $falseField must be False."
        }
    }

    $overclaimPolicy = Assert-ObjectValue -Value $Contract.overclaim_rejection_policy -Context "$SourceLabel overclaim_rejection_policy"
    Assert-FalseFields -Object $overclaimPolicy -Fields $script:RequiredOverclaimFalseFields -Context "$SourceLabel overclaim_rejection_policy"
    Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $nonClaims = Assert-StringArray -Value $Contract.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    $validationCommands = Assert-ObjectArray -Value $Contract.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"
    $invalidStateRules = Assert-ObjectArray -Value $Contract.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $dependencyRefs = Assert-ObjectArray -Value $Contract.dependency_refs -Context "$SourceLabel dependency_refs"
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-DependencyRef -DependencyRef $dependencyRefs[$index] -Context "$SourceLabel dependency_refs[$index]" -RepositoryRoot $RepositoryRoot
    }

    $records = Assert-ObjectArray -Value $Contract.contract_model_records -Context "$SourceLabel contract_model_records"
    $artifactIds = @()
    for ($index = 0; $index -lt $records.Count; $index += 1) {
        $artifactId = Assert-ArtifactRecord -Record $records[$index] -Context "$SourceLabel contract_model_records[$index]" -RepositoryRoot $RepositoryRoot -ExpectedOrder ($index + 1)
        if ($artifactIds -contains $artifactId) {
            throw "$SourceLabel duplicate artifact id '$artifactId' is rejected."
        }
        $artifactIds += $artifactId
    }

    $relationships = Assert-ObjectArray -Value $Contract.contract_model_relationships -Context "$SourceLabel contract_model_relationships" -AllowEmpty
    for ($index = 0; $index -lt $relationships.Count; $index += 1) {
        Assert-Relationship -Relationship $relationships[$index] -Context "$SourceLabel contract_model_relationships[$index]" -ArtifactIds $artifactIds -ExpectedOrder ($index + 1)
    }

    return [pscustomobject]@{
        ArtifactType = $Contract.artifact_type
        ContractId = $Contract.artifact_map_contract_id
        SourceTask = $Contract.source_task
        ArtifactClassCount = $allowedArtifactClasses.Count
        ArtifactRoleCount = $allowedArtifactRoles.Count
        AuthorityClassCount = $allowedAuthorityClasses.Count
        EvidenceKindCount = $allowedEvidenceKinds.Count
        LifecycleStateCount = $allowedLifecycleStates.Count
        ProofStatusCount = $allowedProofStatuses.Count
        AllowedArtifactClasses = $allowedArtifactClasses
        AllowedArtifactRoles = $allowedArtifactRoles
        AllowedAuthorityClasses = $allowedAuthorityClasses
        AllowedEvidenceKinds = $allowedEvidenceKinds
        AllowedLifecycleStates = $allowedLifecycleStates
        AllowedProofStatuses = $allowedProofStatuses
        ArtifactRecordFields = Assert-StringArray -Value $artifactSchema.required_fields -Context "$SourceLabel artifact_record_schema required_fields"
        SourceRefFields = Assert-StringArray -Value $sourceRefSchema.required_fields -Context "$SourceLabel source_ref_schema required_fields"
        RelationshipFields = Assert-StringArray -Value $relationshipSchema.required_fields -Context "$SourceLabel relationship_schema required_fields"
        InspectionRouteFields = Assert-StringArray -Value $inspectionRouteSchema.required_fields -Context "$SourceLabel inspection_route_schema required_fields"
        CaveatFields = Assert-StringArray -Value $caveatSchema.required_fields -Context "$SourceLabel caveat_schema required_fields"
        ActiveThroughTask = $Contract.current_posture.active_through_task
        PlannedTaskStart = $Contract.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Contract.current_posture.planned_tasks[-1]
        ContractOnly = [bool]$mode.contract_only
        GeneratedArtifactMapExists = [bool]$mode.generated_artifact_map_exists
        ArtifactMapGeneratorImplemented = [bool]$mode.artifact_map_generator_implemented
        AuditMapImplemented = [bool]$mode.audit_map_implemented
        ContextLoadPlannerImplemented = [bool]$mode.context_load_planner_implemented
        RecordCount = $records.Count
        RelationshipCount = $relationships.Count
        NonClaims = $nonClaims
    }
}

function Test-R16ArtifactMapContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ContractPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $contract = Read-SingleJsonObject -Path $ContractPath -Label "R16 artifact map contract"
    return Test-R16ArtifactMapContractObject -Contract $contract -SourceLabel $ContractPath -RepositoryRoot $RepositoryRoot
}

Export-ModuleMember -Function Test-R16ArtifactMapContract, Test-R16ArtifactMapContractObject
