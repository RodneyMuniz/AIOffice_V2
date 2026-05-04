Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "memory_layer_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "memory_layer_model_mode",
    "allowed_layer_types",
    "allowed_authority_classes",
    "allowed_memory_scope_kinds",
    "allowed_source_ref_types",
    "allowed_proof_treatments",
    "layer_record_schema",
    "source_ref_schema",
    "freshness_schema",
    "stale_ref_policy",
    "role_eligibility_schema",
    "load_rule_schema",
    "exclusion_rule_schema",
    "context_budget_schema",
    "evidence_requirement_schema",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules"
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

$script:ExpectedAuthorityClasses = @(
    "constitutional_authority",
    "governance_authority",
    "milestone_authority",
    "contract_authority",
    "state_authority",
    "proof_authority",
    "report_context",
    "operator_context",
    "deprecated_context"
)

$script:ExpectedScopeKinds = @(
    "repository_global",
    "product_governance",
    "milestone",
    "task",
    "role",
    "run_session",
    "evidence",
    "knowledge_index",
    "historical_report",
    "cleanup_candidate"
)

$script:ExpectedSourceRefTypes = @(
    "repo_file_exact_path",
    "governance_document",
    "contract_file",
    "state_artifact",
    "proof_review_package",
    "validation_manifest",
    "tool_file",
    "test_file",
    "fixture_file",
    "report_file"
)

$script:ExpectedProofTreatments = @(
    "canonical_authority_constraint_not_proof_by_itself",
    "operator_report_planning_context_not_implementation_proof",
    "validation_manifest_commands_only",
    "state_artifact_validator_backed_machine_evidence",
    "committed_machine_evidence",
    "contract_model_only_not_runtime_memory",
    "deprecated_context_not_active_authority"
)

$script:RequiredLayerRecordFields = @(
    "layer_id",
    "layer_type",
    "authority_class",
    "memory_scope_kind",
    "source_refs",
    "freshness",
    "role_eligibility",
    "load_rules",
    "exclusion_rules",
    "context_budget",
    "proof_treatment",
    "evidence_requirements",
    "allowed_content",
    "forbidden_content",
    "non_claims"
)

$script:RequiredSourceRefFields = @(
    "ref_id",
    "ref_type",
    "path",
    "authority_class",
    "proof_treatment",
    "exact_load_only",
    "broad_scan_allowed",
    "wildcard_allowed",
    "stale_state",
    "stale_caveat",
    "machine_proof",
    "implementation_proof"
)

$script:RequiredFreshnessFields = @(
    "freshness_basis",
    "generated_from_head",
    "generated_from_tree",
    "stale_ref_policy",
    "stale_caveat_required"
)

$script:RequiredValidationCommands = @(
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
    "no R16-005 implementation",
    "no R16-027 or later task",
    "no deterministic memory layer generator",
    "no generated operational memory layers",
    "no role-specific memory packs",
    "no artifact maps implemented yet",
    "no audit maps implemented yet",
    "no context-load planner implemented yet",
    "no context budget estimator implemented yet",
    "no role-run envelopes implemented yet",
    "no handoff packets implemented yet",
    "no workflow drills",
    "memory-layer contract existence does not equal memory runtime"
)

$script:RequiredInvalidRuleIds = @(
    "missing_layer_type_rejected",
    "unknown_layer_type_rejected",
    "missing_authority_class_rejected",
    "unknown_authority_class_rejected",
    "missing_source_refs_rejected",
    "broad_repo_root_source_ref_rejected",
    "wildcard_source_ref_rejected",
    "generated_report_as_machine_proof_rejected",
    "planning_report_as_implementation_proof_rejected",
    "stale_ref_without_caveat_rejected",
    "runtime_memory_loading_claim_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "product_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "external_integration_claim_rejected",
    "r16_005_or_later_implementation_claim_rejected",
    "r16_027_or_later_task_rejected",
    "r13_closure_claim_rejected",
    "r14_caveat_removal_rejected",
    "r15_caveat_removal_rejected"
)

