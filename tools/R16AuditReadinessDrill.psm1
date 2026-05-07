Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:DrillVersion = "v1"
$script:DrillId = "aioffice-r16-024-audit-readiness-drill-v1"
$script:AggregateVerdict = "passed_bounded_audit_readiness_drill_without_broad_scan"
$script:GuardVerdict = "failed_closed_over_budget"
$script:ExpectedThreshold = 150000

$script:RequiredTopLevelFields = [string[]]@(
    "artifact_type",
    "drill_version",
    "drill_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "audit_scope",
    "exact_audit_inputs",
    "audit_map_ref",
    "artifact_map_ref",
    "artifact_audit_check_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "role_run_envelopes_ref",
    "raci_transition_gate_report_ref",
    "handoff_packet_report_ref",
    "restart_compaction_recovery_drill_ref",
    "role_handoff_drill_ref",
    "proof_review_refs",
    "audit_steps",
    "evidence_inspection_routes",
    "inspected_evidence_summary",
    "blocked_execution_summary",
    "no_full_repo_scan_policy",
    "raw_chat_history_policy",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "current_posture",
    "preserved_boundaries",
    "non_claims"
)

$script:RequiredRefPaths = [ordered]@{
    audit_map_ref = "state/audit/r16_r15_r16_audit_map.json"
    artifact_map_ref = "state/artifacts/r16_artifact_map.json"
    artifact_audit_check_ref = "state/artifacts/r16_artifact_audit_map_check_report.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    role_run_envelopes_ref = "state/workflow/r16_role_run_envelopes.json"
    raci_transition_gate_report_ref = "state/workflow/r16_raci_transition_gate_report.json"
    handoff_packet_report_ref = "state/workflow/r16_handoff_packet_report.json"
    restart_compaction_recovery_drill_ref = "state/workflow/r16_restart_compaction_recovery_drill.json"
    role_handoff_drill_ref = "state/workflow/r16_role_handoff_drill.json"
    governance_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredAuditInputPaths = [string[]]@($script:RequiredRefPaths.Values)

$script:RequiredProofReviewPaths = [string[]]@(
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_019_role_run_envelope_generator/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_020_raci_transition_gate/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_021_handoff_packet_generator/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_022_restart_compaction_recovery_drill/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_023_role_handoff_drill/proof_review.json"
)

$script:RequiredProofReviewRefIds = [string[]]@(
    "r16_019_role_run_envelope_generator",
    "r16_020_raci_transition_gate",
    "r16_021_handoff_packet_generator",
    "r16_022_restart_compaction_recovery_drill",
    "r16_023_role_handoff_drill"
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_restart_compaction_recovery_drill.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-024 is a bounded audit-readiness drill report only",
    "evidence inspection uses exact audit and artifact map refs plus committed state artifacts only",
    "raw chat history is not canonical evidence",
    "no broad repo scan",
    "no full repo scan",
    "no wildcard path expansion",
    "guard remains failed_closed_over_budget",
    "no mitigation",
    "no executable handoffs",
    "no executable transitions",
    "no executable envelopes",
    "no final R16 audit acceptance",
    "no closeout completion",
    "no final proof package completion",
    "no R16-025 friction metrics implementation",
    "no R16-026 final proof/review package implementation",
    "R16-025 through R16-026 remain planned only",
    "no runtime execution",
    "no runtime handoff execution",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R16-027 or later not claimed",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved",
    "no main merge"
)

$script:ForbiddenTrueBooleanClaims = @{
    broad_repo_scan_allowed = "broad repo scan claim"
    broad_repo_scan_performed = "broad repo scan claim"
    broad_repo_scan_claimed = "broad repo scan claim"
    full_repo_scan_allowed = "full repo scan claim"
    full_repo_scan_performed = "full repo scan claim"
    full_repo_scan_claimed = "full repo scan claim"
    full_repo_scan_used = "full repo scan claim"
    wildcard_paths_allowed = "wildcard path"
    wildcard_path_expansion_allowed = "wildcard path"
    wildcard_path_expansion_performed = "wildcard path"
    wildcard_paths_loaded = "wildcard path"
    directory_only_refs_allowed = "directory-only ref"
    directory_only_paths_allowed = "directory-only ref"
    directory_only_refs_loaded = "directory-only ref"
    scratch_temp_refs_allowed = "scratch/temp ref"
    scratch_temp_paths_allowed = "scratch/temp ref"
    scratch_temp_refs_loaded = "scratch/temp ref"
    absolute_paths_allowed = "absolute path"
    absolute_paths_loaded = "absolute path"
    parent_traversal_allowed = "parent traversal path"
    parent_traversal_refs_loaded = "parent traversal path"
    url_or_remote_refs_allowed = "URL or remote ref"
    url_or_remote_refs_loaded = "URL or remote ref"
    raw_chat_history_as_canonical_evidence = "raw chat history as canonical evidence"
    raw_chat_history_as_canonical_state = "raw chat history as canonical evidence"
    raw_chat_history_as_canonical_state_used = "raw chat history as canonical evidence"
    raw_chat_history_canonical_evidence_used = "raw chat history as canonical evidence"
    raw_chat_history_as_evidence_allowed = "raw chat history as canonical evidence"
    raw_chat_history_loading_allowed = "raw chat history as canonical evidence"
    raw_chat_history_loaded = "raw chat history as canonical evidence"
    generated_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    generated_report_treated_as_machine_proof = "report-as-machine-proof misuse"
    report_as_machine_proof_allowed = "report-as-machine-proof misuse"
    report_as_machine_proof_used = "report-as-machine-proof misuse"
    exact_provider_tokenization_claimed = "exact provider tokenization claim"
    exact_provider_token_count_claimed = "exact provider tokenization claim"
    provider_tokenizer_used = "exact provider tokenization claim"
    exact_provider_billing_claimed = "exact provider billing claim"
    provider_pricing_used = "exact provider billing claim"
    final_r16_audit_acceptance_claimed = "final R16 audit acceptance claim"
    final_audit_acceptance_claimed = "final R16 audit acceptance claim"
    r16_final_audit_accepted = "final R16 audit acceptance claim"
    closeout_completion_claimed = "closeout completion claim"
    closeout_completed = "closeout completion claim"
    final_proof_package_completion_claimed = "final proof package completion claim"
    final_proof_package_completed = "final proof package completion claim"
    executable_handoffs_exist = "executable handoff claim"
    executable_handoffs_claimed = "executable handoff claim"
    handoff_executable = "executable handoff claim"
    executable_transitions_exist = "executable transition claim"
    executable_transitions_claimed = "executable transition claim"
    transition_execution_permitted = "executable transition claim"
    executable_envelopes_exist = "executable envelope claim"
    executable_envelopes_claimed = "executable envelope claim"
    executable = "executable handoff claim"
    runtime_execution_claimed = "runtime execution claim"
    runtime_execution_performed = "runtime execution claim"
    runtime_execution_implemented = "runtime execution claim"
    runtime_handoff_execution_claimed = "runtime handoff execution claim"
    runtime_handoff_execution_performed = "runtime handoff execution claim"
    runtime_memory_claimed = "runtime memory claim"
    runtime_memory_implemented = "runtime memory claim"
    runtime_memory_loading_implemented = "runtime memory claim"
    retrieval_runtime_claimed = "retrieval runtime claim"
    retrieval_runtime_implemented = "retrieval runtime claim"
    vector_search_runtime_claimed = "vector search runtime claim"
    vector_search_runtime_implemented = "vector search runtime claim"
    product_runtime_claimed = "product runtime claim"
    product_runtime_implemented = "product runtime claim"
    autonomous_agent_claimed = "autonomous-agent claim"
    autonomous_agents_implemented = "autonomous-agent claim"
    actual_autonomous_agents_implemented = "autonomous-agent claim"
    external_integration_claimed = "external-integration claim"
    external_integrations_implemented = "external-integration claim"
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
    r16_025_implementation_claimed = "R16-025 implementation claim"
    r16_025_friction_metrics_implemented = "R16-025 implementation claim"
    r16_026_implementation_claimed = "R16-026 implementation claim"
    r16_026_final_proof_review_package_implemented = "R16-026 implementation claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r13_closed = "R13 closure or partial-gate conversion claim"
    closed = "R13 closure or partial-gate conversion claim"
    r13_closure_claimed = "R13 closure or partial-gate conversion claim"
    r13_partial_gate_conversion_claimed = "R13 closure or partial-gate conversion claim"
    partial_gates_converted_to_passed = "R13 closure or partial-gate conversion claim"
    r14_caveat_removal_claimed = "R14 caveat removal"
    r14_caveats_removed = "R14 caveat removal"
    r15_caveat_removal_claimed = "R15 caveat removal"
    r15_caveats_removed = "R15 caveat removal"
    caveats_removed = "caveat removal"
    main_merge_claimed = "main merge claim"
    main_merge_completed = "main merge claim"
}

function Test-HasProperty {
    param(
        [AllowNull()]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject.Contains($Name)
    }

    return $null -ne $InputObject -and $InputObject.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-HasProperty -InputObject $InputObject -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject[$Name]
    }

    return $InputObject.PSObject.Properties[$Name].Value
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return [string]$Value
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

    try {
        return [int64]$Value
    }
    catch {
        throw "$Context must be an integer."
    }
}

