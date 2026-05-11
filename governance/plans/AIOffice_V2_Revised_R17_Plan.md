# AIOffice V2 Revised R17 Plan: R18 Automated Recovery Runtime and API Orchestration Execution Plan

**Filename retained per operator request:** `AIOffice_V2_Revised_R17_Plan.md`
**Actual purpose:** revised R18 execution plan based on R17 audit findings and project vision
**Repository:** `RodneyMuniz/AIOffice_V2`
**R17 audited posture:** active through `R17-028` final package only; closeout candidate pending operator decision
**R18 status:** not opened by this plan
**Plan status:** execution-ready planning artifact for Orchestrator use; not implementation proof

---

## 1. R18 thesis

R18 must turn R17's recovery and orchestration foundations into a small-work-order, state-preserving, failure-aware runtime loop. The first product value target is not broader reporting. The first product value target is reducing the operator's repetitive manual GPT-to-Codex recovery burden after Codex compaction, validation failure, stream interruption, stale context, branch movement, and unsafe WIP.

R18 should make the Orchestrator usable through a chat/control surface, backed by a local runner/CLI that can execute bounded work orders, preserve state, detect failure, classify WIP, verify remote branch state, generate continuation packets, generate new-context/new-thread prompts, enforce retries, escalate only at decision points, and record evidence.

R18 must not continue the old workflow of giant Codex prompts and manually pasted resume prompts. Every task is designed around small work orders, resumable execution, explicit role handoff, fail-closed validation, and evidence trails.

---

## 2. R18 success definition

R18 can be accepted only if committed evidence proves the following:

1. R18 is explicitly opened in repo truth by operator-approved authority artifacts.
2. A live local runner/CLI can execute one bounded work order at a time and persist state.
3. The Orchestrator chat/control surface can create or select a governed card, select the next work order, and show status/evidence without requiring the operator to manually build recovery prompts.
4. Agent cards are explicit and validated.
5. Skill contracts are explicit and validated.
6. A2A handoff packets are explicit, target roles validate handoffs before acting, and handoff failures trigger retry/block/operator-decision paths.
7. Compact/stream/validation/status-gate failures are detected and recorded as machine-readable failure events.
8. Local WIP is preserved and classified before continuation.
9. Remote branch/head/tree state is verified before continuation.
10. Continuation packets are generated automatically from runner state.
11. New-context/new-thread prompt packets are generated automatically and do not depend on previous thread memory.
12. Retry and escalation limits are enforced by runtime state, not prose.
13. Stage/commit/push gates fail closed unless validators, status-doc gates, evidence package gates, and required approvals pass.
14. Cycle 3 QA/fix-loop is retried using the harness and produces evidence beyond prompt packets.
15. Cycle 4 audit/closeout is retried using the harness and produces evidence beyond prompt packets.
16. Manual recovery burden is measurably reduced. The operator should approve decisions; the operator should not repeatedly copy/paste routine resume prompts.
17. R18 final proof package includes runtime evidence, failure drills, validation manifests, status gates, and hard non-claims.

---

## 3. R18 non-goals and non-claims

R18 must preserve these boundaries until evidence proves otherwise:

- R18 is not opened by this plan.
- R18 does not close R17 unless operator approval is explicitly recorded first.
- R18 does not merge to `main` unless explicitly authorized.
- R18 does not claim external audit acceptance by generating internal reports.
- R18 does not claim solved Codex compaction.
- R18 does not claim solved Codex reliability.
- R18 does not claim no-manual-prompt-transfer success until a runtime drill proves routine continuation without repetitive operator prompt relay.
- R18 does not invoke OpenAI or Codex APIs until secrets, cost, budget, retry, and approval controls exist and pass.
- R18 does not treat agent cards as live agents.
- R18 does not treat prompt packets as automation.
- R18 does not treat continuation packets as live recovery unless the runner generates and consumes them during a drill.
- R18 does not treat static UI snapshots as product runtime.
- R18 does not treat packet-only Cycle 3 or Cycle 4 artifacts as exercised cycles.

---

## 4. R18 architecture target

R18 should produce a minimal but real local orchestration architecture:

### Runtime components

- **Operator chat/control surface:** accepts operator intent, shows cards, work orders, current state, failures, approvals, and evidence refs.
- **Orchestrator runtime controller:** selects the current card/work order, validates authority, routes to roles, and manages state transitions.
- **Local runner/CLI shell:** executes one small work order at a time, captures state, runs validators, writes evidence, and stops safely.
- **Agent card registry:** stores role identity, authority, skills, memory refs, evidence duties, forbidden actions, retry/failover behavior, and approval gates.
- **Skill registry:** stores approved executable or modelled skills with input/output contracts and evidence requirements.
- **A2A handoff ledger:** stores source role, target role, card ID, required inputs, expected outputs, current state, next allowed actions, and validation result.
- **Recovery controller:** detects failure, preserves state, classifies WIP, verifies remote, generates continuation/new-context packets, enforces retries, and escalates.
- **Evidence ledger:** records commands, validators, generated artifacts, tool calls, decisions, failures, retries, and approvals.
- **Board/card state store:** tracks cards, lanes, blockers, agent assignments, evidence refs, and decision gates.
- **Approval gate:** blocks risky actions such as abandoning WIP, pushing commits, invoking APIs, or closing milestones.
- **Optional API adapter layer:** only after secrets/cost controls, used for OpenAI/Codex integrations under strict budgets.

### Runtime principle

