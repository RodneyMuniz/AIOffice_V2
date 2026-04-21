$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$restoreGateModule = Import-Module (Join-Path $repoRoot "tools\RestoreGate.psm1") -Force -PassThru
$milestoneBaselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru

$testRestoreGateRequestContract = $restoreGateModule.ExportedCommands["Test-RestoreGateRequestContract"]
$testRestoreGateResultContract = $restoreGateModule.ExportedCommands["Test-RestoreGateResultContract"]
$invokeRestoreGate = $restoreGateModule.ExportedCommands["Invoke-RestoreGate"]
$saveRestoreGateResult = $restoreGateModule.ExportedCommands["Save-RestoreGateResult"]
$getRestoreGateResult = $restoreGateModule.ExportedCommands["Get-RestoreGateResult"]
$newMilestoneBaselineRecord = $milestoneBaselineModule.ExportedCommands["New-MilestoneBaselineRecord"]
$saveMilestoneBaselineRecord = $milestoneBaselineModule.ExportedCommands["Save-MilestoneBaselineRecord"]

$validMilestone = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"
$validProject = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.project.valid.json"
$validPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_record.task.valid.json"
$validAcceptedPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\accepted\planning_record.task.valid.accepted.json"
$validWorkingPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\working\planning_record.task.valid.working.json"

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Set-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

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
    Invoke-GitCommitAll -Root $Root -Message "add restore gate fixtures"

    return [pscustomobject]@{
        MilestonePath      = Join-Path $fixtureRoot "governed_work_object.milestone.valid.json"
        PlanningRecordPath = Join-Path $fixtureRoot "planning_record.task.valid.json"
    }
}

function New-RestoreGateHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$BaselineId
    )

    New-TempGitRepository -Root $Root
    $fixtureSet = New-BaselineFixtureSet -Root $Root
    $baseline = & $newMilestoneBaselineRecord -BaselineId $BaselineId -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:admin" -AuthorityReason "Validate bounded restore target and authority before any rollback execution." -RepositoryRoot $Root -CapturedAt ([datetime]::Parse("2026-04-21T12:00:00Z").ToUniversalTime())
    $storePath = Join-Path $env:TEMP ("aioffice-r5-003-baseline-store-" + [guid]::NewGuid().ToString("N"))
    $savedBaselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $storePath

    return [pscustomobject]@{
        Root             = $Root
        FixtureSet       = $fixtureSet
        Baseline         = $baseline
        StorePath        = $storePath
        SavedBaselinePath = $savedBaselinePath
    }
}

function New-RestoreGateRequestObject {
    param(
        [Parameter(Mandatory = $true)]
        $Harness,
        [string]$GateRequestId = "restore-gate-r5-003-valid-001",
        [string]$TargetRepositoryRoot = $Harness.Root
    )

    return [pscustomobject]@{
        contract_version      = "v1"
        record_type           = "restore_gate_request"
        gate_request_id       = $GateRequestId
        target_repository_root = $TargetRepositoryRoot
        restore_target        = [pscustomobject]@{
            baseline_id        = $Harness.Baseline.baseline_id
            baseline_ref       = $Harness.SavedBaselinePath
            milestone_object_id = $Harness.Baseline.milestone.object_id
            branch             = $Harness.Baseline.git.branch
            head_commit        = $Harness.Baseline.git.head_commit
            tree_id            = $Harness.Baseline.git.tree_id
        }
        requested_at          = "2026-04-21T12:05:00Z"
        requested_by          = "operator:admin"
        authority             = [pscustomobject]@{
            status      = "approved"
            operator_id = "operator:admin"
            approved_by = "operator:admin"
            approved_at = "2026-04-21T12:05:00Z"
            reason      = "Validate a bounded restore target and authority model without executing rollback."
        }
        notes                 = "Restore gate request for bounded rollback foundation validation only."
    }
}

