# R18 Automated Recovery Runtime and API Orchestration

**Milestone name:** R18 Automated Recovery Runtime and API Orchestration
**Branch:** `release/r17-agentic-operating-surface-a2a-runtime-kanban-release-cycle`
**Status after this pass:** Active through `R18-008` work-order execution state machine foundation only.
**Source authority:** R18 is active only after R17 operator closeout approval in `state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json`.
**Current scope:** `R18-001` through `R18-008` are done. `R18-009` through `R18-028` are planned only. R18 runtime implementation is not yet delivered.

## Mission

R18 exists to reduce the manual GPT-to-Codex recovery loop by implementing, in later tasks, a governed local runner/CLI, failure detection, WIP classification, remote branch verification, continuation packet generation, new-context prompt generation, retry limits, escalation, evidence capture, and operator decision gates.

API-backed Codex/OpenAI invocation is optional and must not be implemented before secrets, budget, timeout, retry, approval, and stop controls exist. R18 must use small resumable work orders, not giant Codex prompts. R18 must preserve fail-closed behavior.

## Current Non-Claims

- R18 runtime implementation is not yet delivered.
- R18-009 through R18-028 are planned only.
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
- Runner state store is not implemented.
- Resumable execution log is not implemented.
- No work orders were executed.
- No board/card runtime mutation occurred.
- No A2A messages were sent.
- No live agents were invoked.
- No live skills were executed.
- No local runner runtime was executed.
- No product runtime is claimed.
- No live recovery runtime is claimed.
- No live A2A runtime is claimed.
- No OpenAI API invocation is claimed.
- No Codex API invocation is claimed.
- No autonomous Codex invocation is claimed.
- No automatic new-thread creation is claimed.
- No stage/commit/push was performed by the runner or state machine.
- No main merge is claimed.
- No solved Codex compaction or reliability is claimed.
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
- Status: planned
- Purpose: Persist runner state and execution logs so continuation does not depend on chat memory.
- Inputs: State machine, work-order packets, git inventory, validator outputs.
- Outputs: State store contract, JSON/JSONL execution log, resume-state validator.
- Acceptance criteria: Store records current work order, last completed step, next safe step, retry count, evidence refs, and git identity.
- Validation expectation: Planned validator rejects missing baseline, missing step refs, or stale state.
- Non-claims: Persisted state is not automatic recovery by itself.
- Dependencies: R18-008.
- Failure/retry behavior: Corrupt or incomplete state blocks continuation and escalates.
- Expected evidence refs: `state/runtime/r18_runner_state.json`, `state/runtime/r18_execution_log.jsonl`, fixtures.

### `R18-010` Implement compact failure detector
- Status: planned
- Purpose: Detect compact/context/stream failure signals and record machine-readable failure events.
- Inputs: Runner execution log, command results, operator failure note when needed.
- Outputs: Failure event contract, detector, check report, tests.
- Acceptance criteria: Detector classifies compact failure, stream disconnect, validation failure, status-doc gate failure, branch movement, unsafe WIP, generated churn, API/token budget failure, and operator abort.
- Validation expectation: Planned validator rejects unknown unclassified failures unless escalated.
- Non-claims: Detection is not recovery completion.
- Dependencies: R18-009.
- Failure/retry behavior: Unknown failure becomes operator decision required.
- Expected evidence refs: `contracts/runtime/r18_failure_event.contract.json`, failure event fixtures.

### `R18-011` Implement WIP classifier
- Status: planned
- Purpose: Preserve and classify local WIP before continuation, cleanup, stage, commit, or push.
- Inputs: Git status, git diff summaries, allowed/forbidden paths, work-order scope.
- Outputs: WIP classification packet, preservation recommendation, validator.
- Acceptance criteria: Classifier distinguishes no WIP, scoped tracked WIP, unexpected tracked WIP, unsafe historical diff, untracked notes, generated churn, and operator-decision WIP.
- Validation expectation: Planned validator rejects unclassified tracked WIP and historical evidence edits.
- Non-claims: Classification does not make WIP safe to commit.
- Dependencies: R18-010.
- Failure/retry behavior: Unsafe WIP blocks continuation and requests operator decision.
- Expected evidence refs: `state/runtime/r18_wip_classification.json`, fixtures, check report.

