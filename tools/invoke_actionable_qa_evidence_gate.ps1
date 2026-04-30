[CmdletBinding()]
param(
    [string]$GateScope = "r12_actionable_qa_evidence_gate_diagnostic",
    [string]$DevResultRef = "",
    [string]$ActionableQaReportRef = "",
    [string]$ActionableQaFixQueueRef = "",
    [string]$ExternalRunnerResultRef = "",
    [string]$ExternalArtifactEvidenceRef = "",
    [string]$ResiduePreflightRef = "",
    [string]$RemoteHeadPhaseDetectionRef = "",
    [string]$OperatingLoopRef = "",
    [string]$ValueScorecardRef = "",
    [string]$OutputPath = "",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ActionableQaEvidenceGate.psm1") -Force -PassThru
$invokeGate = $module.ExportedCommands["Invoke-ActionableQaEvidenceGate"]

& $invokeGate `
    -GateScope $GateScope `
    -DevResultRef $DevResultRef `
    -ActionableQaReportRef $ActionableQaReportRef `
    -ActionableQaFixQueueRef $ActionableQaFixQueueRef `
    -ExternalRunnerResultRef $ExternalRunnerResultRef `
    -ExternalArtifactEvidenceRef $ExternalArtifactEvidenceRef `
    -ResiduePreflightRef $ResiduePreflightRef `
    -RemoteHeadPhaseDetectionRef $RemoteHeadPhaseDetectionRef `
    -OperatingLoopRef $OperatingLoopRef `
    -ValueScorecardRef $ValueScorecardRef `
    -OutputPath $OutputPath `
    -Overwrite:$Overwrite
