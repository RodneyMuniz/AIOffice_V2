# R17-006 Kanban MVP Proof Review

## Scope

R17-006 implements a read-only local/static Kanban MVP surface only. It consumes the R17-005 repo-backed board state and replay artifacts and renders a local operator view from a committed generated snapshot.

The operator can open `scripts/operator_wall/r17_kanban_mvp/index.html` directly in a browser and see the R17 lanes, the R17-005 seed card, the current lane, evidence ref counts, memory ref counts, blocker count, replay summary, user-decision state, non-claims, and evidence refs.

## Evidence

- Static UI folder: `scripts/operator_wall/r17_kanban_mvp/`
- Generated UI snapshot: `state/ui/r17_kanban_mvp/r17_kanban_snapshot.json`
- Generator and validator module: `tools/R17KanbanMvp.psm1`
- Generator wrapper: `tools/new_r17_kanban_mvp.ps1`
- Validator wrapper: `tools/validate_r17_kanban_mvp.ps1`
- Focused tests: `tests/test_r17_kanban_mvp.ps1`
- Compact fixtures: `tests/fixtures/r17_kanban_mvp/`
- R17-005 board state: `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_state.json`
- R17-005 seed card: `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/cards/r17_005_seed_card.json`
- R17-005 seed event log: `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/events/r17_005_seed_events.jsonl`
- R17-005 replay report: `state/board/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_board_replay_report.json`

## Boundary

- R17-006 does not implement live board mutation.
- R17-006 does not implement Orchestrator runtime.
- R17-006 does not implement A2A runtime.
- R17-006 does not implement Dev/Codex executor adapter.
- R17-006 does not implement QA/Test Agent adapter.
- R17-006 does not implement Evidence Auditor API adapter.
- R17-006 does not call external APIs.
- R17-006 does not call Codex as executor.
- R17-006 does not claim autonomous agents.
- R17-006 does not claim product runtime.
- R17-006 does not claim executable handoffs or executable transitions.
- R17-006 does not claim external audit acceptance.
- R17-006 does not claim main merge.
- R13, R14, R15, and R16 boundaries are preserved.

## Result

Validation passed for the R17-006 read-only local/static Kanban MVP boundary. This package is generated for R17-006 only and does not implement R17-007 or later.
