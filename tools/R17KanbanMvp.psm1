Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:ActiveThroughTask = "R17-006"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:UiRoot = "scripts/operator_wall/r17_kanban_mvp"
$script:SnapshotPath = "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json"
$script:BoardStatePath = "$($script:BoardRoot)/r17_board_state.json"
$script:SeedCardPath = "$($script:BoardRoot)/cards/r17_005_seed_card.json"
$script:SeedEventsPath = "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
$script:ReplayReportPath = "$($script:BoardRoot)/r17_board_replay_report.json"
$script:R17BoardContractsProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/"
$script:R17BoardStateStoreProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/"

$script:RequiredLanes = @(
    "intake",
    "define",
    "ready_for_dev",
    "in_dev",
    "ready_for_qa",
    "in_qa",
    "fix_required",
    "ready_for_audit",
    "in_audit",
    "ready_for_user_review",
    "resolved",
    "closed",
    "blocked"
)

$script:RequiredNonClaims = @(
    "no Kanban product runtime",
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
    "no product runtime"
)

$script:RequiredEvidenceRefs = @(
    $script:BoardStatePath,
    $script:SeedCardPath,
    $script:SeedEventsPath,
    $script:ReplayReportPath,
    $script:R17BoardContractsProofReviewPath,
    $script:R17BoardStateStoreProofReviewPath
)

$script:ForbiddenClaimRules = @(
    @{ Label = "Kanban product runtime claim"; Pattern = '(?i)\b(Kanban product runtime|Kanban runtime)\b.{0,120}\b(implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "Orchestrator runtime claim"; Pattern = '(?i)\bOrchestrator runtime\b.{0,120}\b(implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "A2A runtime claim"; Pattern = '(?i)\bA2A runtime\b.{0,120}\b(implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "autonomous agent claim"; Pattern = '(?i)\b(autonomous agents|actual autonomous agents|true multi-agent execution|true multi-agent runtime)\b.{0,120}\b(implemented|exist|exists|working|available|ship|ships|claimed|complete|completed|done|run|runs|ran|executed)\b' },
    @{ Label = "Dev/Codex executor runtime claim"; Pattern = '(?i)\b(Dev/Codex executor adapter|Developer/Codex executor adapter|Dev/Codex adapter)\b.{0,140}\b(runtime|implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "QA/Test Agent adapter runtime claim"; Pattern = '(?i)\b(QA/Test Agent adapter|QA adapter|QA/Test Agent runtime)\b.{0,140}\b(runtime|implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "Evidence Auditor API runtime claim"; Pattern = '(?i)\b(Evidence Auditor API adapter|Evidence Auditor API runtime|Evidence Auditor API)\b.{0,140}\b(runtime|implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "executable handoff claim"; Pattern = '(?i)\b(executable handoff|executable handoffs)\b.{0,120}\b(implemented|exist|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "executable transition claim"; Pattern = '(?i)\b(executable transition|executable transitions)\b.{0,120}\b(implemented|exist|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' },
    @{ Label = "external audit acceptance claim"; Pattern = '(?i)\b(external audit acceptance|external audit accepted|external acceptance)\b.{0,120}\b(accepted|approved|exists|claimed|complete|completed|done|achieved)\b' },
    @{ Label = "main merge claim"; Pattern = '(?i)\b(main merge|merged to main|main contains R17|R17.*merged to main)\b' },
    @{ Label = "R13 closure claim"; Pattern = '(?i)\bR13\b.{0,120}\b(is closed|is now closed|closed in repo truth|formally closed|closeout exists|closeout package exists)\b' },
    @{ Label = "R14 caveat removal claim"; Pattern = '(?i)\bR14\b.{0,120}\b(accepted without caveats|caveats removed|cleanly accepted|uncaveated acceptance)\b' },
    @{ Label = "R15 caveat removal claim"; Pattern = '(?i)\bR15\b.{0,120}\b(accepted without caveats|caveats removed|cleanly accepted|uncaveated acceptance)\b' },
    @{ Label = "solved Codex compaction claim"; Pattern = '(?i)\b(solved Codex compaction|solved Codex context compaction|Codex compaction solved)\b' },
    @{ Label = "solved Codex reliability claim"; Pattern = '(?i)\b(solved Codex reliability|Codex reliability solved)\b' },
    @{ Label = "product runtime claim"; Pattern = '(?i)\b(product runtime|production runtime)\b.{0,120}\b(implemented|exists|working|available|ships|claimed|complete|completed|done|runs?|ran|executed)\b' }
)

function Resolve-R17KanbanMvpPath {
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

function Read-R17KanbanMvpJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17KanbanMvpPath -Path $Path -RepositoryRoot $RepositoryRoot
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

function Write-R17KanbanMvpTextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17KanbanMvpPath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $resolvedPath -Value $Value -Encoding UTF8
}

function Write-R17KanbanMvpJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $InputObject,
        [string]$RepositoryRoot = $repoRoot
    )

    Write-R17KanbanMvpTextFile -Path $Path -Value ($InputObject | ConvertTo-Json -Depth 100) -RepositoryRoot $RepositoryRoot
}

function Assert-R17KanbanMvpSha {
    param($Value, [string]$Context)

    if ($Value -isnot [string] -or $Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character lowercase git SHA."
    }
}

function Assert-R17KanbanMvpArray {
    param($Value, [string]$Context, [switch]$AllowNullAsEmpty)

    if ($null -eq $Value -and $AllowNullAsEmpty) {
        return @()
    }

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    return @($Value)
}

function Assert-R17KanbanMvpHasProperty {
    param($Object, [string]$Name, [string]$Context)

    if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains $Name) {
        throw "$Context is missing required field '$Name'."
    }
}

function Assert-R17KanbanMvpContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)

    foreach ($requiredValue in $Required) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-R17KanbanMvpLaneOrder {
    param([object[]]$LaneOrder, [string]$Context)

    $actual = [string[]]@($LaneOrder)
    if ($actual.Count -ne $script:RequiredLanes.Count) {
        throw "$Context must include $($script:RequiredLanes.Count) lanes."
    }

    for ($index = 0; $index -lt $script:RequiredLanes.Count; $index++) {
        if ($actual[$index] -ne $script:RequiredLanes[$index]) {
            throw "$Context lane order mismatch at index $index. Expected '$($script:RequiredLanes[$index])', got '$($actual[$index])'."
        }
    }
}

