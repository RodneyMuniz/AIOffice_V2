$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentCardSchema.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_agent_card_schema.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_agent_card_schema.ps1"
Import-Module $modulePath -Force

$paths = Get-R18AgentCardSchemaPaths -RepositoryRoot $repoRoot
$failures = @()
$validPassed = 0
$invalidRejected = 0

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
}

function Get-ValidSet {
    $cards = foreach ($agentId in @($paths.CardFiles.Keys)) {
        Read-TestJson -Path $paths.CardFiles[$agentId]
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Cards = @($cards)
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18AgentCardSet -Contract $Set.Contract -Cards $Set.Cards -Report $Set.Report -Snapshot $Set.Snapshot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "card:*") {
        $agentId = $Target.Substring("card:".Length)
        $card = @($Set.Cards | Where-Object { $_.agent_id -eq $agentId }) | Select-Object -First 1
        if ($null -eq $card) {
            throw "No card found for mutation target '$Target'."
        }
        return $card
    }

    throw "Unknown mutation target '$Target'."
}

function Assert-RuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($flag in @(
            "live_agent_runtime_invoked",
            "live_a2a_runtime_implemented",
            "live_recovery_runtime_implemented",
            "openai_api_invoked",
            "codex_api_invoked",
            "autonomous_codex_invocation_performed",
            "automatic_new_thread_creation_performed",
            "product_runtime_executed",
            "no_manual_prompt_transfer_success_claimed",
            "solved_codex_compaction_claimed",
            "solved_codex_reliability_claimed",
            "r18_003_completed",
            "main_merge_claimed"
        )) {
        foreach ($card in @($Set.Cards)) {
            if ([bool]$card.runtime_flags.$flag -ne $false) {
                throw "$($card.agent_id) runtime flag '$flag' must remain false."
            }
        }
        if ([bool]$Set.Report.runtime_flags.$flag -ne $false) {
            throw "check report runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Snapshot.runtime_summary.$flag -ne $false) {
            throw "snapshot runtime flag '$flag' must remain false."
        }
    }
}

function Get-R18TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -ne 28) {
        throw "$Context must define 28 R18 task status entries."
    }

    $map = @{}
    foreach ($match in $matches) {
        $map[$match.Groups[1].Value] = $match.Groups[2].Value
    }
    return $map
}

function Assert-R18StatusAfterR18003 {
    $authority = Get-Content -LiteralPath (Join-Path $repoRoot "governance\R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md") -Raw
    $kanban = Get-Content -LiteralPath (Join-Path $repoRoot "execution\KANBAN.md") -Raw
    $statusText = [string]::Join([Environment]::NewLine, @(
            (Get-Content -LiteralPath (Join-Path $repoRoot "README.md") -Raw),
            $kanban,
            (Get-Content -LiteralPath (Join-Path $repoRoot "governance\ACTIVE_STATE.md") -Raw),
            (Get-Content -LiteralPath (Join-Path $repoRoot "governance\DECISION_LOG.md") -Raw),
            $authority
        ))

    foreach ($required in @(
            "R18 active through R18-019 only",
            "R18-020 through R18-028 planned only",
            "R18-002 created agent card schema and seed cards only",
            "R18-003 created skill contract schema and seed skill contracts only",
            "Agent cards are not live agents",
            "Skill contracts are not live skill execution",
            "R18-004 created A2A handoff packet schema and seed handoff packets only",
            "A2A handoff packets are not live A2A runtime",
            "R18-005 created role-to-skill permission matrix only",
            "Permission matrix is not runtime enforcement",
            "R18-006 created Orchestrator chat/control intake contract and seed intake packets only",
            "Intake packets are not a live chat UI",
            "Intake packets are not Orchestrator runtime",
            "R18-008 created work-order execution state machine foundation only",
            "Work-order state machine is not runtime execution",
            "R18-009 created runner state store and resumable execution log foundation only",
            "Runner state store is not live runner runtime",
            "Execution log is deterministic foundation evidence, not live execution evidence",
            "Resume checkpoint is not a continuation packet",
            "R18-010 created compact failure detector foundation only",
            "Failure detection is deterministic over seed signal artifacts only",
            "Failure events are not recovery completion",
            "R18-011 created WIP classifier foundation only",
            "WIP classification is deterministic over seed git inventory artifacts only",
            "No WIP cleanup was performed",
            "No WIP abandonment was performed",
            "No files were restored or deleted",
            "No staging, commit, or push was performed by the classifier",
            "R18-012 created remote branch verifier foundation only",
            "R18-013 created continuation packet generator foundation only",
            "Continuation packets were generated as deterministic packet artifacts only",
            "Continuation packets were not executed",
            "Continuation packets are not new-context prompts",
            "R18-014 created new-context prompt generator foundation only",
            "New-context prompt packets were generated as deterministic text artifacts only",
            "Prompt packets were not executed",
            "Automatic new-thread creation was not performed",
            "Codex thread creation was not performed",
            "Codex API invocation did not occur",
            "OpenAI API invocation did not occur",
            "Automatic new-thread creation is not implemented",
            "No board/card runtime mutation occurred",
            "No A2A messages were sent",
            "No live agents were invoked",
            "No live skills were executed",
            "No A2A runtime was implemented",
            "No local runner runtime was executed",
            "No recovery runtime was implemented",
            "No API invocation occurred",
            "No automatic new-thread creation occurred",
            "No product runtime is claimed",
            "No no-manual-prompt-transfer success is claimed",
            "Codex reliability is not solved",
            "Main is not merged"
        )) {
        if ($statusText -notlike "*$required*") {
            throw "Status docs missing R18-011 truth: $required"
        }
    }

    $authorityStatuses = Get-R18TaskStatusMap -Text $authority -Context "R18 authority"
    $kanbanStatuses = Get-R18TaskStatusMap -Text $kanban -Context "KANBAN"
    foreach ($taskNumber in 1..28) {
        $taskId = "R18-{0}" -f $taskNumber.ToString("000")
        if ($authorityStatuses[$taskId] -ne $kanbanStatuses[$taskId]) {
            throw "R18 authority and KANBAN disagree for $taskId."
        }
        if ($taskNumber -le 19) {
            if ($authorityStatuses[$taskId] -ne "done") {
                throw "$taskId must be done after R18-019."
            }
        }
        else {
            if ($authorityStatuses[$taskId] -ne "planned") {
                throw "$taskId must remain planned only after R18-019."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-002 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-002 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-SetValidation -Set $validSet | Out-Null
    Write-Output "PASS valid: generated R18-002 seed cards validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid seed card set: $($_.Exception.Message)"
}

try {
    Assert-RuntimeFalseFlags -Set (Get-ValidSet)
    Write-Output "PASS valid: runtime false flags remain false."
    $validPassed += 1
}
catch {
    $failures += "FAIL runtime false flags: $($_.Exception.Message)"
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R18AgentCardObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18AgentCardMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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

try {
    Assert-R18StatusAfterR18003
    Write-Output "PASS valid: R18 status accepts the current active-through R18-018 boundary."
    $validPassed += 1
}
catch {
    $failures += "FAIL R18 status truth: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 agent card schema tests failed."
}

Write-Output ("All R18 agent card schema tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
