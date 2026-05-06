$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16KpiBaselineTargetScorecard.psm1") -Force -PassThru
$testScorecard = $module.ExportedCommands["Test-R16KpiBaselineTargetScorecard"]

$statusModule = Import-Module (Join-Path $repoRoot "tools\StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $statusModule.ExportedCommands["Test-StatusDocGate"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\governance\r16_kpi_baseline_target_scorecard.valid.json"
$stateScorecard = Join-Path $repoRoot "state\governance\r16_kpi_baseline_target_scorecard.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\governance\r16_kpi_baseline_target_scorecard"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

try {
    $validResult = & $testScorecard -ScorecardPath $validFixture -RepositoryRoot $repoRoot
    if ($validResult.DomainCount -ne 10 -or $validResult.WeightSum -ne 100 -or $validResult.ActiveThroughTask -ne "R16-003" -or $validResult.PlannedTaskStart -ne "R16-004" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected 10 domains, 100 weight sum, and R16 active through R16-003 with R16-004 through R16-026 planned only."
    }
    elseif ($validResult.TargetsIncludedInCurrent -or $validResult.TargetAggregateAchieved) {
        $failures += "FAIL valid fixture: target scores were treated as achieved/current scoring."
    }
    elseif (($validResult.KnowledgeTargetMaturity - $validResult.KnowledgeCurrentMaturity) -lt 1.5 -or ($validResult.AgentTargetMaturity - $validResult.AgentCurrentMaturity) -lt 1.5) {
        $failures += "FAIL valid fixture: expected explicit priority maturity jumps for Knowledge/Memory and Agent/RACI."
    }
    else {
        Write-Output ("PASS valid fixture: current={0}; target={1}" -f $validResult.CurrentWeightedScore, $validResult.TargetWeightedScore)
        $validPassed += 1
    }

    $stateResult = & $testScorecard -ScorecardPath $stateScorecard -RepositoryRoot $repoRoot
    if ($stateResult.DomainCount -ne 10 -or $stateResult.WeightSum -ne 100 -or $stateResult.ActiveThroughTask -ne "R16-003" -or $stateResult.PlannedTaskStart -ne "R16-004" -or $stateResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed scorecard: expected 10 domains, 100 weight sum, and R16 active through R16-003 with R16-004 through R16-026 planned only."
    }
    elseif ($stateResult.TargetsIncludedInCurrent -or $stateResult.TargetAggregateAchieved) {
        $failures += "FAIL committed scorecard: target scores were treated as achieved/current scoring."
    }
    elseif (($stateResult.KnowledgeTargetMaturity - $stateResult.KnowledgeCurrentMaturity) -lt 1.5 -or ($stateResult.AgentTargetMaturity - $stateResult.AgentCurrentMaturity) -lt 1.5) {
        $failures += "FAIL committed scorecard: expected explicit priority maturity jumps for Knowledge/Memory and Agent/RACI."
    }
    else {
        Write-Output ("PASS committed R16-003 scorecard: current={0}; target={1}" -f $stateResult.CurrentWeightedScore, $stateResult.TargetWeightedScore)
        $validPassed += 1
    }

    if ($stateResult.CurrentWeightedScore -ge $stateResult.TargetWeightedScore) {
        $failures += "FAIL aggregate separation: current weighted score must remain below the target weighted score."
    }
    else {
        Write-Output "PASS aggregate separation: current weighted score is baseline/current achieved only; target score is future ambition."
        $validPassed += 1
    }

    if ($stateResult.NonClaims -notcontains "no R16-004 implementation" -or $stateResult.NonClaims -notcontains "no memory layers implemented yet" -or $stateResult.NonClaims -notcontains "no artifact maps implemented yet" -or $stateResult.NonClaims -notcontains "KPI targets are not achieved scores") {
        $failures += "FAIL non-claims: expected no R16-004, no memory layers, no artifact maps, and target-not-achievement non-claims."
    }
    else {
        Write-Output "PASS non-claims: no future R16 task or target-as-achieved claim is present."
        $validPassed += 1
    }

    $status = & $testStatusDocGate -RepositoryRoot $repoRoot
    if (-not $status.R16Opened -or $status.R16DoneThrough -ne 16 -or $status.R16PlannedStart -ne 17 -or $status.R16PlannedThrough -ne 26) {
        $failures += "FAIL status posture: expected R16 active through R16-016 only with R16-017 through R16-026 planned only."
    }
    else {
        Write-Output "PASS status posture: R16 active through R16-016 only; R16-017 through R16-026 remain planned only."
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "missing-kpi-domain.invalid.json" = @("domain_scores", "domains")
        "extra-kpi-domain.invalid.json" = @("domain_scores", "domains")
        "wrong-domain-weight-sum.invalid.json" = @("weight")
        "maturity-above-5.invalid.json" = @("current_maturity")
        "invalid-confidence-level.invalid.json" = @("unsupported confidence level")
        "achieved-score-above-evidence-cap.invalid.json" = @("current_score above evidence cap")
        "target-score-treated-as-achieved.invalid.json" = @("target_is_achievement")
        "knowledge-memory-target-uplift-missing.invalid.json" = @("Knowledge, Memory & Context Compression", "target uplift")
        "agent-raci-target-uplift-missing.invalid.json" = @("Agent Workforce & RACI", "target uplift")
        "r16-004-implementation-claimed.invalid.json" = @("r16_004_or_later_implementation_claimed", "False")
        "memory-layer-implemented-claimed.invalid.json" = @("memory_layers_implemented", "False")
        "artifact-map-implemented-claimed.invalid.json" = @("artifact_maps_implemented", "False")
        "role-run-envelope-implemented-claimed.invalid.json" = @("role_run_envelopes_implemented", "False")
        "product-runtime-claimed.invalid.json" = @("product_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-vector-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "r13-closure-claimed.invalid.json" = @("preserved_boundaries r13 closed", "False")
        "r14-caveat-removed.invalid.json" = @("preserved_boundaries r14 caveats_removed", "False")
        "r15-caveat-removed.invalid.json" = @("preserved_boundaries r15 caveats_removed", "False")
        "r16-027-task-introduced.invalid.json" = @("r16_027_or_later_task_exists", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $path = Join-Path $invalidRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            & $testScorecard -ScorecardPath $path -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $invalidRoot -Filter "*.invalid.json" | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }
}
catch {
    $failures += ("FAIL R16 KPI baseline target scorecard harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 KPI baseline target scorecard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 KPI baseline target scorecard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
