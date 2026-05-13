$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18EvidencePackageWrapper.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_evidence_package_wrapper.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_evidence_package_wrapper.ps1"
Import-Module $modulePath -Force

$paths = Get-R18EvidencePackageWrapperPaths -RepositoryRoot $repoRoot
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
    return Get-R18EvidencePackageWrapperSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18EvidencePackageWrapperSet `
        -WrapperContract $Set.WrapperContract `
        -ManifestContract $Set.ManifestContract `
        -Profile $Set.Profile `
        -Inputs $Set.Inputs `
        -Manifest $Set.Manifest `
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
            return @($Set.Inputs | Where-Object { $_.package_scenario -eq $scenario })[0]
        }
        "assessment:*" {
            $scenario = $Target.Substring("assessment:".Length)
            return @($Set.Assessments | Where-Object { $_.package_scenario -eq $scenario })[0]
        }
        "manifest_task:*" {
            $taskId = $Target.Substring("manifest_task:".Length)
            return @($Set.Manifest.task_entries | Where-Object { $_.task_id -eq $taskId })[0]
        }
        "wrapper_contract" { return $Set.WrapperContract }
        "manifest_contract" { return $Set.ManifestContract }
        "profile" { return $Set.Profile }
        "manifest" { return $Set.Manifest }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.WrapperContract.runtime_flags,
        $Set.ManifestContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Manifest.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Inputs | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Assessments | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.assessment_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18EvidencePackageWrapperRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-019 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-019 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all six inputs exist"; script = { if (@((Get-ValidSet).Inputs).Count -ne 6) { throw "Expected six inputs." } } },
        @{ label = "all six assessments exist"; script = { if (@((Get-ValidSet).Assessments).Count -ne 6) { throw "Expected six assessments." } } },
        @{ label = "current manifest covers R18-001 through R18-019"; script = { $entries = @((Get-ValidSet).Manifest.task_entries); foreach ($taskNumber in 1..19) { $taskId = "R18-{0}" -f $taskNumber.ToString("000"); if (@($entries | Where-Object { $_.task_id -eq $taskId }).Count -ne 1) { throw "Manifest missing $taskId." } } } },
        @{ label = "every completed task has proof-review and validation-manifest refs"; script = { foreach ($entry in @((Get-ValidSet).Manifest.task_entries)) { if ([string]::IsNullOrWhiteSpace([string]$entry.proof_review_ref)) { throw "Missing proof review for $($entry.task_id)." }; if ([string]::IsNullOrWhiteSpace([string]$entry.validation_manifest_ref)) { throw "Missing validation manifest for $($entry.task_id)." } } } },
        @{ label = "missing proof review blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.package_scenario -eq "missing_proof_review" })[0]; if ($assessment.assessment_status -ne "evidence_package_blocked_missing_proof_review" -or [bool]$assessment.safe_for_future_audit) { throw "missing_proof_review did not block." } } },
        @{ label = "missing validation manifest blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.package_scenario -eq "missing_validation_manifest" })[0]; if ($assessment.assessment_status -ne "evidence_package_blocked_missing_validation_manifest" -or [bool]$assessment.safe_for_future_audit) { throw "missing_validation_manifest did not block." } } },
        @{ label = "missing status surface blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.package_scenario -eq "missing_status_surface" })[0]; if ($assessment.assessment_status -ne "evidence_package_blocked_missing_status_surface" -or [bool]$assessment.safe_for_future_audit) { throw "missing_status_surface did not block." } } },
        @{ label = "runtime overclaim blocks"; script = { $assessment = @((Get-ValidSet).Assessments | Where-Object { $_.package_scenario -eq "runtime_overclaim" })[0]; if ($assessment.assessment_status -ne "evidence_package_blocked_runtime_overclaim" -or [bool]$assessment.safe_for_future_audit -or -not [bool]$assessment.runtime_overclaim_detected) { throw "runtime_overclaim did not block." } } },
        @{ label = "CI replay gap is disclosed and does not claim CI"; script = { $set = Get-ValidSet; $assessment = @($set.Assessments | Where-Object { $_.package_scenario -eq "ci_replay_gap_known" })[0]; if ($assessment.assessment_status -ne "evidence_package_attention_ci_replay_gap_known" -or -not [bool]$assessment.ci_gap_disclosed -or [bool]$assessment.ci_replay_claimed) { throw "CI replay gap assessment is invalid." }; if ($set.Manifest.ci_replay_status -ne "not_performed_known_gap" -or @($set.Manifest.ci_replay_evidence_refs).Count -ne 0) { throw "Manifest claims CI replay evidence." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no forbidden execution or overclaim exists"; script = { $flags = (Get-ValidSet).Report.runtime_flags; foreach ($flagName in @("audit_acceptance_claimed", "external_audit_acceptance_claimed", "milestone_closeout_claimed", "main_merge_claimed", "ci_replay_performed", "github_actions_workflow_created", "github_actions_workflow_run_claimed", "release_gate_executed", "stage_performed_by_gate", "commit_performed_by_gate", "push_performed_by_gate", "recovery_action_performed", "codex_api_invoked", "openai_api_invoked", "automatic_new_thread_creation_performed", "work_order_execution_performed", "board_runtime_mutation_performed", "a2a_message_sent", "product_runtime_executed", "no_manual_prompt_transfer_success_claimed", "solved_codex_compaction_claimed", "solved_codex_reliability_claimed", "r18_020_completed")) { if ([bool]$flags.$flagName) { throw "Forbidden claim '$flagName' was set." } } } },
        @{ label = "R18 is active through R18-025 only after status updates"; script = { Test-R18EvidencePackageWrapperStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-026 onward remain planned only"; script = { Test-R18EvidencePackageWrapperStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18EvidencePackageWrapperObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18EvidencePackageWrapperMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-019 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 evidence package wrapper tests failed."
}

Write-Output ("All R18 evidence package wrapper tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
