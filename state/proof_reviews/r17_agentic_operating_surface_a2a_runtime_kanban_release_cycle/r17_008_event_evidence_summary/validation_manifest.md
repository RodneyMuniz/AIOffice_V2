# R17-008 Validation Manifest

Status: passed

All R17-008 generator, validator, focused tests, dependency validators, KPI validator, status-doc gate, and `git diff --check` commands passed.

## Commands
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_contracts.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_state_store.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kanban_mvp.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_mvp.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_card_detail_drawer.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_card_detail_drawer.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_event_evidence_summary.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_event_evidence_summary.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_event_evidence_summary.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r17_kpi_baseline_target_scorecard.json`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kpi_baseline_target_scorecard.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1`
- `git diff --check`
