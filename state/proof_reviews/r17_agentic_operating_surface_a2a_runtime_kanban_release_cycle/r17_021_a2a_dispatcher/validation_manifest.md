# R17-021 Validation Manifest

Required focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_a2a_dispatcher.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_a2a_dispatcher.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_a2a_dispatcher.ps1

Required related gates include the existing R17 A2A contract, registry, memory loader, invocation log, adapter, ledger, board/orchestration, Kanban, KPI, and status-doc validators/tests.

Boundary: generated dispatch records are validation-only and not dispatched. The foundation does not invoke agents, runtime Orchestrator, adapters, APIs, tools, QA, audit, product runtime, board mutation, or main merge.