function Get-R17KanbanMvpGitIdentity {
    param([string]$RepositoryRoot = $repoRoot)

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD."
    }

    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD tree."
    }

    Assert-R17KanbanMvpSha -Value $head -Context "generated_from_head"
    Assert-R17KanbanMvpSha -Value $tree -Context "generated_from_tree"

    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function Get-R17KanbanMvpFinalLane {
    param(
        [Parameter(Mandatory = $true)]
        $ReplayReport,
        [Parameter(Mandatory = $true)]
        [string]$CardId
    )

    Assert-R17KanbanMvpHasProperty -Object $ReplayReport -Name "final_lane_by_card" -Context "replay report"
    if ($ReplayReport.final_lane_by_card.PSObject.Properties.Name -notcontains $CardId) {
        throw "Replay report final_lane_by_card is missing '$CardId'."
    }

    return [string]$ReplayReport.final_lane_by_card.PSObject.Properties[$CardId].Value
}

function ConvertTo-R17KanbanMvpLaneTitle {
    param([Parameter(Mandatory = $true)][string]$Lane)

    $parts = @($Lane -split "_" | ForEach-Object {
            if ([string]::IsNullOrWhiteSpace($_)) {
                $_
            }
            else {
                $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1)
            }
        })
    return ($parts -join " ")
}

