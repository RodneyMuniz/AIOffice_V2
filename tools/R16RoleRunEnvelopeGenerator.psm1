Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeContract.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ContextLoadPlanner.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ContextBudgetEstimator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ContextBudgetGuard.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:EnvelopeVersion = "v1"
$script:EnvelopeArtifactId = "aioffice-r16-019-role-run-envelopes-v1"
$script:AggregateVerdict = "passed_with_all_envelopes_blocked_by_guard"
$script:GuardVerdict = "failed_closed_over_budget"
$script:MaxEstimatedUpperBound = 150000

$script:RequiredRoleIds = [string[]]@(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:RequiredTopLevelFields = [string[]]@(
    "artifact_type",
    "envelope_version",
    "role_run_envelopes_artifact_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "contract_ref",
    "role_memory_packs_ref",
    "role_memory_pack_model_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "context_budget_guard_contract_ref",
    "r16_authority_ref",
    "generation_mode",
    "envelopes",
    "current_posture",
    "preserved_boundaries",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "non_claims"
)

$script:RequiredEnvelopeFields = [string[]]@(
    "envelope_id",
    "role_id",
    "role_display_name",
    "source_task",
    "target_task_or_card_ref",
    "allowed_actions",
    "forbidden_actions",
    "required_inputs",
    "memory_pack_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "budget_guard_status",
    "no_full_repo_scan_attestation",
    "evidence_refs",
    "output_expectations",
    "handoff_constraints",
    "non_claims",
    "envelope_execution_status",
    "executable",
    "blocked_reason",
    "deterministic_order"
)

$script:RequiredInputRefs = [string[]]@(
    "memory_pack_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "evidence_refs"
)

$script:RequiredRefPaths = [ordered]@{
    contract_ref = "contracts/workflow/r16_role_run_envelope.contract.json"
    role_memory_packs_ref = "state/memory/r16_role_memory_packs.json"
    role_memory_pack_model_ref = "state/memory/r16_role_memory_pack_model.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    context_budget_guard_contract_ref = "contracts/context/r16_context_budget_guard.contract.json"
    r16_authority_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_role_run_envelopes.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_run_envelopes.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_run_envelope_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_run_envelope_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_run_envelope_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_context_budget_guard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_guard_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_guard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_memory_packs.ps1 -PacksPath state/memory/r16_role_memory_packs.json -ModelPath state/memory/r16_role_memory_pack_model.json -MemoryLayersPath state/memory/r16_memory_layers.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_memory_pack_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_planning_authority_reference.ps1 -PacketPath state/governance/r16_planning_authority_reference.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_planning_authority_reference.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r16_kpi_baseline_target_scorecard.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_kpi_baseline_target_scorecard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layer_contract.ps1 -ContractPath contracts/memory/r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_memory_layers.ps1 -MemoryLayersPath state/memory/r16_memory_layers.json -ContractPath contracts/memory/r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_memory_layer_generator.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-019 generated role-run envelopes as committed state artifacts only",
    "generated role-run envelopes are not runtime execution",
    "generated role-run envelopes are not autonomous agents",
    "generated role-run envelopes are not runtime memory",
    "all generated envelopes are currently blocked by R16-017 failed_closed_over_budget guard",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R16-020 through R16-026 remain planned only",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved"
)

$script:ForbiddenTrueBooleanClaims = @{
    broad_repo_scan_allowed = "broad repo scan claim"
    broad_repo_scan_performed = "broad repo scan claim"
    broad_repo_scan_claimed = "broad repo scan claim"
    broad_scan_allowed = "broad repo scan claim"
    full_repo_scan_allowed = "full repo scan claim"
    full_repo_scan_performed = "full repo scan claim"
    full_repo_scan_claimed = "full repo scan claim"
    wildcard_paths_allowed = "wildcard path claim"
    wildcard_paths_loaded = "wildcard path claim"
    wildcard_allowed = "wildcard path claim"
    directory_only_refs_allowed = "directory-only ref claim"
    directory_only_refs_loaded = "directory-only ref claim"
    directory_only_paths_allowed = "directory-only ref claim"
    scratch_temp_paths_allowed = "scratch/temp ref claim"
    scratch_temp_refs_loaded = "scratch/temp ref claim"
    absolute_paths_allowed = "absolute path claim"
    absolute_paths_loaded = "absolute path claim"
    parent_traversal_allowed = "parent traversal path claim"
    parent_traversal_refs_loaded = "parent traversal path claim"
    url_or_remote_refs_allowed = "URL or remote ref claim"
    url_or_remote_refs_loaded = "URL or remote ref claim"
    raw_chat_history_loading_allowed = "raw chat history loading claim"
    raw_chat_history_loaded = "raw chat history loading claim"
    raw_chat_history_as_evidence_allowed = "raw chat history loading claim"
    report_as_machine_proof_allowed = "report-as-machine-proof misuse"
    generated_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    operator_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    exact_provider_tokenization_claimed = "exact provider tokenization claim"
    exact_provider_token_count_claimed = "exact provider tokenization claim"
    provider_tokenizer_used = "exact provider tokenization claim"
    exact_provider_billing_claimed = "exact provider billing claim"
    provider_pricing_used = "exact provider billing claim"
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
    raci_transition_gate_implemented = "RACI transition gate implementation claim"
    raci_transition_gate_claimed = "RACI transition gate implementation claim"
    handoff_packet_implemented = "handoff packet implementation claim"
    handoff_packet_claimed = "handoff packet implementation claim"
    workflow_drill_run = "workflow drill claim"
    workflow_drill_implemented = "workflow drill claim"
    r16_020_implementation_claimed = "R16-020 implementation claim"
    r16_020_or_later_implementation_claimed = "R16-020 implementation claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r13_closed = "R13 closure claim"
    r13_closure_claimed = "R13 closure claim"
    r13_partial_gate_conversion_claimed = "R13 partial-gate conversion claim"
    partial_gates_converted_to_passed = "R13 partial-gate conversion claim"
    r14_caveat_removal_claimed = "R14 caveat removal"
    r14_caveats_removed = "R14 caveat removal"
    r15_caveat_removal_claimed = "R15 caveat removal"
    r15_caveats_removed = "R15 caveat removal"
    caveats_removed = "caveat removal"
    main_merge_completed = "main merge claim"
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
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

    return [int64]$Value
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
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    return [string[]]$items
}

function Assert-ObjectArray {
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    return $items
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

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $actualSorted = @($Actual | Sort-Object)
    $expectedSorted = @($Expected | Sort-Object)
    if ($actualSorted.Count -ne $expectedSorted.Count) {
        throw "$Context must contain exactly: $($expectedSorted -join ', ')."
    }

    for ($setIndex = 0; $setIndex -lt $expectedSorted.Count; $setIndex += 1) {
        if ($actualSorted[$setIndex] -ne $expectedSorted[$setIndex]) {
            throw "$Context must contain exactly: $($expectedSorted -join ', ')."
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

    if (Test-Path -LiteralPath $RepositoryRoot) {
        return (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalizedValue = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return [string]::IsNullOrWhiteSpace($normalizedValue) -or $normalizedValue -in @(
        ".",
        "./",
        "/",
        "\",
        "repo",
        "repository",
        "full_repo",
        "entire_repo",
        "all",
        "all_files",
        "**",
        "**/*"
    )
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)
    return $PathValue -match '[\*\?\[\]]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalizedValue = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return $normalizedValue -match '^(\.tmp|\.temp|scratch|tmp|temp|state/temp|state/tmp|state/scratch)(/|$)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalizedValue = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalizedValue -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
        $normalizedValue -match '^git@' -or
        $normalizedValue -match '^(origin|upstream|refs)/' -or
        $normalizedValue -match '^[A-Za-z0-9_.-]+:'
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
    if ([System.IO.Path]::IsPathRooted($normalizedValue) -or $normalizedValue -match '(^|/)\.\.(/|$)' -or (Test-RemoteOrUrlRef -PathValue $normalizedValue)) {
        return $false
    }

    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalizedValue))
    return (Test-Path -LiteralPath $candidatePath -PathType Container)
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
    if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context required path '$PathValue' does not exist as an exact file."
    }
    if (-not (Test-GitTrackedPath -PathValue $normalizedValue -RepositoryRoot $RepositoryRoot)) {
        throw "$Context required path '$PathValue' is not git-tracked."
    }
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$InputObject)

    $json = $InputObject | ConvertTo-Json -Depth 100
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $directoryPath = Split-Path -Parent $PathValue
    if (-not [string]::IsNullOrWhiteSpace($directoryPath)) {
        New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
    }

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($PathValue, (ConvertTo-StableJson -InputObject $InputObject) + "`n", $encoding)
}

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Invoke-GitScalar {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $output = & git -C $RepositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return [string]($output | Select-Object -First 1)
}

