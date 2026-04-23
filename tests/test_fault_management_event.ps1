$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\FaultManagement.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot
$validFixture = Join-Path $repoRoot "state\fixtures\valid\fault_management\fault_event.valid.json"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return (ConvertFrom-Json ($Object | ConvertTo-Json -Depth 20))
}

try {
    $validResult = Test-FaultManagementEventContract -EventPath $validFixture
    Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $validFixture), $validResult.EventType, $validResult.EventId)
    $validPassed += 1

    $validEvent = Get-JsonDocument -Path $validFixture
    $inMemoryResult = Test-FaultManagementEventObject -FaultEvent $validEvent -SourceLabel "valid in-memory fault event"
    Write-Output ("PASS valid in-memory: {0} -> {1}" -f $inMemoryResult.EventId, $inMemoryResult.RequiredNextAction)
    $validPassed += 1

    $invalidCases = @(
        @{
            Name = "missing-reason-summary"
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("reason_summary")
                return $Document
            }
        },
        @{
            Name = "malformed-event-id"
            Mutate = {
                param($Document)
                $Document.event_id = "Invalid Event Id"
                return $Document
            }
        },
        @{
            Name = "invalid-trigger-classification"
            Mutate = {
                param($Document)
                $Document.trigger_classification = "automatic_recovery"
                return $Document
            }
        },
        @{
            Name = "invalid-required-next-action"
            Mutate = {
                param($Document)
                $Document.required_next_action = "automatic_resume"
                return $Document
            }
        },
        @{
            Name = "contradictory-event-category"
            Mutate = {
                param($Document)
                $Document.event_category = "tool_failure"
                return $Document
            }
        },
        @{
            Name = "contradictory-cycle-scope-with-task-id"
            Mutate = {
                param($Document)
                $Document.affected_scope.scope_level = "cycle"
                return $Document
            }
        }
    )

    foreach ($invalidCase in @($invalidCases)) {
        $invalidEvent = Copy-JsonObject -Object $validEvent
        $invalidEvent = & $invalidCase.Mutate $invalidEvent

        try {
            Test-FaultManagementEventObject -FaultEvent $invalidEvent -SourceLabel $invalidCase.Name | Out-Null
            $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $invalidCase.Name)
        }
        catch {
            Write-Output ("PASS invalid: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
            $invalidRejected += 1
        }
    }
}
catch {
    $failures += ("FAIL fault management harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Fault management event tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All fault management event tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
