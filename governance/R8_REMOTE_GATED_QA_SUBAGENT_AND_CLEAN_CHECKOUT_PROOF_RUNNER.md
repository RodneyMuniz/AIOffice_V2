# R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner

## Milestone name
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`

## Why this milestone exists now
R7 is honestly closed, but the final R7 audit preserved the next hard trust gap instead of removing it.

The repo now has a real bounded continuity and rollback-drill closeout package, yet the delivery path that produced it still relied too heavily on executor-produced evidence and post-hoc correction. The bounded proof-hardening correction improved evidence linkage, but it did not create independent QA, final-head clean-checkout replay, CI or external proof execution, or a separate QA signoff packet.

The next defensible step is still not UI expansion, not Standard runtime, not broader orchestration, and not broad autonomy. The next bounded step is to make milestone completion mechanically hard to falsely claim by requiring remote-head truth, post-push verification, clean-checkout QA replay, complete raw command logs, QA proof packets, validator-backed proof refs, and status-doc gating before completion can be accepted.

## Objective
Prove one narrow trust substrate for `AIOffice_V2` only in which executor work cannot be accepted as complete unless the exact remote branch head is verified, the exact remote head is verified again after push, the exact remote head is replayed from a clean or disposable checkout, every declared command has raw stdout or stderr or exit-code evidence, Git hygiene state is captured, proof artifacts are validated, status docs cannot close ahead of evidence, and a separate QA packet exists, without widening into UI productization, Standard runtime, multi-repo behavior, swarms, unattended automatic resume, destructive rollback, or broader automation claims.

## Current status
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` is now active in repo truth as a bounded QA and proof trust milestone.

`R8-001` through `R8-005` are complete in repo truth.

`R8-006` through `R8-009` are planned only.

`R8-002` now defines the first durable QA proof packet contract and validator surfaces through `contracts/qa_proof/foundation.contract.json`, `contracts/qa_proof/qa_proof_packet.contract.json`, `tools/QaProofPacket.psm1`, `tools/validate_qa_proof_packet.ps1`, `state/fixtures/valid/qa_proof/`, and `tests/test_qa_proof_packet.ps1`.

`R8-003` now adds the first remote-head verification gate through `contracts/qa_proof/remote_head_verification.contract.json`, `tools/RemoteHeadVerification.psm1`, `tools/verify_remote_branch_head.ps1`, and `tests/test_remote_head_verification.ps1`.

`R8-004` now adds the first post-push verification gate through `contracts/qa_proof/post_push_verification.contract.json`, `tools/PostPushVerification.psm1`, `tools/verify_post_push_remote_head.ps1`, and `tests/test_post_push_verification.ps1`, with a separate satisfaction check that refuses completion if the exact final remote SHA is missing or mismatched.

`R8-005` now adds the first disposable clean-checkout QA runner through `tools/CleanCheckoutQaRunner.psm1`, `tools/invoke_clean_checkout_qa.ps1`, and `tests/test_clean_checkout_qa_runner.ps1`, with QA packet emission pinned to the exact remote SHA under a governed output root.

`R7 Fault-Managed Continuity and Rollback Drill` remains the most recently closed milestone under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, and decision authority `D-0050`.

The operator-facing bridge artifact for the R7-to-R8 transition is `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md`. It is a narrative operator report artifact only, not milestone proof by itself.

## Exact boundary
This milestone is bounded to:
- one repository only: `AIOffice_V2`
- one active milestone cycle at a time
- one remote-head verification path for the active branch
- one post-push remote-head verification path for the exact landed commit
- one clean or disposable checkout QA replay pinned to the exact remote SHA
- one QA proof packet contract and validator path
- one command-level raw logging discipline across declared commands
- one status-doc gating layer that blocks closeout claims ahead of evidence
- one bounded pilot closeout for R8 itself only
- QA and proof trust substrate work only, not productization

