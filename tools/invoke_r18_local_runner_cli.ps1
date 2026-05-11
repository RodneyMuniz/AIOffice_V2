[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CommandInputPath
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18LocalRunnerCli.psm1"
Import-Module $modulePath -Force

$result = Invoke-R18LocalRunnerCliCommand -RepositoryRoot $repoRoot -CommandInputPath $CommandInputPath
$result | ConvertTo-Json -Depth 100
