# R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot

## Milestone name
`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`

## Why this milestone exists now
R10 closed narrowly with cautions at required starting remote head `91035cfbb34f531684943d0bfd8c3ba660f48f08`.

R10 improved the external proof substrate by capturing one successful bounded GitHub Actions proof run, consuming that run through an external-runner-consuming QA signoff, and publishing a two-phase final-head support packet. R10 still exposed serious operating weakness: repeated external-runner failures and repairs under `R10-005`, manual bootstraps, Codex compact/context failure, local-only residue cleanup, high operator burden, and a one-task-at-a-time execution pattern.

R11 opens because the project now needs a controller/state-machine milestone that proves controlled complete cycles, not another proof-documentation milestone.

The operator-facing bridge report `governance/reports/AIOffice_V2_R10_Audit_and_R11_Planning_Report_v1.md` is included as a narrative operator artifact only. It accepts R10 narrowly with cautions, says no corrective R10 support slice is required before R11, and recommends this R11 direction. It is not milestone proof by itself and does not widen R10.

## Current status
`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot` is now active in repo truth through `R11-006` only.

`R11-007` through `R11-009` remain planned only.

`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` remains the most recently closed prior milestone under `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, the Phase 1 candidate package under `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`, the Phase 2 final-head support packet under `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`, candidate closeout commit `cfebd351922b192585ed5f9d3ca56bee30ea16ae`, final R10 support head `91035cfbb34f531684943d0bfd8c3ba660f48f08`, and decision authority `D-0079`.

No R12 or successor milestone is open.

## Objective
Open and prove a governed external/repo-truth cycle controller pilot in which committed repo state, not chat transcript memory, becomes the authority for cycle state, next action, executor dispatch, QA gate, resume, local-residue handling, audit packet generation, and final decision posture.

R11 is explicitly not another proof-paperwork milestone. It is measured by controlled complete-cycle execution and reduced operator burden.

## Exact boundary
R11 is bounded to:
- one repository only: `AIOffice_V2`
- the existing release branch `release/r10-real-external-runner-proof-foundation` for this opening slice, as directed by the operator
- one repo-truth cycle ledger/state machine
- one controller-driven bootstrap/resume path from committed cycle state
- one local-only residue detection/quarantine/refusal path with dry-run evidence
- bounded Dev dispatch/result packets
- a separate QA gate over executor evidence
- one complete controlled cycle with 2 to 3 bounded tasks
- one final audit packet generated from ledger/evidence refs
- a no-successor posture unless the operator explicitly approves a successor milestone

## R11 must prove
- one repo-truth cycle ledger/state machine
- controller-driven bootstrap/resume from committed state
- local-only residue detection/quarantine/refusal
- bounded Dev dispatch/result packets
- separate QA gate over executor evidence
- one complete controlled cycle with multiple bounded tasks
- final audit packet generated from ledger/evidence refs
- fewer operator interruptions than R10
- no successor milestone opened unless explicitly approved

## Success metrics
R11 succeeds only if the demonstrated cycle shows:
- operator intervention count per cycle decreases
- manual bootstrap count decreases to zero for the demonstrated cycle after initial approval
- at least two bounded tasks run inside one controlled cycle
- state authority is repo-truth ledger/controller, not chat memory
- a failed or interrupted executor session can be resumed from repo state
- local-only residue is detected, quarantined, or refused automatically
- QA is separate from executor evidence
- final audit packet is generated from ledger/evidence refs
- user intervention is limited to planned approval and final decision points

## Stop conditions
R11 must stop or fail closed if:
- R11 opens without the R10 closeout evidence chain and final support head `91035cfbb34f531684943d0bfd8c3ba660f48f08`
- status docs contradict the active R11 posture by saying R10 is still active
- a chat transcript is treated as cycle state authority
- local-only residue is used as evidence instead of being refused or quarantined
- executor self-certification is accepted as QA authority
- a task advances without required ledger state, evidence refs, head/tree refs, and allowed transition
- controller output implies broad autonomous milestone execution
- docs claim solved Codex context compaction
- docs claim unattended automatic resume beyond the bounded pilot
- docs claim hours-long unattended milestone execution
- docs claim UI/control-room productization
- docs claim multi-repo orchestration, swarms, or Standard runtime
- docs open R12 or any successor milestone without explicit operator approval
- any R10 claim is widened beyond the narrow Phase 2-supported closeout
- destructive rollback or broad CI/product coverage is claimed

## Required non-claims
R11 does not prove and must not casually widen into:
- no UI or control-room productization
- no Standard runtime
- no multi-repo orchestration
- no swarms
- no broad autonomous milestone execution
- no unattended automatic resume
- no solved Codex context compaction
- no hours-long unattended execution
- no hours-long unattended milestone execution
- no deletion without dry-run and explicit authorization
- no tracked-file modification by the residue guard
- no local-only residue used as evidence
- no QA authority from executor result packets
- no QA verdict from executor result packets
- no real Dev execution beyond bounded adapter fixtures/results generated by tests
- no destructive rollback
- no broad CI/product coverage
- no general Codex reliability
- no productized control-room behavior
- no production runtime
- no successor milestone without explicit approval

## Task list

### `R11-001` Open R11 and freeze boundary
- Status: done
- Done when: R11 opens in repo truth after R10 closeout head `91035cfbb34f531684943d0bfd8c3ba660f48f08`; R10 remains the most recently closed milestone; R11 is frozen as a controlled cycle-controller pilot only; status docs and gates reject R10-active contradictions, broad autonomy, solved compaction, unattended automatic resume, UI/control-room productization, multi-repo/swarms/Standard runtime, and successor opening.

### `R11-002` Define cycle ledger/state machine
- Status: done
- Done when: canonical cycle states and allowed transitions are defined under `contracts/cycle_controller/`, with repo-truth authority, per-state evidence/ref gating, current-step consistency, transition-history validation, and fail-closed invalid state handling.
- Durable output: `contracts/cycle_controller/foundation.contract.json`, `contracts/cycle_controller/cycle_ledger.contract.json`, `state/fixtures/valid/cycle_controller/cycle_ledger.valid.json`, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, `tools/CycleLedger.psm1`, `tools/validate_cycle_ledger.ps1`, and `tests/test_cycle_ledger.ps1`.

### `R11-003` Build cycle controller CLI
- Status: done
- Done when: controller commands can initialize, inspect, advance, and refuse cycles from repo truth, with no chat transcript authority.
- Durable output: `contracts/cycle_controller/controller_command.contract.json`, `contracts/cycle_controller/controller_result.contract.json`, `state/fixtures/valid/cycle_controller/controller_initialize_command.valid.json`, `state/fixtures/valid/cycle_controller/controller_advance_command.valid.json`, `state/fixtures/valid/cycle_controller/controller_refuse_command.valid.json`, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, `tools/CycleController.psm1`, `tools/invoke_cycle_controller.ps1`, and `tests/test_cycle_controller.ps1`.
- Boundary: this is a thin cycle controller CLI only. It does not implement bootstrap/resume from a new session, local-only residue automation, a Dev execution adapter, QA gate execution, a complete controlled cycle, audit packet generation, R11 closeout, or any successor milestone.

### `R11-004` Add bootstrap/resume from repo truth
- Status: done
- Done when: bootstrap and next-action packets can be generated from a valid committed cycle ledger, validated against contract, and refused when ledger state, authority, branch/head/tree identity, allowed next state, or required non-claims contradict repo truth.
- Durable output: `contracts/cycle_controller/cycle_bootstrap_packet.contract.json`, `contracts/cycle_controller/cycle_next_action_packet.contract.json`, `state/fixtures/valid/cycle_controller/cycle_bootstrap_packet.valid.json`, `state/fixtures/valid/cycle_controller/cycle_next_action_packet.valid.json`, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, `tools/CycleBootstrap.psm1`, `tools/prepare_cycle_bootstrap.ps1`, and `tests/test_cycle_bootstrap_resume.ps1`.
- Boundary: this is a bounded bootstrap/resume-from-repo-truth proof only. It emits packets from the committed ledger and recommends only ledger-allowed next states. It does not execute local-only residue automation, Dev tasks, QA gates, a complete controlled cycle, unattended automatic resume beyond this bounded packet proof, R11 closeout, or any successor milestone.

### `R11-005` Add local-only residue detection/quarantine
- Status: done
- Done when: untracked or dirty local residue is detected and refused or quarantined safely with dry-run evidence.
- Durable output: `contracts/cycle_controller/local_residue_policy.contract.json`, `contracts/cycle_controller/local_residue_scan_result.contract.json`, `contracts/cycle_controller/local_residue_quarantine_result.contract.json`, `state/fixtures/valid/cycle_controller/local_residue_scan_result.clean.valid.json`, `state/fixtures/valid/cycle_controller/local_residue_scan_result.dirty.valid.json`, `state/fixtures/valid/cycle_controller/local_residue_quarantine_result.valid.json`, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, `tools/LocalResidueGuard.psm1`, `tools/invoke_local_residue_guard.ps1`, and `tests/test_local_residue_guard.ps1`.
- Boundary: this is a local-only residue detection, dry-run quarantine, authorized quarantine, and refusal guard only. It runs `git status --short --untracked-files=all`, treats tracked dirt as refusal, moves only exact untracked authorized candidates outside the repo after dry-run evidence, and preserves that local-only residue is not evidence or repo truth. It does not implement a Dev execution adapter, QA gate execution, a complete controlled cycle, unattended automatic resume, R11 closeout, or any successor milestone.

### `R11-006` Add bounded Dev execution adapter
- Status: done
- Done when: bounded implementation dispatch/result packets are defined and at least two bounded task packets are representable.
- Durable output: `contracts/cycle_controller/dev_dispatch_packet.contract.json`, `contracts/cycle_controller/dev_execution_result_packet.contract.json`, `state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json`, `state/fixtures/valid/cycle_controller/dev_execution_result_packet.valid.json`, invalid fixtures under `state/fixtures/invalid/cycle_controller/`, `tools/DevExecutionAdapter.psm1`, `tools/invoke_dev_execution_adapter.ps1`, and `tests/test_dev_execution_adapter.ps1`.
- Boundary: this is bounded Dev dispatch/result packet adapter tooling only. It creates and validates structured dispatch/result packets tied to cycle ledger truth, represents at least two bounded task packets, and treats executor result packets as source evidence for later QA, not QA authority or a QA verdict. It does not run a real implementation task, execute a QA gate, execute a complete controlled cycle, perform audit packet generation, close R11, or open any successor milestone.

### `R11-007` Add separate QA gate for cycle tasks
- Status: planned
- Done when: QA consumes executor evidence and rejects executor self-certification as QA authority.

### `R11-008` Execute one complete controlled cycle
- Status: planned
- Done when: one operator-approved request runs through 2 to 3 bounded tasks, evidence, QA, audit packet, and decision packet while reducing manual per-task prompting.

### `R11-009` Close R11 narrowly with final support
- Status: planned
- Done when: R11 closes only if cycle evidence, final support, non-claims, and no-successor posture are present.

## Milestone notes
- `R11-001` opens R11 in repo truth only. It does not implement the controller CLI, resume path, residue guard, Dev adapter, QA gate, controlled cycle, audit packet generation, or closeout.
- `R11-002` defines the canonical cycle ledger/state machine contract and validator foundation only. It does not build the controller CLI, bootstrap/resume execution, local-only residue automation, Dev execution adapter, QA gate execution, complete controlled cycle, audit packet generation, R11 closeout, or any successor milestone.
- `R11-003` builds the first thin cycle controller CLI only. It can initialize, inspect, advance, block, and stop cycle ledgers while validating through the R11-002 ledger contract. It does not execute Dev tasks, QA tasks, bootstrap/resume across sessions, local-only residue automation, or a complete controlled cycle.
- `R11-004` proves bounded bootstrap/resume from repo truth only. It reconstructs state and next action from committed cycle ledger artifacts without chat transcript authority, and it does not execute local-only residue automation, Dev tasks, QA gates, a complete controlled cycle, unattended automatic resume beyond this bounded packet proof, audit packet generation, R11 closeout, or any successor milestone.
- `R11-005` adds local-only residue detection/quarantine/refusal only. It does not delete files, does not modify tracked files, does not use local-only residue as evidence, and does not implement a Dev execution adapter, QA gate execution, complete controlled cycle, unattended automatic resume, audit packet generation, R11 closeout, or any successor milestone.
- `R11-006` adds bounded Dev execution adapter contracts/tooling only. It records bounded dispatch/result packet fixtures/results generated by tests, rejects executor QA authority and complete-cycle claims, and does not run a real implementation task, execute QA, execute a complete controlled cycle, generate final audit packets, close R11, or open any successor milestone.
- `R11-007` through `R11-009` remain planned only after this slice.
- The approved R10 audit/report content is preserved as an operator report artifact and does not become proof by itself.
- R10 remains accepted narrowly with cautions and is not reopened.
- The historical R9 support branch `feature/r5-closeout-remaining-foundations` remains untouched.
- No R12 or successor milestone is opened by this authority document.
