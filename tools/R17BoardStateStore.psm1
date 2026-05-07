Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$script:MilestoneName = "R17 Agentic Operating Surface, A2A Runtime, and Kanban Release Cycle"
$script:BranchName = "release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle"
$script:BoardId = "r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:BoardRoot = "state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle"
$script:ProofReviewRoot = "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_005_board_state_store"
$script:SeedCardPath = "$($script:BoardRoot)/cards/r17_005_seed_card.json"
$script:SeedEventsPath = "$($script:BoardRoot)/events/r17_005_seed_events.jsonl"
$script:BoardStatePath = "$($script:BoardRoot)/r17_board_state.json"
$script:ReplayReportPath = "$($script:BoardRoot)/r17_board_replay_report.json"

$script:R17NonClaims = @(
    "R17-005 implements bounded repo-backed board state store generation and deterministic event replay/check tooling only",
    "R17-005 does not implement Kanban UI",
    "R17-005 does not implement Orchestrator runtime",
    "R17-005 does not implement A2A runtime",
    "R17-005 does not implement Dev/Codex executor adapter",
    "R17-005 does not implement QA/Test Agent adapter",
    "R17-005 does not implement Evidence Auditor API adapter",
    "R17-005 does not call external APIs",
    "R17-005 does not call Codex as executor",
    "R17-005 does not claim autonomous agents",
    "R17-005 does not claim product runtime",
    "R17-005 does not claim executable handoffs",
    "R17-005 does not claim executable transitions",
    "R17-005 does not claim external audit acceptance",
    "R17-005 does not claim main merge",
    "R13 boundary preserved",
    "R14 caveats preserved",
    "R15 caveats preserved",
    "R16 boundary preserved",
    "R17-006 through R17-028 remain planned only",
    "R17-005 does not claim solved Codex compaction",
    "R17-005 does not claim solved Codex reliability"
)

$script:R17RejectedClaims = @(
    "external_audit_acceptance",
    "main_merge",
    "R13_closure",
    "R14_caveat_removal",
    "R15_caveat_removal",
    "R16_boundary_rewrite",
    "solved_Codex_compaction",
    "solved_Codex_reliability",
    "product_runtime",
    "Kanban_runtime",
    "Orchestrator_runtime",
    "autonomous_agents",
    "A2A_runtime",
    "executable_handoffs",
    "executable_transitions",
    "Dev_Codex_executor_adapter_runtime",
    "QA_Test_Agent_adapter_runtime",
    "Evidence_Auditor_API_adapter_runtime"
)

$script:ForbiddenClaimRules = @(
    @{ Claim = "product_runtime"; Patterns = @("product_runtime", "product runtime", "production runtime") },
    @{ Claim = "Kanban_runtime"; Patterns = @("kanban_runtime", "kanban runtime", "kanban product runtime") },
    @{ Claim = "A2A_runtime"; Patterns = @("a2a_runtime", "a2a runtime") },
    @{ Claim = "autonomous_agents"; Patterns = @("autonomous_agents", "autonomous agents", "actual autonomous agents", "true multi-agent execution") },
    @{ Claim = "executable_handoffs"; Patterns = @("executable_handoffs", "executable handoffs", "executable handoff") },
    @{ Claim = "executable_transitions"; Patterns = @("executable_transitions", "executable transitions", "executable transition") },
    @{ Claim = "Dev_Codex_executor_adapter_runtime"; Patterns = @("dev_codex_executor_adapter_runtime", "developer/codex executor adapter runtime", "dev/codex executor adapter runtime") },
    @{ Claim = "QA_Test_Agent_adapter_runtime"; Patterns = @("qa_test_agent_adapter_runtime", "qa/test agent adapter runtime", "qa adapter runtime") },
    @{ Claim = "Evidence_Auditor_API_adapter_runtime"; Patterns = @("evidence_auditor_api_adapter_runtime", "evidence auditor api adapter runtime", "evidence auditor api runtime") },
    @{ Claim = "external_audit_acceptance"; Patterns = @("external_audit_acceptance", "external audit acceptance", "external audit accepted") },
    @{ Claim = "main_merge"; Patterns = @("main_merge", "main merge", "merged to main") },
    @{ Claim = "solved_Codex_compaction"; Patterns = @("solved_codex_compaction", "solved codex compaction", "codex compaction solved") },
    @{ Claim = "solved_Codex_reliability"; Patterns = @("solved_codex_reliability", "solved codex reliability", "codex reliability solved") },
    @{ Claim = "R13_closure"; Patterns = @("r13_closure", "r13 closure", "r13 closed", "r13 is closed") },
    @{ Claim = "R14_caveat_removal"; Patterns = @("r14_caveat_removal", "r14 caveat removal", "r14 caveats removed", "r14 accepted without caveats") },
    @{ Claim = "R15_caveat_removal"; Patterns = @("r15_caveat_removal", "r15 caveat removal", "r15 caveats removed", "r15 accepted without caveats") },
    @{ Claim = "R16_boundary_rewrite"; Patterns = @("r16_boundary_rewrite", "r16 boundary rewrite", "rewrite r16", "r16 overclaim") }
)

function Resolve-R17BoardStorePath {
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

function ConvertTo-R17StableJson {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    return ($InputObject | ConvertTo-Json -Depth 100)
}

function Write-R17JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $InputObject,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17BoardStorePath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Set-Content -LiteralPath $resolvedPath -Value (ConvertTo-R17StableJson -InputObject $InputObject) -Encoding UTF8
}

function Read-R17BoardStoreJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17BoardStorePath -Path $Path -RepositoryRoot $RepositoryRoot
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

function Read-R17BoardEventLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17BoardStorePath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Board event log '$Path' does not exist."
    }

    $events = @()
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $resolvedPath)) {
        $lineNumber += 1
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        try {
            $events += ($line | ConvertFrom-Json)
        }
        catch {
            throw "Board event log '$Path' line $lineNumber could not be parsed. $($_.Exception.Message)"
        }
    }

    return $events
}

function Write-R17BoardEventLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [object[]]$Events,
        [string]$RepositoryRoot = $repoRoot
    )

    $resolvedPath = Resolve-R17BoardStorePath -Path $Path -RepositoryRoot $RepositoryRoot
    $directory = Split-Path -Parent $resolvedPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $lines = @($Events | ForEach-Object { $_ | ConvertTo-Json -Depth 100 -Compress })
    Set-Content -LiteralPath $resolvedPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
}

