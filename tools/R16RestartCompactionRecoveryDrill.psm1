Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:DrillVersion = "v1"
$script:DrillId = "aioffice-r16-022-restart-compaction-recovery-drill-v1"
$script:AggregateVerdict = "passed_bounded_restart_recovery_drill_with_blocked_execution"
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
    "restart_scenario",
    "exact_recovery_inputs",
    "memory_pack_ref",
    "artifact_map_ref",
    "audit_map_ref",
    "artifact_audit_check_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "role_run_envelopes_ref",
    "raci_transition_gate_report_ref",
    "handoff_packet_report_ref",
    "recovery_steps",
    "recovered_posture",
    "blocked_execution_posture",
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
    memory_pack_ref = "state/memory/r16_role_memory_packs.json"
    artifact_map_ref = "state/artifacts/r16_artifact_map.json"
    audit_map_ref = "state/audit/r16_r15_r16_audit_map.json"
    artifact_audit_check_ref = "state/artifacts/r16_artifact_audit_map_check_report.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    role_run_envelopes_ref = "state/workflow/r16_role_run_envelopes.json"
    raci_transition_gate_report_ref = "state/workflow/r16_raci_transition_gate_report.json"
    handoff_packet_report_ref = "state/workflow/r16_handoff_packet_report.json"
    governance_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredRecoveryPaths = [string[]]@(
    "state/memory/r16_role_memory_packs.json",
    "state/artifacts/r16_artifact_map.json",
    "state/audit/r16_r15_r16_audit_map.json",
    "state/artifacts/r16_artifact_audit_map_check_report.json",
    "state/context/r16_context_load_plan.json",
    "state/context/r16_context_budget_estimate.json",
    "state/context/r16_context_budget_guard_report.json",
    "state/workflow/r16_role_run_envelopes.json",
    "state/workflow/r16_raci_transition_gate_report.json",
    "state/workflow/r16_handoff_packet_report.json",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_handoff_packet_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_handoff_packet_generator.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-022 is a bounded restart/compaction recovery drill report only",
    "raw chat history is not canonical state",
    "no full repo scan",
    "no wildcard path expansion",
    "no runtime memory",
    "no runtime memory loading",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous recovery",
    "no autonomous agents",
    "no external integrations",
    "no executable handoffs",
    "no executable transitions",
    "no executable envelopes",
    "no runtime workflow execution",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "guard remains failed_closed_over_budget",
    "no mitigation",
    "R16-023 through R16-026 remain planned only",
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
    wildcard_paths_allowed = "wildcard path claim"
    wildcard_path_expansion_allowed = "wildcard path claim"
    wildcard_path_expansion_performed = "wildcard path claim"
    wildcard_paths_loaded = "wildcard path claim"
    directory_only_refs_allowed = "directory-only ref claim"
    directory_only_paths_allowed = "directory-only ref claim"
    directory_only_refs_loaded = "directory-only ref claim"
    scratch_temp_refs_allowed = "scratch/temp ref claim"
    scratch_temp_paths_allowed = "scratch/temp ref claim"
    scratch_temp_refs_loaded = "scratch/temp ref claim"
    absolute_paths_allowed = "absolute path claim"
    absolute_paths_loaded = "absolute path claim"
    parent_traversal_allowed = "parent traversal path claim"
    parent_traversal_refs_loaded = "parent traversal path claim"
    url_or_remote_refs_allowed = "URL or remote ref claim"
    url_or_remote_refs_loaded = "URL or remote ref claim"
    raw_chat_history_as_canonical_state = "raw chat history as canonical state"
    raw_chat_history_as_canonical_state_used = "raw chat history as canonical state"
    raw_chat_history_canonical_state_used = "raw chat history as canonical state"
    raw_chat_history_as_evidence_allowed = "raw chat history as canonical state"
    raw_chat_history_loading_allowed = "raw chat history as canonical state"
    raw_chat_history_loaded = "raw chat history as canonical state"
    generated_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    report_as_machine_proof_allowed = "report-as-machine-proof misuse"
    generated_report_treated_as_machine_proof = "report-as-machine-proof misuse"
    exact_provider_tokenization_claimed = "exact provider tokenization claim"
    exact_provider_token_count_claimed = "exact provider tokenization claim"
    provider_tokenizer_used = "exact provider tokenization claim"
    exact_provider_billing_claimed = "exact provider billing claim"
    provider_pricing_used = "exact provider billing claim"
    executable_handoffs_exist = "executable handoff claim"
    executable_handoffs_claimed = "executable handoff claim"
    executable_transitions_exist = "executable transition claim"
    executable_transitions_claimed = "executable transition claim"
    executable_envelopes_exist = "executable envelope claim"
    executable_envelopes_claimed = "executable envelope claim"
    transition_execution_permitted = "executable transition claim"
    handoff_execution_permitted = "executable handoff claim"
    mitigation_created = "mitigation claim"
    mitigation_applied = "mitigation claim"
    runtime_memory_claimed = "runtime memory claim"
    runtime_memory_implemented = "runtime memory claim"
    runtime_memory_loading_implemented = "runtime memory claim"
    retrieval_runtime_claimed = "retrieval runtime claim"
    retrieval_runtime_implemented = "retrieval runtime claim"
    vector_search_runtime_claimed = "vector search runtime claim"
    vector_search_runtime_implemented = "vector search runtime claim"
    product_runtime_claimed = "product runtime claim"
    product_runtime_implemented = "product runtime claim"
    autonomous_recovery_claimed = "autonomous recovery claim"
    autonomous_agent_claimed = "autonomous-agent claim"
    autonomous_agents_implemented = "autonomous-agent claim"
    actual_autonomous_agents_implemented = "autonomous-agent claim"
    external_integration_claimed = "external-integration claim"
    external_integrations_implemented = "external-integration claim"
    runtime_workflow_execution_claimed = "runtime workflow execution claim"
    workflow_drill_execution_beyond_this_artifact = "workflow drill execution claim"
    runtime_execution_claimed = "runtime workflow execution claim"
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
    r16_023_complete = "R16-023 complete claim"
    r16_023_implementation_claimed = "R16-023 implementation claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r13_closed = "R13 closure or partial-gate conversion claim"
    r13_closure_claimed = "R13 closure or partial-gate conversion claim"
    r13_partial_gate_conversion_claimed = "R13 closure or partial-gate conversion claim"
    partial_gates_converted_to_passed = "R13 closure or partial-gate conversion claim"
    r14_caveat_removal_claimed = "R14 caveat removal"
    r14_caveats_removed = "R14 caveat removal"
    r15_caveat_removal_claimed = "R15 caveat removal"
    r15_caveats_removed = "R15 caveat removal"
    main_merge_claimed = "main merge claim"
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

    if ($null -eq $Value -or $Value -isnot [pscustomobject]) {
        throw "$Context must be a JSON object."
    }

    return $Value
}

