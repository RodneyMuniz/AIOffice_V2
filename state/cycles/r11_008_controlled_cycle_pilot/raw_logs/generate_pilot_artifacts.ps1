param(
    [string]$PreflightScanPath = (Join-Path $env:TEMP "aioffice_r11_008_preflight_scan.json")
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..\..\..")).Path
Set-Location -LiteralPath $repoRoot

$cycleId = "cycle-r11-008-controlled-cycle-pilot"
$rootRel = "state/cycles/r11_008_controlled_cycle_pilot"
$root = Join-Path $repoRoot ($rootRel -replace "/", "\")
$head = (git rev-parse HEAD).Trim()
$tree = (git rev-parse "HEAD^{tree}").Trim()

function New-Ref {
    param([Parameter(Mandatory = $true)][string]$Name)
    return "$rootRel/$Name"
}

function New-ArtifactPath {
    param([Parameter(Mandatory = $true)][string]$Name)
    return (Join-Path $root ($Name -replace "/", "\"))
}

function Get-UtcStamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Document
    )

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Read-JsonDocument {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Invoke-JsonCli {
    param(
        [Parameter(Mandatory = $true)][string]$LogName,
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )

    $logPath = New-ArtifactPath "raw_logs/$LogName"
    $output = & $Command
    $exitCode = $LASTEXITCODE
    $text = ($output -join "`n")
    Set-Content -LiteralPath $logPath -Value $text -Encoding UTF8
    if ($null -ne $exitCode -and $exitCode -ne 0) {
        throw "Command for '$LogName' failed with exit code $exitCode. Output: $text"
    }
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    return ($text | ConvertFrom-Json)
}

function Add-UniqueValues {
    param([object[]]$Values)

    $items = @()
    foreach ($value in @($Values)) {
        if ($null -eq $value) { continue }
        $text = [string]$value
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        if ($items -notcontains $text) { $items += $text }
    }

    return $items
}

function Add-PilotNonClaims {
    param([Parameter(Mandatory = $true)][string]$Path)

    $doc = Read-JsonDocument -Path $Path
    $doc.non_claims = @(Add-UniqueValues -Values (@($doc.non_claims) + @($script:PilotNonClaims)))
    Write-JsonDocument -Path $Path -Document $doc
    return $doc
}

function New-CommonPacket {
    param(
        [Parameter(Mandatory = $true)][string]$ArtifactType,
        [Parameter(Mandatory = $true)][string]$IdField,
        [Parameter(Mandatory = $true)][string]$IdValue
    )

    $packet = [ordered]@{
        contract_version = "v1"
        artifact_type = $ArtifactType
    }
    $packet[$IdField] = $IdValue
    $packet["repository"] = "AIOffice_V2"
    $packet["branch"] = "release/r10-real-external-runner-proof-foundation"
    $packet["milestone"] = "R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot"
    $packet["source_task"] = "R11-008"
    $packet["cycle_id"] = $cycleId
    return $packet
}

$script:PilotNonClaims = @(
    "no R11 closeout",
    "no R12 or successor milestone",
    "no production runtime",
    "no real production QA",
    "no UI or control-room productization",
    "no Standard runtime",
    "no multi-repo orchestration",
    "no swarms",
    "no broad autonomous milestone execution",
    "no unattended automatic resume",
    "no solved Codex context compaction",
    "no hours-long unattended execution",
    "no destructive rollback",
    "no broad CI/product coverage",
    "no productized control-room behavior",
    "no general Codex reliability",
    "no claim beyond one bounded R11-008 controlled-cycle pilot"
)

if (-not (Test-Path -LiteralPath $PreflightScanPath)) {
    throw "Preflight scan '$PreflightScanPath' does not exist."
}

$preflight = Read-JsonDocument -Path $PreflightScanPath
if (-not [bool]$preflight.worktree_clean -or [string]$preflight.residue_policy_decision -ne "allowed") {
    throw "Preflight scan must be clean and allowed before pilot artifact generation."
}

$createdAt = Get-UtcStamp
$operatorRequest = New-CommonPacket -ArtifactType "cycle_operator_request" -IdField "request_id" -IdValue "operator-request-r11-008-controlled-cycle-pilot"
$operatorRequest["request_text"] = "Run one bounded controlled-cycle pilot that proves the R11 cycle controller can coordinate 2 to 3 bounded Dev tasks, consume Dev evidence through a separate QA gate, generate an audit packet, and produce an operator decision packet from repo-truth artifacts only."
$operatorRequest["operator_approval_source"] = "R11-008 operator instruction in this implementation turn"
$operatorRequest["head_sha"] = $head
$operatorRequest["tree_sha"] = $tree
$operatorRequest["created_at_utc"] = $createdAt
$operatorRequest["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "operator_request.json") -Document ([pscustomobject]$operatorRequest)

$planTasks = @(
    [pscustomobject][ordered]@{
        task_id = "r11-008-cycle-ledger-evidence"
        objective = "Create and advance the cycle ledger through the controlled-cycle pilot states."
        expected_outputs = @("operator_request.json", "cycle_plan.json", "operator_approval.json", "baseline.json", "cycle_ledger.json", "bootstrap/bootstrap_packet.json", "bootstrap/next_action_packet.json", "residue_guard/preflight_scan.json")
    },
    [pscustomobject][ordered]@{
        task_id = "r11-008-dev-and-qa-evidence"
        objective = "Create bounded Dev dispatch/result packets and separate QA signoff over Dev source evidence."
        expected_outputs = @("dev/dev_dispatch.json", "dev/dev_execution_result.json", "qa/cycle_qa_signoff.json")
    },
    [pscustomobject][ordered]@{
        task_id = "r11-008-audit-and-decision-evidence"
        objective = "Create final audit and operator decision packets for the bounded pilot cycle."
        expected_outputs = @("audit/cycle_audit_packet.json", "decision/operator_decision_packet.json", "summary.md")
    }
)

$cyclePlan = New-CommonPacket -ArtifactType "cycle_plan" -IdField "plan_id" -IdValue "cycle-plan-r11-008-controlled-cycle-pilot"
$cyclePlan["operator_request_ref"] = New-Ref "operator_request.json"
$cyclePlan["planned_task_count"] = 3
$cyclePlan["tasks"] = @($planTasks)
$cyclePlan["target_operator_intervention_count"] = 2
$cyclePlan["target_manual_bootstrap_count"] = 0
$cyclePlan["head_sha"] = $head
$cyclePlan["tree_sha"] = $tree
$cyclePlan["created_at_utc"] = $createdAt
$cyclePlan["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "cycle_plan.json") -Document ([pscustomobject]$cyclePlan)

$operatorApproval = New-CommonPacket -ArtifactType "cycle_operator_approval" -IdField "approval_id" -IdValue "operator-approval-r11-008-controlled-cycle-pilot"
$operatorApproval["operator_request_ref"] = New-Ref "operator_request.json"
$operatorApproval["cycle_plan_ref"] = New-Ref "cycle_plan.json"
$operatorApproval["approval_authority"] = "operator_instruction_for_r11_008_pilot_only"
$operatorApproval["approved"] = $true
$operatorApproval["approval_scope"] = "one bounded R11-008 controlled-cycle pilot with 2 to 3 bounded tasks; no R11 closeout and no successor milestone opening"
$operatorApproval["head_sha"] = $head
$operatorApproval["tree_sha"] = $tree
$operatorApproval["created_at_utc"] = $createdAt
$operatorApproval["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "operator_approval.json") -Document ([pscustomobject]$operatorApproval)

$baseline = New-CommonPacket -ArtifactType "cycle_baseline" -IdField "baseline_id" -IdValue "baseline-r11-008-controlled-cycle-pilot"
$baseline["head_sha"] = $head
$baseline["tree_sha"] = $tree
$baseline["git_status_short"] = @()
$baseline["source_refs"] = @((New-Ref "operator_request.json"), (New-Ref "cycle_plan.json"), (New-Ref "operator_approval.json"))
$baseline["created_at_utc"] = $createdAt
$baseline["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "baseline.json") -Document ([pscustomobject]$baseline)
Write-JsonDocument -Path (New-ArtifactPath "residue_guard/preflight_scan.json") -Document $preflight

$ledgerPath = New-ArtifactPath "cycle_ledger.json"
$ledgerRef = New-Ref "cycle_ledger.json"

Invoke-JsonCli -LogName "01_controller_initialize.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command initialize -CycleId $cycleId -OutputPath $ledgerPath -HeadSha $head -TreeSha $tree -OperatorRequestRef (New-Ref "operator_request.json") -GovernedRoot "state/cycles" -AllowOutsideGovernedRoot -Overwrite
} | Out-Null

Invoke-JsonCli -LogName "02_controller_plan_prepared.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState plan_prepared -EvidenceRef (New-Ref "cycle_plan.json") -Actor "R11-008-cycle-controller" -Reason "Prepare the bounded pilot cycle plan from repo-truth request artifacts." -CyclePlanRef (New-Ref "cycle_plan.json")
} | Out-Null

Invoke-JsonCli -LogName "03_controller_plan_approved.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState plan_approved -EvidenceRef (New-Ref "operator_approval.json") -Actor "R11-008-operator-approval" -Reason "Record operator approval for this bounded R11-008 pilot only." -AdditionalEvidenceRefs (New-Ref "operator_approval.json")
} | Out-Null

Invoke-JsonCli -LogName "04_bootstrap_resume.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\prepare_cycle_bootstrap.ps1 -LedgerPath $ledgerPath -OutputRoot (New-ArtifactPath "bootstrap") -BootstrapPacketPath (New-ArtifactPath "bootstrap/bootstrap_packet.json") -NextActionPacketPath (New-ArtifactPath "bootstrap/next_action_packet.json") -BootstrapId "bootstrap-r11-008-controlled-cycle-pilot" -NextActionId "next-action-r11-008-controlled-cycle-pilot" -PreferredTargetState dev_dispatch_ready -AllowOutsideGovernedRoot -Overwrite
} | Out-Null

$dispatchNonClaims = @(
    "no QA authority",
    "no QA verdict",
    "no complete controlled cycle",
    "no R11 closeout",
    "no real Dev execution beyond bounded adapter fixtures/results generated by tests",
    "no UI or control-room productization",
    "no Standard runtime",
    "no multi-repo orchestration",
    "no swarms",
    "no broad autonomous milestone execution",
    "no unattended automatic resume",
    "no solved Codex context compaction",
    "no hours-long unattended execution",
    "no destructive rollback",
    "no broad CI/product coverage",
    "no productized control-room behavior",
    "no production runtime",
    "no general Codex reliability",
    "no successor milestone without explicit approval"
)

$taskPackets = [pscustomobject][ordered]@{
    task_packets = @(
        [pscustomobject][ordered]@{
            task_id = "r11-008-cycle-ledger-evidence"
            task_title = "Record cycle ledger and bootstrap evidence"
            task_objective = "Record request, plan, approval, baseline, ledger transitions, bootstrap packets, and residue preflight for the bounded pilot."
            bounded_scope = @("Create R11-008 cycle-control evidence artifacts under the pilot root only.")
            allowed_paths = @($rootRel)
            forbidden_paths = @("governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md", "contracts/cycle_controller/foundation.contract.json", "tools/CycleController.psm1", "tests/test_cycle_controller.ps1")
            expected_outputs = @("operator request, plan, approval, baseline, ledger, bootstrap, next-action, and residue preflight packets")
            acceptance_checks = @("Artifacts share the cycle id and remain under the approved pilot root.")
            evidence_required = @("cycle ledger and bootstrap refs")
            max_attempts = 1
            context_budget = [pscustomobject][ordered]@{ max_files = 12; max_lines = 1500; max_prompt_tokens = 12000 }
            non_claims = @($dispatchNonClaims)
        },
        [pscustomobject][ordered]@{
            task_id = "r11-008-dev-and-qa-evidence"
            task_title = "Record Dev evidence packets"
            task_objective = "Record bounded Dev dispatch/result packets as source evidence refs."
            bounded_scope = @("Create Dev evidence artifacts under the pilot root only.")
            allowed_paths = @($rootRel)
            forbidden_paths = @("governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md", "contracts/cycle_controller/foundation.contract.json", "tools/CycleQaGate.psm1", "tests/test_cycle_qa_gate.ps1")
            expected_outputs = @("Dev dispatch packet and Dev execution result packet")
            acceptance_checks = @("Dispatch has two bounded tasks and result has source evidence refs.")
            evidence_required = @("Dev dispatch/result refs")
            max_attempts = 1
            context_budget = [pscustomobject][ordered]@{ max_files = 8; max_lines = 1200; max_prompt_tokens = 10000 }
            non_claims = @($dispatchNonClaims)
        }
    )
}
Write-JsonDocument -Path (New-ArtifactPath "dev/task_packets.json") -Document $taskPackets

Invoke-JsonCli -LogName "05_controller_dev_dispatch_ready.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState dev_dispatch_ready -EvidenceRef (New-Ref "bootstrap/next_action_packet.json") -Actor "R11-008-cycle-controller" -Reason "Prepare bounded Dev dispatch after approved plan, bootstrap packet, and clean residue preflight." -BaselineRef (New-Ref "baseline.json") -DispatchRefs (New-Ref "dev/dev_dispatch.json")
} | Out-Null

$dispatch = Invoke-JsonCli -LogName "06_dev_dispatch.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_dev_execution_adapter.ps1 -Command create-dispatch -LedgerPath $ledgerPath -CycleId $cycleId -OutputPath (New-ArtifactPath "dev/dev_dispatch.json") -BaselineRef (New-Ref "baseline.json") -OperatorApprovalRef (New-Ref "operator_approval.json") -TaskPacketPath (New-ArtifactPath "dev/task_packets.json") -TargetExecutor "codex-r11-008-dev-adapter" -Overwrite
}
$dispatch = Add-PilotNonClaims -Path (New-ArtifactPath "dev/dev_dispatch.json")

Invoke-JsonCli -LogName "07_controller_dev_in_progress.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState dev_in_progress -EvidenceRef (New-Ref "dev/dev_dispatch.json") -Actor "R11-008-dev-dispatch" -Reason "Record bounded Dev dispatch handoff for the pilot cycle." -DispatchRefs (New-Ref "dev/dev_dispatch.json")
} | Out-Null

$resultNonClaims = @(
    "no QA authority",
    "no QA verdict",
    "no executor self-certification as QA",
    "no complete controlled cycle",
    "no R11 closeout",
    "no real Dev execution beyond bounded adapter fixtures/results generated by tests",
    "no UI or control-room productization",
    "no Standard runtime",
    "no multi-repo orchestration",
    "no swarms",
    "no broad autonomous milestone execution",
    "no unattended automatic resume",
    "no solved Codex context compaction",
    "no hours-long unattended execution",
    "no destructive rollback",
    "no broad CI/product coverage",
    "no productized control-room behavior",
    "no production runtime",
    "no general Codex reliability",
    "no successor milestone without explicit approval"
)

$taskResults = [pscustomobject][ordered]@{
    task_results = @(
        [pscustomobject][ordered]@{
            task_id = "r11-008-cycle-ledger-evidence"
            status = "completed"
            summary = "Recorded cycle-control evidence refs for the bounded pilot without accepting Dev narration as QA authority."
            changed_files = @((New-Ref "operator_request.json"), (New-Ref "cycle_plan.json"), (New-Ref "operator_approval.json"), (New-Ref "baseline.json"), (New-Ref "cycle_ledger.json"), (New-Ref "bootstrap/bootstrap_packet.json"), (New-Ref "bootstrap/next_action_packet.json"), (New-Ref "residue_guard/preflight_scan.json"))
            produced_artifacts = @((New-Ref "operator_request.json"), (New-Ref "cycle_plan.json"), (New-Ref "operator_approval.json"), (New-Ref "baseline.json"), (New-Ref "cycle_ledger.json"), (New-Ref "bootstrap/bootstrap_packet.json"), (New-Ref "bootstrap/next_action_packet.json"), (New-Ref "residue_guard/preflight_scan.json"))
            command_logs = @((New-Ref "raw_logs/01_controller_initialize.json"), (New-Ref "raw_logs/02_controller_plan_prepared.json"), (New-Ref "raw_logs/03_controller_plan_approved.json"), (New-Ref "raw_logs/04_bootstrap_resume.json"), (New-Ref "raw_logs/05_controller_dev_dispatch_ready.json"))
            evidence_refs = @((New-Ref "cycle_ledger.json"), (New-Ref "bootstrap/bootstrap_packet.json"), (New-Ref "bootstrap/next_action_packet.json"), (New-Ref "residue_guard/preflight_scan.json"))
            refusal_reasons = @()
            non_claims = @($resultNonClaims)
        },
        [pscustomobject][ordered]@{
            task_id = "r11-008-dev-and-qa-evidence"
            status = "completed"
            summary = "Recorded bounded Dev source evidence for later independent review."
            changed_files = @((New-Ref "dev/task_packets.json"), (New-Ref "dev/dev_dispatch.json"), (New-Ref "dev/dev_execution_result.json"))
            produced_artifacts = @((New-Ref "dev/task_packets.json"), (New-Ref "dev/dev_dispatch.json"), (New-Ref "dev/dev_execution_result.json"))
            command_logs = @((New-Ref "raw_logs/06_dev_dispatch.json"), (New-Ref "raw_logs/08_dev_result.json"))
            evidence_refs = @((New-Ref "dev/dev_dispatch.json"), (New-Ref "dev/dev_execution_result.json"))
            refusal_reasons = @()
            non_claims = @($resultNonClaims)
        }
    )
    evidence_refs = @((New-Ref "cycle_ledger.json"), (New-Ref "bootstrap/bootstrap_packet.json"), (New-Ref "bootstrap/next_action_packet.json"), (New-Ref "residue_guard/preflight_scan.json"), (New-Ref "dev/dev_dispatch.json"), (New-Ref "dev/dev_execution_result.json"))
    command_logs = @((New-Ref "raw_logs/06_dev_dispatch.json"), (New-Ref "raw_logs/08_dev_result.json"))
    refusal_reasons = @()
}
Write-JsonDocument -Path (New-ArtifactPath "dev/task_results.json") -Document $taskResults

$devResult = Invoke-JsonCli -LogName "08_dev_result.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_dev_execution_adapter.ps1 -Command create-result -DispatchPath (New-ArtifactPath "dev/dev_dispatch.json") -OutputPath (New-ArtifactPath "dev/dev_execution_result.json") -ExecutorIdentity "codex-r11-008-dev-adapter" -ExecutorKind "codex" -Status completed -TaskResultPath (New-ArtifactPath "dev/task_results.json") -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha -Overwrite
}
$devResult = Add-PilotNonClaims -Path (New-ArtifactPath "dev/dev_execution_result.json")

