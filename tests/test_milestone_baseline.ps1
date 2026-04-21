$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\MilestoneBaseline.psm1"
Import-Module $modulePath -Force

$validMilestone = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"
$validProject = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.project.valid.json"
$validPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_record.task.valid.json"
$validAcceptedPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\accepted\planning_record.task.valid.accepted.json"
$validWorkingPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\working\planning_record.task.valid.working.json"

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

function Invoke-GitCommitAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    & git -C $Root add -A | Out-Null
    & git -C $Root commit -m $Message | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit '$Message' in temp Git repository."
    }
}

function New-BaselineFixtureSet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $fixtureRoot = Join-Path $Root "state\fixtures\valid"
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot "planning_records\accepted") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot "planning_records\working") -Force | Out-Null

    Copy-Item -LiteralPath $validMilestone -Destination (Join-Path $fixtureRoot "governed_work_object.milestone.valid.json") -Force
    Copy-Item -LiteralPath $validProject -Destination (Join-Path $fixtureRoot "governed_work_object.project.valid.json") -Force
    Copy-Item -LiteralPath $validPlanningRecord -Destination (Join-Path $fixtureRoot "planning_record.task.valid.json") -Force
    Copy-Item -LiteralPath $validAcceptedPlanningRecord -Destination (Join-Path $fixtureRoot "planning_records\accepted\planning_record.task.valid.accepted.json") -Force
    Copy-Item -LiteralPath $validWorkingPlanningRecord -Destination (Join-Path $fixtureRoot "planning_records\working\planning_record.task.valid.working.json") -Force
    Invoke-GitCommitAll -Root $Root -Message "add governed baseline fixtures"

    return [pscustomobject]@{
        MilestonePath      = Join-Path $fixtureRoot "governed_work_object.milestone.valid.json"
        ProjectPath        = Join-Path $fixtureRoot "governed_work_object.project.valid.json"
        PlanningRecordPath = Join-Path $fixtureRoot "planning_record.task.valid.json"
        AcceptedRecordPath = Join-Path $fixtureRoot "planning_records\accepted\planning_record.task.valid.accepted.json"
    }
}

function New-PersistedBaselineHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$BaselineId
    )

    New-TempGitRepository -Root $Root
    $fixtureSet = New-BaselineFixtureSet -Root $Root
    $baseline = New-MilestoneBaselineRecord -BaselineId $BaselineId -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Persist a bounded Git-backed milestone baseline for focused validation hardening." -RepositoryRoot $Root -CapturedAt ([datetime]::Parse("2026-04-21T10:00:00Z").ToUniversalTime())
    $storePath = Join-Path $Root "store"
    $savedPath = Save-MilestoneBaselineRecord -Baseline $baseline -StorePath $storePath

    return [pscustomobject]@{
        Root      = $Root
        FixtureSet = $fixtureSet
        StorePath = $storePath
        SavedPath = $savedPath
        Baseline  = $baseline
    }
}

