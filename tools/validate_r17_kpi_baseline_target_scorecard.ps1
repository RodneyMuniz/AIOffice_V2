[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScorecardPath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$expectedDomains = [ordered]@{
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

$requiredTopLevelFields = @(
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
    "planning_artifact_refs",
    "scorecard_mode",
    "current_posture",
    "priority_domains",
    "domain_scores",
    "weighted_aggregate",
    "target_aggregate",
    "target_posture_requirements",
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

$requiredFalseCurrentPostureFields = @(
    "r17_004_or_later_implementation_claimed",
    "r17_029_or_later_task_exists",
    "live_a2a_runtime_implemented",
    "kanban_product_runtime_implemented",
    "developer_codex_executor_adapter_runtime_implemented",
    "qa_test_agent_adapter_runtime_implemented",
    "evidence_auditor_api_runtime_implemented",
    "four_a2a_cycles_exercised",
    "product_runtime_implemented",
    "production_runtime_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "solved_codex_compaction",
    "solved_codex_reliability",
    "main_merge_completed",
    "external_audit_acceptance_claimed"
)

$requiredTargetRequirementFields = @(
    "visible_board_card_lifecycle_required",
    "orchestrator_controlled_card_creation_and_routing_required",
    "developer_codex_executor_adapter_required",
    "qa_test_agent_adapter_required",
    "evidence_auditor_api_adapter_required",
    "tool_call_ledger_required",
    "agent_invocation_log_required",
    "stop_retry_reentry_controls_required",
    "four_exercised_a2a_cycles_required",
    "zero_manual_gpt_to_codex_prompt_transfer_happy_path_by_closeout_required"
)

$requiredPriorityDomains = @(
    "Product Experience & Double-Diamond Workflow",
    "Board & Work Orchestration",
    "Agent Workforce & RACI",
    "Knowledge, Memory & Context Compression",
    "Execution Harness & QA",
    "Architecture & Integrations",
    "Security, Safety & Cost Controls"
)

$requiredNonClaims = @(
    "no external audit acceptance",
    "no main merge",
    "no R13 closure",
    "no R14 caveat removal",
    "no R15 caveat removal",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "no product runtime yet",
    "no production runtime",
    "no autonomous agents yet",
    "no A2A runtime yet",
    "no executable handoffs yet",
    "no executable transitions yet",
    "no Evidence Auditor API runtime yet",
    "no Dev/Codex executor adapter runtime yet",
    "no QA/Test Agent adapter runtime yet",
    "no Kanban product runtime yet",
    "KPI targets are not achieved scores"
)

function Test-Property {
    param($Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    param($Object, [string]$Name, [string]$Context)
    if (-not (Test-Property -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Assert-NonEmptyString {
    param($Value, [string]$Context)
    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }
}

function Assert-Boolean {
    param($Value, [string]$Context)
    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }
}

function Assert-Number {
    param($Value, [string]$Context)
    if ($Value -isnot [byte] -and $Value -isnot [int] -and $Value -isnot [long] -and $Value -isnot [decimal] -and $Value -isnot [double] -and $Value -isnot [single]) {
        throw "$Context must be numeric."
    }
    return [double]$Value
}

function Assert-Array {
    param($Value, [string]$Context)
    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }
    return @($Value)
}

function Assert-PathExists {
    param([string]$Path, [string]$Context)
    Assert-NonEmptyString -Value $Path -Context $Context
    if ($Path -match '^\s*(\.|\.\\|\./|\*|\*\*|/|\\|repo|repository|full_repo|entire_repo)\s*$') {
        throw "$Context path '$Path' is unbounded."
    }
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        [System.IO.Path]::GetFullPath($Path)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }
}

function Assert-ScoreFromMaturity {
    param([double]$Score, [double]$Maturity, [string]$Context)
    $expected = [math]::Round(($Maturity / 5.0) * 100.0, 2)
    if ([math]::Abs($Score - $expected) -gt 0.05) {
        throw "$Context must equal maturity/5*100. Expected $expected, got $Score."
    }
}

function Assert-StringSetContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)
    foreach ($required in $Required) {
        if ($Values -notcontains $required) {
            throw "$Context must include '$required'."
        }
    }
}

function Assert-ExactStringSet {
    param([string[]]$Values, [string[]]$Expected, [string]$Context)
    $missing = @($Expected | Where-Object { $Values -notcontains $_ })
    $extra = @($Values | Where-Object { $Expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }
}

try {
    $resolvedScorecardPath = if ([System.IO.Path]::IsPathRooted($ScorecardPath)) {
        [System.IO.Path]::GetFullPath($ScorecardPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $ScorecardPath))
    }
    if (-not (Test-Path -LiteralPath $resolvedScorecardPath -PathType Leaf)) {
        throw "Scorecard path '$ScorecardPath' does not exist."
    }

    $scorecard = Get-Content -LiteralPath $resolvedScorecardPath -Raw | ConvertFrom-Json

    foreach ($field in $requiredTopLevelFields) {
        Get-RequiredProperty -Object $scorecard -Name $field -Context "R17 KPI scorecard" | Out-Null
    }

    if ($scorecard.artifact_type -ne "r17_kpi_baseline_target_scorecard") {
        throw "R17 KPI scorecard artifact_type must be r17_kpi_baseline_target_scorecard."
    }
    if ($scorecard.contract_version -ne "v1") {
        throw "R17 KPI scorecard contract_version must be v1."
    }
    if ($scorecard.source_milestone -ne "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle") {
        throw "R17 KPI scorecard source_milestone is incorrect."
    }
    if ($scorecard.source_task -ne "R17-003") {
        throw "R17 KPI scorecard source_task must be R17-003."
    }
    if ($scorecard.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "R17 KPI scorecard repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($scorecard.branch -ne "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle") {
        throw "R17 KPI scorecard branch is incorrect."
    }
    if ($scorecard.generated_from_head -ne "5bae17229ea10dee4ce072b258f828220b9d1d8d") {
        throw "R17 KPI scorecard generated_from_head must be the final R16 head."
    }
    if ($scorecard.generated_from_tree -ne "9de1a7b733f400da78f8e683ae4111977c70f1fb") {
        throw "R17 KPI scorecard generated_from_tree must be the final R16 tree."
    }
    if ($scorecard.scorecard_mode -ne "baseline_and_target_not_achievement") {
        throw "R17 KPI scorecard must separate baseline/current achieved scoring from targets."
    }

    Assert-PathExists -Path $scorecard.scoring_model_ref.path -Context "scoring_model_ref"
    Assert-PathExists -Path $scorecard.reporting_standard_ref.path -Context "reporting_standard_ref"
    foreach ($planningRef in (Assert-Array -Value $scorecard.planning_artifact_refs -Context "planning_artifact_refs")) {
        Assert-PathExists -Path $planningRef.path -Context "planning_artifact_refs"
        if ($planningRef.proof_by_itself -ne $false) {
            throw "planning_artifact_refs proof_by_itself must be false."
        }
    }

    $currentPosture = $scorecard.current_posture
    if ($currentPosture.active_through_task -ne "R17-003") {
        throw "current_posture active_through_task must be R17-003."
    }
    Assert-ExactStringSet -Values ([string[]](Assert-Array -Value $currentPosture.complete_tasks -Context "complete_tasks")) -Expected @("R17-001", "R17-002", "R17-003") -Context "complete_tasks"
    $expectedPlanned = @(4..28 | ForEach-Object { "R17-{0}" -f $_.ToString("000") })
    Assert-ExactStringSet -Values ([string[]](Assert-Array -Value $currentPosture.planned_tasks -Context "planned_tasks")) -Expected $expectedPlanned -Context "planned_tasks"
    foreach ($field in $requiredFalseCurrentPostureFields) {
        $value = Get-RequiredProperty -Object $currentPosture -Name $field -Context "current_posture"
        Assert-Boolean -Value $value -Context "current_posture $field"
        if ($value -ne $false) {
            throw "current_posture $field must be False."
        }
    }

    $targetRequirements = $scorecard.target_posture_requirements
    foreach ($field in $requiredTargetRequirementFields) {
        $value = Get-RequiredProperty -Object $targetRequirements -Name $field -Context "target_posture_requirements"
        Assert-Boolean -Value $value -Context "target_posture_requirements $field"
        if ($value -ne $true) {
            throw "target_posture_requirements $field must be True."
        }
    }

    $domainScores = Assert-Array -Value $scorecard.domain_scores -Context "domain_scores"
    if ($domainScores.Count -ne 10) {
        throw "domain_scores must include exactly 10 domains."
    }
    $domainNames = @($domainScores | ForEach-Object { [string]$_.domain })
    Assert-ExactStringSet -Values $domainNames -Expected ([string[]]$expectedDomains.Keys) -Context "domain_scores domains"

    $weightSum = 0.0
    $currentAggregate = 0.0
    $targetAggregate = 0.0
    foreach ($domainScore in $domainScores) {
        Assert-NonEmptyString -Value $domainScore.domain -Context "domain"
        $domainName = [string]$domainScore.domain
        $weight = Assert-Number -Value $domainScore.weight -Context "$domainName weight"
        if ($weight -ne [double]$expectedDomains[$domainName]) {
            throw "$domainName weight must be $($expectedDomains[$domainName])."
        }
        $weightSum += $weight

        $currentMaturity = Assert-Number -Value $domainScore.current_maturity -Context "$domainName current_maturity"
        $targetMaturity = Assert-Number -Value $domainScore.target_maturity -Context "$domainName target_maturity"
        if ($currentMaturity -lt 0 -or $currentMaturity -gt 5 -or $targetMaturity -lt 0 -or $targetMaturity -gt 5) {
            throw "$domainName maturity values must be within 0..5."
        }
        $currentScore = Assert-Number -Value $domainScore.current_score -Context "$domainName current_score"
        $targetScore = Assert-Number -Value $domainScore.target_score -Context "$domainName target_score"
        Assert-ScoreFromMaturity -Score $currentScore -Maturity $currentMaturity -Context "$domainName current_score"
        Assert-ScoreFromMaturity -Score $targetScore -Maturity $targetMaturity -Context "$domainName target_score"
        $evidenceCap = Assert-Number -Value $domainScore.evidence_cap -Context "$domainName evidence_cap"
        if ($currentScore -gt $evidenceCap) {
            throw "$domainName current_score above evidence cap."
        }
        if ($domainScore.target_is_achievement -ne $false) {
            throw "$domainName target_is_achievement must be False."
        }
        if ($domainScore.target_treated_as_evidence -ne $false) {
            throw "$domainName target_treated_as_evidence must be False."
        }
        if (@("A", "B", "C", "D", "E") -notcontains $domainScore.evidence_confidence) {
            throw "$domainName evidence_confidence has unsupported confidence level."
        }
        foreach ($evidenceRef in (Assert-Array -Value $domainScore.evidence_refs -Context "$domainName evidence_refs")) {
            Assert-PathExists -Path ([string]$evidenceRef) -Context "$domainName evidence_refs"
        }
        if ((Assert-Array -Value $domainScore.required_r17_closeout_evidence -Context "$domainName required_r17_closeout_evidence").Count -eq 0) {
            throw "$domainName required_r17_closeout_evidence must not be empty."
        }
        $currentAggregate += ($currentScore * $weight / 100.0)
        $targetAggregate += ($targetScore * $weight / 100.0)
    }

    if ([math]::Abs($weightSum - 100.0) -gt 0.001) {
        throw "domain weights must sum to 100."
    }

    $priorityDomains = @((Assert-Array -Value $scorecard.priority_domains -Context "priority_domains") | ForEach-Object { [string]$_.domain })
    Assert-StringSetContains -Values $priorityDomains -Required $requiredPriorityDomains -Context "priority_domains"

    if ($scorecard.weighted_aggregate.mode -ne "current_achieved_baseline_only" -or $scorecard.weighted_aggregate.targets_included -ne $false) {
        throw "weighted_aggregate must be current achieved baseline only and exclude targets."
    }
    if ([math]::Abs(([double]$scorecard.weighted_aggregate.score) - [math]::Round($currentAggregate, 1)) -gt 0.05) {
        throw "weighted_aggregate score does not match domain weighted current score."
    }
    if ($scorecard.target_aggregate.mode -ne "target_by_r17_closeout_not_achieved" -or $scorecard.target_aggregate.achieved -ne $false -or $scorecard.target_aggregate.requires_future_evidence -ne $true) {
        throw "target_aggregate must be an unachieved future target requiring future evidence."
    }
    if ([math]::Abs(([double]$scorecard.target_aggregate.score) - [math]::Round($targetAggregate, 1)) -gt 0.05) {
        throw "target_aggregate score does not match domain weighted target score."
    }

    foreach ($field in @("target_scores_are_achieved_scores", "target_scores_are_current_evidence", "target_scores_close_r17")) {
        if ((Get-RequiredProperty -Object $scorecard.target_not_achievement_disclaimer -Name $field -Context "target_not_achievement_disclaimer") -ne $false) {
            throw "target_not_achievement_disclaimer $field must be False."
        }
    }
    if ($scorecard.target_not_achievement_disclaimer.target_scores_require_future_evidence -ne $true) {
        throw "target_not_achievement_disclaimer target_scores_require_future_evidence must be True."
    }

    if ($scorecard.preserved_boundaries.r13.closed -ne $false) {
        throw "preserved_boundaries r13 closed must be False."
    }
    if ($scorecard.preserved_boundaries.r14.caveats_removed -ne $false) {
        throw "preserved_boundaries r14 caveats_removed must be False."
    }
    if ($scorecard.preserved_boundaries.r15.caveats_removed -ne $false) {
        throw "preserved_boundaries r15 caveats_removed must be False."
    }
    foreach ($field in @("external_audit_acceptance_claimed", "main_merge_completed", "product_runtime_implemented", "a2a_runtime_implemented", "autonomous_agents_implemented", "solved_codex_compaction", "solved_codex_reliability")) {
        if ((Get-RequiredProperty -Object $scorecard.preserved_boundaries.r16 -Name $field -Context "preserved_boundaries r16") -ne $false) {
            throw "preserved_boundaries r16 $field must be False."
        }
    }

    Assert-StringSetContains -Values ([string[]](Assert-Array -Value $scorecard.non_claims -Context "non_claims")) -Required $requiredNonClaims -Context "non_claims"

    Write-Output ("VALID: R17 KPI baseline target scorecard '{0}' passed with {1} domains, weight sum {2}, current weighted score {3}, target weighted score {4}, active_through={5}, planned_range={6}..{7}; targets are not achieved scores." -f $scorecard.scorecard_id, $domainScores.Count, [math]::Round($weightSum, 1), [math]::Round([double]$scorecard.weighted_aggregate.score, 1), [math]::Round([double]$scorecard.target_aggregate.score, 1), $currentPosture.active_through_task, $currentPosture.planned_tasks[0], $currentPosture.planned_tasks[-1])
    exit 0
}
catch {
    Write-Output ("INVALID: R17 KPI baseline target scorecard failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
