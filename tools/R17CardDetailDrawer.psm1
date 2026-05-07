Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:ActiveThroughTask = "R17-007"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:UiRoot = "scripts/operator_wall/r17_kanban_mvp"
$script:SnapshotPath = "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json"
$script:KanbanSnapshotPath = "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json"
$script:BoardStatePath = "$($script:BoardRoot)/r17_board_state.json"
$script:SeedCardPath = "$($script:BoardRoot)/cards/r17_005_seed_card.json"
$script:SeedEventsPath = "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
$script:ReplayReportPath = "$($script:BoardRoot)/r17_board_replay_report.json"
$script:R17BoardContractsProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/"
$script:R17BoardStateStoreProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/"
$script:R17KanbanMvpProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_006_kanban_mvp/"
$script:R17CardDetailProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_007_card_detail_evidence_drawer/"

$script:RequiredEvidenceRefs = @(
    $script:BoardStatePath,
    $script:SeedCardPath,
    $script:SeedEventsPath,
    $script:ReplayReportPath,
    $script:R17BoardContractsProofReviewPath,
    $script:R17BoardStateStoreProofReviewPath,
    $script:R17KanbanMvpProofReviewPath,
    $script:R17CardDetailProofReviewPath
)

$script:RequiredNonClaims = @(
    "no live board mutation",
    "no Orchestrator runtime",
    "no A2A runtime",
    "no autonomous agents",
    "no Dev/Codex adapter runtime",
    "no QA/Test Agent adapter runtime",
    "no Evidence Auditor API runtime",
    "no executable handoffs",
    "no executable transitions",
    "no external audit acceptance",
    "no main merge",
    "no product runtime",
    "no production runtime",
    "no external integrations",
    "no real Dev output",
    "no real QA result",
    "no real audit verdict",
    "no R13 closure",
    "no R14 caveat removal",
    "no R15 caveat removal",
    "no solved Codex compaction",
    "no solved Codex reliability"
)

$script:RequiredRejectedClaims = @(
    "live_board_mutation",
    "Orchestrator_runtime",
    "A2A_runtime",
    "autonomous_agents",
    "Dev_Codex_executor_adapter_runtime",
    "QA_Test_Agent_adapter_runtime",
    "Evidence_Auditor_API_adapter_runtime",
    "executable_handoffs",
    "executable_transitions",
    "external_integrations",
    "external_audit_acceptance",
    "main_merge",
    "product_runtime",
    "production_runtime",
    "R13_closure",
    "R14_caveat_removal",
    "R15_caveat_removal",
    "solved_Codex_compaction",
    "solved_Codex_reliability"
)

