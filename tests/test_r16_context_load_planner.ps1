$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16ContextLoadPlanner.psm1") -Force -PassThru
$newObject = $module.ExportedCommands["New-R16ContextLoadPlanObject"]
$newPlan = $module.ExportedCommands["New-R16ContextLoadPlan"]
$testPlan = $module.ExportedCommands["Test-R16ContextLoadPlan"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16ContextLoadPlannerFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_context_load_planner"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$tempRootRel = Join-Path "state\context" ("r16contextloadplanner" + [guid]::NewGuid().ToString("N"))
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
        "tools\R16ContextLoadPlanner.psm1",
        "tools\new_r16_context_load_plan.ps1",
        "tools\validate_r16_context_load_plan.ps1",
        "tests\test_r16_context_load_planner.ps1",
        "state\context\r16_context_load_plan.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_015_context_load_planner\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_015_context_load_planner\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_015_context_load_planner\validation_manifest.md"
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
        "tools\R16RaciTransitionGate.psm1",
        "tools\R16HandoffPacketGenerator.psm1"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-020+ overbuild artifact exists: $forbiddenPath"
        }
    }

    $first = & $newObject -RepositoryRoot $repoRoot
    $second = & $newObject -RepositoryRoot $repoRoot
    $firstJson = & $stableJson -Object $first
    $secondJson = & $stableJson -Object $second
    if ($firstJson -ne $secondJson) {
        $failures += "FAIL determinism: two generated R16-015 context-load plans differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-015 context-load plan normalized output is stable across two generations."
        $validPassed += 1
    }

    $tempPlanRel = Join-Path $tempRootRel "r16_context_load_plan.json"
    $generated = & $newPlan -OutputPath $tempPlanRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-015" -or $generated.PlannedTaskStart -ne "R16-016" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL generated plan: expected active through R16-015 only, R16-016 through R16-026 planned only, and passed_with_caveats."
    }
    else {
        Write-Output ("PASS generated plan: load_groups={0}, load_items={1}" -f $generated.LoadGroupCount, $generated.LoadItemCount)
        $validPassed += 1
    }

    $generatedValidation = & $testPlan -Path $tempPlanRel -RepositoryRoot $repoRoot
    if ($generatedValidation.ContextBudgetEstimatorImplemented -or $generatedValidation.OverBudgetFailClosedValidatorImplemented -or $generatedValidation.RoleRunEnvelopeImplemented -or $generatedValidation.WorkflowDrillRun) {
        $failures += "FAIL generated validation: expected no context budget estimator, over-budget validator, role-run envelope, or workflow drill."
    }
    else {
        Write-Output ("PASS generated validation: {0}" -f (Join-Path $repoRoot $tempPlanRel))
        $validPassed += 1
    }

    $stateValidation = & $testPlan -Path "state\context\r16_context_load_plan.json" -RepositoryRoot $repoRoot
    if ($stateValidation.ActiveThroughTask -ne "R16-015" -or $stateValidation.PlannedTaskStart -ne "R16-016" -or $stateValidation.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed state plan: expected R16 active through R16-015 only and R16-016 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS committed state plan: {0}" -f (Join-Path $repoRoot "state\context\r16_context_load_plan.json"))
        $validPassed += 1
    }

    $validFixtureRel = Join-Path $fixtureRootRel "valid_context_load_plan.json"
    $validFixtureResult = & $testPlan -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ActiveThroughTask -ne "R16-015" -or $validFixtureResult.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL valid fixture: expected active_through_task R16-015 and passed_with_caveats."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_role_memory_pack_ref.json" = @("role_memory_pack_ref", "loaded and validated")
        "invalid_missing_artifact_map_ref.json" = @("artifact_map_ref", "loaded and validated")
        "invalid_missing_audit_map_ref.json" = @("audit_map_ref", "loaded and validated")
        "invalid_missing_check_report_ref.json" = @("check_report_ref", "loaded and validated")
        "invalid_missing_load_item_path.json" = @("missing required field 'path'")
        "invalid_wildcard_path.json" = @("wildcard path")
        "invalid_broad_scan_claim.json" = @("broad_repo_scan_allowed", "False")
        "invalid_directory_only_ref.json" = @("directory-only ref")
        "invalid_local_scratch_ref.json" = @("local scratch ref")
        "invalid_remote_unverified_ref.json" = @("remote", "non-repo path")
        "invalid_report_as_machine_proof.json" = @("generated_reports_as_machine_proof_allowed", "False")
        "invalid_runtime_memory_claim.json" = @("runtime_memory_implemented", "False")
        "invalid_retrieval_runtime_claim.json" = @("retrieval_runtime_implemented", "False")
        "invalid_vector_search_claim.json" = @("vector_search_runtime_implemented", "False")
        "invalid_context_budget_estimator_claim.json" = @("context_budget_estimator_implemented", "False")
        "invalid_exact_token_count_claim.json" = @("exact_provider_token_count_claimed", "False")
        "invalid_over_budget_validator_claim.json" = @("over_budget_fail_closed_validator_implemented", "False")
        "invalid_role_run_envelope_claim.json" = @("role_run_envelope_implemented", "False")
        "invalid_raci_transition_gate_claim.json" = @("raci_transition_gate_implemented", "False")
        "invalid_handoff_packet_claim.json" = @("handoff_packet_implemented", "False")
        "invalid_workflow_drill_claim.json" = @("workflow_drill_run", "False")
        "invalid_r16_016_claim.json" = @("r16_016_or_later_implementation_claimed", "False")
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
            & $testPlan -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 context-load planner harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 context-load planner tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 context-load planner tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
