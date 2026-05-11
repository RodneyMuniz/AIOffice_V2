$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17FinalEvidencePackage.psm1"
Import-Module $modulePath -Force

$paths = Get-R17FinalEvidencePackagePaths -RepositoryRoot $repoRoot
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-TestJson {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-ValidSet {
    return [pscustomobject]@{
        Scorecard = Read-TestJson -Path $paths.KpiScorecard
        Contract = Read-TestJson -Path $paths.KpiContract
        EvidenceIndex = Read-TestJson -Path $paths.EvidenceIndex
        FinalHeadSupportPacket = Read-TestJson -Path $paths.FinalHeadSupportPacket
    }
}

function Invoke-TestSet {
    param([Parameter(Mandatory = $true)]$Set)

    return Test-R17FinalEvidencePackageSet `
        -Scorecard $Set.Scorecard `
        -Contract $Set.Contract `
        -EvidenceIndex $Set.EvidenceIndex `
        -FinalHeadSupportPacket $Set.FinalHeadSupportPacket
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
            if ($message -like ("*{0}*" -f $fragment)) {
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

function Set-AllRuntimeFlag {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][bool]$Value
    )

    foreach ($target in @($Set.Scorecard.runtime_flags, $Set.EvidenceIndex.runtime_flags, $Set.FinalHeadSupportPacket.runtime_flags)) {
        $target.$Name = $Value
    }
}

function Invoke-Mutation {
    param(
        [Parameter(Mandatory = $true)]$Set,
        [Parameter(Mandatory = $true)][string]$Mutation
    )

    switch ($Mutation) {
        "set_r17_closed_true" { Set-AllRuntimeFlag -Set $Set -Name "r17_closed" -Value $true }
        "set_r18_opened_true" { Set-AllRuntimeFlag -Set $Set -Name "r18_opened" -Value $true }
        "set_main_merge_true" { Set-AllRuntimeFlag -Set $Set -Name "main_merge_claimed" -Value $true }
        "set_external_audit_acceptance_true" { Set-AllRuntimeFlag -Set $Set -Name "external_audit_acceptance_claimed" -Value $true }
        "set_four_cycles_true" { Set-AllRuntimeFlag -Set $Set -Name "four_exercised_a2a_cycles_claimed" -Value $true }
        "set_live_a2a_true" { Set-AllRuntimeFlag -Set $Set -Name "live_a2a_runtime_implemented" -Value $true }
        "set_live_recovery_true" { Set-AllRuntimeFlag -Set $Set -Name "live_recovery_loop_runtime_implemented" -Value $true }
        "set_automatic_new_thread_true" { Set-AllRuntimeFlag -Set $Set -Name "automatic_new_thread_creation_performed" -Value $true }
        "set_openai_api_true" { Set-AllRuntimeFlag -Set $Set -Name "openai_api_invoked" -Value $true }
        "set_codex_api_true" { Set-AllRuntimeFlag -Set $Set -Name "codex_api_invoked" -Value $true }
        "set_solved_compaction_true" { Set-AllRuntimeFlag -Set $Set -Name "solved_codex_compaction_claimed" -Value $true }
        "set_solved_reliability_true" { Set-AllRuntimeFlag -Set $Set -Name "solved_codex_reliability_claimed" -Value $true }
        "set_no_manual_prompt_transfer_true" { Set-AllRuntimeFlag -Set $Set -Name "no_manual_prompt_transfer_success_claimed" -Value $true }
        "set_product_runtime_true" { Set-AllRuntimeFlag -Set $Set -Name "product_runtime_executed" -Value $true }
        "append_local_backups_ref" { $Set.EvidenceIndex.evidence_refs = @($Set.EvidenceIndex.evidence_refs) + @(".local_backups/evidence.txt") }
        "set_broad_repo_scan_output_true" { $Set.EvidenceIndex | Add-Member -NotePropertyName "broad_repo_scan_output_embedded" -NotePropertyValue $true -Force }
        "set_oversized_generated_artifacts_true" { $Set.EvidenceIndex | Add-Member -NotePropertyName "oversized_generated_artifacts" -NotePropertyValue $true -Force }
        default { throw "Unknown mutation '$Mutation'." }
    }
}

try {
    Test-R17FinalEvidencePackage -RepositoryRoot $repoRoot | Out-Null
    Write-Output "PASS valid: live R17-028 final evidence package validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R17-028 final evidence package: $($_.Exception.Message)"
}

try {
    $set = Get-ValidSet
    Invoke-TestSet -Set $set | Out-Null
    Write-Output "PASS valid: in-memory R17-028 package set validated."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid in-memory R17-028 package set: $($_.Exception.Message)"
}

$fixtureManifest = Read-TestJson -Path $paths.FixtureManifest
foreach ($fixture in @($fixtureManifest.fixtures)) {
    $fixturePath = Join-Path $paths.FixtureRoot ([string]$fixture.file)
    $fixtureSpec = Read-TestJson -Path $fixturePath
    Invoke-ExpectedRefusal -Label ([string]$fixtureSpec.file) -RequiredFragments @($fixtureSpec.expected_failure_fragments | ForEach-Object { [string]$_ }) -Action {
        $set = Get-ValidSet
        Invoke-Mutation -Set $set -Mutation ([string]$fixtureSpec.mutation)
        Invoke-TestSet -Set $set | Out-Null
    }
}

if ($invalidRejected -lt 17) {
    $failures += "FAIL fixture coverage: expected at least 17 invalid final evidence package fixtures."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "R17-028 final evidence package tests failed."
}

Write-Output ("All R17-028 final evidence package tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