### `R18-012` Implement remote branch verifier
- Status: planned
- Purpose: Verify local and remote branch identity before continuation and release actions.
- Inputs: Branch name, expected local head/tree, expected remote head, work-order state.
- Outputs: Remote verification packet, validator, tests.
- Acceptance criteria: Verifier fails on missing remote, moved remote head, divergence, stale expected head/tree, or wrong branch.
- Validation expectation: Planned validator rejects branch movement without operator decision.
- Non-claims: Verification is not push, merge, or final-head support.
- Dependencies: R18-011.
- Failure/retry behavior: Remote movement blocks continuation and escalates.
- Expected evidence refs: `state/runtime/r18_remote_branch_verification.json`, fixtures.

### `R18-013` Implement continuation packet generator
- Status: planned
- Purpose: Generate continuation packets from runner state, failure events, WIP classification, and remote verification.
- Inputs: Failure event, WIP classification, remote verification, runner state, evidence log.
- Outputs: Continuation packet contract, generator, packets, tests.
- Acceptance criteria: Packet includes failure type, baseline head/tree, last completed step, next safe step, retry count, validation commands, evidence refs, approval state, and stop conditions.
- Validation expectation: Planned validator rejects packets missing failure/WIP/remote evidence.
- Non-claims: Continuation packet is not live recovery until consumed in a drill.
- Dependencies: R18-010, R18-011, R18-012.
- Failure/retry behavior: Missing prerequisites block packet generation.
- Expected evidence refs: `state/runtime/r18_continuation_packets/`, check report, fixtures.

### `R18-014` Implement new-context/new-thread prompt generator
- Status: planned
- Purpose: Generate concise exact-ref continuation prompts without previous-thread memory dependency.
- Inputs: Continuation packet, authority refs, current work order, evidence refs, retry policy.
- Outputs: New-context packet contract, prompt packet files, validator, tests.
- Acceptance criteria: Prompt includes accepted refs, last completed step, next safe step, allowed paths, forbidden paths, validators, non-claims, and stop conditions.
- Validation expectation: Planned validator rejects giant prompts, missing refs, and prior-thread dependency.
- Non-claims: Prompt generation is not automatic Codex thread creation.
- Dependencies: R18-013.
- Failure/retry behavior: Oversized or incomplete prompt fails closed and escalates.
- Expected evidence refs: `state/runtime/r18_new_context_packets/`, prompt files, fixtures.

### `R18-015` Implement retry and escalation policy
- Status: planned
- Purpose: Enforce retry limits, escalation conditions, and stop behavior in runner state.
- Inputs: Failure events, continuation packets, runner state, operator approval policy.
- Outputs: Retry policy contract, retry state, escalation packets, validator.
- Acceptance criteria: Retry limit persists; escalation triggers on retry exhaustion, unsafe WIP, remote movement, failed gates, API/token budget failure, and operator abort.
- Validation expectation: Planned validator rejects unbounded retry loops.
- Non-claims: Retry policy does not solve Codex reliability.
- Dependencies: R18-013, R18-014.
- Failure/retry behavior: Retry exhaustion creates an operator decision packet and stops.
- Expected evidence refs: `state/runtime/r18_retry_state.json`, escalation packets, fixtures.

