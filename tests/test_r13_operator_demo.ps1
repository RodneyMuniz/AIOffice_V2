$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$controlRoomModule = Import-Module (Join-Path $repoRoot "tools\R13ControlRoomStatus.psm1") -Force -PassThru
$writeJson = $controlRoomModule.ExportedCommands["Write-R13ControlRoomJsonFile"]

$renderCli = Join-Path $repoRoot "tools\render_r13_operator_demo.ps1"
$validateCli = Join-Path $repoRoot "tools\validate_r13_operator_demo.ps1"
$currentStatusPath = Join-Path $repoRoot "state\control_room\r13_current\control_room_status.json"
$tempRoot = Join-Path $repoRoot ("state\control_room\_test_runs\" + [guid]::NewGuid().ToString("N"))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonObject {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Write-JsonObject {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Value
    )
    & $writeJson -Path $Path -Value $Value
}

function Write-TextFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value
    )
    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ((($Value -replace "`r`n", "`n") -replace "`r", "`n")), $utf8NoBom)
}

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @()
    )
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { [string]$_ })
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )
    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

function Assert-CliValid {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$DemoPath
    )
    $result = Invoke-PowerShellFile -FilePath $validateCli -Arguments @("-DemoPath", $DemoPath)
    if ($result.ExitCode -ne 0 -or ([string]::Join("`n", @($result.Output)) -notmatch "VALID")) {
        $script:failures += ("FAIL valid: {0} did not print VALID. Output: {1}" -f $Label, ([string]::Join(" ", @($result.Output))))
        return
    }
    Write-Output ("PASS valid: {0}" -f $Label)
    $script:validPassed += 1
}

function New-R13NineSourceStatus {
    param([Parameter(Mandatory = $true)]$Status)

    $Status.source_task = "R13-009"
    $Status.active_scope.active_through_task = "R13-009"
    $Status.active_scope.completed_range = "R13-001 through R13-009"
    $Status.active_scope.planned_range = "R13-010 through R13-018"
    $Status.active_scope.scope_summary = "R13 is active through R13-009 only; R13-010 through R13-018 remain planned only."
    $Status.active_scope.current_task_boundary = "R13-009 complete; no R13-010 implementation is included."
    $Status.completed_tasks = @($Status.completed_tasks | Where-Object { [string]$_.task_id -ne "R13-010" })
    $planned010 = [pscustomobject][ordered]@{
        task_id = "R13-010"
        status = "planned_only"
        summary = "R13-010 remains planned only under the R13 authority task order."
        evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
    }
    $Status.planned_tasks = @($planned010) + @($Status.planned_tasks | Where-Object { [string]$_.task_id -ne "R13-010" })
    $Status.hard_gate_status.operator_demo.status = "not_delivered"
    $Status.hard_gate_status.operator_demo.hard_gate_delivered = $false
    $Status.hard_gate_status.operator_demo.summary = "R13-010 remains planned only; no operator demo artifact exists in this source status."
    $Status.hard_gate_status.operator_demo.evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
    $Status.next_actions = @(
        [pscustomobject][ordered]@{
            id = "next-r13-010-operator-demo"
            task_id = "R13-010"
            title = "Add operator demo artifact"
            action_type = "next_legal_task"
            description = "Generate the operator demo artifact from actual QA failure-to-fix cycle evidence and current pipeline refs."
            required_before = "R13-011 external replay or later signoff"
            evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
        }
    )
    return $Status
}

