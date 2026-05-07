[CmdletBinding()]
param(
    [string]$OutputRoot = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16FinalProofReviewPackage.psm1") -Force -PassThru
$newPackageSet = $module.ExportedCommands["New-R16FinalProofReviewPackageSet"]

try {
    $result = & $newPackageSet -OutputRoot $OutputRoot -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 final proof/review package candidate '{0}' wrote package='{1}', evidence_index='{2}', final_head_support_packet='{3}', verdict={4}, exact_evidence_refs={5}, indexed_evidence={6}, proof_review_refs={7}, validation_manifest_refs={8}, guard={9}, latest_guard_upper_bound={10}, threshold={11}, observed_head={12}, observed_tree={13}, previous_accepted_baseline={14}. This is R16-026 generated package candidate-only output; no external audit acceptance, main merge, R13 closure, R14/R15 caveat removal, solved Codex compaction/reliability, runtime execution/memory/retrieval/vector/product runtime, autonomous agents, external integrations, executable handoffs, or executable transitions is claimed." -f $result.PackageId, $result.PackagePath, $result.EvidenceIndexPath, $result.FinalHeadSupportPacketPath, $result.AggregateVerdict, $result.ExactEvidenceRefCount, $result.IndexedEvidenceCount, $result.ProofReviewRefCount, $result.ValidationManifestRefCount, $result.GuardVerdict, $result.LatestGuardUpperBound, $result.Threshold, $result.ObservedHead, $result.ObservedTree, $result.PreviousAcceptedBaseline)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 final proof/review package candidate generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
