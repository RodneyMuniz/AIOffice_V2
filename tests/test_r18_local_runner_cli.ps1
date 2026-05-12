$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18LocalRunnerCli.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_local_runner_cli.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_local_runner_cli.ps1"
$invoker = Join-Path $repoRoot "tools\invoke_r18_local_runner_cli.ps1"
Import-Module $modulePath -Force

$paths = Get-R18CliPaths -RepositoryRoot $repoRoot
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
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string[]]$Arguments = @()
    )

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed: $($output -join [Environment]::NewLine)"
    }
    Write-Output "PASS command: $Label"
    return $output
}

function Get-ValidSet {
    $inputs = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.InputRoot -Filter "*.input.json" | Sort-Object Name) {
        $inputs += Read-TestJson -Path $file.FullName
    }

    $results = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.ResultRoot -Filter "*.result.json" | Sort-Object Name) {
        $results += Read-TestJson -Path $file.FullName
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Profile = Read-TestJson -Path $paths.Profile
        Catalog = Read-TestJson -Path $paths.Catalog
        Inputs = $inputs
        Results = $results
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18LocalRunnerCliSet -Contract $Set.Contract -Profile $Set.Profile -Catalog $Set.Catalog -Inputs $Set.Inputs -Results $Set.Results -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "input:*") {
        $type = $Target.Substring("input:".Length)
        $input = @($Set.Inputs | Where-Object { $_.command_type -eq $type }) | Select-Object -First 1
        if ($null -eq $input) {
            throw "No command input found for mutation target '$Target'."
        }
        return $input
    }
    if ($Target -like "result:*") {
        $type = $Target.Substring("result:".Length)
        $result = @($Set.Results | Where-Object { $_.command_type -eq $type }) | Select-Object -First 1
        if ($null -eq $result) {
            throw "No command result found for mutation target '$Target'."
        }
        return $result
    }
    if ($Target -eq "contract") {
        return $Set.Contract
    }
    throw "Unknown mutation target '$Target'."
}

function Assert-RequiredCommandTypes {
    param([Parameter(Mandatory = $true)][object]$Set)

    $expected = @("status", "inspect_repo", "validate_intake_packet", "refuse_execute_work_order") | Sort-Object
    $actualInputs = @($Set.Inputs | ForEach-Object { [string]$_.command_type } | Sort-Object)
    $actualResults = @($Set.Results | ForEach-Object { [string]$_.command_type } | Sort-Object)
    if (($actualInputs -join "|") -ne ($expected -join "|")) {
        throw "Command inputs are not exactly the required command type set."
    }
    if (($actualResults -join "|") -ne ($expected -join "|")) {
        throw "Command results are not exactly the required command type set."
    }
}

function Assert-InvocationResult {
    param(
        [Parameter(Mandatory = $true)][string]$CommandType,
        [Parameter(Mandatory = $true)][string]$ExpectedStatus
    )

    $inputPath = Join-Path $paths.InputRoot ((@{
                status = "status_command.input.json"
                inspect_repo = "inspect_repo_command.input.json"
                validate_intake_packet = "validate_intake_command.input.json"
                refuse_execute_work_order = "refuse_execute_work_order_command.input.json"
            })[$CommandType])
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $invoker -CommandInputPath $inputPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "invoke $CommandType failed: $($output -join [Environment]::NewLine)"
    }
    $json = ($output -join [Environment]::NewLine) | ConvertFrom-Json
    if ([string]$json.result_status -ne $ExpectedStatus) {
        throw "$CommandType returned '$($json.result_status)' instead of '$ExpectedStatus'."
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $flagNames = @(
        "local_runner_runtime_executed",
        "work_order_execution_performed",
        "work_order_state_machine_implemented",
        "live_chat_ui_implemented",
        "orchestrator_runtime_implemented",
        "board_runtime_mutation_performed",
        "live_agent_runtime_invoked",
        "live_skill_execution_performed",
        "a2a_message_sent",
        "live_a2a_runtime_implemented",
        "live_recovery_runtime_implemented",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_performed",
        "automatic_new_thread_creation_performed",
        "stage_commit_push_performed",
        "product_runtime_executed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "r18_008_completed",
        "main_merge_claimed"
    )

    $runtimeObjects = @($Set.Contract.runtime_flags, $Set.Profile.runtime_flags, $Set.Catalog.runtime_flags, $Set.Report.runtime_flags, $Set.Snapshot.runtime_summary)
    $runtimeObjects += @($Set.Inputs | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Results | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in $flagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

function Assert-ApiFlagsDisabled {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ([bool]$Set.Contract.api_policy.api_enabled -or [bool]$Set.Contract.api_policy.openai_api_invocation_allowed -or [bool]$Set.Contract.api_policy.codex_api_invocation_allowed) {
        throw "Contract API flags must remain disabled."
    }
    foreach ($input in @($Set.Inputs)) {
        if ([bool]$input.runtime_flags.openai_api_invoked -or [bool]$input.runtime_flags.codex_api_invoked) {
            throw "$($input.command_id) API flags must remain false."
        }
    }
    foreach ($result in @($Set.Results)) {
        if ([bool]$result.runtime_flags.openai_api_invoked -or [bool]$result.runtime_flags.codex_api_invoked) {
            throw "$($result.result_id) API flags must remain false."
        }
    }
}

try {
    if (-not (Test-Path -LiteralPath $generator -PathType Leaf)) {
        throw "R18-007 generator is missing."
    }
    Write-Output "PASS valid: R18-007 generator exists; live generator replay is skipped to avoid rewriting historical dry-run identity artifacts during R18-008 validation."
    $validPassed += 1
}
catch {
    $failures += "FAIL generator presence: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-007 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($invokeCase in @(
        @{ command_type = "status"; expected = "dry_run_passed" },
        @{ command_type = "inspect_repo"; expected = "dry_run_passed" },
        @{ command_type = "validate_intake_packet"; expected = "dry_run_passed" },
        @{ command_type = "refuse_execute_work_order"; expected = "dry_run_refused" }
    )) {
    try {
        Assert-InvocationResult -CommandType $invokeCase.command_type -ExpectedStatus $invokeCase.expected
        Write-Output "PASS invoke: $($invokeCase.command_type) returned $($invokeCase.expected)."
        $validPassed += 1
    }
    catch {
        $failures += "FAIL invoke $($invokeCase.command_type): $($_.Exception.Message)"
    }
}

foreach ($assertion in @(
        @{ label = "valid R18-007 artifact set validates"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null } },
        @{ label = "command types are exactly required"; script = { Assert-RequiredCommandTypes -Set (Get-ValidSet) } },
        @{ label = "runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "API flags remain disabled"; script = { Assert-ApiFlagsDisabled -Set (Get-ValidSet) } },
        @{ label = "R18 status is active through R18-013 only"; script = { Test-R18CliStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18CliObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18CliMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
            Write-Output ("PASS invalid: {0} -> {1}" -f $fixtureFile.Name, $message)
            $invalidRejected += 1
        }
    }
}

$finalStaged = (& git -C $repoRoot diff --cached --name-only) -join "`n"
if ($finalStaged -ne $initialStaged) {
    $failures += "FAIL git hygiene: staged changes changed during R18-007 tests."
}
else {
    Write-Output "PASS valid: tests did not stage files."
    $validPassed += 1
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 local runner CLI tests failed."
}

Write-Output ("All R18 local runner CLI tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
