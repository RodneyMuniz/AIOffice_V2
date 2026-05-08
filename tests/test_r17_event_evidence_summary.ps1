$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17EventEvidenceSummary.psm1"
Import-Module $modulePath -Force

$fixtureRoot = Join-Path $repoRoot "tests\fixtures\r17_event_evidence_summary"
$validFixturePath = Join-Path $fixtureRoot "valid_event_evidence_summary_snapshot.json"
$invalidFixtureNames = @(
    "invalid_missing_replay_summary.json",
    "invalid_missing_event_timeline.json",
    "invalid_missing_event_id.json",
    "invalid_missing_event_type.json",
    "invalid_missing_actor_role.json",
    "invalid_missing_transition_allowed.json",
    "invalid_missing_evidence_summary.json",
    "invalid_missing_evidence_grouping.json",
    "invalid_missing_transition_summary.json",
    "invalid_missing_user_decision_state.json",
    "invalid_missing_non_claims.json",
    "invalid_generated_report_treated_as_machine_proof.json",
    "invalid_dev_output_claim.json",
    "invalid_qa_result_claim.json",
    "invalid_audit_verdict_claim.json",
    "invalid_live_board_mutation_claim.json",
    "invalid_orchestrator_runtime_claim.json",
    "invalid_a2a_runtime_claim.json",
    "invalid_autonomous_agent_claim.json",
    "invalid_dev_codex_adapter_runtime_claim.json",
    "invalid_qa_adapter_runtime_claim.json",
    "invalid_evidence_auditor_api_runtime_claim.json",
    "invalid_executable_handoff_claim.json",
    "invalid_executable_transition_claim.json",
    "invalid_product_runtime_claim.json",
    "invalid_production_runtime_claim.json",
    "invalid_external_dependency_ref.json",
    "invalid_external_audit_acceptance_claim.json",
    "invalid_main_merge_claim.json",
    "invalid_r13_closure_claim.json",
    "invalid_r14_caveat_removal_claim.json",
    "invalid_r15_caveat_removal_claim.json",
    "invalid_solved_codex_compaction_claim.json",
    "invalid_solved_codex_reliability_claim.json"
)

function Read-Json {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Clone-JsonObject {
    param([Parameter(Mandatory = $true)]$InputObject)

    return ($InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-PathParentAndName {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $parts = @($Path -split "\.")
    if ($parts.Count -lt 1) {
        throw "Invalid mutation path '$Path'."
    }

    $parent = $Object
    for ($index = 0; $index -lt ($parts.Count - 1); $index++) {
        $part = $parts[$index]
        if ($part -match '^\[(\d+)\]$') {
            $parent = @($parent)[[int]$Matches[1]]
            continue
        }

        if ($parent.PSObject.Properties.Name -notcontains $part) {
            throw "Mutation path '$Path' is missing '$part'."
        }
        $parent = $parent.PSObject.Properties[$part].Value
    }

    return [pscustomobject]@{
        Parent = $parent
        Name = $parts[-1]
    }
}

function Set-MutationPath {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        $Value
    )

    $target = Get-PathParentAndName -Object $Object -Path $Path
    $name = $target.Name
    if ($name -match '^\[(\d+)\]$') {
        $target.Parent[[int]$Matches[1]] = $Value
        return
    }

    if ($target.Parent.PSObject.Properties.Name -contains $name) {
        $target.Parent.PSObject.Properties[$name].Value = $Value
    }
    else {
        $target.Parent | Add-Member -NotePropertyName $name -NotePropertyValue $Value
    }
}

function Remove-MutationPath {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $target = Get-PathParentAndName -Object $Object -Path $Path
    $name = $target.Name
    if ($target.Parent.PSObject.Properties.Name -notcontains $name) {
        throw "Mutation path '$Path' cannot remove missing '$name'."
    }

    $target.Parent.PSObject.Properties.Remove($name)
}

function Apply-Mutation {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        $Fixture
    )

    if ($Fixture.mutation.PSObject.Properties.Name -contains "remove_path") {
        Remove-MutationPath -Object $Object -Path ([string]$Fixture.mutation.remove_path)
    }
    elseif ($Fixture.mutation.PSObject.Properties.Name -contains "set_path") {
        Set-MutationPath -Object $Object -Path ([string]$Fixture.mutation.set_path) -Value $Fixture.mutation.value
    }
    else {
        throw "Fixture '$($Fixture.fixture_id)' does not define a supported mutation."
    }
}

function Invoke-ExpectedRefusal {
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
        if ($message -notlike "*$ExpectedFragment*") {
            $script:failures += "FAIL invalid: $Label refusal did not contain '$ExpectedFragment'. Actual: $message"
            return
        }
        Write-Output "PASS invalid: $Label"
        $script:invalidRejected += 1
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    $liveResult = Test-R17EventEvidenceSummary -RepositoryRoot $repoRoot
    if ($liveResult.SelectedCardId -ne "R17-005" -or $liveResult.EventCount -ne 5 -or $liveResult.EvidenceGroupCount -ne 11 -or $liveResult.EvidenceRefCount -lt 11 -or $liveResult.FinalLane -ne "ready_for_user_review" -or -not $liveResult.UserDecisionRequired) {
        $failures += "FAIL valid: live R17-008 event/evidence summary did not expose the expected seed card, events, evidence groups, final lane, and user decision state."
    }
    else {
        Write-Output "PASS valid: live R17-008 event/evidence summary"
        $validPassed += 1
    }

    $validFixture = Read-Json -Path $validFixturePath
    Test-R17EventEvidenceSummarySnapshot -Snapshot $validFixture -Context "valid fixture" | Out-Null
    Write-Output "PASS valid: fixture snapshot"
    $validPassed += 1

    foreach ($invalidFixtureName in $invalidFixtureNames) {
        $fixturePath = Join-Path $fixtureRoot $invalidFixtureName
        $fixture = Read-Json -Path $fixturePath
        Invoke-ExpectedRefusal -Label $invalidFixtureName -ExpectedFragment ([string]$fixture.expected_error_fragment) -Action {
            $candidate = Clone-JsonObject -InputObject $validFixture
            Apply-Mutation -Object $candidate -Fixture $fixture
            Test-R17EventEvidenceSummarySnapshot -Snapshot $candidate -Context $invalidFixtureName | Out-Null
        }
    }
}
catch {
    $failures += "FAIL event/evidence summary harness: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 event/evidence summary tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17 event/evidence summary tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
