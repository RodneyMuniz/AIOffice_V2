$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RemoteBranchVerifier.psm1"
$validator = Join-Path $repoRoot "tools\validate_r18_remote_branch_verifier.ps1"
Import-Module $modulePath -Force

$paths = Get-R18RemoteBranchVerifierPaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0
$initialTracked = (& git -C $repoRoot diff --name-only) -join "`n"
$initialStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

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

function Get-Samples {
    return @(Get-ChildItem -LiteralPath $paths.SampleRoot -Filter "*.sample.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-Verifications {
    return @(Get-ChildItem -LiteralPath $paths.PacketRoot -Filter "*.verification.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Profile = Read-TestJson -Path $paths.Profile
        Samples = @(Get-Samples)
        Verifications = @(Get-Verifications)
        CurrentVerification = Read-TestJson -Path $paths.CurrentVerification
        Results = Read-TestJson -Path $paths.Results
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18RemoteBranchVerifierSet `
        -Contract $Set.Contract `
        -Profile $Set.Profile `
        -Samples $Set.Samples `
        -Verifications $Set.Verifications `
        -CurrentVerification $Set.CurrentVerification `
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
        "contract" { return $Set.Contract }
        "profile" { return $Set.Profile }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        "current" { return $Set.CurrentVerification }
        "sample:*" {
            $type = $Target.Substring("sample:".Length)
            return @($Set.Samples | Where-Object { $_.sample_type -eq $type })[0]
        }
        "verification:*" {
            $type = $Target.Substring("verification:".Length)
            return @($Set.Verifications | Where-Object { $_.source_sample_ref -like "*$type.sample.json" })[0]
        }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "remote_branch_verifier_live_runtime_executed",
        "branch_mutation_performed",
        "remote_branch_mutation_performed",
        "pull_performed",
        "rebase_performed",
        "reset_performed",
        "merge_performed",
        "checkout_or_switch_performed",
        "clean_performed",
        "restore_performed",
        "staging_performed",
        "commit_performed",
        "push_performed",
        "continuation_packet_generated",
        "new_context_prompt_generated",
        "recovery_runtime_implemented",
        "recovery_action_performed",
        "wip_cleanup_performed",
        "wip_abandonment_performed",
        "work_order_execution_performed",
        "live_runner_runtime_executed",
        "board_runtime_mutation_performed",
        "live_agent_runtime_invoked",
        "live_skill_execution_performed",
        "a2a_message_sent",
        "live_a2a_runtime_implemented",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_performed",
        "automatic_new_thread_creation_performed",
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_013_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.CurrentVerification.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Samples | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Verifications | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.verification_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Get-VerificationBySampleType {
    param([Parameter(Mandatory = $true)][object]$Set, [Parameter(Mandatory = $true)][string]$SampleType)
    return @($Set.Verifications | Where-Object { $_.source_sample_ref -like "*$SampleType.sample.json" })[0]
}

function Assert-VerificationSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    $expected = @{
        remote_in_sync = @{ status = "remote_in_sync_safe"; safe = $true; decision = $false; action = "continue_without_branch_action" }
        remote_ahead = @{ status = "remote_ahead_blocked"; safe = $false; decision = $true; action = "stop_remote_ahead_requires_operator_decision" }
        local_ahead = @{ status = "local_ahead_review_required"; safe = $false; decision = $true; action = "review_local_ahead_before_push" }
        diverged = @{ status = "diverged_operator_decision_required"; safe = $false; decision = $true; action = "stop_diverged_requires_operator_decision" }
        wrong_branch = @{ status = "wrong_branch_blocked"; safe = $false; decision = $true; action = "stop_wrong_branch" }
        missing_remote_ref = @{ status = "missing_remote_ref_blocked"; safe = $false; decision = $true; action = "stop_missing_remote_ref" }
    }

    foreach ($sampleType in $expected.Keys) {
        $verification = Get-VerificationBySampleType -Set $Set -SampleType $sampleType
        if ($verification.verification_status -ne $expected[$sampleType].status) {
            throw "$sampleType classified as $($verification.verification_status), expected $($expected[$sampleType].status)."
        }
        if ([bool]$verification.safe_to_continue -ne [bool]$expected[$sampleType].safe) {
            throw "$sampleType safe_to_continue mismatch."
        }
        if ([bool]$verification.operator_decision_required -ne [bool]$expected[$sampleType].decision) {
            throw "$sampleType operator_decision_required mismatch."
        }
        if ($verification.action_recommendation -ne $expected[$sampleType].action) {
            throw "$sampleType action_recommendation mismatch."
        }
    }
}

function Assert-CurrentVerificationInSyncWhenAligned {
    param([Parameter(Mandatory = $true)][object]$Set)

    $current = $Set.CurrentVerification
    if ($current.expected_branch -eq $current.actual_branch -and $current.local_head -eq $current.actual_remote_head -and $current.local_head -eq $current.expected_remote_head) {
        if ($current.verification_status -ne "remote_in_sync_safe") {
            throw "Current aligned branch/head/remote did not classify as remote_in_sync_safe."
        }
        if ([bool]$current.safe_to_continue -ne $true) {
            throw "Current aligned branch/head/remote was not marked branch-identity safe."
        }
        if ([string]::IsNullOrWhiteSpace([string]$current.local_tree)) {
            throw "Current aligned verification lacks local tree."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-012 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-012 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all valid samples classify correctly"; script = { Assert-VerificationSemantics -Set (Get-ValidSet) } },
        @{ label = "remote ahead is blocked"; script = { if ([bool](Get-VerificationBySampleType -Set (Get-ValidSet) -SampleType "remote_ahead").safe_to_continue) { throw "remote_ahead was marked safe." } } },
        @{ label = "diverged is blocked"; script = { if ([bool](Get-VerificationBySampleType -Set (Get-ValidSet) -SampleType "diverged").safe_to_continue) { throw "diverged was marked safe." } } },
        @{ label = "wrong branch is blocked"; script = { if ([bool](Get-VerificationBySampleType -Set (Get-ValidSet) -SampleType "wrong_branch").safe_to_continue) { throw "wrong_branch was marked safe." } } },
        @{ label = "missing remote ref is blocked"; script = { if ([bool](Get-VerificationBySampleType -Set (Get-ValidSet) -SampleType "missing_remote_ref").safe_to_continue) { throw "missing_remote_ref was marked safe." } } },
        @{ label = "local ahead is review-required not push-safe"; script = { $localAhead = Get-VerificationBySampleType -Set (Get-ValidSet) -SampleType "local_ahead"; if ($localAhead.verification_status -ne "local_ahead_review_required" -or [bool]$localAhead.safe_to_continue) { throw "local_ahead was not review-required and blocked." } } },
        @{ label = "current verification matches expected branch/head/tree/remote when in sync"; script = { Assert-CurrentVerificationInSyncWhenAligned -Set (Get-ValidSet) } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no continuation/new-context/recovery/WIP cleanup/branch mutation/pull-rebase-reset-merge/stage-commit-push claims exist"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-014 only"; script = { Test-R18RemoteBranchVerifierStatusTruth -RepositoryRoot $repoRoot } }
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
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R18RemoteBranchVerifierObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18RemoteBranchVerifierMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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

$finalTracked = (& git -C $repoRoot diff --name-only) -join "`n"
if ($initialTracked -ne $finalTracked) {
    $failures += "FAIL safety: R18-012 tests changed the tracked worktree diff."
}

$finalStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"
if ($initialStaged -ne $finalStaged) {
    $failures += "FAIL safety: R18-012 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 remote branch verifier tests failed."
}

Write-Output ("All R18 remote branch verifier tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