function New-R17KanbanMvpSnapshot {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$GeneratedFromHead = "",
        [string]$GeneratedFromTree = ""
    )

    if ([string]::IsNullOrWhiteSpace($GeneratedFromHead) -or [string]::IsNullOrWhiteSpace($GeneratedFromTree)) {
        $identity = Get-R17KanbanMvpGitIdentity -RepositoryRoot $RepositoryRoot
        $GeneratedFromHead = $identity.Head
        $GeneratedFromTree = $identity.Tree
    }

    Assert-R17KanbanMvpSha -Value $GeneratedFromHead -Context "generated_from_head"
    Assert-R17KanbanMvpSha -Value $GeneratedFromTree -Context "generated_from_tree"

    $boardState = Read-R17KanbanMvpJsonFile -Path $script:BoardStatePath -RepositoryRoot $RepositoryRoot
    $seedCard = Read-R17KanbanMvpJsonFile -Path $script:SeedCardPath -RepositoryRoot $RepositoryRoot
    $replayReport = Read-R17KanbanMvpJsonFile -Path $script:ReplayReportPath -RepositoryRoot $RepositoryRoot

    $laneOrder = [string[]](Assert-R17KanbanMvpArray -Value $boardState.lane_order -Context "board state lane_order")
    Assert-R17KanbanMvpLaneOrder -LaneOrder $laneOrder -Context "board state lane_order"

    $finalLane = Get-R17KanbanMvpFinalLane -ReplayReport $replayReport -CardId "R17-005"
    if ($finalLane -ne "ready_for_user_review") {
        throw "R17-005 seed card final lane must be ready_for_user_review."
    }

    $boardCardRef = @($boardState.card_refs | Where-Object { $_.card_id -eq "R17-005" })[0]
    if ($null -eq $boardCardRef) {
        throw "Board state card_refs must include R17-005."
    }

    $cardSummary = [ordered]@{
        card_id = [string]$seedCard.card_id
        task_id = [string]$seedCard.task_id
        title = [string]$seedCard.title
        current_lane = $finalLane
        owner_role = [string]$seedCard.owner_role
        current_agent = [string]$seedCard.current_agent
        status = [string]$boardCardRef.status
        user_decision_required = [bool]$seedCard.user_decision_required
        user_approval_required_for_closure = [bool]$seedCard.user_approval_required_for_closure
        evidence_ref_count = @(Assert-R17KanbanMvpArray -Value $seedCard.evidence_refs -Context "seed card evidence_refs" -AllowNullAsEmpty).Count
        memory_ref_count = @(Assert-R17KanbanMvpArray -Value $seedCard.memory_refs -Context "seed card memory_refs" -AllowNullAsEmpty).Count
        blocker_count = @(Assert-R17KanbanMvpArray -Value $seedCard.blocker_refs -Context "seed card blocker_refs" -AllowNullAsEmpty).Count
        evidence_refs = @(Assert-R17KanbanMvpArray -Value $seedCard.evidence_refs -Context "seed card evidence_refs" -AllowNullAsEmpty)
        memory_refs = @(Assert-R17KanbanMvpArray -Value $seedCard.memory_refs -Context "seed card memory_refs" -AllowNullAsEmpty)
        blocker_refs = @(Assert-R17KanbanMvpArray -Value $seedCard.blocker_refs -Context "seed card blocker_refs" -AllowNullAsEmpty)
    }

    $cards = @($cardSummary)
    $lanes = @()
    foreach ($lane in $laneOrder) {
        $laneCards = @($cards | Where-Object { $_.current_lane -eq $lane })
        $lanes += [ordered]@{
            id = $lane
            title = ConvertTo-R17KanbanMvpLaneTitle -Lane $lane
            card_count = $laneCards.Count
            cards = @($laneCards | ForEach-Object { $_.card_id })
        }
    }

    $finalLaneByCard = [ordered]@{}
    foreach ($property in $replayReport.final_lane_by_card.PSObject.Properties) {
        $finalLaneByCard[$property.Name] = [string]$property.Value
    }

    return [ordered]@{
        artifact_type = "r17_kanban_mvp_snapshot"
        contract_version = "v1"
        source_task = "R17-006"
        milestone = $script:MilestoneName
        branch = $script:BranchName
        active_through_task = $script:ActiveThroughTask
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        ui_boundary_label = "Read-only Kanban MVP, not runtime"
        local_open_path = "$($script:UiRoot)/index.html"
        source_artifacts = [ordered]@{
            board_state = $script:BoardStatePath
            seed_card = $script:SeedCardPath
            seed_event_log = $script:SeedEventsPath
            replay_report = $script:ReplayReportPath
            r17_004_proof_review_package = $script:R17BoardContractsProofReviewPath
            r17_005_proof_review_package = $script:R17BoardStateStoreProofReviewPath
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
        }
        lane_order = $laneOrder
        lanes = $lanes
        cards = $cards
        replay_summary = [ordered]@{
            aggregate_verdict = [string]$replayReport.aggregate_verdict
            input_card_count = [int]$replayReport.input_card_count
            input_event_count = [int]$replayReport.input_event_count
            replayed_event_count = [int]$replayReport.replayed_event_count
            rejected_event_count = [int]$replayReport.rejected_event_count
            final_lane_by_card = $finalLaneByCard
            user_decisions_required = @(Assert-R17KanbanMvpArray -Value $replayReport.user_decisions_required -Context "replay user_decisions_required" -AllowNullAsEmpty)
            unresolved_blockers = @(Assert-R17KanbanMvpArray -Value $replayReport.unresolved_blockers -Context "replay unresolved_blockers" -AllowNullAsEmpty)
        }
        non_claims = $script:RequiredNonClaims
        evidence_refs = $script:RequiredEvidenceRefs
    }
}

