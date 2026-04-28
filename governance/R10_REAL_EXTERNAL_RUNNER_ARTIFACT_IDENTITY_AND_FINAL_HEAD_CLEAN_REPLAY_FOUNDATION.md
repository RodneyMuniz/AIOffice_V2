# R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation

## Milestone name
`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`

## Why this milestone exists now
R9 is closed narrowly with cautions. It produced useful isolated-QA, final-head support, external-runner limitation, execution-segment, pilot, status-gate, and closeout surfaces, but it did not capture a real external or CI runner artifact identity.

The post-R9 final-head support commit records remote-head support for the R9 closeout head, but it is local remote-query support evidence only. It is not CI proof, not external QA proof, and not a full external final-head replay.

R10 opens only to remove that remaining weakness. It is not UI work, not Standard runtime work, not swarms, not multi-repo orchestration, not broad autonomous milestone execution, not unattended automatic resume, and not a claim that Codex context compaction or hours-long milestone execution is solved.

The operator-facing bridge report `governance/reports/AIOffice_V2_R9_Audit_and_R10_Planning_Report_v2.md` is included as a narrative operator report artifact only. It is not milestone proof by itself.

## Objective
Prove one bounded external-runner evidence loop in which the exact final remote head for the milestone is replayed or verified by a real external runner or CI workflow, with concrete artifact identity, retrievable logs, exact commit/tree identity, and status-doc gating that rejects any external-proof claim without those artifacts.

## Current status
`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` is now closed in repo truth narrowly after `R10-008` Phase 2 post-push final-head support.

`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot` remains the prior closed milestone under `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, the committed proof-review package under `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`, and decision authority `D-0061`.

`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains the prior closed milestone under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review package under `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, and decision authority `D-0053`.

`R10-001` is complete as the repo-truth opening and boundary-freeze step only.

`R10-002` is complete as the closeout-use external-runner identity contract and validator hardening step only.

`R10-003` is complete as the external proof artifact bundle format step only.

`R10-004` is complete as the one external runner path wiring step only.

`R10-005` is complete as one real external runner identity capture.

`R10-008` is complete through the Phase 1 candidate package at `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`, candidate closeout commit `cfebd351922b192585ed5f9d3ca56bee30ea16ae`, and Phase 2 post-push final-head support packet at `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`.

R10-002 hardens the closeout-use validator.

R10-003 defines the external proof artifact bundle format.

R10-004 wires one external runner path.

R10-006 adds external-runner-consuming QA signoff based on successful R10-005G evidence.

R10-007 adds the two-phase final-head closeout support procedure.

Workflow existence is not proof of a successful run.

The failed real run `25032362789` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25032362789` failed before bundle creation because `windows-latest` checkout hit filename-too-long errors. No artifact was uploaded, no R10-005 packet was created, and the run is not accepted R10-005 proof.

R10-004B improves workflow checkout compatibility by moving the external proof workflow to `ubuntu-latest`, using `pwsh`, and keeping artifact upload paths OS-compatible.

R10-005 captured real run ID `25033063285` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25033063285` with artifact `r10-external-proof-bundle-25033063285-1` and retrieval instruction `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6675983991/zip`.

Run `25033063285` completed with conclusion `failure`; it is a real external runner identity capture, but successful external proof was not established by that run.

R10-005A is complete as a corrective support slice for the failed Linux/pwsh external proof bundle validation path. The analysis is `state/external_runs/r10_external_proof_bundle/25033063285/FAILED_VALIDATION_ANALYSIS.md`.

R10-005B captured retry run ID `25034566460` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25034566460` with artifact `r10-external-proof-bundle-25034566460-1` and retrieval instruction `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6676514702/zip`.

Run `25034566460` completed with conclusion `failure`; it uploaded a retrievable artifact and the downloaded bundle validates as a completed non-passing bundle shape, but successful external proof is not established. The failure analysis is `state/external_runs/r10_external_proof_bundle/25034566460/FAILED_RERUN_ANALYSIS.md`.

