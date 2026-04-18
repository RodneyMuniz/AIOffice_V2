[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketRecordPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "PacketRecordStorage.psm1"
Import-Module $modulePath -Force

try {
    $result = Test-PacketRecordContract -PacketRecordPath $PacketRecordPath
    Write-Output ("VALID: packet '{0}' at '{1}'." -f $result.PacketId, $result.PacketRecordPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
