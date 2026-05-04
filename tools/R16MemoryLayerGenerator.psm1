Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerContract.psm1") -Force

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

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "artifact_version",
    "memory_layer_artifact_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "contract_ref",
    "generator",
    "generation_policy",
    "generation_mode",
    "current_posture",
    "generation_inputs",
    "layer_records",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules",
    "generated_artifact_statement"
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

$script:ForbiddenFalseFields = @(
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
    "solved_codex_reliability",
    "r16_006_or_later_implementation_claimed",
    "r16_027_or_later_task_exists",
    "generated_baseline_memory_layers_are_runtime_memory"
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
    "no R16-006 implementation",
    "no R16-027 or later task",
    "no role-specific memory packs",
    "no artifact maps implemented yet",
    "no audit maps implemented yet",
    "no context-load planner implemented yet",
    "no context budget estimator implemented yet",
    "no role-run envelopes implemented yet",
    "no handoff packets implemented yet",
    "no workflow drills",
    "generated baseline memory layers are committed state artifacts, not runtime memory"
)

$script:RequiredValidationCommands = @(
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
    "missing_memory_layer_rejected",
    "unknown_memory_layer_type_rejected",
    "missing_authority_class_rejected",
    "unknown_authority_class_rejected",
    "missing_source_refs_rejected",
    "broad_repo_root_source_ref_rejected",
    "wildcard_source_ref_rejected",
    "full_repo_scan_requested_rejected",
    "stale_ref_without_caveat_rejected",
    "generated_report_as_machine_proof_rejected",
    "planning_report_as_implementation_proof_rejected",
    "runtime_memory_loading_claim_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "role_specific_memory_packs_claim_rejected",
    "artifact_map_claim_rejected",
    "context_load_planner_claim_rejected",
    "product_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "external_integration_claim_rejected",
    "r16_006_implementation_claim_rejected",
    "r16_027_or_later_task_rejected",
    "r13_closure_claim_rejected",
    "r14_caveat_removal_rejected",
    "r15_caveat_removal_rejected"
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

function Resolve-RepoRelativePathValue {
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

function Test-GeneratedReportPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized -like "governance/reports/*"
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
        throw "$Context must be a safe repo-relative path, not an absolute path."
    }
    if (Test-BroadRepoRootPath -Path $Path) {
        throw "$Context rejects broad repo root source ref '$Path'."
    }
    if (Test-WildcardPath -Path $Path) {
        throw "$Context rejects wildcard source ref '$Path'."
    }
    if ($Path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }

    $resolved = Resolve-RepoRelativePathValue -Path $Path -RepositoryRoot $RepositoryRoot
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }

    return $resolved
}

