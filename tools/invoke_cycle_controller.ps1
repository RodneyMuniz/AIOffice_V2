[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$CycleId,
    [string]$OutputPath,
    [string]$Repository,
    [string]$Branch,
    [string]$HeadSha,
    [string]$TreeSha,
    [string]$OperatorRequestRef,
    [string]$GovernedRoot = "state/cycle_controller",
    [switch]$Overwrite,
    [switch]$AllowOutsideGovernedRoot,
    [string]$LedgerPath,
    [string]$TargetState,
    [string]$EvidenceRef,
    [string]$Actor,
    [string]$Reason,
    [string]$CyclePlanRef,
    [string]$BaselineRef,
    [string[]]$DispatchRefs,
    [string[]]$ExecutionResultRefs,
    [string[]]$QaRefs,
    [string]$AuditPacketRef,
    [string]$DecisionPacketRef,
    [string[]]$AdditionalEvidenceRefs,
    [string[]]$RefusalReasons
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "CycleController.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$initialize = $module.ExportedCommands["Initialize-CycleControllerLedger"]
$inspect = $module.ExportedCommands["Inspect-CycleControllerLedger"]
$advance = $module.ExportedCommands["Advance-CycleControllerLedger"]
$refuse = $module.ExportedCommands["Refuse-CycleControllerLedger"]

function Assert-CliString {
    param(
        [AllowNull()]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required for cycle controller command '$Command'."
    }
}

$normalizedCommand = $Command.ToLowerInvariant()
$result = switch ($normalizedCommand) {
    "initialize" {
        Assert-CliString -Value $CycleId -Name "CycleId"
        Assert-CliString -Value $OutputPath -Name "OutputPath"
        Assert-CliString -Value $HeadSha -Name "HeadSha"
        Assert-CliString -Value $TreeSha -Name "TreeSha"

        $parameters = @{
            CycleId = $CycleId
            OutputPath = $OutputPath
            HeadSha = $HeadSha
            TreeSha = $TreeSha
            GovernedRoot = $GovernedRoot
            Overwrite = $Overwrite
            AllowOutsideGovernedRoot = $AllowOutsideGovernedRoot
        }
        if (-not [string]::IsNullOrWhiteSpace($Repository)) { $parameters["Repository"] = $Repository }
        if (-not [string]::IsNullOrWhiteSpace($Branch)) { $parameters["Branch"] = $Branch }
        if (-not [string]::IsNullOrWhiteSpace($OperatorRequestRef)) { $parameters["OperatorRequestRef"] = $OperatorRequestRef }

        & $initialize @parameters
        break
    }
    "inspect" {
        Assert-CliString -Value $LedgerPath -Name "LedgerPath"
        & $inspect -LedgerPath $LedgerPath
        break
    }
    "advance" {
        Assert-CliString -Value $LedgerPath -Name "LedgerPath"
        Assert-CliString -Value $TargetState -Name "TargetState"
        Assert-CliString -Value $EvidenceRef -Name "EvidenceRef"
        Assert-CliString -Value $Actor -Name "Actor"
        Assert-CliString -Value $Reason -Name "Reason"

        $parameters = @{
            LedgerPath = $LedgerPath
            TargetState = $TargetState
            EvidenceRef = $EvidenceRef
            Actor = $Actor
            Reason = $Reason
        }
        if (-not [string]::IsNullOrWhiteSpace($OperatorRequestRef)) { $parameters["OperatorRequestRef"] = $OperatorRequestRef }
        if (-not [string]::IsNullOrWhiteSpace($CyclePlanRef)) { $parameters["CyclePlanRef"] = $CyclePlanRef }
        if (-not [string]::IsNullOrWhiteSpace($BaselineRef)) { $parameters["BaselineRef"] = $BaselineRef }
        if ($null -ne $DispatchRefs) { $parameters["DispatchRefs"] = $DispatchRefs }
        if ($null -ne $ExecutionResultRefs) { $parameters["ExecutionResultRefs"] = $ExecutionResultRefs }
        if ($null -ne $QaRefs) { $parameters["QaRefs"] = $QaRefs }
        if (-not [string]::IsNullOrWhiteSpace($AuditPacketRef)) { $parameters["AuditPacketRef"] = $AuditPacketRef }
        if (-not [string]::IsNullOrWhiteSpace($DecisionPacketRef)) { $parameters["DecisionPacketRef"] = $DecisionPacketRef }
        if ($null -ne $AdditionalEvidenceRefs) { $parameters["AdditionalEvidenceRefs"] = $AdditionalEvidenceRefs }

        & $advance @parameters
        break
    }
    "refuse" {
        Assert-CliString -Value $LedgerPath -Name "LedgerPath"
        Assert-CliString -Value $TargetState -Name "TargetState"
        Assert-CliString -Value $EvidenceRef -Name "EvidenceRef"
        Assert-CliString -Value $Actor -Name "Actor"
        Assert-CliString -Value $Reason -Name "Reason"
        if ($null -eq $RefusalReasons -or $RefusalReasons.Count -eq 0) {
            throw "RefusalReasons is required for cycle controller command '$Command'."
        }

        & $refuse -LedgerPath $LedgerPath -TargetState $TargetState -EvidenceRef $EvidenceRef -Actor $Actor -Reason $Reason -RefusalReasons $RefusalReasons
        break
    }
    default {
        throw "Unknown cycle controller command '$Command'."
    }
}

$result | ConvertTo-Json -Depth 80
