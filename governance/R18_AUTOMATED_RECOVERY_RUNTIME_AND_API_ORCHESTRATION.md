# R18 Automated Recovery Runtime and API Orchestration

**Milestone name:** R18 Automated Recovery Runtime and API Orchestration
**Branch:** `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle`
**Status after this pass:** Active through `R18-020` board/card runtime event model foundation only.
**Source authority:** R18 is active only after R17 operator closeout approval in `state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json`.
**Current scope:** `R18-001` through `R18-020` are done. `R18-021` through `R18-028` are planned only. R18 runtime implementation is not yet delivered.

## Mission

R18 exists to reduce the manual GPT-to-Codex recovery loop by implementing, in later tasks, a governed local runner/CLI, failure detection, WIP classification, remote branch verification, continuation packet generation, new-context prompt generation, retry limits, escalation, evidence capture, and operator decision gates.

API-backed Codex/OpenAI invocation is optional and must not be implemented before secrets, budget, timeout, retry, approval, and stop controls exist. R18 must use small resumable work orders, not giant Codex prompts. R18 must preserve fail-closed behavior.

## Current Non-Claims

- R18 runtime implementation is not yet delivered.
- R18-021 through R18-028 remain planned only.
- R18-020 created board/card runtime event model foundation only.
- Board/card event model artifacts are deterministic seed/policy artifacts only.
- Live board/card runtime was not implemented.
- Board/card runtime mutation was not performed.
- Live Kanban UI was not implemented.
- No R18 runtime tool-call execution was performed.
- R18-002 created agent card schema and seed cards only.
- Agent cards are not live agents.
- R18-003 created skill contract schema and seed skill contracts only.
- Skill contracts are not live skill execution.
- R18-004 created A2A handoff packet schema and seed handoff packets only.
- A2A handoff packets are not live A2A runtime.
- R18-005 created role-to-skill permission matrix only.
- Permission matrix is not runtime enforcement.
- R18-006 created Orchestrator chat/control intake contract and seed intake packets only.
- Intake packets are not a live chat UI.
- Intake packets are not Orchestrator runtime.
- R18-007 created local runner/CLI shell foundation only.
- CLI shell is dry-run only.
- CLI shell is not full work-order execution runtime.
- R18-008 created work-order execution state machine foundation only.
- Work-order state machine is not runtime execution.
- R18-009 created runner state store and resumable execution log foundation only.
- Runner state store is not live runner runtime.
- Execution log is deterministic foundation evidence, not live execution evidence.
- Resume checkpoint is not a continuation packet.
- R18-010 created compact failure detector foundation only.
- Failure detection is deterministic over seed signal artifacts only.
- Failure events are not recovery completion.
- R18-011 created WIP classifier foundation only.
- WIP classification is deterministic over seed git inventory artifacts only.
- R18-012 created remote branch verifier foundation only.
- Remote branch verifier foundation is bounded branch/head/tree/remote-head verification evidence only.
- Current branch identity was verified only by bounded git identity checks.
- R18-013 created continuation packet generator foundation only.
- Continuation packets were generated as deterministic packet artifacts only.
- Continuation packets were not executed.
- Continuation packets are not new-context prompts.
- No branch mutation was performed.
- No pull, rebase, reset, merge, checkout, switch, clean, restore, staging, commit, or push was performed by the verifier.
- No pull, rebase, reset, merge, checkout, switch, clean, or restore was performed.
- No WIP cleanup was performed.
- No WIP abandonment was performed.
- No files were restored or deleted.
- No staging, commit, or push was performed by the classifier.
- No staging, commit, or push was performed by the generator.
- R18-014 created new-context prompt generator foundation only.
- New-context prompt packets were generated as deterministic text artifacts only.
- Prompt packets were not executed.
- R18-015 created retry and escalation policy foundation only.
- Retry/escalation decisions were generated as deterministic policy artifacts only.
- Retry execution was not performed.
- Retry runtime was not implemented.
- Escalation runtime was not implemented.
- Operator approval runtime is not implemented.
- R18-017 created stage/commit/push gate foundation only. Stage/commit/push gate artifacts are deterministic policy artifacts only. Gate runtime was not implemented. The gate did not stage, commit, or push. Normal Codex worker commit/push of this R18-017 task is not the gate executing.
- R18-018 created status-doc gate automation wrapper foundation only.
- Status-doc gate wrapper artifacts are deterministic policy artifacts only.
- Wrapper runtime was not implemented.
- Live status-doc gate runtime was not executed.
- Release gate was not executed.
- No stage/commit/push was performed by the wrapper.
- CI replay was not performed.
- GitHub Actions workflow was not created or run.
- External audit acceptance was not claimed.
- R18-019 created evidence package automation wrapper foundation only.
- Evidence package wrapper artifacts are deterministic policy/manifest artifacts only.
- Live evidence package runtime was not executed.
- Audit acceptance was not claimed.
- Main was not merged.
- CI replay remains absent; evidence relies on committed artifacts plus Codex-reported local validations.
- R18-016 created operator approval gate model foundation only.
- Approval request and decision/refusal packets were generated as deterministic governance artifacts only.
- Operator approval runtime was not implemented.
- No approval was inferred from narration.
- No risky action was approved by seed packets.
- Automatic new-thread creation was not performed.
- Codex thread creation was not performed.
- Codex API invocation did not occur.
- OpenAI API invocation did not occur.
- Automatic new-thread creation is not implemented.
- No work orders were executed.
- No board/card runtime mutation occurred.
- No A2A messages were sent.
- No live agents were invoked.
- No live skills were executed.
- No local runner runtime was executed.
- No live A2A runtime was implemented.
- No recovery action was performed.
- Recovery action was not performed.
- No retry execution was performed.
- No product runtime is claimed.
- No live recovery runtime is claimed.
- No live A2A runtime is claimed.
- No OpenAI API invocation is claimed.
- No Codex API invocation is claimed.
- No autonomous Codex invocation is claimed.
- No automatic new-thread creation is claimed.
- No stage/commit/push was performed by the runner or state store.
- No stage/commit/push was performed by the detector.
- No main merge is claimed.
- Codex compaction is detected as a failure type, not solved.
- No solved Codex reliability is claimed.
- No no-manual-prompt-transfer success is claimed yet.

## Task List

### `R18-001` Open R18 in repo truth and install transition authority
- Status: done
- Purpose: Open R18 after operator-approved R17 closeout while preserving R17 caveats.
- Inputs: R17 operator closeout decision, external R17 audit, revised R18 plan, current branch/head/tree.
- Outputs: R18 authority document, opening authority JSON, contract, planning manifest, status-doc updates.
- Acceptance criteria: R18 active through R18-001 only; R18-002 through R18-028 planned only; R17 closed with caveats through R17-028 only.
- Validation expectation: `tools/validate_r18_opening_authority.ps1`, `tests/test_r18_opening_authority.ps1`, and status-doc gate pass.
- Non-claims: No R18 runtime implementation, API invocation, main merge, solved compaction, or solved reliability.
- Dependencies: Operator-approved R17 closeout decision.
- Failure/retry behavior: Missing or contradictory operator approval fails closed and blocks R18 opening.
- Expected evidence refs: `state/governance/r18_opening_authority.json`, this authority doc, status docs, decision log.

### `R18-002` Define agent card schema and validator
- Status: done
- Purpose: Define enforceable agent cards for role authority, allowed skills, evidence duties, and failover rules.
- Inputs: R17 agent registry, R17 role identity packets, R18 authority.
- Outputs: Agent card contract, seed cards, check report, operator-surface snapshot state artifact, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Each card declares role, authority scope, allowed skills, forbidden actions, inputs, outputs, memory refs, handoff rules, retry behavior, and approval gates.
- Validation expectation: `tools/validate_r18_agent_card_schema.ps1` and `tests/test_r18_agent_card_schema.ps1` fail closed on missing authority, wildcard skills, missing required duties, unsafe permissions, runtime/API claims, historical evidence edits, operator-local backup paths, broad repo writes, and R18-003+ completion claims.
- Non-claims: Agent cards are not live agents, no skills were implemented, no A2A runtime was implemented, no recovery runtime was implemented, no API invocation occurred, no automatic new-thread creation occurred, no product runtime is claimed, and main is not merged.
- Dependencies: R18-001.
- Failure/retry behavior: Missing required authority or wildcard skill permission blocks the card.
- Expected evidence refs: `contracts/agents/r18_agent_card.contract.json`, generated cards, check report, fixtures.

