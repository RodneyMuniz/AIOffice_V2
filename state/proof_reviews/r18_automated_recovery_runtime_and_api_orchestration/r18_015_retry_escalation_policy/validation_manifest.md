# R18-015 Validation Manifest

Expected status truth: R18 active through R18-015 only; R18-016 through R18-028 planned only.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_retry_escalation_policy.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_retry_escalation_policy.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_retry_escalation_policy.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

No retry execution, recovery runtime, API invocation, continuation execution, prompt execution, work-order execution, WIP cleanup, branch mutation, A2A message, live agent, live skill, product runtime, no-manual-prompt-transfer success, solved compaction/reliability, or main merge is claimed.
