Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-018"
$script:AdapterId = "evidence_auditor_api_adapter_future"
$script:AdapterType = "evidence_auditor_api_adapter"
$script:TargetAgentId = "evidence_auditor"
$script:AggregateVerdict = "generated_r17_evidence_auditor_api_adapter_foundation_candidate"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_018_evidence_auditor_api_adapter"
$script:FixtureRoot = "tests/fixtures/r17_evidence_auditor_api_adapter"
$script:MinimumInvalidFixtureCount = 50

$script:RequiredExplicitFalseFields = @(
    "adapter_enabled",
    "evidence_auditor_api_invoked",
    "external_api_call_performed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "runtime_execution_performed"
)

$script:AllowedExecutionModes = @(
    "disabled_seed",
    "packet_only",
    "response_placeholder",
    "verdict_placeholder"
)

$script:RuntimeFalseFields = @(
    "adapter_enabled",
    "adapter_runtime_implemented",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "evidence_auditor_api_invoked",
    "qa_test_agent_invoked",
    "codex_executor_invoked",
    "agent_invocation_performed",
    "a2a_message_sent",
    "board_mutation_performed",
    "product_runtime_executed",
    "production_runtime_executed",
    "live_orchestrator_runtime_invoked",
    "autonomous_agent_executed",
    "tool_call_ledger_runtime_implemented",
    "tool_call_runtime_implemented",
    "executable_handoff_performed",
    "executable_transition_performed",
    "runtime_card_creation_performed",
    "runtime_memory_engine_used",
    "vector_retrieval_performed",
    "runtime_execution_performed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "external_integration_performed",
    "full_source_file_contents_embedded",
    "broad_repo_scan_output_included",
    "broad_repo_scan_used"
)

$script:ClaimStatusFields = @(
    "live_board_mutation_claimed",
    "runtime_card_creation_claimed",
    "live_agent_runtime_claimed",
    "live_orchestrator_runtime_claimed",
    "a2a_runtime_claimed",
    "a2a_messages_claimed",
    "autonomous_agent_claimed",
    "adapter_runtime_claimed",
    "tool_call_runtime_claimed",
    "executable_handoff_claimed",
    "executable_transition_claimed",
    "api_call_claimed",
    "codex_executor_invocation_claimed",
    "qa_test_agent_invocation_claimed",
    "evidence_auditor_api_invocation_claimed",
    "runtime_memory_engine_claimed",
    "vector_retrieval_claimed",
    "dev_output_claimed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "real_audit_verdict_claimed",
    "external_audit_acceptance_claimed",
    "main_merge_claimed",
    "r13_closure_claimed",
    "r14_caveat_removal_claimed",
    "r15_caveat_removal_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "r17_019_plus_implementation_claimed",
    "external_integration_claimed"
)

$script:RequiredContractFields = @(
    "artifact_type",
    "contract_version",
    "contract_id",
    "source_task",
    "adapter_id",
    "adapter_type",
    "target_agent_id",
    "common_tool_adapter_contract_ref",
    "common_tool_adapter_seed_profile_ref",
    "required_request_fields",
    "required_response_fields",
    "required_verdict_fields",
    "required_report_fields",
    "allowed_execution_modes",
    "packet_policy",
    "exact_ref_policy",
    "required_runtime_false_fields",
    "implementation_boundaries",
    "claim_status",
    "non_claims",
    "rejected_claims"
)

$script:RequiredRequestFields = @(
    "request_packet_id",
    "source_task",
    "adapter_id",
    "adapter_type",
    "card_id",
    "requested_by_agent_id",
    "target_agent_id",
    "invocation_ref",
    "memory_packet_ref",
    "input_packet_ref",
    "developer_result_packet_ref",
    "qa_result_packet_ref",
    "audit_response_packet_ref",
    "audit_verdict_packet_ref",
    "board_event_ref",
    "tool_call_ref",
    "evidence_refs",
    "required_authority_refs",
    "acceptance_criteria_refs",
    "validation_command_refs",
    "allowed_validation_scope",
    "forbidden_actions",
    "secret_policy",
    "cost_policy",
    "timeout_policy",
    "retry_policy",
    "status",
    "execution_mode",
    "adapter_enabled",
    "evidence_auditor_api_invoked",
    "external_api_call_performed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "runtime_execution_performed",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredResponseFields = @(
    "response_packet_id",
    "request_packet_ref",
    "source_task",
    "adapter_id",
    "adapter_type",
    "card_id",
    "target_agent_id",
    "invocation_ref",
    "api_response_status",
    "response_payload_ref",
    "external_request_evidence_ref",
    "external_response_evidence_ref",
    "committed_external_request_evidence_present",
    "committed_external_response_evidence_present",
    "error_ref",
    "retry_count",
    "status",
    "execution_mode",
    "adapter_enabled",
    "evidence_auditor_api_invoked",
    "external_api_call_performed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "runtime_execution_performed",
    "runtime_flags",
    "evidence_refs",
    "non_claims",
    "rejected_claims"
)

$script:RequiredVerdictFields = @(
    "verdict_packet_id",
    "request_packet_ref",
    "response_packet_ref",
    "source_task",
    "adapter_id",
    "adapter_type",
    "card_id",
    "target_agent_id",
    "audit_status",
    "audit_summary",
    "external_verdict_evidence_ref",
    "committed_external_request_evidence_present",
    "committed_external_response_evidence_present",
    "committed_external_verdict_evidence_present",
    "status",
    "execution_mode",
    "adapter_enabled",
    "evidence_auditor_api_invoked",
    "external_api_call_performed",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "runtime_execution_performed",
    "runtime_flags",
    "evidence_refs",
    "non_claims",
    "rejected_claims"
)

$script:RequiredReportFields = @(
    "contract_ref",
    "request_packet_ref",
    "response_packet_ref",
    "verdict_packet_ref",
    "common_tool_adapter_contract_ref",
    "evidence_auditor_identity_ref",
    "evidence_auditor_memory_packet_ref",
    "invocation_log_ref",
    "codex_executor_adapter_ref",
    "qa_test_agent_adapter_ref",
    "board_ref_summary",
    "runtime_boundary_summary",
    "validation_summary",
    "aggregate_verdict",
    "non_claims",
    "rejected_claims"
)

function Get-R17EvidenceAuditorApiAdapterRepositoryRoot {
    return (Resolve-Path -LiteralPath $script:RepositoryRoot).Path
}

function Resolve-R17EvidenceAuditorApiAdapterPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17EvidenceAuditorApiAdapterJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON artifact '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "JSON artifact '$Path' is malformed. $($_.Exception.Message)"
    }
}

function Write-R17EvidenceAuditorApiAdapterJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value ($Value | ConvertTo-Json -Depth 100) -Encoding UTF8
}

