[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ScopePath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [switch]$AllowRepoRootScan,
    [switch]$FixtureMode,
    [string]$ExpectedBranch = "",
    [string]$ExpectedHead = "",
    [string]$ExpectedTree = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $PSScriptRoot "R13QaIssueDetector.psm1") -Force -PassThru
$invokeDetector = $module.ExportedCommands["Invoke-R13QaIssueDetector"]

try {
    $report = & $invokeDetector -ScopePath $ScopePath -AllowRepoRootScan:$AllowRepoRootScan -FixtureMode:$FixtureMode -ExpectedBranch $ExpectedBranch -ExpectedHead $ExpectedHead -ExpectedTree $ExpectedTree
    $resolvedOutputPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        [System.IO.Path]::GetFullPath($OutputPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath))
    }

    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = [string]::Join("`n", @($report | ConvertTo-Json -Depth 100))
    $json = ($json -replace "`r`n", "`n") -replace "`r", "`n"
    $json = $json.TrimEnd() + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedOutputPath, $json, $utf8NoBom)
    Write-Output ("R13 QA issue detector completed: verdict={0}; issues={1}; blocking={2}; output={3}" -f $report.aggregate_verdict, $report.summary.total_issue_count, $report.summary.blocking_issue_count, $OutputPath)

    if ($report.aggregate_verdict -eq "blocked") {
        exit 2
    }

    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
