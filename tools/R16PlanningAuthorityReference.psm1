Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "reference_packet_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "authority_document_ref",
    "opening_validation_manifest_ref",
    "planning_artifacts",
    "artifact_paths",
    "artifact_roles",
    "authority_classes",
    "proof_treatment",
    "task_posture",
    "preserved_boundaries",
    "claims",
    "non_claims",
    "validation_commands",
    "invalid_state_rules"
)

$script:ApprovedPlanningArtifactPaths = @(
    "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
    "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"
)

$script:RequiredArtifactPaths = @(
    "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
    "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md",
    "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/validation_manifest.md",
    "contracts/governance/r16_planning_authority_reference.contract.json",
    "tools/R16PlanningAuthorityReference.psm1",
    "tools/validate_r16_planning_authority_reference.ps1",
    "tests/test_r16_planning_authority_reference.ps1",
    "state/governance/r16_planning_authority_reference.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/README.md",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/validation_manifest.md",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/non_claims.json"
)

$script:RequiredProofTreatment = [ordered]@{
    planning_reports_are_operator_artifacts_only = $true
    planning_reports_are_implementation_proof = $false
    r16_002_claims_r16_003_or_later = $false
    memory_layers_implemented = $false
    artifact_maps_implemented = $false
    audit_maps_implemented = $false
    context_load_planners_implemented = $false
    role_run_envelopes_implemented = $false
    handoff_packets_implemented = $false
    product_runtime_implemented = $false
    productized_ui_implemented = $false
    actual_autonomous_agents_implemented = $false
    true_multi_agent_execution_implemented = $false
    persistent_memory_runtime_implemented = $false
    runtime_memory_loading_implemented = $false
    retrieval_runtime_implemented = $false
    vector_search_runtime_implemented = $false
    external_integrations_implemented = $false
    main_merge_completed = $false
    r13_closed = $false
    r14_caveats_removed = $false
    r15_caveats_removed = $false
    solved_codex_compaction = $false
    solved_codex_reliability = $false
    r16_027_or_later_task_exists = $false
}

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
    "no R16-003 implementation",
    "no R16-027 or later task",
    "no memory layers implemented yet",
    "no artifact maps implemented yet",
    "no audit maps implemented yet",
    "no context-load planners implemented yet",
    "no role-run envelopes implemented yet",
    "no handoff packets implemented yet"
)

$script:RequiredInvalidRuleIds = @(
    "missing_approved_v2_report_rejected",
    "planning_report_as_proof_rejected",
    "r16_003_or_later_implementation_claim_rejected",
    "runtime_agent_memory_retrieval_integration_overclaims_rejected",
    "preserved_boundary_changes_rejected",
    "r16_027_or_later_task_rejected"
)

$script:RequiredValidationCommands = @(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1 -PacketPath state\governance\r16_planning_authority_reference.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1",
    "git diff --check",
    "git status --short",
    "git rev-parse HEAD",
    "git rev-parse ""HEAD^{tree}""",
    "git branch --show-current"
)

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
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

    $PSCmdlet.WriteObject($items, $false)
}

function Resolve-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$RepositoryRoot = $repoRoot
    )

    if ($Path -match '^\s*(\.|\.\\|\./|\*|\*\*|/|\\|repo|repository|full_repo|entire_repo)\s*$') {
        throw "$Context path '$Path' is unbounded."
    }

    $resolvedPath = Resolve-RepoRelativePath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Assert-RequiredValuesPresent {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $extraValues = @($Values | Where-Object { $ExpectedValues -notcontains $_ })
    $missingValues = @($ExpectedValues | Where-Object { $Values -notcontains $_ })
    if ($missingValues.Count -gt 0 -or $extraValues.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missingValues -join ', '). Extra: $($extraValues -join ', ')."
    }
}

function Get-StringValuesFromObject {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Get-StringValuesFromObject -Value $Value[$key]
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringValuesFromObject -Value $item
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            Get-StringValuesFromObject -Value $property.Value
        }
    }
}

