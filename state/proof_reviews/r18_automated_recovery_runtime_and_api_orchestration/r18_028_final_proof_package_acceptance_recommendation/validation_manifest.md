# R18-028 Validation Manifest

Expected status truth: R18 active through R18-028 only; no R19 opened; closeout blocked pending explicit committed operator approval.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_final_proof_package_acceptance_recommendation.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_final_proof_package_acceptance_recommendation.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_final_proof_package_acceptance_recommendation.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_opening_authority.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_evidence_package_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_evidence_package_wrapper.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_operator_burden_reduction_metrics.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_operator_burden_reduction_metrics.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_cycle4_audit_closeout_harness.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_cycle4_audit_closeout_harness.ps1
- git diff --check