function Test-R17BoardStoreHasProperty {
    param($Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-R17BoardStoreRequiredProperty {
    param($Object, [string]$Name, [string]$Context)

    if (-not (Test-R17BoardStoreHasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Assert-R17BoardStoreNonEmptyString {
    param($Value, [string]$Context)

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }
}

function Assert-R17BoardStoreBoolean {
    param($Value, [string]$Context)

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }
}

function Assert-R17BoardStoreArray {
    param($Value, [string]$Context, [switch]$AllowNullAsEmpty)

    if ($null -eq $Value -and $AllowNullAsEmpty) {
        return @()
    }

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    return @($Value)
}

function Assert-R17BoardStoreContains {
    param([string[]]$Values, [string[]]$Required, [string]$Context)

    foreach ($requiredValue in $Required) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-R17BoardStoreExactSet {
    param([string[]]$Values, [string[]]$Expected, [string]$Context)

    $missing = @($Expected | Where-Object { $Values -notcontains $_ })
    $extra = @($Values | Where-Object { $Expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Context must exactly match expected values. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }
}

function Assert-R17BoardStoreAllowedValue {
    param($Value, [string[]]$AllowedValues, [string]$Context)

    if ($AllowedValues -notcontains [string]$Value) {
        throw "$Context value '$Value' is not allowed."
    }
}

function Assert-R17BoardStorePathExists {
    param([string]$Path, [string]$Context, [string]$RepositoryRoot = $repoRoot)

    Assert-R17BoardStoreNonEmptyString -Value $Path -Context $Context
    if ($Path -match '^\s*(\.|\.\\|\./|\*|\*\*|/|\\|repo|repository|full_repo|entire_repo)\s*$') {
        throw "$Context path '$Path' is unbounded."
    }

    $resolvedPath = Resolve-R17BoardStorePath -Path $Path -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "$Context path '$Path' does not exist."
    }
}

function Assert-R17BoardStoreSha {
    param($Value, [string]$Context)

    Assert-R17BoardStoreNonEmptyString -Value $Value -Context $Context
    if ($Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character lowercase git SHA."
    }
}

function Get-R17BoardStateStoreContracts {
    param([string]$RepositoryRoot = $repoRoot)

    $cardContract = Read-R17BoardStoreJsonFile -Path "contracts/board/r17_card.contract.json" -RepositoryRoot $RepositoryRoot
    $stateContract = Read-R17BoardStoreJsonFile -Path "contracts/board/r17_board_state.contract.json" -RepositoryRoot $RepositoryRoot
    $eventContract = Read-R17BoardStoreJsonFile -Path "contracts/board/r17_board_event.contract.json" -RepositoryRoot $RepositoryRoot

    if ($cardContract.source_task -ne "R17-004" -or $stateContract.source_task -ne "R17-004" -or $eventContract.source_task -ne "R17-004") {
        throw "R17-005 board state store must load the R17-004 board contracts."
    }

    return [pscustomobject]@{
        Card = $cardContract
        BoardState = $stateContract
        BoardEvent = $eventContract
    }
}

function Get-R17BoardStateStorePaths {
    return [pscustomobject]@{
        BoardRoot = $script:BoardRoot
        ProofReviewRoot = $script:ProofReviewRoot
        SeedCardPath = $script:SeedCardPath
        SeedEventsPath = $script:SeedEventsPath
        BoardStatePath = $script:BoardStatePath
        ReplayReportPath = $script:ReplayReportPath
    }
}

function Get-R17GitIdentity {
    param([string]$RepositoryRoot = $repoRoot)

    $head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD."
    }

    $tree = (& git -C $RepositoryRoot rev-parse "HEAD^{tree}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not resolve git HEAD tree."
    }

    Assert-R17BoardStoreSha -Value $head -Context "generated_from_head"
    Assert-R17BoardStoreSha -Value $tree -Context "generated_from_tree"
    return [pscustomobject]@{
        Head = $head
        Tree = $tree
    }
}

function New-R17BoardStateStoreSeedCard {
    return [ordered]@{
        artifact_type = "r17_board_card"
        contract_version = "v1"
        card_id = "R17-005"
        milestone = $script:MilestoneName
        task_id = "R17-005"
        title = "Implement bounded repo-backed board state store and deterministic replay checks"
        description = "R17-005 creates generated repo-backed board state artifacts plus deterministic event replay/check tooling using the R17-004 card, board-state, and board-event contracts. It is state-artifact generation only, not product runtime and not Kanban UI."
        double_diamond_stage = "develop"
        lane = "intake"
        owner_role = "operator"
        current_agent = "codex_local_repository_worker"
        status = "active"
        acceptance_criteria = @(
            "Create the bounded R17 board state folder and generated seed card, seed events, board state, and replay report artifacts.",
            "Replay seed events deterministically into the generated board state artifact.",
            "Validate card and event inputs against the R17-004 contract field shapes and R17-005 boundary rules.",
            "Reject unknown card, invalid lane, invalid role, closure without user approval, role-policy violations, runtime overclaims, external audit acceptance, main merge, solved Codex claims, and R13/R14/R15/R16 boundary rewrites.",
            "Keep R17-006 through R17-028 planned only and preserve all R17-005 non-claims."
        )
        qa_criteria = @(
            "The R17-004 board contract validator and tests still pass.",
            "The R17-005 board state store generator, validator, and focused tests pass.",
            "The status-doc gate continues to reject R17-006+ and runtime overclaims.",
            "The replay report aggregate verdict is generated_r17_board_state_store_candidate."
        )
        evidence_refs = @(
            "contracts/board/r17_card.contract.json",
            "contracts/board/r17_board_state.contract.json",
            "contracts/board/r17_board_event.contract.json",
            "tools/R17BoardContracts.psm1",
            "tools/R17BoardStateStore.psm1",
            "tools/new_r17_board_state_store.ps1",
            "tools/validate_r17_board_state_store.ps1",
            "tests/test_r17_board_contracts.ps1",
            "tests/test_r17_board_state_store.ps1",
            "$($script:ProofReviewRoot)/proof_review.md",
            "$($script:ProofReviewRoot)/evidence_index.json",
            "$($script:ProofReviewRoot)/validation_manifest.md"
        )
        memory_refs = @(
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
            "contracts/board/r17_card.contract.json",
            "contracts/board/r17_board_state.contract.json",
            "contracts/board/r17_board_event.contract.json"
        )
        task_packet_ref = "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md#r17-005-define-board-state-and-board-event-contracts"
        blocker_refs = @()
        user_decision_required = $true
        user_approval_required_for_closure = $true
        allowed_next_lanes = @("define", "ready_for_user_review", "blocked")
        forbidden_claims = $script:R17RejectedClaims
        non_claims = $script:R17NonClaims
        audit_log_refs = @(
            "$($script:ProofReviewRoot)/proof_review.md",
            "$($script:BoardRoot)/r17_board_replay_report.json"
        )
        created_by = "operator"
        updated_by = "codex"
        claims = [ordered]@{
            product_runtime_claimed = $false
            kanban_runtime_claimed = $false
            orchestrator_runtime_claimed = $false
            a2a_runtime_claimed = $false
            autonomous_agents_claimed = $false
            executable_handoffs_claimed = $false
            executable_transitions_claimed = $false
            external_audit_acceptance_claimed = $false
            main_merge_claimed = $false
            solved_codex_compaction_claimed = $false
            solved_codex_reliability_claimed = $false
        }
    }
}

function New-R17BoardStateStoreSeedEvents {
    $eventEvidenceRefs = @(
        "contracts/board/r17_card.contract.json",
        "contracts/board/r17_board_state.contract.json",
        "contracts/board/r17_board_event.contract.json",
        "tools/R17BoardStateStore.psm1",
        "tools/validate_r17_board_state_store.ps1",
        "$($script:ProofReviewRoot)/proof_review.md"
    )
    $eventValidationRefs = @(
        "tools/validate_r17_board_contracts.ps1",
        "tests/test_r17_board_contracts.ps1",
        "tools/validate_r17_board_state_store.ps1",
        "tests/test_r17_board_state_store.ps1"
    )

    $base = @{
        artifact_type = "r17_board_event"
        contract_version = "v1"
        card_id = "R17-005"
        agent_id = "repo_backed_board_state_store_generator"
        input_ref = $script:SeedCardPath
        output_ref = $script:SeedCardPath
        evidence_refs = $eventEvidenceRefs
        validation_refs = $eventValidationRefs
        user_approval_present = $false
        non_claims = $script:R17NonClaims
        rejected_claims = $script:R17RejectedClaims
    }

    return @(
        [ordered]@{
            artifact_type = $base.artifact_type
            contract_version = $base.contract_version
            event_id = "r17_005_event_001_card_created"
            card_id = $base.card_id
            event_type = "card_created"
            actor_role = "operator"
            agent_id = $base.agent_id
            from_lane = "intake"
            to_lane = "intake"
            timestamp_utc = "2026-05-08T00:00:01Z"
            input_ref = $base.input_ref
            output_ref = $base.output_ref
            evidence_refs = $base.evidence_refs
            validation_refs = $base.validation_refs
            transition_allowed = $true
            user_approval_present = $base.user_approval_present
            non_claims = $base.non_claims
            rejected_claims = $base.rejected_claims
        },
        [ordered]@{
            artifact_type = $base.artifact_type
            contract_version = $base.contract_version
            event_id = "r17_005_event_002_lane_transition_requested"
            card_id = $base.card_id
            event_type = "lane_transition_requested"
            actor_role = "project_manager"
            agent_id = $base.agent_id
            from_lane = "intake"
            to_lane = "define"
            timestamp_utc = "2026-05-08T00:00:02Z"
            input_ref = $base.input_ref
            output_ref = $base.output_ref
            evidence_refs = $base.evidence_refs
            validation_refs = $base.validation_refs
            transition_allowed = $true
            user_approval_present = $base.user_approval_present
            non_claims = $base.non_claims
            rejected_claims = $base.rejected_claims
        },
        [ordered]@{
            artifact_type = $base.artifact_type
            contract_version = $base.contract_version
            event_id = "r17_005_event_003_card_updated"
            card_id = $base.card_id
            event_type = "card_updated"
            actor_role = "operator"
            agent_id = $base.agent_id
            from_lane = "define"
            to_lane = "define"
            timestamp_utc = "2026-05-08T00:00:03Z"
            input_ref = $base.input_ref
            output_ref = $base.output_ref
            evidence_refs = $base.evidence_refs
            validation_refs = $base.validation_refs
            transition_allowed = $true
            user_approval_present = $base.user_approval_present
            non_claims = $base.non_claims
            rejected_claims = $base.rejected_claims
        },
        [ordered]@{
            artifact_type = $base.artifact_type
            contract_version = $base.contract_version
            event_id = "r17_005_event_004_ready_for_user_review"
            card_id = $base.card_id
            event_type = "lane_transition_requested"
            actor_role = "release_closeout"
            agent_id = $base.agent_id
            from_lane = "define"
            to_lane = "ready_for_user_review"
            timestamp_utc = "2026-05-08T00:00:04Z"
            input_ref = $base.input_ref
            output_ref = $base.output_ref
            evidence_refs = $base.evidence_refs
            validation_refs = $base.validation_refs
            transition_allowed = $true
            user_approval_present = $base.user_approval_present
            non_claims = $base.non_claims
            rejected_claims = $base.rejected_claims
        },
        [ordered]@{
            artifact_type = $base.artifact_type
            contract_version = $base.contract_version
            event_id = "r17_005_event_005_user_decision_requested"
            card_id = $base.card_id
            event_type = "user_decision_requested"
            actor_role = "release_closeout"
            agent_id = $base.agent_id
            from_lane = "ready_for_user_review"
            to_lane = "ready_for_user_review"
            timestamp_utc = "2026-05-08T00:00:05Z"
            input_ref = $base.input_ref
            output_ref = $base.output_ref
            evidence_refs = $base.evidence_refs
            validation_refs = $base.validation_refs
            transition_allowed = $false
            user_approval_present = $base.user_approval_present
            non_claims = $base.non_claims
            rejected_claims = $base.rejected_claims
        }
    )
}

function Get-R17BoardStoreClaimInputs {
    param($BoardEvent)

    $claimInputs = @()
    foreach ($field in @("claims", "claim", "claim_text", "assertion", "action", "notes")) {
        if (Test-R17BoardStoreHasProperty -Object $BoardEvent -Name $field) {
            $value = $BoardEvent.PSObject.Properties[$field].Value
            if ($null -eq $value) {
                continue
            }
            if ($value -is [string]) {
                $claimInputs += $value
            }
            elseif ($value -is [System.Collections.IDictionary]) {
                foreach ($key in $value.Keys) {
                    $claimInputs += [string]$key
                    $claimInputs += [string]$value[$key]
                }
            }
            elseif ($value -is [System.Collections.IEnumerable]) {
                foreach ($entry in @($value)) {
                    $claimInputs += [string]$entry
                }
            }
            elseif ($value.PSObject.Properties.Name.Count -gt 0) {
                foreach ($property in $value.PSObject.Properties) {
                    $claimInputs += [string]$property.Name
                    $claimInputs += [string]$property.Value
                }
            }
            else {
                $claimInputs += [string]$value
            }
        }
    }

    return @($claimInputs | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-R17BoardEventClaims {
    param(
        [Parameter(Mandatory = $true)]
        $BoardEvent,
        [string]$Context = "R17 board event"
    )

    $claimInputs = @(Get-R17BoardStoreClaimInputs -BoardEvent $BoardEvent)
    if ($claimInputs.Count -eq 0) {
        return
    }

    $claimText = ([string]::Join(" ", $claimInputs)).ToLowerInvariant()

    foreach ($rule in $script:ForbiddenClaimRules) {
        foreach ($pattern in $rule.Patterns) {
            if ($claimText.Contains($pattern.ToLowerInvariant())) {
                throw "$Context claims forbidden boundary '$($rule.Claim)'."
            }
        }
    }

    if ($BoardEvent.actor_role -eq "qa" -and $claimText -match '\bimplement') {
        throw "$Context violates role policy: QA implements."
    }
    if ($BoardEvent.actor_role -eq "developer" -and ($claimText -match 'approve.*evidence|evidence.*sufficien|approves_evidence')) {
        throw "$Context violates role policy: Developer approves evidence sufficiency."
    }
    if ($BoardEvent.actor_role -eq "evidence_auditor" -and $claimText -match '\bimplement') {
        throw "$Context violates role policy: Auditor implements."
    }
    if ($BoardEvent.actor_role -eq "orchestrator" -and $claimText -match 'bypass.*(qa|audit)|(qa|audit).*bypass') {
        throw "$Context violates transition policy: Orchestrator bypasses QA/audit gates."
    }
}

function Test-R17BoardStateStoreCard {
    param(
        [Parameter(Mandatory = $true)]
        $Card,
        [Parameter(Mandatory = $true)]
        $Contracts,
        [string]$Context = "R17-005 seed card",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in @(Assert-R17BoardStoreArray -Value $Contracts.Card.required_card_fields -Context "card contract required_card_fields")) {
        Get-R17BoardStoreRequiredProperty -Object $Card -Name ([string]$field) -Context $Context | Out-Null
    }

    if ($Card.artifact_type -ne "r17_board_card") {
        throw "$Context artifact_type must be r17_board_card."
    }
    if ($Card.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }
    if ($Card.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($Card.task_id -ne "R17-005") {
        throw "$Context task_id must be R17-005."
    }
    if ($Card.user_approval_required_for_closure -ne $true) {
        throw "$Context must require user approval for closure."
    }

    foreach ($field in @("card_id", "title", "description", "current_agent", "status", "created_by", "updated_by")) {
        Assert-R17BoardStoreNonEmptyString -Value (Get-R17BoardStoreRequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field"
    }

    Assert-R17BoardStoreAllowedValue -Value $Card.double_diamond_stage -AllowedValues ([string[]]$Contracts.Card.allowed_double_diamond_stages) -Context "$Context double_diamond_stage"
    Assert-R17BoardStoreAllowedValue -Value $Card.lane -AllowedValues ([string[]]$Contracts.Card.allowed_lanes) -Context "$Context lane"
    Assert-R17BoardStoreAllowedValue -Value $Card.owner_role -AllowedValues ([string[]]$Contracts.Card.allowed_owner_roles) -Context "$Context owner_role"
    Assert-R17BoardStoreAllowedValue -Value $Card.status -AllowedValues ([string[]]$Contracts.Card.allowed_statuses) -Context "$Context status"

    foreach ($field in @("user_decision_required", "user_approval_required_for_closure")) {
        Assert-R17BoardStoreBoolean -Value (Get-R17BoardStoreRequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field"
    }

    foreach ($field in @("acceptance_criteria", "qa_criteria", "evidence_refs", "memory_refs", "allowed_next_lanes", "forbidden_claims", "non_claims")) {
        $values = @(Assert-R17BoardStoreArray -Value (Get-R17BoardStoreRequiredProperty -Object $Card -Name $field -Context $Context) -Context "$Context $field")
        if ($values.Count -eq 0) {
            throw "$Context $field must not be empty."
        }
    }

    foreach ($lane in @(Assert-R17BoardStoreArray -Value $Card.allowed_next_lanes -Context "$Context allowed_next_lanes")) {
        Assert-R17BoardStoreAllowedValue -Value $lane -AllowedValues ([string[]]$Contracts.Card.allowed_lanes) -Context "$Context allowed_next_lanes"
    }

    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $Card.non_claims -Context "$Context non_claims")) -Required $script:R17NonClaims -Context "$Context non_claims"
    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $Card.forbidden_claims -Context "$Context forbidden_claims")) -Required $script:R17RejectedClaims -Context "$Context forbidden_claims"

    foreach ($evidenceRef in @(Assert-R17BoardStoreArray -Value $Card.evidence_refs -Context "$Context evidence_refs")) {
        Assert-R17BoardStorePathExists -Path ([string]$evidenceRef) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot
    }
    foreach ($memoryRef in @(Assert-R17BoardStoreArray -Value $Card.memory_refs -Context "$Context memory_refs")) {
        Assert-R17BoardStorePathExists -Path ([string]$memoryRef) -Context "$Context memory_refs" -RepositoryRoot $RepositoryRoot
        if ($memoryRef -notmatch '^(governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE\.md|contracts/board/r17_(card|board_state|board_event)\.contract\.json)$') {
            throw "$Context memory ref '$memoryRef' is outside exact R17 authority/contract refs."
        }
    }

    if (Test-R17BoardStoreHasProperty -Object $Card -Name "claims") {
        foreach ($property in $Card.claims.PSObject.Properties) {
            Assert-R17BoardStoreBoolean -Value $property.Value -Context "$Context claims $($property.Name)"
            if ($property.Value -ne $false) {
                throw "$Context forbidden claim '$($property.Name)' must be false."
            }
        }
    }

    return [pscustomobject]@{
        CardId = $Card.card_id
        Lane = $Card.lane
        TaskId = $Card.task_id
    }
}

function Test-R17BoardStateStoreEvent {
    param(
        [Parameter(Mandatory = $true)]
        $BoardEvent,
        [Parameter(Mandatory = $true)]
        $Contracts,
        [hashtable]$KnownCards = @{},
        [string]$Context = "R17-005 board event",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in @(Assert-R17BoardStoreArray -Value $Contracts.BoardEvent.required_board_event_fields -Context "board event contract required_board_event_fields")) {
        Get-R17BoardStoreRequiredProperty -Object $BoardEvent -Name ([string]$field) -Context $Context | Out-Null
    }

    if ($BoardEvent.artifact_type -ne "r17_board_event") {
        throw "$Context artifact_type must be r17_board_event."
    }
    if ($BoardEvent.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }
    foreach ($field in @("event_id", "card_id", "agent_id", "input_ref", "output_ref")) {
        Assert-R17BoardStoreNonEmptyString -Value (Get-R17BoardStoreRequiredProperty -Object $BoardEvent -Name $field -Context $Context) -Context "$Context $field"
    }

    if ($KnownCards.Count -gt 0 -and -not $KnownCards.ContainsKey([string]$BoardEvent.card_id)) {
        throw "$Context references unknown card '$($BoardEvent.card_id)'."
    }

    Assert-R17BoardStoreAllowedValue -Value $BoardEvent.event_type -AllowedValues ([string[]]$Contracts.BoardEvent.allowed_event_types) -Context "$Context event_type"
    Assert-R17BoardStoreAllowedValue -Value $BoardEvent.actor_role -AllowedValues ([string[]]$Contracts.BoardEvent.allowed_actor_roles) -Context "$Context actor_role"
    Assert-R17BoardStoreAllowedValue -Value $BoardEvent.from_lane -AllowedValues ([string[]]$Contracts.BoardEvent.allowed_lanes) -Context "$Context from_lane"
    Assert-R17BoardStoreAllowedValue -Value $BoardEvent.to_lane -AllowedValues ([string[]]$Contracts.BoardEvent.allowed_lanes) -Context "$Context to_lane"
    Assert-R17BoardStoreBoolean -Value $BoardEvent.transition_allowed -Context "$Context transition_allowed"
    Assert-R17BoardStoreBoolean -Value $BoardEvent.user_approval_present -Context "$Context user_approval_present"

    if ($BoardEvent.timestamp_utc -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
        throw "$Context timestamp_utc must be an ISO UTC timestamp ending in Z."
    }
    [datetime]::ParseExact($BoardEvent.timestamp_utc, "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal) | Out-Null

    Assert-R17BoardStorePathExists -Path $BoardEvent.input_ref -Context "$Context input_ref" -RepositoryRoot $RepositoryRoot
    Assert-R17BoardStorePathExists -Path $BoardEvent.output_ref -Context "$Context output_ref" -RepositoryRoot $RepositoryRoot
    foreach ($ref in @(Assert-R17BoardStoreArray -Value $BoardEvent.evidence_refs -Context "$Context evidence_refs")) {
        Assert-R17BoardStorePathExists -Path ([string]$ref) -Context "$Context evidence_refs" -RepositoryRoot $RepositoryRoot
    }
    foreach ($ref in @(Assert-R17BoardStoreArray -Value $BoardEvent.validation_refs -Context "$Context validation_refs")) {
        Assert-R17BoardStorePathExists -Path ([string]$ref) -Context "$Context validation_refs" -RepositoryRoot $RepositoryRoot
    }

    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $BoardEvent.non_claims -Context "$Context non_claims")) -Required $script:R17NonClaims -Context "$Context non_claims"
    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $BoardEvent.rejected_claims -Context "$Context rejected_claims")) -Required $script:R17RejectedClaims -Context "$Context rejected_claims"

    if ($BoardEvent.to_lane -eq "closed" -and $BoardEvent.transition_allowed -eq $true -and $BoardEvent.user_approval_present -ne $true) {
        throw "$Context moves to closed without user approval."
    }

    Test-R17BoardEventClaims -BoardEvent $BoardEvent -Context $Context

    return [pscustomobject]@{
        EventId = $BoardEvent.event_id
        CardId = $BoardEvent.card_id
        EventType = $BoardEvent.event_type
        TransitionAllowed = $BoardEvent.transition_allowed
    }
}

function New-R17LanePolicies {
    param([string[]]$LaneOrder)

    $policies = [ordered]@{}
    for ($index = 0; $index -lt $LaneOrder.Count; $index++) {
        $lane = $LaneOrder[$index]
        $policies[$lane] = [ordered]@{
            lane = $lane
            order = $index
            repo_backed_state_artifact_only = $true
            runtime_lane_movement_implemented = $false
            closure_requires_user_approval = ($lane -eq "closed")
        }
    }

    return $policies
}

function New-R17RolePermissions {
    return [ordered]@{
        qa = [ordered]@{
            can_implement = $false
        }
        developer = [ordered]@{
            can_approve_evidence_sufficiency = $false
        }
        evidence_auditor = [ordered]@{
            can_implement = $false
        }
        orchestrator = [ordered]@{
            can_bypass_qa_gate = $false
            can_bypass_audit_gate = $false
        }
    }
}

function New-R17TransitionPolicies {
    return [ordered]@{
        closed_requires_user_approval = $true
        repo_truth_remains_canonical = $true
        board_state_replaces_repo_truth = $false
        runtime_transitions_implemented_in_r17_005 = $false
        executable_transitions_implemented = $false
        a2a_runtime_implemented_in_r17_005 = $false
        kanban_runtime_implemented_in_r17_005 = $false
        product_runtime_implemented_in_r17_005 = $false
        deterministic_replay_checks_only = $true
        orchestrator_must_not_bypass_qa_or_audit = $true
    }
}

function Invoke-R17BoardEventReplay {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Cards,
        [Parameter(Mandatory = $true)]
        [object[]]$Events,
        [string]$GeneratedFromHead,
        [string]$GeneratedFromTree,
        [string]$RepositoryRoot = $repoRoot
    )

    $contracts = Get-R17BoardStateStoreContracts -RepositoryRoot $RepositoryRoot
    if ([string]::IsNullOrWhiteSpace($GeneratedFromHead) -or [string]::IsNullOrWhiteSpace($GeneratedFromTree)) {
        $identity = Get-R17GitIdentity -RepositoryRoot $RepositoryRoot
        $GeneratedFromHead = $identity.Head
        $GeneratedFromTree = $identity.Tree
    }

    Assert-R17BoardStoreSha -Value $GeneratedFromHead -Context "generated_from_head"
    Assert-R17BoardStoreSha -Value $GeneratedFromTree -Context "generated_from_tree"

    $cardIndex = @{}
    $laneByCard = @{}
    foreach ($card in $Cards) {
        Test-R17BoardStateStoreCard -Card $card -Contracts $contracts -RepositoryRoot $RepositoryRoot | Out-Null
        if ($cardIndex.ContainsKey([string]$card.card_id)) {
            throw "Duplicate card '$($card.card_id)' is not allowed."
        }
        $cardIndex[[string]$card.card_id] = $card
        $laneByCard[[string]$card.card_id] = [string]$card.lane
    }

    $replayedEventCount = 0
    $userDecisionsRequired = @()
    foreach ($event in $Events) {
        Test-R17BoardStateStoreEvent -BoardEvent $event -Contracts $contracts -KnownCards $cardIndex -RepositoryRoot $RepositoryRoot | Out-Null
        $cardId = [string]$event.card_id
        $currentLane = [string]$laneByCard[$cardId]
        if ($event.from_lane -ne $currentLane) {
            throw "Event '$($event.event_id)' from_lane '$($event.from_lane)' does not match current lane '$currentLane' for card '$cardId'."
        }

        if ($event.transition_allowed -eq $true) {
            $laneByCard[$cardId] = [string]$event.to_lane
        }

        if ($event.event_type -eq "user_decision_requested" -or $event.to_lane -eq "ready_for_user_review") {
            if (-not ($userDecisionsRequired | Where-Object { $_.card_id -eq $cardId })) {
                $userDecisionsRequired += [ordered]@{
                    card_id = $cardId
                    task_id = $cardIndex[$cardId].task_id
                    decision = "user approval required before closure"
                    requested_by_event_id = $event.event_id
                }
            }
        }

        $replayedEventCount += 1
    }

    $cardRefs = @()
    foreach ($cardId in @($cardIndex.Keys | Sort-Object)) {
        $cardRefs += [ordered]@{
            card_id = $cardId
            task_id = $cardIndex[$cardId].task_id
            path = $script:SeedCardPath
            lane = $laneByCard[$cardId]
            status = if ($laneByCard[$cardId] -eq "ready_for_user_review") { "ready_for_user_review" } else { $cardIndex[$cardId].status }
            user_approval_required_for_closure = $cardIndex[$cardId].user_approval_required_for_closure
        }
    }

    $laneOrder = [string[]](Assert-R17BoardStoreArray -Value $contracts.BoardState.allowed_lanes -Context "board state allowed_lanes")
    $finalLaneByCard = [ordered]@{}
    foreach ($cardId in @($cardIndex.Keys | Sort-Object)) {
        $finalLaneByCard[$cardId] = $laneByCard[$cardId]
    }

    $boardState = [ordered]@{
        artifact_type = "r17_board_state"
        contract_version = "v1"
        board_id = $script:BoardId
        milestone = $script:MilestoneName
        branch = $script:BranchName
        active_through_task = "R17-005"
        canonical_truth = [ordered]@{
            repo_truth_is_canonical = $true
            board_state_replaces_repo_truth = $false
            repo_backed_generated_state_artifact_only = $true
            product_runtime_implemented = $false
            kanban_runtime_implemented = $false
            orchestrator_runtime_implemented = $false
            a2a_runtime_implemented = $false
        }
        card_refs = $cardRefs
        lane_order = $laneOrder
        lane_policies = New-R17LanePolicies -LaneOrder $laneOrder
        role_permissions = New-R17RolePermissions
        transition_policies = New-R17TransitionPolicies
        unresolved_blockers = @()
        user_decisions_required = $userDecisionsRequired
        non_claims = $script:R17NonClaims
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
    }

    $report = [ordered]@{
        artifact_type = "r17_board_replay_report"
        contract_version = "v1"
        generated_from_head = $GeneratedFromHead
        generated_from_tree = $GeneratedFromTree
        board_id = $script:BoardId
        input_card_count = $Cards.Count
        input_event_count = $Events.Count
        replayed_event_count = $replayedEventCount
        rejected_event_count = 0
        final_lane_by_card = $finalLaneByCard
        user_decisions_required = $userDecisionsRequired
        unresolved_blockers = @()
        non_claims = $script:R17NonClaims
        rejected_claims = $script:R17RejectedClaims
        aggregate_verdict = "generated_r17_board_state_store_candidate"
    }

    return [pscustomobject]@{
        BoardState = $boardState
        ReplayReport = $report
    }
}

