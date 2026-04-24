$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$rollbackDrillModule = Import-Module (Join-Path $repoRoot "tools\MilestoneRollbackDrill.psm1") -Force -PassThru
$rollbackPlanModule = Import-Module (Join-Path $repoRoot "tools\MilestoneRollbackPlan.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru

$testRollbackPlanRequestContract = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanRequestContract"]
$invokeRollbackPlan = $rollbackPlanModule.ExportedCommands["Invoke-MilestoneRollbackPlan"]
$testRollbackDrillAuthorizationContract = $rollbackDrillModule.ExportedCommands["Test-MilestoneRollbackDrillAuthorizationContract"]
$testRollbackDrillResultContract = $rollbackDrillModule.ExportedCommands["Test-MilestoneRollbackDrillResultContract"]
$testRollbackDrillResultObject = $rollbackDrillModule.ExportedCommands["Test-MilestoneRollbackDrillResultObject"]
$invokeRollbackDrill = $rollbackDrillModule.ExportedCommands["Invoke-MilestoneRollbackDrill"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$testMilestoneAutocycleBaselineBindingContract = $baselineModule.ExportedCommands["Test-MilestoneAutocycleBaselineBindingContract"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]

$requestFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\rollback_plan_request.valid.json"
$authorizationFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\rollback_drill_authorization.valid.json"
$proposalFixtureSource = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle"

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return (ConvertFrom-Json ($Object | ConvertTo-Json -Depth 20))
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Path -Encoding ascii
    return $Path
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

    & git -C $Root config core.autocrlf false | Out-Null
    & git -C $Root config core.safecrlf false | Out-Null
    & git -C $Root config user.email "codex@example.com" | Out-Null
    & git -C $Root config user.name "Codex" | Out-Null

    Set-Content -LiteralPath (Join-Path $Root "README.md") -Value "# Temp repo" -Encoding UTF8
    & git -C $Root add README.md | Out-Null
    & git -C $Root commit -m "initial temp commit" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create initial temp Git commit."
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

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $output = & git -C $Root @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "$Context failed."
    }

    return ([string]::Join([Environment]::NewLine, @($output))).Trim()
}

function Initialize-RollbackDrillHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ParentRoot
    )

    $root = Join-Path $ParentRoot "AIOffice_V2"
    New-TempGitRepository -Root $root

    $fixtureDestinationParent = Join-Path $root "state\fixtures\valid"
    New-Item -ItemType Directory -Path $fixtureDestinationParent -Force | Out-Null
    Copy-Item -LiteralPath $proposalFixtureSource -Destination $fixtureDestinationParent -Recurse -Force
    Invoke-GitCommitAll -Root $root -Message "add milestone autocycle fixtures"

    $proposalPath = Join-Path $root "state\fixtures\valid\milestone_autocycle\proposal.expected.json"
    $freezeOutputRoot = Join-Path $root "state\autocycle\cycle"
    New-Item -ItemType Directory -Path $freezeOutputRoot -Force | Out-Null
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r7-007-rollback-drill-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r7-007-approved-001" -FreezeId "freeze-r7-007-approved-001" -DecidedAt ([datetime]::Parse("2026-04-24T04:00:00Z").ToUniversalTime()) -Notes "Approve one bounded milestone freeze so the rollback drill can reuse baseline-binding truth without claiming broader rollback execution."
    Invoke-GitCommitAll -Root $root -Message "commit approved freeze artifacts"

    $bindingOutputRoot = Join-Path $root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r7-007-valid-001" -BaselineId "baseline-r7-007-valid-001" -BoundAt ([datetime]::Parse("2026-04-24T04:05:00Z").ToUniversalTime())
    $bindingValidation = & $testMilestoneAutocycleBaselineBindingContract -BindingPath $bindingFlow.BindingPath

    $rollbackPlanPath = Join-Path $ParentRoot "rollback_plan.valid.json"
    $planFlow = & $invokeRollbackPlan -RollbackPlanRequestPath $requestFixture -BaselineBindingPath $bindingValidation.BindingPath -RollbackPlanPath $rollbackPlanPath -RollbackPlanId "rollback-plan-r7-007-001" -PlannedAt ([datetime]::Parse("2026-04-24T04:10:00Z").ToUniversalTime())
    $rollbackPlan = Get-JsonDocument -Path $planFlow.RollbackPlanPath

    Set-Content -LiteralPath (Join-Path $root "drift.txt") -Value "bounded disposable drill drift" -Encoding ascii
    Invoke-GitCommitAll -Root $root -Message "add post-plan drift commit"

    $sourceHeadAfterDrift = Get-GitTrimmedValue -Root $root -Arguments @("rev-parse", "HEAD") -Context "Temp repo HEAD after drift"
    $sourceTreeAfterDrift = Get-GitTrimmedValue -Root $root -Arguments @("rev-parse", "HEAD^{tree}") -Context "Temp repo tree after drift"
    if ($sourceHeadAfterDrift -eq $rollbackPlan.rollback_target.head_commit -and $sourceTreeAfterDrift -eq $rollbackPlan.rollback_target.tree_id) {
        throw "Rollback drill harness failed to produce a post-plan Git-context transition."
    }

    return [pscustomobject]@{
        Root = $root
        BindingPath = $bindingValidation.BindingPath
        BaselinePath = $bindingValidation.BaselinePath
        RollbackPlanPath = $planFlow.RollbackPlanPath
        RollbackPlan = $rollbackPlan
        SourceHeadAfterDrift = $sourceHeadAfterDrift
        SourceTreeAfterDrift = $sourceTreeAfterDrift
    }
}

