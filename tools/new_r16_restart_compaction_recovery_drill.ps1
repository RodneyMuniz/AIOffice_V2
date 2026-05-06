[CmdletBinding()]
param(
    [string]$OutputPath = "state\workflow\r16_restart_compaction_recovery_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RestartCompactionRecoveryDrill.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16RestartCompactionRecoveryDrill"]

try {
    $result = & $newReport -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 restart/compaction recovery drill '{0}' wrote '{1}' with exact_recovery_inputs={2}, active_through={3}, planned_range={4}..{5}, aggregate_verdict={6}, guard_verdict={7}, estimated_tokens_upper_bound={8}, threshold={9}, blocked_handoffs={10}, executable_handoffs={11}. This is bounded artifact-only recovery drill reporting; no solved Codex compaction, solved Codex reliability, runtime memory, retrieval/vector runtime, product runtime, autonomous recovery, executable handoffs, executable transitions, external integrations, or main merge are claimed." -f $result.DrillId, $result.OutputPath, $result.ExactRecoveryInputCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold, $result.BlockedHandoffCount, $result.ExecutableHandoffCount)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 restart/compaction recovery drill generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
