# R17-007 Card Detail Evidence Drawer Proof Review

## Scope

R17-007 implements a read-only card detail evidence drawer/panel only.

The drawer consumes R17-005 board state/replay artifacts and R17-006 Kanban snapshot/UI artifacts. It surfaces the selected R17-005 seed card's card identity, acceptance criteria, QA criteria, evidence refs, memory refs, task packet ref, event history, validation/proof refs, blocker/user-decision state, non-claims, and rejected claims.

The drawer includes explicit `not_implemented_in_r17_007` placeholders for Dev output, QA result, and audit verdict. These placeholders are non-claims and do not represent real Dev output, real QA result, or a real audit verdict.

## Evidence Boundary

- `state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json`
- `scripts/operator_wall/r17_kanban_mvp/index.html`
- `scripts/operator_wall/r17_kanban_mvp/styles.css`
- `scripts/operator_wall/r17_kanban_mvp/README.md`
- `tools/R17CardDetailDrawer.psm1`
- `tools/new_r17_card_detail_drawer.ps1`
- `tools/validate_r17_card_detail_drawer.ps1`
- `tests/test_r17_card_detail_drawer.ps1`
- `tests/fixtures/r17_card_detail_drawer/`
- this proof-review package

## Preserved Non-Claims

- R17-007 does not implement live board mutation.
- R17-007 does not implement Orchestrator runtime.
- R17-007 does not implement A2A runtime.
- R17-007 does not implement Dev/Codex executor adapter.
- R17-007 does not implement QA/Test Agent adapter.
- R17-007 does not implement Evidence Auditor API adapter.
- R17-007 does not call external APIs.
- R17-007 does not call Codex as executor.
- R17-007 does not claim Dev output, QA result, or audit verdict beyond explicit not-implemented placeholders.
- R17-007 does not claim autonomous agents.
- R17-007 does not claim product runtime.
- R17-007 does not claim production runtime.
- R17-007 does not claim executable handoffs or executable transitions.
- R17-007 does not claim external audit acceptance.
- R17-007 does not claim main merge.
- R13, R14, R15, and R16 boundaries are preserved.

## Review Posture

This is local/static read-only operator inspection over committed/generated repo-backed state only. It is not product runtime, not production runtime, not runtime board mutation, not runtime agent execution, and not an A2A runtime.
