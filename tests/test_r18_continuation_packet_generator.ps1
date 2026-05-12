$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ContinuationPacketGenerator.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_continuation_packet_generator.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_continuation_packet_generator.ps1"
Import-Module $modulePath -Force

$paths = Get-R18ContinuationPaths -RepositoryRoot $repoRoot
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

function Get-ValidSet {
    return [pscustomobject]@{
        PacketContract = Read-TestJson -Path $paths.PacketContract
        GeneratorContract = Read-TestJson -Path $paths.GeneratorContract
        Profile = Read-TestJson -Path $paths.Profile
        InputSets = @(Get-ChildItem -LiteralPath $paths.InputSetRoot -Filter "*.input.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
        Packets = @(Get-ChildItem -LiteralPath $paths.PacketRoot -Filter "*.continuation.json" | Sort-Object Name | ForEach-Object { Read-TestJson -Path $_.FullName })
        Results = Read-TestJson -Path $paths.Results
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18ContinuationPacketGeneratorSet `
        -PacketContract $Set.PacketContract `
        -GeneratorContract $Set.GeneratorContract `
        -Profile $Set.Profile `
        -InputSets $Set.InputSets `
        -Packets $Set.Packets `
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
        "packet:*" {
            $type = $Target.Substring("packet:".Length)
            return @($Set.Packets | Where-Object { $_.continuation_type -eq $type })[0]
        }
        "input:*" {
            $type = $Target.Substring("input:".Length)
            return @($Set.InputSets | Where-Object { $_.continuation_type -eq $type })[0]
        }
        "contract" { return $Set.PacketContract }
        "generator_contract" { return $Set.GeneratorContract }
        "profile" { return $Set.Profile }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "continuation_packet_executed",
        "continuation_runtime_implemented",
        "new_context_prompt_generated",
        "automatic_new_thread_creation_performed",
        "recovery_runtime_implemented",
        "recovery_action_performed",
        "retry_execution_performed",
        "work_order_execution_performed",
        "live_runner_runtime_executed",
        "wip_cleanup_performed",
        "wip_abandonment_performed",
        "branch_mutation_performed",
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
        "board_runtime_mutation_performed",
        "live_agent_runtime_invoked",
        "live_skill_execution_performed",
        "a2a_message_sent",
        "live_a2a_runtime_implemented",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_performed",
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_014_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.PacketContract.runtime_flags,
        $Set.GeneratorContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.InputSets | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Packets | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Get-PacketByType {
    param([Parameter(Mandatory = $true)][object]$Set, [Parameter(Mandatory = $true)][string]$ContinuationType)
    return @($Set.Packets | Where-Object { $_.continuation_type -eq $ContinuationType })[0]
}

function Assert-PacketTypesExist {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($type in @(
            "continue_after_compact_failure",
            "continue_after_stream_disconnect",
            "continue_after_validation_failure",
            "operator_decision_required_for_wip",
            "operator_decision_required_for_remote_branch",
            "block_until_future_runtime"
        )) {
        $packet = Get-PacketByType -Set $Set -ContinuationType $type
        if ($null -eq $packet) {
            throw "Missing continuation packet type '$type'."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-013 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-013 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-013 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all valid input sets and continuation packets pass"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "compact, stream, validation, WIP-decision, remote-decision, and future-runtime packet types exist"; script = { Assert-PacketTypesExist -Set (Get-ValidSet) } },
        @{ label = "WIP decision packet requires operator decision"; script = { if (-not [bool](Get-PacketByType -Set (Get-ValidSet) -ContinuationType "operator_decision_required_for_wip").operator_decision_required) { throw "WIP decision packet does not require operator decision." } } },
        @{ label = "remote decision packet requires operator decision"; script = { if (-not [bool](Get-PacketByType -Set (Get-ValidSet) -ContinuationType "operator_decision_required_for_remote_branch").operator_decision_required) { throw "remote decision packet does not require operator decision." } } },
        @{ label = "block_until_future_runtime does not claim execution"; script = { if ([bool](Get-PacketByType -Set (Get-ValidSet) -ContinuationType "block_until_future_runtime").runtime_flags.continuation_packet_executed) { throw "future runtime packet claims execution." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no new-context prompt, automatic new-thread, recovery action, retry execution, WIP cleanup, branch mutation, work-order execution, API invocation, or product runtime claim exists"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-014 only after status updates"; script = { Test-R18ContinuationPacketGeneratorStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-015 onward remain planned only"; script = { Test-R18ContinuationPacketGeneratorStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18ContinuationObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18ContinuationMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-013 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 continuation packet generator tests failed."
}

Write-Output ("All R18 continuation packet generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
