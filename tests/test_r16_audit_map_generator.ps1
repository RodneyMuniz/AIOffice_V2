$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16AuditMapGenerator.psm1") -Force -PassThru
$newObject = $module.ExportedCommands["New-R16AuditMapObject"]
$testMap = $module.ExportedCommands["Test-R16AuditMap"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_audit_map_generator"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r16auditmap" + [guid]::NewGuid().ToString("N"))

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

    $first = & $newObject -RepositoryRoot $repoRoot
    $second = & $newObject -RepositoryRoot $repoRoot
    $firstJson = & $stableJson -Object $first
    $secondJson = & $stableJson -Object $second
    if ($firstJson -ne $secondJson) {
        $failures += "FAIL determinism: two generated audit map objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated audit map normalized output is stable across two generations."
        $validPassed += 1
    }

    $generatedResult = & $testMap -Path "state\audit\r16_r15_r16_audit_map.json" -RepositoryRoot $repoRoot
    if ($generatedResult.ActiveThroughTask -ne "R16-012" -or $generatedResult.PlannedTaskStart -ne "R16-013" -or $generatedResult.PlannedTaskEnd -ne "R16-026" -or $generatedResult.GeneratedAuditMapIsRuntimeMemory -or $generatedResult.ArtifactMapDiffToolingImplemented -or $generatedResult.ContextLoadPlannerImplemented) {
        $failures += "FAIL generated map: expected R16 active through R16-012 only with R16-013 through R16-026 planned only and no runtime/diff/context overclaims."
    }
    else {
        Write-Output ("PASS generated map: entries={0}, caveats={1}" -f $generatedResult.EntryCount, $generatedResult.CaveatCount)
        $validPassed += 1
    }

    $validFixtureRel = Join-Path $fixtureRootRel "valid_audit_map.json"
    $validFixtureResult = & $testMap -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ActiveThroughTask -ne "R16-012") {
        $failures += "FAIL valid fixture: expected active_through_task R16-012."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_evidence_path.json" = @("missing required path")
        "invalid_wildcard_evidence_path.json" = @("wildcard path")
        "invalid_broad_scan_claim.json" = @("full_repo_scan_performed", "False")
        "invalid_directory_only_proof_claim.json" = @("directory-only proof claim")
        "invalid_runtime_memory_claim.json" = @("generated_audit_map_is_runtime_memory", "False")
        "invalid_context_planner_claim.json" = @("context_load_planner_implemented", "False")
        "invalid_artifact_diff_tooling_claim.json" = @("artifact_map_diff_tooling_implemented", "False")
        "invalid_report_as_machine_proof.json" = @("report/Markdown", "machine proof")
        "invalid_stale_ref_without_caveat.json" = @("stale ref without caveat")
        "invalid_r16_013_claim.json" = @("R16-013 or later")
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
            & $testMap -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 audit map generator harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 audit map generator tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 audit map generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
