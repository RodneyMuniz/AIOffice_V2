[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ExecutionSegmentContinuity.psm1") -Force -PassThru
$testExecutionSegmentArtifact = $module.ExportedCommands["Test-ExecutionSegmentArtifactContract"]

$validation = & $testExecutionSegmentArtifact -ArtifactPath $ArtifactPath
Write-Output ("VALID: execution segment artifact '{0}' type '{1}' for task '{2}' segment '{3}' sequence '{4}' status '{5}'." -f $validation.ArtifactId, $validation.ArtifactType, $validation.TaskId, $validation.SegmentId, $validation.SegmentSequence, $validation.Status)
