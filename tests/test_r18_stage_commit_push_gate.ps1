$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18StageCommitPushGate.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_stage_commit_push_gate.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_stage_commit_push_gate.ps1"
Import-Module $modulePath -Force

$paths = Get-R18StageCommitPushPaths -RepositoryRoot $repoRoot
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
    return $output
}

function Get-ValidSet {
    return Get-R18StageCommitPushGateSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18StageCommitPushGateSet `
        -GateContract $Set.GateContract `
        -AssessmentContract $Set.AssessmentContract `
        -Profile $Set.Profile `
        -Inputs $Set.Inputs `
        -Assessments $Set.Assessments `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch -Wildcard ($Target) {
        "input:*" {
            $scenario = $Target.Substring("input:".Length)
            return @($Set.Inputs | Where-Object { $_.gate_scenario -eq $scenario })[0]
        }
        "assessment:*" {
            $scenario = $Target.Substring("assessment:".Length)
            return @($Set.Assessments | Where-Object { $_.gate_scenario -eq $scenario })[0]
        }
        "gate_contract" { return $Set.GateContract }
        "assessment_contract" { return $Set.AssessmentContract }
        "profile" { return $Set.Profile }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.GateContract.runtime_flags,
        $Set.AssessmentContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Inputs | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Assessments | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.assessment_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18StageCommitPushRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-017 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-017 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all six gate inputs exist"; script = { if (@((Get-ValidSet).Inputs).Count -ne 6) { throw "Expected six gate inputs." } } },
        @{ label = "all six assessments exist"; script = { if (@((Get-ValidSet).Assessments).Count -ne 6) { throw "Expected six assessments." } } },
        @{ label = "safe release candidate is policy-only and requires all gate checks"; script = { $set = Get-ValidSet; $input = @($set.Inputs | Where-Object { $_.gate_scenario -eq "safe_release_candidate" })[0]; $assessment = @($set.Assessments | Where-Object { $_.gate_scenario -eq "safe_release_candidate" })[0]; if (-not ([bool]$input.wip_safe -and [bool]$input.remote_safe -and [bool]$input.validation_passed -and [bool]$input.status_boundary_safe)) { throw "Safe input lacks a required passing check." }; if ($input.operator_approval_status -ne "valid_for_stage_commit_push_gate_future_policy_only") { throw "Safe input lacks valid operator approval status." }; if ($assessment.gate_status -ne "gate_passed_policy_only" -or $assessment.action_recommendation -ne "allow_future_stage_commit_push_after_runtime_gate") { throw "Safe assessment did not remain policy-only." } } },
        @{ label = "missing operator approval blocks stage commit push"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "blocked_by_missing_operator_approval" })[0]; if ([bool]$assessment.safe_to_stage -or [bool]$assessment.safe_to_commit -or [bool]$assessment.safe_to_push -or $assessment.action_recommendation -ne "request_operator_approval") { throw "Missing operator approval did not block all actions." } } },
        @{ label = "unsafe WIP blocks stage commit push"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "blocked_by_unsafe_wip" })[0]; if ([bool]$assessment.safe_to_stage -or [bool]$assessment.safe_to_commit -or [bool]$assessment.safe_to_push -or $assessment.action_recommendation -ne "stop_and_resolve_wip") { throw "Unsafe WIP did not block all actions." } } },
        @{ label = "unsafe remote branch blocks stage commit push"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "blocked_by_remote_branch" })[0]; if ([bool]$assessment.safe_to_stage -or [bool]$assessment.safe_to_commit -or [bool]$assessment.safe_to_push -or $assessment.action_recommendation -ne "stop_and_resolve_remote_branch") { throw "Unsafe remote branch did not block all actions." } } },
        @{ label = "failed validation blocks stage commit push"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "blocked_by_failed_validation" })[0]; if ([bool]$assessment.safe_to_stage -or [bool]$assessment.safe_to_commit -or [bool]$assessment.safe_to_push -or $assessment.action_recommendation -ne "stop_and_fix_validation") { throw "Failed validation did not block all actions." } } },
        @{ label = "status boundary drift blocks stage commit push"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.gate_scenario -eq "blocked_by_status_boundary_drift" })[0]; if ([bool]$assessment.safe_to_stage -or [bool]$assessment.safe_to_commit -or [bool]$assessment.safe_to_push -or $assessment.action_recommendation -ne "stop_and_fix_status_boundary") { throw "Status boundary drift did not block all actions." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no actual stage commit push is performed by the gate"; script = { $set = Get-ValidSet; foreach ($flags in @($set.GateContract.runtime_flags, $set.Results.runtime_flags, $set.Report.runtime_flags, $set.Snapshot.runtime_flags)) { if ([bool]$flags.stage_performed_by_gate -or [bool]$flags.commit_performed_by_gate -or [bool]$flags.push_performed_by_gate -or [bool]$flags.stage_performed -or [bool]$flags.commit_performed -or [bool]$flags.push_performed) { throw "Stage/commit/push was claimed." } } } },
        @{ label = "R18 is active through R18-020 only after status updates"; script = { Test-R18StageCommitPushStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-021 onward remain planned only"; script = { Test-R18StageCommitPushStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18StageCommitPushObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18StageCommitPushMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

    try {
        Invoke-SetValidation -Set $mutatedSet | Out-Null
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
    $failures += "FAIL safety: R18-017 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 stage/commit/push gate tests failed."
}

Write-Output ("All R18 stage/commit/push gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
