# R18-012 Validation Manifest

Expected status truth after this package: R18 active through R18-013 only; R18-014 through R18-028 planned only.

Required validation commands:
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_remote_branch_verifier.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r18_remote_branch_verifier.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_remote_branch_verifier.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_remote_branch_verifier.ps1

Boundary: bounded git identity verification only. No continuation packets, new-context prompts, recovery actions, WIP cleanup, branch mutation, pull/rebase/reset/merge, checkout/switch, clean/restore, staging, commit, push, API invocation, live agent execution, live skill execution, A2A messages, or board/card runtime mutation.
