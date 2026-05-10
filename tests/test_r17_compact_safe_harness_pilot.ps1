$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CompactSafeHarnessPilot.psm1"
Import-Module $modulePath -Force

$paths = Get-R17CompactSafeHarnessPilotPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Plan = Read-TestJson -Path $paths.Plan
        WorkOrders = Read-TestJson -Path $paths.WorkOrders
        ResumeState = Read-TestJson -Path $paths.ResumeState
        CheckReport = Read-TestJson -Path $paths.CheckReport
        UiSnapshot = Read-TestJson -Path $paths.UiSnapshot
        PromptPackets = Get-R17CompactSafeHarnessPilotPromptPacketObjects -RepositoryRoot $repoRoot
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17CompactSafeHarnessPilotSet `
        -Contract $Set.Contract `
        -Plan $Set.Plan `
        -WorkOrders $Set.WorkOrders `
        -ResumeState $Set.ResumeState `
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
        "remove_work_order_allowed_paths" { $Set.WorkOrders.work_orders[0].PSObject.Properties.Remove("allowed_paths") }
        "set_broad_allowed_path" { $Set.WorkOrders.work_orders[0].allowed_paths = @("state") }
        "append_local_backup_token_reference" {
            $token = ".local" + "_backups"
            $Set.WorkOrders.work_orders[0].allowed_paths = @($Set.WorkOrders.work_orders[0].allowed_paths) + @("$token/evidence.txt")
        }
        "append_historical_r14_write" { $Set.WorkOrders.work_orders[0].allowed_paths = @($Set.WorkOrders.work_orders[0].allowed_paths) + @("state/proof_reviews/r14_product_vision_pivot_and_governance_enforcement/changed.json") }
        "append_kanban_js_write" { $Set.WorkOrders.work_orders[0].allowed_paths = @($Set.WorkOrders.work_orders[0].allowed_paths) + @("scripts/operator_wall/r17_kanban_mvp/kanban.js") }
        "set_prompt_packet_too_large" { $Set.PromptPackets[0].content = ((1..2001 | ForEach-Object { "word" }) -join " ") }
        "set_entire_cycle_one_prompt" { $Set.PromptPackets[0].content = $Set.PromptPackets[0].content + "`nRun the entire Cycle 3 QA/fix-loop in one prompt." }
        "remove_resume_prompt_packet" { $Set.PromptPackets = @($Set.PromptPackets | Where-Object { [string]$_.path -notlike "*step_008_resume_after_compact.prompt.txt" }) }
        "remove_stage_prompt_packet" { $Set.PromptPackets = @($Set.PromptPackets | Where-Object { [string]$_.path -notlike "*step_007_stage_commit_push.prompt.txt" }) }
        "set_openai_api_invoked_true" { $Set.WorkOrders.work_orders[0].openai_api_invoked = $true }
        "set_codex_api_invoked_true" { $Set.WorkOrders.work_orders[0].codex_api_invoked = $true }
        "set_autonomous_codex_invocation_true" { $Set.WorkOrders.work_orders[0].autonomous_codex_invocation_performed = $true }
        "set_no_manual_prompt_transfer_true" { $Set.WorkOrders.work_orders[0].no_manual_prompt_transfer_claimed = $true }
        "set_solved_codex_compaction_true" { $Set.WorkOrders.work_orders[0].solved_codex_compaction_claimed = $true }
        "set_solved_codex_reliability_true" { $Set.WorkOrders.work_orders[0].solved_codex_reliability_claimed = $true }
        "set_qa_result_claimed_true" { $Set.WorkOrders.work_orders[0].qa_result_claimed = $true }
        "set_audit_verdict_claimed_true" { $Set.WorkOrders.work_orders[0].audit_verdict_claimed = $true }
        "set_product_runtime_true" { $Set.WorkOrders.work_orders[0].product_runtime_executed = $true }
        "set_future_r17_027_completion_claim" { $Set.Plan | Add-Member -NotePropertyName status_note -NotePropertyValue "R17-027 completed by this pass." -Force }
        "set_live_runtime_true" { $Set.WorkOrders.work_orders[0].live_execution_harness_runtime_implemented = $true }
        default { throw "Unknown mutation '$Mutation'." }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17CompactSafeHarnessPilot -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-026 compact-safe harness pilot package validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-026 compact-safe harness pilot package: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact in-memory pilot fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact pilot fixture set: $($_.Exception.Message)"
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
    $failures += "FAIL fixture coverage: expected at least 20 invalid compact-safe harness pilot fixtures."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17-026 compact-safe harness pilot tests failed."
}

Write-Output ("All R17-026 compact-safe harness pilot tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