function Test-TextHasNegation {
    param(
        [AllowNull()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    if ($Text -match '^\s*-\s+(any\s+)?(broad UI or control-room productization|UI or control-room productization|productized UI|productized control-room behavior|full UI app|Standard runtime|Standard or subproject runtime|multi-repo orchestration|multi-repo or fleet orchestration|swarms|swarms or fleet execution|broad autonomous milestone execution|broad autonomy|unattended automatic resume|product runtime|production runtime|production QA|full product QA|full product QA coverage|solved Codex reliability|solved Codex compaction|solved Codex context compaction|hours-long unattended milestone execution|destructive rollback|destructive primary-tree rollback|main merge|Linear integration|Symphony integration|GitHub Projects integration|custom board implementation|R13 closure|R13 hard gates passed|R15 opening|R15 implementation|R16 runtime|R16 closure)') {
        return $true
    }

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|false|prohibited|forbidden|disallowed|reject|rejected|rejecting|claim|claims|fails validation|fail validation|fail-closed|only|operator artifact only|planning authority only)\b'
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$ClaimLabel,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    foreach ($value in $Values) {
        if ($value -match $Pattern -and -not (Test-TextHasNegation -Text $value)) {
            throw "$Context contains forbidden positive claim: $ClaimLabel. Text: $value"
        }
    }
}

function Get-R16TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R16-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R16 task status headings."
    }

    $statusMap = @{}
    foreach ($match in $matches) {
        $taskId = $match.Groups[1].Value
        $status = $match.Groups[2].Value
        if ($statusMap.ContainsKey($taskId)) {
            throw "$Context defines duplicate task status entries for '$taskId'."
        }

        $statusMap[$taskId] = $status
    }

    return $statusMap
}

function Get-ContiguousDoneThroughFromStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$StatusMap,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $doneThrough = 0
    $plannedStart = $null
    $plannedThrough = $null

    foreach ($taskNumber in 1..26) {
        $taskId = "R16-{0}" -f $taskNumber.ToString("000")
        if (-not $StatusMap.ContainsKey($taskId)) {
            throw "$Context is missing status for '$taskId'."
        }

        $status = $StatusMap[$taskId]
        if ($status -eq "done") {
            if ($null -ne $plannedStart) {
                throw "$Context marks '$taskId' done after planned tasks have already started."
            }

            $doneThrough = $taskNumber
            continue
        }

        if ($null -eq $plannedStart) {
            $plannedStart = $taskNumber
        }

        $plannedThrough = $taskNumber
    }

    return [pscustomobject]@{
        DoneThrough = $doneThrough
        PlannedStart = $plannedStart
        PlannedThrough = $plannedThrough
    }
}

