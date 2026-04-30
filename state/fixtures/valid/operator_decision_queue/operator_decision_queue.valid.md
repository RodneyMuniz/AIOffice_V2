# R12 Operator Decision Queue

- Generated at UTC: `2026-04-30T10:52:06Z`
- Source status: `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`
- Branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- Head: `3c2dcd42a9cb64d5acda8de51e0d579eeaca34bf`
- Tree: `baaa0b40fd8ae23d1a268af64d8bb65955272384`

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
- Evidence refs: `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`, `contracts/actionable_qa/cycle_qa_evidence_gate.contract.json`

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
- Evidence refs: `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`, `contracts/control_room/control_room_status.contract.json`, `contracts/control_room/control_room_view.contract.json`, `contracts/control_room/control_room_refresh_result.contract.json`

### `decision-r12-017-018-authorization`
- Type: `next_slice_authorization`
- Blocking status: `blocking`
- Title: Explicit authorization is required for R12-017 through R12-018 only
- Context: R12-017 and R12-018 remain planned until the operator authorizes one real useful build/change cycle and fresh-thread restart proof.
- Options: `Authorize R12-017 through R12-018 only in the next prompt`, `Keep R12-017 through R12-018 planned`
- Recommended option: Authorize R12-017 through R12-018 only in the next prompt
- Consequence: No real build/change cycle starts unless the next prompt explicitly targets R12-017 through R12-018.
- Required before: `starting_R12_017`
- Owner role: `operator`
- Evidence refs: `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`, `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`

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
- Evidence refs: `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`, `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`

## Evidence Refs
- `state/fixtures/valid/control_room/control_room_status.foundation.valid.json`
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
