Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:DrillVersion = "v1"
$script:DrillId = "aioffice-r16-023-role-handoff-drill-v1"
$script:AggregateVerdict = "passed_bounded_role_handoff_drill_with_all_handoffs_blocked"
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
    "role_handoff_chain",
    "handoff_packet_report_ref",
    "restart_compaction_recovery_drill_ref",
    "raci_transition_gate_report_ref",
    "role_run_envelopes_ref",
    "context_budget_guard_ref",
    "context_budget_estimate_ref",
    "context_load_plan_ref",
    "role_memory_packs_ref",
    "card_state_ref",
    "drill_steps",
    "evaluated_handoffs",
    "blocked_handoff_count",
    "executable_handoff_count",
    "executable_transition_count",
    "role_chain_summary",
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
    handoff_packet_report_ref = "state/workflow/r16_handoff_packet_report.json"
    restart_compaction_recovery_drill_ref = "state/workflow/r16_restart_compaction_recovery_drill.json"
    raci_transition_gate_report_ref = "state/workflow/r16_raci_transition_gate_report.json"
    role_run_envelopes_ref = "state/workflow/r16_role_run_envelopes.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    role_memory_packs_ref = "state/memory/r16_role_memory_packs.json"
    card_state_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredInputPaths = [string[]]@(
    "state/workflow/r16_handoff_packet_report.json",
    "state/workflow/r16_restart_compaction_recovery_drill.json",
    "state/workflow/r16_raci_transition_gate_report.json",
    "state/workflow/r16_role_run_envelopes.json",
    "state/context/r16_context_budget_guard_report.json",
    "state/context/r16_context_budget_estimate.json",
    "state/context/r16_context_load_plan.json",
    "state/memory/r16_role_memory_packs.json",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_handoff_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_restart_compaction_recovery_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_handoff_packet_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_handoff_packet_generator.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-023 is a bounded role-handoff drill report only",
    "role handoff chain inspection uses generated handoff packets only",
    "raw chat history is not canonical state",
    "no full repo scan",
    "no wildcard path expansion",
    "guard remains failed_closed_over_budget",
    "no mitigation",
    "no executable handoffs",
    "no executable transitions",
    "no executable envelopes",
    "no runtime handoff execution",
    "no workflow drill execution beyond this bounded report artifact",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous recovery",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R16-024 through R16-026 remain planned only",
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
    handoff_executable = "handoff marked executable"
    executable = "handoff marked executable"
    executable_handoffs_exist = "executable handoff claim"
    executable_handoffs_claimed = "executable handoff claim"
    executable_transitions_exist = "executable transition claim"
    executable_transitions_claimed = "executable transition claim"
    executable_envelopes_exist = "executable envelope claim"
    executable_envelopes_claimed = "executable envelope claim"
    transition_execution_permitted = "transition marked executable"
    handoff_execution_permitted = "handoff marked executable"
    mitigation_created = "mitigation claim"
    mitigation_applied = "mitigation claim"
    runtime_handoff_execution_claimed = "runtime handoff execution claim"
    runtime_handoff_execution_performed = "runtime handoff execution claim"
    handoff_runtime_execution_claimed = "runtime handoff execution claim"
    handoff_execution_performed = "runtime handoff execution claim"
    runtime_execution_claimed = "runtime handoff execution claim"
    runtime_execution_performed = "runtime handoff execution claim"
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
    workflow_drill_run = "workflow drill execution claim beyond this report artifact"
    workflow_drill_implemented = "workflow drill execution claim beyond this report artifact"
    workflow_drill_execution_beyond_this_report_artifact = "workflow drill execution claim beyond this report artifact"
    workflow_drill_execution_beyond_this_artifact = "workflow drill execution claim beyond this report artifact"
    runtime_workflow_execution_claimed = "workflow drill execution claim beyond this report artifact"
    r16_024_implementation_claimed = "R16-024 implementation claim"
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
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
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

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
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
                throw "$Context contains forbidden $($script:ForbiddenTrueBooleanClaims[$propertyName])."
            }

            Assert-NoForbiddenTrueClaims -Value $property.Value -Context $Context
        }
    }
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
            $propertyValue = $property.Value
            $isPathProperty = $propertyName -eq "path" -or $propertyName -like "*_path" -or $propertyName -like "*_paths"
            if ($isPathProperty) {
                if ($propertyValue -is [System.Array]) {
                    foreach ($pathItem in @($propertyValue)) {
                        Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$pathItem) -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName" | Out-Null
                    }
                }
                else {
                    Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$propertyValue) -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName" | Out-Null
                }
            }
            else {
                Assert-AllPathFieldsAreSafe -Value $propertyValue -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName"
            }
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

function New-RoleHandoffInputRefs {
    return [object[]]@(
        New-RefObject -RefId "handoff_packet_report_ref" -Path $script:RequiredRefPaths.handoff_packet_report_ref -SourceTask "R16-021" -ProofTreatment "committed generated handoff packet report state artifact only; exact role-handoff drill input" -DeterministicOrder 1 -Extra @{ input_role = "handoff_packet_report" }
        New-RefObject -RefId "restart_compaction_recovery_drill_ref" -Path $script:RequiredRefPaths.restart_compaction_recovery_drill_ref -SourceTask "R16-022" -ProofTreatment "committed generated restart/compaction recovery drill state artifact only; exact role-handoff drill input" -DeterministicOrder 2 -Extra @{ input_role = "restart_compaction_recovery_drill" }
        New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "committed generated RACI transition gate report state artifact only; exact role-handoff drill input" -DeterministicOrder 3 -Extra @{ input_role = "raci_transition_gate" }
        New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only; exact role-handoff drill input" -DeterministicOrder 4 -Extra @{ input_role = "role_run_envelopes" }
        New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only; exact role-handoff drill input" -DeterministicOrder 5 -Extra @{ input_role = "context_budget_guard" }
        New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only; exact role-handoff drill input" -DeterministicOrder 6 -Extra @{ input_role = "context_budget_estimate" }
        New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only; exact role-handoff drill input" -DeterministicOrder 7 -Extra @{ input_role = "context_load_plan" }
        New-RefObject -RefId "role_memory_packs_ref" -Path $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only; exact role-handoff drill input" -DeterministicOrder 8 -Extra @{ input_role = "role_memory_packs" }
        New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-022" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself; exact role-handoff drill input" -DeterministicOrder 9 -Extra @{ input_role = "governance_card_state" }
    )
}