$script:ForbiddenClaimRules = @(
    @{ Label = "live board mutation claim"; Pattern = '(?i)\b(live board mutation|runtime board mutation|live Kanban mutation)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "Orchestrator runtime claim"; Pattern = '(?i)\bOrchestrator runtime\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "A2A runtime claim"; Pattern = '(?i)\bA2A runtime\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "autonomous agent claim"; Pattern = '(?i)\b(autonomous agents|actual autonomous agents|true multi-agent execution|true multi-agent runtime|multi-agent runtime)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|exists|working|available|ships|claimed)\b' },
    @{ Label = "Dev/Codex executor runtime claim"; Pattern = '(?i)\b(Dev/Codex executor adapter|Developer/Codex executor adapter|Dev/Codex adapter)\b.{0,160}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "QA/Test Agent adapter runtime claim"; Pattern = '(?i)\b(QA/Test Agent adapter|QA adapter|QA/Test Agent runtime)\b.{0,160}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "Evidence Auditor API runtime claim"; Pattern = '(?i)\b(Evidence Auditor API adapter|Evidence Auditor API runtime|Evidence Auditor API)\b.{0,160}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "executable handoff claim"; Pattern = '(?i)\b(executable handoff|executable handoffs)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "executable transition claim"; Pattern = '(?i)\b(executable transition|executable transitions)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "external integration claim"; Pattern = '(?i)\b(external integrations?|external API integration|external board sync)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "external audit acceptance claim"; Pattern = '(?i)\b(external audit acceptance|external audit accepted|external acceptance)\b.{0,120}\b(done|complete|completed|accepted|approved|claimed|exists|achieved)\b' },
    @{ Label = "main merge claim"; Pattern = '(?i)\b(main merge|merged to main|main contains R17|R17.*merged to main)\b' },
    @{ Label = "product or production runtime claim"; Pattern = '(?i)\b(product runtime|production runtime|Kanban product runtime)\b.{0,140}\b(done|complete|completed|implemented|executed|ran|exists|working|available|ships|claimed)\b' },
    @{ Label = "real Dev output claim"; Pattern = '(?i)\b(Dev output|Developer output|Codex output)\b.{0,140}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real)\b' },
    @{ Label = "real QA result claim"; Pattern = '(?i)\b(QA result|QA verdict|Test Agent result)\b.{0,140}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real|passed)\b' },
    @{ Label = "real audit verdict claim"; Pattern = '(?i)\b(audit verdict|Evidence Auditor verdict|external audit verdict)\b.{0,140}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real|passed|accepted)\b' },
    @{ Label = "R13 closure claim"; Pattern = '(?i)\bR13\b.{0,120}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b' },
    @{ Label = "R14 caveat removal claim"; Pattern = '(?i)\bR14\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' },
    @{ Label = "R15 caveat removal claim"; Pattern = '(?i)\bR15\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' },
    @{ Label = "solved Codex compaction claim"; Pattern = '(?i)\b(solved Codex compaction|solved Codex context compaction|Codex compaction solved)\b' },
    @{ Label = "solved Codex reliability claim"; Pattern = '(?i)\b(solved Codex reliability|Codex reliability solved)\b' }
)

function Resolve-R17CardDetailPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Read-R17CardDetailJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17CardDetailPath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "JSON file '$Path' does not exist."
    }

    try {
        return Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
    }
    catch {
        throw "JSON file '$Path' could not be parsed. $($_.Exception.Message)"
    }
}

function Write-R17CardDetailTextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17CardDetailPath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $resolvedPath -Value $Value -Encoding UTF8
}

function Write-R17CardDetailJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $InputObject,
        [string]$RepositoryRoot = $repoRoot
    )

    Write-R17CardDetailTextFile -Path $Path -Value ($InputObject | ConvertTo-Json -Depth 100) -RepositoryRoot $RepositoryRoot
}

function Assert-R17CardDetailSha {
    param($Value, [string]$Context)

    if ($Value -isnot [string] -or $Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character lowercase git SHA."
    }
}

function Assert-R17CardDetailHasProperty {
    param($Object, [string]$Name, [string]$Context)

    if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains $Name) {
        throw "$Context is missing required field '$Name'."
    }
}

function Assert-R17CardDetailArray {
    param($Value, [string]$Context, [switch]$AllowNullAsEmpty)

    if ($null -eq $Value -and $AllowNullAsEmpty) {
        return @()
    }

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    return @($Value)
}

function Assert-R17CardDetailContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)

    foreach ($requiredValue in $Required) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Get-R17CardDetailGitIdentity {
    param([string]$RepositoryRoot = $repoRoot)

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD."
    }

    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD tree."
    }

    Assert-R17CardDetailSha -Value $head -Context "generated_from_head"
    Assert-R17CardDetailSha -Value $tree -Context "generated_from_tree"

    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function Read-R17CardDetailEventLog {
    param(
        [string]$Path = $script:SeedEventsPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17CardDetailPath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Event log '$Path' does not exist."
    }

    $events = @()
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $resolvedPath) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        try {
            $events += ($line | ConvertFrom-Json)
        }
        catch {
            throw "Event log '$Path' line $lineNumber could not be parsed. $($_.Exception.Message)"
        }
    }

    return $events
}

function Get-R17CardDetailFinalLane {
    param(
        [Parameter(Mandatory = $true)]
        $ReplayReport,
        [Parameter(Mandatory = $true)]
        [string]$CardId
    )

    Assert-R17CardDetailHasProperty -Object $ReplayReport -Name "final_lane_by_card" -Context "replay report"
    if ($ReplayReport.final_lane_by_card.PSObject.Properties.Name -notcontains $CardId) {
        throw "Replay report final_lane_by_card is missing '$CardId'."
    }

    return [string]$ReplayReport.final_lane_by_card.PSObject.Properties[$CardId].Value
}

