[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScorecardPath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16KpiBaselineTargetScorecard.psm1") -Force -PassThru
$testScorecard = $module.ExportedCommands["Test-R16KpiBaselineTargetScorecard"]

try {
    $result = & $testScorecard -ScorecardPath $ScorecardPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R16 KPI baseline target scorecard '{0}' passed with {1} domains, weight sum {2}, current weighted score {3}, target weighted score {4}, active_through={5}, planned_range={6}..{7}; targets are not achieved scores." -f $result.ScorecardId, $result.DomainCount, $result.WeightSum, $result.CurrentWeightedScore, $result.TargetWeightedScore, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 KPI baseline target scorecard failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
