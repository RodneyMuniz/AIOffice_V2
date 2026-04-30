param(
    [string]$DetectionPath = "",
    [string]$OutputPath = "",
    [string]$ExpectedCurrentHead = "",
    [string[]]$AllowedPriorHeads = @(),
    [string[]]$AllowedNextHeads = @(),
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\RemoteHeadPhaseDetector.psm1") -Force -PassThru
$invoke = $module.ExportedCommands["Invoke-RemoteHeadPhaseDetection"]

& $invoke -DetectionPath $DetectionPath -OutputPath $OutputPath -ExpectedCurrentHead $ExpectedCurrentHead -AllowedPriorHeads $AllowedPriorHeads -AllowedNextHeads $AllowedNextHeads -Overwrite:$Overwrite
