# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`

Current posture:
`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` is active through `R10-005` only. `R10-006` through `R10-008` remain planned only. `R10-004` wires one external runner path, and `R10-004B` improves workflow checkout compatibility after failed run `25032362789`, but workflow existence and failed-run analysis are not proof of a successful run. `R10-005` captures real GitHub Actions run `25033063285` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25033063285` with artifact `r10-external-proof-bundle-25033063285-1`; the run conclusion is `failure`, so successful external proof is not established. `R10-005A` corrects the Linux/pwsh validation and relative artifact-ref handling failure from that run without creating a new identity packet. `R10-005B` captures retry run `25034566460` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25034566460` with artifact `r10-external-proof-bundle-25034566460-1`; the run also concluded `failure`, so it is diagnostic failure evidence only. `R10-005C` corrects PowerShell Core JSON-root/object-shape handling in the validators. `R10-005D` hardens the canonical JSON-root reader after failed run `25036440624` repeated the same Linux/pwsh root-shape failure class; that failed run was not committed as R10 proof evidence. `R10-005F` preserves timestamp strings in the canonical reader after failed run `25037934779` exposed timestamp coercion; that failed run was not committed as R10 proof evidence. Successful external proof is still not established until a new external run passes. R10 still has not produced external QA proof, has not performed final-head clean replay, does not prove solved Codex context compaction, does not prove unattended automatic resume, does not prove hours-long unattended milestone execution, does not prove broad autonomous milestone execution, and does not prove broad CI/product coverage. Limitation-only external-runner evidence is insufficient for R10 closeout.

Active branch:
`release/r10-real-external-runner-proof-foundation`

Previous branch:
`feature/r5-closeout-remaining-foundations` remains the historical R9 closed/support line and should not be used for new R10+ milestone implementation.

## Most Recently Closed Milestone
`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`

Closeout summary:
`R9-001` through `R9-007` are complete and formally closed in repo truth. The closeout authority is `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, the committed proof-review basis is `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`, the R9-006 pilot package is `state/pilots/r9_tiny_segmented_milestone_pilot/`, and decision authority is `D-0061`. This closeout remains bounded to one isolated-QA and continuity-managed segmented execution pilot for one repository and one tiny pilot path only.

Prior closed milestone:
`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains honestly closed under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis under `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, and decision authority `D-0053`.

R8 closeout summary:
`R8-001` through `R8-009` are complete and formally closed in repo truth. The closeout authority is `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, the QA proof packet is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/clean_checkout_qa/qa_proof_packet.json`, the starting remote-head verification artifact is `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/artifacts/remote_head_verification/remote_head_verification_starting_head.json`, the starting remote head is `e27464278c2fb29cc3269b562019784124451288`, and decision authority is `D-0053`. This closeout remains bounded to one remote-gated QA/proof trust substrate for one repository and one active milestone cycle only.

Earlier closed milestone:
`R7 Fault-Managed Continuity and Rollback Drill` remains honestly closed under `governance/R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md`, the committed proof-review basis under `state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill/`, and decision authority `D-0050`.

## Tasks

### `R10-001` Open R10 narrowly and freeze boundary
- Status: done
- Order: 1
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: post-R9 final-head support commit `3c225f863add07f64a9026661d9465d02024a83d`, `D-0061`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: repo-truth surfaces that open R10 narrowly and freeze the boundary
- Done when: R10 is active in repo truth, R9 remains most recently closed, R10 scope is external-runner artifact identity plus exact final-head clean replay only, and limitation-only external-runner evidence is explicitly insufficient for R10 closeout

### `R10-002` Harden external-runner artifact identity contract for closeout use
- Status: done
- Order: 2
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-001`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `contracts/external_runner_artifact/external_runner_closeout_identity.contract.json`, `tools/ExternalRunnerArtifactIdentity.psm1`, `tools/validate_external_runner_closeout_identity.ps1`, `tests/test_external_runner_closeout_identity.ps1`
- Durable output: closeout-facing external-runner identity validation hardening plus validator-only shape fixture under `state/fixtures/valid/external_runner_artifact/r10_closeout_identity.valid.json`
- Done when: validation rejects empty/synthetic run identity, missing workflow identity, missing artifact identity, missing exact head/tree, success without command logs, success without final-head support evidence, and unavailable limitation described as proof

### `R10-003` Build the external proof artifact bundle format
- Status: done
- Order: 3
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-002`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `contracts/external_proof_bundle/foundation.contract.json`, `contracts/external_proof_bundle/external_proof_artifact_bundle.contract.json`, `tools/ExternalProofArtifactBundle.psm1`, `tools/validate_external_proof_artifact_bundle.ps1`, `tests/test_external_proof_artifact_bundle.ps1`
- Durable output: standard external proof artifact bundle format plus validator-only shape fixture under `state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle.valid.json`
- Done when: a standard bundle format exists for repository, branch, triggering ref, runner identity, run ID/URL, artifact identity, remote/tested head/tree, clean status, command manifest, logs, exit codes, verdict, refusal reasons, and non-claims

### `R10-004` Wire one GitHub Actions or equivalent runner path
- Status: done
- Order: 4
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-003`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `.github/workflows/r10-external-proof-bundle.yml`, `tools/invoke_r10_external_proof_bundle.ps1`, `tests/test_r10_external_proof_workflow.ps1`
- Durable output: one focused external runner path with controlled workflow dispatch, focused command capture, bundle validation, artifact upload wiring, and R10-004B checkout compatibility hardening for `ubuntu-latest` plus `pwsh`
- Done when: one real external runner path can be triggered on the R10 release branch or controlled dispatch, runs a focused proof set, uploads a standard artifact bundle, and does not claim broad CI/product coverage
- Corrective support: failed run `25032362789` is recorded only as failure analysis at `state/external_runs/r10_external_proof_bundle/25032362789/FAILED_RUN_ANALYSIS.md`; it is not accepted R10-005 proof.

