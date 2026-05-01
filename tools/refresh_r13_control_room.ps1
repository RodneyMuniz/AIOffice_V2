[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,
    [string]$ExpectedBranch,
    [string]$ExpectedHead,
    [string]$ExpectedTree
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
$refresh = $module.ExportedCommands["Invoke-R13ControlRoomRefresh"]

$result = & $refresh `
    -OutputRoot $OutputRoot `
    -ExpectedBranch $ExpectedBranch `
    -ExpectedHead $ExpectedHead `
    -ExpectedTree $ExpectedTree

Write-Output ("R13 control-room refresh verdict: {0}" -f $result.refresh_verdict)
Write-Output ("Status: {0}" -f $result.generated_status_ref)
Write-Output ("View: {0}" -f $result.generated_view_ref)
if ($result.PSObject.Properties.Name -contains "generated_manifest_ref") {
    Write-Output ("Validation manifest: {0}" -f $result.generated_manifest_ref)
}
if ($result.refresh_verdict -ne "current") {
    Write-Output ("Refusal reasons: {0}" -f (@($result.refusal_reasons) -join " | "))
    exit 1
}

exit 0
