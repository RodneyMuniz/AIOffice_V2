$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$rollbackPlanModule = Import-Module (Join-Path $repoRoot "tools\MilestoneRollbackPlan.psm1") -Force -PassThru
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru

$testRollbackPlanRequestContract = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanRequestContract"]
$testRollbackPlanContract = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanContract"]
$testRollbackPlanObject = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanObject"]
$invokeRollbackPlan = $rollbackPlanModule.ExportedCommands["Invoke-MilestoneRollbackPlan"]
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$testMilestoneAutocycleBaselineBindingContract = $baselineModule.ExportedCommands["Test-MilestoneAutocycleBaselineBindingContract"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]

$requestFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\rollback_plan_request.valid.json"
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

function Initialize-BaselineBindingHarness {
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
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r7-006-rollback-plan-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r7-006-approved-001" -FreezeId "freeze-r7-006-approved-001" -DecidedAt ([datetime]::Parse("2026-04-24T01:00:00Z").ToUniversalTime()) -Notes "Approve one bounded milestone freeze so the rollback plan can reuse baseline-binding truth without executing rollback."
    Invoke-GitCommitAll -Root $root -Message "commit approved freeze artifacts"

    $bindingOutputRoot = Join-Path $root "state\autocycle\baseline_binding"
    $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $approvalFlow.FreezePath -RepositoryRoot $root -OutputRoot $bindingOutputRoot -BindingId "baseline-binding-r7-006-valid-001" -BaselineId "baseline-r7-006-valid-001" -BoundAt ([datetime]::Parse("2026-04-24T01:10:00Z").ToUniversalTime())
    $bindingValidation = & $testMilestoneAutocycleBaselineBindingContract -BindingPath $bindingFlow.BindingPath

    return [pscustomobject]@{
        Root = $root
        BindingPath = $bindingValidation.BindingPath
        BaselinePath = $bindingValidation.BaselinePath
        BindingId = $bindingValidation.BindingId
        BaselineId = $bindingValidation.BaselineId
    }
}

try {
    $requestValidation = & $testRollbackPlanRequestContract -RollbackPlanRequestPath $requestFixture
    Write-Output ("PASS valid rollback plan request: {0} -> {1}" -f (Resolve-Path -Relative $requestFixture), $requestValidation.RollbackPlanRequestId)
    $validPassed += 1

    $tempRoot = Join-Path $env:TEMP ("aioffice-r7-006-" + [guid]::NewGuid().ToString("N"))
    try {
        $harness = Initialize-BaselineBindingHarness -ParentRoot $tempRoot
        $planPath = Join-Path $tempRoot "rollback_plan.valid.json"
        $planFlow = & $invokeRollbackPlan -RollbackPlanRequestPath $requestFixture -BaselineBindingPath $harness.BindingPath -RollbackPlanPath $planPath -RollbackPlanId "rollback-plan-r7-006-valid-001" -PlannedAt ([datetime]::Parse("2026-04-24T01:35:00Z").ToUniversalTime())
        $planValidation = & $testRollbackPlanContract -RollbackPlanPath $planFlow.RollbackPlanPath
        $planDocument = Get-JsonDocument -Path $planFlow.RollbackPlanPath

        Write-Output ("PASS valid rollback plan: {0} -> {1}" -f $planValidation.LedgerId, $planValidation.BaselineId)
        if ($planDocument.execution_state -ne "not_executed") {
            $failures += "FAIL valid rollback plan: execution_state drifted."
        }
        if ($planDocument.operator_approval.approved_for_execution) {
            $failures += "FAIL valid rollback plan: approved_for_execution was true."
        }
        if ($planDocument.environment_constraints.primary_worktree_execution -ne "refused") {
            $failures += "FAIL valid rollback plan: primary_worktree_execution was not refused."
        }
        $validPassed += 1

        $validPlan = Get-JsonDocument -Path $planFlow.RollbackPlanPath
        $invalidCases = @(
            @{
                Name = "missing-target-baseline-ref"
                Mutate = {
                    param($Document)
                    $Document.rollback_target.baseline_ref.baseline_path = (Join-Path $env:TEMP "missing-baseline-r7-006.json")
                    return $Document
                }
            },
            @{
                Name = "invalid-target-scope"
                Mutate = {
                    param($Document)
                    $Document.rollback_target.target_scope = "primary_worktree_reset"
                    return $Document
                }
            },
            @{
                Name = "invalid-environment-scope"
                Mutate = {
                    param($Document)
                    $Document.environment_constraints.allowed_environment_scope = "primary_worktree"
                    return $Document
                }
            },
            @{
                Name = "repository-mismatch"
                Mutate = {
                    param($Document)
                    $Document.repository.repository_name = "OtherRepo"
                    return $Document
                }
            },
            @{
                Name = "target-git-context-mismatch"
                Mutate = {
                    param($Document)
                    $Document.rollback_target.head_commit = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                    return $Document
                }
            },
            @{
                Name = "missing-operator-approval-requirement"
                Mutate = {
                    param($Document)
                    $Document.operator_approval.approval_required = $false
                    return $Document
                }
            },
            @{
                Name = "execution-implying-state"
                Mutate = {
                    param($Document)
                    $Document.execution_state = "executed"
                    return $Document
                }
            },
            @{
                Name = "continuity-segment-identity-mismatch"
                Mutate = {
                    param($Document)
                    $Document.source_continuity.successor_segment_id = "segment-r7-006-other-001"
                    return $Document
                }
            },
            @{
                Name = "malformed-rollback-plan-state"
                Mutate = {
                    param($Document)
                    $Document.PSObject.Properties.Remove("rollback_target")
                    return $Document
                }
            }
        )

        foreach ($invalidCase in @($invalidCases)) {
            $invalidPlan = Copy-JsonObject -Object $validPlan
            $invalidPlan = & $invalidCase.Mutate $invalidPlan

            try {
                & $testRollbackPlanObject -RollbackPlan $invalidPlan -SourceLabel $invalidCase.Name | Out-Null
                $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $invalidCase.Name)
            }
            catch {
                Write-Output ("PASS invalid: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
                $invalidRejected += 1
            }
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL rollback plan harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone rollback plan tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone rollback plan tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
