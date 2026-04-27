[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BundlePath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalProofArtifactBundle.psm1") -Force -PassThru
$testExternalProofArtifactBundle = $module.ExportedCommands["Test-ExternalProofArtifactBundleContract"]

$validation = & $testExternalProofArtifactBundle -BundlePath $BundlePath
$proofPosture = if ($validation.IsPassingBundleShape) { "passing bundle shape" } else { "non-passing bundle shape" }
Write-Output ("VALID: external proof artifact bundle '{0}' for branch '{1}' records runner kind '{2}', run id '{3}', artifact '{4}', {5} commands, aggregate verdict '{6}', and {7}." -f $validation.BundleId, $validation.Branch, $validation.RunnerKind, $validation.RunId, $validation.ArtifactName, $validation.CommandCount, $validation.AggregateVerdict, $proofPosture)
