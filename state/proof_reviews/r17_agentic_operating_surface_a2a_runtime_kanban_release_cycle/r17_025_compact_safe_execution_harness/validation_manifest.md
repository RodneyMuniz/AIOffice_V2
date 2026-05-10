# R17-025 Compact-Safe Execution Harness Validation Manifest

Required validation commands:

1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_execution_harness.ps1
2. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1
3. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1
4. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
5. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
6. git diff --check

The validator rejects missing baseline fields, missing allowed paths, broad wildcard writes, local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes unless explicitly allowed, oversized prompt packets, oversized generated artifacts, live runtime claims, OpenAI API claims, Codex API claims, autonomous agent claims, no-manual-prompt-transfer success claims, and future R17-026+ completion claims.
