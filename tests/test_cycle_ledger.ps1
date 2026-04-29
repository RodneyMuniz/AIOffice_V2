$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\CycleLedger.psm1") -Force -PassThru
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$testCycleLedgerContract = $module.ExportedCommands["Test-CycleLedgerContract"]
$testCycleLedgerObject = $module.ExportedCommands["Test-CycleLedgerObject"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\cycle_controller\cycle_ledger.valid.json"
$invalidFixtureRoot = Join-Path $repoRoot "state\fixtures\invalid\cycle_controller"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r11cycleledger" + [guid]::NewGuid().ToString("N").Substring(0, 8))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "Test JSON document")
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $parentPath = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    $Document | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    $copyPath = Join-Path $tempRoot ("copy-" + [guid]::NewGuid().ToString("N") + ".json")
    Write-JsonDocument -Path $copyPath -Document $Object
    return Get-JsonDocument -Path $copyPath
}

function New-Transition {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FromState,
        [Parameter(Mandatory = $true)]
        [string]$ToState,
        [Parameter(Mandatory = $true)]
        [string]$Timestamp,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    return [pscustomobject]@{
        from_state = $FromState
        to_state = $ToState
        transitioned_at_utc = $Timestamp
        evidence_ref = ("state/cycle_controller/r11-002/{0}.transition.json" -f $ToState)
        actor = "R11-002-validator-test"
        reason = $Reason
    }
}

