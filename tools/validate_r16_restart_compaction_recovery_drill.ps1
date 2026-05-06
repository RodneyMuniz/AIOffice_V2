[CmdletBinding()]
param(
    [string]$Path = "state\workflow\r16_restart_compaction_recovery_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RestartCompactionRecoveryDrill.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16RestartCompactionRecoveryDrill"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 restart/compaction recovery drill '{0}' is valid; exact_recovery_inputs={1}, active_through={2}, planned_range={3}..{4}, aggregate_verdict={5}, guard_verdict={6}, estimated_tokens_upper_bound={7}, threshold={8}, blocked_handoffs={9}, executable_handoffs={10}. Validation is bounded to exact repo-backed artifact refs; no raw chat canonical state, full repo scan, solved Codex compaction/reliability, runtime memory, retrieval/vector runtime, product runtime, autonomous recovery, executable handoffs, executable transitions, external integrations, or main merge are claimed." -f $result.DrillId, $result.ExactRecoveryInputCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold, $result.BlockedHandoffCount, $result.ExecutableHandoffCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 restart/compaction recovery drill is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
