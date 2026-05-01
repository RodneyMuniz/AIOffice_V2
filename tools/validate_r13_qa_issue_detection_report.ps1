[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ReportPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaIssueDetector.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R13QaIssueDetectionReport"]

$validation = & $testReport -ReportPath $ReportPath
Write-Output ("VALID: R13 QA issue detection report '{0}' has aggregate verdict '{1}' with {2} issue(s), {3} blocking issue(s), and {4} evidence ref(s)." -f $validation.ReportId, $validation.AggregateVerdict, $validation.IssueCount, $validation.BlockingIssueCount, $validation.EvidenceRefCount)