function Get-StringValuesFromObject {
    param([AllowNull()]$Value)

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        $Value
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($keyName in $Value.Keys) {
            Get-StringValuesFromObject -Value $Value[$keyName]
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($itemValue in $Value) {
            Get-StringValuesFromObject -Value $itemValue
        }
        return
    }
    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($propertyInfo in $Value.PSObject.Properties) {
            Get-StringValuesFromObject -Value $propertyInfo.Value
        }
    }
}

function Test-TextHasNegation {
    param([AllowNull()][string]$TextValue)

    if ([string]::IsNullOrWhiteSpace($TextValue)) {
        return $false
    }

    return $TextValue -match '(?i)\b(no|not|without|does not|do not|must not|non-claim|non_claim|false|blocked|not executable|planned only|state artifact only|reject|rejected|forbidden|disallowed|only)\b'
}

function Assert-NoForbiddenPositiveStringClaims {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $patterns = [ordered]@{
        "broad repo scan claim" = '(?i)\b(broad repo scan|full repo scan|full repository scan)\b.{0,120}\b(allowed|performed|loaded|claimed|used|complete)\b'
        "raw chat history loading claim" = '(?i)\b(raw chat history|chat history)\b.{0,120}\b(loaded|used as context|context source|evidence source)\b'
        "report-as-machine-proof misuse" = '(?i)\b(report|operator report|planning report)\b.{0,120}\b(machine proof|machine evidence|implementation proof)\b'
        "exact provider tokenization claim" = '(?i)\b(exact provider token|exact provider tokenization|provider tokenizer used|exact tokenizer)\b'
        "exact provider billing claim" = '(?i)\b(exact provider billing|provider billing|provider pricing used|exact provider pricing)\b'
        "runtime memory claim" = '(?i)\b(runtime memory|runtime memory loading|persistent memory runtime)\b'
        "retrieval runtime claim" = '(?i)\b(retrieval runtime|retrieval engine|runtime retrieval)\b'
        "vector search runtime claim" = '(?i)\b(vector search runtime|runtime vector search|vector search engine)\b'
        "product runtime claim" = '(?i)\b(product runtime|production runtime|productized UI|full UI app)\b'
        "autonomous-agent claim" = '(?i)\b(actual autonomous agents|actual agents implemented|agent runtime|true multi-agent execution)\b'
        "external-integration claim" = '(?i)\b(external integration|GitHub Projects integration|Linear integration|Symphony integration|custom board integration|external board sync)\b'
        "RACI transition gate implementation claim" = '(?i)\b(RACI transition gate|RACI transition gates)\b.{0,120}\b(implemented|created|exists|runtime|ships)\b'
        "handoff packet implementation claim" = '(?i)\b(handoff packet|handoff packets)\b.{0,120}\b(implemented|created|exists|runtime|ships)\b'
        "workflow drill claim" = '(?i)\b(workflow drill|workflow drills)\b.{0,120}\b(implemented|created|ran|run|exists|runtime|ships)\b'
        "R16-020 implementation claim" = '(?i)\bR16-(0(?:20|2[1-6]))\b.{0,160}\b(done|complete|completed|implemented|executed|ran|created)\b'
        "R16-027 or later task claim" = '(?i)\bR16-(0(?:2[7-9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned|active)\b'
        "R13 closure claim" = '(?i)\bR13\b.{0,140}\b(closed|closure|accepted as closed)\b'
        "R14 caveat removal" = '(?i)\bR14\b.{0,140}\b(caveats removed|accepted without caveats|uncaveated)\b'
        "R15 caveat removal" = '(?i)\bR15\b.{0,140}\b(caveats removed|accepted without caveats|uncaveated)\b'
    }

    foreach ($textValue in $Values) {
        foreach ($labelName in $patterns.Keys) {
            if ($textValue -match $patterns[$labelName] -and -not (Test-TextHasNegation -TextValue $textValue)) {
                throw "$Context rejects $labelName. Text: $textValue"
            }
        }
    }
}

function Assert-NoForbiddenTrueClaims {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string]) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($keyName in $Value.Keys) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($keyName) -and $Value[$keyName] -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$keyName]) via '$keyName'."
            }
            Assert-NoForbiddenTrueClaims -Value $Value[$keyName] -Context "$Context.$keyName"
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $arrayIndex = 0
        foreach ($itemValue in $Value) {
            Assert-NoForbiddenTrueClaims -Value $itemValue -Context "$Context[$arrayIndex]"
            $arrayIndex += 1
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($propertyInfo in $Value.PSObject.Properties) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($propertyInfo.Name) -and $propertyInfo.Value -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$propertyInfo.Name]) via '$($propertyInfo.Name)'."
            }
            Assert-NoForbiddenTrueClaims -Value $propertyInfo.Value -Context "$Context.$($propertyInfo.Name)"
        }
    }
}

function Assert-AllPathFieldsAreSafe {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string]) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($keyName in $Value.Keys) {
            if ($keyName -eq "path") {
                $pathValue = Assert-NonEmptyString -Value $Value[$keyName] -Context "$Context.path"
                Assert-SafeRepoRelativeTrackedPath -PathValue $pathValue -RepositoryRoot $RepositoryRoot -Context "$Context.path"
            }
            else {
                Assert-AllPathFieldsAreSafe -Value $Value[$keyName] -RepositoryRoot $RepositoryRoot -Context "$Context.$keyName"
            }
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $arrayIndex = 0
        foreach ($itemValue in $Value) {
            Assert-AllPathFieldsAreSafe -Value $itemValue -RepositoryRoot $RepositoryRoot -Context "$Context[$arrayIndex]"
            $arrayIndex += 1
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($propertyInfo in $Value.PSObject.Properties) {
            if ($propertyInfo.Name -eq "path") {
                $pathValue = Assert-NonEmptyString -Value $propertyInfo.Value -Context "$Context.path"
                Assert-SafeRepoRelativeTrackedPath -PathValue $pathValue -RepositoryRoot $RepositoryRoot -Context "$Context.path"
            }
            else {
                Assert-AllPathFieldsAreSafe -Value $propertyInfo.Value -RepositoryRoot $RepositoryRoot -Context "$Context.$($propertyInfo.Name)"
            }
        }
    }
}

function New-ValidationCommands {
    $commands = @()
    for ($commandIndex = 0; $commandIndex -lt $script:RequiredValidationCommands.Count; $commandIndex += 1) {
        $commands += [ordered]@{
            command_id = "r16_019_validation_{0:000}" -f ($commandIndex + 1)
            command = $script:RequiredValidationCommands[$commandIndex]
            expected_result = "PASS"
            deterministic_order = $commandIndex + 1
        }
    }

    return $commands
}

