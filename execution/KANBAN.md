# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`No post-R5 implementation milestone is open in repo truth.`

Objective:
Preserve formal R5 closeout truth and bounded evidence without implicitly opening any later milestone or widening rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration claims.

Exit Criteria:
- `governance/POST_R5_CLOSEOUT.md` and `governance/POST_R5_AUDIT_INDEX.md` record bounded R5 closure and audit mapping explicitly
- committed closeout evidence names `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` plus the focused R5 proof surfaces actually used for closure
- no post-R5 implementation milestone is opened implicitly by closeout wording
- the preserved non-claims remain explicit: no rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration

## Most Recently Closed Milestone
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

Closeout summary:
`R5-001` through `R5-007` are complete and formally closed in repo truth. The closeout authority is `governance/POST_R5_CLOSEOUT.md`, the audit mapping authority is `governance/POST_R5_AUDIT_INDEX.md`, and the committed bounded proof-review basis is `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` at replay source head `1a97ff0cef9675c88030d3b618ef928093ee080c`. This closeout remains bounded and does not add rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration claims.

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
- Status: done
- Order: 3
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: restore-gate contracts, explicit restore-target rules, explicit operator authority checks, repository-binding and workspace-safety refusal rules, durable gate results, and focused restore-gate proof
- Done when: restore targets are validated against milestone baselines, unauthorized or invalid rollback-gate states fail closed, focused proof passes through `tests/test_restore_gate.ps1`, and the slice remains foundation-only without claiming rollback execution or proof-suite expansion

### `R5-004` Define strengthened baton continuity and resume authority model
- Status: done
- Order: 4
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: strengthened baton contract and persistence rules, explicit operator-controlled resume-authority metadata, bounded re-entry context capture, fail-closed continuity validation, and focused baton proof
- Done when: batons carry explicit resume_authority and resume_context fields, invalid or unauthorized continuity states fail closed, focused proof passes through `tests/test_baton_persistence.ps1` and `tests/test_work_artifact_contracts.ps1`, and the slice remains foundation-only without claiming resume execution or proof-suite expansion

### `R5-005` Define bounded resume re-entry path
- Status: done
- Order: 5
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-003`, `R5-004`
- Authority: `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: resume-reentry contracts, explicit operator-controlled re-entry rules, fail-closed invalid-state refusal behavior, prepared retry-entry execution-bundle output, and focused resume-reentry proof
- Done when: persisted Baton state can be validated into one bounded retry-entry Execution Bundle only when operator-controlled authority and restore-gate expectations are satisfied, invalid states fail closed, focused proof passes through `tests/test_resume_reentry.ps1`, and the slice does not claim unattended automatic resume or broader orchestration

### `R5-006` Define CI/CD automation expansion for bounded proof and recovery foundations
- Status: done
- Order: 6
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`
- Authority: `governance/ACTIVE_STATE.md`, `governance/OPERATING_MODEL.md`
- Durable output: bounded proof-runner expansion for implemented R5 ids, focused proof-runner verification for that expansion, and continued reuse of the existing workflow entrypoint without symbolic automation growth
- Done when: the existing bounded proof runner and `.github/workflows/bounded-proof-suite.yml` replay the implemented R5 foundation subset, focused verification passes through `tests/test_bounded_proof_suite.ps1` plus `tests/test_bounded_proof_ci_foundation.ps1`, and the slice does not claim repo-enforcement, closeout automation, or broader product maturity

### `R5-007` Define repo enforcement and R5 proof / closeout structure
- Status: done
- Order: 7
- Milestone: `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`
- Depends on: `R5-002`, `R5-003`, `R5-004`, `R5-005`, `R5-006`
- Authority: `governance/ACTIVE_STATE.md`, `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- Durable output: repo-enforcement contracts and fail-closed evaluation, bounded R5 proof-review generation, focused repo-enforcement and proof-review tests, and explicit closeout-discipline structure without milestone overclaim
- Done when: clean-worktree pre-replay discipline, governed proof output roots, replay-summary and replay-command evidence, exact proof-id selection scope, raw log presence, replay-source-head consistency, and explicit refusal behavior are implemented and proved, while full R5 milestone closeout remains separate from this task and is recorded later through `governance/POST_R5_CLOSEOUT.md`

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