$script:RequiredModeFalseFields = @(
    "deterministic_memory_layer_generator_implemented",
    "operational_memory_layers_generated",
    "role_specific_memory_packs_generated",
    "runtime_memory_loading_implemented",
    "persistent_memory_runtime_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "product_runtime_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "external_integrations_implemented"
)

$script:RequiredPostureFalseFields = @(
    "r16_005_or_later_implementation_claimed",
    "r16_027_or_later_task_exists",
    "memory_layer_generator_implemented",
    "generated_operational_memory_layers_exist",
    "role_specific_memory_packs_implemented",
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
    "solved_codex_reliability"
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

function Resolve-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $resolved = Resolve-RepoRelativePath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf) -and -not (Test-Path -LiteralPath $resolved -PathType Container)) {
        throw "$Context path '$Path' does not exist."
    }

    return $resolved
}

function Get-ProofTreatmentIds {
    param(
        [Parameter(Mandatory = $true)]
        $AllowedProofTreatments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $items = Assert-ObjectArray -Value $AllowedProofTreatments -Context $Context
    $ids = @()
    foreach ($item in $items) {
        $ids += Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "treatment_id" -Context $Context) -Context "$Context treatment_id"
    }

    return [string[]]$ids
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

function Test-PlanningReportPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized -in @(
        "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
        "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"
    )
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
        $Posture,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-004") {
        throw "$Context active_through_task must be R16-004."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"

    $allTasks = @($completeTasks) + @($plannedTasks)
    foreach ($taskId in $allTasks) {
        if ($taskId -match '^R16-(\d{3})$') {
            $taskNumber = [int]$Matches[1]
            if ($taskNumber -ge 27) {
                throw "$Context introduces R16-027 or later task '$taskId'."
            }
        }
    }

    foreach ($taskId in @($completeTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 5) {
            throw "$Context claims R16-005 or later implementation with '$taskId'."
        }
    }

    Assert-ExactStringSet -Values $completeTasks -ExpectedValues @("R16-001", "R16-002", "R16-003", "R16-004") -Context "$Context complete_tasks"
    $expectedPlannedTasks = @(5..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues $expectedPlannedTasks -Context "$Context planned_tasks"

    Assert-FalseFields -Object $postureObject -Fields $script:RequiredPostureFalseFields -Context $Context
}

function Assert-ProofTreatmentRules {
    param(
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $rules = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Contract -Name "proof_treatment_rules" -Context $Context) -Context "$Context proof_treatment_rules"
    foreach ($trueField in @(
            "canonical_authority_requires_committed_machine_evidence_for_proof",
            "generated_reports_operator_artifacts_unless_evidence_backed",
            "validation_manifests_prove_recorded_commands_only",
            "state_artifacts_machine_evidence_only_if_validator_backed",
            "planning_reports_planning_authority_only",
            "memory_layer_contract_model_proof_only"
        )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $rules -Name $trueField -Context "$Context proof_treatment_rules") -Context "$Context proof_treatment_rules $trueField") -ne $true) {
            throw "$Context proof_treatment_rules $trueField must be True."
        }
    }
    foreach ($falseField in @(
            "generated_reports_as_machine_proof",
            "planning_reports_as_implementation_proof",
            "memory_layer_contract_is_runtime_memory"
        )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $rules -Name $falseField -Context "$Context proof_treatment_rules") -Context "$Context proof_treatment_rules $falseField") -ne $false) {
            throw "$Context proof_treatment_rules $falseField must be False."
        }
    }
}