function Assert-StringArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = @($Value)
    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context $Context | Out-Null
    }

    return [string[]]$items
}

function Assert-ObjectArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = @($Value)
    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context $Context | Out-Null
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
            throw "$Context must include '$requiredValue'."
        }
    }
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return ($PathValue -replace '\\', '/').Trim()
}

function Get-RepositoryRoot {
    param([string]$RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        return [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalizedValue -in @(".", "./", "", "/", "\")
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue -match '[\*\?]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalizedValue -match '(^|/)(scratch|temp|tmp)(/|$)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or $PathValue -match '^[^/\\]+@[^/\\]+:'
}

function Test-DirectoryOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    if ($normalizedValue.EndsWith("/")) {
        return $true
    }

    $candidate = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalizedValue))
    return Test-Path -LiteralPath $candidate -PathType Container
}

function Test-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    $null = & git -C $RepositoryRoot ls-files --error-unmatch -- $normalizedValue 2>$null
    return $LASTEXITCODE -eq 0
}

function Assert-SafeRepoRelativeTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    if (Test-BroadRepoRootPath -PathValue $normalizedValue) {
        throw "$Context rejects broad repo root ref '$PathValue'."
    }
    if (Test-WildcardPath -PathValue $normalizedValue) {
        throw "$Context rejects wildcard path '$PathValue'."
    }
    if ([System.IO.Path]::IsPathRooted($normalizedValue)) {
        throw "$Context rejects absolute path '$PathValue'."
    }
    if ($normalizedValue -match '(^|/)\.\.(/|$)') {
        throw "$Context rejects parent traversal path '$PathValue'."
    }
    if (Test-RemoteOrUrlRef -PathValue $normalizedValue) {
        throw "$Context rejects URL or remote ref '$PathValue'."
    }
    if (Test-ScratchTempPath -PathValue $normalizedValue) {
        throw "$Context rejects scratch/temp path '$PathValue'."
    }
    if (Test-DirectoryOnlyPath -PathValue $normalizedValue -RepositoryRoot $RepositoryRoot) {
        throw "$Context rejects directory-only ref '$PathValue'."
    }

    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalizedValue))
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    $resolvedRootWithSeparator = $resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolvedPath.StartsWith($resolvedRootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context required path '$PathValue' does not exist as an exact file."
    }
    if (-not (Test-GitTrackedPath -PathValue $normalizedValue -RepositoryRoot $RepositoryRoot)) {
        throw "$Context required path '$PathValue' is not git-tracked."
    }

    return $normalizedValue
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$InputObject)

    return ($InputObject | ConvertTo-Json -Depth 100)
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($PathValue)
    $parent = Split-Path -Parent $resolvedPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($resolvedPath, (ConvertTo-StableJson -InputObject $InputObject) + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
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
        [Parameter(Mandatory = $true)][int]$DeterministicOrder,
        [hashtable]$Extra = @{}
    )

    $refObject = [ordered]@{
        ref_id = $RefId
        path = $Path
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        machine_proof = $false
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
    }

    foreach ($key in ($Extra.Keys | Sort-Object)) {
        $refObject[$key] = $Extra[$key]
    }

    $refObject["deterministic_order"] = $DeterministicOrder
    return [pscustomobject]$refObject
}

