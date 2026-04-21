# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

Objective:
Advance bounded R5 foundations after R4 one gated slice at a time, with `R5-002` now re-closed as the corrected Git-backed milestone baseline slice and `R5-003` as the next gated step, while continuing to avoid restore-gate, resume, repo-enforcement, proof-review expansion, UI, Standard runtime, rollback execution, unattended automatic resume, or broader orchestration claims.

Exit Criteria:
- `R5-001` through `R5-007` are recorded in repo truth
- `R5-001` is complete as the repo-truth open step
- `R5-002` is complete again after corrected hardening through `R5-002A` through `R5-002G`
- `R5-003` through `R5-007` remain explicitly planned until later implementation work is opened and proved
- the corrected `R5-002` slice still does not claim restore-gate behavior, resume behavior, repo-enforcement behavior, proof-suite expansion, UI, Standard runtime, rollback execution, or broader orchestration

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
- Status: done
- Order: 2
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-001`
- Authority: `governance/VISION.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: corrected Git-backed milestone baseline foundations with repository congruence enforcement, persisted Git identity hardening, honest focused tests, explicit path and save semantics, stronger evidence and anchor reconciliation, explicit runtime and dependency fail-closed handling, and reconciled repo truth
- Done when: `R5-002A` through `R5-002G` are complete, the focused milestone-baseline suite passes from a clean worktree, and the slice is honestly restated as complete without claiming rollback execution or any later R5 capability

### `R5-002A` Enforce repository congruence for milestone baseline capture
- Status: done
- Order: 2A
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: strengthened same-repository validation rules for milestone baseline capture plus explicit refusal behavior for cross-repo inputs
- Done when: code prevents cross-repo baseline capture, happy-path capture uses governed artifacts inside the captured repository, and focused tests explicitly reject cross-repo capture

### `R5-002B` Harden persisted Git identity validation
- Status: done
- Order: 2B
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002A`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: stronger validation for `repository_root`, `branch`, `head_commit`, and `tree_id` plus repository-linkage checks where appropriate
- Done when: malformed or tampered stored Git identity fails validation, and contract plus implementation meaningfully enforce Git identity instead of presence checks only

### `R5-002C` Repair misleading happy path and expand focused tests
- Status: done
- Order: 2C
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002A`, `R5-002B`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: corrected happy-path baseline test, refusal tests for cross-repo inputs, and focused coverage for detached HEAD, dirty-state policy, malformed accepted-planning state, cross-milestone mismatch, corrupted stored Git fields, and repeated `baseline_id` behavior
- Done when: the current core defect is caught by tests, the focused suite no longer normalizes broken behavior, and the test claim level is honest for bounded `R5-002`

### `R5-002D` Harden path handling, portability, and save semantics
- Status: done
- Order: 2D
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002C`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: explicit path resolution policy for `RepositoryRoot`, `StorePath`, and `BaselinePath`, explicit portability stance for persisted `git.repository_root`, and explicit overwrite versus immutability policy for repeated `baseline_id`
- Done when: caller working directory does not silently change semantics without governance, save and load portability stance is explicit, and duplicate-id behavior is explicit and tested

### `R5-002E` Harden evidence model and anchor reconciliation
- Status: done
- Order: 2E
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002C`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: explicit evidence-ref validation, stronger reconciliation between planning-record parent identity and milestone anchor refs or paths, and reduced duplication or explicit justification where evidence repeats top-level refs
- Done when: evidence is useful and minimally sufficient, anchor semantics are enforced instead of narrated, and same-milestone validation is stronger than loose object-id coincidence alone if needed

### `R5-002F` Make runtime and dependency assumptions explicit and fail-closed
- Status: done
- Order: 2F
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002A`, `R5-002B`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: explicit Git CLI prerequisite handling, explicit statement of dependency on earlier R3 validators, and explicit failure messaging when those dependencies are absent or invalid
- Done when: runtime prerequisites are not implicit, dependency assumptions are documented where necessary, and failure mode is explicit and bounded

### `R5-002G` Restate repo truth and re-close `R5-002` only after corrected proof
- Status: done
- Order: 2G
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002A`, `R5-002B`, `R5-002C`, `R5-002D`, `R5-002E`, `R5-002F`
- Authority: `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- Durable output: corrected `README.md`, `execution/KANBAN.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, and `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md` wording aligned to corrected code and focused test coverage
- Done when: repo truth no longer overstates what the focused baseline test proves, `R5-002` can be honestly restated as complete, and `R5-003` remains the next gated step

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
