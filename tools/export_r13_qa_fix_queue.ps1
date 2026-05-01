[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IssueReportPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [switch]$AllowBroadScope
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $PSScriptRoot "R13QaFixQueue.psm1") -Force -PassThru
$newQueue = $module.ExportedCommands["New-R13QaFixQueue"]
$testQueueObject = $module.ExportedCommands["Test-R13QaFixQueueObject"]

try {
    $resolvedOutputPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        [System.IO.Path]::GetFullPath($OutputPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath))
    }

    $queueRef = if ($resolvedOutputPath.StartsWith(([System.IO.Path]::GetFullPath($repoRoot)).TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        $resolvedOutputPath.Substring(([System.IO.Path]::GetFullPath($repoRoot)).TrimEnd("\", "/").Length + 1).Replace("\", "/")
    }
    else {
        $OutputPath.Replace("\", "/")
    }

    $queue = & $newQueue -IssueReportPath $IssueReportPath -QueueRef $queueRef -AllowBroadScope:$AllowBroadScope
    $validation = & $testQueueObject -Queue $queue -SourceLabel "R13 QA fix queue export"

    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = [string]::Join("`n", @($queue | ConvertTo-Json -Depth 100))
    $json = ($json -replace "`r`n", "`n") -replace "`r", "`n"
    $json = $json.TrimEnd() + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedOutputPath, $json, $utf8NoBom)

    Write-Output ("R13 QA fix queue exported: source_issues={0}; blocking={1}; fix_items={2}; unmapped_blocking={3}; aggregate_verdict={4}; output={5}" -f $validation.SourceIssueCount, $validation.BlockingIssueCount, $validation.FixItemCount, $validation.UnmappedBlockingIssueCount, $validation.AggregateVerdict, $OutputPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
