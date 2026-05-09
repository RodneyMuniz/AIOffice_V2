$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolCallLedger.psm1"
Import-Module $modulePath -Force

$paths = Get-R17ToolCallLedgerPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    $recordsJson = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ledger_records.json")
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        Records = @($recordsJson | ForEach-Object { $_ })
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17ToolCallLedgerSet `
        -Contract $Set.Contract `
        -Records $Set.Records `
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
        "record" {
            Set-R17ToolCallLedgerObjectPathValue -TargetObject $Set.Records[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "runtime_flag" {
            Set-R17ToolCallLedgerObjectPathValue -TargetObject $Set.Records[0].runtime_flags -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "evidence_append" {
            $Set.Records[0].evidence_refs += [string]$Fixture.value
        }
        "non_claim_append" {
            $Set.Records[0].non_claims += [string]$Fixture.value
        }
        "duplicate_record" {
            $Set.Records[1].ledger_record_id = $Set.Records[0].ledger_record_id
        }
        "remove_property" {
            Remove-R17ToolCallLedgerObjectPathValue -TargetObject $Set.Records[0] -Path ([string]$Fixture.property)
        }
        "fixture_coverage" {
            $emptyFixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17ledgerempty" + [guid]::NewGuid().ToString("N").Substring(0, 8))
            New-Item -ItemType Directory -Path $emptyFixtureRoot -Force | Out-Null
            Assert-R17ToolCallLedgerFixtureCoverage -FixtureRoot $emptyFixtureRoot
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
    Test-R17ToolCallLedger -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-019 tool-call ledger foundation validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-019 tool-call ledger foundation: $($_.Exception.Message)"
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
if ($invalidFixtureFiles.Count -lt 24) {
    $failures += "FAIL fixture coverage: expected at least 24 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
        $set = Copy-R17ToolCallLedgerObject -Value (Get-ValidFixtureSet)
        Invoke-Mutation -Set $set -Fixture $fixture
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 tool-call ledger tests failed."
}

Write-Output ("All R17 tool-call ledger tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
