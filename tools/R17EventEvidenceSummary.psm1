Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:ActiveThroughTask = "R17-008"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:UiRoot = "scripts/operator_wall/r17_kanban_mvp"
$script:SnapshotPath = "state/ui/r17_kanban_mvp/r17_event_evidence_summary_snapshot.json"
$script:BoardStatePath = "$($script:BoardRoot)/r17_board_state.json"
$script:SeedCardPath = "$($script:BoardRoot)/cards/r17_005_seed_card.json"
$script:SeedEventsPath = "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
$script:ReplayReportPath = "$($script:BoardRoot)/r17_board_replay_report.json"
$script:KanbanSnapshotPath = "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json"
$script:CardDetailSnapshotPath = "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json"
$script:R17BoardContractsProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_004_board_contracts/"
$script:R17BoardStateStoreProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store/"
$script:R17KanbanMvpProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_006_kanban_mvp/"
$script:R17CardDetailProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_007_card_detail_evidence_drawer/"
$script:R17EventEvidenceSummaryProofReviewPath = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_008_event_evidence_summary/"
$script:FixtureRoot = "tests/fixtures/r17_event_evidence_summary/"

$script:RequiredEvidenceGroups = @(
    "board_state",
    "seed_card",
    "seed_event_log",
    "replay_report",
    "kanban_snapshot",
    "card_detail_snapshot",
    "proof_review_packages",
    "validation_manifests",
    "tooling",
    "tests",
    "fixtures"
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
    @{ Label = "live board mutation claim"; Pattern = '(?i)\b(live board mutation|runtime board mutation|live Kanban mutation)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "Orchestrator runtime claim"; Pattern = '(?i)\bOrchestrator runtime\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "A2A runtime claim"; Pattern = '(?i)\bA2A runtime\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "autonomous agent claim"; Pattern = '(?i)\b(autonomous agents|actual autonomous agents|true multi-agent execution|true multi-agent runtime|multi-agent runtime)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|working|available|ships|claimed)\b' },
    @{ Label = "Dev/Codex executor runtime claim"; Pattern = '(?i)\b(Dev/Codex executor adapter|Developer/Codex executor adapter|Dev/Codex adapter)\b.{0,180}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "QA/Test Agent adapter runtime claim"; Pattern = '(?i)\b(QA/Test Agent adapter|QA adapter|QA/Test Agent runtime)\b.{0,180}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "Evidence Auditor API runtime claim"; Pattern = '(?i)\b(Evidence Auditor API adapter|Evidence Auditor API runtime|Evidence Auditor API)\b.{0,180}\b(runtime|done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "executable handoff claim"; Pattern = '(?i)\b(executable handoff|executable handoffs)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "executable transition claim"; Pattern = '(?i)\b(executable transition|executable transitions)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "external integration claim"; Pattern = '(?i)\b(external integrations?|external API integration|external board sync)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|working|available|ships|claimed|exists)\b' },
    @{ Label = "external audit acceptance claim"; Pattern = '(?i)\b(external audit acceptance|external audit accepted|external acceptance)\b.{0,140}\b(done|complete|completed|accepted|approved|claimed|exists|achieved)\b' },
    @{ Label = "main merge claim"; Pattern = '(?i)\b(main merge|merged to main|main contains R17|R17.*merged to main)\b' },
    @{ Label = "product or production runtime claim"; Pattern = '(?i)\b(product runtime|production runtime|Kanban product runtime)\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|working|available|ships|claimed)\b' },
    @{ Label = "real Dev output claim"; Pattern = '(?i)\b(Dev output|Developer output|Codex output)\b.{0,160}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real)\b' },
    @{ Label = "real QA result claim"; Pattern = '(?i)\b(QA result|QA verdict|Test Agent result)\b.{0,160}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real|passed)\b' },
    @{ Label = "real audit verdict claim"; Pattern = '(?i)\b(audit verdict|Evidence Auditor verdict|external audit verdict)\b.{0,160}\b(done|complete|completed|implemented|produced|exists|working|available|claimed|real|passed|accepted)\b' },
    @{ Label = "R13 closure claim"; Pattern = '(?i)\bR13\b.{0,140}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b' },
    @{ Label = "R14 caveat removal claim"; Pattern = '(?i)\bR14\b.{0,140}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' },
    @{ Label = "R15 caveat removal claim"; Pattern = '(?i)\bR15\b.{0,140}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' },
    @{ Label = "solved Codex compaction claim"; Pattern = '(?i)\b(solved Codex compaction|solved Codex context compaction|Codex compaction solved)\b' },
    @{ Label = "solved Codex reliability claim"; Pattern = '(?i)\b(solved Codex reliability|Codex reliability solved)\b' }
)

function Resolve-R17EventEvidenceSummaryPath {
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

function Read-R17EventEvidenceSummaryJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17EventEvidenceSummaryPath -Path $Path -RepositoryRoot $RepositoryRoot
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

function Write-R17EventEvidenceSummaryTextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17EventEvidenceSummaryPath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $resolvedPath -Value $Value -Encoding UTF8
}

function Write-R17EventEvidenceSummaryJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $InputObject,
        [string]$RepositoryRoot = $repoRoot
    )

    Write-R17EventEvidenceSummaryTextFile -Path $Path -Value ($InputObject | ConvertTo-Json -Depth 100) -RepositoryRoot $RepositoryRoot
}