function New-CoreRoleHandoffChain {
    return [object[]]@(
        [pscustomobject][ordered]@{
            chain_step_id = "r16-023-role-handoff-chain-001-project_manager-to-developer"
            source_role_id = "project_manager"
            target_role_id = "developer"
            required_core_handoff = $true
            handoff_packet_required = $true
            runtime_execution_permitted = $false
            deterministic_order = 1
        },
        [pscustomobject][ordered]@{
            chain_step_id = "r16-023-role-handoff-chain-002-developer-to-qa"
            source_role_id = "developer"
            target_role_id = "qa"
            required_core_handoff = $true
            handoff_packet_required = $true
            runtime_execution_permitted = $false
            deterministic_order = 2
        },
        [pscustomobject][ordered]@{
            chain_step_id = "r16-023-role-handoff-chain-003-qa-to-evidence_auditor"
            source_role_id = "qa"
            target_role_id = "evidence_auditor"
            required_core_handoff = $true
            handoff_packet_required = $true
            runtime_execution_permitted = $false
            deterministic_order = 3
        }
    )
}

function Get-HandoffPacketByRoles {
    param(
        [Parameter(Mandatory = $true)][object[]]$Packets,
        [Parameter(Mandatory = $true)][string]$SourceRoleId,
        [Parameter(Mandatory = $true)][string]$TargetRoleId
    )

    $matches = @($Packets | Where-Object { [string]$_.source_role_id -eq $SourceRoleId -and [string]$_.target_role_id -eq $TargetRoleId })
    if ($matches.Count -ne 1) {
        throw "R16-023 role handoff drill requires exactly one generated handoff packet for $SourceRoleId -> $TargetRoleId."
    }

    return $matches[0]
}

function Get-TransitionByRoles {
    param(
        [Parameter(Mandatory = $true)][object[]]$Transitions,
        [Parameter(Mandatory = $true)][string]$SourceRoleId,
        [Parameter(Mandatory = $true)][string]$TargetRoleId
    )

    $matches = @($Transitions | Where-Object { [string]$_.source_role_id -eq $SourceRoleId -and [string]$_.target_role_id -eq $TargetRoleId })
    if ($matches.Count -ne 1) {
        throw "R16-023 role handoff drill requires exactly one R16-020 transition for $SourceRoleId -> $TargetRoleId."
    }

    return $matches[0]
}

function New-EvaluatedRoleHandoff {
    param(
        [Parameter(Mandatory = $true)]$ChainStep,
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)]$Transition,
        [Parameter(Mandatory = $true)]$Guard
    )

    $order = [int]$ChainStep.deterministic_order
    $upperBound = [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$Guard.evaluated_budget.max_estimated_tokens_upper_bound

    return [pscustomobject][ordered]@{
        evaluated_handoff_id = ("r16-023-evaluated-handoff-{0:D3}-{1}-to-{2}" -f $order, [string]$ChainStep.source_role_id, [string]$ChainStep.target_role_id)
        source_role_id = [string]$ChainStep.source_role_id
        target_role_id = [string]$ChainStep.target_role_id
        action_type = [string]$Packet.action_type
        handoff_packet_id = [string]$Packet.handoff_packet_id
        handoff_packet_ref = New-RefObject -RefId "handoff_packet_report_ref" -Path $script:RequiredRefPaths.handoff_packet_report_ref -SourceTask "R16-021" -ProofTreatment "generated handoff packet inspected from R16-021 report; state artifact only" -DeterministicOrder 1 -Extra @{ handoff_packet_id = [string]$Packet.handoff_packet_id }
        transition_id = [string]$Transition.transition_id
        transition_gate_ref = New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "R16-020 RACI transition gate decision inspected; state artifact only" -DeterministicOrder 2 -Extra @{ transition_id = [string]$Transition.transition_id }
        source_envelope_ref = Copy-JsonObject -Value $Packet.source_envelope_ref
        target_envelope_ref = Copy-JsonObject -Value $Packet.target_envelope_ref
        packet_found = $true
        transition_found = $true
        reconstructed_from_generated_handoff_packet = $true
        transition_decision = [pscustomobject][ordered]@{
            decision = [string]$Packet.transition_decision.decision
            execution_permitted = [bool]$Packet.transition_decision.execution_permitted
            context_budget_guard_verdict = [string]$Packet.transition_decision.context_budget_guard_verdict
            blocked_reasons = [string[]]@($Packet.transition_decision.blocked_reasons | ForEach-Object { [string]$_ })
            deterministic_order = 1
        }
        block_basis = [string[]]@(
            "R16-020 transition gate decision blocks this handoff",
            "context budget guard remains failed_closed_over_budget",
            "source and target role-run envelopes are non-executable under the current guard posture"
        )
        blocked_reason = [string]$Packet.blocked_reason
        guard_verdict = $script:GuardVerdict
        estimated_tokens_upper_bound = $upperBound
        threshold = $threshold
        no_mitigation = $true
        handoff_executable = $false
        executable = $false
        transition_execution_permitted = $false
        handoff_execution_status = "blocked"
        runtime_handoff_execution_performed = $false
        runtime_handoff_execution_claimed = $false
        workflow_drill_execution_beyond_this_report_artifact = $false
        deterministic_order = $order
    }
}

function Get-EnvelopeCounts {
    param([Parameter(Mandatory = $true)]$RoleRunEnvelopes)

    $envelopes = @($RoleRunEnvelopes.envelopes)
    return [pscustomobject]@{
        Total = $envelopes.Count
        Blocked = @($envelopes | Where-Object { [string]$_.envelope_execution_status -eq "blocked" -and -not [bool]$_.executable }).Count
        Executable = @($envelopes | Where-Object { [bool]$_.executable }).Count
    }
}