### `R18-003` Define skill contract schema and validator
- Status: done
- Purpose: Make skills explicit governed contract units with input/output, evidence, safety, and failure contracts.
- Inputs: R18 agent cards, R17 tool adapter contracts, R17 recovery-loop foundation.
- Outputs: Skill contract schema, fourteen seed skill contracts, skill registry, validator, focused tests, fixtures, check report, operator-surface snapshot state artifact, and proof-review package.
- Acceptance criteria: Each skill declares allowed roles, forbidden roles, required inputs/outputs, evidence obligations, failure packet schema, path policy, command policy, API policy, secrets/cost/token/timeout policy, retry policy, approval requirements, evidence refs, authority refs, runtime false flags, non-claims, and rejected claims.
- Validation expectation: `tools/validate_r18_skill_contract_schema.ps1` and `tests/test_r18_skill_contract_schema.ps1` reject missing seed skills, missing required fields, wildcard or invalid roles, broad paths, operator-local backup paths, historical R13/R14/R15/R16 evidence edits, missing evidence obligations, missing failure packets, missing command/API/secrets/token/timeout/retry policies, unbounded retries, live skill/agent/A2A/recovery/runtime claims, API enablement, automatic new-thread creation, product runtime, R18-004+ completion claims, and status surfaces that advance R18 beyond R18-003.
- Non-claims: Skill contracts are not live skill execution. No A2A handoff schema, A2A runtime, local runner runtime, recovery runtime, API invocation, automatic new-thread creation, product runtime, main merge, solved Codex compaction/reliability, or no-manual-prompt-transfer success is claimed.
- Dependencies: R18-002.
- Failure/retry behavior: Unsafe skill contracts fail closed and require repair before use.
- Expected evidence refs: `contracts/skills/r18_skill_contract.contract.json`, `state/skills/r18_skill_contracts/`, `state/skills/r18_skill_registry.json`, `state/skills/r18_skill_contract_check_report.json`, `state/ui/r18_operator_surface/r18_skill_contract_snapshot.json`, `tools/R18SkillContractSchema.psm1`, `tools/new_r18_skill_contract_schema.ps1`, `tools/validate_r18_skill_contract_schema.ps1`, `tests/test_r18_skill_contract_schema.ps1`, `tests/fixtures/r18_skill_contract_schema/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_003_skill_contract_schema/`.

### `R18-004` Define A2A handoff packet schema and validator
- Status: done
- Purpose: Define explicit, validated A2A handoff packets so source and target roles can validate bounded card/work-order context before any role action.
- Inputs: R17 A2A contracts, R18 agent cards, R18 skill contracts.
- Outputs: A2A handoff packet contract, eight seed packets, handoff registry, check report, operator-surface snapshot state artifact, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Handoffs include source/target agent and role refs, card/work-order refs, skill refs, required inputs, expected outputs, memory refs, evidence refs, authority refs, current state, finite next allowed actions, validation expectations, receiving-role validation, bounded retry/failover policy, failure routing, approval requirements, path policy, runtime false flags, non-claims, and rejected claims.
- Validation expectation: `tools/validate_r18_a2a_handoff_packet_schema.ps1` and `tests/test_r18_a2a_handoff_packet_schema.ps1` reject missing seed handoffs, missing required fields, unknown agents, role/card mismatches, unknown skills, target roles not allowed for skills, missing required refs, wildcard/unbounded next actions, missing validation expectations, unbounded retries, missing failure routing, broad repo writes, operator-local backup paths, historical R13/R14/R15/R16 evidence edits, live A2A/agent/skill/recovery/runtime/API claims, automatic new-thread creation, product runtime, R18-005+ completion claims, and status surfaces that advance R18 beyond R18-004.
- Non-claims: Handoff packets are schema/seed governance artifacts only; no A2A messages were sent, no live A2A runtime was implemented, no live agents were invoked, no live skills were executed, no local runner runtime or recovery runtime was implemented, no API invocation occurred, no automatic new-thread creation occurred, no product runtime is claimed, main is not merged, and no solved Codex compaction/reliability or no-manual-prompt-transfer success is claimed.
- Dependencies: R18-002, R18-003.
- Failure/retry behavior: Invalid handoff routes to repair, block, or operator decision.
- Expected evidence refs: `contracts/a2a/r18_a2a_handoff_packet.contract.json`, `state/a2a/r18_handoff_packets/`, `state/a2a/r18_handoff_registry.json`, `state/a2a/r18_a2a_handoff_check_report.json`, `state/ui/r18_operator_surface/r18_a2a_handoff_snapshot.json`, `tools/R18A2AHandoffPacketSchema.psm1`, `tools/new_r18_a2a_handoff_packet_schema.ps1`, `tools/validate_r18_a2a_handoff_packet_schema.ps1`, `tests/test_r18_a2a_handoff_packet_schema.ps1`, `tests/fixtures/r18_a2a_handoff_packet_schema/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_004_a2a_handoff_packet_schema/`.

### `R18-005` Define explicit role-to-skill permission matrix
- Status: done
- Purpose: Bind each role to allowed and forbidden skills with approval requirements, evidence obligations, runtime false flags, and fail-closed constraints.
- Inputs: Agent cards, skill registry, role authority model.
- Outputs: Permission matrix contract, matrix artifact, check report, operator-surface snapshot state artifact, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: No role has wildcard authority; no role has all-skills authority; risky skills require operator approval; forbidden role/skill pairings fail closed; runtime false flags remain false.
- Validation expectation: `tools/validate_r18_role_skill_permission_matrix.ps1` and `tests/test_r18_role_skill_permission_matrix.ps1` reject missing roles, roles not mapped to R18-002 agent cards, missing skills, skills not mapped to the R18-003 registry, wildcard or all-skills permissions, unbounded permissions, missing approval gates, missing evidence obligations, missing failure behavior, unsafe role escalation, API enablement, historical R13/R14/R15/R16 evidence edits, operator-local backup paths, broad repo writes, live runtime/API/A2A/agent/skill claims, role-skill matrix artifacts claiming R18-006+ completion, and status surfaces that advance R18 beyond R18-006.
- Non-claims: Permission matrix is a governance/control artifact only and is not runtime enforcement. No A2A messages were sent, no live agents were invoked, no live skills were executed, no A2A runtime was implemented, no local runner runtime or recovery runtime was implemented, no API invocation occurred, no automatic new-thread creation occurred, no product runtime is claimed, main is not merged, and no solved Codex compaction/reliability or no-manual-prompt-transfer success is claimed.
- Dependencies: R18-002, R18-003.
- Failure/retry behavior: Unsafe matrix blocks all runtime work orders depending on it.
- Expected evidence refs: `contracts/skills/r18_role_skill_permission_matrix.contract.json`, `state/skills/r18_role_skill_permission_matrix.json`, `state/skills/r18_role_skill_permission_matrix_check_report.json`, `state/ui/r18_operator_surface/r18_role_skill_permission_matrix_snapshot.json`, `tools/R18RoleSkillPermissionMatrix.psm1`, `tools/new_r18_role_skill_permission_matrix.ps1`, `tools/validate_r18_role_skill_permission_matrix.ps1`, `tests/test_r18_role_skill_permission_matrix.ps1`, `tests/fixtures/r18_role_skill_permission_matrix/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_005_role_skill_permission_matrix/`.

