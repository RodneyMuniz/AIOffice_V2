$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18FinalProofPackageAcceptanceRecommendation.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_final_proof_package_acceptance_recommendation.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_final_proof_package_acceptance_recommendation.ps1"
Import-Module $modulePath -Force

$paths = Get-R18FinalProofPackagePaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0
$initialStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"

function Invoke-RequiredCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$ScriptPath
    )

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed: $($output -join [Environment]::NewLine)"
    }
    Write-Output "PASS command: $Label"
}

function Get-ValidSet {
    return Get-R18FinalProofPackageSet -RepositoryRoot $repoRoot
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.FinalReport.runtime_flags,
        $Set.KpiScorecard.runtime_flags,
        $Set.FinalHead.runtime_flags,
        $Set.Recommendation.runtime_flags,
        $Set.RepairPlan.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.CheckReport.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18FinalProofPackageRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-028 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-028 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "evidence index covers R18-001 through R18-028"; script = { $set = Get-ValidSet; if (@($set.EvidenceIndex.task_entries).Count -ne 28) { throw "R18 task coverage missing." } } },
        @{ label = "recommendation remains recommendation-only"; script = { $set = Get-ValidSet; if ([bool]$set.Recommendation.operator_approval_granted -or $set.Recommendation.decision_packet_status -ne "recommendation_only_not_operator_approval") { throw "Recommendation granted approval." } } },
        @{ label = "closeout remains blocked pending operator approval"; script = { $set = Get-ValidSet; if (-not [bool]$set.FinalReport.closeout_assessment.closeout_blocked -or [bool]$set.FinalReport.closeout_assessment.milestone_closeout_claimed) { throw "Closeout was not blocked." } } },
        @{ label = "unresolved gaps remain explicit"; script = { $set = Get-ValidSet; if (@($set.FinalReport.unresolved_gap_summary).Count -lt 5) { throw "Unresolved gaps missing." } } },
        @{ label = "KPI weights sum to 100 and do not exceed targets"; script = { $set = Get-ValidSet; $sum = 0; foreach ($row in @($set.KpiScorecard.score_rows)) { $sum += [int]$row.weight; if ([int]$row.r18_final_score -gt [int]$row.target_score) { throw "KPI target exceeded." } }; if ($sum -ne 100) { throw "KPI weights do not sum to 100." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-028 only"; script = { Test-R18FinalProofPackageStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "no R19 or successor milestone is opened"; script = { $set = Get-ValidSet; if ([bool]$set.RepairPlan.successor_milestone_opened -or [bool]$set.RepairPlan.runtime_flags.r19_opened) { throw "Successor milestone opened." } } }
    )) {
    try {
        & $assertion.script
        Write-Output "PASS valid: $($assertion.label)."
        $validPassed += 1
    }
    catch {
        $failures += "FAIL $($assertion.label): $($_.Exception.Message)"
    }
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Get-Content -LiteralPath $fixtureFile.FullName -Raw | ConvertFrom-Json
    $mutatedSet = Copy-R18FinalProofPackageObject -Value (Get-ValidSet)
    $targetObject = Get-R18FinalProofPackageMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18FinalProofPackageMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

    try {
        Test-R18FinalProofPackageSet -Set $mutatedSet | Out-Null
        $failures += "FAIL invalid: $($fixtureFile.Name) was accepted."
    }
    catch {
        $message = $_.Exception.Message
        $matched = $false
        foreach ($fragment in @($fixture.expected_failure_fragments)) {
            if ($message -match [regex]::Escape([string]$fragment)) {
                $matched = $true
            }
        }
        if (-not $matched -and @($fixture.expected_failure_fragments).Count -gt 0) {
            $failures += "FAIL invalid: $($fixtureFile.Name) rejected with unexpected message: $message"
        }
        else {
            Write-Output "PASS invalid: $($fixtureFile.Name)"
            $invalidRejected += 1
        }
    }
}

$finalStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"
if ($initialStaged -ne $finalStaged) {
    $failures += "FAIL safety: R18-028 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 final proof package and acceptance recommendation tests failed."
}

Write-Output ("All R18 final proof package and acceptance recommendation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
