$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16PlanningAuthorityReference.psm1") -Force -PassThru
$testReference = $module.ExportedCommands["Test-R16PlanningAuthorityReference"]
$assertStatus = $module.ExportedCommands["Assert-R16PlanningAuthorityStatusPosture"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\governance\r16_planning_authority_reference.valid.json"
$statePacket = Join-Path $repoRoot "state\governance\r16_planning_authority_reference.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\governance\r16_planning_authority_reference"

$validPassed = 0
$invalidRejected = 0
$failures = @()

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
    $validResult = & $testReference -PacketPath $validFixture -RepositoryRoot $repoRoot
    if (-not $validResult.PlanningReportsOperatorArtifactsOnly -or $validResult.PlanningReportsImplementationProof -or $validResult.ActiveThroughTask -ne "R16-002" -or $validResult.PlannedTaskStart -ne "R16-003" -or $validResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL valid fixture: expected operator-artifact-only planning treatment and R16 active through R16-002 with R16-003 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f $validFixture)
        $validPassed += 1
    }

    $stateResult = & $testReference -PacketPath $statePacket -RepositoryRoot $repoRoot
    if (-not $stateResult.PlanningReportsOperatorArtifactsOnly -or $stateResult.PlanningReportsImplementationProof -or $stateResult.ActiveThroughTask -ne "R16-002" -or $stateResult.PlannedTaskStart -ne "R16-003" -or $stateResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL state packet: expected operator-artifact-only planning treatment and R16 active through R16-002 with R16-003 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS committed R16-002 packet: {0}" -f $statePacket)
        $validPassed += 1
    }

    $statusSnapshot = & $assertStatus -RepositoryRoot $repoRoot
    if ($statusSnapshot.DoneThrough -ne 13 -or $statusSnapshot.PlannedStart -ne 14 -or $statusSnapshot.PlannedThrough -ne 26) {
        $failures += "FAIL status posture: expected R16 active through R16-013 only with R16-014 through R16-026 planned only."
    }
    else {
        Write-Output "PASS status posture: R16 active through R16-013 only; R16-014 through R16-026 remain planned only."
        $validPassed += 1
    }

    if ($stateResult.NonClaims -notcontains "no memory layers implemented yet" -or $stateResult.NonClaims -notcontains "no artifact maps implemented yet" -or $stateResult.NonClaims -notcontains "no role-run envelopes implemented yet") {
        $failures += "FAIL non-claims: expected explicit no memory layer, no artifact map, and no role-run envelope implementation statements."
    }
    else {
        Write-Output "PASS non-claims: planning reports are operator artifacts only; no memory layer, artifact map, or role-run envelope implementation is claimed."
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "missing-approved-v2-report.invalid.json" = @("artifact_paths", "AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md")
        "planning-report-treated-as-proof.invalid.json" = @("planning_reports_are_implementation_proof", "False")
        "r16-003-implementation-claimed.invalid.json" = @("r16_002_claims_r16_003_or_later", "False")
        "memory-layer-implementation-claimed.invalid.json" = @("memory_layers_implemented", "False")
        "product-runtime-claimed.invalid.json" = @("product_runtime_implemented", "False")
        "actual-autonomous-agents-claimed.invalid.json" = @("actual_autonomous_agents_implemented", "False")
        "true-multi-agent-execution-claimed.invalid.json" = @("true_multi_agent_execution_implemented", "False")
        "persistent-memory-runtime-claimed.invalid.json" = @("persistent_memory_runtime_implemented", "False")
        "retrieval-vector-runtime-claimed.invalid.json" = @("retrieval_runtime_implemented", "False")
        "external-integration-claimed.invalid.json" = @("external_integrations_implemented", "False")
        "r13-closure-claimed.invalid.json" = @("r13_closed", "False")
        "r14-caveat-removed.invalid.json" = @("r14_caveats_removed", "False")
        "r15-caveat-removed.invalid.json" = @("r15_caveats_removed", "False")
        "main-merge-claimed.invalid.json" = @("main_merge_completed", "False")
        "r16-027-task-introduced.invalid.json" = @("r16_027_or_later_task_exists", "False")
    }

    foreach ($name in $expectedInvalidFragments.Keys) {
        $path = Join-Path $invalidRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $name"
            continue
        }

        Invoke-ExpectedRefusal -Label $name -RequiredFragments $expectedInvalidFragments[$name] -Action {
            & $testReference -PacketPath $path -RepositoryRoot $repoRoot -SkipStatusPosture | Out-Null
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
    $failures += ("FAIL R16 planning authority reference harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 planning authority reference tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 planning authority reference tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