function New-RecoveryInputRefs {
    $refs = @(
        New-RefObject -RefId "memory_pack_ref" -Path $script:RequiredRefPaths.memory_pack_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only; exact recovery input" -DeterministicOrder 1 -Extra @{ input_role = "memory_pack" }
        New-RefObject -RefId "artifact_map_ref" -Path $script:RequiredRefPaths.artifact_map_ref -SourceTask "R16-010" -ProofTreatment "committed generated artifact map state artifact only; exact recovery input" -DeterministicOrder 2 -Extra @{ input_role = "artifact_map" }
        New-RefObject -RefId "audit_map_ref" -Path $script:RequiredRefPaths.audit_map_ref -SourceTask "R16-012" -ProofTreatment "committed generated R15/R16 audit map state artifact only; exact recovery input" -DeterministicOrder 3 -Extra @{ input_role = "audit_map" }
        New-RefObject -RefId "artifact_audit_check_ref" -Path $script:RequiredRefPaths.artifact_audit_check_ref -SourceTask "R16-013" -ProofTreatment "committed generated artifact/audit map check report state artifact only; exact recovery input" -DeterministicOrder 4 -Extra @{ input_role = "artifact_audit_check" }
        New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only; exact recovery input" -DeterministicOrder 5 -Extra @{ input_role = "context_load_plan" }
        New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only; exact recovery input" -DeterministicOrder 6 -Extra @{ input_role = "context_budget_estimate" }
        New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only; exact recovery input" -DeterministicOrder 7 -Extra @{ input_role = "context_budget_guard" }
        New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only; exact recovery input" -DeterministicOrder 8 -Extra @{ input_role = "role_run_envelopes" }
        New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "committed generated RACI transition gate report state artifact only; exact recovery input" -DeterministicOrder 9 -Extra @{ input_role = "raci_transition_gate" }
        New-RefObject -RefId "handoff_packet_report_ref" -Path $script:RequiredRefPaths.handoff_packet_report_ref -SourceTask "R16-021" -ProofTreatment "committed generated handoff packet report state artifact only; exact recovery input" -DeterministicOrder 10 -Extra @{ input_role = "handoff_packet_report" }
        New-RefObject -RefId "governance_ref" -Path $script:RequiredRefPaths.governance_ref -SourceTask "R16-021" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself; exact recovery input" -DeterministicOrder 11 -Extra @{ input_role = "governance_card_state" }
    )

    return [object[]]$refs
}

function New-R16RestartCompactionRecoveryDrillObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($requiredPath in $script:RequiredRecoveryPaths) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $requiredPath -RepositoryRoot $resolvedRoot -Context "R16-022 exact recovery inputs" | Out-Null
    }

    $memoryPacks = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.memory_pack_ref) -Label "R16 role memory packs"
    $artifactMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_map_ref) -Label "R16 artifact map"
    $auditMap = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.audit_map_ref) -Label "R16 audit map"
    $artifactAuditCheck = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.artifact_audit_check_ref) -Label "R16 artifact audit map check report"
    $contextLoadPlan = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_load_plan_ref) -Label "R16 context-load plan"
    $contextBudgetEstimate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_estimate_ref) -Label "R16 context budget estimate"
    $contextBudgetGuard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $handoffPacketReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"
    $governanceText = [System.IO.File]::ReadAllText((Join-Path $resolvedRoot $script:RequiredRefPaths.governance_ref))

    if ([string]$memoryPacks.artifact_type -ne "r16_role_memory_packs") {
        throw "R16-022 recovery drill requires state/memory/r16_role_memory_packs.json."
    }
    if ([string]$artifactMap.artifact_type -ne "r16_artifact_map" -or [string]$auditMap.artifact_type -ne "r16_r15_r16_audit_map" -or [string]$artifactAuditCheck.artifact_type -ne "r16_artifact_audit_map_check_report") {
        throw "R16-022 recovery drill requires the R16 artifact map, audit map, and artifact/audit check report."
    }
    if ([string]$contextLoadPlan.artifact_type -ne "r16_context_load_plan" -or [string]$contextBudgetEstimate.artifact_type -ne "r16_context_budget_estimate" -or [string]$contextBudgetGuard.artifact_type -ne "r16_context_budget_guard_report") {
        throw "R16-022 recovery drill requires the R16 context-load plan, context budget estimate, and context budget guard report."
    }
    if ([string]$contextBudgetGuard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "R16-022 recovery drill requires guard aggregate_verdict $script:GuardVerdict."
    }
    if ([int64]$contextBudgetGuard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "R16-022 recovery drill requires guard threshold $script:ExpectedThreshold."
    }
    if ([string]$roleRunEnvelopes.artifact_type -ne "r16_role_run_envelopes" -or [string]$raciGate.artifact_type -ne "r16_raci_transition_gate_report" -or [string]$handoffPacketReport.artifact_type -ne "r16_handoff_packet_report") {
        throw "R16-022 recovery drill requires role-run envelopes, RACI transition gate report, and handoff packet report."
    }
    if ([string]$raciGate.aggregate_verdict -ne "failed_closed_all_transitions_blocked_by_budget_guard" -or [int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "R16-022 recovery drill requires the R16-020 transition gate to remain failed closed with all transitions blocked."
    }
    if ([int64]$handoffPacketReport.blocked_handoff_count -ne 4 -or [int64]$handoffPacketReport.executable_handoff_count -ne 0) {
        throw "R16-022 recovery drill requires all R16-021 handoff packets blocked and zero executable handoffs."
    }
    if ($governanceText -notmatch "R16-021" -or $governanceText -notmatch "R16-022") {
        throw "R16-022 recovery drill requires the R16 governance card-state authority file."
    }

    $envelopes = @($roleRunEnvelopes.envelopes)
    $executableEnvelopeCount = @($envelopes | Where-Object { [bool]$_.executable }).Count
    $blockedEnvelopeCount = @($envelopes | Where-Object { [string]$_.envelope_execution_status -eq "blocked" -and -not [bool]$_.executable }).Count
    $upperBound = [int64]$contextBudgetGuard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$contextBudgetGuard.evaluated_budget.max_estimated_tokens_upper_bound
    $recoveryInputs = New-RecoveryInputRefs

    return [pscustomobject][ordered]@{
        artifact_type = "r16_restart_compaction_recovery_drill"
        drill_version = $script:DrillVersion
        drill_id = $script:DrillId
        source_milestone = $script:R16Milestone
        source_task = "R16-022"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = "R16-022A implementation pass creates a bounded artifact-only restart/compaction recovery drill report from exact repo-backed inputs; it does not claim solved Codex compaction, solved Codex reliability, runtime memory, retrieval/vector runtime, product runtime, autonomous recovery, executable handoffs, executable transitions, external integrations, or main merge."
        restart_scenario = [pscustomobject][ordered]@{
            scenario_id = "r16-022-compacted-or-interrupted-codex-context"
            scenario_summary = "Future operator or Codex session resumes with compacted/interrupted conversation context and uses exact repo-backed evidence instead of raw chat history as canonical state."
            compacted_or_interrupted_context_simulated = $true
            exact_repo_backed_inputs_only = $true
            raw_chat_history_as_canonical_state = $false
            raw_chat_history_loaded = $false
            full_repo_scan_performed = $false
            broad_repo_scan_performed = $false
            wildcard_path_expansion_performed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            deterministic_order = 1
        }
        exact_recovery_inputs = [object[]]$recoveryInputs
        memory_pack_ref = $recoveryInputs[0]
        artifact_map_ref = $recoveryInputs[1]
        audit_map_ref = $recoveryInputs[2]
        artifact_audit_check_ref = $recoveryInputs[3]
        context_load_plan_ref = $recoveryInputs[4]
        context_budget_estimate_ref = $recoveryInputs[5]
        context_budget_guard_ref = $recoveryInputs[6]
        role_run_envelopes_ref = $recoveryInputs[7]
        raci_transition_gate_report_ref = $recoveryInputs[8]
        handoff_packet_report_ref = $recoveryInputs[9]
        recovery_evidence_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_recovery_input_count = $script:RequiredRecoveryPaths.Count
            required_recovery_paths = [string[]]$script:RequiredRecoveryPaths
            generated_reports_as_machine_proof_allowed = $false
            report_as_machine_proof_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            deterministic_order = 1
        }
        recovery_steps = [object[]]@(
            [pscustomobject][ordered]@{
                step_id = "recovery_step_001"
                action = "Load only the exact recovery input list from the drill packet."
                input_ref_ids = [string[]]@("memory_pack_ref", "artifact_map_ref", "audit_map_ref", "artifact_audit_check_ref", "context_load_plan_ref", "context_budget_estimate_ref", "context_budget_guard_ref", "role_run_envelopes_ref", "raci_transition_gate_report_ref", "handoff_packet_report_ref", "governance_ref")
                recovery_result = "Exact repo-relative tracked input set identified without raw chat history and without broad or full repo scan."
                deterministic_order = 1
            },
            [pscustomobject][ordered]@{
                step_id = "recovery_step_002"
                action = "Read memory pack, artifact map, audit map, and artifact/audit check refs to recover the evidence map."
                input_ref_ids = [string[]]@("memory_pack_ref", "artifact_map_ref", "audit_map_ref", "artifact_audit_check_ref")
                recovery_result = "Evidence refs and inspection surfaces are recovered from committed state artifacts only."
                deterministic_order = 2
            },
            [pscustomobject][ordered]@{
                step_id = "recovery_step_003"
                action = "Read context-load plan, context budget estimate, and context budget guard refs."
                input_ref_ids = [string[]]@("context_load_plan_ref", "context_budget_estimate_ref", "context_budget_guard_ref")
                recovery_result = "Guard posture recovered as failed_closed_over_budget with threshold 150000 and no mitigation."
                deterministic_order = 3
            },
            [pscustomobject][ordered]@{
                step_id = "recovery_step_004"
                action = "Read role-run envelopes, RACI transition gate report, and handoff packet report refs."
                input_ref_ids = [string[]]@("role_run_envelopes_ref", "raci_transition_gate_report_ref", "handoff_packet_report_ref")
                recovery_result = "Role envelopes remain non-executable, transitions remain blocked, and handoff packets remain blocked/not executable."
                deterministic_order = 4
            },
            [pscustomobject][ordered]@{
                step_id = "recovery_step_005"
                action = "Read governance card-state authority as a boundary source, then record the drill posture."
                input_ref_ids = [string[]]@("governance_ref")
                recovery_result = "R16 is identified as active through R16-022 in this drill report only; R16-023 through R16-026 remain planned only."
                deterministic_order = 5
            }
        )
        recovered_posture = [pscustomobject][ordered]@{
            current_r16_posture_identified = $true
            active_through_task = "R16-022"
            active_through_scope = "bounded restart/compaction recovery drill report only"
            completed_tasks = [string[]]@("R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006", "R16-007", "R16-008", "R16-009", "R16-010", "R16-011", "R16-012", "R16-013", "R16-014", "R16-015", "R16-016", "R16-017", "R16-018", "R16-019", "R16-020", "R16-021", "R16-022")
            planned_tasks = [string[]]@("R16-023", "R16-024", "R16-025", "R16-026")
            r16_023_complete = $false
            r16_023_through_r16_026_planned_only = $true
            guard_verdict = $script:GuardVerdict
            handoff_packets_blocked = $true
            handoff_packets_executable = $false
            raw_chat_history_as_canonical_state_used = $false
            full_repo_scan_used = $false
            workflow_drill_execution_beyond_this_artifact = $false
            deterministic_order = 1
        }
        blocked_execution_posture = [pscustomobject][ordered]@{
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            max_estimated_tokens_upper_bound = $threshold
            threshold = $threshold
            threshold_exceeded = $true
            no_mitigation = $true
            mitigation_created = $false
            executable_envelope_count = $executableEnvelopeCount
            blocked_envelope_count = $blockedEnvelopeCount
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            blocked_handoff_count = [int64]$handoffPacketReport.blocked_handoff_count
            executable_handoff_count = [int64]$handoffPacketReport.executable_handoff_count
            executable_envelopes_exist = $false
            executable_transitions_exist = $false
            executable_handoffs_exist = $false
            no_executable_envelopes = $true
            no_executable_transitions = $true
            no_executable_handoffs = $true
            runtime_execution_claimed = $false
            deterministic_order = 1
        }
        no_full_repo_scan_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_recovery_inputs_only = $true
            exact_dependency_refs_only = $true
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
            canonical_state_source = "exact_repo_backed_artifacts_only"
            raw_chat_history_as_canonical_state = $false
            raw_chat_history_loaded = $false
            raw_chat_history_loading_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            raw_chat_history_may_be_human_context_but_not_authority = $true
            deterministic_order = 1
        }
        finding_summary = [pscustomobject][ordered]@{
            exact_recovery_input_count = $script:RequiredRecoveryPaths.Count
            exact_recovery_inputs_are_repo_relative = $true
            exact_recovery_inputs_are_tracked_files = $true
            active_through_task_identified = "R16-022"
            active_through_scope = "bounded restart/compaction recovery drill report only"
            planned_task_start = "R16-023"
            planned_task_end = "R16-026"
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            max_estimated_tokens_upper_bound = $threshold
            threshold = $threshold
            no_mitigation = $true
            role_run_envelope_count = $envelopes.Count
            executable_envelope_count = $executableEnvelopeCount
            blocked_envelope_count = $blockedEnvelopeCount
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            blocked_handoff_count = [int64]$handoffPacketReport.blocked_handoff_count
            executable_handoff_count = [int64]$handoffPacketReport.executable_handoff_count
            handoff_packets_remain_blocked_not_executable = $true
            raw_chat_history_canonical_state_used = $false
            full_repo_scan_used = $false
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
        validation_commands = [object[]]@(
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[0]; deterministic_order = 1 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[1]; deterministic_order = 2 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[2]; deterministic_order = 3 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[3]; deterministic_order = 4 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[4]; deterministic_order = 5 }
        )
        current_posture = [pscustomobject][ordered]@{
            active_through_task = "R16-022"
            active_through_scope = "R16-022 bounded restart/compaction recovery drill report only"
            previous_accepted_task = "R16-021"
            r16_022_report_only = $true
            r16_023_through_r16_026_planned_only = $true
            planned_tasks = [string[]]@("R16-023", "R16-024", "R16-025", "R16-026")
            guard_verdict = $script:GuardVerdict
            handoff_packets_blocked = $true
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            workflow_drill_execution_beyond_this_artifact = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            autonomous_recovery_claimed = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            r16_023_implementation_claimed = $false
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

function Assert-RefObject {
    param(
        [AllowNull()]$RefObject,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ExpectedPath,
        [string]$ExpectedRefId
    )

    $ref = Assert-ObjectValue -Value $RefObject -Context $Context
    foreach ($fieldName in @("ref_id", "path", "source_task", "proof_treatment", "machine_proof", "exact_path_only", "broad_scan_allowed", "wildcard_allowed", "deterministic_order")) {
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
        throw "$Context exact_path_only must be True."
    }
    if ((Assert-BooleanValue -Value $ref.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $ref.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }

    return $ref
}

function Assert-NoFullRepoScanPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @("repo_relative_exact_paths_only", "tracked_files_only", "exact_recovery_inputs_only", "exact_dependency_refs_only", "no_wildcard_path_expansion")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_path_expansion_performed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }
}