R10-005C is complete as a corrective support slice for PowerShell Core object-shape and JSON-root preservation in the external proof and closeout identity validators. It does not establish successful external proof; a new external run must pass before R10 can treat external proof as successful.

R10-005D is complete as a corrective support slice for canonical JSON-root reader hardening after failed retry run `25036440624` repeated the same Linux/pwsh root-shape failure class as run `25034566460`. The failed run `25036440624` was not committed as R10 evidence and is not successful external proof.

R10-005F is complete as a corrective support slice for PowerShell Core timestamp string preservation after failed retry run `25037934779` showed that the prior root-shape class was fixed and exposed timestamp coercion for `created_at_utc`, `triggered_at_utc`, and `completed_at_utc`. The failed run `25037934779` was not committed as R10 proof evidence and is not successful external proof.

R10-005G captured successful external proof run ID `25040949422` at `https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25040949422` with artifact `r10-external-proof-bundle-25040949422-1` and retrieval instruction `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip`.

Run `25040949422` completed with status `completed` and conclusion `success`; this is one bounded external runner proof run only, not external QA proof, not final-head clean replay, not broad CI/product coverage, and not R10 closeout.

R10-005G has produced one successful external proof artifact bundle for the tested R10 release branch head.

R10-006 records external-runner-consuming QA signoff at `state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff.json`.

R10 does not claim executed final-head clean replay beyond the Phase 2 remote-head support packet.

R10 is closed narrowly only after Phase 2 support evidence.

The full `R10-001` through `R10-008` sequence is complete only because both the candidate closeout package and post-push final-head support evidence are complete.

The narrow R10 closeout claim is only that one successful bounded external runner proof run exists from R10-005G, one external-runner-consuming QA signoff exists from R10-006, one two-phase final-head support procedure exists from R10-007, one Phase 1 candidate closeout package exists from R10-008, one Phase 2 post-push final-head support packet exists after the candidate push, and no successor milestone is opened.

R10 does not prove solved Codex context compaction.

R10 does not prove unattended automatic resume.

R10 does not prove hours-long unattended milestone execution.

R10 does not prove broad autonomous milestone execution.

Limitation-only external-runner evidence is insufficient for R10 closeout.

## Exact boundary
R10 is bounded to:
- one repository only: `AIOffice_V2`
- one active branch: `release/r10-real-external-runner-proof-foundation`
- one external-runner artifact identity contract suitable for closeout use
- one standard external proof artifact bundle format
- one real GitHub Actions or equivalent external runner path
- one real external run identity packet
- one external-runner-consuming QA signoff path
- one two-phase final-head closeout support procedure
- one Phase 1 candidate closeout package
- one Phase 2 post-push final-head support packet
- one narrow R10 closeout path, now complete only for the bounded evidence chain recorded here

## Critical acceptance rule
R10 must not close on another limitation-only external-runner record.

A limitation-only path was acceptable in R9 because R9 modeled the unavailable external-runner state honestly. R10 must remove that weakness rather than preserve it as the final answer.

## Branch convention
From R10 onward, each release or milestone gets a dedicated release branch.

Pattern: `release/r<release-number>-<short-kebab-milestone-name>`

R10 branch: `release/r10-real-external-runner-proof-foundation`

The previous branch `feature/r5-closeout-remaining-foundations` remains the historical R9 closed/support line and should not be used for new R10+ milestone implementation.

Reports remain narrative operator artifacts, not proof.

Branch truth must be verified before each milestone slice.

## R10 must eventually prove
- one real external or CI runner executes the selected proof commands
- a concrete run ID exists
- a concrete run URL exists
- workflow name/ref exists
- runner identity exists
- artifact name exists
- artifact URL or explicit retrieval instruction exists
- artifact bundle records branch, head SHA, tree SHA, command list, stdout, stderr, exit codes, and verdict
- artifact bundle proves remote branch head equals the tested head
- artifact bundle proves the tested worktree was clean before/after or records exact refusal reasons
- an external-runner-consuming QA signoff exists
- final closeout uses a two-phase support pattern so exact final-head proof is not self-referential
- status docs reject external proof claims unless concrete run identity and artifact refs exist

