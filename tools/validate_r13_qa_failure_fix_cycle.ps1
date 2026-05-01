[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CyclePath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaFailureFixCycle.psm1") -Force -PassThru
$testCycle = $module.ExportedCommands["Test-R13QaFailureFixCycle"]

$validation = & $testCycle -CyclePath $CyclePath
Write-Output ("VALID: R13 QA failure-fix cycle '{0}' selected fix item '{1}', source issue '{2}', issue type '{3}', before issue count {4}, after issue count {5}, comparison verdict '{6}', and aggregate verdict '{7}'." -f $validation.CycleId, $validation.SelectedFixItemId, $validation.SelectedSourceIssueId, $validation.SelectedIssueType, $validation.BeforeIssueCount, $validation.AfterIssueCount, $validation.ComparisonVerdict, $validation.AggregateVerdict)
