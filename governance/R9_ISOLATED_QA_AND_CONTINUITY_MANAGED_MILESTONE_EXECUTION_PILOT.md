# R9 Isolated QA and Continuity-Managed Milestone Execution Pilot

## Milestone name
`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`

## Why this milestone exists now
R8 is honestly closed with cautions. It added real remote-gated QA and proof substrate, but it did not prove a concrete CI or external runner artifact identity, fully isolated QA role/signoff, exact-final post-push verification committed with the final closeout SHA, or final-head clean-checkout replay after push.

The bounded post-R8 correction fixed the stale `ACTIVE_STATE.md` most-recently-closed contradiction and hardened `tools/StatusDocGate.psm1` so that class of status drift now fails validation.

R9 opens only after that correction. It is not UI work, not Standard runtime work, not swarms, not multi-repo orchestration, and not broad autonomy. R9 exists to prove one bounded control pattern where Codex executor output cannot certify itself, QA authority is isolated by role or runner identity, final remote-head support evidence is handled honestly, and milestone work can survive Codex context-window failure by resuming from durable repo state instead of chat memory.

## Objective
Prove one bounded request-to-closeout milestone execution path where Codex executor output is accepted only after isolated QA verification, exact final remote-head verification support, and durable segment-level continuity evidence, while surviving Codex context-window failure through repo-state resume rather than chat memory.

## Current status
`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot` is now active in repo truth through `R9-003` only.

`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner` remains the most recently closed milestone under `governance/R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md`, the committed proof-review basis under `state/proof_reviews/r8_remote_gated_qa_subagent_and_clean_checkout_proof_runner/`, and decision authority `D-0053`.

`R9-001` is complete as the repo-truth opening and boundary-freeze step.

`R9-002` is complete through the first isolated QA signoff packet foundation under `contracts/isolated_qa/`, `tools/IsolatedQaSignoff.psm1`, `tools/validate_isolated_qa_signoff.ps1`, `state/fixtures/valid/isolated_qa/`, and focused proof through `tests/test_isolated_qa_signoff.ps1`.

`R9-003` is complete through the first exact-final post-push verification support model under `contracts/post_push_support/`, `tools/FinalRemoteHeadSupport.psm1`, `tools/validate_final_remote_head_support.ps1`, `state/fixtures/valid/post_push_support/`, and focused proof through `tests/test_final_remote_head_support.ps1`.

`R9-004` through `R9-007` remain planned only.

## Exact boundary
R9 is bounded to:
- one repository only: `AIOffice_V2`
- one active milestone cycle at a time
- one isolated QA role/signoff packet path
- one exact-final post-push verification support model
- one attempt to capture real external or CI runner artifact identity if available
- one continuity-managed execution segment model
- one tiny segmented milestone execution pilot
- one narrow R9 closeout path that preserves all R9 non-claims

## Context-window failure principle
Do not try to make one Codex thread reliable for hours. Make Codex disposable.

Each execution segment must:
- receive a bounded dispatch packet
- operate within a small context budget
- write durable evidence and checkpoint artifacts before exit
- allow a new thread or API runner to resume from committed or persisted repo truth if it fails
- treat durable state, not chat memory, as the orchestrator memory

## Exact stop conditions
R9 must stop or fail closed if:
- executor evidence is presented as QA authority
- a QA signoff packet lacks separate QA role or runner identity
- source artifacts are missing, malformed, contradictory, or not remote-head aligned
- final remote-head support evidence is treated as if it could be committed into the same final closeout commit
- a CI or external runner identity is claimed without a real run ID, artifact name, artifact URL, or retrieval instruction
- required continuity segment artifacts are missing, malformed, contradictory, or not remote-head aligned
- any segment relies on chat memory as authority
- R9 scope widens into UI, Standard runtime, multi-repo orchestration, swarms, broad autonomy, unattended automatic resume, or destructive rollback

## Required outputs
By the end of R9, the milestone must produce:
- one isolated QA signoff packet contract or equivalent tooling
- one support model for exact-final post-push verification evidence
- one real external or CI runner artifact identity if available, or an explicit fail-closed limitation if not available
- one continuity-managed execution segment artifact model
- one tiny segmented milestone execution pilot from request through operator decision
- one narrow R9 closeout package that preserves all non-claims

## Required non-claims
R9 does not currently prove and must not casually widen into:
- no UI or control-room productization
- no Standard runtime
- no multi-repo orchestration
- no swarms or fleet execution
- no broad autonomous milestone execution
- no unattended automatic resume
- no destructive rollback
- no production-grade CI for every workflow
- no general Codex reliability claim
- no claim that Codex context compaction is solved
- no claim that hours-long milestones can now run unattended

## Task list

