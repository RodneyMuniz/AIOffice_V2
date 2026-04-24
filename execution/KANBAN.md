# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R7 Fault-Managed Continuity and Rollback Drill`

Current posture:
`R7 Fault-Managed Continuity and Rollback Drill` is open in repo truth with `R7-001` through `R7-007` complete. `R6 Supervised Milestone Autocycle Pilot` remains honestly closed on the original replay-closeout bar. The next gated step is `R7-008 Add advisory continuity / rollback review summary and operator packet`. The carry-forward claim is governed segmented continuity across interruption without narrative reconstruction, not raw "longer sessions." First-class fault/interruption contracts, governed checkpoint and handoff artifacts, one supervised resume-from-fault re-entry path, one authoritative continuity ledger, one governed pre-execution rollback plan, and one safe disposable-worktree rollback drill now exist, but advisory review packaging, replayable closeout proof, and destructive primary-tree rollback are still unproved here.

## Most Recently Closed Milestone
`R6 Supervised Milestone Autocycle Pilot`

Closeout summary:
`R6-001`, `R6-P1`, `R6-P2`, and `R6-002` through `R6-009` are complete and formally closed in repo truth. The closeout authority is `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, the committed proof-review basis is `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/` at replay source head `9069b29ace87d787515b4c4fb5e9c94e6fa40743`, and decision authority is `D-0041`, not the earlier softened `D-0039` posture. That package records raw replay logs, summary artifacts, exact proof selection scope, replay-source metadata, authoritative artifact refs, one replay proof, one closeout packet, one closeout review, and explicit non-claims for the exact pilot replay from structured intake through advisory-only operator decision. This closeout remains bounded and does not add executed operator acceptance, broad autonomy, rollback execution, unattended automatic resume, UI, Standard runtime, multi-repo behavior, swarms, or broader orchestration claims.

## Tasks

### `R7-001` Open R7 and freeze the fault-managed continuity and rollback drill boundary
- Status: done
- Order: 1
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/`, `D-0041`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`
- Durable output: updated repo-truth surfaces that open R7 as structure only and freeze the exact continuity and rollback-drill boundary
- Done when: R7 is the active milestone in repo truth, R6 remains honestly closed on the original replay-closeout bar, the real R6 continuity-break lesson is frozen into early R7 ordering, the rollback safety boundary is explicit and narrow, and no runtime implementation beyond the open step is implied

### `R7-002` Add first-class fault / interruption event contracts
- Status: done
- Order: 2
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-001`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `governance/ACTIVE_STATE.md`, `contracts/fault_management/`
- Durable output: one bounded contract and validation layer that records interruption and fault events as governed repo truth with explicit identity, repository plus git context, supervision state, required next action, and explicit automatic-recovery non-claim
- Done when: interruption or fault events have explicit authoritative contract shape, required fields, durable identity, and fail-closed validation through `contracts/fault_management/foundation.contract.json`, `contracts/fault_management/fault_event.contract.json`, `tools/FaultManagement.psm1`, `tools/validate_fault_event.ps1`, and `tests/test_fault_management_event.ps1` without yet claiming checkpoints, handoff packets, or resume behavior

### `R7-003` Emit governed continuity checkpoints and handoff packets
- Status: done
- Order: 3
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-002`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `contracts/milestone_continuity/`, `tools/MilestoneContinuity.psm1`
- Durable output: governed checkpoint and handoff packet surfaces for interrupted milestone work, each chained explicitly back to an accepted `R7-002` fault event and the current authoritative milestone refs
- Done when: one interrupted milestone segment can emit durable checkpoints and handoff packets that carry enough governed truth to avoid narrative reconstruction through `contracts/milestone_continuity/`, `tools/MilestoneContinuity.psm1`, `tools/validate_milestone_continuity_artifact.ps1`, and `tests/test_milestone_continuity_artifacts.ps1`

### `R7-004` Add supervised resume-from-fault flow
- Status: done
- Order: 4
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-003`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `contracts/milestone_continuity/`, `tools/MilestoneContinuityResume.psm1`
- Durable output: one supervised resume-from-fault request/result surface plus one preparation flow that re-enters from governed continuity artifacts under explicit operator control
- Done when: one interrupted-and-resumed supervised cycle can re-enter from governed checkpoints and handoff packets under explicit operator control through `contracts/milestone_continuity/resume_from_fault_request.contract.json`, `contracts/milestone_continuity/resume_from_fault_result.contract.json`, `tools/MilestoneContinuityResume.psm1`, `tools/prepare_supervised_resume_from_fault.ps1`, `state/fixtures/valid/milestone_continuity/resume_from_fault_request.valid.json`, `state/fixtures/valid/milestone_continuity/resume_from_fault_result.valid.json`, and `tests/test_milestone_continuity_resume_from_fault.ps1` without implying unattended resume

