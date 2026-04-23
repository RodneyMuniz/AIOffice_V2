$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\MilestoneContinuity.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot
$checkpointFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_checkpoint.valid.json"
$handoffFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\continuity_handoff_packet.valid.json"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r7-003-" + [System.Guid]::NewGuid().ToString("N"))

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
    $checkpointResult = Test-MilestoneContinuityCheckpointContract -ArtifactPath $checkpointFixture
    Write-Output ("PASS valid checkpoint: {0} -> {1}" -f (Resolve-Path -Relative $checkpointFixture), $checkpointResult.ArtifactId)
    $validPassed += 1

    $handoffResult = Test-MilestoneContinuityHandoffPacketContract -ArtifactPath $handoffFixture
    Write-Output ("PASS valid handoff: {0} -> {1}" -f (Resolve-Path -Relative $handoffFixture), $handoffResult.ArtifactId)
    $validPassed += 1

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $checkpointDocument = Get-JsonDocument -Path $checkpointFixture
    $emittedCheckpointPath = Join-Path $tempRoot "continuity_checkpoint.emitted.json"
    $emittedCheckpoint = New-MilestoneContinuityCheckpointArtifact -Checkpoint $checkpointDocument -OutputPath $emittedCheckpointPath
    $emittedCheckpointValidation = Test-MilestoneContinuityCheckpointContract -ArtifactPath $emittedCheckpoint.OutputPath
    Write-Output ("PASS emitted checkpoint: {0} -> {1}" -f $emittedCheckpointValidation.ArtifactId, $emittedCheckpointValidation.RequiredNextAction)
    $validPassed += 1

    $handoffDocument = Get-JsonDocument -Path $handoffFixture
    $emittedHandoffPath = Join-Path $tempRoot "continuity_handoff_packet.emitted.json"
    $emittedHandoff = New-MilestoneContinuityHandoffPacketArtifact -HandoffPacket $handoffDocument -OutputPath $emittedHandoffPath
    $emittedHandoffValidation = Test-MilestoneContinuityHandoffPacketContract -ArtifactPath $emittedHandoff.OutputPath
    Write-Output ("PASS emitted handoff: {0} -> {1}" -f $emittedHandoffValidation.ArtifactId, $emittedHandoffValidation.RequiredNextAction)
    $validPassed += 1

    $invalidCases = @(
        @{
            Name = "checkpoint-missing-required-field"
            Type = "checkpoint"
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("checkpoint_snapshot")
                return $Document
            }
        },
        @{
            Name = "handoff-missing-fault-event-ref"
            Type = "handoff"
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("fault_event_ref")
                return $Document
            }
        },
        @{
            Name = "checkpoint-contradictory-git-context"
            Type = "checkpoint"
            Mutate = {
                param($Document)
                $Document.git_context.head_commit = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                return $Document
            }
        },
        @{
            Name = "handoff-checkpoint-mismatch"
            Type = "handoff"
            Mutate = {
                param($Document)
                $Document.checkpoint_ref.checkpoint_id = "checkpoint-r7-003-segment-999"
                return $Document
            }
        },
        @{
            Name = "handoff-invalid-required-next-action"
            Type = "handoff"
            Mutate = {
                param($Document)
                $Document.required_next_action = "automatic_resume"
                return $Document
            }
        }
    )

    foreach ($invalidCase in @($invalidCases)) {
        $seedDocument = if ($invalidCase.Type -eq "checkpoint") { $checkpointDocument } else { $handoffDocument }
        $invalidDocument = Copy-JsonObject -Object $seedDocument
        $invalidDocument = & $invalidCase.Mutate $invalidDocument

        try {
            if ($invalidCase.Type -eq "checkpoint") {
                Test-MilestoneContinuityCheckpointObject -Checkpoint $invalidDocument -SourceLabel $invalidCase.Name | Out-Null
            }
            else {
                Test-MilestoneContinuityHandoffPacketObject -HandoffPacket $invalidDocument -SourceLabel $invalidCase.Name | Out-Null
            }

            $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $invalidCase.Name)
        }
        catch {
            Write-Output ("PASS invalid: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
            $invalidRejected += 1
        }
    }
}
catch {
    $failures += ("FAIL milestone continuity harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Force -Recurse
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone continuity artifact tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone continuity artifact tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