function Test-R17BoardStateStoreBoardState {
    param(
        [Parameter(Mandatory = $true)]
        $BoardState,
        [Parameter(Mandatory = $true)]
        $Contracts,
        [string]$Context = "R17-005 board state",
        [string]$RepositoryRoot = $repoRoot
    )

    foreach ($field in @(Assert-R17BoardStoreArray -Value $Contracts.BoardState.required_board_state_fields -Context "board state contract required_board_state_fields")) {
        Get-R17BoardStoreRequiredProperty -Object $BoardState -Name ([string]$field) -Context $Context | Out-Null
    }

    if ($BoardState.artifact_type -ne "r17_board_state") {
        throw "$Context artifact_type must be r17_board_state."
    }
    if ($BoardState.contract_version -ne "v1") {
        throw "$Context contract_version must be v1."
    }
    if ($BoardState.board_id -ne $script:BoardId) {
        throw "$Context board_id is incorrect."
    }
    if ($BoardState.milestone -ne $script:MilestoneName) {
        throw "$Context milestone is incorrect."
    }
    if ($BoardState.branch -ne $script:BranchName) {
        throw "$Context branch is incorrect."
    }
    if ($BoardState.active_through_task -ne "R17-005") {
        throw "$Context active_through_task must be R17-005."
    }

    if ($BoardState.canonical_truth.repo_truth_is_canonical -ne $true) {
        throw "$Context canonical truth must keep repo truth canonical."
    }
    if ($BoardState.canonical_truth.board_state_replaces_repo_truth -ne $false) {
        throw "$Context must not replace repo truth."
    }
    foreach ($runtimeField in @("product_runtime_implemented", "kanban_runtime_implemented", "orchestrator_runtime_implemented", "a2a_runtime_implemented")) {
        if ((Get-R17BoardStoreRequiredProperty -Object $BoardState.canonical_truth -Name $runtimeField -Context "$Context canonical_truth") -ne $false) {
            throw "$Context canonical_truth $runtimeField must be false."
        }
    }

    $expectedLanes = [string[]](Assert-R17BoardStoreArray -Value $Contracts.BoardState.allowed_lanes -Context "board state contract allowed_lanes")
    Assert-R17BoardStoreExactSet -Values ([string[]](Assert-R17BoardStoreArray -Value $BoardState.lane_order -Context "$Context lane_order")) -Expected $expectedLanes -Context "$Context lane_order"
    foreach ($lane in $expectedLanes) {
        if (-not (Test-R17BoardStoreHasProperty -Object $BoardState.lane_policies -Name $lane)) {
            throw "$Context lane_policies must define lane '$lane'."
        }
        $lanePolicy = $BoardState.lane_policies.PSObject.Properties[$lane].Value
        if ($lanePolicy.runtime_lane_movement_implemented -ne $false) {
            throw "$Context lane policy '$lane' must not claim runtime movement."
        }
    }

    foreach ($cardRef in @(Assert-R17BoardStoreArray -Value $BoardState.card_refs -Context "$Context card_refs")) {
        Assert-R17BoardStoreNonEmptyString -Value $cardRef.card_id -Context "$Context card_refs card_id"
        Assert-R17BoardStorePathExists -Path ([string]$cardRef.path) -Context "$Context card_refs path" -RepositoryRoot $RepositoryRoot
        Assert-R17BoardStoreAllowedValue -Value $cardRef.lane -AllowedValues $expectedLanes -Context "$Context card_refs lane"
    }

    if ($BoardState.role_permissions.qa.can_implement -ne $false) {
        throw "$Context role policy violation: QA can implement."
    }
    if ($BoardState.role_permissions.developer.can_approve_evidence_sufficiency -ne $false) {
        throw "$Context role policy violation: Developer can approve evidence sufficiency."
    }
    if ($BoardState.role_permissions.evidence_auditor.can_implement -ne $false) {
        throw "$Context role policy violation: Auditor can implement."
    }
    if ($BoardState.role_permissions.orchestrator.can_bypass_qa_gate -ne $false -or $BoardState.role_permissions.orchestrator.can_bypass_audit_gate -ne $false) {
        throw "$Context transition policy violation: Orchestrator can bypass QA/audit gates."
    }

    if ($BoardState.transition_policies.closed_requires_user_approval -ne $true) {
        throw "$Context transition policy closed_requires_user_approval must be true."
    }
    foreach ($field in @("board_state_replaces_repo_truth", "runtime_transitions_implemented_in_r17_005", "executable_transitions_implemented", "a2a_runtime_implemented_in_r17_005", "kanban_runtime_implemented_in_r17_005", "product_runtime_implemented_in_r17_005")) {
        if ((Get-R17BoardStoreRequiredProperty -Object $BoardState.transition_policies -Name $field -Context "$Context transition_policies") -ne $false) {
            throw "$Context transition_policies $field must be false."
        }
    }

    Assert-R17BoardStoreArray -Value $BoardState.unresolved_blockers -Context "$Context unresolved_blockers" -AllowNullAsEmpty | Out-Null
    $decisions = @(Assert-R17BoardStoreArray -Value $BoardState.user_decisions_required -Context "$Context user_decisions_required" -AllowNullAsEmpty)
    if ($decisions.Count -eq 0) {
        throw "$Context must record user decisions required."
    }
    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $BoardState.non_claims -Context "$Context non_claims")) -Required $script:R17NonClaims -Context "$Context non_claims"
    Assert-R17BoardStoreSha -Value $BoardState.generated_from_head -Context "$Context generated_from_head"
    Assert-R17BoardStoreSha -Value $BoardState.generated_from_tree -Context "$Context generated_from_tree"
}

