$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OperatorApprovalGate.psm1"
$generator = Join-Path $repoRoot "tools\new_r18_operator_approval_gate.ps1"
$validator = Join-Path $repoRoot "tools\validate_r18_operator_approval_gate.ps1"
Import-Module $modulePath -Force

$paths = Get-R18OperatorApprovalPaths -RepositoryRoot $repoRoot
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
    return $output
}

function Get-ValidSet {
    return Get-R18OperatorApprovalGateSet -RepositoryRoot $repoRoot
}

function Invoke-SetValidation {
    param([Parameter(Mandatory = $true)][object]$Set)

    return Test-R18OperatorApprovalGateSet `
        -GateContract $Set.GateContract `
        -DecisionContract $Set.DecisionContract `
        -Profile $Set.Profile `
        -Matrix $Set.Matrix `
        -Requests $Set.Requests `
        -Decisions $Set.Decisions `
        -Results $Set.Results `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch -Wildcard ($Target) {
        "request:*" {
            $scope = $Target.Substring("request:".Length)
            return @($Set.Requests | Where-Object { $_.approval_scope -eq $scope })[0]
        }
        "decision:*" {
            $scope = $Target.Substring("decision:".Length)
            return @($Set.Decisions | Where-Object { $_.approval_scope -eq $scope })[0]
        }
        "gate_contract" { return $Set.GateContract }
        "decision_contract" { return $Set.DecisionContract }
        "profile" { return $Set.Profile }
        "matrix" { return $Set.Matrix }
        "results" { return $Set.Results }
        "report" { return $Set.Report }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Assert-AllRuntimeFalseFlags {
    param([Parameter(Mandatory = $true)][object]$Set)

    $runtimeObjects = @(
        $Set.GateContract.runtime_flags,
        $Set.DecisionContract.runtime_flags,
        $Set.Profile.runtime_flags,
        $Set.Matrix.runtime_flags,
        $Set.Results.runtime_flags,
        $Set.Report.runtime_flags,
        $Set.Snapshot.runtime_flags
    )
    $runtimeObjects += @($Set.Requests | ForEach-Object { $_.runtime_flags })
    $runtimeObjects += @($Set.Decisions | ForEach-Object { $_.runtime_flags })

    foreach ($runtimeObject in $runtimeObjects) {
        foreach ($flagName in Get-R18OperatorApprovalRuntimeFlagNames) {
            if ([bool]$runtimeObject.$flagName -ne $false) {
                throw "Runtime flag '$flagName' must remain false."
            }
        }
    }
}

try {
    Invoke-RequiredCommand -Label "R18-016 generator" -ScriptPath $generator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL generator: $($_.Exception.Message)"
}

try {
    Invoke-RequiredCommand -Label "R18-016 validator" -ScriptPath $validator | Out-Null
    $validPassed += 1
}
catch {
    $failures += "FAIL validator: $($_.Exception.Message)"
}

foreach ($assertion in @(
        @{ label = "all six approval scopes exist"; script = { $set = Get-ValidSet; foreach ($scope in Get-R18OperatorApprovalScopes) { if (@($set.Matrix.scope_rows | Where-Object { $_.approval_scope -eq $scope }).Count -ne 1) { throw "Missing scope $scope." } } } },
        @{ label = "all six request packets exist"; script = { if (@((Get-ValidSet).Requests).Count -ne 6) { throw "Expected six request packets." } } },
        @{ label = "all six decision/refusal packets exist"; script = { if (@((Get-ValidSet).Decisions).Count -ne 6) { throw "Expected six decision/refusal packets." } } },
        @{ label = "no seed decision packet approves risky actions"; script = { foreach ($decision in @((Get-ValidSet).Decisions)) { if ([bool]$decision.approved) { throw "Seed decision approved $($decision.approval_scope)." } } } },
        @{ label = "approval cannot be inferred from narration"; script = { foreach ($decision in @((Get-ValidSet).Decisions)) { if ([bool]$decision.approval_inferred_from_narration) { throw "Approval inference was allowed." } } } },
        @{ label = "explicit decision packet is required"; script = { $set = Copy-R18OperatorApprovalObject -Value (Get-ValidSet); $decision = @($set.Decisions | Where-Object { $_.approval_scope -eq "stage_commit_push_gate" })[0]; $decision.approved = $true; try { Invoke-SetValidation -Set $set | Out-Null; throw "Approval without explicit decision packet was accepted." } catch { if ($_.Exception.Message -notlike "*explicit operator decision*") { throw } } } },
        @{ label = "expiry and revocation policies exist"; script = { $set = Get-ValidSet; foreach ($packet in @($set.Requests + $set.Decisions)) { if ($null -eq $packet.expiry_policy -or $null -eq $packet.revocation_policy) { throw "Missing expiry or revocation policy." } } } },
        @{ label = "all runtime false flags remain false"; script = { Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "no forbidden runtime or success claims exist"; script = { Invoke-SetValidation -Set (Get-ValidSet) | Out-Null; Assert-AllRuntimeFalseFlags -Set (Get-ValidSet) } },
        @{ label = "R18 is active through R18-017 only after status updates"; script = { Test-R18OperatorApprovalStatusTruth -RepositoryRoot $repoRoot } },
        @{ label = "R18-020 onward remain planned only"; script = { Test-R18OperatorApprovalStatusTruth -RepositoryRoot $repoRoot } }
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
    $mutatedSet = Copy-R18OperatorApprovalObject -Value (Get-ValidSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R18OperatorApprovalMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

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
    $failures += "FAIL safety: R18-016 tests changed the staged set."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 operator approval gate tests failed."
}

Write-Output ("All R18 operator approval gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