function Write-R17EvidenceAuditorApiAdapterText {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Copy-R17EvidenceAuditorApiAdapterObject {
    param([Parameter(Mandatory = $true)][object]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-R17EvidenceAuditorApiAdapterPaths {
    param([string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
        RequestPacket = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"
        ResponsePacket = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"
        VerdictPacket = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"
        CheckReport = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/tools/r17_evidence_auditor_api_adapter_check_report.json"
        UiSnapshot = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json"
        FixtureRoot = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        ProofRoot = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
        UiFiles = @(
            (Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/index.html"),
            (Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/styles.css"),
            (Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/README.md"),
            (Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue "scripts/operator_wall/r17_kanban_mvp/kanban.js")
        )
    }
}

function Get-R17EvidenceAuditorApiAdapterGitIdentity {
    param([string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot))

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD." }
    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) { throw "Could not resolve git HEAD tree." }
    return [pscustomobject]@{ Head = $head; Tree = $tree }
}

function Get-R17EvidenceAuditorApiAdapterFalseFlags {
    $flags = [ordered]@{}
    foreach ($field in $script:RuntimeFalseFields) { $flags[$field] = $false }
    return $flags
}

function Get-R17EvidenceAuditorApiAdapterExplicitFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:RequiredExplicitFalseFields) { $flags[$field] = $false }
    return $flags
}

function Get-R17EvidenceAuditorApiAdapterClaimStatus {
    $status = [ordered]@{}
    foreach ($field in $script:ClaimStatusFields) { $status[$field] = $false }
    return $status
}

function Get-R17EvidenceAuditorApiAdapterNonClaims {
    return @(
        "R17-018 implements the Evidence Auditor API adapter foundation only",
        "R17-018 creates packetized audit request/response/verdict/check artifacts only",
        "R17-018 keeps adapter_enabled false",
        "R17-018 does not invoke Evidence Auditor API",
        "R17-018 does not call external APIs",
        "R17-018 does not execute an adapter runtime",
        "R17-018 does not implement tool-call runtime",
        "R17-018 does not send A2A messages",
        "R17-018 does not invoke agents",
        "R17-018 does not implement live agent runtime",
        "R17-018 does not implement live Orchestrator runtime",
        "R17-018 does not mutate the board live",
        "R17-018 does not create runtime cards",
        "R17-018 does not implement autonomous agents",
        "R17-018 does not implement runtime memory engine",
        "R17-018 does not implement vector retrieval",
        "R17-018 does not implement executable handoffs",
        "R17-018 does not implement executable transitions",
        "R17-018 does not implement product runtime",
        "R17-018 does not implement production runtime",
        "R17-018 does not produce real Dev output",
        "R17-018 does not produce real QA result",
        "R17-018 does not produce a real audit verdict",
        "R17-018 does not claim external audit acceptance",
        "R17-018 does not claim main merge",
        "R17-018 does not close R13",
        "R17-018 does not remove R14 caveats",
        "R17-018 does not remove R15 caveats",
        "R17-018 does not solve Codex compaction",
        "R17-018 does not solve Codex reliability"
    )
}

function Get-R17EvidenceAuditorApiAdapterRejectedClaims {
    return @(
        "live_board_mutation",
        "runtime_card_creation",
        "live_agent_runtime",
        "live_Orchestrator_runtime",
        "A2A_runtime",
        "A2A_messages_sent",
        "autonomous_agents",
        "adapter_runtime",
        "tool_call_runtime",
        "external_API_calls",
        "Codex_executor_invocation",
        "QA_Test_Agent_invocation",
        "Evidence_Auditor_API_invocation",
        "Evidence_Auditor_API_call",
        "runtime_memory_engine",
        "vector_retrieval_runtime",
        "broad_repo_scan_output",
        "generated_artifact_embedding_full_source_file_contents",
        "executable_handoffs",
        "executable_transitions",
        "external_integrations",
        "external_audit_acceptance",
        "main_merge",
        "production_runtime",
        "product_runtime",
        "real_Dev_output",
        "real_QA_result",
        "real_audit_verdict",
        "audit_verdict_without_committed_external_request_response_verdict_evidence",
        "R13_closure",
        "R14_caveat_removal",
        "R15_caveat_removal",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "R17_019_or_later_implementation"
    )
}

function Get-R17EvidenceAuditorApiAdapterPreservedBoundaries {
    return [ordered]@{
        r13 = [ordered]@{ status = "failed/partial"; active_through = "R13-018"; closed = $false }
        r14 = [ordered]@{ status = "accepted_with_caveats"; through = "R14-006"; caveats_removed = $false }
        r15 = [ordered]@{ status = "accepted_with_caveats"; through = "R15-009"; caveats_removed = $false }
        r16 = [ordered]@{
            status = "complete_bounded_foundation_scope"
            through = "R16-026"
            external_audit_acceptance_claimed = $false
            main_merge_completed = $false
            product_runtime_implemented = $false
            production_runtime_implemented = $false
            runtime_memory_engine_implemented = $false
            vector_retrieval_implemented = $false
            a2a_runtime_implemented = $false
            autonomous_agents_implemented = $false
            executable_handoffs_implemented = $false
            executable_transitions_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
    }
}

function Get-R17EvidenceAuditorApiAdapterDependencyRefs {
    return @(
        "contracts/tools/r17_tool_adapter.contract.json",
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "state/tools/r17_tool_adapter_contract_check_report.json",
        "contracts/tools/r17_codex_executor_adapter.contract.json",
        "state/tools/r17_codex_executor_adapter_request_packet.json",
        "state/tools/r17_codex_executor_adapter_result_packet.json",
        "state/tools/r17_codex_executor_adapter_check_report.json",
        "contracts/tools/r17_qa_test_agent_adapter.contract.json",
        "state/tools/r17_qa_test_agent_adapter_request_packet.json",
        "state/tools/r17_qa_test_agent_adapter_result_packet.json",
        "state/tools/r17_qa_test_agent_adapter_defect_packet.json",
        "state/tools/r17_qa_test_agent_adapter_check_report.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "contracts/agents/r17_agent_registry.contract.json",
        "state/agents/r17_agent_registry.json",
        "state/agents/r17_agent_identities/evidence_auditor.identity.json",
        "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json",
        "contracts/context/r17_memory_artifact_loader.contract.json",
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json"
    )
}

function Assert-R17EvidenceAuditorApiAdapterSafeRefPath {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path,
        [string]$Context = "ref",
        [switch]$AllowSeedPlaceholder,
        [switch]$AllowNone,
        [switch]$RequireExistingPath,
        [string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot)
    )

    if ($AllowSeedPlaceholder -and $Path -in @("not_implemented_seed", "not_imported", "not_applicable_seed")) { return }
    if ($AllowNone -and $Path -eq "none") { return }
    if ([string]::IsNullOrWhiteSpace($Path)) { throw "$Context path must not be empty." }
    if ([System.IO.Path]::IsPathRooted($Path)) { throw "$Context path must be repo-relative." }
    if ($Path -match '(^|/)\.\.(/|$)' -or $Path -match '\\') { throw "$Context path must be normalized repo-relative path." }
    if ($Path -match '[\*\?\[\]]') { throw "$Context path must not contain wildcard characters." }
    if ($Path -match '^(?i:https?://|file://)') { throw "$Context path must not be a URL." }
    if ($Path -match '^\.local_backups/') { throw "$Context path must not point at .local_backups." }
    if ($Path -match '(?i)(chat_history|chat-transcript|raw_chat|transcript)') { throw "$Context path must not use raw chat history as canonical evidence." }

    if ($RequireExistingPath) {
        $pathOnly = ($Path -split '#', 2)[0]
        $resolved = Resolve-R17EvidenceAuditorApiAdapterPath -RepositoryRoot $RepositoryRoot -PathValue $pathOnly
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "$Context path '$pathOnly' does not exist."
        }
    }
}

function Test-R17EvidenceAuditorApiAdapterHasProperty {
    param([object]$Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Assert-R17EvidenceAuditorApiAdapterRequiredFields {
    param(
        [object]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [string]$Context = "object"
    )

    if ($null -eq $Object) { throw "$Context is missing." }
    foreach ($field in $FieldNames) {
        if ($Object.PSObject.Properties.Name -notcontains $field) {
            throw "$Context is missing required field '$field'."
        }
    }
}

function Assert-R17EvidenceAuditorApiAdapterContains {
    param(
        [object[]]$Values,
        [string[]]$Required,
        [string]$Context
    )

    $strings = @($Values | ForEach-Object { [string]$_ })
    foreach ($requiredValue in $Required) {
        if ($strings -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-R17EvidenceAuditorApiAdapterFalseFlags {
    param(
        [object]$Object,
        [string[]]$FieldNames,
        [string]$Context = "object"
    )

    if ($null -eq $Object) { throw "$Context is missing false flag object." }
    foreach ($field in $FieldNames) {
        if ($Object.PSObject.Properties.Name -notcontains $field) {
            throw "$Context is missing required false flag '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context $field must be false."
        }
    }
}

function Assert-R17EvidenceAuditorApiAdapterExplicitFalseFields {
    param(
        [object]$Object,
        [string]$Context = "object"
    )

    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Object -FieldNames $script:RequiredExplicitFalseFields -Context $Context
}

function Assert-R17EvidenceAuditorApiAdapterNoSensitiveLiteral {
    param(
        [object]$Object,
        [string]$Context = "object"
    )

    $text = $Object | ConvertTo-Json -Depth 100
    foreach ($pattern in @("(?i)cookie", "(?i)session[_-]?id", "(?i)bearer\s+[a-z0-9\._-]+", "sk-[a-zA-Z0-9]{20,}", "(?i)api[_-]?key\s*[:=]", "(?i)token\s*[:=]")) {
        if ($text -match $pattern) {
            throw "$Context contains a secret/token/cookie/session-like literal matching '$pattern'."
        }
    }
}

function Assert-R17EvidenceAuditorApiAdapterExecutionMode {
    param(
        [Parameter(Mandatory = $true)][string]$ExecutionMode,
        [string]$Context = "execution mode"
    )

    if ($script:AllowedExecutionModes -notcontains $ExecutionMode) {
        throw "$Context execution_mode '$ExecutionMode' is not allowed."
    }
}

function Get-R17EvidenceAuditorApiAdapterValidationCommandRefs {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_evidence_auditor_api_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1"
    )
}

function New-R17EvidenceAuditorApiAdapterArtifactsObjectSet {
    param([string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot))

    $identity = Get-R17EvidenceAuditorApiAdapterGitIdentity -RepositoryRoot $RepositoryRoot
    $falseFlags = Get-R17EvidenceAuditorApiAdapterFalseFlags
    $explicitFalse = Get-R17EvidenceAuditorApiAdapterExplicitFalseMap
    $claimStatus = Get-R17EvidenceAuditorApiAdapterClaimStatus
    $nonClaims = Get-R17EvidenceAuditorApiAdapterNonClaims
    $rejectedClaims = Get-R17EvidenceAuditorApiAdapterRejectedClaims
    $dependencies = Get-R17EvidenceAuditorApiAdapterDependencyRefs

    $contractRef = "contracts/tools/r17_evidence_auditor_api_adapter.contract.json"
    $requestRef = "state/tools/r17_evidence_auditor_api_adapter_request_packet.json"
    $responseRef = "state/tools/r17_evidence_auditor_api_adapter_response_packet.json"
    $verdictRef = "state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json"
    $reportRef = "state/tools/r17_evidence_auditor_api_adapter_check_report.json"
    $snapshotRef = "state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json"
    $commonContractRef = "contracts/tools/r17_tool_adapter.contract.json"
    $seedProfileRef = "state/tools/r17_tool_adapter_seed_profiles.json#$script:AdapterId"
    $auditorIdentityRef = "state/agents/r17_agent_identities/evidence_auditor.identity.json"
    $auditorMemoryRef = "state/agents/r17_agent_memory_packets/evidence_auditor.memory_packet.json"
    $invocationRef = "state/runtime/r17_agent_invocation_log.jsonl#r17_014_seed_invocation_evidence_auditor"
    $codexResultRef = "state/tools/r17_codex_executor_adapter_result_packet.json"
    $qaResultRef = "state/tools/r17_qa_test_agent_adapter_result_packet.json"

    $authorityRefs = @(
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        $commonContractRef,
        "state/tools/r17_tool_adapter_seed_profiles.json",
        "contracts/runtime/r17_agent_invocation_log.contract.json",
        "state/runtime/r17_agent_invocation_log.jsonl",
        "state/runtime/r17_agent_invocation_log_check_report.json",
        "state/agents/r17_agent_registry.json",
        $auditorIdentityRef,
        $auditorMemoryRef,
        "state/context/r17_memory_artifact_loader_report.json",
        "contracts/board/r17_board_event.contract.json",
        "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json",
        "contracts/orchestration/r17_orchestrator_loop_state_machine.contract.json",
        "state/orchestration/r17_orchestrator_loop_transition_check_report.json",
        "contracts/tools/r17_codex_executor_adapter.contract.json",
        $codexResultRef,
        "contracts/tools/r17_qa_test_agent_adapter.contract.json",
        $qaResultRef
    )

    $evidenceRefs = @(
        $contractRef,
        $requestRef,
        $responseRef,
        $verdictRef,
        $reportRef,
        $snapshotRef,
        "tools/R17EvidenceAuditorApiAdapter.psm1",
        "tools/new_r17_evidence_auditor_api_adapter.ps1",
        "tools/validate_r17_evidence_auditor_api_adapter.ps1",
        "tests/test_r17_evidence_auditor_api_adapter.ps1",
        "tests/fixtures/r17_evidence_auditor_api_adapter/",
        "$script:ProofRoot/proof_review.md",
        "$script:ProofRoot/validation_manifest.md"
    )

    $secretPolicy = [ordered]@{
        committed_secret_material_allowed = $false
        secrets_required_for_packet_foundation = $false
        external_api_keys_required = $false
        future_secret_gate_required_before_runtime = $true
        secret_scan_claimed = $false
    }
    $costPolicy = [ordered]@{
        cost_incurred = $false
        estimated_cost_usd = 0
        external_billing_claimed = $false
        future_cost_budget_required_before_runtime = $true
        provider_cost_known = $false
    }
    $timeoutPolicy = [ordered]@{
        timeout_runtime_implemented = $false
        max_seconds_seed = 0
        future_timeout_required_before_runtime = $true
        runaway_loop_control_implemented = $false
    }
    $retryPolicy = [ordered]@{
        retry_runtime_implemented = $false
        max_retries_seed = 0
        future_retry_policy_required_before_runtime = $true
        repeated_failure_requires_user_decision = $true
    }

    $contract = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_contract"
        contract_version = "v1"
        contract_id = "aioffice-r17-018-evidence-auditor-api-adapter-contract-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        scope = "evidence_auditor_api_adapter_packet_foundation_only_no_runtime_no_api_call"
        purpose = "Create the bounded Evidence Auditor API adapter packet substrate without invoking Evidence Auditor API, performing external API calls, mutating board state, sending A2A messages, executing runtime, claiming external audit acceptance, or producing a real audit verdict."
        adapter_id = $script:AdapterId
        adapter_type = $script:AdapterType
        target_agent_id = $script:TargetAgentId
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        codex_executor_adapter_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
        qa_test_agent_adapter_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
        required_request_fields = $script:RequiredRequestFields
        required_response_fields = $script:RequiredResponseFields
        required_verdict_fields = $script:RequiredVerdictFields
        required_report_fields = $script:RequiredReportFields
        allowed_execution_modes = $script:AllowedExecutionModes
        allowed_statuses = @("disabled_seed", "packet_only", "not_executed_disabled_foundation", "not_called_disabled_seed", "not_evaluated_disabled_seed", "blocked", "invalid")
        packet_policy = [ordered]@{
            evidence_auditor_api_adapter_foundation_only = $true
            adapter_enabled = $false
            adapter_runtime_allowed = $false
            evidence_auditor_api_invocation_allowed = $false
            external_api_call_allowed = $false
            audit_verdict_claim_allowed = $false
            real_audit_verdict_allowed = $false
            external_audit_acceptance_allowed = $false
            product_runtime_execution_allowed = $false
            a2a_message_allowed = $false
            board_mutation_allowed = $false
            runtime_card_creation_allowed = $false
            real_audit_verdict_requires_committed_external_request_response_verdict_evidence = $true
        }
        exact_ref_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            wildcard_paths_allowed = $false
            urls_allowed = $false
            local_backups_refs_allowed = $false
            raw_chat_history_as_canonical_allowed = $false
            full_source_file_content_embedding_allowed = $false
            broad_repo_scan_output_allowed = $false
        }
        dependency_refs = $dependencies
        required_runtime_false_fields = $script:RuntimeFalseFields
        required_explicit_false_fields = $script:RequiredExplicitFalseFields
        required_claim_status_false_fields = $script:ClaimStatusFields
        implementation_boundaries = $falseFlags
        explicit_packet_flags = $explicitFalse
        claim_status = $claimStatus
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17EvidenceAuditorApiAdapterPreservedBoundaries
    }

    $request = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_request_packet"
        contract_version = "v1"
        request_packet_id = "aioffice-r17-018-evidence-auditor-api-adapter-request-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        adapter_id = $script:AdapterId
        adapter_type = $script:AdapterType
        card_id = $script:SourceTask
        requested_by_agent_id = "orchestrator"
        target_agent_id = $script:TargetAgentId
        target_role_name = "Evidence Auditor"
        invocation_ref = $invocationRef
        memory_packet_ref = $auditorMemoryRef
        contract_ref = $contractRef
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        input_packet_ref = $requestRef
        developer_result_packet_ref = $codexResultRef
        qa_result_packet_ref = $qaResultRef
        audit_response_packet_ref = $responseRef
        audit_verdict_packet_ref = $verdictRef
        board_event_ref = "not_implemented_seed"
        tool_call_ref = "not_implemented_seed"
        evidence_refs = $evidenceRefs
        required_authority_refs = $authorityRefs
        acceptance_criteria_refs = @(
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md#r17-018-implement-evidence-auditor-api-adapter",
            "execution/KANBAN.md#r17-018-implement-evidence-auditor-api-adapter",
            "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json#acceptance_criteria"
        )
        validation_command_refs = Get-R17EvidenceAuditorApiAdapterValidationCommandRefs
        allowed_validation_scope = [ordered]@{
            exact_repo_refs_only = $true
            allowed_command_count = 7
            approved_command_refs = Get-R17EvidenceAuditorApiAdapterValidationCommandRefs
            product_runtime_execution_allowed = $false
            production_runtime_execution_allowed = $false
            live_agent_execution_allowed = $false
            live_adapter_execution_allowed = $false
            evidence_auditor_api_invocation_allowed = $false
            external_api_calls_allowed = $false
            broad_repo_scan_allowed = $false
            full_source_file_contents_allowed = $false
        }
        forbidden_actions = @(
            "enable_adapter",
            "invoke_evidence_auditor_api",
            "call_external_api",
            "perform_runtime_execution",
            "claim_audit_verdict",
            "claim_real_audit_verdict",
            "claim_external_audit_acceptance",
            "send_a2a_message",
            "mutate_board_live",
            "create_runtime_card",
            "claim_r17_019_or_later_done",
            "claim_main_merge",
            "embed_full_source_file_contents",
            "include_broad_repo_scan_output"
        )
        secret_policy = $secretPolicy
        cost_policy = $costPolicy
        timeout_policy = $timeoutPolicy
        retry_policy = $retryPolicy
        status = "disabled_seed"
        execution_mode = "disabled_seed"
        adapter_enabled = $false
        evidence_auditor_api_invoked = $false
        external_api_call_performed = $false
        audit_verdict_claimed = $false
        real_audit_verdict = $false
        external_audit_acceptance_claimed = $false
        runtime_execution_performed = $false
        runtime_flags = $falseFlags
        claim_status = $claimStatus
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17EvidenceAuditorApiAdapterPreservedBoundaries
    }

    $response = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_response_packet"
        contract_version = "v1"
        response_packet_id = "aioffice-r17-018-evidence-auditor-api-adapter-response-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        request_packet_ref = $requestRef
        adapter_id = $script:AdapterId
        adapter_type = $script:AdapterType
        card_id = $script:SourceTask
        target_agent_id = $script:TargetAgentId
        invocation_ref = $invocationRef
        api_response_status = "not_called_disabled_seed"
        response_payload_ref = "not_implemented_seed"
        external_request_evidence_ref = "not_implemented_seed"
        external_response_evidence_ref = "not_implemented_seed"
        committed_external_request_evidence_present = $false
        committed_external_response_evidence_present = $false
        error_ref = "none"
        retry_count = 0
        status = "not_executed_disabled_foundation"
        execution_mode = "response_placeholder"
        adapter_enabled = $false
        evidence_auditor_api_invoked = $false
        external_api_call_performed = $false
        audit_verdict_claimed = $false
        real_audit_verdict = $false
        external_audit_acceptance_claimed = $false
        runtime_execution_performed = $false
        runtime_flags = $falseFlags
        claim_status = $claimStatus
        evidence_refs = $evidenceRefs
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17EvidenceAuditorApiAdapterPreservedBoundaries
    }

    $verdict = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_verdict_packet"
        contract_version = "v1"
        verdict_packet_id = "aioffice-r17-018-evidence-auditor-api-adapter-verdict-packet-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        request_packet_ref = $requestRef
        response_packet_ref = $responseRef
        adapter_id = $script:AdapterId
        adapter_type = $script:AdapterType
        card_id = $script:SourceTask
        target_agent_id = $script:TargetAgentId
        audit_status = "not_evaluated_disabled_seed"
        audit_summary = "No real audit verdict exists because R17-018 is a disabled packet-only Evidence Auditor API adapter foundation."
        external_verdict_evidence_ref = "not_implemented_seed"
        committed_external_request_evidence_present = $false
        committed_external_response_evidence_present = $false
        committed_external_verdict_evidence_present = $false
        status = "not_evaluated_disabled_foundation"
        execution_mode = "verdict_placeholder"
        adapter_enabled = $false
        evidence_auditor_api_invoked = $false
        external_api_call_performed = $false
        audit_verdict_claimed = $false
        real_audit_verdict = $false
        external_audit_acceptance_claimed = $false
        runtime_execution_performed = $false
        runtime_flags = $falseFlags
        claim_status = $claimStatus
        evidence_refs = $evidenceRefs
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17EvidenceAuditorApiAdapterPreservedBoundaries
    }

    $report = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_check_report"
        contract_version = "v1"
        report_id = "aioffice-r17-018-evidence-auditor-api-adapter-check-report-v1"
        source_milestone = $script:MilestoneName
        source_task = $script:SourceTask
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        generated_from_head = $identity.Head
        generated_from_tree = $identity.Tree
        generated_state_artifact_only = $true
        active_through_task = $script:SourceTask
        contract_ref = $contractRef
        request_packet_ref = $requestRef
        response_packet_ref = $responseRef
        verdict_packet_ref = $verdictRef
        common_tool_adapter_contract_ref = $commonContractRef
        common_tool_adapter_seed_profile_ref = $seedProfileRef
        evidence_auditor_identity_ref = $auditorIdentityRef
        evidence_auditor_memory_packet_ref = $auditorMemoryRef
        invocation_log_ref = "state/runtime/r17_agent_invocation_log.jsonl"
        codex_executor_adapter_ref = "contracts/tools/r17_codex_executor_adapter.contract.json"
        codex_executor_result_packet_ref = $codexResultRef
        qa_test_agent_adapter_ref = "contracts/tools/r17_qa_test_agent_adapter.contract.json"
        qa_result_packet_ref = $qaResultRef
        dependency_refs = $dependencies
        board_ref_summary = [ordered]@{
            board_state_ref = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json"
            board_event_ref = "not_implemented_seed"
            board_mutation_performed = $false
            runtime_card_creation_performed = $false
            canonical_truth = "repo_backed_generated_state_only"
        }
        runtime_boundary_summary = $falseFlags
        claim_status = $claimStatus
        validation_summary = [ordered]@{
            contract_fields_present = "passed"
            request_packet_present = "passed"
            response_packet_present = "passed"
            verdict_packet_present = "passed"
            check_report_present = "passed"
            common_tool_adapter_seed_profile_linked = "passed"
            evidence_auditor_identity_refs_present = "passed"
            evidence_auditor_memory_packet_ref_present = "passed"
            invocation_ref_present = "passed"
            codex_executor_result_packet_ref_present = "passed"
            qa_result_packet_ref_present = "passed"
            acceptance_criteria_refs_present = "passed"
            validation_command_refs_present = "passed"
            allowed_validation_scope_present = "passed"
            forbidden_actions_present = "passed"
            secret_policy_present = "passed"
            cost_policy_present = "passed"
            timeout_policy_present = "passed"
            retry_policy_present = "passed"
            execution_mode_disabled_or_packet_only = "passed"
            explicit_false_flags_preserved = "passed"
            runtime_false_flags_preserved = "passed"
            claim_status_false_flags_preserved = "passed"
            real_audit_verdict_requires_committed_external_evidence = "passed"
            generated_artifact_content_guard = "passed"
            broad_repo_scan_output_guard = "passed"
            compact_invalid_fixture_coverage = "passed"
            external_ui_dependencies_rejected = "passed"
            kanban_js_churn_rejected = "passed"
        }
        aggregate_verdict = $script:AggregateVerdict
        adapter_enabled = $false
        evidence_auditor_api_invoked = $false
        external_api_call_performed = $false
        audit_verdict_claimed = $false
        real_audit_verdict = $false
        external_audit_acceptance_claimed = $false
        runtime_execution_performed = $false
        full_source_file_contents_embedded = $false
        broad_repo_scan_output_included = $false
        broad_repo_scan_used = $false
        secret_material_committed = $false
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
        preserved_boundaries = Get-R17EvidenceAuditorApiAdapterPreservedBoundaries
    }

    $snapshot = [ordered]@{
        artifact_type = "r17_evidence_auditor_api_adapter_snapshot"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = $script:SourceTask
        contract_ref = $contractRef
        request_packet_ref = $requestRef
        response_packet_ref = $responseRef
        verdict_packet_ref = $verdictRef
        check_report_ref = $reportRef
        visible_adapter = "Evidence Auditor API Adapter"
        status_summary = [ordered]@{
            status = "disabled_seed"
            execution_mode = "disabled_seed"
            api_response_status = "not_called_disabled_seed"
            audit_status = "not_evaluated_disabled_seed"
            adapter_enabled = $false
            adapter_runtime_implemented = $false
            actual_tool_call_performed = $false
            evidence_auditor_api_invoked = $false
            external_api_call_performed = $false
            audit_verdict_claimed = $false
            real_audit_verdict = $false
            external_audit_acceptance_claimed = $false
            runtime_execution_performed = $false
            a2a_message_sent = $false
            agent_invocation_performed = $false
            board_mutation_performed = $false
            runtime_card_creation_performed = $false
            product_runtime_executed = $false
            production_runtime_executed = $false
        }
        runtime_boundaries = $falseFlags
        claim_status = $claimStatus
        non_claims = $nonClaims
        rejected_claims = $rejectedClaims
    }

    return [pscustomobject]@{
        Contract = $contract
        RequestPacket = $request
        ResponsePacket = $response
        VerdictPacket = $verdict
        Report = $report
        Snapshot = $snapshot
    }
}

function Get-R17EvidenceAuditorApiAdapterInvalidFixtureSpecs {
    $runtimeFlagFixtures = @()
    foreach ($field in $script:RuntimeFalseFields) {
        $runtimeFlagFixtures += [ordered]@{
            name = "invalid_runtime_flag_$field.json"
            target = "request"
            set_values = [ordered]@{ "runtime_flags.$field" = $true }
            expected_failure_fragments = @("runtime_flags $field must be false")
        }
    }

    $baseFixtures = @(
        @{ name = "invalid_missing_contract_field.json"; target = "contract"; remove_paths = @("required_request_fields"); expected_failure_fragments = @("missing required field") },
        @{ name = "invalid_missing_request_packet.json"; target = "missing_request"; expected_failure_fragments = @("request packet is missing") },
        @{ name = "invalid_missing_response_packet.json"; target = "missing_response"; expected_failure_fragments = @("response packet is missing") },
        @{ name = "invalid_missing_verdict_packet.json"; target = "missing_verdict"; expected_failure_fragments = @("verdict packet is missing") },
        @{ name = "invalid_missing_check_report.json"; target = "missing_report"; expected_failure_fragments = @("check report is missing") },
        @{ name = "invalid_unknown_adapter_id.json"; target = "request"; set_values = @{ adapter_id = "unknown_adapter" }; expected_failure_fragments = @("adapter_id is invalid") },
        @{ name = "invalid_adapter_type.json"; target = "request"; set_values = @{ adapter_type = "qa_test_agent_adapter" }; expected_failure_fragments = @("adapter_type must be evidence_auditor_api_adapter") },
        @{ name = "invalid_target_agent_id.json"; target = "request"; set_values = @{ target_agent_id = "qa_test_agent" }; expected_failure_fragments = @("target_agent_id must be evidence_auditor") },
        @{ name = "invalid_missing_invocation_ref.json"; target = "request"; remove_paths = @("invocation_ref"); expected_failure_fragments = @("missing required field 'invocation_ref'") },
        @{ name = "invalid_missing_memory_packet_ref.json"; target = "request"; remove_paths = @("memory_packet_ref"); expected_failure_fragments = @("missing required field 'memory_packet_ref'") },
        @{ name = "invalid_missing_qa_result_packet_ref.json"; target = "request"; remove_paths = @("qa_result_packet_ref"); expected_failure_fragments = @("missing required field 'qa_result_packet_ref'") },
        @{ name = "invalid_missing_response_packet_ref.json"; target = "request"; remove_paths = @("audit_response_packet_ref"); expected_failure_fragments = @("missing required field 'audit_response_packet_ref'") },
        @{ name = "invalid_missing_verdict_packet_ref.json"; target = "request"; remove_paths = @("audit_verdict_packet_ref"); expected_failure_fragments = @("missing required field 'audit_verdict_packet_ref'") },
        @{ name = "invalid_missing_acceptance_criteria_refs.json"; target = "request"; remove_paths = @("acceptance_criteria_refs"); expected_failure_fragments = @("missing required field 'acceptance_criteria_refs'") },
        @{ name = "invalid_empty_acceptance_criteria_refs.json"; target = "request"; set_values = @{ acceptance_criteria_refs = @() }; expected_failure_fragments = @("acceptance_criteria_refs must not be empty") },
        @{ name = "invalid_missing_validation_command_refs.json"; target = "request"; remove_paths = @("validation_command_refs"); expected_failure_fragments = @("missing required field 'validation_command_refs'") },
        @{ name = "invalid_empty_validation_command_refs.json"; target = "request"; set_values = @{ validation_command_refs = @() }; expected_failure_fragments = @("validation_command_refs must not be empty") },
        @{ name = "invalid_missing_allowed_validation_scope.json"; target = "request"; remove_paths = @("allowed_validation_scope"); expected_failure_fragments = @("missing required field 'allowed_validation_scope'") },
        @{ name = "invalid_broad_repo_scan_allowed.json"; target = "request"; set_values = @{ "allowed_validation_scope.broad_repo_scan_allowed" = $true }; expected_failure_fragments = @("broad repo scan") },
        @{ name = "invalid_external_api_calls_allowed.json"; target = "request"; set_values = @{ "allowed_validation_scope.external_api_calls_allowed" = $true }; expected_failure_fragments = @("external API calls") },
        @{ name = "invalid_missing_forbidden_actions.json"; target = "request"; remove_paths = @("forbidden_actions"); expected_failure_fragments = @("missing required field 'forbidden_actions'") },
        @{ name = "invalid_empty_forbidden_actions.json"; target = "request"; set_values = @{ forbidden_actions = @() }; expected_failure_fragments = @("forbidden_actions must not be empty") },
        @{ name = "invalid_missing_secret_policy.json"; target = "request"; remove_paths = @("secret_policy"); expected_failure_fragments = @("missing required field 'secret_policy'") },
        @{ name = "invalid_missing_cost_policy.json"; target = "request"; remove_paths = @("cost_policy"); expected_failure_fragments = @("missing required field 'cost_policy'") },
        @{ name = "invalid_missing_timeout_policy.json"; target = "request"; remove_paths = @("timeout_policy"); expected_failure_fragments = @("missing required field 'timeout_policy'") },
        @{ name = "invalid_missing_retry_policy.json"; target = "request"; remove_paths = @("retry_policy"); expected_failure_fragments = @("missing required field 'retry_policy'") },
        @{ name = "invalid_execution_mode_live.json"; target = "request"; set_values = @{ execution_mode = "live_audit_execution" }; expected_failure_fragments = @("execution_mode") },
        @{ name = "invalid_adapter_enabled_true.json"; target = "request"; set_values = @{ adapter_enabled = $true }; expected_failure_fragments = @("adapter_enabled must be false") },
        @{ name = "invalid_api_invoked_true.json"; target = "request"; set_values = @{ evidence_auditor_api_invoked = $true }; expected_failure_fragments = @("evidence_auditor_api_invoked must be false") },
        @{ name = "invalid_external_api_call_true.json"; target = "request"; set_values = @{ external_api_call_performed = $true }; expected_failure_fragments = @("external_api_call_performed must be false") },
        @{ name = "invalid_audit_verdict_claimed_true.json"; target = "request"; set_values = @{ audit_verdict_claimed = $true }; expected_failure_fragments = @("audit_verdict_claimed must be false") },
        @{ name = "invalid_real_audit_verdict_true.json"; target = "verdict"; set_values = @{ real_audit_verdict = $true }; expected_failure_fragments = @("real_audit_verdict must be false") },
        @{ name = "invalid_external_audit_acceptance_true.json"; target = "verdict"; set_values = @{ external_audit_acceptance_claimed = $true }; expected_failure_fragments = @("external_audit_acceptance_claimed must be false") },
        @{ name = "invalid_runtime_execution_true.json"; target = "response"; set_values = @{ runtime_execution_performed = $true }; expected_failure_fragments = @("runtime_execution_performed must be false") },
        @{ name = "invalid_live_board_mutation_claim.json"; target = "request"; set_values = @{ "claim_status.live_board_mutation_claimed" = $true }; expected_failure_fragments = @("claim_status live_board_mutation_claimed must be false") },
        @{ name = "invalid_audit_verdict_claim.json"; target = "request"; set_values = @{ "claim_status.audit_verdict_claimed" = $true }; expected_failure_fragments = @("claim_status audit_verdict_claimed must be false") },
        @{ name = "invalid_real_audit_verdict_claim.json"; target = "request"; set_values = @{ "claim_status.real_audit_verdict_claimed" = $true }; expected_failure_fragments = @("claim_status real_audit_verdict_claimed must be false") },
        @{ name = "invalid_external_audit_acceptance_claim.json"; target = "request"; set_values = @{ "claim_status.external_audit_acceptance_claimed" = $true }; expected_failure_fragments = @("claim_status external_audit_acceptance_claimed must be false") },
        @{ name = "invalid_main_merge_claim.json"; target = "request"; set_values = @{ "claim_status.main_merge_claimed" = $true }; expected_failure_fragments = @("claim_status main_merge_claimed must be false") },
        @{ name = "invalid_r17_019_plus_implementation_claim.json"; target = "request"; set_values = @{ "claim_status.r17_019_plus_implementation_claimed" = $true }; expected_failure_fragments = @("claim_status r17_019_plus_implementation_claimed must be false") },
        @{ name = "invalid_response_success_without_external_evidence.json"; target = "response"; set_values = @{ api_response_status = "success"; committed_external_request_evidence_present = $false; committed_external_response_evidence_present = $false }; expected_failure_fragments = @("external API response claim without committed external request/response evidence") },
        @{ name = "invalid_verdict_passed_without_external_evidence.json"; target = "verdict"; set_values = @{ audit_status = "passed"; committed_external_request_evidence_present = $false; committed_external_response_evidence_present = $false; committed_external_verdict_evidence_present = $false }; expected_failure_fragments = @("real audit verdict claim without committed external request/response/verdict evidence") },
        @{ name = "invalid_full_source_file_contents_embedded.json"; target = "report"; set_values = @{ full_source_file_contents_embedded = $true }; expected_failure_fragments = @("full_source_file_contents_embedded must be false") },
        @{ name = "invalid_broad_repo_scan_output_included.json"; target = "report"; set_values = @{ broad_repo_scan_output_included = $true }; expected_failure_fragments = @("broad_repo_scan_output_included must be false") },
        @{ name = "invalid_report_external_api_call_true.json"; target = "report"; set_values = @{ external_api_call_performed = $true }; expected_failure_fragments = @("external_api_call_performed must be false") },
        @{ name = "invalid_secret_literal.json"; target = "request"; set_values = @{ error_ref = "bearer redacted" }; expected_failure_fragments = @("secret/token/cookie/session-like") },
        @{ name = "invalid_fixture_coverage.json"; target = "fixture_coverage"; expected_failure_fragments = @("missing compact invalid fixture coverage") },
        @{ name = "invalid_external_ui_dependency.json"; target = "ui_text"; text = '<script src="https://example.invalid/app.js"></script>'; expected_failure_fragments = @("forbidden external dependency") },
        @{ name = "invalid_missing_ui_fragment.json"; target = "ui_text"; text = '<section>Evidence Auditor API Adapter</section>'; expected_failure_fragments = @("index.html must expose R17-018 Evidence Auditor API adapter fragment") },
        @{ name = "invalid_kanban_js_churn.json"; target = "kanban_js"; expected_failure_fragments = @("kanban.js churn") }
    )

    $all = @()
    foreach ($fixture in $baseFixtures) { $all += $fixture }
    foreach ($fixture in $runtimeFlagFixtures) { $all += $fixture }
    return $all
}

function New-R17EvidenceAuditorApiAdapterArtifacts {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot))

    $paths = Get-R17EvidenceAuditorApiAdapterPaths -RepositoryRoot $RepositoryRoot
    $set = New-R17EvidenceAuditorApiAdapterArtifactsObjectSet -RepositoryRoot $RepositoryRoot

    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.Contract -Value $set.Contract
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.RequestPacket -Value $set.RequestPacket
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.ResponsePacket -Value $set.ResponsePacket
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.VerdictPacket -Value $set.VerdictPacket
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.CheckReport -Value $set.Report
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.UiSnapshot -Value $set.Snapshot

    if (-not (Test-Path -LiteralPath $paths.FixtureRoot)) {
        New-Item -ItemType Directory -Path $paths.FixtureRoot -Force | Out-Null
    }

    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json") -Value $set.Contract
    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_request_packet.json") -Value $set.RequestPacket
    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_response_packet.json") -Value $set.ResponsePacket
    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_verdict_packet.json") -Value $set.VerdictPacket
    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json") -Value $set.Report
    Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json") -Value $set.Snapshot

    $invalidFixtureCount = 0
    foreach ($fixture in Get-R17EvidenceAuditorApiAdapterInvalidFixtureSpecs) {
        $fileName = [string]$fixture.name
        $fixtureObject = [ordered]@{
            target = [string]$fixture.target
            expected_failure_fragments = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })
        }
        if ($fixture.Contains("remove_paths")) { $fixtureObject.remove_paths = @($fixture.remove_paths | ForEach-Object { [string]$_ }) }
        if ($fixture.Contains("set_values")) { $fixtureObject.set_values = $fixture.set_values }
        if ($fixture.Contains("text")) { $fixtureObject.text = [string]$fixture.text }
        Write-R17EvidenceAuditorApiAdapterJson -Path (Join-Path $paths.FixtureRoot $fileName) -Value $fixtureObject
        $invalidFixtureCount += 1
    }

    $proofReview = @"
