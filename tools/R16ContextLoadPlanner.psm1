Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16AuditMapGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ArtifactAuditMapCheck.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "bdb8b1cf464e015859893c3940ba10f2906467f4"
$script:InputTree = "6b556d925f3c2eecc036e6923ea97a1944b2f4a2"
$script:PlanId = "aioffice-r16-015-context-load-plan-v1"
$script:CompleteTasks = [string[]](1..15 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
$script:PlannedTasks = [string[]](16..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "plan_version",
    "plan_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "requesting_role",
    "target_task",
    "target_workflow_phase",
    "role_memory_pack_ref",
    "artifact_map_ref",
    "audit_map_ref",
    "check_report_ref",
    "load_policy",
    "generation_mode",
    "load_groups",
    "context_budget",
    "current_posture",
    "preserved_boundaries",
    "accepted_caveats",
    "proof_treatment_policy",
    "validation_findings",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "non_claims",
    "generated_artifact_statement"
)

$script:RequiredRefFields = @(
    "ref_id",
    "path",
    "source_task",
    "loaded_and_validated",
    "exact_path_only",
    "broad_scan_allowed",
    "wildcard_allowed",
    "deterministic_order"
)

$script:RequiredLoadItemFields = @(
    "item_id",
    "path",
    "ref_kind",
    "source_ref",
    "source_task",
    "authority_level",
    "proof_status",
    "proof_treatment",
    "load_required",
    "machine_proof",
    "implementation_proof",
    "exact_path_only",
    "broad_scan_allowed",
    "wildcard_allowed",
    "remote_verified",
    "deterministic_order"
)

$script:RequiredFalseGenerationModeFields = @(
    "context_budget_estimator_implemented",
    "over_budget_fail_closed_validator_implemented",
    "runtime_memory_implemented",
    "runtime_memory_loading_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "product_runtime_implemented",
    "productized_ui_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "external_integrations_implemented",
    "role_run_envelope_implemented",
    "raci_transition_gate_implemented",
    "handoff_packet_implemented",
    "workflow_drill_run",
    "r16_016_or_later_implementation_claimed",
    "r16_027_or_later_task_exists",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "r13_partial_gate_conversion_claimed",
    "main_merge_completed",
    "solved_codex_compaction",
    "solved_codex_reliability"
)

$script:RequiredNonClaims = @(
    "state/context/r16_context_load_plan.json is a committed generated context-load plan state artifact only",
    "the context-load plan is not runtime memory",
    "the context-load plan is not runtime memory loading",
    "the context-load plan is not retrieval runtime",
    "the context-load plan is not vector search runtime",
    "the context-load plan is not product runtime",
    "the context-load plan is not a context budget estimator",
    "the context-load plan is not an over-budget fail-closed validator",
    "the context-load plan is not a role-run envelope",
    "the context-load plan is not a RACI transition gate",
    "the context-load plan is not a handoff packet",
    "the context-load plan is not workflow execution",
    "no context budget estimator",
    "no over-budget fail-closed validator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no runtime memory",
    "no runtime memory loading",
    "no retrieval runtime",
    "no vector search runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved",
    "R16-016 through R16-026 remain planned only"
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

function Assert-RequiredStringsPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($item in $Required) {
        if ($Actual -notcontains $item) {
            throw "$Context must include '$item'."
        }
    }
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $sortedActual = @($Actual | Sort-Object)
    $sortedExpected = @($Expected | Sort-Object)
    if ($sortedActual.Count -ne $sortedExpected.Count) {
        throw "$Context must contain exactly: $($sortedExpected -join ', ')."
    }

    for ($index = 0; $index -lt $sortedExpected.Count; $index += 1) {
        if ($sortedActual[$index] -ne $sortedExpected[$index]) {
            throw "$Context must contain exactly: $($sortedExpected -join ', ')."
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

function Assert-TrueField {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $value = Get-RequiredProperty -Object $Object -Name $Field -Context $Context
    if ((Assert-BooleanValue -Value $value -Context "$Context $Field") -ne $true) {
        throw "$Context $Field must be True."
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
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ($normalized.EndsWith("/")) {
        return $true
    }

    if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)' -or $normalized -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return (Test-Path -LiteralPath $resolved -PathType Container)
}

function Test-LocalScratchPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return $normalized -match '^(scratch|tmp|temp|state/temp|state/tmp|state/scratch)(/|$)'
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ($normalized -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        throw "$Context rejects remote or non-repo path '$Path'."
    }
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context path must be repo-relative, not absolute."
    }
    if (Test-BroadRepoRootPath -Path $normalized) {
        throw "$Context rejects broad repo scan or broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $normalized) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }
    if (Test-DirectoryOnlyPath -Path $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context rejects directory-only ref '$Path'."
    }
    if (Test-LocalScratchPath -Path $normalized) {
        throw "$Context rejects local scratch ref '$Path'."
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

function Get-R16ContextLoadInputBundle {
    param(
        [Parameter(Mandatory = $true)][string]$RoleMemoryPacksPath,
        [Parameter(Mandatory = $true)][string]$ArtifactMapPath,
        [Parameter(Mandatory = $true)][string]$AuditMapPath,
        [Parameter(Mandatory = $true)][string]$CheckReportPath,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    Test-R16RoleMemoryPacks -PacksPath $RoleMemoryPacksPath -ModelPath "state/memory/r16_role_memory_pack_model.json" -MemoryLayersPath "state/memory/r16_memory_layers.json" -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16ArtifactMap -Path $ArtifactMapPath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16AuditMap -Path $AuditMapPath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16ArtifactAuditMapCheckReport -Path $CheckReportPath -RepositoryRoot $RepositoryRoot | Out-Null

    $roleMemoryPacks = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $RoleMemoryPacksPath) -Label "R16 role memory packs"
    $artifactMap = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $ArtifactMapPath) -Label "R16 artifact map"
    $auditMap = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $AuditMapPath) -Label "R16 audit map"
    $checkReport = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot $CheckReportPath) -Label "R16 artifact/audit map check report"

    $rolePack = @($roleMemoryPacks.role_packs | Where-Object { $_.role_id -eq "evidence_auditor" })
    if ($rolePack.Count -ne 1) {
        throw "R16 role memory packs must contain exactly one role_id 'evidence_auditor'."
    }

    return [pscustomobject]@{
        RoleMemoryPacks = $roleMemoryPacks
        EvidenceAuditorRolePack = $rolePack[0]
        ArtifactMap = $artifactMap
        AuditMap = $auditMap
        CheckReport = $checkReport
    }
}

function New-SourceRef {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][int]$Order,
        [string]$RoleId = ""
    )

    $ref = [ordered]@{
        ref_id = $RefId
        path = (ConvertTo-NormalizedRepoPath -Path $Path)
        source_task = $SourceTask
        loaded_and_validated = $true
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        deterministic_order = $Order
    }
    if (-not [string]::IsNullOrWhiteSpace($RoleId)) {
        $ref["role_id"] = $RoleId
    }
    return $ref
}

