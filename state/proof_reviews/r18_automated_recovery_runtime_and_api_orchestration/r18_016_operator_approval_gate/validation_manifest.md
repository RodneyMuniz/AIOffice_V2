# R18-016 Validation Manifest

Expected status truth: R18 active through R18-016 only; R18-017 through R18-028 planned only.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_operator_approval_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_approval_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_approval_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

No operator approval runtime, inferred approval, risky seed approval, stage/commit/push gate, recovery action, retry execution, continuation execution, prompt execution, API invocation, work-order execution, board/card mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or main merge is claimed.
