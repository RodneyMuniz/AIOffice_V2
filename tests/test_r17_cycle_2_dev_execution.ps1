$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17Cycle2DevExecution.psm1"
Import-Module $modulePath -Force

$paths = Get-R17Cycle2DevExecutionPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-TestJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)
    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $records += ($line | ConvertFrom-Json)
    }
    return $records
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        DevRequest = Read-TestJson -Path $paths.DevRequest
        DevResult = Read-TestJson -Path $paths.DevResult
        DevDiffStatusSummary = Read-TestJson -Path $paths.DevDiffStatusSummary
        A2aMessages = Read-TestJson -Path $paths.A2aMessages
        A2aHandoffs = Read-TestJson -Path $paths.A2aHandoffs
        A2aDispatchRefs = Read-TestJson -Path $paths.A2aDispatchRefs
        ToolCallLedgerRefs = Read-TestJson -Path $paths.ToolCallLedgerRefs
        InvocationRefs = Read-TestJson -Path $paths.InvocationRefs
        ControlRefs = Read-TestJson -Path $paths.ControlRefs
        BoardEventRefs = Read-TestJson -Path $paths.BoardEventRefs
        CheckReport = Read-TestJson -Path $paths.CheckReport
        BoardCard = Read-TestJson -Path $paths.BoardCard
        BoardEvents = Read-TestJsonLines -Path $paths.BoardEvents
        BoardSnapshot = Read-TestJson -Path $paths.BoardSnapshot
        UiSnapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17Cycle2DevExecutionSet `
        -Contract $Set.Contract `
        -DevRequest $Set.DevRequest `
        -DevResult $Set.DevResult `
        -DevDiffStatusSummary $Set.DevDiffStatusSummary `
        -A2aMessages $Set.A2aMessages `
        -A2aHandoffs $Set.A2aHandoffs `
        -A2aDispatchRefs $Set.A2aDispatchRefs `
        -ToolCallLedgerRefs $Set.ToolCallLedgerRefs `
        -InvocationRefs $Set.InvocationRefs `
        -ControlRefs $Set.ControlRefs `
        -BoardEventRefs $Set.BoardEventRefs `
        -CheckReport $Set.CheckReport `
        -BoardCard $Set.BoardCard `
        -BoardEvents $Set.BoardEvents `
        -BoardSnapshot $Set.BoardSnapshot `
        -UiSnapshot $Set.UiSnapshot `
        -RepositoryRoot $repoRoot `
        -SkipRefExistence `
        -SkipKanbanJsCheck
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        $matched = $false
        foreach ($fragment in $RequiredFragments) {
            if ($message -match [regex]::Escape([string]$fragment)) {
                $matched = $true
            }
        }

        if (-not $matched) {
            $script:failures += "FAIL invalid: $Label rejected with unexpected message: $message"
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "dev_request" { return $Set.DevRequest }
        "dev_result" { return $Set.DevResult }
        "dev_diff" { return $Set.DevDiffStatusSummary }
        "messages" { return $Set.A2aMessages }
        "handoffs" { return $Set.A2aHandoffs }
        "dispatch" { return $Set.A2aDispatchRefs }
        "tool_refs" { return $Set.ToolCallLedgerRefs }
        "invocation_refs" { return $Set.InvocationRefs }
        "control_refs" { return $Set.ControlRefs }
        "board_event_refs" { return $Set.BoardEventRefs }
        "check_report" { return $Set.CheckReport }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Invoke-Mutation {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)]$Fixture
    )

    $target = Get-MutationTarget -Set $Set -Target ([string]$Fixture.target)
    switch ([string]$Fixture.mutation) {
        "remove" {
            Remove-R17Cycle2DevExecutionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property)
        }
        "set" {
            Set-R17Cycle2DevExecutionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "append" {
            $existing = @(Get-R17Cycle2DevExecutionProperty -Object $target -Name ([string]$Fixture.property) -Context ([string]$Fixture.property))
            $existing += $Fixture.value
            Set-R17Cycle2DevExecutionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property) -Value $existing
        }
        default {
            throw "Unknown fixture mutation '$($Fixture.mutation)'."
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17Cycle2DevExecution -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-024 Cycle 2 Developer/Codex execution package validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-024 cycle package: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact live fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact fixture set: $($_.Exception.Message)"
}

$invalidFixtureFiles = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name)
if ($invalidFixtureFiles.Count -lt 20) {
    $failures += "FAIL fixture coverage: expected at least 20 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
        $set = Copy-R17Cycle2DevExecutionObject -Value (Get-ValidSet)
        Invoke-Mutation -Set $set -Fixture $fixture
        Invoke-TestSet -Set $set | Out-Null
    }
}

$requiredFalseFields = @(
    "live_cycle_runtime_implemented",
    "live_orchestrator_runtime_invoked",
    "live_developer_agent_invoked",
    "live_codex_executor_adapter_invoked",
    "codex_executor_adapter_runtime_implemented",
    "codex_executor_invoked_by_product_runtime",
    "live_agent_runtime_invoked",
    "live_a2a_dispatch_performed",
    "a2a_runtime_implemented",
    "a2a_message_sent",
    "adapter_runtime_invoked",
    "actual_tool_call_performed",
    "external_api_call_performed",
    "live_board_mutation_performed",
    "runtime_card_creation_performed",
    "qa_test_agent_invoked",
    "qa_result_claimed",
    "evidence_auditor_api_invoked",
    "audit_verdict_claimed",
    "real_audit_verdict",
    "external_audit_acceptance_claimed",
    "product_runtime_executed",
    "autonomous_agent_executed",
    "main_merge_claimed",
    "no_manual_prompt_transfer_claimed"
)

foreach ($field in $requiredFalseFields) {
    Invoke-ExpectedRefusal -Label ("runtime-flag-{0}-true" -f $field) -RequiredFragments @($field) -Action {
        $set = Copy-R17Cycle2DevExecutionObject -Value (Get-ValidSet)
        Set-R17Cycle2DevExecutionObjectPathValue -TargetObject $set.DevResult -Path ("runtime_flags.{0}" -f $field) -Value $true
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17-024 Cycle 2 Developer/Codex execution tests failed."
}

Write-Output ("All R17-024 Cycle 2 Developer/Codex execution tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