function Assert-R16PlanningAuthorityStatusPosture {
    param(
        [string]$RepositoryRoot = $repoRoot
    )

    $statusPaths = @(
        "README.md",
        "governance\ACTIVE_STATE.md",
        "execution\KANBAN.md",
        "governance\DECISION_LOG.md",
        "governance\DOCUMENT_AUTHORITY_INDEX.md",
        "governance\R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md",
        "governance\R14_PRODUCT_VISION_PIVOT_AND_GOVERNANCE_ENFORCEMENT.md",
        "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md",
        "governance\R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"
    )

    $texts = @{}
    foreach ($relativePath in $statusPaths) {
        $path = Join-Path $RepositoryRoot $relativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "R16-002 status posture check could not find '$relativePath'."
        }

        $texts[$relativePath] = Get-Content -LiteralPath $path -Raw
    }

    $kanbanStatus = Get-R16TaskStatusMap -Text $texts["execution\KANBAN.md"] -Context "KANBAN"
    $authorityStatus = Get-R16TaskStatusMap -Text $texts["governance\R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"] -Context "R16 authority"
    foreach ($taskId in $kanbanStatus.Keys) {
        if ($authorityStatus[$taskId] -ne $kanbanStatus[$taskId]) {
            throw "R16 authority does not match KANBAN for status '$taskId'."
        }
    }

    $snapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanStatus -Context "KANBAN"
    if ($snapshot.DoneThrough -ne 21 -or $snapshot.PlannedStart -ne 22 -or $snapshot.PlannedThrough -ne 26) {
        throw "Status docs must keep R16 active through R16-021 only with R16-022 through R16-026 planned only."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    foreach ($requiredText in @(
            "R16 active through R16-021 only",
            "R16-022 through R16-026 remain planned only",
            "R16-002 installed and validated planning authority references only",
            "R16-003 added KPI baseline and target scorecard only",
            "R16-004 defined the memory layer contract only",
            "R16-005 implemented deterministic baseline memory layer generation only",
            "R16-006 added the role-specific memory pack model only",
            "R16-007 generated baseline role memory packs only",
            "R16-008 added memory pack validation and stale-ref detection only",
            "R16-009 defined the artifact map contract only",
            "R16-010 implemented the bounded artifact map generator for milestone scope",
            "R16-011 added the audit map contract only",
            "R16-012 generated the bounded R15/R16 audit map",
            "R16-013 added bounded artifact/audit map diff-check tooling and a committed check report",
            "R16-014 added the context-load plan contract only",
            "R16-015 implemented the exact context-load planner and generated a committed context-load plan state artifact",
            "R16-016 implemented a bounded context budget estimator with approximation fields",
            "R16-017 adds bounded over-budget/no-full-repo-scan guard only",
            "R16-018 defines the role-run envelope contract only",
            "R16-019 generated role-run envelopes as committed state artifacts only",
            "R16-020 adds bounded RACI transition gate validation/reporting only",
            "R16-021 adds bounded handoff packet generation/reporting only",
            "KPI targets are",
            "generated baseline memory layers are committed state artifacts, not runtime memory",
            "Generated baseline role memory packs are committed state artifacts, not runtime memory",
            "Generated baseline role memory packs are not actual agents",
            "Generated baseline role memory packs do not perform work or workflow execution",
            "state/audit/r16_r15_r16_audit_map.json",
            "committed generated audit map state artifact only",
            "The audit map is not runtime memory",
            "The audit map is not product runtime",
            "The audit map is not a context-load planner",
            "The audit map is not artifact-map diff/check tooling",
            "state/artifacts/r16_artifact_audit_map_check_report.json",
            "committed validation/check report state artifact only",
            "The check report is not runtime memory",
            "The check report is not product runtime",
            "The check report is not a context-load planner",
            "The check report is not a context budget estimator",
            "The check report is not a role-run envelope",
            "The check report is not a handoff packet",
            "The check report is not workflow execution",
            "state/context/r16_context_load_plan.json",
            "committed generated context-load plan state artifact only",
            "The context-load plan is not runtime memory",
            "The context-load plan is not runtime memory loading",
            "The context-load plan is not retrieval runtime",
            "The context-load plan is not vector search runtime",
            "The context-load plan is not product runtime",
            "The context-load plan is not a context budget estimator",
            "The context-load plan is not an over-budget fail-closed validator",
            "The context-load plan is not a role-run envelope",
            "The context-load plan is not a RACI transition gate",
            "The context-load plan is not a handoff packet",
            "The context-load plan is not workflow execution",
            "state/context/r16_context_budget_estimate.json",
            "committed generated context budget estimate state artifact only",
            "The estimate is approximate only",
            "The estimate is not exact provider tokenization",
            "The estimate is not exact provider billing",
            "The estimate is not an over-budget fail-closed validator",
            "state/context/r16_context_budget_guard_report.json",
            "committed generated context budget guard report state artifact only",
            "The guard can fail closed on over-budget context plans",
            "The guard is not runtime memory",
            "The guard is not retrieval runtime",
            "The guard is not vector search runtime",
            "The guard is not product runtime",
            "The guard is not a role-run envelope",
            "The guard is not a RACI transition gate",
            "The guard is not a handoff packet",
            "The guard is not a workflow drill",
            "state/workflow/r16_role_run_envelopes.json",
            "committed generated role-run envelope state artifact only",
            "The role-run envelope generator is bounded state-artifact generation only",
            "All generated role-run envelopes are non-executable while the guard is",
            "state/workflow/r16_raci_transition_gate_report.json",
            "committed generated RACI transition gate report state artifact only",
            "The RACI transition gate report blocks all evaluated execution transitions due to",
            "This is not runtime execution",
            "state/workflow/r16_handoff_packet_report.json",
            "committed generated handoff packet report state artifact only",
            "all generated handoff packets are blocked/not executable",
            "No workflow drill exists yet",
            "state/governance/r16_planning_authority_reference.json",
            "state/governance/r16_kpi_baseline_target_scorecard.json",
            "state/memory/r16_role_memory_pack_model.json",
            "state/memory/r16_role_memory_packs.json"
        )) {
        if ($combinedText.IndexOf($requiredText, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "Status docs must include '$requiredText'."
        }
    }

    foreach ($requiredPath in $script:ApprovedPlanningArtifactPaths) {
        if ($combinedText.IndexOf($requiredPath, [System.StringComparison]::Ordinal) -lt 0) {
            throw "Status docs must reference approved planning artifact '$requiredPath'."
        }
    }

    if ($combinedText -notmatch '(?i)R13 remains failed/partial.*R13-018.*not closed') {
        throw "Status docs must preserve R13 failed/partial through R13-018 and not closed."
    }
    if ($combinedText -notmatch '(?i)R14.*accepted with caveats.*R14-006|R14.*accepted.*caveats.*through `R14-006`') {
        throw "Status docs must preserve R14 accepted with caveats through R14-006."
    }
    if ($combinedText -notmatch '(?i)R15.*accepted with caveats.*R15-009|R15.*accepted with caveats.*bounded foundation milestone only') {
        throw "Status docs must preserve R15 accepted with caveats through R15-009."
    }
    if ($combinedText -notmatch 'r15_final_proof_review_package\.json' -or $combinedText -notmatch 'evidence_index\.json') {
        throw "Status docs must preserve the R15-009 stale generated_from caveat references."
    }

    $stringValues = @($combinedText -split "\r?\n")
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R16-022 or later implementation" -Pattern '(?i)\bR16-(0(?:2[2-6]))\b.{0,160}\b(done|complete|completed|implemented|executed|ran|claimed|created)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "exact provider token count" -Pattern '(?i)\b(exact provider token count|exact provider tokenization|exact provider tokenizer|provider tokenizer used|exact tokenizer)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "exact provider billing" -Pattern '(?i)\b(exact provider billing|exact provider bill|provider bill|provider billing|provider pricing used|exact provider pricing)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "generated baseline memory layers treated as runtime memory" -Pattern '(?i)\b(generated baseline memory layers|baseline generated memory layers|baseline memory layers)\b.{0,160}\b(are runtime memory|as runtime memory|runtime memory loading|persistent memory runtime|retrieval runtime|vector search runtime|production memory runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "generated role memory packs treated as runtime memory, agents, or workflow execution" -Pattern '(?i)\b(generated role memory pack|generated role memory packs|generated baseline role memory pack|generated baseline role memory packs|baseline role memory pack|baseline role memory packs|role-specific memory pack|role-specific memory packs)\b(?!\s+model\b).{0,180}\b(are runtime memory|as runtime memory|runtime memory loading|persistent memory runtime|retrieval runtime|vector search runtime|actual agents|actual autonomous agents|agent runtime|perform work|workflow execution|perform workflow execution|external integration|external integrations)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R16 closure" -Pattern '(?i)\bR16\b.{0,160}\b(is now closed|is closed|closed in repo truth|formally closed|closeout package exists|final proof package complete|accepted as closed)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "artifact map or audit map runtime overclaim" -Pattern '(?i)\b(artifact map|audit map)\b.{0,180}\b(runtime|runtime memory|product runtime|context-load planner|workflow execution|retrieval runtime|vector search runtime|agent runtime|external integration)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "artifact map contract treated as generated artifact map" -Pattern '(?i)\bartifact map contract\b.{0,160}\b(generated artifact map|operational artifact map|generated map|runtime memory|retrieval runtime|vector runtime|audit execution|workflow execution)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "context-load plan runtime or budget overclaim" -Pattern '(?i)\b(context-load plan|context load plan|context-load planner|context load planner)\b.{0,180}\b(runtime memory|runtime memory loading|retrieval runtime|vector search runtime|product runtime|context budget estimator|over-budget fail-closed validator|role-run envelope|RACI transition gate|handoff packet|workflow execution)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "executable or runtime role-run envelope implementation" -Pattern '(?i)\b(generated role-run envelope|generated role-run envelopes|role-run envelope generator|role run envelope generator)\b.{0,180}\b((?<!non-)executable|runtime|runs|dispatches|workflow execution|autonomous|product runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "executable or runtime handoff packet implementation" -Pattern '(?i)\b(handoff packet|handoff packets|handoff packet report)\b.{0,160}\b((?<!non-)executable|runtime handoff execution|runtime execution|runtime|workflow execution|workflow drill ran|workflow drill executed|product runtime|ships)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "RACI transition gate runtime/execution overclaim" -Pattern '(?i)\b(RACI transition gate|RACI transition gates|RACI transition gate report)\b.{0,160}\b(runtime execution|runtime|executes|executed transition|executes role handoffs|handoff packet generated|workflow drill ran|product runtime|autonomous)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "workflow drill implementation" -Pattern '(?i)\b(workflow drill|workflow drills)\b.{0,160}\b(implemented|implementation complete|created|exists|ships|runtime|ran)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R16-027 or later task" -Pattern '(?i)\bR16-(0(?:2[7-9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned|active)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "product runtime" -Pattern '(?i)\b(product runtime|production runtime|productized UI|productized control-room behavior|full UI app)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "true agent or multi-agent runtime" -Pattern '(?i)\b(actual autonomous agents|actual agents implemented|true multi-agent execution|true multi-agent runtime|multi-agent runtime|agent runtime|direct agent access runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "persistent memory runtime" -Pattern '(?i)\b(persistent memory engine|persistent memory runtime|runtime memory loading|production memory runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "retrieval or vector runtime" -Pattern '(?i)\b(retrieval runtime|retrieval engine|runtime retrieval|runtime vector search|vector search runtime|vector search)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "external integration" -Pattern '(?i)\b(GitHub Projects integration|Linear integration|Symphony integration|custom board integration|custom board runtime|external board sync|external integration|board sync)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "solved Codex compaction or reliability" -Pattern '(?i)\b(solved Codex compaction|solved Codex context compaction|solved Codex reliability|Codex reliability solved|Codex compaction solved)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "main merge" -Pattern '(?i)\b(main merge|merged to main|main contains R16|R16.*merged to main)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R13 closure" -Pattern '(?i)\bR13\b.{0,120}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R13 partial gates converted to passed" -Pattern '(?i)\b(API/custom-runner bypass|current operator control-room|current operator control room|skill invocation evidence|operator demo)\b.{0,120}\b(passed|fully delivered|converted to passed|complete as a hard gate|delivered as a hard gate)\b|\bR13 hard gates\b.{0,120}\b(passed|fully delivered)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R14 caveat removal" -Pattern '(?i)\bR14\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context "Status docs" -ClaimLabel "R15 caveat removal" -Pattern '(?i)\bR15\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'

    return $snapshot
}

function Test-R16PlanningAuthorityReferenceObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "R16 planning authority reference packet",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Packet -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Packet.artifact_type -ne "r16_planning_authority_reference_packet") {
        throw "$SourceLabel artifact_type must be 'r16_planning_authority_reference_packet'."
    }
    if ($Packet.source_milestone -ne "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation") {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Packet.source_task -ne "R16-002") {
        throw "$SourceLabel source_task must be R16-002."
    }
    if ($Packet.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Packet.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }
    Assert-NonEmptyString -Value $Packet.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Packet.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    foreach ($refInfo in @(
            @{ Name = "authority_document_ref"; RequiredPath = "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md"; RequiredRole = "milestone_authority"; RequiredClass = "Class E" },
            @{ Name = "opening_validation_manifest_ref"; RequiredPath = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/validation_manifest.md"; RequiredRole = "opening_validation_manifest"; RequiredClass = "Class F" }
        )) {
        $refObject = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Packet -Name $refInfo.Name -Context $SourceLabel) -Context "$SourceLabel $($refInfo.Name)"
        if ($refObject.path -ne $refInfo.RequiredPath) {
            throw "$SourceLabel $($refInfo.Name) path must be '$($refInfo.RequiredPath)'."
        }
        if ($refObject.artifact_role -ne $refInfo.RequiredRole) {
            throw "$SourceLabel $($refInfo.Name) artifact_role must be '$($refInfo.RequiredRole)'."
        }
        if ($refObject.authority_class -ne $refInfo.RequiredClass) {
            throw "$SourceLabel $($refInfo.Name) authority_class must be '$($refInfo.RequiredClass)'."
        }
        if ((Assert-BooleanValue -Value $refObject.proof_by_itself -Context "$SourceLabel $($refInfo.Name) proof_by_itself") -ne $false) {
            throw "$SourceLabel $($refInfo.Name) proof_by_itself must be False."
        }
        if ((Assert-BooleanValue -Value $refObject.implementation_proof -Context "$SourceLabel $($refInfo.Name) implementation_proof") -ne $false) {
            throw "$SourceLabel $($refInfo.Name) implementation_proof must be False."
        }
        Assert-PathExists -Path $refObject.path -Context "$SourceLabel $($refInfo.Name)" -RepositoryRoot $RepositoryRoot | Out-Null
    }

    $artifactPaths = Assert-StringArray -Value $Packet.artifact_paths -Context "$SourceLabel artifact_paths"
    Assert-RequiredValuesPresent -Values $artifactPaths -RequiredValues $script:RequiredArtifactPaths -Context "$SourceLabel artifact_paths"
    foreach ($artifactPath in $artifactPaths) {
        Assert-PathExists -Path $artifactPath -Context "$SourceLabel artifact_paths" -RepositoryRoot $RepositoryRoot | Out-Null
    }

    Assert-ObjectValue -Value $Packet.artifact_roles -Context "$SourceLabel artifact_roles" | Out-Null
    foreach ($roleField in @("planning_artifacts", "authority_document", "opening_validation_manifest", "r16_002_packet")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet.artifact_roles -Name $roleField -Context "$SourceLabel artifact_roles") -Context "$SourceLabel artifact_roles $roleField" | Out-Null
    }

    $authorityClasses = Assert-ObjectArray -Value $Packet.authority_classes -Context "$SourceLabel authority_classes"
    foreach ($authorityClass in $authorityClasses) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authorityClass -Name "class" -Context "$SourceLabel authority_class") -Context "$SourceLabel authority_class class" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authorityClass -Name "treatment" -Context "$SourceLabel authority_class") -Context "$SourceLabel authority_class treatment" | Out-Null
    }

    Assert-ObjectValue -Value $Packet.proof_treatment -Context "$SourceLabel proof_treatment" | Out-Null
    foreach ($key in $script:RequiredProofTreatment.Keys) {
        Get-RequiredProperty -Object $Packet.proof_treatment -Name $key -Context "$SourceLabel proof_treatment" | Out-Null
        $actualValue = Assert-BooleanValue -Value $Packet.proof_treatment.$key -Context "$SourceLabel proof_treatment $key"
        if ($actualValue -ne $script:RequiredProofTreatment[$key]) {
            throw "$SourceLabel proof_treatment $key must be $($script:RequiredProofTreatment[$key])."
        }
    }

    $planningArtifacts = Assert-ObjectArray -Value $Packet.planning_artifacts -Context "$SourceLabel planning_artifacts"
    if ($planningArtifacts.Count -ne 2) {
        throw "$SourceLabel planning_artifacts must contain exactly the two approved v2 reports."
    }
    $planningArtifactPaths = @($planningArtifacts | ForEach-Object { [string]$_.path })
    Assert-ExactStringSet -Values $planningArtifactPaths -ExpectedValues $script:ApprovedPlanningArtifactPaths -Context "$SourceLabel planning_artifacts paths"

    foreach ($artifact in $planningArtifacts) {
        $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifact -Name "path" -Context "$SourceLabel planning_artifact") -Context "$SourceLabel planning_artifact path"
        Assert-PathExists -Path $path -Context "$SourceLabel planning_artifact" -RepositoryRoot $RepositoryRoot | Out-Null
        if ($artifact.artifact_role -ne "operator-approved planning artifact") {
            throw "$SourceLabel planning_artifact '$path' must be classified as operator-approved planning artifact."
        }
        if ($artifact.authority_class -ne "Class G") {
            throw "$SourceLabel planning_artifact '$path' authority_class must be Class G."
        }
        if ($artifact.proof_treatment -ne "planning_authority_only_not_implementation_proof") {
            throw "$SourceLabel planning_artifact '$path' must not be treated as implementation proof."
        }
        if ((Assert-BooleanValue -Value $artifact.operator_approved -Context "$SourceLabel planning_artifact '$path' operator_approved") -ne $true) {
            throw "$SourceLabel planning_artifact '$path' operator_approved must be True."
        }
        if ((Assert-BooleanValue -Value $artifact.proof_by_itself -Context "$SourceLabel planning_artifact '$path' proof_by_itself") -ne $false) {
            throw "$SourceLabel planning_artifact '$path' proof_by_itself must be False."
        }
        if ((Assert-BooleanValue -Value $artifact.implementation_proof -Context "$SourceLabel planning_artifact '$path' implementation_proof") -ne $false) {
            throw "$SourceLabel planning_artifact '$path' implementation_proof must be False."
        }
        Assert-ObjectValue -Value $artifact.content_identity -Context "$SourceLabel planning_artifact '$path' content_identity" | Out-Null
        if ($artifact.content_identity.hash_algorithm -ne "SHA256") {
            throw "$SourceLabel planning_artifact '$path' content_identity hash_algorithm must be SHA256."
        }
        $expectedHash = (Get-FileHash -LiteralPath (Resolve-RepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot) -Algorithm SHA256).Hash.ToLowerInvariant()
        $actualHash = (Assert-NonEmptyString -Value $artifact.content_identity.sha256 -Context "$SourceLabel planning_artifact '$path' sha256").ToLowerInvariant()
        if ($actualHash -ne $expectedHash) {
            throw "$SourceLabel planning_artifact '$path' hash mismatch."
        }
    }

    Assert-ObjectValue -Value $Packet.task_posture -Context "$SourceLabel task_posture" | Out-Null
    if ($Packet.task_posture.active_through_task -ne "R16-002") {
        throw "$SourceLabel task_posture active_through_task must be R16-002."
    }
    Assert-ExactStringSet -Values (Assert-StringArray -Value $Packet.task_posture.complete_tasks -Context "$SourceLabel task_posture complete_tasks") -ExpectedValues @("R16-001", "R16-002") -Context "$SourceLabel task_posture complete_tasks"
    $expectedPlannedTasks = @(3..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
    Assert-ExactStringSet -Values (Assert-StringArray -Value $Packet.task_posture.planned_tasks -Context "$SourceLabel task_posture planned_tasks") -ExpectedValues $expectedPlannedTasks -Context "$SourceLabel task_posture planned_tasks"

    $boundary = Assert-ObjectValue -Value $Packet.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r13" -Context "$SourceLabel preserved_boundaries") -Context "$SourceLabel preserved_boundaries r13"
    if ($r13.status -ne "failed/partial" -or $r13.active_through -ne "R13-018") {
        throw "$SourceLabel preserved_boundaries r13 must stay failed/partial through R13-018."
    }
    if ((Assert-BooleanValue -Value $r13.closed -Context "$SourceLabel preserved_boundaries r13 closed") -ne $false) {
        throw "$SourceLabel preserved_boundaries r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $r13.partial_gates_remain_partial -Context "$SourceLabel preserved_boundaries r13 partial_gates_remain_partial") -ne $true) {
        throw "$SourceLabel preserved_boundaries r13 partial_gates_remain_partial must be True."
    }
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $r13.partial_gates -Context "$SourceLabel preserved_boundaries r13 partial_gates") -RequiredValues @("API/custom-runner bypass", "current operator control room", "skill invocation evidence", "operator demo") -Context "$SourceLabel preserved_boundaries r13 partial_gates"

    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r14" -Context "$SourceLabel preserved_boundaries") -Context "$SourceLabel preserved_boundaries r14"
    if ($r14.status -ne "accepted_with_caveats" -or $r14.through -ne "R14-006") {
        throw "$SourceLabel preserved_boundaries r14 must stay accepted_with_caveats through R14-006."
    }
    foreach ($field in @("caveats_removed", "product_runtime", "r13_partial_gates_converted_to_passed")) {
        if ((Assert-BooleanValue -Value $r14.$field -Context "$SourceLabel preserved_boundaries r14 $field") -ne $false) {
            throw "$SourceLabel preserved_boundaries r14 $field must be False."
        }
    }

    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r15" -Context "$SourceLabel preserved_boundaries") -Context "$SourceLabel preserved_boundaries r15"
    if ($r15.status -ne "accepted_with_caveats" -or $r15.through -ne "R15-009") {
        throw "$SourceLabel preserved_boundaries r15 must stay accepted_with_caveats through R15-009."
    }
    if ($r15.audited_head -ne "d9685030a0556a528684d28367db83f4c72f7fc9" -or $r15.audited_tree -ne "7529230df0c1f5bec3625ba654b035a2af824e9b") {
        throw "$SourceLabel preserved_boundaries r15 audited head/tree must remain unchanged."
    }
    if ($r15.post_audit_support_commit -ne "3058bd6ed5067c97f744c92b9b9235004f0568b0") {
        throw "$SourceLabel preserved_boundaries r15 post_audit_support_commit must remain unchanged."
    }
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$SourceLabel preserved_boundaries r15 caveats_removed") -ne $false) {
        throw "$SourceLabel preserved_boundaries r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r15.stale_generated_from_caveat_preserved -Context "$SourceLabel preserved_boundaries r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$SourceLabel preserved_boundaries r15 stale_generated_from_caveat_preserved must be True."
    }
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $r15.stale_generated_from_caveat_files -Context "$SourceLabel preserved_boundaries r15 stale_generated_from_caveat_files") -RequiredValues @(
        "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json",
        "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
    ) -Context "$SourceLabel preserved_boundaries r15 stale_generated_from_caveat_files"

    $claims = Assert-StringArray -Value $Packet.claims -Context "$SourceLabel claims" -AllowEmpty
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    $validationCommands = Assert-ObjectArray -Value $Packet.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidStateRules = Assert-ObjectArray -Value $Packet.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    $stringValues = @(Get-StringValuesFromObject -Value $Packet)
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "R16-003 implementation" -Pattern '(?i)\bR16-003\b.{0,160}\b(done|complete|completed|implemented|executed|ran|claimed|created)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "memory layer implementation" -Pattern '(?i)\b(memory layer|memory layers|memory pack|memory packs|deterministic memory layer generator)\b.{0,160}\b(implemented|implementation complete|created|generated|ships|runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "artifact map implementation" -Pattern '(?i)\b(artifact map|artifact maps|audit map|audit maps)\b.{0,160}\b(implemented|implementation complete|created|exists|ships)\b|\b(implements|implemented|created|ships)\b.{0,80}\b(artifact map|artifact maps|audit map|audit maps)\b|\b(artifact map runtime|artifact maps runtime|audit map runtime|audit maps runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "context-load planner implementation" -Pattern '(?i)\b(context-load planner|context load planner|context-load plan|context load plan)\b.{0,160}\b(implemented|implementation complete|created|exists|ships|runtime)\b|\b(implements|implemented|created|ships)\b.{0,80}\b(context-load planner|context load planner|context-load plan|context load plan)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "role-run envelope or handoff packet implementation" -Pattern '(?i)\b(role-run envelope|role run envelope|handoff packet|handoff packets)\b.{0,160}\b(implemented|implementation complete|created|exists|ships|runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "product runtime" -Pattern '(?i)\b(product runtime|production runtime|productized UI|productized control-room behavior|full UI app)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "true agent or multi-agent runtime" -Pattern '(?i)\b(actual autonomous agents|actual agents implemented|true multi-agent execution|true multi-agent runtime|multi-agent runtime|agent runtime|direct agent access runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "persistent memory runtime" -Pattern '(?i)\b(persistent memory engine|persistent memory runtime|runtime memory loading|production memory runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "retrieval or vector runtime" -Pattern '(?i)\b(retrieval runtime|retrieval engine|runtime retrieval|runtime vector search|vector search runtime|vector search)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "external integration" -Pattern '(?i)\b(GitHub Projects integration|Linear integration|Symphony integration|custom board integration|custom board runtime|external board sync|external integration|board sync)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "solved Codex compaction or reliability" -Pattern '(?i)\b(solved Codex compaction|solved Codex context compaction|solved Codex reliability|Codex reliability solved|Codex compaction solved)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "main merge" -Pattern '(?i)\b(main merge|merged to main|main contains R16|R16.*merged to main)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "R13 closure" -Pattern '(?i)\bR13\b.{0,120}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "R14 caveat removal" -Pattern '(?i)\bR14\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "R15 caveat removal" -Pattern '(?i)\bR15\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'
    Assert-NoForbiddenPositiveClaim -Values $stringValues -Context $SourceLabel -ClaimLabel "R16-027 or later task" -Pattern '(?i)\bR16-(0(?:2[7-9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned|active)\b'

    return [pscustomobject]@{
        ArtifactType = $Packet.artifact_type
        ReferencePacketId = $Packet.reference_packet_id
        SourceTask = $Packet.source_task
        PlanningArtifactCount = $planningArtifacts.Count
        PlanningReportsOperatorArtifactsOnly = [bool]$Packet.proof_treatment.planning_reports_are_operator_artifacts_only
        PlanningReportsImplementationProof = [bool]$Packet.proof_treatment.planning_reports_are_implementation_proof
        ActiveThroughTask = $Packet.task_posture.active_through_task
        PlannedTaskStart = $Packet.task_posture.planned_tasks[0]
        PlannedTaskEnd = $Packet.task_posture.planned_tasks[-1]
        R13Closed = [bool]$r13.closed
        R14CaveatsRemoved = [bool]$r14.caveats_removed
        R15CaveatsRemoved = [bool]$r15.caveats_removed
        Claims = $claims
        NonClaims = $nonClaims
    }
}

function Test-R16PlanningAuthorityReference {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath,
        [string]$RepositoryRoot = $repoRoot,
        [switch]$SkipStatusPosture
    )

    $packet = Read-SingleJsonObject -Path $PacketPath -Label "R16 planning authority reference packet"
    $result = Test-R16PlanningAuthorityReferenceObject -Packet $packet -SourceLabel $PacketPath -RepositoryRoot $RepositoryRoot
    if (-not $SkipStatusPosture) {
        Assert-R16PlanningAuthorityStatusPosture -RepositoryRoot $RepositoryRoot | Out-Null
    }

    return $result
}

Export-ModuleMember -Function Test-R16PlanningAuthorityReference, Test-R16PlanningAuthorityReferenceObject, Assert-R16PlanningAuthorityStatusPosture
