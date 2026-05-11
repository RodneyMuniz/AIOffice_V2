$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repoRoot "tools\validate_r17_operator_closeout_decision.ps1"
$failures = @()
$validPassed = 0
$invalidRejected = 0

function Invoke-Validator {
    param([string]$Root)
    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $validator -RepositoryRoot $Root 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw ($output -join [Environment]::NewLine)
    }
}

function Copy-Harness {
    param([string]$Root)
    $paths = @(
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/DECISION_LOG.md",
        "governance/reports/AIOffice_V2_R17_External_Audit_and_R18_Planning_Report_v1.md",
        "governance/plans/AIOffice_V2_Revised_R17_Plan.md",
        "contracts/governance/r17_operator_closeout_decision.contract.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/evidence_index.json",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/proof_review.md",
        "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/validation_manifest.md"
    )
    foreach ($relative in $paths) {
        $source = Join-Path $repoRoot $relative
        $target = Join-Path $Root $relative
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $target -Force
    }
}

function Invoke-ExpectedRefusal {
    param(
        [string]$Label,
        [string]$Expected,
        [scriptblock]$Mutation
    )
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("r17closeout" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    try {
        Copy-Harness -Root $temp
        & $Mutation $temp
        try {
            Invoke-Validator -Root $temp
            $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
        }
        catch {
            if ($_.Exception.Message -notlike "*$Expected*") {
                $script:failures += "FAIL invalid: $Label rejected with unexpected message: $($_.Exception.Message)"
            }
            else {
                Write-Output "PASS invalid: $Label"
                $script:invalidRejected += 1
            }
        }
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force
        }
    }
}

try {
    Invoke-Validator -Root $repoRoot
    Write-Output "PASS valid: live R17 operator closeout decision validates."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live closeout decision: $($_.Exception.Message)"
}

Invoke-ExpectedRefusal -Label "missing-operator-approval" -Expected "operator approval" -Mutation {
    param($root)
    $path = Join-Path $root "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json"
    $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $json.operator_approval_recorded = $false
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
}

foreach ($field in @(
        "product_runtime_claimed",
        "four_exercised_a2a_cycles_claimed",
        "live_a2a_runtime_claimed",
        "live_recovery_runtime_claimed",
        "automatic_new_thread_creation_claimed",
        "openai_api_invoked",
        "codex_api_invoked",
        "autonomous_codex_invocation_claimed",
        "no_manual_prompt_transfer_success_claimed",
        "solved_codex_compaction_claimed",
        "solved_codex_reliability_claimed",
        "main_merge_claimed"
    )) {
    Invoke-ExpectedRefusal -Label "false-flag-$field" -Expected "" -Mutation {
        param($root)
        $path = Join-Path $root "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json"
        $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $json.$field = $true
        $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
    }
}

Invoke-ExpectedRefusal -Label "status-doc-missing-r18-boundary" -Expected "R18 active through R18-001 only" -Mutation {
    param($root)
    foreach ($relative in @(
            "README.md",
            "execution/KANBAN.md",
            "governance/ACTIVE_STATE.md",
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
            "governance/DECISION_LOG.md"
        )) {
        $path = Join-Path $root $relative
        $text = Get-Content -LiteralPath $path -Raw
        $text = $text.Replace("R18 active through R18-001 only", "R18 active through R18-002")
        Set-Content -LiteralPath $path -Value $text -Encoding UTF8
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R17 operator closeout tests failed."
}

Write-Output ("All R17 operator closeout decision tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
