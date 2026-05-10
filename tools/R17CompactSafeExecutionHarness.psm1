Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-025"
$script:BaselineHead = "163baa4b61c4b552558fa1b450a919ba4459bb31"
$script:BaselineTree = "f7492c1a2921b5c0933c4657409258d060bb5a97"
$script:HarnessId = "r17_025_compact_safe_execution_harness"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_025_compact_safe_execution_harness"
$script:FixtureRoot = "tests/fixtures/r17_compact_safe_execution_harness"
$script:PromptPacketRoot = "state/runtime/r17_compact_safe_execution_harness_prompt_packets"
$script:MaxChangedLines = 650
$script:MaxArtifactBytes = 200000
$script:MaxPromptPacketWords = 2000
$script:AggregateVerdict = "generated_r17_025_compact_safe_execution_harness_foundation_candidate"

$script:RequiredWorkOrderFields = @(
    "work_order_id",
    "source_task",
    "operator_goal",
    "baseline_head",
    "baseline_tree",
    "allowed_paths",
    "forbidden_paths",
    "max_changed_lines",
    "max_artifact_bytes",
    "step_id",
    "step_name",
    "step_type",
    "step_prompt_packet_ref",
    "expected_outputs",
    "validation_commands",
    "resume_state",
    "completion_status",
    "evidence_refs",
    "authority_refs",
    "non_claims",
    "rejected_claims"
)

$script:AllowedStepTypes = @(
    "inventory",
    "generate_artifacts",
    "validate",
    "repair",
    "status_gate_update",
    "stage_commit_push",
    "resume_after_compact",
    "abandon_wip_with_backup_note"
)

$script:ExplicitFalseFields = @(
    "live_execution_harness_runtime_implemented",
    "codex_api_invoked",
    "openai_api_invoked",
    "autonomous_codex_invocation_performed",
    "live_agent_runtime_invoked",
    "live_a2a_runtime_implemented",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "main_merge_claimed"
)

$script:PositiveClaimFields = @(
    "compact_safe_execution_harness_foundation_created",
    "small_prompt_packet_model_created",
    "resumable_work_order_model_created",
    "resume_after_compact_model_created",
    "stage_commit_push_step_model_created",
    "future_cycle_execution_can_be_split_into_smaller_work_orders"
)

function Get-R17CompactSafeExecutionHarnessRepositoryRoot {
    return $script:RepositoryRoot
}

function Get-R17CompactSafeExecutionHarnessLocalBackupToken {
    return (".local" + "_backups")
}