function Assert-SourceRef {
    param(
        [Parameter(Mandatory = $true)]
        $SourceRef,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedAuthorityClasses,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedSourceRefTypes,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedProofTreatmentIds,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    foreach ($field in $script:RequiredSourceRefFields) {
        Get-RequiredProperty -Object $SourceRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $SourceRef.path -Context "$Context path"
    if (Test-BroadRepoRootPath -Path $path) {
        throw "$Context path rejects broad repo root source ref '$path'."
    }
    if (Test-WildcardPath -Path $path) {
        throw "$Context path rejects wildcard source ref '$path'."
    }
    if ($SourceRef.ref_type -notin $AllowedSourceRefTypes) {
        throw "$Context ref_type '$($SourceRef.ref_type)' is not allowed."
    }
    if ($SourceRef.authority_class -notin $AllowedAuthorityClasses) {
        throw "$Context authority_class '$($SourceRef.authority_class)' is not allowed."
    }
    if ($SourceRef.proof_treatment -notin $AllowedProofTreatmentIds) {
        throw "$Context proof_treatment '$($SourceRef.proof_treatment)' is not allowed."
    }
    if ((Assert-BooleanValue -Value $SourceRef.exact_load_only -Context "$Context exact_load_only") -ne $true) {
        throw "$Context exact_load_only must be True."
    }
    if ((Assert-BooleanValue -Value $SourceRef.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $SourceRef.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }

    $machineProof = Assert-BooleanValue -Value $SourceRef.machine_proof -Context "$Context machine_proof"
    $implementationProof = Assert-BooleanValue -Value $SourceRef.implementation_proof -Context "$Context implementation_proof"
    if (Test-PlanningReportPath -Path $path) {
        if ($machineProof -or $SourceRef.proof_treatment -eq "committed_machine_evidence") {
            throw "$Context generated report treated as machine proof is rejected."
        }
        if ($implementationProof -or $SourceRef.proof_treatment -eq "implementation_proof") {
            throw "$Context planning report treated as implementation proof is rejected."
        }
    }

    $staleState = Assert-NonEmptyString -Value $SourceRef.stale_state -Context "$Context stale_state"
    if ($staleState -notin @("fresh", "stale_with_caveat", "deprecated_with_caveat")) {
        throw "$Context stale_state '$staleState' is not allowed."
    }
    if ($staleState -ne "fresh" -and [string]::IsNullOrWhiteSpace([string]$SourceRef.stale_caveat)) {
        throw "$Context stale ref accepted without caveat is rejected."
    }

    Assert-PathExists -Path $path -Context $Context -RepositoryRoot $RepositoryRoot | Out-Null
}

function Assert-LayerRecord {
    param(
        [Parameter(Mandatory = $true)]
        $Record,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedLayerTypes,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedAuthorityClasses,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedScopeKinds,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedSourceRefTypes,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedProofTreatmentIds,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    foreach ($field in $script:RequiredLayerRecordFields) {
        Get-RequiredProperty -Object $Record -Name $field -Context $Context | Out-Null
    }

    if ($Record.layer_type -notin $AllowedLayerTypes) {
        throw "$Context layer_type '$($Record.layer_type)' is not allowed."
    }
    if ($Record.authority_class -notin $AllowedAuthorityClasses) {
        throw "$Context authority_class '$($Record.authority_class)' is not allowed."
    }
    if ($Record.memory_scope_kind -notin $AllowedScopeKinds) {
        throw "$Context memory_scope_kind '$($Record.memory_scope_kind)' is not allowed."
    }
    if ($Record.proof_treatment -notin $AllowedProofTreatmentIds) {
        throw "$Context proof_treatment '$($Record.proof_treatment)' is not allowed."
    }

    $freshness = Assert-ObjectValue -Value $Record.freshness -Context "$Context freshness"
    foreach ($field in $script:RequiredFreshnessFields) {
        Get-RequiredProperty -Object $freshness -Name $field -Context "$Context freshness" | Out-Null
    }
    if ($freshness.stale_ref_policy -ne "fail_closed_unless_explicit_caveat") {
        throw "$Context freshness stale_ref_policy must be fail_closed_unless_explicit_caveat."
    }
    if ((Assert-BooleanValue -Value $freshness.stale_caveat_required -Context "$Context freshness stale_caveat_required") -ne $true) {
        throw "$Context freshness stale_caveat_required must be True."
    }

    $roleEligibility = Assert-ObjectValue -Value $Record.role_eligibility -Context "$Context role_eligibility"
    Assert-StringArray -Value (Get-RequiredProperty -Object $roleEligibility -Name "eligible_roles" -Context "$Context role_eligibility") -Context "$Context role_eligibility eligible_roles" | Out-Null
    foreach ($falseField in @("actual_autonomous_agents", "true_multi_agent_execution")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $roleEligibility -Name $falseField -Context "$Context role_eligibility") -Context "$Context role_eligibility $falseField") -ne $false) {
            throw "$Context role_eligibility $falseField must be False."
        }
    }

    $loadRules = Assert-ObjectValue -Value $Record.load_rules -Context "$Context load_rules"
    foreach ($trueField in @("exact_load_required", "path_level_source_refs_required")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $loadRules -Name $trueField -Context "$Context load_rules") -Context "$Context load_rules $trueField") -ne $true) {
            throw "$Context load_rules $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_scan_allowed", "full_repo_scan_allowed", "wildcard_path_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $loadRules -Name $falseField -Context "$Context load_rules") -Context "$Context load_rules $falseField") -ne $false) {
            throw "$Context load_rules $falseField must be False."
        }
    }

    Assert-ObjectValue -Value $Record.exclusion_rules -Context "$Context exclusion_rules" | Out-Null
    Assert-ObjectValue -Value $Record.context_budget -Context "$Context context_budget" | Out-Null
    Assert-ObjectValue -Value $Record.evidence_requirements -Context "$Context evidence_requirements" | Out-Null
    Assert-StringArray -Value $Record.allowed_content -Context "$Context allowed_content" | Out-Null
    Assert-StringArray -Value $Record.forbidden_content -Context "$Context forbidden_content" | Out-Null
    Assert-StringArray -Value $Record.non_claims -Context "$Context non_claims" | Out-Null

    $sourceRefs = Assert-ObjectArray -Value $Record.source_refs -Context "$Context source_refs"
    for ($index = 0; $index -lt $sourceRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $sourceRefs[$index] -Context "$Context source_refs[$index]" -AllowedAuthorityClasses $AllowedAuthorityClasses -AllowedSourceRefTypes $AllowedSourceRefTypes -AllowedProofTreatmentIds $AllowedProofTreatmentIds -RepositoryRoot $RepositoryRoot
    }
}

