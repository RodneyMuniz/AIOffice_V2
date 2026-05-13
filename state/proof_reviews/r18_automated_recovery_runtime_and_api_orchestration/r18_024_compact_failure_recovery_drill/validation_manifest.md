# R18-024 Validation Manifest

Expected status truth: R18 active through R18-024 only; R18-025 through R18-028 planned only.

Focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_compact_failure_recovery_drill.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_compact_failure_recovery_drill.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_compact_failure_recovery_drill.ps1

This manifest records deterministic local validation expectations only. It is not CI replay.
