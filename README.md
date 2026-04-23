# AIOffice

AIOffice is being rebuilt as an admin-only, self-build-first product for governed software production.

Bounded `R4 Control-Kernel Hardening and CI Foundations` is complete and closed in repo truth, including the corrective completion layer `R4-008` through `R4-011`. `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations` is now complete and formally closed in repo truth: `R5-002 Git-backed milestone baseline model` is complete again after corrected hardening through `R5-002A` through `R5-002G`, `R5-003 bounded rollback / restore gate foundations` is complete at the bounded foundation level, `R5-004 strengthened baton continuity and resume authority model` is complete at the bounded foundation level, `R5-005 bounded resume re-entry path` is complete at the bounded foundation level, `R5-006 CI/CD automation expansion for bounded proof and recovery foundations` is complete at the bounded foundation level, and `R5-007 repo enforcement and R5 proof / closeout structure` is complete at the bounded foundation level. The formal closeout authority is `governance/POST_R5_CLOSEOUT.md`, the audit mapping authority is `governance/POST_R5_AUDIT_INDEX.md`, and the committed bounded proof-review basis is `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` at replay source head `1a97ff0cef9675c88030d3b618ef928093ee080c`.

`R6 Supervised Milestone Autocycle Pilot` remains the most recently closed milestone in repo truth. `R6-001`, `R6-P1`, `R6-P2`, and `R6-002` through `R6-009` are complete on the original replay-closeout bar. The closeout authority is `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, and the committed proof-review basis is `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/` at replay source head `9069b29ace87d787515b4c4fb5e9c94e6fa40743`. That package commits raw replay logs, summary artifacts, exact proof selection scope, replay-source metadata, authoritative artifact refs, one replay proof, one closeout packet, one closeout review, and explicit non-claims matched to the exact replay scope from structured intake through advisory-only operator decision. The operator decision remains advisory only and unexecuted in this closeout, and the closed R6 boundary still does not widen the repo into broad autonomy, rollback execution, unattended automatic resume, UI, Standard runtime, multi-repo behavior, executor swarms, or broader orchestration.

`R7 Fault-Managed Continuity and Rollback Drill` is the active milestone in repo truth. `R7-001` opened the bounded milestone boundary, `R7-002 Add first-class fault / interruption event contracts` is complete through `contracts/fault_management/foundation.contract.json`, `contracts/fault_management/fault_event.contract.json`, `tools/FaultManagement.psm1`, `tools/validate_fault_event.ps1`, `state/fixtures/valid/fault_management/fault_event.valid.json`, and `tests/test_fault_management_event.ps1`, `R7-003 Emit governed continuity checkpoints and handoff packets` is complete through `contracts/milestone_continuity/foundation.contract.json`, `contracts/milestone_continuity/continuity_checkpoint.contract.json`, `contracts/milestone_continuity/continuity_handoff_packet.contract.json`, `tools/MilestoneContinuity.psm1`, `tools/validate_milestone_continuity_artifact.ps1`, `state/fixtures/valid/milestone_continuity/continuity_checkpoint.valid.json`, `state/fixtures/valid/milestone_continuity/continuity_handoff_packet.valid.json`, and `tests/test_milestone_continuity_artifacts.ps1`, `R7-004 Add supervised resume-from-fault flow` is complete through `contracts/milestone_continuity/resume_from_fault_request.contract.json`, `contracts/milestone_continuity/resume_from_fault_result.contract.json`, `tools/MilestoneContinuityResume.psm1`, `tools/prepare_supervised_resume_from_fault.ps1`, `state/fixtures/valid/milestone_continuity/resume_from_fault_request.valid.json`, `state/fixtures/valid/milestone_continuity/resume_from_fault_result.valid.json`, and `tests/test_milestone_continuity_resume_from_fault.ps1`, `R7-005 Add continuity ledger and multi-segment milestone stitching` is complete through `contracts/milestone_continuity/continuity_ledger.contract.json`, `tools/MilestoneContinuityLedger.psm1`, `tools/validate_milestone_continuity_ledger.ps1`, `state/fixtures/valid/milestone_continuity/continuity_ledger.valid.json`, and `tests/test_milestone_continuity_ledger.ps1`, and `R7-006 Add governed rollback plan artifact` is complete through `contracts/milestone_continuity/rollback_plan_request.contract.json`, `contracts/milestone_continuity/rollback_plan.contract.json`, `tools/MilestoneRollbackPlan.psm1`, `tools/prepare_milestone_rollback_plan.ps1`, `tools/validate_milestone_rollback_plan.ps1`, `state/fixtures/valid/milestone_continuity/rollback_plan_request.valid.json`, and `tests/test_milestone_rollback_plan.ps1`. The accepted `R7-006` slice proves one governed rollback plan artifact that reuses the accepted `R7-005` continuity ledger plus accepted R6 baseline-binding and milestone-baseline truth, records target scope, operator approval requirement, environment constraints, refusal conditions, and target repository or branch or head or tree context durably, and fails closed on missing baseline refs, invalid target or environment scope, repository or target git-context contradiction, missing operator approval requirement, execution-implying state, continuity-segment identity mismatch, and malformed rollback-plan state. The next gated step is `R7-007 Add safe rollback drill harness`. R7 still does not yet prove rollback drill execution, unattended automatic resume, destructive primary-tree rollback, UI, Standard runtime, multi-repo behavior, swarms, or broader orchestration.

The current repo is a clean reset. Its first acceptable proof boundary is supervised workflow through `architect` plus bounded `apply/promotion` control. That narrow proof boundary is now formally claimable from direct repo evidence, and the closeout is recorded in `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`. Git and persisted state remain the intended truth substrates.

## Start Here
- `governance/VISION.md`
- `governance/PROJECT.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/DECISION_LOG.md`
- `governance/ACTIVE_STATE.md`
- `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`
- `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`
- `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- `governance/POST_R5_CLOSEOUT.md`
- `governance/POST_R5_AUDIT_INDEX.md`
- `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`
- `governance/reports/AIOffice_V2_R5_Audit_and_R6_Planning_Report_v2.md`
- `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`
- `governance/R3_GOVERNED_WORK_OBJECTS_AND_DOUBLE_AUDIT_FOUNDATIONS.md`
- `execution/KANBAN.md`
- `execution/PROJECT_BRAIN.md`