function ConvertTo-R17CardDetailEventHistory {
    param([object[]]$Events)

    $history = @()
    foreach ($event in $Events) {
        $history += [ordered]@{
            event_id = [string]$event.event_id
            event_type = [string]$event.event_type
            actor_role = [string]$event.actor_role
            agent_id = [string]$event.agent_id
            from_lane = [string]$event.from_lane
            to_lane = [string]$event.to_lane
            transition_allowed = [bool]$event.transition_allowed
            user_approval_present = [bool]$event.user_approval_present
            input_ref = [string]$event.input_ref
            output_ref = [string]$event.output_ref
            evidence_refs = @(Assert-R17CardDetailArray -Value $event.evidence_refs -Context "event $($event.event_id) evidence_refs" -AllowNullAsEmpty)
            validation_refs = @(Assert-R17CardDetailArray -Value $event.validation_refs -Context "event $($event.event_id) validation_refs" -AllowNullAsEmpty)
        }
    }

    return $history
}

function New-R17CardDetailDrawerSnapshot {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$GeneratedFromHead = "",
        [string]$GeneratedFromTree = ""
    )

    if ([string]::IsNullOrWhiteSpace($GeneratedFromHead) -or [string]::IsNullOrWhiteSpace($GeneratedFromTree)) {
        $identity = Get-R17CardDetailGitIdentity -RepositoryRoot $RepositoryRoot
        $GeneratedFromHead = $identity.Head
        $GeneratedFromTree = $identity.Tree
    }

    Assert-R17CardDetailSha -Value $GeneratedFromHead -Context "generated_from_head"
    Assert-R17CardDetailSha -Value $GeneratedFromTree -Context "generated_from_tree"

    $boardState = Read-R17CardDetailJsonFile -Path $script:BoardStatePath -RepositoryRoot $RepositoryRoot
    $seedCard = Read-R17CardDetailJsonFile -Path $script:SeedCardPath -RepositoryRoot $RepositoryRoot
    $replayReport = Read-R17CardDetailJsonFile -Path $script:ReplayReportPath -RepositoryRoot $RepositoryRoot
    $kanbanSnapshot = Read-R17CardDetailJsonFile -Path $script:KanbanSnapshotPath -RepositoryRoot $RepositoryRoot
    $events = @(Read-R17CardDetailEventLog -Path $script:SeedEventsPath -RepositoryRoot $RepositoryRoot)

    $cardRefs = @(Assert-R17CardDetailArray -Value $boardState.card_refs -Context "board state card_refs")
    $inspectableCards = @($cardRefs | Where-Object { $_.card_id -eq "R17-005" })
    if ($inspectableCards.Count -ne 1 -or $cardRefs.Count -ne 1) {
        throw "R17-007 can inspect exactly the expected R17-005 seed card."
    }

    $kanbanCards = @(Assert-R17CardDetailArray -Value $kanbanSnapshot.cards -Context "Kanban snapshot cards")
    $kanbanCard = @($kanbanCards | Where-Object { $_.card_id -eq "R17-005" })[0]
    if ($null -eq $kanbanCard) {
        throw "R17-006 Kanban snapshot must expose the R17-005 card."
    }

    $finalLane = Get-R17CardDetailFinalLane -ReplayReport $replayReport -CardId "R17-005"
    if ($finalLane -ne "ready_for_user_review") {
        throw "R17-005 seed card final lane must be ready_for_user_review."
    }

    $eventHistory = @(ConvertTo-R17CardDetailEventHistory -Events $events)
    $memoryRefs = @(Assert-R17CardDetailArray -Value $seedCard.memory_refs -Context "seed card memory_refs")
    $boundedMemoryRefs = @($memoryRefs | ForEach-Object {
            [ordered]@{
                ref = [string]$_
                boundary = "bounded repo ref only, not runtime memory loading"
            }
        })

    return [ordered]@{
        artifact_type = "r17_card_detail_drawer_snapshot"
        contract_version = "v1"
        source_task = "R17-007"
        milestone = $script:MilestoneName
        branch = $script:BranchName
        active_through_task = $script:ActiveThroughTask
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        ui_boundary_label = "Read-only card detail evidence drawer, not runtime"
        local_open_path = "$($script:UiRoot)/index.html"
        selected_card_id = "R17-005"
        inspectable_card_ids = @("R17-005")
        generated_from_artifacts = [ordered]@{
            board_state = $script:BoardStatePath
            seed_card = $script:SeedCardPath
            seed_event_log = $script:SeedEventsPath
            replay_report = $script:ReplayReportPath
            r17_004_proof_review_package = $script:R17BoardContractsProofReviewPath
            r17_005_proof_review_package = $script:R17BoardStateStoreProofReviewPath
            r17_006_proof_review_package = $script:R17KanbanMvpProofReviewPath
            r17_006_kanban_snapshot = $script:KanbanSnapshotPath
            r17_007_proof_review_package = $script:R17CardDetailProofReviewPath
        }
        canonical_truth = [ordered]@{
            repo_truth_is_canonical = $true
            read_only_static_ui_only = $true
            live_board_mutation_implemented = $false
            product_runtime_implemented = $false
            production_runtime_implemented = $false
            kanban_product_runtime_implemented = $false
            orchestrator_runtime_implemented = $false
            a2a_runtime_implemented = $false
            autonomous_agents_implemented = $false
            dev_codex_executor_adapter_runtime_implemented = $false
            qa_test_agent_adapter_runtime_implemented = $false
            evidence_auditor_api_runtime_implemented = $false
            executable_handoffs_implemented = $false
            executable_transitions_implemented = $false
            external_integrations_implemented = $false
            external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
        }
        card_identity = [ordered]@{
            card_id = [string]$seedCard.card_id
            task_id = [string]$seedCard.task_id
            title = [string]$seedCard.title
            milestone = [string]$seedCard.milestone
            current_lane = $finalLane
            owner_role = [string]$seedCard.owner_role
            current_agent = [string]$seedCard.current_agent
            status = [string]$kanbanCard.status
        }
        delivery_decision_state = [ordered]@{
            user_decision_required = [bool]$seedCard.user_decision_required
            user_approval_required_for_closure = [bool]$seedCard.user_approval_required_for_closure
            unresolved_blockers = @(Assert-R17CardDetailArray -Value $replayReport.unresolved_blockers -Context "replay unresolved_blockers" -AllowNullAsEmpty)
            final_lane_from_replay_report = $finalLane
            closure_status = "not_closed_user_approval_required"
            closure_note = "closure still requires user approval"
            user_decisions_required = @(Assert-R17CardDetailArray -Value $replayReport.user_decisions_required -Context "replay user_decisions_required")
        }
        acceptance_criteria = @(Assert-R17CardDetailArray -Value $seedCard.acceptance_criteria -Context "seed card acceptance_criteria")
        qa_criteria = @(Assert-R17CardDetailArray -Value $seedCard.qa_criteria -Context "seed card qa_criteria")
        output_placeholders = [ordered]@{
            dev_output = [ordered]@{
                status = "not_implemented_in_r17_007"
                boundary = "placeholder only; no Dev/Codex executor adapter runtime and no real Dev output"
            }
            qa_result = [ordered]@{
                status = "not_implemented_in_r17_007"
                boundary = "placeholder only; no QA/Test Agent adapter runtime and no real QA result"
            }
            audit_verdict = [ordered]@{
                status = "not_implemented_in_r17_007"
                boundary = "placeholder only; no Evidence Auditor API runtime and no real audit verdict"
            }
        }
        evidence_refs = $script:RequiredEvidenceRefs
        card_evidence_refs = @(Assert-R17CardDetailArray -Value $seedCard.evidence_refs -Context "seed card evidence_refs")
        memory_refs = $boundedMemoryRefs
        task_packet_ref = [ordered]@{
            ref = [string]$seedCard.task_packet_ref
            boundary = "bounded repo ref only, not runtime task packet loading or executable handoff"
        }
        event_history = [ordered]@{
            event_count = $eventHistory.Count
            events = $eventHistory
        }
        validation_and_proof_refs = [ordered]@{
            replay_report = $script:ReplayReportPath
            r17_004_proof_review_package = $script:R17BoardContractsProofReviewPath
            r17_005_proof_review_package = $script:R17BoardStateStoreProofReviewPath
            r17_006_proof_review_package = $script:R17KanbanMvpProofReviewPath
            r17_007_proof_review_package = $script:R17CardDetailProofReviewPath
        }
        non_claims = $script:RequiredNonClaims
        rejected_claims = $script:RequiredRejectedClaims
    }
}