function New-LoadItem {
    param(
        [Parameter(Mandatory = $true)][string]$ItemId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RefKind,
        [Parameter(Mandatory = $true)][string]$SourceRef,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$AuthorityLevel,
        [Parameter(Mandatory = $true)][string]$ProofStatus,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        item_id = $ItemId
        path = (ConvertTo-NormalizedRepoPath -Path $Path)
        ref_kind = $RefKind
        source_ref = $SourceRef
        source_task = $SourceTask
        authority_level = $AuthorityLevel
        proof_status = $ProofStatus
        proof_treatment = $ProofTreatment
        load_required = $true
        machine_proof = $false
        implementation_proof = $false
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        remote_verified = $true
        deterministic_order = $Order
    }
}

function New-LoadGroup {
    param(
        [Parameter(Mandatory = $true)][string]$GroupId,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [Parameter(Mandatory = $true)][object[]]$LoadItems,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        group_id = $GroupId
        purpose = $Purpose
        load_items = @($LoadItems)
        required_refs = @($LoadItems | ForEach-Object { [string]$_.item_id })
        optional_refs = @()
        forbidden_refs = @("wildcard paths", "broad repo scans", "directory-only refs", "local scratch refs", "unverified remote refs")
        deterministic_order = $Order
    }
}

function New-R16ContextLoadPlanObject {
    [CmdletBinding()]
    param(
        [string]$RoleMemoryPacksPath = "state/memory/r16_role_memory_packs.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json",
        [string]$AuditMapPath = "state/audit/r16_r15_r16_audit_map.json",
        [string]$CheckReportPath = "state/artifacts/r16_artifact_audit_map_check_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-SafeRepoRelativePath -Path $RoleMemoryPacksPath -RepositoryRoot $resolvedRoot -Context "RoleMemoryPacksPath" -RequireLeaf | Out-Null
    Assert-SafeRepoRelativePath -Path $ArtifactMapPath -RepositoryRoot $resolvedRoot -Context "ArtifactMapPath" -RequireLeaf | Out-Null
    Assert-SafeRepoRelativePath -Path $AuditMapPath -RepositoryRoot $resolvedRoot -Context "AuditMapPath" -RequireLeaf | Out-Null
    Assert-SafeRepoRelativePath -Path $CheckReportPath -RepositoryRoot $resolvedRoot -Context "CheckReportPath" -RequireLeaf | Out-Null

    $inputs = Get-R16ContextLoadInputBundle -RoleMemoryPacksPath $RoleMemoryPacksPath -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -CheckReportPath $CheckReportPath -RepositoryRoot $resolvedRoot
    if ([string]$inputs.CheckReport.aggregate_verdict -notin @("passed", "passed_with_caveats")) {
        throw "R16 context-load planner requires a passed or passed_with_caveats R16-013 check report."
    }

    $loadGroups = @(
        (New-LoadGroup -GroupId "role_scope_and_memory_policy" -Purpose "Load the evidence auditor role pack, role model, and memory-pack validation report as exact state artifacts." -Order 1 -LoadItems @(
            (New-LoadItem -ItemId "role_memory_packs_state" -Path "state/memory/r16_role_memory_packs.json" -RefKind "role_memory_pack_state_artifact" -SourceRef "role_memory_pack_ref" -SourceTask "R16-007" -AuthorityLevel "state_artifact" -ProofStatus "committed_state_artifact_only" -ProofTreatment "context for role-scoped planning only; not runtime memory" -Order 1),
            (New-LoadItem -ItemId "role_memory_pack_model_state" -Path "state/memory/r16_role_memory_pack_model.json" -RefKind "role_memory_pack_model_state_artifact" -SourceRef "role_memory_pack_ref" -SourceTask "R16-006" -AuthorityLevel "state_model" -ProofStatus "model_state_artifact_only" -ProofTreatment "role model context only; not actual agents" -Order 2),
            (New-LoadItem -ItemId "memory_pack_validation_report_state" -Path "state/memory/r16_memory_pack_validation_report.json" -RefKind "memory_pack_validation_report_state_artifact" -SourceRef "role_memory_pack_ref" -SourceTask "R16-008" -AuthorityLevel "validator_backed_state_artifact" -ProofStatus "validation_report_only" -ProofTreatment "validation context only; not runtime memory" -Order 3)
        )),
        (New-LoadGroup -GroupId "status_and_milestone_authority" -Purpose "Load current status surfaces and R16 authority by exact path only." -Order 2 -LoadItems @(
            (New-LoadItem -ItemId "status_readme" -Path "README.md" -RefKind "status_surface" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "governance_authority" -ProofStatus "context_only" -ProofTreatment "status authority context only" -Order 1),
            (New-LoadItem -ItemId "status_active_state" -Path "governance/ACTIVE_STATE.md" -RefKind "status_surface" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "governance_authority" -ProofStatus "context_only" -ProofTreatment "status authority context only" -Order 2),
            (New-LoadItem -ItemId "status_kanban" -Path "execution/KANBAN.md" -RefKind "task_board" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "operator_context" -ProofStatus "context_only" -ProofTreatment "task-board context only" -Order 3),
            (New-LoadItem -ItemId "status_decision_log" -Path "governance/DECISION_LOG.md" -RefKind "decision_log" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "governance_authority" -ProofStatus "context_only" -ProofTreatment "decision-log context only" -Order 4),
            (New-LoadItem -ItemId "document_authority_index" -Path "governance/DOCUMENT_AUTHORITY_INDEX.md" -RefKind "authority_index" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "governance_authority" -ProofStatus "context_only" -ProofTreatment "authority index context only" -Order 5),
            (New-LoadItem -ItemId "r16_authority" -Path "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md" -RefKind "milestone_authority" -SourceRef "artifact_map_ref" -SourceTask "R16-015" -AuthorityLevel "milestone_authority" -ProofStatus "authority_context" -ProofTreatment "R16 authority context only" -Order 6)
        )),
        (New-LoadGroup -GroupId "artifact_audit_and_check_maps" -Purpose "Load the artifact map, audit map, and check report that constrain exact evidence refs." -Order 3 -LoadItems @(
            (New-LoadItem -ItemId "artifact_map_state" -Path "state/artifacts/r16_artifact_map.json" -RefKind "artifact_map_state_artifact" -SourceRef "artifact_map_ref" -SourceTask "R16-010" -AuthorityLevel "validator_backed_state_artifact" -ProofStatus "generated_state_artifact_only" -ProofTreatment "artifact map context only; not runtime memory" -Order 1),
            (New-LoadItem -ItemId "audit_map_state" -Path "state/audit/r16_r15_r16_audit_map.json" -RefKind "audit_map_state_artifact" -SourceRef "audit_map_ref" -SourceTask "R16-012" -AuthorityLevel "validator_backed_state_artifact" -ProofStatus "generated_audit_map_state_artifact_only" -ProofTreatment "audit map context only; not runtime memory" -Order 2),
            (New-LoadItem -ItemId "artifact_audit_map_check_report" -Path "state/artifacts/r16_artifact_audit_map_check_report.json" -RefKind "check_report_state_artifact" -SourceRef "check_report_ref" -SourceTask "R16-013" -AuthorityLevel "validator_backed_state_artifact" -ProofStatus "validation_check_report_only" -ProofTreatment "check report context only; not machine proof by itself" -Order 3)
        )),
        (New-LoadGroup -GroupId "context_contract_and_prior_proof" -Purpose "Load the R16-014 context-load plan contract and proof-review package as exact predecessor context." -Order 4 -LoadItems @(
            (New-LoadItem -ItemId "context_load_plan_contract" -Path "contracts/context/r16_context_load_plan.contract.json" -RefKind "contract" -SourceRef "artifact_map_ref" -SourceTask "R16-014" -AuthorityLevel "contract_authority" -ProofStatus "contract_only" -ProofTreatment "contract/model proof only" -Order 1),
            (New-LoadItem -ItemId "r16_014_proof_review" -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_014_context_load_plan_contract/proof_review.json" -RefKind "proof_review" -SourceRef "audit_map_ref" -SourceTask "R16-014" -AuthorityLevel "proof_review_context" -ProofStatus "proof_review_package" -ProofTreatment "proof-review context only" -Order 2),
            (New-LoadItem -ItemId "r16_014_evidence_index" -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_014_context_load_plan_contract/evidence_index.json" -RefKind "evidence_index" -SourceRef "audit_map_ref" -SourceTask "R16-014" -AuthorityLevel "proof_review_context" -ProofStatus "evidence_index" -ProofTreatment "evidence-index context only" -Order 3),
            (New-LoadItem -ItemId "r16_014_validation_manifest" -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_014_context_load_plan_contract/validation_manifest.md" -RefKind "validation_manifest" -SourceRef "audit_map_ref" -SourceTask "R16-014" -AuthorityLevel "proof_review_context" -ProofStatus "validation_manifest" -ProofTreatment "validation manifest context only" -Order 4)
        )),
        (New-LoadGroup -GroupId "preserved_caveat_context" -Purpose "Load exact caveat and planning-report refs required to preserve R13/R14/R15 boundaries." -Order 5 -LoadItems @(
            (New-LoadItem -ItemId "r15_final_proof_review_package" -Path "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json" -RefKind "accepted_caveat_ref" -SourceRef "check_report_ref" -SourceTask "R15-009" -AuthorityLevel "historical_proof_review_context" -ProofStatus "accepted_with_caveat" -ProofTreatment "historical caveat context only" -Order 1),
            (New-LoadItem -ItemId "r15_final_evidence_index" -Path "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json" -RefKind "accepted_caveat_ref" -SourceRef "check_report_ref" -SourceTask "R15-009" -AuthorityLevel "historical_proof_review_context" -ProofStatus "accepted_with_caveat" -ProofTreatment "historical caveat context only" -Order 2),
            (New-LoadItem -ItemId "r15_external_audit_r16_planning_report" -Path "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md" -RefKind "operator_planning_report" -SourceRef "artifact_map_ref" -SourceTask "R16-002" -AuthorityLevel "operator_context" -ProofStatus "planning_context_only" -ProofTreatment "operator report context only; not machine proof" -Order 3)
        ))
    )

    $acceptedCaveats = @($inputs.CheckReport.accepted_caveats)
    $warningCount = $acceptedCaveats.Count
    $aggregateVerdict = if ($warningCount -gt 0) { "passed_with_caveats" } else { "passed" }

    return [ordered]@{
        artifact_type = "r16_context_load_plan"
        plan_version = "v1"
        plan_id = $script:PlanId
        source_milestone = $script:R16Milestone
        source_task = "R16-015"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
        }
        requesting_role = "evidence_auditor"
        target_task = "R16 continuation and audit-readiness inspection"
        target_workflow_phase = "artifact-map-and-context-load-foundation"
        role_memory_pack_ref = (New-SourceRef -RefId "r16_007_evidence_auditor_role_memory_pack" -Path $RoleMemoryPacksPath -SourceTask "R16-007" -RoleId "evidence_auditor" -Order 1)
        artifact_map_ref = (New-SourceRef -RefId "r16_010_artifact_map" -Path $ArtifactMapPath -SourceTask "R16-010" -Order 2)
        audit_map_ref = (New-SourceRef -RefId "r16_012_r15_r16_audit_map" -Path $AuditMapPath -SourceTask "R16-012" -Order 3)
        check_report_ref = (New-SourceRef -RefId "r16_013_artifact_audit_map_check_report" -Path $CheckReportPath -SourceTask "R16-013" -Order 4)
        load_policy = [ordered]@{
            policy_id = "exact-path-only"
            repo_relative_exact_paths_only = $true
            load_items_require_paths = $true
            directory_only_refs_allowed = $false
            wildcard_paths_allowed = $false
            broad_repo_scan_allowed = $false
            full_repo_scan_allowed = $false
            local_scratch_refs_allowed = $false
            unverified_remote_refs_allowed = $false
            report_as_machine_proof_allowed = $false
            runtime_memory_loading_allowed = $false
            retrieval_runtime_allowed = $false
            vector_search_runtime_allowed = $false
        }
        generation_mode = [ordered]@{
            context_load_planner_implemented = $true
            generated_context_load_plan_state_artifact = $true
            context_budget_estimator_implemented = $false
            over_budget_fail_closed_validator_implemented = $false
            runtime_memory_implemented = $false
            runtime_memory_loading_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            productized_ui_implemented = $false
            actual_autonomous_agents_implemented = $false
            true_multi_agent_execution_implemented = $false
            external_integrations_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            r16_016_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            r13_closure_claimed = $false
            r14_caveat_removal_claimed = $false
            r15_caveat_removal_claimed = $false
            r13_partial_gate_conversion_claimed = $false
            main_merge_completed = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        load_groups = @($loadGroups)
        load_order = @($loadGroups | ForEach-Object { [string]$_.group_id })
        context_budget = [ordered]@{
            context_budget_estimator_implemented = $false
            exact_provider_token_count_claimed = $false
            exact_provider_billing_claimed = $false
            budget_category = "not_estimated_until_R16_016"
        }
        current_posture = [ordered]@{
            active_through_task = "R16-015"
            complete_tasks = $script:CompleteTasks
            planned_tasks = $script:PlannedTasks
            r16_016_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
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
                caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
            }
        }
        accepted_caveats = @($acceptedCaveats)
        proof_treatment_policy = [ordered]@{
            generated_context_load_plan_as_machine_proof_allowed = $false
            generated_reports_as_machine_proof_allowed = $false
            operator_reports_as_machine_proof_allowed = $false
            planning_artifacts_as_implementation_proof_allowed = $false
            runtime_product_claims_allowed_without_later_evidence = $false
        }
        validation_findings = @(
            [ordered]@{
                finding_id = "source_refs_loaded_and_validated"
                severity = "pass"
                message = "Role memory pack, artifact map, audit map, and check report refs were loaded and validated by exact path."
                deterministic_order = 1
            },
            [ordered]@{
                finding_id = "accepted_r15_stale_generated_from_caveats_preserved"
                severity = if ($warningCount -gt 0) { "warning" } else { "pass" }
                message = "Accepted R15 stale generated_from caveats are preserved as caveats, not removed."
                deterministic_order = 2
            }
        )
        finding_summary = [ordered]@{
            pass_count = 1
            warning_count = $warningCount
            fail_count = 0
        }
        aggregate_verdict = $aggregateVerdict
        validation_commands = @(
            [ordered]@{
                command_id = "new_r16_context_load_plan"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_context_load_plan.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_load_plan.json"
                required_for_closeout = $true
                deterministic_order = 1
            },
            [ordered]@{
                command_id = "validate_r16_context_load_plan"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_load_plan.json"
                required_for_closeout = $true
                deterministic_order = 2
            },
            [ordered]@{
                command_id = "test_r16_context_load_planner"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_r16_context_load_planner.ps1"
                required_for_closeout = $true
                deterministic_order = 3
            }
        )
        non_claims = $script:RequiredNonClaims
        generated_artifact_statement = "state/context/r16_context_load_plan.json is a committed generated context-load plan state artifact only; it is not runtime memory, not runtime memory loading, not retrieval runtime, not vector search runtime, not product runtime, not a context budget estimator, not an over-budget fail-closed validator, not a role-run envelope, not a RACI transition gate, not a handoff packet, and not workflow execution."
    }
}

function Assert-SourceRef {
    param(
        [Parameter(Mandatory = $true)]$Ref,
        [Parameter(Mandatory = $true)][string]$ExpectedPath,
        [Parameter(Mandatory = $true)][string]$ExpectedSourceTask,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ExpectedRoleId = ""
    )

    $refObject = Assert-ObjectValue -Value $Ref -Context $Context
    foreach ($field in $script:RequiredRefFields) {
        Get-RequiredProperty -Object $refObject -Name $field -Context $Context | Out-Null
    }
    if ($refObject.path -ne $ExpectedPath) {
        throw "$Context path must be $ExpectedPath."
    }
    if ($refObject.source_task -ne $ExpectedSourceTask) {
        throw "$Context source_task must be $ExpectedSourceTask."
    }
    if ((Assert-BooleanValue -Value $refObject.loaded_and_validated -Context "$Context loaded_and_validated") -ne $true) {
        throw "$Context must be loaded and validated."
    }
    if ((Assert-BooleanValue -Value $refObject.exact_path_only -Context "$Context exact_path_only") -ne $true) {
        throw "$Context exact_path_only must be True."
    }
    foreach ($falseField in @("broad_scan_allowed", "wildcard_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $refObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
    if ((Assert-IntegerValue -Value $refObject.deterministic_order -Context "$Context deterministic_order") -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedRoleId)) {
        if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refObject -Name "role_id" -Context $Context) -Context "$Context role_id") -ne $ExpectedRoleId) {
            throw "$Context role_id must be $ExpectedRoleId."
        }
    }
    Assert-SafeRepoRelativePath -Path ([string]$refObject.path) -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
}

function Assert-LoadPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    if ($policyObject.policy_id -ne "exact-path-only") {
        throw "$Context policy_id must be exact-path-only."
    }
    foreach ($trueField in @("repo_relative_exact_paths_only", "load_items_require_paths")) {
        Assert-TrueField -Object $policyObject -Field $trueField -Context $Context
    }
    foreach ($falseField in @(
        "directory_only_refs_allowed",
        "wildcard_paths_allowed",
        "broad_repo_scan_allowed",
        "full_repo_scan_allowed",
        "local_scratch_refs_allowed",
        "unverified_remote_refs_allowed",
        "report_as_machine_proof_allowed",
        "runtime_memory_loading_allowed",
        "retrieval_runtime_allowed",
        "vector_search_runtime_allowed"
    )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-LoadItem {
    param(
        [Parameter(Mandatory = $true)]$Item,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $itemObject = Assert-ObjectValue -Value $Item -Context $Context
    foreach ($field in $script:RequiredLoadItemFields) {
        Get-RequiredProperty -Object $itemObject -Name $field -Context $Context | Out-Null
    }

    Assert-NonEmptyString -Value $itemObject.item_id -Context "$Context item_id" | Out-Null
    $path = Assert-NonEmptyString -Value $itemObject.path -Context "$Context path"
    Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context $Context -RequireLeaf | Out-Null
    Assert-NonEmptyString -Value $itemObject.source_ref -Context "$Context source_ref" | Out-Null
    if ([string]$itemObject.source_ref -notin @("role_memory_pack_ref", "artifact_map_ref", "audit_map_ref", "check_report_ref")) {
        throw "$Context source_ref must resolve to role_memory_pack_ref, artifact_map_ref, audit_map_ref, or check_report_ref."
    }
    if ((Assert-BooleanValue -Value $itemObject.load_required -Context "$Context load_required") -ne $true) {
        throw "$Context load_required must be True."
    }
    foreach ($trueField in @("exact_path_only", "remote_verified")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $itemObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("machine_proof", "implementation_proof", "broad_scan_allowed", "wildcard_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $itemObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
    if (Test-HasProperty -Object $itemObject -Name "remote_ref") {
        $remoteRef = [string](Get-RequiredProperty -Object $itemObject -Name "remote_ref" -Context $Context)
        if (-not [string]::IsNullOrWhiteSpace($remoteRef)) {
            throw "$Context rejects unverified remote ref '$remoteRef'."
        }
    }
    if ((Assert-IntegerValue -Value $itemObject.deterministic_order -Context "$Context deterministic_order") -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
}

function Assert-LoadGroups {
    param(
        [Parameter(Mandatory = $true)]$Groups,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $groupItems = Assert-ObjectArray -Value $Groups -Context $Context
    $expectedGroupIds = @(
        "role_scope_and_memory_policy",
        "status_and_milestone_authority",
        "artifact_audit_and_check_maps",
        "context_contract_and_prior_proof",
        "preserved_caveat_context"
    )
    $actualGroupIds = @($groupItems | ForEach-Object { [string]$_.group_id })
    Assert-ExactStringSet -Actual $actualGroupIds -Expected $expectedGroupIds -Context "$Context group_id"

    for ($groupIndex = 0; $groupIndex -lt $groupItems.Count; $groupIndex += 1) {
        $group = Assert-ObjectValue -Value $groupItems[$groupIndex] -Context "$Context[$groupIndex]"
        foreach ($field in @("group_id", "purpose", "load_items", "required_refs", "optional_refs", "forbidden_refs", "deterministic_order")) {
            Get-RequiredProperty -Object $group -Name $field -Context "$Context[$groupIndex]" | Out-Null
        }
        if ((Assert-IntegerValue -Value $group.deterministic_order -Context "$Context[$groupIndex] deterministic_order") -ne ($groupIndex + 1)) {
            throw "$Context[$groupIndex] deterministic_order must be $($groupIndex + 1)."
        }
        $loadItems = Assert-ObjectArray -Value $group.load_items -Context "$Context[$groupIndex] load_items"
        for ($itemIndex = 0; $itemIndex -lt $loadItems.Count; $itemIndex += 1) {
            Assert-LoadItem -Item $loadItems[$itemIndex] -ExpectedOrder ($itemIndex + 1) -Context "$Context[$groupIndex] load_items[$itemIndex]" -RepositoryRoot $RepositoryRoot
        }
    }
}

function Assert-ContextBudget {
    param(
        [Parameter(Mandatory = $true)]$Budget,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $budgetObject = Assert-ObjectValue -Value $Budget -Context $Context
    foreach ($field in @("context_budget_estimator_implemented", "exact_provider_token_count_claimed", "exact_provider_billing_claimed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $budgetObject -Name $field -Context $Context) -Context "$Context $field") -ne $false) {
            throw "$Context $field must be False."
        }
    }
    if ($budgetObject.budget_category -ne "not_estimated_until_R16_016") {
        throw "$Context budget_category must be not_estimated_until_R16_016."
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-015") {
        throw "$Context active_through_task must be R16-015."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks") -Expected $script:CompleteTasks -Context "$Context complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks") -Expected $script:PlannedTasks -Context "$Context planned_tasks"
    Assert-FalseFields -Object $postureObject -Fields @("r16_016_or_later_implementation_claimed", "r16_027_or_later_task_exists") -Context $Context
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
    Assert-FalseFields -Object $r13 -Fields @("closed", "partial_gates_converted_to_passed") -Context "$Context r13"
    if ($r14.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    Assert-FalseFields -Object $r14 -Fields @("caveats_removed") -Context "$Context r14"
    if ($r15.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
    Assert-FalseFields -Object $r15 -Fields @("caveats_removed") -Context "$Context r15"
    Assert-TrueField -Object $r15 -Field "stale_generated_from_caveat_preserved" -Context "$Context r15"
}

function Assert-AcceptedCaveats {
    param(
        [Parameter(Mandatory = $true)]$Caveats,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $items = Assert-ObjectArray -Value $Caveats -Context $Context
    $ids = @($items | ForEach-Object { [string]$_.caveat_id })
    Assert-RequiredStringsPresent -Actual $ids -Required @("r15_final_proof_review_package_stale_generated_from", "r15_evidence_index_stale_generated_from") -Context $Context
    for ($index = 0; $index -lt $items.Count; $index += 1) {
        $item = Assert-ObjectValue -Value $items[$index] -Context "$Context[$index]"
        $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "path" -Context "$Context[$index]") -Context "$Context[$index] path"
        Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context[$index]" -RequireLeaf | Out-Null
    }
}

function Assert-ProofTreatmentPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    Assert-FalseFields -Object $policyObject -Fields @(
        "generated_context_load_plan_as_machine_proof_allowed",
        "generated_reports_as_machine_proof_allowed",
        "operator_reports_as_machine_proof_allowed",
        "planning_artifacts_as_implementation_proof_allowed",
        "runtime_product_claims_allowed_without_later_evidence"
    ) -Context $Context
}

function Test-R16ContextLoadPlanObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Plan,
        [string]$SourceLabel = "R16 context-load plan",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Plan -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Plan.artifact_type -ne "r16_context_load_plan") {
        throw "$SourceLabel artifact_type must be r16_context_load_plan."
    }
    if ($Plan.plan_version -ne "v1" -or $Plan.plan_id -ne $script:PlanId -or $Plan.source_task -ne "R16-015") {
        throw "$SourceLabel plan id, version, or source task is incorrect."
    }
    if ($Plan.source_milestone -ne $script:R16Milestone -or $Plan.repository -ne $script:Repository -or $Plan.branch -ne $script:Branch) {
        throw "$SourceLabel milestone, repository, or branch metadata is incorrect."
    }
    $boundary = Assert-ObjectValue -Value $Plan.generation_boundary -Context "$SourceLabel generation_boundary"
    if ($boundary.input_head -ne $script:InputHead -or $boundary.input_tree -ne $script:InputTree) {
        throw "$SourceLabel generation_boundary must preserve the R16-015 input head and tree."
    }
    if ($Plan.requesting_role -ne "evidence_auditor") {
        throw "$SourceLabel requesting_role must be evidence_auditor."
    }
    if ($Plan.target_task -ne "R16 continuation and audit-readiness inspection") {
        throw "$SourceLabel target_task is incorrect."
    }
    if ($Plan.target_workflow_phase -ne "artifact-map-and-context-load-foundation") {
        throw "$SourceLabel target_workflow_phase is incorrect."
    }

    Assert-SourceRef -Ref $Plan.role_memory_pack_ref -ExpectedPath "state/memory/r16_role_memory_packs.json" -ExpectedSourceTask "R16-007" -ExpectedOrder 1 -ExpectedRoleId "evidence_auditor" -Context "$SourceLabel role_memory_pack_ref" -RepositoryRoot $resolvedRoot
    Assert-SourceRef -Ref $Plan.artifact_map_ref -ExpectedPath "state/artifacts/r16_artifact_map.json" -ExpectedSourceTask "R16-010" -ExpectedOrder 2 -Context "$SourceLabel artifact_map_ref" -RepositoryRoot $resolvedRoot
    Assert-SourceRef -Ref $Plan.audit_map_ref -ExpectedPath "state/audit/r16_r15_r16_audit_map.json" -ExpectedSourceTask "R16-012" -ExpectedOrder 3 -Context "$SourceLabel audit_map_ref" -RepositoryRoot $resolvedRoot
    Assert-SourceRef -Ref $Plan.check_report_ref -ExpectedPath "state/artifacts/r16_artifact_audit_map_check_report.json" -ExpectedSourceTask "R16-013" -ExpectedOrder 4 -Context "$SourceLabel check_report_ref" -RepositoryRoot $resolvedRoot

    Assert-LoadPolicy -Policy $Plan.load_policy -Context "$SourceLabel load_policy"
    $mode = Assert-ObjectValue -Value $Plan.generation_mode -Context "$SourceLabel generation_mode"
    Assert-TrueField -Object $mode -Field "context_load_planner_implemented" -Context "$SourceLabel generation_mode"
    Assert-TrueField -Object $mode -Field "generated_context_load_plan_state_artifact" -Context "$SourceLabel generation_mode"
    Assert-FalseFields -Object $mode -Fields $script:RequiredFalseGenerationModeFields -Context "$SourceLabel generation_mode"
    Assert-LoadGroups -Groups $Plan.load_groups -RepositoryRoot $resolvedRoot -Context "$SourceLabel load_groups"
    Assert-ContextBudget -Budget $Plan.context_budget -Context "$SourceLabel context_budget"
    Assert-CurrentPosture -Posture $Plan.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Plan.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    Assert-AcceptedCaveats -Caveats $Plan.accepted_caveats -Context "$SourceLabel accepted_caveats" -RepositoryRoot $resolvedRoot
    Assert-ProofTreatmentPolicy -Policy $Plan.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"

    $findings = Assert-ObjectArray -Value $Plan.validation_findings -Context "$SourceLabel validation_findings"
    for ($index = 0; $index -lt $findings.Count; $index += 1) {
        $finding = Assert-ObjectValue -Value $findings[$index] -Context "$SourceLabel validation_findings[$index]"
        if ((Assert-IntegerValue -Value (Get-RequiredProperty -Object $finding -Name "deterministic_order" -Context "$SourceLabel validation_findings[$index]") -Context "$SourceLabel validation_findings[$index] deterministic_order") -ne ($index + 1)) {
            throw "$SourceLabel validation_findings[$index] deterministic_order must be $($index + 1)."
        }
    }
    $summary = Assert-ObjectValue -Value $Plan.finding_summary -Context "$SourceLabel finding_summary"
    if ((Assert-IntegerValue -Value (Get-RequiredProperty -Object $summary -Name "fail_count" -Context "$SourceLabel finding_summary") -Context "$SourceLabel finding_summary fail_count") -ne 0) {
        throw "$SourceLabel finding_summary fail_count must be 0."
    }
    if ($Plan.aggregate_verdict -notin @("passed", "passed_with_caveats")) {
        throw "$SourceLabel aggregate_verdict must be passed or passed_with_caveats."
    }
    if (@($Plan.accepted_caveats).Count -gt 0 -and $Plan.aggregate_verdict -ne "passed_with_caveats") {
        throw "$SourceLabel aggregate_verdict must be passed_with_caveats when accepted caveat warnings exist."
    }

    $commands = Assert-ObjectArray -Value $Plan.validation_commands -Context "$SourceLabel validation_commands"
    for ($index = 0; $index -lt $commands.Count; $index += 1) {
        $command = Assert-ObjectValue -Value $commands[$index] -Context "$SourceLabel validation_commands[$index]"
        if ((Assert-IntegerValue -Value (Get-RequiredProperty -Object $command -Name "deterministic_order" -Context "$SourceLabel validation_commands[$index]") -Context "$SourceLabel validation_commands[$index] deterministic_order") -ne ($index + 1)) {
            throw "$SourceLabel validation_commands[$index] deterministic_order must be $($index + 1)."
        }
    }

    $nonClaims = Assert-StringArray -Value $Plan.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    $statement = Assert-NonEmptyString -Value $Plan.generated_artifact_statement -Context "$SourceLabel generated_artifact_statement"
    foreach ($fragment in @("committed generated context-load plan state artifact only", "not runtime memory", "not retrieval runtime", "not vector search runtime", "not product runtime", "not a context budget estimator", "not an over-budget fail-closed validator", "not a role-run envelope", "not a RACI transition gate", "not a handoff packet", "workflow execution")) {
        if ($statement -notmatch [regex]::Escape($fragment)) {
            throw "$SourceLabel generated_artifact_statement must include '$fragment'."
        }
    }

    return [pscustomobject]@{
        PlanId = $Plan.plan_id
        SourceTask = $Plan.source_task
        ActiveThroughTask = $Plan.current_posture.active_through_task
        PlannedTaskStart = $Plan.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Plan.current_posture.planned_tasks[-1]
        LoadGroupCount = @($Plan.load_groups).Count
        LoadItemCount = @($Plan.load_groups | ForEach-Object { @($_.load_items).Count } | Measure-Object -Sum).Sum
        AggregateVerdict = $Plan.aggregate_verdict
        ContextBudgetEstimatorImplemented = [bool]$Plan.context_budget.context_budget_estimator_implemented
        OverBudgetFailClosedValidatorImplemented = [bool]$Plan.generation_mode.over_budget_fail_closed_validator_implemented
        RoleRunEnvelopeImplemented = [bool]$Plan.generation_mode.role_run_envelope_implemented
        WorkflowDrillRun = [bool]$Plan.generation_mode.workflow_drill_run
    }
}

function Test-R16ContextLoadPlan {
    [CmdletBinding()]
    param(
        [string]$Path = "state/context/r16_context_load_plan.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRoot -Context "R16 context-load plan path" -RequireLeaf
    $plan = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context-load plan"
    return Test-R16ContextLoadPlanObject -Plan $plan -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16ContextLoadPlan {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/context/r16_context_load_plan.json",
        [string]$RoleMemoryPacksPath = "state/memory/r16_role_memory_packs.json",
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json",
        [string]$AuditMapPath = "state/audit/r16_r15_r16_audit_map.json",
        [string]$CheckReportPath = "state/artifacts/r16_artifact_audit_map_check_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutput = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRoot -Context "OutputPath"
    $plan = New-R16ContextLoadPlanObject -RoleMemoryPacksPath $RoleMemoryPacksPath -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -CheckReportPath $CheckReportPath -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $plan -Path $resolvedOutput
    $validation = Test-R16ContextLoadPlan -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        PlanId = $validation.PlanId
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        LoadGroupCount = $validation.LoadGroupCount
        LoadItemCount = $validation.LoadItemCount
        AggregateVerdict = $validation.AggregateVerdict
    }
}

function New-R16ContextLoadPlannerFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_context_load_planner",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $valid = New-R16ContextLoadPlanObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $valid -Path (Join-Path $resolvedFixtureRoot "valid_context_load_plan.json")

    $fixtureSpecs = [ordered]@{
        "invalid_missing_role_memory_pack_ref.json" = {
            param($p)
            $p.role_memory_pack_ref.loaded_and_validated = $false
        }
        "invalid_missing_artifact_map_ref.json" = {
            param($p)
            $p.artifact_map_ref.loaded_and_validated = $false
        }
        "invalid_missing_audit_map_ref.json" = {
            param($p)
            $p.audit_map_ref.loaded_and_validated = $false
        }
        "invalid_missing_check_report_ref.json" = {
            param($p)
            $p.check_report_ref.loaded_and_validated = $false
        }
        "invalid_missing_load_item_path.json" = {
            param($p)
            $p.load_groups[0].load_items[0].PSObject.Properties.Remove("path")
        }
        "invalid_wildcard_path.json" = {
            param($p)
            $p.load_groups[0].load_items[0].path = "state/memory/*.json"
        }
        "invalid_broad_scan_claim.json" = {
            param($p)
            $p.load_policy.broad_repo_scan_allowed = $true
        }
        "invalid_directory_only_ref.json" = {
            param($p)
            $p.load_groups[0].load_items[0].path = "state/memory/"
        }
        "invalid_local_scratch_ref.json" = {
            param($p)
            $p.load_groups[0].load_items[0].path = "scratch/r16_context_load_plan.tmp.json"
        }
        "invalid_remote_unverified_ref.json" = {
            param($p)
            $p.load_groups[0].load_items[0].path = "https://example.invalid/context.json"
        }
        "invalid_report_as_machine_proof.json" = {
            param($p)
            $p.proof_treatment_policy.generated_reports_as_machine_proof_allowed = $true
        }
        "invalid_runtime_memory_claim.json" = {
            param($p)
            $p.generation_mode.runtime_memory_implemented = $true
        }
        "invalid_retrieval_runtime_claim.json" = {
            param($p)
            $p.generation_mode.retrieval_runtime_implemented = $true
        }
        "invalid_vector_search_claim.json" = {
            param($p)
            $p.generation_mode.vector_search_runtime_implemented = $true
        }
        "invalid_context_budget_estimator_claim.json" = {
            param($p)
            $p.context_budget.context_budget_estimator_implemented = $true
        }
        "invalid_exact_token_count_claim.json" = {
            param($p)
            $p.context_budget.exact_provider_token_count_claimed = $true
        }
        "invalid_over_budget_validator_claim.json" = {
            param($p)
            $p.generation_mode.over_budget_fail_closed_validator_implemented = $true
        }
        "invalid_role_run_envelope_claim.json" = {
            param($p)
            $p.generation_mode.role_run_envelope_implemented = $true
        }
        "invalid_raci_transition_gate_claim.json" = {
            param($p)
            $p.generation_mode.raci_transition_gate_implemented = $true
        }
        "invalid_handoff_packet_claim.json" = {
            param($p)
            $p.generation_mode.handoff_packet_implemented = $true
        }
        "invalid_workflow_drill_claim.json" = {
            param($p)
            $p.generation_mode.workflow_drill_run = $true
        }
        "invalid_r16_016_claim.json" = {
            param($p)
            $p.current_posture.r16_016_or_later_implementation_claimed = $true
        }
        "invalid_r13_boundary_change.json" = {
            param($p)
            $p.preserved_boundaries.r13.closed = $true
        }
        "invalid_r14_caveat_removed.json" = {
            param($p)
            $p.preserved_boundaries.r14.caveats_removed = $true
        }
        "invalid_r15_caveat_removed.json" = {
            param($p)
            $p.preserved_boundaries.r15.caveats_removed = $true
        }
    }

    foreach ($name in $fixtureSpecs.Keys) {
        $fixture = Copy-JsonObject -Value $valid
        & $fixtureSpecs[$name] $fixture
        Write-StableJsonFile -Object $fixture -Path (Join-Path $resolvedFixtureRoot $name)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_context_load_plan.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16ContextLoadPlanObject, New-R16ContextLoadPlan, Test-R16ContextLoadPlanObject, Test-R16ContextLoadPlan, New-R16ContextLoadPlannerFixtureFiles, ConvertTo-StableJson
