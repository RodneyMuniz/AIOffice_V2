# R18-008 Validation Manifest

Required validation:

- powershell -NoProfile -ExecutionPolicy Bypass -File tools\new_r18_work_order_state_machine.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r18_work_order_state_machine.ps1
- powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r18_work_order_state_machine.ps1
- Prior R18 validators and status-doc gate validators must continue to pass with R18 active through R18-008 only and R18-009 through R18-028 planned only.

The validator fails closed on missing artifacts, unknown states, unknown transitions, missing refs, missing validation/evidence obligations, unbounded next states, unbounded retry, forbidden path permissions, runtime/API/agent/skill/A2A/recovery/product claims, R18-009+ completion claims, and status surfaces beyond R18-008.
