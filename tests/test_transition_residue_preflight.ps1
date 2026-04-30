$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\TransitionResiduePreflight.psm1") -Force -PassThru
$testPreflight = $module.ExportedCommands["Test-TransitionResiduePreflightContract"]
$assertReady = $module.ExportedCommands["Assert-TransitionResiduePreflightReady"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\residue_guard"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\residue_guard"
$expectedBranch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$expectedHead = "65dab1a85db35a1c5fd853a08c564df9a2ac2e68"
$expectedTree = "8b0dc744250af62d83b627ec34d78a92dfbc5aee"

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
    $cleanPath = Join-Path $validRoot "transition_residue_preflight.clean.valid.json"
    $cleanResult = & $testPreflight -PreflightPath $cleanPath
    & $assertReady -PreflightPath $cleanPath -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "fresh_thread_bootstrap_ready" -TransitionTo "residue_preflight_passed" | Out-Null
    Write-Output ("PASS valid clean status fixture: {0}" -f $cleanResult.Transition)
    $validPassed += 1

    $expectedPath = Join-Path $validRoot "transition_residue_preflight.expected_generated.valid.json"
    $expectedResult = & $testPreflight -PreflightPath $expectedPath
    & $assertReady -PreflightPath $expectedPath -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "plan_approved" -TransitionTo "fresh_thread_bootstrap_ready" | Out-Null
    Write-Output ("PASS valid expected generated artifact fixture: {0}" -f $expectedResult.Transition)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-dirty-tracked-file" -RequiredFragments @("verdict", "fail_closed", "blocks transition") -Action {
        & $assertReady -PreflightPath (Join-Path $invalidRoot "transition_residue_preflight.dirty_tracked.invalid.json") -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "fresh_thread_bootstrap_ready" -TransitionTo "residue_preflight_passed" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-unexpected-untracked-file" -RequiredFragments @("verdict", "fail_closed", "blocks transition") -Action {
        & $assertReady -PreflightPath (Join-Path $invalidRoot "transition_residue_preflight.unexpected_untracked.invalid.json") -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "residue_preflight_passed" -TransitionTo "external_runner_requested" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-preflight" -RequiredFragments @("missing preflight", "fresh_thread_bootstrap_ready -> residue_preflight_passed") -Action {
        & $assertReady -PreflightPath (Join-Path $invalidRoot "missing_preflight.invalid.json") -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "fresh_thread_bootstrap_ready" -TransitionTo "residue_preflight_passed" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-stale-head-tree" -RequiredFragments @("stale head/tree", $expectedHead) -Action {
        & $assertReady -PreflightPath (Join-Path $invalidRoot "transition_residue_preflight.stale_head_tree.invalid.json") -ExpectedBranch $expectedBranch -ExpectedHead $expectedHead -ExpectedTree $expectedTree -TransitionFrom "fresh_thread_bootstrap_ready" -TransitionTo "residue_preflight_passed" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-broad-quarantine-candidate" -RequiredFragments @("broad quarantine candidate", "refused") -Action {
        & $testPreflight -PreflightPath (Join-Path $invalidRoot "transition_residue_preflight.broad_quarantine.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-outside-repo-quarantine-candidate" -RequiredFragments @("outside-repo quarantine candidate", "refused") -Action {
        & $testPreflight -PreflightPath (Join-Path $invalidRoot "transition_residue_preflight.outside_repo_quarantine.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL transition residue preflight harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Transition residue preflight tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All transition residue preflight tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
