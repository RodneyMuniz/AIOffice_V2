[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RollbackPlanPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1"
Import-Module $modulePath -Force

try {
    $validation = Test-MilestoneRollbackPlanContract -RollbackPlanPath $RollbackPlanPath
    Write-Output ("VALID: governed rollback plan '{0}' remains pre-execution for cycle '{1}' baseline '{2}'." -f $validation.RollbackPlanId, $validation.CycleId, $validation.BaselineId)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
