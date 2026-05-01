[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FixQueuePath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [string[]]$FixItemId = @(),
    [ValidateSet("authorization_only", "dry_run")]
    [string]$Mode = "authorization_only",
    [switch]$AllowBroadScope
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $PSScriptRoot "R13BoundedFixExecution.psm1") -Force -PassThru
$newPacket = $module.ExportedCommands["New-R13BoundedFixExecutionPacket"]
$testPacketObject = $module.ExportedCommands["Test-R13BoundedFixExecutionPacketObject"]

try {
    $resolvedOutputPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        [System.IO.Path]::GetFullPath($OutputPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath))
    }

    $rootPath = ([System.IO.Path]::GetFullPath($repoRoot)).TrimEnd("\", "/")
    $packetRef = if ($resolvedOutputPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        $resolvedOutputPath.Substring($rootPath.Length + 1).Replace("\", "/")
    }
    else {
        $OutputPath.Replace("\", "/")
    }

    $packet = & $newPacket -FixQueuePath $FixQueuePath -FixItemId $FixItemId -Mode $Mode -AllowBroadScope:$AllowBroadScope -PacketRef $packetRef

    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = [string]::Join("`n", @($packet | ConvertTo-Json -Depth 100))
    $json = ($json -replace "`r`n", "`n") -replace "`r", "`n"
    $json = $json.TrimEnd() + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedOutputPath, $json, $utf8NoBom)

    $validation = & $testPacketObject -Packet $packet -SourceLabel "R13 bounded fix execution packet export"
    Write-Output ("R13 bounded fix execution packet generated: selected_fix_items={0}; selected_source_issues={1}; target_files={2}; mode={3}; aggregate_verdict={4}" -f $validation.SelectedFixItemCount, $validation.SelectedSourceIssueCount, $validation.TargetFileCount, $validation.ExecutionMode, $validation.AggregateVerdict)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