# R17-018 Evidence Auditor API Adapter Foundation Proof Review

## Scope
R17-018 creates a bounded Evidence Auditor API adapter foundation only. The contract and generated packets define future audit request, response placeholder, verdict placeholder, and check-report boundaries without invoking Evidence Auditor API, performing external API calls, executing runtime, mutating the board, sending A2A messages, claiming external audit acceptance, or producing a real audit verdict.

## Artifacts
- contracts/tools/r17_evidence_auditor_api_adapter.contract.json
- state/tools/r17_evidence_auditor_api_adapter_request_packet.json
- state/tools/r17_evidence_auditor_api_adapter_response_packet.json
- state/tools/r17_evidence_auditor_api_adapter_verdict_packet.json
- state/tools/r17_evidence_auditor_api_adapter_check_report.json
- state/ui/r17_kanban_mvp/r17_evidence_auditor_api_adapter_snapshot.json
- tools/R17EvidenceAuditorApiAdapter.psm1
- tools/new_r17_evidence_auditor_api_adapter.ps1
- tools/validate_r17_evidence_auditor_api_adapter.ps1
- tests/test_r17_evidence_auditor_api_adapter.ps1
- tests/fixtures/r17_evidence_auditor_api_adapter/

## Verdict
Generated foundation candidate only: $script:AggregateVerdict.