## Current V1 Boundary
Current V1 is intentionally narrow:
- admin-only
- self-build first
- supervised
- docs-first or API-first is acceptable
- no broad UI requirement

## Bounded Proof Command
Replay the currently claimed bounded suite locally with:
- `powershell -ExecutionPolicy Bypass -File tools\run_bounded_proof_suite.ps1`

This replays the focused R2, R3, and R4 bounded tests plus the implemented R5 foundation tests through one fail-closed entrypoint. It does not broaden the proved boundary into UI, Standard runtime, rollback execution, unattended automatic resume, repo-enforcement or closeout behavior, or broader orchestration claims.

`R5-002` is currently backed by one focused milestone-baseline test entrypoint and its bounded proof-suite replay id:
- `powershell -ExecutionPolicy Bypass -File tests\test_milestone_baseline.ps1`
- `r5-milestone-baseline`

The corrected `R5-002` slice now proves a bounded Git-backed milestone-baseline substrate only: repository congruence enforcement, persisted Git identity hardening, focused test honesty improvements, explicit path and save semantics, stronger evidence and anchor reconciliation, and explicit runtime and dependency fail-closed handling.

The corrected `R5-002` slice now participates in the bounded proof suite under `r5-milestone-baseline`. It still does not claim restore execution, resume behavior, repo-enforcement, or broader orchestration.

`R5-003` is currently backed by one focused restore-gate test entrypoint and its bounded proof-suite replay id:
- `powershell -ExecutionPolicy Bypass -File tests\test_restore_gate.ps1`
- `r5-restore-gate`

