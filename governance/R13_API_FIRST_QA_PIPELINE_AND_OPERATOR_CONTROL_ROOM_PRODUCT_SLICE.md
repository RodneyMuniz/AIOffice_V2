# R13 API-First QA Pipeline and Operator Control-Room Product Slice

`R13 API-First QA Pipeline and Operator Control-Room Product Slice` is now active in repo truth through `R13-010` only.

## Purpose

R13 opens as an explicitly approved successor milestone after the approved R12/R13 planning report was committed to repo truth. The milestone target is a meaningful QA and operator workflow vertical slice that reduces manual copy/paste dependency and starts moving execution authority away from Codex chat sessions into repo/API/custom-runner surfaces.

R13 is not a governance-only milestone in intent. R13 must produce practical implementation evidence for a real QA cycle, API/custom-runner handoff, current operator control-room usefulness, and a small skill invocation foundation. `R13-001` only opens the branch, freezes hard value gates, records the task plan, and updates status surfaces. `R13-002` only defines the ideal QA lifecycle contract and validator foundation. `R13-003` only implements the source-mapped issue detector v2 slice. `R13-004` only implements the QA fix queue and fix-plan generator v2 slice. `R13-005` only implements the bounded fix execution packet model. `R13-006` runs one controlled seeded QA failure-to-fix cycle in a demo workspace only. `R13-007` adds a local API-shaped/custom-runner foundation only. `R13-008` adds a bounded skill registry and two local skill invocations only. `R13-009` adds current cycle-aware control-room JSON/Markdown/refresh result only. `R13-010` adds a human-readable operator demo artifact only. None of these tasks delivers any R13 hard value gate.

## Accepted Starting State

- Repository: `RodneyMuniz/AIOffice_V2`
- R13 branch: `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`
- Source branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Report-committed R12 head: `9ad475faa87746cb3d6ef074545e4b703e77e786`
- R12/R13 planning report commit: `9ad475faa87746cb3d6ef074545e4b703e77e786`
- R12/R13 planning report: `governance/reports/AIOffice_V2_R12_Audit_and_R13_Planning_Report_v1.md`
- R12 candidate closeout commit: `4873068faef918608f9f4d74ecbf6ee779ba2ad4`
- R12 candidate closeout tree: `bb2f95efdaa194f2cae03a57ed29461c32eb5df8`
- R12 closeout head before report commit: `9f689a442f0bde25b802d891aed4b36388b7338d`

The R12/R13 planning report is a planning authority for R13 direction only. It is not product proof by itself, does not reopen R12, and does not widen any R12 closeout claim. R12 remains closed narrowly.

## Strict R13 Boundary

R13 is bounded to one release branch and one milestone:

- open R13 from the report-committed R12 branch head;
- freeze hard value gates and non-claims;
- define the R13 task plan from `R13-001` through `R13-018`;
- keep `R13-001` as opening/status work only;
- keep `R13-002` as contract/foundation work only;
- keep `R13-003` as source-mapped issue detector v2 only;
- keep `R13-004` as QA fix queue and fix-plan generator v2 only;
- keep `R13-005` as bounded fix execution packet model only;
- keep `R13-006` as one controlled demo-workspace QA failure-to-fix cycle only;
- keep `R13-007` as a local API-shaped/custom-runner foundation only;
- keep `R13-008` as a bounded skill registry and local skill invocation evidence slice only;
- keep `R13-009` as a current cycle-aware control-room JSON/Markdown/refresh result slice only;
- keep `R13-010` as a human-readable operator demo artifact slice only;
- require later tasks to produce committed machine-readable evidence before any value gate can be marked delivered;
- avoid product/runtime/autonomy/UI overclaim;
- do not open R14 or any successor milestone.

## R13 Hard Value Gates

All R13 gates are planned or partial and not yet fully delivered at `R13-010`.

1. Meaningful QA loop gate: planned, not yet delivered.
2. API/custom-runner bypass gate: foundation added, not fully delivered.
3. Current operator control-room gate: partially evidenced by `R13-009`, not fully delivered as a hard gate.
4. Skill invocation evidence gate: partially evidenced by `R13-008`, not fully delivered as a hard gate.
5. Operator demo gate: partially evidenced by `R13-010`, not fully delivered as a hard gate.

No gate can pass from narrative, schema-only validation, stale artifacts, local-only evidence claimed as external proof, executor self-certification, or chat-memory continuity.

## R13 Task List

### `R13-001` Open R13 and freeze hard value gates
- Status: done
- Boundary: opens R13 on `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`, records the report-committed R12 source head, freezes hard gates, preserves non-claims, updates status surfaces, and does not claim any gate delivered.

