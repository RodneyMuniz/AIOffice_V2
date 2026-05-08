$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17ToolAdapterContract.psm1"
Import-Module $modulePath -Force

$paths = Get-R17ToolAdapterContractPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        SeedProfiles = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_seed_profiles.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17ToolAdapterContractSet `
        -Contract $Set.Contract `
        -SeedProfiles $Set.SeedProfiles `
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
        "seed_profiles" { return $Set.SeedProfiles }
        "profile" { return (@($Set.SeedProfiles.adapter_profiles) | Select-Object -First 1) }
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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17tooladapter" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    Test-R17ToolAdapterContract -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-015 tool adapter contract validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-015 tool adapter contract: $($_.Exception.Message)"
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
        "seed_profiles" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17ToolAdapterContractObject -Value (Get-ValidFixtureSet)
                switch ([string]$fixture.operation) {
                    "missing_seed_adapter_profiles" {
                        $set.SeedProfiles.adapter_profiles = @()
                        $set.SeedProfiles.profile_count = 0
                    }
                    "duplicate_adapter_id" {
                        $duplicate = Copy-R17ToolAdapterContractObject -Value (@($set.SeedProfiles.adapter_profiles) | Select-Object -First 1)
                        $set.SeedProfiles.adapter_profiles = @($set.SeedProfiles.adapter_profiles) + $duplicate
                        $set.SeedProfiles.profile_count = @($set.SeedProfiles.adapter_profiles).Count
                        $set.Snapshot.total_seed_profiles = @($set.SeedProfiles.adapter_profiles).Count
                    }
                    default { throw "Unsupported seed_profiles operation '$($fixture.operation)'." }
                }
                Invoke-TestSet -Set $set | Out-Null
            }
        }
        "fixture_coverage" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $emptyFixtureRoot = Join-Path $tempRoot "empty-fixtures"
                New-Item -ItemType Directory -Path $emptyFixtureRoot -Force | Out-Null
                Assert-R17ToolAdapterContractFixtureCoverage -FixtureRoot $emptyFixtureRoot -MinimumInvalidFixtureCount 50
            }
        }
        "ui_text" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17ToolAdapterContractUiText -UiTextByPath @{ "index.html" = [string]$fixture.text }
            }
        }
        "kanban_js" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17ToolAdapterContractKanbanJsUnchanged -RepositoryRoot $repoRoot -ChangedPaths @("scripts/operator_wall/r17_kanban_mvp/kanban.js")
            }
        }
        default {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17ToolAdapterContractObject -Value (Get-ValidFixtureSet)
                $target = Get-MutationTarget -Set $set -Target ([string]$fixture.target)
                Invoke-R17ToolAdapterContractMutation -TargetObject $target -Mutation $fixture | Out-Null
                Invoke-TestSet -Set $set | Out-Null
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 tool adapter contract tests failed."
}

Write-Output ("All R17 tool adapter contract tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
