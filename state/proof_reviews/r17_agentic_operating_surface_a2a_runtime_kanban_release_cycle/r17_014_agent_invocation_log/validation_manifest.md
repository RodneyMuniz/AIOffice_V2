# R17-014 Agent Invocation Log Validation Manifest

Status: passed

The manifest may be marked passed only after the R17-014 generator, validator, focused test, status-doc gate, impacted R17 foundation validators/tests, Kanban MVP validator/test, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_memory_artifact_loader.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_registry.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_operator_intake_surface.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_operator_intake_surface.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_orchestrator_loop_state_machine.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_orchestrator_loop_state_machine.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_kanban_mvp.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_kanban_mvp.ps1
- git diff --check
