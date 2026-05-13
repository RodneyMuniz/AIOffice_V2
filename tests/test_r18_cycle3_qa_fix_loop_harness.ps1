$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle3QaFixLoopHarness.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_cycle3_qa_fix_loop_harness.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_cycle3_qa_fix_loop_harness.ps1"
Import-Module $modulePath -Force

$paths = Get-R18Cycle3QaFixLoopHarnessPaths -RepositoryRoot $repoRoot
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
    return Get-R18Cycle3QaFixLoopHarnessSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18Cycle3QaFixLoopHarnessSet `
        -Contract $Set.Contract `
        -ExecutionPackage $Set.ExecutionPackage `
        -WorkOrderRecords $Set.WorkOrderRecords `
        -DeveloperQaHandoff $Set.DeveloperQaHandoff `
        -QaResultPacket $Set.QaResultPacket `
        -DefectPacket $Set.DefectPacket `
        -RepairPacket $Set.RepairPacket `
        -ValidatorRunLog $Set.ValidatorRunLog `
        -RecoveryRoutePacket $Set.RecoveryRoutePacket `
        -BoardEvents $Set.BoardEvents `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -EvidenceIndex $Set.EvidenceIndex
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.ExecutionPackage.runtime_flags,
        $Set.DeveloperQaHandoff.runtime_flags,
        $Set.QaResultPacket.runtime_flags,
        $Set.DefectPacket.runtime_flags,
        $Set.RepairPacket.runtime_flags,
        $Set.RecoveryRoutePacket.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    foreach ($entry in $Set.WorkOrderRecords) {
        $runtimeObjects += $entry.runtime_flags
    }
    foreach ($entry in $Set.ValidatorRunLog) {
        $runtimeObjects += $entry.runtime_flags
    }
    foreach ($entry in $Set.BoardEvents) {
        $runtimeObjects += $entry.runtime_flags
    }

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18Cycle3QaFixLoopHarnessRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-025 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-025 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "harness evidence exceeds packet-only artifacts"; script = { $set = Get-ValidSet; if ([bool]$set.ExecutionPackage.harness_evidence.packet_only_artifacts -or -not [bool]$set.ExecutionPackage.harness_evidence.harness_runtime_evidence_present) { throw "Harness evidence is packet-only or missing." } } },
        @{ label = "Developer/QA handoff recorded under harness"; script = { $set = Get-ValidSet; if (-not [bool]$set.DeveloperQaHandoff.handoff_validated_under_harness -or [bool]$set.DeveloperQaHandoff.a2a_message_sent) { throw "Developer/QA handoff missing or dispatch claimed." } } },
        @{ label = "validator run log recorded"; script = { $set = Get-ValidSet; if (@($set.ValidatorRunLog).Count -lt 4 -or -not [bool]$set.QaResultPacket.validators_run_under_harness) { throw "Validator run log missing." } } },
        @{ label = "QA defect and repair packets linked"; script = { $set = Get-ValidSet; if ([string]::IsNullOrWhiteSpace($set.QaResultPacket.defect_packet_ref) -or [string]::IsNullOrWhiteSpace($set.QaResultPacket.repair_packet_ref) -or $set.DefectPacket.repair_packet_ref -notlike "*repair_packet.json" -or $set.RepairPacket.defect_packet_ref -notlike "*defect_packet.json") { throw "Defect/repair refs missing." } } },
        @{ label = "board events are evidence-only"; script = { $set = Get-ValidSet; if (@($set.BoardEvents).Count -lt 5 -or [bool]$set.Results.board_event_summary.board_runtime_mutation_performed) { throw "Board event evidence missing or mutation claimed." } } },
        @{ label = "recovery route did not perform recovery action"; script = { $set = Get-ValidSet; if (-not [bool]$set.RecoveryRoutePacket.routed_through_recovery_policy -or [bool]$set.RecoveryRoutePacket.recovery_action_performed) { throw "Recovery route missing or recovery action claimed." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-027 only after status updates"; script = { Test-R18Cycle3QaFixLoopHarnessStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-028 remains planned only"; script = { Test-R18Cycle3QaFixLoopHarnessStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18Cycle3QaFixLoopHarnessObject -Value (Get-ValidSet)
    $targetObject = Get-R18Cycle3QaFixLoopHarnessMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18Cycle3QaFixLoopHarnessMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-025 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 Cycle 3 QA/fix-loop harness tests failed."
}

Write-Output ("All R18 Cycle 3 QA/fix-loop harness tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
