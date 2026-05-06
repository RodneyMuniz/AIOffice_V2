Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:HandoffPacketVersion = "v1"
$script:HandoffPacketReportId = "aioffice-r16-021-handoff-packet-report-v1"
$script:AggregateVerdict = "generated_handoff_packets_all_blocked_by_transition_gate"
$script:GuardVerdict = "failed_closed_over_budget"

$script:RequiredTopLevelFields = [string[]]@(
    "artifact_type",
    "handoff_packet_version",
    "handoff_packet_report_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "role_run_envelopes_ref",
    "raci_transition_gate_report_ref",
    "context_budget_guard_ref",
    "context_budget_estimate_ref",
    "context_load_plan_ref",
    "role_memory_packs_ref",
    "card_state_ref",
    "generation_mode",
    "handoff_packets",
    "blocked_handoff_count",
    "executable_handoff_count",
    "required_evidence_policy",
    "no_full_repo_scan_policy",
    "current_posture",
    "preserved_boundaries",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "non_claims"
)

$script:RequiredPacketFields = [string[]]@(
    "handoff_packet_id",
    "source_role_id",
    "target_role_id",
    "action_type",
    "source_envelope_ref",
    "target_envelope_ref",
    "transition_gate_ref",
    "transition_decision",
    "card_state_ref",
    "memory_pack_ref",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "context_budget_guard_ref",
    "evidence_refs",
    "handoff_constraints",
    "blocked_reason",
    "executable",
    "handoff_execution_status",
    "non_claims",
    "deterministic_order"
)

$script:RequiredRefPaths = [ordered]@{
    role_run_envelopes_ref = "state/workflow/r16_role_run_envelopes.json"
    role_run_envelope_contract_ref = "contracts/workflow/r16_role_run_envelope.contract.json"
    raci_transition_gate_report_ref = "state/workflow/r16_raci_transition_gate_report.json"
    context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
    context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
    context_load_plan_ref = "state/context/r16_context_load_plan.json"
    role_memory_packs_ref = "state/memory/r16_role_memory_packs.json"
    card_state_ref = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
}

$script:RequiredEvidencePaths = [string[]]@(
    "state/workflow/r16_role_run_envelopes.json",
    "contracts/workflow/r16_role_run_envelope.contract.json",
    "state/workflow/r16_raci_transition_gate_report.json",
    "state/context/r16_context_budget_guard_report.json",
    "state/context/r16_context_budget_estimate.json",
    "state/context/r16_context_load_plan.json",
    "state/memory/r16_role_memory_packs.json",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_handoff_packets.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_handoff_packet_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_handoff_packet_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_raci_transition_gate_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_raci_transition_gate.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-021 generated handoff packets as state artifacts only",
    "no executable handoffs while R16-020 transition gate is blocked",
    "all handoff packets remain blocked while guard is failed_closed_over_budget",
    "no workflow drill",
    "no runtime handoff execution",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R16-022 through R16-026 remain planned only",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved"
)