The system should always know the current work order, last safe step, next safe step, current branch/head/tree, WIP classification, retry count, evidence refs, and approval state.

---

## 5. Required agent cards

Each agent card must include:

- `agent_id`
- `display_name`
- `role`
- `authority_scope`
- `allowed_skills`
- `forbidden_actions`
- `required_inputs`
- `required_outputs`
- `memory_refs`
- `evidence_obligations`
- `handoff_rules`
- `retry_behavior`
- `failover_behavior`
- `approval_gates`
- `runtime_flags`
- `non_claims`

### Minimum required cards

1. **Operator**
   - Approves closeout, branch movement, API enablement, WIP abandonment, and risky pushes.
   - Does not perform routine recovery prompt assembly.

2. **Orchestrator**
   - Owns card routing, work-order selection, handoff validation, retry state, and operator decision requests.
   - Cannot bypass QA, evidence audit, status gates, or approval gates.

3. **Product Manager / Planner**
   - Defines acceptance criteria, card scope, constraints, and release goals.
   - Cannot implement code or approve own delivery.

4. **Architect**
   - Defines contracts, boundaries, allowed paths, and schema decisions.
   - Cannot claim runtime execution without runner evidence.

5. **Developer / Codex Executor**
   - Performs bounded implementation or artifact-generation work orders through the runner.
   - Cannot push, merge, invoke APIs, or modify forbidden paths without approval.

6. **QA/Test Agent**
   - Runs validators/tests, records failures, produces defect packets, and requests repair loops.
   - Cannot approve release or suppress failed validators.

7. **Evidence Auditor**
   - Reviews evidence refs, non-claims, validators, status gates, and overclaim risk.
   - Cannot create implementation artifacts or self-approve external audit acceptance.

8. **Recovery Controller**
   - Detects failures, preserves state, classifies WIP, generates continuation/new-context packets, and enforces retry limits.
   - Cannot abandon tracked WIP or push without required approval.

9. **Release Manager**
   - Runs stage/commit/push gates after validators and approvals pass.
   - Cannot close R17/R18 or merge to `main` without explicit operator approval.

10. **Evidence/Board Curator**
    - Updates evidence indexes, board events, status docs, and final proof packages.
    - Cannot rewrite historical evidence or inflate claims.

---

## 6. Required skills and skill contracts

A skill is not a narrative ability. A skill is a governed callable operation or bounded modelled operation with inputs, outputs, validators, failure behavior, and evidence obligations.

### Required skill contract fields

- `skill_id`
- `skill_name`
- `allowed_roles`
- `forbidden_roles`
- `input_contract`
- `output_contract`
- `allowed_paths`
- `forbidden_paths`
- `commands_allowed`
- `commands_forbidden`
- `secrets_policy`
- `cost_policy`
- `token_policy`
- `timeout_policy`
- `retry_policy`
- `failure_packet_schema`
- `evidence_refs_required`
- `approval_required_when`
- `validator_refs`
- `runtime_flags`

### Minimum required skills

- `read_authority_refs`
- `load_card_context`
- `create_or_update_card`
- `generate_small_work_order`
- `validate_agent_card`
- `validate_skill_contract`
- `create_a2a_handoff`
- `validate_a2a_handoff`
- `execute_work_order_locally`
- `run_validation_command`
- `record_failure_event`
- `detect_compact_or_stream_failure`
- `preserve_local_state`
- `classify_wip`
- `verify_remote_branch`
- `generate_continuation_packet`
- `generate_new_context_prompt`
- `enforce_retry_limit`
- `request_operator_approval`
- `stage_commit_push_with_gates`
- `generate_evidence_package`
- `update_status_docs`
- `invoke_optional_api_adapter` after controls only

---

## 7. Required A2A handoff model

Every handoff packet must include:

- `handoff_id`
- `card_id`
- `source_role`
- `target_role`
- `source_agent_id`
- `target_agent_id`
- `source_task_id`
- `target_task_id`
- `authority_refs`
- `memory_refs`
- `input_refs`
- `expected_output_refs`
- `evidence_refs`
- `current_state`
- `next_allowed_actions`
- `forbidden_actions`
- `validation_commands`
- `approval_gates`
- `retry_count`
- `retry_limit`
- `failure_packet_ref`
- `status`

### Handoff lifecycle

1. Source role creates handoff packet.
2. Orchestrator validates source authority and target authority.
3. Target role validates required inputs before acting.
4. Runner records acceptance or rejection.
5. Rejection triggers one of: repair, retry, block, recovery, or operator decision.
6. Successful handoff produces evidence and board event.

---

## 8. Required recovery-loop model

The recovery loop must be runtime-backed, not packet-only.

### Failure event types

- `codex_compact_failure`
- `stream_disconnected_before_completion`
- `validation_failure`
- `status_doc_gate_failure`
- `unexpected_tracked_wip`
- `remote_branch_moved`
- `unsafe_historical_diff`
- `generated_artifact_churn`
- `api_budget_exceeded`
- `token_budget_exceeded`
- `operator_abort`

### Recovery stages

1. Detect failure.
2. Freeze current work-order state.
3. Capture local git inventory.
4. Preserve safe tracked WIP.
5. Classify WIP.
6. Verify remote branch/head/tree.
7. Generate failure packet.
8. Generate continuation packet.
9. Generate new-context/new-thread prompt packet when needed.
10. Select next safe step.
11. Retry within limits or escalate.
12. Run validators.
13. Record evidence and board event.

### Mandatory fail-closed cases

