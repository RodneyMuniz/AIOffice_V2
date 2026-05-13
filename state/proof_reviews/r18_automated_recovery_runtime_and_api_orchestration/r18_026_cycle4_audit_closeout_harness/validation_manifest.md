# R18-026 Validation Manifest

Expected status truth: R18 active through R18-026 only; R18-027 through R18-028 planned only.

Focused and boundary commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_cycle4_audit_closeout_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle4_audit_closeout_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle4_audit_closeout_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1
- git diff --check

This manifest records deterministic local validation expectations only. It is not CI replay.
