# R18-005 Validation Manifest

Expected validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_role_skill_permission_matrix.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_role_skill_permission_matrix.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_role_skill_permission_matrix.ps1

Expected status truth: R18 active through R18-005 only. R18-006 through R18-028 remain planned only.

The matrix is governance/control evidence only and is not runtime permission enforcement.
