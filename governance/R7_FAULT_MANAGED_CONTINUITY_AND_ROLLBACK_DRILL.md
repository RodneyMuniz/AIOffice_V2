# R7 Fault-Managed Continuity and Rollback Drill

## Milestone name
`R7 Fault-Managed Continuity and Rollback Drill`

## Why this milestone exists now
R6 is honestly closed, but it exposed the next trust weakness instead of closing the story.

The repo now has a real bounded supervised milestone cycle, yet the actual R6 delivery also suffered a real Codex continuity and context-window break. R6 did not fail because of that break, and it is not grounds to reopen R6. It is a carry-forward concern that now has to become first-class repo truth.

The honest next claim is not "make sessions longer." The honest next claim is "make milestone work survive interruption across governed segments without depending on narrative reconstruction." The same applies to rollback readiness: the next step is not destructive rollback productization, but one governed rollback plan plus one safe rollback drill inside a disposable environment only.

## Objective
Prove one interrupted-and-resumed supervised milestone cycle for `AIOffice_V2` only, with first-class interruption truth, governed continuity checkpoints and handoff packets, one governed rollback plan, and one safe rollback drill in a disposable environment, without widening into unattended automatic resume, destructive primary-tree rollback, UI productization, Standard runtime, multi-repo behavior, swarms, or broader orchestration.

## Current status
`R7 Fault-Managed Continuity and Rollback Drill` is open in repo truth with `R7-001` and `R7-002` complete.

`R7-001` is complete as the repo-truth open step.

`R7-002` is complete as a bounded fault/interruption contract slice through `contracts/fault_management/foundation.contract.json`, `contracts/fault_management/fault_event.contract.json`, `tools/FaultManagement.psm1`, `tools/validate_fault_event.ps1`, `state/fixtures/valid/fault_management/fault_event.valid.json`, and focused proof through `tests/test_fault_management_event.ps1`. That slice proves first-class interruption/fault contract shape, durable identity, repository plus branch/head/tree context, supervision state, required next action, explicit `automatic_recovery_claim` non-claim, and fail-closed validation only.