$script:RequiredPacketNonClaims = [string[]]@(
    "this handoff packet is a generated state artifact only",
    "this handoff packet is not executable",
    "R16-020 transition gate remains blocked",
    "context budget guard remains failed_closed_over_budget",
    "no workflow drill",
    "no runtime handoff execution",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "R16-022 through R16-026 remain planned only"
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
    workflow_drill_run = "workflow drill claim"
    workflow_drill_implemented = "workflow drill claim"
    runtime_handoff_execution_claimed = "runtime handoff execution claim"
    runtime_handoff_execution_performed = "runtime handoff execution claim"
    handoff_runtime_execution_claimed = "runtime handoff execution claim"
    handoff_execution_performed = "runtime handoff execution claim"
    runtime_execution_claimed = "runtime handoff execution claim"
    runtime_execution_performed = "runtime handoff execution claim"
    r16_022_implementation_claimed = "R16-022 implementation claim"
    r16_022_or_later_implementation_claimed = "R16-022 implementation claim"
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

    if ($null -eq $Value -or $Value -is [string]) {
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
            if ($propertyName -eq "path" -or $propertyName -match '(^|_)path$') {
                Assert-SafeRepoRelativeTrackedPath -PathValue ([string]$property.Value) -RepositoryRoot $RepositoryRoot -Context "$Context $propertyName" | Out-Null
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
        [Parameter(Mandatory = $true)][bool]$MachineProof,
        [Parameter(Mandatory = $true)][int]$DeterministicOrder,
        [hashtable]$Extra = @{}
    )

    $refObject = [ordered]@{
        ref_id = $RefId
        path = $Path
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        machine_proof = $MachineProof
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
    }

    foreach ($key in @($Extra.Keys | Sort-Object)) {
        $refObject[$key] = $Extra[$key]
    }

    $refObject["deterministic_order"] = $DeterministicOrder
    return [pscustomobject]$refObject
}

function New-HandoffEvidenceRefs {
    return [object[]]@(
        (New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only" -MachineProof $false -DeterministicOrder 1),
        (New-RefObject -RefId "role_run_envelope_contract_ref" -Path $script:RequiredRefPaths.role_run_envelope_contract_ref -SourceTask "R16-018" -ProofTreatment "committed role-run envelope contract; validator-backed contract/model proof" -MachineProof $true -DeterministicOrder 2),
        (New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "committed generated RACI transition gate report state artifact only; not a runtime execution proof" -MachineProof $false -DeterministicOrder 3),
        (New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only" -MachineProof $false -DeterministicOrder 4),
        (New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only" -MachineProof $false -DeterministicOrder 5),
        (New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only" -MachineProof $false -DeterministicOrder 6),
        (New-RefObject -RefId "role_memory_packs_ref" -Path $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only" -MachineProof $false -DeterministicOrder 7),
        (New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself" -MachineProof $false -DeterministicOrder 8)
    )
}

function Get-EnvelopeById {
    param(
        [Parameter(Mandatory = $true)]$Envelopes,
        [Parameter(Mandatory = $true)][string]$EnvelopeId
    )

    $matches = @($Envelopes | Where-Object { [string]$_.envelope_id -eq $EnvelopeId })
    if ($matches.Count -ne 1) {
        throw "Expected exactly one role-run envelope with envelope_id '$EnvelopeId', found $($matches.Count)."
    }

    return $matches[0]
}

function New-HandoffPacketObject {
    param(
        [Parameter(Mandatory = $true)]$Transition,
        [Parameter(Mandatory = $true)]$SourceEnvelope,
        [Parameter(Mandatory = $true)]$TargetEnvelope,
        [Parameter(Mandatory = $true)]$Guard
    )

    $order = [int](Get-RequiredProperty -InputObject $Transition -Name "deterministic_order" -Context "R16-020 transition")
    $transitionId = [string](Get-RequiredProperty -InputObject $Transition -Name "transition_id" -Context "R16-020 transition")
    $sourceRoleId = [string](Get-RequiredProperty -InputObject $Transition -Name "source_role_id" -Context "R16-020 transition")
    $targetRoleId = [string](Get-RequiredProperty -InputObject $Transition -Name "target_role_id" -Context "R16-020 transition")
    $actionType = [string](Get-RequiredProperty -InputObject $Transition -Name "action_type" -Context "R16-020 transition")
    $decision = [string](Get-RequiredProperty -InputObject $Transition -Name "decision" -Context "R16-020 transition")
    $executionPermitted = [bool](Get-RequiredProperty -InputObject $Transition -Name "execution_permitted" -Context "R16-020 transition")
    $blockedReasons = [string[]]@($Transition.blocked_reasons | ForEach-Object { [string]$_ })
    $upperBound = [int64]$Guard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$Guard.evaluated_budget.max_estimated_tokens_upper_bound

    $blockedReason = "R16-020 RACI transition gate decision '$decision' blocks transition '$transitionId' and context budget guard remains failed_closed_over_budget; estimated_tokens_upper_bound $upperBound exceeds max_estimated_tokens_upper_bound $threshold. This R16-021 handoff packet is not executable and does not run a workflow drill or runtime execution."

    return [pscustomobject][ordered]@{
        handoff_packet_id = ("r16-021-handoff-packet-{0:D3}-{1}-to-{2}" -f $order, $sourceRoleId, $targetRoleId)
        source_role_id = $sourceRoleId
        target_role_id = $targetRoleId
        action_type = $actionType
        source_envelope_ref = New-RefObject -RefId "source_envelope_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "source role-run envelope lookup in generated envelopes; state artifact only" -MachineProof $false -DeterministicOrder 1 -Extra @{
            envelope_id = [string]$SourceEnvelope.envelope_id
            role_id = [string]$SourceEnvelope.role_id
        }
        target_envelope_ref = New-RefObject -RefId "target_envelope_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "target role-run envelope lookup in generated envelopes; state artifact only" -MachineProof $false -DeterministicOrder 2 -Extra @{
            envelope_id = [string]$TargetEnvelope.envelope_id
            role_id = [string]$TargetEnvelope.role_id
        }
        transition_gate_ref = New-RefObject -RefId "transition_gate_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "R16-020 RACI transition gate report decision; state artifact only" -MachineProof $false -DeterministicOrder 3 -Extra @{
            gate_id = "aioffice-r16-020-raci-transition-gate-v1"
            transition_id = $transitionId
        }
        transition_decision = [pscustomobject][ordered]@{
            transition_id = $transitionId
            gate_id = "aioffice-r16-020-raci-transition-gate-v1"
            decision = $decision
            execution_permitted = $executionPermitted
            fail_closed = [bool]$Transition.fail_closed
            blocked_reasons = [string[]]$blockedReasons
            context_budget_guard_verdict = [string]$Transition.context_budget_guard_verdict
            deterministic_order = 1
        }
        card_state_ref = Copy-JsonObject -Value $Transition.card_state.card_state_ref
        memory_pack_ref = Copy-JsonObject -Value $TargetEnvelope.memory_pack_ref
        context_load_plan_ref = Copy-JsonObject -Value $TargetEnvelope.context_load_plan_ref
        context_budget_estimate_ref = Copy-JsonObject -Value $TargetEnvelope.context_budget_estimate_ref
        context_budget_guard_ref = Copy-JsonObject -Value $TargetEnvelope.context_budget_guard_ref
        evidence_refs = [object[]](New-HandoffEvidenceRefs)
        handoff_constraints = [pscustomobject][ordered]@{
            handoff_packet_state_artifact_only = $true
            transition_gate_blocks_execution = $true
            budget_guard_blocks_execution = $true
            may_not_execute = $true
            may_not_transfer_execution = $true
            executable_handoff_allowed = $false
            workflow_drill_run = $false
            runtime_handoff_execution_claimed = $false
            runtime_execution_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            r16_022_implementation_claimed = $false
            deterministic_order = 1
        }
        blocked_reason = $blockedReason
        executable = $false
        handoff_execution_status = "blocked"
        non_claims = [string[]]$script:RequiredPacketNonClaims
        deterministic_order = $order
    }
}

function New-R16HandoffPacketReportObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $roleRunEnvelopeContract = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelope_contract_ref) -Label "R16 role-run envelope contract"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"
    $estimate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_estimate_ref) -Label "R16 context budget estimate"
    $loadPlan = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_load_plan_ref) -Label "R16 context-load plan"
    $memoryPacks = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_memory_packs_ref) -Label "R16 role memory packs"

    if ([string]$roleRunEnvelopes.artifact_type -ne "r16_role_run_envelopes") {
        throw "R16-021 handoff packet generation requires state/workflow/r16_role_run_envelopes.json."
    }
    if ([string]$roleRunEnvelopeContract.artifact_type -ne "r16_role_run_envelope_contract") {
        throw "R16-021 handoff packet generation requires contracts/workflow/r16_role_run_envelope.contract.json."
    }
    if ([string]$raciGate.artifact_type -ne "r16_raci_transition_gate_report" -or [string]$raciGate.source_task -ne "R16-020") {
        throw "R16-021 handoff packet generation requires the R16-020 RACI transition gate report."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "R16-021 handoff packet generation requires guard aggregate_verdict $script:GuardVerdict."
    }
    if ([string]$estimate.artifact_type -ne "r16_context_budget_estimate" -or [string]$loadPlan.artifact_type -ne "r16_context_load_plan" -or [string]$memoryPacks.artifact_type -ne "r16_role_memory_packs") {
        throw "R16-021 handoff packet generation requires the R16 context estimate, context-load plan, and role memory packs."
    }

    $envelopes = @($roleRunEnvelopes.envelopes)
    $transitions = @($raciGate.evaluated_transitions | Sort-Object -Property deterministic_order)
    $packets = @()
    foreach ($transition in $transitions) {
        $sourceEnvelope = Get-EnvelopeById -Envelopes $envelopes -EnvelopeId ([string]$transition.source_envelope_id)
        $targetEnvelope = Get-EnvelopeById -Envelopes $envelopes -EnvelopeId ([string]$transition.target_envelope_id)
        $packets += New-HandoffPacketObject -Transition $transition -SourceEnvelope $sourceEnvelope -TargetEnvelope $targetEnvelope -Guard $guard
    }

    $blockedCount = @($packets | Where-Object { [string]$_.handoff_execution_status -eq "blocked" -and -not [bool]$_.executable }).Count
    $executableCount = @($packets | Where-Object { [bool]$_.executable }).Count
    $upperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound

    return [pscustomobject][ordered]@{
        artifact_type = "r16_handoff_packet_report"
        handoff_packet_version = $script:HandoffPacketVersion
        handoff_packet_report_id = $script:HandoffPacketReportId
        source_milestone = $script:R16Milestone
        source_task = "R16-021"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = "R16-021 finalization pass generates bounded handoff packet report/state artifacts only from R16-020 evaluated transitions; no executable handoff, workflow drill, runtime handoff execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, or external integrations are claimed."
        role_run_envelopes_ref = New-RefObject -RefId "role_run_envelopes_ref" -Path $script:RequiredRefPaths.role_run_envelopes_ref -SourceTask "R16-019" -ProofTreatment "committed generated role-run envelope state artifact only" -MachineProof $false -DeterministicOrder 1
        raci_transition_gate_report_ref = New-RefObject -RefId "raci_transition_gate_report_ref" -Path $script:RequiredRefPaths.raci_transition_gate_report_ref -SourceTask "R16-020" -ProofTreatment "committed generated RACI transition gate report state artifact only" -MachineProof $false -DeterministicOrder 2
        context_budget_guard_ref = New-RefObject -RefId "context_budget_guard_ref" -Path $script:RequiredRefPaths.context_budget_guard_ref -SourceTask "R16-017" -ProofTreatment "committed generated context budget guard report state artifact only" -MachineProof $false -DeterministicOrder 3
        context_budget_estimate_ref = New-RefObject -RefId "context_budget_estimate_ref" -Path $script:RequiredRefPaths.context_budget_estimate_ref -SourceTask "R16-016" -ProofTreatment "committed generated context budget estimate state artifact only; approximate only" -MachineProof $false -DeterministicOrder 4
        context_load_plan_ref = New-RefObject -RefId "context_load_plan_ref" -Path $script:RequiredRefPaths.context_load_plan_ref -SourceTask "R16-015" -ProofTreatment "committed generated context-load plan state artifact only" -MachineProof $false -DeterministicOrder 5
        role_memory_packs_ref = New-RefObject -RefId "role_memory_packs_ref" -Path $script:RequiredRefPaths.role_memory_packs_ref -SourceTask "R16-007" -ProofTreatment "committed generated role memory pack state artifact only" -MachineProof $false -DeterministicOrder 6
        card_state_ref = New-RefObject -RefId "card_state_ref" -Path $script:RequiredRefPaths.card_state_ref -SourceTask "R16-019" -ProofTreatment "milestone authority and card-state boundary; not machine proof by itself" -MachineProof $false -DeterministicOrder 7
        generation_mode = [pscustomobject][ordered]@{
            state_artifact_generation_only = $true
            generated_from_r16_020_evaluated_transitions = $true
            handoff_packets_generated_as_state_artifacts_only = $true
            candidate_handoff_count = $packets.Count
            executable_handoffs_allowed = $false
            workflow_drill_run = $false
            runtime_handoff_execution_claimed = $false
            runtime_execution_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            r16_022_implementation_claimed = $false
            deterministic_order = 1
        }
        handoff_packets = [object[]]$packets
        blocked_handoff_count = $blockedCount
        executable_handoff_count = $executableCount
        required_evidence_policy = [pscustomobject][ordered]@{
            required_paths = [string[]]$script:RequiredEvidencePaths
            required_refs_are_exact_repo_relative = $true
            required_refs_are_tracked_files = $true
            all_handoff_evidence_refs_must_exist = $true
            wildcard_paths_allowed = $false
            directory_only_refs_allowed = $false
            scratch_temp_refs_allowed = $false
            absolute_paths_allowed = $false
            parent_traversal_allowed = $false
            url_or_remote_refs_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            generated_reports_as_machine_proof_allowed = $false
        }
        no_full_repo_scan_policy = [pscustomobject][ordered]@{
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
        current_posture = [pscustomobject][ordered]@{
            active_through_task = "R16-021"
            active_through_scope = "R16-021 bounded handoff packet generation/reporting only"
            status_surfaces_updated_this_pass = $true
            status_surfaces_active_through_task = "R16-021"
            complete_tasks = [string[]]@("R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006", "R16-007", "R16-008", "R16-009", "R16-010", "R16-011", "R16-012", "R16-013", "R16-014", "R16-015", "R16-016", "R16-017", "R16-018", "R16-019", "R16-020", "R16-021")
            planned_tasks = [string[]]@("R16-022", "R16-023", "R16-024", "R16-025", "R16-026")
            role_run_envelope_contract_defined = $true
            generated_role_run_envelopes_exist = $true
            raci_transition_gate_validator_exists = $true
            raci_transition_gate_report_exists = $true
            handoff_packet_report_exists = $true
            generated_handoff_packets_are_state_artifacts_only = $true
            all_handoff_packets_blocked = $true
            executable_handoffs_exist = $false
            workflow_drill_exists = $false
            workflow_drill_run = $false
            runtime_handoff_execution_exists = $false
            runtime_handoff_execution_claimed = $false
            runtime_memory_exists = $false
            retrieval_runtime_exists = $false
            vector_search_runtime_exists = $false
            product_runtime_exists = $false
            autonomous_agents_exist = $false
            external_integrations_exist = $false
            r16_022_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        preserved_boundaries = [pscustomobject][ordered]@{
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
        finding_summary = [pscustomobject][ordered]@{
            evaluated_transition_count = $transitions.Count
            handoff_packet_count = $packets.Count
            blocked_handoff_count = $blockedCount
            executable_handoff_count = $executableCount
            blocked_transition_count = [int64]$raciGate.blocked_transition_count
            allowed_transition_count = [int64]$raciGate.allowed_transition_count
            current_guard_verdict = [string]$guard.aggregate_verdict
            estimated_tokens_upper_bound = $upperBound
            max_estimated_tokens_upper_bound = $threshold
            no_executable_handoffs = $true
            no_workflow_drill_run = $true
            no_runtime_handoff_execution = $true
            no_runtime_execution = $true
        }
        aggregate_verdict = $script:AggregateVerdict
        validation_commands = [object[]]@(
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[0]; deterministic_order = 1 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[1]; deterministic_order = 2 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[2]; deterministic_order = 3 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[3]; deterministic_order = 4 },
            [pscustomobject][ordered]@{ command = $script:RequiredValidationCommands[4]; deterministic_order = 5 }
        )
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
    foreach ($trueField in @("repo_relative_exact_paths_only", "tracked_files_only", "exact_dependency_refs_only", "no_wildcard_path_expansion")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
        }
    }
    foreach ($falseField in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_paths_allowed", "wildcard_path_expansion_performed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $policyObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ([string](Get-RequiredProperty -InputObject $postureObject -Name "active_through_task" -Context $Context) -ne "R16-021") {
        throw "$Context active_through_task must be R16-021."
    }

    $plannedTasks = Assert-StringArray -Value (Get-RequiredProperty -InputObject $postureObject -Name "planned_tasks" -Context $Context) -Context "$Context planned_tasks"
    Assert-RequiredStringsPresent -Actual $plannedTasks -Required ([string[]]@("R16-022", "R16-023", "R16-024", "R16-025", "R16-026")) -Context "$Context planned_tasks"
    $completeTasks = Assert-StringArray -Value (Get-RequiredProperty -InputObject $postureObject -Name "complete_tasks" -Context $Context) -Context "$Context complete_tasks"
    Assert-RequiredStringsPresent -Actual $completeTasks -Required ([string[]]@("R16-021")) -Context "$Context complete_tasks"

    foreach ($falseField in @("executable_handoffs_exist", "workflow_drill_exists", "workflow_drill_run", "runtime_handoff_execution_exists", "runtime_handoff_execution_claimed", "runtime_memory_exists", "retrieval_runtime_exists", "vector_search_runtime_exists", "product_runtime_exists", "autonomous_agents_exist", "external_integrations_exist", "r16_022_implementation_claimed", "r16_027_or_later_task_exists")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $falseField -Context $Context) -Context "$Context $falseField") -ne $false) {
            throw "$Context contains forbidden $falseField claim."
        }
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name "status_surfaces_updated_this_pass" -Context $Context) -Context "$Context status_surfaces_updated_this_pass") -ne $true) {
        throw "$Context status_surfaces_updated_this_pass must be True for R16-021 finalization."
    }
    if ([string](Get-RequiredProperty -InputObject $postureObject -Name "status_surfaces_active_through_task" -Context $Context) -ne "R16-021") {
        throw "$Context status_surfaces_active_through_task must be R16-021."
    }
    foreach ($trueField in @("generated_role_run_envelopes_exist", "raci_transition_gate_report_exists", "handoff_packet_report_exists", "generated_handoff_packets_are_state_artifacts_only", "all_handoff_packets_blocked")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $postureObject -Name $trueField -Context $Context) -Context "$Context $trueField") -ne $true) {
            throw "$Context $trueField must be True."
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
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $r13 -Name "closed" -Context "$Context r13") -Context "$Context r13 closed") -ne $false -or (Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $r13 -Name "partial_gates_converted_to_passed" -Context "$Context r13") -Context "$Context r13 partial_gates_converted_to_passed") -ne $false) {
        throw "$Context contains R13 closure or partial-gate conversion claim."
    }

    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $r14 -Name "caveats_removed" -Context "$Context r14") -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context contains R14 caveat removal."
    }

    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $r15 -Name "caveats_removed" -Context "$Context r15") -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context contains R15 caveat removal."
    }
}