### `R9-001` Open R9 and freeze boundary
- Status: done
- Done when: R9 opens only after the post-R8 correction, R8 remains the most recently closed milestone, the R9 scope is frozen as isolated QA plus continuity-managed execution pilot only, and the non-scope explicitly excludes UI, Standard runtime, swarms, multi-repo behavior, broad autonomy, and unattended execution.

### `R9-002` Define isolated QA role and signoff packet
- Status: done
- Durable output: `contracts/isolated_qa/foundation.contract.json`, `contracts/isolated_qa/qa_signoff_packet.contract.json`, `tools/IsolatedQaSignoff.psm1`, `tools/validate_isolated_qa_signoff.ps1`, `state/fixtures/valid/isolated_qa/qa_signoff_packet.valid.json`, and `tests/test_isolated_qa_signoff.ps1`.
- Done when: QA signoff consumes executor evidence plus remote or clean-checkout artifacts, records `qa_role_identity`, `qa_runner_kind`, `qa_authority_type`, `source_artifacts`, `verdict`, `refusal_reasons`, and `independence_boundary`, and fails closed if executor self-certification is presented as QA authority, if the QA packet lacks separate QA role or runner identity, if executor evidence is the only source artifact, if required remote-head or clean-checkout/external QA refs are missing, or if the independence boundary says the same executor produced and approved the signoff.

### `R9-003` Define exact-final post-push verification support model
- Status: done
- Durable output: `contracts/post_push_support/foundation.contract.json`, `contracts/post_push_support/final_remote_head_support_packet.contract.json`, `tools/FinalRemoteHeadSupport.psm1`, `tools/validate_final_remote_head_support.ps1`, `state/fixtures/valid/post_push_support/final_remote_head_support_packet.valid.json`, and `tests/test_final_remote_head_support.ps1`.
- Done when: the support packet model distinguishes milestone closeout commit, after-push verification, and follow-up support packet or external artifact publication; requires `verification_timing` as `after_closeout_push`; fails closed on same-commit or self-referential proof policy, empty evidence refs, invalid status/refusal combinations, missing non-claims, and CI/external runner claims without concrete run identity.

### `R9-004` Capture real external or CI runner artifact identity
- Status: planned
- Planned output: one real external or CI runner artifact identity if available, using the R8 workflow foundation or equivalent runner.
- Done when: the evidence records actual run identity such as GitHub Actions run ID, artifact name, artifact URL or retrieval instruction, branch, head SHA, tree, verdict, and timestamp; if CI cannot be triggered in this environment, the milestone fails closed or records an explicit limitation without faking a run identity.

### `R9-005` Add continuity-managed execution segment model
- Status: planned
- Planned output: durable contracts or artifacts for segmented milestone execution.
- Done when: `execution_segment_dispatch`, `execution_segment_checkpoint`, `execution_segment_result`, `execution_segment_resume_request`, and `execution_segment_handoff` artifacts exist; each segment is small enough to run in a fresh Codex thread or API call, writes durable state before exit, and resume reconstructs from Git and committed or persisted state only.

### `R9-006` Pilot one tiny milestone through segmented execution
- Status: planned
- Planned output: one small bounded milestone pilot using one or two execution segments.
- Done when: the pilot runs request, plan, approve/freeze, segment dispatch, Codex execution evidence, isolated QA, audit summary, and operator decision without claiming full autonomous milestone execution or hours-long unattended processing.

### `R9-007` Close R9 narrowly
- Status: planned
- Done when: isolated QA signoff exists, exact final remote-head verification support exists, clean or external QA evidence exists or a limitation is explicitly recorded, status-doc gate passes, no self-certification is accepted, continuity segment artifacts prove resume-from-state is possible, and all non-claims are preserved.

## Milestone notes
- `R9-001` opens R9 in repo truth only. It does not implement isolated QA signoff, final-head support packets, external runner proof, continuity-managed segment artifacts, or the tiny pilot.
- `R9-002` separates executor evidence from QA authority at the first contract and validation layer. Executor-produced artifacts may be source evidence, but they cannot be the QA verdict by themselves.
- `R9-003` defines the final-closeout SHA support model honestly. Exact final post-push verification may live in a follow-up support packet or external artifact identity; it must not pretend to be inside the same final commit it verifies.
- `R9-004` must not fake CI. If no real run identity is available, record the limitation and stop short of the claim.
- `R9-005` exists because Codex context compaction and deadlock are expected failure modes. The solution is durable segmentation, not trusting chat memory.
- `R9-006` is a control-pattern pilot only. It is not a broad milestone automation claim.
- `R9-007` closes only if the isolated QA, final-head support, external/clean evidence, status gate, and continuity artifacts all align.
- After `R9-003`, R9 still does not prove real external or CI runner artifact identity, continuity-managed execution segments, the tiny segmented milestone pilot, solved Codex context compaction, or hours-long unattended milestone execution. R9-003 defines the support model only; it does not produce the final R9 closeout support packet yet.
