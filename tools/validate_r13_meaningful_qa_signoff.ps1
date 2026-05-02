[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SignoffPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13MeaningfulQaSignoff.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13MeaningfulQaSignoff"]

$result = & $validate -SignoffPath $SignoffPath
Write-Output ("VALID: R13 meaningful QA signoff '{0}', decision '{1}', aggregate verdict '{2}', scope '{3}', evidence rows {4}, residual risks {5}." -f $result.SignoffId, $result.SignoffDecision, $result.AggregateVerdict, $result.SignoffScope, $result.EvidenceRowCount, $result.ResidualRiskCount)