function Assert-R17EventEvidenceSummarySha {
    param($Value, [string]$Context)

    if ($Value -isnot [string] -or $Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character lowercase git SHA."
    }
}

function Assert-R17EventEvidenceSummaryHasProperty {
    param($Object, [string]$Name, [string]$Context)

    if ($null -eq $Object -or $Object.PSObject.Properties.Name -notcontains $Name) {
        throw "$Context is missing required field '$Name'."
    }
}

function Assert-R17EventEvidenceSummaryArray {
    param($Value, [string]$Context, [switch]$AllowNullAsEmpty)

    if ($null -eq $Value -and $AllowNullAsEmpty) {
        return @()
    }

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    return @($Value)
}

function Assert-R17EventEvidenceSummaryContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)

    foreach ($requiredValue in $Required) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Get-R17EventEvidenceSummaryGitIdentity {
    param([string]$RepositoryRoot = $repoRoot)

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD."
    }

    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD tree."
    }

    Assert-R17EventEvidenceSummarySha -Value $head -Context "generated_from_head"
    Assert-R17EventEvidenceSummarySha -Value $tree -Context "generated_from_tree"

    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function Read-R17EventEvidenceSummaryEventLog {
    param(
        [string]$Path = $script:SeedEventsPath,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17EventEvidenceSummaryPath -Path $Path -RepositoryRoot $RepositoryRoot
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

function Get-R17EventEvidenceSummaryFinalLane {
    param(
        [Parameter(Mandatory = $true)]
        $ReplayReport,
        [Parameter(Mandatory = $true)]
        [string]$CardId
    )

    Assert-R17EventEvidenceSummaryHasProperty -Object $ReplayReport -Name "final_lane_by_card" -Context "replay report"
    if ($ReplayReport.final_lane_by_card.PSObject.Properties.Name -notcontains $CardId) {
        throw "Replay report final_lane_by_card is missing '$CardId'."
    }

    return [string]$ReplayReport.final_lane_by_card.PSObject.Properties[$CardId].Value
}

function ConvertTo-R17EventEvidenceSummaryTimeline {
    param([object[]]$Events)

    $timeline = @()
    foreach ($event in $Events) {
        $timeline += [ordered]@{
            event_id = [string]$event.event_id
            event_type = [string]$event.event_type
            card_id = [string]$event.card_id
            actor_role = [string]$event.actor_role
            agent_id = [string]$event.agent_id
            from_lane = [string]$event.from_lane
            to_lane = [string]$event.to_lane
            transition_allowed = [bool]$event.transition_allowed
            user_approval_present = [bool]$event.user_approval_present
            input_ref = [string]$event.input_ref
            output_ref = [string]$event.output_ref
            evidence_refs = @(Assert-R17EventEvidenceSummaryArray -Value $event.evidence_refs -Context "event $($event.event_id) evidence_refs" -AllowNullAsEmpty)
            validation_refs = @(Assert-R17EventEvidenceSummaryArray -Value $event.validation_refs -Context "event $($event.event_id) validation_refs" -AllowNullAsEmpty)
            non_claims = @(Assert-R17EventEvidenceSummaryArray -Value $event.non_claims -Context "event $($event.event_id) non_claims" -AllowNullAsEmpty)
            rejected_claims = @(Assert-R17EventEvidenceSummaryArray -Value $event.rejected_claims -Context "event $($event.event_id) rejected_claims" -AllowNullAsEmpty)
        }
    }

    return $timeline
}

function Add-R17EventEvidenceSummaryUniqueRef {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Refs,
        [AllowEmptyString()]
        [string]$Ref
    )

    if (-not [string]::IsNullOrWhiteSpace($Ref) -and -not $Refs.Contains($Ref)) {
        $Refs.Add($Ref)
    }
}

function New-R17EventEvidenceSummaryEvidenceGroups {
    param([object[]]$Events)

    $toolingRefs = [System.Collections.Generic.List[string]]::new()
    $testRefs = [System.Collections.Generic.List[string]]::new()
    $validationRefs = [System.Collections.Generic.List[string]]::new()

    foreach ($event in $Events) {
        foreach ($evidenceRef in @(Assert-R17EventEvidenceSummaryArray -Value $event.evidence_refs -Context "event evidence_refs" -AllowNullAsEmpty)) {
            if ($evidenceRef -match '^tools/') {
                Add-R17EventEvidenceSummaryUniqueRef -Refs $toolingRefs -Ref ([string]$evidenceRef)
            }
            if ($evidenceRef -match '^tests/') {
                Add-R17EventEvidenceSummaryUniqueRef -Refs $testRefs -Ref ([string]$evidenceRef)
            }
        }

        foreach ($validationRef in @(Assert-R17EventEvidenceSummaryArray -Value $event.validation_refs -Context "event validation_refs" -AllowNullAsEmpty)) {
            Add-R17EventEvidenceSummaryUniqueRef -Refs $validationRefs -Ref ([string]$validationRef)
            if ($validationRef -match '^tools/') {
                Add-R17EventEvidenceSummaryUniqueRef -Refs $toolingRefs -Ref ([string]$validationRef)
            }
            if ($validationRef -match '^tests/') {
                Add-R17EventEvidenceSummaryUniqueRef -Refs $testRefs -Ref ([string]$validationRef)
            }
        }
    }

    foreach ($toolRef in @(
            "tools/R17BoardContracts.psm1",
            "tools/R17BoardStateStore.psm1",
            "tools/R17KanbanMvp.psm1",
            "tools/R17CardDetailDrawer.psm1",
            "tools/R17EventEvidenceSummary.psm1",
            "tools/new_r17_event_evidence_summary.ps1",
            "tools/validate_r17_event_evidence_summary.ps1"
        )) {
        Add-R17EventEvidenceSummaryUniqueRef -Refs $toolingRefs -Ref $toolRef
    }

    foreach ($testRef in @(
            "tests/test_r17_board_contracts.ps1",
            "tests/test_r17_board_state_store.ps1",
            "tests/test_r17_kanban_mvp.ps1",
            "tests/test_r17_card_detail_drawer.ps1",
            "tests/test_r17_event_evidence_summary.ps1"
        )) {
        Add-R17EventEvidenceSummaryUniqueRef -Refs $testRefs -Ref $testRef
    }

    foreach ($validationManifestRef in @(
            "$($script:R17BoardContractsProofReviewPath)validation_manifest.md",
            "$($script:R17BoardStateStoreProofReviewPath)validation_manifest.md",
            "$($script:R17KanbanMvpProofReviewPath)validation_manifest.md",
            "$($script:R17CardDetailProofReviewPath)validation_manifest.md",
            "$($script:R17EventEvidenceSummaryProofReviewPath)validation_manifest.md"
        )) {
        Add-R17EventEvidenceSummaryUniqueRef -Refs $validationRefs -Ref $validationManifestRef
    }

    return [ordered]@{
        board_state = @($script:BoardStatePath)
        seed_card = @($script:SeedCardPath)
        seed_event_log = @($script:SeedEventsPath)
        replay_report = @($script:ReplayReportPath)
        kanban_snapshot = @($script:KanbanSnapshotPath)
        card_detail_snapshot = @($script:CardDetailSnapshotPath)
        proof_review_packages = @(
            $script:R17BoardContractsProofReviewPath,
            $script:R17BoardStateStoreProofReviewPath,
            $script:R17KanbanMvpProofReviewPath,
            $script:R17CardDetailProofReviewPath,
            $script:R17EventEvidenceSummaryProofReviewPath
        )
        validation_manifests = @($validationRefs | Sort-Object)
        tooling = @($toolingRefs | Sort-Object)
        tests = @($testRefs | Sort-Object)
        fixtures = @($script:FixtureRoot)
    }
}

function Get-R17EventEvidenceSummaryFlatRefs {
    param([Parameter(Mandatory = $true)]$GroupedRefs)

    $refs = [System.Collections.Generic.List[string]]::new()
    foreach ($groupName in $script:RequiredEvidenceGroups) {
        $groupValue = $null
        if ($GroupedRefs -is [System.Collections.IDictionary]) {
            if (-not $GroupedRefs.Contains($groupName)) {
                continue
            }
            $groupValue = $GroupedRefs[$groupName]
        }
        elseif ($GroupedRefs.PSObject.Properties.Name -contains $groupName) {
            $groupValue = $GroupedRefs.PSObject.Properties[$groupName].Value
        }
        else {
            continue
        }

        foreach ($ref in @(Assert-R17EventEvidenceSummaryArray -Value $groupValue -Context "evidence group $groupName" -AllowNullAsEmpty)) {
            Add-R17EventEvidenceSummaryUniqueRef -Refs $refs -Ref ([string]$ref)
        }
    }

    return @($refs | Sort-Object)
}

function New-R17EventEvidenceSummarySnapshot {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$GeneratedFromHead = "",
        [string]$GeneratedFromTree = ""
    )

    if ([string]::IsNullOrWhiteSpace($GeneratedFromHead) -or [string]::IsNullOrWhiteSpace($GeneratedFromTree)) {
        $identity = Get-R17EventEvidenceSummaryGitIdentity -RepositoryRoot $RepositoryRoot
        $GeneratedFromHead = $identity.Head
        $GeneratedFromTree = $identity.Tree
    }

    Assert-R17EventEvidenceSummarySha -Value $GeneratedFromHead -Context "generated_from_head"
    Assert-R17EventEvidenceSummarySha -Value $GeneratedFromTree -Context "generated_from_tree"

    $boardState = Read-R17EventEvidenceSummaryJsonFile -Path $script:BoardStatePath -RepositoryRoot $RepositoryRoot
    $seedCard = Read-R17EventEvidenceSummaryJsonFile -Path $script:SeedCardPath -RepositoryRoot $RepositoryRoot
    $replayReport = Read-R17EventEvidenceSummaryJsonFile -Path $script:ReplayReportPath -RepositoryRoot $RepositoryRoot
    $kanbanSnapshot = Read-R17EventEvidenceSummaryJsonFile -Path $script:KanbanSnapshotPath -RepositoryRoot $RepositoryRoot
    $cardDetailSnapshot = Read-R17EventEvidenceSummaryJsonFile -Path $script:CardDetailSnapshotPath -RepositoryRoot $RepositoryRoot
    $events = @(Read-R17EventEvidenceSummaryEventLog -Path $script:SeedEventsPath -RepositoryRoot $RepositoryRoot)
    $eventTimeline = @(ConvertTo-R17EventEvidenceSummaryTimeline -Events $events)
    $groupedRefs = New-R17EventEvidenceSummaryEvidenceGroups -Events $events
    $flatRefs = @(Get-R17EventEvidenceSummaryFlatRefs -GroupedRefs $groupedRefs)
    $finalLane = Get-R17EventEvidenceSummaryFinalLane -ReplayReport $replayReport -CardId "R17-005"

    if ($seedCard.card_id -ne "R17-005" -or $finalLane -ne "ready_for_user_review") {
        throw "R17-008 event summary can inspect only the R17-005 seed card in ready_for_user_review."
    }

    if ($kanbanSnapshot.lane_order.Count -ne 13 -or $cardDetailSnapshot.selected_card_id -ne "R17-005") {
        throw "R17-008 requires the R17-006 Kanban snapshot and R17-007 card detail snapshot."
    }

    $finalLaneByCard = [ordered]@{}
    foreach ($property in $replayReport.final_lane_by_card.PSObject.Properties) {
        $finalLaneByCard[$property.Name] = [string]$property.Value
    }

    $transitionDecisions = @($eventTimeline | ForEach-Object {
            [ordered]@{
                event_id = $_.event_id
                from_lane = $_.from_lane
                to_lane = $_.to_lane
                transition_allowed = $_.transition_allowed
                user_approval_present = $_.user_approval_present
            }
        })

    $laneTransitionCount = @($eventTimeline | Where-Object { $_.from_lane -ne $_.to_lane -and $_.transition_allowed -eq $true }).Count
    $closedAttempted = (@($eventTimeline | Where-Object { $_.to_lane -eq "closed" -or $_.event_type -eq "closure_requested" }).Count -gt 0)

    return [ordered]@{
        artifact_type = "r17_event_evidence_summary_snapshot"
        contract_version = "v1"
        source_task = "R17-008"
        milestone = $script:MilestoneName
        branch = $script:BranchName
        active_through_task = $script:ActiveThroughTask
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        ui_boundary_label = "Read-only board event detail and evidence summary, not runtime"
        local_open_path = "$($script:UiRoot)/index.html"
        selected_card_id = "R17-005"
        inspectable_card_ids = @("R17-005")
        generated_from_artifacts = [ordered]@{
            board_state = $script:BoardStatePath
            seed_card = $script:SeedCardPath
            seed_event_log = $script:SeedEventsPath
            replay_report = $script:ReplayReportPath
            r17_006_kanban_ui_root = "$($script:UiRoot)/"
            r17_006_kanban_snapshot = $script:KanbanSnapshotPath
            r17_007_card_detail_snapshot = $script:CardDetailSnapshotPath
            r17_004_proof_review_package = $script:R17BoardContractsProofReviewPath
            r17_005_proof_review_package = $script:R17BoardStateStoreProofReviewPath
            r17_006_proof_review_package = $script:R17KanbanMvpProofReviewPath
            r17_007_proof_review_package = $script:R17CardDetailProofReviewPath
            r17_008_proof_review_package = $script:R17EventEvidenceSummaryProofReviewPath
        }
        static_ui_refs = @(
            "$($script:UiRoot)/index.html",
            "$($script:UiRoot)/styles.css",
            "$($script:UiRoot)/kanban.js",
            "$($script:UiRoot)/README.md"
        )
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
        replay_summary = [ordered]@{
            aggregate_verdict = [string]$replayReport.aggregate_verdict
            input_card_count = [int]$replayReport.input_card_count
            input_event_count = [int]$replayReport.input_event_count
            replayed_event_count = [int]$replayReport.replayed_event_count
            rejected_event_count = [int]$replayReport.rejected_event_count
            final_lane_by_card = $finalLaneByCard
            user_decisions_required = @(Assert-R17EventEvidenceSummaryArray -Value $replayReport.user_decisions_required -Context "replay user_decisions_required" -AllowNullAsEmpty)
            unresolved_blockers = @(Assert-R17EventEvidenceSummaryArray -Value $replayReport.unresolved_blockers -Context "replay unresolved_blockers" -AllowNullAsEmpty)
        }
        event_timeline = [ordered]@{
            event_count = $eventTimeline.Count
            events = $eventTimeline
        }
        evidence_summary = [ordered]@{
            total_evidence_ref_count = $flatRefs.Count
            grouped_refs = $groupedRefs
            missing_evidence_summary = [ordered]@{
                status = "none_recorded"
                items = @()
            }
            stale_evidence_summary = [ordered]@{
                status = "none_recorded"
                items = @()
            }
            generated_artifact_proof_policy = "Generated UI/report artifacts are operator-readable unless backed by validation evidence."
            generated_ui_report_artifacts_are_machine_proof_without_validation = $false
        }
        transition_summary = [ordered]@{
            lane_transition_count = $laneTransitionCount
            final_lane_for_seed_card = $finalLane
            closure_status = "not_closed_user_approval_required"
            user_approval_required_for_closure = [bool]$seedCard.user_approval_required_for_closure
            closed_was_attempted = $closedAttempted
            closure_blocked_or_pending_user_approval = $true
            closure_blocked_or_pending_user_approval_reason = "closure remains pending user approval; closed was not attempted"
            user_decision_state = [ordered]@{
                user_decision_required = [bool]$seedCard.user_decision_required
                user_decisions_required = @(Assert-R17EventEvidenceSummaryArray -Value $replayReport.user_decisions_required -Context "replay user_decisions_required" -AllowNullAsEmpty)
            }
            transition_decisions = $transitionDecisions
        }
        output_placeholders = [ordered]@{
            dev_output = [ordered]@{
                status = "not_implemented_in_r17_008"
                boundary = "placeholder only; no Dev/Codex executor adapter runtime and no real Dev output"
            }
            qa_result = [ordered]@{
                status = "not_implemented_in_r17_008"
                boundary = "placeholder only; no QA/Test Agent adapter runtime and no real QA result"
            }
            audit_verdict = [ordered]@{
                status = "not_implemented_in_r17_008"
                boundary = "placeholder only; no Evidence Auditor API runtime and no real audit verdict"
            }
        }
        boundary_and_non_claims = [ordered]@{
            statement = "R17-008 implements read-only local/static event and evidence inspection only."
            non_claims = $script:RequiredNonClaims
            rejected_claims = $script:RequiredRejectedClaims
        }
    }
}

