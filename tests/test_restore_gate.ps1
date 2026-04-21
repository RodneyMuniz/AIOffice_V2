$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$baselineModulePath = Join-Path $repoRoot "tools\MilestoneBaseline.psm1"
$restoreGateModulePath = Join-Path $repoRoot "tools\RestoreGate.psm1"
$baselineModule = Import-Module $baselineModulePath -Force -PassThru
$restoreGateModule = Import-Module $restoreGateModulePath -Force -PassThru

$newMilestoneBaselineRecord = $baselineModule.ExportedCommands["New-MilestoneBaselineRecord"]
$saveMilestoneBaselineRecord = $baselineModule.ExportedCommands["Save-MilestoneBaselineRecord"]
$invokeRestoreGate = $restoreGateModule.ExportedCommands["Invoke-RestoreGate"]
$saveRestoreGateResult = $restoreGateModule.ExportedCommands["Save-RestoreGateResult"]

$validMilestone = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"
$validPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_record.task.valid.json"

function New-TempGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    & git -C $Root init | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize temp Git repository."
    }

    & git -C $Root config user.email "codex@example.com" | Out-Null
    & git -C $Root config user.name "Codex" | Out-Null

    Set-Content -LiteralPath (Join-Path $Root "restore.txt") -Value "baseline" -Encoding UTF8
    & git -C $Root add restore.txt | Out-Null
    & git -C $Root commit -m "baseline commit" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create baseline commit for temp Git repository."
    }
}

function Get-CurrentBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return (& git -C $RepositoryRoot branch --show-current 2>$null).Trim()
}

function Get-CurrentHead {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return (& git -C $RepositoryRoot rev-parse HEAD 2>$null).Trim()
}

function Get-CurrentTree {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return (& git -C $RepositoryRoot rev-parse HEAD^{tree} 2>$null).Trim()
}

