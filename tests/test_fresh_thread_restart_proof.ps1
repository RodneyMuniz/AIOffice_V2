$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\FreshThreadRestartProof.psm1") -Force -PassThru
$testProof = $module.ExportedCommands["Test-FreshThreadRestartProofContract"]
$testProofObject = $module.ExportedCommands["Test-FreshThreadRestartProofObject"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\bootstrap\fresh_thread_restart_proof.valid.json"
$actualProof = Join-Path $repoRoot "state\cycles\r12_real_build_cycle\bootstrap\fresh_thread_restart_proof.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\bootstrap"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonFixture {
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

    return ($Object | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
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

function New-InvalidCandidate {
    param(
        [Parameter(Mandatory = $true)]
        $BaseProof,
        [Parameter(Mandatory = $true)]
        [string]$CaseId
    )

    $candidate = Copy-JsonObject -Object $BaseProof

    switch ($CaseId) {
        "missing_bootstrap_packet" {
            $candidate.bootstrap_packet_ref = "state/cycles/r12_real_build_cycle/bootstrap/missing_fresh_thread_bootstrap_packet.json"
        }
        "missing_handoff_prompt" {
            $candidate.handoff_prompt_ref = "state/cycles/r12_real_build_cycle/bootstrap/missing_codex_next_prompt_for_r12_018.md"
        }
        "stale_pre_r12_017_head_used_as_current" {
            $candidate.resolved_remote_head = "d93a66aa6b757241583fa1c61bb6333b4228d639"
            $candidate.local_head = "d93a66aa6b757241583fa1c61bb6333b4228d639"
        }
        "local_head_mismatch" {
            $candidate.local_head = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        }
        "dirty_worktree" {
            $candidate.verification_results.initial_status_short = " M README.md"
        }
        "missing_control_room_refresh_result" {
            $candidate.control_room_refresh_result_ref = "state/control_room/r12_current/missing_control_room_refresh_result.json"
        }
        "r12_019_or_later_claimed" {
            $candidate.recovered_next_actions = @($candidate.recovered_next_actions) + [pscustomobject][ordered]@{
                scope = "forbidden"
                task_id = "R12-019"
                status = "completed"
                action = "R12-019 completed in the fresh-thread proof."
            }
        }
        "r12_closeout_claimed" {
            $candidate.recovered_active_scope | Add-Member -NotePropertyName "forbidden_closeout_claim" -NotePropertyValue "R12 closeout completed by this proof."
        }
        "missing_restart_non_claims" {
            $candidate.non_claims = @()
        }
        default {
            throw "Unknown invalid fresh-thread restart proof case '$CaseId'."
        }
    }

    return $candidate
}

try {
    $validResult = & $testProof -ProofPath $validFixture
    Write-Output ("PASS valid fresh-thread restart proof fixture: {0} verdict {1}" -f $validResult.ProofId, $validResult.ProofVerdict)
    $validPassed += 1

    $actualResult = & $testProof -ProofPath $actualProof
    Write-Output ("PASS actual R12-018 fresh-thread restart proof: {0} at {1}" -f $actualResult.ProofVerdict, $actualResult.ResolvedRemoteHead)
    $validPassed += 1

    $baseProof = Read-JsonFixture -Path $validFixture
    foreach ($fixturePath in @(Get-ChildItem -LiteralPath $invalidRoot -Filter "*.invalid.json" | Where-Object { $_.Name -match 'restart|bootstrap_packet|handoff_prompt|stale_pre_r12_017|local_head|dirty_worktree|control_room_refresh|r12_019|r12_closeout' } | Sort-Object Name)) {
        $fixture = Read-JsonFixture -Path $fixturePath.FullName
        Invoke-ExpectedRefusal -Label $fixture.case_id -RequiredFragments @($fixture.expected_error_fragments) -Action {
            $candidate = New-InvalidCandidate -BaseProof $baseProof -CaseId $fixture.case_id
            & $testProofObject -Proof $candidate -SourceLabel $fixture.case_id | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL fresh-thread restart proof harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Fresh-thread restart proof tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All fresh-thread restart proof tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
