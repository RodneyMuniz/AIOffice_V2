# R13 Control Room Validation Manifest

- artifact_type: `r13_control_room_validation_manifest`
- source_refresh_result_ref: `state/control_room/r13_current/control_room_refresh_result.json`
- generated_at_utc: `2026-05-01T14:50:44Z`

## Repository Identity
- Branch: `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`
- Head: `b1d31fc3503804cbca6526e74cd39ca999375410`
- Tree: `92bc0361ecc9b55c7011f4a18bd86592121519db`
- Stale-state checks passed: `True`

## Generated Artifacts
- Status JSON: `state/control_room/r13_current/control_room_status.json`
- Markdown view: `state/control_room/r13_current/control_room.md`
- Refresh result: `state/control_room/r13_current/control_room_refresh_result.json`
- Validation manifest: `state/control_room/r13_current/validation_manifest.md`

## Refresh Commands
- `generate-status`: `passed` exit `0` - Generated current R13 control-room status from repo evidence.
- `render-view`: `passed` exit `0` - Rendered human-readable control-room Markdown view.

## Validation Results
- `state/control_room/r13_current/control_room_status.json` via `tools/validate_r13_control_room_status.ps1`: `passed` - `Generated status validates.`
- `state/control_room/r13_current/control_room.md` via `tools/validate_r13_control_room_view.ps1`: `passed` - `Generated Markdown view validates.`

## R13 Boundary
- Completed: `R13-001 through R13-010`
- Planned: `R13-011 through R13-018`
- Next legal action: `R13-011`
- Blockers: `3`
- Attention items: `5`

## Hard Gate Posture
- Overall: `blocked`; any hard gate delivered: `False`
- `meaningful_qa_loop`: `partial_local_only`; hard gate delivered `False`
- `api_custom_runner_bypass`: `partial_local_only`; hard gate delivered `False`
- `current_operator_control_room`: `partially_evidenced`; hard gate delivered `False`
- `skill_invocation_evidence`: `partially_evidenced`; hard gate delivered `False`
- `operator_demo`: `partially_evidenced`; hard gate delivered `False`

## Explicit Non-Claims
- R13-010 adds human-readable operator demo artifact only
- R13 active through R13-010 only
- R13-011 through R13-018 remain planned only
- operator demo gate is partially evidenced only; not fully delivered as a hard gate
- current operator control-room gate remains partially evidenced only; not fully delivered as a hard gate
- no external replay has occurred
- no final QA signoff delivered by R13-010
- no R13 hard value gate fully delivered by R13-010
- no productized control-room behavior
- no full UI app
- no production runtime
- no real production QA
- no hard gate overclaim
- no R14 or successor opening