function Test-R16MemoryLayerContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Contract,
        [string]$SourceLabel = "R16 memory layer contract",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Contract -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_memory_layer_contract") {
        throw "$SourceLabel artifact_type must be r16_memory_layer_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.source_milestone -ne "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation") {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Contract.source_task -ne "R16-004") {
        throw "$SourceLabel source_task must be R16-004."
    }
    if ($Contract.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Contract.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }
    Assert-NonEmptyString -Value $Contract.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Contract.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    $mode = Assert-ObjectValue -Value $Contract.memory_layer_model_mode -Context "$SourceLabel memory_layer_model_mode"
    if ($mode.mode -ne "contract_model_only_not_runtime_memory") {
        throw "$SourceLabel memory_layer_model_mode mode must be contract_model_only_not_runtime_memory."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "contract_model_only" -Context "$SourceLabel memory_layer_model_mode") -Context "$SourceLabel memory_layer_model_mode contract_model_only") -ne $true) {
        throw "$SourceLabel memory_layer_model_mode contract_model_only must be True."
    }
    Assert-FalseFields -Object $mode -Fields $script:RequiredModeFalseFields -Context "$SourceLabel memory_layer_model_mode"

    $allowedLayerTypes = Assert-StringArray -Value $Contract.allowed_layer_types -Context "$SourceLabel allowed_layer_types"
    Assert-ExactStringSet -Values $allowedLayerTypes -ExpectedValues $script:ExpectedLayerTypes -Context "$SourceLabel allowed_layer_types"
    $allowedAuthorityClasses = Assert-StringArray -Value $Contract.allowed_authority_classes -Context "$SourceLabel allowed_authority_classes"
    Assert-ExactStringSet -Values $allowedAuthorityClasses -ExpectedValues $script:ExpectedAuthorityClasses -Context "$SourceLabel allowed_authority_classes"
    $allowedScopeKinds = Assert-StringArray -Value $Contract.allowed_memory_scope_kinds -Context "$SourceLabel allowed_memory_scope_kinds"
    Assert-ExactStringSet -Values $allowedScopeKinds -ExpectedValues $script:ExpectedScopeKinds -Context "$SourceLabel allowed_memory_scope_kinds"
    $allowedSourceRefTypes = Assert-StringArray -Value $Contract.allowed_source_ref_types -Context "$SourceLabel allowed_source_ref_types"
    Assert-ExactStringSet -Values $allowedSourceRefTypes -ExpectedValues $script:ExpectedSourceRefTypes -Context "$SourceLabel allowed_source_ref_types"
    $allowedProofTreatmentIds = Get-ProofTreatmentIds -AllowedProofTreatments $Contract.allowed_proof_treatments -Context "$SourceLabel allowed_proof_treatments"
    Assert-ExactStringSet -Values $allowedProofTreatmentIds -ExpectedValues $script:ExpectedProofTreatments -Context "$SourceLabel allowed_proof_treatments"

    $layerSchema = Assert-ObjectValue -Value $Contract.layer_record_schema -Context "$SourceLabel layer_record_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $layerSchema.required_fields -Context "$SourceLabel layer_record_schema required_fields") -RequiredValues $script:RequiredLayerRecordFields -Context "$SourceLabel layer_record_schema required_fields"
    $sourceRefSchema = Assert-ObjectValue -Value $Contract.source_ref_schema -Context "$SourceLabel source_ref_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $sourceRefSchema.required_fields -Context "$SourceLabel source_ref_schema required_fields") -RequiredValues $script:RequiredSourceRefFields -Context "$SourceLabel source_ref_schema required_fields"
    $freshnessSchema = Assert-ObjectValue -Value $Contract.freshness_schema -Context "$SourceLabel freshness_schema"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $freshnessSchema.required_fields -Context "$SourceLabel freshness_schema required_fields") -RequiredValues $script:RequiredFreshnessFields -Context "$SourceLabel freshness_schema required_fields"

    $stalePolicy = Assert-ObjectValue -Value $Contract.stale_ref_policy -Context "$SourceLabel stale_ref_policy"
    if ($stalePolicy.policy_id -ne "fail_closed_unless_explicit_caveat") {
        throw "$SourceLabel stale_ref_policy policy_id must be fail_closed_unless_explicit_caveat."
    }
    if ((Assert-BooleanValue -Value $stalePolicy.stale_ref_accepted_without_caveat -Context "$SourceLabel stale_ref_policy stale_ref_accepted_without_caveat") -ne $false) {
        throw "$SourceLabel stale_ref_policy stale_ref_accepted_without_caveat must be False."
    }
    if ((Assert-BooleanValue -Value $stalePolicy.stale_ref_requires_caveat -Context "$SourceLabel stale_ref_policy stale_ref_requires_caveat") -ne $true) {
        throw "$SourceLabel stale_ref_policy stale_ref_requires_caveat must be True."
    }

    Assert-ObjectValue -Value $Contract.role_eligibility_schema -Context "$SourceLabel role_eligibility_schema" | Out-Null
    Assert-ObjectValue -Value $Contract.load_rule_schema -Context "$SourceLabel load_rule_schema" | Out-Null
    Assert-ObjectValue -Value $Contract.exclusion_rule_schema -Context "$SourceLabel exclusion_rule_schema" | Out-Null
    Assert-ObjectValue -Value $Contract.context_budget_schema -Context "$SourceLabel context_budget_schema" | Out-Null
    Assert-ObjectValue -Value $Contract.evidence_requirement_schema -Context "$SourceLabel evidence_requirement_schema" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Contract -Name "allowed_memory_content" -Context $SourceLabel) -Context "$SourceLabel allowed_memory_content" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Contract -Name "forbidden_memory_content" -Context $SourceLabel) -Context "$SourceLabel forbidden_memory_content" | Out-Null

    Assert-ProofTreatmentRules -Contract $Contract -Context $SourceLabel
    Assert-CurrentPosture -Posture (Get-RequiredProperty -Object $Contract -Name "current_posture" -Context $SourceLabel) -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $nonClaims = Assert-StringArray -Value $Contract.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    $validationCommands = Assert-ObjectArray -Value $Contract.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidStateRules = Assert-ObjectArray -Value $Contract.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $contractSourceRefs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Contract -Name "contract_source_refs" -Context $SourceLabel) -Context "$SourceLabel contract_source_refs"
    for ($index = 0; $index -lt $contractSourceRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $contractSourceRefs[$index] -Context "$SourceLabel contract_source_refs[$index]" -AllowedAuthorityClasses $allowedAuthorityClasses -AllowedSourceRefTypes $allowedSourceRefTypes -AllowedProofTreatmentIds $allowedProofTreatmentIds -RepositoryRoot $RepositoryRoot
    }

    $sampleRecords = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Contract -Name "contract_model_samples" -Context $SourceLabel) -Context "$SourceLabel contract_model_samples"
    for ($index = 0; $index -lt $sampleRecords.Count; $index += 1) {
        Assert-LayerRecord -Record $sampleRecords[$index] -Context "$SourceLabel contract_model_samples[$index]" -AllowedLayerTypes $allowedLayerTypes -AllowedAuthorityClasses $allowedAuthorityClasses -AllowedScopeKinds $allowedScopeKinds -AllowedSourceRefTypes $allowedSourceRefTypes -AllowedProofTreatmentIds $allowedProofTreatmentIds -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        ArtifactType = $Contract.artifact_type
        ContractId = $Contract.memory_layer_contract_id
        SourceTask = $Contract.source_task
        LayerTypeCount = $allowedLayerTypes.Count
        AuthorityClassCount = $allowedAuthorityClasses.Count
        AllowedLayerTypes = $allowedLayerTypes
        AllowedAuthorityClasses = $allowedAuthorityClasses
        ActiveThroughTask = $Contract.current_posture.active_through_task
        PlannedTaskStart = $Contract.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Contract.current_posture.planned_tasks[-1]
        ContractModelOnly = [bool]$mode.contract_model_only
        RuntimeMemoryLoadingImplemented = [bool]$mode.runtime_memory_loading_implemented
        OperationalMemoryLayersGenerated = [bool]$mode.operational_memory_layers_generated
        NonClaims = $nonClaims
    }
}

