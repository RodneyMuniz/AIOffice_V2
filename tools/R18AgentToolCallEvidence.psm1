Set-StrictMode -Version Latest

$script:R18AgentToolSourceTask = "R18-021"
$script:R18AgentToolSourceMilestone = "R18 Automated Recovery Runtime and API Orchestration"
$script:R18AgentToolRepository = "RodneyMuniz/AIOffice_V2"
$script:R18AgentToolBranch = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:R18AgentToolVerdict = "generated_r18_021_agent_tool_call_evidence_model_foundation_only"
$script:R18AgentToolBoundary = "R18 active through R18-021 only; R18-022 through R18-028 planned only; R17 closed with caveats through R17-028 only; Main not merged"

$script:R18AgentToolCallModes = @(
    "planned",
    "dry_run",
    "failed",
    "live_approved"
)

$script:R18AgentToolCallStatuses = @(
    "planned_evidence_record_only",
    "dry_run_evidence_record_only_not_runtime_tool_call",
    "failed_blocked_evidence_record_only",
    "live_approved_requires_evidence_and_controls"
)

$script:R18AgentToolRecordFields = @(
    "artifact_type",
    "contract_version",
    "ledger_record_id",
    "source_task",
    "source_milestone",
    "record_kind",
    "call_mode",
    "call_status",
    "attempt_type",
    "agent_card_ref",
    "agent_id",
    "agent_role",
    "skill_contract_ref",
    "skill_id",
    "runner_log_ref",
    "tool_adapter_profile_ref",
    "requested_by_role",
    "input_ref",
    "result_ref",
    "failure_ref",
    "evidence_refs",
    "authority_refs",
    "control_refs",
    "validation_refs",
    "evidence_policy",
    "live_call_guard",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:R18AgentToolRuntimeFlagFields = @(
    "agent_invocation_performed",
    "live_agent_runtime_invoked",
    "tool_call_execution_performed",
    "live_tool_call_performed",
    "tool_call_runtime_implemented",
    "ledger_runtime_implemented",
    "adapter_runtime_invoked",
    "live_skill_execution_performed",
    "work_order_execution_performed",
    "board_runtime_mutation_performed",
    "a2a_message_sent",
    "live_a2a_runtime_implemented",
    "api_invocation_performed",
    "codex_api_invoked",
    "openai_api_invoked",
    "autonomous_codex_invocation_performed",
    "automatic_new_thread_creation_performed",
    "recovery_action_performed",
    "release_gate_executed",
    "stage_commit_push_performed",
    "ci_replay_performed",
    "github_actions_workflow_created",
    "github_actions_workflow_run_claimed",
    "product_runtime_executed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "no_manual_prompt_transfer_success_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r18_022_completed"
)

function Get-R18AgentToolCallEvidenceRepositoryRoot {
    return (Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
}

function Resolve-R18AgentToolCallEvidencePath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Get-R18AgentToolCallEvidencePaths {
    param([string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))

    return [ordered]@{
        Contract = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "contracts/tools/r18_agent_tool_call_evidence.contract.json"
        LedgerShape = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        Profile = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_agent_tool_call_evidence_profile.json"
        Ledger = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
        Results = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_agent_tool_call_evidence_results.json"
        CheckReport = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r18_agent_tool_call_evidence_check_report.json"
        Snapshot = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r18_operator_surface/r18_agent_tool_call_evidence_snapshot.json"
        FixtureRoot = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "tests/fixtures/r18_agent_tool_call_evidence"
        ProofRoot = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model"
        EvidenceIndex = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/evidence_index.json"
        ProofReview = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/proof_review.md"
        ValidationManifest = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/validation_manifest.md"
    }
}

function New-R18AgentToolCallEvidenceRuntimeFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:R18AgentToolRuntimeFlagFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R18AgentToolCallEvidenceRuntimeFlagNames {
    return $script:R18AgentToolRuntimeFlagFields
}

function Get-R18AgentToolCallEvidencePositiveClaims {
    return @(
        "r18_agent_tool_call_evidence_contract_created",
        "r18_agent_tool_call_evidence_ledger_shape_created",
        "r18_agent_tool_call_evidence_profile_created",
        "r18_agent_tool_call_evidence_seed_ledger_created",
        "r18_agent_tool_call_evidence_results_created",
        "r18_agent_tool_call_evidence_validator_created",
        "r18_agent_tool_call_evidence_fixtures_created",
        "r18_agent_tool_call_evidence_proof_review_created"
    )
}

function Get-R18AgentToolCallEvidenceNonClaims {
    return @(
        "R17 remains closed with caveats through R17-028 only.",
        "R18 is active through R18-021 only.",
        "R18-022 through R18-028 remain planned only.",
        "R18-021 created agent invocation and tool-call evidence model foundation only.",
        "Evidence model is not agent invocation by itself.",
        "Agent/tool-call evidence ledger artifacts are deterministic evidence-shape artifacts only.",
        "No live agents were invoked.",
        "No live agent runtime was implemented.",
        "No live skills were executed.",
        "No tool-call execution was performed.",
        "No live tool call was performed.",
        "No tool-call runtime was implemented.",
        "No ledger runtime was implemented.",
        "No adapter runtime was invoked.",
        "No work orders were executed.",
        "No board/card runtime mutation occurred.",
        "No A2A messages were sent.",
        "No live A2A runtime was implemented.",
        "Codex API invocation did not occur.",
        "OpenAI API invocation did not occur.",
        "No recovery action was performed.",
        "Release gate was not executed.",
        "CI replay was not performed.",
        "GitHub Actions workflow was not created or run.",
        "Product runtime is not claimed.",
        "No no-manual-prompt-transfer success is claimed.",
        "Codex compaction and model-capacity interruption remain known operational issues, not solved.",
        "Codex reliability is not solved.",
        "Main is not merged."
    )
}

function Get-R18AgentToolCallEvidenceRejectedClaims {
    return @(
        "live_agent_invocation",
        "live_agent_runtime",
        "live_skill_execution",
        "tool_call_execution",
        "live_tool_call",
        "tool_call_runtime",
        "ledger_runtime",
        "adapter_runtime_invocation",
        "work_order_execution",
        "board_card_runtime_mutation",
        "a2a_message_sent",
        "live_a2a_runtime",
        "api_invocation",
        "codex_api_invocation",
        "openai_api_invocation",
        "autonomous_codex_invocation",
        "automatic_new_thread_creation",
        "recovery_action",
        "release_gate_execution",
        "stage_commit_push",
        "ci_replay",
        "github_actions_workflow_created",
        "github_actions_workflow_run",
        "external_audit_acceptance",
        "main_merge",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_codex_compaction",
        "solved_codex_reliability",
        "r18_022_or_later_completion",
        "fake_live_tool_call",
        "missing_evidence_refs",
        "missing_live_call_controls",
        "operator_local_backup_path",
        "historical_evidence_edit",
        "broad_repo_write"
    )
}

function Get-R18AgentToolCallEvidenceAuthorityRefs {
    return @(
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "README.md",
        "contracts/agents/r18_agent_card.contract.json",
        "state/agents/r18_agent_cards/",
        "contracts/skills/r18_skill_contract.contract.json",
        "state/skills/r18_skill_contracts/",
        "state/skills/r18_skill_registry.json",
        "contracts/runtime/r18_runner_state_store.contract.json",
        "state/runtime/r18_execution_log.jsonl",
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "contracts/governance/r18_operator_approval_gate.contract.json",
        "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json"
    )
}

function Get-R18AgentToolCallEvidenceEvidenceRefs {
    return @(
        "contracts/tools/r18_agent_tool_call_evidence.contract.json",
        "state/tools/r18_agent_tool_call_evidence_ledger_shape.json",
        "state/tools/r18_agent_tool_call_evidence_profile.json",
        "state/tools/r18_agent_tool_call_evidence_ledger.jsonl",
        "state/tools/r18_agent_tool_call_evidence_results.json",
        "state/tools/r18_agent_tool_call_evidence_check_report.json",
        "state/ui/r18_operator_surface/r18_agent_tool_call_evidence_snapshot.json",
        "tools/R18AgentToolCallEvidence.psm1",
        "tools/new_r18_agent_tool_call_evidence.ps1",
        "tools/validate_r18_agent_tool_call_evidence.ps1",
        "tests/test_r18_agent_tool_call_evidence.ps1",
        "tests/fixtures/r18_agent_tool_call_evidence/",
        "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/"
    )
}

function Get-R18AgentToolCallEvidenceValidationRefs {
    return @(
        "tools/validate_r18_agent_tool_call_evidence.ps1",
        "tests/test_r18_agent_tool_call_evidence.ps1",
        "tools/validate_r18_agent_card_schema.ps1",
        "tests/test_r18_agent_card_schema.ps1",
        "tools/validate_r18_skill_contract_schema.ps1",
        "tests/test_r18_skill_contract_schema.ps1",
        "tools/validate_r18_runner_state_store.ps1",
        "tests/test_r18_runner_state_store.ps1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R18AgentToolCallEvidenceValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_agent_tool_call_evidence.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_tool_call_evidence.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_tool_call_evidence.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function New-R18AgentToolCallEvidenceStatusBoundary {
    return [ordered]@{
        r17_status = "closed_with_caveats_through_r17_028_only"
        r18_status = "active_through_r18_021_only"
        planned_from = "R18-022"
        planned_through = "R18-028"
        main_merge_status = "not_merged"
        ci_replay_status = "not_performed"
        summary = $script:R18AgentToolBoundary
    }
}

function Write-R18AgentToolCallEvidenceJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 100
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($json.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Write-R18AgentToolCallEvidenceJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object[]]$Values
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $lines = @($Values | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ([string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine), $encoding)
}

function Write-R18AgentToolCallEvidenceText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $text = if ($Value -is [array]) { [string]::Join([Environment]::NewLine, @($Value)) } else { [string]$Value }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($text.TrimEnd("`r", "`n") + [Environment]::NewLine), $encoding)
}

function Read-R18AgentToolCallEvidenceJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )

    $resolvedPath = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required JSON artifact missing: $Path"
    }
    return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
}

