[CmdletBinding()]
param(
    [string]$OutputRoot = "state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations",
    [string[]]$TestIds,
    [string]$CloseoutPlanPath = "governance/R5_PROOF_AND_CLOSEOUT_PLAN.md",
    [switch]$SkipRepoEnforcementWorktreeCheck
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "BoundedProofSuite.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "RepoEnforcement.psm1") -Force

$normalizedTestIds = @()
foreach ($testId in @($TestIds)) {
    foreach ($item in @($testId -split ",")) {
        if (-not [string]::IsNullOrWhiteSpace($item)) {
            $normalizedTestIds += $item.Trim()
        }
    }
}
if ($normalizedTestIds.Count -eq 0) {
    $normalizedTestIds = @(
        "r5-milestone-baseline",
        "r5-restore-gate",
        "r3-work-artifact-contracts",
        "r3-baton-persistence",
        "r5-resume-reentry",
        "r5-repo-enforcement"
    )
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Get-RelativePathIfInsideRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedRepoRoot = (Resolve-Path -LiteralPath $repoRoot).Path
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $fullPath.StartsWith($resolvedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath
    }

    $baseUri = [System.Uri]("{0}{1}" -f $resolvedRepoRoot.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$fullPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

$proofResult = Invoke-BoundedProofSuite -OutputRoot $OutputRoot -TestIds $normalizedTestIds
$summary = Get-Content -LiteralPath $proofResult.SummaryPath -Raw | ConvertFrom-Json
$metaRoot = Join-Path $proofResult.OutputRoot "meta"

$selectedCommand = "powershell -ExecutionPolicy Bypass -File tools\new_r5_recovery_resume_proof_review.ps1 -OutputRoot {0} -TestIds {1}" -f (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot), ($normalizedTestIds -join ",")
if ($SkipRepoEnforcementWorktreeCheck.IsPresent) {
    $selectedCommand += " -SkipRepoEnforcementWorktreeCheck"
}
Write-Utf8File -Path (Join-Path $metaRoot "replayed_command.txt") -Value $selectedCommand

$replaySummaryPath = Join-Path $proofResult.OutputRoot "REPLAY_SUMMARY.md"
$summaryLines = @(
    "# R5 Recovery, Resume, and Repo Enforcement Proof Review Summary",
    "",
    "## Review context",
    ('- Review folder: `' + (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot) + '`'),
    ('- Repo branch at replay start: `' + $summary.repo_branch + '`'),
    ('- Repo HEAD at replay start: `' + $summary.repo_head + '`'),
    ('- Replay command: `' + $selectedCommand + '`'),
    ('- Focused proof runner summary: `' + (Get-RelativePathIfInsideRepo -Path $proofResult.SummaryPath) + '`'),
    ('- Closeout plan: `' + (Get-RelativePathIfInsideRepo -Path (Join-Path $repoRoot $CloseoutPlanPath)) + '`'),
    "",
    "## Commands replayed"
)
foreach ($result in @($summary.results)) {
    $summaryLines += ('- `' + $result.command + '`')
}

$summaryLines += ""
$summaryLines += "## Test output summaries"
foreach ($result in @($summary.results)) {
    $logReference = if ([string]::IsNullOrWhiteSpace($result.log_path_repo_relative)) { $result.log_path } else { $result.log_path_repo_relative }
    $summaryLines += ('- `' + $result.relative_path + '`: ' + $result.status + '. Raw output: `' + $logReference + '`')
}

$summaryLines += ""
$summaryLines += "## Direct R5 facts exercised"
$summaryLines += "- milestone baseline capture is Git-backed, authority-scoped, and refused when the source worktree is dirty or the anchor is not a milestone"
$summaryLines += "- restore gate results authorize or block restore targets without executing restore actions and fail closed on approval, branch, commit, or cleanliness mismatches"
$summaryLines += "- baton persistence now carries operator-controlled resume authority, bounded retry-entry lineage, and manual-review stop semantics without opening automatic resume"
$summaryLines += "- bounded resume re-entry prepares one retry-entry execution bundle only when baton state, lineage, retry capacity, and repo state are valid"
$summaryLines += "- repo enforcement checks bounded proof presence, expected test coverage, replay summary presence, closeout-plan presence, and clean-worktree discipline where required"

$summaryLines += ""
$summaryLines += "## Explicit non-claims preserved"
foreach ($nonClaim in @($summary.non_claims_preserved)) {
    $summaryLines += "- $nonClaim"
}
$summaryLines += "- No restore action is executed by this proof review."
$summaryLines += "- No unattended automatic resume or broader orchestration behavior is proved here."

Write-Utf8File -Path $replaySummaryPath -Value ($summaryLines -join [Environment]::NewLine)

$repoEnforcementParams = @{
    MilestoneId      = "r5"
    ProofSummaryPath = $proofResult.SummaryPath
    ReplaySummaryPath = $replaySummaryPath
    CloseoutPlanPath = (Join-Path $repoRoot $CloseoutPlanPath)
    ExpectedTestIds  = $normalizedTestIds
    OutputRoot       = $proofResult.OutputRoot
    RepositoryRoot   = $repoRoot
}
if (-not $SkipRepoEnforcementWorktreeCheck.IsPresent) {
    $repoEnforcementParams.WorktreeCleanRequired = $true
}

$repoEnforcementResult = Invoke-RepoEnforcementCheck @repoEnforcementParams

$summaryLines += ""
$summaryLines += "## Repo enforcement"
$summaryLines += ('- Result: `' + $repoEnforcementResult.RepoEnforcementResult.decision + '`')
$summaryLines += ('- Enforcement record: `' + (Get-RelativePathIfInsideRepo -Path $repoEnforcementResult.ResultPath) + '`')
$summaryLines += "- This result checks bounded proof presence, expected test coverage, replay-summary presence, closeout-plan presence, and clean-worktree discipline when enabled."

$summaryLines += ""
$summaryLines += "## Replay conclusion"
$summaryLines += "- Bounded R5 recovery, resume, and repo-enforcement foundations are replayable from this repo through the command above."
$summaryLines += "- This replay exercises Git-backed baseline capture, restore-gate authorization, stronger baton continuity, bounded resume re-entry, and repo-enforcement foundations only."
$summaryLines += "- This replay does not prove UI productization, Standard or subproject runtime, rollback execution, unattended automatic resume, or broader orchestration."

Write-Utf8File -Path $replaySummaryPath -Value ($summaryLines -join [Environment]::NewLine)

if ($repoEnforcementResult.RepoEnforcementResult.decision -ne "allow") {
    throw ("R5 proof review repo enforcement blocked. See '{0}'." -f $repoEnforcementResult.ResultPath)
}

Write-Output ("PASS: R5 recovery, resume, and repo-enforcement proof review created at '{0}'." -f $proofResult.OutputRoot)
