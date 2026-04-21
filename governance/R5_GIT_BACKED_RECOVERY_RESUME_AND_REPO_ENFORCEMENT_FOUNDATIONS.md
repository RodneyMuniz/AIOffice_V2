# R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations

## Milestone name
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

## Why this milestone exists now
R4 closed a bounded hardening milestone for internal control-kernel, workflow, and CI foundations. The first R4 closeout posture was not clean enough, and the corrective completion layer `R4-008` through `R4-011` was required before honest closure could be restated.

The next defensible step is still not UI expansion, not Standard or subproject runtime, and not broad orchestrator productization. The corrected Git-backed milestone-baseline slice is now complete again as `R5-002`, the bounded rollback / restore gate foundation slice is now complete as `R5-003`, the baton continuity and resume-authority foundation slice is now complete as `R5-004`, the bounded resume re-entry foundation slice is now complete as `R5-005`, the bounded CI/proof expansion slice is now complete as `R5-006`, and the bounded repo-enforcement plus proof / closeout structure slice is now complete as `R5-007`. Full R5 milestone closeout is now recorded explicitly in `governance/POST_R5_CLOSEOUT.md` and `governance/POST_R5_AUDIT_INDEX.md`.

## Objective
Strengthen the next bounded foundation layer after R4 by correcting and hardening Git-backed milestone baselines first, then implementing bounded rollback and restore gate foundations, baton continuity and resume authority foundations, bounded resume re-entry foundations, bounded CI/CD proof expansion, and bounded repo-enforcement plus proof / closeout structure without adding UI, without opening Standard runtime claims, without claiming automatic resume, and without claiming broader orchestration.

## Formal closeout status
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations` is complete and formally closed in repo truth.

The closeout authority is `governance/POST_R5_CLOSEOUT.md`. The audit mapping authority is `governance/POST_R5_AUDIT_INDEX.md`. The committed bounded proof-review basis is `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` at replay source head `1a97ff0cef9675c88030d3b618ef928093ee080c`.

This closeout remains bounded. It does not add rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration claims.

## Exit criteria
- repo truth records `R5-002` as complete again after corrected hardening through `R5-002A` through `R5-002G`
- the corrective task layer under `R5-002` is completed and remains bounded to the milestone-baseline slice only
- bounded rollback and restore gate foundations are implemented and focused-proofed without claiming rollback execution
- strengthened baton continuity and resume authority foundations are implemented and focused-proofed without claiming automatic resume or bounded resume re-entry execution
- bounded resume re-entry foundations are implemented and focused-proofed as operator-controlled preparation only
- the bounded CI/CD automation layer is implemented and remains aligned to the actual proof scope
- repo-enforcement expectations for clean worktrees, governed evidence, and bounded proof discipline are implemented and focused-proofed at the bounded level
- the expected R5 proof and closeout structure is implemented as bounded generator and enforcement surfaces
- full R5 milestone closeout is recorded explicitly in `governance/POST_R5_CLOSEOUT.md` and `governance/POST_R5_AUDIT_INDEX.md`

## In scope
- Git-backed milestone baseline capture foundations
- restore target and rollback gate authority model
- stronger baton continuity semantics for pause and resume re-entry
- bounded resume re-entry path with explicit operator control
- stronger CI/CD automation aligned to implemented bounded proof surfaces beyond the current R4-only replay foundation
- stronger repo enforcement direction around cleanliness, governed evidence, and bounded proof discipline
- bounded implementation structure for R5 proof review and later closeout recommendation

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
- Status: done
- Done when: batons carry explicit operator-controlled resume_authority and resume_context fields, invalid follow-up versus manual-review continuity states fail closed, focused baton proof passes, and the slice remains foundation-only without claiming resume execution or proof-suite expansion

### `R5-005` Define bounded resume re-entry path
- Status: done
- Done when: persisted Baton state can be validated into one bounded retry-entry Execution Bundle only when operator-controlled authority and restore-gate expectations are satisfied, invalid states fail closed, focused proof passes through `tests/test_resume_reentry.ps1`, and the slice does not claim unattended automatic resume or broader orchestration

### `R5-006` Define CI/CD automation expansion for bounded proof and recovery foundations
- Status: done
- Done when: the existing bounded proof runner and `.github/workflows/bounded-proof-suite.yml` replay the implemented R5 foundation subset, focused verification passes through `tests/test_bounded_proof_suite.ps1` plus `tests/test_bounded_proof_ci_foundation.ps1`, and the slice does not claim repo-enforcement or closeout automation

### `R5-007` Define repo enforcement and R5 proof / closeout structure
- Status: done
- Done when: repo-enforcement contracts and fail-closed evaluation exist for clean pre-replay worktrees, governed proof-output roots, replay-summary and replay-command evidence, exact proof-id selection scope, raw replay-log presence, and replay-source-head consistency; bounded R5 proof-review generation exists; focused proof passes; and full R5 milestone closeout remains separate from this task and is recorded later through `governance/POST_R5_CLOSEOUT.md`

## Milestone notes
- `R5-001` opened R5 in repo truth as structure only.
- `R5-002` is complete again after the bounded corrective layer `R5-002A` through `R5-002G` closed from a clean worktree with the focused milestone-baseline suite.
- The current `R5-002` candidate surface remains limited to milestone-baseline contracts, `tools/MilestoneBaseline.psm1`, and `tests/test_milestone_baseline.ps1`.
- `R5-002A` through `R5-002G` are the completed corrective hardening layer that re-closed `R5-002` honestly.
- `R5-003` is complete as a bounded restore-gate foundation slice through `contracts/restore_gate/`, `tools/RestoreGate.psm1`, and `tests/test_restore_gate.ps1`.
- `R5-004` is complete as a bounded baton continuity foundation slice through `contracts/work_artifacts/baton.contract.json`, `tools/BatonPersistence.psm1`, `tools/WorkArtifactValidation.psm1`, `tests/test_baton_persistence.ps1`, and the updated baton fixtures.
- `R5-005` is complete as a bounded resume re-entry slice through `contracts/resume_reentry/`, `tools/ResumeReentry.psm1`, and `tests/test_resume_reentry.ps1`.
- `R5-006` is complete as a bounded proof and CI expansion slice through `tools/BoundedProofSuite.psm1`, `tests/test_bounded_proof_suite.ps1`, and the existing `.github/workflows/bounded-proof-suite.yml` entrypoint.
- `R5-007` is complete as a bounded repo-enforcement and proof / closeout structure slice through `contracts/repo_enforcement/`, `tools/RepoEnforcement.psm1`, `tools/new_r5_recovery_resume_proof_review.ps1`, `tests/test_repo_enforcement.ps1`, and `tests/test_r5_recovery_resume_proof_review.ps1`.
- `R5-002` through `R5-007` do not claim rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration. Formal milestone closeout is now recorded separately in `governance/POST_R5_CLOSEOUT.md` and does not widen those boundaries.
- Focused milestone-baseline proof depth now explicitly covers missing validator module or command refusal plus valid-but-inconsistent stored `head_commit` or `tree_id` refusal through `tests/test_milestone_baseline.ps1`.
- R4 remains the prior closed milestone, and its historical closeout authority remains in `governance/POST_R4_CLOSEOUT.md` and `governance/POST_R4_AUDIT_INDEX.md`.
- The final narrative bridge artifact for the R4 to R5 transition is `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`.
- The `governance/Product Vision V1 baseline/` folder remains reference-only direction material and is not milestone evidence.
