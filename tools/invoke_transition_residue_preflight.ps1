param(
    [Parameter(Mandatory = $true)]
    [string]$TransitionFrom,
    [Parameter(Mandatory = $true)]
    [string]$TransitionTo,
    [string[]]$ExpectedUntrackedPathPatterns = @(),
    [string]$OutputPath = "",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "TransitionResiduePreflight.psm1") -Force -PassThru
$newPreflight = $module.ExportedCommands["New-TransitionResiduePreflight"]

& $newPreflight -TransitionFrom $TransitionFrom -TransitionTo $TransitionTo -ExpectedUntrackedPathPatterns $ExpectedUntrackedPathPatterns -OutputPath $OutputPath -Overwrite:$Overwrite