### `R13-002` Define ideal QA lifecycle contract
- Status: done
- Boundary: defines the canonical QA lifecycle contract from detect to signoff through `contracts/actionable_qa/r13_qa_lifecycle.contract.json`, `tools/R13QaLifecycle.psm1`, `tools/validate_r13_qa_lifecycle.ps1`, valid initialized fixture `state/fixtures/valid/actionable_qa/r13_qa_lifecycle.valid.json`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_lifecycle/`, and `tests/test_r13_qa_lifecycle.ps1`. This is a contract/foundation task only; it does not implement the detector, fix queue, bounded fix execution, rerun, comparison, external replay, control-room demo, or final signoff.

### `R13-003` Build actionable QA issue detector v2
- Status: done
- Boundary: implements the source-mapped issue detector v2 only through `contracts/actionable_qa/r13_qa_issue_detection_report.contract.json`, `tools/R13QaIssueDetector.psm1`, `tools/invoke_r13_qa_issue_detector.ps1`, `tools/validate_r13_qa_issue_detection_report.ps1`, valid detector report fixtures under `state/fixtures/valid/actionable_qa/`, invalid report fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_issue_detector/`, seeded detector inputs under `state/fixtures/invalid/actionable_qa/r13_detector_inputs/`, focused proof in `tests/test_r13_qa_issue_detector.ps1`, and detector capability evidence at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json`. The detector proves source-mapped detection of malformed JSON, missing required evidence refs, missing reproduction command, narrative-only QA evidence, executor self-certification as QA authority, local-only evidence as external proof, missing recommended fix, aggregate passed with unresolved blocking issue, and stale or wrong branch/head/tree identity when expected identity is provided. It does not implement fix queue v2, bounded fix execution, rerun, before/after comparison, external replay, current control-room state, final signoff, R13 closeout, or R14.

### `R13-004` Build QA fix queue and fix-plan generator v2
- Status: done
- Boundary: implements the QA fix queue and fix-plan generator v2 only through `contracts/actionable_qa/r13_qa_fix_queue.contract.json`, `tools/R13QaFixQueue.psm1`, `tools/export_r13_qa_fix_queue.ps1`, `tools/validate_r13_qa_fix_queue.ps1`, valid fix queue fixtures under `state/fixtures/valid/actionable_qa/`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_fix_queue/`, focused proof in `tests/test_r13_qa_fix_queue.ps1`, and generated queue evidence at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json`. It maps every blocking issue from R13-003 to a bounded fix item or explicit no-fix item and rejects orphan fix items, hidden blocking issues, missing source issue IDs, missing reproduction commands, missing recommended fixes, missing validation commands, missing expected evidence refs, broad scope without authorization, outside-repo target files, executor self-certification as fix authority, local-only evidence as external proof, aggregate `passed` before fix execution, missing non-claims, and R14 successor opening. It does not execute fixes, rerun QA, perform before/after comparison, run external replay, produce signoff, deliver a meaningful QA loop, deliver any R13 hard value gate, close R13, or open R14.

### `R13-005` Implement bounded fix execution packet model
- Status: done
- Boundary: implements the bounded fix execution packet model only through `contracts/actionable_qa/r13_bounded_fix_execution.contract.json`, `tools/R13BoundedFixExecution.psm1`, `tools/new_r13_bounded_fix_execution_packet.ps1`, `tools/validate_r13_bounded_fix_execution.ps1`, valid fixtures `state/fixtures/valid/actionable_qa/r13_bounded_fix_execution.authorization.valid.json` and `state/fixtures/valid/actionable_qa/r13_bounded_fix_execution.dry_run.valid.json`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_bounded_fix_execution/`, focused proof in `tests/test_r13_bounded_fix_execution.ps1`, and authorization evidence at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json`. It authorizes future bounded execution without actual target-file mutation and rejects unqueued fixes, source/fix ID mismatch, outside-repo targets, broad scope without explicit authorization, missing rollback or validation evidence, executor self-certification, local-only external proof, premature rerun/comparison/external replay/signoff/hard-gate claims, and R14 successor opening.

### `R13-006` Run one real seeded QA failure through the full loop
- Status: done
- Boundary: runs one controlled seeded QA failure-to-fix cycle in `state/cycles/r13_qa_cycle_demo/` only, using the R13-005 bounded fix authorization for `r13qf-5efcc675b9ec2995` / `r13qi-4da79bc524d40d09` / `malformed_json`. It copies the bad input into a demo before file, writes a repaired demo after file, reruns detector before and after, records `target_issue_resolved`, preserves the canonical invalid fixture unchanged, and does not claim external replay, final signoff, current control-room delivery, or any hard gate.

### `R13-007` Add API/custom-runner execution path foundation
- Status: done
- Boundary: adds a local API-shaped/custom-runner foundation only through `contracts/runner/r13_custom_runner_request.contract.json`, `contracts/runner/r13_custom_runner_result.contract.json`, `tools/R13CustomRunner.psm1`, `tools/invoke_r13_custom_runner.ps1`, `tools/validate_r13_custom_runner_request.ps1`, `tools/validate_r13_custom_runner_result.ps1`, valid and invalid fixtures under `state/fixtures/`, focused proof in `tests/test_r13_custom_runner.ps1`, and bounded runner evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/`. It executes bounded validation commands from a request packet over existing R13-006 evidence and records a result packet with raw logs. It does not implement skill registry/invocation, production API server, external replay, current control-room delivery, operator demo, final signoff, hard gate delivery, R13 closeout, R14, or any successor.

