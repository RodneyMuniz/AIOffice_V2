[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13CompactionMitigation.psm1") -Force -PassThru
$validate = $module.ExportedCommands["Test-R13CompactionMitigationPacket"]

$result = & $validate -PacketPath $PacketPath
Write-Output ("VALID: R13 compaction mitigation packet '{0}', active through {1}, planned {2}, next legal action {3}, evidence refs {4}." -f $result.PacketId, $result.ActiveThroughTask, $result.PlannedRange, $result.NextLegalAction, $result.EvidenceRefCount)
