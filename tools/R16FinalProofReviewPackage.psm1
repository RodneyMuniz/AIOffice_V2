Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:PackageVersion = "v1"
$script:PackageId = "aioffice-r16-026-final-proof-review-package-v1"
$script:EvidenceIndexId = "aioffice-r16-026-final-evidence-index-v1"
$script:FinalHeadPacketId = "aioffice-r16-026-final-head-support-packet-v1"
$script:AggregateVerdict = "generated_r16_final_proof_review_package_candidate"
$script:PackageStatus = "candidate_or_generated_package_only"
$script:GuardVerdict = "failed_closed_over_budget"
$script:ExpectedGuardUpperBound = 1364079
$script:ExpectedThreshold = 150000
$script:PreviousAcceptedBaseline = "8f3453529c763476b597926f53a9dd1899dece0b"
$script:PackageRoot = "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_026_final_proof_review_package"
$script:PackagePath = "$script:PackageRoot/r16_final_proof_review_package.json"
$script:EvidenceIndexPath = "$script:PackageRoot/evidence_index.json"
$script:FinalHeadSupportPacketPath = "$script:PackageRoot/final_head_support_packet.json"

$script:RequiredPackageFields = [string[]]@(
    "artifact_type",
    "package_version",
    "package_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "generated_from_head",
    "generated_from_tree",
    "accepted_task_range",
    "r16_026_package_status",
    "exact_evidence_refs",
    "proof_review_refs",
    "validation_manifest_refs",
    "state_artifact_refs",
    "contract_refs",
    "tool_refs",
    "test_refs",
    "current_guard_posture",
    "context_budget_summary",
    "friction_metrics_summary",
    "audit_readiness_summary",
    "workflow_boundary_summary",
    "accepted_scope_summary_by_phase",
    "blocked_execution_summary",
    "evidence_hygiene_findings",
    "operational_friction_findings",
    "final_validation_commands",
    "current_posture",
    "preserved_boundaries",
    "non_claims",
    "external_audit_instructions",
    "no_full_repo_scan_policy",
    "raw_chat_history_policy",
    "aggregate_verdict"
)

$script:RequiredEvidenceIndexFields = [string[]]@(
    "artifact_type",
    "index_version",
    "index_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "indexed_entries",
    "no_full_repo_scan_policy",
    "evidence_hygiene_policy",
    "non_claims",
    "aggregate_verdict"
)

$script:RequiredFinalHeadPacketFields = [string[]]@(
    "artifact_type",
    "packet_version",
    "packet_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "observed_head",
    "observed_tree",
    "previous_accepted_baseline",
    "validation_command_list",
    "expected_final_scope",
    "non_claims",
    "preserved_boundaries",
    "final_audit_candidate_statement",
    "no_main_merge_attestation",
    "no_external_audit_acceptance_attestation",
    "current_guard_posture",
    "aggregate_verdict"
)

function New-R16RefSpec {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$ArtifactKind,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [string]$AuthorityLevel = "supporting",
        [string[]]$Caveats = @()
    )

    return [pscustomobject][ordered]@{
        Path = $Path
        SourceTask = $SourceTask
        ArtifactKind = $ArtifactKind
        ProofTreatment = $ProofTreatment
        AuthorityLevel = $AuthorityLevel
        Caveats = [string[]]$Caveats
    }
}

$script:RequiredExactEvidenceRefs = [ordered]@{
    r16_001_governance_authority = New-R16RefSpec -Path "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md" -SourceTask "R16-001" -ArtifactKind "governance_authority" -ProofTreatment "milestone opening and task-boundary authority; canonical exact repo-backed ref, not runtime proof" -AuthorityLevel "primary"
    r16_002_planning_authority_reference = New-R16RefSpec -Path "state/governance/r16_planning_authority_reference.json" -SourceTask "R16-002" -ArtifactKind "generated_state_artifact" -ProofTreatment "planning authority reference state artifact; evidence artifact only" -AuthorityLevel "primary"
    r16_003_kpi_baseline_target_scorecard = New-R16RefSpec -Path "state/governance/r16_kpi_baseline_target_scorecard.json" -SourceTask "R16-003" -ArtifactKind "generated_state_artifact" -ProofTreatment "KPI baseline/target scorecard state artifact; target scoring, not achieved runtime proof" -AuthorityLevel "primary"
    r16_004_memory_layer_contract = New-R16RefSpec -Path "contracts/memory/r16_memory_layer.contract.json" -SourceTask "R16-004" -ArtifactKind "contract" -ProofTreatment "memory layer contract; schema/boundary evidence, not runtime memory proof" -AuthorityLevel "primary"
    r16_005_memory_layers = New-R16RefSpec -Path "state/memory/r16_memory_layers.json" -SourceTask "R16-005" -ArtifactKind "generated_state_artifact" -ProofTreatment "deterministic memory layer state artifact; not runtime memory loading" -AuthorityLevel "primary"
    r16_006_role_memory_pack_model = New-R16RefSpec -Path "state/memory/r16_role_memory_pack_model.json" -SourceTask "R16-006" -ArtifactKind "generated_state_artifact" -ProofTreatment "role memory pack model state artifact; not autonomous-agent execution" -AuthorityLevel "primary"
    r16_007_role_memory_packs = New-R16RefSpec -Path "state/memory/r16_role_memory_packs.json" -SourceTask "R16-007" -ArtifactKind "generated_state_artifact" -ProofTreatment "baseline role memory packs state artifact; not runtime retrieval or memory" -AuthorityLevel "primary"
    r16_008_memory_pack_validation_report = New-R16RefSpec -Path "state/memory/r16_memory_pack_validation_report.json" -SourceTask "R16-008" -ArtifactKind "generated_report" -ProofTreatment "memory pack validation and stale-ref report; generated report is not automatically machine proof" -AuthorityLevel "primary"
    r16_009_artifact_map_contract = New-R16RefSpec -Path "contracts/artifacts/r16_artifact_map.contract.json" -SourceTask "R16-009" -ArtifactKind "contract" -ProofTreatment "artifact map contract; schema/boundary evidence" -AuthorityLevel "primary"
    r16_010_artifact_map = New-R16RefSpec -Path "state/artifacts/r16_artifact_map.json" -SourceTask "R16-010" -ArtifactKind "generated_state_artifact" -ProofTreatment "artifact map state artifact; canonical map evidence, not runtime proof" -AuthorityLevel "primary"
    r16_011_audit_map_contract = New-R16RefSpec -Path "contracts/audit/r16_audit_map.contract.json" -SourceTask "R16-011" -ArtifactKind "contract" -ProofTreatment "audit map contract; schema/boundary evidence" -AuthorityLevel "primary"
    r16_012_r15_r16_audit_map = New-R16RefSpec -Path "state/audit/r16_r15_r16_audit_map.json" -SourceTask "R16-012" -ArtifactKind "generated_state_artifact" -ProofTreatment "R15/R16 audit map state artifact; preserves R15 caveats" -AuthorityLevel "primary" -Caveats @("R15 stale generated_from caveat remains preserved.")
    r16_013_artifact_audit_map_check = New-R16RefSpec -Path "state/artifacts/r16_artifact_audit_map_check_report.json" -SourceTask "R16-013" -ArtifactKind "generated_report" -ProofTreatment "artifact/audit map consistency report; generated report is not automatically machine proof" -AuthorityLevel "primary"
    r16_014_context_load_plan_contract = New-R16RefSpec -Path "contracts/context/r16_context_load_plan.contract.json" -SourceTask "R16-014" -ArtifactKind "contract" -ProofTreatment "context load plan contract; schema/boundary evidence" -AuthorityLevel "primary"
    r16_015_context_load_plan = New-R16RefSpec -Path "state/context/r16_context_load_plan.json" -SourceTask "R16-015" -ArtifactKind "generated_state_artifact" -ProofTreatment "context load plan state artifact; exact refs only, no broad scan" -AuthorityLevel "primary"
    r16_016_context_budget_estimate = New-R16RefSpec -Path "state/context/r16_context_budget_estimate.json" -SourceTask "R16-016" -ArtifactKind "generated_state_artifact" -ProofTreatment "approximate context budget estimate; no provider tokenization or billing" -AuthorityLevel "primary"
    r16_017_context_budget_guard = New-R16RefSpec -Path "state/context/r16_context_budget_guard_report.json" -SourceTask "R16-017" -ArtifactKind "generated_report" -ProofTreatment "failed-closed context budget guard report; expected unresolved signal" -AuthorityLevel "primary"
    r16_018_role_run_envelope_contract = New-R16RefSpec -Path "contracts/workflow/r16_role_run_envelope.contract.json" -SourceTask "R16-018" -ArtifactKind "contract" -ProofTreatment "role-run envelope contract; non-executable workflow boundary" -AuthorityLevel "primary"
    r16_019_role_run_envelopes = New-R16RefSpec -Path "state/workflow/r16_role_run_envelopes.json" -SourceTask "R16-019" -ArtifactKind "generated_state_artifact" -ProofTreatment "role-run envelope state artifact; no executable envelopes or transitions" -AuthorityLevel "primary"
    r16_020_raci_transition_gate = New-R16RefSpec -Path "state/workflow/r16_raci_transition_gate_report.json" -SourceTask "R16-020" -ArtifactKind "generated_report" -ProofTreatment "RACI transition gate report; transitions remain blocked/non-executable" -AuthorityLevel "primary"
    r16_021_handoff_packet_report = New-R16RefSpec -Path "state/workflow/r16_handoff_packet_report.json" -SourceTask "R16-021" -ArtifactKind "generated_report" -ProofTreatment "handoff packet report; handoffs remain non-executable" -AuthorityLevel "primary"
    r16_022_restart_compaction_recovery_drill = New-R16RefSpec -Path "state/workflow/r16_restart_compaction_recovery_drill.json" -SourceTask "R16-022" -ArtifactKind "generated_report" -ProofTreatment "restart/compaction recovery drill; Codex compaction captured, not solved" -AuthorityLevel "primary"
    r16_023_role_handoff_drill = New-R16RefSpec -Path "state/workflow/r16_role_handoff_drill.json" -SourceTask "R16-023" -ArtifactKind "generated_report" -ProofTreatment "role-handoff drill; no executable handoffs or transitions" -AuthorityLevel "primary"
    r16_024_audit_readiness_drill = New-R16RefSpec -Path "state/audit/r16_audit_readiness_drill.json" -SourceTask "R16-024" -ArtifactKind "generated_report" -ProofTreatment "audit-readiness drill report; no final R16 audit acceptance" -AuthorityLevel "primary"
    r16_025_friction_metrics_report = New-R16RefSpec -Path "state/governance/r16_friction_metrics_report.json" -SourceTask "R16-025" -ArtifactKind "generated_report" -ProofTreatment "bounded friction metrics report; operator-observed process evidence is not machine proof" -AuthorityLevel "primary"
}

