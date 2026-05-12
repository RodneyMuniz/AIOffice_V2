$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OrchestratorControlIntake.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_orchestrator_control_intake.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_orchestrator_control_intake.ps1"
Import-Module $modulePath -Force

$paths = Get-R18IntakePaths -RepositoryRoot $repoRoot
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
    $packets = @()
    foreach ($file in Get-ChildItem -LiteralPath $paths.PacketRoot -Filter "*.intake.json" | Sort-Object Name) {
        $packets += Read-TestJson -Path $file.FullName
    }

    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        Packets = $packets
        Registry = Read-TestJson -Path $paths.Registry
        Report = Read-TestJson -Path $paths.CheckReport
        Snapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R18OrchestratorControlIntakeSet -Contract $Set.Contract -Packets $Set.Packets -Registry $Set.Registry -Report $Set.Report -Snapshot $Set.Snapshot -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if ($Target -like "packet:*") {
        $type = $Target.Substring("packet:".Length)
        $packet = @($Set.Packets | Where-Object { $_.intake_type -eq $type }) | Select-Object -First 1
        if ($null -eq $packet) {
            throw "No intake packet found for mutation target '$Target'."
        }
        return $packet
    }
    if ($Target -eq "contract") {
        return $Set.Contract
    }
    throw "Unknown mutation target '$Target'."
}

function Assert-RequiredIntakeTypes {
    param([Parameter(Mandatory = $true)][object]$Set)

    $expected = @(
        "create_work_order_request",
        "status_query_request",
        "recovery_resume_request",
        "retry_escalation_request",
        "evidence_query_request",
        "operator_approval_request",
        "operator_rejection_request",
        "stop_block_request"
    )
    $actual = @($Set.Packets | ForEach-Object { [string]$_.intake_type } | Sort-Object)
    $expectedSorted = @($expected | Sort-Object)
    if (($actual -join "|") -ne ($expectedSorted -join "|")) {
        throw "Intake types are not exactly the required set."
    }
}

function Assert-RoleMapping {
    param([Parameter(Mandatory = $true)][object]$Set)

    $cards = Get-R18IntakeAgentCardIndex -RepositoryRoot $repoRoot
    foreach ($packet in @($Set.Packets)) {
        $role = [string]$packet.target_scope.target_role
        if (-not $cards.ContainsKey($role)) {
            throw "$($packet.intake_id) target role '$role' is missing from R18-002 agent cards."
        }
    }
}

function Assert-SkillMapping {
    param([Parameter(Mandatory = $true)][object]$Set)

    $skills = Get-R18IntakeSkillRegistryIndex -RepositoryRoot $repoRoot
    foreach ($packet in @($Set.Packets)) {
        $skill = [string]$packet.target_scope.target_skill
        if (-not $skills.ContainsKey($skill)) {
            throw "$($packet.intake_id) target skill '$skill' is missing from R18-003 skill registry."
        }
    }
}

function Assert-PermissionMatrixRefs {
    param([Parameter(Mandatory = $true)][object]$Set)

    $permissions = Get-R18IntakePermissionIndex -RepositoryRoot $repoRoot
    foreach ($packet in @($Set.Packets)) {
        if ([string]$packet.permission_matrix_ref.matrix_ref -ne "state/skills/r18_role_skill_permission_matrix.json") {
            throw "$($packet.intake_id) does not reference the R18-005 permission matrix."
        }
        $key = "{0}|{1}" -f [string]$packet.target_scope.target_role, [string]$packet.target_scope.target_skill
        if (-not $permissions.ContainsKey($key)) {
            throw "$($packet.intake_id) target role/skill pairing is missing from the permission matrix."
        }
    }
}