function ConvertTo-R17KanbanMvpJavaScript {
    param(
        [Parameter(Mandatory = $true)]
        $Snapshot
    )

    $json = $Snapshot | ConvertTo-Json -Depth 100
    return @"
"use strict";

window.R17_KANBAN_SNAPSHOT = $json;

(function () {
  const snapshot = window.R17_KANBAN_SNAPSHOT;

  function text(value) {
    if (value === true) return "yes";
    if (value === false) return "no";
    if (value === null || value === undefined || value === "") return "none";
    return String(value);
  }

  function pretty(value) {
    return text(value).replace(/_/g, " ");
  }

  function byId(id) {
    return document.getElementById(id);
  }

  function create(tag, className, content) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (content !== undefined) node.textContent = content;
    return node;
  }

  function addMetric(parent, label, value) {
    const item = create("div", "metric");
    item.append(create("span", "metric-label", label));
    item.append(create("strong", "", text(value)));
    parent.append(item);
  }

  function renderHeader() {
    byId("milestone").textContent = snapshot.milestone;
    byId("boundary-label").textContent = snapshot.ui_boundary_label;
    const meta = byId("meta-grid");
    meta.innerHTML = "";
    addMetric(meta, "Branch", snapshot.branch);
    addMetric(meta, "Active through", snapshot.active_through_task);
    addMetric(meta, "Generated from head", snapshot.generated_from_head);
    addMetric(meta, "Generated from tree", snapshot.generated_from_tree);
  }

  function cardById(cardId) {
    return snapshot.cards.find((card) => card.card_id === cardId);
  }

  function renderCard(card) {
    const article = create("article", "kanban-card");
    const title = create("div", "card-title");
    title.append(create("span", "card-id", card.card_id));
    title.append(create("strong", "", card.title));
    article.append(title);

    const fields = [
      ["Task", card.task_id],
      ["Lane", pretty(card.current_lane)],
      ["Owner", pretty(card.owner_role)],
      ["Agent", pretty(card.current_agent)],
      ["Status", pretty(card.status)],
      ["User decision", card.user_decision_required],
      ["Closure approval", card.user_approval_required_for_closure],
      ["Evidence refs", card.evidence_ref_count],
      ["Memory refs", card.memory_ref_count],
      ["Blockers", card.blocker_count]
    ];

    const dl = create("dl", "card-fields");
    fields.forEach(([label, value]) => {
      dl.append(create("dt", "", label));
      dl.append(create("dd", "", text(value)));
    });
    article.append(dl);
    return article;
  }

  function renderBoard() {
    const board = byId("lane-board");
    board.innerHTML = "";

    snapshot.lanes.forEach((lane) => {
      const section = create("section", "lane");
      const header = create("header", "lane-header");
      header.append(create("h2", "", lane.title));
      header.append(create("span", "lane-count", lane.card_count));
      section.append(header);

      const cards = create("div", "lane-cards");
      if (lane.cards.length === 0) {
        cards.append(create("p", "empty-lane", "No cards"));
      } else {
        lane.cards.forEach((cardId) => cards.append(renderCard(cardById(cardId))));
      }
      section.append(cards);
      board.append(section);
    });
  }

  function renderReplay() {
    const replay = byId("replay-summary");
    replay.innerHTML = "";
    const summary = snapshot.replay_summary;
    const metrics = create("div", "summary-grid");
    addMetric(metrics, "Aggregate verdict", summary.aggregate_verdict);
    addMetric(metrics, "Input cards", summary.input_card_count);
    addMetric(metrics, "Input events", summary.input_event_count);
    addMetric(metrics, "Replayed events", summary.replayed_event_count);
    addMetric(metrics, "Rejected events", summary.rejected_event_count);
    addMetric(metrics, "User decisions", summary.user_decisions_required.length);
    addMetric(metrics, "Unresolved blockers", summary.unresolved_blockers.length);
    replay.append(metrics);

    const finalLaneList = create("ul", "plain-list");
    Object.entries(summary.final_lane_by_card).forEach(([cardId, lane]) => {
      finalLaneList.append(create("li", "", cardId + " -> " + pretty(lane)));
    });
    replay.append(create("h3", "", "Final lane by card"));
    replay.append(finalLaneList);

    const decisionList = create("ul", "plain-list");
    summary.user_decisions_required.forEach((decision) => {
      decisionList.append(create("li", "", decision.card_id + ": " + decision.decision));
    });
    if (summary.user_decisions_required.length === 0) decisionList.append(create("li", "", "none"));
    replay.append(create("h3", "", "User decisions required"));
    replay.append(decisionList);
  }

  function renderList(id, values) {
    const list = byId(id);
    list.innerHTML = "";
    values.forEach((value) => list.append(create("li", "", value)));
  }

  function renderEvidence() {
    const values = Object.entries(snapshot.source_artifacts).map(([label, path]) => {
      return pretty(label) + ": " + path;
    });
    renderList("evidence-refs", values);
  }

  renderHeader();
  renderBoard();
  renderReplay();
  renderList("non-claims", snapshot.non_claims);
  renderEvidence();
})();
"@
}