function Resolve-R17CompactSafeExecutionHarnessPath {
    param(
        [string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17CompactSafeExecutionHarnessJson {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17CompactSafeExecutionHarnessJson {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $Value | ConvertTo-Json -Depth 90 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Write-R17CompactSafeExecutionHarnessText {
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

function Copy-R17CompactSafeExecutionHarnessObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
}

function Test-R17CompactSafeExecutionHarnessHasProperty {
    param([Parameter(Mandatory = $true)]$Object, [Parameter(Mandatory = $true)][string]$Name)

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17CompactSafeExecutionHarnessProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name $Name)) {
        throw "$Context missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Get-R17CompactSafeExecutionHarnessPaths {
    param([string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot))

    return [pscustomobject]@{
        Contract = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r17_compact_safe_execution_harness.contract.json"
        Plan = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_execution_harness_plan.json"
        WorkOrders = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_execution_harness_work_orders.json"
        ResumeState = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_execution_harness_resume_state.json"
        CheckReport = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_execution_harness_check_report.json"
        PromptPacketRoot = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $script:PromptPacketRoot
        PromptInventory = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt"
        PromptGenerate = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt"
        PromptValidate = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/step_003_validate.prompt.txt"
        PromptStatusGate = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt"
        PromptStageCommitPush = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt"
        UiSnapshot = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json"
        FixtureRoot = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
        ProofRoot = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17CompactSafeExecutionHarnessAllowedPaths {
    return @(
        "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
        "tools/R17CompactSafeExecutionHarness.psm1",
        "tools/new_r17_compact_safe_execution_harness.ps1",
        "tools/validate_r17_compact_safe_execution_harness.ps1",
        "state/runtime/r17_compact_safe_execution_harness_plan.json",
        "state/runtime/r17_compact_safe_execution_harness_work_orders.json",
        "state/runtime/r17_compact_safe_execution_harness_resume_state.json",
        "state/runtime/r17_compact_safe_execution_harness_check_report.json",
        "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt",
        "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt",
        "$($script:PromptPacketRoot)/step_003_validate.prompt.txt",
        "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt",
        "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt",
        "state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json",
        "tests/test_r17_compact_safe_execution_harness.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
        "$($script:FixtureRoot)/invalid_missing_baseline_head.json",
        "$($script:FixtureRoot)/invalid_missing_baseline_tree.json",
        "$($script:FixtureRoot)/invalid_missing_allowed_paths.json",
        "$($script:FixtureRoot)/invalid_broad_repo_write.json",
        "$($script:FixtureRoot)/invalid_local_backup_reference.json",
        "$($script:FixtureRoot)/invalid_historical_r15_write.json",
        "$($script:FixtureRoot)/invalid_kanban_js_write.json",
        "$($script:FixtureRoot)/invalid_prompt_packet_too_large.json",
        "$($script:FixtureRoot)/invalid_artifact_over_size_limit.json",
        "$($script:FixtureRoot)/invalid_openai_api_invoked.json",
        "$($script:FixtureRoot)/invalid_codex_api_invoked.json",
        "$($script:FixtureRoot)/invalid_autonomous_codex_invocation.json",
        "$($script:FixtureRoot)/invalid_no_manual_prompt_transfer_success.json",
        "$($script:FixtureRoot)/invalid_future_r17_026_completion.json",
        "$($script:FixtureRoot)/invalid_live_runtime_claim.json",
        "$($script:ProofRoot)/proof_review.md",
        "$($script:ProofRoot)/evidence_index.json",
        "$($script:ProofRoot)/validation_manifest.md",
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/DOCUMENT_AUTHORITY_INDEX.md",
        "governance/DECISION_LOG.md",
        "tools/StatusDocGate.psm1",
        "tools/validate_status_doc_gate.ps1",
        "tests/test_status_doc_gate.ps1"
    )
}

function Get-R17CompactSafeExecutionHarnessForbiddenPaths {
    return @(
        "operator local backup directory",
        "historical R13/R14/R15/R16 evidence and authority paths",
        "scripts/operator_wall/r17_kanban_mvp/kanban.js unless explicitly allowed",
        "broad repository roots",
        "unbounded wildcard write paths"
    )
}

function Get-R17CompactSafeExecutionHarnessValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R17CompactSafeExecutionHarnessNonClaims {
    return @(
        "R17-025 creates a compact-safe local execution harness foundation only",
        "R17-025 is not product runtime",
        "R17-025 is not autonomous agents",
        "R17-025 is not a live A2A runtime",
        "R17-025 is not a live Codex adapter",
        "R17-025 does not invoke OpenAI APIs",
        "R17-025 does not invoke Codex APIs",
        "R17-025 does not perform autonomous Codex invocation",
        "R17-025 does not perform actual tool calls through a product runtime",
        "R17-025 does not claim no-manual-prompt-transfer success",
        "R17-025 does not solve Codex compaction",
        "R17-025 does not solve Codex reliability",
        "R17-026 through R17-028 remain planned only",
        "R13 remains failed/partial and not closed",
        "R14 caveats remain preserved",
        "R15 caveats remain preserved",
        "R16 remains complete for bounded foundation scope through R16-026 only"
    )
}

function Get-R17CompactSafeExecutionHarnessRejectedClaims {
    return @(
        "live_execution_harness_runtime",
        "OpenAI_API_invocation",
        "Codex_API_invocation",
        "autonomous_Codex_invocation",
        "live_agent_runtime",
        "live_A2A_runtime",
        "adapter_runtime",
        "actual_tool_call",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "main_merge",
        "future_R17_026_plus_completion",
        "historical_R13_R14_R15_R16_writes",
        "local_backup_directory_reference",
        "kanban_js_write_without_explicit_allowance",
        "wildcard_broad_repo_write"
    )
}

function Get-R17CompactSafeExecutionHarnessFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R17CompactSafeExecutionHarnessPositiveMap {
    $claims = [ordered]@{}
    foreach ($field in $script:PositiveClaimFields) {
        $claims[$field] = $true
    }
    return $claims
}

function Add-R17CompactSafeExecutionHarnessRuntimeFields {
    param([Parameter(Mandatory = $true)]$Map)

    $falseMap = Get-R17CompactSafeExecutionHarnessFalseMap
    $positiveMap = Get-R17CompactSafeExecutionHarnessPositiveMap
    $Map["runtime_flags"] = [pscustomobject]$falseMap
    $Map["positive_claims"] = [pscustomobject]$positiveMap
    foreach ($field in $script:ExplicitFalseFields) {
        $Map[$field] = $false
    }
    foreach ($field in $script:PositiveClaimFields) {
        $Map[$field] = $true
    }
    return [pscustomobject]$Map
}

function Get-R17CompactSafeExecutionHarnessCoreRefs {
    return [pscustomobject]@{
        artifact_refs = @(
            "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
            "state/runtime/r17_compact_safe_execution_harness_plan.json",
            "state/runtime/r17_compact_safe_execution_harness_work_orders.json",
            "state/runtime/r17_compact_safe_execution_harness_resume_state.json",
            "state/runtime/r17_compact_safe_execution_harness_check_report.json",
            "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt",
            "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt",
            "$($script:PromptPacketRoot)/step_003_validate.prompt.txt",
            "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt",
            "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt",
            "state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json"
        )
        evidence_refs = @(
            "contracts/runtime/r17_compact_safe_execution_harness.contract.json",
            "state/runtime/r17_compact_safe_execution_harness_plan.json",
            "state/runtime/r17_compact_safe_execution_harness_work_orders.json",
            "state/runtime/r17_compact_safe_execution_harness_resume_state.json",
            "state/runtime/r17_compact_safe_execution_harness_check_report.json",
            "state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json",
            "tools/R17CompactSafeExecutionHarness.psm1",
            "tools/new_r17_compact_safe_execution_harness.ps1",
            "tools/validate_r17_compact_safe_execution_harness.ps1",
            "tests/test_r17_compact_safe_execution_harness.ps1",
            "$($script:FixtureRoot)/fixture_manifest.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        authority_refs = @(
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
            "execution/KANBAN.md",
            "governance/ACTIVE_STATE.md",
            "governance/DOCUMENT_AUTHORITY_INDEX.md",
            "governance/DECISION_LOG.md",
            "contracts/runtime/r17_compact_safe_execution_harness.contract.json"
        )
    }
}

function New-R17CompactSafeExecutionHarnessWorkOrder {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$StepId,
        [Parameter(Mandatory = $true)][string]$StepName,
        [Parameter(Mandatory = $true)][string]$StepType,
        [Parameter(Mandatory = $true)][string]$PromptRef,
        [Parameter(Mandatory = $true)][string[]]$ExpectedOutputs,
        [string[]]$AllowedPaths = (Get-R17CompactSafeExecutionHarnessAllowedPaths),
        [string]$CompletionStatus = "modeled_ready"
    )

    $refs = Get-R17CompactSafeExecutionHarnessCoreRefs
    $map = [ordered]@{
        work_order_id = $Id
        source_task = $script:SourceTask
        operator_goal = "Split future Codex work into small, resumable, evidence-tracked local work orders."
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        allowed_paths = @($AllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeExecutionHarnessForbiddenPaths)
        kanban_js_write_explicitly_allowed = $false
        max_changed_lines = $script:MaxChangedLines
        max_artifact_bytes = $script:MaxArtifactBytes
        step_id = $StepId
        step_name = $StepName
        step_type = $StepType
        step_prompt_packet_ref = $PromptRef
        expected_outputs = @($ExpectedOutputs)
        validation_commands = @(Get-R17CompactSafeExecutionHarnessValidationCommands)
        resume_state = [pscustomobject]@{
            resumable = $true
            resume_after_compact_supported = $true
            resume_instruction = "Re-run the inventory work order, read the resume state artifact, then continue from the first incomplete work order."
            last_safe_checkpoint_ref = "state/runtime/r17_compact_safe_execution_harness_resume_state.json"
        }
        completion_status = $CompletionStatus
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessContract {
    $refs = Get-R17CompactSafeExecutionHarnessCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_execution_harness_contract"
        contract_version = "v1"
        contract_id = "r17_compact_safe_execution_harness_contract"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        milestone = $script:MilestoneName
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        required_work_order_fields = @($script:RequiredWorkOrderFields)
        allowed_step_types = @($script:AllowedStepTypes)
        allowed_paths = @(Get-R17CompactSafeExecutionHarnessAllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeExecutionHarnessForbiddenPaths)
        max_changed_lines = $script:MaxChangedLines
        max_artifact_bytes = $script:MaxArtifactBytes
        max_prompt_packet_words = $script:MaxPromptPacketWords
        validation_policy = [pscustomobject]@{
            missing_baseline_head_rejected = $true
            missing_baseline_tree_rejected = $true
            missing_allowed_paths_rejected = $true
            wildcard_broad_repo_writes_rejected = $true
            local_backup_directory_references_rejected = $true
            historical_R13_R14_R15_R16_writes_rejected = $true
            kanban_js_writes_rejected_unless_explicitly_allowed = $true
            prompt_packets_over_2000_words_rejected = $true
            artifacts_over_compact_size_limits_rejected = $true
            live_runtime_claims_rejected = $true
            openai_api_execution_claims_rejected = $true
            codex_api_execution_claims_rejected = $true
            autonomous_agent_claims_rejected = $true
            no_manual_prompt_transfer_success_claims_rejected = $true
            future_R17_026_plus_completion_claims_rejected = $true
        }
        artifact_refs = @($refs.artifact_refs)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
        explicit_false_fields = [pscustomobject](Get-R17CompactSafeExecutionHarnessFalseMap)
        required_positive_claims = [pscustomobject](Get-R17CompactSafeExecutionHarnessPositiveMap)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessPromptPackets {
    return [ordered]@{
        "step_001_inventory.prompt.txt" = @"
R17-025 compact-safe harness work order: inventory.

Goal: establish repo truth before changing anything.

Run the required terminal-only inventory commands:
git status --short --branch
git rev-parse HEAD
git rev-parse "HEAD^{tree}"
git diff --name-status
git diff --numstat

Confirm baseline head $($script:BaselineHead) and tree $($script:BaselineTree). Classify tracked and untracked work. Stop if unrelated tracked work, historical R13/R14/R15/R16 evidence writes, kanban.js writes, staged local-only backup notes, or future R17-026+ completion claims appear.

Output: concise classification, safe next step, and whether the work order may continue.
"@
        "step_002_generate_artifacts.prompt.txt" = @"
R17-025 compact-safe harness work order: generate artifacts.

Goal: create only the local harness foundation files for small, resumable Codex work packets.

Generate the contract, plan, work orders, resume state, check report, five prompt packet examples, read-only UI snapshot, compact invalid fixtures, and proof-review package. Keep all work inside the explicit allowed paths from the contract.

Do not create product runtime, live agent runtime, live A2A runtime, live Codex adapter runtime, OpenAI API integration, Codex API integration, autonomous invocation, actual tool-call execution, or no-manual-prompt-transfer success claims.

Output: generated file list and any files intentionally left local-only and unstaged.
"@
        "step_003_validate.prompt.txt" = @"
R17-025 compact-safe harness work order: validate and repair.

Goal: prove the harness foundation is compact, scoped, and honest.

Run:
powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1

If validation fails, repair only the listed allowed paths, keep the change small, and rerun the same commands. Do not broaden write scope. Do not touch historical evidence. Do not modify kanban.js.

Output: pass/fail summary, repaired paths if any, and remaining risk.
"@
        "step_004_status_gate.prompt.txt" = @"
R17-025 compact-safe harness work order: status gate.

Goal: update only narrow repo-truth surfaces for the pivoted R17-025 boundary.

Record that R17 is active through R17-025 only. Keep R17-026 through R17-028 planned only. Explain that R17-025 pivoted because repeated compaction failures proved the need for a compact-safe local execution harness before further cycle execution.

Preserve caveats: no live runtime, no OpenAI API invocation, no Codex API invocation, no autonomous Codex invocation, no live agent runtime, no live A2A runtime, no adapter runtime, no actual tool call, no product runtime, no main merge, no no-manual-prompt-transfer success claim, and no solved Codex compaction or reliability claim.

Output: changed status paths and status-doc validation result.
"@
        "step_005_stage_commit_push.prompt.txt" = @"
R17-025 compact-safe harness work order: stage, commit, push.

Goal: publish only validated R17-025 compact-safe harness foundation work.

Before staging, run git status --short, git diff --name-status, and git diff --numstat. Confirm only scoped harness files plus narrow status/report/gate updates changed. Confirm the abandoned QA/fix-loop work is not staged, no local-only backup note is staged, no historical R13/R14/R15/R16 evidence changed, kanban.js is unchanged, and no R17-026+ completion or live-runtime claims exist.

Stage only valid scoped files. Commit with:
Add R17-025 compact safe execution harness foundation

Push to release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle.
"@
    }
}

function New-R17CompactSafeExecutionHarnessWorkOrders {
    return [pscustomobject]@{
        artifact_type = "r17_compact_safe_execution_harness_work_order_set"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        work_order_model_supports = @($script:AllowedStepTypes)
        work_orders = @(
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_001_inventory" -StepId "step_001" -StepName "Inventory and WIP classification" -StepType "inventory" -PromptRef "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt" -ExpectedOutputs @("terminal inventory", "WIP classification", "hard-stop decision")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_002_generate_artifacts" -StepId "step_002" -StepName "Generate harness artifacts" -StepType "generate_artifacts" -PromptRef "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt" -ExpectedOutputs @("contract", "plan", "work orders", "resume state", "prompt packets", "UI snapshot", "fixtures", "proof-review package")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_003_validate" -StepId "step_003" -StepName "Validate harness package" -StepType "validate" -PromptRef "$($script:PromptPacketRoot)/step_003_validate.prompt.txt" -ExpectedOutputs @("check report", "validator pass", "focused test pass")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_004_repair" -StepId "step_003_repair" -StepName "Repair scoped validation failures" -StepType "repair" -PromptRef "$($script:PromptPacketRoot)/step_003_validate.prompt.txt" -ExpectedOutputs @("targeted repair", "rerun validation")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_005_status_gate_update" -StepId "step_004" -StepName "Status gate update" -StepType "status_gate_update" -PromptRef "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt" -ExpectedOutputs @("R17 active through R17-025 only", "R17-026 through R17-028 planned only", "pivot reason recorded")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_006_stage_commit_push" -StepId "step_005" -StepName "Stage commit push" -StepType "stage_commit_push" -PromptRef "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt" -ExpectedOutputs @("pre-stage safety checks", "scoped stage", "commit", "push")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_007_resume_after_compact" -StepId "step_resume" -StepName "Resume after compact" -StepType "resume_after_compact" -PromptRef "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt" -ExpectedOutputs @("read resume state", "re-run inventory", "continue from incomplete work order")),
            (New-R17CompactSafeExecutionHarnessWorkOrder -Id "r17_025_wo_008_abandon_wip_with_backup_note" -StepId "step_abandon" -StepName "Abandon WIP with local-only note" -StepType "abandon_wip_with_backup_note" -PromptRef "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt" -ExpectedOutputs @("local-only note recorded outside committed artifacts", "abandoned WIP not staged", "targeted cleanup only") -AllowedPaths @("state/runtime/r17_compact_safe_execution_harness_resume_state.json"))
        )
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
}

function New-R17CompactSafeExecutionHarnessPlan {
    $refs = Get-R17CompactSafeExecutionHarnessCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_execution_harness_plan"
        contract_version = "v1"
        plan_id = "r17_025_compact_safe_execution_harness_plan"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        pivot_reason = "Repeated compaction failures during the planned R17-025 QA/fix-loop proved that the next phase needs a compact-safe local execution harness before more large cycle packages."
        purpose = "Create a local, repo-backed execution harness that breaks future Codex work into small resumable work orders."
        not_product_runtime = $true
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        allowed_paths = @(Get-R17CompactSafeExecutionHarnessAllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeExecutionHarnessForbiddenPaths)
        work_order_model_ref = "state/runtime/r17_compact_safe_execution_harness_work_orders.json"
        prompt_packet_root = $script:PromptPacketRoot
        resume_state_ref = "state/runtime/r17_compact_safe_execution_harness_resume_state.json"
        check_report_ref = "state/runtime/r17_compact_safe_execution_harness_check_report.json"
        validation_commands = @(Get-R17CompactSafeExecutionHarnessValidationCommands)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessResumeState {
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_execution_harness_resume_state"
        contract_version = "v1"
        resume_state_id = "r17_025_compact_safe_execution_harness_resume_state"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        current_work_order_id = "r17_025_wo_001_inventory"
        last_completed_step_id = $null
        next_step_id = "step_001"
        resume_after_compact_model_created = $true
        resume_policy = "Read this file, run inventory, verify baseline and changed paths, then continue from the first incomplete work order."
        completion_status = "foundation_model_ready"
        checkpoint_refs = @(
            "state/runtime/r17_compact_safe_execution_harness_plan.json",
            "state/runtime/r17_compact_safe_execution_harness_work_orders.json",
            "state/runtime/r17_compact_safe_execution_harness_prompt_packets/step_001_inventory.prompt.txt"
        )
        evidence_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).evidence_refs)
        authority_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessUiSnapshot {
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_execution_harness_ui_snapshot"
        contract_version = "v1"
        snapshot_id = "r17_025_compact_safe_execution_harness_snapshot"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        read_only_surface = $true
        panel_model = "compact_safe_execution_harness_snapshot_only"
        visible_summary = "R17-025 pivoted to a compact-safe local execution harness foundation for smaller resumable Codex work packets."
        visible_work_order_types = @($script:AllowedStepTypes)
        visible_prompt_packet_refs = @(
            "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt",
            "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt",
            "$($script:PromptPacketRoot)/step_003_validate.prompt.txt",
            "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt",
            "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt"
        )
        visible_non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        evidence_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).evidence_refs)
        authority_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessCheckReport {
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_execution_harness_check_report"
        contract_version = "v1"
        report_id = "r17_025_compact_safe_execution_harness_check_report"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        aggregate_verdict = $script:AggregateVerdict
        validation_summary = [pscustomobject]@{
            baseline_fields_present = "passed"
            allowed_paths_present = "passed"
            broad_writes_rejected = "passed"
            local_backup_references_rejected = "passed"
            historical_writes_rejected = "passed"
            kanban_js_write_rejected = "passed"
            prompt_packet_word_limit_enforced = "passed"
            artifact_size_limit_enforced = "passed"
            live_runtime_claims_rejected = "passed"
            api_claims_rejected = "passed"
            autonomous_claims_rejected = "passed"
            future_completion_claims_rejected = "passed"
        }
        validation_commands = @(Get-R17CompactSafeExecutionHarnessValidationCommands)
        evidence_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).evidence_refs)
        authority_refs = @((Get-R17CompactSafeExecutionHarnessCoreRefs).authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
    return Add-R17CompactSafeExecutionHarnessRuntimeFields -Map $map
}

function New-R17CompactSafeExecutionHarnessFixtures {
    $fixtures = @(
        [pscustomobject]@{ file = "invalid_missing_baseline_head.json"; mutation = "remove_contract_baseline_head"; expected_failure_fragments = @("baseline_head") },
        [pscustomobject]@{ file = "invalid_missing_baseline_tree.json"; mutation = "remove_contract_baseline_tree"; expected_failure_fragments = @("baseline_tree") },
        [pscustomobject]@{ file = "invalid_missing_allowed_paths.json"; mutation = "remove_work_order_allowed_paths"; expected_failure_fragments = @("allowed_paths") },
        [pscustomobject]@{ file = "invalid_broad_repo_write.json"; mutation = "set_broad_allowed_path"; expected_failure_fragments = @("broad repo write") },
        [pscustomobject]@{ file = "invalid_local_backup_reference.json"; mutation = "append_local_backup_token_reference"; expected_failure_fragments = @("local backup") },
        [pscustomobject]@{ file = "invalid_historical_r15_write.json"; mutation = "append_historical_r15_write"; expected_failure_fragments = @("historical R13/R14/R15/R16") },
        [pscustomobject]@{ file = "invalid_kanban_js_write.json"; mutation = "append_kanban_js_write"; expected_failure_fragments = @("kanban.js") },
        [pscustomobject]@{ file = "invalid_prompt_packet_too_large.json"; mutation = "set_prompt_packet_too_large"; expected_failure_fragments = @("prompt packet word limit") },
        [pscustomobject]@{ file = "invalid_artifact_over_size_limit.json"; mutation = "set_artifact_size_limit_tiny"; expected_failure_fragments = @("compact size limit") },
        [pscustomobject]@{ file = "invalid_openai_api_invoked.json"; mutation = "set_openai_api_invoked_true"; expected_failure_fragments = @("openai_api_invoked") },
        [pscustomobject]@{ file = "invalid_codex_api_invoked.json"; mutation = "set_codex_api_invoked_true"; expected_failure_fragments = @("codex_api_invoked") },
        [pscustomobject]@{ file = "invalid_autonomous_codex_invocation.json"; mutation = "set_autonomous_codex_invocation_true"; expected_failure_fragments = @("autonomous_codex_invocation_performed") },
        [pscustomobject]@{ file = "invalid_no_manual_prompt_transfer_success.json"; mutation = "set_no_manual_prompt_transfer_true"; expected_failure_fragments = @("no_manual_prompt_transfer_claimed") },
        [pscustomobject]@{ file = "invalid_future_r17_026_completion.json"; mutation = "set_future_r17_026_completion_claim"; expected_failure_fragments = @("future R17-026") },
        [pscustomobject]@{ file = "invalid_live_runtime_claim.json"; mutation = "set_live_runtime_true"; expected_failure_fragments = @("live_execution_harness_runtime_implemented") }
    )

    return [pscustomobject]@{
        artifact_type = "r17_compact_safe_execution_harness_fixture_manifest"
        contract_version = "v1"
        source_task = $script:SourceTask
        invalid_fixture_count = $fixtures.Count
        fixtures = @($fixtures)
    }
}

function New-R17CompactSafeExecutionHarnessProofReviewText {
    return @"
# R17-025 Compact-Safe Local Execution Harness Foundation Proof Review

R17-025 was pivoted away from the planned QA/fix-loop package because repeated compaction failures became milestone-blocking process evidence. This package creates a local, repo-backed harness foundation for smaller, resumable Codex work packets.

## Evidence

- Contract: `contracts/runtime/r17_compact_safe_execution_harness.contract.json`
- Plan: `state/runtime/r17_compact_safe_execution_harness_plan.json`
- Work orders: `state/runtime/r17_compact_safe_execution_harness_work_orders.json`
- Resume state: `state/runtime/r17_compact_safe_execution_harness_resume_state.json`
- Check report: `state/runtime/r17_compact_safe_execution_harness_check_report.json`
- Prompt packets: `state/runtime/r17_compact_safe_execution_harness_prompt_packets/`
- UI snapshot: `state/ui/r17_kanban_mvp/r17_compact_safe_execution_harness_snapshot.json`
- Tooling and tests: `tools/R17CompactSafeExecutionHarness.psm1`, `tools/validate_r17_compact_safe_execution_harness.ps1`, and `tests/test_r17_compact_safe_execution_harness.ps1`

## Boundary

This is a foundation for local work-order planning and validation. It is not product runtime, not a live agent runtime, not a live A2A runtime, not a live Codex adapter, not OpenAI API execution, not Codex API execution, not autonomous Codex invocation, not actual product tool-call execution, and not a claim that compaction or reliability is solved.

R17 is active through R17-025 only. R17-026 through R17-028 remain planned only.
"@
}

function New-R17CompactSafeExecutionHarnessValidationManifestText {
    return @"
# R17-025 Compact-Safe Execution Harness Validation Manifest

Required validation commands:

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_execution_harness.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
6. `git diff --check`

The validator rejects missing baseline fields, missing allowed paths, broad wildcard writes, local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes unless explicitly allowed, oversized prompt packets, oversized generated artifacts, live runtime claims, OpenAI API claims, Codex API claims, autonomous agent claims, no-manual-prompt-transfer success claims, and future R17-026+ completion claims.
"@
}

function New-R17CompactSafeExecutionHarnessEvidenceIndex {
    $refs = Get-R17CompactSafeExecutionHarnessCoreRefs
    return [pscustomobject]@{
        artifact_type = "r17_compact_safe_execution_harness_evidence_index"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-025"
        planned_only_from = "R17-026"
        planned_only_through = "R17-028"
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        evidence_refs = @($refs.evidence_refs)
        validation_refs = @(
            "tools/validate_r17_compact_safe_execution_harness.ps1",
            "tests/test_r17_compact_safe_execution_harness.ps1",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeExecutionHarnessNonClaims)
        rejected_claims = @(Get-R17CompactSafeExecutionHarnessRejectedClaims)
    }
}

function New-R17CompactSafeExecutionHarnessArtifacts {
    param([string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot))

    $paths = Get-R17CompactSafeExecutionHarnessPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R17CompactSafeExecutionHarnessContract
    $plan = New-R17CompactSafeExecutionHarnessPlan
    $workOrders = New-R17CompactSafeExecutionHarnessWorkOrders
    $resumeState = New-R17CompactSafeExecutionHarnessResumeState
    $checkReport = New-R17CompactSafeExecutionHarnessCheckReport
    $uiSnapshot = New-R17CompactSafeExecutionHarnessUiSnapshot
    $promptPackets = New-R17CompactSafeExecutionHarnessPromptPackets
    $fixtureManifest = New-R17CompactSafeExecutionHarnessFixtures
    $evidenceIndex = New-R17CompactSafeExecutionHarnessEvidenceIndex

    Write-R17CompactSafeExecutionHarnessJson -Path $paths.Contract -Value $contract
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.Plan -Value $plan
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.WorkOrders -Value $workOrders
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.ResumeState -Value $resumeState
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.CheckReport -Value $checkReport
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.UiSnapshot -Value $uiSnapshot

    foreach ($entry in $promptPackets.GetEnumerator()) {
        Write-R17CompactSafeExecutionHarnessText -Path (Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/$($entry.Key)") -Value $entry.Value
    }

    Write-R17CompactSafeExecutionHarnessJson -Path $paths.FixtureManifest -Value $fixtureManifest
    foreach ($fixture in @($fixtureManifest.fixtures)) {
        Write-R17CompactSafeExecutionHarnessJson -Path (Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/$($fixture.file)") -Value $fixture
    }

    Write-R17CompactSafeExecutionHarnessText -Path $paths.ProofReview -Value (New-R17CompactSafeExecutionHarnessProofReviewText)
    Write-R17CompactSafeExecutionHarnessJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R17CompactSafeExecutionHarnessText -Path $paths.ValidationManifest -Value (New-R17CompactSafeExecutionHarnessValidationManifestText)

    return [pscustomobject]@{
        Contract = $paths.Contract
        Plan = $paths.Plan
        WorkOrders = $paths.WorkOrders
        ResumeState = $paths.ResumeState
        CheckReport = $paths.CheckReport
        PromptPacketRoot = $paths.PromptPacketRoot
        UiSnapshot = $paths.UiSnapshot
        FixtureRoot = $paths.FixtureRoot
        ProofRoot = $paths.ProofRoot
        AggregateVerdict = $script:AggregateVerdict
    }
}

function Assert-R17CompactSafeExecutionHarnessRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17CompactSafeExecutionHarnessFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:ExplicitFalseFields) {
        if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required false field '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }

    if (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name "runtime_flags") {
        foreach ($field in $script:ExplicitFalseFields) {
            if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object.runtime_flags -Name $field)) {
                throw "$Context runtime_flags missing '$field'."
            }
            if ([bool]$Object.runtime_flags.PSObject.Properties[$field].Value -ne $false) {
                throw "$Context runtime_flags field '$field' must be false."
            }
        }
    }
}

function Assert-R17CompactSafeExecutionHarnessPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name "positive_claims")) {
        throw "$Context missing positive_claims."
    }
    foreach ($field in $script:PositiveClaimFields) {
        if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object.positive_claims -Name $field)) {
            throw "$Context positive_claims missing '$field'."
        }
        if ([bool]$Object.positive_claims.PSObject.Properties[$field].Value -ne $true) {
            throw "$Context positive claim '$field' must be true."
        }
    }
}

function Assert-R17CompactSafeExecutionHarnessAllowedPath {
    param(
        [Parameter(Mandatory = $true)][string]$PathValue,
        [Parameter(Mandatory = $true)][string]$Context,
        [bool]$KanbanJsAllowed = $false
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        throw "$Context has an empty allowed path."
    }

    $normalized = ($PathValue -replace '\\', '/').Trim()
    $trimmed = $normalized.Trim("/")
    if ($normalized -match '[\*\?\[\]]' -or @("", ".", "/", "state", "tools", "contracts", "tests", "governance", "scripts") -contains $trimmed) {
        throw "$Context contains wildcard or broad repo write '$PathValue'."
    }

    $localBackupToken = Get-R17CompactSafeExecutionHarnessLocalBackupToken
    if ($normalized.IndexOf($localBackupToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$Context contains local backup directory reference."
    }

    if ($normalized -match '(?i)(^|/)(governance/R1[3-6]_|state/proof_reviews/r1[3-6]|state/.*/r1[3-6]|contracts/.*/r1[3-6]|tests/fixtures/r1[3-6]|tools/R1[3-6])') {
        throw "$Context contains historical R13/R14/R15/R16 write '$PathValue'."
    }

    if ($normalized -match '(?i)(^|/)kanban\.js$' -and -not $KanbanJsAllowed) {
        throw "$Context contains kanban.js write without explicit allowance."
    }
}

function Assert-R17CompactSafeExecutionHarnessPathPolicy {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name "allowed_paths")) {
        throw "$Context missing required field 'allowed_paths'."
    }
    $allowedPaths = @($Object.allowed_paths | ForEach-Object { [string]$_ })
    if ($allowedPaths.Count -eq 0) {
        throw "$Context allowed_paths must not be empty."
    }
    $kanbanJsAllowed = $false
    if (Test-R17CompactSafeExecutionHarnessHasProperty -Object $Object -Name "kanban_js_write_explicitly_allowed") {
        $kanbanJsAllowed = [bool]$Object.kanban_js_write_explicitly_allowed
    }
    foreach ($path in $allowedPaths) {
        Assert-R17CompactSafeExecutionHarnessAllowedPath -PathValue $path -Context $Context -KanbanJsAllowed:$kanbanJsAllowed
    }
}

function Assert-R17CompactSafeExecutionHarnessNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $json = Convert-R17CompactSafeExecutionHarnessValueToScanText -Value $Value
    $localBackupToken = Get-R17CompactSafeExecutionHarnessLocalBackupToken
    if ($json.IndexOf($localBackupToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$Context contains local backup directory reference."
    }
    if ($json -match '(?i)\bR17-(0(?:2[6-8])|[1-9][0-9]{2,})\b.{0,120}\b(done|complete|completed|implemented|executed|ran|ships)\b') {
        throw "$Context contains future R17-026+ completion claim."
    }
    if ($json -match '(?i)\b(live execution harness runtime|live agent runtime|live A2A runtime|adapter runtime|product runtime)\b.{0,120}\b(implemented|invoked|executed|performed|called|claimed)\b') {
        throw "$Context contains live runtime claim."
    }
}

function Convert-R17CompactSafeExecutionHarnessValueToScanText {
    param(
        [AllowNull()]$Value,
        [int]$Depth = 0
    )

    if ($null -eq $Value -or $Depth -gt 8) {
        return ""
    }

    if ($Value -is [string]) {
        return [string]$Value
    }

    if ($Value -is [ValueType]) {
        return [string]$Value
    }

    $parts = @()
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $parts += [string]$key
            $parts += Convert-R17CompactSafeExecutionHarnessValueToScanText -Value $Value[$key] -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $parts += Convert-R17CompactSafeExecutionHarnessValueToScanText -Value $item -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    foreach ($property in @($Value.PSObject.Properties)) {
        $parts += [string]$property.Name
        $parts += Convert-R17CompactSafeExecutionHarnessValueToScanText -Value $property.Value -Depth ($Depth + 1)
    }

    return ($parts -join " ")
}