function Save-RequestObject {
    param(
        [Parameter(Mandatory = $true)]
        $RequestObject,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $RequestObject | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-ExternalRequestPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Join-Path $env:TEMP ("{0}-{1}.json" -f $Label, [guid]::NewGuid().ToString("N")))
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-allow-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-valid-001"
        $request = New-RestoreGateRequestObject -Harness $harness
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-allow-request"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $requestCheck = & $testRestoreGateRequestContract -GateRequestPath $requestPath
        if ($requestCheck.GateRequestId -ne $request.gate_request_id) {
            $failures += "FAIL restore gate request contract: gate_request_id did not validate correctly."
        }

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "allow") {
            $failures += "FAIL restore gate allow path: decision was not allow."
        }
        if (-not $result.preconditions.authority -or -not $result.preconditions.restore_target -or -not $result.preconditions.repository_binding -or -not $result.preconditions.workspace_safety) {
            $failures += "FAIL restore gate allow path: not all preconditions were satisfied."
        }

        $resultStore = Join-Path $tempRoot "gate-results"
        $savedResultPath = & $saveRestoreGateResult -GateResult $result -StorePath $resultStore
        $resultCheck = & $testRestoreGateResultContract -GateResultPath $savedResultPath
        $reloadedResult = & $getRestoreGateResult -Path $savedResultPath

        if ($resultCheck.Decision -ne "allow") {
            $failures += "FAIL restore gate allow path: saved result did not validate as allow."
        }
        if ($reloadedResult.restore_target.repository_root -ne $harness.Root) {
            $failures += "FAIL restore gate allow path: restore_target.repository_root did not persist the baseline repository root."
        }
        if (-not $reloadedResult.current_repository_state.working_tree_clean -or -not $reloadedResult.current_repository_state.attached_head) {
            $failures += "FAIL restore gate allow path: current repository safety state did not persist."
        }

        Write-Output ("PASS restore gate allow path: {0}" -f $savedResultPath)
        $validPassed += 1
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL restore gate allow path harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-pending-authority-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-pending-authority"
        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-pending-authority"
        $request.authority.status = "pending"
        $request.authority.approved_by = $null
        $request.authority.approved_at = $null
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-pending-authority"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "authority_missing")) {
            $failures += "FAIL pending authority refusal: request did not block with authority_missing."
        }
        else {
            Write-Output ("PASS pending authority refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL pending authority refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $baselineRoot = Join-Path $env:TEMP ("aioffice-r5-003-cross-repo-baseline-" + [guid]::NewGuid().ToString("N"))
    $otherRepoRoot = Join-Path $env:TEMP ("aioffice-r5-003-cross-repo-target-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $baselineRoot -BaselineId "baseline-r5-003-cross-repo"
        New-TempGitRepository -Root $otherRepoRoot
        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-cross-repo" -TargetRepositoryRoot $otherRepoRoot
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-cross-repo"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "repository_binding_mismatch")) {
            $failures += "FAIL cross-repo repository binding refusal: request did not block with repository_binding_mismatch."
        }
        else {
            Write-Output ("PASS cross-repo repository binding refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        foreach ($root in @($baselineRoot, $otherRepoRoot)) {
            if (Test-Path -LiteralPath $root) {
                Remove-Item -LiteralPath $root -Recurse -Force
            }
        }
    }
}
catch {
    $failures += ("FAIL cross-repo repository binding harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-dirty-workspace-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-dirty-workspace"
        Set-Content -LiteralPath (Join-Path $tempRoot "untracked.txt") -Value "dirty" -Encoding UTF8
        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-dirty-workspace"
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-dirty-workspace"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "workspace_dirty")) {
            $failures += "FAIL dirty workspace refusal: request did not block with workspace_dirty."
        }
        else {
            Write-Output ("PASS dirty workspace refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL dirty workspace refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-detached-head-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-detached-head"
        & git -C $tempRoot checkout --detach HEAD | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to detach HEAD in temp Git repository."
        }

        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-detached-head"
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-detached-head"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "detached_head")) {
            $failures += "FAIL detached head refusal: request did not block with detached_head."
        }
        else {
            Write-Output ("PASS detached head refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL detached head refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-identity-mismatch-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-identity-mismatch"
        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-identity-mismatch"
        $request.restore_target.head_commit = ("f" * 40)
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-identity-mismatch"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "restore_target_identity_mismatch")) {
            $failures += "FAIL restore target identity mismatch refusal: request did not block with restore_target_identity_mismatch."
        }
        else {
            Write-Output ("PASS restore target identity mismatch refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL restore target identity mismatch harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-missing-baseline-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-missing-baseline"
        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-missing-baseline"
        $request.restore_target.baseline_ref = (Join-Path $tempRoot "missing-baseline.json")
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-missing-baseline"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "restore_target_missing")) {
            $failures += "FAIL missing baseline refusal: request did not block with restore_target_missing."
        }
        else {
            Write-Output ("PASS missing baseline refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL missing baseline refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-003-invalid-baseline-" + [guid]::NewGuid().ToString("N"))
    $requestPath = $null
    $harness = $null

    try {
        $harness = New-RestoreGateHarness -Root $tempRoot -BaselineId "baseline-r5-003-invalid-baseline"
        $tamperedBaseline = Get-JsonDocument -Path $harness.SavedBaselinePath
        $tamperedBaseline.git.tree_id = "not-a-tree-id"
        Set-JsonDocument -Path $harness.SavedBaselinePath -Document $tamperedBaseline

        $request = New-RestoreGateRequestObject -Harness $harness -GateRequestId "restore-gate-r5-003-invalid-baseline"
        $requestPath = New-ExternalRequestPath -Label "aioffice-r5-003-invalid-baseline"
        Save-RequestObject -RequestObject $request -Path $requestPath

        $result = & $invokeRestoreGate -GateRequestPath $requestPath
        if ($result.decision -ne "blocked" -or (@($result.block_reasons.code) -notcontains "restore_target_invalid")) {
            $failures += "FAIL invalid baseline refusal: request did not block with restore_target_invalid."
        }
        else {
            Write-Output ("PASS invalid baseline refusal: {0}" -f ($result.block_reasons.code -join ", "))
            $invalidRejected += 1
        }
    }
    finally {
        if ($null -ne $requestPath -and (Test-Path -LiteralPath $requestPath)) {
            Remove-Item -LiteralPath $requestPath -Force
        }
        if ($null -ne $harness -and (Test-Path -LiteralPath $harness.StorePath)) {
            Remove-Item -LiteralPath $harness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL invalid baseline refusal harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Restore gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All restore gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
