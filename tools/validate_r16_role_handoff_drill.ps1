[CmdletBinding()]
param(
    [string]$Path = "state\workflow\r16_role_handoff_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleHandoffDrill.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16RoleHandoffDrill"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 role-handoff drill '{0}' is valid; active_through={1}, planned_range={2}..{3}, core_handoffs={4}, blocked={5}, executable_handoffs={6}, executable_transitions={7}, source_packet_blocked={8}, aggregate_verdict={9}, guard_verdict={10}, estimated_tokens_upper_bound={11}, threshold={12}. This is bounded report-only validation; no runtime handoff execution, executable handoffs, executable transitions, workflow drill execution beyond this report artifact, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, autonomous recovery, external integrations, solved Codex compaction, or solved Codex reliability are claimed." -f $result.DrillId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.CoreHandoffCount, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.ExecutableTransitionCount, $result.SourceHandoffPacketBlockedCount, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 role-handoff drill is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
