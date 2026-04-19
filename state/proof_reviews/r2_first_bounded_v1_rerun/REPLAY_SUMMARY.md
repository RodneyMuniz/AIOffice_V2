# R2 First Bounded V1 Proof Review Rerun Summary

## Review context
- Review folder: `state/proof_reviews/r2_first_bounded_v1_rerun`
- Repo branch at rerun start: `main`
- Repo HEAD at rerun start: `b939683`
- Start-of-rerun Git status: clean before rerun evidence files were created
- Baseline Git metadata saved under:
  - `meta/pwd.txt`
  - `meta/git_repo_root.txt`
  - `meta/git_branch.txt`
  - `meta/git_head_short.txt`
  - `meta/git_status_before.txt`
  - `meta/git_diff_before.txt`
  - `meta/git_diff_cached_before.txt`
  - `meta/git_log_before.txt`

## Commands replayed
- `powershell -ExecutionPolicy Bypass -File tests\test_stage_artifact_contracts.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_packet_record_storage.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_gate.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_action.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_supervised_admin_flow.ps1`
- `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.allow.json -OutputRoot state\proof_reviews\r2_first_bounded_v1_rerun\runs\allow`
- `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.block.json -OutputRoot state\proof_reviews\r2_first_bounded_v1_rerun\runs\block`

## Test output summaries
- `test_stage_artifact_contracts.ps1`: passed. Four valid stage fixtures validated and four invalid fixtures were rejected. Raw output: `tests/test_stage_artifact_contracts.txt`
- `test_packet_record_storage.ps1`: passed. Valid packet fixture validated, invalid packet fixtures rejected, and persist/reload round-trip succeeded. Raw output: `tests/test_packet_record_storage.txt`
- `test_apply_promotion_gate.ps1`: passed. Valid allow request returned `allow`; artifact-ref normalization matched an absolute approved artifact ref to relative accepted packet refs; invalid requests blocked for missing approval, ambiguous or missing scope, missing artifact linkage, and unresolved reconciliation. Raw output: `tests/test_apply_promotion_gate.txt`
- `test_apply_promotion_action.ps1`: passed. Valid action request and result contracts validated, the bounded allow-path action executed, and blocked execution after a non-allow gate result was refused. Raw output: `tests/test_apply_promotion_action.txt`
- `test_supervised_admin_flow.ps1`: passed. Harness request contracts validated, the allow flow produced an executed bounded action with durable artifacts, and the block flow stayed non-executing while persisting blocked-state recording. Raw output: `tests/test_supervised_admin_flow.txt`

## Explicit supervised allow run summary
- Console output: `runs/allow_console.txt`
- Packet output: `runs/allow/packets/packet-rst012-allow-001.json`
- Gate request output: `runs/allow/gate_requests/flow-rst012-allow-001.request.json`
- Gate result output: `runs/allow/gate_results/flow-rst012-allow-001.result.json`
- Action request output: `runs/allow/action_requests/flow-rst012-allow-001.action.request.json`
- Action result output: `runs/allow/action_results/flow-rst012-allow-001.action.result.json`
- Action outcome output: `state/apply_promotion_actions/flow-rst012-allow-001.apply.outcome.json`
- Directly observed facts:
  - gate decision is `allow`
  - all gate preconditions are `true`
  - a durable action request exists
  - a durable action result exists
  - a durable bounded outcome artifact exists
  - the action result status is `completed`
  - packet `working_state.status` changed to `in_progress`
  - packet `reconciliation_state.status` changed to `drift`
  - packet `working_matches_accepted` is `false`
  - packet `git_head_matches_accepted` is `true`
  - the packet working artifact refs include the action request, action result, and bounded outcome artifact
  - the action request, gate result, and outcome artifact all reference the same approved `architect` artifact set

## Explicit supervised block run summary
- Console output: `runs/block_console.txt`
- Packet output: `runs/block/packets/packet-rst011-allow-001.json`
- Gate request output: `runs/block/gate_requests/flow-rst012-block-001.request.json`
- Gate result output: `runs/block/gate_results/flow-rst012-block-001.result.json`
- Directly observed facts:
  - gate decision is `blocked`
  - the only block reason is `approval_missing`
  - blocked-state recording is `recorded: true`
  - packet `working_state.status` is `blocked`
  - packet notes reference the saved blocked gate result
  - no action request, action result, or bounded outcome artifact was produced under the block rerun path
  - no `artifact_linkage_missing` reason appears in the block rerun

## Rerun conclusion
- Accepted implementation is present and replayable now.
- Proof was exercised now.
- The first bounded V1 proof is formally claimable from this rerun because the direct evidence now shows supervised operation through `architect`, bounded gate evaluation, executed bounded allow-path action, durable post-action artifacts and packet-state updates, a non-executing block path, and artifact-linkage behavior without replay ambiguity on the proved paths.
