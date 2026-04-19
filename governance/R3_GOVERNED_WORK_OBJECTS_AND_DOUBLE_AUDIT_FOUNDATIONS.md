# R3 Governed Work Objects and Double-Audit Foundations

## Milestone name
`R3 Governed Work Objects and Double-Audit Foundations`

## Why this milestone exists now
R2 established the minimum control substrate and closed out the first bounded V1 proof for supervised operation through `architect` plus bounded `apply/promotion` control.

The next bounded step is not broad UI expansion or pipeline productization. It is to turn that substrate into governed work objects, durable planning records, structured request-to-task flow, audit-ready QA artifacts, and minimal baton foundations that support the next real proof slice.

## Objective
Turn the current control substrate into governed work objects, structured request-to-task flow, double-audit-ready QA artifacts, and minimal baton foundations without broad UI expansion, without Standard pipeline productization, and without rollback or product recovery overreach.

## Exit criteria
- repo truth explicitly closes the first bounded V1 proof and opens R3
- canonical Project / Milestone / Task / Bug contracts and invariants exist
- planning-record storage and validation exist
- Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton contracts exist
- a bounded Request Brief -> Task Packet planning flow exists
- a QA gate exists with remediation tracking and external-audit packaging
- minimal task baton or resume persistence exists
- a replayable end-to-end R3 planning proof exists

## In scope
- defining canonical Project / Milestone / Task / Bug work objects
- storing and validating planning records for those governed objects
- defining Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton contracts
- implementing a bounded Request Brief -> Task Packet planning flow
- implementing a QA gate that tracks remediation and produces intentional external-audit packaging for an initial double-audit loop
- implementing minimal baton or resume persistence foundations for tasks
- producing a replayable R3 proof without broad UI expansion

## Explicitly out of scope
- broad UI or control-room productization
- Standard or subproject pipeline runtime productization
- later-lane workflow expansion beyond what is required for the bounded R3 proof
- rollback flow or product recovery productization
- cost dashboard or broader operator-console expansion
- full baton or resume recovery productization

## Dependencies and prerequisites
- `RST-009` through `RST-012` are complete and externally accepted
- the first bounded V1 proof is formally claimable only for the narrow supervised-through-`architect` plus bounded `apply/promotion` boundary
- `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md` records the R2 proof closeout
- Git and persisted state remain the authoritative truth substrates
- R3 begins with repo-truth closeout before any R3 implementation task starts

## Key risks
- overloading governed work objects with broader product semantics before the bounded proof slice is defined
- turning request-to-task flow into a broad workflow engine too early
- treating QA or external audit packaging as a full pipeline rather than a bounded double-audit foundation
- overreaching baton or resume support into full recovery or rollback claims
- allowing narration to outrank replayable artifacts and truth surfaces

## Task list

### `R3-001` Close out R2 proof and open R3 in repo truth
- Status: done
- Done when: repo truth explicitly closes the narrow first bounded V1 proof, creates the R2 closeout record, creates this milestone brief, and advances the active milestone to R3 without broadening the claim

### `R3-002` Define canonical Project / Milestone / Task / Bug contracts and invariants
- Status: done
- Done when: the repo has durable contract definitions or schemas for the four governed work objects, including identity, lineage, status, and invariant rules

### `R3-003` Implement planning-record storage and validation
- Status: done
- Done when: the governed work objects can be durably stored, loaded, and validated while preserving distinct working, accepted, and reconciliation surfaces

### `R3-004` Define Request Brief, Task Packet, Execution Bundle, QA Report, External Audit Pack, and Baton contracts
- Status: done
- Done when: the repo has durable contract definitions or schemas for those six artifacts, with explicit audit and handoff expectations

### `R3-005` Implement bounded Request Brief -> Task Packet planning flow
- Status: done
- Done when: a narrow supervised planning flow can convert a Request Brief into a Task Packet with durable evidence and bounded scope

### `R3-006` Implement QA gate with remediation tracking and external-audit packaging
- Status: pending
- Done when: QA outcomes can block or advance work with durable remediation tracking and an intentionally packaged External Audit Pack that supports an initial double-audit loop

### `R3-007` Implement minimal task baton / resume persistence
- Status: pending
- Done when: the repo can durably persist and reload a minimal baton state needed for bounded task resume foundations; this is foundation-only, not full recovery productization

### `R3-008` Produce replayable end-to-end R3 planning proof
- Status: pending
- Done when: the repo can replay a direct end-to-end R3 planning proof with durable evidence for governed work objects, request-to-task flow, QA gating, external-audit packaging, and minimal baton foundations

## Milestone notes
- Baton or resume in R3 is foundation-only. It is not a claim of full recovery, rollback, or broader operational resilience productization.
- External audit packaging is intentional in R3 because the next proof slice needs artifacts that support an initial double-audit loop rather than narration-only QA claims.
