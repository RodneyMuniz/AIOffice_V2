$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ValueScorecard.psm1") -Force -PassThru
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$testValueScorecard = $module.ExportedCommands["Test-ValueScorecardContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\value_scorecard\r12_value_scorecard.valid.json"
$baselineFixture = Join-Path $repoRoot "state\value_scorecards\r12_baseline.json"
$invalidFixtureRoot = Join-Path $repoRoot "state\fixtures\invalid\value_scorecard"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12valuescorecard" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

function New-MutatedScorecardPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $scorecard = Get-JsonDocument -Path $validFixture
    & $Mutation $scorecard
    $path = Join-Path $tempRoot ("$Label.json")
    Write-JsonDocument -Path $path -Document $scorecard
    return $path
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

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $baselineResult = & $testValueScorecard -ScorecardPath $baselineFixture
    Write-Output ("PASS valid baseline scorecard: baseline {0}, target {1}, proved {2}" -f $baselineResult.CorrectedBaseline, $baselineResult.CorrectedTarget, $baselineResult.CorrectedProved)
    $validPassed += 1

    $validResult = & $testValueScorecard -ScorecardPath $validFixture
    Write-Output ("PASS valid fixture scorecard: dimensions {0}, uplift {1}" -f $validResult.DimensionCount, $validResult.CorrectedUplift)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-overclaim-without-value-gates" -RequiredFragments @("10 percent", "value gates proved") -Action {
        & $testValueScorecard -ScorecardPath (Join-Path $invalidFixtureRoot "r12_value_scorecard.overclaim.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-proof-refs" -RequiredFragments @("proved_score increased", "proof_refs") -Action {
        & $testValueScorecard -ScorecardPath (Join-Path $invalidFixtureRoot "r12_value_scorecard.missing-proof-refs.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-target-as-proved" -RequiredFragments @("target-as-proved") -Action {
        & $testValueScorecard -ScorecardPath (Join-Path $invalidFixtureRoot "r12_value_scorecard.target-as-proved.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-dimension" -RequiredFragments @("missing required dimension", "governance_proof_discipline") -Action {
        $path = New-MutatedScorecardPath -Label "missing-dimension" -Mutation {
            param($scorecard)
            $scorecard.dimensions = @($scorecard.dimensions | Where-Object { $_.dimension -ne "governance_proof_discipline" })
        }
        & $testValueScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-planning-report-as-proof" -RequiredFragments @("planning report", "proof") -Action {
        $path = New-MutatedScorecardPath -Label "planning-report-as-proof" -Mutation {
            param($scorecard)
            $scorecard.dimensions[0].proved_score = 12
            $scorecard.dimensions[0].proof_refs = @("governance/reports/AIOffice_V2_R11_Audit_and_R12_Planning_Report_v1.md")
            $scorecard.corrected_total.proved_score = 40
            $scorecard.corrected_total.uplift_from_baseline = 1
        }
        & $testValueScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims", "no R13 or successor opened") -Action {
        $path = New-MutatedScorecardPath -Label "missing-non-claims" -Mutation {
            param($scorecard)
            $scorecard.non_claims = @($scorecard.non_claims | Where-Object { $_ -ne "no R13 or successor opened" })
        }
        & $testValueScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-weight-drift" -RequiredFragments @("weight drift", "expected 25") -Action {
        & $testValueScorecard -ScorecardPath (Join-Path $invalidFixtureRoot "r12_value_scorecard.weight-drift.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL value scorecard harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Value scorecard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All value scorecard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