function Test-R17BoardStateStoreReplayReport {
    param(
        [Parameter(Mandatory = $true)]
        $ReplayReport,
        [string]$Context = "R17-005 replay report"
    )

    foreach ($field in @("generated_from_head", "generated_from_tree", "board_id", "input_card_count", "input_event_count", "replayed_event_count", "rejected_event_count", "final_lane_by_card", "user_decisions_required", "unresolved_blockers", "non_claims", "rejected_claims", "aggregate_verdict")) {
        Get-R17BoardStoreRequiredProperty -Object $ReplayReport -Name $field -Context $Context | Out-Null
    }

    Assert-R17BoardStoreSha -Value $ReplayReport.generated_from_head -Context "$Context generated_from_head"
    Assert-R17BoardStoreSha -Value $ReplayReport.generated_from_tree -Context "$Context generated_from_tree"
    if ($ReplayReport.board_id -ne $script:BoardId) {
        throw "$Context board_id is incorrect."
    }
    if (@("generated_r17_board_state_store_candidate", "failed_validation") -notcontains $ReplayReport.aggregate_verdict) {
        throw "$Context aggregate_verdict '$($ReplayReport.aggregate_verdict)' is not allowed."
    }
    if ($ReplayReport.aggregate_verdict -eq "generated_r17_board_state_store_candidate" -and $ReplayReport.rejected_event_count -ne 0) {
        throw "$Context successful verdict cannot have rejected events."
    }
    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $ReplayReport.non_claims -Context "$Context non_claims")) -Required $script:R17NonClaims -Context "$Context non_claims"
    Assert-R17BoardStoreContains -Values ([string[]](Assert-R17BoardStoreArray -Value $ReplayReport.rejected_claims -Context "$Context rejected_claims")) -Required $script:R17RejectedClaims -Context "$Context rejected_claims"
}

