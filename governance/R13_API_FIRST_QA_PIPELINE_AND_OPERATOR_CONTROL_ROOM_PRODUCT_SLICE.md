# R13 API-First QA Pipeline and Operator Control-Room Product Slice

`R13 API-First QA Pipeline and Operator Control-Room Product Slice` is now active in repo truth through `R13-002` only.

## Purpose

R13 opens as an explicitly approved successor milestone after the approved R12/R13 planning report was committed to repo truth. The milestone target is a meaningful QA and operator workflow vertical slice that reduces manual copy/paste dependency and starts moving execution authority away from Codex chat sessions into repo/API/custom-runner surfaces.

R13 is not a governance-only milestone in intent. R13 must produce practical implementation evidence for a real QA cycle, API/custom-runner handoff, current operator control-room usefulness, and a small skill invocation foundation. `R13-001` only opens the branch, freezes hard value gates, records the task plan, and updates status surfaces. `R13-002` only defines the ideal QA lifecycle contract and validator foundation. Neither task delivers any R13 value gate.

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
- require later tasks to produce committed machine-readable evidence before any value gate can be marked delivered;
- avoid product/runtime/autonomy/UI overclaim;
- do not open R14 or any successor milestone.

## R13 Hard Value Gates

All R13 gates are planned and not yet delivered at `R13-002`.

1. Meaningful QA loop gate: planned, not yet delivered.
2. API/custom-runner bypass gate: planned, not yet delivered.
3. Current operator control-room gate: planned, not yet delivered.
4. Skill invocation evidence gate: planned, not yet delivered.
5. Operator demo gate: planned, not yet delivered.

No gate can pass from narrative, schema-only validation, stale artifacts, local-only evidence claimed as external proof, executor self-certification, or chat-memory continuity.

## R13 Task List

### `R13-001` Open R13 and freeze hard value gates
- Status: done
- Boundary: opens R13 on `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`, records the report-committed R12 source head, freezes hard gates, preserves non-claims, updates status surfaces, and does not claim any gate delivered.

### `R13-002` Define ideal QA lifecycle contract
- Status: done
- Boundary: defines the canonical QA lifecycle contract from detect to signoff through `contracts/actionable_qa/r13_qa_lifecycle.contract.json`, `tools/R13QaLifecycle.psm1`, `tools/validate_r13_qa_lifecycle.ps1`, valid initialized fixture `state/fixtures/valid/actionable_qa/r13_qa_lifecycle.valid.json`, invalid fixtures under `state/fixtures/invalid/actionable_qa/r13_qa_lifecycle/`, and `tests/test_r13_qa_lifecycle.ps1`. This is a contract/foundation task only; it does not implement the detector, fix queue, bounded fix execution, rerun, comparison, external replay, control-room demo, or final signoff.

### `R13-003` Build actionable QA issue detector v2
- Status: planned
- Boundary: inspect selected repo paths and emit source-mapped issues with severity, file path, reproduction command, expected behavior, and recommended fix while handling PSScriptAnalyzer absence explicitly.

### `R13-004` Build QA fix queue and fix-plan generator v2
- Status: planned
- Boundary: map every blocking issue to a bounded fix item and reject orphan fix items or hidden blocking issues.

### `R13-005` Implement bounded fix execution packet model
- Status: planned
- Boundary: define how a bounded fix can be authorized, executed, and returned as evidence while rejecting executor self-certification and scope drift.

### `R13-006` Run one real seeded QA failure through the full loop
- Status: planned
- Boundary: run one controlled failure-to-fix QA cycle and commit before/after evidence under `state/cycles/r13_qa_cycle_demo/`.

### `R13-007` Add API/custom-runner execution path foundation
- Status: planned
- Boundary: implement a local API/custom-runner command surface with request packet in, bounded task execution, result packet out, preserved evidence refs, and fail-closed unavailable external dependencies.

### `R13-008` Add skill registry and skill invocation evidence
- Status: planned
- Boundary: define `qa.detect`, `qa.fix_plan`, `runner.external_replay`, and `control_room.refresh` with contracts and evidence packets, then run at least two real invocations.

### `R13-009` Make control room current and cycle-aware
- Status: planned
- Boundary: render current R13 state from current repo truth and refuse stale source state.

### `R13-010` Add operator demo artifact
- Status: planned
- Boundary: generate `state/control_room/r13_current/operator_demo.md` from actual QA failure-to-fix cycle evidence and current pipeline refs.

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

- no R13 hard value gate delivered by `R13-002`
- no meaningful QA loop gate delivered yet
- no API/custom-runner bypass gate delivered yet
- no current operator control-room gate delivered yet
- no skill invocation evidence gate delivered yet
- no operator demo gate delivered yet
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

## Current R13-002 Claim

`R13-001` claims only that R13 was opened narrowly from the report-committed R12 branch head, the hard gates and task plan were frozen, the required status surfaces were updated, and no R14 or successor milestone was opened.

`R13-002` claims only that the ideal QA lifecycle contract is defined and locally validated as a contract/foundation surface. It makes schema-only QA, narrative-only QA, pass-without-rerun, pass-without-fix, pass-without-evidence, executor self-certification, local-only evidence as external replay proof, missing operator summary, unresolved blocking issues as pass, missing non-claims, and R14 successor opening fail closed. It does not claim the meaningful QA loop gate is delivered. The meaningful QA loop remains undelivered until later tasks prove detector, queue, fix, rerun, comparison, external replay, current control room, and signoff with committed evidence.
