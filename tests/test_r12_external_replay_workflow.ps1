$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot ".github\workflows\r12-external-replay.yml"
$failures = @()

if (-not (Test-Path -LiteralPath $workflowPath)) {
    throw "R12 external replay workflow file is missing."
}

$workflow = Get-Content -LiteralPath $workflowPath -Raw

foreach ($requiredPattern in @(
        'workflow_dispatch:',
        'branch:',
        'expected_head:',
        'expected_tree:',
        'replay_scope:',
        'actions/checkout@v4',
        'ref:\s+\$\{\{\s*inputs\.expected_head\s*\}\}',
        'tests/test_value_scorecard\.ps1',
        'tests/test_operating_loop\.ps1',
        'tests/test_remote_head_phase_detector\.ps1',
        'tests/test_fresh_thread_bootstrap\.ps1',
        'tests/test_transition_residue_preflight\.ps1',
        'tests/test_external_runner_contracts\.ps1',
        'tests/test_external_runner_github_actions\.ps1',
        'tests/test_r12_external_replay_bundle\.ps1',
        'tools/new_r12_external_replay_bundle\.ps1',
        'tools/validate_r12_external_replay_bundle\.ps1',
        'actions/upload-artifact@v4'
    )) {
    if ($workflow -notmatch $requiredPattern) {
        $failures += "Workflow is missing required pattern '$requiredPattern'."
    }
}

if ($workflow -match 'R12 closeout|final-state replay completed|R13') {
    $failures += "Workflow text must not claim R12 closeout, completed final-state replay, or R13."
}

$writesCleanBeforeUnderCommandLogs = $workflow -match '\$cleanBeforeRef\s*=\s*Join-Path\s+\$commandRoot\s+"clean_status_before\.log"'
$writesCleanAfterUnderCommandLogs = $workflow -match '\$cleanAfterRef\s*=\s*Join-Path\s+\$commandRoot\s+"clean_status_after\.log"'

if (-not $writesCleanBeforeUnderCommandLogs) {
    $failures += "Workflow must write clean_status_before.log under command_logs."
}
if (-not $writesCleanAfterUnderCommandLogs) {
    $failures += "Workflow must write clean_status_after.log under command_logs."
}

if ($writesCleanBeforeUnderCommandLogs -and $workflow -match '-CleanStatusBefore\s+"clean_status_before\.log"') {
    $failures += "Workflow writes clean_status_before.log under command_logs but passes clean_status_before.log without the command_logs/ prefix."
}
if ($writesCleanAfterUnderCommandLogs -and $workflow -match '-CleanStatusAfter\s+"clean_status_after\.log"') {
    $failures += "Workflow writes clean_status_after.log under command_logs but passes clean_status_after.log without the command_logs/ prefix."
}
if ($workflow -notmatch '-CleanStatusBefore\s+"command_logs/clean_status_before\.log"') {
    $failures += "Workflow must pass command_logs/clean_status_before.log into the replay bundle."
}
if ($workflow -notmatch '-CleanStatusAfter\s+"command_logs/clean_status_after\.log"') {
    $failures += "Workflow must pass command_logs/clean_status_after.log into the replay bundle."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R12 external replay workflow structure tests failed with {0} failure(s)." -f $failures.Count)
}

Write-Output "All R12 external replay workflow structure tests passed."
