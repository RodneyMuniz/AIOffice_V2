# R17-004 Board Contracts Proof Review

Status: validation passed.

## Scope

R17-004 defines the governed card, board-state, and board-event contracts only.

R17-004 does not implement board state store.
R17-004 does not implement Kanban UI.
R17-004 does not implement Orchestrator runtime.
R17-004 does not implement A2A runtime.
R17-004 does not implement Dev/Codex executor adapter.
R17-004 does not implement QA/Test Agent adapter.
R17-004 does not implement Evidence Auditor API adapter.
R17-004 does not claim product runtime.
R17-004 does not claim autonomous agents.
R17-004 does not claim executable handoffs or executable transitions.
R17-004 does not claim external audit acceptance.
R17-004 does not claim main merge.

R13, R14, R15, and R16 boundaries are preserved.

## Contract Artifacts

- `contracts/board/r17_card.contract.json`
- `contracts/board/r17_board_state.contract.json`
- `contracts/board/r17_board_event.contract.json`

## Validation Surfaces

- `tools/R17BoardContracts.psm1`
- `tools/validate_r17_board_contracts.ps1`
- `tests/test_r17_board_contracts.ps1`
- `tests/fixtures/r17_board_contracts/`

## Boundary Notes

The R17-004 tooling validates contract shape and fixture behavior only. It does not create runtime board state, move cards, call agents, call APIs, replay board events, dispatch A2A messages, or execute handoffs/transitions.

Repo truth remains canonical. The board state contract defines a governed product surface boundary only and is not a replacement for repo truth. Fake multi-agent narration is not accepted as proof.
