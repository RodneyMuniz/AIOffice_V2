Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:ReportVersion = "v1"
$script:ReportId = "aioffice-r16-025-friction-metrics-report-v1"
$script:AggregateVerdict = "passed_bounded_friction_metrics_report_with_guard_failed_closed"
$script:GuardVerdict = "failed_closed_over_budget"
$script:ExpectedGuardUpperBound = 1356909
$script:ExpectedThreshold = 150000

$script:RequiredTopLevelFields = [string[]]@(
    "artifact_type",
    "report_version",
    "report_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "metric_scope",
    "exact_metric_inputs",
    "context_budget_history",
    "context_guard_posture",
    "loaded_file_metrics",
    "exact_ref_metrics",
    "manual_step_metrics",
    "restart_recovery_metrics",
    "compaction_failure_metrics",
    "deterministic_drift_metrics",
    "regeneration_cascade_metrics",
    "stale_ref_findings",
    "fixture_bloat_metrics",
    "validation_sweep_metrics",
    "local_wip_interruption_metrics",
    "process_friction_findings",
    "next_milestone_planning_implications",
    "no_full_repo_scan_policy",
    "raw_chat_history_policy",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "current_posture",
    "preserved_boundaries",
    "non_claims"
)

$script:RequiredMetricInputRefs = [ordered]@{
    context_load_plan_ref = @{
        Path = "state/context/r16_context_load_plan.json"
        SourceTask = "R16-015"
        MetricRole = "context_load_and_budget_surface"
        Treatment = "committed generated context-load plan state artifact only"
    }
    context_budget_estimate_ref = @{
        Path = "state/context/r16_context_budget_estimate.json"
        SourceTask = "R16-016"
        MetricRole = "context_budget_estimate_surface"
        Treatment = "committed generated approximate context budget estimate state artifact only"
    }
    context_budget_guard_ref = @{
        Path = "state/context/r16_context_budget_guard_report.json"
        SourceTask = "R16-017"
        MetricRole = "failed_closed_guard_surface"
        Treatment = "committed generated context budget guard report"
    }
    role_memory_packs_ref = @{
        Path = "state/memory/r16_role_memory_packs.json"
        SourceTask = "R16-007"
        MetricRole = "large_generated_role_memory_pack_surface"
        Treatment = "committed generated role memory pack state artifact only"
    }
    artifact_map_ref = @{
        Path = "state/artifacts/r16_artifact_map.json"
        SourceTask = "R16-010"
        MetricRole = "artifact_ref_surface"
        Treatment = "committed generated artifact map state artifact only"
    }
    audit_map_ref = @{
        Path = "state/audit/r16_r15_r16_audit_map.json"
        SourceTask = "R16-012"
        MetricRole = "audit_ref_surface"
        Treatment = "committed generated audit map state artifact only"
    }
    artifact_audit_check_ref = @{
        Path = "state/artifacts/r16_artifact_audit_map_check_report.json"
        SourceTask = "R16-013"
        MetricRole = "stale_ref_and_diff_check_surface"
        Treatment = "committed generated artifact/audit map check report"
    }
    role_run_envelopes_ref = @{
        Path = "state/workflow/r16_role_run_envelopes.json"
        SourceTask = "R16-019"
        MetricRole = "role_run_envelope_surface"
        Treatment = "committed generated non-executable role-run envelope state artifact only"
    }
    raci_transition_gate_report_ref = @{
        Path = "state/workflow/r16_raci_transition_gate_report.json"
        SourceTask = "R16-020"
        MetricRole = "transition_gate_surface"
        Treatment = "committed generated RACI transition gate report"
    }
    handoff_packet_report_ref = @{
        Path = "state/workflow/r16_handoff_packet_report.json"
        SourceTask = "R16-021"
        MetricRole = "handoff_packet_surface"
        Treatment = "committed generated handoff packet report"
    }
    restart_compaction_recovery_drill_ref = @{
        Path = "state/workflow/r16_restart_compaction_recovery_drill.json"
        SourceTask = "R16-022"
        MetricRole = "restart_recovery_surface"
        Treatment = "committed generated restart/compaction recovery drill report"
    }
    role_handoff_drill_ref = @{
        Path = "state/workflow/r16_role_handoff_drill.json"
        SourceTask = "R16-023"
        MetricRole = "role_handoff_surface"
        Treatment = "committed generated role-handoff drill report"
    }
    audit_readiness_drill_ref = @{
        Path = "state/audit/r16_audit_readiness_drill.json"
        SourceTask = "R16-024"
        MetricRole = "audit_readiness_surface"
        Treatment = "committed generated audit-readiness drill state artifact only"
    }
    governance_ref = @{
        Path = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
        SourceTask = "R16-024"
        MetricRole = "milestone_authority_surface"
        Treatment = "milestone authority and card-state boundary only"
    }
}

$script:RequiredProofReviewRefs = [ordered]@{
    r16_016_context_budget_estimator = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_016_context_budget_estimator/proof_review.json"
        SourceTask = "R16-016"
        Treatment = "proof-review package pointer for context budget estimator"
    }
    r16_017_context_budget_guard = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_017_context_budget_guard/proof_review.json"
        SourceTask = "R16-017"
        Treatment = "proof-review package pointer for context budget guard"
    }
    r16_019_role_run_envelope_generator = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_019_role_run_envelope_generator/proof_review.json"
        SourceTask = "R16-019"
        Treatment = "proof-review package pointer for role-run envelope generator"
    }
    r16_020_raci_transition_gate = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_020_raci_transition_gate/proof_review.json"
        SourceTask = "R16-020"
        Treatment = "proof-review package pointer for RACI transition gate"
    }
    r16_021_handoff_packet_generator = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_021_handoff_packet_generator/proof_review.json"
        SourceTask = "R16-021"
        Treatment = "proof-review package pointer for handoff packet generator"
    }
    r16_022_restart_compaction_recovery_drill = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_022_restart_compaction_recovery_drill/proof_review.json"
        SourceTask = "R16-022"
        Treatment = "proof-review package pointer for restart/compaction recovery drill"
    }
    r16_023_role_handoff_drill = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_023_role_handoff_drill/proof_review.json"
        SourceTask = "R16-023"
        Treatment = "proof-review package pointer for role-handoff drill"
    }
    r16_024_audit_readiness_drill = @{
        Path = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_024_audit_readiness_drill/proof_review.json"
        SourceTask = "R16-024"
        Treatment = "proof-review package pointer for audit-readiness drill"
    }
}

