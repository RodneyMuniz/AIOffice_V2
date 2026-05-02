[CmdletBinding()]
param(
    [string]$IdentityReconciliationPath = "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json",
    [string]$PacketPath = "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json",
    [string]$PromptPath = "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md",
    [string]$ManifestPath = "state/continuity/r13_compaction_mitigation/validation_manifest.md"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13CompactionMitigation.psm1") -Force -PassThru
$generate = $module.ExportedCommands["New-R13CompactionMitigationArtifacts"]

$result = & $generate `
    -IdentityReconciliationPath $IdentityReconciliationPath `
    -PacketPath $PacketPath `
    -PromptPath $PromptPath `
    -ManifestPath $ManifestPath

Write-Output ("Generated R13-013 identity reconciliation: {0}" -f $result.IdentityReconciliationPath)
Write-Output ("Generated R13-013 compaction mitigation packet: {0}" -f $result.PacketPath)
Write-Output ("Generated R13-013 restart prompt: {0}" -f $result.PromptPath)
Write-Output ("Generated R13-013 validation manifest: {0}" -f $result.ManifestPath)
Write-Output ("Packet ID: {0}" -f $result.PacketId)
Write-Output ("Prompt ID: {0}" -f $result.PromptId)
