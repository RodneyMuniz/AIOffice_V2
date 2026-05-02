Run only these minimal checks first:
- `git rev-parse --show-toplevel`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git rev-parse "HEAD^{tree}"`
- `git status --short --untracked-files=all`

Use committed repo evidence as the state source. Read the packet at `state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json` and identity reconciliation at `state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json` before taking any milestone action.

Do not perform broad repo inventory unless focused validation fails. Do not close R13. Do not open R14 or any successor. Do not claim Codex compaction or Codex reliability is solved generally.

R13-014 is allowed only after R13-013 is committed, pushed, and verified from branch/head/tree and a clean worktree. Until then, R13 is active through R13-013 only and R13-014 through R13-018 remain planned only.

Codex compaction is not solved generally; this prompt is only a bounded repo-truth restart aid for the R13-013 boundary.

## Prompt Metadata
- artifact_type: `r13_restart_prompt`
- prompt_id: `r13rp-c949b57b20cb0e47`
- source_packet_ref: `state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json`
- target_user: `Codex restart agent`
- intended_use: `recover R13 state after context compaction using committed repo evidence`
- allowed_next_task: `R13-014 after R13-013 commit/push/verification only`

## Evidence Refs
- `r13-013-packet-contract`: `contracts/continuity/r13_compaction_mitigation_packet.contract.json`
- `r13-013-restart-prompt-contract`: `contracts/continuity/r13_restart_prompt.contract.json`
- `r13-013-module`: `tools/R13CompactionMitigation.psm1`
- `r13-013-generator`: `tools/new_r13_compaction_mitigation_packet.ps1`
- `r13-013-packet-validator`: `tools/validate_r13_compaction_mitigation_packet.ps1`
- `r13-013-restart-prompt-validator`: `tools/validate_r13_restart_prompt.ps1`
- `r13-013-test`: `tests/test_r13_compaction_mitigation.ps1`
- `r13-013-identity-reconciliation`: `state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json`
- `r13-013-compaction-mitigation-packet`: `state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json`
- `r13-013-restart-prompt`: `state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md`
- `r13-013-validation-manifest`: `state/continuity/r13_compaction_mitigation/validation_manifest.md`
- `r13-012-signoff`: `state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json`
- `r13-012-evidence-matrix`: `state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json`
- `r13-011-external-replay-result`: `state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json`
- `r13-011-external-replay-import`: `state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json`
- `r13-control-room-status`: `state/control_room/r13_current/control_room_status.json`
- `r13-control-room-view`: `state/control_room/r13_current/control_room.md`
- `r13-control-room-refresh-result`: `state/control_room/r13_current/control_room_refresh_result.json`
- `r13-control-room-validation-manifest`: `state/control_room/r13_current/validation_manifest.md`
- `r13-operator-demo`: `state/control_room/r13_current/operator_demo.md`
- `r13-authority`: `governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md`

## Non-Claims
- bounded repo-truth continuity mitigation only
- does not solve Codex compaction generally
- does not solve Codex reliability generally
- no R13 closeout
- no R14 or successor opening
- no production runtime
- no productized UI
- no full product QA coverage
- R13 active through R13-013 only
- R13-014 through R13-018 remain planned only