$script:RequiredProofReviewRefs = [ordered]@{
    r16_001_opening_package = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/r16_opening_packet.json" -SourceTask "R16-001" -ArtifactKind "opening_package" -ProofTreatment "opening package path; classified separately from proof_review.json" -AuthorityLevel "supporting"
    r16_002_planning_authority_reference = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/validation_manifest.md" -SourceTask "R16-002" -ArtifactKind "validation_manifest_only" -ProofTreatment "R16-002 uses manifest/non-claims package rather than proof_review.json" -AuthorityLevel "supporting"
    r16_003_kpi_baseline_target_scorecard = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/validation_manifest.md" -SourceTask "R16-003" -ArtifactKind "validation_manifest_only" -ProofTreatment "R16-003 uses manifest/non-claims package rather than proof_review.json" -AuthorityLevel "supporting"
    r16_004_memory_layer_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/validation_manifest.md" -SourceTask "R16-004" -ArtifactKind "validation_manifest_only" -ProofTreatment "R16-004 uses manifest/non-claims package rather than proof_review.json" -AuthorityLevel "supporting"
    r16_005_deterministic_memory_layer_generator = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/generation_summary.json" -SourceTask "R16-005" -ArtifactKind "generation_summary" -ProofTreatment "generation summary path for R16-005; classified separately from proof_review.json" -AuthorityLevel "supporting"
    r16_006_role_memory_pack_model = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/validation_manifest.md" -SourceTask "R16-006" -ArtifactKind "validation_manifest_only" -ProofTreatment "R16-006 uses manifest/non-claims package rather than proof_review.json" -AuthorityLevel "supporting"
    r16_007_baseline_role_memory_packs = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/generation_summary.json" -SourceTask "R16-007" -ArtifactKind "generation_summary" -ProofTreatment "generation summary path for R16-007; classified separately from proof_review.json" -AuthorityLevel "supporting"
    r16_008_memory_pack_validation = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/detection_summary.json" -SourceTask "R16-008" -ArtifactKind "detection_summary" -ProofTreatment "stale-ref detection summary path for R16-008; classified separately from proof_review.json" -AuthorityLevel "supporting"
    r16_009_artifact_map_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_009_artifact_map_contract/proof_review.json" -SourceTask "R16-009" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-009" -AuthorityLevel "supporting"
    r16_010_artifact_map_generator = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_010_artifact_map_generator/proof_review.json" -SourceTask "R16-010" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-010" -AuthorityLevel "supporting"
    r16_011_audit_map_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_011_audit_map_contract/proof_review.json" -SourceTask "R16-011" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-011" -AuthorityLevel "supporting"
    r16_012_r15_r16_audit_map = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/proof_review.json" -SourceTask "R16-012" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-012" -AuthorityLevel "supporting" -Caveats @("R15 stale generated_from caveat remains preserved.")
    r16_013_artifact_audit_map_check = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_013_artifact_audit_map_check/proof_review.json" -SourceTask "R16-013" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-013" -AuthorityLevel "supporting"
    r16_014_context_load_plan_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_014_context_load_plan_contract/proof_review.json" -SourceTask "R16-014" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-014" -AuthorityLevel "supporting"
    r16_015_context_load_planner = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_015_context_load_planner/proof_review.json" -SourceTask "R16-015" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-015" -AuthorityLevel "supporting"
    r16_016_context_budget_estimator = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_016_context_budget_estimator/proof_review.json" -SourceTask "R16-016" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-016" -AuthorityLevel "supporting"
    r16_017_context_budget_guard = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_017_context_budget_guard/proof_review.json" -SourceTask "R16-017" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-017" -AuthorityLevel "supporting"
    r16_018_role_run_envelope_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_018_role_run_envelope_contract/proof_review.json" -SourceTask "R16-018" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-018" -AuthorityLevel "supporting"
    r16_019_role_run_envelope_generator = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_019_role_run_envelope_generator/proof_review.json" -SourceTask "R16-019" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-019" -AuthorityLevel "supporting"
    r16_020_raci_transition_gate = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_020_raci_transition_gate/proof_review.json" -SourceTask "R16-020" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-020" -AuthorityLevel "supporting"
    r16_021_handoff_packet_generator = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_021_handoff_packet_generator/proof_review.json" -SourceTask "R16-021" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-021" -AuthorityLevel "supporting"
    r16_022_restart_compaction_recovery_drill = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_022_restart_compaction_recovery_drill/proof_review.json" -SourceTask "R16-022" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-022" -AuthorityLevel "supporting"
    r16_023_role_handoff_drill = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_023_role_handoff_drill/proof_review.json" -SourceTask "R16-023" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-023" -AuthorityLevel "supporting"
    r16_024_audit_readiness_drill = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_024_audit_readiness_drill/proof_review.json" -SourceTask "R16-024" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-024" -AuthorityLevel "supporting"
    r16_025_friction_metrics_report = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_025_friction_metrics_report/proof_review.json" -SourceTask "R16-025" -ArtifactKind "proof_review" -ProofTreatment "proof-review package pointer for R16-025" -AuthorityLevel "supporting"
}

$script:RequiredValidationManifestRefs = [ordered]@{
    r16_001_opening = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/opening/validation_manifest.md" -SourceTask "R16-001" -ArtifactKind "validation_manifest" -ProofTreatment "opening validation manifest" -AuthorityLevel "supporting"
    r16_002_planning_authority_reference = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_002_planning_authority_reference/validation_manifest.md" -SourceTask "R16-002" -ArtifactKind "validation_manifest" -ProofTreatment "R16-002 validation manifest" -AuthorityLevel "supporting"
    r16_003_kpi_baseline_target_scorecard = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_003_kpi_baseline_target_scorecard/validation_manifest.md" -SourceTask "R16-003" -ArtifactKind "validation_manifest" -ProofTreatment "R16-003 validation manifest" -AuthorityLevel "supporting"
    r16_004_memory_layer_contract = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_004_memory_layer_contract/validation_manifest.md" -SourceTask "R16-004" -ArtifactKind "validation_manifest" -ProofTreatment "R16-004 validation manifest" -AuthorityLevel "supporting"
    r16_005_memory_layers = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_005_deterministic_memory_layer_generator/validation_manifest.md" -SourceTask "R16-005" -ArtifactKind "validation_manifest" -ProofTreatment "R16-005 validation manifest" -AuthorityLevel "supporting"
    r16_006_role_memory_pack_model = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_006_role_memory_pack_model/validation_manifest.md" -SourceTask "R16-006" -ArtifactKind "validation_manifest" -ProofTreatment "R16-006 validation manifest" -AuthorityLevel "supporting"
    r16_007_role_memory_packs = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/validation_manifest.md" -SourceTask "R16-007" -ArtifactKind "validation_manifest" -ProofTreatment "R16-007 validation manifest" -AuthorityLevel "supporting"
    r16_008_memory_pack_validation = New-R16RefSpec -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_008_memory_pack_validation_stale_ref_detection/validation_manifest.md" -SourceTask "R16-008" -ArtifactKind "validation_manifest" -ProofTreatment "R16-008 validation manifest" -AuthorityLevel "supporting"
}

foreach ($taskNumber in 9..25) {
    $taskId = "R16-{0:000}" -f $taskNumber
    $proofSpec = @($script:RequiredProofReviewRefs.GetEnumerator() | Where-Object { $_.Value.SourceTask -eq $taskId } | Select-Object -First 1).Value
    $manifestPath = ($proofSpec.Path -replace "/proof_review\.json$", "/validation_manifest.md")
    $script:RequiredValidationManifestRefs["r16_{0:000}_validation_manifest" -f $taskNumber] = New-R16RefSpec -Path $manifestPath -SourceTask $taskId -ArtifactKind "validation_manifest" -ProofTreatment "$taskId validation manifest" -AuthorityLevel "supporting"
}

$script:RequiredStateArtifactRefs = [ordered]@{
    r16_002_planning_authority_reference = $script:RequiredExactEvidenceRefs.r16_002_planning_authority_reference
    r16_003_kpi_baseline_target_scorecard = $script:RequiredExactEvidenceRefs.r16_003_kpi_baseline_target_scorecard
    r16_005_memory_layers = $script:RequiredExactEvidenceRefs.r16_005_memory_layers
    r16_006_role_memory_pack_model = $script:RequiredExactEvidenceRefs.r16_006_role_memory_pack_model
    r16_007_role_memory_packs = $script:RequiredExactEvidenceRefs.r16_007_role_memory_packs
    r16_008_memory_pack_validation_report = $script:RequiredExactEvidenceRefs.r16_008_memory_pack_validation_report
    r16_010_artifact_map = $script:RequiredExactEvidenceRefs.r16_010_artifact_map
    r16_012_r15_r16_audit_map = $script:RequiredExactEvidenceRefs.r16_012_r15_r16_audit_map
    r16_013_artifact_audit_map_check = $script:RequiredExactEvidenceRefs.r16_013_artifact_audit_map_check
    r16_015_context_load_plan = $script:RequiredExactEvidenceRefs.r16_015_context_load_plan
    r16_016_context_budget_estimate = $script:RequiredExactEvidenceRefs.r16_016_context_budget_estimate
    r16_017_context_budget_guard = $script:RequiredExactEvidenceRefs.r16_017_context_budget_guard
    r16_019_role_run_envelopes = $script:RequiredExactEvidenceRefs.r16_019_role_run_envelopes
    r16_020_raci_transition_gate = $script:RequiredExactEvidenceRefs.r16_020_raci_transition_gate
    r16_021_handoff_packet_report = $script:RequiredExactEvidenceRefs.r16_021_handoff_packet_report
    r16_022_restart_compaction_recovery_drill = $script:RequiredExactEvidenceRefs.r16_022_restart_compaction_recovery_drill
    r16_023_role_handoff_drill = $script:RequiredExactEvidenceRefs.r16_023_role_handoff_drill
    r16_024_audit_readiness_drill = $script:RequiredExactEvidenceRefs.r16_024_audit_readiness_drill
    r16_025_friction_metrics_report = $script:RequiredExactEvidenceRefs.r16_025_friction_metrics_report
}

$script:RequiredContractRefs = [ordered]@{
    r16_026_final_proof_review_package_contract = New-R16RefSpec -Path "contracts/governance/r16_final_proof_review_package.contract.json" -SourceTask "R16-026" -ArtifactKind "contract" -ProofTreatment "current-task contract for final proof/review package candidate" -AuthorityLevel "current_task_output"
    r16_002_planning_authority_reference_contract = New-R16RefSpec -Path "contracts/governance/r16_planning_authority_reference.contract.json" -SourceTask "R16-002" -ArtifactKind "contract" -ProofTreatment "planning authority reference contract" -AuthorityLevel "supporting"
    r16_003_kpi_scorecard_contract = New-R16RefSpec -Path "contracts/governance/r16_kpi_baseline_target_scorecard.contract.json" -SourceTask "R16-003" -ArtifactKind "contract" -ProofTreatment "KPI baseline/target scorecard contract" -AuthorityLevel "supporting"
    r16_004_memory_layer_contract = $script:RequiredExactEvidenceRefs.r16_004_memory_layer_contract
    r16_006_role_memory_pack_model_contract = New-R16RefSpec -Path "contracts/memory/r16_role_memory_pack_model.contract.json" -SourceTask "R16-006" -ArtifactKind "contract" -ProofTreatment "role memory pack model contract" -AuthorityLevel "supporting"
    r16_008_memory_pack_validation_contract = New-R16RefSpec -Path "contracts/memory/r16_memory_pack_validation_report.contract.json" -SourceTask "R16-008" -ArtifactKind "contract" -ProofTreatment "memory pack validation report contract" -AuthorityLevel "supporting"
    r16_009_artifact_map_contract = $script:RequiredExactEvidenceRefs.r16_009_artifact_map_contract
    r16_011_audit_map_contract = $script:RequiredExactEvidenceRefs.r16_011_audit_map_contract
    r16_014_context_load_plan_contract = $script:RequiredExactEvidenceRefs.r16_014_context_load_plan_contract
    r16_016_context_budget_estimate_contract = New-R16RefSpec -Path "contracts/context/r16_context_budget_estimate.contract.json" -SourceTask "R16-016" -ArtifactKind "contract" -ProofTreatment "context budget estimate contract" -AuthorityLevel "supporting"
    r16_017_context_budget_guard_contract = New-R16RefSpec -Path "contracts/context/r16_context_budget_guard.contract.json" -SourceTask "R16-017" -ArtifactKind "contract" -ProofTreatment "context budget guard contract" -AuthorityLevel "supporting"
    r16_018_role_run_envelope_contract = $script:RequiredExactEvidenceRefs.r16_018_role_run_envelope_contract
    r16_020_raci_transition_gate_contract = New-R16RefSpec -Path "contracts/workflow/r16_raci_transition_gate_report.contract.json" -SourceTask "R16-020" -ArtifactKind "contract" -ProofTreatment "RACI transition gate report contract" -AuthorityLevel "supporting"
    r16_021_handoff_packet_report_contract = New-R16RefSpec -Path "contracts/workflow/r16_handoff_packet_report.contract.json" -SourceTask "R16-021" -ArtifactKind "contract" -ProofTreatment "handoff packet report contract" -AuthorityLevel "supporting"
    r16_022_restart_compaction_recovery_drill_contract = New-R16RefSpec -Path "contracts/workflow/r16_restart_compaction_recovery_drill.contract.json" -SourceTask "R16-022" -ArtifactKind "contract" -ProofTreatment "restart/compaction recovery drill contract" -AuthorityLevel "supporting"
    r16_023_role_handoff_drill_contract = New-R16RefSpec -Path "contracts/workflow/r16_role_handoff_drill.contract.json" -SourceTask "R16-023" -ArtifactKind "contract" -ProofTreatment "role-handoff drill contract" -AuthorityLevel "supporting"
    r16_024_audit_readiness_drill_contract = New-R16RefSpec -Path "contracts/audit/r16_audit_readiness_drill.contract.json" -SourceTask "R16-024" -ArtifactKind "contract" -ProofTreatment "audit-readiness drill contract" -AuthorityLevel "supporting"
    r16_025_friction_metrics_report_contract = New-R16RefSpec -Path "contracts/governance/r16_friction_metrics_report.contract.json" -SourceTask "R16-025" -ArtifactKind "contract" -ProofTreatment "friction metrics report contract" -AuthorityLevel "supporting"
}

