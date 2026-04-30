# R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot

`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot` is now active in repo truth through `R12-018` only.

## Purpose

R12 opens a properly named release branch and freezes the next milestone around external/API runner evidence, actionable QA, an operator-readable control-room workflow surface, and one real useful build/change cycle.

R12 is not a documentation-only milestone in intent. The current completed slice adds measurement, operating-loop, stale-head, fresh-thread bootstrap, residue-preflight, external-runner contract, GitHub Actions substrate, external replay workflow, artifact-normalization, actionable QA report/fix queue, cycle QA evidence gate, static control-room status/view, operator decision queue foundations, one bounded executable control-room refresh workflow, and one durable fresh-thread restart proof. It does not deliver all four R12 value gates.

## Accepted Starting State

- Repository: `RodneyMuniz/AIOffice_V2`
- R12 branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`
- R11 final accepted closeout head: `c3bcdf803c0370db66eaa0a9227b3c2301b28fa2`
- R11 Phase 1 candidate closeout commit: `545232bfd06df86018917bc677e6ba3374b3b9c4`
- R11 audit/R12 planning report commit: `5aa08904b02663a5549d2c8a21971544476ae805`
- R11 audit/R12 planning report: `governance/reports/AIOffice_V2_R11_Audit_and_R12_Planning_Report_v1.md`
- Starting tree for R12 branch creation: `ac324d20d4538e50bfdcb92fe192185a824a2f48`
- Historical R9 support branch: `feature/r5-closeout-remaining-foundations`
- Historical R9 support head: `3c225f863add07f64a9026661d9465d02024a83d`

The R11 audit/R12 planning report is a narrative operator planning artifact only. It is not milestone proof by itself, does not open R12 by itself, and does not widen R11.

## Strict R12 Boundary

R12 is bounded to one release branch and one milestone:

- freeze value gates and non-claims;
- add an honest value scorecard foundation that separates baseline, target, and proved scores;
- define the canonical operating-loop contract;
- completed R12 foundation work adds stale-head detection, fresh-thread bootstrap, mandatory residue preflight, external-runner contracts, GitHub Actions substrate tooling, replay workflow/bundle wiring, artifact-normalization foundations, actionable QA report/fix queue tooling, cycle QA evidence gate tooling, static control-room status/view artifacts, operator decision queue tooling, a bounded one-command refresh workflow, and fresh-thread restart proof before later final-state replay and closeout work;
- closeout is prohibited until all four R12 value gates are implemented, exercised, and backed by committed evidence.

R10 and R11 remain closed. R9 remains historical. R13 or any successor milestone is not opened.

## R12 Value Gates

R12 cannot close unless all four gates are implemented, exercised, and backed by committed evidence.

1. External/API runner gate: R12 must eventually invoke, monitor, or capture external runner evidence tied to exact branch, head, and tree, with fail-closed handling if an API token or `gh` CLI is unavailable.
2. Actionable QA gate: R12 must eventually produce JSON and Markdown QA/linter reports with file paths, severity, component or owner, reproduction command, and recommended next action.
3. Operator control-room gate: R12 must eventually generate Markdown, HTML, or JSON status views showing cycle state, blockers, QA issues, external runs, evidence refs, and next action in human-readable form.
4. Real build/change gate: R12 must eventually implement at least one useful executable tooling, workflow, or product-facing change outside proof-only artifact generation.

## Corrected Operator-Value Measurement Stance

The R12 scorecard uses operator-value-weighted measurement and must keep these categories separate:

- `baseline_score`: the inherited R11 operator-value baseline;
- `target_score`: the planned R12 target, which is not proof;
- `proved_score`: evidence-backed progress only;
- `proof_refs`: committed evidence refs for any proved uplift;
- `value_gate_refs`: the value gates tied to the dimension;
- `scoring_basis`: the evidence or measurement basis;
- `non_claims`: explicit rejected claims.

R12 must not claim a 10 percent or larger corrected progress uplift unless all four value gates are proved with committed evidence. Governance or proof artifacts alone cannot drive a major corrected-total increase.

The current R12 foundation slice may claim only:

- R12 opening on the proper release branch;
- frozen value gates and non-claims;
- scorecard measurement foundation;
- operating-loop contract foundation;
- remote-head/stale-phase detection foundation;
- fresh-thread bootstrap packet and next-prompt foundation;
- transition residue preflight foundation;
- external runner request/result/artifact manifest contract foundation;
- bounded GitHub Actions external-runner invoker/monitor/capture substrate;
- R12 external replay workflow and bundle-shape foundation;
- external artifact evidence normalization foundation.
- bounded operator-readable control-room foundation evidence through static JSON/Markdown status and decision queue artifacts.
- bounded real build/change evidence through one executable control-room refresh command and cycle evidence under `state/cycles/r12_real_build_cycle/`.
- bounded fresh-thread restart proof evidence through `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json`.

The current R12 foundation slice does not claim R12 value delivery.

## R12 Task List

### `R12-001` Open R12 on a proper release branch and freeze value gates
- Status: done
- Boundary: opens R12 on `release/r12-external-api-runner-actionable-qa-control-room-pilot`, freezes value gates, records non-claims, and updates status surfaces.

### `R12-002` Add honest KPI/value scorecard
- Status: done
- Boundary: adds the scorecard contract, validator, CLI wrapper, baseline scorecard, fixtures, and focused tests without claiming target achievement.

### `R12-003` Define R12 operating-loop contract
- Status: done
- Boundary: adds the operating-loop contract, validator, CLI wrapper, fixtures, and focused tests for the canonical R12 loop without executing the full loop.

### `R12-004` Implement remote-head and stale-phase detector
- Status: done
- Boundary: detect stale expected heads and advanced remote heads, then choose the correct phase or fail closed.

### `R12-005` Make fresh-thread bootstrap the default execution protocol
- Status: done
- Boundary: emit a compact repo-truth bootstrap packet and next prompt so fresh threads do not rely on chat memory.

### `R12-006` Integrate residue guard into mandatory transition preflight
- Status: done
- Boundary: require clean/residue preflight evidence before controlled transitions.

### `R12-007` Define external runner request/result contracts
- Status: done
- Boundary: define branch/head/tree-bound request, result, and artifact manifest contracts through `contracts/external_runner/external_runner_request.contract.json`, `contracts/external_runner/external_runner_result.contract.json`, `contracts/external_runner/external_runner_artifact_manifest.contract.json`, `tools/ExternalRunnerContract.psm1`, validator wrappers, fixtures, and `tests/test_external_runner_contracts.ps1`.

### `R12-008` Implement GitHub Actions external runner invoker/monitor
- Status: done
- Boundary: add bounded GitHub Actions dependency/dispatch/watch/capture/summarize/manual-dispatch substrate through `tools/ExternalRunnerGitHubActions.psm1`, `tools/invoke_external_runner_github_actions.ps1`, `tools/watch_external_runner_github_actions.ps1`, `tools/capture_external_runner_github_actions.ps1`, fixtures, and `tests/test_external_runner_github_actions.ps1`.

### `R12-009` Add R12 external replay workflow
- Status: done
- Boundary: add one bounded workflow for R12 replay evidence and artifact upload through `.github/workflows/r12-external-replay.yml`, `contracts/external_replay/r12_external_replay_bundle.contract.json`, `tools/new_r12_external_replay_bundle.ps1`, `tools/validate_r12_external_replay_bundle.ps1`, fixtures, `tests/test_r12_external_replay_bundle.ps1`, and `tests/test_r12_external_replay_workflow.ps1`.

### `R12-010` Implement external artifact retrieval and evidence normalization
- Status: done
- Boundary: normalize external run artifacts into repo-consumable evidence packets through `contracts/external_runner/external_artifact_evidence_packet.contract.json`, `tools/ExternalArtifactEvidence.psm1`, `tools/import_external_runner_artifact.ps1`, fixtures, and `tests/test_external_artifact_evidence.ps1`.

### `R12-011` Add QA/linter suite foundation
- Status: done
- Boundary: add focused QA/linter commands that produce structured issue data through `contracts/actionable_qa/actionable_qa_report.contract.json`, `contracts/actionable_qa/actionable_qa_issue.contract.json`, `tools/ActionableQa.psm1`, `tools/invoke_actionable_qa.ps1`, fixtures, and `tests/test_actionable_qa.ps1`.

### `R12-012` Make QA output actionable, not just pass/fail
- Status: done
- Boundary: produce a source-mapped fix queue and Markdown summary through `contracts/actionable_qa/actionable_qa_fix_queue.contract.json`, `tools/ActionableQaFixQueue.psm1`, `tools/export_actionable_qa_fix_queue.ps1`, fixtures, and `tests/test_actionable_qa_fix_queue.ps1`.

### `R12-013` Gate cycle transitions on actionable QA and external evidence
- Status: done
- Boundary: refuse QA pass and closeout transitions without actionable QA, fix queue, external runner result, external artifact evidence, residue preflight, remote-head detection, operating-loop, and scorecard refs through `contracts/actionable_qa/cycle_qa_evidence_gate.contract.json`, `tools/ActionableQaEvidenceGate.psm1`, `tools/invoke_actionable_qa_evidence_gate.ps1`, fixtures, and `tests/test_actionable_qa_evidence_gate.ps1`.

### `R12-014` Generate operator control-room status model
- Status: done
- Boundary: generate a machine-readable cycle/control-room status model through `contracts/control_room/control_room_status.contract.json`, `tools/ControlRoomStatus.psm1`, `tools/export_control_room_status.ps1`, fixtures, `state/control_room/r12_current/control_room_status.json`, and `tests/test_control_room_status.ps1`.

### `R12-015` Generate human-readable control-room view
- Status: done
- Boundary: generate static Markdown so the operator can read status, blockers, QA posture, external-runner posture, evidence refs, next action, decisions, and non-claims through `contracts/control_room/control_room_view.contract.json`, `tools/render_control_room_view.psm1`, fixtures, `state/control_room/r12_current/control_room.md`, and `tests/test_control_room_view.ps1`.

### `R12-016` Add approval/decision queue foundation
- Status: done
- Boundary: expose pending operator decisions and consequences without auto-approval through `contracts/control_room/operator_decision_queue.contract.json`, `tools/OperatorDecisionQueue.psm1`, `tools/export_operator_decision_queue.ps1`, fixtures, `state/control_room/r12_current/operator_decision_queue.json`, `state/control_room/r12_current/operator_decision_queue.md`, and `tests/test_operator_decision_queue.ps1`.

### `R12-017` Run one real useful build/change through the cycle
- Status: done
- Boundary: add one executable operator control-room refresh workflow through `contracts/control_room/control_room_refresh_result.contract.json`, `tools/ControlRoomRefresh.psm1`, `tools/refresh_control_room.ps1`, valid and invalid fixtures under `state/fixtures/valid/control_room_refresh/` and `state/fixtures/invalid/control_room_refresh/`, focused proof `tests/test_control_room_refresh.ps1`, current refresh artifact `state/control_room/r12_current/control_room_refresh_result.json`, refreshed control-room artifacts, and bounded cycle evidence under `state/cycles/r12_real_build_cycle/`.

### `R12-018` Demonstrate fresh-thread restart without operator reconstruction
- Status: done
- Boundary: prove one restart from repo-state bootstrap without manually reconstructing chat context through `contracts/bootstrap/fresh_thread_restart_proof.contract.json`, `tools/FreshThreadRestartProof.psm1`, `tools/record_fresh_thread_restart_proof.ps1`, valid and invalid fixtures under `state/fixtures/valid/bootstrap/` and `state/fixtures/invalid/bootstrap/`, focused proof `tests/test_fresh_thread_restart_proof.ps1`, and actual proof packet `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json`.

### `R12-019` Run external final-state replay
- Status: planned
- Boundary: attach external runner evidence to the R12 final or candidate state.

### `R12-020` Generate final audit/report from repo truth
- Status: planned
- Boundary: generate an audit packet and report from committed evidence, not manual narration.

### `R12-021` Close R12 narrowly with two-phase final-head support
- Status: planned
- Boundary: close only after all four value gates, candidate package, external evidence, and post-push final-head support exist.

## Foundation Outputs

R12-001 through R12-018 are bounded foundation work plus one useful executable refresh workflow and one fresh-thread restart proof only:

- `governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md`
- `contracts/value_scorecard/r12_value_scorecard.contract.json`
- `tools/ValueScorecard.psm1`
- `tools/update_value_scorecard.ps1`
- `state/value_scorecards/r12_baseline.json`
- `state/fixtures/valid/value_scorecard/`
- `state/fixtures/invalid/value_scorecard/`
- `tests/test_value_scorecard.ps1`
- `contracts/operating_loop/r12_operating_loop.contract.json`
- `tools/OperatingLoop.psm1`
- `tools/validate_operating_loop.ps1`
- `state/fixtures/valid/operating_loop/`
- `state/fixtures/invalid/operating_loop/`
- `tests/test_operating_loop.ps1`
- `contracts/remote_head_phase/remote_head_phase_detection.contract.json`
- `tools/RemoteHeadPhaseDetector.psm1`
- `tools/invoke_remote_head_phase_detector.ps1`
- `state/fixtures/valid/remote_head_phase/`
- `state/fixtures/invalid/remote_head_phase/`
- `tests/test_remote_head_phase_detector.ps1`
- `contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json`
- `tools/FreshThreadBootstrap.psm1`
- `tools/prepare_fresh_thread_bootstrap.ps1`
- `state/fixtures/valid/bootstrap/`
- `state/fixtures/invalid/bootstrap/`
- `tests/test_fresh_thread_bootstrap.ps1`
- `contracts/residue_guard/transition_residue_preflight.contract.json`
- `tools/TransitionResiduePreflight.psm1`
- `tools/invoke_transition_residue_preflight.ps1`
- `state/fixtures/valid/residue_guard/`
- `state/fixtures/invalid/residue_guard/`
- `tests/test_transition_residue_preflight.ps1`
- `contracts/external_runner/external_runner_request.contract.json`
- `contracts/external_runner/external_runner_result.contract.json`
- `contracts/external_runner/external_runner_artifact_manifest.contract.json`
- `tools/ExternalRunnerContract.psm1`
- `tools/validate_external_runner_request.ps1`
- `tools/validate_external_runner_result.ps1`
- `tools/validate_external_runner_artifact_manifest.ps1`
- `state/fixtures/valid/external_runner/`
- `state/fixtures/invalid/external_runner/`
- `tests/test_external_runner_contracts.ps1`
- `tools/ExternalRunnerGitHubActions.psm1`
- `tools/invoke_external_runner_github_actions.ps1`
- `tools/watch_external_runner_github_actions.ps1`
- `tools/capture_external_runner_github_actions.ps1`
- `state/fixtures/valid/external_runner_github_actions/`
- `state/fixtures/invalid/external_runner_github_actions/`
- `tests/test_external_runner_github_actions.ps1`
- `.github/workflows/r12-external-replay.yml`
- `contracts/external_replay/r12_external_replay_bundle.contract.json`
- `tools/new_r12_external_replay_bundle.ps1`
- `tools/validate_r12_external_replay_bundle.ps1`
- `state/fixtures/valid/external_replay/`
- `state/fixtures/invalid/external_replay/`
- `tests/test_r12_external_replay_bundle.ps1`
- `tests/test_r12_external_replay_workflow.ps1`
- `contracts/external_runner/external_artifact_evidence_packet.contract.json`
- `tools/ExternalArtifactEvidence.psm1`
- `tools/import_external_runner_artifact.ps1`
- `state/fixtures/valid/external_artifact_evidence/`
- `state/fixtures/invalid/external_artifact_evidence/`
- `tests/test_external_artifact_evidence.ps1`
- `contracts/actionable_qa/actionable_qa_report.contract.json`
- `contracts/actionable_qa/actionable_qa_issue.contract.json`
- `tools/ActionableQa.psm1`
- `tools/invoke_actionable_qa.ps1`
- `state/fixtures/valid/actionable_qa/`
- `state/fixtures/invalid/actionable_qa/`
- `tests/test_actionable_qa.ps1`
- `contracts/actionable_qa/actionable_qa_fix_queue.contract.json`
- `tools/ActionableQaFixQueue.psm1`
- `tools/export_actionable_qa_fix_queue.ps1`
- `state/fixtures/valid/actionable_qa_fix_queue/`
- `state/fixtures/invalid/actionable_qa_fix_queue/`
- `tests/test_actionable_qa_fix_queue.ps1`
- `contracts/actionable_qa/cycle_qa_evidence_gate.contract.json`
- `tools/ActionableQaEvidenceGate.psm1`
- `tools/invoke_actionable_qa_evidence_gate.ps1`
- `state/fixtures/valid/actionable_qa_evidence_gate/`
- `state/fixtures/invalid/actionable_qa_evidence_gate/`
- `tests/test_actionable_qa_evidence_gate.ps1`
- `contracts/control_room/control_room_status.contract.json`
- `tools/ControlRoomStatus.psm1`
- `tools/export_control_room_status.ps1`
- `state/fixtures/valid/control_room/`
- `state/fixtures/invalid/control_room/`
- `tests/test_control_room_status.ps1`
- `contracts/control_room/control_room_view.contract.json`
- `tools/render_control_room_view.psm1`
- `state/fixtures/valid/control_room_view/`
- `state/fixtures/invalid/control_room_view/`
- `tests/test_control_room_view.ps1`
- `contracts/control_room/operator_decision_queue.contract.json`
- `tools/OperatorDecisionQueue.psm1`
- `tools/export_operator_decision_queue.ps1`
- `state/fixtures/valid/operator_decision_queue/`
- `state/fixtures/invalid/operator_decision_queue/`
- `tests/test_operator_decision_queue.ps1`
- `contracts/control_room/control_room_refresh_result.contract.json`
- `tools/ControlRoomRefresh.psm1`
- `tools/refresh_control_room.ps1`
- `state/fixtures/valid/control_room_refresh/`
- `state/fixtures/invalid/control_room_refresh/`
- `tests/test_control_room_refresh.ps1`
- `state/control_room/r12_current/control_room_status.json`
- `state/control_room/r12_current/control_room.md`
- `state/control_room/r12_current/operator_decision_queue.json`
- `state/control_room/r12_current/operator_decision_queue.md`
- `state/control_room/r12_current/control_room_refresh_result.json`
- `state/cycles/r12_real_build_cycle/`
- `contracts/bootstrap/fresh_thread_restart_proof.contract.json`
- `tools/FreshThreadRestartProof.psm1`
- `tools/record_fresh_thread_restart_proof.ps1`
- `tests/test_fresh_thread_restart_proof.ps1`
- `state/fixtures/valid/bootstrap/fresh_thread_restart_proof.valid.json`
- `state/fixtures/invalid/bootstrap/`
- `state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json`

`R12-019` through `R12-021` remain planned only. The R12-018 proof packet records that the bootstrap packet creation head `d93a66aa6b757241583fa1c61bb6333b4228d639` is stale for R12-018 and that the accepted post-R12-017 remote head is `3629d0e8a6659bb31db69b8dd2f25ffaa277ca14` with tree `0ce853ffd37ece19c202e9731b27335ae0cc1756`.

## Required Non-Claims

R12 through `R12-018` does not claim:

- no delivered R12 value gates;
- no R12-019 or later completion;
- no R12 final-state replay;
- no final QA pass for R12 closeout;
- no current real QA evidence gate pass without real external evidence;
- no 10 percent or larger corrected progress uplift;
- no broad autonomous milestone execution;
- no unattended automatic resume;
- no solved Codex context compaction;
- no hours-long unattended execution;
- no production runtime;
- no real production QA;
- no full UI/control-room productization;
- no full UI app;
- no productized control-room behavior;
- no Standard runtime;
- no multi-repo orchestration;
- no swarms;
- no destructive rollback;
- no broad CI/product coverage;
- no general Codex reliability;
- no R13 or successor opening.

## Closeout Requirements

R12 cannot close until:

- all four value gates are implemented, exercised, and backed by committed evidence;
- external/API runner evidence is tied to exact branch, head, and tree;
- actionable QA JSON and Markdown reports exist;
- operator control-room JSON plus human-readable status exists;
- at least one real useful build/change cycle exists outside proof-only artifact generation;
- final audit/report is generated from repo truth;
- two-phase final-head support distinguishes candidate and post-push support evidence;
- non-claims remain explicit;
- no successor milestone is opened without explicit operator approval.

## No-Successor Posture

No R13 or successor milestone is opened by R12 through `R12-018`. Any successor requires explicit operator approval and separate repo-truth opening evidence.
