[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FlowRequestPath,
    [string]$OutputRoot
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "SupervisedAdminHarness.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-SupervisedAdminFlow -FlowRequestPath $FlowRequestPath -OutputRoot $OutputRoot
    if ($result.Decision -eq "allow") {
        Write-Output ("{0}: flow '{1}' packet '{2}' gate result '{3}' action result '{4}' outcome '{5}'." -f $result.Decision.ToUpperInvariant(), $result.FlowRequestId, $result.PacketPath, $result.GateResultPath, $result.ActionResultPath, $result.ActionOutcomePath)
    }
    else {
        Write-Output ("{0}: flow '{1}' packet '{2}' gate result '{3}'." -f $result.Decision.ToUpperInvariant(), $result.FlowRequestId, $result.PacketPath, $result.GateResultPath)
    }
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
