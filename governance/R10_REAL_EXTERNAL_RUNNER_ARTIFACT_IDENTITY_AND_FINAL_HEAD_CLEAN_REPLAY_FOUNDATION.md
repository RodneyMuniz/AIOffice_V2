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
`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation` is now active in repo truth through `R10-002` only.

`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot` remains the most recently closed milestone under `governance/R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md`, the committed proof-review package under `state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/`, and decision authority `D-0061`.

`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains the prior closed milestone under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review package under `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, and decision authority `D-0053`.

`R10-001` is complete as the repo-truth opening and boundary-freeze step only.

`R10-002` is complete as the closeout-use external-runner identity contract and validator hardening step only.

`R10-003` through `R10-008` remain planned only.

R10-002 hardens the closeout-use validator.

R10 still has not captured a real external runner identity.

R10 still has not triggered CI.

R10 still has not produced an external artifact bundle.

R10 still has not produced external QA proof.

R10 still has not performed final-head clean replay.

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
- one narrow R10 closeout path, later, only if real external final-head proof exists

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
- remote branch head equality to the tested head is missing
- clean worktree before/after evidence is missing without exact refusal reasons
- local-only QA is presented as R10 closeout QA
- a limitation-only external-runner record is described as proof
- R10 scope widens into UI, Standard runtime, multi-repo orchestration, swarms, broad autonomous milestone execution, unattended resume, solved context compaction, hours-long execution, destructive rollback, production-grade CI for every workflow, or general Codex reliability

## Required non-claims
R10 does not currently prove and must not casually widen into:
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
- Status: planned
- Done when: a standard bundle format exists for repository, branch, triggering ref, runner identity, run ID/URL, artifact identity, remote/tested head/tree, clean status, command manifest, logs, exit codes, verdict, refusal reasons, and non-claims.

### `R10-004` Wire one GitHub Actions or equivalent runner path
- Status: planned
- Done when: one real external runner path can be triggered on the R10 release branch or controlled dispatch, runs a focused proof set, uploads a standard artifact bundle, and does not claim broad CI/product coverage.

### `R10-005` Capture one real external run identity
- Status: planned
- Done when: a committed packet contains real run ID, run URL, workflow name/ref, runner identity, artifact name, artifact retrieval instruction, head SHA, tree SHA, branch, run status, conclusion, QA/evidence refs, and non-claims.
- This task is not complete if the packet says only `unavailable`.

### `R10-006` Add external-runner-consuming QA signoff
- Status: planned
- Done when: QA signoff validation rejects local-only QA for R10 closeout, executor-only evidence, missing external run packet, missing artifact retrieval instruction, missing final-head support ref, and external-runner limitation presented as QA proof.

### `R10-007` Add two-phase final-head closeout support procedure
- Status: planned
- Done when: the repo distinguishes candidate closeout commit, external run identity, final-head support commit, and final accepted R10 posture.

### `R10-008` Close R10 only with real external final-head proof
- Status: planned
- Done when: R10 proof package exists, real external run identity exists, external artifact bundle is referenced and retrievable, final-head support packet exists after push, status-doc gate passes, non-claims are preserved, and no successor milestone is opened.

## Milestone notes
- `R10-001` opens R10 in repo truth only. It does not implement external-runner proof, real CI, external QA, artifact-bundle validation, final-head replay, or R10 closeout.
- `R10-002` hardens the closeout-facing external-runner identity contract without treating unavailable runner state, synthetic run identity, missing workflow identity, missing artifact identity, missing command logs, missing QA/evidence refs, missing final-head support evidence, old R9 limitation evidence, or broad CI/product coverage language as R10 closeout proof.
- `R10-002` includes a validator-only fixture for contract shape testing. That fixture is not a real external runner capture and is not R10 proof.
- `R10-003` is the next gated step and must define the bundle shape before a runner result can be accepted as closeout evidence.
- `R10-004` must wire only one real external runner path and must not claim broad production CI coverage.
- `R10-005` is not complete if the packet says only `unavailable`.
- `R10-006` must ensure R10 closeout QA consumes real external-runner artifacts rather than local-only executor evidence.
- `R10-007` must make the final-head support procedure non-self-referential.
- `R10-008` must close R10 only if real external final-head proof exists, all non-claims are preserved, and no successor milestone opens.
