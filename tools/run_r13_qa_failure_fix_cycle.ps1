[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IssueReportPath,
    [Parameter(Mandatory = $true)]
    [string]$FixQueuePath,
    [Parameter(Mandatory = $true)]
    [string]$BoundedFixExecutionPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,
    [string]$FixItemId = ""
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaFailureFixCycle.psm1") -Force -PassThru
$invokeCycle = $module.ExportedCommands["Invoke-R13QaFailureFixCycle"]

try {
    $summary = & $invokeCycle -IssueReportPath $IssueReportPath -FixQueuePath $FixQueuePath -BoundedFixExecutionPath $BoundedFixExecutionPath -OutputRoot $OutputRoot -FixItemId $FixItemId
    Write-Output ("selected fix item: {0}" -f $summary.SelectedFixItemId)
    Write-Output ("selected source issue: {0}" -f $summary.SelectedSourceIssueId)
    Write-Output ("selected issue type: {0}" -f $summary.SelectedIssueType)
    Write-Output ("before issue count: {0}" -f $summary.BeforeIssueCount)
    Write-Output ("after issue count: {0}" -f $summary.AfterIssueCount)
    Write-Output ("comparison verdict: {0}" -f $summary.ComparisonVerdict)
    Write-Output ("aggregate verdict: {0}" -f $summary.AggregateVerdict)

    if ($summary.AggregateVerdict -eq "fixed_pending_external_replay") {
        exit 0
    }

    exit 2
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