## Exact stop conditions
R8 must refuse or stop if:
- local HEAD is treated as remote repo truth without remote verification
- post-push remote verification is missing for the exact landed SHA
- QA replay does not run from a clean or disposable checkout pinned to the exact remote head
- any declared command lacks raw stdout log, stderr log, or exit-code evidence
- `git rev-parse HEAD`, tree hash, `git status --porcelain`, or `git diff --check` are missing from the QA evidence set
- proof artifacts are not referenced by a validator-backed packet
- status docs claim `done` or `closed` before QA evidence, remote verification, and proof refs exist
- executor self-certification is presented without a separate QA packet
- scope widens beyond one repository, one active milestone cycle, one clean-checkout QA path, one bounded external-proof path, or one narrow R8 pilot closeout

## Required milestone outputs
By the end of `R8`, the milestone must produce:
- one repo-truth milestone document that freezes the remote-gated QA boundary
- one machine-validated QA proof packet contract
- one remote-head verification gate
- one post-push verification gate
- one clean-checkout QA runner pinned to the exact remote SHA
- one hardened proof-package validator that rejects claimed commands without log coverage
- one CI or equivalent external proof runner with concrete artifact identity
- one status-doc gating layer that blocks closeout claims ahead of evidence
- one bounded R8 proof package and closeout path that uses the R8 gate itself

## Preserved non-claims
R8 does not currently prove and must not casually widen into:
- UI or control-room productization
- Standard runtime or subproject runtime
- multi-repo orchestration
- swarms or fleet execution
- broad autonomous milestone execution
- unattended automatic resume
- destructive rollback on the primary working tree
- production-grade general CI for every future workflow
- productized control-room behavior
- a general claim that "Codex is now reliable"

## In scope
- remote branch head verification before completion can be accepted
- post-push remote head verification for the exact landed SHA
- clean or disposable checkout QA replay pinned to the exact remote SHA
- command-level raw stdout or stderr or exit-code capture for declared QA commands
- capture of Git HEAD, tree hash, `git status --porcelain`, and `git diff --check`
- a durable QA proof packet contract plus validation
- proof-package hardening so claimed commands without log refs fail closed
- one CI or external proof execution path for the exact bounded QA flow
- status-doc gating that blocks milestone closeout ahead of QA evidence
- one narrow R8 pilot closeout that proves the gate once

## Explicitly out of scope
- UI or control-room productization
- unified workspace delivery
- Standard or subproject runtime
- multi-repo or fleet orchestration
- swarms or parallel executor expansion
- broad autonomous milestone execution
- unattended automatic resume
- destructive primary-tree rollback
- rollback productization beyond bounded verification and QA gates
- general-purpose CI for every future workflow
- donor backlog import or donor milestone migration