- remote branch moved unexpectedly;
- unsafe historical diff;
- unclassified tracked WIP;
- missing baseline head/tree;
- missing evidence refs;
- retry limit reached;
- invalid handoff packet;
- status-doc gate failure;
- API budget/cost policy violation;
- attempt to claim runtime success without runtime evidence.

---

## 9. Required compact failure/new-thread continuation model

Codex compaction must be assumed. R18 must not attempt to solve compaction by longer prompts.

### Required behavior

- Detect compact/stream/context failure from runner-visible signals or explicit operator failure input.
- Preserve local state before any cleanup.
- Record branch/head/tree and diff inventory.
- Classify WIP as safe scoped WIP, unsafe WIP, untracked ignored notes, generated churn, or operator-decision required.
- Verify remote branch before continuation.
- Generate a continuation packet with `last_completed_step` and `next_safe_step`.
- Generate a new-context prompt packet that is short, exact-ref based, and independent of previous thread memory.
- Prevent duplicate/regenerated artifacts through artifact IDs and checksums where practical.
- Enforce retry limit and escalate rather than loop forever.
- Show the operator the decision, not a raw prompt relay, except where manual external tool constraints still require a single copy action.

---

## 10. Required operator-chat Orchestrator experience

The operator should interact with the Orchestrator through a chat/control surface. Minimum experience:

- View active milestone, branch, head/tree, current card, current work order, current role, and current state.
- Ask the Orchestrator to continue, retry, stop, approve, reject, or inspect evidence.
- See failure events and recovery status in plain language backed by machine refs.
- Approve only decision points: API enablement, push, WIP abandonment, closeout, merge, external audit claim.
- Avoid routine manual copy/paste for compact recovery.
- Receive generated new-context prompt packets only when external tooling cannot be invoked directly.
- See a board/card timeline of handoffs, validators, defects, retries, and evidence.

---

## 11. Required runner/CLI responsibilities

The local runner/CLI must:

- accept one work order at a time;
- validate work-order schema before execution;
- enforce allowed/forbidden paths;
- capture git status/head/tree before and after execution;
- run configured validators;
- write failure events and continuation packets;
- update board/card state;
- write evidence refs;
- stop on missing authority, unsafe WIP, branch movement, failed validators, or over-budget API/token use;
- require operator approval for stage/commit/push, WIP abandonment, API invocation, closeout, and merge;
- never silently continue after ambiguous state.

---

## 12. Required evidence model

Every runtime action must produce evidence:

- work-order packet;
- runner execution record;
- command log summary;
- validation result;
- failure packet when applicable;
- continuation packet when applicable;
- A2A handoff packet when applicable;
- board event;
- evidence ledger entry;
- approval packet when required;
- artifact refs and checksums where practical;
- final proof package refs.

Generated Markdown is not sufficient evidence unless backed by machine-readable artifacts and validators.

---

## 13. Required board/card model

Each card must track:

- `card_id`
- title and purpose;
- owning role;
- current lane/state;
- current work order;
- source authority refs;
- acceptance criteria;
- allowed paths;
- forbidden paths;
- active agent;
- pending handoff;
- retry count;
- blocker state;
- failure events;
- evidence refs;
- validator refs;
- approval requirements;
- closeout status;
- non-claims.

Board events must be append-only. Historical evidence edits must fail closed unless explicitly authorized and recorded.

---

## 14. Required stage/commit/push controls

Stage/commit/push must be gated by:

1. current branch verification;
2. remote branch verification;
3. clean or classified WIP;
4. allowed-path check;
5. forbidden-path check;
6. `git diff --check`;
7. task validator;
8. focused test;
9. status-doc gate;
10. evidence package gate;
11. overclaim/non-claim gate;
12. operator approval when required.

No push should occur after failed validation, unclassified WIP, remote branch movement, unsafe historical diff, or missing evidence refs.

---

## 15. Required safety/cost/token controls

R18 must introduce controls before API-backed automation:

- secrets are never committed;
- API execution is disabled by default;
- API adapter requires operator-approved enablement;
- per-request token cap is defined;
- per-task token cap is defined;
- per-task cost cap is defined;
- retry budget is defined;
- timeout is defined;
- runaway-loop stop condition is defined;
- logs redact secrets;
- API calls produce evidence packets;
- failed API calls produce machine-readable failure packets;
- budget exhaustion blocks continuation and requests operator decision.

---

## 16. Detailed R18 task list

### R18-001 — Open R18 status authority

- **Purpose:** Explicitly open R18 in repo truth only after operator decision; preserve R17 closeout boundary.
- **Inputs:** R17 final audit report, R17 authority doc, operator approval record, current branch/head/tree.
- **Outputs:** R18 authority document, status-doc updates, decision-log entry, initial R18 board/card entry.
- **Acceptance criteria:** R18 active status is explicit; R17 closeout decision is recorded or R17 remains active with no implied closure; R18 non-claims are present.
- **Validation commands or expected validators:** `tools/validate_r18_status_authority.ps1`; `tests/test_r18_status_authority.ps1`; `tools/validate_status_doc_gate.ps1`; `git diff --check`.
- **Non-claims:** No runtime, no API invocation, no R17 closeout unless operator approval is recorded, no main merge.
- **Dependencies:** Operator decision after R17 audit.
- **Failure/retry behavior:** If operator decision is missing or contradictory, stop and request operator decision. Do not infer approval.
- **Evidence refs expected:** `governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md`; `governance/DECISION_LOG.md`; `execution/KANBAN.md`; status gate report.

