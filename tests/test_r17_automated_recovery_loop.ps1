$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AutomatedRecoveryLoop.psm1"
Import-Module $modulePath -Force

$paths = Get-R17AutomatedRecoveryLoopPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Plan = Read-TestJson -Path $paths.Plan
        StateMachine = Read-TestJson -Path $paths.StateMachine
        FailureEvents = @(Read-R17AutomatedRecoveryLoopFailureEvents -RepositoryRoot $repoRoot)
        ContinuationPackets = Read-TestJson -Path $paths.ContinuationPackets
        NewContextPackets = Read-TestJson -Path $paths.NewContextPackets
        CheckReport = Read-TestJson -Path $paths.CheckReport
        UiSnapshot = Read-TestJson -Path $paths.UiSnapshot
        PromptPackets = Get-R17AutomatedRecoveryLoopPromptPacketObjects -RepositoryRoot $repoRoot
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17AutomatedRecoveryLoopSet `
        -Contract $Set.Contract `
        -Plan $Set.Plan `
        -StateMachine $Set.StateMachine `
        -FailureEvents $Set.FailureEvents `
        -ContinuationPackets $Set.ContinuationPackets `
        -NewContextPackets $Set.NewContextPackets `
        -CheckReport $Set.CheckReport `
        -UiSnapshot $Set.UiSnapshot `
        -PromptPackets $Set.PromptPackets `
        -RepositoryRoot $repoRoot `
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
            if ($message -like ("*{0}*" -f $fragment)) {
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

function Invoke-Mutation {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Mutation
    )

    switch ($Mutation) {
        "remove_contract_baseline_head" { $Set.Contract.PSObject.Properties.Remove("baseline_head") }
        "remove_contract_baseline_tree" { $Set.Contract.PSObject.Properties.Remove("baseline_tree") }
        "remove_failure_remote_verification" { $Set.FailureEvents[0].PSObject.Properties.Remove("remote_verification_required") }
        "remove_failure_local_inventory" { $Set.FailureEvents[0].PSObject.Properties.Remove("local_inventory_commands") }
        "remove_failure_wip_classification" { $Set.FailureEvents[0].PSObject.Properties.Remove("wip_classification") }
        "remove_continuation_packets" { $Set.ContinuationPackets.continuation_packets = @() }
        "remove_new_context_packets" { $Set.NewContextPackets.new_context_packets = @() }
        "remove_failure_retry_limit" { $Set.FailureEvents[0].PSObject.Properties.Remove("retry_limit") }
        "remove_failure_escalation_policy" { $Set.FailureEvents[0].PSObject.Properties.Remove("escalation_policy") }
        "append_broad_allowed_path" { $Set.Contract.allowed_paths = @($Set.Contract.allowed_paths) + @("state") }
        "append_local_backup_reference" {
            $token = ".local" + "_backups"
            $Set.Contract.allowed_paths = @($Set.Contract.allowed_paths) + @("$token/evidence.txt")
        }
        "append_historical_r14_write" { $Set.Contract.allowed_paths = @($Set.Contract.allowed_paths) + @("state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/changed.json") }
        "append_kanban_js_write" { $Set.Contract.allowed_paths = @($Set.Contract.allowed_paths) + @("scripts/operator_wall/r17_kanban_mvp/kanban.js") }
        "set_prompt_packet_too_large" { $Set.PromptPackets[0].content = ((1..2001 | ForEach-Object { "word" }) -join " ") }
        "set_new_context_depends_on_previous_memory" { $Set.NewContextPackets.new_context_packets[0].previous_thread_memory_required = $true }
        "set_new_context_complete_whole_milestone" {
            $packet = @($Set.PromptPackets | Where-Object { [string]$_.path -like "*step_005_new_context_resume.prompt.txt" })[0]
            $packet.content = $packet.content + "`nComplete the whole R17 milestone from this prompt."
        }
        "set_openai_api_invoked_true" { $Set.Plan.openai_api_invoked = $true }
        "set_codex_api_invoked_true" { $Set.Plan.codex_api_invoked = $true }
        "set_automatic_new_thread_creation_true" { $Set.Plan.automatic_new_thread_creation_performed = $true }
        "set_autonomous_codex_invocation_true" { $Set.Plan.autonomous_codex_invocation_performed = $true }
        "set_no_manual_prompt_transfer_true" { $Set.Plan.no_manual_prompt_transfer_claimed = $true }
        "set_solved_codex_compaction_true" { $Set.Plan.solved_codex_compaction_claimed = $true }
        "set_solved_codex_reliability_true" { $Set.Plan.solved_codex_reliability_claimed = $true }
        "set_product_runtime_true" { $Set.Plan.product_runtime_executed = $true }
        "set_main_merge_true" { $Set.Plan.main_merge_claimed = $true }
        "set_r17_closeout_true" { $Set.Plan.r17_closeout_claimed = $true }
        "set_future_r17_028_completion_claim" { $Set.Plan | Add-Member -NotePropertyName status_note -NotePropertyValue "R17-028 completed by this pass." -Force }
        default { throw "Unknown mutation '$Mutation'." }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17AutomatedRecoveryLoop -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-027 automated recovery loop foundation package validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-027 automated recovery loop foundation package: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact in-memory recovery-loop fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact recovery-loop fixture set: $($_.Exception.Message)"
}

$fixtureManifest = Read-TestJson -Path $paths.FixtureManifest
foreach ($fixture in @($fixtureManifest.fixtures)) {
    $fixturePath = Join-Path $paths.FixtureRoot ([string]$fixture.file)
    $fixtureSpec = Read-TestJson -Path $fixturePath
    $expected = @($fixtureSpec.expected_failure_fragments | ForEach-Object { [string]$_ })
    Invoke-ExpectedRefusal -Label ([string]$fixtureSpec.file) -RequiredFragments $expected -Action {
        $set = Get-ValidSet
        Invoke-Mutation -Set $set -Mutation ([string]$fixtureSpec.mutation)
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($invalidRejected -lt 20) {
    $failures += "FAIL fixture coverage: expected at least 20 invalid automated recovery loop fixtures."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17-027 automated recovery loop foundation tests failed."
}

Write-Output ("All R17-027 automated recovery loop foundation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
