$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17EvidenceAuditorApiAdapter.psm1"
Import-Module $modulePath -Force

$paths = Get-R17EvidenceAuditorApiAdapterPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        RequestPacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_request_packet.json")
        ResponsePacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_response_packet.json")
        VerdictPacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_verdict_packet.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17EvidenceAuditorApiAdapterSet `
        -Contract $Set.Contract `
        -RequestPacket $Set.RequestPacket `
        -ResponsePacket $Set.ResponsePacket `
        -VerdictPacket $Set.VerdictPacket `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot `
        -SkipUiFiles `
        -SkipFixtureCoverage
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "contract" { return $Set.Contract }
        "request" { return $Set.RequestPacket }
        "response" { return $Set.ResponsePacket }
        "verdict" { return $Set.VerdictPacket }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
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

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17evidenceadapter" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    Test-R17EvidenceAuditorApiAdapter -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-018 Evidence Auditor API adapter packet foundation validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-018 Evidence Auditor API adapter packet foundation: $($_.Exception.Message)"
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
if ($invalidFixtureFiles.Count -lt 50) {
    $failures += "FAIL fixture coverage: expected at least 50 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    switch ([string]$fixture.target) {
        "missing_request" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17EvidenceAuditorApiAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17EvidenceAuditorApiAdapterSet -Contract $set.Contract -RequestPacket $null -ResponsePacket $set.ResponsePacket -VerdictPacket $set.VerdictPacket -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_response" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17EvidenceAuditorApiAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17EvidenceAuditorApiAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResponsePacket $null -VerdictPacket $set.VerdictPacket -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_verdict" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17EvidenceAuditorApiAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17EvidenceAuditorApiAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResponsePacket $set.ResponsePacket -VerdictPacket $null -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_report" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17EvidenceAuditorApiAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17EvidenceAuditorApiAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResponsePacket $set.ResponsePacket -VerdictPacket $set.VerdictPacket -Report $null -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "fixture_coverage" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $emptyFixtureRoot = Join-Path $tempRoot "empty-fixtures"
                New-Item -ItemType Directory -Path $emptyFixtureRoot -Force | Out-Null
                Assert-R17EvidenceAuditorApiAdapterFixtureCoverage -FixtureRoot $emptyFixtureRoot -MinimumInvalidFixtureCount 50
            }
        }
        "ui_text" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17EvidenceAuditorApiAdapterUiText -UiTextByPath @{ "index.html" = [string]$fixture.text; "styles.css" = ""; "README.md" = "" }
            }
        }
        "kanban_js" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17EvidenceAuditorApiAdapterKanbanJsUnchanged -RepositoryRoot $repoRoot -ChangedPaths @("scripts/operator_wall/r17_kanban_mvp/kanban.js")
            }
        }
        default {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17EvidenceAuditorApiAdapterObject -Value (Get-ValidFixtureSet)
                $target = Get-MutationTarget -Set $set -Target ([string]$fixture.target)
                Invoke-R17EvidenceAuditorApiAdapterMutation -TargetObject $target -Mutation $fixture | Out-Null
                Invoke-TestSet -Set $set | Out-Null
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 Evidence Auditor API adapter tests failed."
}

Write-Output ("All R17 Evidence Auditor API adapter tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
