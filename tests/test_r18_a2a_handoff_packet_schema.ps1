$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18A2AHandoffPacketSchema.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_a2a_handoff_packet_schema.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_a2a_handoff_packet_schema.ps1"
Import-Module $modulePath -Force

$paths = Get-R18HandoffSchemaPaths -RepositoryRoot $repoRoot
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
    $handoffs = foreach ($handoffId in @($paths.HandoffFiles.Keys)) {
        Read-TestJson -Path $paths.HandoffFiles[$handoffId]
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Handoffs = @($handoffs)
        Registry = Read-TestJson -Path $paths.Registry
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18HandoffPacketSet -Contract $Set.Contract -Handoffs $Set.Handoffs -Registry $Set.Registry -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "handoff:*") {
        $handoffId = $Target.Substring("handoff:".Length)
        $handoff = @($Set.Handoffs | Where-Object { $_.handoff_id -eq $handoffId }) | Select-Object -First 1
        if ($null -eq $handoff) {
            throw "No handoff packet found for mutation target '$Target'."
        }
        return $handoff
    }

    throw "Unknown mutation target '$Target'."
}

function Assert-AgentsMapToCards {
    param([Parameter(Mandatory = $true)][object]$Set)

    $cards = Get-R18HandoffAgentCardIndex -RepositoryRoot $repoRoot
    foreach ($handoff in @($Set.Handoffs)) {
        if (-not $cards.ContainsKey([string]$handoff.source_agent_id)) {
            throw "$($handoff.handoff_id) source agent '$($handoff.source_agent_id)' is missing from R18-002 agent cards."
        }
        if (-not $cards.ContainsKey([string]$handoff.target_agent_id)) {
            throw "$($handoff.handoff_id) target agent '$($handoff.target_agent_id)' is missing from R18-002 agent cards."
        }
        if ($handoff.source_role -ne $cards[[string]$handoff.source_agent_id].role) {
            throw "$($handoff.handoff_id) source role does not match R18-002 source card."
        }
        if ($handoff.target_role -ne $cards[[string]$handoff.target_agent_id].role) {
            throw "$($handoff.handoff_id) target role does not match R18-002 target card."
        }
    }
}

function Assert-SkillsMapToRegistry {
    param([Parameter(Mandatory = $true)][object]$Set)

    $skills = Get-R18HandoffSkillRegistryIndex -RepositoryRoot $repoRoot
    foreach ($handoff in @($Set.Handoffs)) {
        if (-not $skills.ContainsKey([string]$handoff.skill_ref)) {
            throw "$($handoff.handoff_id) skill_ref '$($handoff.skill_ref)' is missing from R18-003 skill registry."
        }
        if (@($skills[[string]$handoff.skill_ref].allowed_roles) -notcontains [string]$handoff.target_role) {
            throw "$($handoff.handoff_id) target role '$($handoff.target_role)' is not allowed for '$($handoff.skill_ref)'."
        }
    }
}

function Assert-RuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($flag in @(
            "a2a_message_sent",
            "live_a2a_runtime_implemented",
            "live_agent_runtime_invoked",
            "live_skill_execution_performed",
            "live_recovery_runtime_implemented",
            "local_runner_runtime_implemented",
            "openai_api_invoked",
            "codex_api_invoked",
            "autonomous_codex_invocation_performed",
            "automatic_new_thread_creation_performed",
            "product_runtime_executed",
            "no_manual_prompt_transfer_success_claimed",
            "solved_codex_compaction_claimed",
            "solved_codex_reliability_claimed",
            "r18_005_completed",
            "main_merge_claimed"
        )) {
        foreach ($handoff in @($Set.Handoffs)) {
            if ([bool]$handoff.runtime_flags.$flag -ne $false) {
                throw "$($handoff.handoff_id) runtime flag '$flag' must remain false."
            }
        }
        if ([bool]$Set.Report.runtime_flags.$flag -ne $false) {
            throw "check report runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Registry.runtime_flags.$flag -ne $false) {
            throw "registry runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Snapshot.runtime_summary.$flag -ne $false) {
            throw "snapshot runtime flag '$flag' must remain false."
        }
    }
}

function Assert-RetryLimitsBounded {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($handoff in @($Set.Handoffs)) {
        $maxRetry = [int]$handoff.retry_failover_policy.max_retry_count
        if ($maxRetry -lt 0 -or $maxRetry -gt 3) {
            throw "$($handoff.handoff_id) retry max is not bounded."
        }
        if ([bool]$handoff.retry_failover_policy.retry_limit_enforced -ne $true) {
            throw "$($handoff.handoff_id) retry limit must be enforced."
        }
        if ([bool]$handoff.retry_failover_policy.unbounded_retry_allowed -ne $false) {
            throw "$($handoff.handoff_id) unbounded retry must remain false."
        }
    }
}

function Assert-FailureRoutingExists {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($handoff in @($Set.Handoffs)) {
        if ($null -eq $handoff.failure_routing -or [string]::IsNullOrWhiteSpace([string]$handoff.failure_routing.behavior)) {
            throw "$($handoff.handoff_id) must declare failure routing."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-004 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-004 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-SetValidation -Set $validSet | Out-Null
    Write-Output "PASS valid: generated R18-004 seed handoff packets validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid seed handoff packet set: $($_.Exception.Message)"
}

try {
    Assert-AgentsMapToCards -Set (Get-ValidSet)
    Write-Output "PASS valid: all source/target agents map to R18-002 agent cards."
    $validPassed += 1
}
catch {
    $failures += "FAIL agent mapping: $($_.Exception.Message)"
}

try {
    Assert-SkillsMapToRegistry -Set (Get-ValidSet)
    Write-Output "PASS valid: all skill refs map to R18-003 skill registry and target roles are allowed."
    $validPassed += 1
}
catch {
    $failures += "FAIL skill mapping: $($_.Exception.Message)"
}

try {
    Assert-RuntimeFalseFlags -Set (Get-ValidSet)
    Write-Output "PASS valid: runtime false flags remain false."
    $validPassed += 1
}
catch {
    $failures += "FAIL runtime false flags: $($_.Exception.Message)"
}

try {
    Assert-RetryLimitsBounded -Set (Get-ValidSet)
    Write-Output "PASS valid: retries are bounded."
    $validPassed += 1
}
catch {
    $failures += "FAIL retry limits: $($_.Exception.Message)"
}

try {
    Assert-FailureRoutingExists -Set (Get-ValidSet)
    Write-Output "PASS valid: failure routing exists for every handoff."
    $validPassed += 1
}
catch {
    $failures += "FAIL failure routing: $($_.Exception.Message)"
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R18HandoffObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18HandoffMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    Test-R18HandoffStatusTruth -RepositoryRoot $repoRoot
    Write-Output "PASS valid: R18 status is active through R18-006 only and R18-007 onward planned only."
    $validPassed += 1
}
catch {
    $failures += "FAIL R18 status truth: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 A2A handoff packet schema tests failed."
}

Write-Output ("All R18 A2A handoff packet schema tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
