Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "scorecard_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "scoring_model_ref",
    "reporting_standard_ref",
    "template_ref",
    "scorecard_mode",
    "current_posture",
    "priority_domains",
    "domain_scores",
    "weighted_aggregate",
    "target_aggregate",
    "evidence_caps",
    "confidence_model",
    "maturity_scale",
    "previous_reference_runs",
    "target_not_achievement_disclaimer",
    "preserved_boundaries",
    "non_claims",
    "validation_commands",
    "invalid_state_rules"
)

$script:ExpectedDomainWeights = [ordered]@{
    "Product Experience & Double-Diamond Workflow" = 12
    "Board & Work Orchestration" = 12
    "Agent Workforce & RACI" = 14
    "Knowledge, Memory & Context Compression" = 12
    "Execution Harness & QA" = 14
    "Governance, Evidence & Audit" = 8
    "Architecture & Integrations" = 8
    "Release & Environment Strategy" = 6
    "Security, Safety & Cost Controls" = 8
    "Continuous Improvement & Auto-Research" = 6
}

$script:PriorityDomains = @(
    "Knowledge, Memory & Context Compression",
    "Agent Workforce & RACI"
)

$script:AllowedConfidence = @("A", "B", "C", "D", "E")

$script:RequiredFutureFalseFields = @(
    "r16_004_or_later_implementation_claimed",
    "r16_027_or_later_task_exists",
    "memory_layers_implemented",
    "artifact_maps_implemented",
    "audit_maps_implemented",
    "context_load_planners_implemented",
    "role_run_envelopes_implemented",
    "handoff_packets_implemented",
    "product_runtime_implemented",
    "productized_ui_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "persistent_memory_runtime_implemented",
    "runtime_memory_loading_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "external_integrations_implemented",
    "main_merge_completed",
    "solved_codex_compaction",
    "solved_codex_reliability"
)

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
    "no R16-004 implementation",
    "no R16-027 or later task",
    "no memory layers implemented yet",
    "no artifact maps implemented yet",
    "no audit maps implemented yet",
    "no context-load planners implemented yet",
    "no role-run envelopes implemented yet",
    "no handoff packets implemented yet",
    "KPI targets are not achieved scores"
)

$script:RequiredValidationCommands = @(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_kpi_baseline_target_scorecard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state\governance\r16_kpi_baseline_target_scorecard.json",
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

$script:RequiredInvalidRuleIds = @(
    "missing_or_extra_kpi_domain_rejected",
    "wrong_weight_sum_rejected",
    "invalid_maturity_or_confidence_rejected",
    "score_above_cap_rejected",
    "target_as_achievement_rejected",
    "priority_uplift_missing_rejected",
    "r16_004_or_later_implementation_claim_rejected",
    "runtime_agent_memory_retrieval_integration_overclaims_rejected",
    "preserved_boundary_changes_rejected",
    "r16_027_or_later_task_rejected"
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

function Assert-NumericValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [byte] -and $Value -isnot [int] -and $Value -isnot [long] -and $Value -isnot [decimal] -and $Value -isnot [double] -and $Value -isnot [single]) {
        throw "$Context must be numeric."
    }

    return [double]$Value
}

function Assert-NumericRange {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [double]$Minimum = 0,
        [double]$Maximum = 5
    )

    $number = Assert-NumericValue -Value $Value -Context $Context
    if ($number -lt $Minimum -or $number -gt $Maximum) {
        throw "$Context must be between $Minimum and $Maximum."
    }

    return $number
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

function Assert-ScoreEquals {
    param(
        [double]$Actual,
        [double]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([math]::Abs($Actual - $Expected) -gt 0.05) {
        throw "$Context must be $Expected from maturity conversion, but was $Actual."
    }
}

function Convert-MaturityToScore {
    param(
        [double]$Maturity
    )

    return [math]::Round(($Maturity / 5.0) * 100.0, 1)
}

function Assert-ReferenceObject {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedPath,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$RepositoryRoot = $repoRoot
    )

    $refObject = Assert-ObjectValue -Value $Value -Context $Context
    if ($refObject.path -ne $ExpectedPath) {
        throw "$Context path must be '$ExpectedPath'."
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refObject -Name "authority_class" -Context $Context) -Context "$Context authority_class" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refObject -Name "proof_treatment" -Context $Context) -Context "$Context proof_treatment" | Out-Null
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $refObject -Name "proof_by_itself" -Context $Context) -Context "$Context proof_by_itself") -ne $false) {
        throw "$Context proof_by_itself must be False."
    }
    Assert-PathExists -Path $refObject.path -Context $Context -RepositoryRoot $RepositoryRoot | Out-Null
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    $boundary = Assert-ObjectValue -Value $Value -Context "$SourceLabel preserved_boundaries"
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
}

function Test-R16KpiBaselineTargetScorecardObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Scorecard,
        [string]$SourceLabel = "R16 KPI baseline target scorecard",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Scorecard -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Scorecard.artifact_type -ne "r16_kpi_baseline_target_scorecard") {
        throw "$SourceLabel artifact_type must be r16_kpi_baseline_target_scorecard."
    }
    if ($Scorecard.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Scorecard.source_milestone -ne "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation") {
        throw "$SourceLabel source_milestone must be the R16 milestone."
    }
    if ($Scorecard.source_task -ne "R16-003") {
        throw "$SourceLabel source_task must be R16-003."
    }
    if ($Scorecard.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Scorecard.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }
    Assert-NonEmptyString -Value $Scorecard.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Scorecard.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null
    if ($Scorecard.scorecard_mode -ne "baseline_and_target_not_achievement") {
        throw "$SourceLabel scorecard_mode must separate baseline/current achieved scoring from targets."
    }

    Assert-ReferenceObject -Value $Scorecard.scoring_model_ref -ExpectedPath "governance/KPI_DOMAIN_MODEL.md" -Context "$SourceLabel scoring_model_ref" -RepositoryRoot $RepositoryRoot
    Assert-ReferenceObject -Value $Scorecard.reporting_standard_ref -ExpectedPath "governance/MILESTONE_REPORTING_STANDARD.md" -Context "$SourceLabel reporting_standard_ref" -RepositoryRoot $RepositoryRoot
    Assert-ReferenceObject -Value $Scorecard.template_ref -ExpectedPath "governance/templates/AIOffice_Milestone_Report_Template_v2.md" -Context "$SourceLabel template_ref" -RepositoryRoot $RepositoryRoot

    $currentPosture = Assert-ObjectValue -Value $Scorecard.current_posture -Context "$SourceLabel current_posture"
    if ($currentPosture.active_through_task -ne "R16-003") {
        throw "$SourceLabel current_posture active_through_task must be R16-003."
    }
    Assert-ExactStringSet -Values (Assert-StringArray -Value $currentPosture.complete_tasks -Context "$SourceLabel current_posture complete_tasks") -ExpectedValues @("R16-001", "R16-002", "R16-003") -Context "$SourceLabel current_posture complete_tasks"
    $expectedPlannedTasks = @(4..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
    Assert-ExactStringSet -Values (Assert-StringArray -Value $currentPosture.planned_tasks -Context "$SourceLabel current_posture planned_tasks") -ExpectedValues $expectedPlannedTasks -Context "$SourceLabel current_posture planned_tasks"
    foreach ($field in $script:RequiredFutureFalseFields) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $currentPosture -Name $field -Context "$SourceLabel current_posture") -Context "$SourceLabel current_posture $field") -ne $false) {
            throw "$SourceLabel current_posture $field must be False."
        }
    }

    $domainScores = Assert-ObjectArray -Value $Scorecard.domain_scores -Context "$SourceLabel domain_scores"
    if ($domainScores.Count -ne 10) {
        throw "$SourceLabel domain_scores must include exactly 10 KPI domains."
    }

    $domainNames = @($domainScores | ForEach-Object { [string](Get-RequiredProperty -Object $_ -Name "domain" -Context "$SourceLabel domain_scores") })
    Assert-ExactStringSet -Values $domainNames -ExpectedValues ([string[]]$script:ExpectedDomainWeights.Keys) -Context "$SourceLabel domain_scores domains"

    $weightSum = 0.0
    $currentWeightedScore = 0.0
    $targetWeightedScore = 0.0
    $domainByName = @{}

    foreach ($domainScore in $domainScores) {
        $domainName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $domainScore -Name "domain" -Context "$SourceLabel domain_score") -Context "$SourceLabel domain_score domain"
        if ($domainByName.ContainsKey($domainName)) {
            throw "$SourceLabel domain_scores contains duplicate domain '$domainName'."
        }
        $domainByName[$domainName] = $domainScore

        $weight = Assert-NumericValue -Value (Get-RequiredProperty -Object $domainScore -Name "weight" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName weight"
        if ($weight -ne [double]$script:ExpectedDomainWeights[$domainName]) {
            throw "$SourceLabel $domainName weight must be $($script:ExpectedDomainWeights[$domainName])."
        }
        $weightSum += $weight

        $currentMaturity = Assert-NumericRange -Value (Get-RequiredProperty -Object $domainScore -Name "current_maturity" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName current_maturity"
        $currentScore = Assert-NumericValue -Value (Get-RequiredProperty -Object $domainScore -Name "current_score" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName current_score"
        Assert-ScoreEquals -Actual $currentScore -Expected (Convert-MaturityToScore -Maturity $currentMaturity) -Context "$SourceLabel $domainName current_score"
        $evidenceCap = Assert-NumericValue -Value (Get-RequiredProperty -Object $domainScore -Name "evidence_cap" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName evidence_cap"
        if ($currentScore -gt $evidenceCap) {
            throw "$SourceLabel $domainName current_score above evidence cap."
        }
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $domainScore -Name "cap_applied" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName cap_applied") -ne $true) {
            throw "$SourceLabel $domainName cap_applied must be True."
        }
        $confidence = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $domainScore -Name "evidence_confidence" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName evidence_confidence"
        if ($script:AllowedConfidence -notcontains $confidence) {
            throw "$SourceLabel $domainName evidence_confidence has unsupported confidence level '$confidence'."
        }
        $currentScoreBasis = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $domainScore -Name "current_score_basis" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName current_score_basis"
        if ($currentScoreBasis -notmatch '(?i)baseline|current achieved') {
            throw "$SourceLabel $domainName current_score_basis must explicitly identify baseline/current achieved scoring."
        }
        $evidenceRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $domainScore -Name "evidence_refs" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName evidence_refs"
        foreach ($evidenceRef in $evidenceRefs) {
            Assert-PathExists -Path $evidenceRef -Context "$SourceLabel $domainName evidence_refs" -RepositoryRoot $RepositoryRoot | Out-Null
        }

        $targetMaturity = Assert-NumericRange -Value (Get-RequiredProperty -Object $domainScore -Name "target_maturity" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_maturity"
        $targetScore = Assert-NumericValue -Value (Get-RequiredProperty -Object $domainScore -Name "target_score" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_score"
        Assert-ScoreEquals -Actual $targetScore -Expected (Convert-MaturityToScore -Maturity $targetMaturity) -Context "$SourceLabel $domainName target_score"
        $targetEvidenceCap = Assert-NumericValue -Value (Get-RequiredProperty -Object $domainScore -Name "target_evidence_cap" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_evidence_cap"
        if ($targetScore -gt $targetEvidenceCap) {
            throw "$SourceLabel $domainName target_score above target evidence cap."
        }
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $domainScore -Name "target_is_achievement" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_is_achievement") -ne $false) {
            throw "$SourceLabel $domainName target_is_achievement must be False."
        }
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $domainScore -Name "target_treated_as_evidence" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_treated_as_evidence") -ne $false) {
            throw "$SourceLabel $domainName target_treated_as_evidence must be False."
        }
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $domainScore -Name "target_rationale" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName target_rationale" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $domainScore -Name "next_correction" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName next_correction" | Out-Null
        Assert-StringArray -Value (Get-RequiredProperty -Object $domainScore -Name "risks" -Context "$SourceLabel $domainName") -Context "$SourceLabel $domainName risks" | Out-Null

        $currentWeightedScore += ($currentScore * $weight / 100.0)
        $targetWeightedScore += ($targetScore * $weight / 100.0)
    }

    if ([math]::Abs($weightSum - 100.0) -gt 0.001) {
        throw "$SourceLabel domain weights must sum to 100."
    }

    $priorityDomains = Assert-ObjectArray -Value $Scorecard.priority_domains -Context "$SourceLabel priority_domains"
    if ($priorityDomains.Count -ne 2) {
        throw "$SourceLabel priority_domains must include exactly Knowledge/Memory and Agent/RACI."
    }
    $priorityNames = @($priorityDomains | ForEach-Object { [string](Get-RequiredProperty -Object $_ -Name "domain" -Context "$SourceLabel priority_domains") })
    Assert-ExactStringSet -Values $priorityNames -ExpectedValues $script:PriorityDomains -Context "$SourceLabel priority_domains domains"
    foreach ($priority in $priorityDomains) {
        $domainName = [string]$priority.domain
        $domainScore = $domainByName[$domainName]
        $currentMaturity = Assert-NumericValue -Value $domainScore.current_maturity -Context "$SourceLabel $domainName current_maturity"
        $targetMaturity = Assert-NumericValue -Value $domainScore.target_maturity -Context "$SourceLabel $domainName target_maturity"
        $targetUplift = Assert-NumericValue -Value (Get-RequiredProperty -Object $priority -Name "target_uplift" -Context "$SourceLabel priority $domainName") -Context "$SourceLabel priority $domainName target_uplift"
        Assert-ScoreEquals -Actual $targetUplift -Expected ([math]::Round($targetMaturity - $currentMaturity, 1)) -Context "$SourceLabel priority $domainName target_uplift"
        if ($targetUplift -lt 1.5) {
            throw "$SourceLabel priority $domainName target uplift missing or too small."
        }
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $priority -Name "target_is_achievement" -Context "$SourceLabel priority $domainName") -Context "$SourceLabel priority $domainName target_is_achievement") -ne $false) {
            throw "$SourceLabel priority $domainName target_is_achievement must be False."
        }
    }

    $weightedAggregate = Assert-ObjectValue -Value $Scorecard.weighted_aggregate -Context "$SourceLabel weighted_aggregate"
    if ($weightedAggregate.mode -ne "current_achieved_baseline_only") {
        throw "$SourceLabel weighted_aggregate mode must be current_achieved_baseline_only."
    }
    if ((Assert-BooleanValue -Value $weightedAggregate.targets_included -Context "$SourceLabel weighted_aggregate targets_included") -ne $false) {
        throw "$SourceLabel weighted_aggregate targets_included must be False."
    }
    $recordedCurrentAggregate = Assert-NumericValue -Value $weightedAggregate.score -Context "$SourceLabel weighted_aggregate score"
    Assert-ScoreEquals -Actual $recordedCurrentAggregate -Expected ([math]::Round($currentWeightedScore, 1)) -Context "$SourceLabel weighted_aggregate score"

    $targetAggregate = Assert-ObjectValue -Value $Scorecard.target_aggregate -Context "$SourceLabel target_aggregate"
    if ($targetAggregate.mode -ne "target_by_r16_closeout_not_achieved") {
        throw "$SourceLabel target_aggregate mode must be target_by_r16_closeout_not_achieved."
    }
    if ((Assert-BooleanValue -Value $targetAggregate.achieved -Context "$SourceLabel target_aggregate achieved") -ne $false) {
        throw "$SourceLabel target_aggregate achieved must be False."
    }
    if ((Assert-BooleanValue -Value $targetAggregate.requires_future_evidence -Context "$SourceLabel target_aggregate requires_future_evidence") -ne $true) {
        throw "$SourceLabel target_aggregate requires_future_evidence must be True."
    }
    $recordedTargetAggregate = Assert-NumericValue -Value $targetAggregate.score -Context "$SourceLabel target_aggregate score"
    Assert-ScoreEquals -Actual $recordedTargetAggregate -Expected ([math]::Round($targetWeightedScore, 1)) -Context "$SourceLabel target_aggregate score"

    $disclaimer = Assert-ObjectValue -Value $Scorecard.target_not_achievement_disclaimer -Context "$SourceLabel target_not_achievement_disclaimer"
    foreach ($falseField in @("target_scores_are_achieved_scores", "target_scores_are_current_evidence", "target_scores_close_r16")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $disclaimer -Name $falseField -Context "$SourceLabel target_not_achievement_disclaimer") -Context "$SourceLabel target_not_achievement_disclaimer $falseField") -ne $false) {
            throw "$SourceLabel target_not_achievement_disclaimer $falseField must be False."
        }
    }
    if ((Assert-BooleanValue -Value $disclaimer.target_scores_require_future_evidence -Context "$SourceLabel target_not_achievement_disclaimer target_scores_require_future_evidence") -ne $true) {
        throw "$SourceLabel target_not_achievement_disclaimer target_scores_require_future_evidence must be True."
    }

    $evidenceCaps = Assert-ObjectValue -Value $Scorecard.evidence_caps -Context "$SourceLabel evidence_caps"
    foreach ($trueField in @("current_scores_must_not_exceed_caps", "targets_do_not_override_current_caps", "score_caps_applied")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $evidenceCaps -Name $trueField -Context "$SourceLabel evidence_caps") -Context "$SourceLabel evidence_caps $trueField") -ne $true) {
            throw "$SourceLabel evidence_caps $trueField must be True."
        }
    }

    $confidenceModel = Assert-ObjectValue -Value $Scorecard.confidence_model -Context "$SourceLabel confidence_model"
    Assert-ExactStringSet -Values (Assert-StringArray -Value $confidenceModel.allowed_values -Context "$SourceLabel confidence_model allowed_values") -ExpectedValues $script:AllowedConfidence -Context "$SourceLabel confidence_model allowed_values"
    $maturityScale = Assert-ObjectArray -Value $Scorecard.maturity_scale -Context "$SourceLabel maturity_scale"
    $scaleValues = @($maturityScale | ForEach-Object { [int](Assert-NumericValue -Value $_.value -Context "$SourceLabel maturity_scale value") })
    Assert-ExactStringSet -Values ([string[]]($scaleValues | ForEach-Object { $_.ToString() })) -ExpectedValues @("0", "1", "2", "3", "4", "5") -Context "$SourceLabel maturity_scale values"

    $previousRuns = Assert-ObjectArray -Value $Scorecard.previous_reference_runs -Context "$SourceLabel previous_reference_runs" -AllowEmpty
    foreach ($run in $previousRuns) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $run -Name "run_id" -Context "$SourceLabel previous_reference_runs") -Context "$SourceLabel previous_reference_runs run_id" | Out-Null
        $evidenceRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $run -Name "evidence_ref" -Context "$SourceLabel previous_reference_runs") -Context "$SourceLabel previous_reference_runs evidence_ref"
        Assert-PathExists -Path $evidenceRef -Context "$SourceLabel previous_reference_runs" -RepositoryRoot $RepositoryRoot | Out-Null
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $run -Name "evidence_backed" -Context "$SourceLabel previous_reference_runs") -Context "$SourceLabel previous_reference_runs evidence_backed") -ne $true) {
            throw "$SourceLabel previous_reference_runs must be evidence-backed if listed."
        }
    }

    Assert-PreservedBoundaries -Value $Scorecard.preserved_boundaries -SourceLabel $SourceLabel

    $nonClaims = Assert-StringArray -Value $Scorecard.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredValuesPresent -Values $nonClaims -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    $validationCommands = Assert-ObjectArray -Value $Scorecard.validation_commands -Context "$SourceLabel validation_commands"
    $commandValues = @($validationCommands | ForEach-Object { [string]$_.command })
    Assert-RequiredValuesPresent -Values $commandValues -RequiredValues $script:RequiredValidationCommands -Context "$SourceLabel validation_commands"

    $invalidStateRules = Assert-ObjectArray -Value $Scorecard.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    $ruleIds = @($invalidStateRules | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$SourceLabel invalid_state_rules"

    return [pscustomobject]@{
        ArtifactType = $Scorecard.artifact_type
        ScorecardId = $Scorecard.scorecard_id
        SourceTask = $Scorecard.source_task
        ActiveThroughTask = $currentPosture.active_through_task
        PlannedTaskStart = $currentPosture.planned_tasks[0]
        PlannedTaskEnd = $currentPosture.planned_tasks[-1]
        DomainCount = $domainScores.Count
        WeightSum = [math]::Round($weightSum, 1)
        CurrentWeightedScore = [math]::Round($recordedCurrentAggregate, 1)
        TargetWeightedScore = [math]::Round($recordedTargetAggregate, 1)
        KnowledgeCurrentMaturity = [double]$domainByName["Knowledge, Memory & Context Compression"].current_maturity
        KnowledgeTargetMaturity = [double]$domainByName["Knowledge, Memory & Context Compression"].target_maturity
        AgentCurrentMaturity = [double]$domainByName["Agent Workforce & RACI"].current_maturity
        AgentTargetMaturity = [double]$domainByName["Agent Workforce & RACI"].target_maturity
        TargetsIncludedInCurrent = [bool]$weightedAggregate.targets_included
        TargetAggregateAchieved = [bool]$targetAggregate.achieved
        NonClaims = $nonClaims
    }
}

function Test-R16KpiBaselineTargetScorecard {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScorecardPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $scorecard = Read-SingleJsonObject -Path $ScorecardPath -Label "R16 KPI baseline target scorecard"
    return Test-R16KpiBaselineTargetScorecardObject -Scorecard $scorecard -SourceLabel $ScorecardPath -RepositoryRoot $RepositoryRoot
}

Export-ModuleMember -Function Test-R16KpiBaselineTargetScorecard, Test-R16KpiBaselineTargetScorecardObject
