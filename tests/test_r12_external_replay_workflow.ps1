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

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R12 external replay workflow structure tests failed with {0} failure(s)." -f $failures.Count)
}

Write-Output "All R12 external replay workflow structure tests passed."