### `R13-008` Add skill registry and skill invocation evidence
- Status: done
- Boundary: defines `qa.detect`, `qa.fix_plan`, `runner.external_replay`, and `control_room.refresh` through `contracts/skills/r13_skill_registry.contract.json`, `contracts/skills/r13_skill_invocation_request.contract.json`, `contracts/skills/r13_skill_invocation_result.contract.json`, `tools/R13SkillRegistry.psm1`, `tools/R13SkillInvocation.psm1`, `tools/validate_r13_skill_registry.ps1`, `tools/validate_r13_skill_invocation_request.ps1`, `tools/validate_r13_skill_invocation_result.ps1`, `tools/invoke_r13_skill.ps1`, valid and invalid fixtures under `state/fixtures/`, focused proof in `tests/test_r13_skill_registry_and_invocation.ps1`, and committed evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/`. It invokes `qa.detect` and `qa.fix_plan` over existing R13-003/R13-004 evidence with one passed command each. `runner.external_replay` is registered but not executed, and `control_room.refresh` is registered but not executed. It does not deliver external replay, current control-room delivery, operator demo, final signoff, hard gate delivery, R13 closeout, R14, or any successor.

### `R13-009` Make control room current and cycle-aware
- Status: done
- Boundary: adds current cycle-aware control-room JSON/Markdown/refresh result through `contracts/control_room/r13_control_room_status.contract.json`, `contracts/control_room/r13_control_room_view.contract.json`, `contracts/control_room/r13_control_room_refresh_result.contract.json`, `tools/R13ControlRoomStatus.psm1`, `tools/render_r13_control_room_view.ps1`, `tools/refresh_r13_control_room.ps1`, `tools/validate_r13_control_room_status.ps1`, `tools/validate_r13_control_room_view.ps1`, `tools/validate_r13_control_room_refresh_result.ps1`, focused proof in `tests/test_r13_control_room_status.ps1`, and generated current artifacts at `state/control_room/r13_current/control_room_status.json`, `state/control_room/r13_current/control_room.md`, `state/control_room/r13_current/control_room_refresh_result.json`, and `state/control_room/r13_current/validation_manifest.md`. This is partial current operator control-room evidence only; it does not deliver external replay, operator demo, final signoff, productized UI, a full hard gate, R13 closeout, R14, or any successor.

### `R13-010` Add operator demo artifact
- Status: done
- Boundary: adds a human-readable operator demo through `contracts/control_room/r13_operator_demo.contract.json`, `tools/render_r13_operator_demo.ps1`, `tools/validate_r13_operator_demo.ps1`, focused proof in `tests/test_r13_operator_demo.ps1`, generated artifact `state/control_room/r13_current/operator_demo.md`, and validation manifest `state/control_room/r13_current/operator_demo_validation_manifest.md`. This is partial operator-demo evidence only; it does not deliver external replay, final signoff, productized UI, a full hard gate, R13 closeout, R14, or any successor.

### `R13-011` Run external replay after QA fix loop
- Status: planned
- Boundary: capture exact external run identity and imported artifact evidence, or fail closed with a manual dispatch packet without claiming external proof.

### `R13-012` Add meaningful QA signoff gate
- Status: planned
- Boundary: allow QA signoff only after detector, fix queue, bounded fix evidence, rerun, before/after comparison, external replay evidence, current control-room state, and no blocking issue remain.

### `R13-013` Add Codex-compaction mitigation proof
- Status: planned
- Boundary: prove a fresh-thread restart can recover R13 state and next legal action from committed repo truth rather than prior chat context.

### `R13-014` Produce R13 cycle evidence package
- Status: planned
- Boundary: consolidate R13 evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/`.

