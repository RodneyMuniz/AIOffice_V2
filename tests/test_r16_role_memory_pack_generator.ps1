$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RoleMemoryPackGenerator.psm1") -Force -PassThru
$testRoleMemoryPacks = $module.ExportedCommands["Test-R16RoleMemoryPacks"]
$newRoleMemoryPacks = $module.ExportedCommands["New-R16RoleMemoryPacks"]

$packsRel = "state\memory\r16_role_memory_packs.json"
$modelRel = "state\memory\r16_role_memory_pack_model.json"
$memoryLayersRel = "state\memory\r16_memory_layers.json"
$validFixtureRel = "state\fixtures\valid\memory\r16_role_memory_packs.valid.json"
$packsPath = Join-Path $repoRoot $packsRel
$modelPath = Join-Path $repoRoot $modelRel
$memoryLayersPath = Join-Path $repoRoot $memoryLayersRel
$validFixture = Join-Path $repoRoot $validFixtureRel
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\memory\r16_role_memory_packs"

$expectedRoles = @(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$expectedLayerTypes = @(
    "global_governance_memory",
    "product_governance_memory",
    "milestone_authority_memory",
    "role_identity_memory",
    "task_card_memory",
    "run_session_memory",
    "evidence_memory",
    "knowledge_index_memory",
    "historical_report_memory",
    "deprecated_cleanup_candidate_memory"
)

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $actual = @($Values | Sort-Object)
    $expected = @($ExpectedValues | Sort-Object)
    if ($actual.Count -ne $expected.Count) {
        $script:failures += "FAIL ${Context}: expected exact set $($expected -join ', ')."
        return
    }
    for ($index = 0; $index -lt $expected.Count; $index += 1) {
        if ($actual[$index] -ne $expected[$index]) {
            $script:failures += "FAIL ${Context}: expected exact set $($expected -join ', ')."
            return
        }
    }
}

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

function Read-JsonObject {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function ConvertTo-NormalizedJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    $document = Read-JsonObject -Path $Path
    return ($document | ConvertTo-Json -Depth 100)
}

