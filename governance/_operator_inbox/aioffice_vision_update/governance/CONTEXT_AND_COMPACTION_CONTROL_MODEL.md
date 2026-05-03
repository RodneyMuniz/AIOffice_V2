# AIOffice Context and Compaction Control Model

**Document status:** Proposed v1
**Document type:** Context, memory, stop/recovery, and re-entry model
**Scope:** Target model only; not proof that compaction is solved.

---

## 1. Purpose

R13 showed that Codex/chat continuity and context burn remain serious operational problems. Continuity packets and restart prompts are useful mitigations, not solutions.

This document defines the target correction strategy: move operational memory into compact, role-scoped, artifact-backed packets.

---

## 2. R13 Lesson

R13 evidence supports this conclusion:

> **AIOffice cannot rely on long conversational continuity as its execution substrate. It must use compact authoritative task state, card state, role memory, and re-entry packets.**

R13 compaction mitigation was bounded repo-truth continuity mitigation. It did not solve Codex compaction generally.

---

## 3. Context-Control Principles

1. Task state lives in artifacts, not chat.
2. Every agent gets scoped memory refs.
3. Full-repo scans are exceptional and bounded.
4. Re-entry must start from packetized state.
5. Stop/recovery must preserve partial evidence.
6. The board must show stalled, stopped, retry, and recovery states.
7. Knowledge maps reduce repeated exploration.
8. Agents must not load obsolete/historical artifacts unless authorized.

---

## 4. Compact Authoritative Task State

Every active card should have compact task state containing:

- card ID;
- current status and sub-status;
- task packet ref;
- assigned role;
- latest attempt ref;
- latest QA ref;
- latest Auditor ref;
- latest user decision ref;
- known blockers;
- next legal action;
- loaded knowledge refs;
- non-claims.

This should be the first thing loaded on re-entry.

---

## 5. Task Packet Fields

Required task packet fields:

- task objective;
- role owner;
- scope boundary;
- relevant knowledge refs;
- target artifacts/files/capability;
- acceptance criteria;
- QA criteria;
- evidence required;
- forbidden actions;
- max exploration boundary;
- rollback/recovery expectation;
- handoff target;
- stop/escalation rules;
- non-claims.

---

## 6. Re-Entry Packet Fields

Required re-entry packet fields:

- card_id;
- previous_attempt_id;
- original_task_packet_ref;
- latest_rejection_ref;
- affected_files;
- failed_acceptance_criteria;
- QA evidence ref;
- Auditor feedback ref;
- relevant knowledge refs;
- what changed since last attempt;
- allowed actions;
- forbidden actions;
- required output.

---

## 7. Role Memory

| Role | Required memory refs | Avoid by default |
| --- | --- | --- |
| PM | card state, acceptance criteria, board model, dependencies | implementation internals unless needed |
| Architect | architecture docs, capability map, constraints | old unrelated reports |
| Developer | task packet, allowed files, relevant capability refs | broad repo scan |
| QA | QA criteria, test refs, execution bundle | implementation changes beyond evidence |
| Auditor | evidence taxonomy, refs, QA report, rejected claims | unvalidated narrative |
| Knowledge Curator | artifact registry, maps, classification rules | execution details not relevant to classification |
| Release/Closeout | release strategy, branch refs, QA/audit decisions | product speculation |

---

## 8. Max Exploration Boundary

Every task packet should state how far an agent may explore.

Examples:

- `target_files_only`
- `target_capability_folder`
- `contracts_and_tools_for_capability`
- `repo_wide_read_only_inventory_allowed`
- `no_external_calls`
- `external_replay_allowed`

If the boundary is exceeded, the agent must stop and request PM/Auditor guidance.

---

## 9. Stop and Recovery Packet

Any stopped/stalled/retried run should produce a stop/recovery packet:

- stop_event_id;
- card_id;
- agent_run_id;
- stop_reason;
- last_completed_step;
- partial_outputs;
- evidence_refs;
- dirty_state or clean_state;
- recommended re-entry role;
- next legal action;
- forbidden assumptions.

---

## 10. Queue Behavior

Initial target:

- one active card at a time globally or one active build card at a time;
- later one active card per agent role;
- no daemon dispatch without stop button and state reconciliation;
- retry requires packetized cause and authority;
- stalled tasks become board-visible.

---

## 11. Context-Burn KPIs

- average loaded memory refs per agent run;
- number of broad repo scans;
- number of compaction/restart events;
- re-entry success rate;
- stale artifact refs loaded;
- stop/recovery packet coverage;
- manual copy/paste steps per cycle.

---

## 12. Non-Claims

This model does not claim:

- Codex compaction is solved;
- Codex can run long milestones unattended;
- re-entry packets are implemented;
- stop button is implemented;
- context burn is eliminated.
