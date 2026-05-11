$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AutomatedRecoveryLoop.psm1"
Import-Module $modulePath -Force

$result = Test-R17AutomatedRecoveryLoop -RepositoryRoot $repoRoot

Write-Output "R17-027 automated recovery loop foundation validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Source task: {0}" -f $result.SourceTask)
Write-Output ("Failure events: {0}" -f $result.FailureEventCount)
Write-Output ("Continuation packets: {0}" -f $result.ContinuationPacketCount)
Write-Output ("New-context packets: {0}" -f $result.NewContextPacketCount)
Write-Output ("Prompt packets: {0}" -f $result.PromptPacketCount)
Write-Output ("Active through: {0}" -f $result.ActiveThroughTask)
Write-Output ("Planned only: {0} through {1}" -f $result.PlannedOnlyFrom, $result.PlannedOnlyThrough)
Write-Output ("Automated recovery loop foundation created: {0}" -f $result.AutomatedRecoveryLoopFoundationCreated)
Write-Output ("Failure event model created: {0}" -f $result.FailureEventModelCreated)
Write-Output ("Continuation packet model created: {0}" -f $result.ContinuationPacketModelCreated)
Write-Output ("New-context resume packet model created: {0}" -f $result.NewContextResumePacketModelCreated)
Write-Output ("Compact failure recovery path modelled: {0}" -f $result.CompactFailureRecoveryPathModelled)
Write-Output ("Retry escalation policy created: {0}" -f $result.RetryEscalationPolicyCreated)
Write-Output ("Future work can resume from new-context packet: {0}" -f $result.FutureWorkCanResumeFromNewContextPacket)
Write-Output ("Live recovery-loop runtime implemented: {0}" -f $result.LiveRecoveryLoopRuntimeImplemented)
Write-Output ("Automatic new-thread creation performed: {0}" -f $result.AutomaticNewThreadCreationPerformed)
Write-Output ("OpenAI API invoked: {0}" -f $result.OpenAiApiInvoked)
Write-Output ("Codex API invoked: {0}" -f $result.CodexApiInvoked)
Write-Output ("Autonomous Codex invocation performed: {0}" -f $result.AutonomousCodexInvocationPerformed)
Write-Output ("Product runtime executed: {0}" -f $result.ProductRuntimeExecuted)
Write-Output ("Main merge claimed: {0}" -f $result.MainMergeClaimed)
Write-Output ("R17 closeout claimed: {0}" -f $result.R17CloseoutClaimed)
Write-Output ("No manual prompt transfer claimed: {0}" -f $result.NoManualPromptTransferClaimed)
Write-Output ("Solved Codex compaction claimed: {0}" -f $result.SolvedCodexCompactionClaimed)
Write-Output ("Solved Codex reliability claimed: {0}" -f $result.SolvedCodexReliabilityClaimed)