function Assert-HandoffPacket {
    param(
        [Parameter(Mandatory = $true)]$Packet,
        [Parameter(Mandatory = $true)]$Transition,
        [Parameter(Mandatory = $true)]$RoleRunEnvelopes,
        [Parameter(Mandatory = $true)]$Guard,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder
    )

    $context = "handoff_packets[$($ExpectedOrder - 1)]"
    $packetObject = Assert-ObjectValue -Value $Packet -Context $context
    foreach ($fieldName in $script:RequiredPacketFields) {
        Get-RequiredProperty -InputObject $packetObject -Name $fieldName -Context $context | Out-Null
    }

    $sourceRoleId = Assert-NonEmptyString -Value $packetObject.source_role_id -Context "$context source_role_id"
    $targetRoleId = Assert-NonEmptyString -Value $packetObject.target_role_id -Context "$context target_role_id"
    $actionType = Assert-NonEmptyString -Value $packetObject.action_type -Context "$context action_type"
    $transitionId = [string]$Transition.transition_id

    if ($sourceRoleId -ne [string]$Transition.source_role_id) {
        throw "$context source_role_id must preserve transition source_role_id."
    }
    if ($targetRoleId -ne [string]$Transition.target_role_id) {
        throw "$context target_role_id must preserve transition target_role_id."
    }
    if ($actionType -ne [string]$Transition.action_type) {
        throw "$context action_type must preserve transition action_type."
    }

    $sourceEnvelopeRef = Assert-RefObject -RefObject $packetObject.source_envelope_ref -Context "$context source_envelope_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "source_envelope_ref"
    $targetEnvelopeRef = Assert-RefObject -RefObject $packetObject.target_envelope_ref -Context "$context target_envelope_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "target_envelope_ref"
    if ([string]$sourceEnvelopeRef.envelope_id -ne [string]$Transition.source_envelope_id) {
        throw "$context source_envelope_ref must preserve transition source_envelope_id."
    }
    if ([string]$targetEnvelopeRef.envelope_id -ne [string]$Transition.target_envelope_id) {
        throw "$context target_envelope_ref must preserve transition target_envelope_id."
    }

    $sourceEnvelopeMatches = @($RoleRunEnvelopes.envelopes | Where-Object { [string]$_.envelope_id -eq [string]$sourceEnvelopeRef.envelope_id -and [string]$_.role_id -eq $sourceRoleId })
    $targetEnvelopeMatches = @($RoleRunEnvelopes.envelopes | Where-Object { [string]$_.envelope_id -eq [string]$targetEnvelopeRef.envelope_id -and [string]$_.role_id -eq $targetRoleId })
    if ($sourceEnvelopeMatches.Count -ne 1) {
        throw "$context source_envelope_ref must match exactly one source role-run envelope."
    }
    if ($targetEnvelopeMatches.Count -ne 1) {
        throw "$context target_envelope_ref must match exactly one target role-run envelope."
    }

    $transitionGateRef = Assert-RefObject -RefObject $packetObject.transition_gate_ref -Context "$context transition_gate_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "transition_gate_ref"
    if ([string]$transitionGateRef.transition_id -ne $transitionId) {
        throw "$context transition_gate_ref must preserve transition_id."
    }

    $transitionDecision = Assert-ObjectValue -Value $packetObject.transition_decision -Context "$context transition_decision"
    foreach ($fieldName in @("transition_id", "gate_id", "decision", "execution_permitted", "fail_closed", "blocked_reasons", "context_budget_guard_verdict", "deterministic_order")) {
        Get-RequiredProperty -InputObject $transitionDecision -Name $fieldName -Context "$context transition_decision" | Out-Null
    }
    if ([string]$transitionDecision.transition_id -ne $transitionId -or [string]$transitionDecision.decision -ne [string]$Transition.decision) {
        throw "$context transition_decision must preserve the R16-020 transition decision."
    }
    if ([string]$transitionDecision.decision -ne "blocked" -or (Assert-BooleanValue -Value $transitionDecision.execution_permitted -Context "$context transition_decision execution_permitted") -ne $false) {
        throw "$context transition_decision must remain blocked with execution_permitted False."
    }
    $decisionReasons = Assert-StringArray -Value $transitionDecision.blocked_reasons -Context "$context transition_decision blocked_reasons"
    foreach ($blockedReason in @($Transition.blocked_reasons | ForEach-Object { [string]$_ })) {
        if ($decisionReasons -notcontains $blockedReason) {
            throw "$context transition_decision missing R16-020 blocked reason '$blockedReason'."
        }
    }
    if ($decisionReasons -notcontains "context_budget_guard_failed_closed_over_budget") {
        throw "$context transition_decision must preserve failed_closed_over_budget gate block reason."
    }

    Assert-RefObject -RefObject $packetObject.card_state_ref -Context "$context card_state_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.card_state_ref -ExpectedRefId "card_state_ref" | Out-Null
    $memoryPackRef = Assert-RefObject -RefObject $packetObject.memory_pack_ref -Context "$context memory_pack_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "memory_pack_ref"
    if ([string]$memoryPackRef.role_id -ne $targetRoleId) {
        throw "$context memory_pack_ref must target the handoff target_role_id."
    }
    Assert-RefObject -RefObject $packetObject.context_load_plan_ref -Context "$context context_load_plan_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref" | Out-Null
    Assert-RefObject -RefObject $packetObject.context_budget_estimate_ref -Context "$context context_budget_estimate_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref" | Out-Null
    Assert-RefObject -RefObject $packetObject.context_budget_guard_ref -Context "$context context_budget_guard_ref" -RepositoryRoot $RepositoryRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref" | Out-Null

    $evidenceRefs = @(Assert-ObjectArray -Value $packetObject.evidence_refs -Context "$context evidence_refs")
    $evidencePaths = @()
    for ($evidenceIndex = 0; $evidenceIndex -lt $evidenceRefs.Count; $evidenceIndex += 1) {
        $evidenceRef = Assert-RefObject -RefObject $evidenceRefs[$evidenceIndex] -Context "$context evidence_refs[$evidenceIndex]" -RepositoryRoot $RepositoryRoot
        $evidencePaths += ConvertTo-NormalizedRepoPath -PathValue ([string]$evidenceRef.path)
    }
    Assert-RequiredStringsPresent -Actual ([string[]]$evidencePaths) -Required $script:RequiredEvidencePaths -Context "$context evidence_refs path"

    $constraints = Assert-ObjectValue -Value $packetObject.handoff_constraints -Context "$context handoff_constraints"
    foreach ($trueField in @("handoff_packet_state_artifact_only", "transition_gate_blocks_execution", "budget_guard_blocks_execution", "may_not_execute", "may_not_transfer_execution")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $constraints -Name $trueField -Context "$context handoff_constraints") -Context "$context handoff_constraints $trueField") -ne $true) {
            throw "$context handoff_constraints $trueField must be True."
        }
    }
    foreach ($falseField in @("executable_handoff_allowed", "workflow_drill_run", "runtime_handoff_execution_claimed", "runtime_execution_claimed", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "product_runtime_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "r16_022_implementation_claimed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $constraints -Name $falseField -Context "$context handoff_constraints") -Context "$context handoff_constraints $falseField") -ne $false) {
            throw "$context handoff_constraints contains forbidden $falseField claim."
        }
    }

    $executable = Assert-BooleanValue -Value $packetObject.executable -Context "$context executable"
    if ($executable -eq $true) {
        throw "$context handoff executable while transition gate is blocked and guard is failed_closed_over_budget."
    }

    if ([string]$Guard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "$context guard must remain failed_closed_over_budget."
    }
    $executionStatus = Assert-NonEmptyString -Value $packetObject.handoff_execution_status -Context "$context handoff_execution_status"
    if ($executionStatus -notin @("blocked", "not_executable")) {
        throw "$context handoff_execution_status must be blocked or not_executable."
    }
    $packetBlockedReason = Assert-NonEmptyString -Value $packetObject.blocked_reason -Context "$context blocked_reason"
    if ($packetBlockedReason -notlike "*R16-020*") {
        throw "$context blocked_reason must reference the R16-020 gate block."
    }
    if ($packetBlockedReason -notlike "*failed_closed_over_budget*") {
        throw "$context blocked_reason must reference failed_closed_over_budget."
    }

    $packetNonClaims = Assert-StringArray -Value $packetObject.non_claims -Context "$context non_claims"
    Assert-RequiredStringsPresent -Actual $packetNonClaims -Required $script:RequiredPacketNonClaims -Context "$context non_claims"
    if ((Assert-IntegerValue -Value $packetObject.deterministic_order -Context "$context deterministic_order") -ne $ExpectedOrder) {
        throw "$context deterministic_order must be $ExpectedOrder."
    }
}

