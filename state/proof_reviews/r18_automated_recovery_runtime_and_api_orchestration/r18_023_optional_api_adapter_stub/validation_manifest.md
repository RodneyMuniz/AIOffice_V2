# R18-023 Validation Manifest

Expected status truth: R18 active through R18-023 only; R18-024 through R18-028 planned only.

Focused commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\new_r18_optional_api_adapter_stub.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r18_optional_api_adapter_stub.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\\test_r18_optional_api_adapter_stub.ps1

This manifest records deterministic local validation expectations only. It is not CI replay.