function New-R17BoardStateStore {
    param([string]$RepositoryRoot = $repoRoot)

    Get-R17BoardStateStoreContracts -RepositoryRoot $RepositoryRoot | Out-Null
    $identity = Get-R17GitIdentity -RepositoryRoot $RepositoryRoot
    $seedCard = New-R17BoardStateStoreSeedCard
    $seedEvents = New-R17BoardStateStoreSeedEvents

    Write-R17JsonFile -Path $script:SeedCardPath -InputObject $seedCard -RepositoryRoot $RepositoryRoot
    Write-R17BoardEventLog -Path $script:SeedEventsPath -Events $seedEvents -RepositoryRoot $RepositoryRoot

    $card = Read-R17BoardStoreJsonFile -Path $script:SeedCardPath -RepositoryRoot $RepositoryRoot
    $events = Read-R17BoardEventLog -Path $script:SeedEventsPath -RepositoryRoot $RepositoryRoot
    $replay = Invoke-R17BoardEventReplay -Cards @($card) -Events $events -GeneratedFromHead $identity.Head -GeneratedFromTree $identity.Tree -RepositoryRoot $RepositoryRoot

    Write-R17JsonFile -Path $script:BoardStatePath -InputObject $replay.BoardState -RepositoryRoot $RepositoryRoot
    Write-R17JsonFile -Path $script:ReplayReportPath -InputObject $replay.ReplayReport -RepositoryRoot $RepositoryRoot

    return [pscustomobject]@{
        BoardStatePath = $script:BoardStatePath
        SeedCardPath = $script:SeedCardPath
        SeedEventsPath = $script:SeedEventsPath
        ReplayReportPath = $script:ReplayReportPath
        AggregateVerdict = $replay.ReplayReport.aggregate_verdict
        InputCardCount = $replay.ReplayReport.input_card_count
        InputEventCount = $replay.ReplayReport.input_event_count
        ReplayedEventCount = $replay.ReplayReport.replayed_event_count
        RejectedEventCount = $replay.ReplayReport.rejected_event_count
        FinalLane = $replay.ReplayReport.final_lane_by_card."R17-005"
        UserDecisionCount = @($replay.ReplayReport.user_decisions_required).Count
    }
}

