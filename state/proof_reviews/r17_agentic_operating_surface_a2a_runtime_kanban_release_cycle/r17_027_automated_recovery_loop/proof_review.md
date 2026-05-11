# R17-027 Automated Recovery Loop Foundation Proof Review

R17-027 creates a deterministic automated recovery-loop foundation for interruption and compact-failure handling. It defines failure events, WIP classification, preservation actions, continuation packets, a new-context resume packet, retry limits, escalation policy, prompt packets, compact fixtures, a check report, and a read-only UI snapshot.

## Evidence

- Contract: contracts/runtime/r17_automated_recovery_loop.contract.json
- Plan: state/runtime/r17_automated_recovery_loop_plan.json
- State machine: state/runtime/r17_automated_recovery_loop_state_machine.json
- Failure events: state/runtime/r17_automated_recovery_loop_failure_events.jsonl
- Continuation packets: state/runtime/r17_automated_recovery_loop_continuation_packets.json
- New-context packets: state/runtime/r17_automated_recovery_loop_new_context_packets.json
- Check report: state/runtime/r17_automated_recovery_loop_check_report.json
- Prompt packets: state/runtime/r17_automated_recovery_loop_prompt_packets/
- UI snapshot: state/ui/r17_kanban_mvp/r17_automated_recovery_loop_snapshot.json
- Tooling and tests: 	ools/R17AutomatedRecoveryLoop.psm1, 	ools/validate_r17_automated_recovery_loop.ps1, and 	ests/test_r17_automated_recovery_loop.ps1

## Boundary

This is a recovery-loop foundation only. It does not implement live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live execution harness runtime, live agent runtime, live A2A runtime, adapter runtime, actual tool calls, product runtime, main merge, R17 closeout, no-manual-prompt-transfer success, solved Codex compaction, or solved Codex reliability.

R17 is active through R17-027 only. R17-028 remains planned only. Live automation, automatic new-thread creation, and API-level orchestration remain future work.