### `R13-015` Update Vision Control scoring with calculable evidence
- Status: planned
- Boundary: apply the approved formula and penalties from the R12/R13 report without inflating beyond committed evidence.

### `R13-016` Generate R13 final audit candidate packet
- Status: planned
- Boundary: generate a candidate packet from evidence that identifies passed gates, blocked gates, exact refs, non-claims, operator demo usefulness, and manual burden reduction.

### `R13-017` Close R13 narrowly only if all hard gates pass
- Status: planned
- Boundary: use two-phase final-head support only if all hard gates pass; do not open R14.

### `R13-018` Produce R13 final report and R14 recommendation only after closeout evidence
- Status: planned
- Boundary: generate a final report from committed evidence only, including the Vision Control table and an explicit 10 to 15 percent progress assessment or failure statement.

## Required Non-Claims

- no R13 hard value gate fully delivered by `R13-010`
- no meaningful QA loop gate delivered yet
- no API/custom-runner bypass gate fully delivered yet
- current operator control-room gate remains partially evidenced only, not fully delivered as a hard gate
- no skill invocation evidence gate fully delivered yet
- operator demo gate is partially evidenced only, not fully delivered as a hard gate
- no productized control-room behavior
- no full UI app
- no production runtime
- no real production QA
- no broad CI/product coverage
- no broad autonomous milestone execution
- no unattended automatic resume
- no solved Codex reliability
- no solved Codex context compaction
- no claim that Codex can run long milestones unattended
- no external replay proof until actual external run evidence exists
- no executor self-certification as QA
- no R14 or successor opening

## Current R13-010 Claim

`R13-001` claims only that R13 was opened narrowly from the report-committed R12 branch head, the hard gates and task plan were frozen, the required status surfaces were updated, and no R14 or successor milestone was opened.

`R13-002` claims only that the ideal QA lifecycle contract is defined and locally validated as a contract/foundation surface. It makes schema-only QA, narrative-only QA, pass-without-rerun, pass-without-fix, pass-without-evidence, executor self-certification, local-only evidence as external replay proof, missing operator summary, unresolved blocking issues as pass, missing non-claims, and R14 successor opening fail closed. It does not claim the meaningful QA loop gate is delivered. The meaningful QA loop remains undelivered until later tasks prove detector, queue, fix, rerun, comparison, external replay, current control room, and signoff with committed evidence.

`R13-003` claims only that the source-mapped issue detector v2 is implemented and locally validated against controlled invalid fixtures. It records an honest failed detector capability report at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json` because seeded inputs contain real controlled issues.

`R13-004` claims only that the QA fix queue and fix-plan generator v2 is implemented and locally validated. It records a queue at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json` that consumes the R13-003 issue detection report, maps all 14 R13-003 blocking issues to bounded fix items, preserves source issue IDs, reproduction commands, recommended fixes, validation commands, rollback notes, and expected future evidence refs, and records aggregate verdict `ready_for_fix_execution`.

`R13-005` claims only that the bounded fix execution packet model is implemented and locally validated. It records an authorization-only packet at `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json` that consumes the R13-004 fix queue, selects all 14 queued fix items, preserves all 14 selected source issue IDs, bounds 9 unique target files, preserves allowed commands, validation commands, rollback plans, and expected future evidence refs, and records aggregate verdict `authorized_for_future_execution`.

`R13-006` claims only that one controlled seeded QA failure-to-fix cycle ran in the demo workspace `state/cycles/r13_qa_cycle_demo/`. It adds `contracts/actionable_qa/r13_qa_failure_fix_cycle.contract.json`, `contracts/actionable_qa/r13_fix_execution_result.contract.json`, `contracts/actionable_qa/r13_qa_before_after_comparison.contract.json`, `tools/R13QaFailureFixCycle.psm1`, `tools/run_r13_qa_failure_fix_cycle.ps1`, `tools/validate_r13_fix_execution_result.ps1`, `tools/validate_r13_qa_before_after_comparison.ps1`, `tools/validate_r13_qa_failure_fix_cycle.ps1`, valid and invalid fixtures under `state/fixtures/`, focused proof in `tests/test_r13_qa_failure_fix_cycle.ps1`, and committed demo evidence under `state/cycles/r13_qa_cycle_demo/`. The selected fix item is `r13qf-5efcc675b9ec2995`, the selected source issue is `r13qi-4da79bc524d40d09`, and the selected issue type is `malformed_json`. The before detector report contains the selected issue type, the after detector report has zero issues for the demo after file, the comparison verdict is `target_issue_resolved`, and the cycle aggregate verdict is `fixed_pending_external_replay`. Canonical invalid detector fixtures remain unchanged.

