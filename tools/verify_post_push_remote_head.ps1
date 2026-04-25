[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Branch,
    [Parameter(Mandatory = $true)]
    [string]$ExpectedPushedCommit,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$RepositoryName = "AIOffice_V2",
    [string]$RemoteName = "origin"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "PostPushVerification.psm1") -Force -PassThru
$invokePostPushVerification = $module.ExportedCommands["Invoke-PostPushVerification"]
$assertPostPushVerificationSatisfied = $module.ExportedCommands["Assert-PostPushVerificationSatisfied"]

$verification = & $invokePostPushVerification -RepositoryRoot $RepositoryRoot -RepositoryName $RepositoryName -Branch $Branch -ExpectedPushedCommit $ExpectedPushedCommit -OutputPath $OutputPath -RemoteName $RemoteName
$validation = & $assertPostPushVerificationSatisfied -ArtifactPath $verification.ArtifactPath -ExpectedPushedCommit $ExpectedPushedCommit

Write-Output ("VALID: post-push verification '{0}' confirmed branch '{1}' landed remote SHA '{2}'." -f $validation.VerificationId, $validation.Branch, $validation.ActualRemoteHead)
