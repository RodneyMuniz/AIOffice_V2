$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16ArtifactAuditMapCheck.psm1") -Force -PassThru
$newObject = $module.ExportedCommands["New-R16ArtifactAuditMapCheckReportObject"]
$newReport = $module.ExportedCommands["New-R16ArtifactAuditMapCheckReport"]
$testReport = $module.ExportedCommands["Test-R16ArtifactAuditMapCheckReport"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16ArtifactAuditMapCheckFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_artifact_audit_map_check"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$tempRootRel = Join-Path "scratch" ("r16artifactauditcheck" + [guid]::NewGuid().ToString("N"))
$tempRoot = Join-Path $repoRoot $tempRootRel

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
    & $newFixtures -RepositoryRoot $repoRoot | Out-Null

    $first = & $newObject -RepositoryRoot $repoRoot
    $second = & $newObject -RepositoryRoot $repoRoot
    $firstJson = & $stableJson -Object $first
    $secondJson = & $stableJson -Object $second
    if ($firstJson -ne $secondJson) {
        $failures += "FAIL determinism: two generated R16-013 check reports differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-013 check report normalized output is stable across two generations."
        $validPassed += 1
    }

    $tempReportRel = Join-Path $tempRootRel "r16_artifact_audit_map_check_report.json"
    $tempReport = Join-Path $repoRoot $tempReportRel
    $generated = & $newReport -OutputPath $tempReportRel -RepositoryRoot $repoRoot
    if ($generated.AggregateVerdict -ne "passed_with_caveats" -or $generated.ActiveThroughTask -ne "R16-013" -or $generated.PlannedTaskStart -ne "R16-014" -or $generated.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL generated report: expected passed_with_caveats, active through R16-013 only, and R16-014 through R16-026 planned only."
    }
    else {
        Write-Output ("PASS generated report: findings={0}, warnings={1}" -f $generated.FindingCount, $generated.WarningCount)
        $validPassed += 1
    }

    $generatedValidation = & $testReport -Path $tempReportRel -RepositoryRoot $repoRoot
    if ($generatedValidation.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL generated validation: expected passed_with_caveats."
    }
    else {
        Write-Output ("PASS generated validation: {0}" -f $tempReport)
        $validPassed += 1
    }

    $validFixtureRel = Join-Path $fixtureRootRel "valid_check_report.json"
    $validFixtureResult = & $testReport -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ActiveThroughTask -ne "R16-013" -or $validFixtureResult.AggregateVerdict -ne "passed_with_caveats") {
        $failures += "FAIL valid fixture: expected active_through_task R16-013 and passed_with_caveats."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validReport = Get-Content -Raw (Join-Path $repoRoot $validFixtureRel) | ConvertFrom-Json
    $acceptedCaveatIds = @($validReport.accepted_caveats | ForEach-Object { [string]$_.caveat_id })
    $warningCaveatIds = @($validReport.findings | Where-Object { $_.severity -eq "warning" } | ForEach-Object { [string]$_.accepted_caveat_id })
    foreach ($expectedCaveatId in @("r15_final_proof_review_package_stale_generated_from", "r15_evidence_index_stale_generated_from")) {
        if ($acceptedCaveatIds -notcontains $expectedCaveatId -or $warningCaveatIds -notcontains $expectedCaveatId) {
            $failures += "FAIL caveat acceptance: expected known R15 stale generated_from caveat '$expectedCaveatId' to be explicit in accepted_caveats and warning findings."
        }
    }
    if ($failures.Count -eq 0) {
        Write-Output "PASS caveat acceptance: known R15 stale generated_from refs are accepted only by explicit caveats."
        $validPassed += 1
    }

    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_artifact_map_ref.json" = @("artifact_map_ref", "state/artifacts/r16_artifact_map.json")
        "invalid_missing_audit_map_ref.json" = @("audit_map_ref", "state/audit/r16_r15_r16_audit_map.json")
        "invalid_missing_evidence_path.json" = @("missing_required_paths", "0")
        "invalid_wildcard_path.json" = @("wildcard_paths", "0")
        "invalid_broad_repo_root_path.json" = @("broad_repo_root_paths", "0")
        "invalid_directory_only_proof_claim.json" = @("directory_only_proof_claims", "0")
        "invalid_stale_generated_from_without_caveat.json" = @("accepted_caveats", "r15_evidence_index_stale_generated_from")
        "invalid_report_as_machine_proof.json" = @("report_as_machine_proof_errors", "0")
        "invalid_runtime_memory_claim.json" = @("runtime_memory_implemented", "False")
        "invalid_context_planner_claim.json" = @("context_load_planner_implemented", "False")
        "invalid_role_run_envelope_claim.json" = @("role_run_envelope_implemented", "False")
        "invalid_handoff_packet_claim.json" = @("handoff_packet_implemented", "False")
        "invalid_workflow_drill_claim.json" = @("workflow_drill_run", "False")
        "invalid_r16_014_claim.json" = @("R16-014 or later")
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
            & $testReport -Path $relativePath -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 artifact/audit map check harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 artifact/audit map check tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 artifact/audit map check tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
