$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16ContextBudgetEstimator.psm1") -Force -PassThru
$newObject = $module.ExportedCommands["New-R16ContextBudgetEstimateObject"]
$newEstimate = $module.ExportedCommands["New-R16ContextBudgetEstimate"]
$testEstimate = $module.ExportedCommands["Test-R16ContextBudgetEstimate"]
$testContract = $module.ExportedCommands["Test-R16ContextBudgetEstimateContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16ContextBudgetEstimatorFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_context_budget_estimator"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$tempRootRel = Join-Path "state\context" ("r16contextbudgetestimator" + [guid]::NewGuid().ToString("N"))
$tempRoot = Join-Path $repoRoot $tempRootRel

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Action
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
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    & $newFixtures -RepositoryRoot $repoRoot | Out-Null

    foreach ($requiredPath in @(
        "contracts\context\r16_context_budget_estimate.contract.json",
        "tools\R16ContextBudgetEstimator.psm1",
        "tools\new_r16_context_budget_estimate.ps1",
        "tools\validate_r16_context_budget_estimate.ps1",
        "tests\test_r16_context_budget_estimator.ps1",
        "state\context\r16_context_budget_estimate.json",
        "tests\fixtures\r16_context_budget_estimator\valid_context_budget_estimate.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_016_context_budget_estimator\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_016_context_budget_estimator\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_016_context_budget_estimator\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "tools\R16OverBudgetFailClosedValidator.psm1",
        "contracts\workflow\r16_handoff_packet.contract.json",
        "contracts\workflow\r16_raci_transition_gate.contract.json",
        "state\workflow\r16_handoff_packets.json",
        "tools\R16HandoffPacketGenerator.psm1"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-021+ or non-report workflow overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.ActiveThroughTask -ne "R16-016" -or $contractResult.PlannedTaskStart -ne "R16-017" -or $contractResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL contract: expected R16 active through R16-016 only with R16-017 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS contract: dependency_refs={0}" -f $contractResult.DependencyRefCount)
        $validPassed += 1
    }

    $first = & $newObject -RepositoryRoot $repoRoot
    $second = & $newObject -RepositoryRoot $repoRoot
    $firstJson = & $stableJson -Object $first
    $secondJson = & $stableJson -Object $second
    if ($firstJson -ne $secondJson) {
        $failures += "FAIL determinism: two generated R16-016 context budget estimates differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-016 context budget estimate normalized output is stable across two generations."
        $validPassed += 1
    }

    $tempEstimateRel = Join-Path $tempRootRel "r16_context_budget_estimate.json"
    $generated = & $newEstimate -OutputPath $tempEstimateRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-016" -or $generated.PlannedTaskStart -ne "R16-017" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL generated estimate: expected active through R16-016 only, R16-017 through R16-026 planned only, and passed_with_caveats."
    }
    else {
        Write-Output ("PASS generated estimate: load_items={0}, exact_files={1}, approximate_tokens={2}..{3}" -f $generated.LoadItemCount, $generated.ExactFileCount, $generated.EstimatedTokensLowerBound, $generated.EstimatedTokensUpperBound)
        $validPassed += 1
    }

    $generatedValidation = & $testEstimate -Path $tempEstimateRel -RepositoryRoot $repoRoot
    if ($generatedValidation.ActiveThroughTask -ne "R16-016" -or $generatedValidation.PlannedTaskStart -ne "R16-017" -or $generatedValidation.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL generated validation: expected R16 active through R16-016 only and R16-017 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS generated validation: {0}" -f (Join-Path $repoRoot $tempEstimateRel))
        $validPassed += 1
    }

    $stateValidation = & $testEstimate -Path "state\context\r16_context_budget_estimate.json" -RepositoryRoot $repoRoot
    if ($stateValidation.ActiveThroughTask -ne "R16-016" -or $stateValidation.PlannedTaskStart -ne "R16-017" -or $stateValidation.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed state estimate: expected R16 active through R16-016 only and R16-017 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS committed state estimate: budget_category={0}" -f $stateValidation.BudgetCategory)
        $validPassed += 1
    }

    $validFixtureRel = Join-Path $fixtureRootRel "valid_context_budget_estimate.json"
    $validFixtureResult = & $testEstimate -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ActiveThroughTask -ne "R16-016" -or $validFixtureResult.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL valid fixture: expected active_through_task R16-016 and passed_with_caveats."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_context_load_plan_ref.json" = @("missing required field 'context_load_plan_ref'")
        "invalid_missing_load_item_path.json" = @("missing required field 'path'")
        "invalid_wildcard_path.json" = @("wildcard path")
        "invalid_broad_scan_claim.json" = @("broad_repo_scan_used", "False")
        "invalid_directory_only_ref.json" = @("directory-only ref")
        "invalid_local_scratch_ref.json" = @("local scratch ref")
        "invalid_remote_unverified_ref.json" = @("remote", "non-repo path")
        "invalid_exact_provider_token_claim.json" = @("exact_provider_token_count_claimed", "False")
        "invalid_exact_provider_billing_claim.json" = @("exact_provider_billing_claimed", "False")
        "invalid_over_budget_fail_closed_claim.json" = @("over_budget_fail_closed_validator_implemented", "False")
        "invalid_runtime_memory_claim.json" = @("runtime_memory_implemented", "False")
        "invalid_retrieval_runtime_claim.json" = @("retrieval_runtime_implemented", "False")
        "invalid_vector_search_claim.json" = @("vector_search_runtime_implemented", "False")
        "invalid_role_run_envelope_claim.json" = @("role_run_envelope_implemented", "False")
        "invalid_raci_transition_gate_claim.json" = @("raci_transition_gate_implemented", "False")
        "invalid_handoff_packet_claim.json" = @("handoff_packet_implemented", "False")
        "invalid_workflow_drill_claim.json" = @("workflow_drill_run", "False")
        "invalid_r16_017_claim.json" = @("r16_017_or_later_implementation_claimed", "False")
        "invalid_r13_boundary_change.json" = @("r13 closed", "False")
        "invalid_r14_caveat_removed.json" = @("r14 caveats_removed", "False")
        "invalid_r15_caveat_removed.json" = @("r15 caveats_removed", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $fixturePath = Join-Path $fixtureRoot $name
        if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            $relativePath = Join-Path $fixtureRootRel $name
            & $testEstimate -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }
}
catch {
    $failures += ("FAIL R16 context budget estimator harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 context budget estimator tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 context budget estimator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