### `R18-006` Build Orchestrator chat/control intake contract
- Status: done
- Purpose: Define the operator-facing control intake for cards, work orders, approvals, retries, and evidence inspection.
- Inputs: R18 authority, board/card model, agent cards, skill matrix.
- Outputs: Intake contract, seed intake packets, registry, check report, operator-surface snapshot state artifact, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Intake captures operator intent, normalized intent, target card/work order, allowed and forbidden paths, requested action, approval state, status/evidence query shape, refusal rules, runtime false flags, authority refs, agent card refs, skill refs, A2A handoff refs when routing is implied, and role-skill permission matrix refs.
- Validation expectation: `tools/validate_r18_orchestrator_control_intake.ps1` and `tests/test_r18_orchestrator_control_intake.ps1` reject missing seed packets, missing required fields, unknown intake types, missing authority/agent/skill/permission refs, unbounded freeform prompts, raw prompt-only recovery, permission matrix bypass, A2A handoff validation bypass when routing is implied, unknown roles or skills, denied role-skill pairings without failure/block routing, wildcard roles/skills/paths, historical R13/R14/R15/R16 evidence edits, operator-local backup paths, live chat UI claims, Orchestrator runtime claims, board/card runtime mutation claims, live agent or skill invocation claims, A2A message sent claims, A2A/local runner/recovery runtime claims, API invocation claims, automatic new-thread creation claims, product runtime claims, solved Codex compaction/reliability claims, no-manual-prompt-transfer success claims, R18-007+ completion claims, and status surfaces that advance R18 beyond R18-006.
- Non-claims: Intake contract and seed packets are not a live chat UI, not Orchestrator runtime, not board/card runtime mutation, not A2A runtime, not live agent invocation, not live skill execution, not local runner runtime, not recovery runtime, not API invocation, and not automatic new-thread creation.
- Dependencies: R18-005.
- Failure/retry behavior: Ambiguous or unsafe intake creates an operator clarification/decision packet.
- Expected evidence refs: `contracts/intake/r18_orchestrator_control_intake.contract.json`, `state/intake/r18_orchestrator_control_intake_packets/`, `state/intake/r18_orchestrator_control_intake_registry.json`, `state/intake/r18_orchestrator_control_intake_check_report.json`, `state/ui/r18_operator_surface/r18_orchestrator_control_intake_snapshot.json`, `tools/R18OrchestratorControlIntake.psm1`, `tools/new_r18_orchestrator_control_intake.ps1`, `tools/validate_r18_orchestrator_control_intake.ps1`, `tests/test_r18_orchestrator_control_intake.ps1`, `tests/fixtures/r18_orchestrator_control_intake/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_006_orchestrator_control_intake/`.

### `R18-007` Build local runner/CLI shell foundation
- Status: done
- Purpose: Create a bounded local runner/CLI shell foundation that validates command shape, records branch/head/tree identity, loads approved intake packet refs, enforces dry-run path/authority checks, emits deterministic dry-run evidence, and refuses unsafe commands.
- Inputs: R18 authority, R18-006 intake packet refs, path policy, validation command policy, branch policy.
- Outputs: Local runner CLI contract, dry-run profile, command catalog, dry-run inputs/results, check report, snapshot, validator, invocation wrapper, focused tests, fixtures, and proof-review package.
- Acceptance criteria: CLI validates input shape, records branch/head/tree, refuses missing authority, refuses unsafe paths and unknown commands, validates explicit intake packet refs, and performs no work-order execution, skill execution, A2A dispatch, API invocation, board/card runtime mutation, or stage/commit/push.
- Validation expectation: `tools/validate_r18_local_runner_cli.ps1` and `tests/test_r18_local_runner_cli.ps1` prove fail-closed dry-run behavior.
- Non-claims: CLI shell foundation is not full work-order execution runtime, not the R18-008 state machine, not live runner runtime, not recovery runtime, not API invocation, and not no-manual-prompt-transfer success.
- Dependencies: R18-006.
- Failure/retry behavior: Missing work order, unsafe path, or unknown command exits nonzero with a failure packet.
- Expected evidence refs: `contracts/runtime/r18_local_runner_cli.contract.json`, `state/runtime/r18_local_runner_cli_profile.json`, `state/runtime/r18_local_runner_cli_command_catalog.json`, `state/runtime/r18_local_runner_cli_dry_run_inputs/`, `state/runtime/r18_local_runner_cli_dry_run_results/`, `state/runtime/r18_local_runner_cli_check_report.json`, `state/ui/r18_operator_surface/r18_local_runner_cli_snapshot.json`, `tools/R18LocalRunnerCli.psm1`, `tools/invoke_r18_local_runner_cli.ps1`, `tools/new_r18_local_runner_cli.ps1`, `tools/validate_r18_local_runner_cli.ps1`, `tests/test_r18_local_runner_cli.ps1`, `tests/fixtures/r18_local_runner_cli/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_007_local_runner_cli_shell/`.

### `R18-008` Implement work-order execution state machine foundation
- Status: done
- Purpose: Define the governed work-order execution state machine that future runner/runtime work will consume.
- Inputs: R18 authority, R18-006 intake packets, R18-004 handoff registry, R18-005 role-skill permission matrix, R18-007 dry-run CLI shell boundary, R17 compact-safe harness and recovery-loop contracts.
- Outputs: State machine contract, state machine artifact, transition catalog, four seed work-order packets, four transition-evaluation artifacts, check report, operator-surface snapshot, fail-closed validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Required states and transition IDs are declared exactly; transition evaluations include authority, intake, handoff, permission, validation, evidence, retry, path, and execution-block checks; `ready_for_handoff_to_blocked_pending_future_execution_runtime` blocks work-order execution until R18-009 or later; runtime false flags remain false; R18-009 onward remains planned only.
- Validation expectation: `tools/validate_r18_work_order_state_machine.ps1` and `tests/test_r18_work_order_state_machine.ps1` reject missing artifacts, unknown states/transitions, missing authority/intake/handoff/permission refs, missing validation or evidence obligations, unbounded next states, unbounded retry, forbidden paths, work-order execution claims, runner state store claims, resumable execution log claims, live runtime/API/A2A/agent/skill/recovery/product claims, R18-009+ completion claims, and status surfaces beyond R18-008.
- Non-claims: State machine foundation is not live work execution, not runner state store, not resumable execution log, not full work-order execution runtime, not local runner runtime execution, not board/card runtime mutation, not A2A runtime or message dispatch, not live agent or skill execution, not recovery runtime, not API invocation, not automatic new-thread creation, not stage/commit/push by the runner or state machine, not product runtime, not main merge, not solved Codex compaction/reliability, and not no-manual-prompt-transfer success.
- Dependencies: R18-007.
- Failure/retry behavior: Invalid transition validation fails closed, blocks execution, and routes to validation failure or future operator decision; retry remains bounded and non-runtime.
- Expected evidence refs: `contracts/runtime/r18_work_order_state_machine.contract.json`, `state/runtime/r18_work_order_state_machine.json`, `state/runtime/r18_work_order_transition_catalog.json`, `state/runtime/r18_work_order_seed_packets/`, `state/runtime/r18_work_order_transition_evaluations/`, `state/runtime/r18_work_order_state_machine_check_report.json`, `state/ui/r18_operator_surface/r18_work_order_state_machine_snapshot.json`, `tools/R18WorkOrderStateMachine.psm1`, `tools/new_r18_work_order_state_machine.ps1`, `tools/validate_r18_work_order_state_machine.ps1`, `tests/test_r18_work_order_state_machine.ps1`, `tests/fixtures/r18_work_order_state_machine/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_008_work_order_state_machine/`.

