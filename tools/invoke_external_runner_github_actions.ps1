[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("check_dependencies", "dispatch", "watch", "capture", "summarize", "prepare_manual_dispatch_instructions")]
    [string]$Mode,
    [string]$RequestPath,
    [string]$OutputRoot,
    [string]$MockInputPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerGitHubActions.psm1") -Force -PassThru
$invokeExternalRunnerGitHubActions = $module.ExportedCommands["Invoke-ExternalRunnerGitHubActions"]

$parameters = @{
    Mode = $Mode
}
if (-not [string]::IsNullOrWhiteSpace($RequestPath)) { $parameters["RequestPath"] = $RequestPath }
if (-not [string]::IsNullOrWhiteSpace($OutputRoot)) { $parameters["OutputRoot"] = $OutputRoot }
if (-not [string]::IsNullOrWhiteSpace($MockInputPath)) { $parameters["MockInputPath"] = $MockInputPath }
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) { $parameters["OutputPath"] = $OutputPath }

$result = & $invokeExternalRunnerGitHubActions @parameters
Write-Output ("VALID: GitHub Actions external runner mode '{0}' returned packet mode '{1}'." -f $Mode, $result.Mode)
