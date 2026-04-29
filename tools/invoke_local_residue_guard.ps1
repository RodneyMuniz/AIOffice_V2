[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$RepositoryRoot,
    [string[]]$CandidatePaths,
    [string[]]$AlreadyAbsentPaths,
    [string]$DryRunRef,
    [string]$OutputPath,
    [string]$QuarantineRoot,
    [string]$Actor,
    [string]$Reason,
    [switch]$Authorize,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "LocalResidueGuard.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$scan = $module.ExportedCommands["Invoke-LocalResidueScan"]
$dryRun = $module.ExportedCommands["Invoke-LocalResidueDryRun"]
$quarantine = $module.ExportedCommands["Invoke-LocalResidueQuarantine"]

function Assert-CliString {
    param(
        [AllowNull()]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required for local residue guard command '$Command'."
    }
}

function Assert-CliStringArray {
    param(
        [AllowNull()]
        [string[]]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($null -eq $Value -or $Value.Count -eq 0) {
        throw "$Name is required for local residue guard command '$Command'."
    }
}

$normalizedCommand = $Command.ToLowerInvariant()
$commonParameters = @{}
if (-not [string]::IsNullOrWhiteSpace($RepositoryRoot)) { $commonParameters["RepositoryRoot"] = $RepositoryRoot }
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) { $commonParameters["OutputPath"] = $OutputPath }
if ($Overwrite) { $commonParameters["Overwrite"] = $true }

$result = switch ($normalizedCommand) {
    "scan" {
        & $scan @commonParameters
        break
    }
    "dry-run" {
        Assert-CliStringArray -Value $CandidatePaths -Name "CandidatePaths"
        $parameters = @{} + $commonParameters
        $parameters["CandidatePaths"] = $CandidatePaths
        if ($null -ne $AlreadyAbsentPaths) { $parameters["AlreadyAbsentPaths"] = $AlreadyAbsentPaths }
        & $dryRun @parameters
        break
    }
    "dryrun" {
        Assert-CliStringArray -Value $CandidatePaths -Name "CandidatePaths"
        $parameters = @{} + $commonParameters
        $parameters["CandidatePaths"] = $CandidatePaths
        if ($null -ne $AlreadyAbsentPaths) { $parameters["AlreadyAbsentPaths"] = $AlreadyAbsentPaths }
        & $dryRun @parameters
        break
    }
    "quarantine" {
        Assert-CliStringArray -Value $CandidatePaths -Name "CandidatePaths"
        $parameters = @{} + $commonParameters
        $parameters["CandidatePaths"] = $CandidatePaths
        $parameters["Authorize"] = $Authorize
        if (-not [string]::IsNullOrWhiteSpace($DryRunRef)) { $parameters["DryRunRef"] = $DryRunRef }
        if (-not [string]::IsNullOrWhiteSpace($QuarantineRoot)) { $parameters["QuarantineRoot"] = $QuarantineRoot }
        if (-not [string]::IsNullOrWhiteSpace($Actor)) { $parameters["Actor"] = $Actor }
        if (-not [string]::IsNullOrWhiteSpace($Reason)) { $parameters["Reason"] = $Reason }
        & $quarantine @parameters
        break
    }
    default {
        throw "Unknown local residue guard command '$Command'."
    }
}

$result | ConvertTo-Json -Depth 80
