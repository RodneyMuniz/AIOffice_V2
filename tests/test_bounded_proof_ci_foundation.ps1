$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot ".github\workflows\bounded-proof-suite.yml"
$failures = @()

try {
    if (-not (Test-Path -LiteralPath $workflowPath)) {
        throw "Workflow file '.github/workflows/bounded-proof-suite.yml' does not exist."
    }

    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    Write-Output ("PASS workflow file exists: {0}" -f $workflowPath)

    if ($workflowText -notmatch "(?m)^on:\s*$") {
        $failures += "FAIL workflow is missing the top-level 'on' trigger block."
    }
    if ($workflowText -notmatch "(?m)^\s{2}push:\s*$") {
        $failures += "FAIL workflow is missing the push trigger."
    }
    if ($workflowText -notmatch "(?m)^\s{2}pull_request:\s*$") {
        $failures += "FAIL workflow is missing the pull_request trigger."
    }
    if ($workflowText -notmatch "(?m)^\s{6}- main\s*$") {
        $failures += "FAIL workflow is not scoped to the main development branch."
    }
    if ($workflowText -notmatch "runs-on:\s*windows-latest") {
        $failures += "FAIL workflow is not pinned to windows-latest for the bounded proof environment."
    }
    if ($workflowText -notmatch "tools[\\/]+run_bounded_proof_suite\.ps1") {
        $failures += "FAIL workflow does not invoke the bounded proof runner script."
    }

    Write-Output "PASS workflow trigger and runner assertions."
}
catch {
    $failures += ("FAIL CI foundation workflow inspection: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Bounded proof CI foundation tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All bounded proof CI foundation tests passed."
