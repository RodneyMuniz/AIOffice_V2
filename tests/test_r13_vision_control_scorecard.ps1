$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13VisionControlScorecard.psm1") -Force -PassThru
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$testScorecard = $module.ExportedCommands["Test-R13VisionControlScorecardContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$validScorecard = Join-Path $repoRoot "state\vision_control\r13_015_vision_control_scorecard.json"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r13visioncontrol" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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
    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-MutatedScorecardPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $scorecard = Get-JsonDocument -Path $validScorecard
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

    $validResult = & $testScorecard -ScorecardPath $validScorecard
    Write-Output ("PASS valid R13 Vision Control scorecard: items {0}, R13 aggregate {1}, uplift from reported R12 {2}" -f $validResult.ItemCount, $validResult.R13Aggregate, $validResult.UpliftFromReportedR12)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-item-score-math" -RequiredFragments @("r13_score", "must equal") -Action {
        $path = New-MutatedScorecardPath -Label "item-score-math" -Mutation {
            param($scorecard)
            $scorecard.items[0].r13_score = 10
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-planning-only-uplift" -RequiredFragments @("uplift", "committed") -Action {
        $path = New-MutatedScorecardPath -Label "planning-only-uplift" -Mutation {
            param($scorecard)
            $item = @($scorecard.items | Where-Object { $_.item_id -eq "architecture_agent_skill_execution_architecture" })[0]
            $item.evidence_ref_ids = @("r13-methodology-report")
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-progress-overclaim" -RequiredFragments @("10 to 15 percent", "uplift") -Action {
        $path = New-MutatedScorecardPath -Label "progress-overclaim" -Mutation {
            param($scorecard)
            $scorecard.weighted_aggregate.ten_to_fifteen_percent_progress_claimed = $true
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-penalty-value" -RequiredFragments @("penalty value", "manual_chat_bridge") -Action {
        $path = New-MutatedScorecardPath -Label "penalty-value" -Mutation {
            param($scorecard)
            $item = @($scorecard.items | Where-Object { $_.item_id -eq "workflow_copy_paste_reduction_low_touch_cycle" })[0]
            $item.penalties[0].value = -5
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-evidence-ref" -RequiredFragments @("does not exist") -Action {
        $path = New-MutatedScorecardPath -Label "missing-evidence-ref" -Mutation {
            param($scorecard)
            $scorecard.evidence_refs[0].ref = "state/vision_control/missing-evidence.json"
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claim" -RequiredFragments @("non_claims", "R13 is not closed") -Action {
        $path = New-MutatedScorecardPath -Label "missing-non-claim" -Mutation {
            param($scorecard)
            $scorecard.non_claims = @($scorecard.non_claims | Where-Object { $_ -ne "R13 is not closed" })
        }
        & $testScorecard -ScorecardPath $path | Out-Null
    }
}
catch {
    $failures += ("FAIL R13 Vision Control scorecard harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 Vision Control scorecard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 Vision Control scorecard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
