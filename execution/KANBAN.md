# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

Objective:
Define the next bounded milestone after R4 for Git-backed recovery, resume, and repo-enforcement foundations without executing R5 implementation yet.

Exit Criteria:
- `R5-001` through `R5-007` are recorded in repo truth
- `R5-001` is complete as the repo-truth open step
- `R5-002` through `R5-007` remain explicitly planned until later implementation work is opened and proved
- no R5 code, contracts, tests, workflows, or proof packages are created by this planning step

## Tasks

### `R5-001` Open R5 in repo truth
- Status: done
- Order: 1
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `governance/POST_R4_CLOSEOUT.md`, `governance/POST_R4_AUDIT_INDEX.md`
- Authority: `governance/ACTIVE_STATE.md`, `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`, `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`
- Durable output: updated repo-truth surfaces plus explicit R5 milestone-brief document
- Done when: repo truth closes the post-R4 freeze posture, the new R5 milestone brief exists, and `governance/ACTIVE_STATE.md` plus `execution/KANBAN.md` open R5 without widening claims prematurely

### `R5-002` Define Git-backed milestone baseline model
- Status: open
- Order: 2
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-001`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: planned milestone-baseline model, authority rules, and intended durable outputs
- Done when: repo truth defines what a milestone baseline is in bounded R5 terms, the planned durable outputs and authority rules are explicit, and no rollback is claimed as already implemented

### `R5-003` Define bounded rollback / restore gate foundations
- Status: open
- Order: 3
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: planned restore-target rules, authority checks, and bounded rollback-gate expectations
- Done when: R5 planning clearly defines restore target rules, authority checks, and bounded rollback gate expectations, and the scope stays foundation-only unless later implementation proves more

### `R5-004` Define strengthened baton continuity and resume authority model
- Status: open
- Order: 4
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: planned baton-evolution and resume-authority model
- Done when: R5 planning clearly defines the baton evolution needed for real pause and resume continuity, captures explicit operator authority and re-entry constraints, and makes no automatic resume claim

### `R5-005` Define bounded resume re-entry path
- Status: open
- Order: 5
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-003`, `R5-004`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: planned bounded resume flow with explicit stop points and operator control
- Done when: R5 planning defines the intended bounded resume flow from persisted baton state back into governed work, makes stop points, operator control, and invalid-state expectations explicit, and does not overclaim broader orchestration

### `R5-006` Define CI/CD automation expansion for bounded proof and recovery foundations
- Status: open
- Order: 6
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: planned next-layer CI/CD automation expectations for bounded proof, recovery, and resume foundations
- Done when: R5 planning defines the next bounded CI/CD layer needed beyond current R4 proof replay and keeps the expected automation aligned to actual proof scope

### `R5-007` Define repo enforcement and R5 proof / closeout structure
- Status: open
- Order: 7
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`, `R5-006`
- Authority: `governance/ACTIVE_STATE.md`, `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- Durable output: planned repo-enforcement expectations plus planned R5 proof and closeout surfaces
- Done when: R5 planning defines the repo-enforcement expectations for clean worktrees, governed evidence, and bounded proof discipline, plans the expected R5 proof and closeout surfaces in advance, and does not execute implementation yet

## Explicitly Out Of Scope For This Milestone
- operator-visible or user-facing UI work
- unified workspace work
- chat or intake UX
- approvals queue UI
- cost dashboard UI
- settings or admin UI productization
- Standard or subproject runtime
- rollback or broader recovery productization beyond bounded foundations
- automatic resume behavior
- broader orchestration beyond the currently bounded chain
- donor backlog import or historical backfill
