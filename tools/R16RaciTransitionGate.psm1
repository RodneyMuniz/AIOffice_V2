Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeGenerator.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:GateVersion = "v1"
$script:GateId = "aioffice-r16-020-raci-transition-gate-v1"
$script:AggregateVerdict = "failed_closed_all_transitions_blocked_by_budget_guard"
$script:GuardVerdict = "failed_closed_over_budget"
$script:MaxEstimatedUpperBound = 150000

$script:RequiredTopLevelFields = [string[]]@(
    "artifact_type",
    "gate_version",
    "gate_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "role_run_envelopes_ref",
    "role_run_envelope_contract_ref",
    "context_budget_guard_ref",
    "context_budget_estimate_ref",
    "context_load_plan_ref",
    "role_memory_packs_ref",
    "card_state_ref",
    "gate_mode",
    "evaluated_transitions",
    "blocked_transition_count",
    "allowed_transition_count",
    "required_evidence_policy",
    "allowed_action_policy",
    "no_full_repo_scan_policy",
    "current_posture",
    "preserved_boundaries",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "non_claims"
)

$script:RequiredTransitionFields = [string[]]@(
    "transition_id",
    "source_role_id",
    "target_role_id",
    "action_type",
    "card_state",
    "source_envelope_id",
    "target_envelope_id",
    "source_role_exists",
    "target_role_exists",
    "source_envelope_executable",
    "target_envelope_executable",
    "action_allowed_by_source_role",
    "required_evidence_refs",
    "required_evidence_refs_valid",
    "context_budget_guard_verdict",
    "context_budget_guard_allows_execution",
    "decision",
    "fail_closed",
    "execution_permitted",
    "blocked_reasons",
    "deterministic_order"
)

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

$script:RequiredRefPaths = [ordered]@{
    role_run_envelopes_ref = "state/workflow/r16_role_run_envelopes.json"
    role_run_envelope_contract_ref = "contracts/workflow/r16_role_run_envelope.contract.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    role_memory_packs_ref = "state/memory/r16_role_memory_packs.json"
    card_state_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredEvidencePaths = [string[]]@(
    "state/workflow/r16_role_run_envelopes.json",
    "contracts/workflow/r16_role_run_envelope.contract.json",
    "state/context/r16_context_budget_guard_report.json",
    "state/context/r16_context_budget_estimate.json",
    "state/context/r16_context_load_plan.json",
    "state/memory/r16_role_memory_packs.json",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_raci_transition_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_raci_transition_gate_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_raci_transition_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_role_run_envelopes.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_role_run_envelope_generator.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-020 bounded RACI transition gate validator and report artifact only",
    "current generated envelopes are not executable",
    "transitions requiring executable envelopes are blocked while guard is failed_closed_over_budget",
    "no executable transitions while guard is failed_closed_over_budget",
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
    "R16-021 through R16-026 remain planned only",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved"
)

$script:ForbiddenTrueBooleanClaims = @{
    broad_repo_scan_allowed = "broad repo scan claim"
    broad_repo_scan_performed = "broad repo scan claim"
    broad_repo_scan_claimed = "broad repo scan claim"
    full_repo_scan_allowed = "full repo scan claim"
    full_repo_scan_performed = "full repo scan claim"
    full_repo_scan_claimed = "full repo scan claim"
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
    raw_chat_history_as_evidence_allowed = "raw chat history evidence claim"
    raw_chat_history_loading_allowed = "raw chat history evidence claim"
    raw_chat_history_loaded = "raw chat history evidence claim"
    generated_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    report_as_machine_proof_allowed = "report-as-machine-proof misuse"
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
    handoff_packet_implemented = "handoff packet implementation claim"
    handoff_packet_generated = "handoff packet implementation claim"
    workflow_drill_run = "workflow drill claim"
    workflow_drill_implemented = "workflow drill claim"
    r16_021_implementation_claimed = "R16-021 implementation claim"
    r16_021_or_later_implementation_claimed = "R16-021 implementation claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r13_closed = "R13 closure claim"
    r13_closure_claimed = "R13 closure claim"
    r13_partial_gate_conversion_claimed = "R13 partial-gate conversion claim"
    partial_gates_converted_to_passed = "R13 partial-gate conversion claim"
    r14_caveat_removal_claimed = "R14 caveat removal"
    r14_caveats_removed = "R14 caveat removal"
    r15_caveat_removal_claimed = "R15 caveat removal"
    r15_caveats_removed = "R15 caveat removal"
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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-HasProperty -InputObject $InputObject -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $PSCmdlet.WriteObject($InputObject[$Name], $false)
        return
    }

    $PSCmdlet.WriteObject($InputObject.PSObject.Properties[$Name].Value, $false)
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

    if ($Value -isnot [int] -and $Value -isnot [long] -and $Value -isnot [int64]) {
        throw "$Context must be an integer."
    }

    return [int64]$Value
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

    if ($null -eq $Value) {
        throw "$Context must be an array of strings."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$item)) {
            throw "$Context must contain only non-empty strings."
        }
    }

    return [string[]]$items
}

function Assert-ObjectArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value) {
        throw "$Context must be an array of JSON objects."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context $Context | Out-Null
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

    $actualSorted = @($Actual | Sort-Object)
    $expectedSorted = @($Expected | Sort-Object)
    if ($actualSorted.Count -ne $expectedSorted.Count) {
        throw "$Context must contain exactly: $($expectedSorted -join ', ')."
    }

    for ($index = 0; $index -lt $expectedSorted.Count; $index += 1) {
        if ($actualSorted[$index] -ne $expectedSorted[$index]) {
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

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)
    return $PathValue -match '[\*\?]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalized -match '(^|/)(scratch|tmp|temp)(/|$)' -or $normalized -match '\.tmp($|\.)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue -match '^[A-Za-z][A-Za-z0-9+\.-]*://' -or $PathValue -match '^[^@\s]+@[^:\s]+:'
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

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return Test-Path -LiteralPath $fullPath -PathType Container
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
    if ($normalized -in @(".", "./", "", "/")) {
        throw "$Context path '$pathString' is a broad repo root path."
    }
    if (Test-DirectoryOnlyPath -PathValue $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context path '$pathString' is a directory-only ref."
    }

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    $rootWithSeparator = $RepositoryRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path '$pathString' escapes the repository root."
    }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Context path '$pathString' must resolve to an existing file."
    }
    if (-not (Test-GitTrackedPath -PathValue $normalized -RepositoryRoot $RepositoryRoot)) {
        throw "$Context path '$pathString' must be an exact repo-relative tracked file."
    }

    return $normalized
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-R16RaciStableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $json = ConvertTo-StableJson $Object
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

