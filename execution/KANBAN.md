# AIOffice Kanban

This board tracks the current reset milestone structure only.

## Active Milestone
`R6 Supervised Milestone Autocycle Pilot`

Objective:
Open and implement one operator-controlled, fail-closed, evidence-first milestone autocycle pilot for `AIOffice_V2` only, from structured intake to final operator decision, without widening into broad autonomy, rollback execution, unattended automatic resume, UI, Standard runtime, multi-repo behavior, executor swarms, or broader orchestration.

Exit Criteria:
- `R6-P1` and `R6-P2` are complete
- one milestone proposal can be produced from one structured intake and frozen only by explicit operator approval
- one frozen milestone binds to one Git-backed baseline before dispatch
- Codex dispatch, run ledger, governed execution evidence, QA observation, milestone aggregation, PRO-style summary, and operator decision packet exist for the exact pilot
- one replayable end-to-end pilot proof exists with honest closeout wording and preserved non-claims

## Most Recently Closed Milestone
`R5 Git-Backed Recovery, Resume, and Repo Enforcement Foundations`

Closeout summary:
`R5-001` through `R5-007` are complete and formally closed in repo truth. The closeout authority is `governance/POST_R5_CLOSEOUT.md`, the audit mapping authority is `governance/POST_R5_AUDIT_INDEX.md`, and the committed bounded proof-review basis is `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/` at replay source head `1a97ff0cef9675c88030d3b618ef928093ee080c`. This closeout remains bounded and does not add rollback execution, unattended automatic resume, UI, Standard runtime, or broader orchestration claims.

## Tasks

### `R6-001` Open R6 and freeze the pilot boundary
- Status: done
- Order: 1
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `governance/POST_R5_CLOSEOUT.md`, `governance/POST_R5_AUDIT_INDEX.md`
- Authority: `README.md`, `governance/ACTIVE_STATE.md`, `governance/DECISION_LOG.md`, `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `governance/reports/AIOffice_V2_R5_Audit_and_R6_Planning_Report_v2.md`
- Durable output: updated repo-truth surfaces plus initial milestone-autocycle contract foundation under `contracts/milestone_autocycle/`
- Done when: R6 is opened in repo truth, the exact pilot boundary is written, stop conditions are explicit and fail-closed, and no broader autonomy is implied

### `R6-P1` Final-head evidence-thickness precondition
- Status: done
- Order: P1
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-001`
- Authority: `governance/POST_R5_CLOSEOUT.md`, `governance/POST_R5_AUDIT_INDEX.md`, `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`
- Durable output: one final-head closeout-support packet under `state/proof_reviews/r5_git_backed_recovery_resume_and_repo_enforcement_foundations/support/final_closeout_head/` archiving omitted support-test logs and recording the final inventory clearly
- Done when: final-head support evidence exists for `tests/test_bounded_proof_suite.ps1`, `tests/test_bounded_proof_ci_foundation.ps1`, `tests/test_repo_enforcement.ps1`, `tests/test_r5_recovery_resume_proof_review.ps1`, and `tests/test_work_artifact_contracts.ps1`

### `R6-P2` Baton path determinism precondition
- Status: done
- Order: P2
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-001`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `governance/ACTIVE_STATE.md`
- Durable output: deterministic baton-related path resolution that anchors top-level baton store plus resume request or output paths to repo roots and anchors request-relative `baton_ref` values to the request artifact directory
- Done when: baton continuity no longer carries shell-location-sensitive path behavior into later R6 work

### `R6-002` Add milestone task-set proposal from one structured intake
- Status: done
- Order: 2
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-P1`, `R6-P2`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `governance/ACTIVE_STATE.md`
- Durable output: one milestone proposal surface that derives a bounded 5 to 10 task set from one structured intake with durable request and milestone lineage
- Done when: one structured intake can generate one milestone proposal, proposal lineage back to the request and milestone target is durable, and malformed or incomplete input fails closed

### `R6-003` Add explicit operator approval and milestone freeze
- Status: done
- Order: 3
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-002`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `contracts/milestone_autocycle/`
- Durable output: one explicit approval record surface plus one durable freeze artifact that records the exact approved task set and operator authority
- Done when: the operator can explicitly approve or reject a milestone proposal, approved plans become frozen durable milestone state, freeze records exact task set and operator authority, rejected proposals do not emit freeze artifacts, and unfrozen milestones cannot dispatch work

### `R6-004` Bind milestone freeze to Git-backed baseline capture
- Status: open
- Order: 4
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-003`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `contracts/milestone_autocycle/`, `contracts/milestone_baselines/`
- Durable output: a frozen milestone linked durably to one Git-backed baseline anchor before dispatch
- Done when: a frozen milestone records a valid baseline id, baseline capture is required before dispatch, branch or head or tree or repository binding is durable, and dirty-worktree or mismatch conditions fail closed

### `R6-005` Add Codex dispatch contract and run ledger
- Status: open
- Order: 5
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-004`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `contracts/milestone_autocycle/`
- Durable output: governed Codex dispatch surface plus one durable run ledger with one active dispatch at a time
- Done when: each task dispatch records input refs, baseline ref, allowed scope, target branch, expected outputs, and refusal conditions; dispatch state changes are durable; and the pilot enforces one active dispatch at a time

### `R6-006` Assemble governed execution evidence from executor outputs
- Status: open
- Order: 6
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-005`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `contracts/milestone_autocycle/`
- Durable output: one governed execution evidence bundle assembler for completed dispatches
- Done when: completed dispatches can be converted into one governed execution evidence bundle capturing changed files, produced artifacts, test outputs, and evidence refs, and missing required evidence blocks bundle creation

### `R6-007` Add automated QA observation and milestone aggregation
- Status: open
- Order: 7
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-006`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `governance/ACTIVE_STATE.md`
- Durable output: bounded QA observation path plus milestone-visible task and milestone roll-up status
- Done when: execution evidence can trigger bounded QA observation, each task receives a milestone-visible QA outcome, milestone status rolls up task states into one milestone-level view, and blocked or failed tasks stop progression unless explicitly overridden by the operator

### `R6-008` Add bounded PRO-style summary and operator decision packet
- Status: open
- Order: 8
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-007`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `contracts/milestone_autocycle/`
- Durable output: one milestone-level summary and one operator decision packet
- Done when: one milestone-level summary can cover scope, diffs, tests, blockers, evidence quality, and non-claims, recommendation stays advisory only, and the operator receives one decision packet with `accept`, `rework`, or `stop`

### `R6-009` Produce one replayable supervised pilot proof and closeout packet
- Status: open
- Order: 9
- Milestone: `R6 Supervised Milestone Autocycle Pilot`
- Depends on: `R6-008`
- Authority: `governance/R6_SUPERVISED_MILESTONE_AUTOCYCLE_PILOT.md`, `governance/DECISION_LOG.md`, `contracts/milestone_autocycle/`
- Durable output: one replayable end-to-end pilot proof plus honest closeout package
- Done when: one exact pilot scenario replays from intake to operator decision, raw logs plus summary artifacts plus selection scope plus replay-source metadata are committed, closeout wording matches exact replay scope, and non-claims remain explicit

## Explicitly Out Of Scope For This Milestone
- operator-visible or user-facing UI work
- unified workspace work
- multi-repo behavior
- multiple executor types
- parallel dispatch or executor swarms
- automatic merge or promotion
- unattended automatic resume behavior
- rollback execution
- Standard or subproject runtime
- broader orchestration beyond the exact pilot
- donor backlog import or historical backfill
