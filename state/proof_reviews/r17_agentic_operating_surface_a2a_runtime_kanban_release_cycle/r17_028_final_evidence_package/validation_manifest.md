# R17-028 Final Evidence Package Validation Manifest

Required validation commands:

1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r17_final_evidence_package.ps1
1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_final_evidence_package.ps1
1. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_final_evidence_package.ps1
1. powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
1. powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
1. git diff --check

Validator rejection policy:

- reject R17 closed without operator approval;
- reject R18 opened;
- reject main merge or external audit acceptance claims;
- reject four exercised A2A cycles, live A2A runtime, live recovery-loop runtime, automatic new-thread creation, OpenAI API invocation, Codex API invocation, solved compaction/reliability, no-manual-prompt-transfer success, or product runtime claims;
- reject historical R13/R14/R15/R16 evidence edits;
- reject committed operator local backup directory references;
- reject kanban.js changes unless explicitly allowed;
- reject broad repo scan output and oversized generated artifacts.

Residual finding: live automated recovery and API-level orchestration remain future work.