$script:RequiredMetricInputPaths = [string[]]($script:RequiredMetricInputRefs.Keys | ForEach-Object { $script:RequiredMetricInputRefs[$_].Path })
$script:RequiredProofReviewPaths = [string[]]($script:RequiredProofReviewRefs.Keys | ForEach-Object { $script:RequiredProofReviewRefs[$_].Path })

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_friction_metrics_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_friction_metrics_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_friction_metrics_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_handoff_drill.ps1"
)

$script:RequiredProcessFindingIds = [string[]]@(
    "codex_auto_compaction_failures",
    "fixture_bloat_full_copy_invalids",
    "untracked_file_visibility_gap",
    "deterministic_byte_line_drift",
    "validator_allowlist_update_cost",
    "finalization_split_pressure",
    "powershell_tooling_friction",
    "large_generated_json_context_pressure",
    "failed_closed_guard_is_expected",
    "runtime_non_solution_boundary"
)

$script:RequiredNextImplicationIds = [string[]]@(
    "split_finalization_b1_b2",
    "keep_compact_fixture_strategy",
    "preserve_untracked_line_counting",
    "prefer_targeted_field_extraction",
    "treat_failed_closed_guard_as_expected_signal"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-025 is a bounded friction metrics report only.",
    "Operator-observed process evidence is not machine proof.",
    "Raw chat history is not canonical evidence.",
    "Broad/full repo scan is not used.",
    "Exact provider tokenization and billing are not claimed.",
    "The context guard remains failed_closed_over_budget.",
    "No final R16 audit acceptance is claimed.",
    "No closeout completion is claimed.",
    "No final proof package completion is claimed.",
    "No runtime execution is claimed.",
    "No runtime memory is claimed.",
    "No retrieval runtime is claimed.",
    "No vector search runtime is claimed.",
    "No product runtime is claimed.",
    "No autonomous agents are claimed.",
    "No external integrations are claimed.",
    "No executable handoffs are claimed.",
    "No executable transitions are claimed.",
    "No solved Codex compaction is claimed.",
    "No solved Codex reliability is claimed.",
    "R16-026 remains planned only.",
    "R16-027 or later is not claimed.",
    "R13 remains failed/partial and not closed.",
    "R14 caveats remain preserved.",
    "R15 caveats remain preserved.",
    "No main merge is claimed."
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
    operator_observed_process_evidence_treated_as_machine_proof = "report-as-machine-proof misuse"
    operator_observed_process_evidence_machine_proof = "report-as-machine-proof misuse"
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
    runtime_execution_exists = "runtime execution claim"
    runtime_execution_claimed = "runtime execution claim"
    runtime_execution_performed = "runtime execution claim"
    runtime_execution_implemented = "runtime execution claim"
    runtime_memory_exists = "runtime memory claim"
    runtime_memory_claimed = "runtime memory claim"
    runtime_memory_implemented = "runtime memory claim"
    runtime_memory_loading_implemented = "runtime memory claim"
    retrieval_runtime_exists = "retrieval runtime claim"
    retrieval_runtime_claimed = "retrieval runtime claim"
    retrieval_runtime_implemented = "retrieval runtime claim"
    vector_search_runtime_exists = "vector search runtime claim"
    vector_search_runtime_claimed = "vector search runtime claim"
    vector_search_runtime_implemented = "vector search runtime claim"
    product_runtime_exists = "product runtime claim"
    product_runtime_claimed = "product runtime claim"
    product_runtime_implemented = "product runtime claim"
    autonomous_agents_exist = "autonomous-agent claim"
    autonomous_agent_claimed = "autonomous-agent claim"
    autonomous_agents_implemented = "autonomous-agent claim"
    actual_autonomous_agents_implemented = "autonomous-agent claim"
    external_integrations_exist = "external-integration claim"
    external_integration_claimed = "external-integration claim"
    external_integrations_implemented = "external-integration claim"
    executable_handoffs_exist = "executable handoff claim"
    executable_handoffs_claimed = "executable handoff claim"
    handoff_executable = "executable handoff claim"
    executable_transitions_exist = "executable transition claim"
    executable_transitions_claimed = "executable transition claim"
    transition_execution_permitted = "executable transition claim"
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_compaction_claimed = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
    solved_codex_reliability_claimed = "solved Codex reliability claim"
    r16_026_implementation_claimed = "R16-026 implementation claim"
    r16_026_final_proof_review_package_implemented = "R16-026 implementation claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r13_closed = "R13 closure or partial-gate conversion claim"
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

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $missing = @($Expected | Where-Object { $Actual -notcontains $_ })
    $extra = @($Actual | Where-Object { $Expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
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

function Assert-NoForbiddenTrueClaims {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey([string]$key) -and $Value[$key] -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[[string]$key])."
            }
            Assert-NoForbiddenTrueClaims -Value $Value[$key] -Context $Context
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Assert-NoForbiddenTrueClaims -Value $item -Context $Context
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($property.Name) -and $property.Value -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$property.Name])."
            }
            Assert-NoForbiddenTrueClaims -Value $property.Value -Context $Context
        }
    }
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json -replace "`r`n", "`n"
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($PathValue)
    $directory = [System.IO.Path]::GetDirectoryName($resolvedPath)
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = ConvertTo-StableJson -Object $InputObject
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($resolvedPath, ($json + [Environment]::NewLine), $utf8NoBom)
}

function Get-FileMetric {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = Assert-SafeRepoRelativeTrackedPath -PathValue $PathValue -RepositoryRoot $RepositoryRoot -Context $PathValue
    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    $item = Get-Item -LiteralPath $resolvedPath

    return [pscustomobject][ordered]@{
        path = $normalized
        byte_count = [int64]$item.Length
        line_count = [int64](@([System.IO.File]::ReadLines($resolvedPath)).Count)
        tracked_file = $true
    }
}

function New-RefMetricObject {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)]$Spec,
        [Parameter(Mandatory = $true)][int]$Order,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [switch]$ProofReview
    )

    $metric = Get-FileMetric -PathValue $Spec.Path -RepositoryRoot $RepositoryRoot
    $base = [ordered]@{
        ref_id = $RefId
        path = $metric.path
        source_task = [string]$Spec.SourceTask
        evidence_treatment = [string]$Spec.Treatment
        exact_path_only = $true
        tracked_file = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        machine_proof = $false
        byte_count = [int64]$metric.byte_count
        line_count = [int64]$metric.line_count
        deterministic_order = $Order
    }

    if ($ProofReview) {
        $base["metric_role"] = "proof_review_context"
    }
    else {
        $base["metric_role"] = [string]$Spec.MetricRole
    }

    return [pscustomobject]$base
}

