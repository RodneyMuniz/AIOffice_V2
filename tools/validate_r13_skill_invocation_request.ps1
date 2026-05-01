[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath,
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13SkillInvocation.psm1") -Force -PassThru
$testRequest = $module.ExportedCommands["Test-R13SkillInvocationRequest"]

$validation = & $testRequest -RequestPath $RequestPath -RegistryPath $RegistryPath
Write-Output ("VALID: R13 skill invocation request '{0}' skill '{1}' version '{2}', mode '{3}', command count {4}, input ref count {5}, expected result '{6}'." -f $validation.InvocationId, $validation.SkillId, $validation.SkillVersion, $validation.InvocationMode, $validation.CommandCount, $validation.InputRefCount, $validation.ExpectedResultRef)