function New-R17KanbanMvp {
    param([string]$RepositoryRoot = $repoRoot)

    $snapshot = New-R17KanbanMvpSnapshot -RepositoryRoot $RepositoryRoot
    Write-R17KanbanMvpJsonFile -Path $script:SnapshotPath -InputObject $snapshot -RepositoryRoot $RepositoryRoot
    Write-R17KanbanMvpTextFile -Path "$($script:UiRoot)/kanban.js" -Value (ConvertTo-R17KanbanMvpJavaScript -Snapshot $snapshot) -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        SnapshotPath = $script:SnapshotPath
        IndexPath = "$($script:UiRoot)/index.html"
        StylesPath = "$($script:UiRoot)/styles.css"
        ScriptPath = "$($script:UiRoot)/kanban.js"
        LaneCount = $script:RequiredLanes.Count
        CardCount = @($snapshot.cards).Count
        SeedCardLane = $snapshot.cards[0].current_lane
        AggregateVerdict = $snapshot.replay_summary.aggregate_verdict
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Test-R17KanbanMvpLineHasNegation {
    param([string]$Text)

    return ($Text -match '(?i)\b(no|not|does not|do not|is not|are not|never|forbid|forbidden|reject|rejected|non-claim|non-claims|only)\b' -or $Text -match ':\s*false\b')
}

function Test-R17KanbanMvpTextHasNoForbiddenClaims {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Context = "text"
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        foreach ($rule in $script:ForbiddenClaimRules) {
            if ($line -match $rule.Pattern -and -not (Test-R17KanbanMvpLineHasNegation -Text $line)) {
                throw "$Context contains $($rule.Label). Offending text: $line"
            }
        }
    }
}