function New-R17CardDetailDrawer {
    param([string]$RepositoryRoot = $repoRoot)

    $snapshot = New-R17CardDetailDrawerSnapshot -RepositoryRoot $RepositoryRoot
    Write-R17CardDetailJsonFile -Path $script:SnapshotPath -InputObject $snapshot -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        SnapshotPath = $script:SnapshotPath
        SelectedCardId = $snapshot.selected_card_id
        SelectedCardLane = $snapshot.card_identity.current_lane
        EvidenceRefCount = @($snapshot.evidence_refs).Count
        MemoryRefCount = @($snapshot.memory_refs).Count
        EventHistoryCount = [int]$snapshot.event_history.event_count
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Test-R17CardDetailLineHasNegation {
    param([string]$Text)

    return ($Text -match '(?i)\b(no|not|does not|do not|is not|are not|never|forbid|forbidden|reject|rejected|non-claim|non-claims|placeholder|only|without)\b' -or $Text -match ':\s*false\b')
}

function Test-R17CardDetailTextHasNoForbiddenClaims {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Context = "text"
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        foreach ($rule in $script:ForbiddenClaimRules) {
            if ($line -match $rule.Pattern -and -not (Test-R17CardDetailLineHasNegation -Text $line)) {
                throw "$Context contains $($rule.Label). Offending text: $line"
            }
        }
    }
}