function New-RefObject {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [Parameter(Mandatory = $true)][bool]$MachineProof,
        [Parameter(Mandatory = $true)][int]$Order,
        [string]$RoleId = ""
    )

    $refObject = [ordered]@{
        ref_id = $RefId
        path = (ConvertTo-NormalizedRepoPath -PathValue $PathValue)
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        machine_proof = $MachineProof
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        deterministic_order = $Order
    }

    if (-not [string]::IsNullOrWhiteSpace($RoleId)) {
        $refObject["role_id"] = $RoleId
    }

    return $refObject
}

function New-RequiredRefs {
    return [ordered]@{
        contract_ref = New-RefObject -RefId "contract_ref" -PathValue $script:RequiredRefPaths.contract_ref -SourceTask "R16-018" -ProofTreatment "committed role-run envelope contract; validator-backed contract/model proof" -MachineProof $true -Order 1
        role_memory_packs_ref = New-RefObject -RefId "role_memory_packs_ref" -PathValue $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only" -MachineProof $true -Order 2
        role_memory_pack_model_ref = New-RefObject -RefId "role_memory_pack_model_ref" -PathValue $script:RequiredRefPaths.role_memory_pack_model_ref -SourceTask "R16-006" -ProofTreatment "committed role memory pack model state artifact only" -MachineProof $true -Order 3
        context_load_plan_ref = New-RefObject -RefId "context_load_plan_ref" -PathValue $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only" -MachineProof $true -Order 4
        context_budget_estimate_ref = New-RefObject -RefId "context_budget_estimate_ref" -PathValue $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only" -MachineProof $true -Order 5
        context_budget_guard_ref = New-RefObject -RefId "context_budget_guard_ref" -PathValue $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only" -MachineProof $true -Order 6
        context_budget_guard_contract_ref = New-RefObject -RefId "context_budget_guard_contract_ref" -PathValue $script:RequiredRefPaths.context_budget_guard_contract_ref -SourceTask "R16-017" -ProofTreatment "guard contract dependency; R16-019 does not weaken it" -MachineProof $true -Order 7
        r16_authority_ref = New-RefObject -RefId "r16_authority_ref" -PathValue $script:RequiredRefPaths.r16_authority_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and status boundary; not machine proof by itself" -MachineProof $false -Order 8
    }
}

function Get-R16RoleRunEnvelopeInputBundle {
    param(
        [Parameter(Mandatory = $true)][string]$ContractPath,
        [Parameter(Mandatory = $true)][string]$RoleMemoryPacksPath,
        [Parameter(Mandatory = $true)][string]$RoleMemoryPackModelPath,
        [Parameter(Mandatory = $true)][string]$ContextLoadPlanPath,
        [Parameter(Mandatory = $true)][string]$ContextBudgetEstimatePath,
        [Parameter(Mandatory = $true)][string]$ContextBudgetGuardPath,
        [Parameter(Mandatory = $true)][string]$ContextBudgetGuardContractPath,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    Test-R16RoleRunEnvelopeContract -Path $ContractPath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16RoleMemoryPacks -PacksPath $RoleMemoryPacksPath -ModelPath $RoleMemoryPackModelPath -MemoryLayersPath "state/memory/r16_memory_layers.json" -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16ContextLoadPlan -Path $ContextLoadPlanPath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16ContextBudgetEstimate -Path $ContextBudgetEstimatePath -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R16ContextBudgetGuardReport -Path $ContextBudgetGuardPath -ContractPath $ContextBudgetGuardContractPath -RepositoryRoot $RepositoryRoot | Out-Null

    $contractObject = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot (ConvertTo-NormalizedRepoPath -PathValue $ContractPath)) -Label "R16 role-run envelope contract"
    $packsObject = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot (ConvertTo-NormalizedRepoPath -PathValue $RoleMemoryPacksPath)) -Label "R16 role memory packs"
    $loadPlanObject = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot (ConvertTo-NormalizedRepoPath -PathValue $ContextLoadPlanPath)) -Label "R16 context-load plan"
    $estimateObject = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot (ConvertTo-NormalizedRepoPath -PathValue $ContextBudgetEstimatePath)) -Label "R16 context budget estimate"
    $guardObject = Read-SingleJsonObject -Path (Join-Path $RepositoryRoot (ConvertTo-NormalizedRepoPath -PathValue $ContextBudgetGuardPath)) -Label "R16 context budget guard report"

    $rolePackMap = @{}
    foreach ($packObject in @($packsObject.role_packs)) {
        $packRoleId = [string]$packObject.role_id
        if ($rolePackMap.ContainsKey($packRoleId)) {
            throw "R16 role memory packs contain duplicate role_id '$packRoleId'."
        }
        $rolePackMap[$packRoleId] = $packObject
    }

    return [pscustomobject]@{
        Contract = $contractObject
        RoleMemoryPacks = $packsObject
        RolePackMap = $rolePackMap
        ContextLoadPlan = $loadPlanObject
        ContextBudgetEstimate = $estimateObject
        ContextBudgetGuard = $guardObject
    }
}

function New-AllowedAction {
    param(
        [Parameter(Mandatory = $true)][string]$RoleId,
        [Parameter(Mandatory = $true)][string]$RoleDisplayName,
        [Parameter(Mandatory = $true)][string]$ActionType,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        action_id = "{0}-{1}" -f $RoleId, $ActionType
        action_type = $ActionType
        action_summary = "Declared allowed action category for $RoleDisplayName from the R16-018 role catalog; not executable while the current guard is failed_closed_over_budget."
        allowed_scope = "exact_repo_relative_refs_only_state_artifact_workflow"
        dependency_ref_ids = @("contract_ref", "memory_pack_ref", "context_load_plan_ref", "context_budget_estimate_ref", "context_budget_guard_ref")
        evidence_required = $true
        deterministic_order = $Order
    }
}

function New-ForbiddenActionSet {
    param(
        [Parameter(Mandatory = $true)][object[]]$GlobalForbiddenActions,
        [Parameter(Mandatory = $true)][object[]]$RoleForbiddenActions
    )

    $combinedActions = @()
    foreach ($actionValue in @($GlobalForbiddenActions)) {
        $combinedActions += [string]$actionValue
    }
    foreach ($actionValue in @($RoleForbiddenActions)) {
        if ($combinedActions -notcontains [string]$actionValue) {
            $combinedActions += [string]$actionValue
        }
    }

    $forbiddenObjects = @()
    for ($actionIndex = 0; $actionIndex -lt $combinedActions.Count; $actionIndex += 1) {
        $forbiddenObjects += [ordered]@{
            action_id = $combinedActions[$actionIndex]
            action_type = $combinedActions[$actionIndex]
            source_model = if (@($RoleForbiddenActions | ForEach-Object { [string]$_ }) -contains $combinedActions[$actionIndex]) { "role_catalog_and_forbidden_action_model" } else { "forbidden_action_model" }
            deterministic_order = $actionIndex + 1
        }
    }

    return $forbiddenObjects
}

