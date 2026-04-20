[CmdletBinding()]
param(
    [string]$OutputRoot = "state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations",
    [string[]]$TestIds
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $PSScriptRoot "BoundedProofSuite.psm1"
Import-Module $modulePath -Force

$normalizedTestIds = @()
foreach ($testId in @($TestIds)) {
    foreach ($item in @($testId -split ",")) {
        if (-not [string]::IsNullOrWhiteSpace($item)) {
            $normalizedTestIds += $item.Trim()
        }
    }
}
if ($normalizedTestIds.Count -eq 0) {
    $normalizedTestIds = $null
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

$selectedCommand = if ($null -ne $normalizedTestIds -and $normalizedTestIds.Count -gt 0) {
    "powershell -ExecutionPolicy Bypass -File tools\new_r4_hardening_proof_review.ps1 -OutputRoot {0} -TestIds {1}" -f (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot), ($normalizedTestIds -join ",")
}
else {
    "powershell -ExecutionPolicy Bypass -File tools\new_r4_hardening_proof_review.ps1 -OutputRoot {0}" -f (Get-RelativePathIfInsideRepo -Path $proofResult.OutputRoot)
}

Write-Utf8File -Path (Join-Path $metaRoot "replayed_command.txt") -Value $selectedCommand

$summaryLines = @(
    "# R4 Hardening Proof Review Summary",
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
$summaryLines += "## Direct hardening facts exercised"
$summaryLines += "- packet chronology and lifecycle invalid states are rejected by the bounded packet-record tests"
$summaryLines += "- invalid pipeline and protected-scope declarations are rejected by the bounded planning-record and work-artifact tests"
$summaryLines += "- retry ceilings, retry exhaustion, and invalid planning-to-QA-to-baton handoffs are rejected by the bounded QA, baton, and replay tests"
$summaryLines += "- the supervised harness proof path remains bounded and no longer dirties tracked global action-outcome artifacts during replayed allow runs"
$summaryLines += "- the deterministic repo-local proof runner replays the currently claimed bounded suite through one entrypoint"
$summaryLines += "- the source-controlled CI workflow is wired to the same proof runner and is validated by a focused local inspection test"

$summaryLines += ""
$summaryLines += "## Explicit non-claims preserved"
foreach ($nonClaim in @($summary.non_claims_preserved)) {
    $summaryLines += "- $nonClaim"
}

$summaryLines += ""
$summaryLines += "## Replay conclusion"
$summaryLines += "- Bounded R4 hardening evidence is replayable from this repo through the single proof-review command above."
$summaryLines += "- This replay exercises bounded control-kernel hardening and CI foundations only."
$summaryLines += "- This replay does not prove UI productization, Standard or subproject runtime, rollback, automatic resume, or broader orchestration."

$replaySummaryPath = Join-Path $proofResult.OutputRoot "REPLAY_SUMMARY.md"
Write-Utf8File -Path $replaySummaryPath -Value ($summaryLines -join [Environment]::NewLine)

Write-Output ("PASS: R4 hardening proof review created at '{0}'." -f $proofResult.OutputRoot)
