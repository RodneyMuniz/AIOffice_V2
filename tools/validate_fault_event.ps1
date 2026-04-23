[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$EventPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "FaultManagement.psm1"
Import-Module $modulePath -Force

try {
    $result = Test-FaultManagementEventContract -EventPath $EventPath
    Write-Output ("VALID: fault event '{0}' at '{1}'." -f $result.EventId, $result.EventPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
