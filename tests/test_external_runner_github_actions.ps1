$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExternalRunnerGitHubActions.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-ExternalRunnerGitHubActionsPacket"]
$resolveRunSelection = $module.ExportedCommands["Resolve-ExternalRunnerGitHubActionsRunSelection"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\external_runner_github_actions"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\external_runner_github_actions"
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
    $dependency = & $testPacket -PacketPath (Join-Path $validRoot "dependency_check.valid.json")
    if ($dependency.Verdict -ne "passed" -or -not $dependency.GhAvailable -or -not $dependency.AuthAvailable) {
        $failures += "FAIL valid: dependency check fixture did not validate as passed."
    }
    else {
        Write-Output "PASS valid dependency check fixture"
        $validPassed += 1
    }

    $dispatch = & $testPacket -PacketPath (Join-Path $validRoot "dispatch_result.valid.json")
    if (-not $dispatch.ApiControlled -or $dispatch.DispatchMode -ne "api_dispatch" -or $dispatch.CandidateRunCount -ne 1) {
        $failures += "FAIL valid: dispatch fixture did not validate as one API-controlled run."
    }
    else {
        Write-Output ("PASS valid mocked dispatch fixture: {0}" -f $dispatch.RunId)
        $validPassed += 1
    }

    $capture = & $testPacket -PacketPath (Join-Path $validRoot "capture_result.valid.json")
    if (-not $capture.SuccessfulExternalEvidenceShape -or $capture.CaptureStatus -ne "captured") {
        $failures += "FAIL valid: capture fixture did not emit a contract-valid successful result packet shape."
    }
    else {
        Write-Output ("PASS valid mocked capture fixture: {0}" -f $capture.ResultId)
        $validPassed += 1
    }

    $manual = & $testPacket -PacketPath (Join-Path $validRoot "manual_dispatch_instructions.valid.json")
    if ($manual.ApiControlled -or $manual.DispatchMode -ne "manual_dispatch" -or -not $manual.Manual) {
        $failures += "FAIL valid: manual dispatch fixture was mislabeled."
    }
    else {
        Write-Output "PASS valid manual dispatch fixture is manual, not API-controlled"
        $validPassed += 1
    }

    $candidateRuns = @(
        [pscustomobject]@{
            run_id = "26000000001"
            run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/26000000001"
            head_branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
            head_sha = "03d82720ed15411847f958c7d6e32e5c3d7355c9"
            workflow_name = "R12 External Replay"
        }
    )
    $selected = & $resolveRunSelection -CandidateRuns $candidateRuns -Branch "release/r12-external-api-runner-actionable-qa-control-room-pilot" -Head "03d82720ed15411847f958c7d6e32e5c3d7355c9" -WorkflowName "R12 External Replay"
    if ($selected.run_id -ne "26000000001") {
        $failures += "FAIL valid: unique run selection did not return the expected run id."
    }
    else {
        Write-Output "PASS valid unique run selection"
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-gh" -RequiredFragments @("missing gh", "gh CLI") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "dependency_check.missing-gh.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-auth" -RequiredFragments @("missing auth", "auth") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "dependency_check.missing-auth.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-ambiguous-run-selection-packet" -RequiredFragments @("ambiguous run selection") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "dispatch_result.ambiguous.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-manual-mislabeled-api-controlled" -RequiredFragments @("manual dispatch path", "API-controlled") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "manual_dispatch_instructions.api-controlled.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-ambiguous-selection-function" -RequiredFragments @("ambiguous", "multiple candidate runs") -Action {
        & $resolveRunSelection -CandidateRuns @(
            [pscustomobject]@{
                run_id = "26000000001"
                run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/26000000001"
                head_branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
                head_sha = "03d82720ed15411847f958c7d6e32e5c3d7355c9"
                workflow_name = "R12 External Replay"
            },
            [pscustomobject]@{
                run_id = "26000000002"
                run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/26000000002"
                head_branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
                head_sha = "03d82720ed15411847f958c7d6e32e5c3d7355c9"
                workflow_name = "R12 External Replay"
            }
        ) -Branch "release/r12-external-api-runner-actionable-qa-control-room-pilot" -Head "03d82720ed15411847f958c7d6e32e5c3d7355c9" -WorkflowName "R12 External Replay" | Out-Null
    }
}
catch {
    $failures += ("FAIL external runner GitHub Actions harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External runner GitHub Actions tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external runner GitHub Actions tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
