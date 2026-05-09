# R17-019 Validation Manifest

Required focused validation:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_call_ledger.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_qa_test_agent_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_codex_executor_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_agent_invocation_log.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1

Boundary:
- Generated ledger contract/check/UI/proof artifacts only.
- All ledger seed records remain disabled/not executed.
- No tool-call runtime or ledger runtime.
- No actual tool call.
- No adapter runtime invocation.
- No Codex executor, QA/Test Agent, or Evidence Auditor API invocation.
- No external API call.
- No real audit verdict or external audit acceptance.
- No board mutation, A2A runtime, autonomous agents, product runtime, main merge, or R17-020+ completion claim.
