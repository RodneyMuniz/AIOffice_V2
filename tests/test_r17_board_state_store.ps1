$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17BoardStateStore.psm1") -Force -PassThru
$testStore = $module.ExportedCommands["Test-R17BoardStateStore"]
$readJson = $module.ExportedCommands["Read-R17BoardStoreJsonFile"]
$readEvents = $module.ExportedCommands["Read-R17BoardEventLog"]
$replayEvents = $module.ExportedCommands["Invoke-R17BoardEventReplay"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRoot = "tests/fixtures/r17_board_state_store"
$validFixtureRoot = Join-Path $fixtureRoot "valid_board_state_store"

function Invoke-ExpectedFailure {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedFragment,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        if ($message -notlike ("*{0}*" -f $ExpectedFragment)) {
            $script:failures += "FAIL invalid: $Label refusal missed '$ExpectedFragment'. Actual: $message"
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $ExpectedFragment)
        $script:invalidRejected += 1
    }
}

function Copy-JsonObject {
    param($InputObject)
    return ($InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Set-JsonPathProperty {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        $Value
    )

    $parts = @($Path -split '\.')
    $target = $InputObject
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if (-not ($target.PSObject.Properties.Name -contains $part) -or $null -eq $target.PSObject.Properties[$part].Value) {
            $target | Add-Member -MemberType NoteProperty -Name $part -Value ([pscustomobject]@{}) -Force
        }
        $target = $target.PSObject.Properties[$part].Value
    }

    $leaf = $parts[-1]
    if ($target.PSObject.Properties.Name -contains $leaf) {
        $target.PSObject.Properties[$leaf].Value = $Value
    }
    else {
        $target | Add-Member -MemberType NoteProperty -Name $leaf -Value $Value -Force
    }
}

function New-InvalidEventCandidate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixturePath,
        [Parameter(Mandatory = $true)]
        [object[]]$BaseEvents
    )

    $resolvedPath = Join-Path $repoRoot $FixturePath
    $specLine = Get-Content -LiteralPath $resolvedPath -Raw
    $spec = $specLine | ConvertFrom-Json
    $eventIndex = [int]$spec.base_event_index
    $candidate = Copy-JsonObject -InputObject $BaseEvents[$eventIndex]

    if ($spec.PSObject.Properties.Name -contains "set_fields") {
        foreach ($property in $spec.set_fields.PSObject.Properties) {
            Set-JsonPathProperty -InputObject $candidate -Path $property.Name -Value $property.Value
        }
    }

    return [pscustomobject]@{
        CaseId = $spec.case_id
        ExpectedRefusal = $spec.expected_refusal
        Event = $candidate
    }
}