function Test-R17BoardStateStore {
    param(
        [string]$RepositoryRoot = $repoRoot,
        [string]$SeedCardPath = $script:SeedCardPath,
        [string]$SeedEventsPath = $script:SeedEventsPath,
        [string]$BoardStatePath = $script:BoardStatePath,
        [string]$ReplayReportPath = $script:ReplayReportPath
    )

    $contracts = Get-R17BoardStateStoreContracts -RepositoryRoot $RepositoryRoot
    $seedCard = Read-R17BoardStoreJsonFile -Path $SeedCardPath -RepositoryRoot $RepositoryRoot
    $seedEvents = Read-R17BoardEventLog -Path $SeedEventsPath -RepositoryRoot $RepositoryRoot
    $boardState = Read-R17BoardStoreJsonFile -Path $BoardStatePath -RepositoryRoot $RepositoryRoot
    $replayReport = Read-R17BoardStoreJsonFile -Path $ReplayReportPath -RepositoryRoot $RepositoryRoot
    Test-R17BoardStateStoreCard -Card $seedCard -Contracts $contracts -RepositoryRoot $RepositoryRoot | Out-Null

    if ($boardState.generated_from_head -ne $replayReport.generated_from_head -or $boardState.generated_from_tree -ne $replayReport.generated_from_tree) {
        throw "Generated board state and replay report must record the same head/tree identity."
    }

    $replay = Invoke-R17BoardEventReplay -Cards @($seedCard) -Events $seedEvents -GeneratedFromHead $boardState.generated_from_head -GeneratedFromTree $boardState.generated_from_tree -RepositoryRoot $RepositoryRoot

    Test-R17BoardStateStoreBoardState -BoardState $boardState -Contracts $contracts -RepositoryRoot $RepositoryRoot | Out-Null
    Test-R17BoardStateStoreReplayReport -ReplayReport $replayReport | Out-Null

    $expectedBoardState = $replay.BoardState | ConvertTo-Json -Depth 100
    $actualBoardState = $boardState | ConvertTo-Json -Depth 100
    if ($expectedBoardState -ne $actualBoardState) {
        throw "Generated board state artifact does not match deterministic replay output."
    }

    $expectedReport = $replay.ReplayReport | ConvertTo-Json -Depth 100
    $actualReport = $replayReport | ConvertTo-Json -Depth 100
    if ($expectedReport -ne $actualReport) {
        throw "Generated replay report artifact does not match deterministic replay output."
    }

    return [pscustomobject]@{
        BoardId = $replayReport.board_id
        InputCardCount = $replayReport.input_card_count
        InputEventCount = $replayReport.input_event_count
        ReplayedEventCount = $replayReport.replayed_event_count
        RejectedEventCount = $replayReport.rejected_event_count
        FinalLane = $replayReport.final_lane_by_card."R17-005"
        UserDecisionCount = @($replayReport.user_decisions_required).Count
        AggregateVerdict = $replayReport.aggregate_verdict
    }
}

Export-ModuleMember -Function @(
    "Get-R17BoardStateStoreContracts",
    "Get-R17BoardStateStorePaths",
    "Read-R17BoardStoreJsonFile",
    "Read-R17BoardEventLog",
    "New-R17BoardStateStoreSeedCard",
    "New-R17BoardStateStoreSeedEvents",
    "Invoke-R17BoardEventReplay",
    "Test-R17BoardStateStoreCard",
    "Test-R17BoardStateStoreEvent",
    "Test-R17BoardStateStoreBoardState",
    "Test-R17BoardStateStoreReplayReport",
    "New-R17BoardStateStore",
    "Test-R17BoardStateStore"
)
