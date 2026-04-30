[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [Alias("ReportPath")]
    [string]$ActionableQaReportPath,
    [string]$OutputPath = "",
    [string]$MarkdownOutputPath = "",
    [string]$RecommendedNextAction = "",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ActionableQaFixQueue.psm1") -Force -PassThru
$newFixQueue = $module.ExportedCommands["New-ActionableQaFixQueue"]

& $newFixQueue `
    -ActionableQaReportPath $ActionableQaReportPath `
    -OutputPath $OutputPath `
    -MarkdownOutputPath $MarkdownOutputPath `
    -RecommendedNextAction $RecommendedNextAction `
    -Overwrite:$Overwrite
