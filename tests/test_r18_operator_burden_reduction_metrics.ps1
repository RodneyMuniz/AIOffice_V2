$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorBurdenReductionMetrics.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_operator_burden_reduction_metrics.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_operator_burden_reduction_metrics.ps1"
Import-Module $modulePath -Force

$paths = Get-R18OperatorBurdenReductionMetricsPaths -RepositoryRoot $repoRoot
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
    return Get-R18OperatorBurdenReductionMetricsSet -RepositoryRoot $repoRoot
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.RunnerLogSummary.runtime_flags,
        $Set.ApprovalCounts.runtime_flags,
        $Set.ValidationPacket.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.CheckReport.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18OperatorBurdenReductionMetricsRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-027 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-027 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "counts distinguish recovery evidence from operator approvals"; script = { $set = Get-ValidSet; if ([int]$set.Report.routine_vs_operator_distinction.routine_recovery_automation_executed_count -ne 0 -or [int]$set.Report.routine_vs_operator_distinction.operator_approval_decision_count -lt 1) { throw "Routine recovery automation and operator approvals were not distinguished." } } },
        @{ label = "runner log and continuation counts are present"; script = { $set = Get-ValidSet; if ([int]$set.RunnerLogSummary.runner_log_entry_count -lt 1 -or [int]$set.RunnerLogSummary.continuation_event_count -lt 1) { throw "Runner log or continuation counts missing." } } },
        @{ label = "manual transfer success remains unproved and false"; script = { $set = Get-ValidSet; if ([bool]$set.Report.burden_reduction_assessment.no_manual_prompt_transfer_success_claimed -or [bool]$set.Report.burden_reduction_assessment.burden_reduction_proven) { throw "No-manual success or burden reduction was overclaimed." } } },
        @{ label = "insufficient evidence fail-closed behavior is recorded"; script = { $set = Get-ValidSet; if (-not [bool]$set.ValidationPacket.failure_retry_behavior.insufficient_evidence_marks_unproved -or -not [bool]$set.Report.failure_retry_behavior.no_manual_prompt_transfer_success_kept_false) { throw "Fail-closed burden behavior missing." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-028 only after status updates"; script = { Test-R18OperatorBurdenReductionMetricsStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-028 final package boundary is preserved"; script = { Test-R18OperatorBurdenReductionMetricsStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18OperatorBurdenReductionMetricsObject -Value (Get-ValidSet)
    $targetObject = Get-R18OperatorBurdenReductionMetricsMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18OperatorBurdenReductionMetricsMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

    try {
        Test-R18OperatorBurdenReductionMetricsSet -Set $mutatedSet | Out-Null
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
    $failures += "FAIL safety: R18-027 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 operator burden reduction metrics tests failed."
}

Write-Output ("All R18 operator burden reduction metrics tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