## Stop conditions
R10 must stop or fail closed if:
- a milestone closeout claim appears before real external run identity exists
- external proof is claimed without concrete run ID, run URL, workflow identity, runner identity, artifact name, and artifact retrieval instruction
- command success is claimed without command logs, stderr, stdout, exit codes, head SHA, tree SHA, and verdict
- final-head support is claimed from the same commit it tries to verify
- a candidate closeout package is treated as final R10 closeout before post-push final-head support exists
- remote branch head equality to the tested head is missing
- clean worktree before/after evidence is missing without exact refusal reasons
- local-only QA is presented as R10 closeout QA
- a limitation-only external-runner record is described as proof
- R10 scope widens into UI, Standard runtime, multi-repo orchestration, swarms, broad autonomous milestone execution, unattended resume, solved context compaction, hours-long execution, destructive rollback, production-grade CI for every workflow, or general Codex reliability

## Required non-claims
R10 does not prove and must not casually widen into:
- no UI or control-room productization
- no Standard runtime
- no multi-repo orchestration
- no swarms or fleet execution
- no broad autonomous milestone execution
- no unattended automatic resume
- no solved Codex context compaction
- no hours-long unattended milestone execution
- no destructive rollback
- no production-grade CI for every workflow
- no general Codex reliability
- no broad segmented milestone execution beyond the external-runner proof loop

## Task list

### `R10-001` Open R10 narrowly and freeze boundary
- Status: done
- Done when: R10 is active in repo truth, R9 remains most recently closed, R10 scope is external-runner artifact identity plus exact final-head clean replay only, and limitation-only external-runner evidence is explicitly insufficient for R10 closeout.

### `R10-002` Harden external-runner artifact identity contract for closeout use
- Status: done
- Done when: validation rejects empty/synthetic run identity, missing workflow identity, missing artifact identity, missing exact head/tree, success without command logs, success without final-head support evidence, and unavailable limitation described as proof.
- Durable output: `contracts/external_runner_artifact/external_runner_closeout_identity.contract.json`, `tools/ExternalRunnerArtifactIdentity.psm1`, `tools/validate_external_runner_closeout_identity.ps1`, `state/fixtures/valid/external_runner_artifact/r10_closeout_identity.valid.json`, `state/fixtures/valid/external_runner_artifact/r10_closeout_artifacts/`, and `tests/test_external_runner_closeout_identity.ps1`.

### `R10-003` Build the external proof artifact bundle format
- Status: done
- Done when: a standard bundle format exists for repository, branch, triggering ref, runner identity, run ID/URL, artifact identity, remote/tested head/tree, clean status, command manifest, logs, exit codes, verdict, refusal reasons, and non-claims.
- Durable output: `contracts/external_proof_bundle/foundation.contract.json`, `contracts/external_proof_bundle/external_proof_artifact_bundle.contract.json`, `tools/ExternalProofArtifactBundle.psm1`, `tools/validate_external_proof_artifact_bundle.ps1`, `state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle.valid.json`, `state/fixtures/valid/external_proof_bundle/artifacts/`, and `tests/test_external_proof_artifact_bundle.ps1`.

### `R10-004` Wire one GitHub Actions or equivalent runner path
- Status: done
- Done when: one real external runner path can be triggered on the R10 release branch or controlled dispatch, runs a focused proof set, uploads a standard artifact bundle, and does not claim broad CI/product coverage.
- Durable output: `.github/workflows/r10-external-proof-bundle.yml`, `tools/invoke_r10_external_proof_bundle.ps1`, and `tests/test_r10_external_proof_workflow.ps1`.
- Corrective support: `R10-004B` records checkout compatibility hardening after failed run `25032362789`; the failure analysis is `state/external_runs/r10_external_proof_bundle/25032362789/FAILED_RUN_ANALYSIS.md` and is not accepted R10-005 proof.

