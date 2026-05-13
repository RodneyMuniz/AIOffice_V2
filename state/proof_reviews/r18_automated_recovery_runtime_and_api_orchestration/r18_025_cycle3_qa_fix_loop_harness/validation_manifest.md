# R18-025 Validation Manifest

Expected status truth: R18 active through R18-025 only; R18-026 through R18-028 planned only.

Focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_cycle3_qa_fix_loop_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle3_qa_fix_loop_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle3_qa_fix_loop_harness.ps1

This manifest records deterministic local validation expectations only. It is not CI replay.