### R18-002 — Define runtime-grade agent card schema

- **Purpose:** Replace loose agent identity packets with enforceable agent cards.
- **Inputs:** R17 agent registry, R17 Orchestrator identity contract, R18 authority.
- **Outputs:** `contracts/agents/r18_agent_card.contract.json`; seed cards for Operator, Orchestrator, PM, Architect, Developer/Codex, QA/Test, Evidence Auditor, Recovery Controller, Release Manager, Evidence/Board Curator.
- **Acceptance criteria:** Every card has identity, role, authority, allowed skills, forbidden actions, required inputs/outputs, memory refs, evidence obligations, handoff rules, retry/failover behavior, and approval gates.
- **Validation commands or expected validators:** `tools/validate_r18_agent_cards.ps1`; `tests/test_r18_agent_cards.ps1`.
- **Non-claims:** Agent cards are not live agents; schema validation is not runtime invocation.
- **Dependencies:** R18-001.
- **Failure/retry behavior:** Missing authority, missing forbidden actions, or unbounded skill permission fails closed.
- **Evidence refs expected:** contract, generated cards, check report, fixtures, proof-review package.

### R18-003 — Define skill contract schema and skill registry

- **Purpose:** Make role capabilities explicit and auditable.
- **Inputs:** R18 agent cards, R17 tool adapter contracts, R17 recovery-loop contract.
- **Outputs:** `contracts/skills/r18_skill.contract.json`; `state/skills/r18_skill_registry.json`; failure packet schema.
- **Acceptance criteria:** Each skill has input/output contract, allowed roles, path policy, command policy, secrets/cost/token policy, evidence obligations, failure packet, validators, and approval rules.
- **Validation commands or expected validators:** `tools/validate_r18_skill_registry.ps1`; `tests/test_r18_skill_registry.ps1`.
- **Non-claims:** Skill contracts are not executed skills; API skills remain disabled until controls pass.
- **Dependencies:** R18-002.
- **Failure/retry behavior:** Any skill without role allowlist or failure packet schema is rejected.
- **Evidence refs expected:** contract, registry, check report, invalid fixtures, proof-review package.

### R18-004 — Define A2A handoff schema and validator

- **Purpose:** Make handoffs explicit, target-validated, and fail-closed.
- **Inputs:** R17 A2A contracts, R18 agent cards, R18 skill registry.
- **Outputs:** `contracts/a2a/r18_a2a_handoff.contract.json`; handoff validator; seed valid/invalid handoff packets.
- **Acceptance criteria:** Handoff includes card ID, source/target role, refs, authority, memory/evidence refs, current state, next allowed actions, retry count, failure path, and target validation result.
- **Validation commands or expected validators:** `tools/validate_r18_a2a_handoff.ps1`; `tests/test_r18_a2a_handoff.ps1`.
- **Non-claims:** Handoff schema is not live A2A runtime.
- **Dependencies:** R18-002, R18-003.
- **Failure/retry behavior:** Missing input refs, invalid target authority, or forbidden action triggers block/retry/operator-decision packet.
- **Evidence refs expected:** contract, seed handoffs, validation report, proof-review package.

### R18-005 — Extend board/card model for runtime work orders

- **Purpose:** Track runtime state, work orders, failures, retries, and approvals on cards.
- **Inputs:** R17 board contracts, R18 A2A schema, R18 authority.
- **Outputs:** `contracts/board/r18_card.contract.json`; `contracts/board/r18_board_event.contract.json`; board state generator/checker updates.
- **Acceptance criteria:** Cards record current work order, current role, handoff refs, failure events, retry count, blockers, evidence refs, and approval state.
- **Validation commands or expected validators:** `tools/validate_r18_board_model.ps1`; `tests/test_r18_board_model.ps1`.
- **Non-claims:** Model extension is not live board runtime.
- **Dependencies:** R18-001, R18-004.
- **Failure/retry behavior:** Invalid lane/state transitions or missing evidence refs fail closed.
- **Evidence refs expected:** contracts, generated board state, board event fixtures, check report.

### R18-006 — Define evidence ledger and runtime action record schema

- **Purpose:** Require every runner action, validator, handoff, failure, retry, and approval to produce evidence.
- **Inputs:** R17 tool-call ledger, R17 proof-review model, R18 board model.
- **Outputs:** `contracts/runtime/r18_evidence_ledger.contract.json`; `state/runtime/r18_evidence_ledger.jsonl` seed; validator.
- **Acceptance criteria:** Ledger entries include action ID, card ID, role, work order, command summary, result, evidence refs, failure refs, approval refs, and runtime flags.
- **Validation commands or expected validators:** `tools/validate_r18_evidence_ledger.ps1`; `tests/test_r18_evidence_ledger.ps1`.
- **Non-claims:** Seed ledger entries are not runtime execution proof.
- **Dependencies:** R18-005.
- **Failure/retry behavior:** Missing evidence refs or undocumented command result blocks downstream stage/commit/push.
- **Evidence refs expected:** contract, seed JSONL, check report, fixtures.

### R18-007 — Build Orchestrator chat/control surface MVP

