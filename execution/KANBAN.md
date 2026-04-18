# AIOffice Kanban

This board tracks the current reset implementation milestone only.

## Active Milestone
`R2 Minimum Control Substrate`

Objective:
Make the minimum real control substrate needed for the first bounded V1 proof without widening scope beyond admin-only supervised operation through `architect` plus bounded `apply/promotion` control.

Exit Criteria:
- durable stage artifact contracts exist for `intake`, `pm`, `context_audit`, and `architect`
- persisted state exists for packet identity, stage status, approvals, artifact refs, Git refs, and reconciliation state
- an `apply/promotion` gate exists with explicit approval, bounded scope, artifact linkage, and fail-closed behavior
- an admin-only supervised harness can exercise the substrate without broad UI

## Tasks

### `RST-009` Implement stage artifact contracts through `architect`
- Status: ready
- Order: 1
- Milestone: `R2 Minimum Control Substrate`
- Depends on: none
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed artifact templates or schemas plus validation rules for `intake`, `pm`, `context_audit`, and `architect`
- Done when: each required stage has a durable repo-defined contract with required fields, approval-state support where needed, and a validation path that rejects malformed artifacts

### `RST-010` Implement persisted state substrate for packet and truth reconciliation
- Status: ready
- Order: 2
- Milestone: `R2 Minimum Control Substrate`
- Depends on: `RST-009`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/MINIMAL_DONOR_IMPORT_PLAN.md`
- Durable output: committed state schema and storage implementation for packet identity, stage progression, approvals, artifact references, Git references, and reconciliation status
- Done when: the repo can persist and reload packet records while keeping local working state, accepted artifact state, and reconciliation state distinct

### `RST-011` Implement bounded `apply/promotion` gate with fail-closed checks
- Status: ready
- Order: 3
- Milestone: `R2 Minimum Control Substrate`
- Depends on: `RST-009`, `RST-010`
- Authority: `governance/VISION.md`, `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`
- Durable output: committed gate contract and checks for explicit approval, bounded mutation scope, linked approved artifact set, and blocked-state recording
- Done when: the gate refuses mutation or promotion unless approval, scope, artifact linkage, and reconciliation preconditions are satisfied, and blocked outcomes are durably recorded

### `RST-012` Implement minimal admin-only supervised harness for substrate walk
- Status: ready
- Order: 4
- Milestone: `R2 Minimum Control Substrate`
- Depends on: `RST-009`, `RST-010`, `RST-011`
- Authority: `governance/V1_PRD.md`, `governance/OPERATING_MODEL.md`, `governance/ACTIVE_STATE.md`
- Durable output: committed admin-only entrypoint or script plus a minimal fixture or example packet path for exercising the substrate
- Done when: an admin can run a narrow supervised flow that creates or loads a packet, advances it through `architect`-stage artifact handling, evaluates the `apply/promotion` gate, and records allow or block results without broad UI

### `RST-013` Connect Git remote and publish current repo snapshot for backup/restore
- Status: done
- Order: support
- Milestone: `R2 Minimum Control Substrate`
- Depends on: none
- Authority: user request, `governance/ACTIVE_STATE.md`
- Durable output: committed Git history in the local repo, connected `origin`, and a pushed remote snapshot of the current project files
- Done when: the repo is initialized, `origin` points at the requested GitHub repository, the current workspace files are committed, and the commit is pushed to the remote default branch for backup/restore use

## Explicitly Out Of Scope For This Milestone
- broad UI or control-room work
- Standard or subproject pipeline work
- later-lane workflow proof beyond `architect`
- donor backlog import or historical backfill
