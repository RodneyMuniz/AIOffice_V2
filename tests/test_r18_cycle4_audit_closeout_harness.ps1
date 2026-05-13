$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18Cycle4AuditCloseoutHarness.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_cycle4_audit_closeout_harness.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_cycle4_audit_closeout_harness.ps1"
Import-Module $modulePath -Force

$paths = Get-R18Cycle4AuditCloseoutHarnessPaths -RepositoryRoot $repoRoot
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
    return Get-R18Cycle4AuditCloseoutHarnessSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18Cycle4AuditCloseoutHarnessSet `
        -Contract $Set.Contract `
        -Package $Set.Package `
        -EvidenceInventory $Set.EvidenceInventory `
        -AuditVerdict $Set.AuditVerdict `
        -ReleaseGateResult $Set.ReleaseGateResult `
        -CloseoutCandidate $Set.CloseoutCandidate `
        -AuditRepairHandoff $Set.AuditRepairHandoff `
        -ValidatorRunLog $Set.ValidatorRunLog `
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
        $Set.Package.runtime_flags,
        $Set.EvidenceInventory.runtime_flags,
        $Set.AuditVerdict.runtime_flags,
        $Set.ReleaseGateResult.runtime_flags,
        $Set.CloseoutCandidate.runtime_flags,
        $Set.AuditRepairHandoff.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    foreach ($entry in $Set.ValidatorRunLog) {
        $runtimeObjects += $entry.runtime_flags
    }
    foreach ($entry in $Set.BoardEvents) {
        $runtimeObjects += $entry.runtime_flags
    }

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18Cycle4AuditCloseoutHarnessRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-026 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-026 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "machine-readable evidence inventory exists"; script = { $set = Get-ValidSet; if (-not [bool]$set.EvidenceInventory.machine_readable -or [int]$set.EvidenceInventory.inventory_count -lt 10) { throw "Machine-readable evidence inventory missing." } } },
        @{ label = "Evidence Auditor review is deterministic"; script = { $set = Get-ValidSet; if (-not [bool]$set.AuditVerdict.evidence_auditor_reviewed_machine_readable_evidence -or [bool]$set.AuditVerdict.runtime_flags.live_evidence_auditor_agent_invoked) { throw "Evidence Auditor review did not preserve live-agent boundary." } } },
        @{ label = "release gate enforces validators, status docs, evidence, and approvals"; script = { $set = Get-ValidSet; if (-not [bool]$set.ReleaseGateResult.validation_gate.passed -or -not [bool]$set.ReleaseGateResult.status_docs_gate.passed -or -not [bool]$set.ReleaseGateResult.evidence_gate.passed -or [bool]$set.ReleaseGateResult.approval_gate.passed) { throw "Release gate enforcement shape is invalid." } } },
        @{ label = "release gate is non-runtime and blocked"; script = { $set = Get-ValidSet; if ([bool]$set.ReleaseGateResult.release_gate_executed -or [bool]$set.ReleaseGateResult.safe_to_closeout) { throw "Release gate execution or unsafe closeout was claimed." } } },
        @{ label = "closeout candidate is not closeout"; script = { $set = Get-ValidSet; if (-not [bool]$set.CloseoutCandidate.closeout_candidate_only -or [bool]$set.CloseoutCandidate.closeout_approved -or [bool]$set.CloseoutCandidate.closeout_performed) { throw "Closeout candidate overclaimed closeout." } } },
        @{ label = "external audit acceptance and main merge remain false"; script = { $set = Get-ValidSet; if ([bool]$set.AuditVerdict.external_audit_acceptance_claimed -or [bool]$set.CloseoutCandidate.main_merge_claimed) { throw "External audit acceptance or main merge was claimed." } } },
        @{ label = "audit failure route prepares repair handoff only"; script = { $set = Get-ValidSet; if (-not [bool]$set.AuditRepairHandoff.audit_failure_creates_repair_handoff -or [bool]$set.AuditRepairHandoff.handoff_dispatched -or [bool]$set.AuditRepairHandoff.a2a_message_sent) { throw "Repair handoff behavior is unsafe." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-026 only after status updates"; script = { Test-R18Cycle4AuditCloseoutHarnessStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-027 onward remain planned only"; script = { Test-R18Cycle4AuditCloseoutHarnessStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18Cycle4AuditCloseoutHarnessObject -Value (Get-ValidSet)
    $targetObject = Get-R18Cycle4AuditCloseoutHarnessMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18Cycle4AuditCloseoutHarnessMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-026 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 Cycle 4 audit/closeout harness tests failed."
}

Write-Output ("All R18 Cycle 4 audit/closeout harness tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
