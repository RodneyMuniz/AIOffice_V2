[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScorecardPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ValueScorecard.psm1") -Force -PassThru
$testValueScorecard = $module.ExportedCommands["Test-ValueScorecardContract"]

$validation = & $testValueScorecard -ScorecardPath $ScorecardPath

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedInput = Resolve-Path -LiteralPath $ScorecardPath
    $parent = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Copy-Item -LiteralPath $resolvedInput.Path -Destination $OutputPath -Force
}

Write-Output ("VALID: R12 value scorecard '{0}' baseline {1}, target {2}, proved {3}, uplift {4}, all gates proved: {5}." -f $validation.Milestone, $validation.CorrectedBaseline, $validation.CorrectedTarget, $validation.CorrectedProved, $validation.CorrectedUplift, $validation.AllValueGatesProved)
