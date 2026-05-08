# R17-012 Agent Registry and Identity Packet Validation Manifest

Status: passed

Validation was marked passed only after the R17-012 focused generator, validator, focused test, status-doc gates, impacted Kanban/operator-wall checks, broader existing R17 focused checks, and `git diff --check` passed locally.

## Passed Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kanban_mvp.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_mvp.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_operator_intake_surface.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_operator_intake_surface.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kpi_baseline_target_scorecard.ps1 -ScorecardPath state/governance/r17_kpi_baseline_target_scorecard.json
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kpi_baseline_target_scorecard.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_contracts.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_contracts.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_board_state_store.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_board_state_store.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_card_detail_drawer.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_card_detail_drawer.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_event_evidence_summary.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_event_evidence_summary.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_identity_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_identity_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_loop_state_machine.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_loop_state_machine.ps1
- git diff --check
