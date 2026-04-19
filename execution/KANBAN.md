# AIOffice Kanban

This board tracks the current reset implementation milestone only.

## Active Milestone
`R3 Governed Work Objects and Double-Audit Foundations`

Objective:
Turn the current control substrate into governed work objects, structured request-to-task flow, double-audit-ready QA artifacts, and minimal baton foundations without broad UI expansion, Standard pipeline productization, or rollback or product recovery overreach.

Exit Criteria:
- repo truth explicitly closes the first bounded V1 proof and opens `R3 Governed Work Objects and Double-Audit Foundations`
- canonical Project / Milestone / Task / Bug contracts and invariants exist
- planning-record storage and validation exist
- Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton contracts exist
- a bounded Request Brief -> Task Packet planning flow exists
- a QA gate exists with remediation tracking and external-audit packaging
- minimal task baton or resume persistence exists
- a replayable end-to-end R3 planning proof exists without broad UI expansion

## Tasks

### `R3-001` Close out R2 proof and open R3 in repo truth
- Status: done
- Order: 1
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `governance/R2_FIRST_BOUNDED_V1_PROOF_REVIEW_RERUN.md`, `state/proof_reviews/r2_first_bounded_v1_rerun/REPLAY_SUMMARY.md`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: updated repo-truth surfaces plus explicit closeout and milestone-brief documents
- Done when: `README.md`, `governance/ACTIVE_STATE.md`, and `execution/KANBAN.md` explicitly close out the narrow first bounded V1 proof, `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md` exists, `governance/R3_GOVERNED_WORK_OBJECTS_AND_DOUBLE_AUDIT_FOUNDATIONS.md` exists, and the active milestone is advanced to R3 without broadening the claim

### `R3-002` Define canonical Project / Milestone / Task / Bug contracts and invariants
- Status: done
- Order: 2
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-001`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed contract definitions or schemas for Project, Milestone, Task, and Bug plus explicit invariant rules
- Done when: the repo defines canonical fields, identity rules, state boundaries, lineage expectations, and invariant checks for the four governed work objects without widening into runtime productization

### `R3-003` Implement planning-record storage and validation
- Status: done
- Order: 3
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-002`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed planning-record storage shape, validation rules, and persistence path for the governed work objects
- Done when: planning records can be durably stored, loaded, and validated while preserving distinct working, accepted, and reconciliation surfaces

### `R3-004` Define Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton contracts
- Status: done
- Order: 4
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-002`, `R3-003`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed contract definitions or schemas for Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton
- Done when: each contract has canonical required fields, lineage rules, audit expectations, and bounded handoff intent, including a Baton contract limited to foundation-only resume support

### `R3-005` Implement bounded Request Brief -> Task Packet planning flow
- Status: done
- Order: 5
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-003`, `R3-004`
- Authority: `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed bounded planning flow that converts a Request Brief into a Task Packet with explicit invariants and durable records
- Done when: the repo can run a narrow supervised planning flow from Request Brief to Task Packet without widening into a broad workflow engine

### `R3-006` Implement QA gate with remediation tracking and external-audit packaging
- Status: done
- Order: 6
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-004`, `R3-005`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed QA gate behavior, remediation tracking shape, and External Audit Pack packaging path
- Done when: QA outcomes can block or advance work with durable remediation tracking and intentionally packaged external-audit artifacts suitable for an initial double-audit loop

### `R3-007` Implement minimal task baton / resume persistence
- Status: pending
- Order: 7
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-003`, `R3-004`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed baton or resume persistence foundation for tasks
- Done when: the repo can persist and reload a minimal baton state needed for bounded task resume foundations without claiming full recovery or rollback productization

### `R3-008` Produce replayable end-to-end R3 planning proof
- Status: pending
- Order: 8
- Milestone: `R3 Governed Work Objects and Double-Audit Foundations`
- Depends on: `R3-005`, `R3-006`, `R3-007`
- Authority: `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: committed replay record proving the bounded R3 planning slice from request through audit-ready packaging
- Done when: the repo can replay a direct end-to-end R3 planning proof with durable evidence for governed work objects, request-to-task flow, QA gating, external-audit packaging, and minimal baton foundations

## Explicitly Out Of Scope For This Milestone
- broad UI or control-room productization
- Standard or subproject pipeline productization
- later-lane workflow expansion beyond what is needed for the bounded R3 planning proof
- rollback or product recovery productization
- donor backlog import or historical backfill