function Test-R16MemoryLayerContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $contract = Read-SingleJsonObject -Path $ContractPath -Label "R16 memory layer contract"
    return Test-R16MemoryLayerContractObject -Contract $contract -SourceLabel $ContractPath -RepositoryRoot $RepositoryRoot
}

function Test-R16MemoryLayerContractSample {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SamplePath,
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $contractResult = Test-R16MemoryLayerContract -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    $contract = Read-SingleJsonObject -Path $ContractPath -Label "R16 memory layer contract"
    $sample = Read-SingleJsonObject -Path $SamplePath -Label "R16 memory layer contract sample"
    if ($sample.artifact_type -ne "r16_memory_layer_contract_sample") {
        throw "$SamplePath artifact_type must be r16_memory_layer_contract_sample."
    }
    if ($sample.sample_mode -ne "model_only_not_operational_memory_layer") {
        throw "$SamplePath sample_mode must be model_only_not_operational_memory_layer."
    }
    $records = Assert-ObjectArray -Value (Get-RequiredProperty -Object $sample -Name "layer_records" -Context $SamplePath) -Context "$SamplePath layer_records"
    $allowedProofTreatmentIds = Get-ProofTreatmentIds -AllowedProofTreatments $contract.allowed_proof_treatments -Context "$ContractPath allowed_proof_treatments"
    for ($index = 0; $index -lt $records.Count; $index += 1) {
        Assert-LayerRecord -Record $records[$index] -Context "$SamplePath layer_records[$index]" -AllowedLayerTypes $contractResult.AllowedLayerTypes -AllowedAuthorityClasses $contractResult.AllowedAuthorityClasses -AllowedScopeKinds $script:ExpectedScopeKinds -AllowedSourceRefTypes $script:ExpectedSourceRefTypes -AllowedProofTreatmentIds $allowedProofTreatmentIds -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        SamplePath = $SamplePath
        RecordCount = $records.Count
        SampleMode = $sample.sample_mode
    }
}

Export-ModuleMember -Function Test-R16MemoryLayerContract, Test-R16MemoryLayerContractObject, Test-R16MemoryLayerContractSample