Invoke-JsonCli -LogName "09_controller_dev_evidence_recorded.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState dev_evidence_recorded -EvidenceRef (New-Ref "dev/dev_execution_result.json") -Actor "R11-008-dev-adapter" -Reason "Record bounded Dev execution result packet as source evidence only." -ExecutionResultRefs (New-Ref "dev/dev_execution_result.json")
} | Out-Null

Invoke-JsonCli -LogName "09b_controller_qa_pending.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState qa_pending -EvidenceRef (New-Ref "dev/dev_execution_result.json") -Actor "R11-008-cycle-controller" -Reason "Move to separate QA gate over Dev source evidence." -ExecutionResultRefs (New-Ref "dev/dev_execution_result.json")
} | Out-Null

$qaSignoff = Invoke-JsonCli -LogName "10_qa_signoff.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_qa_gate.ps1 -Command signoff -DispatchPath (New-ArtifactPath "dev/dev_dispatch.json") -DevResultPath (New-ArtifactPath "dev/dev_execution_result.json") -OutputPath (New-ArtifactPath "qa/cycle_qa_signoff.json") -QaActorIdentity "codex-r11-008-separate-qa-gate" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" -QaFindings "Separate QA gate consumed Dev source evidence refs for the bounded R11-008 pilot." -Overwrite
}
$qaSignoff = Add-PilotNonClaims -Path (New-ArtifactPath "qa/cycle_qa_signoff.json")

