$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16MemoryLayerContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16MemoryLayerContract"]

$statusModule = Import-Module (Join-Path $repoRoot "tools\StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $statusModule.ExportedCommands["Test-StatusDocGate"]

$contractPath = Join-Path $repoRoot "contracts\memory\r16_memory_layer.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\memory\r16_memory_layer_contract.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\memory\r16_memory_layer_contract"

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

try {
    $validResult = & $testContract -ContractPath $validFixture -RepositoryRoot $repoRoot
    if (-not $validResult.ContractModelOnly -or $validResult.RuntimeMemoryLoadingImplemented -or $validResult.OperationalMemoryLayersGenerated) {
        $failures += "FAIL valid fixture: expected contract-model-only posture with no runtime memory loading and no generated operational memory layers."
    }
    elseif ($validResult.ActiveThroughTask -ne "R16-004" -or $validResult.PlannedTaskStart -ne "R16-005" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected R16 active through R16-004 only with R16-005 through R16-026 planned only."
    }
    else {
        Assert-ExactStringSet -Values $validResult.AllowedLayerTypes -ExpectedValues $expectedLayerTypes -Context "valid fixture allowed memory layer types"
        Write-Output ("PASS valid fixture: {0}" -f $validFixture)
        $validPassed += 1
    }

    $contractResult = & $testContract -ContractPath $contractPath -RepositoryRoot $repoRoot
    if (-not $contractResult.ContractModelOnly -or $contractResult.RuntimeMemoryLoadingImplemented -or $contractResult.OperationalMemoryLayersGenerated) {
        $failures += "FAIL committed contract: expected contract-model-only posture with no runtime memory loading and no generated operational memory layers."
    }
    elseif ($contractResult.ActiveThroughTask -ne "R16-004" -or $contractResult.PlannedTaskStart -ne "R16-005" -or $contractResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed contract: expected R16 active through R16-004 only with R16-005 through R16-026 planned only."
    }
    else {
        Assert-ExactStringSet -Values $contractResult.AllowedLayerTypes -ExpectedValues $expectedLayerTypes -Context "committed contract allowed memory layer types"
        Write-Output ("PASS committed contract: {0}" -f $contractPath)
        $validPassed += 1
    }

    if ($contractResult.NonClaims -notcontains "no deterministic memory layer generator" -or $contractResult.NonClaims -notcontains "no generated operational memory layers" -or $contractResult.NonClaims -notcontains "memory-layer contract existence does not equal memory runtime") {
        $failures += "FAIL committed contract non-claims: expected explicit no generator, no generated operational memory layers, and no runtime-memory equivalence claim."
    }
    else {
        Write-Output "PASS explicit non-claims: contract is model-only and does not claim memory runtime."
        $validPassed += 1
    }

    $status = & $testStatusDocGate -RepositoryRoot $repoRoot
    if (-not $status.R16Opened -or $status.R16DoneThrough -ne 12 -or $status.R16PlannedStart -ne 13 -or $status.R16PlannedThrough -ne 26) {
        $failures += "FAIL status posture: expected R16 active through R16-012 only with R16-013 through R16-026 planned only."
    }
    else {
        Write-Output "PASS status posture: R16 active through R16-012 only; R16-013 through R16-026 remain planned only."
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "missing-layer-type.invalid.json" = @("layer_type")
        "unknown-layer-type.invalid.json" = @("layer_type")
        "missing-authority-class.invalid.json" = @("authority_class")
        "unknown-authority-class.invalid.json" = @("authority_class")
        "missing-source-refs.invalid.json" = @("source_refs", "must not be empty")
        "broad-repo-root-source-ref.invalid.json" = @("broad repo root source ref")
        "wildcard-source-ref.invalid.json" = @("wildcard source ref")
        "generated-report-treated-as-machine-proof.invalid.json" = @("generated report treated as machine proof")
        "planning-report-treated-as-implementation-proof.invalid.json" = @("planning report treated as implementation proof")
        "stale-ref-accepted-without-caveat.invalid.json" = @("stale ref accepted without caveat")
        "runtime-memory-loading-claimed.invalid.json" = @("runtime_memory_loading_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "vector-search-runtime-claimed.invalid.json" = @("vector_search_runtime_implemented", "False")
        "product-runtime-claimed.invalid.json" = @("product_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "r16-005-implementation-claimed.invalid.json" = @("R16-005 or later implementation")
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
            & $testContract -ContractPath $path -RepositoryRoot $repoRoot | Out-Null
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

    if ($validResult.AllowedLayerTypes -notcontains "global_governance_memory" -or $validResult.AllowedLayerTypes -notcontains "deprecated_cleanup_candidate_memory") {
        $failures += "FAIL layer type completeness: expected first and cleanup-candidate memory layer types."
    }
    else {
        Write-Output "PASS layer type completeness: all required R16-004 memory layer types are defined."
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL R16 memory layer contract harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 memory layer contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 memory layer contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
