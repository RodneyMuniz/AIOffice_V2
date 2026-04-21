$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\MilestoneBaseline.psm1"
Import-Module $modulePath -Force

$validMilestone = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"
$validProject = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.project.valid.json"
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
    Set-Content -LiteralPath (Join-Path $Root "baseline.txt") -Value "baseline" -Encoding UTF8
    & git -C $Root add baseline.txt | Out-Null
    & git -C $Root commit -m "baseline commit" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create temp Git repository baseline commit."
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-valid-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        $baseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-valid-001" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "Capture a bounded Git-backed milestone checkpoint for restore-target proof." -RepositoryRoot $tempRoot -CapturedAt ([datetime]::Parse("2026-04-21T10:00:00Z").ToUniversalTime())
        $storePath = Join-Path $tempRoot "store"
        $savedPath = Save-MilestoneBaselineRecord -Baseline $baseline -StorePath $storePath
        $loadedBaseline = Get-MilestoneBaselineRecord -BaselineId $baseline.baseline_id -StorePath $storePath

        if ($loadedBaseline.Baseline.record_type -ne "milestone_baseline") {
            $failures += "FAIL valid milestone baseline: record_type did not persist."
        }
        if ($loadedBaseline.Baseline.git.working_tree_clean -ne $true) {
            $failures += "FAIL valid milestone baseline: working_tree_clean did not persist as true."
        }
        if (@($loadedBaseline.Baseline.git.status_lines).Count -ne 0) {
            $failures += "FAIL valid milestone baseline: clean Git capture retained unexpected status lines."
        }
        if (@($loadedBaseline.Baseline.planning_record_refs).Count -ne 1) {
            $failures += "FAIL valid milestone baseline: expected one planning_record_ref."
        }
        if (@($loadedBaseline.Baseline.evidence | Where-Object { $_.kind -eq "planning_record" }).Count -eq 0) {
            $failures += "FAIL valid milestone baseline: planning_record evidence was not preserved."
        }

        Write-Output ("PASS valid milestone baseline: {0}" -f $savedPath)
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid milestone baseline harness: {0}" -f $_.Exception.Message)
}

try {
    $dirtyRepoRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-dirty-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $dirtyRepoRoot

    try {
        Add-Content -LiteralPath (Join-Path $dirtyRepoRoot "baseline.txt") -Value "dirty change"
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-dirty" -MilestonePath $validMilestone -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "This should fail because the worktree is dirty." -RepositoryRoot $dirtyRepoRoot | Out-Null
            $failures += "FAIL dirty milestone baseline: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS dirty milestone baseline refusal: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $dirtyRepoRoot) {
            Remove-Item -LiteralPath $dirtyRepoRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL dirty milestone baseline harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-project-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot

    try {
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-project" -MilestonePath $validProject -PlanningRecordPaths @($validPlanningRecord) -OperatorId "operator:admin" -AuthorityReason "This should fail because the anchor object is not a milestone." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL project baseline anchor: capture accepted a project unexpectedly."
        }
        catch {
            Write-Output ("PASS project baseline anchor refusal: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL project baseline anchor harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone baseline tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone baseline tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