function Invoke-GitScalar {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $output = & git -C $RepositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed."
    }

    return [string]($output | Select-Object -First 1)
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
            if ($propertyName -eq "path" -or $propertyName -match '(^|_)path$') {
                Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$property.Value) -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName" | Out-Null
            }

            Assert-AllPathFieldsAreSafe -Value $property.Value -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName"
        }
    }
}

function New-ValidationCommands {
    $commands = @()
    for ($index = 0; $index -lt $script:RequiredValidationCommands.Count; $index += 1) {
        $commands += [pscustomobject][ordered]@{
            command = $script:RequiredValidationCommands[$index]
            deterministic_order = $index + 1
        }
    }

    return $commands
}

function New-RefObject {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [Parameter(Mandatory = $true)][bool]$MachineProof,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        path = $Path
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        machine_proof = $MachineProof
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        deterministic_order = $Order
    }
}

function New-RequiredEvidenceRefs {
    return @(
        New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only" -MachineProof $true -Order 1
        New-RefObject -RefId "role_run_envelope_contract_ref" -Path $script:RequiredRefPaths.role_run_envelope_contract_ref -SourceTask "R16-018" -ProofTreatment "committed role-run envelope contract; validator-backed contract/model proof" -MachineProof $true -Order 2
        New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only" -MachineProof $true -Order 3
        New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only" -MachineProof $true -Order 4
        New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only" -MachineProof $true -Order 5
        New-RefObject -RefId "role_memory_packs_ref" -Path $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only" -MachineProof $true -Order 6
        New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself" -MachineProof $false -Order 7
    )
}

function Get-R16RoleRunEnvelopeInputBundle {
    [CmdletBinding()]
    param(
        [string]$RoleRunEnvelopesPath = $script:RequiredRefPaths.role_run_envelopes_ref,
        [string]$ContextBudgetGuardPath = $script:RequiredRefPaths.context_budget_guard_ref,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-SafeRepoRelativeTrackedPath -PathValue $RoleRunEnvelopesPath -RepositoryRoot $resolvedRoot -Context "role_run_envelopes_ref" | Out-Null
    Assert-SafeRepoRelativeTrackedPath -PathValue $ContextBudgetGuardPath -RepositoryRoot $resolvedRoot -Context "context_budget_guard_ref" | Out-Null

    $roleModule = Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeGenerator.psm1") -Force -PassThru
    $testEnvelopes = $roleModule.ExportedCommands["Test-R16RoleRunEnvelopes"]
    & $testEnvelopes -Path $RoleRunEnvelopesPath -RepositoryRoot $resolvedRoot | Out-Null

    $envelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $RoleRunEnvelopesPath)) -Label "R16 role-run envelopes"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $ContextBudgetGuardPath)) -Label "R16 context budget guard report"

    return [pscustomobject]@{
        RepositoryRoot = $resolvedRoot
        Envelopes = $envelopes
        Guard = $guard
    }
}

function Get-RoleEnvelopeMap {
    param([Parameter(Mandatory = $true)]$RoleRunEnvelopes)

    $map = @{}
    foreach ($envelope in @($RoleRunEnvelopes.envelopes)) {
        $map[[string]$envelope.role_id] = $envelope
    }

    return $map
}

function New-CardStateObject {
    param([Parameter(Mandatory = $true)][int]$Order)

    return [pscustomobject][ordered]@{
        card_state_ref = New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and status boundary; report records R16-020 posture locally only" -MachineProof $false -Order 1
        source_status_surface_active_through_task = "R16-019"
        report_active_through_task = "R16-020"
        report_scope = "R16-020 validator report posture only; status surfaces are not updated in this implementation pass"
        handoff_packet_required_for_execution = $true
        handoff_packet_generated = $false
        workflow_drill_run = $false
        deterministic_order = $Order
    }
}

function New-ProposedTransition {
    param(
        [Parameter(Mandatory = $true)][int]$Order,
        [Parameter(Mandatory = $true)][string]$SourceRoleId,
        [Parameter(Mandatory = $true)][string]$TargetRoleId,
        [Parameter(Mandatory = $true)][string]$ActionType,
        [Parameter(Mandatory = $true)]$RoleEnvelopeMap,
        [Parameter(Mandatory = $true)]$Guard
    )

    $sourceEnvelope = $RoleEnvelopeMap[$SourceRoleId]
    $targetEnvelope = $RoleEnvelopeMap[$TargetRoleId]
    $sourceExecutable = [bool]$sourceEnvelope.executable
    $targetExecutable = [bool]$targetEnvelope.executable
    $sourceAllowedActions = [string[]]@($sourceEnvelope.allowed_actions | ForEach-Object { [string]$_.action_type })
    $actionAllowed = $sourceAllowedActions -contains $ActionType
    $guardAllowsExecution = [string]$Guard.aggregate_verdict -ne $script:GuardVerdict

    $blockedReasons = @()
    if (-not $guardAllowsExecution) {
        $blockedReasons += "context_budget_guard_failed_closed_over_budget"
    }
    if (-not $sourceExecutable) {
        $blockedReasons += "source_envelope_non_executable"
    }
    if (-not $targetExecutable) {
        $blockedReasons += "target_envelope_non_executable"
    }
    if (-not $actionAllowed) {
        $blockedReasons += "action_not_in_source_allowed_actions"
    }

    $decision = if ($blockedReasons.Count -eq 0) { "allowed" } else { "blocked" }

    return [pscustomobject][ordered]@{
        transition_id = "r16-020-raci-transition-{0:000}-{1}-to-{2}" -f $Order, $SourceRoleId, $TargetRoleId
        source_role_id = $SourceRoleId
        target_role_id = $TargetRoleId
        action_type = $ActionType
        card_state = New-CardStateObject -Order $Order
        source_envelope_id = [string]$sourceEnvelope.envelope_id
        target_envelope_id = [string]$targetEnvelope.envelope_id
        source_role_exists = $true
        target_role_exists = $true
        source_envelope_executable = $sourceExecutable
        target_envelope_executable = $targetExecutable
        action_allowed_by_source_role = $actionAllowed
        required_evidence_refs = New-RequiredEvidenceRefs
        required_evidence_refs_valid = $true
        context_budget_guard_verdict = [string]$Guard.aggregate_verdict
        context_budget_guard_allows_execution = $guardAllowsExecution
        decision = $decision
        fail_closed = (-not $guardAllowsExecution)
        execution_permitted = ($decision -eq "allowed")
        blocked_reasons = [string[]]$blockedReasons
        deterministic_order = $Order
    }
}