function Invoke-TamperedBaselineRefusalTest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Tamper
    )

    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-tamper-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = New-PersistedBaselineHarness -Root $tempRoot -BaselineId ("baseline-r5-tamper-" + [guid]::NewGuid().ToString("N"))
        $persistedBaseline = Get-Content -LiteralPath $harness.SavedPath -Raw | ConvertFrom-Json
        & $Tamper $persistedBaseline $harness
        $persistedBaseline | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $harness.SavedPath -Encoding UTF8

        try {
            Test-MilestoneBaselineRecordContract -BaselinePath $harness.SavedPath | Out-Null
            $script:failures += ("FAIL {0}: tampered baseline validated unexpectedly." -f $Label)
        }
        catch {
            Write-Output ("PASS {0} refusal: {1}" -f $Label, $_.Exception.Message)
            $script:invalidRejected += 1
        }
    }
    catch {
        $script:failures += ("FAIL {0} harness: {1}" -f $Label, $_.Exception.Message)
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-valid-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $baseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-valid-001" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Capture a bounded Git-backed milestone checkpoint for restore-target proof." -RepositoryRoot $tempRoot -CapturedAt ([datetime]::Parse("2026-04-21T10:00:00Z").ToUniversalTime())
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
    $fixtureSet = New-BaselineFixtureSet -Root $dirtyRepoRoot

    try {
        Add-Content -LiteralPath (Join-Path $dirtyRepoRoot "baseline.txt") -Value "dirty change"
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-dirty" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the worktree is dirty." -RepositoryRoot $dirtyRepoRoot | Out-Null
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
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-project" -MilestonePath $fixtureSet.ProjectPath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the anchor object is not a milestone." -RepositoryRoot $tempRoot | Out-Null
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

try {
    $captureRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-milestone-" + [guid]::NewGuid().ToString("N"))
    $donorRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-milestone-donor-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $captureRoot
    New-TempGitRepository -Root $donorRoot
    $captureFixtures = New-BaselineFixtureSet -Root $captureRoot
    $donorFixtures = New-BaselineFixtureSet -Root $donorRoot

    try {
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-cross-repo-milestone" -MilestonePath $donorFixtures.MilestonePath -PlanningRecordPaths @($captureFixtures.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the milestone anchor is outside the captured repository." -RepositoryRoot $captureRoot | Out-Null
            $failures += "FAIL cross-repo milestone anchor: capture accepted a milestone outside the captured repository unexpectedly."
        }
        catch {
            Write-Output ("PASS cross-repo milestone anchor refusal: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $captureRoot) {
            Remove-Item -LiteralPath $captureRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $donorRoot) {
            Remove-Item -LiteralPath $donorRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL cross-repo milestone anchor harness: {0}" -f $_.Exception.Message)
}

try {
    $captureRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-planning-" + [guid]::NewGuid().ToString("N"))
    $donorRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-planning-donor-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $captureRoot
    New-TempGitRepository -Root $donorRoot
    $captureFixtures = New-BaselineFixtureSet -Root $captureRoot
    $donorFixtures = New-BaselineFixtureSet -Root $donorRoot

    try {
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-cross-repo-planning" -MilestonePath $captureFixtures.MilestonePath -PlanningRecordPaths @($donorFixtures.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the planning record is outside the captured repository." -RepositoryRoot $captureRoot | Out-Null
            $failures += "FAIL cross-repo planning record: capture accepted a planning record outside the captured repository unexpectedly."
        }
        catch {
            Write-Output ("PASS cross-repo planning record refusal: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $captureRoot) {
            Remove-Item -LiteralPath $captureRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $donorRoot) {
            Remove-Item -LiteralPath $donorRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL cross-repo planning record harness: {0}" -f $_.Exception.Message)
}

try {
    $captureRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-accepted-" + [guid]::NewGuid().ToString("N"))
    $donorRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-repo-accepted-donor-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $captureRoot
    New-TempGitRepository -Root $donorRoot
    $captureFixtures = New-BaselineFixtureSet -Root $captureRoot
    $donorFixtures = New-BaselineFixtureSet -Root $donorRoot

    try {
        $planningRecord = Get-Content -LiteralPath $captureFixtures.PlanningRecordPath -Raw | ConvertFrom-Json
        $planningRecord.accepted_state.record_ref = $donorFixtures.AcceptedRecordPath
        $planningRecord | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $captureFixtures.PlanningRecordPath -Encoding UTF8
        Invoke-GitCommitAll -Root $captureRoot -Message "redirect accepted planning ref outside repository"

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-cross-repo-accepted" -MilestonePath $captureFixtures.MilestonePath -PlanningRecordPaths @($captureFixtures.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the accepted planning ref resolves outside the captured repository." -RepositoryRoot $captureRoot | Out-Null
            $failures += "FAIL cross-repo accepted planning ref: capture accepted an accepted planning ref outside the captured repository unexpectedly."
        }
        catch {
            Write-Output ("PASS cross-repo accepted planning ref refusal: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $captureRoot) {
            Remove-Item -LiteralPath $captureRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $donorRoot) {
            Remove-Item -LiteralPath $donorRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL cross-repo accepted planning ref harness: {0}" -f $_.Exception.Message)
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored repository_root" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.repository_root = (Join-Path $Harness.Root "missing-repository-root")
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored branch" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.branch = "invalid branch name"
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored head_commit" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.head_commit = "12345"
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored tree_id" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.tree_id = "not-a-tree-id"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone baseline tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone baseline tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
