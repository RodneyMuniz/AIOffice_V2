$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$validRoot = Join-Path $repoRoot "state\fixtures\valid\external_replay"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\external_replay"
$validator = Join-Path $repoRoot "tools\validate_r12_external_replay_bundle.ps1"
$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoots = @()

function New-TempBundleFixture {
    param([string]$Label)

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12_external_replay_bundle_{0}_{1}" -f $Label, [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $validRoot "r12_external_replay_bundle.valid.json") -Destination (Join-Path $tempRoot "r12_external_replay_bundle.json")
    Copy-Item -LiteralPath (Join-Path $validRoot "command_logs") -Destination (Join-Path $tempRoot "command_logs") -Recurse
    $script:tempRoots += $tempRoot

    return [pscustomobject]@{
        Root = $tempRoot
        BundlePath = Join-Path $tempRoot "r12_external_replay_bundle.json"
        CommandRoot = Join-Path $tempRoot "command_logs"
    }
}

function Read-TempBundle {
    param([string]$BundlePath)
    return (Get-Content -LiteralPath $BundlePath -Raw | ConvertFrom-Json)
}

function Write-TempBundle {
    param($Bundle, [string]$BundlePath)
    $Bundle | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $BundlePath -Encoding UTF8
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
    $validOutput = & $validator -BundlePath (Join-Path $validRoot "r12_external_replay_bundle.valid.json")
    if ($validOutput -notmatch "aggregate verdict 'passed'") {
        $failures += "FAIL valid: R12 external replay bundle did not validate as passed."
    }
    else {
        Write-Output "PASS valid R12 external replay bundle fixture"
        $validPassed += 1
    }

    $tempFixture = New-TempBundleFixture -Label "valid_bundle_root"
    $tempValidOutput = & $validator -BundlePath $tempFixture.BundlePath
    if ($tempValidOutput -notmatch "aggregate verdict 'passed'") {
        $failures += "FAIL valid: temp-root R12 external replay bundle did not validate as passed."
    }
    else {
        Write-Output "PASS valid temp-root R12 external replay bundle fixture"
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-clean-status-before-temp-root" -RequiredFragments @("clean_status_before.evidence_ref", "does not exist") -Action {
        $fixture = New-TempBundleFixture -Label "missing_clean_before"
        Remove-Item -LiteralPath (Join-Path $fixture.CommandRoot "clean_status_before.log") -Force
        & $validator -BundlePath $fixture.BundlePath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-command-stdout-temp-root" -RequiredFragments @("command_result.stdout_ref", "does not exist") -Action {
        $fixture = New-TempBundleFixture -Label "missing_stdout"
        Remove-Item -LiteralPath (Join-Path $fixture.CommandRoot "test_value_scorecard.stdout.log") -Force
        & $validator -BundlePath $fixture.BundlePath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-command-stderr-temp-root" -RequiredFragments @("command_result.stderr_ref", "does not exist") -Action {
        $fixture = New-TempBundleFixture -Label "missing_stderr"
        Remove-Item -LiteralPath (Join-Path $fixture.CommandRoot "test_value_scorecard.stderr.log") -Force
        & $validator -BundlePath $fixture.BundlePath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-command-exit-code-temp-root" -RequiredFragments @("command_result.exit_code_ref", "does not exist") -Action {
        $fixture = New-TempBundleFixture -Label "missing_exit_code"
        Remove-Item -LiteralPath (Join-Path $fixture.CommandRoot "test_value_scorecard.exit_code.txt") -Force
        & $validator -BundlePath $fixture.BundlePath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-path-traversal-evidence-ref" -RequiredFragments @("bounded inside the bundle root") -Action {
        $fixture = New-TempBundleFixture -Label "path_traversal"
        $bundle = Read-TempBundle -BundlePath $fixture.BundlePath
        $bundle.clean_status_before.evidence_ref = "../outside.log"
        Write-TempBundle -Bundle $bundle -BundlePath $fixture.BundlePath
        & $validator -BundlePath $fixture.BundlePath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-absolute-evidence-ref" -RequiredFragments @("absolute paths are not allowed") -Action {
        $fixture = New-TempBundleFixture -Label "absolute_ref"
        $bundle = Read-TempBundle -BundlePath $fixture.BundlePath
        $bundle.clean_status_before.evidence_ref = Join-Path $fixture.CommandRoot "clean_status_before.log"
        Write-TempBundle -Bundle $bundle -BundlePath $fixture.BundlePath
        & $validator -BundlePath $fixture.BundlePath | Out-Null
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

foreach ($tempRoot in $tempRoots) {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R12 external replay bundle tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R12 external replay bundle tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