### `R10-005` Capture one real external run identity
- Status: done
- Order: 5
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-004`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: `state/external_runs/r10_external_proof_bundle/25033063285/external_runner_closeout_identity.json`, `state/external_runs/r10_external_proof_bundle/25033063285/RUN_IDENTITY_SUMMARY.md`, `state/external_runs/r10_external_proof_bundle/25033063285/artifact_retrieval_instructions.md`, `state/external_runs/r10_external_proof_bundle/25033063285/raw_logs/`, and `state/external_runs/r10_external_proof_bundle/25033063285/downloaded_artifact/`
- Done when: a committed packet contains real run ID, run URL, workflow name/ref, runner identity, artifact name, artifact retrieval instruction, head SHA, tree SHA, branch, run status, conclusion, QA/evidence refs, and non-claims
- Result: real run `25033063285` completed with conclusion `failure`; the artifact is retrievable, but successful external proof is not established.
- Corrective support: `R10-005A` records failed validation analysis at `state/external_runs/r10_external_proof_bundle/25033063285/FAILED_VALIDATION_ANALYSIS.md` and fixes the Linux/pwsh external proof bundle validation path without advancing R10 beyond `R10-005`.
- Retry support: `R10-005B` records failed retry run `25034566460`, artifact `r10-external-proof-bundle-25034566460-1`, identity packet `state/external_runs/r10_external_proof_bundle/25034566460/external_runner_closeout_identity.json`, downloaded artifact contents, and analysis `state/external_runs/r10_external_proof_bundle/25034566460/FAILED_RERUN_ANALYSIS.md`. The retry is not successful external proof, so `R10-006` remains planned only.
- Corrective support: `R10-005C` hardens PowerShell Core JSON-root and object-shape handling in the external proof and closeout identity validators. It does not establish successful external proof; a new external run must pass before `R10-006`.
- Corrective support: `R10-005D` adds the canonical fail-closed JSON-root reader under `tools/JsonRoot.psm1` and routes the external proof and closeout identity validators/tests through it. Failed run `25036440624` repeated the same root-shape failure class and was not committed as R10 proof evidence. R10 remains active through `R10-005` only.
- Corrective support: `R10-005F` preserves timestamp strings under PowerShell Core in the canonical JSON-root reader. Failed run `25037934779` exposed timestamp coercion after the array-root path was corrected, and it was not committed as R10 proof evidence. R10 remains active through `R10-005` only.

### `R10-006` Add external-runner-consuming QA signoff
- Status: planned
- Order: 6
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-005`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: QA signoff validation tied to real external runner artifacts
- Done when: QA signoff validation rejects local-only QA for R10 closeout, executor-only evidence, missing external run packet, missing artifact retrieval instruction, missing final-head support ref, and external-runner limitation presented as QA proof

### `R10-007` Add two-phase final-head closeout support procedure
- Status: planned
- Order: 7
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-006`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`
- Durable output: non-self-referential final-head closeout support procedure
- Done when: the repo distinguishes candidate closeout commit, external run identity, final-head support commit, and final accepted R10 posture

### `R10-008` Close R10 only with real external final-head proof
- Status: planned
- Order: 8
- Milestone: `R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`
- Depends on: `R10-007`
- Authority: `governance/R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md`, `governance/DECISION_LOG.md`
- Durable output: future R10 proof package only if real external final-head proof exists
- Done when: R10 proof package exists, real external run identity exists, external artifact bundle is referenced and retrievable, final-head support packet exists after push, status-doc gate passes, non-claims are preserved, and no successor milestone is opened

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
- Status: done
- Order: 7
- Milestone: `R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`
- Depends on: `R9-006`
- Authority: `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, `governance/DECISION_LOG.md`
- Durable output: `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`
- Done when: isolated QA signoff exists, final remote-head support model exists, local QA evidence exists, external/CI runner identity limitation is explicitly recorded, status-doc gate passes, no self-certification is accepted, continuity segment artifacts prove the one tiny pilot can resume from durable repo-state refs, and all non-claims are preserved

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
- solved Codex context compaction
- hours-long unattended milestone execution
- destructive rollback on the primary working tree
- production-grade general CI for every future workflow
- productized control-room behavior
- general "Codex is now reliable" claims
- claiming Codex context compaction is solved
- claiming hours-long milestones can now run unattended
- closing R10 on limitation-only external-runner evidence
- using `feature/r5-closeout-remaining-foundations` for new R10+ milestone implementation
