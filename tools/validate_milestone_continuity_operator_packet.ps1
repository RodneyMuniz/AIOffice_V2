[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OperatorPacketPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuityReview.psm1"
Import-Module $modulePath -Force

try {
    $validation = Test-MilestoneContinuityOperatorPacketContract -OperatorPacketPath $OperatorPacketPath
    Write-Output ("VALID: continuity operator packet '{0}' remains advisory for cycle '{1}'." -f $validation.OperatorPacketId, $validation.CycleId)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
