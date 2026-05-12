$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WipClassifier.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_wip_classifier.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_wip_classifier.ps1"
Import-Module $modulePath -Force

$paths = Get-R18WipClassifierPaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0
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

function Get-Inventories {
    return @(Get-ChildItem -LiteralPath $paths.InventoryRoot -Filter "*.inventory.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-Classifications {
    return @(Get-ChildItem -LiteralPath $paths.ClassificationRoot -Filter "*.classification.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Profile = Read-TestJson -Path $paths.Profile
        Inventories = @(Get-Inventories)
        Classifications = @(Get-Classifications)
        Results = Read-TestJson -Path $paths.Results
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18WipClassifierSet `
        -Contract $Set.Contract `
        -Profile $Set.Profile `
        -Inventories $Set.Inventories `
        -Classifications $Set.Classifications `
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
        "inventory:*" {
            $type = $Target.Substring("inventory:".Length)
            return @($Set.Inventories | Where-Object { $_.inventory_type -eq $type })[0]
        }
        "classification:*" {
            $type = $Target.Substring("classification:".Length)
            return @($Set.Classifications | Where-Object { $_.source_inventory_ref -like "*$type.inventory.json" })[0]
        }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "wip_classifier_live_runtime_executed",
        "live_git_scan_performed",
        "wip_cleanup_performed",
        "wip_abandonment_performed",
        "file_restore_performed",
        "file_delete_performed",
        "staging_performed",
        "commit_performed",
        "push_performed",
        "remote_branch_verifier_runtime_implemented",
        "remote_branch_verified",
        "continuation_packet_generated",
        "new_context_prompt_generated",
        "recovery_runtime_implemented",
        "recovery_action_performed",
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
        "r18_012_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Inventories | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Classifications | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results.classification_results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Get-ClassificationByInventoryType {
    param([Parameter(Mandatory = $true)][object]$Set, [Parameter(Mandatory = $true)][string]$InventoryType)
    return @($Set.Classifications | Where-Object { $_.source_inventory_ref -like "*$InventoryType.inventory.json" })[0]
}

function Assert-ClassificationSemantics {
    param([Parameter(Mandatory = $true)][object]$Set)

    $expected = @{
        no_wip = @{ type = "no_wip_safe"; safe = $true; decision = $false; action = "continue_without_wip_action" }
        scoped_tracked_wip = @{ type = "scoped_tracked_wip_safe_to_preserve"; safe = $true; decision = $false; action = "preserve_scoped_wip_for_future_task" }
        unexpected_tracked_wip = @{ type = "unexpected_tracked_wip_operator_decision_required"; safe = $false; decision = $true; action = "stop_and_request_operator_decision" }
        historical_evidence_edit = @{ type = "historical_evidence_edit_blocked"; safe = $false; decision = $true; action = "block_historical_evidence_edit" }
        operator_local_backup_path = @{ type = "operator_local_backup_path_blocked"; safe = $false; decision = $true; action = "stop_and_request_operator_decision" }
        untracked_local_notes = @{ type = "untracked_local_notes_do_not_stage"; safe = $true; decision = $false; action = "leave_untracked_local_notes_unstaged" }
        generated_artifact_churn = @{ type = "generated_artifact_churn_review_required"; safe = $false; decision = $true; action = "review_generated_artifact_churn" }
        staged_files_present = @{ type = "staged_files_present_blocked"; safe = $false; decision = $true; action = "unstage_before_continue" }
    }

    foreach ($inventoryType in $expected.Keys) {
        $classification = Get-ClassificationByInventoryType -Set $Set -InventoryType $inventoryType
        if ($classification.classification_type -ne $expected[$inventoryType].type) {
            throw "$inventoryType classified as $($classification.classification_type), expected $($expected[$inventoryType].type)."
        }
        if ([bool]$classification.safe_to_continue -ne [bool]$expected[$inventoryType].safe) {
            throw "$inventoryType safe_to_continue mismatch."
        }
        if ([bool]$classification.operator_decision_required -ne [bool]$expected[$inventoryType].decision) {
            throw "$inventoryType operator_decision_required mismatch."
        }
        if ($classification.action_recommendation -ne $expected[$inventoryType].action) {
            throw "$inventoryType action_recommendation mismatch."
        }
    }

    $notes = Get-ClassificationByInventoryType -Set $Set -InventoryType "untracked_local_notes"
    if (@($notes.recommended_stage_paths).Count -ne 0) {
        throw "Untracked local notes must not be marked for staging."
    }
}

function Assert-NoFutureRuntimeClaims {
    param([Parameter(Mandatory = $true)][object]$Set)

    Assert-AllRuntimeFalseFlags -Set $Set
    if ([bool]$Set.Contract.api_policy.api_enabled -or [bool]$Set.Contract.execution_policy.recovery_action_allowed -or [bool]$Set.Contract.execution_policy.cleanup_restore_delete_stage_commit_push_allowed) {
        throw "R18-011 must not allow API invocation, recovery action, cleanup, restore/delete, stage, commit, or push."
    }
    if ([bool]$Set.Contract.remote_verification_boundary_policy.remote_branch_verified_allowed -or [bool]$Set.Contract.continuation_boundary_policy.continuation_packet_generation_allowed -or [bool]$Set.Contract.continuation_boundary_policy.new_context_prompt_generation_allowed) {
        throw "R18-011 must not allow remote verification, continuation packet generation, or new-context prompt generation."
    }
}

try {
    Invoke-RequiredCommand -Label "R18-011 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-011 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-011 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all valid inventory samples classify correctly"; script = { Assert-ClassificationSemantics -Set (Get-ValidSet) } },
        @{ label = "historical evidence edits are blocked"; script = { if ([bool](Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "historical_evidence_edit").safe_to_continue) { throw "Historical evidence edit was marked safe." } } },
        @{ label = "operator-local backup paths are blocked"; script = { if ([bool](Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "operator_local_backup_path").safe_to_continue) { throw "Operator-local backup path was marked safe." } } },
        @{ label = "staged files are blocked"; script = { if ([bool](Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "staged_files_present").safe_to_continue) { throw "Staged files were marked safe." } } },
        @{ label = "unexpected tracked WIP requires operator decision"; script = { if (-not [bool](Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "unexpected_tracked_wip").operator_decision_required) { throw "Unexpected tracked WIP did not require operator decision." } } },
        @{ label = "untracked local notes are not staged"; script = { if (@((Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "untracked_local_notes").recommended_stage_paths).Count -ne 0) { throw "Untracked local notes marked for staging." } } },
        @{ label = "generated artifact churn requires review"; script = { if ((Get-ClassificationByInventoryType -Set (Get-ValidSet) -InventoryType "generated_artifact_churn").action_recommendation -ne "review_generated_artifact_churn") { throw "Generated artifact churn did not require review." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no remote/continuation/new-context/recovery/cleanup/stage/commit/push claims exist"; script = { Assert-NoFutureRuntimeClaims -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-013 only"; script = { Test-R18WipClassifierStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18WipClassifierObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18WipClassifierMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-011 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 WIP classifier tests failed."
}

Write-Output ("All R18 WIP classifier tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