function Test-R16HandoffPacketReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 handoff packet report",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Assert-ObjectValue -Value $Report -Context $SourceLabel | Out-Null
    foreach ($fieldName in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -InputObject $Report -Name $fieldName -Context $SourceLabel | Out-Null
    }

    Assert-NoForbiddenTrueClaims -Value $Report -Context $SourceLabel
    Assert-AllPathFieldsAreSafe -Value $Report -RepositoryRoot $resolvedRoot -Context $SourceLabel

    if ([string]$Report.artifact_type -ne "r16_handoff_packet_report" -or [string]$Report.handoff_packet_version -ne $script:HandoffPacketVersion -or [string]$Report.handoff_packet_report_id -ne $script:HandoffPacketReportId -or [string]$Report.source_task -ne "R16-021") {
        throw "$SourceLabel identity fields are incorrect for R16-021."
    }
    if ([string]$Report.repository -ne $script:Repository -or [string]$Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }

    Assert-RefObject -RefObject $Report.role_run_envelopes_ref -Context "$SourceLabel role_run_envelopes_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_run_envelopes_ref -ExpectedRefId "role_run_envelopes_ref" | Out-Null
    Assert-RefObject -RefObject $Report.raci_transition_gate_report_ref -Context "$SourceLabel raci_transition_gate_report_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.raci_transition_gate_report_ref -ExpectedRefId "raci_transition_gate_report_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_guard_ref -Context "$SourceLabel context_budget_guard_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_guard_ref -ExpectedRefId "context_budget_guard_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_budget_estimate_ref -Context "$SourceLabel context_budget_estimate_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_budget_estimate_ref -ExpectedRefId "context_budget_estimate_ref" | Out-Null
    Assert-RefObject -RefObject $Report.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.context_load_plan_ref -ExpectedRefId "context_load_plan_ref" | Out-Null
    Assert-RefObject -RefObject $Report.role_memory_packs_ref -Context "$SourceLabel role_memory_packs_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.role_memory_packs_ref -ExpectedRefId "role_memory_packs_ref" | Out-Null
    Assert-RefObject -RefObject $Report.card_state_ref -Context "$SourceLabel card_state_ref" -RepositoryRoot $resolvedRoot -ExpectedPath $script:RequiredRefPaths.card_state_ref -ExpectedRefId "card_state_ref" | Out-Null

    $roleRunEnvelopes = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.role_run_envelopes_ref) -Label "R16 role-run envelopes"
    $raciGate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.raci_transition_gate_report_ref) -Label "R16 RACI transition gate report"
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot $script:RequiredRefPaths.context_budget_guard_ref) -Label "R16 context budget guard report"

    if ([string]$raciGate.aggregate_verdict -ne "failed_closed_all_transitions_blocked_by_budget_guard" -or [int64]$raciGate.allowed_transition_count -ne 0 -or [int64]$raciGate.blocked_transition_count -ne 4) {
        throw "$SourceLabel requires the R16-020 gate to remain failed closed with all four transitions blocked."
    }
    if ([string]$guard.aggregate_verdict -ne $script:GuardVerdict) {
        throw "$SourceLabel requires guard aggregate_verdict failed_closed_over_budget."
    }

    $evidencePolicy = Assert-ObjectValue -Value $Report.required_evidence_policy -Context "$SourceLabel required_evidence_policy"
    $requiredPaths = Assert-StringArray -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name "required_paths" -Context "$SourceLabel required_evidence_policy") -Context "$SourceLabel required_evidence_policy required_paths"
    Assert-RequiredStringsPresent -Actual $requiredPaths -Required $script:RequiredEvidencePaths -Context "$SourceLabel required_evidence_policy required_paths"
    foreach ($requiredPath in $requiredPaths) {
        Assert-SafeRepoRelativeTrackedPath -PathValue $requiredPath -RepositoryRoot $resolvedRoot -Context "$SourceLabel required_evidence_policy required_paths" | Out-Null
    }
    foreach ($falseField in @("wildcard_paths_allowed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "raw_chat_history_as_evidence_allowed", "generated_reports_as_machine_proof_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $evidencePolicy -Name $falseField -Context "$SourceLabel required_evidence_policy") -Context "$SourceLabel required_evidence_policy $falseField") -ne $false) {
            throw "$SourceLabel required_evidence_policy contains forbidden $falseField claim."
        }
    }

    Assert-NoFullRepoScanPolicy -Policy $Report.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $packets = @(Assert-ObjectArray -Value $Report.handoff_packets -Context "$SourceLabel handoff_packets")
    $transitions = @($raciGate.evaluated_transitions | Sort-Object -Property deterministic_order)
    if ($packets.Count -ne $transitions.Count) {
        throw "$SourceLabel must generate one deterministic handoff packet per R16-020 evaluated transition."
    }

    for ($packetIndex = 0; $packetIndex -lt $packets.Count; $packetIndex += 1) {
        Assert-HandoffPacket -Packet $packets[$packetIndex] -Transition $transitions[$packetIndex] -RoleRunEnvelopes $roleRunEnvelopes -Guard $guard -RepositoryRoot $resolvedRoot -ExpectedOrder ($packetIndex + 1)
    }

    $blockedCount = @($packets | Where-Object { [string]$_.handoff_execution_status -in @("blocked", "not_executable") -and -not [bool]$_.executable }).Count
    $executableCount = @($packets | Where-Object { [bool]$_.executable }).Count
    if ([int64]$Report.blocked_handoff_count -ne $blockedCount -or [int64]$Report.blocked_handoff_count -ne 4) {
        throw "$SourceLabel blocked_handoff_count must be 4."
    }
    if ([int64]$Report.executable_handoff_count -ne $executableCount -or [int64]$Report.executable_handoff_count -ne 0) {
        throw "$SourceLabel executable_handoff_count must be 0."
    }

    $summary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    if ([int64]$summary.evaluated_transition_count -ne 4 -or [int64]$summary.handoff_packet_count -ne 4 -or [int64]$summary.blocked_handoff_count -ne 4 -or [int64]$summary.executable_handoff_count -ne 0) {
        throw "$SourceLabel finding_summary must record four generated blocked handoff packets and zero executable handoffs."
    }
    if ([string]$summary.current_guard_verdict -ne $script:GuardVerdict -or [int64]$summary.estimated_tokens_upper_bound -ne [int64]$guard.evaluated_budget.estimated_tokens_upper_bound -or [int64]$summary.max_estimated_tokens_upper_bound -ne [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound) {
        throw "$SourceLabel finding_summary must preserve failed_closed_over_budget guard values."
    }
    foreach ($trueField in @("no_executable_handoffs", "no_workflow_drill_run", "no_runtime_handoff_execution", "no_runtime_execution")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $summary -Name $trueField -Context "$SourceLabel finding_summary") -Context "$SourceLabel finding_summary $trueField") -ne $true) {
            throw "$SourceLabel finding_summary $trueField must be True."
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
        HandoffPacketReportId = [string]$Report.handoff_packet_report_id
        SourceTask = [string]$Report.source_task
        ActiveThroughTask = [string]$Report.current_posture.active_through_task
        PlannedTaskStart = [string]$Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = [string]$Report.current_posture.planned_tasks[-1]
        HandoffPacketCount = $packets.Count
        BlockedHandoffCount = [int64]$Report.blocked_handoff_count
        ExecutableHandoffCount = [int64]$Report.executable_handoff_count
        AggregateVerdict = [string]$Report.aggregate_verdict
        BudgetGuardVerdict = [string]$guard.aggregate_verdict
        EstimatedTokensUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
        MaxEstimatedTokensUpperBound = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
    }
}

