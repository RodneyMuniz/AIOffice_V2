# R12 Operator Decision Queue

- Generated at UTC: `2026-04-30T11:09:45Z`
- Source status: `state/control_room/r12_current/control_room_status.json`
- Branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Head: `d93a66aa6b757241583fa1c61bb6333b4228d639`
- Tree: `3f873b3f4e46bc01a2b3299ce5adabbdda99fdd0`

## Queue Summary
- Decision count: 4
- Blocking decision count: 3

## Recommended Sequence
- Review the generated control-room status, Markdown view, decision queue, and refresh result.
- Keep final QA/evidence gate blocked until real external runner result and artifact evidence exist.
- Use the generated R12-018 prompt only in a separate fresh Codex thread.
- Keep R13 or any successor milestone unauthorized.

## Decisions
### `decision-external-evidence-required`
- Type: `external_evidence_required`
- Blocking status: `blocking`
- Title: Real external evidence is required before final QA/evidence gate pass
- Context: The control-room status records no live R12 external runner result and no external artifact evidence for the current branch/head/tree.
- Options: `Defer final QA/evidence pass until real external evidence exists`, `Authorize a later bounded external evidence capture slice`
- Recommended option: Defer final QA/evidence pass until real external evidence exists
- Consequence: Final QA/evidence gate and R12 closeout remain blocked until real external runner result and artifact evidence are committed.
- Required before: `final_qa_evidence_gate_pass`
- Owner role: `operator`
- Evidence refs: `state/control_room/r12_current/control_room_status.json`, `contracts/actionable_qa/cycle_qa_evidence_gate.contract.json`

### `decision-control-room-review`
- Type: `approval_required`
- Blocking status: `non_blocking`
- Title: Review generated control-room refresh artifacts
- Context: The status model, Markdown view, decision queue, and refresh result are generated for operator review as a bounded static workflow.
- Options: `Accept the bounded control-room refresh evidence`, `Request corrections to generated refresh wording`
- Recommended option: Accept the bounded control-room refresh evidence
- Consequence: Acceptance records operator-readable refresh evidence only; it does not create productized control-room behavior.
- Required before: `next_slice_authorization`
- Owner role: `operator`
- Evidence refs: `state/control_room/r12_current/control_room_status.json`, `contracts/control_room/control_room_status.contract.json`, `contracts/control_room/control_room_view.contract.json`, `contracts/control_room/control_room_refresh_result.contract.json`

### `decision-r12-018-fresh-thread`
- Type: `next_slice_authorization`
- Blocking status: `blocking`
- Title: Execute R12-018 only from a separate fresh Codex thread
- Context: R12-017 prepared a bootstrap packet and next prompt, but R12-018 is not done in this thread.
- Options: `Use the generated R12-018 prompt in a new Codex thread`, `Keep R12-018 pending`
- Recommended option: Use the generated R12-018 prompt in a new Codex thread
- Consequence: R12-018 remains pending until a separate fresh thread verifies repo truth from the committed packet.
- Required before: `starting_R12_018`
- Owner role: `operator`
- Evidence refs: `state/control_room/r12_current/control_room_status.json`, `contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json`, `tools/FreshThreadBootstrap.psm1`

### `decision-no-r13-successor`
- Type: `blocked_refusal`
- Blocking status: `blocking`
- Title: No R13 or successor milestone is authorized
- Context: R12 remains active and cannot close until all R12 closeout prerequisites exist.
- Options: `Keep R13 unauthorized`, `Require a separate future repo-truth opening prompt before any successor`
- Recommended option: Keep R13 unauthorized
- Consequence: Any R13 or successor work remains blocked until explicit future authorization and repo-truth opening evidence exist.
- Required before: `any_successor_milestone_opening`
- Owner role: `operator`
- Evidence refs: `state/control_room/r12_current/control_room_status.json`, `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`

## Evidence Refs
- `state/control_room/r12_current/control_room_status.json`
- `contracts/control_room/operator_decision_queue.contract.json`
- `tools/OperatorDecisionQueue.psm1`
- `tools/export_operator_decision_queue.ps1`
- `contracts/control_room/control_room_refresh_result.contract.json`

## Non-Claims
- no automatic operator replacement
- no R13 authorization
- no final acceptance
- no R12 closeout
- no productized workflow UI
- R12-018 not done
