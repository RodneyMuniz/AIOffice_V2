[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProcedurePath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R10TwoPhaseFinalHeadSupport.psm1") -Force -PassThru
$testR10TwoPhaseFinalHeadSupport = $module.ExportedCommands["Test-R10TwoPhaseFinalHeadSupportContract"]

$validation = & $testR10TwoPhaseFinalHeadSupport -ProcedurePath $ProcedurePath
Write-Output ("VALID: R10 two-phase final-head support procedure '{0}' for branch '{1}' consumes external run '{2}', bundle verdict '{3}', QA verdict '{4}', and requires post-push final-head support: {5}." -f $validation.ProcedureId, $validation.Branch, $validation.ExternalRunId, $validation.BundleVerdict, $validation.QaVerdict, $validation.PostPushFinalHeadSupportRequired)
