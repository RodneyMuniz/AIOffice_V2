[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13BoundedFixExecution.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R13BoundedFixExecutionPacket"]

$validation = & $testPacket -PacketPath $PacketPath
Write-Output ("VALID: R13 bounded fix execution packet '{0}' has mode '{1}', status '{2}', aggregate verdict '{3}', {4} selected fix item(s), {5} selected source issue(s), and {6} target file(s)." -f $validation.ExecutionId, $validation.ExecutionMode, $validation.ExecutionStatus, $validation.AggregateVerdict, $validation.SelectedFixItemCount, $validation.SelectedSourceIssueCount, $validation.TargetFileCount)