function Test-R16HandoffPacketReport {
    [CmdletBinding()]
    param(
        [string]$Path = "state/workflow/r16_handoff_packet_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 handoff packet report"
    return Test-R16HandoffPacketReportObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function New-R16HandoffPacketReport {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/workflow/r16_handoff_packet_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16HandoffPacketReportObject -RepositoryRoot $resolvedRoot
    $resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $OutputPath) }
    Write-StableJsonFile -InputObject $report -PathValue $resolvedOutput
    $validation = Test-R16HandoffPacketReport -Path $OutputPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        HandoffPacketReportId = $validation.HandoffPacketReportId
        HandoffPacketCount = $validation.HandoffPacketCount
        BlockedHandoffCount = $validation.BlockedHandoffCount
        ExecutableHandoffCount = $validation.ExecutableHandoffCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        AggregateVerdict = $validation.AggregateVerdict
        BudgetGuardVerdict = $validation.BudgetGuardVerdict
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        MaxEstimatedTokensUpperBound = $validation.MaxEstimatedTokensUpperBound
    }
}

function Test-R16HandoffPacketReportContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/workflow/r16_handoff_packet_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 handoff packet report contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "handoff_packet_report_contract_id", "source_milestone", "source_task", "repository", "branch", "dependency_refs", "required_report_fields", "handoff_packet_generation_policy", "required_evidence_policy", "no_full_repo_scan_policy", "current_posture_policy", "non_claims", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 handoff packet report contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_handoff_packet_report_contract" -or [string]$contract.source_task -ne "R16-021") {
        throw "R16 handoff packet report contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 handoff packet report contract"
    Assert-AllPathFieldsAreSafe -Value $contract -RepositoryRoot $resolvedRoot -Context "R16 handoff packet report contract"

    $requiredReportFields = Assert-StringArray -Value $contract.required_report_fields -Context "R16 handoff packet report contract required_report_fields"
    Assert-RequiredStringsPresent -Actual $requiredReportFields -Required $script:RequiredTopLevelFields -Context "R16 handoff packet report contract required_report_fields"
    $dependencyRefs = @(Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 handoff packet report contract dependency_refs")
    $dependencyPaths = @()
    for ($index = 0; $index -lt $dependencyRefs.Count; $index += 1) {
        $dependencyRef = Assert-RefObject -RefObject $dependencyRefs[$index] -Context "R16 handoff packet report contract dependency_refs[$index]" -RepositoryRoot $resolvedRoot
        $dependencyPaths += ConvertTo-NormalizedRepoPath -PathValue ([string]$dependencyRef.path)
    }
    Assert-RequiredStringsPresent -Actual ([string[]]$dependencyPaths) -Required $script:RequiredEvidencePaths -Context "R16 handoff packet report contract dependency_refs path"
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 handoff packet report contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 handoff packet report contract non_claims"

    return [pscustomobject]@{
        ContractId = [string]$contract.handoff_packet_report_contract_id
        SourceTask = [string]$contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        RequiredReportFieldCount = $requiredReportFields.Count
    }
}