`R13-007` claims only that a local API-shaped/custom-runner foundation exists for bounded repo-defined validation requests. It adds `contracts/runner/r13_custom_runner_request.contract.json`, `contracts/runner/r13_custom_runner_result.contract.json`, `tools/R13CustomRunner.psm1`, `tools/invoke_r13_custom_runner.ps1`, `tools/validate_r13_custom_runner_request.ps1`, `tools/validate_r13_custom_runner_result.ps1`, valid runner fixtures under `state/fixtures/valid/runner/`, invalid runner fixtures under `state/fixtures/invalid/runner/r13_custom_runner/`, focused proof in `tests/test_r13_custom_runner.ps1`, and committed runner evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/`. The committed request artifact is `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_request.json`; the committed result artifact is `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json`; the validation manifest is `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_validation_manifest.md`. The runner executed 3 bounded validation commands over existing R13-006 evidence, recorded 3 passed commands, 0 failed commands, and aggregate verdict `passed`, with raw logs under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_raw_logs/`. No mutation command ran.

`R13-008` claims only that a bounded repo skill registry and two local skill invocations exist. It adds `contracts/skills/r13_skill_registry.contract.json`, `contracts/skills/r13_skill_invocation_request.contract.json`, `contracts/skills/r13_skill_invocation_result.contract.json`, `tools/R13SkillRegistry.psm1`, `tools/R13SkillInvocation.psm1`, `tools/validate_r13_skill_registry.ps1`, `tools/validate_r13_skill_invocation_request.ps1`, `tools/validate_r13_skill_invocation_result.ps1`, `tools/invoke_r13_skill.ps1`, fixtures under `state/fixtures/valid/skills/` and `state/fixtures/invalid/skills/r13_skill_invocation/`, focused proof in `tests/test_r13_skill_registry_and_invocation.ps1`, and committed registry/invocation evidence under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/`. The committed registry is `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json`. The committed request/result artifacts are `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_request.json`, `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json`, `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_request.json`, and `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json`; the validation manifest is `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_validation_manifest.md`. `qa.detect` ran 1 bounded validation command over the existing R13-003 issue report, recorded 1 passed command, 0 failed commands, and aggregate verdict `passed`. `qa.fix_plan` ran 1 bounded validation command over the existing R13-004 fix queue, recorded 1 passed command, 0 failed commands, and aggregate verdict `passed`. Raw logs are under `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_raw_logs/`. No mutation command ran. `runner.external_replay` is registered but not executed. `control_room.refresh` is registered but not executed.

`R13-009` claims only that current cycle-aware control-room JSON/Markdown/refresh result artifacts exist and validate from repo truth. It adds `contracts/control_room/r13_control_room_status.contract.json`, `contracts/control_room/r13_control_room_view.contract.json`, `contracts/control_room/r13_control_room_refresh_result.contract.json`, `tools/R13ControlRoomStatus.psm1`, `tools/render_r13_control_room_view.ps1`, `tools/refresh_r13_control_room.ps1`, `tools/validate_r13_control_room_status.ps1`, `tools/validate_r13_control_room_view.ps1`, `tools/validate_r13_control_room_refresh_result.ps1`, focused proof in `tests/test_r13_control_room_status.ps1`, and generated current artifacts at `state/control_room/r13_current/control_room_status.json`, `state/control_room/r13_current/control_room.md`, `state/control_room/r13_current/control_room_refresh_result.json`, and `state/control_room/r13_current/validation_manifest.md`.

`R13-010` claims only that a human-readable operator demo artifact exists and validates from actual R13 evidence. It adds `contracts/control_room/r13_operator_demo.contract.json`, `tools/render_r13_operator_demo.ps1`, `tools/validate_r13_operator_demo.ps1`, focused proof in `tests/test_r13_operator_demo.ps1`, generated artifact `state/control_room/r13_current/operator_demo.md`, and validation manifest `state/control_room/r13_current/operator_demo_validation_manifest.md`. `R13-011` through `R13-018` remain planned only. No R13 hard value gate is fully delivered yet. The current operator control-room gate remains partially evidenced only and not fully delivered as a hard gate. The operator demo gate is partially evidenced only and not fully delivered as a hard gate. The meaningful QA loop gate remains partial/local only because external replay and final QA signoff are not delivered. The API/custom-runner bypass gate and skill invocation evidence gate remain partial only. No external replay, final signoff, productized UI, R13 closeout, R14, or successor milestone is opened.
