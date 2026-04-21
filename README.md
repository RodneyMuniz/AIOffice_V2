# AIOffice

AIOffice is being rebuilt as an admin-only, self-build-first product for governed software production.

Bounded `R4 Control-Kernel Hardening and CI Foundations` is complete and closed in repo truth, including the corrective completion layer `R4-008` through `R4-011`. `R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations` is the active milestone in repo truth, and `R5-002` through `R5-007` are now implemented as bounded internal foundations. R5 milestone closure is not yet claimed.

The current repo is a clean reset. Its first acceptable proof boundary is supervised workflow through `architect` plus bounded `apply/promotion` control. That narrow proof boundary is now formally claimable from direct repo evidence, and the closeout is recorded in `governance/R2_FIRST_BOUNDED_V1_PROOF_CLOSEOUT.md`. Git and persisted state remain the intended truth substrates.

## Start Here
- `governance/VISION.md`
- `governance/PROJECT.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/DECISION_LOG.md`
- `governance/ACTIVE_STATE.md`
- `governance/R5_GIT_BACKED_RECOVERY_RESUME_AND_REPO_ENFORCEMENT_FOUNDATIONS.md`
- `governance/R5_PROOF_AND_CLOSEOUT_PLAN.md`
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

This replays the focused R2 through R5 bounded tests through one fail-closed entrypoint. It does not broaden the proved boundary into UI, Standard runtime, rollback execution, unattended automatic resume, or broader orchestration claims.

The focused R5 proof-review entrypoint is:
- `powershell -ExecutionPolicy Bypass -File tools\new_r5_recovery_resume_proof_review.ps1`

This replays the bounded R5 baseline, restore-gate, baton, resume, and repo-enforcement foundations plus their direct contract dependencies. The repo-enforcement clean-worktree allow-path is a closeout discipline gate; it does not imply that every in-progress local workspace already satisfies closure conditions.

The same bounded proof entrypoint remains wired into `.github/workflows/bounded-proof-suite.yml` for `push` and `pull_request` on `main`, and now covers the expanded bounded suite definitions. This CI foundation strengthens proof discipline only; it does not by itself prove broader productization.

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