### `R18-016` Implement operator approval gate model
- Status: planned
- Purpose: Keep routine recovery automated while preserving explicit approval for risky decisions.
- Inputs: Retry/escalation policy, runner state, role-skill matrix, status gates.
- Outputs: Approval gate contract, approval/denial packet shapes, validator.
- Acceptance criteria: Approval is required for WIP abandonment, API enablement, risky stage/commit/push, closeout, main merge, external audit claim, and remote conflict handling.
- Validation expectation: Planned validator rejects actions requiring approval when no approval packet exists.
- Non-claims: Approval gate does not automate operator decisions.
- Dependencies: R18-015.
- Failure/retry behavior: Missing approval blocks the action and records pending decision.
- Expected evidence refs: `contracts/governance/r18_operator_approval_gate.contract.json`, approval fixtures.

### `R18-017` Implement stage/commit/push gate
- Status: planned
- Purpose: Prevent unsafe commits and pushes until validation, evidence, status, remote, and approval gates pass.
- Inputs: WIP classification, remote verification, validators, status-doc gate, evidence package gate, approval state.
- Outputs: Gate contract, command wrapper, gate report, tests.
- Acceptance criteria: Gate requires passing validators, `git diff --check`, allowed-path check, overclaim check, status-doc gate, evidence package gate, and required approval.
- Validation expectation: Planned validator blocks push on any failed prerequisite.
- Non-claims: Gate definition is not a push and does not merge main.
- Dependencies: R18-012, R18-016.
- Failure/retry behavior: Failed gate creates a failure event and returns to recovery or operator decision.
- Expected evidence refs: gate report, command logs, approval packet.

### `R18-018` Implement status-doc gate automation wrapper
- Status: planned
- Purpose: Keep README, ACTIVE_STATE, KANBAN, authority docs, decision log, and non-claims synchronized.
- Inputs: Current milestone status, task completions, runtime flags, hard non-claims.
- Outputs: R18 status-doc gate wrapper, validator/test updates, repair guidance.
- Acceptance criteria: Gate rejects R18 overclaims, R17 closure without approval, R18 closeout without proof, API invocation without controls, and main merge claims.
- Validation expectation: `tools/validate_status_doc_gate.ps1` and `tests/test_status_doc_gate.ps1` remain passing.
- Non-claims: Status docs are not runtime proof.
- Dependencies: R18-001, R18-017.
- Failure/retry behavior: Status mismatch blocks commit/push and creates repair work.
- Expected evidence refs: status gate module, test output, validation manifest.

### `R18-019` Implement evidence package automation wrapper
- Status: planned
- Purpose: Generate evidence packages from machine-readable runtime evidence instead of prose alone.
- Inputs: Evidence ledger, board events, work-order records, failure packets, continuation packets, validator outputs.
- Outputs: Evidence package generator, evidence index, proof review, validation manifest, final-head support candidate.
- Acceptance criteria: Package includes runtime flags, rejected claims, evidence refs, validation commands, and residual risks.
- Validation expectation: Planned validator rejects report-only proof and missing evidence refs.
- Non-claims: Evidence package is not external audit acceptance.
- Dependencies: R18-018.
- Failure/retry behavior: Missing evidence blocks package acceptance.
- Expected evidence refs: `state/proof_reviews/r18_automated_recovery_runtime_and_api_orchestration/`, package fixtures.

### `R18-020` Implement board/card runtime event model
- Status: planned
- Purpose: Define append-only board/card runtime events for work orders, failures, handoffs, approvals, and evidence.
- Inputs: R17 board contracts, runner state, A2A handoffs, approval packets.
- Outputs: Runtime board event contract, event log shape, validator, tests.
- Acceptance criteria: Events are append-only, scoped to cards/work orders, evidence-backed, and reject historical rewrites.
- Validation expectation: Planned validator rejects mutation of historical evidence and missing event evidence.
- Non-claims: Event model is not a live UI or product runtime.
- Dependencies: R18-004, R18-009, R18-016.
- Failure/retry behavior: Invalid event blocks board state advancement.
- Expected evidence refs: `contracts/board/r18_runtime_board_event.contract.json`, event fixtures.

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