function New-R16HandoffPacketFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_handoff_packet_generator",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validReport = New-R16HandoffPacketReportObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validReport -PathValue (Join-Path $fixtureRootPath "valid_handoff_packet_report.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_handoff_packet_report.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.generation_mode' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generation_mode'")
        "invalid_missing_role_run_envelopes_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_role_run_envelopes_ref" -MutationPath '$.role_run_envelopes_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_raci_transition_gate_report_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_raci_transition_gate_report_ref" -MutationPath '$.raci_transition_gate_report_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'raci_transition_gate_report_ref'")
        "invalid_missing_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_guard_ref" -MutationPath '$.context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_handoff_packets.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_handoff_packets" -MutationPath '$.handoff_packets' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'handoff_packets'")
        "invalid_missing_source_role_id.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_source_role_id" -MutationPath '$.handoff_packets[0].source_role_id' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'source_role_id'")
        "invalid_missing_target_role_id.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_target_role_id" -MutationPath '$.handoff_packets[0].target_role_id' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'target_role_id'")
        "invalid_missing_transition_decision.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_transition_decision" -MutationPath '$.handoff_packets[0].transition_decision' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'transition_decision'")
        "invalid_handoff_executable_transition_gate_blocked.json" = New-MutationFixtureSpec -FixtureId "invalid_handoff_executable_transition_gate_blocked" -MutationPath '$.handoff_packets[0].executable' -MutationValue $true -ExpectedFailure @("executable while transition gate is blocked")
        "invalid_handoff_executable_guard_failed_closed_over_budget.json" = New-MutationFixtureSpec -FixtureId "invalid_handoff_executable_guard_failed_closed_over_budget" -MutationPath '$.handoff_packets[1].executable' -MutationValue $true -ExpectedFailure @("guard is failed_closed_over_budget")
        "invalid_blocked_reason_missing_failed_closed_over_budget.json" = New-MutationFixtureSpec -FixtureId "invalid_blocked_reason_missing_failed_closed_over_budget" -MutationPath '$.handoff_packets[0].blocked_reason' -MutationValue "R16-020 gate blocks this handoff, but the guard verdict is omitted." -ExpectedFailure @("blocked_reason", "failed_closed_over_budget")
        "invalid_missing_card_state_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_card_state_ref" -MutationPath '$.handoff_packets[0].card_state_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'card_state_ref'")
        "invalid_missing_memory_pack_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_memory_pack_ref" -MutationPath '$.handoff_packets[0].memory_pack_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'memory_pack_ref'")
        "invalid_missing_context_load_plan_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_load_plan_ref" -MutationPath '$.handoff_packets[0].context_load_plan_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_load_plan_ref'")
        "invalid_missing_context_budget_estimate_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_context_budget_estimate_ref" -MutationPath '$.handoff_packets[0].context_budget_estimate_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_estimate_ref'")
        "invalid_missing_packet_context_budget_guard_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_packet_context_budget_guard_ref" -MutationPath '$.handoff_packets[0].context_budget_guard_ref' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_evidence_refs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_evidence_refs" -MutationPath '$.handoff_packets[0].evidence_refs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'evidence_refs'")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "state/memory/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "state/memory/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "scratch/r16_handoff_packet.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "C:/tmp/r16_handoff_packet.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "../state/memory/r16_role_memory_packs.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.handoff_packets[0].memory_pack_ref.path' -MutationValue "https://example.invalid/r16_role_memory_packs.json" -ExpectedFailure @("URL or remote ref")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_raw_chat_history_evidence_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_evidence_claim" -MutationPath '$.required_evidence_policy.raw_chat_history_as_evidence_allowed' -MutationValue $true -ExpectedFailure @("raw chat history evidence claim")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.required_evidence_policy.generated_reports_as_machine_proof_allowed' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.generation_mode.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.generation_mode.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.generation_mode.runtime_memory_implemented' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.generation_mode.retrieval_runtime_implemented' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.generation_mode.vector_search_runtime_implemented' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.generation_mode.product_runtime_implemented' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.generation_mode.actual_autonomous_agents_implemented' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.generation_mode.external_integrations_implemented' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_workflow_drill_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_workflow_drill_claim" -MutationPath '$.generation_mode.workflow_drill_run' -MutationValue $true -ExpectedFailure @("workflow drill claim")
        "invalid_runtime_handoff_execution_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_handoff_execution_claim" -MutationPath '$.handoff_packets[0].handoff_constraints.runtime_handoff_execution_claimed' -MutationValue $true -ExpectedFailure @("runtime handoff execution claim")
        "invalid_r16_022_implementation_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_022_implementation_claim" -MutationPath '$.current_posture.r16_022_implementation_claimed' -MutationValue $true -ExpectedFailure @("R16-022 implementation claim")
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
        ValidFixture = (Join-Path $FixtureRoot "valid_handoff_packet_report.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16HandoffPacketReportObject, New-R16HandoffPacketReport, Test-R16HandoffPacketReportObject, Test-R16HandoffPacketReport, Test-R16HandoffPacketReportContract, New-R16HandoffPacketFixtureFiles, ConvertTo-StableJson