function Assert-RawChatHistoryPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    if ([string](Get-RequiredProperty -InputObject $policyObject -Name "canonical_state_source" -Context $Context) -ne "exact_repo_backed_artifacts_only") {
        throw "$Context canonical_state_source must be exact_repo_backed_artifacts_only."
    }
    foreach ($falseField in @("raw_chat_history_as_canonical_state", "raw_chat_history_loaded", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context rejects raw chat history as canonical state."
        }
    }
}

function Assert-RecoveredPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string](Get-RequiredProperty -InputObject $postureObject -Name "active_through_task" -Context $Context) -ne "R16-022") {
        throw "$Context must identify active_through_task R16-022."
    }
    $completedTasks = Assert-StringArray -Value (Get-RequiredProperty -InputObject $postureObject -Name "completed_tasks" -Context $Context) -Context "$Context completed_tasks"
    if ($completedTasks -contains "R16-023") {
        throw "$Context rejects R16-023 complete claim."
    }
    if ($completedTasks[-1] -ne "R16-022") {
        throw "$Context completed_tasks must stop at R16-022."
    }
    $plannedTasks = Assert-StringArray -Value (Get-RequiredProperty -InputObject $postureObject -Name "planned_tasks" -Context $Context) -Context "$Context planned_tasks"
    if (($plannedTasks -join ",") -ne "R16-023,R16-024,R16-025,R16-026") {
        throw "$Context must keep R16-023 through R16-026 planned only."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name "r16_023_complete" -Context $Context) -Context "$Context r16_023_complete") -ne $false) {
        throw "$Context rejects R16-023 complete claim."
    }
    if ([string](Get-RequiredProperty -InputObject $postureObject -Name "guard_verdict" -Context $Context) -ne $script:GuardVerdict) {
        throw "$Context must preserve guard verdict $script:GuardVerdict."
    }
}

