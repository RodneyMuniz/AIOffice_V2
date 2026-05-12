$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repoRoot "tools\validate_r18_opening_authority.ps1"
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
        "governance/DECISION_LOG.md",
        "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md",
        "contracts/governance/r18_opening_authority.contract.json",
        "state/governance/r18_opening_authority.json",
        "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json",
        "state/planning/r18_automated_recovery_runtime_and_api_orchestration/r18_001_opening_authority_manifest.md"
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
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("r18opening" + [guid]::NewGuid().ToString("N").Substring(0, 8))
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
    Write-Output "PASS valid: live R18 opening authority validates."
    $validPassed += 1
}
catch {
    $failures += "FAIL valid live R18 opening authority: $($_.Exception.Message)"
}

Invoke-ExpectedRefusal -Label "opened-beyond-r18-001" -Expected "R18-001 only" -Mutation {
    param($root)
    $path = Join-Path $root "state/governance/r18_opening_authority.json"
    $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $json.active_task = "R18-002"
    $json.done_tasks = @("R18-001", "R18-002")
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
}

Invoke-ExpectedRefusal -Label "runtime-claim" -Expected "runtime implementation" -Mutation {
    param($root)
    $path = Join-Path $root "state/governance/r18_opening_authority.json"
    $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $json.r18_runtime_implementation_claimed = $true
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
}

Invoke-ExpectedRefusal -Label "api-claim" -Expected "API invocation" -Mutation {
    param($root)
    $path = Join-Path $root "state/governance/r18_opening_authority.json"
    $json = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $json.openai_api_invoked = $true
    $json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
}

Invoke-ExpectedRefusal -Label "authority-r18-020-done" -Expected "R18-020 must be planned only" -Mutation {
    param($root)
    $path = Join-Path $root "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md"
    $text = Get-Content -LiteralPath $path -Raw
    $text = [regex]::Replace($text, '(### `R18-020`[\s\S]*?\r?\n- Status: )planned', '${1}done', 1)
    Set-Content -LiteralPath $path -Value $text -Encoding UTF8
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw "R18 opening authority tests failed."
}

Write-Output ("All R18 opening authority tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
