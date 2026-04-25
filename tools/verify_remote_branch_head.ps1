[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Branch,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$RepositoryName = "AIOffice_V2",
    [string]$RemoteName = "origin"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "RemoteHeadVerification.psm1") -Force -PassThru
$invokeRemoteHeadVerification = $module.ExportedCommands["Invoke-RemoteHeadVerification"]
$testRemoteHeadVerification = $module.ExportedCommands["Test-RemoteHeadVerificationContract"]

$verification = & $invokeRemoteHeadVerification -RepositoryRoot $RepositoryRoot -RepositoryName $RepositoryName -Branch $Branch -OutputPath $OutputPath -RemoteName $RemoteName
$validation = & $testRemoteHeadVerification -ArtifactPath $verification.ArtifactPath

if ($validation.Result -ne "passed") {
    throw ("Remote head verification failed for branch '{0}'. Artifact: '{1}'. Reason: local '{2}' remote '{3}'." -f $validation.Branch, $verification.ArtifactPath, $validation.LocalHead, $validation.RemoteHead)
}

Write-Output ("VALID: remote head verification '{0}' matched branch '{1}' at '{2}'." -f $validation.VerificationId, $validation.Branch, $validation.RemoteHead)
