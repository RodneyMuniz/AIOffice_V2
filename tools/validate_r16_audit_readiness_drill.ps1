[CmdletBinding()]
param(
    [string]$Path = "state\audit\r16_audit_readiness_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16AuditReadinessDrill.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R16AuditReadinessDrill"]

try {
    $result = & $testReport -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 audit-readiness drill '{0}' is valid; active_through={1}, planned_range={2}..{3}, exact_audit_inputs={4}, proof_review_refs={5}, evidence_routes={6}, aggregate_verdict={7}, guard_verdict={8}, estimated_tokens_upper_bound={9}, threshold={10}, blocked_handoffs={11}, executable_handoffs={12}, executable_transitions={13}. This is bounded audit-readiness report-only validation; no broad/full repo scan, raw chat canonical evidence, final R16 audit acceptance, closeout, final proof package, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, executable handoffs/transitions, solved Codex compaction, or solved Codex reliability is claimed." -f $result.DrillId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.ExactAuditInputCount, $result.ProofReviewRefCount, $result.EvidenceInspectionRouteCount, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.ExecutableTransitionCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 audit-readiness drill is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
