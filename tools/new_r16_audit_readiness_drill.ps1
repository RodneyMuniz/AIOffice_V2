[CmdletBinding()]
param(
    [string]$OutputPath = "state\audit\r16_audit_readiness_drill.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16AuditReadinessDrill.psm1") -Force -PassThru
$newReport = $module.ExportedCommands["New-R16AuditReadinessDrill"]

try {
    $result = & $newReport -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 audit-readiness drill '{0}' wrote '{1}' with exact_audit_inputs={2}, proof_review_refs={3}, evidence_routes={4}, active_through={5}, planned_range={6}..{7}, aggregate_verdict={8}, guard_verdict={9}, estimated_tokens_upper_bound={10}, threshold={11}, blocked_handoffs={12}, executable_handoffs={13}, executable_transitions={14}. This is bounded audit-readiness report-only generation; no broad/full repo scan, raw chat canonical evidence, final R16 audit acceptance, closeout, final proof package, runtime execution, runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, executable handoffs/transitions, solved Codex compaction, or solved Codex reliability is claimed." -f $result.DrillId, $result.OutputPath, $result.ExactAuditInputCount, $result.ProofReviewRefCount, $result.EvidenceInspectionRouteCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.GuardVerdict, $result.EstimatedTokensUpperBound, $result.Threshold, $result.BlockedHandoffCount, $result.ExecutableHandoffCount, $result.ExecutableTransitionCount)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 audit-readiness drill generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