### `R7-005` Add continuity ledger and multi-segment milestone stitching
- Status: done
- Order: 5
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-004`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `contracts/milestone_continuity/`, `tools/MilestoneContinuityLedger.psm1`
- Durable output: one authoritative continuity ledger that stitches governed milestone segments into one bounded continuity view
- Done when: one interrupted milestone preserves authoritative segment lineage, ordering, and continuity state across governed interruption and supervised resume boundaries through `contracts/milestone_continuity/continuity_ledger.contract.json`, `tools/MilestoneContinuityLedger.psm1`, `tools/validate_milestone_continuity_ledger.ps1`, `state/fixtures/valid/milestone_continuity/continuity_ledger.valid.json`, and `tests/test_milestone_continuity_ledger.ps1`

### `R7-006` Add governed rollback plan artifact
- Status: done
- Order: 6
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-005`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `contracts/milestone_continuity/`, `tools/MilestoneRollbackPlan.psm1`
- Durable output: one governed rollback plan artifact that stays explicitly pre-execution and reuses authoritative continuity-ledger plus baseline-binding truth
- Done when: one governed rollback plan artifact records target scope, approvals, environment constraints, refusal conditions, and target repository or branch or head or tree context durably without executing rollback through `contracts/milestone_continuity/rollback_plan_request.contract.json`, `contracts/milestone_continuity/rollback_plan.contract.json`, `tools/MilestoneRollbackPlan.psm1`, `tools/prepare_milestone_rollback_plan.ps1`, `tools/validate_milestone_rollback_plan.ps1`, `state/fixtures/valid/milestone_continuity/rollback_plan_request.valid.json`, and `tests/test_milestone_rollback_plan.ps1`

### `R7-007` Add safe rollback drill harness
- Status: done
- Order: 7
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-006`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `contracts/milestone_continuity/`, `tools/MilestoneRollbackDrill.psm1`
- Durable output: one rollback drill harness constrained to one disposable worktree with explicit drill authorization and durable drill-result output
- Done when: one safe rollback drill can run only in a disposable worktree, requires explicit operator approval before any Git mutation, refuses primary-worktree execution, and is proved through `contracts/milestone_continuity/rollback_drill_authorization.contract.json`, `contracts/milestone_continuity/rollback_drill_result.contract.json`, `tools/MilestoneRollbackDrill.psm1`, `tools/invoke_milestone_rollback_drill.ps1`, `tools/validate_milestone_rollback_drill_result.ps1`, `state/fixtures/valid/milestone_continuity/rollback_drill_authorization.valid.json`, and `tests/test_milestone_rollback_drill.ps1`

### `R7-008` Add advisory continuity / rollback review summary and operator packet
- Status: planned
- Order: 8
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-007`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`
- Durable output: one advisory review summary and operator packet for continuity and rollback drill results
- Done when: the operator receives one bounded advisory summary of continuity and rollback evidence with explicit non-claims and no implied automatic execution

### `R7-009` Produce one replayable interrupted-and-resumed proof plus rollback drill packet
- Status: planned
- Order: 9
- Milestone: `R7 Fault-Managed Continuity and Rollback Drill`
- Depends on: `R7-008`
- Authority: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `governance/DECISION_LOG.md`
- Durable output: one replayable interrupted-and-resumed proof package plus one rollback drill packet
- Done when: one exact interrupted-and-resumed supervised cycle plus one safe rollback drill are replayable from committed evidence, closeout wording matches the exact scope, and non-claims remain explicit

## Explicitly Out Of Scope For This Milestone
- broader autonomy
- unattended automatic resume
- destructive rollback on the primary working tree
- UI or control-room productization
- unified workspace delivery
- Standard or subproject runtime
- multi-repo behavior
- swarms
- broader orchestration
- raw "longer sessions" as a runtime capability claim
