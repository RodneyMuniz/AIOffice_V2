[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$LedgerPath,
    [string]$CycleId,
    [string]$OutputPath,
    [string]$BaselineRef,
    [string]$OperatorApprovalRef,
    [string]$TaskPacketPath,
    [string]$TargetExecutor = "codex",
    [string[]]$AllowedTools,
    [string[]]$ForbiddenTools,
    [string]$DispatchPath,
    [string]$ResultPath,
    [string]$ExecutorIdentity,
    [string]$ExecutorKind,
    [string]$Status,
    [string]$TaskResultPath,
    [string[]]$ChangedFiles,
    [string[]]$ProducedArtifacts,
    [string[]]$CommandLogs,
    [string[]]$EvidenceRefs,
    [string[]]$RefusalReasons,
    [string]$HeadBefore,
    [string]$TreeBefore,
    [string]$HeadAfter,
    [string]$TreeAfter,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "DevExecutionAdapter.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$newDispatch = $module.ExportedCommands["New-DevDispatchPacket"]
$inspectDispatch = $module.ExportedCommands["Inspect-DevDispatchPacket"]
$readTaskPacket = $module.ExportedCommands["Read-TaskPacketDocument"]
$newResult = $module.ExportedCommands["New-DevExecutionResultPacket"]
$inspectResult = $module.ExportedCommands["Inspect-DevExecutionResultPacket"]
$readTaskResult = $module.ExportedCommands["Read-TaskResultDocument"]

function Assert-CliString {
    param(
        [AllowNull()]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required for Dev execution adapter command '$Command'."
    }
}

$normalizedCommand = $Command.ToLowerInvariant()
$result = switch ($normalizedCommand) {
    "create-dispatch" {
        Assert-CliString -Value $LedgerPath -Name "LedgerPath"
        Assert-CliString -Value $CycleId -Name "CycleId"
        Assert-CliString -Value $OutputPath -Name "OutputPath"
        Assert-CliString -Value $BaselineRef -Name "BaselineRef"
        Assert-CliString -Value $OperatorApprovalRef -Name "OperatorApprovalRef"
        Assert-CliString -Value $TaskPacketPath -Name "TaskPacketPath"

        $taskPackets = & $readTaskPacket -TaskPacketPath $TaskPacketPath
        $parameters = @{
            LedgerPath = $LedgerPath
            CycleId = $CycleId
            OutputPath = $OutputPath
            BaselineRef = $BaselineRef
            OperatorApprovalRef = $OperatorApprovalRef
            TaskPackets = @($taskPackets)
            TargetExecutor = $TargetExecutor
            Overwrite = $Overwrite
        }
        if ($null -ne $AllowedTools) { $parameters["AllowedTools"] = $AllowedTools }
        if ($null -ne $ForbiddenTools) { $parameters["ForbiddenTools"] = $ForbiddenTools }

        & $newDispatch @parameters
        break
    }
    "inspect-dispatch" {
        Assert-CliString -Value $DispatchPath -Name "DispatchPath"
        & $inspectDispatch -DispatchPath $DispatchPath
        break
    }
    "create-result" {
        Assert-CliString -Value $DispatchPath -Name "DispatchPath"
        Assert-CliString -Value $OutputPath -Name "OutputPath"
        Assert-CliString -Value $ExecutorIdentity -Name "ExecutorIdentity"
        Assert-CliString -Value $ExecutorKind -Name "ExecutorKind"
        Assert-CliString -Value $Status -Name "Status"
        Assert-CliString -Value $TaskResultPath -Name "TaskResultPath"
        Assert-CliString -Value $HeadBefore -Name "HeadBefore"
        Assert-CliString -Value $TreeBefore -Name "TreeBefore"
        Assert-CliString -Value $HeadAfter -Name "HeadAfter"
        Assert-CliString -Value $TreeAfter -Name "TreeAfter"

        $taskResultDocument = & $readTaskResult -TaskResultPath $TaskResultPath
        $taskResults = @($taskResultDocument.task_results)
        $changedFileValues = if ($null -ne $ChangedFiles) { $ChangedFiles } elseif ($taskResultDocument.PSObject.Properties.Name -contains "changed_files") { @($taskResultDocument.changed_files) } else { $null }
        $producedArtifactValues = if ($null -ne $ProducedArtifacts) { $ProducedArtifacts } elseif ($taskResultDocument.PSObject.Properties.Name -contains "produced_artifacts") { @($taskResultDocument.produced_artifacts) } else { $null }
        $commandLogValues = if ($null -ne $CommandLogs) { $CommandLogs } elseif ($taskResultDocument.PSObject.Properties.Name -contains "command_logs") { @($taskResultDocument.command_logs) } else { $null }
        $evidenceRefValues = if ($null -ne $EvidenceRefs) { $EvidenceRefs } elseif ($taskResultDocument.PSObject.Properties.Name -contains "evidence_refs") { @($taskResultDocument.evidence_refs) } else { $null }
        $refusalReasonValues = if ($null -ne $RefusalReasons) { $RefusalReasons } elseif ($taskResultDocument.PSObject.Properties.Name -contains "refusal_reasons") { @($taskResultDocument.refusal_reasons) } else { $null }

        & $newResult -DispatchPath $DispatchPath -OutputPath $OutputPath -ExecutorIdentity $ExecutorIdentity -ExecutorKind $ExecutorKind -Status $Status -TaskResults $taskResults -ChangedFiles $changedFileValues -ProducedArtifacts $producedArtifactValues -CommandLogs $commandLogValues -EvidenceRefs $evidenceRefValues -RefusalReasons $refusalReasonValues -HeadBefore $HeadBefore -TreeBefore $TreeBefore -HeadAfter $HeadAfter -TreeAfter $TreeAfter -Overwrite:$Overwrite
        break
    }
    "inspect-result" {
        Assert-CliString -Value $ResultPath -Name "ResultPath"
        if ([string]::IsNullOrWhiteSpace($DispatchPath)) {
            & $inspectResult -ResultPath $ResultPath
        }
        else {
            & $inspectResult -ResultPath $ResultPath -DispatchPath $DispatchPath
        }
        break
    }
    default {
        throw "Unknown Dev execution adapter command '$Command'."
    }
}

$result | ConvertTo-Json -Depth 100