function New-R16RoleHandoffDrillObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($requiredPath in $script:RequiredInputPaths) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $requiredPath -RepositoryRoot $resolvedRoot -Context "R16-023 exact role-handoff drill inputs" | Out-Null
    }

    $handoffPacketReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"
    $restartDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.restart_compaction_recovery_drill_ref) -Label "R16 restart/compaction recovery drill"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $estimate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_estimate_ref) -Label "R16 context budget estimate"
    $loadPlan = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_load_plan_ref) -Label "R16 context-load plan"
    $memoryPacks = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_memory_packs_ref) -Label "R16 role memory packs"
    $governanceText = [System.IO.File]::ReadAllText((Join-Path $resolvedRoot $script:RequiredRefPaths.card_state_ref))

    if ([string]$handoffPacketReport.artifact_type -ne "r16_handoff_packet_report" -or [string]$handoffPacketReport.source_task -ne "R16-021") {
        throw "R16-023 role handoff drill requires the R16-021 generated handoff packet report."
    }
    if ([string]$restartDrill.artifact_type -ne "r16_restart_compaction_recovery_drill" -or [string]$restartDrill.source_task -ne "R16-022") {
        throw "R16-023 role handoff drill requires the R16-022 restart/compaction recovery drill report."
    }
    if ([string]$raciGate.artifact_type -ne "r16_raci_transition_gate_report" -or [int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "R16-023 role handoff drill requires the R16-020 transition gate to remain failed closed with all transitions blocked."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "R16-023 role handoff drill requires guard failed_closed_over_budget with threshold $script:ExpectedThreshold."
    }
    if ([string]$roleRunEnvelopes.artifact_type -ne "r16_role_run_envelopes" -or [string]$estimate.artifact_type -ne "r16_context_budget_estimate" -or [string]$loadPlan.artifact_type -ne "r16_context_load_plan" -or [string]$memoryPacks.artifact_type -ne "r16_role_memory_packs") {
        throw "R16-023 role handoff drill requires role envelopes, context artifacts, and role memory packs."
    }
    if ([int64]$handoffPacketReport.blocked_handoff_count -ne 4 -or [int64]$handoffPacketReport.executable_handoff_count -ne 0) {
        throw "R16-023 role handoff drill requires all R16-021 handoff packets blocked and zero executable handoffs."
    }
    if ([string]$restartDrill.aggregate_verdict -ne "passed_bounded_restart_recovery_drill_with_blocked_execution" -or [string]$restartDrill.current_posture.active_through_task -ne "R16-022") {
        throw "R16-023 role handoff drill requires the accepted R16-022 bounded recovery drill posture."
    }
    if ($governanceText -notmatch "R16-023" -or $governanceText -notmatch "R16-024") {
        throw "R16-023 role handoff drill requires the R16 governance card-state authority file."
    }

    $inputRefs = New-RoleHandoffInputRefs
    $roleChain = New-CoreRoleHandoffChain
    $packets = @($handoffPacketReport.handoff_packets)
    $transitions = @($raciGate.evaluated_transitions)
    $evaluated = @()
    foreach ($chainStep in $roleChain) {
        $packet = Get-HandoffPacketByRoles -Packets $packets -SourceRoleId ([string]$chainStep.source_role_id) -TargetRoleId ([string]$chainStep.target_role_id)
        $transition = Get-TransitionByRoles -Transitions $transitions -SourceRoleId ([string]$chainStep.source_role_id) -TargetRoleId ([string]$chainStep.target_role_id)
        $evaluated += New-EvaluatedRoleHandoff -ChainStep $chainStep -Packet $packet -Transition $transition -Guard $guard
    }

    $downstreamCandidate = @($packets | Where-Object { [string]$_.source_role_id -eq "evidence_auditor" -and [string]$_.target_role_id -eq "release_closeout_agent" } | Select-Object -First 1)
    $observedDownstreamCandidates = @()
    if ($downstreamCandidate.Count -eq 1) {
        $observedDownstreamCandidates += [pscustomobject][ordered]@{
            source_role_id = "evidence_auditor"
            target_role_id = "release_closeout_agent"
            handoff_packet_id = [string]$downstreamCandidate[0].handoff_packet_id
            observed_downstream_candidate_only = $true
            required_for_core_chain = $false
            executable = $false
            handoff_execution_status = "blocked"
            deterministic_order = 1
        }
    }

    $blockedCount = @($evaluated | Where-Object { [string]$_.handoff_execution_status -eq "blocked" -and -not [bool]$_.handoff_executable }).Count
    $executableCount = @($evaluated | Where-Object { [bool]$_.handoff_executable -or [bool]$_.executable }).Count
    $executableTransitionCount = @($evaluated | Where-Object { [bool]$_.transition_execution_permitted }).Count
    $envelopeCounts = Get-EnvelopeCounts -RoleRunEnvelopes $roleRunEnvelopes
    $upperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound

    return [pscustomobject][ordered]@{
        artifact_type = "r16_role_handoff_drill"
        drill_version = $script:DrillVersion
        drill_id = $script:DrillId
        source_milestone = $script:R16Milestone
        source_task = "R16-023"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = "R16-023A implementation pass creates a bounded role-handoff drill report from exact repo-backed generated artifacts only; it inspects Project Manager to Developer to QA to Evidence Auditor handoff packets and does not claim runtime handoff execution, executable handoffs, executable transitions, workflow drill execution beyond this report artifact, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, autonomous recovery, external integrations, solved Codex compaction, or solved Codex reliability."
        drill_execution_boundary = [pscustomobject][ordered]@{
            artifact_only_report = $true
            generated_from_exact_repo_backed_inputs_only = $true
            runtime_handoff_execution_claimed = $false
            runtime_handoff_execution_performed = $false
            workflow_drill_execution_beyond_this_report_artifact = $false
            executable_handoffs_claimed = $false
            executable_transitions_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            autonomous_recovery_claimed = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
            deterministic_order = 1
        }
        exact_input_refs = [object[]]$inputRefs
        role_handoff_chain = [object[]]$roleChain
        handoff_packet_report_ref = $inputRefs[0]
        restart_compaction_recovery_drill_ref = $inputRefs[1]
        raci_transition_gate_report_ref = $inputRefs[2]
        role_run_envelopes_ref = $inputRefs[3]
        context_budget_guard_ref = $inputRefs[4]
        context_budget_estimate_ref = $inputRefs[5]
        context_load_plan_ref = $inputRefs[6]
        role_memory_packs_ref = $inputRefs[7]
        card_state_ref = $inputRefs[8]
        drill_evidence_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_input_count = $script:RequiredInputPaths.Count
            required_input_paths = [string[]]$script:RequiredInputPaths
            generated_reports_as_machine_proof_allowed = $false
            report_as_machine_proof_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            deterministic_order = 1
        }
        drill_steps = [object[]]@(
            [pscustomobject][ordered]@{
                step_id = "role_handoff_drill_step_001"
                action = "Load exact role-handoff drill input refs only."
                input_ref_ids = [string[]]@("handoff_packet_report_ref", "restart_compaction_recovery_drill_ref", "raci_transition_gate_report_ref", "role_run_envelopes_ref", "context_budget_guard_ref", "context_budget_estimate_ref", "context_load_plan_ref", "role_memory_packs_ref", "card_state_ref")
                result = "Exact repo-relative tracked input set identified without raw chat history and without broad or full repo scan."
                deterministic_order = 1
            },
            [pscustomobject][ordered]@{
                step_id = "role_handoff_drill_step_002"
                action = "Reconstruct the deterministic Project Manager to Developer to QA to Evidence Auditor handoff chain from generated handoff packets."
                input_ref_ids = [string[]]@("handoff_packet_report_ref")
                result = "All three core chain handoff packets exist in the R16-021 generated handoff packet report."
                deterministic_order = 2
            },
            [pscustomobject][ordered]@{
                step_id = "role_handoff_drill_step_003"
                action = "Cross-check each core handoff against the R16-020 transition gate and failed_closed_over_budget guard posture."
                input_ref_ids = [string[]]@("raci_transition_gate_report_ref", "context_budget_guard_ref")
                result = "Each core handoff is blocked/not executable by R16-020 transition gate basis and failed_closed_over_budget."
                deterministic_order = 3
            },
            [pscustomobject][ordered]@{
                step_id = "role_handoff_drill_step_004"
                action = "Preserve non-runtime drill boundaries."
                input_ref_ids = [string[]]@("restart_compaction_recovery_drill_ref", "card_state_ref")
                result = "No runtime handoff execution, executable handoff, executable transition, or workflow drill execution beyond this report artifact is claimed."
                deterministic_order = 4
            }
        )
        evaluated_handoffs = [object[]]$evaluated
        blocked_handoff_count = $blockedCount
        executable_handoff_count = $executableCount
        executable_transition_count = $executableTransitionCount
        role_chain_summary = [pscustomobject][ordered]@{
            core_chain_role_sequence = [string[]]@("project_manager", "developer", "qa", "evidence_auditor")
            core_chain_handoff_count = $roleChain.Count
            core_chain_reconstructed_from_generated_packets = $true
            required_core_handoffs_present = $true
            source_handoff_packet_count = $packets.Count
            source_handoff_packet_blocked_count = [int64]$handoffPacketReport.blocked_handoff_count
            source_handoff_packet_executable_count = [int64]$handoffPacketReport.executable_handoff_count
            observed_downstream_candidates = [object[]]$observedDownstreamCandidates
            observed_downstream_candidate_count = $observedDownstreamCandidates.Count
            blocked_handoff_count = $blockedCount
            executable_handoff_count = $executableCount
            executable_transition_count = $executableTransitionCount
            active_through_task_in_report_only = "R16-023"
            planned_tasks_remain = [string[]]@("R16-024", "R16-025", "R16-026")
            runtime_handoff_execution_performed = $false
            workflow_drill_execution_beyond_this_report_artifact = $false
            deterministic_order = 1
        }
        no_full_repo_scan_policy = [pscustomobject][ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            exact_input_refs_only = $true
            exact_dependency_refs_only = $true
            required_input_paths = [string[]]$script:RequiredInputPaths
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
            exact_input_count = $script:RequiredInputPaths.Count
            core_chain_handoff_count = $roleChain.Count
            source_handoff_packet_count = $packets.Count
            source_handoff_packet_blocked_count = [int64]$handoffPacketReport.blocked_handoff_count
            source_handoff_packet_executable_count = [int64]$handoffPacketReport.executable_handoff_count
            blocked_handoff_count = $blockedCount
            executable_handoff_count = $executableCount
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            executable_transition_count = $executableTransitionCount
            executable_envelope_count = $envelopeCounts.Executable
            blocked_envelope_count = $envelopeCounts.Blocked
            guard_verdict = $script:GuardVerdict
            estimated_tokens_upper_bound = $upperBound
            threshold = $threshold
            no_mitigation = $true
            all_core_handoffs_blocked_not_executable = $true
            raw_chat_history_canonical_state_used = $false
            full_repo_scan_used = $false
            runtime_handoff_execution_performed = $false
            workflow_drill_execution_beyond_this_report_artifact = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            autonomous_recovery_claimed = $false
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
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[4]; deterministic_order = 5 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[5]; deterministic_order = 6 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[6]; deterministic_order = 7 }
        )
        current_posture = [pscustomobject][ordered]@{
            active_through_task = "R16-023"
            active_through_scope = "R16-023 bounded role-handoff drill report only"
            previous_accepted_task = "R16-022"
            r16_023_report_only = $true
            r16_024_through_r16_026_planned_only = $true
            planned_tasks = [string[]]@("R16-024", "R16-025", "R16-026")
            guard_verdict = $script:GuardVerdict
            no_mitigation = $true
            handoff_packets_blocked = $true
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            executable_envelopes_exist = $false
            runtime_handoff_execution_claimed = $false
            workflow_drill_execution_beyond_this_report_artifact = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            autonomous_recovery_claimed = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            r16_024_implementation_claimed = $false
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
        [Parameter(Mandatory = $true)]$RefObject,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ExpectedPath,
        [string]$ExpectedRefId
    )

    $ref = Assert-ObjectValue -Value $RefObject -Context $Context
    foreach ($fieldName in @("ref_id", "path", "source_task", "proof_treatment", "machine_proof", "exact_path_only", "broad_scan_allowed", "wildcard_allowed", "deterministic_order")) {
        Get-RequiredProperty -InputObject $ref -Name $fieldName -Context $Context | Out-Null
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedRefId) -and [string]$ref.ref_id -ne $ExpectedRefId) {
        throw "$Context ref_id must be '$ExpectedRefId'."
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedPath) -and (ConvertTo-NormalizedRepoPath -PathValue ([string]$ref.path)) -ne $ExpectedPath) {
        throw "$Context path must be '$ExpectedPath'."
    }
    Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$ref.path) -RepositoryRoot $RepositoryRoot -Context $Context | Out-Null
    if ((Assert-BooleanValue -Value $ref.machine_proof -Context "$Context machine_proof") -ne $false) {
        throw "$Context contains report-as-machine-proof misuse."
    }
    if ((Assert-BooleanValue -Value $ref.exact_path_only -Context "$Context exact_path_only") -ne $true) {
        throw "$Context exact_path_only must be true."
    }
    foreach ($falseField in @("broad_scan_allowed", "wildcard_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $ref -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }

    return $ref
}

function Assert-NoFullRepoScanPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($trueField in @("repo_relative_exact_paths_only", "tracked_files_only", "exact_input_refs_only", "exact_dependency_refs_only", "no_wildcard_path_expansion")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be true."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_path_expansion_performed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $policyObject -Name "required_input_paths" -Context $Context) -Context "$Context required_input_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredInputPaths -Context "$Context required_input_paths"
    foreach ($requiredPath in $requiredPaths) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $requiredPath -RepositoryRoot $RepositoryRoot -Context "$Context required_input_paths" | Out-Null
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

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string]$postureObject.active_through_task -ne "R16-023") {
        throw "$Context active_through_task must be R16-023."
    }
    if ([string]$postureObject.guard_verdict -ne $script:GuardVerdict) {
        throw "$Context guard verdict must be failed_closed_over_budget."
    }
    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    Assert-RequiredStringsPresent -Actual $plannedTasks -Required ([string[]]@("R16-024", "R16-025", "R16-026")) -Context "$Context planned_tasks"
    foreach ($trueField in @("r16_023_report_only", "r16_024_through_r16_026_planned_only", "handoff_packets_blocked", "no_mitigation")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be true."
        }
    }
    foreach ($falseField in @("executable_handoffs_exist", "executable_transitions_exist", "executable_envelopes_exist", "runtime_handoff_execution_claimed", "workflow_drill_execution_beyond_this_report_artifact", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "autonomous_recovery_claimed", "actual_autonomous_agents_implemented", "external_integrations_implemented", "r16_024_implementation_claimed", "r16_027_or_later_task_exists", "main_merge_claimed")) {
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
    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"
    if ([bool]$r13.closed -or [bool]$r13.r13_closed -or [bool]$r13.partial_gates_converted_to_passed) {
        throw "$Context contains forbidden R13 closure or partial-gate conversion claim."
    }
    if ([bool]$r14.caveats_removed -or [bool]$r14.r14_caveats_removed) {
        throw "$Context contains forbidden R14 caveat removal."
    }
    if ([bool]$r15.caveats_removed -or [bool]$r15.r15_caveats_removed) {
        throw "$Context contains forbidden R15 caveat removal."
    }
}

