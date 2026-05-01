$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13QaFailureFixCycle.psm1") -Force -PassThru
$testResult = $module.ExportedCommands["Test-R13FixExecutionResult"]
$testComparison = $module.ExportedCommands["Test-R13QaBeforeAfterComparison"]
$testCycle = $module.ExportedCommands["Test-R13QaFailureFixCycle"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_qa_failure_fix_cycle"
$cycleRoot = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\qa"
$issueReportPath = Join-Path $cycleRoot "r13_003_issue_detection_report.json"
$fixQueuePath = Join-Path $cycleRoot "r13_004_fix_queue.json"
$boundedFixExecutionPath = Join-Path $cycleRoot "r13_005_bounded_fix_execution_packet.json"
$demoRoot = Join-Path $repoRoot "state\cycles\r13_qa_cycle_demo"
$cliPath = Join-Path $repoRoot "tools\run_r13_qa_failure_fix_cycle.ps1"
$validateResultPath = Join-Path $repoRoot "tools\validate_r13_fix_execution_result.ps1"
$validateComparisonPath = Join-Path $repoRoot "tools\validate_r13_qa_before_after_comparison.ps1"
$validateCyclePath = Join-Path $repoRoot "tools\validate_r13_qa_failure_fix_cycle.ps1"
$canonicalInvalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_detector_inputs"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path $demoRoot ("_test_runs\" + [guid]::NewGuid().ToString("N"))

function Read-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { [string]$_ })
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

