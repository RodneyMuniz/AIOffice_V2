# R17-005 Validation Manifest

Status: passed.

The R17-005 validation sequence passed.

## Passed Commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_contracts.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_contracts.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_board_state_store.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_state_store.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_state_store.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r17_kpi_baseline_target_scorecard.json` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kpi_baseline_target_scorecard.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1` - passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1` - passed
- `git diff --check` - passed

## Replay Summary

- Aggregate verdict: `generated_r17_board_state_store_candidate`
- Input card count: 1
- Input event count: 5
- Replayed event count: 5
- Rejected event count: 0
- Final lane for `R17-005`: `ready_for_user_review`
- User decisions required: 1
