# R18-021 Validation Manifest

Expected validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_agent_tool_call_evidence.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_tool_call_evidence.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_tool_call_evidence.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

The validator fails closed on fake live tool calls, missing evidence refs, missing live-call controls, unknown call modes, mismatched agent cards, role/skill mismatches, unsafe refs, runtime/API/recovery/release/CI/product overclaims, R18-022+ completion claims, and status-boundary drift.