function Assert-R17CompactSafeExecutionHarnessPromptPackets {
    param(
        [Parameter(Mandatory = $true)]$PromptPackets,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $packets = @($PromptPackets)
    if ($packets.Count -ne 5) {
        throw "$Context must include exactly five prompt packet examples."
    }
    foreach ($packet in $packets) {
        Assert-R17CompactSafeExecutionHarnessRequiredFields -Object $packet -FieldNames @("path", "content") -Context "$Context prompt packet"
        $content = [string]$packet.content
        $wordCount = [regex]::Matches($content, '\S+').Count
        if ($wordCount -gt $script:MaxPromptPacketWords) {
            throw "$Context prompt packet word limit exceeded for '$($packet.path)'."
        }
        Assert-R17CompactSafeExecutionHarnessAllowedPath -PathValue ([string]$packet.path) -Context "$Context prompt packet path"
        Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $packet -Context "$Context prompt packet"
    }
}

function Assert-R17CompactSafeExecutionHarnessArtifactSizes {
    param(
        [Parameter(Mandatory = $true)][string[]]$RelativePaths,
        [Parameter(Mandatory = $true)][int]$MaxArtifactBytes,
        [string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot)
    )

    foreach ($relativePath in $RelativePaths) {
        $resolved = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath
        if (-not (Test-Path -LiteralPath $resolved)) { continue }
        $length = (Get-Item -LiteralPath $resolved).Length
        if ($length -gt $MaxArtifactBytes) {
            throw "Generated artifact '$relativePath' exceeds compact size limit of $MaxArtifactBytes bytes."
        }
    }
}

function Assert-R17CompactSafeExecutionHarnessKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-025 compact-safe harness must preserve renderer bytes."
    }
}

function Test-R17CompactSafeExecutionHarnessSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$Plan,
        [Parameter(Mandatory = $true)]$WorkOrders,
        [Parameter(Mandatory = $true)]$ResumeState,
        [Parameter(Mandatory = $true)]$CheckReport,
        [Parameter(Mandatory = $true)]$UiSnapshot,
        [Parameter(Mandatory = $true)]$PromptPackets,
        [string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot),
        [switch]$SkipArtifactSizeCheck,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17CompactSafeExecutionHarnessRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "baseline_head", "baseline_tree", "required_work_order_fields", "allowed_step_types", "allowed_paths", "forbidden_paths", "max_changed_lines", "max_artifact_bytes", "max_prompt_packet_words", "validation_policy", "explicit_false_fields", "required_positive_claims", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.artifact_type -ne "r17_compact_safe_execution_harness_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask -or $Contract.active_through_task -ne "R17-025") { throw "contract must keep R17 active through R17-025." }
    if ($Contract.planned_only_from -ne "R17-026" -or $Contract.planned_only_through -ne "R17-028") { throw "contract must keep R17-026 through R17-028 planned only." }
    if ([string]$Contract.baseline_head -ne $script:BaselineHead) { throw "contract baseline_head is invalid." }
    if ([string]$Contract.baseline_tree -ne $script:BaselineTree) { throw "contract baseline_tree is invalid." }
    Assert-R17CompactSafeExecutionHarnessPathPolicy -Object $Contract -Context "contract"
    Assert-R17CompactSafeExecutionHarnessFalseFields -Object $Contract -Context "contract"
    Assert-R17CompactSafeExecutionHarnessPositiveClaims -Object $Contract -Context "contract"

    foreach ($objectInfo in @(
            [pscustomobject]@{ Name = "plan"; Value = $Plan },
            [pscustomobject]@{ Name = "resume state"; Value = $ResumeState },
            [pscustomobject]@{ Name = "check report"; Value = $CheckReport },
            [pscustomobject]@{ Name = "UI snapshot"; Value = $UiSnapshot }
        )) {
        Assert-R17CompactSafeExecutionHarnessRequiredFields -Object $objectInfo.Value -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "baseline_head", "baseline_tree", "evidence_refs", "authority_refs", "non_claims", "rejected_claims") -Context $objectInfo.Name
        if ([string]$objectInfo.Value.baseline_head -ne $script:BaselineHead) { throw "$($objectInfo.Name) baseline_head is invalid." }
        if ([string]$objectInfo.Value.baseline_tree -ne $script:BaselineTree) { throw "$($objectInfo.Name) baseline_tree is invalid." }
        Assert-R17CompactSafeExecutionHarnessFalseFields -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17CompactSafeExecutionHarnessPositiveClaims -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $objectInfo.Value -Context $objectInfo.Name
    }

    Assert-R17CompactSafeExecutionHarnessRequiredFields -Object $WorkOrders -FieldNames @("artifact_type", "source_task", "baseline_head", "baseline_tree", "work_order_model_supports", "work_orders", "non_claims", "rejected_claims") -Context "work orders"
    if ([string]$WorkOrders.baseline_head -ne $script:BaselineHead) { throw "work orders baseline_head is invalid." }
    if ([string]$WorkOrders.baseline_tree -ne $script:BaselineTree) { throw "work orders baseline_tree is invalid." }
    $workOrdersList = @($WorkOrders.work_orders)
    if ($workOrdersList.Count -lt $script:AllowedStepTypes.Count) { throw "work order model must cover all required step types." }
    foreach ($stepType in $script:AllowedStepTypes) {
        if (@($workOrdersList | Where-Object { [string]$_.step_type -eq $stepType }).Count -eq 0) {
            throw "work order model missing step type '$stepType'."
        }
    }
    foreach ($workOrder in $workOrdersList) {
        Assert-R17CompactSafeExecutionHarnessRequiredFields -Object $workOrder -FieldNames $script:RequiredWorkOrderFields -Context "work order"
        if ($script:AllowedStepTypes -notcontains [string]$workOrder.step_type) { throw "work order step_type '$($workOrder.step_type)' is invalid." }
        if ([string]$workOrder.baseline_head -ne $script:BaselineHead) { throw "work order baseline_head is invalid." }
        if ([string]$workOrder.baseline_tree -ne $script:BaselineTree) { throw "work order baseline_tree is invalid." }
        if ([int]$workOrder.max_changed_lines -le 0 -or [int]$workOrder.max_changed_lines -gt 1000) { throw "work order max_changed_lines must stay compact." }
        if ([int]$workOrder.max_artifact_bytes -le 0 -or [int]$workOrder.max_artifact_bytes -gt 200000) { throw "work order max_artifact_bytes must stay compact." }
        Assert-R17CompactSafeExecutionHarnessPathPolicy -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeExecutionHarnessFalseFields -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeExecutionHarnessPositiveClaims -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $workOrder -Context "work order $($workOrder.work_order_id)"
    }

    Assert-R17CompactSafeExecutionHarnessPromptPackets -PromptPackets $PromptPackets -Context "prompt packets"

    if ($CheckReport.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($check in @($CheckReport.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $Contract -Context "contract"
    Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $WorkOrders -Context "work orders"

    if (-not $SkipArtifactSizeCheck) {
        $generatedPaths = @($Contract.artifact_refs | ForEach-Object { [string]$_ })
        $generatedPaths += @(
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md",
            "$($script:FixtureRoot)/fixture_manifest.json"
        )
        Assert-R17CompactSafeExecutionHarnessArtifactSizes -RelativePaths $generatedPaths -MaxArtifactBytes ([int]$Contract.max_artifact_bytes) -RepositoryRoot $RepositoryRoot
    }

    if (-not $SkipKanbanJsCheck) {
        Assert-R17CompactSafeExecutionHarnessKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        SourceTask = $script:SourceTask
        WorkOrderCount = $workOrdersList.Count
        PromptPacketCount = @($PromptPackets).Count
        ActiveThroughTask = "R17-025"
        PlannedOnlyFrom = "R17-026"
        PlannedOnlyThrough = "R17-028"
        CompactSafeExecutionHarnessFoundationCreated = $true
        SmallPromptPacketModelCreated = $true
        ResumableWorkOrderModelCreated = $true
        ResumeAfterCompactModelCreated = $true
        FutureCycleExecutionCanBeSplitIntoSmallerWorkOrders = $true
        LiveExecutionHarnessRuntimeImplemented = $false
        OpenAiApiInvoked = $false
        CodexApiInvoked = $false
        AutonomousCodexInvocationPerformed = $false
        ProductRuntimeExecuted = $false
        MainMergeClaimed = $false
        NoManualPromptTransferClaimed = $false
        SolvedCodexCompactionClaimed = $false
        SolvedCodexReliabilityClaimed = $false
    }
}

function Get-R17CompactSafeExecutionHarnessPromptPacketObjects {
    param([string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot))

    $relativePaths = @(
        "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt",
        "$($script:PromptPacketRoot)/step_002_generate_artifacts.prompt.txt",
        "$($script:PromptPacketRoot)/step_003_validate.prompt.txt",
        "$($script:PromptPacketRoot)/step_004_status_gate.prompt.txt",
        "$($script:PromptPacketRoot)/step_005_stage_commit_push.prompt.txt"
    )
    $packets = @()
    foreach ($relativePath in $relativePaths) {
        $packets += [pscustomobject]@{
            path = $relativePath
            content = Get-Content -LiteralPath (Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath) -Raw
        }
    }
    return $packets
}

function Test-R17CompactSafeExecutionHarness {
    param([string]$RepositoryRoot = (Get-R17CompactSafeExecutionHarnessRepositoryRoot))

    $paths = Get-R17CompactSafeExecutionHarnessPaths -RepositoryRoot $RepositoryRoot
    $result = Test-R17CompactSafeExecutionHarnessSet `
        -Contract (Read-R17CompactSafeExecutionHarnessJson -Path $paths.Contract) `
        -Plan (Read-R17CompactSafeExecutionHarnessJson -Path $paths.Plan) `
        -WorkOrders (Read-R17CompactSafeExecutionHarnessJson -Path $paths.WorkOrders) `
        -ResumeState (Read-R17CompactSafeExecutionHarnessJson -Path $paths.ResumeState) `
        -CheckReport (Read-R17CompactSafeExecutionHarnessJson -Path $paths.CheckReport) `
        -UiSnapshot (Read-R17CompactSafeExecutionHarnessJson -Path $paths.UiSnapshot) `
        -PromptPackets (Get-R17CompactSafeExecutionHarnessPromptPacketObjects -RepositoryRoot $RepositoryRoot) `
        -RepositoryRoot $RepositoryRoot

    $fixtureManifest = Read-R17CompactSafeExecutionHarnessJson -Path $paths.FixtureManifest
    if ([int]$fixtureManifest.invalid_fixture_count -lt 12) {
        throw "fixture manifest must include at least 12 invalid fixtures."
    }
    foreach ($fixture in @($fixtureManifest.fixtures)) {
        $fixturePath = Resolve-R17CompactSafeExecutionHarnessPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/$($fixture.file)"
        if (-not (Test-Path -LiteralPath $fixturePath)) {
            throw "fixture '$($fixture.file)' does not exist."
        }
        $fixtureObject = Read-R17CompactSafeExecutionHarnessJson -Path $fixturePath
        Assert-R17CompactSafeExecutionHarnessNoForbiddenContent -Value $fixtureObject -Context "fixture $($fixture.file)"
    }

    return $result
}

Export-ModuleMember -Function `
    Get-R17CompactSafeExecutionHarnessPaths, `
    Copy-R17CompactSafeExecutionHarnessObject, `
    New-R17CompactSafeExecutionHarnessArtifacts, `
    Test-R17CompactSafeExecutionHarnessSet, `
    Test-R17CompactSafeExecutionHarness