### `R10-005` Capture one real external run identity
- Status: done
- Done when: a committed packet contains real run ID, run URL, workflow name/ref, runner identity, artifact name, artifact retrieval instruction, head SHA, tree SHA, branch, run status, conclusion, QA/evidence refs, and non-claims.
- Durable output: initial failed run evidence under `state/external_runs/r10_external_proof_bundle/25033063285/`, failed retry evidence under `state/external_runs/r10_external_proof_bundle/25034566460/`, and successful bounded external proof evidence under `state/external_runs/r10_external_proof_bundle/25040949422/`.
- Initial result: run `25033063285` completed with conclusion `failure`; this captured one real external runner identity and artifact reference, but it was not successful external proof.
- Corrective support: `R10-005A` fixes Linux/pwsh external proof bundle validation and relative artifact-ref handling after failed run `25033063285`; the failure analysis is `state/external_runs/r10_external_proof_bundle/25033063285/FAILED_VALIDATION_ANALYSIS.md`. At that point, R10 remained active through `R10-005` only.
- Retry support: `R10-005B` records failed retry run `25034566460` with artifact `r10-external-proof-bundle-25034566460-1`, committed identity packet `state/external_runs/r10_external_proof_bundle/25034566460/external_runner_closeout_identity.json`, downloaded artifact contents, and failure analysis `state/external_runs/r10_external_proof_bundle/25034566460/FAILED_RERUN_ANALYSIS.md`. The retry is not successful external proof.
- Corrective support: `R10-005C` hardens PowerShell Core object-shape handling so JSON roots are preserved as single `PSCustomObject` values and array/property-stream roots fail closed. It does not establish successful external proof.
- Corrective support: `R10-005D` adds the canonical `tools/JsonRoot.psm1` reader and routes the external proof and closeout identity validators/tests through it so raw array roots fail before field validation. Failed run `25036440624` repeated the prior root-shape failure class and was not committed as R10 evidence. At that point, successful external proof remained unestablished.
- Corrective support: `R10-005F` preserves JSON timestamp fields as strings under PowerShell Core through the canonical reader. Failed run `25037934779` exposed the timestamp coercion issue after the array-root failure path was corrected; the failed run was not committed as R10 proof evidence. At that point, successful external proof remained unestablished.
- Retry support: `R10-005G` records successful GitHub Actions run `25040949422`, artifact `r10-external-proof-bundle-25040949422-1`, identity packet `state/external_runs/r10_external_proof_bundle/25040949422/external_runner_closeout_identity.json`, downloaded artifact contents, run metadata, and artifact retrieval instruction `https://api.github.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip`. This is one bounded external runner proof run only; before R10-006 it had not produced external-runner-consuming QA signoff, and it did not perform final-head clean replay or close R10.

### `R10-006` Add external-runner-consuming QA signoff
- Status: done
- Done when: QA signoff validation rejects local-only QA for R10 closeout, executor-only evidence, missing external run packet, missing artifact retrieval instruction, missing final-head support ref, and external-runner limitation presented as QA proof.
- Durable output: `contracts/isolated_qa/external_runner_consuming_qa_signoff.contract.json`, `tools/ExternalRunnerConsumingQaSignoff.psm1`, `tools/validate_external_runner_consuming_qa_signoff.ps1`, `state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff.json`, and `tests/test_external_runner_consuming_qa_signoff.ps1`.

### `R10-007` Add two-phase final-head closeout support procedure
- Status: done
- Done when: the repo distinguishes candidate closeout commit, external run identity, final-head support commit, and final accepted R10 posture.
- Durable output: `governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE.md`, `contracts/post_push_support/r10_two_phase_final_head_closeout_procedure.contract.json`, `tools/R10TwoPhaseFinalHeadSupport.psm1`, `tools/validate_r10_two_phase_final_head_support.ps1`, `state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure.valid.json`, and `tests/test_r10_two_phase_final_head_support.ps1`.