function Assert-ObjectValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [System.Array] -or $Value -isnot [pscustomobject]) {
        throw "$Context must be a JSON object."
    }

    return $Value
}

function Assert-StringArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string]) {
        throw "$Context must be an array of strings."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context $Context | Out-Null
    }

    return [string[]]$items
}

function Assert-ObjectArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string]) {
        throw "$Context must be an array of JSON objects."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    return [object[]]$items
}

function Assert-RequiredStringsPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $Required) {
        if ($Actual -notcontains $requiredValue) {
            throw "$Context is missing required value '$requiredValue'."
        }
    }
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue.Trim().Replace("\", "/")
}

function Get-RepositoryRoot {
    param([AllowNull()][string]$RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $RepositoryRoot = $repoRoot
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\", "repo", "repository", "full_repo", "entire_repo", "all", "all_files", "**", "**/*")
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue -match '[\*\?\[\]]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return $normalized -match '(^|/)(scratch|tmp|temp)(/|$)' -or $normalized -match '\.tmp($|\.)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalized -match '^[A-Za-z][A-Za-z0-9+\.-]*://' -or $normalized -match '^git@' -or $normalized -match '^(origin|upstream|refs)/' -or $normalized -match '^[^@\s]+@[^:\s]+:'
}

function Test-DirectoryOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    if ($normalized.EndsWith("/")) {
        return $true
    }
    if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)' -or (Test-RemoteOrUrlRef -PathValue $normalized)) {
        return $false
    }

    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return Test-Path -LiteralPath $candidatePath -PathType Container
}

function Test-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    & git -C $RepositoryRoot ls-files --error-unmatch -- $normalized 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Assert-SafeRepoRelativeTrackedPath {
    param(
        [AllowNull()][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $pathString = Assert-NonEmptyString -Value $PathValue -Context "$Context path"
    $normalized = ConvertTo-NormalizedRepoPath -PathValue $pathString

    if (Test-BroadRepoRootPath -PathValue $normalized) {
        throw "$Context path '$pathString' is a broad repo root ref."
    }
    if (Test-RemoteOrUrlRef -PathValue $normalized) {
        throw "$Context path '$pathString' is a URL or remote ref."
    }
    if ([System.IO.Path]::IsPathRooted($pathString) -or $pathString -match '^[A-Za-z]:[\\/]') {
        throw "$Context path '$pathString' is an absolute path."
    }
    if (Test-WildcardPath -PathValue $normalized) {
        throw "$Context path '$pathString' contains a wildcard path."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context path '$pathString' contains parent traversal path."
    }
    if (Test-ScratchTempPath -PathValue $normalized) {
        throw "$Context path '$pathString' is a scratch/temp path."
    }
    if (Test-DirectoryOnlyPath -PathValue $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context path '$pathString' is a directory-only ref."
    }

    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $normalized))
    $rootWithSeparator = $resolvedRoot + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedPath -ne $resolvedRoot -and -not $resolvedPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path '$pathString' escapes the repository root."
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$pathString' must resolve to an existing file."
    }
    if (-not (Test-GitTrackedPath -PathValue $normalized -RepositoryRoot $resolvedRoot)) {
        throw "$Context path '$pathString' must be an exact repo-relative tracked file."
    }

    return $normalized
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $json = ConvertTo-StableJson -Object $InputObject
    $directory = Split-Path -Parent $PathValue
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($PathValue, $json + "`n", [System.Text.UTF8Encoding]::new($false))
}

function Assert-NoForbiddenTrueClaims {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [System.Array]) {
        foreach ($item in $Value) {
            Assert-NoForbiddenTrueClaims -Value $item -Context $Context
        }
        return
    }

    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            $propertyName = [string]$property.Name
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($propertyName) -and $property.Value -is [bool] -and [bool]$property.Value) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$propertyName])."
            }

            Assert-NoForbiddenTrueClaims -Value $property.Value -Context "$Context $propertyName"
        }
    }
}

function Assert-PathValueOrValues {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -is [System.Array]) {
        foreach ($item in $Value) {
            Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$item) -RepositoryRoot $RepositoryRoot -Context $Context | Out-Null
        }
        return
    }

    Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$Value) -RepositoryRoot $RepositoryRoot -Context $Context | Out-Null
}

function Assert-AllPathFieldsAreSafe {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [System.Array]) {
        foreach ($item in $Value) {
            Assert-AllPathFieldsAreSafe -Value $item -RepositoryRoot $RepositoryRoot -Context $Context
        }
        return
    }

    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            $propertyName = [string]$property.Name
            if ($propertyName -eq "path" -or $propertyName -match '(^|_)path$' -or $propertyName -match '(^|_)paths$') {
                Assert-PathValueOrValues -Value $property.Value -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName"
            }

            Assert-AllPathFieldsAreSafe -Value $property.Value -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName"
        }
    }
}

function New-RefObject {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [Parameter(Mandatory = $true)][string]$InputRole,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        path = $Path
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        machine_proof = $false
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        input_role = $InputRole
        deterministic_order = $Order
    }
}

function Assert-RefObject {
    param(
        [Parameter(Mandatory = $true)]$RefObject,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ExpectedPath,
        [string]$ExpectedRefId
    )

    $ref = Assert-ObjectValue -Value $RefObject -Context $Context
    foreach ($fieldName in @("ref_id", "path", "source_task", "proof_treatment", "machine_proof", "exact_path_only", "broad_scan_allowed", "wildcard_allowed")) {
        Get-RequiredProperty -InputObject $ref -Name $fieldName -Context $Context | Out-Null
    }

    $normalizedPath = Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$ref.path) -RepositoryRoot $RepositoryRoot -Context $Context
    if (-not [string]::IsNullOrWhiteSpace($ExpectedPath) -and $normalizedPath -ne (ConvertTo-NormalizedRepoPath -PathValue $ExpectedPath)) {
        throw "$Context path must be '$ExpectedPath'."
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedRefId) -and [string]$ref.ref_id -ne $ExpectedRefId) {
        throw "$Context ref_id must be '$ExpectedRefId'."
    }
    if ((Assert-BooleanValue -Value $ref.machine_proof -Context "$Context machine_proof") -ne $false) {
        throw "$Context rejects report-as-machine-proof misuse."
    }
    if ((Assert-BooleanValue -Value $ref.exact_path_only -Context "$Context exact_path_only") -ne $true) {
        throw "$Context must require exact paths."
    }
    if ((Assert-BooleanValue -Value $ref.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context rejects broad repo scan claim."
    }
    if ((Assert-BooleanValue -Value $ref.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context rejects wildcard path."
    }

    return $ref
}

function New-AuditInputRefs {
    return [object[]]@(
        (New-RefObject -RefId "audit_map_ref" -Path $script:RequiredRefPaths.audit_map_ref -SourceTask "R16-012" -ProofTreatment "committed generated R15/R16 audit map state artifact; exact audit-readiness input" -InputRole "audit_map" -Order 1),
        (New-RefObject -RefId "artifact_map_ref" -Path $script:RequiredRefPaths.artifact_map_ref -SourceTask "R16-010" -ProofTreatment "committed generated artifact map state artifact; exact audit-readiness input" -InputRole "artifact_map" -Order 2),
        (New-RefObject -RefId "artifact_audit_check_ref" -Path $script:RequiredRefPaths.artifact_audit_check_ref -SourceTask "R16-013" -ProofTreatment "committed generated artifact/audit map check report; exact audit-readiness input" -InputRole "artifact_audit_check" -Order 3),
        (New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact; exact audit-readiness input" -InputRole "context_load_plan" -Order 4),
        (New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact; approximate only; exact audit-readiness input" -InputRole "context_budget_estimate" -Order 5),
        (New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report; failed-closed guard input" -InputRole "context_budget_guard" -Order 6),
        (New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact; all envelopes non-executable under failed-closed guard" -InputRole "role_run_envelopes" -Order 7),
        (New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "committed generated RACI transition gate report; all evaluated transitions blocked" -InputRole "raci_transition_gate_report" -Order 8),
        (New-RefObject -RefId "handoff_packet_report_ref" -Path $script:RequiredRefPaths.handoff_packet_report_ref -SourceTask "R16-021" -ProofTreatment "committed generated handoff packet report; all handoffs blocked/not executable" -InputRole "handoff_packet_report" -Order 9),
        (New-RefObject -RefId "restart_compaction_recovery_drill_ref" -Path $script:RequiredRefPaths.restart_compaction_recovery_drill_ref -SourceTask "R16-022" -ProofTreatment "committed generated restart/compaction recovery drill report; report-only recovery posture" -InputRole "restart_compaction_recovery_drill" -Order 10),
        (New-RefObject -RefId "role_handoff_drill_ref" -Path $script:RequiredRefPaths.role_handoff_drill_ref -SourceTask "R16-023" -ProofTreatment "committed generated role-handoff drill state artifact; three core handoffs blocked and zero executable transitions" -InputRole "role_handoff_drill" -Order 11),
        (New-RefObject -RefId "governance_ref" -Path $script:RequiredRefPaths.governance_ref -SourceTask "R16-023" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself; exact audit-readiness input" -InputRole "governance_card_state" -Order 12)
    )
}

function New-ProofReviewRefs {
    return [object[]]@(
        (New-RefObject -RefId "r16_019_role_run_envelope_generator" -Path $script:RequiredProofReviewPaths[0] -SourceTask "R16-019" -ProofTreatment "proof-review package pointer for role-run envelope generator; exact file ref only" -InputRole "proof_review" -Order 1),
        (New-RefObject -RefId "r16_020_raci_transition_gate" -Path $script:RequiredProofReviewPaths[1] -SourceTask "R16-020" -ProofTreatment "proof-review package pointer for RACI transition gate; exact file ref only" -InputRole "proof_review" -Order 2),
        (New-RefObject -RefId "r16_021_handoff_packet_generator" -Path $script:RequiredProofReviewPaths[2] -SourceTask "R16-021" -ProofTreatment "proof-review package pointer for handoff packet generator; exact file ref only" -InputRole "proof_review" -Order 3),
        (New-RefObject -RefId "r16_022_restart_compaction_recovery_drill" -Path $script:RequiredProofReviewPaths[3] -SourceTask "R16-022" -ProofTreatment "proof-review package pointer for restart/compaction recovery drill; exact file ref only" -InputRole "proof_review" -Order 4),
        (New-RefObject -RefId "r16_023_role_handoff_drill" -Path $script:RequiredProofReviewPaths[4] -SourceTask "R16-023" -ProofTreatment "proof-review package pointer for role-handoff drill; exact file ref only" -InputRole "proof_review" -Order 5)
    )
}

function New-ValidationCommands {
    $commands = @()
    for ($index = 0; $index -lt $script:RequiredValidationCommands.Count; $index += 1) {
        $commands += [pscustomobject][ordered]@{
            command = $script:RequiredValidationCommands[$index]
            deterministic_order = $index + 1
        }
    }

    return [object[]]$commands
}

function New-AuditSteps {
    return [object[]]@(
        [pscustomobject][ordered]@{
            step_id = "r16-024-audit-readiness-step-001"
            action = "Load exact audit-readiness input refs only."
            input_ref_ids = [string[]]@($script:RequiredRefPaths.Keys)
            result = "Exact repo-relative tracked audit inputs identified without raw chat history and without broad or full repo scan."
            deterministic_order = 1
        },
        [pscustomobject][ordered]@{
            step_id = "r16-024-audit-readiness-step-002"
            action = "Inspect R16 evidence through the audit map and artifact map route."
            input_ref_ids = [string[]]@("audit_map_ref", "artifact_map_ref", "artifact_audit_check_ref")
            result = "Audit map and artifact map refs provide bounded route anchors for the committed evidence artifacts."
            deterministic_order = 2
        },
        [pscustomobject][ordered]@{
            step_id = "r16-024-audit-readiness-step-003"
            action = "Inspect R16-019 through R16-023 workflow evidence through exact state artifact refs."
            input_ref_ids = [string[]]@("role_run_envelopes_ref", "raci_transition_gate_report_ref", "handoff_packet_report_ref", "restart_compaction_recovery_drill_ref", "role_handoff_drill_ref")
            result = "Role envelopes, transitions, handoffs, restart recovery, and role handoff evidence remain inspectable as exact repo-backed state artifacts."
            deterministic_order = 3
        },
        [pscustomobject][ordered]@{
            step_id = "r16-024-audit-readiness-step-004"
            action = "Preserve failed-closed execution posture and report-only audit boundary."
            input_ref_ids = [string[]]@("context_budget_guard_ref", "raci_transition_gate_report_ref", "handoff_packet_report_ref", "role_handoff_drill_ref")
            result = "Guard remains failed_closed_over_budget; handoffs and transitions remain blocked/not executable; no final audit acceptance or closeout is claimed."
            deterministic_order = 4
        }
    )
}

function New-InspectionRoute {
    param(
        [Parameter(Mandatory = $true)][string]$RouteId,
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$EvidenceKind,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [pscustomobject][ordered]@{
        route_id = $RouteId
        route_kind = "exact_file_read"
        evidence_ref_id = $RefId
        path = $Path
        source_task = $SourceTask
        reader_role = "external_auditor"
        evidence_kind = $EvidenceKind
        exact_command = "Get-Content -LiteralPath $($Path.Replace("/", "\"))"
        audit_map_route_used = $true
        artifact_map_route_used = $true
        broad_scan_allowed = $false
        full_repo_scan_allowed = $false
        wildcard_allowed = $false
        fallback_route = "none"
        deterministic_order = $Order
    }
}

function New-EvidenceInspectionRoutes {
    return [object[]]@(
        (New-InspectionRoute -RouteId "r16-024-route-001-audit-map" -RefId "audit_map_ref" -Path $script:RequiredRefPaths.audit_map_ref -SourceTask "R16-012" -EvidenceKind "audit_map" -Order 1),
        (New-InspectionRoute -RouteId "r16-024-route-002-artifact-map" -RefId "artifact_map_ref" -Path $script:RequiredRefPaths.artifact_map_ref -SourceTask "R16-010" -EvidenceKind "artifact_map" -Order 2),
        (New-InspectionRoute -RouteId "r16-024-route-003-role-run-envelopes" -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -EvidenceKind "role_run_envelopes" -Order 3),
        (New-InspectionRoute -RouteId "r16-024-route-004-raci-transition-gate" -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -EvidenceKind "raci_transition_gate" -Order 4),
        (New-InspectionRoute -RouteId "r16-024-route-005-handoff-packets" -RefId "handoff_packet_report_ref" -Path $script:RequiredRefPaths.handoff_packet_report_ref -SourceTask "R16-021" -EvidenceKind "handoff_packet_report" -Order 5),
        (New-InspectionRoute -RouteId "r16-024-route-006-restart-compaction-recovery-drill" -RefId "restart_compaction_recovery_drill_ref" -Path $script:RequiredRefPaths.restart_compaction_recovery_drill_ref -SourceTask "R16-022" -EvidenceKind "restart_compaction_recovery_drill" -Order 6),
        (New-InspectionRoute -RouteId "r16-024-route-007-role-handoff-drill" -RefId "role_handoff_drill_ref" -Path $script:RequiredRefPaths.role_handoff_drill_ref -SourceTask "R16-023" -EvidenceKind "role_handoff_drill" -Order 7)
    )
}

function Assert-NoFullRepoScanPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $policyObject -Name "required_input_paths" -Context $Context) -Context "$Context required_input_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredAuditInputPaths -Context "$Context required_input_paths"
    foreach ($path in $requiredPaths) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $path -RepositoryRoot $RepositoryRoot -Context "$Context required_input_paths" | Out-Null
    }
    foreach ($trueField in @("repo_relative_exact_paths_only", "tracked_files_only", "exact_audit_inputs_only", "exact_dependency_refs_only", "no_wildcard_path_expansion")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be true."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_path_expansion_performed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context rejects $falseField."
        }
    }
}

function Assert-RawChatHistoryPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    if ([string]$policyObject.canonical_evidence_source -ne "exact_repo_backed_artifacts_only") {
        throw "$Context canonical_evidence_source must be exact_repo_backed_artifacts_only."
    }
    foreach ($falseField in @("raw_chat_history_as_canonical_evidence", "raw_chat_history_as_canonical_state", "raw_chat_history_loaded", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context rejects raw chat history as canonical evidence."
        }
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string]$postureObject.active_through_task -ne "R16-024") {
        throw "$Context active_through_task must be R16-024."
    }
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    Assert-RequiredStringsPresent -Actual $plannedTasks -Required ([string[]]@("R16-025", "R16-026")) -Context "$Context planned_tasks"
    if ($plannedTasks.Count -ne 2) {
        throw "$Context planned_tasks must contain only R16-025 through R16-026."
    }
    if ([string]$postureObject.guard_verdict -ne $script:GuardVerdict) {
        throw "$Context guard verdict must be failed_closed_over_budget."
    }
    foreach ($falseField in @("final_r16_audit_acceptance_claimed", "closeout_completion_claimed", "final_proof_package_completion_claimed", "runtime_execution_claimed", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "solved_codex_compaction", "solved_codex_reliability", "r16_025_implementation_claimed", "r16_026_implementation_claimed", "r16_027_or_later_task_exists", "main_merge_claimed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context rejects $falseField."
        }
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    $r13 = Assert-ObjectValue -Value $boundaryObject.r13 -Context "$Context r13"
    $r14 = Assert-ObjectValue -Value $boundaryObject.r14 -Context "$Context r14"
    $r15 = Assert-ObjectValue -Value $boundaryObject.r15 -Context "$Context r15"
    if ((Assert-BooleanValue -Value $r13.closed -Context "$Context r13 closed") -ne $false -or (Assert-BooleanValue -Value $r13.partial_gates_converted_to_passed -Context "$Context r13 partial_gates_converted_to_passed") -ne $false) {
        throw "$Context rejects R13 closure or partial-gate conversion claim."
    }
    if ((Assert-BooleanValue -Value $r14.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context rejects R14 caveat removal."
    }
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context rejects R15 caveat removal."
    }
}

function New-R16AuditReadinessDrillObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($requiredPath in ($script:RequiredAuditInputPaths + $script:RequiredProofReviewPaths)) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $requiredPath -RepositoryRoot $resolvedRoot -Context "R16-024 exact audit-readiness inputs" | Out-Null
    }

    $auditMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.audit_map_ref) -Label "R16 audit map"
    $artifactMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_map_ref) -Label "R16 artifact map"
    $artifactCheck = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_audit_check_ref) -Label "R16 artifact/audit map check report"
    $loadPlan = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_load_plan_ref) -Label "R16 context-load plan"
    $estimate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_estimate_ref) -Label "R16 context budget estimate"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $handoffReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"
    $restartDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.restart_compaction_recovery_drill_ref) -Label "R16 restart/compaction recovery drill"
    $roleHandoffDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_handoff_drill_ref) -Label "R16 role-handoff drill"
    $governanceText = [System.IO.File]::ReadAllText((Join-Path $resolvedRoot $script:RequiredRefPaths.governance_ref))

    if ([string]$auditMap.artifact_type -ne "r16_r15_r16_audit_map" -or [string]$auditMap.source_task -ne "R16-012") {
        throw "R16-024 audit-readiness drill requires the R16-012 audit map."
    }
    if ([string]$artifactMap.artifact_type -ne "r16_artifact_map" -or [string]$artifactMap.source_task -ne "R16-010") {
        throw "R16-024 audit-readiness drill requires the R16-010 artifact map."
    }
    if ([string]$artifactCheck.artifact_type -ne "r16_artifact_audit_map_check_report" -or [int64]$artifactCheck.finding_summary.fail_count -ne 0) {
        throw "R16-024 audit-readiness drill requires the R16-013 artifact/audit map check report with no failures."
    }
    if ([string]$loadPlan.artifact_type -ne "r16_context_load_plan" -or [string]$estimate.artifact_type -ne "r16_context_budget_estimate") {
        throw "R16-024 audit-readiness drill requires R16 context-load and budget estimate artifacts."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "R16-024 audit-readiness drill requires guard failed_closed_over_budget with threshold $script:ExpectedThreshold."
    }
    if ([string]$roleRunEnvelopes.artifact_type -ne "r16_role_run_envelopes" -or @($roleRunEnvelopes.envelopes | Where-Object { [bool]$_.executable }).Count -ne 0) {
        throw "R16-024 audit-readiness drill requires non-executable R16-019 role-run envelopes."
    }
    if ([string]$raciGate.artifact_type -ne "r16_raci_transition_gate_report" -or [int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "R16-024 audit-readiness drill requires R16-020 transitions blocked/not executable."
    }
    if ([string]$handoffReport.artifact_type -ne "r16_handoff_packet_report" -or [int64]$handoffReport.blocked_handoff_count -ne 4 -or [int64]$handoffReport.executable_handoff_count -ne 0) {
        throw "R16-024 audit-readiness drill requires R16-021 handoffs blocked/not executable."
    }
    if ([string]$restartDrill.artifact_type -ne "r16_restart_compaction_recovery_drill" -or [string]$restartDrill.aggregate_verdict -ne "passed_bounded_restart_recovery_drill_with_blocked_execution") {
        throw "R16-024 audit-readiness drill requires the R16-022 restart/compaction recovery drill report."
    }
    if ([string]$roleHandoffDrill.artifact_type -ne "r16_role_handoff_drill" -or [int64]$roleHandoffDrill.blocked_handoff_count -ne 3 -or [int64]$roleHandoffDrill.executable_handoff_count -ne 0 -or [int64]$roleHandoffDrill.executable_transition_count -ne 0) {
        throw "R16-024 audit-readiness drill requires the R16-023 role-handoff drill with three blocked core handoffs and zero executable handoffs/transitions."
    }
    if ($governanceText -notmatch "R16-024" -or $governanceText -notmatch "R16-025") {
        throw "R16-024 audit-readiness drill requires the R16 governance card-state authority file."
    }

    $inputRefs = New-AuditInputRefs
    $proofReviewRefs = New-ProofReviewRefs
    $routes = New-EvidenceInspectionRoutes
    $upperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
    $envelopeCount = @($roleRunEnvelopes.envelopes).Count
    $executableEnvelopeCount = @($roleRunEnvelopes.envelopes | Where-Object { [bool]$_.executable }).Count

    return [pscustomobject][ordered]@{
        artifact_type = "r16_audit_readiness_drill"
        drill_version = $script:DrillVersion
        drill_id = $script:DrillId
        source_milestone = $script:R16Milestone
        source_task = "R16-024"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = "R16-024A implementation pass creates a bounded audit-readiness drill report from exact repo-backed audit map, artifact map, proof review, and committed state artifact refs only; it does not claim final R16 audit acceptance, closeout completion, final proof package completion, R16-025 or R16-026 implementation, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, solved Codex compaction, or solved Codex reliability."
        audit_scope = [pscustomobject][ordered]@{
            artifact_only_report = $true
            bounded_audit_readiness_drill_only = $true
            external_auditor_path_mode = "exact_audit_and_artifact_map_refs_only"
            exact_repo_backed_state_artifacts_are_canonical = $true
            raw_chat_history_canonical_evidence_used = $false
            generated_report_treated_as_machine_proof = $false
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            r16_025_friction_metrics_implemented = $false
            r16_026_final_proof_review_package_implemented = $false
            runtime_execution_claimed = $false
            runtime_handoff_execution_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            deterministic_order = 1
        }
        exact_audit_inputs = [object[]]$inputRefs
        audit_map_ref = $inputRefs[0]
        artifact_map_ref = $inputRefs[1]
        artifact_audit_check_ref = $inputRefs[2]
        context_load_plan_ref = $inputRefs[3]
        context_budget_estimate_ref = $inputRefs[4]
        context_budget_guard_ref = $inputRefs[5]
        role_run_envelopes_ref = $inputRefs[6]
        raci_transition_gate_report_ref = $inputRefs[7]
        handoff_packet_report_ref = $inputRefs[8]
        restart_compaction_recovery_drill_ref = $inputRefs[9]
        role_handoff_drill_ref = $inputRefs[10]
        governance_ref = $inputRefs[11]
        proof_review_refs = [object[]]$proofReviewRefs
        audit_evidence_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_audit_input_count = $script:RequiredAuditInputPaths.Count
            exact_proof_review_ref_count = $script:RequiredProofReviewPaths.Count
            required_input_paths = [string[]]$script:RequiredAuditInputPaths
            required_proof_review_paths = [string[]]$script:RequiredProofReviewPaths
            generated_reports_as_machine_proof_allowed = $false
            report_as_machine_proof_allowed = $false
            generated_report_treated_as_machine_proof = $false
            raw_chat_history_as_evidence_allowed = $false
            deterministic_order = 1
        }
        audit_steps = New-AuditSteps
        evidence_inspection_routes = [object[]]$routes
        inspected_evidence_summary = [pscustomobject][ordered]@{
            exact_audit_input_count = $script:RequiredAuditInputPaths.Count
            proof_review_ref_count = $proofReviewRefs.Count
            evidence_inspection_route_count = $routes.Count
            audit_map_used = $true
            artifact_map_used = $true
            artifact_audit_check_used = $true
            exact_repo_backed_state_artifacts_used = $true
            raw_chat_history_canonical_evidence_used = $false
            broad_repo_scan_used = $false
            full_repo_scan_used = $false
            r16_019_role_run_envelopes_inspectable = $true
            r16_020_raci_transition_gate_inspectable = $true
            r16_021_handoff_packet_report_inspectable = $true
            r16_022_restart_compaction_recovery_drill_inspectable = $true
            r16_023_role_handoff_drill_inspectable = $true
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            threshold = $threshold
            active_through_task_in_report_only = "R16-024"
            planned_tasks_remain = [string[]]@("R16-025", "R16-026")
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            deterministic_order = 1
        }
        blocked_execution_summary = [pscustomobject][ordered]@{
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            threshold = $threshold
            no_mitigation = $true
            role_run_envelope_count = $envelopeCount
            executable_envelope_count = $executableEnvelopeCount
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            source_handoff_packet_blocked_count = [int64]$handoffReport.blocked_handoff_count
            source_handoff_packet_executable_count = [int64]$handoffReport.executable_handoff_count
            role_handoff_core_blocked_count = [int64]$roleHandoffDrill.blocked_handoff_count
            executable_handoff_count = [int64]$roleHandoffDrill.executable_handoff_count
            executable_transition_count = [int64]$roleHandoffDrill.executable_transition_count
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            executable_envelopes_exist = $false
            runtime_execution_claimed = $false
            runtime_handoff_execution_claimed = $false
            deterministic_order = 1
        }
        no_full_repo_scan_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_audit_inputs_only = $true
            exact_dependency_refs_only = $true
            required_input_paths = [string[]]$script:RequiredAuditInputPaths
            no_wildcard_path_expansion = $true
            broad_repo_scan_allowed = $false
            broad_repo_scan_performed = $false
            full_repo_scan_allowed = $false
            full_repo_scan_performed = $false
            wildcard_paths_allowed = $false
            wildcard_path_expansion_performed = $false
            directory_only_refs_allowed = $false
            scratch_temp_refs_allowed = $false
            absolute_paths_allowed = $false
            parent_traversal_allowed = $false
            url_or_remote_refs_allowed = $false
            deterministic_order = 1
        }
        raw_chat_history_policy = [pscustomobject][ordered]@{
            canonical_evidence_source = "exact_repo_backed_artifacts_only"
            raw_chat_history_as_canonical_evidence = $false
            raw_chat_history_as_canonical_state = $false
            raw_chat_history_loaded = $false
            raw_chat_history_loading_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            raw_chat_history_may_be_human_context_but_not_authority = $true
            deterministic_order = 1
        }
        finding_summary = [pscustomobject][ordered]@{
            exact_audit_input_count = $script:RequiredAuditInputPaths.Count
            proof_review_ref_count = $proofReviewRefs.Count
            evidence_inspection_route_count = $routes.Count
            artifact_audit_check_fail_count = [int64]$artifactCheck.finding_summary.fail_count
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            threshold = $threshold
            executable_envelope_count = $executableEnvelopeCount
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            blocked_handoff_count = [int64]$roleHandoffDrill.blocked_handoff_count
            executable_handoff_count = [int64]$roleHandoffDrill.executable_handoff_count
            executable_transition_count = [int64]$roleHandoffDrill.executable_transition_count
            raw_chat_history_canonical_evidence_used = $false
            broad_repo_scan_used = $false
            full_repo_scan_used = $false
            report_as_machine_proof_used = $false
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            r16_025_implementation_claimed = $false
            r16_026_implementation_claimed = $false
            runtime_execution_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        aggregate_verdict = $script:AggregateVerdict
        validation_commands = New-ValidationCommands
        current_posture = [pscustomobject][ordered]@{
            active_through_task = "R16-024"
            active_through_scope = "R16-024 bounded audit-readiness drill report only"
            previous_accepted_task = "R16-023"
            r16_024_report_only = $true
            r16_025_through_r16_026_planned_only = $true
            planned_tasks = [string[]]@("R16-025", "R16-026")
            guard_verdict = $script:GuardVerdict
            no_mitigation = $true
            handoff_packets_blocked = $true
            transitions_blocked = $true
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            runtime_execution_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            r16_025_implementation_claimed = $false
            r16_026_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            main_merge_claimed = $false
        }
        preserved_boundaries = [pscustomobject][ordered]@{
            r13 = [pscustomobject][ordered]@{
                status = "failed_partial_through_r13_018_only"
                closed = $false
                r13_closed = $false
                partial_gates_converted_to_passed = $false
                caveat_preserved = $true
            }
            r14 = [pscustomobject][ordered]@{
                status = "accepted_with_caveats_through_r14_006_only"
                caveats_removed = $false
                r14_caveats_removed = $false
                caveat_preserved = $true
            }
            r15 = [pscustomobject][ordered]@{
                status = "accepted_with_caveats_through_r15_009_only"
                caveats_removed = $false
                r15_caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
            }
        }
        non_claims = [string[]]$script:RequiredNonClaims
    }
}

function Test-R16AuditReadinessDrillObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 audit-readiness drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-ObjectValue -Value $Report -Context $SourceLabel | Out-Null
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }
    if ([string]$Report.artifact_type -ne "r16_audit_readiness_drill" -or [string]$Report.source_task -ne "R16-024") {
        throw "$SourceLabel identity is incorrect."
    }
    if ([string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Report -RepositoryRoot $resolvedRoot -Context $SourceLabel

    $expectedRefIds = [string[]]@($script:RequiredRefPaths.Keys)
    Assert-RefObject -RefObject $Report.audit_map_ref -Context "$SourceLabel audit_map_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.audit_map_ref -ExpectedRefId "audit_map_ref" | Out-Null
    Assert-RefObject -RefObject $Report.artifact_map_ref -Context "$SourceLabel artifact_map_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.artifact_map_ref -ExpectedRefId "artifact_map_ref" | Out-Null
    Assert-RefObject -RefObject $Report.artifact_audit_check_ref -Context "$SourceLabel artifact_audit_check_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.artifact_audit_check_ref -ExpectedRefId "artifact_audit_check_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_run_envelopes_ref -Context "$SourceLabel role_run_envelopes_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "role_run_envelopes_ref" | Out-Null
    Assert-RefObject -RefObject $Report.raci_transition_gate_report_ref -Context "$SourceLabel raci_transition_gate_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "raci_transition_gate_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.handoff_packet_report_ref -Context "$SourceLabel handoff_packet_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.handoff_packet_report_ref -ExpectedRefId "handoff_packet_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.restart_compaction_recovery_drill_ref -Context "$SourceLabel restart_compaction_recovery_drill_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.restart_compaction_recovery_drill_ref -ExpectedRefId "restart_compaction_recovery_drill_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_handoff_drill_ref -Context "$SourceLabel role_handoff_drill_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_handoff_drill_ref -ExpectedRefId "role_handoff_drill_ref" | Out-Null

    $exactInputs = @(Assert-ObjectArray -Value $Report.exact_audit_inputs -Context "$SourceLabel exact_audit_inputs")
    if ($exactInputs.Count -ne $script:RequiredAuditInputPaths.Count) {
        throw "$SourceLabel exact_audit_inputs must include exactly $($script:RequiredAuditInputPaths.Count) refs."
    }
    for ($index = 0; $index -lt $exactInputs.Count; $index += 1) {
        Assert-RefObject -RefObject $exactInputs[$index] -Context "$SourceLabel exact_audit_inputs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredAuditInputPaths[$index] -ExpectedRefId $expectedRefIds[$index] | Out-Null
    }

    $proofRefs = @(Assert-ObjectArray -Value $Report.proof_review_refs -Context "$SourceLabel proof_review_refs")
    if ($proofRefs.Count -lt $script:RequiredProofReviewPaths.Count) {
        throw "$SourceLabel proof_review_refs must include at least $($script:RequiredProofReviewPaths.Count) refs."
    }
    for ($index = 0; $index -lt $script:RequiredProofReviewPaths.Count; $index += 1) {
        Assert-RefObject -RefObject $proofRefs[$index] -Context "$SourceLabel proof_review_refs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredProofReviewPaths[$index] -ExpectedRefId $script:RequiredProofReviewRefIds[$index] | Out-Null
    }

    $auditMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.audit_map_ref) -Label "R16 audit map"
    $artifactMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_map_ref) -Label "R16 artifact map"
    $artifactCheck = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_audit_check_ref) -Label "R16 artifact/audit map check report"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $handoffReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"
    $restartDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.restart_compaction_recovery_drill_ref) -Label "R16 restart/compaction recovery drill"
    $roleHandoffDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_handoff_drill_ref) -Label "R16 role-handoff drill"

    if ([string]$auditMap.artifact_type -ne "r16_r15_r16_audit_map" -or [string]$artifactMap.artifact_type -ne "r16_artifact_map" -or [string]$artifactCheck.artifact_type -ne "r16_artifact_audit_map_check_report") {
        throw "$SourceLabel requires audit map, artifact map, and artifact/audit check report inputs."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "$SourceLabel requires guard failed_closed_over_budget with threshold $script:ExpectedThreshold."
    }
    if (@($roleRunEnvelopes.envelopes | Where-Object { [bool]$_.executable }).Count -ne 0) {
        throw "$SourceLabel requires non-executable role-run envelopes."
    }
    if ([int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "$SourceLabel requires all R16-020 transitions blocked."
    }
    if ([int64]$handoffReport.executable_handoff_count -ne 0 -or [int64]$handoffReport.blocked_handoff_count -ne 4) {
        throw "$SourceLabel requires all R16-021 handoff packets blocked/not executable."
    }
    if ([string]$restartDrill.aggregate_verdict -ne "passed_bounded_restart_recovery_drill_with_blocked_execution") {
        throw "$SourceLabel requires the R16-022 recovery drill input."
    }
    if ([int64]$roleHandoffDrill.blocked_handoff_count -ne 3 -or [int64]$roleHandoffDrill.executable_handoff_count -ne 0 -or [int64]$roleHandoffDrill.executable_transition_count -ne 0) {
        throw "$SourceLabel requires the R16-023 role-handoff drill blocked posture."
    }

    Assert-NoFullRepoScanPolicy -Policy $Report.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy" -RepositoryRoot $resolvedRoot
    Assert-RawChatHistoryPolicy -Policy $Report.raw_chat_history_policy -Context "$SourceLabel raw_chat_history_policy"
    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $routes = @(Assert-ObjectArray -Value $Report.evidence_inspection_routes -Context "$SourceLabel evidence_inspection_routes")
    $routeTasks = [string[]]@($routes | ForEach-Object { [string]$_.source_task })
    Assert-RequiredStringsPresent -Actual $routeTasks -Required ([string[]]@("R16-019", "R16-020", "R16-021", "R16-022", "R16-023")) -Context "$SourceLabel evidence_inspection_routes source_task"
    foreach ($route in $routes) {
        if ([string]$route.route_kind -ne "exact_file_read") {
            throw "$SourceLabel evidence_inspection_routes must use exact_file_read routes."
        }
        foreach ($falseField in @("broad_scan_allowed", "full_repo_scan_allowed", "wildcard_allowed")) {
            if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $route -Name $falseField -Context "$SourceLabel evidence_inspection_routes") -Context "$SourceLabel evidence_inspection_routes $falseField") -ne $false) {
                throw "$SourceLabel evidence_inspection_routes rejects $falseField."
            }
        }
    }

    $evidencePolicy = Assert-ObjectValue -Value $Report.audit_evidence_policy -Context "$SourceLabel audit_evidence_policy"
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name "required_input_paths" -Context "$SourceLabel audit_evidence_policy") -Context "$SourceLabel audit_evidence_policy required_input_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredAuditInputPaths -Context "$SourceLabel audit_evidence_policy required_input_paths"
    $proofPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name "required_proof_review_paths" -Context "$SourceLabel audit_evidence_policy") -Context "$SourceLabel audit_evidence_policy required_proof_review_paths"
    Assert-RequiredStringsPresent -Actual $proofPaths -Required $script:RequiredProofReviewPaths -Context "$SourceLabel audit_evidence_policy required_proof_review_paths"
    if ((Assert-BooleanValue -Value $evidencePolicy.generated_reports_as_machine_proof_allowed -Context "$SourceLabel audit_evidence_policy generated_reports_as_machine_proof_allowed") -ne $false) {
        throw "$SourceLabel rejects report-as-machine-proof misuse."
    }

    $summary = Assert-ObjectValue -Value $Report.inspected_evidence_summary -Context "$SourceLabel inspected_evidence_summary"
    if ([int64]$summary.exact_audit_input_count -ne $script:RequiredAuditInputPaths.Count -or [int64]$summary.proof_review_ref_count -lt $script:RequiredProofReviewPaths.Count) {
        throw "$SourceLabel inspected_evidence_summary must record exact audit input and proof review ref counts."
    }
    if ((Assert-BooleanValue -Value $summary.audit_map_used -Context "$SourceLabel inspected_evidence_summary audit_map_used") -ne $true -or (Assert-BooleanValue -Value $summary.artifact_map_used -Context "$SourceLabel inspected_evidence_summary artifact_map_used") -ne $true) {
        throw "$SourceLabel inspected_evidence_summary must prove audit map and artifact map use."
    }
    if ([string]$summary.guard_verdict -ne $script:GuardVerdict -or [int64]$summary.estimated_tokens_upper_bound -ne [int64]$guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$summary.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel inspected_evidence_summary must preserve failed_closed_over_budget guard values."
    }

    $blocked = Assert-ObjectValue -Value $Report.blocked_execution_summary -Context "$SourceLabel blocked_execution_summary"
    if ([int64]$blocked.executable_handoff_count -ne 0 -or [int64]$blocked.executable_transition_count -ne 0 -or [int64]$blocked.executable_envelope_count -ne 0 -or [int64]$blocked.allowed_transition_count -ne 0) {
        throw "$SourceLabel blocked_execution_summary must preserve zero executable handoffs, transitions, envelopes, and allowed transitions."
    }

    $findingSummary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$findingSummary.exact_audit_input_count -ne $script:RequiredAuditInputPaths.Count -or [int64]$findingSummary.proof_review_ref_count -lt $script:RequiredProofReviewPaths.Count) {
        throw "$SourceLabel finding_summary must record exact audit input and proof review counts."
    }
    if ([int64]$findingSummary.executable_handoff_count -ne 0 -or [int64]$findingSummary.executable_transition_count -ne 0 -or [int64]$findingSummary.allowed_transition_count -ne 0) {
        throw "$SourceLabel finding_summary must preserve blocked workflow posture."
    }
    foreach ($falseField in @("raw_chat_history_canonical_evidence_used", "broad_repo_scan_used", "full_repo_scan_used", "report_as_machine_proof_used", "final_r16_audit_acceptance_claimed", "closeout_completion_claimed", "final_proof_package_completion_claimed", "r16_025_implementation_claimed", "r16_026_implementation_claimed", "runtime_execution_claimed", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "solved_codex_compaction", "solved_codex_reliability")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $findingSummary -Name $falseField -Context "$SourceLabel finding_summary") -Context "$SourceLabel finding_summary $falseField") -ne $false) {
            throw "$SourceLabel finding_summary contains forbidden $falseField claim."
        }
    }

    if ([string]$Report.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be $script:AggregateVerdict."
    }
    $commands = @(Assert-ObjectArray -Value $Report.validation_commands -Context "$SourceLabel validation_commands")
    $commandValues = [string[]]@($commands | ForEach-Object { [string]$_.command })
    Assert-RequiredStringsPresent -Actual $commandValues -Required $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"
    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        DrillId = [string]$Report.drill_id
        SourceTask = [string]$Report.source_task
        ActiveThroughTask = [string]$Report.current_posture.active_through_task
        PlannedTaskStart = [string]$Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = [string]$Report.current_posture.planned_tasks[-1]
        ExactAuditInputCount = $exactInputs.Count
        ProofReviewRefCount = $proofRefs.Count
        EvidenceInspectionRouteCount = $routes.Count
        AggregateVerdict = [string]$Report.aggregate_verdict
        GuardVerdict = [string]$guard.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
        Threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
        BlockedHandoffCount = [int64]$roleHandoffDrill.blocked_handoff_count
        ExecutableHandoffCount = [int64]$roleHandoffDrill.executable_handoff_count
        ExecutableTransitionCount = [int64]$roleHandoffDrill.executable_transition_count
    }
}

function Test-R16AuditReadinessDrill {
    [CmdletBinding()]
    param(
        [string]$Path = "state/audit/r16_audit_readiness_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 audit-readiness drill"
    return Test-R16AuditReadinessDrillObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16AuditReadinessDrill {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/audit/r16_audit_readiness_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16AuditReadinessDrillObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $report -PathValue $resolvedOutput
    $validation = Test-R16AuditReadinessDrill -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        DrillId = $validation.DrillId
        ExactAuditInputCount = $validation.ExactAuditInputCount
        ProofReviewRefCount = $validation.ProofReviewRefCount
        EvidenceInspectionRouteCount = $validation.EvidenceInspectionRouteCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        GuardVerdict = $validation.GuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        Threshold = $validation.Threshold
        BlockedHandoffCount = $validation.BlockedHandoffCount
        ExecutableHandoffCount = $validation.ExecutableHandoffCount
        ExecutableTransitionCount = $validation.ExecutableTransitionCount
    }
}

function Test-R16AuditReadinessDrillContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/audit/r16_audit_readiness_drill.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 audit-readiness drill contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "audit_readiness_drill_contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "audit_readiness_drill_policy", "no_full_repo_scan_policy", "raw_chat_history_policy", "blocked_execution_policy", "non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 audit-readiness drill contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_audit_readiness_drill_contract" -or [string]$contract.source_task -ne "R16-024") {
        throw "R16 audit-readiness drill contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 audit-readiness drill contract"
    Assert-AllPathFieldsAreSafe -Value $contract -RepositoryRoot $resolvedRoot -Context "R16 audit-readiness drill contract"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 audit-readiness drill contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 audit-readiness drill contract required_report_fields"
    $dependencyRefs = @(Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 audit-readiness drill contract dependency_refs")
    $expectedDependencyPaths = [string[]]($script:RequiredAuditInputPaths + $script:RequiredProofReviewPaths)
    if ($dependencyRefs.Count -ne $expectedDependencyPaths.Count) {
        throw "R16 audit-readiness drill contract dependency_refs must include exactly $($expectedDependencyPaths.Count) input and proof-review refs."
    }
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        Assert-RefObject -RefObject $dependencyRefs[$index] -Context "R16 audit-readiness drill contract dependency_refs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $expectedDependencyPaths[$index] | Out-Null
    }
    if ([string]$contract.audit_readiness_drill_policy.aggregate_verdict_required -ne $script:AggregateVerdict) {
        throw "R16 audit-readiness drill contract aggregate verdict policy is incorrect."
    }
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 audit-readiness drill contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 audit-readiness drill contract non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.audit_readiness_drill_contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16AuditReadinessDrillFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_audit_readiness_drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16AuditReadinessDrillObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validReport -PathValue (Join-Path $fixtureRootPath "valid_audit_readiness_drill.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_audit_readiness_drill.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.generation_boundary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generation_boundary'")
        "invalid_missing_audit_map_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_audit_map_ref" -MutationPath '$.audit_map_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'audit_map_ref'")
        "invalid_missing_artifact_map_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_artifact_map_ref" -MutationPath '$.artifact_map_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'artifact_map_ref'")
        "invalid_missing_artifact_audit_check_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_artifact_audit_check_ref" -MutationPath '$.artifact_audit_check_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'artifact_audit_check_ref'")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_role_run_envelopes_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_run_envelopes_ref" -MutationPath '$.role_run_envelopes_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_raci_transition_gate_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_raci_transition_gate_report_ref" -MutationPath '$.raci_transition_gate_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'raci_transition_gate_report_ref'")
        "invalid_missing_handoff_packet_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_handoff_packet_report_ref" -MutationPath '$.handoff_packet_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'handoff_packet_report_ref'")
        "invalid_missing_restart_compaction_recovery_drill_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_restart_compaction_recovery_drill_ref" -MutationPath '$.restart_compaction_recovery_drill_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'restart_compaction_recovery_drill_ref'")
        "invalid_missing_role_handoff_drill_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_handoff_drill_ref" -MutationPath '$.role_handoff_drill_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_handoff_drill_ref'")
        "invalid_missing_proof_review_refs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_proof_review_refs" -MutationPath '$.proof_review_refs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'proof_review_refs'")
        "invalid_missing_evidence_inspection_routes.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_evidence_inspection_routes" -MutationPath '$.evidence_inspection_routes' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'evidence_inspection_routes'")
        "invalid_raw_chat_history_as_canonical_evidence.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_as_canonical_evidence" -MutationPath '$.raw_chat_history_policy.raw_chat_history_as_canonical_evidence' -MutationValue $true -ExpectedFailure @("raw chat history as canonical evidence")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.audit_map_ref.path' -MutationValue "state/audit/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.audit_map_ref.path' -MutationValue "state/audit/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.audit_map_ref.path' -MutationValue "scratch/r16_audit_readiness_drill.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.audit_map_ref.path' -MutationValue "C:/tmp/r16_audit_readiness_drill.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.audit_map_ref.path' -MutationValue "../state/audit/r16_r15_r16_audit_map.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.audit_map_ref.path' -MutationValue "https://example.invalid/r16_r15_r16_audit_map.json" -ExpectedFailure @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.audit_evidence_policy.generated_report_treated_as_machine_proof' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.audit_scope.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.audit_scope.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_final_r16_audit_acceptance_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_final_r16_audit_acceptance_claim" -MutationPath '$.current_posture.final_r16_audit_acceptance_claimed' -MutationValue $true -ExpectedFailure @("final R16 audit acceptance claim")
        "invalid_closeout_completion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_closeout_completion_claim" -MutationPath '$.current_posture.closeout_completion_claimed' -MutationValue $true -ExpectedFailure @("closeout completion claim")
        "invalid_final_proof_package_completion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_final_proof_package_completion_claim" -MutationPath '$.current_posture.final_proof_package_completion_claimed' -MutationValue $true -ExpectedFailure @("final proof package completion claim")
        "invalid_executable_handoff_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_handoff_claim" -MutationPath '$.blocked_execution_summary.executable_handoffs_exist' -MutationValue $true -ExpectedFailure @("executable handoff claim")
        "invalid_executable_transition_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_transition_claim" -MutationPath '$.blocked_execution_summary.executable_transitions_exist' -MutationValue $true -ExpectedFailure @("executable transition claim")
        "invalid_runtime_execution_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_execution_claim" -MutationPath '$.audit_scope.runtime_execution_claimed' -MutationValue $true -ExpectedFailure @("runtime execution claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.audit_scope.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.audit_scope.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.audit_scope.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.audit_scope.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.audit_scope.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.audit_scope.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_compaction_claim" -MutationPath '$.audit_scope.solved_codex_compaction' -MutationValue $true -ExpectedFailure @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_reliability_claim" -MutationPath '$.audit_scope.solved_codex_reliability' -MutationValue $true -ExpectedFailure @("solved Codex reliability claim")
        "invalid_r16_025_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_025_implementation_claim" -MutationPath '$.current_posture.r16_025_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-025 implementation claim")
        "invalid_r16_026_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_026_implementation_claim" -MutationPath '$.current_posture.r16_026_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-026 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_027_or_later_task_claim" -MutationPath '$.current_posture.r16_027_or_later_task_exists' -MutationValue $true -ExpectedFailure @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_closure_or_partial_gate_conversion_claim" -MutationPath '$.preserved_boundaries.r13.closed' -MutationValue $true -ExpectedFailure @("R13 closure or partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r14_caveat_removal" -MutationPath '$.preserved_boundaries.r14.caveats_removed' -MutationValue $true -ExpectedFailure @("caveat removal")
        "invalid_r15_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r15_caveat_removal" -MutationPath '$.preserved_boundaries.r15.caveats_removed' -MutationValue $true -ExpectedFailure @("caveat removal")
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        Write-StableJsonFile -InputObject $fixtureSpecs[$fixtureName] -PathValue (Join-Path $fixtureRootPath $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_audit_readiness_drill.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16AuditReadinessDrillObject, New-R16AuditReadinessDrill, Test-R16AuditReadinessDrillObject, Test-R16AuditReadinessDrill, Test-R16AuditReadinessDrillContract, New-R16AuditReadinessDrillFixtureFiles, ConvertTo-StableJson