function Get-CanonicalFixtureHashes {
    $hashes = @{}
    foreach ($file in @(Get-ChildItem -LiteralPath $canonicalInvalidRoot -File | Sort-Object FullName)) {
        $relative = $file.FullName.Substring($repoRoot.Length + 1).Replace("\", "/")
        $hashes[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
    }

    return $hashes
}

function Assert-CanonicalHashesUnchanged {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Before,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $after = Get-CanonicalFixtureHashes
    foreach ($key in $Before.Keys) {
        if (-not $after.ContainsKey($key) -or $after[$key] -ne $Before[$key]) {
            $script:failures += ("FAIL canonical preservation: {0} changed during {1}." -f $key, $Context)
        }
    }
}

try {
    $resultFixturePath = Join-Path $validRoot "r13_fix_execution_result.valid.json"
    $resultValidation = & $testResult -ResultPath $resultFixturePath
    if ($resultValidation.AggregateVerdict -ne "executed_pending_rerun") {
        $failures += "FAIL valid: fix execution result fixture did not validate as executed_pending_rerun."
    }
    else {
        Write-Output ("PASS valid fix execution result fixture: {0}" -f $resultValidation.ExecutionResultId)
        $validPassed += 1
    }

    $comparisonFixturePath = Join-Path $validRoot "r13_qa_before_after_comparison.valid.json"
    $comparisonValidation = & $testComparison -ComparisonPath $comparisonFixturePath
    if ($comparisonValidation.ComparisonVerdict -ne "target_issue_resolved") {
        $failures += "FAIL valid: before/after comparison fixture did not validate as target_issue_resolved."
    }
    else {
        Write-Output ("PASS valid before/after comparison fixture: {0}" -f $comparisonValidation.ComparisonId)
        $validPassed += 1
    }

    $cycleFixturePath = Join-Path $validRoot "r13_qa_failure_fix_cycle.valid.json"
    $cycleValidation = & $testCycle -CyclePath $cycleFixturePath
    if ($cycleValidation.AggregateVerdict -ne "fixed_pending_external_replay") {
        $failures += "FAIL valid: QA failure-fix cycle fixture did not validate as fixed_pending_external_replay."
    }
    else {
        Write-Output ("PASS valid QA failure-fix cycle fixture: {0}" -f $cycleValidation.CycleId)
        $validPassed += 1
    }

    $expectedInvalidFixtures = @(
        "canonical_fixture_mutated.invalid.json",
        "selected_fix_item_not_authorized.invalid.json",
        "before_report_missing_selected_issue.invalid.json",
        "after_report_still_has_selected_issue.invalid.json",
        "new_blocking_issue_introduced.invalid.json",
        "missing_before_after_comparison.invalid.json",
        "claims_external_replay.invalid.json",
        "claims_signoff.invalid.json",
        "claims_hard_gate_delivered.invalid.json",
        "missing_non_claims.invalid.json",
        "r14_successor_opened.invalid.json"
    )
    foreach ($fixtureName in $expectedInvalidFixtures) {
        $path = Join-Path $invalidRoot $fixtureName
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "FAIL fixture: missing invalid fixture '$fixtureName'."
            continue
        }
        Invoke-ExpectedRefusal -Label $fixtureName -Action {
            & $testCycle -CyclePath $path | Out-Null
        }
    }

    $canonicalBefore = Get-CanonicalFixtureHashes
    $cliResult = Invoke-PowerShellFile -FilePath $cliPath -Arguments @(
        "-IssueReportPath", $issueReportPath,
        "-FixQueuePath", $fixQueuePath,
        "-BoundedFixExecutionPath", $boundedFixExecutionPath,
        "-OutputRoot", $tempRoot,
        "-FixItemId", "r13qf-5efcc675b9ec2995"
    )
    if ($cliResult.ExitCode -ne 0) {
        $failures += "FAIL CLI: controlled demo cycle returned non-zero. Output: $([string]::Join(' ', @($cliResult.Output)))"
    }
    else {
        Write-Output "PASS CLI: controlled demo cycle completed."
        $validPassed += 1
    }
    Assert-CanonicalHashesUnchanged -Before $canonicalBefore -Context "controlled demo run"

    $generatedBeforeReport = Read-JsonObject -Path (Join-Path $tempRoot "before_detection_report.json")
    $generatedAfterReport = Read-JsonObject -Path (Join-Path $tempRoot "after_detection_report.json")
    $generatedComparison = Read-JsonObject -Path (Join-Path $tempRoot "before_after_comparison.json")
    $generatedCycle = Read-JsonObject -Path (Join-Path $tempRoot "qa_failure_fix_cycle.json")
    $beforeSelected = @($generatedBeforeReport.issues | Where-Object { [string]$_.issue_type -eq [string]$generatedCycle.selected_issue_type -and [string]$_.blocking_status -eq "blocking" })
    $afterSelected = @($generatedAfterReport.issues | Where-Object { [string]$_.issue_type -eq [string]$generatedCycle.selected_issue_type -and [string]$_.blocking_status -eq "blocking" })

    if ($beforeSelected.Count -eq 0) {
        $failures += "FAIL generated: before report did not contain selected issue type."
    }
    else {
        Write-Output "PASS generated: before report contains selected issue type."
        $validPassed += 1
    }
    if ($afterSelected.Count -ne 0) {
        $failures += "FAIL generated: after report still contained selected issue type as blocking."
    }
    else {
        Write-Output "PASS generated: after report no longer contains selected issue type as blocking."
        $validPassed += 1
    }
    if ($generatedComparison.comparison_verdict -ne "target_issue_resolved") {
        $failures += "FAIL generated: comparison did not report target_issue_resolved."
    }
    else {
        Write-Output "PASS generated: comparison reports target_issue_resolved."
        $validPassed += 1
    }
    if ($generatedCycle.aggregate_verdict -ne "fixed_pending_external_replay") {
        $failures += "FAIL generated: cycle aggregate_verdict was not fixed_pending_external_replay."
    }
    else {
        Write-Output "PASS generated: cycle aggregate_verdict is fixed_pending_external_replay."
        $validPassed += 1
    }

    $generatedResultValidation = Invoke-PowerShellFile -FilePath $validateResultPath -Arguments @("-ResultPath", (Join-Path $tempRoot "fix_execution_result.json"))
    if ($generatedResultValidation.ExitCode -ne 0 -or ([string]::Join("`n", @($generatedResultValidation.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: fix execution result validator did not print VALID for generated artifact. Output: $([string]::Join(' ', @($generatedResultValidation.Output)))"
    }
    else {
        Write-Output "PASS validator: fix execution result validator prints VALID."
        $validPassed += 1
    }

    $generatedComparisonValidation = Invoke-PowerShellFile -FilePath $validateComparisonPath -Arguments @("-ComparisonPath", (Join-Path $tempRoot "before_after_comparison.json"))
    if ($generatedComparisonValidation.ExitCode -ne 0 -or ([string]::Join("`n", @($generatedComparisonValidation.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: before/after comparison validator did not print VALID for generated artifact. Output: $([string]::Join(' ', @($generatedComparisonValidation.Output)))"
    }
    else {
        Write-Output "PASS validator: before/after comparison validator prints VALID."
        $validPassed += 1
    }

    $generatedCycleValidation = Invoke-PowerShellFile -FilePath $validateCyclePath -Arguments @("-CyclePath", (Join-Path $tempRoot "qa_failure_fix_cycle.json"))
    if ($generatedCycleValidation.ExitCode -ne 0 -or ([string]::Join("`n", @($generatedCycleValidation.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: QA failure-fix cycle validator did not print VALID for generated artifact. Output: $([string]::Join(' ', @($generatedCycleValidation.Output)))"
    }
    else {
        Write-Output "PASS validator: QA failure-fix cycle validator prints VALID."
        $validPassed += 1
    }

    $unauthorizedRoot = Join-Path $tempRoot "unauthorized"
    $unauthorizedResult = Invoke-PowerShellFile -FilePath $cliPath -Arguments @(
        "-IssueReportPath", $issueReportPath,
        "-FixQueuePath", $fixQueuePath,
        "-BoundedFixExecutionPath", $boundedFixExecutionPath,
        "-OutputRoot", $unauthorizedRoot,
        "-FixItemId", "r13qf-not-authorized"
    )
    if ($unauthorizedResult.ExitCode -eq 0) {
        $failures += "FAIL refusal: unapproved fix item was accepted by generated cycle CLI."
    }
    else {
        Write-Output "PASS refusal: unapproved fix item is rejected."
        $invalidRejected += 1
    }

    foreach ($claimFixture in @("claims_external_replay.invalid.json", "claims_signoff.invalid.json", "claims_hard_gate_delivered.invalid.json")) {
        Invoke-ExpectedRefusal -Label "claim-refusal-$claimFixture" -Action {
            & $testCycle -CyclePath (Join-Path $invalidRoot $claimFixture) | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL R13 QA failure-fix cycle harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $demoRoot "_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 QA failure-fix cycle tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 QA failure-fix cycle tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
