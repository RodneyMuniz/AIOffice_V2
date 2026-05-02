[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MatrixPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13MeaningfulQaSignoff.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13MeaningfulQaSignoffEvidenceMatrix"]

$result = & $validate -MatrixPath $MatrixPath
Write-Output ("VALID: R13 meaningful QA signoff evidence matrix '{0}', source signoff '{1}', aggregate verdict '{2}', evidence rows {3}." -f $result.MatrixId, $result.SourceSignoffRef, $result.AggregateVerdict, $result.EvidenceRowCount)