function Get-FileSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Invoke-GitScalar {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $output = & git -C $RepositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return [string]($output | Select-Object -First 1)
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

function Get-R16SourceRefDefinitions {
    $staleCaveat = "R15-009 stale generated_from_head/generated_from_tree caveat is preserved for audited R15 proof-package hygiene; R15 remains accepted with caveats through R15-009 and is not rewritten by R16-005."

    return @(
        [ordered]@{ RefId = "r16_memory_layer_contract"; RefType = "contract_file"; Path = "contracts/memory/r16_memory_layer.contract.json"; AuthorityClass = "contract_authority"; ProofTreatment = "contract_model_only_not_runtime_memory"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_memory_layer_contract_validator"; RefType = "tool_file"; Path = "tools/R16MemoryLayerContract.psm1"; AuthorityClass = "contract_authority"; ProofTreatment = "contract_model_only_not_runtime_memory"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_memory_layer_generator"; RefType = "tool_file"; Path = "tools/R16MemoryLayerGenerator.psm1"; AuthorityClass = "proof_authority"; ProofTreatment = "committed_machine_evidence"; MachineProof = $true; ImplementationProof = $true; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_memory_layer_generator_cli"; RefType = "tool_file"; Path = "tools/new_r16_memory_layers.ps1"; AuthorityClass = "proof_authority"; ProofTreatment = "committed_machine_evidence"; MachineProof = $true; ImplementationProof = $true; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_memory_layer_validator_cli"; RefType = "tool_file"; Path = "tools/validate_r16_memory_layers.ps1"; AuthorityClass = "proof_authority"; ProofTreatment = "committed_machine_evidence"; MachineProof = $true; ImplementationProof = $true; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_memory_layer_generator_test"; RefType = "test_file"; Path = "tests/test_r16_memory_layer_generator.ps1"; AuthorityClass = "proof_authority"; ProofTreatment = "committed_machine_evidence"; MachineProof = $true; ImplementationProof = $true; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_kpi_scorecard"; RefType = "state_artifact"; Path = "state/governance/r16_kpi_baseline_target_scorecard.json"; AuthorityClass = "state_authority"; ProofTreatment = "state_artifact_validator_backed_machine_evidence"; MachineProof = $true; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_planning_authority_reference"; RefType = "state_artifact"; Path = "state/governance/r16_planning_authority_reference.json"; AuthorityClass = "state_authority"; ProofTreatment = "state_artifact_validator_backed_machine_evidence"; MachineProof = $true; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_authority"; RefType = "governance_document"; Path = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"; AuthorityClass = "milestone_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "kpi_domain_model"; RefType = "governance_document"; Path = "governance/KPI_DOMAIN_MODEL.md"; AuthorityClass = "governance_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "milestone_reporting_standard"; RefType = "governance_document"; Path = "governance/MILESTONE_REPORTING_STANDARD.md"; AuthorityClass = "governance_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r15_external_audit_r16_planning_report"; RefType = "report_file"; Path = "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md"; AuthorityClass = "report_context"; ProofTreatment = "operator_report_planning_context_not_implementation_proof"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_revised_operational_memory_plan"; RefType = "report_file"; Path = "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"; AuthorityClass = "report_context"; ProofTreatment = "operator_report_planning_context_not_implementation_proof"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r16_004_validation_manifest"; RefType = "validation_manifest"; Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/validation_manifest.md"; AuthorityClass = "proof_authority"; ProofTreatment = "validation_manifest_commands_only"; MachineProof = $true; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "readme_status_surface"; RefType = "repo_file_exact_path"; Path = "README.md"; AuthorityClass = "governance_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "active_state_status_surface"; RefType = "governance_document"; Path = "governance/ACTIVE_STATE.md"; AuthorityClass = "governance_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "kanban_status_surface"; RefType = "repo_file_exact_path"; Path = "execution/KANBAN.md"; AuthorityClass = "operator_context"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "decision_log_status_surface"; RefType = "governance_document"; Path = "governance/DECISION_LOG.md"; AuthorityClass = "governance_authority"; ProofTreatment = "canonical_authority_constraint_not_proof_by_itself"; MachineProof = $false; ImplementationProof = $false; StaleState = "fresh"; StaleCaveat = "" },
        [ordered]@{ RefId = "r15_stale_final_proof_package"; RefType = "proof_review_package"; Path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json"; AuthorityClass = "deprecated_context"; ProofTreatment = "deprecated_context_not_active_authority"; MachineProof = $false; ImplementationProof = $false; StaleState = "stale_with_caveat"; StaleCaveat = $staleCaveat },
        [ordered]@{ RefId = "r15_stale_evidence_index"; RefType = "proof_review_package"; Path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"; AuthorityClass = "deprecated_context"; ProofTreatment = "deprecated_context_not_active_authority"; MachineProof = $false; ImplementationProof = $false; StaleState = "stale_with_caveat"; StaleCaveat = $staleCaveat }
    )
}

function New-R16SourceRef {
    param(
        [Parameter(Mandatory = $true)]
        $Definition,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $path = Assert-NonEmptyString -Value $Definition.Path -Context "source ref path"
    $resolvedPath = Assert-SafeRepoRelativeFilePath -Path $path -RepositoryRoot $RepositoryRoot -Context "source ref '$($Definition.RefId)' path"
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "source ref '$($Definition.RefId)' path '$path' does not exist."
    }

    return [ordered]@{
        ref_id = $Definition.RefId
        ref_type = $Definition.RefType
        path = $path
        authority_class = $Definition.AuthorityClass
        proof_treatment = $Definition.ProofTreatment
        exact_load_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        stale_state = $Definition.StaleState
        stale_caveat = $Definition.StaleCaveat
        machine_proof = [bool]$Definition.MachineProof
        implementation_proof = [bool]$Definition.ImplementationProof
        content_identity = [ordered]@{
            hash_algorithm = "SHA256"
            sha256 = Get-FileSha256 -Path $resolvedPath
            identity_basis = "Exact repo-relative file content read by R16-005 deterministic memory layer generator."
        }
    }
}

function Copy-R16SourceRef {
    param(
        [Parameter(Mandatory = $true)]
        $SourceRef
    )

    return [ordered]@{
        ref_id = $SourceRef.ref_id
        ref_type = $SourceRef.ref_type
        path = $SourceRef.path
        authority_class = $SourceRef.authority_class
        proof_treatment = $SourceRef.proof_treatment
        exact_load_only = $SourceRef.exact_load_only
        broad_scan_allowed = $SourceRef.broad_scan_allowed
        wildcard_allowed = $SourceRef.wildcard_allowed
        stale_state = $SourceRef.stale_state
        stale_caveat = $SourceRef.stale_caveat
        machine_proof = $SourceRef.machine_proof
        implementation_proof = $SourceRef.implementation_proof
        content_identity = [ordered]@{
            hash_algorithm = $SourceRef.content_identity.hash_algorithm
            sha256 = $SourceRef.content_identity.sha256
            identity_basis = $SourceRef.content_identity.identity_basis
        }
    }
}

function Select-R16SourceRefs {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$SourceRefMap,
        [Parameter(Mandatory = $true)]
        [string[]]$RefIds
    )

    $refs = @()
    foreach ($refId in $RefIds) {
        if (-not $SourceRefMap.ContainsKey($refId)) {
            throw "Unknown source ref id '$refId'."
        }

        $refs += (Copy-R16SourceRef -SourceRef $SourceRefMap[$refId])
    }

    return $refs
}

function New-R16LayerRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LayerId,
        [Parameter(Mandatory = $true)]
        [string]$LayerType,
        [Parameter(Mandatory = $true)]
        [string]$AuthorityClass,
        [Parameter(Mandatory = $true)]
        [string]$MemoryScopeKind,
        [Parameter(Mandatory = $true)]
        [string]$ProofTreatment,
        [Parameter(Mandatory = $true)]
        [object[]]$SourceRefs,
        [Parameter(Mandatory = $true)]
        [string]$BudgetCategory,
        [Parameter(Mandatory = $true)]
        [string]$Summary,
        [Parameter(Mandatory = $true)]
        [string]$GeneratedFromHead,
        [Parameter(Mandatory = $true)]
        [string]$GeneratedFromTree
    )

    return [ordered]@{
        layer_id = $LayerId
        layer_type = $LayerType
        authority_class = $AuthorityClass
        memory_scope_kind = $MemoryScopeKind
        summary = $Summary
        source_refs = $SourceRefs
        freshness = [ordered]@{
            freshness_basis = "exact_repo_relative_source_refs_with_sha256_identity"
            generated_from_head = $GeneratedFromHead
            generated_from_tree = $GeneratedFromTree
            stale_ref_policy = "fail_closed_unless_explicit_caveat"
            stale_caveat_required = $true
        }
        role_eligibility = [ordered]@{
            eligible_roles = @("Operator", "PM", "Architect", "Developer", "QA", "Auditor", "Knowledge Curator", "Release/Closeout Agent")
            role_scope_only = $true
            actual_autonomous_agents = $false
            true_multi_agent_execution = $false
        }
        load_rules = [ordered]@{
            exact_load_required = $true
            path_level_source_refs_required = $true
            broad_scan_allowed = $false
            full_repo_scan_allowed = $false
            wildcard_path_allowed = $false
            runtime_memory_loading_allowed = $false
            retrieval_runtime_allowed = $false
            vector_search_runtime_allowed = $false
        }
        exclusion_rules = [ordered]@{
            excluded_claims = @(
                "runtime memory loading",
                "persistent memory runtime",
                "retrieval runtime",
                "vector search runtime",
                "product runtime",
                "actual autonomous agents",
                "true multi-agent execution",
                "external integrations",
                "role-specific memory packs",
                "artifact maps",
                "audit maps",
                "context-load planner",
                "role-run envelope",
                "handoff packet",
                "workflow drill"
            )
            broad_repo_scan_excluded = $true
            wildcard_source_ref_excluded = $true
        }
        context_budget = [ordered]@{
            budget_category = $BudgetCategory
            max_source_refs = $SourceRefs.Count
            token_budget_category = "bounded_small"
            exact_paths_required = $true
            full_repo_scan_budget_allowed = $false
            runtime_retrieval_budget_allowed = $false
            vector_search_budget_allowed = $false
        }
        proof_treatment = $ProofTreatment
        evidence_requirements = [ordered]@{
            committed_contract_required = $true
            validator_required = $true
            focused_test_required = $true
            exact_source_refs_required = $true
            report_context_alone_sufficient = $false
            planning_report_is_implementation_proof = $false
            generated_report_is_machine_proof = $false
        }
        allowed_content = @(
            "authority summary",
            "exact source ref",
            "freshness status",
            "stale caveat",
            "role eligibility",
            "proof treatment",
            "evidence requirement",
            "exclusion rule",
            "context budget category",
            "non-claim"
        )
        forbidden_content = @(
            "runtime memory payload",
            "persistent memory state",
            "retrieval index",
            "vector embedding",
            "broad repo scan instruction",
            "wildcard source ref",
            "agent runtime instruction",
            "external integration credential",
            "product runtime claim",
            "implementation proof claim from planning report",
            "role-specific memory pack"
        )
        non_claims = @(
            "baseline memory layer state artifact only",
            "not runtime memory",
            "not persistent memory runtime",
            "not runtime memory loading",
            "not retrieval or vector runtime",
            "not a role-specific memory pack",
            "not an artifact map",
            "not an audit map",
            "not a context-load planner",
            "not a role-run envelope",
            "not a handoff packet"
        )
    }
}

