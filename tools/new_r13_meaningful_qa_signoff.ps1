[CmdletBinding()]
param(
    [string]$SignoffPath = "state\signoff\r13_meaningful_qa_signoff\r13_012_signoff.json",
    [string]$MatrixPath = "state\signoff\r13_meaningful_qa_signoff\r13_012_evidence_matrix.json",
    [string]$ManifestPath = "state\signoff\r13_meaningful_qa_signoff\validation_manifest.md"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13MeaningfulQaSignoff.psm1") -Force -PassThru
$generate = $module.ExportedCommands["New-R13MeaningfulQaSignoffArtifacts"]

$result = & $generate `
    -SignoffPath $SignoffPath `
    -MatrixPath $MatrixPath `
    -ManifestPath $ManifestPath

Write-Output ("R13 meaningful QA signoff decision: {0}" -f $result.SignoffDecision)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Scope: {0}" -f $result.SignoffScope)
Write-Output ("Signoff: {0}" -f $result.SignoffPath)
Write-Output ("Evidence matrix: {0}" -f $result.MatrixPath)
Write-Output ("Validation manifest: {0}" -f $result.ManifestPath)