- **Purpose:** Give the operator a direct Orchestrator interface for card/work-order/recovery decisions.
- **Inputs:** R18 board model, agent cards, skill registry, evidence ledger.
- **Outputs:** Minimal local chat/control UI or CLI panel; request/response packet schema; operator command log.
- **Acceptance criteria:** Operator can view active card, current work order, failure state, next safe action, approvals required, and evidence refs; operator can issue continue/stop/retry/approve/reject commands.
- **Validation commands or expected validators:** `tools/validate_r18_orchestrator_control_surface.ps1`; `tests/test_r18_orchestrator_control_surface.ps1`.
- **Non-claims:** MVP surface is not autonomous runtime by itself; it must not claim API execution.
- **Dependencies:** R18-002 through R18-006.
- **Failure/retry behavior:** Invalid operator command creates rejection packet and leaves state unchanged.
- **Evidence refs expected:** surface files, interaction contract, seed transcripts, UI/CLI snapshot, validation report.

### R18-008 — Build local runner/CLI shell

- **Purpose:** Create the executable shell that runs one bounded work order at a time.
- **Inputs:** R18 skill registry, board model, evidence ledger, Orchestrator control surface.
- **Outputs:** `tools/r18_runner.ps1` or equivalent CLI; runner state file; command dispatcher; dry-run mode.
- **Acceptance criteria:** Runner validates work order schema, captures pre/post git state, runs allowed commands, writes evidence, and stops on failure.
- **Validation commands or expected validators:** `tools/validate_r18_runner_shell.ps1`; `tests/test_r18_runner_shell.ps1`; `git diff --check`.
- **Non-claims:** Runner shell alone is not proof of recovered compaction until failure drills pass.
- **Dependencies:** R18-003, R18-006, R18-007.
- **Failure/retry behavior:** Missing authority, unsafe paths, command failure, or validator failure produces failure event and stops.
- **Evidence refs expected:** runner script/module, state file, dry-run execution records, check report.

### R18-009 — Implement work-order execution state machine

- **Purpose:** Track each small work order from planned to completed/failed/blocked/recovered.
- **Inputs:** R17 compact-safe harness model, R18 runner shell, board/card model.
- **Outputs:** `contracts/runtime/r18_work_order.contract.json`; `state/runtime/r18_work_order_state_machine.json`; validator.
- **Acceptance criteria:** State machine includes planned, validated, executing, failed, preserving_state, classified, continuation_generated, retry_pending, blocked, completed, staged, committed, pushed.
- **Validation commands or expected validators:** `tools/validate_r18_work_order_state_machine.ps1`; `tests/test_r18_work_order_state_machine.ps1`.
- **Non-claims:** State machine is not complete runtime until runner uses it in a drill.
- **Dependencies:** R18-008.
- **Failure/retry behavior:** Illegal transitions fail closed and generate failure packet.
- **Evidence refs expected:** contract, state machine, seed work orders, invalid transition fixtures, proof review.

### R18-010 — Implement small work-order generator

- **Purpose:** Prevent giant prompts by generating bounded, resumable work orders.
- **Inputs:** R18 card, authority refs, allowed paths, target task, validators.
- **Outputs:** Work-order generator; prompt/work-order packets with max size, allowed paths, expected outputs, validators, stop conditions.
- **Acceptance criteria:** Work orders are scoped to one safe step; no whole-milestone prompts; each has last/next step fields and evidence obligations.
- **Validation commands or expected validators:** `tools/validate_r18_work_order_generator.ps1`; `tests/test_r18_work_order_generator.ps1`.
- **Non-claims:** Generated work orders are not executed work.
- **Dependencies:** R18-009.
- **Failure/retry behavior:** Overlarge prompt, broad repo write, missing validator, or missing stop condition is rejected.
- **Evidence refs expected:** generator, generated examples, check report, invalid fixtures.

### R18-011 — Implement compact/stream/validation failure detector

- **Purpose:** Detect recurring failure modes automatically or semi-automatically through runner signals and explicit operator failure input.
- **Inputs:** Runner execution records, command status, validation output, optional operator failure note.
- **Outputs:** `contracts/runtime/r18_failure_event.contract.json`; failure detector; JSONL failure events.
- **Acceptance criteria:** Detector classifies compact failure, stream disconnect, validation failure, status-doc gate failure, remote movement, unsafe WIP, generated churn, API/token budget failure.
- **Validation commands or expected validators:** `tools/validate_r18_failure_detector.ps1`; `tests/test_r18_failure_detector.ps1`.
- **Non-claims:** Detection is not recovery completion.
- **Dependencies:** R18-008, R18-009.
- **Failure/retry behavior:** Unknown failure type becomes `operator_decision_required` and stops.
- **Evidence refs expected:** contract, detector logs, failure-event fixtures, check report.

### R18-012 — Implement WIP classifier

- **Purpose:** Preserve and classify local state before continuation or cleanup.
- **Inputs:** `git status --short --branch`, `git diff --name-status`, `git diff --numstat`, allowed/forbidden paths, work-order refs.
- **Outputs:** WIP classification packet; safe/unsafe path lists; preservation actions.
- **Acceptance criteria:** Classifier distinguishes no WIP, scoped tracked WIP, unexpected tracked WIP, unsafe historical diff, untracked notes, generated churn, and operator-decision-required WIP.
- **Validation commands or expected validators:** `tools/validate_r18_wip_classifier.ps1`; `tests/test_r18_wip_classifier.ps1`.
- **Non-claims:** WIP classification does not imply WIP is safe to commit.
- **Dependencies:** R18-011.
- **Failure/retry behavior:** Unsafe or unclassified WIP blocks continuation and requests operator decision.
- **Evidence refs expected:** classifier module, classification packets, fixtures, evidence ledger entries.

### R18-013 — Implement remote branch verifier

