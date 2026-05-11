Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:SourceTask = "R17-028"
$script:BaselineHead = "f7321a114f9946dd1d35e0aadbc78ae53892a908"
$script:BaselineTree = "65ad8fe9a79e848850a24b7796da124a54523fbe"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_evidence_package"
$script:SupportRoot = "state/final_head_support/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:FixtureRoot = "tests/fixtures/r17_final_evidence_package"
$script:AggregateVerdict = "r17_closeout_candidate_operator_decision_required"

function Resolve-R17FinalEvidencePackagePath {
    param(
        [string]$RepositoryRoot = $script:RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Write-R17FinalEvidencePackageJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Value | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17FinalEvidencePackageText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Read-R17FinalEvidencePackageJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-R17FinalEvidencePackageObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Test-R17FinalEvidencePackageHasProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17FinalEvidencePackagePaths {
    param([string]$RepositoryRoot = $script:RepositoryRoot)

    return [pscustomobject]@{
        FinalReport = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/reports/AIOffice_V2_R17_Final_Report_and_R18_Planning_Report_v1.md"
        KpiScorecard = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "state/governance/r17_final_kpi_movement_scorecard.json"
        KpiContract = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/governance/r17_final_kpi_movement_scorecard.contract.json"
        EvidenceIndex = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ProofReview = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        ValidationManifest = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        FinalHeadSupportPacket = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "$($script:SupportRoot)/r17_028_final_head_support_packet.json"
        R18PlanningBrief = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "governance/plans/AIOffice_V2_R18_Automated_Recovery_Runtime_and_API_Orchestration_Plan_v1.md"
        FixtureRoot = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17FinalEvidencePackagePath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
    }
}

function Get-R17FinalEvidencePackageValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_final_evidence_package.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_final_evidence_package.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_final_evidence_package.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R17FinalEvidencePackageNonClaims {
    return @(
        "no live recovery-loop runtime",
        "no automatic new-thread creation",
        "no OpenAI API invocation",
        "no Codex API invocation",
        "no autonomous Codex invocation",
        "no live execution harness runtime",
        "no live agent runtime",
        "no live A2A runtime",
        "no adapter runtime",
        "no actual tool call",
        "no product runtime",
        "no main merge",
        "no external audit acceptance",
        "no R17 closeout without operator approval",
        "no no-manual-prompt-transfer success claim",
        "no solved Codex compaction claim",
        "no solved Codex reliability claim"
    )
}

function Get-R17FinalEvidencePackageRejectedClaims {
    return @(
        "R17 closed without operator approval",
        "R18 opened",
        "main merge claimed",
        "external audit acceptance claimed",
        "four exercised A2A cycles claimed",
        "live A2A runtime claimed",
        "live recovery-loop runtime claimed",
        "automatic new-thread creation claimed",
        "OpenAI API invocation claimed",
        "Codex API invocation claimed",
        "solved compaction claimed",
        "solved reliability claimed",
        "no-manual-prompt-transfer success claimed",
        "product runtime claimed",
        "historical R13/R14/R15/R16 evidence edits",
        "operator local backup directory references",
        "kanban.js changes",
        "broad repo scan output",
        "oversized generated artifacts"
    )
}

function Get-R17FinalEvidencePackagePositiveClaims {
    return [pscustomobject][ordered]@{
        r17_final_evidence_package_created = $true
        kpi_movement_package_created = $true
        r18_planning_brief_created = $true
        compact_failure_finding_preserved = $true
        operator_decision_package_created = $true
    }
}

function Get-R17FinalEvidencePackageRuntimeFlags {
    return [pscustomobject][ordered]@{
        r17_closed = $false
        r18_opened = $false
        main_merge_claimed = $false
        external_audit_acceptance_claimed = $false
        four_exercised_a2a_cycles_claimed = $false
        live_a2a_runtime_implemented = $false
        live_recovery_loop_runtime_implemented = $false
        automatic_new_thread_creation_performed = $false
        openai_api_invoked = $false
        codex_api_invoked = $false
        autonomous_codex_invocation_performed = $false
        live_execution_harness_runtime_implemented = $false
        live_agent_runtime_invoked = $false
        adapter_runtime_invoked = $false
        actual_tool_call_performed = $false
        product_runtime_executed = $false
        no_manual_prompt_transfer_success_claimed = $false
        solved_codex_compaction_claimed = $false
        solved_codex_reliability_claimed = $false
        operator_approval_recorded = $false
    }
}

function Get-R17FinalEvidencePackageEvidenceRefs {
    return @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/reports/AIOffice_V2_R17_Final_Report_and_R18_Planning_Report_v1.md",
        "governance/plans/AIOffice_V2_R18_Automated_Recovery_Runtime_and_API_Orchestration_Plan_v1.md",
        "state/governance/r17_final_kpi_movement_scorecard.json",
        "contracts/governance/r17_final_kpi_movement_scorecard.contract.json",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/validation_manifest.md",
        "$($script:SupportRoot)/r17_028_final_head_support_packet.json",
        "tools/R17FinalEvidencePackage.psm1",
        "tools/new_r17_final_evidence_package.ps1",
        "tools/validate_r17_final_evidence_package.ps1",
        "tests/test_r17_final_evidence_package.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json"
    )
}

function Get-R17FinalEvidencePackageAllowedPaths {
    return @(
        "governance/reports/AIOffice_V2_R17_Final_Report_and_R18_Planning_Report_v1.md",
        "governance/plans/AIOffice_V2_R18_Automated_Recovery_Runtime_and_API_Orchestration_Plan_v1.md",
        "state/governance/r17_final_kpi_movement_scorecard.json",
        "contracts/governance/r17_final_kpi_movement_scorecard.contract.json",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/validation_manifest.md",
        "$($script:SupportRoot)/r17_028_final_head_support_packet.json",
        "tools/R17FinalEvidencePackage.psm1",
        "tools/new_r17_final_evidence_package.ps1",
        "tools/validate_r17_final_evidence_package.ps1",
        "tests/test_r17_final_evidence_package.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
        "$($script:FixtureRoot)/invalid_r17_closed_without_operator_approval.json",
        "$($script:FixtureRoot)/invalid_r18_opened.json",
        "$($script:FixtureRoot)/invalid_main_merge_claimed.json",
        "$($script:FixtureRoot)/invalid_external_audit_acceptance_claimed.json",
        "$($script:FixtureRoot)/invalid_four_cycles_claimed.json",
        "$($script:FixtureRoot)/invalid_live_a2a_runtime_claimed.json",
        "$($script:FixtureRoot)/invalid_live_recovery_runtime_claimed.json",
        "$($script:FixtureRoot)/invalid_automatic_new_thread_creation_claimed.json",
        "$($script:FixtureRoot)/invalid_openai_api_invoked.json",
        "$($script:FixtureRoot)/invalid_codex_api_invoked.json",
        "$($script:FixtureRoot)/invalid_solved_compaction_claimed.json",
        "$($script:FixtureRoot)/invalid_solved_reliability_claimed.json",
        "$($script:FixtureRoot)/invalid_no_manual_prompt_transfer_success.json",
        "$($script:FixtureRoot)/invalid_product_runtime_claimed.json",
        "$($script:FixtureRoot)/invalid_local_backups_reference.json",
        "$($script:FixtureRoot)/invalid_broad_repo_scan_output.json",
        "$($script:FixtureRoot)/invalid_oversized_generated_artifacts.json",
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/DECISION_LOG.md",
        "governance/reports/AIOffice_V2_R17_External_Audit_and_R18_Planning_Report_v1.md",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/governance/r17_operator_closeout_decision.contract.json",
        "contracts/governance/r18_opening_authority.contract.json",
        "state/governance/r18_opening_authority.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/planning/r18_automated_recovery_runtime_and_api_orchestration/r18_001_opening_authority_manifest.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/validation_manifest.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tools/validate_r17_operator_closeout_decision.ps1",
        "tools/validate_r18_opening_authority.ps1",
        "tests/test_status_doc_gate.ps1",
        "tests/test_r17_operator_closeout_decision.ps1",
        "tests/test_r18_opening_authority.ps1"
    )
}

function New-R17FinalEvidencePackageDomainRows {
    return @(
        [pscustomobject][ordered]@{ segment_category = "Product Experience & Double-Diamond Workflow"; r16_baseline_score = 35; r17_target_score = 70; r17_achieved_score = 40; score_movement = 5; evidence_refs = @("scripts/operator_wall/r17_kanban_mvp/", "state/ui/r17_kanban_mvp/r17_*_snapshot.json"); justification = "Read-only/static surfaces and packet evidence improved inspectability, but no product runtime exists." },
        [pscustomobject][ordered]@{ segment_category = "Board & Work Orchestration"; r16_baseline_score = 60; r17_target_score = 80; r17_achieved_score = 68; score_movement = 8; evidence_refs = @("contracts/board/", "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/", "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_023_cycle_1_definition/", "state/cycles/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_024_cycle_2_dev_execution/"); justification = "Repo-backed board/card/event packets and two packet-only cycle packages improved orchestration evidence, but no live board mutation or runtime loop exists." },
        [pscustomobject][ordered]@{ segment_category = "Agent Workforce & RACI"; r16_baseline_score = 70; r17_target_score = 85; r17_achieved_score = 74; score_movement = 4; evidence_refs = @("state/agents/r17_agent_registry.json", "state/agents/r17_agent_identities/", "state/runtime/r17_agent_invocation_log.jsonl"); justification = "Identity, role, memory, and invocation-log foundations improved separation of duties; no live agents were invoked." },
        [pscustomobject][ordered]@{ segment_category = "Knowledge, Memory & Context Compression"; r16_baseline_score = 70; r17_target_score = 80; r17_achieved_score = 72; score_movement = 2; evidence_refs = @("state/context/r17_memory_artifact_loader_report.json", "state/agents/r17_agent_memory_packets/", "state/runtime/r17_compact_safe_execution_harness_prompt_packets/", "state/runtime/r17_automated_recovery_loop_prompt_packets/"); justification = "Exact-ref loading and compact prompt packets improved context discipline; Codex compaction remains unsolved." },
        [pscustomobject][ordered]@{ segment_category = "Execution Harness & QA"; r16_baseline_score = 65; r17_target_score = 80; r17_achieved_score = 70; score_movement = 5; evidence_refs = @("contracts/runtime/r17_compact_safe_execution_harness.contract.json", "contracts/runtime/r17_compact_safe_harness_pilot.contract.json", "contracts/tools/r17_qa_test_agent_adapter.contract.json"); justification = "Harness and QA adapter foundations improved future execution control; no live QA runtime or Cycle 3 QA/fix-loop execution was delivered." },
        [pscustomobject][ordered]@{ segment_category = "Governance, Evidence & Audit"; r16_baseline_score = 70; r17_target_score = 85; r17_achieved_score = 80; score_movement = 10; evidence_refs = @("state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/", "tools/validate_status_doc_gate.ps1", "state/governance/r17_final_kpi_movement_scorecard.json"); justification = "Task-level proof packages, non-claim gates, and this final package materially improved auditability." },
        [pscustomobject][ordered]@{ segment_category = "Architecture & Integrations"; r16_baseline_score = 40; r17_target_score = 70; r17_achieved_score = 55; score_movement = 15; evidence_refs = @("contracts/tools/r17_tool_adapter.contract.json", "contracts/a2a/r17_a2a_message.contract.json", "contracts/a2a/r17_a2a_dispatcher.contract.json"); justification = "Adapter, A2A, dispatcher, and tool-ledger contracts improved architecture; no live integration runtime or API invocation exists." },
        [pscustomobject][ordered]@{ segment_category = "Release & Environment Strategy"; r16_baseline_score = 70; r17_target_score = 80; r17_achieved_score = 72; score_movement = 2; evidence_refs = @("governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md", "state/final_head_support/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_head_support_packet.json"); justification = "Branch/status/final-head support evidence improved release posture modestly; no main merge or closure occurred." },
        [pscustomobject][ordered]@{ segment_category = "Security, Safety & Cost Controls"; r16_baseline_score = 60; r17_target_score = 80; r17_achieved_score = 70; score_movement = 10; evidence_refs = @("contracts/runtime/r17_stop_retry_reentry_controls.contract.json", "contracts/runtime/r17_automated_recovery_loop.contract.json", "state/runtime/r17_automated_recovery_loop_*"); justification = "Stop/retry/re-entry and recovery-loop models improved safety/cost control foundations; live automated recovery remains absent." },
        [pscustomobject][ordered]@{ segment_category = "Continuous Improvement & Auto-Research"; r16_baseline_score = 60; r17_target_score = 75; r17_achieved_score = 74; score_movement = 14; evidence_refs = @("state/runtime/r17_compact_safe_execution_harness_*", "state/runtime/r17_compact_safe_harness_pilot_cycle_3_*", "state/runtime/r17_automated_recovery_loop_*"); justification = "The compact-failure finding forced a concrete pivot into smaller work orders and recovery foundations; improvement is process learning, not automation success." }
    )
}

function New-R17FinalKpiMovementScorecard {
    $rows = @(New-R17FinalEvidencePackageDomainRows)
    $weighted = 0
    foreach ($row in $rows) {
        $weight = switch ($row.segment_category) {
            "Product Experience & Double-Diamond Workflow" { 12 }
            "Board & Work Orchestration" { 12 }
            "Agent Workforce & RACI" { 14 }
            "Knowledge, Memory & Context Compression" { 12 }
            "Execution Harness & QA" { 14 }
            "Governance, Evidence & Audit" { 8 }
            "Architecture & Integrations" { 8 }
            "Release & Environment Strategy" { 6 }
            "Security, Safety & Cost Controls" { 8 }
            "Continuous Improvement & Auto-Research" { 6 }
        }
        $row | Add-Member -NotePropertyName weight -NotePropertyValue $weight -Force
        $weighted += ($weight * [double]$row.r17_achieved_score)
    }

    return [pscustomobject][ordered]@{
        artifact_type = "r17_final_kpi_movement_scorecard"
        contract_version = "v1"
        scorecard_id = "aioffice-r17-028-final-kpi-movement-scorecard-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = $script:Repository
        branch = $script:BranchName
        generated_from_head = $script:BaselineHead
        generated_from_tree = $script:BaselineTree
        source_kpi_model_ref = "state/governance/r17_kpi_baseline_target_scorecard.json"
        scorecard_mode = "final_movement_candidate_not_closeout_approval"
        active_through_task = "R17-028"
        r17_closed = $false
        operator_decision_required = $true
        weighted_actual_score = [math]::Round(($weighted / 100), 2)
        target_weighted_score = 78.8
        score_rows = $rows
        runtime_flags = Get-R17FinalEvidencePackageRuntimeFlags
        positive_claims = Get-R17FinalEvidencePackagePositiveClaims
        non_claims = @(Get-R17FinalEvidencePackageNonClaims)
        caveats = @(
            "Product/runtime-related scores remain capped because no live product runtime, live A2A runtime, live agents, adapter runtime, or live automated recovery runtime exists.",
            "Recovery/harness scores move only for committed foundations and prompt/work-order models.",
            "Score movement is not closeout approval and does not open R18."
        )
        evidence_refs = @(Get-R17FinalEvidencePackageEvidenceRefs)
    }
}

function New-R17FinalKpiMovementScorecardContract {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_final_kpi_movement_scorecard_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-final-kpi-movement-scorecard-contract-v1"
        source_task = $script:SourceTask
        source_milestone = $script:MilestoneName
        required_domain_count = 10
        required_weight_sum = 100
        required_fields = @("artifact_type", "scorecard_id", "source_task", "generated_from_head", "generated_from_tree", "score_rows", "weighted_actual_score", "runtime_flags", "positive_claims", "non_claims", "caveats")
        required_runtime_false_fields = @((Get-R17FinalEvidencePackageRuntimeFlags).PSObject.Properties.Name)
        required_non_claims = @(Get-R17FinalEvidencePackageNonClaims)
        required_positive_claims = @((Get-R17FinalEvidencePackagePositiveClaims).PSObject.Properties.Name)
        source_kpi_model_ref = "state/governance/r17_kpi_baseline_target_scorecard.json"
        movement_policy = [pscustomobject][ordered]@{
            targets_are_not_achievement = $true
            runtime_scores_must_remain_limited = $true
            foundations_may_move_scores = $true
            live_runtime_claims_allowed = $false
            operator_decision_required = $true
        }
    }
}

