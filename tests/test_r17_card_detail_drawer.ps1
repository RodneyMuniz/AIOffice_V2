$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17CardDetailDrawer.psm1") -Force -PassThru
$readJson = $module.ExportedCommands["Read-R17CardDetailJsonFile"]
$testSnapshot = $module.ExportedCommands["Test-R17CardDetailDrawerSnapshot"]
$testDrawer = $module.ExportedCommands["Test-R17CardDetailDrawer"]

$fixtureRoot = Join-Path $repoRoot "tests\fixtures\r17_card_detail_drawer"
$validFixturePath = Join-Path $fixtureRoot "valid_card_detail_snapshot.json"

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    return ($InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-MutationParent {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [object[]]$Path
    )

    if ($Path.Count -lt 1) {
        throw "Mutation path cannot be empty."
    }

    $current = $Object
    for ($index = 0; $index -lt ($Path.Count - 1); $index++) {
        $segment = [string]$Path[$index]
        $property = $current.PSObject.Properties[$segment]
        if ($null -eq $property) {
            throw "Mutation path segment '$segment' does not exist."
        }

        $current = $property.Value
    }

    return $current
}

function Apply-MutationSpec {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        $Mutation
    )

    $path = @($Mutation.path)
    $parent = Get-MutationParent -Object $Object -Path $path
    $leaf = [string]$path[-1]

    switch ([string]$Mutation.operation) {
        "remove" {
            if ($parent.PSObject.Properties.Name -notcontains $leaf) {
                throw "Mutation remove target '$leaf' does not exist."
            }
            $parent.PSObject.Properties.Remove($leaf)
        }
        "set" {
            $property = $parent.PSObject.Properties[$leaf]
            if ($null -eq $property) {
                $parent | Add-Member -NotePropertyName $leaf -NotePropertyValue $Mutation.value
            }
            else {
                $property.Value = $Mutation.value
            }
        }
        "append" {
            $property = $parent.PSObject.Properties[$leaf]
            if ($null -eq $property) {
                throw "Mutation append target '$leaf' does not exist."
            }
            $property.Value = @(@($property.Value) + $Mutation.value)
        }
        default {
            throw "Unknown mutation operation '$($Mutation.operation)'."
        }
    }

    return $Object
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$RequiredFragment,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
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

try {
    $liveValidation = & $testDrawer -RepositoryRoot $repoRoot
    if ($liveValidation.SelectedCardId -ne "R17-005" -or $liveValidation.SelectedCardLane -ne "ready_for_user_review" -or $liveValidation.EvidenceRefCount -lt 8 -or $liveValidation.MemoryRefCount -lt 1 -or $liveValidation.EventHistoryCount -ne 5 -or $liveValidation.UserDecisionRequired -ne $true -or $liveValidation.DevOutputPlaceholderStatus -ne "not_implemented_in_r17_007" -or $liveValidation.QaResultPlaceholderStatus -ne "not_implemented_in_r17_007" -or $liveValidation.AuditVerdictPlaceholderStatus -ne "not_implemented_in_r17_007") {
        $failures += "FAIL valid: live R17-007 card detail drawer did not expose the expected selected card, refs, event history, decision state, and placeholders."
    }
    else {
        Write-Output ("PASS valid live R17-007 drawer: card {0}, lane {1}, evidence refs {2}, memory refs {3}, events {4}" -f $liveValidation.SelectedCardId, $liveValidation.SelectedCardLane, $liveValidation.EvidenceRefCount, $liveValidation.MemoryRefCount, $liveValidation.EventHistoryCount)
        $validPassed += 1
    }

    $validFixture = & $readJson -Path $validFixturePath -RepositoryRoot $repoRoot
    & $testSnapshot -Snapshot $validFixture -Context "valid fixture" | Out-Null
    Write-Output "PASS valid fixture: valid_card_detail_snapshot.json"
    $validPassed += 1

    foreach ($invalidFixture in Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | Sort-Object Name) {
        $mutation = & $readJson -Path $invalidFixture.FullName -RepositoryRoot $repoRoot
        Invoke-ExpectedRefusal -Label $invalidFixture.Name -RequiredFragment ([string]$mutation.expected_fragment) -Action {
            $candidate = Copy-JsonObject -InputObject $validFixture
            Apply-MutationSpec -Object $candidate -Mutation $mutation | Out-Null
            & $testSnapshot -Snapshot $candidate -Context $invalidFixture.Name | Out-Null
        }
    }
}
catch {
    $failures += "FAIL r17 card detail drawer harness: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 card detail drawer tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17 card detail drawer tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
