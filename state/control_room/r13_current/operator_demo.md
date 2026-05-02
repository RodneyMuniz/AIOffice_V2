# R13 Operator Demo

- contract_version: `v1`
- artifact_type: `r13_operator_demo`
- demo_id: `r13od-ee41ac3fcbd34a3b`
- repository: `AIOffice_V2`
- branch: `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`
- head: `b1d31fc3503804cbca6526e74cd39ca999375410`
- tree: `92bc0361ecc9b55c7011f4a18bd86592121519db`
- source_milestone: `R13 API-First QA Pipeline and Operator Control-Room Product Slice`
- source_task: `R13-010`
- source_control_room_status_ref: `state/control_room/r13_current/control_room_status.json`
- source_control_room_view_ref: `state/control_room/r13_current/control_room.md`
- source_failure_fix_cycle_ref: `state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json`
- source_before_after_comparison_ref: `state/cycles/r13_qa_cycle_demo/before_after_comparison.json`
- source_runner_result_ref: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json`
- source_skill_registry_ref: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json`
- source_skill_invocation_refs: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json`, `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json`
- demo_sections: `Executive operator summary`, `What was proved locally`, `QA failure-to-fix cycle walkthrough`, `Before and after evidence`, `Current control-room posture`, `Custom runner posture`, `Skill invocation posture`, `What is still blocked`, `Next legal action`, `Evidence map`, `Explicit non-claims`
- evidence_refs: see `Evidence map`
- blocker_summary: `external replay missing; final QA signoff missing; hard gates not fully delivered`
- hard_gate_summary: `operator demo gate partially evidenced only; no hard R13 value gate fully delivered`
- next_legal_action: `R13-011 external replay after demo`
- generated_at_utc: `2026-05-01T14:50:32Z`
- non_claims: see `Explicit non-claims`

## Executive operator summary
R13 now has a human-readable operator demo artifact that explains the local QA failure-to-fix proof, current control-room surface, bounded custom-runner evidence, and partial skill invocation evidence without requiring raw JSON first.
R13 is active through R13-010 only; R13-011 through R13-018 remain planned only.
External replay and final QA signoff are still missing, and no hard R13 value gate is fully delivered.

## What was proved locally
- Local QA proof: selected issue type `malformed_json` was repaired in the controlled demo workspace.
- Cycle aggregate verdict: `fixed_pending_external_replay`.
- Current control-room surface: `state/control_room/r13_current/control_room_status.json` and `state/control_room/r13_current/control_room.md`.
- Bounded custom-runner evidence: `3` commands, `3` passed, aggregate `passed`.
- Partial skill invocation evidence: `qa.detect` `1` command / `1` passed; `qa.fix_plan` `1` command / `1` passed.

## QA failure-to-fix cycle walkthrough
- Source cycle: `state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json`.
- Selected fix item: `r13qf-5efcc675b9ec2995`.
- Selected source issue: `r13qi-4da79bc524d40d09`.
- Selected issue type: `malformed_json`.
- Cycle status: `fixed_locally_pending_external_replay`.
- Aggregate verdict: `fixed_pending_external_replay`.

## Before and after evidence
- Before input: `state/cycles/r13_qa_cycle_demo/before/malformed_json_input.json`.
- After input: `state/cycles/r13_qa_cycle_demo/after/malformed_json_input.json`.
- Before detection report: `state/cycles/r13_qa_cycle_demo/before_detection_report.json`.
- After detection report: `state/cycles/r13_qa_cycle_demo/after_detection_report.json`.
- Before issue count: `1`.
- After issue count: `0`.
- Comparison verdict: `target_issue_resolved`.

## Current control-room posture
- Source status: `state/control_room/r13_current/control_room_status.json`.
- Source Markdown view: `state/control_room/r13_current/control_room.md`.
- Source status stale-state checks passed: `True`.
- R13 active through R13-010 only after this demo; R13-011 through R13-018 remain planned only.
- Current operator control-room gate remains partially evidenced only, not fully delivered as a hard gate.

## Custom runner posture
- Runner result: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json`.
- Execution status: `completed`.
- Aggregate verdict: `passed`.
- Commands: `3` total, `3` passed, `0` failed.
- API/custom-runner bypass gate remains partial only, not fully delivered as a hard gate.

## Skill invocation posture
- Skill registry: `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json`.
- Registered skills: `qa.detect`, `qa.fix_plan`, `runner.external_replay`, `control_room.refresh`.
- `qa.detect`: `1` command, `1` passed, aggregate `passed`, ref `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json`.
- `qa.fix_plan`: `1` command, `1` passed, aggregate `passed`, ref `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json`.
- Skill invocation evidence gate is partially evidenced only, not fully delivered as a hard gate.

## What is still blocked
- External replay missing.
- Final QA signoff missing.
- Hard gates not fully delivered.

## Next legal action
- `R13-011`: external replay after demo, unless the R13 authority/status changes by explicit repo-truth approval.

## Evidence map
- `contracts/control_room/r13_operator_demo.contract.json`
- `tools/render_r13_operator_demo.ps1`
- `tools/validate_r13_operator_demo.ps1`
- `state/control_room/r13_current/control_room_status.json`
- `state/control_room/r13_current/control_room.md`
- `state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json`
- `state/cycles/r13_qa_cycle_demo/before_after_comparison.json`
- `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json`
- `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json`
- `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json`
- `state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json`

## Explicit non-claims
- no external replay has occurred
- no final QA signoff has occurred
- no hard R13 value gate fully delivered
- no productized UI
- no production runtime
- no R14 or successor opening