function New-R17EventEvidenceSummary {
    param([string]$RepositoryRoot = $repoRoot)

    $snapshot = New-R17EventEvidenceSummarySnapshot -RepositoryRoot $RepositoryRoot
    Write-R17EventEvidenceSummaryJsonFile -Path $script:SnapshotPath -InputObject $snapshot -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        SnapshotPath = $script:SnapshotPath
        SelectedCardId = $snapshot.selected_card_id
        EventCount = [int]$snapshot.event_timeline.event_count
        EvidenceGroupCount = $script:RequiredEvidenceGroups.Count
        EvidenceRefCount = [int]$snapshot.evidence_summary.total_evidence_ref_count
        FinalLane = $snapshot.transition_summary.final_lane_for_seed_card
        UserDecisionRequired = [bool]$snapshot.transition_summary.user_decision_state.user_decision_required
        DevOutputPlaceholderStatus = $snapshot.output_placeholders.dev_output.status
        QaResultPlaceholderStatus = $snapshot.output_placeholders.qa_result.status
        AuditVerdictPlaceholderStatus = $snapshot.output_placeholders.audit_verdict.status
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Test-R17EventEvidenceSummaryLineHasNegation {
    param([string]$Text)

    return ($Text -match '(?i)\b(no|not|does not|do not|is not|are not|never|forbid|forbidden|reject|rejected|non-claim|non-claims|placeholder|only|unless|pending)\b' -or $Text -match ':\s*false\b')
}

function Test-R17EventEvidenceSummaryTextHasNoForbiddenClaims {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Context = "text"
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        foreach ($rule in $script:ForbiddenClaimRules) {
            if ($line -match $rule.Pattern -and -not (Test-R17EventEvidenceSummaryLineHasNegation -Text $line)) {
                throw "$Context contains $($rule.Label). Offending text: $line"
            }
        }
    }
}