function New-LaterStateLedger {
    $ledger = Copy-JsonObject -Object (Get-JsonDocument -Path $validFixture)
    $ledger.state = "operator_decision_pending"
    $ledger.allowed_next_states = @("accepted", "blocked", "stopped")
    $ledger.current_step = "await_operator_decision"
    $ledger.operator_request_ref = "state/cycle_controller/r11-002/operator_request.json"
    $ledger.cycle_plan_ref = "state/cycle_controller/r11-002/cycle_plan.json"
    $ledger.baseline_ref = "state/cycle_controller/r11-002/baseline.json"
    $ledger.dispatch_refs = @("state/cycle_controller/r11-002/dev_dispatch_001.json")
    $ledger.execution_result_refs = @("state/cycle_controller/r11-002/dev_result_001.json")
    $ledger.qa_refs = @("state/cycle_controller/r11-002/qa_result_001.json")
    $ledger.audit_packet_ref = "state/cycle_controller/r11-002/audit_packet.json"
    $ledger.decision_packet_ref = "state/cycle_controller/r11-002/decision_packet.json"
    $ledger.evidence_refs = @(
        "state/cycle_controller/r11-002/operator_approval.evidence.json",
        "state/cycle_controller/r11-002/dev_evidence.evidence.json",
        "state/cycle_controller/r11-002/qa.evidence.json",
        "state/cycle_controller/r11-002/audit.evidence.json",
        "state/cycle_controller/r11-002/decision.evidence.json"
    )
    $ledger.updated_at_utc = "2026-04-29T00:10:00Z"
    $ledger.transition_history = @(
        (New-Transition -FromState "none" -ToState "initialized" -Timestamp "2026-04-29T00:00:00Z" -Reason "Initialize the cycle ledger."),
        (New-Transition -FromState "initialized" -ToState "request_recorded" -Timestamp "2026-04-29T00:01:00Z" -Reason "Record operator request."),
        (New-Transition -FromState "request_recorded" -ToState "plan_prepared" -Timestamp "2026-04-29T00:02:00Z" -Reason "Prepare cycle plan."),
        (New-Transition -FromState "plan_prepared" -ToState "plan_approved" -Timestamp "2026-04-29T00:03:00Z" -Reason "Record operator approval evidence."),
        (New-Transition -FromState "plan_approved" -ToState "dev_dispatch_ready" -Timestamp "2026-04-29T00:04:00Z" -Reason "Prepare Dev dispatch."),
        (New-Transition -FromState "dev_dispatch_ready" -ToState "dev_in_progress" -Timestamp "2026-04-29T00:05:00Z" -Reason "Dispatch Dev execution."),
        (New-Transition -FromState "dev_in_progress" -ToState "dev_evidence_recorded" -Timestamp "2026-04-29T00:06:00Z" -Reason "Record Dev evidence."),
        (New-Transition -FromState "dev_evidence_recorded" -ToState "qa_pending" -Timestamp "2026-04-29T00:07:00Z" -Reason "Send executor evidence to separate QA."),
        (New-Transition -FromState "qa_pending" -ToState "qa_passed" -Timestamp "2026-04-29T00:08:00Z" -Reason "Record separate QA pass."),
        (New-Transition -FromState "qa_passed" -ToState "audit_packet_ready" -Timestamp "2026-04-29T00:09:00Z" -Reason "Prepare audit packet."),
        (New-Transition -FromState "audit_packet_ready" -ToState "operator_decision_pending" -Timestamp "2026-04-29T00:10:00Z" -Reason "Prepare decision packet and await operator decision.")
    )

    return $ledger
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Invoke-MutatedLedgerRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation,
        [switch]$UseLaterState
    )

    Invoke-ExpectedRefusal -Label $Label -RequiredFragments $RequiredFragments -Action {
        $ledger = if ($UseLaterState) { New-LaterStateLedger } else { Copy-JsonObject -Object (Get-JsonDocument -Path $validFixture) }
        & $Mutation $ledger
        & $testCycleLedgerObject -Ledger $ledger -SourceLabel $Label | Out-Null
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $validResult = & $testCycleLedgerContract -LedgerPath $validFixture
    Write-Output ("PASS valid initialized cycle ledger: {0} -> {1}" -f $validResult.CycleId, $validResult.State)
    $validPassed += 1

    $laterLedger = New-LaterStateLedger
    $laterResult = & $testCycleLedgerObject -Ledger $laterLedger -SourceLabel "valid later-state cycle ledger"
    Write-Output ("PASS valid later-state cycle ledger: {0} -> {1}" -f $laterResult.CycleId, $laterResult.State)
    $validPassed += 1

    Invoke-MutatedLedgerRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "contract_version") -Mutation {
        param($ledger)
        $ledger.PSObject.Properties.Remove("contract_version")
    }

    Invoke-MutatedLedgerRefusal -Label "wrong-repository" -RequiredFragments @("repository", "AIOffice_V2") -Mutation {
        param($ledger)
        $ledger.repository = "OtherRepo"
    }

    Invoke-MutatedLedgerRefusal -Label "wrong-branch" -RequiredFragments @("branch", "release/r10-real-external-runner-proof-foundation") -Mutation {
        param($ledger)
        $ledger.branch = "feature/r5-closeout-remaining-foundations"
    }

    Invoke-MutatedLedgerRefusal -Label "wrong-milestone" -RequiredFragments @("milestone", "R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot") -Mutation {
        param($ledger)
        $ledger.milestone = "R12 Successor Milestone"
    }

    Invoke-MutatedLedgerRefusal -Label "wrong-source-task" -RequiredFragments @("source_task", "R11-002") -Mutation {
        param($ledger)
        $ledger.source_task = "R11-003"
    }

    Invoke-MutatedLedgerRefusal -Label "unknown-state" -RequiredFragments @("state", "must be one of") -Mutation {
        param($ledger)
        $ledger.state = "teleported"
    }

    Invoke-MutatedLedgerRefusal -Label "illegal-transition" -RequiredFragments @("impossible jump", "dev_dispatch_ready", "qa_pending") -UseLaterState -Mutation {
        param($ledger)
        $ledger.transition_history[5].to_state = "qa_pending"
    }

    Invoke-MutatedLedgerRefusal -Label "transition-history-gap" -RequiredFragments @("from_state", "prior to_state") -UseLaterState -Mutation {
        param($ledger)
        $ledger.transition_history = @($ledger.transition_history | Where-Object { $_.to_state -ne "dev_dispatch_ready" })
    }

    Invoke-MutatedLedgerRefusal -Label "transition-timestamp-regression" -RequiredFragments @("timestamps", "regress") -UseLaterState -Mutation {
        param($ledger)
        $ledger.transition_history[3].transitioned_at_utc = "2026-04-29T00:01:30Z"
    }

    Invoke-MutatedLedgerRefusal -Label "terminal-state-with-allowed-next-states" -RequiredFragments @("terminal state", "allowed_next_states") -UseLaterState -Mutation {
        param($ledger)
        $ledger.state = "accepted"
        $ledger.current_step = "cycle_accepted"
        $ledger.allowed_next_states = @("request_recorded")
    }

    Invoke-MutatedLedgerRefusal -Label "non-terminal-empty-allowed-next-states" -RequiredFragments @("non-terminal state", "allowed_next_states") -Mutation {
        param($ledger)
        $ledger.allowed_next_states = @()
    }

    Invoke-MutatedLedgerRefusal -Label "chat-transcript-authority" -RequiredFragments @("state_authority", "chat transcript") -Mutation {
        param($ledger)
        $ledger.controller_authority.state_authority = "chat transcript"
    }

    Invoke-MutatedLedgerRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no Standard runtime") -Mutation {
        param($ledger)
        $ledger.non_claims = @($ledger.non_claims | Where-Object { $_ -ne "no Standard runtime" })
    }

    Invoke-MutatedLedgerRefusal -Label "required-state-refs-missing" -RequiredFragments @("baseline_ref", "required") -UseLaterState -Mutation {
        param($ledger)
        $ledger.baseline_ref = ""
    }

    Invoke-MutatedLedgerRefusal -Label "updated-earlier-than-created" -RequiredFragments @("updated_at_utc", "created_at_utc") -Mutation {
        param($ledger)
        $ledger.updated_at_utc = "2026-04-28T23:59:59Z"
    }

    Invoke-MutatedLedgerRefusal -Label "transition-history-does-not-end-at-current-state" -RequiredFragments @("transition_history", "current state") -Mutation {
        param($ledger)
        $ledger.state = "request_recorded"
        $ledger.allowed_next_states = @("plan_prepared", "blocked", "stopped")
        $ledger.current_step = "record_operator_request"
        $ledger.operator_request_ref = "state/cycle_controller/r11-002/operator_request.json"
    }

    Invoke-MutatedLedgerRefusal -Label "current-step-contradicts-state" -RequiredFragments @("current_step", "contradicts") -Mutation {
        param($ledger)
        $ledger.current_step = "run_separate_qa_gate"
    }

    if (Test-Path -LiteralPath $invalidFixtureRoot) {
        $invalidFixtures = @(Get-ChildItem -LiteralPath $invalidFixtureRoot -Filter "*.json" -File)
        if ($invalidFixtures.Count -eq 0) {
            $failures += "FAIL invalid fixtures: no invalid cycle ledger fixtures were found."
        }

        foreach ($invalidFixture in $invalidFixtures) {
            Invoke-ExpectedRefusal -Label ("invalid-fixture:{0}" -f $invalidFixture.Name) -RequiredFragments @("Cycle ledger") -Action {
                & $testCycleLedgerContract -LedgerPath $invalidFixture.FullName | Out-Null
            }
        }
    }
    else {
        $failures += "FAIL invalid fixtures: state\\fixtures\\invalid\\cycle_controller was not found."
    }
}
catch {
    $failures += ("FAIL cycle ledger harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Cycle ledger tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All cycle ledger tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
