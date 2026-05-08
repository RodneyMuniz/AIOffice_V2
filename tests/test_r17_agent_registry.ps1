$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentRegistry.psm1"
Import-Module $modulePath -Force

$paths = Get-R17AgentRegistryPaths -RepositoryRoot $repoRoot
$requiredAgents = @(
    "user",
    "operator",
    "orchestrator",
    "project_manager",
    "architect",
    "developer",
    "qa_test_agent",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout"
)

function Read-TestJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    $identityPackets = foreach ($agentId in $requiredAgents) {
        Read-TestJson -Path (Join-Path $paths.FixtureRoot ("valid_{0}_identity.json" -f $agentId))
    }

    return [pscustomobject]@{
        RegistryContract = Read-TestJson -Path $paths.RegistryContract
        IdentityContract = Read-TestJson -Path $paths.IdentityContract
        Registry = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry.json")
        IdentityPackets = @($identityPackets)
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry_check_report.json")
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_agent_registry_snapshot.json")
    }
}

function Invoke-TestSet {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Set
    )

    return Test-R17AgentRegistrySet `
        -RegistryContract $Set.RegistryContract `
        -IdentityContract $Set.IdentityContract `
        -Registry $Set.Registry `
        -IdentityPackets $Set.IdentityPackets `
        -Report $Set.Report `
        -Snapshot $Set.Snapshot
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Set,
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    if ($Target -eq "agent_registry") {
        return $Set.Registry
    }
    if ($Target -eq "check_report") {
        return $Set.Report
    }
    if ($Target -eq "ui_snapshot") {
        return $Set.Snapshot
    }
    if ($Target -like "identity:*") {
        $agentId = $Target.Substring("identity:".Length)
        $identity = @($Set.IdentityPackets | Where-Object { $_.agent_id -eq $agentId }) | Select-Object -First 1
        if ($null -eq $identity) {
            throw "No identity packet found for mutation target '$Target'."
        }
        return $identity
    }

    throw "Unknown mutation target '$Target'."
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17AgentRegistry -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-012 agent registry validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-012 agent registry: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidFixtureSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid fixture set: $($_.Exception.Message)"
}

$invalidFixtureFiles = Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name
foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R17AgentRegistryObject -Value (Get-ValidFixtureSet)
    $targetObject = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R17AgentRegistryMutation -TargetObject $targetObject -Mutation $fixture | Out-Null

    try {
        Invoke-TestSet -Set $mutatedSet | Out-Null
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
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17 agent registry tests failed."
}

Write-Output ("All R17 agent registry tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