function New-R17FinalEvidenceIndex {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_028_final_evidence_index"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-028"
        milestone_status = "active_closeout_candidate_operator_decision_required"
        generated_from_head = $script:BaselineHead
        generated_from_tree = $script:BaselineTree
        evidence_refs = @(Get-R17FinalEvidencePackageEvidenceRefs)
        validation_refs = @(Get-R17FinalEvidencePackageValidationCommands)
        accepted_claims = @(
            "R17 final evidence package created",
            "KPI movement package created",
            "R18 planning brief created",
            "compact failure finding preserved",
            "operator decision package created"
        )
        rejected_claims = @(Get-R17FinalEvidencePackageRejectedClaims)
        runtime_flags = Get-R17FinalEvidencePackageRuntimeFlags
        positive_claims = Get-R17FinalEvidencePackagePositiveClaims
        non_claims = @(Get-R17FinalEvidencePackageNonClaims)
        residual_risks = @(
            "R17 did not achieve the original four exercised A2A cycle goal.",
            "R17 did not solve Codex compaction or reliability.",
            "The planned Cycle 3 QA/fix-loop was abandoned before commit and replaced by harness/recovery foundations.",
            "R18 is recommended but not opened."
        )
    }
}

function New-R17FinalHeadSupportPacket {
    return [pscustomobject][ordered]@{
        artifact_type = "r17_028_final_head_support_packet"
        packet_version = "v1"
        packet_id = "aioffice-r17-028-final-head-support-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = $script:Repository
        branch = $script:BranchName
        claimed_final_head = $script:BaselineHead
        claimed_final_tree = $script:BaselineTree
        claim_status = "pre_commit_closeout_candidate_support_values; final post-commit SHA is reported by operator workflow, not self-certified inside this packet"
        milestone_active_through = "R17-028"
        planned_or_closed_status = "active_closeout_candidate_operator_decision_required"
        r17_closed = $false
        r18_opened = $false
        validation_commands = @(Get-R17FinalEvidencePackageValidationCommands)
        evidence_refs = @(Get-R17FinalEvidencePackageEvidenceRefs)
        non_claims = @(Get-R17FinalEvidencePackageNonClaims)
        operator_decision_required = $true
        r18_recommendation = "Open R18 only by explicit operator decision, focused on automated recovery runtime and API-level orchestration."
        runtime_flags = Get-R17FinalEvidencePackageRuntimeFlags
        positive_claims = Get-R17FinalEvidencePackagePositiveClaims
    }
}

