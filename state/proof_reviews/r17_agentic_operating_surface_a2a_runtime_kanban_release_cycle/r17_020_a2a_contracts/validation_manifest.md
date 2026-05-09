# R17-020 Validation Manifest

Expected focused validation:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_a2a_contracts.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_a2a_contracts.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_a2a_contracts.ps1
- relevant existing R17 registry, memory loader, invocation log, adapter, ledger, board/orchestration, and status gates
- git diff --check

The manifest is proof-review support only; command execution remains terminal Git/PowerShell truth.
