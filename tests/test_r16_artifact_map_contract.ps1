$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16ArtifactMapContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16ArtifactMapContract"]

$contractRel = "contracts\artifacts\r16_artifact_map.contract.json"
$fixtureRootRel = "tests\fixtures\r16_artifact_map_contract"
$validFixtureRel = Join-Path $fixtureRootRel "valid_artifact_map_contract.json"
$invalidRoot = Join-Path $repoRoot $fixtureRootRel

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r16artifactmapcontract" + [guid]::NewGuid().ToString("N"))

function Read-JsonObject {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Write-JsonObject {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, ($json + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
}

function Assert-ContainsAll {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required
    )

    foreach ($requiredValue in $Required) {
        if ($Actual -notcontains $requiredValue) {
            $script:failures += ("FAIL {0}: missing required value '{1}'." -f $Label, $requiredValue)
        }
    }
}

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

function Invoke-MutatedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Mutate
    )

    $contractObject = Copy-JsonObject -Value $script:validFixtureObject
    & $Mutate $contractObject
    $path = Join-Path $tempRoot ("{0}.json" -f $Label)
    Write-JsonObject -Value $contractObject -Path $path

    Invoke-ExpectedRefusal -Label $Label -RequiredFragments $RequiredFragments -Action {
        & $testContract -ContractPath $path -RepositoryRoot $repoRoot | Out-Null
    }
}

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    foreach ($requiredPath in @(
        $contractRel,
        "tools\R16ArtifactMapContract.psm1",
        "tools\validate_r16_artifact_map_contract.ps1",
        "tests\test_r16_artifact_map_contract.ps1",
        $validFixtureRel,
        (Join-Path $fixtureRootRel "invalid_missing_required_field.json"),
        (Join-Path $fixtureRootRel "invalid_runtime_claim.json"),
        (Join-Path $fixtureRootRel "invalid_generated_map_claim.json"),
        (Join-Path $fixtureRootRel "invalid_broad_scan_policy.json"),
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_009_artifact_map_contract\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_009_artifact_map_contract\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_009_artifact_map_contract\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    $script:validFixtureObject = Read-JsonObject -Path (Join-Path $repoRoot $validFixtureRel)
    $validResult = & $testContract -ContractPath $validFixtureRel -RepositoryRoot $repoRoot
    if ($validResult.ActiveThroughTask -ne "R16-009" -or $validResult.PlannedTaskStart -ne "R16-010" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-009 only with R16-010 through R16-026 planned only."
    }
    elseif ($validResult.GeneratedArtifactMapExists -or $validResult.ArtifactMapGeneratorImplemented -or $validResult.AuditMapImplemented -or $validResult.ContextLoadPlannerImplemented) {
        $failures += "FAIL valid fixture: contract must not claim generated artifact map, generator, audit map, or context-load planner."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $contractResult = & $testContract -ContractPath $contractRel -RepositoryRoot $repoRoot
    if ($contractResult.ActiveThroughTask -ne "R16-009" -or $contractResult.PlannedTaskStart -ne "R16-010" -or $contractResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed contract: expected R16 active through R16-009 only with R16-010 through R16-026 planned only."
    }
    elseif (-not $contractResult.ContractOnly -or $contractResult.GeneratedArtifactMapExists -or $contractResult.ArtifactMapGeneratorImplemented) {
        $failures += "FAIL committed contract: expected contract-only mode with no generated artifact map or generator."
    }
    else {
        Write-Output ("PASS committed contract: {0}" -f (Join-Path $repoRoot $contractRel))
        $validPassed += 1
    }

    Assert-ContainsAll -Label "artifact classes" -Actual $contractResult.AllowedArtifactClasses -Required @(
        "governance_document", "authority_document", "contract", "tool", "cli_wrapper", "test", "fixture", "state_artifact", "proof_review_package", "validation_manifest", "report", "operator_artifact", "generated_artifact", "external_evidence", "deprecated_context", "cleanup_candidate", "unknown"
    )
    Assert-ContainsAll -Label "artifact roles" -Actual $contractResult.AllowedArtifactRoles -Required @(
        "constitutional_authority", "governance_authority", "milestone_authority", "planning_authority", "contract_authority", "validation_tool", "generation_tool", "focused_test", "valid_fixture", "invalid_fixture", "committed_state", "proof_manifest", "proof_review", "operator_report", "evidence_context", "non_claim_record", "stale_ref_caveat", "dependency_ref", "source_ref", "inspection_target"
    )
    Assert-ContainsAll -Label "authority classes" -Actual $contractResult.AllowedAuthorityClasses -Required @(
        "constitutional_authority", "governance_authority", "milestone_authority", "contract_authority", "state_authority", "proof_authority", "report_context", "operator_context", "external_evidence_context", "deprecated_context", "unknown_authority"
    )
    Assert-ContainsAll -Label "evidence kinds" -Actual $contractResult.AllowedEvidenceKinds -Required @(
        "committed_machine_evidence", "contract_schema", "validator_module", "cli_wrapper", "focused_test", "valid_fixture", "invalid_fixture", "generated_state_artifact", "validation_manifest", "proof_review_package", "operator_report", "external_replay", "narrative_context", "stale_ref_caveat", "non_claim", "rejected_claim"
    )
    Assert-ContainsAll -Label "artifact record schema" -Actual $contractResult.ArtifactRecordFields -Required @(
        "artifact_id", "path", "artifact_class", "artifact_role", "authority_class", "evidence_kind", "lifecycle_state", "proof_status", "source_task", "source_milestone", "owner_role", "source_refs", "dependency_refs", "generated_from_head", "generated_from_tree", "exact_path_only", "broad_scan_allowed", "wildcard_allowed", "inspection_route", "caveats", "non_claims", "deterministic_order"
    )

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_field.json" = @("missing required field 'path'")
        "invalid_runtime_claim.json" = @("runtime_memory_implemented", "False")
        "invalid_generated_map_claim.json" = @("artifact_map_generation_claimed", "False")
        "invalid_broad_scan_policy.json" = @("broad_scan_allowed", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $path = Join-Path $invalidRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            $relativePath = Join-Path $fixtureRootRel $name
            & $testContract -ContractPath $relativePath -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $invalidRoot -Filter "invalid_*.json" | Where-Object { $_.Name -ne "valid_artifact_map_contract.json" } | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }

    Invoke-MutatedRefusal -Label "artifact-map-generator-claimed" -RequiredFragments @("artifact_map_generator_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.artifact_map_generator_claimed = $true
    }
    Invoke-MutatedRefusal -Label "wildcard-policy-claimed" -RequiredFragments @("wildcard_allowed", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_model_records[0].wildcard_allowed = $true
    }
    Invoke-MutatedRefusal -Label "audit-map-claimed" -RequiredFragments @("audit_map_implemented", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.audit_map_implemented = $true
    }
    Invoke-MutatedRefusal -Label "context-load-planner-claimed" -RequiredFragments @("context_load_planner_implemented", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.context_load_planner_implemented = $true
    }
    Invoke-MutatedRefusal -Label "artifact-map-contract-treated-as-generated-map" -RequiredFragments @("artifact_map_contract_treated_as_generated_artifact_map", "False") -Mutate {
        param($contractObject)
        $contractObject.current_posture.artifact_map_contract_treated_as_generated_artifact_map = $true
    }
    Invoke-MutatedRefusal -Label "product-runtime-claimed" -RequiredFragments @("product_runtime_implemented", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.product_runtime_implemented = $true
    }
    Invoke-MutatedRefusal -Label "autonomous-agents-claimed" -RequiredFragments @("actual_autonomous_agents_implemented", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.actual_autonomous_agents_implemented = $true
    }
    Invoke-MutatedRefusal -Label "external-integrations-claimed" -RequiredFragments @("external_integrations_implemented", "False") -Mutate {
        param($contractObject)
        $contractObject.contract_mode.external_integrations_implemented = $true
    }
    Invoke-MutatedRefusal -Label "r16-010-implementation-claimed" -RequiredFragments @("R16-010 implementation") -Mutate {
        param($contractObject)
        $contractObject.current_posture.complete_tasks += "R16-010"
    }
    Invoke-MutatedRefusal -Label "r16-027-task-claimed" -RequiredFragments @("R16-027") -Mutate {
        param($contractObject)
        $contractObject.current_posture.planned_tasks += "R16-027"
    }
    Invoke-MutatedRefusal -Label "r13-closure-claimed" -RequiredFragments @("r13 closed", "False") -Mutate {
        param($contractObject)
        $contractObject.preserved_boundaries.r13.closed = $true
    }
    Invoke-MutatedRefusal -Label "r14-caveat-removed" -RequiredFragments @("r14 caveats_removed", "False") -Mutate {
        param($contractObject)
        $contractObject.preserved_boundaries.r14.caveats_removed = $true
    }
    Invoke-MutatedRefusal -Label "r15-caveat-removed" -RequiredFragments @("r15 caveats_removed", "False") -Mutate {
        param($contractObject)
        $contractObject.preserved_boundaries.r15.caveats_removed = $true
    }
    Invoke-MutatedRefusal -Label "audit-map-overclaim-policy" -RequiredFragments @("audit_map_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.overclaim_rejection_policy.audit_map_claimed = $true
    }
    Invoke-MutatedRefusal -Label "context-planner-overclaim-policy" -RequiredFragments @("context_load_planner_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.overclaim_rejection_policy.context_load_planner_claimed = $true
    }
    Invoke-MutatedRefusal -Label "role-run-envelope-claimed" -RequiredFragments @("role_run_envelope_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.overclaim_rejection_policy.role_run_envelope_claimed = $true
    }
    Invoke-MutatedRefusal -Label "handoff-packet-claimed" -RequiredFragments @("handoff_packet_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.overclaim_rejection_policy.handoff_packet_claimed = $true
    }
    Invoke-MutatedRefusal -Label "workflow-drill-claimed" -RequiredFragments @("workflow_drill_claimed", "False") -Mutate {
        param($contractObject)
        $contractObject.overclaim_rejection_policy.workflow_drill_claimed = $true
    }
}
catch {
    $failures += ("FAIL R16 artifact map contract harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 artifact map contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 artifact map contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
