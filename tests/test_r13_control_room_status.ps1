$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13ControlRoomStatus.psm1") -Force -PassThru
$testStatus = $module.ExportedCommands["Test-R13ControlRoomStatus"]
$testView = $module.ExportedCommands["Test-R13ControlRoomView"]
$testRefresh = $module.ExportedCommands["Test-R13ControlRoomRefreshResult"]
$writeJson = $module.ExportedCommands["Write-R13ControlRoomJsonFile"]

$refreshCli = Join-Path $repoRoot "tools\refresh_r13_control_room.ps1"
$validateStatusCli = Join-Path $repoRoot "tools\validate_r13_control_room_status.ps1"
$validateViewCli = Join-Path $repoRoot "tools\validate_r13_control_room_view.ps1"
$validateRefreshCli = Join-Path $repoRoot "tools\validate_r13_control_room_refresh_result.ps1"
$tempRoot = Join-Path $repoRoot ("state\control_room\_test_runs\" + [guid]::NewGuid().ToString("N"))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Write-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    & $script:writeJson -Path $Path -Value $Value
}

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
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
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
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
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $result = Invoke-PowerShellFile -FilePath $FilePath -Arguments $Arguments
    if ($result.ExitCode -ne 0 -or ([string]::Join("`n", @($result.Output)) -notmatch "VALID")) {
        $script:failures += ("FAIL valid: {0} did not print VALID. Output: {1}" -f $Label, ([string]::Join(" ", @($result.Output))))
        return
    }

    Write-Output ("PASS valid: {0}" -f $Label)
    $script:validPassed += 1
}

function Assert-RefreshCliBlocked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $result = Invoke-PowerShellFile -FilePath $refreshCli -Arguments $Arguments
    if ($result.ExitCode -eq 0) {
        $script:failures += ("FAIL stale refresh: {0} exited 0." -f $Label)
        return
    }

    Write-Output ("PASS stale refresh: {0}" -f $Label)
    $script:invalidRejected += 1
}

function Invoke-MutatedStatusRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$SourceStatusPath,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutator
    )

    $status = Read-JsonObject -Path $SourceStatusPath
    & $Mutator $status
    $invalidPath = Join-Path $tempRoot ("invalid\" + $Label + ".json")
    Write-JsonObject -Path $invalidPath -Value $status
    Invoke-ExpectedRefusal -Label $Label -Action {
        & $testStatus -StatusPath $invalidPath | Out-Null
    }
}