function New-R16MemoryLayerObject {
    [CmdletBinding()]
    param(
        [string]$ContractPath = "contracts\memory\r16_memory_layer.contract.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = if (Test-Path -LiteralPath $RepositoryRoot) {
        (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }
    else {
        [System.IO.Path]::GetFullPath($RepositoryRoot)
    }

    $resolvedContractPath = Assert-SafeRepoRelativeFilePath -Path $ContractPath -RepositoryRoot $resolvedRepositoryRoot -Context "ContractPath"
    if (-not (Test-Path -LiteralPath $resolvedContractPath -PathType Leaf)) {
        throw "R16 memory layer contract '$ContractPath' is missing."
    }

    $contractResult = Test-R16MemoryLayerContract -ContractPath $resolvedContractPath -RepositoryRoot $resolvedRepositoryRoot
    $contract = Read-SingleJsonObject -Path $resolvedContractPath -Label "R16 memory layer contract"
    $allowedProofTreatmentIds = Get-ProofTreatmentIds -AllowedProofTreatments $contract.allowed_proof_treatments -Context "R16 memory layer contract allowed_proof_treatments"

    $head = Invoke-GitScalar -Arguments @("rev-parse", "HEAD") -RepositoryRoot $resolvedRepositoryRoot
    $tree = Invoke-GitScalar -Arguments @("rev-parse", "HEAD^{tree}") -RepositoryRoot $resolvedRepositoryRoot
    $branch = Invoke-GitScalar -Arguments @("branch", "--show-current") -RepositoryRoot $resolvedRepositoryRoot

    $sourceRefMap = @{}
    $sourceRefs = @()
    foreach ($definition in (Get-R16SourceRefDefinitions)) {
        $sourceRef = New-R16SourceRef -Definition $definition -RepositoryRoot $resolvedRepositoryRoot
        $sourceRefs += $sourceRef
        $sourceRefMap[$sourceRef.ref_id] = $sourceRef
    }

    $layers = @(
        (New-R16LayerRecord -LayerId "r16-005-global-governance-memory" -LayerType "global_governance_memory" -AuthorityClass "governance_authority" -MemoryScopeKind "repository_global" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("readme_status_surface", "active_state_status_surface", "decision_log_status_surface")) -BudgetCategory "governance_authority_load" -Summary "Repo-truth posture and governance status boundaries for R16-005." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-product-governance-memory" -LayerType "product_governance_memory" -AuthorityClass "governance_authority" -MemoryScopeKind "product_governance" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("kpi_domain_model", "milestone_reporting_standard", "r16_authority")) -BudgetCategory "governance_authority_load" -Summary "Product governance and KPI/reporting constraints that bound R16-005 evidence treatment." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-milestone-authority-memory" -LayerType "milestone_authority_memory" -AuthorityClass "milestone_authority" -MemoryScopeKind "milestone" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r16_authority", "r16_planning_authority_reference", "r16_kpi_scorecard", "r16_memory_layer_contract")) -BudgetCategory "governance_authority_load" -Summary "R16 task posture and milestone authority through R16-005 only." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-role-identity-memory" -LayerType "role_identity_memory" -AuthorityClass "contract_authority" -MemoryScopeKind "role" -ProofTreatment "contract_model_only_not_runtime_memory" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r16_memory_layer_contract", "r16_memory_layer_contract_validator")) -BudgetCategory "small_exact_ref_load" -Summary "Contract-defined role eligibility only; no role-specific memory packs are implemented." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-task-card-memory" -LayerType "task_card_memory" -AuthorityClass "operator_context" -MemoryScopeKind "task" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("kanban_status_surface", "r16_authority")) -BudgetCategory "governance_authority_load" -Summary "Task-card status for R16-001 through R16-026 with R16-006 through R16-026 planned only." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-run-session-memory" -LayerType "run_session_memory" -AuthorityClass "proof_authority" -MemoryScopeKind "run_session" -ProofTreatment "committed_machine_evidence" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r16_memory_layer_generator", "r16_memory_layer_generator_cli", "r16_memory_layer_validator_cli", "r16_memory_layer_generator_test")) -BudgetCategory "fixture_test_load" -Summary "R16-005 generator, CLI, validator, and focused test implementation refs." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-evidence-memory" -LayerType "evidence_memory" -AuthorityClass "proof_authority" -MemoryScopeKind "evidence" -ProofTreatment "validation_manifest_commands_only" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r16_004_validation_manifest", "r16_kpi_scorecard", "r16_planning_authority_reference")) -BudgetCategory "proof_review_load" -Summary "Validator-backed prior R16 evidence used as bounded source context for baseline layers." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-knowledge-index-memory" -LayerType "knowledge_index_memory" -AuthorityClass "governance_authority" -MemoryScopeKind "knowledge_index" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("kpi_domain_model", "milestone_reporting_standard", "r16_planning_authority_reference")) -BudgetCategory "small_exact_ref_load" -Summary "Knowledge-index style pointers for exact authority and state refs; no retrieval runtime is claimed." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-historical-report-memory" -LayerType "historical_report_memory" -AuthorityClass "report_context" -MemoryScopeKind "historical_report" -ProofTreatment "operator_report_planning_context_not_implementation_proof" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r15_external_audit_r16_planning_report", "r16_revised_operational_memory_plan")) -BudgetCategory "report_context_load" -Summary "Operator-approved planning reports as planning/report context only, not machine proof or implementation proof." -GeneratedFromHead $head -GeneratedFromTree $tree),
        (New-R16LayerRecord -LayerId "r16-005-deprecated-cleanup-candidate-memory" -LayerType "deprecated_cleanup_candidate_memory" -AuthorityClass "deprecated_context" -MemoryScopeKind "cleanup_candidate" -ProofTreatment "deprecated_context_not_active_authority" -SourceRefs (Select-R16SourceRefs -SourceRefMap $sourceRefMap -RefIds @("r15_stale_final_proof_package", "r15_stale_evidence_index", "r16_authority")) -BudgetCategory "small_exact_ref_load" -Summary "Deprecated/stale cleanup candidate context preserving the R15-009 generated_from caveat without rewriting audited evidence." -GeneratedFromHead $head -GeneratedFromTree $tree)
    )

    if ($branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "R16 memory layer generation must run on release/r16-operational-memory-artifact-map-role-workflow-foundation, not '$branch'."
    }

    return [ordered]@{
        artifact_type = "r16_memory_layers"
        artifact_version = "v1"
        memory_layer_artifact_id = "aioffice-r16-005-baseline-memory-layers-v1"
        source_milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
        source_task = "R16-005"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $branch
        generated_from_head = $head
        generated_from_tree = $tree
        contract_ref = [ordered]@{
            path = "contracts/memory/r16_memory_layer.contract.json"
            contract_id = $contractResult.ContractId
            contract_source_task = "R16-004"
            proof_treatment = "contract_model_only_not_runtime_memory"
            exact_load_only = $true
        }
        generator = [ordered]@{
            module_path = "tools/R16MemoryLayerGenerator.psm1"
            cli_path = "tools/new_r16_memory_layers.ps1"
            validator_path = "tools/validate_r16_memory_layers.ps1"
            deterministic_output_ordering = $true
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
            stale_refs_fail_closed_without_caveat = $true
            generated_reports_as_machine_proof = $false
            planning_reports_as_implementation_proof = $false
        }
        generation_mode = [ordered]@{
            deterministic_memory_layer_generator_implemented = $true
            baseline_memory_layer_state_artifact_generated = $true
            baseline_memory_layers_are_state_artifacts = $true
            generated_baseline_memory_layers_are_runtime_memory = $false
            role_specific_memory_packs_implemented = $false
            artifact_maps_implemented = $false
            audit_maps_implemented = $false
            context_load_planner_implemented = $false
            context_budget_estimator_implemented = $false
            role_run_envelopes_implemented = $false
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
            r16_006_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        current_posture = [ordered]@{
            active_through_task = "R16-005"
            complete_tasks = @("R16-001", "R16-002", "R16-003", "R16-004", "R16-005")
            planned_tasks = @(6..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            r16_006_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            posture_statement = "R16 active through R16-005 only; R16-006 through R16-026 remain planned only."
        }
        generation_inputs = [ordered]@{
            source_ref_count = $sourceRefs.Count
            exact_source_refs = $sourceRefs
            contract_allowed_layer_types = [string[]]$contract.allowed_layer_types
            contract_allowed_authority_classes = [string[]]$contract.allowed_authority_classes
            contract_allowed_proof_treatments = $allowedProofTreatmentIds
        }
        layer_records = $layers
        non_claims = $script:RequiredNonClaims
        preserved_boundaries = [ordered]@{
            r13 = [ordered]@{
                status = "failed/partial"
                active_through = "R13-018"
                closed = $false
                partial_gates_remain_partial = $true
                partial_gates = @("API/custom-runner bypass", "current operator control room", "skill invocation evidence", "operator demo")
            }
            r14 = [ordered]@{
                status = "accepted_with_caveats"
                through = "R14-006"
                caveats_removed = $false
                product_runtime = $false
                r13_partial_gates_converted_to_passed = $false
            }
            r15 = [ordered]@{
                status = "accepted_with_caveats"
                through = "R15-009"
                audited_head = "d9685030a0556a528684d28367db83f4c72f7fc9"
                audited_tree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
                post_audit_support_commit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"
                caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
                stale_generated_from_caveat_files = @(
                    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json",
                    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
                )
            }
        }
        validation_commands = @($script:RequiredValidationCommands | ForEach-Object { [ordered]@{ command = $_; required = $true } })
        invalid_state_rules = @($script:RequiredInvalidRuleIds | ForEach-Object { [ordered]@{ rule_id = $_; description = "Fail closed for $($_ -replace '_', ' ')." } })
        generated_artifact_statement = "Generated baseline memory layers are committed state artifacts, not runtime memory. They prepare the substrate for R16-006/R16-007 role-specific memory pack work without implementing those packs."
    }
}

function Write-R16MemoryLayerJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $MemoryLayers,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRepositoryRoot = if (Test-Path -LiteralPath $RepositoryRoot) {
        (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }
    else {
        [System.IO.Path]::GetFullPath($RepositoryRoot)
    }
    $resolvedOutputPath = Assert-SafeRepoRelativeFilePath -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -Context "OutputPath"
    $parent = Split-Path -Parent $resolvedOutputPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $MemoryLayers | ConvertTo-Json -Depth 100
    $json = $json -replace "`r`n", "`n"
    $json = $json -replace "`r", "`n"
    [System.IO.File]::WriteAllText($resolvedOutputPath, ($json + "`n"), [System.Text.UTF8Encoding]::new($false))

    return $resolvedOutputPath
}

function New-R16MemoryLayers {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state\memory\r16_memory_layers.json",
        [string]$ContractPath = "contracts\memory\r16_memory_layer.contract.json",
        [string]$RepositoryRoot = $repoRoot
    )

    $memoryLayers = New-R16MemoryLayerObject -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    $writtenPath = Write-R16MemoryLayerJson -MemoryLayers $memoryLayers -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Test-R16MemoryLayersObject -MemoryLayers $memoryLayers -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot | Out-Null

    return [pscustomobject]@{
        OutputPath = $writtenPath
        LayerCount = @($memoryLayers.layer_records).Count
        LayerTypes = @($memoryLayers.layer_records | ForEach-Object { $_.layer_type })
        GeneratedFromHead = $memoryLayers.generated_from_head
        GeneratedFromTree = $memoryLayers.generated_from_tree
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
    if ([System.IO.Path]::IsPathRooted($path)) {
        throw "$Context path must be repo-relative exact path."
    }
    if ($path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context path must not traverse outside the repository."
    }

    $resolvedPath = Resolve-RepoRelativePathValue -Path $path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$path' does not exist."
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
    if (Test-GeneratedReportPath -Path $path) {
        if ($machineProof -or $SourceRef.proof_treatment -eq "committed_machine_evidence") {
            throw "$Context generated report treated as machine proof is rejected."
        }
    }
    if (Test-PlanningReportPath -Path $path) {
        if ($implementationProof) {
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
    if ($postureObject.active_through_task -ne "R16-005") {
        throw "$Context active_through_task must be R16-005."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"

    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in @($completeTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 6) {
            throw "$Context claims R16-006 implementation with '$taskId'."
        }
    }

    Assert-ExactStringSet -Values $completeTasks -ExpectedValues @("R16-001", "R16-002", "R16-003", "R16-004", "R16-005") -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues @(6..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") }) -Context "$Context planned_tasks"

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_006_or_later_implementation_claimed" -Context $Context) -Context "$Context r16_006_or_later_implementation_claimed") -ne $false) {
        throw "$Context r16_006_or_later_implementation_claimed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_027_or_later_task_exists" -Context $Context) -Context "$Context r16_027_or_later_task_exists") -ne $false) {
        throw "$Context r16_027_or_later_task_exists must be False."
    }
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
    foreach ($falseField in @("broad_scan_allowed", "full_repo_scan_allowed", "wildcard_path_allowed", "runtime_memory_loading_allowed", "retrieval_runtime_allowed", "vector_search_runtime_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $loadRules -Name $falseField -Context "$Context load_rules") -Context "$Context load_rules $falseField") -ne $false) {
            throw "$Context load_rules $falseField must be False."
        }
    }

    $contextBudget = Assert-ObjectValue -Value $Record.context_budget -Context "$Context context_budget"
    foreach ($falseField in @("full_repo_scan_budget_allowed", "runtime_retrieval_budget_allowed", "vector_search_budget_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $contextBudget -Name $falseField -Context "$Context context_budget") -Context "$Context context_budget $falseField") -ne $false) {
            throw "$Context context_budget $falseField must be False."
        }
    }

    Assert-ObjectValue -Value $Record.exclusion_rules -Context "$Context exclusion_rules" | Out-Null
    Assert-ObjectValue -Value $Record.evidence_requirements -Context "$Context evidence_requirements" | Out-Null
    Assert-StringArray -Value $Record.allowed_content -Context "$Context allowed_content" | Out-Null
    Assert-StringArray -Value $Record.forbidden_content -Context "$Context forbidden_content" | Out-Null
    Assert-StringArray -Value $Record.non_claims -Context "$Context non_claims" | Out-Null

    $sourceRefs = Assert-ObjectArray -Value $Record.source_refs -Context "$Context source_refs"
    for ($index = 0; $index -lt $sourceRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $sourceRefs[$index] -Context "$Context source_refs[$index]" -AllowedAuthorityClasses $AllowedAuthorityClasses -AllowedSourceRefTypes $AllowedSourceRefTypes -AllowedProofTreatmentIds $AllowedProofTreatmentIds -RepositoryRoot $RepositoryRoot
    }
}

function Test-R16MemoryLayersObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $MemoryLayers,
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [string]$RepositoryRoot = $repoRoot,
        [string]$SourceLabel = "R16 memory layers"
    )

    $resolvedRepositoryRoot = if (Test-Path -LiteralPath $RepositoryRoot) {
        (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }
    else {
        [System.IO.Path]::GetFullPath($RepositoryRoot)
    }
    $resolvedContractPath = if ([System.IO.Path]::IsPathRooted($ContractPath)) {
        [System.IO.Path]::GetFullPath($ContractPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $resolvedRepositoryRoot $ContractPath))
    }

    if (-not (Test-Path -LiteralPath $resolvedContractPath -PathType Leaf)) {
        throw "R16 memory layer contract '$ContractPath' is missing."
    }

    $contractResult = Test-R16MemoryLayerContract -ContractPath $resolvedContractPath -RepositoryRoot $resolvedRepositoryRoot
    $contract = Read-SingleJsonObject -Path $resolvedContractPath -Label "R16 memory layer contract"
    $allowedLayerTypes = [string[]]$contract.allowed_layer_types
    $allowedAuthorityClasses = [string[]]$contract.allowed_authority_classes
    $allowedScopeKinds = [string[]]$contract.allowed_memory_scope_kinds
    $allowedSourceRefTypes = [string[]]$contract.allowed_source_ref_types
    $allowedProofTreatmentIds = Get-ProofTreatmentIds -AllowedProofTreatments $contract.allowed_proof_treatments -Context "$ContractPath allowed_proof_treatments"

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $MemoryLayers -Name $field -Context $SourceLabel | Out-Null
    }

    if ($MemoryLayers.artifact_type -ne "r16_memory_layers") {
        throw "$SourceLabel artifact_type must be r16_memory_layers."
    }
    if ($MemoryLayers.source_task -ne "R16-005") {
        throw "$SourceLabel source_task must be R16-005."
    }
    if ($MemoryLayers.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($MemoryLayers.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }

    $policy = Assert-ObjectValue -Value $MemoryLayers.generation_policy -Context "$SourceLabel generation_policy"
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_requested", "full_repo_scan_allowed", "full_repo_scan_requested", "wildcard_source_refs_allowed", "generated_reports_as_machine_proof", "planning_reports_as_implementation_proof")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policy -Name $falseField -Context "$SourceLabel generation_policy") -Context "$SourceLabel generation_policy $falseField") -ne $false) {
            throw "$SourceLabel generation_policy $falseField must be False."
        }
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policy -Name "source_refs_are_exact_repo_relative_paths" -Context "$SourceLabel generation_policy") -Context "$SourceLabel generation_policy source_refs_are_exact_repo_relative_paths") -ne $true) {
        throw "$SourceLabel generation_policy source_refs_are_exact_repo_relative_paths must be True."
    }

    $mode = Assert-ObjectValue -Value $MemoryLayers.generation_mode -Context "$SourceLabel generation_mode"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "deterministic_memory_layer_generator_implemented" -Context "$SourceLabel generation_mode") -Context "$SourceLabel generation_mode deterministic_memory_layer_generator_implemented") -ne $true) {
        throw "$SourceLabel generation_mode deterministic_memory_layer_generator_implemented must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "baseline_memory_layer_state_artifact_generated" -Context "$SourceLabel generation_mode") -Context "$SourceLabel generation_mode baseline_memory_layer_state_artifact_generated") -ne $true) {
        throw "$SourceLabel generation_mode baseline_memory_layer_state_artifact_generated must be True."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name "baseline_memory_layers_are_state_artifacts" -Context "$SourceLabel generation_mode") -Context "$SourceLabel generation_mode baseline_memory_layers_are_state_artifacts") -ne $true) {
        throw "$SourceLabel generation_mode baseline_memory_layers_are_state_artifacts must be True."
    }
    Assert-FalseFields -Object $mode -Fields $script:ForbiddenFalseFields -Context "$SourceLabel generation_mode"

    Assert-CurrentPosture -Posture $MemoryLayers.current_posture -Context "$SourceLabel current_posture"

    $inputObject = Assert-ObjectValue -Value $MemoryLayers.generation_inputs -Context "$SourceLabel generation_inputs"
    $inputRefs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $inputObject -Name "exact_source_refs" -Context "$SourceLabel generation_inputs") -Context "$SourceLabel generation_inputs exact_source_refs"
    for ($index = 0; $index -lt $inputRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $inputRefs[$index] -Context "$SourceLabel generation_inputs exact_source_refs[$index]" -AllowedAuthorityClasses $allowedAuthorityClasses -AllowedSourceRefTypes $allowedSourceRefTypes -AllowedProofTreatmentIds $allowedProofTreatmentIds -RepositoryRoot $resolvedRepositoryRoot
    }

    $layers = Assert-ObjectArray -Value $MemoryLayers.layer_records -Context "$SourceLabel layer_records"
    $layerTypes = @($layers | ForEach-Object { [string]$_.layer_type })
    Assert-ExactStringSet -Values $layerTypes -ExpectedValues $script:ExpectedLayerTypes -Context "$SourceLabel layer_records layer_type"
    for ($index = 0; $index -lt $layers.Count; $index += 1) {
        Assert-LayerRecord -Record $layers[$index] -Context "$SourceLabel layer_records[$index]" -AllowedLayerTypes $allowedLayerTypes -AllowedAuthorityClasses $allowedAuthorityClasses -AllowedScopeKinds $allowedScopeKinds -AllowedSourceRefTypes $allowedSourceRefTypes -AllowedProofTreatmentIds $allowedProofTreatmentIds -RepositoryRoot $resolvedRepositoryRoot
    }

    $nonClaims = Assert-StringArray -Value $MemoryLayers.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    Assert-PreservedBoundaries -Value $MemoryLayers.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $validationCommands = Assert-ObjectArray -Value $MemoryLayers.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidStateRules = Assert-ObjectArray -Value $MemoryLayers.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $statement = Assert-NonEmptyString -Value $MemoryLayers.generated_artifact_statement -Context "$SourceLabel generated_artifact_statement"
    if ($statement -notmatch 'state artifacts, not runtime memory') {
        throw "$SourceLabel generated_artifact_statement must state that generated baseline memory layers are state artifacts, not runtime memory."
    }
    if ($statement -match '(?i)runtime memory loading|persistent memory runtime|retrieval runtime|vector search runtime') {
        throw "$SourceLabel generated_artifact_statement contains a runtime memory/retrieval overclaim."
    }

    return [pscustomobject]@{
        ArtifactId = $MemoryLayers.memory_layer_artifact_id
        SourceTask = $MemoryLayers.source_task
        LayerCount = $layers.Count
        LayerTypes = [string[]]$layerTypes
        ActiveThroughTask = $MemoryLayers.current_posture.active_through_task
        PlannedTaskStart = $MemoryLayers.current_posture.planned_tasks[0]
        PlannedTaskEnd = $MemoryLayers.current_posture.planned_tasks[-1]
        GeneratedFromHead = $MemoryLayers.generated_from_head
        GeneratedFromTree = $MemoryLayers.generated_from_tree
        ContractId = $contractResult.ContractId
        BaselineStateArtifactGenerated = [bool]$mode.baseline_memory_layer_state_artifact_generated
        RuntimeMemoryLoadingImplemented = [bool]$mode.runtime_memory_loading_implemented
        RetrievalRuntimeImplemented = [bool]$mode.retrieval_runtime_implemented
        VectorSearchRuntimeImplemented = [bool]$mode.vector_search_runtime_implemented
        RoleSpecificMemoryPacksImplemented = [bool]$mode.role_specific_memory_packs_implemented
    }
}

function Test-R16MemoryLayers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MemoryLayersPath,
        [Parameter(Mandatory = $true)]
        [string]$ContractPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $memoryLayers = Read-SingleJsonObject -Path $MemoryLayersPath -Label "R16 memory layers"
    return Test-R16MemoryLayersObject -MemoryLayers $memoryLayers -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot -SourceLabel $MemoryLayersPath
}

Export-ModuleMember -Function New-R16MemoryLayerObject, New-R16MemoryLayers, Test-R16MemoryLayers, Test-R16MemoryLayersObject, Write-R16MemoryLayerJson
