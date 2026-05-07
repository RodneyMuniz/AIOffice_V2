[CmdletBinding()]
param(
    [string]$PackagePath = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\r16_final_proof_review_package.json",
    [string]$EvidenceIndexPath = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\evidence_index.json",
    [string]$FinalHeadSupportPacketPath = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\final_head_support_packet.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16FinalProofReviewPackage.psm1") -Force -PassThru
$testPackageSet = $module.ExportedCommands["Test-R16FinalProofReviewPackageSet"]

try {
    $result = & $testPackageSet -PackagePath $PackagePath -EvidenceIndexPath $EvidenceIndexPath -FinalHeadSupportPacketPath $FinalHeadSupportPacketPath -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 final proof/review package candidate '{0}' is valid with evidence_index='{1}', final_head_support_packet='{2}', verdict={3}, exact_evidence_refs={4}, indexed_evidence={5}, proof_review_refs={6}, validation_manifest_refs={7}, guard={8}, latest_guard_upper_bound={9}, threshold={10}, observed_head={11}, observed_tree={12}, validation_commands={13}. This is candidate-only validation; no external audit acceptance, main merge, R13 closure, R14/R15 caveat removal, solved Codex compaction/reliability, runtime execution/memory/retrieval/vector/product runtime, autonomous agents, external integrations, executable handoffs, or executable transitions is claimed." -f $result.PackageId, $result.EvidenceIndexId, $result.FinalHeadPacketId, $result.AggregateVerdict, $result.ExactEvidenceRefCount, $result.IndexedEvidenceCount, $result.ProofReviewRefCount, $result.ValidationManifestRefCount, $result.GuardVerdict, $result.LatestGuardUpperBound, $result.Threshold, $result.ObservedHead, $result.ObservedTree, $result.ValidationCommandCount)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 final proof/review package candidate is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
