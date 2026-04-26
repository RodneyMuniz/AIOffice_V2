# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`

Current posture:
`R9` is now active in repo truth through `R9-006` only. `R9-006` is complete through one tiny bounded segmented control-path pilot under `state/pilots/r9_tiny_segmented_milestone_pilot/` with focused proof through `tests/test_r9_tiny_segmented_pilot.ps1`. No concrete CI or external runner artifact identity is claimed, because R9-004 landed only the limitation path. `R9-007` remains planned only. R9 still does not close, does not prove real external or CI runner artifact identity, does not solve Codex context compaction, does not prove hours-long unattended milestone execution, does not prove unattended automatic resume, and does not prove broad autonomous milestone execution. R9-003 defines the final-head support model only and does not produce the final R9 closeout support packet yet.

## Most Recently Closed Milestone
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`

Closeout summary:
`R8-001` through `R8-009` are complete and formally closed in repo truth. The closeout authority is `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, the QA proof packet is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/clean_checkout_qa/qa_proof_packet.json`, the starting remote-head verification artifact is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/remote_head_verification/remote_head_verification_starting_head.json`, the starting remote head is `e27464278c2fb29cc3269b562019784124451288`, and decision authority is `D-0053`. This closeout remains bounded to one remote-gated QA/proof trust substrate for one repository and one active milestone cycle only.

Prior closed milestone:
`R7 Fault-Managed Continuity and Rollback Drill` remains honestly closed under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, and decision authority `D-0050`.

## Tasks

### `R9-001` Open R9 and freeze boundary
- Status: done
- Order: 1
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: post-R8 correction commit `4140780c08c90af03d398644050682de42ee0b1d`, `D-0053`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: repo-truth surfaces that open R9 narrowly and freeze the boundary
- Done when: R9 opens only after the post-R8 correction, R8 remains the most recently closed milestone, R9 scope is isolated QA plus continuity-managed execution pilot only, and UI, Standard runtime, swarms, multi-repo behavior, broad autonomy, and unattended execution are explicitly excluded

### `R9-002` Define isolated QA role and signoff packet
- Status: done
- Order: 2
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-001`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/isolated_qa/foundation.contract.json`, `contracts/isolated_qa/qa_signoff_packet.contract.json`, `tools/IsolatedQaSignoff.psm1`, `tools/validate_isolated_qa_signoff.ps1`, `state/fixtures/valid/isolated_qa/qa_signoff_packet.valid.json`, and `tests/test_isolated_qa_signoff.ps1`
- Done when: QA signoff consumes executor evidence and remote or clean-checkout artifacts, records `qa_role_identity`, `qa_runner_kind`, `qa_authority_type`, `source_artifacts`, `verdict`, `refusal_reasons`, and `independence_boundary`, and fails closed if executor self-certification is presented as QA authority, if separate QA role or runner identity is missing, if executor evidence is the only source artifact, if required remote-head or clean-checkout/external QA refs are missing, or if the independence boundary says the same executor produced and approved the signoff

### `R9-003` Define exact-final post-push verification support model
- Status: done
- Order: 3
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-002`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/post_push_support/foundation.contract.json`, `contracts/post_push_support/final_remote_head_support_packet.contract.json`, `tools/FinalRemoteHeadSupport.psm1`, `tools/validate_final_remote_head_support.ps1`, `state/fixtures/valid/post_push_support/final_remote_head_support_packet.valid.json`, and `tests/test_final_remote_head_support.ps1`
- Done when: final-head support evidence is distinguished from the milestone closeout commit itself, `verification_timing` is `after_closeout_push`, follow-up support commit or external artifact publication is allowed without pretending same-commit proof exists, and self-referential proof, empty evidence refs, invalid status/refusal combinations, missing non-claims, or CI/external claims without run identity fail closed

### `R9-004` Capture real external or CI runner artifact identity
- Status: done
- Order: 4
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-003`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/external_runner_artifact/foundation.contract.json`, `contracts/external_runner_artifact/external_runner_artifact_identity.contract.json`, `tools/ExternalRunnerArtifactIdentity.psm1`, `tools/validate_external_runner_artifact_identity.ps1`, `state/fixtures/valid/external_runner_artifact/external_runner_limitation.valid.json`, and `tests/test_external_runner_artifact_identity.ps1`
- Done when: the external-runner identity contract and validator fail closed on missing run or artifact identity for completed or successful runs, GitHub Actions run URLs must be concrete, success requires QA and remote-head evidence refs, required non-claims are present, and this environment records an explicit unavailable limitation without faking run identity or describing the limitation as proof

### `R9-005` Add continuity-managed execution segment model
- Status: done
- Order: 5
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-004`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `contracts/execution_segments/foundation.contract.json`, `contracts/execution_segments/execution_segment_dispatch.contract.json`, `contracts/execution_segments/execution_segment_checkpoint.contract.json`, `contracts/execution_segments/execution_segment_result.contract.json`, `contracts/execution_segments/execution_segment_resume_request.contract.json`, `contracts/execution_segments/execution_segment_handoff.contract.json`, `tools/ExecutionSegmentContinuity.psm1`, `tools/validate_execution_segment_artifact.ps1`, `state/fixtures/valid/execution_segments/`, and `tests/test_execution_segment_continuity.ps1`
- Done when: `execution_segment_dispatch`, `execution_segment_checkpoint`, `execution_segment_result`, `execution_segment_resume_request`, and `execution_segment_handoff` artifacts validate as a bounded restartable segment model; each segment declares a context budget and allowed scope; checkpoints, results, resume requests, and handoffs resolve from durable repo artifacts rather than chat memory; and the focused tests pass without claiming the R9-006 pilot, unattended resume, solved compaction, or hours-long unattended execution

### `R9-006` Pilot one tiny milestone through segmented execution
- Status: done
- Order: 6
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-005`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`
- Durable output: `state/pilots/r9_tiny_segmented_milestone_pilot/` and `tests/test_r9_tiny_segmented_pilot.ps1`
- Done when: the pilot runs request, plan, approve or freeze, segment dispatch, Codex execution evidence, isolated QA, audit summary, and operator decision without claiming full autonomous milestone execution, external or CI proof, solved Codex context compaction, unattended automatic resume, or hours-long unattended processing

### `R9-007` Close R9 narrowly
- Status: planned
- Order: 7
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-006`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, `governance/DECISION_LOG.md`
- Durable output: one narrow R9 closeout package
- Done when: isolated QA signoff exists, exact final remote-head verification support exists, clean or external QA evidence exists or a limitation is explicitly recorded, status-doc gate passes, no self-certification is accepted, continuity segment artifacts prove resume-from-state is possible, and all non-claims are preserved

## Closed R8 Task Record

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
- Status: done
- Order: 8
- Milestone: `R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`
- Depends on: `R8-007`
- Authority: `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`
- Durable output: one status-doc gating layer across `README.md`, `governance/ACTIVE_STATE.md`, `execution/KANBAN.md`, and `governance/DECISION_LOG.md`
- Done when: status docs cannot claim milestone `done` or `closed` without QA packet, remote-head verification, and proof refs, and stale "most recently closed" contradictions fail validation

### `R8-009` Pilot and close R8 narrowly
- Status: done
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
- claiming Codex context compaction is solved
- claiming hours-long milestones can now run unattended