## Non-Claims
No Evidence Auditor API invocation, external API call, real audit verdict, external audit acceptance, adapter runtime, tool-call runtime, board mutation, A2A runtime, autonomous agents, product runtime, production runtime, main merge, R13 closure, R14 caveat removal, R15 caveat removal, solved Codex compaction, or solved Codex reliability is claimed.
"@
    Write-R17EvidenceAuditorApiAdapterText -Path $paths.ProofReview -Value $proofReview

    $evidenceIndex = [ordered]@{
        artifact_type = "r17_018_evidence_auditor_api_adapter_evidence_index"
        source_task = $script:SourceTask
        aggregate_verdict = $script:AggregateVerdict
        evidence_refs = @($set.RequestPacket.evidence_refs)
        validation_refs = Get-R17EvidenceAuditorApiAdapterValidationCommandRefs
        non_claims = Get-R17EvidenceAuditorApiAdapterNonClaims
    }
    Write-R17EvidenceAuditorApiAdapterJson -Path $paths.EvidenceIndex -Value $evidenceIndex

    $manifest = @"
# R17-018 Validation Manifest

Required focused validation:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1

Boundary:
- Generated packet/check/UI/proof artifacts only.
- Adapter enabled remains false.
- No Evidence Auditor API invocation.
- No external API call.
- No real audit verdict.
- No external audit acceptance.
- No adapter runtime or tool-call runtime.
- No board mutation, A2A runtime, autonomous agents, product runtime, main merge, or future R17-019+ completion claim.
"@
    Write-R17EvidenceAuditorApiAdapterText -Path $paths.ValidationManifest -Value $manifest

    return [pscustomobject]@{
        Contract = $paths.Contract
        RequestPacket = $paths.RequestPacket
        ResponsePacket = $paths.ResponsePacket
        VerdictPacket = $paths.VerdictPacket
        CheckReport = $paths.CheckReport
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        InvalidFixtureCount = $invalidFixtureCount
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17EvidenceAuditorApiAdapterPolicies {
    param(
        [object]$Object,
        [string]$Context
    )

    foreach ($policy in @("secret_policy", "cost_policy", "timeout_policy", "retry_policy")) {
        if (-not (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Object -Name $policy)) {
            throw "$Context is missing required field '$policy'."
        }
    }

    if ([bool]$Object.secret_policy.committed_secret_material_allowed -ne $false) { throw "$Context secret policy must forbid committed secret material." }
    if ([bool]$Object.cost_policy.cost_incurred -ne $false) { throw "$Context cost policy must record no cost incurred." }
    if ([bool]$Object.timeout_policy.timeout_runtime_implemented -ne $false) { throw "$Context timeout policy must not claim runtime timeout implementation." }
    if ([bool]$Object.retry_policy.retry_runtime_implemented -ne $false) { throw "$Context retry policy must not claim retry runtime implementation." }
}

function Assert-R17EvidenceAuditorApiAdapterNoRealAuditVerdictImplication {
    param(
        [object]$Packet,
        [string]$Context
    )

    if ((Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "real_audit_verdict") -and [bool]$Packet.real_audit_verdict -ne $false) {
        throw "$Context real_audit_verdict must be false."
    }
    if ((Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "audit_verdict_claimed") -and [bool]$Packet.audit_verdict_claimed -ne $false) {
        throw "$Context audit_verdict_claimed must be false."
    }
    if ((Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "external_audit_acceptance_claimed") -and [bool]$Packet.external_audit_acceptance_claimed -ne $false) {
        throw "$Context external_audit_acceptance_claimed must be false."
    }
}

function Assert-R17EvidenceAuditorApiAdapterPacket {
    param(
        [object]$Packet,
        [Parameter(Mandatory = $true)][ValidateSet("request", "response", "verdict")][string]$PacketKind,
        [string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot)
    )

    if ($null -eq $Packet) { throw "$PacketKind packet is missing." }

    if ($PacketKind -eq "request") {
        Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Packet -FieldNames $script:RequiredRequestFields -Context "request packet"
        if ($Packet.artifact_type -ne "r17_evidence_auditor_api_adapter_request_packet") { throw "request packet artifact_type is invalid." }
        if (@($Packet.acceptance_criteria_refs).Count -lt 1) { throw "request packet acceptance_criteria_refs must not be empty." }
        if (@($Packet.validation_command_refs).Count -lt 1) { throw "request packet validation_command_refs must not be empty." }
        if ($null -eq $Packet.allowed_validation_scope) { throw "request packet allowed_validation_scope is missing." }
        if ([bool]$Packet.allowed_validation_scope.broad_repo_scan_allowed -ne $false) { throw "request packet allowed_validation_scope must forbid broad repo scan." }
        if ([bool]$Packet.allowed_validation_scope.external_api_calls_allowed -ne $false) { throw "request packet allowed_validation_scope must forbid external API calls." }
        if (@($Packet.forbidden_actions).Count -lt 1) { throw "request packet forbidden_actions must not be empty." }
        Assert-R17EvidenceAuditorApiAdapterPolicies -Object $Packet -Context "request packet"
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.input_packet_ref) -Context "request packet input_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.developer_result_packet_ref) -Context "request packet developer_result_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.qa_result_packet_ref) -Context "request packet qa_result_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.audit_response_packet_ref) -Context "request packet audit_response_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.audit_verdict_packet_ref) -Context "request packet audit_verdict_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    elseif ($PacketKind -eq "response") {
        Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Packet -FieldNames $script:RequiredResponseFields -Context "response packet"
        if ($Packet.artifact_type -ne "r17_evidence_auditor_api_adapter_response_packet") { throw "response packet artifact_type is invalid." }
        if ($Packet.status -ne "not_executed_disabled_foundation") { throw "response packet status must be not_executed_disabled_foundation." }
        if ([int]$Packet.retry_count -ne 0) { throw "response packet retry_count must be 0." }
        if ([string]$Packet.api_response_status -in @("success", "accepted", "complete", "completed") -and ([bool]$Packet.committed_external_request_evidence_present -ne $true -or [bool]$Packet.committed_external_response_evidence_present -ne $true)) {
            throw "response packet makes an external API response claim without committed external request/response evidence."
        }
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.request_packet_ref) -Context "response packet request_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.response_payload_ref) -Context "response packet response_payload_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.external_request_evidence_ref) -Context "response packet external_request_evidence_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.external_response_evidence_ref) -Context "response packet external_response_evidence_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
    }
    else {
        Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Packet -FieldNames $script:RequiredVerdictFields -Context "verdict packet"
        if ($Packet.artifact_type -ne "r17_evidence_auditor_api_adapter_verdict_packet") { throw "verdict packet artifact_type is invalid." }
        if ($Packet.status -ne "not_evaluated_disabled_foundation") { throw "verdict packet status must be not_evaluated_disabled_foundation." }
        if ([string]$Packet.audit_status -in @("passed", "failed", "accepted", "rejected", "approved", "blocked") -and ([bool]$Packet.committed_external_request_evidence_present -ne $true -or [bool]$Packet.committed_external_response_evidence_present -ne $true -or [bool]$Packet.committed_external_verdict_evidence_present -ne $true)) {
            throw "verdict packet makes a real audit verdict claim without committed external request/response/verdict evidence."
        }
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.request_packet_ref) -Context "verdict packet request_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.response_packet_ref) -Context "verdict packet response_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.external_verdict_evidence_ref) -Context "verdict packet external_verdict_evidence_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
    }

    if ($Packet.source_task -ne $script:SourceTask) { throw "$PacketKind packet source_task must be R17-018." }
    if ($Packet.adapter_id -ne $script:AdapterId) { throw "$PacketKind packet adapter_id is invalid." }
    if ($Packet.adapter_type -ne $script:AdapterType) { throw "$PacketKind packet adapter_type must be evidence_auditor_api_adapter." }
    if ($Packet.target_agent_id -ne $script:TargetAgentId) { throw "$PacketKind packet target_agent_id must be evidence_auditor." }
    Assert-R17EvidenceAuditorApiAdapterExecutionMode -ExecutionMode ([string]$Packet.execution_mode) -Context "$PacketKind packet"
    Assert-R17EvidenceAuditorApiAdapterExplicitFalseFields -Object $Packet -Context "$PacketKind packet"
    Assert-R17EvidenceAuditorApiAdapterNoRealAuditVerdictImplication -Packet $Packet -Context "$PacketKind packet"

    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "invocation_ref") {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.invocation_ref) -Context "$PacketKind packet invocation_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "memory_packet_ref") {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.memory_packet_ref) -Context "$PacketKind packet memory_packet_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "board_event_ref") {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.board_event_ref) -Context "$PacketKind packet board_event_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
    }
    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "tool_call_ref") {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$Packet.tool_call_ref) -Context "$PacketKind packet tool_call_ref" -AllowSeedPlaceholder -RepositoryRoot $RepositoryRoot
    }

    if (@($Packet.evidence_refs).Count -lt 1) { throw "$PacketKind packet evidence_refs must not be empty." }
    foreach ($ref in @($Packet.evidence_refs)) {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$ref) -Context "$PacketKind packet evidence_ref" -RepositoryRoot $RepositoryRoot
    }
    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "required_authority_refs") {
        foreach ($ref in @($Packet.required_authority_refs)) {
            Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$ref) -Context "$PacketKind packet required_authority_ref" -RequireExistingPath -RepositoryRoot $RepositoryRoot
        }
    }

    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Packet.runtime_flags -FieldNames $script:RuntimeFalseFields -Context "$PacketKind packet runtime_flags"
    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Packet -Name "claim_status") {
        Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Packet.claim_status -FieldNames $script:ClaimStatusFields -Context "$PacketKind packet claim_status"
    }
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Packet.non_claims) -Required (Get-R17EvidenceAuditorApiAdapterNonClaims) -Context "$PacketKind packet non_claims"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Packet.rejected_claims) -Required (Get-R17EvidenceAuditorApiAdapterRejectedClaims) -Context "$PacketKind packet rejected_claims"
    Assert-R17EvidenceAuditorApiAdapterNoSensitiveLiteral -Object $Packet -Context "$PacketKind packet"
}