function Get-R17FinalEvidencePackageProofReviewText {
    return @"
# R17-028 Final Evidence Package Proof Review

R17-028 creates a final reporting, KPI movement, final evidence, final-head support, and R18 planning package only.

## Evidence

- Final report: governance/reports/AIOffice_V2_R17_Final_Report_and_R18_Planning_Report_v1.md
- KPI movement scorecard: state/governance/r17_final_kpi_movement_scorecard.json
- KPI movement contract: contracts/governance/r17_final_kpi_movement_scorecard.contract.json
- Evidence index: state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_evidence_package/evidence_index.json
- Final-head support packet: state/final_head_support/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_028_final_head_support_packet.json
- R18 planning brief: governance/plans/AIOffice_V2_R18_Automated_Recovery_Runtime_and_API_Orchestration_Plan_v1.md
- Tooling and tests: tools/R17FinalEvidencePackage.psm1, tools/new_r17_final_evidence_package.ps1, tools/validate_r17_final_evidence_package.ps1, tests/test_r17_final_evidence_package.ps1

## Verdict

R17 is active through R17-028 final package only. This is a closeout candidate requiring an operator decision, not executed closure.

R17 delivered substantial foundations and two repo-backed packet-only cycle packages. R17 did not deliver the original four exercised A2A cycles or a live product/runtime loop. Repeated Codex compact failures are the primary process/product finding and remain unresolved.

## Boundary

R17-028 does not implement live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, external audit acceptance, R17 closeout, no-manual-prompt-transfer success, solved Codex compaction, or solved Codex reliability.
"@
}