$script:RequiredToolRefs = [ordered]@{
    r16_026_module = New-R16RefSpec -Path "tools/R16FinalProofReviewPackage.psm1" -SourceTask "R16-026" -ArtifactKind "tool_module" -ProofTreatment "current-task generator and validator module" -AuthorityLevel "current_task_output"
    r16_026_new_script = New-R16RefSpec -Path "tools/new_r16_final_proof_review_package.ps1" -SourceTask "R16-026" -ArtifactKind "tool_script" -ProofTreatment "current-task generation script" -AuthorityLevel "current_task_output"
    r16_026_validate_script = New-R16RefSpec -Path "tools/validate_r16_final_proof_review_package.ps1" -SourceTask "R16-026" -ArtifactKind "tool_script" -ProofTreatment "current-task validation script" -AuthorityLevel "current_task_output"
}

$script:RequiredTestRefs = [ordered]@{
    r16_026_tests = New-R16RefSpec -Path "tests/test_r16_final_proof_review_package.ps1" -SourceTask "R16-026" -ArtifactKind "test" -ProofTreatment "current-task focused test harness" -AuthorityLevel "current_task_output"
}

$script:CurrentTaskOutputPaths = [string[]]@(
    "contracts/governance/r16_final_proof_review_package.contract.json",
    "tools/R16FinalProofReviewPackage.psm1",
    "tools/new_r16_final_proof_review_package.ps1",
    "tools/validate_r16_final_proof_review_package.ps1",
    "tests/test_r16_final_proof_review_package.ps1",
    $script:PackagePath,
    $script:EvidenceIndexPath,
    $script:FinalHeadSupportPacketPath
)

$script:RequiredValidationCommands = [string[]]@(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_final_proof_review_package.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_final_proof_review_package.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_final_proof_review_package.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_friction_metrics_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_friction_metrics_report.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_audit_readiness_drill.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_audit_readiness_drill.ps1"
)

$script:RequiredNonClaims = [string[]]@(
    "R16-026 is a generated final proof/review package candidate only.",
    "No external audit acceptance is claimed.",
    "No main merge is claimed.",
    "No R13 closure is claimed.",
    "R13 remains failed/partial and not closed.",
    "R14 caveats remain preserved.",
    "R15 caveats remain preserved.",
    "No solved Codex compaction is claimed.",
    "No solved Codex reliability is claimed.",
    "No runtime execution is claimed.",
    "No runtime memory is claimed.",
    "No retrieval runtime is claimed.",
    "No vector search runtime is claimed.",
    "No product runtime is claimed.",
    "No autonomous agents are claimed.",
    "No external integrations are claimed.",
    "No executable handoffs are claimed.",
    "No executable transitions are claimed.",
    "The context guard remains failed_closed_over_budget.",
    "The failed-closed guard remains expected and unresolved.",
    "Exact provider tokenization and billing are not claimed.",
    "Raw chat history is not canonical evidence.",
    "Generated state artifacts are evidence artifacts, not runtime proof.",
    "Generated reports are not automatically machine proof.",
    "Operator-observed process evidence is not machine proof.",
    "R16-027 or later is not claimed."
)

$script:RequiredEvidenceHygieneFindingIds = [string[]]@(
    "generated_state_artifacts_not_runtime_proof",
    "generated_reports_not_automatic_machine_proof",
    "operator_observed_process_evidence_not_machine_proof",
    "raw_chat_history_not_canonical_evidence",
    "exact_repo_backed_artifacts_are_canonical_refs",
    "r15_stale_generated_from_caveat_preserved",
    "r13_failed_partial_not_closed",
    "r14_caveats_preserved",
    "r15_caveats_preserved"
)

$script:RequiredOperationalFrictionFindingIds = [string[]]@(
    "codex_auto_compaction_failures",
    "fixture_bloat_full_copy_invalids",
    "untracked_file_visibility_gap",
    "deterministic_byte_line_drift",
    "validator_allowlist_update_cost",
    "finalization_split_pressure",
    "powershell_tooling_friction",
    "large_generated_json_context_pressure",
    "failed_closed_guard_is_expected",
    "runtime_non_solution_boundary"
)

$script:ForbiddenTrueBooleanClaims = @{
    broad_repo_scan_allowed = "broad repo scan claim"
    broad_repo_scan_performed = "broad repo scan claim"
    broad_repo_scan_claimed = "broad repo scan claim"
    full_repo_scan_allowed = "full repo scan claim"
    full_repo_scan_performed = "full repo scan claim"
    full_repo_scan_claimed = "full repo scan claim"
    full_repo_scan_used = "full repo scan claim"
    wildcard_paths_allowed = "wildcard path"
    wildcard_path_expansion_allowed = "wildcard path"
    wildcard_path_expansion_performed = "wildcard path"
    wildcard_paths_loaded = "wildcard path"
    directory_only_refs_allowed = "directory-only ref"
    directory_only_paths_allowed = "directory-only ref"
    directory_only_refs_loaded = "directory-only ref"
    scratch_temp_refs_allowed = "scratch/temp ref"
    scratch_temp_paths_allowed = "scratch/temp ref"
    scratch_temp_refs_loaded = "scratch/temp ref"
    absolute_paths_allowed = "absolute path"
    absolute_paths_loaded = "absolute path"
    parent_traversal_allowed = "parent traversal path"
    parent_traversal_refs_loaded = "parent traversal path"
    url_or_remote_refs_allowed = "URL or remote ref"
    url_or_remote_refs_loaded = "URL or remote ref"
    raw_chat_history_as_canonical_evidence = "raw chat history as canonical evidence"
    raw_chat_history_as_canonical_state = "raw chat history as canonical evidence"
    raw_chat_history_loaded = "raw chat history as canonical evidence"
    raw_chat_history_as_evidence_allowed = "raw chat history as canonical evidence"
    raw_chat_history_loading_allowed = "raw chat history as canonical evidence"
    generated_report_treated_as_machine_proof = "report-as-machine-proof misuse"
    generated_reports_as_machine_proof_allowed = "report-as-machine-proof misuse"
    report_as_machine_proof_allowed = "report-as-machine-proof misuse"
    report_as_machine_proof_used = "report-as-machine-proof misuse"
    operator_observed_process_evidence_treated_as_machine_proof = "report-as-machine-proof misuse"
    operator_observed_process_evidence_machine_proof = "report-as-machine-proof misuse"
    exact_provider_tokenization_claimed = "exact provider tokenization claim"
    exact_provider_token_count_claimed = "exact provider tokenization claim"
    provider_tokenizer_used = "exact provider tokenization claim"
    exact_provider_billing_claimed = "exact provider billing claim"
    provider_pricing_used = "exact provider billing claim"
    external_audit_acceptance_claimed = "final external audit acceptance claim"
    final_external_audit_acceptance_claimed = "final external audit acceptance claim"
    final_r16_audit_acceptance_claimed = "final external audit acceptance claim"
    final_audit_acceptance_claimed = "final external audit acceptance claim"
    r16_final_audit_accepted = "final external audit acceptance claim"
    closeout_completion_claimed = "closeout completion claim"
    closeout_completed = "closeout completion claim"
    final_proof_package_completion_claimed = "final proof package completion claim"
    final_proof_package_completed = "final proof package completion claim"
    runtime_execution_exists = "runtime execution claim"
    runtime_execution_claimed = "runtime execution claim"
    runtime_execution_performed = "runtime execution claim"
    runtime_execution_implemented = "runtime execution claim"
    runtime_memory_exists = "runtime memory claim"
    runtime_memory_claimed = "runtime memory claim"
    runtime_memory_implemented = "runtime memory claim"
    runtime_memory_loading_implemented = "runtime memory claim"
    retrieval_runtime_exists = "retrieval runtime claim"
    retrieval_runtime_claimed = "retrieval runtime claim"
    retrieval_runtime_implemented = "retrieval runtime claim"
    vector_search_runtime_exists = "vector search runtime claim"
    vector_search_runtime_claimed = "vector search runtime claim"
    vector_search_runtime_implemented = "vector search runtime claim"
    product_runtime_exists = "product runtime claim"
    product_runtime_claimed = "product runtime claim"
    product_runtime_implemented = "product runtime claim"
    autonomous_agents_exist = "autonomous-agent claim"
    autonomous_agent_claimed = "autonomous-agent claim"
    autonomous_agents_implemented = "autonomous-agent claim"
    actual_autonomous_agents_implemented = "autonomous-agent claim"
    external_integrations_exist = "external-integration claim"
    external_integration_claimed = "external-integration claim"
    external_integrations_implemented = "external-integration claim"
    executable_handoffs_exist = "executable handoff claim"
    executable_handoffs_claimed = "executable handoff claim"
    handoff_executable = "executable handoff claim"
    executable_transitions_exist = "executable transition claim"
    executable_transitions_claimed = "executable transition claim"
    transition_execution_permitted = "executable transition claim"
    solved_codex_compaction = "solved Codex compaction claim"
    solved_codex_compaction_claimed = "solved Codex compaction claim"
    solved_codex_reliability = "solved Codex reliability claim"
    solved_codex_reliability_claimed = "solved Codex reliability claim"
    r16_027_or_later_task_exists = "R16-027 or later task claim"
    r16_027_or_later_task_claimed = "R16-027 or later task claim"
    r13_closed = "R13 closure claim"
    r13_closure_claimed = "R13 closure claim"
    r13_partial_gate_conversion_claimed = "R13 partial-gate conversion claim"
    partial_gates_converted_to_passed = "R13 partial-gate conversion claim"
    r14_caveat_removal_claimed = "R14 caveat removal"
    r14_caveats_removed = "R14 caveat removal"
    r15_caveat_removal_claimed = "R15 caveat removal"
    r15_caveats_removed = "R15 caveat removal"
    caveats_removed = "caveat removal"
    main_merge_claimed = "main merge claim"
    main_merge_completed = "main merge claim"
}

function Test-HasProperty {
    param(
        [AllowNull()]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject.Contains($Name)
    }

    return $null -ne $InputObject -and $InputObject.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-HasProperty -InputObject $InputObject -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject[$Name]
    }

    return $InputObject.PSObject.Properties[$Name].Value
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return [string]$Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    try {
        return [int64]$Value
    }
    catch {
        throw "$Context must be an integer."
    }
}

function Assert-ObjectValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [System.Array] -or $Value -isnot [pscustomobject]) {
        throw "$Context must be a JSON object."
    }

    return $Value
}

function Assert-StringArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string]) {
        throw "$Context must be an array of strings."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context $Context | Out-Null
    }

    return [string[]]$items
}

function Assert-ObjectArray {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string]) {
        throw "$Context must be an array of JSON objects."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    return [object[]]$items
}

