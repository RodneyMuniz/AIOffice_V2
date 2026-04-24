[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RollbackPlanPath,
    [Parameter(Mandatory = $true)]
    [string]$RollbackDrillAuthorizationPath,
    [Parameter(Mandatory = $true)]
    [string]$DrillResultPath,
    [string]$DisposableEnvironmentRoot,
    [string]$DisposableBranchName
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneRollbackDrill.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-MilestoneRollbackDrill -RollbackPlanPath $RollbackPlanPath -RollbackDrillAuthorizationPath $RollbackDrillAuthorizationPath -DrillResultPath $DrillResultPath -DisposableEnvironmentRoot $DisposableEnvironmentRoot -DisposableBranchName $DisposableBranchName
    Write-Output ("DRILLED: rollback drill '{0}' completed safely in disposable environment '{1}'." -f $result.Validation.RollbackDrillId, $result.Validation.EnvironmentRoot)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