function Assert-BlockedExecutionPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)]$RaciGate,
        [Parameter(Mandatory = $true)]$HandoffReport
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string]$postureObject.guard_verdict -ne $script:GuardVerdict) {
        throw "$Context must preserve guard verdict $script:GuardVerdict."
    }
    if ([int64]$postureObject.estimated_tokens_upper_bound -ne [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$postureObject.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold -or [int64]$postureObject.threshold -ne $script:ExpectedThreshold) {
        throw "$Context must preserve guard upper bound and threshold."
    }
    if ((Assert-BooleanValue -Value $postureObject.no_mitigation -Context "$Context no_mitigation") -ne $true -or (Assert-BooleanValue -Value $postureObject.mitigation_created -Context "$Context mitigation_created") -ne $false) {
        throw "$Context must preserve no mitigation."
    }
    if ([int64]$postureObject.executable_envelope_count -ne 0) {
        throw "$Context must preserve no executable envelopes."
    }
    if ([int64]$postureObject.allowed_transition_count -ne [int64]$RaciGate.allowed_transition_count -or [int64]$postureObject.allowed_transition_count -ne 0) {
        throw "$Context must preserve no executable transitions."
    }
    if ([int64]$postureObject.blocked_transition_count -ne [int64]$RaciGate.blocked_transition_count -or [int64]$postureObject.blocked_transition_count -ne 4) {
        throw "$Context must preserve four blocked transitions."
    }
    if ([int64]$postureObject.blocked_handoff_count -ne [int64]$HandoffReport.blocked_handoff_count -or [int64]$postureObject.blocked_handoff_count -ne 4) {
        throw "$Context must preserve four blocked handoffs."
    }
    if ([int64]$postureObject.executable_handoff_count -ne [int64]$HandoffReport.executable_handoff_count -or [int64]$postureObject.executable_handoff_count -ne 0) {
        throw "$Context must preserve no executable handoffs."
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string]$postureObject.active_through_task -ne "R16-022") {
        throw "$Context active_through_task must be R16-022."
    }
    if ([string]$postureObject.previous_accepted_task -ne "R16-021") {
        throw "$Context previous_accepted_task must be R16-021."
    }
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    if (($plannedTasks -join ",") -ne "R16-023,R16-024,R16-025,R16-026") {
        throw "$Context must keep R16-023 through R16-026 planned only."
    }
    foreach ($falseField in @("executable_handoffs_exist", "executable_transitions_exist", "workflow_drill_execution_beyond_this_artifact", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "autonomous_recovery_claimed", "actual_autonomous_agents_implemented", "external_integrations_implemented", "r16_023_implementation_claimed", "r16_027_or_later_task_exists", "main_merge_claimed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r13" -Context $Context) -Context "$Context r13"
    if ((Assert-BooleanValue -Value $r13.closed -Context "$Context r13.closed") -ne $false -or (Assert-BooleanValue -Value $r13.partial_gates_converted_to_passed -Context "$Context r13.partial_gates_converted_to_passed") -ne $false) {
        throw "$Context rejects R13 closure or partial-gate conversion claim."
    }
    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    if ((Assert-BooleanValue -Value $r14.caveats_removed -Context "$Context r14.caveats_removed") -ne $false) {
        throw "$Context rejects R14 caveat removal."
    }
    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$Context r15.caveats_removed") -ne $false) {
        throw "$Context rejects R15 caveat removal."
    }
}