function New-R16FrictionMetricsReportObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_budget_guard_report.json") -Label "R16 context budget guard report"
    $restartDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/workflow/r16_restart_compaction_recovery_drill.json") -Label "R16 restart/compaction recovery drill"
    $roleHandoffDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/workflow/r16_role_handoff_drill.json") -Label "R16 role-handoff drill"
    $auditReadinessDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/audit/r16_audit_readiness_drill.json") -Label "R16 audit-readiness drill"

    $guardUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $guardThreshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
    $thresholdExceeded = [bool]$guard.evaluated_budget.threshold_exceeded

    $exactMetricInputs = @()
    $order = 1
    foreach ($refId in $script:RequiredMetricInputRefs.Keys) {
        $exactMetricInputs += New-RefMetricObject -RefId $refId -Spec $script:RequiredMetricInputRefs[$refId] -Order $order -RepositoryRoot $resolvedRoot
        $order += 1
    }

    $proofReviewRefs = @()
    foreach ($refId in $script:RequiredProofReviewRefs.Keys) {
        $proofReviewRefs += New-RefMetricObject -RefId $refId -Spec $script:RequiredProofReviewRefs[$refId] -Order $order -RepositoryRoot $resolvedRoot -ProofReview
        $order += 1
    }

    $largestExactInputs = @($exactMetricInputs | Sort-Object -Property byte_count -Descending | Select-Object -First 5 | ForEach-Object {
            [pscustomobject][ordered]@{
                path = [string]$_.path
                byte_count = [int64]$_.byte_count
                line_count = [int64]$_.line_count
            }
        })

    $restartStepCount = if (Test-HasProperty -InputObject $restartDrill -Name "recovery_steps") { @($restartDrill.recovery_steps).Count } else { 0 }
    $auditInputCount = if (Test-HasProperty -InputObject $auditReadinessDrill -Name "exact_audit_inputs") { @($auditReadinessDrill.exact_audit_inputs).Count } else { 0 }

    return [pscustomobject][ordered]@{
        artifact_type = "r16_friction_metrics_report"
        report_version = $script:ReportVersion
        report_id = $script:ReportId
        source_milestone = $script:R16Milestone
        source_task = "R16-025"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [pscustomobject][ordered]@{
            generated_report_path = "state/governance/r16_friction_metrics_report.json"
            generated_report_treatment = "committed generated friction metrics state artifact only"
            implementation_pass_only = $true
            proof_status_commit_pass_completed = $false
            full_dependent_validation_sweep_performed = $false
            broad_repo_scan_performed = $false
            full_repo_scan_performed = $false
            raw_chat_history_loaded = $false
        }
        metric_scope = [pscustomobject][ordered]@{
            report_only_friction_metrics = $true
            captures_operational_friction = $true
            captures_context_pressure = $true
            source_evidence_classes = [string[]]@(
                "exact_repo_backed_artifacts",
                "proof_review_refs",
                "operator_observed_process_evidence"
            )
            exact_repo_backed_artifacts_are_canonical_metric_inputs = $true
            operator_observed_process_evidence_is_canonical_machine_proof = $false
            operator_observed_process_evidence_treated_as_machine_proof = $false
            generated_report_treated_as_machine_proof = $false
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            runtime_execution_claimed = $false
            runtime_memory_claimed = $false
            retrieval_runtime_claimed = $false
            vector_search_runtime_claimed = $false
            product_runtime_claimed = $false
            autonomous_agent_claimed = $false
            external_integration_claimed = $false
        }
        exact_metric_inputs = [object[]]$exactMetricInputs
        proof_review_refs = [object[]]$proofReviewRefs
        context_budget_history = [pscustomobject][ordered]@{
            metric_basis = "current_committed_guard_artifact_plus_operator_observed_drift_notes"
            context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
            context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
            latest_accepted_guard_verdict = [string]$guard.aggregate_verdict
            latest_accepted_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            threshold_exceeded = $thresholdExceeded
            budget_category = [string]$guard.evaluated_budget.budget_category
            guard_growth_exact_series_available = $false
            guard_growth_exact_series = "not_measured"
            deterministic_status_and_proof_edit_drift_observed = $true
            deterministic_drift_evidence_class = "operator_observed_process_evidence"
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            provider_tokenizer_used = $false
            provider_pricing_used = $false
        }
        context_guard_posture = [pscustomobject][ordered]@{
            guard_verdict = [string]$guard.aggregate_verdict
            expected_failed_closed = $true
            failed_closed_is_expected_signal = $true
            latest_accepted_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            threshold_exceeded = $thresholdExceeded
            mitigation_created = $false
            failed_task = $false
            proves_current_context_surface_too_large = $true
            proves_guard_works = $true
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
        }
        loaded_file_metrics = [pscustomobject][ordered]@{
            metric_basis = "exact_repo_backed_file_metadata_for_required_refs_only"
            exact_metric_input_count = $exactMetricInputs.Count
            proof_review_ref_count = $proofReviewRefs.Count
            total_exact_ref_count = $exactMetricInputs.Count + $proofReviewRefs.Count
            large_generated_json_context_pressure_observed = $true
            large_generated_json_threshold_bytes = 100000
            largest_exact_metric_inputs = [object[]]$largestExactInputs
            exact_metric_input_files = [object[]]$exactMetricInputs
        }
        exact_ref_metrics = [pscustomobject][ordered]@{
            metric_basis = "exact_repo_relative_tracked_paths_only"
            exact_metric_input_count = $exactMetricInputs.Count
            proof_review_ref_count = $proofReviewRefs.Count
            all_exact_metric_inputs_tracked = $true
            all_proof_review_refs_tracked = $true
            broad_repo_scan_performed = $false
            full_repo_scan_performed = $false
            wildcard_path_expansion_performed = $false
            directory_only_refs_loaded = $false
            scratch_temp_refs_loaded = $false
            absolute_paths_loaded = $false
            parent_traversal_refs_loaded = $false
            url_or_remote_refs_loaded = $false
            untracked_file_visibility_issue_captured = $true
            untracked_line_counting_required_for_future_diff_control = $true
        }
        manual_step_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence"
            machine_proof = $false
            exact_manual_step_count = "not_measured"
            manual_step_categories = [object[]]@(
                [pscustomobject][ordered]@{ step_id = "baseline_and_branch_checks"; description = "Verify branch, head, status, and recent log before changing R16 artifacts." },
                [pscustomobject][ordered]@{ step_id = "targeted_validation_commands"; description = "Run bounded validators and tests instead of historical full sweeps during implementation passes." },
                [pscustomobject][ordered]@{ step_id = "explicit_untracked_line_counting"; description = "Account for untracked files because git diff --stat and --numstat omit them." },
                [pscustomobject][ordered]@{ step_id = "deterministic_regeneration_order"; description = "Regenerate only after validation proves deterministic state artifacts are stale." },
                [pscustomobject][ordered]@{ step_id = "restart_recovery_from_exact_refs"; description = "Recover from compaction or restart using exact repo-backed refs rather than raw chat history." },
                [pscustomobject][ordered]@{ step_id = "proof_status_finalization_split"; description = "Keep proof/status/regeneration separate from validation/commit/push when context is high." },
                [pscustomobject][ordered]@{ step_id = "direct_powershell_execution"; description = "Prefer direct command invocation and targeted Select-String/field extraction when shell wrappers are brittle." }
            )
        }
        restart_recovery_metrics = [pscustomobject][ordered]@{
            metric_basis = "restart_drill_artifact_plus_operator_observed_process_evidence"
            restart_compaction_recovery_drill_ref = "state/workflow/r16_restart_compaction_recovery_drill.json"
            restart_recovery_step_count_from_artifact = $restartStepCount
            exact_recovery_input_count_from_artifact = @($restartDrill.exact_recovery_inputs).Count
            raw_chat_history_as_canonical_evidence = $false
            operator_observed_local_wip_recovery_cycles = "repeated"
            exact_local_wip_recovery_cycle_count = "not_measured"
            recovery_evidence_class = "operator_observed_process_evidence"
            machine_proof = $false
        }
        compaction_failure_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence"
            machine_proof = $false
            repeated_codex_automatic_compaction_failures_observed = $true
            exact_failure_count = "not_measured"
            observed_failure_messages = [string[]]@(
                "Context automatically compacted.",
                "Error running remote compact task: stream disconnected before completion."
            )
            main_occurrence_window = "long finalization passes after proof/status/regeneration work and before commit/push"
            process_impact = "repeated local-WIP recovery cycles"
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        deterministic_drift_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence_plus_latest_guard_artifact"
            deterministic_byte_line_drift_observed = $true
            exact_drift_occurrence_count = "not_measured"
            drift_source = "status and proof edits changed files in the context-load plan"
            affected_guard_upper_bound_latest_accepted = $guardUpperBound
            threshold = $guardThreshold
            cascade_tasks = [string[]]@("R16-016", "R16-017", "R16-019", "R16-020", "R16-021", "R16-022", "R16-023", "R16-024")
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
        }
        regeneration_cascade_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence"
            cascade_observed = $true
            exact_regeneration_cascade_count = "not_measured"
            affected_artifact_tasks = [string[]]@("R16-019", "R16-020", "R16-021", "R16-022", "R16-023", "R16-024")
            validation_regeneration_cascade_cost = "operationally_expensive"
            older_validator_allowlist_updates_required = $true
            future_tasks_kept_forbidden = $true
        }
        stale_ref_findings = [object[]]@(
            [pscustomobject][ordered]@{
                finding_id = "deterministic_guard_drift_stale_generated_refs"
                evidence_class = "operator_observed_process_evidence"
                machine_proof = $false
                description = "Deterministic byte and line drift in status/proof surfaces can make accepted generated artifacts stale until regenerated in order."
                exact_occurrence_count = "not_measured"
            },
            [pscustomobject][ordered]@{
                finding_id = "untracked_diff_visibility_gap"
                evidence_class = "operator_observed_process_evidence"
                machine_proof = $false
                description = "git diff --stat and git diff --numstat do not include untracked files, so explicit untracked line counting must be preserved."
                exact_occurrence_count = "not_measured"
            }
        )
        fixture_bloat_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence"
            machine_proof = $false
            r16_019_initial_fixture_bloat_observed = $true
            initial_unstaged_added_lines_approximate = "150k+"
            exact_initial_unstaged_added_line_count = "not_measured"
            root_cause = "full-copy invalid fixtures"
            mitigation = "one full valid fixture plus compact invalid mutation specs"
            invalid_objects_constructed_in_memory_by_tests = $true
            compact_invalid_fixture_line_limit = 50
        }
        validation_sweep_metrics = [pscustomobject][ordered]@{
            metric_basis = "required_focused_validation_command_list"
            focused_validation_command_count = $script:RequiredValidationCommands.Count
            full_dependent_validation_sweep_performed = $false
            full_historical_validation_sweep_required_for_this_pass = $false
            validation_regeneration_cascade_cost = "high_when_combined_with_proof_status_regeneration_commit_push"
            focused_validation_commands = [string[]]$script:RequiredValidationCommands
        }
        local_wip_interruption_metrics = [pscustomobject][ordered]@{
            metric_basis = "operator_observed_process_evidence"
            machine_proof = $false
            repeated_local_wip_recovery_cycles_observed = $true
            exact_interruption_count = "not_measured"
            interruption_pattern = "compaction failures during long finalization passes before commit/push"
            mitigation_recommendation = "split finalization into B1 proof/status/regeneration and B2 validation/commit/push"
        }
        process_friction_findings = [object[]]@(
            [pscustomobject][ordered]@{ finding_id = "codex_auto_compaction_failures"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "Repeated automatic compaction failures created local-WIP recovery cycles."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "fixture_bloat_full_copy_invalids"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "R16-019 initially produced around 150k+ unstaged/added lines from full-copy invalid fixtures; compact mutation specs mitigated it."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "untracked_file_visibility_gap"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "git diff --stat and git diff --numstat omit untracked files, requiring explicit untracked line counting."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "deterministic_byte_line_drift"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "Status and proof edits changed deterministic byte/line inputs and cascaded through R16-016, R16-017, and R16-019 through R16-024."; latest_guard_upper_bound = $guardUpperBound },
            [pscustomobject][ordered]@{ finding_id = "validator_allowlist_update_cost"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "Each newly authorized task artifact required narrow validator allowlist updates while keeping future tasks forbidden."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "finalization_split_pressure"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "A/B split helped, but finalization pass B was still too large when proof, status, regeneration, validation, commit, and push were combined."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "powershell_tooling_friction"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "rg.exe access denial, wrapper interpolation, array invocation, and short timeouts created PowerShell/tooling friction."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "large_generated_json_context_pressure"; evidence_class = "operator_observed_process_evidence"; machine_proof = $false; summary = "Large generated state JSON files add context pressure and should be inspected through validators or targeted field extraction."; exact_count = "not_measured" },
            [pscustomobject][ordered]@{ finding_id = "failed_closed_guard_is_expected"; evidence_class = "committed_guard_artifact_plus_operator_observed_process_evidence"; machine_proof = $false; summary = "The context guard is correctly failed closed and should be treated as an expected signal, not a failed task."; latest_guard_upper_bound = $guardUpperBound; threshold = $guardThreshold },
            [pscustomobject][ordered]@{ finding_id = "runtime_non_solution_boundary"; evidence_class = "boundary_policy"; machine_proof = $false; summary = "R16 does not claim runtime memory, retrieval/vector runtime, product runtime, autonomous agents, executable handoffs/transitions, or solved Codex reliability."; exact_count = "not_measured" }
        )
        next_milestone_planning_implications = [object[]]@(
            [pscustomobject][ordered]@{ implication_id = "split_finalization_b1_b2"; recommendation = "Use B1 for proof/status/regeneration only and B2 for validation/commit/push only." },
            [pscustomobject][ordered]@{ implication_id = "keep_compact_fixture_strategy"; recommendation = "Keep one full valid fixture and compact invalid mutation specs; construct invalid objects in memory." },
            [pscustomobject][ordered]@{ implication_id = "preserve_untracked_line_counting"; recommendation = "Always pair git diff --stat and --numstat with explicit untracked line counting before validation." },
            [pscustomobject][ordered]@{ implication_id = "prefer_targeted_field_extraction"; recommendation = "Prefer validators, Select-String, and targeted JSON field extraction over opening large generated JSON." },
            [pscustomobject][ordered]@{ implication_id = "treat_failed_closed_guard_as_expected_signal"; recommendation = "Treat the failed-closed guard as proof the context surface remains too large and that the guard works." },
            [pscustomobject][ordered]@{ implication_id = "keep_future_task_allowlists_narrow"; recommendation = "Authorize the current task narrowly while keeping R16-026 and later work forbidden until explicitly started." }
        )
        no_full_repo_scan_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_metric_inputs_only = $true
            broad_repo_scan_allowed = $false
            broad_repo_scan_performed = $false
            full_repo_scan_allowed = $false
            full_repo_scan_performed = $false
            wildcard_path_expansion_allowed = $false
            wildcard_path_expansion_performed = $false
            wildcard_paths_allowed = $false
            directory_only_refs_allowed = $false
            scratch_temp_refs_allowed = $false
            absolute_paths_allowed = $false
            parent_traversal_allowed = $false
            url_or_remote_refs_allowed = $false
        }
        raw_chat_history_policy = [pscustomobject][ordered]@{
            canonical_evidence_source = "exact_repo_backed_artifacts_only"
            raw_chat_history_as_canonical_evidence = $false
            raw_chat_history_as_canonical_state = $false
            raw_chat_history_loaded = $false
            raw_chat_history_loading_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            operator_observed_process_evidence_separate_from_raw_chat_history = $true
        }
        finding_summary = [pscustomobject][ordered]@{
            friction_finding_count = $script:RequiredProcessFindingIds.Count
            next_milestone_implication_count = 6
            exact_metric_input_count = $exactMetricInputs.Count
            proof_review_ref_count = $proofReviewRefs.Count
            audit_readiness_exact_input_count = $auditInputCount
            latest_guard_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            guard_verdict = [string]$guard.aggregate_verdict
            executable_handoff_count = [int64]$roleHandoffDrill.executable_handoff_count
            executable_transition_count = [int64]$roleHandoffDrill.executable_transition_count
        }
        aggregate_verdict = $script:AggregateVerdict
        validation_commands = [string[]]$script:RequiredValidationCommands
        current_posture = [pscustomobject][ordered]@{
            active_through_task = "R16-025"
            active_through_scope = "R16-025 bounded friction metrics report only"
            r16_026_planned_only = $true
            planned_tasks = [string[]]@("R16-026")
            r16_026_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            runtime_execution_exists = $false
            runtime_memory_exists = $false
            retrieval_runtime_exists = $false
            vector_search_runtime_exists = $false
            product_runtime_exists = $false
            autonomous_agents_exist = $false
            external_integrations_exist = $false
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            main_merge_claimed = $false
        }
        preserved_boundaries = [pscustomobject][ordered]@{
            r13 = [pscustomobject][ordered]@{
                status = "failed_partial_through_r13_018_only"
                closed = $false
                partial_gates_remain_partial = $true
                partial_gates_converted_to_passed = $false
            }
            r14 = [pscustomobject][ordered]@{
                status = "accepted_with_caveats_through_r14_006_only"
                caveats_removed = $false
                product_runtime = $false
            }
            r15 = [pscustomobject][ordered]@{
                status = "accepted_with_caveats_through_r15_009_only"
                caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
            }
        }
        non_claims = [string[]]$script:RequiredNonClaims
    }
}

