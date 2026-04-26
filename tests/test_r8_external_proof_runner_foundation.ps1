$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot ".github\workflows\r8-clean-checkout-qa.yml"
$activeStatePath = Join-Path $repoRoot "governance\ACTIVE_STATE.md"
$kanbanPath = Join-Path $repoRoot "execution\KANBAN.md"
$r8AuthorityPath = Join-Path $repoRoot "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md"
$readmePath = Join-Path $repoRoot "README.md"
$failures = @()

try {
    if (-not (Test-Path -LiteralPath $workflowPath)) {
        throw "Workflow file '.github/workflows/r8-clean-checkout-qa.yml' does not exist."
    }

    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    Write-Output ("PASS workflow file exists: {0}" -f $workflowPath)

    if ($workflowText -notmatch "(?m)^on:\s*$") {
        $failures += "FAIL workflow is missing the top-level 'on' trigger block."
    }
    if ($workflowText -notmatch "(?m)^\s{2}workflow_dispatch:\s*$") {
        $failures += "FAIL workflow is missing manual dispatch support."
    }
    if ($workflowText -notmatch "(?m)^\s{6}branch:\s*$") {
        $failures += "FAIL workflow is missing the branch input."
    }
    if ($workflowText -notmatch "(?m)^\s{6}remote_sha:\s*$") {
        $failures += "FAIL workflow is missing the remote_sha input."
    }
    if ($workflowText -notmatch "(?m)^\s{6}qa_commands:\s*$") {
        $failures += "FAIL workflow is missing the qa_commands input."
    }
    if ($workflowText -notmatch "actions/checkout@v4") {
        $failures += "FAIL workflow does not check out the requested branch."
    }
    if ($workflowText -notmatch "tools[\\/]+invoke_clean_checkout_qa\.ps1") {
        $failures += "FAIL workflow does not invoke the clean-checkout QA runner."
    }
    if ($workflowText -notmatch "actions/upload-artifact@v4") {
        $failures += "FAIL workflow does not upload QA proof outputs as artifacts."
    }
    if ($workflowText -notmatch "run_identity\.json") {
        $failures += "FAIL workflow does not persist workflow run identity metadata."
    }
    if ($workflowText -notmatch "No external proof claim exists until a concrete workflow run artifact is recorded and cited") {
        $failures += "FAIL workflow does not preserve the non-claim that foundation is not the same as a proved external run."
    }

    Write-Output "PASS workflow foundation assertions."
}
catch {
    $failures += ("FAIL workflow foundation inspection: {0}" -f $_.Exception.Message)
}

try {
    $activeStateText = Get-Content -LiteralPath $activeStatePath -Raw
    $kanbanText = Get-Content -LiteralPath $kanbanPath -Raw
    $r8AuthorityText = Get-Content -LiteralPath $r8AuthorityPath -Raw
    $readmeText = Get-Content -LiteralPath $readmePath -Raw

    if ($activeStateText -notmatch 'R8-001` through `R8-008` complete and `R8-009` planned') {
        $failures += "FAIL ACTIVE_STATE does not mark only R8-008 complete with R8-009 still planned."
    }
    if ($kanbanText -notmatch '### `R8-007` Add CI or equivalent external proof runner[\s\S]*?- Status: done') {
        $failures += "FAIL KANBAN does not mark R8-007 done."
    }
    if ($kanbanText -notmatch '### `R8-008` Add status-doc gating[\s\S]*?- Status: done') {
        $failures += "FAIL KANBAN does not mark R8-008 done."
    }
    if ($kanbanText -notmatch '### `R8-009` Pilot and close R8 narrowly[\s\S]*?- Status: planned') {
        $failures += "FAIL KANBAN does not keep R8-009 planned."
    }
    if ($r8AuthorityText -notmatch '`R8-001` through `R8-008` are complete in repo truth\.\s+`R8-009` is planned only\.') {
        $failures += "FAIL R8 authority document does not preserve the R8-008 done / R8-009 planned boundary."
    }
    if ($r8AuthorityText -notmatch '`R8-007` adds the external proof runner foundation only\. It does not yet claim that a concrete CI or external proof run artifact exists') {
        $failures += "FAIL R8 authority document does not preserve the no-external-proof-yet non-claim for R8-007."
    }
    if ($readmeText -notmatch '`R8-007` is complete') {
        $failures += "FAIL README does not reflect R8-007 completion."
    }
    if ($readmeText -notmatch '`R8-008` is complete' -or $readmeText -notmatch '`R8-009` is planned only') {
        $failures += "FAIL README does not keep the R8-008 done / R8-009 planned boundary."
    }

    Write-Output "PASS R8 status-surface assertions."
}
catch {
    $failures += ("FAIL R8 status-surface inspection: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R8 external proof runner foundation tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All R8 external proof runner foundation tests passed."