The bounded `R5-003` slice now proves explicit restore-target validation, explicit operator approval, repository-binding checks, and clean-worktree or attached-head refusal behavior only. It does not execute rollback.

`R5-004` is currently backed by focused baton-continuity entrypoints and its bounded proof-suite replay id:
- `powershell -ExecutionPolicy Bypass -File tests\test_baton_persistence.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_work_artifact_contracts.ps1`
- `r5-baton-continuity`

The bounded `R5-004` slice now proves explicit operator-controlled baton resume authority, bounded re-entry context capture, and fail-closed follow-up versus manual-review continuity rules only. It does not execute resume by itself.

`R5-005` is currently backed by one focused resume re-entry test entrypoint and its bounded proof-suite replay id:
- `powershell -ExecutionPolicy Bypass -File tests\test_resume_reentry.ps1`
- `r5-resume-reentry`

The bounded `R5-005` slice now proves operator-controlled resume re-entry preparation from persisted Baton state back into governed retry work, explicit restore-gate-required refusal, invalid-state refusal, and one prepared retry-entry Execution Bundle only. It does not execute automatic resume, rollback, or broader orchestration.

`R5-006` is currently backed by the bounded proof-runner verification entrypoints:
- `powershell -ExecutionPolicy Bypass -File tests\test_bounded_proof_ci_foundation.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_bounded_proof_suite.ps1`

The same bounded proof entrypoint remains wired into `.github/workflows/bounded-proof-suite.yml` for `push` and `pull_request` on `main`. `R5-006` expands that existing CI path only by broadening `tools/run_bounded_proof_suite.ps1` and `tools/BoundedProofSuite.psm1` to replay the implemented R5 foundation ids `r5-milestone-baseline`, `r5-restore-gate`, `r5-baton-continuity`, and `r5-resume-reentry`. This CI expansion strengthens bounded proof discipline only; it does not by itself add repo-enforcement or closeout automation, and it does not prove broader productization.

`R5-007` is currently backed by the bounded proof-review and repo-enforcement entrypoints:
- `powershell -ExecutionPolicy Bypass -File tools\new_r5_recovery_resume_proof_review.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_repo_enforcement.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_r5_recovery_resume_proof_review.ps1`

This slice adds fail-closed repo-enforcement contracts under `contracts/repo_enforcement/`, bounded repo-enforcement evaluation in `tools/RepoEnforcement.psm1`, and an R5 proof-review generator in `tools/new_r5_recovery_resume_proof_review.ps1`. The proved boundary is clean-worktree pre-replay discipline, governed in-repo proof output under `state/proof_reviews/`, required replay summary and replayed command evidence, exact proof-id selection scope, raw replay-log presence, replay-source-head consistency, and explicit refusal when those checks fail. This bounded structure is one named input to the formal R5 closeout recorded in `governance/POST_R5_CLOSEOUT.md`. It does not prove rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration.

The committed bounded R4 proof package lives under `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/`.
The committed bounded R5 proof-review package lives under `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/`.

The initial `R4-005` through `R4-007` delivery required explicit corrective completion work before honest closure could be restated. That corrective layer is now part of the completed bounded R4 baseline and remained limited to proof-runner repair, CI-path re-verification, replay-package refresh, and repo-truth reconciliation only.

The final narrative bridge artifact for the R4-to-R5 transition is `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`. It is a report artifact only, not milestone proof by itself.

The operator-facing bridge artifact for the R5-to-R6 transition is `governance/reports/AIOffice_V2_R5_Audit_and_R6_Planning_Report_v2.md`. It is a narrative report artifact only, not milestone proof by itself.

The `governance/Product Vision V1 baseline/` folder remains reference-only direction material and is not milestone evidence.

## Not Required In Current V1
- broad UI or control-room proof
- Standard or subproject pipeline work
- later-lane live workflow proof beyond `architect`
- legacy task or milestone migration

## Repo Layout
- `governance/`
  Constitutional and operating truth.
- `execution/`
  Fresh reset backlog and working primer.