### `R18-009` Implement runner state store and resumable execution log
- Status: done
- Purpose: Persist runner state and execution logs so continuation does not depend on chat memory.
- Inputs: R18-008 state machine, R18-008 blocked seed work order, local runner CLI shell refs, intake/handoff/permission refs, git identity recorded from required preflight, validator outputs, and source authority refs.
- Outputs: Runner state store contract, profile, seed runner state, JSONL state history, JSONL execution log, resume checkpoint, seed event artifacts, check report, operator-surface snapshot state artifact, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Store records current work order, current state, previous state, last completed step, next safe step, retry count, bounded retry limit, git identity, authority refs, evidence refs, validation refs, stop conditions, escalation conditions, and a checkpoint ref while all runtime/API/continuation flags remain false.
- Validation expectation: `tools/validate_r18_runner_state_store.ps1` and `tests/test_r18_runner_state_store.ps1` reject missing artifacts, missing state/log/checkpoint fields, unknown states/events, unbounded retry, missing git identity, wrong branch identity, missing authority/evidence/validation refs, missing stop conditions, continuation or new-context prompt claims, live runtime/API/A2A/agent/skill/recovery/board/product claims, operator-local backup paths, historical evidence edit permissions, broad repo writes, stage/commit/push claims, and R18-010+ completion claims.
- Non-claims: Runner state store is a deterministic state/log foundation only, not live runner runtime. Execution log is deterministic foundation evidence, not live execution evidence. Resume checkpoint is not a continuation packet. No work orders were executed.
- Dependencies: R18-008.
- Failure/retry behavior: Corrupt or incomplete state fails closed, blocks future continuation, and records escalation conditions; retry count is bounded and enforced.
- Expected evidence refs: `contracts/runtime/r18_runner_state_store.contract.json`, `state/runtime/r18_runner_state_store_profile.json`, `state/runtime/r18_runner_state.json`, `state/runtime/r18_runner_state_history.jsonl`, `state/runtime/r18_execution_log.jsonl`, `state/runtime/r18_runner_resume_checkpoint.json`, `state/runtime/r18_runner_state_store_seed_events/`, `state/runtime/r18_runner_state_store_check_report.json`, `state/ui/r18_operator_surface/r18_runner_state_store_snapshot.json`, `tools/R18RunnerStateStore.psm1`, `tools/new_r18_runner_state_store.ps1`, `tools/validate_r18_runner_state_store.ps1`, `tests/test_r18_runner_state_store.ps1`, `tests/fixtures/r18_runner_state_store/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_009_runner_state_store/`.

### `R18-010` Implement compact failure detector
- Status: done
- Purpose: Create a deterministic compact/context/stream failure detector foundation over committed seed signal artifacts only.
- Inputs: R18-009 runner state store refs, execution log refs, resume checkpoint refs, R17 automated recovery-loop authority refs, and seeded compact/context/stream/validation failure signal artifacts.
- Outputs: Failure event contract, compact failure detector contract, detector profile, six seed signal samples, six detected failure events, detection results, check report, operator-surface snapshot, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Detector classifies seeded compact/backend stream disconnect, context compaction required, stream disconnect before completion, validation interrupted after compact, non-compact validation failure, and unknown failure escalation signals into deterministic failure event packets with runner state refs, evidence refs, authority refs, next safe step, stop conditions, and runtime false flags.
- Validation expectation: `tools/validate_r18_compact_failure_detector.ps1` and `tests/test_r18_compact_failure_detector.ps1` reject missing artifacts, missing signal/event fields, unknown signal or detected failure types, missing runner state/execution log/resume checkpoint refs, missing evidence/authority refs, compact/non-compact misclassification, unknown failures without operator decision, runtime/API/recovery/WIP/remote/continuation/new-context/work-order/board/A2A/agent/skill/stage-commit-push claims, and status surfaces that advance R18 beyond R18-010.
- Non-claims: Detection is not recovery completion. Failure events are not continuation packets or new-context prompts. No WIP classification, remote branch verification, recovery action, work-order execution, live monitoring, API invocation, automatic new-thread creation, or stage/commit/push was performed by the detector.
- Dependencies: R18-009.
- Failure/retry behavior: Unknown failure becomes operator decision required.
- Expected evidence refs: `contracts/runtime/r18_failure_event.contract.json`, `contracts/runtime/r18_compact_failure_detector.contract.json`, `state/runtime/r18_compact_failure_detector_profile.json`, `state/runtime/r18_compact_failure_signal_samples/`, `state/runtime/r18_detected_failure_events/`, `state/runtime/r18_compact_failure_detector_results.json`, `state/runtime/r18_compact_failure_detector_check_report.json`, `state/ui/r18_operator_surface/r18_compact_failure_detector_snapshot.json`, `tools/R18CompactFailureDetector.psm1`, `tools/new_r18_compact_failure_detector.ps1`, `tools/validate_r18_compact_failure_detector.ps1`, `tests/test_r18_compact_failure_detector.ps1`, `tests/fixtures/r18_compact_failure_detector/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_010_compact_failure_detector/`.

### `R18-011` Implement WIP classifier
- Status: done
- Purpose: Create a deterministic WIP classifier foundation over committed seed git inventory samples before any future continuation, cleanup, stage, commit, or push gate work.
- Inputs: Seed git inventory samples, git status summaries, git diff summaries, staged/tracked/untracked path lists, allowed/forbidden paths, runner state refs, and failure event refs.
- Outputs: WIP classifier contract, profile, eight seed inventory samples, eight deterministic classification packets, results/check/snapshot artifacts, validator, tests, fixtures, and proof-review package.
- Acceptance criteria: Classifier distinguishes safe/no-WIP, scoped tracked WIP, unexpected tracked WIP, unsafe historical evidence edits, operator-local backup paths, untracked local notes, generated artifact churn, staged files, and WIP requiring operator decision without performing cleanup or recovery actions.
- Validation expectation: `tools/validate_r18_wip_classifier.ps1` and `tests/test_r18_wip_classifier.ps1` reject missing fields, unknown classifications/actions, unsafe historical evidence edits, operator-local backup paths, unexpected tracked WIP marked safe, staged files marked safe, generated churn without threshold policy, missing runner/failure/evidence/authority refs, runtime/API/recovery/remote/continuation/new-context/work-order/board/A2A/agent/skill/stage-commit-push claims, and status surfaces that advance R18 beyond R18-011.
- Non-claims: WIP classification is deterministic seed-inventory evidence only. It is not live git scanning, WIP cleanup, WIP abandonment, file restore/delete, staging, commit, push, remote branch verification, continuation packet generation, new-context prompt generation, recovery runtime/action, work-order execution, board/card runtime mutation, live agent/skill/A2A runtime, API invocation, automatic new-thread creation, product runtime, main merge, solved Codex compaction/reliability, or no-manual-prompt-transfer success.
- Dependencies: R18-010.
- Failure/retry behavior: Unsafe WIP blocks continuation and requests operator decision.
- Expected evidence refs: `contracts/runtime/r18_wip_classifier.contract.json`, `state/runtime/r18_wip_classifier_profile.json`, `state/runtime/r18_wip_inventory_samples/`, `state/runtime/r18_wip_classification_packets/`, `state/runtime/r18_wip_classifier_results.json`, `state/runtime/r18_wip_classifier_check_report.json`, `state/ui/r18_operator_surface/r18_wip_classifier_snapshot.json`, `tools/R18WipClassifier.psm1`, `tools/new_r18_wip_classifier.ps1`, `tools/validate_r18_wip_classifier.ps1`, `tests/test_r18_wip_classifier.ps1`, `tests/fixtures/r18_wip_classifier/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_011_wip_classifier/`.

### `R18-012` Implement remote branch verifier
- Status: done
- Purpose: Create a machine-checkable remote branch verifier foundation that validates local branch identity, local head/tree, expected remote head, remote branch identity, divergence classification, and safe/unsafe continuation decisions.
- Inputs: Branch name, expected local head/tree, expected remote head, bounded current branch/head/tree/remote-head observation, runner state ref, failure event ref, and WIP classifier result ref.
- Outputs: Remote branch verifier contract, profile, six deterministic seed samples, six deterministic verification packets, one bounded current-branch verification packet, results/check/snapshot artifacts, validator, invocation wrapper, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Verifier classifies remote-in-sync, remote-ahead, local-ahead, diverged, wrong-branch, and missing-remote-ref states; only remote-in-sync is branch-identity safe, local-ahead remains review-required in R18-012, and all unsafe states require operator decision without branch mutation.
- Validation expectation: `tools/validate_r18_remote_branch_verifier.ps1` and `tests/test_r18_remote_branch_verifier.ps1` reject missing fields, unknown statuses/actions, remote-ahead/local-ahead/diverged/wrong-branch/missing-remote marked safe, missing evidence/authority refs, forbidden runtime/API/recovery/continuation/new-context/WIP cleanup/branch mutation/pull/rebase/reset/merge/checkout/switch/clean/restore/stage/commit/push claims, and status surfaces that advance R18 beyond R18-012.
- Non-claims: Remote branch verifier foundation is bounded branch/head/tree/remote-head verification evidence only. It is not recovery, not continuation packet generation, not new-context prompt generation, not push, not merge, not rebase, not pull, not reset, not checkout/switch, not clean/restore, not staging, not commit, not release gate completion, not work-order execution, not board/card runtime mutation, not A2A runtime/message dispatch, not live agent/skill execution, not API invocation, not automatic new-thread creation, not product runtime, not main merge, and not solved Codex compaction/reliability or no-manual-prompt-transfer success.
- Dependencies: R18-011.
- Failure/retry behavior: Remote movement blocks continuation and escalates.
- Expected evidence refs: `state/runtime/r18_remote_branch_verification.json`, fixtures.