try {
    $generatedRoot = Join-Path $tempRoot "current"
    $refreshResult = Invoke-PowerShellFile -FilePath $refreshCli -Arguments @("-OutputRoot", $generatedRoot)
    if ($refreshResult.ExitCode -ne 0) {
        $failures += "FAIL refresh CLI: current refresh exited non-zero. Output: $([string]::Join(' ', @($refreshResult.Output)))"
    }
    else {
        Write-Output "PASS refresh CLI: generated current artifacts."
        $validPassed += 1
    }

    $generatedStatusPath = Join-Path $generatedRoot "control_room_status.json"
    $generatedViewPath = Join-Path $generatedRoot "control_room.md"
    $generatedRefreshPath = Join-Path $generatedRoot "control_room_refresh_result.json"
    $generatedManifestPath = Join-Path $generatedRoot "validation_manifest.md"

    $statusValidation = & $testStatus -StatusPath $generatedStatusPath
    if ($statusValidation.CompletedTaskCount -ne 9 -or $statusValidation.PlannedTaskCount -ne 9 -or $statusValidation.NextLegalAction -ne "R13-010") {
        $failures += "FAIL generated status: status did not preserve R13-009 boundary."
    }
    else {
        Write-Output "PASS generated status: R13-009 boundary validates."
        $validPassed += 1
    }

    & $testView -ViewPath $generatedViewPath | Out-Null
    Write-Output "PASS generated Markdown view."
    $validPassed += 1

    & $testRefresh -RefreshResultPath $generatedRefreshPath | Out-Null
    Write-Output "PASS generated refresh result."
    $validPassed += 1

    if (-not (Test-Path -LiteralPath $generatedManifestPath)) {
        $failures += "FAIL generated manifest: validation_manifest.md was not created."
    }
    else {
        $manifestText = Get-Content -LiteralPath $generatedManifestPath -Raw
        if ($manifestText -notmatch "Stale-state checks passed: ``True``" -or $manifestText -notmatch "R13-010") {
            $failures += "FAIL generated manifest: expected stale-state and next-action evidence was missing."
        }
        else {
            Write-Output "PASS generated validation manifest."
            $validPassed += 1
        }
    }

    Assert-CliValid -Label "generated status validates" -FilePath $validateStatusCli -Arguments @("-StatusPath", $generatedStatusPath)
    Assert-CliValid -Label "generated Markdown validates" -FilePath $validateViewCli -Arguments @("-ViewPath", $generatedViewPath)
    Assert-CliValid -Label "generated refresh result validates" -FilePath $validateRefreshCli -Arguments @("-RefreshResultPath", $generatedRefreshPath)

    Invoke-MutatedStatusRefusal -Label "stale_branch.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.stale_state_checks.branch_matches_expected = $false
        $status.stale_state_checks.stale_state_checks_passed = $false
    }
    Invoke-MutatedStatusRefusal -Label "stale_head.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.stale_state_checks.head_matches_expected = $false
        $status.stale_state_checks.stale_state_checks_passed = $false
    }
    Invoke-MutatedStatusRefusal -Label "missing_evidence_ref.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.evidence_refs = @($status.evidence_refs | Where-Object { [string]$_.ref_id -ne "r13-control-room-test" })
    }
    Invoke-MutatedStatusRefusal -Label "hard_gate_overclaimed.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.hard_gate_status.meaningful_qa_loop.hard_gate_delivered = $true
    }
    Invoke-MutatedStatusRefusal -Label "external_replay_claimed.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.external_replay_status.status = "partially_evidenced"
        $status.external_replay_status.executed = $true
    }
    Invoke-MutatedStatusRefusal -Label "final_signoff_claimed.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.control_room_status.summary = "R13 final QA signoff completed."
    }
    Invoke-MutatedStatusRefusal -Label "operator_demo_claimed.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.hard_gate_status.operator_demo.status = "partially_evidenced"
        $status.hard_gate_status.operator_demo.summary = "R13 operator demo delivered."
    }
    Invoke-MutatedStatusRefusal -Label "productized_ui_claimed.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.control_room_status.productized_ui_claimed = $true
    }
    Invoke-MutatedStatusRefusal -Label "missing_non_claims.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.non_claims = @($status.non_claims | Select-Object -Skip 1)
    }
    Invoke-MutatedStatusRefusal -Label "r14_successor_opened.invalid" -SourceStatusPath $generatedStatusPath -Mutator {
        param($status)
        $status.active_scope.r14_or_successor_opened = $true
    }

    $badHead = "0000000000000000000000000000000000000000"
    $badTree = "1111111111111111111111111111111111111111"
    Assert-RefreshCliBlocked -Label "stale expected branch refused" -Arguments @("-OutputRoot", (Join-Path $tempRoot "stale_branch"), "-ExpectedBranch", "release/not-r13")
    Assert-RefreshCliBlocked -Label "stale expected head refused" -Arguments @("-OutputRoot", (Join-Path $tempRoot "stale_head"), "-ExpectedHead", $badHead)
    Assert-RefreshCliBlocked -Label "stale expected tree refused" -Arguments @("-OutputRoot", (Join-Path $tempRoot "stale_tree"), "-ExpectedTree", $badTree)

    $generatedStatus = Read-JsonObject -Path $generatedStatusPath
    $completedTaskIds = @($generatedStatus.completed_tasks | ForEach-Object { [string]$_.task_id })
    $plannedTaskIds = @($generatedStatus.planned_tasks | ForEach-Object { [string]$_.task_id })
    if (($completedTaskIds -join "|") -ne ((1..9 | ForEach-Object { "R13-{0}" -f $_.ToString("000") }) -join "|")) {
        $failures += "FAIL generated status: completed tasks are not R13-001 through R13-009 only."
    }
    else {
        Write-Output "PASS generated status: R13 active through R13-009 only."
        $validPassed += 1
    }
    if (($plannedTaskIds -join "|") -ne ((10..18 | ForEach-Object { "R13-{0}" -f $_.ToString("000") }) -join "|")) {
        $failures += "FAIL generated status: planned tasks are not R13-010 through R13-018 only."
    }
    else {
        Write-Output "PASS generated status: R13-010 through R13-018 planned only."
        $validPassed += 1
    }
    if ($generatedStatus.hard_gate_status.current_operator_control_room.status -ne "partially_evidenced" -or [bool]$generatedStatus.hard_gate_status.current_operator_control_room.hard_gate_delivered) {
        $failures += "FAIL generated status: current operator control-room gate was not partial only."
    }
    else {
        Write-Output "PASS generated status: current control-room gate is partial only."
        $validPassed += 1
    }
    if ([bool]$generatedStatus.control_room_status.productized_ui_claimed) {
        $failures += "FAIL generated status: productized UI was claimed."
    }
    else {
        Write-Output "PASS generated status: no productized UI claim."
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL R13 control-room harness: {0}" -f $_.Exception.Message)
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
    throw ("R13 control-room tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 control-room tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
