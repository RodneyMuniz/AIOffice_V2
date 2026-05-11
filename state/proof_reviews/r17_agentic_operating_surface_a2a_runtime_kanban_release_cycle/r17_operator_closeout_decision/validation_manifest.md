# R17 Operator Closeout Decision Validation Manifest

Required validation commands:

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_final_evidence_package.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_final_evidence_package.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r17_operator_closeout_decision.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r17_operator_closeout_decision.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1`
- `git diff --check`

Expected result: all commands pass while preserving the hard non-claims and keeping R18 active through R18-001 only.
