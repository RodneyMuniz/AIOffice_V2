[CmdletBinding()]
param(
    [string]$Path = "state\governance\r16_friction_metrics_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16FrictionMetricsReport.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16FrictionMetricsReport"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 friction metrics report '{0}' is valid; active_through={1}, planned_range={2}..{3}, exact_metric_inputs={4}, proof_review_refs={5}, aggregate_verdict={6}, guard_verdict={7}, latest_guard_upper_bound={8}, threshold={9}, friction_findings={10}, next_milestone_implications={11}. This is bounded friction metrics report-only validation; no broad/full repo scan, raw chat canonical evidence, final R16 audit acceptance, closeout, final proof package, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, executable handoffs/transitions, solved Codex compaction, or solved Codex reliability is claimed." -f $result.ReportId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.ExactMetricInputCount, $result.ProofReviewRefCount, $result.AggregateVerdict, $result.GuardVerdict, $result.LatestGuardUpperBound, $result.Threshold, $result.FrictionFindingCount, $result.NextMilestoneImplicationCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 friction metrics report is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