function Get-R17FinalEvidencePackageValidationManifestText {
    $commands = (Get-R17FinalEvidencePackageValidationCommands | ForEach-Object { "1. $_" }) -join [Environment]::NewLine
    return @"
# R17-028 Final Evidence Package Validation Manifest

Required validation commands:

$commands

Validator rejection policy:

- reject R17 closed without operator approval;
- reject R18 opened;
- reject main merge or external audit acceptance claims;
- reject four exercised A2A cycles, live A2A runtime, live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, solved compaction/reliability, no-manual-prompt-transfer success, or product runtime claims;
- reject historical R13/R14/R15/R16 evidence edits;
- reject committed operator local backup directory references;
- reject kanban.js changes unless explicitly allowed;
- reject broad repo scan output and oversized generated artifacts.

Residual finding: live automated recovery and API-level orchestration remain future work.
"@
}

function Get-R17FinalReportText {
    $rows = New-R17FinalEvidencePackageDomainRows
    $visionRows = ($rows | ForEach-Object {
            "| $($_.segment_category) | $($_.r16_baseline_score) | $($_.r17_target_score) | $($_.r17_achieved_score) | $($_.score_movement) | $((@($_.evidence_refs) -join '<br>')) | $($_.justification) |"
        }) -join [Environment]::NewLine
    $nonClaims = (Get-R17FinalEvidencePackageNonClaims | ForEach-Object { "- $_" }) -join [Environment]::NewLine

    return @"
# AIOffice V2 R17 Final Report and R18 Planning Report v1

## Executive verdict

R17 delivered substantial foundations and two repo-backed packet-only cycle packages. It did not meet the original four-cycle/live operating loop ambition. Repeated Codex compact failures became the dominant finding and forced a pivot from long-session cycle execution into compact-safe harness and recovery-loop foundations. R18 must prioritize live automated recovery and API-level orchestration.

This is a closeout candidate only. R17 remains active through R17-028 final package pending operator decision.

## Scope delivered by task

- R17-001 through R17-022: foundations for authority, KPI baseline, board/contracts/state/UI, Orchestrator identity/intake, agent registry/memory/invocation logs, tool adapters, tool-call ledger, A2A contracts/dispatcher, and stop/retry/re-entry controls.
- R17-023: Cycle 1 definition package, repo-backed and packet-only.
- R17-024: Cycle 2 Developer/Codex execution package, repo-backed and packet-only.
- R17-025: compact-safe execution harness foundation.
- R17-026: compact-safe harness pilot.
- R17-027: automated recovery-loop foundation.
- R17-028: final evidence/reporting/KPI/R18 planning package.

## Evidence table

| Task | Commit if known | Durable outputs | Validation artifacts | Accepted claims | Rejected claims | Residual risks |
| --- | --- | --- | --- | --- | --- | --- |
| R17-001 through R17-022 | Not enumerated in this package; see task proof packages | R17 authority, KPI baseline, board/orchestrator/agent/tool/A2A/control foundations | task validators and proof-review packages under state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/ | Bounded foundations only | live runtime, agents, product, A2A execution, main merge, audit acceptance | Foundations are not operating runtime |
| R17-023 | Not enumerated in this package | Cycle 1 definition package under state/cycles/.../r17_023_cycle_1_definition/ | tools/validate_r17_cycle_1_definition.ps1; tests/test_r17_cycle_1_definition.ps1 | repo-backed packet-only Cycle 1 definition | live PM/Architect invocation, live A2A, Dev/QA/audit output | packet-only evidence does not prove live cycle |
| R17-024 | Not enumerated in this package | Cycle 2 Developer/Codex execution package under state/cycles/.../r17_024_cycle_2_dev_execution/ | tools/validate_r17_cycle_2_dev_execution.ps1; tests/test_r17_cycle_2_dev_execution.ps1 | repo-backed packet-only Developer/Codex package | live Codex adapter, autonomous Codex, QA result, no-manual-prompt-transfer success | cycle stops before QA/fix-loop |
| R17-025 | Not enumerated in this package | compact-safe execution harness foundation artifacts | tools/validate_r17_compact_safe_execution_harness.ps1; tests/test_r17_compact_safe_execution_harness.ps1 | compact-safe work-order foundation | live harness runtime, API execution, solved compaction | foundation only |
| R17-026 | Not enumerated in this package | compact-safe harness pilot and Cycle 3 prompt packets | tools/validate_r17_compact_safe_harness_pilot.ps1; tests/test_r17_compact_safe_harness_pilot.ps1 | smaller resumable work-order pilot | full QA/fix-loop execution, solved compaction | manual continuation still required |
| R17-027 | Not enumerated in this package | automated recovery-loop foundation artifacts | tools/validate_r17_automated_recovery_loop.ps1; tests/test_r17_automated_recovery_loop.ps1 | recovery model, continuation and new-context packet model | live recovery runtime, automatic new-thread creation, API orchestration | live automation absent |
| R17-028 | $($script:BaselineHead) baseline for generation | final report, KPI movement scorecard, evidence index, proof review, validation manifest, final-head support packet, R18 planning brief | tools/validate_r17_final_evidence_package.ps1; tests/test_r17_final_evidence_package.ps1 | final package, KPI movement package, compact failure finding, operator decision package | R17 closure, R18 opening, main merge, external audit acceptance | operator decision still required |

## Vision Control Table

| Segment/category | R16 baseline | R17 target | R17 achieved score | Score movement | Evidence refs | Justification |
| --- | ---: | ---: | ---: | ---: | --- | --- |
$visionRows

## Original R17 goal vs actual delivery

Original goal: full agentic operating surface, A2A runtime, and four exercised A2A cycles.

Actual delivery: foundations, packet-only Cycle 1 and Cycle 2, compact-safe harness pivot, and recovery-loop foundation.

Verdict: meaningful architecture progress, but not live product runtime.

## Compact failure finding

Repeated compact failures are primary process/product evidence. Manual resume prompts are not acceptable as the long-term solution. Automated retry, state preservation, continuation packet creation, and new-context continuation are the next priority. R17 did not solve this.

## R18 planning recommendation

R18 should focus on a live local runner/CLI loop, automatic failure detection, automatic continuation packet creation, automatic new-context/new-thread prompt creation, optional API-backed Codex/OpenAI execution only after secrets and cost controls, an execution state machine, max token/request budget controls such as a later 256k token/request cap, small work-order execution, automated stage/commit/push only after gates, operator approval gates, and proof that manual retry burden is reduced.

## Non-claims and caveats

$nonClaims

Additional caveats: no live agent runtime, no live A2A runtime, no adapter runtime, no actual tool call, no product runtime, no main merge, no external audit acceptance, no no-manual-prompt-transfer success, no solved Codex compaction, and no solved Codex reliability.

## Operator decision required

The operator must decide whether to accept R17 as a bounded foundation/pivot milestone with caveats, require further R17 repair work, or open R18 focused on automated recovery runtime and API-level orchestration.
"@
}

