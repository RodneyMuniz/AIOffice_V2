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

function New-CompletionClaimFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixtureRoot
    )

    $packetPath = Join-Path $FixtureRoot "qa_proof_packet.valid.json"
    $packet = Get-JsonDocument -Path $packetPath

    $supplementalCommandResults = @(
        @{
            command_id = "clean-checkout-runner"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_clean_checkout_qa.ps1"
            stdout_log_ref = "logs/invoke_clean_checkout_qa.stdout.log"
            stderr_log_ref = "logs/invoke_clean_checkout_qa.stderr.log"
            exit_code = 0
            status = "passed"
        },
        @{
            command_id = "qa-packet-validator"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_qa_proof_packet.ps1 -PacketPath state\fixtures\valid\qa_proof\qa_proof_packet.valid.json"
            stdout_log_ref = "logs/validate_qa_proof_packet.stdout.log"
            stderr_log_ref = "logs/validate_qa_proof_packet.stderr.log"
            exit_code = 0
            status = "passed"
        },
        @{
            command_id = "remote-head-verifier"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify_remote_branch_head.ps1"
            stdout_log_ref = "logs/verify_remote_branch_head.stdout.log"
            stderr_log_ref = "logs/verify_remote_branch_head.stderr.log"
            exit_code = 0
            status = "passed"
        },
        @{
            command_id = "post-push-verifier"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify_post_push_remote_head.ps1"
            stdout_log_ref = "logs/verify_post_push_remote_head.stdout.log"
            stderr_log_ref = "logs/verify_post_push_remote_head.stderr.log"
            exit_code = 0
            status = "passed"
        },
        @{
            command_id = "git-status-porcelain"
            command = "git status --porcelain"
            stdout_log_ref = "logs/git_status_porcelain_completion.stdout.log"
            stderr_log_ref = "logs/git_status_porcelain_completion.stderr.log"
            exit_code = 0
            status = "passed"
        }
    )

    foreach ($supplementalCommandResult in $supplementalCommandResults) {
        Set-Content -LiteralPath (Join-Path $FixtureRoot $supplementalCommandResult.stdout_log_ref) -Value ("stdout for {0}" -f $supplementalCommandResult.command_id) -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $FixtureRoot $supplementalCommandResult.stderr_log_ref) -Value "" -Encoding UTF8
    }

    $remoteHeadVerificationPath = Join-Path $FixtureRoot "artifacts\\remote_head_verification.valid.json"
    Write-JsonDocument -Path $remoteHeadVerificationPath -Document ([pscustomobject]@{
            contract_version = "v1"
            record_type = "remote_head_verification_result"
            verification_id = "remote-head-verification-r8-006-valid-001"
            repository_name = $packet.repository.repository_name
            branch = $packet.branch
            local_head = $packet.remote_head
            remote_head = $packet.remote_head
            commit_subject = "Valid fixture remote-head verification artifact"
            tree_hash = $packet.tree_hash
            verified_at_utc = $packet.captured_at_utc
            status = "matched"
            result = "passed"
            refusal_reason = ""
        })

    $postPushVerificationPath = Join-Path $FixtureRoot "artifacts\\post_push_verification.valid.json"
    Write-JsonDocument -Path $postPushVerificationPath -Document ([pscustomobject]@{
            contract_version = "v1"
            record_type = "post_push_verification_result"
            verification_id = "post-push-verification-r8-006-valid-001"
            repository_name = $packet.repository.repository_name
            branch = $packet.branch
            expected_pushed_commit = $packet.remote_head
            actual_remote_head = $packet.remote_head
            commit_subject = "Valid fixture post-push verification artifact"
            tree_hash = $packet.tree_hash
            verified_at_utc = $packet.captured_at_utc
            status = "matched"
            result = "passed"
            refusal_reason = ""
        })

    $packet | Add-Member -NotePropertyName "completion_claim" -NotePropertyValue ([pscustomobject]@{
            claim_type = "milestone_completion_candidate"
            claimed_commands = @(
                "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_clean_checkout_qa.ps1",
                "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_qa_proof_packet.ps1 -PacketPath state\fixtures\valid\qa_proof\qa_proof_packet.valid.json",
                "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1",
                "powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify_remote_branch_head.ps1",
                "powershell -NoProfile -ExecutionPolicy Bypass -File tools\verify_post_push_remote_head.ps1",
                "git status --porcelain",
                "git diff --check"
            )
            supplemental_command_results = @($supplementalCommandResults | ForEach-Object { [pscustomobject]$_ })
            remote_head_verification_ref = "artifacts/remote_head_verification.valid.json"
            post_push_verification_ref = "artifacts/post_push_verification.valid.json"
            notes = "Completion-claim fixture for R8-006 command-log coverage hardening tests."
        }) -Force

    Write-JsonDocument -Path $packetPath -Document $packet
    return $packetPath
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

