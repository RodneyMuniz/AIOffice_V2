# R18-018 Validation Manifest

Expected status truth: R18 active through R18-019 only; R18-020 through R18-028 planned only.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_status_doc_gate_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_status_doc_gate_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_status_doc_gate_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_status_doc_gate.ps1
- git diff --check

Validation is policy validation only; it is not release runtime execution.
