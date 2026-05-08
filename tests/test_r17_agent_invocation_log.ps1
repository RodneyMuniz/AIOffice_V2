$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentInvocationLog.psm1"
Import-Module $modulePath -Force

$paths = Get-R17AgentInvocationLogPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        Records = @((Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_invocation_log_records.json")))
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_ui_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R17AgentInvocationLogSet `
        -Contract $Set.Contract `
        -InvocationRecords $Set.Records `
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
        "record" { return (@($Set.Records) | Select-Object -First 1) }
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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17invocationlog" + [guid]::NewGuid().ToString("N").Substring(0, 8))

try {
    Test-R17AgentInvocationLog -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-014 agent invocation log validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-014 agent invocation log: $($_.Exception.Message)"
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
if ($invalidFixtureFiles.Count -lt 40) {
    $failures += "FAIL fixture coverage: expected at least 40 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    switch ([string]$fixture.target) {
        "files" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17AgentInvocationLogObject -Value (Get-ValidFixtureSet)
                switch ([string]$fixture.operation) {
                    "missing_invocation_log" {
                        Test-R17AgentInvocationLogSet -Contract $set.Contract -InvocationRecords $null -Report $set.Report -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
                    }
                    "missing_check_report" {
                        Test-R17AgentInvocationLogSet -Contract $set.Contract -InvocationRecords $set.Records -Report $null -Snapshot $set.Snapshot -RepositoryRoot $repoRoot -SkipUiFiles -SkipFixtureCoverage | Out-Null
                    }
                    default { throw "Unsupported files operation '$($fixture.operation)'." }
                }
            }
        }
        "jsonl" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
                $badPath = Join-Path $tempRoot "malformed.jsonl"
                Set-Content -LiteralPath $badPath -Value "{ bad json" -Encoding UTF8
                Read-R17AgentInvocationLogJsonLines -Path $badPath | Out-Null
            }
        }
        "log" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17AgentInvocationLogObject -Value (Get-ValidFixtureSet)
                if ([string]$fixture.operation -eq "duplicate_invocation_id") {
                    $duplicate = Copy-R17AgentInvocationLogObject -Value (@($set.Records) | Select-Object -First 1)
                    $set.Records = @($set.Records) + $duplicate
                    $set.Report.total_invocation_records = @($set.Records).Count
                    $set.Snapshot.total_seed_records = @($set.Records).Count
                }
                Invoke-TestSet -Set $set | Out-Null
            }
        }
        "fixture_coverage" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $emptyFixtureRoot = Join-Path $tempRoot "empty-fixtures"
                New-Item -ItemType Directory -Path $emptyFixtureRoot -Force | Out-Null
                Assert-R17AgentInvocationLogFixtureCoverage -FixtureRoot $emptyFixtureRoot -MinimumInvalidFixtureCount 40
            }
        }
        "ui_text" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17AgentInvocationLogUiText -UiTextByPath @{ "index.html" = [string]$fixture.text }
            }
        }
        "kanban_js" {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                Assert-R17AgentInvocationLogKanbanJsUnchanged -RepositoryRoot $repoRoot -ChangedPaths @("scripts/operator_wall/r17_kanban_mvp/kanban.js")
            }
        }
        default {
            Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
                $set = Copy-R17AgentInvocationLogObject -Value (Get-ValidFixtureSet)
                $target = Get-MutationTarget -Set $set -Target ([string]$fixture.target)
                Invoke-R17AgentInvocationLogMutation -TargetObject $target -Mutation $fixture | Out-Null
                Invoke-TestSet -Set $set | Out-Null
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 agent invocation log tests failed."
}

Write-Output ("All R17 agent invocation log tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
