$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ApiSafetyControls.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_api_safety_controls.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_api_safety_controls.ps1"
Import-Module $modulePath -Force

$paths = Get-R18ApiSafetyControlsPaths -RepositoryRoot $repoRoot
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
    return Get-R18ApiSafetyControlsSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18ApiSafetyControlsSet `
        -Contract $Set.Contract `
        -DisabledProfile $Set.DisabledProfile `
        -SecretsPolicy $Set.SecretsPolicy `
        -BudgetTokenPolicy $Set.BudgetTokenPolicy `
        -TimeoutPolicy $Set.TimeoutPolicy `
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
        $Set.DisabledProfile.runtime_flags,
        $Set.SecretsPolicy.runtime_flags,
        $Set.BudgetTokenPolicy.runtime_flags,
        $Set.TimeoutPolicy.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags,
        $Set.EvidenceIndex.runtime_flags
    )

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18ApiSafetyControlsRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-022 generator" -ScriptPath $generator
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-022 validator" -ScriptPath $validator
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "API disabled by default"; script = { $set = Get-ValidSet; if ([bool]$set.DisabledProfile.api_enabled -ne $false -or [bool]$set.DisabledProfile.codex_api_enabled -ne $false -or [bool]$set.DisabledProfile.openai_api_enabled -ne $false) { throw "API profile is not disabled." } } },
        @{ label = "secrets never committed and logs redact secrets"; script = { $set = Get-ValidSet; if ([bool]$set.SecretsPolicy.committed_secret_values_present -ne $false -or [bool]$set.SecretsPolicy.logging_redaction_policy.redact_secret_values -ne $true) { throw "Secrets policy is unsafe." } } },
        @{ label = "per-request and per-task budgets exist"; script = { $set = Get-ValidSet; if (-not [bool]$set.BudgetTokenPolicy.per_request_budget_usd.limit_defined -or -not [bool]$set.BudgetTokenPolicy.per_task_budget_usd.limit_defined) { throw "Budget limits are missing." } } },
        @{ label = "token budget exists and is bounded"; script = { $set = Get-ValidSet; if (-not [bool]$set.BudgetTokenPolicy.token_budget.per_task_total_token_limit_defined -or [bool]$set.BudgetTokenPolicy.token_budget.unbounded_tokens_allowed) { throw "Token budget is unsafe." } } },
        @{ label = "timeouts exist and are bounded"; script = { $set = Get-ValidSet; if (-not [bool]$set.TimeoutPolicy.timeout_policy.per_request_timeout_limit_defined -or -not [bool]$set.TimeoutPolicy.timeout_policy.per_task_timeout_limit_defined -or [bool]$set.TimeoutPolicy.timeout_policy.unbounded_timeout_allowed) { throw "Timeout policy is unsafe." } } },
        @{ label = "operator approval required"; script = { $set = Get-ValidSet; if (-not [bool]$set.DisabledProfile.enablement_requirements.operator_approval_required -or [bool]$set.DisabledProfile.enablement_requirements.seed_decision_approved) { throw "Operator approval boundary is unsafe." } } },
        @{ label = "all runtime flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-023 only after status updates"; script = { Test-R18ApiSafetyControlsStatusTruth -RepositoryRoot $repoRoot | Out-Null } },
        @{ label = "R18-024 onward remain planned only"; script = { Test-R18ApiSafetyControlsStatusTruth -RepositoryRoot $repoRoot | Out-Null } }
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
    $mutatedSet = Copy-R18ApiSafetyControlsObject -Value (Get-ValidSet)
    $targetObject = Get-R18ApiSafetyControlsMutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18ApiSafetyControlsMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-022 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 safety/secrets/budget/token controls tests failed."
}

Write-Output ("All R18 safety/secrets/budget/token controls tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
