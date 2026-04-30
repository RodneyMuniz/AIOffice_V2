[CmdletBinding()]
param(
    [string]$MockInputPath,
    [string]$OutputRoot,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "invoke_external_runner_github_actions.ps1"
& $scriptPath -Mode "watch" -MockInputPath $MockInputPath -OutputRoot $OutputRoot -OutputPath $OutputPath
