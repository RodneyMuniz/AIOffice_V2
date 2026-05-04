$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RoleMemoryPackModel.psm1") -Force -PassThru
$testModel = $module.ExportedCommands["Test-R16RoleMemoryPackModel"]

$contractPath = Join-Path $repoRoot "contracts\memory\r16_role_memory_pack_model.contract.json"
$modelPath = Join-Path $repoRoot "state\memory\r16_role_memory_pack_model.json"
$memoryLayersPath = Join-Path $repoRoot "state\memory\r16_memory_layers.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\memory\r16_role_memory_pack_model.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\memory\r16_role_memory_pack_model"

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
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

try {
    $validResult = & $testModel -ModelPath $validFixture -ContractPath $contractPath -MemoryLayersPath $memoryLayersPath -RepositoryRoot $repoRoot
    if ($validResult.ActiveThroughTask -ne "R16-006" -or $validResult.PlannedTaskStart -ne "R16-007" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-006 only with R16-007 through R16-026 planned only."
    }
    elseif (-not $validResult.RolePackModelDefined -or $validResult.GeneratedBaselineRoleMemoryPacksExist -or $validResult.RoleMemoryPackGeneratorExists -or $validResult.RuntimeMemoryLoadingClaimed) {
        $failures += "FAIL valid fixture: expected model-only posture with no generated role packs, generator, or runtime memory loading."
    }
    else {
        Assert-ExactStringSet -Values $validResult.Roles -ExpectedValues $expectedRoles -Context "valid fixture roles"
        Assert-ExactStringSet -Values $validResult.KnownMemoryLayerTypes -ExpectedValues $expectedLayerTypes -Context "valid fixture memory layer dependencies"
        Write-Output ("PASS valid fixture: {0}" -f $validFixture)
        $validPassed += 1
    }

    $artifactResult = & $testModel -ModelPath $modelPath -ContractPath $contractPath -MemoryLayersPath $memoryLayersPath -RepositoryRoot $repoRoot
    if ($artifactResult.ActiveThroughTask -ne "R16-006" -or $artifactResult.PlannedTaskStart -ne "R16-007" -or $artifactResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed artifact: expected R16 active through R16-006 only with R16-007 through R16-026 planned only."
    }
    elseif (-not $artifactResult.RolePackModelDefined -or $artifactResult.GeneratedBaselineRoleMemoryPacksExist -or $artifactResult.RoleMemoryPackGeneratorExists -or $artifactResult.RuntimeMemoryLoadingClaimed) {
        $failures += "FAIL committed artifact: expected model-only posture with no generated role packs, generator, or runtime memory loading."
    }
    else {
        Assert-ExactStringSet -Values $artifactResult.Roles -ExpectedValues $expectedRoles -Context "committed artifact roles"
        Assert-ExactStringSet -Values $artifactResult.KnownMemoryLayerTypes -ExpectedValues $expectedLayerTypes -Context "committed artifact memory layer dependencies"
        Write-Output ("PASS committed artifact: {0}" -f $modelPath)
        $validPassed += 1
    }

    $model = Read-JsonObject -Path $modelPath
    Assert-ExactStringSet -Values ([string[]]$model.allowed_roles) -ExpectedValues $expectedRoles -Context "allowed roles"
    $aliasRoleIds = @($model.role_aliases | ForEach-Object { [string]$_.role_id })
    foreach ($aliasRoleId in $aliasRoleIds) {
        if ($expectedRoles -notcontains $aliasRoleId) {
            $failures += "FAIL aliases: alias resolved to unknown role '$aliasRoleId'."
        }
    }
    Write-Output "PASS role aliases: all aliases resolve only to known roles."
    $validPassed += 1

    $policyLayerRefs = @()
    foreach ($policy in $model.role_memory_layer_policy) {
        $policyLayerRefs += @($policy.allowed_memory_layer_types)
        $policyLayerRefs += @($policy.required_memory_layer_types)
        $policyLayerRefs += @($policy.forbidden_memory_layer_types)
        $orders = @($policy.load_priority | ForEach-Object { [int]$_.order })
        $uniqueOrders = @($orders | Sort-Object -Unique)
        if ($orders.Count -ne $uniqueOrders.Count -or $orders.Count -ne $policy.load_priority.Count) {
            $failures += "FAIL load priority: role '$($policy.role_id)' has duplicate order values."
        }
    }
    foreach ($layerRef in @($policyLayerRefs | Sort-Object -Unique)) {
        if ($expectedLayerTypes -notcontains $layerRef) {
            $failures += "FAIL memory layer refs: unknown layer type '$layerRef'."
        }
    }
    Write-Output "PASS memory layer refs and load priorities: all role references are known and deterministic."
    $validPassed += 1

    if ($model.pack_generation_status.generated_baseline_role_memory_packs_exist -or $model.pack_generation_status.role_memory_pack_generator_exists -or $model.pack_generation_status.runtime_memory_loading_claimed -or $model.pack_generation_status.retrieval_runtime_claimed -or $model.pack_generation_status.vector_search_runtime_claimed -or $model.pack_generation_status.actual_autonomous_agents_claimed -or $model.pack_generation_status.true_multi_agent_execution_claimed) {
        $failures += "FAIL non-claims: committed model claims generated role packs, generator, runtime memory, retrieval/vector runtime, agents, or true multi-agent execution."
    }
    else {
        Write-Output "PASS non-claims: no generated role packs, generator, runtime memory, retrieval/vector runtime, agents, or true multi-agent execution are claimed."
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "missing-role.invalid.json" = @("role_catalog")
        "unknown-role.invalid.json" = @("unknown role")
        "alias-to-unknown-role.invalid.json" = @("alias", "unknown role")
        "missing-memory-layer-dependency.invalid.json" = @("missing memory layer dependency")
        "unknown-memory-layer-type.invalid.json" = @("allowed_memory_layer_types")
        "missing-required-layer-for-role.invalid.json" = @("required_memory_layer_types")
        "no-forbidden-actions.invalid.json" = @("forbidden_actions", "must not be empty")
        "non-deterministic-load-order.invalid.json" = @("non-deterministic load order")
        "broad-repo-scan-requested.invalid.json" = @("broad repo scan")
        "wildcard-source-ref-requested.invalid.json" = @("wildcard source ref")
        "generated-role-memory-packs-claimed.invalid.json" = @("generated_role_memory_packs_claimed", "False")
        "role-memory-pack-generator-claimed.invalid.json" = @("role_memory_pack_generator_claimed", "False")
        "runtime-memory-loading-claimed.invalid.json" = @("runtime_memory_loading_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "vector-search-runtime-claimed.invalid.json" = @("vector_search_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "artifact-map-claimed.invalid.json" = @("artifact_maps_implemented", "False")
        "context-load-planner-claimed.invalid.json" = @("context_load_planner_implemented", "False")
        "r16-007-implementation-claimed.invalid.json" = @("r16_007_or_later_implementation_claimed", "False")
        "r16-027-task-introduced.invalid.json" = @("r16_027_or_later_task_exists", "False")
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
            & $testModel -ModelPath $path -ContractPath $contractPath -MemoryLayersPath $memoryLayersPath -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 role memory pack model harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 role memory pack model tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 role memory pack model tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
