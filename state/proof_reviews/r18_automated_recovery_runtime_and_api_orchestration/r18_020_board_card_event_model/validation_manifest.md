# R18-020 Validation Manifest

Required validation:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_board_card_event_model.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_board_card_event_model.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_board_card_event_model.ps1
- Prior R18 validators and status-doc gate validators must continue to pass with R18 active through R18-020 only and R18-021 through R18-028 planned only.
- git diff --check

The validator fails closed on missing artifacts, missing card/event fields, unknown event types, unknown actor roles, unknown card statuses, missing card IDs, missing previous/next states where required, missing authority/evidence/status-boundary refs, R18-021+ completion claims, and runtime claims for live board runtime, mutation, work-order execution, A2A messages, live agent/skill/tool/API execution, recovery, retry, continuation/prompt execution, automatic thread creation, stage/commit/push by gate, release gate execution, audit acceptance, milestone closeout, main merge, CI replay, GitHub Actions workflow creation/run claims, product runtime, no-manual-prompt-transfer success, or solved Codex compaction/reliability.
