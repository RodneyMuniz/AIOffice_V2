$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17A2aContracts.psm1"
Import-Module $modulePath -Force

$paths = Get-R17A2aContractsPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        MessageContract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_message_contract.json")
        HandoffContract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_handoff_contract.json")
        MessagePackets = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_message_seed_packets.json")
        HandoffPackets = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_handoff_seed_packets.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17A2aContractsSet `
        -MessageContract $Set.MessageContract `
        -HandoffContract $Set.HandoffContract `
        -MessagePackets $Set.MessagePackets `
        -HandoffPackets $Set.HandoffPackets `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot `
        -SkipFixtureCoverage `
        -SkipRefExistence `
        -SkipKanbanJsCheck
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        $matched = $false
        foreach ($fragment in $RequiredFragments) {
            if ($message -match [regex]::Escape([string]$fragment)) {
                $matched = $true
            }
        }

        if (-not $matched) {
            $script:failures += "FAIL invalid: $Label rejected with unexpected message: $message"
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Invoke-Mutation {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][object]$Fixture
    )

    switch ([string]$Fixture.target) {
        "message" {
            Set-R17A2aObjectPathValue -TargetObject $Set.MessagePackets.messages[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "message_runtime_flag" {
            Set-R17A2aObjectPathValue -TargetObject $Set.MessagePackets.messages[0].runtime_flags -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "message_evidence_append" {
            $Set.MessagePackets.messages[0].evidence_refs += [string]$Fixture.value
        }
        "message_add_property" {
            Set-R17A2aObjectPathValue -TargetObject $Set.MessagePackets.messages[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "message_non_claim_append" {
            $Set.MessagePackets.messages[0].non_claims += [string]$Fixture.value
        }
        "handoff" {
            Set-R17A2aObjectPathValue -TargetObject $Set.HandoffPackets.handoffs[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "handoff_allowed_message_type_append" {
            $Set.HandoffPackets.handoffs[0].allowed_message_types += [string]$Fixture.value
        }
        default {
            throw "Unknown fixture mutation target '$($Fixture.target)'."
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17A2aContracts -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-020 A2A contract foundation validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-020 A2A contract foundation: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidFixtureSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact fixture set: $($_.Exception.Message)"
}

$invalidFixtureFiles = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name)
if ($invalidFixtureFiles.Count -lt 30) {
    $failures += "FAIL fixture coverage: expected at least 30 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
        $set = Copy-R17A2aObject -Value (Get-ValidFixtureSet)
        Invoke-Mutation -Set $set -Fixture $fixture
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 A2A contract tests failed."
}

Write-Output ("All R17 A2A contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
