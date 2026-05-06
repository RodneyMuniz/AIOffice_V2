$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16ContextBudgetGuard.psm1") -Force -PassThru
$newReportObject = $module.ExportedCommands["New-R16ContextBudgetGuardReportObject"]
$newReport = $module.ExportedCommands["New-R16ContextBudgetGuardReport"]
$testReport = $module.ExportedCommands["Test-R16ContextBudgetGuardReport"]
$testReportObject = $module.ExportedCommands["Test-R16ContextBudgetGuardReportObject"]
$testContract = $module.ExportedCommands["Test-R16ContextBudgetGuardContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16ContextBudgetGuardFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_context_budget_guard"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$tempRootRel = Join-Path "state\context" ("r16contextbudgetguard" + [guid]::NewGuid().ToString("N"))
$tempRoot = Join-Path $repoRoot $tempRootRel

function Read-FixtureScenario {
    param([Parameter(Mandatory = $true)][string]$Name)

    $path = Join-Path $fixtureRoot $Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Expected fixture missing: $Name"
    }

    return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
}

function Invoke-GuardScenario {
    param([Parameter(Mandatory = $true)]$Scenario)

    return & $newReportObject -ContextLoadPlanPath ("tests/fixtures/r16_context_budget_guard/{0}.plan.json" -f $Scenario.fixture_id) -ContextBudgetEstimatePath ("tests/fixtures/r16_context_budget_guard/{0}.estimate.json" -f $Scenario.fixture_id) -ContextLoadPlanObject $Scenario.plan -ContextBudgetEstimateObject $Scenario.estimate -MaxEstimatedTokensUpperBound ([int64]$Scenario.configured_budget_thresholds.max_estimated_tokens_upper_bound) -RepositoryRoot $repoRoot
}