function Write-InvalidDemo {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Text
    )
    $path = Join-Path $tempRoot ("invalid\" + $Label + ".md")
    Write-TextFile -Path $path -Value $Text
    return $path
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $sourceStatus = New-R13NineSourceStatus -Status (Read-JsonObject -Path $currentStatusPath)
    $sourceStatusPath = Join-Path $tempRoot "source_r13_009_status.json"
    Write-JsonObject -Path $sourceStatusPath -Value $sourceStatus

    $generatedDemoPath = Join-Path $tempRoot "operator_demo.md"
    $renderResult = Invoke-PowerShellFile -FilePath $renderCli -Arguments @("-StatusPath", $sourceStatusPath, "-OutputPath", $generatedDemoPath)
    if ($renderResult.ExitCode -ne 0) {
        $failures += "FAIL render: operator demo renderer returned non-zero. Output: $([string]::Join(' ', @($renderResult.Output)))"
    }
    else {
        Write-Output "PASS render: operator demo generated."
        $validPassed += 1
    }

    Assert-CliValid -Label "generated operator demo validates" -DemoPath $generatedDemoPath

    $generatedManifestPath = Join-Path $tempRoot "operator_demo_validation_manifest.md"
    if (-not (Test-Path -LiteralPath $generatedManifestPath)) {
        $failures += "FAIL manifest: operator_demo_validation_manifest.md was not generated."
    }
    else {
        $manifestText = Get-Content -LiteralPath $generatedManifestPath -Raw
        if ($manifestText -notmatch "R13-001 through R13-010" -or $manifestText -notmatch "R13-011 through R13-018") {
            $failures += "FAIL manifest: operator demo validation manifest did not include the R13-010 boundary."
        }
        else {
            Write-Output "PASS manifest: operator demo validation manifest generated."
            $validPassed += 1
        }
    }

    $demoText = Get-Content -LiteralPath $generatedDemoPath -Raw
    $positiveChecks = @(
        'selected issue type `malformed_json`',
        'Before issue count: `1`',
        'After issue count: `0`',
        'Comparison verdict: `target_issue_resolved`',
        'Cycle aggregate verdict: `fixed_pending_external_replay`',
        'External replay missing',
        'Final QA signoff missing',
        'Hard gates not fully delivered',
        '`R13-011`: external replay after demo',
        'state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json',
        'state/cycles/r13_qa_cycle_demo/before_after_comparison.json',
        'state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json',
        'state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json',
        'state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json',
        'no external replay has occurred',
        'no final QA signoff has occurred',
        'no hard R13 value gate fully delivered',
        'no productized UI',
        'no production runtime',
        'no R14 or successor opening'
    )
    foreach ($requiredText in $positiveChecks) {
        if ($demoText -notmatch [regex]::Escape($requiredText)) {
            $failures += "FAIL generated content: missing '$requiredText'."
        }
    }
    if ($failures.Count -eq 0) {
        Write-Output "PASS generated content: proof, blockers, next action, evidence refs, and non-claims present."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing_required_section.invalid" -Action {
        $path = Write-InvalidDemo -Label "missing_required_section" -Text ($demoText -replace '(?m)^## Evidence map\r?\n', '')
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected missing section" }
    }
    Invoke-ExpectedRefusal -Label "missing_evidence_refs.invalid" -Action {
        $path = Write-InvalidDemo -Label "missing_evidence_refs" -Text ($demoText -replace 'state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle\.json', 'state/cycles/r13_qa_cycle_demo/missing_cycle.json')
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected missing evidence ref" }
    }
    Invoke-ExpectedRefusal -Label "external_replay_claimed.invalid" -Action {
        $path = Write-InvalidDemo -Label "external_replay_claimed" -Text ($demoText + "`nExternal replay executed and passed.`n")
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected external replay claim" }
    }
    Invoke-ExpectedRefusal -Label "final_signoff_claimed.invalid" -Action {
        $path = Write-InvalidDemo -Label "final_signoff_claimed" -Text ($demoText + "`nFinal QA signoff completed.`n")
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected final signoff claim" }
    }
    Invoke-ExpectedRefusal -Label "hard_gate_delivered_claimed.invalid" -Action {
        $path = Write-InvalidDemo -Label "hard_gate_delivered_claimed" -Text ($demoText + "`nR13 hard value gate fully delivered.`n")
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected hard gate claim" }
    }
    Invoke-ExpectedRefusal -Label "productized_ui_claimed.invalid" -Action {
        $path = Write-InvalidDemo -Label "productized_ui_claimed" -Text ($demoText + "`nProductized UI is available.`n")
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected productized UI claim" }
    }
    Invoke-ExpectedRefusal -Label "r14_successor_opened.invalid" -Action {
        $path = Write-InvalidDemo -Label "r14_successor_opened" -Text ($demoText + "`nR14 successor milestone opened.`n")
        & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCli -DemoPath $path | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "validator rejected R14 successor claim" }
    }
}
catch {
    $failures += ("FAIL R13 operator demo harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\control_room\_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 operator demo tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 operator demo tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
