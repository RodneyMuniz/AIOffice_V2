[CmdletBinding()]
param(
    [string]$OutputRoot,
    [string[]]$TestIds,
    [switch]$SkipWorkspaceMutationCheck
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "BoundedProofSuite.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-BoundedProofSuite -OutputRoot $OutputRoot -TestIds $TestIds -SkipWorkspaceMutationCheck:$SkipWorkspaceMutationCheck
    Write-Output ("PASS: bounded proof suite passed. Output root: '{0}'. Summary: '{1}'." -f $result.OutputRoot, $result.SummaryPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