function Test-R17EventEvidenceSummaryTextHasNoExternalDependencyRefs {
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

function Get-R17EventEvidenceSummaryStringValues {
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
            $strings += Get-R17EventEvidenceSummaryStringValues -Value $Value[$key]
        }
        return $strings
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            $strings += Get-R17EventEvidenceSummaryStringValues -Value $item
        }
        return $strings
    }

    if (@($Value.PSObject.Properties).Count -gt 0) {
        foreach ($property in $Value.PSObject.Properties) {
            $strings += Get-R17EventEvidenceSummaryStringValues -Value $property.Value
        }
    }

    return $strings
}

function Test-R17EventEvidenceSummarySnapshot {
    param(
        [Parameter(Mandatory = $true)]
        $Snapshot,
        [string]$Context = "R17-008 event evidence summary snapshot"
    )

    foreach ($field in @("artifact_type", "contract_version", "source_task", "milestone", "branch", "active_through_task", "generated_from_head", "generated_from_tree", "ui_boundary_label", "local_open_path", "selected_card_id", "inspectable_card_ids", "generated_from_artifacts", "canonical_truth", "replay_summary", "event_timeline", "evidence_summary", "transition_summary", "output_placeholders", "boundary_and_non_claims")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot -Name $field -Context $Context
    }

    if ($Snapshot.artifact_type -ne "r17_event_evidence_summary_snapshot") {
        throw "$Context artifact_type must be r17_event_evidence_summary_snapshot."
    }
    if ($Snapshot.source_task -ne "R17-008") {
        throw "$Context source_task must be R17-008."
    }
    if ($Snapshot.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($Snapshot.branch -ne $script:BranchName) {
        throw "$Context branch is incorrect."
    }
    if ($Snapshot.active_through_task -ne $script:ActiveThroughTask) {
        throw "$Context active_through_task must be R17-008."
    }
    if ($Snapshot.ui_boundary_label -notmatch '(?i)read-only board event detail and evidence summary, not runtime') {
        throw "$Context must label the surface as read-only and not runtime."
    }

    Assert-R17EventEvidenceSummarySha -Value $Snapshot.generated_from_head -Context "$Context generated_from_head"
    Assert-R17EventEvidenceSummarySha -Value $Snapshot.generated_from_tree -Context "$Context generated_from_tree"

    $inspectableCardIds = [string[]](Assert-R17EventEvidenceSummaryArray -Value $Snapshot.inspectable_card_ids -Context "$Context inspectable_card_ids")
    if ($Snapshot.selected_card_id -ne "R17-005" -or $inspectableCardIds.Count -ne 1 -or $inspectableCardIds[0] -ne "R17-005") {
        throw "$Context must allow inspection of exactly the R17-005 seed card."
    }

    foreach ($field in @("board_state", "seed_card", "seed_event_log", "replay_report", "r17_006_kanban_snapshot", "r17_007_card_detail_snapshot", "r17_004_proof_review_package", "r17_005_proof_review_package", "r17_006_proof_review_package", "r17_007_proof_review_package", "r17_008_proof_review_package")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.generated_from_artifacts -Name $field -Context "$Context generated_from_artifacts"
    }

    foreach ($field in @("live_board_mutation_implemented", "product_runtime_implemented", "production_runtime_implemented", "kanban_product_runtime_implemented", "orchestrator_runtime_implemented", "a2a_runtime_implemented", "autonomous_agents_implemented", "dev_codex_executor_adapter_runtime_implemented", "qa_test_agent_adapter_runtime_implemented", "evidence_auditor_api_runtime_implemented", "executable_handoffs_implemented", "executable_transitions_implemented", "external_integrations_implemented", "external_audit_acceptance_claimed", "main_merge_claimed")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.canonical_truth -Name $field -Context "$Context canonical_truth"
        if ($Snapshot.canonical_truth.PSObject.Properties[$field].Value -ne $false) {
            throw "$Context canonical_truth $field must be false."
        }
    }

    $summary = $Snapshot.replay_summary
    foreach ($field in @("aggregate_verdict", "input_card_count", "input_event_count", "replayed_event_count", "rejected_event_count", "final_lane_by_card", "user_decisions_required", "unresolved_blockers")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $summary -Name $field -Context "$Context replay_summary"
    }
    if ($summary.aggregate_verdict -ne "generated_r17_board_state_store_candidate") {
        throw "$Context replay_summary aggregate_verdict is incorrect."
    }
    if ([int]$summary.input_card_count -lt 1 -or [int]$summary.input_event_count -lt 1 -or [int]$summary.replayed_event_count -lt 1) {
        throw "$Context replay_summary counts must be present and non-empty."
    }
    if ($summary.final_lane_by_card.PSObject.Properties.Name -notcontains "R17-005" -or $summary.final_lane_by_card."R17-005" -ne "ready_for_user_review") {
        throw "$Context replay_summary final lane for R17-005 must be ready_for_user_review."
    }
    if (@(Assert-R17EventEvidenceSummaryArray -Value $summary.user_decisions_required -Context "$Context replay_summary user_decisions_required").Count -lt 1) {
        throw "$Context replay_summary must show user decisions required."
    }
    Assert-R17EventEvidenceSummaryArray -Value $summary.unresolved_blockers -Context "$Context replay_summary unresolved_blockers" -AllowNullAsEmpty | Out-Null

    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.event_timeline -Name "event_count" -Context "$Context event_timeline"
    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.event_timeline -Name "events" -Context "$Context event_timeline"
    $events = @(Assert-R17EventEvidenceSummaryArray -Value $Snapshot.event_timeline.events -Context "$Context event_timeline events")
    if ([int]$Snapshot.event_timeline.event_count -ne $events.Count -or $events.Count -lt 1) {
        throw "$Context must surface event timeline."
    }
    foreach ($event in $events) {
        foreach ($field in @("event_id", "event_type", "card_id", "actor_role", "agent_id", "from_lane", "to_lane", "transition_allowed", "user_approval_present", "input_ref", "output_ref", "evidence_refs", "validation_refs", "non_claims", "rejected_claims")) {
            Assert-R17EventEvidenceSummaryHasProperty -Object $event -Name $field -Context "$Context event"
        }
        if ([string]::IsNullOrWhiteSpace([string]$event.event_id)) { throw "$Context event is missing event_id." }
        if ([string]::IsNullOrWhiteSpace([string]$event.event_type)) { throw "$Context event is missing event_type." }
        if ([string]::IsNullOrWhiteSpace([string]$event.actor_role)) { throw "$Context event is missing actor_role." }
        if ($event.transition_allowed -isnot [bool]) { throw "$Context event transition_allowed must be boolean." }
        if (@(Assert-R17EventEvidenceSummaryArray -Value $event.evidence_refs -Context "$Context event evidence_refs" -AllowNullAsEmpty).Count -lt 1) {
            throw "$Context event must include evidence refs."
        }
        if (@(Assert-R17EventEvidenceSummaryArray -Value $event.validation_refs -Context "$Context event validation_refs" -AllowNullAsEmpty).Count -lt 1) {
            throw "$Context event must include validation refs."
        }
    }

    foreach ($field in @("total_evidence_ref_count", "grouped_refs", "missing_evidence_summary", "stale_evidence_summary", "generated_artifact_proof_policy", "generated_ui_report_artifacts_are_machine_proof_without_validation")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.evidence_summary -Name $field -Context "$Context evidence_summary"
    }
    foreach ($groupName in $script:RequiredEvidenceGroups) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.evidence_summary.grouped_refs -Name $groupName -Context "$Context evidence_summary grouped_refs"
        Assert-R17EventEvidenceSummaryArray -Value $Snapshot.evidence_summary.grouped_refs.PSObject.Properties[$groupName].Value -Context "$Context evidence group $groupName" -AllowNullAsEmpty | Out-Null
    }
    if ([int]$Snapshot.evidence_summary.total_evidence_ref_count -lt $script:RequiredEvidenceGroups.Count) {
        throw "$Context evidence_summary must count grouped evidence refs."
    }
    if ($Snapshot.evidence_summary.generated_ui_report_artifacts_are_machine_proof_without_validation -ne $false) {
        throw "$Context generated UI/report artifacts must not be treated as machine proof without validation."
    }
    if ($Snapshot.evidence_summary.generated_artifact_proof_policy -notmatch '(?i)operator-readable unless backed by validation evidence') {
        throw "$Context must state generated UI/report artifacts are operator-readable unless backed by validation evidence."
    }
    foreach ($summaryName in @("missing_evidence_summary", "stale_evidence_summary")) {
        $evidenceStatus = $Snapshot.evidence_summary.PSObject.Properties[$summaryName].Value
        foreach ($field in @("status", "items")) {
            Assert-R17EventEvidenceSummaryHasProperty -Object $evidenceStatus -Name $field -Context "$Context $summaryName"
        }
        Assert-R17EventEvidenceSummaryArray -Value $evidenceStatus.items -Context "$Context $summaryName items" -AllowNullAsEmpty | Out-Null
    }

    foreach ($field in @("lane_transition_count", "final_lane_for_seed_card", "closure_status", "user_approval_required_for_closure", "closed_was_attempted", "closure_blocked_or_pending_user_approval", "closure_blocked_or_pending_user_approval_reason", "user_decision_state", "transition_decisions")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.transition_summary -Name $field -Context "$Context transition_summary"
    }
    if ($Snapshot.transition_summary.final_lane_for_seed_card -ne "ready_for_user_review") {
        throw "$Context transition_summary final lane must be ready_for_user_review."
    }
    if ($Snapshot.transition_summary.user_approval_required_for_closure -ne $true -or $Snapshot.transition_summary.closure_blocked_or_pending_user_approval -ne $true) {
        throw "$Context transition_summary must show closure approval is required or pending."
    }
    if ($Snapshot.transition_summary.closed_was_attempted -ne $false) {
        throw "$Context transition_summary must show closed was not attempted."
    }
    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.transition_summary.user_decision_state -Name "user_decision_required" -Context "$Context user_decision_state"
    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.transition_summary.user_decision_state -Name "user_decisions_required" -Context "$Context user_decision_state"
    if ($Snapshot.transition_summary.user_decision_state.user_decision_required -ne $true -or @(Assert-R17EventEvidenceSummaryArray -Value $Snapshot.transition_summary.user_decision_state.user_decisions_required -Context "$Context user_decision_state user_decisions_required").Count -lt 1) {
        throw "$Context must surface user decision state."
    }

    foreach ($placeholderName in @("dev_output", "qa_result", "audit_verdict")) {
        Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.output_placeholders -Name $placeholderName -Context "$Context output_placeholders"
        $placeholder = $Snapshot.output_placeholders.PSObject.Properties[$placeholderName].Value
        Assert-R17EventEvidenceSummaryHasProperty -Object $placeholder -Name "status" -Context "$Context $placeholderName placeholder"
        if ($placeholder.status -ne "not_implemented_in_r17_008") {
            throw "$Context $placeholderName must be explicitly marked not_implemented_in_r17_008."
        }
    }

    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.boundary_and_non_claims -Name "non_claims" -Context "$Context boundary_and_non_claims"
    Assert-R17EventEvidenceSummaryHasProperty -Object $Snapshot.boundary_and_non_claims -Name "rejected_claims" -Context "$Context boundary_and_non_claims"
    Assert-R17EventEvidenceSummaryContains -Values ([string[]](Assert-R17EventEvidenceSummaryArray -Value $Snapshot.boundary_and_non_claims.non_claims -Context "$Context non_claims")) -Required $script:RequiredNonClaims -Context "$Context non_claims"
    Assert-R17EventEvidenceSummaryContains -Values ([string[]](Assert-R17EventEvidenceSummaryArray -Value $Snapshot.boundary_and_non_claims.rejected_claims -Context "$Context rejected_claims")) -Required $script:RequiredRejectedClaims -Context "$Context rejected_claims"

    foreach ($stringValue in Get-R17EventEvidenceSummaryStringValues -Value $Snapshot) {
        Test-R17EventEvidenceSummaryTextHasNoForbiddenClaims -Text $stringValue -Context "$Context string value"
        Test-R17EventEvidenceSummaryTextHasNoExternalDependencyRefs -Text $stringValue -Context "$Context string value"
    }
}