function Assert-RequiredStringsPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $Required) {
        if ($Actual -notcontains $requiredValue) {
            throw "$Context is missing required value '$requiredValue'."
        }
    }
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $missing = @($Expected | Where-Object { $Actual -notcontains $_ })
    $extra = @($Actual | Where-Object { $Expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue.Trim().Replace("\", "/")
}

function Get-RepositoryRoot {
    param([AllowNull()][string]$RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $RepositoryRoot = $repoRoot
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\", "repo", "repository", "full_repo", "entire_repo", "all", "all_files", "**", "**/*")
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    return $PathValue -match '[\*\?\[\]]'
}

function Test-ScratchTempPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = (ConvertTo-NormalizedRepoPath -PathValue $PathValue).ToLowerInvariant()
    return $normalized -match '(^|/)(scratch|tmp|temp)(/|$)' -or $normalized -match '\.tmp($|\.)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    return $normalized -match '^[A-Za-z][A-Za-z0-9+\.-]*://' -or $normalized -match '^git@' -or $normalized -match '^(origin|upstream|refs)/' -or $normalized -match '^[^@\s]+@[^:\s]+:'
}

function Test-DirectoryOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    if ($normalized.EndsWith("/")) {
        return $true
    }
    if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)' -or (Test-RemoteOrUrlRef -PathValue $normalized)) {
        return $false
    }

    $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return Test-Path -LiteralPath $candidatePath -PathType Container
}

function Test-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -PathValue $PathValue
    try {
        & git -C $RepositoryRoot ls-files --error-unmatch -- $normalized 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Assert-SafeRepoRelativePath {
    param(
        [AllowNull()][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireTracked
    )

    $pathString = Assert-NonEmptyString -Value $PathValue -Context "$Context path"
    $normalized = ConvertTo-NormalizedRepoPath -PathValue $pathString

    if (Test-BroadRepoRootPath -PathValue $normalized) {
        throw "$Context path '$pathString' is a broad repo root ref."
    }
    if (Test-RemoteOrUrlRef -PathValue $normalized) {
        throw "$Context path '$pathString' is a URL or remote ref."
    }
    if ([System.IO.Path]::IsPathRooted($pathString) -or $pathString -match '^[A-Za-z]:[\\/]') {
        throw "$Context path '$pathString' is an absolute path."
    }
    if (Test-WildcardPath -PathValue $normalized) {
        throw "$Context path '$pathString' contains a wildcard path."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context path '$pathString' contains parent traversal path."
    }
    if (Test-ScratchTempPath -PathValue $normalized) {
        throw "$Context path '$pathString' is a scratch/temp path."
    }
    if (Test-DirectoryOnlyPath -PathValue $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context path '$pathString' is a directory-only ref."
    }

    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $normalized))
    $rootWithSeparator = $resolvedRoot + [System.IO.Path]::DirectorySeparatorChar
    if ($resolvedPath -ne $resolvedRoot -and -not $resolvedPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path '$pathString' escapes the repository root."
    }
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$pathString' must resolve to an existing file."
    }
    if ($RequireTracked -and -not (Test-GitTrackedPath -PathValue $normalized -RepositoryRoot $resolvedRoot)) {
        throw "$Context path '$pathString' must be an exact repo-relative tracked file."
    }

    return $normalized
}

function Assert-NoForbiddenTrueClaims {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey([string]$key) -and $Value[$key] -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[[string]$key])."
            }
            Assert-NoForbiddenTrueClaims -Value $Value[$key] -Context $Context
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Assert-NoForbiddenTrueClaims -Value $item -Context $Context
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            if ($script:ForbiddenTrueBooleanClaims.ContainsKey($property.Name) -and $property.Value -eq $true) {
                throw "$Context rejects $($script:ForbiddenTrueBooleanClaims[$property.Name])."
            }
            Assert-NoForbiddenTrueClaims -Value $property.Value -Context $Context
        }
    }
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json -replace "`r`n", "`n"
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($PathValue)
    $directory = [System.IO.Path]::GetDirectoryName($resolvedPath)
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = ConvertTo-StableJson -Object $InputObject
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($resolvedPath, ($json + [Environment]::NewLine), $utf8NoBom)
}

function Get-GitScalar {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )

    $output = & git -C $RepositoryRoot @GitArgs 2>$null
    if ($LASTEXITCODE -ne 0 -or $null -eq $output) {
        return $null
    }

    return [string](@($output)[0]).Trim()
}

function Get-CurrentHead {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

    return Get-GitScalar -RepositoryRoot $RepositoryRoot -GitArgs @("rev-parse", "HEAD")
}

function Get-CurrentTree {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

    $tree = Get-GitScalar -RepositoryRoot $RepositoryRoot -GitArgs @("rev-parse", "HEAD^{tree}")
    if ([string]::IsNullOrWhiteSpace($tree)) {
        return "unavailable"
    }

    return $tree
}

function Get-FileMetric {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [switch]$RequireTracked
    )

    $normalized = Assert-SafeRepoRelativePath -PathValue $PathValue -RepositoryRoot $RepositoryRoot -Context $PathValue -RequireTracked:$RequireTracked
    $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    $item = Get-Item -LiteralPath $resolvedPath

    return [pscustomobject][ordered]@{
        path = $normalized
        byte_count = [int64]$item.Length
        line_count = [int64](@([System.IO.File]::ReadLines($resolvedPath)).Count)
        tracked_file = (Test-GitTrackedPath -PathValue $normalized -RepositoryRoot $RepositoryRoot)
    }
}

function New-R16RefObject {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)]$Spec,
        [Parameter(Mandatory = $true)][int]$Order,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [switch]$RequireTracked
    )

    $metric = Get-FileMetric -PathValue $Spec.Path -RepositoryRoot $RepositoryRoot -RequireTracked:$RequireTracked
    $caveats = [string[]]$Spec.Caveats
    if ($caveats.Count -eq 0) {
        $caveats = [string[]]@("none")
    }

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        path = [string]$metric.path
        source_task = [string]$Spec.SourceTask
        artifact_kind = [string]$Spec.ArtifactKind
        proof_treatment = [string]$Spec.ProofTreatment
        authority_level = [string]$Spec.AuthorityLevel
        machine_proof = $false
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        deterministic_order = $Order
        caveats = [string[]]$caveats
        byte_count = [int64]$metric.byte_count
        line_count = [int64]$metric.line_count
        tracked_file = [bool]$metric.tracked_file
    }
}

function New-R16RefObjectList {
    param(
        [Parameter(Mandatory = $true)]$Specs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [int]$StartOrder = 1,
        [switch]$RequireTracked
    )

    $items = @()
    $order = $StartOrder
    foreach ($key in $Specs.Keys) {
        $spec = $Specs[$key]
        $mustBeTracked = $RequireTracked -and ($script:CurrentTaskOutputPaths -notcontains $spec.Path)
        $items += New-R16RefObject -RefId $key -Spec $spec -Order $order -RepositoryRoot $RepositoryRoot -RequireTracked:$mustBeTracked
        $order += 1
    }

    return [object[]]$items
}

function New-NoFullRepoScanPolicy {
    return [pscustomobject][ordered]@{
        repo_relative_exact_paths_only = $true
        canonical_refs_tracked_files_only = $true
        broad_repo_scan_allowed = $false
        broad_repo_scan_performed = $false
        full_repo_scan_allowed = $false
        full_repo_scan_performed = $false
        wildcard_path_expansion_allowed = $false
        wildcard_path_expansion_performed = $false
        wildcard_paths_allowed = $false
        directory_only_refs_allowed = $false
        scratch_temp_refs_allowed = $false
        absolute_paths_allowed = $false
        parent_traversal_allowed = $false
        url_or_remote_refs_allowed = $false
    }
}

function New-RawChatHistoryPolicy {
    return [pscustomobject][ordered]@{
        canonical_evidence_source = "exact_repo_backed_artifacts_only"
        raw_chat_history_as_canonical_evidence = $false
        raw_chat_history_as_canonical_state = $false
        raw_chat_history_loaded = $false
        raw_chat_history_loading_allowed = $false
        raw_chat_history_as_evidence_allowed = $false
    }
}

function New-PreservedBoundaries {
    return [pscustomobject][ordered]@{
        r13 = [pscustomobject][ordered]@{
            status = "failed_partial_through_r13_018_only"
            closed = $false
            r13_closed = $false
            partial_gates_remain_partial = $true
            partial_gates_converted_to_passed = $false
        }
        r14 = [pscustomobject][ordered]@{
            status = "accepted_with_caveats_through_r14_006_only"
            caveats_removed = $false
            r14_caveats_removed = $false
            product_runtime = $false
        }
        r15 = [pscustomobject][ordered]@{
            status = "accepted_with_caveats_through_r15_009_only"
            caveats_removed = $false
            r15_caveats_removed = $false
            stale_generated_from_caveat_preserved = $true
        }
    }
}

function Get-R16AcceptedTasks {
    return [string[]](1..25 | ForEach-Object { "R16-{0:000}" -f $_ })
}

function Get-RequiredFindingIds {
    param(
        [AllowNull()]$Collection,
        [Parameter(Mandatory = $true)][string]$PropertyName
    )

    $items = @($Collection)
    return [string[]]($items | ForEach-Object {
            if (Test-HasProperty -InputObject $_ -Name $PropertyName) {
                [string]$_.PSObject.Properties[$PropertyName].Value
            }
        } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function New-EvidenceHygieneFindings {
    return [object[]]@(
        [pscustomobject][ordered]@{ finding_id = "generated_state_artifacts_not_runtime_proof"; classification = "generated state artifacts are evidence artifacts, not runtime proof"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "generated_reports_not_automatic_machine_proof"; classification = "generated reports are not automatically machine proof"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "operator_observed_process_evidence_not_machine_proof"; classification = "operator-observed process evidence is not machine proof"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "raw_chat_history_not_canonical_evidence"; classification = "raw chat history is not canonical evidence"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "exact_repo_backed_artifacts_are_canonical_refs"; classification = "exact repo-backed artifacts are canonical evidence refs"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "r15_stale_generated_from_caveat_preserved"; classification = "R15 stale generated_from caveat remains preserved"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "r13_failed_partial_not_closed"; classification = "R13 remains failed/partial and not closed"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "r14_caveats_preserved"; classification = "R14 caveats remain preserved"; machine_proof = $false },
        [pscustomobject][ordered]@{ finding_id = "r15_caveats_preserved"; classification = "R15 caveats remain preserved"; machine_proof = $false }
    )
}

function New-R16AcceptedScopeByPhase {
    return [object[]]@(
        [pscustomobject][ordered]@{ phase = "Phase 1"; task_range = "R16-001 through R16-003"; summary = "R16 opening, planning authority, and KPI scorecard."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 2"; task_range = "R16-004 through R16-008"; summary = "Memory layer contracts, deterministic memory layers, role memory packs, and stale-ref validation."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 3"; task_range = "R16-009 through R16-013"; summary = "Artifact map, audit map, and artifact/audit consistency check."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 4"; task_range = "R16-014 through R16-017"; summary = "Context-load planner, budget estimator, and failed-closed guard."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 5"; task_range = "R16-018 through R16-021"; summary = "Role-run envelope contract/generator, RACI transition gate, and handoff packets."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 6"; task_range = "R16-022 through R16-025"; summary = "Restart/compaction recovery drill, role-handoff drill, audit-readiness drill, and friction metrics."; proof_status = "accepted_task_refs_indexed" },
        [pscustomobject][ordered]@{ phase = "Phase 7"; task_range = "R16-026"; summary = "R16-026 final proof/review package candidate and final-head support packet only."; proof_status = "candidate_generated_artifacts_only" }
    )
}

function New-R16FinalProofReviewPackageObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $head = Get-CurrentHead -RepositoryRoot $resolvedRoot
    $tree = Get-CurrentTree -RepositoryRoot $resolvedRoot
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_budget_guard_report.json") -Label "R16 context budget guard report"
    $friction = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/governance/r16_friction_metrics_report.json") -Label "R16 friction metrics report"
    $auditReadiness = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/audit/r16_audit_readiness_drill.json") -Label "R16 audit-readiness drill"
    $roleHandoff = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/workflow/r16_role_handoff_drill.json") -Label "R16 role-handoff drill"

    $guardUpperBound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
    $guardThreshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
    $thresholdExceeded = [bool]$guard.evaluated_budget.threshold_exceeded
    $exactEvidenceRefs = New-R16RefObjectList -Specs $script:RequiredExactEvidenceRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $proofReviewRefs = New-R16RefObjectList -Specs $script:RequiredProofReviewRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $validationManifestRefs = New-R16RefObjectList -Specs $script:RequiredValidationManifestRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $stateArtifactRefs = New-R16RefObjectList -Specs $script:RequiredStateArtifactRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $contractRefs = New-R16RefObjectList -Specs $script:RequiredContractRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $toolRefs = New-R16RefObjectList -Specs $script:RequiredToolRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $testRefs = New-R16RefObjectList -Specs $script:RequiredTestRefs -RepositoryRoot $resolvedRoot -RequireTracked
    $acceptedTasks = Get-R16AcceptedTasks

    $frictionFindingIds = Get-RequiredFindingIds -Collection $friction.process_friction_findings -PropertyName "finding_id"
    $operationalFindings = @($friction.process_friction_findings | ForEach-Object {
            [pscustomobject][ordered]@{
                finding_id = [string]$_.finding_id
                source_task = "R16-025"
                evidence_class = [string]$_.evidence_class
                machine_proof = $false
                summary = [string]$_.summary
            }
        })

    return [pscustomobject][ordered]@{
        artifact_type = "r16_final_proof_review_package"
        package_version = $script:PackageVersion
        package_id = $script:PackageId
        source_milestone = $script:R16Milestone
        source_task = "R16-026"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [pscustomobject][ordered]@{
            implementation_pass_only = $true
            generated_package_path = $script:PackagePath
            generated_evidence_index_path = $script:EvidenceIndexPath
            generated_final_head_support_packet_path = $script:FinalHeadSupportPacketPath
            current_task_outputs_pending_finalization_commit = $true
            finalization_commit_completed = $false
            external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
            runtime_execution_claimed = $false
            executable_handoffs_claimed = $false
            executable_transitions_claimed = $false
            broad_repo_scan_performed = $false
            full_repo_scan_performed = $false
            raw_chat_history_loaded = $false
        }
        generated_from_head = $head
        generated_from_tree = $tree
        accepted_task_range = [pscustomobject][ordered]@{
            start_task = "R16-001"
            end_task = "R16-025"
            task_count = 25
            accepted_tasks = [string[]]$acceptedTasks
        }
        r16_026_package_status = $script:PackageStatus
        exact_evidence_refs = [object[]]$exactEvidenceRefs
        proof_review_refs = [object[]]$proofReviewRefs
        validation_manifest_refs = [object[]]$validationManifestRefs
        state_artifact_refs = [object[]]$stateArtifactRefs
        contract_refs = [object[]]$contractRefs
        tool_refs = [object[]]$toolRefs
        test_refs = [object[]]$testRefs
        current_guard_posture = [pscustomobject][ordered]@{
            guard_verdict = [string]$guard.aggregate_verdict
            expected_failed_closed = $true
            failed_closed_is_expected_signal = $true
            latest_accepted_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            threshold_exceeded = $thresholdExceeded
            mitigation_created = $false
            no_provider_tokenization = $true
            no_provider_billing = $true
            no_executable_envelopes = $true
            no_executable_handoffs = $true
            no_executable_transitions = $true
            guard_remains_expected_and_unresolved = $true
        }
        context_budget_summary = [pscustomobject][ordered]@{
            context_budget_estimate_ref = "state/context/r16_context_budget_estimate.json"
            context_budget_guard_ref = "state/context/r16_context_budget_guard_report.json"
            guard_verdict = [string]$guard.aggregate_verdict
            latest_accepted_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            threshold_exceeded = $thresholdExceeded
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            provider_tokenizer_used = $false
            provider_pricing_used = $false
            mitigation_created = $false
        }
        friction_metrics_summary = [pscustomobject][ordered]@{
            source_ref = "state/governance/r16_friction_metrics_report.json"
            source_task = "R16-025"
            aggregate_verdict = [string]$friction.aggregate_verdict
            finding_ids = [string[]]$frictionFindingIds
            finding_count = $frictionFindingIds.Count
            codex_auto_compaction_failures_captured = $true
            codex_auto_compaction_failures_solved = $false
            fixture_bloat_and_compact_mutation_fixture_mitigation = $true
            untracked_file_visibility_gap_and_line_counting = $true
            deterministic_byte_line_drift_and_regeneration_cascade_cost = $true
            validator_allowlist_update_cost = $true
            finalization_split_pressure_b1_b2_recommendation = $true
            powershell_tooling_friction = $true
            large_generated_json_context_pressure = $true
            failed_closed_guard_expected_signal = $true
            runtime_non_solution_boundary = $true
            machine_proof = $false
        }
        audit_readiness_summary = [pscustomobject][ordered]@{
            source_ref = "state/audit/r16_audit_readiness_drill.json"
            source_task = "R16-024"
            aggregate_verdict = [string]$auditReadiness.aggregate_verdict
            exact_audit_input_count = [int64]$auditReadiness.finding_summary.exact_audit_input_count
            proof_review_ref_count = [int64]$auditReadiness.finding_summary.proof_review_ref_count
            final_r16_audit_acceptance_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            machine_proof = $false
        }
        workflow_boundary_summary = [pscustomobject][ordered]@{
            role_run_envelope_ref = "state/workflow/r16_role_run_envelopes.json"
            raci_transition_gate_ref = "state/workflow/r16_raci_transition_gate_report.json"
            handoff_packet_report_ref = "state/workflow/r16_handoff_packet_report.json"
            role_handoff_drill_ref = "state/workflow/r16_role_handoff_drill.json"
            executable_handoff_count = [int64]$roleHandoff.executable_handoff_count
            executable_transition_count = [int64]$roleHandoff.executable_transition_count
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            executable_envelopes_exist = $false
            runtime_handoff_execution_claimed = $false
        }
        accepted_scope_summary_by_phase = [object[]](New-R16AcceptedScopeByPhase)
        blocked_execution_summary = [pscustomobject][ordered]@{
            guard_verdict = [string]$guard.aggregate_verdict
            latest_accepted_upper_bound = $guardUpperBound
            threshold = $guardThreshold
            guard_blocks_execution = $true
            no_mitigation = $true
            runtime_execution_claimed = $false
            runtime_memory_claimed = $false
            retrieval_runtime_claimed = $false
            vector_search_runtime_claimed = $false
            product_runtime_claimed = $false
            autonomous_agent_claimed = $false
            external_integration_claimed = $false
            executable_handoffs_claimed = $false
            executable_transitions_claimed = $false
        }
        evidence_hygiene_findings = [object[]](New-EvidenceHygieneFindings)
        operational_friction_findings = [object[]]$operationalFindings
        final_validation_commands = [string[]]$script:RequiredValidationCommands
        current_posture = [pscustomobject][ordered]@{
            accepted_through_task = "R16-025"
            current_task = "R16-026"
            r16_026_final_package_candidate_exists_only_as_generated_state_artifacts = $true
            r16_027_or_later_task_exists = $false
            external_audit_acceptance_claimed = $false
            final_external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
            closeout_completion_claimed = $false
            final_proof_package_completion_claimed = $false
            runtime_execution_exists = $false
            runtime_execution_claimed = $false
            runtime_memory_exists = $false
            runtime_memory_claimed = $false
            retrieval_runtime_exists = $false
            retrieval_runtime_claimed = $false
            vector_search_runtime_exists = $false
            vector_search_runtime_claimed = $false
            product_runtime_exists = $false
            product_runtime_claimed = $false
            autonomous_agents_exist = $false
            autonomous_agent_claimed = $false
            external_integrations_exist = $false
            external_integration_claimed = $false
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        preserved_boundaries = New-PreservedBoundaries
        non_claims = [string[]]$script:RequiredNonClaims
        external_audit_instructions = [pscustomobject][ordered]@{
            reviewer_should_use_exact_repo_backed_refs = $true
            reviewer_should_not_treat_raw_chat_history_as_canonical = $true
            reviewer_should_not_treat_generated_reports_as_automatic_machine_proof = $true
            reviewer_may_run_final_validation_commands = [string[]]$script:RequiredValidationCommands
            no_external_audit_acceptance_claimed_by_this_package = $true
            no_main_merge_claimed_by_this_package = $true
        }
        no_full_repo_scan_policy = New-NoFullRepoScanPolicy
        raw_chat_history_policy = New-RawChatHistoryPolicy
        aggregate_verdict = $script:AggregateVerdict
    }
}

function New-R16FinalEvidenceIndexObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $head = Get-CurrentHead -RepositoryRoot $resolvedRoot
    $tree = Get-CurrentTree -RepositoryRoot $resolvedRoot
    $entries = New-R16RefObjectList -Specs $script:RequiredExactEvidenceRefs -RepositoryRoot $resolvedRoot -RequireTracked

    return [pscustomobject][ordered]@{
        artifact_type = "r16_final_evidence_index"
        index_version = $script:PackageVersion
        index_id = $script:EvidenceIndexId
        source_milestone = $script:R16Milestone
        source_task = "R16-026"
        repository = $script:Repository
        branch = $script:Branch
        generated_from_head = $head
        generated_from_tree = $tree
        indexed_entries = [object[]]$entries
        no_full_repo_scan_policy = New-NoFullRepoScanPolicy
        evidence_hygiene_policy = [pscustomobject][ordered]@{
            generated_state_artifacts_are_evidence_artifacts_not_runtime_proof = $true
            generated_reports_are_not_automatically_machine_proof = $true
            operator_observed_process_evidence_is_not_machine_proof = $true
            raw_chat_history_is_not_canonical_evidence = $true
            exact_repo_backed_artifacts_are_canonical_evidence_refs = $true
            report_as_machine_proof_allowed = $false
        }
        non_claims = [string[]]$script:RequiredNonClaims
        aggregate_verdict = $script:AggregateVerdict
    }
}

function New-R16FinalHeadSupportPacketObject {
    [CmdletBinding()]
    param([string]$RepositoryRoot)

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $head = Get-CurrentHead -RepositoryRoot $resolvedRoot
    $tree = Get-CurrentTree -RepositoryRoot $resolvedRoot
    $guard = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_budget_guard_report.json") -Label "R16 context budget guard report"

    return [pscustomobject][ordered]@{
        artifact_type = "r16_final_head_support_packet"
        packet_version = $script:PackageVersion
        packet_id = $script:FinalHeadPacketId
        source_milestone = $script:R16Milestone
        source_task = "R16-026"
        repository = $script:Repository
        branch = $script:Branch
        observed_head = $head
        observed_tree = $tree
        previous_accepted_baseline = $script:PreviousAcceptedBaseline
        validation_command_list = [string[]]$script:RequiredValidationCommands
        expected_final_scope = [pscustomobject][ordered]@{
            r16_026_final_proof_review_package_candidate = $true
            accepted_task_range = "R16-001 through R16-025"
            no_r16_027_or_later_task = $true
            no_external_audit_acceptance = $true
            no_main_merge = $true
            no_runtime_execution = $true
            no_executable_handoffs = $true
            no_executable_transitions = $true
        }
        non_claims = [string[]]$script:RequiredNonClaims
        preserved_boundaries = New-PreservedBoundaries
        final_audit_candidate_statement = "This packet supports external/pro audit review of an R16-026 final proof/review package candidate only; it does not claim external audit acceptance or main merge."
        no_main_merge_attestation = [pscustomobject][ordered]@{
            main_merge_claimed = $false
            main_merge_completed = $false
            attestation = "No merge to main is claimed by this generated packet."
        }
        no_external_audit_acceptance_attestation = [pscustomobject][ordered]@{
            external_audit_acceptance_claimed = $false
            final_external_audit_acceptance_claimed = $false
            attestation = "No external/pro audit acceptance is claimed by this generated packet."
        }
        current_guard_posture = [pscustomobject][ordered]@{
            guard_verdict = [string]$guard.aggregate_verdict
            latest_accepted_upper_bound = [int64]$guard.evaluated_budget.estimated_tokens_upper_bound
            threshold = [int64]$guard.evaluated_budget.max_estimated_tokens_upper_bound
            threshold_exceeded = [bool]$guard.evaluated_budget.threshold_exceeded
            guard_remains_expected_and_unresolved = $true
            exact_provider_tokenization_claimed = $false
            exact_provider_billing_claimed = $false
            mitigation_created = $false
            executable_handoffs_exist = $false
            executable_transitions_exist = $false
        }
        aggregate_verdict = $script:AggregateVerdict
    }
}

function Assert-PolicyBooleans {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in @("repo_relative_exact_paths_only", "canonical_refs_tracked_files_only")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }

    foreach ($fieldName in @("broad_repo_scan_allowed", "broad_repo_scan_performed", "full_repo_scan_allowed", "full_repo_scan_performed", "wildcard_path_expansion_allowed", "wildcard_path_expansion_performed", "wildcard_paths_allowed", "directory_only_refs_allowed", "scratch_temp_refs_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context rejects $fieldName."
        }
    }
}

function Assert-RawChatPolicy {
    param(
        [Parameter(Mandatory = $true)]$Policy,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($fieldName in @("raw_chat_history_as_canonical_evidence", "raw_chat_history_as_canonical_state", "raw_chat_history_loaded", "raw_chat_history_loading_allowed", "raw_chat_history_as_evidence_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $Policy -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context rejects raw chat history as canonical evidence."
        }
    }
}

function Assert-RefObject {
    param(
        [Parameter(Mandatory = $true)]$RefObject,
        [Parameter(Mandatory = $true)]$ExpectedSpec,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [switch]$RequireTracked
    )

    Assert-ObjectValue -Value $RefObject -Context $Context | Out-Null
    $expectedPath = [string]$ExpectedSpec.Path
    $mustBeTracked = $RequireTracked -and ($script:CurrentTaskOutputPaths -notcontains $expectedPath)
    $path = Assert-SafeRepoRelativePath -PathValue (Get-RequiredProperty -InputObject $RefObject -Name "path" -Context $Context) -RepositoryRoot $RepositoryRoot -Context $Context -RequireTracked:$mustBeTracked
    if ($path -ne $expectedPath) {
        throw "$Context path must be '$expectedPath'."
    }

    foreach ($fieldName in @("ref_id", "source_task", "artifact_kind", "proof_treatment", "authority_level")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName" | Out-Null
    }
    if ([string]$RefObject.source_task -ne [string]$ExpectedSpec.SourceTask) {
        throw "$Context source_task must be '$($ExpectedSpec.SourceTask)'."
    }
    if ([string]$RefObject.artifact_kind -ne [string]$ExpectedSpec.ArtifactKind) {
        throw "$Context artifact_kind must be '$($ExpectedSpec.ArtifactKind)'."
    }
    if ([int64](Get-RequiredProperty -InputObject $RefObject -Name "deterministic_order" -Context $Context) -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
    foreach ($fieldName in @("exact_path_only")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $true) {
            throw "$Context $fieldName must be True."
        }
    }
    foreach ($fieldName in @("broad_scan_allowed", "wildcard_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $RefObject -Name $fieldName -Context $Context) -Context "$Context $fieldName") -ne $false) {
            throw "$Context $fieldName must be False."
        }
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -InputObject $RefObject -Name "machine_proof" -Context $Context) -Context "$Context machine_proof") -ne $false) {
        throw "$Context rejects report-as-machine-proof misuse."
    }
    $caveatValue = Get-RequiredProperty -InputObject $RefObject -Name "caveats" -Context $Context
    if ($caveatValue -is [string]) {
        Assert-NonEmptyString -Value $caveatValue -Context "$Context caveats" | Out-Null
    }
    else {
        Assert-StringArray -Value $caveatValue -Context "$Context caveats" -AllowEmpty | Out-Null
    }
}

function Assert-RefList {
    param(
        [Parameter(Mandatory = $true)]$ActualRefs,
        [Parameter(Mandatory = $true)]$ExpectedRefs,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [switch]$RequireTracked
    )

    $items = @(Assert-ObjectArray -Value $ActualRefs -Context $Context)
    if ($items.Count -ne $ExpectedRefs.Count) {
        throw "$Context must include exactly $($ExpectedRefs.Count) refs."
    }

    $expectedKeys = @($ExpectedRefs.Keys)
    for ($index = 0; $index -lt $items.Count; $index += 1) {
        $key = $expectedKeys[$index]
        if ([string]$items[$index].ref_id -ne [string]$key) {
            throw "$Context[$index] ref_id must be '$key'."
        }
        Assert-RefObject -RefObject $items[$index] -ExpectedSpec $ExpectedRefs[$key] -Context "$Context[$index]" -RepositoryRoot $RepositoryRoot -ExpectedOrder ($index + 1) -RequireTracked:$RequireTracked
    }

    return [object[]]$items
}

function Assert-GuardPosture {
    param(
        [Parameter(Mandatory = $true)]$GuardPosture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-ObjectValue -Value $GuardPosture -Context $Context | Out-Null
    if ([string](Get-RequiredProperty -InputObject $GuardPosture -Name "guard_verdict" -Context $Context) -ne $script:GuardVerdict) {
        throw "$Context guard verdict must be '$script:GuardVerdict'."
    }
    if ([int64](Get-RequiredProperty -InputObject $GuardPosture -Name "latest_accepted_upper_bound" -Context $Context) -ne $script:ExpectedGuardUpperBound) {
        throw "$Context latest accepted upper bound must be $script:ExpectedGuardUpperBound."
    }
    if ([int64](Get-RequiredProperty -InputObject $GuardPosture -Name "threshold" -Context $Context) -ne $script:ExpectedThreshold) {
        throw "$Context threshold must be $script:ExpectedThreshold."
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Preserved,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-ObjectValue -Value $Preserved -Context $Context | Out-Null
    if ([bool]$Preserved.r13.closed -ne $false -or [bool]$Preserved.r13.r13_closed -ne $false) {
        throw "$Context rejects R13 closure claim."
    }
    if ([bool]$Preserved.r13.partial_gates_converted_to_passed -ne $false) {
        throw "$Context rejects R13 partial-gate conversion claim."
    }
    if ([bool]$Preserved.r14.caveats_removed -ne $false -or [bool]$Preserved.r14.r14_caveats_removed -ne $false) {
        throw "$Context rejects R14 caveat removal."
    }
    if ([bool]$Preserved.r15.caveats_removed -ne $false -or [bool]$Preserved.r15.r15_caveats_removed -ne $false) {
        throw "$Context rejects R15 caveat removal."
    }
}

function Assert-FinalValidationCommands {
    param(
        [Parameter(Mandatory = $true)]$Commands,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-ExactStringSet -Actual (Assert-StringArray -Value $Commands -Context $Context) -Expected $script:RequiredValidationCommands -Context $Context
}

function Assert-NonClaims {
    param(
        [Parameter(Mandatory = $true)]$NonClaims,
        [Parameter(Mandatory = $true)][string]$Context
    )

    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $NonClaims -Context $Context) -Required $script:RequiredNonClaims -Context $Context
}

function Test-R16FinalProofReviewPackageObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Package,
        [string]$SourceLabel = "R16 final proof/review package",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredPackageFields) {
        Get-RequiredProperty -InputObject $Package -Name $fieldName -Context $SourceLabel | Out-Null
    }

    if ([string]$Package.artifact_type -ne "r16_final_proof_review_package") {
        throw "$SourceLabel artifact_type must be 'r16_final_proof_review_package'."
    }
    if ([string]$Package.package_version -ne $script:PackageVersion -or [string]$Package.package_id -ne $script:PackageId) {
        throw "$SourceLabel package identity is incorrect."
    }
    if ([string]$Package.source_milestone -ne $script:R16Milestone -or [string]$Package.source_task -ne "R16-026") {
        throw "$SourceLabel source identity must be R16-026."
    }
    if ([string]$Package.repository -ne $script:Repository -or [string]$Package.branch -ne $script:Branch) {
        throw "$SourceLabel repository or branch is incorrect."
    }
    if ([string]$Package.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel aggregate_verdict must be '$script:AggregateVerdict'."
    }
    if ([string]$Package.r16_026_package_status -ne $script:PackageStatus) {
        throw "$SourceLabel r16_026_package_status must be '$script:PackageStatus'."
    }

    Assert-NoForbiddenTrueClaims -Value $Package -Context $SourceLabel

    Assert-NonEmptyString -Value (Get-RequiredProperty -InputObject $Package -Name "generated_from_head" -Context $SourceLabel) -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -InputObject $Package -Name "generated_from_tree" -Context $SourceLabel) -Context "$SourceLabel generated_from_tree" | Out-Null

    $taskRange = Assert-ObjectValue -Value (Get-RequiredProperty -InputObject $Package -Name "accepted_task_range" -Context $SourceLabel) -Context "$SourceLabel accepted_task_range"
    if ([string]$taskRange.start_task -ne "R16-001" -or [string]$taskRange.end_task -ne "R16-025" -or [int64]$taskRange.task_count -ne 25) {
        throw "$SourceLabel accepted_task_range must be R16-001 through R16-025."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $taskRange.accepted_tasks -Context "$SourceLabel accepted_task_range accepted_tasks") -Expected (Get-R16AcceptedTasks) -Context "$SourceLabel accepted_task_range accepted_tasks"

    $exactEvidenceRefs = Assert-RefList -ActualRefs $Package.exact_evidence_refs -ExpectedRefs $script:RequiredExactEvidenceRefs -Context "$SourceLabel exact_evidence_refs" -RepositoryRoot $resolvedRoot -RequireTracked
    $proofReviewRefs = Assert-RefList -ActualRefs $Package.proof_review_refs -ExpectedRefs $script:RequiredProofReviewRefs -Context "$SourceLabel proof_review_refs" -RepositoryRoot $resolvedRoot -RequireTracked
    $validationRefs = Assert-RefList -ActualRefs $Package.validation_manifest_refs -ExpectedRefs $script:RequiredValidationManifestRefs -Context "$SourceLabel validation_manifest_refs" -RepositoryRoot $resolvedRoot -RequireTracked
    Assert-RefList -ActualRefs $Package.state_artifact_refs -ExpectedRefs $script:RequiredStateArtifactRefs -Context "$SourceLabel state_artifact_refs" -RepositoryRoot $resolvedRoot -RequireTracked | Out-Null
    Assert-RefList -ActualRefs $Package.contract_refs -ExpectedRefs $script:RequiredContractRefs -Context "$SourceLabel contract_refs" -RepositoryRoot $resolvedRoot -RequireTracked | Out-Null
    Assert-RefList -ActualRefs $Package.tool_refs -ExpectedRefs $script:RequiredToolRefs -Context "$SourceLabel tool_refs" -RepositoryRoot $resolvedRoot -RequireTracked | Out-Null
    Assert-RefList -ActualRefs $Package.test_refs -ExpectedRefs $script:RequiredTestRefs -Context "$SourceLabel test_refs" -RepositoryRoot $resolvedRoot -RequireTracked | Out-Null

    Assert-GuardPosture -GuardPosture $Package.current_guard_posture -Context "$SourceLabel current_guard_posture"

    $contextBudget = Assert-ObjectValue -Value $Package.context_budget_summary -Context "$SourceLabel context_budget_summary"
    if ([string]$contextBudget.guard_verdict -ne $script:GuardVerdict -or [int64]$contextBudget.latest_accepted_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$contextBudget.threshold -ne $script:ExpectedThreshold) {
        throw "$SourceLabel context_budget_summary must preserve failed-closed guard values."
    }
    foreach ($fieldName in @("exact_provider_tokenization_claimed", "exact_provider_billing_claimed", "provider_tokenizer_used", "provider_pricing_used", "mitigation_created")) {
        if ((Assert-BooleanValue -Value $contextBudget.$fieldName -Context "$SourceLabel context_budget_summary $fieldName") -ne $false) {
            throw "$SourceLabel rejects $fieldName."
        }
    }

    $friction = Assert-ObjectValue -Value $Package.friction_metrics_summary -Context "$SourceLabel friction_metrics_summary"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $friction.finding_ids -Context "$SourceLabel friction_metrics_summary finding_ids") -Required $script:RequiredOperationalFrictionFindingIds -Context "$SourceLabel friction_metrics_summary finding_ids"
    if ((Assert-BooleanValue -Value $friction.codex_auto_compaction_failures_solved -Context "$SourceLabel friction_metrics_summary codex_auto_compaction_failures_solved") -ne $false) {
        throw "$SourceLabel rejects solved Codex compaction claim."
    }

    $auditSummary = Assert-ObjectValue -Value $Package.audit_readiness_summary -Context "$SourceLabel audit_readiness_summary"
    foreach ($fieldName in @("final_r16_audit_acceptance_claimed", "closeout_completion_claimed", "final_proof_package_completion_claimed")) {
        if ((Assert-BooleanValue -Value $auditSummary.$fieldName -Context "$SourceLabel audit_readiness_summary $fieldName") -ne $false) {
            throw "$SourceLabel rejects final external audit acceptance claim."
        }
    }

    $workflow = Assert-ObjectValue -Value $Package.workflow_boundary_summary -Context "$SourceLabel workflow_boundary_summary"
    if ([int64]$workflow.executable_handoff_count -ne 0 -or [int64]$workflow.executable_transition_count -ne 0) {
        throw "$SourceLabel workflow_boundary_summary rejects executable handoff or transition claim."
    }

    $phases = Assert-ObjectArray -Value $Package.accepted_scope_summary_by_phase -Context "$SourceLabel accepted_scope_summary_by_phase"
    if ($phases.Count -ne 7) {
        throw "$SourceLabel accepted_scope_summary_by_phase must include seven phase summaries."
    }

    Assert-ObjectValue -Value $Package.blocked_execution_summary -Context "$SourceLabel blocked_execution_summary" | Out-Null
    $hygieneFindings = Assert-ObjectArray -Value $Package.evidence_hygiene_findings -Context "$SourceLabel evidence_hygiene_findings"
    Assert-RequiredStringsPresent -Actual (Get-RequiredFindingIds -Collection $hygieneFindings -PropertyName "finding_id") -Required $script:RequiredEvidenceHygieneFindingIds -Context "$SourceLabel evidence_hygiene_findings"
    $operationalFindings = Assert-ObjectArray -Value $Package.operational_friction_findings -Context "$SourceLabel operational_friction_findings"
    Assert-RequiredStringsPresent -Actual (Get-RequiredFindingIds -Collection $operationalFindings -PropertyName "finding_id") -Required $script:RequiredOperationalFrictionFindingIds -Context "$SourceLabel operational_friction_findings"

    Assert-FinalValidationCommands -Commands $Package.final_validation_commands -Context "$SourceLabel final_validation_commands"

    $currentPosture = Assert-ObjectValue -Value $Package.current_posture -Context "$SourceLabel current_posture"
    if ([string]$currentPosture.accepted_through_task -ne "R16-025" -or [string]$currentPosture.current_task -ne "R16-026") {
        throw "$SourceLabel current_posture must be accepted through R16-025 with current task R16-026."
    }
    if ((Assert-BooleanValue -Value $currentPosture.r16_026_final_package_candidate_exists_only_as_generated_state_artifacts -Context "$SourceLabel current_posture r16_026 candidate") -ne $true) {
        throw "$SourceLabel must state R16-026 final package candidate exists only as generated state artifacts."
    }

    Assert-PreservedBoundaries -Preserved $Package.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    Assert-NonClaims -NonClaims $Package.non_claims -Context "$SourceLabel non_claims"
    Assert-ObjectValue -Value $Package.external_audit_instructions -Context "$SourceLabel external_audit_instructions" | Out-Null
    Assert-PolicyBooleans -Policy $Package.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    Assert-RawChatPolicy -Policy $Package.raw_chat_history_policy -Context "$SourceLabel raw_chat_history_policy"

    return [pscustomobject]@{
        PackageId = [string]$Package.package_id
        SourceTask = [string]$Package.source_task
        AggregateVerdict = [string]$Package.aggregate_verdict
        GeneratedFromHead = [string]$Package.generated_from_head
        GeneratedFromTree = [string]$Package.generated_from_tree
        ExactEvidenceRefCount = $exactEvidenceRefs.Count
        ProofReviewRefCount = $proofReviewRefs.Count
        ValidationManifestRefCount = $validationRefs.Count
        GuardVerdict = [string]$Package.current_guard_posture.guard_verdict
        LatestGuardUpperBound = [int64]$Package.current_guard_posture.latest_accepted_upper_bound
        Threshold = [int64]$Package.current_guard_posture.threshold
        OperationalFrictionFindingCount = $operationalFindings.Count
    }
}

function Test-R16FinalEvidenceIndexObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$EvidenceIndex,
        [string]$SourceLabel = "R16 final evidence index",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredEvidenceIndexFields) {
        Get-RequiredProperty -InputObject $EvidenceIndex -Name $fieldName -Context $SourceLabel | Out-Null
    }
    if ([string]$EvidenceIndex.artifact_type -ne "r16_final_evidence_index") {
        throw "$SourceLabel artifact_type must be 'r16_final_evidence_index'."
    }
    if ([string]$EvidenceIndex.source_task -ne "R16-026" -or [string]$EvidenceIndex.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel source identity or aggregate verdict is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $EvidenceIndex -Context $SourceLabel
    $entries = Assert-RefList -ActualRefs $EvidenceIndex.indexed_entries -ExpectedRefs $script:RequiredExactEvidenceRefs -Context "$SourceLabel indexed_entries" -RepositoryRoot $resolvedRoot -RequireTracked
    Assert-PolicyBooleans -Policy $EvidenceIndex.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    Assert-NonClaims -NonClaims $EvidenceIndex.non_claims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        IndexId = [string]$EvidenceIndex.index_id
        SourceTask = [string]$EvidenceIndex.source_task
        IndexedEvidenceCount = $entries.Count
        AggregateVerdict = [string]$EvidenceIndex.aggregate_verdict
    }
}

function Test-R16FinalHeadSupportPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$SupportPacket,
        [string]$SourceLabel = "R16 final-head support packet",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($fieldName in $script:RequiredFinalHeadPacketFields) {
        Get-RequiredProperty -InputObject $SupportPacket -Name $fieldName -Context $SourceLabel | Out-Null
    }
    if ([string]$SupportPacket.artifact_type -ne "r16_final_head_support_packet") {
        throw "$SourceLabel artifact_type must be 'r16_final_head_support_packet'."
    }
    if ([string]$SupportPacket.source_task -ne "R16-026" -or [string]$SupportPacket.aggregate_verdict -ne $script:AggregateVerdict) {
        throw "$SourceLabel source identity or aggregate verdict is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $SupportPacket -Context $SourceLabel
    Assert-NonEmptyString -Value $SupportPacket.observed_head -Context "$SourceLabel observed_head" | Out-Null
    Assert-NonEmptyString -Value $SupportPacket.observed_tree -Context "$SourceLabel observed_tree" | Out-Null
    if ([string]$SupportPacket.previous_accepted_baseline -ne $script:PreviousAcceptedBaseline) {
        throw "$SourceLabel previous_accepted_baseline must be $script:PreviousAcceptedBaseline."
    }
    $currentHead = Get-CurrentHead -RepositoryRoot $resolvedRoot
    if (-not [string]::IsNullOrWhiteSpace($currentHead) -and [string]$SupportPacket.observed_head -ne $currentHead) {
        throw "$SourceLabel observed_head must match current local HEAD."
    }
    Assert-FinalValidationCommands -Commands $SupportPacket.validation_command_list -Context "$SourceLabel validation_command_list"
    Assert-NonClaims -NonClaims $SupportPacket.non_claims -Context "$SourceLabel non_claims"
    Assert-PreservedBoundaries -Preserved $SupportPacket.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    Assert-GuardPosture -GuardPosture $SupportPacket.current_guard_posture -Context "$SourceLabel current_guard_posture"

    return [pscustomobject]@{
        PacketId = [string]$SupportPacket.packet_id
        SourceTask = [string]$SupportPacket.source_task
        ObservedHead = [string]$SupportPacket.observed_head
        ObservedTree = [string]$SupportPacket.observed_tree
        PreviousAcceptedBaseline = [string]$SupportPacket.previous_accepted_baseline
        ValidationCommandCount = @($SupportPacket.validation_command_list).Count
        GuardVerdict = [string]$SupportPacket.current_guard_posture.guard_verdict
        LatestGuardUpperBound = [int64]$SupportPacket.current_guard_posture.latest_accepted_upper_bound
        Threshold = [int64]$SupportPacket.current_guard_posture.threshold
        AggregateVerdict = [string]$SupportPacket.aggregate_verdict
    }
}

function Test-R16FinalProofReviewPackage {
    [CmdletBinding()]
    param(
        [string]$Path = $script:PackagePath,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $package = Read-SingleJsonObject -Path $resolvedPath -Label "R16 final proof/review package"
    return Test-R16FinalProofReviewPackageObject -Package $package -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function Test-R16FinalEvidenceIndex {
    [CmdletBinding()]
    param(
        [string]$Path = $script:EvidenceIndexPath,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $index = Read-SingleJsonObject -Path $resolvedPath -Label "R16 final evidence index"
    return Test-R16FinalEvidenceIndexObject -EvidenceIndex $index -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function Test-R16FinalHeadSupportPacket {
    [CmdletBinding()]
    param(
        [string]$Path = $script:FinalHeadSupportPacketPath,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $packet = Read-SingleJsonObject -Path $resolvedPath -Label "R16 final-head support packet"
    return Test-R16FinalHeadSupportPacketObject -SupportPacket $packet -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function Test-R16FinalProofReviewPackageSet {
    [CmdletBinding()]
    param(
        [string]$PackagePath = $script:PackagePath,
        [string]$EvidenceIndexPath = $script:EvidenceIndexPath,
        [string]$FinalHeadSupportPacketPath = $script:FinalHeadSupportPacketPath,
        [string]$RepositoryRoot
    )

    $packageResult = Test-R16FinalProofReviewPackage -Path $PackagePath -RepositoryRoot $RepositoryRoot
    $indexResult = Test-R16FinalEvidenceIndex -Path $EvidenceIndexPath -RepositoryRoot $RepositoryRoot
    $packetResult = Test-R16FinalHeadSupportPacket -Path $FinalHeadSupportPacketPath -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        PackageId = $packageResult.PackageId
        EvidenceIndexId = $indexResult.IndexId
        FinalHeadPacketId = $packetResult.PacketId
        AggregateVerdict = $packageResult.AggregateVerdict
        ExactEvidenceRefCount = $packageResult.ExactEvidenceRefCount
        IndexedEvidenceCount = $indexResult.IndexedEvidenceCount
        ProofReviewRefCount = $packageResult.ProofReviewRefCount
        ValidationManifestRefCount = $packageResult.ValidationManifestRefCount
        GuardVerdict = $packageResult.GuardVerdict
        LatestGuardUpperBound = $packageResult.LatestGuardUpperBound
        Threshold = $packageResult.Threshold
        ObservedHead = $packetResult.ObservedHead
        ObservedTree = $packetResult.ObservedTree
        PreviousAcceptedBaseline = $packetResult.PreviousAcceptedBaseline
        ValidationCommandCount = $packetResult.ValidationCommandCount
    }
}

function New-R16FinalProofReviewPackageSet {
    [CmdletBinding()]
    param(
        [string]$OutputRoot = $script:PackageRoot,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $normalizedOutputRoot = ConvertTo-NormalizedRepoPath -PathValue $OutputRoot
    $resolvedOutputRoot = if ([System.IO.Path]::IsPathRooted($OutputRoot)) { $OutputRoot } else { Join-Path $resolvedRoot $normalizedOutputRoot }
    $packagePath = Join-Path $resolvedOutputRoot "r16_final_proof_review_package.json"
    $indexPath = Join-Path $resolvedOutputRoot "evidence_index.json"
    $packetPath = Join-Path $resolvedOutputRoot "final_head_support_packet.json"

    Write-StableJsonFile -InputObject (New-R16FinalProofReviewPackageObject -RepositoryRoot $resolvedRoot) -PathValue $packagePath
    Write-StableJsonFile -InputObject (New-R16FinalEvidenceIndexObject -RepositoryRoot $resolvedRoot) -PathValue $indexPath
    Write-StableJsonFile -InputObject (New-R16FinalHeadSupportPacketObject -RepositoryRoot $resolvedRoot) -PathValue $packetPath

    function ConvertTo-RepoRelativePath {
        param([Parameter(Mandatory = $true)][string]$FullPath)

        $root = [System.IO.Path]::GetFullPath($resolvedRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
        $full = [System.IO.Path]::GetFullPath($FullPath)
        $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
        if (-not $full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Generated path '$FullPath' is outside repository root."
        }

        return ConvertTo-NormalizedRepoPath -PathValue $full.Substring($prefix.Length)
    }

    $packageRel = ConvertTo-RepoRelativePath -FullPath $packagePath
    $indexRel = ConvertTo-RepoRelativePath -FullPath $indexPath
    $packetRel = ConvertTo-RepoRelativePath -FullPath $packetPath
    $validation = Test-R16FinalProofReviewPackageSet -PackagePath $packageRel -EvidenceIndexPath $indexRel -FinalHeadSupportPacketPath $packetRel -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputRoot = $normalizedOutputRoot
        PackagePath = $packageRel
        EvidenceIndexPath = $indexRel
        FinalHeadSupportPacketPath = $packetRel
        PackageId = $validation.PackageId
        EvidenceIndexId = $validation.EvidenceIndexId
        FinalHeadPacketId = $validation.FinalHeadPacketId
        AggregateVerdict = $validation.AggregateVerdict
        ExactEvidenceRefCount = $validation.ExactEvidenceRefCount
        IndexedEvidenceCount = $validation.IndexedEvidenceCount
        ProofReviewRefCount = $validation.ProofReviewRefCount
        ValidationManifestRefCount = $validation.ValidationManifestRefCount
        GuardVerdict = $validation.GuardVerdict
        LatestGuardUpperBound = $validation.LatestGuardUpperBound
        Threshold = $validation.Threshold
        ObservedHead = $validation.ObservedHead
        ObservedTree = $validation.ObservedTree
        PreviousAcceptedBaseline = $validation.PreviousAcceptedBaseline
        ValidationCommandCount = $validation.ValidationCommandCount
    }
}

function Test-R16FinalProofReviewPackageContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/governance/r16_final_proof_review_package.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -PathValue $Path) }
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 final proof/review package contract"
    foreach ($fieldName in @("artifact_type", "contract_version", "contract_id", "source_milestone", "source_task", "repository", "branch", "required_package_fields", "required_evidence_index_fields", "required_final_head_packet_fields", "required_exact_evidence_paths", "package_policy", "guard_policy", "no_full_repo_scan_policy", "raw_chat_history_policy", "required_non_claims", "required_validation_commands", "invalid_state_policy")) {
        Get-RequiredProperty -InputObject $contract -Name $fieldName -Context "R16 final proof/review package contract" | Out-Null
    }
    if ([string]$contract.artifact_type -ne "r16_final_proof_review_package_contract" -or [string]$contract.source_task -ne "R16-026") {
        throw "R16 final proof/review package contract identity is incorrect."
    }
    Assert-NoForbiddenTrueClaims -Value $contract -Context "R16 final proof/review package contract"
    Assert-PolicyBooleans -Policy $contract.no_full_repo_scan_policy -Context "R16 final proof/review package contract no_full_repo_scan_policy"
    Assert-RawChatPolicy -Policy $contract.raw_chat_history_policy -Context "R16 final proof/review package contract raw_chat_history_policy"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_package_fields -Context "R16 final proof/review package contract required_package_fields") -Required $script:RequiredPackageFields -Context "R16 final proof/review package contract required_package_fields"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_evidence_index_fields -Context "R16 final proof/review package contract required_evidence_index_fields") -Required $script:RequiredEvidenceIndexFields -Context "R16 final proof/review package contract required_evidence_index_fields"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $contract.required_final_head_packet_fields -Context "R16 final proof/review package contract required_final_head_packet_fields") -Required $script:RequiredFinalHeadPacketFields -Context "R16 final proof/review package contract required_final_head_packet_fields"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $contract.required_exact_evidence_paths -Context "R16 final proof/review package contract required_exact_evidence_paths") -Expected ([string[]]($script:RequiredExactEvidenceRefs.Keys | ForEach-Object { $script:RequiredExactEvidenceRefs[$_].Path })) -Context "R16 final proof/review package contract required_exact_evidence_paths"
    Assert-NonClaims -NonClaims $contract.required_non_claims -Context "R16 final proof/review package contract required_non_claims"
    Assert-FinalValidationCommands -Commands $contract.required_validation_commands -Context "R16 final proof/review package contract required_validation_commands"
    if ([string]$contract.package_policy.aggregate_verdict_required -ne $script:AggregateVerdict -or [string]$contract.package_policy.package_status_required -ne $script:PackageStatus) {
        throw "R16 final proof/review package contract package policy is incorrect."
    }
    if ([string]$contract.guard_policy.guard_verdict_required -ne $script:GuardVerdict -or [int64]$contract.guard_policy.latest_accepted_guard_upper_bound -ne $script:ExpectedGuardUpperBound -or [int64]$contract.guard_policy.threshold -ne $script:ExpectedThreshold) {
        throw "R16 final proof/review package contract guard policy is incorrect."
    }

    return [pscustomobject]@{
        ContractId = [string]$contract.contract_id
        SourceTask = [string]$contract.source_task
        RequiredPackageFieldCount = @($contract.required_package_fields).Count
        RequiredEvidencePathCount = @($contract.required_exact_evidence_paths).Count
        RequiredValidationCommandCount = @($contract.required_validation_commands).Count
    }
}

function New-R16FinalProofReviewPackageFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_final_proof_review_package",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $fixtureRootPath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $fixtureRootPath -Force | Out-Null

    $validPackage = New-R16FinalProofReviewPackageObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -InputObject $validPackage -PathValue (Join-Path $fixtureRootPath "valid_final_proof_review_package.json")

    function New-MutationFixtureSpec {
        param(
            [Parameter(Mandatory = $true)][string]$FixtureId,
            [Parameter(Mandatory = $true)][string]$MutationPath,
            [Parameter(Mandatory = $true)]$MutationValue,
            [Parameter(Mandatory = $true)][string[]]$ExpectedFailure
        )

        return [pscustomobject][ordered]@{
            fixture_id = $FixtureId
            base_fixture = "valid_final_proof_review_package.json"
            mutation_path = $MutationPath
            mutation_value = $MutationValue
            expected_failure = [string[]]$ExpectedFailure
        }
    }

    $fixtureSpecs = [ordered]@{
        "invalid_missing_required_top_level_field.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_required_top_level_field" -MutationPath '$.generation_boundary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generation_boundary'")
        "invalid_missing_generated_from_head.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_generated_from_head" -MutationPath '$.generated_from_head' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'generated_from_head'")
        "invalid_missing_accepted_task_range.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_accepted_task_range" -MutationPath '$.accepted_task_range' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'accepted_task_range'")
        "invalid_missing_exact_evidence_refs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_exact_evidence_refs" -MutationPath '$.exact_evidence_refs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'exact_evidence_refs'")
        "invalid_missing_proof_review_refs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_proof_review_refs" -MutationPath '$.proof_review_refs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'proof_review_refs'")
        "invalid_missing_validation_manifest_refs.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_validation_manifest_refs" -MutationPath '$.validation_manifest_refs' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'validation_manifest_refs'")
        "invalid_missing_current_guard_posture.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_current_guard_posture" -MutationPath '$.current_guard_posture' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'current_guard_posture'")
        "invalid_missing_friction_metrics_summary.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_friction_metrics_summary" -MutationPath '$.friction_metrics_summary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'friction_metrics_summary'")
        "invalid_missing_audit_readiness_summary.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_audit_readiness_summary" -MutationPath '$.audit_readiness_summary' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'audit_readiness_summary'")
        "invalid_missing_preserved_boundaries.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_preserved_boundaries" -MutationPath '$.preserved_boundaries' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'preserved_boundaries'")
        "invalid_missing_non_claims.json" = New-MutationFixtureSpec -FixtureId "invalid_missing_non_claims" -MutationPath '$.non_claims' -MutationValue "__REMOVE_PROPERTY__" -ExpectedFailure @("missing required field 'non_claims'")
        "invalid_guard_verdict_not_failed_closed.json" = New-MutationFixtureSpec -FixtureId "invalid_guard_verdict_not_failed_closed" -MutationPath '$.current_guard_posture.guard_verdict' -MutationValue "passed" -ExpectedFailure @("guard verdict")
        "invalid_threshold_changed.json" = New-MutationFixtureSpec -FixtureId "invalid_threshold_changed" -MutationPath '$.current_guard_posture.threshold' -MutationValue 150001 -ExpectedFailure @("threshold must be 150000")
        "invalid_executable_handoff_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_handoff_claim" -MutationPath '$.current_posture.executable_handoffs_exist' -MutationValue $true -ExpectedFailure @("executable handoff claim")
        "invalid_executable_transition_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_executable_transition_claim" -MutationPath '$.current_posture.executable_transitions_exist' -MutationValue $true -ExpectedFailure @("executable transition claim")
        "invalid_runtime_execution_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_execution_claim" -MutationPath '$.current_posture.runtime_execution_claimed' -MutationValue $true -ExpectedFailure @("runtime execution claim")
        "invalid_runtime_memory_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_runtime_memory_claim" -MutationPath '$.current_posture.runtime_memory_exists' -MutationValue $true -ExpectedFailure @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_retrieval_runtime_claim" -MutationPath '$.current_posture.retrieval_runtime_exists' -MutationValue $true -ExpectedFailure @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_vector_search_runtime_claim" -MutationPath '$.current_posture.vector_search_runtime_exists' -MutationValue $true -ExpectedFailure @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_product_runtime_claim" -MutationPath '$.current_posture.product_runtime_exists' -MutationValue $true -ExpectedFailure @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_autonomous_agent_claim" -MutationPath '$.current_posture.autonomous_agents_exist' -MutationValue $true -ExpectedFailure @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_external_integration_claim" -MutationPath '$.current_posture.external_integrations_exist' -MutationValue $true -ExpectedFailure @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_compaction_claim" -MutationPath '$.current_posture.solved_codex_compaction' -MutationValue $true -ExpectedFailure @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_solved_codex_reliability_claim" -MutationPath '$.current_posture.solved_codex_reliability' -MutationValue $true -ExpectedFailure @("solved Codex reliability claim")
        "invalid_final_external_audit_acceptance_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_final_external_audit_acceptance_claim" -MutationPath '$.current_posture.external_audit_acceptance_claimed' -MutationValue $true -ExpectedFailure @("final external audit acceptance claim")
        "invalid_main_merge_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_main_merge_claim" -MutationPath '$.current_posture.main_merge_claimed' -MutationValue $true -ExpectedFailure @("main merge claim")
        "invalid_r13_closure_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_closure_claim" -MutationPath '$.preserved_boundaries.r13.r13_closed' -MutationValue $true -ExpectedFailure @("R13 closure claim")
        "invalid_r13_partial_gate_conversion_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r13_partial_gate_conversion_claim" -MutationPath '$.preserved_boundaries.r13.partial_gates_converted_to_passed' -MutationValue $true -ExpectedFailure @("R13 partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r14_caveat_removal" -MutationPath '$.preserved_boundaries.r14.r14_caveats_removed' -MutationValue $true -ExpectedFailure @("R14 caveat removal")
        "invalid_r15_caveat_removal.json" = New-MutationFixtureSpec -FixtureId "invalid_r15_caveat_removal" -MutationPath '$.preserved_boundaries.r15.r15_caveats_removed' -MutationValue $true -ExpectedFailure @("R15 caveat removal")
        "invalid_raw_chat_history_as_canonical_evidence.json" = New-MutationFixtureSpec -FixtureId "invalid_raw_chat_history_as_canonical_evidence" -MutationPath '$.raw_chat_history_policy.raw_chat_history_as_canonical_evidence' -MutationValue $true -ExpectedFailure @("raw chat history as canonical evidence")
        "invalid_full_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_full_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.full_repo_scan_performed' -MutationValue $true -ExpectedFailure @("full repo scan claim")
        "invalid_broad_repo_scan_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_broad_repo_scan_claim" -MutationPath '$.no_full_repo_scan_policy.broad_repo_scan_performed' -MutationValue $true -ExpectedFailure @("broad repo scan claim")
        "invalid_wildcard_path.json" = New-MutationFixtureSpec -FixtureId "invalid_wildcard_path" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "state/*.json" -ExpectedFailure @("wildcard path")
        "invalid_directory_only_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_directory_only_ref" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "state/context/" -ExpectedFailure @("directory-only ref")
        "invalid_scratch_temp_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_scratch_temp_ref" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "scratch/r16_final.tmp.json" -ExpectedFailure @("scratch/temp path")
        "invalid_absolute_path.json" = New-MutationFixtureSpec -FixtureId "invalid_absolute_path" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "C:/tmp/r16_final.json" -ExpectedFailure @("absolute path")
        "invalid_parent_traversal_path.json" = New-MutationFixtureSpec -FixtureId "invalid_parent_traversal_path" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "../state/context/r16_context_load_plan.json" -ExpectedFailure @("parent traversal path")
        "invalid_url_or_remote_ref.json" = New-MutationFixtureSpec -FixtureId "invalid_url_or_remote_ref" -MutationPath '$.exact_evidence_refs[0].path' -MutationValue "https://example.invalid/r16_context_load_plan.json" -ExpectedFailure @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = New-MutationFixtureSpec -FixtureId "invalid_report_as_machine_proof_misuse" -MutationPath '$.exact_evidence_refs[0].machine_proof' -MutationValue $true -ExpectedFailure @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_tokenization_claim" -MutationPath '$.context_budget_summary.exact_provider_tokenization_claimed' -MutationValue $true -ExpectedFailure @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_exact_provider_billing_claim" -MutationPath '$.context_budget_summary.exact_provider_billing_claimed' -MutationValue $true -ExpectedFailure @("exact provider billing claim")
        "invalid_r16_027_or_later_task_claim.json" = New-MutationFixtureSpec -FixtureId "invalid_r16_027_or_later_task_claim" -MutationPath '$.current_posture.r16_027_or_later_task_exists' -MutationValue $true -ExpectedFailure @("R16-027 or later task claim")
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        Write-StableJsonFile -InputObject $fixtureSpecs[$fixtureName] -PathValue (Join-Path $fixtureRootPath $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_final_proof_review_package.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16FinalProofReviewPackageObject, New-R16FinalEvidenceIndexObject, New-R16FinalHeadSupportPacketObject, New-R16FinalProofReviewPackageSet, Test-R16FinalProofReviewPackageObject, Test-R16FinalProofReviewPackage, Test-R16FinalEvidenceIndexObject, Test-R16FinalEvidenceIndex, Test-R16FinalHeadSupportPacketObject, Test-R16FinalHeadSupportPacket, Test-R16FinalProofReviewPackageSet, Test-R16FinalProofReviewPackageContract, New-R16FinalProofReviewPackageFixtureFiles, ConvertTo-StableJson
