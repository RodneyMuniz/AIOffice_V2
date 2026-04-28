[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerConsumingQaSignoff.psm1") -Force -PassThru
$testExternalRunnerConsumingQaSignoff = $module.ExportedCommands["Test-ExternalRunnerConsumingQaSignoffContract"]

$validation = & $testExternalRunnerConsumingQaSignoff -PacketPath $PacketPath
Write-Output ("VALID: external-runner-consuming QA signoff '{0}' for branch '{1}' records verdict '{2}', QA runner '{3}', external run id '{4}', artifact '{5}', and bundle verdict '{6}'." -f $validation.PacketId, $validation.Branch, $validation.Verdict, $validation.QaRunnerKind, $validation.ExternalRunId, $validation.ArtifactName, $validation.BundleVerdict)
