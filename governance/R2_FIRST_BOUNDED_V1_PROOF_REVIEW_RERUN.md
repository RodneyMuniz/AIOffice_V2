# R2 First Bounded V1 Proof Review Rerun

## 1. Scope reviewed
- The accepted `RST-009` through `RST-012` substrate stack only, as it exists in the current repository state at rerun commit `b939683`.
- Current repo truth in `README.md`, `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, the prior review record `governance/R2_FIRST_BOUNDED_V1_PROOF_REVIEW.md`, and the prior replay summary `state/proof_reviews/r2_first_bounded_v1/REPLAY_SUMMARY.md`.
- Direct replay from the current repository state, without relying on session UI state or narrative-only claims.

## 2. Repo truths inspected
- The governing documents consistently keep the first proof boundary at supervised operation through `architect` plus bounded `apply/promotion` control.
- `ACTIVE_STATE.md` and `execution/KANBAN.md` still place the repo in `R2 Minimum Control Substrate`, with `RST-009`, `RST-010`, `RST-011`, and `RST-012` accepted implementation steps and the first bounded V1 proof still awaiting formal review closeout.
- The prior review record correctly blocked the proof claim because the allow path stopped at gate permission and the replay still showed artifact-linkage noise from absolute and relative ref mismatch.
- Current repo truth now includes the narrow bounded allow-path action, durable action request and result artifacts, packet and reconciliation post-action updates, and artifact-ref normalization that the rerun directly exercises.

## 3. Evidence replayed
- Replayed required tests directly from the current checkout:
  - `powershell -ExecutionPolicy Bypass -File tests\test_stage_artifact_contracts.ps1`
  - `powershell -ExecutionPolicy Bypass -File tests\test_packet_record_storage.ps1`
  - `powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_gate.ps1`
  - `powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_action.ps1`
  - `powershell -ExecutionPolicy Bypass -File tests\test_supervised_admin_flow.ps1`
- Replayed one explicit allow-path supervised run:
  - `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.allow.json -OutputRoot state\proof_reviews\r2_first_bounded_v1_rerun\runs\allow`
- Replayed one explicit block-path supervised run:
  - `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.block.json -OutputRoot state\proof_reviews\r2_first_bounded_v1_rerun\runs\block`
- Durable rerun outputs were saved under `state/proof_reviews/r2_first_bounded_v1_rerun/`, including raw test outputs, allow and block console outputs, persisted packet, gate request, gate result, action request, and action result files, plus rerun baseline Git metadata.
- Evidence-integrity correction: the saved file `state/proof_reviews/r2_first_bounded_v1_rerun/meta/git_status_before.txt` was captured after the rerun folder had already been created, so it shows `?? state/proof_reviews/r2_first_bounded_v1_rerun/`. That file is therefore post-folder-creation metadata, not a true pre-folder Git-status baseline. The saved `git diff --stat` and `git diff --cached --stat` metadata remained empty, and this mismatch does not alter the replayed proof substance.
- The allow rerun also produced a bounded outcome artifact at `state/apply_promotion_actions/flow-rst012-allow-001.apply.outcome.json`, referenced from the saved action result and packet state.

## 4. What is directly proved now
- `RST-009` remains replayable now: required `intake`, `pm`, `context_audit`, and `architect` stage artifacts validate and malformed artifacts are rejected.
- `RST-010` remains replayable now: packet records persist and reload with distinct packet identity, stage progression, approval, artifact, Git, working, accepted, and reconciliation surfaces.
- `RST-011` remains replayable now: the `apply/promotion` gate allows only when approval, scope, artifact linkage, and reconciliation preconditions are satisfied, blocks fail closed otherwise, and persists blocked-state recording back into packet state.
- `RST-012` remains replayable now: the supervised harness can create or load a packet, walk it through `architect`, issue a bounded gate request, and save durable outcomes.
- The allow rerun proves more than permission:
  - the supervised flow reached `architect`
  - the gate decision was `allow`
  - a bounded `apply` action actually executed after the allow decision
  - a durable action request exists
  - a durable action result exists
  - a durable bounded outcome artifact exists
  - packet state reflects the post-action working change
  - reconciliation state reflects the post-action drift between working and accepted state
  - the action request, gate result, and outcome artifact tie the executed action back to the approved `architect` artifact set
- The block rerun proves the non-executing fail-closed path:
  - the gate decision was `blocked`
  - blocked-state recording persisted back into the packet
  - no action request, action result, or bounded outcome artifact was produced for the block rerun
  - no spurious `artifact_linkage_missing` reason remained on the replayed block path when the approved artifact was in fact the same artifact

## 5. What is still not proved
- This rerun does not prove any broader UI or control-room requirement.
- This rerun does not prove unattended operation.
- This rerun does not prove later-lane workflow beyond the first proof boundary.
- This rerun does not prove Standard or subproject pipeline behavior.
- Those non-proved areas are outside the current first bounded V1 proof boundary and do not block the specific proof decision reviewed here.

## 6. Formal proof decision
- `ALLOW FORMAL PROOF CLAIM`

Implementation accepted is true.
Proof exercised is true.
Proof formally claimable is now true for the first bounded V1 proof boundary reviewed here.
The evidence-integrity correction above does not change that decision.

## 7. Exact blockers if blocked
- None for the first bounded V1 proof boundary on this rerun.

## 8. Exact next action
- Close out the formal proof claim using the saved rerun evidence in `state/proof_reviews/r2_first_bounded_v1_rerun/` and this review record, without broadening the claim beyond the supervised-through-`architect` plus bounded `apply/promotion` proof boundary.
