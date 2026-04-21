$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\MilestoneBaseline.psm1"
$milestoneBaselineModule = Import-Module $modulePath -Force -PassThru

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

    # Keep temp-repo fixture commits stable under runner replay without changing repo-wide Git policy.
    & git -C $Root config core.autocrlf false | Out-Null
    & git -C $Root config core.safecrlf false | Out-Null
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

function Set-JsonFixtureDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-RelativePathFromModuleRepoRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedRepoRoot = (Resolve-Path -LiteralPath $repoRoot).Path
    $normalizedTargetPath = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedRepoRoot.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$normalizedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Get-MilestoneBaselineModuleState {
    return [pscustomobject]@{
        PlanningRecordStorageModulePath         = $milestoneBaselineModule.SessionState.PSVariable.GetValue("planningRecordStorageModulePath")
        GovernedWorkObjectValidationModulePath  = $milestoneBaselineModule.SessionState.PSVariable.GetValue("governedWorkObjectValidationModulePath")
        TestPlanningRecordContract              = $milestoneBaselineModule.SessionState.PSVariable.GetValue("testPlanningRecordContract")
        TestGovernedWorkObjectContract          = $milestoneBaselineModule.SessionState.PSVariable.GetValue("testGovernedWorkObjectContract")
    }
}

function Restore-MilestoneBaselineModuleState {
    param(
        [Parameter(Mandatory = $true)]
        $State
    )

    $milestoneBaselineModule.SessionState.PSVariable.Set("planningRecordStorageModulePath", $State.PlanningRecordStorageModulePath)
    $milestoneBaselineModule.SessionState.PSVariable.Set("governedWorkObjectValidationModulePath", $State.GovernedWorkObjectValidationModulePath)
    $milestoneBaselineModule.SessionState.PSVariable.Set("testPlanningRecordContract", $State.TestPlanningRecordContract)
    $milestoneBaselineModule.SessionState.PSVariable.Set("testGovernedWorkObjectContract", $State.TestGovernedWorkObjectContract)
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
        if (@($loadedBaseline.Baseline.evidence | Where-Object { $_.kind -eq "artifact" -and $_.ref -eq $loadedBaseline.Baseline.milestone.ref }).Count -eq 0) {
            $failures += "FAIL valid milestone baseline: milestone anchor artifact evidence was not preserved."
        }
        if (@($loadedBaseline.Baseline.evidence | Where-Object { $_.kind -eq "artifact" -and $_.ref -eq $loadedBaseline.Baseline.planning_record_refs[0].accepted_record_ref }).Count -eq 0) {
            $failures += "FAIL valid milestone baseline: accepted planning artifact evidence was not preserved."
        }
        if (-not [System.IO.Path]::IsPathRooted($loadedBaseline.Baseline.git.repository_root)) {
            $failures += "FAIL valid milestone baseline: git.repository_root was not persisted as an absolute path."
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
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-relative-repository-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot
    $relativeRepositoryRoot = Get-RelativePathFromModuleRepoRoot -TargetPath $tempRoot

    try {
        Push-Location -LiteralPath $env:TEMP
        try {
            $baseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-relative-repository-root" -MilestonePath "state/fixtures/valid/governed_work_object.milestone.valid.json" -PlanningRecordPaths @("state/fixtures/valid/planning_record.task.valid.json") -OperatorId "operator:admin" -AuthorityReason "Capture should resolve repository-scoped relative paths deterministically." -RepositoryRoot $relativeRepositoryRoot

            if ($baseline.git.repository_root -ne [System.IO.Path]::GetFullPath($tempRoot)) {
                $failures += "FAIL relative repository input resolution: repository_root did not resolve to the expected absolute path."
            }

            Write-Output "PASS relative repository input resolution: RepositoryRoot-relative capture paths resolve against the captured repository instead of the caller working directory."
            $validPassed += 1
        }
        finally {
            Pop-Location
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL relative repository input resolution harness: {0}" -f $_.Exception.Message)
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

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-detached-head-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        & git -C $tempRoot checkout --detach HEAD | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to detach HEAD in temp Git repository."
        }

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-detached-head" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the repository is in detached HEAD state." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL detached HEAD refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS detached HEAD refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL detached HEAD harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-untracked-dirty-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        Set-Content -LiteralPath (Join-Path $tempRoot "untracked.txt") -Value "untracked" -Encoding UTF8
        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-untracked" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because an untracked file makes the worktree dirty." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL untracked dirty-state refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS untracked dirty-state refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL untracked dirty-state harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-ignored-characterization-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        Set-Content -LiteralPath (Join-Path $tempRoot ".gitignore") -Value "ignored.tmp" -Encoding UTF8
        Invoke-GitCommitAll -Root $tempRoot -Message "add ignored file rule"
        Set-Content -LiteralPath (Join-Path $tempRoot "ignored.tmp") -Value "ignored" -Encoding UTF8

        $baseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-ignored-characterization" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Characterize current ignored-file cleanliness behavior without changing policy." -RepositoryRoot $tempRoot
        if ($baseline.git.working_tree_clean -ne $true) {
            $failures += "FAIL ignored-file cleanliness characterization: working_tree_clean was not true."
        }
        if (@($baseline.git.status_lines).Count -ne 0) {
            $failures += "FAIL ignored-file cleanliness characterization: ignored file appeared in captured status lines unexpectedly."
        }

        Write-Output "PASS ignored-file cleanliness characterization: ignored files do not block baseline capture under the current status policy."
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL ignored-file cleanliness characterization harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-accepted-status-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $planningRecord = Get-Content -LiteralPath $fixtureSet.PlanningRecordPath -Raw | ConvertFrom-Json
        $planningRecord.accepted_state.status = "working"
        Set-JsonFixtureDocument -Path $fixtureSet.PlanningRecordPath -Document $planningRecord
        Invoke-GitCommitAll -Root $tempRoot -Message "set accepted state to working"

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-accepted-status" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the planning record is not in accepted state." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL malformed accepted-state status refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS malformed accepted-state status refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL malformed accepted-state status harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-accepted-record-ref-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $planningRecord = Get-Content -LiteralPath $fixtureSet.PlanningRecordPath -Raw | ConvertFrom-Json
        $planningRecord.accepted_state.record_ref = ""
        Set-JsonFixtureDocument -Path $fixtureSet.PlanningRecordPath -Document $planningRecord
        Invoke-GitCommitAll -Root $tempRoot -Message "blank accepted record ref"

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-accepted-record-ref" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the accepted record ref is blank." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL malformed accepted-state record_ref refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS malformed accepted-state record_ref refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL malformed accepted-state record_ref harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-cross-milestone-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $alternateMilestonePath = Join-Path (Split-Path -Parent $fixtureSet.MilestonePath) "governed_work_object.milestone.other.valid.json"
        $alternateMilestone = Get-Content -LiteralPath $fixtureSet.MilestonePath -Raw | ConvertFrom-Json
        $alternateMilestone.object_id = "milestone-r5-002c-other"
        $alternateMilestone.title = "Alternate milestone for mismatch refusal"
        Set-JsonFixtureDocument -Path $alternateMilestonePath -Document $alternateMilestone
        Invoke-GitCommitAll -Root $tempRoot -Message "add alternate milestone anchor"

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-cross-milestone" -MilestonePath $alternateMilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the planning record does not belong to the anchored milestone." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL cross-milestone mismatch refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS cross-milestone mismatch refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL cross-milestone mismatch harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-parent-ref-mismatch-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $alternateMilestonePath = Join-Path (Split-Path -Parent $fixtureSet.MilestonePath) "governed_work_object.milestone.same-id.alt.json"
        $alternateMilestone = Get-Content -LiteralPath $fixtureSet.MilestonePath -Raw | ConvertFrom-Json
        $alternateMilestone.title = "Alternate milestone path with the same identity"
        Set-JsonFixtureDocument -Path $alternateMilestonePath -Document $alternateMilestone

        $acceptedRecord = Get-Content -LiteralPath $fixtureSet.AcceptedRecordPath -Raw | ConvertFrom-Json
        $acceptedRecord.parent.ref = $alternateMilestonePath
        Set-JsonFixtureDocument -Path $fixtureSet.AcceptedRecordPath -Document $acceptedRecord
        Invoke-GitCommitAll -Root $tempRoot -Message "redirect accepted parent ref to alternate milestone path"

        try {
            New-MilestoneBaselineRecord -BaselineId "baseline-r5-invalid-parent-ref-mismatch" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "This should fail because the accepted planning parent ref does not match the anchored milestone path." -RepositoryRoot $tempRoot | Out-Null
            $failures += "FAIL accepted planning parent ref mismatch refusal: capture succeeded unexpectedly."
        }
        catch {
            Write-Output ("PASS accepted planning parent ref mismatch refusal: {0}" -f $_.Exception.Message)
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
    $failures += ("FAIL accepted planning parent ref mismatch harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-repeat-id-" + [guid]::NewGuid().ToString("N"))
    $storePath = Join-Path $env:TEMP ("aioffice-r5-baseline-repeat-store-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $firstBaseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-repeat-id" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "First save" -RepositoryRoot $tempRoot -CapturedAt ([datetime]::Parse("2026-04-21T10:00:00Z").ToUniversalTime())
        $firstPath = Save-MilestoneBaselineRecord -Baseline $firstBaseline -StorePath $storePath

        $secondBaseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-repeat-id" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Second save" -RepositoryRoot $tempRoot -CapturedAt ([datetime]::Parse("2026-04-21T11:00:00Z").ToUniversalTime())
        $secondPath = Save-MilestoneBaselineRecord -Baseline $secondBaseline -StorePath $storePath
        $loadedBaseline = Get-MilestoneBaselineRecord -BaselineId "baseline-r5-repeat-id" -StorePath $storePath

        if ($firstPath -ne $secondPath) {
            $failures += "FAIL repeated baseline_id characterization: repeated save wrote to a different path unexpectedly."
        }
        if ($loadedBaseline.Baseline.authority.reason -ne "Second save") {
            $failures += "FAIL repeated baseline_id characterization: saved baseline did not reflect the second write."
        }
        if ($loadedBaseline.Baseline.captured_at -ne "2026-04-21T11:00:00Z") {
            $failures += "FAIL repeated baseline_id characterization: captured_at did not reflect overwrite behavior."
        }

        Write-Output "PASS repeated baseline_id characterization: current save behavior overwrites an existing baseline record with the same baseline_id."
        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $storePath) {
            Remove-Item -LiteralPath $storePath -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL repeated baseline_id characterization harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-relative-store-" + [guid]::NewGuid().ToString("N"))
    $storePath = Join-Path $env:TEMP ("aioffice-r5-baseline-relative-store-root-" + [guid]::NewGuid().ToString("N"))
    New-TempGitRepository -Root $tempRoot
    $fixtureSet = New-BaselineFixtureSet -Root $tempRoot

    try {
        $baseline = New-MilestoneBaselineRecord -BaselineId "baseline-r5-relative-store-paths" -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Characterize deterministic relative store and baseline path handling." -RepositoryRoot $tempRoot
        $relativeStorePath = Get-RelativePathFromModuleRepoRoot -TargetPath $storePath

        Push-Location -LiteralPath $env:TEMP
        try {
            $savedPath = Save-MilestoneBaselineRecord -Baseline $baseline -StorePath $relativeStorePath
            $relativeBaselinePath = Get-RelativePathFromModuleRepoRoot -TargetPath $savedPath
            $validation = Test-MilestoneBaselineRecordContract -BaselinePath $relativeBaselinePath
            $loadedBaseline = Get-MilestoneBaselineRecord -BaselineId $baseline.baseline_id -StorePath $relativeStorePath

            if ($validation.BaselinePath -ne $savedPath) {
                $failures += "FAIL relative store and baseline path resolution: validation did not resolve the saved baseline path deterministically."
            }
            if ($loadedBaseline.Validation.BaselinePath -ne $savedPath) {
                $failures += "FAIL relative store and baseline path resolution: baseline load did not resolve the saved baseline path deterministically."
            }

            Write-Output "PASS relative store and baseline path resolution: relative StorePath and BaselinePath inputs resolve from the module repository root deterministically."
            $validPassed += 1
        }
        finally {
            Pop-Location
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $storePath) {
            Remove-Item -LiteralPath $storePath -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL relative store and baseline path resolution harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-missing-git-" + [guid]::NewGuid().ToString("N"))
    $scriptPath = Join-Path $env:TEMP ("aioffice-r5-baseline-missing-git-" + [guid]::NewGuid().ToString("N") + ".ps1")

    try {
        $harness = New-PersistedBaselineHarness -Root $tempRoot -BaselineId "baseline-r5-missing-git"
        $runnerPath = (Get-Command powershell).Source
        @"
`$ErrorActionPreference = 'Stop'
`$env:PATH = ''
Import-Module '$modulePath' -Force
try {
    Test-MilestoneBaselineRecordContract -BaselinePath '$($harness.SavedPath)' | Out-Null
    Write-Output 'UNEXPECTED-SUCCESS'
    exit 1
}
catch {
    Write-Output `$_.Exception.Message
    exit 0
}
"@ | Set-Content -LiteralPath $scriptPath -Encoding UTF8

        $subprocessOutput = & $runnerPath -NoProfile -ExecutionPolicy Bypass -File $scriptPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            $failures += "FAIL missing Git CLI prerequisite refusal: subprocess exited unexpectedly."
        }
        elseif (($subprocessOutput -join [Environment]::NewLine) -notmatch "Milestone baseline requires Git CLI to be installed and callable\.") {
            $failures += "FAIL missing Git CLI prerequisite refusal: subprocess did not emit the explicit Git prerequisite message."
        }
        else {
            Write-Output "PASS missing Git CLI prerequisite refusal: Milestone baseline requires Git CLI to be installed and callable."
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $scriptPath) {
            Remove-Item -LiteralPath $scriptPath -Force
        }
    }
}
catch {
    $failures += ("FAIL missing Git CLI prerequisite refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-missing-planning-validator-module-" + [guid]::NewGuid().ToString("N"))
    $originalModuleState = Get-MilestoneBaselineModuleState

    try {
        $harness = New-PersistedBaselineHarness -Root $tempRoot -BaselineId "baseline-r5-missing-planning-validator-module"
        $missingModulePath = Join-Path $tempRoot "missing\PlanningRecordStorage.psm1"

        $milestoneBaselineModule.SessionState.PSVariable.Set("planningRecordStorageModulePath", $missingModulePath)
        $milestoneBaselineModule.SessionState.PSVariable.Set("testPlanningRecordContract", $null)

        try {
            Test-MilestoneBaselineRecordContract -BaselinePath $harness.SavedPath | Out-Null
            $failures += "FAIL missing planning-record validator module refusal: baseline validated unexpectedly."
        }
        catch {
            if ($_.Exception.Message -notmatch "Milestone baseline requires dependency module 'PlanningRecordStorage'") {
                $failures += ("FAIL missing planning-record validator module refusal: unexpected message '{0}'." -f $_.Exception.Message)
            }
            else {
                Write-Output ("PASS missing planning-record validator module refusal: {0}" -f $_.Exception.Message)
                $invalidRejected += 1
            }
        }
    }
    finally {
        Restore-MilestoneBaselineModuleState -State $originalModuleState
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL missing planning-record validator module refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-baseline-missing-governed-validator-command-" + [guid]::NewGuid().ToString("N"))
    $fakeModulePath = Join-Path $env:TEMP ("aioffice-r5-baseline-fake-governed-validator-" + [guid]::NewGuid().ToString("N") + ".psm1")
    $originalModuleState = Get-MilestoneBaselineModuleState

    try {
        @"
function Get-PlaceholderCommand {
    return 'placeholder'
}

Export-ModuleMember -Function Get-PlaceholderCommand
"@ | Set-Content -LiteralPath $fakeModulePath -Encoding UTF8

        $harness = New-PersistedBaselineHarness -Root $tempRoot -BaselineId "baseline-r5-missing-governed-validator-command"
        $milestoneBaselineModule.SessionState.PSVariable.Set("governedWorkObjectValidationModulePath", $fakeModulePath)
        $milestoneBaselineModule.SessionState.PSVariable.Set("testGovernedWorkObjectContract", $null)

        try {
            Test-MilestoneBaselineRecordContract -BaselinePath $harness.SavedPath | Out-Null
            $failures += "FAIL missing governed-work-object validator command refusal: baseline validated unexpectedly."
        }
        catch {
            if ($_.Exception.Message -notmatch "Milestone baseline requires dependency command 'Test-GovernedWorkObjectContract'") {
                $failures += ("FAIL missing governed-work-object validator command refusal: unexpected message '{0}'." -f $_.Exception.Message)
            }
            else {
                Write-Output ("PASS missing governed-work-object validator command refusal: {0}" -f $_.Exception.Message)
                $invalidRejected += 1
            }
        }
    }
    finally {
        Restore-MilestoneBaselineModuleState -State $originalModuleState
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $fakeModulePath) {
            Remove-Item -LiteralPath $fakeModulePath -Force
        }
    }
}
catch {
    $failures += ("FAIL missing governed-work-object validator command refusal harness: {0}" -f $_.Exception.Message)
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored repository_root" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.repository_root = (Join-Path $Harness.Root "missing-repository-root")
}

Invoke-TamperedBaselineRefusalTest -Label "relative stored repository_root" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.repository_root = "relative/repository-root"
}

Invoke-TamperedBaselineRefusalTest -Label "planning_record evidence mismatch" -Tamper {
    param($PersistedBaseline, $Harness)

    $planningRecordEvidence = @($PersistedBaseline.evidence | Where-Object { $_.kind -eq "planning_record" })[0]
    $planningRecordEvidence.ref = $PersistedBaseline.milestone.ref
}

Invoke-TamperedBaselineRefusalTest -Label "accepted planning artifact evidence missing" -Tamper {
    param($PersistedBaseline, $Harness)

    $acceptedRef = $PersistedBaseline.planning_record_refs[0].accepted_record_ref
    $PersistedBaseline.evidence = @($PersistedBaseline.evidence | Where-Object { -not ($_.kind -eq "artifact" -and $_.ref -eq $acceptedRef) })
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored branch" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.branch = "invalid branch name"
}

Invoke-TamperedBaselineRefusalTest -Label "invalid stored head_commit" -Tamper {
    param($PersistedBaseline, $Harness)

    $PersistedBaseline.git.head_commit = "12345"
}

Invoke-TamperedBaselineRefusalTest -Label "stored head_commit/tree_id mismatch" -Tamper {
    param($PersistedBaseline, $Harness)

    Set-Content -LiteralPath (Join-Path $Harness.Root "alternate-tree.txt") -Value "alternate tree" -Encoding UTF8
    Invoke-GitCommitAll -Root $Harness.Root -Message "add alternate tree for mismatch refusal"
    $PersistedBaseline.git.tree_id = (& git -C $Harness.Root rev-parse "HEAD^{tree}").Trim()
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