function Assert-InvokeRejected {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath,
        [Parameter(Mandatory = $true)]
        [string]$RollbackDrillAuthorizationPath,
        [Parameter(Mandatory = $true)]
        [string]$DrillResultPath,
        [Parameter(Mandatory = $true)]
        [string]$DisposableEnvironmentRoot,
        [Parameter(Mandatory = $true)]
        [string]$DisposableBranchName
    )

    try {
        & $invokeRollbackDrill -RollbackPlanPath $RollbackPlanPath -RollbackDrillAuthorizationPath $RollbackDrillAuthorizationPath -DrillResultPath $DrillResultPath -DisposableEnvironmentRoot $DisposableEnvironmentRoot -DisposableBranchName $DisposableBranchName | Out-Null
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Name)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Name, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

try {
    $requestValidation = & $testRollbackPlanRequestContract -RollbackPlanRequestPath $requestFixture
    $authorizationValidation = & $testRollbackDrillAuthorizationContract -RollbackDrillAuthorizationPath $authorizationFixture
    if ($authorizationValidation.RollbackPlanId -ne "rollback-plan-r7-007-001") {
        $failures += "FAIL valid rollback drill authorization: rollback plan id drifted."
    }
    Write-Output ("PASS valid rollback drill authorization: {0} -> {1}" -f (Resolve-Path -Relative $authorizationFixture), $authorizationValidation.RollbackDrillAuthorizationId)
    $validPassed += 1

    $tempRoot = Join-Path $env:TEMP ("aioffice-r7-007-" + [guid]::NewGuid().ToString("N"))
    $disposableEnvironmentRoot = Join-Path $tempRoot "disposable-worktree"
    try {
        $harness = Initialize-RollbackDrillHarness -ParentRoot $tempRoot
        if ($requestValidation.LedgerId -ne $harness.RollbackPlan.source_continuity.ledger_ref.ledger_id) {
            $failures += "FAIL rollback drill harness: rollback plan did not preserve the expected continuity ledger id."
        }

        $drillResultPath = Join-Path $tempRoot "rollback_drill.valid.json"
        $drillFlow = & $invokeRollbackDrill -RollbackPlanPath $harness.RollbackPlanPath -RollbackDrillAuthorizationPath $authorizationFixture -DrillResultPath $drillResultPath -DisposableEnvironmentRoot $disposableEnvironmentRoot -DisposableBranchName "rollback-drill-r7-007-valid"
        $drillValidation = & $testRollbackDrillResultContract -DrillResultPath $drillFlow.DrillResultPath
        $drillResult = Get-JsonDocument -Path $drillFlow.DrillResultPath

        if ($drillFlow.SourceArtifacts.SourceHeadBefore -ne $harness.SourceHeadAfterDrift -or $drillFlow.SourceArtifacts.SourceHeadAfter -ne $harness.SourceHeadAfterDrift) {
            $failures += "FAIL valid rollback drill: primary worktree HEAD drifted during disposable drill execution."
        }
        if ($drillValidation.TargetHeadCommit -ne $harness.RollbackPlan.rollback_target.head_commit -or $drillValidation.TargetTreeId -ne $harness.RollbackPlan.rollback_target.tree_id) {
            $failures += "FAIL valid rollback drill: target Git context did not stay aligned with the rollback plan."
        }
        if ($drillResult.drill_environment.environment_root -eq $harness.Root) {
            $failures += "FAIL valid rollback drill: environment root collapsed onto the primary worktree."
        }
        Write-Output ("PASS valid rollback drill: {0} -> {1}" -f $drillValidation.RollbackPlanId, $drillValidation.EnvironmentScope)
        $validPassed += 1

        $invalidAuthNoApproval = Copy-JsonObject -Object (Get-JsonDocument -Path $authorizationFixture)
        $invalidAuthNoApproval.git_mutation_approved = $false
        $invalidAuthNoApprovalPath = Write-JsonDocument -Document $invalidAuthNoApproval -Path (Join-Path $tempRoot "invalid\missing-operator-approval.authorization.json")

        $invalidAuthBadScope = Copy-JsonObject -Object (Get-JsonDocument -Path $authorizationFixture)
        $invalidAuthBadScope.approved_environment_scope = "disposable_branch"
        $invalidAuthBadScopePath = Write-JsonDocument -Document $invalidAuthBadScope -Path (Join-Path $tempRoot "invalid\invalid-environment-scope.authorization.json")

        $invalidPlanRepositoryMismatch = Copy-JsonObject -Object $harness.RollbackPlan
        $invalidPlanRepositoryMismatch.repository.repository_name = "OtherRepo"
        $invalidPlanRepositoryMismatchPath = Write-JsonDocument -Document $invalidPlanRepositoryMismatch -Path (Join-Path $tempRoot "invalid\repository-mismatch.rollback_plan.json")

        $invalidPlanTargetMismatch = Copy-JsonObject -Object $harness.RollbackPlan
        $invalidPlanTargetMismatch.rollback_target.head_commit = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        $invalidPlanTargetMismatchPath = Write-JsonDocument -Document $invalidPlanTargetMismatch -Path (Join-Path $tempRoot "invalid\target-git-context-mismatch.rollback_plan.json")

        $invalidPlanMalformed = Copy-JsonObject -Object $harness.RollbackPlan
        $invalidPlanMalformed.PSObject.Properties.Remove("rollback_target")
        $invalidPlanMalformedPath = Write-JsonDocument -Document $invalidPlanMalformed -Path (Join-Path $tempRoot "invalid\malformed-rollback-plan.rollback_plan.json")

        $invalidPlanExecutionState = Copy-JsonObject -Object $harness.RollbackPlan
        $invalidPlanExecutionState.execution_state = "executed"
        $invalidPlanExecutionStatePath = Write-JsonDocument -Document $invalidPlanExecutionState -Path (Join-Path $tempRoot "invalid\execution-state-contradiction.rollback_plan.json")

        $invalidCases = @(
            @{
                Name = "primary-worktree-target"
                RollbackPlanPath = $harness.RollbackPlanPath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\primary-worktree-target.result.json")
                DisposableEnvironmentRoot = $harness.Root
                DisposableBranchName = "rollback-drill-r7-007-invalid-001"
            },
            @{
                Name = "missing-explicit-operator-approval"
                RollbackPlanPath = $harness.RollbackPlanPath
                AuthorizationPath = $invalidAuthNoApprovalPath
                DrillResultPath = (Join-Path $tempRoot "invalid\missing-explicit-operator-approval.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\missing-explicit-operator-approval.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-002"
            },
            @{
                Name = "invalid-environment-scope"
                RollbackPlanPath = $harness.RollbackPlanPath
                AuthorizationPath = $invalidAuthBadScopePath
                DrillResultPath = (Join-Path $tempRoot "invalid\invalid-environment-scope.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\invalid-environment-scope.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-003"
            },
            @{
                Name = "repository-mismatch"
                RollbackPlanPath = $invalidPlanRepositoryMismatchPath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\repository-mismatch.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\repository-mismatch.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-004"
            },
            @{
                Name = "target-git-context-mismatch"
                RollbackPlanPath = $invalidPlanTargetMismatchPath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\target-git-context-mismatch.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\target-git-context-mismatch.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-005"
            },
            @{
                Name = "malformed-rollback-plan-artifact"
                RollbackPlanPath = $invalidPlanMalformedPath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\malformed-rollback-plan-artifact.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\malformed-rollback-plan-artifact.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-006"
            },
            @{
                Name = "destructive-drill-path"
                RollbackPlanPath = $harness.RollbackPlanPath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\destructive-drill-path.result.json")
                DisposableEnvironmentRoot = (Join-Path $harness.Root "nested\disposable-worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-007"
            },
            @{
                Name = "execution-state-contradiction"
                RollbackPlanPath = $invalidPlanExecutionStatePath
                AuthorizationPath = $authorizationFixture
                DrillResultPath = (Join-Path $tempRoot "invalid\execution-state-contradiction.result.json")
                DisposableEnvironmentRoot = (Join-Path $tempRoot "invalid\execution-state-contradiction.worktree")
                DisposableBranchName = "rollback-drill-r7-007-invalid-008"
            }
        )

        foreach ($invalidCase in @($invalidCases)) {
            Assert-InvokeRejected -Name $invalidCase.Name -RollbackPlanPath $invalidCase.RollbackPlanPath -RollbackDrillAuthorizationPath $invalidCase.AuthorizationPath -DrillResultPath $invalidCase.DrillResultPath -DisposableEnvironmentRoot $invalidCase.DisposableEnvironmentRoot -DisposableBranchName $invalidCase.DisposableBranchName
        }

        $invalidDrillResult = Copy-JsonObject -Object $drillResult
        $invalidDrillResult.execution_state = "pending"
        try {
            & $testRollbackDrillResultObject -RollbackDrillResult $invalidDrillResult -SourceLabel "malformed-drill-result-state" | Out-Null
            $failures += "FAIL invalid: malformed-drill-result-state was accepted unexpectedly."
        }
        catch {
            Write-Output ("PASS invalid: malformed-drill-result-state -> {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $disposableEnvironmentRoot) {
            & git -C $harness.Root worktree remove --force $disposableEnvironmentRoot 2>$null | Out-Null
        }

        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL rollback drill harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone rollback drill tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone rollback drill tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
