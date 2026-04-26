[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerArtifactIdentity.psm1") -Force -PassThru
$testExternalRunnerArtifactIdentity = $module.ExportedCommands["Test-ExternalRunnerArtifactIdentityContract"]

$validation = & $testExternalRunnerArtifactIdentity -PacketPath $PacketPath
Write-Output ("VALID: external runner artifact identity '{0}' for branch '{1}' records status '{2}', conclusion '{3}', runner kind '{4}', and run id '{5}'." -f $validation.ArtifactId, $validation.Branch, $validation.Status, $validation.Conclusion, $validation.RunnerKind, $validation.RunId)
