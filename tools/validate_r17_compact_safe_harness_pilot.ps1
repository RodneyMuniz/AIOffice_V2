$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CompactSafeHarnessPilot.psm1"
Import-Module $modulePath -Force

$result = Test-R17CompactSafeHarnessPilot -RepositoryRoot $repoRoot

Write-Output "R17-026 compact-safe harness pilot validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Source task: {0}" -f $result.SourceTask)
Write-Output ("Work orders: {0}" -f $result.WorkOrderCount)
Write-Output ("Prompt packets: {0}" -f $result.PromptPacketCount)
Write-Output ("Active through: {0}" -f $result.ActiveThroughTask)
Write-Output ("Planned only: {0} through {1}" -f $result.PlannedOnlyFrom, $result.PlannedOnlyThrough)
Write-Output ("Compact-safe harness pilot created: {0}" -f $result.CompactSafeHarnessPilotCreated)
Write-Output ("Cycle 3 split into small work orders: {0}" -f $result.Cycle3SplitIntoSmallWorkOrders)
Write-Output ("Cycle 3 prompt packets created: {0}" -f $result.Cycle3PromptPacketsCreated)
Write-Output ("Resume-after-compact prompt packet created: {0}" -f $result.ResumeAfterCompactPromptPacketCreated)
Write-Output ("Stage/commit/push prompt packet created: {0}" -f $result.StageCommitPushPromptPacketCreated)
Write-Output ("Future Cycle 3 can be attempted in smaller steps: {0}" -f $result.FutureCycle3CanBeAttemptedInSmallerSteps)
Write-Output ("Live execution harness runtime implemented: {0}" -f $result.LiveExecutionHarnessRuntimeImplemented)
Write-Output ("Harness pilot runtime executed: {0}" -f $result.HarnessPilotRuntimeExecuted)
Write-Output ("OpenAI API invoked: {0}" -f $result.OpenAiApiInvoked)
Write-Output ("Codex API invoked: {0}" -f $result.CodexApiInvoked)
Write-Output ("Autonomous Codex invocation performed: {0}" -f $result.AutonomousCodexInvocationPerformed)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Audit verdict claimed: {0}" -f $result.AuditVerdictClaimed)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
Write-Output ("No manual prompt transfer claimed: {0}" -f $result.NoManualPromptTransferClaimed)
Write-Output ("Solved Codex compaction claimed: {0}" -f $result.SolvedCodexCompactionClaimed)
Write-Output ("Solved Codex reliability claimed: {0}" -f $result.SolvedCodexReliabilityClaimed)
