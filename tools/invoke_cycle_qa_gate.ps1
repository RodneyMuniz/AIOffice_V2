[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$DispatchPath,
    [string]$DevResultPath,
    [string]$OutputPath,
    [string]$SignoffPath,
    [string]$QaActorIdentity,
    [string]$QaActorKind,
    [string]$QaAuthorityType,
    [string]$QaIndependenceBoundary,
    [string]$QaVerdict,
    [string[]]$QaFindings,
    [string[]]$RequiredFollowups,
    [string[]]$SourceEvidenceRefs,
    [string[]]$RefusalReasons,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "CycleQaGate.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$newSignoff = $module.ExportedCommands["New-CycleQaSignoffPacket"]
$inspectSignoff = $module.ExportedCommands["Inspect-CycleQaSignoffPacket"]

function Assert-CliString {
    param(
        [AllowNull()]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required for Cycle QA gate command '$Command'."
    }
}

$normalizedCommand = $Command.ToLowerInvariant()
$result = switch ($normalizedCommand) {
    "signoff" {
        Assert-CliString -Value $DispatchPath -Name "DispatchPath"
        Assert-CliString -Value $DevResultPath -Name "DevResultPath"
        Assert-CliString -Value $OutputPath -Name "OutputPath"
        Assert-CliString -Value $QaActorIdentity -Name "QaActorIdentity"
        Assert-CliString -Value $QaActorKind -Name "QaActorKind"
        Assert-CliString -Value $QaAuthorityType -Name "QaAuthorityType"

        $parameters = @{
            DispatchPath = $DispatchPath
            DevResultPath = $DevResultPath
            OutputPath = $OutputPath
            QaActorIdentity = $QaActorIdentity
            QaActorKind = $QaActorKind
            QaAuthorityType = $QaAuthorityType
            Overwrite = $Overwrite
        }
        if (-not [string]::IsNullOrWhiteSpace($QaIndependenceBoundary)) { $parameters["QaIndependenceBoundary"] = $QaIndependenceBoundary }
        if (-not [string]::IsNullOrWhiteSpace($QaVerdict)) { $parameters["QaVerdict"] = $QaVerdict }
        if ($null -ne $QaFindings) { $parameters["QaFindings"] = $QaFindings }
        if ($null -ne $RequiredFollowups) { $parameters["RequiredFollowups"] = $RequiredFollowups }
        if ($null -ne $SourceEvidenceRefs) { $parameters["SourceEvidenceRefs"] = $SourceEvidenceRefs }
        if ($null -ne $RefusalReasons) { $parameters["RefusalReasons"] = $RefusalReasons }

        & $newSignoff @parameters
        break
    }
    "inspect-signoff" {
        Assert-CliString -Value $SignoffPath -Name "SignoffPath"
        if ([string]::IsNullOrWhiteSpace($DispatchPath) -and [string]::IsNullOrWhiteSpace($DevResultPath)) {
            & $inspectSignoff -SignoffPath $SignoffPath
        }
        else {
            Assert-CliString -Value $DispatchPath -Name "DispatchPath"
            Assert-CliString -Value $DevResultPath -Name "DevResultPath"
            & $inspectSignoff -SignoffPath $SignoffPath -DispatchPath $DispatchPath -DevResultPath $DevResultPath
        }
        break
    }
    default {
        throw "Unknown Cycle QA gate command '$Command'."
    }
}

$result | ConvertTo-Json -Depth 100
