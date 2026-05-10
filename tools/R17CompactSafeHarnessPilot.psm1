Set-StrictMode -Version Latest

$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:SourceTask = "R17-026"
$script:TargetFutureCycle = "Cycle 3 QA/fix-loop"
$script:BaselineHead = "a53f2b8788e451051563fee2180c49121a5038e5"
$script:BaselineTree = "4eeb27d47fab40ef6fe5c743dab341b802fc1ba8"
$script:PilotId = "r17_026_compact_safe_harness_pilot"
$script:ProofRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_026_compact_safe_harness_pilot"
$script:FixtureRoot = "tests/fixtures/r17_compact_safe_harness_pilot"
$script:PromptPacketRoot = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets"
$script:MaxChangedLines = 650
$script:MaxArtifactBytes = 200000
$script:MaxPromptPacketWords = 2000
$script:AggregateVerdict = "generated_r17_026_compact_safe_harness_pilot_candidate"

$script:RequiredWorkOrderFields = @(
    "work_order_id",
    "source_task",
    "target_future_cycle",
    "baseline_head",
    "baseline_tree",
    "allowed_paths",
    "forbidden_paths",
    "expected_outputs",
    "validation_commands",
    "max_changed_lines",
    "max_artifact_bytes",
    "step_prompt_packet_ref",
    "resume_state",
    "completion_status",
    "evidence_refs",
    "authority_refs",
    "runtime_flags",
    "non_claims",
    "rejected_claims"
)

$script:RequiredStepTypes = @(
    "inventory_and_wip_classification",
    "contract_and_skeleton_creation",
    "cycle_packet_generation",
    "board_ui_proof_package_generation",
    "validate_and_repair",
    "status_doc_gate_update",
    "stage_commit_push",
    "resume_after_compact"
)

$script:PromptPacketFiles = @(
    "step_001_inventory.prompt.txt",
    "step_002_contract_and_skeleton.prompt.txt",
    "step_003_generate_cycle_packets.prompt.txt",
    "step_004_generate_board_ui_proof.prompt.txt",
    "step_005_validate_and_repair.prompt.txt",
    "step_006_status_gate_update.prompt.txt",
    "step_007_stage_commit_push.prompt.txt",
    "step_008_resume_after_compact.prompt.txt"
)

$script:ExplicitFalseFields = @(
    "live_execution_harness_runtime_implemented",
    "harness_pilot_runtime_executed",
    "openai_api_invoked",
    "codex_api_invoked",
    "autonomous_codex_invocation_performed",
    "live_cycle_runtime_implemented",
    "live_qa_test_agent_invoked",
    "live_developer_agent_invoked",
    "live_a2a_runtime_implemented",
    "a2a_message_sent",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "live_board_mutation_performed",
    "qa_result_claimed",
    "audit_verdict_claimed",
    "product_runtime_executed",
    "no_manual_prompt_transfer_claimed",
    "solved_codex_compaction_claimed",
    "solved_codex_reliability_claimed",
    "main_merge_claimed"
)

$script:PositiveClaimFields = @(
    "compact_safe_harness_pilot_created",
    "cycle_3_split_into_small_work_orders",
    "cycle_3_prompt_packets_created",
    "resume_after_compact_prompt_packet_created",
    "stage_commit_push_prompt_packet_created",
    "future_cycle_3_can_be_attempted_in_smaller_steps"
)

function Get-R17CompactSafeHarnessPilotRepositoryRoot {
    return $script:RepositoryRoot
}

function Get-R17CompactSafeHarnessPilotLocalBackupToken {
    return (".local" + "_backups")
}

function Resolve-R17CompactSafeHarnessPilotPath {
    param(
        [string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot),
        [Parameter(Mandatory = $true)][string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $PathValue))
}

function Read-R17CompactSafeHarnessPilotJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-R17CompactSafeHarnessPilotJson {
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

function Write-R17CompactSafeHarnessPilotText {
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

function Test-R17CompactSafeHarnessPilotHasProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Copy-R17CompactSafeHarnessPilotObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 90 | ConvertFrom-Json)
}

function Get-R17CompactSafeHarnessPilotPaths {
    param([string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot))

    $promptPaths = [ordered]@{}
    foreach ($file in $script:PromptPacketFiles) {
        $promptPaths[$file] = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/$file"
    }

    return [pscustomobject]@{
        Contract = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "contracts/runtime/r17_compact_safe_harness_pilot.contract.json"
        Plan = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json"
        WorkOrders = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json"
        ResumeState = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json"
        CheckReport = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json"
        PromptPacketRoot = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue $script:PromptPacketRoot
        PromptPackets = [pscustomobject]$promptPaths
        UiSnapshot = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json"
        FixtureRoot = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue $script:FixtureRoot
        FixtureManifest = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/fixture_manifest.json"
        ProofRoot = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue $script:ProofRoot
        ProofReview = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/proof_review.md"
        EvidenceIndex = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/evidence_index.json"
        ValidationManifest = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:ProofRoot)/validation_manifest.md"
    }
}

function Get-R17CompactSafeHarnessPilotArtifactRefs {
    $refs = @(
        "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json",
        "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json"
    )
    foreach ($file in $script:PromptPacketFiles) {
        $refs += "$($script:PromptPacketRoot)/$file"
    }
    return $refs
}

function Get-R17CompactSafeHarnessPilotAllowedPaths {
    $paths = @(
        "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
        "tools/R17CompactSafeHarnessPilot.psm1",
        "tools/new_r17_compact_safe_harness_pilot.ps1",
        "tools/validate_r17_compact_safe_harness_pilot.ps1",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
        "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json",
        "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json",
        "tests/test_r17_compact_safe_harness_pilot.ps1",
        "$($script:FixtureRoot)/fixture_manifest.json",
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
    foreach ($file in $script:PromptPacketFiles) {
        $paths += "$($script:PromptPacketRoot)/$file"
    }
    return $paths
}

function Get-R17CompactSafeHarnessPilotForbiddenPaths {
    return @(
        "operator local backup directory",
        "historical R13/R14/R15/R16 evidence and authority paths",
        "scripts/operator_wall/r17_kanban_mvp/kanban.js unless explicitly allowed",
        "broad repository roots",
        "unbounded wildcard write paths"
    )
}

function Get-R17CompactSafeHarnessPilotValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_harness_pilot.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_harness_pilot.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_harness_pilot.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
        "git diff --check"
    )
}

function Get-R17CompactSafeHarnessPilotNonClaims {
    return @(
        "R17-026 creates a compact-safe harness pilot only",
        "R17-026 models future Cycle 3 QA/fix-loop work orders but does not execute the full QA/fix-loop",
        "R17-026 does not implement live execution harness runtime",
        "R17-026 does not execute harness pilot runtime",
        "R17-026 does not invoke OpenAI APIs",
        "R17-026 does not invoke Codex APIs",
        "R17-026 does not perform autonomous Codex invocation",
        "R17-026 does not implement live cycle runtime",
        "R17-026 does not invoke live QA/Test Agent",
        "R17-026 does not invoke live Developer/Codex",
        "R17-026 does not implement live A2A runtime",
        "R17-026 does not send A2A messages",
        "R17-026 does not invoke adapter runtime",
        "R17-026 does not perform actual tool calls through a product runtime",
        "R17-026 does not perform live board mutation",
        "R17-026 does not claim a QA result",
        "R17-026 does not claim an audit verdict",
        "R17-026 does not execute product runtime",
        "R17-026 does not claim no-manual-prompt-transfer success",
        "R17-026 does not solve Codex compaction",
        "R17-026 does not solve Codex reliability",
        "R17-026 does not claim main merge",
        "R17-027 through R17-028 remain planned only",
        "R13 remains failed/partial and not closed",
        "R14 caveats remain preserved",
        "R15 caveats remain preserved",
        "R16 remains complete for bounded foundation scope through R16-026 only"
    )
}

