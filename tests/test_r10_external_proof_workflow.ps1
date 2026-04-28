$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot ".github\workflows\r10-external-proof-bundle.yml"
$runnerPath = Join-Path $repoRoot "tools\invoke_r10_external_proof_bundle.ps1"

function Assert-TextContains {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NoPositiveClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    foreach ($line in ($Text -split "\r?\n")) {
        if ($line -match $Pattern -and $line -notmatch '(?i)\b(no|not|without|must not|does not|cannot|until)\b') {
            throw $Message
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()

try {
    if (-not (Test-Path -LiteralPath $workflowPath)) {
        throw "R10 external proof workflow does not exist."
    }
    if (-not (Test-Path -LiteralPath $runnerPath)) {
        throw "R10 external proof runner script does not exist."
    }

    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    $runnerText = Get-Content -LiteralPath $runnerPath -Raw
    $combinedText = $workflowText + "`n" + $runnerText

    Assert-TextContains -Text $workflowText -Pattern '(?m)^\s*workflow_dispatch:\s*$' -Message "Workflow must support workflow_dispatch."
    Assert-TextContains -Text $workflowText -Pattern 'actions/checkout@v4' -Message "Workflow must check out the requested ref."
    Assert-TextContains -Text $workflowText -Pattern 'ref:\s*\$\{\{\s*steps\.resolve\.outputs\.requested_ref\s*\}\}' -Message "Workflow checkout must use the resolved requested ref."
    Assert-TextContains -Text $workflowText -Pattern 'actions/upload-artifact@v4' -Message "Workflow must upload an artifact."
    Assert-TextContains -Text $workflowText -Pattern 'r10-external-proof-bundle-\$\{\{\s*github\.run_id\s*\}\}-\$\{\{\s*github\.run_attempt\s*\}\}' -Message "Workflow artifact name must follow the R10 convention."
    Assert-TextContains -Text $workflowText -Pattern 'tools\\invoke_r10_external_proof_bundle\.ps1' -Message "Workflow must invoke the R10 external proof bundle runner."
    Assert-TextContains -Text $workflowText -Pattern '(?m)^\s*path:\s*\$\{\{\s*env\.R10_OUTPUT_ROOT\s*\}\}' -Message "Workflow must upload the runner output root."

    Assert-TextContains -Text $runnerText -Pattern 'external_proof_artifact_bundle\.json' -Message "Runner must emit external_proof_artifact_bundle.json."
    Assert-TextContains -Text $runnerText -Pattern 'RedirectStandardOutput' -Message "Runner must capture stdout."
    Assert-TextContains -Text $runnerText -Pattern 'RedirectStandardError' -Message "Runner must capture stderr."
    Assert-TextContains -Text $runnerText -Pattern 'exit_code\.txt' -Message "Runner must record exit-code files."
    Assert-TextContains -Text $runnerText -Pattern 'remote_head_query\.txt' -Message "Runner must record remote head query output."
    Assert-TextContains -Text $runnerText -Pattern 'tested_head\.txt' -Message "Runner must record tested head output."
    Assert-TextContains -Text $runnerText -Pattern 'tested_tree\.txt' -Message "Runner must record tested tree output."
    Assert-TextContains -Text $runnerText -Pattern 'clean_status_before\.json' -Message "Runner must record clean status before commands."
    Assert-TextContains -Text $runnerText -Pattern 'clean_status_after\.json' -Message "Runner must record clean status after commands."
    Assert-TextContains -Text $runnerText -Pattern 'command_manifest\.json' -Message "Runner must emit a command manifest."
    Assert-TextContains -Text $runnerText -Pattern 'artifact_retrieval_README\.txt' -Message "Runner must emit artifact retrieval instructions."
    Assert-TextContains -Text $runnerText -Pattern 'validate_external_proof_artifact_bundle\.ps1' -Message "Runner must validate the generated bundle with the R10-003 validator."

    foreach ($requiredCommand in @(
            'tests\\test_external_proof_artifact_bundle\.ps1',
            'tests\\test_external_runner_closeout_identity\.ps1',
            'tests\\test_status_doc_gate\.ps1',
            'tools\\validate_status_doc_gate\.ps1',
            'git diff --check'
        )) {
        Assert-TextContains -Text $runnerText -Pattern $requiredCommand -Message "Runner must include focused proof command '$requiredCommand'."
    }

    foreach ($requiredNonClaim in @(
            'no broad CI/product coverage claim',
            'no UI or control-room productization',
            'no Standard runtime',
            'no multi-repo orchestration',
            'no swarms',
            'no broad autonomous milestone execution',
            'no unattended automatic resume',
            'no solved Codex context compaction',
            'no hours-long unattended milestone execution',
            'no destructive rollback',
            'no general Codex reliability'
        )) {
        Assert-TextContains -Text $runnerText -Pattern ([regex]::Escape($requiredNonClaim)) -Message "Runner must preserve non-claim '$requiredNonClaim'."
    }

    Assert-NoPositiveClaim -Text $combinedText -Pattern '(?i)broad.{0,80}CI.{0,80}(coverage|proof|complete|available|claim)' -Message "Workflow/script must not claim broad CI/product coverage."
    Assert-NoPositiveClaim -Text $combinedText -Pattern '(?i)external QA proof.{0,80}(exists|complete|available|claimed|proves)' -Message "Workflow/script must not claim external QA proof."
    Assert-NoPositiveClaim -Text $combinedText -Pattern '(?i)R10.{0,80}(closed|closeout complete|formally closed)' -Message "Workflow/script must not close R10."

    if ($workflowText -match '(?m)^\s*push:\s*$') {
        throw "Workflow must not run on push for R10-004; R10-005 captures real run identity later."
    }

    Write-Output "PASS valid R10 external proof workflow shape."
    $validPassed += 1
}
catch {
    $failures += ("FAIL R10 external proof workflow shape: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R10 external proof workflow tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R10 external proof workflow tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