function Assert-RequiredObjectSection {
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)][string]$FieldName,
        [Parameter(Mandatory = $true)][string]$SourceLabel
    )

    $section = Get-RequiredProperty -InputObject $Report -Name $FieldName -Context $SourceLabel
    Assert-ObjectValue -Value $section -Context "$SourceLabel $FieldName" | Out-Null
    return $section
}

function Assert-PolicyBooleans {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in @("repo_relative_exact_paths_only", "tracked_files_only", "exact_metric_inputs_only")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }

    foreach ($fieldName in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_path_expansion_allowed", "wildcard_path_expansion_performed", "wildcard_paths_allowed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context rejects $fieldName."
        }
    }
}

function Assert-RawChatPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in @("raw_chat_history_as_canonical_evidence", "raw_chat_history_as_canonical_state", "raw_chat_history_loaded", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context rejects raw chat history as canonical evidence."
        }
    }
}

function Assert-RefObject {
    param(
        [Parameter(Mandatory = $true)]$RefObject,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$ExpectedPath
    )

    Assert-ObjectValue -Value $RefObject -Context $Context | Out-Null
    $path = Assert-SafeRepoRelativeTrackedPath -PathValue (Get-RequiredProperty -InputObject $RefObject -Name "path" -Context $Context) -RepositoryRoot $RepositoryRoot -Context $Context
    if ($path -ne $ExpectedPath) {
        throw "$Context path must be '$ExpectedPath'."
    }

    foreach ($fieldName in @("ref_id", "source_task", "evidence_treatment")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName" | Out-Null
    }
    foreach ($fieldName in @("exact_path_only", "tracked_file")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }
    foreach ($fieldName in @("broad_scan_allowed", "wildcard_allowed", "machine_proof")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context $fieldName must be False."
        }
    }
    Assert-IntegerValue -Value (Get-RequiredProperty -InputObject $RefObject -Name "byte_count" -Context $Context) -Context "$Context byte_count" | Out-Null
    Assert-IntegerValue -Value (Get-RequiredProperty -InputObject $RefObject -Name "line_count" -Context $Context) -Context "$Context line_count" | Out-Null
}

