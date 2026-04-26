$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\IsolatedQaSignoff.psm1") -Force -PassThru
$testIsolatedQaSignoff = $module.ExportedCommands["Test-IsolatedQaSignoffContract"]

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

function New-IsolatedQaFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r9isolatedqa" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-Path $repoRoot "state\fixtures\valid\isolated_qa"
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path (Split-Path -Parent $fixtureRoot) -Force | Out-Null
    Copy-Item -LiteralPath $sourceRoot -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function Invoke-IsolatedQaFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $fixtureRoot = New-IsolatedQaFixtureRoot -Label $Label
    try {
        $packetPath = Join-Path $fixtureRoot "qa_signoff_packet.valid.json"
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

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validFixture = Join-Path $repoRoot "state\fixtures\valid\isolated_qa\qa_signoff_packet.valid.json"

try {
    $validResult = & $testIsolatedQaSignoff -PacketPath $validFixture
    Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $validFixture), $validResult.PacketId, $validResult.Verdict)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "missing-qa-role-identity" -RequiredFragments @("qa_role_identity", "missing required field") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "missing-qa-role" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("qa_role_identity")
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-qa-runner-kind" -RequiredFragments @("qa_runner_kind", "missing required field") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "missing-runner-kind" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("qa_runner_kind")
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-qa-authority-type" -RequiredFragments @("qa_authority_type", "missing required field") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "missing-authority-type" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("qa_authority_type")
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "executor-self-certification-authority" -RequiredFragments @("qa_authority_type", "executor self-certification") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "executor-self-cert" -Mutation {
            param($packet)
            $packet.qa_authority_type = "executor_self_certification"
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "executor-only-source-evidence" -RequiredFragments @("source_artifacts", "executor evidence alone") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "executor-only-source" -Mutation {
            param($packet)
            $executorArtifact = @($packet.source_artifacts | Where-Object { $_.artifact_kind -eq "executor_evidence" })[0]
            $packet.source_artifacts = @($executorArtifact)
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-remote-head-evidence-ref" -RequiredFragments @("remote_head_evidence_ref", "missing required field") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "missing-remote-ref" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("remote_head_evidence_ref")
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-clean-checkout-or-external-qa-ref" -RequiredFragments @("clean_checkout_or_external_qa_ref", "missing required field") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "missing-clean-ref" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("clean_checkout_or_external_qa_ref")
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "invalid-verdict" -RequiredFragments @("verdict", "passed, failed, blocked") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "invalid-verdict" -Mutation {
            param($packet)
            $packet.verdict = "approved"
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "executor-evidence-as-qa-authority" -RequiredFragments @("executor evidence refs", "QA verdict authority") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "executor-authority" -Mutation {
            param($packet)
            $packet.source_artifacts[0].authority_role = "qa_verdict_authority"
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "contradictory-independence-boundary" -RequiredFragments @("independence_boundary", "same executor produced and approved") -Action {
        $packetPath = Invoke-IsolatedQaFixtureMutation -Label "same-executor-boundary" -Mutation {
            param($packet)
            $packet.independence_boundary.qa_identity = $packet.independence_boundary.executor_identity
            $packet.independence_boundary.statement = "The same executor produced and approved the signoff."
            $packet.qa_role_identity = $packet.independence_boundary.executor_identity
        }
        try {
            & $testIsolatedQaSignoff -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }
}
catch {
    $failures += ("FAIL isolated QA signoff harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Isolated QA signoff tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All isolated QA signoff tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
