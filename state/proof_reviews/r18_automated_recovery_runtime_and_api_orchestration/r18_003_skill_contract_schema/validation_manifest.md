# R18-003 Skill Contract Schema Validation Manifest

Required validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_skill_contract_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_skill_contract_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_skill_contract_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected status truth: R18 active through R18-003 only; R18-004 through R18-028 planned only.

Expected non-claims: no live skill execution, no live agent runtime, no A2A handoff schema, no live A2A runtime, no local runner runtime, no live recovery runtime, no API invocation, no automatic new-thread creation, no product runtime, no main merge, no solved Codex compaction/reliability, and no no-manual-prompt-transfer success.
