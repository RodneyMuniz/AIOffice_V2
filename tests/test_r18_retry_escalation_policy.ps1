$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RetryEscalationPolicy.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_retry_escalation_policy.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_retry_escalation_policy.ps1"
Import-Module $modulePath -Force

$paths = Get-R18RetryEscalationPaths -RepositoryRoot $repoRoot
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
    return Get-R18RetryEscalationPolicySet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18RetryEscalationPolicySet `
        -PolicyContract $Set.PolicyContract `
        -DecisionContract $Set.DecisionContract `
        -Profile $Set.Profile `
        -Scenarios $Set.Scenarios `
        -Decisions $Set.Decisions `
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
        "scenario:*" {
            $scenarioType = $Target.Substring("scenario:".Length)
            return @($Set.Scenarios | Where-Object { $_.scenario_type -eq $scenarioType })[0]
        }
        "decision:*" {
            $scenarioType = $Target.Substring("decision:".Length)
            return @($Set.Decisions | Where-Object { $_.scenario_type -eq $scenarioType })[0]
        }
        "policy_contract" { return $Set.PolicyContract }
        "decision_contract" { return $Set.DecisionContract }
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
        $Set.PolicyContract.runtime_flags,
        $Set.DecisionContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Scenarios | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Decisions | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18RetryEscalationRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-015 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-015 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all six scenarios and six decision packets exist"; script = { $set = Get-ValidSet; if (@($set.Scenarios).Count -ne 6 -or @($set.Decisions).Count -ne 6) { throw "Expected six scenarios and six decisions." } } },
        @{ label = "retry_allowed_after_compact_failure is policy-only and bounded"; script = { $scenario = @((Get-ValidSet).Scenarios | Where-Object { $_.scenario_type -eq "retry_allowed_after_compact_failure" })[0]; if (-not [bool]$scenario.retry_allowed -or [int]$scenario.retry_count -ge [int]$scenario.max_retry_count -or [bool]$scenario.unsafe_wip_present -or [bool]$scenario.unsafe_remote_state_present) { throw "Retry allowed policy scenario is not bounded and safe." } } },
        @{ label = "unsafe WIP blocks retry"; script = { $decision = @((Get-ValidSet).Decisions | Where-Object { $_.scenario_type -eq "retry_blocked_by_unsafe_wip" })[0]; if ([bool]$decision.retry_allowed -or -not [bool]$decision.operator_decision_required) { throw "Unsafe WIP did not block retry." } } },
        @{ label = "unsafe remote branch blocks retry"; script = { $decision = @((Get-ValidSet).Decisions | Where-Object { $_.scenario_type -eq "retry_blocked_by_remote_branch" })[0]; if ([bool]$decision.retry_allowed -or -not [bool]$decision.operator_decision_required) { throw "Unsafe remote did not block retry." } } },
        @{ label = "retry limit reached blocks retry and escalates"; script = { $decision = @((Get-ValidSet).Decisions | Where-Object { $_.scenario_type -eq "retry_limit_reached" })[0]; if ([bool]$decision.retry_allowed -or -not [bool]$decision.escalation_required -or [int]$decision.retry_count -lt [int]$decision.max_retry_count) { throw "Retry limit scenario did not block and escalate." } } },
        @{ label = "operator decision required routes to future R18-016"; script = { $decision = @((Get-ValidSet).Decisions | Where-Object { $_.scenario_type -eq "operator_decision_required" })[0]; if ([bool]$decision.retry_allowed -or -not [bool]$decision.operator_decision_required -or [string]$decision.next_safe_step -notmatch "R18-016") { throw "Operator decision scenario does not route to future R18-016." } } },
        @{ label = "block_until_future_runtime does not claim execution"; script = { $decision = @((Get-ValidSet).Decisions | Where-Object { $_.scenario_type -eq "block_until_future_runtime" })[0]; if ([bool]$decision.retry_allowed -or [string]$decision.action_recommendation -ne "block_until_r18_016_or_later") { throw "Future-runtime block scenario did not block." }; Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no forbidden runtime or success claims exist"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null; Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-015 only after status updates"; script = { Test-R18RetryEscalationPolicyStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-020 onward remain planned only"; script = { Test-R18RetryEscalationPolicyStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18RetryEscalationObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18RetryEscalationPolicyMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-015 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 retry escalation policy tests failed."
}

Write-Output ("All R18 retry escalation policy tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
