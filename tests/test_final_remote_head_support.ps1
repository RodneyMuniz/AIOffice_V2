$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\FinalRemoteHeadSupport.psm1") -Force -PassThru
$testFinalRemoteHeadSupport = $module.ExportedCommands["Test-FinalRemoteHeadSupportContract"]

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

function New-FinalRemoteHeadSupportFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r9finalhead" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-Path $repoRoot "state\fixtures\valid\post_push_support"
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path (Split-Path -Parent $fixtureRoot) -Force | Out-Null
    Copy-Item -LiteralPath $sourceRoot -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function Invoke-FinalRemoteHeadFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $fixtureRoot = New-FinalRemoteHeadSupportFixtureRoot -Label $Label
    try {
        $packetPath = Join-Path $fixtureRoot "final_remote_head_support_packet.valid.json"
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
$validFixture = Join-Path $repoRoot "state\fixtures\valid\post_push_support\final_remote_head_support_packet.valid.json"

try {
    $validResult = & $testFinalRemoteHeadSupport -PacketPath $validFixture
    Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $validFixture), $validResult.PacketId, $validResult.Status)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "packet_id") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "missing-required-field" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("packet_id")
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-verified-remote-head" -RequiredFragments @("verified_remote_head", "missing required field") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "missing-verified-head" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("verified_remote_head")
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "malformed-verified-remote-head" -RequiredFragments @("verified_remote_head", "required pattern") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "malformed-verified-head" -Mutation {
            param($packet)
            $packet.verified_remote_head = "not-a-sha"
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-closeout-commit" -RequiredFragments @("closeout_commit", "missing required field") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "missing-closeout" -Mutation {
            param($packet)
            $packet.PSObject.Properties.Remove("closeout_commit")
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "malformed-closeout-commit" -RequiredFragments @("closeout_commit", "required pattern") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "malformed-closeout" -Mutation {
            param($packet)
            $packet.closeout_commit = "not-a-sha"
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "wrong-verification-timing" -RequiredFragments @("verification_timing", "after_closeout_push") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "wrong-timing" -Mutation {
            param($packet)
            $packet.verification_timing = "before_closeout_push"
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "same-commit-support-policy" -RequiredFragments @("support_packet_commit_policy", "not inside the same closeout commit") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "same-commit-policy" -Mutation {
            param($packet)
            $packet.support_packet_commit_policy.not_inside_same_closeout_commit = $false
            $packet.support_packet_commit_policy.statement = "The support packet is committed inside the same closeout commit it verifies."
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "empty-verification-evidence-refs" -RequiredFragments @("verification_evidence_refs", "must not be empty") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "empty-evidence" -Mutation {
            param($packet)
            $packet.verification_evidence_refs = @()
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "invalid-status" -RequiredFragments @("status", "passed, failed, blocked") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "invalid-status" -Mutation {
            param($packet)
            $packet.status = "approved"
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "passed-with-refusal-reasons" -RequiredFragments @("refusal_reasons", "empty when status is 'passed'") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "passed-with-refusals" -Mutation {
            param($packet)
            $packet.refusal_reasons = @("Passed packets cannot carry refusal reasons.")
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "failed-without-refusal-reasons" -RequiredFragments @("refusal_reasons", "must not be empty") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "failed-empty-refusals" -Mutation {
            param($packet)
            $packet.status = "failed"
            $packet.refusal_reasons = @()
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction claim") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "missing-non-claim" -Mutation {
            param($packet)
            $packet.non_claims = @($packet.non_claims | Where-Object { $_ -ne "no solved Codex context compaction claim" })
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }

    Invoke-ExpectedRefusal -Label "ci-claim-without-run-identity" -RequiredFragments @("CI or external runner proof", "concrete run identity") -Action {
        $packetPath = Invoke-FinalRemoteHeadFixtureMutation -Label "ci-without-run" -Mutation {
            param($packet)
            $packet.verification_method.method_type = "ci_runner"
            $packet.verification_method.external_run_identity_ref = ""
            $packet.verification_method.notes = "Claims CI proof without recording a run identity."
        }
        try {
            & $testFinalRemoteHeadSupport -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }
}
catch {
    $failures += ("FAIL final remote-head support harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Final remote-head support tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All final remote-head support tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