function Assert-RoleHandoffChain {
    param(
        [Parameter(Mandatory = $true)]$Chain,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $chainItems = @(Assert-ObjectArray -Value $Chain -Context $Context)
    $requiredPairs = @(New-CoreRoleHandoffChain)
    if ($chainItems.Count -ne $requiredPairs.Count) {
        throw "$Context must contain the three core role handoffs."
    }
    for ($index = 0; $index -lt $requiredPairs.Count; $index += 1) {
        $actual = $chainItems[$index]
        $expected = $requiredPairs[$index]
        if ([string]$actual.source_role_id -ne [string]$expected.source_role_id -or [string]$actual.target_role_id -ne [string]$expected.target_role_id) {
            throw "$Context must preserve deterministic core chain order."
        }
        if ((Assert-BooleanValue -Value $actual.required_core_handoff -Context "$Context required_core_handoff") -ne $true -or (Assert-BooleanValue -Value $actual.handoff_packet_required -Context "$Context handoff_packet_required") -ne $true) {
            throw "$Context core handoffs must be required and packet-backed."
        }
        if ((Assert-BooleanValue -Value $actual.runtime_execution_permitted -Context "$Context runtime_execution_permitted") -ne $false) {
            throw "$Context contains runtime handoff execution claim."
        }
    }
}

function Assert-EvaluatedHandoffs {
    param(
        [Parameter(Mandatory = $true)]$EvaluatedHandoffs,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)]$HandoffPacketReport,
        [Parameter(Mandatory = $true)]$RaciGate,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $items = @(Assert-ObjectArray -Value $EvaluatedHandoffs -Context $Context)
    $packets = @($HandoffPacketReport.handoff_packets)
    $transitions = @($RaciGate.evaluated_transitions)
    $requiredPairs = @(New-CoreRoleHandoffChain)
    if ($items.Count -ne $requiredPairs.Count) {
        throw "$Context must contain exactly three evaluated core handoffs."
    }

    foreach ($expected in $requiredPairs) {
        $source = [string]$expected.source_role_id
        $target = [string]$expected.target_role_id
        $matching = @($items | Where-Object { [string]$_.source_role_id -eq $source -and [string]$_.target_role_id -eq $target })
        if ($matching.Count -ne 1) {
            throw "$Context is missing $source -> $target handoff."
        }

        $handoff = $matching[0]
        foreach ($fieldName in @("evaluated_handoff_id", "source_role_id", "target_role_id", "action_type", "handoff_packet_id", "handoff_packet_ref", "transition_id", "transition_gate_ref", "packet_found", "transition_found", "reconstructed_from_generated_handoff_packet", "transition_decision", "block_basis", "blocked_reason", "guard_verdict", "estimated_tokens_upper_bound", "threshold", "no_mitigation", "handoff_executable", "executable", "transition_execution_permitted", "handoff_execution_status", "runtime_handoff_execution_performed", "runtime_handoff_execution_claimed", "workflow_drill_execution_beyond_this_report_artifact", "deterministic_order")) {
            Get-RequiredProperty -InputObject $handoff -Name $fieldName -Context "$Context $source -> $target" | Out-Null
        }

        $packet = Get-HandoffPacketByRoles -Packets $packets -SourceRoleId $source -TargetRoleId $target
        $transition = Get-TransitionByRoles -Transitions $transitions -SourceRoleId $source -TargetRoleId $target
        if ([string]$handoff.handoff_packet_id -ne [string]$packet.handoff_packet_id -or [string]$handoff.transition_id -ne [string]$transition.transition_id) {
            throw "$Context $source -> $target must match generated handoff packet and R16-020 transition ids."
        }
        Assert-RefObject -RefObject $handoff.handoff_packet_ref -Context "$Context $source -> $target handoff_packet_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.handoff_packet_report_ref -ExpectedRefId "handoff_packet_report_ref" | Out-Null
        Assert-RefObject -RefObject $handoff.transition_gate_ref -Context "$Context $source -> $target transition_gate_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "raci_transition_gate_report_ref" | Out-Null
        Assert-RefObject -RefObject $handoff.source_envelope_ref -Context "$Context $source -> $target source_envelope_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "source_envelope_ref" | Out-Null
        Assert-RefObject -RefObject $handoff.target_envelope_ref -Context "$Context $source -> $target target_envelope_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "target_envelope_ref" | Out-Null

        foreach ($trueField in @("packet_found", "transition_found", "reconstructed_from_generated_handoff_packet", "no_mitigation")) {
            if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $handoff -Name $trueField -Context "$Context $source -> $target") -Context "$Context $source -> $target $trueField") -ne $true) {
                throw "$Context $source -> $target $trueField must be true."
            }
        }
        foreach ($falseField in @("handoff_executable", "executable", "transition_execution_permitted", "runtime_handoff_execution_performed", "runtime_handoff_execution_claimed", "workflow_drill_execution_beyond_this_report_artifact")) {
            if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $handoff -Name $falseField -Context "$Context $source -> $target") -Context "$Context $source -> $target $falseField") -ne $false) {
                if ($falseField -eq "transition_execution_permitted") {
                    throw "$Context $source -> $target transition marked executable."
                }
                if ($falseField -in @("handoff_executable", "executable")) {
                    throw "$Context $source -> $target handoff marked executable."
                }
                throw "$Context $source -> $target contains forbidden $falseField claim."
            }
        }
        $transitionDecision = Assert-ObjectValue -Value $handoff.transition_decision -Context "$Context $source -> $target transition_decision"
        if ([string]$transitionDecision.decision -ne "blocked" -or [bool]$transitionDecision.execution_permitted) {
            throw "$Context $source -> $target transition marked executable."
        }
        if ([string]$transitionDecision.context_budget_guard_verdict -ne $script:GuardVerdict) {
            throw "$Context $source -> $target transition decision must preserve failed_closed_over_budget."
        }
        if ([string]$handoff.guard_verdict -ne $script:GuardVerdict) {
            throw "$Context $source -> $target guard verdict must be failed_closed_over_budget."
        }
        if ([int64]$handoff.estimated_tokens_upper_bound -ne [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$handoff.threshold -ne $script:ExpectedThreshold) {
            throw "$Context $source -> $target must preserve current guard upper bound and threshold."
        }
        if ([string]$handoff.handoff_execution_status -ne "blocked") {
            throw "$Context $source -> $target handoff_execution_status must be blocked."
        }
        $blockedReason = [string]$handoff.blocked_reason
        if ($blockedReason -notmatch "failed_closed_over_budget") {
            throw "$Context $source -> $target blocked_reason must reference failed_closed_over_budget."
        }
        if ($blockedReason -notmatch "R16-020" -or $blockedReason -notmatch "transition gate") {
            throw "$Context $source -> $target blocked_reason must reference the R16-020 transition gate."
        }
        $basis = Assert-StringArray -Value $handoff.block_basis -Context "$Context $source -> $target block_basis"
        if (@($basis | Where-Object { $_ -match "R16-020" }).Count -eq 0 -or @($basis | Where-Object { $_ -match "failed_closed_over_budget" }).Count -eq 0) {
            throw "$Context $source -> $target block_basis must reference R16-020 and failed_closed_over_budget."
        }
    }

    return $items
}

