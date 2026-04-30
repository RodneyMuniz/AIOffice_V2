[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("from_local_artifact_zip", "from_extracted_artifact_directory", "from_github_artifact_metadata", "validate_only")]
    [string]$Mode,
    [string]$PacketPath,
    [string]$SourcePath,
    [string]$ExtractionRoot,
    [string]$MetadataPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExternalArtifactEvidence.psm1") -Force -PassThru
$importExternalRunnerArtifactEvidence = $module.ExportedCommands["Import-ExternalRunnerArtifactEvidence"]

$parameters = @{
    Mode = $Mode
}
if (-not [string]::IsNullOrWhiteSpace($PacketPath)) { $parameters["PacketPath"] = $PacketPath }
if (-not [string]::IsNullOrWhiteSpace($SourcePath)) { $parameters["SourcePath"] = $SourcePath }
if (-not [string]::IsNullOrWhiteSpace($ExtractionRoot)) { $parameters["ExtractionRoot"] = $ExtractionRoot }
if (-not [string]::IsNullOrWhiteSpace($MetadataPath)) { $parameters["MetadataPath"] = $MetadataPath }
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) { $parameters["OutputPath"] = $OutputPath }

$result = & $importExternalRunnerArtifactEvidence @parameters
Write-Output ("VALID: external artifact evidence packet '{0}' from source kind '{1}' has aggregate verdict '{2}' and {3} contained file(s)." -f $result.EvidencePacketId, $result.ArtifactSourceKind, $result.AggregateVerdict, $result.ContainedFileCount)
