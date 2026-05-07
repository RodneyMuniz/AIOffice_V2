# R17-006 Validation Manifest

Status: passed

The requested R17-006 validation suite passed.

## Commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_kanban_mvp.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kanban_mvp.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_mvp.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r17_kpi_baseline_target_scorecard.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kpi_baseline_target_scorecard.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1`
- `git diff --check`