function Get-R17R18PlanningBriefText {
    return @"
# AIOffice V2 R18 Automated Recovery Runtime and API Orchestration Plan v1

Status: planning recommendation only. R18 is not opened by this document.

## Recommended mission

Build a live automated recovery runtime that reduces manual retry burden after Codex compact failures, validation failures, stream interruptions, and stale context. Add API-level orchestration only after operator-approved secrets, cost, and runaway-loop controls exist.

## Required capabilities

- live local runner/CLI loop;
- automatic failure detection;
- automatic continuation packet creation;
- automatic new-context/new-thread prompt creation;
- execution state machine;
- max token/request budget controls, including a later cap such as 256k tokens per request;
- small work-order execution;
- automated stage/commit/push only after validation gates;
- operator approval gates for risky actions;
- optional API-backed Codex/OpenAI execution only after secrets and cost controls;
- measurable proof that manual retry burden is reduced.

## Acceptance posture

R18 should not be accepted on plans or prompt packets alone. It needs live recovery execution evidence, failed-case drills, cost/secret controls, bounded retry behavior, and proof that manual prompt transfer has been reduced rather than renamed.

## Non-claims

This brief does not open R18, invoke OpenAI APIs, invoke Codex APIs, create a new Codex thread automatically, implement live recovery runtime, merge to main, claim external audit acceptance, close R17, solve compaction, or solve reliability.
"@
}

