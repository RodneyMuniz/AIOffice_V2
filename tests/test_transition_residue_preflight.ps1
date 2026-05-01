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
$tempRoots = @()

function New-MutatedPreflightFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("transition_residue_preflight_{0}_{1}" -f $Label, [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $document = Get-Content -LiteralPath $SourcePath -Raw | ConvertFrom-Json
    & $Mutation $document
    $targetPath = Join-Path $tempRoot ("{0}.json" -f $Label)
    $document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $targetPath -Encoding UTF8
    $script:tempRoots += $tempRoot
    return $targetPath
}

function Set-QuarantineCandidatePath {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Document.quarantine_candidates = @(
        [pscustomobject]@{
            path = $Path
            dry_run_evidence_ref = "state/fixtures/invalid/residue_guard/dry_run.json"
            authorization_status = "candidate"
            action = "quarantine_dry_run_only"
        }
    )
    $Document.deletion_allowed = $false
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

    $validInRepoCandidatePath = New-MutatedPreflightFixture -SourcePath $cleanPath -Label "valid-in-repo-quarantine-candidate" -Mutation {
        param($Document)
        Set-QuarantineCandidatePath -Document $Document -Path "state/fixtures/valid/residue_guard/dry_run.json"
    }
    & $testPreflight -PreflightPath $validInRepoCandidatePath | Out-Null
    Write-Output "PASS valid in-repo quarantine candidate remains dry-run and non-destructive"
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

    foreach ($case in @(
            [pscustomobject]@{ Label = "invalid-windows-drive-forward-slash-quarantine-candidate"; Path = "C:/outside-repo/residue.tmp" },
            [pscustomobject]@{ Label = "invalid-windows-drive-backslash-quarantine-candidate"; Path = "C:\outside-repo\residue.tmp" },
            [pscustomobject]@{ Label = "invalid-posix-absolute-quarantine-candidate"; Path = "/outside-repo/residue.tmp" },
            [pscustomobject]@{ Label = "invalid-unc-backslash-quarantine-candidate"; Path = "\\server\share\residue.tmp" },
            [pscustomobject]@{ Label = "invalid-unc-forward-slash-quarantine-candidate"; Path = "//server/share/residue.tmp" },
            [pscustomobject]@{ Label = "invalid-relative-traversal-quarantine-candidate"; Path = "../outside-repo/residue.tmp" }
        )) {
        Invoke-ExpectedRefusal -Label $case.Label -RequiredFragments @("outside-repo quarantine candidate", "refused") -Action {
            $fixturePath = New-MutatedPreflightFixture -SourcePath (Join-Path $invalidRoot "transition_residue_preflight.outside_repo_quarantine.invalid.json") -Label $case.Label -Mutation {
                param($Document)
                Set-QuarantineCandidatePath -Document $Document -Path $case.Path
            }
            & $testPreflight -PreflightPath $fixturePath | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL transition residue preflight harness: {0}" -f $_.Exception.Message)
}

foreach ($tempRoot in $tempRoots) {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Transition residue preflight tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All transition residue preflight tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