function Assert-FindingFragment {
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)][string]$Fragment,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $findingText = (($Report.validation_findings | ConvertTo-Json -Depth 20) -join "`n")
    if ($findingText -notlike ("*{0}*" -f $Fragment)) {
        $script:failures += ("FAIL fixture: {0} did not include expected finding fragment '{1}'. Findings: {2}" -f $Label, $Fragment, $findingText)
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    & $newFixtures -RepositoryRoot $repoRoot | Out-Null

    foreach ($requiredPath in @(
        "contracts\context\r16_context_budget_guard.contract.json",
        "tools\R16ContextBudgetGuard.psm1",
        "tools\test_r16_context_budget_guard.ps1",
        "tools\validate_r16_context_budget_guard_report.ps1",
        "tests\test_r16_context_budget_guard.ps1",
        "state\context\r16_context_budget_guard_report.json",
        "tests\fixtures\r16_context_budget_guard\valid_bounded_under_budget.fixture.json",
        "tests\fixtures\r16_context_budget_guard\current_over_budget_estimate.fixture.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_017_context_budget_guard\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_017_context_budget_guard\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_017_context_budget_guard\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "contracts\workflow\r16_handoff_packet.contract.json",
        "contracts\workflow\r16_raci_transition_gate.contract.json",
        "state\workflow\r16_handoff_packets.json",
        "state\memory\r16_runtime_memory.json",
        "state\retrieval\r16_vector_index.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-021+ or non-report workflow overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.ActiveThroughTask -ne "R16-017" -or $contractResult.PlannedTaskStart -ne "R16-018" -or $contractResult.PlannedTaskEnd -ne "R16-026" -or $contractResult.MaxEstimatedTokensUpperBound -ne 150000) {
        $failures += "FAIL contract: expected R16 active through R16-017 only with R16-018 through R16-026 planned only and max threshold 150000."
    }
    else {
        Write-Output ("PASS contract: dependency_refs={0}, threshold={1}" -f $contractResult.DependencyRefCount, $contractResult.MaxEstimatedTokensUpperBound)
        $validPassed += 1
    }

    $first = & $newReportObject -RepositoryRoot $repoRoot
    $second = & $newReportObject -RepositoryRoot $repoRoot
    if ((& $stableJson -Object $first) -ne (& $stableJson -Object $second)) {
        $failures += "FAIL determinism: two generated guard report objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-017 context budget guard report object is stable across two generations."
        $validPassed += 1
    }

    $tempReportRel = Join-Path $tempRootRel "r16_context_budget_guard_report.json"
    $generated = & $newReport -OutputPath $tempReportRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-017" -or $generated.PlannedTaskStart -ne "R16-018" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "failed_closed_over_budget" -or -not $generated.ThresholdExceeded) {
        $failures += "FAIL generated report: expected active through R16-017, R16-018 through R16-026 planned only, and failed_closed_over_budget."
    }
    else {
        Write-Output ("PASS generated report: approximate_upper_bound={0}, threshold={1}, verdict={2}" -f $generated.EstimatedTokensUpperBound, $generated.MaxEstimatedTokensUpperBound, $generated.AggregateVerdict)
        $validPassed += 1
    }

    $stateValidation = & $testReport -Path "state\context\r16_context_budget_guard_report.json" -RepositoryRoot $repoRoot
    if ($stateValidation.ActiveThroughTask -ne "R16-017" -or $stateValidation.PlannedTaskStart -ne "R16-018" -or $stateValidation.PlannedTaskEnd -ne "R16-026" -or $stateValidation.AggregateVerdict -ne "failed_closed_over_budget" -or $stateValidation.EstimatedTokensUpperBound -ne $generated.EstimatedTokensUpperBound -or $stateValidation.MaxEstimatedTokensUpperBound -ne $generated.MaxEstimatedTokensUpperBound) {
        $failures += ("FAIL committed state guard report: expected failed_closed_over_budget for current approximate upper bound {0} over threshold {1}." -f $generated.EstimatedTokensUpperBound, $generated.MaxEstimatedTokensUpperBound)
    }
    else {
        Write-Output ("PASS committed state guard report: approximate_upper_bound={0}, threshold={1}, verdict={2}" -f $stateValidation.EstimatedTokensUpperBound, $stateValidation.MaxEstimatedTokensUpperBound, $stateValidation.AggregateVerdict)
        $validPassed += 1
    }

    $validScenario = Read-FixtureScenario -Name "valid_bounded_under_budget.fixture.json"
    $validReport = Invoke-GuardScenario -Scenario $validScenario
    & $testReportObject -Report $validReport -RepositoryRoot $repoRoot | Out-Null
    if ($validReport.aggregate_verdict -ne "passed_guard") {
        $failures += "FAIL valid bounded under-budget fixture: expected passed_guard."
    }
    else {
        Write-Output "PASS valid fixture: valid_bounded_under_budget passed under the configured threshold."
        $validPassed += 1
    }

    $currentScenario = Read-FixtureScenario -Name "current_over_budget_estimate.fixture.json"
    $currentReport = Invoke-GuardScenario -Scenario $currentScenario
    & $testReportObject -Report $currentReport -RepositoryRoot $repoRoot | Out-Null
    if ($currentReport.aggregate_verdict -ne "failed_closed_over_budget") {
        $failures += "FAIL current over-budget fixture: expected failed_closed_over_budget."
    }
    else {
        Assert-FindingFragment -Report $currentReport -Fragment "exceeds configured threshold" -Label "current_over_budget_estimate"
        Write-Output "PASS over-budget fixture: current R16-016 estimate fails closed over threshold."
        $invalidRejected += 1
    }

    $expectedInvalidFixtures = [ordered]@{
        "invalid_wildcard_path.fixture.json" = "wildcard_path"
        "invalid_directory_only_path.fixture.json" = "directory_only_path"
        "invalid_broad_repo_scan_claim.fixture.json" = "broad/full repo scan claim"
        "invalid_full_repo_scan_claim.fixture.json" = "broad/full repo scan claim"
        "invalid_scratch_temp_path.fixture.json" = "scratch_temp_path"
        "invalid_absolute_path.fixture.json" = "absolute_path"
        "invalid_parent_traversal_path.fixture.json" = "parent_traversal_path"
        "invalid_url_remote_ref.fixture.json" = "url_or_remote_ref"
        "invalid_exact_provider_token_claim.fixture.json" = "exact provider token count"
        "invalid_exact_provider_billing_claim.fixture.json" = "exact provider billing"
        "invalid_runtime_memory_claim.fixture.json" = "runtime memory claim"
        "invalid_retrieval_runtime_claim.fixture.json" = "retrieval runtime claim"
        "invalid_vector_search_claim.fixture.json" = "vector search runtime claim"
        "invalid_role_run_envelope_claim.fixture.json" = "role-run envelope claim"
        "invalid_raci_transition_gate_claim.fixture.json" = "RACI transition gate claim"
        "invalid_handoff_packet_claim.fixture.json" = "handoff packet claim"
        "invalid_workflow_drill_claim.fixture.json" = "workflow drill claim"
        "invalid_r16_018_implementation_claim.fixture.json" = "R16-018 or later implementation"
        "invalid_r13_boundary_change.fixture.json" = "R13 failed/partial boundary"
        "invalid_r14_caveat_removal.fixture.json" = "R14 caveat boundary"
        "invalid_r15_caveat_removal.fixture.json" = "R15 caveat boundary"
    }

    foreach ($fixtureName in $expectedInvalidFixtures.Keys) {
        try {
            $scenario = Read-FixtureScenario -Name $fixtureName
            $report = Invoke-GuardScenario -Scenario $scenario
            & $testReportObject -Report $report -RepositoryRoot $repoRoot | Out-Null
            if ($report.aggregate_verdict -eq "passed_guard") {
                $failures += ("FAIL invalid fixture: {0} passed unexpectedly." -f $fixtureName)
                continue
            }
            Assert-FindingFragment -Report $report -Fragment $expectedInvalidFixtures[$fixtureName] -Label $fixtureName
            Write-Output ("PASS invalid fixture: {0} -> {1}" -f $fixtureName, $report.aggregate_verdict)
            $invalidRejected += 1
        }
        catch {
            $failures += ("FAIL invalid fixture: {0} threw unexpectedly. {1}" -f $fixtureName, $_.Exception.Message)
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.fixture.json" | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFixtures.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid fixture inventory: unexpected invalid fixtures exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }
}
catch {
    $failures += ("FAIL R16 context budget guard harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 context budget guard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 context budget guard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
