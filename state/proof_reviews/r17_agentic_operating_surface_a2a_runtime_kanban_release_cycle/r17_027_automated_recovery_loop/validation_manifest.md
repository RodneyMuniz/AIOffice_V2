# R17-027 Automated Recovery Loop Validation Manifest

Required validation commands:

1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_automated_recovery_loop.ps1
2. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_automated_recovery_loop.ps1
3. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_automated_recovery_loop.ps1
4. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_execution_harness.ps1
5. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_compact_safe_harness_pilot.ps1
6. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
7. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
8. git diff --check

The validator rejects missing baseline head or tree, missing remote verification requirement, missing local inventory commands, missing WIP classification, missing continuation packet, missing new-context packet, missing retry limit, missing escalation policy, broad wildcard writes, operator local backup directory references, historical R13/R14/R15/R16 writes, kanban.js writes, prompt packets over 2000 words, new-context packets that depend on previous thread memory, new-context packets that ask for whole milestone completion, live runtime/API claims, product runtime claims, main merge claims, R17 closeout claims, solved compaction/reliability claims, no-manual-prompt-transfer success claims, and R17-028 completion claims.

Residual finding: live automation is still not implemented; automatic new-thread creation and API-level orchestration remain future work.
