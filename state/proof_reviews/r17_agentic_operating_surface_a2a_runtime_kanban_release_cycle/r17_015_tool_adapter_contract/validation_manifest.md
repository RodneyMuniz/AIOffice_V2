# R17-015 Tool Adapter Contract Validation Manifest

Status: passed

The manifest may be marked passed only after the R17-015 generator, validator, focused test, status-doc gate, impacted R17 validators/tests, and git diff hygiene checks pass locally.

## Required Commands

- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_tool_adapter_contract.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1
- git diff --check