function Assert-R17EvidenceAuditorApiAdapterUiText {
    param([Parameter(Mandatory = $true)][hashtable]$UiTextByPath)

    foreach ($path in $UiTextByPath.Keys) {
        $text = [string]$UiTextByPath[$path]
        foreach ($pattern in @("http://", "https://", "(?i)\bcdn\b", "(?i)\bnpm\b", "(?i)fonts\.googleapis", "(?i)fonts\.gstatic", "(?i)unpkg", "(?i)jsdelivr", "(?i)@import\s+url")) {
            if ($text -match $pattern) {
                throw "UI file '$path' contains forbidden external dependency reference matching '$pattern'."
            }
        }
    }

    $indexText = ""
    $styleText = ""
    $readmeText = ""
    foreach ($path in $UiTextByPath.Keys) {
        if ($path -like "*index.html") { $indexText = [string]$UiTextByPath[$path] }
        if ($path -like "*styles.css") { $styleText = [string]$UiTextByPath[$path] }
        if ($path -like "*README.md") { $readmeText = [string]$UiTextByPath[$path] }
    }

    foreach ($fragment in @("evidence-auditor-api-adapter-panel", "Evidence Auditor API Adapter", "disabled seed foundation", "adapter_enabled: false", "evidence_auditor_api_invoked: false", "external_api_call_performed: false", "audit_verdict_claimed: false", "real_audit_verdict: false", "external_audit_acceptance_claimed: false", "runtime_execution_performed: false", "no Evidence Auditor API invocation", "no external API call", "no real audit verdict", "no external audit acceptance", "no adapter runtime")) {
        if ($indexText -notmatch [regex]::Escape($fragment)) {
            throw "index.html must expose R17-018 Evidence Auditor API adapter fragment '$fragment'."
        }
    }

    if ($styleText -notmatch "evidence-auditor-api-adapter-panel") { throw "styles.css must include evidence-auditor-api-adapter-panel styling." }
    if ($readmeText -notmatch "R17-018" -or $readmeText -notmatch "disabled seed") { throw "README.md must document the R17-018 disabled seed panel." }
}

