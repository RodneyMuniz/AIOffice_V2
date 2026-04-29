$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\LocalResidueGuard.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru

$scan = $module.ExportedCommands["Invoke-LocalResidueScan"]
$dryRun = $module.ExportedCommands["Invoke-LocalResidueDryRun"]
$quarantine = $module.ExportedCommands["Invoke-LocalResidueQuarantine"]
$testScan = $module.ExportedCommands["Test-LocalResidueScanResultContract"]
$testQuarantine = $module.ExportedCommands["Test-LocalResidueQuarantineResultContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$cliPath = Join-Path $repoRoot "tools\invoke_local_residue_guard.ps1"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r11-local-residue-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$resultRoot = Join-Path $tempRoot "results"
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $RepositoryRoot @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw ("git {0} failed in '{1}': {2}" -f ($Arguments -join " "), $RepositoryRoot, ($output -join "`n"))
    }

    return @($output | ForEach-Object { [string]$_ })
}

function New-TestRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $path = Join-Path $tempRoot $Name
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    & git init $path | Out-Null
    Invoke-Git -RepositoryRoot $path -Arguments @("checkout", "-b", "release/r10-real-external-runner-proof-foundation") | Out-Null
    Invoke-Git -RepositoryRoot $path -Arguments @("config", "user.email", "r11-local-residue@example.invalid") | Out-Null
    Invoke-Git -RepositoryRoot $path -Arguments @("config", "user.name", "R11 Local Residue Test") | Out-Null
    Invoke-Git -RepositoryRoot $path -Arguments @("config", "commit.gpgsign", "false") | Out-Null
    Set-Content -LiteralPath (Join-Path $path "README.md") -Value "tracked baseline" -Encoding UTF8
    Invoke-Git -RepositoryRoot $path -Arguments @("add", "--", "README.md") | Out-Null
    Invoke-Git -RepositoryRoot $path -Arguments @("commit", "-m", "baseline") | Out-Null
    return (Resolve-Path -LiteralPath $path).Path
}

function New-ResultPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    New-Item -ItemType Directory -Path $resultRoot -Force | Out-Null
    return (Join-Path $resultRoot $Name)
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "Test JSON document")
}

function Invoke-CliJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Parameters
    )

    $output = & $cliPath @Parameters
    if ($LASTEXITCODE -ne 0) {
        throw ("local residue CLI failed: {0}" -f ($output -join "`n"))
    }

    return (($output -join "`n") | ConvertFrom-Json)
}

