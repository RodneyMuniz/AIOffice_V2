# R17-022 Validation Manifest

Required focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_stop_retry_reentry_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_stop_retry_reentry_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_stop_retry_reentry_controls.ps1

Required related gates include the existing R17 A2A contract, A2A dispatcher, registry, memory loader, invocation log, adapter, ledger, board/orchestration, Kanban, KPI, and status-doc validators/tests.

Boundary: generated control and re-entry records are validation-only and not executed. The foundation does not invoke agents, runtime Orchestrator, adapters, APIs, tools, QA, audit, product runtime, board mutation, or main merge.
