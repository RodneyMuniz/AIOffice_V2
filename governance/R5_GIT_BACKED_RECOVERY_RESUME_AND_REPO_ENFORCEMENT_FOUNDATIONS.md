# R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations

## Milestone name
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

## Why this milestone exists now
R4 closed a bounded hardening milestone for internal control-kernel, workflow, and CI foundations. The first R4 closeout posture was not clean enough, and the corrective completion layer `R4-008` through `R4-011` was required before honest closure could be restated.

The next defensible step is still not UI expansion, not Standard or subproject runtime, and not broad orchestrator productization. The corrected Git-backed milestone-baseline slice is now complete again as `R5-002`, and the bounded rollback / restore gate foundation slice is now complete as `R5-003`, while later resume and repo-enforcement foundations remain gated and unproved.

## Objective
Strengthen the next bounded foundation layer after R4 by correcting and hardening Git-backed milestone baselines first, then implementing bounded rollback and restore gate foundations before later baton continuity and resume authority semantics, and stronger CI/CD automation plus repo-enforcement expectations without adding UI, without opening Standard runtime claims, without claiming automatic resume, and without claiming broader orchestration.

## Exit criteria
- repo truth records `R5-002` as complete again after corrected hardening through `R5-002A` through `R5-002G`
- the corrective task layer under `R5-002` is completed and remains bounded to the milestone-baseline slice only
- bounded rollback and restore gate foundations are implemented and focused-proofed without claiming rollback execution
- strengthened baton continuity and resume authority expectations are explicit without claiming automatic resume
- bounded resume re-entry expectations are explicit and operator-controlled
- the planned next CI/CD automation layer is explicit and remains aligned to the actual proof scope
- repo-enforcement expectations for clean worktrees, governed evidence, and bounded proof discipline are explicit
- the expected R5 proof and closeout structure is defined in advance

## In scope
- Git-backed milestone baseline capture foundations
- restore target and rollback gate authority model
- stronger baton continuity semantics for pause and resume re-entry
- bounded resume path expectations with explicit operator control
- stronger CI/CD automation direction beyond the current R4 bounded replay foundation
- stronger repo enforcement direction around cleanliness, governed evidence, and bounded proof discipline
- bounded planning structure for R5 proof and closeout expectations

## Explicitly out of scope
- any operator-visible or user-facing UI work
- unified workspace work
- chat or intake UX
- approvals queue UI
- cost dashboard UI
- settings or admin UI productization
- truthful visibility surface
- Standard or subproject runtime
- broad orchestrator autonomy
- unattended automatic resume
- rollback or broader recovery productization beyond the bounded foundation layer being defined here
- donor backlog import or donor milestone migration

## Dependencies and prerequisites
- `RST-009` through `RST-012` remain complete and externally accepted
- `R3-001` through `R3-008` remain complete in repo truth
- `R4-001` through `R4-011` remain complete in repo truth
- `governance/POST_R4_CLOSEOUT.md` and `governance/POST_R4_AUDIT_INDEX.md` remain the historical bounded R4 freeze surfaces
- Git and persisted state remain the authoritative truth substrates
- admin-only posture remains in force unless later repo truth explicitly proves more

## Key risks
- treating Git-backed baseline planning as if rollback were already productized
- overstating baton continuity and resume planning as if automatic resume were already proved
- widening R5 into UI, Standard runtime, or broader orchestration before the underlying foundations are real
- letting CI/CD automation claims outrun the actual bounded proof scope
- allowing repo-enforcement planning to turn into proof theater instead of verifiable discipline

## Task list

### `R5-001` Open R5 in repo truth
- Status: done
- Done when: repo truth closes the post-R4 freeze posture, the new R5 milestone brief exists, and `governance/ACTIVE_STATE.md` plus `execution/KANBAN.md` open R5 without widening claims prematurely

### `R5-002` Define Git-backed milestone baseline model
- Status: done
- Done when: `R5-002A` through `R5-002G` are complete, the focused milestone-baseline suite passes from a clean worktree, and the slice can be honestly restated as complete without claiming rollback execution or any later R5 capability