function New-GateMode {
    return [pscustomobject][ordered]@{
        deterministic_local_only = $true
        exact_repo_relative_tracked_inputs_only = $true
        reads_generated_role_run_envelopes = $true
        reads_context_budget_guard_report = $true
        reads_card_state_from_exact_refs = $true
        evaluates_required_evidence_refs = $true
        evaluates_allowed_actions = $true
        raci_transition_gate_validator_present = $true
        report_artifact_generation_only = $true
        all_execution_transitions_blocked_by_current_guard = $true
        no_full_repo_scan_performed = $true
        broad_repo_scan_allowed = $false
        broad_repo_scan_performed = $false
        full_repo_scan_allowed = $false
        full_repo_scan_performed = $false
        wildcard_path_expansion_allowed = $false
        wildcard_path_expansion_performed = $false
        raw_chat_history_as_evidence_allowed = $false
        provider_tokenizer_used = $false
        provider_pricing_used = $false
        exact_provider_tokenization_claimed = $false
        exact_provider_billing_claimed = $false
        runtime_execution_performed = $false
        runtime_memory_implemented = $false
        runtime_memory_loading_implemented = $false
        retrieval_runtime_implemented = $false
        vector_search_runtime_implemented = $false
        product_runtime_implemented = $false
        autonomous_agents_implemented = $false
        actual_autonomous_agents_implemented = $false
        external_integrations_implemented = $false
        handoff_packet_implemented = $false
        handoff_packet_generated = $false
        workflow_drill_run = $false
        r16_021_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
        solved_codex_compaction = $false
        solved_codex_reliability = $false
    }
}

function New-RequiredEvidencePolicy {
    return [pscustomobject][ordered]@{
        required_paths = [string[]]$script:RequiredEvidencePaths
        required_refs_are_exact_repo_relative = $true
        required_refs_are_tracked_files = $true
        all_transition_required_evidence_refs_must_exist = $true
        wildcard_paths_allowed = $false
        directory_only_refs_allowed = $false
        scratch_temp_refs_allowed = $false
        absolute_paths_allowed = $false
        parent_traversal_allowed = $false
        url_or_remote_refs_allowed = $false
        raw_chat_history_as_evidence_allowed = $false
        generated_reports_as_machine_proof_allowed = $false
    }
}

function New-AllowedActionPolicy {
    return [pscustomobject][ordered]@{
        source_role_must_exist_in_generated_envelopes = $true
        target_role_must_exist_in_generated_envelopes = $true
        source_envelope_must_be_executable_for_allowed_transition = $true
        target_envelope_must_be_executable_for_allowed_transition = $true
        action_must_exist_in_source_role_allowed_actions = $true
        context_budget_guard_must_not_be_failed_closed_over_budget = $true
        required_evidence_refs_must_exist_before_allowed_transition = $true
        execution_transition_allowed_under_current_guard = $false
        runtime_execution_performed = $false
        handoff_packet_generation_allowed_in_r16_020 = $false
        workflow_drill_allowed_in_r16_020 = $false
    }
}

function New-NoFullRepoScanPolicy {
    return [pscustomobject][ordered]@{
        repo_relative_exact_paths_only = $true
        tracked_files_only = $true
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
        raw_chat_history_loading_allowed = $false
        raw_chat_history_as_evidence_allowed = $false
    }
}

