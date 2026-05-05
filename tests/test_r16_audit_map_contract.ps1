$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16AuditMapContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16AuditMapContract"]

$contractRel = "contracts\audit\r16_audit_map.contract.json"
$fixtureRootRel = "tests\fixtures\r16_audit_map_contract"
$validFixtureRel = Join-Path $fixtureRootRel "valid_audit_map_contract.json"
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
        "tools\R16AuditMapContract.psm1",
        "tools\validate_r16_audit_map_contract.ps1",
        "tests\test_r16_audit_map_contract.ps1",
        $validFixtureRel,
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_011_audit_map_contract\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_011_audit_map_contract\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_011_audit_map_contract\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "tools\R16AuditMapGenerator.psm1",
        "tools\new_r16_audit_map.ps1",
        "state\audit\r16_audit_map.json",
        "state\audit\r15_r16_audit_map.json",
        "state\artifacts\r16_audit_map.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-011 artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -Path $contractRel -RepositoryRoot $repoRoot
    if ($contractResult.ActiveThroughTask -ne "R16-011" -or $contractResult.PlannedTaskStart -ne "R16-012" -or $contractResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed contract: expected R16 active through R16-011 only with R16-012 through R16-026 planned only."
    }
    elseif (-not $contractResult.ContractOnly -or $contractResult.GeneratedAuditMap -or $contractResult.AuditMapGenerator -or $contractResult.R15R16AuditMapGenerated -or $contractResult.ArtifactMapDiffTooling -or $contractResult.ContextLoadPlanner -or $contractResult.RoleRunEnvelope -or $contractResult.HandoffPacket -or $contractResult.WorkflowDrill -or $contractResult.RuntimeMemory -or $contractResult.ProductRuntime -or $contractResult.AutonomousAgents -or $contractResult.ExternalIntegrations -or $contractResult.R16012OrLaterClaimed) {
        $failures += "FAIL committed contract: expected contract-only mode with no generated audit map, generator, R15/R16 audit map, artifact-map diff/check tooling, context planner, role-run envelope, handoff packet, workflow drill, runtime memory, product runtime, autonomous agents, external integrations, or R16-012+ implementation."
    }
    elseif ($contractResult.R13Closed -or $contractResult.R14CaveatsRemoved -or $contractResult.R15CaveatsRemoved) {
        $failures += "FAIL committed contract: expected R13/R14/R15 boundaries to remain preserved."
    }
    else {
        Write-Output ("PASS committed contract: {0}" -f (Join-Path $repoRoot $contractRel))
        $validPassed += 1
    }

    $validFixtureResult = & $testContract -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ActiveThroughTask -ne "R16-011" -or $validFixtureResult.GeneratedAuditMap -or $validFixtureResult.AuditMapGenerator) {
        $failures += "FAIL valid fixture: expected R16 active through R16-011 only and no audit-map overclaims."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_field.json" = @("missing required field 'audit_map_entry_schema'")
        "invalid_generated_audit_map_claim.json" = @("generated_audit_map", "False")
        "invalid_audit_map_generator_claim.json" = @("audit_map_generator", "False")
        "invalid_runtime_memory_claim.json" = @("runtime_memory", "False")
        "invalid_context_planner_claim.json" = @("context_load_planner", "False")
        "invalid_broad_scan_policy.json" = @("broad_repo_root_claims_allowed", "False")
        "invalid_wildcard_path_policy.json" = @("wildcard_path_claims_allowed", "False")
        "invalid_report_as_machine_proof.json" = @("generated_reports_as_machine_proof_allowed", "False")
        "invalid_r16_012_claim.json" = @("R16-012 or later")
        "invalid_r13_boundary_change.json" = @("r13 closed", "False")
        "invalid_r14_caveat_removed.json" = @("r14 caveats_removed", "False")
        "invalid_r15_caveat_removed.json" = @("r15 caveats_removed", "False")
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
    $failures += ("FAIL R16 audit map contract harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 audit map contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 audit map contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
