# R18-009 Validation Manifest

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_runner_state_store.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_runner_state_store.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_runner_state_store.ps1
- Prior R18 validators and focused tests listed in the R18-009 task prompt.
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected status truth after this package: R18 active through R18-009 only; R18-010 through R18-028 planned only.