function Test-R16RoleHandoffDrillObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 role handoff drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-ObjectValue -Value $Report -Context $SourceLabel | Out-Null
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }
    if ([string]$Report.artifact_type -ne "r16_role_handoff_drill" -or [string]$Report.source_task -ne "R16-023") {
        throw "$SourceLabel identity is incorrect."
    }
    if ([string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Report -RepositoryRoot $resolvedRoot -Context $SourceLabel

    Assert-RefObject -RefObject $Report.handoff_packet_report_ref -Context "$SourceLabel handoff_packet_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.handoff_packet_report_ref -ExpectedRefId "handoff_packet_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.restart_compaction_recovery_drill_ref -Context "$SourceLabel restart_compaction_recovery_drill_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.restart_compaction_recovery_drill_ref -ExpectedRefId "restart_compaction_recovery_drill_ref" | Out-Null
    Assert-RefObject -RefObject $Report.raci_transition_gate_report_ref -Context "$SourceLabel raci_transition_gate_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "raci_transition_gate_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_run_envelopes_ref -Context "$SourceLabel role_run_envelopes_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "role_run_envelopes_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_memory_packs_ref -Context "$SourceLabel role_memory_packs_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "role_memory_packs_ref" | Out-Null
    Assert-RefObject -RefObject $Report.card_state_ref -Context "$SourceLabel card_state_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.card_state_ref -ExpectedRefId "card_state_ref" | Out-Null

    $handoffPacketReport = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.handoff_packet_report_ref) -Label "R16 handoff packet report"
    $restartDrill = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.restart_compaction_recovery_drill_ref) -Label "R16 restart/compaction recovery drill"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"

    if ([string]$handoffPacketReport.artifact_type -ne "r16_handoff_packet_report" -or [int64]$handoffPacketReport.blocked_handoff_count -ne 4 -or [int64]$handoffPacketReport.executable_handoff_count -ne 0) {
        throw "$SourceLabel requires R16-021 handoff packets blocked/not executable."
    }
    if ([string]$restartDrill.artifact_type -ne "r16_restart_compaction_recovery_drill" -or [string]$restartDrill.current_posture.active_through_task -ne "R16-022") {
        throw "$SourceLabel requires the R16-022 recovery drill input."
    }
    if ([string]$raciGate.aggregate_verdict -ne "failed_closed_all_transitions_blocked_by_budget_guard" -or [int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "$SourceLabel requires all R16-020 transitions blocked."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict -or [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound -ne $script:ExpectedThreshold) {
        throw "$SourceLabel requires guard failed_closed_over_budget with threshold $script:ExpectedThreshold."
    }

    Assert-RoleHandoffChain -Chain $Report.role_handoff_chain -Context "$SourceLabel role_handoff_chain"
    $evaluated = Assert-EvaluatedHandoffs -EvaluatedHandoffs $Report.evaluated_handoffs -Context "$SourceLabel evaluated_handoffs" -HandoffPacketReport $handoffPacketReport -RaciGate $raciGate -Guard $guard -RepositoryRoot $resolvedRoot

    $blockedCount = @($evaluated | Where-Object { [string]$_.handoff_execution_status -eq "blocked" -and -not [bool]$_.handoff_executable }).Count
    $executableCount = @($evaluated | Where-Object { [bool]$_.handoff_executable -or [bool]$_.executable }).Count
    $executableTransitionCount = @($evaluated | Where-Object { [bool]$_.transition_execution_permitted }).Count
    if ([int64]$Report.blocked_handoff_count -ne $blockedCount -or [int64]$Report.blocked_handoff_count -ne 3) {
        throw "$SourceLabel blocked_handoff_count must be 3 for the core chain."
    }
    if ([int64]$Report.executable_handoff_count -ne $executableCount -or [int64]$Report.executable_handoff_count -ne 0) {
        throw "$SourceLabel executable_handoff_count must be 0."
    }
    if ([int64]$Report.executable_transition_count -ne $executableTransitionCount -or [int64]$Report.executable_transition_count -ne 0) {
        throw "$SourceLabel executable_transition_count must be 0."
    }

    Assert-NoFullRepoScanPolicy -Policy $Report.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy" -RepositoryRoot $resolvedRoot
    Assert-RawChatHistoryPolicy -Policy $Report.raw_chat_history_policy -Context "$SourceLabel raw_chat_history_policy"
    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $evidencePolicy = Assert-ObjectValue -Value $Report.drill_evidence_policy -Context "$SourceLabel drill_evidence_policy"
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name "required_input_paths" -Context "$SourceLabel drill_evidence_policy") -Context "$SourceLabel drill_evidence_policy required_input_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredInputPaths -Context "$SourceLabel drill_evidence_policy required_input_paths"
    if ((Assert-BooleanValue -Value $evidencePolicy.generated_reports_as_machine_proof_allowed -Context "$SourceLabel drill_evidence_policy generated_reports_as_machine_proof_allowed") -ne $false) {
        throw "$SourceLabel rejects report-as-machine-proof misuse."
    }

    $summary = Assert-ObjectValue -Value $Report.role_chain_summary -Context "$SourceLabel role_chain_summary"
    if ([int64]$summary.core_chain_handoff_count -ne 3 -or [int64]$summary.source_handoff_packet_blocked_count -ne 4 -or [int64]$summary.source_handoff_packet_executable_count -ne 0) {
        throw "$SourceLabel role_chain_summary must preserve core chain and source handoff packet posture."
    }
    if ([string]$summary.active_through_task_in_report_only -ne "R16-023") {
        throw "$SourceLabel role_chain_summary must record R16 active through R16-023 in this drill report only."
    }
    $findingSummary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$findingSummary.exact_input_count -ne $script:RequiredInputPaths.Count -or [int64]$findingSummary.core_chain_handoff_count -ne 3) {
        throw "$SourceLabel finding_summary must record exact input and core chain counts."
    }
    if ([string]$findingSummary.guard_verdict -ne $script:GuardVerdict -or [int64]$findingSummary.estimated_tokens_upper_bound -ne [int64]$guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$findingSummary.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel finding_summary must preserve failed_closed_over_budget guard values."
    }
    if ([int64]$findingSummary.blocked_handoff_count -ne 3 -or [int64]$findingSummary.executable_handoff_count -ne 0 -or [int64]$findingSummary.executable_transition_count -ne 0 -or [int64]$findingSummary.allowed_transition_count -ne 0) {
        throw "$SourceLabel finding_summary must preserve blocked handoff and transition posture."
    }
    if ([int64]$findingSummary.executable_envelope_count -ne 0 -or @($roleRunEnvelopes.envelopes | Where-Object { [bool]$_.executable }).Count -ne 0) {
        throw "$SourceLabel finding_summary must preserve no executable envelopes."
    }
    foreach ($falseField in @("raw_chat_history_canonical_state_used", "full_repo_scan_used", "runtime_handoff_execution_performed", "workflow_drill_execution_beyond_this_report_artifact", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "autonomous_recovery_claimed", "actual_autonomous_agents_implemented", "external_integrations_implemented", "solved_codex_compaction", "solved_codex_reliability")) {
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
        CoreHandoffCount = $evaluated.Count
        BlockedHandoffCount = [int64]$Report.blocked_handoff_count
        ExecutableHandoffCount = [int64]$Report.executable_handoff_count
        ExecutableTransitionCount = [int64]$Report.executable_transition_count
        SourceHandoffPacketBlockedCount = [int64]$handoffPacketReport.blocked_handoff_count
        AggregateVerdict = [string]$Report.aggregate_verdict
        GuardVerdict = [string]$guard.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
        Threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
    }
}

