$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\FreshThreadBootstrap.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-FreshThreadBootstrapPacketContract"]
$newPacket = $module.ExportedCommands["New-FreshThreadBootstrapPacket"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\bootstrap\fresh_thread_bootstrap.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\bootstrap"

$validPassed = 0
$invalidRejected = 0
$failures = @()

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

try {
    $validResult = & $testPacket -PacketPath $validFixture
    Write-Output ("PASS valid fresh-thread bootstrap fixture: {0} with {1} evidence ref(s)" -f $validResult.CurrentTask, $validResult.EvidenceRefCount)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-missing-branch-head-tree" -RequiredFragments @("missing required field", "active_branch") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "missing_branch_head_tree.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-chat-memory-authority" -RequiredFragments @("chat transcript", "authority") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "chat_memory_authority.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-fail-closed-rules" -RequiredFragments @("fail_closed_rules", "must not be empty") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "missing_fail_closed_rules.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("explicit_non_claims", "must not be empty") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "missing_non_claims.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-value-gate-claim-without-proof" -RequiredFragments @("value gates delivered", "proof refs") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "value_gate_claim_without_proof.invalid.json") | Out-Null
    }

    $generated = & $newPacket `
        -ActiveBranch "release/r12-external-api-runner-actionable-qa-control-room-pilot" `
        -LocalHead "65dab1a85db35a1c5fd853a08c564df9a2ac2e68" `
        -LocalTree "8b0dc744250af62d83b627ec34d78a92dfbc5aee" `
        -RemoteHead "65dab1a85db35a1c5fd853a08c564df9a2ac2e68" `
        -CurrentTask "R12-005 generated prompt smoke test" `
        -RemoteHeadPhaseDetectionRef "state/fixtures/valid/remote_head_phase/phase_match.valid.json"

    foreach ($fragment in @(
            "Do not rely on prior chat context",
            "release/r12-external-api-runner-actionable-qa-control-room-pilot",
            "65dab1a85db35a1c5fd853a08c564df9a2ac2e68",
            "8b0dc744250af62d83b627ec34d78a92dfbc5aee",
            "R12-005 generated prompt smoke test",
            "Fail-closed rules",
            "Relevant evidence refs",
            "Non-claims"
        )) {
        if ($generated.next_prompt_body -notmatch [regex]::Escape($fragment)) {
            $failures += ("FAIL generated prompt: missing fragment '{0}'." -f $fragment)
        }
    }

    if ($generated.next_prompt_body.Length -gt 2500) {
        $failures += "FAIL generated prompt: prompt is not compact."
    }
    else {
        Write-Output ("PASS generated next prompt: {0} chars" -f $generated.next_prompt_body.Length)
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL fresh-thread bootstrap harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Fresh-thread bootstrap tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All fresh-thread bootstrap tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