function New-R17FinalEvidencePackageFixtureFiles {
    param([string]$RepositoryRoot = $script:RepositoryRoot)

    $paths = Get-R17FinalEvidencePackagePaths -RepositoryRoot $RepositoryRoot
    New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null

    $fixtures = @(
        @{ file = "invalid_r17_closed_without_operator_approval.json"; mutation = "set_r17_closed_true"; expected_failure_fragments = @("R17 closed without operator approval") },
        @{ file = "invalid_r18_opened.json"; mutation = "set_r18_opened_true"; expected_failure_fragments = @("R18 opened") },
        @{ file = "invalid_main_merge_claimed.json"; mutation = "set_main_merge_true"; expected_failure_fragments = @("main merge") },
        @{ file = "invalid_external_audit_acceptance_claimed.json"; mutation = "set_external_audit_acceptance_true"; expected_failure_fragments = @("external audit acceptance") },
        @{ file = "invalid_four_cycles_claimed.json"; mutation = "set_four_cycles_true"; expected_failure_fragments = @("four exercised A2A cycles") },
        @{ file = "invalid_live_a2a_runtime_claimed.json"; mutation = "set_live_a2a_true"; expected_failure_fragments = @("live A2A runtime") },
        @{ file = "invalid_live_recovery_runtime_claimed.json"; mutation = "set_live_recovery_true"; expected_failure_fragments = @("live recovery-loop runtime") },
        @{ file = "invalid_automatic_new_thread_creation_claimed.json"; mutation = "set_automatic_new_thread_true"; expected_failure_fragments = @("automatic new-thread creation") },
        @{ file = "invalid_openai_api_invoked.json"; mutation = "set_openai_api_true"; expected_failure_fragments = @("OpenAI API") },
        @{ file = "invalid_codex_api_invoked.json"; mutation = "set_codex_api_true"; expected_failure_fragments = @("Codex API") },
        @{ file = "invalid_solved_compaction_claimed.json"; mutation = "set_solved_compaction_true"; expected_failure_fragments = @("solved compaction") },
        @{ file = "invalid_solved_reliability_claimed.json"; mutation = "set_solved_reliability_true"; expected_failure_fragments = @("solved reliability") },
        @{ file = "invalid_no_manual_prompt_transfer_success.json"; mutation = "set_no_manual_prompt_transfer_true"; expected_failure_fragments = @("no-manual-prompt-transfer") },
        @{ file = "invalid_product_runtime_claimed.json"; mutation = "set_product_runtime_true"; expected_failure_fragments = @("product runtime") },
        @{ file = "invalid_local_backups_reference.json"; mutation = "append_local_backups_ref"; expected_failure_fragments = @("operator local backup") },
        @{ file = "invalid_broad_repo_scan_output.json"; mutation = "set_broad_repo_scan_output_true"; expected_failure_fragments = @("broad repo scan output") },
        @{ file = "invalid_oversized_generated_artifacts.json"; mutation = "set_oversized_generated_artifacts_true"; expected_failure_fragments = @("oversized generated artifacts") }
    )

    foreach ($fixture in $fixtures) {
        $fixtureObject = [pscustomobject][ordered]@{
            file = $fixture.file
            mutation = $fixture.mutation
            expected_failure_fragments = $fixture.expected_failure_fragments
        }
        Write-R17FinalEvidencePackageJson -Path (Join-Path $paths.FixtureRoot $fixture.file) -Value $fixtureObject
    }

    Write-R17FinalEvidencePackageJson -Path $paths.FixtureManifest -Value ([pscustomobject][ordered]@{
            artifact_type = "r17_final_evidence_package_fixture_manifest"
            source_task = $script:SourceTask
            fixtures = @($fixtures | ForEach-Object {
                    [pscustomobject][ordered]@{
                        file = $_.file
                        mutation = $_.mutation
                        expected_failure_fragments = $_.expected_failure_fragments
                    }
                })
        })
}

