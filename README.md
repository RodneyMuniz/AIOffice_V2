# AIOffice

AIOffice is being rebuilt as an admin-only, self-build-first product for governed software production.

Bounded `R4 Control-Kernel Hardening and CI Foundations` is complete and closed in repo truth, including the corrective completion layer `R4-008` through `R4-011`. `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations` is now complete and formally closed in repo truth: `R5-002 Git-backed milestone baseline model` is complete again after corrected hardening through `R5-002A` through `R5-002G`, `R5-003 bounded rollback / restore gate foundations` is complete at the bounded foundation level, `R5-004 strengthened baton continuity and resume authority model` is complete at the bounded foundation level, `R5-005 bounded resume re-entry path` is complete at the bounded foundation level, `R5-006 CI/CD automation expansion for bounded proof and recovery foundations` is complete at the bounded foundation level, and `R5-007 repo enforcement and R5 proof / closeout structure` is complete at the bounded foundation level. The formal closeout authority is `governance/POST_R5_CLOSEOUT.md`, the audit mapping authority is `governance/POST_R5_AUDIT_INDEX.md`, and the committed bounded proof-review basis is `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` at replay source head `1a97ff0cef9675c88030d3b618ef928093ee080c`.

`R6 Supervised Milestone Autocycle Pilot` remains the immediately prior closed milestone in repo truth. `R6-001`, `R6-P1`, `R6-P2`, and `R6-002` through `R6-009` are complete on the original replay-closeout bar. The closeout authority is `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, and the committed proof-review basis is `state/proof_reviews/r6_supervised_milestone_autocycle_pilot/` at replay source head `9069b29ace87d787515b4c4fb5e9c94e6fa40743`. That package commits raw replay logs, summary artifacts, exact proof selection scope, replay-source metadata, authoritative artifact refs, one replay proof, one closeout packet, one closeout review, and explicit non-claims matched to the exact replay scope from structured intake through advisory-only operator decision. The operator decision remains advisory only and unexecuted in this closeout, and the closed R6 boundary still does not widen the repo into broad autonomy, rollback execution, unattended automatic resume, UI, Standard runtime, multi-repo behavior, executor swarms, or broader orchestration.

`R7 Fault-Managed Continuity and Rollback Drill` is now the most recently closed milestone in repo truth. `R7-001` through `R7-009` are complete through the committed fault, continuity, supervised resume, continuity-ledger, governed rollback-plan, safe rollback-drill, advisory review, and proof-review surfaces under `contracts/fault_management/`, `contracts/milestone_continuity/`, `tools/FaultManagement.psm1`, `tools/MilestoneContinuity.psm1`, `tools/MilestoneContinuityResume.psm1`, `tools/MilestoneContinuityLedger.psm1`, `tools/MilestoneRollbackPlan.psm1`, `tools/MilestoneRollbackDrill.psm1`, `tools/MilestoneContinuityReview.psm1`, `tools/MilestoneContinuityProofReview.psm1`, `tools/new_r7_fault_managed_continuity_proof_review.ps1`, `tools/validate_milestone_continuity_proof_review.ps1`, the valid R7 fixtures under `state/fixtures/valid/fault_management/` and `state/fixtures/valid/milestone_continuity/`, and focused proof through `tests/test_fault_management_event.ps1`, `tests/test_milestone_continuity_artifacts.ps1`, `tests/test_milestone_continuity_resume_from_fault.ps1`, `tests/test_milestone_continuity_ledger.ps1`, `tests/test_milestone_rollback_plan.ps1`, `tests/test_milestone_rollback_drill.ps1`, `tests/test_milestone_continuity_review.ps1`, and `tests/test_r7_fault_managed_continuity_proof_review.ps1`. The closeout authority remains `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, decision authority is `D-0050`, and the committed proof-review basis is `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/` at replay source head `fce96fb35c3d1ff8d2676d470ccfe81ae3cb6905` and replay source tree `3b55d697b6206a62967800cd78bc4f3b39b99858`. That package commits exact replay commands, raw replay logs, summary artifacts, exact proof selection scope, replay-source metadata, authoritative artifact refs for `R7-002` through `R7-008`, one closeout packet, and explicit non-claims for one replayable interrupted-and-resumed supervised continuity path plus one safe disposable-worktree rollback drill packet only. It does not prove unattended automatic resume, destructive primary-tree rollback, broader rollback productization, UI, Standard runtime, multi-repo behavior, swarms, or broader orchestration.

`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` is now the active milestone in repo truth as a bounded QA and proof trust milestone. `R8-001` is complete as the milestone-open and registration slice under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, `R8-002` is complete through the first durable QA proof packet contract, validator, fixture, and focused test surfaces under `contracts/qa_proof/`, `tools/QaProofPacket.psm1`, `tools/validate_qa_proof_packet.ps1`, `state/fixtures/valid/qa_proof/`, and `tests/test_qa_proof_packet.ps1`, `R8-003` is complete through the remote-head verification contract, module, CLI entrypoint, and focused tests under `contracts/qa_proof/remote_head_verification.contract.json`, `tools/RemoteHeadVerification.psm1`, `tools/verify_remote_branch_head.ps1`, and `tests/test_remote_head_verification.ps1`, `R8-004` is complete through the post-push verification contract, module, CLI entrypoint, and satisfaction check under `contracts/qa_proof/post_push_verification.contract.json`, `tools/PostPushVerification.psm1`, `tools/verify_post_push_remote_head.ps1`, and `tests/test_post_push_verification.ps1`, `R8-005` is complete through the disposable clean-checkout QA runner, CLI entrypoint, and focused tests under `tools/CleanCheckoutQaRunner.psm1`, `tools/invoke_clean_checkout_qa.ps1`, and `tests/test_clean_checkout_qa_runner.ps1`, and `R8-006` is complete through stricter claimed-command log coverage hardening under `contracts/qa_proof/`, `tools/QaProofPacket.psm1`, and `tests/test_qa_proof_packet.ps1`; `R8-007` through `R8-009` remain planned only. Completion claims now require an explicit post-push verification artifact, the exact final remote SHA, a validator-backed QA packet from a disposable checkout pinned to that remote SHA, and fail-closed claimed-command coverage for completion-facing replay commands, not narration alone. R8 exists to harden remote-head verification, post-push verification, clean-checkout QA replay, complete raw command logging, QA proof packets, CI or external proof references, and status-doc gating before future milestone completion can be trusted. The operator-facing bridge artifact for the R7-to-R8 transition is `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md`. It is a narrative operator report artifact only, not milestone proof by itself.

The current repo is a clean reset. Its first acceptable proof boundary is supervised workflow through `architect` plus bounded `apply/promotion` control. That narrow proof boundary is now formally claimable from direct repo evidence, and the closeout is recorded in `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`. Git and persisted state remain the intended truth substrates.

## Start Here
- `governance/VISION.md`
- `governance/PROJECT.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/DECISION_LOG.md`
- `governance/ACTIVE_STATE.md`
- `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`
- `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`
- `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- `governance/POST_R5_CLOSEOUT.md`
- `governance/POST_R5_AUDIT_INDEX.md`
- `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`
- `governance/reports/AIOffice_V2_R5_Audit_and_R6_Planning_Report_v2.md`
- `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md`
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