function Read-R18AgentToolCallEvidenceJsonLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )

    $resolvedPath = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Required JSONL artifact missing: $Path"
    }

    $records = @()
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $resolvedPath)) {
        $lineNumber += 1
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $records += ($line | ConvertFrom-Json)
        }
        catch {
            throw "Malformed JSONL in '$Path' at line $lineNumber. $($_.Exception.Message)"
        }
    }
    return $records
}

function Copy-R18AgentToolCallEvidenceObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function New-R18AgentToolCallEvidenceContract {
    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_contract"
        contract_version = "v1"
        contract_id = "aioffice-r18-021-agent-tool-call-evidence-contract-v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        repository = $script:R18AgentToolRepository
        branch = $script:R18AgentToolBranch
        purpose = "Define deterministic evidence records for future agent invocation and tool-call attempts without invoking agents, executing tool calls, invoking APIs, or implementing live runtime."
        required_record_fields = $script:R18AgentToolRecordFields
        allowed_call_modes = $script:R18AgentToolCallModes
        allowed_call_statuses = $script:R18AgentToolCallStatuses
        required_runtime_false_fields = $script:R18AgentToolRuntimeFlagFields
        live_call_policy = [ordered]@{
            live_call_records_allowed_by_shape = $true
            live_call_performance_allowed_by_r18_021 = $false
            live_calls_require_operator_approval = $true
            live_calls_require_evidence_refs = $true
            live_calls_require_safety_controls = $true
            live_calls_require_secret_budget_token_timeout_stop_controls = $true
            controls_source_task = "R18-022"
            r18_022_controls_implemented = $false
            fake_live_tool_calls_rejected = $true
        }
        append_only_policy = [ordered]@{
            ledger_shape_only = $true
            repo_backed_jsonl = $true
            runtime_append_allowed_by_r18_021 = $false
            future_runtime_append_requires_later_task = $true
            missing_evidence_records_failed_or_blocked_invocation = $true
            missing_evidence_stops_dependent_work = $true
        }
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            operator_local_backup_refs_allowed = $false
            historical_r13_r16_evidence_edits_allowed = $false
            raw_chat_history_as_evidence_allowed = $false
            full_source_content_embedding_allowed = $false
            broad_repo_scan_output_allowed = $false
        }
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        positive_claims = Get-R18AgentToolCallEvidencePositiveClaims
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        evidence_refs = Get-R18AgentToolCallEvidenceEvidenceRefs
    }
}

function New-R18AgentToolCallEvidenceLedgerShape {
    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_ledger_shape"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        ledger_ref = "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
        required_record_fields = $script:R18AgentToolRecordFields
        call_modes = [ordered]@{
            planned = "Planned agent/tool-call attempt evidence shape; not executed."
            dry_run = "Dry-run evidence shape tied to committed dry-run artifacts; not runtime execution."
            failed = "Failed or blocked attempt record with failure evidence and dependent-work stop."
            live_approved = "Future live-approved evidence shape requiring operator approval, controls, and evidence before any call; no live records are seeded by R18-021."
        }
        required_live_control_fields = @(
            "operator_approval_ref",
            "safety_controls_ref",
            "secrets_policy_ref",
            "budget_policy_ref",
            "token_policy_ref",
            "timeout_policy_ref",
            "stop_control_ref",
            "live_call_evidence_ref"
        )
        live_call_controls_source_task = "R18-022"
        seeded_live_approved_record_count = 0
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
    }
}

function New-R18AgentToolCallEvidenceProfile {
    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_profile"
        contract_version = "v1"
        profile_id = "aioffice-r18-021-agent-tool-call-evidence-profile-v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        repository = $script:R18AgentToolRepository
        branch = $script:R18AgentToolBranch
        input_refs = [ordered]@{
            agent_cards = "state/agents/r18_agent_cards/"
            skill_contracts = "state/skills/r18_skill_contracts/"
            runner_log = "state/runtime/r18_execution_log.jsonl"
            tool_adapter_profiles = "state/tools/r17_tool_adapter_seed_profiles.json"
        }
        output_refs = [ordered]@{
            contract = "contracts/tools/r18_agent_tool_call_evidence.contract.json"
            ledger_shape = "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
            ledger = "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
            results = "state/tools/r18_agent_tool_call_evidence_results.json"
            check_report = "state/tools/r18_agent_tool_call_evidence_check_report.json"
            snapshot = "state/ui/r18_operator_surface/r18_agent_tool_call_evidence_snapshot.json"
            proof_review = "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/"
        }
        mode_support = [ordered]@{
            planned = $true
            dry_run = $true
            failed = $true
            live_approved_shape = $true
            live_approved_seeded = $false
        }
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        positive_claims = Get-R18AgentToolCallEvidencePositiveClaims
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        evidence_refs = Get-R18AgentToolCallEvidenceEvidenceRefs
    }
}

