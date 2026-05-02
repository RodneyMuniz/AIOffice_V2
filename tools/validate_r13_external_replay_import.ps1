[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ImportPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13ExternalReplayImport"]

$result = & $validate -ImportPath $ImportPath
Write-Output ("VALID: R13 external replay import '{0}', source run '{1}', source artifact '{2}', imported paths {3}, validation results {4}, aggregate verdict '{5}'." -f $result.ImportedArtifactId, $result.SourceRunId, $result.SourceArtifactId, $result.ImportedPathCount, $result.ValidationResultCount, $result.AggregateVerdict)
