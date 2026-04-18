# AIOffice Minimal Donor Import Plan

Authority: `COPY_MANIFEST.md`

## Planning Rules
- Do not bulk-copy donor material.
- Do not import legacy backlog data.
- Do not widen scope beyond current V1.
- Prefer reimplementation from pattern over noisy carry-over.
- Do not import donor code now.

## Current Support Targets
This plan is limited to the minimum donor patterns needed to support:
- persisted state substrate
- packet/bundle path
- `apply/promotion` boundary
- fail-closed checks
- fresh kanban and process discipline

## Import Now
These are the only donor documents worth selectively fetching next, and only as pattern inputs for fresh rewrite:

### `projects/aioffice/governance/WORKFLOW_VISION.md`
- Why: provides the canonical packet-out and bundle-back workflow shape and the first-proof boundary framing
- Supports: packet/bundle path, `apply/promotion` boundary
- Carry mode: adapt from pattern, rewrite fresh

### `projects/aioffice/governance/STAGE_GOVERNANCE.md`
- Why: provides stage order, artifact expectations, blocked-state rules, and fail-closed stage discipline
- Supports: packet/bundle path, fail-closed checks
- Carry mode: adapt from pattern, rewrite fresh

### `projects/aioffice/governance/SYSTEM_REALITY_MAP.md`
- Why: provides the distinction between local drafts, product vision, and sanctioned truth surfaces
- Supports: persisted state substrate, fail-closed reporting
- Carry mode: adapt from pattern, rewrite fresh

### `projects/aioffice/governance/REPO_MILESTONE_LOOP_DISCIPLINE.md`
- Why: provides publication, verification, and process-discipline patterns that keep proof claims bounded
- Supports: fail-closed checks, fresh kanban and process discipline, `apply/promotion` reporting
- Carry mode: adapt from pattern, rewrite fresh

## Import Later
No donor imports are required later by default at this stage.

If the next implementation slice proves that the fresh rewrite still has unresolved ambiguity, revisit only the smallest additional governance pattern that directly answers that ambiguity.

## Reference Only
These donor files may be consulted later as implementation references, but they should not be copied into the new repo:

### `sessions/store.py`
- Why: possible persisted state substrate reference
- Supports: store shape and reconciliation ideas
- Carry mode: reference only, reimplement cleanly

### `state_machine.py`
- Why: possible stage transition and gate-order reference
- Supports: packet progression and fail-closed transition rules
- Carry mode: reference only, reimplement cleanly

### `tests/test_control_kernel_store.py`
- Why: possible invariant reference for state and fail-closed behavior
- Supports: persisted state checks, fail-closed test design
- Carry mode: reference only, rewrite tests fresh

## Not Needed
These donor materials are not needed for the current V1 slice:

### `projects/aioffice/governance/DESIGN_LANE_CONTRACT.md`
- Reason: design-lane boundary logic is explicitly not an initial implementation commitment

### `projects/aioffice/handoffs/rebaseline_2026_04/OLD_REPO_FREEZE.md`
- Reason: freeze context is historical only and does not advance current V1 implementation

### `projects/aioffice/governance/M13_STRUCTURAL_TRUTH_REVIEW.md`
- Reason: old review history is not needed to define the new proof slice

### `projects/aioffice/governance/M14_HOOK_AND_AUTOMATION_REVIEW.md`
- Reason: automation review is outside the smallest current proof slice

### `projects/aioffice/governance/M15_DESIGN_LANE_REVIEW.md`
- Reason: design-lane review is outside current V1

### `scripts/operator_api.py`
- Reason: current V1 allows docs-first or API-first operation, so donor API code is optional rather than minimum

### old `execution/KANBAN.md`, old `governance/ACTIVE_STATE.md`, old `governance/DECISION_LOG.md`, and old task or milestone chains
- Reason: explicitly excluded by the reset authority

## Smallest Recommended Donor Use
If donor material is fetched next, fetch only these four governance documents:
1. `WORKFLOW_VISION.md`
2. `STAGE_GOVERNANCE.md`
3. `SYSTEM_REALITY_MAP.md`
4. `REPO_MILESTONE_LOOP_DISCIPLINE.md`

Do not fetch donor code until the new repo has already defined:
- fresh stage artifact contracts
- fresh persisted state schema
- fresh `apply/promotion` gate contract

## Outcome
The donor plan for the current V1 is docs-pattern first, code-reference later, and bulk import never.
