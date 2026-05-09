# R17-017 Validation Manifest

Status: passed after local validation on 2026-05-09.

Required focused validation:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1

Regression validation also passed:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1
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

Boundary:
- Generated packet/check/UI/proof artifacts only.
- No live QA execution.
- No adapter runtime.
- No real QA result unless separately imported with committed validation evidence.
- No board mutation or runtime card creation.
- No external APIs, Codex executor invocation, Evidence Auditor API invocation, A2A messages, or live agent runtime.
