$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18CompactFailureRecoveryDrill.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_compact_failure_recovery_drill.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_compact_failure_recovery_drill.ps1"
Import-Module $modulePath -Force

$paths = Get-R18CompactFailureRecoveryDrillPaths -RepositoryRoot $repoRoot
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
}

function Get-ValidSet {
    return Get-R18CompactFailureRecoveryDrillSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18CompactFailureRecoveryDrillSet `
        -Contract $Set.Contract `
        -DrillPacket $Set.DrillPacket `
        -FailureEvent $Set.FailureEvent `
        -WipClassification $Set.WipClassification `
        -RemoteVerification $Set.RemoteVerification `
        -ContinuationPacket $Set.ContinuationPacket `
        -NewContextPacket $Set.NewContextPacket `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -EvidenceIndex $Set.EvidenceIndex `
        -RunnerLogEntries $Set.RunnerLogEntries
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.DrillPacket.runtime_flags,
        $Set.FailureEvent.runtime_flags,
        $Set.WipClassification.runtime_flags,
        $Set.RemoteVerification.runtime_flags,
        $Set.ContinuationPacket.runtime_flags,
        $Set.NewContextPacket.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    foreach ($entry in $Set.RunnerLogEntries) {
        $runtimeObjects += $entry.runtime_flags
    }

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18CompactFailureRecoveryDrillRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-024 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-024 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "runner evidence is present"; script = { $set = Get-ValidSet; if (-not [bool]$set.DrillPacket.runner_evidence.runner_evidence_present -or [bool]$set.DrillPacket.runner_evidence.packet_only_recovery) { throw "Runner evidence is missing or packet-only recovery is true." } } },
        @{ label = "last completed and next safe step recorded"; script = { $set = Get-ValidSet; if ([string]::IsNullOrWhiteSpace($set.DrillPacket.last_completed_step) -or [string]::IsNullOrWhiteSpace($set.DrillPacket.next_safe_step)) { throw "Missing drill step fields." } } },
        @{ label = "retry count bounded"; script = { $set = Get-ValidSet; if ([int]$set.DrillPacket.retry_count -gt [int]$set.DrillPacket.max_retry_count -or [int]$set.DrillPacket.max_retry_count -gt 2 -or -not [bool]$set.DrillPacket.retry_limit_enforced) { throw "Retry count is not bounded." } } },
        @{ label = "operator decision points recorded"; script = { $set = Get-ValidSet; if (@($set.DrillPacket.operator_decision_points).Count -lt 3) { throw "Missing operator decision points." } } },
        @{ label = "runner log has required events"; script = { $set = Get-ValidSet; $events = @($set.RunnerLogEntries | ForEach-Object { $_.event_type }); foreach ($event in @("preflight_verified", "runner_state_loaded", "failure_event_recorded", "wip_classification_linked", "remote_verification_linked", "continuation_packets_recorded", "operator_decision_points_recorded")) { if ($events -notcontains $event) { throw "Missing runner log event $event." } } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-025 only after status updates"; script = { Test-R18CompactFailureRecoveryDrillStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-026 onward remain planned only"; script = { Test-R18CompactFailureRecoveryDrillStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18CompactFailureRecoveryDrillObject -Value (Get-ValidSet)
    $targetObject = Get-R18CompactFailureRecoveryDrillMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18CompactFailureRecoveryDrillMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-024 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 compact-failure recovery drill tests failed."
}

Write-Output ("All R18 compact-failure recovery drill tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
