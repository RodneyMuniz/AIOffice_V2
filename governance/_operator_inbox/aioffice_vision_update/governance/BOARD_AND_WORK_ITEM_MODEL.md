# AIOffice Board and Work Item Model

**Document status:** Proposed v1
**Document type:** Board/card schema and process-state model
**Scope:** Target model only; not implementation proof.

---

## 1. Purpose

This document defines the target AIO-owned board/card model.

Core rule:

> **Repo truth remains canonical. The board is the live process surface. Board cards are governed work packets, not sticky notes.**

External boards such as GitHub Projects or Linear may mirror AIO cards, but they must not silently become canonical truth.

---

## 2. Board Principles

1. All significant user questions become board-visible after Operator intake.
2. PM owns card state and routing.
3. Cards carry evidence refs and authority constraints.
4. Status changes are governed events.
5. Resolved is not Closed.
6. Closed requires User approval.
7. External mirrors are adapters.
8. Daemon/runner activity must be visible on cards.
9. Stop/retry/re-entry must be visible on cards.
10. Cards should reduce context scans by pointing agents to scoped knowledge refs.

---

## 3. Primary Statuses

| Status | Meaning | State owner |
| --- | --- | --- |
| Intake | Raw user intent or incoming question exists. | Operator/PM |
| Refinement | PM is shaping the card, criteria, scope, or routing. | PM |
| Ready | Task packet exists and can be routed. | PM |
| In Progress | Authorized role/runner is executing. | PM applies; Developer/runner does not own state. |
| QA | QA is executing criteria. | PM applies; QA reports. |
| Audit | Auditor is reviewing evidence sufficiency. | PM applies; Auditor reports. |
| Resolved | Evidence is sufficient for User review. | PM applies after QA/Auditor gates. |
| Closed | User accepted the outcome. | User approval required. |
| Blocked | Required authority/evidence/tooling/context is missing. | PM/Auditor/Release may trigger; PM records. |
| Parked | Work intentionally deferred for product direction or priority. | PM/User |

---

## 4. Sub-Statuses

Sub-statuses are metadata, not necessarily board columns.

Examples:

- raw_user_input
- operator_clarifying
- ready_for_pm
- repo_question_detected
- architecture_question_detected
- pm_triage
- requirements_drafting
- acceptance_criteria_drafting
- qa_input_required
- auditor_input_required
- architect_input_required
- user_decision_required
- split_required
- ready_for_build
- agent_bootstrapping
- executing
- evidence_generating
- stopped_by_user
- stalled
- retry_scheduled
- needs_recovery
- qa_bootstrapping
- testing
- qa_failed
- qa_passed
- qa_inconclusive
- auditor_bootstrapping
- repo_truth_check
- evidence_review
- architecture_alignment_check
- acceptance_satisfied
- more_work_required
- follow_up_task_required
- ready_for_user_review
- user_rejected
- user_approved
- blocked_user_decision
- blocked_architecture
- blocked_tooling
- blocked_auth
- blocked_context
- blocked_cost_budget
- parked_needs_product_direction

---

## 5. Card Types

| Card type | Purpose |
| --- | --- |
| Idea | Raw product or project idea. |
| Clarification | Question needed before shaping work. |
| Architecture Question | Technical/design decision requiring Architect/User. |
| Repo Question | Repo truth question requiring investigation. |
| Milestone | Container for related cards/tasks. |
| Build Task | Implementation work. |
| QA Task | Testing/validation work. |
| Audit Task | Evidence review. |
| Bug | Defect or failure. |
| Enhancement | Improvement request. |
| Knowledge Update | Documentation, memory, or artifact-map update. |
| Cleanup Candidate | Possible stale/deprecated artifact or refactor/cleanup. |
| Release/Report Task | Release, closeout, report, or final-head support. |
| Operator Decision | Explicit User/Operator decision requirement. |

---

## 6. Minimum Card Schema

```json
{
  "card_id": "...",
  "card_type": "Build Task",
  "title": "...",
  "status": "Refinement",
  "sub_status": "acceptance_criteria_drafting",
  "pipeline_type": "admin|standard|unknown",
  "owner_role": "pm|architect|developer|qa|auditor|knowledge_curator|release_closeout",
  "created_from": "intake_ref",
  "task_packet_ref": null,
  "acceptance_criteria_refs": [],
  "qa_criteria_refs": [],
  "evidence_refs": [],
  "knowledge_refs": [],
  "blocked_by": [],
  "user_decision_required": false,
  "resolved_ref": null,
  "closed_approval_ref": null,
  "non_claims": []
}
```

---

## 7. External Mirror Strategy

Recommended sequence:

1. Define AIO-owned board/card schema.
2. Generate repo-backed card artifacts.
3. Mirror to GitHub Issues/Projects first because it is closest to repo, commits, PRs, and GitHub Actions.
4. Keep Linear as an adapter/lab path for Symphony compatibility.
5. Build custom AIO board/control room only after schema, authority, memory, and re-entry mechanics are proven.

External board state should include an AIO card ID and repo evidence refs. If external state conflicts with repo truth, repo truth wins.

---

## 8. State Transition Rules

| Transition | Required condition |
| --- | --- |
| Intake -> Refinement | PM accepts intake. |
| Refinement -> Ready | Task packet and criteria exist. |
| Ready -> In Progress | PM authorizes correct role/runner. |
| In Progress -> QA | Developer evidence bundle exists. |
| QA -> Audit | QA report exists. |
| Audit -> Resolved | Auditor sufficiency accepted and PM marks ready for User. |
| Resolved -> Closed | User approval event exists. |
| Any active -> Blocked | Missing authority/evidence/tooling/context/cost. |
| Any active -> Parked | User/PM decision to defer. |
| Rejection -> Refinement | User rejection recorded and PM re-triages. |

---

## 9. Non-Claims

This model does not claim:

- board engine exists;
- GitHub Projects sync exists;
- Linear sync exists;
- custom AIO board UI exists;
- state transition enforcement exists in runtime;
- a successor milestone is planned.
