[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerContract.psm1") -Force -PassThru
$testExternalRunnerArtifactManifest = $module.ExportedCommands["Test-ExternalRunnerArtifactManifestContract"]

$validation = & $testExternalRunnerArtifactManifest -ManifestPath $ManifestPath
Write-Output ("VALID: external runner artifact manifest '{0}' records run '{1}', artifact '{2}', {3} contained file(s), and matching requested/observed head and tree." -f $validation.ManifestId, $validation.RunId, $validation.ArtifactName, $validation.ContainedFileCount)