### `R5-002A` Enforce repository congruence for milestone baseline capture
- Status: done
- Done when: milestone file, planning-record files, and accepted planning refs must resolve inside the same Git worktree as `RepositoryRoot`, cross-repo capture fails closed, and focused tests explicitly reject cross-repo capture

### `R5-002B` Harden persisted Git identity validation
- Status: done
- Done when: malformed or tampered stored Git identity fails validation, and `repository_root`, `branch`, `head_commit`, and `tree_id` are meaningfully enforced instead of presence-checked only

### `R5-002C` Repair misleading happy path and expand focused tests
- Status: done
- Done when: the current misleading happy path is replaced, focused tests catch the core defect surface, and the suite covers detached HEAD, dirty-state policy, malformed accepted-planning state, cross-milestone mismatch, corrupted stored Git fields, and repeated `baseline_id` behavior honestly

### `R5-002D` Harden path handling, portability, and save semantics
- Status: done
- Done when: caller working directory does not silently change semantics without governance, save and load portability stance is explicit, and duplicate-id behavior is explicit and tested

### `R5-002E` Harden evidence model and anchor reconciliation
- Status: done
- Done when: evidence refs are validated as appropriate, planning-record parent identity reconciles cleanly with milestone anchor refs or paths, and evidence duplication is reduced or explicitly justified

### `R5-002F` Make runtime and dependency assumptions explicit and fail-closed
- Status: done
- Done when: Git CLI prerequisite handling, dependency on earlier R3 validators, and bounded failure messaging are explicit instead of implicit

### `R5-002G` Restate repo truth and re-close `R5-002` only after corrected proof
- Status: done
- Done when: repo truth no longer overstates what the focused baseline test proves, `R5-002` can be honestly restated as complete, and `R5-003` remains the next gated step

### `R5-003` Define bounded rollback / restore gate foundations
- Status: done
- Done when: restore-gate contracts, explicit restore-target rules, explicit operator authority checks, repository-binding and workspace-safety refusal rules, durable gate results, and focused restore-gate proof exist without claiming rollback execution or proof-suite expansion

### `R5-004` Define strengthened baton continuity and resume authority model
- Status: open
- Done when: R5 planning clearly defines the baton evolution needed for real pause and resume continuity, captures explicit operator authority and re-entry constraints, and makes no automatic resume claim

### `R5-005` Define bounded resume re-entry path
- Status: open
- Done when: R5 planning defines the intended bounded resume flow from persisted baton state back into governed work, makes stop points, operator control, and invalid-state expectations explicit, and does not overclaim broader orchestration

### `R5-006` Define CI/CD automation expansion for bounded proof and recovery foundations
- Status: open
- Done when: R5 planning defines the next bounded CI/CD layer needed beyond current R4 proof replay and keeps the expected automation aligned to actual proof scope

### `R5-007` Define repo enforcement and R5 proof / closeout structure
- Status: open
- Done when: R5 planning defines the repo-enforcement expectations for clean worktrees, governed evidence, and bounded proof discipline, plans the expected R5 proof and closeout surfaces in advance, and does not execute implementation yet

## Milestone notes
- `R5-001` opened R5 in repo truth as structure only.
- `R5-002` is complete again after the bounded corrective layer `R5-002A` through `R5-002G` closed from a clean worktree with the focused milestone-baseline suite.
- The current `R5-002` candidate surface remains limited to milestone-baseline contracts, `tools/MilestoneBaseline.psm1`, and `tests/test_milestone_baseline.ps1`.
- `R5-002A` through `R5-002G` are the completed corrective hardening layer that re-closed `R5-002` honestly.
- `R5-003` is complete as a bounded restore-gate foundation slice through `contracts/restore_gate/`, `tools/RestoreGate.psm1`, and `tests/test_restore_gate.ps1`.
- `R5-004` through `R5-007` remain open and planned only.
- `R5-002` and `R5-003` do not claim rollback execution, resume behavior, repo-enforcement behavior, or proof-suite expansion.
- R4 remains the prior closed milestone, and its historical closeout authority remains in `governance/POST_R4_CLOSEOUT.md` and `governance/POST_R4_AUDIT_INDEX.md`.
- The final narrative bridge artifact for the R4 to R5 transition is `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`.
- The `governance/Product Vision V1 baseline/` folder remains reference-only direction material and is not milestone evidence.
