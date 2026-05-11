# R18-002 Agent Card Schema Validation Manifest

Required validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_agent_card_schema.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

Expected result: all commands pass before R18-002 is committed and pushed.

Non-claims: this manifest is not runtime proof, not skill implementation proof, not A2A runtime proof, not recovery runtime proof, not API invocation proof, and not main-merge proof.
