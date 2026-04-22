$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$proposalModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleProposal.psm1") -Force -PassThru
$freezeModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleFreeze.psm1") -Force -PassThru
$testMilestoneAutocycleProposalContract = $proposalModule.ExportedCommands["Test-MilestoneAutocycleProposalContract"]
$testMilestoneAutocycleApprovalContract = $freezeModule.ExportedCommands["Test-MilestoneAutocycleApprovalContract"]
$testMilestoneAutocycleFreezeContract = $freezeModule.ExportedCommands["Test-MilestoneAutocycleFreezeContract"]
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

$validProposal = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle\proposal.expected.json"

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $proposalCheck = & $testMilestoneAutocycleProposalContract -ProposalPath $validProposal
    Write-Output ("PASS valid proposal fixture: {0} -> {1}" -f (Resolve-Path -Relative $validProposal), $proposalCheck.ProposalId)

    $approvedOutputRoot = Join-Path $env:TEMP ("aioffice-r6-003-approved-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $approvedOutputRoot -Force | Out-Null

    try {
        $approvedFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $validProposal -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-pilot-approved-001" -OutputRoot $approvedOutputRoot -DecisionId "decision-r6-003-approved-001" -FreezeId "freeze-r6-003-approved-001" -DecidedAt ([datetime]::Parse("2026-04-22T04:00:00Z").ToUniversalTime()) -Notes "Approve the bounded milestone proposal and freeze the exact task set."
        $approvalCheck = & $testMilestoneAutocycleApprovalContract -ApprovalPath $approvedFlow.ApprovalPath
        $freezeCheck = & $testMilestoneAutocycleFreezeContract -FreezePath $approvedFlow.FreezePath
        $approval = Get-JsonDocument -Path $approvedFlow.ApprovalPath
        $freeze = Get-JsonDocument -Path $approvedFlow.FreezePath
        $proposal = Get-JsonDocument -Path $validProposal

        Write-Output ("PASS approved milestone freeze flow: {0} -> {1}" -f $approvalCheck.DecisionId, $freezeCheck.FreezeId)

        if ($approval.status -ne "approved") {
            $failures += ("FAIL approved milestone freeze flow: expected approval status 'approved' but found '{0}'." -f $approval.status)
        }
        if ($freeze.approval_status -ne "approved") {
            $failures += ("FAIL approved milestone freeze flow: expected freeze approval_status 'approved' but found '{0}'." -f $freeze.approval_status)
        }
        if ($freeze.proposal_id -ne $proposal.proposal_id) {
            $failures += "FAIL approved milestone freeze flow: freeze.proposal_id did not match the source proposal."
        }
        if (@($freeze.frozen_task_set).Count -ne @($proposal.proposed_task_set).Count) {
            $failures += "FAIL approved milestone freeze flow: frozen_task_set count did not match the proposal task count."
        }
        if ($freeze.approved_by -ne "operator:rodney") {
            $failures += ("FAIL approved milestone freeze flow: expected approved_by 'operator:rodney' but found '{0}'." -f $freeze.approved_by)
        }
        if ($freeze.operator_authority.operator_id -ne "operator:rodney") {
            $failures += "FAIL approved milestone freeze flow: operator authority did not preserve the approving operator id."
        }

        $validPassed += 1

        $freezeDirectory = Split-Path -Parent $approvedFlow.FreezePath

        $tamperedFreezePath = Join-Path $freezeDirectory "tampered.freeze.json"
        $tamperedFreeze = ConvertFrom-Json ($freeze | ConvertTo-Json -Depth 20)
        $tamperedFreeze.approval_status = "rejected"
        Write-JsonDocument -Path $tamperedFreezePath -Document $tamperedFreeze
        try {
            & $testMilestoneAutocycleFreezeContract -FreezePath $tamperedFreezePath | Out-Null
            $failures += "FAIL malformed freeze state: freeze with approval_status 'rejected' was accepted unexpectedly."
        }
        catch {
            Write-Output ("PASS malformed freeze state: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }

        $tamperedTaskSetPath = Join-Path $freezeDirectory "tampered-task-set.freeze.json"
        $tamperedTaskSet = ConvertFrom-Json ($freeze | ConvertTo-Json -Depth 20)
        $tamperedTaskSet.frozen_task_set[0].task_id = "task-r6-pilot-mismatch-001"
        Write-JsonDocument -Path $tamperedTaskSetPath -Document $tamperedTaskSet
        try {
            & $testMilestoneAutocycleFreezeContract -FreezePath $tamperedTaskSetPath | Out-Null
            $failures += "FAIL task-set mismatch: freeze with a mismatched frozen task id was accepted unexpectedly."
        }
        catch {
            Write-Output ("PASS task-set mismatch: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $approvedOutputRoot) {
            Remove-Item -LiteralPath $approvedOutputRoot -Recurse -Force
        }
    }

    $rejectedOutputRoot = Join-Path $env:TEMP ("aioffice-r6-003-rejected-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $rejectedOutputRoot -Force | Out-Null

    try {
        $rejectedFlow = & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $validProposal -DecisionStatus rejected -OperatorId "operator:rodney" -CycleId "cycle-r6-pilot-rejected-001" -OutputRoot $rejectedOutputRoot -DecisionId "decision-r6-003-rejected-001" -RejectionReasons @("Operator requires tighter scope notes before freeze.") -DecidedAt ([datetime]::Parse("2026-04-22T04:10:00Z").ToUniversalTime()) -Notes "Reject the milestone proposal without creating a freeze artifact."
        $rejectedApprovalCheck = & $testMilestoneAutocycleApprovalContract -ApprovalPath $rejectedFlow.ApprovalPath
        $rejectedApproval = Get-JsonDocument -Path $rejectedFlow.ApprovalPath
        Write-Output ("PASS rejected milestone approval flow: {0} -> {1}" -f $rejectedApprovalCheck.DecisionId, $rejectedApproval.status)

        if ($rejectedApproval.status -ne "rejected") {
            $failures += ("FAIL rejected milestone approval flow: expected status 'rejected' but found '{0}'." -f $rejectedApproval.status)
        }
        if ($null -ne $rejectedFlow.FreezePath) {
            $failures += "FAIL rejected milestone approval flow: a rejected proposal unexpectedly produced a freeze artifact."
        }
        if (@($rejectedApproval.rejection_reasons).Count -eq 0) {
            $failures += "FAIL rejected milestone approval flow: rejection_reasons should not be empty."
        }

        $validPassed += 1

        try {
            & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $validProposal -DecisionStatus approved -OperatorId "operator:rodney" -CycleId "cycle-r6-pilot-invalid-approval-001" -OutputRoot (Join-Path $rejectedOutputRoot "invalid-approved") -DecisionId "decision-r6-003-invalid-approved-001" -FreezeId "freeze-r6-003-invalid-approved-001" -RejectionReasons @("Unexpected rejection reason") -Notes "Invalid approved decision." | Out-Null
            $failures += "FAIL invalid approved decision: approved flow accepted rejection reasons unexpectedly."
        }
        catch {
            Write-Output ("PASS invalid approved decision: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }

        try {
            & $invokeMilestoneAutocycleApprovalFlow -ProposalPath $validProposal -DecisionStatus rejected -OperatorId "operator:rodney" -CycleId "cycle-r6-pilot-invalid-rejected-001" -OutputRoot (Join-Path $rejectedOutputRoot "invalid-rejected") -DecisionId "decision-r6-003-invalid-rejected-001" -Notes "Invalid rejected decision." | Out-Null
            $failures += "FAIL invalid rejected decision: rejected flow accepted empty rejection reasons unexpectedly."
        }
        catch {
            Write-Output ("PASS invalid rejected decision: {0}" -f $_.Exception.Message)
            $invalidRejected += 1
        }
    }
    finally {
        if (Test-Path -LiteralPath $rejectedOutputRoot) {
            Remove-Item -LiteralPath $rejectedOutputRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL milestone freeze harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone freeze tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone freeze tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
