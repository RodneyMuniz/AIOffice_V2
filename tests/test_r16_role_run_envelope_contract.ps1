$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RoleRunEnvelopeContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16RoleRunEnvelopeContract"]

$contractRel = "contracts\workflow\r16_role_run_envelope.contract.json"
$fixtureRootRel = "tests\fixtures\r16_role_run_envelope_contract"
$validFixtureRel = Join-Path $fixtureRootRel "valid_role_run_envelope_contract.json"
$invalidRoot = Join-Path $repoRoot $fixtureRootRel

$validPassed = 0
$invalidRejected = 0
$failures = @()

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
    foreach ($requiredPath in @(
        $contractRel,
        "tools\R16RoleRunEnvelopeContract.psm1",
        "tools\validate_r16_role_run_envelope_contract.ps1",
        "tests\test_r16_role_run_envelope_contract.ps1",
        $validFixtureRel,
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_018_role_run_envelope_contract\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_018_role_run_envelope_contract\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_018_role_run_envelope_contract\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "state\workflow\r16_handoff_packets.json",
        "contracts\workflow\r16_handoff_packet.contract.json",
        "contracts\workflow\r16_raci_transition_gate.contract.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-021+ or non-report workflow overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -Path $contractRel -RepositoryRoot $repoRoot
    if ($contractResult.SourceTask -ne "R16-018" -or $contractResult.ActiveThroughTask -ne "R16-018" -or $contractResult.PlannedTaskStart -ne "R16-019" -or $contractResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed contract: expected R16-018 identity and R16 active through R16-018 only with R16-019 through R16-026 planned only."
    }
    elseif ($contractResult.RoleCount -lt 8 -or $contractResult.RequiredInputRefCount -lt 5 -or $contractResult.GuardVerdict -ne "failed_closed_over_budget" -or -not $contractResult.GuardBlocksExecution) {
        $failures += "FAIL committed contract: expected complete role catalog, required input refs, and failed_closed_over_budget as a block."
    }
    elseif ($contractResult.RaciTransitionGateExists -or $contractResult.HandoffPacketExists -or $contractResult.WorkflowDrillExists) {
        $failures += "FAIL committed contract: expected no RACI transition gate, no handoff packet, and no workflow drill."
    }
    elseif ($contractResult.R13Closed -or $contractResult.R14CaveatsRemoved -or $contractResult.R15CaveatsRemoved) {
        $failures += "FAIL committed contract: expected R13/R14/R15 boundaries to remain preserved."
    }
    else {
        Write-Output ("PASS committed contract: {0}" -f (Join-Path $repoRoot $contractRel))
        $validPassed += 1
    }

    $validFixtureResult = & $testContract -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.SourceTask -ne "R16-018" -or $validFixtureResult.RoleCount -lt 8 -or $validFixtureResult.GuardVerdict -ne "failed_closed_over_budget" -or $validFixtureResult.RaciTransitionGateExists -or $validFixtureResult.HandoffPacketExists -or $validFixtureResult.WorkflowDrillExists) {
        $failures += "FAIL valid fixture: expected R16-018 contract identity, complete role catalog, failed_closed_over_budget blocking, and no RACI transition gate, handoff packet, or workflow drill."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'role_catalog'")
        "invalid_role_id.json" = @("invalid role id")
        "invalid_missing_role_catalog_entry.json" = @("role_catalog", "qa")
        "invalid_missing_memory_pack_ref_requirement.json" = @("memory_pack_ref")
        "invalid_missing_context_load_plan_ref_requirement.json" = @("context_load_plan_ref")
        "invalid_missing_context_budget_guard_ref_requirement.json" = @("context_budget_guard_ref")
        "invalid_missing_budget_guard_status_requirement.json" = @("budget_guard_status")
        "invalid_executable_despite_failed_closed_over_budget_guard.json" = @("failed_closed_over_budget guard", "block execution")
        "invalid_wildcard_path_allowed.json" = @("wildcard path allowed")
        "invalid_directory_only_ref_allowed.json" = @("directory-only ref allowed")
        "invalid_broad_repo_scan_allowed.json" = @("broad repo scan allowed")
        "invalid_full_repo_scan_allowed.json" = @("full repo scan allowed")
        "invalid_raw_chat_history_loading_allowed.json" = @("raw chat history loading allowed")
        "invalid_report_as_machine_proof_allowed.json" = @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous agent claim")
        "invalid_external_integration_claim.json" = @("external integration claim")
        "invalid_raci_transition_gate_implementation_claim.json" = @("RACI transition gate implementation claim")
        "invalid_handoff_packet_implementation_claim.json" = @("handoff packet implementation claim")
        "invalid_workflow_drill_claim.json" = @("workflow drill claim")
        "invalid_r16_019_implementation_claim.json" = @("R16-019 or later implementation")
        "invalid_r16_027_or_later_task_claim.json" = @("R16-027 or later task")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = @("r13 closed", "False")
        "invalid_r14_caveat_removal.json" = @("r14 caveats_removed", "False")
        "invalid_r15_caveat_removal.json" = @("r15 caveats_removed", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $path = Join-Path $invalidRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            $relativePath = Join-Path $fixtureRootRel $name
            & $testContract -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $invalidRoot -Filter "invalid_*.json" | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }
}
catch {
    $failures += ("FAIL R16 role-run envelope contract harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 role-run envelope contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 role-run envelope contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
