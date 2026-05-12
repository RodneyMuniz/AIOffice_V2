$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18NewContextPromptGenerator.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_new_context_prompt_generator.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_new_context_prompt_generator.ps1"
Import-Module $modulePath -Force

$paths = Get-R18NewContextPaths -RepositoryRoot $repoRoot
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
    return Get-R18NewContextPromptGeneratorSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18NewContextPromptGeneratorSet `
        -PacketContract $Set.PacketContract `
        -GeneratorContract $Set.GeneratorContract `
        -Profile $Set.Profile `
        -Inputs $Set.Inputs `
        -Prompts $Set.Prompts `
        -Manifest $Set.Manifest `
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
            $type = $Target.Substring("input:".Length)
            return @($Set.Inputs | Where-Object { $_.prompt_type -eq $type })[0]
        }
        "prompt:*" {
            $type = $Target.Substring("prompt:".Length)
            return @($Set.Prompts | Where-Object { $_.prompt_type -eq $type })[0]
        }
        "packet_contract" { return $Set.PacketContract }
        "generator_contract" { return $Set.GeneratorContract }
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

    $flagNames = @(
        "prompt_packet_executed",
        "new_context_prompt_runtime_executed",
        "automatic_new_thread_creation_performed",
        "codex_thread_created",
        "codex_api_invoked",
        "openai_api_invoked",
        "autonomous_codex_invocation_performed",
        "continuation_packet_executed",
        "continuation_runtime_implemented",
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
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_015_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @(
        $Set.PacketContract.runtime_flags,
        $Set.GeneratorContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Manifest.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Inputs | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Assert-PromptTypesExist {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($type in @(
            "continue_after_compact_failure",
            "continue_after_stream_disconnect",
            "continue_after_validation_failure",
            "operator_decision_required_for_wip",
            "operator_decision_required_for_remote_branch",
            "block_until_future_runtime"
        )) {
        $input = @($Set.Inputs | Where-Object { $_.prompt_type -eq $type })
        $prompt = @($Set.Prompts | Where-Object { $_.prompt_type -eq $type })
        if ($input.Count -ne 1 -or $prompt.Count -ne 1) {
            throw "Missing prompt input or prompt packet type '$type'."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-014 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-014 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "valid R18-014 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "all six prompt inputs and prompt packets exist"; script = { Assert-PromptTypesExist -Set (Get-ValidSet) } },
        @{ label = "all prompts include required sections and exact refs"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "prompts are context-independent and do not require previous-thread memory"; script = { $set = Get-ValidSet; if ([bool]$set.Manifest.previous_thread_memory_required) { throw "Manifest requires previous-thread memory." }; Invoke-SetValidation -Set $set | Out-Null } },
        @{ label = "prompts do not ask for whole-milestone completion"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "prompts do not exceed configured size limits"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "manifest has previous_thread_memory_required false"; script = { if ([bool](Get-ValidSet).Manifest.previous_thread_memory_required) { throw "previous_thread_memory_required is true." } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no automatic new-thread, API invocation, prompt execution, continuation execution, recovery action, or no-manual-prompt-transfer success claim exists"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet); Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "R18 is active through R18-014 only after status updates"; script = { Test-R18NewContextPromptGeneratorStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-015 onward remain planned only"; script = { Test-R18NewContextPromptGeneratorStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18NewContextObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18NewContextPromptMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-014 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 new-context prompt generator tests failed."
}

Write-Output ("All R18 new-context prompt generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