function Test-R16RestartCompactionRecoveryDrillObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 restart/compaction recovery drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-ObjectValue -Value $Report -Context $SourceLabel | Out-Null
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Report -RepositoryRoot $resolvedRoot -Context $SourceLabel

    if ([string]$Report.artifact_type -ne "r16_restart_compaction_recovery_drill" -or [string]$Report.drill_version -ne $script:DrillVersion -or [string]$Report.drill_id -ne $script:DrillId -or [string]$Report.source_task -ne "R16-022") {
        throw "$SourceLabel identity fields are incorrect for R16-022."
    }
    if ([string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }

    Assert-RefObject -RefObject $Report.memory_pack_ref -Context "$SourceLabel memory_pack_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.memory_pack_ref -ExpectedRefId "memory_pack_ref" | Out-Null
    Assert-RefObject -RefObject $Report.artifact_map_ref -Context "$SourceLabel artifact_map_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.artifact_map_ref -ExpectedRefId "artifact_map_ref" | Out-Null
    Assert-RefObject -RefObject $Report.audit_map_ref -Context "$SourceLabel audit_map_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.audit_map_ref -ExpectedRefId "audit_map_ref" | Out-Null
    Assert-RefObject -RefObject $Report.artifact_audit_check_ref -Context "$SourceLabel artifact_audit_check_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.artifact_audit_check_ref -ExpectedRefId "artifact_audit_check_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_run_envelopes_ref -Context "$SourceLabel role_run_envelopes_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "role_run_envelopes_ref" | Out-Null
    Assert-RefObject -RefObject $Report.raci_transition_gate_report_ref -Context "$SourceLabel raci_transition_gate_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "raci_transition_gate_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.handoff_packet_report_ref -Context "$SourceLabel handoff_packet_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.handoff_packet_report_ref -ExpectedRefId "handoff_packet_report_ref" | Out-Null

    $exactInputs = @(Assert-ObjectArray -Value $Report.exact_recovery_inputs -Context "$SourceLabel exact_recovery_inputs")
    if ($exactInputs.Count -ne $script:RequiredRecoveryPaths.Count) {
        throw "$SourceLabel exact_recovery_inputs must contain $($script:RequiredRecoveryPaths.Count) refs."
    }
    for ($index = 0; $index -lt $script:RequiredRecoveryPaths.Count; $index += 1) {
        $ref = Assert-RefObject -RefObject $exactInputs[$index] -Context "$SourceLabel exact_recovery_inputs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRecoveryPaths[$index]
        if ([int64]$ref.deterministic_order -ne ($index + 1)) {
            throw "$SourceLabel exact_recovery_inputs must be deterministic."
        }
    }

    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $handoffReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"

    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "$SourceLabel requires guard failed_closed_over_budget with threshold $script:ExpectedThreshold."
    }
    if ([int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "$SourceLabel requires all transitions blocked."
    }
    if ([int64]$handoffReport.blocked_handoff_count -ne 4 -or [int64]$handoffReport.executable_handoff_count -ne 0) {
        throw "$SourceLabel requires handoff packets blocked/not executable."
    }

    Assert-NoFullRepoScanPolicy -Policy $Report.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    Assert-RawChatHistoryPolicy -Policy $Report.raw_chat_history_policy -Context "$SourceLabel raw_chat_history_policy"
    Assert-RecoveredPosture -Posture $Report.recovered_posture -Context "$SourceLabel recovered_posture"
    Assert-BlockedExecutionPosture -Posture $Report.blocked_execution_posture -Context "$SourceLabel blocked_execution_posture" -Guard $guard -RaciGate $raciGate -HandoffReport $handoffReport
    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $evidencePolicy = Assert-ObjectValue -Value $Report.recovery_evidence_policy -Context "$SourceLabel recovery_evidence_policy"
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name "required_recovery_paths" -Context "$SourceLabel recovery_evidence_policy") -Context "$SourceLabel recovery_evidence_policy required_recovery_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredRecoveryPaths -Context "$SourceLabel recovery_evidence_policy required_recovery_paths"
    if ((Assert-BooleanValue -Value $evidencePolicy.generated_reports_as_machine_proof_allowed -Context "$SourceLabel recovery_evidence_policy generated_reports_as_machine_proof_allowed") -ne $false) {
        throw "$SourceLabel rejects report-as-machine-proof misuse."
    }

    $summary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$summary.exact_recovery_input_count -ne $script:RequiredRecoveryPaths.Count) {
        throw "$SourceLabel finding_summary must record exact recovery input count $($script:RequiredRecoveryPaths.Count)."
    }
    if ([string]$summary.guard_verdict -ne $script:GuardVerdict -or [int64]$summary.estimated_tokens_upper_bound -ne [int64]$guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$summary.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel finding_summary must preserve failed_closed_over_budget guard values."
    }
    if ([int64]$summary.executable_handoff_count -ne 0 -or [int64]$summary.blocked_handoff_count -ne 4 -or [int64]$summary.allowed_transition_count -ne 0) {
        throw "$SourceLabel finding_summary must preserve blocked execution posture."
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
        ExactRecoveryInputCount = $exactInputs.Count
        AggregateVerdict = [string]$Report.aggregate_verdict
        GuardVerdict = [string]$guard.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
        Threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
        BlockedHandoffCount = [int64]$handoffReport.blocked_handoff_count
        ExecutableHandoffCount = [int64]$handoffReport.executable_handoff_count
    }
}

