$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18SkillContractSchema.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_skill_contract_schema.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_skill_contract_schema.ps1"
Import-Module $modulePath -Force

$paths = Get-R18SkillContractSchemaPaths -RepositoryRoot $repoRoot
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
    $skills = foreach ($skillId in @($paths.SkillFiles.Keys)) {
        Read-TestJson -Path $paths.SkillFiles[$skillId]
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Skills = @($skills)
        Registry = Read-TestJson -Path $paths.Registry
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18SkillContractSet -Contract $Set.Contract -Skills $Set.Skills -Registry $Set.Registry -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "skill:*") {
        $skillId = $Target.Substring("skill:".Length)
        $skill = @($Set.Skills | Where-Object { $_.skill_id -eq $skillId }) | Select-Object -First 1
        if ($null -eq $skill) {
            throw "No skill contract found for mutation target '$Target'."
        }
        return $skill
    }

    throw "Unknown mutation target '$Target'."
}

function Assert-RolesMapToAgentCards {
    param([Parameter(Mandatory = $true)][object]$Set)

    $roles = Get-R18AgentCardRoles -RepositoryRoot $repoRoot
    foreach ($skill in @($Set.Skills)) {
        foreach ($role in @($skill.allowed_roles)) {
            if ($roles -notcontains [string]$role) {
                throw "$($skill.skill_id) role '$role' is missing from R18-002 agent cards."
            }
        }
    }
}

function Assert-RuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($flag in @(
            "live_skill_execution_performed",
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
            "r18_004_completed",
            "main_merge_claimed"
        )) {
        foreach ($skill in @($Set.Skills)) {
            if ([bool]$skill.runtime_flags.$flag -ne $false) {
                throw "$($skill.skill_id) runtime flag '$flag' must remain false."
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

function Assert-ApiFlagsDisabled {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($skill in @($Set.Skills)) {
        if ([bool]$skill.api_policy.api_enabled -ne $false) { throw "$($skill.skill_id) api_enabled must remain false." }
        if ([bool]$skill.api_policy.openai_api_invocation_allowed -ne $false) { throw "$($skill.skill_id) OpenAI API allowance must remain false." }
        if ([bool]$skill.api_policy.codex_api_invocation_allowed -ne $false) { throw "$($skill.skill_id) Codex API allowance must remain false." }
        if ([bool]$skill.api_policy.autonomous_codex_invocation_allowed -ne $false) { throw "$($skill.skill_id) autonomous Codex allowance must remain false." }
        if ([bool]$skill.api_policy.automatic_new_thread_creation_allowed -ne $false) { throw "$($skill.skill_id) automatic new-thread allowance must remain false." }
    }
}

function Assert-RetryLimitsBounded {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($skill in @($Set.Skills)) {
        $maxRetry = [int]$skill.retry_policy.max_retry_count
        if ($maxRetry -lt 0 -or $maxRetry -gt 3) {
            throw "$($skill.skill_id) retry max is not bounded."
        }
        if ([bool]$skill.retry_policy.retry_limit_enforced -ne $true) {
            throw "$($skill.skill_id) retry limit must be enforced."
        }
        if ([bool]$skill.retry_policy.unbounded_retry_allowed -ne $false) {
            throw "$($skill.skill_id) unbounded retry must remain false."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-003 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-003 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-SetValidation -Set $validSet | Out-Null
    Write-Output "PASS valid: generated R18-003 seed skill contracts validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid seed skill contract set: $($_.Exception.Message)"
}

try {
    Assert-RolesMapToAgentCards -Set (Get-ValidSet)
    Write-Output "PASS valid: all allowed roles map to R18-002 agent cards."
    $validPassed += 1
}
catch {
    $failures += "FAIL role mapping: $($_.Exception.Message)"
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
    Assert-ApiFlagsDisabled -Set (Get-ValidSet)
    Write-Output "PASS valid: API flags remain disabled."
    $validPassed += 1
}
catch {
    $failures += "FAIL API flags: $($_.Exception.Message)"
}

try {
    Assert-RetryLimitsBounded -Set (Get-ValidSet)
    Write-Output "PASS valid: retry limits are bounded."
    $validPassed += 1
}
catch {
    $failures += "FAIL retry limits: $($_.Exception.Message)"
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R18SkillContractObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18SkillContractMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    Test-R18SkillContractStatusTruth -RepositoryRoot $repoRoot
    Write-Output "PASS valid: R18 status accepts the current active-through R18-013 boundary."
    $validPassed += 1
}
catch {
    $failures += "FAIL R18 status truth: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 skill contract schema tests failed."
}

Write-Output ("All R18 skill contract schema tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