function New-CurrentPosture {
    return [pscustomobject][ordered]@{
        active_through_task = "R16-020"
        active_through_scope = "R16-020 in this RACI transition gate report only"
        status_surfaces_updated_this_pass = $false
        status_surfaces_may_remain_active_through_task = "R16-019"
        complete_tasks = [string[]](1..20 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        planned_tasks = [string[]](21..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        role_run_envelope_contract_defined = $true
        generated_role_run_envelopes_exist = $true
        generated_role_run_envelopes_are_state_artifacts_only = $true
        all_generated_envelopes_blocked_by_guard = $true
        raci_transition_gate_validator_exists = $true
        raci_transition_gate_report_exists = $true
        executable_transitions_exist = $false
        handoff_packet_exists = $false
        workflow_drill_exists = $false
        runtime_memory_exists = $false
        retrieval_runtime_exists = $false
        vector_search_runtime_exists = $false
        product_runtime_exists = $false
        autonomous_agents_exist = $false
        external_integrations_exist = $false
        r16_021_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
    }
}

function New-PreservedBoundaries {
    return [pscustomobject][ordered]@{
        r13 = [pscustomobject][ordered]@{
            status = "failed_partial_through_r13_018_only"
            closed = $false
            partial_gates_converted_to_passed = $false
            caveat_preserved = $true
        }
        r14 = [pscustomobject][ordered]@{
            status = "accepted_with_caveats_through_r14_006_only"
            caveats_removed = $false
            caveat_preserved = $true
        }
        r15 = [pscustomobject][ordered]@{
            status = "accepted_with_caveats_through_r15_009_only"
            caveats_removed = $false
            stale_generated_from_caveat_preserved = $true
        }
    }
}

function New-R16RaciTransitionGateReportObject {
    [CmdletBinding()]
    param(
        [string]$RoleRunEnvelopesPath = $script:RequiredRefPaths.role_run_envelopes_ref,
        [string]$ContextBudgetGuardPath = $script:RequiredRefPaths.context_budget_guard_ref,
        [string]$RepositoryRoot
    )

    $bundle = Get-R16RoleRunEnvelopeInputBundle -RoleRunEnvelopesPath $RoleRunEnvelopesPath -ContextBudgetGuardPath $ContextBudgetGuardPath -RepositoryRoot $RepositoryRoot
    $resolvedRoot = $bundle.RepositoryRoot
    $roleMap = Get-RoleEnvelopeMap -RoleRunEnvelopes $bundle.Envelopes

    $transitions = @(
        New-ProposedTransition -Order 1 -SourceRoleId "project_manager" -TargetRoleId "developer" -ActionType "prepare_task_scope" -RoleEnvelopeMap $roleMap -Guard $bundle.Guard
        New-ProposedTransition -Order 2 -SourceRoleId "developer" -TargetRoleId "qa" -ActionType "run_scoped_validation" -RoleEnvelopeMap $roleMap -Guard $bundle.Guard
        New-ProposedTransition -Order 3 -SourceRoleId "qa" -TargetRoleId "evidence_auditor" -ActionType "record_findings" -RoleEnvelopeMap $roleMap -Guard $bundle.Guard
        New-ProposedTransition -Order 4 -SourceRoleId "evidence_auditor" -TargetRoleId "release_closeout_agent" -ActionType "prepare_evidence_summary" -RoleEnvelopeMap $roleMap -Guard $bundle.Guard
    )

    $blockedTransitionCount = @($transitions | Where-Object { [string]$_.decision -eq "blocked" }).Count
    $allowedTransitionCount = @($transitions | Where-Object { [string]$_.decision -eq "allowed" }).Count
    $executableEnvelopeCount = @($bundle.Envelopes.envelopes | Where-Object { [bool]$_.executable }).Count
    $blockedEnvelopeCount = @($bundle.Envelopes.envelopes | Where-Object { -not [bool]$_.executable }).Count

    return [pscustomobject][ordered]@{
        artifact_type = "r16_raci_transition_gate_report"
        gate_version = $script:GateVersion
        gate_id = $script:GateId
        source_milestone = $script:R16Milestone
        source_task = "R16-020"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [pscustomobject][ordered]@{
            input_head = Invoke-GitScalar -RepositoryRoot $resolvedRoot -Arguments @("rev-parse", "HEAD")
            input_tree = Invoke-GitScalar -RepositoryRoot $resolvedRoot -Arguments @("rev-parse", "HEAD^{tree}")
            source_boundary = "deterministic local R16-020 gate report from exact committed refs only"
        }
        role_run_envelopes_ref = New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only" -MachineProof $true -Order 1
        role_run_envelope_contract_ref = New-RefObject -RefId "role_run_envelope_contract_ref" -Path $script:RequiredRefPaths.role_run_envelope_contract_ref -SourceTask "R16-018" -ProofTreatment "committed role-run envelope contract; validator-backed contract/model proof" -MachineProof $true -Order 2
        context_budget_guard_ref = New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only" -MachineProof $true -Order 3
        context_budget_estimate_ref = New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only" -MachineProof $true -Order 4
        context_load_plan_ref = New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only" -MachineProof $true -Order 5
        role_memory_packs_ref = New-RefObject -RefId "role_memory_packs_ref" -Path $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only" -MachineProof $true -Order 6
        card_state_ref = New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself" -MachineProof $false -Order 7
        gate_mode = New-GateMode
        evaluated_transitions = $transitions
        blocked_transition_count = $blockedTransitionCount
        allowed_transition_count = $allowedTransitionCount
        required_evidence_policy = New-RequiredEvidencePolicy
        allowed_action_policy = New-AllowedActionPolicy
        no_full_repo_scan_policy = New-NoFullRepoScanPolicy
        current_posture = New-CurrentPosture
        preserved_boundaries = New-PreservedBoundaries
        finding_summary = [pscustomobject][ordered]@{
            role_envelope_count = @($bundle.Envelopes.envelopes).Count
            blocked_envelope_count = $blockedEnvelopeCount
            executable_envelope_count = $executableEnvelopeCount
            evaluated_transition_count = $transitions.Count
            blocked_transition_count = $blockedTransitionCount
            allowed_transition_count = $allowedTransitionCount
            current_guard_verdict = [string]$bundle.Guard.aggregate_verdict
            estimated_tokens_upper_bound = [int64]$bundle.Guard.evaluated_budget.estimated_tokens_upper_bound
            max_estimated_tokens_upper_bound = [int64]$bundle.Guard.configured_budget_thresholds.max_estimated_tokens_upper_bound
            no_handoff_packet_generated = $true
            no_workflow_drill_run = $true
            no_runtime_execution = $true
            finding = "All evaluated execution transitions are blocked because the guard is failed_closed_over_budget and source/target envelopes are non-executable."
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
    $normalizedPath = Assert-SafeRepoRelativeTrackedPath -PathValue $pathValue -RepositoryRoot $RepositoryRoot -Context $Context
    if (-not [string]::IsNullOrWhiteSpace($ExpectedPath) -and $normalizedPath -ne $ExpectedPath) {
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
    if ($normalizedPath -eq $script:RequiredRefPaths.card_state_ref -and [bool]$refValue.machine_proof) {
        throw "$Context contains report-as-machine-proof misuse for card-state authority ref."
    }
}

function Assert-GateMode {
    param(
        [Parameter(Mandatory = $true)]$GateMode,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $modeObject = Assert-ObjectValue -Value $GateMode -Context $Context
    foreach ($trueField in @("deterministic_local_only", "exact_repo_relative_tracked_inputs_only", "reads_generated_role_run_envelopes", "reads_context_budget_guard_report", "reads_card_state_from_exact_refs", "evaluates_required_evidence_refs", "evaluates_allowed_actions", "raci_transition_gate_validator_present", "report_artifact_generation_only", "all_execution_transitions_blocked_by_current_guard", "no_full_repo_scan_performed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $modeObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_path_expansion_allowed", "wildcard_path_expansion_performed", "raw_chat_history_as_evidence_allowed", "provider_tokenizer_used", "provider_pricing_used", "exact_provider_tokenization_claimed", "exact_provider_billing_claimed", "runtime_execution_performed", "runtime_memory_implemented", "runtime_memory_loading_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "autonomous_agents_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "handoff_packet_implemented", "handoff_packet_generated", "workflow_drill_run", "r16_021_implementation_claimed", "r16_027_or_later_task_exists", "solved_codex_compaction", "solved_codex_reliability")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $modeObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-PolicyBooleans {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string[]]$TrueFields,
        [Parameter(Mandatory = $true)][string[]]$FalseFields
    )

    $policyObject = Assert-ObjectValue -Value $Policy -Context $Context
    foreach ($fieldName in $TrueFields) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }
    foreach ($fieldName in $FalseFields) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context $fieldName must be False."
        }
    }

    return $policyObject
}

function Assert-RequiredEvidencePolicy {
    param([Parameter(Mandatory = $true)]$Policy)

    $policyObject = Assert-PolicyBooleans -Policy $Policy -Context "required_evidence_policy" -TrueFields @("required_refs_are_exact_repo_relative", "required_refs_are_tracked_files", "all_transition_required_evidence_refs_must_exist") -FalseFields @("wildcard_paths_allowed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "raw_chat_history_as_evidence_allowed", "generated_reports_as_machine_proof_allowed")
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $policyObject -Name "required_paths" -Context "required_evidence_policy") -Context "required_evidence_policy required_paths"
    Assert-ExactStringSet -Actual $requiredPaths -Expected $script:RequiredEvidencePaths -Context "required_evidence_policy required_paths"
}

function Assert-AllowedActionPolicy {
    param([Parameter(Mandatory = $true)]$Policy)

    Assert-PolicyBooleans -Policy $Policy -Context "allowed_action_policy" -TrueFields @("source_role_must_exist_in_generated_envelopes", "target_role_must_exist_in_generated_envelopes", "source_envelope_must_be_executable_for_allowed_transition", "target_envelope_must_be_executable_for_allowed_transition", "action_must_exist_in_source_role_allowed_actions", "context_budget_guard_must_not_be_failed_closed_over_budget", "required_evidence_refs_must_exist_before_allowed_transition") -FalseFields @("execution_transition_allowed_under_current_guard", "runtime_execution_performed", "handoff_packet_generation_allowed_in_r16_020", "workflow_drill_allowed_in_r16_020") | Out-Null
}

function Assert-NoFullRepoScanPolicy {
    param([Parameter(Mandatory = $true)]$Policy)

    Assert-PolicyBooleans -Policy $Policy -Context "no_full_repo_scan_policy" -TrueFields @("repo_relative_exact_paths_only", "tracked_files_only", "exact_dependency_refs_only", "no_wildcard_path_expansion") -FalseFields @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_path_expansion_performed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed") | Out-Null
}

function Assert-CurrentPosture {
    param([Parameter(Mandatory = $true)]$Posture)

    $postureObject = Assert-ObjectValue -Value $Posture -Context "current_posture"
    if ([string]$postureObject.active_through_task -ne "R16-020") {
        throw "current_posture active_through_task must be R16-020."
    }
    if ([string]$postureObject.status_surfaces_may_remain_active_through_task -ne "R16-019") {
        throw "current_posture must preserve status surfaces as active through R16-019 for this pass."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.complete_tasks -Context "current_posture complete_tasks") -Expected ([string[]](1..20 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "current_posture complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $postureObject.planned_tasks -Context "current_posture planned_tasks") -Expected ([string[]](21..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "current_posture planned_tasks"
    foreach ($trueField in @("role_run_envelope_contract_defined", "generated_role_run_envelopes_exist", "generated_role_run_envelopes_are_state_artifacts_only", "all_generated_envelopes_blocked_by_guard", "raci_transition_gate_validator_exists", "raci_transition_gate_report_exists")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $trueField -Context "current_posture") -Context "current_posture $trueField") -ne $true) {
            throw "current_posture $trueField must be True."
        }
    }
    foreach ($falseField in @("status_surfaces_updated_this_pass", "executable_transitions_exist", "handoff_packet_exists", "workflow_drill_exists", "runtime_memory_exists", "retrieval_runtime_exists", "vector_search_runtime_exists", "product_runtime_exists", "autonomous_agents_exist", "external_integrations_exist", "r16_021_implementation_claimed", "r16_027_or_later_task_exists")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $falseField -Context "current_posture") -Context "current_posture $falseField") -ne $false) {
            throw "current_posture $falseField must be False."
        }
    }
}