function Test-R16RestartCompactionRecoveryDrill {
    [CmdletBinding()]
    param(
        [string]$Path = "state/workflow/r16_restart_compaction_recovery_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 restart/compaction recovery drill"
    return Test-R16RestartCompactionRecoveryDrillObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16RestartCompactionRecoveryDrill {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/workflow/r16_restart_compaction_recovery_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16RestartCompactionRecoveryDrillObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $report -PathValue $resolvedOutput
    $validation = Test-R16RestartCompactionRecoveryDrill -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        DrillId = $validation.DrillId
        ExactRecoveryInputCount = $validation.ExactRecoveryInputCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        GuardVerdict = $validation.GuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        Threshold = $validation.Threshold
        BlockedHandoffCount = $validation.BlockedHandoffCount
        ExecutableHandoffCount = $validation.ExecutableHandoffCount
    }
}

function Test-R16RestartCompactionRecoveryDrillContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/workflow/r16_restart_compaction_recovery_drill.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 restart/compaction recovery drill contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "restart_compaction_recovery_drill_contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "recovery_policy", "no_full_repo_scan_policy", "raw_chat_history_policy", "blocked_execution_policy", "non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 restart/compaction recovery drill contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_restart_compaction_recovery_drill_contract" -or [string]$contract.source_task -ne "R16-022") {
        throw "R16 restart/compaction recovery drill contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 restart/compaction recovery drill contract"
    Assert-AllPathFieldsAreSafe -Value $contract -RepositoryRoot $resolvedRoot -Context "R16 restart/compaction recovery drill contract"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 restart/compaction recovery drill contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 restart/compaction recovery drill contract required_report_fields"
    $dependencyRefs = @(Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 restart/compaction recovery drill contract dependency_refs")
    if ($dependencyRefs.Count -ne $script:RequiredRecoveryPaths.Count) {
        throw "R16 restart/compaction recovery drill contract dependency_refs must include exactly $($script:RequiredRecoveryPaths.Count) recovery inputs."
    }
    $dependencyPaths = @()
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        $dependencyRef = Assert-RefObject -RefObject $dependencyRefs[$index] -Context "R16 restart/compaction recovery drill contract dependency_refs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRecoveryPaths[$index]
        $dependencyPaths += ConvertTo-NormalizedRepoPath -PathValue ([string]$dependencyRef.path)
    }
    Assert-RequiredStringsPresent -Actual ([string[]]$dependencyPaths) -Required $script:RequiredRecoveryPaths -Context "R16 restart/compaction recovery drill contract dependency_refs path"
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 restart/compaction recovery drill contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 restart/compaction recovery drill contract non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.restart_compaction_recovery_drill_contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16RestartCompactionRecoveryDrillFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_restart_compaction_recovery_drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16RestartCompactionRecoveryDrillObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validReport -PathValue (Join-Path $fixtureRootPath "valid_restart_compaction_recovery_drill.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_restart_compaction_recovery_drill.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.restart_scenario' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'restart_scenario'")
        "invalid_missing_memory_pack_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_memory_pack_ref" -MutationPath '$.memory_pack_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'memory_pack_ref'")
        "invalid_missing_artifact_map_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_artifact_map_ref" -MutationPath '$.artifact_map_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'artifact_map_ref'")
        "invalid_missing_audit_map_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_audit_map_ref" -MutationPath '$.audit_map_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'audit_map_ref'")
        "invalid_missing_context_load_plan_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_load_plan_ref" -MutationPath '$.context_load_plan_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_load_plan_ref'")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_role_run_envelopes_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_run_envelopes_ref" -MutationPath '$.role_run_envelopes_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_raci_transition_gate_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_raci_transition_gate_report_ref" -MutationPath '$.raci_transition_gate_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'raci_transition_gate_report_ref'")
        "invalid_missing_handoff_packet_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_handoff_packet_report_ref" -MutationPath '$.handoff_packet_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'handoff_packet_report_ref'")
        "invalid_recovered_posture_r16_023_complete.json" = New-MutationFixtureSpec -FixtureId "invalid_recovered_posture_r16_023_complete" -MutationPath '$.recovered_posture.r16_023_complete' -MutationValue $true -ExpectedFailure @("R16-023 complete claim")
        "invalid_raw_chat_history_canonical_state.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_canonical_state" -MutationPath '$.raw_chat_history_policy.raw_chat_history_as_canonical_state' -MutationValue $true -ExpectedFailure @("raw chat history as canonical state")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "state/memory/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "state/memory/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "scratch/r16_restart_compaction_recovery_drill.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "C:/tmp/r16_restart_compaction_recovery_drill.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "../state/memory/r16_role_memory_packs.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.exact_recovery_inputs[0].path' -MutationValue "https://example.invalid/r16_role_memory_packs.json" -ExpectedFailure @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.recovery_evidence_policy.generated_reports_as_machine_proof_allowed' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.restart_scenario.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.restart_scenario.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_executable_handoff_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_handoff_claim" -MutationPath '$.blocked_execution_posture.executable_handoffs_exist' -MutationValue $true -ExpectedFailure @("executable handoff claim")
        "invalid_executable_transition_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_transition_claim" -MutationPath '$.blocked_execution_posture.executable_transitions_exist' -MutationValue $true -ExpectedFailure @("executable transition claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.restart_scenario.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.restart_scenario.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.restart_scenario.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.restart_scenario.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.restart_scenario.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.restart_scenario.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_compaction_claim" -MutationPath '$.restart_scenario.solved_codex_compaction' -MutationValue $true -ExpectedFailure @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_reliability_claim" -MutationPath '$.restart_scenario.solved_codex_reliability' -MutationValue $true -ExpectedFailure @("solved Codex reliability claim")
        "invalid_r16_023_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_023_implementation_claim" -MutationPath '$.current_posture.r16_023_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-023 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_027_or_later_task_claim" -MutationPath '$.current_posture.r16_027_or_later_task_exists' -MutationValue $true -ExpectedFailure @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_closure_or_partial_gate_conversion_claim" -MutationPath '$.preserved_boundaries.r13.closed' -MutationValue $true -ExpectedFailure @("R13 closure or partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r14_caveat_removal" -MutationPath '$.preserved_boundaries.r14.caveats_removed' -MutationValue $true -ExpectedFailure @("R14 caveat removal")
        "invalid_r15_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r15_caveat_removal" -MutationPath '$.preserved_boundaries.r15.caveats_removed' -MutationValue $true -ExpectedFailure @("R15 caveat removal")
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        Write-StableJsonFile -InputObject $fixtureSpecs[$fixtureName] -PathValue (Join-Path $fixtureRootPath $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_restart_compaction_recovery_drill.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16RestartCompactionRecoveryDrillObject, New-R16RestartCompactionRecoveryDrill, Test-R16RestartCompactionRecoveryDrillObject, Test-R16RestartCompactionRecoveryDrill, Test-R16RestartCompactionRecoveryDrillContract, New-R16RestartCompactionRecoveryDrillFixtureFiles, ConvertTo-StableJson