function Test-R17EventEvidenceSummaryUiFiles {
    param([string]$RepositoryRoot = $repoRoot)

    foreach ($relativePath in @("$($script:UiRoot)/index.html", "$($script:UiRoot)/styles.css", "$($script:UiRoot)/kanban.js", "$($script:UiRoot)/README.md")) {
        $resolvedPath = Resolve-R17EventEvidenceSummaryPath -Path $relativePath -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            throw "UI file '$relativePath' does not exist."
        }

        $text = Get-Content -LiteralPath $resolvedPath -Raw
        Test-R17EventEvidenceSummaryTextHasNoExternalDependencyRefs -Text $text -Context $relativePath
        Test-R17EventEvidenceSummaryTextHasNoForbiddenClaims -Text $text -Context $relativePath
    }

    $indexText = Get-Content -LiteralPath (Resolve-R17EventEvidenceSummaryPath -Path "$($script:UiRoot)/index.html" -RepositoryRoot $RepositoryRoot) -Raw
    foreach ($requiredFragment in @("event-evidence-summary", "Event Timeline", "Evidence Summary", "Transition Summary", "Missing Evidence", "Stale Evidence", "not_implemented_in_r17_008")) {
        if ($indexText -notmatch [regex]::Escape($requiredFragment)) {
            throw "index.html must expose the R17-008 event/evidence summary fragment '$requiredFragment'."
        }
    }
}