function Assert-PreservedBoundaries {
    param([Parameter(Mandatory = $true)]$Boundaries)

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context "preserved_boundaries"
    $r13Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r13" -Context "preserved_boundaries") -Context "preserved_boundaries r13"
    if ([string]$r13Boundary.status -ne "failed_partial_through_r13_018_only") {
        throw "preserved_boundaries r13 status must preserve failed_partial_through_r13_018_only."
    }
    if ((Assert-BooleanValue -Value $r13Boundary.closed -Context "preserved_boundaries r13 closed") -ne $false) {
        throw "preserved_boundaries r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $r13Boundary.partial_gates_converted_to_passed -Context "preserved_boundaries r13 partial_gates_converted_to_passed") -ne $false) {
        throw "preserved_boundaries r13 partial_gates_converted_to_passed must be False."
    }

    $r14Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r14" -Context "preserved_boundaries") -Context "preserved_boundaries r14"
    if ([string]$r14Boundary.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "preserved_boundaries r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    if ((Assert-BooleanValue -Value $r14Boundary.caveats_removed -Context "preserved_boundaries r14 caveats_removed") -ne $false) {
        throw "preserved_boundaries r14 caveat removal must remain False."
    }

    $r15Boundary = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r15" -Context "preserved_boundaries") -Context "preserved_boundaries r15"
    if ([string]$r15Boundary.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "preserved_boundaries r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
    if ((Assert-BooleanValue -Value $r15Boundary.caveats_removed -Context "preserved_boundaries r15 caveats_removed") -ne $false) {
        throw "preserved_boundaries r15 caveat removal must remain False."
    }
    if ((Assert-BooleanValue -Value $r15Boundary.stale_generated_from_caveat_preserved -Context "preserved_boundaries r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "preserved_boundaries r15 stale_generated_from_caveat_preserved must be True."
    }
}

function Assert-CardState {
    param(
        [Parameter(Mandatory = $true)]$CardState,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $cardStateObject = Assert-ObjectValue -Value $CardState -Context $Context
    Assert-RefObject -RefObject (Get-RequiredProperty -InputObject $cardStateObject -Name "card_state_ref" -Context $Context) -Context "$Context card_state_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.card_state_ref -ExpectedRefId "card_state_ref"
    if ([string]$cardStateObject.source_status_surface_active_through_task -ne "R16-019") {
        throw "$Context source_status_surface_active_through_task must be R16-019."
    }
    if ([string]$cardStateObject.report_active_through_task -ne "R16-020") {
        throw "$Context report_active_through_task must be R16-020."
    }
    foreach ($falseField in @("handoff_packet_generated", "workflow_drill_run")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $cardStateObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context $falseField must be False."
        }
    }
}

function Assert-RequiredEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]$EvidenceRefs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $refs = Assert-ObjectArray -Value $EvidenceRefs -Context $Context
    $paths = @()
    for ($index = 0; $index -lt $refs.Count; $index += 1) {
        Assert-RefObject -RefObject $refs[$index] -Context "$Context[$index]" -RepositoryRoot $RepositoryRoot | Out-Null
        $paths += ConvertTo-NormalizedRepoPath -PathValue ([string]$refs[$index].path)
    }

    foreach ($requiredPath in $script:RequiredEvidencePaths) {
        if ($paths -notcontains $requiredPath) {
            throw "$Context is missing required evidence ref '$requiredPath'."
        }
    }

    return [string[]]$paths
}