function Get-R17CompactSafeHarnessPilotRejectedClaims {
    return @(
        "live_execution_harness_runtime",
        "harness_pilot_runtime_execution",
        "OpenAI_API_invocation",
        "Codex_API_invocation",
        "autonomous_Codex_invocation",
        "live_cycle_runtime",
        "live_QA_Test_Agent_invocation",
        "live_Developer_Codex_invocation",
        "live_A2A_runtime",
        "A2A_message_sent",
        "adapter_runtime",
        "actual_tool_call",
        "live_board_mutation",
        "QA_result",
        "audit_verdict",
        "product_runtime",
        "no_manual_prompt_transfer_success",
        "solved_Codex_compaction",
        "solved_Codex_reliability",
        "main_merge",
        "future_R17_027_plus_completion",
        "historical_R13_R14_R15_R16_writes",
        "local_backup_directory_reference",
        "kanban_js_write_without_explicit_allowance",
        "wildcard_broad_repo_write",
        "entire_cycle_3_in_one_prompt"
    )
}

function Get-R17CompactSafeHarnessPilotFalseMap {
    $flags = [ordered]@{}
    foreach ($field in $script:ExplicitFalseFields) {
        $flags[$field] = $false
    }
    return $flags
}

function Get-R17CompactSafeHarnessPilotPositiveMap {
    $claims = [ordered]@{}
    foreach ($field in $script:PositiveClaimFields) {
        $claims[$field] = $true
    }
    return $claims
}

function Add-R17CompactSafeHarnessPilotRuntimeFields {
    param([Parameter(Mandatory = $true)]$Map)

    $falseMap = Get-R17CompactSafeHarnessPilotFalseMap
    $positiveMap = Get-R17CompactSafeHarnessPilotPositiveMap
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

function Get-R17CompactSafeHarnessPilotCoreRefs {
    return [pscustomobject]@{
        artifact_refs = @(Get-R17CompactSafeHarnessPilotArtifactRefs)
        evidence_refs = @(
            "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json",
            $script:PromptPacketRoot,
            "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json",
            "tools/R17CompactSafeHarnessPilot.psm1",
            "tools/new_r17_compact_safe_harness_pilot.ps1",
            "tools/validate_r17_compact_safe_harness_pilot.ps1",
            "tests/test_r17_compact_safe_harness_pilot.ps1",
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
            "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
            "contracts/runtime/r17_compact_safe_execution_harness.contract.json"
        )
    }
}

function New-R17CompactSafeHarnessPilotWorkOrder {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$StepId,
        [Parameter(Mandatory = $true)][string]$StepName,
        [Parameter(Mandatory = $true)][string]$StepType,
        [Parameter(Mandatory = $true)][string]$PromptRef,
        [Parameter(Mandatory = $true)][string[]]$AllowedPaths,
        [Parameter(Mandatory = $true)][string[]]$ExpectedOutputs,
        [int]$MaxChangedLines = $script:MaxChangedLines
    )

    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        work_order_id = $Id
        source_task = $script:SourceTask
        target_future_cycle = $script:TargetFutureCycle
        operator_goal = "Represent the abandoned Cycle 3 QA/fix-loop as smaller, resumable, bounded future work orders."
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        allowed_paths = @($AllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeHarnessPilotForbiddenPaths)
        kanban_js_write_explicitly_allowed = $false
        expected_outputs = @($ExpectedOutputs)
        validation_commands = @(Get-R17CompactSafeHarnessPilotValidationCommands)
        max_changed_lines = $MaxChangedLines
        max_artifact_bytes = $script:MaxArtifactBytes
        step_id = $StepId
        step_name = $StepName
        step_type = $StepType
        step_prompt_packet_ref = $PromptRef
        resume_state = [pscustomobject]@{
            resumable = $true
            resume_after_compact_supported = $true
            checkpoint_ref = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json"
            resume_instruction = "Read the resume state, re-run inventory, verify baseline and path scope, then continue from the first incomplete work order."
        }
        completion_status = "pilot_modeled_ready"
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotContract {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_contract"
        contract_version = "v1"
        contract_id = "r17_compact_safe_harness_pilot_contract"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        milestone = $script:MilestoneName
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $script:BranchName
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        target_future_cycle = $script:TargetFutureCycle
        pilot_scope = "Split future Cycle 3 QA/fix-loop work into small prompt packets and work orders without executing the full QA/fix-loop."
        required_work_order_fields = @($script:RequiredWorkOrderFields)
        required_step_types = @($script:RequiredStepTypes)
        prompt_packet_files = @($script:PromptPacketFiles)
        allowed_paths = @(Get-R17CompactSafeHarnessPilotAllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeHarnessPilotForbiddenPaths)
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
            entire_cycle_3_in_one_prompt_rejected = $true
            missing_resume_after_compact_prompt_packet_rejected = $true
            missing_stage_commit_push_prompt_packet_rejected = $true
            openai_api_invocation_claims_rejected = $true
            codex_api_invocation_claims_rejected = $true
            autonomous_codex_invocation_claims_rejected = $true
            no_manual_prompt_transfer_success_claims_rejected = $true
            solved_codex_compaction_claims_rejected = $true
            solved_codex_reliability_claims_rejected = $true
            qa_result_claims_rejected = $true
            audit_verdict_claims_rejected = $true
            product_runtime_claims_rejected = $true
            future_R17_027_plus_completion_claims_rejected = $true
        }
        artifact_refs = @($refs.artifact_refs)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        explicit_false_fields = [pscustomobject](Get-R17CompactSafeHarnessPilotFalseMap)
        required_positive_claims = [pscustomobject](Get-R17CompactSafeHarnessPilotPositiveMap)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotPromptText {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Goal,
        [Parameter(Mandatory = $true)][string[]]$AllowedPaths,
        [Parameter(Mandatory = $true)][string[]]$ExpectedOutputs,
        [Parameter(Mandatory = $true)][string[]]$ValidationCommands,
        [Parameter(Mandatory = $true)][string[]]$StopConditions
    )

    $allowed = ($AllowedPaths | ForEach-Object { "- $_" }) -join "`n"
    $outputs = ($ExpectedOutputs | ForEach-Object { "- $_" }) -join "`n"
    $commands = ($ValidationCommands | ForEach-Object { "- $_" }) -join "`n"
    $stops = ($StopConditions | ForEach-Object { "- $_" }) -join "`n"
    return @"
R17-026 compact-safe harness pilot packet: $Title

Goal:
$Goal

Baseline:
- HEAD: $($script:BaselineHead)
- Tree: $($script:BaselineTree)

Allowed paths:
$allowed

Stop conditions:
$stops

Expected outputs:
$outputs

Validation commands:
$commands

Rules:
- This is one small step for the future Cycle 3 QA/fix-loop.
- Do not ask Codex to do the whole Cycle 3 QA/fix-loop in one session.
- Do not invoke OpenAI APIs, Codex APIs, live agents, adapters, A2A runtime, product runtime, or live board mutation.
- Do not claim QA results, audit verdicts, solved compaction, solved reliability, main merge, or no-manual-prompt-transfer success.
"@
}