function Assert-Condition {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-HasRefusal {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Fragment,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $joined = (@($Packet.refusal_reasons) -join "`n")
    if ($joined -notlike ("*{0}*" -f $Fragment)) {
        throw ("{0} did not include refusal fragment '{1}'. Actual refusals: {2}" -f $Label, $Fragment, $joined)
    }
}

function Assert-NonClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    foreach ($required in @(
            "no deletion without dry-run and explicit authorization",
            "no tracked-file modification",
            "no local-only residue used as evidence",
            "no destructive rollback",
            "no successor milestone without explicit approval"
        )) {
        if (@($Packet.non_claims) -notcontains $required) {
            throw "$Label is missing required non-claim '$required'."
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
    New-Item -ItemType Directory -Path $resultRoot -Force | Out-Null

    $cleanRepo = New-TestRepo -Name "clean-scan"
    $cleanScanPath = New-ResultPath -Name "clean.scan.json"
    $cleanScan = Invoke-CliJson -Parameters @{
        Command = "scan"
        RepositoryRoot = $cleanRepo
        OutputPath = $cleanScanPath
    }
    & $testScan -ScanResultPath $cleanScanPath | Out-Null
    Assert-Condition -Condition ([bool]$cleanScan.worktree_clean -and -not [bool]$cleanScan.residue_detected -and $cleanScan.residue_policy_decision -eq "allowed") -Message "clean worktree scan did not produce a clean valid scan result."
    Write-Output "PASS valid: clean worktree scan produces clean valid scan result."
    $validPassed += 1

    $dirtyRepo = New-TestRepo -Name "dirty-untracked-scan"
    New-Item -ItemType Directory -Path (Join-Path $dirtyRepo "residue") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $dirtyRepo "residue\only.txt") -Value "local-only" -Encoding UTF8
    $dirtyScan = & $scan -RepositoryRoot $dirtyRepo
    Assert-Condition -Condition ([bool]$dirtyScan.untracked_residue_detected -and $dirtyScan.residue_policy_decision -eq "refused") -Message "synthetic untracked residue was not detected and refused by scan."
    Assert-HasRefusal -Packet $dirtyScan -Fragment "explicit dry-run and quarantine authorization" -Label "dirty scan"
    Assert-Condition -Condition (-not [bool]$dirtyScan.entries[0].evidence_allowed -and $dirtyScan.entries[0].evidence_status -eq "not_evidence") -Message "local-only residue was marked as evidence."
    Write-Output "PASS valid: synthetic untracked residue is detected and never marked as evidence."
    $validPassed += 1

    $dryRunRepo = New-TestRepo -Name "dry-run-exact"
    Set-Content -LiteralPath (Join-Path $dryRunRepo "residue.txt") -Value "local-only" -Encoding UTF8
    $dryRunPath = New-ResultPath -Name "exact.dry-run.json"
    $dryRunResult = Invoke-CliJson -Parameters @{
        Command = "dry-run"
        RepositoryRoot = $dryRunRepo
        CandidatePaths = @("residue.txt")
        OutputPath = $dryRunPath
    }
    & $testScan -ScanResultPath $dryRunPath | Out-Null
    Assert-Condition -Condition ([bool]$dryRunResult.quarantine_eligible -and @($dryRunResult.refusal_reasons).Count -eq 0 -and @($dryRunResult.candidate_paths)[0] -eq "residue.txt") -Message "exact untracked residue dry-run did not succeed."
    $wrongDryRun = & $dryRun -RepositoryRoot $dryRunRepo -CandidatePaths @("residue-other.txt")
    Assert-HasRefusal -Packet $wrongDryRun -Fragment "outside the expected quarantine candidate list" -Label "wrong dry-run"
    Write-Output "PASS valid: untracked residue dry-run succeeds only for the exact candidate path."
    $validPassed += 1

    $quarantineRepo = New-TestRepo -Name "authorized-quarantine"
    Set-Content -LiteralPath (Join-Path $quarantineRepo "quarantine-me.txt") -Value "move me" -Encoding UTF8
    $quarantineDryRunPath = New-ResultPath -Name "quarantine.dry-run.json"
    & $dryRun -RepositoryRoot $quarantineRepo -CandidatePaths @("quarantine-me.txt") -OutputPath $quarantineDryRunPath | Out-Null
    $quarantineOutputPath = New-ResultPath -Name "quarantine.result.json"
    $quarantineRoot = Join-Path $tempRoot "outside-quarantine"
    $quarantineResult = Invoke-CliJson -Parameters @{
        Command = "quarantine"
        RepositoryRoot = $quarantineRepo
        CandidatePaths = @("quarantine-me.txt")
        DryRunRef = $quarantineDryRunPath
        OutputPath = $quarantineOutputPath
        QuarantineRoot = $quarantineRoot
        Authorize = $true
    }
    & $testQuarantine -QuarantineResultPath $quarantineOutputPath | Out-Null
    $movedPath = [string]$quarantineResult.moved_items[0].quarantine_path
    Assert-Condition -Condition ((@($quarantineResult.moved_items).Count -eq 1) -and -not (Test-Path -LiteralPath (Join-Path $quarantineRepo "quarantine-me.txt")) -and (Test-Path -LiteralPath $movedPath) -and -not $movedPath.StartsWith($quarantineRepo, [System.StringComparison]::OrdinalIgnoreCase)) -Message "authorized quarantine did not move exactly one untracked path outside the repo."
    Assert-Condition -Condition ($quarantineResult.moved_items[0].evidence_status -eq "not_evidence" -and $quarantineResult.moved_items[0].repo_truth_status -eq "not_repo_truth") -Message "quarantine result treated local-only residue as evidence or repo truth."
    Write-Output "PASS valid: authorized quarantine moves only the exact untracked candidate outside the repo and validates."
    $validPassed += 1

    $dirtyTrackedRepo = New-TestRepo -Name "dirty-tracked"
    Set-Content -LiteralPath (Join-Path $dirtyTrackedRepo "README.md") -Value "dirty tracked change" -Encoding UTF8
    $dirtyTrackedScan = & $scan -RepositoryRoot $dirtyTrackedRepo
    Assert-Condition -Condition ([bool]$dirtyTrackedScan.tracked_changes_detected -and $dirtyTrackedScan.residue_policy_decision -eq "refused") -Message "dirty tracked file did not cause refusal."
    Assert-HasRefusal -Packet $dirtyTrackedScan -Fragment "tracked changes detected" -Label "dirty tracked scan"
    Write-Output "PASS invalid: dirty tracked file causes refusal."
    $invalidRejected += 1

    $trackedCandidateRepo = New-TestRepo -Name "tracked-candidate"
    $trackedCandidate = & $dryRun -RepositoryRoot $trackedCandidateRepo -CandidatePaths @("README.md")
    Assert-HasRefusal -Packet $trackedCandidate -Fragment "tracked or contains tracked files" -Label "tracked candidate"
    Write-Output "PASS invalid: tracked file candidate cannot be quarantined."
    $invalidRejected += 1

    $missingRepo = New-TestRepo -Name "missing-candidate"
    $missingCandidate = & $dryRun -RepositoryRoot $missingRepo -CandidatePaths @("missing.txt")
    Assert-HasRefusal -Packet $missingCandidate -Fragment "missing and was not explicitly marked as already absent" -Label "missing candidate"
    $alreadyAbsentCandidate = & $dryRun -RepositoryRoot $missingRepo -CandidatePaths @("missing.txt") -AlreadyAbsentPaths @("missing.txt")
    Assert-Condition -Condition (@($alreadyAbsentCandidate.refusal_reasons).Count -eq 0 -and [bool]$alreadyAbsentCandidate.candidate_path_results[0].already_absent) -Message "already-absent candidate was not accepted as explicitly absent."
    Write-Output "PASS invalid/valid: missing candidate refuses unless explicitly marked already absent."
    $invalidRejected += 1
    $validPassed += 1

    $outsideRepo = New-TestRepo -Name "outside-candidate"
    $outsidePath = Join-Path $tempRoot "outside-file.txt"
    Set-Content -LiteralPath $outsidePath -Value "outside" -Encoding UTF8
    $outsideCandidate = & $dryRun -RepositoryRoot $outsideRepo -CandidatePaths @($outsidePath)
    Assert-HasRefusal -Packet $outsideCandidate -Fragment "escapes the repository root" -Label "outside candidate"
    Write-Output "PASS invalid: path outside repository refuses."
    $invalidRejected += 1

    $broadRepo = New-TestRepo -Name "broad-paths"
    $rootCandidate = & $dryRun -RepositoryRoot $broadRepo -CandidatePaths @(".")
    Assert-HasRefusal -Packet $rootCandidate -Fragment "repository root" -Label "repo root candidate"
    $gitCandidate = & $dryRun -RepositoryRoot $broadRepo -CandidatePaths @(".git")
    Assert-HasRefusal -Packet $gitCandidate -Fragment "targets .git" -Label ".git candidate"
    $broadCandidate = & $dryRun -RepositoryRoot $broadRepo -CandidatePaths @("governance")
    Assert-HasRefusal -Packet $broadCandidate -Fragment "broad root-level path" -Label "broad governance candidate"
    Write-Output "PASS invalid: repo root, .git, and broad root-level paths refuse."
    $invalidRejected += 3

    $noDryRunRepo = New-TestRepo -Name "no-dry-run"
    Set-Content -LiteralPath (Join-Path $noDryRunRepo "residue.txt") -Value "local-only" -Encoding UTF8
    Invoke-ExpectedRefusal -Label "quarantine-without-dry-run" -RequiredFragments @("dry_run_ref", "authorized") -Action {
        & $quarantine -RepositoryRoot $noDryRunRepo -CandidatePaths @("residue.txt") -Authorize | Out-Null
    }

    $noAuthRepo = New-TestRepo -Name "no-authorization"
    Set-Content -LiteralPath (Join-Path $noAuthRepo "residue.txt") -Value "local-only" -Encoding UTF8
    $noAuthDryRun = New-ResultPath -Name "no-auth.dry-run.json"
    & $dryRun -RepositoryRoot $noAuthRepo -CandidatePaths @("residue.txt") -OutputPath $noAuthDryRun | Out-Null
    $noAuthResult = & $quarantine -RepositoryRoot $noAuthRepo -CandidatePaths @("residue.txt") -DryRunRef $noAuthDryRun
    Assert-HasRefusal -Packet $noAuthResult -Fragment "explicit quarantine authorization is required" -Label "no authorization quarantine"
    Assert-Condition -Condition (Test-Path -LiteralPath (Join-Path $noAuthRepo "residue.txt")) -Message "quarantine without authorization moved a file."
    Write-Output "PASS invalid: quarantine without explicit authorization refuses and moves nothing."
    $invalidRejected += 1

    $ambiguousRepo = New-TestRepo -Name "ambiguous-status"
    $ambiguousScan = & $scan -RepositoryRoot $ambiguousRepo -StatusLinesOverride @("ZZ strange")
    Assert-HasRefusal -Packet $ambiguousScan -Fragment "ambiguous status entry" -Label "ambiguous scan"
    Assert-Condition -Condition ($ambiguousScan.entries[0].classification -eq "ignored_or_unknown") -Message "ambiguous status was not classified as ignored_or_unknown."
    Write-Output "PASS invalid: ambiguous status classification refuses."
    $invalidRejected += 1

    Assert-NonClaims -Packet $dirtyScan -Label "dirty scan"
    Assert-NonClaims -Packet $quarantineResult -Label "quarantine result"
    Write-Output "PASS valid: generated result packets preserve required non-claims."
    $validPassed += 1

    foreach ($validFixture in @(
            "state\fixtures\valid\cycle_controller\local_residue_scan_result.clean.valid.json",
            "state\fixtures\valid\cycle_controller\local_residue_scan_result.dirty.valid.json"
        )) {
        & $testScan -ScanResultPath (Join-Path $repoRoot $validFixture) | Out-Null
    }
    & $testQuarantine -QuarantineResultPath (Join-Path $repoRoot "state\fixtures\valid\cycle_controller\local_residue_quarantine_result.valid.json") | Out-Null
    Write-Output "PASS valid: checked-in local residue fixtures validate."
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-scan-residue-as-evidence" -RequiredFragments @("never mark local-only residue as evidence") -Action {
        & $testScan -ScanResultPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\local_residue_scan_result.local_residue_as_evidence.invalid.json") | Out-Null
    }
    Invoke-ExpectedRefusal -Label "invalid-scan-missing-non-claim" -RequiredFragments @("non_claims", "no deletion without dry-run") -Action {
        & $testScan -ScanResultPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\local_residue_scan_result.missing_non_claim.invalid.json") | Out-Null
    }
    Invoke-ExpectedRefusal -Label "invalid-quarantine-authorized-without-dry-run" -RequiredFragments @("dry_run_ref", "authorized") -Action {
        & $testQuarantine -QuarantineResultPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\local_residue_quarantine_result.authorized_without_dry_run.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL local residue guard harness: {0}" -f $_.Exception.Message)
}
finally {
    $tempRootFull = [System.IO.Path]::GetFullPath($tempRoot)
    $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    if ($tempRootFull.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $tempRootFull)) {
        Remove-Item -LiteralPath $tempRootFull -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Local residue guard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All local residue guard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
