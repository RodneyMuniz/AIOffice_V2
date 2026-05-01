[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComparisonPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaFailureFixCycle.psm1") -Force -PassThru
$testComparison = $module.ExportedCommands["Test-R13QaBeforeAfterComparison"]

$validation = & $testComparison -ComparisonPath $ComparisonPath
Write-Output ("VALID: R13 QA before/after comparison '{0}' selected issue type '{1}', before issue count {2}, after issue count {3}, resolved issue count {4}, and verdict '{5}'." -f $validation.ComparisonId, $validation.SelectedIssueType, $validation.BeforeIssueCount, $validation.AfterIssueCount, $validation.ResolvedIssueCount, $validation.ComparisonVerdict)