function New-R17FinalEvidencePackageArtifacts {
    param([string]$RepositoryRoot = $script:RepositoryRoot)

    $paths = Get-R17FinalEvidencePackagePaths -RepositoryRoot $RepositoryRoot
    Write-R17FinalEvidencePackageJson -Path $paths.KpiScorecard -Value (New-R17FinalKpiMovementScorecard)
    Write-R17FinalEvidencePackageJson -Path $paths.KpiContract -Value (New-R17FinalKpiMovementScorecardContract)
    Write-R17FinalEvidencePackageJson -Path $paths.EvidenceIndex -Value (New-R17FinalEvidenceIndex)
    Write-R17FinalEvidencePackageJson -Path $paths.FinalHeadSupportPacket -Value (New-R17FinalHeadSupportPacket)
    Write-R17FinalEvidencePackageText -Path $paths.ProofReview -Value (Get-R17FinalEvidencePackageProofReviewText)
    Write-R17FinalEvidencePackageText -Path $paths.ValidationManifest -Value (Get-R17FinalEvidencePackageValidationManifestText)
    Write-R17FinalEvidencePackageText -Path $paths.FinalReport -Value (Get-R17FinalReportText)
    Write-R17FinalEvidencePackageText -Path $paths.R18PlanningBrief -Value (Get-R17R18PlanningBriefText)
    New-R17FinalEvidencePackageFixtureFiles -RepositoryRoot $RepositoryRoot

    return [pscustomobject][ordered]@{
        FinalReport = $paths.FinalReport
        KpiScorecard = $paths.KpiScorecard
        KpiContract = $paths.KpiContract
        EvidenceIndex = $paths.EvidenceIndex
        ProofReview = $paths.ProofReview
        ValidationManifest = $paths.ValidationManifest
        FinalHeadSupportPacket = $paths.FinalHeadSupportPacket
        R18PlanningBrief = $paths.R18PlanningBrief
        FixtureRoot = $paths.FixtureRoot
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17FinalEvidencePackage {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-R17FinalEvidencePackageFalseFlag {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Message
    )

    Assert-R17FinalEvidencePackage -Condition (Test-R17FinalEvidencePackageHasProperty -Object $Object -Name $Name) -Message "Missing runtime flag '$Name'."
    Assert-R17FinalEvidencePackage -Condition ($Object.$Name -eq $false) -Message $Message
}

function Test-R17FinalEvidencePackageSet {
    param(
        [Parameter(Mandatory = $true)]$Scorecard,
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$EvidenceIndex,
        [Parameter(Mandatory = $true)]$FinalHeadSupportPacket
    )

    Assert-R17FinalEvidencePackage -Condition ($Scorecard.artifact_type -eq "r17_final_kpi_movement_scorecard") -Message "Scorecard artifact_type is invalid."
    Assert-R17FinalEvidencePackage -Condition ($Contract.artifact_type -eq "r17_final_kpi_movement_scorecard_contract") -Message "Scorecard contract artifact_type is invalid."
    Assert-R17FinalEvidencePackage -Condition ($EvidenceIndex.artifact_type -eq "r17_028_final_evidence_index") -Message "Evidence index artifact_type is invalid."
    Assert-R17FinalEvidencePackage -Condition ($FinalHeadSupportPacket.artifact_type -eq "r17_028_final_head_support_packet") -Message "Final-head support packet artifact_type is invalid."
    Assert-R17FinalEvidencePackage -Condition ($Scorecard.active_through_task -eq "R17-028") -Message "Scorecard must mark R17 active through R17-028."
    Assert-R17FinalEvidencePackage -Condition ($FinalHeadSupportPacket.milestone_active_through -eq "R17-028") -Message "Final-head support packet must mark R17 active through R17-028."
    Assert-R17FinalEvidencePackage -Condition ($Scorecard.source_kpi_model_ref -eq "state/governance/r17_kpi_baseline_target_scorecard.json") -Message "Scorecard must use the existing R17 KPI domain model."
    Assert-R17FinalEvidencePackage -Condition (@($Scorecard.score_rows).Count -eq 10) -Message "Scorecard must include ten KPI domain rows."

    $weightSum = 0
    foreach ($row in @($Scorecard.score_rows)) {
        $weightSum += [int]$row.weight
        Assert-R17FinalEvidencePackage -Condition ($row.r17_achieved_score -le $row.r17_target_score) -Message "R17 actual score must not exceed target score for $($row.segment_category)."
        Assert-R17FinalEvidencePackage -Condition (@($row.evidence_refs).Count -gt 0) -Message "Each KPI row must include evidence refs."
    }
    Assert-R17FinalEvidencePackage -Condition ($weightSum -eq 100) -Message "KPI weights must sum to 100."

    foreach ($target in @($Scorecard.runtime_flags, $EvidenceIndex.runtime_flags, $FinalHeadSupportPacket.runtime_flags)) {
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "r17_closed" -Message "R17 closed without operator approval is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "r18_opened" -Message "R18 opened is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "main_merge_claimed" -Message "main merge claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "external_audit_acceptance_claimed" -Message "external audit acceptance claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "four_exercised_a2a_cycles_claimed" -Message "four exercised A2A cycles claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "live_a2a_runtime_implemented" -Message "live A2A runtime claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "live_recovery_loop_runtime_implemented" -Message "live recovery-loop runtime claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "automatic_new_thread_creation_performed" -Message "automatic new-thread creation claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "openai_api_invoked" -Message "OpenAI API invocation claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "codex_api_invoked" -Message "Codex API invocation claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "no_manual_prompt_transfer_success_claimed" -Message "no-manual-prompt-transfer success claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "product_runtime_executed" -Message "product runtime claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "solved_codex_compaction_claimed" -Message "solved compaction claimed is rejected."
        Assert-R17FinalEvidencePackageFalseFlag -Object $target -Name "solved_codex_reliability_claimed" -Message "solved reliability claimed is rejected."
    }

    foreach ($claimName in @((Get-R17FinalEvidencePackagePositiveClaims).PSObject.Properties.Name)) {
        Assert-R17FinalEvidencePackage -Condition ($Scorecard.positive_claims.$claimName -eq $true) -Message "Missing positive claim '$claimName'."
        Assert-R17FinalEvidencePackage -Condition ($EvidenceIndex.positive_claims.$claimName -eq $true) -Message "Evidence index missing positive claim '$claimName'."
    }

    $combinedJson = @($Scorecard, $Contract, $EvidenceIndex, $FinalHeadSupportPacket) | ConvertTo-Json -Depth 100
    Assert-R17FinalEvidencePackage -Condition ($combinedJson -notmatch '\.local_backups') -Message "operator local backup directory reference is rejected."
    Assert-R17FinalEvidencePackage -Condition ($combinedJson -notmatch '"broad_repo_scan_output_embedded"\s*:\s*true') -Message "broad repo scan output is rejected."
    Assert-R17FinalEvidencePackage -Condition ($combinedJson -notmatch '"oversized_generated_artifacts"\s*:\s*true') -Message "oversized generated artifacts are rejected."

    return [pscustomobject][ordered]@{
        AggregateVerdict = $script:AggregateVerdict
        SourceTask = $script:SourceTask
        ActiveThroughTask = "R17-028"
        DomainCount = @($Scorecard.score_rows).Count
        WeightedActualScore = $Scorecard.weighted_actual_score
        R17Closed = $Scorecard.runtime_flags.r17_closed
        R18Opened = $Scorecard.runtime_flags.r18_opened
        ProductRuntimeExecuted = $Scorecard.runtime_flags.product_runtime_executed
        OperatorDecisionRequired = $true
    }
}

function Assert-R17FinalEvidencePackageTextSafe {
    param([Parameter(Mandatory = $true)][string]$Text)

    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '\.local_backups') -Message "operator local backup directory reference is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\bR18\b.{0,80}\b(is now active|opened in repo truth|is active in repo truth)') -Message "R18 opened is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\b(R17 is closed|R17 closed in repo truth|R17 formally closed)\b') -Message "R17 closed without operator approval is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\b(merged to main|main merge completed|main contains R17)\b') -Message "main merge claimed is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\b(external audit accepted|external audit acceptance achieved|external audit acceptance completed)\b') -Message "external audit acceptance claimed is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\bfour exercised A2A cycles\b.{0,80}\b(complete|completed|achieved|proved|delivered)\b') -Message "four exercised A2A cycles claimed is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\b(live A2A runtime|live recovery-loop runtime|product runtime)\b.{0,80}\b(implemented|executed|achieved|delivered|claimed true)\b') -Message "live/product runtime claimed is rejected."
    Assert-R17FinalEvidencePackage -Condition ($Text -notmatch '(?i)\b(Codex compaction is solved|Codex reliability is solved|Codex compaction solved|Codex reliability solved|has solved Codex compaction|has solved Codex reliability)\b') -Message "solved compaction/reliability claimed is rejected."
}

