# R18-022 Validation Manifest

Expected status truth: R18 active through R18-022 only; R18-023 through R18-028 planned only.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_api_safety_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_api_safety_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_api_safety_controls.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_agent_tool_call_evidence.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_agent_tool_call_evidence.ps1
- git diff --check

Validation is deterministic controls validation only; it is not API invocation, CI replay, release gate execution, or live runtime execution.