### `R18-013` Implement continuation packet generator
- Status: done
- Purpose: Create deterministic continuation packet contracts, input sets, and seed continuation packets from runner state, failure events, WIP classification, remote verification, and resume checkpoint refs.
- Inputs: R18-009 runner state and checkpoint, R18-010 failure events, R18-011 WIP classifications, R18-012 remote verification packets, validation command refs, evidence refs, and authority refs.
- Outputs: Continuation packet contract, generator contract, generator profile, six input sets, six continuation packets, results, check report, operator-surface snapshot, generator/validator tooling, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Each packet includes exact runner/failure/WIP/remote/checkpoint refs, current work order, current state, last completed step, next safe step, next safe step type, bounded retry count, stop conditions, escalation conditions, operator-decision policy, validation commands, allowed/forbidden paths, evidence refs, authority refs, runtime false flags, rejected claims, and non-claims.
- Validation expectation: `tools/validate_r18_continuation_packet_generator.ps1` and `tests/test_r18_continuation_packet_generator.ps1` reject missing refs, unknown continuation types, unbounded retries, missing stop conditions, missing operator-decision policy, missing validation commands, missing evidence/authority refs, unsafe WIP/remote decision packets without operator decision, execution claims, new-context prompt generation claims, automatic new-thread creation claims, recovery/retry/work-order execution claims, WIP cleanup/abandonment claims, branch mutation/pull/rebase/reset/merge/checkout/switch/clean/restore/stage/commit/push claims, board/A2A/agent/skill/API/product runtime claims, solved compaction/reliability claims, no-manual-prompt-transfer success claims, and R18-014 or later completion claims.
- Non-claims: Continuation packets are deterministic packet artifacts only. Continuation packets were not executed. New-context prompt generation, automatic new-thread creation, retry/escalation policy, operator approval gates, stage/commit/push gates, recovery runtime, work-order execution, live agents, live skills, A2A messages, board/card runtime mutation, API invocation, product runtime, and main merge are not implemented or claimed by R18-013.
- Dependencies: R18-010, R18-011, R18-012.
- Failure/retry behavior: Missing prerequisites, unsafe WIP, unsafe remote verification, unknown continuation type, or unbounded retry policy fails closed; R18-013 performs no retry execution.
- Expected evidence refs: `contracts/runtime/r18_continuation_packet.contract.json`, `contracts/runtime/r18_continuation_packet_generator.contract.json`, `state/runtime/r18_continuation_packet_generator_profile.json`, `state/runtime/r18_continuation_input_sets/`, `state/runtime/r18_continuation_packets/`, `state/runtime/r18_continuation_packet_generator_results.json`, `state/runtime/r18_continuation_packet_generator_check_report.json`, `state/ui/r18_operator_surface/r18_continuation_packet_snapshot.json`, `tools/R18ContinuationPacketGenerator.psm1`, `tools/new_r18_continuation_packet_generator.ps1`, `tools/validate_r18_continuation_packet_generator.ps1`, `tests/test_r18_continuation_packet_generator.ps1`, `tests/fixtures/r18_continuation_packet_generator/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_013_continuation_packet_generator/`.

### `R18-014` Implement new-context/new-thread prompt generator
- Status: done
- Purpose: Generate concise exact-ref continuation prompts without previous-thread memory dependency.
- Inputs: Continuation packet, authority refs, current work order, evidence refs, retry policy.
- Outputs: New-context prompt packet contract, generator contract, generator profile, six prompt input artifacts, six bounded prompt text packets, manifest, results, check report, operator-surface snapshot, generator/validator tooling, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Prompt packets are compact-safe, exact-ref, copy/paste-ready, context-independent, bounded by configured size limits, and scoped to the referenced continuation packet and next safe step.
- Validation expectation: `tools/validate_r18_new_context_prompt_generator.ps1` and `tests/test_r18_new_context_prompt_generator.ps1` reject missing prompt ids, missing continuation refs, missing repository/branch/head/tree/remote-head refs, missing last completed step, missing next safe step, missing allowed/forbidden paths, missing validation commands, missing stop conditions, missing non-claims, previous-thread memory dependency, oversized prompts, whole-milestone scope, broad repo scans, unbounded write paths, automatic new-thread creation claims, Codex/OpenAI API invocation claims, prompt execution claims, continuation packet execution claims, recovery/retry/work-order execution claims, WIP cleanup/abandonment claims, branch mutation/pull/rebase/reset/merge/checkout/switch/clean/restore/stage/commit/push claims, skill/A2A/board/product runtime claims, no-manual-prompt-transfer success claims, solved compaction/reliability claims, and R18-015 or later completion claims.
- Non-claims: New-context prompt packets are deterministic text artifacts only. Prompt packets were not executed. Automatic new-thread creation, Codex thread creation, Codex API invocation, OpenAI API invocation, continuation packet execution, retry/escalation policy, operator approval gates, stage/commit/push gates, recovery runtime, work-order execution, live agents, live skills, A2A messages, board/card runtime mutation, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, and main merge are not implemented or claimed by R18-014.
- Dependencies: R18-013.
- Failure/retry behavior: Oversized, incomplete, previous-thread-dependent, unbounded, or forbidden-claim prompt packets fail closed; R18-014 performs no retry execution.
- Expected evidence refs: `contracts/runtime/r18_new_context_prompt_packet.contract.json`, `contracts/runtime/r18_new_context_prompt_generator.contract.json`, `state/runtime/r18_new_context_prompt_generator_profile.json`, `state/runtime/r18_new_context_prompt_inputs/`, `state/runtime/r18_new_context_prompt_packets/`, `state/runtime/r18_new_context_prompt_packet_manifest.json`, `state/runtime/r18_new_context_prompt_generator_results.json`, `state/runtime/r18_new_context_prompt_generator_check_report.json`, `state/ui/r18_operator_surface/r18_new_context_prompt_snapshot.json`, `tools/R18NewContextPromptGenerator.psm1`, `tools/new_r18_new_context_prompt_generator.ps1`, `tools/validate_r18_new_context_prompt_generator.ps1`, `tests/test_r18_new_context_prompt_generator.ps1`, `tests/fixtures/r18_new_context_prompt_generator/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_014_new_context_prompt_generator/`.

