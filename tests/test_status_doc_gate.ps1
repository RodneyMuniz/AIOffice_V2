$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $module.ExportedCommands["Test-StatusDocGate"]
$failures = @()
$validPassed = 0
$invalidRejected = 0

function Copy-Harness {
    param([string]$Root)
    $paths = @(
        "README.md",
        "execution/KANBAN.md",
        "governance/ACTIVE_STATE.md",
        "governance/DECISION_LOG.md",
        "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/governance/r18_opening_authority.json"
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
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("r18status" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    try {
        Copy-Harness -Root $temp
        & $Mutation $temp
        try {
            & $testStatusDocGate -RepositoryRoot $temp | Out-Null
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
    $liveValidation = & $testStatusDocGate -RepositoryRoot $repoRoot
    if ($liveValidation.ActiveMilestone -ne "R18 Automated Recovery Runtime and API Orchestration" -or -not $liveValidation.R18Opened -or $liveValidation.R18DoneThrough -ne 8 -or $liveValidation.R18PlannedStart -ne 9 -or $liveValidation.R18PlannedThrough -ne 28 -or -not $liveValidation.R17Closed -or $liveValidation.R17DoneThrough -ne 28) {
        $failures += "FAIL valid: live status-doc gate did not report R17 closed and R18 active through R18-008 only."
    }
    else {
        Write-Output "PASS valid: live status-doc gate reports R17 closed with caveats and R18 active through R18-008 only."
        $validPassed += 1
    }
}
catch {
    $failures += "FAIL valid live status-doc gate: $($_.Exception.Message)"
}

Invoke-ExpectedRefusal -Label "r18-009-done-in-kanban" -Expected "does not match KANBAN" -Mutation {
    param($root)
    $path = Join-Path $root "execution/KANBAN.md"
    $text = Get-Content -LiteralPath $path -Raw
    $text = [regex]::Replace($text, '(### `R18-009`[\s\S]*?\r?\n- Status: )planned', '${1}done', 1)
    Set-Content -LiteralPath $path -Value $text -Encoding UTF8
}

Invoke-ExpectedRefusal -Label "missing-r17-closeout-wording" -Expected "R17 accepted and closed with caveats" -Mutation {
    param($root)
    foreach ($relative in @(
            "README.md",
            "execution/KANBAN.md",
            "governance/ACTIVE_STATE.md",
            "governance/DECISION_LOG.md",
            "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md",
            "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md"
        )) {
        $path = Join-Path $root $relative
        $text = (Get-Content -LiteralPath $path -Raw).Replace("R17 accepted and closed with caveats through R17-028 only", "R17 closeout wording removed")
        Set-Content -LiteralPath $path -Value $text -Encoding UTF8
    }
}

Invoke-ExpectedRefusal -Label "runtime-overclaim" -Expected "Forbidden status-doc claim" -Mutation {
    param($root)
    $path = Join-Path $root "governance/ACTIVE_STATE.md"
    Add-Content -LiteralPath $path -Value "`nR18 runtime implementation is delivered." -Encoding UTF8
}

Invoke-ExpectedRefusal -Label "operator-approval-missing" -Expected "operator approval" -Mutation {
    param($root)
    $path = Join-Path $root "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json"
    $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $json.operator_approval_recorded = $false
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "Status-doc gate tests failed."
}

Write-Output ("All status-doc gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