function Test-R16FrictionMetricsReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 friction metrics report",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }

    if ([string]$Report.artifact_type -ne "r16_friction_metrics_report") {
        throw "$SourceLabel artifact_type must be 'r16_friction_metrics_report'."
    }
    if ([string]$Report.report_version -ne $script:ReportVersion -or [string]$Report.report_id -ne $script:ReportId) {
        throw "$SourceLabel report identity is incorrect."
    }
    if ([string]$Report.source_milestone -ne $script:R16Milestone -or [string]$Report.source_task -ne "R16-025") {
        throw "$SourceLabel source identity must be R16-025."
    }
    if ([string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }
    if ([string]$Report.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be '$script:AggregateVerdict'."
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel

    $metricScope = Assert-RequiredObjectSection -Report $Report -FieldName "metric_scope" -SourceLabel $SourceLabel
    if ((Assert-BooleanValue -Value $metricScope.operator_observed_process_evidence_treated_as_machine_proof -Context "$SourceLabel metric_scope operator evidence treatment") -ne $false) {
        throw "$SourceLabel rejects report-as-machine-proof misuse."
    }

    $exactInputs = Assert-ObjectArray -Value $Report.exact_metric_inputs -Context "$SourceLabel exact_metric_inputs"
    if ($exactInputs.Count -ne $script:RequiredMetricInputPaths.Count) {
        throw "$SourceLabel exact_metric_inputs must include exactly $($script:RequiredMetricInputPaths.Count) refs."
    }
    for ($index = 0; $index -lt $exactInputs.Count; $index += 1) {
        Assert-RefObject -RefObject $exactInputs[$index] -Context "$SourceLabel exact_metric_inputs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredMetricInputPaths[$index]
    }

    $proofRefs = Assert-ObjectArray -Value (Get-RequiredProperty -InputObject $Report -Name "proof_review_refs" -Context $SourceLabel) -Context "$SourceLabel proof_review_refs"
    if ($proofRefs.Count -ne $script:RequiredProofReviewPaths.Count) {
        throw "$SourceLabel proof_review_refs must include exactly $($script:RequiredProofReviewPaths.Count) refs."
    }
    for ($index = 0; $index -lt $proofRefs.Count; $index += 1) {
        Assert-RefObject -RefObject $proofRefs[$index] -Context "$SourceLabel proof_review_refs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredProofReviewPaths[$index]
    }

    $contextBudgetHistory = Assert-RequiredObjectSection -Report $Report -FieldName "context_budget_history" -SourceLabel $SourceLabel
    if ([string]$contextBudgetHistory.latest_accepted_guard_verdict -ne $script:GuardVerdict) {
        throw "$SourceLabel context_budget_history guard verdict must be '$script:GuardVerdict'."
    }
    if ([int64]$contextBudgetHistory.latest_accepted_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$contextBudgetHistory.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel context_budget_history must preserve latest accepted guard upper bound $script:ExpectedGuardUpperBound with threshold $script:ExpectedThreshold."
    }
    foreach ($fieldName in @("exact_provider_tokenization_claimed", "exact_provider_billing_claimed", "provider_tokenizer_used", "provider_pricing_used")) {
        if ((Assert-BooleanValue -Value $contextBudgetHistory.$fieldName -Context "$SourceLabel context_budget_history $fieldName") -ne $false) {
            throw "$SourceLabel rejects $fieldName."
        }
    }

    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_budget_guard_report.json") -Label "R16 context budget guard report"
    if ([int64]$guard.evaluated_budget.estimated_tokens_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "$SourceLabel current guard artifact does not match latest accepted R16-024 boundary."
    }

    $contextGuardPosture = Assert-RequiredObjectSection -Report $Report -FieldName "context_guard_posture" -SourceLabel $SourceLabel
    if ([string]$contextGuardPosture.guard_verdict -ne $script:GuardVerdict -or [int64]$contextGuardPosture.latest_accepted_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$contextGuardPosture.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel context_guard_posture must preserve failed-closed guard values."
    }
    if ((Assert-BooleanValue -Value $contextGuardPosture.failed_closed_is_expected_signal -Context "$SourceLabel context_guard_posture failed_closed_is_expected_signal") -ne $true) {
        throw "$SourceLabel must treat failed-closed guard as expected signal."
    }

    $loadedFileMetrics = Assert-RequiredObjectSection -Report $Report -FieldName "loaded_file_metrics" -SourceLabel $SourceLabel
    if ([int64]$loadedFileMetrics.exact_metric_input_count -ne $script:RequiredMetricInputPaths.Count -or [int64]$loadedFileMetrics.proof_review_ref_count -ne $script:RequiredProofReviewPaths.Count) {
        throw "$SourceLabel loaded_file_metrics counts are incorrect."
    }
    if ((Assert-BooleanValue -Value $loadedFileMetrics.large_generated_json_context_pressure_observed -Context "$SourceLabel loaded_file_metrics large_generated_json_context_pressure_observed") -ne $true) {
        throw "$SourceLabel must capture large generated JSON context pressure."
    }

    $exactRefMetrics = Assert-RequiredObjectSection -Report $Report -FieldName "exact_ref_metrics" -SourceLabel $SourceLabel
    if ((Assert-BooleanValue -Value $exactRefMetrics.untracked_file_visibility_issue_captured -Context "$SourceLabel exact_ref_metrics untracked_file_visibility_issue_captured") -ne $true) {
        throw "$SourceLabel must capture untracked file visibility issue."
    }

    foreach ($sectionName in @("manual_step_metrics", "restart_recovery_metrics", "compaction_failure_metrics", "deterministic_drift_metrics", "regeneration_cascade_metrics", "fixture_bloat_metrics", "validation_sweep_metrics", "local_wip_interruption_metrics")) {
        Assert-RequiredObjectSection -Report $Report -FieldName $sectionName -SourceLabel $SourceLabel | Out-Null
    }

    if ([string]$Report.compaction_failure_metrics.metric_basis -ne "operator_observed_process_evidence" -or [bool]$Report.compaction_failure_metrics.machine_proof -ne $false) {
        throw "$SourceLabel compaction_failure_metrics must be operator-observed process evidence, not machine proof."
    }
    if ((Assert-BooleanValue -Value $Report.compaction_failure_metrics.repeated_codex_automatic_compaction_failures_observed -Context "$SourceLabel compaction_failure_metrics repeated failures") -ne $true) {
        throw "$SourceLabel must capture repeated Codex automatic compaction failures."
    }
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $Report.compaction_failure_metrics.observed_failure_messages -Context "$SourceLabel compaction failure messages") -Required @("Context automatically compacted.", "Error running remote compact task: stream disconnected before completion.") -Context "$SourceLabel compaction failure messages"

    if ((Assert-BooleanValue -Value $Report.fixture_bloat_metrics.invalid_objects_constructed_in_memory_by_tests -Context "$SourceLabel fixture_bloat_metrics invalid_objects_constructed_in_memory_by_tests") -ne $true -or [int64]$Report.fixture_bloat_metrics.compact_invalid_fixture_line_limit -ne 50) {
        throw "$SourceLabel must capture compact fixture strategy."
    }
    if ((Assert-BooleanValue -Value $Report.deterministic_drift_metrics.deterministic_byte_line_drift_observed -Context "$SourceLabel deterministic_drift_metrics deterministic_byte_line_drift_observed") -ne $true) {
        throw "$SourceLabel must capture deterministic byte/line drift."
    }
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $Report.regeneration_cascade_metrics.affected_artifact_tasks -Context "$SourceLabel regeneration cascade tasks") -Required @("R16-019", "R16-020", "R16-021", "R16-022", "R16-023", "R16-024") -Context "$SourceLabel regeneration cascade tasks"

    $staleFindings = Assert-ObjectArray -Value $Report.stale_ref_findings -Context "$SourceLabel stale_ref_findings"
    if ($staleFindings.Count -lt 2) {
        throw "$SourceLabel stale_ref_findings must capture deterministic drift and untracked visibility findings."
    }

    $processFindings = Assert-ObjectArray -Value $Report.process_friction_findings -Context "$SourceLabel process_friction_findings"
    $processFindingIds = [string[]]@($processFindings | ForEach-Object { [string]$_.finding_id })
    Assert-RequiredStringsPresent -Actual $processFindingIds -Required $script:RequiredProcessFindingIds -Context "$SourceLabel process_friction_findings"
    foreach ($finding in $processFindings) {
        if (Test-HasProperty -InputObject $finding -Name "machine_proof") {
            Assert-BooleanValue -Value $finding.machine_proof -Context "$SourceLabel process_friction_findings machine_proof" | Out-Null
        }
    }

    $implications = Assert-ObjectArray -Value $Report.next_milestone_planning_implications -Context "$SourceLabel next_milestone_planning_implications"
    $implicationIds = [string[]]@($implications | ForEach-Object { [string]$_.implication_id })
    Assert-RequiredStringsPresent -Actual $implicationIds -Required $script:RequiredNextImplicationIds -Context "$SourceLabel next_milestone_planning_implications"

    Assert-PolicyBooleans -Policy (Assert-RequiredObjectSection -Report $Report -FieldName "no_full_repo_scan_policy" -SourceLabel $SourceLabel) -Context "$SourceLabel no_full_repo_scan_policy"
    Assert-RawChatPolicy -Policy (Assert-RequiredObjectSection -Report $Report -FieldName "raw_chat_history_policy" -SourceLabel $SourceLabel) -Context "$SourceLabel raw_chat_history_policy"

    $validationCommands = Assert-StringArray -Value $Report.validation_commands -Context "$SourceLabel validation_commands"
    Assert-RequiredStringsPresent -Actual $validationCommands -Required $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $currentPosture = Assert-RequiredObjectSection -Report $Report -FieldName "current_posture" -SourceLabel $SourceLabel
    if ([string]$currentPosture.active_through_task -ne "R16-025") {
        throw "$SourceLabel current_posture active_through_task must be R16-025."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $currentPosture.planned_tasks -Context "$SourceLabel current_posture planned_tasks") -Expected @("R16-026") -Context "$SourceLabel current_posture planned_tasks"
    if ((Assert-BooleanValue -Value $currentPosture.r16_026_planned_only -Context "$SourceLabel current_posture r16_026_planned_only") -ne $true) {
        throw "$SourceLabel must keep R16-026 planned only."
    }

    $preserved = Assert-RequiredObjectSection -Report $Report -FieldName "preserved_boundaries" -SourceLabel $SourceLabel
    if ([bool]$preserved.r13.closed -ne $false -or [bool]$preserved.r13.partial_gates_converted_to_passed -ne $false) {
        throw "$SourceLabel preserved_boundaries r13 rejects R13 closure or partial-gate conversion claim."
    }
    if ([bool]$preserved.r14.caveats_removed -ne $false) {
        throw "$SourceLabel preserved_boundaries r14 rejects caveat removal."
    }
    if ([bool]$preserved.r15.caveats_removed -ne $false) {
        throw "$SourceLabel preserved_boundaries r15 rejects caveat removal."
    }

    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ReportId = [string]$Report.report_id
        SourceTask = [string]$Report.source_task
        ActiveThroughTask = [string]$Report.current_posture.active_through_task
        PlannedTaskStart = [string]$Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = [string]$Report.current_posture.planned_tasks[-1]
        ExactMetricInputCount = $exactInputs.Count
        ProofReviewRefCount = $proofRefs.Count
        AggregateVerdict = [string]$Report.aggregate_verdict
        GuardVerdict = [string]$Report.context_guard_posture.guard_verdict
        LatestGuardUpperBound = [int64]$Report.context_guard_posture.latest_accepted_upper_bound
        Threshold = [int64]$Report.context_guard_posture.threshold
        FrictionFindingCount = $processFindings.Count
        NextMilestoneImplicationCount = $implications.Count
    }
}

