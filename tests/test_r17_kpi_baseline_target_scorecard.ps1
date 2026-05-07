$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$validatorPath = Join-Path $repoRoot "tools\validate_r17_kpi_baseline_target_scorecard.ps1"
$scorecardPath = Join-Path $repoRoot "state\governance\r17_kpi_baseline_target_scorecard.json"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17kpi" + [guid]::NewGuid().ToString("N").Substring(0, 8))

function Invoke-Validator {
    param([string]$Path)

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $validatorPath -ScorecardPath $Path -RepositoryRoot $repoRoot 2>&1
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = ($output -join [Environment]::NewLine)
    }
}

function Write-JsonFixture {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Object | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Invoke-ExpectedInvalid {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedFragment,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutate
    )

    $candidate = Get-Content -LiteralPath $scorecardPath -Raw | ConvertFrom-Json
    & $Mutate $candidate
    $candidatePath = Join-Path $tempRoot ("{0}.invalid.json" -f $Label)
    Write-JsonFixture -Object $candidate -Path $candidatePath

    $result = Invoke-Validator -Path $candidatePath
    if ($result.ExitCode -eq 0) {
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
        return
    }
    if ($result.Output -notlike ("*{0}*" -f $ExpectedFragment)) {
        $script:failures += "FAIL invalid: $Label refusal missed '$ExpectedFragment'. Actual: $($result.Output)"
        return
    }

    Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $ExpectedFragment)
    $script:invalidRejected += 1
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $validResult = Invoke-Validator -Path $scorecardPath
    if ($validResult.ExitCode -ne 0) {
        $failures += "FAIL valid committed scorecard: $($validResult.Output)"
    }
    else {
        Write-Output "PASS valid committed R17-003 scorecard."
        $validPassed += 1
    }

    $scorecard = Get-Content -LiteralPath $scorecardPath -Raw | ConvertFrom-Json
    if ($scorecard.domain_scores.Count -ne 10) {
        $failures += "FAIL domain count: expected exactly 10 KPI domains."
    }
    else {
        Write-Output "PASS domain count: 10 KPI domains."
        $validPassed += 1
    }

    if ($scorecard.current_posture.active_through_task -ne "R17-003" -or $scorecard.current_posture.planned_tasks[0] -ne "R17-004" -or $scorecard.current_posture.planned_tasks[-1] -ne "R17-028") {
        $failures += "FAIL posture: expected active through R17-003 with R17-004 through R17-028 planned only."
    }
    else {
        Write-Output "PASS posture: R17 active through R17-003; R17-004 through R17-028 planned only."
        $validPassed += 1
    }

    if ($scorecard.weighted_aggregate.targets_included -or $scorecard.target_aggregate.achieved) {
        $failures += "FAIL target separation: targets were treated as achieved/current scoring."
    }
    else {
        Write-Output "PASS target separation: target scores are future evidence requirements only."
        $validPassed += 1
    }

    foreach ($field in @("live_a2a_runtime_implemented", "developer_codex_executor_adapter_runtime_implemented", "qa_test_agent_adapter_runtime_implemented", "evidence_auditor_api_runtime_implemented", "kanban_product_runtime_implemented")) {
        if ($scorecard.current_posture.$field -ne $false) {
            $failures += "FAIL current non-claim: expected $field to be false."
        }
    }
    if ($scorecard.current_posture.live_a2a_runtime_implemented -eq $false) {
        Write-Output "PASS current non-claims: no runtime adapter/A2A/Kanban product claims."
        $validPassed += 1
    }

    Invoke-ExpectedInvalid -Label "live-a2a-runtime-claimed" -ExpectedFragment "live_a2a_runtime_implemented must be False" -Mutate {
        param($candidate)
        $candidate.current_posture.live_a2a_runtime_implemented = $true
    }

    Invoke-ExpectedInvalid -Label "target-treated-as-achieved" -ExpectedFragment "target_is_achievement must be False" -Mutate {
        param($candidate)
        $candidate.domain_scores[0].target_is_achievement = $true
    }

    Invoke-ExpectedInvalid -Label "missing-four-cycles-requirement" -ExpectedFragment "four_exercised_a2a_cycles_required must be True" -Mutate {
        param($candidate)
        $candidate.target_posture_requirements.four_exercised_a2a_cycles_required = $false
    }

    Invoke-ExpectedInvalid -Label "wrong-domain-weight" -ExpectedFragment "weight must be" -Mutate {
        param($candidate)
        $candidate.domain_scores[0].weight = 13
    }
}
catch {
    $failures += ("FAIL R17 KPI scorecard harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 KPI baseline target scorecard tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R17 KPI baseline target scorecard tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
