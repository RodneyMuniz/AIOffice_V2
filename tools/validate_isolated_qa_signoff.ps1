[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "IsolatedQaSignoff.psm1") -Force -PassThru
$testIsolatedQaSignoff = $module.ExportedCommands["Test-IsolatedQaSignoffContract"]

$validation = & $testIsolatedQaSignoff -PacketPath $PacketPath
Write-Output ("VALID: isolated QA signoff packet '{0}' for '{1}' uses QA role '{2}' with runner kind '{3}' and verdict '{4}'." -f $validation.PacketId, $validation.SourceTask, $validation.QaRoleIdentity, $validation.QaRunnerKind, $validation.Verdict)
