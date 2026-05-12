# R18-013 Validation Manifest

Expected status truth after this package: R18 active through R18-013 only; R18-014 through R18-028 planned only.

Required validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_continuation_packet_generator.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_continuation_packet_generator.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_continuation_packet_generator.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check
