$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17QaTestAgentAdapter.psm1"
Import-Module $modulePath -Force

$paths = Get-R17QaTestAgentAdapterPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        RequestPacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_request_packet.json")
        ResultPacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_result_packet.json")
        DefectPacket = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_defect_packet.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17QaTestAgentAdapterSet `
        -Contract $Set.Contract `
        -RequestPacket $Set.RequestPacket `
        -ResultPacket $Set.ResultPacket `
        -DefectPacket $Set.DefectPacket `
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
        "result" { return $Set.ResultPacket }
        "defect" { return $Set.DefectPacket }
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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17qaadapter" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    Test-R17QaTestAgentAdapter -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-017 QA/Test Agent adapter packet foundation validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-017 QA/Test Agent adapter packet foundation: $($_.Exception.Message)"
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
if ($invalidFixtureFiles.Count -lt 55) {
    $failures += "FAIL fixture coverage: expected at least 55 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    switch ([string]$fixture.target) {
        "missing_request" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17QaTestAgentAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17QaTestAgentAdapterSet -Contract $set.Contract -RequestPacket $null -ResultPacket $set.ResultPacket -DefectPacket $set.DefectPacket -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_result" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17QaTestAgentAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17QaTestAgentAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResultPacket $null -DefectPacket $set.DefectPacket -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_defect" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17QaTestAgentAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17QaTestAgentAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResultPacket $set.ResultPacket -DefectPacket $null -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "missing_report" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17QaTestAgentAdapterObject -Value (Get-ValidFixtureSet)
                Test-R17QaTestAgentAdapterSet -Contract $set.Contract -RequestPacket $set.RequestPacket -ResultPacket $set.ResultPacket -DefectPacket $set.DefectPacket -Report $null -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
            }
        }
        "fixture_coverage" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $emptyFixtureRoot = Join-Path $tempRoot "empty-fixtures"
                New-Item -ItemType Directory -Path $emptyFixtureRoot -Force | Out-Null
                Assert-R17QaTestAgentAdapterFixtureCoverage -FixtureRoot $emptyFixtureRoot -MinimumInvalidFixtureCount 55
            }
        }
        "ui_text" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17QaTestAgentAdapterUiText -UiTextByPath @{ "index.html" = [string]$fixture.text; "styles.css" = ""; "README.md" = "" }
            }
        }
        "kanban_js" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17QaTestAgentAdapterKanbanJsUnchanged -RepositoryRoot $repoRoot -ChangedPaths @("scripts/operator_wall/r17_kanban_mvp/kanban.js")
            }
        }
        default {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17QaTestAgentAdapterObject -Value (Get-ValidFixtureSet)
                $target = Get-MutationTarget -Set $set -Target ([string]$fixture.target)
                Invoke-R17QaTestAgentAdapterMutation -TargetObject $target -Mutation $fixture | Out-Null
                Invoke-TestSet -Set $set | Out-Null
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 QA/Test Agent adapter tests failed."
}

Write-Output ("All R17 QA/Test Agent adapter tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