function New-BudgetGuardStatus {
    param([Parameter(Mandatory = $true)]$Guard)

    return [ordered]@{
        aggregate_verdict = [string]$Guard.aggregate_verdict
        estimated_tokens_upper_bound = [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound
        max_estimated_tokens_upper_bound = [int64]$Guard.evaluated_budget.max_estimated_tokens_upper_bound
        threshold_exceeded = [bool]$Guard.evaluated_budget.threshold_exceeded
        fail_closed = $true
        guard_report_ref = "state/context/r16_context_budget_guard_report.json"
        exact_provider_tokenization_claimed = $false
        exact_provider_billing_claimed = $false
        deterministic_order = 1
    }
}

function New-NoFullRepoScanAttestation {
    return [ordered]@{
        repo_relative_exact_tracked_paths_only = $true
        tracked_files_only = $true
        exact_dependency_refs_only = $true
        broad_repo_scan_allowed = $false
        broad_repo_scan_performed = $false
        full_repo_scan_allowed = $false
        full_repo_scan_performed = $false
        wildcard_paths_allowed = $false
        wildcard_paths_loaded = $false
        directory_only_refs_allowed = $false
        directory_only_refs_loaded = $false
        scratch_temp_paths_allowed = $false
        scratch_temp_refs_loaded = $false
        absolute_paths_allowed = $false
        absolute_paths_loaded = $false
        parent_traversal_allowed = $false
        parent_traversal_refs_loaded = $false
        url_or_remote_refs_allowed = $false
        url_or_remote_refs_loaded = $false
        raw_chat_history_loading_allowed = $false
        raw_chat_history_loaded = $false
        report_as_machine_proof_allowed = $false
    }
}

function New-RoleMemoryPackRef {
    param(
        [Parameter(Mandatory = $true)]$RolePack,
        [Parameter(Mandatory = $true)][string]$RoleId,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        ref_id = "memory_pack_ref"
        path = "state/memory/r16_role_memory_packs.json"
        source_task = "R16-007"
        proof_treatment = "committed generated role memory pack state artifact only"
        machine_proof = $true
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        role_id = $RoleId
        role_pack_lookup = [ordered]@{
            lookup_field = "role_packs.role_id"
            lookup_value = $RoleId
            lookup_status = "matched_exactly_once"
            pack_display_name = [string]$RolePack.display_name
            display_name_treatment = "contract role_display_name remains authoritative for the envelope"
        }
        deterministic_order = $Order
    }
}

function New-R16RoleRunEnvelopeObject {
    param(
        [Parameter(Mandatory = $true)]$RoleCatalogEntry,
        [Parameter(Mandatory = $true)]$RolePack,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)]$Refs
    )

    $roleId = [string]$RoleCatalogEntry.role_id
    $displayName = [string]$RoleCatalogEntry.role_display_name
    $roleOrder = [int]$RoleCatalogEntry.deterministic_order
    $allowedActions = @()
    $allowedCategories = @($RoleCatalogEntry.allowed_action_categories)
    for ($actionIndex = 0; $actionIndex -lt $allowedCategories.Count; $actionIndex += 1) {
        $allowedActions += New-AllowedAction -RoleId $roleId -RoleDisplayName $displayName -ActionType ([string]$allowedCategories[$actionIndex]) -Order ($actionIndex + 1)
    }

    $guardStatus = New-BudgetGuardStatus -Guard $Guard
    $blockedReason = "R16-017 context budget guard report aggregate_verdict failed_closed_over_budget blocks this R16-019 role-run envelope; estimated_tokens_upper_bound $($guardStatus.estimated_tokens_upper_bound) exceeds max_estimated_tokens_upper_bound $($guardStatus.max_estimated_tokens_upper_bound)."
    $memoryRef = New-RoleMemoryPackRef -RolePack $RolePack -RoleId $roleId -Order 1

    return [ordered]@{
        envelope_id = "r16-019-role-run-envelope-{0:000}-{1}" -f $roleOrder, $roleId
        role_id = $roleId
        role_display_name = $displayName
        source_task = "R16-019"
        target_task_or_card_ref = [ordered]@{
            ref_id = "r16_phase_5_future_role_workflow"
            path = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
            target_task_range = "R16-020 through R16-026 planned only"
            proof_treatment = "milestone authority reference only; not a handoff packet or transition gate"
            deterministic_order = 1
        }
        allowed_actions = $allowedActions
        forbidden_actions = New-ForbiddenActionSet -GlobalForbiddenActions @($Refs.contract.forbidden_action_model.required_forbidden_actions) -RoleForbiddenActions @($RoleCatalogEntry.forbidden_action_categories)
        required_inputs = [string[]]$script:RequiredInputRefs
        memory_pack_ref = $memoryRef
        context_load_plan_ref = Copy-JsonObject -Value $Refs.required.context_load_plan_ref
        context_budget_estimate_ref = Copy-JsonObject -Value $Refs.required.context_budget_estimate_ref
        context_budget_guard_ref = Copy-JsonObject -Value $Refs.required.context_budget_guard_ref
        budget_guard_status = $guardStatus
        no_full_repo_scan_attestation = New-NoFullRepoScanAttestation
        evidence_refs = @(
            (Copy-JsonObject -Value $Refs.required.contract_ref),
            (Copy-JsonObject -Value $Refs.required.role_memory_packs_ref),
            (Copy-JsonObject -Value $Refs.required.role_memory_pack_model_ref),
            (Copy-JsonObject -Value $Refs.required.context_load_plan_ref),
            (Copy-JsonObject -Value $Refs.required.context_budget_estimate_ref),
            (Copy-JsonObject -Value $Refs.required.context_budget_guard_ref),
            (Copy-JsonObject -Value $Refs.required.context_budget_guard_contract_ref),
            (Copy-JsonObject -Value $Refs.required.r16_authority_ref)
        )
        output_expectations = [string[]]@(
            "Record only bounded state-artifact expectations for the role.",
            "Do not execute role actions while the current guard remains failed_closed_over_budget.",
            "Any later executable workflow requires a later explicit machine-checkable mitigation and task authority."
        )
        handoff_constraints = [ordered]@{
            handoff_packet_implemented = $false
            raci_transition_gate_implemented = $false
            workflow_drill_run = $false
            may_not_transfer_execution = $true
            blocked_by_budget_guard = $true
            deterministic_order = 1
        }
        non_claims = [string[]]@(
            "this envelope is not runtime execution",
            "this envelope is not an autonomous agent",
            "this envelope does not implement runtime memory",
            "this envelope does not implement retrieval runtime",
            "this envelope does not implement vector search runtime",
            "this envelope does not implement product runtime",
            "this envelope does not implement external integrations",
            "this envelope does not implement a RACI transition gate",
            "this envelope does not implement a handoff packet",
            "this envelope does not run a workflow drill",
            "R16-020 through R16-026 remain planned only"
        )
        envelope_execution_status = "blocked"
        executable = $false
        blocked_reason = $blockedReason
        deterministic_order = $roleOrder
    }
}