function Test-R17CardDetailTextHasNoExternalDependencyRefs {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Context = "text"
    )

    $patterns = @(
        @{ Label = "http URL"; Pattern = '(?i)http://' },
        @{ Label = "https URL"; Pattern = '(?i)https://' },
        @{ Label = "remote font reference"; Pattern = '(?i)(fonts\.googleapis\.com|fonts\.gstatic\.com|@import\s+url)' },
        @{ Label = "CDN reference"; Pattern = '(?i)(cdnjs|jsdelivr|unpkg|cdn\.)' },
        @{ Label = "npm package reference"; Pattern = '(?i)\bnpm\s+(install|run|package|dependency)\b' }
    )

    foreach ($pattern in $patterns) {
        if ($Text -match $pattern.Pattern) {
            throw "$Context contains external dependency reference: $($pattern.Label)."
        }
    }
}

function Get-R17CardDetailStringValues {
    param($Value)

    $strings = @()
    if ($null -eq $Value) {
        return $strings
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $strings += Get-R17CardDetailStringValues -Value $Value[$key]
        }
        return $strings
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $strings += Get-R17CardDetailStringValues -Value $item
        }
        return $strings
    }

    if (@($Value.PSObject.Properties).Count -gt 0) {
        foreach ($property in $Value.PSObject.Properties) {
            $strings += Get-R17CardDetailStringValues -Value $property.Value
        }
    }

    return $strings
}

