[CmdletBinding()]
param(
    [string]$OutputPath = "state\workflow\r16_role_handoff_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleHandoffDrill.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16RoleHandoffDrill"]

try {
    $result = & $newReport -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 role-handoff drill '{0}' wrote '{1}' with core_handoffs={2}, blocked={3}, executable_handoffs={4}, executable_transitions={5}, source_packet_blocked={6}, active_through={7}, planned_range={8}..{9}, aggregate_verdict={10}, guard_verdict={11}, estimated_tokens_upper_bound={12}, threshold={13}. This is bounded report-only role-handoff drill inspection; no runtime handoff execution, executable handoffs, executable transitions, workflow drill execution beyond this report artifact, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, autonomous recovery, external integrations, solved Codex compaction, or solved Codex reliability are claimed." -f $result.DrillId, $result.OutputPath, $result.CoreHandoffCount, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.ExecutableTransitionCount, $result.SourceHandoffPacketBlockedCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 role-handoff drill generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