function Assert-R17EvidenceAuditorApiAdapterFixtureCoverage {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [int]$MinimumInvalidFixtureCount = $script:MinimumInvalidFixtureCount
    )

    $invalidFixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "invalid_*.json" -ErrorAction SilentlyContinue)
    if ($invalidFixtures.Count -lt $MinimumInvalidFixtureCount) {
        throw "missing compact invalid fixture coverage: expected at least $MinimumInvalidFixtureCount invalid fixtures."
    }
}

function Assert-R17EvidenceAuditorApiAdapterKanbanJsUnchanged {
    param(
        [string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot),
        [string[]]$ChangedPaths
    )

    if ($null -eq $ChangedPaths) {
        $ChangedPaths = @()
        $ChangedPaths += @((& git -C $RepositoryRoot diff --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $ChangedPaths += @((& git -C $RepositoryRoot diff --cached --name-only -- "scripts/operator_wall/r17_kanban_mvp/kanban.js") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    if (@($ChangedPaths | Where-Object { $_ -eq "scripts/operator_wall/r17_kanban_mvp/kanban.js" }).Count -gt 0) {
        throw "kanban.js churn is not allowed for R17-018 unless explicitly justified."
    }
}

function Test-R17EvidenceAuditorApiAdapterSet {
    [CmdletBinding()]
    param(
        [object]$Contract,
        [object]$RequestPacket,
        [object]$ResponsePacket,
        [object]$VerdictPacket,
        [object]$Report,
        [object]$Snapshot,
        [string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot),
        [switch]$SkipUiFiles,
        [switch]$SkipFixtureCoverage
    )

    if ($null -eq $Contract) { throw "contract is missing." }
    if ($null -eq $RequestPacket) { throw "request packet is missing." }
    if ($null -eq $ResponsePacket) { throw "response packet is missing." }
    if ($null -eq $VerdictPacket) { throw "verdict packet is missing." }
    if ($null -eq $Report) { throw "check report is missing." }
    if ($null -eq $Snapshot) { throw "UI snapshot is missing." }

    Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Contract -FieldNames $script:RequiredContractFields -Context "contract"
    if ($Contract.artifact_type -ne "r17_evidence_auditor_api_adapter_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask) { throw "contract source_task must be R17-018." }
    if ($Contract.adapter_id -ne $script:AdapterId) { throw "contract adapter_id is invalid." }
    if ($Contract.adapter_type -ne $script:AdapterType) { throw "contract adapter_type must be evidence_auditor_api_adapter." }
    if ($Contract.target_agent_id -ne $script:TargetAgentId) { throw "contract target_agent_id must be evidence_auditor." }
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.required_request_fields) -Required $script:RequiredRequestFields -Context "contract required_request_fields"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.required_response_fields) -Required $script:RequiredResponseFields -Context "contract required_response_fields"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.required_verdict_fields) -Required $script:RequiredVerdictFields -Context "contract required_verdict_fields"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.allowed_execution_modes) -Required $script:AllowedExecutionModes -Context "contract allowed_execution_modes"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Contract.implementation_boundaries -FieldNames $script:RuntimeFalseFields -Context "contract implementation_boundaries"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Contract.explicit_packet_flags -FieldNames $script:RequiredExplicitFalseFields -Context "contract explicit_packet_flags"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Contract.claim_status -FieldNames $script:ClaimStatusFields -Context "contract claim_status"
    if ([bool]$Contract.packet_policy.adapter_enabled -ne $false) { throw "contract packet_policy adapter_enabled must be false." }
    if ([bool]$Contract.packet_policy.evidence_auditor_api_invocation_allowed -ne $false) { throw "contract packet_policy must disable Evidence Auditor API invocation." }
    if ([bool]$Contract.packet_policy.external_api_call_allowed -ne $false) { throw "contract packet_policy must disable external API calls." }
    if ([bool]$Contract.packet_policy.real_audit_verdict_allowed -ne $false) { throw "contract packet_policy must disable real audit verdicts." }
    if ([bool]$Contract.packet_policy.external_audit_acceptance_allowed -ne $false) { throw "contract packet_policy must disable external audit acceptance." }
    if ([bool]$Contract.exact_ref_policy.urls_allowed -ne $false) { throw "contract exact_ref_policy must forbid URLs." }
    if ([bool]$Contract.exact_ref_policy.full_source_file_content_embedding_allowed -ne $false) { throw "contract must forbid generated artifact embedding full source file contents." }
    if ([bool]$Contract.exact_ref_policy.broad_repo_scan_output_allowed -ne $false) { throw "contract must forbid broad repo scan output." }
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.non_claims) -Required (Get-R17EvidenceAuditorApiAdapterNonClaims) -Context "contract non_claims"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Contract.rejected_claims) -Required (Get-R17EvidenceAuditorApiAdapterRejectedClaims) -Context "contract rejected_claims"
    Assert-R17EvidenceAuditorApiAdapterNoSensitiveLiteral -Object $Contract -Context "contract"

    Assert-R17EvidenceAuditorApiAdapterPacket -Packet $RequestPacket -PacketKind "request" -RepositoryRoot $RepositoryRoot
    Assert-R17EvidenceAuditorApiAdapterPacket -Packet $ResponsePacket -PacketKind "response" -RepositoryRoot $RepositoryRoot
    Assert-R17EvidenceAuditorApiAdapterPacket -Packet $VerdictPacket -PacketKind "verdict" -RepositoryRoot $RepositoryRoot

    Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Report -FieldNames $script:RequiredReportFields -Context "check report"
    if ($Report.artifact_type -ne "r17_evidence_auditor_api_adapter_check_report") { throw "check report artifact_type is invalid." }
    if ($Report.source_task -ne $script:SourceTask) { throw "check report source_task must be R17-018." }
    if ($Report.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($ref in @($Report.dependency_refs)) {
        Assert-R17EvidenceAuditorApiAdapterSafeRefPath -Path ([string]$ref) -Context "check report dependency_refs" -RequireExistingPath -RepositoryRoot $RepositoryRoot
    }
    Assert-R17EvidenceAuditorApiAdapterExplicitFalseFields -Object $Report -Context "check report"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Report.runtime_boundary_summary -FieldNames $script:RuntimeFalseFields -Context "check report runtime_boundary_summary"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Report.claim_status -FieldNames $script:ClaimStatusFields -Context "check report claim_status"
    foreach ($check in @($Report.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }
    if ([bool]$Report.full_source_file_contents_embedded -ne $false) { throw "check report full_source_file_contents_embedded must be false." }
    if ([bool]$Report.broad_repo_scan_output_included -ne $false) { throw "check report broad_repo_scan_output_included must be false." }
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Report.non_claims) -Required (Get-R17EvidenceAuditorApiAdapterNonClaims) -Context "check report non_claims"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Report.rejected_claims) -Required (Get-R17EvidenceAuditorApiAdapterRejectedClaims) -Context "check report rejected_claims"
    Assert-R17EvidenceAuditorApiAdapterNoSensitiveLiteral -Object $Report -Context "check report"

    Assert-R17EvidenceAuditorApiAdapterRequiredFields -Object $Snapshot -FieldNames @("artifact_type", "source_task", "active_through_task", "contract_ref", "request_packet_ref", "response_packet_ref", "verdict_packet_ref", "check_report_ref", "visible_adapter", "status_summary", "runtime_boundaries", "claim_status", "non_claims", "rejected_claims") -Context "UI snapshot"
    if ($Snapshot.artifact_type -ne "r17_evidence_auditor_api_adapter_snapshot") { throw "UI snapshot artifact_type is invalid." }
    if ($Snapshot.active_through_task -ne $script:SourceTask) { throw "UI snapshot active_through_task must be R17-018." }
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Snapshot.status_summary -FieldNames @("adapter_enabled", "adapter_runtime_implemented", "actual_tool_call_performed", "evidence_auditor_api_invoked", "external_api_call_performed", "audit_verdict_claimed", "real_audit_verdict", "external_audit_acceptance_claimed", "runtime_execution_performed", "a2a_message_sent", "agent_invocation_performed", "board_mutation_performed", "runtime_card_creation_performed", "product_runtime_executed", "production_runtime_executed") -Context "UI snapshot status_summary"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Snapshot.runtime_boundaries -FieldNames $script:RuntimeFalseFields -Context "UI snapshot runtime_boundaries"
    Assert-R17EvidenceAuditorApiAdapterFalseFlags -Object $Snapshot.claim_status -FieldNames $script:ClaimStatusFields -Context "UI snapshot claim_status"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Snapshot.non_claims) -Required (Get-R17EvidenceAuditorApiAdapterNonClaims) -Context "UI snapshot non_claims"
    Assert-R17EvidenceAuditorApiAdapterContains -Values @($Snapshot.rejected_claims) -Required (Get-R17EvidenceAuditorApiAdapterRejectedClaims) -Context "UI snapshot rejected_claims"

    if (-not $SkipFixtureCoverage) {
        $paths = Get-R17EvidenceAuditorApiAdapterPaths -RepositoryRoot $RepositoryRoot
        Assert-R17EvidenceAuditorApiAdapterFixtureCoverage -FixtureRoot $paths.FixtureRoot
    }

    if (-not $SkipUiFiles) {
        $paths = Get-R17EvidenceAuditorApiAdapterPaths -RepositoryRoot $RepositoryRoot
        $uiText = @{}
        foreach ($uiPath in $paths.UiFiles) {
            if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) { throw "UI file '$uiPath' does not exist." }
            $uiText[$uiPath] = Get-Content -LiteralPath $uiPath -Raw
        }
        Assert-R17EvidenceAuditorApiAdapterUiText -UiTextByPath $uiText
        Assert-R17EvidenceAuditorApiAdapterKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        AdapterType = $Contract.adapter_type
        RequestStatus = $RequestPacket.status
        ResponseStatus = $ResponsePacket.status
        VerdictStatus = $VerdictPacket.status
        ExecutionMode = $RequestPacket.execution_mode
        AdapterEnabled = [bool]$Report.adapter_enabled
        EvidenceAuditorApiInvoked = [bool]$Report.evidence_auditor_api_invoked
        ExternalApiCallPerformed = [bool]$Report.external_api_call_performed
        AuditVerdictClaimed = [bool]$Report.audit_verdict_claimed
        RealAuditVerdict = [bool]$Report.real_audit_verdict
        ExternalAuditAcceptanceClaimed = [bool]$Report.external_audit_acceptance_claimed
        RuntimeExecutionPerformed = [bool]$Report.runtime_execution_performed
    }
}

