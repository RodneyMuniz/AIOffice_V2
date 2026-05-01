[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResultPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaFailureFixCycle.psm1") -Force -PassThru
$testResult = $module.ExportedCommands["Test-R13FixExecutionResult"]

$validation = & $testResult -ResultPath $ResultPath
Write-Output ("VALID: R13 fix execution result '{0}' selected fix item '{1}', source issue '{2}', issue type '{3}', aggregate verdict '{4}', and {5} changed file(s)." -f $validation.ExecutionResultId, $validation.SelectedFixItemId, $validation.SelectedSourceIssueId, $validation.SelectedIssueType, $validation.AggregateVerdict, $validation.ChangedFileCount)
