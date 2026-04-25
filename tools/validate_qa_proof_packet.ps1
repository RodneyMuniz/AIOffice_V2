[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "QaProofPacket.psm1") -Force -PassThru
$testQaProofPacket = $module.ExportedCommands["Test-QaProofPacketContract"]

$validation = & $testQaProofPacket -PacketPath $PacketPath
Write-Output ("VALID: QA proof packet '{0}' for branch '{1}' pins remote head '{2}' with verdict '{3}'." -f $validation.PacketId, $validation.Branch, $validation.RemoteHead, $validation.Verdict)