### `R10-008` Close R10 only with real external final-head proof
- Status: done
- Done when: R10 proof package exists, real external run identity exists, external artifact bundle is referenced and retrievable, final-head support packet exists after push, status-doc gate passes, non-claims are preserved, and no successor milestone is opened.
- Phase 1 candidate output: `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/`.
- Phase 2 support output: `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`.
- Candidate closeout commit: `cfebd351922b192585ed5f9d3ca56bee30ea16ae`.
- Phase 2 boundary: R10 closes narrowly only after the pushed candidate closeout commit is verified as the remote branch head by the Phase 2 support packet.

## Milestone notes
- `R10-001` opens R10 in repo truth only. It does not implement external-runner proof, real CI, external QA, artifact-bundle validation, final-head replay, or R10 closeout.
- `R10-002` hardens the closeout-facing external-runner identity contract without treating unavailable runner state, synthetic run identity, missing workflow identity, missing artifact identity, missing command logs, missing QA/evidence refs, missing final-head support evidence, old R9 limitation evidence, or broad CI/product coverage language as R10 closeout proof.
- `R10-002` includes a validator-only fixture for contract shape testing. That fixture is not a real external runner capture and is not R10 proof.
- `R10-003` defines the bundle shape before a future runner result can be accepted as closeout evidence. Its validator-only fixture is not a real external runner capture, not CI proof, not external QA proof, and not R10 closeout proof.
- `R10-004` wires one external runner path through a controlled GitHub Actions workflow and runner script. Workflow existence alone is not proof of a successful run.
- `R10-004B` moves the workflow to `ubuntu-latest` with `pwsh` after failed run `25032362789` proved the Windows checkout path could hit filename-too-long errors before bundle creation. That failed run uploaded no artifact, created no R10-005 packet, and is not accepted as R10-005 proof.
- `R10-005` captures real GitHub Actions run `25033063285` and artifact `r10-external-proof-bundle-25033063285-1` as a completed failed external runner identity. This is not successful external proof, not external QA proof, not final-head clean replay, and not R10 closeout.
- `R10-005A` corrects the Linux/pwsh validation and artifact-ref handling failure exposed by run `25033063285`. It does not create a new identity packet and does not establish successful external proof.
- `R10-005B` captures retry run `25034566460` and artifact `r10-external-proof-bundle-25034566460-1` as completed failed external runner evidence after R10-005A. The bundle records matching remote and tested heads and a failed aggregate verdict, so it is diagnostic failure evidence only, not successful external proof.
- `R10-005C` corrects PowerShell Core JSON-root preservation and object-shape handling for the external proof and closeout identity validators. It does not implement R10-006, does not create successful external proof, and does not close R10.
- `R10-005D` corrects the remaining JSON-root reader path by using one canonical fail-closed root reader for the external proof and closeout identity validators/tests. It does not retry the external workflow, does not implement R10-006, does not create successful external proof, and does not close R10.
- `R10-005F` corrects PowerShell Core timestamp string preservation in the canonical JSON-root reader. It does not retry the external workflow, does not implement R10-006, does not create successful external proof, and does not close R10.
- `R10-005G` captures successful GitHub Actions run `25040949422` and artifact `r10-external-proof-bundle-25040949422-1` as one bounded external runner proof run. By itself, it did not implement R10-006, did not produce external-runner-consuming QA signoff, did not perform final-head clean replay, did not close R10, and did not prove broad CI/product coverage.
- `R10-006` adds external-runner-consuming QA signoff based on successful R10-005G evidence and ensures R10 closeout QA consumes real external-runner artifacts rather than local-only executor evidence.
- `R10-007` defines the two-phase final-head closeout support procedure so R10-008 can avoid self-referential final-head proof.
- `R10-008` has a Phase 1 candidate closeout package under `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/` and a Phase 2 post-push final-head support packet under `state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json`. It closes R10 narrowly only because the support packet verifies pushed candidate closeout head `cfebd351922b192585ed5f9d3ca56bee30ea16ae`, all non-claims are preserved, and no successor milestone opens.
