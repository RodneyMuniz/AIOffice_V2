Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapContract.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "a6e088b79bd4bd70042d6540acc24c8c988f1984"
$script:InputTree = "be53d49d4b2752e08fb407e19c247e9bf31c948b"
$script:R15AuditedHead = "d9685030a0556a528684d28367db83f4c72f7fc9"
$script:R15AuditedTree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
$script:R15PostAuditSupportCommit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"

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
    "no audit map",
    "no context-load planner",
    "no role-run envelope",
    "no handoff packet",
    "no workflow drill"
)

$script:RequiredMapPaths = @(
    "README.md",
    "governance/ACTIVE_STATE.md",
    "execution/KANBAN.md",
    "governance/DECISION_LOG.md",
    "governance/DOCUMENT_AUTHORITY_INDEX.md",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md",
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
    "tests/fixtures/r16_artifact_map_contract/valid_artifact_map_contract.json",
    "tests/fixtures/r16_artifact_map_contract/invalid_missing_required_field.json",
    "tests/fixtures/r16_artifact_map_contract/invalid_runtime_claim.json",
    "tests/fixtures/r16_artifact_map_contract/invalid_generated_map_claim.json",
    "tests/fixtures/r16_artifact_map_contract/invalid_broad_scan_policy.json",
    "tools/R16ArtifactMapGenerator.psm1",
    "tools/new_r16_artifact_map.ps1",
    "tools/validate_r16_artifact_map.ps1",
    "tests/test_r16_artifact_map_generator.ps1",
    "state/artifacts/r16_artifact_map.json",
    "tests/fixtures/r16_artifact_map_generator/valid_artifact_map.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_missing_required_path.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_wildcard_path.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_broad_scan_claim.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_runtime_memory_claim.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_audit_map_claim.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_context_planner_claim.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_report_as_machine_proof.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_stale_ref_without_caveat.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_r16_011_claim.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_r13_boundary_change.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_r14_caveat_removed.json",
    "tests/fixtures/r16_artifact_map_generator/invalid_r15_caveat_removed.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/evidence_index.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/validation_manifest.md"
)

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "artifact_map_version",
    "artifact_map_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "contract_ref",
    "generation_boundary",
    "generator",
    "generation_policy",
    "generation_mode",
    "current_posture",
    "required_paths",
    "artifact_records",
    "relationships",
    "finding_summary",
    "aggregate_verdict",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules"
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

