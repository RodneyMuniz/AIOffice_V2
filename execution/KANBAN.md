# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`

Current posture:
`R8` is now active in repo truth as a bounded QA and proof trust milestone. `R8-001` is complete through the milestone-open and registration step. `R8-002` is complete through the durable QA proof packet contract, validator, fixture, and focused test surfaces under `contracts/qa_proof/`, `tools/QaProofPacket.psm1`, `tools/validate_qa_proof_packet.ps1`, `state/fixtures/valid/qa_proof/`, and `tests/test_qa_proof_packet.ps1`. `R8-003` is complete through the remote-head verification contract, module, CLI entrypoint, and focused tests under `contracts/qa_proof/remote_head_verification.contract.json`, `tools/RemoteHeadVerification.psm1`, `tools/verify_remote_branch_head.ps1`, and `tests/test_remote_head_verification.ps1`. `R8-004` is complete through the post-push verification contract, module, CLI entrypoint, and satisfaction check under `contracts/qa_proof/post_push_verification.contract.json`, `tools/PostPushVerification.psm1`, `tools/verify_post_push_remote_head.ps1`, and `tests/test_post_push_verification.ps1`. `R8-005` is complete through the disposable clean-checkout QA runner, CLI entrypoint, and focused tests under `tools/CleanCheckoutQaRunner.psm1`, `tools/invoke_clean_checkout_qa.ps1`, and `tests/test_clean_checkout_qa_runner.ps1`. `R8-006` is complete through stricter claimed-command log coverage validation under `contracts/qa_proof/`, `tools/QaProofPacket.psm1`, and `tests/test_qa_proof_packet.ps1`. `R8-007` is complete through the external proof runner foundation at `.github/workflows/r8-clean-checkout-qa.yml`, the focused foundation validation at `tests/test_r8_external_proof_runner_foundation.ps1`, and uploaded-artifact run-identity capture for later closeout reference. `R8-008` through `R8-009` are planned only. `R7 Fault-Managed Continuity and Rollback Drill` remains the most recently closed milestone under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, and decision authority `D-0050`. The operator-facing bridge artifact for the R7-to-R8 transition is `governance/reports/AIOffice_V2_R7_Audit_and_R8_Planning_Report_v1.md`. It is a narrative operator report artifact only, not milestone proof by itself. R8 exists because R7 still left no independent clean-checkout QA, no CI or external final proof artifact, no separate QA signoff packet, and no committed final post-push verification artifact in repo truth.

## Most Recently Closed Milestone
`R7 Fault-Managed Continuity and Rollback Drill`

Closeout summary:
`R7-001` through `R7-009` are complete and formally closed in repo truth. The closeout authority is `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis is `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/` at replay source head `fce96fb35c3d1ff8d2676d470ccfe81ae3cb6905` and replay source tree `3b55d697b6206a62967800cd78bc4f3b39b99858`, and decision authority is `D-0050`. That package records exact replay commands, raw replay logs, summary artifacts, exact proof selection scope, replay-source metadata, authoritative artifact refs for `R7-002` through `R7-008`, one bounded closeout packet, and explicit non-claims for the exact interrupted-and-resumed supervised continuity chain plus one safe disposable-worktree rollback drill packet only. This closeout remains bounded and does not add unattended automatic resume, destructive primary-tree rollback, broader rollback productization, UI, Standard runtime, multi-repo behavior, swarms, or broader orchestration claims.

## Tasks

### `R8-001` Open R8 and freeze the remote-gated QA boundary
- Status: done
- Order: 1
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, `D-0050`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: updated repo-truth surfaces that open R8 as planning only and freeze the exact remote-gated QA boundary
- Done when: R8 is open in repo truth, R7 remains honestly closed, no post-R8 milestone is opened, and scope or non-scope or stop conditions are explicit

### `R8-002` Define QA proof packet contract
- Status: done
- Order: 2
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-001`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one durable machine-validated QA proof packet contract plus future validation surfaces
- Done when: the packet requires remote head, tree hash, command list, raw logs, exit codes, environment, dirty or clean status, artifact hashes, QA verdict, and refusal reasons

### `R8-003` Implement remote-head verification gate
- Status: done
- Order: 3
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-002`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one gate that records branch, local head, remote head, commit subject, tree, timestamp, and pass or fail for remote branch truth
- Done when: local-only completion claims fail closed on local or remote mismatch

### `R8-004` Implement post-push verification gate
- Status: done
- Order: 4
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-003`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one final remote-head verification artifact path that proves the exact landed SHA after push
- Done when: completion cannot be claimed without post-push verification for the exact final remote SHA

### `R8-005` Implement clean-checkout QA runner
- Status: done
- Order: 5
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-004`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one clean or disposable checkout QA runner pinned to the exact remote SHA, with raw log output root
- Done when: the runner checks out the exact remote head, runs declared commands, captures stdout or stderr or exit codes, and records clean or dirty status before and after

### `R8-006` Harden proof-package validator for complete command logs
- Status: done
- Order: 6
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-005`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one proof-validator hardening layer that rejects claimed commands without raw or support log coverage
- Done when: generator, validator, proof-review test, Git hygiene, remote-head, and QA runner commands all fail closed if coverage is missing

### `R8-007` Add CI or equivalent external proof runner
- Status: done
- Order: 7
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-006`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one external proof execution path with concrete artifact identity
- Done when: CI or equivalent external execution can run the clean-checkout QA flow and publish or reference artifacts with concrete run identity

### `R8-008` Add status-doc gating
- Status: planned
- Order: 8
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-007`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one status-doc gating layer across `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, and `governance/DECISION_LOG.md`
- Done when: status docs cannot claim milestone `done` or `closed` without QA packet, remote-head verification, and proof refs, and stale "most recently closed" contradictions fail validation

### `R8-009` Pilot and close R8 narrowly
- Status: planned
- Order: 9
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-008`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, `governance/DECISION_LOG.md`
- Durable output: one bounded R8 closeout path that uses the remote-gated QA process on itself
- Done when: R8 closes only after remote-gated clean-checkout QA passes, explicit non-claims remain intact, and no broader automation claim is made

## Explicitly Out Of Scope For This Milestone
- UI or control-room productization
- Standard runtime
- multi-repo orchestration
- swarms
- broad autonomous milestone execution
- unattended automatic resume
- destructive rollback on the primary working tree
- production-grade general CI for every future workflow
- productized control-room behavior
- general "Codex is now reliable" claims