- **Purpose:** Verify remote branch state before continuation, recovery, stage, commit, or push.
- **Inputs:** branch name, expected local head/tree, expected remote ref, work-order packet.
- **Outputs:** Remote verification packet with observed local/remote refs and verdict.
- **Acceptance criteria:** Verifier fails closed on missing remote, moved remote branch, unexpected divergence, missing expected head/tree, or stale branch.
- **Validation commands or expected validators:** `tools/validate_r18_remote_branch_verifier.ps1`; `tests/test_r18_remote_branch_verifier.ps1`.
- **Non-claims:** Verification is not push, merge, or final-head support.
- **Dependencies:** R18-008, R18-012.
- **Failure/retry behavior:** Remote movement escalates to operator decision; no automatic force push.
- **Evidence refs expected:** verifier output, failure fixtures, board event, evidence ledger entry.

### R18-014 — Implement continuation packet generator

- **Purpose:** Generate machine-readable continuation packets automatically from runner state.
- **Inputs:** failure event, WIP classification, remote verification packet, work-order state, evidence ledger.
- **Outputs:** `state/runtime/r18_continuation_packets.json`; per-failure continuation packet; validator.
- **Acceptance criteria:** Packet includes failure type, baseline head/tree, WIP classification, last completed step, next safe step, retry count, validation commands, evidence refs, approval state, and stop conditions.
- **Validation commands or expected validators:** `tools/validate_r18_continuation_packet_generator.ps1`; `tests/test_r18_continuation_packet_generator.ps1`.
- **Non-claims:** Continuation packet is not live recovery unless consumed by runner in a drill.
- **Dependencies:** R18-011, R18-012, R18-013.
- **Failure/retry behavior:** Missing failure/WIP/remote evidence blocks packet generation and escalates.
- **Evidence refs expected:** generated continuation packets, check report, invalid fixtures.

### R18-015 — Implement new-context/new-thread prompt generator

- **Purpose:** Generate concise, exact-ref-based continuation prompts without previous-thread dependency.
- **Inputs:** continuation packet, authority refs, current card/work-order, evidence refs, retry policy.
- **Outputs:** `state/runtime/r18_new_context_packets.json`; prompt packet files; prompt validator.
- **Acceptance criteria:** Prompt contains current accepted refs, last completed step, next safe step, allowed paths, forbidden paths, validators, non-claims, and stop conditions; prompt avoids full milestone history and giant context dumps.
- **Validation commands or expected validators:** `tools/validate_r18_new_context_prompt_generator.ps1`; `tests/test_r18_new_context_prompt_generator.ps1`.
- **Non-claims:** Prompt generation is not automatic Codex thread creation unless an approved API/tool adapter actually creates one and records evidence.
- **Dependencies:** R18-014.
- **Failure/retry behavior:** Overlarge prompt, missing refs, or previous-thread dependency fails closed.
- **Evidence refs expected:** new-context packets, prompt files, validation report, fixtures.

### R18-016 — Implement retry and escalation policy runtime

- **Purpose:** Enforce retry limits and escalation through runner state.
- **Inputs:** failure events, continuation packets, work-order state, operator approval policy.
- **Outputs:** Retry/escalation contract; retry counter; escalation packets.
- **Acceptance criteria:** Retry limit is enforced; retry count persists; escalation triggers on retry limit, unsafe WIP, remote movement, validation gate failure, API/token budget failure, or operator abort.
- **Validation commands or expected validators:** `tools/validate_r18_retry_escalation_runtime.ps1`; `tests/test_r18_retry_escalation_runtime.ps1`.
- **Non-claims:** Retry policy does not solve Codex reliability.
- **Dependencies:** R18-014, R18-015.
- **Failure/retry behavior:** Retry loops cannot run unbounded; escalation asks operator for a decision and stops.
- **Evidence refs expected:** retry state, escalation packets, board events, evidence ledger entries.

### R18-017 — Implement stage/commit/push gate

- **Purpose:** Prevent unsafe commits/pushes and require validation evidence before release actions.
- **Inputs:** work-order state, WIP classification, remote verification, validators, status-doc gate, evidence ledger, operator approval if required.
- **Outputs:** Stage/commit/push gate contract, gate report, command wrapper.
- **Acceptance criteria:** Gate requires passing validators, status-doc gate, evidence package gate, diff check, allowed-path check, overclaim check, and approvals; push is blocked on any failure.
- **Validation commands or expected validators:** `tools/validate_r18_stage_commit_push_gate.ps1`; `tests/test_r18_stage_commit_push_gate.ps1`; `git diff --check`.
- **Non-claims:** Gate definition is not a push. No main merge.
- **Dependencies:** R18-013, R18-016.
- **Failure/retry behavior:** Failed gate creates failure packet and returns to recovery path or operator decision.
- **Evidence refs expected:** gate report, command logs, approval packet, evidence ledger entry.

### R18-018 — Automate status-doc gate for R18

- **Purpose:** Ensure README, active state, KANBAN, authority docs, decision log, and non-claims stay synchronized.
- **Inputs:** current milestone status, task completions, runtime flags, non-claims.
- **Outputs:** Updated `StatusDocGate` support, R18-specific status gate validator/test.
- **Acceptance criteria:** Gate rejects R18 overclaims, R17 closure without approval, R18 closeout without proof, API invocation without controls, and main merge claims.
- **Validation commands or expected validators:** `tools/validate_status_doc_gate.ps1`; `tests/test_status_doc_gate.ps1`; `tools/validate_r18_status_doc_gate.ps1`.
- **Non-claims:** Status docs are not runtime proof.
- **Dependencies:** R18-001, R18-017.
- **Failure/retry behavior:** Status mismatch blocks commit/push and generates repair work order.
- **Evidence refs expected:** updated gate module, test results, status-doc check report.

