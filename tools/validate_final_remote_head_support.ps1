[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "FinalRemoteHeadSupport.psm1") -Force -PassThru
$testFinalRemoteHeadSupport = $module.ExportedCommands["Test-FinalRemoteHeadSupportContract"]

$validation = & $testFinalRemoteHeadSupport -PacketPath $PacketPath
Write-Output ("VALID: final remote-head support packet '{0}' records '{1}' for branch '{2}' with status '{3}' and timing '{4}'." -f $validation.PacketId, $validation.VerifiedRemoteHead, $validation.Branch, $validation.Status, $validation.VerificationTiming)
