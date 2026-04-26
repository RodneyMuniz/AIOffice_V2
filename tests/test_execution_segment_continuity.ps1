$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExecutionSegmentContinuity.psm1") -Force -PassThru
$testExecutionSegmentArtifact = $module.ExportedCommands["Test-ExecutionSegmentArtifactContract"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 30
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-ExecutionSegmentFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r9segments" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-Path $repoRoot "state\fixtures\valid\execution_segments"
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path (Split-Path -Parent $fixtureRoot) -Force | Out-Null
    Copy-Item -LiteralPath $sourceRoot -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function Get-ExecutionSegmentArtifactPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixtureRoot,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactName
    )

    $fileName = switch ($ArtifactName) {
        "dispatch" { "execution_segment_dispatch.valid.json" }
        "checkpoint" { "execution_segment_checkpoint.valid.json" }
        "result" { "execution_segment_result.valid.json" }
        "resume" { "execution_segment_resume_request.valid.json" }
        "handoff" { "execution_segment_handoff.valid.json" }
        default { throw "Unsupported artifact fixture '$ArtifactName'." }
    }

    return Join-Path $FixtureRoot $fileName
}

function Invoke-ExecutionSegmentFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactName,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $fixtureRoot = New-ExecutionSegmentFixtureRoot -Label $Label
    try {
        $artifactPath = Get-ExecutionSegmentArtifactPath -FixtureRoot $fixtureRoot -ArtifactName $ArtifactName
        $artifact = Get-JsonDocument -Path $artifactPath
        & $Mutation $artifact
        Write-JsonDocument -Path $artifactPath -Document $artifact
        return $artifactPath
    }
    catch {
        if (Test-Path -LiteralPath $fixtureRoot) {
            Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
        }

        throw
    }
}

function Remove-FixtureForArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $fixtureRoot = Split-Path -Parent $ArtifactPath
    $tempRoot = Split-Path -Parent $fixtureRoot
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validFixtureRoot = Join-Path $repoRoot "state\fixtures\valid\execution_segments"

try {
    foreach ($artifactName in @("dispatch", "checkpoint", "result", "resume", "handoff")) {
        $artifactPath = Get-ExecutionSegmentArtifactPath -FixtureRoot $validFixtureRoot -ArtifactName $artifactName
        $validResult = & $testExecutionSegmentArtifact -ArtifactPath $artifactPath
        Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $artifactPath), $validResult.ArtifactType, $validResult.Status)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "artifact_id") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "missing-required-field" -ArtifactName "dispatch" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("artifact_id")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "malformed-git-sha" -RequiredFragments @("baseline_head", "required pattern") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "malformed-git-sha" -ArtifactName "dispatch" -Mutation {
            param($artifact)
            $artifact.baseline_head = "not-a-sha"
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "contradictory-segment-identity" -RequiredFragments @("contradictory", "TaskId") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "contradictory-segment-identity" -ArtifactName "checkpoint" -Mutation {
            param($artifact)
            $artifact.task_id = "R9-006"
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "segment-sequence-going-backward" -RequiredFragments @("segment_sequence", "move forward") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "sequence-backward" -ArtifactName "resume" -Mutation {
            param($artifact)
            $artifact.segment_sequence = 1
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "checkpoint-without-dispatch-ref" -RequiredFragments @("missing required field", "dispatch_ref") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "checkpoint-missing-dispatch" -ArtifactName "checkpoint" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("dispatch_ref")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "result-without-checkpoint-ref" -RequiredFragments @("missing required field", "checkpoint_ref") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "result-missing-checkpoint" -ArtifactName "result" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("checkpoint_ref")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "resume-without-prior-result-ref" -RequiredFragments @("missing required field", "prior_segment_result_ref") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "resume-missing-prior" -ArtifactName "resume" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("prior_segment_result_ref")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "handoff-without-resume-request-ref" -RequiredFragments @("missing required field", "resume_request_ref") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "handoff-missing-resume" -ArtifactName "handoff" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("resume_request_ref")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "expected-current-head-mismatch" -RequiredFragments @("expected_current_head", "prior segment result") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "current-head-mismatch" -ArtifactName "resume" -Mutation {
            param($artifact)
            $artifact.expected_current_head = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-allowed-scope" -RequiredFragments @("missing required field", "allowed_scope") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "missing-allowed-scope" -ArtifactName "dispatch" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("allowed_scope")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-context-budget" -RequiredFragments @("missing required field", "context_budget") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "missing-context-budget" -ArtifactName "handoff" -Mutation {
            param($artifact)
            $artifact.PSObject.Properties.Remove("context_budget")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "empty-expected-outputs" -RequiredFragments @("expected_outputs", "must not be empty") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "empty-expected-outputs" -ArtifactName "dispatch" -Mutation {
            param($artifact)
            $artifact.expected_outputs = @()
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "completed-result-without-evidence" -RequiredFragments @("evidence_refs", "completed") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "completed-without-evidence" -ArtifactName "result" -Mutation {
            param($artifact)
            $artifact.evidence_refs = @()
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "resume-uses-chat-memory" -RequiredFragments @("durable repo artifacts", "chat memory") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "resume-chat-memory" -ArtifactName "resume" -Mutation {
            param($artifact)
            $artifact.required_artifact_refs = @("chat_transcript.md")
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "handoff-uses-chat-transcript-authority" -RequiredFragments @("chat transcript", "authority") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "handoff-chat-authority" -ArtifactName "handoff" -Mutation {
            param($artifact)
            $artifact.handoff_packet.chat_memory_authority = $true
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "artifact-claims-unattended-resume" -RequiredFragments @("must not claim", "unattended automatic resume") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "claims-unattended-resume" -ArtifactName "handoff" -Mutation {
            param($artifact)
            $artifact.handoff_packet.summary = "This proves unattended automatic resume."
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction") -Action {
        $artifactPath = Invoke-ExecutionSegmentFixtureMutation -Label "missing-non-claim" -ArtifactName "dispatch" -Mutation {
            param($artifact)
            $artifact.non_claims = @($artifact.non_claims | Where-Object { $_ -ne "no solved Codex context compaction" })
        }
        try {
            & $testExecutionSegmentArtifact -ArtifactPath $artifactPath | Out-Null
        }
        finally {
            Remove-FixtureForArtifact -ArtifactPath $artifactPath
        }
    }
}
catch {
    $failures += ("FAIL execution segment continuity harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Execution segment continuity tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All execution segment continuity tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
