# Post-R4 Audit Index

## Purpose
This index maps the bounded R4 state to the exact governing docs, implementation modules, focused tests, proof entrypoints, proof-review artifacts, milestone commits, and exclusions that an independent audit should preserve. It is an audit-readiness surface only and not a next-phase planning record.

The initial `R4-005` through `R4-007` delivery required the corrective completion layer `R4-008` through `R4-011` before honest closure could be restated. Those new tasks are recorded explicitly here rather than being merged silently into the earlier task history.

## Milestone-To-Commit Mapping
- `R4-001` repo-truth open and backlog activation: `c10b7dd1f4b4ce6dce043e237af7344c5146ef44`
- `R4-002` chronology and lifecycle hardening: `6afc9151d20960462dc0d7d45cf19e355968705d`
- `R4-003` explicit pipeline and scope hardening: `08c23446cb1c4c3dbcc4780f4e28ba3ff72fa297`
- `R4-004` bounded QA-loop and handoff hardening: `0b98f847514847f55f66a67fe4b0d4b5e28ad5e2`
- `R4-005` deterministic repo-local proof runner: `0441698078cf1dd50e4c5f2dd905867c3ab83b5d`
- `R4-006` source-controlled CI proof foundation: `387a58693fc1a424b9a9e782f343b4080547492c`
- `R4-007` replayable proof package and closeout: `bbdd5a8ec548e9707275e8438fa6fb4b91917ed0`
- `R4-008` repair bounded proof runner clean-checkout behavior: `2d8b01d71b9478cc31e0863c9b8185cb3e62b15a`
- `R4-009` re-stabilize CI foundation on the real proof path: pending corrective completion
- `R4-010` regenerate proof package and evidence inventory cleanly: pending corrective completion
- `R4-011` reconcile post-R4 repo truth for honest closure readiness: pending corrective completion

## Governing Docs Supporting R4 Truth
- `README.md`
- `governance/VISION.md`
- `governance/V1_PRD.md`
- `governance/OPERATING_MODEL.md`
- `governance/ACTIVE_STATE.md`
- `execution/KANBAN.md`
- `governance/R4_CONTROL_KERNEL_HARDENING_AND_CI_FOUNDATIONS.md`
- `governance/POST_R4_CLOSEOUT.md`

## Implementation Modules By Bounded Capability
- chronology and lifecycle hardening:
  - `tools/PacketRecordStorage.psm1`
- planning-record pipeline and scope hardening:
  - `contracts/planning_records/foundation.contract.json`
  - `contracts/planning_records/planning_record.contract.json`
  - `tools/PlanningRecordStorage.psm1`
- governed work artifact pipeline, scope, retry, and handoff hardening:
  - `contracts/work_artifacts/foundation.contract.json`
  - `contracts/work_artifacts/request_brief.contract.json`
  - `contracts/work_artifacts/task_packet.contract.json`
  - `contracts/work_artifacts/execution_bundle.contract.json`
  - `contracts/work_artifacts/qa_report.contract.json`
  - `contracts/work_artifacts/external_audit_pack.contract.json`
  - `contracts/work_artifacts/baton.contract.json`
  - `tools/WorkArtifactValidation.psm1`
  - `tools/ExecutionBundleQaGate.psm1`
  - `tools/BatonPersistence.psm1`
  - `tools/R3PlanningReplayProof.psm1`
- bounded supervised-flow proof hygiene:
  - `tools/SupervisedAdminHarness.psm1`
- deterministic bounded proof running:
  - `tools/BoundedProofSuite.psm1`
  - `tools/run_bounded_proof_suite.ps1`
- bounded proof-review generation:
  - `tools/new_r4_hardening_proof_review.ps1`
- source-controlled CI proof foundation:
  - `.github/workflows/bounded-proof-suite.yml`

## Focused Tests By Bounded Capability
- R2 bounded surface:
  - `tests/test_stage_artifact_contracts.ps1`
  - `tests/test_packet_record_storage.ps1`
  - `tests/test_apply_promotion_gate.ps1`
  - `tests/test_apply_promotion_action.ps1`
  - `tests/test_supervised_admin_flow.ps1`
- R3 and R4 bounded internal foundation:
  - `tests/test_governed_work_object_contracts.ps1`
  - `tests/test_planning_record_storage.ps1`
  - `tests/test_work_artifact_contracts.ps1`
  - `tests/test_request_brief_task_packet_flow.ps1`
  - `tests/test_execution_bundle_qa_gate.ps1`
  - `tests/test_baton_persistence.ps1`
  - `tests/test_r3_planning_replay.ps1`
- R4 proof-discipline and proof-package foundation:
  - `tests/test_bounded_proof_suite.ps1`
  - `tests/test_bounded_proof_ci_foundation.ps1`
  - `tests/test_r4_hardening_proof_review.ps1`

## Committed Replay Package Contents
The committed replay package currently consists of:
- `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/REPLAY_SUMMARY.md`
- `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/bounded-proof-suite-summary.md`
- `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/bounded-proof-suite-summary.json`
- `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/meta/`
- `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/`

The committed replay package does not include self-replay logs for `tests/test_bounded_proof_suite.ps1` or `tests/test_r4_hardening_proof_review.ps1`. Those remain support regression tests outside the replay package.

## Replay Proof Surface
The direct replay proof surface is:
- proof-review command: `powershell -ExecutionPolicy Bypass -File tools\new_r4_hardening_proof_review.ps1 -OutputRoot state\proof_reviews\r4_control_kernel_hardening_and_ci_foundations`
- deterministic proof runner command: `powershell -ExecutionPolicy Bypass -File tools\run_bounded_proof_suite.ps1`
- committed proof-review folder: `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/`
- proof-review summary: `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/REPLAY_SUMMARY.md`
- proof-runner summary: `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/bounded-proof-suite-summary.json`
- per-test raw logs: `state/proof_reviews/r4_control_kernel_hardening_and_ci_foundations/tests/`

## Limits And Exclusions The Auditor Must Preserve
- Preserve the bounded claim only. R4 strengthens control-kernel, workflow, and CI foundations; it does not prove broad product completion.
- Preserve the no-UI boundary. R4 does not prove user-facing or operator-facing productization.
- Preserve the no-Standard-runtime boundary. R4 does not prove Standard or subproject pipeline runtime.
- Preserve the no-auto-resume boundary. R4 does not prove automatic resume behavior.
- Preserve the no-recovery boundary. R4 does not prove rollback or broader recovery productization.
- Preserve the no-broad-orchestration boundary. R4 does not prove orchestration beyond the bounded chain.
- Preserve the no-next-milestone boundary. `governance/Product Vision V1 baseline/` remains reference-only direction material, and no post-R4 implementation milestone is open yet in repo truth.