function Test-R17EventEvidenceSummary {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$SnapshotPath = $script:SnapshotPath
    )

    $snapshot = Read-R17EventEvidenceSummaryJsonFile -Path $SnapshotPath -RepositoryRoot $RepositoryRoot
    Test-R17EventEvidenceSummarySnapshot -Snapshot $snapshot

    $seedEvents = @(Read-R17EventEvidenceSummaryEventLog -Path $script:SeedEventsPath -RepositoryRoot $RepositoryRoot)
    $timelineEvents = @(Assert-R17EventEvidenceSummaryArray -Value $snapshot.event_timeline.events -Context "snapshot event_timeline events")
    if ($timelineEvents.Count -ne $seedEvents.Count) {
        throw "R17-008 event timeline must include every R17-005 seed event."
    }
    for ($index = 0; $index -lt $seedEvents.Count; $index++) {
        if ($timelineEvents[$index].event_id -ne $seedEvents[$index].event_id) {
            throw "R17-008 event timeline does not preserve seed event order at index $index."
        }
    }

    foreach ($evidenceRef in (Get-R17EventEvidenceSummaryFlatRefs -GroupedRefs $snapshot.evidence_summary.grouped_refs)) {
        $resolvedPath = Resolve-R17EventEvidenceSummaryPath -Path $evidenceRef -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            throw "Evidence ref '$evidenceRef' does not exist."
        }
    }

    $expectedSnapshot = New-R17EventEvidenceSummarySnapshot -RepositoryRoot $RepositoryRoot -GeneratedFromHead $snapshot.generated_from_head -GeneratedFromTree $snapshot.generated_from_tree
    $expectedJson = $expectedSnapshot | ConvertTo-Json -Depth 100
    $actualJson = $snapshot | ConvertTo-Json -Depth 100
    if ($expectedJson -ne $actualJson) {
        throw "R17-008 event/evidence summary snapshot does not match deterministic generation output."
    }

    Test-R17EventEvidenceSummaryUiFiles -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        SnapshotPath = $SnapshotPath
        SelectedCardId = $snapshot.selected_card_id
        EventCount = [int]$snapshot.event_timeline.event_count
        EvidenceGroupCount = $script:RequiredEvidenceGroups.Count
        EvidenceRefCount = [int]$snapshot.evidence_summary.total_evidence_ref_count
        TransitionCount = [int]$snapshot.transition_summary.lane_transition_count
        FinalLane = $snapshot.transition_summary.final_lane_for_seed_card
        UserDecisionRequired = [bool]$snapshot.transition_summary.user_decision_state.user_decision_required
        MissingEvidenceStatus = $snapshot.evidence_summary.missing_evidence_summary.status
        StaleEvidenceStatus = $snapshot.evidence_summary.stale_evidence_summary.status
        DevOutputPlaceholderStatus = $snapshot.output_placeholders.dev_output.status
        QaResultPlaceholderStatus = $snapshot.output_placeholders.qa_result.status
        AuditVerdictPlaceholderStatus = $snapshot.output_placeholders.audit_verdict.status
        GeneratedFromHead = $snapshot.generated_from_head
        GeneratedFromTree = $snapshot.generated_from_tree
    }
}

function Get-R17EventEvidenceSummaryPaths {
    return [pscustomobject]@{
        UiRoot = $script:UiRoot
        SnapshotPath = $script:SnapshotPath
        IndexPath = "$($script:UiRoot)/index.html"
        StylesPath = "$($script:UiRoot)/styles.css"
        ScriptPath = "$($script:UiRoot)/kanban.js"
        ReadmePath = "$($script:UiRoot)/README.md"
        ProofReviewPath = $script:R17EventEvidenceSummaryProofReviewPath
        FixtureRoot = $script:FixtureRoot
    }
}

Export-ModuleMember -Function @(
    "Get-R17EventEvidenceSummaryPaths",
    "Read-R17EventEvidenceSummaryJsonFile",
    "New-R17EventEvidenceSummarySnapshot",
    "New-R17EventEvidenceSummary",
    "Test-R17EventEvidenceSummarySnapshot",
    "Test-R17EventEvidenceSummaryTextHasNoExternalDependencyRefs",
    "Test-R17EventEvidenceSummaryTextHasNoForbiddenClaims",
    "Test-R17EventEvidenceSummaryUiFiles",
    "Test-R17EventEvidenceSummary"
)