function New-R18AgentToolCallEvidenceControlRefs {
    return [ordered]@{
        operator_approval_ref = "not_applicable_no_live_call"
        safety_controls_ref = "planned_r18_022_controls_not_implemented"
        secrets_policy_ref = "planned_r18_022_controls_not_implemented"
        budget_policy_ref = "planned_r18_022_controls_not_implemented"
        token_policy_ref = "planned_r18_022_controls_not_implemented"
        timeout_policy_ref = "planned_r18_022_controls_not_implemented"
        stop_control_ref = "planned_r18_022_controls_not_implemented"
        live_call_evidence_ref = "not_applicable_no_live_call"
        live_call_controls_present = $false
        future_controls_required_before_live_call = $true
    }
}

function New-R18AgentToolCallEvidenceRecord {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$RecordKind,
        [Parameter(Mandatory = $true)][string]$CallMode,
        [Parameter(Mandatory = $true)][string]$CallStatus,
        [Parameter(Mandatory = $true)][string]$AttemptType,
        [Parameter(Mandatory = $true)][string]$AgentCardRef,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$AgentRole,
        [Parameter(Mandatory = $true)][string]$SkillContractRef,
        [Parameter(Mandatory = $true)][string]$SkillId,
        [Parameter(Mandatory = $true)][string]$ToolAdapterProfileRef,
        [Parameter(Mandatory = $true)][string]$RequestedByRole,
        [Parameter(Mandatory = $true)][string]$InputRef,
        [Parameter(Mandatory = $true)][string]$ResultRef,
        [Parameter(Mandatory = $true)][string]$FailureRef,
        [bool]$FailureRecorded = $false,
        [bool]$DependentWorkStopped = $false
    )

    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_record"
        contract_version = "v1"
        ledger_record_id = $Id
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        record_kind = $RecordKind
        call_mode = $CallMode
        call_status = $CallStatus
        attempt_type = $AttemptType
        agent_card_ref = $AgentCardRef
        agent_id = $AgentId
        agent_role = $AgentRole
        skill_contract_ref = $SkillContractRef
        skill_id = $SkillId
        runner_log_ref = "state/runtime/r18_execution_log.jsonl#r18_009_execution_block_recorded_001"
        tool_adapter_profile_ref = $ToolAdapterProfileRef
        requested_by_role = $RequestedByRole
        input_ref = $InputRef
        result_ref = $ResultRef
        failure_ref = $FailureRef
        evidence_refs = @(
            "contracts/tools/r18_agent_tool_call_evidence.contract.json",
            "state/tools/r18_agent_tool_call_evidence_ledger_shape.json",
            "state/tools/r18_agent_tool_call_evidence_ledger.jsonl",
            "state/runtime/r18_execution_log.jsonl",
            $AgentCardRef,
            $SkillContractRef,
            "state/tools/r17_tool_adapter_seed_profiles.json"
        )
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        control_refs = New-R18AgentToolCallEvidenceControlRefs
        validation_refs = Get-R18AgentToolCallEvidenceValidationRefs
        evidence_policy = [ordered]@{
            evidence_refs_required = $true
            missing_evidence_records_failed_or_blocked_invocation = $true
            failure_recorded = $FailureRecorded
            dependent_work_stopped = $DependentWorkStopped
            dependent_work_stop_reason = if ($DependentWorkStopped) { "missing_live_evidence_or_controls" } else { "not_applicable_seed_record" }
        }
        live_call_guard = [ordered]@{
            live_call_requested = $false
            live_call_approved = $false
            live_call_performed = $false
            fake_live_claim_rejected = $true
            controls_required_before_live = $true
        }
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
    }
}

