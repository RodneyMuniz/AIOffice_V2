[CmdletBinding()]
param(
    [string]$OutputPath = "state\governance\r16_friction_metrics_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16FrictionMetricsReport.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16FrictionMetricsReport"]

try {
    $result = & $newReport -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 friction metrics report '{0}' wrote '{1}' with exact_metric_inputs={2}, proof_review_refs={3}, active_through={4}, planned_range={5}..{6}, aggregate_verdict={7}, guard_verdict={8}, latest_guard_upper_bound={9}, threshold={10}, friction_findings={11}, next_milestone_implications={12}. This is bounded friction metrics report-only generation; no broad/full repo scan, raw chat canonical evidence, final R16 audit acceptance, closeout, final proof package, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, executable handoffs/transitions, solved Codex compaction, or solved Codex reliability is claimed." -f $result.ReportId, $result.OutputPath, $result.ExactMetricInputCount, $result.ProofReviewRefCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.GuardVerdict, $result.LatestGuardUpperBound, $result.Threshold, $result.FrictionFindingCount, $result.NextMilestoneImplicationCount)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 friction metrics report generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
