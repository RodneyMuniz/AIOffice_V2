[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResultPath,
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13SkillInvocation.psm1") -Force -PassThru
$testResult = $module.ExportedCommands["Test-R13SkillInvocationResult"]

$validation = & $testResult -ResultPath $ResultPath -RegistryPath $RegistryPath
Write-Output ("VALID: R13 skill invocation result '{0}' for invocation '{1}' skill '{2}', mode '{3}', command count {4}, passed {5}, failed {6}, blocked {7}, aggregate verdict '{8}'." -f $validation.ResultId, $validation.InvocationId, $validation.SkillId, $validation.InvocationMode, $validation.CommandCount, $validation.PassedCommandCount, $validation.FailedCommandCount, $validation.BlockedCommandCount, $validation.AggregateVerdict)