function Test-R17FinalEvidencePackageChangedFileScope {
    param([string]$RepositoryRoot = $script:RepositoryRoot)

    $gitDiff = & git -C $RepositoryRoot diff --name-only
    $gitStaged = & git -C $RepositoryRoot diff --cached --name-only
    $changed = @($gitDiff + $gitStaged | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $allowed = @(Get-R17FinalEvidencePackageAllowedPaths)

    foreach ($path in $changed) {
        $normalized = $path -replace '\\', '/'
        $isAllowed = $false
        foreach ($allowedPath in $allowed) {
            if ($normalized -eq ($allowedPath -replace '\\', '/')) {
                $isAllowed = $true
                break
            }
        }
        if (-not $isAllowed) {
            if ($normalized -match '^(state/proof_reviews/r1[3-6]|governance/R1[3-6]|state/.*/r1[3-6]_)') {
                throw "historical R13/R14/R15/R16 evidence edits are rejected: $normalized"
            }
            if ($normalized -eq "scripts/operator_wall/r17_kanban_mvp/kanban.js") {
                throw "kanban.js changes are rejected unless explicitly allowed."
            }
            throw "Changed file is outside R17-028 final package scope: $normalized"
        }
    }

    $numstat = & git -C $RepositoryRoot diff --numstat
    $lineTotal = 0
    foreach ($line in @($numstat)) {
        $parts = $line -split "`t"
        if ($parts.Count -ge 2) {
            $add = 0
            $del = 0
            [void][int]::TryParse($parts[0], [ref]$add)
            [void][int]::TryParse($parts[1], [ref]$del)
            $lineTotal += $add + $del
        }
    }
    Assert-R17FinalEvidencePackage -Condition ($lineTotal -le 15000) -Message "oversized generated artifacts are rejected: changed lines exceed 15000."
}

function Test-R17FinalEvidencePackage {
    param([string]$RepositoryRoot = $script:RepositoryRoot)

    $paths = Get-R17FinalEvidencePackagePaths -RepositoryRoot $RepositoryRoot
    foreach ($path in @($paths.FinalReport, $paths.KpiScorecard, $paths.KpiContract, $paths.EvidenceIndex, $paths.ProofReview, $paths.ValidationManifest, $paths.FinalHeadSupportPacket, $paths.R18PlanningBrief, $paths.FixtureManifest)) {
        Assert-R17FinalEvidencePackage -Condition (Test-Path -LiteralPath $path -PathType Leaf) -Message "Required R17-028 artifact is missing: $path"
    }

    $scorecard = Read-R17FinalEvidencePackageJson -Path $paths.KpiScorecard
    $contract = Read-R17FinalEvidencePackageJson -Path $paths.KpiContract
    $evidenceIndex = Read-R17FinalEvidencePackageJson -Path $paths.EvidenceIndex
    $finalHead = Read-R17FinalEvidencePackageJson -Path $paths.FinalHeadSupportPacket
    $result = Test-R17FinalEvidencePackageSet -Scorecard $scorecard -Contract $contract -EvidenceIndex $evidenceIndex -FinalHeadSupportPacket $finalHead

    $text = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath $paths.FinalReport -Raw),
            (Get-Content -LiteralPath $paths.ProofReview -Raw),
            (Get-Content -LiteralPath $paths.ValidationManifest -Raw),
            (Get-Content -LiteralPath $paths.R18PlanningBrief -Raw)
        ))
    Assert-R17FinalEvidencePackageTextSafe -Text $text

    foreach ($nonClaim in Get-R17FinalEvidencePackageNonClaims) {
        Assert-R17FinalEvidencePackage -Condition ($text -like "*$nonClaim*") -Message "Final text is missing non-claim '$nonClaim'."
    }

    $artifactPaths = @($paths.FinalReport, $paths.KpiScorecard, $paths.KpiContract, $paths.EvidenceIndex, $paths.ProofReview, $paths.ValidationManifest, $paths.FinalHeadSupportPacket, $paths.R18PlanningBrief)
    $totalBytes = 0
    foreach ($artifactPath in $artifactPaths) {
        $totalBytes += (Get-Item -LiteralPath $artifactPath).Length
    }
    Assert-R17FinalEvidencePackage -Condition ($totalBytes -le 2000000) -Message "oversized generated artifacts are rejected: generated artifacts exceed 2 MB."

    Test-R17FinalEvidencePackageChangedFileScope -RepositoryRoot $RepositoryRoot
    return $result
}
