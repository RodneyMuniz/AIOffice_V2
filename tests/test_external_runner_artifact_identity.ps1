$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExternalRunnerArtifactIdentity.psm1") -Force -PassThru
$testExternalRunnerArtifactIdentity = $module.ExportedCommands["Test-ExternalRunnerArtifactIdentityContract"]

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

function New-ExternalRunnerFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r9externalrunner" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-Path $repoRoot "state\fixtures\valid\external_runner_artifact"
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path (Split-Path -Parent $fixtureRoot) -Force | Out-Null
    Copy-Item -LiteralPath $sourceRoot -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function New-CompletedRunnerFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $fixtureRoot = New-ExternalRunnerFixtureRoot -Label $Label
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot "artifacts") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $fixtureRoot "artifacts\qa_packet.json") -Value "{}" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $fixtureRoot "artifacts\remote_head_evidence.json") -Value "{}" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $fixtureRoot "artifacts\final_remote_head_support.json") -Value "{}" -Encoding UTF8

    $packet = Get-JsonDocument -Path (Join-Path $fixtureRoot "external_runner_limitation.valid.json")
    $packet.artifact_id = "r9-004-synthetic-completed-run"
    $packet.run_id = "1234567890"
    $packet.run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/1234567890"
    $packet.artifact_name = "r8-clean-checkout-qa-1234567890-1"
    $packet.artifact_url_or_retrieval_instruction = "Synthetic validator-only retrieval instruction for run 1234567890 artifact r8-clean-checkout-qa-1234567890-1."
    $packet.status = "completed"
    $packet.conclusion = "success"
    $packet.qa_packet_ref = "artifacts/qa_packet.json"
    $packet.remote_head_evidence_ref = "artifacts/remote_head_evidence.json"
    $packet.final_remote_head_support_ref = "artifacts/final_remote_head_support.json"
    $packet.non_claims = @(
        "no broad automation claim",
        "no solved Codex context compaction claim",
        "no unattended long-running milestone claim"
    )

    $packetPath = Join-Path $fixtureRoot "external_runner_artifact_identity.valid.json"
    Write-JsonDocument -Path $packetPath -Document $packet
    return $fixtureRoot
}

function Invoke-ExternalRunnerFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation,
        [switch]$CompletedRun
    )

    $fixtureRoot = if ($CompletedRun) {
        New-CompletedRunnerFixtureRoot -Label $Label
    }
    else {
        New-ExternalRunnerFixtureRoot -Label $Label
    }

    try {
        $packetPath = if ($CompletedRun) {
            Join-Path $fixtureRoot "external_runner_artifact_identity.valid.json"
        }
        else {
            Join-Path $fixtureRoot "external_runner_limitation.valid.json"
        }

        $packet = Get-JsonDocument -Path $packetPath
        & $Mutation $packet
        Write-JsonDocument -Path $packetPath -Document $packet
        return $packetPath
    }
    catch {
        if (Test-Path -LiteralPath $fixtureRoot) {
            Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
        }

        throw
    }
}

function Remove-FixtureForPacket {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $fixtureRoot = Split-Path -Parent $PacketPath
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
$validLimitationFixture = Join-Path $repoRoot "state\fixtures\valid\external_runner_artifact\external_runner_limitation.valid.json"

try {
    $validLimitationResult = & $testExternalRunnerArtifactIdentity -PacketPath $validLimitationFixture
    Write-Output ("PASS valid limitation: {0} -> {1} {2}" -f (Resolve-Path -Relative $validLimitationFixture), $validLimitationResult.ArtifactId, $validLimitationResult.Status)
    $validPassed += 1

    $completedFixtureRoot = New-CompletedRunnerFixtureRoot -Label "valid-completed"
    try {
        $completedFixturePath = Join-Path $completedFixtureRoot "external_runner_artifact_identity.valid.json"
        $completedResult = & $testExternalRunnerArtifactIdentity -PacketPath $completedFixturePath
        Write-Output ("PASS valid synthetic completed model: {0} -> {1} {2}" -f $completedResult.ArtifactId, $completedResult.Status, $completedResult.Conclusion)
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath (Split-Path -Parent $completedFixtureRoot)) {
            Remove-Item -LiteralPath (Split-Path -Parent $completedFixtureRoot) -Recurse -Force
        }
    }

    Invoke-ExpectedRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "artifact_id") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-required-field" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("artifact_id")
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "completed-success-without-run-id" -RequiredFragments @("run_id", "non-empty string") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-run-id" -CompletedRun -Mutation {
            param($packet)
            $packet.run_id = ""
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "completed-success-without-artifact-name" -RequiredFragments @("artifact_name", "non-empty string") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-artifact-name" -CompletedRun -Mutation {
            param($packet)
            $packet.artifact_name = ""
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "github-actions-run-url-not-concrete" -RequiredFragments @("run_url", "required pattern") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "bad-run-url" -CompletedRun -Mutation {
            param($packet)
            $packet.run_url = "https://example.invalid/not-a-github-actions-run"
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "success-without-qa-packet-ref" -RequiredFragments @("qa_packet_ref", "non-empty string") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-qa-packet" -CompletedRun -Mutation {
            param($packet)
            $packet.qa_packet_ref = ""
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "success-without-remote-head-evidence-ref" -RequiredFragments @("remote_head_evidence_ref", "non-empty string") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-remote-head" -CompletedRun -Mutation {
            param($packet)
            $packet.remote_head_evidence_ref = ""
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "invalid-status" -RequiredFragments @("status", "queued, in_progress, completed, unavailable") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "invalid-status" -Mutation {
            param($packet)
            $packet.status = "passed"
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "invalid-conclusion" -RequiredFragments @("conclusion", "success, failure, cancelled, timed_out, skipped, unavailable") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "invalid-conclusion" -Mutation {
            param($packet)
            $packet.conclusion = "passed"
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction claim") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "missing-non-claim" -Mutation {
            param($packet)
            $packet.non_claims = @($packet.non_claims | Where-Object { $_ -ne "no solved Codex context compaction claim" })
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "unavailable-with-run-identity" -RequiredFragments @("unavailable limitation", "must not claim concrete") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "unavailable-with-run" -Mutation {
            param($packet)
            $packet.run_id = "1234567890"
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "unavailable-described-as-proof" -RequiredFragments @("unavailable limitation", "must not be described as proof") -Action {
        $packetPath = Invoke-ExternalRunnerFixtureMutation -Label "unavailable-proof-claim" -Mutation {
            param($packet)
            $packet.artifact_url_or_retrieval_instruction = "limitation note: external proof artifact captured and available."
        }
        try {
            & $testExternalRunnerArtifactIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }
}
catch {
    $failures += ("FAIL external runner artifact identity harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External runner artifact identity tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external runner artifact identity tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
