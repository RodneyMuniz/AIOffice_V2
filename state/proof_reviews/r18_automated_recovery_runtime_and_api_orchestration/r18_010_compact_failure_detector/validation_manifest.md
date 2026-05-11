# R18-010 Validation Manifest

Expected status truth after this package: R18 active through R18-010 only; R18-011 through R18-028 planned only.

Required validation commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_compact_failure_detector.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_detector.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_detector.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`
