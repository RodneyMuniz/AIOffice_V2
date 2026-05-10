# R17-023 Validation Manifest

Required validation commands:

- powershell -ExecutionPolicy Bypass -File tools\new_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tools\validate_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_r17_cycle_1_definition.ps1
- powershell -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1

The package is deterministic repo-backed evidence only. It is not live autonomous operation and not live A2A runtime.