function Test-R17KanbanMvpTextHasNoExternalDependencyRefs {
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

function Get-R17KanbanMvpStringValues {
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
            $strings += Get-R17KanbanMvpStringValues -Value $Value[$key]
        }
        return $strings
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $strings += Get-R17KanbanMvpStringValues -Value $item
        }
        return $strings
    }

    if (@($Value.PSObject.Properties).Count -gt 0) {
        foreach ($property in $Value.PSObject.Properties) {
            $strings += Get-R17KanbanMvpStringValues -Value $property.Value
        }
    }

    return $strings
}

function Test-R17KanbanMvpSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        $Snapshot,
        [string]$Context = "R17-006 Kanban MVP snapshot"
    )

    foreach ($field in @("artifact_type", "contract_version", "source_task", "milestone", "branch", "active_through_task", "generated_from_head", "generated_from_tree", "ui_boundary_label", "source_artifacts", "canonical_truth", "lane_order", "lanes", "cards", "replay_summary", "non_claims", "evidence_refs")) {
        Assert-R17KanbanMvpHasProperty -Object $Snapshot -Name $field -Context $Context
    }

    if ($Snapshot.artifact_type -ne "r17_kanban_mvp_snapshot") {
        throw "$Context artifact_type must be r17_kanban_mvp_snapshot."
    }
    if ($Snapshot.source_task -ne "R17-006") {
        throw "$Context source_task must be R17-006."
    }
    if ($Snapshot.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($Snapshot.branch -ne $script:BranchName) {
        throw "$Context branch is incorrect."
    }
    if ($Snapshot.active_through_task -ne $script:ActiveThroughTask) {
        throw "$Context active_through_task must be R17-006."
    }
    if ($Snapshot.ui_boundary_label -notmatch '(?i)read-only Kanban MVP, not runtime') {
        throw "$Context must label the UI as read-only and not runtime."
    }

    Assert-R17KanbanMvpSha -Value $Snapshot.generated_from_head -Context "$Context generated_from_head"
    Assert-R17KanbanMvpSha -Value $Snapshot.generated_from_tree -Context "$Context generated_from_tree"

    $laneOrder = @(Assert-R17KanbanMvpArray -Value $Snapshot.lane_order -Context "$Context lane_order")
    Assert-R17KanbanMvpLaneOrder -LaneOrder $laneOrder -Context "$Context lane_order"

    $lanes = @(Assert-R17KanbanMvpArray -Value $Snapshot.lanes -Context "$Context lanes")
    if ($lanes.Count -ne $script:RequiredLanes.Count) {
        throw "$Context lanes must include one rendered lane per required lane."
    }
    foreach ($lane in $lanes) {
        Assert-R17KanbanMvpHasProperty -Object $lane -Name "id" -Context "$Context lane"
        Assert-R17KanbanMvpHasProperty -Object $lane -Name "card_count" -Context "$Context lane"
        if ($script:RequiredLanes -notcontains [string]$lane.id) {
            throw "$Context contains unexpected lane '$($lane.id)'."
        }
    }

    $cards = @(Assert-R17KanbanMvpArray -Value $Snapshot.cards -Context "$Context cards")
    $seedCards = @($cards | Where-Object { $_.card_id -eq "R17-005" })
    if ($seedCards.Count -ne 1) {
        throw "$Context must include exactly one R17-005 seed card."
    }
    $seedCard = $seedCards[0]
    foreach ($field in @("card_id", "task_id", "title", "current_lane", "owner_role", "current_agent", "status", "user_decision_required", "user_approval_required_for_closure", "evidence_ref_count", "memory_ref_count", "blocker_count")) {
        Assert-R17KanbanMvpHasProperty -Object $seedCard -Name $field -Context "$Context R17-005 card"
    }
    if ($seedCard.current_lane -ne "ready_for_user_review") {
        throw "$Context R17-005 seed card must be shown in ready_for_user_review."
    }
    if ($seedCard.user_decision_required -ne $true -or $seedCard.user_approval_required_for_closure -ne $true) {
        throw "$Context R17-005 seed card must show user decision and closure approval requirements."
    }
    if ([int]$seedCard.evidence_ref_count -lt 1 -or [int]$seedCard.memory_ref_count -lt 1) {
        throw "$Context R17-005 card must show evidence and memory ref counts."
    }

    $readyLane = @($lanes | Where-Object { $_.id -eq "ready_for_user_review" })[0]
    if ($null -eq $readyLane -or @($readyLane.cards).Count -ne 1 -or @($readyLane.cards) -notcontains "R17-005") {
        throw "$Context ready_for_user_review lane must render the R17-005 card."
    }

    $summary = $Snapshot.replay_summary
    foreach ($field in @("aggregate_verdict", "input_card_count", "input_event_count", "replayed_event_count", "rejected_event_count", "final_lane_by_card", "user_decisions_required", "unresolved_blockers")) {
        Assert-R17KanbanMvpHasProperty -Object $summary -Name $field -Context "$Context replay_summary"
    }
    if ($summary.aggregate_verdict -ne "generated_r17_board_state_store_candidate") {
        throw "$Context replay_summary aggregate_verdict is incorrect."
    }
    if ([int]$summary.input_card_count -ne 1 -or [int]$summary.input_event_count -ne 5 -or [int]$summary.replayed_event_count -ne 5 -or [int]$summary.rejected_event_count -ne 0) {
        throw "$Context replay_summary counts do not match R17-005 replay artifacts."
    }
    if ($summary.final_lane_by_card.PSObject.Properties.Name -notcontains "R17-005" -or $summary.final_lane_by_card."R17-005" -ne "ready_for_user_review") {
        throw "$Context replay_summary final lane for R17-005 must be ready_for_user_review."
    }
    if (@(Assert-R17KanbanMvpArray -Value $summary.user_decisions_required -Context "$Context replay_summary user_decisions_required").Count -lt 1) {
        throw "$Context replay_summary must show user decisions required."
    }
    if (@(Assert-R17KanbanMvpArray -Value $summary.unresolved_blockers -Context "$Context replay_summary unresolved_blockers" -AllowNullAsEmpty).Count -ne 0) {
        throw "$Context replay_summary unresolved blockers should be empty for R17-005."
    }

    Assert-R17KanbanMvpContains -Values ([string[]](Assert-R17KanbanMvpArray -Value $Snapshot.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"
    Assert-R17KanbanMvpContains -Values ([string[]](Assert-R17KanbanMvpArray -Value $Snapshot.evidence_refs -Context "$Context evidence_refs")) -Required $script:RequiredEvidenceRefs -Context "$Context evidence_refs"

    foreach ($field in @("live_board_mutation_implemented", "product_runtime_implemented", "production_runtime_implemented", "kanban_product_runtime_implemented", "orchestrator_runtime_implemented", "a2a_runtime_implemented", "autonomous_agents_implemented", "dev_codex_executor_adapter_runtime_implemented", "qa_test_agent_adapter_runtime_implemented", "evidence_auditor_api_runtime_implemented", "executable_handoffs_implemented", "executable_transitions_implemented", "external_integrations_implemented")) {
        Assert-R17KanbanMvpHasProperty -Object $Snapshot.canonical_truth -Name $field -Context "$Context canonical_truth"
        if ($Snapshot.canonical_truth.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context canonical_truth $field must be false."
        }
    }

    foreach ($stringValue in Get-R17KanbanMvpStringValues -Value $Snapshot) {
        Test-R17KanbanMvpTextHasNoForbiddenClaims -Text $stringValue -Context "$Context string value"
        Test-R17KanbanMvpTextHasNoExternalDependencyRefs -Text $stringValue -Context "$Context string value"
    }
}

function Test-R17KanbanMvpUiFiles {
    param([string]$RepositoryRoot = $repoRoot)

    foreach ($relativePath in @("$($script:UiRoot)/index.html", "$($script:UiRoot)/styles.css", "$($script:UiRoot)/kanban.js", "$($script:UiRoot)/README.md")) {
        $resolvedPath = Resolve-R17KanbanMvpPath -Path $relativePath -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            throw "UI file '$relativePath' does not exist."
        }

        $text = Get-Content -LiteralPath $resolvedPath -Raw
        Test-R17KanbanMvpTextHasNoExternalDependencyRefs -Text $text -Context $relativePath
        Test-R17KanbanMvpTextHasNoForbiddenClaims -Text $text -Context $relativePath
    }
}

function Test-R17KanbanMvp {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$SnapshotPath = $script:SnapshotPath
    )

    $snapshot = Read-R17KanbanMvpJsonFile -Path $SnapshotPath -RepositoryRoot $RepositoryRoot
    Test-R17KanbanMvpSnapshot -Snapshot $snapshot

    foreach ($evidenceRef in $script:RequiredEvidenceRefs) {
        $resolvedPath = Resolve-R17KanbanMvpPath -Path $evidenceRef -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            throw "Evidence ref '$evidenceRef' does not exist."
        }
    }

    $expectedSnapshot = New-R17KanbanMvpSnapshot -RepositoryRoot $RepositoryRoot -GeneratedFromHead $snapshot.generated_from_head -GeneratedFromTree $snapshot.generated_from_tree
    $expectedJson = $expectedSnapshot | ConvertTo-Json -Depth 100
    $actualJson = $snapshot | ConvertTo-Json -Depth 100
    if ($expectedJson -ne $actualJson) {
        throw "R17-006 Kanban snapshot does not match deterministic generation output."
    }

    Test-R17KanbanMvpUiFiles -RepositoryRoot $RepositoryRoot

    $expectedScript = ConvertTo-R17KanbanMvpJavaScript -Snapshot $snapshot
    $actualScript = Get-Content -LiteralPath (Resolve-R17KanbanMvpPath -Path "$($script:UiRoot)/kanban.js" -RepositoryRoot $RepositoryRoot) -Raw
    if ($expectedScript.TrimEnd() -ne $actualScript.TrimEnd()) {
        throw "R17-006 kanban.js does not match the embedded generated snapshot."
    }

    return [pscustomobject]@{
        SnapshotPath = $SnapshotPath
        LaneCount = @(Assert-R17KanbanMvpArray -Value $snapshot.lane_order -Context "snapshot lane_order").Count
        CardCount = @(Assert-R17KanbanMvpArray -Value $snapshot.cards -Context "snapshot cards").Count
        SeedCardLane = @($snapshot.cards | Where-Object { $_.card_id -eq "R17-005" })[0].current_lane
        AggregateVerdict = $snapshot.replay_summary.aggregate_verdict
        UserDecisionCount = @($snapshot.replay_summary.user_decisions_required).Count
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Get-R17KanbanMvpPaths {
    return [pscustomobject]@{
        UiRoot = $script:UiRoot
        SnapshotPath = $script:SnapshotPath
        IndexPath = "$($script:UiRoot)/index.html"
        StylesPath = "$($script:UiRoot)/styles.css"
        ScriptPath = "$($script:UiRoot)/kanban.js"
        ReadmePath = "$($script:UiRoot)/README.md"
    }
}

Export-ModuleMember -Function @(
    "Get-R17KanbanMvpPaths",
    "Read-R17KanbanMvpJsonFile",
    "New-R17KanbanMvpSnapshot",
    "ConvertTo-R17KanbanMvpJavaScript",
    "New-R17KanbanMvp",
    "Test-R17KanbanMvpSnapshot",
    "Test-R17KanbanMvpTextHasNoExternalDependencyRefs",
    "Test-R17KanbanMvpTextHasNoForbiddenClaims",
    "Test-R17KanbanMvpUiFiles",
    "Test-R17KanbanMvp"
)
