$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16MemoryPackValidation.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16MemoryPackValidationReport"]
$newReport = $module.ExportedCommands["New-R16MemoryPackValidationReport"]

$reportRel = "state\memory\r16_memory_pack_validation_report.json"
$memoryLayersRel = "state\memory\r16_memory_layers.json"
$roleModelRel = "state\memory\r16_role_memory_pack_model.json"
$rolePacksRel = "state\memory\r16_role_memory_packs.json"
$contractRel = "contracts\memory\r16_memory_pack_validation_report.contract.json"
$validFixtureRel = "state\fixtures\valid\memory\r16_memory_pack_validation_report.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\memory\r16_memory_pack_validation_report"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonObject {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function ConvertTo-NormalizedJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    $document = Read-JsonObject -Path $Path
    return ($document | ConvertTo-Json -Depth 100)
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

$scratchRelativeRoot = "scratch\r16_memory_pack_validation_test"
$scratchRoot = Join-Path $repoRoot $scratchRelativeRoot

try {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratch = [System.IO.Path]::GetFullPath($scratchRoot)
        $resolvedRoot = [System.IO.Path]::GetFullPath($repoRoot)
        if (-not $resolvedScratch.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Scratch root escaped repository."
        }
        Remove-Item -LiteralPath $scratchRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $scratchRoot -Force | Out-Null

    $validResult = & $testReport -ReportPath $validFixtureRel -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot
    if ($validResult.AggregateVerdict -notin @("passed", "passed_with_caveats") -or $validResult.RolePackCount -ne 8 -or $validResult.MemoryLayerTypeCount -ne 10) {
        $failures += "FAIL valid fixture: expected passing report with 8 role packs and 10 memory layer types."
    }
    elseif ($validResult.ActiveThroughTask -ne "R16-008" -or $validResult.PlannedTaskStart -ne "R16-009" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-008 only with R16-009 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $artifactResult = & $testReport -ReportPath $reportRel -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot
    if ($artifactResult.AggregateVerdict -notin @("passed", "passed_with_caveats") -or $artifactResult.RolePackCount -ne 8 -or $artifactResult.MemoryLayerTypeCount -ne 10) {
        $failures += "FAIL committed artifact: expected passing report with 8 role packs and 10 memory layer types."
    }
    elseif ($artifactResult.ActiveThroughTask -ne "R16-008" -or $artifactResult.PlannedTaskStart -ne "R16-009" -or $artifactResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed artifact: expected R16 active through R16-008 only with R16-009 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS committed artifact: {0}" -f (Join-Path $repoRoot $reportRel))
        $validPassed += 1
    }

    $deterministicA = Join-Path $scratchRelativeRoot "deterministic_a.json"
    $deterministicB = Join-Path $scratchRelativeRoot "deterministic_b.json"
    & $newReport -OutputPath $deterministicA -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
    & $newReport -OutputPath $deterministicB -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
    $normalizedA = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicA)
    $normalizedB = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicB)
    if ($normalizedA -ne $normalizedB) {
        $failures += "FAIL deterministic detector: repeated detector runs did not produce the same normalized JSON."
    }
    else {
        Write-Output "PASS deterministic detector: repeated outputs normalized identically."
        $validPassed += 1
    }

    $report = Read-JsonObject -Path (Join-Path $repoRoot $reportRel)
    if (-not $report.exact_ref_policy.source_refs_must_be_repo_relative_exact_paths -or $report.exact_ref_policy.broad_repo_scan_performed -or $report.exact_ref_policy.wildcard_scan_performed) {
        $failures += "FAIL exact refs: report must inspect exact file refs only and record no broad/wildcard scan."
    }
    else {
        Write-Output "PASS exact refs: report records exact inspected refs only."
        $validPassed += 1
    }
    if ($report.finding_summary.missing_ref_findings -ne 0) {
        $failures += "FAIL missing refs: clean baseline must not report missing exact refs."
    }
    else {
        Write-Output "PASS missing refs: no required exact source refs are missing."
        $validPassed += 1
    }
    if ($report.finding_summary.stale_ref_findings -lt 1 -or $report.finding_summary.accepted_stale_ref_findings -lt 1) {
        $failures += "FAIL stale refs: expected stale generated_from findings accepted by explicit caveat."
    }
    else {
        Write-Output "PASS stale refs: stale generated_from boundaries are detected and caveated."
        $validPassed += 1
    }
    if ($report.finding_summary.role_policy_findings -lt 1 -or $report.finding_summary.overclaim_findings -lt 1 -or $report.finding_summary.proof_treatment_findings -lt 1) {
        $failures += "FAIL findings: expected role policy, proof treatment, and overclaim findings to be produced."
    }
    else {
        Write-Output "PASS finding coverage: role policy, proof treatment, and overclaim findings are present."
        $validPassed += 1
    }
    if ($report.report_mode.artifact_map -or $report.report_mode.audit_map -or $report.report_mode.context_load_planner -or $report.report_mode.runtime_memory -or $report.report_mode.workflow_execution) {
        $failures += "FAIL non-claims: validation report must not be runtime memory, an artifact map, an audit map, planner output, or workflow execution."
    }
    else {
        Write-Output "PASS non-claims: validation report remains a state artifact only."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "broad-output-path" -RequiredFragments @("broad repo root") -Action {
        & $newReport -OutputPath "." -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
    }
    Invoke-ExpectedRefusal -Label "wildcard-output-path" -RequiredFragments @("wildcard") -Action {
        & $newReport -OutputPath "state\memory\*.json" -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
    }
    Invoke-ExpectedRefusal -Label "missing-exact-required-path-argument" -RequiredFragments @("missing") -Action {
        & $newReport -OutputPath (Join-Path $scratchRelativeRoot "missing_input.json") -MemoryLayersPath "state\memory\missing_r16_memory_layers.json" -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
    }

    $expectedInvalidFragments = [ordered]@{
        "missing-memory-layers-artifact.invalid.json" = @("missing memory layers artifact")
        "missing-role-model-artifact.invalid.json" = @("missing role model artifact")
        "missing-role-packs-artifact.invalid.json" = @("missing role packs artifact")
        "missing-source-ref.invalid.json" = @("missing required field 'path'")
        "broad-repo-root-source-ref.invalid.json" = @("broad repo root")
        "wildcard-source-ref.invalid.json" = @("wildcard")
        "missing-exact-path.invalid.json" = @("missing")
        "stale-ref-without-caveat.invalid.json" = @("stale ref without caveat")
        "generated-report-treated-as-machine-proof.invalid.json" = @("generated report treated as machine proof")
        "planning-report-treated-as-implementation-proof.invalid.json" = @("planning report treated as implementation proof")
        "role-pack-missing-required-layer.invalid.json" = @("missing required layer")
        "role-pack-includes-forbidden-layer.invalid.json" = @("includes forbidden layer")
        "role-pack-unknown-role.invalid.json" = @("unknown role")
        "role-pack-unknown-layer-type.invalid.json" = @("unknown layer type")
        "non-deterministic-ordering.invalid.json" = @("non-deterministic report ordering")
        "runtime-memory-loading-claimed.invalid.json" = @("runtime_memory_loading_claimed", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_claimed", "False")
        "retrieval-runtime-claimed.invalid.json" = @("retrieval_runtime_claimed", "False")
        "vector-search-runtime-claimed.invalid.json" = @("vector_search_runtime_claimed", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_claimed", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_claimed", "False")
        "external-integration-claimed.invalid.json" = @("external_integration_claimed", "False")
        "artifact-map-claimed.invalid.json" = @("artifact_map_claimed", "False")
        "audit-map-claimed.invalid.json" = @("audit_map_claimed", "False")
        "context-load-planner-claimed.invalid.json" = @("context_load_planner_claimed", "False")
        "role-run-envelope-claimed.invalid.json" = @("role_run_envelope_claimed", "False")
        "handoff-packet-claimed.invalid.json" = @("handoff_packet_claimed", "False")
        "workflow-drill-claimed.invalid.json" = @("workflow_drill_claimed", "False")
        "r16-009-implementation-claimed.invalid.json" = @("r16_009_or_later_implementation_claimed", "False")
        "r16-027-task-introduced.invalid.json" = @("R16-027")
        "r13-closure-claimed.invalid.json" = @("r13 closed", "False")
        "r14-caveat-removed.invalid.json" = @("r14 caveats_removed", "False")
        "r15-caveat-removed.invalid.json" = @("r15 caveats_removed", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $path = Join-Path $invalidRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            $relativePath = Join-Path "state\fixtures\invalid\memory\r16_memory_pack_validation_report" $name
            & $testReport -ReportPath $relativePath -MemoryLayersPath $memoryLayersRel -RoleModelPath $roleModelRel -RolePacksPath $rolePacksRel -ContractPath $contractRel -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 memory pack validation harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratch = [System.IO.Path]::GetFullPath($scratchRoot)
        $resolvedRoot = [System.IO.Path]::GetFullPath($repoRoot)
        if ($resolvedScratch.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $scratchRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 memory pack validation tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 memory pack validation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
