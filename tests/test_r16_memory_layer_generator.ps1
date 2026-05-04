$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16MemoryLayerGenerator.psm1") -Force -PassThru
$testMemoryLayers = $module.ExportedCommands["Test-R16MemoryLayers"]
$newMemoryLayers = $module.ExportedCommands["New-R16MemoryLayers"]

$contractPath = Join-Path $repoRoot "contracts\memory\r16_memory_layer.contract.json"
$memoryLayersPath = Join-Path $repoRoot "state\memory\r16_memory_layers.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\memory\r16_memory_layers.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\memory\r16_memory_layers"

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

function ConvertTo-NormalizedJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $document = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    return ($document | ConvertTo-Json -Depth 100)
}

$scratchRelativeRoot = "scratch\r16_memory_layer_generator_test"
$scratchRoot = Join-Path $repoRoot $scratchRelativeRoot

try {
    if (Test-Path -LiteralPath $scratchRoot) {
        Remove-Item -LiteralPath $scratchRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $scratchRoot -Force | Out-Null

    $validResult = & $testMemoryLayers -MemoryLayersPath $validFixture -ContractPath $contractPath -RepositoryRoot $repoRoot
    if ($validResult.ActiveThroughTask -ne "R16-005" -or $validResult.PlannedTaskStart -ne "R16-006" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-005 only with R16-006 through R16-026 planned only."
    }
    elseif (-not $validResult.BaselineStateArtifactGenerated -or $validResult.RuntimeMemoryLoadingImplemented -or $validResult.RetrievalRuntimeImplemented -or $validResult.VectorSearchRuntimeImplemented -or $validResult.RoleSpecificMemoryPacksImplemented) {
        $failures += "FAIL valid fixture: expected baseline state artifact generation only with no runtime, retrieval/vector, or role-specific memory packs."
    }
    else {
        Assert-ExactStringSet -Values $validResult.LayerTypes -ExpectedValues $expectedLayerTypes -Context "valid fixture memory layer types"
        Write-Output ("PASS valid fixture: {0}" -f $validFixture)
        $validPassed += 1
    }

    $artifactResult = & $testMemoryLayers -MemoryLayersPath $memoryLayersPath -ContractPath $contractPath -RepositoryRoot $repoRoot
    if ($artifactResult.ActiveThroughTask -ne "R16-005" -or $artifactResult.PlannedTaskStart -ne "R16-006" -or $artifactResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed artifact: expected R16 active through R16-005 only with R16-006 through R16-026 planned only."
    }
    elseif (-not $artifactResult.BaselineStateArtifactGenerated -or $artifactResult.RuntimeMemoryLoadingImplemented -or $artifactResult.RetrievalRuntimeImplemented -or $artifactResult.VectorSearchRuntimeImplemented -or $artifactResult.RoleSpecificMemoryPacksImplemented) {
        $failures += "FAIL committed artifact: expected baseline state artifact generation only with no runtime, retrieval/vector, or role-specific memory packs."
    }
    else {
        Assert-ExactStringSet -Values $artifactResult.LayerTypes -ExpectedValues $expectedLayerTypes -Context "committed artifact memory layer types"
        Write-Output ("PASS committed artifact: {0}" -f $memoryLayersPath)
        $validPassed += 1
    }

    $deterministicA = Join-Path $scratchRelativeRoot "deterministic_a.json"
    $deterministicB = Join-Path $scratchRelativeRoot "deterministic_b.json"
    & $newMemoryLayers -OutputPath $deterministicA -ContractPath "contracts\memory\r16_memory_layer.contract.json" -RepositoryRoot $repoRoot | Out-Null
    & $newMemoryLayers -OutputPath $deterministicB -ContractPath "contracts\memory\r16_memory_layer.contract.json" -RepositoryRoot $repoRoot | Out-Null
    $normalizedA = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicA)
    $normalizedB = ConvertTo-NormalizedJson -Path (Join-Path $repoRoot $deterministicB)
    if ($normalizedA -ne $normalizedB) {
        $failures += "FAIL deterministic generation: repeated generation did not produce the same normalized JSON."
    }
    else {
        Write-Output "PASS deterministic generation: repeated outputs normalized identically."
        $validPassed += 1
    }

    if ($artifactResult.LayerTypes.Count -ne 10) {
        $failures += "FAIL layer type completeness: expected all 10 R16-004 memory layer types."
    }
    else {
        Write-Output "PASS layer type completeness: all 10 memory layer types are present."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "broad-output-path" -RequiredFragments @("broad repo root") -Action {
        & $newMemoryLayers -OutputPath "." -ContractPath "contracts\memory\r16_memory_layer.contract.json" -RepositoryRoot $repoRoot | Out-Null
    }
    Invoke-ExpectedRefusal -Label "wildcard-output-path" -RequiredFragments @("wildcard source ref") -Action {
        & $newMemoryLayers -OutputPath "state\memory\*.json" -ContractPath "contracts\memory\r16_memory_layer.contract.json" -RepositoryRoot $repoRoot | Out-Null
    }

    $expectedInvalidFragments = [ordered]@{
        "missing-memory-layer.invalid.json" = @("layer_type")
        "unknown-memory-layer-type.invalid.json" = @("layer_type")
        "missing-authority-class.invalid.json" = @("authority_class")
        "unknown-authority-class.invalid.json" = @("authority_class")
        "missing-source-refs.invalid.json" = @("source_refs", "must not be empty")
        "broad-repo-root-source-ref.invalid.json" = @("broad repo root source ref")
        "wildcard-source-ref.invalid.json" = @("wildcard source ref")
        "full-repo-scan-requested.invalid.json" = @("full_repo_scan_requested", "False")
        "stale-ref-accepted-without-caveat.invalid.json" = @("stale ref accepted without caveat")
        "generated-report-treated-as-machine-proof.invalid.json" = @("generated report treated as machine proof")
        "planning-report-treated-as-implementation-proof.invalid.json" = @("planning report treated as implementation proof")
        "runtime-memory-loading-claimed.invalid.json" = @("runtime_memory_loading_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "vector-search-runtime-claimed.invalid.json" = @("vector_search_runtime_implemented", "False")
        "role-specific-memory-packs-claimed.invalid.json" = @("role_specific_memory_packs_implemented", "False")
        "artifact-map-claimed.invalid.json" = @("artifact_maps_implemented", "False")
        "context-load-planner-claimed.invalid.json" = @("context_load_planner_implemented", "False")
        "product-runtime-claimed.invalid.json" = @("product_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "r16-006-implementation-claimed.invalid.json" = @("R16-006 implementation")
        "r16-027-task-introduced.invalid.json" = @("R16-027 or later task")
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
            & $testMemoryLayers -MemoryLayersPath $path -ContractPath $contractPath -RepositoryRoot $repoRoot | Out-Null
        }
    }

    if (Test-Path -LiteralPath $invalidRoot -PathType Container) {
        $actualInvalidNames = @((Get-ChildItem -LiteralPath $invalidRoot -Filter "*.invalid.json" | ForEach-Object { $_.Name }) | Sort-Object)
        $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
        $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
        if ($unexpectedInvalidNames.Count -gt 0) {
            $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
        }
    }
}
catch {
    $failures += ("FAIL R16 memory layer generator harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        Remove-Item -LiteralPath $scratchRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 memory layer generator tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 memory layer generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
