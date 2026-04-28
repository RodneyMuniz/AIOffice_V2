# R10 Two-Phase Final-Head Closeout Support Procedure

## Purpose
R10-007 defines the procedure R10-008 must use later so R10 can close without a self-referential final-head proof claim.

This document is procedure authority only. It does not execute final-head clean replay, does not create a final closeout proof package, does not close R10, and does not open a successor milestone.

## Evidence Already Available
- Successful external runner identity: `state/external_runs/r10_external_proof_bundle/25040949422/external_runner_closeout_identity.json`
- Successful downloaded external proof bundle: `state/external_runs/r10_external_proof_bundle/25040949422/downloaded_artifact/external_proof_artifact_bundle.json`
- External-runner-consuming QA signoff: `state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff.json`

These artifacts are prerequisite evidence for a future R10 closeout attempt. They are not final-head clean replay by themselves.

## Two-Phase Procedure
1. Prepare a candidate R10 closeout commit.
2. Ensure the candidate closeout commit records the successful external proof run identity, passed proof bundle, passed external-runner-consuming QA signoff, status-doc gate evidence, and preserved R10 non-claims.
3. Push the candidate closeout commit to `release/r10-real-external-runner-proof-foundation`.
4. Only after that push, create final-head support evidence that verifies the final closeout head.
5. Publish that final-head support evidence in a follow-up support commit or external artifact identity, not inside the same closeout commit it verifies.
6. Accept the final R10 posture only if the post-push final-head support packet verifies the final closeout head, the status-doc gate passes, no successor milestone is opened, and all R10 non-claims remain preserved.

## Machine-Validated Procedure Packet
The R10-007 procedure packet is:

`state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure.valid.json`

Its validator is:

`tools/validate_r10_two_phase_final_head_support.ps1`

Focused proof is:

`tests/test_r10_two_phase_final_head_support.ps1`

## Required Refusals
R10-008 must refuse closeout if any of these are true:
- missing successful external proof identity
- failed or missing external proof bundle
- missing or failed external-runner-consuming QA signoff
- missing post-push final-head support
- self-referential final-head proof
- status-doc drift
- broad CI/product coverage claim
- R10 closeout claim before support evidence exists

## Non-Claims
- no R10 closeout claim
- no completed final-head clean replay claim
- no broad CI/product coverage claim
- no UI or control-room productization
- no Standard runtime
- no multi-repo orchestration
- no swarms
- no broad autonomous milestone execution
- no unattended automatic resume
- no solved Codex context compaction
- no hours-long unattended milestone execution
- no destructive rollback
- no general Codex reliability
