$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17CompactSafeExecutionHarness.psm1"
Import-Module $modulePath -Force

$result = Test-R17CompactSafeExecutionHarness -RepositoryRoot $repoRoot

Write-Output "R17-025 compact-safe local execution harness foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Source task: {0}" -f $result.SourceTask)
Write-Output ("Work orders: {0}" -f $result.WorkOrderCount)
Write-Output ("Prompt packets: {0}" -f $result.PromptPacketCount)
Write-Output ("Active through: {0}" -f $result.ActiveThroughTask)
Write-Output ("Planned only: {0} through {1}" -f $result.PlannedOnlyFrom, $result.PlannedOnlyThrough)
Write-Output ("Compact-safe execution harness foundation created: {0}" -f $result.CompactSafeExecutionHarnessFoundationCreated)
Write-Output ("Small prompt packet model created: {0}" -f $result.SmallPromptPacketModelCreated)
Write-Output ("Resumable work order model created: {0}" -f $result.ResumableWorkOrderModelCreated)
Write-Output ("Resume-after-compact model created: {0}" -f $result.ResumeAfterCompactModelCreated)
Write-Output ("Future cycle execution can be split into smaller work orders: {0}" -f $result.FutureCycleExecutionCanBeSplitIntoSmallerWorkOrders)
Write-Output ("Live execution harness runtime implemented: {0}" -f $result.LiveExecutionHarnessRuntimeImplemented)
Write-Output ("OpenAI API invoked: {0}" -f $result.OpenAiApiInvoked)
Write-Output ("Codex API invoked: {0}" -f $result.CodexApiInvoked)
Write-Output ("Autonomous Codex invocation performed: {0}" -f $result.AutonomousCodexInvocationPerformed)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
Write-Output ("No manual prompt transfer claimed: {0}" -f $result.NoManualPromptTransferClaimed)
Write-Output ("Solved Codex compaction claimed: {0}" -f $result.SolvedCodexCompactionClaimed)
Write-Output ("Solved Codex reliability claimed: {0}" -f $result.SolvedCodexReliabilityClaimed)
