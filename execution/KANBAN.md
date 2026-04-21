# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

Objective:
Implement the bounded Git-backed baseline, restore-gate, stronger baton continuity, bounded resume re-entry, CI-proof expansion, and repo-enforcement foundations after R4 without widening into UI, Standard runtime, rollback execution, unattended automatic resume, or broader orchestration.

Exit Criteria:
- `R5-001` through `R5-007` are recorded in repo truth
- `R5-002` through `R5-007` are backed by real bounded code, focused tests, and proof-runner coverage
- repo truth remains narrower than the implementation and proof surface, not broader
- R5 milestone closure is deferred until a later closeout replay and truth-reconciliation pass from clean repo state

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
- Durable output: milestone-baseline contracts, storage module, focused tests, and repo-truth updates
- Done when: the repo captures Git-backed milestone baselines with explicit operator authority, clean-worktree requirements, durable storage, and honest non-claims about rollback execution

### `R5-003` Define bounded rollback / restore gate foundations
- Status: done
- Order: 3
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: restore-gate contracts, gate module, focused tests, and repo-truth updates
- Done when: the repo records explicit restore targets, authority checks, and fail-closed blocked reasons without executing restore actions or claiming broader recovery productization

### `R5-004` Define strengthened baton continuity and resume authority model
- Status: done
- Order: 4
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: stronger baton contract fields, persistence changes, focused negative fixtures, and updated baton tests
- Done when: batons carry explicit operator-controlled resume authority, bounded retry-entry lineage, and manual-review stop semantics without opening automatic resume claims

### `R5-005` Define bounded resume re-entry path
- Status: done
- Order: 5
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-003`, `R5-004`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: resume re-entry contracts, module, focused tests, and proof-runner coverage
- Done when: the repo can prepare one operator-controlled retry-entry execution bundle from valid persisted baton state, fail closed on invalid state, and avoid any claim of unattended automatic resume or broader orchestration

### `R5-006` Define CI/CD automation expansion for bounded proof and recovery foundations
- Status: done
- Order: 6
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: expanded bounded proof-suite definitions, R5 proof-review entrypoint, and focused proof-review tests
- Done when: the source-controlled proof runner and proof-review entrypoint cover the bounded R5 foundations they claim without symbolic automation or proof inflation

### `R5-007` Define repo enforcement and R5 proof / closeout structure
- Status: done
- Order: 7
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`, `R5-006`
- Authority: `governance/ACTIVE_STATE.md`, `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- Durable output: repo-enforcement contracts and module, focused tests, R5 proof-and-closeout plan, and repo-truth updates
- Done when: the repo has bounded enforcement checks for clean-worktree discipline, proof-summary coverage, replay-summary presence, and closeout-plan presence, while still deferring milestone closure until later clean-state replay

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