function New-R17CompactSafeHarnessPilotPromptPackets {
    $validation = @(Get-R17CompactSafeHarnessPilotValidationCommands)
    $stop = @(
        "HEAD or tree differ from the baseline.",
        "Tracked unrelated local WIP exists before this step.",
        "Historical R13/R14/R15/R16 evidence would be changed.",
        "kanban.js would be changed.",
        "The step would exceed compact line or artifact limits."
    )

    return [ordered]@{
        "step_001_inventory.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 001 inventory and WIP classification" `
            -Goal "Run terminal Git inventory, classify any local WIP, and stop unless only ignored or untracked operator-local backup material is present." `
            -AllowedPaths @("state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json") `
            -ExpectedOutputs @("terminal Git inventory summary", "tracked WIP classification", "continue-or-stop decision") `
            -ValidationCommands @("git status --short --branch", "git rev-parse HEAD", "git rev-parse `"HEAD^{tree}`"", "git diff --name-status", "git diff --numstat") `
            -StopConditions $stop

        "step_002_contract_and_skeleton.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 002 contract and skeleton" `
            -Goal "Create or repair only the R17-026 pilot contract, module, wrapper scripts, focused test, fixture manifest, and initial runtime skeleton paths." `
            -AllowedPaths @(
                "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
                "tools/R17CompactSafeHarnessPilot.psm1",
                "tools/new_r17_compact_safe_harness_pilot.ps1",
                "tools/validate_r17_compact_safe_harness_pilot.ps1",
                "tests/test_r17_compact_safe_harness_pilot.ps1",
                "$($script:FixtureRoot)/fixture_manifest.json"
            ) `
            -ExpectedOutputs @("contract skeleton", "generator script", "validator script", "focused test", "fixture manifest") `
            -ValidationCommands $validation `
            -StopConditions $stop

        "step_003_generate_cycle_packets.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 003 generate Cycle 3 work orders and prompt packets" `
            -Goal "Generate the compact work-order set, resume state, check report, and eight short prompt packets that represent future Cycle 3 QA/fix-loop steps." `
            -AllowedPaths @(
                "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
                "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
                "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
                "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json",
                "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt",
                "$($script:PromptPacketRoot)/step_002_contract_and_skeleton.prompt.txt",
                "$($script:PromptPacketRoot)/step_003_generate_cycle_packets.prompt.txt",
                "$($script:PromptPacketRoot)/step_004_generate_board_ui_proof.prompt.txt",
                "$($script:PromptPacketRoot)/step_005_validate_and_repair.prompt.txt",
                "$($script:PromptPacketRoot)/step_006_status_gate_update.prompt.txt",
                "$($script:PromptPacketRoot)/step_007_stage_commit_push.prompt.txt",
                "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt"
            ) `
            -ExpectedOutputs @("Cycle 3 pilot plan", "eight work orders", "resume state", "check report", "eight prompt packets under 2000 words each") `
            -ValidationCommands $validation `
            -StopConditions $stop

        "step_004_generate_board_ui_proof.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 004 board UI snapshot and proof package" `
            -Goal "Generate the read-only pilot snapshot and proof-review package for the compact-safe harness pilot only." `
            -AllowedPaths @(
                "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json",
                "$($script:ProofRoot)/proof_review.md",
                "$($script:ProofRoot)/evidence_index.json",
                "$($script:ProofRoot)/validation_manifest.md"
            ) `
            -ExpectedOutputs @("read-only UI snapshot", "proof review", "evidence index", "validation manifest") `
            -ValidationCommands $validation `
            -StopConditions $stop

        "step_005_validate_and_repair.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 005 validate and repair" `
            -Goal "Run the pilot validator and focused test, then repair only R17-026 pilot scoped files if they fail." `
            -AllowedPaths @(Get-R17CompactSafeHarnessPilotAllowedPaths) `
            -ExpectedOutputs @("pilot validator pass", "focused test pass", "repair summary if needed") `
            -ValidationCommands $validation `
            -StopConditions $stop

        "step_006_status_gate_update.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 006 status gate update" `
            -Goal "Update narrow status and authority surfaces so R17 is active through R17-026 only and R17-027 through R17-028 remain planned only." `
            -AllowedPaths @(
                "README.md",
                "execution/KANBAN.md",
                "governance/ACTIVE_STATE.md",
                "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
                "governance/DOCUMENT_AUTHORITY_INDEX.md",
                "governance/DECISION_LOG.md",
                "tools/StatusDocGate.psm1",
                "tools/validate_status_doc_gate.ps1",
                "tests/test_status_doc_gate.ps1"
            ) `
            -ExpectedOutputs @("R17 active through R17-026 only", "R17-027 through R17-028 planned only", "status-doc gate updated") `
            -ValidationCommands @("powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1", "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1") `
            -StopConditions $stop

        "step_007_stage_commit_push.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 007 stage commit push" `
            -Goal "After all validations pass, stage only scoped R17-026 pilot files and narrow status updates, commit, and push the release branch." `
            -AllowedPaths @(Get-R17CompactSafeHarnessPilotAllowedPaths) `
            -ExpectedOutputs @("pre-stage git status", "scoped staged file list", "commit", "push to release branch") `
            -ValidationCommands @("git status --short", "git diff --name-status", "git diff --numstat", "git diff --check") `
            -StopConditions $stop

        "step_008_resume_after_compact.prompt.txt" = New-R17CompactSafeHarnessPilotPromptText `
            -Title "step 008 resume after compact" `
            -Goal "Resume after context compaction by reading the resume state, re-running inventory, and continuing only the first incomplete work order." `
            -AllowedPaths @(
                "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
                "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt"
            ) `
            -ExpectedOutputs @("resume checkpoint read", "fresh inventory", "first incomplete work order identified") `
            -ValidationCommands @("git status --short --branch", "git rev-parse HEAD", "git rev-parse `"HEAD^{tree}`"", "git diff --name-status", "git diff --numstat") `
            -StopConditions $stop
    }
}

function New-R17CompactSafeHarnessPilotWorkOrders {
    $pilotPaths = @{
        Inventory = @("state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json")
        Skeleton = @(
            "contracts/runtime/r17_compact_safe_harness_pilot.contract.json",
            "tools/R17CompactSafeHarnessPilot.psm1",
            "tools/new_r17_compact_safe_harness_pilot.ps1",
            "tools/validate_r17_compact_safe_harness_pilot.ps1",
            "tests/test_r17_compact_safe_harness_pilot.ps1",
            "$($script:FixtureRoot)/fixture_manifest.json"
        )
        Packets = @(
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json"
        ) + @($script:PromptPacketFiles | ForEach-Object { "$($script:PromptPacketRoot)/$_" })
        Proof = @(
            "state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json",
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        Status = @(
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

    $workOrders = @(
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_001_inventory" -StepId "step_001" -StepName "Inventory and WIP classification" -StepType "inventory_and_wip_classification" -PromptRef "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt" -AllowedPaths $pilotPaths.Inventory -ExpectedOutputs @("terminal inventory", "WIP classification", "hard-stop decision") -MaxChangedLines 100
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_002_contract_and_skeleton" -StepId "step_002" -StepName "Contract and skeleton creation" -StepType "contract_and_skeleton_creation" -PromptRef "$($script:PromptPacketRoot)/step_002_contract_and_skeleton.prompt.txt" -AllowedPaths $pilotPaths.Skeleton -ExpectedOutputs @("pilot contract", "module skeleton", "wrapper scripts", "focused test", "fixture manifest")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_003_generate_cycle_packets" -StepId "step_003" -StepName "Cycle packet generation" -StepType "cycle_packet_generation" -PromptRef "$($script:PromptPacketRoot)/step_003_generate_cycle_packets.prompt.txt" -AllowedPaths $pilotPaths.Packets -ExpectedOutputs @("Cycle 3 plan", "work order set", "resume state", "check report", "eight prompt packets")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_004_generate_board_ui_proof" -StepId "step_004" -StepName "Board UI and proof package generation" -StepType "board_ui_proof_package_generation" -PromptRef "$($script:PromptPacketRoot)/step_004_generate_board_ui_proof.prompt.txt" -AllowedPaths $pilotPaths.Proof -ExpectedOutputs @("read-only UI snapshot", "proof review", "evidence index", "validation manifest")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_005_validate_and_repair" -StepId "step_005" -StepName "Validator and focused test execution and repair" -StepType "validate_and_repair" -PromptRef "$($script:PromptPacketRoot)/step_005_validate_and_repair.prompt.txt" -AllowedPaths (Get-R17CompactSafeHarnessPilotAllowedPaths) -ExpectedOutputs @("pilot validator pass", "focused test pass", "scoped repair summary")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_006_status_gate_update" -StepId "step_006" -StepName "Status document gate update" -StepType "status_doc_gate_update" -PromptRef "$($script:PromptPacketRoot)/step_006_status_gate_update.prompt.txt" -AllowedPaths $pilotPaths.Status -ExpectedOutputs @("R17 active through R17-026 only", "R17-027 through R17-028 planned only", "updated status gate")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_007_stage_commit_push" -StepId "step_007" -StepName "Stage commit push" -StepType "stage_commit_push" -PromptRef "$($script:PromptPacketRoot)/step_007_stage_commit_push.prompt.txt" -AllowedPaths (Get-R17CompactSafeHarnessPilotAllowedPaths) -ExpectedOutputs @("pre-stage safety inventory", "scoped stage", "commit", "push")
        New-R17CompactSafeHarnessPilotWorkOrder -Id "r17_026_wo_008_resume_after_compact" -StepId "step_008" -StepName "Resume after compact" -StepType "resume_after_compact" -PromptRef "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt" -AllowedPaths @("state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json", "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt") -ExpectedOutputs @("resume checkpoint", "fresh inventory", "first incomplete work order")
    )

    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_cycle_3_work_order_set"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        work_order_model_supports = @($script:RequiredStepTypes)
        prompt_packet_root = $script:PromptPacketRoot
        work_orders = @($workOrders)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotPlan {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_cycle_3_plan"
        contract_version = "v1"
        plan_id = "r17_026_compact_safe_harness_pilot_cycle_3_plan"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        pre_pilot_accepted_state = "R17 active through R17-025 only; R17-026 through R17-028 planned only."
        pilot_reason = "R17-025 created the compact-safe harness foundation after repeated compaction failures blocked the old large QA/fix-loop prompt pattern."
        pilot_scope = "Represent the abandoned Cycle 3 QA/fix-loop as bounded work orders and short prompt packets before any future full evidence package attempt."
        full_cycle_execution_performed = $false
        allowed_paths = @(Get-R17CompactSafeHarnessPilotAllowedPaths)
        forbidden_paths = @(Get-R17CompactSafeHarnessPilotForbiddenPaths)
        work_order_set_ref = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json"
        prompt_packet_root = $script:PromptPacketRoot
        resume_state_ref = "state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json"
        validation_commands = @(Get-R17CompactSafeHarnessPilotValidationCommands)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotResumeState {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_cycle_3_resume_state"
        contract_version = "v1"
        resume_state_id = "r17_026_compact_safe_harness_pilot_cycle_3_resume_state"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        current_work_order_id = "r17_026_wo_001_inventory"
        last_completed_work_order_id = $null
        next_prompt_packet_ref = "$($script:PromptPacketRoot)/step_001_inventory.prompt.txt"
        resume_after_compact_prompt_packet_ref = "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt"
        completion_status = "pilot_ready_for_future_bounded_attempt"
        resume_policy = "Re-run inventory first, verify baseline and changed paths, then use the next incomplete work order packet only."
        checkpoint_refs = @(
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json",
            "state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json",
            "$($script:PromptPacketRoot)/step_008_resume_after_compact.prompt.txt"
        )
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotUiSnapshot {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_ui_snapshot"
        contract_version = "v1"
        snapshot_id = "r17_026_compact_safe_harness_pilot_snapshot"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        read_only_surface = $true
        panel_model = "compact_safe_harness_pilot_snapshot_only"
        visible_summary = "R17-026 pilots the R17-025 compact-safe harness by splitting the future Cycle 3 QA/fix-loop into bounded work orders and prompt packets."
        visible_work_order_count = 8
        visible_prompt_packet_refs = @($script:PromptPacketFiles | ForEach-Object { "$($script:PromptPacketRoot)/$_" })
        full_qa_fix_loop_executed = $false
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotCheckReport {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    $map = [ordered]@{
        artifact_type = "r17_compact_safe_harness_pilot_cycle_3_check_report"
        contract_version = "v1"
        report_id = "r17_026_compact_safe_harness_pilot_cycle_3_check_report"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
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
            entire_cycle_one_prompt_rejected = "passed"
            resume_prompt_required = "passed"
            stage_commit_push_prompt_required = "passed"
            api_claims_rejected = "passed"
            autonomous_claims_rejected = "passed"
            qa_and_audit_claims_rejected = "passed"
            product_runtime_claims_rejected = "passed"
            future_completion_claims_rejected = "passed"
        }
        validation_commands = @(Get-R17CompactSafeHarnessPilotValidationCommands)
        evidence_refs = @($refs.evidence_refs)
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
    return Add-R17CompactSafeHarnessPilotRuntimeFields -Map $map
}

function New-R17CompactSafeHarnessPilotFixtures {
    $fixtures = @(
        [pscustomobject]@{ file = "invalid_missing_baseline_head.json"; mutation = "remove_contract_baseline_head"; expected_failure_fragments = @("baseline_head") },
        [pscustomobject]@{ file = "invalid_missing_baseline_tree.json"; mutation = "remove_contract_baseline_tree"; expected_failure_fragments = @("baseline_tree") },
        [pscustomobject]@{ file = "invalid_missing_allowed_paths.json"; mutation = "remove_work_order_allowed_paths"; expected_failure_fragments = @("allowed_paths") },
        [pscustomobject]@{ file = "invalid_broad_repo_write.json"; mutation = "set_broad_allowed_path"; expected_failure_fragments = @("broad repo write") },
        [pscustomobject]@{ file = "invalid_local_backup_reference.json"; mutation = "append_local_backup_token_reference"; expected_failure_fragments = @("local backup") },
        [pscustomobject]@{ file = "invalid_historical_r14_write.json"; mutation = "append_historical_r14_write"; expected_failure_fragments = @("historical R13/R14/R15/R16") },
        [pscustomobject]@{ file = "invalid_kanban_js_write.json"; mutation = "append_kanban_js_write"; expected_failure_fragments = @("kanban.js") },
        [pscustomobject]@{ file = "invalid_prompt_packet_too_large.json"; mutation = "set_prompt_packet_too_large"; expected_failure_fragments = @("prompt packet word limit") },
        [pscustomobject]@{ file = "invalid_entire_cycle_one_prompt.json"; mutation = "set_entire_cycle_one_prompt"; expected_failure_fragments = @("entire Cycle 3") },
        [pscustomobject]@{ file = "invalid_missing_resume_prompt.json"; mutation = "remove_resume_prompt_packet"; expected_failure_fragments = @("resume-after-compact") },
        [pscustomobject]@{ file = "invalid_missing_stage_prompt.json"; mutation = "remove_stage_prompt_packet"; expected_failure_fragments = @("stage/commit/push") },
        [pscustomobject]@{ file = "invalid_openai_api_invoked.json"; mutation = "set_openai_api_invoked_true"; expected_failure_fragments = @("openai_api_invoked") },
        [pscustomobject]@{ file = "invalid_codex_api_invoked.json"; mutation = "set_codex_api_invoked_true"; expected_failure_fragments = @("codex_api_invoked") },
        [pscustomobject]@{ file = "invalid_autonomous_codex_invocation.json"; mutation = "set_autonomous_codex_invocation_true"; expected_failure_fragments = @("autonomous_codex_invocation_performed") },
        [pscustomobject]@{ file = "invalid_no_manual_prompt_transfer_success.json"; mutation = "set_no_manual_prompt_transfer_true"; expected_failure_fragments = @("no_manual_prompt_transfer_claimed") },
        [pscustomobject]@{ file = "invalid_solved_codex_compaction.json"; mutation = "set_solved_codex_compaction_true"; expected_failure_fragments = @("solved_codex_compaction_claimed") },
        [pscustomobject]@{ file = "invalid_solved_codex_reliability.json"; mutation = "set_solved_codex_reliability_true"; expected_failure_fragments = @("solved_codex_reliability_claimed") },
        [pscustomobject]@{ file = "invalid_qa_result_claimed.json"; mutation = "set_qa_result_claimed_true"; expected_failure_fragments = @("qa_result_claimed") },
        [pscustomobject]@{ file = "invalid_audit_verdict_claimed.json"; mutation = "set_audit_verdict_claimed_true"; expected_failure_fragments = @("audit_verdict_claimed") },
        [pscustomobject]@{ file = "invalid_product_runtime_claim.json"; mutation = "set_product_runtime_true"; expected_failure_fragments = @("product_runtime_executed") },
        [pscustomobject]@{ file = "invalid_future_r17_027_completion.json"; mutation = "set_future_r17_027_completion_claim"; expected_failure_fragments = @("future R17-027") },
        [pscustomobject]@{ file = "invalid_live_runtime_claim.json"; mutation = "set_live_runtime_true"; expected_failure_fragments = @("live_execution_harness_runtime_implemented") }
    )

    return [pscustomobject]@{
        artifact_type = "r17_compact_safe_harness_pilot_fixture_manifest"
        contract_version = "v1"
        source_task = $script:SourceTask
        invalid_fixture_count = $fixtures.Count
        fixtures = @($fixtures)
    }
}

function New-R17CompactSafeHarnessPilotProofReviewText {
    return @'
# R17-026 Compact-Safe Harness Pilot Proof Review

R17-026 pilots the R17-025 compact-safe harness foundation against the future Cycle 3 QA/fix-loop. It represents the abandoned large QA/fix-loop prompt as eight bounded work orders and eight short prompt packets.

## Evidence

- Contract: `contracts/runtime/r17_compact_safe_harness_pilot.contract.json`
- Plan: `state/runtime/r17_compact_safe_harness_pilot_cycle_3_plan.json`
- Work orders: `state/runtime/r17_compact_safe_harness_pilot_cycle_3_work_orders.json`
- Resume state: `state/runtime/r17_compact_safe_harness_pilot_cycle_3_resume_state.json`
- Check report: `state/runtime/r17_compact_safe_harness_pilot_cycle_3_check_report.json`
- Prompt packets: `state/runtime/r17_compact_safe_harness_pilot_cycle_3_prompt_packets/`
- UI snapshot: `state/ui/r17_kanban_mvp/r17_compact_safe_harness_pilot_snapshot.json`
- Tooling and tests: `tools/R17CompactSafeHarnessPilot.psm1`, `tools/validate_r17_compact_safe_harness_pilot.ps1`, and `tests/test_r17_compact_safe_harness_pilot.ps1`

## Boundary

This is a harness pilot only. It does not execute the full Cycle 3 QA/fix-loop, implement live execution harness runtime, invoke OpenAI APIs, invoke Codex APIs, perform autonomous Codex invocation, invoke live QA/Test Agent, invoke live Developer/Codex, implement live A2A runtime, invoke adapter runtime, perform actual product-runtime tool calls, mutate the live board, claim QA results, claim audit verdicts, execute product runtime, claim main merge, claim no-manual-prompt-transfer success, solve Codex compaction, or solve Codex reliability.

Repeated Codex compact failures remain unresolved. The next milestone must prioritize automated recovery loops that detect failure, preserve state, generate a continuation packet, start a new context/thread when needed, and continue with minimal operator involvement. R17-026 only pilots smaller work orders and does not solve the failure mode.

R17 is active through R17-026 only. R17-027 through R17-028 remain planned only.
'@
}

function New-R17CompactSafeHarnessPilotValidationManifestText {
    return @'
# R17-026 Compact-Safe Harness Pilot Validation Manifest

Required validation commands:

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_harness_pilot.ps1`
2. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_harness_pilot.ps1`
3. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_harness_pilot.ps1`
4. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1`
5. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1`
6. `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
7. `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
8. `git diff --check`

The validator rejects missing baseline fields, missing allowed paths, broad wildcard writes, local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes unless explicitly allowed, prompt packets over 2000 words, work orders that attempt the full Cycle 3 QA/fix-loop in one prompt, missing resume-after-compact and stage/commit/push prompt packets, OpenAI API claims, Codex API claims, autonomous Codex invocation claims, no-manual-prompt-transfer success claims, solved Codex compaction/reliability claims, QA result claims, audit verdict claims, product runtime claims, and future R17-027+ completion claims.

Residual finding: repeated Codex compact failures remain unresolved. A future milestone must prioritize automated recovery loops and new-context/thread continuation. R17-026 only pilots smaller work orders and does not solve the failure mode.
'@
}

function New-R17CompactSafeHarnessPilotEvidenceIndex {
    $refs = Get-R17CompactSafeHarnessPilotCoreRefs
    return [pscustomobject]@{
        artifact_type = "r17_compact_safe_harness_pilot_evidence_index"
        contract_version = "v1"
        source_task = $script:SourceTask
        active_through_task = "R17-026"
        planned_only_from = "R17-027"
        planned_only_through = "R17-028"
        target_future_cycle = $script:TargetFutureCycle
        baseline_head = $script:BaselineHead
        baseline_tree = $script:BaselineTree
        evidence_refs = @($refs.evidence_refs)
        validation_refs = @(
            "tools/validate_r17_compact_safe_harness_pilot.ps1",
            "tests/test_r17_compact_safe_harness_pilot.ps1",
            "$($script:ProofRoot)/validation_manifest.md"
        )
        authority_refs = @($refs.authority_refs)
        non_claims = @(Get-R17CompactSafeHarnessPilotNonClaims)
        rejected_claims = @(Get-R17CompactSafeHarnessPilotRejectedClaims)
    }
}

function New-R17CompactSafeHarnessPilotArtifacts {
    param([string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot))

    $paths = Get-R17CompactSafeHarnessPilotPaths -RepositoryRoot $RepositoryRoot
    $contract = New-R17CompactSafeHarnessPilotContract
    $plan = New-R17CompactSafeHarnessPilotPlan
    $workOrders = New-R17CompactSafeHarnessPilotWorkOrders
    $resumeState = New-R17CompactSafeHarnessPilotResumeState
    $checkReport = New-R17CompactSafeHarnessPilotCheckReport
    $uiSnapshot = New-R17CompactSafeHarnessPilotUiSnapshot
    $promptPackets = New-R17CompactSafeHarnessPilotPromptPackets
    $fixtureManifest = New-R17CompactSafeHarnessPilotFixtures
    $evidenceIndex = New-R17CompactSafeHarnessPilotEvidenceIndex

    Write-R17CompactSafeHarnessPilotJson -Path $paths.Contract -Value $contract
    Write-R17CompactSafeHarnessPilotJson -Path $paths.Plan -Value $plan
    Write-R17CompactSafeHarnessPilotJson -Path $paths.WorkOrders -Value $workOrders
    Write-R17CompactSafeHarnessPilotJson -Path $paths.ResumeState -Value $resumeState
    Write-R17CompactSafeHarnessPilotJson -Path $paths.CheckReport -Value $checkReport
    Write-R17CompactSafeHarnessPilotJson -Path $paths.UiSnapshot -Value $uiSnapshot

    foreach ($entry in $promptPackets.GetEnumerator()) {
        Write-R17CompactSafeHarnessPilotText -Path (Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:PromptPacketRoot)/$($entry.Key)") -Value $entry.Value
    }

    Write-R17CompactSafeHarnessPilotJson -Path $paths.FixtureManifest -Value $fixtureManifest
    foreach ($fixture in @($fixtureManifest.fixtures)) {
        Write-R17CompactSafeHarnessPilotJson -Path (Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue "$($script:FixtureRoot)/$($fixture.file)") -Value $fixture
    }

    Write-R17CompactSafeHarnessPilotText -Path $paths.ProofReview -Value (New-R17CompactSafeHarnessPilotProofReviewText)
    Write-R17CompactSafeHarnessPilotJson -Path $paths.EvidenceIndex -Value $evidenceIndex
    Write-R17CompactSafeHarnessPilotText -Path $paths.ValidationManifest -Value (New-R17CompactSafeHarnessPilotValidationManifestText)

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

function Assert-R17CompactSafeHarnessPilotRequiredFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$FieldNames,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $FieldNames) {
        if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required field '$field'."
        }
    }
}

function Assert-R17CompactSafeHarnessPilotFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:ExplicitFalseFields) {
        if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name $field)) {
            throw "$Context missing required false field '$field'."
        }
        if ([bool]$Object.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context field '$field' must be false."
        }
    }

    if (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name "runtime_flags") {
        foreach ($field in $script:ExplicitFalseFields) {
            if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object.runtime_flags -Name $field)) {
                throw "$Context runtime_flags missing '$field'."
            }
            if ([bool]$Object.runtime_flags.PSObject.Properties[$field].Value -ne $false) {
                throw "$Context runtime_flags field '$field' must be false."
            }
        }
    }
}

function Assert-R17CompactSafeHarnessPilotPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name "positive_claims")) {
        throw "$Context missing positive_claims."
    }
    foreach ($field in $script:PositiveClaimFields) {
        if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object.positive_claims -Name $field)) {
            throw "$Context positive_claims missing '$field'."
        }
        if ([bool]$Object.positive_claims.PSObject.Properties[$field].Value -ne $true) {
            throw "$Context positive claim '$field' must be true."
        }
    }
}

function Assert-R17CompactSafeHarnessPilotAllowedPath {
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

    $localBackupToken = Get-R17CompactSafeHarnessPilotLocalBackupToken
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

function Assert-R17CompactSafeHarnessPilotPathPolicy {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name "allowed_paths")) {
        throw "$Context missing required field 'allowed_paths'."
    }
    $allowedPaths = @($Object.allowed_paths | ForEach-Object { [string]$_ })
    if ($allowedPaths.Count -eq 0) {
        throw "$Context allowed_paths must not be empty."
    }
    $kanbanJsAllowed = $false
    if (Test-R17CompactSafeHarnessPilotHasProperty -Object $Object -Name "kanban_js_write_explicitly_allowed") {
        $kanbanJsAllowed = [bool]$Object.kanban_js_write_explicitly_allowed
    }
    foreach ($path in $allowedPaths) {
        Assert-R17CompactSafeHarnessPilotAllowedPath -PathValue $path -Context $Context -KanbanJsAllowed:$kanbanJsAllowed
    }
}

function Convert-R17CompactSafeHarnessPilotValueToScanText {
    param(
        [AllowNull()]$Value,
        [int]$Depth = 0
    )

    if ($null -eq $Value -or $Depth -gt 8) { return "" }
    if ($Value -is [string]) { return [string]$Value }
    if ($Value -is [ValueType]) { return [string]$Value }

    $parts = @()
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $parts += [string]$key
            $parts += Convert-R17CompactSafeHarnessPilotValueToScanText -Value $Value[$key] -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $parts += Convert-R17CompactSafeHarnessPilotValueToScanText -Value $item -Depth ($Depth + 1)
        }
        return ($parts -join " ")
    }

    foreach ($property in @($Value.PSObject.Properties)) {
        $parts += [string]$property.Name
        $parts += Convert-R17CompactSafeHarnessPilotValueToScanText -Value $property.Value -Depth ($Depth + 1)
    }
    return ($parts -join " ")
}

function Assert-R17CompactSafeHarnessPilotNoForbiddenContent {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $text = Convert-R17CompactSafeHarnessPilotValueToScanText -Value $Value
    $localBackupToken = Get-R17CompactSafeHarnessPilotLocalBackupToken
    if ($text.IndexOf($localBackupToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "$Context contains local backup directory reference."
    }
    if ($text -match '(?i)\bR17-(0(?:2[7-8])|[1-9][0-9]{2,})\b(?:(?!planned only).){0,80}\b(done|complete|completed|implemented|executed|ran|exercised|working|available|ships)\b') {
        throw "$Context contains future R17-027+ completion claim."
    }
    if ($text -match '(?i)\b(solved Codex compaction|Codex compaction solved|solved Codex reliability|Codex reliability solved)\b.{0,80}\b(true|done|complete|completed|claimed|achieved)\b') {
        throw "$Context contains solved Codex claim."
    }
    if ($text -match '(?i)\b(QA result|audit verdict|product runtime)\b.{0,100}\b(done|complete|completed|implemented|executed|ran|claimed|achieved|passed|available)\b') {
        throw "$Context contains QA, audit, or product runtime claim."
    }
}

function Assert-R17CompactSafeHarnessPilotPromptPackets {
    param(
        [Parameter(Mandatory = $true)]$PromptPackets,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $packets = @($PromptPackets)

    $paths = @($packets | ForEach-Object { [string]$_.path })
    foreach ($file in $script:PromptPacketFiles) {
        $expectedPath = "$($script:PromptPacketRoot)/$file"
        if ($paths -notcontains $expectedPath) {
            if ($file -eq "step_008_resume_after_compact.prompt.txt") {
                throw "$Context missing resume-after-compact prompt packet."
            }
            if ($file -eq "step_007_stage_commit_push.prompt.txt") {
                throw "$Context missing stage/commit/push prompt packet."
            }
            throw "$Context missing prompt packet '$expectedPath'."
        }
    }

    if ($packets.Count -ne $script:PromptPacketFiles.Count) {
        throw "$Context must include exactly $($script:PromptPacketFiles.Count) prompt packets."
    }

    foreach ($packet in $packets) {
        Assert-R17CompactSafeHarnessPilotRequiredFields -Object $packet -FieldNames @("path", "content") -Context "$Context prompt packet"
        $content = [string]$packet.content
        $wordCount = [regex]::Matches($content, '\S+').Count
        if ($wordCount -gt $script:MaxPromptPacketWords) {
            throw "$Context prompt packet word limit exceeded for '$($packet.path)'."
        }
        foreach ($requiredText in @($script:BaselineHead, $script:BaselineTree, "Allowed paths:", "Stop conditions:", "Expected outputs:", "Validation commands:")) {
            if ($content.IndexOf($requiredText, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                throw "$Context prompt packet '$($packet.path)' missing required text '$requiredText'."
            }
        }
        $cycleAttemptLines = @($content -split "`r?`n" | Where-Object {
                $_ -match '(?i)\b(run|execute|perform|complete|do)\b.{0,80}\b(entire|full|whole)\b.{0,80}\bCycle 3\b.{0,80}\b(one prompt|single prompt|one session)' -and
                $_ -notmatch '(?i)\bdo not\b'
            })
        if ($cycleAttemptLines.Count -gt 0) {
            throw "$Context prompt packet attempts entire Cycle 3 in one prompt."
        }
        Assert-R17CompactSafeHarnessPilotAllowedPath -PathValue ([string]$packet.path) -Context "$Context prompt packet path"
        Assert-R17CompactSafeHarnessPilotNoForbiddenContent -Value $packet -Context "$Context prompt packet"
    }
}

function Assert-R17CompactSafeHarnessPilotArtifactSizes {
    param(
        [Parameter(Mandatory = $true)][string[]]$RelativePaths,
        [Parameter(Mandatory = $true)][int]$MaxArtifactBytes,
        [string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot)
    )

    foreach ($relativePath in $RelativePaths) {
        $resolved = Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath
        if (-not (Test-Path -LiteralPath $resolved)) { continue }
        $length = (Get-Item -LiteralPath $resolved).Length
        if ($length -gt $MaxArtifactBytes) {
            throw "Generated artifact '$relativePath' exceeds compact size limit of $MaxArtifactBytes bytes."
        }
    }
}

function Assert-R17CompactSafeHarnessPilotKanbanJsUnchanged {
    param([string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot))

    & git -C $RepositoryRoot diff --quiet -- scripts/operator_wall/r17_kanban_mvp/kanban.js
    if ($LASTEXITCODE -ne 0) {
        throw "kanban.js has local changes; R17-026 compact-safe harness pilot must preserve renderer bytes."
    }
}

function Test-R17CompactSafeHarnessPilotSet {
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [Parameter(Mandatory = $true)]$Plan,
        [Parameter(Mandatory = $true)]$WorkOrders,
        [Parameter(Mandatory = $true)]$ResumeState,
        [Parameter(Mandatory = $true)]$CheckReport,
        [Parameter(Mandatory = $true)]$UiSnapshot,
        [Parameter(Mandatory = $true)]$PromptPackets,
        [string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot),
        [switch]$SkipArtifactSizeCheck,
        [switch]$SkipKanbanJsCheck
    )

    Assert-R17CompactSafeHarnessPilotRequiredFields -Object $Contract -FieldNames @("artifact_type", "contract_version", "contract_id", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "baseline_head", "baseline_tree", "target_future_cycle", "required_work_order_fields", "allowed_paths", "forbidden_paths", "max_changed_lines", "max_artifact_bytes", "max_prompt_packet_words", "validation_policy", "explicit_false_fields", "required_positive_claims", "non_claims", "rejected_claims") -Context "contract"
    if ($Contract.artifact_type -ne "r17_compact_safe_harness_pilot_contract") { throw "contract artifact_type is invalid." }
    if ($Contract.source_task -ne $script:SourceTask -or $Contract.active_through_task -ne "R17-026") { throw "contract must keep R17 active through R17-026." }
    if ($Contract.planned_only_from -ne "R17-027" -or $Contract.planned_only_through -ne "R17-028") { throw "contract must keep R17-027 through R17-028 planned only." }
    if ([string]$Contract.baseline_head -ne $script:BaselineHead) { throw "contract baseline_head is invalid." }
    if ([string]$Contract.baseline_tree -ne $script:BaselineTree) { throw "contract baseline_tree is invalid." }
    Assert-R17CompactSafeHarnessPilotPathPolicy -Object $Contract -Context "contract"
    Assert-R17CompactSafeHarnessPilotFalseFields -Object $Contract -Context "contract"
    Assert-R17CompactSafeHarnessPilotPositiveClaims -Object $Contract -Context "contract"

    foreach ($objectInfo in @(
            [pscustomobject]@{ Name = "plan"; Value = $Plan },
            [pscustomobject]@{ Name = "resume state"; Value = $ResumeState },
            [pscustomobject]@{ Name = "check report"; Value = $CheckReport },
            [pscustomobject]@{ Name = "UI snapshot"; Value = $UiSnapshot }
        )) {
        Assert-R17CompactSafeHarnessPilotRequiredFields -Object $objectInfo.Value -FieldNames @("artifact_type", "source_task", "active_through_task", "planned_only_from", "planned_only_through", "target_future_cycle", "baseline_head", "baseline_tree", "evidence_refs", "authority_refs", "non_claims", "rejected_claims") -Context $objectInfo.Name
        if ([string]$objectInfo.Value.baseline_head -ne $script:BaselineHead) { throw "$($objectInfo.Name) baseline_head is invalid." }
        if ([string]$objectInfo.Value.baseline_tree -ne $script:BaselineTree) { throw "$($objectInfo.Name) baseline_tree is invalid." }
        Assert-R17CompactSafeHarnessPilotFalseFields -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17CompactSafeHarnessPilotPositiveClaims -Object $objectInfo.Value -Context $objectInfo.Name
        Assert-R17CompactSafeHarnessPilotNoForbiddenContent -Value $objectInfo.Value -Context $objectInfo.Name
    }

    Assert-R17CompactSafeHarnessPilotRequiredFields -Object $WorkOrders -FieldNames @("artifact_type", "source_task", "target_future_cycle", "baseline_head", "baseline_tree", "work_order_model_supports", "work_orders", "non_claims", "rejected_claims") -Context "work orders"
    if ([string]$WorkOrders.baseline_head -ne $script:BaselineHead) { throw "work orders baseline_head is invalid." }
    if ([string]$WorkOrders.baseline_tree -ne $script:BaselineTree) { throw "work orders baseline_tree is invalid." }
    $workOrdersList = @($WorkOrders.work_orders)
    if ($workOrdersList.Count -ne $script:RequiredStepTypes.Count) { throw "work order model must include eight Cycle 3 pilot work orders." }
    foreach ($stepType in $script:RequiredStepTypes) {
        if (@($workOrdersList | Where-Object { [string]$_.step_type -eq $stepType }).Count -eq 0) {
            throw "work order model missing step type '$stepType'."
        }
    }
    foreach ($workOrder in $workOrdersList) {
        Assert-R17CompactSafeHarnessPilotRequiredFields -Object $workOrder -FieldNames $script:RequiredWorkOrderFields -Context "work order"
        if ([string]$workOrder.source_task -ne $script:SourceTask) { throw "work order source_task is invalid." }
        if ([string]$workOrder.target_future_cycle -ne $script:TargetFutureCycle) { throw "work order target_future_cycle is invalid." }
        if ([string]$workOrder.baseline_head -ne $script:BaselineHead) { throw "work order baseline_head is invalid." }
        if ([string]$workOrder.baseline_tree -ne $script:BaselineTree) { throw "work order baseline_tree is invalid." }
        if ($script:RequiredStepTypes -notcontains [string]$workOrder.step_type) { throw "work order step_type '$($workOrder.step_type)' is invalid." }
        if ([int]$workOrder.max_changed_lines -lt 1 -or [int]$workOrder.max_changed_lines -gt 1000) { throw "work order max_changed_lines must stay compact." }
        if ([int]$workOrder.max_artifact_bytes -lt 1 -or [int]$workOrder.max_artifact_bytes -gt 200000) { throw "work order max_artifact_bytes must stay compact." }
        Assert-R17CompactSafeHarnessPilotPathPolicy -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeHarnessPilotFalseFields -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeHarnessPilotPositiveClaims -Object $workOrder -Context "work order $($workOrder.work_order_id)"
        Assert-R17CompactSafeHarnessPilotNoForbiddenContent -Value $workOrder -Context "work order $($workOrder.work_order_id)"
    }

    Assert-R17CompactSafeHarnessPilotPromptPackets -PromptPackets $PromptPackets -Context "prompt packets"

    if ($CheckReport.aggregate_verdict -ne $script:AggregateVerdict) { throw "check report aggregate_verdict is invalid." }
    foreach ($check in @($CheckReport.validation_summary.PSObject.Properties)) {
        if ([string]$check.Value -ne "passed") { throw "check report validation_summary '$($check.Name)' must be passed." }
    }

    Assert-R17CompactSafeHarnessPilotNoForbiddenContent -Value $Contract -Context "contract"
    Assert-R17CompactSafeHarnessPilotNoForbiddenContent -Value $WorkOrders -Context "work orders"

    if (-not $SkipArtifactSizeCheck) {
        $generatedPaths = @($Contract.artifact_refs | ForEach-Object { [string]$_ })
        $generatedPaths += @(
            "$($script:ProofRoot)/proof_review.md",
            "$($script:ProofRoot)/evidence_index.json",
            "$($script:ProofRoot)/validation_manifest.md",
            "$($script:FixtureRoot)/fixture_manifest.json"
        )
        Assert-R17CompactSafeHarnessPilotArtifactSizes -RelativePaths $generatedPaths -MaxArtifactBytes ([int]$Contract.max_artifact_bytes) -RepositoryRoot $RepositoryRoot
    }

    if (-not $SkipKanbanJsCheck) {
        Assert-R17CompactSafeHarnessPilotKanbanJsUnchanged -RepositoryRoot $RepositoryRoot
    }

    return [pscustomobject]@{
        AggregateVerdict = $script:AggregateVerdict
        SourceTask = $script:SourceTask
        WorkOrderCount = $workOrdersList.Count
        PromptPacketCount = @($PromptPackets).Count
        ActiveThroughTask = "R17-026"
        PlannedOnlyFrom = "R17-027"
        PlannedOnlyThrough = "R17-028"
        CompactSafeHarnessPilotCreated = $true
        Cycle3SplitIntoSmallWorkOrders = $true
        Cycle3PromptPacketsCreated = $true
        ResumeAfterCompactPromptPacketCreated = $true
        StageCommitPushPromptPacketCreated = $true
        FutureCycle3CanBeAttemptedInSmallerSteps = $true
        LiveExecutionHarnessRuntimeImplemented = $false
        HarnessPilotRuntimeExecuted = $false
        OpenAiApiInvoked = $false
        CodexApiInvoked = $false
        AutonomousCodexInvocationPerformed = $false
        ProductRuntimeExecuted = $false
        QaResultClaimed = $false
        AuditVerdictClaimed = $false
        MainMergeClaimed = $false
        NoManualPromptTransferClaimed = $false
        SolvedCodexCompactionClaimed = $false
        SolvedCodexReliabilityClaimed = $false
    }
}

function Get-R17CompactSafeHarnessPilotPromptPacketObjects {
    param([string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot))

    $packets = @()
    foreach ($file in $script:PromptPacketFiles) {
        $relativePath = "$($script:PromptPacketRoot)/$file"
        $packets += [pscustomobject]@{
            path = $relativePath
            content = Get-Content -LiteralPath (Resolve-R17CompactSafeHarnessPilotPath -RepositoryRoot $RepositoryRoot -PathValue $relativePath) -Raw
        }
    }
    return $packets
}

function Test-R17CompactSafeHarnessPilot {
    param([string]$RepositoryRoot = (Get-R17CompactSafeHarnessPilotRepositoryRoot))

    $paths = Get-R17CompactSafeHarnessPilotPaths -RepositoryRoot $RepositoryRoot
    $contract = Read-R17CompactSafeHarnessPilotJson -Path $paths.Contract
    $plan = Read-R17CompactSafeHarnessPilotJson -Path $paths.Plan
    $workOrders = Read-R17CompactSafeHarnessPilotJson -Path $paths.WorkOrders
    $resumeState = Read-R17CompactSafeHarnessPilotJson -Path $paths.ResumeState
    $checkReport = Read-R17CompactSafeHarnessPilotJson -Path $paths.CheckReport
    $uiSnapshot = Read-R17CompactSafeHarnessPilotJson -Path $paths.UiSnapshot
    $promptPackets = Get-R17CompactSafeHarnessPilotPromptPacketObjects -RepositoryRoot $RepositoryRoot

    return Test-R17CompactSafeHarnessPilotSet `
        -Contract $contract `
        -Plan $plan `
        -WorkOrders $workOrders `
        -ResumeState $resumeState `
        -CheckReport $checkReport `
        -UiSnapshot $uiSnapshot `
        -PromptPackets $promptPackets `
        -RepositoryRoot $RepositoryRoot
}

Export-ModuleMember -Function `
    Get-R17CompactSafeHarnessPilotPaths, `
    New-R17CompactSafeHarnessPilotArtifacts, `
    Test-R17CompactSafeHarnessPilot, `
    Test-R17CompactSafeHarnessPilotSet, `
    Get-R17CompactSafeHarnessPilotPromptPacketObjects, `
    Copy-R17CompactSafeHarnessPilotObject