function Assert-DeniedPermissionRoutesToBlock {
    $set = Copy-R18IntakeObject -Value (Get-ValidSet)
    $packet = @($set.Packets | Where-Object { $_.intake_type -eq "operator_approval_request" }) | Select-Object -First 1
    $packet.target_scope.target_role = "Developer/Codex"
    $packet.target_scope.target_skill = "request_operator_approval"
    $packet.agent_card_refs = @(
        [pscustomobject]@{ role = "Orchestrator"; agent_id = "agent_orchestrator"; card_ref = "state/agents/r18_agent_cards/agent_orchestrator.card.json" },
        [pscustomobject]@{ role = "Developer/Codex"; agent_id = "agent_developer_codex"; card_ref = "state/agents/r18_agent_cards/agent_developer_codex.card.json" }
    )
    $packet.permission_matrix_ref.permission_id = "developer_codex__request_operator_approval"
    $packet.permission_matrix_ref.role = "Developer/Codex"
    $packet.permission_matrix_ref.skill_id = "request_operator_approval"
    $packet.permission_matrix_ref.permission_status = "denied"
    $packet.failure_routing.behavior = "fail_closed_and_block_intake"
    $packet.failure_routing.block_on_denied_permission = $true

    Invoke-SetValidation -Set $set | Out-Null
}

function Assert-RuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    foreach ($flag in @(
            "live_chat_ui_implemented",
            "orchestrator_runtime_implemented",
            "intake_routed_by_runtime",
            "board_runtime_mutation_performed",
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
            "r18_007_completed",
            "main_merge_claimed"
        )) {
        if ([bool]$Set.Report.runtime_flags.$flag -ne $false) {
            throw "check report runtime flag '$flag' must remain false."
        }
        if ([bool]$Set.Snapshot.runtime_summary.$flag -ne $false) {
            throw "snapshot runtime flag '$flag' must remain false."
        }
        foreach ($packet in @($Set.Packets)) {
            if ([bool]$packet.runtime_flags.$flag -ne $false) {
                throw "$($packet.intake_id) runtime flag '$flag' must remain false."
            }
        }
    }
}

function Assert-ApiFlagsDisabled {
    param([Parameter(Mandatory = $true)][object]$Set)

    if ([bool]$Set.Contract.api_policy.api_enabled -or [bool]$Set.Contract.api_policy.openai_api_invocation_allowed -or [bool]$Set.Contract.api_policy.codex_api_invocation_allowed) {
        throw "contract API flags must remain disabled."
    }
    foreach ($packet in @($Set.Packets)) {
        if ([bool]$packet.runtime_flags.openai_api_invoked -or [bool]$packet.runtime_flags.codex_api_invoked) {
            throw "$($packet.intake_id) API invocation flags must remain false."
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-006 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-006 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-SetValidation -Set $validSet | Out-Null
    Write-Output "PASS valid: generated R18-006 Orchestrator control intake validates."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid intake set: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "intake types are exactly the required set"; script = { Assert-RequiredIntakeTypes -Set (Get-ValidSet) } },
        @{ label = "target roles map to R18-002 agent cards"; script = { Assert-RoleMapping -Set (Get-ValidSet) } },
        @{ label = "target skills map to R18-003 skill registry"; script = { Assert-SkillMapping -Set (Get-ValidSet) } },
        @{ label = "permission matrix refs exist and are used"; script = { Assert-PermissionMatrixRefs -Set (Get-ValidSet) } },
        @{ label = "denied permissions route to failure/block behavior"; script = { Assert-DeniedPermissionRoutesToBlock } },
        @{ label = "runtime false flags remain false"; script = { Assert-RuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "API flags remain disabled"; script = { Assert-ApiFlagsDisabled -Set (Get-ValidSet) } },
        @{ label = "R18 status accepts the current active-through R18-013 boundary"; script = { Test-R18IntakeStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18IntakeObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18IntakeMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $fixture = Read-TestJson -Path (Join-Path $paths.FixtureRoot "invalid_raw_prompt_only_recovery.json")
    $mutatedSet = Copy-R18IntakeObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18IntakeMutation -TargetObject $targetObject -Mutation $fixture | Out-Null
    try {
        Invoke-SetValidation -Set $mutatedSet | Out-Null
        $failures += "FAIL raw prompt-only recovery: fixture was accepted."
    }
    catch {
        if ($_.Exception.Message -notmatch "raw prompt-only recovery") {
            $failures += "FAIL raw prompt-only recovery: unexpected rejection '$($_.Exception.Message)'."
        }
        else {
            Write-Output "PASS valid: raw prompt-only recovery is rejected."
            $validPassed += 1
        }
    }
}
catch {
    $failures += "FAIL raw prompt-only recovery explicit check: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 Orchestrator control intake tests failed."
}

Write-Output ("All R18 Orchestrator control intake tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
