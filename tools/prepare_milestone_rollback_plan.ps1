[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RollbackPlanRequestPath,
    [Parameter(Mandatory = $true)]
    [string]$BaselineBindingPath,
    [Parameter(Mandatory = $true)]
    [string]$RollbackPlanPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-MilestoneRollbackPlan -RollbackPlanRequestPath $RollbackPlanRequestPath -BaselineBindingPath $BaselineBindingPath -RollbackPlanPath $RollbackPlanPath
    Write-Output ("PREPARED: governed rollback plan '{0}' at '{1}'." -f $result.Validation.RollbackPlanId, $result.RollbackPlanPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
