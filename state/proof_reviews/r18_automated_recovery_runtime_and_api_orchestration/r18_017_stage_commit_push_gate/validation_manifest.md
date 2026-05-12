# R18-017 Stage/Commit/Push Gate Validation Manifest

Expected validation commands:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_stage_commit_push_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_stage_commit_push_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_stage_commit_push_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1
- git diff --check

The R18-017 gate validator is fail-closed on missing artifacts, missing required fields, unknown scenarios/statuses/actions, unsafe safe-release inputs, safe blocked assessments, runtime claims, API claims, work-order execution claims, board/A2A/agent/skill claims, stage/commit/push claims, main merge claims, milestone closeout claims, and R18-018 or later completion claims.