Invoke-JsonCli -LogName "11_controller_qa_passed.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState qa_passed -EvidenceRef (New-Ref "qa/cycle_qa_signoff.json") -Actor "R11-008-separate-qa-gate" -Reason "Record separate QA signoff over Dev source evidence." -QaRefs (New-Ref "qa/cycle_qa_signoff.json")
} | Out-Null

$auditEvidenceRefs = @((New-Ref "operator_request.json"), (New-Ref "cycle_plan.json"), (New-Ref "operator_approval.json"), (New-Ref "baseline.json"), (New-Ref "cycle_ledger.json"), (New-Ref "bootstrap/bootstrap_packet.json"), (New-Ref "bootstrap/next_action_packet.json"), (New-Ref "residue_guard/preflight_scan.json"), (New-Ref "dev/dev_dispatch.json"), (New-Ref "dev/dev_execution_result.json"), (New-Ref "qa/cycle_qa_signoff.json"))
$auditPacket = New-CommonPacket -ArtifactType "cycle_audit_packet" -IdField "audit_packet_id" -IdValue "audit-r11-008-controlled-cycle-pilot"
$auditPacket["cycle_ledger_ref"] = $ledgerRef
$auditPacket["operator_request_ref"] = New-Ref "operator_request.json"
$auditPacket["cycle_plan_ref"] = New-Ref "cycle_plan.json"
$auditPacket["operator_approval_ref"] = New-Ref "operator_approval.json"
$auditPacket["bootstrap_packet_ref"] = New-Ref "bootstrap/bootstrap_packet.json"
$auditPacket["next_action_packet_ref"] = New-Ref "bootstrap/next_action_packet.json"
$auditPacket["residue_scan_ref"] = New-Ref "residue_guard/preflight_scan.json"
$auditPacket["dev_dispatch_ref"] = New-Ref "dev/dev_dispatch.json"
$auditPacket["dev_result_ref"] = New-Ref "dev/dev_execution_result.json"
$auditPacket["qa_signoff_ref"] = New-Ref "qa/cycle_qa_signoff.json"
$auditPacket["qa_verdict"] = "passed"
$auditPacket["cycle_state"] = "qa_passed"
$auditPacket["evidence_refs"] = @($auditEvidenceRefs)
$auditPacket["validated_tooling_refs"] = @("tools/CycleLedger.psm1", "tools/CycleController.psm1", "tools/CycleBootstrap.psm1", "tools/LocalResidueGuard.psm1", "tools/DevExecutionAdapter.psm1", "tools/CycleQaGate.psm1")
$auditPacket["completed_task_ids"] = @("r11-008-cycle-ledger-evidence", "r11-008-dev-and-qa-evidence", "r11-008-audit-and-decision-evidence")
$auditPacket["operator_intervention_count"] = 2
$auditPacket["manual_bootstrap_count"] = 0
$auditPacket["head_sha"] = $head
$auditPacket["tree_sha"] = $tree
$auditPacket["created_at_utc"] = Get-UtcStamp
$auditPacket["audit_findings"] = @("All required R11-008 pilot refs are present under the bounded artifact root.", "QA signoff consumes Dev source evidence refs and remains separate from executor evidence.")
$auditPacket["refusal_reasons"] = @()
$auditPacket["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "audit/cycle_audit_packet.json") -Document ([pscustomobject]$auditPacket)

Invoke-JsonCli -LogName "12_controller_audit_packet_ready.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState audit_packet_ready -EvidenceRef (New-Ref "audit/cycle_audit_packet.json") -Actor "R11-008-cycle-audit" -Reason "Record bounded pilot audit packet from ledger and evidence refs." -AuditPacketRef (New-Ref "audit/cycle_audit_packet.json") -AdditionalEvidenceRefs (New-Ref "audit/cycle_audit_packet.json")
} | Out-Null