$scratchRelativeRoot = "scratch\r16_role_memory_pack_generator_test"
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

    $validResult = & $testRoleMemoryPacks -PacksPath $validFixtureRel -ModelPath $modelRel -MemoryLayersPath $memoryLayersRel -RepositoryRoot $repoRoot
    if ($validResult.ActiveThroughTask -ne "R16-007" -or $validResult.PlannedTaskStart -ne "R16-008" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-007 only with R16-008 through R16-026 planned only."
    }
    elseif (-not $validResult.StateArtifactsOnly -or $validResult.RuntimeMemoryLoadingImplemented -or $validResult.ActualAutonomousAgentsImplemented -or $validResult.WorkflowDrillsRun) {
        $failures += "FAIL valid fixture: expected generated role packs as state artifacts only, not runtime memory, not actual agents, and not workflow execution."
    }
    else {
        Assert-ExactStringSet -Values $validResult.Roles -ExpectedValues $expectedRoles -Context "valid fixture roles"
        Assert-ExactStringSet -Values $validResult.MemoryLayerTypes -ExpectedValues $expectedLayerTypes -Context "valid fixture memory layer types"
        Write-Output ("PASS valid fixture: {0}" -f $validFixture)
        $validPassed += 1
    }

    $artifactResult = & $testRoleMemoryPacks -PacksPath $packsRel -ModelPath $modelRel -MemoryLayersPath $memoryLayersRel -RepositoryRoot $repoRoot
    if ($artifactResult.ActiveThroughTask -ne "R16-007" -or $artifactResult.PlannedTaskStart -ne "R16-008" -or $artifactResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed artifact: expected R16 active through R16-007 only with R16-008 through R16-026 planned only."
    }
    elseif (-not $artifactResult.StateArtifactsOnly -or $artifactResult.RuntimeMemoryLoadingImplemented -or $artifactResult.ActualAutonomousAgentsImplemented -or $artifactResult.WorkflowDrillsRun) {
        $failures += "FAIL committed artifact: expected generated role packs as state artifacts only, not runtime memory, not actual agents, and not workflow execution."
    }
    else {
        Assert-ExactStringSet -Values $artifactResult.Roles -ExpectedValues $expectedRoles -Context "committed artifact roles"
        Assert-ExactStringSet -Values $artifactResult.MemoryLayerTypes -ExpectedValues $expectedLayerTypes -Context "committed artifact memory layer types"
        Write-Output ("PASS committed artifact: {0}" -f $packsPath)
        $validPassed += 1
    }

    $packs = Read-JsonObject -Path $packsPath
    $model = Read-JsonObject -Path $modelPath
    $memoryLayers = Read-JsonObject -Path $memoryLayersPath
    $knownLayerTypes = @($memoryLayers.layer_records | ForEach-Object { [string]$_.layer_type })

    Assert-ExactStringSet -Values ([string[]]$packs.allowed_roles) -ExpectedValues $expectedRoles -Context "allowed roles"
    $aliasRoleIds = @($packs.role_aliases | ForEach-Object { [string]$_.role_id })
    foreach ($aliasRoleId in $aliasRoleIds) {
        if ($expectedRoles -notcontains $aliasRoleId) {
            $failures += "FAIL aliases: alias resolved to unknown role '$aliasRoleId'."
        }
    }
    Write-Output "PASS role aliases: all aliases resolve only to known roles."
    $validPassed += 1

    foreach ($pack in $packs.role_packs) {
        $roleId = [string]$pack.role_id
        $policy = @($model.role_memory_layer_policy | Where-Object { $_.role_id -eq $roleId })[0]
        $dependencyTypes = @($pack.memory_layer_dependencies | ForEach-Object { [string]$_.layer_type })
        foreach ($layerType in $dependencyTypes) {
            if ($knownLayerTypes -notcontains $layerType) {
                $failures += "FAIL memory layer refs: role '$roleId' uses unknown R16 memory layer type '$layerType'."
            }
        }
        foreach ($requiredLayer in @($policy.required_memory_layer_types)) {
            if ($dependencyTypes -notcontains $requiredLayer) {
                $failures += "FAIL required layers: role '$roleId' is missing '$requiredLayer'."
            }
        }
        foreach ($forbiddenLayer in @($policy.forbidden_memory_layer_types)) {
            if ($dependencyTypes -contains $forbiddenLayer) {
                $failures += "FAIL forbidden layers: role '$roleId' includes forbidden layer '$forbiddenLayer'."
            }
        }
        $orders = @($pack.load_priority | ForEach-Object { [int]$_.order })
        for ($index = 0; $index -lt $orders.Count; $index += 1) {
            if ($orders[$index] -ne ($index + 1)) {
                $failures += "FAIL deterministic load order: role '$roleId' load priority is not contiguous from 1."
            }
        }
    }
    Write-Output "PASS role pack policies: known layers, required layers, forbidden exclusions, and deterministic load priorities verified."
    $validPassed += 1

    $deterministicA = Join-Path $scratchRelativeRoot "deterministic_a.json"
    $deterministicB = Join-Path $scratchRelativeRoot "deterministic_b.json"
    & $newRoleMemoryPacks -OutputPath $deterministicA -ModelPath "state\memory\r16_role_memory_pack_model.json" -MemoryLayersPath "state\memory\r16_memory_layers.json" -RepositoryRoot $repoRoot | Out-Null
    & $newRoleMemoryPacks -OutputPath $deterministicB -ModelPath "state\memory\r16_role_memory_pack_model.json" -MemoryLayersPath "state\memory\r16_memory_layers.json" -RepositoryRoot $repoRoot | Out-Null
    $normalizedA = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicA)
    $normalizedB = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicB)
    if ($normalizedA -ne $normalizedB) {
        $failures += "FAIL deterministic generation: repeated generation did not produce the same normalized JSON."
    }
    else {
        Write-Output "PASS deterministic generation: repeated outputs normalized identically."
        $validPassed += 1
    }

    if ($packs.generated_artifact_statement -notmatch "committed state artifacts" -or $packs.generated_artifact_statement -notmatch "not runtime memory" -or $packs.generated_artifact_statement -notmatch "not actual agents" -or $packs.generated_artifact_statement -notmatch "not workflow execution") {
        $failures += "FAIL artifact statement: role memory packs must be state artifacts only, not runtime memory, not actual agents, and not workflow execution."
    }
    else {
        Write-Output "PASS non-claims: generated role memory packs are state artifacts only, not runtime memory, not actual agents, and not workflow execution."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "broad-output-path" -RequiredFragments @("broad repo") -Action {
        & $newRoleMemoryPacks -OutputPath "." -ModelPath "state\memory\r16_role_memory_pack_model.json" -MemoryLayersPath "state\memory\r16_memory_layers.json" -RepositoryRoot $repoRoot | Out-Null
    }
    Invoke-ExpectedRefusal -Label "wildcard-output-path" -RequiredFragments @("wildcard source ref") -Action {
        & $newRoleMemoryPacks -OutputPath "state\memory\*.json" -ModelPath "state\memory\r16_role_memory_pack_model.json" -MemoryLayersPath "state\memory\r16_memory_layers.json" -RepositoryRoot $repoRoot | Out-Null
    }

    $expectedInvalidFragments = [ordered]@{
        "missing-role-pack.invalid.json" = @("role_packs role_id")
        "unknown-role.invalid.json" = @("unknown role")
        "alias-to-unknown-role.invalid.json" = @("alias", "unknown role")
        "missing-model-dependency.invalid.json" = @("model_ref")
        "missing-memory-layer-dependency.invalid.json" = @("missing memory layer dependency")
        "unknown-memory-layer-type.invalid.json" = @("unknown memory layer type")
        "missing-required-layer-for-role.invalid.json" = @("missing required layer")
        "forbidden-layer-included-for-role.invalid.json" = @("forbidden layer included")
        "missing-load-priority.invalid.json" = @("load_priority")
        "non-deterministic-load-order.invalid.json" = @("non-deterministic load order")
        "broad-repo-scan-requested.invalid.json" = @("broad_repo_scan_requested", "False")
        "wildcard-source-ref-requested.invalid.json" = @("wildcard source ref")
        "stale-ref-accepted-without-caveat.invalid.json" = @("stale ref accepted without caveat")
        "generated-report-treated-as-machine-proof.invalid.json" = @("generated report treated as machine proof")
        "planning-report-treated-as-implementation-proof.invalid.json" = @("planning report treated as implementation proof")
        "runtime-memory-loading-claimed.invalid.json" = @("runtime_memory_loading_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "vector-search-runtime-claimed.invalid.json" = @("vector_search_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "artifact-map-claimed.invalid.json" = @("artifact_maps_implemented", "False")
        "audit-map-claimed.invalid.json" = @("audit_maps_implemented", "False")
        "context-load-planner-claimed.invalid.json" = @("context_load_planner_implemented", "False")
        "role-run-envelope-claimed.invalid.json" = @("role_run_envelopes_implemented", "False")
        "raci-transition-gate-claimed.invalid.json" = @("raci_transition_gates_implemented", "False")
        "handoff-packet-claimed.invalid.json" = @("handoff_packets_implemented", "False")
        "workflow-drill-claimed.invalid.json" = @("workflow_drills_run", "False")
        "r16-008-implementation-claimed.invalid.json" = @("r16_008_or_later_implementation_claimed", "False")
        "r16-027-task-introduced.invalid.json" = @("planned_tasks")
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
            $relativePath = Join-Path "state\fixtures\invalid\memory\r16_role_memory_packs" $name
            & $testRoleMemoryPacks -PacksPath $relativePath -ModelPath $modelRel -MemoryLayersPath $memoryLayersRel -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 role memory pack generator harness: {0}" -f $_.Exception.Message)
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
    throw ("R16 role memory pack generator tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 role memory pack generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
