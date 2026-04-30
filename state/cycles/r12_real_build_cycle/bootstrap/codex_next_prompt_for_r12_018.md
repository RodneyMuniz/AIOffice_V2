You are Codex continuing R12 implementation in `RodneyMuniz/AIOffice_V2` from a new fresh Codex thread.

Do not rely on prior chat context. Use only committed repo truth and this generated bootstrap packet:
`state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_bootstrap_packet.json`

Current task: R12-018 fresh-thread restart proof only.
Target R12-018 only.
Do not implement R12-019 or later.
Do not run final external replay.
Do not claim R12 closeout.
Do not open R13.

Bootstrap verification required before any change:
- Confirm repo root is `AIOffice_V2`.
- Confirm branch is `release/r12-external-api-runner-actionable-qa-control-room-pilot`.
- Packet creation local head: `d93a66aa6b757241583fa1c61bb6333b4228d639`.
- Packet creation local tree: `3f873b3f4e46bc01a2b3299ce5adabbdda99fdd0`.
- Resolve the expected post-R12-017 head from committed repo truth: the remote R12 branch head at fresh-thread start must be the commit containing the R12-017 refresh artifacts and must not equal the pre-R12-017 source head `d93a66aa6b757241583fa1c61bb6333b4228d639`.
- Confirm local HEAD equals that resolved post-R12-017 remote head.
- Confirm local tree matches `git rev-parse 'HEAD^{tree}'` for that head.
- Confirm `git status --short --untracked-files=all` is clean.
- Confirm `state/control_room/r12_current/control_room_refresh_result.json` validates with `tests/test_control_room_refresh.ps1`.

Fail-closed rules:
- Missing branch/head/tree refuses R12-018.
- Local head must equal the resolved post-R12-017 remote R12 head.
- The pre-R12-017 head `d93a66aa6b757241583fa1c61bb6333b4228d639` is stale for R12-018.
- R12-019 or later is out of scope.
- R12 closeout must not be claimed.

Relevant evidence refs:
- `state/control_room/r12_current/control_room_refresh_result.json`
- `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_bootstrap_packet.json`
- `state/cycles/r12_real_build_cycle/bootstrap/codex_next_prompt_for_r12_018.md`
- `tests/test_control_room_refresh.ps1`

R12-018 objective:
Prove fresh-thread restart without operator reconstruction by using only committed repo truth and the bootstrap packet. Produce durable R12-018 evidence that a new thread can recover the active R12 posture, expected branch/head/tree, completed-through state, pending tasks, blockers, and non-claims from repository artifacts.

Required posture to preserve:
- R12-001 through R12-017 are done.
- R12-018 through R12-021 are planned at thread start.
- External/API runner gate remains not fully delivered because no real external run exists.
- Final QA/evidence gate remains blocked/refused without real external evidence.
- Operator control-room remains bounded static tooling, not productized behavior.
- No final-state replay.
- No R12 closeout.
- No R13/successor.

Non-claims:
- This does not prove R12-018 in the current thread.
- This does not prove final QA pass.
- This does not claim R12 closeout.
- This does not open R13.
- This does not deliver productized control-room behavior.

Stop after R12-018 evidence. Do not advance R12-019.