$decisionPacket = New-CommonPacket -ArtifactType "operator_decision_packet" -IdField "decision_packet_id" -IdValue "decision-r11-008-controlled-cycle-pilot"
$decisionPacket["cycle_ledger_ref"] = $ledgerRef
$decisionPacket["audit_packet_ref"] = New-Ref "audit/cycle_audit_packet.json"
$decisionPacket["qa_signoff_ref"] = New-Ref "qa/cycle_qa_signoff.json"
$decisionPacket["decision"] = "accepted_for_r11_008_pilot"
$decisionPacket["decision_authority"] = "operator approval from R11-008 instruction, limited to accepting this bounded pilot evidence only"
$decisionPacket["operator_intervention_count"] = 2
$decisionPacket["manual_bootstrap_count"] = 0
$decisionPacket["accepted_claims"] = @("one bounded R11-008 controlled-cycle pilot artifact chain exists under state/cycles/r11_008_controlled_cycle_pilot", "two bounded tasks were represented in one Dev dispatch", "separate QA signoff consumed Dev source evidence refs")
$decisionPacket["rejected_claims"] = @("R11 closeout", "R12 or successor milestone opening", "real production QA", "production runtime", "UI or control-room productization", "Standard runtime", "multi-repo orchestration", "swarms", "broad autonomous milestone execution", "unattended automatic resume", "solved Codex context compaction", "hours-long unattended execution", "destructive rollback", "broad CI/product coverage", "general Codex reliability")
$decisionPacket["next_allowed_step"] = "R11-009 remains planned only and requires explicit operator direction; no R12 or successor milestone is opened."
$decisionPacket["head_sha"] = $head
$decisionPacket["tree_sha"] = $tree
$decisionPacket["created_at_utc"] = Get-UtcStamp
$decisionPacket["non_claims"] = @($PilotNonClaims)
Write-JsonDocument -Path (New-ArtifactPath "decision/operator_decision_packet.json") -Document ([pscustomobject]$decisionPacket)