function Assert-EvaluatedTransitions {
    param(
        [Parameter(Mandatory = $true)]$Transitions,
        [Parameter(Mandatory = $true)]$RoleRunEnvelopes,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $transitionObjects = Assert-ObjectArray -Value $Transitions -Context "evaluated_transitions"
    $roleMap = Get-RoleEnvelopeMap -RoleRunEnvelopes $RoleRunEnvelopes
    $guardAllowsExecution = [string]$Guard.aggregate_verdict -ne $script:GuardVerdict
    $blockedCount = 0
    $allowedCount = 0

    for ($index = 0; $index -lt $transitionObjects.Count; $index += 1) {
        $transition = $transitionObjects[$index]
        $context = "evaluated_transitions[$index]"
        foreach ($fieldName in $script:RequiredTransitionFields) {
            Get-RequiredProperty -InputObject $transition -Name $fieldName -Context $context | Out-Null
        }

        $expectedOrder = $index + 1
        if ((Assert-IntegerValue -Value $transition.deterministic_order -Context "$context deterministic_order") -ne $expectedOrder) {
            throw "$context deterministic_order must be $expectedOrder."
        }

        $sourceRoleId = Assert-NonEmptyString -Value $transition.source_role_id -Context "$context source_role_id"
        $targetRoleId = Assert-NonEmptyString -Value $transition.target_role_id -Context "$context target_role_id"
        if (-not $roleMap.ContainsKey($sourceRoleId)) {
            throw "$context references unknown source role '$sourceRoleId'."
        }
        if (-not $roleMap.ContainsKey($targetRoleId)) {
            throw "$context references unknown target role '$targetRoleId'."
        }

        $sourceEnvelope = $roleMap[$sourceRoleId]
        $targetEnvelope = $roleMap[$targetRoleId]
        if ((Assert-BooleanValue -Value $transition.source_role_exists -Context "$context source_role_exists") -ne $true) {
            throw "$context source_role_exists must be True."
        }
        if ((Assert-BooleanValue -Value $transition.target_role_exists -Context "$context target_role_exists") -ne $true) {
            throw "$context target_role_exists must be True."
        }
        if ([string]$transition.source_envelope_id -ne [string]$sourceEnvelope.envelope_id) {
            throw "$context source_envelope_id must match generated source envelope."
        }
        if ([string]$transition.target_envelope_id -ne [string]$targetEnvelope.envelope_id) {
            throw "$context target_envelope_id must match generated target envelope."
        }

        $sourceExecutableActual = [bool]$sourceEnvelope.executable
        $targetExecutableActual = [bool]$targetEnvelope.executable
        if ((Assert-BooleanValue -Value $transition.source_envelope_executable -Context "$context source_envelope_executable") -ne $sourceExecutableActual) {
            throw "$context source_envelope_executable must match generated source envelope."
        }
        if ((Assert-BooleanValue -Value $transition.target_envelope_executable -Context "$context target_envelope_executable") -ne $targetExecutableActual) {
            throw "$context target_envelope_executable must match generated target envelope."
        }

        $actionType = Assert-NonEmptyString -Value $transition.action_type -Context "$context action_type"
        $allowedActionTypes = [string[]]@($sourceEnvelope.allowed_actions | ForEach-Object { [string]$_.action_type })
        $actionAllowedActual = $allowedActionTypes -contains $actionType
        if (-not $actionAllowedActual) {
            throw "$context action not in allowed_actions for source role '$sourceRoleId'."
        }
        if ((Assert-BooleanValue -Value $transition.action_allowed_by_source_role -Context "$context action_allowed_by_source_role") -ne $actionAllowedActual) {
            throw "$context action_allowed_by_source_role must match generated source role allowed_actions."
        }

        Assert-CardState -CardState $transition.card_state -RepositoryRoot $RepositoryRoot -Context "$context card_state"
        Assert-RequiredEvidenceRefs -EvidenceRefs $transition.required_evidence_refs -RepositoryRoot $RepositoryRoot -Context "$context required_evidence_refs" | Out-Null
        if ((Assert-BooleanValue -Value $transition.required_evidence_refs_valid -Context "$context required_evidence_refs_valid") -ne $true) {
            throw "$context required_evidence_refs_valid must be True."
        }

        if ([string]$transition.context_budget_guard_verdict -ne [string]$Guard.aggregate_verdict) {
            throw "$context context_budget_guard_verdict must match current guard report."
        }
        if ((Assert-BooleanValue -Value $transition.context_budget_guard_allows_execution -Context "$context context_budget_guard_allows_execution") -ne $guardAllowsExecution) {
            throw "$context context_budget_guard_allows_execution must match current guard report."
        }

        $decision = Assert-NonEmptyString -Value $transition.decision -Context "$context decision"
        if ($decision -notin @("allowed", "blocked", "fail_closed")) {
            throw "$context decision must be allowed, blocked, or fail_closed."
        }
        if ($decision -eq "allowed") {
            $violations = @()
            if (-not $guardAllowsExecution) {
                $violations += "guard is failed_closed_over_budget"
            }
            if (-not $sourceExecutableActual) {
                $violations += "source envelope executable=false"
            }
            if (-not $targetExecutableActual) {
                $violations += "target envelope executable=false"
            }
            if (-not $actionAllowedActual) {
                $violations += "action not in allowed_actions"
            }
            if ($violations.Count -gt 0) {
                throw "$context is allowed while $($violations -join '; ')."
            }
        }
        if (-not $guardAllowsExecution -and $decision -ne "blocked") {
            throw "$context execution transition must be blocked while guard is failed_closed_over_budget."
        }

        $executionPermitted = Assert-BooleanValue -Value $transition.execution_permitted -Context "$context execution_permitted"
        if ($executionPermitted -ne ($decision -eq "allowed")) {
            throw "$context execution_permitted must match decision."
        }
        if (-not $guardAllowsExecution -and $executionPermitted) {
            throw "$context execution_permitted is true while guard is failed_closed_over_budget."
        }

        $failClosed = Assert-BooleanValue -Value $transition.fail_closed -Context "$context fail_closed"
        if (-not $guardAllowsExecution -and -not $failClosed) {
            throw "$context fail_closed must be True while guard is failed_closed_over_budget."
        }

        $blockedReasons = Assert-StringArray -Value $transition.blocked_reasons -Context "$context blocked_reasons" -AllowEmpty:($decision -eq "allowed")
        if (-not $guardAllowsExecution -and $blockedReasons -notcontains "context_budget_guard_failed_closed_over_budget") {
            throw "$context blocked_reasons must reference failed_closed_over_budget."
        }
        if (-not $sourceExecutableActual -and $blockedReasons -notcontains "source_envelope_non_executable") {
            throw "$context blocked_reasons must reference source_envelope_non_executable."
        }
        if (-not $targetExecutableActual -and $blockedReasons -notcontains "target_envelope_non_executable") {
            throw "$context blocked_reasons must reference target_envelope_non_executable."
        }

        if ($decision -eq "allowed") {
            $allowedCount += 1
        }
        elseif ($decision -eq "blocked") {
            $blockedCount += 1
        }
    }

    return [pscustomobject]@{
        TransitionCount = $transitionObjects.Count
        BlockedTransitionCount = $blockedCount
        AllowedTransitionCount = $allowedCount
    }
}

function Test-R16RaciTransitionGateReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 RACI transition gate report",
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }

    if ([string]$Report.artifact_type -ne "r16_raci_transition_gate_report") {
        throw "$SourceLabel artifact_type must be r16_raci_transition_gate_report."
    }
    if ([string]$Report.gate_version -ne $script:GateVersion -or [string]$Report.gate_id -ne $script:GateId -or [string]$Report.source_task -ne "R16-020") {
        throw "$SourceLabel gate identity is incorrect."
    }
    if ([string]$Report.source_milestone -ne $script:R16Milestone -or [string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel milestone, repository, or branch metadata is incorrect."
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Report -RepositoryRoot $resolvedRoot -Context $SourceLabel

    Assert-RefObject -RefObject $Report.role_run_envelopes_ref -Context "$SourceLabel role_run_envelopes_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "role_run_envelopes_ref"
    Assert-RefObject -RefObject $Report.role_run_envelope_contract_ref -Context "$SourceLabel role_run_envelope_contract_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelope_contract_ref -ExpectedRefId "role_run_envelope_contract_ref"
    Assert-RefObject -RefObject $Report.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref"
    Assert-RefObject -RefObject $Report.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref"
    Assert-RefObject -RefObject $Report.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref"
    Assert-RefObject -RefObject $Report.role_memory_packs_ref -Context "$SourceLabel role_memory_packs_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "role_memory_packs_ref"
    Assert-RefObject -RefObject $Report.card_state_ref -Context "$SourceLabel card_state_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.card_state_ref -ExpectedRefId "card_state_ref"

    $roleModule = Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeGenerator.psm1") -Force -PassThru
    $testEnvelopes = $roleModule.ExportedCommands["Test-R16RoleRunEnvelopes"]
    & $testEnvelopes -Path ([string]$Report.role_run_envelopes_ref.path) -RepositoryRoot $resolvedRoot | Out-Null
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue ([string]$Report.role_run_envelopes_ref.path))) -Label "R16 role-run envelopes"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue ([string]$Report.context_budget_guard_ref.path))) -Label "R16 context budget guard report"
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "$SourceLabel current guard report must remain $script:GuardVerdict."
    }

    Assert-GateMode -GateMode $Report.gate_mode -Context "$SourceLabel gate_mode"
    Assert-RequiredEvidencePolicy -Policy $Report.required_evidence_policy
    Assert-AllowedActionPolicy -Policy $Report.allowed_action_policy
    Assert-NoFullRepoScanPolicy -Policy $Report.no_full_repo_scan_policy
    Assert-CurrentPosture -Posture $Report.current_posture
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries

    $transitionSummary = Assert-EvaluatedTransitions -Transitions $Report.evaluated_transitions -RoleRunEnvelopes $roleRunEnvelopes -Guard $guard -RepositoryRoot $resolvedRoot
    if ((Assert-IntegerValue -Value $Report.blocked_transition_count -Context "$SourceLabel blocked_transition_count") -ne $transitionSummary.BlockedTransitionCount) {
        throw "$SourceLabel blocked_transition_count must match evaluated transitions."
    }
    if ((Assert-IntegerValue -Value $Report.allowed_transition_count -Context "$SourceLabel allowed_transition_count") -ne $transitionSummary.AllowedTransitionCount) {
        throw "$SourceLabel allowed_transition_count must match evaluated transitions."
    }
    if ($transitionSummary.BlockedTransitionCount -ne 4 -or $transitionSummary.AllowedTransitionCount -ne 0) {
        throw "$SourceLabel must record four blocked transitions and zero allowed transitions."
    }

    $summary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$summary.role_envelope_count -ne 8 -or [int64]$summary.blocked_envelope_count -ne 8 -or [int64]$summary.executable_envelope_count -ne 0) {
        throw "$SourceLabel finding_summary must record eight non-executable envelopes."
    }
    if ([int64]$summary.evaluated_transition_count -ne 4 -or [int64]$summary.blocked_transition_count -ne 4 -or [int64]$summary.allowed_transition_count -ne 0) {
        throw "$SourceLabel finding_summary must record four blocked and zero allowed transitions."
    }
    $expectedEstimatedUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $expectedMaxUpperBound = [int64]$guard.configured_budget_thresholds.max_estimated_tokens_upper_bound
    if ([string]$summary.current_guard_verdict -ne $script:GuardVerdict -or [int64]$summary.estimated_tokens_upper_bound -ne $expectedEstimatedUpperBound -or [int64]$summary.max_estimated_tokens_upper_bound -ne $expectedMaxUpperBound) {
        throw ("$SourceLabel finding_summary must preserve failed_closed_over_budget guard values {0} over {1}." -f $expectedEstimatedUpperBound, $expectedMaxUpperBound)
    }
    foreach ($trueField in @("no_handoff_packet_generated", "no_workflow_drill_run", "no_runtime_execution")) {
        if ((Assert-BooleanValue -Value $summary.$trueField -Context "$SourceLabel finding_summary $trueField") -ne $true) {
            throw "$SourceLabel finding_summary $trueField must be True."
        }
    }

    if ([string]$Report.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be $script:AggregateVerdict."
    }
    $commands = Assert-ObjectArray -Value $Report.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($commands | ForEach-Object { [string]$_.command })
    Assert-RequiredStringsPresent -Actual $commandValues -Required $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"
    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        GateId = [string]$Report.gate_id
        SourceTask = [string]$Report.source_task
        ActiveThroughTask = [string]$Report.current_posture.active_through_task
        PlannedTaskStart = [string]$Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = [string]$Report.current_posture.planned_tasks[-1]
        TransitionCount = $transitionSummary.TransitionCount
        BlockedTransitionCount = $transitionSummary.BlockedTransitionCount
        AllowedTransitionCount = $transitionSummary.AllowedTransitionCount
        AggregateVerdict = [string]$Report.aggregate_verdict
        BudgetGuardVerdict = [string]$guard.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
        MaxEstimatedTokensUpperBound = [int64]$guard.configured_budget_thresholds.max_estimated_tokens_upper_bound
    }
}

