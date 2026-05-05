Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16AuditMapContract.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapGenerator.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:R15Milestone = "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "1b7a8969dcdefe464cef2fac16dd15f4b17f1e15"
$script:InputTree = "3f20f23d156b47f7334ed596861247d133861bd6"
$script:R15AuditedHead = "d9685030a0556a528684d28367db83f4c72f7fc9"
$script:R15AuditedTree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
$script:R15FinalPackageGeneratedHead = "5865422a1a1c0bf6f347346a95087ee33e055da3"
$script:R15FinalPackageGeneratedTree = "c2d8f3e8f59e3f7785a0f8261f82204bcbb4af22"
$script:R15PostAuditSupportCommit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"

$script:RequiredEntryFields = @(
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

$script:RequiredValidationCommandFields = @(
    "command_id",
    "command",
    "expected_result",
    "validates_path",
    "evidence_kind",
    "required_for_closeout",
    "deterministic_order"
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

$script:AllowedAuthorityLevels = @(
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

$script:AllowedAuthorityClasses = @(
    "governance_authority",
    "milestone_authority",
    "contract_authority",
    "state_authority",
    "validation_authority",
    "proof_authority",
    "operator_context",
    "planning_authority",
    "context_authority",
    "external_evidence",
    "rejected_authority"
)

$script:AllowedProofStatuses = @(
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

$script:AllowedAuditReadinessStatuses = @(
    "ready_for_exact_inspection",
    "ready_with_caveat",
    "context_only",
    "not_implementation_proof",
    "rejected_overclaim",
    "missing_required_ref",
    "stale_without_caveat",
    "planned_only"
)

$script:RequiredFindingFields = @(
    "missing_required_paths",
    "wildcard_paths",
    "broad_repo_root_paths",
    "directory_only_proof_claims",
    "stale_refs_without_caveat",
    "report_as_machine_proof_errors",
    "runtime_overclaims",
    "context_planner_overclaims",
    "artifact_diff_tooling_overclaims",
    "later_task_overclaims",
    "r13_boundary_violations",
    "r14_caveat_removals",
    "r15_caveat_removals"
)

$script:RequiredNonClaims = @(
    "no artifact-map diff/check tooling",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
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
    "no R13 partial-gate conversion"
)

$script:RequiredAuditPaths = @(
    "README.md",
    "governance/ACTIVE_STATE.md",
    "execution/KANBAN.md",
    "governance/DECISION_LOG.md",
    "governance/DOCUMENT_AUTHORITY_INDEX.md",
    "governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md",
    "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
    "governance/reports/AIOffice_V2_R15_Proof_Review_Package_and_R16_Readiness_Recommendation_v1.md",
    "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/post_audit_acceptance/r15_post_audit_acceptance_packet.json",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/post_audit_acceptance/README.md",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/post_audit_acceptance/validation_manifest.md",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/README.md",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/validation_manifest.md",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/non_claims.json",
    "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/rejected_claims.json",
    "state/governance/r16_planning_authority_reference.json",
    "contracts/governance/r16_planning_authority_reference.contract.json",
    "tools/R16PlanningAuthorityReference.psm1",
    "tools/validate_r16_planning_authority_reference.ps1",
    "tests/test_r16_planning_authority_reference.ps1",
    "state/governance/r16_kpi_baseline_target_scorecard.json",
    "contracts/governance/r16_kpi_baseline_target_scorecard.contract.json",
    "tools/R16KpiBaselineTargetScorecard.psm1",
    "tools/validate_r16_kpi_baseline_target_scorecard.ps1",
    "tests/test_r16_kpi_baseline_target_scorecard.ps1",
    "contracts/memory/r16_memory_layer.contract.json",
    "tools/R16MemoryLayerContract.psm1",
    "tools/validate_r16_memory_layer_contract.ps1",
    "tests/test_r16_memory_layer_contract.ps1",
    "tools/R16MemoryLayerGenerator.psm1",
    "tools/new_r16_memory_layers.ps1",
    "tools/validate_r16_memory_layers.ps1",
    "tests/test_r16_memory_layer_generator.ps1",
    "state/memory/r16_memory_layers.json",
    "contracts/memory/r16_role_memory_pack_model.contract.json",
    "tools/R16RoleMemoryPackModel.psm1",
    "tools/validate_r16_role_memory_pack_model.ps1",
    "tests/test_r16_role_memory_pack_model.ps1",
    "state/memory/r16_role_memory_pack_model.json",
    "tools/R16RoleMemoryPackGenerator.psm1",
    "tools/new_r16_role_memory_packs.ps1",
    "tools/validate_r16_role_memory_packs.ps1",
    "tests/test_r16_role_memory_pack_generator.ps1",
    "state/memory/r16_role_memory_packs.json",
    "contracts/memory/r16_memory_pack_validation_report.contract.json",
    "tools/R16MemoryPackValidation.psm1",
    "tools/test_r16_memory_pack_refs.ps1",
    "tools/validate_r16_memory_pack_validation_report.ps1",
    "tests/test_r16_memory_pack_validation.ps1",
    "state/memory/r16_memory_pack_validation_report.json",
    "contracts/artifacts/r16_artifact_map.contract.json",
    "tools/R16ArtifactMapContract.psm1",
    "tools/validate_r16_artifact_map_contract.ps1",
    "tests/test_r16_artifact_map_contract.ps1",
    "tools/R16ArtifactMapGenerator.psm1",
    "tools/new_r16_artifact_map.ps1",
    "tools/validate_r16_artifact_map.ps1",
    "tests/test_r16_artifact_map_generator.ps1",
    "state/artifacts/r16_artifact_map.json",
    "contracts/audit/r16_audit_map.contract.json",
    "tools/R16AuditMapContract.psm1",
    "tools/validate_r16_audit_map_contract.ps1",
    "tests/test_r16_audit_map_contract.ps1",
    "tests/fixtures/r16_audit_map_contract/valid_audit_map_contract.json",
    "tests/fixtures/r16_audit_map_contract/invalid_missing_required_field.json",
    "tests/fixtures/r16_audit_map_contract/invalid_generated_audit_map_claim.json",
    "tests/fixtures/r16_audit_map_contract/invalid_audit_map_generator_claim.json",
    "tests/fixtures/r16_audit_map_contract/invalid_runtime_memory_claim.json",
    "tests/fixtures/r16_audit_map_contract/invalid_context_planner_claim.json",
    "tests/fixtures/r16_audit_map_contract/invalid_broad_scan_policy.json",
    "tests/fixtures/r16_audit_map_contract/invalid_wildcard_path_policy.json",
    "tests/fixtures/r16_audit_map_contract/invalid_report_as_machine_proof.json",
    "tests/fixtures/r16_audit_map_contract/invalid_r16_012_claim.json",
    "tests/fixtures/r16_audit_map_contract/invalid_r13_boundary_change.json",
    "tests/fixtures/r16_audit_map_contract/invalid_r14_caveat_removed.json",
    "tests/fixtures/r16_audit_map_contract/invalid_r15_caveat_removed.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_011_audit_map_contract/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_011_audit_map_contract/evidence_index.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_011_audit_map_contract/validation_manifest.md",
    "tools/R16AuditMapGenerator.psm1",
    "tools/new_r16_audit_map.ps1",
    "tools/validate_r16_audit_map.ps1",
    "tests/test_r16_audit_map_generator.ps1",
    "state/audit/r16_r15_r16_audit_map.json",
    "tests/fixtures/r16_audit_map_generator/valid_audit_map.json",
    "tests/fixtures/r16_audit_map_generator/invalid_missing_evidence_path.json",
    "tests/fixtures/r16_audit_map_generator/invalid_wildcard_evidence_path.json",
    "tests/fixtures/r16_audit_map_generator/invalid_broad_scan_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_directory_only_proof_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_runtime_memory_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_context_planner_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_artifact_diff_tooling_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_report_as_machine_proof.json",
    "tests/fixtures/r16_audit_map_generator/invalid_stale_ref_without_caveat.json",
    "tests/fixtures/r16_audit_map_generator/invalid_r16_013_claim.json",
    "tests/fixtures/r16_audit_map_generator/invalid_r13_boundary_change.json",
    "tests/fixtures/r16_audit_map_generator/invalid_r14_caveat_removed.json",
    "tests/fixtures/r16_audit_map_generator/invalid_r15_caveat_removed.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/evidence_index.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/validation_manifest.md"
)

$script:ValidationCommandDefinitions = @(
    @{ Id = "new_r16_audit_map"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_audit_map.ps1"; Path = "state/audit/r16_r15_r16_audit_map.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_audit_map"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_map.ps1"; Path = "state/audit/r16_r15_r16_audit_map.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_audit_map_generator"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_map_generator.ps1"; Path = "tests/test_r16_audit_map_generator.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_audit_map_contract"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_map_contract.ps1"; Path = "contracts/audit/r16_audit_map.contract.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_audit_map_contract"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_map_contract.ps1"; Path = "tests/test_r16_audit_map_contract.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_artifact_map"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map.ps1"; Path = "state/artifacts/r16_artifact_map.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_artifact_map_generator"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_generator.ps1"; Path = "tests/test_r16_artifact_map_generator.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_artifact_map_contract"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map_contract.ps1"; Path = "contracts/artifacts/r16_artifact_map.contract.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_artifact_map_contract"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_contract.ps1"; Path = "tests/test_r16_artifact_map_contract.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_status_doc_gate"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1"; Path = "tools/validate_status_doc_gate.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_status_doc_gate"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1"; Path = "tests/test_status_doc_gate.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_memory_pack_validation"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_pack_validation.ps1"; Path = "tests/test_r16_memory_pack_validation.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_memory_pack_validation_report"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_pack_validation_report.ps1"; Path = "state/memory/r16_memory_pack_validation_report.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_memory_layers"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layers.ps1 -MemoryLayersPath state/memory/r16_memory_layers.json -ContractPath contracts/memory/r16_memory_layer.contract.json"; Path = "state/memory/r16_memory_layers.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_memory_layer_generator"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_generator.ps1"; Path = "tests/test_r16_memory_layer_generator.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_role_memory_packs"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1 -PacksPath state/memory/r16_role_memory_packs.json -ModelPath state/memory/r16_role_memory_pack_model.json -MemoryLayersPath state/memory/r16_memory_layers.json"; Path = "state/memory/r16_role_memory_packs.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_role_memory_pack_generator"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1"; Path = "tests/test_r16_role_memory_pack_generator.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_kpi_baseline_target_scorecard"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json"; Path = "state/governance/r16_kpi_baseline_target_scorecard.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_kpi_baseline_target_scorecard"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1"; Path = "tests/test_r16_kpi_baseline_target_scorecard.ps1"; Kind = "machine_validated"; Required = $true },
    @{ Id = "validate_r16_planning_authority_reference"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json"; Path = "state/governance/r16_planning_authority_reference.json"; Kind = "machine_validated"; Required = $true },
    @{ Id = "test_r16_planning_authority_reference"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1"; Path = "tests/test_r16_planning_authority_reference.ps1"; Kind = "machine_validated"; Required = $true }
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

function Assert-RequiredValuesPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$RequiredValues,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context missing required path '$requiredValue'."
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

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-DirectoryLikePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/").EndsWith("/")
}

function Resolve-RepoRelativePathValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
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
    if (Test-DirectoryLikePath -Path $Path) {
        throw "$Context rejects directory-only proof claim '$Path'."
    }
    if ($Path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }

    $resolved = Resolve-RepoRelativePathValue -Path $Path -RepositoryRoot $RepositoryRoot
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

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, (ConvertTo-StableJson -Object $Object) + "`n", $encoding)
}

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function ConvertTo-AuditIdPart {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.ToLowerInvariant() -replace '[^a-z0-9]+', '_'
    return $normalized.Trim("_")
}

function Get-ContentTypeForPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    switch ($extension) {
        ".json" { return "json" }
        ".ps1" { return "powershell_cli" }
        ".psm1" { return "powershell_module" }
        ".md" { return "markdown" }
        default { return "text" }
    }
}

function New-ValidationCommandRef {
    param([Parameter(Mandatory = $true)]$Definition)

    return [ordered]@{
        command_id = $Definition.Id
        command = $Definition.Command
        expected_result = "PASS"
        validates_path = $Definition.Path.Replace("\", "/")
        evidence_kind = $Definition.Kind
        required_for_closeout = [bool]$Definition.Required
        deterministic_order = 0
    }
}

function Get-ValidationCommandsForPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Replace("\", "/")
    $matches = @($script:ValidationCommandDefinitions | Where-Object {
        $_.Path.Replace("\", "/") -eq $normalized -or
        ($normalized -eq "state/audit/r16_r15_r16_audit_map.json" -and $_.Id -in @("new_r16_audit_map", "validate_r16_audit_map", "test_r16_audit_map_generator")) -or
        ($normalized -in @("README.md", "governance/ACTIVE_STATE.md", "execution/KANBAN.md", "governance/DECISION_LOG.md", "governance/DOCUMENT_AUTHORITY_INDEX.md", "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md") -and $_.Id -in @("validate_status_doc_gate", "test_status_doc_gate")) -or
        ($normalized -like "contracts/audit/*" -and $_.Id -in @("validate_r16_audit_map_contract", "test_r16_audit_map_contract")) -or
        ($normalized -like "contracts/artifacts/*" -and $_.Id -in @("validate_r16_artifact_map_contract", "test_r16_artifact_map_contract")) -or
        ($normalized -like "state/memory/r16_memory_layers.json" -and $_.Id -in @("validate_r16_memory_layers", "test_r16_memory_layer_generator")) -or
        ($normalized -like "state/memory/r16_role_memory_packs.json" -and $_.Id -in @("validate_r16_role_memory_packs", "test_r16_role_memory_pack_generator")) -or
        ($normalized -like "state/memory/r16_memory_pack_validation_report.json" -and $_.Id -in @("validate_r16_memory_pack_validation_report", "test_r16_memory_pack_validation")) -or
        ($normalized -like "state/governance/r16_kpi_baseline_target_scorecard.json" -and $_.Id -in @("validate_r16_kpi_baseline_target_scorecard", "test_r16_kpi_baseline_target_scorecard")) -or
        ($normalized -like "state/governance/r16_planning_authority_reference.json" -and $_.Id -in @("validate_r16_planning_authority_reference", "test_r16_planning_authority_reference"))
    })

    $commands = @()
    for ($index = 0; $index -lt $matches.Count; $index += 1) {
        $command = New-ValidationCommandRef -Definition $matches[$index]
        $command.deterministic_order = $index + 1
        $commands += $command
    }

    return $commands
}

function Get-AuditClassification {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$SourceTask,
        [string]$ArtifactClass,
        [string]$ArtifactRole,
        [string]$EvidenceKind,
        [string]$ProofStatus
    )

    $normalized = $Path.Replace("\", "/")
    $isInvalidFixture = $normalized -like "tests/fixtures/*/invalid_*.json"

    if ($isInvalidFixture) {
        return [pscustomobject]@{
            ArtifactType = "rejected_fixture"
            AuthorityLevel = "local_only_rejected"
            AuthorityClass = "rejected_authority"
            EvidenceKind = "rejected_overclaim_fixture"
            ProofStatus = "local_only_rejected"
            ProofTreatment = "negative fixture for fail-closed validation only, not closeout evidence"
            AuditReadinessStatus = "not_implementation_proof"
            RequiredForCloseout = $false
        }
    }

    if ($normalized -eq "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md" -or $normalized -eq "governance/R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md") {
        return [pscustomobject]@{
            ArtifactType = "milestone_authority_document"
            AuthorityLevel = "milestone_authority"
            AuthorityClass = "milestone_authority"
            EvidenceKind = "narrative_context"
            ProofStatus = "narrative_context_only"
            ProofTreatment = "milestone scope authority and narrative operating context"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -match '^(README\.md|governance/ACTIVE_STATE\.md|governance/DECISION_LOG\.md|governance/DOCUMENT_AUTHORITY_INDEX\.md)$') {
        return [pscustomobject]@{
            ArtifactType = "governance_authority_document"
            AuthorityLevel = "governance_authority"
            AuthorityClass = "governance_authority"
            EvidenceKind = "narrative_context"
            ProofStatus = "narrative_context_only"
            ProofTreatment = "repo-truth governance authority, not machine proof by itself"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -eq "execution/KANBAN.md") {
        return [pscustomobject]@{
            ArtifactType = "operator_report"
            AuthorityLevel = "operator_report"
            AuthorityClass = "operator_context"
            EvidenceKind = "operator_report"
            ProofStatus = "operator_artifact_only"
            ProofTreatment = "operator status surface only, validated by status-doc gate"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "governance/reports/*") {
        return [pscustomobject]@{
            ArtifactType = "planning_report"
            AuthorityLevel = "planning_artifact"
            AuthorityClass = "planning_authority"
            EvidenceKind = "planning_report"
            ProofStatus = "planning_artifact_only"
            ProofTreatment = "planning/report artifact only, not implementation proof by itself"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "contracts/*") {
        return [pscustomobject]@{
            ArtifactType = "contract"
            AuthorityLevel = "contract_authority"
            AuthorityClass = "contract_authority"
            EvidenceKind = "contract_schema"
            ProofStatus = "contract_only"
            ProofTreatment = "contract/schema authority, not runtime behavior"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "tools/new_*" -or $normalized -like "tools/validate_*" -or $normalized -like "tools/test_*") {
        return [pscustomobject]@{
            ArtifactType = "validation_cli"
            AuthorityLevel = "validation_report"
            AuthorityClass = "validation_authority"
            EvidenceKind = "validation_cli"
            ProofStatus = "machine_validated"
            ProofTreatment = "committed CLI wrapper, machine evidence only when command-backed"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "tools/R16*Generator.psm1") {
        return [pscustomobject]@{
            ArtifactType = "generator_module"
            AuthorityLevel = "validation_report"
            AuthorityClass = "validation_authority"
            EvidenceKind = "generator_module"
            ProofStatus = "machine_validated"
            ProofTreatment = "committed generator module validated by focused commands"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "tools/*.psm1") {
        return [pscustomobject]@{
            ArtifactType = "validation_module"
            AuthorityLevel = "validation_report"
            AuthorityClass = "validation_authority"
            EvidenceKind = "validator_module"
            ProofStatus = "machine_validated"
            ProofTreatment = "committed validation module, machine evidence only when command-backed"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "tests/test_*.ps1") {
        return [pscustomobject]@{
            ArtifactType = "test"
            AuthorityLevel = "validation_report"
            AuthorityClass = "validation_authority"
            EvidenceKind = "focused_test"
            ProofStatus = "machine_validated"
            ProofTreatment = "focused test command evidence"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "tests/fixtures/*/valid_*.json") {
        return [pscustomobject]@{
            ArtifactType = "fixture"
            AuthorityLevel = "validation_report"
            AuthorityClass = "validation_authority"
            EvidenceKind = "valid_fixture"
            ProofStatus = "machine_validated"
            ProofTreatment = "valid fixture for validator harness"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "state/audit/*.json" -or $normalized -like "state/artifacts/*.json" -or $normalized -like "state/memory/*.json" -or $normalized -like "state/governance/*.json") {
        return [pscustomobject]@{
            ArtifactType = "committed_generated_state_artifact"
            AuthorityLevel = "generated_state_artifact"
            AuthorityClass = "state_authority"
            EvidenceKind = "generated_state_artifact"
            ProofStatus = "validator_backed_state_artifact"
            ProofTreatment = "committed generated state artifact only, not runtime memory"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "state/proof_reviews/*/evidence_index.json") {
        return [pscustomobject]@{
            ArtifactType = "evidence_index"
            AuthorityLevel = "evidence_index"
            AuthorityClass = "proof_authority"
            EvidenceKind = "evidence_index"
            ProofStatus = "proof_review_only"
            ProofTreatment = "exact evidence index for proof review, not machine proof by itself"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "state/proof_reviews/*/validation_manifest.md") {
        return [pscustomobject]@{
            ArtifactType = "validation_manifest"
            AuthorityLevel = "validation_manifest"
            AuthorityClass = "proof_authority"
            EvidenceKind = "validation_manifest"
            ProofStatus = "validation_manifest_only"
            ProofTreatment = "manifest of executed commands only"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "state/proof_reviews/*/proof_review.json" -or $normalized -like "state/proof_reviews/*/*proof_review_package.json") {
        return [pscustomobject]@{
            ArtifactType = "proof_review_package"
            AuthorityLevel = "proof_review_package"
            AuthorityClass = "proof_authority"
            EvidenceKind = "proof_review_package"
            ProofStatus = "proof_review_only"
            ProofTreatment = "proof-review package context, not machine proof by itself"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    if ($normalized -like "state/external_runs/*") {
        return [pscustomobject]@{
            ArtifactType = "external_replay_evidence"
            AuthorityLevel = "external_evidence"
            AuthorityClass = "external_evidence"
            EvidenceKind = "external_replay_evidence"
            ProofStatus = "external_replay_evidence"
            ProofTreatment = "external replay evidence only when exact run identity is present"
            AuditReadinessStatus = "ready_for_exact_inspection"
            RequiredForCloseout = $false
        }
    }

    if ($normalized -like "state/proof_reviews/*") {
        return [pscustomobject]@{
            ArtifactType = "proof_review_package"
            AuthorityLevel = "proof_review_package"
            AuthorityClass = "proof_authority"
            EvidenceKind = "proof_review_package"
            ProofStatus = "proof_review_only"
            ProofTreatment = "proof-review supporting artifact, not machine proof by itself"
            AuditReadinessStatus = "context_only"
            RequiredForCloseout = $true
        }
    }

    return [pscustomobject]@{
        ArtifactType = "narrative_context"
        AuthorityLevel = "narrative_context"
        AuthorityClass = "context_authority"
        EvidenceKind = if ([string]::IsNullOrWhiteSpace($EvidenceKind)) { "narrative_context" } else { $EvidenceKind }
        ProofStatus = "narrative_context_only"
        ProofTreatment = "context only"
        AuditReadinessStatus = "context_only"
        RequiredForCloseout = $false
    }
}

function New-InspectionRoute {
    param(
        [Parameter(Mandatory = $true)][string]$AuditEntryId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ArtifactType
    )

    return [ordered]@{
        route_id = ("{0}_inspection" -f $AuditEntryId)
        route_kind = "exact_file_read"
        evidence_path = $Path.Replace("\", "/")
        reader_role = "evidence_auditor"
        exact_command = ("Get-Content -LiteralPath {0}" -f $Path.Replace("/", "\"))
        expected_content_type = Get-ContentTypeForPath -Path $Path
        broad_scan_allowed = $false
        wildcard_allowed = $false
        fallback_allowed = $false
        fallback_route = "none"
        audit_notes = ("Inspect this exact repo-relative {0} path only; do not infer from broad repo scans or wildcard expansion." -f $ArtifactType)
    }
}

function New-AuditEntry {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$ArtifactId,
        [string]$SourceTask = "R16-012",
        [string]$SourceMilestone = $script:R16Milestone,
        [string]$ArtifactClass = "",
        [string]$ArtifactRole = "",
        [string]$EvidenceKind = "",
        [string]$ProofStatus = "",
        [string[]]$NonClaims,
        [string]$CaveatId = "",
        [string]$StaleRefStatus = "fresh"
    )

    $normalizedPath = $Path.Replace("\", "/")
    $id = if ([string]::IsNullOrWhiteSpace($ArtifactId)) {
        ConvertTo-AuditIdPart -Value $normalizedPath
    }
    else {
        ConvertTo-AuditIdPart -Value $ArtifactId
    }

    $classification = Get-AuditClassification -Path $normalizedPath -SourceTask $SourceTask -ArtifactClass $ArtifactClass -ArtifactRole $ArtifactRole -EvidenceKind $EvidenceKind -ProofStatus $ProofStatus
    if ($StaleRefStatus -eq "stale_with_explicit_caveat") {
        $classification.ProofStatus = "stale_with_explicit_caveat"
        $classification.ProofTreatment = "stale generated_from ref accepted only with explicit caveat"
        $classification.AuditReadinessStatus = "ready_with_caveat"
    }

    if ($null -eq $NonClaims -or $NonClaims.Count -eq 0) {
        $NonClaims = @(
            "This audit entry is an exact-path evidence pointer only.",
            "This entry is not runtime memory, product runtime, autonomous agent execution, external integration, or artifact-map diff/check tooling."
        )
    }

    $auditEntryId = ("audit_{0}" -f $id)

    return [ordered]@{
        audit_entry_id = $auditEntryId
        evidence_path = $normalizedPath
        artifact_id = $id
        artifact_type = $classification.ArtifactType
        source_milestone = $SourceMilestone
        source_task = $SourceTask
        authority_level = $classification.AuthorityLevel
        authority_class = $classification.AuthorityClass
        evidence_kind = $classification.EvidenceKind
        proof_status = $classification.ProofStatus
        proof_treatment = $classification.ProofTreatment
        inspection_route = New-InspectionRoute -AuditEntryId $auditEntryId -Path $normalizedPath -ArtifactType $classification.ArtifactType
        exact_ref_required = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        stale_ref_status = $StaleRefStatus
        caveat_id = $CaveatId
        validation_commands = @(Get-ValidationCommandsForPath -Path $normalizedPath)
        required_for_closeout = [bool]$classification.RequiredForCloseout
        audit_readiness_status = $classification.AuditReadinessStatus
        non_claims = [string[]]$NonClaims
        deterministic_order = 0
    }
}

function Add-AuditEntryUnique {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Entries,
        [Parameter(Mandatory = $true)][hashtable]$PathSet,
        [Parameter(Mandatory = $true)]$Entry
    )

    $path = [string]$Entry.evidence_path
    if ($PathSet.ContainsKey($path)) {
        return
    }

    $PathSet[$path] = $true
    [void]$Entries.Add($Entry)
}

function New-R15StaleGeneratedFromCaveats {
    $declared = [ordered]@{
        audited_head = $script:R15AuditedHead
        audited_tree = $script:R15AuditedTree
        post_audit_support_commit = $script:R15PostAuditSupportCommit
    }
    $observed = [ordered]@{
        generated_from_head = $script:R15FinalPackageGeneratedHead
        generated_from_tree = $script:R15FinalPackageGeneratedTree
    }

    return @(
        [ordered]@{
            caveat_id = "r15_final_proof_review_package_stale_generated_from"
            caveat_type = "stale_generated_from_ref_preserved"
            applies_to_path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json"
            applies_to_ref_id = "r15_final_proof_review_package"
            declared_boundary = $declared
            observed_boundary = $observed
            accepted_reason = "The R15 external audit acceptance boundary is recorded separately and the older generated_from values remain visible as provenance caveats."
            preserved_scope = "R15 remains accepted with caveats through R15-009 only; R13 remains failed/partial and R14/R15 caveats are not removed."
            audit_impact = "ready_with_caveat"
            deterministic_order = 1
        },
        [ordered]@{
            caveat_id = "r15_evidence_index_stale_generated_from"
            caveat_type = "stale_generated_from_ref_preserved"
            applies_to_path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
            applies_to_ref_id = "r15_final_evidence_index"
            declared_boundary = $declared
            observed_boundary = $observed
            accepted_reason = "The R15 evidence index keeps its original generated_from values and is accepted only with this explicit caveat."
            preserved_scope = "R15 remains accepted with caveats through R15-009 only; R13 remains failed/partial and R14/R15 caveats are not removed."
            audit_impact = "ready_with_caveat"
            deterministic_order = 2
        }
    )
}

function Get-R16AuditMapRequiredPaths {
    return [string[]]$script:RequiredAuditPaths
}

function Get-TopLevelValidationCommands {
    $commands = @()
    for ($index = 0; $index -lt $script:ValidationCommandDefinitions.Count; $index += 1) {
        $command = New-ValidationCommandRef -Definition $script:ValidationCommandDefinitions[$index]
        $command.deterministic_order = $index + 1
        $commands += $command
    }

    return $commands
}

function New-R16AuditMapObject {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/audit/r16_audit_map.contract.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16AuditMapContract -Path $ContractPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    Test-R16ArtifactMap -Path $ArtifactMapPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null

    $auditContract = Read-SingleJsonObject -Path (Join-Path $resolvedRepositoryRoot $ContractPath) -Label "R16 audit map contract"
    $artifactMap = Read-SingleJsonObject -Path (Join-Path $resolvedRepositoryRoot $ArtifactMapPath) -Label "R16 artifact map"
    $entries = [System.Collections.ArrayList]::new()
    $pathSet = @{}

    foreach ($record in @($artifactMap.artifact_records)) {
        $entry = New-AuditEntry -Path ([string]$record.path) -ArtifactId ([string]$record.artifact_id) -SourceTask ([string]$record.source_task) -SourceMilestone ([string]$record.source_milestone) -ArtifactClass ([string]$record.artifact_class) -ArtifactRole ([string]$record.artifact_role) -EvidenceKind ([string]$record.evidence_kind) -ProofStatus ([string]$record.proof_status) -NonClaims ([string[]]$record.non_claims)
        Add-AuditEntryUnique -Entries $entries -PathSet $pathSet -Entry $entry
    }

    foreach ($path in $script:RequiredAuditPaths) {
        $sourceTask = if ($path -like "state/proof_reviews/r15_*" -or $path -like "governance/R15_*" -or $path -like "governance/reports/AIOffice_V2_R15_*") { "R15-009" } else { "R16-012" }
        $sourceMilestone = if ($sourceTask -like "R15-*") { $script:R15Milestone } else { $script:R16Milestone }
        $caveatId = ""
        $stale = "fresh"
        if ($path -eq "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json") {
            $caveatId = "r15_final_proof_review_package_stale_generated_from"
            $stale = "stale_with_explicit_caveat"
        }
        elseif ($path -eq "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json") {
            $caveatId = "r15_evidence_index_stale_generated_from"
            $stale = "stale_with_explicit_caveat"
        }

        $entry = New-AuditEntry -Path $path -SourceTask $sourceTask -SourceMilestone $sourceMilestone -CaveatId $caveatId -StaleRefStatus $stale
        Add-AuditEntryUnique -Entries $entries -PathSet $pathSet -Entry $entry
    }

    $orderedEntries = @($entries | Sort-Object -Property @{ Expression = { [string]$_.evidence_path }; Ascending = $true })
    for ($index = 0; $index -lt $orderedEntries.Count; $index += 1) {
        $orderedEntries[$index].deterministic_order = $index + 1
    }

    $requiredPaths = [string[]]@($script:RequiredAuditPaths | Sort-Object -Unique)

    return [ordered]@{
        artifact_type = "r16_r15_r16_audit_map"
        audit_map_version = "v1"
        audit_map_id = "aioffice-r16-012-r15-r16-audit-map-v1"
        source_milestone = $script:R16Milestone
        source_task = "R16-012"
        repository = $script:Repository
        branch = $script:Branch
        contract_ref = [ordered]@{
            path = $ContractPath.Replace("\", "/")
            source_task = "R16-011"
            contract_artifact_type = $auditContract.artifact_type
            contract_version = $auditContract.contract_version
            loaded_and_validated = $true
        }
        artifact_map_ref = [ordered]@{
            path = $ArtifactMapPath.Replace("\", "/")
            source_task = "R16-010"
            artifact_map_id = $artifactMap.artifact_map_id
            loaded_and_validated = $true
        }
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
            boundary_note = "input boundary for generation, not a claim to equal the final R16-012 commit"
        }
        current_posture = [ordered]@{
            active_through_task = "R16-012"
            complete_tasks = [string[]](1..12 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            planned_tasks = [string[]](13..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            r16_013_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        generation_policy = [ordered]@{
            curated_exact_paths_only = $true
            repo_relative_exact_paths_required = $true
            broad_repo_scan_allowed = $false
            broad_repo_scan_performed = $false
            full_repo_scan_allowed = $false
            full_repo_scan_performed = $false
            wildcard_paths_allowed = $false
            wildcard_paths_loaded = $false
            directory_only_proof_claims_allowed_without_exact_files = $false
            reports_as_machine_proof_allowed = $false
            planning_reports_as_implementation_proof_allowed = $false
            stale_refs_without_caveat_allowed = $false
        }
        generation_mode = [ordered]@{
            audit_map_generator_implemented = $true
            generated_audit_map_exists = $true
            generated_audit_map_is_state_artifact = $true
            generated_audit_map_is_runtime_memory = $false
            artifact_map_diff_tooling_implemented = $false
            context_load_planner_implemented = $false
            context_budget_estimator_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
        }
        required_paths = $requiredPaths
        audit_entries = $orderedEntries
        caveats = @(New-R15StaleGeneratedFromCaveats)
        finding_summary = [ordered]@{
            missing_required_paths = 0
            wildcard_paths = 0
            broad_repo_root_paths = 0
            directory_only_proof_claims = 0
            stale_refs_without_caveat = 0
            report_as_machine_proof_errors = 0
            runtime_overclaims = 0
            context_planner_overclaims = 0
            artifact_diff_tooling_overclaims = 0
            later_task_overclaims = 0
            r13_boundary_violations = 0
            r14_caveat_removals = 0
            r15_caveat_removals = 0
        }
        aggregate_verdict = "passed"
        non_claims = [string[]]$script:RequiredNonClaims
        preserved_boundaries = [ordered]@{
            r13 = [ordered]@{
                status = "failed_partial_through_r13_018_only"
                closed = $false
                partial_gates_remain_partial = $true
                partial_gates_converted_to_passed = $false
            }
            r14 = [ordered]@{
                status = "accepted_with_caveats_through_r14_006_only"
                caveats_removed = $false
            }
            r15 = [ordered]@{
                status = "accepted_with_caveats_through_r15_009_only"
                audited_head = $script:R15AuditedHead
                audited_tree = $script:R15AuditedTree
                post_audit_support_commit = $script:R15PostAuditSupportCommit
                caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
            }
        }
        validation_commands = @(Get-TopLevelValidationCommands)
    }
}

function Assert-FalseField {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $value = Get-RequiredProperty -Object $Object -Name $Name -Context $Context
    if ((Assert-BooleanValue -Value $value -Context "$Context $Name") -ne $false) {
        throw "$Context $Name must be False."
    }
}

function Assert-TrueField {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $value = Get-RequiredProperty -Object $Object -Name $Name -Context $Context
    if ((Assert-BooleanValue -Value $value -Context "$Context $Name") -ne $true) {
        throw "$Context $Name must be True."
    }
}

function Assert-GenerationPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @("curated_exact_paths_only", "repo_relative_exact_paths_required")) {
        Assert-TrueField -Object $policyObject -Name $trueField -Context $Context
    }
    foreach ($falseField in @(
        "broad_repo_scan_allowed",
        "broad_repo_scan_performed",
        "full_repo_scan_allowed",
        "full_repo_scan_performed",
        "wildcard_paths_allowed",
        "wildcard_paths_loaded",
        "directory_only_proof_claims_allowed_without_exact_files",
        "reports_as_machine_proof_allowed",
        "planning_reports_as_implementation_proof_allowed",
        "stale_refs_without_caveat_allowed"
    )) {
        Assert-FalseField -Object $policyObject -Name $falseField -Context $Context
    }
}

function Assert-GenerationMode {
    param(
        [Parameter(Mandatory = $true)]$Mode,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $modeObject = Assert-ObjectValue -Value $Mode -Context $Context
    foreach ($trueField in @("audit_map_generator_implemented", "generated_audit_map_exists", "generated_audit_map_is_state_artifact")) {
        Assert-TrueField -Object $modeObject -Name $trueField -Context $Context
    }
    foreach ($falseField in @(
        "generated_audit_map_is_runtime_memory",
        "artifact_map_diff_tooling_implemented",
        "context_load_planner_implemented",
        "context_budget_estimator_implemented",
        "role_run_envelope_implemented",
        "raci_transition_gate_implemented",
        "handoff_packet_implemented",
        "workflow_drill_run",
        "product_runtime_implemented",
        "actual_autonomous_agents_implemented",
        "external_integrations_implemented"
    )) {
        Assert-FalseField -Object $modeObject -Name $falseField -Context $Context
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-012") {
        throw "$Context active_through_task must be R16-012."
    }

    $completeTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "complete_tasks" -Context $Context) -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $postureObject -Name "planned_tasks" -Context $Context) -Context "$Context planned_tasks"
    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in $completeTasks) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 13) {
            throw "$Context claims R16-013 or later implementation with '$taskId'."
        }
    }

    Assert-ExactStringSet -Values $completeTasks -ExpectedValues ([string[]](1..12 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues ([string[]](13..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"

    Assert-FalseField -Object $postureObject -Name "r16_013_or_later_implementation_claimed" -Context $Context
    Assert-FalseField -Object $postureObject -Name "r16_027_or_later_task_exists" -Context $Context
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r13" -Context $Context) -Context "$Context r13"
    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"

    if ($r13.status -ne "failed_partial_through_r13_018_only") {
        throw "$Context r13 status must preserve failed_partial_through_r13_018_only."
    }
    Assert-FalseField -Object $r13 -Name "closed" -Context "$Context r13"
    Assert-FalseField -Object $r13 -Name "partial_gates_converted_to_passed" -Context "$Context r13"
    if ($r14.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    Assert-FalseField -Object $r14 -Name "caveats_removed" -Context "$Context r14"
    if ($r15.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
    Assert-FalseField -Object $r15 -Name "caveats_removed" -Context "$Context r15"
    Assert-TrueField -Object $r15 -Name "stale_generated_from_caveat_preserved" -Context "$Context r15"
}

function Assert-ValidationCommand {
    param(
        [Parameter(Mandatory = $true)]$Command,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredValidationCommandFields) {
        Get-RequiredProperty -Object $Command -Name $field -Context $Context | Out-Null
    }

    Assert-NonEmptyString -Value $Command.command_id -Context "$Context command_id" | Out-Null
    Assert-NonEmptyString -Value $Command.command -Context "$Context command" | Out-Null
    $path = Assert-NonEmptyString -Value $Command.validates_path -Context "$Context validates_path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context validates_path" | Out-Null
    if ($Command.expected_result -ne "PASS") {
        throw "$Context expected_result must be PASS."
    }
    Assert-BooleanValue -Value $Command.required_for_closeout -Context "$Context required_for_closeout" | Out-Null
    $order = Assert-IntegerValue -Value $Command.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
}

function Assert-InspectionRoute {
    param(
        [Parameter(Mandatory = $true)]$Route,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$EntryPath
    )

    $routeObject = Assert-ObjectValue -Value $Route -Context $Context
    foreach ($field in $script:RequiredInspectionRouteFields) {
        Get-RequiredProperty -Object $routeObject -Name $field -Context $Context | Out-Null
    }

    $routePath = Assert-NonEmptyString -Value $routeObject.evidence_path -Context "$Context evidence_path"
    Assert-SafeRepoRelativePath -Path $routePath -RepositoryRoot $RepositoryRoot -Context "$Context evidence_path" | Out-Null
    if ($routePath -ne $EntryPath) {
        throw "$Context evidence_path must match audit entry evidence_path."
    }
    Assert-FalseField -Object $routeObject -Name "broad_scan_allowed" -Context $Context
    Assert-FalseField -Object $routeObject -Name "wildcard_allowed" -Context $Context
    Assert-FalseField -Object $routeObject -Name "fallback_allowed" -Context $Context
}

function Assert-AuditEntry {
    param(
        [Parameter(Mandatory = $true)]$Entry,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [Parameter(Mandatory = $true)][string[]]$CaveatIds
    )

    foreach ($field in $script:RequiredEntryFields) {
        Get-RequiredProperty -Object $Entry -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $Entry.evidence_path -Context "$Context evidence_path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context evidence_path" -RequireLeaf | Out-Null
    Assert-TrueField -Object $Entry -Name "exact_ref_required" -Context $Context
    Assert-FalseField -Object $Entry -Name "broad_scan_allowed" -Context $Context
    Assert-FalseField -Object $Entry -Name "wildcard_allowed" -Context $Context

    if ($Entry.authority_level -notin $script:AllowedAuthorityLevels) {
        throw "$Context authority_level '$($Entry.authority_level)' is not allowed."
    }
    if ($Entry.authority_class -notin $script:AllowedAuthorityClasses) {
        throw "$Context authority_class '$($Entry.authority_class)' is not allowed."
    }
    if ($Entry.proof_status -notin $script:AllowedProofStatuses) {
        throw "$Context proof_status '$($Entry.proof_status)' is not allowed."
    }
    if ($Entry.audit_readiness_status -notin $script:AllowedAuditReadinessStatuses) {
        throw "$Context audit_readiness_status '$($Entry.audit_readiness_status)' is not allowed."
    }

    $order = Assert-IntegerValue -Value $Entry.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }

    if ($Entry.source_task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 13) {
        throw "$Context claims R16-013 or later implementation with source_task '$($Entry.source_task)'."
    }
    if ($Entry.source_task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
        throw "$Context introduces R16-027 or later task '$($Entry.source_task)'."
    }

    if ($Entry.stale_ref_status -ne "fresh") {
        if ([string]::IsNullOrWhiteSpace([string]$Entry.caveat_id)) {
            throw "$Context stale ref without caveat is rejected."
        }
        if ($CaveatIds -notcontains [string]$Entry.caveat_id) {
            throw "$Context stale ref without caveat is rejected; caveat_id '$($Entry.caveat_id)' is not declared."
        }
    }

    if (($path -like "*.md" -or $Entry.artifact_type -in @("planning_report", "operator_report", "narrative_context")) -and $Entry.proof_status -eq "machine_validated") {
        throw "$Context report/Markdown cannot be treated as machine proof without validator-backed evidence."
    }

    if ([string]$Entry.proof_status -like "*runtime*" -or [string]$Entry.proof_treatment -match '(?i)runtime memory|product runtime') {
        if ($Entry.proof_status -ne "runtime_claim_rejected" -and $Entry.proof_treatment -notmatch '(?i)not runtime') {
            throw "$Context runtime overclaim is rejected."
        }
    }

    Assert-InspectionRoute -Route $Entry.inspection_route -Context "$Context inspection_route" -RepositoryRoot $RepositoryRoot -EntryPath $path
    $commands = Assert-ObjectArray -Value $Entry.validation_commands -Context "$Context validation_commands" -AllowEmpty
    for ($index = 0; $index -lt $commands.Count; $index += 1) {
        Assert-ValidationCommand -Command $commands[$index] -Context "$Context validation_commands[$index]" -RepositoryRoot $RepositoryRoot -ExpectedOrder ($index + 1)
    }

    return $path
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

    $path = Assert-NonEmptyString -Value $Caveat.applies_to_path -Context "$Context applies_to_path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context applies_to_path" -RequireLeaf | Out-Null
    $order = Assert-IntegerValue -Value $Caveat.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
    if ($Caveat.caveat_type -ne "stale_generated_from_ref_preserved") {
        throw "$Context caveat_type must preserve stale_generated_from_ref_preserved."
    }
    if ($Caveat.audit_impact -ne "ready_with_caveat") {
        throw "$Context audit_impact must be ready_with_caveat."
    }

    return [string]$Caveat.caveat_id
}

function Assert-FindingSummary {
    param(
        [Parameter(Mandatory = $true)]$Summary,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $summaryObject = Assert-ObjectValue -Value $Summary -Context $Context
    foreach ($field in $script:RequiredFindingFields) {
        $value = Assert-IntegerValue -Value (Get-RequiredProperty -Object $summaryObject -Name $field -Context $Context) -Context "$Context $field"
        if ($value -ne 0) {
            throw "$Context $field must be 0."
        }
    }
}

function Test-R16AuditMapObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$AuditMap,
        [string]$SourceLabel = "R16 audit map",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/audit/r16_audit_map.contract.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16AuditMapContract -Path $ContractPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    Test-R16ArtifactMap -Path $ArtifactMapPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null

    foreach ($field in @(
        "artifact_type",
        "audit_map_version",
        "audit_map_id",
        "source_milestone",
        "source_task",
        "repository",
        "branch",
        "contract_ref",
        "artifact_map_ref",
        "generation_boundary",
        "current_posture",
        "generation_policy",
        "generation_mode",
        "required_paths",
        "audit_entries",
        "caveats",
        "finding_summary",
        "aggregate_verdict",
        "non_claims",
        "preserved_boundaries",
        "validation_commands"
    )) {
        Get-RequiredProperty -Object $AuditMap -Name $field -Context $SourceLabel | Out-Null
    }

    if ($AuditMap.artifact_type -ne "r16_r15_r16_audit_map") {
        throw "$SourceLabel artifact_type must be r16_r15_r16_audit_map."
    }
    if ($AuditMap.audit_map_version -ne "v1") {
        throw "$SourceLabel audit_map_version must be v1."
    }
    if ($AuditMap.audit_map_id -ne "aioffice-r16-012-r15-r16-audit-map-v1") {
        throw "$SourceLabel audit_map_id must be aioffice-r16-012-r15-r16-audit-map-v1."
    }
    if ($AuditMap.source_task -ne "R16-012") {
        throw "$SourceLabel source_task must be R16-012."
    }
    if ($AuditMap.source_milestone -ne $script:R16Milestone) {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($AuditMap.repository -ne $script:Repository) {
        throw "$SourceLabel repository must be $script:Repository."
    }
    if ($AuditMap.branch -ne $script:Branch) {
        throw "$SourceLabel branch must be $script:Branch."
    }

    $contractRef = Assert-ObjectValue -Value $AuditMap.contract_ref -Context "$SourceLabel contract_ref"
    if ($contractRef.path -ne $ContractPath.Replace("\", "/") -or $contractRef.source_task -ne "R16-011" -or $contractRef.loaded_and_validated -ne $true) {
        throw "$SourceLabel contract_ref must load and validate the R16-011 audit map contract."
    }
    $artifactMapRef = Assert-ObjectValue -Value $AuditMap.artifact_map_ref -Context "$SourceLabel artifact_map_ref"
    if ($artifactMapRef.path -ne $ArtifactMapPath.Replace("\", "/") -or $artifactMapRef.source_task -ne "R16-010" -or $artifactMapRef.loaded_and_validated -ne $true) {
        throw "$SourceLabel artifact_map_ref must load and validate the R16-010 artifact map."
    }

    $boundary = Assert-ObjectValue -Value $AuditMap.generation_boundary -Context "$SourceLabel generation_boundary"
    if ($boundary.input_head -ne $script:InputHead -or $boundary.input_tree -ne $script:InputTree) {
        throw "$SourceLabel generation_boundary must preserve the requested R16-012 input head and tree."
    }

    Assert-CurrentPosture -Posture $AuditMap.current_posture -Context "$SourceLabel current_posture"
    Assert-GenerationPolicy -Policy $AuditMap.generation_policy -Context "$SourceLabel generation_policy"
    Assert-GenerationMode -Mode $AuditMap.generation_mode -Context "$SourceLabel generation_mode"
    Assert-PreservedBoundaries -Boundaries $AuditMap.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    Assert-FindingSummary -Summary $AuditMap.finding_summary -Context "$SourceLabel finding_summary"
    if ($AuditMap.aggregate_verdict -ne "passed") {
        throw "$SourceLabel aggregate_verdict must be passed."
    }

    $nonClaims = Assert-StringArray -Value $AuditMap.non_claims -Context "$SourceLabel non_claims"
    foreach ($nonClaim in $script:RequiredNonClaims) {
        if ($nonClaims -notcontains $nonClaim) {
            throw "$SourceLabel non_claims must include '$nonClaim'."
        }
    }

    $requiredPaths = Assert-StringArray -Value $AuditMap.required_paths -Context "$SourceLabel required_paths"
    Assert-RequiredValuesPresent -Values $requiredPaths -RequiredValues $script:RequiredAuditPaths -Context "$SourceLabel required_paths"
    foreach ($requiredPath in $requiredPaths) {
        Assert-SafeRepoRelativePath -Path $requiredPath -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel required_paths" -RequireLeaf | Out-Null
    }

    $caveats = Assert-ObjectArray -Value $AuditMap.caveats -Context "$SourceLabel caveats"
    $caveatIds = @()
    for ($index = 0; $index -lt $caveats.Count; $index += 1) {
        $caveatIds += Assert-Caveat -Caveat $caveats[$index] -Context "$SourceLabel caveats[$index]" -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1)
    }
    foreach ($expectedCaveat in @("r15_final_proof_review_package_stale_generated_from", "r15_evidence_index_stale_generated_from")) {
        if ($caveatIds -notcontains $expectedCaveat) {
            throw "$SourceLabel caveats must preserve '$expectedCaveat'."
        }
    }

    $entries = Assert-ObjectArray -Value $AuditMap.audit_entries -Context "$SourceLabel audit_entries"
    $paths = @()
    $ids = @()
    for ($index = 0; $index -lt $entries.Count; $index += 1) {
        $path = Assert-AuditEntry -Entry $entries[$index] -Context "$SourceLabel audit_entries[$index]" -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1) -CaveatIds $caveatIds
        if ($paths -contains $path) {
            throw "$SourceLabel duplicate evidence_path '$path' is rejected."
        }
        $paths += $path
        $id = [string]$entries[$index].audit_entry_id
        if ($ids -contains $id) {
            throw "$SourceLabel duplicate audit_entry_id '$id' is rejected."
        }
        $ids += $id
    }
    Assert-RequiredValuesPresent -Values $paths -RequiredValues $script:RequiredAuditPaths -Context "$SourceLabel audit_entries"

    $topCommands = Assert-ObjectArray -Value $AuditMap.validation_commands -Context "$SourceLabel validation_commands"
    for ($index = 0; $index -lt $topCommands.Count; $index += 1) {
        Assert-ValidationCommand -Command $topCommands[$index] -Context "$SourceLabel validation_commands[$index]" -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1)
    }

    return [pscustomobject]@{
        AuditMapId = $AuditMap.audit_map_id
        SourceTask = $AuditMap.source_task
        ActiveThroughTask = $AuditMap.current_posture.active_through_task
        PlannedTaskStart = $AuditMap.current_posture.planned_tasks[0]
        PlannedTaskEnd = $AuditMap.current_posture.planned_tasks[-1]
        EntryCount = $entries.Count
        CaveatCount = $caveats.Count
        RequiredPathCount = $script:RequiredAuditPaths.Count
        AggregateVerdict = $AuditMap.aggregate_verdict
        GeneratedAuditMapIsRuntimeMemory = [bool]$AuditMap.generation_mode.generated_audit_map_is_runtime_memory
        ArtifactMapDiffToolingImplemented = [bool]$AuditMap.generation_mode.artifact_map_diff_tooling_implemented
        ContextLoadPlannerImplemented = [bool]$AuditMap.generation_mode.context_load_planner_implemented
    }
}

function Test-R16AuditMap {
    [CmdletBinding()]
    param(
        [string]$Path = "state/audit/r16_r15_r16_audit_map.json",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/audit/r16_audit_map.contract.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRepositoryRoot -Context "R16 audit map path" -RequireLeaf
    $auditMap = Read-SingleJsonObject -Path $resolvedPath -Label "R16 audit map"
    return Test-R16AuditMapObject -AuditMap $auditMap -SourceLabel $Path -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath -ArtifactMapPath $ArtifactMapPath
}

function New-R16AuditMap {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/audit/r16_r15_r16_audit_map.json",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/audit/r16_audit_map.contract.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutputPath = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -Context "OutputPath"
    $auditMap = New-R16AuditMapObject -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath -ArtifactMapPath $ArtifactMapPath
    Write-StableJsonFile -Object $auditMap -Path $resolvedOutputPath
    $validation = Test-R16AuditMap -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath -ArtifactMapPath $ArtifactMapPath

    return [pscustomobject]@{
        OutputPath = $OutputPath
        AuditMapId = $validation.AuditMapId
        EntryCount = $validation.EntryCount
        CaveatCount = $validation.CaveatCount
        RequiredPathCount = $validation.RequiredPathCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
    }
}

function Set-DeterministicAuditEntryOrder {
    param([Parameter(Mandatory = $true)]$AuditMap)

    $entries = @($AuditMap.audit_entries)
    for ($index = 0; $index -lt $entries.Count; $index += 1) {
        $entries[$index].deterministic_order = $index + 1
    }
    $AuditMap.audit_entries = $entries
}

function New-MinimalInvalidFixtureObject {
    param(
        [Parameter(Mandatory = $true)]$ValidObject,
        [int]$EntryIndex = 0
    )

    $fixture = Copy-JsonObject -Value $ValidObject
    $fixture.audit_entries = @($fixture.audit_entries[$EntryIndex])
    $fixture.audit_entries[0].deterministic_order = 1
    return $fixture
}

function New-R16AuditMapFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_audit_map_generator",
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = Resolve-RepoRelativePathValue -Path $FixtureRoot -RepositoryRoot $resolvedRepositoryRoot
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $valid = New-R16AuditMapObject -RepositoryRoot $resolvedRepositoryRoot
    Write-StableJsonFile -Object $valid -Path (Join-Path $resolvedFixtureRoot "valid_audit_map.json")

    $missing = Copy-JsonObject -Value $valid
    $missing.audit_entries = @($missing.audit_entries | Where-Object { $_.evidence_path -ne "README.md" })
    Set-DeterministicAuditEntryOrder -AuditMap $missing
    Write-StableJsonFile -Object $missing -Path (Join-Path $resolvedFixtureRoot "invalid_missing_evidence_path.json")

    $wildcard = New-MinimalInvalidFixtureObject -ValidObject $valid
    $wildcard.audit_entries[0].evidence_path = "tools/*.ps1"
    $wildcard.audit_entries[0].inspection_route.evidence_path = "tools/*.ps1"
    Write-StableJsonFile -Object $wildcard -Path (Join-Path $resolvedFixtureRoot "invalid_wildcard_evidence_path.json")

    $broad = New-MinimalInvalidFixtureObject -ValidObject $valid
    $broad.generation_policy.full_repo_scan_performed = $true
    Write-StableJsonFile -Object $broad -Path (Join-Path $resolvedFixtureRoot "invalid_broad_scan_claim.json")

    $directoryOnly = New-MinimalInvalidFixtureObject -ValidObject $valid
    $directoryOnly.audit_entries[0].evidence_path = "state/proof_reviews/"
    $directoryOnly.audit_entries[0].inspection_route.evidence_path = "state/proof_reviews/"
    Write-StableJsonFile -Object $directoryOnly -Path (Join-Path $resolvedFixtureRoot "invalid_directory_only_proof_claim.json")

    $runtime = New-MinimalInvalidFixtureObject -ValidObject $valid
    $runtime.generation_mode.generated_audit_map_is_runtime_memory = $true
    Write-StableJsonFile -Object $runtime -Path (Join-Path $resolvedFixtureRoot "invalid_runtime_memory_claim.json")

    $contextPlanner = New-MinimalInvalidFixtureObject -ValidObject $valid
    $contextPlanner.generation_mode.context_load_planner_implemented = $true
    Write-StableJsonFile -Object $contextPlanner -Path (Join-Path $resolvedFixtureRoot "invalid_context_planner_claim.json")

    $artifactDiff = New-MinimalInvalidFixtureObject -ValidObject $valid
    $artifactDiff.generation_mode.artifact_map_diff_tooling_implemented = $true
    Write-StableJsonFile -Object $artifactDiff -Path (Join-Path $resolvedFixtureRoot "invalid_artifact_diff_tooling_claim.json")

    $reportProof = New-MinimalInvalidFixtureObject -ValidObject $valid
    $reportProof.audit_entries[0].evidence_path = "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md"
    $reportProof.audit_entries[0].inspection_route.evidence_path = "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md"
    $reportProof.audit_entries[0].artifact_type = "planning_report"
    $reportProof.audit_entries[0].proof_status = "machine_validated"
    Write-StableJsonFile -Object $reportProof -Path (Join-Path $resolvedFixtureRoot "invalid_report_as_machine_proof.json")

    $stale = New-MinimalInvalidFixtureObject -ValidObject $valid
    $stale.audit_entries[0].stale_ref_status = "stale_with_explicit_caveat"
    $stale.audit_entries[0].caveat_id = ""
    Write-StableJsonFile -Object $stale -Path (Join-Path $resolvedFixtureRoot "invalid_stale_ref_without_caveat.json")

    $r16Later = New-MinimalInvalidFixtureObject -ValidObject $valid
    $r16Later.current_posture.complete_tasks += "R16-013"
    $r16Later.current_posture.r16_013_or_later_implementation_claimed = $true
    Write-StableJsonFile -Object $r16Later -Path (Join-Path $resolvedFixtureRoot "invalid_r16_013_claim.json")

    $r13 = New-MinimalInvalidFixtureObject -ValidObject $valid
    $r13.preserved_boundaries.r13.closed = $true
    Write-StableJsonFile -Object $r13 -Path (Join-Path $resolvedFixtureRoot "invalid_r13_boundary_change.json")

    $r14 = New-MinimalInvalidFixtureObject -ValidObject $valid
    $r14.preserved_boundaries.r14.caveats_removed = $true
    Write-StableJsonFile -Object $r14 -Path (Join-Path $resolvedFixtureRoot "invalid_r14_caveat_removed.json")

    $r15 = New-MinimalInvalidFixtureObject -ValidObject $valid
    $r15.preserved_boundaries.r15.caveats_removed = $true
    Write-StableJsonFile -Object $r15 -Path (Join-Path $resolvedFixtureRoot "invalid_r15_caveat_removed.json")

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = Join-Path $FixtureRoot "valid_audit_map.json"
        InvalidFixtureCount = 13
    }
}

Export-ModuleMember -Function New-R16AuditMapObject, New-R16AuditMap, Test-R16AuditMap, Test-R16AuditMapObject, New-R16AuditMapFixtureFiles, Get-R16AuditMapRequiredPaths, ConvertTo-StableJson
