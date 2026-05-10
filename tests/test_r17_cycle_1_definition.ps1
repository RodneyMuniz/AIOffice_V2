$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17Cycle1Definition.psm1"
Import-Module $modulePath -Force

$paths = Get-R17Cycle1DefinitionPaths -RepositoryRoot $repoRoot

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-TestJsonLines {
    param([Parameter(Mandatory = $true)][string]$Path)
    $records = @()
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $records += ($line | ConvertFrom-Json)
    }
    return $records
}

function Get-ValidSet {
    return [pscustomobject]@{
        Contract = Read-TestJson -Path $paths.Contract
        OperatorIntent = Read-TestJson -Path $paths.OperatorIntent
        OrchestratorPacket = Read-TestJson -Path $paths.OrchestratorPacket
        PmDefinitionPacket = Read-TestJson -Path $paths.PmDefinitionPacket
        ArchitectDefinitionPacket = Read-TestJson -Path $paths.ArchitectDefinitionPacket
        TaskPacketReadyForDev = Read-TestJson -Path $paths.TaskPacketReadyForDev
        A2aMessages = Read-TestJson -Path $paths.A2aMessages
        A2aHandoffs = Read-TestJson -Path $paths.A2aHandoffs
        A2aDispatchRefs = Read-TestJson -Path $paths.A2aDispatchRefs
        ControlRefs = Read-TestJson -Path $paths.ControlRefs
        BoardEventRefs = Read-TestJson -Path $paths.BoardEventRefs
        CheckReport = Read-TestJson -Path $paths.CheckReport
        BoardCard = Read-TestJson -Path $paths.BoardCard
        BoardEvents = Read-TestJsonLines -Path $paths.BoardEvents
        BoardSnapshot = Read-TestJson -Path $paths.BoardSnapshot
        UiSnapshot = Read-TestJson -Path $paths.UiSnapshot
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17Cycle1DefinitionSet `
        -Contract $Set.Contract `
        -OperatorIntent $Set.OperatorIntent `
        -OrchestratorPacket $Set.OrchestratorPacket `
        -PmDefinitionPacket $Set.PmDefinitionPacket `
        -ArchitectDefinitionPacket $Set.ArchitectDefinitionPacket `
        -TaskPacketReadyForDev $Set.TaskPacketReadyForDev `
        -A2aMessages $Set.A2aMessages `
        -A2aHandoffs $Set.A2aHandoffs `
        -A2aDispatchRefs $Set.A2aDispatchRefs `
        -ControlRefs $Set.ControlRefs `
        -BoardEventRefs $Set.BoardEventRefs `
        -CheckReport $Set.CheckReport `
        -BoardCard $Set.BoardCard `
        -BoardEvents $Set.BoardEvents `
        -BoardSnapshot $Set.BoardSnapshot `
        -UiSnapshot $Set.UiSnapshot `
        -RepositoryRoot $repoRoot `
        -SkipRefExistence `
        -SkipKanbanJsCheck
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        $matched = $false
        foreach ($fragment in $RequiredFragments) {
            if ($message -match [regex]::Escape([string]$fragment)) {
                $matched = $true
            }
        }

        if (-not $matched) {
            $script:failures += "FAIL invalid: $Label rejected with unexpected message: $message"
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Get-MutationTarget {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Target
    )

    switch ($Target) {
        "orchestrator" { return $Set.OrchestratorPacket }
        "task_packet" { return $Set.TaskPacketReadyForDev }
        default { throw "Unknown mutation target '$Target'." }
    }
}

function Invoke-Mutation {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)]$Fixture
    )

    $target = Get-MutationTarget -Set $Set -Target ([string]$Fixture.target)
    switch ([string]$Fixture.mutation) {
        "remove" {
            Remove-R17Cycle1DefinitionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property)
        }
        "set" {
            Set-R17Cycle1DefinitionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property) -Value $Fixture.value
        }
        "append" {
            $existing = @(Get-R17Cycle1DefinitionProperty -Object $target -Name ([string]$Fixture.property) -Context ([string]$Fixture.property))
            $existing += $Fixture.value
            Set-R17Cycle1DefinitionObjectPathValue -TargetObject $target -Path ([string]$Fixture.property) -Value $existing
        }
        default {
            throw "Unknown fixture mutation '$($Fixture.mutation)'."
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    Test-R17Cycle1Definition -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-023 Cycle 1 definition package validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-023 cycle package: $($_.Exception.Message)"
}

try {
    $validSet = Get-ValidSet
    Invoke-TestSet -Set $validSet | Out-Null
    Write-Output "PASS valid: compact live fixture set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid compact fixture set: $($_.Exception.Message)"
}

$invalidFixtureFiles = @(Get-ChildItem -LiteralPath $paths.FixtureRoot -Filter "invalid_*.json" | Sort-Object Name)
if ($invalidFixtureFiles.Count -lt 40) {
    $failures += "FAIL fixture coverage: expected at least 40 compact invalid fixtures."
}

foreach ($fixtureFile in $invalidFixtureFiles) {
    $fixture = Read-TestJson -Path $fixtureFile.FullName
    $expected = @($fixture.expected_failure_fragments | ForEach-Object { [string]$_ })

    Invoke-ExpectedRefusal -Label $fixtureFile.Name -RequiredFragments $expected -Action {
        $set = Copy-R17Cycle1DefinitionObject -Value (Get-ValidSet)
        Invoke-Mutation -Set $set -Fixture $fixture
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17-023 Cycle 1 definition tests failed."
}

Write-Output ("All R17-023 Cycle 1 definition tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
