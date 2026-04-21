# AIOffice

AIOffice is being rebuilt as an admin-only, self-build-first product for governed software production.

Bounded `R4 Control-Kernel Hardening and CI Foundations` is complete and closed in repo truth, including the corrective completion layer `R4-008` through `R4-011`. `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations` is now the active milestone in repo truth, `R5-002 Git-backed milestone baseline model` is complete again after corrected hardening through `R5-002A` through `R5-002G`, and `R5-003 bounded rollback / restore gate foundations` is complete at the bounded foundation level. `R5-004` through `R5-007` remain planned only. These completed R5 slices stay admin-only and foundation-focused, and they do not open rollback execution, resume behavior, repo-enforcement behavior, proof-suite expansion, UI, Standard runtime, or broader orchestration claims.

The current repo is a clean reset. Its first acceptable proof boundary is supervised workflow through `architect` plus bounded `apply/promotion` control. That narrow proof boundary is now formally claimable from direct repo evidence, and the closeout is recorded in `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`. Git and persisted state remain the intended truth substrates.

## Start Here
- `governance/VISION.md`
- `governance/PROJECT.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/DECISION_LOG.md`
- `governance/ACTIVE_STATE.md`
- `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`
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

This replays the focused R2, R3, and R4 bounded tests through one fail-closed entrypoint. It does not broaden the proved boundary into UI, Standard runtime, rollback, automatic resume, or broader orchestration claims.

`R5-002` is currently backed by one focused milestone-baseline test entrypoint:
- `powershell -ExecutionPolicy Bypass -File tests\test_milestone_baseline.ps1`

The corrected `R5-002` slice now proves a bounded Git-backed milestone-baseline substrate only: repository congruence enforcement, persisted Git identity hardening, focused test honesty improvements, explicit path and save semantics, stronger evidence and anchor reconciliation, and explicit runtime and dependency fail-closed handling.

The current bounded proof surface still remains the R2 through R4 slice only until later R5 proof expansion is actually implemented and proved. `R5-002` does not claim proof-suite expansion.

`R5-003` is currently backed by one focused restore-gate test entrypoint:
- `powershell -ExecutionPolicy Bypass -File tests\test_restore_gate.ps1`

The bounded `R5-003` slice now proves explicit restore-target validation, explicit operator approval, repository-binding checks, and clean-worktree or attached-head refusal behavior only. It does not execute rollback, and it does not broaden the current bounded proof suite beyond the R2 through R4 runner.

The same bounded proof entrypoint is now wired into `.github/workflows/bounded-proof-suite.yml` for `push` and `pull_request` on `main`. This CI foundation strengthens proof discipline only; it does not by itself prove broader productization.

The committed bounded R4 proof package lives under `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/`.

The initial `R4-005` through `R4-007` delivery required explicit corrective completion work before honest closure could be restated. That corrective layer is now part of the completed bounded R4 baseline and remained limited to proof-runner repair, CI-path re-verification, replay-package refresh, and repo-truth reconciliation only.

The final narrative bridge artifact for the R4-to-R5 transition is `governance/reports/AIOffice_V2_R4_Audit_and_R5_Planning_Report_v1.md`. It is a report artifact only, not milestone proof by itself.

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
