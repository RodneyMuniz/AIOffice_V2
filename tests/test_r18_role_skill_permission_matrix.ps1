$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RoleSkillPermissionMatrix.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_role_skill_permission_matrix.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_role_skill_permission_matrix.ps1"
Import-Module $modulePath -Force

$paths = Get-R18MatrixPaths -RepositoryRoot $repoRoot
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
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Matrix = Read-TestJson -Path $paths.Matrix
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18RoleSkillPermissionMatrixSet -Contract $Set.Contract -Matrix $Set.Matrix -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -eq "matrix") {
        return $Set.Matrix
    }
    if ($Target -eq "contract") {
        return $Set.Contract
    }
    if ($Target -like "permission:*") {
        $parts = $Target.Split(":", 3)
        $role = $parts[1]
        $skillId = $parts[2]
        $permission = @($Set.Matrix.permissions | Where-Object { $_.role -eq $role -and $_.skill_id -eq $skillId }) | Select-Object -First 1
        if ($null -eq $permission) {
            throw "No permission row found for mutation target '$Target'."
        }
        return $permission
    }
    throw "Unknown mutation target '$Target'."
}

function Assert-RoleMapping {
    param([Parameter(Mandatory = $true)][object]$Set)

    $cards = Get-R18MatrixAgentCardIndex -RepositoryRoot $repoRoot
    foreach ($role in @($Set.Matrix.roles)) {
        if (-not $cards.ContainsKey([string]$role.role)) {
            throw "$($role.role) is missing from R18-002 agent cards."
        }
        if ([string]$role.agent_id -ne [string]$cards[[string]$role.role].agent_id) {
            throw "$($role.role) agent_id does not match the R18-002 card."
        }
    }
}

function Assert-SkillMapping {
    param([Parameter(Mandatory = $true)][object]$Set)

    $skills = Get-R18MatrixSkillRegistryIndex -RepositoryRoot $repoRoot
    foreach ($skill in @($Set.Matrix.skills)) {
        if (-not $skills.ContainsKey([string]$skill.skill_id)) {
            throw "$($skill.skill_id) is missing from R18-003 skill registry."
        }
    }
}

function Assert-DeniedUnsafeCombinations {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($entry in @(
            @{ role = "Orchestrator"; skill = "generate_bounded_artifacts" },
            @{ role = "Project Manager"; skill = "generate_bounded_artifacts" },
            @{ role = "Evidence Auditor"; skill = "generate_bounded_artifacts" },
            @{ role = "Developer/Codex"; skill = "request_operator_approval" },
            @{ role = "QA/Test"; skill = "generate_bounded_artifacts" },
            @{ role = "Release Manager"; skill = "generate_bounded_artifacts" }
        )) {
        $row = @($Set.Matrix.permissions | Where-Object { $_.role -eq $entry.role -and $_.skill_id -eq $entry.skill }) | Select-Object -First 1
        if ($null -eq $row -or $row.permission_status -ne "denied") {
            throw "$($entry.role)/$($entry.skill) must be denied."
        }
    }
}

function Assert-ApprovalGates {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($gate in @(
            "operator_approval_required_for_main_merge",
            "operator_approval_required_for_milestone_closeout",
            "operator_approval_required_for_external_audit_acceptance_claim",
            "operator_approval_required_for_api_enablement",
            "operator_approval_required_for_wip_abandonment",
            "operator_approval_required_for_remote_branch_conflict_resolution",
            "operator_approval_required_for_stage_commit_push_when_risky"
        )) {
        if (@($Set.Matrix.approval_gate_refs) -notcontains $gate) {
            throw "approval gate '$gate' is missing."
        }
    }

    $releaseGate = @($Set.Matrix.permissions | Where-Object { $_.role -eq "Release Manager" -and $_.skill_id -eq "stage_commit_push_gate" }) | Select-Object -First 1
    if ($releaseGate.permission_status -ne "approval_required") {
        throw "Release Manager stage_commit_push_gate must require approval."
    }
}

function Assert-RuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($flag in @(
            "permission_runtime_enforced",
            "live_agent_runtime_invoked",
            "live_skill_execution_performed",
            "a2a_message_sent",
            "live_a2a_runtime_implemented",
            "local_runner_runtime_implemented",
            "live_recovery_runtime_implemented",
            "openai_api_invoked",
            "codex_api_invoked",
            "autonomous_codex_invocation_performed",
            "automatic_new_thread_creation_performed",
            "product_runtime_executed",
            "no_manual_prompt_transfer_success_claimed",
            "solved_codex_compaction_claimed",
            "solved_codex_reliability_claimed",
            "r18_006_completed",
            "main_merge_claimed"
        )) {
        if ([bool]$Set.Matrix.runtime_flags.$flag -ne $false) {
            throw "matrix runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Report.runtime_flags.$flag -ne $false) {
            throw "report runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Snapshot.runtime_summary.$flag -ne $false) {
            throw "snapshot runtime flag '$flag' must remain false."
        }
        foreach ($permission in @($Set.Matrix.permissions)) {
            if ([bool]$permission.runtime_flags.$flag -ne $false) {
                throw "$($permission.role)/$($permission.skill_id) runtime flag '$flag' must remain false."
            }
        }
    }
}

function Assert-ApiFlagsDisabled {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ([bool]$Set.Matrix.api_policy.api_enabled -or [bool]$Set.Matrix.api_policy.openai_api_invocation_allowed -or [bool]$Set.Matrix.api_policy.codex_api_invocation_allowed) {
        throw "matrix API flags must remain disabled."
    }
    foreach ($permission in @($Set.Matrix.permissions)) {
        if ([bool]$permission.api_policy.api_enabled -or [bool]$permission.api_policy.openai_api_invocation_allowed -or [bool]$permission.api_policy.codex_api_invocation_allowed) {
            throw "$($permission.role)/$($permission.skill_id) API flags must remain disabled."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-005 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-005 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-SetValidation -Set $validSet | Out-Null
    Write-Output "PASS valid: generated R18-005 role-to-skill permission matrix validates."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid matrix set: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all roles map to R18-002 agent cards"; script = { Assert-RoleMapping -Set (Get-ValidSet) } },
        @{ label = "all skills map to R18-003 skill registry"; script = { Assert-SkillMapping -Set (Get-ValidSet) } },
        @{ label = "unsafe combinations are denied"; script = { Assert-DeniedUnsafeCombinations -Set (Get-ValidSet) } },
        @{ label = "approval gates are present for risky actions"; script = { Assert-ApprovalGates -Set (Get-ValidSet) } },
        @{ label = "runtime false flags remain false"; script = { Assert-RuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "API flags remain disabled"; script = { Assert-ApiFlagsDisabled -Set (Get-ValidSet) } },
        @{ label = "R18 status accepts the current active-through R18-007 boundary"; script = { Test-R18MatrixStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18MatrixObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18MatrixMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 role-to-skill permission matrix tests failed."
}

Write-Output ("All R18 role-to-skill permission matrix tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