try {
    $liveResult = & $testStore -RepositoryRoot $repoRoot
    if ($liveResult.AggregateVerdict -ne "generated_r17_board_state_store_candidate" -or $liveResult.InputCardCount -ne 1 -or $liveResult.InputEventCount -ne 5 -or $liveResult.ReplayedEventCount -ne 5 -or $liveResult.RejectedEventCount -ne 0 -or $liveResult.FinalLane -ne "ready_for_user_review" -or $liveResult.UserDecisionCount -ne 1) {
        $failures += "FAIL valid live R17-005 board state store: unexpected replay counts, lane, user decision count, or verdict."
    }
    else {
        Write-Output "PASS valid live R17-005 board state store: deterministic replay output matches generated artifacts."
        $validPassed += 1
    }

    $fixtureCard = & $readJson -Path (Join-Path $validFixtureRoot "seed_card.json") -RepositoryRoot $repoRoot
    $fixtureEvents = & $readEvents -Path (Join-Path $validFixtureRoot "seed_events.jsonl") -RepositoryRoot $repoRoot
    $expectedBoardState = & $readJson -Path (Join-Path $validFixtureRoot "expected_board_state.json") -RepositoryRoot $repoRoot
    $expectedReplayReport = & $readJson -Path (Join-Path $validFixtureRoot "expected_replay_report.json") -RepositoryRoot $repoRoot
    $fixtureReplay = & $replayEvents -Cards @($fixtureCard) -Events $fixtureEvents -GeneratedFromHead $expectedBoardState.generated_from_head -GeneratedFromTree $expectedBoardState.generated_from_tree -RepositoryRoot $repoRoot

    if (($fixtureReplay.BoardState | ConvertTo-Json -Depth 100) -ne ($expectedBoardState | ConvertTo-Json -Depth 100)) {
        $failures += "FAIL valid fixture expected_board_state: deterministic replay output differed."
    }
    elseif (($fixtureReplay.ReplayReport | ConvertTo-Json -Depth 100) -ne ($expectedReplayReport | ConvertTo-Json -Depth 100)) {
        $failures += "FAIL valid fixture expected_replay_report: deterministic replay output differed."
    }
    else {
        Write-Output "PASS valid fixture replay: expected board state and replay report match deterministic output."
        $validPassed += 1
    }

    $invalidExpectations = [ordered]@{
        "invalid_unknown_card_event.jsonl" = "unknown card"
        "invalid_lane_event.jsonl" = "not allowed"
        "invalid_role_event.jsonl" = "actor_role"
        "invalid_closed_without_user_approval_event.jsonl" = "closed without user approval"
        "invalid_qa_implements_event.jsonl" = "QA implements"
        "invalid_developer_approves_evidence_event.jsonl" = "Developer approves evidence sufficiency"
        "invalid_auditor_implements_event.jsonl" = "Auditor implements"
        "invalid_orchestrator_bypasses_qa_event.jsonl" = "Orchestrator bypasses QA/audit gates"
        "invalid_product_runtime_claim_event.jsonl" = "product_runtime"
        "invalid_kanban_runtime_claim_event.jsonl" = "Kanban_runtime"
        "invalid_a2a_runtime_claim_event.jsonl" = "A2A_runtime"
        "invalid_autonomous_agent_claim_event.jsonl" = "autonomous_agents"
        "invalid_executable_handoff_claim_event.jsonl" = "executable_handoffs"
        "invalid_executable_transition_claim_event.jsonl" = "executable_transitions"
        "invalid_dev_codex_adapter_runtime_claim_event.jsonl" = "Dev_Codex_executor_adapter_runtime"
        "invalid_qa_adapter_runtime_claim_event.jsonl" = "QA_Test_Agent_adapter_runtime"
        "invalid_evidence_auditor_api_runtime_claim_event.jsonl" = "Evidence_Auditor_API_adapter_runtime"
        "invalid_external_audit_acceptance_claim_event.jsonl" = "external_audit_acceptance"
        "invalid_main_merge_claim_event.jsonl" = "main_merge"
        "invalid_solved_codex_compaction_claim_event.jsonl" = "solved_Codex_compaction"
        "invalid_solved_codex_reliability_claim_event.jsonl" = "solved_Codex_reliability"
        "invalid_r13_closure_claim_event.jsonl" = "R13_closure"
        "invalid_r14_caveat_removal_claim_event.jsonl" = "R14_caveat_removal"
        "invalid_r15_caveat_removal_claim_event.jsonl" = "R15_caveat_removal"
    }

    foreach ($entry in $invalidExpectations.GetEnumerator()) {
        Invoke-ExpectedFailure -Label $entry.Key -ExpectedFragment $entry.Value -Action {
            $candidateRecord = New-InvalidEventCandidate -FixturePath (Join-Path $fixtureRoot $entry.Key) -BaseEvents $fixtureEvents
            & $replayEvents -Cards @($fixtureCard) -Events @($candidateRecord.Event) -GeneratedFromHead $expectedBoardState.generated_from_head -GeneratedFromTree $expectedBoardState.generated_from_tree -RepositoryRoot $repoRoot | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL R17-005 board state store harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17-005 board state store tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17-005 board state store tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