### R18-019 — Automate evidence package generation

- **Purpose:** Generate proof-review/evidence packages from runtime evidence, not prose alone.
- **Inputs:** evidence ledger, board events, work-order records, failure packets, continuation packets, validator outputs.
- **Outputs:** Evidence package generator; evidence index; validation manifest; proof review; final-head support packet template.
- **Acceptance criteria:** Package includes machine-readable evidence refs, runtime flags, rejected claims, residual risks, validation commands, and exact artifact refs.
- **Validation commands or expected validators:** `tools/validate_r18_evidence_package.ps1`; `tests/test_r18_evidence_package.ps1`.
- **Non-claims:** Generated evidence package is not external audit acceptance.
- **Dependencies:** R18-006, R18-018.
- **Failure/retry behavior:** Missing evidence refs or report-only proof blocks package acceptance.
- **Evidence refs expected:** evidence index, proof review, validation manifest, final-head support packet candidate.

### R18-020 — Implement operator approval gate

- **Purpose:** Keep the operator out of routine recovery while preserving explicit approval for risky decisions.
- **Inputs:** approval policy, work-order state, escalation packet, Orchestrator control surface.
- **Outputs:** Approval request packet, approval/denial record, UI/CLI approval command.
- **Acceptance criteria:** Approval required for WIP abandonment, API enablement, stage/commit/push when risky, closeout, main merge, external audit claim, remote conflict handling.
- **Validation commands or expected validators:** `tools/validate_r18_operator_approval_gate.ps1`; `tests/test_r18_operator_approval_gate.ps1`.
- **Non-claims:** Approval gate does not automate operator decisions.
- **Dependencies:** R18-007, R18-016, R18-017.
- **Failure/retry behavior:** Missing approval blocks the action and records pending decision.
- **Evidence refs expected:** approval packets, denial packets, board events, evidence ledger entries.

### R18-021 — Implement API, secrets, cost, and token controls

- **Purpose:** Create controls required before any OpenAI/Codex API adapter is enabled.
- **Inputs:** skill registry, approval gate, runner shell, operator policy.
- **Outputs:** API control contract; secrets policy; cost/token budget policy; disabled adapter profile; budget failure packet schema.
- **Acceptance criteria:** API disabled by default; secrets never committed; per-request/per-task budgets exist; retries/timeouts capped; logs redact secrets; operator approval required for enablement.
- **Validation commands or expected validators:** `tools/validate_r18_api_secrets_cost_controls.ps1`; `tests/test_r18_api_secrets_cost_controls.ps1`.
- **Non-claims:** Controls are not API invocation.
- **Dependencies:** R18-003, R18-020.
- **Failure/retry behavior:** Missing secret policy, missing budget, or unsafe logging blocks adapter enablement.
- **Evidence refs expected:** control contract, disabled profile, fixtures, check report.

### R18-022 — Optional OpenAI/Codex API adapter after controls only

- **Purpose:** Add optional controlled API adapter only after R18-021 passes.
- **Inputs:** approved API controls, operator enablement packet, skill registry, evidence ledger.
- **Outputs:** Adapter contract/profile; dry-run adapter; optional live adapter path if approved; API call evidence packet schema.
- **Acceptance criteria:** Dry-run works without secrets; live mode requires operator approval and budget; each call records model/tool, purpose, cost estimate, token estimate, request/response refs, redaction status, and failure packet if failed.
- **Validation commands or expected validators:** `tools/validate_r18_optional_api_adapter.ps1`; `tests/test_r18_optional_api_adapter.ps1`.
- **Non-claims:** No API invocation unless a live approved run records evidence. No autonomous Codex invocation by default.
- **Dependencies:** R18-021.
- **Failure/retry behavior:** Budget exceeded, missing approval, missing secrets, or failed call produces failure packet and stops.
- **Evidence refs expected:** adapter profile, dry-run evidence, optional live evidence if approved, failure fixtures.

### R18-023 — Implement governed Developer/Codex execution adapter runtime through runner

- **Purpose:** Move Developer/Codex work from packet-only to governed runner-mediated execution.
- **Inputs:** Developer agent card, skills, work order, Codex adapter profile, runner state.
- **Outputs:** Developer execution packet, result packet, command log summary, evidence ledger entry, board event.
- **Acceptance criteria:** Execution is bounded by allowed paths and one work order; result includes changed files, validators, failures, and next handoff; no autonomous push.
- **Validation commands or expected validators:** `tools/validate_r18_developer_codex_runtime.ps1`; `tests/test_r18_developer_codex_runtime.ps1`.
- **Non-claims:** Does not claim solved Codex reliability or no-manual-transfer until recovery drills prove it.
- **Dependencies:** R18-008 through R18-017; R18-022 only if API-backed execution is used.
- **Failure/retry behavior:** Compact/stream/validation failure routes to R18 recovery loop.
- **Evidence refs expected:** execution packet, result packet, failure/continuation packets when applicable, board event, evidence ledger.

### R18-024 — Implement QA/Test Agent runtime and defect loop

