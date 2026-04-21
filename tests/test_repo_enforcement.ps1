$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoEnforcementModule = Import-Module (Join-Path $repoRoot "tools\RepoEnforcement.psm1") -Force -PassThru

$invokeRepoEnforcementCheck = $repoEnforcementModule.ExportedCommands["Invoke-RepoEnforcementCheck"]
$testRepoEnforcementResultContract = $repoEnforcementModule.ExportedCommands["Test-RepoEnforcementResultContract"]

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Initialize-TemporaryGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    & git -C $Path init --initial-branch main 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to initialize temporary Git repository at '$Path'."
    }

    & git -C $Path config user.email "codex@example.com" 2>$null | Out-Null
    & git -C $Path config user.name "Codex Test" 2>$null | Out-Null
    Set-Content -LiteralPath (Join-Path $Path "README.txt") -Value "repo enforcement test" -Encoding UTF8
    & git -C $Path add README.txt 2>$null | Out-Null
    & git -C $Path commit -m "init" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to create initial commit in temporary Git repository at '$Path'."
    }

    return $Path
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-007-repo-enforcement-valid-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $tempRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "repo")
        $proofSummaryPath = Join-Path $tempRoot "bounded-proof-suite-summary.json"
        $replaySummaryPath = Join-Path $tempRoot "REPLAY_SUMMARY.md"
        $closeoutPlanPath = Join-Path $tempRoot "R5_PROOF_AND_CLOSEOUT_PLAN.md"

        Write-JsonDocument -Path $proofSummaryPath -Document ([pscustomobject]@{
                selection_ids = @("r5-milestone-baseline", "r5-restore-gate")
                results       = @(
                    [pscustomobject]@{ id = "r5-milestone-baseline"; status = "passed" },
                    [pscustomobject]@{ id = "r5-restore-gate"; status = "passed" }
                )
                passed_count  = 2
                failed_count  = 0
            })
        Set-Content -LiteralPath $replaySummaryPath -Value "# Replay summary" -Encoding UTF8
        Set-Content -LiteralPath $closeoutPlanPath -Value "# Closeout plan" -Encoding UTF8

        $enforcementResult = & $invokeRepoEnforcementCheck -MilestoneId "r5" -ProofSummaryPath $proofSummaryPath -ReplaySummaryPath $replaySummaryPath -CloseoutPlanPath $closeoutPlanPath -ExpectedTestIds @("r5-milestone-baseline", "r5-restore-gate") -OutputRoot (Join-Path $tempRoot "enforcement-output") -RepositoryRoot $tempRepo -WorktreeCleanRequired
        $enforcementResultCheck = & $testRepoEnforcementResultContract -ResultPath $enforcementResult.ResultPath
        $enforcementResultDocument = Get-JsonDocument -Path $enforcementResult.ResultPath

        Write-Output ("PASS valid repo enforcement: {0} -> {1}" -f $enforcementResultDocument.milestone_id, $enforcementResultDocument.decision)

        if ($enforcementResultCheck.IsValid -ne $true) {
            $failures += "FAIL valid repo enforcement: saved result did not validate."
        }
        if ($enforcementResultDocument.decision -ne "allow") {
            $failures += ("FAIL valid repo enforcement: expected decision 'allow' but found '{0}'." -f $enforcementResultDocument.decision)
        }
        if (@($enforcementResultDocument.block_reasons).Count -ne 0) {
            $failures += "FAIL valid repo enforcement: allow result unexpectedly retained block reasons."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid repo enforcement harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-007-repo-enforcement-blocked-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $tempRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "repo")
        Set-Content -LiteralPath (Join-Path $tempRepo "DIRTY.txt") -Value "dirty" -Encoding UTF8
        $proofSummaryPath = Join-Path $tempRoot "bounded-proof-suite-summary.json"
        $replaySummaryPath = Join-Path $tempRoot "REPLAY_SUMMARY.md"

        Write-JsonDocument -Path $proofSummaryPath -Document ([pscustomobject]@{
                selection_ids = @("r5-milestone-baseline")
                results       = @(
                    [pscustomobject]@{ id = "r5-milestone-baseline"; status = "passed" }
                )
                passed_count  = 1
                failed_count  = 0
            })
        Set-Content -LiteralPath $replaySummaryPath -Value "# Replay summary" -Encoding UTF8

        $enforcementResult = & $invokeRepoEnforcementCheck -MilestoneId "r5" -ProofSummaryPath $proofSummaryPath -ReplaySummaryPath $replaySummaryPath -CloseoutPlanPath (Join-Path $tempRoot "missing-closeout-plan.md") -ExpectedTestIds @("r5-milestone-baseline", "r5-restore-gate") -OutputRoot (Join-Path $tempRoot "enforcement-output") -RepositoryRoot $tempRepo -WorktreeCleanRequired
        $enforcementResultDocument = Get-JsonDocument -Path $enforcementResult.ResultPath

        Write-Output ("PASS blocked repo enforcement: {0} -> {1}" -f $enforcementResultDocument.milestone_id, $enforcementResultDocument.decision)

        if ($enforcementResultDocument.decision -ne "blocked") {
            $failures += ("FAIL blocked repo enforcement: expected decision 'blocked' but found '{0}'." -f $enforcementResultDocument.decision)
        }
        if (@($enforcementResultDocument.block_reasons | Where-Object { $_.code -eq "worktree_dirty" }).Count -eq 0) {
            $failures += "FAIL blocked repo enforcement: missing worktree_dirty block reason."
        }
        if (@($enforcementResultDocument.block_reasons | Where-Object { $_.code -eq "proof_test_missing" }).Count -eq 0) {
            $failures += "FAIL blocked repo enforcement: missing proof_test_missing block reason."
        }
        if (@($enforcementResultDocument.block_reasons | Where-Object { $_.code -eq "closeout_plan_missing" }).Count -eq 0) {
            $failures += "FAIL blocked repo enforcement: missing closeout_plan_missing block reason."
        }

        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL blocked repo enforcement harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Repo enforcement tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All repo enforcement tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