`R6 Supervised Milestone Autocycle Pilot` remains formally closed on the original replay-closeout bar under `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, the committed proof-review basis under `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/`, and decision authority `D-0041`.

The next gated step inside active R7 is `R7-003 Emit governed continuity checkpoints and handoff packets`.

The accepted `R7-002` slice does not yet prove continuity checkpoints, handoff packets, supervised resume-from-fault behavior, continuity ledger stitching, governed rollback-plan generation, rollback drill execution, unattended automatic resume, or destructive primary-tree rollback.

## Exact boundary
This milestone is bounded to:
- one repository only: `AIOffice_V2`
- one active milestone cycle at a time
- one interrupted-and-resumed supervised cycle only
- one governed rollback plan only
- one safe rollback drill only
- rollback drill only in a disposable environment such as a disposable branch, worktree, or replay sandbox
- explicit operator approval required before any rollback drill that mutates Git state
- one replayable proof package at closeout
- advisory operator review only unless later repo truth proves more

## Exact stop conditions
R7 must refuse or stop if:
- interruption or fault state is not durably captured as governed repo truth
- continuity or handoff state would require narrative reconstruction instead of governed checkpoint or packet reuse
- resume-from-fault would proceed without explicit operator authority
- continuity stitching loses milestone, segment, or repository identity
- a rollback plan is missing, malformed, or points outside the bounded disposable drill scope
- a rollback drill would mutate Git state without explicit operator approval
- a rollback drill would target the primary working tree instead of a disposable branch, worktree, or replay sandbox
- evidence, review, or closeout wording outruns the exact interrupted-and-resumed scope actually proved
- scope widens beyond one repository, one active milestone cycle, one governed rollback plan, one safe rollback drill, or advisory review only

## Required milestone outputs
By the end of `R7`, the milestone must produce:
- first-class fault and interruption event contracts
- governed continuity checkpoints and handoff packets
- one supervised resume-from-fault flow
- one continuity ledger for multi-segment milestone stitching
- one governed rollback plan artifact
- one safe rollback drill harness constrained to a disposable environment
- one advisory continuity and rollback review summary plus operator packet
- one replayable interrupted-and-resumed proof plus rollback drill packet
- repo-truth and closeout surfaces that state the interrupted continuity claim honestly and preserve non-claims

## Preserved non-claims
R7 does not currently prove and must not casually widen into:
- broader autonomy
- unattended automatic resume
- destructive rollback on the primary working tree
- UI or control-room productization
- unified workspace delivery
- Standard runtime or subproject runtime
- multi-repo behavior
- swarms
- broader orchestration
- raw "longer sessions" as a runtime capability claim

## In scope
- one repository-local interrupted milestone cycle for `AIOffice_V2`
- first-class interruption and fault truth
- governed continuity checkpoints and handoff packets
- one supervised interrupted-and-resumed cycle with explicit operator control
- one continuity ledger that stitches governed segments into one authoritative milestone view
- one governed rollback plan kept explicitly separate from rollback execution
- one safe rollback drill in a disposable branch, worktree, or replay sandbox only
- one advisory continuity and rollback review packet
- one replayable proof package for the exact interrupted-and-resumed plus rollback-drill scope

## Explicitly out of scope
- broader autonomy or unattended operation
- unattended automatic resume behavior
- destructive rollback execution on the primary working tree
- rollback drill execution outside a disposable environment
- UI or control-room productization
- unified workspace delivery
- Standard or subproject runtime
- multi-repo or fleet behavior
- swarms or parallel executor expansion
- broader orchestration beyond the exact bounded cycle
- donor backlog import or donor milestone migration

## Dependencies and prerequisites
- `RST-009` through `RST-012` remain complete and externally accepted
- `R3-001` through `R3-008` remain complete in repo truth
- `R4-001` through `R4-011` remain complete in repo truth
- `R5-001` through `R5-007` remain complete and formally closed in repo truth
- `R6 Supervised Milestone Autocycle Pilot` remains honestly closed under `D-0041` on the original replay-closeout bar
- the committed R6 proof-review package under `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/` remains the authority for what R6 did and did not prove
- Git and persisted state remain the authoritative truth substrates
- admin-only posture remains in force unless later repo truth explicitly proves more
- R7 ordering remains thin: interruption and continuity truth must land before rollback drill execution or any surface expansion

## Key risks
- narrating around interruption instead of preserving governed continuity artifacts
- overclaiming "longer sessions" instead of proving segmented continuity across governed handoffs
- letting rollback drill scope drift from disposable rehearsal into destructive execution
- allowing rollback drill activity on the primary working tree
- widening R7 into UI, autonomy, Standard runtime, multi-repo behavior, swarms, or broader orchestration before continuity truth is proved
- flattening the honest R6 reopen-and-reclose history instead of carrying the real continuity break forward as a scoped lesson

## Task list

### `R7-001` Open R7 and freeze the fault-managed continuity and rollback drill boundary
- Status: done
- Done when: R7 is open in repo truth as bounded structure only, R6 remains honestly closed on the original replay-closeout bar, the real R6 continuity and context-window break is frozen into R7 rationale and ordering, the rollback safety boundary is explicit and narrow, and no implementation beyond the opening step is implied

### `R7-002` Add first-class fault / interruption event contracts
- Status: done
- Done when: interruption and fault events have explicit governed contract shape, identity, repository plus git context, supervision state, required next action, explicit `automatic_recovery_claim` non-claim, and fail-closed validation without yet claiming checkpoints, handoff packets, or resume behavior

### `R7-003` Emit governed continuity checkpoints and handoff packets
- Status: planned
- Done when: one interrupted milestone segment can emit governed checkpoints and handoff packets with enough durable truth to avoid narrative reconstruction

### `R7-004` Add supervised resume-from-fault flow
- Status: planned
- Done when: one interrupted-and-resumed supervised cycle can re-enter from governed continuity artifacts under explicit operator control without implying unattended automatic resume

### `R7-005` Add continuity ledger and multi-segment milestone stitching
- Status: planned
- Done when: one milestone can preserve authoritative segment lineage, ordering, and continuity state across governed interruption and resume boundaries

### `R7-006` Add governed rollback plan artifact
- Status: planned
- Done when: one governed rollback plan artifact records target scope, approvals, environment constraints, and refusal conditions durably without executing rollback

### `R7-007` Add safe rollback drill harness
- Status: planned
- Done when: one rollback drill harness runs only inside a disposable branch, worktree, or replay sandbox, requires explicit operator approval before any Git mutation, and refuses primary-worktree execution

### `R7-008` Add advisory continuity / rollback review summary and operator packet
- Status: planned
- Done when: one bounded advisory review packet summarizes continuity and rollback drill evidence, records explicit non-claims, and does not imply automatic or destructive execution

### `R7-009` Produce one replayable interrupted-and-resumed proof plus rollback drill packet
- Status: planned
- Done when: one exact interrupted-and-resumed supervised cycle plus one safe rollback drill are replayable from committed evidence, closeout wording matches exact proved scope, and non-claims remain explicit

## Milestone notes
- `R7-001` opens R7 in repo truth as bounded structure only. It does not claim that fault-managed continuity, resume-from-fault, rollback planning, rollback drill execution, or closeout proof is implemented.
- `R7-002` now makes interruption and fault records first-class governed repo truth through explicit contracts and fail-closed validation only. It does not emit checkpoints or handoff packets, it does not resume from fault, and it does not generate rollback plans or drills.
- The real R6 continuity and context-window break is preserved here as an ordering driver: interruption and continuity truth comes first, before rollback drill work and far before any UI or orchestration growth.
- R7 keeps rollback rehearsal explicitly disposable. Any Git-mutating rollback drill still requires explicit operator approval and must not target the primary working tree.
- Advisory operator review remains the ceiling for this milestone unless later repo truth proves more.
