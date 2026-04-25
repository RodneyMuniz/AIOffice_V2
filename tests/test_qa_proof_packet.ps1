$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\QaProofPacket.psm1") -Force -PassThru
$testQaProofPacket = $module.ExportedCommands["Test-QaProofPacketContract"]

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

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return (ConvertFrom-Json ($Object | ConvertTo-Json -Depth 30))
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

function New-FixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $shortBase = "C:\t"
    if (-not (Test-Path -LiteralPath $shortBase)) {
        New-Item -ItemType Directory -Path $shortBase -Force | Out-Null
    }

    $tempRoot = Join-Path $shortBase ("qapkt" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $sourceRoot = Join-Path $repoRoot "state\fixtures\valid\qa_proof"
    $fixtureRoot = Join-Path $tempRoot $Label
    Copy-Item -LiteralPath $sourceRoot -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

$validFixture = Join-Path $repoRoot "state\fixtures\valid\qa_proof\qa_proof_packet.valid.json"

try {
    $validResult = & $testQaProofPacket -PacketPath $validFixture
    Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $validFixture), $validResult.PacketId, $validResult.Verdict)
    $validPassed += 1

    $dirtyFailureRoot = New-FixtureRoot -Label "dirty-final-failed-verdict"
    try {
        $dirtyFailurePacketPath = Join-Path $dirtyFailureRoot "qa_proof_packet.valid.json"
        $dirtyFailurePacket = Get-JsonDocument -Path $dirtyFailurePacketPath
        $dirtyFailurePacket.workspace_state.status_after = "dirty"
        $dirtyFailurePacket.qa_verdict = "failed"
        $dirtyFailurePacket.refusal_reasons = @("Dirty final checkout state forces a failed QA verdict.")
        Write-JsonDocument -Path $dirtyFailurePacketPath -Document $dirtyFailurePacket

        $dirtyFailureResult = & $testQaProofPacket -PacketPath $dirtyFailurePacketPath
        Write-Output ("PASS valid dirty-final failed verdict: {0} -> {1}" -f $dirtyFailureResult.PacketId, $dirtyFailureResult.Verdict)
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $dirtyFailureRoot) {
            Remove-Item -LiteralPath $dirtyFailureRoot -Recurse -Force
        }
    }

    $malformedRoot = New-FixtureRoot -Label "malformed"
    try {
        $malformedPacketPath = Join-Path $malformedRoot "qa_proof_packet.valid.json"
        Set-Content -LiteralPath $malformedPacketPath -Value "{ this is not valid json" -Encoding UTF8
        Invoke-ExpectedRefusal -Label "malformed-packet" -RequiredFragments @("not valid JSON") -Action {
            & $testQaProofPacket -PacketPath $malformedPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $malformedRoot) {
            Remove-Item -LiteralPath $malformedRoot -Recurse -Force
        }
    }

    $missingRemoteRoot = New-FixtureRoot -Label "missing-remote-head"
    try {
        $missingRemotePacketPath = Join-Path $missingRemoteRoot "qa_proof_packet.valid.json"
        $missingRemotePacket = Get-JsonDocument -Path $missingRemotePacketPath
        $missingRemotePacket.PSObject.Properties.Remove("remote_head")
        Write-JsonDocument -Path $missingRemotePacketPath -Document $missingRemotePacket
        Invoke-ExpectedRefusal -Label "missing-remote-head" -RequiredFragments @("missing required field 'remote_head'") -Action {
            & $testQaProofPacket -PacketPath $missingRemotePacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingRemoteRoot) {
            Remove-Item -LiteralPath $missingRemoteRoot -Recurse -Force
        }
    }

    $missingLogRoot = New-FixtureRoot -Label "missing-raw-log"
    try {
        $missingLogPacketPath = Join-Path $missingLogRoot "qa_proof_packet.valid.json"
        Remove-Item -LiteralPath (Join-Path $missingLogRoot "logs\test_r7_fault_managed_continuity_proof_review.stdout.log") -Force
        Invoke-ExpectedRefusal -Label "missing-raw-log" -RequiredFragments @("stdout_log_ref", "does not exist") -Action {
            & $testQaProofPacket -PacketPath $missingLogPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingLogRoot) {
            Remove-Item -LiteralPath $missingLogRoot -Recurse -Force
        }
    }

    $failedCommandRoot = New-FixtureRoot -Label "failed-command"
    try {
        $failedCommandPacketPath = Join-Path $failedCommandRoot "qa_proof_packet.valid.json"
        $failedCommandPacket = Get-JsonDocument -Path $failedCommandPacketPath
        $failedCommandPacket.command_results[1].exit_code = 1
        $failedCommandPacket.command_results[1].status = "failed"
        Write-JsonDocument -Path $failedCommandPacketPath -Document $failedCommandPacket
        Invoke-ExpectedRefusal -Label "failed-command-with-passed-verdict" -RequiredFragments @("cannot report qa_verdict 'passed' when any command failed") -Action {
            & $testQaProofPacket -PacketPath $failedCommandPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $failedCommandRoot) {
            Remove-Item -LiteralPath $failedCommandRoot -Recurse -Force
        }
    }

    $dirtyPassedRoot = New-FixtureRoot -Label "dirty-final-passed-verdict"
    try {
        $dirtyPassedPacketPath = Join-Path $dirtyPassedRoot "qa_proof_packet.valid.json"
        $dirtyPassedPacket = Get-JsonDocument -Path $dirtyPassedPacketPath
        $dirtyPassedPacket.workspace_state.status_after = "dirty"
        Write-JsonDocument -Path $dirtyPassedPacketPath -Document $dirtyPassedPacket
        Invoke-ExpectedRefusal -Label "dirty-final-passed-verdict" -RequiredFragments @("cannot report qa_verdict 'passed' when workspace_state is dirty") -Action {
            & $testQaProofPacket -PacketPath $dirtyPassedPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $dirtyPassedRoot) {
            Remove-Item -LiteralPath $dirtyPassedRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL QA proof packet harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("QA proof packet tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All QA proof packet tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
