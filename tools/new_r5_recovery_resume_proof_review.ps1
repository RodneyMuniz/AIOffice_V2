[CmdletBinding()]
param(
    [string]$OutputRoot = "state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations",
    [string[]]$TestIds
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofModulePath = Join-Path $PSScriptRoot "BoundedProofSuite.psm1"
$repoEnforcementModulePath = Join-Path $PSScriptRoot "RepoEnforcement.psm1"
Import-Module $proofModulePath -Force
$repoEnforcementModule = Import-Module $repoEnforcementModulePath -Force -PassThru
$invokeRepoEnforcementCheck = $repoEnforcementModule.ExportedCommands["Invoke-RepoEnforcementCheck"]
$saveRepoEnforcementResult = $repoEnforcementModule.ExportedCommands["Save-RepoEnforcementResult"]

$defaultTestIds = @(
    "r5-milestone-baseline",
    "r5-restore-gate",
    "r5-baton-continuity",
    "r5-resume-reentry"
)

$normalizedTestIds = [System.Collections.Generic.List[string]]::new()
foreach ($testId in @($TestIds)) {
    foreach ($item in @($testId -split ",")) {
        if (-not [string]::IsNullOrWhiteSpace($item)) {
            $normalizedTestIds.Add($item.Trim())
        }
    }
}
if ($normalizedTestIds.Count -eq 0) {
    foreach ($testId in $defaultTestIds) {
        $normalizedTestIds.Add($testId)
    }
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

function Get-PreReplayStatusLines {
    $statusOutput = & git -C $repoRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status before R5 proof review replay."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

$statusBefore = @(Get-PreReplayStatusLines)
if ($statusBefore.Count -ne 0) {
    throw "R5 proof review requires a clean Git worktree before replay."
}

$proofResult = Invoke-BoundedProofSuite -OutputRoot $OutputRoot -TestIds @($normalizedTestIds)
$summary = Get-Content -LiteralPath $proofResult.SummaryPath -Raw | ConvertFrom-Json
$metaRoot = Join-Path $proofResult.OutputRoot "meta"

$selectedCommand = "powershell -ExecutionPolicy Bypass -File tools\new_r5_recovery_resume_proof_review.ps1 -OutputRoot {0} -TestIds {1}" -f (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot), ($normalizedTestIds -join ",")
Write-Utf8File -Path (Join-Path $metaRoot "replayed_command.txt") -Value $selectedCommand

$summaryLines = @(
    "# R5 Recovery, Resume, And Proof Review Summary",
    "",
    "## Review context",
    ('- Review folder: `' + (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot) + '`'),
    ('- Repo branch at replay start: `' + $summary.repo_branch + '`'),
    ('- Repo HEAD at replay start: `' + $summary.repo_head + '`'),
    ('- Replay command: `' + $selectedCommand + '`'),
    ('- Focused proof runner summary: `' + (Get-RelativePathIfInsideRepo -Path $proofResult.SummaryPath) + '`'),
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
$summaryLines += "- Git-backed milestone baselines remain replayable through bounded repository-congruence, Git-identity, and anchor-evidence validation."
$summaryLines += "- Restore gate results remain bounded to explicit restore-target validation, operator approval, repository binding, and workspace-safety refusal only."
$summaryLines += "- Baton continuity remains bounded to explicit operator-controlled resume authority and follow-up versus manual-review continuity rules only."
$summaryLines += "- Resume re-entry remains bounded to operator-controlled retry-entry preparation only, with restore-gate-required refusal and no unattended automatic resume."
$summaryLines += "- The existing bounded proof runner and existing CI workflow now replay the implemented R5 foundation subset without adding repo-enforcement or closeout automation beyond this review structure."

$summaryLines += ""
$summaryLines += "## Explicit non-claims preserved"
foreach ($nonClaim in @($summary.non_claims_preserved)) {
    $summaryLines += "- $nonClaim"
}
$summaryLines += "- No repo-enforcement or closeout behavior beyond this bounded proof-review structure is proved here."
$summaryLines += "- No full R5 closeout is claimed by this proof review alone."

$summaryLines += ""
$summaryLines += "## Replay conclusion"
$summaryLines += "- Bounded R5 recovery and resume foundations are replayable from this repo through the single proof-review command above."
$summaryLines += "- This replay exercises milestone baseline, restore gate, Baton continuity, and bounded resume re-entry foundations only."
$summaryLines += "- This replay does not prove rollback execution, unattended automatic resume, UI productization, Standard runtime, repo-enforcement beyond this review structure, or broader orchestration."

$replaySummaryPath = Join-Path $proofResult.OutputRoot "REPLAY_SUMMARY.md"
Write-Utf8File -Path $replaySummaryPath -Value ($summaryLines -join [Environment]::NewLine)

$enforcementResult = & $invokeRepoEnforcementCheck -ProofOutputRoot $proofResult.OutputRoot -RequiredProofIds @($normalizedTestIds) -PreReplayStatusLines @($statusBefore)
$enforcementResultPath = & $saveRepoEnforcementResult -EnforcementResult $enforcementResult -OutputRoot $proofResult.OutputRoot
if ($enforcementResult.decision -ne "allow") {
    throw "R5 proof review failed repo enforcement. See '$enforcementResultPath' for details."
}

Write-Output ("PASS: R5 recovery/resume proof review created at '{0}'." -f $proofResult.OutputRoot)