### `R18-015` Implement retry and escalation policy
- Status: done
- Purpose: Create deterministic retry/escalation policy contracts, seed scenarios, decision packets, escalation/block recommendations, validator, fixtures, status snapshot, and proof-review artifacts for future runtime work.
- Inputs: R18-009 runner state/checkpoint, R18-010 failure events, R18-011 WIP classifications, R18-012 remote branch verification packets, R18-013 continuation packets, R18-014 prompt packets, authority refs, evidence refs, and bounded retry policy.
- Outputs: Retry/escalation policy contract, decision contract, policy profile, six seed scenarios, six decision packets, results, check report, operator-surface snapshot, validator, focused tests, fixtures, and proof-review package.
- Acceptance criteria: Retry is policy-allowed only when retry count is bounded and below max, WIP is safe, remote branch state is safe, continuation packet exists, prompt packet exists, and no unsafe stop condition exists. Unsafe WIP and unsafe remote branch state block retry and require operator decision. Retry exhaustion blocks retry and escalates. Operator-decision and future-runtime cases route to R18-016 or later without inferring approval or claiming execution.
- Validation expectation: `tools/validate_r18_retry_escalation_policy.ps1` and `tests/test_r18_retry_escalation_policy.ps1` reject missing refs, missing retry counts, unbounded retries, retry allowed with unsafe WIP, retry allowed with unsafe remote branch state, retry allowed after retry limit reached, missing operator decision policy, missing stop/escalation/evidence/authority refs, retry/recovery/operator-approval/stage-commit-push/continuation/prompt/API/work-order/WIP/branch/A2A/agent/skill/board/product runtime claims, no-manual-prompt-transfer success claims, solved compaction/reliability claims, and R18-016 or later completion claims.
- Non-claims: Retry/escalation decisions are deterministic policy artifacts only. Retry execution was not performed. Retry runtime, escalation runtime, operator approval runtime, stage/commit/push gates, recovery runtime, work-order execution, board/card runtime mutation, A2A messages, live agents, live skills, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, and main merge are not implemented or claimed by R18-015.
- Dependencies: R18-013, R18-014.
- Failure/retry behavior: Retry exhaustion creates a deterministic policy decision packet and stops; unsafe WIP or unsafe remote branch state routes to future operator decision without cleanup or branch action.
- Expected evidence refs: `contracts/runtime/r18_retry_escalation_policy.contract.json`, `contracts/runtime/r18_retry_escalation_decision.contract.json`, `state/runtime/r18_retry_escalation_policy_profile.json`, `state/runtime/r18_retry_escalation_scenarios/`, `state/runtime/r18_retry_escalation_decisions/`, `state/runtime/r18_retry_escalation_policy_results.json`, `state/runtime/r18_retry_escalation_policy_check_report.json`, `state/ui/r18_operator_surface/r18_retry_escalation_policy_snapshot.json`, `tools/R18RetryEscalationPolicy.psm1`, `tools/new_r18_retry_escalation_policy.ps1`, `tools/validate_r18_retry_escalation_policy.ps1`, `tests/test_r18_retry_escalation_policy.ps1`, `tests/fixtures/r18_retry_escalation_policy/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_015_retry_escalation_policy/`.

### `R18-016` Implement operator approval gate model
- Status: done
- Purpose: Create deterministic operator approval gate contracts, scoped request packets, refusal decision packets, an approval scope matrix, and validation artifacts only.
- Inputs: R18 authority, opening authority, retry/escalation policy and decisions, continuation packets, prompt packet manifest, remote branch verification, WIP classification packets, runner state, and revised R17 planning authority.
- Outputs: Approval gate contract, operator decision packet contract, approval gate profile, approval scope matrix, six request packets, six refusal/block decision packets, results, check report, operator-surface snapshot, validator, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Approval is explicit, finite-scope, evidence-backed, authority-backed, expirable, revocable/refusable, and impossible to infer from narration. All seed decision packets refuse or block stage/commit/push, recovery execution, API enablement, WIP abandonment, remote branch conflict resolution, and milestone closeout.
- Validation expectation: `tools/validate_r18_operator_approval_gate.ps1` and `tests/test_r18_operator_approval_gate.ps1` reject missing request/decision fields, unknown scopes/statuses, inferred approval, approval without explicit decision packet, approval without finite scope, approval without expiry or revocation policy, missing evidence or authority refs, risky seed approvals, runtime/API/recovery/stage-commit-push/work-order/board/A2A/agent/skill/product claims, no-manual-prompt-transfer success claims, solved compaction/reliability claims, and R18-017 or later completion claims.
- Non-claims: Operator approval gate artifacts are deterministic governance artifacts only. Operator approval runtime was not implemented. No approval was executed or inferred from narration. No seed packet approves stage/commit/push, recovery execution, API enablement, WIP abandonment, remote branch conflict resolution, or milestone closeout. Stage/commit/push gate, retry execution, recovery action, continuation execution, prompt execution, API invocation, work-order execution, board/card runtime mutation, A2A messages, live agents, live skills, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, main merge, and R18-017 or later completion are not claimed.
- Dependencies: R18-015.
- Failure/retry behavior: Missing, inferred, unscoped, expired, revoked, evidence-missing, or authority-missing approval fails closed and remains a policy artifact for future runtime work.
- Expected evidence refs: `contracts/governance/r18_operator_approval_gate.contract.json`, `contracts/governance/r18_operator_decision_packet.contract.json`, `state/governance/r18_operator_approval_gate_profile.json`, `state/governance/r18_operator_approval_scope_matrix.json`, `state/governance/r18_operator_approval_requests/`, `state/governance/r18_operator_approval_decisions/`, `state/governance/r18_operator_approval_gate_results.json`, `state/governance/r18_operator_approval_gate_check_report.json`, `state/ui/r18_operator_surface/r18_operator_approval_gate_snapshot.json`, `tools/R18OperatorApprovalGate.psm1`, `tools/new_r18_operator_approval_gate.ps1`, `tools/validate_r18_operator_approval_gate.ps1`, `tests/test_r18_operator_approval_gate.ps1`, `tests/fixtures/r18_operator_approval_gate/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_016_operator_approval_gate/`.

### `R18-017` Implement stage/commit/push gate
- Status: done
- Purpose: Create deterministic stage/commit/push gate contracts, gate input packets, assessment packets, refusal cases, validation artifacts, and proof-review evidence only.
- Inputs: WIP classification refs, remote verification refs, validation refs, status-doc gate refs, operator approval scope refs, retry/escalation policy refs, continuation/prompt packet refs, and R18 authority.
- Outputs: Stage/commit/push gate contract, assessment contract, gate profile, six gate inputs, six assessments, results, check report, operator-surface snapshot, validator, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Gate assessment requires explicit stage_commit_push_gate operator approval scope, safe WIP classification, safe remote branch verification, passing validation evidence, truthful R18 status boundary, allowed path scope, forbidden path refusal, evidence refs, authority refs, and runtime false flags before any future policy-only allow recommendation.
- Validation expectation: `tools/validate_r18_stage_commit_push_gate.ps1` and `tests/test_r18_stage_commit_push_gate.ps1` reject missing artifacts, missing fields, unknown scenarios/statuses/actions, safe release candidates without all prerequisite checks, blocked scenarios marked safe, stage/commit/push performed claims, live gate runtime claims, main merge or milestone closeout claims, operator approval runtime claims, recovery/retry/continuation/prompt/API/work-order/WIP/branch/A2A/agent/skill/board/product runtime claims, no-manual-prompt-transfer success claims, solved compaction/reliability claims, and R18-018 or later completion claims.
- Non-claims: R18-017 created stage/commit/push gate foundation only. Stage/commit/push gate artifacts are deterministic policy artifacts only. Gate runtime was not implemented. The gate did not stage, commit, or push. Normal Codex worker commit/push of this R18-017 task is not the gate executing. Main was not merged. Milestone closeout was not claimed. Operator approval runtime was not implemented. Recovery action was not performed. Retry execution was not performed. Continuation packets were not executed. Prompt packets were not executed. Codex/OpenAI API invocation did not occur. No work orders were executed. No board/card runtime mutation occurred. No A2A messages were sent. No live agents were invoked. No live skills were executed. No product runtime is claimed. No no-manual-prompt-transfer success is claimed.
- Dependencies: R18-012, R18-016.
- Failure/retry behavior: Failed gate creates deterministic assessment/refusal artifacts only; it does not execute recovery, retries, fixes, branch mutation, WIP cleanup, approval, staging, committing, or pushing.
- Expected evidence refs: `contracts/runtime/r18_stage_commit_push_gate.contract.json`, `contracts/runtime/r18_stage_commit_push_gate_assessment.contract.json`, `state/runtime/r18_stage_commit_push_gate_profile.json`, `state/runtime/r18_stage_commit_push_gate_inputs/`, `state/runtime/r18_stage_commit_push_gate_assessments/`, `state/runtime/r18_stage_commit_push_gate_results.json`, `state/runtime/r18_stage_commit_push_gate_check_report.json`, `state/ui/r18_operator_surface/r18_stage_commit_push_gate_snapshot.json`, `tools/R18StageCommitPushGate.psm1`, `tools/new_r18_stage_commit_push_gate.ps1`, `tools/validate_r18_stage_commit_push_gate.ps1`, `tests/test_r18_stage_commit_push_gate.ps1`, `tests/fixtures/r18_stage_commit_push_gate/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_017_stage_commit_push_gate/`.

