$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17MemoryArtifactLoader.psm1"
Import-Module $modulePath -Force

$paths = Get-R17MemoryArtifactLoaderPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidFixtureSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_contract.json")
        Report = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_loader_report.json")
        LoadedRefsLog = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_loaded_refs_log.json")
        AgentPackets = @((Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_agent_memory_packets.json")))
        Snapshot = Read-TestJson -Path (Join-Path $paths.FixtureRoot "valid_memory_loader_snapshot.json")
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)][object]$Set)
    return Test-R17MemoryArtifactLoaderSet `
        -Contract $Set.Contract `
        -Report $Set.Report `
        -LoadedRefsLog $Set.LoadedRefsLog `
        -AgentPackets $Set.AgentPackets `
        -Snapshot $Set.Snapshot `
        -RepositoryRoot $repoRoot `
        -SkipUiFiles `
        -SkipFixtureCoverage
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)][object]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "contract" { return $Set.Contract }
        "report" { return $Set.Report }
        "packet" { return (@($Set.AgentPackets | Where-Object { $_.agent_id -eq "developer" }) | Select-Object -First 1) }
        "snapshot" { return $Set.Snapshot }
        default { throw "Unknown mutation target '$Target'." }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17MemoryArtifactLoader -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-013 memory/artifact loader validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-013 memory/artifact loader: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidFixtureSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact fixture set: $($_.Exception.Message)"
}

$invalidFixtureFiles = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name)
if ($invalidFixtureFiles.Count -lt 8) {
    $failures += "FAIL fixture coverage: expected at least 8 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $mutatedSet = Copy-R17MemoryArtifactLoaderObject -Value (Get-ValidFixtureSet)
    $target = Get-MutationTarget -Set $mutatedSet -Target ([string]$fixture.target)
    Invoke-R17MemoryArtifactLoaderMutation -TargetObject $target -Mutation $fixture | Out-Null

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
    throw "R17 memory/artifact loader tests failed."
}

Write-Output ("All R17 memory/artifact loader tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
