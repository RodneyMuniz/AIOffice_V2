[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LedgerPath,
    [string]$OutputRoot = "state/cycle_controller/bootstrap",
    [string]$BootstrapPacketPath,
    [string]$NextActionPacketPath,
    [string]$BootstrapId,
    [string]$NextActionId,
    [string]$PreferredTargetState,
    [string]$ExpectedRepository,
    [string]$ExpectedBranch,
    [string]$ExpectedHeadSha,
    [string]$ExpectedTreeSha,
    [switch]$Overwrite,
    [switch]$AllowOutsideGovernedRoot
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "CycleBootstrap.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$prepare = $module.ExportedCommands["New-CycleBootstrapResume"]

$parameters = @{
    LedgerPath = $LedgerPath
    OutputRoot = $OutputRoot
    Overwrite = $Overwrite
    AllowOutsideGovernedRoot = $AllowOutsideGovernedRoot
}

if (-not [string]::IsNullOrWhiteSpace($BootstrapPacketPath)) { $parameters["BootstrapPacketPath"] = $BootstrapPacketPath }
if (-not [string]::IsNullOrWhiteSpace($NextActionPacketPath)) { $parameters["NextActionPacketPath"] = $NextActionPacketPath }
if (-not [string]::IsNullOrWhiteSpace($BootstrapId)) { $parameters["BootstrapId"] = $BootstrapId }
if (-not [string]::IsNullOrWhiteSpace($NextActionId)) { $parameters["NextActionId"] = $NextActionId }
if (-not [string]::IsNullOrWhiteSpace($PreferredTargetState)) { $parameters["PreferredTargetState"] = $PreferredTargetState }
if (-not [string]::IsNullOrWhiteSpace($ExpectedRepository)) { $parameters["ExpectedRepository"] = $ExpectedRepository }
if (-not [string]::IsNullOrWhiteSpace($ExpectedBranch)) { $parameters["ExpectedBranch"] = $ExpectedBranch }
if (-not [string]::IsNullOrWhiteSpace($ExpectedHeadSha)) { $parameters["ExpectedHeadSha"] = $ExpectedHeadSha }
if (-not [string]::IsNullOrWhiteSpace($ExpectedTreeSha)) { $parameters["ExpectedTreeSha"] = $ExpectedTreeSha }

$result = & $prepare @parameters
$result | ConvertTo-Json -Depth 80
