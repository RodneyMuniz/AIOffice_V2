param(
    [string]$OutputPath = "",
    [string]$CurrentTask = "R12-005 make fresh-thread bootstrap the default execution protocol",
    [string]$RemoteHeadPhaseDetectionRef = "state/fixtures/valid/remote_head_phase/phase_match.valid.json",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "FreshThreadBootstrap.psm1") -Force -PassThru
$newPacket = $module.ExportedCommands["New-FreshThreadBootstrapPacket"]

& $newPacket -OutputPath $OutputPath -CurrentTask $CurrentTask -RemoteHeadPhaseDetectionRef $RemoteHeadPhaseDetectionRef -Overwrite:$Overwrite
