[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DrillResultPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneRollbackDrill.psm1"
Import-Module $modulePath -Force

try {
    $validation = Test-MilestoneRollbackDrillResultContract -DrillResultPath $DrillResultPath
    Write-Output ("VALID: rollback drill '{0}' completed safely in disposable environment '{1}'." -f $validation.RollbackDrillId, $validation.EnvironmentRoot)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
