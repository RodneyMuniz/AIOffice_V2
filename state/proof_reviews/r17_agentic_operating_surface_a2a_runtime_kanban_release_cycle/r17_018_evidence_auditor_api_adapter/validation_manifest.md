# R17-018 Validation Manifest

Required focused validation:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r17_evidence_auditor_api_adapter.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1

Boundary:
- Generated packet/check/UI/proof artifacts only.
- Adapter enabled remains false.
- No Evidence Auditor API invocation.
- No external API call.
- No real audit verdict.
- No external audit acceptance.
- No adapter runtime or tool-call runtime.
- No board mutation, A2A runtime, autonomous agents, product runtime, main merge, or future R17-019+ completion claim.