## Dependencies and prerequisites
- `RST-009` through `RST-012` remain complete and externally accepted
- `R3-001` through `R3-008` remain complete in repo truth
- `R4-001` through `R4-011` remain complete in repo truth
- `R5-001` through `R5-007` remain complete and formally closed in repo truth
- `R6 Supervised Milestone Autocycle Pilot` remains honestly closed under `D-0041`
- `R7 Fault-Managed Continuity and Rollback Drill` remains honestly closed under `D-0050`
- the committed R7 proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/` remains the authority for what R7 did and did not prove
- the proof-hardening correction commit `2d51317d9920fc3faa03e5f09331f3026efcc7f8` remains the accepted remote head before R8 opening
- `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md` may be used as operator-facing bridge context only and not as milestone proof
- Git and persisted state remain the authoritative truth substrates
- admin-only posture remains in force unless later repo truth explicitly proves more

## Key risks
- adding QA theater instead of separate QA authority
- accepting local-only completion claims without final remote verification
- treating dirty-worktree executor runs as clean-checkout proof
- adding a workflow without requiring concrete artifact identity for closeout
- letting status docs move ahead of landed evidence again
- turning a narrow proof-trust milestone into broad automation or UI scope creep

## Task list

### `R8-001` Open R8 and freeze the remote-gated QA boundary
- Status: done
- Done when: R8 is open in repo truth, R7 remains closed, no post-R8 milestone is opened, and R8 scope, non-scope, stop conditions, and task order are explicit

### `R8-002` Define QA proof packet contract
- Status: done
- Expected future surfaces:
  - `contracts/qa_proof/qa_proof_packet.contract.json`
  - validation module under `tools/`
  - valid and invalid fixtures
- Done when: the packet requires remote head, tree hash, command list, raw logs, exit codes, environment, dirty or clean status, artifact hashes, QA verdict, and refusal reasons

### `R8-003` Implement remote-head verification gate
- Status: done
- Expected future surfaces:
  - `tools/RemoteHeadVerification.psm1`
  - `tools/verify_remote_branch_head.ps1`
  - focused tests
- Done when: the gate records branch, local HEAD, remote HEAD, commit subject, tree, timestamp, and pass or fail, and refuses mismatch

### `R8-004` Implement post-push verification gate
- Status: done
- Done when: final completion cannot be claimed without a committed or externally published post-push verification artifact and the exact final remote SHA

### `R8-005` Implement clean-checkout QA runner
- Status: done
- Expected future surfaces:
  - `tools/CleanCheckoutQaRunner.psm1`
  - clean checkout runner script
  - raw log output root
- Done when: the runner checks out the exact remote SHA, runs declared commands, captures stdout or stderr or exit codes, and records clean or dirty status before and after

### `R8-006` Harden proof-package validator for complete command logs
- Status: planned
- Done when: any claimed command without raw or support log refs fails validation, including generator, validator, proof-review test, Git hygiene, and remote-head commands

### `R8-007` Add CI or equivalent external proof runner
- Status: planned
- Expected future surfaces:
  - `.github/workflows/r8-clean-checkout-qa.yml`
- Done when: an external runner can execute clean-checkout QA and publish or download or reference artifacts with concrete run identity

### `R8-008` Add status-doc gating
- Status: planned
- Done when: `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, and `governance/DECISION_LOG.md` cannot claim milestone `done` or `closed` without QA packet, remote-head verification, and proof refs, and stale "most recently closed" contradictions fail validation

### `R8-009` Pilot and close R8 narrowly
- Status: planned
- Done when: R8 itself closes only after remote-gated clean-checkout QA passes, with explicit non-claims and no broader automation claim

## Milestone notes
- `R8-001` opens R8 in repo truth as bounded structure only. It does not claim that remote-head gates, post-push verification, clean-checkout QA runners, CI or external proof execution, or status-doc validators are implemented yet.
- `R8-002` adds the QA proof packet contract, validator, and focused fixtures or tests only. It does not yet implement the remote-head gate, post-push verification gate, clean-checkout runner, CI runner, status-doc validator, or R8 closeout packet.
- `R8-003` adds the remote-head verification contract, module, CLI entrypoint, and focused tests only. It does not yet add post-push verification, clean-checkout QA replay, CI or external proof execution, status-doc gating, or R8 closeout proof.
- `R8-004` adds the post-push verification contract, module, CLI entrypoint, and satisfaction check only. It does not yet add clean-checkout QA replay, CI or external proof execution, status-doc gating, or R8 closeout proof.
- `R8-005` adds the disposable clean-checkout QA runner, CLI entrypoint, and focused tests only. It does not yet add CI or external proof execution, status-doc gating, or R8 closeout proof.
- R8 is a QA and proof trust substrate milestone, not productization. The milestone is meant to make completion claims mechanically trustworthy before broader automation is attempted.
- The operator-facing bridge artifact for the R7-to-R8 transition remains `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md`. It is narrative planning input only and must not be treated as milestone proof by itself.
- R8 exists because closed R7 still preserved major cautions: executor-produced evidence remains the main proof source, no independent clean-checkout replay exists, no CI or external-runner final proof artifact exists, no separate QA packet exists, no committed final post-push verification artifact exists in repo truth, and status docs have previously moved ahead of evidence.
- The success condition for R8 is not prettier executor narration. The success condition is that the executor cannot self-certify completion without remote truth, clean-checkout QA evidence, full raw command logs, and validator-backed closeout proof.