function New-RestoreRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [Parameter(Mandatory = $true)]
        [string]$BaselinePath,
        [Parameter(Mandatory = $true)]
        [string]$TargetBranch,
        [Parameter(Mandatory = $true)]
        [string]$TargetCommit,
        [Parameter(Mandatory = $true)]
        [string]$TargetTreeId,
        [Parameter(Mandatory = $true)]
        [string]$ApprovalStatus,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ApprovalBy,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ApprovalAt
    )

    $request = [pscustomobject]@{
        contract_version  = "v1"
        record_type       = "restore_gate_request"
        restore_request_id = "restore-r5-test-001"
        baseline_ref      = $BaselinePath
        target_branch     = $TargetBranch
        target_commit     = $TargetCommit
        target_tree_id    = $TargetTreeId
        requested_at      = "2026-04-21T11:00:00Z"
        requested_by      = "operator:admin"
        approval          = [pscustomobject]@{
            status = $ApprovalStatus
            by     = if ([string]::IsNullOrWhiteSpace($ApprovalBy)) { $null } else { $ApprovalBy }
            at     = if ([string]::IsNullOrWhiteSpace($ApprovalAt)) { $null } else { $ApprovalAt }
            notes  = "Restore gate test approval."
        }
        notes             = "Evaluate a bounded restore target against the captured milestone baseline."
    }

    $request | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $RequestPath -Encoding UTF8
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-restore-valid-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        $baseline = & $newMilestoneBaselineRecord -BaselineId "baseline-r5-restore-001" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "Capture restore-target baseline." -RepositoryRoot $tempRoot -CapturedAt ([datetime]::Parse("2026-04-21T11:00:00Z").ToUniversalTime())
        $baselineStore = Join-Path $env:TEMP ("aioffice-r5-restore-baseline-store-valid-" + [guid]::NewGuid().ToString("N"))
        $baselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $baselineStore

        Add-Content -LiteralPath (Join-Path $tempRoot "restore.txt") -Value "second commit"
        & git -C $tempRoot add restore.txt | Out-Null
        & git -C $tempRoot commit -m "second commit" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create second commit for restore gate test."
        }

        $requestPath = Join-Path $env:TEMP ("aioffice-r5-restore-request-valid-" + [guid]::NewGuid().ToString("N") + ".json")
        New-RestoreRequest -RequestPath $requestPath -BaselinePath $baselinePath -TargetBranch $baseline.git.branch -TargetCommit $baseline.git.head_commit -TargetTreeId $baseline.git.tree_id -ApprovalStatus "approved" -ApprovalBy "operator:admin" -ApprovalAt "2026-04-21T11:05:00Z"
        $result = & $invokeRestoreGate -RestoreRequestPath $requestPath -RepositoryRoot $tempRoot
        $savedResult = & $saveRestoreGateResult -RestoreGateResult $result -StorePath (Join-Path $tempRoot "results")

        if ($savedResult.RestoreGateResult.decision -ne "allow") {
            $failures += "FAIL valid restore gate: expected allow decision."
        }
        if (-not $savedResult.RestoreGateResult.preconditions.restore_required) {
            $failures += "FAIL valid restore gate: restore_required precondition should be true."
        }
        if (-not $savedResult.RestoreGateResult.preconditions.clean_worktree) {
            $failures += "FAIL valid restore gate: clean_worktree precondition should be true."
        }

        Write-Output ("PASS valid restore gate: {0}" -f $savedResult.RestoreResultPath)
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $requestPath) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if (Test-Path -LiteralPath $baselineStore) {
            Remove-Item -LiteralPath $baselineStore -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid restore gate harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-restore-same-head-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        $baseline = & $newMilestoneBaselineRecord -BaselineId "baseline-r5-restore-same-head" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "Capture restore-target baseline." -RepositoryRoot $tempRoot
        $baselineStore = Join-Path $env:TEMP ("aioffice-r5-restore-baseline-store-same-head-" + [guid]::NewGuid().ToString("N"))
        $baselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $baselineStore

        $requestPath = Join-Path $env:TEMP ("aioffice-r5-restore-request-same-head-" + [guid]::NewGuid().ToString("N") + ".json")
        New-RestoreRequest -RequestPath $requestPath -BaselinePath $baselinePath -TargetBranch $baseline.git.branch -TargetCommit $baseline.git.head_commit -TargetTreeId $baseline.git.tree_id -ApprovalStatus "approved" -ApprovalBy "operator:admin" -ApprovalAt "2026-04-21T11:05:00Z"
        $result = & $invokeRestoreGate -RestoreRequestPath $requestPath -RepositoryRoot $tempRoot

        if ($result.decision -ne "blocked") {
            $failures += "FAIL restore-not-required case: expected blocked decision."
        }
        if (@($result.block_reasons | Where-Object { $_.code -eq "restore_not_required" }).Count -eq 0) {
            $failures += "FAIL restore-not-required case: restore_not_required reason was missing."
        }

        Write-Output "PASS restore-not-required refusal."
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $requestPath) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if (Test-Path -LiteralPath $baselineStore) {
            Remove-Item -LiteralPath $baselineStore -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL restore-not-required harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-restore-dirty-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        $baseline = & $newMilestoneBaselineRecord -BaselineId "baseline-r5-restore-dirty" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "Capture restore-target baseline." -RepositoryRoot $tempRoot
        $baselineStore = Join-Path $env:TEMP ("aioffice-r5-restore-baseline-store-dirty-" + [guid]::NewGuid().ToString("N"))
        $baselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $baselineStore

        Add-Content -LiteralPath (Join-Path $tempRoot "restore.txt") -Value "second commit"
        & git -C $tempRoot add restore.txt | Out-Null
        & git -C $tempRoot commit -m "second commit" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create second commit for dirty restore gate test."
        }

        Add-Content -LiteralPath (Join-Path $tempRoot "restore.txt") -Value "dirty change"
        $requestPath = Join-Path $env:TEMP ("aioffice-r5-restore-request-dirty-" + [guid]::NewGuid().ToString("N") + ".json")
        New-RestoreRequest -RequestPath $requestPath -BaselinePath $baselinePath -TargetBranch $baseline.git.branch -TargetCommit $baseline.git.head_commit -TargetTreeId $baseline.git.tree_id -ApprovalStatus "approved" -ApprovalBy "operator:admin" -ApprovalAt "2026-04-21T11:05:00Z"
        $result = & $invokeRestoreGate -RestoreRequestPath $requestPath -RepositoryRoot $tempRoot

        if ($result.decision -ne "blocked") {
            $failures += "FAIL dirty restore gate: expected blocked decision."
        }
        if (@($result.block_reasons | Where-Object { $_.code -eq "worktree_dirty" }).Count -eq 0) {
            $failures += "FAIL dirty restore gate: worktree_dirty reason was missing."
        }

        Write-Output "PASS dirty restore gate refusal."
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $requestPath) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if (Test-Path -LiteralPath $baselineStore) {
            Remove-Item -LiteralPath $baselineStore -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL dirty restore gate harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-restore-pending-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        $baseline = & $newMilestoneBaselineRecord -BaselineId "baseline-r5-restore-pending" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "Capture restore-target baseline." -RepositoryRoot $tempRoot
        $baselineStore = Join-Path $env:TEMP ("aioffice-r5-restore-baseline-store-pending-" + [guid]::NewGuid().ToString("N"))
        $baselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $baselineStore

        Add-Content -LiteralPath (Join-Path $tempRoot "restore.txt") -Value "second commit"
        & git -C $tempRoot add restore.txt | Out-Null
        & git -C $tempRoot commit -m "second commit" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create second commit for pending-approval restore gate test."
        }

        $requestPath = Join-Path $env:TEMP ("aioffice-r5-restore-request-pending-" + [guid]::NewGuid().ToString("N") + ".json")
        New-RestoreRequest -RequestPath $requestPath -BaselinePath $baselinePath -TargetBranch $baseline.git.branch -TargetCommit $baseline.git.head_commit -TargetTreeId $baseline.git.tree_id -ApprovalStatus "pending" -ApprovalBy $null -ApprovalAt $null
        $result = & $invokeRestoreGate -RestoreRequestPath $requestPath -RepositoryRoot $tempRoot

        if ($result.decision -ne "blocked") {
            $failures += "FAIL pending approval restore gate: expected blocked decision."
        }
        if (@($result.block_reasons | Where-Object { $_.code -eq "approval_missing" }).Count -eq 0) {
            $failures += "FAIL pending approval restore gate: approval_missing reason was missing."
        }

        Write-Output "PASS pending approval restore gate refusal."
        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $requestPath) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if (Test-Path -LiteralPath $baselineStore) {
            Remove-Item -LiteralPath $baselineStore -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL pending approval restore gate harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Restore gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All restore gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