- **Purpose:** Run validators/tests as a governed QA role and create defect/repair handoffs.
- **Inputs:** QA agent card, validation skill, Developer result packet, board card, evidence ledger.
- **Outputs:** QA request/result packet, defect packet, repair handoff to Developer if needed.
- **Acceptance criteria:** QA validates inputs, runs configured validators, records pass/fail, creates defect packet on failure, and blocks release on failed QA.
- **Validation commands or expected validators:** `tools/validate_r18_qa_test_runtime.ps1`; `tests/test_r18_qa_test_runtime.ps1`.
- **Non-claims:** QA runtime is not release approval or external audit.
- **Dependencies:** R18-023.
- **Failure/retry behavior:** Failed validator creates defect loop; repeated failure follows retry/escalation policy.
- **Evidence refs expected:** QA packets, defect packet, repair handoff, validation logs, board events.

### R18-025 — Implement Evidence Auditor adapter/runtime path

- **Purpose:** Perform evidence review through a governed Evidence Auditor role before closeout/audit claims.
- **Inputs:** Evidence auditor card, evidence package, QA result, runtime ledger, non-claim list.
- **Outputs:** Audit request packet, audit verdict packet, overclaim findings, required repairs.
- **Acceptance criteria:** Auditor rejects missing evidence, report-only proof, runtime overclaims, missing validators, unapproved closeout, or API/main-merge claims without evidence.
- **Validation commands or expected validators:** `tools/validate_r18_evidence_auditor_runtime.ps1`; `tests/test_r18_evidence_auditor_runtime.ps1`.
- **Non-claims:** Internal Evidence Auditor runtime is not external audit acceptance.
- **Dependencies:** R18-019, R18-024.
- **Failure/retry behavior:** Audit failure creates repair handoff or blocks closeout.
- **Evidence refs expected:** audit packets, finding packets, board events, evidence ledger entries.

### R18-026 — Retry Cycle 3 QA/fix-loop using the harness

- **Purpose:** Convert R17 Cycle 3 prompt-packet pilot into actual small-work-order execution evidence.
- **Inputs:** R17 Cycle 3 pilot work orders, R18 runner, Developer/QA agents, recovery loop.
- **Outputs:** Executed Cycle 3 work-order records, QA result, defect/repair loop evidence, recovery evidence if failure occurs.
- **Acceptance criteria:** Cycle 3 runs through Developer/QA handoff with validators; compact/validation failure is handled by recovery loop; evidence exceeds packet-only artifacts.
- **Validation commands or expected validators:** `tools/validate_r18_cycle_3_qa_fix_loop.ps1`; `tests/test_r18_cycle_3_qa_fix_loop.ps1`; status-doc gate.
- **Non-claims:** Does not claim four cycles; does not claim solved compaction.
- **Dependencies:** R18-023, R18-024, R18-016.
- **Failure/retry behavior:** Failure must generate failure event, WIP classification, continuation packet, new-context prompt if needed, and retry/escalation state.
- **Evidence refs expected:** Cycle 3 execution package, handoff packets, QA/defect packets, recovery packets, evidence ledger, board events.

### R18-027 — Retry Cycle 4 audit/closeout using the harness

- **Purpose:** Exercise audit/closeout loop under governance, without implying external audit acceptance.
- **Inputs:** Cycle 3 result, evidence package generator, Evidence Auditor runtime, release manager gate.
- **Outputs:** Cycle 4 audit/closeout package, auditor verdict, release gate result, closeout-candidate packet.
- **Acceptance criteria:** Evidence Auditor reviews machine-readable evidence; release manager gate enforces validators/status/evidence/approval; closeout remains candidate until operator approval.
- **Validation commands or expected validators:** `tools/validate_r18_cycle_4_audit_closeout.ps1`; `tests/test_r18_cycle_4_audit_closeout.ps1`; `tools/validate_status_doc_gate.ps1`.
- **Non-claims:** No external audit acceptance, no main merge, no closeout without operator approval.
- **Dependencies:** R18-025, R18-026.
- **Failure/retry behavior:** Missing evidence or overclaim blocks closeout and creates repair handoff.
- **Evidence refs expected:** Cycle 4 package, audit verdict packet, release gate report, approval packet if requested.

### R18-028 — Produce R18 final proof package and closeout-candidate decision packet

- **Purpose:** Package R18 evidence and produce a decision point for the operator.
- **Inputs:** R18 evidence ledger, Cycle 3/4 packages, recovery drills, validators, status gates, final-head verification.
- **Outputs:** R18 final report, KPI movement scorecard, evidence index, proof review, validation manifest, final-head support packet, operator decision packet.
- **Acceptance criteria:** Package proves or rejects R18 success definition honestly; runtime claims only if backed by execution evidence; manual burden reduction is measured; non-claims preserved; operator decision required.
- **Validation commands or expected validators:** `tools/validate_r18_final_evidence_package.ps1`; `tests/test_r18_final_evidence_package.ps1`; `tools/validate_status_doc_gate.ps1`; `tests/test_status_doc_gate.ps1`; `git diff --check`.
- **Non-claims:** Final package is not operator approval, not external audit acceptance, not main merge.
- **Dependencies:** R18-001 through R18-027.
- **Failure/retry behavior:** If evidence is insufficient, mark R18 partial/active and create repair plan; do not close by narration.
- **Evidence refs expected:** final evidence package, proof review, validation manifest, final-head support packet, KPI scorecard, operator decision packet.

---

## Final planning stance

R18 should be judged by runtime evidence, not by more polished reports. The minimum acceptable movement is a runner-backed recovery loop that reduces repetitive operator copy/paste during failure recovery. If R18 only creates more prompt packets, schemas, and static snapshots, it will repeat R17's main product-value failure.