### `R18-018` Implement status-doc gate automation wrapper
- Status: done
- Purpose: Create a deterministic status-doc gate automation wrapper foundation that consolidates status surface refs, expected boundary checks, non-claim checks, validation refs, evidence refs, authority refs, and policy-only assessments before any future release action is allowed.
- Inputs: Current milestone status, required status surfaces, expected R18/R17/main boundary, runtime false flags, hard non-claims, validation refs, evidence refs, and authority refs.
- Outputs: Status-doc gate wrapper contract, assessment contract, wrapper profile, five input packets, five assessment packets, results, check report, operator-surface snapshot, validator, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Current status surfaces pass policy-only after revalidation; missing status surfaces, boundary drift, runtime overclaims, and R18-020 premature claims block; all runtime false flags remain false; no live runtime, release gate execution, stage/commit/push, CI replay, GitHub Actions workflow, main merge, milestone closeout, external audit acceptance, recovery action, API invocation, automatic new-thread creation, work-order execution, board runtime mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction, or solved reliability claim is accepted.
- Validation expectation: `tools/validate_r18_status_doc_gate_wrapper.ps1`, `tests/test_r18_status_doc_gate_wrapper.ps1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1` pass while R18 remains active through R18-019 only.
- Non-claims: R18-018 created status-doc gate automation wrapper foundation only. Status-doc gate wrapper artifacts are deterministic policy artifacts only. Wrapper runtime was not implemented. Live status-doc gate runtime was not executed. Release gate was not executed. No stage/commit/push was performed by the wrapper. CI replay was not performed. GitHub Actions workflow was not created or run. Main was not merged. Milestone closeout was not claimed. External audit acceptance was not claimed. Recovery action was not performed. Codex/OpenAI API invocation did not occur. Automatic new-thread creation was not performed. No work orders were executed. No board/card runtime mutation occurred. No A2A messages were sent. No live agents were invoked. No live skills were executed. No product runtime is claimed. No no-manual-prompt-transfer success is claimed.
- Dependencies: R18-001, R18-017.
- Failure/retry behavior: Status mismatch creates deterministic blocked assessment artifacts only; the wrapper does not repair surfaces, execute recovery, infer approval, create threads, execute work orders, invoke APIs, run release automation, or perform stage/commit/push.
- Expected evidence refs: `contracts/governance/r18_status_doc_gate_wrapper.contract.json`, `contracts/governance/r18_status_doc_gate_assessment.contract.json`, `state/governance/r18_status_doc_gate_wrapper_profile.json`, `state/governance/r18_status_doc_gate_inputs/`, `state/governance/r18_status_doc_gate_assessments/`, `state/governance/r18_status_doc_gate_wrapper_results.json`, `state/governance/r18_status_doc_gate_wrapper_check_report.json`, `state/ui/r18_operator_surface/r18_status_doc_gate_wrapper_snapshot.json`, `tools/R18StatusDocGateWrapper.psm1`, `tools/new_r18_status_doc_gate_wrapper.ps1`, `tools/validate_r18_status_doc_gate_wrapper.ps1`, `tests/test_r18_status_doc_gate_wrapper.ps1`, `tests/fixtures/r18_status_doc_gate_wrapper/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_018_status_doc_gate_wrapper/`.

### `R18-019` Implement evidence package automation wrapper
- Status: done
- Purpose: Create deterministic evidence package wrapper contracts, package input packets, manifest, assessments, validation-command inventory, non-claim checks, CI-gap disclosure, validator, fixtures, read-only snapshot, and proof-review evidence only.
- Inputs: R18 authority refs, R17 closeout decision refs, R18-001 through R18-019 evidence refs, proof-review refs, validation manifest refs, status-surface refs, validator/test refs, and CI-gap disclosure.
- Outputs: Evidence package wrapper contract, manifest contract, wrapper profile, six input packets, current manifest, six assessment packets, results, check report, operator-surface snapshot, validator, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Package covers R18-001 through R18-019 plus required package groupings; completed entries have proof-review, validation-manifest, validator, and test refs; missing proof review, validation manifest, status surface, runtime overclaim, or undisclosed CI gap fails closed.
- Validation expectation: `tools/validate_r18_evidence_package_wrapper.ps1`, `tests/test_r18_evidence_package_wrapper.ps1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1` pass while R18 remains active through R18-019 only.
- Non-claims: Evidence package wrapper artifacts are deterministic policy/manifest artifacts only. Wrapper runtime was not implemented. Live evidence package runtime was not executed. Audit acceptance was not claimed. External audit acceptance was not claimed. Milestone closeout was not claimed. Main was not merged. CI replay was not performed. GitHub Actions workflow was not created or run. Release gate was not executed. No stage/commit/push was performed by the wrapper. Recovery action was not performed. Codex/OpenAI API invocation did not occur. Automatic new-thread creation was not performed. No work orders were executed. No board/card runtime mutation occurred. No A2A messages were sent. No live agents were invoked. No live skills were executed. No product runtime is claimed. No no-manual-prompt-transfer success is claimed. Codex compaction and reliability remain unresolved operational issues.
- Dependencies: R18-018.
- Failure/retry behavior: Missing evidence blocks package acceptance.
- Expected evidence refs: `contracts/governance/r18_evidence_package_wrapper.contract.json`, `contracts/governance/r18_evidence_package_manifest.contract.json`, `state/governance/r18_evidence_package_wrapper_profile.json`, `state/governance/r18_evidence_package_inputs/`, `state/governance/r18_evidence_package_manifests/current_r18_evidence_package.manifest.json`, `state/governance/r18_evidence_package_assessments/`, `state/governance/r18_evidence_package_wrapper_results.json`, `state/governance/r18_evidence_package_wrapper_check_report.json`, `state/ui/r18_operator_surface/r18_evidence_package_wrapper_snapshot.json`, `tools/R18EvidencePackageWrapper.psm1`, `tools/new_r18_evidence_package_wrapper.ps1`, `tools/validate_r18_evidence_package_wrapper.ps1`, `tests/test_r18_evidence_package_wrapper.ps1`, `tests/fixtures/r18_evidence_package_wrapper/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_019_evidence_package_wrapper/`.

### `R18-020` Implement board/card runtime event model
- Status: done
- Purpose: Create deterministic board/card runtime event model foundation artifacts that define how future runtime work will represent board events, card lifecycle changes, state transitions, handoff links, validation results, evidence links, operator decisions, release-gate assessments, and blocked/failure states without implementing live board/card runtime.
- Inputs: R17 board contracts, R18 runner state/store artifacts, R18 work-order seed packets, A2A handoff packets, operator approval model artifacts, release-gate wrapper artifacts, evidence package wrapper artifacts, and status authority refs.
- Outputs: Board/card event contract, event model contract, model profile, three seed cards, nine seed events, JSONL event log sample, registry, results, check report, operator-surface snapshot, validator, focused tests, invalid fixtures, and proof-review package.
- Acceptance criteria: Required cards/events/log/registry/results/check-report artifacts exist; all event/card required fields are present; event types, actor roles, and card statuses are known; handoff/validation/evidence/operator/release/failure refs are evidence-backed; all runtime false flags remain false; R18-021 through R18-028 remain planned only.
- Validation expectation: `tools/validate_r18_board_card_event_model.ps1`, `tests/test_r18_board_card_event_model.ps1`, `tools/validate_status_doc_gate.ps1`, and `tests/test_status_doc_gate.ps1` pass while R18 remains active through R18-020 only.
- Non-claims: Board/card event model artifacts are deterministic seed/policy artifacts only. Live board/card runtime was not implemented. Board/card runtime mutation was not performed. Live Kanban UI was not implemented. No work orders were executed. No A2A messages were sent. No live agents were invoked. No live skills were executed. No R18 runtime tool-call execution was performed. Codex/OpenAI API invocation did not occur. Recovery action was not performed. Release gate was not executed. CI replay was not performed. GitHub Actions workflow was not created or run. Product runtime is not claimed. No no-manual-prompt-transfer success is claimed. Codex compaction and reliability remain unresolved operational issues.
- Dependencies: R18-004, R18-008, R18-010, R18-016, R18-017, R18-018, R18-019.
- Failure/retry behavior: Invalid event model artifacts fail closed in validation only; the event model does not execute recovery, retries, approvals, work orders, A2A messages, release gates, stage/commit/push, tool calls, API calls, or live board mutation.
- Expected evidence refs: `contracts/board/r18_board_card_event.contract.json`, `contracts/board/r18_board_card_event_model.contract.json`, `state/board/r18_board_card_event_model_profile.json`, `state/board/r18_board_card_seed_cards/`, `state/board/r18_board_card_seed_events/`, `state/board/r18_board_card_event_log.jsonl`, `state/board/r18_board_card_event_registry.json`, `state/board/r18_board_card_event_model_results.json`, `state/board/r18_board_card_event_model_check_report.json`, `state/ui/r18_operator_surface/r18_board_card_event_model_snapshot.json`, `tools/R18BoardCardEventModel.psm1`, `tools/new_r18_board_card_event_model.ps1`, `tools/validate_r18_board_card_event_model.ps1`, `tests/test_r18_board_card_event_model.ps1`, `tests/fixtures/r18_board_card_event_model/`, and `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/r18_020_board_card_event_model/`.

