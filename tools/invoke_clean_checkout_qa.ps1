[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Branch,
    [Parameter(Mandatory = $true)]
    [string]$RemoteSha,
    [Parameter(Mandatory = $true)]
    [string[]]$Commands,
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$RepositoryName = "AIOffice_V2",
    [string]$RemoteName = "origin"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "CleanCheckoutQaRunner.psm1") -Force -PassThru
$invokeCleanCheckoutQaRun = $module.ExportedCommands["Invoke-CleanCheckoutQaRun"]

$run = & $invokeCleanCheckoutQaRun -RepositoryRoot $RepositoryRoot -RepositoryName $RepositoryName -Branch $Branch -RemoteSha $RemoteSha -Commands $Commands -OutputRoot $OutputRoot -RemoteName $RemoteName
Write-Output ("VALID: clean-checkout QA packet '{0}' captured verdict '{1}' for remote SHA '{2}'." -f $run.PacketId, $run.Verdict, $run.RemoteHead)
