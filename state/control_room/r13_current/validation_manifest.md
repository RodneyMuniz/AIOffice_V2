# R13 Control Room Validation Manifest

- artifact_type: `r13_control_room_validation_manifest`
- source_refresh_result_ref: `state/control_room/r13_current/control_room_refresh_result.json`
- generated_at_utc: `2026-05-02T00:49:40Z`

## Repository Identity
- Branch: `release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice`
- Head: `e9e8b4e21147d7c0906b4916297e3162690dbf64`
- Tree: `520e2adf5e5fcbce2f81b23c872206d746e6b9c2`
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
- Completed: `R13-001 through R13-011`
- Planned: `R13-012 through R13-018`
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
- R13-011 records a blocked external replay/manual dispatch packet only
- R13 active through R13-011 only
- R13-012 through R13-018 remain planned only
- operator demo gate is partially evidenced only; not fully delivered as a hard gate
- current operator control-room gate remains partially evidenced only; not fully delivered as a hard gate
- external replay is blocked; no external replay proof is claimed
- no final QA signoff delivered by R13-011
- no R13 hard value gate fully delivered by R13-011
- no productized control-room behavior
- no full UI app
- no production runtime
- no real production QA
- no hard gate overclaim
- no R14 or successor opening
