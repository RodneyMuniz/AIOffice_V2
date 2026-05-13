$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentToolCallEvidence.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_agent_tool_call_evidence.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_agent_tool_call_evidence.ps1"
Import-Module $modulePath -Force

$paths = Get-R18AgentToolCallEvidencePaths -RepositoryRoot $repoRoot
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
    return Get-R18AgentToolCallEvidenceSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18AgentToolCallEvidenceSet `
        -Contract $Set.Contract `
        -LedgerShape $Set.LedgerShape `
        -Profile $Set.Profile `
        -Records $Set.Records `
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
        $Set.LedgerShape.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )
    $runtimeObjects += @($Set.Records | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18AgentToolCallEvidenceRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-021 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-021 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "ledger has planned, dry-run, failed records"; script = { $set = Get-ValidSet; foreach ($mode in @("planned", "dry_run", "failed")) { if (@($set.Records | Where-Object { $_.call_mode -eq $mode }).Count -ne 1) { throw "Missing mode $mode." } } } },
        @{ label = "ledger shape distinguishes live-approved without seeding live records"; script = { $set = Get-ValidSet; if (-not (($set.LedgerShape.call_modes.PSObject.Properties.Name) -contains "live_approved")) { throw "live_approved mode missing." }; if (@($set.Records | Where-Object { $_.call_mode -eq "live_approved" }).Count -ne 0) { throw "R18-021 must not seed live-approved records." } } },
        @{ label = "failed record stops dependent work"; script = { $record = @((Get-ValidSet).Records | Where-Object { $_.call_mode -eq "failed" })[0]; if (-not [bool]$record.evidence_policy.failure_recorded -or -not [bool]$record.evidence_policy.dependent_work_stopped) { throw "Failed record did not stop dependent work." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "input refs include agent cards, skill contracts, runner log, and tool adapter profiles"; script = { $profile = (Get-ValidSet).Profile; foreach ($field in @("agent_cards", "skill_contracts", "runner_log", "tool_adapter_profiles")) { if ([string]::IsNullOrWhiteSpace([string]$profile.input_refs.$field)) { throw "Missing input ref $field." } } } },
        @{ label = "R18 is active through R18-021 only after status updates"; script = { Test-R18AgentToolCallEvidenceStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-022 onward remain planned only"; script = { Test-R18AgentToolCallEvidenceStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18AgentToolCallEvidenceObject -Value (Get-ValidSet)
    $targetObject = Get-R18AgentToolCallEvidenceMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18AgentToolCallEvidenceMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-021 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 agent invocation/tool-call evidence model tests failed."
}

Write-Output ("All R18 agent invocation/tool-call evidence model tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