$validFixture = Join-Path $repoRoot "state\fixtures\valid\qa_proof\qa_proof_packet.valid.json"

try {
    $validResult = & $testQaProofPacket -PacketPath $validFixture
    Write-Output ("PASS valid: {0} -> {1} {2}" -f (Resolve-Path -Relative $validFixture), $validResult.PacketId, $validResult.Verdict)
    $validPassed += 1

    $completionClaimRoot = New-FixtureRoot -Label "completion-claim-valid"
    try {
        $completionClaimPacketPath = New-CompletionClaimFixture -FixtureRoot $completionClaimRoot
        $completionClaimResult = & $testQaProofPacket -PacketPath $completionClaimPacketPath
        Write-Output ("PASS valid completion-claim: {0} -> {1}" -f $completionClaimResult.PacketId, $completionClaimResult.Verdict)
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $completionClaimRoot) {
            Remove-Item -LiteralPath $completionClaimRoot -Recurse -Force
        }
    }

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

    $missingStdoutRefRoot = New-FixtureRoot -Label "missing-stdout-log-ref"
    try {
        $missingStdoutRefPacketPath = New-CompletionClaimFixture -FixtureRoot $missingStdoutRefRoot
        $missingStdoutRefPacket = Get-JsonDocument -Path $missingStdoutRefPacketPath
        $missingStdoutRefPacket.completion_claim.supplemental_command_results[0].PSObject.Properties.Remove("stdout_log_ref")
        Write-JsonDocument -Path $missingStdoutRefPacketPath -Document $missingStdoutRefPacket
        Invoke-ExpectedRefusal -Label "missing-stdout-log-ref" -RequiredFragments @("stdout_log_ref", "missing required field") -Action {
            & $testQaProofPacket -PacketPath $missingStdoutRefPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingStdoutRefRoot) {
            Remove-Item -LiteralPath $missingStdoutRefRoot -Recurse -Force
        }
    }

    $missingStderrRefRoot = New-FixtureRoot -Label "missing-stderr-log-ref"
    try {
        $missingStderrRefPacketPath = New-CompletionClaimFixture -FixtureRoot $missingStderrRefRoot
        $missingStderrRefPacket = Get-JsonDocument -Path $missingStderrRefPacketPath
        $missingStderrRefPacket.completion_claim.supplemental_command_results[0].PSObject.Properties.Remove("stderr_log_ref")
        Write-JsonDocument -Path $missingStderrRefPacketPath -Document $missingStderrRefPacket
        Invoke-ExpectedRefusal -Label "missing-stderr-log-ref" -RequiredFragments @("stderr_log_ref", "missing required field") -Action {
            & $testQaProofPacket -PacketPath $missingStderrRefPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingStderrRefRoot) {
            Remove-Item -LiteralPath $missingStderrRefRoot -Recurse -Force
        }
    }

    $missingExitCodeRoot = New-FixtureRoot -Label "missing-exit-code"
    try {
        $missingExitCodePacketPath = New-CompletionClaimFixture -FixtureRoot $missingExitCodeRoot
        $missingExitCodePacket = Get-JsonDocument -Path $missingExitCodePacketPath
        $missingExitCodePacket.completion_claim.supplemental_command_results[0].PSObject.Properties.Remove("exit_code")
        Write-JsonDocument -Path $missingExitCodePacketPath -Document $missingExitCodePacket
        Invoke-ExpectedRefusal -Label "missing-exit-code" -RequiredFragments @("exit_code", "missing required field") -Action {
            & $testQaProofPacket -PacketPath $missingExitCodePacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingExitCodeRoot) {
            Remove-Item -LiteralPath $missingExitCodeRoot -Recurse -Force
        }
    }

    $claimedCommandGapRoot = New-FixtureRoot -Label "claimed-command-gap"
    try {
        $claimedCommandGapPacketPath = New-CompletionClaimFixture -FixtureRoot $claimedCommandGapRoot
        $claimedCommandGapPacket = Get-JsonDocument -Path $claimedCommandGapPacketPath
        $claimedCommandGapPacket.completion_claim.supplemental_command_results = @($claimedCommandGapPacket.completion_claim.supplemental_command_results | Where-Object { $_.command -ne "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_qa_proof_packet.ps1 -PacketPath state\fixtures\valid\qa_proof\qa_proof_packet.valid.json" })
        Write-JsonDocument -Path $claimedCommandGapPacketPath -Document $claimedCommandGapPacket
        Invoke-ExpectedRefusal -Label "claimed-command-gap" -RequiredFragments @("tools\validate_qa_proof_packet.ps1", "has no command_result or supplemental_command_result coverage") -Action {
            & $testQaProofPacket -PacketPath $claimedCommandGapPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $claimedCommandGapRoot) {
            Remove-Item -LiteralPath $claimedCommandGapRoot -Recurse -Force
        }
    }

    $missingGitHygieneRoot = New-FixtureRoot -Label "missing-git-hygiene"
    try {
        $missingGitHygienePacketPath = New-CompletionClaimFixture -FixtureRoot $missingGitHygieneRoot
        $missingGitHygienePacket = Get-JsonDocument -Path $missingGitHygienePacketPath
        $missingGitHygienePacket.completion_claim.claimed_commands = @($missingGitHygienePacket.completion_claim.claimed_commands | Where-Object { $_ -ne "git status --porcelain" })
        Write-JsonDocument -Path $missingGitHygienePacketPath -Document $missingGitHygienePacket
        Invoke-ExpectedRefusal -Label "missing-git-hygiene-command-evidence" -RequiredFragments @("completion_claim.claimed_commands", "git status --porcelain") -Action {
            & $testQaProofPacket -PacketPath $missingGitHygienePacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingGitHygieneRoot) {
            Remove-Item -LiteralPath $missingGitHygieneRoot -Recurse -Force
        }
    }

    $missingRemoteVerificationRoot = New-FixtureRoot -Label "missing-remote-verification"
    try {
        $missingRemoteVerificationPacketPath = New-CompletionClaimFixture -FixtureRoot $missingRemoteVerificationRoot
        $missingRemoteVerificationPacket = Get-JsonDocument -Path $missingRemoteVerificationPacketPath
        $missingRemoteVerificationPacket.completion_claim.PSObject.Properties.Remove("remote_head_verification_ref")
        Write-JsonDocument -Path $missingRemoteVerificationPacketPath -Document $missingRemoteVerificationPacket
        Invoke-ExpectedRefusal -Label "missing-remote-verification-evidence" -RequiredFragments @("remote_head_verification_ref", "missing required field") -Action {
            & $testQaProofPacket -PacketPath $missingRemoteVerificationPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingRemoteVerificationRoot) {
            Remove-Item -LiteralPath $missingRemoteVerificationRoot -Recurse -Force
        }
    }

    $missingPostPushVerificationRoot = New-FixtureRoot -Label "missing-post-push-verification"
    try {
        $missingPostPushVerificationPacketPath = New-CompletionClaimFixture -FixtureRoot $missingPostPushVerificationRoot
        $missingPostPushVerificationPacket = Get-JsonDocument -Path $missingPostPushVerificationPacketPath
        $missingPostPushVerificationPacket.completion_claim.PSObject.Properties.Remove("post_push_verification_ref")
        Write-JsonDocument -Path $missingPostPushVerificationPacketPath -Document $missingPostPushVerificationPacket
        Invoke-ExpectedRefusal -Label "missing-post-push-verification-evidence" -RequiredFragments @("post_push_verification_ref", "missing required field") -Action {
            & $testQaProofPacket -PacketPath $missingPostPushVerificationPacketPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $missingPostPushVerificationRoot) {
            Remove-Item -LiteralPath $missingPostPushVerificationRoot -Recurse -Force
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
