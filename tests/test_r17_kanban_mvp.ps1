$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17KanbanMvp.psm1") -Force -PassThru
$testR17KanbanMvp = $module.ExportedCommands["Test-R17KanbanMvp"]
$testR17KanbanMvpSnapshot = $module.ExportedCommands["Test-R17KanbanMvpSnapshot"]
$readR17KanbanMvpJsonFile = $module.ExportedCommands["Read-R17KanbanMvpJsonFile"]

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$InputObject)
    return ($InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Set-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)]$Value
    )

    if ($Object.PSObject.Properties.Name -contains $Name) {
        $Object.PSObject.Properties[$Name].Value = $Value
        return
    }

    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
}

function Apply-R17KanbanMvpMutation {
    param(
        [Parameter(Mandatory = $true)]$Snapshot,
        [Parameter(Mandatory = $true)]$Mutation
    )

    switch ($Mutation.mutation) {
        "remove_lane" {
            $lane = [string]$Mutation.lane
            Set-ObjectProperty -Object $Snapshot -Name "lane_order" -Value @($Snapshot.lane_order | Where-Object { $_ -ne $lane })
            Set-ObjectProperty -Object $Snapshot -Name "lanes" -Value @($Snapshot.lanes | Where-Object { $_.id -ne $lane })
        }
        "remove_seed_card" {
            Set-ObjectProperty -Object $Snapshot -Name "cards" -Value @($Snapshot.cards | Where-Object { $_.card_id -ne "R17-005" })
            foreach ($lane in @($Snapshot.lanes)) {
                if ($lane.id -eq "ready_for_user_review") {
                    Set-ObjectProperty -Object $lane -Name "card_count" -Value 0
                    Set-ObjectProperty -Object $lane -Name "cards" -Value @()
                }
            }
        }
        "wrong_final_lane" {
            $wrongLane = [string]$Mutation.lane
            foreach ($card in @($Snapshot.cards)) {
                if ($card.card_id -eq "R17-005") {
                    Set-ObjectProperty -Object $card -Name "current_lane" -Value $wrongLane
                }
            }
            foreach ($lane in @($Snapshot.lanes)) {
                if ($lane.id -eq "ready_for_user_review") {
                    Set-ObjectProperty -Object $lane -Name "card_count" -Value 0
                    Set-ObjectProperty -Object $lane -Name "cards" -Value @()
                }
                if ($lane.id -eq $wrongLane) {
                    Set-ObjectProperty -Object $lane -Name "card_count" -Value 1
                    Set-ObjectProperty -Object $lane -Name "cards" -Value @("R17-005")
                }
            }
            Set-ObjectProperty -Object $Snapshot.replay_summary.final_lane_by_card -Name "R17-005" -Value $wrongLane
        }
        "add_text_sample" {
            Set-ObjectProperty -Object $Snapshot -Name "runtime_claim_text_samples" -Value @([string]$Mutation.claim_text)
        }
        "add_external_dependency_sample" {
            Set-ObjectProperty -Object $Snapshot -Name "ui_file_text_samples" -Value @([string]$Mutation.content)
        }
        default {
            throw "Unsupported mutation '$($Mutation.mutation)'."
        }
    }

    return $Snapshot
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$RequiredFragment,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        if ($message -notlike "*$RequiredFragment*") {
            $script:failures += "FAIL invalid: $Label refusal missed '$RequiredFragment'. Actual: $message"
            return
        }

        Write-Output "PASS invalid: $Label -> $message"
        $script:invalidRejected += 1
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRoot = Join-Path $repoRoot "tests\fixtures\r17_kanban_mvp"

try {
    $liveResult = & $testR17KanbanMvp -RepositoryRoot $repoRoot
    if ($liveResult.LaneCount -ne 13 -or $liveResult.CardCount -ne 1 -or $liveResult.SeedCardLane -ne "ready_for_user_review" -or $liveResult.AggregateVerdict -ne "generated_r17_board_state_store_candidate" -or $liveResult.UserDecisionCount -lt 1) {
        $failures += "FAIL valid: live R17-006 Kanban MVP did not expose the expected lanes, seed card, replay verdict, and user decision state."
    }
    else {
        Write-Output "PASS valid live R17-006 Kanban MVP snapshot and UI files."
        $validPassed += 1
    }

    $validFixturePath = Join-Path $fixtureRoot "valid_kanban_snapshot.json"
    $validFixture = & $readR17KanbanMvpJsonFile -Path $validFixturePath -RepositoryRoot $repoRoot
    & $testR17KanbanMvpSnapshot -Snapshot $validFixture -Context "valid fixture" | Out-Null
    Write-Output "PASS valid fixture: valid_kanban_snapshot.json"
    $validPassed += 1

    foreach ($invalidPath in @(Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | Sort-Object Name)) {
        $mutation = & $readR17KanbanMvpJsonFile -Path $invalidPath.FullName -RepositoryRoot $repoRoot
        Invoke-ExpectedRefusal -Label $invalidPath.Name -RequiredFragment ([string]$mutation.expected_error) -Action {
            $candidate = Copy-JsonObject -InputObject $validFixture
            $candidate = Apply-R17KanbanMvpMutation -Snapshot $candidate -Mutation $mutation
            & $testR17KanbanMvpSnapshot -Snapshot $candidate -Context $invalidPath.Name | Out-Null
        }
    }
}
catch {
    $failures += "FAIL r17 kanban MVP harness: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 Kanban MVP tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17 Kanban MVP tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
