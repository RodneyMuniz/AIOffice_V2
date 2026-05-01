[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13SkillRegistry.psm1") -Force -PassThru
$testRegistry = $module.ExportedCommands["Test-R13SkillRegistry"]

$validation = & $testRegistry -RegistryPath $RegistryPath
Write-Output ("VALID: R13 skill registry '{0}', skill count {1}, required skill count {2}, invocation mode count {3}." -f $validation.RegistryId, $validation.SkillCount, $validation.RequiredSkillCount, $validation.AllowedInvocationModeCount)
