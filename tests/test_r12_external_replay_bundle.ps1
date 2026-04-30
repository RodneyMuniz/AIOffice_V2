$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$validRoot = Join-Path $repoRoot "state\fixtures\valid\external_replay"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\external_replay"
$validator = Join-Path $repoRoot "tools\validate_r12_external_replay_bundle.ps1"
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
    $validOutput = & $validator -BundlePath (Join-Path $validRoot "r12_external_replay_bundle.valid.json")
    if ($validOutput -notmatch "aggregate verdict 'passed'") {
        $failures += "FAIL valid: R12 external replay bundle did not validate as passed."
    }
    else {
        Write-Output "PASS valid R12 external replay bundle fixture"
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-head-mismatch" -RequiredFragments @("observed head/tree", "expected head/tree") -Action {
        & $validator -BundlePath (Join-Path $invalidRoot "r12_external_replay_bundle.head-mismatch.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-command-logs" -RequiredFragments @("evidence_ref", "does not exist") -Action {
        & $validator -BundlePath (Join-Path $invalidRoot "r12_external_replay_bundle.missing-command-logs.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-failed-command-as-pass" -RequiredFragments @("failed command", "presented as pass") -Action {
        & $validator -BundlePath (Join-Path $invalidRoot "r12_external_replay_bundle.failed-command-as-pass.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-local-only-as-external-proof" -RequiredFragments @("local-only bundle", "external run proof") -Action {
        & $validator -BundlePath (Join-Path $invalidRoot "r12_external_replay_bundle.local-only-as-external.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL R12 external replay bundle harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R12 external replay bundle tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R12 external replay bundle tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