function New-CurrentPosture {
    return [ordered]@{
        active_through_task = "R16-019"
        complete_tasks = [string[]](1..19 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        planned_tasks = [string[]](20..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        role_run_envelope_contract_defined = $true
        role_run_envelope_generator_exists = $true
        generated_role_run_envelopes_exist = $true
        generated_role_run_envelopes_are_state_artifacts_only = $true
        generated_role_run_envelopes_are_runtime_execution = $false
        all_generated_envelopes_blocked_by_guard = $true
        raci_transition_gate_exists = $false
        handoff_packet_exists = $false
        workflow_drill_exists = $false
        r16_020_or_later_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
    }
}

function New-PreservedBoundaries {
    return [ordered]@{
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
}

function New-GenerationMode {
    return [ordered]@{
        deterministic_local_generation = $true
        deterministic_output_ordering = $true
        role_run_envelope_generator_implemented = $true
        generated_role_run_envelopes_exist = $true
        generated_role_run_envelopes_are_state_artifacts = $true
        reads_role_run_envelope_contract = $true
        reads_role_memory_packs = $true
        reads_context_load_plan = $true
        reads_context_budget_estimate = $true
        reads_context_budget_guard_report = $true
        all_envelopes_blocked_by_failed_closed_over_budget_guard = $true
        generated_role_run_envelopes_are_runtime_execution = $false
        runtime_executor_implemented = $false
        envelopes_executable = $false
        mitigation_created = $false
        r16_017_guard_weakened = $false
        runtime_memory_implemented = $false
        runtime_memory_loading_implemented = $false
        retrieval_runtime_implemented = $false
        vector_search_runtime_implemented = $false
        product_runtime_implemented = $false
        actual_autonomous_agents_implemented = $false
        external_integrations_implemented = $false
        raci_transition_gate_implemented = $false
        handoff_packet_implemented = $false
        workflow_drill_run = $false
        r16_020_or_later_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
        exact_provider_tokenization_claimed = $false
        exact_provider_billing_claimed = $false
        solved_codex_compaction = $false
        solved_codex_reliability = $false
    }
}

function New-R16RoleRunEnvelopesObject {
    [CmdletBinding()]
    param(
        [string]$ContractPath = "contracts/workflow/r16_role_run_envelope.contract.json",
        [string]$RoleMemoryPacksPath = "state/memory/r16_role_memory_packs.json",
        [string]$RoleMemoryPackModelPath = "state/memory/r16_role_memory_pack_model.json",
        [string]$ContextLoadPlanPath = "state/context/r16_context_load_plan.json",
        [string]$ContextBudgetEstimatePath = "state/context/r16_context_budget_estimate.json",
        [string]$ContextBudgetGuardPath = "state/context/r16_context_budget_guard_report.json",
        [string]$ContextBudgetGuardContractPath = "contracts/context/r16_context_budget_guard.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($pathValue in @($ContractPath, $RoleMemoryPacksPath, $RoleMemoryPackModelPath, $ContextLoadPlanPath, $ContextBudgetEstimatePath, $ContextBudgetGuardPath, $ContextBudgetGuardContractPath, $script:RequiredRefPaths.r16_authority_ref)) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $pathValue -RepositoryRoot $resolvedRoot -Context "R16 role-run envelope generator input"
    }

    $bundle = Get-R16RoleRunEnvelopeInputBundle -ContractPath $ContractPath -RoleMemoryPacksPath $RoleMemoryPacksPath -RoleMemoryPackModelPath $RoleMemoryPackModelPath -ContextLoadPlanPath $ContextLoadPlanPath -ContextBudgetEstimatePath $ContextBudgetEstimatePath -ContextBudgetGuardPath $ContextBudgetGuardPath -ContextBudgetGuardContractPath $ContextBudgetGuardContractPath -RepositoryRoot $resolvedRoot
    if ([string]$bundle.ContextBudgetGuard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "R16-019 requires current context budget guard aggregate_verdict $script:GuardVerdict."
    }

    $requiredRefs = New-RequiredRefs
    $envelopes = @()
    $roleCatalog = @($bundle.Contract.role_catalog | Sort-Object -Property deterministic_order)
    foreach ($roleEntry in $roleCatalog) {
        $roleIdValue = [string]$roleEntry.role_id
        if (-not $bundle.RolePackMap.ContainsKey($roleIdValue)) {
            throw "R16 role memory packs do not expose a clean per-role lookup for '$roleIdValue'."
        }
        $envelopes += New-R16RoleRunEnvelopeObject -RoleCatalogEntry $roleEntry -RolePack $bundle.RolePackMap[$roleIdValue] -Guard $bundle.ContextBudgetGuard -Refs ([pscustomobject]@{ contract = $bundle.Contract; required = $requiredRefs })
    }

    $inputHead = Invoke-GitScalar -Arguments @("rev-parse", "HEAD") -RepositoryRoot $resolvedRoot
    $inputTree = Invoke-GitScalar -Arguments @("rev-parse", "HEAD^{tree}") -RepositoryRoot $resolvedRoot

    return [ordered]@{
        artifact_type = "r16_role_run_envelopes"
        envelope_version = $script:EnvelopeVersion
        role_run_envelopes_artifact_id = $script:EnvelopeArtifactId
        source_milestone = $script:R16Milestone
        source_task = "R16-019"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [ordered]@{
            input_head = $inputHead
            input_tree = $inputTree
            source_boundary = "deterministic local generation from exact committed refs only"
        }
        contract_ref = $requiredRefs.contract_ref
        role_memory_packs_ref = $requiredRefs.role_memory_packs_ref
        role_memory_pack_model_ref = $requiredRefs.role_memory_pack_model_ref
        context_load_plan_ref = $requiredRefs.context_load_plan_ref
        context_budget_estimate_ref = $requiredRefs.context_budget_estimate_ref
        context_budget_guard_ref = $requiredRefs.context_budget_guard_ref
        context_budget_guard_contract_ref = $requiredRefs.context_budget_guard_contract_ref
        r16_authority_ref = $requiredRefs.r16_authority_ref
        generation_mode = New-GenerationMode
        envelopes = $envelopes
        current_posture = New-CurrentPosture
        preserved_boundaries = New-PreservedBoundaries
        finding_summary = [ordered]@{
            role_catalog_count = $roleCatalog.Count
            envelope_count = $envelopes.Count
            blocked_envelope_count = $envelopes.Count
            executable_envelope_count = 0
            budget_guard_block_count = $envelopes.Count
            fail_count = 0
            policy_violation_count = 0
        }
        aggregate_verdict = $script:AggregateVerdict
        validation_commands = New-ValidationCommands
        non_claims = [string[]]$script:RequiredNonClaims
    }
}

function Assert-RefObject {
    param(
        [Parameter(Mandatory = $true)]$RefObject,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$ExpectedPath = "",
        [string]$ExpectedRefId = ""
    )

    $refValue = Assert-ObjectValue -Value $RefObject -Context $Context
    foreach ($fieldName in @("ref_id", "path", "source_task", "proof_treatment", "machine_proof", "exact_path_only", "broad_scan_allowed", "wildcard_allowed", "deterministic_order")) {
        Get-RequiredProperty -InputObject $refValue -Name $fieldName -Context $Context | Out-Null
    }

    $pathValue = Assert-NonEmptyString -Value $refValue.path -Context "$Context path"
    Assert-SafeRepoRelativeTrackedPath -PathValue $pathValue -RepositoryRoot $RepositoryRoot -Context $Context
    if (-not [string]::IsNullOrWhiteSpace($ExpectedPath) -and (ConvertTo-NormalizedRepoPath -PathValue $pathValue) -ne $ExpectedPath) {
        throw "$Context path must be '$ExpectedPath'."
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedRefId) -and [string]$refValue.ref_id -ne $ExpectedRefId) {
        throw "$Context ref_id must be '$ExpectedRefId'."
    }
    if ((Assert-BooleanValue -Value $refValue.exact_path_only -Context "$Context exact_path_only") -ne $true) {
        throw "$Context exact_path_only must be True."
    }
    if ((Assert-BooleanValue -Value $refValue.broad_scan_allowed -Context "$Context broad_scan_allowed") -ne $false) {
        throw "$Context broad_scan_allowed must be False."
    }
    if ((Assert-BooleanValue -Value $refValue.wildcard_allowed -Context "$Context wildcard_allowed") -ne $false) {
        throw "$Context wildcard_allowed must be False."
    }
    Assert-BooleanValue -Value $refValue.machine_proof -Context "$Context machine_proof" | Out-Null

    if ((ConvertTo-NormalizedRepoPath -PathValue $pathValue) -like "governance/reports/*" -and [bool]$refValue.machine_proof) {
        throw "$Context rejects report-as-machine-proof misuse for '$pathValue'."
    }
}

function Assert-GenerationMode {
    param(
        [Parameter(Mandatory = $true)]$GenerationMode,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $modeObject = Assert-ObjectValue -Value $GenerationMode -Context $Context
    foreach ($trueField in @("deterministic_local_generation", "deterministic_output_ordering", "role_run_envelope_generator_implemented", "generated_role_run_envelopes_exist", "generated_role_run_envelopes_are_state_artifacts", "all_envelopes_blocked_by_failed_closed_over_budget_guard")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $modeObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("generated_role_run_envelopes_are_runtime_execution", "runtime_executor_implemented", "envelopes_executable", "mitigation_created", "r16_017_guard_weakened", "runtime_memory_implemented", "runtime_memory_loading_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "raci_transition_gate_implemented", "handoff_packet_implemented", "workflow_drill_run", "r16_020_or_later_implementation_claimed", "r16_027_or_later_task_exists", "exact_provider_tokenization_claimed", "exact_provider_billing_claimed", "solved_codex_compaction", "solved_codex_reliability")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $modeObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string]$postureObject.active_through_task -ne "R16-019") {
        throw "$Context active_through_task must be R16-019."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks") -Expected ([string[]](1..19 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks") -Expected ([string[]](20..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"
    foreach ($trueField in @("role_run_envelope_contract_defined", "role_run_envelope_generator_exists", "generated_role_run_envelopes_exist", "generated_role_run_envelopes_are_state_artifacts_only", "all_generated_envelopes_blocked_by_guard")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("generated_role_run_envelopes_are_runtime_execution", "raci_transition_gate_exists", "handoff_packet_exists", "workflow_drill_exists", "r16_020_or_later_implementation_claimed", "r16_027_or_later_task_exists")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    $r13Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r13" -Context $Context) -Context "$Context r13"
    if ($r13Boundary.status -ne "failed_partial_through_r13_018_only") {
        throw "$Context r13 status must preserve failed_partial_through_r13_018_only."
    }
    if ((Assert-BooleanValue -Value $r13Boundary.closed -Context "$Context r13 closed") -ne $false) {
        throw "$Context r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $r13Boundary.partial_gates_converted_to_passed -Context "$Context r13 partial_gates_converted_to_passed") -ne $false) {
        throw "$Context r13 partial_gates_converted_to_passed must be False."
    }

    $r14Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    if ($r14Boundary.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    if ((Assert-BooleanValue -Value $r14Boundary.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }

    $r15Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"
    if ($r15Boundary.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
    if ((Assert-BooleanValue -Value $r15Boundary.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r15Boundary.stale_generated_from_caveat_preserved -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale_generated_from_caveat_preserved must be True."
    }
}

function Assert-BudgetGuardStatus {
    param(
        [Parameter(Mandatory = $true)]$Status,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $statusObject = Assert-ObjectValue -Value $Status -Context $Context
    if ([string]$statusObject.aggregate_verdict -ne $script:GuardVerdict) {
        throw "$Context aggregate_verdict must be $script:GuardVerdict."
    }
    if ([int64]$statusObject.estimated_tokens_upper_bound -ne [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound) {
        throw "$Context estimated_tokens_upper_bound must preserve $($Guard.evaluated_budget.estimated_tokens_upper_bound)."
    }
    if ([int64]$statusObject.max_estimated_tokens_upper_bound -ne $script:MaxEstimatedUpperBound) {
        throw "$Context max_estimated_tokens_upper_bound must preserve $script:MaxEstimatedUpperBound."
    }
    if ((Assert-BooleanValue -Value $statusObject.threshold_exceeded -Context "$Context threshold_exceeded") -ne $true) {
        throw "$Context threshold_exceeded must be True."
    }
    if ((Assert-BooleanValue -Value $statusObject.fail_closed -Context "$Context fail_closed") -ne $true) {
        throw "$Context fail_closed must be True."
    }
}

function Assert-NoFullRepoScanAttestation {
    param(
        [Parameter(Mandatory = $true)]$Attestation,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $attestationObject = Assert-ObjectValue -Value $Attestation -Context $Context
    foreach ($trueField in @("repo_relative_exact_tracked_paths_only", "tracked_files_only", "exact_dependency_refs_only")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $attestationObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_paths_loaded", "directory_only_refs_allowed", "directory_only_refs_loaded", "scratch_temp_paths_allowed", "scratch_temp_refs_loaded", "absolute_paths_allowed", "absolute_paths_loaded", "parent_traversal_allowed", "parent_traversal_refs_loaded", "url_or_remote_refs_allowed", "url_or_remote_refs_loaded", "raw_chat_history_loading_allowed", "raw_chat_history_loaded", "report_as_machine_proof_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $attestationObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-Envelope {
    param(
        [Parameter(Mandatory = $true)]$Envelope,
        [Parameter(Mandatory = $true)]$ContractRole,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [Parameter(Mandatory = $true)][string[]]$GlobalForbiddenActions
    )

    $envelopeObject = Assert-ObjectValue -Value $Envelope -Context "envelope[$ExpectedOrder]"
    foreach ($fieldName in $script:RequiredEnvelopeFields) {
        Get-RequiredProperty -InputObject $envelopeObject -Name $fieldName -Context "envelope[$ExpectedOrder]" | Out-Null
    }

    $roleId = [string]$ContractRole.role_id
    if ([string]$envelopeObject.role_id -ne $roleId) {
        throw "envelope[$ExpectedOrder] role_id must match canonical role '$roleId'."
    }
    if ([string]$envelopeObject.role_display_name -ne [string]$ContractRole.role_display_name) {
        throw "envelope[$ExpectedOrder] role display name mismatch for '$roleId'."
    }
    if ([string]$envelopeObject.source_task -ne "R16-019") {
        throw "envelope[$ExpectedOrder] source_task must be R16-019."
    }
    if ((Assert-IntegerValue -Value $envelopeObject.deterministic_order -Context "envelope[$ExpectedOrder] deterministic_order") -ne $ExpectedOrder) {
        throw "envelope[$ExpectedOrder] deterministic_order must be $ExpectedOrder."
    }

    $requiredInputs = Assert-StringArray -Value $envelopeObject.required_inputs -Context "envelope[$ExpectedOrder] required_inputs"
    Assert-ExactStringSet -Actual $requiredInputs -Expected $script:RequiredInputRefs -Context "envelope[$ExpectedOrder] required_inputs"
    foreach ($contractRequiredInput in @($ContractRole.required_input_ref_types | ForEach-Object { [string]$_ })) {
        if ($requiredInputs -notcontains $contractRequiredInput) {
            throw "envelope[$ExpectedOrder] required_inputs must include contract input '$contractRequiredInput'."
        }
    }

    Assert-RefObject -RefObject $envelopeObject.memory_pack_ref -Context "envelope[$ExpectedOrder] memory_pack_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "memory_pack_ref"
    if ([string]$envelopeObject.memory_pack_ref.role_id -ne $roleId) {
        throw "envelope[$ExpectedOrder] memory_pack_ref role_id must be '$roleId'."
    }
    if ([string]$envelopeObject.memory_pack_ref.role_pack_lookup.lookup_status -ne "matched_exactly_once") {
        throw "envelope[$ExpectedOrder] memory_pack_ref must identify a role-specific pack where possible."
    }
    Assert-RefObject -RefObject $envelopeObject.context_load_plan_ref -Context "envelope[$ExpectedOrder] context_load_plan_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref"
    Assert-RefObject -RefObject $envelopeObject.context_budget_estimate_ref -Context "envelope[$ExpectedOrder] context_budget_estimate_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref"
    Assert-RefObject -RefObject $envelopeObject.context_budget_guard_ref -Context "envelope[$ExpectedOrder] context_budget_guard_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref"
    Assert-BudgetGuardStatus -Status $envelopeObject.budget_guard_status -Guard $Guard -Context "envelope[$ExpectedOrder] budget_guard_status"
    Assert-NoFullRepoScanAttestation -Attestation $envelopeObject.no_full_repo_scan_attestation -Context "envelope[$ExpectedOrder] no_full_repo_scan_attestation"

    $allowedActions = Assert-ObjectArray -Value $envelopeObject.allowed_actions -Context "envelope[$ExpectedOrder] allowed_actions"
    $allowedActionTypes = @($allowedActions | ForEach-Object { [string]$_.action_type })
    Assert-ExactStringSet -Actual $allowedActionTypes -Expected ([string[]]@($ContractRole.allowed_action_categories | ForEach-Object { [string]$_ })) -Context "envelope[$ExpectedOrder] allowed_actions action_type"
    for ($actionIndex = 0; $actionIndex -lt $allowedActions.Count; $actionIndex += 1) {
        foreach ($fieldName in @("action_id", "action_type", "action_summary", "allowed_scope", "dependency_ref_ids", "evidence_required", "deterministic_order")) {
            Get-RequiredProperty -InputObject $allowedActions[$actionIndex] -Name $fieldName -Context "envelope[$ExpectedOrder] allowed_actions[$actionIndex]" | Out-Null
        }
    }

    $forbiddenActions = Assert-ObjectArray -Value $envelopeObject.forbidden_actions -Context "envelope[$ExpectedOrder] forbidden_actions"
    $forbiddenTypes = @($forbiddenActions | ForEach-Object { [string]$_.action_type })
    Assert-RequiredStringsPresent -Actual $forbiddenTypes -Required $GlobalForbiddenActions -Context "envelope[$ExpectedOrder] forbidden_actions"
    Assert-RequiredStringsPresent -Actual $forbiddenTypes -Required ([string[]]@($ContractRole.forbidden_action_categories | ForEach-Object { [string]$_ })) -Context "envelope[$ExpectedOrder] forbidden_actions"

    $evidenceRefs = Assert-ObjectArray -Value $envelopeObject.evidence_refs -Context "envelope[$ExpectedOrder] evidence_refs"
    $evidencePaths = @()
    for ($evidenceIndex = 0; $evidenceIndex -lt $evidenceRefs.Count; $evidenceIndex += 1) {
        Assert-RefObject -RefObject $evidenceRefs[$evidenceIndex] -Context "envelope[$ExpectedOrder] evidence_refs[$evidenceIndex]" -RepositoryRoot $RepositoryRoot
        $evidencePaths += [string]$evidenceRefs[$evidenceIndex].path
    }
    Assert-RequiredStringsPresent -Actual $evidencePaths -Required ([string[]]$script:RequiredRefPaths.Values) -Context "envelope[$ExpectedOrder] evidence_refs path"

    Assert-ObjectValue -Value $envelopeObject.handoff_constraints -Context "envelope[$ExpectedOrder] handoff_constraints" | Out-Null
    foreach ($falseField in @("handoff_packet_implemented", "raci_transition_gate_implemented", "workflow_drill_run")) {
        if ((Assert-BooleanValue -Value $envelopeObject.handoff_constraints.$falseField -Context "envelope[$ExpectedOrder] handoff_constraints $falseField") -ne $false) {
            throw "envelope[$ExpectedOrder] handoff_constraints $falseField must be False."
        }
    }
    if ((Assert-BooleanValue -Value $envelopeObject.executable -Context "envelope[$ExpectedOrder] executable") -ne $false) {
        throw "envelope[$ExpectedOrder] executable envelope while guard is failed_closed_over_budget."
    }
    if ([string]$envelopeObject.envelope_execution_status -notin @("blocked", "not_executable")) {
        throw "envelope[$ExpectedOrder] envelope_execution_status must be blocked or not_executable."
    }
    if ([string]$envelopeObject.blocked_reason -notmatch "failed_closed_over_budget") {
        throw "envelope[$ExpectedOrder] blocked_reason must reference failed_closed_over_budget."
    }

    Assert-StringArray -Value $envelopeObject.output_expectations -Context "envelope[$ExpectedOrder] output_expectations" | Out-Null
    Assert-StringArray -Value $envelopeObject.non_claims -Context "envelope[$ExpectedOrder] non_claims" | Out-Null
}

function Test-R16RoleRunEnvelopesObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [string]$SourceLabel = "R16 role-run envelopes",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Artifact -Name $fieldName -Context $SourceLabel | Out-Null
    }

    if ($Artifact.artifact_type -ne "r16_role_run_envelopes") {
        throw "$SourceLabel artifact_type must be r16_role_run_envelopes."
    }
    if ($Artifact.envelope_version -ne $script:EnvelopeVersion -or $Artifact.source_task -ne "R16-019") {
        throw "$SourceLabel envelope_version or source_task is incorrect."
    }
    if ($Artifact.source_milestone -ne $script:R16Milestone -or $Artifact.repository -ne $script:Repository -or $Artifact.branch -ne $script:Branch) {
        throw "$SourceLabel milestone, repository, or branch metadata is incorrect."
    }

    Assert-NoForbiddenTrueClaims -Value $Artifact -Context $SourceLabel
    Assert-NoForbiddenPositiveStringClaims -Values ([string[]]@(Get-StringValuesFromObject -Value $Artifact)) -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Artifact -RepositoryRoot $resolvedRoot -Context $SourceLabel

    Assert-RefObject -RefObject $Artifact.contract_ref -Context "$SourceLabel contract_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.contract_ref -ExpectedRefId "contract_ref"
    Assert-RefObject -RefObject $Artifact.role_memory_packs_ref -Context "$SourceLabel role_memory_packs_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "role_memory_packs_ref"
    Assert-RefObject -RefObject $Artifact.role_memory_pack_model_ref -Context "$SourceLabel role_memory_pack_model_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_memory_pack_model_ref -ExpectedRefId "role_memory_pack_model_ref"
    Assert-RefObject -RefObject $Artifact.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref"
    Assert-RefObject -RefObject $Artifact.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref"
    Assert-RefObject -RefObject $Artifact.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref"
    Assert-RefObject -RefObject $Artifact.context_budget_guard_contract_ref -Context "$SourceLabel context_budget_guard_contract_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_contract_ref -ExpectedRefId "context_budget_guard_contract_ref"
    Assert-RefObject -RefObject $Artifact.r16_authority_ref -Context "$SourceLabel r16_authority_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.r16_authority_ref -ExpectedRefId "r16_authority_ref"

    Assert-GenerationMode -GenerationMode $Artifact.generation_mode -Context "$SourceLabel generation_mode"
    Assert-CurrentPosture -Posture $Artifact.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Artifact.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $contractObject = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.contract_ref) -Label "R16 role-run envelope contract"
    $guardObject = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    if ([string]$guardObject.aggregate_verdict -ne $script:GuardVerdict) {
        throw "$SourceLabel current guard report must remain $script:GuardVerdict."
    }

    $envelopes = Assert-ObjectArray -Value $Artifact.envelopes -Context "$SourceLabel envelopes"
    $roleIds = @($envelopes | ForEach-Object { [string]$_.role_id })
    Assert-ExactStringSet -Actual $roleIds -Expected $script:RequiredRoleIds -Context "$SourceLabel envelopes role_id"
    if (@($roleIds | Select-Object -Unique).Count -ne $roleIds.Count) {
        throw "$SourceLabel contains duplicate role envelope."
    }

    $contractRoles = @($contractObject.role_catalog | Sort-Object -Property deterministic_order)
    for ($roleIndex = 0; $roleIndex -lt $contractRoles.Count; $roleIndex += 1) {
        $expectedRoleId = [string]$contractRoles[$roleIndex].role_id
        $matchingEnvelope = @($envelopes | Where-Object { [string]$_.role_id -eq $expectedRoleId })
        if ($matchingEnvelope.Count -ne 1) {
            throw "$SourceLabel missing role envelope for canonical role '$expectedRoleId'."
        }
        Assert-Envelope -Envelope $matchingEnvelope[0] -ContractRole $contractRoles[$roleIndex] -Guard $guardObject -RepositoryRoot $resolvedRoot -ExpectedOrder ([int]$contractRoles[$roleIndex].deterministic_order) -GlobalForbiddenActions ([string[]]@($contractObject.forbidden_action_model.required_forbidden_actions | ForEach-Object { [string]$_ }))
    }

    $summary = Assert-ObjectValue -Value $Artifact.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$summary.envelope_count -ne 8 -or [int64]$summary.blocked_envelope_count -ne 8 -or [int64]$summary.executable_envelope_count -ne 0) {
        throw "$SourceLabel finding_summary must record eight blocked and zero executable envelopes."
    }
    if ([string]$Artifact.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be $script:AggregateVerdict."
    }

    $commands = Assert-ObjectArray -Value $Artifact.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($commands | ForEach-Object { [string]$_.command })
    Assert-RequiredStringsPresent -Actual $commandValues -Required $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"
    $nonClaims = Assert-StringArray -Value $Artifact.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ArtifactId = $Artifact.role_run_envelopes_artifact_id
        SourceTask = $Artifact.source_task
        ActiveThroughTask = $Artifact.current_posture.active_through_task
        PlannedTaskStart = $Artifact.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Artifact.current_posture.planned_tasks[-1]
        EnvelopeCount = $envelopes.Count
        BlockedEnvelopeCount = [int64]$summary.blocked_envelope_count
        ExecutableEnvelopeCount = [int64]$summary.executable_envelope_count
        AggregateVerdict = $Artifact.aggregate_verdict
        BudgetGuardVerdict = $guardObject.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guardObject.evaluated_budget.estimated_tokens_upper_bound
        MaxEstimatedTokensUpperBound = [int64]$guardObject.evaluated_budget.max_estimated_tokens_upper_bound
    }
}

function Test-R16RoleRunEnvelopes {
    [CmdletBinding()]
    param(
        [string]$Path = "state/workflow/r16_role_run_envelopes.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $artifact = Read-SingleJsonObject -Path $resolvedPath -Label "R16 role-run envelopes"
    return Test-R16RoleRunEnvelopesObject -Artifact $artifact -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16RoleRunEnvelopes {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/workflow/r16_role_run_envelopes.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $artifact = New-R16RoleRunEnvelopesObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $artifact -PathValue $resolvedOutput
    $validation = Test-R16RoleRunEnvelopes -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        ArtifactId = $validation.ArtifactId
        EnvelopeCount = $validation.EnvelopeCount
        BlockedEnvelopeCount = $validation.BlockedEnvelopeCount
        ExecutableEnvelopeCount = $validation.ExecutableEnvelopeCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        BudgetGuardVerdict = $validation.BudgetGuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        MaxEstimatedTokensUpperBound = $validation.MaxEstimatedTokensUpperBound
    }
}

function New-R16RoleRunEnvelopeGeneratorFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_role_run_envelope_generator",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validArtifact = New-R16RoleRunEnvelopesObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validArtifact -PathValue (Join-Path $fixtureRootPath "valid_role_run_envelopes.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_role_run_envelopes.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.envelopes' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'envelopes'")
        "invalid_missing_role_envelope.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_envelope" -MutationPath '$.envelopes' -MutationValue "__REMOVE_ROLE:qa__" -ExpectedFailure @("envelopes role_id", "qa")
        "invalid_duplicate_role_envelope.json" = New-MutationFixtureSpec -FixtureId "invalid_duplicate_role_envelope" -MutationPath '$.envelopes' -MutationValue "__DUPLICATE_FIRST_ITEM__" -ExpectedFailure @("envelopes role_id", "must contain exactly")
        "invalid_role_id.json" = New-MutationFixtureSpec -FixtureId "invalid_role_id" -MutationPath '$.envelopes[0].role_id' -MutationValue "invalid_role" -ExpectedFailure @("envelopes role_id", "must contain exactly")
        "invalid_role_display_name_mismatch.json" = New-MutationFixtureSpec -FixtureId "invalid_role_display_name_mismatch" -MutationPath '$.envelopes[0].role_display_name' -MutationValue "Operator Mismatch" -ExpectedFailure @("role display name mismatch")
        "invalid_missing_memory_pack_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_memory_pack_ref" -MutationPath '$.envelopes[0].memory_pack_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("memory_pack_ref")
        "invalid_missing_context_load_plan_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_load_plan_ref" -MutationPath '$.envelopes[0].context_load_plan_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("context_load_plan_ref")
        "invalid_missing_context_budget_estimate_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_estimate_ref" -MutationPath '$.envelopes[0].context_budget_estimate_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("context_budget_estimate_ref")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.envelopes[0].context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("context_budget_guard_ref")
        "invalid_missing_budget_guard_status.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_budget_guard_status" -MutationPath '$.envelopes[0].budget_guard_status' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("budget_guard_status")
        "invalid_executable_failed_closed_guard.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_failed_closed_guard" -MutationPath '$.envelopes[0].executable' -MutationValue $true -ExpectedFailure @("executable envelope", "failed_closed_over_budget")
        "invalid_blocked_reason_missing_failed_closed_over_budget.json" = New-MutationFixtureSpec -FixtureId "invalid_blocked_reason_missing_failed_closed_over_budget" -MutationPath '$.envelopes[0].blocked_reason' -MutationValue "blocked without naming the guard verdict" -ExpectedFailure @("blocked_reason", "failed_closed_over_budget")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "state/memory/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "state/memory/" -ExpectedFailure @("directory-only ref")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.envelopes[0].no_full_repo_scan_attestation.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.envelopes[0].no_full_repo_scan_attestation.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "scratch/r16_role_run_envelope.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "C:/tmp/r16_role_run_envelope.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "../state/memory/r16_role_memory_packs.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.envelopes[0].memory_pack_ref.path' -MutationValue "https://example.invalid/r16_role_memory_packs.json" -ExpectedFailure @("URL or remote ref")
        "invalid_raw_chat_history_loading_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_loading_claim" -MutationPath '$.envelopes[0].no_full_repo_scan_attestation.raw_chat_history_loaded' -MutationValue $true -ExpectedFailure @("raw chat history loading claim")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.generation_mode.generated_reports_as_machine_proof_allowed' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.envelopes[0].budget_guard_status.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.envelopes[0].budget_guard_status.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.generation_mode.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.generation_mode.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.generation_mode.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.generation_mode.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.generation_mode.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.generation_mode.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_raci_transition_gate_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_raci_transition_gate_implementation_claim" -MutationPath '$.generation_mode.raci_transition_gate_implemented' -MutationValue $true -ExpectedFailure @("RACI transition gate implementation claim")
        "invalid_handoff_packet_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_handoff_packet_implementation_claim" -MutationPath '$.generation_mode.handoff_packet_implemented' -MutationValue $true -ExpectedFailure @("handoff packet implementation claim")
        "invalid_workflow_drill_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_workflow_drill_claim" -MutationPath '$.generation_mode.workflow_drill_run' -MutationValue $true -ExpectedFailure @("workflow drill claim")
        "invalid_r16_020_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_020_implementation_claim" -MutationPath '$.current_posture.r16_020_or_later_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-020 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_027_or_later_task_claim" -MutationPath '$.current_posture.r16_027_or_later_task_exists' -MutationValue $true -ExpectedFailure @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_closure_or_partial_gate_conversion_claim" -MutationPath '$.preserved_boundaries.r13.closed' -MutationValue $true -ExpectedFailure @("R13 closure claim", "r13", "closed must be False")
        "invalid_r14_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r14_caveat_removal" -MutationPath '$.preserved_boundaries.r14.caveats_removed' -MutationValue $true -ExpectedFailure @("R14 caveat removal", "r14", "caveat removal")
        "invalid_r15_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r15_caveat_removal" -MutationPath '$.preserved_boundaries.r15.caveats_removed' -MutationValue $true -ExpectedFailure @("R15 caveat removal", "r15", "caveat removal")
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        Write-StableJsonFile -InputObject $fixtureSpecs[$fixtureName] -PathValue (Join-Path $fixtureRootPath $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_role_run_envelopes.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16RoleRunEnvelopesObject, New-R16RoleRunEnvelopes, Test-R16RoleRunEnvelopesObject, Test-R16RoleRunEnvelopes, New-R16RoleRunEnvelopeGeneratorFixtureFiles, ConvertTo-StableJson
