# R17-026 Compact-Safe Harness Pilot Validation Manifest

Required validation commands:

1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_compact_safe_harness_pilot.ps1
2. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_harness_pilot.ps1
3. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_harness_pilot.ps1
4. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1
5. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_compact_safe_execution_harness.ps1
6. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
7. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
8. git diff --check

The validator rejects missing baseline fields, missing allowed paths, broad wildcard writes, local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes unless explicitly allowed, prompt packets over 2000 words, work orders that attempt the full Cycle 3 QA/fix-loop in one prompt, missing resume-after-compact and stage/commit/push prompt packets, OpenAI API claims, Codex API claims, autonomous Codex invocation claims, no-manual-prompt-transfer success claims, solved Codex compaction/reliability claims, QA result claims, audit verdict claims, product runtime claims, and future R17-027+ completion claims.

Residual finding: repeated Codex compact failures remain unresolved. A future milestone must prioritize automated recovery loops and new-context/thread continuation. R17-026 only pilots smaller work orders and does not solve the failure mode.