$script:RequiredDependencyRefFields = @(
    "ref_id",
    "path",
    "artifact_class",
    "artifact_role",
    "authority_class",
    "evidence_kind",
    "source_task",
    "source_milestone",
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

    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized.EndsWith("/")
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
        throw "$Context rejects directory-only path '$Path'."
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

function ConvertTo-ArtifactIdPart {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.ToLowerInvariant() -replace '[^a-z0-9]+', '_'
    return $normalized.Trim("_")
}

function Get-R16ArtifactMapContractSemantics {
    param(
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_map.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ArtifactMapContract -ContractPath $ContractPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    $contract = Read-SingleJsonObject -Path (Join-Path $resolvedRepositoryRoot $ContractPath) -Label "R16 artifact map contract"

    return [pscustomobject]@{
        Contract = $contract
        AllowedArtifactClasses = [string[]]$contract.allowed_artifact_classes
        AllowedArtifactRoles = [string[]]$contract.allowed_artifact_roles
        AllowedAuthorityClasses = [string[]]$contract.allowed_authority_classes
        AllowedEvidenceKinds = [string[]]$contract.allowed_evidence_kinds
        AllowedLifecycleStates = [string[]]$contract.allowed_lifecycle_states
        AllowedProofStatuses = [string[]]$contract.allowed_proof_statuses
        AllowedRelationshipTypes = [string[]]$contract.relationship_schema.allowed_relationship_types
    }
}

function New-R16ArtifactDefinition {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ArtifactClass,
        [Parameter(Mandatory = $true)][string]$ArtifactRole,
        [Parameter(Mandatory = $true)][string]$AuthorityClass,
        [Parameter(Mandatory = $true)][string]$EvidenceKind,
        [Parameter(Mandatory = $true)][string]$ProofStatus,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$OwnerRole,
        [bool]$MachineProof = $false,
        [bool]$ImplementationProof = $false,
        [string[]]$NonClaims
    )

    if ($null -eq $NonClaims -or $NonClaims.Count -eq 0) {
        $NonClaims = @(
            "This artifact map record is exact-path metadata only.",
            "This artifact is not runtime memory, not an audit map, not a context-load planner, and not workflow execution."
        )
    }

    return [ordered]@{
        Id = $Id
        Path = $Path.Replace("\", "/")
        ArtifactClass = $ArtifactClass
        ArtifactRole = $ArtifactRole
        AuthorityClass = $AuthorityClass
        EvidenceKind = $EvidenceKind
        ProofStatus = $ProofStatus
        SourceTask = $SourceTask
        OwnerRole = $OwnerRole
        MachineProof = $MachineProof
        ImplementationProof = $ImplementationProof
        NonClaims = [string[]]$NonClaims
    }
}

function Get-R16ArtifactDefinitions {
    $items = @()

    $statusNonClaims = @(
        "Status surface only; not machine implementation proof by itself.",
        "This artifact is not runtime memory, not an audit map, not a context-load planner, and not workflow execution."
    )
    $items += New-R16ArtifactDefinition -Id "status_readme" -Path "README.md" -ArtifactClass "authority_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "status_active_state" -Path "governance/ACTIVE_STATE.md" -ArtifactClass "governance_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "status_kanban" -Path "execution/KANBAN.md" -ArtifactClass "operator_artifact" -ArtifactRole "operator_report" -AuthorityClass "operator_context" -EvidenceKind "operator_report" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "project_manager" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "status_decision_log" -Path "governance/DECISION_LOG.md" -ArtifactClass "governance_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "status_document_authority_index" -Path "governance/DOCUMENT_AUTHORITY_INDEX.md" -ArtifactClass "authority_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_milestone_authority" -Path "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md" -ArtifactClass "governance_document" -ArtifactRole "milestone_authority" -AuthorityClass "milestone_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "R16-010" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "governance_kpi_domain_model" -Path "governance/KPI_DOMAIN_MODEL.md" -ArtifactClass "governance_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "pre-R16" -OwnerRole "governance_operator" -NonClaims $statusNonClaims
    $items += New-R16ArtifactDefinition -Id "governance_milestone_reporting_standard" -Path "governance/MILESTONE_REPORTING_STANDARD.md" -ArtifactClass "governance_document" -ArtifactRole "governance_authority" -AuthorityClass "governance_authority" -EvidenceKind "narrative_context" -ProofStatus "context_only" -SourceTask "pre-R16" -OwnerRole "governance_operator" -NonClaims $statusNonClaims

    $reportNonClaims = @(
        "Planning/operator report only; not implementation proof by itself.",
        "This report is not runtime memory, not an audit map, not a context-load planner, and not workflow execution."
    )
    $items += New-R16ArtifactDefinition -Id "r16_r15_external_audit_planning_report" -Path "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md" -ArtifactClass "report" -ArtifactRole "operator_report" -AuthorityClass "report_context" -EvidenceKind "operator_report" -ProofStatus "context_only" -SourceTask "R16-002" -OwnerRole "governance_operator" -NonClaims $reportNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_revised_operational_memory_plan" -Path "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md" -ArtifactClass "report" -ArtifactRole "operator_report" -AuthorityClass "report_context" -EvidenceKind "operator_report" -ProofStatus "context_only" -SourceTask "R16-002" -OwnerRole "governance_operator" -NonClaims $reportNonClaims

    $contractNonClaims = @(
        "Contract/model artifact only; not runtime memory and not workflow execution.",
        "This artifact is not an audit map or context-load planner."
    )
    $toolNonClaims = @(
        "Committed tool artifact only; not runtime memory and not workflow execution.",
        "This artifact does not implement product runtime, autonomous agents, or external integrations."
    )
    $stateNonClaims = @(
        "Committed generated state artifact only; not runtime memory.",
        "This artifact is not an audit map, not a context-load planner, and not workflow execution."
    )

    $items += New-R16ArtifactDefinition -Id "r16_002_planning_authority_reference_state" -Path "state/governance/r16_planning_authority_reference.json" -ArtifactClass "state_artifact" -ArtifactRole "planning_authority" -AuthorityClass "state_authority" -EvidenceKind "generated_state_artifact" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-002" -OwnerRole "release_closeout_agent" -MachineProof $true -NonClaims $stateNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_002_planning_authority_reference_contract" -Path "contracts/governance/r16_planning_authority_reference.contract.json" -ArtifactClass "contract" -ArtifactRole "contract_authority" -AuthorityClass "contract_authority" -EvidenceKind "contract_schema" -ProofStatus "proof_by_itself_true" -SourceTask "R16-002" -OwnerRole "release_closeout_agent" -MachineProof $true -NonClaims $contractNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_002_planning_authority_reference_module" -Path "tools/R16PlanningAuthorityReference.psm1" -ArtifactClass "tool" -ArtifactRole "validation_tool" -AuthorityClass "proof_authority" -EvidenceKind "validator_module" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-002" -OwnerRole "release_closeout_agent" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_002_planning_authority_reference_validator_cli" -Path "tools/validate_r16_planning_authority_reference.ps1" -ArtifactClass "cli_wrapper" -ArtifactRole "validation_tool" -AuthorityClass "proof_authority" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-002" -OwnerRole "release_closeout_agent" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_002_planning_authority_reference_test" -Path "tests/test_r16_planning_authority_reference.ps1" -ArtifactClass "test" -ArtifactRole "focused_test" -AuthorityClass "proof_authority" -EvidenceKind "focused_test" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-002" -OwnerRole "qa" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims

    $items += New-R16ArtifactDefinition -Id "r16_003_kpi_baseline_target_scorecard_state" -Path "state/governance/r16_kpi_baseline_target_scorecard.json" -ArtifactClass "state_artifact" -ArtifactRole "committed_state" -AuthorityClass "state_authority" -EvidenceKind "generated_state_artifact" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-003" -OwnerRole "release_closeout_agent" -MachineProof $true -NonClaims $stateNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_003_kpi_baseline_target_scorecard_contract" -Path "contracts/governance/r16_kpi_baseline_target_scorecard.contract.json" -ArtifactClass "contract" -ArtifactRole "contract_authority" -AuthorityClass "contract_authority" -EvidenceKind "contract_schema" -ProofStatus "proof_by_itself_true" -SourceTask "R16-003" -OwnerRole "release_closeout_agent" -MachineProof $true -NonClaims $contractNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_003_kpi_baseline_target_scorecard_module" -Path "tools/R16KpiBaselineTargetScorecard.psm1" -ArtifactClass "tool" -ArtifactRole "validation_tool" -AuthorityClass "proof_authority" -EvidenceKind "validator_module" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-003" -OwnerRole "release_closeout_agent" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_003_kpi_baseline_target_scorecard_validator_cli" -Path "tools/validate_r16_kpi_baseline_target_scorecard.ps1" -ArtifactClass "cli_wrapper" -ArtifactRole "validation_tool" -AuthorityClass "proof_authority" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-003" -OwnerRole "release_closeout_agent" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_003_kpi_baseline_target_scorecard_test" -Path "tests/test_r16_kpi_baseline_target_scorecard.ps1" -ArtifactClass "test" -ArtifactRole "focused_test" -AuthorityClass "proof_authority" -EvidenceKind "focused_test" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-003" -OwnerRole "qa" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims

    $memoryEntries = @(
        @{ Id = "r16_004_memory_layer_contract"; Path = "contracts/memory/r16_memory_layer.contract.json"; Class = "contract"; Role = "contract_authority"; Authority = "contract_authority"; Evidence = "contract_schema"; Proof = "proof_by_itself_true"; Task = "R16-004"; Owner = "knowledge_curator"; Machine = $true; Impl = $false; Claims = $contractNonClaims },
        @{ Id = "r16_004_memory_layer_contract_module"; Path = "tools/R16MemoryLayerContract.psm1"; Class = "tool"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "validator_module"; Proof = "proof_if_validator_backed"; Task = "R16-004"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_004_memory_layer_contract_validator_cli"; Path = "tools/validate_r16_memory_layer_contract.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-004"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_004_memory_layer_contract_test"; Path = "tests/test_r16_memory_layer_contract.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-004"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_005_memory_layer_generator_module"; Path = "tools/R16MemoryLayerGenerator.psm1"; Class = "tool"; Role = "generation_tool"; Authority = "proof_authority"; Evidence = "committed_machine_evidence"; Proof = "proof_if_validator_backed"; Task = "R16-005"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_005_memory_layer_generator_cli"; Path = "tools/new_r16_memory_layers.ps1"; Class = "cli_wrapper"; Role = "generation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-005"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_005_memory_layer_validator_cli"; Path = "tools/validate_r16_memory_layers.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-005"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_005_memory_layer_generator_test"; Path = "tests/test_r16_memory_layer_generator.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-005"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_005_memory_layers_state"; Path = "state/memory/r16_memory_layers.json"; Class = "state_artifact"; Role = "committed_state"; Authority = "state_authority"; Evidence = "generated_state_artifact"; Proof = "proof_if_validator_backed"; Task = "R16-005"; Owner = "knowledge_curator"; Machine = $true; Impl = $false; Claims = $stateNonClaims },
        @{ Id = "r16_006_role_memory_pack_model_contract"; Path = "contracts/memory/r16_role_memory_pack_model.contract.json"; Class = "contract"; Role = "contract_authority"; Authority = "contract_authority"; Evidence = "contract_schema"; Proof = "proof_by_itself_true"; Task = "R16-006"; Owner = "knowledge_curator"; Machine = $true; Impl = $false; Claims = $contractNonClaims },
        @{ Id = "r16_006_role_memory_pack_model_module"; Path = "tools/R16RoleMemoryPackModel.psm1"; Class = "tool"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "validator_module"; Proof = "proof_if_validator_backed"; Task = "R16-006"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_006_role_memory_pack_model_validator_cli"; Path = "tools/validate_r16_role_memory_pack_model.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-006"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_006_role_memory_pack_model_test"; Path = "tests/test_r16_role_memory_pack_model.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-006"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_006_role_memory_pack_model_state"; Path = "state/memory/r16_role_memory_pack_model.json"; Class = "state_artifact"; Role = "committed_state"; Authority = "state_authority"; Evidence = "generated_state_artifact"; Proof = "proof_if_validator_backed"; Task = "R16-006"; Owner = "knowledge_curator"; Machine = $true; Impl = $false; Claims = $stateNonClaims },
        @{ Id = "r16_007_role_memory_pack_generator_module"; Path = "tools/R16RoleMemoryPackGenerator.psm1"; Class = "tool"; Role = "generation_tool"; Authority = "proof_authority"; Evidence = "committed_machine_evidence"; Proof = "proof_if_validator_backed"; Task = "R16-007"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_007_role_memory_pack_generator_cli"; Path = "tools/new_r16_role_memory_packs.ps1"; Class = "cli_wrapper"; Role = "generation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-007"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_007_role_memory_pack_validator_cli"; Path = "tools/validate_r16_role_memory_packs.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-007"; Owner = "knowledge_curator"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_007_role_memory_pack_generator_test"; Path = "tests/test_r16_role_memory_pack_generator.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-007"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_007_role_memory_packs_state"; Path = "state/memory/r16_role_memory_packs.json"; Class = "state_artifact"; Role = "committed_state"; Authority = "state_authority"; Evidence = "generated_state_artifact"; Proof = "proof_if_validator_backed"; Task = "R16-007"; Owner = "knowledge_curator"; Machine = $true; Impl = $false; Claims = $stateNonClaims },
        @{ Id = "r16_008_memory_pack_validation_contract"; Path = "contracts/memory/r16_memory_pack_validation_report.contract.json"; Class = "contract"; Role = "contract_authority"; Authority = "contract_authority"; Evidence = "contract_schema"; Proof = "proof_by_itself_true"; Task = "R16-008"; Owner = "evidence_auditor"; Machine = $true; Impl = $false; Claims = $contractNonClaims },
        @{ Id = "r16_008_memory_pack_validation_module"; Path = "tools/R16MemoryPackValidation.psm1"; Class = "tool"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "validator_module"; Proof = "proof_if_validator_backed"; Task = "R16-008"; Owner = "evidence_auditor"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_008_memory_pack_ref_detector_cli"; Path = "tools/test_r16_memory_pack_refs.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-008"; Owner = "evidence_auditor"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_008_memory_pack_validation_report_validator_cli"; Path = "tools/validate_r16_memory_pack_validation_report.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-008"; Owner = "evidence_auditor"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_008_memory_pack_validation_test"; Path = "tests/test_r16_memory_pack_validation.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-008"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_008_memory_pack_validation_report_state"; Path = "state/memory/r16_memory_pack_validation_report.json"; Class = "state_artifact"; Role = "committed_state"; Authority = "state_authority"; Evidence = "generated_state_artifact"; Proof = "proof_if_validator_backed"; Task = "R16-008"; Owner = "evidence_auditor"; Machine = $true; Impl = $false; Claims = $stateNonClaims },
        @{ Id = "r16_009_artifact_map_contract"; Path = "contracts/artifacts/r16_artifact_map.contract.json"; Class = "contract"; Role = "contract_authority"; Authority = "contract_authority"; Evidence = "contract_schema"; Proof = "proof_by_itself_true"; Task = "R16-009"; Owner = "evidence_auditor"; Machine = $true; Impl = $false; Claims = $contractNonClaims },
        @{ Id = "r16_009_artifact_map_contract_module"; Path = "tools/R16ArtifactMapContract.psm1"; Class = "tool"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "validator_module"; Proof = "proof_if_validator_backed"; Task = "R16-009"; Owner = "evidence_auditor"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_009_artifact_map_contract_validator_cli"; Path = "tools/validate_r16_artifact_map_contract.ps1"; Class = "cli_wrapper"; Role = "validation_tool"; Authority = "proof_authority"; Evidence = "cli_wrapper"; Proof = "proof_if_validator_backed"; Task = "R16-009"; Owner = "evidence_auditor"; Machine = $true; Impl = $true; Claims = $toolNonClaims },
        @{ Id = "r16_009_artifact_map_contract_test"; Path = "tests/test_r16_artifact_map_contract.ps1"; Class = "test"; Role = "focused_test"; Authority = "proof_authority"; Evidence = "focused_test"; Proof = "proof_if_validator_backed"; Task = "R16-009"; Owner = "qa"; Machine = $true; Impl = $true; Claims = $toolNonClaims }
    )

    foreach ($entry in $memoryEntries) {
        $items += New-R16ArtifactDefinition -Id $entry.Id -Path $entry.Path -ArtifactClass $entry.Class -ArtifactRole $entry.Role -AuthorityClass $entry.Authority -EvidenceKind $entry.Evidence -ProofStatus $entry.Proof -SourceTask $entry.Task -OwnerRole $entry.Owner -MachineProof $entry.Machine -ImplementationProof $entry.Impl -NonClaims $entry.Claims
    }

    $contractFixtureNames = @(
        @{ Name = "valid_artifact_map_contract.json"; Role = "valid_fixture"; Evidence = "valid_fixture" },
        @{ Name = "invalid_missing_required_field.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_runtime_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_generated_map_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_broad_scan_policy.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" }
    )
    foreach ($fixture in $contractFixtureNames) {
        $items += New-R16ArtifactDefinition -Id ("r16_009_artifact_map_contract_fixture_{0}" -f (ConvertTo-ArtifactIdPart -Value $fixture.Name)) -Path ("tests/fixtures/r16_artifact_map_contract/{0}" -f $fixture.Name) -ArtifactClass "fixture" -ArtifactRole $fixture.Role -AuthorityClass "proof_authority" -EvidenceKind $fixture.Evidence -ProofStatus "proof_if_validator_backed" -SourceTask "R16-009" -OwnerRole "qa" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    }

    $artifactMapStateNonClaims = @(
        "state/artifacts/r16_artifact_map.json is a committed generated state artifact only.",
        "The artifact map is not runtime memory.",
        "The artifact map is not an audit map.",
        "The artifact map is not a context-load planner.",
        "The artifact map is not workflow execution."
    )
    $items += New-R16ArtifactDefinition -Id "r16_010_artifact_map_generator" -Path "tools/R16ArtifactMapGenerator.psm1" -ArtifactClass "tool" -ArtifactRole "generation_tool" -AuthorityClass "proof_authority" -EvidenceKind "committed_machine_evidence" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "evidence_auditor" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_010_artifact_map_generator_cli" -Path "tools/new_r16_artifact_map.ps1" -ArtifactClass "cli_wrapper" -ArtifactRole "generation_tool" -AuthorityClass "proof_authority" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "evidence_auditor" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_010_artifact_map_validator_cli" -Path "tools/validate_r16_artifact_map.ps1" -ArtifactClass "cli_wrapper" -ArtifactRole "validation_tool" -AuthorityClass "proof_authority" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "evidence_auditor" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_010_artifact_map_generator_test" -Path "tests/test_r16_artifact_map_generator.ps1" -ArtifactClass "test" -ArtifactRole "focused_test" -AuthorityClass "proof_authority" -EvidenceKind "focused_test" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "qa" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    $items += New-R16ArtifactDefinition -Id "r16_010_artifact_map_state" -Path "state/artifacts/r16_artifact_map.json" -ArtifactClass "state_artifact" -ArtifactRole "committed_state" -AuthorityClass "state_authority" -EvidenceKind "generated_state_artifact" -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "evidence_auditor" -MachineProof $true -ImplementationProof $false -NonClaims $artifactMapStateNonClaims

    $generatorFixtureNames = @(
        @{ Name = "valid_artifact_map.json"; Role = "valid_fixture"; Evidence = "valid_fixture" },
        @{ Name = "invalid_missing_required_path.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_wildcard_path.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_broad_scan_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_runtime_memory_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_audit_map_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_context_planner_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_report_as_machine_proof.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_stale_ref_without_caveat.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_r16_011_claim.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_r13_boundary_change.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_r14_caveat_removed.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" },
        @{ Name = "invalid_r15_caveat_removed.json"; Role = "invalid_fixture"; Evidence = "invalid_fixture" }
    )
    foreach ($fixture in $generatorFixtureNames) {
        $items += New-R16ArtifactDefinition -Id ("r16_010_artifact_map_generator_fixture_{0}" -f (ConvertTo-ArtifactIdPart -Value $fixture.Name)) -Path ("tests/fixtures/r16_artifact_map_generator/{0}" -f $fixture.Name) -ArtifactClass "fixture" -ArtifactRole $fixture.Role -AuthorityClass "proof_authority" -EvidenceKind $fixture.Evidence -ProofStatus "proof_if_validator_backed" -SourceTask "R16-010" -OwnerRole "qa" -MachineProof $true -ImplementationProof $true -NonClaims $toolNonClaims
    }

    $proofPackageDefs = @(
        @{ Task = "R16-001"; Prefix = "r16_001_opening"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/r16_opening_packet.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/non_claims.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundATION/opening/validation_manifest.md") },
        @{ Task = "R16-002"; Prefix = "r16_002_planning_authority_reference"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/non_claims.json") },
        @{ Task = "R16-003"; Prefix = "r16_003_kpi_baseline_target_scorecard"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/non_claims.json") },
        @{ Task = "R16-004"; Prefix = "r16_004_memory_layer_contract"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/non_claims.json") },
        @{ Task = "R16-005"; Prefix = "r16_005_deterministic_memory_layer_generator"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/non_claims.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/generation_summary.json") },
        @{ Task = "R16-006"; Prefix = "r16_006_role_memory_pack_model"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/non_claims.json") },
        @{ Task = "R16-007"; Prefix = "r16_007_baseline_role_memory_packs"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/non_claims.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/generation_summary.json") },
        @{ Task = "R16-008"; Prefix = "r16_008_memory_pack_validation_stale_ref_detection"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/README.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/validation_manifest.md", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/non_claims.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/detection_summary.json") },
        @{ Task = "R16-009"; Prefix = "r16_009_artifact_map_contract"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_009_artifact_map_contract/proof_review.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_009_artifact_map_contract/evidence_index.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_009_artifact_map_contract/validation_manifest.md") },
        @{ Task = "R16-010"; Prefix = "r16_010_artifact_map_generator"; Files = @("state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/proof_review.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/evidence_index.json", "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/validation_manifest.md") }
    )

    foreach ($package in $proofPackageDefs) {
        foreach ($path in $package.Files) {
            $normalizedPath = $path.Replace("FOUNDATION", "foundation")
            $leaf = [System.IO.Path]::GetFileName($normalizedPath)
            $artifactClass = if ($leaf -eq "validation_manifest.md") { "validation_manifest" } else { "proof_review_package" }
            $artifactRole = if ($leaf -eq "proof_review.json") { "proof_review" } elseif ($leaf -eq "validation_manifest.md") { "proof_manifest" } else { "evidence_context" }
            $evidenceKind = if ($leaf -eq "validation_manifest.md") { "validation_manifest" } else { "proof_review_package" }
            $items += New-R16ArtifactDefinition -Id ("{0}_{1}" -f $package.Prefix, (ConvertTo-ArtifactIdPart -Value $leaf)) -Path $normalizedPath -ArtifactClass $artifactClass -ArtifactRole $artifactRole -AuthorityClass "proof_authority" -EvidenceKind $evidenceKind -ProofStatus "context_only" -SourceTask $package.Task -OwnerRole "evidence_auditor" -MachineProof $false -ImplementationProof $false
        }
    }

    return $items
}

function New-R16SourceRef {
    param(
        [Parameter(Mandatory = $true)]$Definition,
        [Parameter(Mandatory = $true)][string]$ArtifactId
    )

    return [ordered]@{
        ref_id = ("{0}_self_ref" -f $ArtifactId)
        path = [string]$Definition.Path
        source_task = [string]$Definition.SourceTask
        source_milestone = $script:R16Milestone
        artifact_class = [string]$Definition.ArtifactClass
        authority_class = [string]$Definition.AuthorityClass
        evidence_kind = [string]$Definition.EvidenceKind
        proof_status = [string]$Definition.ProofStatus
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        stale_state = "fresh"
        caveat_id = ""
        generated_from_head = $script:InputHead
        generated_from_tree = $script:InputTree
        machine_proof = [bool]$Definition.MachineProof
        implementation_proof = [bool]$Definition.ImplementationProof
    }
}

function New-R16InspectionRoute {
    param(
        [Parameter(Mandatory = $true)][string]$ArtifactId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$OwnerRole
    )

    return [ordered]@{
        route_id = ("{0}_inspection" -f $ArtifactId)
        route_kind = "exact_file_read"
        path = $Path
        expected_reader_role = $OwnerRole
        exact_command = ("Get-Content -LiteralPath {0}" -f $Path)
        broad_scan_allowed = $false
        wildcard_allowed = $false
        fallback_route = "none"
        inspection_notes = "Inspect this exact repo-relative path only; do not infer from a repository-wide scan."
    }
}

function New-R16ArtifactRecord {
    param(
        [Parameter(Mandatory = $true)]$Definition,
        [Parameter(Mandatory = $true)][int]$Order
    )

    $artifactId = [string]$Definition.Id
    return [ordered]@{
        artifact_id = $artifactId
        path = [string]$Definition.Path
        artifact_class = [string]$Definition.ArtifactClass
        artifact_role = [string]$Definition.ArtifactRole
        authority_class = [string]$Definition.AuthorityClass
        evidence_kind = [string]$Definition.EvidenceKind
        lifecycle_state = "active"
        proof_status = [string]$Definition.ProofStatus
        source_task = [string]$Definition.SourceTask
        source_milestone = $script:R16Milestone
        owner_role = [string]$Definition.OwnerRole
        source_refs = @((New-R16SourceRef -Definition $Definition -ArtifactId $artifactId))
        dependency_refs = @()
        generated_from_head = $script:InputHead
        generated_from_tree = $script:InputTree
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        inspection_route = New-R16InspectionRoute -ArtifactId $artifactId -Path ([string]$Definition.Path) -OwnerRole ([string]$Definition.OwnerRole)
        caveats = @()
        non_claims = [string[]]$Definition.NonClaims
        deterministic_order = $Order
    }
}

function New-R16DependencyRefFromRecord {
    param([Parameter(Mandatory = $true)]$Record)

    return [ordered]@{
        ref_id = [string]$Record.artifact_id
        path = [string]$Record.path
        artifact_class = [string]$Record.artifact_class
        artifact_role = [string]$Record.artifact_role
        authority_class = [string]$Record.authority_class
        evidence_kind = [string]$Record.evidence_kind
        source_task = [string]$Record.source_task
        source_milestone = [string]$Record.source_milestone
        proof_status = [string]$Record.proof_status
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        stale_state = "fresh"
        caveat_id = ""
        generated_from_head = $script:InputHead
        generated_from_tree = $script:InputTree
        machine_proof = ($Record.source_refs[0].machine_proof -eq $true)
        implementation_proof = ($Record.source_refs[0].implementation_proof -eq $true)
    }
}

function New-R16Relationship {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter(Mandatory = $true)][string]$From,
        [Parameter(Mandatory = $true)][string]$To,
        [Parameter(Mandatory = $true)][string]$Kind,
        [Parameter(Mandatory = $true)][string]$EvidenceKind,
        [Parameter(Mandatory = $true)][string]$ProofStatus,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        relationship_id = $Id
        relationship_type = $Type
        from_artifact_id = $From
        to_artifact_id = $To
        dependency_kind = $Kind
        required = $true
        evidence_kind = $EvidenceKind
        proof_status = $ProofStatus
        deterministic_order = $Order
    }
}

function New-R16ArtifactMapRelationships {
    return @(
        (New-R16Relationship -Id "r16_artifact_map_state_generated_by_generator_module" -Type "depends_on" -From "r16_010_artifact_map_state" -To "r16_010_artifact_map_generator" -Kind "generated_by" -EvidenceKind "committed_machine_evidence" -ProofStatus "proof_if_validator_backed" -Order 1),
        (New-R16Relationship -Id "r16_artifact_map_generator_cli_wraps_module" -Type "wraps" -From "r16_010_artifact_map_generator_cli" -To "r16_010_artifact_map_generator" -Kind "cli_wrapper" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -Order 2),
        (New-R16Relationship -Id "r16_artifact_map_state_validated_by_validator_cli" -Type "validated_by" -From "r16_010_artifact_map_state" -To "r16_010_artifact_map_validator_cli" -Kind "artifact_map_validation" -EvidenceKind "cli_wrapper" -ProofStatus "proof_if_validator_backed" -Order 3),
        (New-R16Relationship -Id "r16_artifact_map_generator_test_exercises_state" -Type "exercises" -From "r16_010_artifact_map_generator_test" -To "r16_010_artifact_map_state" -Kind "focused_test" -EvidenceKind "focused_test" -ProofStatus "proof_if_validator_backed" -Order 4),
        (New-R16Relationship -Id "r16_artifact_map_contract_models_state" -Type "models" -From "r16_009_artifact_map_contract" -To "r16_010_artifact_map_state" -Kind "contract_model" -EvidenceKind "contract_schema" -ProofStatus "proof_if_validator_backed" -Order 5),
        (New-R16Relationship -Id "r16_artifact_map_valid_fixture_models_state" -Type "models" -From "r16_010_artifact_map_generator_fixture_valid_artifact_map_json" -To "r16_010_artifact_map_state" -Kind "valid_fixture" -EvidenceKind "valid_fixture" -ProofStatus "proof_if_validator_backed" -Order 6),
        (New-R16Relationship -Id "r16_artifact_map_proof_review_depends_on_state" -Type "depends_on" -From "r16_010_artifact_map_generator_proof_review_json" -To "r16_010_artifact_map_state" -Kind "evidence_for" -EvidenceKind "proof_review_package" -ProofStatus "context_only" -Order 7),
        (New-R16Relationship -Id "r16_artifact_map_validation_manifest_depends_on_validator" -Type "depends_on" -From "r16_010_artifact_map_generator_validation_manifest_md" -To "r16_010_artifact_map_validator_cli" -Kind "summarized_by" -EvidenceKind "validation_manifest" -ProofStatus "context_only" -Order 8)
    )
}

function Get-R16ValidationCommands {
    $commands = @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_artifact_map.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_artifact_map_contract.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_artifact_map_contract.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_pack_validation.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_pack_validation_report.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layers.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_milestone_reporting_standard.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_milestone_reporting_standard.ps1",
        "git diff --check",
        "git diff --cached --check"
    )

    $order = 1
    return @($commands | ForEach-Object {
        [ordered]@{
            command = $_
            expected_result = "pass"
            deterministic_order = $order++
        }
    })
}

function Get-R16InvalidStateRules {
    $rules = @(
        "missing_required_path_rejected",
        "wildcard_path_rejected",
        "broad_repo_root_path_rejected",
        "full_repo_scan_claim_rejected",
        "runtime_memory_claim_rejected",
        "audit_map_claim_rejected",
        "context_load_planner_claim_rejected",
        "report_as_machine_proof_rejected",
        "stale_ref_without_caveat_rejected",
        "r16_011_or_later_implementation_claim_rejected",
        "r16_027_or_later_task_rejected",
        "r13_closure_claim_rejected",
        "r14_caveat_removal_rejected",
        "r15_caveat_removal_rejected",
        "r13_partial_gate_conversion_claim_rejected"
    )

    $order = 1
    return @($rules | ForEach-Object {
        [ordered]@{
            rule_id = $_
            enforced = $true
            deterministic_order = $order++
        }
    })
}

function New-R16PreservedBoundaries {
    return [ordered]@{
        r13 = [ordered]@{
            status = "failed/partial"
            active_through = "R13-018"
            closed = $false
            partial_gates_remain_partial = $true
            partial_gates = @(
                "API/custom-runner bypass",
                "current operator control room",
                "skill invocation evidence",
                "operator demo"
            )
        }
        r14 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R14-006"
            caveats_removed = $false
            r13_partial_gates_converted_to_passed = $false
        }
        r15 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R15-009"
            audited_head = $script:R15AuditedHead
            audited_tree = $script:R15AuditedTree
            post_audit_support_commit = $script:R15PostAuditSupportCommit
            caveats_removed = $false
            stale_generated_from_caveat_preserved = $true
        }
    }
}

function New-R16ArtifactMapObject {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_map.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Get-R16ArtifactMapContractSemantics -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath | Out-Null

    $definitions = Get-R16ArtifactDefinitions
    $records = @()
    for ($index = 0; $index -lt $definitions.Count; $index += 1) {
        $records += New-R16ArtifactRecord -Definition $definitions[$index] -Order ($index + 1)
    }

    $recordMap = @{}
    foreach ($record in $records) {
        $recordMap[[string]$record.artifact_id] = $record
    }

    $mapState = $recordMap["r16_010_artifact_map_state"]
    if ($null -ne $mapState) {
        $mapState["dependency_refs"] = @(
            (New-R16DependencyRefFromRecord -Record $recordMap["r16_010_artifact_map_generator"]),
            (New-R16DependencyRefFromRecord -Record $recordMap["r16_010_artifact_map_generator_cli"]),
            (New-R16DependencyRefFromRecord -Record $recordMap["r16_010_artifact_map_validator_cli"]),
            (New-R16DependencyRefFromRecord -Record $recordMap["r16_010_artifact_map_generator_test"]),
            (New-R16DependencyRefFromRecord -Record $recordMap["r16_009_artifact_map_contract"])
        )
    }

    return [ordered]@{
        artifact_type = "r16_artifact_map"
        artifact_map_version = "v1"
        artifact_map_id = "aioffice-r16-010-artifact-map-v1"
        source_milestone = $script:R16Milestone
        source_task = "R16-010"
        repository = $script:Repository
        branch = $script:Branch
        contract_ref = [ordered]@{
            path = "contracts/artifacts/r16_artifact_map.contract.json"
            source_task = "R16-009"
            contract_artifact_type = "r16_artifact_map_contract"
            contract_version = "v1"
            loaded_and_validated = $true
        }
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
            boundary_note = "This is the input boundary for generation, not a claim to equal the final commit created by R16-010."
        }
        generator = [ordered]@{
            module_path = "tools/R16ArtifactMapGenerator.psm1"
            cli_path = "tools/new_r16_artifact_map.ps1"
            validator_path = "tools/validate_r16_artifact_map.ps1"
            deterministic_output_ordering = $true
            broad_repo_scan_performed = $false
            wildcard_paths_loaded = $false
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
            missing_required_paths_rejected = $true
            reports_as_machine_proof_allowed = $false
            planning_reports_as_implementation_proof_allowed = $false
            stale_refs_without_caveat_allowed = $false
        }
        generation_mode = [ordered]@{
            artifact_map_generator_implemented = $true
            generated_artifact_map_exists = $true
            generated_artifact_map_is_state_artifact = $true
            generated_artifact_map_is_runtime_memory = $false
            audit_map_implemented = $false
            context_load_planner_implemented = $false
            context_budget_estimator_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            product_runtime_implemented = $false
            productized_ui_implemented = $false
            actual_autonomous_agents_implemented = $false
            true_multi_agent_execution_implemented = $false
            persistent_memory_runtime_implemented = $false
            runtime_memory_implemented = $false
            runtime_memory_loading_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            external_integrations_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            main_merge_completed = $false
            r16_011_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            r13_closure_claimed = $false
            r14_caveat_removed = $false
            r15_caveat_removed = $false
            r13_partial_gate_conversion_claimed = $false
        }
        current_posture = [ordered]@{
            active_through_task = "R16-010"
            complete_tasks = [string[]](1..10 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            planned_tasks = [string[]](11..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
            r16_011_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        required_paths = [string[]]$script:RequiredMapPaths
        artifact_records = $records
        relationships = New-R16ArtifactMapRelationships
        finding_summary = [ordered]@{
            missing_required_paths = 0
            wildcard_paths = 0
            broad_repo_root_paths = 0
            stale_refs_without_caveat = 0
            runtime_overclaims = 0
            audit_map_overclaims = 0
            context_planner_overclaims = 0
            later_task_overclaims = 0
        }
        aggregate_verdict = "passed"
        non_claims = [string[]]$script:RequiredNonClaims
        preserved_boundaries = New-R16PreservedBoundaries
        validation_commands = Get-R16ValidationCommands
        invalid_state_rules = Get-R16InvalidStateRules
    }
}

function Assert-GenerationBoundary {
    param(
        [Parameter(Mandatory = $true)]$Boundary,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundary -Context $Context
    if ($boundaryObject.input_head -ne $script:InputHead) {
        throw "$Context input_head must be $script:InputHead."
    }
    if ($boundaryObject.input_tree -ne $script:InputTree) {
        throw "$Context input_tree must be $script:InputTree."
    }
    if ((Assert-NonEmptyString -Value $boundaryObject.boundary_note -Context "$Context boundary_note") -notmatch 'input boundary for generation') {
        throw "$Context boundary_note must state that this is the input boundary for generation."
    }
}

function Assert-GenerationPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @("curated_exact_paths_only", "repo_relative_exact_paths_required", "missing_required_paths_rejected")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }

    Assert-FalseFields -Object $policyObject -Fields @(
        "broad_repo_scan_allowed",
        "broad_repo_scan_performed",
        "full_repo_scan_allowed",
        "full_repo_scan_performed",
        "wildcard_paths_allowed",
        "wildcard_paths_loaded",
        "reports_as_machine_proof_allowed",
        "planning_reports_as_implementation_proof_allowed",
        "stale_refs_without_caveat_allowed"
    ) -Context $Context
}

function Assert-GenerationMode {
    param(
        [Parameter(Mandatory = $true)]$Mode,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $modeObject = Assert-ObjectValue -Value $Mode -Context $Context
    foreach ($trueField in @("artifact_map_generator_implemented", "generated_artifact_map_exists", "generated_artifact_map_is_state_artifact")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $modeObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }

    Assert-FalseFields -Object $modeObject -Fields @(
        "generated_artifact_map_is_runtime_memory",
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
        "solved_codex_compaction",
        "solved_codex_reliability",
        "main_merge_completed",
        "r16_011_or_later_implementation_claimed",
        "r16_027_or_later_task_exists",
        "r13_closure_claimed",
        "r14_caveat_removed",
        "r15_caveat_removed",
        "r13_partial_gate_conversion_claimed"
    ) -Context $Context
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-010") {
        throw "$Context active_through_task must be R16-010."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"

    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in $completeTasks) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 11) {
            throw "$Context claims R16-011 or later implementation with '$taskId'."
        }
    }

    Assert-ExactStringSet -Values $completeTasks -ExpectedValues ([string[]](1..10 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues ([string[]](11..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_011_or_later_implementation_claimed" -Context $Context) -Context "$Context r16_011_or_later_implementation_claimed") -ne $false) {
        throw "$Context r16_011_or_later_implementation_claimed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $postureObject -Name "r16_027_or_later_task_exists" -Context $Context) -Context "$Context r16_027_or_later_task_exists") -ne $false) {
        throw "$Context r16_027_or_later_task_exists must be False."
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
    if ($r15.audited_head -ne $script:R15AuditedHead -or $r15.audited_tree -ne $script:R15AuditedTree) {
        throw "$Context r15 audited head/tree must remain unchanged."
    }
    if ($r15.post_audit_support_commit -ne $script:R15PostAuditSupportCommit) {
        throw "$Context r15 post_audit_support_commit must remain unchanged."
    }
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r15.stale_generated_from_caveat_preserved -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale_generated_from_caveat_preserved must be True."
    }
}

function Assert-PathPolicyFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $Object -Name "exact_path_only" -Context $Context) -Context "$Context exact_path_only") -ne $true) {
        throw "$Context exact_path_only must be True."
    }
    foreach ($falseField in @("broad_scan_allowed", "wildcard_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $Object -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
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

    $normalized = $Path.Trim().Replace("\", "/")
    $isMarkdown = $normalized -like "*.md"
    $isReport = $normalized -like "governance/reports/*"
    if (($isMarkdown -or $isReport) -and ($ProofStatus -eq "proof_by_itself_true" -or $MachineProof -or $ImplementationProof -or $EvidenceKind -eq "committed_machine_evidence")) {
        throw "$Context rejects report/Markdown planning artifact treated as machine implementation proof."
    }

    if ($normalized -eq "state/artifacts/r16_artifact_map.json" -and ($ArtifactClass -ne "state_artifact" -or $EvidenceKind -ne "generated_state_artifact")) {
        throw "$Context generated artifact map must be a committed generated state artifact only."
    }
}

function Assert-StaleState {
    param(
        [Parameter(Mandatory = $true)][string]$StaleState,
        [AllowNull()][string]$CaveatId,
        [string[]]$CaveatIds = @(),
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($StaleState -notin @("fresh", "stale_with_caveat", "stale_without_caveat_rejected")) {
        throw "$Context stale_state '$StaleState' is not allowed."
    }
    if ($StaleState -eq "stale_without_caveat_rejected") {
        throw "$Context stale ref without caveat is rejected."
    }
    if ($StaleState -eq "stale_with_caveat") {
        if ([string]::IsNullOrWhiteSpace($CaveatId) -or $CaveatIds -notcontains $CaveatId) {
            throw "$Context stale ref without caveat is rejected."
        }
    }
}

function Assert-Caveat {
    param(
        [Parameter(Mandatory = $true)]$Caveat,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredCaveatFields) {
        Get-RequiredProperty -Object $Caveat -Name $field -Context $Context | Out-Null
    }

    foreach ($field in @("caveat_id", "caveat_type", "applies_to_ref_id", "applies_to_path", "declared_boundary", "observed_boundary", "accepted_reason", "preserved_scope")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Caveat -Name $field -Context $Context) -Context "$Context $field" | Out-Null
    }
    $order = Assert-IntegerValue -Value $Caveat.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic caveat ordering."
    }
}

function Assert-SourceRef {
    param(
        [Parameter(Mandatory = $true)]$SourceRef,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string[]]$CaveatIds = @()
    )

    foreach ($field in $script:RequiredSourceRefFields) {
        Get-RequiredProperty -Object $SourceRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $SourceRef.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    Assert-PathPolicyFields -Object $SourceRef -Context $Context
    $machineProof = Assert-BooleanValue -Value $SourceRef.machine_proof -Context "$Context machine_proof"
    $implementationProof = Assert-BooleanValue -Value $SourceRef.implementation_proof -Context "$Context implementation_proof"
    Assert-ProofTreatmentForPath -Path $path -ArtifactClass $SourceRef.artifact_class -EvidenceKind $SourceRef.evidence_kind -ProofStatus $SourceRef.proof_status -MachineProof $machineProof -ImplementationProof $implementationProof -Context $Context
    Assert-StaleState -StaleState (Assert-NonEmptyString -Value $SourceRef.stale_state -Context "$Context stale_state") -CaveatId ([string]$SourceRef.caveat_id) -CaveatIds $CaveatIds -Context $Context
}

function Assert-DependencyRef {
    param(
        [Parameter(Mandatory = $true)]$DependencyRef,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    foreach ($field in $script:RequiredDependencyRefFields) {
        Get-RequiredProperty -Object $DependencyRef -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $DependencyRef.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    Assert-PathPolicyFields -Object $DependencyRef -Context $Context
    $machineProof = Assert-BooleanValue -Value $DependencyRef.machine_proof -Context "$Context machine_proof"
    $implementationProof = Assert-BooleanValue -Value $DependencyRef.implementation_proof -Context "$Context implementation_proof"
    Assert-ProofTreatmentForPath -Path $path -ArtifactClass $DependencyRef.artifact_class -EvidenceKind $DependencyRef.evidence_kind -ProofStatus $DependencyRef.proof_status -MachineProof $machineProof -ImplementationProof $implementationProof -Context $Context
    Assert-StaleState -StaleState (Assert-NonEmptyString -Value $DependencyRef.stale_state -Context "$Context stale_state") -CaveatId ([string]$DependencyRef.caveat_id) -CaveatIds @() -Context $Context
}

function Assert-InspectionRoute {
    param(
        [Parameter(Mandatory = $true)]$Route,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$RecordPath
    )

    foreach ($field in $script:RequiredInspectionRouteFields) {
        Get-RequiredProperty -Object $Route -Name $field -Context $Context | Out-Null
    }

    $path = Assert-NonEmptyString -Value $Route.path -Context "$Context path"
    if ($path -ne $RecordPath) {
        throw "$Context path must match the artifact record path."
    }
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    if ((Assert-BooleanValue -Value $Route.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $Route.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }
    if ((Assert-NonEmptyString -Value $Route.exact_command -Context "$Context exact_command") -notmatch [regex]::Escape($path)) {
        throw "$Context exact_command must name the exact path."
    }
}

function Assert-ArtifactRecord {
    param(
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)]$Semantics,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredArtifactRecordFields) {
        Get-RequiredProperty -Object $Record -Name $field -Context $Context | Out-Null
    }

    $artifactId = Assert-NonEmptyString -Value $Record.artifact_id -Context "$Context artifact_id"
    $path = Assert-NonEmptyString -Value $Record.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    Assert-PathPolicyFields -Object $Record -Context $Context

    if ($Record.artifact_class -notin $Semantics.AllowedArtifactClasses) {
        throw "$Context artifact_class '$($Record.artifact_class)' is not allowed."
    }
    if ($Record.artifact_role -notin $Semantics.AllowedArtifactRoles) {
        throw "$Context artifact_role '$($Record.artifact_role)' is not allowed."
    }
    if ($Record.authority_class -notin $Semantics.AllowedAuthorityClasses) {
        throw "$Context authority_class '$($Record.authority_class)' is not allowed."
    }
    if ($Record.evidence_kind -notin $Semantics.AllowedEvidenceKinds) {
        throw "$Context evidence_kind '$($Record.evidence_kind)' is not allowed."
    }
    if ($Record.lifecycle_state -notin $Semantics.AllowedLifecycleStates) {
        throw "$Context lifecycle_state '$($Record.lifecycle_state)' is not allowed."
    }
    if ($Record.proof_status -notin $Semantics.AllowedProofStatuses) {
        throw "$Context proof_status '$($Record.proof_status)' is not allowed."
    }

    $order = Assert-IntegerValue -Value $Record.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic ordering."
    }

    if ($Record.source_task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 11) {
        throw "$Context claims R16-011 or later implementation with source_task '$($Record.source_task)'."
    }
    if ($Record.source_task -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
        throw "$Context introduces R16-027 or later task '$($Record.source_task)'."
    }

    $caveats = Assert-ObjectArray -Value $Record.caveats -Context "$Context caveats" -AllowEmpty
    $caveatIds = @()
    for ($index = 0; $index -lt $caveats.Count; $index += 1) {
        Assert-Caveat -Caveat $caveats[$index] -Context "$Context caveats[$index]" -ExpectedOrder ($index + 1)
        $caveatIds += [string]$caveats[$index].caveat_id
    }
    if ($Record.proof_status -eq "stale_without_caveat_rejected") {
        throw "$Context stale ref without caveat is rejected."
    }
    if ($Record.proof_status -eq "stale_with_caveat" -and $caveatIds.Count -eq 0) {
        throw "$Context stale ref without caveat is rejected."
    }

    $sourceRefs = Assert-ObjectArray -Value $Record.source_refs -Context "$Context source_refs"
    for ($index = 0; $index -lt $sourceRefs.Count; $index += 1) {
        Assert-SourceRef -SourceRef $sourceRefs[$index] -Context "$Context source_refs[$index]" -RepositoryRoot $RepositoryRoot -CaveatIds $caveatIds
    }

    $dependencyRefs = Assert-ObjectArray -Value $Record.dependency_refs -Context "$Context dependency_refs" -AllowEmpty
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-DependencyRef -DependencyRef $dependencyRefs[$index] -Context "$Context dependency_refs[$index]" -RepositoryRoot $RepositoryRoot
    }

    $route = Assert-ObjectValue -Value $Record.inspection_route -Context "$Context inspection_route"
    Assert-InspectionRoute -Route $route -Context "$Context inspection_route" -RepositoryRoot $RepositoryRoot -RecordPath $path

    $nonClaims = Assert-StringArray -Value $Record.non_claims -Context "$Context non_claims"
    if ($path -eq "state/artifacts/r16_artifact_map.json") {
        Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues @(
            "The artifact map is not runtime memory.",
            "The artifact map is not an audit map.",
            "The artifact map is not a context-load planner.",
            "The artifact map is not workflow execution."
        ) -Context "$Context non_claims"
    }

    return $artifactId
}

function Assert-Relationship {
    param(
        [Parameter(Mandatory = $true)]$Relationship,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string[]]$ArtifactIds,
        [Parameter(Mandatory = $true)][string[]]$AllowedRelationshipTypes,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    foreach ($field in $script:RequiredRelationshipFields) {
        Get-RequiredProperty -Object $Relationship -Name $field -Context $Context | Out-Null
    }

    if ($Relationship.relationship_type -notin $AllowedRelationshipTypes) {
        throw "$Context relationship_type '$($Relationship.relationship_type)' is not allowed."
    }
    if ($ArtifactIds -notcontains [string]$Relationship.from_artifact_id -or $ArtifactIds -notcontains [string]$Relationship.to_artifact_id) {
        throw "$Context relationship endpoints must reference known artifact ids."
    }
    if ((Assert-BooleanValue -Value $Relationship.required -Context "$Context required") -ne $true) {
        throw "$Context required must be True."
    }
    $order = Assert-IntegerValue -Value $Relationship.deterministic_order -Context "$Context deterministic_order"
    if ($order -ne $ExpectedOrder) {
        throw "$Context has non-deterministic relationship ordering."
    }
}

function Assert-FindingSummary {
    param(
        [Parameter(Mandatory = $true)]$Summary,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $summaryObject = Assert-ObjectValue -Value $Summary -Context $Context
    foreach ($field in @(
        "missing_required_paths",
        "wildcard_paths",
        "broad_repo_root_paths",
        "stale_refs_without_caveat",
        "runtime_overclaims",
        "audit_map_overclaims",
        "context_planner_overclaims",
        "later_task_overclaims"
    )) {
        $value = Assert-IntegerValue -Value (Get-RequiredProperty -Object $summaryObject -Name $field -Context $Context) -Context "$Context $field"
        if ($value -ne 0) {
            throw "$Context $field must be 0."
        }
    }
}

function Test-R16ArtifactMapObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$ArtifactMap,
        [string]$SourceLabel = "R16 artifact map",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_map.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $semantics = Get-R16ArtifactMapContractSemantics -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $ArtifactMap -Name $field -Context $SourceLabel | Out-Null
    }

    if ($ArtifactMap.artifact_type -ne "r16_artifact_map") {
        throw "$SourceLabel artifact_type must be r16_artifact_map."
    }
    if ($ArtifactMap.artifact_map_version -ne "v1") {
        throw "$SourceLabel artifact_map_version must be v1."
    }
    if ($ArtifactMap.source_task -ne "R16-010") {
        throw "$SourceLabel source_task must be R16-010."
    }
    if ($ArtifactMap.source_milestone -ne $script:R16Milestone) {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($ArtifactMap.repository -ne $script:Repository) {
        throw "$SourceLabel repository must be $script:Repository."
    }
    if ($ArtifactMap.branch -ne $script:Branch) {
        throw "$SourceLabel branch must be $script:Branch."
    }

    $contractRef = Assert-ObjectValue -Value $ArtifactMap.contract_ref -Context "$SourceLabel contract_ref"
    if ($contractRef.path -ne $ContractPath.Replace("\", "/") -or $contractRef.loaded_and_validated -ne $true) {
        throw "$SourceLabel contract_ref must load and validate contracts/artifacts/r16_artifact_map.contract.json."
    }

    Assert-GenerationBoundary -Boundary $ArtifactMap.generation_boundary -Context "$SourceLabel generation_boundary"
    Assert-GenerationPolicy -Policy $ArtifactMap.generation_policy -Context "$SourceLabel generation_policy"
    Assert-GenerationMode -Mode $ArtifactMap.generation_mode -Context "$SourceLabel generation_mode"
    Assert-CurrentPosture -Posture $ArtifactMap.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $ArtifactMap.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $nonClaims = Assert-StringArray -Value $ArtifactMap.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    $requiredPaths = Assert-StringArray -Value $ArtifactMap.required_paths -Context "$SourceLabel required_paths"
    Assert-RequiredValuesPresent -Values $requiredPaths -RequiredValues $script:RequiredMapPaths -Context "$SourceLabel required_paths"

    $records = Assert-ObjectArray -Value $ArtifactMap.artifact_records -Context "$SourceLabel artifact_records"
    $artifactIds = @()
    $recordPaths = @()
    for ($index = 0; $index -lt $records.Count; $index += 1) {
        $artifactId = Assert-ArtifactRecord -Record $records[$index] -Context "$SourceLabel artifact_records[$index]" -Semantics $semantics -RepositoryRoot $resolvedRepositoryRoot -ExpectedOrder ($index + 1)
        if ($artifactIds -contains $artifactId) {
            throw "$SourceLabel duplicate artifact id '$artifactId' is rejected."
        }
        $artifactIds += $artifactId
        $recordPaths += [string]$records[$index].path
    }

    foreach ($requiredPath in $script:RequiredMapPaths) {
        if ($recordPaths -notcontains $requiredPath) {
            throw "$SourceLabel missing required path '$requiredPath'."
        }
    }

    $relationships = Assert-ObjectArray -Value $ArtifactMap.relationships -Context "$SourceLabel relationships" -AllowEmpty
    for ($index = 0; $index -lt $relationships.Count; $index += 1) {
        Assert-Relationship -Relationship $relationships[$index] -Context "$SourceLabel relationships[$index]" -ArtifactIds $artifactIds -AllowedRelationshipTypes $semantics.AllowedRelationshipTypes -ExpectedOrder ($index + 1)
    }

    Assert-FindingSummary -Summary $ArtifactMap.finding_summary -Context "$SourceLabel finding_summary"
    if ($ArtifactMap.aggregate_verdict -ne "passed") {
        throw "$SourceLabel aggregate_verdict must be passed."
    }

    $validationCommands = Assert-ObjectArray -Value $ArtifactMap.validation_commands -Context "$SourceLabel validation_commands"
    if ($validationCommands.Count -eq 0) {
        throw "$SourceLabel validation_commands must not be empty."
    }
    $invalidRules = Assert-ObjectArray -Value $ArtifactMap.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues @(
        "missing_required_path_rejected",
        "wildcard_path_rejected",
        "full_repo_scan_claim_rejected",
        "runtime_memory_claim_rejected",
        "audit_map_claim_rejected",
        "context_load_planner_claim_rejected",
        "report_as_machine_proof_rejected",
        "stale_ref_without_caveat_rejected",
        "r16_011_or_later_implementation_claim_rejected",
        "r13_closure_claim_rejected",
        "r14_caveat_removal_rejected",
        "r15_caveat_removal_rejected"
    ) -Context "$SourceLabel invalid_state_rules"

    return [pscustomobject]@{
        ArtifactMapId = $ArtifactMap.artifact_map_id
        SourceTask = $ArtifactMap.source_task
        ActiveThroughTask = $ArtifactMap.current_posture.active_through_task
        PlannedTaskStart = $ArtifactMap.current_posture.planned_tasks[0]
        PlannedTaskEnd = $ArtifactMap.current_posture.planned_tasks[-1]
        RecordCount = $records.Count
        RelationshipCount = $relationships.Count
        RequiredPathCount = $script:RequiredMapPaths.Count
        AggregateVerdict = $ArtifactMap.aggregate_verdict
        GeneratedArtifactMapIsRuntimeMemory = [bool]$ArtifactMap.generation_mode.generated_artifact_map_is_runtime_memory
        AuditMapImplemented = [bool]$ArtifactMap.generation_mode.audit_map_implemented
        ContextLoadPlannerImplemented = [bool]$ArtifactMap.generation_mode.context_load_planner_implemented
    }
}

function Test-R16ArtifactMap {
    [CmdletBinding()]
    param(
        [string]$Path = "state/artifacts/r16_artifact_map.json",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_map.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRepositoryRoot -Context "R16 artifact map path" -RequireLeaf
    $artifactMap = Read-SingleJsonObject -Path $resolvedPath -Label "R16 artifact map"
    return Test-R16ArtifactMapObject -ArtifactMap $artifactMap -SourceLabel $Path -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath
}

function New-R16ArtifactMap {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/artifacts/r16_artifact_map.json",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_map.contract.json"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutputPath = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -Context "OutputPath"
    $artifactMap = New-R16ArtifactMapObject -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath
    Write-StableJsonFile -Object $artifactMap -Path $resolvedOutputPath
    $validation = Test-R16ArtifactMap -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -ContractPath $ContractPath

    return [pscustomobject]@{
        OutputPath = $OutputPath
        ArtifactMapId = $validation.ArtifactMapId
        RecordCount = $validation.RecordCount
        RelationshipCount = $validation.RelationshipCount
        RequiredPathCount = $validation.RequiredPathCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
    }
}

function Set-DeterministicRecordOrder {
    param([Parameter(Mandatory = $true)]$ArtifactMap)

    $records = @($ArtifactMap.artifact_records)
    for ($index = 0; $index -lt $records.Count; $index += 1) {
        $records[$index].deterministic_order = $index + 1
    }
    $ArtifactMap.artifact_records = $records
}

function New-MinimalInvalidFixtureObject {
    param(
        [Parameter(Mandatory = $true)]$ValidObject,
        [int]$RecordIndex = 0
    )

    $fixture = Copy-JsonObject -Value $ValidObject
    $fixture.artifact_records = @($fixture.artifact_records[$RecordIndex])
    $fixture.artifact_records[0].deterministic_order = 1
    $fixture.relationships = @()
    return $fixture
}

function New-R16ArtifactMapFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_artifact_map_generator",
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = Resolve-RepoRelativePathValue -Path $FixtureRoot -RepositoryRoot $resolvedRepositoryRoot
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $valid = New-R16ArtifactMapObject -RepositoryRoot $resolvedRepositoryRoot
    Write-StableJsonFile -Object $valid -Path (Join-Path $resolvedFixtureRoot "valid_artifact_map.json")

    $missing = Copy-JsonObject -Value $valid
    $missing.artifact_records = @($missing.artifact_records | Where-Object { $_.path -ne "README.md" })
    Set-DeterministicRecordOrder -ArtifactMap $missing
    Write-StableJsonFile -Object $missing -Path (Join-Path $resolvedFixtureRoot "invalid_missing_required_path.json")

    $wildcard = New-MinimalInvalidFixtureObject -ValidObject $valid
    $wildcard.artifact_records[0].path = "tools/*.ps1"
    $wildcard.artifact_records[0].inspection_route.path = "tools/*.ps1"
    $wildcard.artifact_records[0].source_refs[0].path = "tools/*.ps1"
    Write-StableJsonFile -Object $wildcard -Path (Join-Path $resolvedFixtureRoot "invalid_wildcard_path.json")

    $broad = New-MinimalInvalidFixtureObject -ValidObject $valid
    $broad.generation_policy.full_repo_scan_performed = $true
    Write-StableJsonFile -Object $broad -Path (Join-Path $resolvedFixtureRoot "invalid_broad_scan_claim.json")

    $runtime = New-MinimalInvalidFixtureObject -ValidObject $valid
    $runtime.generation_mode.generated_artifact_map_is_runtime_memory = $true
    Write-StableJsonFile -Object $runtime -Path (Join-Path $resolvedFixtureRoot "invalid_runtime_memory_claim.json")

    $audit = New-MinimalInvalidFixtureObject -ValidObject $valid
    $audit.generation_mode.audit_map_implemented = $true
    Write-StableJsonFile -Object $audit -Path (Join-Path $resolvedFixtureRoot "invalid_audit_map_claim.json")

    $contextPlanner = New-MinimalInvalidFixtureObject -ValidObject $valid
    $contextPlanner.generation_mode.context_load_planner_implemented = $true
    Write-StableJsonFile -Object $contextPlanner -Path (Join-Path $resolvedFixtureRoot "invalid_context_planner_claim.json")

    $reportProof = New-MinimalInvalidFixtureObject -ValidObject $valid
    $reportProof.artifact_records[0].proof_status = "proof_by_itself_true"
    $reportProof.artifact_records[0].source_refs[0].proof_status = "proof_by_itself_true"
    $reportProof.artifact_records[0].source_refs[0].machine_proof = $true
    $reportProof.artifact_records[0].source_refs[0].implementation_proof = $true
    Write-StableJsonFile -Object $reportProof -Path (Join-Path $resolvedFixtureRoot "invalid_report_as_machine_proof.json")

    $stale = New-MinimalInvalidFixtureObject -ValidObject $valid
    $stale.artifact_records[0].proof_status = "stale_with_caveat"
    $stale.artifact_records[0].source_refs[0].stale_state = "stale_with_caveat"
    $stale.artifact_records[0].source_refs[0].caveat_id = "missing_caveat"
    Write-StableJsonFile -Object $stale -Path (Join-Path $resolvedFixtureRoot "invalid_stale_ref_without_caveat.json")

    $r16Later = New-MinimalInvalidFixtureObject -ValidObject $valid
    $r16Later.current_posture.complete_tasks += "R16-011"
    $r16Later.current_posture.r16_011_or_later_implementation_claimed = $true
    Write-StableJsonFile -Object $r16Later -Path (Join-Path $resolvedFixtureRoot "invalid_r16_011_claim.json")

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
        ValidFixture = Join-Path $FixtureRoot "valid_artifact_map.json"
        InvalidFixtureCount = 12
    }
}

function Get-R16ArtifactMapRequiredPaths {
    return [string[]]$script:RequiredMapPaths
}

Export-ModuleMember -Function New-R16ArtifactMapObject, New-R16ArtifactMap, Test-R16ArtifactMap, Test-R16ArtifactMapObject, New-R16ArtifactMapFixtureFiles, Get-R16ArtifactMapRequiredPaths, ConvertTo-StableJson
