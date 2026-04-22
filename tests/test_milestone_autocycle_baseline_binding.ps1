$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$baselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$invokeMilestoneFreezeBaselineBindingFlow = $baselineModule.ExportedCommands["Invoke-MilestoneFreezeBaselineBindingFlow"]
$testMilestoneAutocycleBaselineBindingContract = $baselineModule.ExportedCommands["Test-MilestoneAutocycleBaselineBindingContract"]
$invokeMilestoneAutocycleApprovalFlow = $freezeModule.ExportedCommands["Invoke-MilestoneAutocycleApprovalFlow"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
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
        [string]$Root
    )

    New-TempGitRepository -Root $Root
    $fixtureSource = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle"
    $fixtureDestinationParent = Join-Path $Root "state\fixtures\valid"
    New-Item -ItemType Directory -Path $fixtureDestinationParent -Force | Out-Null
    Copy-Item -LiteralPath $fixtureSource -Destination $fixtureDestinationParent -Recurse -Force
    Invoke-GitCommitAll -Root $Root -Message "add milestone autocycle fixtures"

    $proposalPath = Join-Path $Root "state\fixtures\valid\milestone_autocycle\proposal.expected.json"
    $freezeOutputRoot = Join-Path $Root "state\autocycle\cycle"
    New-Item -ItemType Directory -Path $freezeOutputRoot -Force | Out-Null
    $approvalFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $proposalPath -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-004-binding-001" -OutputRoot $freezeOutputRoot -DecisionId "decision-r6-004-approved-001" -FreezeId "freeze-r6-004-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T05:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze it before Git-backed baseline binding."
    Invoke-GitCommitAll -Root $Root -Message "commit approved freeze artifacts"

    return [pscustomobject]@{
        Root               = $Root
        ProposalPath       = $proposalPath
        FreezePath         = $approvalFlow.FreezePath
        FreezeOutputRoot   = $freezeOutputRoot
        BindingOutputRoot  = (Join-Path $Root "state\autocycle\baseline_binding")
        MilestonePath      = (Join-Path $Root "state\fixtures\valid\milestone_autocycle\governed_work_object.milestone.valid.json")
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
        $script:failures += ("FAIL {0}: operation succeeded unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS {0}: {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-004-binding-valid-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-BaselineBindingHarness -Root $tempRoot
        $bindingFlow = & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $harness.FreezePath -RepositoryRoot $harness.Root -OutputRoot $harness.BindingOutputRoot -BindingId "baseline-binding-r6-004-valid-001" -BaselineId "baseline-r6-004-valid-001" -BoundAt ([datetime]::Parse("2026-04-22T05:30:00Z").ToUniversalTime())
        $bindingCheck = & $testMilestoneAutocycleBaselineBindingContract -BindingPath $bindingFlow.BindingPath
        $binding = Get-JsonDocument -Path $bindingFlow.BindingPath
        $freeze = Get-JsonDocument -Path $harness.FreezePath

        if ($bindingCheck.BaselineId -ne "baseline-r6-004-valid-001") {
            $failures += "FAIL valid baseline binding: validator did not return the expected baseline id."
        }
        if (@($binding.planning_record_refs).Count -ne @($freeze.frozen_task_set).Count) {
            $failures += "FAIL valid baseline binding: planning_record_refs count did not match the frozen task count."
        }
        if ([string]::IsNullOrWhiteSpace($binding.baseline.head_commit) -or [string]::IsNullOrWhiteSpace($binding.baseline.tree_id)) {
            $failures += "FAIL valid baseline binding: baseline Git identity was not persisted."
        }
        if ($binding.freeze_id -ne "freeze-r6-004-approved-001") {
            $failures += "FAIL valid baseline binding: freeze_id did not persist."
        }

        Write-Output ("PASS valid baseline binding flow: {0} -> {1}" -f $bindingCheck.BindingId, $bindingCheck.BaselineId)
        $validPassed += 1

        $tamperedBridgePath = Join-Path (Split-Path -Parent $bindingFlow.BindingPath) "tampered-bridge.binding.json"
        $tamperedBridge = Get-JsonDocument -Path $bindingFlow.BindingPath
        $tamperedBridge.planning_record_refs[0].accepted_record_ref = $tamperedBridge.baseline.baseline_ref
        Write-JsonDocument -Path $tamperedBridgePath -Document $tamperedBridge
        Invoke-ExpectedRefusal -Label "malformed planning bridge refusal" -Action {
            & $testMilestoneAutocycleBaselineBindingContract -BindingPath $tamperedBridgePath | Out-Null
        }

        $tamperedBaselineRefPath = Join-Path (Split-Path -Parent $bindingFlow.BindingPath) "tampered-baseline-ref.binding.json"
        $tamperedBaselineRef = Get-JsonDocument -Path $bindingFlow.BindingPath
        $tamperedBaselineRef.baseline.baseline_ref = "baseline_store/milestone_baselines/missing-baseline.json"
        Write-JsonDocument -Path $tamperedBaselineRefPath -Document $tamperedBaselineRef
        Invoke-ExpectedRefusal -Label "malformed baseline ref refusal" -Action {
            & $testMilestoneAutocycleBaselineBindingContract -BindingPath $tamperedBaselineRefPath | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid baseline binding harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-004-binding-missing-freeze-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-BaselineBindingHarness -Root $tempRoot
        Invoke-ExpectedRefusal -Label "missing freeze refusal" -Action {
            & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath (Join-Path $harness.Root "state\autocycle\cycle\freezes\missing-freeze.json") -RepositoryRoot $harness.Root -OutputRoot $harness.BindingOutputRoot -BindingId "baseline-binding-r6-004-missing-freeze" -BaselineId "baseline-r6-004-missing-freeze" | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL missing freeze refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-004-binding-dirty-" + [guid]::NewGuid().ToString("N"))

    try {
        $harness = Initialize-BaselineBindingHarness -Root $tempRoot
        Add-Content -LiteralPath (Join-Path $harness.Root "README.md") -Value "dirty change"
        Invoke-ExpectedRefusal -Label "dirty worktree refusal" -Action {
            & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $harness.FreezePath -RepositoryRoot $harness.Root -OutputRoot $harness.BindingOutputRoot -BindingId "baseline-binding-r6-004-dirty" -BaselineId "baseline-r6-004-dirty" | Out-Null
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL dirty worktree refusal harness: {0}" -f $_.Exception.Message)
}

try {
    $captureRoot = Join-Path $env:TEMP ("aioffice-r6-004-binding-capture-" + [guid]::NewGuid().ToString("N"))
    $donorRoot = Join-Path $env:TEMP ("aioffice-r6-004-binding-donor-" + [guid]::NewGuid().ToString("N"))

    try {
        New-TempGitRepository -Root $captureRoot
        $donorHarness = Initialize-BaselineBindingHarness -Root $donorRoot
        Invoke-ExpectedRefusal -Label "repository mismatch refusal" -Action {
            & $invokeMilestoneFreezeBaselineBindingFlow -FreezePath $donorHarness.FreezePath -RepositoryRoot $captureRoot -OutputRoot (Join-Path $captureRoot "state\autocycle\baseline_binding") -BindingId "baseline-binding-r6-004-repository-mismatch" -BaselineId "baseline-r6-004-repository-mismatch" | Out-Null
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
    $failures += ("FAIL repository mismatch refusal harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone autocycle baseline binding tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone autocycle baseline binding tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
