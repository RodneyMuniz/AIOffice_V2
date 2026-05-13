$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OptionalApiAdapterStub.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_optional_api_adapter_stub.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_optional_api_adapter_stub.ps1"
Import-Module $modulePath -Force

$paths = Get-R18OptionalApiAdapterStubPaths -RepositoryRoot $repoRoot
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
    return Get-R18OptionalApiAdapterStubSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18OptionalApiAdapterStubSet `
        -Contract $Set.Contract `
        -Profile $Set.Profile `
        -DryRunEvidencePacketShape $Set.DryRunEvidencePacketShape `
        -BlockedLiveRequest $Set.BlockedLiveRequest `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -EvidenceIndex $Set.EvidenceIndex `
        -RepositoryRoot $repoRoot
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.Contract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.DryRunEvidencePacketShape.runtime_flags,
        $Set.BlockedLiveRequest.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18OptionalApiAdapterStubRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-023 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-023 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "stub defaults disabled"; script = { $set = Get-ValidSet; if ($set.Profile.adapter_stub.default_mode -ne "disabled" -or [bool]$set.Profile.adapter_stub.live_mode_enabled) { throw "Stub is not disabled by default." } } },
        @{ label = "dry-run is shape-only"; script = { $set = Get-ValidSet; if ($set.DryRunEvidencePacketShape.packet_status -ne "dry_run_shape_only_no_api_invocation" -or $set.DryRunEvidencePacketShape.effective_mode -ne "disabled") { throw "Dry-run packet is not shape-only." } } },
        @{ label = "live request is blocked"; script = { $set = Get-ValidSet; if ($set.BlockedLiveRequest.request_outcome -ne "blocked_by_stub_policy_missing_approval_or_budget" -or [bool]$set.BlockedLiveRequest.api_invocation_performed) { throw "Live request was not blocked." } } },
        @{ label = "approval and budget gates block operation"; script = { $set = Get-ValidSet; if ([bool]$set.Profile.operator_enablement.approved -or [decimal]$set.Profile.budget_gate.max_usd_when_disabled -ne 0 -or -not [bool]$set.Profile.budget_gate.missing_budget_blocks_operation) { throw "Approval or budget gate is unsafe." } } },
        @{ label = "R18-022 control refs are present"; script = { $set = Get-ValidSet; if ($set.Profile.control_refs.disabled_api_profile_ref -ne "state/security/r18_api_disabled_profile.json" -or $set.Profile.control_refs.evidence_ledger_shape_ref -ne "state/tools/r18_agent_tool_call_evidence_ledger_shape.json") { throw "Control refs are missing." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-023 only after status updates"; script = { Test-R18OptionalApiAdapterStubStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-024 onward remain planned only"; script = { Test-R18OptionalApiAdapterStubStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18OptionalApiAdapterStubObject -Value (Get-ValidSet)
    $targetObject = Get-R18OptionalApiAdapterStubMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18OptionalApiAdapterStubMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-023 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 optional API adapter stub tests failed."
}

Write-Output ("All R18 optional API adapter stub tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
