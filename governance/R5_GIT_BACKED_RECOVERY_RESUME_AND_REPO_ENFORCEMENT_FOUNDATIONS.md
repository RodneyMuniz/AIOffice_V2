# R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations

## Milestone name
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

## Why this milestone exists now
R4 closed a bounded hardening milestone for internal control-kernel, workflow, and CI foundations. The first R4 closeout posture was not clean enough, and the corrective completion layer `R4-008` through `R4-011` was required before honest closure could be restated.

The next defensible step is still not UI expansion, not Standard or subproject runtime, and not broad orchestrator productization. The first implemented step inside R5 is the bounded Git-backed milestone baseline slice, while later restore, resume, and repo-enforcement foundations remain gated and unproved.

## Objective
Strengthen the next bounded foundation layer after R4 by implementing Git-backed milestone baselines first, then gating later bounded rollback and restore foundations, stronger baton continuity and resume authority semantics, and stronger CI/CD automation plus repo-enforcement expectations without adding UI, without opening Standard runtime claims, without claiming automatic resume, and without claiming broader orchestration.

## Exit criteria
- repo truth records `R5-002` as the first implemented R5 slice without widening the currently proved boundary beyond what the branch actually contains
- Git-backed milestone baseline foundations are explicit in bounded R5 terms through contracts, capture and storage code, and focused tests
- bounded rollback and restore gate expectations are explicit without claiming rollback as already implemented
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
- Done when: the repo captures Git-backed milestone baselines with explicit operator authority, clean-worktree capture rules, Git branch / head / tree identity, milestone anchoring, accepted planning record capture, durable storage, and focused tests without claiming rollback execution

### `R5-003` Define bounded rollback / restore gate foundations
- Status: open
- Done when: R5 planning clearly defines restore target rules, authority checks, and bounded rollback gate expectations, and the scope stays foundation-only unless later implementation proves more

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
- `R5-002` is now complete as the Git-backed milestone baseline slice only.
- The implemented `R5-002` surface is limited to milestone-baseline contracts, `tools/MilestoneBaseline.psm1`, and `tests/test_milestone_baseline.ps1`.
- `R5-003` through `R5-007` remain open and planned only.
- `R5-002` does not claim rollback execution, restore-gate behavior, resume behavior, repo-enforcement behavior, or proof-suite expansion.
- R4 remains the prior closed milestone, and its historical closeout authority remains in `governance/POST_R4_CLOSEOUT.md` and `governance/POST_R4_AUDIT_INDEX.md`.
- The final narrative bridge artifact for the R4 to R5 transition is `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`.
- The `governance/Product Vision V1 baseline/` folder remains reference-only direction material and is not milestone evidence.