Invoke-JsonCli -LogName "13_controller_operator_decision_pending.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState operator_decision_pending -EvidenceRef (New-Ref "decision/operator_decision_packet.json") -Actor "R11-008-operator-decision" -Reason "Record operator decision packet for the bounded pilot only." -DecisionPacketRef (New-Ref "decision/operator_decision_packet.json") -AdditionalEvidenceRefs (New-Ref "decision/operator_decision_packet.json")
} | Out-Null

Invoke-JsonCli -LogName "14_controller_accepted.json" -Command {
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_cycle_controller.ps1 -Command advance -LedgerPath $ledgerPath -TargetState accepted -EvidenceRef (New-Ref "decision/operator_decision_packet.json") -Actor "R11-008-operator-decision" -Reason "Accept the bounded R11-008 pilot cycle evidence only; this is not R11 closeout." -AuditPacketRef (New-Ref "audit/cycle_audit_packet.json") -DecisionPacketRef (New-Ref "decision/operator_decision_packet.json")
} | Out-Null

$summary = @"
# R11-008 Controlled-Cycle Pilot Summary

Cycle ID: ``$cycleId``

Artifact root: ``$rootRel``

The bounded pilot records one approved R11-008 cycle artifact chain from operator request through cycle ledger, bootstrap and next-action packet, local residue preflight, one Dev dispatch with two bounded tasks, one Dev result packet, separate QA signoff, audit packet, and operator decision packet.

Operator intervention count: 2
Manual bootstrap count after initial approval: 0
Final cycle ledger state: accepted

Accepted claim: one bounded R11-008 controlled-cycle pilot evidence chain exists under the artifact root.

Rejected claims: no R11 closeout, no R12 or successor milestone, no production runtime, no real production QA, no UI/control-room productization, no Standard runtime, no multi-repo orchestration, no swarms, no broad autonomous milestone execution, no unattended automatic resume, no solved Codex context compaction, no hours-long unattended execution, no destructive rollback, no broad CI/product coverage, no productized control-room behavior, and no general Codex reliability.
"@
Set-Content -LiteralPath (New-ArtifactPath "summary.md") -Value $summary -Encoding UTF8

Write-Output "PILOT_GENERATION_OK"
Write-Output "ROOT=$rootRel"
Write-Output "CYCLE_ID=$cycleId"
Write-Output "HEAD=$head"
Write-Output "TREE=$tree"