function Test-R16RaciTransitionGateReport {
    [CmdletBinding()]
    param(
        [string]$Path = "state/workflow/r16_raci_transition_gate_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 RACI transition gate report"
    return Test-R16RaciTransitionGateReportObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16RaciTransitionGateReport {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/workflow/r16_raci_transition_gate_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16RaciTransitionGateReportObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-R16RaciStableJsonFile $report $resolvedOutput
    $validation = Test-R16RaciTransitionGateReport -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        GateId = $validation.GateId
        TransitionCount = $validation.TransitionCount
        BlockedTransitionCount = $validation.BlockedTransitionCount
        AllowedTransitionCount = $validation.AllowedTransitionCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        BudgetGuardVerdict = $validation.BudgetGuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        MaxEstimatedTokensUpperBound = $validation.MaxEstimatedTokensUpperBound
    }
}

function Test-R16RaciTransitionGateReportContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/workflow/r16_raci_transition_gate_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 RACI transition gate report contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "raci_transition_gate_report_contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "transition_evaluation_policy", "required_evidence_policy", "no_full_repo_scan_policy", "handoff_boundary_policy", "current_posture_policy", "non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 RACI transition gate report contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_raci_transition_gate_report_contract" -or [string]$contract.source_task -ne "R16-020") {
        throw "R16 RACI transition gate report contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 RACI transition gate report contract"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 RACI transition gate report contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 RACI transition gate report contract required_report_fields"

    $dependencyRefs = Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 RACI transition gate report contract dependency_refs"
    $dependencyPaths = @()
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        $dependencyPath = Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$dependencyRefs[$index].path) -RepositoryRoot $resolvedRoot -Context "R16 RACI transition gate report contract dependency_refs[$index]"
        $dependencyPaths += $dependencyPath
    }
    Assert-RequiredStringsPresent -Actual ([string[]]$dependencyPaths) -Required $script:RequiredEvidencePaths -Context "R16 RACI transition gate report contract dependency_refs path"
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 RACI transition gate report contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required @("no executable transitions while guard is failed_closed_over_budget", "no handoff packet", "no workflow drill", "R16-021 through R16-026 remain planned only", "R13 remains failed/partial and not closed", "R14 caveats remain preserved", "R15 caveats remain preserved") -Context "R16 RACI transition gate report contract non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.raci_transition_gate_report_contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16RaciTransitionGateFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_raci_transition_gate",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16RaciTransitionGateReportObject -RepositoryRoot $resolvedRoot
    Write-R16RaciStableJsonFile $validReport (Join-Path $fixtureRootPath "valid_raci_transition_gate_report.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_raci_transition_gate_report.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.gate_mode' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'gate_mode'")
        "invalid_missing_role_run_envelopes_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_run_envelopes_ref" -MutationPath '$.role_run_envelopes_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_evaluated_transitions.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_evaluated_transitions" -MutationPath '$.evaluated_transitions' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'evaluated_transitions'")
        "invalid_transition_allowed_failed_guard.json" = New-MutationFixtureSpec -FixtureId "invalid_transition_allowed_failed_guard" -MutationPath '$.evaluated_transitions[0].decision' -MutationValue "allowed" -ExpectedFailure @("allowed while", "failed_closed_over_budget")
        "invalid_transition_allowed_source_not_executable.json" = New-MutationFixtureSpec -FixtureId "invalid_transition_allowed_source_not_executable" -MutationPath '$.evaluated_transitions[1].decision' -MutationValue "allowed" -ExpectedFailure @("source envelope executable=false")
        "invalid_transition_allowed_target_not_executable.json" = New-MutationFixtureSpec -FixtureId "invalid_transition_allowed_target_not_executable" -MutationPath '$.evaluated_transitions[2].decision' -MutationValue "allowed" -ExpectedFailure @("target envelope executable=false")
        "invalid_unknown_source_role.json" = New-MutationFixtureSpec -FixtureId "invalid_unknown_source_role" -MutationPath '$.evaluated_transitions[0].source_role_id' -MutationValue "unknown_role" -ExpectedFailure @("unknown source role")
        "invalid_unknown_target_role.json" = New-MutationFixtureSpec -FixtureId "invalid_unknown_target_role" -MutationPath '$.evaluated_transitions[0].target_role_id' -MutationValue "unknown_role" -ExpectedFailure @("unknown target role")
        "invalid_action_not_in_allowed_actions.json" = New-MutationFixtureSpec -FixtureId "invalid_action_not_in_allowed_actions" -MutationPath '$.evaluated_transitions[1].action_type' -MutationValue "prepare_task_scope" -ExpectedFailure @("action not in allowed_actions")
        "invalid_missing_required_evidence_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_evidence_ref" -MutationPath '$.evaluated_transitions[0].required_evidence_refs' -MutationValue "__REMOVE_REQUIRED_EVIDENCE:state/context/r16_context_budget_guard_report.json__" -ExpectedFailure @("missing required evidence ref")
        "invalid_evidence_ref_path_wildcard.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_path_wildcard" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "state/workflow/*.json" -ExpectedFailure @("wildcard path")
        "invalid_evidence_ref_directory_only.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_directory_only" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "state/workflow/" -ExpectedFailure @("directory-only ref")
        "invalid_evidence_ref_scratch_temp.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_scratch_temp" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "scratch/r16_raci_transition_gate.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_evidence_ref_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_absolute_path" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "C:/tmp/r16_raci_transition_gate.json" -ExpectedFailure @("absolute path")
        "invalid_evidence_ref_parent_traversal.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_parent_traversal" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "../state/workflow/r16_role_run_envelopes.json" -ExpectedFailure @("parent traversal path")
        "invalid_evidence_ref_url_remote.json" = New-MutationFixtureSpec -FixtureId "invalid_evidence_ref_url_remote" -MutationPath '$.evaluated_transitions[0].required_evidence_refs[0].path' -MutationValue "https://example.invalid/r16_role_run_envelopes.json" -ExpectedFailure @("URL or remote ref")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_raw_chat_history_evidence_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_evidence_claim" -MutationPath '$.required_evidence_policy.raw_chat_history_as_evidence_allowed' -MutationValue $true -ExpectedFailure @("raw chat history evidence claim")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.required_evidence_policy.generated_reports_as_machine_proof_allowed' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.gate_mode.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.gate_mode.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.gate_mode.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.gate_mode.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.gate_mode.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.gate_mode.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.gate_mode.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.gate_mode.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_handoff_packet_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_handoff_packet_implementation_claim" -MutationPath '$.gate_mode.handoff_packet_implemented' -MutationValue $true -ExpectedFailure @("handoff packet implementation claim")
        "invalid_workflow_drill_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_workflow_drill_claim" -MutationPath '$.gate_mode.workflow_drill_run' -MutationValue $true -ExpectedFailure @("workflow drill claim")
        "invalid_r16_021_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_021_implementation_claim" -MutationPath '$.current_posture.r16_021_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-021 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_027_or_later_task_claim" -MutationPath '$.current_posture.r16_027_or_later_task_exists' -MutationValue $true -ExpectedFailure @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_closure_or_partial_gate_conversion_claim" -MutationPath '$.preserved_boundaries.r13.closed' -MutationValue $true -ExpectedFailure @("r13", "closed must be False")
        "invalid_r14_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r14_caveat_removal" -MutationPath '$.preserved_boundaries.r14.caveats_removed' -MutationValue $true -ExpectedFailure @("r14", "caveat removal")
        "invalid_r15_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r15_caveat_removal" -MutationPath '$.preserved_boundaries.r15.caveats_removed' -MutationValue $true -ExpectedFailure @("r15", "caveat removal")
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        Write-R16RaciStableJsonFile $fixtureSpecs[$fixtureName] (Join-Path $fixtureRootPath $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_raci_transition_gate_report.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16RaciTransitionGateReportObject, New-R16RaciTransitionGateReport, Test-R16RaciTransitionGateReportObject, Test-R16RaciTransitionGateReport, Test-R16RaciTransitionGateReportContract, New-R16RaciTransitionGateFixtureFiles, ConvertTo-StableJson