function Test-R16RoleHandoffDrill {
    [CmdletBinding()]
    param(
        [string]$Path = "state/workflow/r16_role_handoff_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 role handoff drill"
    return Test-R16RoleHandoffDrillObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16RoleHandoffDrill {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/workflow/r16_role_handoff_drill.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16RoleHandoffDrillObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $report -PathValue $resolvedOutput
    $validation = Test-R16RoleHandoffDrill -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        DrillId = $validation.DrillId
        CoreHandoffCount = $validation.CoreHandoffCount
        BlockedHandoffCount = $validation.BlockedHandoffCount
        ExecutableHandoffCount = $validation.ExecutableHandoffCount
        ExecutableTransitionCount = $validation.ExecutableTransitionCount
        SourceHandoffPacketBlockedCount = $validation.SourceHandoffPacketBlockedCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        GuardVerdict = $validation.GuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        Threshold = $validation.Threshold
    }
}

function Test-R16RoleHandoffDrillContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/workflow/r16_role_handoff_drill.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 role handoff drill contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "role_handoff_drill_contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "role_handoff_drill_policy", "no_full_repo_scan_policy", "raw_chat_history_policy", "blocked_execution_policy", "non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 role handoff drill contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_role_handoff_drill_contract" -or [string]$contract.source_task -ne "R16-023") {
        throw "R16 role handoff drill contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 role handoff drill contract"
    Assert-AllPathFieldsAreSafe -Value $contract -RepositoryRoot $resolvedRoot -Context "R16 role handoff drill contract"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 role handoff drill contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 role handoff drill contract required_report_fields"
    $dependencyRefs = @(Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 role handoff drill contract dependency_refs")
    if ($dependencyRefs.Count -ne $script:RequiredInputPaths.Count) {
        throw "R16 role handoff drill contract dependency_refs must include exactly $($script:RequiredInputPaths.Count) input refs."
    }
    $dependencyPaths = @()
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        $dependencyRef = Assert-RefObject -RefObject $dependencyRefs[$index] -Context "R16 role handoff drill contract dependency_refs[$index]" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredInputPaths[$index]
        $dependencyPaths += ConvertTo-NormalizedRepoPath -PathValue ([string]$dependencyRef.path)
    }
    Assert-RequiredStringsPresent -Actual ([string[]]$dependencyPaths) -Required $script:RequiredInputPaths -Context "R16 role handoff drill contract dependency_refs path"
    if ([string]$contract.role_handoff_drill_policy.aggregate_verdict_required -ne $script:AggregateVerdict) {
        throw "R16 role handoff drill contract aggregate verdict policy is incorrect."
    }
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 role handoff drill contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 role handoff drill contract non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.role_handoff_drill_contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16RoleHandoffDrillFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_role_handoff_drill",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16RoleHandoffDrillObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validReport -PathValue (Join-Path $fixtureRootPath "valid_role_handoff_drill.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_role_handoff_drill.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.generation_boundary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generation_boundary'")
        "invalid_missing_handoff_packet_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_handoff_packet_report_ref" -MutationPath '$.handoff_packet_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'handoff_packet_report_ref'")
        "invalid_missing_restart_compaction_recovery_drill_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_restart_compaction_recovery_drill_ref" -MutationPath '$.restart_compaction_recovery_drill_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'restart_compaction_recovery_drill_ref'")
        "invalid_missing_raci_transition_gate_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_raci_transition_gate_report_ref" -MutationPath '$.raci_transition_gate_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'raci_transition_gate_report_ref'")
        "invalid_missing_role_run_envelopes_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_run_envelopes_ref" -MutationPath '$.role_run_envelopes_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_role_handoff_chain.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_handoff_chain" -MutationPath '$.role_handoff_chain' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_handoff_chain'")
        "invalid_missing_evaluated_handoffs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_evaluated_handoffs" -MutationPath '$.evaluated_handoffs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'evaluated_handoffs'")
        "invalid_missing_project_manager_to_developer_handoff.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_project_manager_to_developer_handoff" -MutationPath '$.evaluated_handoffs[0].target_role_id' -MutationValue "architect" -ExpectedFailure @("missing project_manager -> developer handoff")
        "invalid_missing_developer_to_qa_handoff.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_developer_to_qa_handoff" -MutationPath '$.evaluated_handoffs[1].target_role_id' -MutationValue "evidence_auditor" -ExpectedFailure @("missing developer -> qa handoff")
        "invalid_missing_qa_to_evidence_auditor_handoff.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_qa_to_evidence_auditor_handoff" -MutationPath '$.evaluated_handoffs[2].target_role_id' -MutationValue "release_closeout_agent" -ExpectedFailure @("missing qa -> evidence_auditor handoff")
        "invalid_handoff_marked_executable.json" = New-MutationFixtureSpec -FixtureId "invalid_handoff_marked_executable" -MutationPath '$.evaluated_handoffs[0].handoff_executable' -MutationValue $true -ExpectedFailure @("handoff marked executable")
        "invalid_transition_marked_executable.json" = New-MutationFixtureSpec -FixtureId "invalid_transition_marked_executable" -MutationPath '$.evaluated_handoffs[0].transition_execution_permitted' -MutationValue $true -ExpectedFailure @("transition marked executable")
        "invalid_guard_verdict_not_failed_closed_over_budget.json" = New-MutationFixtureSpec -FixtureId "invalid_guard_verdict_not_failed_closed_over_budget" -MutationPath '$.current_posture.guard_verdict' -MutationValue "passed" -ExpectedFailure @("guard verdict must be failed_closed_over_budget")
        "invalid_blocked_reason_missing_failed_closed_over_budget.json" = New-MutationFixtureSpec -FixtureId "invalid_blocked_reason_missing_failed_closed_over_budget" -MutationPath '$.evaluated_handoffs[0].blocked_reason' -MutationValue "R16-020 transition gate blocks this handoff, but the guard verdict is omitted." -ExpectedFailure @("blocked_reason", "failed_closed_over_budget")
        "invalid_blocked_reason_missing_r16_020_transition_gate.json" = New-MutationFixtureSpec -FixtureId "invalid_blocked_reason_missing_r16_020_transition_gate" -MutationPath '$.evaluated_handoffs[0].blocked_reason' -MutationValue "The handoff remains blocked because context budget guard remains failed_closed_over_budget." -ExpectedFailure @("blocked_reason", "R16-020")
        "invalid_raw_chat_history_as_canonical_state.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_as_canonical_state" -MutationPath '$.raw_chat_history_policy.raw_chat_history_as_canonical_state' -MutationValue $true -ExpectedFailure @("raw chat history as canonical state")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "state/workflow/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "state/workflow/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "scratch/r16_role_handoff.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "C:/tmp/r16_role_handoff_drill.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "../state/workflow/r16_handoff_packet_report.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.handoff_packet_report_ref.path' -MutationValue "https://example.invalid/r16_handoff_packet_report.json" -ExpectedFailure @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.drill_evidence_policy.generated_reports_as_machine_proof_allowed' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.drill_execution_boundary.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.drill_execution_boundary.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_runtime_handoff_execution_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_handoff_execution_claim" -MutationPath '$.drill_execution_boundary.runtime_handoff_execution_claimed' -MutationValue $true -ExpectedFailure @("runtime handoff execution claim")
        "invalid_workflow_drill_execution_beyond_report_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_workflow_drill_execution_beyond_report_claim" -MutationPath '$.drill_execution_boundary.workflow_drill_execution_beyond_this_report_artifact' -MutationValue $true -ExpectedFailure @("workflow drill execution claim beyond this report artifact")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.drill_execution_boundary.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.drill_execution_boundary.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.drill_execution_boundary.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.drill_execution_boundary.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.drill_execution_boundary.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_autonomous_recovery_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_recovery_claim" -MutationPath '$.drill_execution_boundary.autonomous_recovery_claimed' -MutationValue $true -ExpectedFailure @("autonomous recovery claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.drill_execution_boundary.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_compaction_claim" -MutationPath '$.drill_execution_boundary.solved_codex_compaction' -MutationValue $true -ExpectedFailure @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_reliability_claim" -MutationPath '$.drill_execution_boundary.solved_codex_reliability' -MutationValue $true -ExpectedFailure @("solved Codex reliability claim")
        "invalid_r16_024_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_024_implementation_claim" -MutationPath '$.current_posture.r16_024_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-024 implementation claim")
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
        ValidFixture = (Join-Path $FixtureRoot "valid_role_handoff_drill.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16RoleHandoffDrillObject, New-R16RoleHandoffDrill, Test-R16RoleHandoffDrillObject, Test-R16RoleHandoffDrill, Test-R16RoleHandoffDrillContract, New-R16RoleHandoffDrillFixtureFiles, ConvertTo-StableJson