function Test-R17CardDetailDrawerSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        $Snapshot,
        [string]$Context = "R17-007 card detail drawer snapshot"
    )

    foreach ($field in @("artifact_type", "contract_version", "source_task", "milestone", "branch", "active_through_task", "generated_from_head", "generated_from_tree", "ui_boundary_label", "selected_card_id", "inspectable_card_ids", "generated_from_artifacts", "canonical_truth", "card_identity", "delivery_decision_state", "acceptance_criteria", "qa_criteria", "output_placeholders", "evidence_refs", "memory_refs", "task_packet_ref", "event_history", "validation_and_proof_refs", "non_claims", "rejected_claims")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot -Name $field -Context $Context
    }

    if ($Snapshot.artifact_type -ne "r17_card_detail_drawer_snapshot") {
        throw "$Context artifact_type must be r17_card_detail_drawer_snapshot."
    }
    if ($Snapshot.source_task -ne "R17-007") {
        throw "$Context source_task must be R17-007."
    }
    if ($Snapshot.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($Snapshot.branch -ne $script:BranchName) {
        throw "$Context branch is incorrect."
    }
    if ($Snapshot.active_through_task -ne $script:ActiveThroughTask) {
        throw "$Context active_through_task must be R17-007."
    }
    if ($Snapshot.ui_boundary_label -notmatch '(?i)read-only card detail evidence drawer, not runtime') {
        throw "$Context must label the drawer as read-only and not runtime."
    }

    Assert-R17CardDetailSha -Value $Snapshot.generated_from_head -Context "$Context generated_from_head"
    Assert-R17CardDetailSha -Value $Snapshot.generated_from_tree -Context "$Context generated_from_tree"

    $inspectableCardIds = [string[]](Assert-R17CardDetailArray -Value $Snapshot.inspectable_card_ids -Context "$Context inspectable_card_ids")
    if ($Snapshot.selected_card_id -ne "R17-005" -or $inspectableCardIds.Count -ne 1 -or $inspectableCardIds[0] -ne "R17-005") {
        throw "$Context must allow inspection of exactly the R17-005 seed card."
    }

    foreach ($field in @("card_id", "task_id", "title", "milestone", "current_lane", "owner_role", "current_agent", "status")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot.card_identity -Name $field -Context "$Context card_identity"
    }
    if ($Snapshot.card_identity.card_id -ne "R17-005" -or $Snapshot.card_identity.task_id -ne "R17-005") {
        throw "$Context card_identity must identify R17-005."
    }
    if ($Snapshot.card_identity.current_lane -ne "ready_for_user_review") {
        throw "$Context card_identity current_lane must be ready_for_user_review."
    }

    foreach ($field in @("user_decision_required", "user_approval_required_for_closure", "unresolved_blockers", "final_lane_from_replay_report", "closure_status", "closure_note", "user_decisions_required")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot.delivery_decision_state -Name $field -Context "$Context delivery_decision_state"
    }
    if ($Snapshot.delivery_decision_state.user_decision_required -ne $true -or $Snapshot.delivery_decision_state.user_approval_required_for_closure -ne $true) {
        throw "$Context delivery_decision_state must show user decision and closure approval requirements."
    }
    if ($Snapshot.delivery_decision_state.final_lane_from_replay_report -ne "ready_for_user_review") {
        throw "$Context delivery_decision_state must include final lane from replay report."
    }
    if ($Snapshot.delivery_decision_state.closure_status -ne "not_closed_user_approval_required" -or $Snapshot.delivery_decision_state.closure_note -notmatch '(?i)closure still requires user approval') {
        throw "$Context delivery_decision_state must state closure still requires user approval."
    }
    if (@(Assert-R17CardDetailArray -Value $Snapshot.delivery_decision_state.user_decisions_required -Context "$Context user_decisions_required").Count -lt 1) {
        throw "$Context must surface user decision state."
    }

    if (@(Assert-R17CardDetailArray -Value $Snapshot.acceptance_criteria -Context "$Context acceptance_criteria").Count -lt 1) {
        throw "$Context must surface acceptance criteria."
    }
    if (@(Assert-R17CardDetailArray -Value $Snapshot.qa_criteria -Context "$Context qa_criteria").Count -lt 1) {
        throw "$Context must surface QA criteria."
    }

    foreach ($placeholderName in @("dev_output", "qa_result", "audit_verdict")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot.output_placeholders -Name $placeholderName -Context "$Context output_placeholders"
        $placeholder = $Snapshot.output_placeholders.PSObject.Properties[$placeholderName].Value
        Assert-R17CardDetailHasProperty -Object $placeholder -Name "status" -Context "$Context $placeholderName placeholder"
        if ($placeholder.status -ne "not_implemented_in_r17_007") {
            throw "$Context $placeholderName must be explicitly marked not_implemented_in_r17_007."
        }
    }

    Assert-R17CardDetailContains -Values ([string[]](Assert-R17CardDetailArray -Value $Snapshot.evidence_refs -Context "$Context evidence_refs")) -Required $script:RequiredEvidenceRefs -Context "$Context evidence_refs"

    $memoryRefs = @(Assert-R17CardDetailArray -Value $Snapshot.memory_refs -Context "$Context memory_refs")
    if ($memoryRefs.Count -lt 1) {
        throw "$Context must surface memory refs."
    }
    foreach ($memoryRef in $memoryRefs) {
        Assert-R17CardDetailHasProperty -Object $memoryRef -Name "ref" -Context "$Context memory_ref"
        Assert-R17CardDetailHasProperty -Object $memoryRef -Name "boundary" -Context "$Context memory_ref"
        if ($memoryRef.boundary -notmatch '(?i)bounded repo ref only, not runtime memory loading') {
            throw "$Context memory refs must be labelled as bounded refs, not runtime memory loading."
        }
    }

    Assert-R17CardDetailHasProperty -Object $Snapshot.task_packet_ref -Name "ref" -Context "$Context task_packet_ref"
    Assert-R17CardDetailHasProperty -Object $Snapshot.task_packet_ref -Name "boundary" -Context "$Context task_packet_ref"
    if ([string]::IsNullOrWhiteSpace([string]$Snapshot.task_packet_ref.ref) -or $Snapshot.task_packet_ref.boundary -notmatch '(?i)bounded repo ref only') {
        throw "$Context must surface task_packet_ref as a bounded repo ref."
    }

    Assert-R17CardDetailHasProperty -Object $Snapshot.event_history -Name "event_count" -Context "$Context event_history"
    Assert-R17CardDetailHasProperty -Object $Snapshot.event_history -Name "events" -Context "$Context event_history"
    $events = @(Assert-R17CardDetailArray -Value $Snapshot.event_history.events -Context "$Context event_history events")
    if ([int]$Snapshot.event_history.event_count -ne $events.Count -or $events.Count -lt 1) {
        throw "$Context must surface event history."
    }
    foreach ($event in $events) {
        foreach ($field in @("event_id", "event_type", "actor_role", "from_lane", "to_lane", "transition_allowed", "user_approval_present", "input_ref", "output_ref", "evidence_refs", "validation_refs")) {
            Assert-R17CardDetailHasProperty -Object $event -Name $field -Context "$Context event"
        }
    }

    foreach ($field in @("board_state", "seed_card", "seed_event_log", "replay_report", "r17_004_proof_review_package", "r17_005_proof_review_package", "r17_006_proof_review_package", "r17_006_kanban_snapshot", "r17_007_proof_review_package")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot.generated_from_artifacts -Name $field -Context "$Context generated_from_artifacts"
    }

    foreach ($field in @("live_board_mutation_implemented", "product_runtime_implemented", "production_runtime_implemented", "kanban_product_runtime_implemented", "orchestrator_runtime_implemented", "a2a_runtime_implemented", "autonomous_agents_implemented", "dev_codex_executor_adapter_runtime_implemented", "qa_test_agent_adapter_runtime_implemented", "evidence_auditor_api_runtime_implemented", "executable_handoffs_implemented", "executable_transitions_implemented", "external_integrations_implemented", "external_audit_acceptance_claimed", "main_merge_claimed")) {
        Assert-R17CardDetailHasProperty -Object $Snapshot.canonical_truth -Name $field -Context "$Context canonical_truth"
        if ($Snapshot.canonical_truth.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context canonical_truth $field must be false."
        }
    }

    Assert-R17CardDetailContains -Values ([string[]](Assert-R17CardDetailArray -Value $Snapshot.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"
    Assert-R17CardDetailContains -Values ([string[]](Assert-R17CardDetailArray -Value $Snapshot.rejected_claims -Context "$Context rejected_claims")) -Required $script:RequiredRejectedClaims -Context "$Context rejected_claims"

    foreach ($stringValue in Get-R17CardDetailStringValues -Value $Snapshot) {
        Test-R17CardDetailTextHasNoForbiddenClaims -Text $stringValue -Context "$Context string value"
        Test-R17CardDetailTextHasNoExternalDependencyRefs -Text $stringValue -Context "$Context string value"
    }
}

function Test-R17CardDetailDrawerUiFiles {
    param([string]$RepositoryRoot = $repoRoot)

    foreach ($relativePath in @("$($script:UiRoot)/index.html", "$($script:UiRoot)/styles.css", "$($script:UiRoot)/kanban.js", "$($script:UiRoot)/README.md")) {
        $resolvedPath = Resolve-R17CardDetailPath -Path $relativePath -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            throw "UI file '$relativePath' does not exist."
        }

        $text = Get-Content -LiteralPath $resolvedPath -Raw
        Test-R17CardDetailTextHasNoExternalDependencyRefs -Text $text -Context $relativePath
        Test-R17CardDetailTextHasNoForbiddenClaims -Text $text -Context $relativePath
    }

    $indexText = Get-Content -LiteralPath (Resolve-R17CardDetailPath -Path "$($script:UiRoot)/index.html" -RepositoryRoot $RepositoryRoot) -Raw
    foreach ($requiredFragment in @("card-detail-drawer", "Selected Card Detail", "Acceptance Criteria", "QA Criteria", "Event History", "not_implemented_in_r17_007")) {
        if ($indexText -notmatch [regex]::Escape($requiredFragment)) {
            throw "index.html must expose the R17-007 card detail drawer fragment '$requiredFragment'."
        }
    }
}

function Test-R17CardDetailDrawer {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$SnapshotPath = $script:SnapshotPath
    )

    $snapshot = Read-R17CardDetailJsonFile -Path $SnapshotPath -RepositoryRoot $RepositoryRoot
    Test-R17CardDetailDrawerSnapshot -Snapshot $snapshot

    foreach ($evidenceRef in $script:RequiredEvidenceRefs) {
        $resolvedPath = Resolve-R17CardDetailPath -Path $evidenceRef -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            throw "Evidence ref '$evidenceRef' does not exist."
        }
    }

    $expectedSnapshot = New-R17CardDetailDrawerSnapshot -RepositoryRoot $RepositoryRoot -GeneratedFromHead $snapshot.generated_from_head -GeneratedFromTree $snapshot.generated_from_tree
    $expectedJson = $expectedSnapshot | ConvertTo-Json -Depth 100
    $actualJson = $snapshot | ConvertTo-Json -Depth 100
    if ($expectedJson -ne $actualJson) {
        throw "R17-007 card detail snapshot does not match deterministic generation output."
    }

    Test-R17CardDetailDrawerUiFiles -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        SnapshotPath = $SnapshotPath
        SelectedCardId = $snapshot.selected_card_id
        SelectedCardLane = $snapshot.card_identity.current_lane
        EvidenceRefCount = @($snapshot.evidence_refs).Count
        MemoryRefCount = @($snapshot.memory_refs).Count
        EventHistoryCount = [int]$snapshot.event_history.event_count
        UserDecisionRequired = [bool]$snapshot.delivery_decision_state.user_decision_required
        DevOutputPlaceholderStatus = $snapshot.output_placeholders.dev_output.status
        QaResultPlaceholderStatus = $snapshot.output_placeholders.qa_result.status
        AuditVerdictPlaceholderStatus = $snapshot.output_placeholders.audit_verdict.status
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Get-R17CardDetailDrawerPaths {
    return [pscustomobject]@{
        UiRoot = $script:UiRoot
        SnapshotPath = $script:SnapshotPath
        KanbanSnapshotPath = $script:KanbanSnapshotPath
        IndexPath = "$($script:UiRoot)/index.html"
        StylesPath = "$($script:UiRoot)/styles.css"
        ScriptPath = "$($script:UiRoot)/kanban.js"
        ReadmePath = "$($script:UiRoot)/README.md"
        ProofReviewPath = $script:R17CardDetailProofReviewPath
    }
}

Export-ModuleMember -Function @(
    "Get-R17CardDetailDrawerPaths",
    "Read-R17CardDetailJsonFile",
    "New-R17CardDetailDrawerSnapshot",
    "New-R17CardDetailDrawer",
    "Test-R17CardDetailDrawerSnapshot",
    "Test-R17CardDetailTextHasNoExternalDependencyRefs",
    "Test-R17CardDetailTextHasNoForbiddenClaims",
    "Test-R17CardDetailDrawerUiFiles",
    "Test-R17CardDetailDrawer"
)