function Test-R17EvidenceAuditorApiAdapter {
    [CmdletBinding()]
    param([string]$RepositoryRoot = (Get-R17EvidenceAuditorApiAdapterRepositoryRoot))

    $paths = Get-R17EvidenceAuditorApiAdapterPaths -RepositoryRoot $RepositoryRoot
    return Test-R17EvidenceAuditorApiAdapterSet `
        -Contract (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.Contract) `
        -RequestPacket (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.RequestPacket) `
        -ResponsePacket (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.ResponsePacket) `
        -VerdictPacket (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.VerdictPacket) `
        -Report (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.CheckReport) `
        -Snapshot (Read-R17EvidenceAuditorApiAdapterJson -Path $paths.UiSnapshot) `
        -RepositoryRoot $RepositoryRoot
}

function Set-R17EvidenceAuditorApiAdapterObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowNull()][object]$Value
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) {
            $current | Add-Member -NotePropertyName $part -NotePropertyValue ([pscustomobject]@{})
        }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -eq $current.PSObject.Properties[$leaf]) {
        $current | Add-Member -NotePropertyName $leaf -NotePropertyValue $Value
    }
    else {
        $current.PSObject.Properties[$leaf].Value = $Value
    }
}

function Remove-R17EvidenceAuditorApiAdapterObjectPathValue {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $parts = $Path -split '\.'
    $current = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($null -eq $current.PSObject.Properties[$part]) { return }
        $current = $current.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($null -ne $current.PSObject.Properties[$leaf]) {
        $current.PSObject.Properties.Remove($leaf)
    }
}

function Invoke-R17EvidenceAuditorApiAdapterMutation {
    param(
        [Parameter(Mandatory = $true)][object]$TargetObject,
        [Parameter(Mandatory = $true)][object]$Mutation
    )

    if (Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Mutation -Name "remove_paths") {
        foreach ($removePath in @($Mutation.remove_paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$removePath)) {
                Remove-R17EvidenceAuditorApiAdapterObjectPathValue -Object $TargetObject -Path $removePath
            }
        }
    }

    if ((Test-R17EvidenceAuditorApiAdapterHasProperty -Object $Mutation -Name "set_values") -and $null -ne $Mutation.set_values) {
        foreach ($entry in @($Mutation.set_values.PSObject.Properties)) {
            Set-R17EvidenceAuditorApiAdapterObjectPathValue -Object $TargetObject -Path $entry.Name -Value $entry.Value
        }
    }

    return $TargetObject
}

Export-ModuleMember -Function `
    Get-R17EvidenceAuditorApiAdapterPaths, `
    Get-R17EvidenceAuditorApiAdapterNonClaims, `
    Get-R17EvidenceAuditorApiAdapterRejectedClaims, `
    New-R17EvidenceAuditorApiAdapterArtifacts, `
    New-R17EvidenceAuditorApiAdapterArtifactsObjectSet, `
    Test-R17EvidenceAuditorApiAdapter, `
    Test-R17EvidenceAuditorApiAdapterSet, `
    Assert-R17EvidenceAuditorApiAdapterUiText, `
    Assert-R17EvidenceAuditorApiAdapterFixtureCoverage, `
    Assert-R17EvidenceAuditorApiAdapterKanbanJsUnchanged, `
    Invoke-R17EvidenceAuditorApiAdapterMutation, `
    Copy-R17EvidenceAuditorApiAdapterObject