### `R18-021` Implement agent invocation and tool-call evidence model
- Status: planned
- Purpose: Record agent invocation attempts, tool-call attempts, results, failures, and non-claims.
- Inputs: Agent cards, skill contracts, runner log, tool adapter profiles.
- Outputs: Invocation/tool-call evidence contract, ledger shape, validator, tests.
- Acceptance criteria: Ledger distinguishes planned, dry-run, failed, and live-approved calls; live calls require evidence and controls.
- Validation expectation: Planned validator rejects fake live tool calls and missing evidence refs.
- Non-claims: Evidence model is not agent invocation by itself.
- Dependencies: R18-002, R18-003, R18-009.
- Failure/retry behavior: Missing evidence records a failed/blocked invocation and stops dependent work.
- Expected evidence refs: `contracts/tools/r18_agent_tool_call_evidence.contract.json`, ledger fixtures.

### `R18-022` Implement safety, secrets, budget, and token controls
- Status: planned
- Purpose: Create controls required before any API-backed automation is enabled.
- Inputs: Skill registry, approval gate, runner shell, operator policy.
- Outputs: Secrets policy, budget/token policy, timeout policy, disabled API profile, validator/tests.
- Acceptance criteria: API disabled by default; secrets never committed; per-request/per-task budgets and timeouts exist; logs redact secrets; operator approval required.
- Validation expectation: Planned validator rejects unsafe secret, budget, token, timeout, or logging policies.
- Non-claims: Controls are not API invocation.
- Dependencies: R18-003, R18-016.
- Failure/retry behavior: Missing controls block API adapter work.
- Expected evidence refs: `contracts/security/r18_api_safety_controls.contract.json`, disabled profile, fixtures.

### `R18-023` Implement optional API adapter stub only after controls
- Status: planned
- Purpose: Add a disabled/dry-run API adapter stub only after safety controls exist.
- Inputs: R18-022 controls, operator enablement model, skill registry, evidence ledger.
- Outputs: Optional adapter stub, dry-run evidence packet shape, validator/tests.
- Acceptance criteria: Stub defaults disabled; live mode impossible without explicit controls, approval, budgets, and evidence packet requirements.
- Validation expectation: Planned validator rejects live API mode without controls and approval.
- Non-claims: No API invocation is claimed by a stub.
- Dependencies: R18-022.
- Failure/retry behavior: Missing approval or budget blocks adapter operation.
- Expected evidence refs: `contracts/tools/r18_optional_api_adapter_stub.contract.json`, dry-run fixtures.

### `R18-024` Exercise compact-failure recovery drill with local runner
- Status: planned
- Purpose: Prove the runner can handle a compact/stream failure drill through state preservation and continuation.
- Inputs: Runner state store, failure detector, WIP classifier, remote verifier, continuation generator, retry policy.
- Outputs: Drill packet, failure event, WIP classification, remote verification, continuation/new-context packets, evidence.
- Acceptance criteria: Drill records last completed step, next safe step, retry count, evidence refs, and operator decision points without claiming solved compaction.
- Validation expectation: Planned drill validator rejects packet-only recovery without runner evidence.
- Non-claims: Drill does not solve compaction or prove full product runtime.
- Dependencies: R18-010 through R18-016.
- Failure/retry behavior: Failed drill escalates with exact failure evidence and no runtime success claim.
- Expected evidence refs: compact-failure drill package, runner log, continuation packets.

### `R18-025` Retry Cycle 3 QA/fix-loop using compact-safe harness
- Status: planned
- Purpose: Retry the R17 Cycle 3 QA/fix-loop with the compact-safe runner harness.
- Inputs: R17 Cycle 3 prompt/work-order plan, R18 runner, Developer/QA roles, recovery loop.
- Outputs: Executed Cycle 3 work-order records, QA result packet, defect/repair evidence, recovery evidence if needed.
- Acceptance criteria: Evidence exceeds packet-only artifacts; Developer/QA handoff and validators run under the harness.
- Validation expectation: Planned validator rejects fake QA/fix-loop completion and missing runtime evidence.
- Non-claims: Does not claim four cycles or solved compaction.
- Dependencies: R18-024 and required Developer/QA evidence models.
- Failure/retry behavior: Compact/validation failure routes through R18 recovery.
- Expected evidence refs: Cycle 3 execution package, QA packets, defect packets, board events.

### `R18-026` Retry Cycle 4 audit/closeout using compact-safe harness
- Status: planned
- Purpose: Exercise audit/closeout flow under the harness without claiming external audit acceptance.
- Inputs: Cycle 3 results, evidence package wrapper, Evidence Auditor model, release gate.
- Outputs: Cycle 4 audit/closeout package, audit verdict packet, release gate result, closeout-candidate packet.
- Acceptance criteria: Evidence Auditor reviews machine-readable evidence; release gate enforces validators, status docs, evidence, and approvals.
- Validation expectation: Planned validator rejects missing evidence, overclaims, and closeout without operator approval.
- Non-claims: No external audit acceptance, no main merge, no closeout without operator approval.
- Dependencies: R18-019, R18-021, R18-025.
- Failure/retry behavior: Audit failure creates repair handoff or blocks closeout.
- Expected evidence refs: Cycle 4 package, audit packets, release gate report.

### `R18-027` Measure operator burden reduction
- Status: planned
- Purpose: Measure whether R18 reduced repetitive manual GPT-to-Codex copy/paste recovery work.
- Inputs: Runner logs, failure drills, continuation events, operator approval records, manual intervention counts.
- Outputs: Burden reduction report, metrics contract, validation packet.
- Acceptance criteria: Metrics distinguish routine recovery automation from operator approvals and prove or reject no-manual-transfer progress honestly.
- Validation expectation: Planned validator rejects anecdotal burden claims without counts and evidence refs.
- Non-claims: No no-manual-prompt-transfer success unless metrics prove it.
- Dependencies: R18-024 through R18-026.
- Failure/retry behavior: Insufficient evidence marks burden reduction unproved and keeps claim false.
- Expected evidence refs: metrics report, runner log summary, approval/intervention counts.

### `R18-028` Produce R18 final proof package and acceptance recommendation
- Status: planned
- Purpose: Package R18 evidence and produce an acceptance recommendation for operator decision.
- Inputs: R18 evidence ledger, recovery drills, Cycle 3/4 packages, validators, status gates, burden metrics.
- Outputs: R18 final report, KPI movement scorecard, evidence index, proof review, validation manifest, final-head support packet, decision recommendation.
- Acceptance criteria: Runtime claims are backed by execution evidence; unresolved gaps remain explicit; operator approval remains required for closeout.
- Validation expectation: Planned final package validator, focused test, status-doc gate, and `git diff --check`.
- Non-claims: Final package is not operator approval, external audit acceptance, or main merge.
- Dependencies: R18-001 through R18-027.
- Failure/retry behavior: Insufficient evidence keeps R18 active/partial and creates a repair plan.
- Expected evidence refs: R18 final proof package, validation manifest, final-head support packet, operator decision packet.
