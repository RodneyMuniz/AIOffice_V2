$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExternalRunnerContract.psm1") -Force -PassThru
$testRequest = $module.ExportedCommands["Test-ExternalRunnerRequestContract"]
$testResult = $module.ExportedCommands["Test-ExternalRunnerResultContract"]
$testManifest = $module.ExportedCommands["Test-ExternalRunnerArtifactManifestContract"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\external_runner"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\external_runner"
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
    $request = & $testRequest -RequestPath (Join-Path $validRoot "external_runner_request.valid.json")
    if ($request.CommandCount -ne 1 -or $request.DispatchMode -ne "api_dispatch") {
        $failures += "FAIL valid: external runner request did not validate with expected command count and dispatch mode."
    }
    else {
        Write-Output ("PASS valid request fixture: {0}" -f $request.RequestId)
        $validPassed += 1
    }

    $result = & $testResult -ResultPath (Join-Path $validRoot "external_runner_result.success.valid.json")
    if (-not $result.SuccessfulExternalEvidenceShape -or $result.Status -ne "completed" -or $result.Conclusion -ne "success") {
        $failures += "FAIL valid: successful external runner result did not validate as successful evidence shape."
    }
    else {
        Write-Output ("PASS valid successful result fixture: {0}" -f $result.ResultId)
        $validPassed += 1
    }

    $manifest = & $testManifest -ManifestPath (Join-Path $validRoot "external_runner_artifact_manifest.valid.json")
    if (-not $manifest.HeadTreeMatch -or $manifest.ContainedFileCount -ne 1) {
        $failures += "FAIL valid: external runner artifact manifest did not validate with matching head/tree."
    }
    else {
        Write-Output ("PASS valid artifact manifest fixture: {0}" -f $manifest.ManifestId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-run-id" -RequiredFragments @("run_id", "non-empty string") -Action {
        & $testResult -ResultPath (Join-Path $invalidRoot "external_runner_result.missing-run-id.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-head-mismatch" -RequiredFragments @("matching requested/observed head and tree") -Action {
        & $testResult -ResultPath (Join-Path $invalidRoot "external_runner_result.head-mismatch.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-success-without-artifact-manifest" -RequiredFragments @("artifact_manifest_ref", "non-empty string") -Action {
        & $testResult -ResultPath (Join-Path $invalidRoot "external_runner_result.success-without-manifest.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-failed-run-presented-as-pass" -RequiredFragments @("failed or missing run", "presented as pass") -Action {
        & $testResult -ResultPath (Join-Path $invalidRoot "external_runner_result.failed-presented-as-pass.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-local-only-as-external-proof" -RequiredFragments @("local-only evidence", "external runner claim") -Action {
        & $testResult -ResultPath (Join-Path $invalidRoot "external_runner_result.local-only-as-external.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims", "no R12 value-gate delivery yet") -Action {
        & $testRequest -RequestPath (Join-Path $invalidRoot "external_runner_request.missing-non-claims.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-artifact-manifest-head-mismatch" -RequiredFragments @("head/tree mismatch") -Action {
        & $testManifest -ManifestPath (Join-Path $invalidRoot "external_runner_artifact_manifest.head-mismatch.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL external runner contract harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External runner contract tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external runner contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