function Test-R16FrictionMetricsReport {
    [CmdletBinding()]
    param(
        [string]$Path = "state/governance/r16_friction_metrics_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 friction metrics report"
    return Test-R16FrictionMetricsReportObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16FrictionMetricsReport {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/governance/r16_friction_metrics_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16FrictionMetricsReportObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $report -PathValue $resolvedOutput
    $validation = Test-R16FrictionMetricsReport -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        ReportId = $validation.ReportId
        ExactMetricInputCount = $validation.ExactMetricInputCount
        ProofReviewRefCount = $validation.ProofReviewRefCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        GuardVerdict = $validation.GuardVerdict
        LatestGuardUpperBound = $validation.LatestGuardUpperBound
        Threshold = $validation.Threshold
        FrictionFindingCount = $validation.FrictionFindingCount
        NextMilestoneImplicationCount = $validation.NextMilestoneImplicationCount
    }
}

function Test-R16FrictionMetricsReportContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/governance/r16_friction_metrics_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 friction metrics report contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "friction_metrics_report_policy", "no_full_repo_scan_policy", "raw_chat_history_policy", "required_process_friction_finding_ids", "required_next_milestone_implication_ids", "required_validation_commands", "required_non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 friction metrics report contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_friction_metrics_report_contract" -or [string]$contract.source_task -ne "R16-025") {
        throw "R16 friction metrics report contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 friction metrics report contract"
    Assert-PolicyBooleans -Policy $contract.no_full_repo_scan_policy -Context "R16 friction metrics report contract no_full_repo_scan_policy"
    Assert-RawChatPolicy -Policy $contract.raw_chat_history_policy -Context "R16 friction metrics report contract raw_chat_history_policy"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 friction metrics report contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 friction metrics report contract required_report_fields"
    $dependencyRefs = Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 friction metrics report contract dependency_refs"
    $expectedDependencyPaths = [string[]]($script:RequiredMetricInputPaths + $script:RequiredProofReviewPaths)
    if ($dependencyRefs.Count -ne $expectedDependencyPaths.Count) {
        throw "R16 friction metrics report contract dependency_refs must include exactly $($expectedDependencyPaths.Count) exact input and proof-review refs."
    }
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        $depPath = Assert-SafeRepoRelativeTrackedPath -PathValue $dependencyRefs[$index].path -RepositoryRoot $resolvedRoot -Context "R16 friction metrics report contract dependency_refs[$index]"
        if ($depPath -ne $expectedDependencyPaths[$index]) {
            throw "R16 friction metrics report contract dependency_refs[$index] path must be '$($expectedDependencyPaths[$index])'."
        }
    }

    if ([string]$contract.friction_metrics_report_policy.aggregate_verdict_required -ne $script:AggregateVerdict) {
        throw "R16 friction metrics report contract aggregate verdict policy is incorrect."
    }
    if ([int64]$contract.friction_metrics_report_policy.latest_accepted_guard_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$contract.friction_metrics_report_policy.threshold -ne $script:ExpectedThreshold) {
        throw "R16 friction metrics report contract guard boundary is incorrect."
    }
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_process_friction_finding_ids -Context "R16 friction metrics report contract required_process_friction_finding_ids") -Required $script:RequiredProcessFindingIds -Context "R16 friction metrics report contract required_process_friction_finding_ids"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_next_milestone_implication_ids -Context "R16 friction metrics report contract required_next_milestone_implication_ids") -Required $script:RequiredNextImplicationIds -Context "R16 friction metrics report contract required_next_milestone_implication_ids"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_validation_commands -Context "R16 friction metrics report contract required_validation_commands") -Required $script:RequiredValidationCommands -Context "R16 friction metrics report contract required_validation_commands"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_non_claims -Context "R16 friction metrics report contract required_non_claims") -Required $script:RequiredNonClaims -Context "R16 friction metrics report contract required_non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16FrictionMetricsReportFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_friction_metrics_report",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16FrictionMetricsReportObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validReport -PathValue (Join-Path $fixtureRootPath "valid_friction_metrics_report.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_friction_metrics_report.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.generation_boundary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generation_boundary'")
        "invalid_missing_context_budget_history.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_history" -MutationPath '$.context_budget_history' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_history'")
        "invalid_missing_context_guard_posture.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_guard_posture" -MutationPath '$.context_guard_posture' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_guard_posture'")
        "invalid_missing_manual_step_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_manual_step_metrics" -MutationPath '$.manual_step_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'manual_step_metrics'")
        "invalid_missing_restart_recovery_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_restart_recovery_metrics" -MutationPath '$.restart_recovery_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'restart_recovery_metrics'")
        "invalid_missing_compaction_failure_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_compaction_failure_metrics" -MutationPath '$.compaction_failure_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'compaction_failure_metrics'")
        "invalid_missing_deterministic_drift_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_deterministic_drift_metrics" -MutationPath '$.deterministic_drift_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'deterministic_drift_metrics'")
        "invalid_missing_regeneration_cascade_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_regeneration_cascade_metrics" -MutationPath '$.regeneration_cascade_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'regeneration_cascade_metrics'")
        "invalid_missing_fixture_bloat_metrics.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_fixture_bloat_metrics" -MutationPath '$.fixture_bloat_metrics' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'fixture_bloat_metrics'")
        "invalid_missing_next_milestone_planning_implications.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_next_milestone_planning_implications" -MutationPath '$.next_milestone_planning_implications' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'next_milestone_planning_implications'")
        "invalid_raw_chat_history_as_canonical_evidence.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_as_canonical_evidence" -MutationPath '$.raw_chat_history_policy.raw_chat_history_as_canonical_evidence' -MutationValue $true -ExpectedFailure @("raw chat history as canonical evidence")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "state/context/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "state/context/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "scratch/r16_friction_metrics.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "C:/tmp/r16_friction_metrics_report.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "../state/context/r16_context_load_plan.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.exact_metric_inputs[0].path' -MutationValue "https://example.invalid/r16_context_load_plan.json" -ExpectedFailure @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.metric_scope.generated_report_treated_as_machine_proof' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.context_budget_history.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.context_budget_history.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_solved_codex_compaction_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_compaction_claim" -MutationPath '$.current_posture.solved_codex_compaction' -MutationValue $true -ExpectedFailure @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_reliability_claim" -MutationPath '$.current_posture.solved_codex_reliability' -MutationValue $true -ExpectedFailure @("solved Codex reliability claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.current_posture.runtime_memory_exists' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.current_posture.retrieval_runtime_exists' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.current_posture.vector_search_runtime_exists' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.current_posture.product_runtime_exists' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.current_posture.autonomous_agents_exist' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.current_posture.external_integrations_exist' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_executable_handoff_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_handoff_claim" -MutationPath '$.current_posture.executable_handoffs_exist' -MutationValue $true -ExpectedFailure @("executable handoff claim")
        "invalid_executable_transition_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_transition_claim" -MutationPath '$.current_posture.executable_transitions_exist' -MutationValue $true -ExpectedFailure @("executable transition claim")
        "invalid_final_r16_audit_acceptance_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_final_r16_audit_acceptance_claim" -MutationPath '$.current_posture.final_r16_audit_acceptance_claimed' -MutationValue $true -ExpectedFailure @("final R16 audit acceptance claim")
        "invalid_closeout_completion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_closeout_completion_claim" -MutationPath '$.current_posture.closeout_completion_claimed' -MutationValue $true -ExpectedFailure @("closeout completion claim")
        "invalid_final_proof_package_completion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_final_proof_package_completion_claim" -MutationPath '$.current_posture.final_proof_package_completion_claimed' -MutationValue $true -ExpectedFailure @("final proof package completion claim")
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
        ValidFixture = (Join-Path $FixtureRoot "valid_friction_metrics_report.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16FrictionMetricsReportObject, New-R16FrictionMetricsReport, Test-R16FrictionMetricsReportObject, Test-R16FrictionMetricsReport, Test-R16FrictionMetricsReportContract, New-R16FrictionMetricsReportFixtureFiles, ConvertTo-StableJson
