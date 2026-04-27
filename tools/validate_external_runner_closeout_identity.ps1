[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerArtifactIdentity.psm1") -Force -PassThru
$testExternalRunnerCloseoutIdentity = $module.ExportedCommands["Test-ExternalRunnerCloseoutIdentityContract"]

$validation = & $testExternalRunnerCloseoutIdentity -PacketPath $PacketPath
$proofPosture = if ($validation.IsSuccessfulProofIdentity) { "successful closeout-use identity shape" } else { "completed non-success closeout-use identity shape" }
Write-Output ("VALID: external runner closeout identity '{0}' for branch '{1}' records status '{2}', conclusion '{3}', runner kind '{4}', run id '{5}', artifact '{6}', and {7}." -f $validation.ArtifactId, $validation.Branch, $validation.Status, $validation.Conclusion, $validation.RunnerKind, $validation.RunId, $validation.ArtifactName, $proofPosture)