function New-R18AgentToolCallEvidenceRecords {
    return @(
        (New-R18AgentToolCallEvidenceRecord `
                -Id "r18_021_planned_agent_invocation_attempt" `
                -RecordKind "agent_invocation_attempt" `
                -CallMode "planned" `
                -CallStatus "planned_evidence_record_only" `
                -AttemptType "future_agent_invocation_planned_evidence_shape" `
                -AgentCardRef "state/agents/r18_agent_cards/agent_orchestrator.card.json" `
                -AgentId "agent_orchestrator" `
                -AgentRole "Orchestrator" `
                -SkillContractRef "state/skills/r18_skill_contracts/inspect_repo_refs.skill.json" `
                -SkillId "inspect_repo_refs" `
                -ToolAdapterProfileRef "not_applicable_no_tool_adapter_for_agent_planning_record" `
                -RequestedByRole "Operator" `
                -InputRef "state/runtime/r18_runner_state.json" `
                -ResultRef "not_applicable_planned_record_only" `
                -FailureRef "none"),
        (New-R18AgentToolCallEvidenceRecord `
                -Id "r18_021_dry_run_tool_call_attempt" `
                -RecordKind "tool_call_attempt" `
                -CallMode "dry_run" `
                -CallStatus "dry_run_evidence_record_only_not_runtime_tool_call" `
                -AttemptType "deterministic_dry_run_tool_call_evidence_shape" `
                -AgentCardRef "state/agents/r18_agent_cards/agent_release_manager.card.json" `
                -AgentId "agent_release_manager" `
                -AgentRole "Release Manager" `
                -SkillContractRef "state/skills/r18_skill_contracts/run_validator.skill.json" `
                -SkillId "run_validator" `
                -ToolAdapterProfileRef "state/tools/r17_tool_adapter_seed_profiles.json#developer_codex_executor_adapter_future" `
                -RequestedByRole "Release Manager" `
                -InputRef "state/runtime/r18_local_runner_cli_dry_run_inputs/validate_intake_command.input.json" `
                -ResultRef "state/runtime/r18_local_runner_cli_dry_run_results/validate_intake_command.result.json" `
                -FailureRef "none"),
        (New-R18AgentToolCallEvidenceRecord `
                -Id "r18_021_failed_blocked_missing_live_controls" `
                -RecordKind "tool_call_attempt" `
                -CallMode "failed" `
                -CallStatus "failed_blocked_evidence_record_only" `
                -AttemptType "blocked_live_call_request_missing_r18_022_controls" `
                -AgentCardRef "state/agents/r18_agent_cards/agent_evidence_auditor.card.json" `
                -AgentId "agent_evidence_auditor" `
                -AgentRole "Evidence Auditor" `
                -SkillContractRef "state/skills/r18_skill_contracts/generate_evidence_package.skill.json" `
                -SkillId "generate_evidence_package" `
                -ToolAdapterProfileRef "state/tools/r17_tool_adapter_seed_profiles.json#evidence_auditor_api_adapter_future" `
                -RequestedByRole "Evidence Auditor" `
                -InputRef "state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json" `
                -ResultRef "not_applicable_failed_blocked_record" `
                -FailureRef "state/governance/r18_operator_approval_decisions/api_enablement.refusal.json" `
                -FailureRecorded $true `
                -DependentWorkStopped $true)
    )
}

function New-R18AgentToolCallEvidenceModeCounts {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    $counts = [ordered]@{}
    foreach ($mode in $script:R18AgentToolCallModes) {
        $counts[$mode] = @($Records | Where-Object { [string]$_.call_mode -eq $mode }).Count
    }
    return $counts
}

function New-R18AgentToolCallEvidenceResults {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_results"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        aggregate_verdict = $script:R18AgentToolVerdict
        ledger_ref = "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
        record_count = @($Records).Count
        record_ids = @($Records | ForEach-Object { $_.ledger_record_id })
        supported_call_modes = $script:R18AgentToolCallModes
        call_mode_counts = New-R18AgentToolCallEvidenceModeCounts -Records $Records
        live_approved_shape_supported = $true
        live_approved_seeded_record_count = 0
        live_calls_require_evidence_and_controls = $true
        missing_evidence_stops_dependent_work = $true
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        positive_claims = Get-R18AgentToolCallEvidencePositiveClaims
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
        evidence_refs = Get-R18AgentToolCallEvidenceEvidenceRefs
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        validation_refs = Get-R18AgentToolCallEvidenceValidationRefs
    }
}

function New-R18AgentToolCallEvidenceCheckReport {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_check_report"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        aggregate_verdict = $script:R18AgentToolVerdict
        required_record_field_count = @($script:R18AgentToolRecordFields).Count
        ledger_record_count = @($Records).Count
        call_mode_counts = New-R18AgentToolCallEvidenceModeCounts -Records $Records
        live_approved_seeded_record_count = 0
        fake_live_tool_calls_rejected_by_validator = $true
        missing_evidence_refs_rejected_by_validator = $true
        live_calls_require_evidence_and_controls = $true
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        positive_claims = Get-R18AgentToolCallEvidencePositiveClaims
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
        evidence_refs = Get-R18AgentToolCallEvidenceEvidenceRefs
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        validation_refs = Get-R18AgentToolCallEvidenceValidationRefs
    }
}

function New-R18AgentToolCallEvidenceSnapshot {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_snapshot"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        r18_status = "active_through_r18_021_only"
        planned_from = "R18-022"
        planned_through = "R18-028"
        ledger_ref = "state/tools/r18_agent_tool_call_evidence_ledger.jsonl"
        check_report_ref = "state/tools/r18_agent_tool_call_evidence_check_report.json"
        total_records = @($Records).Count
        mode_counts = New-R18AgentToolCallEvidenceModeCounts -Records $Records
        visible_records = @($Records | ForEach-Object {
                [ordered]@{
                    ledger_record_id = $_.ledger_record_id
                    record_kind = $_.record_kind
                    call_mode = $_.call_mode
                    call_status = $_.call_status
                    agent_role = $_.agent_role
                    skill_id = $_.skill_id
                    live_call_performed = $false
                }
            })
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
    }
}

function New-R18AgentToolCallEvidenceFixtureDefinitions {
    return @(
        [ordered]@{ fixture_id = "invalid_missing_evidence_refs"; target = "record:r18_021_planned_agent_invocation_attempt"; operation = "set"; path = "evidence_refs"; value = @(); expected_failure_fragments = @("evidence_refs") },
        [ordered]@{ fixture_id = "invalid_fake_live_tool_call_runtime_flag"; target = "record:r18_021_dry_run_tool_call_attempt"; operation = "set"; path = "runtime_flags.tool_call_execution_performed"; value = $true; expected_failure_fragments = @("runtime flag") },
        [ordered]@{ fixture_id = "invalid_live_tool_call_performed_flag"; target = "record:r18_021_dry_run_tool_call_attempt"; operation = "set"; path = "live_call_guard.live_call_performed"; value = $true; expected_failure_fragments = @("live_call_performed") },
        [ordered]@{ fixture_id = "invalid_live_approved_missing_controls"; target = "record:r18_021_failed_blocked_missing_live_controls"; operation = "set"; path = "call_mode"; value = "live_approved"; expected_failure_fragments = @("live-approved call requires") },
        [ordered]@{ fixture_id = "invalid_unknown_call_mode"; target = "record:r18_021_planned_agent_invocation_attempt"; operation = "set"; path = "call_mode"; value = "runtime"; expected_failure_fragments = @("unknown call_mode") },
        [ordered]@{ fixture_id = "invalid_missing_agent_card_ref"; target = "record:r18_021_planned_agent_invocation_attempt"; operation = "remove"; path = "agent_card_ref"; expected_failure_fragments = @("agent_card_ref") },
        [ordered]@{ fixture_id = "invalid_wrong_agent_role"; target = "record:r18_021_planned_agent_invocation_attempt"; operation = "set"; path = "agent_role"; value = "Release Manager"; expected_failure_fragments = @("agent role") },
        [ordered]@{ fixture_id = "invalid_skill_not_allowed_for_role"; target = "record:r18_021_planned_agent_invocation_attempt"; operation = "set"; path = "skill_contract_ref"; value = "state/skills/r18_skill_contracts/stage_commit_push_gate.skill.json"; expected_failure_fragments = @("skill_id does not match") },
        [ordered]@{ fixture_id = "invalid_missing_runner_log_ref"; target = "record:r18_021_dry_run_tool_call_attempt"; operation = "remove"; path = "runner_log_ref"; expected_failure_fragments = @("runner_log_ref") },
        [ordered]@{ fixture_id = "invalid_operator_local_backup_ref"; target = "record:r18_021_dry_run_tool_call_attempt"; operation = "set"; path = "result_ref"; value = ".local_backups/r18/result.json"; expected_failure_fragments = @(".local_backups") },
        [ordered]@{ fixture_id = "invalid_api_invocation_claim"; target = "record:r18_021_dry_run_tool_call_attempt"; operation = "set"; path = "runtime_flags.api_invocation_performed"; value = $true; expected_failure_fragments = @("runtime flag") },
        [ordered]@{ fixture_id = "invalid_work_order_execution_claim"; target = "record:r18_021_failed_blocked_missing_live_controls"; operation = "set"; path = "runtime_flags.work_order_execution_performed"; value = $true; expected_failure_fragments = @("runtime flag") },
        [ordered]@{ fixture_id = "invalid_missing_failed_stop"; target = "record:r18_021_failed_blocked_missing_live_controls"; operation = "set"; path = "evidence_policy.dependent_work_stopped"; value = $false; expected_failure_fragments = @("dependent work") },
        [ordered]@{ fixture_id = "invalid_r18_022_completion_claim"; target = "report"; operation = "set"; path = "runtime_flags.r18_022_completed"; value = $true; expected_failure_fragments = @("runtime flag") },
        [ordered]@{ fixture_id = "invalid_result_wrong_boundary"; target = "results"; operation = "set"; path = "status_boundary.r18_status"; value = "active_through_r18_022_only"; expected_failure_fragments = @("status boundary") }
    )
}

function New-R18AgentToolCallEvidenceFixtureManifest {
    $fixtures = New-R18AgentToolCallEvidenceFixtureDefinitions
    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_fixture_manifest"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        invalid_fixture_count = @($fixtures).Count
        valid_fixture_refs = @(
            "tests/fixtures/r18_agent_tool_call_evidence/valid_contract.json",
            "tests/fixtures/r18_agent_tool_call_evidence/valid_ledger_shape.json",
            "tests/fixtures/r18_agent_tool_call_evidence/valid_ledger_records.jsonl",
            "tests/fixtures/r18_agent_tool_call_evidence/valid_check_report.json",
            "tests/fixtures/r18_agent_tool_call_evidence/valid_snapshot.json"
        )
        invalid_fixture_ids = @($fixtures | ForEach-Object { $_.fixture_id })
        fixture_policy = "compact mutation fixtures only; no full source or broad repo scan payloads"
    }
}

function New-R18AgentToolCallEvidenceIndex {
    return [ordered]@{
        artifact_type = "r18_agent_tool_call_evidence_proof_review_evidence_index"
        contract_version = "v1"
        source_task = $script:R18AgentToolSourceTask
        source_milestone = $script:R18AgentToolSourceMilestone
        aggregate_verdict = $script:R18AgentToolVerdict
        evidence_refs = Get-R18AgentToolCallEvidenceEvidenceRefs
        authority_refs = Get-R18AgentToolCallEvidenceAuthorityRefs
        validation_refs = Get-R18AgentToolCallEvidenceValidationRefs
        validation_commands = Get-R18AgentToolCallEvidenceValidationCommands
        status_boundary = New-R18AgentToolCallEvidenceStatusBoundary
        runtime_flags = New-R18AgentToolCallEvidenceRuntimeFlags
        non_claims = Get-R18AgentToolCallEvidenceNonClaims
        rejected_claims = Get-R18AgentToolCallEvidenceRejectedClaims
    }
}

function New-R18AgentToolCallEvidenceProofReviewText {
    return @(
        "# R18-021 Agent Invocation And Tool-Call Evidence Model Proof Review",
        "",
        "R18-021 created a deterministic agent invocation and tool-call evidence model foundation only. The package defines the invocation/tool-call evidence contract, ledger shape, seed evidence ledger, results/check-report artifacts, operator-surface snapshot, validator, fixtures, and proof-review evidence.",
        "",
        "The seed ledger distinguishes planned, dry-run, and failed/blocked evidence records. The live-approved mode is defined in the ledger shape but no live-approved seed record and no live call execution are performed because R18-022 safety, secrets, budget, token, timeout, and stop controls remain planned only.",
        "",
        "R18 status after this task is active through R18-021 only. R18-022 through R18-028 remain planned only.",
        "",
        "No live agents were invoked. No tool-call execution was performed. No Codex/OpenAI API invocation occurred. No recovery action or release gate execution occurred. CI replay and GitHub Actions workflow execution were not performed."
    )
}

function New-R18AgentToolCallEvidenceValidationManifestText {
    $lines = @(
        "# R18-021 Validation Manifest",
        "",
        "Expected validation commands:",
        ""
    )
    foreach ($command in Get-R18AgentToolCallEvidenceValidationCommands) {
        $lines += ('- `' + $command + '`')
    }
    $lines += ""
    $lines += "The validator fails closed on fake live tool calls, missing evidence refs, missing live-call controls, unknown call modes, mismatched agent cards, role/skill mismatches, unsafe refs, runtime/API/recovery/release/CI/product overclaims, R18-022+ completion claims, and status-boundary drift."
    return $lines
}

function New-R18AgentToolCallEvidenceArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))

    $paths = Get-R18AgentToolCallEvidencePaths -RepositoryRoot $RepositoryRoot
    $contract = New-R18AgentToolCallEvidenceContract
    $ledgerShape = New-R18AgentToolCallEvidenceLedgerShape
    $profile = New-R18AgentToolCallEvidenceProfile
    $records = New-R18AgentToolCallEvidenceRecords
    $results = New-R18AgentToolCallEvidenceResults -Records $records
    $report = New-R18AgentToolCallEvidenceCheckReport -Records $records
    $snapshot = New-R18AgentToolCallEvidenceSnapshot -Records $records
    $evidenceIndex = New-R18AgentToolCallEvidenceIndex

    Write-R18AgentToolCallEvidenceJson -Path $paths.Contract -Value $contract
    Write-R18AgentToolCallEvidenceJson -Path $paths.LedgerShape -Value $ledgerShape
    Write-R18AgentToolCallEvidenceJson -Path $paths.Profile -Value $profile
    Write-R18AgentToolCallEvidenceJsonLines -Path $paths.Ledger -Values $records
    Write-R18AgentToolCallEvidenceJson -Path $paths.Results -Value $results
    Write-R18AgentToolCallEvidenceJson -Path $paths.CheckReport -Value $report
    Write-R18AgentToolCallEvidenceJson -Path $paths.Snapshot -Value $snapshot

    Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot "fixture_manifest.json") -Value (New-R18AgentToolCallEvidenceFixtureManifest)
    Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json") -Value $contract
    Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot "valid_ledger_shape.json") -Value $ledgerShape
    Write-R18AgentToolCallEvidenceJsonLines -Path (Join-Path $paths.FixtureRoot "valid_ledger_records.jsonl") -Values $records
    Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json") -Value $report
    Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot "valid_snapshot.json") -Value $snapshot
    foreach ($fixture in New-R18AgentToolCallEvidenceFixtureDefinitions) {
        Write-R18AgentToolCallEvidenceJson -Path (Join-Path $paths.FixtureRoot ("{0}.json" -f $fixture.fixture_id)) -Value $fixture
    }

    Write-R18AgentToolCallEvidenceJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R18AgentToolCallEvidenceText -Path $paths.ProofReview -Value (New-R18AgentToolCallEvidenceProofReviewText)
    Write-R18AgentToolCallEvidenceText -Path $paths.ValidationManifest -Value (New-R18AgentToolCallEvidenceValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        LedgerShape = $paths.LedgerShape
        Profile = $paths.Profile
        Ledger = $paths.Ledger
        Results = $paths.Results
        CheckReport = $paths.CheckReport
        Snapshot = $paths.Snapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        RecordCount = @($records).Count
        InvalidFixtureCount = @(New-R18AgentToolCallEvidenceFixtureDefinitions).Count
        AggregateVerdict = $script:R18AgentToolVerdict
    }
}

function Assert-R18AgentToolCallEvidenceCondition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-R18AgentToolCallEvidenceFields {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($field in $Fields) {
        Assert-R18AgentToolCallEvidenceCondition -Condition ($Object.PSObject.Properties.Name -contains $field) -Message "$Context missing required field '$field'."
    }
}

function Assert-R18AgentToolCallEvidenceRuntimeFlags {
    param(
        [Parameter(Mandatory = $true)][object]$RuntimeFlags,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($field in $script:R18AgentToolRuntimeFlagFields) {
        Assert-R18AgentToolCallEvidenceCondition -Condition ($RuntimeFlags.PSObject.Properties.Name -contains $field) -Message "$Context missing runtime flag '$field'."
        Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$RuntimeFlags.$field -eq $false) -Message "$Context runtime flag '$field' must remain false."
    }
}

function Test-R18AgentToolCallEvidencePlaceholderRef {
    param([string]$Value)
    return $Value -in @(
        "none",
        "not_applicable_no_live_call",
        "planned_r18_022_controls_not_implemented",
        "not_applicable_no_tool_adapter_for_agent_planning_record",
        "not_applicable_planned_record_only",
        "not_applicable_failed_blocked_record"
    )
}

function Assert-R18AgentToolCallEvidenceSafeRef {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot),
        [switch]$SkipExistence
    )

    if (Test-R18AgentToolCallEvidencePlaceholderRef -Value $Value) { return }
    Assert-R18AgentToolCallEvidenceCondition -Condition (-not [string]::IsNullOrWhiteSpace($Value)) -Message "$Context ref must not be empty."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Value -notmatch '\*|\?|\[|\]') -Message "$Context contains wildcard ref '$Value'."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Value -notmatch '(^|/|\\)\.local_backups(/|\\)') -Message "$Context contains .local_backups ref '$Value'."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Value -notmatch '^(?i:https?|file)://') -Message "$Context contains URL ref '$Value'."
    Assert-R18AgentToolCallEvidenceCondition -Condition (-not [System.IO.Path]::IsPathRooted($Value)) -Message "$Context contains absolute ref '$Value'."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Value -notmatch '(?i)(chat_history|raw_chat|transcript)') -Message "$Context uses raw chat history as evidence '$Value'."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Value -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "$Context points at historical R13/R14/R15/R16 evidence '$Value'."

    if (-not $SkipExistence) {
        $pathPart = ($Value -split '#')[0]
        $fullPath = Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue $pathPart
        Assert-R18AgentToolCallEvidenceCondition -Condition (Test-Path -LiteralPath $fullPath) -Message "$Context ref does not exist: '$Value'."
    }
}

function Assert-R18AgentToolCallEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Refs,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot),
        [switch]$SkipExistence
    )
    Assert-R18AgentToolCallEvidenceCondition -Condition (@($Refs).Count -gt 0) -Message "$Context must not be empty."
    foreach ($ref in @($Refs)) {
        Assert-R18AgentToolCallEvidenceSafeRef -Value ([string]$ref) -Context $Context -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipExistence
    }
}

function Assert-R18AgentToolCallEvidenceCommonArtifact {
    param(
        [Parameter(Mandatory = $true)][object]$Artifact,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Artifact.source_task -eq $script:R18AgentToolSourceTask) -Message "$Context source_task must be R18-021."
    Assert-R18AgentToolCallEvidenceRuntimeFlags -RuntimeFlags $Artifact.runtime_flags -Context $Context
    if ($Artifact.PSObject.Properties.Name -contains "status_boundary") {
        Assert-R18AgentToolCallEvidenceCondition -Condition ($Artifact.status_boundary.r18_status -eq "active_through_r18_021_only") -Message "$Context status boundary must record active_through_r18_021_only."
        Assert-R18AgentToolCallEvidenceCondition -Condition ($Artifact.status_boundary.planned_from -eq "R18-022") -Message "$Context status boundary must keep R18-022 planned."
    }
    if ($Artifact.PSObject.Properties.Name -contains "evidence_refs") {
        Assert-R18AgentToolCallEvidenceRefs -Refs $Artifact.evidence_refs -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot
    }
    if ($Artifact.PSObject.Properties.Name -contains "authority_refs") {
        Assert-R18AgentToolCallEvidenceRefs -Refs $Artifact.authority_refs -Context "$Context authority_refs" -RepositoryRoot $RepositoryRoot
    }
}

function Get-R18AgentToolCallEvidenceAgentCard {
    param(
        [Parameter(Mandatory = $true)][string]$Ref,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )
    return Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path (($Ref -split '#')[0])
}

function Get-R18AgentToolCallEvidenceSkillContract {
    param(
        [Parameter(Mandatory = $true)][string]$Ref,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot)
    )
    return Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path (($Ref -split '#')[0])
}

function Assert-R18AgentToolCallEvidenceRecord {
    param(
        [Parameter(Mandatory = $true)][object]$Record,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R18AgentToolCallEvidenceFields -Object $Record -Fields $script:R18AgentToolRecordFields -Context "ledger record"
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Record.artifact_type -eq "r18_agent_tool_call_evidence_record") -Message "ledger record artifact_type is invalid."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Record.source_task -eq $script:R18AgentToolSourceTask) -Message "ledger record source_task must be R18-021."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($script:R18AgentToolCallModes -contains [string]$Record.call_mode) -Message "ledger record '$($Record.ledger_record_id)' has unknown call_mode '$($Record.call_mode)'."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($script:R18AgentToolCallStatuses -contains [string]$Record.call_status) -Message "ledger record '$($Record.ledger_record_id)' has unknown call_status '$($Record.call_status)'."
    Assert-R18AgentToolCallEvidenceRuntimeFlags -RuntimeFlags $Record.runtime_flags -Context "ledger record '$($Record.ledger_record_id)'"
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Record.live_call_guard.live_call_performed -eq $false) -Message "ledger record '$($Record.ledger_record_id)' live_call_performed must remain false."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Record.live_call_guard.fake_live_claim_rejected -eq $true) -Message "ledger record '$($Record.ledger_record_id)' must reject fake live claims."

    foreach ($ref in @($Record.agent_card_ref, $Record.skill_contract_ref, $Record.runner_log_ref, $Record.tool_adapter_profile_ref, $Record.input_ref, $Record.result_ref, $Record.failure_ref)) {
        Assert-R18AgentToolCallEvidenceSafeRef -Value ([string]$ref) -Context "ledger record '$($Record.ledger_record_id)' ref" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    }
    Assert-R18AgentToolCallEvidenceRefs -Refs $Record.evidence_refs -Context "ledger record '$($Record.ledger_record_id)' evidence_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    Assert-R18AgentToolCallEvidenceRefs -Refs $Record.authority_refs -Context "ledger record '$($Record.ledger_record_id)' authority_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    Assert-R18AgentToolCallEvidenceRefs -Refs $Record.validation_refs -Context "ledger record '$($Record.ledger_record_id)' validation_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence

    if (-not $SkipRefExistence) {
        $agentCard = Get-R18AgentToolCallEvidenceAgentCard -Ref ([string]$Record.agent_card_ref) -RepositoryRoot $RepositoryRoot
        Assert-R18AgentToolCallEvidenceCondition -Condition ([string]$agentCard.agent_id -eq [string]$Record.agent_id) -Message "ledger record '$($Record.ledger_record_id)' agent_id does not match agent card."
        Assert-R18AgentToolCallEvidenceCondition -Condition ([string]$agentCard.role -eq [string]$Record.agent_role) -Message "ledger record '$($Record.ledger_record_id)' agent role does not match agent card."

        $skillContract = Get-R18AgentToolCallEvidenceSkillContract -Ref ([string]$Record.skill_contract_ref) -RepositoryRoot $RepositoryRoot
        Assert-R18AgentToolCallEvidenceCondition -Condition ([string]$skillContract.skill_id -eq [string]$Record.skill_id) -Message "ledger record '$($Record.ledger_record_id)' skill_id does not match skill contract."
        Assert-R18AgentToolCallEvidenceCondition -Condition (@($skillContract.allowed_roles) -contains [string]$Record.agent_role) -Message "ledger record '$($Record.ledger_record_id)' role '$($Record.agent_role)' is not allowed for skill '$($Record.skill_id)'."
    }

    if ([string]$Record.call_mode -eq "failed") {
        Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Record.evidence_policy.failure_recorded -eq $true) -Message "failed ledger record must set failure_recorded."
        Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Record.evidence_policy.dependent_work_stopped -eq $true) -Message "failed ledger record must stop dependent work."
        Assert-R18AgentToolCallEvidenceCondition -Condition (-not (Test-R18AgentToolCallEvidencePlaceholderRef -Value ([string]$Record.failure_ref))) -Message "failed ledger record must include failure_ref evidence."
    }

    if ([string]$Record.call_mode -eq "live_approved") {
        Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Record.control_refs.live_call_controls_present -eq $true) -Message "live-approved call requires live_call_controls_present."
        foreach ($controlField in @("operator_approval_ref", "safety_controls_ref", "secrets_policy_ref", "budget_policy_ref", "token_policy_ref", "timeout_policy_ref", "stop_control_ref", "live_call_evidence_ref")) {
            $controlRef = [string]$Record.control_refs.$controlField
            Assert-R18AgentToolCallEvidenceCondition -Condition (-not (Test-R18AgentToolCallEvidencePlaceholderRef -Value $controlRef)) -Message "live-approved call requires $controlField."
            Assert-R18AgentToolCallEvidenceSafeRef -Value $controlRef -Context "live-approved $controlField" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
        }
        Assert-R18AgentToolCallEvidenceRefs -Refs $Record.evidence_refs -Context "live-approved evidence_refs" -RepositoryRoot $RepositoryRoot -SkipExistence:$SkipRefExistence
    }
}

function Assert-R18AgentToolCallEvidenceContract {
    param([Parameter(Mandatory = $true)][object]$Contract, [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))
    Assert-R18AgentToolCallEvidenceFields -Object $Contract -Fields @("artifact_type", "contract_version", "contract_id", "source_task", "required_record_fields", "allowed_call_modes", "live_call_policy", "append_only_policy", "exact_ref_policy", "runtime_flags", "non_claims", "rejected_claims") -Context "contract"
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Contract.artifact_type -eq "r18_agent_tool_call_evidence_contract") -Message "contract artifact_type is invalid."
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $Contract -Context "contract" -RepositoryRoot $RepositoryRoot
    foreach ($mode in $script:R18AgentToolCallModes) {
        Assert-R18AgentToolCallEvidenceCondition -Condition (@($Contract.allowed_call_modes) -contains $mode) -Message "contract missing call mode '$mode'."
    }
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Contract.live_call_policy.live_call_performance_allowed_by_r18_021 -eq $false) -Message "contract must not allow live call performance in R18-021."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Contract.live_call_policy.live_calls_require_evidence_refs -eq $true -and [bool]$Contract.live_call_policy.live_calls_require_safety_controls -eq $true) -Message "contract must require evidence and controls for live calls."
}

function Assert-R18AgentToolCallEvidenceModeCounts {
    param([Parameter(Mandatory = $true)][object]$ModeCounts, [Parameter(Mandatory = $true)][string]$Context)
    Assert-R18AgentToolCallEvidenceCondition -Condition ([int]$ModeCounts.planned -eq 1) -Message "$Context planned count must be 1."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([int]$ModeCounts.dry_run -eq 1) -Message "$Context dry_run count must be 1."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([int]$ModeCounts.failed -eq 1) -Message "$Context failed count must be 1."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([int]$ModeCounts.live_approved -eq 0) -Message "$Context live_approved count must be 0 for R18-021 seeds."
}

function Get-R18AgentToolCallEvidenceTaskStatusMap {
    param([Parameter(Mandatory = $true)][string]$Text, [Parameter(Mandatory = $true)][string]$Context)

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -ne 28) {
        throw "$Context must define 28 R18 task status entries."
    }
    $map = @{}
    foreach ($match in $matches) {
        $map[$match.Groups[1].Value] = $match.Groups[2].Value
    }
    return $map
}

function Test-R18AgentToolCallEvidenceStatusTruth {
    param([string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))

    $authority = Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "execution/KANBAN.md") -Raw
    $combinedText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "governance/ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DOCUMENT_AUTHORITY_INDEX.md") -Raw),
            (Get-Content -LiteralPath (Resolve-R18AgentToolCallEvidencePath -RepositoryRoot $RepositoryRoot -PathValue "governance/DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R17 accepted and closed with caveats through R17-028 only",
            "R18 active through R18-021 only",
            "R18-022 through R18-028 planned only",
            "R18-021 created agent invocation and tool-call evidence model foundation only",
            "Evidence model is not agent invocation by itself",
            "No live agents were invoked",
            "No live skills were executed",
            "No R18 runtime tool-call execution was performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "Recovery action was not performed",
            "Release gate was not executed",
            "CI replay was not performed",
            "GitHub Actions workflow was not created or run",
            "Product runtime is not claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex compaction and model-capacity interruption remain known operational issues, not solved"
        )) {
        Assert-R18AgentToolCallEvidenceCondition -Condition ($combinedText -like "*$required*") -Message "Status docs missing R18-021 truth: $required"
    }

    $authorityStatuses = Get-R18AgentToolCallEvidenceTaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18AgentToolCallEvidenceTaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        Assert-R18AgentToolCallEvidenceCondition -Condition ($authorityStatuses[$taskId] -eq $kanbanStatuses[$taskId]) -Message "R18 authority and KANBAN disagree for $taskId."
        if ($taskNumber -le 21) {
            Assert-R18AgentToolCallEvidenceCondition -Condition ($authorityStatuses[$taskId] -eq "done") -Message "$taskId must be done after R18-021."
        }
        else {
            Assert-R18AgentToolCallEvidenceCondition -Condition ($authorityStatuses[$taskId] -eq "planned") -Message "$taskId must remain planned only after R18-021."
        }
    }

    if ($combinedText -match 'R18 active through R18-(02[2-8])') {
        throw "Status surface claims R18 beyond R18-021."
    }
    if ($combinedText -match '(?i)R18-(02[2-8]).{0,120}(done|complete|completed|implemented|executed|active)') {
        throw "Status surface claims R18-022 or later completion."
    }
}

function Test-R18AgentToolCallEvidenceSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Contract,
        [Parameter(Mandatory = $true)][object]$LedgerShape,
        [Parameter(Mandatory = $true)][object]$Profile,
        [Parameter(Mandatory = $true)][object[]]$Records,
        [Parameter(Mandatory = $true)][object]$Results,
        [Parameter(Mandatory = $true)][object]$Report,
        [Parameter(Mandatory = $true)][object]$Snapshot,
        [Parameter(Mandatory = $true)][object]$EvidenceIndex,
        [string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot),
        [switch]$SkipRefExistence
    )

    Assert-R18AgentToolCallEvidenceContract -Contract $Contract -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $LedgerShape -Context "ledger shape" -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $Profile -Context "profile" -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $Results -Context "results" -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $Report -Context "check report" -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $Snapshot -Context "snapshot" -RepositoryRoot $RepositoryRoot
    Assert-R18AgentToolCallEvidenceCommonArtifact -Artifact $EvidenceIndex -Context "evidence index" -RepositoryRoot $RepositoryRoot

    Assert-R18AgentToolCallEvidenceCondition -Condition (@($Records).Count -eq 3) -Message "Expected three seed ledger records."
    $seen = @{}
    foreach ($record in @($Records)) {
        Assert-R18AgentToolCallEvidenceRecord -Record $record -RepositoryRoot $RepositoryRoot -SkipRefExistence:$SkipRefExistence
        Assert-R18AgentToolCallEvidenceCondition -Condition (-not $seen.ContainsKey([string]$record.ledger_record_id)) -Message "Duplicate ledger_record_id '$($record.ledger_record_id)'."
        $seen[[string]$record.ledger_record_id] = $true
    }

    foreach ($mode in @("planned", "dry_run", "failed")) {
        Assert-R18AgentToolCallEvidenceCondition -Condition (@($Records | Where-Object { $_.call_mode -eq $mode }).Count -eq 1) -Message "Seed ledger must include one $mode record."
    }
    Assert-R18AgentToolCallEvidenceCondition -Condition (@($Records | Where-Object { $_.call_mode -eq "live_approved" }).Count -eq 0) -Message "R18-021 must not seed live-approved records."
    Assert-R18AgentToolCallEvidenceCondition -Condition (@($LedgerShape.call_modes.PSObject.Properties.Name) -contains "live_approved") -Message "Ledger shape must distinguish live_approved mode."
    Assert-R18AgentToolCallEvidenceModeCounts -ModeCounts $Results.call_mode_counts -Context "results"
    Assert-R18AgentToolCallEvidenceModeCounts -ModeCounts $Report.call_mode_counts -Context "check report"
    Assert-R18AgentToolCallEvidenceModeCounts -ModeCounts $Snapshot.mode_counts -Context "snapshot"
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Results.aggregate_verdict -eq $script:R18AgentToolVerdict) -Message "Results aggregate verdict is invalid."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Report.aggregate_verdict -eq $script:R18AgentToolVerdict) -Message "Check report aggregate verdict is invalid."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Report.fake_live_tool_calls_rejected_by_validator -eq $true) -Message "Check report must state fake live tool calls are rejected."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Report.missing_evidence_refs_rejected_by_validator -eq $true) -Message "Check report must state missing evidence refs are rejected."
    Assert-R18AgentToolCallEvidenceCondition -Condition ([bool]$Report.live_calls_require_evidence_and_controls -eq $true) -Message "Check report must require evidence and controls for live calls."
    Assert-R18AgentToolCallEvidenceCondition -Condition ($Snapshot.r18_status -eq "active_through_r18_021_only") -Message "Snapshot must record active_through_r18_021_only."

    Test-R18AgentToolCallEvidenceStatusTruth -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RecordCount = @($Records).Count
        RuntimeFlags = $Report.runtime_flags
        CallModeCounts = $Report.call_mode_counts
    }
}

function Get-R18AgentToolCallEvidenceSet {
    param([string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))

    return [pscustomobject]@{
        Contract = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "contracts/tools/r18_agent_tool_call_evidence.contract.json"
        LedgerShape = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_agent_tool_call_evidence_ledger_shape.json"
        Profile = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_agent_tool_call_evidence_profile.json"
        Records = @(Read-R18AgentToolCallEvidenceJsonLines -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_agent_tool_call_evidence_ledger.jsonl")
        Results = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_agent_tool_call_evidence_results.json"
        Report = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/tools/r18_agent_tool_call_evidence_check_report.json"
        Snapshot = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/ui/r18_operator_surface/r18_agent_tool_call_evidence_snapshot.json"
        EvidenceIndex = Read-R18AgentToolCallEvidenceJson -RepositoryRoot $RepositoryRoot -Path "state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_021_agent_tool_call_evidence_model/evidence_index.json"
        Paths = Get-R18AgentToolCallEvidencePaths -RepositoryRoot $RepositoryRoot
    }
}

function Test-R18AgentToolCallEvidence {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R18AgentToolCallEvidenceRepositoryRoot))

    $set = Get-R18AgentToolCallEvidenceSet -RepositoryRoot $RepositoryRoot
    return Test-R18AgentToolCallEvidenceSet `
        -Contract $set.Contract `
        -LedgerShape $set.LedgerShape `
        -Profile $set.Profile `
        -Records $set.Records `
        -Results $set.Results `
        -Report $set.Report `
        -Snapshot $set.Snapshot `
        -EvidenceIndex $set.EvidenceIndex `
        -RepositoryRoot $RepositoryRoot
}

function Get-R18AgentToolCallEvidenceMutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch -Wildcard ($Target) {
        "record:*" {
            $recordId = $Target.Substring("record:".Length)
            return @($Set.Records | Where-Object { $_.ledger_record_id -eq $recordId })[0]
        }
        "contract" { return $Set.Contract }
        "ledger_shape" { return $Set.LedgerShape }
        "profile" { return $Set.Profile }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "evidence_index" { return $Set.EvidenceIndex }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Set-R18AgentToolCallEvidenceObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][object]$Value
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($null -eq $cursor.PSObject.Properties[$segment]) {
            $cursor | Add-Member -NotePropertyName $segment -NotePropertyValue ([pscustomobject]@{})
        }
        $cursor = $cursor.PSObject.Properties[$segment].Value
    }
    $leaf = $segments[-1]
    if ($null -eq $cursor.PSObject.Properties[$leaf]) {
        $cursor | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
    else {
        $cursor.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R18AgentToolCallEvidenceObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = $Path -split '\.'
    $cursor = $TargetObject
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        if ($null -eq $cursor.PSObject.Properties[$segment]) { return }
        $cursor = $cursor.PSObject.Properties[$segment].Value
    }
    $leaf = $segments[-1]
    if ($null -ne $cursor.PSObject.Properties[$leaf]) {
        $cursor.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R18AgentToolCallEvidenceMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    switch ([string]$Mutation.operation) {
        "remove" { Remove-R18AgentToolCallEvidenceObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) }
        "set" { Set-R18AgentToolCallEvidenceObjectPathValue -TargetObject $TargetObject -Path ([string]$Mutation.path) -Value $Mutation.value }
        default { throw "Unknown R18 agent/tool-call evidence mutation operation '$($Mutation.operation)'." }
    }
}

Export-ModuleMember -Function `
    Get-R18AgentToolCallEvidencePaths, `
    Get-R18AgentToolCallEvidenceRuntimeFlagNames, `
    New-R18AgentToolCallEvidenceRuntimeFlags, `
    New-R18AgentToolCallEvidenceArtifacts, `
    Test-R18AgentToolCallEvidence, `
    Test-R18AgentToolCallEvidenceSet, `
    Test-R18AgentToolCallEvidenceStatusTruth, `
    Get-R18AgentToolCallEvidenceSet, `
    Get-R18AgentToolCallEvidenceMutationTarget, `
    Copy-R18AgentToolCallEvidenceObject, `
    Invoke-R18AgentToolCallEvidenceMutation
