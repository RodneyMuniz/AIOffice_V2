# AIOffice Agent Identity and Memory Model

**Document status:** Proposed v1
**Document type:** Agent identity, memory, and handoff enforcement model
**Scope:** Target governance model only; not proof of implemented multi-agent execution.

---

## 1. Purpose

This document defines how AIOffice prevents fake multi-agent behavior, role collapse, and context-burn failures.

Core rule:

> **An agent is not a name in a paragraph. An agent is a bounded execution with identity, memory refs, authority, tools, required output, and audit trail.**

Different agents do not necessarily require different LLM providers. They do require separate bounded executions and explicit artifacts.

---

## 2. True Agent Execution Requirements

A true agent run must include:

- Agent Identity Packet;
- card/task packet reference;
- loaded memory refs;
- tool permission profile;
- output artifact;
- handoff packet when work moves to another role;
- audit log entry.

A single assistant response may simulate a multi-role discussion only if it is explicitly labeled `simulation`. Simulations must not be accepted as execution proof.

---

## 3. Agent Identity Packet

Minimum fields:

```json
{
  "agent_run_id": "...",
  "agent_profile_id": "...",
  "agent_role": "pm|architect|developer|qa|auditor|knowledge_curator|release_closeout|operator|orchestrator",
  "card_id": "...",
  "task_packet_ref": "...",
  "loaded_memory_refs": [],
  "allowed_actions": [],
  "forbidden_actions": [],
  "allowed_tools": [],
  "forbidden_tools": [],
  "can_change_board_state": false,
  "can_modify_repo": false,
  "can_close_task": false,
  "output_required": "...",
  "handoff_target": "...",
  "created_at_utc": "..."
}
```

---

## 4. Memory Scopes

| Memory scope | Purpose | Allowed examples | Forbidden examples |
| --- | --- | --- | --- |
| Product memory | Stable vision and doctrine. | `governance/VISION.md`, product model docs. | Raw chat as authority. |
| Board/card memory | Current process state. | card, status, task packet, blockers. | Unrelated old cards by default. |
| Role memory | Role-specific rules. | RACI, agent authority model, role templates. | Other role private assumptions. |
| Task memory | Exact work context. | packet, relevant files, evidence refs. | Full repo scan without authorization. |
| Attempt memory | Current run history. | execution bundle, QA report, audit decision. | Obsolete attempts not linked to re-entry. |
| Knowledge map memory | Scoped artifact references. | capability map, artifact registry. | Unclassified repo inventory dumps. |

---

## 5. Tool Permission Profiles

| Role | Default repo write | Default board state mutation | Default test execution | Default audit authority |
| --- | --- | --- | --- | --- |
| Operator | No | Intake only | No | No |
| Orchestrator | No | Routing only | No | No |
| PM | No implementation writes | Yes | No | No |
| Architect | No by default | No | No by default | Advisory only |
| Developer | Scoped yes | No | Scoped validation only | No |
| QA | No implementation writes | No | Yes | No |
| Auditor | No implementation writes | No | Validation/read only | Yes |
| Knowledge Curator | Docs/proposals only | No | No | No |
| Release/Closeout | Packaging/release artifacts only | No final closure | Release readiness checks | Closeout readiness support |

Any expansion of tool access must be explicit in the agent identity packet.

---

## 6. Hard Enforcement Rules

1. Developer cannot change card state.
2. QA cannot implement.
3. PM cannot implement or test.
4. Auditor cannot implement.
5. Operator cannot answer repo/architecture questions without routing.
6. Architect cannot decide alone.
7. Closed transition requires User approval event.
8. Release/Closeout Agent cannot override failed gates.
9. Knowledge Curator cannot deprecate/delete without User approval.
10. One assistant narrating multiple roles is not accepted as execution proof.

---

## 7. Direct Agent Access

The User must be able to invoke specific agents directly:

- PM
- Architect
- QA/Test Agent
- Evidence Auditor
- Knowledge Curator
- Release/Closeout Agent
- Orchestrator

Direct access requirements:

- show active agent identity;
- show loaded memory refs;
- show authority limits;
- show allowed tools;
- show required output artifact;
- prevent state mutation if the role lacks authority;
- log the direct invocation as a card/event when material.

Direct access cannot bypass state mutation rules. For example, the User may directly ask Auditor for evidence sufficiency, but Auditor still cannot close the task.

---

## 8. Handoff Packet

Every role handoff should produce a handoff packet when the next role needs durable context.

Minimum fields:

- handoff_id;
- from_agent_run_id;
- to_role;
- card_id;
- source_output_ref;
- summary;
- unresolved risks;
- required next action;
- evidence refs;
- forbidden assumptions;
- non-claims.

---

## 9. Audit Log Entry

Every material agent run should emit an audit log entry:

- agent_run_id;
- role;
- card_id;
- start/end time;
- loaded memory refs;
- tools used;
- output refs;
- state change requested;
- state change applied by whom;
- rejected claims;
- non-claims.

---

## 10. Compaction and Restart Behavior

Agent memory must survive compaction by reloading from artifacts, not prior chat.

Required restart inputs:

- card ID;
- task packet ref;
- latest role output;
- latest QA report;
- latest Auditor decision;
- latest state transition;
- relevant knowledge refs;
- forbidden actions;
- next legal action.

Restart prompts are useful but not a solution by themselves. The target solution is artifact-backed re-entry.

---

## 11. Non-Claims

This document does not claim:

- true multi-agent execution is currently implemented;
- direct agent access exists;
- model compaction is solved;
- role boundaries are enforced by runtime code;
- Symphony or Agent Builder is integrated.
