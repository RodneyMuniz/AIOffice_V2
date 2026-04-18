# R2 First Bounded V1 Replay Summary

## Review context
- Review folder: `state/proof_reviews/r2_first_bounded_v1`
- Repo branch at replay start: `main`
- Repo HEAD at replay start: `5cfc40e267f75a79d7e3f2c3a0d9f0b007b01be0`
- Start-of-review Git status: clean before proof-review evidence files were created

## Commands replayed
- `powershell -ExecutionPolicy Bypass -File tests\test_stage_artifact_contracts.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_packet_record_storage.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_gate.ps1`
- `powershell -ExecutionPolicy Bypass -File tests\test_supervised_admin_flow.ps1`
- `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.allow.json -OutputRoot state\proof_reviews\r2_first_bounded_v1\runs\allow`
- `powershell -ExecutionPolicy Bypass -File tools\run_supervised_admin_flow.ps1 -FlowRequestPath state\fixtures\valid\supervised_admin_flow.block.json -OutputRoot state\proof_reviews\r2_first_bounded_v1\runs\block`

## Test output summaries
- `test_stage_artifact_contracts.ps1`: passed. Four valid stage fixtures validated and four invalid fixtures were rejected. Raw output: `tests/test_stage_artifact_contracts.txt`
- `test_packet_record_storage.ps1`: passed. Valid packet fixture validated, invalid packet fixtures rejected, and persist/reload round-trip succeeded. Raw output: `tests/test_packet_record_storage.txt`
- `test_apply_promotion_gate.ps1`: passed. Valid allow request returned `allow`; invalid requests blocked for missing approval, ambiguous or missing scope, missing artifact linkage, and unresolved reconciliation; blocked state recording was persisted. Raw output: `tests/test_apply_promotion_gate.txt`
- `test_supervised_admin_flow.ps1`: passed. Harness request contracts validated, an allow flow returned `allow`, and a block flow returned `blocked` with persisted blocked-state recording. Raw output: `tests/test_supervised_admin_flow.txt`

## Explicit supervised allow run summary
- Console output: `runs/allow_console.txt`
- Packet output: `runs/allow/packets/packet-rst012-allow-001.json`
- Gate request output: `runs/allow/gate_requests/flow-rst012-allow-001.request.json`
- Gate result output: `runs/allow/gate_results/flow-rst012-allow-001.result.json`
- Directly observed result:
  The harness created a fresh packet, advanced it through `architect`, accepted the `architect` artifact into packet truth, and produced an `allow` gate result with all four preconditions set to `true`.
- Directly observed limit:
  The durable allow evidence stops at gate evaluation. The packet remains at `current_stage: architect` with `working_state.status: ready_for_review`, and the allow gate result records no bounded mutation or promotion having been executed.

## Explicit supervised block run summary
- Console output: `runs/block_console.txt`
- Packet output: `runs/block/packets/packet-rst011-allow-001.json`
- Gate request output: `runs/block/gate_requests/flow-rst012-block-001.request.json`
- Gate result output: `runs/block/gate_results/flow-rst012-block-001.result.json`
- Directly observed result:
  The harness loaded an architect-ready packet and produced a `blocked` gate result with durable blocked-state recording back into the packet.
- Directly observed block reasons:
  `approval_missing`
- Additional directly observed block reasons on this replay:
  `artifact_linkage_missing` was also recorded twice because the loaded packet fixture kept relative accepted artifact refs while the harness gate request stored an absolute approved artifact ref.

## Replay conclusion
- Accepted implementation is present and replayable now.
- Proof was exercised now.
- Formal proof is still not claimable from this replay because the direct allow-path evidence demonstrates gate permission, not a completed bounded `apply/promotion` action with a durable trace of the actual action outcome.
