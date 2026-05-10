$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17StopRetryReentryControls.psm1"
Import-Module $modulePath -Force

$paths = Get-R17StopRetryReentryPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        ControlSet = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_control_packets.json")
        ReentrySet = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_reentry_packets.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17StopRetryReentrySet `
        -Contract $Set.Contract `
        -ControlSet $Set.ControlSet `
        -ReentrySet $Set.ReentrySet `
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
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)]$Fixture
    )

    switch ([string]$Fixture.target) {
        "control" {
            Set-R17StopRetryReentryObjectPathValue -TargetObject $Set.ControlSet.control_packets[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "reentry" {
            Set-R17StopRetryReentryObjectPathValue -TargetObject $Set.ReentrySet.reentry_packets[0] -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "control_evidence_append" {
            $Set.ControlSet.control_packets[0].evidence_refs += [string]$Fixture.value
        }
        "control_authority_append" {
            $Set.ControlSet.control_packets[0].authority_refs += [string]$Fixture.value
        }
        "control_validation_append" {
            $Set.ControlSet.control_packets[0].validation_refs += [string]$Fixture.value
        }
        "control_non_claim_append" {
            $Set.ControlSet.control_packets[0].non_claims += [string]$Fixture.value
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
    Test-R17StopRetryReentryControls -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-022 stop/retry/re-entry controls foundation validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-022 controls foundation: $($_.Exception.Message)"
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
if ($invalidFixtureFiles.Count -lt 36) {
    $failures += "FAIL fixture coverage: expected at least 36 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
        $set = Copy-R17StopRetryReentryObject -Value (Get-ValidFixtureSet)
        Invoke-Mutation -Set $set -Fixture $fixture
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 stop/retry/re-entry controls tests failed."
}

Write-Output ("All R17 stop/retry/re-entry controls tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
